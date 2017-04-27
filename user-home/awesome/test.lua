local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")

test_bar = wibox.widget {
   {
       max_value        = 1,
       value            = .33,
       background_color = "#131211",
       color            = {type="linear", from = {0, 0}, to = {0, 20},
            stops = { {0, "#F6F6F6"}, {0.5, 
            "#bdbdbd"}, {1.0, "#3b3b3b"} }
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 12,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}

