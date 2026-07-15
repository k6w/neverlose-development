---@meta
-- neverlose CS:GO API — panorama module. Auto-generated from docs-csgo.neverlose.cc.
-- Do not edit by hand; regenerate from the raw docs instead.

--#region Structs

---A panorama API table (or a root panel) obtained by indexing `panorama`.
---Indexing an API yields its JavaScript functions; indexing a root panel yields nested APIs.
---@class PanoramaAPI
---@field [string] table|function

---The `panorama` global. Exposes `loadstring` and dynamic access to panorama APIs.
---Indexing with an API name, e.g. `GameStateAPI`, or a root panel name, e.g. `CSGOMainMenu`.
---@class panorama
---@field [string] PanoramaAPI
panorama = {}

--#endregion

--#region Functions

---Compiles and runs a string of JavaScript code in the panorama context.
---@param js_code string String containing JavaScript code
---@param panel string? Panel name (panorama root panel). Optional.
---@return any
function panorama.loadstring(js_code, panel) end

--#endregion

--#region Accessing API's

-- Panorama APIs are accessed dynamically by indexing the `panorama` global:
--
--   panorama[api]         -> table   -- API from the default root panel, e.g. panorama.GameStateAPI
--   panorama[panel][api]  -> table   -- API from a specific root panel, e.g. panorama.CSGOMainMenu.UiToolkitAPI
--
-- Each accessed API is returned as a table whose fields are the JavaScript functions of that API.
--
-- Example:
--   local MyPersonaAPI = panorama.MyPersonaAPI
--   print(MyPersonaAPI.GetXuid())
--
--   local UiToolkitAPI = panorama.CSGOMainMenu.UiToolkitAPI
--   UiToolkitAPI.CloseAllVisiblePopups()

--#endregion
