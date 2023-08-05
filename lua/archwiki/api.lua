local utils = require("archwiki.utils")

local Archwiki = {}

---comment
---@param extra_args string?
---@param on_err function?
function Archwiki.select_page_from_local(extra_args, on_err)
    local exit, out = utils.execute_command("archwiki-rs list-pages -f")
    if (exit == false) then
        print("failed to run `archwiki-rs` command")
        return
    end

    local pages = utils.split(out, "\n")
    utils.select_item(pages, function(page)
        Archwiki.read_page_into_buffer(page, extra_args, on_err)
    end)
end

---comment
function Archwiki.update_category_from_local()
    local exit, out = utils.execute_command("archwiki-rs list-categories")
    if (exit == false) then
        print("failed to run `archwiki-rs` command")
        return
    end

    local categories = utils.split(out, "\n")
    utils.select_item(categories, function(category)
        Archwiki.update_category(category)
    end)
end

---comment
---@param page string
---@param extra_args string?
---@param on_err function?
---@return integer
function Archwiki.read_page_into_buffer(page, extra_args, on_err)
    local extra_args = extra_args or ""
    local on_err = on_err or function(similar)
        if next(similar) == nil then
            print("page doesn't exist and no similar pages were found")
        else
            utils.select_item(similar, function(page)
                Archwiki.read_page_into_buffer(page, extra_args, function()
                    print("failed to read ArchWiki page")
                end)
            end, "Similar Pages")
        end
    end

    local exit, out, err = utils.execute_command("archwiki-rs read-page \"" .. page .. "\" " .. extra_args)
    if (exit == false) then
        print('failed to run `archwiki-rs` command')
        return 0
    end

    if (err ~= "") then
        on_err(utils.split(err, "\n"))
        return 0
    end

    local buf = vim.api.nvim_create_buf(false, false)
    local data = utils.split(out, "\n")

    vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, data)
    vim.cmd("b" .. buf)

    return buf
end

---comment
---@param category string
function Archwiki.update_category(category)
    local suc = os.execute("archwiki-rs update-category " .. category)
    if (suc) then
        print("updating category")
    else
        print("failed to update category")
    end
end

return Archwiki
