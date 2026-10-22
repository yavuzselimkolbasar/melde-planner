# Meldo Android design pass: Material 3 Expressive

Goal: make the Android app feel as polished as the iOS app, in Android's newest language
(Material 3 Expressive, material3 1.5.0-beta02) instead of Liquid Glass. Same content and
behavior as before — this pass changes how things look and move, never what they do.

## Already in place (read these first)
- `ui/theme/MeldoTheme.kt` — `MaterialExpressiveTheme` with `MotionScheme.expressive()`,
  rounder `MeldoShapes` (8/12/20/28/36 dp), emphasized `MeldoTypography`, `dynamicAccentPreview()`.
- `ui/theme/Chrome.kt` — translucent chrome (Haze backdrop blur): `Modifier.meldoChrome()` for
  floating bars/controls, `Modifier.meldoBlurSource()` for content, `LocalBottomChrome` (height
  of the navigation bar the content scrolls under), `MeldenButtonClearance`.
- `ui/navigation/Navigator.kt` — `MeldoScreen` now has a `LargeFlexibleTopAppBar` that turns
  into frosted glass when content scrolls under it. The `padding` it gives `content` already
  includes the top bar, the bottom navigation bar and (on Start/Stundenplan) the Melden button.
- `ui/navigation/RootScreen.kt` — Expressive `ShortNavigationBar`, translucent, content runs under it.
- `ui/components/Expressive.kt` — `MeldoSegmented(options, selected, label, onSelect, symbol)`
  (connected ToggleButtons) and `MeldoMenu(expanded, onDismiss, groups = listOf(listOf(MeldoMenuItem(...))))`
  (grouped Expressive menus with check marks and destructive items).
- `ui/components/Components.kt` — `DS` (cards 28 dp, rows 20 dp), `Card`, `SubjectIcon`, …

## Rules for every screen
1. **Content scrolls under the bars.** Pass MeldoScreen's `padding` as the scrolling container's
   *content padding*: `LazyColumn(contentPadding = padding)`, or for `Column + verticalScroll`
   put `.padding(padding)` *after* `.verticalScroll(...)` (inside the scroll). Never
   `Modifier.padding(padding)` on the outside of the scroller — that clips content with a hard
   edge under the bars, which is the bug visible today on Start.
2. **Segmented choices** → `MeldoSegmented` (no `SingleChoiceSegmentedButtonRow`).
3. **Menus** → `MeldoMenu` with groups like iOS menus (no plain `DropdownMenu`).
4. **Buttons morph on press**: `Button/FilledTonalButton/OutlinedButton/TextButton(..., shapes = ButtonDefaults.shapes())`.
   One clear primary action per screen (filled); secondary tonal; tertiary text.
   Icon buttons: `IconButton(..., shapes = IconButtonDefaults.shapes())` where it fits.
5. **Progress** → `LoadingIndicator()` / `ContainedLoadingIndicator()` instead of `CircularProgressIndicator`
   (keep `LinearProgressIndicator` for determinate progress if any).
6. **Lists animate**: stable `key =` on `items(...)` and `Modifier.animateItem()` on each row, so
   rows slide between sections (iOS animates these; Android currently jumps).
7. **Hierarchy**: big numbers use `displaySmall`/`headlineLarge`; card headers `titleSmall`
   in `onSurfaceVariant`; values in rows use the same style as their label (no smaller font for
   one value). Generous spacing: `DS.spacingL` inside cards, `DS.spacingM` between rows.
8. **Surfaces**: page `surface`; cards `surfaceContainer`; grouped list rows
   `surfaceContainerLow`/`surfaceContainer` with `DS.rowShape`, first/last row rounder like iOS
   inset groups. Bottom sheets: `ModalBottomSheet(containerColor = surfaceContainerLow)`.
9. **Motion**: use the theme's motion (`MaterialTheme.motionScheme.defaultSpatialSpec()` /
   `fastEffectsSpec()`) for custom animations; respect Remove animations (`rememberReduceMotion()`).
10. Keep all strings via `L()`, all behavior, all TalkBack semantics. No new dependencies.
    Don't edit files outside your list; if you need a shared change, report it.

## Build check
```bash
cd apps/android && export JAVA_HOME="$LOCALAPPDATA/Programs/jdk-21.0.12.1+1"
./gradlew :app:compileReleaseKotlin --console=plain -q 2>&1 | grep -E "^e:" | head -50
```
Other engineers work in parallel; errors in their files are theirs. Don't install or assemble.
