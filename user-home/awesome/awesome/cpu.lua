--imports
local wibox = require("wibox")
local vicious = require("vicious")
local awful = require("awful")

--####GRAPH WIDGET####
cpu_widget_graph = awful.widget.graph()
--graph properties
cpu_widget_graph:set_width(20)
cpu_widget_graph:set_background_color('#494b4f') --#494b4f
cpu_widget_graph:set_color('#9370db') --#663399
--tooltip
cpu_widget_graph_t = awful.tooltip({ objects = { cpu_widget_graph.widget }})
--register widget
vicious.register(cpu_widget_graph, vicious.widgets.cpu, "$1", 1)


--####TEXT WIDGET (OLD)####
--cpu_widget_text2 = wibox.widget.textbox()
---- Register widget
--vicious.register(cpu_widget_text2, vicious.widgets.cpu, "<span color='#663399'>" .. cpu_icon .. " CPU: $1%" .. "</span>")
----cpu_widget_text:set_markup("<span color='#9370db'>" .. cpu_widget_text .. " " .. "</span>")


--### CPU PARSER FUNCTION ####
function update_cpu(widget)
	--get cpu status
	  --for user level cpu usage:
	  --mpstat | awk ' /'....'/ {print $3} ' | grep -w '[0-9]'
	  --for kernel and user level cpu usage:
	  --mpstat | awk ' /'....'/ {print $3+$5} ' | grep -w '[1-9]'
	local fd = io.open("/proc/stat") --popen("top -bn 1 | grep Cpu0 | awk -v RS=[0-9]?[0-9].[0-9]+ '{print RT+0;exit}'") --"mpstat | awk ' /'....'/ {print 100-$12} ' | grep -w '[1-9][1-9]'")
	--local status = worker()[2] --fd:read("*all")
	local cpu0_status = worker()[1]
	local cpu1_status = worker()[2]
	local cpu2_status = worker()[3]
	local cpu3_status = worker()[4]

	local cpu_status = ((cpu0_status+cpu1_status+cpu2_status+cpu3_status)/4)
	fd:close()


	cpu0_status = string.format("%3d%%", cpu0_status)
	cpu1_status = string.format("%#3s%%", cpu1_status)
	cpu2_status = string.format("%3d%%", cpu2_status)
	cpu3_status = string.format("%#3s%%", cpu3_status)
	cpu_status = string.format("%#5.1f%%", cpu_status)

	local percent = tostring(cpu_status) --string.match(status, "....")--"(%d?%d?%d.%d?%d?)%%")
	local cpu_icon = '\u{f126}'

	--color: #9370db
	widget:set_markup("  <span color='#9370db'>" .. cpu_icon .. " 1: " .. "<span font='Ubuntu Mono 10'>" .. cpu0_status .. "</span>" .. "|2: " .. "<span font='Ubuntu Mono 10'>" .. cpu1_status .. "</span>" .. "|3: " .. "<span font='Ubuntu Mono 10'>" .. cpu2_status .. "</span>" .. "|4: " .. "<span font='Ubuntu Mono 10'>" .. cpu3_status .. "</span>" .. "|CPU: " .. "<span font='Ubuntu Mono 10'>" .. percent .. "</span>" .. " " .. "</span>")
end



--#### CPU STATUS FUNCTION, ETC ####
-- {{{ Grab environment
local ipairs = ipairs
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
local string = {
    sub = string.sub,
    gmatch = string.gmatch
}
-- }}}

-- Cpu: provides CPU usage for all available CPUs/cores
-- vicious.widgets.cpu
local cpu = {}


-- Initialize function tables
local cpu_usage  = {}
local cpu_total  = {}
local cpu_active = {}

function worker()
    local cpu_lines = {}

    -- Get CPU stats
    local f = io.open("/proc/stat")
    for line in f:lines() do
        if string.sub(line, 1, 3) ~= "cpu" then break end

        cpu_lines[#cpu_lines+1] = {}

        for i in string.gmatch(line, "[%s]+([^%s]+)") do
            table.insert(cpu_lines[#cpu_lines], i)
        end
    end
    f:close()

    -- Ensure tables are initialized correctly
    for i = #cpu_total + 1, #cpu_lines do
        cpu_total[i]  = 0
        cpu_usage[i]  = 0
        cpu_active[i] = 0
    end


    for i, v in ipairs(cpu_lines) do
        -- Calculate totals
        local total_new = 0
        for j = 1, #v do
            total_new = total_new + v[j]
        end
        local active_new = total_new - (v[4] + v[5])

        -- Calculate percentage
        local diff_total  = total_new - cpu_total[i]
        local diff_active = active_new - cpu_active[i]

        if diff_total == 0 then diff_total = 1E-6 end
        cpu_usage[i]      = math.floor((diff_active / diff_total) * 100)

        -- Store totals
        cpu_total[i]   = total_new
        cpu_active[i]  = active_new
    end

    return cpu_usage
end
--#######






--create widget
cpu_widget_text = wibox.widget.textbox()

--run function
update_cpu(cpu_widget_text)

--create, assign, and run timer for function iteration
mycputimer = timer({ timeout = 1 })
mycputimer:connect_signal("timeout", function () update_cpu(cpu_widget_text) end)
mycputimer:start()
