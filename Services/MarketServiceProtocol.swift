import Foundation

protocol MarketServiceProtocol {
    func fetchQuotes() async throws -> [StockQuote]
    func fetchQuote(ticker: String) async throws -> StockQuote
    func fetchHistoricalData(ticker: String, range: ChartRange) async throws -> [Double]
    func fetchIndexValue() async throws -> IndexSnapshot
}

struct IndexSnapshot {
    let name: String        // e.g. "OMXICPI"
    let value: Double
    let previousClose: Double

    var change: Double { value - previousClose }
    var percentChange: Double {
        guard previousClose != 0 else { return 0 }
        return (change / previousClose) * 100
    }
    var isPositive: Bool { change >= 0 }
}
