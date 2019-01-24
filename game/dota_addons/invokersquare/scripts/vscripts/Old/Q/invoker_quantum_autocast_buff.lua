invoker_quantum_autocast_buff = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

local nHPRegen = 0
local nMPRegen = 0

function invoker_quantum_autocast_buff:RefreshProcentSwap()
	local caster = self:GetParent()
	local Q, W, E, R = QWERSystemGetAbilityLevel(caster)
	local nForseSwapPercent = QWERSystemGetnConstBySpell(Q, W, E, R, "quantum", "nForseSwap")

	local nHP_Max = caster:GetMaxHealth()
	local nMP_Max = caster:GetMaxMana()

	local nHP_Current = caster:GetHealth()
	local nMP_Current = caster:GetMana()

	--local nHP_Current_Percent = caster:GetHealthPercent()
	--local nMP_Current_Percent = caster:GetManaPercent()
	local nHP_Current_Percent = nHP_Current / nHP_Max * 100
	local nMP_Current_Percent = nMP_Current / nMP_Max * 100

	if nHP_Current_Percent > nMP_Current_Percent then
		--Из HP в ману
		nHPRegen = -nHP_Max * nForseSwapPercent 
		nMPRegen = nMP_Max * nForseSwapPercent
	elseif nHP_Current_Percent < nMP_Current_Percent then
		--из маны в HP
		nHPRegen = nHP_Max * nForseSwapPercent
		nMPRegen = -nMP_Max * nForseSwapPercent
	else
		--ровное совпадение по HP и MP
		nHPRegen = 0
		nMPRegen = 0
	end
end

function invoker_quantum_autocast_buff:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
	return funcs
end

function invoker_quantum_autocast_buff:GetModifierConstantHealthRegen()
	self:RefreshProcentSwap()
	return nHPRegen
end

function invoker_quantum_autocast_buff:GetModifierConstantManaRegen()
	return nMPRegen
end

function invoker_quantum_autocast_buff:GetTexture()
	return "morphling_morph_str"	--"leshrac_diabolic_edict"
end



function invoker_quantum_autocast_buff:IsDeBuff()
	return false
end

function invoker_quantum_autocast_buff:IsBuff()
	return true
end

function invoker_quantum_autocast_buff:IsHidden()
	return false
end

function invoker_quantum_autocast_buff:IsPermanent()
	return true
end