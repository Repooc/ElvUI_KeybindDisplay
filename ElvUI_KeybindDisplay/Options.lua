local KD, E, L, V, P, G = unpack(select(2, ...))
local ACH = E.Libs.ACH
local AB = E.ActionBars

local selectedHotKey, selectedNewText
local tempTextReplacement = {}

local function ColorizeName(name, color)
	return format('|cFF%s%s|r', color or 'ffd100', name)
end

local tbl = { [-1] = '|cff0080FFBlizzard|r Default' }

local function SetupButtonOptions(barType, binding, numButtons, isPlayerBars)
	local getValues, getButtonSetting, setButtonSetting
	local HotKey
	for i = 1, numButtons do
		getValues = function()
			local keys = {GetBindingKey(binding..i)}
			local save1 = tbl[-1]
			wipe(tbl)
			tbl[-1] = save1

			for _, key in next, keys do
				tbl[key] = key
			end

			return tbl
		end

		getButtonSetting = function()
			local command = binding..i
			local keys = {GetBindingKey(command)}
			if not tContains(keys, E.db.kd.binding[command].hotKey) then return -1 end

			return E.db.kd.binding[command].hotKey
		end
		setButtonSetting = function(_, value)
			local command = binding..i
			E.db.kd.binding[command].hotKey = value
			KD:UpdateButtonDB(command)
		end

		if isPlayerBars then
			HotKey = ACH:Select(L["Button "]..i, nil, i, getValues, nil, nil, getButtonSetting, setButtonSetting)
			KD.Options.args.playerbars.args[barType].args[''..i] = HotKey
		else
			HotKey = ACH:Select(L["Button "]..i, nil, i, getValues, nil, nil, getButtonSetting, setButtonSetting)
			KD.Options.args[barType].args[''..i] = HotKey
		end
	end
end

local function AddNewText()
	local originalText = tempTextReplacement.originalText
	if E.db.kd.replacements[originalText] then
		print('Original Text already exsist!')
		return
	elseif originalText and originalText ~= '' and not E.db.kd.replacements[originalText] then
		E.db.kd.replacements[originalText] = tempTextReplacement.newText
		selectedHotKey = originalText
		selectedNewText = tempTextReplacement.newText
		KD:UpdateButtonDB('PEW')

		KD.Options.args.general.args.textreplacegroup.args.textreplaceoptions.name = format(L["Search for: |cff33ff33%s|r"], selectedHotKey)
		tempTextReplacement.originalText = ''
		tempTextReplacement.newText = ''
	end
end

local function TextReplaceGroup()
	local options = ACH:Group('', nil, 101, nil, nil, nil, function() return not AB.Initialized or _G.ElvUI_KeyBinder.active end)
	options.guiInline = true

	options.args.header1 = ACH:Header('Add New Text Replacement', 0, nil, nil, nil)
	options.args.originalText = ACH:Input(L["Original Text"], nil, 1, nil, 'full', function() return tempTextReplacement.originalText end, function(_, value) tempTextReplacement.originalText = value end, nil, nil, function(_, value) if E.db.kd.replacements[value] then print(format(L["You are already replacing the keybind text, %s."], value)) return false end return true end)
	options.args.newText = ACH:Input(L["New Text"], nil, 2, nil, 'full', function() return tempTextReplacement.newText end, function(_, value) tempTextReplacement.newText = value end, nil, nil, function(_, value) if not tempTextReplacement.originalText then print('Fill in the Original Text Box First!') return false elseif tempTextReplacement.originalText == value then print('Original and New Text can not be the same!') return false end return true end)
	options.args.add = ACH:Execute(L['Add'], nil, 3, AddNewText, nil, nil, 'full', nil, nil, function() return E.db.kd.replacements[tempTextReplacement.originalText] or not tempTextReplacement.originalText or tempTextReplacement.originalText == '' or not tempTextReplacement.newText or tempTextReplacement.newText == '' end, hidden)
	options.args.header2 = ACH:Header(function() return (selectedHotKey and selectedHotKey ~= '') and format(L["Editing Keybind Text: %s"], selectedHotKey) or nil end, 4)

	options.args.hotKeyList = ACH:Select(L["List of Replacements"], desc, 5,
	function()
		local hotKeyList = {}
		hotKeyList[''] = NONE
		for name in pairs(E.db.kd.replacements) do
			hotKeyList[name] = name
		end
		if not selectedHotKey then
			selectedHotKey = ''
			selectedNewText = ''
		end
		return hotKeyList
	end,
	confirm, width,
	function() return selectedHotKey end,
	function(_, value)
		selectedHotKey = value
		selectedNewText = E.db.kd.replacements[selectedHotKey]
		KD.Options.args.general.args.textreplacegroup.args.textreplaceoptions.name = format(L["Search for: |cff33ff33%s|r"], selectedHotKey)
	end, disabled, hidden)

	local TextReplaceOptions = ACH:Group('', desc, 8, childGroups, get, set, disabled, function() return selectedHotKey == '' end)
	options.args.textreplaceoptions = TextReplaceOptions
	TextReplaceOptions.guiInline = true

	TextReplaceOptions.args.newText = ACH:Input(L["Replace with: "], nil, 1, nil, 'full', function() return selectedNewText end, function(_, value) selectedNewText = value end, nil, nil,
	function(_, value)
		if selectedNewText == value then
			print('Your your search text and replace text are the same values. Please change your replace value with something else.')
			return false
		elseif selectedNewText == '' or not selectedNewText or selectedHotKey == '' or not selectedHotKey then
			return false
		end

		return true
	end)

	TextReplaceOptions.args.edit = ACH:Execute(ColorizeName(L['Edit'], '33ff33'), nil, 2, function() E.db.kd.replacements[selectedHotKey] = selectedNewText; KD:UpdateButtonDB('PEW') end, nil, nil, 'full', get, nil, function() local disabled = not selectedHotKey or not selectedNewText or (selectedHotKey == selectedNewText) return disabled end, function() return E.db.kd.replacements[selectedHotKey] == selectedNewText end)
	TextReplaceOptions.args.delete = ACH:Execute(ColorizeName(L['Delete'], 'ff3333'), nil, 3, function() E.db.kd.replacements[selectedHotKey] = nil selectedHotKey = '' selectedNewText = '' KD:UpdateButtonDB('PEW') KD.Options.args.general.args.textreplacegroup.args.textreplaceoptions.name = '' end, nil, function() return L["Are you sure you want to delete this?"] end, 'full')
	options.args.header3 = ACH:Header('', 9)

	return options
end

local function configTable()
	local kd = ACH:Group('|cFFFFFFFFKeybind|r|cFF16C3F2Display|r', nil, 6, 'tab', nil, nil, function() return not AB.Initialized end)
	local rrp = E.Options.args.rrp
	if rrp then
		E.Options.args.rrp.args.kd = kd
		KD.Options = E.Options.args.rrp.args.kd
	else
		E.Options.args.kd = kd
		KD.Options = E.Options.args.kd
	end

	local General = ACH:Group(L["General"], nil, 9, 'tree', nil, nil, function() return not AB.Initialized or _G.ElvUI_KeyBinder.active end)
	kd.args.general = General
	General.args.shortElvUIText = ACH:Toggle(L["Use ElvUI Short Keybind Text"], desc, 1, tristate, confirm, width, function(info) return E.db.kd[info[#info]] end, function(info, value) E.db.kd[info[#info]] = value KD:UpdateButtonDB('PEW') end, disabled, hidden)
	General.args.noTruncateAll = ACH:Toggle(L["Reduce Keybind Text Truncating"], L["This will utilize the width of the button for the keybind text which allows the text to not truncate so early."], 2, tristate, confirm, width, function(info) return E.db.kd[info[#info]] end, function(info, value) E.db.kd[info[#info]] = value KD:UpdateButtonDB('PEW') end, disabled, hidden)
	General.args.textreplacegroup = TextReplaceGroup()

	local PlayerBars = ACH:Group(L["Player Bars"], nil, 10, 'tree', nil, nil, function() return not AB.Initialized or _G.ElvUI_KeyBinder.active end)
	kd.args.playerbars = PlayerBars

	local PetBar = ACH:Group(L["Pet Bar"], nil, 15, 'tree', nil, nil, function() return not AB.Initialized or _G.ElvUI_KeyBinder.active end)
	kd.args.petbar = PetBar

	local StanceBar = ACH:Group(L["Stance Bar"], nil, 20, 'tree', nil, nil, function() return not AB.Initialized or _G.ElvUI_KeyBinder.active end)
	kd.args.stancebar = StanceBar

	for i = 1, 10 do
		local Bar = ACH:Group(L["Bar "]..i, nil, i, 'group', nil, nil)
		kd.args.playerbars.args['bar'..i] = Bar
	end
	if E.Retail then
		for i = 13, 15 do
			local Bar = ACH:Group(L["Bar "]..i, nil, i, 'group', nil, nil)
			kd.args.playerbars.args['bar'..i] = Bar
		end
	end
	for bar, values in next, KD.barDefaults do
		if bar == 'stancebar' or bar == 'petbar' then
			SetupButtonOptions(bar, values.binding, values.buttons)
		else
			SetupButtonOptions(bar, values.binding, values.buttons, true)
		end
	end
end

tinsert(KD.Configs, configTable)
