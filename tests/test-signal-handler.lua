local constants = require('constants')
local os = require('os')
local timer = require('timer')

local first = 0
local second = 0
local sighup = false

if os.type() == 'win32' then
  process.exit(0)
end

process:on('SIGUSR1', function()
  print('Interrupted by SIGUSR1')
  first = first + 1
end)

process:on('SIGUSR1', function()
  second = second + 1
  timer.setTimeout(5, function()
    print('End.')
    process.exit(0)
  end)
end)

local i = 0
timer.setInterval(1, function()
  print('running process...' .. i)
  i = i + 1
  if i == 5 then
    process.kill(process.pid, constants.SIGUSR1)
  end
end)

process:on('SIGHUP', function()
  sighup = true
end)
process.kill(process.pid, constants.SIGHUP)

process:on('exit', function()
  assert(first == 1)
  assert(second == 1)
  assert(sighup == true)
end)
