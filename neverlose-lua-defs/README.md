# neverlose-lua-defs

**LuaCATS type definitions for the entire [neverlose CS:GO Lua API](https://docs-csgo.neverlose.cc)** —
autocomplete, hover docs, parameter hints, and warning-free scripting in any editor that uses
`lua-language-server` (sumneko): **Zed**, VS Code, Neovim, Helix, etc.

Generated from the official docs. Validated with `lua-language-server`: a real script went from
**103 warnings → 0**.

## What this is (and isn't)

Editors run `lua-language-server` for Lua. The best autocomplete for a library is achieved by
feeding that server **type-definition stubs** — not by writing a custom LSP. So this is a
`library/` of `---@meta` definition files plus a `.luarc.json` that wires them in. No custom LSP,
no editor extension to build, no build step.

## Layout

```
neverlose/                          ← your project (open this folder in your editor)
├── .luarc.json                     ← points lua-language-server at the defs
├── your-script.lua                 ← autocomplete works here
└── neverlose-lua-defs/
    ├── library/                    ← the type definitions
    │   ├── ui.lua render.lua …      ← one file per API module (---@meta)
    │   └── modules/neverlose/       ← bundled 3rd-party libs for require() resolution
    ├── scripts/                    ← scraper + generation guide (to refresh from docs)
    └── README.md
```

## Setup

Everything is already wired up in this project. Just:

**Zed** — open the `neverlose/` folder (the one with `.luarc.json`). Ensure the **Lua** extension
is installed (`zed: extensions` → search *Lua*); it bundles `lua-language-server`. Open any `.lua`
script — autocomplete, hover docs, and signatures light up.

**VS Code** — install the *Lua* extension by sumneko/LuaLS, open the `neverlose/` folder. `.luarc.json`
is picked up automatically.

**Neovim / Helix / other** — point your `lua_ls` setup at this folder as a workspace; it reads
`.luarc.json` from the workspace root.

If your scripts live elsewhere, move `.luarc.json` next to them and point `workspace.library` /
`runtime.path` at this `neverlose-lua-defs/library` folder (relative or absolute both work).

## What's covered

Every module, function, method, event, and object class from the docs — **287 functions/methods,
43 classes, 31 events** across 21 definition files:

| Namespaces | Object classes | Events |
|---|---|---|
| `ui` `render` `entity` `rage` `esp` `materials` `network` `cvar` `db` `files` `json` `panorama` `common` `utils` `globals` `bit` `math` `events` | `vector` `color` `entity` `MenuItem` `MenuGroup` `FontObject` `ImgObject` `Material` `Hotkey` `EventHandle` … | all ~31 events with typed callback args (`player_hurt`, `createmove`, `render`, …) |

Highlights:
- **Netprop access is warning-free** — `ent.m_iHealth`, `ent['m_flStamina']`, `ent.m_flPoseParameter[12]` all resolve.
- **Method chains autocomplete** — `entity.get_local_player():get_origin():dist(vector(0,0,0))`.
- **Constructors** — `vector(x,y,z)`, `color(255,195,25,200)` (with all documented overloads).
- **Event callbacks typed** — `events.player_hurt:set(function(e) ... end)` autocompletes `e`'s fields.
- **`new_class()` class system** — `new_class():struct 'name' { ... }` chaining and `ctx.name:method()` access resolve without warnings.

## Bundled library modules (`require("neverlose/…")`)

Third-party library sources live in `library/modules/neverlose/` (67 of them). Because your scripts
load them as `require("neverlose/<name>")` (no `.lua`), `.luarc.json` maps that namespace via:

```json
"runtime.path": ["?.lua", "?/init.lua", "neverlose-lua-defs/library/modules/?.lua"]
```

So `require("neverlose/aes")` resolves to `library/modules/neverlose/aes.lua`, and the required
value autocompletes its real members (e.g. `aes.encrypt`, `aes.decrypt`).

These files are loaded as a **definition library and never diagnosed** — the whole
`neverlose-lua-defs/library` folder is in `workspace.ignoreDir`, so you get every library's API for
autocomplete/`require` resolution **without a single warning from the libraries' own internals**.

**Adding a new library:** drop `foo.lua` (real source or a typed stub) into
`library/modules/neverlose/` — `require("neverlose/foo")` works immediately, no config change.

Notes:
- Names must match the require string: `require("neverlose/menulib")` → `menulib.lua`.
- Some libraries ship no local source (loaded by neverlose at runtime). For those, a small typed
  **stub** provides autocomplete — e.g. `edge_yaw.lua`, `md5.lua`, `get_lc.lua`.
- A few libraries don't `return` a value (they register globals / run for side effects); those
  won't produce a typed `require` result, which is expected.

## Diagnostics tuning

`.luarc.json` is tuned for a large, dynamically-typed script codebase: **full autocomplete + hover,
noise off, real-bug checks on**. On a real script this took it from ~180 warnings to essentially 0.

**Kept on (catch real bugs):**
- `undefined-global` — catches typos in names (it caught a real `grouond_state` typo, misspelled 6×).
- `duplicate-index` — catches the same table key defined twice (it caught a dead `main_home` entry).

**Disabled (`diagnostics.disable`) — pure noise on dynamically-typed / third-party-module code:**
`param-type-mismatch`, `redundant-parameter`, `missing-parameter`, `undefined-field`,
`need-check-nil`, `cast-local-type`, `lowercase-global`.

The `neverlose-lua-defs/library` folder is also never diagnosed (`workspace.ignoreDir`), so bundled
libraries never warn.

### Your own globals

Your scripts define globals in their own style (`localplayer = slib.lp`, `font = …`, etc.). Those
are whitelisted in `diagnostics.globals`. When you add a new intentional global, append its name
there — that keeps the `undefined-global` typo-catcher useful without false positives. (Or annotate
tables with `---@type` / `---@class` to type-flow them.)

### If you want it stricter again

Remove entries from `diagnostics.disable` to re-enable those checks — e.g. drop `"undefined-field"`
to have method-name typos flagged again. Annotate a variable with `---@type entity` and its methods
(`:get_origin()` etc.) type-check precisely.

## Refreshing when the docs change

The definitions are generated from the raw docs. To update:

```bash
cd neverlose-lua-defs
./scripts/scrape.sh /tmp/nl-raw      # re-download every page listed in the docs llms.txt
```

Then regenerate the `library/*.lua` files from the raw markdown following
`scripts/GENERATION_GUIDE.md` (the conventions every file follows: class names, type mapping,
overload/optional-param handling). Validate with:

```bash
lua-language-server --check .        # from the project root; expect "no problems found"
```

## Source

Docs: <https://docs-csgo.neverlose.cc> (GitBook). Page index: `/llms.txt`.
Definitions target `lua-language-server` (LuaCATS/EmmyLua annotations), runtime **LuaJIT 2.1**.
