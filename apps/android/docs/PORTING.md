# Porting the iOS app to Android (Meldo for Android)

Goal: a 1:1 port of `apps/ios` (SwiftUI, iOS 26) to `apps/android` (Kotlin, Jetpack
Compose, Material 3 / Material You, Android 16–17: minSdk 36, targetSdk 37). Every
feature, screen, card, text and rule behaves the same. Only the visual language changes:
Liquid Glass → Material 3 (tonal surfaces, Material You dynamic color as an option).

## Rules (from the project CLAUDE.md, they apply here too)
- **No mock data, no placeholders, no TODO stubs** in finished code. Port real behavior.
- **Strings**: every user-facing string goes through `L("German key", args…)`
  (`app.meldeplanner.android.core.L`). Keys are the exact keys of the iOS String Catalog
  `apps/ios/MeldePlanner/Resources/Localizable.xcstrings`. Swift interpolation becomes a
  format key: `L("\(n) Meldungen diese Woche")` → `L("%lld Meldungen diese Woche", n)`,
  strings → `%@`. Look the key up in the catalog to get it exactly right
  (`python -I -c "import json;print([k for k in json.load(open('apps/ios/MeldePlanner/Resources/Localizable.xcstrings',encoding='utf-8'))['strings'] if 'Meldung' in k])"`).
  A string that exists only on Android goes into **your own** file
  `apps/android/strings/<feature>.json` as `{ "German key": { "de": …, "tr": …, "en": … } }`
  with real German, Turkish and English text.
- Participation counts are not grades. Grade comparisons go through the scale (1–6 lower
  is better, 0–15 higher is better). Never hard-code grading rules.
- No secrets in code. No new dependency without asking the lead (reply in your report);
  the available ones are in `gradle/libs.versions.toml` / `app/build.gradle.kts`.
- graphify: when `graphify-out/graph.json` exists, run `graphify query "<question>"` before
  your first grep/search of the iOS code for a codebase question; read raw files for the
  lines it located. Reading the Swift files you are told to port directly is fine.

## Architecture (already in place — read these files first)
- `data/Models.kt` — the same data model as `apps/ios/Shared/Models.swift`, same JSON.
  Ids are `String` (uppercase UUID, `newID()`), dates are `java.time.Instant`.
  Enum entries keep the Swift raw values (`DashboardCard.weekPreview`).
- `data/LocalStore.kt` — data.json, atomic, one lock.
- `core/MeldoCalendar.kt` — the student's calendar (Monday-first) + FFI date conversions
  (`calendar.ffiDate(instant)`, `calendar.instant(ffiDate)`, `startOfDay`, `isSameDay`,
  `addDays`, `weekStart`, `mondayIndex`, `minuteOfDay`, `at(day, minute)`).
- `core/MeldeEngine.kt` — port of `Shared/MeldeEngine.swift`.
- `core/Localization.kt` — `L()` and `Localization.locale` (use it for every date/number format).
- `model/AppModel.kt` (+ `AppModelWeek.kt`, `AppModelTasks.kt`, `AppModelSchool.kt`) —
  port of `App/AppModel*.swift`. Swift extensions become Kotlin extension functions in
  their own file `model/AppModel<Feature>.kt`. State is Compose state: `model.data` is
  observable; change data **only** through `model.mutate { d -> … }` (d is mutable).
  `model.calendar`, `model.currentDate`, `model.context`, `model.scope` (coroutines).
- Rust core API (UniFFI, package `uniffi.melde_ffi`): summary in `docs/core-api.kt.txt`.
  Errors are `MeldeException.InvalidInput(detail)`, `.UntisServer(code, detail)`,
  `.UntisMalformed(detail)`.
- UI foundation:
  - `ui/theme/MeldoTheme.kt` — `MeldoTheme`, `SubjectColor.color` (composable), `StateColors`,
    `AppTheme.brandColor()`, `MeldoColors`.
  - `ui/components/Components.kt` — `LocalAppModel`, `DS` tokens, `Card`, `CardHeader`,
    `ProgressRing`, `SubjectIcon`, `LessonRow`, `Badge`, `TimeText`, `WeekdayText`, `SectionHeader`.
  - `ui/components/Symbols.kt` — `sfSymbol("sf.symbol.name")` → Material icon. Add mappings
    there **only** by appending new `when` branches (other ports edit it too; re-read before editing).
  - `ui/navigation/Navigator.kt` — `MeldoScreen(title, actions, floatingActionButton) { padding -> }`
    is every screen's scaffold (large top app bar = iOS large title, back arrow on pushed screens).
    `LocalNavigator.current.push { OtherScreen() }` = `NavigationLink`; `.pop()` = dismiss.
  - `ui/navigation/RootScreen.kt` — tabs (phone) / permanent drawer (≥ 840 dp, = iPad sidebar).
- SwiftUI → Compose mapping: `List`/`Form` → `LazyColumn` with tonal grouped sections
  (`Card` or `ListItem` on `surfaceContainer` with `DS.rowShape`), `.sheet` →
  `ModalBottomSheet`, `.alert`/`.confirmationDialog` → `AlertDialog`, `Menu` → `DropdownMenu`,
  `Picker(.segmented)` → `SingleChoiceSegmentedButtonRow`, `Toggle` → `Switch` in a `ListItem`,
  `DatePicker` → Material `DatePickerDialog`/`TimePicker`, `.swipeActions` →
  `SwipeToDismissBox`, `ContentUnavailableView` → centered icon + title + text,
  Swift Charts → Compose `Canvas` drawing, `.glassEffect`/`.glass` buttons → filled tonal
  buttons / `FilledTonalButton` / FAB. Haptics: `LocalHapticFeedback` (only when
  `preferences.haptics`). Reduce Motion: respect `Settings.Global.ANIMATOR_DURATION_SCALE == 0`.

## Ownership (parallel ports — touch only your files)
Each port owns the files it creates under its package and its own
`model/AppModel<Feature>.kt` and `strings/<feature>.json`. Shared files you may append to,
re-reading right before each edit: `ui/components/Symbols.kt`, `AndroidManifest.xml`
(only between the `MANIFEST:*` markers' lines, adding your own lines), `docs/core-api.kt.txt` (no).
Do not edit `AppModel.kt`, `Models.kt`, `RootScreen.kt`, `Components.kt`, `MeldoTheme.kt`
— if you need a change there, describe it in your final report and the lead applies it.
The screen stub files (`// PORT-IN-PROGRESS`) of your feature are yours to overwrite;
keep the composable names and signatures that `RootScreen.kt` calls.

## Build
```bash
cd apps/android
export JAVA_HOME="$LOCALAPPDATA/Programs/jdk-21.0.12.1+1"
./gradlew :app:compileDebugKotlin --console=plain -q 2>&1 | grep -E "^e:" | head -50
```
Other ports work at the same time, so errors in files you don't own are theirs — ignore
them, but make sure **your** files compile. Do not run `assemble`/install; the lead does.
