package app.meldeplanner.android.ui.navigation

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.PermanentDrawerSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.unit.dp
import app.meldeplanner.android.core.L
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.ui.layout.onSizeChanged
import app.meldeplanner.android.ui.theme.LocalBottomChrome
import app.meldeplanner.android.ui.theme.LocalChromeHaze
import app.meldeplanner.android.ui.theme.meldoChrome
import app.meldeplanner.android.model.AppModel
import app.meldeplanner.android.ui.components.DS
import app.meldeplanner.android.ui.components.LocalAppModel
import app.meldeplanner.android.ui.components.SectionHeader
import app.meldeplanner.android.ui.components.sfSymbol
import app.meldeplanner.android.ui.features.calendar.CalendarScreen
import app.meldeplanner.android.ui.features.dashboard.DashboardScreen
import app.meldeplanner.android.ui.features.exams.ExamListScreen
import app.meldeplanner.android.ui.features.grades.GradesScreen
import app.meldeplanner.android.ui.features.more.AboutScreen
import app.meldeplanner.android.ui.features.more.MoreScreen
import app.meldeplanner.android.ui.features.more.SettingsScreen
import app.meldeplanner.android.ui.features.more.StatusScreen
import app.meldeplanner.android.ui.features.participation.MeldenButton
import app.meldeplanner.android.ui.features.participation.SubjectPickerSheet
import app.meldeplanner.android.ui.features.statistics.StatisticsScreen
import app.meldeplanner.android.ui.features.subjects.SubjectListScreen
import app.meldeplanner.android.ui.features.tasks.TaskListScreen
import app.meldeplanner.android.ui.features.timetable.HolidayListScreen
import app.meldeplanner.android.ui.features.timetable.TimetableScreen
import app.meldeplanner.android.ui.features.untis.AbsencesScreen
import app.meldeplanner.android.ui.features.untis.TeamsConnectScreen
import app.meldeplanner.android.ui.features.untis.UntisConnectScreen

enum class AppTab {
    home, timetable, calendar, tasks, exams, statistics, more,
    absences, holidays, untis, teams, subjects, settings, status, about, grades,
}

private data class Destination(val tab: AppTab, val title: () -> String, val symbol: String)

private val phoneTabs = listOf(
    Destination(AppTab.home, { L("Start") }, "house"),
    Destination(AppTab.timetable, { L("Stundenplan") }, "tablecells"),
    Destination(AppTab.tasks, { L("Aufgaben") }, "checklist"),
    Destination(AppTab.exams, { L("Dokumente") }, "doc.on.doc"),
    Destination(AppTab.more, { L("Mehr") }, "ellipsis.circle"),
)

private val sidebarMain = listOf(
    Destination(AppTab.home, { L("Start") }, "house"),
    Destination(AppTab.timetable, { L("Stundenplan") }, "tablecells"),
    Destination(AppTab.tasks, { L("Aufgaben") }, "checklist"),
    Destination(AppTab.exams, { L("Dokumente") }, "doc.on.doc"),
    Destination(AppTab.calendar, { L("Kalender") }, "calendar"),
    Destination(AppTab.statistics, { L("Statistik") }, "chart.bar"),
)

private val sidebarSchool = listOf(
    Destination(AppTab.grades, { L("Noten") }, "graduationcap"),
    Destination(AppTab.absences, { L("Abwesenheiten") }, "person.crop.circle.badge.clock"),
    Destination(AppTab.holidays, { L("Ferien") }, "sun.horizon"),
    Destination(AppTab.untis, { L("WebUntis") }, "arrow.triangle.2.circlepath"),
    Destination(AppTab.teams, { L("Microsoft Teams") }, "person.3"),
)

private val sidebarApp = listOf(
    Destination(AppTab.subjects, { L("Fächer") }, "books.vertical"),
    Destination(AppTab.settings, { L("Einstellungen") }, "gearshape"),
    Destination(AppTab.status, { L("Status") }, "stethoscope"),
    Destination(AppTab.about, { L("Über Meldo") }, "info.circle"),
)

/** Something the app was opened for (widget, tile, notification, shortcut). */
enum class DeepLinkTarget { melden, homework }

/**
 * Main navigation, port of RootView.swift. Phones show five tabs (the rest lives
 * under Mehr); wide screens (tablets, unfolded foldables) show a permanent drawer
 * with every destination, grouped into Schule and App, like the iPad sidebar. The
 * floating Melden button only appears on Start and Stundenplan.
 */
@Composable
fun RootScreen(model: AppModel, deepLink: DeepLinkTarget?, onDeepLinkHandled: () -> Unit) {
    var tab by rememberSaveable { mutableStateOf(AppTab.home) }
    var pickingSubject by remember { mutableStateOf(false) }
    val navigators = remember { mutableMapOf<AppTab, Navigator>() }
    fun navigator(t: AppTab) = navigators.getOrPut(t) { Navigator() }

    LaunchedEffect(deepLink) {
        when (deepLink) {
            DeepLinkTarget.melden -> {
                tab = AppTab.home
                if (model.recordParticipation() is AppModel.RecordOutcome.NeedsSubject) pickingSubject = true
            }
            DeepLinkTarget.homework -> tab = AppTab.tasks
            null -> return@LaunchedEffect
        }
        onDeepLinkHandled()
    }

    // No focused text field (and keyboard) waiting when the student comes back to Meldo.
    val focusManager = androidx.compose.ui.platform.LocalFocusManager.current
    androidx.lifecycle.compose.LifecycleEventEffect(androidx.lifecycle.Lifecycle.Event.ON_STOP) { focusManager.clearFocus() }

    val chromeHaze = dev.chrisbanes.haze.rememberHazeState()
    CompositionLocalProvider(LocalAppModel provides model, LocalChromeHaze provides chromeHaze) {
        BoxWithConstraints(Modifier.fillMaxSize()) {
            val wide = maxWidth >= 840.dp
            // Sidebar-only destinations have no phone tab; land on Mehr instead (and back).
            LaunchedEffect(wide) {
                if (!wide && phoneTabs.none { it.tab == tab }) tab = AppTab.more
                if (wide && tab == AppTab.more) tab = AppTab.settings
            }
            if (wide) {
                Row(Modifier.fillMaxSize()) {
                    PermanentDrawerSheet(Modifier.width(280.dp).fillMaxHeight()) {
                        Column(Modifier.verticalScroll(rememberScrollState()).statusBarsPadding().padding(horizontal = DS.spacingM)) {
                            Text(
                                "Meldo", style = MaterialTheme.typography.headlineSmall,
                                modifier = Modifier.padding(DS.spacingL),
                            )
                            sidebarMain.forEach { DrawerItem(it, tab) { t -> tab = t } }
                            SectionHeader(L("Schule"))
                            sidebarSchool.forEach { DrawerItem(it, tab) { t -> tab = t } }
                            SectionHeader(L("App"))
                            sidebarApp.forEach { DrawerItem(it, tab) { t -> tab = t } }
                        }
                    }
                    val navInset = androidx.compose.foundation.layout.WindowInsets.navigationBars
                        .asPaddingValues().calculateBottomPadding()
                    Box(Modifier.weight(1f)) {
                        CompositionLocalProvider(LocalBottomChrome provides navInset) { TabContent(tab, navigator(tab)) }
                    }
                }
            } else {
                // Content runs under the floating frosted tab bar, which blurs it (iOS 26 tab bar).
                val navInset = androidx.compose.foundation.layout.WindowInsets.navigationBars
                    .asPaddingValues().calculateBottomPadding()
                val barGap = DS.spacingS
                // Constant while the bar minimizes, so content doesn't jump as it scrolls.
                val bottomChrome = TabBarHeight + barGap + navInset
                val scroll = remember { TabBarScrollState() }
                Box(Modifier.fillMaxSize().nestedScroll(scroll)) {
                    CompositionLocalProvider(LocalBottomChrome provides bottomChrome) {
                        TabContent(tab, navigator(tab))
                    }
                    // Scroll edge effect (iOS): content fades out where it meets the floating bar.
                    val page = MaterialTheme.colorScheme.surface
                    Box(
                        Modifier
                            .align(Alignment.BottomCenter)
                            .fillMaxWidth()
                            .height(bottomChrome + DS.spacingS)
                            .background(
                                androidx.compose.ui.graphics.Brush.verticalGradient(
                                    listOf(page.copy(alpha = 0f), page.copy(alpha = 0.75f), page.copy(alpha = 0.92f)),
                                ),
                            ),
                    )
                    FloatingTabBar(
                        items = phoneTabs.map { d ->
                            TabItem(d.title(), d.symbol, tab == d.tab) {
                                scroll.expand()
                                // Tapping the selected tab again goes back to its root, like iOS.
                                if (tab == d.tab) navigator(d.tab).popToRoot() else tab = d.tab
                            }
                        },
                        minimized = scroll.minimized,
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(start = TabBarMargin, end = TabBarMargin, bottom = navInset + barGap),
                    )
                }
            }
            model.storageProblem?.let { StorageBanner(it, Modifier.align(Alignment.TopCenter)) }
        }
        if (pickingSubject) {
            SubjectPickerSheet(onDismiss = { pickingSubject = false }) { subjectID ->
                model.recordParticipation(subjectID)
                pickingSubject = false
            }
        }
    }
}

@Composable
private fun DrawerItem(d: Destination, selected: AppTab, select: (AppTab) -> Unit) {
    NavigationDrawerItem(
        label = { Text(d.title()) },
        icon = { Icon(sfSymbol(d.symbol), null) },
        selected = selected == d.tab,
        onClick = { select(d.tab) },
    )
}

/** One tab's content in its own navigation stack; Start and Stundenplan get the Melden button. */
@Composable
private fun TabContent(tab: AppTab, navigator: Navigator) {
    CompositionLocalProvider(LocalNavigator provides navigator) {
        val melden = tab == AppTab.home || tab == AppTab.timetable
        val bottomChrome = LocalBottomChrome.current
        Box(Modifier.fillMaxSize()) {
            CompositionLocalProvider(LocalMeldenClearance provides melden) { navigator.Content {
                when (tab) {
                    AppTab.home -> DashboardScreen()
                    AppTab.timetable -> TimetableScreen()
                    AppTab.tasks -> TaskListScreen()
                    AppTab.exams -> ExamListScreen()
                    AppTab.more -> MoreScreen()
                    AppTab.calendar -> CalendarScreen()
                    AppTab.statistics -> StatisticsScreen()
                    AppTab.grades -> GradesScreen()
                    AppTab.absences -> AbsencesScreen()
                    AppTab.holidays -> HolidayListScreen()
                    AppTab.untis -> UntisConnectScreen()
                    AppTab.teams -> TeamsConnectScreen()
                    AppTab.subjects -> SubjectListScreen()
                    AppTab.settings -> SettingsScreen()
                    AppTab.status -> StatusScreen()
                    AppTab.about -> AboutScreen()
                }
            } }
            // Only on the tab's root screen, never on screens pushed from it; above the navigation bar.
            if (melden && navigator.depth == 0) {
                Box(Modifier.align(Alignment.BottomEnd).padding(end = DS.spacingL, bottom = bottomChrome + DS.spacingL)) { MeldenButton() }
            }
        }
    }
}

@Composable
private fun StorageBanner(message: String, modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier.statusBarsPadding().padding(horizontal = DS.spacingL),
        shape = DS.rowShape,
        color = MaterialTheme.colorScheme.errorContainer,
        contentColor = MaterialTheme.colorScheme.onErrorContainer,
    ) {
        Row(Modifier.padding(DS.spacingM), verticalAlignment = Alignment.CenterVertically) {
            Icon(sfSymbol("exclamationmark.triangle.fill"), null)
            Text(message, style = MaterialTheme.typography.bodySmall, modifier = Modifier.padding(start = DS.spacingS))
        }
    }
}
