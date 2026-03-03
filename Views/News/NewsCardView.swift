import SwiftUI

struct NewsCardView: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                    case .failure, .empty:
                        fallbackThumbnail
                    @unknown default:
                        fallbackThumbnail
                    }
                }
            } else {
                fallbackThumbnail
            }

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                // Source + time row
                HStack(spacing: 6) {
                    sourceBadge
                    Text(item.publishedAt.relativeFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(item.category.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Title
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                // Summary
                if !item.summary.isEmpty {
                    Text(item.summary)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(12)
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    private var fallbackThumbnail: some View {
        Rectangle()
            .fill(Color.surfaceSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
            }
    }

    private var sourceBadge: some View {
        Text(item.source.displayName)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(sourceColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
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

private extension Date {
    var relativeFormatted: String {
        let seconds = -timeIntervalSinceNow
        switch seconds {
        case ..<60:        return "Rétt í þessu"
        case ..<3600:      return "\(Int(seconds / 60)) mín"
        case ..<86400:     return "\(Int(seconds / 3600)) klst"
        default:
            let f = DateFormatter()
            f.locale = Locale(identifier: "is_IS")
            f.dateStyle = .short
            f.timeStyle = .none
            return f.string(from: self)
        }
    }
}
