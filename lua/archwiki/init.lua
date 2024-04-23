require("archwiki.__config")

local utils = require("archwiki.__utils")
local read_page = require("archwiki.__read_page")
local search = require("archwiki.__search")

local log = require("plenary.log")

local M = {}

local min_version = "3.2.0"
local max_version = nil

---@param cfg table
function M.setup(cfg)
    Config = vim.tbl_deep_extend("force", Config, cfg or {})

    WikiLogger = log:new()
    WikiLogger.plugin = "archwiki-nvim"
    WikiLogger.level = Config.logging.level

    if not Config.logging.detailed then
        WikiLogger.fmt_msg = function(is_console, mode_name, _, _, msg)
            local name_upper = mode_name:upper()
            if is_console then
                return string.format("%s: %s", name_upper, msg)
            else
                return string.format("%s: %s\n", name_upper, msg)
            end
        end
    end


    local res = utils.exec_cmd('archwiki-rs -V')
    if not res.success then
        local msg = "'archwiki-rs' is not installed. 'archwiki-nvim' will not function without it.\n" ..
            "Install the cli tool by running 'cargo install archwiki-rs'\n" ..
            "or reference 'https://gitlab.com/Jackboxx/archwiki-rs/-/blob/main/README.md' for other installation options."

        WikiLogger.fatal(msg)
        return
    end

    M.read_page = read_page.read_page
    M.read_page_raw = read_page.read_page_raw
    M.text_search = search.text_search
    M.page_search = search.page_title_search
    M.local_search = search.local_page_search
    M.config = Config

    local version = string.gsub(res.stdout, "archwiki%-rs ", "");
    if min_version then
        local too_small = utils.cmp_semver_version(version, min_version) == "smaller"
        if too_small then
            local msg = "'archwiki-rs' version is too small. Some featurs might not work properly.\n" ..
                "Current version " .. version .. "\n" ..
                "Minimum version " .. min_version

            WikiLogger.warn(msg)
        end
    end

    if max_version then
        local too_large = utils.cmp_semver_version(version, max_version) == "greater"
        if too_large then
            local msg = "'archwiki-rs' version is too large. Some featurs might not work properly.\n" ..
                "Current version " .. version .. "\n" ..
                "Maximum version " .. max_version

            WikiLogger.warn(msg)
        end
    end

    utils.fetch_wiki_metadata()
end

return M
