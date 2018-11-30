-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

function Dome:GetAverageWage()
  local wage_sum, wage_earners, average_wage = 0, 0, 0
  local colonists = self.labels.Colonist
  for i = #colonists, 1, -1 do
    local colonist = colonists[i]
    
    if colonist.workplace then
      -- Fail-safe
      if colonist.workplace.wages_level == nil then colonist.workplace.wages_level = 0 end
      --
      wage_sum = wage_sum + colonist.workplace.wages_level
      wage_earners = wage_earners + 1
    end
    
    if wage_earners > 0 then
      average_wage = floatfloor((wage_sum + 0.0) // (wage_earners + 0.0))
    end
  end
  
  return average_wage
end