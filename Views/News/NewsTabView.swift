import SwiftUI

struct NewsTabView: View {
    @State private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredItems.isEmpty && viewModel.hasLoaded {
                    emptyView
                } else {
                    newsList
                }
            }
            .navigationTitle("Fréttir")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sourceFilterMenu
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - News list

    private var newsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Error banner (non-blocking)
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }

                ForEach(viewModel.filteredItems) { item in
                    Link(destination: item.url) {
                        NewsCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Source filter menu

    private var sourceFilterMenu: some View {
        Menu {
            Button {
                viewModel.selectedSource = nil
            } label: {
                Label("Allar heimildir", systemImage: viewModel.selectedSource == nil ? "checkmark" : "")
            }
            Divider()
            ForEach(NewsItem.NewsSource.allCases, id: \.self) { source in
                Button {
                    viewModel.selectedSource = source
                } label: {
                    Label(
                        source.displayName,
                        systemImage: viewModel.selectedSource == source ? "checkmark" : ""
                    )
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolVariant(viewModel.selectedSource != nil ? .fill : .none)
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Sæki fréttir…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Engar fréttir",
            systemImage: "newspaper",
            description: Text("Drægðu niður til að uppfæra, eða athugaðu nettengingu.")
        )
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.exclamationmark")
            Text(message)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NewsTabView()
}
