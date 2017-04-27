--imports
local wibox = require("wibox")
local awful = require("awful")

----bar widget
bat_widget_bar = wibox.widget {
   {
       max_value        = 1,
       value            = 0,
       background_color = "#494B4F",
       color            = {type="linear", from = {0, 0}, to = {0, 20},
            stops = { {0, "#ff0000"}, {0.5, 
            "#ff0000"}, {1.0, "#ff0000"} }
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 12,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}

bat_widget = {}


--battery icons
local batt_empty = '\u{f244}'
local batt_quarter = '\u{f243}'
local batt_half = '\u{f242}'
local batt_three_quarter = '\u{f241}'
local batt_full = '\u{f240}'
local batt_charge = '\u{f0e7}'

--function to update widget
function update_battery(widget)
	--check battery via acpi command
	local fd = io.popen("acpi")
	local status = fd:read("*all")
	fd:close()

	--create parsed volume and icon variables
	local percent = string.match(status, "(%d?%d?%d)%%")
	local icon = ""

	if (percent == nil) then
		percent = "100"
	end

	--assign icon
	if (tonumber(percent) < 25) then
		icon = batt_empty
	elseif (tonumber(percent) >= 25 and tonumber(percent) < 50) then
		icon = batt_quarter
	elseif (tonumber(percent) >= 50 and tonumber(percent) < 75) then
		icon = batt_half
	elseif (tonumber(percent) >= 75 and tonumber(percent) < 100) then
		icon = batt_three_quarter
	else
		icon = batt_full
	end

	--check charging status
	fd = io.popen("acpi -a")
	local charge_status = fd:read("*all")
	fd:close()

	--assign charge icon if charging
	if (string.find(charge_status, "on-line", 1, true)) then
		icon = batt_charge .. " " .. icon
	end

	--update status bar
	local batt_progress = (percent / 100)
	bat_widget_bar.widget:set_value(batt_progress)

	--set widget display
	widget:set_markup("  <span color='#ff0000'>" .. icon .. " Batt: " .. percent .. "% " .. "</span>")
end

--create widget
battery_widget = wibox.widget.textbox()
battery_widget:set_align("right")

--run function
update_battery(battery_widget)
	
--create, assign, and start timer for functon iteration
mybattimer = timer({ timeout = 1 })
mybattimer:connect_signal("timeout", function() update_battery(battery_widget) end)
mybattimer:start()
