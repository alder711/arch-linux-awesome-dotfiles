--imports
local wibox = require("wibox")
local awful = require("awful")

--icons
local wifi_full_signal = '\u{f1eb}'
local wifi_no_signal = '\u{f05e}'
local wired_signal = '\u{f0e8}'


--updating function
function update_network(widget)
	local status = ""
	local ssid = ""
	local ip = ""
	local icon = ""
	local signal_level = 0
	signal_level = tonumber(awful.util.pread("awk 'NR==3 {printf \"%03.0f\" ,($3/70)*100}' /proc/net/wireless"))
        if signal_level == nil then
		connected = false
		status = "N/A"
		icon = wifi_no_signal
        else
		connected = true
		status = (string.format("%03d%%", signal_level))
		icon = wifi_full_signal

		
		--get ssid
		local fd = io.popen("iwgetid -r")
		ssid = tostring(fd:read())
		fd:close()

		--update bar
		wifi_widget_bar:set_value(signal_level/100)
	end
		--check for ethernet
		local fd2 = io.open("/sys/class/net/enp0s3/carrier")
		local lan_connected = fd2:read()
		fd2:close()
		if (tonumber(lan_connected) == 1) then
			icon = (wired_signal .. " " .. icon)
		else
			icon = icon
		end

		--get ip address
		local fd3 = io.popen("hostname -i")
		ip = tostring(fd3:read())
		local addresses = {} --{ dhcp, Hamachi }
		for w in string.gmatch(ip, "%d+.%d+.%d+.%d+") do table.insert(addresses, w) end
		if (ip ~= nil and addresses[1] ~= nil and addresses[2] ~= nil) then
			ip = addresses[1] .. "|" .. addresses[2]
		elseif (ip ~= nil and (addresses[1] ~= nil or addresses[2] ~= nil)) then
			if (addresses[1] == nil) then
				ip = "-|" .. addresses[2]
			else
				ip = addresses[1] .. "|-"
			end 
		else
			ip = "-|-"
		end
		fd3:close()

		

   		--icon handling (not needed)
		--if signal_level < 25 then
                --	net_icon:set_image(ICON_DIR.."wireless_0.png")
            	--elseif signal_level < 50 then
                --net_icon:set_image(ICON_DIR.."wireless_1.png")
            	--elseif signal_level < 75 then
                --	net_icon:set_image(ICON_DIR.."wireless_2.png")
            	--else
                --	net_icon:set_image(ICON_DIR.."wireless_3.png")
            	--end
	widget:set_markup(" <span color='#1e90ff'>" .. icon .. " " .. ssid .. " |" .. ip .. "| " .. status .. "</span> ")
end



--####PROGRESSBAR WIDGET####
wifi_widget_bar = awful.widget.progressbar()
wifi_widget_bar:set_width(8)
wifi_widget_bar:set_vertical(true)
wifi_widget_bar:set_background_color("#494b4f")
wifi_widget_bar:set_color("#1e90ff")



--create widget
wifi_widget = wibox.widget.textbox()
wifi_widget:set_align("right")

--run function
update_network(wifi_widget)

--create, assign, run timer
mywifitimer = timer({ timeout = 2 })
mywifitimer:connect_signal("timeout", function() update_network(wifi_widget) end)
mywifitimer:start() 
