-- appSwitcher.lua

local M = {}

M.hyper = { "cmd", "o" }
-- Define the key-app mappings
M.keyAppPairs = {
	["1"] = "dev.warp.Warp-Stable",
	["2"] = "com.jetbrains.PhpStorm",
	-- ["2"] = "com.jetbrains.WebStorm",
	["3"] = "de.beyondco.herd",
	-- ["4"] = "com.brave.Browser",
	-- ["4"] = "company.thebrowser.Browser",
	["4"] = "app.zen-browser.zen",
	["5"] = "com.clickup.desktop-app",
	["6"] = "com.microsoft.teams2",
	["7"] = "com.microsoft.Outlook",
}

-- Function to focus windows based on app bundle ID
function M.focusWindowByApp(bundleID)
	local app = hs.application.get(bundleID)
	local appName = hs.application.nameForBundleID(bundleID)
	if app then
		local windows = app:allWindows()
		if windows and #windows > 0 then
			local win = hs.window.focusedWindow()
			if win and #windows > 1 and app == win:application() then
				windows[#windows]:focus()
			else
				windows[1]:focus()
			end
		else
			if appName then
				hs.application.launchOrFocus(appName)
			end
		end
	else
		hs.application.launchOrFocus(appName)
	end
end

function M.registerWindowSwitchKeys()
	for key, app in pairs(M.keyAppPairs) do
		hs.hotkey.bind(M.hyper, key, function()
			M.focusWindowByApp(app)
		end)
	end
end

return M
