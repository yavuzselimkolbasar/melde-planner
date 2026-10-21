import Foundation

/// Device-local persistence as one JSON document, written atomically and
/// protected by iOS data protection. Small by design: a school year of data
/// is well under a megabyte. Replaced in Phase 2 by the Rust-owned store.
nonisolated struct LocalStore {
    enum LoadError: Error {
        case unreadable(underlying: Error, backup: URL?)
        case newerSchema(Int)
    }

    let url: URL

    static func standard() throws -> LocalStore {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )
        let folder = base.appending(path: "MeldePlanner", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return LocalStore(url: folder.appending(path: "data.json"))
    }

    func load() throws(LoadError) -> AppData {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
            return AppData()
        }
        do {
            let data = try Data(contentsOf: url)
            var decoded = try Self.decoder.decode(AppData.self, from: data)
            if decoded.schemaVersion > AppData.currentSchemaVersion {
                throw LoadError.newerSchema(decoded.schemaVersion)
            }
            // Older files are migrated in memory; the next save writes the current version.
            decoded.schemaVersion = AppData.currentSchemaVersion
            return decoded
        } catch let error as LoadError {
            throw error
        } catch {
            // Keep the unreadable file instead of overwriting the student's data.
            throw LoadError.unreadable(underlying: error, backup: backupCorruptFile())
        }
    }

    func save(_ appData: AppData) throws {
        let data = try Self.encoder.encode(appData)
        try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    private func backupCorruptFile() -> URL? {
        let stamp = Int(Date().timeIntervalSince1970)
        let backup = url.deletingLastPathComponent().appending(path: "data-unreadable-\(stamp).json")
        return (try? FileManager.default.copyItem(at: url, to: backup)) != nil ? backup : nil
    }

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
