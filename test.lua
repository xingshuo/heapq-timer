package.path = package.path .. ";src/?.lua"
package.cpath = package.cpath .. ";./dep/?.so"

local timer = require "timer"
local Utils = require "utils"

local timer_mgr = timer.new_timer_mgr(0)

local start_ms = Utils.millisecond()

local session3 = timer_mgr:add_timer(function ( ... )
	print("33333333333", Utils.millisecond() - start_ms)
end, 1500, 2)

print("create timer ", session3)

for i = 1, 3 do
	timer_mgr:add_timer(function ( ... )
		print("55555555555", Utils.millisecond() - start_ms)
	end, 1500, 1)
end

local cnt11 = 0
timer_mgr:add_timer(function ( ... )
	print("11111111111", Utils.millisecond() - start_ms)
	cnt11 = cnt11 + 1
	if cnt11 >= 2 then
		print("delete timer ",session3)
		timer_mgr:remove_timer(session3)
	else
		timer_mgr:add_timer(function ( ... )
			print("44444444444", Utils.millisecond() - start_ms)
		end, 500, 2)
	end
end, 1000, 2)

timer_mgr:add_timer(function ( ... )
	print("22222222222", Utils.millisecond() - start_ms)
end, 500, 1)

while timer_mgr:size() > 0 do
	local dt = timer_mgr:min_wakeup_spacing()
	if dt > 0 then
		Utils.msleep(dt)
	end
	timer_mgr:update()
end