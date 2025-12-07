-- src/cli/resolve.lua - key resolver for the cli.
--
--     Copyright (C) 2024-2025  Kıvılcım İpek Defne Öztürk
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local lpeg = require("lpeg")
local P, R, S, C, Ct = lpeg.P, lpeg.R, lpeg.S, lpeg.C, lpeg.Ct

local space       = S(" \t")^0
local dot         = P(".")
local key_simple  = C((R("az", "AZ", "09") + S("_-"))^1)
local key_string  = C(P('["') * (1 - S('"]'))^0 * P('"]'))
local key_num     = C(R("09")^1) / tonumber

local key_segment =
   space * (
         key_string
      +  key_num
      +  key_simple
   )

local key_pattern = P{
   "KEYSEQ",
   KEYSEQ = (dot^(-1))
         * Ct((key_segment * dot)^0 * key_segment)
}

local resolve_key(input)
   return key_patter:match(input)
end

return {
   resolve_key = resolve_key
}
