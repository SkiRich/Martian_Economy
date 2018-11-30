-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

function OnMsg.NewDay(day)
        if day % 10 == 0 then
            ModifyResupplyParams("price", 5)
        end
end