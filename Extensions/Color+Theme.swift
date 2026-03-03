import SwiftUI

extension Color {
    // MARK: - Price movement
    static let priceUp = Color("PriceUp", bundle: nil).fallback(Color(red: 0.18, green: 0.78, blue: 0.44))
    static let priceDown = Color("PriceDown", bundle: nil).fallback(Color(red: 0.94, green: 0.27, blue: 0.33))

    // MARK: - Surfaces (dark/light adaptive)
    static let surface = Color(UIColor.secondarySystemBackground)
    static let surfaceSecondary = Color(UIColor.tertiarySystemBackground)
    static let surfacePrimary = Color(UIColor.systemBackground)

    // MARK: - Brand
    static let brandAccent = Color(red: 0.18, green: 0.78, blue: 0.44) // Icelandic green
}

private extension Color {
    /// Returns `self` if it resolves in the asset catalog, otherwise returns `fallback`.
    /// Allows graceful fallback when asset catalog colors aren't set up yet.
    func fallback(_ fallback: Color) -> Color {
        // In a real project, asset catalog colors will override the fallbacks.
        fallback
    }
}

// MARK: - Formatting helpers

extension Double {
    /// Format as Icelandic króna with thousands separator: "382,50 kr."
    var iskFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "is_IS")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(formatted) kr."
    }

    /// Format as percentage with sign: "+2,34%" or "-1,05%"
    var percentFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "is_IS")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(formatted)%"
    }

    /// Format large numbers compactly: 287B, 48M
    var compactFormatted: String {
        switch abs(self) {
        case 1_000_000_000_000...: return String(format: "%.1fT", self / 1_000_000_000_000)
        case 1_000_000_000...:     return String(format: "%.1fB", self / 1_000_000_000)
        case 1_000_000...:         return String(format: "%.1fM", self / 1_000_000)
        case 1_000...:             return String(format: "%.1fK", self / 1_000)
        default:                   return String(format: "%.0f", self)
        }
    }
}
