local utils = require("archwiki._utils")

local M = {}

---@class ReadPageRaw
---@field buf integer|nil Buffer that is created after a successful page read.
---@field err string|nil Any output sent to stderr.

---Read a page from the ArchWiki.
---@param page string
---@param extra string|nil
---@return ReadPageRaw
function M.read_page_raw(page, extra)
    local cmd = "archwiki-rs read-page \"" .. page .. "\" " .. (extra or "")
    local res = utils.exec_cmd(cmd)

    if not res.success then
        return {
            err = res.stderr
        }
    end

    local buf = vim.api.nvim_create_buf(false, false)
    local data = utils.split(res.stdout, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, 0, true, data)

    return {
        buf = buf
    }
end

---Read a page from the ArchWiki.
---@param page string
---@param extra string|nil
function M.read_page(page, extra)
    local res = M.read_page_raw(page, extra)

    if res.buf then
        Config.page.handle_buf(res.buf)
    elseif res.err then
        if Config.page.show_similar then
            local suggestions = utils.split(res.err, "\n")
            Config.pickers.page_search(suggestions)
        end
    end
end

---@param buf integer
function M.handle_buf(buf)
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.api.nvim_buf_set_option(buf, "modified", false)
    vim.cmd("b" .. buf)
end

return M
