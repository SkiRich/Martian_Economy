-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

local mod_name = "Martian Economy"
local steam_id = "1575009362"

local function ESDailyPopup()
    CreateRealTimeThread(function()
        local params = {
              title = "Non-Author Mod Copy",
               text = "We have detected an illegal copy version of : ".. mod_name .. ". Please uninstall the existing version.",
            choice1 = "Download the Original [Opens in new window]",
            choice2 = "Damn you copycats!",
            choice3 = "I don't care...",
              image = "UI/Messages/death.tga",
            start_minimized = false,
        } -- params
        local choice = WaitPopupNotification(false, params)
        if choice == 1 then
          OpenUrl("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. steam_id, true)
        end -- if statement
    end ) -- CreateRealTimeThread
end -- function end

function OnMsg.NewDay()
    if table.find(ModsLoaded, "steam_id", "1575009362")~= nil then
    --nothing
    else
        ESDailyPopup()
    end
end -- OnMsg.NewDay()