require('AddonScripts/ModifierSync')


local nDEFAULT_OUT_LEVEL = 0 --Выставляется, если способности таковой не нашлось

local nSPELL_COUNT = 5 --Всего доступных способностей для проверки
local sPACIFIER = 'invoker_empty2'

--SSSystem = SSSystem or class({})
if not SpellSystem then
  SpellSystem = class({})

  SpellSystem.Tooltips = {}
  SpellSystem.Tooltips.nPlayer_hTrafficData = {}
end




--обновить всё, что связано с этим юнитом
function SpellSystem:FullRefreshUnit(u)
  self:RefreshAllBuffs(u)
  self:RefreshAllSpells(u)

  --пройдём всех юнитов героя и обновим их
  if u.groups then
    for _, n_unit in pairs(u.groups) do
      for _, unit in pairs(n_unit) do
        if unit and IsValidEntity(unit) and u ~= unit then 
          self:RefreshAllBuffs(unit)
          self:RefreshAllSpells(unit)
        end
      end
    end
  end

  self:ABS(u, nil, u)

  self:ForceTooltipSync() --Обновляет Tooltip'ы у всех
end

function SpellSystem:FullRefreshPlayer(nPlayer)
  local eHero = PlayerResource:GetPlayer(nPlayer):GetAssignedHero()
  self:FullRefreshUnit(eHero)
end

function SpellSystem:dota_player_gained_level(keys)
  self:FullRefreshPlayer(keys.player-1)
end

function SpellSystem:dota_player_learned_ability(keys)
  self:FullRefreshPlayer(keys.player-1)
end






function SpellSystem:ApplyBuff(hData)
  local sBuff = hData.sBuff
  local eCaster = hData.eCaster
  local eParent = hData.eParent or eCaster
  local eSourceAbility = hData.eSourceAbility
  local hDeviationsFormDefault = hData.hStats or {}

  local hStats = hMode.Const.modifiers[sBuff]
  if hStats then
    for k, v in pairs(hDeviationsFormDefault) do  --отличия от стандарта
      hStats[k] = v
    end
  else
    hStats = hDeviationsFormDefault
  end

  local nOldBuffsCount = #eCaster:FindAllModifiers()  --просто кол-во баффов у юнита
  local eBuff = eParent:AddNewModifier(eCaster or eParent, eSourceAbility, sBuff, hStats)
  --SpellSystem:BuffOnCreated(eBuff) (выполнится сразу после AddNewModifier)

  return eBuff, eBuff.nIndex
end



function SpellSystem:BuffIndexApply(eBuff)
  --Код рассчитан на (1)СЕРВЕР-(2)КЛИЕНТ, СЕРВЕР
  if eBuff and eBuff.GetParent then
    local nIndex
    if IsServer() then --если бафф уже имеет индекс
      nIndex = eBuff.nIndex
    end
    nIndex = Sync(nIndex, eBuff:GetName()..'nIndex')
    if nIndex then
      return nIndex
    else
      local eParent = eBuff:GetParent()
      
      local hSyncPack = {
        bCreateBuffIndex = false
      }
      if IsServer() then
        local hCurrentBuffs = eParent:FindAllModifiers()

        hSyncPack.nBuffAbsCount = (eParent.nBuffAbsCount or 0)
        for n, eCurrentBuff in ipairs(hCurrentBuffs) do
          --db('SpellSystem:BuffIndexApply, hCurrentBuffs['..n..']='..eCurrentBuff:GetName())
          if not eCurrentBuff.nIndex then --если нету индекса, то создаём его
            --db('SpellSystem:BuffIndexApply, bCreateBuffIndex=true')
            hSyncPack.bCreateBuffIndex = true
            hSyncPack.nBuffAbsCount = hSyncPack.nBuffAbsCount + 1
            break
          end
        end
      end

      --Дополнительная очистка памяти

      eParent.nBuff_eBuff = eParent.nBuff_eBuff or {}
      --print('SpellSystem:BuffIndexApply('..eBuff:GetName()..'), eParent.nBuff_eBuff..., IsServer=', IsServer())
      for nOldBuff, eOldBuff in pairs(eParent.nBuff_eBuff) do
        if eOldBuff:IsNull() then
          --print('SpellSystem:BuffIndexApply, eParent.nBuff_eBuff['..nOldBuff..']=nil')
          eParent.nBuff_eBuff[nOldBuff] = nil
        else
          --print('SpellSystem:BuffIndexApply, eParent.nBuff_eBuff['..nOldBuff..']=', eOldBuff:GetName())
        end
      end

      hSyncPack = Sync(hSyncPack, 'BuffIndexApply_'..eBuff:GetName())

      eParent.nBuffAbsCount = hSyncPack.nBuffAbsCount
      if hSyncPack.bCreateBuffIndex then
        nIndex = hSyncPack.nBuffAbsCount
        eParent.nBuff_eBuff[nIndex] = eBuff
        eBuff.nIndex = nIndex
        
        return nIndex
      else
        print('(SpellSystem:BuffIndexApply) WARNING, '..eBuff:GetName()..'.nIndex == nil! and will not be created, IsServer=', IsServer())
      end
    end
  end
end


--[[
        db('SpellSystem:BuffIndexApply'..eBuff:GetName()..'eParent:FindAllModifiers()=',eParent:FindAllModifiers())
        local hCurrentBuffs = eParent:FindAllModifiers()
        local nCurrentBuffCount = #hCurrentBuffs

        db('SpellSystem:BuffIndexApply, eBuff='..eBuff:GetName()..', eParent.nBuff_eBuff=')
        local nOldBuffCount = 0
        for n, eOldBuff in pairs(eParent.nBuff_eBuff) do
          if eOldBuff then
            if eOldBuff:IsNull() then
              eParent.nBuff_eBuff[n] = nil
            else
              db('SpellSystem:BuffIndexApply, eParent.nBuff_eBuff['..n..']='..eOldBuff:GetName())
              
              nOldBuffCount = nOldBuffCount + 1
            end
          end
        end




        if nCurrentBuffCount > nOldBuffCount then
          --появился новый бафф
          hSyncPack.bCreateBuffIndex = true
          
        else
          --такой бафф уже существует
          hSyncPack.nBuffAbsCount = eParent.nBuffAbsCount
        end

]]











function SpellSystem:BuffOnCreated(eBuff)
  --CLIENT + SERVER
  local nBuffIndex = self:BuffIndexApply(eBuff)

  if IsServer() then
    self:ForceInfluenceIn(eBuff)
  end

  eBuff:OnRefresh(nil)

  return nBuffIndex
end

--eObj ~ eSpell, eBuff
function SpellSystem:RefreshComplete(eObj, hSendData)
  --CLIENT + SERVER
  if IsServer() and eObj then
    self:ForceTooltipSync(eObj, nil, hSendData)
  end
end

function SpellSystem:BuffOnDestroy(eBuff)
  --CLIENT + SERVER
  if IsServer() and eBuff.CustomOutInfluence then
    local eHero = eBuff:GetParent()
    Timers:CreateTimer(
      function()
        --self:RefreshAllBuffs(eHero)
        --self:RefreshAllSpells(eHero)
        --self:ForceTooltipSync() --Обновляет Tooltip'ы у всех

        self:FullRefreshUnit(eHero)
      end
    )
  end
end


function SpellSystem:RefreshSpell(eSpell)
  if eSpell then
    if eSpell.OnRefresh then
      SyncExecByEnt(eSpell,'OnRefresh')
          
      --eUnit:GetAbilityByIndex(i):OnRefresh()
    end
    --[[
    local SS = self:Get(eSpell)
    if SS then
      self:ForceTooltipSync(eSpell)
    end 
    ]]
  end
end

function SpellSystem:RefreshAllSpells(eUnit)
  for nSpellIndex=0, eUnit:GetAbilityCount()-1 do
    self:RefreshSpell(eUnit:GetAbilityByIndex(nSpellIndex))
  end
end

function SpellSystem:RefreshBuff(eBuff)
  if eBuff then
    --db('SpellSystem:RefreshBuff, SyncExecByEnt('..eBuff:GetName()..')')
    SyncExecByEnt(eBuff,'OnRefresh')
  else
    db('SpellSystem:RefreshBuff, eBuff == nil!!!')
  end
end

function SpellSystem:RefreshAllBuffs(eUnit, n_eBuffException)
  if eUnit and eUnit.FindAllModifiers then
    self:InfluenceFullCalculate(eUnit)
    --[[for _, eBuff in pairs(eUnit:FindAllModifiers()) do
      if bRefresh then
        self:RefreshBuff(eBuff)
        local SS = self:Get(eBuff)
        if SS then
          self:ForceTooltipSync(eBuff)
        end
      end
      
    end 
    ]]
  end
end



--[[
function SpellSystem:SendBuffTooltipInfo(nEventSourceIndex, hBuffAllInfo)
	local nCaster = hBuffAllInfo.nCaster
	local nBuff = hBuffAllInfo.nBuff
  local sBuff = hBuffAllInfo.sBuff
  
  local eCaster = EntIndexToHScript(nCaster)
  local hBuffs = (sBuff and eCaster:FindAllModifiersByName(sBuff)) or eCaster:FindAllModifiers()

  for _, eCurrentBuff in pairs(hBuffs) do
    if eCurrentBuff.nIndex == nBuff then
      hBuffAllInfo.sLevelName_hLevels = eCurrentBuff.SS.sLevelName_hLevels
      break
    end
  end

  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(hBuffAllInfo.PlayerID), "SERVER_send_buff_info_signal", hBuffAllInfo)
end
if IsServer() then
  CustomGameEventManager:RegisterListener( "CLIENT_send_buff_info_signal", SpellSystem.SendBuffTooltipInfo)
end
]]




function SpellSystem:ForceTooltipSync(eObj, nPlayer, hSendData)
  require('Gamemodes/ClassicMode/QWERSystem')

  local function GetTrafficObj(nPlayer)
    local hTrafficData = self.Tooltips.nPlayer_hTrafficData[nPlayer]
    local eParent = EntIndexToHScript(hTrafficData.nEntityParent)
    local nIndex = hTrafficData.nEntityIndex

    local eObj
    if hTrafficData.sType == 'unit' then
      if nIndex then
        eObj = EntIndexToHScript(nIndex)
      end
    elseif hTrafficData.sType == 'spell' then
      local sName = hTrafficData.sName
      if nIndex then
        eObj = EntIndexToHScript(nIndex)
      elseif sName then
        eObj = eParent and eParent:FindAbilityByName(sName)
      end
    elseif hTrafficData.sType == 'buff' then
      if nIndex then
        eObj = self:GetBuff(eParent, nIndex)
      end
    end

    return eObj, eParent
  end
  local function TooltipTrafficUpdateToPlayer(hSendData, nPlayer)
    local hTrafficData = self.Tooltips.nPlayer_hTrafficData[nPlayer]

    hSendData.nSyncEventIndex = hTrafficData.nSyncEventIndex
    hSendData.sType = hTrafficData.sType

    --db('SpellSystem:ForceTooltipSync, hSendData=', hSendData)
    local hSyncTable = Table2StringTable(hSendData) --нейтрализуем утечки
    CustomNetTables:SetTableValue('tooltips', tostring(nPlayer), hSyncTable)
  end
  local function CheckActiveTooltip(eObj, nPlayer)
    local function GetObjIndex(eObj)
      local nIndex, nParentIndex
      if eObj.GetEntityIndex then
        nIndex = eObj:GetEntityIndex()
        --nParentIndex = eObj.nEntityParent
      elseif eObj.nIndex then
        nIndex = eObj.nIndex

        local SS = SpellSystem:Get(eObj)
        nParentIndex = SS and SS.nParent
      end
      return nIndex, nParentIndex
    end

    local eActiveObj = GetTrafficObj(nPlayer)
    if eActiveObj then
      local nActiveIndex, nActiveParentIndex = GetObjIndex(eActiveObj)
      local nRefreshedIndex, nRefreshedParentIndex = GetObjIndex(eObj)
      if (nActiveIndex and nRefreshedIndex) 
        and (nActiveIndex == nRefreshedIndex)
        and (nActiveParentIndex == nRefreshedParentIndex)
      then
        return true
      end
    end
    return false
  end
  
  local function TooltipObjProcessing(eObj, hSendData, nPlayer)
    if CheckActiveTooltip(eObj, nPlayer) then
      TooltipTrafficUpdateToPlayer(hSendData, nPlayer)
    end
  end
  local function TooltipNoObjProcessing(nPlayer)
    local eObj, eParent = GetTrafficObj(nPlayer)

    if not eObj then
      eObj = eParent
    end

    if not hSendData then
      eObj.bOnlyRefresh = true
      _, hSendData = QWERSystem:ABSAsync(eObj)
    end
    TooltipTrafficUpdateToPlayer(hSendData, nPlayer)
  end


  if eObj then
    if not hSendData then
      eObj.bOnlyRefresh = true
      _, hSendData = QWERSystem:ABSAsync(eObj)
    end
    if nPlayer then
      TooltipObjProcessing(eObj, hSendData, nPlayer)
    else
      for nCurrentPlayer in pairs(self.Tooltips.nPlayer_hTrafficData) do
        TooltipObjProcessing(eObj, hSendData, nCurrentPlayer)
      end
    end
  else
    if nPlayer then
      TooltipNoObjProcessing(nPlayer)
    else
      for nCurrentPlayer in pairs(self.Tooltips.nPlayer_hTrafficData) do
        TooltipNoObjProcessing(nCurrentPlayer)
      end
    end
  end
end


function SpellSystem:UpdateTooltipTraffic(hInfo)  --при каждом наведении на spell или buff
  self.Tooltips.nPlayer_hTrafficData[hInfo.PlayerID] = hInfo

  local eObj
  if hInfo.nEntityIndex ~= -1 then
    if hInfo.sType == 'spell' then
      eObj = EntIndexToHScript(hInfo.nEntityIndex)
    elseif hInfo.sType == 'buff' then
      local eParent = EntIndexToHScript(hInfo.nEntityParent)
      eObj = self:GetBuff(eParent, hInfo.nEntityIndex)
    end
  end
  self:ForceTooltipSync(eObj, hInfo.PlayerID)
end

local function ReciveTraffic(nEventIndex, hInfo)
  SpellSystem:UpdateTooltipTraffic(hInfo)
end
if IsServer() then
  CustomGameEventManager:RegisterListener( "CLIENT_update_tooltip_traffic", ReciveTraffic)
end

--[[
function ApplyBuffLevels(eBuff, hLevels, eOwnerLevels)
  eOwnerLevels = eOwnerLevels or eBuff:GetCaster()
  RefreshBuffBaseLevel(eBuff, hLevels, eOwnerLevels)
  
  --local hSyncTable = Table2StringTable(eBuff.SS.sLevelName_hLevels) --нейтрализуем утечки
  --CustomNetTables:SetTableValue('tooltips', 'buff_'..tostring(eBuff:GetEntityIndex()), hSyncTable)

  return GetSpellAbsLevel(eBuff, hLevels)
end
]]




function SpellSystem:RefreshTooltipByObj(hObj)
  if hObj then
    local hData = {}

    if hObj.GetUnitName or hObj.GetAbilityName  then
      --hObj ~ eUnit or eSpell
      hData.nIndex = hObj:GetEntityIndex()
    elseif hObj.GetName and hObj.GetParent then
      --hObj ~ CEntityInstance (+buff)
      hData.nIndex = hObj.nIndex
      hData.nParent = hObj:GetParent():GetEntityIndex()
    else
      --hObj ~ SS
      return
    end

    CustomGameEventManager:Send_ServerToAllClients("RefreshTooltipsUnitData", hData)
  end
end


--[[
function RefreshTooltipByEnt(eEnt)
  if eEnt then
    local hData = {}
    if eEnt.GetAbilityName then
      --SPELL
      hData.nSpell = eEnt:GetAbilityIndex()
    else
      --BUFF
      hData.nParent = eEnt:GetParent():GetEntityIndex()
      hData.nBuff = eEnt.nIndex
    end
    CustomGameEventManager:Send_ServerToAllClients("RefreshTooltipsUnitData", hData)
  end
end


function RefreshBuffBaseLevel(eBuff, n_sLevelName, eOwnerLevels) --обновить базовые уровни способности
  local OUT_levels = GetUnitOUTlevel(eOwnerLevels or eBuff:GetCaster(), n_sLevelName)

  local hBase = GetSS(eBuff, true).sLevelName_hLevels.base
  for sLevelParam, nOUT_level in pairs(OUT_levels) do
    local nOldBaseLevel = hBase[sLevelParam] or 0 --внутренний уровень текущего параметра
    hBase[sLevelParam] = math.max(nOldBaseLevel, nOUT_level)
  end
  
  return hBase
end

function BuffLevelsFree(eBuff)
  CustomNetTables:SetTableValue('tooltips', 'buff_'..tostring(eBuff:GetEntityIndex()), nil)
end
]]




--function RefreshAllSS(eUnit, n_sLevelName)
function SpellSystem:RefreshSSpellsByUnit(eUnit, n_sLevelName)
  for nSpellIndex = 0, nSPELL_COUNT do
    local eSpell = eUnit:GetAbilityByIndex(nSpellIndex)
    if eSpell then
      RefreshSpellBaseLevel(eSpell, n_sLevelName)
      
      local hSyncTable = Table2StringTable(eSpell.SS.sLevelName_hLevels) --нейтрализуем утечки
      CustomNetTables:SetTableValue('tooltips', tostring(eSpell:GetEntityIndex()), hSyncTable)
      --GetSpellAbsLevel(eSpell, n_sLevelName)
    end
  end
end


  
  --CustomGameEventManager:Send_ServerToAllClients( "RefreshTooltips", nil )
--end































function SpellSystem:DeleteSpell(hData)
  if not hData then
    return nil, 'SpellSystem:DeleteSpell(hData == nil) => return nil'
  end

  local eSpell, SS  --Определяем способность и SS
  if hData.GetAbilityName then
    --hData is SPELL
    eSpell = hData
    SS = self:Get(eSpell, true)
  else 
    --hData is SS
    eSpell = EntIndexToHScript(hData.nObj)
    if not eSpell then
      return nil, 'SpellSystem:DeleteSpell: |EntIndexToHScript(hData.nObj) == nil| => return nil'
    end
    SS = hData
  end
  
  local eUnit = eSpell:GetCaster()
  local hReservedSpells = {}
  for nSpellIndex = 0, nSPELL_COUNT do
    local eCurrentSpell = eUnit:GetAbilityByIndex(nSpellIndex)
    --print('nSpellIndex = ' .. nSpellIndex, ', eCurrentSpell=', eCurrentSpell)
    if eCurrentSpell then
      local nCurrentSpell = eCurrentSpell:GetEntityIndex()
      local sCurrentSpell = eCurrentSpell:GetAbilityName()
      if nCurrentSpell == SS.nObj then
        --тот же самый скилл
        --print('REMOVE = ', sCurrentSpell)
        SS = self:Get(eCurrentSpell, true)
        --DelByEnt(eSpell)  --уничтожаем всю информацию с NetTables
        --print('tooltips('..nCurrentSpell..') = nil')
        --CustomNetTables:SetTableValue('tooltips', tostring(nCurrentSpell), nil)
        eUnit:RemoveAbility(sCurrentSpell)
        break
      else
        if sCurrentSpell == SS.sObj then
          --есть одинаковый скилл
          hReservedSpells[#hReservedSpells+1] = self:Get(eCurrentSpell, true)
          eUnit:RemoveAbility(sCurrentSpell)
        end
      end
    end
  end
  for nReservedIndex, CurrentSS in ipairs(hReservedSpells) do
    local eReservedSpell = eUnit:AddAbility(CurrentSS.sObj)
    eReservedSpell.SS = CurrentSS
    if CurrentSS.sLevelName_hLevels.nSelfLevel.base + CurrentSS.sLevelName_hLevels.nSelfLevel.add > 0 then
      eReservedSpell:SetLevel(CurrentSS.sLevelName_hLevels.nSelfLevel)
    end
  end
  
  return SS
end





function SpellSystem:InsertSpell(hData)
  if not hData then 
    db('SpellSystem:InsertSpell(hData == nil) => return nil')
    return
  end
  local SS = hData.SS or {}

  local sSpell = hData.sSpell or SS.sObj or SS.sSpell
  local eUnit = hData.eUnit
  local nSlot = hData.nSlot
  local nLevel = hData.nLevel or 0
  local sLevelName_hLevels = hData.sLevelName_hLevels or SS.sLevelName_hLevels

  --добираемся до нужного слота
  local nPacifiersCount = 0 --кол-во способностей "пустышек"
  if nSlot then 
    for nSpellIndex = 0, nSlot do
      local eCurrentSpell = eUnit:GetAbilityByIndex(nSpellIndex)
      if nSpellIndex == nSlot then
        if eCurrentSpell then
          --db('DELETE SPELL!')
          DeleteSpell(self:Get(eCurrentSpell, true))
        end
      else
        if not eCurrentSpell then --если спелла нету
          eUnit:AddAbility(sPACIFIER)  --то добавляем способность "пустышку"
          nPacifiersCount = nPacifiersCount + 1
        end
      end
    end 
  end
  --print('CreateSpell, eUnit=', eUnit:GetUnitName(), ', sSpell=', sSpell)
  local eSpell = eUnit:AddAbility(sSpell)
  --print('InsertSpell = ', eSpell:GetAbilityName())
  for i = 1, nPacifiersCount do
    eUnit:RemoveAbility(sPACIFIER)
  end  

  if nLevel > 0 then
    eSpell:SetLevel(nLevel)
  end
  local SS_Spell = self:Get(eSpell, true)
  if sLevelName_hLevels and SS_Spell then
    for sLevelName, hLevels in pairs(sLevelName_hLevels) do
      SS_Spell.sLevelName_hLevels[sLevelName] = {}
      for sLevelType, nCurrentLevel in pairs(hLevels) do
        SS_Spell.sLevelName_hLevels[sLevelName][sLevelType] = nCurrentLevel
      end
    end
  end

  self:RefreshSpell(eSpell)

  return eSpell, SS_Spell
end






--eParent ~ eUnit
--nBuffIndex ~ eBuff.nIndex
--return eBuff
function SpellSystem:GetBuff(eParent, nBuffIndex)
  if (eParent and nBuffIndex) and eParent.FindAllModifiers then
    local hBuffs = eParent:FindAllModifiers()
    for _, eCurrentBuff in pairs(hBuffs) do
      if eCurrentBuff.nIndex == nBuffIndex then
        return eCurrentBuff
      end
    end
  end
end


--[[
  hObj - может быть:
    eUnit
    eSpell
    eBuff
    (или любым другим SS)

  n_sLevelName = это таблица нужных уровней по названию уровня
  eOwnerBuffs = может быть:
    eUnit
    bRefresh

  return sLevelName_nLevel, SS  (возвращает таблицу "название уровня"-"соответствующий уровень", и абстрактный SS)
]]
function SpellSystem:ABS(hObj, n_sLevelName, eOwnerBuffs)
  if hObj then
    local hBASE
    local hADD

    if eOwnerBuffs then
      --ABS с обновлением
      eOwnerBuffs = ((type(eOwnerBuffs) == 'boolean') and hObj) or eOwnerBuffs
    
      hBASE = self:BASE(hObj, n_sLevelName, eOwnerBuffs)
      hADD = self:ADD(hObj, n_sLevelName, eOwnerBuffs)
    else
      --ABS, только чтение
      hBASE = self:GetBASE(hObj, n_sLevelName)
      hADD = self:GetADD(hObj, n_sLevelName)
    end
    hBASE = hBASE or {}
    hADD = hADD or {}

    local sLevelName_nLevel = {}
    if n_sLevelName then
      for _, sLevelName in pairs(n_sLevelName) do
        local nCurrentBaseLevel = hBASE[sLevelName] or 0
        local nCurrentADDLevel = hADD[sLevelName] or 0
        sLevelName_nLevel[sLevelName] = nCurrentBaseLevel + nCurrentADDLevel
      end
    else
      sLevelName_nLevel = hBASE
      for sLevelName, nLevel in pairs(hADD) do
        sLevelName_nLevel[sLevelName] = (sLevelName_nLevel[sLevelName] or 0) + nLevel
      end
    end
    return sLevelName_nLevel, self:Get(hObj)
  end
end






























function SpellSystem:InfluenceFullCalculate(eUnit)
  local hBuffs = eUnit:FindAllModifiers()
  for _, eBuff in pairs(hBuffs) do
    self:ForceInfluenceIn(eBuff)
    self:ForceInfluenceOut(eBuff)
  end
  for _, eBuff in pairs(hBuffs) do
    --self:InfluenceCalculate(eBuff)   

    eBuff.bOnlyRefresh = true
    self:RefreshBuff(eBuff) 
  end
end


function SpellSystem:InfluenceCalculate(eObj)
  local SS = self:Get(eObj)
  if SS.nBuff_hInfluence then
    local eParent = (SS.nParent and EntIndexToHScript(SS.nParent)) or eObj:GetParent()
    local hInfluenceLevels = {}
    for nBuff, sInfluenceLevelName_nLevel in pairs(SS.nBuff_hInfluence) do
      local eCurrentBuff = eParent.nBuff_eBuff[nBuff]
      if not eCurrentBuff or eCurrentBuff:IsNull() then
        SS.nBuff_hInfluence[nBuff] = nil
        eParent.nBuff_eBuff[nBuff] = nil
      else
        for sLevelName, nLevel in pairs(sInfluenceLevelName_nLevel) do
          hInfluenceLevels[sLevelName] = (hInfluenceLevels[sLevelName] or 0) + nLevel
        end
      end
    end

    return hInfluenceLevels
  end
end


--создание таблицы воздействия eSource на eTarget
local function ForceInfluence(eSource, eTarget) 
  if eSource.CustomOutInfluence then
    local SSTarget = SpellSystem:Get(eTarget, true) 
    local sInfluenceLevelName_nLevel = eSource:CustomOutInfluence(SSTarget)
    if sInfluenceLevelName_nLevel then
      SSTarget.nBuff_hInfluence = SSTarget.nBuff_hInfluence or {}
      SSTarget.nBuff_hInfluence[eSource.nIndex] = sInfluenceLevelName_nLevel
    end
  end 
end

--eSpell or eBuff
function SpellSystem:ForceInfluenceIn(eTarget)
  local eParent = eTarget:GetParent()

  local hBuffs = eParent:FindAllModifiers()
  for _, eSource in pairs(hBuffs) do
    ForceInfluence(eSource, eTarget)
  end
end

--eBuff
function SpellSystem:ForceInfluenceOut(eSource)
  if eSource.CustomOutInfluence then
    local eParent = eSource:GetParent()

    local hBuffs = eParent:FindAllModifiers()
    for _, eTarget in pairs(hBuffs) do
      ForceInfluence(eSource, eTarget)
    end

    local nSpellIndex
    for nSpellIndex=0, eParent:GetAbilityCount()-1 do
      local eTarget = eParent:GetAbilityByIndex(nSpellIndex)
      if eTarget then
        ForceInfluence(eSource, eTarget)
      end
    end

    require('Gamemodes/ClassicMode/QWERSystem')
    local eR = eParent:FindAbilityByName(sR)
    if eR and eR.Spells then
      local i
      for i = 1, 5 do
        local SSpell = eR.Spells[i]
        if SSpell  then
          ForceInfluence(eSource, SSpell)
        end
      end
    end

  end
end

--[[
  hObj - может быть:
    eUnit
    eSpell
    eBuff
    (или любым другим SS)
    nil (можно создать ADD уровни в памяти)

  n_sLevelName = это таблица нужных уровней по названию уровня
  eOwnerBuffs = может быть только:
    eUnit

  return sLevelName_nLevel, SS  (возвращает таблицу "название уровня"-"соответствующий уровень", и абстрактный SS)
]]

function SpellSystem:ADD(hObj, n_sLevelName, eOwnerBuffs)
  if not hObj then 
    hObj = self:Get()
  end
  local SS = self:Get(hObj, true)
  local eObj = self:GetEnt(SS)
  if eObj then
    if eObj.CustomOutInfluence and not eObj.bOnlyRefresh then
      --FullRefresh
      eOwnerBuffs = (eOwnerBuffs and eOwnerBuffs.GetUnitName and eOwnerBuffs)
        or (hObj.GetCaster and hObj:GetCaster())
        or (hObj.GetParent and hObj:GetParent())
        or (hObj.nParent and EntIndexToHScript(hObj.nParent))
      self:InfluenceFullCalculate(eOwnerBuffs)
    end
    eObj.bOnlyRefresh = nil

    --Only Refresh
    local sLevelName_nLevel = self:InfluenceCalculate(eObj)

    --перезапись данных hObj'та
    --db('SpellSystem:ADD, sLevelName_nLevel=', sLevelName_nLevel)

    --удаляем старые записи доп. уровней
    for sLevelName in pairs(SS.sLevelName_hLevels) do
      SS.sLevelName_hLevels[sLevelName].add = nil
    end

    --записываем обновлённые, если есть
    if sLevelName_nLevel then
      for sLevelName, nLevel in pairs(sLevelName_nLevel) do
        SS.sLevelName_hLevels[sLevelName] = SS.sLevelName_hLevels[sLevelName] or {}
        SS.sLevelName_hLevels[sLevelName].add = nLevel
      end
    end
    return sLevelName_nLevel, SS
  end

  
  

  --[[
  local hNewAddLevels = {}
  local hBuffs = eOwnerBuffs:FindAllModifiers()
  for _, eCurrentBuff in pairs(hBuffs) do
    if eCurrentBuff.CustomOutInfluence then
      local sInfluenceLevelName_nLevel = eCurrentBuff:CustomOutInfluence(SS, hOldAddLevels)
      if sInfluenceLevelName_nLevel then
        for sLevelName, nLevel in pairs(sInfluenceLevelName_nLevel) do
          hNewAddLevels[sLevelName] = (hNewAddLevels[sLevelName] or 0) + nLevel
        end
      end
    end
  end
  local nSpellIndex
  for nSpellIndex=0, eOwnerBuffs:GetAbilityCount()-1 do
    local eSpell = eOwnerBuffs:GetAbilityByIndex(nSpellIndex)
    if eSpell and eSpell.CustomOutInfluence then
      local sInfluenceLevelName_nLevel = eSpell:CustomOutInfluence(SS, hOldAddLevels)
      if sInfluenceLevelName_nLevel then
        for sLevelName, nLevel in pairs(sInfluenceLevelName_nLevel) do
          hNewAddLevels[sLevelName] = (hNewAddLevels[sLevelName] or 0) + nLevel
        end
      end
    end
  end
  ]]

end


--[[
  hObj - может быть:
    eUnit
    eSpell
    eBuff
    (или любым другим SS)
    nil (можно создать BASE уровни в памяти или перезаписать с hNewObj)

  n_sLevelName = это таблица нужных уровней по названию уровня
  hNewObj = это новая информация, может быть:
    eUnit
    eSpell
    eBuff
    (или любым другим SS)

  return sLevelName_nLevel  (возвращает таблицу "название уровня"-"соответствующий уровень")
]]
function SpellSystem:BASE(hObj, n_sLevelName, hNewObj) --Обновляет и возвращает базовые уровни SS
  if not hObj then 
    hObj = self:Get()
  end
  local function LevelsMerger(...)
    local nArg_hArg = {...}
    if #nArg_hArg > 0 then
      local hRes = {}
      for nArg, hArg in pairs(nArg_hArg) do
        for k, v in pairs(hArg) do
          hRes[k] = math.max(hRes[k] or 0, v)
        end
      end
      return hRes
    end
  end
  
  hNewObj = hNewObj or hObj 
  
  --у кого смотреть BASE уровни
  --Сначала смотрим старую информацию
  local hOldBASE = self:GetBASE(hObj, n_sLevelName) 
  local hOldOUT = self:GetOUT(hObj, n_sLevelName) 
  --берём новую информацию
  local hNewBASE = self:GetBASE(hNewObj, n_sLevelName) 
  local hNewOUT = self:GetOUT(hNewObj, n_sLevelName)

  local sLevelName_nLevel = LevelsMerger(hOldBASE, hOldOUT, hNewBASE, hNewOUT)
  if not sLevelName_nLevel then return end

  --перезапись данных hObj'та
  local SS = self:Get(hObj, true)
  --db('SpellSystem:BASE, SS=', SS)
  for k, v in pairs(sLevelName_nLevel) do
    SS.sLevelName_hLevels[k] = SS.sLevelName_hLevels[k] or {}
    SS.sLevelName_hLevels[k].base = v
  end
  
  return sLevelName_nLevel, SS
end

function SpellSystem:GetADD(hObj, n_sGetLevelName) --получить дополнительные уровни способности
  return self:GethLevelsBysLevelType(hObj, n_sGetLevelName, 'add')
end

function SpellSystem:GetBASE(hObj, n_sGetLevelName) --получить базовые уровни способности
  return self:GethLevelsBysLevelType(hObj, n_sGetLevelName, 'base')
end


function SpellSystem:GetOUT(hObj, n_sReturnLevelName)  --Возвращает "внешние" уровни всех способностей юнита
  local eUnit = (hObj.GetUnitName and hObj)
    or (hObj.GetCaster and hObj:GetCaster())
    or (hObj.GetParent and hObj:GetParent())
    or (hObj.nParent and EntIndexToHScript(hObj.nParent))

  if eUnit then
    local OUT_levels = {}
    local nSpellIndex
    for nSpellIndex = 0, nSPELL_COUNT do
      local eSpell = eUnit:GetAbilityByIndex(nSpellIndex)
      if eSpell then
        local sSpell = eSpell:GetAbilityName()
        if OUT_levels[sSpell] then
          --если уже несколько похожих способностей, то нужно сравнить их уровни
          OUT_levels[sSpell] = math.max(OUT_levels[sSpell], eSpell:GetLevel())  --берём больший уровень из всех спеллов с одинаковым именем
        else
          --способность встречается впервые
          OUT_levels[sSpell] = eSpell:GetLevel()
        end
      end
    end
    if n_sReturnLevelName then
      local hResult = {}
      for _, sReturnLevelName in pairs(n_sReturnLevelName) do
        hResult[sReturnLevelName] = OUT_levels[sReturnLevelName] or nDEFAULT_OUT_LEVEL
      end
      return hResult --sLevelName_nLevel
    else
      return OUT_levels --sLevelName_nLevel
    end
  end
end


function SpellSystem:GethLevelsBysLevelType(hObj, n_sGetLevelName, sType)
  local SS = self:Get(hObj)
  if SS then
    local sLevelName_nLevel = {}  --результирующая таблица
    if n_sGetLevelName then
      --показать запрощенные уровни
      for _, sGetLevelName in pairs(n_sGetLevelName) do
        sLevelName_nLevel[sGetLevelName] = (SS.sLevelName_hLevels[sGetLevelName] 
          and SS.sLevelName_hLevels[sGetLevelName][sType])
          or 0
      end
    else
      --показать все уровни
      --sLevelName_nLevel = SS.sLevelName_hLevels[sType]

      --просто явно копируем всю информацию по sType
      for sLevelName, sLevelType_nLevel in pairs(SS.sLevelName_hLevels) do
        sLevelName_nLevel[sLevelName] = sLevelType_nLevel[sType]
      end
    end
    return sLevelName_nLevel
  end
end







--[[
local function Err(DefaultValue, sErr)  --Error
  if db then
    db('GetSS, ERROR. sErr=', sErr)
  else
    print('GetSS, ERROR. sErr=', sErr)
  end
  return DefaultValue
end
]]

function SpellSystem:GetEnt(hObj)
  if hObj then
    if hObj.nThisSS then
      local nIndex = hObj.nObj
      local nParent = hObj.nParent
      --local sName = hObj.sObj

      if nIndex then 
        if nParent then
          local eParent = EntIndexToHScript(nParent)
          local eBuff = self:GetBuff(eParent, nIndex)
          return eBuff, 'buff'
        else
          local eObj = EntIndexToHScript(nIndex)
          if eObj then
            if eObj.GetUnitName then
              return eObj, 'unit'
            end
            return eObj, 'spell'
          end
          return
        end
      end
    else
      if hObj.GetUnitName then
        return hObj, 'unit'
      elseif hObj.GetAbilityName then
        return hObj, 'spell'
      elseif hObj.GetName then
        return hObj, 'buff'
      else
        return
      end
    end
  end
end

function SpellSystem:Get(hObj, bCreate)
  local function CreateSS(hObj)
    local nObj = -1
    local sObj = ''
    local nSelfLevel = 0
    local nParent

    local SS = {}
    if hObj then
      hObj.SS = SS

      nObj = (hObj.GetEntityIndex and hObj:GetEntityIndex()) --для entity
        or hObj.nIndex  --для абстрактных объектов (используется в buff'ах)
        or nObj
      local eParent = hObj.GetParent and hObj:GetParent() or (hObj.GetAbilityName and hObj:GetCaster())
      nParent = eParent and eParent.GetEntityIndex and eParent:GetEntityIndex()
      sObj = (hObj.GetUnitName and hObj:GetUnitName()) --для eUnit
        or (hObj.GetAbilityName and hObj:GetAbilityName())  --для eSpell
        or (hObj.GetName and hObj:GetName()) --для CEntityInstance или buff'ов
        or sObj
      nSelfLevel = (hObj.GetLevel and hObj:GetLevel())  --для eUnit или eSpell
        or nSelfLevel     
    end

    self.nSSLastIndex = (self.nSSLastIndex or 0) + 1
    SS.nThisSS = self.nSSLastIndex
    SS.nObj = nObj
    SS.nParent = nParent
    SS.sObj = sObj
    SS.sLevelName_hLevels = {
      nSelfLevel = {
        base = nSelfLevel,
        add = 0
      }
    }

    return SS
  end

  if not hObj then
    return CreateSS()
  elseif hObj.nThisSS then
    return hObj
  elseif hObj.SS then
    return hObj.SS
  elseif bCreate then
    return CreateSS(hObj)
  end
end



--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--[[SpellLists]]
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

--[[
  регистрирует SpellList

  требует:
    hList = (обязательно) [таблица, юнит, spell или buff] с заготовленными функциями:
      SpellListVision(hList, bVision) - вызывается при смене видимости текущего SpellList'а
    eUnit = (обязательно) [юнит], к кому будет приклеплён SpellList
    nPriority = (необязательно) [число] приоритет SpellList'а в дапазоне [0; +∞)
    nsIndex = (необязательно) [число или строка] являющаяся индексом для данного SpellList
  возвращает:
    nsIndex = [число или строка] индекс зарегестрированного (и обновлённого) SpellList'а

  используемые поля:
    eUnit.SpellList = список всех SpellList'ов этого юнита
    eUnit.nsSpellListCurrentIndex = [число или строка] индекс текущего используемого SpellList'а
    hList.nSpellListPriority = [число] приоритет hList'а
]]
function SpellSystem:RegisterSpellListToUnit(hList, eUnit, nPriority, nsIndex)
  if not nsIndex then --самостоятельное индексирование списка
      if hList.GetUnitName then
      --unit
      nsIndex = hList:GetEntityIndex()
    elseif hList.GetAbilityName then
      --spell
      nsIndex = hList:GetAbilityIndex()
    elseif hList.nIndex then
      --buff or another
      local prefix = (hList.GetName and ('buff_' + hList.GetName() + '_')) or 0
      nsIndex = prefix + hList.nIndex
    else
      db('SpellSystem:RegisterSpellListToUnit(): |nsIndex == nil| => return nil')
      return
    end
  end

  --задание приоритета hList'у
  hList.nSpellListPriority = nPriority or 1 
  --инициализация SpellList'а юнита
	eUnit.SpellList = eUnit.SpellList or {} 
  eUnit.SpellList[nsIndex] = hList  --запись hList к SpellList'у юнита

  self:SpellListUpdate(eUnit)
  return nsIndex
end

function SpellSystem:UnRegisterSpellListToUnit(eUnit, nsIndex)
  if eUnit.SpellList and eUnit.SpellList[nsIndex] ~= nil then
    self:SpellListChangePriority(eUnit, nsIndex, -1)
    eUnit.SpellList[nsIndex] = nil
    --self:SpellListUpdate(eUnit)
    return true
  end
  return false
end

--изменяет приоритет hList'а и обновляет SpellList у eUnit
--без проверок на ошибки
function SpellSystem:SpellListChangePriority(eUnit, nsIndex, nPriority)
  eUnit.SpellList[nsIndex].nSpellListPriority = nPriority
  return self:SpellListUpdate(eUnit)  --возвратит индекс нового используемого hList'а
end

function SpellSystem:SpellListUpdate(eUnit)
  if eUnit.SpellList then
    local nsIndexWithHighPriority --индекс системы с макс. приоритетом
    local nMaxPriority = -1  --(int) не рабочий приоритет, работает всё что больше или равно 0 
    --[[  образная классификация приоритетов:
      0 = базовый приоритет (уровень базового интерфейса)
      1 = стандартный приоритет (уровень обычных спеллов)
      2..+∞ = особый приоритет (выше уровня обычных спеллв)
    ]]

    --находим индекс с максимальным приоритетом
    for nsIndex, hList in pairs(eUnit.SpellList) do
      if hList.nSpellListPriority > nMaxPriority then
        nsIndexWithHighPriority = nsIndex
        nMaxPriority = hList.nSpellListPriority
      end
    end

    if eUnit.nsSpellListCurrentIndex ~= nsIndexWithHighPriority then  --если состояние изменено
      if eUnit.nsSpellListCurrentIndex ~= nil then  --если была предыдущая система, то
        --сообщаем предыдущей системе, что она должна скрыться
        eUnit.SpellList[eUnit.nsSpellListCurrentIndex]:SpellListVision(false)
      end
      eUnit.nsSpellListCurrentIndex = nsIndexWithHighPriority --записываем новое состояние
      if eUnit.nsSpellListCurrentIndex ~= nil then  --если текущая система не обнулена
        --показываем её
        eUnit.SpellList[eUnit.nsSpellListCurrentIndex]:SpellListVision(true)
      end
    end

    return eUnit.nsSpellListCurrentIndex
  end
end