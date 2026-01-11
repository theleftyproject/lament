/**
*    .git-com.jsonnet - git-com configuration manifest script
*        Copyright (C) 2025 - 2026 Kıvılcım İpek Afet Öztürk
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
std.manifestYamlDoc({
    "commit-type": {
        "type": "select",
        "destination": "title",
        "instructions": "What type of work was done?",
        "options": [
            "fix",
            "feat",
            "build",
            "chore",
            "ci",
            "docs",
            "style",
            "refactor",
            "perf",
            "test",
            "fix!", // indicates a breaking change
            "feat!", // indicates a breaking change
        ]
    },
    "scope": {
        "type": "select",
        "destination": "title",
        "instructions": "(optional) What section of codebase? ",
        "allow-empty": true,
        "before-string": "(",
        "after-string": ")",
        "options": [
            "cli",
            "engine",
            "exec",
            "hive",
            "interface",
            "log",
            "util",
            "global",
            "infra",
            "test"
        ]
    },
    "subject": {
        "type": "text",
        "destination": "title",
        "before-string": " ", // empty space to separate it from either scope or title
        "placeholder": "a short description...",
    },
    "commit-description": {
        "allow-empty": true,
        "destination": "body",
        "instructions": "Please describe your changes...",
        "type": "multiline-text",
        "placeholder": "(optional text)",
    },
    "ticket-number": {
        "type": "text",
        "destination": "body",
        "data-type": "integer",
        "allow-empty": true,
        "before-string": "\n\nTicket: ",
        "instructions":  "Associated ticket number (if any)"
    }
}, quote_keys = false)
