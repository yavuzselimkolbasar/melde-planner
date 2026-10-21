import MeldeCore
import SwiftUI
import WebKit

/// The school's own WebUntis login page inside Meldo, for schools that sign in
/// through Microsoft 365, IServ or another login (SSO). The student logs in on
/// those pages; Meldo only reads the resulting WebUntis session cookie and asks
/// WebUntis who is logged in. Passwords typed here never reach Meldo.
struct UntisWebLoginView: View {
    let school: FfiUntisSchool
    /// Called once WebUntis confirms the login: the `Cookie` header and the session id.
    var onLoggedIn: (_ cookies: String, _ sessionID: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var loading = true

    var body: some View {
        NavigationStack {
            UntisWebView(school: school, loading: $loading, onLoggedIn: onLoggedIn)
                .ignoresSafeArea(edges: .bottom)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Label(L("Melde dich so an, wie du es von WebUntis kennst, z. B. mit Microsoft 365. Meldo erkennt die Anmeldung automatisch."), systemImage: "person.badge.key")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
                    if loading {
                        ToolbarItem(placement: .confirmationAction) { ProgressView() }
                    }
                }
        }
    }
}

private struct UntisWebView: UIViewRepresentable {
    let school: FfiUntisSchool
    @Binding var loading: Bool
    var onLoggedIn: (String, String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(school: school, loading: $loading, onLoggedIn: onLoggedIn)
    }

    func makeUIView(context: Context) -> WKWebView {
        // The default data store keeps the Microsoft sign-in, so logging in again
        // after the WebUntis session ran out is usually one tap.
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        context.coordinator.webView = view
        var components = URLComponents()
        components.scheme = "https"
        components.host = school.server
        components.path = "/WebUntis/"
        components.queryItems = [URLQueryItem(name: "school", value: school.loginName)]
        if let url = components.url { view.load(URLRequest(url: url)) }
        context.coordinator.startWatching()
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}

    static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) {
        coordinator.stopWatching()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let school: FfiUntisSchool
        var loading: Binding<Bool>
        let onLoggedIn: (String, String) -> Void
        weak var webView: WKWebView?
        private var watcher: Task<Void, Never>?
        private var lastChecked: String?
        private var checks = 0
        private var done = false

        init(school: FfiUntisSchool, loading: Binding<Bool>, onLoggedIn: @escaping (String, String) -> Void) {
            self.school = school
            self.loading = loading
            self.onLoggedIn = onLoggedIn
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            loading.wrappedValue = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loading.wrappedValue = false
            Task { await check() }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            loading.wrappedValue = false
        }

        /// WebUntis is a single-page app, so a login doesn't always load a new
        /// page. Check the session every two seconds as well.
        func startWatching() {
            watcher = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2))
                    await self?.check()
                }
            }
        }

        func stopWatching() {
            watcher?.cancel()
        }

        /// Asks WebUntis who is logged in whenever the session cookie changes.
        private func check() async {
            guard !done, let store = webView?.configuration.websiteDataStore.httpCookieStore else { return }
            let cookies = await store.allCookies().filter { cookie in
                let domain = cookie.domain.hasPrefix(".") ? String(cookie.domain.dropFirst()) : cookie.domain
                return school.server == domain || school.server.hasSuffix("." + domain)
            }
            guard let session = cookies.first(where: { $0.name == "JSESSIONID" }) else { return }
            let header = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            // An unchanged session is re-checked every third time; a login often keeps the id.
            checks += 1
            if header == lastChecked, checks % 3 != 0 { return }
            lastChecked = header
            let client = UntisClient(browserCookies: header)
            guard (try? await client.browserAuth(server: school.server, sessionID: session.value)) != nil, !done else { return }
            done = true
            stopWatching()
            onLoggedIn(header, session.value)
        }
    }
}
