local utils = require("archwiki.__utils")
local job = require("plenary.job")
local pickers = require("archwiki.__pickers")


local M = {}

---@class ReadPageRaw
---@field buf integer|nil Buffer that is created after a successful page read.
---@field err string|nil Any output sent to stderr.

---Read a page from the ArchWiki.
---@param query string
---@param extra string[]|nil
function M.search(query, extra)
    local stdout = ""
    local default_args = { "-t", "-L", "25", "-J" }
    local args = vim.tbl_deep_extend("force", default_args, extra or {})

    job:new({
        command = "archwiki-rs",
        args = { "search", query, unpack(args) },
        on_stdout = function(__err, out)
            if not out then
                return
            end

            stdout = stdout .. out
        end,
        on_exit = function(job, code)
            vim.schedule(function()
                if code == 0 then
                    local items = vim.json.decode(stdout)
                    if items then
                        pickers.snippet_search(items)
                    end
                end
            end)
        end
    }):start()
end

return M
