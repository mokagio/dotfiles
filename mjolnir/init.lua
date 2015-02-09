local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local grid = require "mjolnir.bg.grid"

-- Define hotkey combo
local mash = { "cmd", "alt" }

grid.MARGINX = 0
grid.MARGINY = 0
grid.GRIDWIDTH = 2
grid.GRIDHEIGHT = 2

local current_window = function()
  return window.focusedwindow()
end

local set_current_window_grid = function(x, y, w, h)
  grid.set(
    current_window(),
    {x=x, y=y, w=w, h=h},
    current_window():screen()
  )
end

local loop_push_current_window_left = function()
  return function()
    cur_window_grid = grid.get(current_window())
    width = cur_window_grid.w - 1
    if width == 0 then width = grid.GRIDWIDTH end
    set_current_window_grid(0, 0, width, grid.GRIDHEIGHT)
  end
end

local loop_push_current_window_right = function()
  return function()
    cur_window_grid = grid.get(current_window())
    x = cur_window_grid.x + 1
    if x == grid.GRIDWIDTH then x = 0 end
    width = grid.GRIDWIDTH - x
    set_current_window_grid(x, 0, width, grid.GRIDHEIGHT)
  end
end

hotkey.bind(mash, "left", loop_push_current_window_left())
hotkey.bind(mash, "right", loop_push_current_window_right())
hotkey.bind(mash, "b", function() set_current_window_grid(0, 0, grid.GRIDWIDTH, grid.GRIDHEIGHT) end)

