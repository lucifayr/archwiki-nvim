# archwiki-nvim

Have any ArchWiki article available instantly

![preview](./preview.gif)

## Dependencies
This plugin uses the CLI tool [archwiki-rs](https://github.com/jackboxx/archwiki-rs). 
Installation instructions are available [here](https://github.com/jackboxx/archwiki-rs#installation).

## Installation

### Plug

```
Plug 'nvim-telescope/telescope.nvim'
Plug 'Jackboxx/archwiki-nvim'
```

### Packer
```lua
    use {
        'Jackboxx/archwiki-nvim',
        requires = { 'nvim-telescope/telescope.nvim' }
    }
```

### Lazy
```lua
    {
        'Jackboxx/archwiki-nvim', 
        dependencies = { 'nvim-telescope/telescope.nvim' }
    }
```

## Usage
```lua
-- read page as plain text
vim.keymap.set('n', '<leader>awp', '<cmd>lua require("archwiki.api").select_page_from_local()<cr>')
-- read page as markdown
vim.keymap.set('n', '<leader>awm', '<cmd>lua require("archwiki.api").select_page_from_local("-f markdown")<cr>')
-- read page as html
vim.keymap.set('n', '<leader>awh', '<cmd>lua require("archwiki.api").select_page_from_local("-f html")<cr>')
```
