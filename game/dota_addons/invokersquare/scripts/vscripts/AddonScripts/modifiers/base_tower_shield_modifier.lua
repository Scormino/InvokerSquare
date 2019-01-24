require('AddonScripts/SpellSystem')

base_tower_shield_modifier = base_tower_shield_modifier or class({})


function base_tower_shield_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,	--физ. урон будет обрабатываться

		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,

		MODIFIER_PROPERTY_MIN_HEALTH	--чтобы наверняка не уничтожить обелиск
	}
end


function base_tower_shield_modifier:GetAbsoluteNoDamagePhysical(data)
	local eAttacker = data.attacker		--атакующий юнит
	local eTarget = data.target				--в роли башни
	--local nOriginalDamage = data.original_damage
	local damage = 1			
	if eAttacker:IsHero() then
		damage = 2
	end
	if eAttacker:GetTeam() == eTarget:GetTeam() then
		--если атакующий = союзник
		damage = damage*2

		eTarget:SetHealth(eTarget:GetHealth() + damage)	--отхиливаем башню
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, eTarget, damage, nil)	--выводим видимое сообщение с отлеченным здоровьем
	else
		--если атакующий = противник
		if eTarget:GetHealth() > damage then
			--если у башни хватит здоровья пережить урон
			eTarget:SetHealth(eTarget:GetHealth() - damage)	--наносим урон
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, eTarget, damage, nil)	--показываем сообщение о нанесённом уроне
		else
			--если башня будет перехвачена атакующим
			eTarget:SetTeam(eAttacker:GetTeam())

			eTarget:SetHealth(5)
			StartAnimation(
				eTarget, 
				{
					duration=-1,
					activity=ACT_DOTA_CAPTURE, 
				}
			)
			local nPlayerID = eAttacker:GetPlayerOwnerID() or eAttacker:GetPlayerID()
			--[[
			if eAttacker:GetPlayerOwnerID() ~= nil then
				nPlayerID = 
			else
				nPlayerID = 
			end
			ClassicFuncs.RefreshRespawnSystemByPlayerID(nPlayerID)	--обновление respawn System'ы
			eTarget:SetControllableByPlayer(eAttacker:GetPlayerID(), true)
			]]
			PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():AddExperience(45, 0, false, true)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_DENY, eTarget, 0, nil)
			if IsServer() and hMode.ExpSystem then
				
				--print(eTarget:FindAbilityByName('tower_knowledge_concentrator'):GetTeam())
				hMode.ExpSystem.Refresh()
			end
		end
	end
	return 1 --блок урона состоялся
end

function base_tower_shield_modifier:GetAbsoluteNoDamageMagical()
	return 1 --блок урона состоялся
end

function base_tower_shield_modifier:GetAbsoluteNoDamagePure()
	return 1 --блок урона состоялся
end

function base_tower_shield_modifier:GetMinHealth()
	return 1 --хп не может быть ниже 1 (тавера физически невозможно уничтожить)
end

function base_tower_shield_modifier:OnCreated(data)
	SpellSystem:BuffOnCreated(self)
end

function base_tower_shield_modifier:OnDestroy()
	
end

function base_tower_shield_modifier:GetTexture()
	return 'rattletrap_power_cogs'
end
	
function base_tower_shield_modifier:IsDeBuff()
	return false
end

function base_tower_shield_modifier:IsBuff()
	return true
end

function base_tower_shield_modifier:IsHidden()
	return false
end

function base_tower_shield_modifier:IsPermanent()
	return true
end
