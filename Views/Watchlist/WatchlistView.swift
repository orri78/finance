import SwiftUI

struct WatchlistView: View {
    @Environment(CompanySearchViewModel.self) private var searchVM

    var body: some View {
        NavigationStack {
            Group {
                if searchVM.savedCompanies.isEmpty {
                    emptyView
                } else {
                    watchlist
                }
            }
            .navigationTitle("Vaktlisti")
        }
    }

    private var watchlist: some View {
        List {
            Section("Vistuð fyrirtæki") {
                ForEach(searchVM.savedCompanies) { entity in
                    NavigationLink {
                        CompanyDetailView(entity: entity)
                            .environment(searchVM)
                    } label: {
                        CompanyRowView(entity: entity)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            searchVM.remove(entity)
                        } label: {
                            Label("Eyða", systemImage: "star.slash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Vaktlisti er tómur",
            systemImage: "star",
            description: Text("Leitu að fyrirtæki í Leita flipanum og vistaðu það með stjörnunni.")
        )
    }
}
