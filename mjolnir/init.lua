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

local resize_current_window_to_half_screen_left = function()
  return function()
    cur_window_grid = grid.get(current_window())
    width = grid.GRIDWIDTH / 2
    set_current_window_grid(0, 0, width, grid.GRIDHEIGHT)
  end
end

local resize_current_window_to_half_screen_right = function()
  return function()
    cur_window_grid = grid.get(current_window())
    x = grid.GRIDWIDTH / 2
    width = grid.GRIDWIDTH / 2
    set_current_window_grid(x, 0, width, grid.GRIDHEIGHT)
  end
end

hotkey.bind(mash, "left", resize_current_window_to_half_screen_left())
hotkey.bind(mash, "right", resize_current_window_to_half_screen_right())
hotkey.bind(mash, "b", function() set_current_window_grid(0, 0, grid.GRIDWIDTH, grid.GRIDHEIGHT) end)

