--imports
local wibox = require("wibox")
local awful = require("awful")

--icons
local wifi_full_signal = '\u{f1eb}'
local wifi_no_signal = '\u{f05e}'
local wired_signal = '\u{f0e8}'

--interfaces
local dhcp = "wlp3s0"
local ham = "ham0"

--updating function
function update_network(widget)
	local status = ""
	local ssid = ""
	local ip = ""
	local icon = ""
	local signal_level = 0
	local query_command = [[awk 'NR==3 {printf "%03.0f" ,($3/70)*100}' /proc/net/wireless]]
	local signal_query = io.popen(query_command)
	signal_level = tonumber(signal_query:read("*a"))
	signal_query:close()
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
		wifi_widget_bar.widget:set_value(signal_level/100)
	end
		--check for ethernet
		local fd2 = io.open("/sys/class/net/enp2s0/carrier") --"/sys/class/net/enp2s0/carrier")
		local lan_connected = fd2:read()
		fd2:close()
		if (tonumber(lan_connected) == 1) then
			icon = (wired_signal .. " " .. icon)
		else
			icon = icon
		end

		--get ip address
		query_command = "ip addr show "..ham.." | grep 'inet' | awk '{print $2}' | cut -d/ -f1"
		local fd3 = io.popen(query_command)  --"hostname -i")
		ip = tostring(fd3:read())
		query_command = "hostname -i" --"ip addr show "..dhcp.." | grep 'inet' | awk '{print $2}' | cut -d/ -f1"
		fd3 = io.popen(query_command)  --"hostname -i")
		ip = ip .. "\n" .. tostring(fd3:read())

		local addresses = {} --{ Hamachi, dhcp }
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
wifi_widget_bar = wibox.widget {
   {
       max_value        = 1,
       value            = 0,
       background_color = "#494B4F",
       color            = {type="linear", from = {0, 0}, to = {0, 20},
            stops = { {0, "#1e90ff"}, {0.5, 
            "#1e90ff"}, {1.0, "#1e90ff"} }
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 12,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}



--create widget
wifi_widget = wibox.widget.textbox()
wifi_widget:set_align("right")

--run function
update_network(wifi_widget)

--create, assign, run timer
mywifitimer = timer({ timeout = 2 })
mywifitimer:connect_signal("timeout", function() update_network(wifi_widget) end)
mywifitimer:start() 
