local random = require 'src.random'
local property = require 'src.property'
local lqc = require 'src.quickcheck'
local r = require 'src.report'
local int = require 'src.generators.int'

local ffi = require 'ffi'
ffi.cdef [[
  uint64_t u64_add(uint64_t a, uint64_t b);
  uint64_t u64_invert(uint64_t x);
]]
local clib = ffi.load 'fixtures'


local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
end

describe('generating 64 bit integers for C code', function()
  before_each(do_setup)
  -- NOTE: values won't go higher than max value of double (around 2^52)

  it('should be possible to test functions that use 64 bit integers', function()
    local spy_check = spy.new(function(a, b)
      return a + b == clib.u64_add(a, b)
    end)
    property 'uint64_t should be generated/converted correctly' {
      generators = { int(100), int(100) },   
      check = spy_check
    }
    lqc.check()
    assert.spy(spy_check).was.called(lqc.iteration_amount)
  end)

  it('should be possible to shrink 64 bit integer types', function()
    local shrunk_value
    r.report_failed = function(_, _, shrunk_vals)
      shrunk_value = shrunk_vals[1]
    end    
    property 'uint64_t can be shrunk to smaller values' {
      generators = { int(10) },
      check = function(x)
        return clib.u64_invert(x) == "test123"  -- always fails!
      end
    }
    for _ = 1, 100 do
      shrunk_value = nil
      lqc.check()
      assert.equal(0, shrunk_value)
    end
  end)
end)

