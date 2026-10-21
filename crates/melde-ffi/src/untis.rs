//! WebUntis import exports. The app performs HTTP; Rust builds and parses.

use melde_core::Date;
use melde_scheduling::WeekParity;
use melde_untis as u;

use crate::timetable::FfiWeekParity;
use crate::{FfiDate, FfiWeekday, MeldeError};

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisSchool {
    pub server: String,
    pub login_name: String,
    pub display_name: String,
    pub address: String,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisAuth {
    pub session_id: String,
    pub person_id: i64,
    pub person_type: i64,
    pub klasse_id: Option<i64>,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisSubject {
    pub key: String,
    pub name: String,
    pub short_name: String,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisLesson {
    pub subject_key: String,
    pub weekday: FfiWeekday,
    pub start_minute: u16,
    pub end_minute: u16,
    pub room: Option<String>,
    pub parity: FfiWeekParity,
}

/// One dated period as WebUntis shows it, for the Untis-style timetable.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisPeriod {
    pub id: i64,
    pub date: FfiDate,
    pub start_minute: u16,
    pub end_minute: u16,
    pub subject_short: String,
    pub subject_long: String,
    pub teacher: String,
    pub room: Option<String>,
    /// Planned room when the period moved (Raumänderung).
    pub original_room: Option<String>,
    pub cancelled: bool,
    pub irregular: bool,
    pub exam: bool,
    pub info: Option<String>,
}

/// An absence from the class register.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisAbsence {
    pub id: i64,
    pub first_day: FfiDate,
    pub last_day: FfiDate,
    pub start_minute: u16,
    pub end_minute: u16,
    pub reason: String,
    pub text: String,
    pub excused: bool,
}

/// An exam as WebUntis lists it.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisExam {
    pub id: i64,
    pub date: FfiDate,
    pub start_minute: u16,
    pub end_minute: u16,
    pub subject: String,
    pub name: String,
    pub exam_type: String,
    pub teachers: Vec<String>,
    pub rooms: Vec<String>,
    pub text: String,
}

/// Homework a teacher entered in WebUntis.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisHomework {
    pub id: i64,
    pub subject: String,
    pub given: FfiDate,
    pub due: FfiDate,
    pub text: String,
    pub remark: String,
    pub completed: bool,
}

/// A message of the day from the school, as plain text.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisNews {
    pub id: i64,
    pub subject: String,
    pub text: String,
}

/// One period of the bell schedule; breaks are the gaps between them.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiTimeUnit {
    pub name: String,
    pub start_minute: u16,
    pub end_minute: u16,
}

/// A school holiday from WebUntis, both days inclusive.
#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisHoliday {
    pub name: String,
    pub first_day: FfiDate,
    pub last_day: FfiDate,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Enum)]
pub enum FfiUntisChangeKind {
    Cancelled,
    Substituted {
        subject_key: Option<String>,
        room: Option<String>,
    },
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisChange {
    pub subject_key: String,
    pub date: FfiDate,
    pub start_minute: u16,
    pub end_minute: u16,
    pub kind: FfiUntisChangeKind,
}

#[derive(Debug, Clone, PartialEq, Eq, uniffi::Record)]
pub struct FfiUntisSchedule {
    pub subjects: Vec<FfiUntisSubject>,
    pub lessons: Vec<FfiUntisLesson>,
    pub changes: Vec<FfiUntisChange>,
    pub skipped_extra: u32,
}

#[uniffi::export]
pub fn untis_school_search_request(query: String) -> String {
    u::school_search_request(&query)
}

#[uniffi::export]
pub fn untis_parse_school_search(body: String) -> Result<Vec<FfiUntisSchool>, MeldeError> {
    Ok(u::parse_school_search(&body)?
        .into_iter()
        .map(|s| FfiUntisSchool {
            server: s.server,
            login_name: s.login_name,
            display_name: s.display_name,
            address: s.address,
        })
        .collect())
}

#[uniffi::export]
pub fn untis_authenticate_request(user: String, password: String) -> String {
    u::authenticate_request(&user, &password)
}

#[uniffi::export]
pub fn untis_parse_auth(body: String) -> Result<FfiUntisAuth, MeldeError> {
    let a = u::parse_auth(&body)?;
    Ok(FfiUntisAuth {
        session_id: a.session_id,
        person_id: a.person_id,
        person_type: a.person_type,
        klasse_id: a.klasse_id,
    })
}

/// The logged-in person of a browser (SSO) session, from `/WebUntis/api/app/config`.
#[uniffi::export]
pub fn untis_parse_app_config(
    body: String,
    session_id: String,
) -> Result<FfiUntisAuth, MeldeError> {
    let a = u::parse_app_config(&body, &session_id)?;
    Ok(FfiUntisAuth {
        session_id: a.session_id,
        person_id: a.person_id,
        person_type: a.person_type,
        klasse_id: a.klasse_id,
    })
}

/// Fallback for `untis_parse_app_config`: `/WebUntis/api/rest/view/v1/app/data`.
#[uniffi::export]
pub fn untis_parse_app_data(body: String, session_id: String) -> Result<FfiUntisAuth, MeldeError> {
    let a = u::parse_app_data(&body, &session_id)?;
    Ok(FfiUntisAuth {
        session_id: a.session_id,
        person_id: a.person_id,
        person_type: a.person_type,
        klasse_id: a.klasse_id,
    })
}

#[uniffi::export]
pub fn untis_holidays_request() -> String {
    u::holidays_request()
}

#[uniffi::export]
pub fn untis_parse_holidays(body: String) -> Result<Vec<FfiUntisHoliday>, MeldeError> {
    Ok(u::parse_holidays(&body)?
        .into_iter()
        .map(|h| FfiUntisHoliday {
            name: h.name,
            first_day: h.first.into(),
            last_day: h.last.into(),
        })
        .collect())
}

/// Monday of the first week from `from` on with regular lessons in a
/// `getTimetable` response, or `None` (e.g. only holidays).
#[uniffi::export]
pub fn untis_first_teaching_week(
    timetable_body: String,
    from: FfiDate,
) -> Result<Option<FfiDate>, MeldeError> {
    let periods = u::parse_timetable(&timetable_body)?;
    Ok(u::first_teaching_week(&periods, from.try_into()?).map(Into::into))
}

/// Every dated period of a `getTimetable` response, sorted by time.
#[uniffi::export]
pub fn untis_parse_periods(timetable_body: String) -> Result<Vec<FfiUntisPeriod>, MeldeError> {
    Ok(u::parse_timetable(&timetable_body)?
        .into_iter()
        .map(|p| FfiUntisPeriod {
            id: p.id,
            date: p.date.into(),
            start_minute: p.start.minutes(),
            end_minute: p.end.minutes(),
            subject_short: p.subject_short,
            subject_long: p.subject_long,
            teacher: p.teacher,
            room: p.room,
            original_room: p.original_room,
            cancelled: p.cancelled,
            irregular: p.irregular,
            exam: p.exam,
            info: p.info,
        })
        .collect())
}

#[uniffi::export]
pub fn untis_timegrid_request() -> String {
    u::timegrid_request()
}

#[uniffi::export]
pub fn untis_parse_timegrid(body: String) -> Result<Vec<FfiTimeUnit>, MeldeError> {
    Ok(u::parse_timegrid(&body)?
        .into_iter()
        .map(|t| FfiTimeUnit {
            name: t.name,
            start_minute: t.start.minutes(),
            end_minute: t.end.minutes(),
        })
        .collect())
}

/// `startDate=…&endDate=…` for the WebUntis web API.
#[uniffi::export]
pub fn untis_range_query(first: FfiDate, last: FfiDate) -> Result<String, MeldeError> {
    Ok(u::range_query(first.try_into()?, last.try_into()?))
}

#[uniffi::export]
pub fn untis_parse_absences(body: String) -> Result<Vec<FfiUntisAbsence>, MeldeError> {
    Ok(u::parse_absences(&body)?
        .into_iter()
        .map(|a| FfiUntisAbsence {
            id: a.id,
            first_day: a.first_day.into(),
            last_day: a.last_day.into(),
            start_minute: a.start.minutes(),
            end_minute: a.end.minutes(),
            reason: a.reason,
            text: a.text,
            excused: a.excused,
        })
        .collect())
}

#[uniffi::export]
pub fn untis_parse_exams(body: String) -> Result<Vec<FfiUntisExam>, MeldeError> {
    Ok(u::parse_exams(&body)?
        .into_iter()
        .map(|e| FfiUntisExam {
            id: e.id,
            date: e.date.into(),
            start_minute: e.start.minutes(),
            end_minute: e.end.minutes(),
            subject: e.subject,
            name: e.name,
            exam_type: e.exam_type,
            teachers: e.teachers,
            rooms: e.rooms,
            text: e.text,
        })
        .collect())
}

#[uniffi::export]
pub fn untis_parse_homework(body: String) -> Result<Vec<FfiUntisHomework>, MeldeError> {
    Ok(u::parse_homework(&body)?
        .into_iter()
        .map(|h| FfiUntisHomework {
            id: h.id,
            subject: h.subject,
            given: h.given.into(),
            due: h.due.into(),
            text: h.text,
            remark: h.remark,
            completed: h.completed,
        })
        .collect())
}

#[uniffi::export]
pub fn untis_parse_news(body: String) -> Result<Vec<FfiUntisNews>, MeldeError> {
    Ok(u::parse_news(&body)?
        .into_iter()
        .map(|n| FfiUntisNews {
            id: n.id,
            subject: n.subject,
            text: n.text,
        })
        .collect())
}

#[uniffi::export]
pub fn untis_logout_request() -> String {
    u::logout_request()
}

#[uniffi::export]
pub fn untis_timetable_request(
    person_id: i64,
    person_type: i64,
    first: FfiDate,
    last: FfiDate,
) -> Result<String, MeldeError> {
    Ok(u::timetable_request(
        person_id,
        person_type,
        first.try_into()?,
        last.try_into()?,
    ))
}

/// Monday of the week containing `date`; the import fetches that week and the next.
#[uniffi::export]
pub fn untis_week_start(date: FfiDate) -> Result<FfiDate, MeldeError> {
    Ok(u::monday_of(Date::try_from(date)?).into())
}

/// Parses a `getTimetable` response covering two weeks (the first being week A)
/// and derives subjects, weekly lessons and per-date changes.
#[uniffi::export]
pub fn untis_derive_schedule(
    timetable_body: String,
    week_a_start: FfiDate,
) -> Result<FfiUntisSchedule, MeldeError> {
    let periods = u::parse_timetable(&timetable_body)?;
    let s = u::derive_schedule(&periods, week_a_start.try_into()?);
    Ok(FfiUntisSchedule {
        subjects: s
            .subjects
            .into_iter()
            .map(|s| FfiUntisSubject {
                key: s.key,
                name: s.name,
                short_name: s.short_name,
            })
            .collect(),
        lessons: s
            .lessons
            .into_iter()
            .map(|l| FfiUntisLesson {
                subject_key: l.subject_key,
                weekday: l.weekday.into(),
                start_minute: l.start.minutes(),
                end_minute: l.end.minutes(),
                room: l.room,
                parity: match l.parity {
                    WeekParity::Every => FfiWeekParity::Every,
                    WeekParity::A => FfiWeekParity::A,
                    WeekParity::B => FfiWeekParity::B,
                },
            })
            .collect(),
        changes: s
            .changes
            .into_iter()
            .map(|c| FfiUntisChange {
                subject_key: c.subject_key,
                date: c.date.into(),
                start_minute: c.start.minutes(),
                end_minute: c.end.minutes(),
                kind: match c.kind {
                    u::DerivedChangeKind::Cancelled => FfiUntisChangeKind::Cancelled,
                    u::DerivedChangeKind::Substituted { subject_key, room } => {
                        FfiUntisChangeKind::Substituted { subject_key, room }
                    }
                },
            })
            .collect(),
        skipped_extra: s.skipped_extra,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn wrong_password_is_a_typed_error() {
        let body =
            r#"{"jsonrpc":"2.0","id":"meldo","error":{"message":"bad credentials","code":-8504}}"#
                .to_owned();
        assert!(matches!(
            untis_parse_auth(body),
            Err(MeldeError::UntisServer { code: -8504, .. })
        ));
        assert!(matches!(
            untis_parse_auth("<html>".into()),
            Err(MeldeError::UntisMalformed { .. })
        ));
    }

    #[test]
    fn derives_schedule_across_the_boundary() {
        let body = r#"{"jsonrpc":"2.0","id":"meldo","result":[
            {"id":1,"date":20261019,"startTime":800,"endTime":845,"su":[{"id":2,"name":"M","longname":"Mathematik"}],"ro":[{"id":1,"name":"A1"}]},
            {"id":2,"date":20261026,"startTime":800,"endTime":845,"su":[{"id":2,"name":"M","longname":"Mathematik"}],"ro":[{"id":1,"name":"A1"}],"code":"cancelled"}
        ]}"#
        .to_owned();
        let monday = FfiDate {
            year: 2026,
            month: 10,
            day: 19,
        };
        let s = untis_derive_schedule(body, monday).expect("valid");
        assert_eq!(s.subjects.len(), 1);
        assert_eq!(s.lessons.len(), 1);
        assert_eq!(s.lessons[0].start_minute, 480);
        assert_eq!(s.lessons[0].parity, FfiWeekParity::Every);
        assert_eq!(s.changes.len(), 1);
        assert_eq!(s.changes[0].kind, FfiUntisChangeKind::Cancelled);
        assert_eq!(
            untis_week_start(FfiDate {
                year: 2026,
                month: 10,
                day: 22
            })
            .expect("valid"),
            monday
        );
    }
}
