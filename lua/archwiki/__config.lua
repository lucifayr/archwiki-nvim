local pickers = require("archwiki.__pickers")
local read_page = require("archwiki.__read_page")

---@class Config
---@field page ConfigPage
---@field pickers ConfigPickers
---@field mappings ConfigMappings
---@field logging ConfigLogging

---@class ConfigPage
---@field format string
---@field show_similar boolean
---@field handle_buf function

---@class ConfigPickers
---@field similar_pages function

---@class ConfigMappings
---@field reload_search string
--
---@class ConfigLogging
---@field level "trace"|"debug"|"info"|"warn"|"error"|"fatal"
---@field detailed boolean

---@type Config
Config = {
    page     = {
        format = "markdown",
        show_similar = true,
        handle_buf = read_page.handle_buf
    },
    pickers  = {
        similar_pages = pickers.page_picker_itemized,
    },
    mappings = {
        reload_search = "<S-r>"
    },
    logging  = {
        level = "info",
        detailed = false,
    },
}
