import SwiftUI

/// The floating Melden button on every tab (iPhone and iPad). One tap records
/// a Meldung for the current lesson; outside lessons it asks for the subject.
/// After recording it shows the subject with an Undo button for a few seconds.
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
