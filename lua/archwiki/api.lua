-- used to warn users at commit f770bfbdb3b60f7c0dc73b1685e476aabe98e773 or earlier
-- that their have been breaking changes

---@param fn_name string
---@param replacements string[]
local function warn_no_longer_exists(fn_name, replacements)
    assert(#replacements ~= 0)
    return function()
        vim.notify(
            "Function '" ..
            fn_name .. "' no longer exists. It was replaced by [" .. vim.fn.join(replacements, ', ') .. "]",
            vim.log.levels.ERROR)
    end
end

local M = {}

M.select_page_from_local = warn_no_longer_exists("select_page_from_local", { "read_page", "local_search" })
M.read_page_into_buffer = warn_no_longer_exists("read_page_into_buffer", { "read_page", "read_page_raw" })

return M
