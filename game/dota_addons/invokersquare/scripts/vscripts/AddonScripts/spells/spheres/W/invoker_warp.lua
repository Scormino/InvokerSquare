require('AddonScripts/spells/spheres/spheres')
require('AddonScripts/SpellSystem') --для индексации модификаторов
LinkLuaModifier( "invoker_warp_passivebuff", "AddonScripts/spells/spheres/W/invoker_warp_passivebuff", LUA_MODIFIER_MOTION_NONE )

invoker_warp = invoker_warp or class({})

function invoker_warp:OnSpellStart()
  local eCaster = self:GetCaster()
  local nAnim = StartRandomCastAnimation(eCaster) --Проигрываем анимацию каста
  ApplyBuffSphere(eCaster, 2, nAnim)   --Создаём новую сферу
end

function invoker_warp:OnUpgrade()
  local eCaster = self:GetCaster()

  SpellSystem:ApplyBuff({
      eCaster = eCaster,
      eSourceAbility = self,
      sBuff = 'invoker_warp_passivebuff'
    }
  )
end

function invoker_warp:OnAutoCast()
  RemoveAllSpheres(self:GetCaster())
  return false  --автокаст не "toogle"
end
