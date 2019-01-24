require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('AddonScripts/spells/spheres/spheres')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')

invoker_reconstruction = invoker_reconstruction or class({})

local nPermanentSpellSlots 	= 2	--Кол-во постоянно действующих слотов
local nFullSpellSlots		= 5	--Кол-во слотов в ракрытом списке

local nSpellListPriotity	= 0	--приоритет SpellList'а, задаётся при инициализации


local sSpellFreeSlot = 'invoker_reconstruction_empty'
local sSpellPacifier = 'invoker_reconstruction_void'
local hSphereSpellNames = {sQ, sW, sE}

local Reconstruction__sReplic_nON = {
	invoker_invo_ability_invoke_01 = 1,	--моё любимое
	invoker_invo_ability_invoke_02 = 1,	--Сферическое волшебство
	--invoker_invo_ability_invoke_03 = 1,	--Узри!!
	invoker_invo_ability_invoke_04 = 1,	--богатая традиция
	invoker_invo_ability_invoke_07 = 1,	--я хорошо помню это заклятие
	invoker_invo_ability_invoke_08 = 1,	--истинное волшебство - торжествует
	invoker_invo_ability_invoke_09 = 1,	--из недр волшебства
	invoker_invo_ability_invoke_10 = 1,	--мой ум, моё волщебство
	invoker_invo_ability_invoke_11 = 1,	--памятное заклятие
	invoker_invo_ability_invoke_12 = 1,	--превосходное заклятие
	invoker_invo_ability_invoke_15 = 1,	--узри, истинную магию
	invoker_invo_ability_invoke_16 = 1,	--магия распространяется
	--invoker_invo_ability_invoke_17 = 1,	--заклятие, известное только мне

	enigma_enig_fastres_01 = 0.25,  --тайны бытия не знают конца
}


--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--[[внесение системы spell'ов invoker_reconstruction в массив списков способностей данного юнита]]
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--регистрирует текущую систему в память юнита
function invoker_reconstruction:RegisterToSpellList()
	local eUnit = self:GetCaster()

	eUnit.SpellList = eUnit.SpellList or {}
	--eUnit.SpellList[nListId] = hObj
	eUnit.SpellList[self:GetAbilityIndex()] = self
end

--стирает текущую систему из памяти юнита
function invoker_reconstruction:UnRegisterToSpellList()
	if eUnit.SpellList then
		eUnit.SpellList[self:GetAbilityIndex()] = nil
	end
end



--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--[[вспомогательные локальные функции для интерплетации формул spell'ов]]
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
local function GetSphereFormula(eCaster)
	local hFormula = {0, 0, 0}	--заготовка формулы
	local nSphereIndex_eSphere = GethSpheres(eCaster)
	local nCurrentSphereIndex = eCaster.nCurrentSphereIndex
	if not nCurrentSphereIndex then
		return hFormula
	end

	local nFormulaIndex = 1
	local nCheck
	for nCheck = 1, #hBuffSphereNames do
		local eCurrentSphere = nSphereIndex_eSphere[nCurrentSphereIndex]
		if eCurrentSphere then
			hFormula[nFormulaIndex] = eCurrentSphere.nSphereType
			nFormulaIndex = nFormulaIndex + 1
		end

		nCurrentSphereIndex = nCurrentSphereIndex + 1
		if nCurrentSphereIndex > #hBuffSphereNames then
			nCurrentSphereIndex = 1
		end
	end
	return hFormula
end

local function GetSpellNameByFormula(hFormula)
	local function IsEqually(f1, f2)
		local bEquall = true
		for k, v in ipairs(f1) do
			if v ~= f2[k] then
				bEquall = false
				break
			end
		end
		return bEquall
	end

	local sSpellName
	local sAbilName_hConstFormula = hMode.Const.sAbilName_hFormula --GetGameConst().sAbilName_hFormula
	for sConstAbilName, hConstFormula in pairs(sAbilName_hConstFormula) do
		if IsEqually(hFormula, hConstFormula) then
			sSpellName = sConstAbilName
			break
		end
	end
	return sSpellName
end




--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--[[Обработка событий spell'а]]
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
function invoker_reconstruction:OnUpgrade()
	local bFirstUpgrade = false
	local eCaster = self:GetCaster()

	if not self.Spells then
		--Первая инициализация
		self.Spells = {}
		bFirstUpgrade = true
	end

	local hQWER = QWERSystem:Apply(self, eCaster)
	self.nAllowSpellsCount = GetConst(GetGameConst().reconstruction.nAllowSpellsCount, hQWER)
	self.nCooldown = GetConst(GetGameConst().reconstruction.nCooldown, hQWER)
	self.nCooldownBackpackSwapFactor = GetConst(GetGameConst().reconstruction.nCooldownBackpackSwapFactor, hQWER)
	self.nAltCooldown = GetConst(GetGameConst().reconstruction.nAltCooldown, hQWER)

	if bFirstUpgrade then
		self:OnAllRefresh(false, true)	--изначально закрытый BackPack
		--регистрируем SpellList
		self.nSpellList = SpellSystem:RegisterSpellListToUnit(self, eCaster, nSpellListPriotity)
	else
		self:RefreshActivatedSpells()
	end	
	SpellSystem:RefreshAllSpells(eCaster)
end


function invoker_reconstruction:OnSpellStart()
	local eCaster = self:GetCaster()
	local hFormula = GetSphereFormula(eCaster)
	local sSpellName = GetSpellNameByFormula(hFormula)
	self:ApplySpell({
			sSpell = sSpellName,
			bSelfCast = true
		}
	)
end



--механизм открытия/закрытия книжки через [Alt + R] или [ПКМ по кнопке способности]
function invoker_reconstruction:OnAutoCast()
	local bChangeAutoCastState = false	--проходит ли сигнал изменения автокаста spell'а
	local eCaster = self:GetCaster()
	
	if self:GetAutoCastState() then
		--Если автокаст включен
		bChangeAutoCastState = true		--применяем изменения к Toogle способности
		self:OnAllRefresh(false)	--выключаем BackPack способностей
	else
		--если автокаст выключен
		if self:IsCooldownReady() then	--смотрим, есть ли кулдаун
			--если нет кулдауна
			bChangeAutoCastState = true		--применяем изменения к Toogle способности
			self:OnAllRefresh(true)	--включаем BackPack способностей
			if self.nAltCooldown > 0 then
				self:StartCooldown(self.nAltCooldown)	--уводим способность к кд
			end
		end
	end

	return bChangeAutoCastState
end

--обновление видимости SpellList'а
function invoker_reconstruction:SpellListVision(bVision)
	local eCaster = self:GetCaster()
	if bVision == nil then	--чтение видимости SpellList'а
		return self.nSpellList == eCaster.nsSpellListCurrentIndex
	elseif bVision == true then	--SpellList виден
		self:OnAllRefresh()
		eCaster:AddAbility(sSpellPacifier)
		eCaster:SwapAbilities(sR, sSpellPacifier, true, false)
		eCaster:RemoveAbility(sSpellPacifier)
		eCaster:FindAbilityByName(sR):SetHidden(false)
	elseif bVision == false then --SpellList спрятан
		self:SetQWESpellsHidden(true)	--прячем сферы (занимают 6-8 слоты), если они ещё не спрятаны

		--очищаем 0-4 слоты
		self:DeleteAllReconstructionSpells()	--прячем все связанные способности

		--прячем сам invoker_reconstruction (занимает 9 слот)
		for i = 1, nFullSpellSlots do
			eCaster:AddAbility(sSpellPacifier):SetHidden(true)
		end
		eCaster:AddAbility(sSpellFreeSlot) --:SetHidden(true)
		eCaster:SwapAbilities(sR, sSpellFreeSlot, false, true)
		eCaster:RemoveAbility(sSpellFreeSlot)
		eCaster:FindAbilityByName(sR):SetHidden(true)
		for i = 1, nFullSpellSlots do
			eCaster:RemoveAbility(sSpellPacifier)
		end		
	end
end




--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--[[набор функций для создания/удаления списка (кастомных) spell'ов]]
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--физически создаёт способности на основе информации self.Spells о spell'ах
--учитывает текущее состояние (Alt) книжки (открыта или закрыта)
function invoker_reconstruction:CreateSpells()
	local eCaster = self:GetCaster()

	--определяем кол-во способностей которые нужно показать
	local nCountCreateSpells = nPermanentSpellSlots
	if self.bIsBackpackSpellsOpen then
		nCountCreateSpells = nFullSpellSlots
	end	
	local hNewSpells = {}
	--обходим нужные способности из памяти книжки
	for nMemoryIndex = 1, nCountCreateSpells do
		local SS = self.Spells[nMemoryIndex]
		if SS then
			_, hNewSpells[nMemoryIndex] = SpellSystem:InsertSpell({SS = SS, eUnit = eCaster})			
		else
			_, hNewSpells[nMemoryIndex] = SpellSystem:InsertSpell({sSpell = sSpellFreeSlot, eUnit = eCaster})		
		end
	end
	for nMemoryIndex, hNewSS in pairs(hNewSpells) do
		self.Spells[nMemoryIndex] = hNewSS
	end





	--SpellSystem:RefreshAllSpells(eCaster)
	--RefreshAllQWER(eCaster)
end


--удаляет лишь физические способности. self.Spells продолжит хранить информацию о уровнях spell'ов в памяти
--мб использован вхолостую - если spell'а нет, то ничего не сделает
function invoker_reconstruction:DeleteAllReconstructionSpells()
	local eCaster = self:GetCaster()
	--удаляем способности книжки у героя
	for _, SS in pairs(self.Spells) do
		--db('invoker_reconstruction:DeleteAllReconstructionSpells: SS=', SS)
		SpellSystem:DeleteSpell(SS)
	end
	while eCaster:FindAbilityByName(sSpellFreeSlot) do
		eCaster:RemoveAbility(sSpellFreeSlot)
	end
end


function invoker_reconstruction:SetQWESpellsHidden(bHidden, bApplyAnyway)
	local eCaster = self:GetCaster()
	for nSphereSpell, sCurrentSphereSpellName in ipairs(hSphereSpellNames) do
		local eSphereSpell = eCaster:FindAbilityByName(sCurrentSphereSpellName)
		if eSphereSpell then
			if (bApplyAnyway) or (eSphereSpell:IsHidden() ~= bHidden) then
				if bHidden then
					for i = 1, nSphereSpell-1 do
						eCaster:AddAbility(sSpellPacifier):SetHidden(true)
					end
					eCaster:AddAbility(sSpellFreeSlot):SetHidden(true)
					eCaster:SwapAbilities(sCurrentSphereSpellName, sSpellFreeSlot, false, true)
					eCaster:RemoveAbility(sSpellFreeSlot)
					for i = 1, nSphereSpell-1 do
						eCaster:RemoveAbility(sSpellPacifier)
					end
				else
					eCaster:AddAbility(sSpellPacifier):SetHidden(true)
					eCaster:SwapAbilities(sCurrentSphereSpellName, sSpellPacifier, true, false)
					eCaster:RemoveAbility(sSpellPacifier)
				end
				eSphereSpell:SetHidden(bHidden)
			end
		end
	end
end


function invoker_reconstruction:RefreshActivatedSpells()
	local bActivated = hMode.bAllowReconstructionSpells
	for nMemoryIndex, SS in pairs(self.Spells) do
		local eSpell = EntIndexToHScript(SS.nObj)
		if eSpell then
			if bActivated then
				--если активация включена, то ставим активацию в зависимости от прокачки invoker_reconstruction
				if nMemoryIndex > self.nAllowSpellsCount then
					--eSpell:SetActivated(false)
					if eSpell:GetLevel() > 0 then
						eSpell:SetLevel(0)
					end
				else
					--eSpell:SetActivated(true)
					if eSpell:GetLevel() <= 0 then
						eSpell:SetLevel(1)
					end	
				end
			else
				--Если выключен, то в любом случае активация выключена
				--eSpell:SetActivated(false)
				if eSpell:GetLevel() > 0 then
					eSpell:SetLevel(0)
				end	
			end
		end
	end
end


function invoker_reconstruction:OnAllRefresh(bIsBackpackSpellsOpen, bApplyAnyway)
	if bIsBackpackSpellsOpen ~= nil then
		self.bIsBackpackSpellsOpen = bIsBackpackSpellsOpen
	end

	if self:SpellListVision() then
		if self.bIsBackpackSpellsOpen then
			self:SetQWESpellsHidden(true, bApplyAnyway)
			self:DeleteAllReconstructionSpells()
		else
			self:DeleteAllReconstructionSpells()
			self:SetQWESpellsHidden(false, bApplyAnyway)
		end

		self:CreateSpells()
		self:RefreshActivatedSpells()	
	end
end


--добавляет способность в память, если имеется фокус списка способностей, то сразу обновляет все spell'ы связанных с invoker_reconstruction
function invoker_reconstruction:ApplySpell(data)	
	local sSpell = data.sSpell
	local sLevelType_hLevels = data.sLevelType_hLevels
	local bSelfCast = data.bSelfCast	--если сам игрок прожал способность
	local bReplicas = false	--будут ли использованы реплики
	local CustomReplicas__sReplic_nON = data.sReplic_nON	--особые реплики (если есть)
	
	local nCooldown = 0

	local hNewSpells = {}
	for nMemoryIndex, SS in pairs(self.Spells) do	--явно копируем старые данные, чтобы не затронуть их
		hNewSpells[nMemoryIndex] = SS
	end

	if sSpell then
		local nMemoryBackpackSpell --это индекс совпадающей способности
		for nMemoryIndex, SS in pairs(self.Spells) do
			if SS.sObj == sSpell then
				nMemoryBackpackSpell = nMemoryIndex
				break
			end
		end
		if nMemoryBackpackSpell then
			--есть совпадающая способность
			if nMemoryBackpackSpell > nPermanentSpellSlots then
				nCooldown = self.nCooldown * self.nCooldownBackpackSwapFactor
			else
				nCooldown = 0
			end
			--меняем местами способности
			hNewSpells[1], hNewSpells[nMemoryBackpackSpell] = hNewSpells[nMemoryBackpackSpell], hNewSpells[1]
		else
			--нет совпадающей способности
			nCooldown = self.nCooldown
			for nMemoryIndex = nFullSpellSlots, 2, -1 do	--смещаем всё вправо
				hNewSpells[nMemoryIndex] = hNewSpells[nMemoryIndex-1]
			end
			--присваиваем новую способность
			hNewSpells[1] = {sSpell = sSpell}
			bReplicas = true
		end
		if sLevelType_hLevels then
			hNewSpells[1].sLevelType_hLevels = sLevelType_hLevels
		end
	else
		--перемешиваем способности
		if self.bIsBackpackSpellsOpen then
			nCooldown = self.nCooldown * self.nCooldownBackpackSwapFactor
			local hLastSpell = hNewSpells[nFullSpellSlots]
			for nMemoryIndex = nFullSpellSlots, 2, -1 do	--смещаем всё вправо
				hNewSpells[nMemoryIndex] = hNewSpells[nMemoryIndex-1]
			end
			hNewSpells[1] = hLastSpell
		else
			hNewSpells[1], hNewSpells[2] = hNewSpells[2], hNewSpells[1]
		end
	end

	--применяем изменения
	self:DeleteAllReconstructionSpells()
	self.Spells = hNewSpells

	if self:SpellListVision() then
		self:CreateSpells()
		self:RefreshActivatedSpells()	
	end

	--принимаем кулдаун
	if bSelfCast and nCooldown > 0 then
		self:StartCooldown(nCooldown)
	end

	--применяем озвучку персонажа
	if bReplicas then
		local sReplic_nON = CustomReplicas__sReplic_nON or Reconstruction__sReplic_nON	--выбираем подходящий набор реплик
		ApplySound(self:GetCaster(), 'invoker_reconstruction', sReplic_nON)
	end
end
































