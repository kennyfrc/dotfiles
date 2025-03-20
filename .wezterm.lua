-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

-- Split panes
config.keys = {
  -- This will create a new split and run the `top` program inside it
  {
    key = "%",
    mods = "CTRL|SHIFT|ALT",
    action = wezterm.action.SplitPane({
      direction = "Left",
      command = { args = { "top" } },
      size = { Percent = 50 },
    }),
  },
  -- This will allow users to enter a new tab for tab
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- Add word navigation shortcuts
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = act.SendKey { key = 'b', mods = 'ALT' }
  },
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = act.SendKey { key = 'f', mods = 'ALT' }
  },
  -- Optional: Add word deletion shortcuts
  {
    key = 'Backspace',
    mods = 'ALT',
    action = act.SendKey { key = 'w', mods = 'CTRL' }
  }
}

-- Color schemes
config.color_scheme = "Breeze (Gogh)"
config.font = wezterm.font("JetBrains Mono Nerd Font Mono")
config.font_size = 16.0
config.initial_cols = 180
config.initial_rows = 60

-- This does auto-reloading for the helix editor
-- https://wezfurlong.org/wezterm/config/lua/pane/get_foreground_process_name.html
-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

-- Auto-reload when we focus on the pane
-- Escape first so we don't spill random characters if we were in
-- non-insert mode.
wezterm.on('window-focus-changed', function(window, pane)
    if window:is_focused() then
        local top_process = basename(pane:get_foreground_process_name())
        if top_process == 'hx' then
            -- Send escape first to ensure we're in normal mode
            window:perform_action(wezterm.action.SendKey{key='Escape'}, pane)
            -- Small delay to ensure the escape is processed
            wezterm.sleep_ms(50)
            -- Then send the reload command
            window:perform_action(wezterm.action.SendString(':rla\r'), pane)
        end
    end
end)

-- return the configuration to wezterm
return config
