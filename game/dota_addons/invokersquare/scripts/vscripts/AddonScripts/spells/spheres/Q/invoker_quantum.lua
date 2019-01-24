require('AddonScripts/spells/spheres/spheres')
require('AddonScripts/SpellSystem') --для индексации модификаторов
LinkLuaModifier( "invoker_quantum_passivebuff", "AddonScripts/spells/spheres/Q/invoker_quantum_passivebuff", LUA_MODIFIER_MOTION_NONE )

invoker_quantum = invoker_quantum or class({})


function invoker_quantum:OnSpellStart()
  local eCaster = self:GetCaster()
  local nAnim = StartRandomCastAnimation(eCaster) --Проигрываем анимацию каста
  ApplyBuffSphere(eCaster, 1, nAnim)   --Создаём новую сферу
end

function invoker_quantum:OnUpgrade()
  local eCaster = self:GetCaster()

  SpellSystem:ApplyBuff({
      eCaster = eCaster,
      eSourceAbility = self,
      sBuff = 'invoker_quantum_passivebuff'
    }
  )
end

function invoker_quantum:OnAutoCast()
  RemoveAllSpheres(self:GetCaster())
  return false  --автокаст не "toogle"
end
