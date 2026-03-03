import Foundation

struct StockQuote: Identifiable, Codable {
    let id: String          // ticker symbol, e.g. "MAREL"
    let ticker: String
    let companyName: String
    let currentPrice: Double
    let previousClose: Double
    let openPrice: Double
    let high52Week: Double
    let low52Week: Double
    let volume: Int
    let marketCap: Double
    let currency: String    // "ISK"
    let sparklineData: [Double]

    var priceChange: Double {
        currentPrice - previousClose
    }

    var percentChange: Double {
        guard previousClose != 0 else { return 0 }
        return (priceChange / previousClose) * 100
    }

    var isPositive: Bool {
        priceChange >= 0
    }
}

enum ChartRange: String, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1V"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Á"
    case fiveYears = "5Á"
}
