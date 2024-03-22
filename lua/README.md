# nix-cmp

This is a *source* for the [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
plugin to try and provide auto-completion in nix files.

## Builtins completion

We provide completion for `builtins` based on _syntax_: any time you input
verbatim `builtins.`, completion will trigger. A future improvement would only
fire on the "actual" `builtins` (and not e.g. for a function argument named in the
same way).

The list is built at runtime using `nix-instantiate`.

### Setup
- put the `nix-cmp.lua` file in a know location like `~/.config/nvim/lua`
- register the source before calling `nvim-cmp` setup function
- enable it on nix file only

Here is one I update my config

```
-- configuration of nvim-cmp
local cmp = require('cmp')

-- add that first
cmp.register_source('nix-cmp', require('nix-cmp'))

cmp.setup({
  -- your normal setup config here
  -- ...

  -- my "general" cmp config
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }, {
      { name = 'path' },
      { name = 'buffer' },
    }),
    experimental = {
      ghost_text = true,
    },
})

-- specific config for .nix files
cmp.setup.filetype('nix', {
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nix-cmp' }
  }, {
      { name = 'path' },
      { name = 'buffer' },
    }),
    experimental = {
      ghost_text = true,
    },
})
```
