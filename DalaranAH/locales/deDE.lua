-- Localizations German Client
local L = LibStub("AceLocale-3.0"):NewLocale("DalaranAH", "deDE")
if not L then return end

-- Mandatory that the addon works with ur Language
L["Like Clockwork"] = "Auf die Sekunde"                                                    -- Must exactly Match DalaranAH RealZoneName use in chat: /run local getcurrentZone = tostring(GetMinimapZoneText());print(getcurrentZone)
L["Brassbolt Mechawrench"] = "Kupferbolz Mechazang"                                             -- Must exactly Match NPC Name
L["Press "] = "Drücke "
L[" to interact with Target"] = " um mit Ziel zu interagieren"
L[" or "] = " oder "
L[" to interact with Mouseover"] = " um mit Mouseover zu interagieren"
L["Bind 'Interact with Target' to interact with the Target"] = "Belege 'Mit Ziel interagieren' um mit Ziel zu interagieren"                        -- Key Bindings Option Name shut match
L["Bind 'Interact with Mouseover' to interact with the Mouseover"] = "Belege 'Mit Mouseover interagieren' um mit Mouseover zu interagieren"            -- Key Bindings Option Name shut match
L["Left-click to target"] = "Linksklick um anzuvisieren"
L["size"] = "größe"
L["Resized Button to "] = "Größe des Buttons geändert auf"
L[" px"] = true                                            -- not sure if needed
L["Invalid size."] = "Ungültige Größe."
L["Resize Button (min: 10, max: 100, default: 50)"] = "Button Größe ändern (Min.: 10, Max.: 100, Standard: 50)"
L["reset"] = true
L["Button Position reset."] = "Button Position resetet."
L["focus"] = "fokus"
L["Set Focus: "] = "Setze Fokus: "                            -- "Set Focus: true" is output
L["mark"] = "symbol"
L["Set Mark: "] = "Setze Symbol: "                              -- "Set Mark: true" is output
L["help"] = "hilfe"
L["DalaranAH Commands"] = "DalaranAH Befehle"
L["Arguments to /dah :"] = "Argumente zu /dah :"
L["Resets Position to Center"] = "Setzt die Position auf die Mitte zurück"
L["On Button-click sets AHBot to focus"] = "Beim Klicken des Buttons wird der AHBot in den Fokus gesetzt"
L["On Button-click gives AHBot a raidmark"] = "Beim Klicken des Buttons erhält AHBot ein Schlachtzugssymbol"
L["Prints Help"] = "Zeigt Hilfe"