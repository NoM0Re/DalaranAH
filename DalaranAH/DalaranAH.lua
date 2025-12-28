-- *********************************************************
-- **                      DalaranAH                      **
-- **         https://github.com/NoM0Re/DalaranAH         **
-- *********************************************************
--
-- This addon is written and copyrighted by:
-- - NoM0Re
--
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-ShareAlike 4.0 License.
--
--  You are free:
--    * to Share - to copy, distribute, display, and perform the work
--    * to Remix - to make derivative works
--  Under the following conditions:
--    * Attribution. You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).
--    * Noncommercial. You may not use this work for commercial purposes.
--    * Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.

-- Libs
local DalaranAH = LibStub("AceAddon-3.0"):NewAddon("DalaranAH", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DalaranAH")

-- Check if Libs are loaded.
if not DalaranAH then
  error("Addon DalaranAH: Missing Crucial Dependency 'LibStub' or 'AceAddon-3.0', Please reinstall the Addon.")
end
if not AC then
  error("Addon DalaranAH: Missing Crucial Dependency 'AceConfig-3.0', Please reinstall the Addon.")
end
if not ACD then
  error("Addon DalaranAH: Missing Crucial Dependency 'AceConfigDialog-3.0', Please reinstall the Addon.")
end
if not L then
  error("Addon DalaranAH: Missing Crucial Dependency 'AceLocale-3.0', Please reinstall the Addon.")
end

-- WoW API locals
local GetBuildInfo = _G.GetBuildInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
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
local RunNextFrame = _G.RunNextFrame

-- Flavor detection
local WrathClassic = not (select(4, GetBuildInfo()) > 30000 and select(4, GetBuildInfo()) <= 30300)

function DalaranAH.IsWrathClassic()
  return WrathClassic
end

-- Constants / State
local DALARAN_MAP_ID = DalaranAH.IsWrathClassic() and 125 or 505
DalaranAH.AHBotNPCIDA = 35594
DalaranAH.AHBotNPCIDH = 35607
DalaranAH.eventsRegistered = false
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
  return IsSpellKnown(DalaranAH.ENGINEERING_GM) or false
end

-- Zone
function DalaranAH:ZoneCheck()
  return tostring(GetMinimapZoneText()) == L["Like Clockwork"]
end

-- Update Tooltip when Button Clicked
function DalaranAH:UpdateTooltipOnClick()
  if self.Button:GetScript("OnEnter") then
    self.Button:GetScript("OnEnter")(self.Button)
  end
end

-- Tooltip helpers (ugly asf)
function DalaranAH:GenerateTooltips()
  local m1, m2 = GetBindingKey("INTERACTMOUSEOVER")
  local t1, t2 = GetBindingKey("INTERACTTARGET")

  if m1 == "" then
    m1 = nil
  end
  if m2 == "" then
    m2 = nil
  end
  if t1 == "" then
    t1 = nil
  end
  if t2 == "" then
    t2 = nil
  end

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
    DalaranAH:UpdateTooltipOnClick()
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
function DalaranAH:RegisterOurEvents()
  self.EventFrame:RegisterEvent("ZONE_CHANGED")
  self.EventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
  self.EventFrame:RegisterEvent("GOSSIP_SHOW")
end

function DalaranAH:UnregisterOurEvents()
  self.EventFrame:UnregisterEvent("ZONE_CHANGED")
  self.EventFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
  self.EventFrame:UnregisterEvent("GOSSIP_SHOW")
end

function DalaranAH:ZONE_CHANGED_NEW_AREA()
  if self:IsInDalaran() and self.Init then
    if not self.eventsRegistered then
      self:RegisterOurEvents()
      self.eventsRegistered = true
    end
  else
    if self.eventsRegistered then
      self:UnregisterOurEvents()
      self.eventsRegistered = false
    end
  end
end

function DalaranAH:GOSSIP_SHOW()
  if self.NPCName and GetUnitName("target", 1) == self.NPCName then
    SelectGossipOption(1)
  end
end

function DalaranAH:SKILL_LINES_CHANGED()
  if (not self.Init) and self:CheckEngineering() then
    self.Init = true
    self:constructButton()
    self.EventFrame:UnregisterEvent("SKILL_LINES_CHANGED")
    self.EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:ZONE_CHANGED_NEW_AREA()
    self:ButtonShow()
  end
end

local function EventHandler(self, event)
  if event == "ZONE_CHANGED_NEW_AREA" then
    DalaranAH:ZONE_CHANGED_NEW_AREA()
  elseif event == "ZONE_CHANGED_INDOORS" then
    DalaranAH:ButtonShow()
  elseif event == "ZONE_CHANGED" then
    DalaranAH:ButtonHide()
  elseif event == "GOSSIP_SHOW" then
    DalaranAH:GOSSIP_SHOW()
  elseif event == "SKILL_LINES_CHANGED" then
    DalaranAH:SKILL_LINES_CHANGED()
  elseif event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if C_Timer and C_Timer.After then
      C_Timer.After(5, function()
        DalaranAH:PLAYER_ENTERING_WORLD()
      end)
    else
      local f = CreateFrame("Frame")
      f:SetScript("OnUpdate", function(self)
        self:SetScript("OnUpdate", nil)
        self:Hide()
        DalaranAH:PLAYER_ENTERING_WORLD()
      end)
    end
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
DalaranAH.version = " |c00ffd100DalaranAH v" .. GetAddOnMetadata("DalaranAH", "Version") .. "|r"

DalaranAH.EventFrame = CreateFrame("Frame")
DalaranAH.EventFrame:SetScript("OnEvent", EventHandler)
DalaranAH.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

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
end

function DalaranAH:PLAYER_ENTERING_WORLD()
  if self:CheckEngineering() then
    self.Init = true
    self:constructButton()
    self.EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:ZONE_CHANGED_NEW_AREA()
    self:ButtonShow()
  else
    self.EventFrame:RegisterEvent("SKILL_LINES_CHANGED")
  end
  DalaranAH.PLAYER_ENTERING_WORLD = nil
end
