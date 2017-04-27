--imports
local wibox = require("wibox")
local awful = require("awful")
local vicious = require("vicious")

--create widget   
ram_widget = wibox.widget.textbox()
ram_widget:set_align("right")

--icon
local icon = '\u{f1c0}' --f233

--updating function for text   
function update_ram(widget)
	local active, total
 	for line in io.lines('/proc/meminfo') do
 		for key, value in string.gmatch(line, "(%w+):%s+(%d+).+") do
 			if key == "Active" then active = tonumber(value)
 			elseif key == "MemTotal" then total = tonumber(value) end
 		end
 	end

	local percent_used = ((active/total)*100)
	percent_used = string.format("%02.1f", percent_used)
	ram_widget_graph:add_value(percent_used/100)
   
       widget:set_markup(" <span color='#ffff00'>" .. icon .. " Mem: " .. string.format("%.1fMB",(active/1024)) .. " (" .. percent_used .. "%)" .. "</span>")
end


--#### GRAPH WIDGET ####
ram_widget_graph = awful.widget.graph()
--graph properties
ram_widget_graph:set_width(20)
ram_widget_graph:set_color('#ffff00')
ram_widget_graph:set_background_color('#494b4f')





--run function   
update_ram(ram_widget)
   
--create, assign, and run timer
myramtimer = timer({ timeout = 1 })
myramtimer:connect_signal("timeout", function () update_ram(ram_widget) end)
myramtimer:start()
