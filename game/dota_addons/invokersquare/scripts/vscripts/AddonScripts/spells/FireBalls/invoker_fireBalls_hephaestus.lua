require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')
require('AddonScripts/Rockets')

LinkLuaModifier( "invoker_fireballs_hephaestus_modifier_owner_aura", "AddonScripts/spells/FireBalls/invoker_fireballs_hephaestus_modifier_owner_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "invoker_fireballs_hephaestus_modifier_aura", "AddonScripts/spells/FireBalls/invoker_fireballs_hephaestus_modifier_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("invoker_fireballs_hephaestus_modifier_fire", "AddonScripts/spells/FireBalls/invoker_fireballs_hephaestus_modifier_fire", LUA_MODIFIER_MOTION_NONE )

invoker_fireBalls_hephaestus = invoker_fireBalls_hephaestus or class({})

function invoker_fireBalls_hephaestus:Refresh_eDummyFire(eDummyFire)
	eDummyFire:SetDayTimeVisionRange(self.nFireVisionRange)
	eDummyFire:SetNightTimeVisionRange(self.nFireVisionRange)
	
	SpellSystem:ApplyBuff({
			eParent = eDummyFire,
			eCaster = self:GetCaster(),
			sBuff = 'dummy',
			hStats = {
				MODIFIER_STATE_NO_HEALTH_BAR = false,
				MODIFIER_STATE_NOT_ON_MINIMAP = self.bMiniMapHideVision,
				MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES = self.bMiniMapHideVisionEnemy
			}
		}
	)
	--[[
	eDummyFire:AddNewModifier(self:GetCaster(), nil, "dummy", {
			MODIFIER_STATE_NO_HEALTH_BAR = false,
			MODIFIER_STATE_NOT_ON_MINIMAP = self.bMiniMapHideVision,
			MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES = self.bMiniMapHideVisionEnemy
		}
	)
	]]
	
	SpellSystem:ApplyBuff({
			eParent = eDummyFire,
			eCaster = self:GetCaster(),
			sBuff = 'invoker_fireballs_hephaestus_modifier_owner_aura',
			hStats = {nRange = self.nFireRange}
		}
	)	
	--[[
	eDummyFire:AddNewModifier(self:GetCaster(), nil, "invoker_fireballs_hephaestus_modifier_owner_aura", {
			nRange = self.nFireRange
		}
	)
	]]

	--return eDummyFire
end

function invoker_fireBalls_hephaestus:OnRefresh()
	--[[
	local hQWER
	if IsServer() then
		hQWER = GetSSAbsQWERLevel(self)
	end
	hQWER = Sync(hQWER)
	]]
	local hQWER = QWERSystem:Apply(self)

	--базовые параметры скилла
	self.nCooldown = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nCooldown, hQWER)
	self.nManaCost = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nManaCost, hQWER)
	self.nCastPoint = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nCastPoint, hQWER)
	--урон
	self.nDamage = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nDamage, hQWER)	--урон при попадании
	self.nStackDamageFactor = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nStackDamageFactor, hQWER)
	self.nRadius = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nRadius, hQWER)	--Радиус захвата урона при попадании
	self.nFireRange = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nFireRange, hQWER)	--Радиус действия огня
	self.nBuffDuration = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nBuffDuration, hQWER)
	self.nHitStackCount = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nHitStackCount, hQWER)
	--параметры снаряда
	self.nMaxSpeed = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nMaxSpeed, hQWER)
	self.nAcceleration = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nAcceleration, hQWER)
	self.nRocketVisionRange = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nRocketVisionRange, hQWER)
	--параметры (статичного) огня
	self.nTimeLife = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nTimeLife, hQWER)
	self.nFireVisionRange = GetConst(GetGameConst().invoker_fireBalls_hephaestus.nFireVisionRange, hQWER)
	self.bMiniMapHideVision = GetConst(GetGameConst().invoker_fireBalls_hephaestus.bMiniMapHideVision, hQWER)
	self.bMiniMapHideVisionEnemy = GetConst(GetGameConst().invoker_fireBalls_hephaestus.bMiniMapHideVisionEnemy, hQWER)
	
	if IsServer() then
		self.nDummyFire_eDummyFire = self.nDummyFire_eDummyFire or {}
		for _, eDummyFire in pairs(self.nDummyFire_eDummyFire) do
			self:Refresh_eDummyFire(eDummyFire)
		end
	end
	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_fireBalls_hephaestus:OnSpellStart()
	local eCaster = self:GetCaster()
	local vTarget = self:GetCursorPosition()
	--local target = self:GetCursorTarget() 
	
	local sEffectName = "particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf"

	local hData = {
		eSource = eCaster,
		vTarget = vTarget + Vector(0,0,25),
		nMaxSpeed = self.nMaxSpeed,
		--nSpeed = 5500,
		nAcceleration = self.nAcceleration,
		nVerticalAngle = 85,

		bUseDummyVision = true,
		
		nVisionRadius = self.nRocketVisionRange,
		--bFreeDummy = false,
		--nDurationVision = 3,

		OnGroundHit = function(this)
			return true
		end,

		
		OnFinish = function(this)
			--eCaster:EmitSound("Hero_Phoenix.ProjectileImpact")
			--eCaster:EmitSound("Hero_Jakiro.LiquidFire")
			EmitSoundOnLocationWithCaster(this.vPos, 'Hero_Jakiro.LiquidFire', eCaster)
			local nGroundEffect = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf",
				PATTACH_CUSTOMORIGIN, nil
			)
			ParticleManager:SetParticleControl(nGroundEffect, 0, this.vPos)		

			local nFireEffect1 = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_phoenix/phoenix_icarus_dive_char_glow.vpcf",
				PATTACH_CUSTOMORIGIN, nil
			)
			local nFireEffect2 = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf",
				PATTACH_CUSTOMORIGIN, nil
			)
			ParticleManager:SetParticleControl(nFireEffect1, 0, this.vPos)
			ParticleManager:SetParticleControl(nFireEffect2, 0, this.vPos)			
			Timers:CreateTimer(4,
				function()
					ParticleManager:DestroyParticle(nGroundEffect, false)
					ParticleManager:ReleaseParticleIndex(nGroundEffect)
				end
			)	


			local hUnits = FindUnitsInRadius(
				this.nTeam,
				this.vPos,
				nil,
				self.nRadius,
				DOTA_UNIT_TARGET_TEAM_BOTH, --DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, --,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, --DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)

			--db('hUnits:', hUnits)

			for _, eUnit in pairs(hUnits) do
				local nDamage = self.nDamage
				local eFireModifier = eUnit:FindModifierByName('invoker_fireballs_hephaestus_modifier_fire') 
					or SpellSystem:ApplyBuff({
							eParent = eUnit,
							eCaster = self:GetCaster(),
							sBuff = 'invoker_fireballs_hephaestus_modifier_fire',
							hStats = {duration = self.nBuffDuration}
						}
					)
					--or eUnit:AddNewModifier(self:GetCaster(), nil, 'invoker_fireballs_hephaestus_modifier_fire', {duration = self.nBuffDuration})
				if eFireModifier then
					nDamage = nDamage + nDamage * (self.nStackDamageFactor * eFireModifier:GetStackCount())
				end
				ApplyDamage({
						victim = eUnit,
						attacker = this.eSource,
						damage = nDamage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
					}
				)
				eFireModifier:SetStackCount(eFireModifier:GetStackCount() + self.nHitStackCount)
			end


			local eDummyFire = CreateUnitByName('npc_dummy', this.vPos, false, this.eSource, this.eSource, this.nTeam)
			self:Refresh_eDummyFire(eDummyFire)
			local nDummyFire = 1
			while self.nDummyFire_eDummyFire[nDummyFire] do
				nDummyFire = nDummyFire + 1
			end
			self.nDummyFire_eDummyFire[nDummyFire] = eDummyFire

			eDummyFire.nTimeLife = self.nTimeLife
			eDummyFire.nCurrentTimeLife = eDummyFire.nTimeLife
			Timers:CreateTimer(
				function()
					if eDummyFire.nCurrentTimeLife <= 0 then
						ParticleManager:DestroyParticle(nFireEffect1, false)
						ParticleManager:ReleaseParticleIndex(nFireEffect1)
						ParticleManager:DestroyParticle(nFireEffect2, false)
						ParticleManager:ReleaseParticleIndex(nFireEffect2)

						--eDummyFire:ForceKill(false)
						eDummyFire:RemoveSelf()
						self.nDummyFire_eDummyFire[nDummyFire] = nil
						return
					end
					eDummyFire:SetHealth((eDummyFire.nCurrentTimeLife / eDummyFire.nTimeLife)*eDummyFire:GetMaxHealth())
					eDummyFire.nCurrentTimeLife = eDummyFire.nCurrentTimeLife - FrameTime()
					return FrameTime()
				end
			)	
		end,

		
			
		hAttachments = {
			sAttachSource = 'attach_attack' .. tostring(self.nLastAnimation),
		}
	}
	CreateRocket(hData)
	--eCaster:EmitSound("Hero_Phoenix.FireSpirits.Launch")
	eCaster:EmitSound("Hero_OgreMagi.Fireblast.Target")

	
	--if RandomFloat(0, 100) <= 2 then
	if RandomInt(0, 100) <= 2 then
		ApplySound(eCaster, 'invoker_fireBalls_hephaestus', {
				invoker_invo_laugh_01 = 1,	--Хм-хм-хм-хм-хм-хм-хм-хм-хм-хм-хм.
				invoker_invo_laugh_05 = 1, 
				invoker_invo_laugh_08 = 1, 	--Хе-хе-ха-ха.
				invoker_invo_laugh_11 = 1,	--Хм-ха-ха
				invoker_invo_laugh_13 = 1		--Ха.
			}, 10
		)	
	end

	











	--[[
	local hRocket = Len.CreateRocket(
		{
			eSource = eCaster,
			vTarget = vTarget,
			vPos = eCaster:GetAbsOrigin() + Vector(0,0,200),
			nMaxSpeed = 1300,
			--nFirstSpeed = 300,
			vSpeed = Vector(0,0,100),
			sEffectName = sEffectName,
			bStaticEffect = false,
		}
	)
	]]

	--[[
	--local nRocket = ParticleManager:CreateParticle("particles/base_attacks/ranged_tower_good_linear.vpcf", PATTACH_OVERHEAD_FOLLOW, eCaster)
	local nRocket = ParticleManager:CreateParticle(sEffectName, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleAlwaysSimulate(nRocket)
	ParticleManager:SetParticleControl(nRocket, 0, eCaster:GetAbsOrigin())
	--ParticleManager:SetParticleControlForward(nRocket, 0, eCaster:GetForwardVector() * 300)
	ParticleManager:SetParticleControl(nRocket, 1, eCaster:GetForwardVector() * 1000)
	
	
	--local nAdvSpeed = 0
	local nTimeStep = 0.1
	Timers:CreateTimer(0,
		function()
			--ParticleManager:SetParticleControl(nRocket, 1, vOldPos)
			--nAdvSpeed = nAdvSpeed + 50
			
			--ParticleManager:SetParticleControl(nRocket, 0, eCaster:GetAbsOrigin())
			return nTimeStep
		end
	)
	]]
	
	

	self:RemoveParticles()
end

function invoker_fireBalls_hephaestus:GetCooldown()
	return self.nCooldown
end

function invoker_fireBalls_hephaestus:GetManaCost()
	return self.nManaCost
end

function invoker_fireBalls_hephaestus:GetCastPoint()
	return self.nCastPoint
end

function invoker_fireBalls_hephaestus:OnAbilityPhaseInterrupted()
	self.nLastAnimation = nil
	EndAnimation(self:GetCaster())

	self:RemoveParticles()
end

function invoker_fireBalls_hephaestus:OnAbilityPhaseStart()
	local eCaster = self:GetCaster()

	self:RemoveParticles()

	
	local hAnims = {}
	hAnims[1] = ACT_DOTA_ATTACK
	hAnims[2] = ACT_DOTA_ATTACK2

	self.nLastAnimation = RandomInt(1, 2)
	StartAnimation(eCaster, {
			duration = self.nCastPoint+0.2, 
			activity = hAnims[self.nLastAnimation],
			--translate = 'injured',
			rate = 1.3
		}
	)


	eCaster.Particle_fireBools_hephaestus = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_invoker/invoker_alacrity.vpcf",
		PATTACH_ABSORIGIN_FOLLOW, eCaster)

	if IsServer() then
		eCaster:EmitSound('Hero_AbyssalUnderlord.Firestorm.Cast')
	end
	return true
end

function invoker_fireBalls_hephaestus:RemoveParticles()
	local eCaster = self:GetCaster()
	if eCaster.Particle_fireBools_hephaestus then
		ParticleManager:DestroyParticle(eCaster.Particle_fireBools_hephaestus, true)
    ParticleManager:ReleaseParticleIndex(eCaster.Particle_fireBools_hephaestus)
		eCaster.Particle_fireBools_hephaestus = nil
	end
end