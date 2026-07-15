# neverlose-development

my workspace for writing lua scripts against the [neverlose cs:go api](https://docs-csgo.neverlose.cc).

it comes with full luacats type definitions for the whole api and a `.luarc.json` that's already
tuned, so any editor running `lua-language-server` (zed, vs code, neovim, helix) gives you
autocomplete, hover docs, parameter hints and clean diagnostics without any extra setup.

## what's inside

```
neverlose/
├── .luarc.json            wires lua-language-server to the defs + tuned diagnostics
├── neverlose-lua-defs/    the type definitions for the whole neverlose api
│   ├── library/           one ---@meta file per api module (ui, render, entity, ...)
│   │   └── modules/neverlose/   67 bundled 3rd-party libs for require() resolution
│   ├── scripts/           scraper + guide to refresh the defs from the docs
│   └── README.md          full details on the defs, coverage and setup
└── your-script.lua        drop your scripts here, autocomplete just works
```

the defs are generated from the official docs and checked with `lua-language-server`. running them
against a real script took it from 103 warnings down to 0.

## what's covered

every module, function, method, event and object class from the docs. that's 287 functions/methods,
43 classes and 31 events across 21 definition files:

- namespaces: `ui` `render` `entity` `rage` `esp` `materials` `network` `cvar` `db` `files`
  `json` `panorama` `common` `utils` `globals` `bit` `math` `events`
- object classes: `vector` `color` `entity` `menuitem` `menugroup` `fontobject` `imgobject`
  `material` `hotkey` `eventhandle` and more
- events: all ~31 events with typed callback args (`player_hurt`, `createmove`, `render`, ...)

a few things that work nicely:

- netprop access is warning-free, like `ent.m_iHealth`, `ent['m_flStamina']`, `ent.m_flPoseParameter[12]`
- method chains autocomplete, like `entity.get_local_player():get_origin():dist(vector(0,0,0))`
- constructors with every documented overload, like `vector(x,y,z)` and `color(255,195,25,200)`
- typed event callbacks, so `events.player_hurt:set(function(e) ... end)` autocompletes `e`
- the `new_class()` class system resolves without warnings

## setup

everything's already wired up. just open the project folder (the one with `.luarc.json`) in an
editor that uses `lua-language-server`:

- **zed**: install the *lua* extension, open the folder, open any `.lua` file
- **vs code**: install the *lua* extension by sumneko/luals, open the folder. `.luarc.json` is
  picked up automatically
- **neovim / helix / other**: point your `lua_ls` workspace at this folder, it reads `.luarc.json`
  from the workspace root

if your scripts live somewhere else, copy `.luarc.json` next to them and point `workspace.library`
and `runtime.path` at `neverlose-lua-defs/library`.

## diagnostics

`.luarc.json` is set up for a big dynamically-typed codebase: full autocomplete and hover, noise
off, real-bug checks on. `undefined-global` (the typo catcher) and `duplicate-index` stay on, while
the type-mismatch and nil-check noise on third-party code is turned off. the full breakdown, plus
how to make it stricter, is in [`neverlose-lua-defs/README.md`](neverlose-lua-defs/README.md).

## refreshing the defs

when the docs change, regenerate the library from `neverlose-lua-defs/scripts/`. there's a walkthrough
in `neverlose-lua-defs/scripts/GENERATION_GUIDE.md`.
</content>
