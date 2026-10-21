//! JSON-RPC request bodies and response parsing.

use serde::Deserialize;
use serde_json::{Value, json};

use melde_core::{Date, LocalTime};

use crate::UntisError;

/// Client name sent to Untis, so schools can see which app connects.
const CLIENT: &str = "Meldo";

/// A school from the Untis school search.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct School {
    /// Host of the school's WebUntis server, e.g. `nessa.webuntis.com`.
    pub server: String,
    /// The `school` query parameter for that server.
    pub login_name: String,
    pub display_name: String,
    pub address: String,
}

/// Result of a successful login.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Auth {
    pub session_id: String,
    pub person_id: i64,
    /// 5 = student, 2 = teacher, 12 = parent (Untis element types).
    pub person_type: i64,
    pub klasse_id: Option<i64>,
}

/// One dated period from `getTimetable`.
#[derive(Debug, Clone, PartialEq)]
pub struct Period {
    pub id: i64,
    pub date: Date,
    pub start: LocalTime,
    pub end: LocalTime,
    /// Short subject name (e.g. "M"); empty for events without a subject.
    pub subject_short: String,
    pub subject_long: String,
    pub room: Option<String>,
    pub cancelled: bool,
    /// Vertretung or extra period ("irregular" in Untis).
    pub irregular: bool,
}

fn rpc(method: &str, params: Value) -> String {
    json!({ "id": "meldo", "method": method, "params": params, "jsonrpc": "2.0" }).to_string()
}

/// Body for `POST https://mobile.webuntis.com/ms/schoolquery2`.
pub fn school_search_request(query: &str) -> String {
    rpc("searchSchool", json!([{ "search": query }]))
}

/// Body for `POST https://<server>/WebUntis/jsonrpc.do?school=<login_name>`.
pub fn authenticate_request(user: &str, password: &str) -> String {
    rpc(
        "authenticate",
        json!({ "user": user, "password": password, "client": CLIENT }),
    )
}

pub fn logout_request() -> String {
    rpc("logout", json!({}))
}

/// Timetable of one person for `first..=last` (send with the session cookie).
pub fn timetable_request(person_id: i64, person_type: i64, first: Date, last: Date) -> String {
    rpc(
        "getTimetable",
        json!({ "options": {
            "element": { "id": person_id, "type": person_type },
            "startDate": untis_date(first),
            "endDate": untis_date(last),
            "subjectFields": ["id", "name", "longname"],
            "roomFields": ["id", "name"],
        }}),
    )
}

fn untis_date(d: Date) -> i64 {
    use chrono::Datelike;
    i64::from(d.year()) * 10_000 + i64::from(d.month()) * 100 + i64::from(d.day())
}

fn parse_date(v: i64) -> Option<Date> {
    let (y, m, d) = (v / 10_000, (v / 100) % 100, v % 100);
    Date::from_ymd_opt(
        i32::try_from(y).ok()?,
        u32::try_from(m).ok()?,
        u32::try_from(d).ok()?,
    )
}

/// Untis times are `hhmm` integers (`745` = 07:45).
fn parse_time(v: i64) -> Option<LocalTime> {
    LocalTime::from_hm(u16::try_from(v / 100).ok()?, u16::try_from(v % 100).ok()?).ok()
}

/// Extracts `result` or turns a JSON-RPC `error` into `UntisError::Server`.
fn result(body: &str) -> Result<Value, UntisError> {
    let v: Value = serde_json::from_str(body).map_err(|e| UntisError::Malformed(e.to_string()))?;
    if let Some(err) = v.get("error").filter(|e| !e.is_null()) {
        return Err(UntisError::Server {
            code: err.get("code").and_then(Value::as_i64).unwrap_or(0),
            message: err
                .get("message")
                .and_then(Value::as_str)
                .unwrap_or("")
                .to_owned(),
        });
    }
    v.get("result")
        .cloned()
        .ok_or_else(|| UntisError::Malformed("missing result".into()))
}

pub fn parse_school_search(body: &str) -> Result<Vec<School>, UntisError> {
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        server: String,
        login_name: String,
        display_name: String,
        #[serde(default)]
        address: String,
    }
    #[derive(Deserialize)]
    struct Schools {
        #[serde(default)]
        schools: Vec<Raw>,
    }
    let raw: Schools =
        serde_json::from_value(result(body)?).map_err(|e| UntisError::Malformed(e.to_string()))?;
    Ok(raw
        .schools
        .into_iter()
        .map(|s| School {
            server: s.server,
            login_name: s.login_name,
            display_name: s.display_name,
            address: s.address,
        })
        .collect())
}

pub fn parse_auth(body: &str) -> Result<Auth, UntisError> {
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        session_id: String,
        person_id: i64,
        person_type: i64,
        klasse_id: Option<i64>,
    }
    let raw: Raw =
        serde_json::from_value(result(body)?).map_err(|e| UntisError::Malformed(e.to_string()))?;
    Ok(Auth {
        session_id: raw.session_id,
        person_id: raw.person_id,
        person_type: raw.person_type,
        klasse_id: raw.klasse_id,
    })
}

/// The logged-in person from `GET /WebUntis/api/app/config`, for sessions that
/// started in the browser (school SSO such as Microsoft 365) instead of
/// `authenticate`. `session_id` is the browser's `JSESSIONID` cookie.
pub fn parse_app_config(body: &str, session_id: &str) -> Result<Auth, UntisError> {
    #[derive(Deserialize)]
    struct Person {
        id: i64,
        #[serde(rename = "type")]
        kind: i64,
    }
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct User {
        person_id: Option<i64>,
        #[serde(default)]
        persons: Vec<Person>,
    }
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct LoginServiceConfig {
        user: Option<User>,
    }
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Data {
        login_service_config: Option<LoginServiceConfig>,
    }
    #[derive(Deserialize)]
    struct Envelope {
        data: Data,
    }
    // A logged-out session gets the login page (HTML) instead of JSON.
    let envelope: Envelope =
        serde_json::from_str(body).map_err(|e| UntisError::Malformed(e.to_string()))?;
    let user = envelope
        .data
        .login_service_config
        .and_then(|c| c.user)
        .ok_or_else(|| UntisError::Malformed("not logged in".into()))?;
    let person_id = user
        .person_id
        .ok_or_else(|| UntisError::Malformed("no person".into()))?;
    let person = user
        .persons
        .iter()
        .find(|p| p.id == person_id)
        .ok_or_else(|| UntisError::Malformed("person not listed".into()))?;
    Ok(Auth {
        session_id: session_id.to_owned(),
        person_id,
        person_type: person.kind,
        klasse_id: None,
    })
}

pub fn parse_timetable(body: &str) -> Result<Vec<Period>, UntisError> {
    #[derive(Deserialize)]
    struct Named {
        #[serde(default)]
        name: String,
        #[serde(default)]
        longname: String,
    }
    #[derive(Deserialize)]
    #[serde(rename_all = "camelCase")]
    struct Raw {
        id: i64,
        date: i64,
        start_time: i64,
        end_time: i64,
        #[serde(default)]
        su: Vec<Named>,
        #[serde(default)]
        ro: Vec<Named>,
        #[serde(default)]
        code: Option<String>,
    }
    let raw: Vec<Raw> =
        serde_json::from_value(result(body)?).map_err(|e| UntisError::Malformed(e.to_string()))?;
    let mut periods: Vec<Period> = raw
        .into_iter()
        .filter_map(|p| {
            let subject = p.su.first();
            Some(Period {
                id: p.id,
                date: parse_date(p.date)?,
                start: parse_time(p.start_time)?,
                end: parse_time(p.end_time)?,
                subject_short: subject.map(|s| s.name.clone()).unwrap_or_default(),
                subject_long: subject.map(|s| s.longname.clone()).unwrap_or_default(),
                room: p
                    .ro
                    .first()
                    .map(|r| r.name.clone())
                    .filter(|r| !r.is_empty()),
                cancelled: p.code.as_deref() == Some("cancelled"),
                irregular: p.code.as_deref() == Some("irregular"),
            })
        })
        .collect();
    periods.sort_by_key(|p| (p.date, p.start));
    Ok(periods)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn requests_are_jsonrpc() {
        let v: Value = serde_json::from_str(&authenticate_request("max", "geheim")).expect("json");
        assert_eq!(v["method"], "authenticate");
        assert_eq!(v["params"]["user"], "max");
        assert_eq!(v["params"]["client"], "Meldo");
        let first = Date::from_ymd_opt(2026, 10, 19).expect("date");
        let last = Date::from_ymd_opt(2026, 11, 1).expect("date");
        let v: Value = serde_json::from_str(&timetable_request(42, 5, first, last)).expect("json");
        assert_eq!(v["params"]["options"]["startDate"], 20261019);
        assert_eq!(v["params"]["options"]["endDate"], 20261101);
        assert_eq!(v["params"]["options"]["element"]["type"], 5);
    }

    #[test]
    fn parses_auth_and_server_errors() {
        let ok = r#"{"jsonrpc":"2.0","id":"meldo","result":{"sessionId":"ABC","personType":5,"personId":123,"klasseId":71}}"#;
        assert_eq!(
            parse_auth(ok),
            Ok(Auth {
                session_id: "ABC".into(),
                person_id: 123,
                person_type: 5,
                klasse_id: Some(71)
            })
        );
        let bad =
            r#"{"jsonrpc":"2.0","id":"meldo","error":{"message":"bad credentials","code":-8504}}"#;
        assert_eq!(
            parse_auth(bad),
            Err(UntisError::Server {
                code: UntisError::BAD_CREDENTIALS,
                message: "bad credentials".into()
            })
        );
        assert!(matches!(
            parse_auth("<html>"),
            Err(UntisError::Malformed(_))
        ));
    }

    #[test]
    fn parses_school_search() {
        let body = r#"{"id":"meldo","result":{"size":1,"schools":[{"server":"nessa.webuntis.com","useMobileServiceUrlAndroid":true,"address":"Musterstr. 1, Köln","displayName":"Gymnasium Musterstadt","loginName":"gym-muster","schoolId":123,"serverUrl":"https://nessa.webuntis.com/WebUntis/?school=gym-muster"}]},"jsonrpc":"2.0"}"#;
        let schools = parse_school_search(body).expect("valid");
        assert_eq!(schools.len(), 1);
        assert_eq!(schools[0].server, "nessa.webuntis.com");
        assert_eq!(schools[0].login_name, "gym-muster");
    }

    /// Real response shape from mobile.webuntis.com (2026-10-21), including fields we ignore.
    #[test]
    fn parses_live_school_search_shape() {
        let body = r#"{"result":{"size":0,"schools":[{"server":"gym-koeln-pesch.webuntis.com","useMobileServiceUrlAndroid":false,"address":"50767, Köln, Schulstr. 18","displayName":"Gymnasium Köln-Pesch","loginName":"gym-koeln-pesch","schoolId":6524200,"useMobileServiceUrlIos":false,"serverUrl":"https:\/\/gym-koeln-pesch.webuntis.com\/WebUntis\/?school=gym-koeln-pesch","tenantId":"6524200","mobileServiceUrl":null}]},"id":"meldo","jsonrpc":"2.0"}"#;
        let schools = parse_school_search(body).expect("valid");
        assert_eq!(schools[0].server, "gym-koeln-pesch.webuntis.com");
        assert_eq!(schools[0].login_name, "gym-koeln-pesch");
        assert_eq!(schools[0].display_name, "Gymnasium Köln-Pesch");
    }

    #[test]
    fn parses_timetable_periods() {
        let body = r#"{"jsonrpc":"2.0","id":"meldo","result":[
            {"id":2,"date":20261019,"startTime":850,"endTime":935,"su":[{"id":3,"name":"D","longname":"Deutsch"}],"ro":[{"id":1,"name":"A12"}]},
            {"id":1,"date":20261019,"startTime":800,"endTime":845,"su":[{"id":2,"name":"M","longname":"Mathematik"}],"ro":[],"code":"cancelled"},
            {"id":3,"date":20261019,"startTime":2500,"endTime":2600,"su":[]}
        ]}"#;
        let periods = parse_timetable(body).expect("valid");
        // Invalid time (25:00) is dropped; result sorted by time.
        assert_eq!(periods.len(), 2);
        assert_eq!(periods[0].subject_short, "M");
        assert!(periods[0].cancelled);
        assert_eq!(periods[1].room.as_deref(), Some("A12"));
        assert_eq!(periods[1].start, LocalTime::from_hm(8, 50).expect("time"));
    }

    #[test]
    fn parses_app_config_of_a_browser_session() {
        let body = r#"{"data":{"loginServiceConfig":{"user":{"personId":4711,"name":"max.muster",
            "persons":[{"id":12,"type":12,"displayName":"Elternteil"},{"id":4711,"type":5,"displayName":"Max Muster"}]}}}}"#;
        let auth = parse_app_config(body, "ABC123").expect("logged in");
        assert_eq!(auth.person_id, 4711);
        assert_eq!(auth.person_type, 5);
        assert_eq!(auth.session_id, "ABC123");
    }

    #[test]
    fn app_config_without_user_means_logged_out() {
        assert!(matches!(
            parse_app_config(r#"{"data":{"loginServiceConfig":{"user":null}}}"#, "x"),
            Err(UntisError::Malformed(_))
        ));
        assert!(matches!(
            parse_app_config("<!DOCTYPE html>", "x"),
            Err(UntisError::Malformed(_))
        ));
    }
}
