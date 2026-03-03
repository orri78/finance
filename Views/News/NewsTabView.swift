import SwiftUI

struct NewsTabView: View {
    @State private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sortToggle

                Divider()

                Group {
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.filteredItems.isEmpty && viewModel.hasLoaded {
                        emptyView
                    } else {
                        newsList
                    }
                }
            }
            .navigationTitle("Fréttir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sourceFilterMenu
                }
            }
            .sheet(item: $viewModel.selectedItem) { item in
                NewsReaderView(item: item)
                    .ignoresSafeArea()
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Sort Toggle

    private var sortToggle: some View {
        HStack(spacing: 0) {
            ForEach(NewsSortMode.allCases, id: \.self) { mode in
                Button {
                    Task { await viewModel.switchMode(mode) }
                } label: {
                    VStack(spacing: 6) {
                        Text(mode.rawValue.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(viewModel.sortMode == mode ? .primary : .secondary)
                            .padding(.top, 10)

                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(viewModel.sortMode == mode ? Color.brandAccent : Color.clear)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - News list

    private var newsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let error = viewModel.errorMessage {
                    errorBanner(error)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }

                ForEach(viewModel.filteredItems) { item in
                    Button {
                        viewModel.selectedItem = item
                    } label: {
                        NewsCardView(item: item)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 116)
                }
            }
            .padding(.vertical, 4)
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
