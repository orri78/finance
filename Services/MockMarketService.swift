import Foundation

final class MockMarketService: MarketServiceProtocol {

    func fetchQuotes() async throws -> [StockQuote] {
        try await simulateNetworkDelay()
        return try loadStocksFromBundle()
    }

    func fetchQuote(ticker: String) async throws -> StockQuote {
        try await simulateNetworkDelay()
        let all = try loadStocksFromBundle()
        guard let quote = all.first(where: { $0.ticker == ticker }) else {
            throw MarketError.tickerNotFound(ticker)
        }
        return quote
    }

    func fetchHistoricalData(ticker: String, range: ChartRange) async throws -> [Double] {
        try await simulateNetworkDelay()
        let quote = try await fetchQuote(ticker: ticker)
        // For mock, generate plausible historical data derived from current price
        return generateHistoricalData(basePrice: quote.currentPrice, range: range)
    }

    func fetchIndexValue() async throws -> IndexSnapshot {
        try await simulateNetworkDelay()
        return IndexSnapshot(
            name: "OMXICPI",
            value: 2_847.35,
            previousClose: 2_821.10
        )
    }

    // MARK: - Private

    private func loadStocksFromBundle() throws -> [StockQuote] {
        guard let url = Bundle.main.url(forResource: "mock_stocks", withExtension: "json") else {
            throw MarketError.bundleResourceMissing("mock_stocks.json")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([StockQuote].self, from: data)
    }

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    private func generateHistoricalData(basePrice: Double, range: ChartRange) -> [Double] {
        let pointCount: Int
        switch range {
        case .oneDay:       pointCount = 30
        case .oneWeek:      pointCount = 35
        case .oneMonth:     pointCount = 30
        case .threeMonths:  pointCount = 90
        case .oneYear:      pointCount = 52
        case .fiveYears:    pointCount = 60
        }

        var prices: [Double] = []
        var price = basePrice * 0.92
        for _ in 0..<pointCount {
            let delta = price * Double.random(in: -0.015...0.018)
            price = max(price + delta, basePrice * 0.5)
            prices.append(price)
        }
        prices[prices.count - 1] = basePrice
        return prices
    }
}

enum MarketError: LocalizedError {
    case tickerNotFound(String)
    case bundleResourceMissing(String)

    var errorDescription: String? {
        switch self {
        case .tickerNotFound(let t): return "Hlutabréf fannst ekki: \(t)"
        case .bundleResourceMissing(let f): return "Gögn vantar: \(f)"
        }
    }
}
