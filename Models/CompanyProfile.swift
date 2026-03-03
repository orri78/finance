import Foundation

struct CompanyProfile: Identifiable, Codable {
    let id: String              // kennitala (Icelandic company registration number)
    let kennitala: String
    let name: String
    let shortName: String?
    let industry: String
    let sector: String?
    let address: String?
    let website: URL?
    let numberOfEmployees: Int?
    let revenue: Double?        // ISK
    let ticker: String?         // nil if not publicly listed
    let foundedYear: Int?
    let description: String?

    var isListed: Bool {
        ticker != nil
    }
}
