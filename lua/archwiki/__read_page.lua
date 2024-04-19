local utils            = require("archwiki.__utils")
local job              = require("plenary.job")
local previewers       = require("telescope.previewers")
local previewers_utils = require('telescope.previewers.utils')

local M                = {}

---@class ReadPageRaw
---@field buf integer|nil Buffer that is created after a successful page read.
---@field err string|nil Any output sent to stderr.

---Read a page from the ArchWiki.
---@param page string
---@param on_success function
---@param on_err function
---@param extra string[]|nil
function M.read_page_raw(page, on_success, on_err, extra)
    local stdout = ""
    local args = utils.join_array({ "read-page", page, "--format", "markdown" }, extra or {})

    job:new({
        command = "archwiki-rs",
        args = args,
        on_stdout = function(_, out)
            if not out then
                return
            end

            if string.gsub(out, "%s+", "") == "" then
                stdout = stdout .. "\n"
            else
                stdout = stdout .. out
            end
        end,
        on_exit = function(job, code)
            vim.schedule(function()
                if code == 0 then
                    local buf = vim.api.nvim_create_buf(false, false)
                    local data = utils.lines(stdout)

                    vim.api.nvim_buf_set_lines(buf, 0, 0, true, data)
                    vim.api.nvim_buf_set_option(buf, "modified", false)

                    on_success(buf)
                else
                    on_err(job:stderr_result())
                end
            end)
        end
    }):start()
end

function M.previewer()
    return previewers.new_buffer_previewer({
        title = "Page Preview",
        define_preview = function(self, entry)
            previewers_utils.highlighter(self.state.bufnr, "markdown")

            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, { "Loading..." })

            local selection = entry.display
            local function on_success(bufnr)
                local lines = vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {})
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, lines)
            end
            local function on_err()
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true,
                    { "Failed to fetch page" })
            end

            M.read_page_raw(selection, on_success, on_err)
        end,
    })
end

---Read a page from the ArchWiki.
---@param page string
---@param extra string[]|nil
function M.read_page(page, extra)
    local function on_success(bufnr)
        Config.page.handle_buf(bufnr)
    end

    local function on_err(err)
        if Config.page.show_similar and err[1] == "SIMILAR PAGES" then
            table.remove(err, 1)
            Config.pickers.page_search(err)
        else
            vim.notify("Failed to reag page '" .. page .. "'", vim.log.levels.WARN)
            Logger.debug(err)
        end
    end

    vim.notify("Fetching page '" .. page .. "'", vim.log.levels.INFO)
    M.read_page_raw(page, on_success, on_err, extra)
end

---@param buf integer
function M.handle_buf(buf)
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.cmd("b" .. buf)
end

return M
