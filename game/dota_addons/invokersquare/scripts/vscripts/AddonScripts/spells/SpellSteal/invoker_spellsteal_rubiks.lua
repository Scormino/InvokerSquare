require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')


invoker_spellsteal_rubiks = invoker_spellsteal_rubiks or class({})

local nSpellListPriotity = 1

local sSpellSelect = 'invoker_spellsteal_rubiks_select'
local sSpellApply = 'invoker_spellsteal_rubiks_apply'

local hList = {
	nSpellSlot_eSpell = {}
}

function invoker_spellsteal_rubiks:OnSpellStart()
	local eCaster = self:GetCaster()
	local eTarget = self:GetCursorTarget() 

	hList.eCaster = eCaster
	hList.eTarget = eTarget
	hList.nIndex = self:GetAbilityIndex()	--первоначальный индекс
	--окончательный индекс
	hList.nIndex = SpellSystem:RegisterSpellListToUnit(hList, eCaster, nSpellListPriotity)

	ApplySound(eCaster, 'invoker_spellsteal_rubiks', {
			invoker_invo_lasthit_03 = 1,		--интересно...
			invoker_invo_respawn_10 = 2,		--зная меня, зная(-ю) тебя
		}, 15
	)
end




function hList:SpellListVision(bVision)
	local eCaster = self.eCaster
	if bVision then
		local function CreateButton(sSpell, nSpellSlot)
			local eSpell = eCaster:AddAbility(sSpell)
			eSpell.hList = self
			eSpell.nSpellSlot = nSpellSlot

			eSpell:SetLevel(1)
			return eSpell
		end

		for i = 0, 4 do
			eSelectSpell = CreateButton(sSpellSelect, i)
			self.nSpellSlot_eSpell[i] = eSelectSpell
			eSelectSpell:SetTarget(self.eTarget)
		end
		self.nSpellSlot_eSpell[5] = CreateButton(sSpellApply, 5)
	else
		for _, eSpell in pairs(self.nSpellSlot_eSpell) do
			local sSpellName = eSpell:GetAbilityName()
			eCaster:RemoveAbility(sSpellName)
		end
		self.nSpellSlot_eSpell = {}
		self.nToggleIndex_nSpellSlot = nil
	end
end

--при любой нажатой ToggleButton надо сообщить (из invoker_spellsteal_rubiks_select.lua) hList'у об этом событии
function hList:ToggleButtonApply(nSpellSlot)
	local eSpellApply = self.nSpellSlot_eSpell[5]
	self.nToggleIndex_nSpellSlot = self.nToggleIndex_nSpellSlot or {}

	local bToggle = self.nSpellSlot_eSpell[nSpellSlot]:GetToggleState()
	if bToggle then
		--nSpellSlot был прижат
		local nMaxToggleCount = 2

		--вставляем прижатый элемент
		table.insert(self.nToggleIndex_nSpellSlot, 1, nSpellSlot)

		if #self.nToggleIndex_nSpellSlot > nMaxToggleCount then
			--нажато больше Кнопок, чем допустимо

			local nLastToggleIndex = self.nToggleIndex_nSpellSlot[#self.nToggleIndex_nSpellSlot]
			--отжимаем кнопку по индексу nLastToggleIndex
			self.nSpellSlot_eSpell[nLastToggleIndex]:ToggleAbility()
		end
	else
		--nSpellSlot был отжат
		for nToggleIndex, nCurrentSpellSlot in pairs(self.nToggleIndex_nSpellSlot) do
			if nCurrentSpellSlot == nSpellSlot then
				table.remove(self.nToggleIndex_nSpellSlot, nToggleIndex)
				break
			end
		end
	end
	--local hQWER = QWERSystem:ABSAsync(eSpellApply:GetCaster())
	--self.nSpellSlot_eSpell[SLOT]:ToggleAbility()
end

function invoker_spellsteal_rubiks:OnRefresh()
	local hQWER = QWERSystem:Apply(self, self:GetCaster(), 'invoker_spellsteal_rubiks')
	
	self.nDuration = GetConst(GetGameConst().invoker_spellsteal_rubiks.nDuration, hQWER)
	self.nCooldown = GetConst(GetGameConst().invoker_spellsteal_rubiks.nCooldown, hQWER)
	self.nManaCost = GetConst(GetGameConst().invoker_spellsteal_rubiks.nManaCost, hQWER)
	self.nCastPoint = GetConst(GetGameConst().invoker_spellsteal_rubiks.nCastPoint, hQWER)
	self.nCastRange = GetConst(GetGameConst().invoker_spellsteal_rubiks.nCastRange, hQWER)

	SpellSystem:RefreshComplete(self)
end

function invoker_spellsteal_rubiks:OnUpgrade()
	SyncExecByEnt(self,'OnRefresh')
	--self:OnRefresh()
end

function invoker_spellsteal_rubiks:OnHeroLevelUp()
	SyncExecByEnt(self,'OnRefresh')
	--self:OnRefresh()
end

function invoker_spellsteal_rubiks:GetCooldown()
	return self.nCooldown
end

function invoker_spellsteal_rubiks:GetManaCost()
	return self.nManaCost
end

function invoker_spellsteal_rubiks:GetCastPoint()
	return self.nCastPoint
end

function invoker_spellsteal_rubiks:GetCastRange()
	return self.nCastRange
end


--[[
["Hero_Rubick.NullField.Offense"] = 1,
["Hero_Rubick.NullField.Defense"] = 1,

invoker_invo_ability_invoke_12	--превосходное заклятие
invoker_invo_invis_03	--для этого у меня есть сферы
invoker_invo_lasthit_03	--интересно...
invoker_invo_lasthit_05	--какая.. самоотверженность
invoker_invo_level_03 --богадство, мудрость принадлежат мне
invoker_invo_rare_01	--всё может быть познано, познано мной
invoker_invo_respawn_07	--всё знание параллельно
invoker_invo_respawn_10	--зная меня, зная(-ю) тебя

invoker_invo_thanks_01	--спасибо..	(без сарказма)
invoker_invo_thanks_03	--Б'лагодарю (чуток саракастично)

особое:
invoker_invo_lasthit_06	--прибыльное занятие
invoker_invo_level_09 --блаженство понимания

]]