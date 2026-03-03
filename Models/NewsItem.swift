import Foundation

struct NewsItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let summary: String
    let source: NewsSource
    let publishedAt: Date
    let url: URL
    let imageURL: URL?
    let category: NewsCategory

    enum NewsSource: String, Codable, CaseIterable {
        case mbl = "mbl.is"
        case vb = "vb.is"
        case visir = "visir.is"

        var displayName: String { rawValue }
    }

    enum NewsCategory: String, Codable, CaseIterable {
        case viðskipti
        case markaðir
        case fasteignir
        case efnahagur
        case almennt

        var displayName: String {
            switch self {
            case .viðskipti: return "Viðskipti"
            case .markaðir: return "Markaðir"
            case .fasteignir: return "Fasteignir"
            case .efnahagur: return "Efnahagur"
            case .almennt: return "Almennt"
            }
        }
    }
}
