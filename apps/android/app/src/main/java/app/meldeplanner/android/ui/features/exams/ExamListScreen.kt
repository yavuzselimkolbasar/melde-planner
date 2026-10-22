@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package app.meldeplanner.android.ui.features.exams

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.snap
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.VerticalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import app.meldeplanner.android.core.L
import app.meldeplanner.android.data.DocumentCategory
import app.meldeplanner.android.data.ExamDocument
import app.meldeplanner.android.data.Subject
import app.meldeplanner.android.model.deleteExam
import app.meldeplanner.android.model.exams
import app.meldeplanner.android.model.organizeDocuments
import app.meldeplanner.android.model.upcomingUntisExams
import app.meldeplanner.android.ui.components.Badge
import app.meldeplanner.android.ui.components.DS
import app.meldeplanner.android.ui.components.LocalAppModel
import app.meldeplanner.android.ui.components.MeldoMenu
import app.meldeplanner.android.ui.components.MeldoMenuItem
import app.meldeplanner.android.ui.components.rememberReduceMotion
import app.meldeplanner.android.ui.components.sfSymbol
import app.meldeplanner.android.ui.features.dashboard.UntisExamRow
import app.meldeplanner.android.ui.features.more.meldoAnimateItem
import app.meldeplanner.android.ui.features.more.IconTile
import app.meldeplanner.android.ui.features.more.extend
import app.meldeplanner.android.ui.features.more.formRowShape
import app.meldeplanner.android.ui.features.tasks.DayFormat
import app.meldeplanner.android.ui.features.tasks.SwipeToDelete
import app.meldeplanner.android.ui.features.tasks.rememberMinuteNow
import app.meldeplanner.android.ui.navigation.LocalNavigator
import app.meldeplanner.android.ui.navigation.MeldoScreen

/** Dokumente (Prüfungen, Arbeitsblätter, Dokumente), grouped by subject. Port of ExamListView.swift. */
@Composable
fun ExamListScreen() {
    val model = LocalAppModel.current
    var selected by rememberSaveable { mutableStateOf<String?>(null) }
    BoxWithConstraints(Modifier.fillMaxSize()) {
        val shown = selected?.takeIf { id -> model.exams.any { it.id == id } } ?: model.exams.firstOrNull()?.id
        if (maxWidth >= 840.dp && shown != null) {
            // Wide screens (iPad layout): list and PDF side by side.
            Row(Modifier.fillMaxSize()) {
                Box(Modifier.width(380.dp).fillMaxHeight()) {
                    ExamList(selected = shown, onSelect = { selected = it }, onDeleted = { if (selected == it) selected = null })
                }
                VerticalDivider()
                Box(Modifier.weight(1f).fillMaxHeight()) {
                    key(shown) { ExamDetailScreen(shown) }
                }
            }
        } else {
            ExamList(selected = null, onSelect = null, onDeleted = { if (selected == it) selected = null })
        }
    }
}

/**
 * The list; [onSelect] is set on wide screens, where tapping shows the document
 * next to the list instead of opening it.
 */
@Composable
private fun ExamList(selected: String?, onSelect: ((String) -> Unit)?, onDeleted: (String) -> Unit) {
    val model = LocalAppModel.current
    val navigator = LocalNavigator.current
    val now = rememberMinuteNow(model)
    var filter by rememberSaveable { mutableStateOf<DocumentCategory?>(null) }
    var problem by remember { mutableStateOf<String?>(null) }
    var menu by remember { mutableStateOf(false) }
    var filterMenu by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) { model.organizeDocuments() }

    val importer = rememberDocumentImporter(
        onPending = { pending ->
            navigator.push { ExamEditorScreen(ExamEditorMode.New(pending), onDismiss = { navigator.pop() }) }
        },
        onProblem = { problem = it },
    )
    val scan = { problem = null; importer.scan() }
    val photos = { problem = null; importer.photos() }
    val files = { problem = null; importer.files() }

    val all = model.exams
    val shown = all.filter { filter == null || it.kind == filter }
    val groups = groups(shown, model.subjects) { model.subject(it) }

    MeldoScreen(
        L("Dokumente"),
        actions = {
            if (all.isNotEmpty()) {
                Box {
                    IconButton(onClick = { filterMenu = true }, shapes = IconButtonDefaults.shapes()) {
                        Icon(sfSymbol("slider.horizontal.3"), "${L("Anzeigen")}: ${DocumentCategoryText.plural(filter)}")
                    }
                    MeldoMenu(
                        expanded = filterMenu,
                        onDismiss = { filterMenu = false },
                        groups = listOf(
                            listOf(MeldoMenuItem(L("Alle"), symbol = "doc.on.doc", checked = filter == null) { filter = null }),
                            DocumentCategory.entries.map { category ->
                                MeldoMenuItem(
                                    DocumentCategoryText.plural(category),
                                    symbol = DocumentCategoryText.symbol(category),
                                    checked = filter == category,
                                ) { filter = category }
                            },
                        ),
                    )
                }
            }
            Box {
                IconButton(onClick = { menu = true }, shapes = IconButtonDefaults.shapes()) { Icon(sfSymbol("plus"), L("Hinzufügen")) }
                MeldoMenu(
                    expanded = menu,
                    onDismiss = { menu = false },
                    groups = listOf(
                        listOf(MeldoMenuItem(L("Scannen"), symbol = "doc.viewfinder") { scan() }),
                        listOf(
                            MeldoMenuItem(L("Aus Fotos"), symbol = "photo.on.rectangle") { photos() },
                            MeldoMenuItem(L("PDF importieren"), symbol = "square.and.arrow.down") { files() },
                        ),
                    ),
                )
            }
        },
    ) { padding ->
        LazyColumn(
            Modifier.fillMaxSize(),
            contentPadding = padding.extend(horizontal = DS.spacingL, bottom = DS.spacingXL),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            problem?.let { text ->
                item(key = "problem") { ProblemLabel(text, meldoAnimateItem().padding(vertical = DS.spacingS)) }
            }
            if (all.isNotEmpty() && filter != null) {
                item(key = "filter") {
                    // The active filter, one tap to show everything again.
                    FilterChip(
                        selected = true,
                        onClick = { filter = null },
                        label = { Text(DocumentCategoryText.plural(filter)) },
                        leadingIcon = { Icon(sfSymbol(DocumentCategoryText.symbol(filter)), null, Modifier.size(FilterChipDefaults.IconSize)) },
                        trailingIcon = { Icon(sfSymbol("xmark.circle.fill"), L("Alle"), Modifier.size(FilterChipDefaults.IconSize)) },
                        shape = RoundedCornerShape(DS.rowRadius),
                        modifier = meldoAnimateItem().padding(top = DS.spacingS),
                    )
                }
            }
            val upcoming = model.upcomingUntisExams(now)
            if (upcoming.isNotEmpty()) {
                item(key = "upcoming-header") { GroupHeader(L("Anstehend"), null, meldoAnimateItem()) }
                items(upcoming.withIndex().toList(), key = { "untis-${it.value.id}" }) { (index, exam) ->
                    Surface(
                        shape = formRowShape(index, upcoming.size),
                        color = MaterialTheme.colorScheme.surfaceContainer,
                        modifier = meldoAnimateItem(),
                    ) {
                        Box(Modifier.fillMaxWidth().padding(DS.spacingL)) { UntisExamRow(exam, now) }
                    }
                }
                item(key = "upcoming-footer") {
                    Text(
                        L("Termine aus WebUntis. Zurückgegebene Arbeiten scannst du unten ein."),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = meldoAnimateItem().padding(start = DS.spacingL, end = DS.spacingL, top = DS.spacingS),
                    )
                }
            }
            if (all.isEmpty()) {
                item(key = "welcome") { ExamsWelcome(canScan = true, scan = scan, photos = photos, files = files) }
            }
            for ((subject, exams) in groups) {
                item(key = "group-${subject?.id ?: "none"}") {
                    GroupHeader(subject?.name ?: L("Ohne Fach"), subject?.symbolName ?: "questionmark.folder", meldoAnimateItem())
                }
                items(exams.withIndex().toList(), key = { it.value.id }) { (index, exam) ->
                    val shape = formRowShape(index, exams.size)
                    SwipeToDelete(
                        onDelete = {
                            onDeleted(exam.id)
                            model.deleteExam(exam.id)
                        },
                        shape = shape,
                        modifier = meldoAnimateItem(),
                    ) {
                        val highlighted = onSelect != null && selected == exam.id
                        Box(
                            Modifier
                                .fillMaxWidth()
                                .background(if (highlighted) MaterialTheme.colorScheme.secondaryContainer else Color.Transparent, shape)
                                .clickable(role = Role.Button) {
                                    if (onSelect != null) onSelect(exam.id)
                                    else navigator.push { ExamDetailScreen(exam.id, onDismiss = { navigator.pop() }) }
                                }
                                .padding(horizontal = DS.spacingL, vertical = DS.spacingM),
                        ) { ExamRow(exam) }
                    }
                }
            }
        }
    }
}

/** Subjects in their order, then documents whose subject is gone or unset. */
private fun groups(
    shown: List<ExamDocument>,
    subjects: List<Subject>,
    lookup: (String) -> Subject?,
): List<Pair<Subject?, List<ExamDocument>>> {
    val bySubject = shown.groupBy { it.subjectID }
    val result = mutableListOf<Pair<Subject?, List<ExamDocument>>>()
    for (subject in subjects) bySubject[subject.id]?.let { result += subject to it }
    val orphans = shown.filter { exam -> exam.subjectID?.let(lookup) == null }
    if (orphans.isNotEmpty()) result += null to orphans
    return result
}

@Composable
private fun GroupHeader(title: String, symbol: String?, modifier: Modifier = Modifier) {
    Row(
        modifier.padding(start = DS.spacingL, top = DS.spacingL, bottom = DS.spacingS),
        horizontalArrangement = Arrangement.spacedBy(DS.spacingS),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (symbol != null) Icon(sfSymbol(symbol), null, Modifier.size(18.dp), tint = MaterialTheme.colorScheme.primary)
        Text(title, style = MaterialTheme.typography.titleSmall, color = MaterialTheme.colorScheme.primary)
    }
}

@Composable
private fun ExamRow(exam: ExamDocument) {
    val model = LocalAppModel.current
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(DS.spacingM)) {
        IconTile(sfSymbol(DocumentCategoryText.symbol(exam.kind)), size = 40.dp)
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(exam.title, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.SemiBold)
            Text(
                L("%@ · %lld Seiten", DayFormat.format(exam.date, "yMMMd", model.calendar), exam.pageCount),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        if (exam.grade.isNotEmpty()) Badge(exam.grade, MaterialTheme.colorScheme.primary)
    }
}

/** First visit: what Dokumente is for and the three ways to add one. Scannen is the hero. */
@Composable
private fun ExamsWelcome(canScan: Boolean, scan: () -> Unit, photos: () -> Unit, files: () -> Unit) {
    Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.TopCenter) {
        Column(
            Modifier.widthIn(max = 520.dp).padding(vertical = DS.spacingL),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(DS.spacingL),
        ) {
            Column(
                Modifier.padding(top = DS.spacingS, start = DS.spacingS, end = DS.spacingS),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(DS.spacingS),
            ) {
                IconTile(sfSymbol("doc.text.viewfinder"), size = 72.dp)
                Text(
                    L("Deine Unterlagen an einem Ort"),
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(top = DS.spacingS),
                )
                Text(
                    L("Scanne Klassenarbeiten, Arbeitsblätter und Dokumente oder lade Fotos und PDFs. Meldo sortiert sie nach Fach, auch in der Dateien-App."),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                )
            }
            Column(verticalArrangement = Arrangement.spacedBy(DS.spacingS)) {
                if (canScan) {
                    HeroTile(L("Scannen"), L("Mit der Kamera, Seite für Seite"), "doc.viewfinder", onClick = scan)
                    Row(Modifier.height(IntrinsicSize.Max), horizontalArrangement = Arrangement.spacedBy(DS.spacingS)) {
                        SmallTile(L("Aus Fotos"), L("Bilder aus deiner Galerie"), "photo.on.rectangle", photos, Modifier.weight(1f))
                        SmallTile(L("PDF importieren"), L("Aus Dateien, Google Drive oder Mail"), "square.and.arrow.down", files, Modifier.weight(1f))
                    }
                } else {
                    HeroTile(L("Aus Fotos"), L("Bilder aus deiner Galerie"), "photo.on.rectangle", onClick = photos)
                    SmallTile(L("PDF importieren"), L("Aus Dateien, Google Drive oder Mail"), "square.and.arrow.down", files, Modifier.fillMaxWidth())
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(DS.spacingXS), verticalAlignment = Alignment.CenterVertically) {
                Icon(sfSymbol("folder"), null, Modifier.size(14.dp), tint = MaterialTheme.colorScheme.onSurfaceVariant)
                Text(
                    L("Dateien › Dokumente › Meldo › Scans"),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

/** Corner radius that tightens while pressed (Expressive press morph); fixed when animations are off. */
@Composable
private fun pressedCorner(interaction: MutableInteractionSource, rest: androidx.compose.ui.unit.Dp, pressed: androidx.compose.ui.unit.Dp) =
    animateDpAsState(
        if (interaction.collectIsPressedAsState().value) pressed else rest,
        if (rememberReduceMotion()) snap() else MaterialTheme.motionScheme.fastSpatialSpec(),
        label = "corner",
    ).value

/** The main way to add a document: a large filled tile. */
@Composable
private fun HeroTile(title: String, subtitle: String, symbol: String, onClick: () -> Unit) {
    val scheme = MaterialTheme.colorScheme
    val interaction = remember { MutableInteractionSource() }
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(pressedCorner(interaction, DS.cardRadius, DS.rowRadius)),
        color = scheme.primary,
        contentColor = scheme.onPrimary,
        interactionSource = interaction,
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            Modifier.padding(DS.spacingL),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(DS.spacingL),
        ) {
            IconTile(sfSymbol(symbol), tint = scheme.onPrimary, background = scheme.onPrimary.copy(alpha = 0.18f), size = 56.dp)
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(title, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                Text(subtitle, style = MaterialTheme.typography.bodyMedium, color = scheme.onPrimary.copy(alpha = 0.85f))
            }
            Icon(sfSymbol("chevron.right"), null, Modifier.size(20.dp), tint = scheme.onPrimary.copy(alpha = 0.7f))
        }
    }
}

/** A secondary way to add a document: a tonal tile. */
@Composable
private fun SmallTile(title: String, subtitle: String, symbol: String, onClick: () -> Unit, modifier: Modifier) {
    val scheme = MaterialTheme.colorScheme
    val interaction = remember { MutableInteractionSource() }
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(pressedCorner(interaction, DS.cardRadius, DS.rowRadius)),
        color = scheme.secondaryContainer,
        contentColor = scheme.onSecondaryContainer,
        interactionSource = interaction,
        modifier = modifier.fillMaxHeight(),
    ) {
        Column(Modifier.padding(DS.spacingL), verticalArrangement = Arrangement.spacedBy(DS.spacingS)) {
            IconTile(sfSymbol(symbol), tint = scheme.onSecondaryContainer, background = scheme.onSecondaryContainer.copy(alpha = 0.12f), size = 44.dp)
            Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = scheme.onSecondaryContainer.copy(alpha = 0.8f))
        }
    }
}

/** German labels for document categories (the folders keep English names). */
object DocumentCategoryText {
    fun name(category: DocumentCategory): String = when (category) {
        DocumentCategory.exam -> L("Prüfung")
        DocumentCategory.worksheet -> L("Arbeitsblatt")
        DocumentCategory.document -> L("Dokument")
    }

    fun plural(category: DocumentCategory?): String = when (category) {
        null -> L("Alle")
        DocumentCategory.exam -> L("Prüfungen")
        DocumentCategory.worksheet -> L("Arbeitsblätter")
        DocumentCategory.document -> L("Dokumente")
    }

    /** Symbol for a category's rows and menu items. */
    fun symbol(category: DocumentCategory?): String = when (category) {
        null -> "doc.on.doc"
        DocumentCategory.exam -> "pencil.and.list.clipboard"
        DocumentCategory.worksheet -> "doc.text"
        DocumentCategory.document -> "folder"
    }
}
