local pickers = require("archwiki.__pickers")
local read_page = require("archwiki.__read_page")

local log = require("plenary.log")
Logger = log:new()

---@class Config
---@field page ConfigPage
---@field pickers ConfigPickers
---@field mappings ConfigMappings
---@field log_level string

---@class ConfigPage
---@field format string
---@field show_similar boolean
---@field handle_buf function

---@class ConfigPickers
---@field similar_pages function

---@class ConfigMappings
---@field reload_search string

---@type Config
Config = {
    log_level = "error",
    page      = {
        format = "markdown",
        show_similar = true,
        handle_buf = read_page.handle_buf
    },
    pickers   = {
        similar_pages = pickers.page_picker_itemized,
    },
    mappings  = {
        reload_search = "<S-r>"
    }
}
