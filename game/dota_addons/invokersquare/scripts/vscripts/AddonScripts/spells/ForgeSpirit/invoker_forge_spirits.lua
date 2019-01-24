require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')

LinkLuaModifier( "invoker_forge_spirit_stats", "AddonScripts/spells/ForgeSpirit/invoker_forge_spirit_stats", LUA_MODIFIER_MOTION_NONE )

invoker_forge_spirits = invoker_forge_spirits or class({})

function invoker_forge_spirits:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = GetSSAbsQWERLevel(self)
	end
	hQWER = Sync(hQWER)
	]]
	local hQWER = QWERSystem:Apply(self)
	self.nCooldown = GetConst(GetGameConst().invoker_forge_spirits.nCooldown, hQWER)
	self.nManaCost = GetConst(GetGameConst().invoker_forge_spirits.nManaCost, hQWER)
	self.nCastPoint = GetConst(GetGameConst().invoker_forge_spirits.nCastPoint, hQWER)

	self.nDuration = GetConst(GetGameConst().invoker_forge_spirits.nDuration, hQWER)
	self.nCountCreatures = GetConst(GetGameConst().invoker_forge_spirits.nCountCreatures, hQWER)
	--self.nHPMax = GetConst(GetGameConst().invoker_forge_spirits.nHPMax, hQWER)

	SpellSystem:RefreshComplete(self)
end

function invoker_forge_spirits:OnSpellStart()
	local eCaster = self:GetCaster()



	--локальная группа
	eCaster.forged_spirits = eCaster.forged_spirits or {}
	for _, eForge in pairs(eCaster.forged_spirits) do
		if eForge and IsValidEntity(eForge) then 
			eForge:ForceKill(false)
		end
	end
	eCaster.forged_spirits = {}

	for i=1, self.nCountCreatures do
		local eForge = CreateUnitByName("npc_invoker_forge_spirit", eCaster:GetAbsOrigin() + RandomVector(75), true, eCaster, eCaster, eCaster:GetTeamNumber())
		eForge:SetControllableByPlayer(eCaster:GetPlayerID(), true)
		--eForge:SetBaseMaxHealth(self.nHPMax)
		SpellSystem:ApplyBuff({
				eParent = eForge,
				eCaster = eCaster,
				eSourceAbility = self,
				sBuff = 'modifier_phased',
				hStats = {duration = 0.03}
			}
		)
		--eForge:AddNewModifier(eCaster, self, "modifier_phased", {duration = 0.03})
		SpellSystem:ApplyBuff({
				eParent = eForge,
				eCaster = eCaster,
				eSourceAbility = self,
				sBuff = 'invoker_forge_spirit_stats',
			}
		)		
		--eForge:AddNewModifier(eCaster, self, "invoker_forge_spirit_stats", {})
		SpellSystem:ApplyBuff({
				eParent = eForge,
				eCaster = eCaster,
				eSourceAbility = self,
				sBuff = 'modifier_kill',
				hStats = {duration = self.nDuration}
			}
		)	
		--eForge:AddNewModifier(eCaster, self, "modifier_kill", {duration = self.nDuration})
		


		eForge:AddAbility("forge_spirits_life_giving_fire"):SetLevel(1)
		eForge:AddAbility("forge_spirits_owner_link"):SetLevel(1)
		table.insert(eCaster.forged_spirits, eForge)
	end

	eCaster:EmitSound("Hero_Invoker.ForgeSpirit")
	ApplySound(eCaster, 'invoker_forge_spirits', {
			invoker_invo_ability_forgespirit_01 = 1, 	--forgespirit
			invoker_invo_ability_forgespirit_03 = 1,	--элементали Горя!
			invoker_invo_ability_forgespirit_04 = 1,	--хитроумные конструкции Кальвина
			invoker_invo_ability_forgespirit_05 = 1,	--разрушители из воли и брони
			invoker_invo_ability_forgespirit_06 = 1,	--союзник из неоткуда
			invoker_invo_purch_02 = 0.7,	--одной лишь силой разума, я воплотил это в реальность
			invoker_invo_ability_invoke_05 = 1,	--Из глубин

			enigma_enig_drop_common_01 = 1,  --[enigma] из ничего возникло нечто
			enigma_enig_drop_medium_01 = 1,  --[enigma] благополучное воплощение производности
		}, 1
	)

	--глобальная группа групп (юнитов) владельца
	eCaster.groups = eCaster.groups or {}
	eCaster.groups.forged_spirits = eCaster.forged_spirits
end

function invoker_forge_spirits:GetCooldown()
	return self.nCooldown
end

function invoker_forge_spirits:GetManaCost()
	return self.nManaCost
end

function invoker_forge_spirits:GetCastPoint()
	return self.nCastPoint
end