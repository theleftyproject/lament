// src/crates/lament_sandbox/src/lib.rs - Lua C extension entry point
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

//! `lament_sandbox` — sandboxed Lua execution for the LAMENT configuration
//! tool.
//!
//! This crate exposes two surfaces:
//!
//! 1. **Lua C extension** (`cdylib`): `require('lament_sandbox')` returns a
//!    module table with constructors for [`Sandbox`], [`SandboxEnv`],
//!    `Registry`, `Hive`, and `Key`.
//!
//! 2. **Rust library** (`rlib`): the [`Sandbox`] struct can be used directly
//!    by Rust code to load and drive backend modules without going through an
//!    outer Lua interpreter.

use mlua::prelude::*;

mod config;
mod env;
mod error;
mod sandbox;
pub mod types;

pub use config::{Hive, Key, Registry};
pub use env::SandboxEnv;
pub use sandbox::Sandbox;
pub use types::Value;

// ---------------------------------------------------------------------------
// Lua C extension entry point
// ---------------------------------------------------------------------------

/// Called by Lua when the module is `require`-d.
///
/// Returns a table:
///
/// ```lua
/// local ls = require('lament_sandbox')
/// local reg  = ls.Registry.new()
/// local env  = ls.SandboxEnv.new()
/// local sb   = ls.Sandbox.new(env, reg)
/// sb:load_script("/path/to/backend.lua")
/// sb:call("apply")
/// ```
#[mlua::lua_module]
fn lament_sandbox(lua: &Lua) -> LuaResult<LuaTable> {
    let module = lua.create_table()?;

    config::register_constructors(lua, &module)?;
    env::register_constructors(lua, &module)?;
    sandbox::register_constructors(lua, &module)?;

    Ok(module)
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use std::sync::{Arc, Mutex};

    use mlua::prelude::*;

    use crate::config::Registry;
    use crate::env::SandboxEnv;
    use crate::sandbox::Sandbox;

    /// Helper: build a Sandbox with a fresh Registry.
    fn make_sandbox() -> Sandbox {
        let env = SandboxEnv::new();
        let reg = Arc::new(Mutex::new(Registry::new()));
        Sandbox::new(env, reg).expect("Sandbox::new failed")
    }

    // ── Registry / Hive / Key round-trip ────────────────────────────────

    #[test]
    fn test_registry_hive_key() {
        use crate::config::{Hive, Key, Registry};
        use crate::types::Value;
        let mut reg = Registry::new();
        let mut hive = Hive::new("fonts");
        let key = Key::new("size", Value::Integer(12));
        hive.register_key(key);
        reg.register_hive(hive);

        let v = reg
            .get_hive("fonts")
            .unwrap()
            .get_key("size")
            .unwrap()
            .get();
        assert_eq!(v, Value::Integer(12));
    }

    // ── Load a Lua script and call apply ────────────────────────────────

    #[test]
    fn test_sandbox_load_script() {
        use std::io::Write;

        // Write a minimal backend script to a temp file
        let mut tmp = tempfile::NamedTempFile::new().unwrap();
        write!(
            tmp,
            r#"
local result = false
return {{
    apply = function()
        result = true
        lament.config.test_hive.was_applied = true
    end,
    recalibrate = function() end,
}}
"#
        )
        .unwrap();

        let reg = Arc::new(Mutex::new(Registry::new()));
        let env = SandboxEnv::new();
        let mut sb = Sandbox::new(env, Arc::clone(&reg)).unwrap();
        sb.load_script(tmp.path().to_str().unwrap()).unwrap();
        sb.call_apply().unwrap();
    }

    // ── Load bytecode ────────────────────────────────────────────────────

    #[test]
    fn test_sandbox_load_bytecode() {
        // Compile a trivial chunk to bytecode via a throw-away Lua state
        let compiler = unsafe { Lua::unsafe_new() };
        let bytecode = compiler
            .load(
                r#"
return {
    apply       = function() end,
    recalibrate = function() end,
}
"#,
            )
            .into_function()
            .unwrap()
            .dump(false);

        let reg = Arc::new(Mutex::new(Registry::new()));
        let env = SandboxEnv::new();
        let mut sb = Sandbox::new(env, Arc::clone(&reg)).unwrap();
        sb.load_bytecode(&bytecode).unwrap();
        sb.call_apply().unwrap();
    }

    // ── Restricted environment: os.exit must not be accessible ──────────

    #[test]
    fn test_sandbox_restricted_env() {
        let reg = Arc::new(Mutex::new(Registry::new()));
        let env = SandboxEnv::new();
        let mut sb = Sandbox::new(env, Arc::clone(&reg)).unwrap();

        // A script that tries to call os.exit — should error out at load
        // time or when called, because os.exit is not in the env table.
        let result = sb.load_script("/dev/null"); // /dev/null returns nothing
        // /dev/null is a valid but empty file; load should succeed yielding nil module.
        // The interesting part is that even if the module exists, os.exit is unavailable.
        let _ = result;

        // Directly check that the env table lacks os.exit
        let lua = unsafe { Lua::unsafe_new() };
        let e = SandboxEnv::new();
        let env_table = e
            .build_env(&lua, Arc::new(Mutex::new(Registry::new())))
            .unwrap();
        let os_t: LuaTable = env_table.get("os").unwrap();
        let exit: LuaValue = os_t.get("exit").unwrap();
        assert_eq!(exit, LuaValue::Nil, "os.exit must not be accessible");
    }

    // ── Calling a non-existent function returns an error ─────────────────

    #[test]
    fn test_sandbox_call_missing_fn() {
        use std::io::Write;
        let mut tmp = tempfile::NamedTempFile::new().unwrap();
        write!(tmp, "return {{ apply = function() end }}").unwrap();

        let mut sb = make_sandbox();
        sb.load_script(tmp.path().to_str().unwrap()).unwrap();

        let err = sb.call("nonexistent").unwrap_err();
        let msg = err.to_string();
        assert!(
            msg.contains("nonexistent"),
            "error should mention the missing field, got: {msg}"
        );
    }

    // ── lament.config is reachable from inside a sandboxed chunk ─────────

    #[test]
    fn test_config_accessible() {
        use std::io::Write;

        let mut tmp = tempfile::NamedTempFile::new().unwrap();
        write!(
            tmp,
            r#"
return {{
    apply = function()
        -- writing to lament.config should not panic
        lament.config.my_hive.my_key = 42
    end,
    recalibrate = function() end,
}}
"#
        )
        .unwrap();

        let mut sb = make_sandbox();
        sb.load_script(tmp.path().to_str().unwrap()).unwrap();
        sb.call_apply().unwrap();
    }
}
