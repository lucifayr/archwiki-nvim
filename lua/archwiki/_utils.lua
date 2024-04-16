local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

---@param s string
---@param sep string
---@returns string[]
function M.split(s, sep)
    local result = {}
    for field in string.gmatch(s, string.format("([^%s]+)", sep)) do
        table.insert(result, field)
    end
    return result
end

function M.select_item(items, on_select, title)
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

---@class CmdResult
---@field success boolean
---@field stdout string | nil
---@field stderr string | nil

---@param command string
---@returns CmdResult
function M.exec_cmd(command)
    local tmpfile = os.tmpname()
    local exit = os.execute(command .. ' > ' .. tmpfile .. ' 2> ' .. tmpfile .. '.err')

    local stdout_file = io.open(tmpfile)
    local stdout = nil
    if stdout_file ~= nil then
        stdout = stdout_file:read("*all")
        stdout_file:close()
    end


    local stderr_file = io.open(tmpfile .. '.err')
    local stderr = nil
    if stderr_file ~= nil then
        stderr = stderr_file:read("*all")
        stderr_file:close()
    end

    return {
        success = exit == 0,
        stdout = stdout,
        stderr = stderr,
    }
end

---@param triple_b string[]
---@param triple_a string[]
---@param digit "major"|"minor"|"patch"
---@returns "greater"|"equal"|"smaller"
local function cmp_semver_version_digit(triple_a, triple_b, digit)
    ---@type integer
    local idx
    if digit == "major" then
        idx = 1
    elseif digit == "minor" then
        idx = 2
    else
        idx = 3
    end

    local ver_a = tonumber(triple_a[idx])
    assert(ver_a ~= nil,
        "semantic version string contains the none number value '" .. triple_a[idx] .. "' as the " .. digit .. " version")
    local ver_b = tonumber(triple_b[idx])
    assert(ver_b ~= nil,
        "semantic version string contains the none number value '" .. triple_b[idx] .. "' as the " .. digit .. " version")

    if ver_a > ver_b then
        return "greater"
    elseif ver_a < ver_b then
        return "smaller"
    end

    return "equal"
end

--- Compare 2 semantic version strings of the form x.y.z
---@param a string
---@param b string
---@returns "greater"|"equal"|"smaller"
function M.cmp_semver_version(a, b)
    local triple_a = M.split(a, ".");
    assert(#triple_a == 3, "semantic version string '" .. a .. "' is not of the form 'x.y.z'")

    local triple_b = M.split(b, ".");
    assert(#triple_b == 3, "semantic version string '" .. b .. "' is not of the form 'x.y.z'")

    local ord_major = cmp_semver_version_digit(triple_a, triple_b, "major")
    if ord_major ~= "equal" then
        return ord_major
    end

    local ord_minor = cmp_semver_version_digit(triple_a, triple_b, "minor")
    if ord_minor ~= "equal" then
        return ord_minor
    end

    return cmp_semver_version_digit(triple_a, triple_b, "patch")
end

return M
