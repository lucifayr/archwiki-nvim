local read_page    = require("archwiki.__read_page")
local utils        = require("archwiki.__utils")

local job          = require("plenary.job")

local pickers      = require("telescope.pickers")
local previewers   = require("telescope.previewers")
local finders      = require("telescope.finders")
local conf         = require("telescope.config").values
local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M            = {}

---@class TextSnippet
---@field title string
---@field snippet string

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

--- TODO
---@class DebouncedSearchOpts
---@field timeout number|nil
---@field prompt_title string|nil
---@field previewer function|nil
---@field entry_maker function|nil

---TODO
---@param cmd string
---@param args string[]
---@param on_select function TODO
---@param opts DebouncedSearchOpts TODO
function M.debounced_search(cmd, args, on_select, opts)
    local items = {}
    local runnin_job = nil
    local picker = nil
    local prev_prompt = nil

    local function on_prompt_line_change(text)
        if text == prev_prompt then
            return
        end

        if runnin_job ~= nil then
            runnin_job:shutdown()
        end

        local stdout = ""
        runnin_job = job:new({
            command = cmd,
            args = utils.join_array(args, { text }),
            on_stdout = function(_, out)
                if not out then
                    return
                end

                stdout = stdout .. out
            end,
            on_exit = function(_, code)
                vim.schedule(function()
                    if code == 0 then
                        local parsed = vim.json.decode(stdout)
                        if parsed and picker and #parsed ~= 0 then
                            items = parsed
                            picker:refresh()
                        end
                    end
                end)
            end
        })

        runnin_job:start()
    end

    local search_finder = finders.new_dynamic({
        fn = function(prompt)
            on_prompt_line_change(prompt)
            prev_prompt = prompt
            return items
        end,
        entry_maker = opts.entry_maker
    })

    picker = pickers.new({}, {
        prompt_title = opts.prompt_title or "Search the ArchWiki",
        finder = search_finder,
        sorter = conf.generic_sorter({}),
        previewer = opts.previewer,
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                on_select(prompt_bufnr)
            end)
            return true
        end,
    })

    picker:find()
end

return M
