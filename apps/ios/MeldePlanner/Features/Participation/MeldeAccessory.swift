import SwiftUI

/// The Melde button in the tab bar accessory: one tap records a Meldung for the
/// current lesson; outside lessons a second tap picks the subject. Every
/// recording can be undone for a few seconds.
struct MeldeAccessory: View {
    @Environment(AppModel.self) private var model
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement
    @State private var lastEntry: ParticipationEntry?
    @State private var choosingSubject = false
    @State private var successCount = 0

    var body: some View {
        TimelineView(.everyMinute) { context in
            HStack(spacing: DS.spacingM) {
                if placement != .inline {
                    status(at: context.date)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button(action: record) {
                    Label(L("Melden"), systemImage: "hand.raised.fill")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .accessibilityLabel(L("Meldung erfassen"))
            }
            .padding(.horizontal, DS.spacingM)
        }
        .sensoryFeedback(.success, trigger: successCount)
        .task(id: lastEntry?.id) {
            guard lastEntry != nil else { return }
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled { lastEntry = nil }
        }
        .sheet(isPresented: $choosingSubject) {
            SubjectPickerSheet { subjectID in
                lastEntry = model.recordParticipation(subjectID: subjectID)
                successCount += 1
            }
        }
    }

    @ViewBuilder
    private func status(at date: Date) -> some View {
        if let entry = lastEntry {
            HStack(spacing: DS.spacingS) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text(model.subject(entry.subjectID)?.name ?? L("Gemeldet"))
                    .lineLimit(1)
                Button(L("Rückgängig")) {
                    model.deleteParticipation(entry.id)
                    lastEntry = nil
                }
                .font(.subheadline.weight(.semibold))
            }
            .font(.subheadline)
            .transition(.opacity)
        } else if let current = model.currentLesson(at: date) {
            let subject = model.subject(for: current)
            HStack(spacing: DS.spacingS) {
                SubjectIcon(subject: subject, size: 26)
                VStack(alignment: .leading, spacing: 0) {
                    Text(subject?.name ?? L("Unbekanntes Fach"))
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(L("\(todayCount(for: current.subjectId)) heute"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Text(L("Gerade keine Stunde"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func todayCount(for subjectID: String) -> Int {
        model.entries(on: model.currentDate).filter { $0.subjectID?.uuidString == subjectID }.count
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

/// Manual subject selection when no lesson is running.
struct SubjectPickerSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var onPick: (UUID?) -> Void

    var body: some View {
        NavigationStack {
            List {
                if model.subjects.isEmpty {
                    Text(L("Lege zuerst Fächer an, damit Meldungen zugeordnet werden können."))
                        .foregroundStyle(.secondary)
                }
                ForEach(model.subjects) { subject in
                    Button {
                        onPick(subject.id)
                        dismiss()
                    } label: {
                        HStack(spacing: DS.spacingM) {
                            SubjectIcon(subject: subject, size: 30)
                            Text(subject.name).foregroundStyle(.primary)
                        }
                    }
                }
                Section {
                    Button(L("Ohne Fach erfassen")) {
                        onPick(nil)
                        dismiss()
                    }
                }
            }
            .navigationTitle(L("Für welches Fach?"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("Abbrechen"), role: .cancel) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
