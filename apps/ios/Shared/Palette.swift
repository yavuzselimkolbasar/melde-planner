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

    var localizedName: String {
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

/// Meldo brand colors (ADR-0005).
nonisolated extension Color {
    static let meldoIndigo = Color(red: 0x3B / 255, green: 0x3F / 255, blue: 0xD8 / 255)
    static let meldoIndigoLight = Color(red: 0x8D / 255, green: 0x90 / 255, blue: 0xFF / 255)
    static let meldoOrange = Color(red: 0xFF / 255, green: 0x9A / 255, blue: 0x4D / 255)
    static let meldoYellow = Color(red: 0xFF / 255, green: 0xD4 / 255, blue: 0x47 / 255)
    static let meldoInk = Color(red: 0x14 / 255, green: 0x15 / 255, blue: 0x2A / 255)
}
