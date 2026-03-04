import SwiftUI
import SafariServices

struct CompanyDetailView: View {
    let entity: LegalEntity
    @Environment(CompanySearchViewModel.self) private var searchVM

    @State private var showSafari = false
    @State private var safariURL: URL? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header.padding()
                Divider()
                contactSection
                registrationSection
                industrySection
                Spacer(minLength: 80)
            }
        }
        .navigationTitle(entity.shortName ?? entity.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { saveButton }
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SFSafariViewWrapper(url: url).ignoresSafeArea()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entity.name)
                        .font(.system(size: 22, weight: .bold))
                    if let short = entity.shortName, short != entity.name {
                        Text(short).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                statusPill
            }
            HStack(spacing: 6) {
                Label(entity.kennitala, systemImage: "number")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.secondary)
                if let lf = entity.legalForm {
                    Text("· \(lf)").font(.system(size: 13)).foregroundStyle(.secondary)
                }
            }
        }
    }

    private var statusPill: some View {
        Text(entity.isActive ? "Í rekstri" : "Afskráð")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(entity.statusColor)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(entity.statusColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var saveButton: some View {
        Button {
            searchVM.isSaved(entity) ? searchVM.remove(entity) : searchVM.save(entity)
        } label: {
            Image(systemName: searchVM.isSaved(entity) ? "star.fill" : "star")
                .foregroundStyle(Color.brandAccent)
        }
    }

    // MARK: - Contact

    private var contactSection: some View {
        SectionCard(title: "Tengiliðaupplýsingar") {
            if let addr = entity.address, !addr.formatted.isEmpty {
                InfoRow(icon: "mappin.circle", label: "Heimilisfang", value: addr.formatted, tappable: true) {
                    openMaps(addr.mapsQuery)
                }
            }
            if let email = entity.email {
                InfoRow(icon: "envelope", label: "Netfang", value: email, tappable: true) {
                    open(url: URL(string: "mailto:\(email)"))
                }
            }
            if let phone = entity.phone {
                InfoRow(icon: "phone", label: "Sími", value: phone, tappable: true) {
                    open(url: URL(string: "tel:\(phone.filter(\.isNumber))"))
                }
            }
            if let site = entity.website {
                InfoRow(icon: "globe", label: "Vefsíða", value: site, tappable: true) {
                    safariURL = entity.websiteURL; showSafari = safariURL != nil
                }
            }
        }
    }

    // MARK: - Registration

    private var registrationSection: some View {
        SectionCard(title: "Skráningarupplýsingar") {
            InfoRow(icon: "creditcard", label: "Kennitala", value: entity.kennitala, tappable: false)
            if let vat = entity.vatNumber {
                InfoRow(icon: "doc.text", label: "VSK-númer", value: vat, tappable: false)
            }
            if let date = entity.registrationDate {
                InfoRow(icon: "calendar", label: "Stofndagur", value: date, tappable: false)
            }
            if let lf = entity.legalForm {
                InfoRow(icon: "building.2", label: "Rekstrarform", value: lf, tappable: false)
            }
            if let cap = entity.shareCapital {
                InfoRow(icon: "banknote", label: "Hlutafé", value: cap.iskFormatted, tappable: false)
            }
        }
    }

    // MARK: - Industry

    private var industrySection: some View {
        SectionCard(title: "Atvinnugrein") {
            if let code = entity.industryCode {
                InfoRow(icon: "tag", label: "ÍSAT-kóði", value: code, tappable: false)
            }
            if let desc = entity.industryDescription {
                InfoRow(icon: "briefcase", label: "Starfsemi", value: desc, tappable: false)
            }
            if let emp = entity.employees {
                InfoRow(icon: "person.3", label: "Starfsmenn", value: emp, tappable: false)
            }
        }
    }

    // MARK: - Helpers

    private func open(url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }

    private func openMaps(_ query: String) {
        let enc = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        open(url: URL(string: "maps://?q=\(enc)"))
    }
}

// MARK: - SFSafariViewController wrapper

private struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = UIColor(Color.brandAccent)
        return vc
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Section Card

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 8)
            VStack(spacing: 0) {
                content()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let tappable: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        Button { action?() } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundStyle(Color.brandAccent)
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(tappable ? Color.brandAccent : .primary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                if tappable {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        .disabled(!tappable)

        Divider().padding(.leading, 46)
    }
}
