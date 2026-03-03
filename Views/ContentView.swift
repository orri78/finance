import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Fréttir", systemImage: "newspaper.fill") {
                NewsTabView()
            }
            Tab("Markaðir", systemImage: "chart.bar.fill") {
                MarketOverviewView()
            }
            Tab("Leita", systemImage: "magnifyingglass") {
                SearchTabPlaceholderView()
            }
            Tab("Vaktlisti", systemImage: "star.fill") {
                WatchlistTabPlaceholderView()
            }
            Tab("Mín síða", systemImage: "person.fill") {
                ProfileTabPlaceholderView()
            }
        }
    }
}

// MARK: - Placeholder tabs (to be implemented in future phases)

private struct SearchTabPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Leita",
                systemImage: "building.2",
                description: Text("Leit að fyrirtækjum í Skattagátt kemur fljótlega.")
            )
            .navigationTitle("Fyrirtæki")
        }
    }
}

private struct WatchlistTabPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Vaktlisti",
                systemImage: "star",
                description: Text("Vistaðu hlutabréf hér. Skráðu þig inn til að samstilla.")
            )
            .navigationTitle("Vaktlisti")
        }
    }
}

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
