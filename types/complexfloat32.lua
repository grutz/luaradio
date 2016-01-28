local ffi = require('ffi')
local object = require('object')
local vector = require('vector')

ffi.cdef[[
typedef struct {
    float real;
    float imag;
} complex_float32_t;
]]

local ComplexFloat32Type
local mt = object.class_factory()

-- Operations

function mt:__add(other)
    return self.new(self.real + other.real, self.imag + other.imag)
end

function mt:__sub(other)
    return self.new(self.real - other.real, self.imag - other.imag)
end

function mt:__mul(other)
    return self.new(self.real * other.value, self.imag * other.value)
end

function mt:__div(other)
    local real = (self.real * other.real + self.imag * other.imag) / (other.real * other.real + other.imag * other.imag)
    local imag = (self.imag * other.real - self.real * other.imag) / (other.real * other.real + other.imag * other.imag)
    return self.new(real, imag)
end

function mt:__eq(other)
    return self.real == other.real and self.imag == other.imag
end

function mt:__lt(other)
    return (self.real < other.real) and (self.imag < other.imag)
end

function mt:__le(other)
    return (self.real <= other.real) and (self.imag <= other.imag)
end

function mt:scalar_mul(other)
    return self.new(self.real * other, self.imag * other)
end

function mt:scalar_div(other)
    return self.new(self.real / value, self.imag / value)
end

function mt:arg()
    return math.atan2(self.imag, self.real)
end

function mt:abs()
    return math.sqrt(self.real*self.real + self.imag*self.imag)
end

function mt:conj()
    return self.new(self.real, -self.imag)
end

function mt:__tostring()
    return "ComplexFloat32<real=" .. self.real .. ", imag=" .. self.imag .. ">"
end

-- Constructors

function mt.new(real, imag)
    return ComplexFloat32Type(real, imag)
end

function mt.vector(n)
    return vector.vector_calloc("complex_float32_t *", n, ffi.sizeof(ComplexFloat32Type))
end

function mt.vector_from_buf(buf, size)
    return vector.vector_cast("complex_float32_t *", buf, size, ffi.sizeof(ComplexFloat32Type))
end

function mt.vector_from_const_buf(buf, size)
    return vector.vector_cast("const complex_float32_t *", buf, size, ffi.sizeof(ComplexFloat32Type))
end

-- FFI type binding

ComplexFloat32Type = ffi.metatype("complex_float32_t", mt)

return {ComplexFloat32Type = ComplexFloat32Type}