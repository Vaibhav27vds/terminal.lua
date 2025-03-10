-- Test getting character width by printing and reading cursor pos afterwards.
-- Usefull for East Asian Width ambiguous characters.
--
-- Tests 2 mechanisms;
-- 1. Using individual characters to write and test.
-- 2. Using the 'preload' to test many at once (way faster)

local t = require("terminal")
local w = require("terminal.width")
local p = require("terminal.progress")
local sys = require("system")

local pr

local function test()
  local stime = sys.gettime()
  for n = 0, #pr do
    local sprite = pr[n]
    local c = w.write_swidth(sprite)
    t.output.write(c,"\n")
  end

  t.output.write(("-time: %.1f s"):format(sys.gettime() - stime).."\n")
end


assert(t.initwrap({}, function()
  pr = p.sprites.bar_horizontal
  pr[0] = "✔"
  test()
  test()
  pr = p.sprites.moon
  pr[math.random( 0,8)] = "✔"
  local stime = sys.gettime()
  w.preload(table.concat(pr))
  t.output.write(("preload-time: %.1f s"):format(sys.gettime() - stime).."\n")
  test()
  test()
  return true
end))
