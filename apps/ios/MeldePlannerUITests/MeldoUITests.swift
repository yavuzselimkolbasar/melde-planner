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

    private func launch(seed: Bool, language: String = "de", theme: String = "system", dark: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest", "-uitest-now", mondayInLesson, "-uitest-language", language, "-uitest-theme", theme]
        if seed { app.launchArguments.append("-uitest-seed") }
        if dark { app.launchArguments += ["-AppleInterfaceStyle", "Dark"] }
        app.launch()
        XCUIDevice.shared.orientation = UIDevice.current.userInterfaceIdiom == .pad ? .landscapeLeft : .portrait
        return app
    }

    private func shot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
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

    private func back(_ app: XCUIApplication) {
        let button = app.navigationBars.buttons.element(boundBy: 0)
        if button.exists { button.tap() }
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
        shot(app, "06-after-melden")
        XCTAssertTrue(app.buttons["Rückgängig"].waitForExistence(timeout: 3), "undo should appear after Melden")
        tab(app, "Start")
        shot(app, "07-start-with-meldung")
    }

    /// Every tab and screen with realistic data.
    func test02_everyScreenWithSampleData() {
        let app = launch(seed: true)
        shot(app, "10-start")
        app.swipeUp()
        shot(app, "11-start-scrolled")

        tab(app, "Stundenplan")
        shot(app, "12-timetable")
        _ = app.buttons["Stunde hinzufügen"].firstMatch.waitForExistence(timeout: 2)
        let firstLesson = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Mathematik'")).firstMatch
        if firstLesson.waitForExistence(timeout: 3) {
            firstLesson.press(forDuration: 1.2)
            shot(app, "13-lesson-context-menu")
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

        tab(app, "Prüfungen")
        shot(app, "18-exams-empty")

        if device == "ipad" {
            tab(app, "Kalender")
            shot(app, "19-calendar")
            tab(app, "Statistik")
            shot(app, "20-statistics")
        }

        tab(app, "Mehr")
        shot(app, "21-more")
        if device == "iphone" {
            tap(app.buttons["Kalender"].firstMatch, "Kalender in Mehr")
            shot(app, "19-calendar")
            back(app)
            tap(app.buttons["Statistik"].firstMatch, "Statistik in Mehr")
            shot(app, "20-statistics")
            back(app)
        }
        for (label, name) in [("WebUntis", "22-webuntis"), ("Einstellungen", "23-settings"),
                              ("Status: Widgets, Mitteilungen", "24-status"), ("Fächer", "25-subjects"),
                              ("Über Meldo", "26-about")] {
            if tap(app.buttons[label].firstMatch, label) {
                shot(app, name)
                if name == "23-settings" {
                    app.swipeUp()
                    shot(app, "23b-settings-scrolled")
                }
                back(app)
            }
        }
    }

    func test03_meldenAndUndo() {
        let app = launch(seed: true)
        let melden = app.buttons["Meldung erfassen"].firstMatch
        tap(melden, "Melden")
        shot(app, "30-melden-recorded")
        tap(app.buttons["Rückgängig"], "Rückgängig")
        shot(app, "31-melden-undone")
    }

    func test04_darkMode() {
        let app = launch(seed: true, dark: true)
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
}
