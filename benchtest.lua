package.path = package.path .. ";src/?.lua"
package.cpath = package.cpath .. ";./dep/?.so"

local timer = require "timer"
local Utils = require "utils"

math.randomseed(os.time())

local timer_mgr = timer.new_timer_mgr(0)

local last_record = {0,0}

local function testfunc( cur_wakeup, topnode)
	assert(cur_wakeup >= last_record[1] and topnode.m_wakeup >= last_record[2])
	last_record[1] = cur_wakeup
	last_record[2] = topnode.m_wakeup
end

timer_mgr:set_time(Utils.millisecond())
local num = 100000
for i = 1, num do
	local interval = math.random(1, num)
	timer_mgr:add_timer(function ( topnode )
		testfunc(interval, topnode)
	end, interval, 1)
end
timer_mgr:set_time(nil)

print(string.format("push %d timer and create %d heap node ok", timer_mgr:timer_num(), timer_mgr:size()))

local t1 = Utils.millisecond()

timer_mgr:update(t1 + num)

assert(timer_mgr:timer_num() == 0)

local t2 = Utils.millisecond()

print(string.format("proc %d timer use %dms", num, t2 - t1))