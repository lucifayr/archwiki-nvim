# archwiki-nvim 📖

Have any ArchWiki page available instantly.

![](./preview.mp4)

## Table of contents

<!--toc:start-->

- [Dependencies](#dependencies)
- [Installation](#installation)
  - [Packer](#packer)
  - [Lazy](#lazy)
  - [Plug](#plug)
- [Usage](#usage)
- [Config](#config)
  - [Custom page handling - Open page in split window](#custom-page-handling-open-page-in-split-window)
  - [Custom similar page picker - No preview](#custom-similar-page-picker-no-preview)
  <!--toc:end-->

## Dependencies

This plugin uses the CLI tool [archwiki-rs](https://gitlab.com/jackboxx/archwiki-rs).
Installation instructions are available [here](https://gitlab.com/jackboxx/archwiki-rs#installation).

## Installation

### Packer

```lua
use {
    'https://gitlab.com/Jackboxx/archwiki-nvim',
    requires = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
}
```

### Lazy

```lua
{
    'https://gitlab.com/Jackboxx/archwiki-nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
}
```

### Plug

```
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'https://gitlab.com/Jackboxx/archwiki-nvim'
```

## Usage

```lua
vim.keymap.set('n', '<leader>ar', function() require("archwiki").read_page() end)
vim.keymap.set('n', '<leader>ast', function() require("archwiki").text_search() end)
vim.keymap.set('n', '<leader>asp', function() require("archwiki").page_search() end)
vim.keymap.set('n', '<leader>asl', function() require("archwiki").local_search() end)
```

## Config

```lua
-- All available config options and their defaults
require('archwiki').setup({
    page = {
        -- Format argument passed to 'archwiki-rs read-page'. See 'archwiki-rs help read-page' for more information
        --  Valid options: ["plain-text", "markdown", "html"]
        format = "markdown",
        -- Show pages with a similar name when no page is found with 'read-page'.
        show_similar = true,
        -- What to do with a page after it has been fetched.
        -- Default: open in new buffer with filetype 'format'.
        handle_buf = ...
    },
    pickers = {
        -- 'telescope.nvim' picker used to display similar pages.
        similar_pages = ...
    },
    mappings = {
        -- Keymap to display new search results when using 'text_search' or 'page_search'.
        reload_search = "<S-r>"
    },
    logging  = {
        -- 'plenary.nvim' log level.
        -- Valid options: ["trace", "debug", "info", "warn", "error", "fatal"]
        level = "info",
        -- Show source file and line numbers for logs
        detailed = false,
    },
})
```

#### Custom page handling - Open page in split window

```lua
local archwiki = require('archwiki')

archwiki.setup({
    page = {
        handle_buf = function(bufnr)
            vim.api.nvim_buf_set_option(bufnr, "readonly", true)
            vim.api.nvim_buf_set_option(bufnr, "filetype", archwiki.config.page.format)

            vim.cmd.vsplit()
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, bufnr)
        end
    }
})
```

#### Custom similar page picker - No preview

```lua
local archwiki = require('archwiki')
local pickers  = require("telescope.pickers")
local finders  = require("telescope.finders")

archwiki.setup({
    pickers = {
        similar_pages = function (items)
            pickers.new({}, {
                prompt_title = "Similar Pages",
                results_title = "Search Similar pages",
                finder = finders.new_table({
                    results = items
                }),
            }):find()
        end
    },
})
```
