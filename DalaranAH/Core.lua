-- Libs
local L = LibStub("AceLocale-3.0"):GetLocale("DalaranAH")

-- WoW Api Functions
local IsSpellKnown = IsSpellKnown
local GetBinding = GetBinding
local GetMinimapZoneText = GetMinimapZoneText
local GetUnitName = GetUnitName
local IsShiftKeyDown = IsShiftKeyDown
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local SelectGossipOption = SelectGossipOption
local CreateFrame, GameTooltip = CreateFrame, GameTooltip
local GetLocale = GetLocale

-- local Variables
local AHButton
local BotModel
local DalaranAHBotNPCID = 35594 -- AH NPC ID
local ButtonSize
local ButtonHalfSize

local function CheckEngineering() -- Engineering Grandmaster
    if IsSpellKnown(51306) then return true end
    return false
end

local function ZoneCheck()
    return tostring(GetMinimapZoneText()) == L["Like Clockwork"]
end

-- Open AH Selecting first Gossip on Interact
local function OnGossipShow()
    if not ZoneCheck() then return end
    if GetUnitName("target") == L["Brassbolt Mechawrench"] then SelectGossipOption(1) end
end

-- Update Tooltip when Button Clicked
local function UpdateTooltipOnClick()
    if AHButton:GetScript("OnEnter") then AHButton:GetScript("OnEnter")(AHButton) end
end

-- Generate Binding Tooltips
local function GenerateTooltips()
    local _, Bind1, Bind2 = GetBinding(116) -- INTERACTTARGET
    local _, mBind1, mBind2 = GetBinding(115) -- INTERACTMOUSEOVER
    local TooltipBind1
    local TooltipBind2
    --case1
    if Bind1 and not Bind2 then
        TooltipBind1 = L["Press "] .. Bind1 .. L[" to interact with Target"]
    elseif not Bind1 and Bind2 then
        TooltipBind1 = L["Press "] .. Bind2 .. L[" to interact with Target"]
    elseif Bind1 and Bind2 then
        TooltipBind1 = L["Press "] .. Bind1 .. L[" or "] .. Bind2 .. L[" to interact with Target"]
    end
    --case2
    if mBind1 and not mBind2 then
        TooltipBind2 = L["Press "] .. mBind1 .. L[" to interact with Mouseover"]
    elseif not mBind1 and mBind2 then
        TooltipBind2 = L["Press "] .. mBind2 .. L[" to interact with Mouseover"]
    elseif mBind1 and mBind2 then
        TooltipBind2 = L["Press "] .. mBind1 .. L[" or "] .. mBind2 .. L[" to interact with Mouseover"]
    end
    --case3
    if not mBind1 and not mBind2 and not Bind1 and not Bind2 then TooltipBind1, TooltipBind2 = L["Bind 'Interact with Target' to interact with the Target"], L["Bind 'Interact with Mouseover' to interact with the Mouseover"] end
    return TooltipBind1, TooltipBind2
end

local function ChatPrint(str)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage(str);
    end
end

-- Hide Button
local function ButtonHide()
    if not ZoneCheck() and AHButton then
    AHButton:Hide()
    end
end

-- Show Button
local function ButtonShow()
    if ZoneCheck() and AHButton and BotModel then
        AHButton:Show()
        BotModel:SetCreature(DalaranAHBotNPCID) -- in case model is not in cache
        BotModel:SetCamera(0) -- has to be called again, because its PlayerModel
    end
end

-- Slashcommandhandler: Focus / Mark
local function setMacroText(mark, focus)
    local macroText = "/tar " .. L["Brassbolt Mechawrench"]
    if mark and focus then
        macroText = macroText .. "\n/focus\n/run local GetTargetName = tostring(GetUnitName('target', 1)); if GetTargetName == '" .. L["Brassbolt Mechawrench"] .. "' then SetRaidTarget('target', 4) end"
    elseif mark then
        macroText = macroText .. "\n/run local GetTargetName = tostring(GetUnitName('target', 1)); if GetTargetName == '" .. L["Brassbolt Mechawrench"] .. "' then SetRaidTarget('target', 4) end"
    elseif focus then
        macroText = macroText .. "\n/focus"
    end
    return macroText
end
-- Create Button and Model
local function constructButton()
    -- Button with Backdrop
    AHButton = CreateFrame("Button", "AHButton", UIParent, "SecureActionButtonTemplate")
    AHButton:Hide()
    AHButton:SetSize(ButtonSize, ButtonSize)
    AHButton:SetPoint("BOTTOMLEFT", DalaranAH.x, DalaranAH.y)
    AHButton:SetFrameStrata("HIGH")
    AHButton:SetFrameLevel(1)
    AHButton:SetMovable(true)
    AHButton:SetUserPlaced(true)
    AHButton:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeSize = 1,
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            },
        })
    AHButton:SetBackdropColor(0, 0, 0, 0.7)
    AHButton:SetBackdropBorderColor(0, 0, 0, 1)
    AHButton:SetHighlightTexture(nil)
    AHButton:SetPushedTexture(nil)
    AHButton:SetAttribute("type", "macro")
    AHButton:SetAttribute("macrotext", setMacroText(DalaranAH.mark, DalaranAH.focus)) -- Call Function
    AHButton:SetScript(
        "OnEnter",
        function(self)
            local Tooltip1, Tooltip2 = GenerateTooltips()
            local GetTargetName = tostring(GetUnitName("target", 1))
            if GetTargetName == L["Brassbolt Mechawrench"] then
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:SetUnit("target")
                GameTooltip:AddLine(" ", 1, 1, 1)
                if Tooltip1 then
                    GameTooltip:AddLine("|cffffd100" .. Tooltip1 .. "|r", 1, 1, 1)
                end
                if Tooltip2 then
                    GameTooltip:AddLine("|cffffd100" .. Tooltip2 .. "|r", 1, 1, 1)
                end
                GameTooltip:Show()
            else
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                GameTooltip:SetText(L["Brassbolt Mechawrench"])
                GameTooltip:AddLine("|cffffd100" .. L["Left-click to target"] .. "|r", 1, 1, 1)
                GameTooltip:Show()
            end
        end
    )

    AHButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    AHButton:SetScript("OnMouseDown", function(self, button) if IsShiftKeyDown() and button == "LeftButton" then self:StartMoving() end end)
    AHButton:SetScript("OnMouseUp",
        function(self, button)
            if button == "LeftButton" then
                self:StopMovingOrSizing()
                DalaranAH.x, DalaranAH.y = self:GetCenter()
                DalaranAH.x, DalaranAH.y = DalaranAH.x - ButtonHalfSize, DalaranAH.y - ButtonHalfSize
            end

            UpdateTooltipOnClick()
        end
    )
    AHButton:RegisterForClicks("AnyDown")

    -- DalaranAHBot Model
    BotModel = CreateFrame("PlayerModel", nil, AHButton)
    BotModel:SetParent(AHButton) -- Needs debug if needed
    BotModel:SetAllPoints("AHButton")
    BotModel:SetFrameStrata("HIGH")
    BotModel:SetFrameLevel(2)
    BotModel:SetMovable(true)
    BotModel:SetUserPlaced(true)
    BotModel:SetCreature(DalaranAHBotNPCID) -- Set AH NPC, out of Cache
    BotModel:SetCamera(0)
    BotModel:SetScale(1)
    BotModel:SetFacing(0)
end

-- Slashcommandhandler: Size
local function RefreshButtonSize()
    ButtonSize = tonumber(DalaranAH.size)
    ButtonHalfSize = ButtonSize / 2
    if AHButton and BotModel then
        AHButton:SetSize(ButtonSize, ButtonSize)
        BotModel:SetAllPoints("AHButton")
    end
end

-- Slashcommandhandler: Reset
local function OnButtonPositionReset()
    local width, height = GetScreenWidth() / 2 - ButtonHalfSize, GetScreenHeight() / 2 - ButtonHalfSize
    DalaranAH.x, DalaranAH.y = width, height
    if AHButton then
        AHButton:SetPoint("BOTTOMLEFT", DalaranAH.x, DalaranAH.y)
    end
end

-- Slashcommandhandler: Focus
local function OnFocus()
    DalaranAH.focus = not DalaranAH.focus -- Toggles on/off
    if AHButton and BotModel then
        AHButton:SetAttribute("macrotext", setMacroText(DalaranAH.mark, DalaranAH.focus))
    end
end

-- Slashcommandhandler: Mark
local function OnMark()
    DalaranAH.mark = not DalaranAH.mark -- Toggles on/off
    if AHButton and BotModel then
        AHButton:SetAttribute("macrotext", setMacroText(DalaranAH.mark, DalaranAH.focus))
    end
end

-- Slash Help
local function SlashHelp(showHelp)
ChatPrint(string.format("|cff33ff99" .. L["DalaranAH Commands"] .. "|r: " .. L["Arguments to /dah :"]));
ChatPrint(string.format("|cFFFFFF00  " .. L["size"] .. "|r - " .. L["Resize Button (min: 10, max: 100, default: 50)"]))
ChatPrint(string.format("|cFFFFFF00  " .. L["reset"] .. "|r - " .. L["Resets Position to Center"]))
ChatPrint(string.format("|cFFFFFF00  " .. L["focus"] .. "|r - " .. L["On Button-click sets AHBot to focus"]))
ChatPrint(string.format("|cFFFFFF00  " .. L["mark"] .. "|r - " .. L["On Button-click gives AHBot a raidmark"]))
if showHelp == false then
    ChatPrint(string.format("|cFFFFFF00  " .. L["help"] .. "|r - " .. L["Prints Help"]))
end
end

-- Slash Handler
function DalaranAHCommandHandler(msg)
    local DAH = "|cff33ff99DalaranAH > |r"
    msg = string.lower(msg)
    if string.find(msg, L["size"]) then
        local _, _, sizeValue = string.find(msg, L["size"] .. " (%d+)")
        if sizeValue then
            sizeValue = tonumber(sizeValue)
            if sizeValue >= 10 and sizeValue <= 100 then
                DalaranAH.size = sizeValue
                RefreshButtonSize()
                ChatPrint(string.format(DAH .. L["Resized Button to "] .. DalaranAH.size .. L[" px"]));
            end
        else
            ChatPrint(string.format(DAH .. "|cFFFFFF00" .. L["Invalid size."] .. "|r"));
            ChatPrint(string.format("|cFFFFFF00  " .. L["size"] .. "|r - " .. L["Resize Button (min: 10, max: 100, default: 50)"]));
        end
    elseif msg == L["reset"] then
        OnButtonPositionReset()
        ChatPrint(string.format(DAH .. L["Button Position reset."]));
    elseif msg == L["focus"] then
        OnFocus()
        ChatPrint(string.format(DAH .. L["Set Focus: "] .. tostring(DalaranAH.focus)));
    elseif msg == L["mark"] then
        OnMark()
        ChatPrint(string.format(DAH .. L["Set Mark: "] .. tostring(DalaranAH.mark)));
    elseif msg == L["help"] then
        SlashHelp(true)
    else
        SlashHelp(false)
    end
end

-- Localisation Warning
local function LocaleWarning()
    local locale = tostring(GetLocale())
    if locale == "enUS" or locale == "enGB" or locale == "deDE" then
        return true
    elseif locale == "ruRU" or locale == "zhCN" or locale == "zhTW" or locale == "frFR" or locale == "esES" or locale == "esMX" then
        ChatPrint(string.format("|cff33ff99DalaranAH > |r The localization of your client is incomplete, the addon works but is mostly in English, Help us complete your localization at: https://github.com/NoM0Re/DalaranAH"))
        return true
    else
        ChatPrint(string.format("|cff33ff99DalaranAH > |r The localization of your client is not supported, the addon will not work with your language, help us add support for your language at: https://github.com/NoM0Re/DalaranAH"))
        return false
    end
end

-- Init Saved Variables
local function InitializeSavedVariables()
    if not DalaranAH then DalaranAH = {} end
    if DalaranAH.focus == nil then DalaranAH.focus = false end
    if DalaranAH.mark == nil then DalaranAH.mark = false end
    if DalaranAH.size == nil then DalaranAH.size = 50 end
    RefreshButtonSize()
    local width, height = GetScreenWidth() / 2 - ButtonHalfSize, GetScreenHeight() / 2 - ButtonHalfSize
    if not DalaranAH.y then DalaranAH.y = height end
    if not DalaranAH.x then DalaranAH.x = width end
end

-- Init Addon
local function OnInit(frame)
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    InitializeSavedVariables()
    if CheckEngineering() and LocaleWarning() then
        constructButton()
        ButtonShow()
    end
end

-- Create EventsFrames for Events
local Init = CreateFrame("Frame")
Init:RegisterEvent("PLAYER_ENTERING_WORLD")
Init:SetScript("OnEvent", OnInit)

local indoor = CreateFrame("Frame")
indoor:RegisterEvent("ZONE_CHANGED_INDOORS")
indoor:SetScript("OnEvent", ButtonShow)

local outdoor = CreateFrame("Frame")
outdoor:RegisterEvent("ZONE_CHANGED")
outdoor:SetScript("OnEvent", ButtonHide)

local gossip = CreateFrame("Frame")
gossip:RegisterEvent("GOSSIP_SHOW")
gossip:SetScript("OnEvent", OnGossipShow)

-- Register Slash Command Handler
SlashCmdList["DALARANAH"] = DalaranAHCommandHandler
SLASH_DALARANAH1 = "/dah"
SLASH_DALARANAH2 = "/dalaranah"
