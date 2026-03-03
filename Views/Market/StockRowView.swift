import SwiftUI

struct StockRowView: View {
    let quote: StockQuote

    var body: some View {
        HStack(spacing: 12) {
            logoBadge
            centerInfo
            Spacer()
            sparklineAndPrice
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    private var logoBadge: some View {
        Group {
            if let urlStr = quote.logoURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    case .failure, .empty:
                        initialsView
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: 38, height: 38)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.surfaceSecondary, lineWidth: 1))
    }

    private var initialsView: some View {
        Text(String(quote.ticker.prefix(2)))
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tickerColor)
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
            Text(quote.sector)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
    }

    private var sparklineAndPrice: some View {
        HStack(alignment: .center, spacing: 8) {
            SparklineChartView(data: quote.sparklineData, isPositive: quote.isPositive)
            priceStack
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
