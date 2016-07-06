
local Action = {}
local Action_mt = { __index = Action }


-- Creates a new action.
function Action.new(var, cmd, command_generator)
  if var == nil then
    error 'Need to provide variable to action object!'
  end
  if cmd == nil then
    error 'Need to provide command to action object!'
  end

  local action = { 
    variable = var, 
    command = cmd,
    cmd_gen = command_generator
  }
  return setmetatable(action, Action_mt)
end


-- returns a string representation of the action.
function Action:to_string()
  return '{ set, ' .. self.variable:to_string() .. 
              ', ' .. self.command:to_string() .. ' }'
end

return Action

