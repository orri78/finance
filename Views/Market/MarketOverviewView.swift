import SwiftUI

struct MarketOverviewView: View {
    @State private var viewModel = MarketViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    stockList
                }
            }
            .navigationTitle("Markaðir")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Stock list

    private var stockList: some View {
        List {
            // Index header section
            if let snapshot = viewModel.indexSnapshot {
                Section {
                    IndexHeaderView(snapshot: snapshot)
                }
                .listSectionSeparator(.hidden)
            }

            // Filter picker
            Section {
                Picker("Sía", selection: $viewModel.filter) {
                    ForEach(MarketFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            }
            .listSectionSeparator(.hidden)

            // Stock rows
            Section {
                ForEach(viewModel.filteredQuotes) { quote in
                    NavigationLink {
                        StockDetailView(quote: quote)
                    } label: {
                        StockRowView(quote: quote)
                    }
                    .listRowBackground(Color.surface)
                }
            } header: {
                Text("Hlutabréf — Nasdaq Iceland")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut(duration: 0.2), value: viewModel.filter)
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Sæki gögn…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Gat ekki sótt gögn",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }
}

// MARK: - Index Header

private struct IndexHeaderView: View {
    let snapshot: IndexSnapshot

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(snapshot.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(snapshot.value, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Dagurinn")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 3) {
                    Image(systemName: snapshot.isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption.bold())
                    Text(snapshot.percentChange.percentFormatted)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(snapshot.isPositive ? Color.priceUp : Color.priceDown)
            }
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    MarketOverviewView()
}
