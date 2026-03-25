// src/crates/lament_sandbox/src/types.rs - rich system configuration types
//
//     Copyright (C) 2026  Kıvılcım İpek Afet Öztürk
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

use std::collections::HashMap;
use chrono::{DateTime, Utc, Duration};
use mlua::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct HiveRef {
    pub name: String,
    pub registrar: String,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct PermissionTriplet {
    pub read: bool,
    pub write: bool,
    pub execute: Option<ExecuteMode>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum ExecuteMode {
    Regular,
    Suid,   // represents mode "s"
    Sticky, // represents mode "t"
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub struct Version {
    pub major: u64,
    pub minor: u64,
    pub build: Option<u64>,
    pub edit: Option<u64>,
}

impl std::fmt::Display for PermissionTriplet {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let r = if self.read { "r" } else { "-" };
        let w = if self.write { "w" } else { "-" };
        let x = match self.execute {
            Some(ExecuteMode::Regular) => "x",
            Some(ExecuteMode::Suid) => "s",
            Some(ExecuteMode::Sticky) => "t",
            None => "-",
        };
        write!(f, "{}{}{}", r, w, x)
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Value {
    Nil,
    Boolean(bool),
    String(String),
    Integer(i128),
    Natural(u128),
    Float(f64),
    List(Vec<Value>),
    Path(String),
    KeyMap(HashMap<String, Value>),
    User {
        uid: usize,
        name: String,
    },
    Group {
        gid: usize,
        name: String,
    },
    Permission {
        owner: PermissionTriplet,
        group: PermissionTriplet,
        other: PermissionTriplet,
    },
    Package(String),
    Version(Version),
    Range {
        start: i128,
        end: i128,
        step: Option<i128>,
        include_right: bool,
    },
    VersionRange {
        min: Version,
        max: Version,
    },
    Service {
        name: String,
    },
    Command {
        program: String,
        args: Vec<String>,
    },
    EnvVar {
        name: String,
        value: String,
    },
    Reference(String),
    Hostname(String),
    Ipv4Addr(std::net::Ipv4Addr),
    Ipv6Addr(std::net::Ipv6Addr),
    DateTime(DateTime<Utc>),
    Duration(Duration),
}

// ---------------------------------------------------------------------------
// UserData Implementations
// ---------------------------------------------------------------------------

impl LuaUserData for PermissionTriplet {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("to_string", |_lua, this, ()| Ok(this.to_string()));
        methods.add_meta_method(LuaMetaMethod::ToString, |_lua, this, ()| Ok(this.to_string()));
        methods.add_meta_method(LuaMetaMethod::Index, |_lua, this, key: String| {
            match key.as_str() {
                "read" => Ok(LuaValue::Boolean(this.read)),
                "write" => Ok(LuaValue::Boolean(this.write)),
                "execute" => Ok(match this.execute {
                    Some(m) => LuaValue::String(_lua.create_string(format!("{:?}", m))?),
                    None => LuaValue::Nil,
                }),
                _ => Ok(LuaValue::Nil),
            }
        });
    }
}

impl LuaUserData for Version {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_meta_method(LuaMetaMethod::ToString, |_lua, this, ()| {
            let mut s = format!("{}.{}", this.major, this.minor);
            if let Some(b) = this.build { s.push_str(&format!(".{}", b)); }
            if let Some(e) = this.edit { s.push_str(&format!("-{}", e)); }
            Ok(s)
        });
        methods.add_meta_method(LuaMetaMethod::Index, |_lua, this, key: String| {
            match key.as_str() {
                "major" => Ok(LuaValue::Integer(this.major as i64)),
                "minor" => Ok(LuaValue::Integer(this.minor as i64)),
                "build" => Ok(this.build.map(|v| LuaValue::Integer(v as i64)).unwrap_or(LuaValue::Nil)),
                "edit" => Ok(this.edit.map(|v| LuaValue::Integer(v as i64)).unwrap_or(LuaValue::Nil)),
                _ => Ok(LuaValue::Nil),
            }
        });
    }
}

// ---------------------------------------------------------------------------
// Conversion to/from LuaValue
// ---------------------------------------------------------------------------

impl IntoLua for Value {
    fn into_lua(self, lua: &Lua) -> LuaResult<LuaValue> {
        match self {
            Value::Nil => Ok(LuaValue::Nil),
            Value::Boolean(b) => Ok(LuaValue::Boolean(b)),
            Value::String(s) => Ok(LuaValue::String(lua.create_string(s)?)),
            Value::Integer(i) => Ok(LuaValue::Integer(i as i64)), // Potentially lossy if > i64::MAX
            Value::Natural(u) => Ok(LuaValue::Integer(u as i64)),
            Value::Float(f) => Ok(LuaValue::Number(f)),
            Value::List(l) => {
                let t = lua.create_table()?;
                for (i, v) in l.into_iter().enumerate() {
                    t.raw_insert((i + 1) as i64, v.into_lua(lua)?)?;
                }
                Ok(LuaValue::Table(t))
            }
            Value::Path(p) => Ok(LuaValue::String(lua.create_string(p)?)),
            Value::KeyMap(m) => {
                let t = lua.create_table()?;
                for (k, v) in m {
                    t.set(k, v.into_lua(lua)?)?;
                }
                Ok(LuaValue::Table(t))
            }
            // Complex types become UserData
            Value::User { uid, name } => {
                let t = lua.create_table()?;
                t.set("uid", uid)?;
                t.set("name", name)?;
                Ok(LuaValue::Table(t))
            }
            Value::Group { gid, name } => {
                let t = lua.create_table()?;
                t.set("gid", gid)?;
                t.set("name", name)?;
                Ok(LuaValue::Table(t))
            }
            Value::Permission { owner, group, other } => {
                let t = lua.create_table()?;
                t.set("owner", lua.create_userdata(owner)?)?;
                t.set("group", lua.create_userdata(group)?)?;
                t.set("other", lua.create_userdata(other)?)?;
                Ok(LuaValue::Table(t))
            }
            Value::Package(p) => {
                let t = lua.create_table()?;
                t.set("__type", "Package")?;
                t.set("name", p)?;
                Ok(LuaValue::Table(t))
            }
            Value::Version(v) => Ok(LuaValue::UserData(lua.create_userdata(v)?)),
            Value::Range { start, end, step, include_right } => {
                let t = lua.create_table()?;
                t.set("start", start as i64)?;
                t.set("end", end as i64)?;
                t.set("step", step.map(|s| s as i64))?;
                t.set("include_right", include_right)?;
                Ok(LuaValue::Table(t))
            }
            Value::VersionRange { min, max } => {
                let t = lua.create_table()?;
                t.set("min", lua.create_userdata(min)?)?;
                t.set("max", lua.create_userdata(max)?)?;
                Ok(LuaValue::Table(t))
            }
            Value::Service { name } => {
                let t = lua.create_table()?;
                t.set("__type", "Service")?;
                t.set("name", name)?;
                Ok(LuaValue::Table(t))
            }
            Value::Command { program, args } => {
                let t = lua.create_table()?;
                t.set("program", program)?;
                t.set("args", args)?;
                Ok(LuaValue::Table(t))
            }
            Value::EnvVar { name, value } => {
                let t = lua.create_table()?;
                t.set("name", name)?;
                t.set("value", value)?;
                Ok(LuaValue::Table(t))
            }
            Value::Reference(r) => Ok(LuaValue::String(lua.create_string(format!("ref:{}", r))?)),
            Value::Hostname(h) => Ok(LuaValue::String(lua.create_string(h)?)),
            Value::Ipv4Addr(ip) => Ok(LuaValue::String(lua.create_string(ip.to_string())?)),
            Value::Ipv6Addr(ip) => Ok(LuaValue::String(lua.create_string(ip.to_string())?)),
            Value::DateTime(dt) => Ok(LuaValue::String(lua.create_string(dt.to_rfc3339())?)),
            Value::Duration(d) => Ok(LuaValue::Integer(d.num_seconds())),
        }
    }
}

impl FromLua for Value {
    fn from_lua(value: LuaValue, _lua: &Lua) -> LuaResult<Self> {
        match value {
            LuaValue::Nil => Ok(Value::Nil),
            LuaValue::Boolean(b) => Ok(Value::Boolean(b)),
            LuaValue::Integer(i) => Ok(Value::Integer(i as i128)),
            LuaValue::Number(f) => Ok(Value::Float(f)),
            LuaValue::String(s) => Ok(Value::String(s.to_str()?.to_string())),
            LuaValue::Table(t) => {
                // Heuristic: if it looks like a list, make it a list
                let len = t.raw_len();
                if len > 0 {
                    let mut list = Vec::new();
                    for i in 1..=len {
                        list.push(Value::from_lua(t.get(i)?, _lua)?);
                    }
                    Ok(Value::List(list))
                } else {
                    let mut map = HashMap::new();
                    for pair in t.pairs::<String, LuaValue>() {
                        let (k, v) = pair?;
                        map.insert(k, Value::from_lua(v, _lua)?);
                    }
                    Ok(Value::KeyMap(map))
                }
            }
            LuaValue::UserData(ud) => {
                if let Ok(v) = ud.borrow::<Version>() {
                    return Ok(Value::Version(*v));
                }
                Err(LuaError::FromLuaConversionError {
                    from: "UserData",
                    to: "Value",
                    message: Some("Unsupported UserData type for Value".to_string()),
                })
            }
            _ => Err(LuaError::FromLuaConversionError {
                from: "LuaValue",
                to: "Value",
                message: Some(format!("Cannot convert {} to Value", value.type_name())),
            }),
        }
    }
}
