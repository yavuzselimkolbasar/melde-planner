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
        case noAccess(String)
        case server(code: Int64, message: String)
        case network
    }

    private static let searchURL = URL(string: "https://mobile.webuntis.com/ms/schoolquery2")!
    /// Own cookie store per client, so the Untis session never mixes with anything else.
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.httpCookieStorage = HTTPCookieStorage()
        config.httpShouldSetCookies = true
        config.timeoutIntervalForRequest = 20
        session = URLSession(configuration: config)
    }

    func searchSchools(_ query: String) async throws(Failure) -> [FfiUntisSchool] {
        let body = try await post(Self.searchURL, body: untisSchoolSearchRequest(query: query))
        return try map { try untisParseSchoolSearch(body: body) }
    }

    func login(server: String, loginName: String, user: String, password: String) async throws(Failure) -> FfiUntisAuth {
        let body = try await post(endpoint(server, loginName), body: untisAuthenticateRequest(user: user, password: password))
        return try map { try untisParseAuth(body: body) }
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
        do {
            let (data, _) = try await session.data(for: request)
            return String(decoding: data, as: UTF8.self)
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
