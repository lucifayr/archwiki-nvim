local read_page = require("archwiki._read_page")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}


---@param items string[]
function M.page_search(items)
    pickers.new({}, {
        prompt_title = "ArchWiki Pages",
        finder = finders.new_table {
            results = items
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                local text = action_state.get_current_line()
                local selection = text

                if (entry and entry[1]) then
                    selection = entry[1]
                end


                local res = read_page.read_page_raw(selection)
                if res.buf then
                    Config.page.handle_buf(res.buf)
                else
                    vim.notify("Failed to fetch page '" .. selection "'", vim.log.levels.WARN)
                end
            end)

            return true
        end,

    }):find()
end

function M.snippet_search()

end

return M
