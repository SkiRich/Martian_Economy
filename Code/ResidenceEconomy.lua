-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

function NewChooseResidence(unit)
  local is_child = unit.traits.Child
  local buildings = unit.city.labels.Residence or empty_table
  local max_score
  local current_score = unit.residence and unit.residence.service_comfort
  local best_building = false
  for i = 1, #buildings do
    local home = buildings[i]
    local is_children_only = home.children_only
    
    -- Fail-safe
    if home.rents_level == nil then home.rents_level = 0 end
    if unit.workplace and unit.workplace.wages_level == nil then unit.workplace.wages_level = 0 end
    --
    
    if ((unit.workplace and unit.workplace.wages_level >= home.rents_level) or home.rents_level == 0) and IsValid(home) and not home.destroyed and not home.demolishing and home.parent_dome == unit.dome and home:GetFreeSpace() > 0 and (not is_children_only or is_children_only and is_child) then
      local score = home.service_comfort
      if is_child and is_children_only then
        score = score * 2
      end
      if best_building then
        local best_working = best_building.ui_working
        local home_working = home.ui_working
        if not best_working and home_working then
          max_score = score
          best_building = home
        elseif best_working and home_working and (score > max_score or max_score == score and Random(0, 100) < 50) then
          max_score = score
          best_building = home
        end
      elseif not max_score or score > max_score or max_score == score and Random(0, 100) < 50 then
        max_score = score
        best_building = home
      end
    end
  end
  if (not max_score or current_score and current_score >= max_score) and (unit.residence and unit.residence.ui_working or best_building and not best_building.ui_working) then
    return unit.residence
  end
  return best_building
end

VanillaChooseResidence = ChooseResidence
ChooseResidence = NewChooseResidence