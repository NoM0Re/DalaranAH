local DalaranAH = LibStub("AceAddon-3.0"):GetAddon("DalaranAH")

local L = LibStub("AceLocale-3.0"):GetLocale("DalaranAH")

-- WoW Api Functions
local GetBindingKey = _G.GetBindingKey
local GetCurrentBindingSet = _G.GetCurrentBindingSet
local SetBinding = _G.SetBinding
local SaveBindings = _G.SaveBindings

-- BlizzOptionsTable
DalaranAH.resetToDefault = "|c00ffd100DalaranAH|r\n" .. L["Reset all settings to default?"]
DalaranAH.options = {
  type = "group",
  name = "",
  args = {
    DalAH = {
      type = "description",
      name = DalaranAH.version,
      order = 0,
      fontSize = "large",
      image = "Interface\\Icons\\Trade_Engineering",
      imageCoords = { 0.1, 0.9, 0.1, 0.9 },
      imageWidth = 30,
      imageHeight = 30,
      width = 1.6,
    },
    resetdefaults = {
      type = "execute",
      name = L["Reset"],
      desc = L["Reset to Defaults"],
      order = 1,
      func = function()
        DalaranAH:ResetToDefaults()
      end,
      confirm = function()
        return DalaranAH.resetToDefault
      end,
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
        DalaranAH.db[i[#i]] = val
        if DalaranAH.Button then
          DalaranAH.Button:SetSize(val, val)
        end
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
        if DalaranAH.Button then
          DalaranAH.Button:SetAttribute("macrotext", DalaranAH:setMacroText(DalaranAH.db.mark, DalaranAH.db.focus))
        end
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
        ["8"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:20|t",
      },
      get = function(i)
        return tostring(DalaranAH.db[i[#i]])
      end,
      set = function(i, val)
        DalaranAH.db[i[#i]] = tonumber(val)
        if DalaranAH.Button then
          DalaranAH.Button:SetAttribute("macrotext", DalaranAH:setMacroText(DalaranAH.db.mark, DalaranAH.db.focus))
        end
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
        if DalaranAH.Button then
          DalaranAH.Button:SetAttribute("macrotext", DalaranAH:setMacroText(DalaranAH.db.mark, DalaranAH.db.focus))
        end
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
      get = function()
        local Bind1, Bind2 = GetBindingKey("INTERACTMOUSEOVER")
        return Bind1 or Bind2
      end,
      set = function(_, val)
        local Bind1, Bind2 = GetBindingKey("INTERACTMOUSEOVER")
        if Bind1 then
          SetBinding(Bind1)
        end
        if Bind2 then
          SetBinding(Bind2)
        end
        if val ~= "ESCAPE" then
          SetBinding(val, "INTERACTMOUSEOVER")
        end
        SaveBindings(GetCurrentBindingSet())
      end,
    },
    target = {
      type = "keybinding",
      name = L["Set Keybind to Interact with Target"],
      order = 12,
      width = "full",
      get = function()
        local Bind1, Bind2 = GetBindingKey("INTERACTTARGET")
        return Bind1 or Bind2
      end,
      set = function(_, val)
        local Bind1, Bind2 = GetBindingKey("INTERACTTARGET")
        if Bind1 then
          SetBinding(Bind1)
        end
        if Bind2 then
          SetBinding(Bind2)
        end
        if val ~= "ESCAPE" then
          SetBinding(val, "INTERACTTARGET")
        end
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
