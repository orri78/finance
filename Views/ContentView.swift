import SwiftUI

struct ContentView: View {
    // Shared across Search + Watchlist tabs so saved companies stay in sync
    @State private var companySearchViewModel = CompanySearchViewModel()

    var body: some View {
        TabView {
            NewsTabView()
                .tabItem { Label("Fréttir", systemImage: "newspaper.fill") }

            MarketOverviewView()
                .tabItem { Label("Markaðir", systemImage: "chart.bar.fill") }

            CompanySearchView()
                .environment(companySearchViewModel)
                .tabItem { Label("Leita", systemImage: "magnifyingglass") }

            WatchlistView()
                .environment(companySearchViewModel)
                .tabItem { Label("Vaktlisti", systemImage: "star.fill") }

            ProfileTabPlaceholderView()
                .tabItem { Label("Mín síða", systemImage: "person.fill") }
        }
    }
}

// MARK: - Profile placeholder

private struct ProfileTabPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Mín síða",
                systemImage: "person.circle",
                description: Text("Apple innskráning með Supabase kemur fljótlega.")
            )
            .navigationTitle("Mín síða")
        }
    }
}

#Preview {
    ContentView()
}
