-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

-- Add the field to the colonist summary where age/specialization/dome/etc are.
local function AddWagesToColonistView()
    local XT = XTemplates.ipColonist[1][5] or empty_table

    if not XT.ISHCWagesAdded then
        XT.ISHCWagesAdded = true
        XT[#XT + 1] = PlaceObj('XTemplateTemplate', {
                '__template', "InfopanelText",
                'Text', T{123456789000, --[[XTemplate ipColonist Text]] "Wage<right><UIWorkplaceWages>"},
            })
    end
end

function OnMsg.ClassesPostprocess()
    AddWagesToColonistView()
end

-- Populate the field.
function Colonist:GetUIWorkplaceWages()
    local wages = (self.workplace.wages_level + 1) * 10
    return "$"..wages.."/hr"
end