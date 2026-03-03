import SwiftUI

struct StockRowView: View {
    let quote: StockQuote

    var body: some View {
        HStack(spacing: 12) {
            tickerBadge
            centerInfo
            Spacer()
            sparklineAndPrice
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    private var tickerBadge: some View {
        Text(String(quote.ticker.prefix(2)))
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .frame(width: 38, height: 38)
            .background(tickerColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var centerInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(quote.ticker)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            Text(quote.companyName)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var sparklineAndPrice: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                SparklineChartView(data: quote.sparklineData, isPositive: quote.isPositive)
                priceStack
            }
        }
    }

    private var priceStack: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(quote.currentPrice.iskFormatted)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)

            HStack(spacing: 2) {
                Image(systemName: quote.isPositive ? "arrow.up" : "arrow.down")
                    .font(.system(size: 9, weight: .bold))
                Text(quote.percentChange.percentFormatted)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(quote.isPositive ? Color.priceUp : Color.priceDown)
        }
    }

    // MARK: - Helpers

    private var tickerColor: Color {
        // Deterministic color per ticker from a curated palette
        let colors: [Color] = [
            Color(red: 0.18, green: 0.45, blue: 0.78),
            Color(red: 0.55, green: 0.25, blue: 0.75),
            Color(red: 0.18, green: 0.62, blue: 0.55),
            Color(red: 0.78, green: 0.35, blue: 0.18),
            Color(red: 0.25, green: 0.55, blue: 0.32),
            Color(red: 0.62, green: 0.18, blue: 0.38),
            Color(red: 0.45, green: 0.38, blue: 0.18),
            Color(red: 0.18, green: 0.38, blue: 0.62),
        ]
        let index = abs(quote.ticker.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    List {
        StockRowView(quote: StockQuote(
            id: "MAREL",
            ticker: "MAREL",
            companyName: "Marel hf.",
            currentPrice: 382.50,
            previousClose: 375.00,
            openPrice: 376.00,
            high52Week: 520.00,
            low52Week: 310.00,
            volume: 1_243_800,
            marketCap: 287_000_000_000,
            currency: "ISK",
            sparklineData: [375, 377, 376, 379, 381, 380, 382, 381, 383, 382.5]
        ))
        StockRowView(quote: StockQuote(
            id: "PLAY",
            ticker: "PLAY",
            companyName: "Play hf.",
            currentPrice: 78.50,
            previousClose: 83.00,
            openPrice: 82.50,
            high52Week: 125.00,
            low52Week: 62.00,
            volume: 4_812_600,
            marketCap: 18_500_000_000,
            currency: "ISK",
            sparklineData: [83, 82, 81, 80, 79.5, 79, 78.8, 78.5, 78.6, 78.5]
        ))
    }
}
