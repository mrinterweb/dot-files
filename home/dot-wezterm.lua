local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Appearance
config.font_size = 16
config.line_height = 1.2
config.color_scheme = "tokyonight_night"

config.window_decorations = "RESIZE"
-- config.enable_tab_bar = false

-- Keybindings
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
local act = wezterm.action
config.keys = {
  {key="w", mods="CMD", action=wezterm.action{CloseCurrentPane={confirm=false}}},
  {key="d", mods="CMD", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
  {key="D", mods="CMD|SHIFT", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
  {key="h", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Left"}},
  {key="j", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Down"}},
  {key="k", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Up"}},
  {key="l", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Right"}},
  {key="k", mods="CMD", action=wezterm.action.SendString "clear\n"},
  {key="k", mods="LEADER", action=wezterm.action.SendString("printf '\\x1b[K'")},
  { key = '{', mods = 'SHIFT|ALT', action = act.MoveTabRelative(-1) },
  { key = '}', mods = 'SHIFT|ALT', action = act.MoveTabRelative(1) },
}

return config
