import SwiftUI

/// App themes. Light/Dark/System control appearance; the colored themes keep
/// the system appearance and change the accent (tint) plus a faint backdrop wash.
/// Glass controls pick up the tint automatically, so Liquid Glass stays native.
nonisolated enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system, light, dark, purple, blue, green, orange

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        default: nil
        }
    }

    var tint: Color {
        switch self {
        case .system, .light, .dark: .accentColor
        case .purple: .purple
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        }
    }

    /// Very low-opacity wash behind content; nil for neutral themes.
    var wash: Color? {
        switch self {
        case .purple, .blue, .green, .orange: tint
        default: nil
        }
    }

    @MainActor var localizedName: String {
        switch self {
        case .system: L("System")
        case .light: L("Hell")
        case .dark: L("Dunkel")
        case .purple: L("Lila")
        case .blue: L("Blau")
        case .green: L("Grün")
        case .orange: L("Orange")
        }
    }
}

/// Subject palette backed by system colors, which already adapt to dark mode
/// and Increase Contrast.
nonisolated enum SubjectColor: String, Codable, CaseIterable, Identifiable {
    case blue, indigo, purple, pink, red, orange, yellow, green, mint, teal, cyan, brown, gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: .blue
        case .indigo: .indigo
        case .purple: .purple
        case .pink: .pink
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .mint: .mint
        case .teal: .teal
        case .cyan: .cyan
        case .brown: .brown
        case .gray: .gray
        }
    }
}

/// Spacing and shape tokens. One scale for the whole app keeps rhythm consistent.
enum DS {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let cardRadius: CGFloat = 24
    static let rowRadius: CGFloat = 16

    /// Curated SF Symbols for subjects.
    static let subjectSymbols = [
        "book.closed", "function", "x.squareroot", "globe.europe.africa", "atom",
        "flask", "leaf", "pawprint", "paintpalette", "music.note", "figure.run",
        "theatermasks", "building.columns", "text.book.closed", "character.book.closed",
        "laptopcomputer", "chart.line.uptrend.xyaxis", "scalemass", "cross.case", "hands.and.sparkles",
    ]
}

/// Grouped background with the theme's wash. Content stays on opaque cards for readability;
/// glass is reserved for navigation and controls.
struct ThemedBackground: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            if let wash = model.preferences.theme.wash {
                LinearGradient(
                    colors: [wash.opacity(0.10), .clear],
                    startPoint: .top, endPoint: .center
                )
            }
        }
        .ignoresSafeArea()
    }
}
