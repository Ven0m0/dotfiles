---@diagnostic disable
version = '1.0.1'
package.path = os.getenv("HOME") .. "/.config/xplr/plugins/?.lua"
require("ui").setup()
require("keys").setup()
require("plug").setup()
xplr.config.general.disable_debug_error_mode = true
xplr.config.general.enable_mouse = true
xplr.config.general.show_hidden = true
