import CryptoKit
import Foundation
import Security

/// Microsoft Teams assignments through Microsoft Graph (ADR-0008).
///
/// Sign-in uses Microsoft's own page with OAuth 2.0 + PKCE: Meldo never sees
/// the school password, only tokens. Meldo is a public client, so there is no
/// secret; the app (client) ID comes from the school's or the developer's
/// Azure app registration and is not confidential.
nonisolated enum TeamsConfig {
    /// Application (client) ID from the Azure app registration. Empty until it
    /// is registered; Teams then shows how to set it up.
    static let clientID = ""
    static let redirectURI = "meldeplanner://auth"
    static let callbackScheme = "meldeplanner"
    static let scopes = "offline_access User.Read EduAssignments.ReadBasic EduRoster.ReadBasic"
    static var isConfigured: Bool { !clientID.isEmpty }
}

nonisolated struct TeamsClient: Sendable {
    nonisolated enum Failure: Error, Equatable {
        case notConfigured
        case cancelled
        /// Microsoft refused, e.g. the school's IT hasn't approved Meldo.
        case denied(String)
        case expired
        case network
    }

    nonisolated struct Tokens: Sendable {
        var access: String
        var refresh: String
    }

    nonisolated struct Assignment: Sendable {
        var id: String
        var title: String
        var className: String
        var due: Date?
        var instructions: String
        var webURL: String?
    }

    private static let authority = "https://login.microsoftonline.com/common/oauth2/v2.0"

    /// PKCE verifier and the sign-in URL to open in the web authentication session.
    static func authorization() -> (verifier: String, url: URL)? {
        var bytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { return nil }
        let verifier = base64URL(Data(bytes))
        let challenge = base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))
        var components = URLComponents(string: "\(authority)/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: TeamsConfig.clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: TeamsConfig.redirectURI),
            URLQueryItem(name: "scope", value: TeamsConfig.scopes),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "prompt", value: "select_account"),
        ]
        guard let url = components?.url else { return nil }
        return (verifier, url)
    }

    /// The `code` (or Microsoft's error) from the redirect back to Meldo.
    static func code(from callback: URL) throws(Failure) -> String {
        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        if let code = items.first(where: { $0.name == "code" })?.value { return code }
        let message = items.first { $0.name == "error_description" }?.value
            ?? items.first { $0.name == "error" }?.value ?? ""
        throw .denied(message)
    }

    func redeem(code: String, verifier: String) async throws(Failure) -> Tokens {
        try await token([
            "grant_type": "authorization_code", "code": code,
            "redirect_uri": TeamsConfig.redirectURI, "code_verifier": verifier,
        ])
    }

    func refresh(_ refreshToken: String) async throws(Failure) -> Tokens {
        try await token(["grant_type": "refresh_token", "refresh_token": refreshToken])
    }

    private func token(_ fields: [String: String]) async throws(Failure) -> Tokens {
        guard TeamsConfig.isConfigured, let url = URL(string: "\(Self.authority)/token") else { throw .notConfigured }
        var all = fields
        all["client_id"] = TeamsConfig.clientID
        all["scope"] = TeamsConfig.scopes
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var form = URLComponents()
        form.queryItems = all.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.httpBody = Data((form.percentEncodedQuery ?? "").utf8)
        let response: GraphToken = try await send(request)
        guard let access = response.access_token else {
            if response.error == "invalid_grant" { throw .expired }
            throw .denied(response.error_description ?? response.error ?? "")
        }
        return Tokens(access: access, refresh: response.refresh_token ?? fields["refresh_token"] ?? "")
    }

    /// The signed-in account's name, for the status screen.
    func accountName(access: String) async throws(Failure) -> String {
        let me: GraphMe = try await graph("me", access: access)
        return me.displayName ?? me.userPrincipalName ?? ""
    }

    /// Assignments of all the student's classes, with class names.
    func assignments(access: String) async throws(Failure) -> [Assignment] {
        let classes: GraphClasses = try await graph("education/me/classes", access: access)
        let names = Dictionary(classes.value.map { ($0.id, $0.displayName ?? "") }, uniquingKeysWith: { a, _ in a })
        let list: GraphAssignments = try await graph("education/me/assignments?$top=100", access: access)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoPlain = ISO8601DateFormatter()
        return list.value
            .filter { $0.status != "draft" }
            .map { item in
                let due = item.dueDateTime.flatMap { iso.date(from: $0) ?? isoPlain.date(from: $0) }
                return Assignment(
                    id: item.id,
                    title: item.displayName ?? "",
                    className: item.classId.flatMap { names[$0] } ?? "",
                    due: due,
                    instructions: Self.plainText(item.instructions?.content ?? ""),
                    webURL: item.webUrl
                )
            }
    }

    private func graph<T: Decodable>(_ path: String, access: String) async throws(Failure) -> T {
        guard let url = URL(string: "https://graph.microsoft.com/v1.0/\(path)") else { throw .network }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(access)", forHTTPHeaderField: "Authorization")
        return try await send(request)
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws(Failure) -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw .network
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 401 { throw .expired }
        if status == 403 { throw .denied(String(decoding: data.prefix(200), as: UTF8.self)) }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw .denied(String(decoding: data.prefix(200), as: UTF8.self))
        }
    }

    private static func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Assignment instructions arrive as HTML.
    static func plainText(_ html: String) -> String {
        var text = html
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "</p>", with: "\n")
        while let open = text.range(of: "<"), let close = text.range(of: ">", range: open.upperBound..<text.endIndex) {
            text.removeSubrange(open.lowerBound..<close.upperBound)
        }
        return text
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Microsoft Graph answers, decoded off the main actor.

private nonisolated struct GraphToken: Decodable {
    var access_token: String?
    var refresh_token: String?
    var error: String?
    var error_description: String?
}

private nonisolated struct GraphMe: Decodable {
    var displayName: String?
    var userPrincipalName: String?
}

private nonisolated struct GraphClasses: Decodable {
    nonisolated struct Class: Decodable {
        var id: String
        var displayName: String?
    }
    var value: [Class]
}

private nonisolated struct GraphAssignments: Decodable {
    nonisolated struct Body: Decodable {
        var content: String?
    }
    nonisolated struct Item: Decodable {
        var id: String
        var displayName: String?
        var classId: String?
        var dueDateTime: String?
        var status: String?
        var webUrl: String?
        var instructions: Body?
    }
    var value: [Item]
}
