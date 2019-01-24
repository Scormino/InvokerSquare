require('AddonScripts/spells/spheres/spheres')
require('AddonScripts/SpellSystem') --для индексации модификаторов
LinkLuaModifier( "invoker_expanse_passivebuff", "AddonScripts/spells/spheres/E/invoker_expanse_passivebuff", LUA_MODIFIER_MOTION_NONE )

invoker_expanse = invoker_expanse or class({})


function invoker_expanse:OnSpellStart()
  local eCaster = self:GetCaster()
  local nAnim = StartRandomCastAnimation(eCaster) --Проигрываем анимацию каста
  ApplyBuffSphere(eCaster, 3, nAnim)   --Создаём новую сферу
end

function invoker_expanse:OnUpgrade()
  local eCaster = self:GetCaster()

  SpellSystem:ApplyBuff({
      eCaster = eCaster,
      eSourceAbility = self,
      sBuff = 'invoker_expanse_passivebuff'
    }
  )
end

function invoker_expanse:OnAutoCast()
  RemoveAllSpheres(self:GetCaster())
  return false  --автокаст не "toogle"
end

