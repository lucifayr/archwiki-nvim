local config = require("archwiki._config")
local utils = require("archwiki._utils")

local M = {}

local min_version = "3.1.2"
local max_version = nil

M.setup = config.setup

local res = utils.exec_cmd('archwiki-rs -V')
if not res.success then
    vim.notify(
        "'archwiki-rs' is not installed. 'archwiki-nvim' will not function without it.\n" ..
        "Install the cli tool by running 'cargo install archwiki-rs'\n" ..
        "or reference 'https://gitlab.com/Jackboxx/archwiki-rs/-/blob/main/README.md' for other installation options.",
        vim.log.levels.ERROR)

    M = {}
end

local version = string.gsub(res.stdout, "archwiki%-rs ", "");
if min_version then
    local too_small = utils.cmp_semver_version(version, min_version) == "smaller"
    if too_small then
        vim.notify(
            "'archwiki-rs' version is too small. Some featurs might not work properly.\n" ..
            "Current version " .. version .. "\n" ..
            "Minimum version " .. min_version
        )
    end
end

if max_version then
    local too_large = utils.cmp_semver_version(version, max_version) == "greater"
    if too_large then
        vim.notify(
            "'archwiki-rs' version is too large. Some featurs might not work properly.\n" ..
            "Current version " .. version .. "\n" ..
            "Maximum version " .. max_version
        )
    end
end


return M
