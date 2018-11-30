-- Code developed for Martian Economy
-- Author @EagleScout93 and @SkiRich
-- All rights reserved, duplication and modification prohibited.
-- But you may not copy it, package it, or claim it as your own.
-- Created Nov 30th, 2018
-- Updated Nov 30th, 2018




local PlaceWealthButton = function(wealth_level, wealth_type)
  local IdName = "idWealthButton"..tostring(wealth_level)  -- skirichs code to add
  return PlaceObj
  (
    "XTemplateWindow",
    {
      "__class",
      "XTextButton",
      "RolloverTemplate",
      "Rollover",
      "MouseCursor",
      "UI/Cursors/Rollover.tga",
      "FocusOrder",
      point(1000, 1),
      "RolloverText",
      T({
        990000000040,
        ""
      }),
      "RolloverTitle",
      T({
        990000000041,
        "Wealth Level"
      }),
      "RolloverHint",
      T({
        990000000042,
        "",
      }),
      "Id", IdName, -- skirich added
      "Dock",
      "right",
      "VAlign",
      "center",
      "OnPress",
      function(self, gamepad)
        local building = ResolvePropObj(self.context)

        if wealth_type == "wages" then
					building.wages_level = wealth_level
				elseif wealth_type == "rents" then
					building.rents_level = wealth_level
				elseif wealth_type == "prices" then
					building.prices_level = wealth_level
				end

        ObjModified(building)
      end,
      "OnContextUpdate",
      function(self, context)
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
				end

      end,
      "Image",
      "UI/Infopanel/infopanel_workshift_time.tga",
      "Rows",
      2,
      "ColumnsUse",
      "abbbb"
    }
  )
end

function OnMsg.ClassesBuilt()
  XTemplates.customServiceWealth = PlaceObj("XTemplate", { PlaceObj
  (
    "XTemplateForEach",
    {
      "array",
      function(parent, context)
        return nil, 1, 1
      end,
      "map",
      function(parent, context, array, i)
        return i
      end,
      "item_in_context",
      "Service"
    },
    {
      PlaceObj(
        "XTemplateTemplate",
        {
          "__template",
          "InfopanelActiveSection",
          "Icon",
          "UI/Icons/Sections/Funding.tga",
          "Title",
          T({990000000043, "Prices Level"}),
        },
        {
          PlaceWealthButton(4,"prices"),PlaceWealthButton(3,"prices"), PlaceWealthButton(2,"prices"), PlaceWealthButton(1,"prices"), PlaceWealthButton(0,"prices"),
        }
      )
    }
  )})

  XTemplates.customWorkplaceWealth = PlaceObj("XTemplate", { PlaceObj
  (
    "XTemplateForEach",
    {
      "array",
      function(parent, context)
        return nil, 1, 1
      end,
      "map",
      function(parent, context, array, i)
        return i
      end,
      "item_in_context",
      "Workplace"
    },
    {
      PlaceObj(
        "XTemplateTemplate",
        {
          "__template",
          "InfopanelActiveSection",
          "Icon",
          "UI/Icons/Sections/Funding.tga",
          "Title",
          T({990000000044, "Wages Level"}),
        },
        {
          PlaceWealthButton(4,"wages"), PlaceWealthButton(3,"wages"), PlaceWealthButton(2,"wages"), PlaceWealthButton(1,"wages"), PlaceWealthButton(0,"wages"),
        }
      )
    }
  )})

	XTemplates.customResidenceWealth = PlaceObj("XTemplate", { PlaceObj
  (
    "XTemplateForEach",
    {
      "array",
      function(parent, context)
        return nil, 1, 1
      end,
      "map",
      function(parent, context, array, i)
        return i
      end,
      "item_in_context",
      "Residence"
    },
    {
      PlaceObj(
        "XTemplateTemplate",
        {
          "__template",
          "InfopanelActiveSection",
          "Icon",
          "UI/Icons/Sections/Funding.tga",
          "Title",
          T({990000000045, "Rents Level"}),
        },
        {
          PlaceWealthButton(4,"rents"), PlaceWealthButton(3,"rents"), PlaceWealthButton(2,"rents"), PlaceWealthButton(1,"rents"), PlaceWealthButton(0,"rents"),
        }
      )
    }
  )})

  XTemplates.sectionCustom = PlaceObj('XTemplate', {
      group = "Infopanel Sections",
      id = "sectionCustom",
      XTemplates.sectionCustom,
      PlaceObj('XTemplateTemplate', {
          '__context_of_kind', "Service",
          '__template', "customServiceWealth",
      }),
      PlaceObj('XTemplateTemplate', {
          '__context_of_kind', "Residence",
          '__template', "customResidenceWealth",
      }),
      PlaceObj('XTemplateTemplate', {
          '__context_of_kind', "Workplace",
          '__template', "customWorkplaceWealth",
      }),
  })
end