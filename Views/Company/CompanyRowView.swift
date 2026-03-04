import SwiftUI

struct CompanyRowView: View {
    let entity: LegalEntity

    var body: some View {
        HStack(spacing: 12) {
            // Legal form badge
            Text(shortForm)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(entity.statusColor)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(minWidth: 36)

            // Company info
            VStack(alignment: .leading, spacing: 3) {
                Text(entity.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(entity.kennitala)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                    if let city = entity.address?.city {
                        Text("· \(city)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Status pill
            Text(entity.isActive ? "Í rekstri" : "Afskráð")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(entity.statusColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(entity.statusColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private var shortForm: String {
        entity.legalFormCode ?? String(entity.legalFormDisplay.prefix(3)).uppercased()
    }
}
