---
-- Filter a complex or real valued signal with a real-valued FIR high-pass
-- filter generated by the window design method.
--
-- $$ y[n] = (x * h_{hpf})[n] $$
--
-- @category Filtering
-- @block HighpassFilterBlock
-- @tparam int num_taps Number of FIR taps, must be odd
-- @tparam number cutoff Cutoff frequency in Hz
-- @tparam[opt=nil] number nyquist Nyquist frequency, if specifying a
--                                 normalized cutoff frequency
-- @tparam[opt='hamming'] string window Window type
--
-- @signature in:ComplexFloat32 > out:ComplexFloat32
-- @signature in:Float32 > out:Float32
--
-- @usage
-- -- Highpass filter, 128 taps, 18 KHz
-- local hpf = radio.HighpassFilterBlock(128, 18e3)

local ffi = require('ffi')

local block = require('radio.core.block')
local types = require('radio.types')
local filter_utils = require('radio.blocks.signal.filter_utils')

local FIRFilterBlock = require('radio.blocks.signal.firfilter')

local HighpassFilterBlock = block.factory("HighpassFilterBlock", FIRFilterBlock)

function HighpassFilterBlock:instantiate(num_taps, cutoff, nyquist, window)
    assert(num_taps, "Missing argument #1 (num_taps)")
    self.cutoff = assert(cutoff, "Missing argument #2 (cutoff)")
    self.window = window or "hamming"
    self.nyquist = nyquist

    FIRFilterBlock.instantiate(self, types.Float32.vector(num_taps))
end

function HighpassFilterBlock:initialize()
    -- Compute Nyquist frequency
    local nyquist = self.nyquist or (self:get_rate()/2)

    -- Generate taps
    local taps = filter_utils.firwin_highpass(self.taps.length, self.cutoff/nyquist, self.window)
    self.taps = types.Float32.vector_from_array(taps)

    FIRFilterBlock.initialize(self)
end

return HighpassFilterBlock
