import Foundation

/// Finds the App Group this build is actually signed with.
///
/// Sideloading tools that sign with a free Apple ID often rename App Groups
/// (e.g. append the team id), so the name in project.yml may not be the one
/// iOS grants. Resolution order:
/// 1. `ALTAppGroups` in Info.plist (AltStore rewrites it to the real names),
/// 2. the `com.apple.security.application-groups` entitlement embedded in this
///    binary's code signature (works for any signing tool),
/// 3. the name from project.yml.
/// The first candidate iOS actually gives a container for wins.
nonisolated enum AppGroup {
    static let configured = "group.app.meldeplanner.ios"

    /// The working group id, or `nil` when this build has no usable App Group.
    static let identifier: String? = candidates().first {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0) != nil
    }

    static var containerURL: URL? {
        identifier.flatMap { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0) }
    }

    /// For the diagnostics screen.
    static var allCandidates: [String] { candidates() }

    private static func candidates() -> [String] {
        var result: [String] = []
        if let alt = Bundle.main.object(forInfoDictionaryKey: "ALTAppGroups") as? [String] {
            result += alt
        }
        result += signedGroups()
        result.append(configured)
        var seen = Set<String>()
        return result.filter { seen.insert($0).inserted }
    }

    /// Reads the entitlements plist that every code signature embeds as plain XML.
    private static func signedGroups() -> [String] {
        guard let url = Bundle.main.executableURL,
              let binary = try? Data(contentsOf: url, options: .alwaysMapped) else { return [] }
        let start = Data("<?xml".utf8)
        let end = Data("</plist>".utf8)
        let key = Data("com.apple.security.application-groups".utf8)
        var searchFrom = binary.startIndex
        while let open = binary.range(of: start, in: searchFrom..<binary.endIndex),
              let close = binary.range(of: end, in: open.upperBound..<binary.endIndex) {
            let chunk = binary[open.lowerBound..<close.upperBound]
            if chunk.range(of: key) != nil,
               let plist = try? PropertyListSerialization.propertyList(from: Data(chunk), format: nil) as? [String: Any],
               let groups = plist["com.apple.security.application-groups"] as? [String] {
                return groups
            }
            searchFrom = close.upperBound
        }
        return []
    }
}
