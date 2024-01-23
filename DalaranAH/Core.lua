-- *********************************************************
-- **                      DalaranAH                      **
-- **         https://github.com/NoM0Re/DalaranAH         **
-- *********************************************************
--
-- This addon is written and copyrighted by:
-- - NoM0Re
--
-- The localizations are written by:
--    * enGB/enUS: NoM0Re
--    * deDE: NoM0Re
--
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 4.0 License.
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
if not DalaranAH then error("Addon DalaranAH: Missing Crucial Dependency 'LibStub' or 'AceAddon-3.0', Please reinstall the Addon.") end
if not AC then error("Addon DalaranAH: Missing Crucial Dependency 'AceConfig-3.0', Please reinstall the Addon.") end
if not ACD then error("Addon DalaranAH: Missing Crucial Dependency 'AceConfigDialog-3.0', Please reinstall the Addon.") end
if not L then error("Addon DalaranAH: Missing Crucial Dependency 'AceLocale-3.0', Please reinstall the Addon.") end

-- WoW Api Functions
local GetLocale = GetLocale
local GetAddOnMetadata = GetAddOnMetadata
local UnitFactionGroup = UnitFactionGroup
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local IsSpellKnown = IsSpellKnown
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetMinimapZoneText = GetMinimapZoneText
local GetUnitName = GetUnitName
local IsShiftKeyDown = IsShiftKeyDown
local CreateFrame, GameTooltip = CreateFrame, GameTooltip
local SelectGossipOption = SelectGossipOption
local SetBinding, SaveBindings = SetBinding, SaveBindings
local GetBindingKey, GetCurrentBindingSet = GetBindingKey, GetCurrentBindingSet

-- NPC IDs
DalaranAH.AHBotNPCIDA = 35594 -- AH NPC Alliance ID
DalaranAH.AHBotNPCIDH = 35607 -- AH NPC Horde ID

-- FactionCheck
function DalaranAH:GetFactionNPCNameAndID()
    local faction = UnitFactionGroup("player")
    if faction == "Horde" then
        return L["Reginald Arcfire"], self.AHBotNPCIDH
    elseif faction == "Alliance" then
        return L["Brassbolt Mechawrench"], self.AHBotNPCIDA
    end
end

-- Check if we are Engineering Grandmaster
function DalaranAH:CheckEngineering()
    if IsSpellKnown(51306) then return true end
    return false
end

-- Check if we are in the Auctionhouse
function DalaranAH:ZoneCheck()
    return tostring(GetMinimapZoneText()) == L["Like Clockwork"]
end

-- Update Tooltip when Button Clicked
function DalaranAH:UpdateTooltipOnClick()
    if self.Button:GetScript("OnEnter") then self.Button:GetScript("OnEnter")(self.Button) end
end

-- Generate Binding Tooltips
function DalaranAH:GenerateTooltips()
    local mBind1, mBind2 = GetBindingKey("INTERACTMOUSEOVER") -- INTERACTMOUSEOVER
    local Bind1, Bind2 = GetBindingKey("INTERACTTARGET") -- INTERACTTARGET
    if mBind1 == "" then mBind1 = nil end if mBind2 == "" then mBind2 = nil end -- Needed because of Keybinds can be "" when nil
    if Bind1 == "" then Bind1 = nil end if Bind2 == "" then Bind2 = nil end -- Needed because of Keybinds can be "" when nil

    local TooltipBind1, TooltipBind2
    --case1 INTERACTTARGET
    if Bind1 and not Bind2 then
        TooltipBind1 = L["Press "] .. Bind1 .. L[" to interact with Target"]
    elseif not Bind1 and Bind2 then
        TooltipBind1 = L["Press "] .. Bind2 .. L[" to interact with Target"]
    elseif Bind1 and Bind2 then
        TooltipBind1 = L["Press "] .. Bind1 .. L[" or "] .. Bind2 .. L[" to interact with Target"]
    end
    --case2 INTERACTMOUSEOVER
    if mBind1 and not mBind2 then
        TooltipBind2 = L["Press "] .. mBind1 .. L[" to interact with Mouseover"]
    elseif not mBind1 and mBind2 then
        TooltipBind2 = L["Press "] .. mBind2 .. L[" to interact with Mouseover"]
    elseif mBind1 and mBind2 then
        TooltipBind2 = L["Press "] .. mBind1 .. L[" or "] .. mBind2 .. L[" to interact with Mouseover"]
    end
    --case3 both not
    if not mBind1 and not mBind2 and not Bind1 and not Bind2 then TooltipBind1, TooltipBind2 = L["Bind 'Interact with Target' to interact with the Target"], L["Bind 'Interact with Mouseover' to interact with the Mouseover"] end
    return TooltipBind1, TooltipBind2
end

-- Prints Addon messages
function DalaranAH:ChatPrint(str)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(str) end
end

-- Hide Button
function DalaranAH:ButtonHide()
    if (not self:ZoneCheck()) and self.Button and self.Button:IsShown() then self.Button:Hide() end
end

-- Show Button
function DalaranAH:ButtonShow()
    if self:ZoneCheck() and self.Button and self.Model then
        self.Model:SetCreature(self.NPCID) -- in case model is not in cache
        self.Button:Show()
        self.Model:SetCamera(0) -- has to be called again, because its PlayerModel
    end
end

-- Update Macrotext on Settings change
function DalaranAH:setMacroText(mark, focus)
    local macroText = "/tar " .. self.NPCName
    if not mark and not focus then
        return macroText
    elseif mark and focus then
        macroText = macroText .. string.format("\n/focus\n/run local a = tostring(GetUnitName('target', 1)); if a == '%s' then SetRaidTarget('target', %d) end", self.NPCName, self.db.raidmark)
    elseif mark then
        macroText = macroText .. string.format("\n/run local a = tostring(GetUnitName('target', 1)); if a == '%s' then SetRaidTarget('target', %d) end", self.NPCName, self.db.raidmark)
    elseif focus then
        macroText = macroText .. "\n/focus"
    end
    return macroText
end

-- Create GUI Button and Model
function DalaranAH:constructButton()
    -- Button with Backdrop
    self.Button = CreateFrame("Button", "DalaranAHButton", UIParent, "SecureActionButtonTemplate")
    self.Button:Hide()
    self.Button:SetSize(self.ButtonSize, self.ButtonSize)
    self.Button:SetPoint("BOTTOMLEFT", self.db.x, self.db.y)
    self.Button:SetFrameStrata("HIGH")
    self.Button:SetFrameLevel(1)
    self.Button:SetMovable(true)
    self.Button:SetUserPlaced(true)
    self.Button:SetClampedToScreen(true)
    self.Button:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeSize = 1,
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0 },
            })
    self.Button:SetBackdropColor(0, 0, 0, 0.7)
    self.Button:SetBackdropBorderColor(0, 0, 0, 1)
    self.Button:SetHighlightTexture(nil)
    self.Button:SetPushedTexture(nil)
    self.Button:SetAttribute("type", "macro")
    self.Button:SetAttribute("macrotext", self:setMacroText(self.db.mark, self.db.focus)) -- Call Function
    self.Button:SetScript("OnEnter",
        function(self)
            local Tooltip1, Tooltip2 = DalaranAH:GenerateTooltips()
            local GetTargetName = tostring(GetUnitName("target", 1))
            if GetTargetName == DalaranAH.NPCName then
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:SetUnit("target")
                GameTooltip:AddLine(" ", 1, 1, 1)
                if Tooltip1 then GameTooltip:AddLine("|cffffd100" .. Tooltip1 .. "|r", 1, 1, 1) end
                if Tooltip2 then GameTooltip:AddLine("|cffffd100" .. Tooltip2 .. "|r", 1, 1, 1) end
                GameTooltip:Show()
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:SetText(DalaranAH.NPCName)
            GameTooltip:AddLine("|cffffd100" .. L["Left-click to target"] .. "|r", 1, 1, 1)
            GameTooltip:Show()
        end)
    self.Button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.Button:SetScript("OnMouseDown", function(self, button) if IsShiftKeyDown() and button == "LeftButton" then self:StartMoving() end end)
    self.Button:SetScript("OnMouseUp",
        function(self, button)
            if button == "LeftButton" then
                self:StopMovingOrSizing()
                DalaranAH.db.x, DalaranAH.db.y = self:GetCenter()
                DalaranAH.db.x, DalaranAH.db.y = DalaranAH.db.x - DalaranAH.ButtonHalfSize, DalaranAH.db.y - DalaranAH.ButtonHalfSize
            end
            DalaranAH:UpdateTooltipOnClick()
        end)
    self.Button:RegisterForClicks("AnyDown")
    -- DalaranAHBot Model
    self.Model = CreateFrame("PlayerModel", nil, DalaranAH.Button)
    self.Model:SetParent(DalaranAH.Button) -- Needs debug if needed
    self.Model:SetAllPoints("DalaranAHButton")
    self.Model:SetFrameStrata("HIGH")
    self.Model:SetFrameLevel(2)
    self.Model:SetCreature(self.NPCID) -- Set AH NPC, out of Cache
    self.Model:SetCamera(0)
    self.Model:SetScale(1)
    self.Model:SetFacing(0)
end

-- Slash Handler
function DalaranAH:ChatCommandHandler()
    ACD:Open("DalaranAH")
end

DalaranAH.version = " |c00ffd100DalaranAH v" .. GetAddOnMetadata("DalaranAH", "Version") .. "|r"
DalaranAH.nosupport = " |c00b22222DalaranAH v" .. GetAddOnMetadata("DalaranAH", "Version") .. " - Client not Supported|r"
-- Localization Warning
function DalaranAH:LocaleWarning()
    local locale = tostring(GetLocale())
    local supportedLocales = {"enUS", "enGB", "deDE", "ruRU", "zhCN", "frFR", "zhTW", "esES", "esMX"}
    for _, Supported in ipairs(supportedLocales) do
        if Supported == locale then
            return true
        end
    end
    self.version = self.nosupport
    self:ChatPrint("|cff33ff99DalaranAH > |r Your client's localization is not supported. Help us add support for your language at: https://github.com/NoM0Re/DalaranAH")
    return false
end

-- Init Saved Variables
function DalaranAH:InitializeSavedVariables()
    if not DalaranAHDB then DalaranAHDB = {} end
    self.db = DalaranAHDB
    if self.db.size == nil then self.db.size = 70 end
    self.ButtonSize = self.db.size
    self.ButtonHalfSize = self.db.size / 2
    local width, height = GetScreenWidth() / 2 - self.ButtonHalfSize, GetScreenHeight() / 2 - self.ButtonHalfSize
    if not self.db.y then self.db.y = height end
    if not self.db.x then self.db.x = width end
    if self.db.mark == nil then self.db.mark = false end
    if self.db.raidmark == nil then self.db.raidmark = 6 end
    if self.db.focus == nil then self.db.focus = false end
end

-- Reset Button
function DalaranAH:ResetToDefaults()
    if not DalaranAHDB then DalaranAHDB = {} end
    self.db = DalaranAHDB
    self.db.size = 70
    self.ButtonSize = self.db.size
    self.ButtonHalfSize = self.db.size / 2
    local width, height = GetScreenWidth() / 2 - self.ButtonHalfSize, GetScreenHeight() / 2 - self.ButtonHalfSize
    self.db.y = height
    self.db.x = width
    self.db.mark = false
    self.db.raidmark = 6
    self.db.focus = false
    -- Apply Changes
    if self.Button and self.Model then self.Button:SetSize(self.ButtonSize, self.ButtonSize) end
    if self.Button then self.Button:SetAttribute("macrotext", self:setMacroText(self.db.mark, self.db.focus)) end
end

-- Entered Dalaran register Events
function DalaranAH:RegisterOurEvents()
    self.EventFrame:RegisterEvent("ZONE_CHANGED")
    self.EventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    self.EventFrame:RegisterEvent("GOSSIP_SHOW")
end

-- Leave Dalaran unregister Events
function DalaranAH:UnregisterOurEvents()
    self.EventFrame:UnregisterEvent("ZONE_CHANGED")
    self.EventFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
    self.EventFrame:UnregisterEvent("GOSSIP_SHOW")
end

-- On ZONE_CHANGED_NEW_AREA register/unregister Events
function DalaranAH:ZONE_CHANGED_NEW_AREA()
    local isInDalaran = GetCurrentMapAreaID() == 505
    if isInDalaran and self.Init then
        self:RegisterOurEvents()
    else
        self:UnregisterOurEvents()
    end
end

-- On GOSSIP_SHOW click first Gossip of AHBot
function DalaranAH:GOSSIP_SHOW()
    if DalaranAH.NPCName and GetUnitName("target", 1) == DalaranAH.NPCName then SelectGossipOption(1) end
end

-- On SKILL_LINES_CHANGED check if we are now Engineering Grandmaster, if so startup addon
function DalaranAH:SKILL_LINES_CHANGED()
    if (not self.Init) and self:CheckEngineering() and self:LocaleWarning() then
        self.Init = true
        self:constructButton()
        self.EventFrame:UnregisterEvent("SKILL_LINES_CHANGED")
        self.EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        self:ZONE_CHANGED_NEW_AREA()
        self:ButtonShow()
    end
end

-- Event Handler
local function EventHandler(_, event)
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
    end
end

-- BlizzOptionsTable
DalaranAH.resetToDefault = "|c00ffd100DalaranAH|r\n" .. L["Reset all settings to default?"]
local options = {
    type = "group",
    name = "",
    args = {
        DalAH = {
            type = "description",
            name = DalaranAH.version,
            order = 0,
            fontSize = "large",
            image = "Interface\\Icons\\Trade_Engineering",
            imageCoords = {0.1,0.9,0.1,0.9},
            imageWidth = 30,
            imageHeight = 30,
            width = 1.6,
        },
        resetdefaults = {
            type = "execute",
            name = L["Reset"],
            desc = L["Reset to Defaults"],
            order = 1,
            func = function() DalaranAH:ResetToDefaults() end,
            confirm = function() return DalaranAH.resetToDefault end,
            width = 0.4,
        },
        header = {
            type = "header",
            name = L["General"],
            order = 2,
        },
        size = {
            type = "range",
            name = L["Button Size"],
            order = 3,
            width = "full",
            min = 20,
            softMax = 120,
            step = 1,
            get = function(i)
                return DalaranAH.db[i[#i]]
            end,
            set = function(i, val)
                DalaranAH.db[i[#i]] = tonumber(val)
                DalaranAH.ButtonSize = tonumber(DalaranAH.db.size)
                DalaranAH.ButtonHalfSize = DalaranAH.ButtonSize / 2
                if DalaranAH.Button and DalaranAH.Model then DalaranAH.Button:SetSize(DalaranAH.ButtonSize, DalaranAH.ButtonSize) end
            end,
        },
        spacer = {
            type = "description",
            name = " ",
            order = 4,
            width = "full",
        },
        header1 = {
            type = "header",
            name = L["Additional Functions"],
            order = 5,
        },
        mark = {
            type = "toggle",
            name = L["Set Mark on the Auctioneer"],
            desc = L["On-Click sets Mark on the Auctioneer"],
            order = 6,
            get = function(i)
                return DalaranAH.db[i[#i]]
            end,
            set = function(i, val)
                DalaranAH.db[i[#i]] = val
                if DalaranAH.Button then DalaranAH.Button:SetAttribute("macrotext", DalaranAH:setMacroText(DalaranAH.db.mark, DalaranAH.db.focus)) end
            end,
            width = 1.2,
        },
        raidmark = {
            type = "select",
            name = L["Select the Mark"],
            order = 7,
            values = {
                ["1"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1:20|t",
                ["2"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_2:20|t",
                ["3"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_3:20|t",
                ["4"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_4:20|t",
                ["5"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_5:20|t",
                ["6"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_6:20|t",
                ["7"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_7:20|t",
                ["8"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:20|t"
            },
            get = function(i)
                return tostring(DalaranAH.db[i[#i]])
            end,
            set = function(i, val)
                DalaranAH.db[i[#i]] = tonumber(val)
                if DalaranAH.Button then DalaranAH.Button:SetAttribute("macrotext", DalaranAH:setMacroText(DalaranAH.db.mark, DalaranAH.db.focus)) end
            end,
        },
        focus = {
            type = "toggle",
            name = L["Set Auctioneer as Focus"],
            desc = L["On-Click sets Auctioneer as Focus"],
            order = 8,
            width = "full",
            get = function(i)
                return DalaranAH.db[i[#i]]
            end,
            set = function(i, val)
                DalaranAH.db[i[#i]] = val
                if DalaranAH.Button then DalaranAH.Button:SetAttribute("macrotext", DalaranAH:setMacroText(DalaranAH.db.mark, DalaranAH.db.focus)) end
            end,
        },
        spacer1 = {
            type = "description",
            name = " ",
            order = 9,
            width = "full",
        },
        header4 = {
            type = "header",
            name = L["Keybinds"],
            order = 10,
        },
        mouseover = {
            type = "keybinding",
            name = L["Set Keybind to Interact with Mouseover"],
            order = 11,
            width = "full",
            get = function() local Bind1, Bind2 = GetBindingKey("INTERACTMOUSEOVER") return Bind1 or Bind2 end,
            set = function(_, val)
                local Bind1, Bind2 = GetBindingKey("INTERACTMOUSEOVER")
                if Bind1 then SetBinding(Bind1) end
                if Bind2 then SetBinding(Bind2) end
                if val ~= "ESCAPE" then SetBinding(val, "INTERACTMOUSEOVER") end
                SaveBindings(GetCurrentBindingSet())
            end,
        },
        target = {
            type = "keybinding",
            name = L["Set Keybind to Interact with Target"],
            order = 12,
            width = "full",
            get = function() local Bind1, Bind2 = GetBindingKey("INTERACTTARGET") return Bind1 or Bind2 end,
            set = function(_, val)
                local Bind1, Bind2 = GetBindingKey("INTERACTTARGET")
                if Bind1 then SetBinding(Bind1) end
                if Bind2 then SetBinding(Bind2) end
                if val ~= "ESCAPE" then SetBinding(val, "INTERACTTARGET") end
                SaveBindings(GetCurrentBindingSet())
            end,
        },
        spacer2 = {
            type = "description",
            name = "\n",
            order = 13,
            width = "full",
        },
        github = {
            type = "header",
            name = "Github: |c007289d9https://github.com/NoM0Re/DalaranAH|r",
            order = 14,
        },
    },
}

-- EventFrame
DalaranAH.EventFrame = CreateFrame("Frame")
DalaranAH.EventFrame:SetScript("OnEvent", EventHandler)

-- Init
local timer = CreateFrame("Frame")
function DalaranAH:OnInitialize()
    self:InitializeSavedVariables()
    self.NPCName, self.NPCID = self:GetFactionNPCNameAndID()
    if self:CheckEngineering() and self:LocaleWarning() then
        self.Init = true
        self:constructButton()
        self.EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        -- C_Timer mimik until MiniMap information is available, calling get Zone and Button show
        local time = 0
        timer:SetScript("OnUpdate", function(self, elapsed)
            time = time + elapsed
            if time >= 18 then
                self:SetScript("OnUpdate", nil)
                DalaranAH:ZONE_CHANGED_NEW_AREA()
                DalaranAH:ButtonShow()
            end
        end)
    elseif (not self:CheckEngineering()) and self:LocaleWarning() then
        self.EventFrame:RegisterEvent("SKILL_LINES_CHANGED")
    end
    AC:RegisterOptionsTable("DalaranAH", options)
    ACD:AddToBlizOptions("DalaranAH")
    self:RegisterChatCommand("dalaranah", "ChatCommandHandler")
    self:RegisterChatCommand("dah", "ChatCommandHandler")
    self.OnInitialize = nil
end
