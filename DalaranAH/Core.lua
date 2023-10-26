local L = LibStub("AceLocale-3.0"):GetLocale("DalaranAH")

-- local variables
local DalaranAHButton
local DalaranAHBotModel
local DalaranAHBotNPCID = 35594 -- AH NPC ID
local ButtonSize
local ButtonHalfSize

--Generate Binding Tooltips
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
        if not mBind1 and not mBind2 and not Bind1 and not Bind2 then
            TooltipBind1, TooltipBind2 = L["Bind 'Interact with Target' to interact with the Target"], L["Bind 'Interact with Mouseover' to interact with the Mouseover"]
        end
    return TooltipBind1, TooltipBind2
end

-- Update Tooltip when Button Clicked
local function UpdateTooltipOnClick()
    if DalaranAHButton:GetScript("OnEnter") then
        DalaranAHButton:GetScript("OnEnter")(DalaranAHButton)
    end
end

-- Hide Button
local function DalaranAHButtonHide()
    local getcurrentZone = tostring(GetMinimapZoneText())
    if getcurrentZone ~= L["Like Clockwork"] then 
        if DalaranAHButton then
            DalaranAHButton:Hide()
        end
    end
end

-- Show Button
local function DalaranAHButtonShow()
    if DalaranAHButton then
        DalaranAHButton:Show()
    end
    if DalaranAHBotModel then
        DalaranAHBotModel:SetPosition(0, 0, 0)
        DalaranAHBotModel:SetFacing(0)
        DalaranAHBotModel:SetScale(1)
        DalaranAHBotModel:SetCamera(0)
    end
end

-- Slashcommandhandler: Focus / Mark
local function MacroText()
    local npcName = L["Brassbolt Mechawrench"]
    if DalaranAH.mark == true and DalaranAH.focus == true then 
        DalaranAHButton:SetAttribute("macrotext", "/tar " .. L["Brassbolt Mechawrench"] .. "\n/focus\n/run local GetTargetName = tostring(GetUnitName('target', 1)); if GetTargetName == '".. L["Brassbolt Mechawrench"] .. "' then SetRaidTarget('target', 4) end")
    elseif DalaranAH.mark == false and DalaranAH.focus == true then
        DalaranAHButton:SetAttribute("macrotext", "/tar " .. L["Brassbolt Mechawrench"] .. "\n/focus")
    elseif DalaranAH.mark == true and DalaranAH.focus == false then
        DalaranAHButton:SetAttribute("macrotext", "/tar " .. L["Brassbolt Mechawrench"] .. "\n/run local GetTargetName = tostring(GetUnitName('target', 1)); if GetTargetName == '" .. L["Brassbolt Mechawrench"] .. "' then SetRaidTarget('target', 4) end")
    elseif DalaranAH.mark == false and DalaranAH.focus == false then 
        DalaranAHButton:SetAttribute("macrotext", "/tar ".. L["Brassbolt Mechawrench"])
    end
end

-- Create or Call Button and Model
local function CreateCallDalaranAHButton()

    -- Zone Check
    local getcurrentZone = tostring(GetMinimapZoneText())
    if getcurrentZone ~= L["Like Clockwork"] then return end

    -- Call Button and Model then already exists
    if DalaranAHButton then
        DalaranAHButtonShow()
    return end

    -- Create Button and Model
    DalaranAHButton = CreateFrame("Button", "DalaranAHButton", UIParent, "SecureActionButtonTemplate")
    DalaranAHButton:SetSize(ButtonSize, ButtonSize)
    DalaranAHButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
      })
    DalaranAHButton:SetBackdropColor(0, 0, 0, 0.7)  
    DalaranAHButton:SetBackdropBorderColor(0, 0, 0, 1)   
    DalaranAHButton:SetHighlightTexture(nil)
    DalaranAHButton:SetPushedTexture(nil)
    DalaranAHButton:SetPoint("BOTTOMLEFT", DalaranAH.x, DalaranAH.y)
    DalaranAHButton:SetMovable(true)
    DalaranAHButton:SetUserPlaced(true)
    DalaranAHButton:SetFrameStrata("HIGH")
    DalaranAHButton:SetFrameLevel(1)
    DalaranAHButton:SetAttribute("type", "macro")
    MacroText()
    DalaranAHButton:SetScript("OnEnter", function(self)
        local Tooltip1, Tooltip2 = GenerateTooltips()
        local GetTargetName = tostring(GetUnitName('target', 1))
        if GetTargetName == L["Brassbolt Mechawrench"] then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnit("target")
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("|cffffd100" .. L["Left-click to target"] .. "|r", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("|cffffd100" .. Tooltip1 .. "|r", 1, 1, 1)
        GameTooltip:AddLine("|cffffd100" .. Tooltip2 .. "|r", 1, 1, 1)
        GameTooltip:Show()
        else
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetText(L["Brassbolt Mechawrench"])
        GameTooltip:AddLine("|cffffd100" .. L["Left-click to target"] .. "|r", 1, 1, 1)
        GameTooltip:Show()
        end
    end)
    DalaranAHButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    DalaranAHButton:SetScript("OnMouseDown", function(self, button)
    if IsShiftKeyDown() and button == "LeftButton" then
        self:StartMoving()
    end
    end)
    DalaranAHButton:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        DalaranAH.x, DalaranAH.y = self:GetCenter()
        DalaranAH.x, DalaranAH.y = (DalaranAH.x - ButtonHalfSize), (DalaranAH.y - ButtonHalfSize)
    end
    UpdateTooltipOnClick()
    end)
    DalaranAHButton:RegisterForClicks("AnyDown")

    -- DalaranAHBot Model
    DalaranAHBotModel = CreateFrame("PlayerModel", nil, DalaranAHButton)
    DalaranAHBotModel:SetParent(DalaranAHButton)
    DalaranAHBotModel:SetAllPoints("DalaranAHButton")
    DalaranAHBotModel:SetFrameStrata("HIGH")
    DalaranAHBotModel:SetFrameLevel(2)
    DalaranAHBotModel:SetMovable(true)
    DalaranAHBotModel:SetUserPlaced(true)
    --DalaranAHBotModel:SetUnit("target")
    DalaranAHBotModel:SetCreature(DalaranAHBotNPCID) -- Set AH NPC, out of Cache
    DalaranAHBotModel:SetPosition(0, 0, 0)
    DalaranAHBotModel:SetFacing(0)
    DalaranAHBotModel:SetScale(1)
    DalaranAHBotModel:SetCamera(0)

    DalaranAHButtonShow()
end

-- Slashcommandhandler: Size
local function RefreshButtonSize()
    ButtonSize = tonumber(DalaranAH.size)
    ButtonHalfSize = ButtonSize / 2

    if DalaranAHButton and DalaranAHBotModel then
    DalaranAHButton:SetSize(ButtonSize, ButtonSize)
    DalaranAHBotModel:ClearAllPoints()
    DalaranAHBotModel:SetAllPoints("DalaranAHButton")
    end
end

-- Slashcommandhandler: Reset
local function OnButtonPositionReset()
    local width, height = GetScreenWidth() / 2 - ButtonHalfSize, GetScreenHeight() / 2 - ButtonHalfSize
    DalaranAH.x, DalaranAH.y = width, height

    if DalaranAHButton and DalaranAHBotModel then
    DalaranAHButton:SetPoint("BOTTOMLEFT", DalaranAH.x, DalaranAH.y)
    DalaranAHBotModel:ClearAllPoints()
    DalaranAHBotModel:SetAllPoints("DalaranAHButton")
    end
end

-- Slashcommandhandler: Focus
local function OnFocus()
    if DalaranAH.focus == false then
        DalaranAH.focus = true
    elseif DalaranAH.focus == true then
        DalaranAH.focus = false
    end

    if DalaranAHButton and DalaranAHBotModel then
    MacroText()
    end
end

-- Slashcommandhandler: Mark
local function OnMark()
    if DalaranAH.mark == false then
        DalaranAH.mark = true
    elseif DalaranAH.mark == true then
        DalaranAH.mark = false
    end

    if DalaranAHButton and DalaranAHBotModel then
    MacroText()
    end
end


-- Open AH Selecting first Gossip on Interact
local function OnGossipShow()
    local getcurrentZone = tostring(GetMinimapZoneText())
    if getcurrentZone ~= L["Like Clockwork"] then return end
    if GetUnitName("target") == L["Brassbolt Mechawrench"] then
        SelectGossipOption(1)
    end
end

--Slash Handler

function DalaranAHCommandHandler(msg)
    local DAH = "|cff33ff99DalaranAH > |r"
    msg = string.lower(msg)
    if string.find(msg, L["size"]) then
        local _, _, sizeValue = string.find(msg, L["size"] .. " (%d+)")
        if sizeValue then
            sizeValue = tonumber(sizeValue)
            if sizeValue and sizeValue >= 10 and sizeValue <= 100 then
                DalaranAH.size = sizeValue
                RefreshButtonSize()
                print(DAH .. L["Resized Button to "] .. DalaranAH.size .. L[" px"])
            else
                print(DAH .. "|cFFFFFF00" .. L["Invalid size."] .. "|r")
                print("|cFFFFFF00  " .. L["size"] .. "|r - " .. L["Resize Button (min: 10, max: 100, default: 50)"])
            end
        end

    elseif msg == L["reset"] then
        OnButtonPositionReset()
        print(DAH .. L["Button Position reset."])

    elseif msg == L["focus"] then
        OnFocus()
        print(DAH .. L["Set Focus: "] .. tostring(DalaranAH.focus))

    elseif msg == L["mark"] then
        OnMark()
        print(DAH .. L["Set Mark: "] .. tostring(DalaranAH.mark))

    elseif msg == L["help"] then
        print("|cff33ff99" .. L["DalaranAH Commands"] .. "|r: " .. L["Arguments to /dah :"])
        print("|cFFFFFF00  " .. L["size"] .."|r - " .. L["Resize Button (min: 10, max: 100, default: 50)"])
        print("|cFFFFFF00  ".. L["reset"] .."|r - " .. L["Resets Position to Center"])
        print("|cFFFFFF00  " .. L["focus"] .. "|r - " .. L["On Button-click sets AHBot to focus"])
        print("|cFFFFFF00  " .. L["mark"] .. "|r - " .. L["On Button-click gives AHBot a raidmark"])
    else
        print("|cff33ff99" .. L["DalaranAH Commands"] .. "|r: " .. L["Arguments to /dah :"])
        print("|cFFFFFF00  " .. L["size"] .."|r - " .. L["Resize Button (min: 10, max: 100, default: 50)"])
        print("|cFFFFFF00  ".. L["reset"] .."|r - " .. L["Resets Position to Center"])
        print("|cFFFFFF00  " .. L["focus"] .. "|r - " .. L["On Button-click sets AHBot to focus"])
        print("|cFFFFFF00  " .. L["mark"] .. "|r - " .. L["On Button-click gives AHBot a raidmark"])
        print("|cFFFFFF00  " .. L["help"] .."|r - " .. L["Prints Help"])
    end

end

-- Localisation Warning
local function LocaleWarning()
    local locale = tostring(GetLocale())
    if locale == "enUS" or locale == "enGB" or locale == "deDE" then
        return
    elseif locale == "ruRU" or locale == "zhCN" or locale == "zhTW" or locale == "frFR" or locale == "esES" or locale == "esMX" then
        print("|cff33ff99DalaranAH > |r The localization of your client is incomplete, and the addon works but is mostly in English.")
        print("|cff33ff99DalaranAH > |r Help us complete your localization at: https://github.com/NoM0Re/DalaranAH")
    else
        print("|cff33ff99DalaranAH > |r Your client's localization is not supported, and the addon will not work with your language!")
        print("|cff33ff99DalaranAH > |r Help us add support for your language at: https://github.com/NoM0Re/DalaranAH")
    end
end

-- Init

local function OnInit(frame, event)
    if event == "PLAYER_ENTERING_WORLD" then
        frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        frame = nil

        local width, height
        if not DalaranAH then DalaranAH = {} end
        if DalaranAH.focus == nil then DalaranAH.focus = false end
        if DalaranAH.mark == nil then DalaranAH.mark = false end
        if DalaranAH.size == nil then DalaranAH.size = 50 end
        RefreshButtonSize()
        if not DalaranAH.x or not DalaranAH.y then width, height = GetScreenWidth() / 2 - ButtonHalfSize, GetScreenHeight() / 2 - ButtonHalfSize end
        if not DalaranAH.y then DalaranAH.y = height end
        if not DalaranAH.x then DalaranAH.x = width end

        SLASH_DALARANAH1 = "/dah"
        SLASH_DALARANAH2 = "/dalaranah"
        SlashCmdList["DALARANAH"] = DalaranAHCommandHandler

        LocaleWarning()
        CreateCallDalaranAHButton()
    end
end


-- Register Events to Frames

local Init = CreateFrame("Frame")
Init:RegisterEvent("PLAYER_ENTERING_WORLD")
Init:SetScript("OnEvent", OnInit)

local indoor = CreateFrame("FRAME")
indoor:RegisterEvent("ZONE_CHANGED_INDOORS")
indoor:SetScript("OnEvent", CreateCallDalaranAHButton)

local outdoor = CreateFrame("FRAME")
outdoor:RegisterEvent("ZONE_CHANGED")
outdoor:SetScript("OnEvent", DalaranAHButtonHide)

local gossip = CreateFrame("FRAME")
gossip:RegisterEvent("GOSSIP_SHOW")
gossip:SetScript("OnEvent", OnGossipShow)
