require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

LinkLuaModifier( "forge_spirits_life_giving_fire_modifier", "AddonScripts/spells/ForgeSpirit/forge_spirits_life_giving_fire_modifier", LUA_MODIFIER_MOTION_NONE )

forge_spirits_life_giving_fire = forge_spirits_life_giving_fire or class({})


function forge_spirits_life_giving_fire:OnRefresh()
	local hQWER
	if IsServer() then
		db(self:GetName())
		db(self:GetCaster():GetName())
		db(self:GetCaster():GetOwner():GetName())
		hQWER = QWERSystem:Apply(self, self:GetCaster():GetOwner() or self:GetCaster(), 'invoker_forge_spirits')
	end
	hQWER = Sync(hQWER, 'forge_spirits_life_giving_fire')
	self.nRadius = GetConst(GetGameConst().forge_spirits_life_giving_fire.nRadius, hQWER)

	if IsServer() then
		local eForge = self:GetCaster()
		local eOwner = eForge:GetOwner() or eForge
		SpellSystem:ApplyBuff({
				eParent = eForge,
				eCaster = eOwner,
				eSourceAbility = self,
				sBuff = 'forge_spirits_life_giving_fire_modifier',
				hStats = {nRadius = self.nRadius}
			}
		)
		--eForge:AddNewModifier(eOwner, self, "forge_spirits_life_giving_fire_modifier", {nRadius = self.nRadius})
	end

	SpellSystem:RefreshComplete(self, hQWER)
end

function forge_spirits_life_giving_fire:OnUpgrade()
	SyncExecByEnt(self,'OnRefresh')
end

function forge_spirits_life_giving_fire:GetCastRange()
	return self.nRadius
end