require("git"):setup{ order = 0 }
require("full-border"):setup()
require("starship"):setup()
require("smart-enter"):setup{ open_multi = true }

-- Symlink target in status
Status:children_add(function(self)
  local h = self._current and self._current.hovered
  if h and h.link_to then
    return " -> " .. tostring(h.link_to)
  end
  return ""
end, 3300, Status.LEFT)

-- Modification time (24h), nil-safe
Status:children_add(function()
  local a = cx.active
  if not a or not a.current then return "" end
  local h = a.current.hovered
  if not h or not h.cha or not h.cha.mtime then return "" end
  local ts = tonumber(tostring(h.cha.mtime):sub(1, 10))
  local t = os.date("%Y-%m-%d %H:%M:%S", ts)
  return ui.Line{
    ui.Span(t):fg("blue"),
    ui.Span(" "),
  }
end, 500, Status.RIGHT)

-- user:group (unix), nil-safe
Status:children_add(function()
  local a = cx.active
  if not a or not a.current then return "" end
  local h = a.current.hovered
  if not h or ya.target_family() ~= "unix" then
    return ""
  end
  return ui.Line{
    ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
    ":",
    ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
    " ",
  }
end, 500, Status.RIGHT)
