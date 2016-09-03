local map = require 'lqc.helpers.map'
local lanes = require('lanes').configure()  -- TODO make lanes optional


local TASK_TAG = 'task'
local RESULT_TAG = 'result'
local STOP_VALUE = 'stop'
local VOID_RESULT = '__thread_pool_VOID'


-- Checks if 'x' is callable.
-- Returns true if callable; otherwise false.
local function is_callable(x)
  local type_x = type(x)
  return type_x == 'function' or type_x == 'table'
end


-- Checks if x is a positive integer (excluding 0)
-- Returns true if x is a positive integer; otherwise false.
local function is_positive_integer(x)
  return type(x) == 'number' and x % 1 == 0 and x > 0
end


-- Checks if the thread pool args are valid.
-- Raises an error if invalid args are passed in.
local function check_threadpool_args(num_threads)
  if not is_positive_integer(num_threads) then 
    error 'num_threads should be an integer > 0' 
  end
end


-- Creates and starts a thread.
local function make_thread(func)
  return lanes.gen('*', func)()
end


local ThreadPool = {
  VOID_RESULT = VOID_RESULT
}
local ThreadPool_mt = { __index = ThreadPool }


-- Creates a new thread pool with a specific number of threads
function ThreadPool.new(num_threads)
  check_threadpool_args(num_threads)

  local linda = lanes.linda()
  local thread_pool = { 
    threads = {}, 
    linda = linda,
    numjobs = 0
  }

  local function msg_processor()
    -- TODO init random seed per thread?
    while true do
      local _, cmd = linda:receive(nil, TASK_TAG)
      if cmd == STOP_VALUE then 
        return 
      elseif is_callable(cmd) then
        local result = cmd() or VOID_RESULT  -- hangs if it returns nil.. -> TODO fix dirty workaround
        linda:send(nil, RESULT_TAG, result)
      else
        break
      end
    end
  end

  for _ = 1, num_threads do
    table.insert(thread_pool.threads, make_thread(msg_processor))
  end
  
  return setmetatable(thread_pool, ThreadPool_mt)
end


-- Schedules a task to a thread in the thread pool
function ThreadPool:schedule(task)
  self.numjobs = self.numjobs + 1
  self.linda:send(nil, TASK_TAG, task)
end


-- Stops all threads in the threadpool. Blocks until all threads are finished
-- Returns a table containing all results (in no specific order)
function ThreadPool:join()
  map(self.threads, function() self:schedule(STOP_VALUE) end)
  map(self.threads, function(thread) thread:join() end)

  local results = {}
  for _ = 1, self.numjobs - #self.threads do  -- don't count stop job at end
    local _, result = self.linda:receive(nil, RESULT_TAG)
    table.insert(results, result)
  end
  return results
end


return ThreadPool

