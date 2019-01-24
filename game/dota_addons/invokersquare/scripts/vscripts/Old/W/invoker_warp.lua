invoker_warp = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

LinkLuaModifier( "invoker_warp_passivebuff", "AddonScripts/spells/W/invoker_warp_passivebuff", LUA_MODIFIER_MOTION_NONE )

function invoker_warp:OnSpellStart()
	QWERSystem_SphereClick(self, 2)
end

function invoker_warp:OnUpgrade()
	local caster = self:GetCaster()
	QWERSystem_LevelUpdate(caster)
	caster:AddNewModifier(caster, self, "invoker_warp_passivebuff", {})
end