require("git"):setup{ order = 0 }
require("full-border"):setup()
require("starship"):setup()
require("smart-enter"):setup{ open_multi = true }

local ui, ya, cx = ui, ya, cx
local function hovered()
  local a = cx.active
  return a and a.current and a.current.hovered or nil
end

-- Symlink target in status (after name)
Status:children_add(function()
  local h = hovered()
  if h and h.link_to then return " -> " .. tostring(h.link_to) end
  return ""
end, 3300, Status.LEFT)

-- Modification time (24h), nil-safe
Status:children_add(function()
  local h = hovered()
  if not h or not h.cha or not h.cha.mtime then return "" end
  local s = tostring(h.cha.mtime)
  local ts = tonumber(s:sub(1, 10))
  if not ts then return "" end
  local t = os.date("%Y-%m-%d %H:%M:%S", ts)
  return ui.Line{ ui.Span(t):fg("blue"), ui.Span(" ") }
end, 500, Status.RIGHT)

-- user:group (unix), nil-safe
Status:children_add(function()
  local h = hovered()
  if not h or ya.target_family() ~= "unix" or not h.cha then return "" end
  local u = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
  local g = ya.group_name(h.cha.gid) or tostring(h.cha.gid)
  return ui.Line{ ui.Span(u):fg("magenta"), ":", ui.Span(g):fg("magenta"), " " }
end, 480, Status.RIGHT)
