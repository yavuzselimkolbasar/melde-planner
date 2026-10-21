import MeldeCore
import SwiftUI

/// Connect WebUntis: find the school, sign in, import. Afterwards: status,
/// refresh and disconnect.
struct UntisConnectView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let link = model.untisLink {
            UntisStatusView(link: link)
        } else {
            UntisSchoolSearchView()
        }
    }
}

private struct UntisSchoolSearchView: View {
    @State private var query = ""
    @State private var schools: [FfiUntisSchool] = []
    @State private var searching = false
    @State private var problem: String?

    var body: some View {
        List {
            Section {
                Text(L("Meldo übernimmt deinen Stundenplan, Ausfälle und Vertretungen aus WebUntis. Dein Login bleibt auf diesem iPhone und geht nur an den WebUntis-Server deiner Schule."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if query.trimmingCharacters(in: .whitespaces).count < 3 {
                Label(L("Gib oben den Namen oder Ort deiner Schule ein."), systemImage: "magnifyingglass")
                    .foregroundStyle(.secondary)
            }
            if searching {
                ProgressView()
            }
            if let problem {
                Label(problem, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            }
            ForEach(schools, id: \.loginName) { school in
                NavigationLink {
                    UntisLoginView(school: school)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(school.displayName).font(.body.weight(.semibold))
                        if !school.address.isEmpty {
                            Text(school.address).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(L("WebUntis"))
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: L("Schule oder Ort suchen"))
        .task(id: query) { await search() }
    }

    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 3 else {
            schools = []
            problem = nil
            return
        }
        // Debounce typing.
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        searching = true
        defer { searching = false }
        do {
            schools = try await UntisClient().searchSchools(trimmed)
            problem = schools.isEmpty ? L("Keine Schule gefunden. Versuche den Ort oder einen Teil des Namens.") : nil
        } catch {
            problem = UntisMessages.text(for: error)
        }
    }
}

private struct UntisLoginView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let school: FfiUntisSchool

    @State private var user = ""
    @State private var password = ""
    @State private var working = false
    @State private var problem: String?
    @State private var summary: AppModel.UntisImportSummary?

    var body: some View {
        Form {
            Section {
                LabeledContent(L("Schule"), value: school.displayName)
                TextField(L("Benutzername"), text: $user)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField(L("Passwort"), text: $password)
                    .textContentType(.password)
            } footer: {
                Text(L("Dein WebUntis-Login der Schule. Er wird nur im Schlüsselbund dieses iPhones gespeichert. Schulen mit eigener Anmeldeseite (SSO) werden noch nicht unterstützt."))
            }
            if let problem {
                Label(problem, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red)
            }
            if let summary {
                Section(L("Importiert")) {
                    LabeledContent(L("Neue Fächer"), value: "\(summary.newSubjects)")
                    LabeledContent(L("Stunden pro Woche"), value: "\(summary.lessons)")
                    LabeledContent(L("Ausfälle und Vertretungen"), value: "\(summary.changes)")
                }
            }
            Section {
                Button {
                    Task { await connect() }
                } label: {
                    HStack {
                        Text(summary == nil ? L("Verbinden und importieren") : L("Fertig"))
                        if working { Spacer(); ProgressView() }
                    }
                }
                .disabled(working || (summary == nil && (user.isEmpty || password.isEmpty)))
            }
        }
        .navigationTitle(L("Anmelden"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func connect() async {
        if summary != nil {
            dismiss()
            return
        }
        working = true
        problem = nil
        defer { working = false }
        do {
            summary = try await model.connectUntis(school: school, user: user, password: password)
            password = ""
        } catch {
            problem = UntisMessages.text(for: error)
        }
    }
}

private struct UntisStatusView: View {
    @Environment(AppModel.self) private var model
    let link: UntisLink
    @State private var working = false
    @State private var message: String?
    @State private var confirmingDisconnect = false

    var body: some View {
        List {
            Section {
                LabeledContent(L("Schule"), value: link.schoolName)
                LabeledContent(L("Benutzer"), value: link.user)
                if let last = link.lastSync {
                    LabeledContent(L("Zuletzt aktualisiert")) {
                        Text(last, style: .relative)
                    }
                }
            } footer: {
                Text(L("Meldo aktualisiert Ausfälle und Vertretungen automatisch, wenn du die App öffnest (höchstens alle drei Stunden)."))
            }
            if let message {
                Text(message).foregroundStyle(.secondary)
            }
            Section {
                Button {
                    Task {
                        working = true
                        defer { working = false }
                        do {
                            if let s = try await model.refreshUntis() {
                                message = L("Aktualisiert: \(s.lessons) Stunden, \(s.changes) Änderungen.")
                            } else {
                                message = L("Bitte melde dich erneut an.")
                            }
                        } catch {
                            message = UntisMessages.text(for: error)
                        }
                    }
                } label: {
                    HStack {
                        Text(L("Jetzt aktualisieren"))
                        if working { Spacer(); ProgressView() }
                    }
                }
                .disabled(working)
                Button(L("WebUntis trennen"), role: .destructive) { confirmingDisconnect = true }
            }
        }
        .navigationTitle(L("WebUntis"))
        .confirmationDialog(L("WebUntis trennen?"), isPresented: $confirmingDisconnect) {
            Button(L("Trennen"), role: .destructive) { model.disconnectUntis() }
        } message: {
            Text(L("Dein Stundenplan bleibt erhalten, wird aber nicht mehr aktualisiert. Das Passwort wird gelöscht."))
        }
    }
}

enum UntisMessages {
    static func text(for error: any Error) -> String {
        switch error as? UntisClient.Failure {
        case .wrongCredentials: L("Benutzername oder Passwort ist falsch.")
        case .network: L("Keine Verbindung zu WebUntis. Prüfe dein Internet.")
        case .server(let code, _): L("WebUntis hat die Anfrage abgelehnt (Code \(code)).")
        case .noAccess, .none: L("Deine Schule erlaubt diesen Zugriff gerade nicht, oder WebUntis wird gewartet.")
        }
    }
}
