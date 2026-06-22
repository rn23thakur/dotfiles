local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ÄÄÄ Appearance ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
config.font = wezterm.font_with_fallback({
    "JetBrainsMono NFP",
    "JetBrainsMono Nerd Font",
})
config.font_size = 15
config.window_decorations = "RESIZE"
if wezterm.target_triple:find("windows") then
    config.default_prog = { 'pwsh.exe', '-NoLogo' }
else
    -- On macOS/Linux, fall back to your native login shell (Zsh)
    config.default_prog = { '/bin/zsh', '--login' }
end
config.color_scheme = 'Catppuccin Mocha'
config.window_background_opacity = 0.97

-- ÄÄÄ Tab Bar (our status bar) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32

-- Catppuccin Mocha palette
local mocha = {
    base    = '#1e1e2e',
    mantle  = '#181825',
    crust   = '#11111b',
    surface0= '#313244',
    surface1= '#45475a',
    overlay1= '#7f849c',
    text    = '#cdd6f4',
    mauve   = '#cba6f7',
    pink    = '#f38ba8',
    green   = '#a6e3a1',
    yellow  = '#f9e2af',
    blue    = '#89b4fa',
    sky     = '#89dceb',
    red     = '#f38ba8',
    peach   = '#fab387',
}

config.colors = {
    tab_bar = {
        background = mocha.crust,
        active_tab = {
            bg_color  = mocha.mauve,
            fg_color  = mocha.base,
            intensity = 'Bold',
        },
        inactive_tab = {
            bg_color = mocha.surface0,
            fg_color = mocha.overlay1,
        },
        inactive_tab_hover = {
            bg_color = mocha.surface1,
            fg_color = mocha.text,
        },
        new_tab = {
            bg_color = mocha.crust,
            fg_color = mocha.overlay1,
        },
    },
}

-- ÄÄÄ Center Window on Startup ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
wezterm.on("gui-startup", function(cmd)
    local screen = wezterm.gui.screens().active
    local ratio  = 0.7
    local width  = screen.width  * ratio
    local height = screen.height * ratio
    local tab, pane, window = wezterm.mux.spawn_window {
        position = {
            x = (screen.width  - width)  / 2,
            y = (screen.height - height) / 2,
            origin = 'ActiveScreen',
        }
    }
    window:gui_window():set_inner_size(width, height)
end)

-- ÄÄÄ Leader ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }

-- ÄÄÄ Key Tables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
config.key_tables = {
    resize_pane = {
        { key = 'h',      action = act.AdjustPaneSize { 'Left',  2 } },
        { key = 'l',      action = act.AdjustPaneSize { 'Right', 2 } },
        { key = 'k',      action = act.AdjustPaneSize { 'Up',    2 } },
        { key = 'j',      action = act.AdjustPaneSize { 'Down',  2 } },
        { key = 'H',      action = act.AdjustPaneSize { 'Left',  6 } },
        { key = 'L',      action = act.AdjustPaneSize { 'Right', 6 } },
        { key = 'K',      action = act.AdjustPaneSize { 'Up',    6 } },
        { key = 'J',      action = act.AdjustPaneSize { 'Down',  6 } },
        { key = 'Escape', action = act.PopKeyTable },
    },
}

-- ÄÄÄ Keys ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
config.keys = {

    -- Pane navigation - LEADER + hjkl
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left'  },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up'    },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down'  },

    -- Splits
    { key = '-',  mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

    -- Resize mode
    { key = 'r', mods = 'LEADER',
      action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

    -- Copy mode
    { key = 'c', mods = 'LEADER', action = act.ActivateCopyMode },

    -- Pane utils
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

    -- Workspaces
    {
        key = 'S', mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'New workspace name:',
            action = wezterm.action_callback(function(window, pane, line)
                if line and #line > 0 then
                    window:perform_action(act.SwitchToWorkspace { name = line }, pane)
                end
            end),
        },
    },
    { key = 'w', mods = 'LEADER',
      action = act.ShowLauncherArgs { flags = 'WORKSPACES', title = 'Switch Workspace' } },
    {
        key = '$', mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'Rename workspace:',
            action = wezterm.action_callback(function(window, pane, line)
                if line and #line > 0 then
                    wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
                end
            end),
        },
    },
    { key = ']', mods = 'LEADER', action = act.SwitchWorkspaceRelative(1)  },
    { key = '[', mods = 'LEADER', action = act.SwitchWorkspaceRelative(-1) },

    -- Tabs
    { key = 't', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1)  },
}

-- ÄÄÄ Status Bar ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
wezterm.on('update-left-status', function(window, pane)
    local is_leader = window:leader_is_active()
    local kt = window:active_key_table()

    -- Determine mode
    local mode_text  = ''
    local mode_bg    = mocha.mauve   -- default: leader color
    local mode_fg    = mocha.base

    if kt == 'resize_pane' then
        mode_text = '  RESIZE '
        mode_bg   = mocha.peach
    elseif is_leader then
        mode_text = '  LDR '
        mode_bg   = mocha.yellow
        mode_fg   = mocha.base
    else
        -- idle: just a subtle left edge, no pill
        window:set_left_status(wezterm.format {
            { Background = { Color = mocha.crust } },
            { Text = '  ' },
        })
        return
    end

    window:set_left_status(wezterm.format {
        -- pill background
        { Foreground = { Color = mode_fg } },
        { Background = { Color = mode_bg } },
        { Attribute  = { Intensity = 'Bold' } },
        { Text = mode_text },
        -- powerline arrow out
        { Foreground = { Color = mode_bg  } },
        { Background = { Color = mocha.crust } },
        { Text = '' },
        { Text = ' ' },
    })
end)

-- Right side: workspace + clock
wezterm.on('update-right-status', function(window, pane)
    local workspace = wezterm.mux.get_active_workspace()
    local time      = wezterm.strftime '%H:%M'
    local date      = wezterm.strftime '%d %b'

    window:set_right_status(wezterm.format {
        { Foreground = { Color = mocha.surface0 } },
        { Background = { Color = mocha.crust    } },
        { Text = '' },
        { Foreground = { Color = mocha.sky      } },
        { Background = { Color = mocha.surface0 } },
        { Text = '  ' .. workspace .. ' ' },
        { Foreground = { Color = mocha.surface1 } },
        { Background = { Color = mocha.surface0 } },
        { Text = '³' },
        { Foreground = { Color = mocha.overlay1 } },
        { Text = ' ' .. date .. ' ' },
        { Text = '³' },
        { Foreground = { Color = mocha.text     } },
        { Attribute = { Intensity = 'Bold'      } },
        { Text = ' ' .. time .. ' ' },
    })
end)

return config
