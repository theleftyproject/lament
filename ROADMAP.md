# Roadmap for LAMENT

Since mid-2023, LAMENT has been in irregular development due to my adverse life circumstances (Trying to administer my schoolwork, my internships, transitioning in an adverse political climate, etc.) and I have decided to make a roadmap from here to show us where we are and how we are planning to proceed with the new contributors. (Does anyone even see my repo or otherwise want to contribute???)

## Brief summary of LAMENT

The Lefty Application, Modification, Editing and Notification Tool ("LAMENT") is the reference implementation of Sparkles' Configuration Theory and its "bi-mutable" configuration model. A pivot point for transitioning between traditional imperative configuration (`/etc/<config file>` style) and declarative configuration (akin to what NixOS, Ansible, Terraform, Docker Compose, Puppet, Chef, etc. provide) is needed given that there are a lot of search engine results that are still shaped around manipulating configuration files directly, which are simply not compatible with systems that use declarative configuration engines.

LAMENT has three goals:

1. To provide a declarative and reproducible configuration environment that provides a user-friendly DSL to declare how configuration will behave
2. To provide a `gsettings`-like command line tool that provides access to the system configuration directly, allowing external programs to invoke this CLI tool to modify the configuration of the system.
3. To reassemble and adapt the declarative configuration in environments with diverse computer hardware that provide varying levels of computation capacity, including older systems with lower performance.

# The roadmap

- [ ]  Prepare the project environment
  - [X]  Choose Lua version (5.4)
  - [ ]  Create a containerized testing environment
  - [X]  Test for bugs present in Busted with a dummy bugcheck test that asserts well-known conditions that can be computed with paper and pen
- [ ]  Implement the basic file layout
  - [X]  `src/engine` provides the declarative configuration engine
  - [X]  `src/exec` provides functions related to execution
  - [X]  `src/hive` provides functionality related to top-level configuration entries, the "hives"
  - [X]  `src/interface` provides the following:
    - [ ]  `src/interface/backend.lua` which provides "backends" which are compiled Lua modules that describe how configuration files should be read and written, and how the configuration files should be integrated with the System State table `_sysconf`
    - [X]  `src/interface/registry.lua` which provides the `lament.interface.Registry` class the `_sysconf` table implements.
  - [X]  `src/util` which provides the following utilities:
    - [X]  `src/util/enum.lua` which provides Discriminated Unions and Enums
    - [X]  `src/util/switch.lua` which provides a pattern-matching expression function to work with enums and DUs
  - [X]  `utils/` which provides
    - [X]  `utils/lefty-escal.sh` which is a way to grant root access regardless of what program is providing the ability to run a command as another user.
  - [X]  `spec/` which provides tests
  - [X]  `docs/` where documentation written using AMS-TeX is present
  - [X]  `.forgejo/` for Nickel or Jsonnet scripts that generate YAML files for Forgejo actions
  - [X]  `.github/` for GitHub configuration
  - [X]  `.vscode/` for VSCode/VSCodium configuration.
  - [X]  `.git/` which presents the Git database
  - [X]  `.editorconfig` for enforcing the coding style present in CONTRIBUTING.md for EditorConfig-capable editors
  - [X]  `.envrc` to configure the Lua environment
  - [X]  `.gitattributes` and `.gitignore` which configure Git behaviour
  - [X]  `.luacheckrc` for the configuration of `luacheck`
  - [X]  `.luarc.json` which configures the Lua environment further
  - [X]  `flake.nix` and `flake.lock` for build environments that run NixOS
  - [X]  `Justfile` for build orchestration
  - [X]  `lament-dev-2.rockspec` which is the LuaRocks specification for `lament`
  - [X]  `LICENSE` where the GNU General Public License v3, which LAMENT is licensed under, lives
  - [ ]  `README.md` where the project summary is present
  - [X]  `ROADMAP.md` which provides our roadmap.
- [ ]  Define the configuration API and backend API
  - [ ]  Backends need to implement the following functionality:
    - [ ]  an event called `init`, triggered when the module is found in the respective directory and finished loading.
    - [ ]  an event called `exit`, triggered when LAMENT has completed the given task and unloads the module.
    - [ ]  an event called `apply`, triggered when a module is requested to write a present configuration file by referring to the relevant hives on the `_sysconf` table.
    - [ ]  an event called `recalibrate`, triggered when a module is requested to fill the respective hive on the `_sysconf` table by reading its respective configuration files.
- [ ]  Implement a sandbox to provide a restricted Lua environment to configuration backends to allow them to read and write configuration files without causing damage to the system without permission, and another sandbox to provide the configuration scripts written in Lua.
- [ ]  Describe locations where LAMENT should expect the presence of its own configuration (the so-called *auto-configuration*), system-wide declarative configuration, user-level declarative configuration, system-wide backend modules and user-level backend modules.
  - Note: in configuration theory, the *auto-configuration* is defined as the configuration file that is always identically reproduced by application and recalibration operations.
- [ ]  Allow user-level declarative configuration of the `$HOME/.config/` directory.
- [ ]  Provide a command line interface to LAMENT which can trigger explicit reconfiguration of the system.
  - [X]  Decide which command line parameters it will support.
    - [] `--apply`/`--calibrate`/`-A` triggers application.
    - [] `--recalibrate`/`--reconcile`/`-B` triggers recalibration.
    - [] `--cross-calibrate`/`-C` triggers a simultaneous application and recalibration.
    - Commands **follow** the name of the key they will act on, not precede them.
      - It's `lament <key> set`, not `lament set <key>`
    - [] The `set` command sets the value of a `<key>`
      - [] Shall support the following for list keys
        - `--append`/`-a` to append a value to the end of a list
        - `--prepend`/`-p` to prepend a value to the start of a list
        - `--set-index`/`-s` to set a specific index of a list. **Lists are 1-indexed, not 0-indexed**.
        - `--nil-index`/`-n` to set a specific index of a list to `nil`. Compare it to the following.
        - `--del-index`/`-d` to **remove** a specific index of a list. This should **reduce the length of a list by 1**.
        - `--clear`/`-c` to **clear** a list. This removes all values from a list, **effectively setting the count of elements in the list to 0**.
    - [] The `get` command retrieves the value of a `<key>`
      - Shall support the following for list keys
        - `--index`/`--at`/`-i <n>` to retrieve a specific index of a list key. **Lists are 1-indexed**.
  - [X]  Implement a way to resolve configuration keys, the unique path to the property of the hive the user would like to modify or retrieve. The key format is `.foo.["bar baz"].1.quux`.
    - The leading dot is optional, it symbolizes `sysconf.` that will be used in the declarative configuration files.
    - Any key that does not contain spaces in its name is not required to be wrapped in square brackets.
    - Any key that does contain spaces in its name is required to be wrapped in `["..."]`, both the double quotes and the square brackets are **required**.
    - Subkeys are split by dots (`.`) from each other, the dot is **never** optional.
  - [X]  Implement how the user will specify explicit, system-wide application and recalibration of the system.
  - [ ]  Allow user-level declarative configuration by providing the `$HOME/.config/lament` directory and the `--user`/`-U` command-line flag.
- [ ]  Allow backends to run on multiple threads concurrently
  - [ ]  Race conditions will need to be resolved.
