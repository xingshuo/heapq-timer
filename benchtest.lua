package.path = package.path .. ";src/?.lua"
package.cpath = package.cpath .. ";./dep/?.so"

local timer = require "timer"
local Utils = require "utils"
local strfmt = string.format

math.randomseed(os.time())

local timer_mgr = timer.new_timer_mgr(0)

local last_record = {0,0}

local function testfunc( cur_wakeup, topnode)
	assert(cur_wakeup >= last_record[1] and topnode.m_wakeup >= last_record[2])
	last_record[1] = cur_wakeup
	last_record[2] = topnode.m_wakeup
end

local m0 = collectgarbage("count")
local t0 = Utils.millisecond()

timer_mgr:set_time(t0)
local num = 100000
for i = 1, num do
	local interval = math.random(1, num)
	timer_mgr:add_timer(function ( topnode )
		testfunc(interval, topnode)
	end, interval, 1)
end
timer_mgr:set_time(nil)

local m1 = collectgarbage("count")
local t1 = Utils.millisecond()

print(strfmt("push %d timer(create %d heap node) use: %dms(time) malloc: %0.3fM(memory)", timer_mgr:timer_num(), timer_mgr:size(), t1-t0, (m1-m0)/1024))

timer_mgr:update(t1 + num)

assert(timer_mgr:timer_num() == 0)

local t2 = Utils.millisecond()
collectgarbage("collect")
local m2 = collectgarbage("count")

print(strfmt("proc %d timer use: %dms(time) free: %0.3fM(memory)", num, t2-t1, (m1-m2)/1024))