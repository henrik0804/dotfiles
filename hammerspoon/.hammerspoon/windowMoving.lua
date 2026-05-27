local M = {}
local resizeTimer = nil
local resizeDelayTimer = nil

local function resizeWindowOnce(direction)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local f = win:frame()

	if direction == "up" then
		f.h = math.max(100, f.h - 10)
	elseif direction == "down" then
		f.h = f.h + 10
	elseif direction == "left" then
		f.w = math.max(100, f.w - 10)
	elseif direction == "right" then
		f.w = f.w + 10
	end

	win:setFrame(f)
end

local function startResizingWindow(direction)
	-- Step 1: immediate resize
	resizeWindowOnce(direction)

	-- Step 2: if held, start continuous resizing after 1s
	resizeDelayTimer = hs.timer.doAfter(1.0, function()
		resizeTimer = hs.timer.doEvery(0.05, function()
			resizeWindowOnce(direction)
		end)
	end)
end

local function stopResizingWindow()
	if resizeDelayTimer then
		resizeDelayTimer:stop()
		resizeDelayTimer = nil
	end
	if resizeTimer then
		resizeTimer:stop()
		resizeTimer = nil
	end
end

function M.registerWindowResizeKeys()
	hs.hotkey.bind({ "cmd", "ctrl" }, "K", function()
		stopResizingWindow()
		startResizingWindow("up")
	end, stopResizingWindow)

	hs.hotkey.bind({ "cmd", "ctrl" }, "J", function()
		stopResizingWindow()
		startResizingWindow("down")
	end, stopResizingWindow)

	hs.hotkey.bind({ "cmd", "ctrl" }, "H", function()
		stopResizingWindow()
		startResizingWindow("left")
	end, stopResizingWindow)

	hs.hotkey.bind({ "cmd", "ctrl" }, "L", function()
		stopResizingWindow()
		startResizingWindow("right")
	end, stopResizingWindow)
end

return M
