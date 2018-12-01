-- Code developed for Martian Economy
-- Author @EagleScout93 and @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- But you may not copy it, package it, or claim it as your own.
-- Created Nov 30th, 2018
-- Updated Nov 30th, 2018

local lf_print = false -- Setup debug printing in local file
                       -- Use if lf_print then print("something") end

local ModDir = CurrentModPath


local PlaceWealthButton = function(wealth_level, wealth_type)
  local IdName = "idWealthButton"..tostring(wealth_level)  -- skirichs code to add
  return PlaceObj ("XTemplateWindow", {
      "__class", "XTextButton",
      "RolloverTemplate", "Rollover",
      "MouseCursor", "UI/Cursors/Rollover.tga",
      "FocusOrder", point(1000, 1),
      "RolloverText", T({990000000040, ""}),
      "RolloverTitle", T({990000000041, "Wealth Level"}),
      "RolloverHint", T({990000000042, ""}),
      "Id", IdName, -- skirich added
      "Dock", "right",
      "VAlign", "center",
      "OnPress", function(self, gamepad)
        local building = ResolvePropObj(self.context)

        if wealth_type == "wages" then
					building.wages_level = wealth_level
				elseif wealth_type == "rents" then
					building.rents_level = wealth_level
				elseif wealth_type == "prices" then
					building.prices_level = wealth_level
				end

        ObjModified(building)
      end, -- OnPress
      "OnContextUpdate", function(self, context)
        local building = ResolvePropObj(self.context)

				building.wages_level = building.wages_level or 0
				building.rents_level = building.rents_level or 0
				building.prices_level = building.prices_level or 0

        if wealth_type == "wages" then
					if building.wages_level >= wealth_level then
						self:SetImage("UI/Infopanel/infopanel_workshift_active.tga")
					else
						self:SetImage("UI/Infopanel/infopanel_workshift_stop.tga")
					end
				elseif wealth_type == "rents" then
					if wealth_level == 0 then
						for i = #building.colonists, 1, -1 do
							local resident = building.colonists[i]
							if resident.workplace and resident.workplace.wages_level == nil then resident.workplace.wages_level = 0 end
							if (building.rents_level > 0 and not resident.workplace)
							or (resident.workplace and resident.workplace.wages_level < building.rents_level) then
								resident:SetResidence(false)
								resident:UpdateResidence()
							end
						end
					else
						if building.rents_level >= wealth_level then
							self:SetImage("UI/Infopanel/infopanel_workshift_active.tga")
						else
							self:SetImage("UI/Infopanel/infopanel_workshift_stop.tga")
						end
					end
				elseif wealth_type == "prices" then
					if building.prices_level >= wealth_level then
						self:SetImage("UI/Infopanel/infopanel_workshift_active.tga")
					else
						self:SetImage("UI/Infopanel/infopanel_workshift_stop.tga")
					end
				end -- if wealth_type

      end, -- OnContextUpdate
      "Image", "UI/Infopanel/infopanel_workshift_time.tga",
      "Rows", 2,
      "ColumnsUse", "abbbb"
  }) -- end PlaceObject
end -- PlaceWealthButton


------------------------------- OnMsgs ---------------------------------------------------


function OnMsg.ClassesBuilt()
	local XTemplates = XTemplates
  local ObjModified = ObjModified
  local PlaceObj = PlaceObj
  local MESectionID01 = "MESection-01"
  local MESectionID02 = "MESection-02"
  local MESectionID03 = "MESection-03"
  local MEObjVer  = "v1.0"
  local XT = XTemplates.ipBuilding[1]

  if lf_print then print("Loaded Classes ME_1_UI_Templates.lua") end

  -- Service buildings
  -- retrofit versioning
  if XT.ME_ServiceBuildings then
  	if lf_print then print("Retro fitting ME_ServiceBuildings in ME_1_UI_Templates in ipBuilding") end
  	for i, obj in pairs(XT or empty_table) do
  		if type(obj) == "table" and obj.__context_of_kind == "Service" and
  		 (obj.UniqueID == MESectionID01) and (obj.Version ~= MEObjVer) then
  			table.remove(XT, i)
  			if lf_print then print("Removed old ME_ServiceBuildings in ME_1_UI_Templates Class Button") end
  			XT.ME_ServiceBuildings = nil
  		end -- if obj
  	end -- for each obj
  end -- retrofix versioning

  -- build the classes just once per game
  if not XT.ME_ServiceBuildings then
    XT.ME_ServiceBuildings = true

    local idx = 1 -- Insert first before all other panels
    --Check for Cheats Menu and insert before Cheats menu
    --local foundcheats, idx = table.find_value(XT, "__template", "sectionCheats")

    --alter the ipBuilding panel for ME
    table.insert(XT, idx,
      PlaceObj("XTemplateTemplate", {
        "UniqueID", MESectionID01,
        "Version", MEObjVer,
        "Id", "idME_ServiceBuilding",
        "__context_of_kind", "Service",
        --"__condition", function (parent, context) return end,
        "__template", "InfopanelActiveSection",
        "Icon", "UI/Icons/Sections/Funding.tga",
        "Title", T({990000000043, "Prices Level"}),
      },{
         PlaceWealthButton(4,"prices"),PlaceWealthButton(3,"prices"), PlaceWealthButton(2,"prices"), PlaceWealthButton(1,"prices"), PlaceWealthButton(0,"prices"),
      }) -- end PlaceObject
    ) -- end table.insert
  end -- if not XT.ME_ServiceBuildings



  -- Workplace buildings
  -- retrofit versioning
  if XT.ME_WorkPlaceBuildings then
  	if lf_print then print("Retro fitting ME_WorkPlaceBuildings in ME_1_UI_Templates in ipBuilding") end
  	for i, obj in pairs(XT or empty_table) do
  		if type(obj) == "table" and obj.__context_of_kind == "Workplace" and
  		 (obj.UniqueID == MESectionID02) and (obj.Version ~= MEObjVer) then
  			table.remove(XT, i)
  			if lf_print then print("Removed old ME_WorkPlaceBuildings in ME_1_UI_Templates Class Button") end
  			XT.ME_WorkPlaceBuildings = nil
  		end -- if obj
  	end -- for each obj
  end -- retrofix versioning


  -- build the classes just once per game
  if not XT.ME_WorkPlaceBuildings then
    XT.ME_WorkPlaceBuildings = true

    local idx = 2 -- Insert after the Service Buildings panel
    --Check for Cheats Menu and insert before Cheats menu
    --local foundcheats, idx = table.find_value(XT, "__template", "sectionCheats")

    --alter the ipBuilding panel for ME wages
    table.insert(XT, idx,
      PlaceObj("XTemplateTemplate", {
        "UniqueID", MESectionID02,
        "Version", MEObjVer,
        "Id", "idME_WorkPlaceBuilding",
        "__context_of_kind", "Workplace",
        --"__condition", function (parent, context) return end,
        "__template", "InfopanelActiveSection",
        "Icon", "UI/Icons/Sections/Funding.tga",
        "Title", T({990000000044, "Wages Level"}),
      },{
         PlaceWealthButton(4,"wages"), PlaceWealthButton(3,"wages"), PlaceWealthButton(2,"wages"), PlaceWealthButton(1,"wages"), PlaceWealthButton(0,"wages"),
      }) -- end PlaceObject
    ) -- end table.insert

  end -- if not XT.ME_WorkPlaceBuildings



  -- Residence buildings
  -- retrofit versioning
  if XT.ME_ResidenceBuildings then
  	if lf_print then print("Retro fitting ME_ResidenceBuildings in ME_1_UI_Templates in ipBuilding") end
  	for i, obj in pairs(XT or empty_table) do
  		if type(obj) == "table" and obj.__context_of_kind == "Residence" and
  		 (obj.UniqueID == MESectionID03) and (obj.Version ~= MEObjVer) then
  			table.remove(XT, i)
  			if lf_print then print("Removed old ME_ResidenceBuildings in ME_1_UI_Templates Class Button") end
  			XT.ME_ResidenceBuildings = nil
  		end -- if obj
  	end -- for each obj
  end -- retrofix versioning


  -- build the classes just once per game
  if not XT.ME_ResidenceBuildings then
    XT.ME_ResidenceBuildings = true

    local idx = 1 -- Insert first in panel
    --Check for Cheats Menu and insert before Cheats menu
    --local foundcheats, idx = table.find_value(XT, "__template", "sectionCheats")

    --alter the ipBuilding panel for ME rents
    table.insert(XT, idx,
      PlaceObj("XTemplateTemplate", {
        "UniqueID", MESectionID03,
        "Version", MEObjVer,
        "Id", "idME_ResidenceBuilding",
        "__context_of_kind", "Residence",
        --"__condition", function (parent, context) return end,
        "__template", "InfopanelActiveSection",
        "Icon", "UI/Icons/Sections/Funding.tga",
        "Title", T({990000000045, "Rents Level"}),
      },{
         PlaceWealthButton(4,"rents"), PlaceWealthButton(3,"rents"), PlaceWealthButton(2,"rents"), PlaceWealthButton(1,"rents"), PlaceWealthButton(0,"rents"),
      }) -- end PlaceObject
    ) -- end table.insert

  end -- if not XT.ME_ResidenceBuildings

end -- OnMsg.ClassesBuilt()
