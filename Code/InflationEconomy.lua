-- Code developed for Martian Economy
-- Author @EagleScout93 and @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- But you may not copy it, package it, or claim it as your own.
-- Created Nov 30th, 2018
-- Updated Nov 30th, 2018


function OnMsg.NewDay(day)
        if day % 10 == 0 then
            ModifyResupplyParams("price", 5)
        end
end