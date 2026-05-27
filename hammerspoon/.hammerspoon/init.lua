hs.loadSpoon("ControlEscape"):start()
-- local switcher = require("appSwitcher")
local chooser = require("quickOpenChooser")

-- local dimmer = require("browserDimming")
-- dimmer.init()

-- local mover = require("windowMoving")

-- switcher.registerWindowSwitchKeys()
chooser.registerModalChooserKeys()
-- mover.registerWindowResizeKeys()

local oeKeycode = hs.keycodes.map[41]

local function applyWebLayout()
	local mainScreen = "LG HDR 4K"
	-- local laptopScreen = "Built-in Retina Display"
	local windowLayout = {
		{ "Brave Browser", "Brave", mainScreen, hs.layout.left50, nil, nil },
		{ "Brave Browser", "DevTools", mainScreen, hs.layout.right50, nil, nil },
	}
	hs.layout.apply(windowLayout)
end

hs.hotkey.bind({ "cmd", "ctrl" }, oeKeycode, function()
	print(hs.screen.allScreens()[1]:name())
	print(hs.screen.allScreens()[2]:name())
	local mainScreen = hs.screen.find("LG HDR 4k")
	print(mainScreen:name())
	local max = mainScreen:frame()
	print(max.y)
	print(max.x)
	print(max.w)
	print(max.h)
	local apps = hs.application.applicationsForBundleID("com.brave.Browser")
	print(apps[1]:name())
	local windows = apps[1]:allWindows()
	for _, value in pairs(windows) do
		print(value)
	end
	applyWebLayout()
end)
