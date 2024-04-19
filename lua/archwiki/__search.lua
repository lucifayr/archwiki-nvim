local utils = require("archwiki.__utils")
local read_page = require("archwiki.__read_page")
local pickers = require("archwiki.__pickers")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local previewers_utils = require('telescope.previewers.utils')

local M = {}

---Read a page from the ArchWiki.
---@param extra string[]|nil
function M.text_search(extra)
    local cmd = "archwiki-rs"
    local default_args = { "-t", "-L", "25", "-J", "-S", "markdown" }
    local args = vim.tbl_deep_extend("force", default_args, extra or {})

    local function on_select(prompt_bufnr)
        actions.close(prompt_bufnr)

        local entry = action_state.get_selected_entry()
        local text = action_state.get_current_line()
        local selection = text

        if (entry and entry.value) then
            selection = entry.value.title
        end


        local function on_success(bufnr)
            Config.page.handle_buf(bufnr)
        end
        local function on_err()
            vim.notify("Failed to fetch page '" .. selection .. "'", vim.log.levels.WARN)
        end

        read_page.read_page_raw(selection, on_success, on_err)
    end

    pickers.debounced_search(cmd, { "search", unpack(args) }, on_select, {
        entry_maker = function(entry)
            return {
                value = entry,
                display = entry.title,
                ordinal = entry.title .. entry.snippet
            }
        end,
        previewer = previewers.new_buffer_previewer({
            title = "Snippet",
            define_preview = function(self, entry)
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, utils.lines(entry.value.snippet))
                previewers_utils.highlighter(self.state.bufnr, "markdown")
            end
        })
    })
end

return M
