local Gen = require 'src.generator'
local random = require 'src.random'
local reduce = require 'src.functional.reduce'

local lib = {}

-- Picks a number randomly between min and max.
local function choose_pick(min, max)
  local function pick()
    return random.between(min, max)
  end
  return pick
end

-- Shrinks a value between min and max by dividing the sum of the closest
-- number to 0 and the generated value with 2. 
-- This effectively reduces it to the value closest to 0 gradually in the
-- chosen range.
local function choose_shrink(min, max)
  local shrink_to = (math.abs(min) < math.abs(max)) and min or max

  local function shrink(value)
    local shrunk_value = (shrink_to + value) / 2
  
    if shrunk_value < 0 then
      return math.ceil(shrunk_value)
    else
      return math.floor(shrunk_value)
    end
  end

  return shrink
end

-- Creates a generator, chooses an integer between min and max.
function lib.choose(min, max)
  return Gen.new(choose_pick(min, max), choose_shrink(min, max))
end


-- Select a generator from a list of generators
function lib.oneof(generators)
  local which  -- shared state between pick and shrink needed to shrink correctly

  local function oneof_pick()
    which = random.between(1, #generators)
    return generators[which]:pick()
  end
  local function oneof_shrink(prev)
    return generators[which]:shrink(prev)
  end

  return Gen.new(oneof_pick, oneof_shrink)
end

-- Select a generator from a list of weighted generators ({{weight1, gen1}, ... })
function lib.frequency(generators)
  local which
  local function frequency_pick()
    local sum = reduce(generators, 0, function(generator, acc) 
      return generator[1] + acc 
    end)
    
    local val = random.between(1, sum)
    which = reduce(generators, { 0, 1 }, function(generator, acc)
      local current_sum = acc[1] + generator[1]
      if current_sum >= val then
        return acc
      else
        return { current_sum, acc[2] + 1 }
      end
    end)[2]
    
    return generators[which][2]:pick()
  end
  local function frequency_shrink(prev)
    return generators[which][2]:shrink(prev)
  end

  return Gen.new(frequency_pick, frequency_shrink)
end

function lib.elements(array)
  local last_idx
  local function elements_pick()
    local idx = random.between(1, #array)
    last_idx = idx
    return array[idx]
  end

  local function elements_shrink(_)
    if last_idx > 1 then
      last_idx = last_idx - 1
    end
    return array[last_idx]
  end

  return Gen.new(elements_pick, elements_shrink)
end

return lib

