--imports
local wibox = require("wibox")
local awful = require("awful")

--icon
icon = '\u{f0a0}'

--widget forming function
function update_disk(widget)
	local fd1 = io.popen("df -hl | grep 'sda4' | awk '{print $2-$4}'")
	local disk_used = fd1:read()
	fd1:close()
	local fd2 = io.popen("df -hl | grep 'sda4' | awk '{print 0+$2}'")
	local disk_total = fd2:read()
	fd2:close()

	local disk_percent_value = ((disk_used/disk_total)*100)
	local disk_percent = string.format("%02.0f%%", disk_percent_value)
	local status = "(" .. disk_used .. "G/" .. disk_total .. "G) " .. disk_percent
	
	disk_widget_bar:set_value(disk_percent_value/100)

	widget:set_markup("<span color='#ffa500'>" .. icon.. " Disk: " .. status .. "</span> ")
end


--progressbar widget
disk_widget_bar = awful.widget.progressbar()
disk_widget_bar:set_vertical(true)
disk_widget_bar:set_width(8)
disk_widget_bar:set_background_color('#494b4f')
disk_widget_bar:set_color('#ffa500')


--create widget
disk_widget = wibox.widget.textbox()

--run function
update_disk(disk_widget)
