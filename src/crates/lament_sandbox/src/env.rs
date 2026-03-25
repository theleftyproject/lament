// src/crates/lament_sandbox/src/env.rs - restricted Lua environment builder
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

//! [`SandboxEnv`] holds permission flags and assembles the restricted Lua
//! environment table that every sandboxed chunk receives as its `_ENV`.
//!
//! The structure mirrors what `src/exec/sandbox.lua` does in pure Lua, but
//! lives here so Rust code can also construct sandboxes without going through
//! the Lua side.

use std::sync::{Arc, Mutex};

use mlua::prelude::*;

use crate::config::{LuaRegistry, Registry};

// ---------------------------------------------------------------------------
// SandboxEnv
// ---------------------------------------------------------------------------

/// Permission flags controlling what a sandboxed chunk is allowed to access.
///
/// These are consulted when `build_env` builds the restricted `_ENV` table.
/// Flags are `false` by default; future authorization logic will gate
/// operations on them at runtime rather than at construction time.
#[derive(Clone, Debug, Default)]
pub struct SandboxEnv {
    /// Allow access to `io.open`, `io.read`, `io.write`.
    pub allowed_io: bool,
    /// Allow access to `http` (luasocket).
    pub allowed_http: bool,
    /// Allow access to `os.time`, `os.date`, `os.difftime`, `os.execute`.
    pub allowed_os: bool,
}

impl SandboxEnv {
    pub fn new() -> Self {
        Self::default()
    }

    /// Build the restricted `_ENV` table for a sandboxed chunk.
    ///
    /// The table is suitable to pass as the third argument to `lua.load(…)`.
    /// `lament.config` is injected as a [`LuaRegistry`] userdata so that
    /// backend modules can read and write configuration state via the natural
    /// `lament.config.<hive>.<key>` indexing path.
    pub fn build_env(
        &self,
        lua: &Lua,
        registry: Arc<Mutex<Registry>>,
    ) -> LuaResult<LuaTable> {
        let env = lua.create_table()?;

        // ── Safe stdlib pass-throughs ────────────────────────────────────
        let globals = lua.globals();

        for name in &["math", "string", "table"] {
            let v: LuaValue = globals.get(*name)?;
            env.set(*name, v)?;
        }

        // Safe individual globals
        for name in &[
            "assert", "error", "ipairs", "pairs", "pcall", "xpcall",
            "select", "tostring", "tonumber", "type", "unpack", "load",
            "rawget", "rawset", "rawequal", "rawlen",
            "setmetatable", "getmetatable",
            "next",
        ] {
            let v: LuaValue = globals.get(*name)?;
            if v != LuaValue::Nil {
                env.set(*name, v)?;
            }
        }

        // ── lament namespace ─────────────────────────────────────────────
        let lament_t = lua.create_table()?;
        let registry_ud = lua.create_userdata(LuaRegistry(registry))?;
        lament_t.set("config", registry_ud)?;
        env.set("lament", lament_t)?;

        // ── Gated stubs ──────────────────────────────────────────────────
        // io
        if self.allowed_io {
            let io_t: LuaValue = globals.get("io")?;
            env.set("io", io_t)?;
        } else {
            env.set("io", lua.create_table()?)?;
        }

        // os (only safe subset, never os.exit)
        {
            let os_t = lua.create_table()?;
            if self.allowed_os {
                let real_os: LuaTable = globals.get("os")?;
                for name in &["time", "date", "difftime", "execute", "clock"] {
                    let v: LuaValue = real_os.get(*name)?;
                    if v != LuaValue::Nil {
                        os_t.set(*name, v)?;
                    }
                }
            }
            env.set("os", os_t)?;
        }

        // http — empty stub unless allowed (luasocket may not be present)
        env.set("http", lua.create_table()?)?;

        // ── _ENV self-reference (required for some Lua patterns) ─────────
        env.set("_ENV", env.clone())?;

        Ok(env)
    }
}

impl LuaUserData for SandboxEnv {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("allowed_io", |_lua, this, ()| Ok(this.allowed_io));
        methods.add_method("allowed_http", |_lua, this, ()| Ok(this.allowed_http));
        methods.add_method("allowed_os", |_lua, this, ()| Ok(this.allowed_os));

        methods.add_meta_method(LuaMetaMethod::Index, |_lua, this, field: String| {
            match field.as_str() {
                "allowed_io" => Ok(LuaValue::Boolean(this.allowed_io)),
                "allowed_http" => Ok(LuaValue::Boolean(this.allowed_http)),
                "allowed_os" => Ok(LuaValue::Boolean(this.allowed_os)),
                _ => Ok(LuaValue::Nil),
            }
        });

        methods.add_meta_method(LuaMetaMethod::ToString, |_lua, _this, ()| {
            Ok("SandboxEnv")
        });
    }
}

/// Register `SandboxEnv` constructors into the module table.
pub fn register_constructors(lua: &Lua, module: &LuaTable) -> LuaResult<()> {
    let t = lua.create_table()?;

    t.set(
        "new",
        lua.create_function(|lua, ()| {
            lua.create_userdata(SandboxEnv::new())
        })?,
    )?;

    t.set(
        "new_with",
        lua.create_function(|lua, opts: LuaTable| {
            let mut e = SandboxEnv::new();
            e.allowed_io = opts.get::<bool>("allowed_io").unwrap_or(false);
            e.allowed_http = opts.get::<bool>("allowed_http").unwrap_or(false);
            e.allowed_os = opts.get::<bool>("allowed_os").unwrap_or(false);
            lua.create_userdata(e)
        })?,
    )?;

    module.set("SandboxEnv", t)?;
    Ok(())
}
