import SwiftUI

struct ProfileTabView: View {
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "skatturinnAPIKey") ?? ""
    @State private var showKey = false

    var body: some View {
        NavigationStack {
            List {
                apiKeySection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stillingar")
        }
    }

    // MARK: - API Key Section

    private var apiKeySection: some View {
        Section {
            // Key input
            HStack {
                Group {
                    if showKey {
                        TextField("Límdu inn API lykil…", text: $apiKey)
                    } else {
                        SecureField("Límdu inn API lykil…", text: $apiKey)
                    }
                }
                .font(.system(size: 14, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: apiKey) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "skatturinnAPIKey")
                }

                Button {
                    showKey.toggle()
                } label: {
                    Image(systemName: showKey ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Status row
            if apiKey.isEmpty {
                Label("Enginn lykill stilltur", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .font(.subheadline)
            } else {
                Label("Lykill vistaður", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color(red: 0.18, green: 0.78, blue: 0.44))
                    .font(.subheadline)
            }

            // Link to get a key
            Link(destination: URL(string: "https://api.skatturinn.is")!) {
                HStack {
                    Text("Sækja um API aðgang")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .foregroundStyle(Color(red: 0.18, green: 0.78, blue: 0.44))
            }

        } header: {
            Text("Skatturinn API")
        } footer: {
            Text("API lykillinn er notaður til að leita í Fyrirtækjaskrá Skatturins. Þú getur sótt um aðgang á api.skatturinn.is.")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("Um forritið") {
            LabeledContent("Útgáfa", value: appVersion)
            LabeledContent("Gagnaveita — Fréttir", value: "mbl.is · vb.is · visir.is")
            LabeledContent("Gagnaveita — Markaðir", value: "Nasdaq Iceland")
            LabeledContent("Gagnaveita — Fyrirtæki", value: "Skatturinn")

            Link(destination: URL(string: "https://github.com/orri78/finance")!) {
                HStack {
                    Text("Frumkóði á GitHub")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .foregroundStyle(Color(red: 0.18, green: 0.78, blue: 0.44))
            }
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

#Preview {
    ProfileTabView()
}
