import Foundation
import MeldeCore

/// Talks to WebUntis (ADR-0007). Only two hosts are ever contacted: Untis'
/// school search and the student's own school server. Request bodies and
/// response parsing come from the Rust core (melde-untis).
///
/// A nonisolated struct: with approachable concurrency its async methods run
/// on the caller's actor, so the generated FFI records never cross actors.
nonisolated struct UntisClient: Sendable {
    enum Failure: Error, Equatable {
        case wrongCredentials
        /// The school search matched too many schools; WebUntis then returns none.
        case tooManyResults
        case noAccess(String)
        case server(code: Int64, message: String)
        case network
        /// A browser (SSO) session that has expired or was never logged in.
        case sessionExpired
        /// No lessons in the next eight weeks (holidays or an empty timetable).
        case noLessons
    }

    private static let searchURL = URL(string: "https://mobile.webuntis.com/ms/schoolquery2")!
    /// Own cookie store per client, so the Untis session never mixes with anything else.
    private let session: URLSession
    /// `Cookie` header of a session that was logged in in the browser (school SSO).
    private let browserCookies: String?

    init(browserCookies: String? = nil) {
        self.browserCookies = browserCookies
        let config = URLSessionConfiguration.ephemeral
        config.httpCookieStorage = HTTPCookieStorage()
        config.httpShouldSetCookies = true
        config.timeoutIntervalForRequest = 20
        session = URLSession(configuration: config)
    }

    func searchSchools(_ query: String) async throws(Failure) -> [FfiUntisSchool] {
        let body = try await post(Self.searchURL, body: untisSchoolSearchRequest(query: query))
        do {
            return try map { try untisParseSchoolSearch(body: body) }
        } catch .server(code: -6003, _) {
            throw .tooManyResults
        }
    }

    func login(server: String, loginName: String, user: String, password: String) async throws(Failure) -> FfiUntisAuth {
        let body = try await post(endpoint(server, loginName), body: untisAuthenticateRequest(user: user, password: password))
        return try map { try untisParseAuth(body: body) }
    }

    /// Who is logged in, for a session that started in the browser (Microsoft 365 or
    /// another school login) instead of `authenticate`.
    func browserAuth(server: String, sessionID: String) async throws(Failure) -> FfiUntisAuth {
        let probe = await probeBrowserLogin(server: server, sessionID: sessionID)
        guard let auth = probe.auth else { throw .sessionExpired }
        return auth
    }

    /// Asks `/api/app/config`, then the newer `/api/rest/view/v1/app/data`.
    /// `detail` says what WebUntis answered, for the login screen when it fails.
    func probeBrowserLogin(server: String, sessionID: String) async -> (auth: FfiUntisAuth?, detail: String) {
        var notes: [String] = []
        func url(_ path: String) -> URL? {
            var components = URLComponents()
            components.scheme = "https"
            components.host = server
            components.path = path
            return components.url
        }
        // The newer REST API wants the session's JWT as well.
        var token: String?
        if let tokenURL = url("/WebUntis/api/token/new"),
           let (status, body) = try? await sendWithStatus(URLRequest(url: tokenURL)),
           status == 200, !body.isEmpty, !body.hasPrefix("<") {
            token = body.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        for path in ["/WebUntis/api/app/config", "/WebUntis/api/rest/view/v1/app/data"] {
            guard let url = url(path) else { continue }
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            if let token, path.contains("/rest/") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            guard let (status, body) = try? await sendWithStatus(request) else {
                notes.append("\(path): keine Verbindung")
                continue
            }
            let auth = path.hasSuffix("config")
                ? try? untisParseAppConfig(body: body, sessionId: sessionID)
                : try? untisParseAppData(body: body, sessionId: sessionID)
            if let auth { return (auth, "") }
            let start = body.prefix(80).replacingOccurrences(of: "\n", with: " ")
            notes.append("\(path): HTTP \(status) \(start)")
        }
        return (nil, ([server] + notes).joined(separator: "\n"))
    }

    /// Raw `getTimetable` JSON for `first...last`, parsed later by Rust.
    func timetable(server: String, loginName: String, auth: FfiUntisAuth, first: FfiDate, last: FfiDate) async throws(Failure) -> String {
        let request = try map { try untisTimetableRequest(personId: auth.personId, personType: auth.personType, first: first, last: last) }
        return try await post(endpoint(server, loginName), body: request)
    }

    func logout(server: String, loginName: String) async {
        _ = try? await post(endpoint(server, loginName), body: untisLogoutRequest())
    }

    private func endpoint(_ server: String, _ loginName: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = server
        components.path = "/WebUntis/jsonrpc.do"
        components.queryItems = [URLQueryItem(name: "school", value: loginName)]
        return components.url ?? Self.searchURL
    }

    private func post(_ url: URL, body: String) async throws(Failure) -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(body.utf8)
        return try await send(request)
    }

    private func send(_ request: URLRequest) async throws(Failure) -> String {
        try await sendWithStatus(request).body
    }

    private func sendWithStatus(_ request: URLRequest) async throws(Failure) -> (status: Int, body: String) {
        var request = request
        if let browserCookies { request.setValue(browserCookies, forHTTPHeaderField: "Cookie") }
        do {
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            return (status, String(decoding: data, as: UTF8.self))
        } catch {
            throw .network
        }
    }

    private func map<T>(_ work: () throws -> T) throws(Failure) -> T {
        do {
            return try work()
        } catch let MeldeError.UntisServer(code, message) {
            throw code == -8504 ? .wrongCredentials : .server(code: code, message: message)
        } catch let MeldeError.UntisMalformed(message) {
            throw .noAccess(message)
        } catch {
            throw .noAccess("\(error)")
        }
    }
}
