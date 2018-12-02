--[[
	author: lakefu
	date: 2018-12-2
 --]]
local Utils = require "utils"
local Heapq = require "heapq"

local strfmt = string.format

local TimerNode = {}
TimerNode.__index = TimerNode

function TimerNode:new( ... )
	local o = {}
	setmetatable(o, self)
	o:init( ... )
	return o
end

function TimerNode:init(timer_mgr, session, interval, times)
	times = times or 0
	assert(interval >= 0, "negative timer interval")
	if interval == 0 then
		assert(times > 0, "reflect timer must be finite times")
	end
	self.m_session = session
	self.m_interval = interval
	self.m_wakeup = timer_mgr:get_time() + interval
	self.m_times = times > 0 and times or 0 --0 is permanent else finite
	self.m_nextlink = nil
end


local TimerMgr = {}
TimerMgr.__index = TimerMgr

function TimerMgr:new( ... )
	local o = {}
	setmetatable(o, self)
	o:init( ... )
	return o
end

function TimerMgr:init(capacity)
	self.m_timers = Heapq.create_queue(capacity, function (a, b)
		return a.m_wakeup <= b.m_wakeup
	end)
	self.m_funcs = {} --<map>: session 2 function
	self.m_tailnodes = {} --<map>: interval 2 tail node of list
	self.m_session = 0
end

function TimerMgr:alloc_session()
	local nxt_handle = self.m_session + 1
	while true do
		if self.m_funcs[nxt_handle] == nil then
			break
		end
		nxt_handle = nxt_handle + 1
		if nxt_handle == self.m_session then --travel a loop!!!
			break
		end
	end
	if nxt_handle ~= self.m_session then
		self.m_session = nxt_handle
		return nxt_handle
	else
		error("alloc session failed!!!")
	end
end

--interval: millisecond
--times: proc times
function TimerMgr:add_timer(func, interval, times)
	local session = self:alloc_session()
	local tnode = TimerNode:new(self, session, interval, times)
	local tailnode = self.m_tailnodes[interval]
	if tailnode == nil then --not in timers heap
		local succ = self.m_timers:push( tnode )
		if not succ then
			return
		end
		self.m_tailnodes[interval] = tnode
	else -- head in timers heap, direct link to tail
		tailnode.m_nextlink = tnode
		self.m_tailnodes[interval] = tnode
	end
	self.m_funcs[session] = func
	return session
end

function TimerMgr:remove_timer( session )
	self.m_funcs[session] = false
end

function TimerMgr:size()
	return self.m_timers:size()
end

function TimerMgr:timer_num()
	if self.m_timers:size() <= 0 then
		return 0
	end
	local num = 0
	for i = 1, self.m_timers:size() do
		local v = self.m_timers:get(i)
		while v do
			num = num + 1
			v = v.m_nextlink
		end
	end
	return num
end

function TimerMgr:set_time( t )
	self.m_SpecifyTime = t
end

function TimerMgr:get_time()
	if self.m_SpecifyTime then
		return self.m_SpecifyTime
	end
	return Utils.millisecond()
end

function TimerMgr:min_wakeup_spacing()
	if self.m_timers:size() <= 0 then
		return -1
	end
	local topnode = self.m_timers:top()
	local dt = topnode.m_wakeup - self:get_time()
	if dt > 0 then
		return dt
	else
		return 0
	end
end

function TimerMgr:update( cur_time )
	if self.m_timers:size() <= 0 then
		return
	end
	cur_time = cur_time or self:get_time()
	local err = nil
	while self.m_timers:size() > 0 do
		local topnode = self.m_timers:top()
		if topnode.m_wakeup > cur_time then
			break
		end
		local do_remove = false --if true remove the node, else modify
		local session = topnode.m_session
		local interval = topnode.m_interval
		local func = self.m_funcs[session]
		if func then
			local succ,errmsg = pcall(func, topnode)
			if not succ then
				if err == nil then
					err = strfmt("session:%d wakeup:%s ", session, topnode.m_wakeup) .. tostring(errmsg)
				else
					err = err .. "\n" .. strfmt("session:%d wakeup:%s ", session, topnode.m_wakeup) .. tostring(errmsg)
				end
			end
			if topnode.m_times > 0 then --finite
				topnode.m_times = topnode.m_times - 1
				if topnode.m_times <= 0 then
					do_remove = true
				end
			end
		else  --has be removed
			if func ~= false then
				print(strfmt("unexpect timer session %s", session))
			end
			do_remove = true
		end

		if do_remove then
			if topnode.m_nextlink then --has next node
				local newtop = topnode.m_nextlink
				topnode.m_nextlink = nil
				self.m_timers:modify(1, newtop)
			else
				assert(topnode == self.m_tailnodes[interval], "timer node list fatal error")
				self.m_timers:pop()
				self.m_tailnodes[interval] = nil
			end
			self.m_funcs[session] = nil
		else
			topnode.m_wakeup = self:get_time() + topnode.m_interval
			if topnode.m_nextlink then --has next node
				local newtop = topnode.m_nextlink
				topnode.m_nextlink = nil
				local curtail = self.m_tailnodes[interval]
				curtail.m_nextlink = topnode
				self.m_tailnodes[interval] = topnode
				self.m_timers:modify(1, newtop)
			else
				self.m_timers:adjust(1)
			end
		end
	end

	if err ~= nil then
		print(strfmt("timer update err: %s", err))
	end
end

local M = {}

function M.new_timer_mgr( ... )
	return TimerMgr:new( ... )
end

return M