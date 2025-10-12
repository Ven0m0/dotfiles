---@diagnostic disable
version = '1.0.1'
local home = os.getenv("HOME")
package.path = home
.. "/.config/xplr/plugins/?/init.lua;"
.. home
.. "/.config/xplr/plugins/?.lua;"
.. package.path

xplr.config.general.disable_debug_error_mode = true
xplr.config.general.enable_mouse = true
xplr.config.general.show_hidden = true
