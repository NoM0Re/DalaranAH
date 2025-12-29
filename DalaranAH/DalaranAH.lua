-- *********************************************************
-- **                      DalaranAH                      **
-- **         https://github.com/NoM0Re/DalaranAH         **
-- *********************************************************
--
-- Copyright (c) 2025 NoM0Re
--
-- This software is licensed under the MIT License.

-- Libs
local DalaranAH = LibStub("AceAddon-3.0"):NewAddon("DalaranAH", "AceConsole-3.0", "AceEvent-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DalaranAH")
--@debug@
setglobal("DalaranAH", DalaranAH)
--@end-debug@

-- Check if Libs are loaded
if not DalaranAH then
  error("Addon DalaranAH: Missing Crucial Dependency, Please reinstall the Addon.")
end
if not AC then
  error("Addon DalaranAH: Missing Crucial 'AceConfig-3.0' Dependency, Please reinstall the Addon.")
end
if not ACD then
  error("Addon DalaranAH: Missing Crucial 'AceConfigDialog-3.0' Dependency, Please reinstall the Addon.")
end
if not L then
  error("Addon DalaranAH: Missing Crucial 'AceLocale-3.0' Dependency, Please reinstall the Addon.")
end

-- WoW API locals
local GetBuildInfo = _G.GetBuildInfo
local UnitFactionGroup = _G.UnitFactionGroup
local GetScreenWidth = _G.GetScreenWidth
local GetScreenHeight = _G.GetScreenHeight
local IsSpellKnown = _G.IsSpellKnown
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetUnitName = _G.GetUnitName
local IsShiftKeyDown = _G.IsShiftKeyDown
local InCombatLockdown = _G.InCombatLockdown
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local SelectGossipOption = _G.SelectGossipOption
local GetBindingKey = _G.GetBindingKey
local C_Map = _G.C_Map and _G.C_Map.GetBestMapForUnit or _G.GetCurrentMapAreaID
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata

-- Flavor detection
local WrathClassic = not (select(4, GetBuildInfo()) > 30000 and select(4, GetBuildInfo()) <= 30300)

function DalaranAH.IsWrathClassic()
  return WrathClassic
end

-- Constants / State
local DALARAN_MAP_ID = DalaranAH.IsWrathClassic() and 125 or 505
DalaranAH.AHBotNPCIDA = 35594
DalaranAH.AHBotNPCIDH = 35607
DalaranAH.ENGINEERING_GM = 51306

-- Helpers
function DalaranAH:IsInDalaran()
  return C_Map and C_Map("player") == DALARAN_MAP_ID
end

-- Faction / Profession
function DalaranAH:GetFactionNPCNameAndID()
  local faction = UnitFactionGroup("player")
  if faction == "Horde" then
    return L["Reginald Arcfire"], self.AHBotNPCIDH
  else
    return L["Brassbolt Mechawrench"], self.AHBotNPCIDA
  end
end

function DalaranAH:CheckEngineering()
  return IsSpellKnown(self.ENGINEERING_GM) or false
end

-- Zone
function DalaranAH:ZoneCheck()
  return tostring(GetMinimapZoneText()) == L["Like Clockwork"]
end

-- Tooltip helpers (ugly asf)
function DalaranAH:GenerateTooltips()
  local m1, m2 = GetBindingKey("INTERACTMOUSEOVER")
  local t1, t2 = GetBindingKey("INTERACTTARGET")

  m1 = m1 == "" and nil or m1
  m2 = m2 == "" and nil or m2
  t1 = t1 == "" and nil or t1
  t2 = t2 == "" and nil or t2

  local function fmt(a, b, s)
    return a and b and (L["Press "] .. a .. L[" or "] .. b .. s) or (a or b) and (L["Press "] .. (a or b) .. s)
  end

  local tt = fmt(t1, t2, L[" to interact with Target"])
  local tm = fmt(m1, m2, L[" to interact with Mouseover"])

  return tt or tm and tt,
    tm or tt and tm or L["Bind 'Interact with Target' to interact with the Target"],
    L["Bind 'Interact with Mouseover' to interact with the Mouseover"]
end

-- Button visibility
function DalaranAH:ButtonShow()
  if self:ZoneCheck() and self.Button and self.Model then
    self.Model:SetCreature(self.NPCID)
    self.Button:Show()
    self.Model:SetCamera(0)
  end
end

function DalaranAH:ButtonHide()
  if (not self:ZoneCheck()) and self.Button then
    self.Button:Hide()
  end
end

-- Macro
function DalaranAH:setMacroText(mark, focus)
  local txt = "/tar " .. self.NPCName
  if mark then
    txt = txt
      .. string.format(
        "\n/run local a=GetUnitName('target',1); if a=='%s' then SetRaidTarget('target',%d) end",
        self.NPCName,
        self.db.raidmark
      )
  end
  if focus then
    txt = txt .. "\n/focus"
  end
  return txt
end

-- Button / Model (clean, modern dragging + tooltip)
function DalaranAH:constructButton()
  local templates = "SecureActionButtonTemplate"
  if DalaranAH:IsWrathClassic() then
    templates = templates .. ",BackdropTemplate"
  end
  local btn = CreateFrame("Button", "DalaranAHButton", UIParent, templates)
  self.Button = btn

  btn:SetSize(self.ButtonSize, self.ButtonSize)
  btn:SetPoint("BOTTOMLEFT", self.db.x, self.db.y)
  btn:SetFrameStrata("HIGH")
  btn:SetMovable(true)
  btn:SetClampedToScreen(true)
  btn:Hide()

  btn:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  btn:SetBackdropColor(0, 0, 0, 0.7)
  btn:SetHighlightTexture("")
  btn:SetPushedTexture("")
  btn:SetAttribute("type", "macro")
  btn:SetAttribute("macrotext", self:setMacroText(self.db.mark, self.db.focus))

  -- Tooltip
  btn:SetScript("OnEnter", function(self)
    local l1, l2 = DalaranAH:GenerateTooltips()
    local isTarget = GetUnitName("target", 1) == DalaranAH.NPCName

    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

    if isTarget then
      GameTooltip:SetUnit("target")
      GameTooltip:AddLine(" ")
    else
      GameTooltip:SetText(DalaranAH.NPCName)
      GameTooltip:AddLine("|cffffd100" .. L["Left-click to target"] .. "|r")
    end

    if l1 then
      GameTooltip:AddLine("|cffffd100" .. l1 .. "|r")
    end
    if l2 then
      GameTooltip:AddLine("|cffffd100" .. l2 .. "|r")
    end

    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  btn:SetScript("OnMouseUp", function(self)
    self:GetScript("OnEnter")(self)
  end)
  -- Dragging
  btn:RegisterForDrag("LeftButton")
  btn:SetScript("OnDragStart", function(self)
    if InCombatLockdown() then
      return
    end
    if not IsShiftKeyDown() then
      return
    end
    self:StartMoving()
  end)
  btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    DalaranAH.db.x = self:GetLeft()
    DalaranAH.db.y = self:GetBottom()
  end)
  self.Button:RegisterForClicks("AnyDown")
  -- Model
  local model = CreateFrame("PlayerModel", nil, btn)
  self.Model = model
  model:SetAllPoints(btn)
  model:SetFrameStrata("HIGH")
  model:SetCreature(self.NPCID)
  model:SetCamera(0)
end

-- Events
function DalaranAH:ZONE_CHANGED_NEW_AREA()
  if self:IsInDalaran() and self.Init then
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("GOSSIP_SHOW")
  else
    self:UnregisterEvent("ZONE_CHANGED")
    self:UnregisterEvent("ZONE_CHANGED_INDOORS")
    self:UnregisterEvent("GOSSIP_SHOW")
  end
end

function DalaranAH:ZONE_CHANGED()
  self:ButtonHide()
end

function DalaranAH:ZONE_CHANGED_INDOORS()
  self:ButtonShow()
end

function DalaranAH:GOSSIP_SHOW()
  if self.NPCName and GetUnitName("target", 1) == self.NPCName then
    SelectGossipOption(1)
  end
end

function DalaranAH:SKILL_LINES_CHANGED()
  if not self.Init and self:CheckEngineering() then
    self.Init = true
    self:constructButton()

    self:UnregisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    self:ZONE_CHANGED_NEW_AREA()
    self:ButtonShow()
  end
end

-- SavedVariables
function DalaranAH:InitializeSavedVariables()
  if not DalaranAHDB then
    DalaranAHDB = {}
  end
  self.db = DalaranAHDB

  self.db.size = self.db.size or 70
  self.db.mark = self.db.mark or false
  self.db.focus = self.db.focus or false
  self.db.raidmark = self.db.raidmark or 6

  self.ButtonSize = self.db.size

  local cx = GetScreenWidth() / 2
  local cy = GetScreenHeight() / 2
  self.db.x = self.db.x or (cx - self.ButtonSize / 2)
  self.db.y = self.db.y or (cy - self.ButtonSize / 2)
end

function DalaranAH:ResetToDefaults()
  if not DalaranAHDB then
    DalaranAHDB = {}
  end
  self.db = DalaranAHDB

  self.db.size = 70
  self.db.mark = false
  self.db.focus = false
  self.db.raidmark = 6

  self.ButtonSize = self.db.size

  local cx = GetScreenWidth() / 2
  local cy = GetScreenHeight() / 2
  self.db.x = cx - self.ButtonSize / 2
  self.db.y = cy - self.ButtonSize / 2
  -- Apply Changes
  if self.Button then
    self.Button:SetSize(self.ButtonSize, self.ButtonSize)
    self.Button:ClearAllPoints()
    self.Button:SetPoint("BOTTOMLEFT", self.db.x, self.db.y)
    self.Button:SetAttribute("macrotext", self:setMacroText(self.db.mark, self.db.focus))
  end
end

-- Init
local version = GetAddOnMetadata("DalaranAH", "Version")
--@debug@
if version == "@project-version@" then
  version = "Dev"
end
--@end-debug@
DalaranAH.version = " |c00ffd100DalaranAH " .. version .. "|r"

-- Slash Handler
function DalaranAH:ChatCommandHandler()
  ACD:Open("DalaranAH")
end

function DalaranAH:OnInitialize()
  self:InitializeSavedVariables()
  self.NPCName, self.NPCID = self:GetFactionNPCNameAndID()

  AC:RegisterOptionsTable("DalaranAH", DalaranAH.options)
  ACD:AddToBlizOptions("DalaranAH")

  self:RegisterChatCommand("dalaranah", "ChatCommandHandler")
  self:RegisterChatCommand("dah", "ChatCommandHandler")

  DalaranAH:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function DalaranAH:PLAYER_ENTERING_WORLD()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")

  local function delayedInit()
    if self:CheckEngineering() then
      self.Init = true
      self:constructButton()
      self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
      self:ZONE_CHANGED_NEW_AREA()
      self:ButtonShow()
    else
      self:RegisterEvent("SKILL_LINES_CHANGED")
    end
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(5, delayedInit)
  else
    local f, elapsed = CreateFrame("Frame"), 0
    f:SetScript("OnUpdate", function(_, elaps)
      elapsed = elapsed + elaps
      if elapsed < 5 then
        return
      end
      f:SetScript("OnUpdate", nil)
      delayedInit()
    end)
  end
end
