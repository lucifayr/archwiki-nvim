local utils            = require("archwiki.__utils")
local job              = require("plenary.job")
local previewers       = require("telescope.previewers")
local previewers_utils = require('telescope.previewers.utils')


local M = {}

---@class ReadPageRaw
---@field buf integer|nil Buffer that is created after a successful page read.
---@field err string|nil Any output sent to stderr.

---Read a page from the ArchWiki.
---Useful when creating custom telescope previewers.
---@param page string
---@param on_success function
---@param on_err function
---@param extra string[]|nil
function M.read_page_raw(page, on_success, on_err, extra)
    WikiLogger.trace("running 'archwiki-rs read-page' with page '" .. page .. "'")

    local stdout = ""
    local args = utils.array_join({ "read-page", page, "--format", Config.page.format }, extra or {})

    job:new({
        command = "archwiki-rs",
        args = args,
        on_stdout = function(_, out)
            if not out then
                return
            end

            stdout = stdout .. out .. "\n"
        end,
        on_exit = function(job, code)
            vim.schedule(function()
                if code == 0 then
                    local buf = vim.api.nvim_create_buf(false, false)
                    local data = vim.split(stdout, "\n")

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

---@param opts table
---@return unknown
function M.previewer(opts)
    return previewers.new_buffer_previewer({
        title = opts.title or "Page Preview",
        define_preview = function(self, entry)
            previewers_utils.highlighter(self.state.bufnr, Config.page.format)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, { "Loading..." })

            local selection = entry.display
            local preview_bufner = self.state.bufnr
            local function on_success(bufnr)
                if not vim.api.nvim_buf_is_valid(preview_bufner) then
                    return
                end

                local lines = vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {})
                vim.api.nvim_buf_set_lines(preview_bufner, 0, -1, true, lines)

                if opts.post_process then
                    opts.post_process(preview_bufner, entry)
                end
            end
            local function on_err()
                if not vim.api.nvim_buf_is_valid(preview_bufner) then
                    return
                end

                vim.api.nvim_buf_set_lines(preview_bufner, 0, -1, true,
                    { "Failed to load page" })
            end

            M.read_page_raw(selection, on_success, on_err)
        end,
    })
end

---Read a page from the ArchWiki.
---@param page string|nil
function M.read_page(page)
    if page == nil or #page == 0 then
        page = vim.fn.input("page name: ")
        if #page == 0 then
            return
        end
    end

    local function on_success(bufnr)
        Config.page.handle_buf(bufnr)
    end

    local function on_err(err)
        if Config.page.show_similar and err[1] == "SIMILAR PAGES" then
            table.remove(err, 1)
            local similar = utils.filter(err, function(v)
                return string.gsub(v, "%s+", "") ~= ""
            end)

            if #similar ~= 0 then
                Config.pickers.similar_pages(similar,
                    { prompt_title = "Search similar pages", results_title = "Similar Pages" })
            else
                WikiLogger.warn('No pages similar to "' .. page .. '" were found')
            end
        else
            WikiLogger.warn("Failed to load page '" .. page .. "'")
            WikiLogger.error(err)
        end
    end

    WikiLogger.info("Loading page '" .. page .. "'")
    M.read_page_raw(page, on_success, on_err)
end

---@param bufnr integer
function M.handle_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "readonly", true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", Config.page.format)

    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, bufnr)
end

return M
