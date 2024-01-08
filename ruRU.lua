-- Localizations Russian Client
local L = LibStub("AceLocale-3.0"):NewLocale("DalaranAH", "ruRU")
if not L then return end

-- Mandatory that the addon works with ur Language
L["Like Clockwork"] = "Как часы"                                                    -- Must exactly Match DalaranAH RealZoneName use in chat: /run local getcurrentZone = tostring(GetMinimapZoneText());print(getcurrentZone)
L["Brassbolt Mechawrench"] = "Медноштиф Латунник"                                                              -- Must exactly Match NPC Name
L["Press "] = "Press "
L[" to interact with Target"] = " to interact with Target"
L[" or "] = " or "
L[" to interact with Mouseover"] = " to interact with Mouseover"
L["Bind 'Interact with Target' to interact with the Target"] = "Bind 'Interact with Target' to interact with the Target"                        -- Key Bindings Option Name shut match
L["Bind 'Interact with Mouseover' to interact with the Mouseover"] = "Bind 'Interact with Mouseover' to interact with the Mouseover"            -- Key Bindings Option Name shut match
L["Left-click to target"] = "Left-click to target"
L["size"] = "size"
L["Resized Button to "] = "Resized Button to "
L[" px"] = " px"                                            -- not sure if needed
L["Invalid size."] = "Invalid size."
L["Resize Button (min: 10, max: 100, default: 50)"] = "Resize Button (min: 10, max: 100, default: 50)"
L["reset"] = "reset"
L["Button Position reset."] = "Button Position reset."
L["focus"] = "focus"
L["Set Focus: "] = "Set Focus: "                            -- "Set Focus: true" is output
L["mark"] = "mark"
L["Set Mark: "] = "Set Mark: "                              -- "Set Mark: true" is output
L["help"] = "help"
L["DalaranAH Commands"] = "DalaranAH Commands"
L["Arguments to /dah :"] = "Arguments to /dah :"
L["Resets Position to Center"] = "Resets Position to Center"
L["On Button-click sets AHBot to focus"] = "On Button-click sets AHBot to focus"
L["On Button-click gives AHBot a raidmark"] = "On Button-click gives AHBot a raidmark"
L["Prints Help"] = "Prints Help"
