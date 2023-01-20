----------------------------------------
-- Namespaces
--------------------------------------
local _, L = ...;

L.Spells = {}; -- adds Spells table to addon namespace

local Spells = L.Spells;
local UISpells;
local tooltip = CreateFrame("GameTooltip", "MouseoverTooltip", UIParent, "GameTooltipTemplate")
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitHealth = UnitHealth
local UnitName = UnitName
local UnitGUID = UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInInstance = IsInInstance
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local GetName = GetName
local GetNumGroupMembers = GetNumGroupMembers
local GetNumArenaOpponents = GetNumArenaOpponents
local GetInstanceInfo = GetInstanceInfo
local GetZoneText = GetZoneText
local SetPortraitToTexture = SetPortraitToTexture
local ipairs = ipairs
local pairs = pairs
local next = next
local type = type
local select = select
local strsplit = strsplit
local strfind = string.find
local strmatch = string.match
local tblinsert = table.insert
local tblremove= table.remove
local mathfloor = math.floor
local mathabs = math.abs
local bit_band = bit.band
local tblsort = table.sort
local substring = string.sub
local tonumber = tonumber
local unpack = unpack
local SetScript = SetScript
local SetUnitDebuff = SetUnitDebuff
local SetOwner = SetOwner
local OnEvent = OnEvent
local CreateFrame = CreateFrame
local SetTexture = SetTexture
local SetNormalTexture = SetNormalTexture
local SetSwipeTexture = SetSwipeTexture
local SetCooldown = SetCooldown
local SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor, SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor = SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor,  SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor
local SetText = SetText
local SetChecked = SetChecked
local Disable = Disable
local AddLine = AddLine
local AddDoubleLine = AddDoubleLine
local GetVerticalScrollRange = GetVerticalScrollRange
local SetOwner = SetOwner
local getglobal = getglobal
local GetVerticalScroll = GetVerticalScroll
local GetChecked = GetChecked
local SetSpellByID = SetSpellByID
local CreateFontString = CreateFontString
local GetStringWidth = GetStringWidth
local _G = _G
local ClearAllPoints = ClearAllPoints
local GetParent = GetParent
local GetFrameLevel = GetFrameLevel
local GetDrawSwipe = GetDrawSwipe
local GetDrawLayer = GetDrawLayer
local GetAlpha = GetAlpha
local Hide = Hide
local Show = Show
local IsShown = IsShown
local IsVisible = IsVisible
local playerGUID
local print = print
local contents = { };
--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	theme = {
		r = 0,
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	}
}


local tabs = {}

local tabsType = {
	"CC",
	"Silence",
	"Interrupt",
	"Disarm",
	"Root",
  "Immune",
  "Other",
  "Warning",
  "Snare",
	}

local tabsIndex = {}
for i = 1, #tabsType do
	tabsIndex[tabsType[i]] = i
end

local tabsDrop = {}
for i = 1, #tabsType + 1 do
	if not tabsType[i] then
		tabsDrop[i] = "Delete"
	else
		tabsDrop[i] = tabsType[i]
	end
end


local function GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);

	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end

	self:SetVerticalScroll(newValue);
end

local function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Enable();
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

local function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Hide();
	getglobal(name.."Middle"):Hide();
	getglobal(name.."Right"):Hide();
	--tab:LockHighlight();
	tab:Disable();
	getglobal(name.."LeftDisabled"):Show();
	getglobal(name.."MiddleDisabled"):Show();
	getglobal(name.."RightDisabled"):Show();

	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

local function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

local function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = getglobal(frame:GetName().."Tab"..i);
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

local function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = UISpells.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpells.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
end

local function makeAndShowSpellTTPVE(self)
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	if type(self.spellID) == "number" then
	GameTooltip:SetSpellByID(self.spellID)
	else
		GameTooltip:SetText(self.spellID, 1, 1, 1, true)
		GameTooltip:AddLine("This Spell Uses the Name not SpellID.", 1.0, 0.82, 0.0, true);
	end
	if (self:GetChecked()) then
		GameTooltip:AddDoubleLine("|cff66FF00Enabled")
	else
		GameTooltip:AddDoubleLine("|cffFF0000Disabled")
	end
	GameTooltip:Show()
end

local function makeGreenBar(self)
	local text
	if type(self.spellID) == "number" then text = GetSpellInfo(self.spellID) else text = self.spellID end
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	GameTooltip:SetText(text, 1, 1, 1, true)
	GameTooltip:AddLine("Set the Red Bar to Green.", 1.0, 0.82, 0.0, true);
	if (self:GetChecked()) then
		GameTooltip:AddDoubleLine("|cff66FF00Enabled")
	else
		GameTooltip:AddDoubleLine("|cffFF0000Disabled")
	end
	GameTooltip:Show()
end

local function DeleteSpellFrame(spellID, c)
	if spellID then
		if _G[c:GetName().."spellCheck"..spellID] then
			_G[c:GetName().."spellCheck"..spellID] = nil
		end
	end
end

local function GetSpellFrame(spellID, c)
	if spellID then
		if _G[c:GetName().."spellCheck"..spellID] then
			return _G[c:GetName().."spellCheck"..spellID]
		else
			return false
		end
	end
end

local function CustomAddedCompileSpells(spell, prio, tab, string) --Adding a Custom Spell
	for k, v in ipairs(_G.EasyCCDB.customSpellIds) do
		if spell == v[1] then
			tblremove(_G.EasyCCDB.customSpellIds, k)
			break
		end
	end
	for i = 1, #L.spells do
		for l = 1, #L.spells[i] do
			for k, v in ipairs(L.spells[i][l]) do
				local spellID, oldPrio, _, _, customname = unpack(v)
				if spell == spellID then
					L.Spells:WipeSpellList(i); print("|cff00ccffEasyCC|r : ".."|cff009900Removed |r"..spellID.." |cff009900from : |r"..L.spellsTable[i][1])
					tblremove(L.spells[i][l], k)
					L.Spells:UpdateSpellList(i)
					break
				end
			end
		end
	end
	L.spellIds[spell] = prio; _G.EasyCCDB.spellDisabled[spell] = nil
	if string then _G.EasyCCDB.customString[spell] = string end
	L.Spells:WipeSpellList(tab)
	tblinsert(_G.EasyCCDB.customSpellIds, {spell, prio, string, nil, nil, "Custom Spell", tab})
	tblinsert(L.spells[tab][1], 1, {spell, prio, string, nil, nil, "Custom Spell", tab})
	L.Spells:UpdateSpellList(tab, true)
	print("|cff00ccffEasyCC|r : ".."|cff009900Added |r"..spell.." |cff009900to to list: |r"..tabs[tab])
end

local function CustomPVEDropDownCompileSpells(spell, prio, tab, c) --Changing the Dropdown of a Spell
	for k, v in ipairs(_G.EasyCCDB.customSpellIds) do
		if spell == v[1] then
			tblremove(_G.EasyCCDB.customSpellIds, k)
			break
		end
	end
	for l = 1, (#tabsType) do
		for k, v in ipairs(L.spells[tab][l]) do
			local spellID, oldPrio, _, _, _, customname = unpack(v)
			if spell == spellID then
				if prio == "Delete" then
					L.spellIds[spell] = nil
					_G.EasyCCDB.spellDisabled[spell] = nil
					_G.EasyCCDB.customString[spell] = nil
					Spells:WipeSpellList(tab)
					DeleteSpellFrame(spell, c)
					tblremove(L.spells[tab][l], k)
					Spells:UpdateSpellList(tab)
					if L.spellList[spell] then
						tblinsert(_G.EasyCCDB.customSpellIds, {spell, prio, nil, nil, nil, customname, tab})  --v[7]: Category Tab to enter spell
					end
					print("|cff00ccffEasyCC|r : ".."|cff009900Removed |r"..spellID.." |cff009900from : |r"..tabs[tab])
				else
					L.spellIds[spell] = prio
					local string = _G.EasyCCDB.customString[spell]
					if string then customname = "Custom Spell" else customname  = "Custom Priority" end
					tblinsert(_G.EasyCCDB.customSpellIds, {spell, prio, string, nil, nil, customname, tab})  --v[7]: Category Tab to enter spell
					local priotext = L[prio] or prio
					print("|cff00ccffEasyCC|r : ".."|cff009900Changed |r"..spell.." |cff009900to : |r"..priotext)
				end
				break
			end
		end
	end
end


local function createDropdown(opts)
	    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
	    local menu_items = opts['items'] or {}
	    local title_text = opts['title'] or ''
	    local dropdown_width = 0
	    local default_val = opts['defaultVal'] or ''
	    local change_func = opts['changeFunc'] or function (dropdown_val) end

	    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
	    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
	    dd_title:SetPoint("TOPLEFT", 20, 10)

	    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
	        dd_title:SetText(item)
	        local text_width = dd_title:GetStringWidth() + 20
	        if text_width > dropdown_width then
	            dropdown_width = text_width
	        end
	    end

	    UIDropDownMenu_SetWidth(dropdown, 1)
	    UIDropDownMenu_SetText(dropdown, 1)
	    dd_title:SetText(title_text)

	    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
	        local info = UIDropDownMenu_CreateInfo()
	        for key, val in pairs(menu_items) do
						if L[val] then val = L[val] end
	            info.text = val;
	            info.checked = false
							if val == default_val then
								info.checked = true
							end
	            info.menuList= key
	            info.hasArrow = false
	            info.func = function(b)
	                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
	                UIDropDownMenu_SetText(dropdown, b.value)
	                b.checked = true
	                change_func(dropdown, b.value)
	            end
	            UIDropDownMenu_AddButton(info)
	        end
	    end)

	    return dropdown
		end

local function createDropdownAdd(opts)
	    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
	    local menu_items = opts['items'] or {}
	    local title_text = opts['title'] or ''
	    local dropdown_width = 0
	    local default_val = opts['defaultVal'] or ''
	    local change_func = opts['changeFunc'] or function (dropdown_val) end

	    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
	    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
	    dd_title:SetPoint("TOPLEFT", 20, 10)

	    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
	        dd_title:SetText(item)
	        local text_width = dd_title:GetStringWidth() + 20
	        if text_width > dropdown_width then
	            dropdown_width = text_width
	        end
	    end

	    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
	    UIDropDownMenu_SetText(dropdown, dropdown_val)
	    dd_title:SetText(title_text)

	    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
	        local info = UIDropDownMenu_CreateInfo()
	        for key, val in pairs(menu_items) do
						if L[val] then val = L[val] end
	            info.text = val;
	            info.checked = false
	            info.menuList= key
	            info.hasArrow = false
	            info.func = function(b)
	                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
	                UIDropDownMenu_SetText(dropdown, b.value)
	                b.checked = true
	                change_func(dropdown, b.value)
	            end
	            UIDropDownMenu_AddButton(info)
	        end
	    end)

	    return dropdown
		end

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;

	local frameName = frame:GetName();
	local width = {}
	local rows = 1
	local rowCount = 1

	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		tab:SetFrameLevel(10)

		if L[select(i, ...)] then
			tab:SetText(L[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);
		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpells.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
		tab.content.spellstext = tab.content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	--tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

	if tabs[i] == "Discovered Spells" then else
		tab.content.input = CreateFrame("EditBox", tab:GetName()..'CustomSpells', tab.content, 'InputBoxTemplate')
  	tab.content.input:SetSize(100,22)
  	tab.content.input:SetAutoFocus(false)
  	tab.content.input:SetMaxLetters(30)
  	tab.content.input:SetPoint("TOPLEFT", tab.content, "TOPRIGHT", 95, 2)
  	tab.content.input:SetScript('OnChar', function(self, customspelltext)
    tab.content.input.customspelltext = self:GetText() end)
		tab.content.input.Ltext = tab.content.input:CreateFontString(nil, "ARTWORK")
		tab.content.input.Ltext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
		tab.content.input.Ltext:SetTextColor(1, .75, 0, 1)
		tab.content.input.Ltext:SetText("Spell")
		tab.content.input.Ltext:SetJustifyH("LEFT")
		tab.content.input.Ltext:SetParent(tab.content.input)
		tab.content.input.Ltext:SetJustifyH("RIGHT")
		tab.content.input.Ltext:SetPoint("RIGHT", tab.content.input, "LEFT", -4, 0)
		tab.content.inputText = CreateFrame("EditBox", tab:GetName()..'CustomSpellsString', tab.content, 'InputBoxTemplate')
		tab.content.inputText:SetSize(100,22)
		tab.content.inputText:SetAutoFocus(false)
		tab.content.inputText:SetMaxLetters(35)
		tab.content.inputText:SetPoint("TOPLEFT", tab.content, "TOPRIGHT", 95, -17)
		tab.content.inputText:SetScript('OnChar', function(self, customspelltextstring)
		tab.content.inputText.customspelltextstring = self:GetText(); end)
		tab.content.inputText.Ltext = tab.content.inputText:CreateFontString(nil, "ARTWORK")
		tab.content.inputText.Ltext:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
		tab.content.inputText.Ltext:SetTextColor(1, .75, 0, 1)
		tab.content.inputText.Ltext:SetText("Text")
		tab.content.inputText.Ltext:SetJustifyH("LEFT")
		tab.content.inputText.Ltext:SetParent(tab.content.inputText)
		tab.content.inputText.Ltext:SetJustifyH("RIGHT")
		tab.content.inputText.Ltext:SetPoint("RIGHT", tab.content.inputText, "LEFT", -4, 0)
    local drop_val
		local drop_opts = {
				['name']='raid',
				['parent']= tab.content.input,
				['title']='',
				['items']= tabsType,
				['defaultVal']='',
				['changeFunc'] = function(dropdown_frame, dropdown_val)
					drop_val = dropdown_val
					for k, v in ipairs(tabsType) do
							if dropdown_val == L[v] then
								drop_val = v
							end
						end
					end
		}
		local dropdown = createDropdownAdd(drop_opts)
		dropdown:SetPoint("TOPLEFT", tab.content.inputText, "BOTTOMLEFT", 10, 3)
		dropdown:SetScale(.85)

  	tab.content.add = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content.input, "UIPanelButtonTemplate")
    tab.content.add:SetSize(50,22)
  	tab.content.add:SetPoint("TOPLEFT",	tab.content.input, "TOPRIGHT", 2, 0)
  	tab.content.add:SetText("Add")
  	tab.content.add:SetScript("OnClick", function(self, addenemy)
			local spell = GetSpellInfo(tonumber(tab.content.input.customspelltext))
			local string = tab.content.inputText.customspelltextstring
			if spell then spell = tonumber(tab.content.input.customspelltext) else spell = tab.content.input.customspelltext end
			if drop_val and spell then
	  		CustomAddedCompileSpells(spell, drop_val, i, string)
			else
				print("|cff00ccffEasyCC|r : Please Select a Spell Type or Enter a spellId or Name")
			end
    end)
	end

	tab.content.reset = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content, "UIPanelButtonTemplate")
	tab.content.reset:SetSize(70,22)
	tab.content.reset:SetScale(.7)
		if tabs[i] == "Discovered Spells" then
			tab.content.reset:SetPoint("CENTER", tab.content, "CENTER", 860, 245 )
		else
			tab.content.reset:SetPoint("CENTER", tab.content, "CENTER", 860, 214 )
		end
	tab.content.reset:SetText("Enable All")
	tab.content.reset:SetScript("OnClick", function(self, enable)
	Spells:EnableAll(i)
	end)


	tab.content.disable = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content, "UIPanelButtonTemplate")
	tab.content.disable:SetSize(70,22)
	tab.content.disable:SetScale(.7)
	tab.content.disable:SetPoint("TOP",	tab.content.reset, "BOTTOM", 0, -2)
	tab.content.disable:SetText("Disable All")
	tab.content.disable:SetScript("OnClick", function(self, disable)
	Spells:DisableAll(i)
	end)


		if (i == 1) then
			tab:SetPoint("TOPLEFT", UISpells, "BOTTOMLEFT", 5, 7);
		rowCount = 1
		else
				if rowCount <= 9 then
			 		tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
					rowCount = rowCount + 1
	    	else
					y = 7 - (25 * rows)
					tab:SetPoint("TOPLEFT", UISpells, "BOTTOMLEFT", 5, y);
					rows = rows + 1
					rowCount = 1
	    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

local function CreateMenu()

	for i = 1, #L.spellsTable do
		tabs[i] = L.spellsTable[i][1]
	end

	UISpells = CreateFrame("Frame", "EasyCCSpells", UIParent, "UIPanelDialogTemplate");
	local hex = select(4, GetThemeColor());
	local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
	UISpells.Title:SetText('EasyCC Spells Config '..BambiTag)
	UISpells:SetFrameStrata("DIALOG");
	UISpells:SetFrameLevel(10);
	UISpells:EnableMouse(true);
	UISpells:SetMovable(true)
	UISpells:RegisterForDrag("LeftButton")
	UISpells:SetScript("OnDragStart", UISpells.StartMoving)
	UISpells:SetScript("OnDragStop", UISpells.StopMovingOrSizing)

	UISpells:SetSize(1050, 400);
	UISpells:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")


	UISpells.ScrollFrame = CreateFrame("ScrollFrame", nil, UISpells, "UIPanelScrollFrameTemplate");
	UISpells.ScrollFrame:SetPoint("TOPLEFT", EasyCCSpellsDialogBG, "TOPLEFT", 4, -8);
	UISpells.ScrollFrame:SetPoint("BOTTOMRIGHT", EasyCCSpellsDialogBG, "BOTTOMRIGHT", -3, 4);
	UISpells.ScrollFrame:SetClipsChildren(true);
	UISpells.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

	UISpells.ScrollFrame.ScrollBar:ClearAllPoints();
	UISpells.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UISpells.ScrollFrame, "TOPRIGHT", -12, -18);
	UISpells.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UISpells.ScrollFrame, "BOTTOMRIGHT", -7, 18);

	local allContents = SetTabs(UISpells, #tabs, unpack(tabs));

	UISpells:Hide();
	return UISpells;
end

--------------------------------------
-- Spells functions
--------------------------------------
function Spells:Addon_Load()
if not UISpells then CreateMenu(); Spells:UpdateAllSpellList() end
end

function Spells:Toggle() --Builds the Table
	if not UISpells then Spells:CreateMenu(); Spells:UpdateAllSpellList() end
	local menu = UISpells
	menu:SetShown(not menu:IsShown());
end

function Spells:UpdateTab(i)
	if not UISpells then return end
	Spells:WipeSpellList(i)
	Spells:UpdateSpellList(i);
end

function Spells:WipeAll()
if not UISpells then return end
Spells:WipeAllSpellList()
end

function Spells:UpdateAll()
if not UISpells then return end
	Spells:UpdateAllSpellList()
end

function Spells:WipeAllSpellList()
	for i = 1, #tabs do
	Spells:WipeSpellList(i)
	end
end

function Spells:UpdateAllSpellList()
	for i = 1, #tabs do
	Spells:UpdateSpellList(i, true)
	end
end

function Spells:ResetAllSpellList()
	for i = 1, #tabs do
	Spells:EnableAll(i)
	end
end

function Spells:EnableAll(i)
	local c = contents[i]
		for l = 1, #L.spells[i] do
		 	for x = 1, (#L.spells[i][l]) do
			local spellID, _, _, _, _ = unpack(L.spells[i][l][x])
			local spellCheck = GetSpellFrame(spellID, c)
			spellCheck.icon = _G[spellCheck:GetName().."Icon"]
			spellCheck.icon.check = spellCheck
			spellID = spellCheck.spellID
			_G.EasyCCDB.spellDisabled[spellID] = nil
			spellCheck:SetChecked(true);
		end
	end
end

function Spells:DisableAll(i)
	local c = contents[i]
		for l = 1, #L.spells[i] do
		 	for x = 1, (#L.spells[i][l]) do
			local spellID, _, _, _, _ = unpack(L.spells[i][l][x])
			local spellCheck = GetSpellFrame(spellID, c)
			spellCheck.icon = _G[spellCheck:GetName().."Icon"]
			spellCheck.icon.check = spellCheck
			spellID = spellCheck.spellID
			_G.EasyCCDB.spellDisabled[spellID] = true
			spellCheck:SetChecked(false);
		end
	end
end



function Spells:WipeSpellList(i)
local c = contents[i]
	for l = 1, #L.spells[i] do
	 	for x = 1, (#L.spells[i][l]) do
			local spellID, _, _, _, _ = unpack(L.spells[i][l][x])
			local spellCheck = GetSpellFrame(spellID, c)
			if not  spellCheck then return end
			spellCheck:Hide()
		end
	end
end

function Spells:UpdateSpellList(i, typeUpdate)
local numberOfSpellChecksPerRow = 5
	if i == nil then return end
	local c = contents[i]
	local previousSpellID = nil
	local Y = -10
	local X = 230
	local spellCount = 1
	local lspells = 0

	for l = 1, #tabsType do
		lspells = lspells + #L.spells[i][l]
	end

	c.spellstext:SetText("|cff00ccffSpells|r : "..lspells)
	c.spellstext:SetPoint("TOPLEFT", c, "TOPLEFT", 5, 0);

	for l = 1, #L.spells[i] do
		for x = 1 , #L.spells[i][l] do
		local spellID, prio, string, instanceType, zone, customname, tab = unpack(L.spells[i][l][x])
			if (spellID) then
				local spellCheck = GetSpellFrame(spellID, c)
				if spellCheck then
					if (previousSpellID) then
						if (spellCount % numberOfSpellChecksPerRow == 0) then
							Y = Y-40
							X = 30
						end
						spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", X, Y);
						--spellCheck.Green:SetPoint("TOP", spellCheck, "BOTTOM", 0, 21);
						X = X+200
					else
						spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", 30, -10);
						--spellCheck.Green:SetPoint("TOP", spellCheck, "BOTTOM", 0, 21);
					end
					if typeUpdate then
						spellCheck.icon = _G[spellCheck:GetName().."Icon"]
						spellCheck.icon.check = spellCheck
						local aString = spellID
						prio = L[prio] or prio
						if type(spellID) == "number" then
							if (instanceType ==  "arena" or instanceType == "pvp") then
								local name = GetSpellInfo(spellID)
								if name then aString = substring(name, 0, 17)..": "..substring(prio, 0, 6) else aString ="SPELL REMOVED: "..spellID end
								local aString2 = " ("..instanceType..")"
								local cutString1 = substring(aString1, 0, 23);
								local cutString2 = substring(aString2, 0, 23);
								local aString3 = cutString1.."\n"..cutString2
								spellCheck.text:SetText(aString3);
							elseif zone then
								local name = GetSpellInfo(spellID)
								if name then aString = substring(name, 0, 17)..": "..substring(prio, 0, 6) else aString ="SPELL REMOVED: "..spellID end
								local aString2 = zone
								local cutString1 = substring(aString1, 0, 23);
								local cutString2 = substring(aString2, 0, 23);
								local	aString3 = cutString1.."\n"..cutString2
								spellCheck.text:SetText(aString3);
							else
								local name = GetSpellInfo(spellID)
								if name then aString = substring(name, 0, 17)..": "..substring(prio, 0, 6) else aString ="SPELL REMOVED: "..spellID end
								local cutString = substring(aString, 0, 23);
									if customname and string then
										spellCheck.text:SetText(cutString.."\n".."("..customname..")".."\n"..string);
									elseif customname then
										spellCheck.text:SetText(cutString.."\n".."("..customname..")");
									else
										spellCheck.text:SetText(cutString);
									end
							end
							spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
						else
						aString = spellID..": "..prio
						local cutString = substring(aString, 0, 23);
							if customname and string then
								spellCheck.text:SetText(cutString.."\n".."("..customname..")".."\n"..string);
							elseif customname then
								spellCheck.text:SetText(cutString.."\n".."("..customname..")");
							else
								spellCheck.text:SetText(cutString);
							end
						spellCheck.icon:SetNormalTexture(136235)
						end
					end
					spellCheck:Show()
				else
					spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID, c, "UICheckButtonTemplate");
					spellCheck.Green = CreateFrame("CheckButton", spellCheck:GetName().."spellCheckGreen"..spellID, spellCheck, "UICheckButtonTemplate");
					if (previousSpellID) then
						if (spellCount % numberOfSpellChecksPerRow == 0) then
							Y = Y-40
							X = 30
						end
						spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", X, Y);
						spellCheck.Green:SetPoint("TOP", spellCheck, "BOTTOM", 0, 21);
						X = X+200
					else
						spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", 30, -10);
						spellCheck.Green:SetPoint("TOP", spellCheck, "BOTTOM", 0, 21);
					end
					spellCheck:Show()
					spellCheck.Green:SetScale(.4)
					spellCheck.Green:Show()

					spellCheck.icon = CreateFrame("Button", spellCheck:GetName().."Icon", spellCheck, "ActionButtonTemplate")
					spellCheck.icon:Disable()
					spellCheck.icon:SetPoint("CENTER", spellCheck, "CENTER", -90, 0)
					spellCheck.icon:SetScale(0.3)
					spellCheck.icon:Show()

					local aString = spellID
					prio = L[prio] or prio
					if type(spellID) == "number" then
						if (instanceType ==  "arena" or instanceType == "pvp") then
							local name = GetSpellInfo(spellID)
							if name then aString = substring(name, 0, 17)..": "..substring(prio, 0, 6) else aString ="SPELL REMOVED: "..spellID end
							local aString2 = " ("..instanceType..")"
							local cutString1 = substring(aString1, 0, 23);
							local cutString2 = substring(aString2, 0, 23);
							local aString3 = cutString1.."\n"..cutString2
							spellCheck.text:SetText(aString3);
						elseif zone then
							local name = GetSpellInfo(spellID)
							if name then aString1 = substring(name, 0, 17)..": "..substring(prio, 0, 6) else aString1 ="SPELL REMOVED: "..spellID end
							local aString2 = zone
							local cutString1 = substring(aString1, 0, 23);
							local cutString2 = substring(aString2, 0, 23);
						  local	aString3 = cutString1.."\n"..cutString2
							spellCheck.text:SetText(aString3);
						else
							local name = GetSpellInfo(spellID)
							if name then aString = substring(name, 0, 17)..": "..substring(prio, 0, 6) else aString ="SPELL REMOVED: "..spellID end
							local cutString = substring(aString, 0, 23);
							if customname and string then
								spellCheck.text:SetText(cutString.."\n".."("..customname..")".."\n"..string);
							elseif customname then
								spellCheck.text:SetText(cutString.."\n".."("..customname..")");
							else
								spellCheck.text:SetText(cutString);
							end
						end
						spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
					else
					aString = spellID..": "..prio
					local cutString = substring(aString, 0, 23);
						if customname and string then
							spellCheck.text:SetText(cutString.."\n".."("..customname..")".."\n"..string);
						elseif customname then
							spellCheck.text:SetText(cutString.."\n".."("..customname..")");
						else
							spellCheck.text:SetText(cutString);
						end
					spellCheck.icon:SetNormalTexture(136235)
					end

					local drop_opts = {
							['name']='raid',
							['parent']=spellCheck,
							['title']='',
							['items']= tabsDrop,
							['defaultVal']=prio,
							['changeFunc']=function(dropdown_frame, dropdown_val)
								local spell = GetSpellInfo(tonumber(spellID))
								if spell then spell = tonumber(spellID) else spell = spellID end
								for k, v in ipairs(tabsType) do
									if dropdown_val == L[v] then
										dropdown_val = v
									end
								end
								if dropdown_val ~= prio then
									CustomPVEDropDownCompileSpells(spell, dropdown_val, i, c)
									prio = dropdown_val
									prio = L[prio] or prio
									if type(spell) == "number" then
										aString = substring(GetSpellInfo(spellID), 0, 17)..": "..substring(prio, 0, 6) or "SPELL REMOVED: "..spellID
										local cutString = substring(aString, 0, 23);
										if string then spellCheck.text:SetText(cutString.."\n".."("..customname..")".."\n"..string); else spellCheck.text:SetText(cutString.."\n".."Custom Priority") end
										spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
									else
										aString = spellID..": "..prio
										local cutString = substring(aString, 0, 23);
										if string then spellCheck.text:SetText(cutString.."\n".."("..customname..")".."\n"..string); else spellCheck.text:SetText(cutString.."\n".."Custom Priority") end
										spellCheck.icon:SetNormalTexture(136235)
									end
								end
							 end
					}


					local dropdown = createDropdown(drop_opts)
					dropdown:SetPoint("LEFT", spellCheck.text, "RIGHT", -10,0)
					dropdown:SetScale(.55)
					spellCheck.spellID = spellID
					spellCheck.Green.spellID = spellID
					if _G.EasyCCDB.spellDisabled[spellCheck.spellID] then spellCheck:SetChecked(false) else spellCheck:SetChecked(true) end    --Error on 1st ADDON_LOADED
					spellCheck:SetScript("OnClick",
						function()
						 GameTooltip:Hide()
						 if not spellCheck:GetChecked() then _G.EasyCCDB.spellDisabled[spellCheck.spellID] = true else _G.EasyCCDB.spellDisabled[spellCheck.spellID] = nil end
						 makeAndShowSpellTTPVE(spellCheck)
						end
					);
					spellCheck:SetScript("OnEnter", function(self)
							makeAndShowSpellTTPVE(self)
					end)
					spellCheck:SetScript("OnLeave", function(self)
						GameTooltip:Hide()
					end)
					if _G.EasyCCDB.GreenBar[spellCheck.Green.spellID] then spellCheck.Green:SetChecked(true) else spellCheck.Green:SetChecked(false) end
					spellCheck.Green:SetScript("OnClick",
						function()
						 GameTooltip:Hide()
						 if spellCheck.Green:GetChecked() then _G.EasyCCDB.GreenBar[spellCheck.Green.spellID] = true else _G.EasyCCDB.GreenBar[spellCheck.Green.spellID] = nil end
						  makeGreenBar(spellCheck.Green)
						end
					);
					spellCheck.Green:SetScript("OnEnter", function(self)
							 makeGreenBar(self)
					end)
					spellCheck.Green:SetScript("OnLeave", function(self)
						GameTooltip:Hide()
					end)

				end
				previousSpellID = spellID
				spellCount = spellCount + 1
			end
		end
	end
end
