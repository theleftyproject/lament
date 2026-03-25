// src/crates/lament_sandbox/src/error.rs - error helpers
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

use mlua::prelude::*;

/// Convert a plain string message into an [`mlua::Error::RuntimeError`].
#[inline]
pub(crate) fn runtime(msg: impl Into<String>) -> LuaError {
    LuaError::RuntimeError(msg.into())
}

/// Assert that a required field exists in a module table; return a
/// [`LuaError`] if it is absent or `nil`.
pub(crate) fn require_field<'lua>(
    table: &LuaTable<'lua>,
    field: &str,
) -> LuaResult<LuaValue<'lua>> {
    let v: LuaValue<'_> = table.get(field)?;
    if v == LuaValue::Nil {
        Err(runtime(format!(
            "this backend lacks a `{field}` field"
        )))
    } else {
        Ok(v)
    }
}
