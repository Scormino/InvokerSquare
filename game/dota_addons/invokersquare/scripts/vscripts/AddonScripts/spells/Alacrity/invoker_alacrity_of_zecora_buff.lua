require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

invoker_alacrity_of_zecora_buff = invoker_alacrity_of_zecora_buff or class({})


function invoker_alacrity_of_zecora_buff:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		--hQWER = GetSSOutQWERLevel(self:GetParent())
		hQWER = ApplyQWERBuffLevels(self, self:GetCaster())
		RefreshTooltipByEnt(self)	
	end
	hQWER = Sync(hQWER)
	]]
	local hQWER = QWERSystem:Apply(self, self:GetCaster(), 'invoker_alacrity_of_zecora')

	self.sTextureName = GetConst(GetGameConst().invoker_alacrity_of_zecora.sBuffTextureName, hQWER)
	self.nDamage = GetConst(GetGameConst().invoker_alacrity_of_zecora.nDamage, hQWER)
	self.nInDamagePercent = GetConst(GetGameConst().invoker_alacrity_of_zecora.nInDamagePercent, hQWER)
	self.nOutDamagePercent = GetConst(GetGameConst().invoker_alacrity_of_zecora.nOutDamagePercent, hQWER)

	
	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_alacrity_of_zecora_buff:OnCreated()
	local nBuffIndex = SpellSystem:BuffOnCreated(self)
	self:CastAnim()
end

function invoker_alacrity_of_zecora_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end


function invoker_alacrity_of_zecora_buff:GetModifierPreAttack_BonusDamage()
	return self.nDamage
end

function invoker_alacrity_of_zecora_buff:GetModifierIncomingDamage_Percentage()
	return self.nInDamagePercent
end

function invoker_alacrity_of_zecora_buff:GetModifierTotalDamageOutgoing_Percentage()
	return self.nOutDamagePercent
end



function invoker_alacrity_of_zecora_buff:CastAnim()
	local unit = self:GetParent()
	local Add_Effect = function(unit)
		local res = ParticleManager:CreateParticle(
	    	"particles/econ/items/invoker/invoker_ti7/invoker_ti7_alacrity.vpcf",
	    	PATTACH_ABSORIGIN_FOLLOW, unit)
		return res
	end
	local Add_Effect2 = function(unit)
		local res = ParticleManager:CreateParticle(
	    	"particles/units/heroes/hero_invoker/invoker_alacrity_buff.vpcf",
			PATTACH_OVERHEAD_FOLLOW, unit)
		return res
	end

	if self.EffectID ~= nil then
		ParticleManager:DestroyParticle(self.EffectID, true)
		--ParticleManager:DestroyParticle(self.EffectID2, true)
	end
	self.EffectID = Add_Effect(unit)
	--self.EffectID2 = Add_Effect2(unit)
	if IsServer() then
		unit:EmitSound("Hero_Invoker.Alacrity")
	end
end

function invoker_alacrity_of_zecora_buff:OnDestroy()
	ParticleManager:DestroyParticle(self.EffectID, false)
	--ParticleManager:DestroyParticle(self.EffectID2, false)
	SpellSystem:BuffOnDestroy(self)
end

function invoker_alacrity_of_zecora_buff:GetTexture()
	return self.sTextureName
end

function invoker_alacrity_of_zecora_buff:IsDeBuff()
	return false
end

function invoker_alacrity_of_zecora_buff:IsBuff()
	return true
end

function invoker_alacrity_of_zecora_buff:IsHidden()
	return false
end

--[[
Пример использования CustomOutInfluence():

function invoker_alacrity_of_zecora_buff:CustomOutInfluence(SSTarget)
	local sInfluenceLevelName_nLevel

	local eTarget, sTargetType
	eTarget, sTargetType = SpellSystem:GetEnt(SSTarget)
	local sName = tostring(eTarget and eTarget.GetName and eTarget:GetName())
	if eTarget then
		if sTargetType == 'unit' then
			--UNIT

		elseif sTargetType == 'spell' then
			--SPELL

		elseif sTargetType == 'buff' then
			--BUFF
			--print('Alacrity, CustomOutInfluence, BUFF:', sName)
			if not eTarget.IsHidden() and eTarget ~= self then
				--print('Alacrity, CustomOutInfluence, FORCE BUFF:', sName)
				for _, sLevelName in pairs(QWERSystem.QWER) do
					sInfluenceLevelName_nLevel = sInfluenceLevelName_nLevel or {}
					sInfluenceLevelName_nLevel[sLevelName] = -1
				end
			end
		end
	end
	--db('Alacrity:CustomOutInfluence('..sName..') RESULT:', sInfluenceLevelName_nLevel)

	return sInfluenceLevelName_nLevel
end
]]