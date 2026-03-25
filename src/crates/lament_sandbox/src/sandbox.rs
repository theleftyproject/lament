// src/crates/lament_sandbox/src/sandbox.rs - embedded Lua host
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

//! [`Sandbox`] owns a Lua VM and provides the embedded-host interface:
//! load a backend module (text or bytecode), then call any named function
//! it exports.

use std::fs;
use std::sync::{Arc, Mutex};

use mlua::prelude::*;

use crate::config::Registry;
use crate::env::SandboxEnv;
use crate::error::{require_field, runtime};

// ---------------------------------------------------------------------------
// Sandbox
// ---------------------------------------------------------------------------

/// An isolated Lua interpreter for running one LAMENT backend module.
///
/// Each `Sandbox` owns its own [`Lua`] VM and a shared [`Registry`] that
/// the module can read/write through `lament.config`.
pub struct Sandbox {
    lua: Lua,
    registry: Arc<Mutex<Registry>>,
    /// The module table returned by executing the loaded chunk.
    module: Option<LuaTable>,
}

impl Sandbox {
    /// Create a new sandboxed Lua VM.
    ///
    /// The [`Registry`] is shared with the caller so that configuration
    /// written by the module is accessible from Rust after the call returns.
    pub fn new(env: SandboxEnv, registry: Arc<Mutex<Registry>>) -> LuaResult<Self> {
        // Safety: we never expose the underlying VM to more than one thread
        // at a time; all calls go through &mut self or &self with Lua's own
        // internal synchronisation.
        let lua = unsafe { Lua::unsafe_new() };

        // Store env + registry so load_* can reference them
        let _env_table = env.build_env(&lua, Arc::clone(&registry))?;

        Ok(Self {
            lua,
            registry,
            module: None,
        })
    }

    // ── Internal: execute a chunk in the restricted environment ──────────

    fn exec_chunk(&mut self, chunk: LuaChunk<'_>) -> LuaResult<()> {
        // Rebuild a fresh env every time so each load is independent
        let env_table = {
            // We need a temporary SandboxEnv to rebuild; permission flags
            // default to false (deny by default).
            let env = SandboxEnv::new();
            env.build_env(&self.lua, Arc::clone(&self.registry))?
        };

        let result: LuaMultiValue = chunk
            .set_environment(env_table)
            .eval()?;

        // The chunk must return a table (the module table)
        match result.into_iter().next() {
            Some(LuaValue::Table(t)) => {
                self.module = Some(t);
                Ok(())
            }
            Some(LuaValue::Nil) | None => {
                // Module returned nil — that's acceptable; call() will report
                // missing fields only when actually invoked.
                self.module = None;
                Ok(())
            }
            Some(other) => Err(runtime(format!(
                "backend module must return a table, got {}",
                other.type_name()
            ))),
        }
    }

    /// Load and execute a Lua **source file** in the sandbox.
    ///
    /// The chunk's return value must be a table exposing the module's
    /// callable fields (`init`, `apply`, `recalibrate`, `exit`, …).
    pub fn load_script(&mut self, path: &str) -> LuaResult<()> {
        let source = fs::read(path).map_err(|e| {
            runtime(format!("cannot read `{path}`: {e}"))
        })?;
        let chunk = self.lua.load(&source).set_name(path);
        self.exec_chunk(chunk)
    }

    /// Load and execute **pre-compiled Lua bytecode** in the sandbox.
    pub fn load_bytecode(&mut self, bytes: &[u8]) -> LuaResult<()> {
        let chunk = self.lua.load(bytes).set_name("(bytecode)");
        self.exec_chunk(chunk)
    }

    // ── Calling module functions ─────────────────────────────────────────

    /// Call a named function in the loaded module table.
    ///
    /// Returns an error if the module has not been loaded yet, or if the
    /// named field is absent / not callable.
    pub fn call(&self, fn_name: &str) -> LuaResult<LuaMultiValue> {
        let module = self.module.as_ref().ok_or_else(|| {
            runtime("no module loaded — call load_script or load_bytecode first")
        })?;

        let field = require_field(module, fn_name)?;

        match field {
            LuaValue::Function(f) => f.call::<LuaMultiValue>(()),
            other => Err(runtime(format!(
                "field `{fn_name}` is {}, not a function",
                other.type_name()
            ))),
        }
    }

    /// Convenience: call `init`.
    pub fn call_init(&self) -> LuaResult<()> {
        self.call("init").map(|_| ())
    }

    /// Convenience: call `apply`.
    pub fn call_apply(&self) -> LuaResult<()> {
        self.call("apply").map(|_| ())
    }

    /// Convenience: call `recalibrate`.
    pub fn call_recalibrate(&self) -> LuaResult<()> {
        self.call("recalibrate").map(|_| ())
    }

    /// Convenience: call `exit`.
    pub fn call_exit(&self) -> LuaResult<()> {
        self.call("exit").map(|_| ())
    }

    /// Return a reference to the shared [`Registry`].
    pub fn registry(&self) -> Arc<Mutex<Registry>> {
        Arc::clone(&self.registry)
    }
}

// ---------------------------------------------------------------------------
// Sandbox as Lua UserData (so the Lua side can drive it too)
// ---------------------------------------------------------------------------

/// Wrapper so [`Sandbox`] can be held by Lua as userdata.
///
/// We put it inside a `Mutex` because mlua's `UserData` trait requires
/// `Send + 'static`, and `Sandbox` owns a `Lua` VM.
pub struct LuaSandbox(pub std::cell::UnsafeCell<Sandbox>);

// SAFETY: we only ever drive the sandbox from one Lua state and one thread.
unsafe impl Send for LuaSandbox {}
unsafe impl Sync for LuaSandbox {}

impl LuaSandbox {
    #[inline]
    fn inner(&self) -> &Sandbox {
        unsafe { &*self.0.get() }
    }

    #[allow(clippy::mut_from_ref)]
    #[inline]
    fn inner_mut(&self) -> &mut Sandbox {
        unsafe { &mut *self.0.get() }
    }
}

impl LuaUserData for LuaSandbox {
    fn add_methods<M: LuaUserDataMethods<Self>>(methods: &mut M) {
        methods.add_method("load_script", |_lua, this, path: String| {
            this.inner_mut().load_script(&path)
        });

        methods.add_method("load_bytecode", |_lua, this, bytes: LuaString| {
            this.inner_mut().load_bytecode(bytes.as_bytes())
        });

        methods.add_method("call", |_lua, this, fn_name: String| {
            this.inner().call(&fn_name)
        });

        methods.add_method("call_init", |_lua, this, ()| {
            this.inner().call_init()
        });

        methods.add_method("call_apply", |_lua, this, ()| {
            this.inner().call_apply()
        });

        methods.add_method("call_recalibrate", |_lua, this, ()| {
            this.inner().call_recalibrate()
        });

        methods.add_method("call_exit", |_lua, this, ()| {
            this.inner().call_exit()
        });

        methods.add_meta_method(LuaMetaMethod::ToString, |_lua, _this, ()| {
            Ok("Sandbox")
        });
    }
}

/// Register the `Sandbox` constructor into the module table.
pub fn register_constructors(lua: &Lua, module: &LuaTable) -> LuaResult<()> {
    use crate::config::{LuaRegistry, Registry};

    let t = lua.create_table()?;

    t.set(
        "new",
        lua.create_function(|lua, (env_ud, reg_ud): (LuaAnyUserData, LuaAnyUserData)| {
            let env: SandboxEnv = env_ud.borrow::<SandboxEnv>()?.clone();
            let registry: Arc<Mutex<Registry>> = {
                let r = reg_ud.borrow::<LuaRegistry>()?;
                Arc::clone(&r.0)
            };
            let sb = Sandbox::new(env, registry)?;
            lua.create_userdata(LuaSandbox(std::cell::UnsafeCell::new(sb)))
        })?,
    )?;

    // Also allow creating a sandbox with a fresh Registry
    t.set(
        "new_with_fresh_registry",
        lua.create_function(|lua, env_ud: LuaAnyUserData| {
            let env: SandboxEnv = env_ud.borrow::<SandboxEnv>()?.clone();
            let registry = Arc::new(Mutex::new(Registry::new()));
            let sb = Sandbox::new(env, registry)?;
            lua.create_userdata(LuaSandbox(std::cell::UnsafeCell::new(sb)))
        })?,
    )?;

    module.set("Sandbox", t)?;
    Ok(())
}
