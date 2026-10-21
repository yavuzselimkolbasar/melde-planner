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
