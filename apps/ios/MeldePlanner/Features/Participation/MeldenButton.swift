import SwiftUI

/// The floating Melden button on Start and Stundenplan. One tap records a
/// Meldung for the current lesson (the badge counts this lesson's Meldungen);
/// outside lessons it suggests the likely lesson instead of listing every
/// subject. After recording it shows the subject with Undo for a few seconds.
struct MeldenButton: View {
    @Environment(AppModel.self) private var model
    @State private var lastEntry: ParticipationEntry?
    @State private var choosingSubject = false
    @State private var successCount = 0

    var body: some View {
        HStack(spacing: DS.spacingS) {
            if let entry = lastEntry {
                Button {
                    model.deleteParticipation(entry.id)
                    lastEntry = nil
                } label: {
                    Label(L("Rückgängig"), systemImage: "arrow.uturn.backward")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, DS.spacingM)
                        .padding(.vertical, DS.spacingS)
                }
                .buttonStyle(.glass)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            Button(action: record) {
                Label(label, systemImage: lastEntry == nil ? "hand.raised.fill" : "checkmark")
                    .font(.headline)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(.horizontal, DS.spacingL)
                    .padding(.vertical, DS.spacingM)
            }
            .buttonStyle(.glassProminent)
            .overlay(alignment: .topTrailing) {
                let count = lessonCount
                if count > 0, lastEntry == nil {
                    Text(count, format: .number)
                        .font(.caption2.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(Color.orange, in: .capsule)
                        .offset(x: 4, y: -4)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityValue(lessonCount > 0 ? L("\(lessonCount)× in dieser Stunde") : "")
            .accessibilityLabel(L("Meldung erfassen"))
            .keyboardShortcut("m", modifiers: .command)
        }
        .padding(DS.spacingL)
        .animation(.spring(duration: 0.3), value: lastEntry?.id)
        .sensoryFeedback(.success, trigger: successCount) { _, _ in model.preferences.haptics }
        .task(id: lastEntry?.id) {
            guard lastEntry != nil else { return }
            try? await Task.sleep(for: .seconds(4))
            if !Task.isCancelled { lastEntry = nil }
        }
        .sheet(isPresented: $choosingSubject) {
            SubjectPickerSheet { subjectID in
                lastEntry = model.recordParticipation(subjectID: subjectID)
                successCount += 1
            }
        }
    }

    /// Meldungen in the running lesson today.
    private var lessonCount: Int {
        guard let current = model.currentLesson(at: model.currentDate) else { return 0 }
        return MeldeEngine.count(model.data, lessonID: current.lessonId, on: model.currentDate, calendar: model.calendar)
    }

    private var label: String {
        guard let entry = lastEntry else { return L("Melden") }
        return model.subject(entry.subjectID)?.name ?? L("Gemeldet")
    }

    private func record() {
        switch model.recordParticipation() {
        case .recorded(let entry):
            lastEntry = entry
            successCount += 1
        case .needsSubject:
            choosingSubject = true
        }
    }
}

/// Outside a lesson: the lesson that just ended, the next one and the
/// subjects used most, as big buttons. Every subject stays one tap away.
struct SubjectPickerSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var onPick: (UUID?) -> Void
    @State private var showingAll = false

    private struct Suggestion: Identifiable {
        let subject: Subject
        let reason: String
        var id: UUID { subject.id }
    }

    private var suggestions: [Suggestion] {
        let now = model.currentDate
        let minute = model.calendar.component(.hour, from: now) * 60 + model.calendar.component(.minute, from: now)
        let blocks = model.timetableBlocks(on: now).filter { $0.kind != .cancelled }
        var list: [Suggestion] = []
        func add(_ id: UUID?, _ reason: String) {
            guard let id, let subject = model.subject(id), !list.contains(where: { $0.subject.id == id }) else { return }
            list.append(Suggestion(subject: subject, reason: reason))
        }
        if let ended = blocks.last(where: { $0.endMinute <= minute && minute - $0.endMinute <= 90 }) {
            add(ended.subjectID, L("Gerade vorbei"))
        }
        if let next = blocks.first(where: { $0.startMinute > minute }) {
            add(next.subjectID, L("Als Nächstes"))
        }
        let counts = Dictionary(grouping: model.data.participation.compactMap(\.subjectID), by: { $0 }).mapValues(\.count)
        for (id, _) in counts.sorted(by: { $0.value > $1.value }).prefix(4) {
            add(id, L("Oft gemeldet"))
        }
        return Array(list.prefix(4))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.spacingM) {
                    if model.subjects.isEmpty {
                        Text(L("Lege zuerst Fächer an, damit Meldungen zugeordnet werden können."))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(L("Gerade läuft keine Stunde. Wofür war die Meldung?"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: DS.spacingS), GridItem(.flexible())], spacing: DS.spacingS) {
                            ForEach(suggestions) { suggestion in
                                Button { pick(suggestion.subject.id) } label: {
                                    VStack(alignment: .leading, spacing: DS.spacingS) {
                                        SubjectIcon(subject: suggestion.subject, size: 32)
                                        Text(suggestion.subject.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        Text(suggestion.reason)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(DS.spacingM)
                                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: DS.rowRadius))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        DisclosureGroup(L("Anderes Fach"), isExpanded: $showingAll) {
                            VStack(spacing: 0) {
                                ForEach(model.subjects) { subject in
                                    Button { pick(subject.id) } label: {
                                        HStack(spacing: DS.spacingM) {
                                            SubjectIcon(subject: subject, size: 26)
                                            Text(subject.name).foregroundStyle(.primary)
                                            Spacer()
                                        }
                                        .padding(.vertical, DS.spacingS)
                                        .contentShape(.rect)
                                    }
                                    .buttonStyle(.plain)
                                    Divider()
                                }
                            }
                        }
                        .padding(.top, DS.spacingS)
                    }
                    Button(L("Ohne Fach erfassen")) { pick(nil) }
                        .font(.subheadline)
                        .padding(.top, DS.spacingS)
                }
                .padding(DS.spacingL)
            }
            .navigationTitle(L("Melden"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("Abbrechen"), role: .cancel) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func pick(_ id: UUID?) {
        onPick(id)
        dismiss()
    }
}
