invoker_expanse = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

LinkLuaModifier( "invoker_expanse_passivebuff", "AddonScripts/spells/E/invoker_expanse_passivebuff", LUA_MODIFIER_MOTION_NONE )

function invoker_expanse:OnSpellStart()
	QWERSystem_SphereClick(self, 3)
end

function invoker_expanse:OnUpgrade()
	local caster = self:GetCaster()
	QWERSystem_LevelUpdate(caster)
	caster:AddNewModifier(caster, self, "invoker_expanse_passivebuff", {})
end