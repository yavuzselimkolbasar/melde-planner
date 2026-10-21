import UIKit
import XCTest

/// Uses Meldo like a student would and saves a screenshot of every screen.
/// Runs on iPhone and iPad simulators; screenshots are exported from the test
/// results and reviewed by hand. Steps that cannot find their element record a
/// failure but the walk continues, so one problem doesn't hide the rest.
final class MeldoUITests: XCTestCase {
    /// Monday, 08:10: the first lesson (Mathematik 08:00–08:45) is running.
    private let mondayInLesson = "2026-10-19T08:10"

    private var device: String {
        UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
    }

    override func setUp() {
        continueAfterFailure = true
    }

    /// Monday, 13:00: school is over, so Melden asks for the subject.
    private let mondayAfterSchool = "2026-10-19T13:00"

    private func launch(seed: Bool, language: String = "de", theme: String = "system",
                        now: String? = nil, landscape: Bool = false) -> XCUIApplication {
        XCUIDevice.shared.orientation = landscape ? .landscapeLeft : .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-uitest", "-uitest-now", now ?? mondayInLesson, "-uitest-language", language, "-uitest-theme", theme]
        if seed { app.launchArguments.append("-uitest-seed") }
        app.launch()
        return app
    }

    /// Screenshot of the whole screen once animations have settled.
    /// `XCUIScreen` captures rotated screens correctly; `app.screenshot()` does not.
    private func shot(_ app: XCUIApplication, _ name: String) {
        RunLoop.current.run(until: Date().addingTimeInterval(0.8))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "\(device)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Taps a tab in the iPhone tab bar or the iPad sidebar / top bar.
    @discardableResult
    private func tab(_ app: XCUIApplication, _ name: String) -> Bool {
        let inBar = app.tabBars.buttons[name]
        if inBar.waitForExistence(timeout: 3) { inBar.tap(); return true }
        let anywhere = app.buttons[name].firstMatch
        if anywhere.waitForExistence(timeout: 3) { anywhere.tap(); return true }
        let cell = app.cells.staticTexts[name].firstMatch
        if cell.waitForExistence(timeout: 2) { cell.tap(); return true }
        XCTFail("tab \(name) not found")
        return false
    }

    @discardableResult
    private func tap(_ element: XCUIElement, _ what: String, timeout: TimeInterval = 4) -> Bool {
        guard element.waitForExistence(timeout: timeout) else {
            XCTFail("\(what) not found")
            return false
        }
        element.tap()
        return true
    }

    /// Goes back one level; the back button carries the previous screen's title.
    private func back(_ app: XCUIApplication, to title: String) {
        let named = app.navigationBars.buttons[title]
        if named.waitForExistence(timeout: 2) { named.tap(); return }
        let first = app.navigationBars.buttons.element(boundBy: 0)
        if first.exists { first.tap() } else { XCTFail("no back button to \(title)") }
    }

    /// Scrolling down minimizes the iPhone tab bar; scroll back so every tab is tappable.
    private func scrollToTop(_ app: XCUIApplication) {
        app.swipeDown()
        app.swipeDown()
    }

    // MARK: - Flows

    /// First launch: create a subject and a lesson by hand, then Melden.
    func test01_firstRunCreatesSubjectLessonAndMeldung() {
        let app = launch(seed: false)
        shot(app, "01-empty-start")
        tap(app.buttons["Erstes Fach anlegen"], "Erstes Fach anlegen")
        let name = app.textFields["Name, z. B. Mathematik"]
        if tap(name, "subject name field") { name.typeText("Mathematik") }
        shot(app, "02-subject-editor")
        tap(app.buttons["Sichern"], "Sichern (subject)")

        tab(app, "Stundenplan")
        shot(app, "03-timetable-empty")
        tap(app.buttons["Stunde hinzufügen"].firstMatch, "Stunde hinzufügen")
        shot(app, "04-lesson-editor")
        tap(app.buttons["Sichern"], "Sichern (lesson)")
        shot(app, "05-timetable-one-lesson")

        tap(app.buttons["Meldung erfassen"].firstMatch, "Melden button")
        // Undo is offered for four seconds only, so check it before the screenshot.
        XCTAssertTrue(app.buttons["Rückgängig"].waitForExistence(timeout: 3), "undo should appear after Melden")
        shot(app, "06-after-melden")
        tab(app, "Start")
        shot(app, "07-start-with-meldung")
    }

    /// Every tab and screen with realistic data.
    func test02_everyScreenWithSampleData() {
        let app = launch(seed: true)
        shot(app, "10-start")
        app.swipeUp()
        shot(app, "11-start-scrolled")
        scrollToTop(app)

        tab(app, "Stundenplan")
        shot(app, "12-timetable")
        _ = app.buttons["Stunde hinzufügen"].firstMatch.waitForExistence(timeout: 2)
        let firstLesson = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Mathematik'")).firstMatch
        if firstLesson.waitForExistence(timeout: 3) {
            firstLesson.tap()
            shot(app, "13-lesson-detail")
            if app.buttons["Hausaufgabe eintragen"].waitForExistence(timeout: 2) {
                app.buttons["Hausaufgabe eintragen"].tap()
                shot(app, "14-homework-from-lesson")
                tap(app.buttons["Abbrechen"], "Abbrechen")
            } else {
                app.tap()
            }
        }

        tab(app, "Aufgaben")
        shot(app, "15-tasks")
        let check = app.buttons["Als erledigt markieren"].firstMatch
        if tap(check, "task check circle") { shot(app, "16-task-checked") }
        tap(app.buttons["Aufgabe hinzufügen"].firstMatch, "Aufgabe hinzufügen")
        shot(app, "17-task-editor")
        tap(app.buttons["Abbrechen"], "Abbrechen (task)")

        tab(app, "Dokumente")
        shot(app, "18-exams-empty")

        if device == "ipad" {
            tab(app, "Kalender")
            shot(app, "19-calendar")
            tab(app, "Statistik")
            shot(app, "20-statistics")
        }

        if device == "ipad" {
            // iPad has no Mehr tab: every destination sits in the sidebar.
            for (label, name) in [("Abwesenheiten", "21-absences"), ("Ferien", "21b-holidays"), ("WebUntis", "22-webuntis"),
                                  ("Microsoft Teams", "22b-teams"), ("Einstellungen", "23-settings"), ("Fächer", "25-subjects"),
                                  ("Über Meldo", "26-about")] {
                if tab(app, label) { shot(app, name) }
            }
            return
        }
        tab(app, "Mehr")
        shot(app, "21-more")
        if device == "iphone" {
            tap(app.buttons["Kalender"].firstMatch, "Kalender in Mehr")
            shot(app, "19-calendar")
            back(app, to: "Mehr")
            tap(app.buttons["Statistik"].firstMatch, "Statistik in Mehr")
            shot(app, "20-statistics")
            back(app, to: "Mehr")
        }
        for (label, name) in [("Abwesenheiten", "21-absences"), ("Microsoft Teams", "22b-teams"),
                              ("WebUntis", "22-webuntis"), ("Einstellungen", "23-settings"),
                              ("Status: Widgets, Mitteilungen", "24-status"), ("Fächer", "25-subjects"),
                              ("Über Meldo", "26-about")] {
            if tap(app.buttons[label].firstMatch, label) {
                shot(app, name)
                if name == "23-settings" {
                    app.swipeUp()
                    shot(app, "23b-settings-scrolled")
                    app.swipeUp()
                    shot(app, "23c-settings-bottom")
                }
                back(app, to: "Mehr")
            }
        }
    }

    func test03_meldenAndUndo() {
        let app = launch(seed: true)
        let melden = app.buttons["Meldung erfassen"].firstMatch
        tap(melden, "Melden")
        // Undo first: it disappears after four seconds, longer than a slow simulator's screenshot.
        tap(app.buttons["Rückgängig"], "Rückgängig")
        shot(app, "31-melden-undone")
    }

    func test04_darkMode() {
        let app = launch(seed: true, theme: "dark")
        shot(app, "40-dark-start")
        tab(app, "Stundenplan")
        shot(app, "41-dark-timetable")
        tab(app, "Aufgaben")
        shot(app, "42-dark-tasks")
    }

    func test05_turkishAndEnglish() {
        let tr = launch(seed: true, language: "tr")
        shot(tr, "50-tr-start")
        tr.terminate()
        let en = launch(seed: true, language: "en")
        shot(en, "51-en-start")
        tab(en, "Tasks")
        shot(en, "52-en-tasks")
    }

    func test06_coloredTheme() {
        let app = launch(seed: true, theme: "purple")
        shot(app, "60-purple-start")
    }

    /// Outside a lesson Melden asks which subject the Meldung belongs to.
    func test07_meldenAfterSchoolAsksForSubject() {
        let app = launch(seed: true, now: mondayAfterSchool)
        shot(app, "70-after-school-start")
        tap(app.buttons["Meldung erfassen"].firstMatch, "Melden")
        shot(app, "71-subject-picker")
        if tap(app.buttons.containing(NSPredicate(format: "label CONTAINS 'Biologie'")).firstMatch, "Biologie in picker") {
            shot(app, "72-after-picking-subject")
        }
    }

    /// Finds a real school through the public WebUntis school search and opens
    /// its login form. No credentials are entered.
    func test09_webUntisSchoolSearch() {
        let app = launch(seed: true)
        if device == "ipad" {
            tab(app, "WebUntis")
        } else {
            tab(app, "Mehr")
            tap(app.buttons["WebUntis"].firstMatch, "WebUntis")
        }
        shot(app, "90-webuntis-empty")
        // Too general: WebUntis refuses it (-6003) and Meldo must explain why.
        let field = app.textFields["untis-school-search"]
        if tap(field, "school search field") {
            field.typeText("Köln")
            _ = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH 'Zu viele Schulen'")).firstMatch.waitForExistence(timeout: 15)
            shot(app, "91a-webuntis-too-many")
            field.typeText("-Pesch")
            let school = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Pesch'")).firstMatch
            if school.waitForExistence(timeout: 15) {
                shot(app, "91-webuntis-results")
                school.tap()
                shot(app, "92-webuntis-login")
                // Opens the school's real WebUntis page; nothing is typed there.
                if tap(app.buttons["Mit Microsoft 365 oder Schul-Login anmelden"], "school login button") {
                    RunLoop.current.run(until: Date().addingTimeInterval(6))
                    shot(app, "93-webuntis-school-login-page")
                    tap(app.buttons["Abbrechen"], "Abbrechen (school login)")
                }
            } else {
                shot(app, "91-webuntis-no-results")
                XCTFail("no school found for Köln-Pesch")
            }
        }
    }

    /// The iPad is mostly used sideways; the iPhone checks landscape too.
    func test08_landscape() {
        let app = launch(seed: true, landscape: true)
        shot(app, "80-landscape-start")
        tab(app, "Stundenplan")
        shot(app, "81-landscape-timetable")
        tab(app, "Aufgaben")
        shot(app, "82-landscape-tasks")
        if device == "ipad" {
            tab(app, "Dokumente")
            shot(app, "83-landscape-exams")
            tab(app, "Statistik")
            shot(app, "84-landscape-statistics")
        }
        XCUIDevice.shared.orientation = .portrait
    }
}
