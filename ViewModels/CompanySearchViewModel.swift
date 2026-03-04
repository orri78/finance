import Foundation
import Observation

@MainActor
@Observable
final class CompanySearchViewModel {

    var searchQuery = ""
    var results: [LegalEntity] = []
    var savedCompanies: [LegalEntity] = []
    var isSearching = false
    var errorMessage: String? = nil

    private let service: any CompanyRegistryProtocol
    private var searchTask: Task<Void, Never>?

    init(service: (any CompanyRegistryProtocol)? = nil) {
        self.service = service ?? CompanyRegistryService()
        loadSaved()
    }

    // MARK: - Search

    /// Called on every keystroke — debounces 0.4s before firing.
    func onQueryChange() {
        searchTask?.cancel()
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        guard query.count >= 2 else {
            results = []
            errorMessage = nil
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }

    private func performSearch(query: String) async {
        isSearching = true
        errorMessage = nil
        do {
            results = try await service.search(query: query)
            if results.isEmpty {
                errorMessage = "Engar niðurstöður fundust fyrir '\(query)'"
            }
        } catch {
            results = []
            errorMessage = error.localizedDescription
        }
        isSearching = false
    }

    // MARK: - Saved companies (UserDefaults persistence)

    func save(_ entity: LegalEntity) {
        guard !isSaved(entity) else { return }
        savedCompanies.insert(entity, at: 0)
        persistSaved()
    }

    func remove(_ entity: LegalEntity) {
        savedCompanies.removeAll { $0.kennitala == entity.kennitala }
        persistSaved()
    }

    func isSaved(_ entity: LegalEntity) -> Bool {
        savedCompanies.contains { $0.kennitala == entity.kennitala }
    }

    private func persistSaved() {
        if let data = try? JSONEncoder().encode(savedCompanies) {
            UserDefaults.standard.set(data, forKey: "savedCompanies")
        }
    }

    private func loadSaved() {
        guard let data = UserDefaults.standard.data(forKey: "savedCompanies"),
              let entities = try? JSONDecoder().decode([LegalEntity].self, from: data)
        else { return }
        savedCompanies = entities
    }
}
