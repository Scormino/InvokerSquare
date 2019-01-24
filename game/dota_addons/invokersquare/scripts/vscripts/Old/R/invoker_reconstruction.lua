--require('AddonScripts/ModifierSync')


invoker_reconstruction = class({})

function QWERSystemInit(caster)

	caster.QWERSystem = class({})

	caster.QWERSystem.Spell = {}
	caster.QWERSystem.Spell[1] = caster:FindAbilityByName("invoker_empty1")
	caster.QWERSystem.Spell[2] = caster:FindAbilityByName("invoker_empty2")

	caster.QWERSystem.Formula = {0, 0, 0}	-- 0 = nil, 1 = quantum, 2 = warp, 3 = expanse
	caster.QWERSystem.CurrentUseSlot = 1
	
	QWERSystem_LevelUpdate(caster)

	for i=1, 3 do
		LinkLuaModifier( "invoker_quantum_buff"..i, "AddonScripts/spells/Q/invoker_quantum_buff"..i, LUA_MODIFIER_MOTION_NONE )
		LinkLuaModifier( "invoker_warp_buff"..i, "AddonScripts/spells/W/invoker_warp_buff"..i, LUA_MODIFIER_MOTION_NONE )
		LinkLuaModifier( "invoker_expanse_buff"..i, "AddonScripts/spells/E/invoker_expanse_buff"..i, LUA_MODIFIER_MOTION_NONE )
	end

	print("[Lenivex] QWERSystem init complited...")
end

function QWERSystem_LevelUpdate(caster)
	if caster.QWERSystem == nil then
		QWERSystemInit(caster)
	end
	caster.QWERSystem.level_quantum = caster:FindAbilityByName("invoker_quantum"):GetLevel()
	caster.QWERSystem.level_warp = caster:FindAbilityByName("invoker_warp"):GetLevel()
	caster.QWERSystem.level_expanse = caster:FindAbilityByName("invoker_expanse"):GetLevel()
end

function QWERSystem_BuffUpdate(caster, sphere, nAnim)
	local a = {}

	a[1] = caster:FindAbilityByName("invoker_quantum")	--на них будут повешены модификаторы
	a[2] = caster:FindAbilityByName("invoker_warp")		--на них будут повешены модификаторы
	a[3] = caster:FindAbilityByName("invoker_expanse")	--на них будут повешены модификаторы
	local f = caster.QWERSystem.Formula

	local b = {}
	b[1] = "invoker_quantum_buff"
	b[2] = "invoker_warp_buff"
	b[3] = "invoker_expanse_buff"

	if sphere == nil then
		for nSphereIndex = 1,3 do
			for nAttachIndex = 1,3 do
				if caster:HasModifier(b[nSphereIndex]..nAttachIndex) then
					caster:RemoveModifierByName(b[nSphereIndex]..nAttachIndex)
				end
			end
		end
		caster.QWERSystem.Formula = {0, 0, 0}
		caster.QWERSystem.CurrentUseSlot = 1
	else
		if caster.QWERSystem.Formula[3] == 0 then
			--создание способности 1, 2 или 3 порядка
			caster.QWERSystem.Formula[caster.QWERSystem.CurrentUseSlot] = sphere
		else
			--создание способности 3 порядка (перемешивание)
			--if caster.QWERSystem.Formula[caster.QWERSystem.CurrentUseSlot] ~= 0 then
			--	caster:RemoveModifierByName(b[f[3]]..caster.QWERSystem.CurrentUseSlot)
			--end
			--caster.QWERSystem.Formula[caster.QWERSystem.CurrentUseSlot] = sphere
			caster:RemoveModifierByName(b[f[1]]..caster.QWERSystem.CurrentUseSlot)
			
			local NewFormula = {}
			NewFormula[1] = caster.QWERSystem.Formula[2] 
			NewFormula[2] = caster.QWERSystem.Formula[3]
			NewFormula[3] = sphere
			caster.QWERSystem.Formula = NewFormula
		end
		caster:AddNewModifier(caster, a[sphere], b[sphere]..caster.QWERSystem.CurrentUseSlot, {nAnim=nAnim})
		caster.QWERSystem.CurrentUseSlot = caster.QWERSystem.CurrentUseSlot + 1
		if caster.QWERSystem.CurrentUseSlot > 3 then caster.QWERSystem.CurrentUseSlot = 1 end
	end
end


function QWERSystem_SphereClick(abil, sphere)	--shere - индекс сферы, в формуле
	local caster = abil:GetCaster() 

	if caster.QWERSystem == nil then
		QWERSystemInit(caster)
	end
	QWERSystem_BuffUpdate(caster, sphere, QWECastAnimation(abil:GetCaster()))
	


	print("Formula = {"..caster.QWERSystem.Formula[1]..", "..caster.QWERSystem.Formula[2]..", "..caster.QWERSystem.Formula[3].."}")
end






function GetNameSpellbyFormula(formula)
	local spell_name = nil
	local fText = "none"
	local s = function(f1, f2) 
		if f1[1] == f2[1] and f1[2] == f2[2] and f1[3] == f2[3] then
			return true
		end
		return false
	end

	for abil_name, f in pairs(hMode.GameConst.sAbilName_hFormula) do
		if s(formula, f) then
			spell_name = abil_name
			print("Reconstruction: ", abil_name, f)
			break
		end
	end
	return spell_name, fText
end

function invoker_reconstruction:OnSpellStart() 
	local re_cd = function(spell)
		spell:RefundManaCost()
		spell:EndCooldown()
	end
	local apply_changes = function(caster, spell_1_name, spell_2_name)
		caster:RemoveAbility(caster.QWERSystem.Spell[1]:GetName())
		caster:RemoveAbility(caster.QWERSystem.Spell[2]:GetName())

		caster.QWERSystem.Spell[1] = caster:AddAbility(spell_1_name)
		caster.QWERSystem.Spell[2] = caster:AddAbility(spell_2_name)

		caster.QWERSystem.Spell[1]:SetLevel(1)
		caster.QWERSystem.Spell[2]:SetLevel(1)
	end
	local apply_animation = function(caster, self_spell)
		local EffectID = ParticleManager:CreateParticle(
	    	"particles/units/heroes/hero_invoker/invoker_invoke.vpcf",
	    	PATTACH_ABSORIGIN_FOLLOW, caster
	    )
		--caster:EmitSound('Hero_Invoker.invo_ability_invoke_12')
		caster:EmitSound('Hero_Invoker.Invoke')

		Timers:CreateTimer(2, function ()
			ParticleManager:DestroyParticle(EffectID, true)
		end)
	end





	print('invoker_reconstruction self:GetEntityIndex(): ', self:GetEntityIndex())
	


	local caster = self:GetCaster()
	if caster.QWERSystem == nil then
		QWERSystemInit(caster)
	end

	local spell_name, _ = GetNameSpellbyFormula(caster.QWERSystem.Formula)

	local new_spell_1_name = caster.QWERSystem.Spell[1]:GetName()
	local new_spell_2_name = caster.QWERSystem.Spell[2]:GetName()
	local changed = false

	if spell_name ~= nil then
		if spell_name == caster.QWERSystem.Spell[1]:GetName() then
			re_cd(self)
		elseif spell_name == caster.QWERSystem.Spell[2]:GetName() then
			re_cd(self)

			local memory_name = new_spell_1_name
			new_spell_1_name = new_spell_2_name
			new_spell_2_name = memory_name
			changed = true
		else --new spell
			if caster.QWERSystem.Spell[1]:GetName() ~= "invoker_empty1" then
				new_spell_2_name = caster.QWERSystem.Spell[1]:GetName()
			end
			new_spell_1_name = spell_name
			changed = true
		end
	else
		re_cd(self)
		if caster.QWERSystem.Spell[1]:GetName() ~= "invoker_empty1" and caster.QWERSystem.Spell[2]:GetName() ~= "invoker_empty2" then
			local memory_name = new_spell_1_name
			new_spell_1_name = new_spell_2_name
			new_spell_2_name = memory_name
			changed = true
		end
	end

	apply_animation(caster, self)
	if changed then
		apply_changes(caster, new_spell_1_name, new_spell_2_name)
	end
	--QWERSystem_BuffUpdate(caster, nil)
	--EmitSoundOnLocationWithCaster(caster:GetCursorPosition(), "sounds/vo/invoker/invo_ability_invoke_12.vsnd", caster)
end


function QWECastAnimation(caster)
	local RandInt = RandomInt(1, 2)
	local a = ACT_DOTA_OVERRIDE_ABILITY_1
	if RandInt == 2 then
		a = ACT_DOTA_OVERRIDE_ABILITY_2
	end
    StartAnimation(caster, {duration=5.0, 
      activity=a
		})
	return RandInt
end

function RemoveQWEParticle(abil)
	if abil.QWEParticle ~= nil then
		ParticleManager:DestroyParticle(abil.QWEParticle, false)
		abil.QWEParticle = nil
	end
end

function CreateQWEParticle(abil, shpere, UseSlot, nAnim)
	nAnim = nAnim or 1
	local PartPath = {}	--пути к .vpcf сфер invoker'а
	PartPath[1] = "particles/invoker/quantum/invoker_quantum_orb.vpcf"
	PartPath[2] = "particles/invoker/warp/invoker_warp_orb.vpcf"
	PartPath[3] = "particles/invoker/expanse/invoker_expanse_orb.vpcf"
	--[[
	--Стандарные сферы:
	PartPath[1] = "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf"
	PartPath[2] = "particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf"
	PartPath[3] = "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf"
	]]
	local caster = abil:GetCaster()
	
	abil.QWEParticle = ParticleManager:CreateParticle(
		PartPath[shpere],
		PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(abil.QWEParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack"..nAnim, caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(abil.QWEParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_orb"..UseSlot, caster:GetAbsOrigin(), false)
end

function QWERSystemGetAbilityLevel(caster)	--Для Modifier'ов
	if IsServer() then
		local Q = caster:FindAbilityByName("invoker_quantum"):GetLevel()
		local W = caster:FindAbilityByName("invoker_warp"):GetLevel()
		local E = caster:FindAbilityByName("invoker_expanse"):GetLevel()
		local R = caster:FindAbilityByName("invoker_reconstruction"):GetLevel()
		CustomNetTables:SetTableValue("Hash", string.format( "%d", caster:GetEntityIndex() ), 
			{ 
				Q = Q,
				W = W,
				E = E,
				R = R
			} 
		)
	end
	local hT = CustomNetTables:GetTableValue("Hash", string.format( "%d", caster:GetEntityIndex()))
	if hT then
		return hT.Q, hT.W, hT.E, hT.R
	end
	return 0, 0, 0, 0
end

function QWERSystemGetnConstBySpell(nQ, nW, nE, nR, sSpellName, sParameter)
	if not hGlobalGameConst then
		hGlobalGameConst = CustomNetTables:GetTableValue("Hash", "hGameConst")
	end

	local result
	local sParameter_Value = hGlobalGameConst[sSpellName][sParameter]
	local getSphereLevel = function(Q, W, E, R, sParameter_Value)
		local nSphere = sParameter_Value.nSphere
		if nSphere == 1 then
			return Q
		elseif nSphere == 2 then
			return W
		elseif nSphere == 3 then
			return E
		end
		return R--Если сфера не указана, то смотрим R
	end

	if type(sParameter_Value) == "number" then
		result = sParameter_Value
	elseif type(sParameter_Value) == "table" then
		if sParameter_Value.bArithmetictype and sParameter_Value.bArithmetictype == 1 then
			local first = sParameter_Value.first
			local gain = sParameter_Value.gain
			local nSphereLevel = getSphereLevel(nQ, nW, nE, nR, sParameter_Value)
			if gain == nil then
				print("[invoker_reconstruction.lua QWERSystemGetnConstBySpell] gain = nil!, sSpellName=", sSpellName, ", sParameter=", sParameter)
				print("[invoker_reconstruction.lua QWERSystemGetnConstBySpell] sParameter_Value.bArithmetictype=", sParameter_Value.bArithmetictype, ", type(sParameter_Value.bArithmetictype)=", type(sParameter_Value.bArithmetictype))
			end
			result = first + (gain * (nSphereLevel - 1))
		else
			if sParameter_Value.bFuncType then
				--Этот параметр - исключение запускаем функцию вывода
				result = sParameter_Value.func(nQ, nW, nE, nR, sParameter_Value)
			else
				--Этот параметр - перечисление (подобно как в обычной доте)
				local nSphereLevel = getSphereLevel(nQ, nW, nE, nR, sParameter_Value)
				result = sParameter_Value[tostring(nSphereLevel)]	--netTables type(key) = string
			end
		end
	end
	return tonumber(result)
	--[[
	CustomNetTables:SetTableValue("Hash", sSpellName..sParameter, {result = result})
	end
	local hT = CustomNetTables:GetTableValue("Hash", sSpellName..sParameter)
	if hT ~= nil then
	end
	return 0
	]]
end

function invoker_reconstruction:OnAutoCast()
	local caster = self:GetCaster()
	if caster.QWERSystem == nil then
		QWERSystemInit(caster)
	end
	return QWERSystem_BuffUpdate(caster, nil)
end




