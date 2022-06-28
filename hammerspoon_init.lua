local mash = { "cmd", "alt" }
local powermash = { "cmd", "alt", "ctrl" }

-- Make the grid a 4x4, that is, each screen will have 4 quadrants
hs.grid.setGrid('4x4')

-- Reload the configuration
hs.hotkey.bind(powermash, "R", function()
  hs.reload()
end)

-- Resize a window to the 2048x1152 (16:9) format best suited for Twitter
-- I use this to create the vimforxcode.com images
--
-- H 1095 ... 2190 ... 2190/2 = 1095!
-- W 1792
-- The sizes are / 2!
--
-- What's 16:9 of the fullscreen width size in points?
-- 1792 / x = 16 / 9
-- x = 9 * 1792 / 16
-- x = 1008
hs.hotkey.bind(powermash, 'N', function()
  local win = hs.window.focusedWindow()
  -- local geometry = hs.geometry(0, 0, 1024, 756)
  local geometry = hs.geometry(0, 0, 1792, 1008)
  win:move(geometry)
  hs.alert.show(win:size())
end)

hs.hotkey.bind(mash, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(mash, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(mash, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind(mash, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.h / 2
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind(mash, "B", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
  -- hs.alert.show(win:size())
end)

hs.hotkey.bind(mash, "1", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 4
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(mash, "3", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 4
  f.y = max.y
  f.w = max.w * 3 / 4
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(powermash, "Right", function()
  local win = hs.window.focusedWindow()
  hs.grid.pushWindowRight(win)
end)

hs.hotkey.bind(powermash, "Left", function()
  local win = hs.window.focusedWindow()
  hs.grid.pushWindowLeft(win)
end)

hs.alert.show("Config loaded")
