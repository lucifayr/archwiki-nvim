# archwiki-nvim

Have any ArchWiki article available immediately.


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
