import Foundation
import SwiftUI

struct LegalEntity: Identifiable, Codable, Hashable {

    // MARK: - Core identity
    var id: String { kennitala }
    let kennitala: String
    let name: String
    let shortName: String?

    // MARK: - Legal & registration
    let legalForm: String?          // e.g. "Hlutafélag", "Einkahlutafélag"
    let legalFormCode: String?      // e.g. "HF", "EHF"
    let status: String?             // e.g. "Í rekstri", "Afskráð"
    let registrationDate: String?
    let vatNumber: String?
    let shareCapital: Double?

    // MARK: - Contact
    let address: LegalAddress?
    let email: String?
    let phone: String?
    let website: String?

    // MARK: - Industry
    let industryCode: String?       // ISAT code e.g. "64.19"
    let industryDescription: String?
    let employees: String?          // range e.g. "10-49"

    // MARK: - Computed
    var isActive: Bool {
        guard let s = status else { return true }
        return !s.lowercased().contains("afskrá")
    }

    var statusColor: Color {
        isActive ? Color(red: 0.18, green: 0.78, blue: 0.44) : Color(red: 0.94, green: 0.27, blue: 0.33)
    }

    var legalFormDisplay: String {
        legalForm ?? legalFormCode ?? "Félag"
    }

    var websiteURL: URL? {
        guard let w = website else { return nil }
        let prefixed = w.hasPrefix("http") ? w : "https://\(w)"
        return URL(string: prefixed)
    }

    // MARK: - CodingKeys (maps common Skatturinn API field names)
    enum CodingKeys: String, CodingKey {
        case kennitala
        case name           = "name"
        case shortName      = "shortName"
        case legalForm      = "legalForm"
        case legalFormCode  = "legalFormCode"
        case status         = "status"
        case registrationDate = "registrationDate"
        case vatNumber      = "vatNumber"
        case shareCapital   = "shareCapital"
        case address        = "address"
        case email          = "email"
        case phone          = "phone"
        case website        = "website"
        case industryCode   = "industryCode"
        case industryDescription = "industryDescription"
        case employees      = "employees"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kennitala         = try c.decode(String.self, forKey: .kennitala)
        name              = try c.decode(String.self, forKey: .name)
        shortName         = try? c.decode(String.self, forKey: .shortName)
        legalForm         = try? c.decode(String.self, forKey: .legalForm)
        legalFormCode     = try? c.decode(String.self, forKey: .legalFormCode)
        status            = try? c.decode(String.self, forKey: .status)
        registrationDate  = try? c.decode(String.self, forKey: .registrationDate)
        vatNumber         = try? c.decode(String.self, forKey: .vatNumber)
        shareCapital      = try? c.decode(Double.self, forKey: .shareCapital)
        address           = try? c.decode(LegalAddress.self, forKey: .address)
        email             = try? c.decode(String.self, forKey: .email)
        phone             = try? c.decode(String.self, forKey: .phone)
        website           = try? c.decode(String.self, forKey: .website)
        industryCode      = try? c.decode(String.self, forKey: .industryCode)
        industryDescription = try? c.decode(String.self, forKey: .industryDescription)
        employees         = try? c.decode(String.self, forKey: .employees)
    }
}

struct LegalAddress: Codable, Hashable {
    let street: String?
    let postalCode: String?
    let city: String?
    let country: String?

    var formatted: String {
        [street, postalCode.map { "\($0)" }.flatMap { Optional($0) }, city]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    var mapsQuery: String {
        [street, city, "Ísland"].compactMap { $0 }.joined(separator: ", ")
    }

    enum CodingKeys: String, CodingKey {
        case street      = "street"
        case postalCode  = "postalCode"
        case city        = "city"
        case country     = "country"
    }
}
