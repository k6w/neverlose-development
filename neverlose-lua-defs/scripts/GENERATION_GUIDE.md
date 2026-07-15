# LuaCATS Generation Guide — neverlose CS:GO API

Every definition file MUST follow these rules so the files are mutually consistent and
cross-reference correctly. Target: `lua-language-server` (sumneko) / LuaCATS annotations.

## File header

Each generated file starts with:

```lua
---@meta
-- neverlose CS:GO API — <module> module. Auto-generated from docs-csgo.neverlose.cc.
-- Do not edit by hand; regenerate from the raw docs instead.
```

## Type mapping (doc type → LuaCATS type)

| doc type        | LuaCATS type            |
|-----------------|-------------------------|
| `number`        | `number`                |
| `string`        | `string`                |
| `boolean`       | `boolean`               |
| `function`      | `function` (or a typed `fun(...)` when args are known) |
| `table`         | `table` (or `T[]` / typed table when known) |
| `any`           | `any`                   |
| `nil`           | `nil`                   |
| `vector`        | `vector`                |
| `color`         | `color`                 |
| `entity`        | `entity`                |
| `MenuItem`      | `MenuItem`              |
| `FontObject`    | `FontObject`            |
| `ImgObject`     | `ImgObject`             |
| `Material`      | `Material`              |
| `number/string` | `number\|string`        |

- A function returning "X or nil on failure" → return type `X?` (e.g. `entity?`).
- Multiple return values (`vector, number, boolean`) → `---@return vector`, `---@return number`, `---@return boolean` (one per line, in order), each named where the doc names them.

## Object classes (fixed names — use these EXACTLY)

- `vector` — vector object (methods documented as `vec_object:method` in vector.md)
- `color` — color object (`color_object:method` in color.md)
- `entity` — entity pointer (methods documented in entity.md under Netprops and elsewhere; also `:get_name()`, etc.)
- `MenuItem` — object returned by `ui.create` / `ui.find` (all the `:get`, `:set`, `:override`, `:type` etc. methods)
- `FontObject`, `ImgObject` — returned by `render.load_font` / `render.load_image*`
- `Material` — returned by the `materials` module
- `Hotkey` — struct returned in `ui.get_binds()`

Namespaces (`ui`, `render`, …) are plain global tables; declare their functions as
`function ui.get_alpha() end` with annotations above. Object classes are declared with
`---@class` and their methods as `function vector:clone() end`.

Note: the type namespace and the value namespace are separate in LuaLS, so a global table
`entity` (with `entity.get`) and a `---@class entity` (the object) coexist fine. Keep the
lowercase names to match the doc return-type strings.

## Function annotation format

For `render.world_to_screen(position: vector): vector` with a description:

```lua
---Returns the screen position vector, or nil if the world position is not visible.
---This can only be called from the render callback.
---@param position vector Position in world space
---@return vector? screen_position
function render.world_to_screen(position) end
```

Rules:
- Put the prose description (from the paragraph under the signature) as `---` doc comment lines ABOVE the annotations. Preserve useful notes/warnings (hints) as extra comment lines.
- One `---@param name type Description` per parameter, using the param table's Name/Type/Description.
- Optional params (shown as `[param]` in the signature) → mark the type optional: `---@param accurate boolean?` and mention "Optional." in the description.
- Optional/variadic: `...` → `---@param ... any Description`, and the function value uses `(...)`.
- Name return values when the docs name them.

## Overloads (`{% tabs %}` or "Available overloads")

Use LuaCATS `---@overload fun(...)` lines, OR declare the primary signature with `---@param`
and add `---@overload fun(...):ret` for the alternatives. Example (`render.load_font`):

```lua
---Loads a font. ...
---@param name string Font that will be initialized
---@param size number Size of the font
---@param flags string? 'a' anti-alias, 'i' italic, 'b' bold, 'o' outline, 'd' drop shadow
---@return FontObject?
---@overload fun(name: string, size: vector, flags?: string): FontObject?
function render.load_font(name, size, flags) end
```

## Events (events.lua)

`events` is indexed by event name; each returns an event handle with `:set`, `:unset`, `:call`,
and is also directly callable. Model the generic handle as a class and expose each concrete
event as a typed field so the callback argument autocompletes:

```lua
---@class EventHandle
---@field set fun(self: EventHandle, callback: function)
---@field unset fun(self: EventHandle, callback: function)
---@field call fun(self: EventHandle, ...)

---@class events
---Fired every frame. Most render.* functions can only be used here.
---@field render EventHandle
---Called on player_hurt. Callback receives the event data table.
---@field player_hurt EventHandle
-- ...one @field per documented event...
events = {}
```

Where an event's callback has documented arguments/fields (e.g. `player_hurt` gives
`userid, attacker, health, dmg_health, hitgroup, …`, `createmove` gives `cmd`), add a
`---@class <Event>Data` (or the cmd/ctx class) with `---@field` per documented field, and
reference it in the event's doc comment so users know the shape. Capture EVERY event listed
in `documentation/events.md`.

## Quality bar

- Include EVERY function/method/event on the page. Do not summarize or drop any.
- Keep descriptions faithful to the docs (trim GitBook markup: `<mark>`, `\`, `<code>`).
- Strip escaped underscores (`screen\_size` → `screen_size`).
- Valid Lua: every file must parse. Method/function bodies are empty (`end`).
- No `require`; these are ambient `---@meta` declarations.
