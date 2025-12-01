local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ===== Appearance =====
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 14.0
config.line_height = 1.2

config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- ===== Cursor =====
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- ===== Scrollback =====
config.scrollback_lines = 10000

-- ===== Platform-specific defaults =====
if wezterm.target_triple:find("windows") then
    -- Windows: Default to WSL
    config.default_domain = "WSL:Ubuntu"
    -- Or use PowerShell: config.default_prog = { "pwsh.exe" }
elseif wezterm.target_triple:find("darwin") then
    -- macOS
    config.default_prog = { "/opt/homebrew/bin/zsh", "-l" }
else
    -- Linux
    config.default_prog = { "zsh", "-l" }
end

-- ===== Key Bindings =====
config.keys = {
    -- Split panes
    { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "CMD", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Navigate panes
    { key = "h", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "l", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "k", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "j", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

    -- Close pane
    { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

    -- New tab
    { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

    -- Navigate tabs
    { key = "[", mods = "CMD", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "]", mods = "CMD", action = wezterm.action.ActivateTabRelative(1) },

    -- Clear scrollback
    { key = "k", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

    -- Search
    { key = "f", mods = "CMD", action = wezterm.action.Search({ CaseInSensitiveString = "" }) },

    -- Copy/Paste
    { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
    { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
}

-- ===== Mouse =====
config.mouse_bindings = {
    -- Right-click paste
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wezterm.action.PasteFrom("Clipboard"),
    },
}

return config
