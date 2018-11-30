-- ========== THIS IS AN AUTOMATICALLY GENERATED FILE! ==========

-- Emigration
function Workplace:GetFreeSlots()
  if self.active_shift > 0 then
    local shift = self.active_shift
    return self.max_workers - self:GetWorkersCount(shift) - (self.closed_workplaces[shift] or 0)
  end
  local sum = 0
  local max = self.max_workers
  for i = 1, self.max_shifts do
    sum = sum + Max(0, max - self:GetWorkersCount(i) - (self.closed_workplaces[i] or 0))
  end
  return sum
end

function GetWorkersCount(bld, shift, unit, is_training)
  if not bld then
    return 0, 0, 0
  end
  local none, workers, max_workers = 0, 0, 0
  if is_training then
    none = 0
    workers = bld:GetVisitorsCount(shift)
    max_workers = bld.max_visitors - (bld.closed_visitor_slots[shift] or 0)
  else
    none = bld:CountWorkersToKick(unit, shift)
    workers = bld:GetWorkersCount(shift)
    max_workers = bld.max_workers - (bld.closed_workplaces[shift] or 0)
  end
  return none, workers, max_workers
end

function Workplace:GetWorkersCount(shift)
  return self.workers and #self.workers[shift] or 0
end

function Workplace:CountWorkersToKick(unit, shift)
  local count = 0
  for s = shift or 1, shift or #self.workers do
    for _, worker in ipairs(self.workers[s]) do
      if self:IsPreferredWorker(unit, worker) then
        count = count + 1
      end
    end
  end
  return count
end

function Workplace:GetWorkerToKick(unit, shift)
  for s = shift or 1, shift or #self.workers do
    for _, worker in ipairs(self.workers[s]) do
      if self:IsPreferredWorker(unit, worker) then
        return worker
      end
    end
  end
end

function Workplace:IsPreferredWorker(unit, worker, ignore_forced, check_performance)
  if not ignore_forced and worker:CheckForcedWorkplace() then
    return false
  end
  if not unit then
    return true
  end
  local specialization = self.specialist
  local worker_specialist = worker.specialist or false
  local unit_specialist = unit.specialist or false
  if worker_specialist ~= specialization and unit_specialist == specialization then
    return true
  end
  if worker_specialist == specialization and unit_specialist ~= specialization then
    return false
  end
  local worker_renegade = worker.traits.Renegade or false
  local unit_renegade = unit.traits.Renegade or false
  if unit_renegade and not worker_renegade then
    return false
  end
  if worker_renegade and not unit_renegade then
    return true
  end
  if not check_performance then
    return false
  end
  return worker.performance < unit.performance
end

local FilterDomeWorkplaces = function(dome, unit, only_specs)
  local dome_workplaces
  local cur_workplace = unit.workplace
  if cur_workplace and unit.lock_workplace then
    if IsKindOf(cur_workplace, "Workplace") then
      dome_workplaces = {cur_workplace}
    end
  elseif unit:CanWork() then
    local dome_dist = dome:GetOutsideWorkplacesDist()
    local avoid_workplace = unit.avoid_workplace
    if avoid_workplace and (not unit.avoid_workplace_start or unit.avoid_workplace_start + g_Consts.AvoidWorkplaceSols < unit.city.day) then
      avoid_workplace = false
    end
    local specialist = unit.specialist
    for _, workplace in ipairs(unit.city.labels.Workplace or empty_table) do
      local parent_dome = workplace.parent_dome
	  if workplace.allow_all_workers == nil then workplace.allow_all_workers = true end
      if (workplace.specialist == specialist or not only_specs) 
      and (workplace.specialist == specialist or workplace.allow_all_workers) 
      and not workplace.destroyed 
      and not workplace.demolishing 
      and (parent_dome == dome or not parent_dome and dome_dist >= HexAxialDistance(workplace, dome)) 
      and workplace.ui_working 
      and workplace.max_workers > 0
      and workplace ~= avoid_workplace 
      and (workplace:GetFreeSlots() > 0 or workplace.specialist == specialist and workplace:GetWorkerToKick(unit, false)) 
      then
        dome_workplaces = dome_workplaces or {}
        dome_workplaces[#dome_workplaces + 1] = workplace
      end
    end
  end
  return dome_workplaces
end

function SmartFindEmigrationDome(colonist)
  local my_dome = colonist.dome
	local pos = colonist.current_dome or colonist:GetPos()
	local forced_dome = colonist:CheckForcedDome()
	if forced_dome then
		if forced_dome == my_dome then
			return
		end
		local is_walking, dist = IsInWalkingDistDome(forced_dome, pos)
		return forced_dome, is_walking, dist
	end
	local can_work = colonist:CanWork()
	--check if match filters to its dome or any other dome
	local traits = colonist.traits
	local is_child = traits.Child
	local eval = -1
	local choosen
	local spec_workplaces, non_spec_workplaces, new_spec_workplaces, new_nonspec_workplaces;
	if my_dome then
		if not my_dome.accept_colonists then
			-- quarantine, no one enters or leaves
			return
		end
		if not colonist:IsHomeless() and (my_dome.ui_working or GameTime() - my_dome.ui_working_changed < wait_dome_turned_off) then
			-- could stay only if not homeless and if the Dome is switched ON
			eval = TraitFilterColonist(my_dome.traits_filter, traits)
		end
    spec_workplaces = FilterDomeWorkplaces(my_dome, colonist, true) --GetFreeWorkplacesAround(my_dome) > 0
    non_spec_workplaces = FilterDomeWorkplaces(my_dome, colonist, false)
  end
  local LR_transport_available = IsLRTransportAvailable(colonist.city)
	local is_unemployed = can_work and not IsValid(colonist.workplace) and not colonist.user_forced_workplace
	local is_walking, dist
	local domes = colonist.city.labels.Dome or false
	if not domes then
		return false
	end
	-- randomize starting dome to avoid moving all colonist to the first one that pass their criteria
	local count_domes = #domes
	local start_idx = colonist:Random(count_domes)
	for i = 1, count_domes do
		local idx = start_idx + i
		if idx>count_domes then 
			idx = idx - count_domes
		end	
		local dome = domes[idx]
		
		if my_dome ~= dome and not dome.destroyed and not dome.demolishing
			and dome.accept_colonists and not dome.overpopulated and dome.ui_working
			and dome:HasPower() and dome:HasWater() and dome:HasAir() 
		then
			-- dome to dome dist is cached, thus IsInWalkingDist is fast
			local new_is_walking, new_dist = IsInWalkingDistDome(dome, pos)
			if new_is_walking or LR_transport_available then
        local new_eval = TraitFilterColonist(dome.traits_filter, traits)
        local free_living_space, free_living_space_adult = dome:GetFreeLivingSpace(true), dome:GetFreeLivingSpace(false)
        
        if new_eval >= 0 and eval <= new_eval then
          new_spec_workplaces = FilterDomeWorkplaces(dome, colonist, true) --GetFreeWorkplacesAround(dome) > 0
          new_nonspec_workplaces = FilterDomeWorkplaces(dome, colonist, false)
        end
        
        local specialist_going_to_specialization = 
          colonist:CanWork() and 
          (
            (IsValid(colonist.workplace) and not colonist.user_forced_workplace and 
            colonist.workplace.specialist ~= colonist.specialist and not spec_workplaces and new_spec_workplaces)
            or
            (not IsValid(colonist.workplace) and not spec_workplaces and new_spec_workplaces) 
          )
        
        if new_eval >= 0 and eval <= new_eval and (
          specialist_going_to_specialization
          or
          ( 
            (
              (colonist:IsHomeless() and not (false and colonist.workplace and colonist.specialist == colonist.workplace.specialist))
              or 
              (is_unemployed and not (spec_workplaces or non_spec_workplaces) and (new_spec_workplaces or new_nonspec_workplaces))
            )             
            and 
            (is_child and free_living_space > 0 or not is_child and free_living_space_adult > 0) 
          )
          or
          (not colonist:CanWork() and eval < new_eval and (is_child and free_living_space > 0 or not is_child and free_living_space_adult > 0))
        ) then       
          if specialist_going_to_specialization then
            local kicked_out_worker
            local new_workplace = ChooseWorkplace(colonist, dome.labels.Workplaces, false)
            if new_workplace then 
              for i_shift = 1, 3 do
                for _, worker in ipairs(new_workplace.workers[i_shift]) do
                  if worker.residence and new_workplace:IsPreferredWorker(colonist, worker) then
                    kicked_out_worker = worker 
                  end
                end
              end
              local residence_to_take = kicked_out_worker and kicked_out_worker.residence
              
              if kicked_out_worker and residence_to_take then
                kicked_out_worker:SetResidence(false)
                residence_to_take:ReserveResidence(colonist)
              end
              
              if residence_to_take or free_living_space_adult > 0 then
                choosen = dome
                eval = new_eval
                is_walking = new_is_walking
                dist = new_dist
              end
            end
          else
            choosen = dome
            eval = new_eval
            is_walking = new_is_walking
            dist = new_dist
          end
        end
      end
		end --if my_dome ~= dome and not dome.destroyed and not dome.demolishing
  end --for i = 1, count_domes do
  return choosen, is_walking, dist
end
	
VanillaFindEmigrationDome = Colonist.FindEmigrationDome
Colonist.FindEmigrationDome = SmartFindEmigrationDome