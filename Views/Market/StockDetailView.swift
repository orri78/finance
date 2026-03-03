import SwiftUI
import Charts

struct StockDetailView: View {
    @State private var viewModel: StockDetailViewModel
    @State private var isDescriptionExpanded = false

    init(quote: StockQuote) {
        _viewModel = State(initialValue: StockDetailViewModel(quote: quote))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                priceHeader
                    .padding(.horizontal)
                    .padding(.top, 8)

                chartSection
                    .padding(.top, 16)

                statsGrid
                    .padding(.horizontal)
                    .padding(.top, 20)

                aboutSection
                    .padding(.horizontal)
                    .padding(.top, 20)

                companyInfoSection
                    .padding(.horizontal)
                    .padding(.top, 20)

                watchlistButton
                    .padding(.horizontal)
                    .padding(.vertical, 24)
            }
        }
        .navigationTitle(viewModel.quote.ticker)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadChart() }
    }

    // MARK: - Price Header

    private var priceHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.quote.companyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.quote.currentPrice.iskFormatted)
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)

            HStack(spacing: 6) {
                Image(systemName: viewModel.quote.isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 13, weight: .semibold))
                Text(viewModel.quote.priceChange.iskFormatted)
                    .font(.system(size: 15, weight: .medium))
                Text("(\(viewModel.quote.percentChange.percentFormatted))")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(viewModel.quote.isPositive ? Color.priceUp : Color.priceDown)
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        VStack(spacing: 12) {
            ZStack {
                if viewModel.isLoadingChart {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                } else {
                    DetailChartView(
                        data: viewModel.historicalData,
                        isPositive: viewModel.quote.isPositive
                    )
                    .frame(height: 180)
                    .padding(.horizontal)
                }
            }

            rangePicker
                .padding(.horizontal)
        }
    }

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(ChartRange.allCases, id: \.self) { range in
                Button {
                    Task { await viewModel.selectRange(range) }
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.selectedRange == range
                                ? Color.brandAccent
                                : Color.clear
                        )
                        .foregroundStyle(
                            viewModel.selectedRange == range
                                ? Color.white
                                : Color.secondary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Key Stats Grid

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lykilstærðir")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCell(label: "Markaðsvirði", value: viewModel.quote.marketCap.compactFormatted + " kr.")
                StatCell(label: "Veltan í dag", value: "\(viewModel.quote.volume.formatted())")
                StatCell(label: "52v hæsta", value: viewModel.quote.high52Week.iskFormatted)
                StatCell(label: "52v lægsta", value: viewModel.quote.low52Week.iskFormatted)
                if let pe = viewModel.quote.peRatio {
                    StatCell(label: "V/H hlutfall", value: String(format: "%.1f", pe))
                }
                if let div = viewModel.quote.dividendYield {
                    StatCell(label: "Arðsávöxtun", value: String(format: "%.2f%%", div))
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Um fyrirtækið")
                .font(.headline)

            Text(viewModel.quote.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(isDescriptionExpanded ? nil : 3)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isDescriptionExpanded.toggle()
                }
            } label: {
                Text(isDescriptionExpanded ? "Sjá minna" : "Sjá meira")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.brandAccent)
            }
        }
    }

    // MARK: - Company Info Section

    private var companyInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Upplýsingar")
                .font(.headline)
                .padding(.bottom, 10)

            VStack(spacing: 0) {
                InfoRow(label: "Geirinn", value: viewModel.quote.sector)

                if let website = viewModel.quote.website {
                    Divider()
                    WebsiteRow(website: website)
                }

                if let founded = viewModel.quote.founded {
                    Divider()
                    InfoRow(label: "Stofnað", value: "\(founded)")
                }

                if let employees = viewModel.quote.employees {
                    Divider()
                    InfoRow(label: "Starfsmenn", value: employees.formatted())
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Watchlist Button

    private var watchlistButton: some View {
        Button {
            // TODO: toggle watchlist
        } label: {
            Label("Bæta við vaktlista", systemImage: "star")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundStyle(Color.brandAccent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Detail Chart

private struct DetailChartView: View {
    let data: [Double]
    let isPositive: Bool

    private var color: Color { isPositive ? .priceUp : .priceDown }

    private var indexed: [(i: Int, v: Double)] {
        data.enumerated().map { (i: $0.offset, v: $0.element) }
    }

    var body: some View {
        Chart(indexed, id: \.i) { point in
            LineMark(
                x: .value("Tími", point.i),
                y: .value("Verð", point.v)
            )
            .foregroundStyle(color)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Tími", point.i),
                yStart: .value("Min", data.min() ?? 0),
                yEnd: .value("Verð", point.v)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.25), color.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.secondary.opacity(0.3))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(v.compactFormatted)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYScale(domain: (data.min() ?? 0)...(data.max() ?? 1))
    }
}

// MARK: - Stat Cell

private struct StatCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Website Row

private struct WebsiteRow: View {
    let website: String

    var body: some View {
        HStack {
            Text("Vefsíða")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if let url = URL(string: "https://\(website)") {
                Link(website, destination: url)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.brandAccent)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        StockDetailView(quote: StockQuote(
            id: "MAREL",
            ticker: "MAREL",
            companyName: "Marel hf.",
            currentPrice: 382.50,
            previousClose: 375.00,
            openPrice: 376.00,
            high52Week: 420.00,
            low52Week: 290.00,
            volume: 1_250_000,
            marketCap: 287_000_000_000,
            currency: "ISK",
            sparklineData: [290, 300, 310, 305, 315, 320, 318, 325, 330, 328,
                            335, 340, 338, 345, 350, 348, 355, 360, 358, 365,
                            370, 368, 375, 372, 378, 382, 380, 382, 381, 382],
            logoURL: "https://logo.clearbit.com/marel.com",
            sector: "Tækni",
            description: "Marel hf. er leiðandi þróunar- og framleiðslufyrirtæki í sjávarútvegi, kjötvinnslu og alifuglaiðnaði. Félagið er skráð á Nasdaq Iceland og Euronext Amsterdam og starfar í yfir 30 löndum.",
            website: "marel.com",
            founded: 1983,
            employees: 7500,
            peRatio: 24.5,
            dividendYield: 1.8
        ))
    }
}
