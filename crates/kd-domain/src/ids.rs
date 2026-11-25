//! Typed opaque identifiers for realm aggregates.
use std::fmt;

/// Opaque, globally unique identifiers. Realms, players and aggregates use
/// typed prefixes to make cross-realm / cross-aggregate confusion obvious.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
/// Typed identifier for a realm aggregate.
pub enum Id {
    Realm(String),
    Player(String),
    City(String),
    March(String),
    Alliance(String),
    Event(String),
}

impl Id {
    pub fn new(prefix: &str) -> Self {
        match prefix {
            "realm" => Id::Realm(uuid::Uuid::new_v4().to_string()),
            "player" => Id::Player(uuid::Uuid::new_v4().to_string()),
            "city" => Id::City(uuid::Uuid::new_v4().to_string()),
            "march" => Id::March(uuid::Uuid::new_v4().to_string()),
            "alliance" => Id::Alliance(uuid::Uuid::new_v4().to_string()),
            "event" => Id::Event(uuid::Uuid::new_v4().to_string()),
            _ => panic!("unknown id prefix"),
        }
    }
    pub fn as_str(&self) -> &str {
        match self {
            Id::Realm(s)
            | Id::Player(s)
            | Id::City(s)
            | Id::March(s)
            | Id::Alliance(s)
            | Id::Event(s) => s,
        }
    }
}

impl fmt::Display for Id {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

/// Generate a time-sortable unique id with a random suffix.
pub fn new_id() -> String {
    uuid::Uuid::new_v4().to_string()
}
