require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

invoker_fireballs_hephaestus_modifier_fire = invoker_fireballs_hephaestus_modifier_fire or class({})



function invoker_fireballs_hephaestus_modifier_fire:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = false,	--снимает нивидимость
	}
end

function invoker_fireballs_hephaestus_modifier_fire:OnRefresh()
	self.hQWER = QWERSystem:Apply(self, self:GetCaster(), 'invoker_fireBalls_hephaestus')

	self.sTextureName = GetConst(GetGameConst().invoker_fireBalls_hephaestus.sFireTextureName, self.hQWER)
	self.nDamagePerStack = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nDamagePerStack, self.hQWER)
	self:StartIntervalThink(FrameTime())

	SpellSystem:RefreshComplete(self, hQWER)
end


function invoker_fireballs_hephaestus_modifier_fire:OnIntervalThink()
	if IsServer() then
		local eUnit = self:GetParent()
		
		local nStackCount = math.max(self:GetStackCount(), 1)
		self.nDamageBuffer = self.nDamageBuffer + (nStackCount * self.nDamagePerStack * FrameTime())
		local int_Damage = math.floor(self.nDamageBuffer)
		if int_Damage > 0 then
			self.nDamageBuffer = self.nDamageBuffer - int_Damage

			ApplyDamage({
					victim = eUnit,
					attacker = self:GetCaster(),
					damage = int_Damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
					--ability = self, --Optional.
				}
			)
		end
		

	end
end

function invoker_fireballs_hephaestus_modifier_fire:OnCreated()
	SpellSystem:BuffOnCreated(self)
	if IsServer() then
		self.nDamageBuffer = 0
	end
	--self:OnRefresh()
end

function invoker_fireballs_hephaestus_modifier_fire:GetTexture()
	return self.sTextureName
end

function invoker_fireballs_hephaestus_modifier_fire:GetEffectName()
	return 'particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf'
end

function invoker_fireballs_hephaestus_modifier_fire:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function invoker_fireballs_hephaestus_modifier_fire:IsPurgable()
	return true
end

function invoker_fireballs_hephaestus_modifier_fire:IsHidden()
	return false
end

function invoker_fireballs_hephaestus_modifier_fire:IsDeBuff()
	return true
end
--[[
function invoker_fireballs_hephaestus_modifier_fire:IsBuff()
	return true
end
]]