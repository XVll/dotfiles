-- Plugins configuration
-- Add your custom plugins here

return {
    -- Tokyo Night colorscheme (matches WezTerm)
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            transparent = false,
        },
    },

    -- Configure LazyVim colorscheme
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "tokyonight",
        },
    },

    -- Better telescope defaults
    {
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
            },
        },
    },

    -- Add telescope-fzf-native for faster search
    {
        "telescope.nvim",
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
    },

    -- Language extras
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },

    -- Additional treesitter parsers
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "bash",
                "html",
                "css",
                "javascript",
                "typescript",
                "tsx",
                "json",
                "yaml",
                "toml",
                "lua",
                "python",
                "go",
                "rust",
                "markdown",
                "markdown_inline",
            })
        end,
    },

    -- Mason tools
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "shellcheck",
                "shfmt",
                "prettier",
            },
        },
    },
}
