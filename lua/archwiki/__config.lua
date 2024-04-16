local pickers = require("archwiki.__pickers")
local read_page = require("archwiki.__read_page")

---@class Config
---@field page PageConfig
---@field pickers PickerConfig

---@class PageConfig
---@field show_similar boolean
---@field handle_buf function
--
---@class PickerConfig
---@field page_search function
---@field snippet_search function

---@type Config
Config = {
    page = {
        show_similar = true,
        handle_buf = read_page.handle_buf
    },
    pickers = {
        page_search = pickers.page_search,
        snippet_search = pickers.snippet_search
    }
}

local M = {}


---@param cfg table
function M.setup(cfg)
    Config = vim.tbl_deep_extend("force", Config, cfg)
end

return M
