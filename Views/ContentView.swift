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

            ProfileTabView()
                .tabItem { Label("Mín síða", systemImage: "person.fill") }
        }
    }
}

#Preview {
    ContentView()
}
