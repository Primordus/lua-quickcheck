local argparse = require 'argparse'
local config = require 'lqc.config'


-- Module for easily parsing list of command line arguments

local name_of_executable = 'lqc'
local help_info = 'Property based testing tool written in Lua'
local parser = argparse(name_of_executable, help_info)
parser.error = function(msg) error(msg) end


-- Converts a string to an integer
-- Returns an integer representation of the input string or raises an error on failure.
local function str_to_int(x)
  return tonumber(x)
end


parser:argument('files_or_dirs',
                'List of input files or directories (recursive search) used for testing, default = "."',
                nil, nil, '*')
parser:option('-s --seed', 
              'Value of the random seed to use, default = seed based on current time',
              nil, str_to_int)
parser:option('--numtests', 'Number of iterations per property, default = 100',
              nil, str_to_int)
parser:option('--numshrinks', 'Number of shrinks per failing property, default = 100',
              nil, str_to_int)
parser:flag('-c --colors', "Enable coloring of test output, default = disabled (doesn't work on Windows!).")
-- TODO option --check to re-run last seed


local lib = {}


-- Parses the arguments, returns a table containing the config specified by the
-- user or raises an error if parsing failed.
function lib.parse(args)
  local parsed_values = parser:parse(args)
  return config.resolve(parsed_values)
end


return lib

