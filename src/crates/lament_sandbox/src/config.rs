// src/crates/lament_sandbox/src/config.rs - Registry / Hive / Key userdata
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

//! Rust-side mirrors of `hive.lua` and `key.lua`, exposed to sandboxed Lua
//! chunks as userdata so that `lament.config.<hive>.<key>` indexing works
//! through the `__index` / `__newindex` metamethods below.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use mlua::prelude::*;

use crate::error::runtime;

// ---------------------------------------------------------------------------
// Key
// ---------------------------------------------------------------------------

/// A named, optionally-validated configuration slot inside a [`Hive`].
///
/// Mirrors `Key` from `src/hive/key.lua`.
#[derive(Clone)]
pub struct Key {
    pub name: String,
    pub default: LuaValue,
    /// Optional Lua validator function (`function(v) -> bool`).
    pub validate: Option<LuaRegistryKey>,
    value: Option<LuaValue>,
}

impl Key {
    pub fn new(name: impl Into<String>, default: LuaValue) -> Self {
        Self {
            name: name.into(),
            default,
            validate: None,
            value: None,
        }
    }

    pub fn with_validator(mut self, key: LuaRegistryKey) -> Self {
        self.validate = Some(key);
        self
    }

    /// Get the current value, falling back to `default`.
    pub fn get(&self) -> LuaValue {
        self.value.clone().unwrap_or_else(|| self.default.clone())
    }

    /// Set the value, running `validate` if present.
    pub fn set(&mut self, lua: &Lua, value: LuaValue) -> LuaResult<()> {
        if let Some(reg) = &self.validate {
            let f: LuaFunction<'_> = lua.registry_value(reg)?;
            let ok: bool = f.call(value.clone())?;
            if !ok {
                return Err(runtime(format!(
                    "validation failed for key `{}`",
                    self.name
                )));
            }
        }
        self.value = Some(value);
        Ok(())
    }
}

// ---------------------------------------------------------------------------
// Hive
// ---------------------------------------------------------------------------

/// A named collection of [`Key`]s.
///
/// Mirrors `Hive` from `src/hive/hive.lua`.
#[derive(Clone, Default)]
pub struct Hive {
    pub name: String,
    keys: HashMap<String, Key>,
}

impl Hive {
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            keys: HashMap::new(),
        }
    }

    pub fn register_key(&mut self, key: Key) {
        self.keys.insert(key.name.clone(), key);
    }

    pub fn get_key(&self, name: &str) -> Option<&Key> {
        self.keys.get(name)
    }

    pub fn get_key_mut(&mut self, name: &str) -> Option<&mut Key> {
        self.keys.get_mut(name)
    }
}

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

/// Top-level registry of [`Hive`]s, exposed to Lua as `lament.config`.
///
/// Mirrors `Registry` from `src/interface/registry.lua`.
#[derive(Clone, Default)]
pub struct Registry {
    hives: HashMap<String, Hive>,
}

impl Registry {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn register_hive(&mut self, hive: Hive) {
        self.hives.insert(hive.name.clone(), hive);
    }

    pub fn get_hive(&self, name: &str) -> Option<&Hive> {
        self.hives.get(name)
    }

    pub fn get_hive_mut(&mut self, name: &str) -> Option<&mut Hive> {
        self.hives.get_mut(name)
    }
}

// ---------------------------------------------------------------------------
// Shared-ownership wrappers for UserData
//
// mlua UserData requires 'static + Send, so we wrap the inner types in
// Arc<Mutex<_>> and expose those as the Lua-visible userdata values.
// ---------------------------------------------------------------------------

/// Lua-visible wrapper around a shared [`Key`].
pub struct LuaKey(pub Arc<Mutex<Key>>);

impl LuaUserData for LuaKey {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("get", |_lua, this, ()| {
            Ok(this.0.lock().unwrap().get())
        });

        methods.add_method_mut("set", |lua, this, value: LuaValue| {
            this.0.lock().unwrap().set(lua, value)
        });

        // Allow `key_ud.value` as a read shorthand
        methods.add_meta_method(LuaMetaMethod::Index, |_lua, this, field: String| {
            if field == "value" || field == "get" {
                Ok(this.0.lock().unwrap().get())
            } else if field == "name" {
                Ok(LuaValue::String(
                    _lua.create_string(this.0.lock().unwrap().name.as_bytes())?,
                ))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        methods.add_meta_method_mut(
            LuaMetaMethod::NewIndex,
            |lua, this, (field, value): (String, LuaValue)| {
                if field == "value" {
                    this.0.lock().unwrap().set(lua, value)
                } else {
                    Err(runtime(format!("Key has no settable field `{field}`")))
                }
            },
        );
    }
}

/// Lua-visible wrapper around a shared [`Hive`].
pub struct LuaHive(pub Arc<Mutex<Hive>>);

impl LuaUserData for LuaHive {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("get_keys", |lua, this, ()| {
            let hive = this.0.lock().unwrap();
            let t = lua.create_table()?;
            for (k, _) in &hive.keys {
                t.set(k.as_str(), true)?;
            }
            Ok(t)
        });

        methods.add_method_mut("register_key", |_lua, this, key: LuaTable| {
            let name: String = key.get("name")?;
            let default: LuaValue = key.get("default")?;
            let k = Key::new(name, default);
            this.0.lock().unwrap().register_key(k);
            Ok(())
        });

        // __index: hive[keyname] → key value (or nil)
        methods.add_meta_method(LuaMetaMethod::Index, |_lua, this, field: String| {
            let hive = this.0.lock().unwrap();
            Ok(hive.get_key(&field).map(|k| k.get()).unwrap_or(LuaValue::Nil))
        });

        // __newindex: hive[keyname] = value
        methods.add_meta_method_mut(
            LuaMetaMethod::NewIndex,
            |lua, this, (field, value): (String, LuaValue)| {
                let mut hive = this.0.lock().unwrap();
                if let Some(key) = hive.get_key_mut(&field) {
                    key.set(lua, value)
                } else {
                    // Auto-create an unvalidated key for convenience
                    let mut k = Key::new(&field, LuaValue::Nil);
                    k.value = Some(value);
                    hive.register_key(k);
                    Ok(())
                }
            },
        );

        methods.add_meta_method(LuaMetaMethod::ToString, |_lua, this, ()| {
            Ok(format!("Hive({})", this.0.lock().unwrap().name))
        });
    }
}

/// Lua-visible wrapper around a shared [`Registry`].
///
/// This is the value injected as `lament.config` into each sandbox chunk.
pub struct LuaRegistry(pub Arc<Mutex<Registry>>);

impl LuaUserData for LuaRegistry {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut(
            "register_hive",
            |_lua, this, (name, _hive): (String, LuaValue)| {
                let hive = Hive::new(&name);
                this.0.lock().unwrap().register_hive(hive);
                Ok(())
            },
        );

        methods.add_method("get_hive", |lua, this, name: String| {
            let reg = this.0.lock().unwrap();
            if reg.get_hive(&name).is_some() {
                // We share the same Arc for the Hive so mutations are visible
                // to both Lua and Rust.
                let hive_arc = {
                    drop(reg);
                    let mut reg2 = this.0.lock().unwrap();
                    // Get or create
                    if reg2.get_hive(&name).is_none() {
                        reg2.register_hive(Hive::new(&name));
                    }
                    Arc::new(Mutex::new(reg2.hives[&name].clone()))
                };
                Ok(LuaValue::UserData(lua.create_userdata(LuaHive(hive_arc))?))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        // __index: config[hivename] → LuaHive (or nil)
        methods.add_meta_method(LuaMetaMethod::Index, |lua, this, field: String| {
            let mut reg = this.0.lock().unwrap();
            if reg.get_hive(&field).is_none() {
                // Auto-create hive on first access (mirrors Lua _SYSCONF table behaviour)
                reg.register_hive(Hive::new(&field));
            }
            let hive = reg.hives[&field].clone();
            let arc = Arc::new(Mutex::new(hive));
            Ok(LuaValue::UserData(lua.create_userdata(LuaHive(arc))?))
        });

        // __newindex: config[hivename] = hive_ud
        methods.add_meta_method_mut(
            LuaMetaMethod::NewIndex,
            |_lua, this, (field, value): (String, LuaValue)| {
                if let LuaValue::UserData(ud) = value {
                    if let Ok(h) = ud.borrow::<LuaHive>() {
                        let hive = h.0.lock().unwrap().clone();
                        this.0.lock().unwrap().hives.insert(field, hive);
                        return Ok(());
                    }
                }
                Err(runtime("lament.config: value must be a Hive userdata"))
            },
        );

        methods.add_meta_method(LuaMetaMethod::ToString, |_lua, _this, ()| {
            Ok("Registry(lament.config)")
        });
    }
}

/// Build the Lua-facing constructor table for `lament_sandbox.Registry`,
/// `lament_sandbox.Hive`, and `lament_sandbox.Key`.
pub fn register_constructors(lua: &Lua, module: &LuaTable) -> LuaResult<()> {
    // Registry.new()
    let reg_t = lua.create_table()?;
    reg_t.set(
        "new",
        lua.create_function(|lua, ()| {
            let r = Registry::new();
            lua.create_userdata(LuaRegistry(Arc::new(Mutex::new(r))))
        })?,
    )?;
    module.set("Registry", reg_t)?;

    // Hive.new(name)
    let hive_t = lua.create_table()?;
    hive_t.set(
        "new",
        lua.create_function(|lua, name: String| {
            let h = Hive::new(name);
            lua.create_userdata(LuaHive(Arc::new(Mutex::new(h))))
        })?,
    )?;
    module.set("Hive", hive_t)?;

    // Key.new(name, default)
    let key_t = lua.create_table()?;
    key_t.set(
        "new",
        lua.create_function(|lua, (name, default): (String, LuaValue)| {
            let k = Key::new(name, default);
            lua.create_userdata(LuaKey(Arc::new(Mutex::new(k))))
        })?,
    )?;
    module.set("Key", key_t)?;

    Ok(())
}
