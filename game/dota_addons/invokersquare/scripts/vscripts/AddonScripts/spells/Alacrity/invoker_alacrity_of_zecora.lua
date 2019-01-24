require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')

LinkLuaModifier( "invoker_alacrity_of_zecora_buff", "AddonScripts/spells/Alacrity/invoker_alacrity_of_zecora_buff", LUA_MODIFIER_MOTION_NONE )

invoker_alacrity_of_zecora = invoker_alacrity_of_zecora or class({})


function invoker_alacrity_of_zecora:OnSpellStart()
	local eCaster = self:GetCaster()
	local eTarget = self:GetCursorTarget() 

	ApplySound(eCaster, 'invoker_alacrity_of_zecora', {
			invoker_invo_ability_alacrity_02 = 1,	--Alacrity!
			invoker_invo_ability_alacrity_04 = 1,	--Заклятие стремительности Гастера
			invoker_invo_doubdam_02 = 1,	--одной лишь силой разума я воплотил это в реальность
			invoker_invo_ability_invoke_12 = 1,	--слова силы
		}, 10
	)
	--print('invoker_alacrity_of_zecora:OnSpellStart, self.nDuration=', self.nDuration)
	SpellSystem:ApplyBuff({
			eParent = eTarget,
			eCaster = eCaster,
			eSourceAbility = self,
			sBuff = 'invoker_alacrity_of_zecora_buff',
			hStats = {duration = self.nDuration}
		}
	)
	--SpellSystem:RefreshAllBuffs(self:GetCaster())
	--eTarget:AddNewModifier(eCaster, self, "invoker_alacrity_of_zecora_buff", {duration = self.nDuration})
end

function invoker_alacrity_of_zecora:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = GetSSAbsQWERLevel(self)
	end
	hQWER = Sync(hQWER)
	]]
	--print('invoker_alacrity_of_zecora:OnRefresh, IsServer=', IsServer())
	local hQWER = QWERSystem:Apply(self, self:GetCaster(), 'invoker_alacrity_of_zecora')
	
	self.nDuration = GetConst(GetGameConst().invoker_alacrity_of_zecora.nDuration, hQWER)
	self.nCooldown = GetConst(GetGameConst().invoker_alacrity_of_zecora.nCooldown, hQWER)
	self.nManaCost = GetConst(GetGameConst().invoker_alacrity_of_zecora.nManaCost, hQWER)
	self.nCastPoint = GetConst(GetGameConst().invoker_alacrity_of_zecora.nCastPoint, hQWER)
	self.nCastRange = GetConst(GetGameConst().invoker_alacrity_of_zecora.nCastRange, hQWER)

	SpellSystem:RefreshComplete(self)
end

function invoker_alacrity_of_zecora:OnUpgrade()
	SyncExecByEnt(self,'OnRefresh')
	--self:OnRefresh()
end

function invoker_alacrity_of_zecora:OnHeroLevelUp()
	SyncExecByEnt(self,'OnRefresh')
	--self:OnRefresh()
end

--[[
function invoker_alacrity_of_zecora:OnTooltip()
	--print('invoker_alacrity_of_zecora:OnTooltip')


	--particles/ui_mouseactions/range_display.vpcf
end
]]
function invoker_alacrity_of_zecora:GetCooldown()
	return self.nCooldown
end

function invoker_alacrity_of_zecora:GetManaCost()
	return self.nManaCost
end

function invoker_alacrity_of_zecora:GetCastPoint()
	return self.nCastPoint
end

function invoker_alacrity_of_zecora:GetCastRange()
	return self.nCastRange
end
