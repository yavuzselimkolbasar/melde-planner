//! The WebUntis web API (`/WebUntis/api/…`) for what JSON-RPC doesn't offer:
//! absences, exams, homework and the school's messages of the day. The app
//! sends GET requests with the session cookie; this module parses the
//! `{ "data": … }` answers. A logged-out session gets HTML, which is an error.

use serde::Deserialize;
use serde::de::DeserializeOwned;
use serde_json::Value;

use melde_core::{Date, LocalTime};

use crate::UntisError;
use crate::rpc::{parse_date, parse_time, untis_date};

/// Query string for a date range, e.g. `startDate=20261102&endDate=20261227`.
pub fn range_query(first: Date, last: Date) -> String {
    format!(
        "startDate={}&endDate={}",
        untis_date(first),
        untis_date(last)
    )
}

/// An absence from the class register.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Absence {
    pub id: i64,
    pub first_day: Date,
    pub last_day: Date,
    pub start: LocalTime,
    pub end: LocalTime,
    /// "ärztliches Attest", "Zugausfall", …; may be empty.
    pub reason: String,
    pub text: String,
    pub excused: bool,
}

/// An exam (Klausur, Test) as WebUntis lists it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Exam {
    pub id: i64,
    pub date: Date,
    pub start: LocalTime,
    pub end: LocalTime,
    pub subject: String,
    /// The exam's name, e.g. "1. Klausur".
    pub name: String,
    pub exam_type: String,
    pub teachers: Vec<String>,
    pub rooms: Vec<String>,
    pub text: String,
}

/// Homework a teacher entered in WebUntis.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Homework {
    pub id: i64,
    /// Subject name of the lesson the homework belongs to; may be empty.
    pub subject: String,
    pub given: Date,
    pub due: Date,
    pub text: String,
    pub remark: String,
    pub completed: bool,
}

/// A message of the day from the school.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct NewsMessage {
    pub id: i64,
    pub subject: String,
    /// Plain text; HTML tags removed.
    pub text: String,
}

fn data<T: DeserializeOwned>(body: &str) -> Result<T, UntisError> {
    #[derive(Deserialize)]
    struct Envelope<T> {
        data: T,
    }
    let envelope: Envelope<T> =
        serde_json::from_str(body).map_err(|e| UntisError::Malformed(e.to_string()))?;
    Ok(envelope.data)
}

pub fn parse_absences(body: &str) -> Result<Vec<Absence>, UntisError> {
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        id: i64,
        start_date: i64,
        end_date: i64,
        start_time: i64,
        end_time: i64,
        #[serde(default)]
        reason: String,
        #[serde(default)]
        text: String,
        #[serde(default)]
        is_excused: bool,
    }
    #[derive(Deserialize)]
    struct Data {
        #[serde(default)]
        absences: Vec<Raw>,
    }
    let d: Data = data(body)?;
    let mut list: Vec<Absence> = d
        .absences
        .into_iter()
        .filter_map(|a| {
            Some(Absence {
                id: a.id,
                first_day: parse_date(a.start_date)?,
                last_day: parse_date(a.end_date)?,
                start: parse_time(a.start_time)?,
                end: parse_time(a.end_time)?,
                reason: a.reason,
                text: a.text,
                excused: a.is_excused,
            })
        })
        .collect();
    list.sort_by_key(|a| std::cmp::Reverse((a.first_day, a.start)));
    Ok(list)
}

/// Path and query of the REST timetable (`/WebUntis/api/rest/view/v1/timetable/entries`)
/// for one student, which the WebUntis web app uses. Needs the session's JWT as
/// `Authorization: Bearer …`.
pub fn timetable_entries_query(person_id: i64, first: Date, last: Date) -> String {
    format!(
        "/WebUntis/api/rest/view/v1/timetable/entries?start={first}&end={last}&format=4\
         &resourceType=STUDENT&resources={person_id}&periodTypes=&timetableType=MY_TIMETABLE",
        first = first.format("%Y-%m-%d"),
        last = last.format("%Y-%m-%d"),
    )
}

/// Exams from the REST timetable (entries of type `EXAM`). Some schools refuse
/// `/api/exams` to students (403) but still mark exams in the timetable, which
/// is what the Untis apps show.
pub fn parse_timetable_exams(body: &str) -> Result<Vec<Exam>, UntisError> {
    let v: Value = serde_json::from_str(body).map_err(|e| UntisError::Malformed(e.to_string()))?;
    let days = v
        .get("days")
        .and_then(Value::as_array)
        .ok_or_else(|| UntisError::Malformed("no days".to_owned()))?;
    let text = |e: &Value, key: &str| e.get(key).and_then(Value::as_str).unwrap_or("").to_owned();
    let mut list = Vec::new();
    for entry in days
        .iter()
        .filter_map(|d| d.get("gridEntries").and_then(Value::as_array))
        .flatten()
    {
        if entry.get("type").and_then(Value::as_str) != Some("EXAM")
            || entry.get("status").and_then(Value::as_str) == Some("CANCELLED")
        {
            continue;
        }
        let Some((date, start, end)) = entry.get("duration").and_then(parse_duration) else {
            continue;
        };
        let (mut subject, mut teachers, mut rooms) = (String::new(), Vec::new(), Vec::new());
        for slot in
            (1..=7).filter_map(|i| entry.get(format!("position{i}")).and_then(Value::as_array))
        {
            for current in slot.iter().filter_map(|p| p.get("current")) {
                let short = text(current, "shortName");
                match current.get("type").and_then(Value::as_str) {
                    Some("SUBJECT") if subject.is_empty() => subject = short,
                    Some("TEACHER") => teachers.push(short),
                    Some("ROOM") => rooms.push(short),
                    _ => {}
                }
            }
        }
        let name = [
            text(entry, "name"),
            text(entry, "lessonInfo"),
            text(entry, "lessonText"),
        ]
        .into_iter()
        .find(|t| !t.is_empty())
        .unwrap_or_default();
        list.push(Exam {
            id: entry
                .get("ids")
                .and_then(Value::as_array)
                .and_then(|ids| ids.first())
                .and_then(Value::as_i64)
                .unwrap_or(0),
            date,
            start,
            end,
            subject,
            name,
            exam_type: String::new(),
            teachers,
            rooms,
            text: text(entry, "notesAll"),
        });
    }
    list.sort_by_key(|e| (e.date, e.start));
    Ok(list)
}

/// `{"start":"2026-11-02T11:25","end":"2026-11-02T12:55"}` → day, start, end.
fn parse_duration(d: &Value) -> Option<(Date, LocalTime, LocalTime)> {
    let at = |key: &str| {
        chrono::NaiveDateTime::parse_from_str(d.get(key)?.as_str()?, "%Y-%m-%dT%H:%M").ok()
    };
    let (start, end) = (at("start")?, at("end")?);
    let time = |t: chrono::NaiveDateTime| {
        use chrono::Timelike;
        LocalTime::from_hm(
            u16::try_from(t.hour()).ok()?,
            u16::try_from(t.minute()).ok()?,
        )
        .ok()
    };
    Some((start.date(), time(start)?, time(end)?))
}

pub fn parse_exams(body: &str) -> Result<Vec<Exam>, UntisError> {
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        id: i64,
        exam_date: i64,
        start_time: i64,
        end_time: i64,
        #[serde(default)]
        subject: String,
        #[serde(default)]
        name: String,
        #[serde(default)]
        exam_type: String,
        #[serde(default)]
        teachers: Vec<String>,
        #[serde(default)]
        rooms: Vec<String>,
        #[serde(default)]
        text: String,
    }
    #[derive(Deserialize)]
    struct Data {
        #[serde(default)]
        exams: Vec<Raw>,
    }
    let d: Data = data(body)?;
    let mut list: Vec<Exam> = d
        .exams
        .into_iter()
        .filter_map(|e| {
            Some(Exam {
                id: e.id,
                date: parse_date(e.exam_date)?,
                start: parse_time(e.start_time)?,
                end: parse_time(e.end_time)?,
                subject: e.subject,
                name: e.name,
                exam_type: e.exam_type,
                teachers: e.teachers,
                rooms: e.rooms,
                text: e.text,
            })
        })
        .collect();
    list.sort_by_key(|e| (e.date, e.start));
    Ok(list)
}

pub fn parse_homework(body: &str) -> Result<Vec<Homework>, UntisError> {
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        id: i64,
        #[serde(default)]
        lesson_id: i64,
        date: i64,
        due_date: i64,
        #[serde(default)]
        text: String,
        #[serde(default)]
        remark: String,
        #[serde(default)]
        completed: bool,
    }
    #[derive(Deserialize)]
    struct Lesson {
        id: i64,
        #[serde(default)]
        subject: String,
    }
    #[derive(Deserialize)]
    struct Data {
        #[serde(default)]
        homeworks: Vec<Raw>,
        #[serde(default)]
        lessons: Vec<Lesson>,
    }
    let d: Data = data(body)?;
    let mut list: Vec<Homework> = d
        .homeworks
        .into_iter()
        .filter_map(|h| {
            Some(Homework {
                id: h.id,
                subject: d
                    .lessons
                    .iter()
                    .find(|l| l.id == h.lesson_id)
                    .map(|l| l.subject.clone())
                    .unwrap_or_default(),
                given: parse_date(h.date)?,
                due: parse_date(h.due_date)?,
                text: h.text.trim().to_owned(),
                remark: h.remark.trim().to_owned(),
                completed: h.completed,
            })
        })
        .collect();
    list.sort_by_key(|h| h.due);
    Ok(list)
}

pub fn parse_news(body: &str) -> Result<Vec<NewsMessage>, UntisError> {
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        id: i64,
        #[serde(default)]
        subject: String,
        #[serde(default)]
        text: String,
    }
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Data {
        #[serde(default)]
        messages_of_day: Vec<Raw>,
    }
    let d: Data = data(body)?;
    Ok(d.messages_of_day
        .into_iter()
        .map(|m| NewsMessage {
            id: m.id,
            subject: strip_html(&m.subject),
            text: strip_html(&m.text),
        })
        .filter(|m| !m.subject.is_empty() || !m.text.is_empty())
        .collect())
}

/// Plain text from the small HTML WebUntis uses in messages: tags removed,
/// line breaks kept, common entities decoded.
fn strip_html(html: &str) -> String {
    let with_breaks = html
        .replace("<br>", "\n")
        .replace("<br/>", "\n")
        .replace("<br />", "\n")
        .replace("</p>", "\n");
    let mut out = String::with_capacity(with_breaks.len());
    let mut in_tag = false;
    for c in with_breaks.chars() {
        match c {
            '<' => in_tag = true,
            '>' => in_tag = false,
            _ if !in_tag => out.push(c),
            _ => {}
        }
    }
    let decoded = out
        .replace("&nbsp;", " ")
        .replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", "\"")
        .replace("&#39;", "'");
    decoded
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty())
        .collect::<Vec<_>>()
        .join("\n")
}

/// Whether a web-API answer is the login page instead of data.
pub fn is_logged_out(body: &str) -> bool {
    serde_json::from_str::<Value>(body).is_err()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn day(y: i32, m: u32, d: u32) -> Date {
        Date::from_ymd_opt(y, m, d).expect("valid")
    }

    #[test]
    fn range_query_uses_untis_dates() {
        assert_eq!(
            range_query(day(2026, 11, 2), day(2026, 12, 27)),
            "startDate=20261102&endDate=20261227"
        );
    }

    #[test]
    fn parses_absences_newest_first() {
        let body = r#"{"data":{"absences":[
            {"id":1,"startDate":20260924,"endDate":20260924,"startTime":935,"endTime":1445,"reason":"ärztliches Attest","text":"","isExcused":true},
            {"id":2,"startDate":20260929,"endDate":20260929,"startTime":935,"endTime":950,"reason":"","text":"","isExcused":false}
        ],"absenceReasons":[]}}"#;
        let list = parse_absences(body).expect("valid");
        assert_eq!(list.len(), 2);
        assert_eq!(list[0].id, 2);
        assert!(!list[0].excused);
        assert_eq!(list[1].reason, "ärztliches Attest");
    }

    #[test]
    fn timetable_entries_query_uses_iso_dates() {
        assert_eq!(
            timetable_entries_query(32846, day(2026, 11, 2), day(2026, 11, 6)),
            "/WebUntis/api/rest/view/v1/timetable/entries?start=2026-11-02&end=2026-11-06&format=4\
             &resourceType=STUDENT&resources=32846&periodTypes=&timetableType=MY_TIMETABLE"
        );
    }

    #[test]
    fn reads_exams_from_the_rest_timetable() {
        // Shape of a real answer (trimmed): one lesson, one exam with a room change, one cancelled exam.
        let body = r#"{"format":1,"days":[{"date":"2026-11-02","gridEntries":[
            {"ids":[3200422],"duration":{"start":"2026-11-02T09:35","end":"2026-11-02T11:05"},"type":"NORMAL_TEACHING_PERIOD","status":"REGULAR",
             "position2":[{"current":{"type":"SUBJECT","shortName":"DEU"}}]},
            {"ids":[3250574,3250577],"duration":{"start":"2026-11-02T11:25","end":"2026-11-02T12:55"},"type":"EXAM","status":"CHANGED","name":null,"notesAll":"",
             "position1":[{"current":{"type":"TEACHER","shortName":"SW"},"removed":null}],
             "position2":[{"current":{"type":"SUBJECT","shortName":"MAT"},"removed":null}],
             "position3":[{"current":{"type":"ROOM","status":"ADDED","shortName":"A108"},"removed":{"type":"ROOM","shortName":"B111"}}],
             "lessonInfo":"Kla MAT 11.1.1","lessonText":""}]},
            {"date":"2026-11-05","gridEntries":[
            {"ids":[9],"duration":{"start":"2026-11-05T13:15","end":"2026-11-05T14:45"},"type":"EXAM","status":"CANCELLED",
             "position2":[{"current":{"type":"SUBJECT","shortName":"PHY"}}]}]}]}"#;
        let exams = parse_timetable_exams(body).expect("valid");
        assert_eq!(exams.len(), 1);
        let e = &exams[0];
        assert_eq!((e.id, e.date), (3250574, day(2026, 11, 2)));
        assert_eq!(
            (e.start, e.end),
            (
                LocalTime::from_hm(11, 25).expect("valid"),
                LocalTime::from_hm(12, 55).expect("valid")
            )
        );
        assert_eq!(e.subject, "MAT");
        assert_eq!(e.name, "Kla MAT 11.1.1");
        assert_eq!(e.teachers, vec!["SW".to_owned()]);
        assert_eq!(e.rooms, vec!["A108".to_owned()]);
    }

    #[test]
    fn rest_timetable_rejects_html() {
        assert!(parse_timetable_exams("<!DOCTYPE html><html>").is_err());
    }

    #[test]
    fn parses_exams_by_date() {
        let body = r#"{"data":{"exams":[
            {"id":5,"examType":"Klausur","name":"1. Klausur","examDate":20261110,"startTime":1125,"endTime":1255,
             "subject":"MAT","teachers":["SW"],"rooms":["A108"],"text":"Kapitel 1–3"}
        ]}}"#;
        let exams = parse_exams(body).expect("valid");
        assert_eq!(exams[0].subject, "MAT");
        assert_eq!(exams[0].date, day(2026, 11, 10));
        assert_eq!(exams[0].rooms, vec!["A108".to_owned()]);
    }

    #[test]
    fn parses_homework_with_lesson_subjects() {
        let body = r#"{"data":{"homeworks":[
            {"id":9,"lessonId":3,"date":20261102,"dueDate":20261109,"text":" Inhaltsangabe ","remark":"","completed":false,"attachments":[]}
        ],"lessons":[{"id":3,"subject":"DEU","lessonType":"Unterricht"}]}}"#;
        let list = parse_homework(body).expect("valid");
        assert_eq!(list[0].subject, "DEU");
        assert_eq!(list[0].text, "Inhaltsangabe");
        assert_eq!(list[0].due, day(2026, 11, 9));
    }

    #[test]
    fn parses_news_as_plain_text() {
        let body = r#"{"data":{"messagesOfDay":[
            {"id":1,"subject":"<b>Wandertag</b>","text":"Treffpunkt&nbsp;8 Uhr<br>am Haupteingang","isExpanded":true}
        ]}}"#;
        let news = parse_news(body).expect("valid");
        assert_eq!(news[0].subject, "Wandertag");
        assert_eq!(news[0].text, "Treffpunkt 8 Uhr\nam Haupteingang");
    }

    #[test]
    fn login_page_is_an_error() {
        assert!(parse_exams("<!DOCTYPE html><html>").is_err());
        assert!(is_logged_out("<html>"));
    }
}
