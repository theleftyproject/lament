# Contributions to LAMENT

## Preamble
Free and open source software development is a collaborative job. Various people work on the source code, and different people have different styles of programming. While we value diversity a lot here, the presence of a unified coding style is essential for everyone to provide a more comfortable and convenient environment to collaborate. Therefore, decisions about the style of the code, the way the pull requests are described, and the way pull requests are merged should be standardised.

## General Rules
- Abide by the [Code of Conduct](CODE_OF_CONDUCT.md). We are very strict about this one. We will not tolerate harassment of any contributors here.
## Toolchain
- LAMENT is written in [Lua](https://lua.org), supports [LuaJIT](https://luajit.org/) and is built using [Luarocks](https://luarocks.org)
- We use [`asdf`](https://asdf-vm.com) to manage the versions of Lua and LuaJIT
- For documentation, we both use Lua's internal triple-dash (`---`) documentation syntax, and also LaTeX with the AMS-TeX package.
  - The LaTeX processor we prefer is LuaLaTeX, but you can use an alternative processor if you need
- The `.envrc` file in the repository root configures your development environment using [`direnv`](https://direnv.net/)

## Coding style
- We generally follow the [style guidelines of LuaRocks](https://github.com/luarocks/lua-style-guide).
- However we have one strict enforcement, use `local function`s whenever possible.

## Pull requests
- Use concise titles for pull requests and describe what it does well.
- (The applicability of this article to forks on external servers not guaranteed)
  GitHub gives us a nice feature called *tags* on pull requests. Use the appropriate tags for your pull requests.
- And that's it you will have a large chance for it being merged.

## Commits (for project administrators)
- **VERY IMPORTANT:** The only commits on the `main` branch should be created by merges, unless some sort of apocalypse happens.
- **REPEATING:** FOR THE SAKE OF CHRONOS YOU **DO NOT** COMMIT TO `main` UNLESS YOU MERGE STUFF OR UNLESS CHRONOS WANTS YOU TO DO SO.
- **Always create branches** for your commits and make a **pull request** to the `main` branch.

## Final notes
- Do not be afraid to ask whenever you need help. We have [GitHub Discussions](https://github.com/Sparkles-Laurel/lament/discussions/10)
