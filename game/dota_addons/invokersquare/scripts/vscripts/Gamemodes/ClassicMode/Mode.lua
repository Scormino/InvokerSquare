require('BarebonesLib/timers')
require('BarebonesLib/animations')

require('AddonScripts/ModifierSync')
require('Gamemodes/ClassicMode/Constants')

require('Gamemodes/ClassicMode/QWERSystem')


if Classic == nil then
  _G.Classic = class({})
end

function Classic:Init()
  self:ApplyConstants() --Применить константы данного мода




  --[[
  --регистрируем уничтожение entity
  LinkEvent('entity_killed')
  --Вписываем условия победы/поражения
  EventModul.entity_killed:AddFunc(
    function(keys)
      local nAttacker = keys.entindex_attacker
      local nKilled = keys.entindex_killed
      --local damagebits = keys.damagebits
      
      local eKilled = EntIndexToHScript(nKilled)
      if eKilled == hMode.SUPER_CREEP then
        local eAttacker = EntIndexToHScript(nAttacker)
        GameRules:SetGameWinner(eAttacker:GetTeam())
      end
    end
  )
  ]]

  
  LinkEvent('entity_killed')
  --[[
  Classic.ModeInit()                        
  Classic.ApplySetupInfo()                  
  Classic.ExpSystemInit()                   
  Classic.RegisterModifierEvent_LevelUp()   
  ]]
  
  EventModul.STATE_PRE_GAME:AddFunc(self.ModeInit)                       --объявление некоторых необходимых переменных для мода       
  EventModul.STATE_PRE_GAME:AddFunc(self.ApplySetupInfo)                 --Инициализируем введённую информацию с GameSetup в _G.hMapConstants        
  EventModul.STATE_PRE_GAME:AddFunc(self.ExpSystemInit)                  --инициализируем систему опыта 
  EventModul.STATE_PRE_GAME:AddFunc(self.RegisterModifierEvent_LevelUp)  --Регистрация LevelUp героев для их модификаторов
  EventModul.STATE_PRE_GAME:AddFunc(self.LuaModifiersInit)               --Инициализируем модификаторы
  EventModul.STATE_PRE_GAME:AddFunc(self.SpellSystemInit)
  
  EventModul.STATE_PRE_GAME:AddFunc(self.SpawnTowers)                  --Спавним тавера
  
  
  LinkEvent('npc_spawned', self.NpcSpawnFilter)                        --регистрируем спавн любой сущности
  
  LinkEvent('dota_player_pick_hero')                                      --Регистрируем событие при пике героя
  EventModul.dota_player_pick_hero:AddFunc(self.SetSpawnPoints)        --Перемещаем героя и присваиваем точку спавна
  EventModul.dota_player_pick_hero:AddFunc(self.FirstInvokerAnimApply) --создаём начальную анимацию
  EventModul.dota_player_pick_hero:AddFunc(self.BaseModifiersApply)    --применяем начальные статы основываясь на текущем Gamemode
  EventModul.dota_player_pick_hero:AddFunc(self.InvokerSpellsInit)     --инициализируем способности
  
  EventModul.dota_player_pick_hero:AddFunc(self.ItemInit)              --инициализируем предметы
  
  
  EventModul.dota_player_pick_hero:AddFunc(self.FirstRootApply)        --Стопим героя начальным root'ом

  EventModul.STATE_GAME_IN_PROGRESS:AddFunc(self.FirstRootRemoveAll)   --Снимаем root'ы
  EventModul.STATE_GAME_IN_PROGRESS:AddFunc(self.AllowReconstructionSpells)  --позволяет использовать сотворённые Invoker'ом способности


  --[[
  EventModul.STATE_GAME_IN_PROGRESS:AddFunc(
    function()
      if GetMapName() == 'space' then
        local hMainPlaces = Entities:FindAllByName('MainPlace')
        local dt = 0.1
        for _, MainPlace in pairs(hMainPlaces) do
          local vBasePos = MainPlace:GetAbsOrigin()
          local nAmplitude = 20.0
          local nFrequency = 1
          hMode[MainPlace] = {}
          hMode[MainPlace].nTime = 0.0
          db('hMode[MainPlace]:', hMode[MainPlace])
          Timers:CreateTimer(
            function()
              --local vPos = MainPlace:GetAbsOrigin()
              local vNewPos = vBasePos + nAmplitude * Vector(0,0, math.sin(nFrequency * hMode[MainPlace].nTime))
              MainPlace:SetAbsOrigin(vNewPos)
          
              print('hMode[MainPlace].nTime = ', hMode[MainPlace].nTime)
              print('vNewPos=', vNewPos)
              hMode[MainPlace].nTime = hMode[MainPlace].nTime + dt
              return dt
            end
          )
          
        end
      end
    end
  )
  ]]

  
  

  --[[
  local sPlaneName = 'custom_plane'
  local hPlanes = Entities:FindAllByName(sPlaneName)
  db(hPlanes)
  local CurrentPlane = hPlanes[1]

  Timers:CreateTimer(10.0,
    function()
      local vOldPos = CurrentPlane:GetAbsOrigin()
      CurrentPlane.SetAbsOrigin(vOldPos + Vector(-0.1, 0, 0))

      return 0.1
    end
  )
  ]]
  

  






  require('Gamemodes/Setup')



  

  return self
end
ADDON.GM = Classic --Выбор текущего инициализируемого мода





function Classic.ModeInit()
  hMode.nTeam_hPlayers = {} --сопостовляем игроков с командами
  for nPlayer = 0, PlayerResource:GetPlayerCount()-1 do
    local nTeam = PlayerResource:GetTeam(nPlayer)

    if not hMode.nTeam_hPlayers[nTeam] then
      hMode.nTeam_hPlayers[nTeam] = {}
    end
    table.insert(hMode.nTeam_hPlayers[nTeam], nPlayer)
  end
end

function Classic.ApplySetupInfo() --Синхронизация введённых в GameSetup данных
  SETUP__hMapConstants = CustomNetTables:GetTableValue("addon", "hMapConstants")

  --Синхронизируем слоты игроков
  for sTower, hTower in pairs(SETUP__hMapConstants.nTower_hTower) do
    _G.hMapConstants.nTower_hTower[tonumber(sTower)].nPlayer = hTower.nPlayer
  end
  --расставляем не рассаженных игроков в слоты
  --обходим всех сущ. игроков
  for nPlayer = 0, PlayerResource:GetPlayerCount()-1 do
    local nRandomIndex_nFreeTower = {}
    local nRandomCount = 0
    local bSetPlayerInSlot = true      --Нужно ли сожать игрока в слот
    for nTower, hTower in pairs(hMapConstants.nTower_hTower) do
      if nPlayer == hTower.nPlayer then --Если текущий игрок уже сидит в слоте
        bSetPlayerInSlot = false  --то его сожать не нужно
        break --выходим из внутреннего цикла
      end
      if hTower.nPlayer == -1 and hTower.nTowerType == 1 then    --Если слот свободный
        nRandomCount = nRandomCount + 1
        nRandomIndex_nFreeTower[nRandomCount] = nTower  --то добавляем в список свободных для текущего игрока
      end
    end
    
    if bSetPlayerInSlot then  --Если нужно посадить игрока
      local nRandomIndex = RandomInt(1, nRandomCount) --генерируем рандомное число на основе текущего списка свободных Tower'ов
      hMapConstants.nTower_hTower[nRandomIndex_nFreeTower[nRandomIndex]].nPlayer = nPlayer
    end
  end
end







function Classic.LuaModifiersInit()
  LinkLuaModifier( "speedlim", "AddonScripts/modifiers/speedlim.lua", LUA_MODIFIER_MOTION_NONE )
  LinkLuaModifier( "HeroBase", "AddonScripts/modifiers/HeroBase.lua", LUA_MODIFIER_MOTION_NONE )
  LinkLuaModifier( "attack_fix", "AddonScripts/modifiers/attack_fix.lua", LUA_MODIFIER_MOTION_NONE )
  LinkLuaModifier( "base_tower_shield_modifier", "AddonScripts/modifiers/base_tower_shield_modifier.lua", LUA_MODIFIER_MOTION_NONE )
  LinkLuaModifier( "FirstStopMoves", "AddonScripts/modifiers/FirstStopMoves.lua", LUA_MODIFIER_MOTION_NONE )
  LinkLuaModifier( "dummy", "AddonScripts/modifiers/dummy", LUA_MODIFIER_MOTION_NONE)
end






function Classic.SpellSystemInit()
  require('Gamemodes/ClassicMode/QWERSystem')  
  local sGainLevel = 'dota_player_gained_level'
  LinkEvent(sGainLevel)
  EventModul[sGainLevel]:AddFunc(
    function(keys)
      SpellSystem[sGainLevel](SpellSystem, keys)
      --local eHero = PlayerResource:GetPlayer(keys.player-1):GetAssignedHero()
      --RefreshAllQWER(eHero)
    end
  )
  local sLearnAbil = 'dota_player_learned_ability'
  LinkEvent(sLearnAbil)
  EventModul[sLearnAbil]:AddFunc(
    function(keys)
      SpellSystem[sLearnAbil](SpellSystem, keys)
      --db('dota_player_learned_ability, keys=', keys)
      --local eHero = PlayerResource:GetPlayer(keys.player-1):GetAssignedHero()
      --RefreshAllQWER(eHero)
    end
  )
end

function Classic.SpawnTowers()
  if hMapConstants and hMapConstants.nTower_hTower then  --Если есть константы карты
    local nTower_hTower = hMapConstants.nTower_hTower

    for nTower, hTower in pairs(nTower_hTower) do
      local nPlayer = hTower.nPlayer
      local nTeam = DOTA_TEAM_NEUTRALS
      if nPlayer ~= -1 then 
        nTeam = PlayerResource:GetTeam(nPlayer)
      end
      local vLoc = hTower.vPos
      --local nTowerType = hTower.nTowerType
      
      local eTower = Classic.NewUnit('npc_tower_1', vLoc, nTeam)
      if eTower then
        SpellSystem:BuffIndexApply(eTower:FindAllModifiers()[1]) --Тавер имеет неуязвимость изначально, проиндексируем его для сервера
        eTower:SetInvulnCount(0)  --Убираем неуязвимость
        SpellSystem:ApplyBuff({eCaster = eTower, sBuff = "base_tower_shield_modifier"}) --добавляем модификатор получаемого физического урона
        eTower:AddAbility('tower_knowledge_concentrator'):SetLevel(1)

        hMode.nPlayer_eSpawnTower = hMode.nPlayer_eSpawnTower or {}
        hMode.nPlayer_eSpawnTower[nPlayer] = eTower --записываем тавер как выбранный для спавна

        --[[
        if not hMode.nTeam_hTowers then
          hMode.nTeam_hTowers = {}
        end
        if not hMode.nTeam_hTowers[nTeam] then
          hMode.nTeam_hTowers[nTeam] = {}
        end
        hMode.nTeam_hTowers[nTeam][#hMode.nTeam_hTowers[nTeam]+1] = {
          eTower = eTower,
          nTowerType = nTowerType,
        }
        ]]
      end
    end
  end
end


function Classic.ExpSystemInit()  
  --[[
  Опыт суммируется каждые dt времени
  кол-во вышек динамично
  кол-во героев динамично

  у каждого героя свой фактор опыта 
    может брать опыт в размере от 0% до 100%
    если герой мёртв, то фактор получения опыта = 0%

    герой может получать больше опыта, чем ему предоставляется, будучи у всех по 100%
  (т.к. у каждого игрока может быть только 1 герой, то игрок = герой)
  прощёлкиваем каждую команду
    смотрим кол-во опыта за текущий фрейм (для этой команды)
    а потом просто присваиваем каждому герою опыт по формуле

    EXP(i) = EXP_POWER * factor(i) / SUMfactor
      где EXP(i) = опыт, полученный i-ым игроком
      где EXP_POWER = суммарный опыт за фрейм, распределённый на всех игроков (изначально высчитывается именно он)
      где factor(i) = фактор полученного опыта текущего игрока
      где SUMfactor = сумма факторов всех героев
  ]]
  
  hMode.ExpSystem = {}
  hMode.ExpSystem.nPlayer_hExp = {} --создаём хранилище опыта для каждого игрока (чтобы хранить опыт в float типе, а потом отдавать его, когда он равен или больше 1)
  for nPlayer = 0, PlayerResource:GetPlayerCount()-1 do
    hMode.ExpSystem.nPlayer_hExp[nPlayer] = {
      nGainFactor = 1.0,  --фактор получения опыта
      nExpBank =    0.0,  --локальное хранилище опыта
    }
  end
  hMode.ExpSystem.nAbilIndex_eExpAbil = hMode.ExpSystem.nAbilIndex_eExpAbil or {}
  hMode.ExpSystem.nPlayer_nExpIncreasePerDt = {} --Таблица для Apply timer'а (это позволит уменьшить рассчёты за каждый dt)

  hMode.ExpSystem.Refresh = function() --обновляет выдаваемый за dt времени опыт на каждого игрока
    local nTeam_hExpAbil = {} --Подготавливаем рабочую таблицу КОМАНДА-СПОСОБНОСТИ ОПЫТА
    for nAbilIndex, eExpAbil in pairs(hMode.ExpSystem.nAbilIndex_eExpAbil) do
      local nTeam = eExpAbil:GetTeam()
      if not nTeam_hExpAbil[nTeam] then
        nTeam_hExpAbil[nTeam] = {}
      end
      table.insert(nTeam_hExpAbil[nTeam], eExpAbil)
    end

    local CLIENT__nPlayer_hExpInfo = {}   --приготавливаем таблицу для синхронизации
    local nPlayer_nExpIncreasePerDt = {}  --приготавливаем результирующую таблицу
    for nTeam, hExpAbil in pairs(nTeam_hExpAbil) do
      if nTeam == DOTA_TEAM_NEUTRALS then
        break
      end
      --[[    EXP_POWER    ]]
      local nExpPowerPerSec = 0.0 --опыт получаемый за 1цу времени для текущей команды
      for _, eExpAbil in pairs(hExpAbil) do
        nExpPowerPerSec = nExpPowerPerSec + hMode.Const.tower_knowledge_concentrator.nGainExp[eExpAbil:GetLevel()]
      end

      --[[  factor(i),  SUMfactor  ]]
      local nPlayer_nGainFactor = {}
      local nSumExpFactor = 0.0 --сумма всех факторов получения опыта каждого игрока
      --высчитываем сумму факторов
      for _, nPlayer in pairs(hMode.nTeam_hPlayers[nTeam]) do
        nPlayer_nGainFactor[nPlayer] = hMode.ExpSystem.nPlayer_hExp[nPlayer].nGainFactor
        if (not PlayerResource:GetPlayer(nPlayer):GetAssignedHero())--если героя не существует
          or (not PlayerResource:GetPlayer(nPlayer):GetAssignedHero():IsAlive()) --или он мёртв
        then 
          nPlayer_nGainFactor[nPlayer] = 0.0 --то фактор этого игрока = 0
        end
        nSumExpFactor = nSumExpFactor + nPlayer_nGainFactor[nPlayer]
      end

      --[[  EXP(i)  ]] --Присваиваем обновлённые значения
      if nSumExpFactor == 0 then
        for _, nPlayer in pairs(hMode.nTeam_hPlayers[nTeam]) do
          CLIENT__nPlayer_hExpInfo[nPlayer] = {
            nGainFactor = hMode.ExpSystem.nPlayer_hExp[nPlayer].nGainFactor,
            nExpPerSec = 0,
          }
        end
      else
        for _, nPlayer in pairs(hMode.nTeam_hPlayers[nTeam]) do
          local nExpPerSec = nExpPowerPerSec * nPlayer_nGainFactor[nPlayer] / nSumExpFactor     --полный опыт на 1 игрока за 1цу времени
          CLIENT__nPlayer_hExpInfo[nPlayer] = {
            nGainFactor = hMode.ExpSystem.nPlayer_hExp[nPlayer].nGainFactor,
            nExpPerSec = nExpPerSec,
          }
          local nExpResult = nExpPerSec * hMode.Const.tower_knowledge_concentrator.dt --полный опыт на 1 игрока за dt времени
          if nExpResult > 0.0 and GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            nPlayer_nExpIncreasePerDt[nPlayer] = nExpResult
          end
        end
      end
    end
    hMode.ExpSystem.nPlayer_nExpIncreasePerDt = nPlayer_nExpIncreasePerDt

    --синронизируем данные с клиентами
    CLIENT__nPlayer_hExpInfo = Table2StringTable(CLIENT__nPlayer_hExpInfo)
    CustomNetTables:SetTableValue("Mode", "ExpSystem", CLIENT__nPlayer_hExpInfo)
  end

  hMode.ExpSystem.Apply = function()
    for nPlayer, nExpIncreasePerDt in pairs(hMode.ExpSystem.nPlayer_nExpIncreasePerDt) do
      --прибавляем значение в банк текущего игрока
      hMode.ExpSystem.nPlayer_hExp[nPlayer].nExpBank = hMode.ExpSystem.nPlayer_hExp[nPlayer].nExpBank + nExpIncreasePerDt
      local nIntExp = math.floor(hMode.ExpSystem.nPlayer_hExp[nPlayer].nExpBank) --целая часть опыта из банка
      if nIntExp > 0 then
        hMode.ExpSystem.nPlayer_hExp[nPlayer].nExpBank = hMode.ExpSystem.nPlayer_hExp[nPlayer].nExpBank - nIntExp --вычитаем из банка эту целую часть
        PlayerResource:GetPlayer(nPlayer):GetAssignedHero():AddExperience(nIntExp, 0, false, true)  --присваиваем дискретный опыт
      end
    end

    return hMode.Const.tower_knowledge_concentrator.dt
  end




  hMode.ExpSystem.Free = function()
    Timers:RemoveTimer(hMode.ExpSystem.sTimer)
    table.remove(hMode, 'ExpSystem')
    --hMode.ExpSystem = nil
  end

  
  function GameMode:ExpSystemUpdate(data)
    --local nPlayerID = data.PlayerID
    local nPlayer = data.nPlayer
    local nNewExpFactor = data.nNewExpFactor

    hMode.ExpSystem.nPlayer_hExp[nPlayer].nGainFactor = nNewExpFactor
    hMode.ExpSystem.Refresh()
  end
  CustomGameEventManager:RegisterListener("ExpSystemUpdate", Dynamic_Wrap(GameMode, 'ExpSystemUpdate'))
  
  LinkEvent('dota_player_pick_hero')
  EventModul.dota_player_pick_hero:AddFunc(
    function()
      Timers:CreateTimer(0, hMode.ExpSystem.Refresh)
    end
  )
  EventModul.STATE_GAME_IN_PROGRESS:AddFunc(hMode.ExpSystem.Refresh)
  EventModul.entity_killed:AddFunc(
    function(keys)
      local eKilled = EntIndexToHScript(keys.entindex_killed)
      if eKilled:IsHero() then
        hMode.ExpSystem.Refresh()
      end
    end
  )



  hMode.ExpSystem.Refresh()
  db('FIRST EXP_SYSTEM Refresh()')
  hMode.ExpSystem.sTimer = Timers:CreateTimer(hMode.ExpSystem.Apply)
end


function Classic.RegisterModifierEvent_LevelUp()
  LinkEvent('dota_player_gained_level')
  EventModul.dota_player_gained_level:AddFunc(
    function(keys)
      local eHero = PlayerResource:GetPlayer(keys.player-1):GetAssignedHero()
      
      local hModifiers = eHero:FindAllModifiers()
      for k, hModifier in pairs(hModifiers) do
        if hModifier.OnHeroLevelUp then
          hModifier:OnHeroLevelUp()
        end
      end
    end
  )
end


















--Все созданные NPC проходят через эту функу
function Classic.NpcSpawnFilter(keys)
  local eUnit = EntIndexToHScript(keys.entindex) 
  --Разрешаем друж. целям атаковать этот entity
  SpellSystem:ApplyBuff({eCaster = eUnit, sBuff = 'attack_fix'})  
  return keys  --т.к. это фильтр, то нужно сообщить другим входную информацию
end




function Classic.SetSpawnPoints(keys)
  local eHero = EntIndexToHScript(keys.heroindex)
  local nPlayer = eHero:GetPlayerID()
  local eSpawnTower = hMode.nPlayer_eSpawnTower[nPlayer]
  local vPos = eSpawnTower:GetAbsOrigin()

  eHero:SetRespawnPosition(vPos)  --Устанавливаем новую точку респавна
  Timers:CreateTimer(0,
    function()
      eHero:SetAbsOrigin(vPos + RandomVector(175.0))        --Устанавливаем текущую позицию появившегося героя
    end
  )
end

function Classic.FirstInvokerAnimApply(keys)
  Classic.RespawnedActions(EntIndexToHScript(keys.heroindex), 0.3)
end

function Classic.BaseModifiersApply(keys)
  local eHero = EntIndexToHScript(keys.heroindex)
  --eHero:AddNewModifier(nil, nil, "speedlim", nil)
	--eHero:AddNewModifier(nil, nil, "HeroBase", nil)

  SpellSystem:ApplyBuff({eCaster = eHero, sBuff = 'speedlim'})
  SpellSystem:ApplyBuff({eCaster = eHero, sBuff = 'HeroBase'})
end

function Classic.InvokerSpellsInit(keys)
  local eHero = EntIndexToHScript(keys.heroindex)
  SpellSystem:InsertSpell({
      sSpell = 'invoker_quantum',
      eUnit = eHero,
      nSlot = 6
    }
  )
  SpellSystem:InsertSpell({
      sSpell = 'invoker_warp',
      eUnit = eHero,
      nSlot = 7
    }
  )
  SpellSystem:InsertSpell({
      sSpell = 'invoker_expanse',
      eUnit = eHero,
      nSlot = 8
    }
  )
  hMode.bAllowReconstructionSpells = hMode.bAllowReconstructionSpells or false
  SpellSystem:InsertSpell({
      sSpell = 'invoker_reconstruction',
      eUnit = eHero,
      nSlot = 9,  --т.к. invoker_reconstruction:SpellListVision(true) будет вызван при 1 инициализации и поменяет местами с 5 слотом
      nLevel = 1,
    }
  )

  --Возможно избыточная инструкция. Просто для уверенности
  QWERSystem:ABSAsync(eHero, eHero) --создаём SS для героя
end

function Classic.ItemInit(keys)
  local eHero = EntIndexToHScript(keys.heroindex)
  local i
  for i = 0, 8 do --Удаляем все предметы
    local item = eHero:GetItemInSlot(i)
    eHero:RemoveItem(item) 
  end
  
  --удаляем предмет (Portal Scroll) в доп. слоте
  local item_add = eHero:GetItemInSlot(15)
  eHero:RemoveItem(item_add) 
end

function Classic.FirstRootApply(keys)
  SpellSystem:ApplyBuff({eCaster = EntIndexToHScript(keys.heroindex), sBuff = 'FirstStopMoves'})
end

function Classic.FirstRootRemoveAll()
  local i
  for i=0, 19 do
    local player = PlayerResource:GetPlayer(i)
    if player ~= nil then
      local hero = player:GetAssignedHero()
      if hero ~= nil then
        hero:RemoveModifierByName("FirstStopMoves")
      end
    end
  end
end

function Classic.AllowReconstructionSpells()
  require('Gamemodes/ClassicMode/QWERSystem')

  hMode.bAllowReconstructionSpells = true
  for nPlayer = 0, PlayerResource:GetPlayerCount()-1 do
    local eHero = PlayerResource:GetPlayer(nPlayer):GetAssignedHero()
    if eHero then
      local eReconstructionSpell = eHero:FindAbilityByName(sR)
      if eReconstructionSpell then
        eReconstructionSpell:RefreshActivatedSpells()
      end
    end
  end
end






























































































--обрабатывание нажатия на иконку способности в SpellBook'е
function GameMode:onButtonSpellClick(data)
  local applyFormulaWithUnit = function(caster, formula)
    require('AddonScripts/spells/R/invoker_reconstruction')
    if formula ~= nil then
      local SpellWork = true

      local nSphere_sSphereName = {sQ, sW, sE}
      local hQWER = QWERSystem:ABS(caster) --GetSSOutQWERLevel(caster)
      local i
      for i = 1, 3 do
        if formula[i] ~= 0 then
          if hQWER[nSphere_sSphereName[ formula[i] ] ] <= 0 then
            SpellWork = false
            break
          end
        else
          break
        end
      end

      if SpellWork then
        require('AddonScripts/spells/spheres/spheres')
        RemoveAllSpheres(caster)

        local SphereSpell = {}
        SphereSpell[1] = caster:FindAbilityByName(sQ)
        SphereSpell[2] = caster:FindAbilityByName(sW)
        SphereSpell[3] = caster:FindAbilityByName(sE)
        for i=1, 3 do
          if formula[i] ~= 0 then
            caster:CastAbilityImmediately(SphereSpell[formula[i] ], data.playerID)
          else
            break
          end
        end

        local eSpellReconstruction = caster:FindAbilityByName(sR)
        if eSpellReconstruction:GetCooldownTime() <= 0 and not eSpellReconstruction:IsHidden() then
          caster:CastAbilityImmediately(caster:FindAbilityByName(sR), data.playerID)
          --CustomGameEventManager:Send_ServerToAllClients("CloseSpellBook", nil)
          CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "CloseSpellBook", nil)
        end
      end
    end
  end

  db("onButtonSpellClick: "..data.abilname)
  local ResultFormula = hMode.Const.sAbilName_hFormula[data.abilname]
  if ResultFormula then
    local caster = PlayerResource:GetPlayer(data.playerID):GetAssignedHero()
    applyFormulaWithUnit(caster, ResultFormula)
  end
end
CustomGameEventManager:RegisterListener("event_onButtonSpellClick", Dynamic_Wrap(GameMode, 'onButtonSpellClick'))



function Classic.RespawnedActions(eHero, nAnimationRate)
  Timers:CreateTimer(0.05, 
    function()
      StartAnimation(
        eHero, 
        {
          duration=5.0, 
          activity=ACT_DOTA_SPAWN, 
          translate="divine_sorrow_loadout_spawn", 
          translate2="loadout", 
          rate=nAnimationRate
        }
      )
    end
  )
end

function Classic.NewUnit(sUnitName, vLoc, nTeam, eOwner)  --Это может понадобится для модификации созданных юнитов в будущем
  return CreateUnitByName(sUnitName, vLoc, false, eOwner, eOwner, nTeam)
  --CreateUnitByName(sUnitName, vLoc, bFindClearSpace, hNPCOwner, hUnitOwner, nTeam )
end