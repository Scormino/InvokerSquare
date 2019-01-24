require('AddonScripts/ModifierSync')
require('AddonScripts/SpellSystem')

spell_test_modifier = spell_test_modifier or class({})


function spell_test_modifier:OnCreated()
  SpellSystem:BuffOnCreated(self)
  local eCaster = self:GetCaster()
end

function spell_test_modifier:OnSpellStart(keys)
  print('spell_test_modifier:OnSpellStart()', keys)
  if IsServer() then
    db(keys)

  end
end


