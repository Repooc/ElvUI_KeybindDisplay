local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local AB = E.ActionBars
local AddOnName, Engine = ...

local KD = E:NewModule(AddOnName, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')
Engine[1] = KD
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[AddOnName] = Engine

KD.Configs = {}
KD.barDefaults = {
	bar1 = {
		locale = L["Bar 1"],
		binding = 'ACTIONBUTTON',
		buttons = 12,
	},
	bar2 = {
		locale = L["Bar 2"],
		binding = 'ELVUIBAR2BUTTON',
		buttons = 12,
	},
	bar3 = {
		locale = L["Bar 3"],
		binding = 'MULTIACTIONBAR3BUTTON',
		buttons = 12,
	},
	bar4 = {
		locale = L["Bar 4"],
		binding = 'MULTIACTIONBAR4BUTTON',
		buttons = 12,
	},
	bar5 = {
		locale = L["Bar 5"],
		binding = 'MULTIACTIONBAR2BUTTON',
		buttons = 12,
	},
	bar6 = {
		locale = L["Bar 6"],
		binding = 'MULTIACTIONBAR1BUTTON',
		buttons = 12,
	},
	bar7 = {
		locale = L["Bar 7"],
		binding = 'ELVUIBAR7BUTTON',
		buttons = 12,
	},
	bar8 = {
		locale = L["Bar 8"],
		binding = 'ELVUIBAR8BUTTON',
		buttons = 12,
	},
	bar9 = {
		locale = L["Bar 9"],
		binding = 'ELVUIBAR9BUTTON',
		buttons = 12,
	},
	bar10 = {
		locale = L["Bar 10"],
		binding = 'ELVUIBAR10BUTTON',
		buttons = 12,
	},
	petbar = {
		locale = L["Pet Bar"],
		binding = 'BONUSACTIONBUTTON',
		buttons = 10,
	},
	stancebar = {
		locale = L["Stance Bar"],
		binding = 'SHAPESHIFTBUTTON',
		buttons = 10,
	}
}

if E.Retail then
	KD.barDefaults.bar13 = {
		locale = L["Bar 13"],
		binding = 'MULTIACTIONBAR5BUTTON',
		buttons = 12,
	}
	KD.barDefaults.bar14 = {
		locale = L["Bar 14"],
		binding = 'MULTIACTIONBAR6BUTTON',
		buttons = 12,
	}
	KD.barDefaults.bar15 = {
		locale = L["Bar 15"],
		binding = 'MULTIACTIONBAR7BUTTON',
		buttons = 12,
	}
end

local function GetOptions()
	for _, func in pairs(KD.Configs) do
		func()
	end
end

function KD:FixKeybindText(button)
	if not button then return end
	local hotkey = button.HotKey
	local oldWidth

	local binding, currentText
	if button.keyBoundTarget then
		binding = button.keyBoundTarget
	elseif button.commandName then
		binding = button.commandName
	end
	if binding then
		currentText = GetBindingKey(binding)
	end

	if not button.useMasque then
		if button:GetWidth() ~= hotkey:GetWidth() then
			oldWidth = hotkey:GetWidth()
		end

		if KD.db.noTruncateAll or button.kd and button.kd.noTruncate then
			hotkey:Width(button:GetWidth())
		else
			if oldWidth then
				hotkey:Width(oldWidth)
			end
		end
	end

	if currentText and currentText ~= _G.RANGE_INDICATOR then
		if button.kd and button.kd.hotKey and button.kd.hotKey ~= -1 then
			currentText = button.kd.hotKey
		end

		if KD.db.shortElvUIText then
			currentText = gsub(currentText, 'SHIFT%-', L["KEY_SHIFT"])
			currentText = gsub(currentText, 'ALT%-', L["KEY_ALT"])
			currentText = gsub(currentText, 'CTRL%-', L["KEY_CTRL"])
			currentText = gsub(currentText, 'BUTTON', L["KEY_MOUSEBUTTON"])
			currentText = gsub(currentText, 'MOUSEWHEELUP', L["KEY_MOUSEWHEELUP"])
			currentText = gsub(currentText, 'MOUSEWHEELDOWN', L["KEY_MOUSEWHEELDOWN"])
			currentText = gsub(currentText, 'NUMPAD', L["KEY_NUMPAD"])
			currentText = gsub(currentText, 'PAGEUP', L["KEY_PAGEUP"])
			currentText = gsub(currentText, 'PAGEDOWN', L["KEY_PAGEDOWN"])
			currentText = gsub(currentText, 'SPACE', L["KEY_SPACE"])
			currentText = gsub(currentText, 'INSERT', L["KEY_INSERT"])
			currentText = gsub(currentText, 'HOME', L["KEY_HOME"])
			currentText = gsub(currentText, 'DELETE', L["KEY_DELETE"])
			currentText = gsub(currentText, 'NMULTIPLY', '*')
			currentText = gsub(currentText, 'NMINUS', 'N-')
			currentText = gsub(currentText, 'NPLUS', 'N+')
			currentText = gsub(currentText, 'NEQUALS', 'N=')
		end

		if KD.db.replacements[currentText] then
			currentText = KD.db.replacements[currentText]
		end

		hotkey:SetText(currentText)
	end
end

function KD:UpdateButtonDB(specific)
	for button in pairs(AB.handledbuttons) do
		local binding = button.commandName or button.keyBoundTarget
		if binding then
			button.kd = KD.db.binding[binding]
			if specific and (specific == 'PEW' or specific == binding) then
				KD:FixKeybindText(button)
			end
		end
	end
end

local function UpdateDB()
	KD.db = E.db.kd
	KD:UpdateButtonDB('PEW')
end

function KD:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	KD.db = E.db.kd

	hooksecurefunc(E, 'UpdateDB', UpdateDB)
	hooksecurefunc(AB, 'FixKeybindText', KD.FixKeybindText)
	KD:UpdateButtonDB('PEW')
end

E.Libs.EP:HookInitialize(KD, KD.Initialize)
