--[[
speedlim = class({})

function speedlim:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function speedlim:GetModifierMoveSpeed_Max()
	return 2000
end

function speedlim:GetModifierMoveSpeed_Limit()
	return 2000
end

function speedlim:IsHidden()
	return true
end

function speedlim:IsPermanent()
	return true
end
]]
--Возможное решение понижения минимального порога скорости
--https://customgames.ru/forum/threads/%D0%9D%D0%B8%D0%B6%D0%BD%D0%B8%D0%B9-%D0%BF%D1%80%D0%B5%D0%B4%D0%B5%D0%BB-%D1%81%D0%BA%D0%BE%D1%80%D0%BE%D1%81%D1%82%D0%B8.1286/

require('AddonScripts/ModifierSync')
require('AddonScripts/SpellSystem')


speedlim = speedlim or class({})

function speedlim:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
	--data = Sync(data)
	self.nMovespeedMax = data.nMovespeedMax 		or 3000
	self.nMovespeedMin = data.nMovespeedMin 		or 1			--0 не ставить! 0 работать не будет
	local nIntervalThink = data.nIntervalThink	or 0.1
	
	
	self.eParent = self:GetParent()
	self.base_speed = self.eParent:GetBaseMoveSpeed()
	self.sParentIndex = 'speedlim_' .. tostring(self.eParent:GetEntityIndex())
	
	self:StartIntervalThink(nIntervalThink)
	--self:OnIntervalThink()
	--SpellSystem:RefreshComplete(self)
	
end

function speedlim:OnIntervalThink()
	self.real_speed = Sync( 
		function()
			local nResultSpeed = self.base_speed
			if self.eParent.FindAllModifiers then
				for _, modifier in pairs(self.eParent:FindAllModifiers()) do
						if modifier and modifier.GetModifierMoveSpeedBonus_Constant then
							local nAddSpeed = modifier:GetModifierMoveSpeedBonus_Constant() 
							if nAddSpeed then
								nResultSpeed = nResultSpeed + nAddSpeed
							else
								print('speedlim:OnIntervalThink, '..modifier:GetName()..':GetModifierMoveSpeedBonus_Constant() == nil, IsServer=', IsServer())
							end		
						end
				end
			end
			return math.max(self.nMovespeedMin, nResultSpeed)
		end,
		self.sParentIndex
	)
	--SpellSystem:RefreshBuff(self)
end

function speedlim:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,		--Повышает макс. порог скорости
		MODIFIER_PROPERTY_MOVESPEED_LIMIT		--Позволяет реально присвоить ms (у меня обновляется даже в UI)
	}
end

function speedlim:GetModifierMoveSpeed_Max()
	return self.nMovespeedMax
end

function speedlim:GetModifierMoveSpeed_Limit()
	--print('speedlim:GetModifierMoveSpeed_Limit, self.real_speed='..self.real_speed..', IsServer=', IsServer())
	return self.real_speed
end

function speedlim:IsHidden()
	return true
end

function speedlim:IsPermanent()
	return true
end