require('AddonScripts/SpellSystem')


sQ = 'invoker_quantum'
sW = 'invoker_warp'
sE = 'invoker_expanse'
sR = 'invoker_reconstruction'


--local Q, W, E, R = QWERSystemGetAbilityLevel(self:GetParent())

QWERSystem = QWERSystem or class({})
QWERSystem.QWER = {sQ, sW, sE, sR}


function QWERSystem:GetAbsByReconstructionSpell(eObj, sSpell)
  local hRes
  if IsServer() then
    local hNewObj = self:GetReconstructionSS(eObj:GetCaster(), sSpell) or eObj:GetCaster()
    hRes = self:ABSAsync(eObj, hNewObj)
  end
  return Sync(hRes, (eObj.GetName and eObj:GetName()) or eObj.sObj)
end


--[[
  1 arg:
  hObj  --объект у которого обновяться уровни

  2 args:
  hObj  --объект, которому присвоятся уровни
  hNewObj --объект с нужными уровнями

  3 args: 
  hObj  --объект, которому присвоятся уровни
  eOwnerBuffs --Владелец способности с нужными уровнями
  sSpell --способность у владельца, если таковой нет, то берётся уровень владельца
]]
function QWERSystem:Apply(...)  --Общая функция управления SS
  local hArgs = {...}

  local hObj = hArgs[1]
  if hObj then
    if #hArgs == 1 then
      return self:ABS(hObj)
    end

    local hQWER = {}
    if IsServer() then
      local hNewObj
      if #hArgs == 2 then
        hNewObj = hArgs[2]
      else --#hArgs == 3
        local eOwnerBuffs = hArgs[2]
        local sSpell = hArgs[3]

        hNewObj = self:GetReconstructionSS(eOwnerBuffs, sSpell) or eOwnerBuffs
      end
      hQWER = self:ABSAsync(hObj, hNewObj)
    end

    hQWER = Sync(hQWER, hObj)
    return hQWER
  end
end

function QWERSystem:GetReconstructionSS(eUnit, spell)
  if eUnit and spell then
    local eR = eUnit:FindAbilityByName(sR)
    if eR and eR.Spells then
      if type(spell) == 'number' then
        local nSpellMemorySlot = spell

        local SSpell = eR.Spells[nSpellMemorySlot]
        return SSpell
      elseif type(spell) == 'string' then
        local sSpell = spell

        local i
        for i = 1, 5 do
          local SSpell = eR.Spells[i]
          if SSpell and SSpell.sObj == sSpell then
            return SSpell
          end
        end
      end
    end
  end
end




function QWERSystem:GetQWER(hObj, eOwnerLevels)

end

--[[
function RefreshAllQWER(eUnit)
  RefreshAllSS(eUnit, {sQ, sW, sE, sR})
  local hSyncTable = Table2StringTable({base=GetSSOutQWERLevel(eUnit), add = {}}) --нейтрализуем утечки
  CustomNetTables:SetTableValue('tooltips', 'unit_'..eUnit:GetEntityIndex(), hSyncTable)
  CustomGameEventManager:Send_ServerToAllClients( "RefreshTooltips", nil )
end
]]

function QWERSystem:ABSAsync(hObj, eOwnerLevels)
  eOwnerLevels = eOwnerLevels or (not hObj.FindAllModifiers and not hObj.GetAbilityName and hObj.GetCaster and hObj:GetCaster()) or true
  return SpellSystem:ABS(hObj, self.QWER, eOwnerLevels)
end

function QWERSystem:ABS(hObj, eOwnerLevels, SyncKey)
  local hQWER
  if IsServer() then
    hQWER = self:ABSAsync(hObj, eOwnerLevels)
  end

  return Sync(hQWER, SyncKey or (hObj.GetEntityIndex and hObj:GetEntityIndex()))
end
--[[
function QWERSystem:BASE(hObj, eOwnerLevels)
  return SpellSystem:ABS(hObj, self.nSpellIndex_sSpellName, eOwnerLevels or true)
end
]]