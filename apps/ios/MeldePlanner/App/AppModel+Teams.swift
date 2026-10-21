import Foundation

/// Microsoft Teams assignments become homework in Aufgaben (ADR-0008).
extension AppModel {
    private static let teamsKeychainAccount = "microsoft-teams"

    var teamsLink: TeamsLink? { data.teams }

    /// Finishes sign-in with the code from Microsoft's redirect, then imports.
    @discardableResult
    func connectTeams(code: String, verifier: String) async throws(TeamsClient.Failure) -> Int {
        let client = TeamsClient()
        let tokens = try await client.redeem(code: code, verifier: verifier)
        let account = (try? await client.accountName(access: tokens.access)) ?? ""
        _ = Keychain.save(tokens.refresh, account: Self.teamsKeychainAccount)
        mutate { $0.teams = TeamsLink(account: account) }
        return try await importTeams(client: client, access: tokens.access)
    }

    /// Re-imports with the stored refresh token. Returns the number of new assignments.
    @discardableResult
    func refreshTeams() async throws(TeamsClient.Failure) -> Int {
        guard data.teams != nil, let refresh = Keychain.read(account: Self.teamsKeychainAccount) else { return 0 }
        let client = TeamsClient()
        let tokens = try await client.refresh(refresh)
        if !tokens.refresh.isEmpty { _ = Keychain.save(tokens.refresh, account: Self.teamsKeychainAccount) }
        return try await importTeams(client: client, access: tokens.access)
    }

    /// At most every three hours, when the app comes to the foreground.
    func refreshTeamsIfStale() async {
        guard TeamsConfig.isConfigured, let link = data.teams else { return }
        if let last = link.lastSync, currentDate.timeIntervalSince(last) < 3 * 3600 { return }
        _ = try? await refreshTeams()
    }

    func disconnectTeams() {
        Keychain.delete(account: Self.teamsKeychainAccount)
        mutate { $0.teams = nil }
    }

    /// Adds assignments Meldo hasn't seen; tasks already imported stay as the
    /// student left them (done, edited, deleted ones aren't brought back).
    private func importTeams(client: TeamsClient, access: String) async throws(TeamsClient.Failure) -> Int {
        let assignments = try await client.assignments(access: access)
        let calendar = calendar
        let now = currentDate
        var added = 0
        mutate { data in
            var seen = Set(data.tasks.compactMap(\.teamsID))
            for a in assignments where !seen.contains(a.id) && !a.title.isEmpty {
                let subject = data.subjects.first { subject in
                    !a.className.isEmpty && (a.className.localizedCaseInsensitiveContains(subject.name)
                        || (subject.untisKey.map { a.className.localizedCaseInsensitiveContains($0) } ?? false))
                }
                var notes = a.className
                if !a.instructions.isEmpty { notes += notes.isEmpty ? a.instructions : "\n\n\(a.instructions)" }
                data.tasks.append(SchoolTask(
                    title: a.title, notes: notes, kind: .homework, subjectID: subject?.id,
                    dueDate: a.due.map { calendar.startOfDay(for: $0) }, teamsID: a.id
                ))
                seen.insert(a.id)
                added += 1
            }
            data.teams?.lastSync = now
        }
        return added
    }
}
