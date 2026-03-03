import Foundation
import Observation

@MainActor
@Observable
final class StockDetailViewModel {

    let quote: StockQuote
    var historicalData: [Double] = []
    var selectedRange: ChartRange = .oneDay
    var isLoadingChart = false

    private let service: any MarketServiceProtocol

    init(quote: StockQuote, service: (any MarketServiceProtocol)? = nil) {
        self.quote = quote
        self.service = service ?? MockMarketService()
        self.historicalData = quote.sparklineData
    }

    func loadChart() async {
        isLoadingChart = true
        if let data = try? await service.fetchHistoricalData(ticker: quote.ticker, range: selectedRange) {
            historicalData = data
        }
        isLoadingChart = false
    }

    func selectRange(_ range: ChartRange) async {
        selectedRange = range
        await loadChart()
    }
}
