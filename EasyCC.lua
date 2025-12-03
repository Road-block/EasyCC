local addonName, L = ...
local CreateFrame = CreateFrame
local SetTexture = SetTexture
local SetNormalTexture = SetNormalTexture
local SetSwipeTexture = SetSwipeTexture
local SetCooldown = SetCooldown
local SetAlpha, SetPoint, SetParent, SetFrameLevel, SetDrawSwipe, SetSwipeColor, SetScale, SetHeight, SetWidth, SetDesaturated, SetVertexColor =
  SetAlpha,
  SetPoint,
  SetParent,
  SetFrameLevel,
  SetDrawSwipe,
  SetSwipeColor,
  SetScale,
  SetHeight,
  SetWidth,
  SetDesaturated,
  SetVertexColor
local LossOfControlFrame_Show_Orig
local EnableWidget = function(widget)
  if widget and widget.Enable then
    widget:Enable()
  end
end
local DisableWidget = function(widget)
  if widget and widget.Disable then
    widget:Disable()
  end
end
local GetSpellInfo = function(...)
  if C_Spell and C_Spell.GetSpellInfo then
    local info = C_Spell.GetSpellInfo(...)
    if info then
      return info.name,
        nil,
        info.iconID,
        info.castTime,
        info.minRange,
        info.maxRange,
        info.spellID,
        info.originalIconID
    end
  elseif _G.GetSpellInfo then
    return _G.GetSpellInfo(...)
  end
end
local IsAddOnLoaded = function(...)
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    return C_AddOns.IsAddOnLoaded(...)
  elseif _G.IsAddOnLoaded then
    return _G.IsAddOnLoaded(...)
  end
end
local UnitAffectingCombat = UnitAffectingCombat
local BlizzardOptionsPanel_Slider_Enable = _G.BlizzardOptionsPanel_Slider_Enable or EnableWidget
local BlizzardOptionsPanel_Slider_Disable = _G.BlizzardOptionsPanel_Slider_Disable or DisableWidget
local ClearAllPoints = ClearAllPoints
local GetParent = GetParent
local GetFrameLevel = GetFrameLevel
local GetDrawSwipe = GetDrawSwipe
local GetDrawLayer = GetDrawLayer
local GetAlpha = GetAlpha
local tblinsert = table.insert
local strfind = string.find
local strmatch = string.match
local strformat = string.format
local strlen = string.len
local tblinsert = table.insert
local tblremove = table.remove
local mathfloor = math.floor
local mathabs = math.abs
local bit_band = bit.band
local tblsort = table.sort
local Ctimer = C_Timer.After
local substring = string.sub
local su = string.sub
local CLocData = C_LossOfControl.GetActiveLossOfControlData
local UnitIsUnit = UnitIsUnit
local f, x, y
local _G = _G
local EasyCCDB
local hieght = 48
local width = 48
local fadeTime = 2 -- Fade Timer
local DISPLAY_NONE = 0
local pulseLtext, pulsetimer

local spellsTable = {

  {
    "Death Knight",

    { 51209, "CC" }, -- Hungering Cold (talent)
    { 47476, "Silence" }, -- Strangulate
    --{42650    , "Immune"},      -- Army of the Dead (not immune, the Death Knight takes less damage equal to his Dodge plus Parry chance)
    --{48707    , "Immune"},    -- Anti-Magic Shell
    --{50461    , "Immune"},    -- Anti-Magic Zone (talent)
    --{48792    , "Other"},       -- Icebound Fortitude
    --{51271    , "Other"},       -- Unbreakable Armor (talent)
    --{49039    , "Other"},       -- Lichborne (talent)
    --{49796    , "Other"},       -- Deathchill (talent)
    --{49016    , "Other"},       -- Unholy Frenzy (talent)
    --{49028    , "Other"},       -- Dancing Rune Weapon (talent)
    { 45524, "Snare" }, -- Chains of Ice
    { 58617, "Snare" }, -- Glyph of Heart Strike
    { 68766, "Snare" }, -- Desecration (talent)
    { 50436, "Snare" }, -- Icy Clutch (talent)

    ----------------
    -- Death Knight Ghoul
    ----------------
    --{47484    , "Immune"},      -- Huddle (not immune, damage taken reduced 50%) (Turtle)
    { 47481, "CC" }, -- Gnaw
  },

  {
    "Hunter", --TAB
    { 1513, "CC" }, -- Scare Beast (rank 1)
    { 14326, "CC" }, -- Scare Beast (rank 2)
    { 14327, "CC" }, -- Scare Beast (rank 3)
    { 3355, "CC" }, -- Freezing Trap (rank 1)
    { 14308, "CC" }, -- Freezing Trap (rank 2)
    { 14309, "CC" }, -- Freezing Trap (rank 3)
    { 60210, "CC" }, -- Freezing Arrow Effect
    { 19386, "CC" }, -- Wyvern Sting (talent) (rank 1)
    { 24132, "CC" }, -- Wyvern Sting (talent) (rank 2)
    { 24133, "CC" }, -- Wyvern Sting (talent) (rank 3)
    { 27068, "CC" }, -- Wyvern Sting (talent) (rank 4)
    { 49011, "CC" }, -- Wyvern Sting (talent) (rank 5)
    { 49012, "CC" }, -- Wyvern Sting (talent) (rank 6)
    { 19503, "CC" }, -- Scatter Shot (talent)
    { 34490, "Silence" }, -- Silencing Shot
    { 19306, "Root" }, -- Counterattack (talent) (rank 1)
    { 20909, "Root" }, -- Counterattack (talent) (rank 2)
    { 20910, "Root" }, -- Counterattack (talent) (rank 3)
    { 27067, "Root" }, -- Counterattack (talent) (rank 4)
    { 48998, "Root" }, -- Counterattack (talent) (rank 5)
    { 48999, "Root" }, -- Counterattack (talent) (rank 6)
    { 19185, "Root" }, -- Entrapment (talent) (rank 1)
    { 64803, "Root" }, -- Entrapment (talent) (rank 2)
    { 64804, "Root" }, -- Entrapment (talent) (rank 3)
    { 53359, "Disarm" }, -- Chimera Shot - Scorpid (talent)
    { 2974, "Snare" }, -- Wing Clip
    { 5116, "Snare" }, -- Concussive Shot
    { 15571, "Snare" }, -- Dazed (Aspect of the Cheetah and Aspect of the Pack)
    { 13809, "Snare" }, -- Frost Trap
    { 13810, "Snare" }, -- Frost Trap Aura
    { 35101, "Snare" }, -- Concussive Barrage (talent)
    --{19263    , "Immune"},      -- Deterrence (not immune, parry chance increased by 100% and grants a 100% chance to deflect spells)
    --{19574    , "Immune"},    -- Bestial Wrath (talent) (not immuune to spells, only immune to some CC's)
    --{34471    , "Immune"},    -- The Beast Within (talent) (not immuune to spells, only immune to some CC's)
    --{5384     , "Other"},       -- Feign Death
    --{19434    , "Other"},       -- Aimed Shot (rank 1) (healing effects reduced by 50%)
    --{20900    , "Other"},       -- Aimed Shot (rank 2) (healing effects reduced by 50%)
    --{20901    , "Other"},       -- Aimed Shot (rank 3) (healing effects reduced by 50%)
    --{20902    , "Other"},       -- Aimed Shot (rank 4) (healing effects reduced by 50%)
    --{20903    , "Other"},       -- Aimed Shot (rank 5) (healing effects reduced by 50%)
    --{20904    , "Other"},       -- Aimed Shot (rank 6) (healing effects reduced by 50%)
    --{27065    , "Other"},       -- Aimed Shot (rank 7) (healing effects reduced by 50%)
    --{49049    , "Other"},       -- Aimed Shot (rank 8) (healing effects reduced by 50%)
    --{49050    , "Other"},       -- Aimed Shot (rank 9) (healing effects reduced by 50%)
    { 4167, "Root" }, -- Web (rank 1) (Spider)
    { 4168, "Root" }, -- Web II
    { 4169, "Root" }, -- Web III
    { 54706, "Root" }, -- Venom Web Spray (rank 1) (Silithid)
    { 55505, "Root" }, -- Venom Web Spray (rank 2) (Silithid)
    { 55506, "Root" }, -- Venom Web Spray (rank 3) (Silithid)
    { 55507, "Root" }, -- Venom Web Spray (rank 4) (Silithid)
    { 55508, "Root" }, -- Venom Web Spray (rank 5) (Silithid)
    { 55509, "Root" }, -- Venom Web Spray (rank 6) (Silithid)
    { 50245, "Root" }, -- Pin (rank 1) (Crab)
    { 53544, "Root" }, -- Pin (rank 2) (Crab)
    { 53545, "Root" }, -- Pin (rank 3) (Crab)
    { 53546, "Root" }, -- Pin (rank 4) (Crab)
    { 53547, "Root" }, -- Pin (rank 5) (Crab)
    { 53548, "Root" }, -- Pin (rank 6) (Crab)
    { 53148, "Root" }, -- Charge (Bear and Carrion Bird)
    { 25999, "Root" }, -- Boar Charge (Boar)
    { 24394, "CC" }, -- Intimidation (talent)
    { 50519, "CC" }, -- Sonic Blast (rank 1) (Bat)
    { 53564, "CC" }, -- Sonic Blast (rank 2) (Bat)
    { 53565, "CC" }, -- Sonic Blast (rank 3) (Bat)
    { 53566, "CC" }, -- Sonic Blast (rank 4) (Bat)
    { 53567, "CC" }, -- Sonic Blast (rank 5) (Bat)
    { 53568, "CC" }, -- Sonic Blast (rank 6) (Bat)
    { 50518, "CC" }, -- Ravage (rank 1) (Ravager)
    { 53558, "CC" }, -- Ravage (rank 2) (Ravager)
    { 53559, "CC" }, -- Ravage (rank 3) (Ravager)
    { 53560, "CC" }, -- Ravage (rank 4) (Ravager)
    { 53561, "CC" }, -- Ravage (rank 5) (Ravager)
    { 53562, "CC" }, -- Ravage (rank 6) (Ravager)
    { 54404, "CC" }, -- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
    { 50541, "Disarm" }, -- Snatch (rank 1) (Bird of Prey)
    { 53537, "Disarm" }, -- Snatch (rank 2) (Bird of Prey)
    { 53538, "Disarm" }, -- Snatch (rank 3) (Bird of Prey)
    { 53540, "Disarm" }, -- Snatch (rank 4) (Bird of Prey)
    { 53542, "Disarm" }, -- Snatch (rank 5) (Bird of Prey)
    { 53543, "Disarm" }, -- Snatch (rank 6) (Bird of Prey)
    --{1742     , "Immune"},      -- Cower (not immune, damage taken reduced 40%)
    --{26064    , "Immune"},      -- Shell Shield (not immune, damage taken reduced 50%) (Turtle)
    { 50271, "Snare" }, -- Tendon Rip (rank 1) (Hyena)
    { 53571, "Snare" }, -- Tendon Rip (rank 2) (Hyena)
    { 53572, "Snare" }, -- Tendon Rip (rank 3) (Hyena)
    { 53573, "Snare" }, -- Tendon Rip (rank 4) (Hyena)
    { 53574, "Snare" }, -- Tendon Rip (rank 5) (Hyena)
    { 53575, "Snare" }, -- Tendon Rip (rank 6) (Hyena)
    { 54644, "Snare" }, -- Froststorm Breath (rank 1) (Chimaera)
    { 55488, "Snare" }, -- Froststorm Breath (rank 2) (Chimaera)
    { 55489, "Snare" }, -- Froststorm Breath (rank 3) (Chimaera)
    { 55490, "Snare" }, -- Froststorm Breath (rank 4) (Chimaera)
    { 55491, "Snare" }, -- Froststorm Breath (rank 5) (Chimaera)
    { 55492, "Snare" }, -- Froststorm Breath (rank 6) (Chimaera)
  },
  {
    "Shaman",
    { 39796, "CC" }, -- Stoneclaw Stun (Stoneclaw Totem)
    { 51514, "CC" }, -- Hex
    { 58861, "CC" }, -- Bash (Spirit Wolf)
    --{8178     , "Immune"},    -- Grounding Totem Effect (Grounding Totem)
    { 64695, "Root" }, -- Earthgrab (Storm, Earth and Fire talent)
    { 63685, "Root" }, -- Freeze (Frozen Power talent)
    { 8056, "Snare" }, -- Frost Shock (rank 1)
    { 8058, "Snare" }, -- Frost Shock (rank 2)
    { 10472, "Snare" }, -- Frost Shock (rank 3)
    { 10473, "Snare" }, -- Frost Shock (rank 4)
    { 25464, "Snare" }, -- Frost Shock (rank 5)
    { 49235, "Snare" }, -- Frost Shock (rank 6)
    { 49236, "Snare" }, -- Frost Shock (rank 7)
    { 8034, "Snare" }, -- Frostbrand Attack (rank 1)
    { 8037, "Snare" }, -- Frostbrand Attack (rank 2)
    { 10458, "Snare" }, -- Frostbrand Attack (rank 3)
    { 16352, "Snare" }, -- Frostbrand Attack (rank 4)
    { 16353, "Snare" }, -- Frostbrand Attack (rank 5)
    { 25501, "Snare" }, -- Frostbrand Attack (rank 6)
    { 58797, "Snare" }, -- Frostbrand Attack (rank 7)
    { 58798, "Snare" }, -- Frostbrand Attack (rank 8)
    { 58799, "Snare" }, -- Frostbrand Attack (rank 9)
    { 64186, "Snare" }, -- Frostbrand Attack (rank 9)
    { 3600, "Snare" }, -- Earthbind (Earthbind Totem)
    --{16166    , "Other"},       -- Elemental Mastery (talent)
    --{16188    , "Other"},       -- Nature's Swiftness (talent)
    --{30823    , "Other"},       -- Shamanistic Rage (talent) (damage taken reduced by 30%)
  },
  {
    "Druid",
    { 339, "Root" }, -- Entangling Roots (rank 1)
    { 1062, "Root" }, -- Entangling Roots (rank 2)
    { 5195, "Root" }, -- Entangling Roots (rank 3)
    { 5196, "Root" }, -- Entangling Roots (rank 4)
    { 9852, "Root" }, -- Entangling Roots (rank 5)
    { 9853, "Root" }, -- Entangling Roots (rank 6)
    { 26989, "Root" }, -- Entangling Roots (rank 7)
    { 53308, "Root" }, -- Entangling Roots (rank 8)
    { 9005, "CC" }, -- Pounce (rank 1)
    { 9823, "CC" }, -- Pounce (rank 2)
    { 9827, "CC" }, -- Pounce (rank 3)
    { 27006, "CC" }, -- Pounce (rank 4)
    { 49803, "CC" }, -- Pounce (rank 5)
    { 5211, "CC" }, -- Bash (rank 1)
    { 6798, "CC" }, -- Bash (rank 2)
    { 8983, "CC" }, -- Bash (rank 3)
    { 2637, "CC" }, -- Hibernate (rank 1)
    { 18657, "CC" }, -- Hibernate (rank 2)
    { 18658, "CC" }, -- Hibernate (rank 3)
    { 33786, "CC" }, -- Cyclone
    { 19975, "Root" }, -- Entangling Roots (rank 1) (Nature's Grasp spell)
    { 19974, "Root" }, -- Entangling Roots (rank 2) (Nature's Grasp spell)
    { 19973, "Root" }, -- Entangling Roots (rank 3) (Nature's Grasp spell)
    { 19972, "Root" }, -- Entangling Roots (rank 4) (Nature's Grasp spell)
    { 19971, "Root" }, -- Entangling Roots (rank 5) (Nature's Grasp spell)
    { 19970, "Root" }, -- Entangling Roots (rank 6) (Nature's Grasp spell)
    { 27010, "Root" }, -- Entangling Roots (rank 7) (Nature's Grasp spell)
    { 53313, "Root" }, -- Entangling Roots (rank 8) (Nature's Grasp spell)
    { 22570, "CC" }, -- Maim (rank 1)
    { 49802, "CC" }, -- Maim (rank 2)
    { 19675, "Root" }, -- Feral Charge Effect (Feral Charge talent)
    { 45334, "Root" }, -- Feral Charge Effect (Feral Charge talent)
    --[[{17116    , "Other"},       -- Nature's Swiftness (talent)
{16689    , "Other"},       -- Nature's Grasp (rank 1)
{16810    , "Other"},       -- Nature's Grasp (rank 2)
{16811    , "Other"},       -- Nature's Grasp (rank 3)
{16812    , "Other"},       -- Nature's Grasp (rank 4)
{16813    , "Other"},       -- Nature's Grasp (rank 5)
{17329    , "Other"},       -- Nature's Grasp (rank 6)
{27009    , "Other"},       -- Nature's Grasp (rank 7)
{53312    , "Other"},       -- Nature's Grasp (rank 8)
{22812    , "Other"},       -- Barkskin
{29166    , "Other"},       -- Innervate
{48505    , "Other"},       -- Starfall (talent) (rank 1)
{53199    , "Other"},       -- Starfall (talent) (rank 2)
{53200    , "Other"},       -- Starfall (talent) (rank 3)
{53201    , "Other"},       -- Starfall (talent) (rank 4)
{50334    , "Other"},       -- Berserk (talent)
{69369    , "Other"},       -- Predator's Swiftness (talent)]]
    { 50259, "Snare" }, -- Dazed
    { 58181, "Snare" }, -- Infected Wounds) (talent) (rank 3
    { 61391, "Snare" }, -- Typhoon (talent) (rank 1)
    { 61390, "Snare" }, -- Typhoon (talent) (rank 2)
    { 61388, "Snare" }, -- Typhoon (talent) (rank 3)
    { 61387, "Snare" }, -- Typhoon (talent) (rank 4)
    { 53227, "Snare" }, -- Typhoon (talent) (rank 5)
  },
  {
    "Mage",
    { 118, "CC" }, -- Polymorph (rank 1)
    { 12824, "CC" }, -- Polymorph (rank 2)
    { 12825, "CC" }, -- Polymorph (rank 3)
    { 12826, "CC" }, -- Polymorph (rank 4)
    { 28271, "CC" }, -- Polymorph: Turtle
    { 28272, "CC" }, -- Polymorph: Pig
    { 61305, "CC" }, -- Polymorph: Black Cat
    { 61721, "CC" }, -- Polymorph: Rabbit
    { 61780, "CC" }, -- Polymorph: Turkey
    { 71319, "CC" }, -- Polymorph: Turkey
    { 61025, "CC" }, -- Polymorph: Serpent
    { 59634, "CC" }, -- Polymorph - Penguin (Glyph)
    { 12355, "CC" }, -- Impact (talent)
    { 31661, "CC" }, -- Dragon's Breath (rank 1) (talent)
    { 33041, "CC" }, -- Dragon's Breath (rank 2) (talent)
    { 33042, "CC" }, -- Dragon's Breath (rank 3) (talent)
    { 33043, "CC" }, -- Dragon's Breath (rank 4) (talent)
    { 42949, "CC" }, -- Dragon's Breath (rank 5) (talent)
    { 42950, "CC" }, -- Dragon's Breath (rank 6) (talent)
    { 44572, "CC" }, -- Deep Freeze (talent)
    { 64346, "Disarm" }, -- Fiery Payback (talent)
    { 18469, "Silence" }, -- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
    { 55021, "Silence" }, -- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
    --{45438    , "Immune"},      -- Ice Block
    { 122, "Root" }, -- Frost Nova (rank 1)
    { 865, "Root" }, -- Frost Nova (rank 2)
    { 6131, "Root" }, -- Frost Nova (rank 3)
    { 10230, "Root" }, -- Frost Nova (rank 4)
    { 27088, "Root" }, -- Frost Nova (rank 5)
    { 42917, "Root" }, -- Frost Nova (rank 6)
    { 12494, "Root" }, -- Frostbite (talent)
    { 55080, "Root" }, -- Shattered Barrier (talent)
    { 12484, "Snare" }, -- Chilled (rank 1) (Improved Blizzard talent)
    { 12485, "Snare" }, -- Chilled (rank 2) (Improved Blizzard talent)
    { 12486, "Snare" }, -- Chilled (rank 3) (Improved Blizzard talent)
    { 120, "Snare" }, -- Cone of Cold (rank 1)
    { 8492, "Snare" }, -- Cone of Cold (rank 2)
    { 10159, "Snare" }, -- Cone of Cold (rank 3)
    { 10160, "Snare" }, -- Cone of Cold (rank 4)
    { 10161, "Snare" }, -- Cone of Cold (rank 5)
    { 27087, "Snare" }, -- Cone of Cold (rank 6)
    { 42930, "Snare" }, -- Cone of Cold (rank 7)
    { 42931, "Snare" }, -- Cone of Cold (rank 8)
    { 116, "Snare" }, -- Frostbolt (rank 1)
    { 205, "Snare" }, -- Frostbolt (rank 2)
    { 837, "Snare" }, -- Frostbolt (rank 3)
    { 7322, "Snare" }, -- Frostbolt (rank 4)
    { 8406, "Snare" }, -- Frostbolt (rank 5)
    { 8407, "Snare" }, -- Frostbolt (rank 6)
    { 8408, "Snare" }, -- Frostbolt (rank 7)
    { 10179, "Snare" }, -- Frostbolt (rank 8)
    { 10180, "Snare" }, -- Frostbolt (rank 9)
    { 10181, "Snare" }, -- Frostbolt (rank 10)
    { 25304, "Snare" }, -- Frostbolt (rank 11)
    { 27071, "Snare" }, -- Frostbolt (rank 12)
    { 27072, "Snare" }, -- Frostbolt (rank 13)
    { 38697, "Snare" }, -- Frostbolt (rank 14)
    { 42841, "Snare" }, -- Frostbolt (rank 15)
    { 42842, "Snare" }, -- Frostbolt (rank 16)
    { 59638, "Snare" }, -- Frostbolt (Mirror Images)
    { 44614, "Snare" }, -- Frostfire Bolt (rank 1)
    { 47610, "Snare" }, -- Frostfire Bolt (rank 2)
    --{6136     , "Snare"},       -- Chilled (Frost Armor)
    --{7321     , "Snare"},       -- Chilled (Ice Armor)
    { 11113, "Snare" }, -- Blast Wave (talent) (rank 1)
    { 13018, "Snare" }, -- Blast Wave (talent) (rank 2)
    { 13019, "Snare" }, -- Blast Wave (talent) (rank 3)
    { 13020, "Snare" }, -- Blast Wave (talent) (rank 4)
    { 13021, "Snare" }, -- Blast Wave (talent) (rank 5)
    { 27133, "Snare" }, -- Blast Wave (talent) (rank 6)
    { 33933, "Snare" }, -- Blast Wave (talent) (rank 7)
    { 42944, "Snare" }, -- Blast Wave (talent) (rank 8)
    { 42945, "Snare" }, -- Blast Wave (talent) (rank 9)
    --[[{31589    , "Snare"},       -- Slow (talent)
{12043    , "Other"},       -- Presence of Mind (talent)
{12042    , "Other"},       -- Arcane Power (talent)
{12472    , "Other"},       -- Icy Veins (talent)]]

    ----------------
    -- Mage Water Elemental
    ----------------
    { 33395, "Root" }, -- Freeze
  },
  {
    "Paladin",
    --{642      , "Immune"},      -- Divine Shield
    --{498      , "Immune"},      -- Divine Protection (not immune, damage taken reduced by 50%)
    --{19753    , "Immune"},      -- Divine Intervention
    --{1022     , "Immune"},  -- Hand of Protection (rank 1)
    --{5599     , "Immune"},  -- Hand of Protection (rank 2)
    --{10278    , "Immune"},  -- Hand of Protection (rank 3)
    { 853, "CC" }, -- Hammer of Justice (rank 1)
    { 5588, "CC" }, -- Hammer of Justice (rank 2)
    { 5589, "CC" }, -- Hammer of Justice (rank 3)
    { 10308, "CC" }, -- Hammer of Justice (rank 4)
    { 2812, "CC" }, -- Holy Wrath (rank 1)
    { 10318, "CC" }, -- Holy Wrath (rank 2)
    { 27139, "CC" }, -- Holy Wrath (rank 3)
    { 48816, "CC" }, -- Holy Wrath (rank 4)
    { 48817, "CC" }, -- Holy Wrath (rank 5)
    { 20170, "CC" }, -- Stun (Seal of Justice)
    { 10326, "CC" }, -- Turn Evil
    { 20066, "CC" }, -- Repentance (talent)
    { 63529, "Silence" }, -- Silenced - Shield of the Templar (talent)
    --{1044     , "Other"},       -- Blessing of Freedom
    --{20216    , "Other"},       -- Divine Favor (talent)
    --{31821    , "Other"},       -- Aura Mastery (talent)
    { 31935, "Snare" }, -- Avenger's Shield (rank 1) (talent)
    { 32699, "Snare" }, -- Avenger's Shield (rank 2) (talent)
    { 32700, "Snare" }, -- Avenger's Shield (rank 3) (talent)
    { 48826, "Snare" }, -- Avenger's Shield (rank 4) (talent)
    { 48827, "Snare" }, -- Avenger's Shield (rank 5) (talent)
    --[[{31884    , "Other"},       -- Avenging Wrath
{31842    , "Other"}, ]]
    -- Divine Illumination (talent)
  },
  {
    "Priest",
    { 15487, "Silence" }, -- Silence (talent)
    --{10060    , "Other"},       -- Power Infusion (talent)
    --{6346     , "Other"},       -- Fear Ward
    { 605, "CC" }, -- Mind Control
    { 8122, "CC" }, -- Psychic Scream (rank 1)
    { 8124, "CC" }, -- Psychic Scream (rank 2)
    { 10888, "CC" }, -- Psychic Scream (rank 3)
    { 10890, "CC" }, -- Psychic Scream (rank 4)
    { 9484, "CC" }, -- Shackle Undead (rank 1)
    { 9485, "CC" }, -- Shackle Undead (rank 2)
    { 10955, "CC" }, -- Shackle Undead (rank 3)
    { 64044, "CC" }, -- Psychic Horror (talent)
    { 64058, "Disarm" }, -- Psychic Horror (talent)
    --{27827    , "Immune"},      -- Spirit of Redemption
    --{33206    , "Immune"},      -- Pain Suppression (not immune, damage taken reduced by 40%)
    --{47585    , "Immune"},      -- Dispersion (talent) (not immune, damage taken reduced by 90%)
    --{47788    , "Other"},       -- Guardian Spirit (talent) (prevent the target from dying)
    --{14751    , "Other"},       -- Inner Focus
    { 15407, "Snare" }, -- Mind Flay (talent) (rank 1)
    { 17311, "Snare" }, -- Mind Flay (talent) (rank 2)
    { 17312, "Snare" }, -- Mind Flay (talent) (rank 3)
    { 17313, "Snare" }, -- Mind Flay (talent) (rank 4)
    { 17314, "Snare" }, -- Mind Flay (talent) (rank 5)
    { 18807, "Snare" }, -- Mind Flay (talent) (rank 6)
    { 25387, "Snare" }, -- Mind Flay (talent) (rank 7)
    { 48155, "Snare" }, -- Mind Flay (talent) (rank 8)
    { 48156, "Snare" }, -- Mind Flay (talent) (rank 9)
  },
  {
    "Rogue",
    { 2094, "CC" }, -- Blind
    { 408, "CC" }, -- Kidney Shot (rank 1)
    { 8643, "CC" }, -- Kidney Shot (rank 2)
    { 1833, "CC" }, -- Cheap Shot
    { 6770, "CC" }, -- Sap (rank 1)
    { 2070, "CC" }, -- Sap (rank 2)
    { 11297, "CC" }, -- Sap (rank 3)
    { 51724, "CC" }, -- Sap (rank 4)
    { 1776, "CC" }, -- Gouge
    { 1330, "Silence" }, -- Garrote - Silence
    { 51722, "Disarm" }, -- Dismantle
    { 18425, "Silence" }, -- Kick - Silenced (talent)
    { 3409, "Snare" }, -- Crippling Poison
    { 26679, "Snare" }, -- Deadly Throw (rank 1)
    { 48673, "Snare" }, -- Deadly Throw (rank 2)
    { 48674, "Snare" }, -- Deadly Throw (rank 3)
    { 31125, "Snare" }, -- Dazed (Blade Twisting) (rank 1) (talent)
    { 51585, "Snare" }, -- Dazed (Blade Twisting) (rank 2) (talent)
    { 51693, "Snare" }, -- Waylay (talent)
    --{5277     , "Immune"},  -- Evasion (dodge chance increased 50%)
    --{26669    , "Immune"},  -- Evasion (dodge chance increased 50%)
    --{31224    , "Immune"},    -- Cloak of Shadows
    --{45182    , "Immune"},      -- Cheating Death (talent) (damage taken reduced by 90%)
    --{14177    , "Other"},       -- Cold Blood (talent)
    --{13877    , "Other"},       -- Blade Flurry (talent)
    --{13750    , "Other"},       -- Adrenaline Rush (talent)
    --{51690    , "Other"},       -- Killing Spree (talent)
    --{51713    , "Other"},       -- Shadow Dance (talent)
    --{13218    , "Other"},       -- Wound Poison (rank 1) (healing effects reduced by 50%)
    --{13222    , "Other"},       -- Wound Poison II (rank 2) (healing effects reduced by 50%)
    --{13223    , "Other"},       -- Wound Poison III (rank 3) (healing effects reduced by 50%)
    --{13224    , "Other"},       -- Wound Poison IV (rank 4) (healing effects reduced by 50%)
    --{27189    , "Other"},       -- Wound Poison V (rank 5) (healing effects reduced by 50%)
    --{57974    , "Other"},       -- Wound Poison VI (rank 6) (healing effects reduced by 50%)
    --{57975    , "Other"},       -- Wound Poison VII (rank 7) (healing effects reduced by 50%)
  },
  {
    "Warlock",
    { 710, "CC" }, -- Banish (rank 1)
    { 18647, "CC" }, -- Banish (rank 2)
    { 5782, "CC" }, -- Fear (rank 1)
    { 6213, "CC" }, -- Fear (rank 2)
    { 6215, "CC" }, -- Fear (rank 3)
    { 5484, "CC" }, -- Howl of Terror (rank 1)
    { 17928, "CC" }, -- Howl of Terror (rank 2)
    { 6789, "CC" }, -- Death Coil (rank 1)
    { 17925, "CC" }, -- Death Coil (rank 2)
    { 17926, "CC" }, -- Death Coil (rank 3)
    { 27223, "CC" }, -- Death Coil (rank 4)
    { 47859, "CC" }, -- Death Coil (rank 5)
    { 47860, "CC" }, -- Death Coil (rank 6)
    { 22703, "CC" }, -- Inferno Effect
    { 30283, "CC" }, -- Shadowfury (rank 1) (talent)
    { 30413, "CC" }, -- Shadowfury (rank 2) (talent)
    { 30414, "CC" }, -- Shadowfury (rank 3) (talent)
    { 47846, "CC" }, -- Shadowfury (rank 4) (talent)
    { 47847, "CC" }, -- Shadowfury (rank 5) (talent)
    { 60995, "CC" }, -- Demon Charge (metamorphosis talent)
    { 54786, "CC" }, -- Demon Leap (metamorphosis talent)
    { 31117, "Silence" }, -- Unstable Affliction
    --{18708    , "Other"},       -- Fel Domination (talent)
    { 18223, "Snare" }, -- Curse of Exhaustion (talent)
    { 18118, "Snare" }, -- Aftermath (talent)
    { 63311, "Snare" }, -- Glyph of Shadowflame

    ----------------
    -- Warlock Pets
    ----------------
    { 32752, "CC" }, -- Summoning Disorientation
    { 24259, "Silence" }, -- Spell Lock (Felhunter)
    { 6358, "CC" }, -- Seduction (Succubus)
    --  {4511     , "Immune"},    -- Phase Shift (Imp)
    { 19482, "CC" }, -- War Stomp (Doomguard)
    { 89, "Snare" }, -- Cripple (Doomguard)
    { 30153, "CC" }, -- Intercept Stun (rank 1) (Felguard)
    { 30195, "CC" }, -- Intercept Stun (rank 2) (Felguard)
    { 30197, "CC" }, -- Intercept Stun (rank 3) (Felguard)
    { 47995, "CC" }, -- Intercept Stun (rank 4) (Felguard)
  },
  {
    "Warrior",
    { 7922, "CC" }, -- Charge (rank 1/2/3)
    { 20253, "CC" }, -- Intercept
    { 5246, "CC" }, -- Intimidating Shout
    { 20511, "CC" }, -- Intimidating Shout
    { 12809, "CC" }, -- Concussion Blow (talent)
    { 46968, "CC" }, -- Shockwave (talent)
    --{46924    , "Immune"},      -- Bladestorm (talent) (not immune to dmg, only to LoC)
    { 676, "Disarm" }, -- Disarm
    --{871      , "Immune"},      -- Shield Wall (not immune, 60%/40% damage reduction)
    --{23920    , "Immune"},    -- Spell Reflection
    --{59725    , "Immune"},    -- Spell Reflection (Improved Spell Reflection talent)
    { 23694, "Root" }, -- Improved Hwamstring (talent)
    { 74347, "Silence" }, -- Silenced - Gag Order (Improved Shield Bash talent)
    { 18498, "Silence" }, -- Silenced - Gag Order (Improved Shield Bash talent)
    { 29703, "Snare" }, -- Dazed (Shield Bash)
    { 1715, "Snare" }, -- Hamstring
    { 58373, "Root" }, -- Glyph of Hamstring
    { 12323, "Snare" }, -- Piercing Howl (talent)
    --{3411     , "Other"},       -- Intervene
    --{2565     , "Immune"},  -- Shield Block (not immune, block chance and block value increased by 100%)
    --{12292    , "Other"},       -- Death Wish (talent)
    --{12976    , "Other"},       -- Last Stand (talent)
    --{20230    , "Other"},       -- Retaliation
    --{18499    , "Other"},       -- Berserker Rage
    --{1719     , "Other"},       -- Recklessness
    --{12294    , "Other"},       -- Mortal Strike (rank 1) (healing effects reduced by 50%)
    --{21551    , "Other"},       -- Mortal Strike (rank 2) (healing effects reduced by 50%)
    --{21552    , "Other"},       -- Mortal Strike (rank 3) (healing effects reduced by 50%)
    --{21553    , "Other"},       -- Mortal Strike (rank 4) (healing effects reduced by 50%)
    --{25248    , "Other"},       -- Mortal Strike (rank 5) (healing effects reduced by 50%)
    --{30330    , "Other"},       -- Mortal Strike (rank 6) (healing effects reduced by 50%)
    --{47485    , "Other"},       -- Mortal Strike (rank 7) (healing effects reduced by 50%)
    --{47486    , "Other"},       -- Mortal Strike (rank 8) (healing effects reduced by 50%)
  },
  {
    "Racials",
    { 20549, "CC" }, -- War Stomp (tauren racial)

    { 25046, "Silence" }, -- Arcane Torrent (blood elf racial)
    { 28730, "Silence" }, -- Arcane Torrent (blood elf racial)
  },
  --[[{"Interrupts",
{72     ,"Interrupt"}, --6,   -- Shield Bash (Warrior)
{1766   ,"Interrupt"}, --5,   -- Kick (Rogue)
{2139   ,"Interrupt"}, --8,   -- Counterspell (Mage)
{6552   ,"Interrupt"}, --4,   -- Pummel (Warrior)
{57994  ,"Interrupt"}, --2,   -- Wind Shear (Shaman)
{47528  ,"Interrupt"}, --4,   -- Mind Freeze (Death Knight)
{13491  ,"Interrupt"}, --5,   -- Pummel (Iron Knuckles Item)
{19244  ,"Interrupt"}, --5,   -- Spell Lock (felhunter) (rank 1) (Warlock)
{19647  ,"Interrupt"}, --6,   -- Spell Lock (felhunter) (rank 2) (Warlock)
{26090  ,"Interrupt"}, --2,   -- Pummel (gorilla) (Hunter)
{19675  ,"Interrupt"}, --4,   -- Feral Charge (Druid)
{51680  ,"Interrupt"}, --3,   -- Throwing Specialization (Rogue)
{29443  ,"Interrupt"}, --10,    -- Counterspell (Clutch of Foresight)
-- NPC Interrupts
{1767   ,"Interrupt"}, --5,   -- Kick (rank 2) (Rogue)
{1768   ,"Interrupt"}, --5,   -- Kick (rank 3) (Rogue)
{1769   ,"Interrupt"}, --5,   -- Kick (rank 4) (Rogue)
{38768  ,"Interrupt"}, --5,   -- Kick (rank 5) (Rogue)
{6554   ,"Interrupt"}, --4,   -- Pummel (rank 2) (Warrior)
{1671   ,"Interrupt"}, --6,   -- Shield Bash (rank 2) (Warrior)
{1672   ,"Interrupt"}, --6,   -- Shield Bash (rank 3) (Warrior)
{29704  ,"Interrupt"}, --6,   -- Shield Bash (rank 4) (Warrior)
{2676   ,"Interrupt"}, --2,   -- Pulverize
{5133   ,"Interrupt"}, --30,    -- Interrupt (PT)
{8714   ,"Interrupt"}, --5,   -- Overwhelming Musk
{10887  ,"Interrupt"}, --5,   -- Crowd Pummel
{11972  ,"Interrupt"}, --8,   -- Shield Bash
{11978  ,"Interrupt"}, --6,   -- Kick
{12555  ,"Interrupt"}, --5,   -- Pummel
{13281  ,"Interrupt"}, --2,   -- Earth Shock
{13728  ,"Interrupt"}, --2,   -- Earth Shock
{15122  ,"Interrupt"}, --15,    -- Counterspell
{15501  ,"Interrupt"}, --2,   -- Earth Shock
{15610  ,"Interrupt"}, --6,   -- Kick
{15614  ,"Interrupt"}, --6,   -- Kick
{15615  ,"Interrupt"}, --5,   -- Pummel
{19129  ,"Interrupt"}, --2,   -- Massive Tremor
{19639  ,"Interrupt"}, --5,   -- Pummel
{19715  ,"Interrupt"}, --10,    -- Counterspell
{20537  ,"Interrupt"}, --15,    -- Counterspell
{20788  ,"Interrupt"}, --0.001, -- Counterspell
{21832  ,"Interrupt"}, --10,    -- Boulder
{22885  ,"Interrupt"}, --2,   -- Earth Shock
{23114  ,"Interrupt"}, --2,   -- Earth Shock
{24685  ,"Interrupt"}, --4,   -- Earth Shock
{25025  ,"Interrupt"}, --2,   -- Earth Shock
{25788  ,"Interrupt"}, --5,   -- Head Butt
{26194  ,"Interrupt"}, --2,   -- Earth Shock
{27613  ,"Interrupt"}, --4,   -- Kick
{27620  ,"Interrupt"}, --4,   -- Snap Kick
{27814  ,"Interrupt"}, --6,   -- Kick
{27880  ,"Interrupt"}, --3,   -- Stun
{29298  ,"Interrupt"}, --4,   -- Dark Shriek
{29560  ,"Interrupt"}, --2,   -- Kick
{29586  ,"Interrupt"}, --5,   -- Kick
{29961  ,"Interrupt"}, --10,    -- Counterspell
{30849  ,"Interrupt"}, --4,   -- Spell Lock
{31596  ,"Interrupt"}, --6,   -- Counterspell
{31999  ,"Interrupt"}, --15,    -- Counterspell
{32322  ,"Interrupt"}, --4,   -- Dark Shriek
{32691  ,"Interrupt"}, --6,   -- Spell Shock
{32747  ,"Interrupt"}, --3,   -- Interrupt
{32846  ,"Interrupt"}, --4,   -- Counter Kick
{32938  ,"Interrupt"}, --4,   -- Cry of the Dead
{33871  ,"Interrupt"}, --8,   -- Shield Bash
{34797  ,"Interrupt"}, --6,   -- Nature Shock
{34802  ,"Interrupt"}, --6,   -- Kick
{35039  ,"Interrupt"}, --10,    -- Countercharge
{35178  ,"Interrupt"}, --6,   -- Shield Bash
{35856  ,"Interrupt"}, --3,   -- Stun
{35920  ,"Interrupt"}, --2,   -- Electroshock
{36033  ,"Interrupt"}, --6,   -- Kick
{36138  ,"Interrupt"}, --3,   -- Hammer Stun
{36254  ,"Interrupt"}, --3,   -- Judgement of the Flame
{36841  ,"Interrupt"}, --3,   -- Sonic Boom
{36988  ,"Interrupt"}, --8,   -- Shield Bash
{37359  ,"Interrupt"}, --5,   -- Rush
{37470  ,"Interrupt"}, --3,   -- Counterspell
{38052  ,"Interrupt"}, --3,   -- Sonic Boom
{38233  ,"Interrupt"}, --8,   -- Shield Bash
{38313  ,"Interrupt"}, --5,   -- Pummel
{38625  ,"Interrupt"}, --6,   -- Kick
{38750  ,"Interrupt"}, --4,   -- War Stomp
{38897  ,"Interrupt"}, --4,   -- Sonic Boom
{39076  ,"Interrupt"}, --6,   -- Spell Shock
{39120  ,"Interrupt"}, --6,   -- Nature Shock
{40305  ,"Interrupt"}, --1,   -- Power Burn
{40547  ,"Interrupt"}, --1,   -- Interrupt Unholy Growth
{40751  ,"Interrupt"}, --3,   -- Disrupt Magic
{40864  ,"Interrupt"}, --3,   -- Throbbing Stun
{41180  ,"Interrupt"}, --3,   -- Shield Bash
{41197  ,"Interrupt"}, --3,   -- Shield Bash
{41395  ,"Interrupt"}, --5,   -- Kick
{43305  ,"Interrupt"}, --4,   -- Earth Shock
{43518  ,"Interrupt"}, --2,   -- Kick
{44418  ,"Interrupt"}, --2,   -- Massive Tremor
{44644  ,"Interrupt"}, --6,   -- Arcane Nova
{45214  ,"Interrupt"}, --8,   -- Ron's Test Spell #4
{45356  ,"Interrupt"}, --5,   -- Kick
{46036  ,"Interrupt"}, --6,   -- Arcane Nova
{46182  ,"Interrupt"}, --2,   -- Snap Kick
{47071  ,"Interrupt"}, --2,   -- Earth Shock
{47081  ,"Interrupt"}, --5,   -- Pummel
{6555   ,"Interrupt"}, --4,   -- Pummel
{42708  ,"Interrupt"}, --6,   -- Staggering Roar
{42729  ,"Interrupt"}, --8,   -- Dreadful Roar
{42780  ,"Interrupt"}, --5,   -- Ringing Slap
{50504  ,"Interrupt"}, --2,   -- Arcane Jolt
{50854  ,"Interrupt"}, --5,   -- Side Kick
{51591  ,"Interrupt"}, --1.5,   -- Stormhammer
{51610  ,"Interrupt"}, --4,   -- Counterspell
{51612  ,"Interrupt"}, --4,   -- Static Arrest
{52272  ,"Interrupt"}, --4,   -- Boulder Throw
{52666  ,"Interrupt"}, --4,   -- Disease Expulsion
{52764  ,"Interrupt"}, --4,   -- Serrated Arrow
{52885  ,"Interrupt"}, --3,   -- Deadly Throw
{53394  ,"Interrupt"}, --5,   -- Pummel
{53550  ,"Interrupt"}, --4,   -- Mind Freeze
{54511  ,"Interrupt"}, --2,   -- Earth Shock
{56256  ,"Interrupt"}, --0.001, -- Vortex
{56506  ,"Interrupt"}, --2,   -- Earth Shock
{56730  ,"Interrupt"}, --8,   -- Dark Counterspell
{56854  ,"Interrupt"}, --4,   -- Counter Kick
{57783  ,"Interrupt"}, --2,   -- Earth Shock
{57845  ,"Interrupt"}, --5,   -- Ringing Slap
{58690  ,"Interrupt"}, --2,   -- Tail Sweep
{58824  ,"Interrupt"}, --4,   -- Disease Expulsion
{58953  ,"Interrupt"}, --5,   -- Pummel
{59033  ,"Interrupt"}, --4,   -- Static Arrest
{59111  ,"Interrupt"}, --8,   -- Dark Counterspell
{59180  ,"Interrupt"}, --3,   -- Deadly Throw
{59283  ,"Interrupt"}, --2,   -- Tail Sweep
{59344  ,"Interrupt"}, --5,   -- Pummel
{59606  ,"Interrupt"}, --5,   -- Ringing Slap
{59708  ,"Interrupt"}, --6,   -- Staggering Roar
{59734  ,"Interrupt"}, --8,   -- Dreadful Roar
{60011  ,"Interrupt"}, --2,   -- Earth Shock
{61068  ,"Interrupt"}, --0.001, -- Vortex
{61381  ,"Interrupt"}, --2,   -- Interrupt
{61668  ,"Interrupt"}, --3,   -- Earth Shock
{62325  ,"Interrupt"}, --8,   -- Ground Tremor
{62347  ,"Interrupt"}, --2,   -- Nether Shock
{62437  ,"Interrupt"}, --8,   -- Ground Tremor
{62522  ,"Interrupt"}, --4,   -- Electroshock
{62681  ,"Interrupt"}, --6,   -- Flame Jets
{62859  ,"Interrupt"}, --10,    -- Ground Tremor
{62932  ,"Interrupt"}, --8,   -- Ground Tremor
{64376  ,"Interrupt"}, --2,   -- Barrel Toss
{64496  ,"Interrupt"}, --6,   -- Feral Rush
{64674  ,"Interrupt"}, --6,   -- Feral Rush
{64710  ,"Interrupt"}, --8,   -- Overhead Smash Tremor
{64715  ,"Interrupt"}, --8,   -- Overhead Smash Tremor
{65790  ,"Interrupt"}, --8,   -- Counterspell
{65973  ,"Interrupt"}, --2,   -- Earth Shock
{66330  ,"Interrupt"}, --8,   -- Staggering Stomp
{66335  ,"Interrupt"}, --8,   -- Mistress' Kiss
{66359  ,"Interrupt"}, --8,   -- Mistress' Kiss
{66408  ,"Interrupt"}, --5,   -- Batter
{66905  ,"Interrupt"}, --2,   -- Hammer of the Righteous
{67235  ,"Interrupt"}, --4,   -- Pummel
{67519  ,"Interrupt"}, --6,   -- Spell Lock
{68884  ,"Interrupt"}, --5,   -- Silence Fool
{71022  ,"Interrupt"}, --8,   -- Disrupting Shout
{72194  ,"Interrupt"}, --3    -- Shield Bash
},]]

  ----------------
  -- Other
  ----------------
  {
    "Other", --TAB

    --------------------------------------------------------
    { 129147, "CC" }, -- Ominous Cackle
    { 2676, "Interrupt" }, -- Pulverize
    { 5133, "Interrupt" }, -- Interrupt (PT)
    { 8714, "Interrupt" }, -- Overwhelming Musk
    { 10887, "Interrupt" }, -- Crowd Pummel
    { 11972, "Interrupt" }, -- Shield Bash
    { 11978, "Interrupt" }, -- Kick
    { 12555, "Interrupt" }, -- Pummel
    { 13281, "Interrupt" }, -- Earth Shock
    { 13728, "Interrupt" }, -- Earth Shock
    { 15122, "Interrupt" }, -- Counterspell
    { 15501, "Interrupt" }, -- Earth Shock
    { 15610, "Interrupt" }, -- Kick
    { 15614, "Interrupt" }, -- Kick
    { 15615, "Interrupt" }, -- Pummel
    { 19129, "Interrupt" }, -- Massive Tremor
    { 19639, "Interrupt" }, -- Pummel
    { 19715, "Interrupt" }, -- Counterspell
    { 20537, "Interrupt" }, -- Counterspell
    { 20788, "Interrupt" }, -- Counterspell
    { 21832, "Interrupt" }, -- Boulder
    { 22885, "Interrupt" }, -- Earth Shock
    { 23114, "Interrupt" }, -- Earth Shock
    { 24685, "Interrupt" }, -- Earth Shock
    { 25025, "Interrupt" }, -- Earth Shock
    { 25788, "Interrupt" }, -- Head Butt
    { 26194, "Interrupt" }, -- Earth Shock
    { 27613, "Interrupt" }, -- Kick
    --{27620  , "Interrupt"},   -- Snap Kick
    --{27814  , "Interrupt"},   -- Kick
    --{27880  , "Interrupt"},   -- Stun
    { 29298, "Interrupt" }, -- Dark Shriek
    { 29560, "Interrupt" }, -- Kick
    { 29586, "Interrupt" }, -- Kick
    { 29961, "Interrupt" }, -- Counterspell
    --{30849  , "Interrupt"},   -- Spell Lock
    { 31596, "Interrupt" }, -- Counterspell
    { 31999, "Interrupt" }, -- Counterspell
    { 32322, "Interrupt" }, -- Dark Shriek
    { 32691, "Interrupt" }, -- Spell Shock
    { 32747, "Interrupt" }, -- Deadly Interrupt Effect
    { 32846, "Interrupt" }, -- Counter Kick
    { 32938, "Interrupt" }, -- Cry of the Dead
    { 33871, "Interrupt" }, -- Shield Bash
    { 34797, "Interrupt" }, -- Nature Shock
    { 34802, "Interrupt" }, -- Kick
    { 35039, "Interrupt" }, -- Countercharge
    { 35178, "Interrupt" }, -- Shield Bash
    --{35856  , "Interrupt"},   -- Stun
    { 35920, "Interrupt" }, -- Electroshock
    { 36033, "Interrupt" }, -- Kick
    --{36138  , "Interrupt"},   -- Hammer Stun
    --{36254  , "Interrupt"},   -- Judgement of the Flame
    { 36841, "Interrupt" }, -- Sonic Boom
    { 36988, "Interrupt" }, -- Shield Bash
    { 37470, "Interrupt" }, -- Counterspell
    { 38052, "Interrupt" }, -- Sonic Boom
    { 38233, "Interrupt" }, -- Shield Bash
    { 38313, "Interrupt" }, -- Pummel
    { 38625, "Interrupt" }, -- Kick
    { 38750, "Interrupt" }, -- War Stomp
    { 38897, "Interrupt" }, -- Sonic Boom
    { 39076, "Interrupt" }, -- Spell Shock
    { 39120, "Interrupt" }, -- Nature Shock
    --{40305  , "Interrupt"},   -- Power Burn
    { 40547, "Interrupt" }, -- Interrupt Unholy Growth
    { 40751, "Interrupt" }, -- Disrupt Magic
    --{40864  , "Interrupt"},   -- Throbbing Stun
    { 41180, "Interrupt" }, -- Shield Bash
    --{41197  , "Interrupt"},   -- Shield Bash
    { 41395, "Interrupt" }, -- Kick
    { 43305, "Interrupt" }, -- Earth Shock
    { 43518, "Interrupt" }, -- Kick
    { 44418, "Interrupt" }, -- Massive Tremor
    { 44644, "Interrupt" }, -- Arcane Nova
    { 45214, "Interrupt" }, -- Ron's Test Spell #4
    { 45356, "Interrupt" }, -- Kick
    { 46036, "Interrupt" }, -- Arcane Nova
    --{46182  , "Interrupt"},   -- Snap Kick
    { 47071, "Interrupt" }, -- Earth Shock
    { 47081, "Interrupt" }, -- Pummel
    --{11978  , "Interrupt"},   -- Pummel (Iron Knuckles Item)
    { 13491, "Interrupt" }, -- Pummel (Iron Knuckles Item)
    { 29443, "Interrupt" }, -- Counterspell (Clutch of Foresight)
    { 56, "CC" }, -- Stun (some weapons proc)
    { 835, "CC" }, -- Tidal Charm (trinket)
    { 4159, "CC" }, -- Tight Pinch
    { 8312, "Root" }, -- Trap (Hunting Net trinket)
    { 17308, "CC" }, -- Stun (Hurd Smasher fist weapon)
    { 23454, "CC" }, -- Stun (The Unstoppable Force weapon)
    { 9179, "CC" }, -- Stun (Tigule and Foror's Strawberry Ice Cream item)
    --{26297    , "Other"},       -- Berserking (troll racial)
    { 13327, "CC" }, -- Reckless Charge (Goblin Rocket Helmet)
    --{23230    , "Other"},       -- Blood Fury (orc racial)

    { 50613, "Silence" }, -- Arcane Torrent (blood elf racial)
    { 13181, "CC" }, -- Gnomish Mind Control Cap (Gnomish Mind Control Cap helmet)
    { 26740, "CC" }, -- Gnomish Mind Control Cap (Gnomish Mind Control Cap helmet)
    { 8345, "CC" }, -- Control Machine (Gnomish Universal Remote trinket)
    { 13235, "CC" }, -- Forcefield Collapse (Gnomish Harm Prevention belt)
    { 13158, "CC" }, -- Rocket Boots Malfunction (Engineering Rocket Boots)
    { 8893, "CC" }, -- Rocket Boots Malfunction (Engineering Rocket Boots)
    { 13466, "CC" }, -- Goblin Dragon Gun (engineering trinket malfunction)
    { 8224, "CC" }, -- Cowardice (Savory Deviate Delight effect)
    { 8225, "CC" }, -- Run Away! (Savory Deviate Delight effect)
    --{23131    , "Immune"},    -- Frost Reflector (Gyrofreeze Ice Reflector trinket) (only reflect frost spells)
    --{23097    , "Immune"},    -- Fire Reflector (Hyper-Radiant Flame Reflector trinket) (only reflect fire spells)
    --{23132    , "Immune"},    -- Shadow Reflector (Ultra-Flash Shadow Reflector trinket) (only reflect shadow spells)
    --{30003    , "Immune"},    -- Sheen of Zanza
    { 23444, "CC" }, -- Transporter Malfunction
    { 23447, "CC" }, -- Transporter Malfunction
    { 23456, "CC" }, -- Transporter Malfunction
    { 23457, "CC" }, -- Transporter Malfunction
    { 8510, "CC" }, -- Large Seaforium Backfire
    { 8511, "CC" }, -- Small Seaforium Backfire
    --{7144     , "Immune"},  -- Stone Slumber
    --{12843    , "Immune"},      -- Mordresh's Shield
    --{27619    , "Immune"},      -- Ice Block
    --{21892    , "Immune"},      -- Arcane Protection
    { 13237, "CC" }, -- Goblin Mortar
    { 13238, "CC" }, -- Goblin Mortar
    { 5134, "CC" }, -- Flash Bomb
    { 4064, "CC" }, -- Rough Copper Bomb
    { 4065, "CC" }, -- Large Copper Bomb
    { 4066, "CC" }, -- Small Bronze Bomb
    { 4067, "CC" }, -- Big Bronze Bomb
    { 4068, "CC" }, -- Iron Grenade
    { 4069, "CC" }, -- Big Iron Bomb
    { 12543, "CC" }, -- Hi-Explosive Bomb
    { 12562, "CC" }, -- The Big One
    { 12421, "CC" }, -- Mithril Frag Bomb
    { 19784, "CC" }, -- Dark Iron Bomb
    { 19769, "CC" }, -- Thorium Grenade
    { 13808, "CC" }, -- M73 Frag Grenade
    { 21188, "CC" }, -- Stun Bomb Attack
    { 9159, "CC" }, -- Sleep (Green Whelp Armor chest)
    { 19821, "Silence" }, -- Arcane Bomb
    --{9774     , "Other"},       -- Immune Root (spider belt)
    { 18278, "Silence" }, -- Silence (Silent Fang sword)
    { 8346, "Root" }, -- Mobility Malfunction (trinket)
    { 13099, "Root" }, -- Net-o-Matic (trinket)
    { 13119, "Root" }, -- Net-o-Matic (trinket)
    { 13138, "Root" }, -- Net-o-Matic (trinket)
    { 16566, "Root" }, -- Net-o-Matic (trinket)
    { 15752, "Disarm" }, -- Linken's Boomerang (trinket)
    { 15753, "CC" }, -- Linken's Boomerang (trinket)
    { 15535, "CC" }, -- Enveloping Winds (Six Demon Bag trinket)
    { 23103, "CC" }, -- Enveloping Winds (Six Demon Bag trinket)
    { 15534, "CC" }, -- Polymorph (Six Demon Bag trinket)
    { 16470, "CC" }, -- Gift of Stone
    { 700, "CC" }, -- Sleep (Slumber Sand item)
    { 1090, "CC" }, -- Sleep
    { 12098, "CC" }, -- Sleep
    { 20663, "CC" }, -- Sleep
    { 20669, "CC" }, -- Sleep
    { 8064, "CC" }, -- Sleepy
    { 17446, "CC" }, -- The Black Sleep
    { 29124, "CC" }, -- Polymorph
    { 14621, "CC" }, -- Polymorph
    { 27760, "CC" }, -- Polymorph
    { 28406, "CC" }, -- Polymorph Backfire
    { 851, "CC" }, -- Polymorph: Sheep
    { 16707, "CC" }, -- Hex
    { 16708, "CC" }, -- Hex
    { 16709, "CC" }, -- Hex
    { 18503, "CC" }, -- Hex
    { 20683, "CC" }, -- Highlord's Justice
    { 17286, "CC" }, -- Crusader's Hammer
    --{17820    , "Other"},       -- Veil of Shadow
    { 12096, "CC" }, -- Fear
    { 27641, "CC" }, -- Fear
    { 29168, "CC" }, -- Fear
    { 30002, "CC" }, -- Fear
    { 15398, "CC" }, -- Psychic Scream
    { 26042, "CC" }, -- Psychic Scream
    { 27610, "CC" }, -- Psychic Scream
    { 10794, "CC" }, -- Spirit Shock
    { 9915, "Root" }, -- Frost Nova
    { 14907, "Root" }, -- Frost Nova
    { 15091, "Snare" }, -- Blast Wave
    { 17277, "Snare" }, -- Blast Wave
    { 23039, "Snare" }, -- Blast Wave
    { 23115, "Snare" }, -- Frost Shock
    { 19133, "Snare" }, -- Frost Shock
    { 21030, "Snare" }, -- Frost Shock
    { 11538, "Snare" }, -- Frostbolt
    { 21369, "Snare" }, -- Frostbolt
    { 20297, "Snare" }, -- Frostbolt
    { 20806, "Snare" }, -- Frostbolt
    { 20819, "Snare" }, -- Frostbolt
    { 20792, "Snare" }, -- Frostbolt
    { 23412, "Snare" }, -- Frostbolt
    { 24942, "Snare" }, -- Frostbolt
    { 23102, "Snare" }, -- Frostbolt
    { 20717, "Snare" }, -- Sand Breath
    { 16568, "Snare" }, -- Mind Flay
    { 16094, "Snare" }, -- Frost Breath
    { 16340, "Snare" }, -- Frost Breath
    { 17174, "Snare" }, -- Concussive Shot
    { 27634, "Snare" }, -- Concussive Shot
    { 20654, "Root" }, -- Entangling Roots
    { 22800, "Root" }, -- Entangling Roots
    { 20699, "Root" }, -- Entangling Roots
    { 18546, "Root" }, -- Overdrive
    { 22935, "Root" }, -- Planted
    { 12520, "Root" }, -- Teleport from Azshara Tower
    { 12521, "Root" }, -- Teleport from Azshara Tower
    { 12509, "Root" }, -- Teleport from Azshara Tower
    { 12023, "Root" }, -- Web
    { 13608, "Root" }, -- Hooked Net
    { 10017, "Root" }, -- Frost Hold
    { 23279, "Root" }, -- Crippling Clip
    { 3542, "Root" }, -- Naraxis Web
    { 5567, "Root" }, -- Miring Mud
    { 5424, "Root" }, -- Claw Grasp
    { 5219, "Root" }, -- Draw of Thistlenettle
    { 9576, "Root" }, -- Lock Down
    { 7950, "Root" }, -- Pause
    { 7761, "Root" }, -- Shared Bondage
    { 6714, "Root" }, -- Test of Faith
    { 6716, "Root" }, -- Test of Faith
    --{4932     , "Immune"},    -- Ward of Myzrael
    --{7383     , "Immune"},  -- Water Bubble
    { 25, "CC" }, -- Stun
    { 101, "CC" }, -- Trip
    { 2880, "CC" }, -- Stun
    { 5648, "CC" }, -- Stunning Blast
    { 5649, "CC" }, -- Stunning Blast
    { 5726, "CC" }, -- Stunning Blow
    { 5727, "CC" }, -- Stunning Blow
    { 5703, "CC" }, -- Stunning Strike
    { 5918, "CC" }, -- Shadowstalker Stab
    { 3446, "CC" }, -- Ravage
    { 3109, "CC" }, -- Presence of Death
    { 3143, "CC" }, -- Glacial Roar
    { 5403, "Root" }, -- Crash of Waves
    { 3260, "CC" }, -- Violent Shield Effect
    { 3263, "CC" }, -- Touch of Ravenclaw
    { 3271, "CC" }, -- Fatigued
    { 5106, "CC" }, -- Crystal Flash
    { 6266, "CC" }, -- Kodo Stomp
    { 6730, "CC" }, -- Head Butt
    { 6982, "CC" }, -- Gust of Wind
    { 6749, "CC" }, -- Wide Swipe
    { 6754, "CC" }, -- Slap!
    { 6927, "CC" }, -- Shadowstalker Slash
    { 7961, "CC" }, -- Azrethoc's Stomp
    { 8151, "CC" }, -- Surprise Attack
    { 3635, "CC" }, -- Crystal Gaze
    { 9992, "CC" }, -- Dizzy
    { 6614, "CC" }, -- Cowardly Flight
    { 5543, "CC" }, -- Fade Out
    { 6664, "CC" }, -- Survival Instinct
    { 6669, "CC" }, -- Survival Instinct
    { 5951, "CC" }, -- Knockdown
    { 4538, "CC" }, -- Extract Essence
    { 6580, "CC" }, -- Pierce Ankle
    { 6894, "CC" }, -- Death Bed
    { 7184, "CC" }, -- Lost Control
    { 8901, "CC" }, -- Gas Bomb
    { 8902, "CC" }, -- Gas Bomb
    { 9454, "CC" }, -- Freeze
    { 7082, "CC" }, -- Barrel Explode
    { 6537, "CC" }, -- Call of the Forest
    { 8672, "CC" }, -- Challenger is Dazed
    { 6409, "CC" }, -- Cheap Shot
    { 14902, "CC" }, -- Cheap Shot
    { 8338, "CC" }, -- Defibrillated!
    { 23055, "CC" }, -- Defibrillated!
    { 8646, "CC" }, -- Snap Kick
    { 27620, "Silence" }, -- Snap Kick
    { 27814, "Silence" }, -- Kick
    { 11650, "CC" }, -- Head Butt
    { 21990, "CC" }, -- Tornado
    { 19725, "CC" }, -- Turn Undead
    { 19469, "CC" }, -- Poison Mind
    { 10134, "CC" }, -- Sand Storm
    { 12613, "CC" }, -- Dark Iron Taskmaster Death
    { 13488, "CC" }, -- Firegut Fear Storm
    { 17738, "CC" }, -- Curse of the Plague Rat
    { 20019, "CC" }, -- Engulfing Flames
    { 19136, "CC" }, -- Stormbolt
    { 20685, "CC" }, -- Storm Bolt
    { 16803, "CC" }, -- Flash Freeze
    { 14100, "CC" }, -- Terrifying Roar
    { 17276, "CC" }, -- Scald
    { 13360, "CC" }, -- Knockdown
    { 11430, "CC" }, -- Slam
    { 16451, "CC" }, -- Judge's Gavel
    { 25260, "CC" }, -- Wings of Despair
    { 23275, "CC" }, -- Dreadful Fright
    { 24919, "CC" }, -- Nauseous
    { 21167, "CC" }, -- Snowball
    { 26641, "CC" }, -- Aura of Fear
    { 28315, "CC" }, -- Aura of Fear
    { 21898, "CC" }, -- Warlock Terror
    { 20672, "CC" }, -- Fade
    { 31365, "CC" }, -- Self Fear
    { 25815, "CC" }, -- Frightening Shriek
    { 12134, "CC" }, -- Atal'ai Corpse Eat
    { 16096, "CC" }, -- Cowering Roar
    { 27177, "CC" }, -- Defile
    { 18395, "CC" }, -- Dismounting Shot
    { 28323, "CC" }, -- Flameshocker's Revenge
    { 28314, "CC" }, -- Flameshocker's Touch
    { 28127, "CC" }, -- Flash
    { 17011, "CC" }, -- Freezing Claw
    { 14102, "CC" }, -- Head Smash
    { 15652, "CC" }, -- Head Smash
    { 23269, "CC" }, -- Holy Blast
    { 22357, "CC" }, -- Icebolt
    { 10451, "CC" }, -- Implosion
    { 15252, "CC" }, -- Keg Trap
    { 27615, "CC" }, -- Kidney Shot
    { 24213, "CC" }, -- Ravage
    { 21936, "CC" }, -- Reindeer
    { 11444, "CC" }, -- Shackle Undead
    { 14871, "CC" }, -- Shadow Bolt Misfire
    { 25056, "CC" }, -- Stomp
    { 24647, "CC" }, -- Stun
    { 17691, "CC" }, -- Time Out
    { 11481, "CC" }, -- TWEEP
    { 20310, "CC" }, -- Stun
    { 23775, "CC" }, -- Stun Forever
    { 23676, "CC" }, -- Minigun (chance to hit reduced by 50%)
    { 11983, "CC" }, -- Steam Jet (chance to hit reduced by 30%)
    { 9612, "CC" }, -- Ink Spray (chance to hit reduced by 50%)
    { 4150, "CC" }, -- Eye Peck (chance to hit reduced by 47%)
    { 6530, "CC" }, -- Sling Dirt (chance to hit reduced by 40%)
    { 5101, "CC" }, -- Dazed
    { 4320, "Silence" }, -- Trelane's Freezing Touch
    { 4243, "Silence" }, -- Pester Effect
    { 6942, "Silence" }, -- Overwhelming Stench
    { 9552, "Silence" }, -- Searing Flames
    { 10576, "Silence" }, -- Piercing Howl
    { 12943, "Silence" }, -- Fell Curse Effect
    { 23417, "Silence" }, -- Smother
    { 10851, "Disarm" }, -- Grab Weapon
    { 25057, "Disarm" }, -- Dropped Weapon
    { 25655, "Disarm" }, -- Dropped Weapon
    { 14180, "Disarm" }, -- Sticky Tar
    { 5376, "Disarm" }, -- Hand Snap
    { 6576, "CC" }, -- Intimidating Growl
    { 7093, "CC" }, -- Intimidation
    { 8715, "CC" }, -- Terrifying Howl
    { 8817, "CC" }, -- Smoke Bomb
    { 9458, "CC" }, -- Smoke Cloud
    { 3442, "CC" }, -- Enslave
    --{3389     , "Immune"},    -- Ward of the Eye
    --{3651     , "Immune"},    -- Shield of Reflection
    --{20223    , "Immune"},    -- Magic Reflection
    --{27546    , "Immune"},    -- Faerie Dragon Form (not immune, 50% magical damage reduction)
    --{17177    , "Immune"},  -- Seal of Protection
    { 25772, "CC" }, -- Mental Domination
    { 16053, "CC" }, -- Dominion of Soul (Orb of Draconic Energy)
    { 15859, "CC" }, -- Dominate Mind
    { 20740, "CC" }, -- Dominate Mind
    { 11446, "CC" }, -- Mind Control
    { 20668, "CC" }, -- Sleepwalk
    { 21330, "CC" }, -- Corrupted Fear (Deathmist Raiment set)
    { 27868, "Root" }, -- Freeze (Magister's and Sorcerer's Regalia sets)
    { 17333, "Root" }, -- Spider's Kiss (Spider's Kiss set)
    { 26108, "CC" }, -- Glimpse of Madness (Dark Edge of Insanity axe)
    { 1604, "Snare" }, -- Dazed
    { 9462, "Snare" }, -- Mirefin Fungus
    { 19137, "Snare" }, -- Slow
    { 24753, "CC" }, -- Trick
    { 21847, "CC" }, -- Snowman
    { 21848, "CC" }, -- Snowman
    { 21980, "CC" }, -- Snowman
    { 27880, "CC" }, -- Stun
    { 23010, "CC" }, -- Tendrils of Air
    --{6724     , "Immune"},      -- Light of Elune
    --{13007    , "Immune"},      -- Divine Protection
    { 24360, "CC" }, -- Greater Dreamless Sleep Potion
    { 15822, "CC" }, -- Dreamless Sleep Potion
    { 15283, "CC" }, -- Stunning Blow (Dark Iron Pulverizer weapon)
    { 21152, "CC" }, -- Earthshaker (Earthshaker weapon)
    { 16600, "CC" }, -- Might of Shahram (Blackblade of Shahram sword)
    { 16597, "Snare" }, -- Curse of Shahram (Blackblade of Shahram sword)
    { 13496, "Snare" }, -- Dazed (Mug O' Hurt mace)
    --[[{3238     , "Other"},       -- Nimble Reflexes
{5990     , "Other"},       -- Nimble Reflexes
{6615     , "Other"},       -- Free Action Potion
{11359    , "Other"},       -- Restorative Potion
{24364    , "Other"},       -- Living Free Action Potion
{23505    , "Other"},       -- Berserking
{24378    , "Other"},       -- Berserking
{19135    , "Other"},       -- Avatar
{12738    , "Other"},]]
    -- Amplify Damage
    { 26198, "CC" }, -- Whisperings of C'Thun
    { 26195, "CC" }, -- Whisperings of C'Thun
    { 26197, "CC" }, -- Whisperings of C'Thun
    { 26258, "CC" }, -- Whisperings of C'Thun
    { 26259, "CC" }, -- Whisperings of C'Thun
    --{17624    , "Immune"},      -- Flask of Petrification (not immune, absorbs damage up to 6000, cannot attack, move or use spells)
    { 13534, "Disarm" }, -- Disarm (The Shatterer weapon)
    { 11879, "Disarm" }, -- Disarm (Shoni's Disarming Tool weapon)
    { 13439, "Snare" }, -- Frostbolt (some weapons)
    --{16621    , "Immune"},  -- Self Invulnerability (Invulnerable Mail)
    { 27559, "Silence" }, -- Silence (Jagged Obsidian Shield)
    { 13907, "CC" }, -- Smite Demon (Enchant Weapon - Demonslaying)
    { 18798, "CC" }, -- Freeze (Freezing Band)
    { 17500, "CC" }, -- Malown's Slam (Malown's Slam weapon)
    { 34510, "CC" }, -- Stun (Stormherald and Deep Thunder weapons)
    { 46567, "CC" }, -- Rocket Launch (Goblin Rocket Launcher trinket)
    { 30501, "Silence" }, -- Poultryized! (Gnomish Poultryizer trinket)
    { 30504, "Silence" }, -- Poultryized! (Gnomish Poultryizer trinket)
    { 30506, "Silence" }, -- Poultryized! (Gnomish Poultryizer trinket)
    { 35474, "CC" }, -- Drums of Panic (Drums of Panic item)
    { 351357, "CC" }, -- Greater Drums of Panic (Greater Drums of Panic item)
    { 28504, "CC" }, -- Major Dreamless Sleep (Major Dreamless Sleep Potion)
    { 30216, "CC" }, -- Fel Iron Bomb
    { 30217, "CC" }, -- Adamantite Grenade
    { 30461, "CC" }, -- The Bigger One
    { 31367, "Root" }, -- Netherweave Net (tailoring item)
    { 31368, "Root" }, -- Heavy Netherweave Net (tailoring item)
    { 39965, "Root" }, -- Frost Grenade
    { 36940, "CC" }, -- Transporter Malfunction
    { 51581, "CC" }, -- Rocket Boots Malfunction
    { 12565, "CC" }, -- Wyatt Test
    { 35182, "CC" }, -- Banish
    { 40307, "CC" }, -- Stasis Field
    --{40282    , "Immune"},      -- Possess Spirit Immune
    --{45838    , "Immune"},      -- Possess Drake Immune
    { 35236, "CC" }, -- Heat Wave (chance to hit reduced by 35%)
    { 29117, "CC" }, -- Feather Burst (chance to hit reduced by 50%)
    { 34088, "CC" }, -- Feeble Weapons (chance to hit reduced by 75%)
    --[[]{45078    , "Other"},        -- Berserk (damage increased by 500%)
{32378    , "Other"},       -- Filet (healing effects reduced by 50%)
{32736    , "Other"},       -- Mortal Strike (healing effects reduced by 50%)
{39595    , "Other"},       -- Mortal Cleave (healing effects reduced by 50%)
{40220    , "Other"},       -- Mortal Strike (healing effects reduced by 50%)
{44268    , "Other"},       -- Mortal Strike (healing effects reduced by 50%)
{34625    , "Other"},       -- Demolish (healing effects reduced by 75%)
{38031    , "Other"},       -- Shield Block (chance to block increased by 75%)
{31905    , "Other"},       -- Shield Stance (chance to block increased by 100%)
{37683    , "Other"},       -- Evasion (chance to dodge increased by 50%)
{38541    , "Other"},]]
    -- Evasion (chance to dodge increased by 50%)
    --[[]{36513    , "Immune"}, -- Intangible Presence (not immune, physical damage taken reduced by 40%)
{45954    , "Immune"},      -- Ahune's Shield (not immune, damage taken reduced by 75%)
{46416    , "Immune"},      -- Ahune Self Stun
{50279    , "Immune"},      -- Copy of Elemental Shield (not immune, damage taken reduced by 75%)
{29476    , "Immune"},      -- Astral Armor (not immune, damage taken reduced by 90%)
{30858    , "Immune"},      -- Demon Blood Shell
{42206    , "Immune"},      -- Protection
{33581    , "Immune"},      -- Divine Shield
{40733    , "Immune"},      -- Divine Shield
{30972    , "Immune"},      -- Evocation
{31797    , "Immune"},      -- Banish Self
{34973    , "Immune"},      -- Ravandwyr's Ice Block
{36527    , "Immune"},      -- Stasis
{36816    , "Immune"},      -- Water Shield
{36860    , "Immune"},      -- Cannon Charging (self)
{36911    , "Immune"},      -- Ice Block
{37546    , "Immune"},      -- Banish
{37905    , "Immune"},      -- Metamorphosis
{37205    , "Immune"},      -- Channel Air Shield
{38099    , "Immune"},      -- Channel Air Shield
{38100    , "Immune"},      -- Channel Air Shield
{37204    , "Immune"},      -- Channel Earth Shield
{38101    , "Immune"},      -- Channel Earth Shield
{38102    , "Immune"},      -- Channel Earth Shield
{37206    , "Immune"},      -- Channel Fire Shield
{38103    , "Immune"},      -- Channel Fire Shield
{38104    , "Immune"},      -- Channel Fire Shield
{36817    , "Immune"},      -- Channel Water Shield
{38105    , "Immune"},      -- Channel Water Shield
{38106    , "Immune"},      -- Channel Water Shield
{38456    , "Immune"},      -- Banish Self
{38916    , "Immune"},      -- Diplomatic Immunity
{40357    , "Immune"},      -- Legion Ring - Character Invis and Immune
{41130    , "Immune"},      -- Toranaku - Character Invis and Immune
{40671    , "Immune"},      -- Health Funnel
{41590    , "Immune"},      -- Ice Block
{42354    , "Immune"},      -- Banish Self
{46604    , "Immune"},      -- Ice Block
{11412    , "Immune"},  -- Nether Shell
{34518    , "Immune"},  -- Nether Protection (Embrace of the Twisting Nether & Twisting Nether Chain Shirt items)
{38026    , "Immune"},  -- Viscous Shield
{36576    , "Immune"},    -- Shaleskin (not immune, magic damage taken reduced by 50%)
{39804    , "Immune"},    -- Damage Immunity: Magic
{39811    , "Immune"},    -- Damage Immunity: Fire, Frost, Shadow, Nature, Arcane
{37538    , "Immune"},]]
    -- Anti-Magic Shield
    { 32904, "CC" }, -- Pacifying Dust
    { 37748, "CC" }, -- Teron Gorefiend
    { 38177, "CC" }, -- Blackwhelp Net
    { 39810, "CC" }, -- Sparrowhawk Net
    { 41621, "CC" }, -- Wolpertinger Net
    { 43906, "CC" }, -- Feeling Froggy
    { 32913, "CC" }, -- Dazzling Dust
    { 33810, "CC" }, -- Rock Shell
    { 37450, "CC" }, -- Dimensius Feeding
    { 38318, "CC" }, -- Transformation - Blackwhelp
    { 35892, "Silence" }, -- Suppression
    { 34087, "Silence" }, -- Chilling Words
    { 35334, "Silence" }, -- Nether Shock
    { 38913, "Silence" }, -- Silence
    { 38915, "CC" }, -- Mental Interference
    { 41128, "CC" }, -- Through the Eyes of Toranaku
    { 22901, "CC" }, -- Body Switch
    { 31988, "CC" }, -- Enslave Humanoid
    { 37323, "CC" }, -- Crystal Control
    { 37221, "CC" }, -- Crystal Control
    { 38774, "CC" }, -- Incite Rage
    { 33384, "CC" }, -- Mass Charm
    { 36145, "CC" }, -- Chains of Naberius
    { 42185, "CC" }, -- Brewfest Control Piece
    { 44881, "CC" }, -- Charm Ravager
    { 37216, "CC" }, -- Crystal Control
    { 29909, "CC" }, -- Elven Manacles
    --{31533    , "Immune"},    -- Spell Reflection (50% chance to reflect a spell)
    --{33719    , "Immune"},    -- Perfect Spell Reflection
    --{34783    , "Immune"},    -- Spell Reflection
    --{37885    , "Immune"},    -- Spell Reflection
    --{38331    , "Immune"},    -- Spell Reflection
    { 28516, "Silence" }, -- Sunwell Torrent (Sunwell Blade & Sunwell Orb items)
    { 33913, "Silence" }, -- Soul Burn
    { 37031, "Silence" }, -- Chaotic Temperament
    { 39052, "Silence" }, -- Sonic Burst
    { 41247, "Silence" }, -- Shared Suffering
    { 44957, "Silence" }, -- Nether Shock
    { 31955, "Disarm" }, -- Disarm
    { 34097, "Disarm" }, -- Riposte
    { 34099, "Disarm" }, -- Riposte
    { 36208, "Disarm" }, -- Steal Weapon
    { 36510, "Disarm" }, -- Enchanted Weapons
    { 39489, "Disarm" }, -- Enchanted Weapons
    { 41053, "Disarm" }, -- Whirling Blade
    { 47310, "Disarm" }, -- Direbrew's Disarm
    { 30298, "CC" }, -- Tree Disguise
    { 49750, "CC" }, -- Honey Touched
    { 42380, "CC" }, -- Conflagration
    { 42408, "CC" }, -- Headless Horseman Climax - Head Stun
    { 42695, "CC" }, -- Holiday - Brewfest - Dark Iron Knock-down Power-up
    { 42435, "CC" }, -- Brewfest - Stun
    { 47718, "CC" }, -- Direbrew Charge
    { 47442, "CC" }, -- Barreled!
    { 51413, "CC" }, -- Barreled!
    { 47340, "CC" }, -- Dark Brewmaiden's Stun
    { 50093, "CC" }, -- Chilled
    { 29044, "CC" }, -- Hex
    { 30838, "CC" }, -- Polymorph
    { 35840, "CC" }, -- Conflagration
    { 39293, "CC" }, -- Conflagration
    { 40400, "CC" }, -- Hex
    { 42805, "CC" }, -- Dirty Trick
    { 45665, "CC" }, -- Encapsulate
    { 26661, "CC" }, -- Fear
    { 31358, "CC" }, -- Fear
    { 31404, "CC" }, -- Shrill Cry
    { 32040, "CC" }, -- Scare Daggerfen
    { 32241, "CC" }, -- Fear
    { 32709, "CC" }, -- Death Coil
    { 33829, "CC" }, -- Fleeing in Terror
    { 33924, "CC" }, -- Fear
    { 34259, "CC" }, -- Fear
    { 35198, "CC" }, -- Terrify
    { 35954, "CC" }, -- Death Coil
    { 36629, "CC" }, -- Terrifying Roar
    { 36950, "CC" }, -- Blinding Light
    { 37939, "CC" }, -- Terrifying Roar
    { 38065, "CC" }, -- Death Coil
    { 38154, "CC" }, -- Fear
    { 39048, "CC" }, -- Howl of Terror
    { 39119, "CC" }, -- Fear
    { 39176, "CC" }, -- Fear
    { 39210, "CC" }, -- Fear
    { 39661, "CC" }, -- Death Coil
    { 39914, "CC" }, -- Scare Soulgrinder Ghost
    { 40221, "CC" }, -- Terrifying Roar
    { 40259, "CC" }, -- Boar Charge
    { 40636, "CC" }, -- Bellowing Roar
    { 40669, "CC" }, -- Egbert
    { 41436, "CC" }, -- Panic
    { 42690, "CC" }, -- Terrifying Roar
    { 42869, "CC" }, -- Conflagration
    { 44142, "CC" }, -- Death Coil
    { 50368, "CC" }, -- Ethereal Liqueur Mutation
    { 27983, "CC" }, -- Lightning Strike
    { 29516, "CC" }, -- Dance Trance
    { 29903, "CC" }, -- Dive
    { 30657, "CC" }, -- Quake
    { 30688, "CC" }, -- Shield Slam
    { 30790, "CC" }, -- Arcane Domination
    { 30832, "CC" }, -- Kidney Shot
    { 30850, "CC" }, -- Seduction
    { 30857, "CC" }, -- Wield Axes
    { 31274, "CC" }, -- Knockdown
    { 31292, "CC" }, -- Sleep
    { 31390, "CC" }, -- Knockdown
    { 31539, "CC" }, -- Self Stun Forever
    { 31541, "CC" }, -- Sleep
    { 31548, "CC" }, -- Sleep
    { 31733, "CC" }, -- Charge
    { 31819, "CC" }, -- Cheap Shot
    { 31843, "CC" }, -- Cheap Shot
    { 31864, "CC" }, -- Shield Charge Stun
    { 31964, "CC" }, -- Thundershock
    { 31994, "CC" }, -- Shoulder Charge
    { 32015, "CC" }, -- Knockdown
    { 32021, "CC" }, -- Rushing Charge
    { 32023, "CC" }, -- Hoof Stomp
    { 32104, "CC" }, -- Backhand
    { 32105, "CC" }, -- Kick
    { 32150, "CC" }, -- Infernal
    { 32416, "CC" }, -- Hammer of Justice
    { 32779, "CC" }, -- Repentance
    { 32905, "CC" }, -- Glare
    { 33128, "CC" }, -- Stone Gaze
    { 33241, "CC" }, -- Infernal
    { 33422, "CC" }, -- Phase In
    { 33463, "CC" }, -- Icebolt
    { 33487, "CC" }, -- Addle Humanoid
    { 33542, "CC" }, -- Staff Strike
    { 33637, "CC" }, -- Infernal
    { 33781, "CC" }, -- Ravage
    { 33792, "CC" }, -- Exploding Shot
    { 33965, "CC" }, -- Look Around
    { 33937, "CC" }, -- Stun Phase 2 Units
    { 34016, "CC" }, -- Stun Phase 3 Units
    { 34023, "CC" }, -- Stun Phase 4 Units
    { 34024, "CC" }, -- Stun Phase 5 Units
    { 34108, "CC" }, -- Spine Break
    { 34243, "CC" }, -- Cheap Shot
    { 34357, "CC" }, -- Vial of Petrification
    { 34620, "CC" }, -- Slam
    { 34815, "CC" }, -- Teleport Effect
    { 34885, "CC" }, -- Petrify
    { 35202, "CC" }, -- Paralysis
    { 35313, "CC" }, -- Hypnotic Gaze
    { 35382, "CC" }, -- Rushing Charge
    { 35424, "CC" }, -- Soul Shadows
    { 35492, "CC" }, -- Exhaustion
    { 35614, "CC" }, -- Kaylan's Wrath
    { 35856, "CC" }, -- Stun
    { 35957, "CC" }, -- Mana Bomb Explosion
    { 36138, "CC" }, -- Hammer Stun
    { 36254, "CC" }, -- Judgement of the Flame
    { 36402, "CC" }, -- Sleep
    { 36449, "CC" }, -- Debris
    { 36474, "CC" }, -- Flayer Flu
    { 36509, "CC" }, -- Charge
    { 36575, "CC" }, -- T'chali the Head Freeze State
    { 36642, "CC" }, -- Banished from Shattrath City
    { 36671, "CC" }, -- Banished from Shattrath City
    { 36732, "CC" }, -- Scatter Shot
    { 36809, "CC" }, -- Overpowering Sickness
    { 36824, "CC" }, -- Overwhelming Odor
    { 36877, "CC" }, -- Stun Forever
    { 37012, "CC" }, -- Swoop
    { 37073, "CC" }, -- Drink Eye Potion
    { 37103, "CC" }, -- Smash
    { 37417, "CC" }, -- Warp Charge
    { 37493, "CC" }, -- Feign Death
    { 37592, "CC" }, -- Knockdown
    { 37768, "CC" }, -- Metamorphosis
    { 37833, "CC" }, -- Banish
    { 37919, "CC" }, -- Arcano-dismantle
    { 38006, "CC" }, -- World Breaker
    { 38009, "CC" }, -- Banish
    { 38169, "CC" }, -- Subservience
    { 38357, "CC" }, -- Tidal Surge
    { 38510, "CC" }, -- Sablemane's Sleeping Powder
    { 38554, "CC" }, -- Absorb Eye of Grillok
    { 38757, "CC" }, -- Fel Reaver Freeze
    { 38863, "CC" }, -- Gouge
    { 39229, "CC" }, -- Talon of Justice
    { 39568, "CC" }, -- Stun
    { 39594, "CC" }, -- Cyclone
    { 39622, "CC" }, -- Banish
    { 39668, "CC" }, -- Ambush
    { 40135, "CC" }, -- Shackle Undead
    { 40262, "CC" }, -- Super Jump
    { 40358, "CC" }, -- Death Hammer
    { 40370, "CC" }, -- Banish
    { 40380, "CC" }, -- Legion Ring - Shield Defense Beam
    { 40511, "CC" }, -- Demon Transform 1
    { 40398, "CC" }, -- Demon Transform 2
    { 40510, "CC" }, -- Demon Transform 3
    { 40409, "CC" }, -- Maiev Down
    { 40447, "CC" }, -- Akama Soul Channel
    { 40490, "CC" }, -- Resonant Feedback
    { 40497, "CC" }, -- Chaos Charge
    { 40503, "CC" }, -- Possession Transfer
    { 40563, "CC" }, -- Throw Axe
    { 40578, "CC" }, -- Cyclone
    { 40774, "CC" }, -- Stun Pulse
    { 40835, "CC" }, -- Stasis Field
    { 40846, "CC" }, -- Crystal Prison
    { 40858, "CC" }, -- Ethereal Ring, Cannon Visual
    { 40951, "CC" }, -- Stasis Field
    { 41182, "CC" }, -- Concussive Throw
    { 41358, "CC" }, -- Rizzle's Blackjack
    { 41421, "CC" }, -- Brief Stun
    { 41528, "CC" }, -- Mark of Stormrage
    { 41534, "CC" }, -- War Stomp
    { 41592, "CC" }, -- Spirit Channelling
    { 41962, "CC" }, -- Possession Transfer
    { 42386, "CC" }, -- Sleeping Sleep
    { 42621, "CC" }, -- Fire Bomb
    { 42648, "CC" }, -- Sleeping Sleep
    { 43528, "CC" }, -- Cyclone
    { 44031, "CC" }, -- Tackled!
    { 44138, "CC" }, -- Rocket Launch
    { 44415, "CC" }, -- Blackout
    { 44432, "CC" }, -- Cube Ground State
    { 44836, "CC" }, -- Banish
    { 44994, "CC" }, -- Self Repair
    { 45574, "CC" }, -- Water Tomb
    { 45676, "CC" }, -- Juggle Torch (Quest, Missed)
    { 45889, "CC" }, -- Scorchling Blast
    { 45947, "CC" }, -- Slip
    { 46188, "CC" }, -- Rocket Launch
    { 46590, "CC" }, -- Ninja Grenade {PH
    { 48342, "CC" }, -- Stun Self
    { 50876, "CC" }, -- Mounted Charge
    { 47407, "Root" }, -- Direbrew's Disarm (precast)
    { 47411, "Root" }, -- Direbrew's Disarm (spin)
    { 43207, "Root" }, -- Headless Horseman Climax - Head's Breath
    { 43049, "Root" }, -- Upset Tummy
    { 31287, "Root" }, -- Entangling Roots
    { 31290, "Root" }, -- Net
    { 31409, "Root" }, -- Wild Roots
    { 33356, "Root" }, -- Self Root Forever
    { 33844, "Root" }, -- Entangling Roots
    { 34080, "Root" }, -- Riposte Stance
    { 34569, "Root" }, -- Chilled Earth
    { 35234, "Root" }, -- Strangling Roots
    { 35247, "Root" }, -- Choking Wound
    { 35327, "Root" }, -- Jackhammer
    { 39194, "Root" }, -- Jackhammer
    { 36252, "Root" }, -- Felforge Flames
    { 36734, "Root" }, -- Test Whelp Net
    { 37823, "Root" }, -- Entangling Roots
    { 38033, "Root" }, -- Frost Nova
    { 38035, "Root" }, -- Freeze
    { 38051, "Root" }, -- Fel Shackles
    { 38338, "Root" }, -- Net
    { 38505, "Root" }, -- Shackle
    { 39268, "Root" }, -- Chains of Ice
    { 40363, "Root" }, -- Entangling Roots
    { 40525, "Root" }, -- Rizzle's Frost Grenade
    { 40590, "Root" }, -- Rizzle's Frost Grenade (Self
    { 40727, "Root" }, -- Icy Leap
    { 41981, "Root" }, -- Dust Field
    { 42716, "Root" }, -- Self Root Forever (No Visual)
    { 43130, "Root" }, -- Creeping Vines
    { 43585, "Root" }, -- Entangle
    { 45255, "Root" }, -- Rocket Chicken
    { 45905, "Root" }, -- Frost Nova
    { 29158, "Snare" }, -- Inhale
    { 29957, "Snare" }, -- Frostbolt Volley
    { 30600, "Snare" }, -- Blast Wave
    { 30942, "Snare" }, -- Frostbolt
    { 31296, "Snare" }, -- Frostbolt
    { 32334, "Snare" }, -- Cyclone
    { 32417, "Snare" }, -- Mind Flay
    { 32774, "Snare" }, -- Avenger's Shield
    { 32984, "Snare" }, -- Frostbolt
    { 33047, "Snare" }, -- Void Bolt
    { 34214, "Snare" }, -- Frost Touch
    { 34347, "Snare" }, -- Frostbolt
    { 35252, "Snare" }, -- Unstable Cloud
    { 35263, "Snare" }, -- Frost Attack
    { 35316, "Snare" }, -- Frostbolt
    { 35351, "Snare" }, -- Sand Breath
    { 35955, "Snare" }, -- Dazed
    { 36148, "Snare" }, -- Chill Nova
    { 36278, "Snare" }, -- Blast Wave
    { 36279, "Snare" }, -- Frostbolt
    { 36464, "Snare" }, -- The Den Mother's Mark
    { 36518, "Snare" }, -- Shadowsurge
    { 36839, "Snare" }, -- Impairing Poison
    { 36843, "Snare" }, -- Slow
    { 37330, "Snare" }, -- Mind Flay
    { 37359, "Snare" }, -- Rush
    { 37554, "Snare" }, -- Avenger's Shield
    { 37786, "Snare" }, -- Bloodmaul Rage
    { 37830, "Snare" }, -- Repolarized Magneto Sphere
    { 38032, "Snare" }, -- Stormbolt
    { 38256, "Snare" }, -- Piercing Howl
    { 38534, "Snare" }, -- Frostbolt
    { 38536, "Snare" }, -- Blast Wave
    { 38663, "Snare" }, -- Slow
    { 38767, "Snare" }, -- Daze
    { 38771, "Snare" }, -- Burning Rage
    { 38952, "Snare" }, -- Frost Arrow
    { 39001, "Snare" }, -- Blast Wave
    { 39038, "Snare" }, -- Blast Wave
    { 40417, "Snare" }, -- Rage
    { 40429, "Snare" }, -- Frostbolt
    { 40430, "Snare" }, -- Frostbolt
    { 40653, "Snare" }, -- Whirlwind
    { 40976, "Snare" }, -- Slimy Spittle
    { 41281, "Snare" }, -- Cripple
    { 41439, "Snare" }, -- Mangle
    { 41486, "Snare" }, -- Frostbolt
    { 42396, "Snare" }, -- Mind Flay
    { 42803, "Snare" }, -- Frostbolt
    { 43945, "Snare" }, -- You're a ...! (Effects1)
    { 43963, "Snare" }, -- Retch!
    { 44289, "Snare" }, -- Crippling Poison
    { 44937, "Snare" }, -- Fel Siphon
    { 46984, "Snare" }, -- Cone of Cold
    { 46987, "Snare" }, -- Frostbolt
    { 47106, "Snare" }, -- Soul Flay
    { 16922, "CC" }, -- Starfire Stun
    { 28445, "CC" }, -- Improved Concussive Shot (talent)
    { 1777, "CC" }, -- Gouge
    { 8629, "CC" }, -- Gouge
    { 11285, "CC" }, -- Gouge
    { 11286, "CC" }, -- Gouge
    { 38764, "CC" }, -- Gouge
    { 20614, "CC" }, -- Intercept
    { 25273, "CC" }, -- Intercept
    { 25274, "CC" }, -- Intercept
    { 12798, "CC" }, -- Revenge Stun
    { 12705, "Snare" }, -- Long Daze (Improved Pummel)
    { 7372, "Snare" }, -- Hamstring
    { 7373, "Snare" }, -- Hamstring
    { 25212, "Snare" }, -- Hamstring
    { 48680, "CC" }, -- Strangulate
    { 49913, "Silence" }, -- Strangulate
    { 49914, "Silence" }, -- Strangulate
    { 49915, "Silence" }, -- Strangulate
    { 49916, "Silence" }, -- Strangulate
    --{65860    , "Immune"},      -- Barkskin (not immune, damage taken decreased by 40%)
    { 50411, "Snare" }, -- Dazed
    { 57546, "CC" }, -- Greater Turn Evil
    { 53570, "CC" }, -- Hungering Cold
    { 61058, "CC" }, -- Hungering Cold
    { 67769, "CC" }, -- Cobalt Frag Bomb
    { 67890, "CC" }, -- Cobalt Frag Bomb (engineering belt enchant)
    { 54735, "CC" }, -- Electromagnetic Pulse (engineering enchant)
    { 67810, "CC" }, -- Mental Battle (engineering enchant)
    { 52207, "CC" }, -- Devour Humanoid
    { 60074, "CC" }, -- Time Stop
    { 60077, "CC" }, -- Stop Time
    { 54132, "CC" }, -- Concussion Blow
    { 61819, "CC" }, -- Manabonked!
    { 61834, "CC" }, -- Manabonked!
    { 65122, "CC" }, -- Polymorph (TEST)
    { 48288, "CC" }, -- Mace Smash
    { 49735, "CC" }, -- Terrifying Countenance
    { 43348, "CC" }, -- Head Crush
    { 58974, "CC" }, -- Crushing Leap
    { 56747, "CC" }, -- Stomp
    { 49675, "CC" }, -- Stone Stomp
    { 51756, "CC" }, -- Charge
    { 51752, "CC" }, -- Stampy's Stompy-Stomp
    { 59705, "CC" }, -- War Stomp
    { 60960, "CC" }, -- War Stomp
    { 70199, "CC" }, -- Blinding Retreat
    { 71750, "CC" }, -- Blind!
    { 50283, "CC" }, -- Blinding Swarm (chance to hit reduced by 75%)
    { 52856, "CC" }, -- Charge
    { 54460, "CC" }, -- Charge
    { 52577, "CC" }, -- Charge
    { 55982, "CC" }, -- Mammoth Charge
    { 46315, "CC" }, -- Mammoth Charge
    { 52601, "CC" }, -- Rushing Charge
    { 52169, "CC" }, -- Magnataur Charge
    { 52061, "CC" }, -- Lightning Fear
    { 68326, "CC" }, -- Fear Self
    { 62628, "CC" }, -- Fear Self
    { 59669, "CC" }, -- Fear
    { 47534, "CC" }, -- Cower in Fear
    { 54196, "CC" }, -- Cower in Fear
    { 75343, "CC" }, -- Shockwave
    { 55918, "CC" }, -- Shockwave
    { 57741, "CC" }, -- Shockwave
    { 48376, "CC" }, -- Hammer Blow
    { 61662, "CC" }, -- Cyclone
    { 69699, "CC" }, -- Cyclone
    { 53103, "CC" }, -- Charm Blightblood Troll
    { 52488, "CC" }, -- Charm Bloated Abomination
    { 52390, "CC" }, -- Charm Drakuru Servant
    { 52244, "CC" }, -- Charm Geist
    { 42790, "CC" }, -- Charm Plaguehound
    { 53070, "CC" }, -- Worgen's Command
    { 48558, "CC" }, -- Backfire
    { 44424, "CC" }, -- Escape
    { 42320, "CC" }, -- Head Butt
    { 53439, "CC" }, -- Hex
    { 49935, "CC" }, -- Hex of the Murloc
    { 50396, "CC" }, -- Psychosis
    { 53325, "CC" }, -- SelfSheep
    { 58283, "CC" }, -- Throw Rock
    { 54683, "CC" }, -- Ablaze
    { 60983, "CC" }, -- Bright Flare
    { 62951, "CC" }, -- Dodge
    { 74472, "CC" }, -- Guard Fear
    { 50577, "CC" }, -- Howl of Terror
    { 53438, "CC" }, -- Incite Horror
    { 48696, "CC" }, -- Intimidating Roar
    { 51467, "CC" }, -- Intimidating Roar
    { 62585, "CC" }, -- Mulgore Hatchling
    { 58958, "CC" }, -- Presence of the Master
    { 51343, "CC" }, -- Razorpine's Fear Effect
    { 51846, "CC" }, -- Scared Chicken
    { 50979, "CC" }, -- Scared Softknuckle
    { 50497, "CC" }, -- Scream of Chaos
    { 56404, "CC" }, -- Startling Flare
    { 62000, "CC" }, -- Stinker Periodic
    { 52716, "CC" }, -- Terrified
    { 46316, "CC" }, -- Thundering Roar
    { 68506, "CC" }, -- Crushing Leap
    { 58203, "CC" }, -- Iron Chain
    { 63726, "CC" }, -- Pacify Self
    { 59880, "CC" }, -- Suppression Charge
    { 62026, "CC" }, -- Test of Strength Building
    { 58891, "CC" }, -- Wild Magic
    { 58893, "CC" }, -- Wild Magic
    { 52151, "CC" }, -- Bat Net
    { 71103, "CC" }, -- Combobulating Spray
    { 67691, "CC" }, -- Feign Death
    { 43489, "CC" }, -- Grasp of the Lich King
    { 51788, "CC" }, -- Lost Soul
    { 66490, "CC" }, -- P3Wx2 Laser Barrage
    --{60778    , "CC"},        -- Serenity
    { 44848, "CC" }, -- Tumbling
    { 49946, "CC" }, -- Chaff
    { 51899, "CC" }, -- Banshee Curse (chance to hit reduced by 40%)
    { 54224, "CC" }, -- Death
    { 58269, "CC" }, -- Iceskin Stoneform
    { 52182, "CC" }, -- Tomb of the Heartless
    { 51897, "CC" }, -- Banshee Screech
    { 57490, "CC" }, -- Librarian's Shush
    { 51316, "CC" }, -- Lobotomize
    { 43415, "CC" }, -- Freezing Trap
    { 43612, "CC" }, -- Bash
    { 48620, "CC" }, -- Wing Buffet
    { 49342, "CC" }, -- Frost Breath
    { 49842, "CC" }, -- Perturbed Mind
    { 51663, "CC" }, -- Slap in the Face
    { 52174, "CC" }, -- Heroic Leap
    { 52271, "CC" }, -- Violent Crash
    { 52402, "CC" }, -- Stunning Force
    { 52457, "CC" }, -- Drak'aguul's Soldiers
    { 52584, "CC" }, -- Influence of the Old God
    { 52939, "CC" }, -- Pungent Slime Vomit
    { 54477, "CC" }, -- Exhausted
    { 54506, "CC" }, -- Heroic Leap
    { 54888, "CC" }, -- Elemental Spawn Effect
    { 55929, "CC" }, -- Impale
    { 57488, "CC" }, -- Squall
    { 57794, "CC" }, -- Heroic Leap
    { 57854, "CC" }, -- Raging Shadows
    { 58154, "CC" }, -- Hammer of Injustice
    { 58628, "CC" }, -- Glyph of Death Grip
    { 59689, "CC" }, -- Heroic Leap
    { 60109, "CC" }, -- Heroic Leap
    { 61065, "CC" }, -- War Stomp
    { 61143, "CC" }, -- Crazed Chop
    { 61557, "CC" }, -- Plant Spawn Effect
    { 61881, "CC" }, -- Ice Shriek
    { 62891, "CC" }, -- Vulnerable!
    { 62999, "CC" }, -- Scourge Stun
    { 64141, "CC" }, -- Flash Freeze
    { 64345, "CC" }, -- Food
    { 67806, "CC" }, -- Mental Combat
    { 68980, "CC" }, -- Harvest Soul
    { 69222, "CC" }, -- Throw Shield
    { 71960, "CC" }, -- Heroic Leap
    { 74785, "CC" }, -- Wrench Throw
    { 42166, "CC" }, -- Plagued Blood Explosion
    { 42167, "CC" }, -- Plagued Blood Explosion
    { 43416, "CC" }, -- Throw Shield
    { 44532, "CC" }, -- Knockdown
    { 44542, "CC" }, -- Eagle Swoop
    { 45108, "CC" }, -- CK's Fireball
    { 45419, "CC" }, -- Nerub'ar Web Wrap
    { 45587, "CC" }, -- Web Bolt
    { 45876, "CC" }, -- Stampede
    { 45922, "CC" }, -- Shadow Prison
    { 45995, "CC" }, -- Bloodspore Ruination
    { 46010, "CC" }, -- Bloodspore Ruination
    { 46383, "CC" }, -- Cenarion Stun
    { 46441, "CC" }, -- Stun
    { 46895, "CC" }, -- Boulder Impact
    { 47007, "CC" }, -- Boulder Impact
    { 47035, "CC" }, -- Out Cold
    { 47415, "CC" }, -- Freezing Breath
    { 47591, "CC" }, -- Frozen Solid
    { 47923, "CC" }, -- Stunned
    { 48323, "CC" }, -- Indisposed
    { 48596, "CC" }, -- Spirit Dies
    { 48628, "CC" }, -- Lock Jaw
    { 49025, "CC" }, -- Self Destruct
    { 49215, "CC" }, -- Self-Destruct
    { 49333, "CC" }, -- Ice Prison
    { 49481, "CC" }, -- Glaive Throw
    { 49616, "CC" }, -- Kidney Shot
    { 50100, "CC" }, -- Stormbolt
    { 50597, "CC" }, -- Ice Stalagmite
    { 50839, "CC" }, -- Stun Self
    { 51020, "CC" }, -- Time Lapse
    { 51319, "CC" }, -- Sandfern Disguise
    { 51329, "CC" }, -- Feign Death
    { 52287, "CC" }, -- Quetz'lun's Hex of Frost
    { 52318, "CC" }, -- Lumberjack Slam
    { 52459, "CC" }, -- End of Round
    { 52497, "CC" }, -- Flatulate
    { 52593, "CC" }, -- Bloated Abomination Feign Death
    { 52640, "CC" }, -- Forge Force
    { 52743, "CC" }, -- Head Smack
    { 52781, "CC" }, -- Persuasive Strike
    { 52908, "CC" }, -- Backhand
    { 52989, "CC" }, -- Akali's Stun
    { 53017, "CC" }, -- Indisposed
    { 53211, "CC" }, -- Post-Apocalypse
    { 53437, "CC" }, -- Backbreaker
    { 53625, "CC" }, -- Heroic Leap
    { 54028, "CC" }, -- Trespasser!
    { 54029, "CC" }, -- Trespasser!
    { 54426, "CC" }, -- Decimate
    { 54526, "CC" }, -- Torment
    { 55224, "CC" }, -- Archivist's Scan
    { 55240, "CC" }, -- Towering Chains
    { 55467, "CC" }, -- Arcane Explosion
    { 55891, "CC" }, -- Flame Sphere Spawn Effect
    { 55947, "CC" }, -- Flame Sphere Death Effect
    { 55958, "CC" }, -- Storm Bolt
    { 56448, "CC" }, -- Storm Hammer
    { 56485, "CC" }, -- The Storm's Fury
    { 56756, "CC" }, -- Fall Asleep Standing
    { 57395, "CC" }, -- Desperate Blow
    { 57515, "CC" }, -- Waking from a Fitful Dream
    { 57626, "CC" }, -- Feign Death
    { 57685, "CC" }, -- Permanent Feign Death
    { 57886, "CC" }, -- Defense System Spawn Effect
    { 58119, "CC" }, -- Geist Control End
    { 58351, "CC" }, -- Teach: Death Gate
    { 58540, "CC" }, -- Eidolon Prison
    { 58563, "CC" }, -- Assassinate Restless Lookout
    { 58664, "CC" }, -- Shade Control End
    { 58672, "CC" }, -- Impale
    { 59047, "CC" }, -- Backhand
    { 59564, "CC" }, -- Flatulate
    { 60511, "CC" }, -- Deep Freeze
    { 60642, "CC" }, -- Annihilate
    { 61224, "CC" }, -- Deep Freeze
    { 61628, "CC" }, -- Storm Bolt
    { 62091, "CC" }, -- Stun Forever AoE
    { 62487, "CC" }, -- Throw Grenade
    { 62973, "CC" }, -- Foam Sword Attack
    { 63124, "CC" }, -- Incapacitate Maloric
    { 63228, "CC" }, -- Talon Strike
    { 63846, "CC" }, -- Arm of Law
    { 63986, "CC" }, -- Trespasser!
    { 63987, "CC" }, -- Trespasser!
    { 64755, "CC" }, -- Clayton's Test Spell
    { 65400, "CC" }, -- Food Coma
    { 65578, "CC" }, -- Right in the eye!
    { 66514, "CC" }, -- Frost Breath
    { 66533, "CC" }, -- Fel Shock
    { 67366, "CC" }, -- C-14 Gauss Rifle
    { 67575, "CC" }, -- Frost Breath
    { 67576, "CC" }, -- Spirit Drain
    { 67780, "CC" }, -- Transporter Arrival
    { 67791, "CC" }, -- Transporter Arrival
    { 68485, "CC" }, -- Clayton's Test Spell 2
    { 69006, "CC" }, -- Onyxian Whelpling
    { 69681, "CC" }, -- Lil' Frost Blast
    { 70296, "CC" }, -- Caught!
    { 70525, "CC" }, -- Jaina's Call
    { 70540, "CC" }, -- Icy Prison
    { 70583, "CC" }, -- Lich King Stun
    { 70592, "CC" }, -- Permanent Feign Death
    { 70628, "CC" }, -- Permanent Feign Death
    { 70630, "CC" }, -- Frozen Aftermath - Feign Death
    { 71988, "CC" }, -- Vile Fumes (Vile Fumigator's Mask item)
    { 73536, "CC" }, -- Trespasser!
    { 74412, "CC" }, -- Emergency Recall
    { 74490, "CC" }, -- Permanent Feign Death
    { 74735, "CC" }, -- Gnomerconfidance
    { 74808, "CC" }, -- Twilight Phasing
    { 75448, "CC" }, -- Bwonsamdi's Boot
    { 75496, "CC" }, -- Zalazane's Fool
    { 75510, "CC" }, -- Emergency Recall
    { 53261, "CC" }, -- Saronite Grenade
    { 71590, "CC" }, -- Rocket Launch
    { 71755, "CC" }, -- Crafty Bomb
    { 71715, "CC" }, -- Snivel's Rocket
    { 71786, "CC" }, -- Rocket Launch
    { 385807, "CC" }, -- Knockdown
    { 59124, "CC" }, -- Crystalline Bonds
    { 49981, "CC" }, -- Machine Gun (chance to hit reduced by 50%)
    { 50188, "CC" }, -- Wildly Flailing (chance to hit reduced by 50%)
    { 50701, "CC" }, -- Sling Mortar (chance to hit reduced by 50%)
    { 51356, "CC" }, -- Vile Vomit (chance to hit reduced by 50%)
    { 54770, "CC" }, -- Bone Saw (chance to hit reduced by 50%)
    { 60906, "CC" }, -- Machine Gun (chance to hit reduced by 50%)
    { 53645, "CC" }, -- The Light of Dawn (damage done reduced by 1500%)
    { 70339, "CC" }, -- Friendly Boss Damage Mod (damage done reduced by 95%)
    { 43952, "CC" }, -- Bonegrinder (physical damage done reduced by 75%)
    { 51705, "CC" }, -- Wrongfully Accused (damage done reduced by 50%)
    { 51707, "CC" }, -- Wrongfully Accused (damage done reduced by 50%)
    { 64850, "CC" }, -- Unrelenting Assault (damage done reduced by 50%)
    { 65925, "CC" }, -- Unrelenting Assault (damage done reduced by 50%)
    { 68780, "CC" }, -- Frozen Visage (damage done reduced by 50%)
    { 72341, "CC" }, -- Hallucinatory Creature (damage done reduced by 50%)
    { 58976, "Disarm" }, -- Assaulter Slam, Throw Axe Disarm
    { 48883, "Disarm" }, -- Disarm
    { 58138, "Disarm" }, -- Disarm Test
    { 54159, "Disarm" }, -- Ritual of the Sword
    { 54059, "Disarm" }, -- You're a ...! (Effects4)
    { 57590, "Disarm" }, -- Steal Ranged (only disarm ranged weapon)
    --[[{65802    , "Immune"},      -- Ice Block
{52982    , "Immune"},      -- Akali's Immunity
{64505    , "Immune"},      -- Dark Shield
{52972    , "Immune"},      -- Dispersal
{54322    , "Immune"},      -- Divine Shield
{47922    , "Immune"},      -- Furyhammer's Immunity
{54166    , "Immune"},      -- Maker's Sanctuary
{53052    , "Immune"},      -- Phase Out
{74458    , "Immune"},      -- Power Shield XL-1
{50161    , "Immune"},      -- Protection Sphere
{50494    , "Immune"},      -- Shroud of Lightning
{54434    , "Immune"},      -- Sparksocket AA: Periodic Aura
{58729    , "Immune"},      -- Spiritual Immunity
{52185    , "Immune"},      -- Bindings of Submission
{62336    , "Immune"},      -- Hookshot Aura
{48695    , "Immune"},      -- Imbue Power Shield State
{48325    , "Immune"},      -- Rune Shield
{62371    , "Immune"},      -- Spirit of Redemption
{75099    , "Immune"},      -- Zalazane's Shield
{75223    , "Immune"},      -- Zalazane's Shield
{66776    , "Immune"},      -- Rage (not immune, damage taken decreased by 95%)
{62733    , "Immune"},      -- Hardened (not immune, damage taken decreased by 90%)
{57057    , "Immune"},      -- Torvald's Deterrence (not immune, damage taken decreased by 60%)
{63214    , "Immune"},      -- Scourge Damage Reduction (not immune, damage taken decreased by 60%)
{53058    , "Immune"},      -- Crystalline Essence (not immune, damage taken decreased by 50%)
{53355    , "Immune"},      -- Strength of the Frenzyheart (not immune, damage taken decreased by 50%)
{53371    , "Immune"},      -- Power of the Great Ones (not immune, damage taken decreased by 50%)
{58130    , "Immune"},      -- Icebound Fortitude (not immune, damage taken decreased by 50%)
{61088    , "Immune"},      -- Zombie Horde (not immune, damage taken decreased by 50%)
{61099    , "Immune"},      -- Zombie Horde (not immune, damage taken decreased by 50%)
{61144    , "Immune"},      -- Fire Shield (not immune, damage taken decreased by 50%)
{54467    , "Immune"},      -- Bone Armor (not immune, damage taken decreased by 40%)
{71822    , "Immune"},      -- Shadow Resonance (not immune, damage taken decreased by 35%)
{62712    , "Immune"},  -- Grab
{54386    , "Immune"},  -- Darmuk's Vigilance (chance to dodge increased by 75%)
{51946    , "Immune"},  -- Evasive Maneuver (chance to dodge increased by 75%)
{57643    , "Immune"},    -- Spell Reflection
{63089    , "Immune"},    -- Spell Deflection
{55976    , "Immune"},    -- Spell Deflection]]
    { 51131, "Silence" }, -- Strangulate
    { 51609, "Silence" }, -- Arcane Lightning
    { 62826, "Silence" }, -- Energy Orb
    { 61734, "Silence" }, -- Noblegarden Bunny
    { 61716, "Silence" }, -- Rabbit Costume
    { 42671, "Silence" }, -- Silencing Shot
    { 64140, "Silence" }, -- Sonic Burst
    { 68922, "Silence" }, -- Unstable Air Nova
    { 53095, "Silence" }, -- Worgen's Call
    { 55536, "Root" }, -- Frostweave Net
    { 54453, "Root" }, -- Web Wrap
    { 57668, "Root" }, -- Frost Nova
    { 61376, "Root" }, -- Frost Nova
    { 62597, "Root" }, -- Frost Nova
    { 65792, "Root" }, -- Frost Nova
    { 69571, "Root" }, -- Frost Nova
    { 71929, "Root" }, -- Frost Nova
    { 47021, "Root" }, -- Net
    { 62312, "Root" }, -- Net
    { 51959, "Root" }, -- Chicken Net
    { 52761, "Root" }, -- Barbed Net
    { 49453, "Root" }, -- Wolvar Net
    { 54997, "Root" }, -- Cast Net
    { 66474, "Root" }, -- Throw Net
    { 50635, "Root" }, -- Frozen
    { 51440, "Root" }, -- Frozen
    { 52973, "Root" }, -- Frost Breath
    { 53019, "Root" }, -- Earth's Grasp
    { 53077, "Root" }, -- Ensnaring Trap
    { 53218, "Root" }, -- Frozen Grip
    { 53534, "Root" }, -- Chains of Ice
    { 58464, "Root" }, -- Chains of Ice
    { 59679, "Root" }, -- Copy of Frostbite
    { 61385, "Root" }, -- Bear Trap
    { 62573, "Root" }, -- Locked Lance
    { 68821, "Root" }, -- Chain Reaction
    { 48416, "Root" }, -- Rune Detonation
    { 48601, "Root" }, -- Rune of Binding
    { 49978, "Root" }, -- Claw Grasp
    { 52713, "Root" }, -- Rune Weaving
    { 53442, "Root" }, -- Claw Grasp
    { 54047, "Root" }, -- Light Lamp
    { 55030, "Root" }, -- Rune Detonation
    { 55284, "Root" }, -- Siege Ram
    { 56425, "Root" }, -- Earth's Grasp
    { 58447, "Root" }, -- Drakefire Chile Ale
    { 61043, "Root" }, -- The Raising of Sindragosa
    { 62187, "Root" }, -- Touchdown!
    { 63861, "Root" }, -- Chains of Law
    { 65444, "Root" }, -- Aura Beam Test
    { 71713, "Root" }, -- Searching the Bank
    { 71745, "Root" }, -- Searching the Auction House
    { 71752, "Root" }, -- Searching the Barber Shop
    { 71758, "Root" }, -- Searching the Barber Shop
    { 71759, "Root" }, -- Searching the Bank
    { 71760, "Root" }, -- Searching the Auction House
    { 73395, "Root" }, -- Elemental Credit
    { 75215, "Root" }, -- Root
    --[[{50822    , "Other"},       -- Fervor
{54615    , "Other"},       -- Aimed Shot (healing effects reduced by 50%)
{54657    , "Other"},       -- Incorporeal (chance to dodge increased by 50%)
{60617    , "Other"},       -- Parry (chance to parry increased by 100%)
{31965    , "Other"},       -- Spell Debuffs 2 (80) (healing effects reduced by 50%)
{60084    , "Other"},       -- The Veil of Shadows (healing effects reduced by 50%)
{61042    , "Other"},       -- Mortal Smash (healing effects reduced by 50%)
{68881    , "Other"},]]
    -- Unstable Water Nova (healing effects reduced by 50%)
    { 51372, "Snare" }, -- Dazed
    { 43512, "Snare" }, -- Mind Flay
    { 60472, "Snare" }, -- Mind Flay
    { 57665, "Snare" }, -- Frostbolt
    { 65023, "Snare" }, -- Cone of Cold
    { 59258, "Snare" }, -- Cone of Cold
    { 48783, "Snare" }, -- Trample
    { 51878, "Snare" }, -- Ice Slash
    { 53113, "Snare" }, -- Thunderclap
    { 61359, "Snare" }, -- Thunderclap
    { 54996, "Snare" }, -- Ice Slick
    { 54540, "Snare" }, -- Test Frostbolt Weapon
    { 61087, "Snare" }, -- Frostbolt
    { 42719, "Snare" }, -- Frostbolt
    { 54791, "Snare" }, -- Frostbolt
    { 61730, "Snare" }, -- Frostbolt
    { 69274, "Snare" }, -- Frostbolt
    { 70327, "Snare" }, -- Frostbolt
    { 62583, "Snare" }, -- Frostbolt
    { 58970, "Snare" }, -- Blast Wave
    { 60290, "Snare" }, -- Blast Wave
    { 47805, "Snare" }, -- Chains of Ice
    { 52436, "Snare" }, -- Scarlet Cannon Assault
    { 57383, "Snare" }, -- Argent Cannon Assault
    { 44622, "Snare" }, -- Tendon Rip
    { 51315, "Snare" }, -- Leprous Touch
    { 68902, "Snare" }, -- Unstable Earth Nova
    { 69769, "Snare" }, -- Ice Prison
    { 50304, "Snare" }, -- Outbreak
    { 58606, "Snare" }, -- Self Snare
    { 65262, "Snare" }, -- Arcane Blurst
    { 70866, "Snare" }, -- Shadow Blast
    { 61578, "Snare" }, -- Incapacitating Shout
    { 43562, "Snare" }, -- Frost Breath
    { 43568, "Snare" }, -- Frost Strike
    { 43569, "Snare" }, -- Frost
    { 47425, "Snare" }, -- Frost Breath
    { 49316, "Snare" }, -- Ice Cannon
    { 51676, "Snare" }, -- Wavering Will
    { 51681, "Snare" }, -- Rearing Stomp
    { 51938, "Snare" }, -- Wing Beat
    { 52292, "Snare" }, -- Pestilience Test
    { 52744, "Snare" }, -- Piercing Howl
    { 52807, "Snare" }, -- Avenger's Shield
    { 52889, "Snare" }, -- Envenomed Shot
    { 54193, "Snare" }, -- Earth's Fury
    { 54340, "Snare" }, -- Vile Vomit
    { 54399, "Snare" }, -- Water Bubble
    { 54451, "Snare" }, -- Withered Touch
    { 54632, "Snare" }, -- Claws of Ice
    { 54687, "Snare" }, -- Cold Feet
    { 56138, "Snare" }, -- Sprained Ankle
    { 56143, "Snare" }, -- Acidic Retch
    { 56147, "Snare" }, -- Aching Bones
    { 57477, "Snare" }, -- Freezing Breath
    { 60667, "Snare" }, -- Frost Breath
    { 60814, "Snare" }, -- Frost Blast
    { 61166, "Snare" }, -- Frostbite Weapon
    { 61572, "Snare" }, -- Frostbite
    { 61577, "Snare" }, -- Molten Blast
    { 63004, "Snare" }, -- {DND NPC Slow
    { 67035, "Snare" }, -- Frost Trap
    { 68551, "Snare" }, -- Dan's Avenger's Shield
    { 71361, "Snare" }, -- Frost Blast
    { 74802, "Snare" }, -- Consumption
    { 47298, "Snare" }, -- Test Frozen Tomb Effect
    { 47307, "Snare" }, -- Test Frozen Tomb
    { 50522, "Snare" }, -- Gorloc Stomp
    { 69984, "Snare" }, -- Frostfire Bolt
  },

  -- PvE
  --{123456   , "PvE"},       -- This is just an example, not a real spell
  ------------------------
  ---- PVE WOTLK
  ------------------------
  {
    "Vault of Archavon Raid",
    -- -- Archavon the Stone Watcher
    { 58965, "CC" }, -- Choking Cloud (chance to hit with melee and ranged attacks reduced by 50%)
    { 61672, "CC" }, -- Choking Cloud (chance to hit with melee and ranged attacks reduced by 50%)
    { 58663, "CC" }, -- Stomp
    { 60880, "CC" }, -- Stomp
    -- -- Emalon the Storm Watcher
    { 63080, "CC" }, -- Stoned (!)
    -- -- Toravon the Ice Watcher
    { 72090, "Root" }, -- Freezing Ground
  },
  ------------------------
  {
    "Naxxramas (WotLK) Raid",
    -- -- Trash
    { 56427, "CC" }, -- War Stomp
    { 55314, "Silence" }, -- Strangulate
    { 55334, "Silence" }, -- Strangulate
    { 54722, "Immune" }, -- Stoneskin (not immune, big health regeneration)
    { 53803, "Other" }, -- Veil of Shadow
    { 55315, "Other" }, -- Bone Armor
    { 55336, "Other" }, -- Bone Armor
    { 55848, "Other" }, -- Invisibility
    { 54769, "Snare" }, -- Slime Burst
    { 54339, "Snare" }, -- Mind Flay
    { 29407, "Snare" }, -- Mind Flay
    { 54805, "Snare" }, -- Mind Flay
    -- -- Anub'Rekhan
    { 54022, "CC" }, -- Locust Swarm
    -- -- Grand Widow Faerlina
    { 54093, "Silence" }, -- Silence
    -- -- Maexxna
    { 54125, "CC" }, -- Web Spray
    { 54121, "Other" }, -- Necrotic Poison (healing taken reduced by 75%)
    -- -- Noth the Plaguebringer
    { 54814, "Snare" }, -- Cripple
    -- -- Heigan the Unclean
    { 29310, "Other" }, -- Spell Disruption (casting speed decreased by 300%)
    -- -- Loatheb
    { 55593, "Other" }, -- Necrotic Aura (healing taken reduced by 100%)
    -- -- Sapphiron
    { 55699, "Snare" }, -- Chill
    -- -- Kel'Thuzad
    { 55802, "Snare" }, -- Frostbolt
    { 55807, "Snare" }, -- Frostbolt
    ------------------------
    -- The Obsidian Sanctum Raid
    -- -- Trash
    { 57835, "Immune" }, -- Gift of Twilight
    { 39647, "Other" }, -- Curse of Mending (20% chance to heal enemy target on spell or melee hit)
    { 58948, "Other" }, -- Curse of Mending (20% chance to heal enemy target on spell or melee hit)
    { 57728, "CC" }, -- Shockwave
    { 58947, "CC" }, -- Shockwave
    -- -- Sartharion
    { 56910, "CC" }, -- Tail Lash
    { 58957, "CC" }, -- Tail Lash
    { 58766, "Immune" }, -- Gift of Twilight
    { 61632, "Other" }, -- Berserk
    { 57491, "Snare" }, -- Flame Tsunami
    ------------------------
    -- The Eye of Eternity Raid
    -- -- Malygos
    { 57108, "Immune" }, -- Flame Shield (not immune, damage taken decreased by 80%)
    { 55853, "Root" }, -- Vortex
    { 56263, "Root" }, -- Vortex
    { 56264, "Root" }, -- Vortex
    { 56265, "Root" }, -- Vortex
    { 56266, "Root" }, -- Vortex
    { 61071, "Root" }, -- Vortex
    { 61072, "Root" }, -- Vortex
    { 61073, "Root" }, -- Vortex
    { 61074, "Root" }, -- Vortex
    { 61075, "Root" }, -- Vortex
    { 56438, "Other" }, -- Arcane Overload (reduces magic damage taken by 50%)
    { 55849, "Other" }, -- Power Spark
    { 56152, "Other" }, -- Power Spark
    { 57060, "Other" }, -- Haste
    { 47008, "Other" }, -- Berserk
  },
  ------------------------
  {
    "Ulduar Raid",
    -- -- Trash
    { 64010, "CC" }, -- Nondescript
    { 64013, "CC" }, -- Nondescript
    { 64781, "CC" }, -- Charged Leap
    { 64819, "CC" }, -- Devastating Leap
    { 64942, "CC" }, -- Devastating Leap
    { 64649, "CC" }, -- Freezing Breath
    { 62310, "CC" }, -- Impale
    { 62928, "CC" }, -- Impale
    { 63713, "CC" }, -- Dominate Mind
    { 64918, "CC" }, -- Electro Shock
    { 64971, "CC" }, -- Electro Shock
    { 64647, "CC" }, -- Snow Blindness
    { 64654, "CC" }, -- Snow Blindness
    { 65078, "CC" }, -- Compacted
    { 65105, "CC" }, -- Compacted
    { 64697, "Silence" }, -- Earthquake
    { 64663, "Silence" }, -- Arcane Burst
    { 63710, "Immune" }, -- Void Barrier
    { 63784, "Immune" }, -- Bladestorm (not immune to dmg, only to LoC)
    { 63006, "Immune" }, -- Aggregation Pheromones (not immune, damage taken reduced by 90%)
    { 65070, "Immune" }, -- Defense Matrix (not immune, damage taken reduced by 90%)
    { 64903, "Root" }, -- Fuse Lightning
    { 64970, "Root" }, -- Fuse Lightning
    { 64877, "Root" }, -- Harden Fists
    { 63912, "Root" }, -- Frost Nova
    { 63272, "Other" }, -- Hurricane (slow attacks and spells by 67%)
    { 63557, "Other" }, -- Hurricane (slow attacks and spells by 67%)
    { 64644, "Other" }, -- Shield of the Winter Revenant (damage taken from AoE attacks reduced by 90%)
    { 63136, "Other" }, -- Winter's Embrace
    { 63564, "Other" }, -- Winter's Embrace
    { 63539, "Other" }, -- Separation Anxiety
    { 63630, "Other" }, -- Vengeful Surge
    { 62845, "Snare" }, -- Hamstring
    { 63913, "Snare" }, -- Frostbolt
    { 64645, "Snare" }, -- Cone of Cold
    { 64655, "Snare" }, -- Cone of Cold
    { 62287, "Snare" }, -- Tar
    -- -- Flame Leviathan
    { 62297, "CC" }, -- Hodir's Fury
    { 62475, "CC" }, -- Systems Shutdown
    -- -- Ignis the Furnace Master
    { 62717, "CC" }, -- Slag Pot
    { 65722, "CC" }, -- Slag Pot
    { 63477, "CC" }, -- Slag Pot
    { 65720, "CC" }, -- Slag Pot
    { 65723, "CC" }, -- Slag Pot
    { 62382, "CC" }, -- Brittle
    -- -- Razorscale
    { 62794, "CC" }, -- Stun Self
    { 64774, "CC" }, -- Fused Armor
    -- -- XT-002 Deconstructor
    { 63849, "Other" }, -- Exposed Heart
    { 62775, "Snare" }, -- Tympanic Tantrum
    -- -- Assembly of Iron
    { 61878, "CC" }, -- Overload
    { 63480, "CC" }, -- Overload
    --{64320    , "Other"},       -- Rune of Power
    { 63489, "Other" }, -- Shield of Runes
    { 62274, "Other" }, -- Shield of Runes
    { 63967, "Other" }, -- Shield of Runes
    { 62277, "Other" }, -- Shield of Runes
    { 61888, "Other" }, -- Overwhelming Power
    { 64637, "Other" }, -- Overwhelming Power
    -- -- Kologarn
    { 64238, "Other" }, -- Berserk
    { 62056, "CC" }, -- Stone Grip
    { 63985, "CC" }, -- Stone Grip
    { 64290, "CC" }, -- Stone Grip
    { 64292, "CC" }, -- Stone Grip
    -- -- Auriaya
    { 64386, "CC" }, -- Terrifying Screech
    { 64478, "CC" }, -- Feral Pounce
    { 64669, "CC" }, -- Feral Pounce
    -- -- Freya
    { 62532, "CC" }, -- Conservator's Grip
    { 62467, "CC" }, -- Drained of Power
    { 62283, "Root" }, -- Iron Roots
    { 62438, "Root" }, -- Iron Roots
    { 62861, "Root" }, -- Iron Roots
    { 62930, "Root" }, -- Iron Roots
    -- -- Hodir
    { 61968, "CC" }, -- Flash Freeze
    { 61969, "CC" }, -- Flash Freeze
    { 61170, "CC" }, -- Flash Freeze
    { 61990, "CC" }, -- Flash Freeze
    { 62469, "Root" }, -- Freeze
    -- -- Mimiron
    { 64436, "CC" }, -- Magnetic Core
    { 64616, "Silence" }, -- Deafening Siren
    { 64668, "Root" }, -- Magnetic Field
    { 64570, "Other" }, -- Flame Suppressant (casting speed slowed by 50%)
    { 65192, "Other" }, -- Flame Suppressant (casting speed slowed by 50%)
    -- -- Thorim
    { 62241, "CC" }, -- Paralytic Field
    { 63540, "CC" }, -- Paralytic Field
    { 62042, "CC" }, -- Stormhammer
    { 62332, "CC" }, -- Shield Smash
    { 62420, "CC" }, -- Shield Smash
    { 64151, "CC" }, -- Whirling Trip
    { 62316, "CC" }, -- Sweep
    { 62417, "CC" }, -- Sweep
    { 62276, "Immune" }, -- Sheath of Lightning (not immune, damage taken reduced by 99%)
    { 62338, "Immune" }, -- Runic Barrier (not immune, damage taken reduced by 50%)
    { 62321, "Immune" }, -- Runic Shield (not immune, physical damage taken reduced by 50% and absorbing magical damage)
    { 62529, "Immune" }, -- Runic Shield (not immune, physical damage taken reduced by 50% and absorbing magical damage)
    { 62470, "Other" }, -- Deafening Thunder (spell casting times increased by 75%)
    { 62555, "Other" }, -- Berserk
    { 62560, "Other" }, -- Berserk
    { 62526, "Root" }, -- Rune Detonation
    { 62605, "Root" }, -- Frost Nova
    { 62576, "Snare" }, -- Blizzard
    { 62602, "Snare" }, -- Blizzard
    { 62601, "Snare" }, -- Frostbolt
    { 62580, "Snare" }, -- Frostbolt Volley
    { 62604, "Snare" }, -- Frostbolt Volley
    -- -- General Vezax
    { 63364, "Immune" }, -- Saronite Barrier (not immune, damage taken reduced by 99%)
    { 63276, "Other" }, -- Mark of the Faceless
    { 62662, "Snare" }, -- Surge of Darkness
    -- -- Yogg-Saron
    { 64189, "CC" }, -- Deafening Roar
    { 64173, "CC" }, -- Shattered Illusion
    { 64155, "CC" }, -- Black Plague
    { 63830, "CC" }, -- Malady of the Mind
    { 63881, "CC" }, -- Malady of the Mind
    { 63042, "CC" }, -- Dominate Mind
    { 63120, "CC" }, -- Insane
    { 63894, "Immune" }, -- Shadowy Barrier
    { 64775, "Immune" }, -- Shadowy Barrier
    { 64175, "Immune" }, -- Flash Freeze
    { 64156, "Snare" }, -- Apathy
  },
  ------------------------
  {
    "Trial of the Crusader Raid",
    -- -- Northrend Beasts
    { 66407, "CC" }, -- Head Crack
    { 66689, "CC" }, -- Arctic Breath
    { 72848, "CC" }, -- Arctic Breath
    { 66770, "CC" }, -- Ferocious Butt
    { 66683, "CC" }, -- Massive Crash
    { 66758, "CC" }, -- Staggered Daze
    { 66830, "CC" }, -- Paralysis
    { 66759, "Other" }, -- Frothing Rage
    { 66823, "Snare" }, -- Paralytic Toxin
    -- -- Lord Jaraxxus
    { 66237, "CC" }, -- Incinerate Flesh (reduces damage dealt by 50%)
    { 66283, "CC" }, -- Spinning Pain Spike (!)
    { 66334, "Other" }, -- Mistress' Kiss
    { 66336, "Other" }, -- Mistress' Kiss
    -- -- Faction Champions
    { 65930, "CC" }, -- Intimidating Shout
    { 65931, "CC" }, -- Intimidating Shout
    { 65929, "CC" }, -- Charge Stun
    { 65809, "CC" }, -- Fear
    { 65820, "CC" }, -- Death Coil
    { 66054, "CC" }, -- Hex
    { 65960, "CC" }, -- Blind
    { 65545, "CC" }, -- Psychic Horror
    { 65543, "CC" }, -- Psychic Scream
    { 66008, "CC" }, -- Repentance
    { 66007, "CC" }, -- Hammer of Justice
    { 66613, "CC" }, -- Hammer of Justice
    { 65801, "CC" }, -- Polymorph
    { 65877, "CC" }, -- Wyvern Sting
    { 65859, "CC" }, -- Cyclone
    { 65935, "Disarm" }, -- Disarm
    { 65542, "Silence" }, -- Silence
    { 65813, "Silence" }, -- Unstable Affliction
    { 66018, "Silence" }, -- Strangulate
    { 65857, "Root" }, -- Entangling Roots
    { 66070, "Root" }, -- Entangling Roots (Nature's Grasp)
    { 66010, "Immune" }, -- Divine Shield
    { 65871, "Immune" }, -- Deterrence
    { 66023, "Immune" }, -- Icebound Fortitude (not immune, damage taken reduced by 45%)
    { 65544, "Immune" }, -- Dispersion (not immune, damage taken reduced by 90%)
    { 65947, "Immune" }, -- Bladestorm (not immune to dmg, only to LoC)
    { 66009, "Immune" }, -- Hand of Protection
    { 65961, "Immune" }, -- Cloak of Shadows
    { 66071, "Other" }, -- Nature's Grasp
    { 65883, "Other" }, -- Aimed Shot (healing effects reduced by 50%)
    { 65926, "Other" }, -- Mortal Strike (healing effects reduced by 50%)
    { 65962, "Other" }, -- Wound Poison (healing effects reduced by 50%)
    { 66011, "Other" }, -- Avenging Wrath
    { 65932, "Other" }, -- Retaliation
    --{65983    , "Other"},       -- Heroism
    --{65980    , "Other"},       -- Bloodlust
    { 66020, "Snare" }, -- Chains of Ice
    { 66207, "Snare" }, -- Wing Clip
    { 65488, "Snare" }, -- Mind Flay
    { 65815, "Snare" }, -- Curse of Exhaustion
    { 65807, "Snare" }, -- Frostbolt
    -- -- Twin Val'kyr
    { 65724, "Other" }, -- Empowered Darkness
    { 65748, "Other" }, -- Empowered Light
    { 65874, "Other" }, -- Shield of Darkness
    { 65858, "Other" }, -- Shield of Lights
    -- -- Anub'arak
    { 66012, "CC" }, -- Freezing Slash
    { 66193, "Snare" }, -- Permafrost
  },
  ------------------------
  {
    "Icecrown Citadel Raid",
    -- -- Trash
    { 71784, "CC" }, -- Hammer of Betrayal
    { 71785, "CC" }, -- Conflagration
    { 71592, "CC" }, -- Fel Iron Bomb
    { 71787, "CC" }, -- Fel Iron Bomb
    { 70410, "CC" }, -- Polymorph: Spider
    { 70645, "CC" }, -- Chains of Shadow
    { 70432, "CC" }, -- Blood Sap
    { 71010, "CC" }, -- Web Wrap
    { 71330, "CC" }, -- Ice Tomb
    { 69903, "CC" }, -- Shield Slam
    { 71123, "CC" }, -- Decimate
    { 71163, "CC" }, -- Devour Humanoid
    { 71298, "CC" }, -- Banish
    { 71443, "CC" }, -- Impaling Spear
    { 71847, "CC" }, -- Critter-Killer Attack
    { 71955, "CC" }, -- Focused Attacks
    { 70781, "CC" }, -- Light's Hammer Teleport
    { 70856, "CC" }, -- Oratory of the Damned Teleport
    { 70857, "CC" }, -- Rampart of Skulls Teleport
    { 70858, "CC" }, -- Deathbringer's Rise Teleport
    { 70859, "CC" }, -- Upper Spire Teleport
    { 70861, "CC" }, -- Sindragosa's Lair Teleport
    { 70860, "CC" }, -- Frozen Throne Teleport
    { 72106, "Disarm" }, -- Polymorph: Spider
    { 71325, "Disarm" }, -- Frostblade
    { 70714, "Immune" }, -- Icebound Armor
    { 71550, "Immune" }, -- Divine Shield
    { 71463, "Immune" }, -- Aether Shield
    { 69910, "Immune" }, -- Pain Suppression (not immune, damage taken reduced by 40%)
    { 69634, "Immune" }, -- Taste of Blood (not immune, damage taken reduced by 50%)
    { 72065, "Immune" }, -- Shroud of Protection
    { 72066, "Immune" }, -- Shroud of Spell Warding
    { 69901, "Immune" }, -- Spell Reflect
    { 70299, "Root" }, -- Siphon Essence
    { 70431, "Root" }, -- Shadowstep
    { 71320, "Root" }, -- Frost Nova
    { 70980, "Root" }, -- Web Wrap
    { 71327, "Root" }, -- Web
    { 71647, "Root" }, -- Ice Trap
    { 69483, "Other" }, -- Dark Reckoning
    { 71552, "Other" }, -- Mortal Strike (healing effects reduced by 50%)
    { 70711, "Other" }, -- Empowered Blood
    { 69871, "Other" }, -- Plague Stream
    { 70407, "Snare" }, -- Blast Wave
    { 69405, "Snare" }, -- Consuming Shadows
    { 71318, "Snare" }, -- Frostbolt
    { 61747, "Snare" }, -- Frostbolt
    { 69869, "Snare" }, -- Frostfire Bolt
    { 69927, "Snare" }, -- Avenger's Shield
    { 70536, "Snare" }, -- Spirit Alarm
    { 70545, "Snare" }, -- Spirit Alarm
    { 70546, "Snare" }, -- Spirit Alarm
    { 70547, "Snare" }, -- Spirit Alarm
    { 70739, "Snare" }, -- Geist Alarm
    { 70740, "Snare" }, -- Geist Alarm
    -- -- Lord Marrowgar
    { 69065, "CC" }, -- Impaled
    -- -- Lady Deathwhisper
    { 71289, "CC" }, -- Dominate Mind
    { 70768, "Immune" }, -- Shroud of the Occult (reflects harmful spells)
    { 71234, "Immune" }, -- Adherent's Determination (not immune, magic damage taken reduced by 99%)
    { 71235, "Immune" }, -- Adherent's Determination (not immune, physical damage taken reduced by 99%)
    { 71237, "Other" }, -- Curse of Torpor (ability cooldowns increased by 15 seconds)
    { 70674, "Other" }, -- Vampiric Might
    { 71420, "Snare" }, -- Frostbolt
    -- -- Gunship Battle
    { 69705, "CC" }, -- Below Zero
    { 69651, "Other" }, -- Wounding Strike (healing effects reduced by 40%)
    -- -- Deathbringer Saurfang
    { 70572, "CC" }, -- Grip of Agony
    { 72771, "Other" }, -- Scent of Blood (physical damage done increased by 300%)
    { 72769, "Snare" }, -- Scent of Blood
    -- -- Festergut
    { 72297, "CC" }, -- Malleable Goo (casting and attack speed reduced by 250%)
    { 69240, "CC" }, -- Vile Gas
    { 69248, "CC" }, -- Vile Gas
    -- -- Rotface
    { 72272, "CC" }, -- Vile Gas  (!)
    { 72274, "CC" }, -- Vile Gas
    { 69244, "Root" }, -- Vile Gas
    { 72276, "Root" }, -- Vile Gas
    { 69674, "Other" }, -- Mutated Infection (healing received reduced by 75%/-50%)
    { 69778, "Snare" }, -- Sticky Ooze
    { 69789, "Snare" }, -- Ooze Flood
    -- -- Professor Putricide
    { 70853, "CC" }, -- Malleable Goo (casting and attack speed reduced by 250%)
    { 71615, "CC" }, -- Tear Gas
    { 71618, "CC" }, -- Tear Gas
    { 71278, "CC" }, -- Choking Gas (reduces chance to hit by 75%/100%)
    { 71279, "CC" }, -- Choking Gas Explosion (reduces chance to hit by 75%/100%)
    { 70447, "Root" }, -- Volatile Ooze Adhesive
    { 70539, "Snare" }, -- Regurgitated Ooze
    -- -- Blood Prince Council
    { 71807, "Snare" }, -- Glittering Sparks
    -- -- Blood-Queen Lana'thel
    { 70923, "CC" }, -- Uncontrollable Frenzy
    { 73070, "CC" }, -- Incite Terror
    -- -- Valithria Dreamwalker
    --{70904    , "CC"},        -- Corruption
    { 70588, "Other" }, -- Suppression (healing taken reduced)
    { 70759, "Snare" }, -- Frostbolt Volley
    -- -- Sindragosa
    { 70157, "CC" }, -- Ice Tomb
    -- -- The Lich King
    { 71614, "CC" }, -- Ice Lock
    { 73654, "CC" }, -- Harvest Souls
    { 69242, "Silence" }, -- Soul Shriek
    { 72143, "Other" }, -- Enrage
    { 72679, "Other" }, -- Harvested Soul (increases all damage dealt by 200%/500%)
    { 73028, "Other" }, -- Harvested Soul (increases all damage dealt by 200%/500%)
  },
  ------------------------
  {
    "The Ruby Sanctum Raid",
    -- -- Trash
    { 74509, "CC" }, -- Repelling Wave
    { 74384, "CC" }, -- Intimidating Roar
    { 75417, "CC" }, -- Shockwave
    { 74456, "CC" }, -- Conflagration
    { 78722, "Other" }, -- Enrage
    { 75413, "Snare" }, -- Flame Wave
    -- -- Halion
    { 74531, "CC" }, -- Tail Lash
    { 74834, "Immune" }, -- Corporeality (not immune, damage taken reduced by 50%, damage dealt reduced by 30%)
    { 74835, "Immune" }, -- Corporeality (not immune, damage taken reduced by 80%, damage dealt reduced by 50%)
    { 74836, "Immune" }, -- Corporeality (damage taken reduced by 100%, damage dealt reduced by 70%)
    { 74830, "Other" }, -- Corporeality (damage taken increased by 200%, damage dealt increased by 100%)
    { 74831, "Other" }, -- Corporeality (damage taken increased by 400%, damage dealt increased by 200%)
  },
  ------------------------
  -- WotLK Dungeons
  {
    "The Culling of Stratholme",
    { 52696, "CC" }, -- Constricting Chains
    { 58823, "CC" }, -- Constricting Chains
    { 52711, "CC" }, -- Steal Flesh (damage dealt decreased by 75%)
    { 58848, "CC" }, -- Time Stop
    { 52721, "CC" }, -- Sleep
    { 58849, "CC" }, -- Sleep
    { 60451, "CC" }, -- Corruption of Time
    { 52634, "Immune" }, -- Void Shield (not immune, reduces damage taken by 50%)
    { 58813, "Immune" }, -- Void Shield (not immune, reduces damage taken by 75%)
    { 52317, "Immune" }, -- Defend (not immune, reduces physical damage taken by 50%)
    { 52491, "Root" }, -- Web Explosion
    { 52766, "Snare" }, -- Time Warp
    { 52657, "Snare" }, -- Temporal Vortex
    { 58816, "Snare" }, -- Temporal Vortex
    { 52498, "Snare" }, -- Cripple
    { 20828, "Snare" }, -- Cone of Cold
  },
  {
    "The Violet Hold",
    { 52719, "CC" }, -- Concussion Blow
    { 58526, "CC" }, -- Azure Bindings
    { 58537, "CC" }, -- Polymorph
    { 58534, "CC" }, -- Deep Freeze
    { 59820, "Immune" }, -- Drained
    { 54306, "Immune" }, -- Protective Bubble (not immune, reduces damage taken by 99%)
    { 60158, "Immune" }, -- Magic Reflection
    { 58458, "Root" }, -- Frost Nova
    { 59253, "Root" }, -- Frost Nova
    { 54462, "Snare" }, -- Howling Screech
    { 58693, "Snare" }, -- Blizzard
    { 59369, "Snare" }, -- Blizzard
    { 58463, "Snare" }, -- Cone of Cold
    { 58532, "Snare" }, -- Frostbolt Volley
    { 61594, "Snare" }, -- Frostbolt Volley
    { 58457, "Snare" }, -- Frostbolt
    { 58535, "Snare" }, -- Frostbolt
    { 59251, "Snare" }, -- Frostbolt
    { 61590, "Snare" }, -- Frostbolt
    { 20822, "Snare" }, -- Frostbolt
  },
  {
    "Azjol-Nerub",
    { 52087, "CC" }, -- Web Wrap
    { 52524, "CC" }, -- Blinding Webs
    { 59365, "CC" }, -- Blinding Webs
    { 53472, "CC" }, -- Pound
    { 59433, "CC" }, -- Pound
    { 52086, "Root" }, -- Web Wrap
    { 53322, "Root" }, -- Crushing Webs
    { 59347, "Root" }, -- Crushing Webs
    { 52586, "Snare" }, -- Mind Flay
    { 59367, "Snare" }, -- Mind Flay
    { 52592, "Snare" }, -- Curse of Fatigue
    { 59368, "Snare" }, -- Curse of Fatigue
  },
  {
    "Ahn'kahet: The Old Kingdom",
    { 55959, "CC" }, -- Embrace of the Vampyr
    { 59513, "CC" }, -- Embrace of the Vampyr
    { 57055, "CC" }, -- Mini (damage dealt reduced by 75%)
    { 61491, "CC" }, -- Intercept
    { 56153, "Immune" }, -- Guardian Aura
    { 55964, "Immune" }, -- Vanish
    { 57095, "Root" }, -- Entangling Roots
    { 56632, "Root" }, -- Tangled Webs
    { 56219, "Other" }, -- Gift of the Herald (damage dealt increased by 200%)
    { 57789, "Other" }, -- Mortal Strike (healing effects reduced by 50%)
    { 59995, "Root" }, -- Frost Nova
    { 61462, "Root" }, -- Frost Nova
    { 57629, "Root" }, -- Frost Nova
    { 57941, "Snare" }, -- Mind Flay
    { 59974, "Snare" }, -- Mind Flay
    { 57799, "Snare" }, -- Avenger's Shield
    { 59999, "Snare" }, -- Avenger's Shield
    { 57825, "Snare" }, -- Frostbolt
    { 61461, "Snare" }, -- Frostbolt
    { 57779, "Snare" }, -- Mind Flay
    { 60006, "Snare" }, -- Mind Flay
  },
  {
    "Utgarde Keep",
    { 42672, "CC" }, -- Frost Tomb
    { 48400, "CC" }, -- Frost Tomb
    { 43651, "CC" }, -- Charge
    { 35570, "CC" }, -- Charge
    { 59611, "CC" }, -- Charge
    { 42723, "CC" }, -- Dark Smash
    { 59709, "CC" }, -- Dark Smash
    { 43936, "CC" }, -- Knockdown Spin
    { 42972, "CC" }, -- Blind
    { 37578, "CC" }, -- Debilitating Strike (physical damage done reduced by 75%)
    { 42740, "Immune" }, -- Njord's Rune of Protection (not immune, big absorb)
    { 59616, "Immune" }, -- Njord's Rune of Protection (not immune, big absorb)
    { 43650, "Other" }, -- Debilitate
    { 59577, "Other" }, -- Debilitate
  },
  {
    "Utgarde Pinnacle",
    { 48267, "CC" }, -- Ritual Preparation
    { 48278, "CC" }, -- Paralyze
    { 50234, "CC" }, -- Crush
    { 59330, "CC" }, -- Crush
    { 51750, "CC" }, -- Screams of the Dead
    { 48131, "CC" }, -- Stomp
    { 48144, "CC" }, -- Terrifying Roar
    { 49106, "CC" }, -- Terrify
    { 49170, "CC" }, -- Lycanthropy
    { 49172, "Other" }, -- Wolf Spirit
    { 49173, "Other" }, -- Wolf Spirit
    { 48703, "CC" }, -- Fervor
    { 48702, "Other" }, -- Fervor
    { 48871, "Other" }, -- Aimed Shot (decreases healing received by 50%)
    { 59243, "Other" }, -- Aimed Shot (decreases healing received by 50%)
    { 49092, "Root" }, -- Net
    { 48639, "Snare" }, -- Hamstring
  },
  {
    "The Nexus",
    { 47736, "CC" }, -- Time Stop
    { 47731, "CC" }, -- Critter
    { 47772, "CC" }, -- Ice Nova
    { 56935, "CC" }, -- Ice Nova
    { 60067, "CC" }, -- Charge
    { 47700, "CC" }, -- Crystal Freeze
    { 55041, "CC" }, -- Freezing Trap Effect
    { 47781, "CC" }, -- Spellbreaker (damage from magical spells and effects reduced by 75%)
    { 47854, "CC" }, -- Frozen Prison
    { 47543, "CC" }, -- Frozen Prison
    { 47779, "Silence" }, -- Arcane Torrent
    { 56777, "Silence" }, -- Silence
    { 47748, "Immune" }, -- Rift Shield
    { 48082, "Immune" }, -- Seed Pod
    { 47981, "Immune" }, -- Spell Reflection
    { 47698, "Root" }, -- Crystal Chains
    { 50997, "Root" }, -- Crystal Chains
    { 57050, "Root" }, -- Crystal Chains
    { 48179, "Root" }, -- Crystallize
    { 61556, "Root" }, -- Tangle
    { 48053, "Snare" }, -- Ensnare
    { 56775, "Snare" }, -- Frostbolt
    { 56837, "Snare" }, -- Frostbolt
    { 12737, "Snare" }, -- Frostbolt
  },
  {
    "The Oculus",
    { 49838, "CC" }, -- Stop Time
    { 50731, "CC" }, -- Mace Smash
    { 50053, "Immune" }, -- Centrifuge Shield
    { 53813, "Immune" }, -- Arcane Shield
    { 50240, "Immune" }, -- Evasive Maneuvers
    { 51162, "Immune" }, -- Planar Shift
    { 50690, "Root" }, -- Immobilizing Field
    { 59260, "Root" }, -- Hooked Net
    { 51170, "Other" }, -- Enraged Assault
    { 50253, "Other" }, -- Martyr (harmful spells redirected to you)
    { 59370, "Snare" }, -- Thundering Stomp
    { 49549, "Snare" }, -- Ice Beam
    { 59211, "Snare" }, -- Ice Beam
    { 59217, "Snare" }, -- Thunderclap
    { 59261, "Snare" }, -- Water Tomb
    { 50721, "Snare" }, -- Frostbolt
    { 59280, "Snare" }, -- Frostbolt
  },
  {
    "Drak Tharon Keep",
    { 49356, "CC" }, -- Decay Flesh
    { 53463, "CC" }, -- Return Flesh
    { 51240, "CC" }, -- Fear
    { 49704, "Root" }, -- Encasing Webs
    { 49711, "Root" }, -- Hooked Net
    { 49721, "Silence" }, -- Deafening Roar
    { 59010, "Silence" }, -- Deafening Roar
    { 47346, "Snare" }, -- Arcane Field
    { 49037, "Snare" }, -- Frostbolt
    { 50378, "Snare" }, -- Frostbolt
    { 59017, "Snare" }, -- Frostbolt
    { 59855, "Snare" }, -- Frostbolt
    { 50379, "Snare" }, -- Cripple
  },
  {
    "Gundrak",
    { 55142, "CC" }, -- Ground Tremor
    { 55101, "CC" }, -- Quake
    { 55636, "CC" }, -- Shockwave
    { 58977, "CC" }, -- Shockwave
    { 55099, "CC" }, -- Snake Wrap
    { 61475, "CC" }, -- Snake Wrap
    { 55126, "CC" }, -- Snake Wrap
    { 61476, "CC" }, -- Snake Wrap
    { 54956, "CC" }, -- Impaling Charge
    { 59827, "CC" }, -- Impaling Charge
    { 55663, "Silence" }, -- Deafening Roar
    { 58992, "Silence" }, -- Deafening Roar
    { 55633, "Root" }, -- Body of Stone
    { 54716, "Other" }, -- Mortal Strikes (healing effects reduced by 50%)
    { 59455, "Other" }, -- Mortal Strikes (healing effects reduced by 75%)
    { 55816, "Other" }, -- Eck Berserk
    { 40546, "Other" }, -- Retaliation
    { 61362, "Snare" }, -- Blast Wave
    { 55250, "Snare" }, -- Whirling Slash
    { 59824, "Snare" }, -- Whirling Slash
    { 58975, "Snare" }, -- Thunderclap
  },
  {
    "Halls of Stone",
    { 50812, "CC" }, -- Stoned
    { 50760, "CC" }, -- Shock of Sorrow
    { 59726, "CC" }, -- Shock of Sorrow
    { 59865, "CC" }, -- Ground Smash
    { 51503, "CC" }, -- Domination
    { 51842, "CC" }, -- Charge
    { 59040, "CC" }, -- Charge
    { 51491, "CC" }, -- Unrelenting Strike
    { 59039, "CC" }, -- Unrelenting Strike
    { 59868, "Snare" }, -- Dark Matter
    { 50836, "Snare" }, -- Petrifying Grip
  },
  {
    "Halls of Lightning",
    { 53045, "CC" }, -- Sleep
    { 59165, "CC" }, -- Sleep
    { 59142, "CC" }, -- Shield Slam
    { 60236, "CC" }, -- Cyclone
    { 36096, "Immune" }, -- Spell Reflection
    { 53069, "Root" }, -- Runic Focus
    { 59153, "Root" }, -- Runic Focus
    { 61579, "Root" }, -- Runic Focus
    { 61596, "Root" }, -- Runic Focus
    { 52883, "Root" }, -- Counterattack
    { 59181, "Other" }, -- Deflection (parry chance increased by 40%)
    { 52773, "Snare" }, -- Hammer Blow
    { 23600, "Snare" }, -- Piercing Howl
    { 23113, "Snare" }, -- Blast Wave
  },
  {
    "Trial of the Champion",
    { 67745, "CC" }, -- Death's Respite
    { 66940, "CC" }, -- Hammer of Justice
    { 66862, "CC" }, -- Radiance
    { 66547, "CC" }, -- Confess
    { 66546, "CC" }, -- Holy Nova
    { 65918, "CC" }, -- Stunned
    { 67867, "CC" }, -- Trampled
    { 67868, "CC" }, -- Trampled
    { 67255, "CC" }, -- Final Meditation (movement, attack, and casting speeds reduced by 70%)
    { 67229, "CC" }, -- Mind Control
    { 66043, "CC" }, -- Polymorph
    { 66619, "CC" }, -- Shadows of the Past (attack and casting speeds reduced by 90%)
    { 66552, "CC" }, -- Waking Nightmare
    { 67541, "Immune" }, -- Bladestorm (not immune to dmg, only to LoC)
    { 66515, "Immune" }, -- Reflective Shield
    { 67251, "Immune" }, -- Divine Shield
    { 67534, "Other" }, -- Hex of Mending (direct heals received will heal all nearby enemies)
    { 67542, "Other" }, -- Mortal Strike (healing effects reduced by 50%)
    { 66045, "Other" }, -- Haste
    { 67781, "Snare" }, -- Desecration
    { 66044, "Snare" }, -- Blast Wave
  },
  {
    "The Forge of Souls",
    { 68950, "CC" }, -- Fear
    { 68848, "CC" }, -- Knockdown Stun
    { 69133, "CC" }, -- Lethargy
    { 69056, "Immune" }, -- Shroud of Runes
    { 69060, "Root" }, -- Frost Nova
    { 68839, "Other" }, -- Corrupt Soul
    { 69131, "Other" }, -- Soul Sickness
    { 69633, "Other" }, -- Veil of Shadow
    { 68921, "Snare" }, -- Soulstorm
  },
  {
    "Pit of Saron",
    { 68771, "CC" }, -- Thundering Stomp
    { 70380, "CC" }, -- Deep Freeze
    { 69245, "CC" }, -- Hoarfrost
    { 69503, "CC" }, -- Devour Humanoid
    { 70302, "CC" }, -- Blinding Dirt
    { 69572, "CC" }, -- Shovelled!
    { 70639, "CC" }, -- Call of Sylvanas
    { 70291, "Disarm" }, -- Frostblade
    { 69575, "Immune" }, -- Stoneform (not immune, damage taken reduced by 90%)
    { 70130, "Root" }, -- Empowered Blizzard
    { 69580, "Other" }, -- Shield Block (chance to block increased by 100%)
    { 69029, "Other" }, -- Pursuit Confusion
    { 69167, "Other" }, -- Unholy Power
    { 69172, "Other" }, -- Overlord's Brand
    { 70381, "Snare" }, -- Deep Freeze
    { 69238, "Snare" }, -- Icy Blast
    { 71380, "Snare" }, -- Icy Blast
    { 69573, "Snare" }, -- Frostbolt
    { 69413, "Silence" }, -- Strangulating
    { 70569, "Silence" }, -- Strangulating
    { 70616, "Snare" }, -- Frostfire Bolt
    { 51779, "Snare" }, -- Frostfire Bolt
    { 34779, "Root" }, -- Freezing Circle
    { 22645, "Root" }, -- Frost Nova
    { 22746, "Snare" }, -- Cone of Cold
  },
  {
    "Halls of Reflection",
    { 72435, "CC" }, -- Defiling Horror
    { 72428, "CC" }, -- Despair Stricken
    { 72321, "CC" }, -- Cower in Fear
    { 70194, "CC" }, -- Dark Binding
    { 69708, "CC" }, -- Ice Prison
    { 72343, "CC" }, -- Hallucination
    { 72335, "CC" }, -- Kidney Shot
    { 72268, "CC" }, -- Ice Shot
    { 69866, "CC" }, -- Harvest Soul
    { 72171, "Root" }, -- Chains of Ice
    { 69787, "Immune" }, -- Ice Barrier (not immune, absorbs a lot of damage)
    { 70188, "Immune" }, -- Cloak of Darkness
    { 69780, "Snare" }, -- Remorseless Winter
    { 72166, "Snare" }, -- Frostbolt
  },
  -- PvE
  --{123456 , "PvE"},       -- This is just an example}, not a real spell
  ------------------------
  ---- PVE TBC
  ------------------------
  {
    "Karazhan Raid",
    -- -- Trash
    { 18812, "CC" }, -- Knockdown
    { 29684, "CC" }, -- Shield Slam
    { 29679, "CC" }, -- Bad Poetry
    { 29676, "CC" }, -- Rolling Pin
    { 29490, "CC" }, -- Seduction
    { 29300, "CC" }, -- Sonic Blast
    { 29321, "CC" }, -- Fear
    { 29546, "CC" }, -- Oath of Fealty
    { 29670, "CC" }, -- Ice Tomb
    { 29690, "CC" }, -- Drunken Skull Crack
    { 29486, "Warning" }, -- Bewitching Aura (spell damage done reduced by 50%)
    { 29485, "Warning" }, -- Alluring Aura (physical damage done reduced by 50%)
    { 37498, "CC" }, -- Stomp (physical damage done reduced by 50%)
    { 41580, "Root" }, -- Net
    { 29505, "Silence" }, -- Banshee Shriek
    { 30013, "Disarm" }, -- Disarm
    --{30019  , "CC"},        -- Control Piece
    --{39331  , "Silence"},     -- Game In Session

    -- -- Servant Quarters
    { 29896, "CC" }, -- Hyakiss' Web
    { 29904, "Silence" }, -- Sonic Burst
    -- -- Attumen the Huntsman
    { 29711, "CC" }, -- Knockdown
    { 29833, "CC" }, -- Intangible Presence (chance to hit with spells and melee attacks reduced by 50%)
    -- -- Moroes
    { 29425, "CC" }, -- Gouge
    { 34694, "CC" }, -- Blind
    -- -- Maiden of Virtue
    { 29511, "CC" }, -- Repentance
    { 29512, "Silence" }, -- Holy Ground
    -- -- Opera Event
    { 31046, "CC" }, -- Brain Bash
    { 30889, "CC" }, -- Powerful Attraction
    { 30761, "CC" }, -- Wide Swipe
    { 31013, "CC" }, -- Frightened Scream
    { 30752, "CC" }, -- Terrifying Howl
    { 31075, "CC" }, -- Burning Straw
    { 30753, "CC" }, -- Red Riding Hood
    { 30756, "CC" }, -- Little Red Riding Hood
    { 31015, "CC" }, -- Annoying Yipping
    { 31069, "Silence" }, -- Brain Wipe
    -- -- The Curator
    { 30254, "CC" }, -- Evocation
    -- -- Terestian Illhoof
    { 30115, "CC" }, -- Sacrifice
    -- -- Shade of Aran
    { 29964, "CC" }, -- Dragon's Breath
    { 29963, "CC" }, -- Mass Polymorph
    { 29991, "Root" }, -- Chains of Ice

    -- -- Nightbane
    { 36922, "CC" }, -- Bellowing Roar
    { 30130, "CC" }, -- Distracting Ash (chance to hit with attacks}, spells and abilities reduced by 30%)
    -- -- Prince Malchezaar
  },
  ------------------------
  {
    "Gruul's Lair Raid",
    -- -- Trash
    { 33709, "CC" }, -- Charge
    -- -- High King Maulgar & Council
    { 33173, "CC" }, -- Greater Polymorph
    { 33130, "CC" }, -- Death Coil
    { 33175, "Disarm" }, -- Arcane Shock
    -- -- Gruul the Dragonkiller
    { 33652, "CC" }, -- Stoned
    { 36297, "Silence" }, -- Reverberation
    ------------------------
    -- -- Magtheridon’s Lair Raid
    -- -- Trash
    { 34437, "CC" }, -- Death Coil
    --{31117  , "Silence"},     -- Unstable Affliction
    -- -- Magtheridon
    { 30530, "CC" }, -- Fear
    { 30168, "CC" }, -- Shadow Cage
    { 30205, "CC" }, -- Shadow Cage
  },
  ------------------------
  {
    "Serpentshrine Cavern Raid",
    -- -- Trash
    { 38945, "CC" }, -- Frightening Shout
    { 38946, "CC" }, -- Frightening Shout
    { 38626, "CC" }, -- Domination
    { 39002, "CC" }, -- Spore Quake Knockdown
    { 38661, "Root" }, -- Net
    { 39035, "Root" }, -- Frost Nova
    { 39063, "Root" }, -- Frost Nova
    { 38634, "Silence" }, -- Arcane Lightning
    { 38491, "Silence" }, -- Silence

    -- -- Hydross the Unstable
    { 38246, "CC" }, -- Vile Sludge (damage and healing dealt is reduced by 50%)
    -- -- Leotheras the Blind
    { 37749, "CC" }, -- Consuming Madness
    -- -- Fathom-Lord Karathress
    { 38441, "CC" }, -- Cataclysmic Bolt
    -- -- Morogrim Tidewalker
    { 37871, "CC" }, -- Freeze
    { 37850, "CC" }, -- Watery Grave
    { 38023, "CC" }, -- Watery Grave
    { 38024, "CC" }, -- Watery Grave
    { 38025, "CC" }, -- Watery Grave
    { 38049, "CC" }, -- Watery Grave
    -- -- Lady Vashj
    { 38509, "CC" }, -- Shock Blast
    { 38511, "CC" }, -- Persuasion
    { 38258, "CC" }, -- Panic
    { 38316, "Root" }, -- Entangle
    { 38132, "Root" }, -- Paralyze (Tainted Core item)
  },
  ------------------------
  {
    "The Eye (Tempest Keep) Raid",
    -- -- Trash
    { 34937, "CC" }, -- Powered Down
    { 37122, "CC" }, -- Domination
    { 37135, "CC" }, -- Domination
    { 37118, "CC" }, -- Shell Shock
    { 39077, "CC" }, -- Hammer of Justice
    { 37160, "Silence" }, -- Silence

    -- -- Void Reaver
    { 34190, "Silence" }, -- Arcane Orb
    -- -- Kael'thas
    { 36834, "CC" }, -- Arcane Disruption
    { 37018, "CC" }, -- Conflagration
    { 44863, "CC" }, -- Bellowing Roar
    { 36797, "CC" }, -- Mind Control
    { 37029, "CC" }, -- Remote Toy
    { 36989, "Root" }, -- Frost Nova
  },
  ------------------------
  {
    "Black Temple Raid",
    -- -- Trash
    { 41345, "CC" }, -- Infatuation
    { 39645, "CC" }, -- Shadow Inferno
    { 41150, "CC" }, -- Fear
    { 39574, "CC" }, -- Charge
    { 39674, "CC" }, -- Banish
    { 40936, "CC" }, -- War Stomp
    { 41197, "CC" }, -- Shield Bash
    { 41272, "CC" }, -- Behemoth Charge
    { 41274, "CC" }, -- Fel Stomp
    { 41338, "CC" }, -- Love Tap
    { 41396, "CC" }, -- Sleep
    { 41356, "CC" }, -- Chest Pains
    { 41213, "CC" }, -- Throw Shield
    { 40864, "CC" }, -- Throbbing Stun
    { 41334, "CC" }, -- Polymorph
    { 40099, "CC" }, -- Vile Slime (damage and healing dealt reduced by 50%)
    { 40079, "CC" }, -- Debilitating Spray (damage and healing dealt reduced by 50%)
    { 39584, "Root" }, -- Sweeping Wing Clip
    { 40082, "Root" }, -- Hooked Net
    { 41086, "Root" }, -- Ice Trap

    { 41062, "Disarm" }, -- Disarm
    { 36139, "Disarm" }, -- Disarm
    { 41084, "Silence" }, -- Silencing Shot
    { 41168, "Silence" }, -- Sonic Strike
    -- -- High Warlord Naj'entus
    { 39837, "CC" }, -- Impaling Spine
    -- -- Supremus
    -- -- Shade of Akama
    { 41179, "CC" }, -- Debilitating Strike (physical damage done reduced by 75%)
    -- -- Teron Gorefiend
    { 40175, "CC" }, -- Spirit Chains
    -- -- Gurtogg Bloodboil
    { 40597, "CC" }, -- Eject
    { 40491, "CC" }, -- Bewildering Strike
    { 40569, "Root" }, -- Fel Geyser
    { 40591, "CC" }, -- Fel Geyser
    -- -- Reliquary of the Lost
    { 41426, "CC" }, -- Spirit Shock
    -- -- Mother Shahraz
    { 40823, "Silence" }, -- Silencing Shriek
    -- -- The Illidari Council
    { 41468, "CC" }, -- Hammer of Justice
    { 41479, "CC" }, -- Vanish
    -- -- Illidan
    { 40647, "CC" }, -- Shadow Prison
    { 41083, "CC" }, -- Paralyze
    { 40620, "CC" }, -- Eyebeam
    { 40695, "CC" }, -- Caged
    { 40760, "CC" }, -- Cage Trap
    { 41218, "CC" }, -- Death
    { 41220, "CC" }, -- Death
    { 41221, "CC" }, -- Teleport Maiev
  },
  ------------------------
  {
    "Hyjal Summit Raid",
    -- -- Trash
    { 31755, "CC" }, -- War Stomp
    { 31610, "CC" }, -- Knockdown
    { 31537, "CC" }, -- Cannibalize
    { 31302, "CC" }, -- Inferno Effect
    { 31651, "CC" }, -- Banshee Curse (chance to hit reduced by 66%)
    { 42201, "Silence" }, -- Eternal Silence
    { 42205, "Silence" }, -- Residue of Eternity

    -- -- Rage Winterchill
    { 31249, "CC" }, -- Icebolt
    { 31250, "Root" }, -- Frost Nova
    -- -- Anetheron
    { 31298, "CC" }, -- Sleep
    -- -- Kaz'rogal
    { 31480, "CC" }, -- War Stomp
    -- -- Azgalor
    { 31344, "Silence" }, -- Howl of Azgalor
    -- -- Archimonde
    { 31970, "CC" }, -- Fear
    { 32053, "Silence" }, -- Soul Charge
  },
  ------------------------
  {
    "Zul'Aman Raid",
    -- -- Trash
    { 43356, "CC" }, -- Pounce
    { 43361, "CC" }, -- Domesticate
    { 42220, "CC" }, -- Conflagration
    { 35011, "CC" }, -- Knockdown
    { 43362, "Root" }, -- Electrified Net

    -- -- Akil'zon
    { 43648, "CC" }, -- Electrical Storm
    -- -- Nalorakk
    { 42398, "Silence" }, -- Deafening Roar
    -- -- Hex Lord Malacrass
    { 43590, "CC" }, -- Psychic Wail
    -- -- Daakara
    { 43437, "CC" }, -- Paralyzed
  },
  ------------------------
  {
    "Sunwell Plateau Raid",
    -- -- Trash
    { 46762, "CC" }, -- Shield Slam
    { 46288, "CC" }, -- Petrify
    { 46239, "CC" }, -- Bear Down
    { 46561, "CC" }, -- Fear
    { 46427, "CC" }, -- Domination
    { 46280, "CC" }, -- Polymorph
    { 46295, "CC" }, -- Hex
    { 46681, "CC" }, -- Scatter Shot
    { 45029, "CC" }, -- Corrupting Strike
    { 44872, "CC" }, -- Frost Blast
    { 45201, "CC" }, -- Frost Blast
    { 45203, "CC" }, -- Frost Blast
    { 46555, "Root" }, -- Frost Nova

    -- -- Kalecgos & Sathrovarr
    { 45066, "CC" }, -- Self Stun
    { 45002, "CC" }, -- Wild Magic (chance to hit with melee and ranged attacks reduced by 50%)
    { 45122, "CC" }, -- Tail Lash
    -- -- Felmyst
    { 46411, "CC" }, -- Fog of Corruption
    { 45717, "CC" }, -- Fog of Corruption
    -- -- Grand Warlock Alythess & Lady Sacrolash
    { 45256, "CC" }, -- Confounding Blow
    { 45342, "CC" }, -- Conflagration
    -- -- M'uru
    { 46102, "Root" }, -- Spell Fury

    -- -- Kil'jaeden
    { 37369, "CC" }, -- Hammer of Justice
  },
  ------------------------
  ------------------------
  -- TBC Dungeons
  {
    "Hellfire Ramparts",
    { 39427, "CC" }, -- Bellowing Roar
    { 30615, "CC" }, -- Fear
    { 30621, "CC" }, -- Kidney Shot
  },
  {
    "The Blood Furnace",
    { 30923, "CC" }, -- Domination
    { 31865, "CC" }, -- Seduction
  },
  {
    "The Shattered Halls",
    { 30500, "CC" }, -- Death Coil
    { 30741, "CC" }, -- Death Coil
    { 30584, "CC" }, -- Fear
    { 37511, "CC" }, -- Charge
    { 23601, "CC" }, -- Scatter Shot
    { 30980, "CC" }, -- Sap
    { 30986, "CC" }, -- Cheap Shot
  },
  {
    "The Slave Pens",
    { 34984, "CC" }, -- Psychic Horror
    { 32173, "Root" }, -- Entangling Roots
    { 31983, "Root" }, -- Earthgrab
    { 32192, "Root" }, -- Frost Nova
  },
  {
    "The Underbog",
    { 31428, "CC" }, -- Sneeze
    { 31932, "CC" }, -- Freezing Trap Effect
    { 35229, "CC" }, -- Sporeskin (chance to hit with attacks}, spells and abilities reduced by 35%)
    { 31673, "Root" }, -- Foul Spores
  },
  {
    "The Steamvault",
    { 31718, "CC" }, -- Enveloping Winds
    { 38660, "CC" }, -- Fear
    { 35107, "Root" }, -- Electrified Net
  },
  {
    "Mana-Tombs",
    { 32361, "CC" }, -- Crystal Prison
    { 34322, "CC" }, -- Psychic Scream
    { 33919, "CC" }, -- Earthquake
    { 34940, "CC" }, -- Gouge
    { 32365, "Root" }, -- Frost Nova
    { 34922, "Silence" }, -- Shadows Embrace
  },
  {
    "Auchenai Crypts",
    { 32421, "CC" }, -- Soul Scream
    { 32830, "CC" }, -- Possess
    { 32859, "Root" }, -- Falter
    { 33401, "Root" }, -- Possess
    { 32346, "CC" }, -- Stolen Soul (damage and healing done reduced by 50%)
  },
  {
    "Sethekk Halls",
    { 40305, "CC" }, -- Power Burn
    { 40184, "CC" }, -- Paralyzing Screech
    { 43309, "CC" }, -- Polymorph
    { 38245, "CC" }, -- Polymorph
    { 40321, "CC" }, -- Cyclone of Feathers
    { 35120, "CC" }, -- Charm
    { 32654, "CC" }, -- Talon of Justice
    { 32690, "Silence" }, -- Arcane Lightning
    { 38146, "Silence" }, -- Arcane Lightning
  },
  {
    "Shadow Labyrinth",
    { 33547, "CC" }, -- Fear
    { 38791, "CC" }, -- Banish
    { 33563, "CC" }, -- Draw Shadows
    { 33684, "CC" }, -- Incite Chaos
    { 33502, "CC" }, -- Brain Wash
    { 33332, "CC" }, -- Suppression Blast
    { 33686, "Silence" }, -- Shockwave
    { 33499, "Silence" }, -- Shape of the Beast
  },
  {
    "Old Hillsbrad Foothills",
    { 33789, "CC" }, -- Frightening Shout
    { 50733, "CC" }, -- Scatter Shot
    { 32890, "CC" }, -- Knockout
    { 32864, "CC" }, -- Kidney Shot
    { 41389, "CC" }, -- Kidney Shot
    { 50762, "Root" }, -- Net
    { 12024, "Root" }, -- Net
  },
  {
    "The Black Morass",
    { 31422, "CC" }, -- Time Stop
  },
  {
    "The Mechanar",
    { 35250, "CC" }, -- Dragon's Breath
    { 35326, "CC" }, -- Hammer Punch
    { 35280, "CC" }, -- Domination
    { 35049, "CC" }, -- Pound
    { 35783, "CC" }, -- Knockdown
    { 36333, "CC" }, -- Anesthetic
    { 35268, "CC" }, -- Inferno
    { 36022, "Silence" }, -- Arcane Torrent
    { 35055, "Disarm" }, -- The Claw
  },
  {
    "The Arcatraz",
    { 36924, "CC" }, -- Mind Rend
    { 39017, "CC" }, -- Mind Rend
    { 39415, "CC" }, -- Fear
    { 37162, "CC" }, -- Domination
    { 36866, "CC" }, -- Domination
    { 39019, "CC" }, -- Complete Domination
    { 38850, "CC" }, -- Deafening Roar
    { 36887, "CC" }, -- Deafening Roar
    { 36700, "CC" }, -- Hex
    { 36840, "CC" }, -- Polymorph
    { 38896, "CC" }, -- Polymorph
    { 36634, "CC" }, -- Emergence
    { 36719, "CC" }, -- Explode
    { 38830, "CC" }, -- Explode
    { 36835, "CC" }, -- War Stomp
    { 38911, "CC" }, -- War Stomp
    { 36862, "CC" }, -- Gouge
    { 36778, "CC" }, -- Soul Steal (physical damage done reduced by 45%)
    { 35963, "Root" }, -- Improved Wing Clip
    { 36512, "Root" }, -- Knock Away
    { 36827, "Root" }, -- Hooked Net
    { 38912, "Root" }, -- Hooked Net
    { 37480, "Root" }, -- Bind
    { 38900, "Root" }, -- Bind
  },
  {
    "The Botanica",
    { 34716, "CC" }, -- Stomp
    { 34661, "CC" }, -- Sacrifice
    { 32323, "CC" }, -- Charge
    { 34639, "CC" }, -- Polymorph
    { 34752, "CC" }, -- Freezing Touch
    { 34770, "CC" }, -- Plant Spawn Effect
    { 34801, "CC" }, -- Sleep
    { 22127, "Root" }, -- Entangling Roots
  },
  {
    "Magisters' Terrace",
    { 47109, "CC" }, -- Power Feedback
    { 44233, "CC" }, -- Power Feedback
    { 46183, "CC" }, -- Knockdown
    { 46026, "CC" }, -- War Stomp
    { 46024, "CC" }, -- Fel Iron Bomb
    { 46184, "CC" }, -- Fel Iron Bomb
    { 44352, "CC" }, -- Overload
    { 38595, "CC" }, -- Fear
    { 44320, "CC" }, -- Mana Rage
    { 44547, "CC" }, -- Deadly Embrace
    { 44765, "CC" }, -- Banish
    { 44177, "Root" }, -- Frost Nova
    { 47168, "Root" }, -- Improved Wing Clip
    { 46182, "Silence" }, -- Snap Kick
  },
  ------------------------
  ---- PVE CLASSIC
  ------------------------
  {
    "Molten Core Raid",
    -- -- Trash
    { 19364, "CC" }, -- Ground Stomp
    { 19369, "CC" }, -- Ancient Despair
    { 19641, "CC" }, -- Pyroclast Barrage
    { 20276, "CC" }, -- Knockdown
    { 19393, "Silence" }, -- Soul Burn
    { 19636, "Root" }, -- Fire Blossom
    -- -- Lucifron
    { 20604, "CC" }, -- Dominate Mind
    -- -- Magmadar
    { 19408, "CC" }, -- Panic
    -- -- Gehennas
    { 20277, "CC" }, -- Fist of Ragnaros
    -- -- Garr
    -- -- Shazzrah
    -- -- Baron Geddon
    { 19695, "CC" }, -- Inferno
    { 20478, "CC" }, -- Armageddon
    -- -- Golemagg the Incinerator
    -- -- Sulfuron Harbinger
    { 19780, "CC" }, -- Hand of Ragnaros
    -- -- Majordomo Executus
  },
  ------------------------
  {
    "Onyxia's Lair Raid",
    -- -- Onyxia
    { 18431, "CC" }, -- Bellowing Roar
    ------------------------
    -- Blackwing Lair Raid
    -- -- Trash
    { 24375, "CC" }, -- War Stomp
    { 22289, "CC" }, -- Brood Power: Green
    { 22291, "CC" }, -- Brood Power: Bronze
    { 22561, "CC" }, -- Brood Power: Green
    -- -- Razorgore the Untamed
    { 19872, "CC" }, -- Calm Dragonkin
    { 23023, "CC" }, -- Conflagration
    { 15593, "CC" }, -- War Stomp
    { 16740, "CC" }, -- War Stomp
    { 28725, "CC" }, -- War Stomp
    { 14515, "CC" }, -- Dominate Mind
    { 22274, "CC" }, -- Greater Polymorph
    -- -- Broodlord Lashlayer
    -- -- Chromaggus
    { 23310, "CC" }, -- Time Lapse
    { 23312, "CC" }, -- Time Lapse
    { 23174, "CC" }, -- Chromatic Mutation
    { 23171, "CC" }, -- Time Stop (Brood Affliction: Bronze)
    -- -- Nefarian
    { 22666, "Silence" }, -- Silence
    { 22667, "CC" }, -- Shadow Command
    { 22686, "CC" }, -- Bellowing Roar
    { 22678, "CC" }, -- Fear
    { 23603, "CC" }, -- Wild Polymorph
    { 23364, "CC" }, -- Tail Lash
    { 23365, "Disarm" }, -- Dropped Weapon
    { 23414, "Root" }, -- Paralyze
  },
  ------------------------
  {
    "Zul'Gurub Raid",
    -- -- Trash
    { 24619, "Silence" }, -- Soul Tap
    { 24048, "CC" }, -- Whirling Trip
    { 24600, "CC" }, -- Web Spin
    { 24335, "CC" }, -- Wyvern Sting
    { 24020, "CC" }, -- Axe Flurry
    { 24671, "CC" }, -- Snap Kick
    { 24333, "CC" }, -- Ravage
    { 6869, "CC" }, -- Fall down
    { 24053, "CC" }, -- Hex
    -- -- High Priestess Jeklik
    { 23918, "Silence" }, -- Sonic Burst
    { 22884, "CC" }, -- Psychic Scream
    { 22911, "CC" }, -- Charge
    { 23919, "CC" }, -- Swoop
    { 26044, "CC" }, -- Mind Flay
    -- -- High Priestess Mar'li
    { 24110, "Silence" }, -- Enveloping Webs
    -- -- High Priest Thekal
    { 21060, "CC" }, -- Blind
    { 12540, "CC" }, -- Gouge
    { 24193, "CC" }, -- Charge
    -- -- Bloodlord Mandokir & Ohgan
    { 24408, "CC" }, -- Charge
    -- -- Gahz'ranka
    -- -- Jin'do the Hexxer
    { 17172, "CC" }, -- Hex
    { 24261, "CC" }, -- Brain Wash
    -- -- Edge of Madness: Gri'lek}, Hazza'rah}, Renataki}, Wushoolay
    { 24648, "Root" }, -- Entangling Roots
    { 24664, "CC" }, -- Sleep
    -- -- Hakkar
    { 24687, "Silence" }, -- Aspect of Jeklik
    { 24686, "CC" }, -- Aspect of Mar'li
    { 24690, "CC" }, -- Aspect of Arlokk
    { 24327, "CC" }, -- Cause Insanity
    { 24178, "CC" }, -- Will of Hakkar
    { 24322, "CC" }, -- Blood Siphon
    { 24323, "CC" }, -- Blood Siphon
    { 24324, "CC" }, -- Blood Siphon
  },
  ------------------------
  {
    "Ruins of Ahn'Qiraj Raid",
    -- -- Trash
    { 25371, "CC" }, -- Consume
    { 26196, "CC" }, -- Consume
    { 25654, "CC" }, -- Tail Lash
    { 25515, "CC" }, -- Bash
    { 25756, "CC" }, -- Purge
    -- -- Kurinnaxx
    { 25656, "CC" }, -- Sand Trap
    -- -- General Rajaxx
    { 19134, "CC" }, -- Frightening Shout
    { 29544, "CC" }, -- Frightening Shout
    { 25425, "CC" }, -- Shockwave
    -- -- Moam
    { 25685, "CC" }, -- Energize
    { 28450, "CC" }, -- Arcane Explosion
    -- -- Ayamiss the Hunter
    { 25852, "CC" }, -- Lash
    { 6608, "Disarm" }, -- Dropped Weapon
    { 25725, "CC" }, -- Paralyze
    -- -- Ossirian the Unscarred
    { 25189, "CC" }, -- Enveloping Winds
  },
  ------------------------
  {
    "Temple of Ahn'Qiraj Raid",
    -- -- Trash
    { 7670, "CC" }, -- Explode
    { 18327, "Silence" }, -- Silence
    { 26069, "Silence" }, -- Silence
    { 26070, "CC" }, -- Fear
    { 26072, "CC" }, -- Dust Cloud
    { 25698, "CC" }, -- Explode
    { 26079, "CC" }, -- Cause Insanity
    { 26049, "CC" }, -- Mana Burn
    { 26552, "CC" }, -- Nullify
    { 26071, "Root" }, -- Entangling Roots
    -- -- The Prophet Skeram
    { 785, "CC" }, -- True Fulfillment
    -- -- Bug Trio: Yauj}, Vem}, Kri
    { 3242, "CC" }, -- Ravage
    { 26580, "CC" }, -- Fear
    { 19128, "CC" }, -- Knockdown
    -- -- Fankriss the Unyielding
    { 720, "CC" }, -- Entangle
    { 731, "CC" }, -- Entangle
    { 1121, "CC" }, -- Entangle
    -- -- Viscidus
    { 25937, "CC" }, -- Viscidus Freeze
    -- -- Princess Huhuran
    { 26180, "CC" }, -- Wyvern Sting
    { 26053, "Silence" }, -- Noxious Poison
    -- -- Twin Emperors: Vek'lor & Vek'nilash
    { 800, "CC" }, -- Twin Teleport
    { 804, "Root" }, -- Explode Bug
    { 12241, "Root" }, -- Twin Colossals Teleport
    { 12242, "Root" }, -- Twin Colossals Teleport
    -- -- Ouro
    { 26102, "CC" }, -- Sand Blast
    -- -- C'Thun
  },
  ------------------------
  {
    "Naxxramas (Classic) Raid",
    -- -- Trash
    { 6605, "CC" }, -- Terrifying Screech
    { 27758, "CC" }, -- War Stomp
    { 27990, "CC" }, -- Fear
    { 28412, "CC" }, -- Death Coil
    { 29848, "CC" }, -- Polymorph
    { 29849, "Root" }, -- Frost Nova
    { 30094, "Root" }, -- Frost Nova
    -- -- Anub'Rekhan
    { 28786, "CC" }, -- Locust Swarm
    { 25821, "CC" }, -- Charge
    { 28991, "Root" }, -- Web
    -- -- Grand Widow Faerlina
    { 30225, "Silence" }, -- Silence
    -- -- Maexxna
    { 28622, "CC" }, -- Web Wrap
    { 29484, "CC" }, -- Web Spray
    -- -- Noth the Plaguebringer
    -- -- Heigan the Unclean
    { 30112, "CC" }, -- Frenzied Dive
    -- -- Instructor Razuvious
    -- -- Gothik the Harvester
    { 11428, "CC" }, -- Knockdown
    -- -- Gluth
    { 29685, "CC" }, -- Terrifying Roar
    -- -- Sapphiron
    { 28522, "CC" }, -- Icebolt
    -- -- Kel'Thuzad
    { 28410, "CC" }, -- Chains of Kel'Thuzad
    { 27808, "CC" }, -- Frost Blast
  },
  ------------------------
  {
    "Classic World Bosses",
    -- -- Azuregos
    { 23186, "CC" }, -- Aura of Frost
    { 21099, "CC" }, -- Frost Breath
    -- -- Doom Lord Kazzak & Highlord Kruul
    -- -- Dragons of Nightmare
    { 25043, "CC" }, -- Aura of Nature
    { 24778, "CC" }, -- Sleep (Dream Fog)
    { 24811, "CC" }, -- Draw Spirit
    { 25806, "CC" }, -- Creature of Nightmare
    { 12528, "Silence" }, -- Silence
    { 23207, "Silence" }, -- Silence
    { 29943, "Silence" }, -- Silence
  },
  ------------------------
  -- Classic Dungeons
  {
    "Ragefire Chasm",
    { 8242, "CC" }, -- Shield Slam
  },
  {
    "The Deadmines",
    { 6304, "CC" }, -- Rhahk'Zor Slam
    { 6713, "Disarm" }, -- Disarm
    { 7399, "CC" }, -- Terrify
    { 6435, "CC" }, -- Smite Slam
    { 6432, "CC" }, -- Smite Stomp
    { 113, "Root" }, -- Chains of Ice
    { 512, "Root" }, -- Chains of Ice
    { 228, "CC" }, -- Polymorph: Chicken
    { 6466, "CC" }, -- Axe Toss
  },
  {
    "Wailing Caverns",
    { 8040, "CC" }, -- Druid's Slumber
    { 8142, "Root" }, -- Grasping Vines
    { 5164, "CC" }, -- Knockdown
    { 7967, "CC" }, -- Naralex's Nightmare
    { 6271, "CC" }, -- Naralex's Awakening
    { 8150, "CC" }, -- Thundercrack
  },
  {
    "Shadowfang Keep",
    { 7295, "Root" }, -- Soul Drain
    { 7587, "Root" }, -- Shadow Port
    { 7136, "Root" }, -- Shadow Port
    { 7586, "Root" }, -- Shadow Port
    { 7139, "CC" }, -- Fel Stomp
    { 13005, "CC" }, -- Hammer of Justice
    { 7621, "CC" }, -- Arugal's Curse
    { 7803, "CC" }, -- Thundershock
    { 7074, "Silence" }, -- Screams of the Past
  },
  {
    "Blackfathom Deeps",
    { 15531, "Root" }, -- Frost Nova
    { 6533, "Root" }, -- Net
    { 8399, "CC" }, -- Sleep
    { 8379, "Disarm" }, -- Disarm
    { 8391, "CC" }, -- Ravage
    { 7645, "CC" }, -- Dominate Mind
  },
  {
    "The Stockade",
    { 7964, "CC" }, -- Smoke Bomb
    { 6253, "CC" }, -- Backhand
  },
  {
    "Gnomeregan",
    { 10737, "CC" }, -- Hail Storm
    { 15878, "CC" }, -- Ice Blast
    { 10856, "CC" }, -- Link Dead
    { 11820, "Root" }, -- Electrified Net
    { 10852, "Root" }, -- Battle Net
    { 11264, "Root" }, -- Ice Blast
    { 10730, "CC" }, -- Pacify
  },
  {
    "Razorfen Kraul",
    { 8281, "Silence" }, -- Sonic Burst
    { 8359, "CC" }, -- Left for Dead
    { 8285, "CC" }, -- Rampage
    { 8377, "Root" }, -- Earthgrab
    { 6728, "CC" }, -- Enveloping Winds
    { 6524, "CC" }, -- Ground Tremor
  },
  {
    "Scarlet Monastery",
    { 13323, "CC" }, -- Polymorph
    { 8988, "Silence" }, -- Silence
    { 9256, "CC" }, -- Deep Sleep
  },
  {
    "Razorfen Downs",
    { 12252, "Root" }, -- Web Spray
    { 12946, "Silence" }, -- Putrid Stench
    { 745, "Root" }, -- Web
    { 12748, "Root" }, -- Frost Nova
  },
  {
    "Uldaman",
    { 11876, "CC" }, -- War Stomp
    { 3636, "CC" }, -- Crystalline Slumber
    { 6726, "Silence" }, -- Silence
    { 10093, "Silence" }, -- Harsh Winds
    { 25161, "Silence" }, -- Harsh Winds
  },
  {
    "Maraudon",
    { 12747, "Root" }, -- Entangling Roots
    { 21331, "Root" }, -- Entangling Roots
    { 21909, "Root" }, -- Dust Field
    { 21808, "CC" }, -- Summon Shardlings
    { 29419, "CC" }, -- Flash Bomb
    { 22592, "CC" }, -- Knockdown
    { 21869, "CC" }, -- Repulsive Gaze
    { 16790, "CC" }, -- Knockdown
    { 21748, "CC" }, -- Thorn Volley
    { 21749, "CC" }, -- Thorn Volley
    { 11922, "Root" }, -- Entangling Roots
  },
  {
    "Zul'Farrak",
    { 11020, "CC" }, -- Petrify
    { 22692, "CC" }, -- Petrify
    { 13704, "CC" }, -- Psychic Scream
    { 11836, "CC" }, -- Freeze Solid
    { 11641, "CC" }, -- Hex
  },
  {
    "The Temple of Atal'Hakkar (Sunken Temple)",
    { 12888, "CC" }, -- Cause Insanity
    { 12480, "CC" }, -- Hex of Jammal'an
    { 12890, "CC" }, -- Deep Slumber
    { 6607, "CC" }, -- Lash
    { 33126, "Disarm" }, -- Dropped Weapon
    { 25774, "CC" }, -- Mind Shatter
  },
  {
    "Blackrock Depths",
    { 8994, "CC" }, -- Banish
    { 12674, "Root" }, -- Frost Nova
    { 15471, "Silence" }, -- Enveloping Web
    { 3609, "CC" }, -- Paralyzing Poison
    { 15474, "Root" }, -- Web Explosion
    { 17492, "CC" }, -- Hand of Thaurissan
    { 14030, "Root" }, -- Hooked Net
    { 14870, "CC" }, -- Drunken Stupor
    { 13902, "CC" }, -- Fist of Ragnaros
    { 15063, "Root" }, -- Frost Nova
    { 6945, "CC" }, -- Chest Pains
    { 3551, "CC" }, -- Skull Crack
    { 15621, "CC" }, -- Skull Crack
    { 11831, "Root" }, -- Frost Nova
  },
  {
    "Blackrock Spire",
    { 16097, "CC" }, -- Hex
    { 22566, "CC" }, -- Hex
    { 15618, "CC" }, -- Snap Kick
    { 16075, "CC" }, -- Throw Axe
    { 16045, "CC" }, -- Encage
    { 16104, "CC" }, -- Crystallize
    { 16508, "CC" }, -- Intimidating Roar
    { 15609, "Root" }, -- Hooked Net
    { 16497, "CC" }, -- Stun Bomb
    { 5276, "CC" }, -- Freeze
    { 18763, "CC" }, -- Freeze
    { 16805, "CC" }, -- Conflagration
    { 13579, "CC" }, -- Gouge
    { 24698, "CC" }, -- Gouge
    { 28456, "CC" }, -- Gouge
    { 16469, "Root" }, -- Web Explosion
    { 15532, "Root" }, -- Frost Nova
  },
  {
    "Stratholme",
    { 17398, "CC" }, -- Balnazzar Transform Stun
    { 17405, "CC" }, -- Domination
    { 17246, "CC" }, -- Possessed
    { 19832, "CC" }, -- Possess
    { 15655, "CC" }, -- Shield Slam
    { 16798, "CC" }, -- Enchanting Lullaby
    { 12542, "CC" }, -- Fear
    { 12734, "CC" }, -- Ground Smash
    { 17293, "CC" }, -- Burning Winds
    { 4962, "Root" }, -- Encasing Webs
    { 16869, "CC" }, -- Ice Tomb
    { 17244, "CC" }, -- Possess
    { 17307, "CC" }, -- Knockout
    { 15970, "CC" }, -- Sleep
    { 3589, "Silence" }, -- Deafening Screech
  },
  {
    "Dire Maul",
    { 27553, "CC" }, -- Maul
    { 22651, "CC" }, -- Sacrifice
    { 22419, "Disarm" }, -- Riptide
    { 22691, "Disarm" }, -- Disarm
    { 22833, "CC" }, -- Booze Spit (chance to hit reduced by 75%)
    { 22856, "CC" }, -- Ice Lock
    { 16727, "CC" }, -- War Stomp
    { 22994, "Root" }, -- Entangle
    { 22924, "Root" }, -- Grasping Vines
    { 22915, "CC" }, -- Improved Concussive Shot
    { 28858, "Root" }, -- Entangling Roots
    { 22415, "Root" }, -- Entangling Roots
    { 22744, "Root" }, -- Chains of Ice
    { 16838, "Silence" }, -- Banshee Shriek
    { 22519, "CC" }, -- Ice Nova
  },
  {
    "Scholomance",
    { 5708, "CC" }, -- Swoop
    { 18144, "CC" }, -- Swoop
    { 18103, "CC" }, -- Backhand
    { 8208, "CC" }, -- Backhand
    { 12461, "CC" }, -- Backhand
    { 27565, "CC" }, -- Banish
    { 16350, "CC" }, -- Freeze

    --{139 , "CC", "Renew"},
  },
  { "Discovered Spells" },
}

local spellIds = {}
local stringcache = {} -- used for default text storage

local defaultString = {
  ["CC"] = "LossOfControl",
  ["Silence"] = "Silenced",
  ["Interrupt"] = "Interrupted",
  ["Disarm"] = "Disarmed",
  ["Root"] = "Rooted",
  ["Immune"] = "Immune",
  ["Other"] = "Other",
  ["Warning"] = "Warning",
  ["Snare"] = "Snared",
}

local tabs = {
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

L.spellsTable = spellsTable

local tabsIndex = {}
for i = 1, #tabs do
  tabsIndex[tabs[i]] = i
end

local DBdefaults = {
  version = 2.17,
  Scale = 1,
  xOfs = 0,
  yOfs = -30,
  point = "CENTER",
  relativePoint = "CENTER",
  AnimateText = false,
  LossOfControl = true,
  spellDisabled = {},
  customSpellIds = {},
  customString = {},
  GreenBar = {
    [1022] = true, -- BOP (rank 1)
    [5599] = true, -- BOP (rank 2)
    [10278] = true, -- BOP (rank 3)
  },
  priority = { -- higher numbers have more priority; 0 = disabled
    CC = 100,
    Interrupt = 90,
    Silence = 80,
    Disarm = 60,
    Root = 50,
    Immune = 40,
    Other = 30,
    Warning = 20,
    Snare = 0,
  },
  durationTime = {
    CC = 2,
    Interrupt = 2,
    Silence = 2,
    Root = 2,
    Disarm = 2,
    Immune = 2,
    Other = 2,
    Warning = 2,
    Snare = 2,
  },
}

local EasyCC = CreateFrame("Frame")
EasyCC:SetScript("OnEvent", function(frame, event, ...)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
  --EasyCC:cleu()
  elseif event == "LOSS_OF_CONTROL_ADDED" then
    local Unit, Index = ...
    if UnitIsUnit(Unit, "player") then
      local data = CLocData(Index)
      EasyCC:LossOfControl(data, Index)
    end
  elseif event == "LOSS_OF_CONTROL_UPDATE" then
    local Unit = ...
    if UnitIsUnit(Unit, "player") then
      local data = CLocData(1)
      EasyCC:LossOfControl(data)
    end
  elseif event == "UNIT_AURA" and ... == "player" then
    EasyCC:PlayerAura(...)
  elseif event == "PLAYER_ENTERING_WORLD" then
    EasyCC:OnLoad()
  elseif event == "ADDON_LOADED" and ... == addonName then
    EasyCC:ADDON_LOADED(...)
  elseif event == "SPELLS_CHANGED" then
    EasyCC:SPELLS_CHANGED(...)
  elseif event == "PLAYER_REGEN_ENABLED" then
    EasyCC:PLAYER_REGEN_ENABLED()
  end
end)

-- this is a custom function
---EasyCC:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
EasyCC:RegisterUnitEvent("UNIT_AURA", "player")
EasyCC:RegisterEvent("PLAYER_ENTERING_WORLD")
EasyCC:RegisterEvent("ADDON_LOADED")
EasyCC:RegisterEvent("LOSS_OF_CONTROL_ADDED")
EasyCC:RegisterEvent("LOSS_OF_CONTROL_UPDATE")

function EasyCC:LossOfControl(data, Index)
  if not data then
    f:Hide()
    f.priority = nil
    f.startTime = nil
    return
  end

  local customString = EasyCCDB.customString

  local locType = data.locType
  local spellID = data.spellID
  local text = data.displayText
  local iconTexture = data.iconTexture
  local startTime = data.startTime
  local timeRemaining = data.timeRemaining
  local duration = data.duration
  local lockoutSchool = data.lockoutSchool
  local priority = data.priority
  local displayType = data.displayType

  if displayType == DISPLAY_NONE then
    return
  end

  stringcache[spellID] = customString[spellID] or text

  if not spellIds[spellID] then
    EasyCC:NewSpell(spellID, locType)
  end --Need to filter out deleted spells fron DB or will keep finding same spell thats been deleted
  if locType == "SCHOOL_INTERRUPT" then
    text = strformat("%s Locked", GetSchoolString(lockoutSchool))

    if spellID then
      f.InterruptspellID = spellID
    else
      f.InterruptspellID = nil
    end
    if iconTexture then
      f.InterrupticonTexture = iconTexture
    else
      f.InterrupticonTexture = nil
    end
    if startTime then
      f.InterruptstartTime = startTime
    else
      f.InterruptstartTime = nil
    end
    if text then
      f.Interrupttext = customString[spellID] or text
    else
      f.Interrupttext = nil
    end
    if duration then
      f.Interruptduration = duration
    else
      f.Interruptduration = nil
    end

    Ctimer(duration, function()
      f.InterruptspellID = nil
      f.InterrupticonTexture = nil
      f.InterruptstartTime = nil
      f.Interruptduration = nil
      f.Interrupttext = nil
    end)

    EasyCC:PlayerAura("player")
  end
end

function EasyCC:NewSpell(spellID, locType)
  local name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()
  local ZoneName = GetZoneText()
  local spell = GetSpellInfo(spellID)
  local Type
  if
    (locType == "STUN_MECHANIC")
    or (locType == "PACIFY")
    or (locType == "STUN")
    or (locType == "FEAR")
    or (locType == "CHARM")
    or (locType == "CONFUSE")
    or (locType == "POSSESS")
    or (locType == "FEAR_MECHANIC")
    or (locType == "FEAR")
  then
    Type = "CC"
    print("EasyCC Discovered New CC " .. spell)
  elseif locType == "DISARM" then
    Type = "Disarm"
    print("EasyCC Discovered New Disarm " .. spell)
  elseif (locType == "PACIFYSILENCE") or (locType == "SILENCE") then
    Type = "Silence"
    print("EasyCC Discovered New Silence " .. spell)
  elseif locType == "SCHOOL_INTERRUPT" then
    Type = "Interrupt"
    print("EasyCC Discovered New Interrupt " .. spell)
  elseif locType == "ROOT" then
    Type = "Root"
    print("EasyCC Discovered New Root " .. spell)
  else
    Type = "Other"
    print("EasyCC Discovered New Other " .. spell) --May Not Want to Include this based on Retail Interactions
  end
  spellIds[spellID] = Type -- _G.EasyCCDB.spellDisabled[spell] = nil --If already delted then this will disable it
  tblinsert(
    EasyCCDB.customSpellIds,
    { spellID, Type, instanceType, nil, name .. "\n" .. ZoneName, "Discovered", #L.spells }
  )
  tblinsert(
    L.spells[#L.spells][tabsIndex[Type]],
    { spellID, Type, nil, instanceType, name .. "\n" .. ZoneName, "Discovered", #L.spells }
  )
  L.Spells:UpdateTab(#L.spells)
end

function EasyCC:PlayerAura(unit)
  if not EasyCCDB.LossOfControl then
    return
  end

  local priority = EasyCCDB.priority
  local disabled = EasyCCDB.spellDisabled
  local durationTime = EasyCCDB.durationTime
  local customString = EasyCCDB.customString
  local maxPriority = 1
  local maxExpirationTime = 0
  local Unique = 0
  local Icon, Duration, DurationTime, Text, Spell, GreenBar

  for i = 1, 40 do
    local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura(unit, i, "HARMFUL")
    if not spellId then
      break
    end

    if duration == 0 and expirationTime == 0 then
      expirationTime = GetTime() + 1 -- normal expirationTime = 0
    end

    local spellCategory = spellIds[spellId] or spellIds[name]
    local Priority = priority[spellCategory]
    local durationShow = durationTime[spellCategory]
    if ((not disabled[spellId]) and not disabled[name]) and durationShow and durationShow > 0 then
      if Priority == maxPriority and expirationTime > maxExpirationTime then
        maxExpirationTime = expirationTime
        Duration = duration
        DurationTime = durationShow
        Icon = icon
        GreenBar = EasyCCDB.GreenBar[spellId] or EasyCCDB.GreenBar[name]
        if duration == 0 then
          Unique = spellId .. 0
        else
          Unique = spellId .. expirationTime
        end
        Text = customString[spellId]
          or customString[name]
          or stringcache[spellId]
          or defaultString[spellCategory]
      elseif Priority > maxPriority then
        maxPriority = Priority
        maxExpirationTime = expirationTime
        Duration = duration
        DurationTime = durationShow
        Icon = icon
        GreenBar = EasyCCDB.GreenBar[spellId] or EasyCCDB.GreenBar[name]
        if duration == 0 then
          Unique = spellId .. 0
        else
          Unique = spellId .. expirationTime
        end
        Text = customString[spellId]
          or customString[name]
          or stringcache[spellId]
          or defaultString[spellCategory]
      end
    end
  end

  for i = 1, 40 do
    local name, icon, count, _, duration, expirationTime, source, _, _, spellId = UnitAura(unit, i, "HELPFULL")
    if not spellId then
      break
    end

    if duration == 0 and expirationTime == 0 then
      expirationTime = GetTime() + 1 -- normal expirationTime = 0
    end

    local spellCategory = spellIds[spellId] or spellIds[name]
    local Priority = priority[spellCategory]
    local durationShow = durationTime[spellCategory]
    if ((not disabled[spellId]) and not disabled[name]) and durationShow and durationShow > 0 then
      if Priority == maxPriority and expirationTime > maxExpirationTime then
        maxExpirationTime = expirationTime
        Duration = duration
        DurationTime = durationShow
        Icon = icon
        GreenBar = EasyCCDB.GreenBar[spellId] or EasyCCDB.GreenBar[name]
        if duration == 0 then
          Unique = spellId .. 0
        else
          Unique = spellId .. expirationTime
        end
        Text = customString[spellId]
          or customString[name]
          or stringcache[spellId]
          or defaultString[spellCategory]
      elseif Priority > maxPriority then
        maxPriority = Priority
        maxExpirationTime = expirationTime
        Duration = duration
        DurationTime = durationShow
        Icon = icon
        GreenBar = EasyCCDB.GreenBar[spellId] or EasyCCDB.GreenBar[name]
        if duration == 0 then
          Unique = spellId .. 0
        else
          Unique = spellId .. expirationTime
        end
        Text = customString[spellId]
          or customString[name]
          or stringcache[spellId]
          or defaultString[spellCategory]
      end
    end
  end

  if f.InterruptspellID and not disabled[f.InterruptspellID] then
    local spellCategory = spellIds[f.InterruptspellID]

    if f.InterruptspellID == 26679 then
      spellCategory = "Interrupt"
    end -- fix for Deadly throw
    if f.InterruptspellID == 22570 then
      spellCategory = "Interrupt"
    end -- fix for Maim
    if f.InterruptspellID == 19675 then
      spellCategory = "Interrupt"
    end -- fix for Feral CHarge
    if f.InterruptspellID == 27620 then
      spellCategory = "Interrupt"
    end -- fix for Snap Kick
    if f.InterruptspellID == 27814 then
      spellCategory = "Interrupt"
    end -- fix for Kick
    if f.InterruptspellID == 27880 then
      spellCategory = "Interrupt"
    end -- fix for Stun
    if f.InterruptspellID == 30849 then
      spellCategory = "Interrupt"
    end -- fix for Spell Lock
    if f.InterruptspellID == 35856 then
      spellCategory = "Interrupt"
    end -- fix for Stun
    if f.InterruptspellID == 36138 then
      spellCategory = "Interrupt"
    end -- fix for Hammer Stun
    if f.InterruptspellID == 36254 then
      spellCategory = "Interrupt"
    end -- fix for Judgement of Flame
    if f.InterruptspellID == 11978 then
      spellCategory = "Interrupt"
    end -- fix for Kick
    if f.InterruptspellID == 41197 then
      spellCategory = "Interrupt"
    end -- fix for Shield Bash
    if f.InterruptspellID == 40864 then
      spellCategory = "Interrupt"
    end -- fix for Throbing Stun
    if f.InterruptspellID == 40305 then
      spellCategory = "Interrupt"
    end -- fix for Power Burn
    if f.InterruptspellID == 46182 then
      spellCategory = "Interrupt"
    end -- fix for Snap Kick
    if f.InterruptspellID == 37359 then
      spellCategory = "Interrupt"
    end -- fix for Snap Kick

    local Priority = priority[spellCategory]
    local expirationTime = f.InterruptstartTime + f.Interruptduration
    local durationShow = durationTime[spellCategory]
    if Priority == maxPriority and expirationTime > maxExpirationTime and durationShow and durationShow > 0 then
      maxExpirationTime = expirationTime
      Duration = f.Interruptduration
      DurationTime = durationShow
      Icon = f.InterrupticonTexture
      Text = f.Interrupttext
      GreenBar = EasyCCDB.GreenBar[f.InterruptspellID]
      if Duration == 0 then
        Unique = f.InterruptspellID .. 0
      else
        Unique = f.InterruptspellID .. expirationTime
      end
    elseif Priority > maxPriority and durationShow and durationShow > 0 then
      maxPriority = Priority
      maxExpirationTime = expirationTime
      Duration = f.Interruptduration
      DurationTime = durationShow
      Icon = f.InterrupticonTexture
      Text = f.Interrupttext
      GreenBar = EasyCCDB.GreenBar[f.InterruptspellID]
      if Duration == 0 then
        Unique = f.InterruptspellID .. 0
      else
        Unique = f.InterruptspellID .. expirationTime
      end
    end
  end

  if DurationTime == 2 then
    DurationTime = true
  elseif DurationTime == 1 then
    DurationTime = false
  end

  if maxExpirationTime == 0 then -- no (de)buffs found
    self.maxExpirationTime = 0
    self.Unique = 0
    if f:IsShown() then
      f:Hide()
    end
  elseif maxExpirationTime ~= self.maxExpirationTime and Unique ~= self.Unique then -- new debuff found
    self.maxExpirationTime = maxExpirationTime
    self.Unique = Unique
    local StartTime = maxExpirationTime - Duration
    EasyCC:Display(Icon, StartTime, Duration, Text, DurationTime, GreenBar)
  end
end

function EasyCC:Display(icon, startTime, duration, text, durationDisplay, greenBar)
  if self.test then
    f.displayTime = duration
    f.startTime = GetTime()
  elseif durationDisplay then
    f.displayTime = duration
    f.startTime = startTime
  else
    f.displayTime = fadeTime
    f.startTime = startTime
  end
  if text then
    f.Ltext:SetText(text)
  end
  if icon then --icon control here
    f.Icon.texture:SetTexture(icon)
  else
    f.Icon.texture:SetTexture(136235)
  end
  if duration and duration ~= 0 then --duration control here
    f.TimeSinceLastUpdate = 0
    f.Icon.cooldown:SetCooldown(startTime, duration)
    f.Icon.cooldown:SetSwipeColor(0, 0, 0, 1)
    f.Ltext:ClearAllPoints()
    f.timer:ClearAllPoints()
    f.Ltext:SetPoint("LEFT", f.Icon, "RIGHT", 5, 9)
    f.timer:SetPoint("LEFT", f.Icon, "RIGHT", 5, -14)
    f.timer:Show()
  else -- no druation
    f.TimeSinceLastUpdate = 0
    if not durationDisplay then
      f.displayTime = fadeTime
    else
      f.displayTime = GetTime() + 1
    end
    f.Icon.cooldown:SetCooldown(GetTime(), 0)
    f.Icon.cooldown:SetSwipeColor(0, 0, 0, 0)
    f.Ltext:ClearAllPoints()
    f.Ltext:SetPoint("LEFT", f.Icon, "RIGHT", 7.5, 0)
    f.timer:Hide()
  end
  if IsAddOnLoaded("BambiUI") then
    local point, relativeTo, relativePoint, xOfs, yOfs = PartyAnchor5:GetPoint()
    EasyCCDB.point = "CENTER"
    EasyCCDB.relativePoint = "CENTER"
    EasyCCDB.yOfs = yOfs
    EasyCCDB.xOfs = 0
  end
  if greenBar then
    f.barB.texture:SetDesaturated(1) --sets the border green
    f.barB.texture:SetVertexColor(0, 1, 0, 1) --sets the border green
    f.barU.texture:SetDesaturated(1) --sets the border green
    f.barU.texture:SetVertexColor(0, 1, 0, 1) --sets the border green
  else
    f.barB.texture:SetDesaturated(nil) --sets the border green
    f.barB.texture:SetVertexColor(1, 1, 1, 1) --sets the border green
    f.barU.texture:SetDesaturated(nil) --sets the border green
    f.barU.texture:SetVertexColor(1, 1, 1, 1) --sets the border green
  end

  if f.Ltext:GetStringWidth() > 100 then
    f.barB.texture:SetWidth(f.Icon:GetWidth() + f.Ltext:GetStringWidth())
    f.barU.texture:SetWidth(f.Icon:GetWidth() + f.Ltext:GetStringWidth())
    f.backgroundTexture:SetWidth(f.Icon:GetWidth() + f.Ltext:GetStringWidth())
    f:SetWidth(f.Icon:GetWidth() + f.Ltext:GetStringWidth())
  else
    f.barB.texture:SetWidth(f.Icon:GetWidth() + (7 * 21))
    f.barU.texture:SetWidth(f.Icon:GetWidth() + (7 * 21))
    f.backgroundTexture:SetWidth(f.Icon:GetWidth() + (7 * 16))
    f:SetWidth(f.Icon:GetWidth() + (7 * 16))
  end
  f.barU.texture:ClearAllPoints()
  f.barB.texture:ClearAllPoints()
  f.barU.texture:SetPoint("BOTTOM", f, "TOP", 0, 4)
  f.barB.texture:SetPoint("TOP", f, "BOTTOM", 0, -4)
  f:ClearAllPoints()
  f:SetPoint(
    EasyCCDB.point or "CENTER",
    UIParent,
    EasyCCDB.relativePoint or "CENTER",
    EasyCCDB.xOfs or 0,
    EasyCCDB.yOfs or 0
  )
  f:Show()
  if EasyCCDB.AnimateText then
    if pulseLtext then
      pulseLtext:Play()
    end
    if pulsetimer then
      pulsetimer:Play()
    end
  end
end

function EasyCC:StopMoving()
  f.point, f.anchor, f.relativePoint, f.x, f.y = f:GetPoint()
  if not f.anchor then
    f:ClearAllPoints()
    f:SetPoint(f.point or "CENTER", UIParent, f.relativePoint or "CENTER", f.x or 0, f.y or 0)
  end
  EasyCCDB.point = f.point
  EasyCCDB.relativePoint = f.relativePoint
  EasyCCDB.yOfs = f.y
  EasyCCDB.xOfs = f.x
  self:StopMovingOrSizing()
end

function EasyCC:OnLoad()
  if not f then --create the frame
    f = CreateFrame("Frame")
    f:SetScale(EasyCCDB.Scale)
    f:SetParent(UIParent)
    f:SetFrameStrata("HIGH")
    f:SetHeight(hieght)

    f.backgroundTexture = f:CreateTexture(nil, "BACKGROUND")
    f.backgroundTexture:SetTexture("Interface\\Cooldown\\LoC-ShadowBG")
    f.backgroundTexture:SetPoint("CENTER", f, "CENTER", 0, 0)
    f.backgroundTexture:SetHeight(hieght + 8)
    f.backgroundTexture:SetVertexColor(1, 1, 1, 0.6)

    f.Icon = CreateFrame("Frame", "f.Icon")
    f.Icon:SetHeight(hieght)
    f.Icon:SetWidth(width)
    f.Icon:SetParent(f)
    f.Icon:ClearAllPoints()
    f.Icon:SetPoint("LEFT", f, "LEFT", 0, 0)

    f.Icon.texture = f.Icon:CreateTexture(nil, "BACKGROUND")
    f.Icon.texture:SetAllPoints(f.Icon)

    f.Icon.cooldown = CreateFrame("Cooldown", "BambiUIInterrupt", f.Icon, "CooldownFrameTemplate")
    f.Icon.cooldown:SetAllPoints(f.Icon)
    f.Icon.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge") --("Interface\\Cooldown\\edge-LoC") Blizz CD
    f.Icon.cooldown:SetDrawSwipe(true)
    f.Icon.cooldown:SetDrawEdge(true)
    f.Icon.cooldown:SetSwipeColor(0, 0, 0, 1)
    f.Icon.cooldown:SetReverse(false) --will reverse the swipe if actionbars or debuff, by default bliz sets the swipe to actionbars if this = true it will be set to debuffs
    f.Icon.cooldown:SetDrawBling(true)
    f.Icon.cooldown:SetHideCountdownNumbers(true)

    f.Ltext = f.Icon:CreateFontString(nil, "ARTWORK")
    f.Ltext:SetFont(STANDARD_TEXT_FONT, 24, "THICKOUTLINE")
    f.Ltext:SetParent(f.Icon)
    f.Ltext:SetJustifyH("LEFT")
    f.Ltext:SetTextColor(1, 0.8, 0, 1)

    f.timer = f.Icon:CreateFontString(nil, "ARTWORK")
    f.timer:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
    f.timer:SetParent(f.Icon)

    local ONUPDATE_INTERVAL = 1

    f.barU = CreateFrame("Frame", "f.barU")
    f.barU.texture = f.barU:CreateTexture(nil, "BACKGROUND")
    f.barU.texture:SetTexture("Interface\\Cooldown\\Loc-RedLine")

    f.barU.texture:SetHeight(17)
    f.barU.texture:SetParent(f)

    f.barB = CreateFrame("Frame", "f.barU")
    f.barB.texture = f.barB:CreateTexture(nil, "BACKGROUND")
    f.barB.texture:SetTexture("Interface\\Cooldown\\Loc-RedLine")
    f.barB.texture:SetHeight(17)
    f.barB.texture:SetParent(f)
    f.barB.texture:SetRotation(math.rad(180))

    f.displayTime = fadeTime -- Default Timer Display
    f.TimeSinceLastUpdate = 0

    pulseLtext = f.Ltext:CreateAnimationGroup()
    pulseLtext:SetScript("OnFinished", function() end)

    local startLtext = pulseLtext:CreateAnimation("Scale")
    startLtext:SetDuration(0.125)
    startLtext:SetScale(1.15, 1.15)
    startLtext:SetOrder(1)
    startLtext:SetEndDelay(0)

    local finishLtext = pulseLtext:CreateAnimation("Scale")
    finishLtext:SetDuration(0.125)
    finishLtext:SetScale(1, 1)
    finishLtext:SetOrder(2)

    pulsetimer = f.timer:CreateAnimationGroup()
    pulsetimer:SetScript("OnFinished", function() end)

    local starttimer = pulsetimer:CreateAnimation("Scale")
    starttimer:SetDuration(0.125)
    starttimer:SetScale(1.15, 1.15)
    starttimer:SetOrder(1)
    starttimer:SetEndDelay(0)

    local finishtimer = pulsetimer:CreateAnimation("Scale")
    finishtimer:SetDuration(0.125)
    finishtimer:SetScale(1, 1)
    finishtimer:SetOrder(2)

    -- The number of seconds since the last update, script to set the duration to show before fading
    f.Icon:SetScript("OnUpdate", function(self, elapsed)
      if f.startTime then
        local timeRemaining = f.startTime - GetTime() + (f.Icon.cooldown:GetCooldownDuration() / 1000)
        if timeRemaining >= 60 then
          local number = strformat("%.1f", timeRemaining / 60)
          f.timer:SetText(number .. " minutes")
        elseif timeRemaining >= 10 then
          local number = strformat("%d", timeRemaining)
          f.timer:SetText(number .. " seconds")
        elseif timeRemaining < 9.95 then -- From 9.95 to 9.99 it will print 10.0 instead of 9.9
          local number = strformat("%.1F", timeRemaining)
          f.timer:SetText(number .. " seconds")
        end
      end
      --text:SetText(string.format("%.1f", start - GetTime() + (f.Icon.cooldown:GetCooldownDuration()/1000)) .." seconds")
      f.TimeSinceLastUpdate = f.TimeSinceLastUpdate + elapsed
      if f.TimeSinceLastUpdate >= f.displayTime then
        f.TimeSinceLastUpdate = 0
        if f and f:IsShown() then
          f:Hide()
        end
        if EasyCC.test then
          EasyCC:toggletest()
        end
      end
    end)
    -- When the frame is shown, reset the update f.timer
    f.Icon:SetScript("OnShow", function(self)
      f.TimeSinceLastUpdate = 0
    end)
    f:SetScript("OnEvent", self.OnEvent)
    f:SetScript("OnDragStart", self.StartMoving) -- this function is already built into the Frame class
    f:SetScript("OnDragStop", self.StopMoving)
    print("|cff00ccffEasyCC|r", "|cffFF7D0A (Cata)|r", ': Type "/ecc"')
  end
end

function EasyCC:ADDON_LOADED(arg1)
  if arg1 == addonName then
    if (_G.EasyCCDB == nil) or (_G.EasyCCDB.version == nil) then
      _G.EasyCCDB = CopyTable(DBdefaults)
      print("EasyCC Defaults Loaded.")
    elseif _G.EasyCCDB.version < DBdefaults.version then
      print("EasyCC Version " .. _G.EasyCCDB.version .. " Updated to " .. DBdefaults.version)
      for j, u in pairs(DBdefaults) do
        if _G.EasyCCDB[j] == nil then
          _G.EasyCCDB[j] = u
        elseif type(u) == "table" then
          for k, v in pairs(u) do
            if _G.EasyCCDB[j][k] == nil then
              _G.EasyCCDB[j][k] = v
            end
          end
        end
      end
    end
    EasyCCDB = _G.EasyCCDB
    EasyCC:RegisterEvent("SPELLS_CHANGED")
    if EasyCCDB.LossOfControl then
      if not LossOfControlFrame_Show_Orig and LossOfControlFrame then
        LossOfControlFrame_Show_Orig = LossOfControlFrame.Show
      end
      LossOfControlFrame.Show = LossOfControlFrame.Hide
    end
  end
end

function EasyCC:SPELLS_CHANGED(...)
  if UnitAffectingCombat("player") then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("SPELLS_CHANGED")
    return
  end
  self:UnregisterEvent("SPELLS_CHANGED")
  self:CompileSpells()
  L.Spells:Addon_Load()
end

function EasyCC:PLAYER_REGEN_ENABLED()
  self:UnregisterEvent("PLAYER_REGEN_ENABLED")
  self:CompileSpells()
  L.Spells:Addon_Load()
end

function EasyCC:CompileSpells(typeUpdate)
  spellIds = {}
  local spells = {}
  local spellList = {}
  local hash = {}
  local customSpells = {}
  local toremove = {}

  for i = 1, #spellsTable do
    for l = 2, #spellsTable[i] do
      local spellID, prio, text = unpack(spellsTable[i][l])
      if text and not _G.EasyCCDB.customString[spellID] then
        _G.EasyCCDB.customString[spellID] = text
      end
    end
  end

  --Build Custom Table for Check
  for k, v in ipairs(_G.EasyCCDB.customSpellIds) do
    local spellID, prio, _, _, _, _, tabId = unpack(v)
    customSpells[spellID] = { spellID, prio, tabId, k }
  end
  --Build the Spells Table
  for i = 1, #spellsTable do
    if spells[i] == nil then
      spells[i] = {}
    end
    for l = 1, #tabs do
      if spells[i][l] == nil then
        spells[i][l] = {}
      end
    end
  end
  --Sort the spells
  for i = 1, #spellsTable do
    for l = 2, #spellsTable[i] do
      local spellID, prio = unpack(spellsTable[i][l])
      if
        prio == "CC"
        or prio == "Interrupt"
        or prio == "Silence"
        or prio == "Root"
        or prio == "Disarm"
        or prio == "Immune"
        or prio == "Other"
        or prio == "Warning"
        or prio == "Snare"
      then
        tblinsert(spells[i][tabsIndex[prio]], { spellID, prio })
        spellList[spellID] = true
      end
    end
  end

  L.spellList = spellList
  --Cleans Up All Spells
  for i = 1, #spells do
    for l = 1, #spells[i] do
      local removed = 0
      for x = 1, #spells[i][l] do
        local spellID, prio = unpack(spells[i][l][x])
        if (not hash[spellID]) and not customSpells[spellID] then
          hash[spellID] = { spellID, prio }
        else
          if customSpells[spellID] then
            local CspellID, Cprio, CtabId, Ck = unpack(customSpells[spellID])
            if CspellID == spellID and Cprio == prio and CtabId == i then
              tblremove(_G.EasyCCDB.customSpellIds, Ck)
              print(
                "|cff00ccffEasyCC|r : "
                  .. spellID
                  .. " : "
                  .. prio
                  .. " |cff009900Restored to Original Value|r"
              )
            elseif CspellID == spellID and CtabId == #spells then
              tblremove(_G.EasyCCDB.customSpellIds, Ck)
              print(
                "|cff00ccffEasyCC|r : "
                  .. spellID
                  .. " : "
                  .. prio
                  .. " |cff009900Added from Discovered Spells to Database (Reconfigure if Needed)|r"
              )
            else
              if type(spellID) == "number" then
                if GetSpellInfo(spellID) then
                  local name = GetSpellInfo(spellID) or "Unknnown"
                  print(
                    "|cff00ccffEasyCC|r : "
                      .. CspellID
                      .. " : "
                      .. Cprio
                      .. " ("
                      .. name
                      .. ") Modified Spell "
                      .. "|cff009900Removed |r"
                      .. spellID
                      .. " |cff009900: |r"
                      .. prio
                  )
                end
              else
                print(
                  "|cff00ccffEasyCC|r : "
                    .. CspellID
                    .. " : "
                    .. Cprio
                    .. " (not spellId) Modified Spell "
                    .. "|cff009900Removed |r"
                    .. spellID
                    .. " |cff009900: |r"
                    .. prio
                )
              end
              tblinsert(toremove, { i, l, x, removed, spellID })
              removed = removed + 1
            end
          else
            local HspellID, Hprio = unpack(hash[spellID])
            if type(spellID) == "number" then
              local name = GetSpellInfo(spellID) or "Unknnown"
              print(
                "|cff00ccffEasyCC|r : "
                  .. HspellID
                  .. " : "
                  .. Hprio
                  .. " ("
                  .. name
                  .. ") "
                  .. "|cffff0000Duplicate Spell in Lua |r"
                  .. "|cff009900Removed |r"
                  .. spellID
                  .. " |cff009900: |r"
                  .. prio
              )
            else
              print(
                "|cff00ccffEasyCC|r : "
                  .. HspellID
                  .. " : "
                  .. Hprio
                  .. " (not spellId) "
                  .. "|cff009900Duplicate Spell in Lua |r"
                  .. "|cff009900Removed |r"
                  .. spellID
                  .. " |cff009900: |r"
                  .. prio
              )
            end
            tblinsert(toremove, { i, l, x, removed, spellID })
            removed = removed + 1
          end
        end
      end
    end
  end
  --Now Remove all the Duplicates and Custom Spells
  for k, v in ipairs(toremove) do
    local i, l, x, r, s = unpack(v)
    tblremove(spells[i][l], x - r)
  end
  --ReAdd all dbCustom Spells to spells
  for k, v in ipairs(_G.EasyCCDB.customSpellIds) do
    local spellID, prio, text, instanceType, zone, customname, tab = unpack(v)
    if prio ~= "Delete" then
      if customname == "Discovered" then
        tab = #spells
      end
      --if position then
      --  tblinsert(spells[tab][position], 1, v)
      --else
      tblinsert(spells[tab][tabsIndex[prio]], 1, v) --v[7]: Category to enter spell / v[8]: Tab to update / v[9]: Table
      --end
    end
  end
  --Make spellIds from Spells for AuraFilter to check
  for i = 1, #spells do
    for l = 1, #spells[i] do
      for x = 1, #spells[i][l] do
        spellIds[spells[i][l][x][1]] = spells[i][l][x][2]
      end
    end
  end
  L.spells = spells
  L.spellIds = spellIds
  --check for any 1st time spells being added and set to On

  if EasyCCDB.LossOfControl then
    SetCVar("lossOfControl", 1)
  else
    SetCVar("lossOfControl", 0)
  end
  if EasyCCDB.durationTime["CC"] == 2 then
    SetCVar("lossOfControlFull", 2)
  elseif EasyCCDB.durationTime["CC"] == 1 then
    SetCVar("lossOfControlFull", 1)
  else
    SetCVar("lossOfControlFull", 0)
  end
  if EasyCCDB.durationTime["Silence"] == 2 then
    SetCVar("lossOfControlSilence", 2)
  elseif EasyCCDB.durationTime["Silence"] == 1 then
    SetCVar("lossOfControlSilence", 1)
  else
    SetCVar("lossOfControlSilence", 0)
  end
  if EasyCCDB.durationTime["Interrupt"] == 2 then
    SetCVar("lossOfControlInterrupt", 2)
  elseif EasyCCDB.durationTime["Interrupt"] == 1 then
    SetCVar("lossOfControlInterrupt", 1)
  else
    SetCVar("lossOfControlInterrupt", 0)
  end
  if EasyCCDB.durationTime["Disarm"] == 2 then
    SetCVar("lossOfControlDisarm", 2)
  elseif EasyCCDB.durationTime["Disarm"] == 1 then
    SetCVar("lossOfControlDisarm", 1)
  else
    SetCVar("lossOfControlDisarm", 0)
  end
  if EasyCCDB.durationTime["Root"] == 2 then
    SetCVar("lossOfControlRoot", 2)
  elseif EasyCCDB.durationTime["Root"] == 1 then
    SetCVar("lossOfControlRoot", 1)
  else
    SetCVar("lossOfControlRoot", 0)
  end
end

local teststring =
  { "Holy Locked", "Polymorph", "Shadow Locked", "Stunned", "Feared", "", "Long String to Test Red Bar", "Kick" }
local mytime = { 30, 25, 30, 15, 25, 20, 30, 10, 20, 20 }

function EasyCC:toggletest()
  if not self.test then
    self.test = true
    local text = teststring[math.random(#teststring)]
    local keys = {} -- for random icon sillyness
    for k in pairs(spellIds) do
      tinsert(keys, k)
    end
    local _, _, icon = GetSpellInfo(keys[random(#keys)])
    EasyCC:Display(icon, GetTime(), mytime[math.random(#mytime)], text)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:EnableMouse(true)
    print("|cff00ccffEasyCC|r", "|cffFF7D0A (Cata)|r", ": Test Mode On")
  else
    self.test = nil
    f:EnableMouse(false)
    f:RegisterForDrag()
    f:SetMovable(false)
    f.TimeSinceLastUpdate = 0
    if f and f:IsShown() then
      f:Hide()
    end
    print("|cff00ccffEasyCC|r", "|cffFF7D0A (Cata)|r", ": Test Mode Off")
  end
end

---------------------------------------------------------------------------------------------------------------

local O = addonName .. "OptionsPanel"

local function CreateSlider(text, parent, low, high, step, globalName)
  local name = globalName or (parent:GetName() .. text)
  local slider = CreateFrame("Slider", name, parent, "UISliderTemplateWithLabels") --"OptionsSliderTemplate")
  slider:SetHeight(8)
  slider:SetWidth(150)
  slider:SetScale(0.9)
  slider:SetMinMaxValues(low, high)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)
  _G[name .. "Text"]:SetText(text)
  _G[name .. "Low"]:SetText("")
  _G[name .. "High"]:SetText("")
  return slider
end

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = addonName

local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetFont("Fonts\\FRIZQT__.TTF", 30)
title:SetText(addonName)
title:SetPoint("TOPLEFT", 15, -15)

local BambiText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
BambiText:SetFont("Fonts\\MORPHEUS.ttf", 14)
BambiText:SetText("By " .. "|cff00ccffBambi|r")
BambiText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 65, 1)

local Spells = CreateFrame("Button", O .. "Spells", OptionsPanel, "UIPanelButtonTemplate")
_G[O .. "Spells"]:SetText("Customize Any Spells")
Spells:SetHeight(28)
Spells:SetWidth(200)
Spells:SetScale(1)
Spells:SetScript("OnClick", function(self)
  L.Spells:Toggle()
end)
Spells:SetPoint("LEFT", title, "RIGHT", 90, 3)

local SpellText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
SpellText:SetFont("Fonts\\FRIZQT__.TTF", 11)
SpellText:SetText(
  "Fully Customize Any Default Spell or Add Any Spell by Name or SpellId \n\n1: Add spells with Custom Text and Priority \n2: Delete or hide any spell in game \n3: Change the Red Bar to Green on any Spell \n4: Check out the discovered tab for spells found while playing \n "
)
SpellText:SetJustifyH("LEFT")
SpellText:SetPoint("TOPLEFT", Spells, "BOTTOMRIGHT", -197, -5)

local unlocknewline = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
unlocknewline:SetFont("Fonts\\FRIZQT__.TTF", 16)
unlocknewline:SetText(" (drag to move)")

-- "Unlock" checkbox - allow the frames to be moved
local Unlock = CreateFrame("CheckButton", O .. "Unlock", OptionsPanel, "InterfaceOptionsCheckButtonTemplate")
function Unlock:OnClick()
  if self:GetChecked() then
    unlocknewline:SetPoint("LEFT", Unlock, "RIGHT", 40, 0)
    unlocknewline:Show()
    EasyCC:toggletest()
  else
    unlocknewline:Hide()
    EasyCC:toggletest()
  end
end
Unlock:SetScript("OnClick", Unlock.OnClick)
Unlock:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -22)

local unlock = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
unlock:SetFont("Fonts\\FRIZQT__.TTF", 18)
unlock:SetText("Test")
unlock:SetPoint("LEFT", Unlock, "RIGHT", 6, 0)

local Scale
Scale = CreateSlider("EasyCC Scale", OptionsPanel, 0.5, 1.5, 0.01, "EasyCC Scale")
Scale:SetScript("OnValueChanged", function(self, value)
  Scale:SetScale(1)
  Scale:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("EasyCC Scale" .. " (" .. ("%.2f"):format(value) .. ")")
  if f and f.SetScale then
    f:SetScale(EasyCCDB.Scale)
  end
  EasyCCDB.Scale = ("%.2f"):format(value) -- the real alpha value
end)

local AnimateText = CreateFrame("CheckButton", O .. "Unlock", OptionsPanel, "InterfaceOptionsCheckButtonTemplate")
AnimateText:SetScript("OnClick", function(self)
  if self:GetChecked() then
    EasyCCDB.AnimateText = true
  else
    EasyCCDB.AnimateText = false
  end
end)
AnimateText:SetPoint("LEFT", Scale, "RIGHT", 25, 0)

local animateText = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
animateText:SetFont("Fonts\\FRIZQT__.TTF", 12)
animateText:SetText("Animate Text")
animateText:SetPoint("LEFT", AnimateText, "RIGHT", 6, 0)

local LossOfControlFull
LossOfControlFull = CreateSlider("LossOfControlFull", OptionsPanel, 0, 2, 1, "LossOfControlFull")
LossOfControlFull:SetScript("OnValueChanged", function(self, value)
  LossOfControlFull:SetScale(1)
  LossOfControlFull:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType Full CC" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["CC"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
  SetCVar("lossOfControlFull", mathfloor(tonumber(("%.0f"):format(value))))
end)

local LossOfControlInterrupt
LossOfControlInterrupt = CreateSlider("LossOfControlInterrupt", OptionsPanel, 0, 2, 1, "LossOfControlInterrupt")
LossOfControlInterrupt:SetScript("OnValueChanged", function(self, value)
  LossOfControlInterrupt:SetScale(1)
  LossOfControlInterrupt:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Interrupt" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Interrupt"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
  SetCVar("lossOfControlInterrupt", mathfloor(tonumber(("%.0f"):format(value))))
end)

local LossOfControlSilence
LossOfControlSilence = CreateSlider("LossOfControlSilence", OptionsPanel, 0, 2, 1, "LossOfControlSilence")
LossOfControlSilence:SetScript("OnValueChanged", function(self, value)
  LossOfControlSilence:SetScale(1)
  LossOfControlSilence:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Silence" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Silence"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
  SetCVar("lossOfControlSilence", mathfloor(tonumber(("%.0f"):format(value))))
end)

local LossOfControlDisarm
LossOfControlDisarm = CreateSlider("LossOfControlDisarm", OptionsPanel, 0, 2, 1, "LossOfControlDisarm")
LossOfControlDisarm:SetScript("OnValueChanged", function(self, value)
  LossOfControlDisarm:SetScale(1)
  LossOfControlDisarm:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Disarm" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Disarm"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
  SetCVar("lossOfControlDisarm", mathfloor(tonumber(("%.0f"):format(value))))
end)

local LossOfControlRoot
LossOfControlRoot = CreateSlider("LossOfControlRoot", OptionsPanel, 0, 2, 1, "LossOfControlRoot")
LossOfControlRoot:SetScript("OnValueChanged", function(self, value)
  LossOfControlRoot:SetScale(1)
  LossOfControlRoot:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Root" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Root"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
  SetCVar("lossOfControlRoot", mathfloor(tonumber(("%.0f"):format(value))))
end)

local LossOfControlImmune
LossOfControlImmune = CreateSlider("LossOfControlImmune", OptionsPanel, 0, 2, 1, "LossOfControlImmune")
LossOfControlImmune:SetScript("OnValueChanged", function(self, value)
  LossOfControlImmune:SetScale(1)
  LossOfControlImmune:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Immune" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Immune"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local LossOfControlOther
LossOfControlOther = CreateSlider("LossOfControlOther", OptionsPanel, 0, 2, 1, "LossOfControlOther")
LossOfControlOther:SetScript("OnValueChanged", function(self, value)
  LossOfControlOther:SetScale(1)
  LossOfControlOther:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Other" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Other"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local LossOfControlWarning
LossOfControlWarning = CreateSlider("LossOfControlWarning", OptionsPanel, 0, 2, 1, "LossOfControlWarning")
LossOfControlWarning:SetScript("OnValueChanged", function(self, value)
  LossOfControlWarning:SetScale(1)
  LossOfControlWarning:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType  Warning" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Warning"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local LossOfControlSnare
LossOfControlSnare = CreateSlider("LossOfControlSnare", OptionsPanel, 0, 2, 1, "LossOfControlSnare")
LossOfControlSnare:SetScript("OnValueChanged", function(self, value)
  LossOfControlSnare:SetScale(1)
  LossOfControlSnare:SetWidth(175)
  _G[self:GetName() .. "Text"]:SetText("DisplayType Snare" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.durationTime["Snare"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityFull
PriorityFull = CreateSlider("PriorityFull", OptionsPanel, 0, 100, 1, "PriorityFull")
PriorityFull:SetScript("OnValueChanged", function(self, value)
  PriorityFull:SetScale(1)
  PriorityFull:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority Full CC" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["CC"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityInterrupt
PriorityInterrupt = CreateSlider("PriorityInterrupt", OptionsPanel, 0, 100, 1, "PriorityInterrupt")
PriorityInterrupt:SetScript("OnValueChanged", function(self, value)
  PriorityInterrupt:SetScale(1)
  PriorityInterrupt:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Interrupt" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Interrupt"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PrioritySilence
PrioritySilence = CreateSlider("PrioritySilence", OptionsPanel, 0, 100, 1, "PrioritySilence")
PrioritySilence:SetScript("OnValueChanged", function(self, value)
  PrioritySilence:SetScale(1)
  PrioritySilence:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Silence" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Silence"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityDisarm
PriorityDisarm = CreateSlider("PriorityDisarm", OptionsPanel, 0, 100, 1, "PriorityDisarm")
PriorityDisarm:SetScript("OnValueChanged", function(self, value)
  PriorityDisarm:SetScale(1)
  PriorityDisarm:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Disarm" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Disarm"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityRoot
PriorityRoot = CreateSlider("PriorityRoot", OptionsPanel, 0, 100, 1, "PriorityRoot")
PriorityRoot:SetScript("OnValueChanged", function(self, value)
  PriorityRoot:SetScale(1)
  PriorityRoot:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Root" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Root"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityImmune
PriorityImmune = CreateSlider("PriorityImmune", OptionsPanel, 0, 100, 1, "PriorityImmune")
PriorityImmune:SetScript("OnValueChanged", function(self, value)
  PriorityImmune:SetScale(1)
  PriorityImmune:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Immune" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Immune"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityOther
PriorityOther = CreateSlider("PriorityOther", OptionsPanel, 0, 100, 1, "PriorityOther")
PriorityOther:SetScript("OnValueChanged", function(self, value)
  PriorityOther:SetScale(1)
  PriorityOther:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Other" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Other"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PriorityWarning
PriorityWarning = CreateSlider("PriorityWarning", OptionsPanel, 0, 100, 1, "PriorityWarning")
PriorityWarning:SetScript("OnValueChanged", function(self, value)
  PriorityWarning:SetScale(1)
  PriorityWarning:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority  Warning" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Warning"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local PrioritySnare
PrioritySnare = CreateSlider("PrioritySnare", OptionsPanel, 0, 100, 1, "PrioritySnare")
PrioritySnare:SetScript("OnValueChanged", function(self, value)
  PrioritySnare:SetScale(1)
  PrioritySnare:SetWidth(200)
  _G[self:GetName() .. "Text"]:SetText("Priority Snare" .. " (" .. ("%.0f"):format(value) .. ")")
  EasyCCDB.priority["Snare"] = mathfloor(tonumber(("%.0f"):format(value))) -- the real alpha value
end)

local LossOfControl
LossOfControl = CreateFrame("CheckButton", O .. "LossOfControl", OptionsPanel, "InterfaceOptionsCheckButtonTemplate")
LossOfControl:SetScale(1)
LossOfControl:SetHitRectInsets(0, 0, 0, 0)
_G[O .. "LossOfControlText"]:SetText("LossOfControl")
LossOfControl:SetScript("OnClick", function(self)
  EasyCCDB.LossOfControl = self:GetChecked()
  if self:GetChecked() then
    SetCVar("LossOfControl", 1)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlFull)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlInterrupt)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlSilence)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlDisarm)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlRoot)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlImmune)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlOther)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlWarning)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlSnare)
    BlizzardOptionsPanel_Slider_Enable(PriorityInterrupt)
    BlizzardOptionsPanel_Slider_Enable(PriorityFull)
    BlizzardOptionsPanel_Slider_Enable(PrioritySilence)
    BlizzardOptionsPanel_Slider_Enable(PriorityDisarm)
    BlizzardOptionsPanel_Slider_Enable(PriorityRoot)
    BlizzardOptionsPanel_Slider_Enable(PriorityImmune)
    BlizzardOptionsPanel_Slider_Enable(PriorityOther)
    BlizzardOptionsPanel_Slider_Enable(PriorityWarning)
    BlizzardOptionsPanel_Slider_Enable(PrioritySnare)
    if not LossOfControlFrame_Show_Orig and LossOfControlFrame then
      LossOfControlFrame_Show_Orig = LossOfControlFrame.Show
    end
    LossOfControlFrame.Show = LossOfControlFrame.Hide
  else
    SetCVar("LossOfControl", 0)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlFull)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlInterrupt)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlSilence)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlDisarm)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlRoot)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlImmune)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlOther)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlWarning)
    BlizzardOptionsPanel_Slider_Disable(LossOfControlSnare)
    BlizzardOptionsPanel_Slider_Disable(PriorityInterrupt)
    BlizzardOptionsPanel_Slider_Disable(PriorityFull)
    BlizzardOptionsPanel_Slider_Disable(PrioritySilence)
    BlizzardOptionsPanel_Slider_Disable(PriorityDisarm)
    BlizzardOptionsPanel_Slider_Disable(PriorityRoot)
    BlizzardOptionsPanel_Slider_Disable(PriorityImmune)
    BlizzardOptionsPanel_Slider_Disable(PriorityOther)
    BlizzardOptionsPanel_Slider_Disable(PriorityWarning)
    BlizzardOptionsPanel_Slider_Disable(PrioritySnare)
    if LossOfControlFrame_Show_Orig then
      LossOfControlFrame.Show = LossOfControlFrame_Show_Orig
    end
  end
end)

if Unlock then
  Unlock:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -30)
end
if Scale then
  Scale:SetPoint("TOPLEFT", Unlock, "BOTTOMLEFT", 5, -30)
end
if LossOfControl then
  LossOfControl:SetPoint("TOPLEFT", Scale, "BOTTOMLEFT", 5, -15)
end

if PriorityFull then
  PriorityFull:SetPoint("TOPLEFT", LossOfControl, "BOTTOMLEFT", 0, -22.5)
end
if PriorityInterrupt then
  PriorityInterrupt:SetPoint("TOPLEFT", PriorityFull, "BOTTOMLEFT", 0, -25)
end
if PrioritySilence then
  PrioritySilence:SetPoint("TOPLEFT", PriorityInterrupt, "BOTTOMLEFT", 0, -25)
end
if PriorityDisarm then
  PriorityDisarm:SetPoint("TOPLEFT", PrioritySilence, "BOTTOMLEFT", 0, -25)
end
if PriorityRoot then
  PriorityRoot:SetPoint("TOPLEFT", PriorityDisarm, "BOTTOMLEFT", 0, -25)
end
if PriorityImmune then
  PriorityImmune:SetPoint("TOPLEFT", PriorityRoot, "BOTTOMLEFT", 0, -25)
end
if PriorityOther then
  PriorityOther:SetPoint("TOPLEFT", PriorityImmune, "BOTTOMLEFT", 0, -25)
end
if PriorityWarning then
  PriorityWarning:SetPoint("TOPLEFT", PriorityOther, "BOTTOMLEFT", 0, -25)
end
if PrioritySnare then
  PrioritySnare:SetPoint("TOPLEFT", PriorityWarning, "BOTTOMLEFT", 0, -25)
end

if LossOfControlFull then
  LossOfControlFull:SetPoint("TOPLEFT", LossOfControl, "BOTTOMLEFT", 250, -22.5)
end
if LossOfControlInterrupt then
  LossOfControlInterrupt:SetPoint("TOPLEFT", LossOfControlFull, "BOTTOMLEFT", 0, -25)
end
if LossOfControlSilence then
  LossOfControlSilence:SetPoint("TOPLEFT", LossOfControlInterrupt, "BOTTOMLEFT", 0, -25)
end
if LossOfControlDisarm then
  LossOfControlDisarm:SetPoint("TOPLEFT", LossOfControlSilence, "BOTTOMLEFT", 0, -25)
end
if LossOfControlRoot then
  LossOfControlRoot:SetPoint("TOPLEFT", LossOfControlDisarm, "BOTTOMLEFT", 0, -25)
end
if LossOfControlImmune then
  LossOfControlImmune:SetPoint("TOPLEFT", LossOfControlRoot, "BOTTOMLEFT", 0, -25)
end
if LossOfControlOther then
  LossOfControlOther:SetPoint("TOPLEFT", LossOfControlImmune, "BOTTOMLEFT", 0, -25)
end
if LossOfControlWarning then
  LossOfControlWarning:SetPoint("TOPLEFT", LossOfControlOther, "BOTTOMLEFT", 0, -25)
end
if LossOfControlSnare then
  LossOfControlSnare:SetPoint("TOPLEFT", LossOfControlWarning, "BOTTOMLEFT", 0, -25)
end

local PLoCOptions = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
PLoCOptions:SetFont("Fonts\\FRIZQT__.TTF", 11)
PLoCOptions:SetText(
  "|cffff00000:|r Disables Icon Type \n#: Sets the priority for each spell category \n|cff00ff00#:|r Higher numbers have more priority\n \n "
)
PLoCOptions:SetJustifyH("LEFT")
PLoCOptions:SetPoint("TOPLEFT", PrioritySnare, "TOPLEFT", 0, -25)

local LoCOptions = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
LoCOptions:SetFont("Fonts\\FRIZQT__.TTF", 11)
LoCOptions:SetText(
  "|cffff00000:|r Disables Icon Type \n1: Shows Icon Alert (2 Seconds) \n|cff00ff002:|r Shows Icon for the Full Duration\n \n "
)
LoCOptions:SetJustifyH("LEFT")
LoCOptions:SetPoint("TOPLEFT", LossOfControlSnare, "TOPLEFT", 0, -25)

-------------------------------------------------------------------------------
OptionsPanel.OnDefault = function() -- This method will run when the player clicks "defaults"
  if not LossOfControl:GetChecked() then
    BlizzardOptionsPanel_Slider_Enable(LossOfControlFull)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlInterrupt)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlSilence)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlDisarm)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlRoot)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlFull)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlSilence)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlDisarm)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlRoot)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlImmune)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlOther)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlWarning)
    BlizzardOptionsPanel_Slider_Enable(LossOfControlSnare)
    BlizzardOptionsPanel_Slider_Enable(PriorityInterrupt)
    BlizzardOptionsPanel_Slider_Enable(PriorityFull)
    BlizzardOptionsPanel_Slider_Enable(PriorityInterrupt)
    BlizzardOptionsPanel_Slider_Enable(PrioritySilence)
    BlizzardOptionsPanel_Slider_Enable(PriorityDisarm)
    BlizzardOptionsPanel_Slider_Enable(PriorityRoot)
    BlizzardOptionsPanel_Slider_Enable(PriorityFull)
    BlizzardOptionsPanel_Slider_Enable(PrioritySilence)
    BlizzardOptionsPanel_Slider_Enable(PriorityDisarm)
    BlizzardOptionsPanel_Slider_Enable(PriorityRoot)
    BlizzardOptionsPanel_Slider_Enable(PriorityImmune)
    BlizzardOptionsPanel_Slider_Enable(PriorityOther)
    BlizzardOptionsPanel_Slider_Enable(PriorityWarning)
    BlizzardOptionsPanel_Slider_Enable(PrioritySnare)
  end

  L.Spells:ResetAllSpellList()
  _G.EasyCCDB = nil
  L.Spells:WipeAll()
  EasyCC:ADDON_LOADED(addonName)
  L.Spells:UpdateAll()

  if EasyCC.test then
    EasyCC:toggletest()
  end
  print("|cff00ccffEasyCC|r", "|cffFF7D0A (Cata)|r", ": Reset (Requires Reload for Green Bar & Custom Text Settings)")
end
OptionsPanel.default = OptionsPanel.OnDefault

OptionsPanel.OnRefresh = function()
  -- This method will run when the Interface Options frame calls its OnShow function and after defaults have been applied via the panel.default method described above.
  LossOfControl:SetChecked(EasyCCDB.LossOfControl)
  LossOfControlFull:SetValue(EasyCCDB.durationTime["CC"])
  LossOfControlInterrupt:SetValue(EasyCCDB.durationTime["Interrupt"])
  LossOfControlSilence:SetValue(EasyCCDB.durationTime["Silence"])
  LossOfControlDisarm:SetValue(EasyCCDB.durationTime["Disarm"])
  LossOfControlRoot:SetValue(EasyCCDB.durationTime["Root"])
  LossOfControlImmune:SetValue(EasyCCDB.durationTime["Immune"])
  LossOfControlOther:SetValue(EasyCCDB.durationTime["Other"])
  LossOfControlWarning:SetValue(EasyCCDB.durationTime["Warning"])
  LossOfControlSnare:SetValue(EasyCCDB.durationTime["Snare"])

  PriorityFull:SetValue(EasyCCDB.priority["CC"])
  PriorityInterrupt:SetValue(EasyCCDB.priority["Interrupt"])
  PrioritySilence:SetValue(EasyCCDB.priority["Silence"])
  PriorityDisarm:SetValue(EasyCCDB.priority["Disarm"])
  PriorityRoot:SetValue(EasyCCDB.priority["Root"])
  PriorityImmune:SetValue(EasyCCDB.priority["Immune"])
  PriorityOther:SetValue(EasyCCDB.priority["Other"])
  PriorityWarning:SetValue(EasyCCDB.priority["Warning"])
  PrioritySnare:SetValue(EasyCCDB.priority["Snare"])

  Scale:SetValue(EasyCCDB.Scale)
  AnimateText:SetChecked(EasyCCDB.AnimateText)

  if EasyCC.test then
    Unlock:SetChecked(true)
  else
    Unlock:SetChecked(false)
  end
  if EasyCCDB.LossOfControl then
    SetCVar("lossOfControl", 1)
  else
    SetCVar("lossOfControl", 0)
  end
  if EasyCCDB.durationTime["CC"] == 2 then
    SetCVar("lossOfControlFull", 2)
  elseif EasyCCDB.durationTime["CC"] == 1 then
    SetCVar("lossOfControlFull", 1)
  else
    SetCVar("lossOfControlFull", 0)
  end
  if EasyCCDB.durationTime["Silence"] == 2 then
    SetCVar("lossOfControlSilence", 2)
  elseif EasyCCDB.durationTime["Silence"] == 1 then
    SetCVar("lossOfControlSilence", 1)
  else
    SetCVar("lossOfControlSilence", 0)
  end
  if EasyCCDB.durationTime["Interrupt"] == 2 then
    SetCVar("lossOfControlInterrupt", 2)
  elseif EasyCCDB.durationTime["Interrupt"] == 1 then
    SetCVar("lossOfControlInterrupt", 1)
  else
    SetCVar("lossOfControlInterrupt", 0)
  end
  if EasyCCDB.durationTime["Disarm"] == 2 then
    SetCVar("lossOfControlDisarm", 2)
  elseif EasyCCDB.durationTime["Disarm"] == 1 then
    SetCVar("lossOfControlDisarm", 1)
  else
    SetCVar("lossOfControlDisarm", 0)
  end
  if EasyCCDB.durationTime["Root"] == 2 then
    SetCVar("lossOfControlRoot", 2)
  elseif EasyCCDB.durationTime["Root"] == 1 then
    SetCVar("lossOfControlRoot", 1)
  else
    SetCVar("lossOfControlRoot", 0)
  end
end
OptionsPanel.refresh = OptionsPanel.OnRefresh

if _G.InterfaceOptions_AddCategory then
  InterfaceOptions_AddCategory(OptionsPanel)
elseif Settings and Settings.RegisterCanvasLayoutCategory then
  local cat = Settings.RegisterCanvasLayoutCategory(OptionsPanel, OptionsPanel.name)
  L.settingsCat = cat
  Settings.RegisterAddOnCategory(cat)
end

-------------------------------------------------------------------------------
SLASH_ECC1 = "/ecc"

local SlashCmd = {}

function SlashCmd:reset()
  OptionsPanel.OnDefault()
end

SlashCmdList["ECC"] = function(cmd)
  local args = {}
  for word in cmd:lower():gmatch("%S+") do
    tinsert(args, word)
  end
  if SlashCmd[args[1]] then
    SlashCmd[args[1]](unpack(args))
  else
    print("|cff00ccffEasyCC|r", "|cffFF7D0A (Mists)|r", ': Type "/ecc reset" to reset all settings')
    if _G.InterfaceOptionsFrame_OpenToCategory then
      InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
    elseif Settings and Settings.OpenToCategory then
      Settings.OpenToCategory(L.settingsCat.ID)
    end
  end
end
