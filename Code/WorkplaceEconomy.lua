-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

local OldOnChangeWorkshift = Workplace.OnChangeWorkshift

Workplace.OnChangeWorkshift = function(workplace, old, new)  
  if old then
    -- Fail-safe
    if workplace.wages_level == nil then workplace.wages_level = 0 end
    
    for _, worker in ipairs(workplace.workers[old]) do
      local dome = worker.dome
      local avg_wage = dome:GetAverageWage()
      local effect = (workplace.wages_level - avg_wage) * 2 * const.Scale.Stat
      
      worker:ChangeComfort(effect, "Received wage")
      
      local display_text
      if effect > 0 then 
        display_text = T({990000000046, "<green>Earns more than average +<amount> (Wage)</green>"})
      else 
        display_text = T({990000000047, "<red>Earns less than average <amount> (Wage)</red>"})
      end
    
      worker:SetModifier("base_morale", "wage_level", effect, 0, display_text)
    end
  end
  OldOnChangeWorkshift(workplace, old, new)
end