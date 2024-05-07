-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = {}

config.enable_tab_bar = false -- no

config.window_background_opacity = 1.0
--config.text_background_opacity = 0.8

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
--config.color_scheme = 'astromouse (terminal.sexy)'
--config.color_scheme = 'Aci (Gogh)'
--config.color_scheme = require('aco_gogh_drgn')
local aco_drgn = wezterm.color.get_builtin_schemes()['Aco (Gogh)']
aco_drgn.background = "#0e0e0e"
aco_drgn.foreground = "#e0e0e0"
aco_drgn.cyan = "#04ecf0"

config.color_schemes = {
  ['aco_drgn'] = aco_drgn,
}

config.color_scheme = 'aco_drgn'


--config.font = wezterm.font('0xProto Nerd Font Mono', { italic = false, intensity = "Normal" })
config.font = wezterm.font('0xProto Nerd Font Mono')
config.font_size = 16.0


-- and finally, return the configuration to wezterm
return config
