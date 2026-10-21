//! WebUntis import (ADR-0007).
//!
//! The app does the HTTP calls; this crate builds the JSON-RPC bodies, parses
//! the responses and turns dated Untis periods into Meldo's model: subjects,
//! recurring weekly lessons (with A/B weeks when the two weeks differ) and
//! per-date changes (Ausfall, Vertretung). Everything is pure and testable.

mod derive;
mod rpc;

pub use derive::{
    DerivedChange, DerivedChangeKind, DerivedLesson, DerivedSchedule, DerivedSubject,
    derive_schedule, monday_of,
};
pub use rpc::{
    Auth, Period, School, authenticate_request, logout_request, parse_auth, parse_school_search,
    parse_timetable, school_search_request, timetable_request,
};

/// Errors from Untis responses.
#[derive(Debug, Clone, PartialEq, thiserror::Error)]
pub enum UntisError {
    /// The server answered with a JSON-RPC error (wrong password, no access, …).
    #[error("WebUntis error {code}: {message}")]
    Server { code: i64, message: String },
    #[error("unexpected WebUntis response: {0}")]
    Malformed(String),
}

impl UntisError {
    /// Untis code for wrong user name or password.
    pub const BAD_CREDENTIALS: i64 = -8504;
    /// Untis code for an expired or missing session.
    pub const NOT_AUTHENTICATED: i64 = -8520;
}
