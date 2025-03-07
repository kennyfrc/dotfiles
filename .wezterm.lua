-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

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
}

-- For example, changing the color scheme:
config.color_scheme = "Breeze (Gogh)"
config.font = wezterm.font("IosevkaTerm Nerd Font Mono")
config.font_size = 16.0
config.initial_cols = 180
config.initial_rows = 60

-- https://wezfurlong.org/wezterm/config/lua/pane/get_foreground_process_name.html
-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
-- This does auto-reloading for the helix editor
function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on('window-focus-changed', function(window, pane)
    if window:is_focused() then
        local top_process = basename(pane:get_foreground_process_name())
        print(top_process)
        if top_process == 'hx' then
            local action = wezterm.action.SendString(':rla\r')
            window:perform_action(action, pane);
        end
    end
end)

-- and finally, return the configuration to wezterm
return config
