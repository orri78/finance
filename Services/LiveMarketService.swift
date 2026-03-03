import Foundation

/// Stub for the live Nasdaq Iceland / OMXICPI data feed.
/// Replace the placeholder URL and parsing logic when the API is available.
final class LiveMarketService: MarketServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchQuotes() async throws -> [StockQuote] {
        // TODO: Call Nasdaq Iceland market data endpoint
        // Example endpoint (replace with real): https://api.nasdaqomxnordic.com/...
        throw MarketError.bundleResourceMissing("Live API not configured")
    }

    func fetchQuote(ticker: String) async throws -> StockQuote {
        throw MarketError.bundleResourceMissing("Live API not configured")
    }

    func fetchHistoricalData(ticker: String, range: ChartRange) async throws -> [Double] {
        throw MarketError.bundleResourceMissing("Live API not configured")
    }

    func fetchIndexValue() async throws -> IndexSnapshot {
        throw MarketError.bundleResourceMissing("Live API not configured")
    }
}
