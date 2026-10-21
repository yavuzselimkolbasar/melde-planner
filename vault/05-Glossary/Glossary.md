---
type: glossary
tags:
- glossary
permalink: melde-planner/05-glossary/glossary
---

# Glossary

Use these exact meanings in code, UI copy and notes. German terms are the canonical product names; code identifiers use the English column.

| Term (DE) | Code name (EN) | Meaning |
|---|---|---|
| Melden / Meldung | `participation` / `ParticipationEntry` | A student raising their hand / actively contributing in class. An *activity count*, **not** a grade. |
| Melde Tracker | `ParticipationTracker` | Signature feature: 1–2 tap recording of a Meldung, auto-linked to the current lesson. |
| Wochenziele | `WeeklyGoal` | Weekly participation targets (overall or per subject). |
| Mündliche Note | `oralGrade` | Oral grade **assigned by the teacher**. Never derived automatically from participation counts. |
| Schriftliche Note | `writtenGrade` | Written grade (Klassenarbeit, Klausur, Test). |
| Klassenarbeit / Klausur | `Exam` (kind: `classTest` / `klausur`) | Graded written exam. "Klausur" is the Oberstufe term. |
| Note (1–6) | `GradeScale.traditional` | 1 = sehr gut (best) … 6 = ungenügend (worst). Lower is better. Tendencies like 2+ / 2− exist. |
| Notenpunkte (0–15) | `GradeScale.points` | Oberstufe scale; higher is better. 15 ≈ 1+, 0 = 6. Conversion is configurable, not hard-coded. |
| Oberstufe | `SchoolStage.upper` | Upper secondary (grades 11–13 / Q-Phase) using the 0–15 point scale. |
| Gewichtung | `weight` | Relative weight of written vs oral or of individual assessments. Configurable per subject; states and schools differ. |
| Notenrechner | `GradeCalculator` | Computes exact weighted averages. Exact value is shown separately from any rounded/official grade. |
| Notenprognose | `GradeForecast` | "What do I need?" / "What if?" scenarios, incl. reachable/unreachable detection. |
| Stundenplan | `Timetable` | Repeating weekly schedule of `Lesson`s. |
| Stunde / Schulstunde | `Lesson` / `Period` | One timetable slot with start/end time and subject. |
| Fach | `Subject` | School subject with color + SF Symbol. |
| Vertretung / Ausfall | `TimetableChange` | Substitution / cancelled lesson. |
| Ferien | `Holiday` | School holidays; vary by Bundesland. |
| Bundesland | `State` | German federal state; grading rules may differ per state. |
| Hausaufgaben | `Homework` (a `Task` kind) | Homework with a due date. |
| Tagesplaner | `DailyPlanner` / `StudySession` | Planned study sessions per day/week. |
| Fokus Timer | `FocusTimer` | Pomodoro / Stopwatch / Countdown; timestamp-based. |
| Meine Ziele | `AcademicGoal` | Grade / participation / study-time targets. |

## Rules that prevent misunderstandings
- **Participation ≠ grade.** Never show copy like "10 more hand raises = grade 2".
- **Grade direction depends on scale.** On 1–6 lower is better; on 0–15 higher is better. All comparison logic must go through the scale type, never raw `<`/`>`.
- **No universal German rules.** Weighting, rounding and point conversion are configuration with sensible defaults.
- **Exact vs official.** Show the exact average (e.g. 2,37) separately from a rounded or teacher-assigned grade.
- **Default language is German**, then Turkish and English.