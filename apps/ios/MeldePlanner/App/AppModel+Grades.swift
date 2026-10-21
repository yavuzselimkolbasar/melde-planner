import Foundation
import MeldeCore

/// Notenrechner: the student's own grades, averaged by the Rust core with the
/// configured scale and weights. Estimates only; official grades come from
/// the school. Participation counts (Meldungen) are never mixed in.
extension AppModel {
    var gradeConfig: FfiGradingConfig {
        let p = data.preferences
        return FfiGradingConfig(
            scale: p.gradeScale == .points ? .points : .traditional,
            writtenWeight: p.writtenWeight,
            oralWeight: 1 - p.writtenWeight,
            rounding: .halfTowardBetter
        )
    }

    func grades(for subjectID: UUID) -> [GradeEntry] {
        data.grades.filter { $0.subjectID == subjectID }.sorted { $0.date > $1.date }
    }

    private func assessments(_ grades: [GradeEntry]) -> [FfiAssessment] {
        grades.map { FfiAssessment(value: $0.value, weight: $0.weight, category: $0.written ? .written : .oral) }
    }

    func gradeSummary(for subjectID: UUID) -> FfiSubjectSummary? {
        let list = grades(for: subjectID)
        guard !list.isEmpty else { return nil }
        return try? gradeSubjectSummary(config: gradeConfig, assessments: assessments(list))
    }

    /// Average over all subjects with grades, each subject weighted equally.
    var overallGradeAverage: Double? {
        let weights = data.subjects.compactMap { subject -> FfiSubjectWeight? in
            guard let exact = gradeSummary(for: subject.id)?.exact else { return nil }
            return FfiSubjectWeight(average: exact, weight: 1)
        }
        return gradeOverallAverage(subjects: weights)
    }

    /// What the next written grade must be to reach `target` (e.g. 2.0 or 11 points).
    func gradeNeeded(for subjectID: UUID, target: Double) -> FfiForecast? {
        try? gradeForecast(
            config: gradeConfig,
            existing: assessments(grades(for: subjectID)),
            planned: [FfiPlannedAssessment(weight: 1, category: .written)],
            targetGrade: target
        )
    }

    func saveGrade(_ grade: GradeEntry) {
        mutate { data in
            if let i = data.grades.firstIndex(where: { $0.id == grade.id }) {
                data.grades[i] = grade
            } else {
                data.grades.append(grade)
            }
        }
    }

    func deleteGrade(_ id: UUID) {
        mutate { $0.grades.removeAll { $0.id == id } }
    }

    /// Remembered for the next Entschuldigung.
    func setExcuseDetails(name: String, className: String, salutation: String, adult: Bool) {
        mutate { data in
            data.preferences.studentName = name.trimmingCharacters(in: .whitespaces)
            data.preferences.className = className.trimmingCharacters(in: .whitespaces)
            data.preferences.excuseSalutation = salutation.trimmingCharacters(in: .whitespaces)
            data.preferences.adultStudent = adult
        }
    }

    func setGradeScale(_ scale: GradeScaleChoice) {
        mutate { $0.preferences.gradeScale = scale }
    }

    func setWrittenWeight(_ weight: Double) {
        mutate { $0.preferences.writtenWeight = min(max(weight, 0), 1) }
    }

    func setTendencyStep(_ step: Double) {
        mutate { $0.preferences.tendencyStep = step }
    }

    /// "2,33" or "11,0 P." in the student's scale.
    func gradeText(_ value: Double) -> String {
        let number = value.formatted(.number.precision(.fractionLength(data.preferences.gradeScale == .points ? 1 : 2)).locale(Localization.locale))
        return data.preferences.gradeScale == .points ? L("\(number) P.") : number
    }
}
