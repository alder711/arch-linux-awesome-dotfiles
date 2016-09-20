--imports
local wibox = require("wibox") 
local awful = require("awful")

--create widget
volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

--create accompanying bar widget
vol_widget = {}
vol_widget.bar = awful.widget.progressbar()
vol_widget.bar:set_width (8)
vol_widget.bar:set_vertical (true)
vol_widget.bar:set_background_color ("#494B4F")
vol_widget.bar:set_color ("#32cd32") --#AECF96")

--volume icons
local volume_mute = '\u{f026}'
local volume_down = '\u{f027}'
local volume_full = '\u{f028}'

--function to update volume status
function update_volume(widget)
	--get status via command
	local fd = io.popen("amixer sget Master")
	local status = fd:read("*all")
	fd:close()

	--parse data and create icon
	local icon = ''
	local volume_bar = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
	local volume = string.match(status, "(%d?%d?%d)%%")
	volume = string.format("% 3d", volume)

	--assign icon
	if (tonumber(volume) > 0 and tonumber(volume) < 66) then
		icon = volume_down
	elseif (tonumber(volume) >=66) then
		icon = volume_full
	elseif (tonumber(volume) == 0) then
		icon = volume_mute
	end

	--update progressbar
	vol_widget.bar:set_value(volume_bar)

	--reparse status differently
	status = string.match(status, "%[(o[^%]]*)%]")

	--[NOT NEEDED] color variables
	--local sr, sg, sb = 0x3F, 0x3F, 0x3F
	--local er, eg, eb = 0xDC, 0xDC, 0xCC
	--local ir = math.floor(volume * (er - sr) + sr)
	--local ig = math.floor(volume * (eg - sg) + sg)
	--local ib = math.floor(volume * (eb - sb) + sb)
	--interpol_color = string.format("%.2x%.2x%.2x", ir, ig, ib)

	--update variables if muted or not
	if string.find(status, "on", 1, true) then
		--volume_bar = " <span background='#" .. interpol_color .. "'>  </span>"
		volume = volume .. "%"
	else
		--volume_bar = " <span color='red' background='#" .. interpol_color .. "'> M </span>"
		volume = volume .. "% " .. "M"
		icon = volume_mute
	end
	
	--set widget display
	widget:set_markup("  <span color='#32cd32'>" .. icon .. " Vol:" ..  volume .. "</span> ")-- .. " | ")
end



--run function
update_volume(volume_widget)

--create, assign, and run timer for function iteration
myvoltimer = timer({ timeout = 1 })
myvoltimer:connect_signal("timeout", function () update_volume(volume_widget) end)
myvoltimer:start()

