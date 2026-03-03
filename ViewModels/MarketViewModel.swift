import Foundation
import Observation

enum MarketFilter: String, CaseIterable {
    case all = "Allir"
    case topGainers = "Hæstir"
    case topLosers = "Lægstir"
    case mostActive = "Mest viðskipti"
}

@MainActor
@Observable
final class MarketViewModel {

    var quotes: [StockQuote] = []
    var indexSnapshot: IndexSnapshot?
    var filter: MarketFilter = .all
    var isLoading = false
    var error: Error?

    var filteredQuotes: [StockQuote] {
        switch filter {
        case .all:
            return quotes
        case .topGainers:
            return quotes.sorted { $0.percentChange > $1.percentChange }
        case .topLosers:
            return quotes.sorted { $0.percentChange < $1.percentChange }
        case .mostActive:
            return quotes.sorted { $0.volume > $1.volume }
        }
    }

    private let service: any MarketServiceProtocol

    init(service: (any MarketServiceProtocol)? = nil) {
        self.service = service ?? MockMarketService()
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            async let quotesTask = service.fetchQuotes()
            async let indexTask = service.fetchIndexValue()
            quotes = try await quotesTask
            indexSnapshot = try await indexTask
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
