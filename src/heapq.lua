--[[
	author: lakefu
	date: 2018-11-26
 --]]
local strfmt = string.format 

local HeapQueue = {}
HeapQueue.__index = HeapQueue

function HeapQueue:new(...)
	local o = {}
	setmetatable(o, self)
	o:init(...)
	return o
end

function HeapQueue:init(capacity, cmpfunc)
	self.m_capacity = capacity or 0
	self.m_size = 0
	self.m_ltecmp = cmpfunc or function (a, b) return a <= b end --less than or equal return true
	self.m_data = {}
end

function HeapQueue:customize(data, size)
	assert(size >= 0, "customize illegal heapq size: not positive")
	if self.m_capacity > 0 then
		assert(size <= self.m_capacity, "customize illegal heapq size: over capacity")
	end
	self.m_data = data
	self.m_size = size
end

function HeapQueue:size()
	return self.m_size
end

function HeapQueue:top()
	return self.m_data[1]
end

function HeapQueue:modify(k, v)
	if k < 1 or k > self.m_size then
		print(strfmt("[Error]: modify err pos value: %s", k))
		return
	end
	self.m_data[k] = v
	self:adjust( k )
end

function HeapQueue:reset()
	self.m_size = 0
end

function HeapQueue:rebuild()
	for i = 1, self.m_size do
		self:_shiftup(i)
	end
end

function HeapQueue:_shiftdown( k )
	local top = self.m_data[k]
	repeat
		local c = k * 2
		if c > self.m_size then
			break
		end
		if c < self.m_size and not self.m_ltecmp(self.m_data[c], self.m_data[c + 1]) then
			c = c + 1
		end
		if self.m_ltecmp(top, self.m_data[c]) then
			break
		end

		self.m_data[k] = self.m_data[c]
		k = c
	until false

	self.m_data[k] = top
end

function HeapQueue:_shiftup( k )
	local top = self.m_data[k]
	repeat
		local c = k // 2
		if c <= 0 or self.m_ltecmp(self.m_data[c], top) then
			break
		end
		self.m_data[k] = self.m_data[c]
		k = c
	until false

	self.m_data[k] = top
end

function HeapQueue:adjust( k )
	if (k <= 0 or k > self.m_size) then
		return
	end
	if k > 1 and self.m_ltecmp(self.m_data[k], self.m_data[k//2]) then
		self:_shiftup( k )
	else
		self:_shiftdown( k )
	end
end

function HeapQueue:push( e )
	if self.m_capacity > 0 and self.m_size >= self.m_capacity then
		print(strfmt("[Error]: heapq size over capacity %s", self.m_capacity))
		return false
	end
	local pos = self.m_size + 1
	self.m_data[pos] = e
	self.m_size = self.m_size + 1
	self:_shiftup(pos)
	return true
end

function HeapQueue:pop()
	if self.m_size < 1 then
		return
	end
	local e = self.m_data[1]
	self.m_size = self.m_size - 1
	self.m_data[1] = self.m_data[self.m_size + 1]
	self:_shiftdown(1)
	return e
end

function HeapQueue:get( k )
	if k < 1 or k > self.m_size then
		print(strfmt("[Error]: get err pos value: %s", k))
		return
	end
	return self.m_data[k]
end

function HeapQueue:dump()
	print("-------dump begin-------")
	for i = 1, self.m_size do
		print(strfmt("[%d]: %s", i, self.m_data[i]))
	end
	print("-------dump end-------")
end

local M = {}

function M.create_queue(...)
	return HeapQueue:new(...)
end

return M