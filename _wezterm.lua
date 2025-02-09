-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Solarized Darcula'
config.font_size = 13


wezterm.on("update-right-status", function(window, pane)
      -- demonstrates shelling out to get some external status.
      -- wezterm will parse escape sequences output by the
      -- child process and include them in the status area, too.
      local success, date, stderr = wezterm.run_child_process({"date"});

     -- However, if all you need is to format the date/time, then:
     date = wezterm.strftime("%Y-%m-%d %H:%M:%S");

      -- Make it italic and underlined
      window:set_right_status(wezterm.format({
        {Attribute={Underline="Single"}},
        {Attribute={Italic=true}},
        {Text=date},
    }));
end);

-- and finally, return the configuration to wezterm
return config
