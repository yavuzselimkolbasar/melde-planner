import MeldeCore
import SwiftUI
import WebKit

/// The school's own WebUntis login page inside Meldo, for schools that sign in
/// through Microsoft 365, IServ or another login (SSO). The student logs in on
/// those pages; Meldo only reads the resulting WebUntis session cookie and asks
/// WebUntis who is logged in. Passwords typed here never reach Meldo.
struct UntisWebLoginView: View {
    let school: FfiUntisSchool
    /// Called once WebUntis confirms the login: the WebUntis host the session
    /// belongs to, the `Cookie` header and the session id.
    var onLoggedIn: (_ server: String, _ cookies: String, _ sessionID: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var watcher = UntisLoginWatcher()

    var body: some View {
        NavigationStack {
            UntisWebView(school: school, watcher: watcher)
                .ignoresSafeArea(edges: .bottom)
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: DS.spacingXS) {
                        Label(watcher.status, systemImage: watcher.checking ? "hourglass" : "person.badge.key")
                            .font(.footnote.weight(.semibold))
                        if let detail = watcher.detail {
                            Text(detail)
                                .font(.caption2.monospaced())
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, DS.spacingS)
                    .background(.bar)
                }
                .navigationTitle(school.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(L("Abbrechen")) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(L("Ich bin angemeldet")) {
                            Task { await watcher.check(manual: true) }
                        }
                        .disabled(watcher.checking)
                    }
                }
        }
        .onAppear { watcher.onLoggedIn = onLoggedIn }
        .onDisappear { watcher.stop() }
    }
}

/// Watches the web view's cookies and asks WebUntis whether the student is
/// logged in. Checks every WebUntis host the page has visited, because after
/// a school login WebUntis may land on another server than the search said.
@Observable
final class UntisLoginWatcher {
    var status = L("Melde dich so an, wie du es von WebUntis kennst, z. B. mit Microsoft 365. Meldo erkennt die Anmeldung automatisch.")
    var detail: String?
    var checking = false

    @ObservationIgnored weak var webView: WKWebView?
    @ObservationIgnored var school: FfiUntisSchool?
    @ObservationIgnored var onLoggedIn: ((String, String, String) -> Void)?
    @ObservationIgnored private var hosts: [String] = []
    @ObservationIgnored private var lastChecked: [String: String] = [:]
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var done = false

    func start(school: FfiUntisSchool) {
        self.school = school
        remember(host: school.server)
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                await self?.check(manual: false)
            }
        }
    }

    func stop() {
        task?.cancel()
    }

    func remember(host: String?) {
        guard let host, host.contains("webuntis"), !hosts.contains(host) else { return }
        hosts.append(host)
    }

    /// `manual`: the student says they are logged in; check every host now and
    /// show what WebUntis answered if it still fails.
    func check(manual: Bool) async {
        guard !done, !checking, let store = webView?.configuration.websiteDataStore.httpCookieStore else { return }
        remember(host: webView?.url?.host)
        let all = await store.allCookies()
        if manual {
            checking = true
            status = L("Prüfe die Anmeldung …")
        }
        defer { if manual { checking = false } }
        var report: [String] = []
        for host in hosts {
            let cookies = all.filter { cookie in
                let domain = cookie.domain.hasPrefix(".") ? String(cookie.domain.dropFirst()) : cookie.domain
                return host == domain || host.hasSuffix("." + domain)
            }
            guard let session = cookies.first(where: { $0.name == "JSESSIONID" }) else {
                report.append("\(host): " + L("noch keine Sitzung"))
                continue
            }
            let header = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            // Automatic checks only ask WebUntis again when the cookies changed.
            if !manual, lastChecked[host] == header { continue }
            lastChecked[host] = header
            let probe = await UntisClient(browserCookies: header).probeBrowserLogin(server: host, sessionID: session.value)
            if probe.auth != nil, !done {
                done = true
                stop()
                status = L("Angemeldet. Stundenplan wird geladen …")
                onLoggedIn?(host, header, session.value)
                return
            }
            report.append(probe.detail)
        }
        if manual {
            status = L("Meldo erkennt die Anmeldung noch nicht. Das hat WebUntis geantwortet:")
            detail = report.joined(separator: "\n")
        }
    }
}

private struct UntisWebView: UIViewRepresentable {
    let school: FfiUntisSchool
    let watcher: UntisLoginWatcher

    func makeCoordinator() -> Coordinator { Coordinator(watcher: watcher) }

    func makeUIView(context: Context) -> WKWebView {
        // The default data store keeps the Microsoft sign-in, so logging in again
        // after the WebUntis session ran out is usually one tap.
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        watcher.webView = view
        var components = URLComponents()
        components.scheme = "https"
        components.host = school.server
        components.path = "/WebUntis/"
        components.queryItems = [URLQueryItem(name: "school", value: school.loginName)]
        if let url = components.url { view.load(URLRequest(url: url)) }
        watcher.start(school: school)
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}

    static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) {
        coordinator.watcher.stop()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let watcher: UntisLoginWatcher

        init(watcher: UntisLoginWatcher) {
            self.watcher = watcher
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            watcher.remember(host: webView.url?.host)
            Task { await watcher.check(manual: false) }
        }
    }
}
