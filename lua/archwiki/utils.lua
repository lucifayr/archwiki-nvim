local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function select_item(items, on_select, title)
    pickers.new({}, {
        prompt_title = title or "ArchWiki Pages",
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

                on_select(selection)
            end)
            return true
        end,

    }):find()
end

local function split(s, sep)
    local result = {}
    for field in string.gmatch(s, string.format("([^%s]+)", sep)) do
        table.insert(result, field)
    end
    return result
end

local function execute_command(command)
    local tmpfile = '/tmp/lua_execute_tmp_file'
    local exit = os.execute(command .. ' > ' .. tmpfile .. ' 2> ' .. tmpfile .. '.err')

    local stdout_file = io.open(tmpfile)
    local stdout = stdout_file:read("*all")

    local stderr_file = io.open(tmpfile .. '.err')
    local stderr = stderr_file:read("*all")

    stdout_file:close()
    stderr_file:close()

    return exit, stdout, stderr
end

return {
    select_item = select_item,
    split = split,
    execute_command = execute_command
}
