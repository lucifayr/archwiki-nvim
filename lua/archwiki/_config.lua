---@class Config
---@field page PageConfig

---@class PageConfig
---@field show_similar boolean

---@type Config
Config = {
    page = {
        show_similar = true,
    }
}

local M = {}


---@param cfg Config
function M.setup(cfg)
    Config = vim.tbl_deep_extend("force", Config, cfg)
end

return M
