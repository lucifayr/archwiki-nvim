local read_page    = require("archwiki.__read_page")
local pickers      = require("archwiki.__pickers")

local finders      = require("telescope.finders")
local actions      = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M            = {}

local function build_on_select(on_success, on_err)
    return function(prompt_bufnr)
        actions.close(prompt_bufnr)

        local entry = action_state.get_selected_entry()
        local text = action_state.get_current_line()
        local selection = text

        if (entry and entry.value) then
            selection = entry.value.title
        end


        local function default_on_success(bufnr)
            Config.page.handle_buf(bufnr)
        end

        local function default_on_err(err)
            WikiLogger.warn("Failed to load page '" .. selection .. "'")
            WikiLogger.error(err)
        end

        WikiLogger.info("Loading page '" .. selection .. "'")
        read_page.read_page_raw(selection, on_success or default_on_success, on_err or default_on_err)
    end
end

--- Search the ArchWiki for any pages containing the query text.
function M.text_search()
    local args = { "-t", "-L", "25", "-J", "-S", Config.page.format, "-H" }
    local lineMatchIdx = nil

    local function on_select_success(bufnr)
        Config.page.handle_buf(bufnr)
        if lineMatchIdx then
            WikiLogger.trace("going to exact match for text search in buffer with ID " ..
                bufnr .. ' at line ' .. lineMatchIdx)
            vim.api.nvim_buf_call(bufnr, function()
                vim.cmd(":" .. lineMatchIdx)
                vim.cmd("norm zz")
            end)
        end
    end

    pickers.debounced_search(args, build_on_select(on_select_success), {
        prompt_title = "Search ArchWiki for text",
        entry_maker = function(entry)
            return {
                value = entry,
                display = entry.title,
                ordinal = entry.title .. entry.snippet
            }
        end,
        previewer = read_page.previewer({
            title = "Page Snippet",
            post_process = function(bufnr)
                local lines = vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {})
                local text = action_state.get_current_line()

                for idx, line in ipairs(lines) do
                    if string.find(line, text) ~= nil then
                        lineMatchIdx = idx
                        break;
                    end
                end

                if lineMatchIdx then
                    WikiLogger.trace("found exact match for text search in preview buffer with ID " ..
                        bufnr .. ' at line ' .. lineMatchIdx)
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.cmd(":" .. lineMatchIdx)
                        vim.cmd("norm zz")
                    end)
                end
            end
        })
    })
end

--- Search the ArchWiki for any pages with a title similar to the query text.
function M.page_title_search()
    local args = { "-L", "25", "-J" }

    pickers.debounced_search(args, build_on_select(), {
        prompt_title = "Search ArchWiki for pages",
        entry_maker = function(entry)
            return {
                value = entry,
                display = entry.title,
                ordinal = entry.title
            }
        end,
        previewer = read_page.previewer({})
    })
end

--- Search a local list of ArchWiki pages in a telescope picker.
function M.local_page_search()
    pickers.page_picker({
        prompt_title = "Search local pages",
        finder = finders.new_job(function()
            return { "archwiki-rs", "list-pages", "--flatten" }
        end)
    })
end

return M
