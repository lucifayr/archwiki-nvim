local read_page = require("archwiki.__read_page")
local utils = require("archwiki.__utils")

local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}


---@param items string[]
function M.page_search(items)
    pickers.new({}, {
        prompt_title = "Pages",
        finder = finders.new_table {
            results = items
        },
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            title = "Page Preview",
            define_preview = function(self, entry)
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, { "Loading..." })

                local selection = entry[1]
                local function on_success(bufnr)
                    local lines = vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {})
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, lines)
                end
                local function on_err()
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true,
                        { "Failed to fetch page '" .. selection .. "'" })
                end

                read_page.read_page_raw(selection, on_success, on_err)
            end
        }),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                local text = action_state.get_current_line()
                local selection = text

                if (entry and entry[1]) then
                    selection = entry[1]
                end


                local function on_success(bufnr)
                    Config.page.handle_buf(bufnr)
                end
                local function on_err()
                    vim.notify("Failed to fetch page '" .. selection .. "'", vim.log.levels.WARN)
                end

                read_page.read_page_raw(selection, on_success, on_err)
            end)

            return true
        end,

    }):find()
end

---@class TextSnippet
---@field title string
---@field snippet string

---@param items TextSnippet[]
function M.snippet_search(items)
    pickers.new({}, {
        prompt_title = "Search Results",
        finder = finders.new_table({
            results = items,
            entry_maker = function(entry)
                local snippet = entry
                return {
                    value = snippet,
                    display = snippet.title,
                    ordinal = snippet.title
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            title = "Snippet",
            define_preview = function(self, entry)
                Logger.debug(entry)
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, utils.lines(entry.value.snippet))
            end
        }),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
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
            end)

            return true
        end,

    }):find()
end

return M
