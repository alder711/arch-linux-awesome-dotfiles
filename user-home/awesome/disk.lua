--imports
local wibox = require("wibox")
local awful = require("awful")

--icon
icon = '\u{f0a0}'

--widget forming function
function update_disk(widget)
	local fd1 = io.popen("df -hl | grep 'sda1' | awk '{print $2-$4}'")
	local disk_used = fd1:read()
	fd1:close()
	local fd2 = io.popen("df -hl | grep 'sda1' | awk '{print 0+$2}'")
	local disk_total = fd2:read()
	fd2:close()

	local disk_percent_value = ((disk_used/disk_total)*100)
	local disk_percent = string.format("%02.0f%%", disk_percent_value)
	local status = "(" .. disk_used .. "G/" .. disk_total .. "G) " .. disk_percent
	
	disk_widget_bar.widget:set_value(disk_percent_value/100)

	widget:set_markup("<span color='#ffa500'>" .. icon.. " Disk: " .. status .. "</span> ")
end


--progressbar widget
disk_widget_bar = wibox.widget {
   {
       max_value        = 1,
       value            = 0,
       background_color = "#494B4F",
       color            = {type="linear", from = {0, 0}, to = {0, 20},
            stops = { {0, "#ffa500"}, {0.5, 
            "#ffa500"}, {1.0, "#ffa500"} }
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 12,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}


--create widget
disk_widget = wibox.widget.textbox()

--run function
update_disk(disk_widget)
