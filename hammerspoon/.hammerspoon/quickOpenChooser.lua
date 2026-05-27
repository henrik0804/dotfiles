local switcher = require("appSwitcher")
local M = {}
QuickOpen = nil
local function openSelected(app)
	if app then
		app.app:activate()
	end
end

local function setQuickOpen(app)
	if app then
		QuickOpen = app
		openSelected(app)
	end
end

local appChooser = hs.chooser.new(setQuickOpen)

local function setModalChoices()
	local choices = {}
	local windows = hs.window:visibleWindows()

	for _, win in ipairs(windows) do
		local app = win:application()
		local bundleID = app:bundleID()
		local name = app:name()

		local exclude = false
		if name == "Finder" then
			exclude = true
		end

		for _, id in pairs(switcher.keyAppPairs) do
			if exclude then
				break
			end
			if bundleID == id then
				exclude = true
				break
			end
		end
		if not exclude then
			table.insert(choices, {
				text = name,
				app = app,
			})
		end
	end

	appChooser:choices(choices)
end

function M.registerModalChooserKeys()
	hs.hotkey.bind({ "cmd-ctrl-shift" }, "E", nil, function()
		setModalChoices()
		appChooser:show()
	end)

	hs.hotkey.bind({ "cmd-ctrl" }, "E", nil, function()
		if QuickOpen ~= nil then
			openSelected(QuickOpen)
			return
		end
		setModalChoices()
		appChooser:show()
	end)
end
return M
