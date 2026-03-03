import SwiftUI

struct NewsCardView: View {
    let item: NewsItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
            textContent
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }

    // MARK: - Thumbnail

    private var thumbnail: some View {
        Group {
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        fallbackThumb
                    @unknown default:
                        fallbackThumb
                    }
                }
            } else {
                fallbackThumb
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var fallbackThumb: some View {
        Color(UIColor.tertiarySystemBackground)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
            }
    }

    // MARK: - Text content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Source badge + time + category
            HStack(spacing: 4) {
                sourceBadge
                Text("· \(item.publishedAt.relativeFormatted) · \(item.category.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Headline
            Text(item.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Source badge

    private var sourceBadge: some View {
        Text(item.source.displayName.uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(sourceColor)
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }

    private var sourceColor: Color {
        switch item.source {
        case .mbl:   return Color(red: 0.85, green: 0.15, blue: 0.15)
        case .vb:    return Color(red: 0.10, green: 0.45, blue: 0.80)
        case .visir: return Color(red: 0.15, green: 0.60, blue: 0.35)
        }
    }
}

// MARK: - Date formatting

extension Date {
    var relativeFormatted: String {
        let seconds = -timeIntervalSinceNow
        switch seconds {
        case ..<60:    return "Rétt í þessu"
        case ..<3600:  return "\(Int(seconds / 60)) mín"
        case ..<86400: return "\(Int(seconds / 3600)) klst"
        default:
            let f = DateFormatter()
            f.locale = Locale(identifier: "is_IS")
            f.dateStyle = .short
            f.timeStyle = .none
            return f.string(from: self)
        }
    }
}
