local DIM_ALPHA = 0.8
local BROWSERS = {
	["Google Chrome"] = true,
	["Firefox"] = true,
	["Safari"] = true,
	["Brave Browser"] = true,
}

local M = {}

local dimmed = true

local wf = hs.window.filter.new():setDefaultFilter()

local function shouldDim(win)
	if not win or not win:application() then
		return false
	end
	if not BROWSERS[win:application():name()] then
		return false
	end
	if win:isFullScreen() then
		return false
	end
	return dimmed
end

local function apply(win)
	if not win or not win:isStandard() then
		return
	end

	if shouldDim(win) then
		hs.window.setAlpha(win, DIM_ALPHA)
	else
		hs.window.setAlpha(win, 1.0)
	end
end
function M.init()
	wf:subscribe({
		hs.window.filter.windowFocused,
		hs.window.filter.windowCreated,
		hs.window.filter.windowFullscreened,
		hs.window.filter.windowUnfullscreened,
	}, function(win)
		hs.timer.doAfter(0.05, function()
			apply(win)
		end)
	end)
end

-- Hotkey: toggle dimming
hs.hotkey.bind({ "ctrl", "alt" }, "D", function()
	dimmed = not dimmed
	for _, win in ipairs(hs.window.allWindows()) do
		apply(win)
	end
end)

return M
