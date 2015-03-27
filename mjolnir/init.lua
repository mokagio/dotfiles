local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local grid = require "mjolnir.bg.grid"

-- Define hotkey combo
local mash = { "cmd", "alt" }
local powermash = { "cmd", "alt", "ctrl" }

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
    width = grid.GRIDWIDTH / 2
    set_current_window_grid(0, 0, width, grid.GRIDHEIGHT)
  end
end

local resize_current_window_to_half_screen_right = function()
  return function()
    x = grid.GRIDWIDTH / 2
    width = grid.GRIDWIDTH / 2
    set_current_window_grid(x, 0, width, grid.GRIDHEIGHT)
  end
end

local resize_current_window_to_half_screen_top = function()
  return function()
    set_current_window_grid(0, 0, grid.GRIDWIDTH, grid.GRIDHEIGHT / 2)
  end
end

local resize_current_window_to_half_screen_bottom = function()
  return function()
    half_screen = grid.GRIDHEIGHT / 2
    set_current_window_grid(0, half_screen, grid.GRIDWIDTH, half_screen)
  end
end

hotkey.bind(mash, "left", resize_current_window_to_half_screen_left())
hotkey.bind(mash, "right", resize_current_window_to_half_screen_right())
hotkey.bind(mash, "up", resize_current_window_to_half_screen_top())
hotkey.bind(mash, "down", resize_current_window_to_half_screen_bottom())
hotkey.bind(mash, "b", grid.maximize_window)

hotkey.bind(powermash, "right", grid.pushwindow_nextscreen)
hotkey.bind(powermash, "left", grid.pushwindow_prevscreen)
