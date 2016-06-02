local ffi = require('ffi')

local class = require('radio.core.class')
local platform = require('radio.core.platform')

ffi.cdef[[
    void *memset(void *s, int c, size_t n);
    void *memcpy(void *dest, const void *src, size_t n);
]]

-- Vector class
local Vector = class.factory()

function Vector.new(ctype, num)
    local self = setmetatable({}, Vector)

    -- Data type
    self.type = ctype
    -- Length
    self.length = num or 0
    -- Capacity
    self._capacity = self.length
    -- Size in bytes
    self.size = self.length*ffi.sizeof(ctype)
    -- Allocate and zero buffer
    self._buffer = platform.alloc(self.size)
    ffi.C.memset(self._buffer, 0, self.size)
    -- Cast buffer to data type pointer
    self.data = ffi.cast(ffi.typeof("$ *", ctype), self._buffer)

    return self
end

function Vector.cast(ctype, buf, size)
    local self = setmetatable({}, Vector)

    -- Data type
    self.type = ctype
    -- Length
    self.length = size/ffi.sizeof(ctype)
    -- Capacity
    self._capacity = self.length
    -- Size in bytes
    self.size = size
    -- Buffer
    self._buffer = buf
    -- Cast buffer to data type pointer
    self.data = ffi.cast(ffi.typeof("const $ *", ctype), buf)

    return self
end

function Vector:__eq(other)
    if self.length ~= other.length then
        return false
    end

    for i = 0, self.length-1 do
        if self.data[i] ~= other.data[i] then
            return false
        end
    end

    return true
end

function Vector:__tostring()
    local strs = {}

    for i = 0, self.length-1 do
        strs[i+1] = tostring(self.data[i])
    end

    return "[" .. table.concat(strs, ", ") .. "]"
end

function Vector:resize(num)
    -- If we're within capacity, adjust length and size
    if num <= self._capacity then
        self.length = num
        self.size = num*ffi.sizeof(self.type)
        return self
    end

    -- Calculate new capacity (grow exponentially)
    local capacity = math.max(num, 2*self._capacity)
    -- Calculate new buffer size
    local bufsize = capacity*ffi.sizeof(self.type)
    -- Allocate and zero buffer
    local buf = platform.alloc(bufsize)
    ffi.C.memset(buf, 0, bufsize)
    -- Cast buffer to data type pointer
    local ptr = ffi.cast(ffi.typeof("$ *", self.data_type), buf)
    -- Copy old data
    ffi.C.memcpy(buf, self._buffer, math.min(self.size, num*ffi.sizeof(self.type)))

    -- Update state
    self.data = ptr
    self.length = num
    self.size = num*ffi.sizeof(self.type)
    self._capacity = capacity
    self._buffer = buf

    return self
end

function Vector:append(elem)
    self:resize(self.length + 1)
    self.data[self.length - 1] = elem

    return self
end

-- ObjectVector class

local ObjectVector = class.factory()

function ObjectVector.new(type, num)
    local self = setmetatable({}, ObjectVector)

    -- Class type
    self.type = type
    -- Length
    self.length = num or 0
    -- Size in bytes
    self.size = 0
    -- Data array
    self.data = {}

    return self
end

function ObjectVector:__tostring()
    local strs = {}

    for i = 0, self.length-1 do
        strs[i+1] = tostring(self.data[i])
    end

    return "[" .. table.concat(strs, ", ") .. "]"
end

function ObjectVector:resize(num)
    if num < self.length then
        for i = num, self.length do
            self.data[i] = nil
        end
    end
    self.length = num

    return self
end

function ObjectVector:append(elem)
    self.data[self.length] = elem
    self.length = self.length + 1

    return self
end

return {Vector = Vector, ObjectVector = ObjectVector}
