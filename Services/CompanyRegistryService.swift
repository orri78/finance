import Foundation

// MARK: - Protocol

protocol CompanyRegistryProtocol {
    func search(query: String) async throws -> [LegalEntity]
    func fetch(kennitala: String) async throws -> LegalEntity
}

// MARK: - Errors

enum CompanyRegistryError: LocalizedError {
    case notFound
    case invalidResponse
    case networkError(Error)
    case apiError(Int, String)

    var errorDescription: String? {
        switch self {
        case .notFound:             return "Fyrirtæki fannst ekki."
        case .invalidResponse:      return "Ógilt svar frá þjóni."
        case .networkError(let e):  return "Netvillu: \(e.localizedDescription)"
        case .apiError(let code, let msg): return "Villa \(code): \(msg)"
        }
    }
}

// MARK: - Live Service

final class CompanyRegistryService: CompanyRegistryProtocol {

    private let baseURL = "https://api.skatturinn.is/company-registry-legalentities-v2"
    private let session: URLSession

    /// Always reads the latest key from UserDefaults so changes in Settings take effect immediately.
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "skatturinnAPIKey") ?? ""
    }

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Search by company name or kennitala (auto-detected).
    func search(query: String) async throws -> [LegalEntity] {
        let isKennitala = query.allSatisfy(\.isNumber) && query.count == 10
        if isKennitala {
            let entity = try await fetch(kennitala: query)
            return [entity]
        }
        return try await searchByName(query)
    }

    func fetch(kennitala: String) async throws -> LegalEntity {
        let url = try makeURL("/v2/legalentity/\(kennitala)")
        let data = try await performRequest(url: url)
        print("📋 Fetched entity: \(data.count) bytes")
        print("Raw: \(String(data: data, encoding: .utf8) ?? "")")
        return try decode(LegalEntity.self, from: data)
    }

    // MARK: - Private

    private func searchByName(_ name: String) async throws -> [LegalEntity] {
        var comps = URLComponents(string: baseURL + "/v2/legalentities")!
        comps.queryItems = [URLQueryItem(name: "name", value: name)]
        guard let url = comps.url else { throw CompanyRegistryError.invalidResponse }
        let data = try await performRequest(url: url)
        print("🔍 Search '\(name)': \(data.count) bytes")
        print("Raw: \(String(data: data, encoding: .utf8) ?? "")")
        // API may return array directly or wrapped in a container
        if let entities = try? JSONDecoder().decode([LegalEntity].self, from: data) {
            return entities
        }
        if let wrapper = try? JSONDecoder().decode(SearchResponse.self, from: data) {
            return wrapper.items ?? wrapper.value ?? []
        }
        throw CompanyRegistryError.invalidResponse
    }

    private func performRequest(url: URL) async throws -> Data {
        var req = URLRequest(url: url)
        req.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        print("🌐 Request: \(url.absoluteString)")
        print("🔑 Key present: \(!apiKey.isEmpty)")
        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                throw CompanyRegistryError.invalidResponse
            }
            switch http.statusCode {
            case 200...299: return data
            case 404:       throw CompanyRegistryError.notFound
            default:
                let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw CompanyRegistryError.apiError(http.statusCode, msg)
            }
        } catch let e as CompanyRegistryError {
            throw e
        } catch {
            throw CompanyRegistryError.networkError(error)
        }
    }

    private func makeURL(_ path: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw CompanyRegistryError.invalidResponse
        }
        return url
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("⚠️ Decode error: \(error)")
            throw CompanyRegistryError.invalidResponse
        }
    }
}

// MARK: - Response wrappers (handle different API envelope formats)

private struct SearchResponse: Decodable {
    let items: [LegalEntity]?
    let value: [LegalEntity]?
}
