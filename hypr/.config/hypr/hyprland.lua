-- Hyprland 0.55+ native Lua config.
-- Legacy hyprlang config is kept in hyprland.old.conf.

local colors = require 'hyprland/colors'
local programs = require 'hyprland/programs'

require 'hyprland/monitors'
require 'hyprland/environment'
require 'hyprland/appearance'(colors)
require 'hyprland/input'
require 'hyprland/autostart'(programs)
require 'hyprland/keybindings'(programs)
require 'hyprland/rules'
