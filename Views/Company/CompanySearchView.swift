import SwiftUI

struct CompanySearchView: View {
    @Environment(CompanySearchViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            List {
                // Saved companies shown when search bar is empty
                if vm.searchQuery.isEmpty && !viewModel.savedCompanies.isEmpty {
                    Section("Vistuð") {
                        ForEach(viewModel.savedCompanies) { entity in
                            NavigationLink(destination: CompanyDetailView(entity: entity)) {
                                CompanyRowView(entity: entity)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.remove(entity)
                                } label: {
                                    Label("Eyða", systemImage: "star.slash")
                                }
                            }
                        }
                    }
                }

                // Search results
                if !vm.searchQuery.isEmpty {
                    if viewModel.isSearching {
                        Section {
                            HStack {
                                ProgressView()
                                Text("Leita…")
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 8)
                            }
                            .listRowBackground(Color.clear)
                        }
                    } else if !viewModel.results.isEmpty {
                        Section("\(viewModel.results.count) niðurstöður") {
                            ForEach(viewModel.results) { entity in
                                NavigationLink(destination: CompanyDetailView(entity: entity)) {
                                    CompanyRowView(entity: entity)
                                }
                            }
                        }
                    } else if let error = viewModel.errorMessage {
                        Section {
                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .listRowBackground(Color.clear)
                        }
                    }
                }

                // Empty state
                if vm.searchQuery.isEmpty && viewModel.savedCompanies.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "building.2.crop.circle")
                                .font(.system(size: 52))
                                .foregroundStyle(.tertiary)
                            Text("Leita að fyrirtæki")
                                .font(.headline)
                            Text("Sláðu inn nafn eða kennitölu (10 tölustafir)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Fyrirtæki")
            .searchable(
                text: $vm.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Nafn eða kennitala…"
            )
            .onChange(of: vm.searchQuery) { _, _ in
                viewModel.onQueryChange()
            }
        }
    }
}
