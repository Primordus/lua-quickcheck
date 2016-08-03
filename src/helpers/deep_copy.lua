local pairs = pairs


-- Deep copies an object recursively (including (nested) tables, metatables,
-- circular references, ...)
-- Heavily based on http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value 
local function deep_copy(obj, seen)
  -- handle number, string, boolean, ...
  if type(obj) ~= 'table' then return obj end

  seen = seen or {}
  if seen[obj] then return seen[obj] end  -- handle circular references

  -- handle table
  local result = {}
  seen[obj] = result

  for key, value in pairs(obj) do
    result[deep_copy(key, seen)] = deep_copy(value, seen)
  end

  -- handle metatable
  return setmetatable(result, deep_copy(getmetatable(obj), seen))
end

return deep_copy

