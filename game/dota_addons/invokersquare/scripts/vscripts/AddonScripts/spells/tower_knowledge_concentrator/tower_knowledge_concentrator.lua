tower_knowledge_concentrator = tower_knowledge_concentrator or class({})

local sBuff = "tower_knowledge_concentrator_buff"
LinkLuaModifier(sBuff, "AddonScripts/spells/tower_knowledge_concentrator/" .. sBuff, LUA_MODIFIER_MOTION_NONE )

function tower_knowledge_concentrator:OnUpgrade()
  if IsServer() then
    local eUnit = self:GetCaster()

    if hMode and hMode.ExpSystem then
      if not eUnit:HasModifier(sBuff) then
        SpellSystem:ApplyBuff({
            eParent = eUnit,
            eCaster = eUnit,
            --eSourceAbility = self,
            sBuff = sBuff,
            --hStats = {duration = self.nDuration}
          }
        )        
        hMode.ExpSystem.nAbilIndex_eExpAbil = hMode.ExpSystem.nAbilIndex_eExpAbil or {}
      
        table.insert(hMode.ExpSystem.nAbilIndex_eExpAbil, self)
      end
      hMode.ExpSystem.Refresh()
    end
  end
end

function tower_knowledge_concentrator:OnDestroy()
  if IsServer() then
    local bRefresh = false
    for nAbilIndex, eExpAbil in pairs(hMode.ExpSystem.nAbilIndex_eExpAbil) do
      if self == eExpAbil then
        bRefresh = true
        table.remove(hMode.ExpSystem.nAbilIndex_eExpAbil[nAbilIndex], nAbilIndex)
        break
      end
    end
    if bRefresh then
      hMode.ExpSystem.Refresh()
    end
  end
  print("tower_knowledge_concentrator:OnDestroy()")
end

