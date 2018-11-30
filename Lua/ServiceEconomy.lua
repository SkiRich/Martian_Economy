-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

function CanServiceEmployed(service, unit)
  local is_child = unit.traits.Child
  if is_child and not service.usable_by_children or not is_child and service.children_only then
    return false
  end
  if service:DoesHaveConsumption() and service.consumption_type == g_ConsumptionType.Visit and service.consumption_stored_resources <= 0 then
    return false
  end
  
  -- Fail-safe
  if service.prices_level == nil or service.prices_level == true then service.prices_level = 0 end
  if unit.workplace and unit.workplace.wages_level == nil then unit.workplace.wages_level = 0 end
  --
  
  if (unit.workplace and unit.workplace.wages_level >= service.prices_level or service.prices_level == 0) then
    return true
  end
  
  return false
end

Service.CanService = CanServiceEmployed