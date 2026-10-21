//! Turns two weeks of dated Untis periods into a weekly timetable.

use std::collections::{BTreeMap, BTreeSet};

use chrono::Days;
use melde_core::{Date, LocalTime, Weekday};
use melde_scheduling::WeekParity;

use crate::Period;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DerivedSubject {
    /// Stable key across imports: the Untis short name (e.g. "M").
    pub key: String,
    pub name: String,
    pub short_name: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DerivedLesson {
    pub subject_key: String,
    pub weekday: Weekday,
    pub start: LocalTime,
    pub end: LocalTime,
    pub room: Option<String>,
    pub parity: WeekParity,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DerivedChangeKind {
    Cancelled,
    Substituted {
        subject_key: Option<String>,
        room: Option<String>,
    },
}

/// A change to the regular lesson at this slot on this date.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DerivedChange {
    /// Subject of the regular lesson that is changed.
    pub subject_key: String,
    pub date: Date,
    pub start: LocalTime,
    pub end: LocalTime,
    pub kind: DerivedChangeKind,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct DerivedSchedule {
    pub subjects: Vec<DerivedSubject>,
    pub lessons: Vec<DerivedLesson>,
    pub changes: Vec<DerivedChange>,
    /// Extra periods (irregular, no regular lesson at that time) that were not imported.
    pub skipped_extra: u32,
}

/// `week_a_start`: Monday of the first of the two weeks in `periods`; that
/// week counts as week A when lessons alternate.
pub fn derive_schedule(periods: &[Period], week_a_start: Date) -> DerivedSchedule {
    let week_of = |d: Date| -> Option<usize> {
        let days = (d - week_a_start).num_days();
        match days {
            0..=6 => Some(0),
            7..=13 => Some(1),
            _ => None,
        }
    };
    let key_of = |p: &Period| -> Option<String> {
        let k = if p.subject_short.is_empty() {
            &p.subject_long
        } else {
            &p.subject_short
        };
        (!k.is_empty()).then(|| k.clone())
    };

    // Subjects, by first appearance.
    let mut subjects: Vec<DerivedSubject> = Vec::new();
    for p in periods {
        if let Some(key) = key_of(p)
            && !subjects.iter().any(|s| s.key == key)
        {
            subjects.push(DerivedSubject {
                name: if p.subject_long.is_empty() {
                    key.clone()
                } else {
                    p.subject_long.clone()
                },
                short_name: p.subject_short.clone(),
                key,
            });
        }
    }

    // Regular slots: (weekday, start, end, subject) → weeks seen, rooms seen.
    type Slot = (Weekday, LocalTime, LocalTime, String);
    let mut slots: BTreeMap<Slot, (BTreeSet<usize>, Vec<String>)> = BTreeMap::new();
    // Occupied times per (week, weekday) to tell A/B apart from free periods.
    type Busy = Vec<(LocalTime, LocalTime, String)>;
    let mut occupied: BTreeMap<(usize, Weekday), Busy> = BTreeMap::new();
    for p in periods.iter().filter(|p| !p.irregular) {
        let (Some(key), Some(week)) = (key_of(p), week_of(p.date)) else {
            continue;
        };
        let weekday = Weekday::of(p.date);
        let entry = slots
            .entry((weekday, p.start, p.end, key.clone()))
            .or_default();
        entry.0.insert(week);
        if let Some(room) = &p.room {
            entry.1.push(room.clone());
        }
        occupied
            .entry((week, weekday))
            .or_default()
            .push((p.start, p.end, key));
    }
    let week_has_lessons = |week: usize| occupied.keys().any(|(w, _)| *w == week);

    let mut lessons: Vec<DerivedLesson> = slots
        .into_iter()
        .map(|((weekday, start, end, key), (weeks, rooms))| {
            let parity = if weeks.len() == 2 {
                WeekParity::Every
            } else {
                let seen = *weeks.iter().next().unwrap_or(&0);
                let other = 1 - seen;
                // Only alternating if the other week has lessons and something else in this slot.
                let other_differs = week_has_lessons(other)
                    && occupied.get(&(other, weekday)).is_some_and(|list| {
                        list.iter()
                            .any(|(s, e, k)| *s < end && start < *e && *k != key)
                    });
                match (other_differs, seen) {
                    (false, _) => WeekParity::Every,
                    (true, 0) => WeekParity::A,
                    (true, _) => WeekParity::B,
                }
            };
            DerivedLesson {
                subject_key: key,
                weekday,
                start,
                end,
                room: most_common(rooms),
                parity,
            }
        })
        .collect();
    lessons.sort_by_key(|l| (l.weekday, l.start, l.subject_key.clone()));

    // Changes: cancellations of regular periods, and irregular periods replacing one.
    let mut changes = Vec::new();
    let mut skipped_extra = 0;
    for p in periods {
        let Some(key) = key_of(p) else { continue };
        if p.cancelled && !p.irregular {
            changes.push(DerivedChange {
                subject_key: key,
                date: p.date,
                start: p.start,
                end: p.end,
                kind: DerivedChangeKind::Cancelled,
            });
        } else if p.irregular {
            let weekday = Weekday::of(p.date);
            let replaced = lessons.iter().find(|l| {
                l.weekday == weekday && l.start < p.end && p.start < l.end && l.subject_key != key
                    || (l.weekday == weekday
                        && l.start == p.start
                        && l.subject_key == key
                        && p.room.is_some())
            });
            match replaced {
                Some(lesson) => changes.push(DerivedChange {
                    subject_key: lesson.subject_key.clone(),
                    date: p.date,
                    start: lesson.start,
                    end: lesson.end,
                    kind: DerivedChangeKind::Substituted {
                        subject_key: (key != lesson.subject_key).then_some(key),
                        room: p.room.clone(),
                    },
                }),
                None => skipped_extra += 1,
            }
        }
    }
    // A regular period that is both cancelled and replaced keeps only the substitution.
    let substituted: BTreeSet<(Date, LocalTime, String)> = changes
        .iter()
        .filter(|c| matches!(c.kind, DerivedChangeKind::Substituted { .. }))
        .map(|c| (c.date, c.start, c.subject_key.clone()))
        .collect();
    changes.retain(|c| {
        !(c.kind == DerivedChangeKind::Cancelled
            && substituted.contains(&(c.date, c.start, c.subject_key.clone())))
    });

    DerivedSchedule {
        subjects,
        lessons,
        changes,
        skipped_extra,
    }
}

fn most_common(values: Vec<String>) -> Option<String> {
    let mut counts: BTreeMap<String, usize> = BTreeMap::new();
    for v in values {
        *counts.entry(v).or_default() += 1;
    }
    counts.into_iter().max_by_key(|(_, n)| *n).map(|(v, _)| v)
}

/// Monday of the first week from `from` on that has regular lessons, e.g. the
/// week after the Herbstferien. `None` when the periods contain no lessons.
pub fn first_teaching_week(periods: &[Period], from: Date) -> Option<Date> {
    periods
        .iter()
        .filter(|p| !p.irregular && !p.cancelled && p.date >= from)
        .map(|p| p.date)
        .min()
        .map(monday_of)
}

/// Monday of the week containing `date`.
pub fn monday_of(date: Date) -> Date {
    date - Days::new(u64::from(Weekday::of(date).index()))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn d(day: u32) -> Date {
        Date::from_ymd_opt(2026, 10, day).expect("valid")
    }

    fn t(h: u16, m: u16) -> LocalTime {
        LocalTime::from_hm(h, m).expect("valid")
    }

    fn period(
        id: i64,
        date: Date,
        start: LocalTime,
        end: LocalTime,
        short: &str,
        long: &str,
    ) -> Period {
        Period {
            id,
            date,
            start,
            end,
            subject_short: short.into(),
            subject_long: long.into(),
            room: Some("A1".into()),
            cancelled: false,
            irregular: false,
        }
    }

    /// Two weeks starting Monday 2026-10-19.
    fn two_weeks() -> Vec<Period> {
        vec![
            // Mathe every Monday 08:00.
            period(1, d(19), t(8, 0), t(8, 45), "M", "Mathematik"),
            period(2, d(26), t(8, 0), t(8, 45), "M", "Mathematik"),
            // Physik in week A, Chemie in week B, Monday 10:00.
            period(3, d(19), t(10, 0), t(10, 45), "PH", "Physik"),
            period(4, d(26), t(10, 0), t(10, 45), "CH", "Chemie"),
            // Deutsch Tuesday, only seen in week A, nothing else there in week B: still weekly.
            period(5, d(20), t(9, 0), t(9, 45), "D", "Deutsch"),
            // Some other lesson exists in week B so it is not a holiday week.
            period(6, d(27), t(12, 0), t(12, 45), "SP", "Sport"),
        ]
    }

    #[test]
    fn derives_subjects_and_parity() {
        let s = derive_schedule(&two_weeks(), d(19));
        let keys: Vec<_> = s.subjects.iter().map(|s| s.key.as_str()).collect();
        assert_eq!(keys, ["M", "PH", "CH", "D", "SP"]);
        assert_eq!(s.subjects[0].name, "Mathematik");
        let parity = |key: &str| {
            s.lessons
                .iter()
                .find(|l| l.subject_key == key)
                .map(|l| l.parity)
        };
        assert_eq!(parity("M"), Some(WeekParity::Every));
        assert_eq!(parity("PH"), Some(WeekParity::A));
        assert_eq!(parity("CH"), Some(WeekParity::B));
        assert_eq!(parity("D"), Some(WeekParity::Every));
        // Mathe appears once, not twice.
        assert_eq!(s.lessons.iter().filter(|l| l.subject_key == "M").count(), 1);
        assert_eq!(s.lessons[0].room.as_deref(), Some("A1"));
    }

    #[test]
    fn holiday_week_does_not_create_ab_lessons() {
        // Second week empty (Ferien): everything stays weekly.
        let periods = vec![
            period(1, d(19), t(10, 0), t(10, 45), "PH", "Physik"),
            period(2, d(20), t(10, 0), t(10, 45), "CH", "Chemie"),
        ];
        let s = derive_schedule(&periods, d(19));
        assert!(s.lessons.iter().all(|l| l.parity == WeekParity::Every));
    }

    #[test]
    fn cancellations_and_substitutions_become_changes() {
        let mut periods = two_weeks();
        // Mathe on the 26th is cancelled; Englisch replaces it (irregular).
        periods[1].cancelled = true;
        let mut english = period(7, d(26), t(8, 0), t(8, 45), "E", "Englisch");
        english.irregular = true;
        english.room = Some("B2".into());
        periods.push(english);
        // A Deutsch cancellation without substitute.
        let mut cancelled = period(8, d(27), t(9, 0), t(9, 45), "D", "Deutsch");
        cancelled.cancelled = true;
        periods.push(cancelled);
        // An extra irregular period with no regular lesson at that time.
        let mut extra = period(9, d(28), t(14, 0), t(14, 45), "AG", "Robotik-AG");
        extra.irregular = true;
        periods.push(extra);

        let s = derive_schedule(&periods, d(19));
        assert_eq!(s.skipped_extra, 1);
        assert!(s.changes.contains(&DerivedChange {
            subject_key: "M".into(),
            date: d(26),
            start: t(8, 0),
            end: t(8, 45),
            kind: DerivedChangeKind::Substituted {
                subject_key: Some("E".into()),
                room: Some("B2".into())
            },
        }));
        // The cancelled Mathe is reported only as the substitution.
        assert!(
            !s.changes
                .iter()
                .any(|c| c.subject_key == "M" && c.kind == DerivedChangeKind::Cancelled)
        );
        assert!(
            s.changes
                .iter()
                .any(|c| c.subject_key == "D" && c.kind == DerivedChangeKind::Cancelled)
        );
        // Irregular periods never become regular lessons.
        assert!(
            !s.lessons
                .iter()
                .any(|l| l.subject_key == "E" || l.subject_key == "AG")
        );
    }

    #[test]
    fn monday_of_week() {
        assert_eq!(monday_of(d(22)), d(19));
        assert_eq!(monday_of(d(19)), d(19));
    }

    #[test]
    fn first_teaching_week_skips_holiday_weeks() {
        let mut periods = vec![period(1, d(19), t(8, 0), t(8, 45), "M", "Mathematik")];
        periods[0].cancelled = true;
        assert_eq!(first_teaching_week(&periods, d(19)), None);
        periods.push(period(
            2,
            Date::from_ymd_opt(2026, 11, 4).expect("valid"),
            t(8, 0),
            t(8, 45),
            "M",
            "Mathematik",
        ));
        assert_eq!(
            first_teaching_week(&periods, d(19)),
            Some(Date::from_ymd_opt(2026, 11, 2).expect("valid"))
        );
    }
}
