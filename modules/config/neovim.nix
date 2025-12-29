{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    # Install required packages for the plugins
    extraPackages = with pkgs; [
      git # Required for lazy.nvim
    ];

    # Set up the configuration files
    extraLuaConfig = ''
      -- Use system clipboard
      vim.opt.clipboard:append("unnamedplus")

      -- Make j and k move through visual lines instead of physical lines
      vim.keymap.set("n", "j", "gj", { noremap = true })
      vim.keymap.set("n", "k", "gk", { noremap = true })

      -- Make H and L go to the start and end of the line
      vim.keymap.set("n", "H", "^", { noremap = true })
      vim.keymap.set("n", "L", "$", { noremap = true })

      -- Keep original j/k behavior available with gj/gk
      vim.keymap.set("n", "gj", "j", { noremap = true })
      vim.keymap.set("n", "gk", "k", { noremap = true })

      vim.opt.compatible = false  -- Use Vim defaults rather than vi (opposite of nocompatible)
      vim.opt.wrap = true         -- Enable line wrapping
      vim.opt.linebreak = true    -- Break lines at word boundaries

      vim.opt.ignorecase = true
      vim.opt.smartcase = true

      -- Lua block for VSCode-Neovim integration
      local function move(d)
        return function()
          -- Only works in charwise visual mode
          if vim.api.nvim_get_mode().mode ~= 'v' then return 'g' .. d end
          require('vscode-neovim').action('cursorMove', {
            args = {
              {
                to = d == 'j' and 'down' or 'up',
                by = 'wrappedLine',
                value = vim.v.count1,
                select = true,
              },
            },
          })
          return '<Ignore>'
        end
      end

      vim.keymap.set({ 'v' }, 'gj', move('j'), { expr = true })
      vim.keymap.set({ 'v' }, 'gk', move('k'), { expr = true })

      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
          local lazyrepo = "https://github.com/folke/lazy.nvim.git"
          local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
          if vim.v.shell_error ~= 0 then
              vim.api.nvim_echo({
                  { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                  { out,                            "WarningMsg" },
                  { "\nPress any key to exit..." },
              }, true, {})
              vim.fn.getchar()
              os.exit(1)
          end
      end
      vim.opt.rtp:prepend(lazypath)

      -- Make sure to setup `mapleader` and `maplocalleader` before
      -- loading lazy.nvim so that mappings are correct.
      -- This is also a good place to setup other settings (vim.opt)
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- Setup lazy.nvim with plugins
      require("lazy").setup({
          spec = {
              {
                  "gbprod/substitute.nvim",
                  opts = {
                      -- your configuration comes here
                      -- or leave it empty to use the default settings
                      -- refer to the configuration section below
                  }
              },
              {
                  "folke/tokyonight.nvim",
                  lazy = false,
                  priority = 1000,
                  opts = {},
              },
              {
                  "kylechui/nvim-surround",
                  version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
                  config = function()
                      require("nvim-surround").setup({})
                  end
              },
              { "wellle/targets.vim", event = "VeryLazy" },
              { "tpope/vim-repeat", event = "VeryLazy" },
              {
                  "nvim-tree/nvim-tree.lua",
                  dependencies = { "nvim-tree/nvim-web-devicons" },
                  config = function()
                      require("nvim-tree").setup()
                      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
                  end
              },
          },
          -- Configure any other settings here. See the documentation for more details.
          -- colorscheme that will be used when installing plugins.
          -- install = { colorscheme = { "habamax" } },
          -- automatically check for plugin updates
          checker = { enabled = true },
      })

      vim.cmd[[colorscheme tokyonight]]

      vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
      vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })
    '';
  };
}
