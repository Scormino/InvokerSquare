function InitEvents()
  function LinkEvent(sEvent, NewFunc)
    if not EventModul[sEvent] then
      EventModul[sEvent] = CreateModul()

      local LinkFunc
      if NewFunc ~= nil then
        LinkFunc = function(...)
          EventModul[sEvent]:apply(NewFunc(...))
        end
      else
        LinkFunc = function(...)
          EventModul[sEvent]:apply(...)
        end
      end
      EventModul[sEvent].id = ListenToGameEvent(sEvent, LinkFunc, nil)
      return true
    end
    return false
  end
  
  _G.EventModul = class({})

  EventModul.STATE_SETUP = CreateModul()
  EventModul.STATE_HERO_SELECTION = CreateModul()
  EventModul.STATE_STRATEGY_TIME = CreateModul()
  EventModul.STATE_TEAM_SHOWCASE = CreateModul()
  EventModul.STATE_WAIT_FOR_MAP_TO_LOAD = CreateModul()
  EventModul.STATE_PRE_GAME = CreateModul()             --Как только все игроки вошли в выбранный мод
  EventModul.STATE_GAME_IN_PROGRESS = CreateModul()
  EventModul.STATE_POST_GAME = CreateModul()
  EventModul.STATE_DISCONNECT = CreateModul()
  local hState = {
    [DOTA_GAMERULES_STATE_INIT] = "DOTA_GAMERULES_STATE_INIT",
    [DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD] = "DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD",
    [DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP] = "DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP",
    [DOTA_GAMERULES_STATE_HERO_SELECTION] = "DOTA_GAMERULES_STATE_HERO_SELECTION",
    [DOTA_GAMERULES_STATE_STRATEGY_TIME] = "DOTA_GAMERULES_STATE_STRATEGY_TIME",
    [DOTA_GAMERULES_STATE_TEAM_SHOWCASE] = "DOTA_GAMERULES_STATE_TEAM_SHOWCASE",
    [DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD] = 'DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD',
    [DOTA_GAMERULES_STATE_PRE_GAME] = "DOTA_GAMERULES_STATE_PRE_GAME",
    [DOTA_GAMERULES_STATE_GAME_IN_PROGRESS] = "DOTA_GAMERULES_STATE_GAME_IN_PROGRESS",
    [DOTA_GAMERULES_STATE_POST_GAME] = "DOTA_GAMERULES_STATE_POST_GAME",
    [DOTA_GAMERULES_STATE_DISCONNECT] = "DOTA_GAMERULES_STATE_DISCONNECT"
  }
  --Перед инициализацией чистим все листы GameEvents
  StopListeningToAllGameEvents(nil)

  LinkEvent('game_rules_state_change',
    function()
      local state = GameRules:State_Get()
      local sState = hState[state] or state

      if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        EventModul.STATE_SETUP:apply()
      elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
        EventModul.STATE_HERO_SELECTION:apply()
      elseif state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        EventModul.STATE_STRATEGY_TIME:apply()
      elseif state == DOTA_GAMERULES_STATE_TEAM_SHOWCASE then
        EventModul.STATE_TEAM_SHOWCASE:apply()
      elseif state == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
        EventModul.STATE_WAIT_FOR_MAP_TO_LOAD:apply()
      elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
        EventModul.STATE_PRE_GAME:apply()
      elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        EventModul.STATE_GAME_IN_PROGRESS:apply()
      elseif state == DOTA_GAMERULES_STATE_POST_GAME then
        EventModul.STATE_POST_GAME:apply()
      elseif state == DOTA_GAMERULES_STATE_DISCONNECT then
        EventModul.STATE_DISCONNECT:apply()
      end



      --CustomNetTables:SetTableValue("addon", "DOTA_STATE" , {DOTA_STATE = sState})

      db('game_rules_state_change = '..sState)
      return sState
    end 
  )


  EventModul.InitGameMode = CreateModul()
  EventModul.InitGameMode:AddFunc(
    function(keys)
      eGameMode:ClearExecuteOrderFilter()
      function GameMode:OrderFilter(ev)
        if ev.order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO then
          local eAbil = EntIndexToHScript(ev.entindex_ability)
          if eAbil.OnAutoCast then
            return eAbil:OnAutoCast()
          end
          
        --[[elseif ev.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then --Для QWERSystem
          local nSpell = ev.entindex_ability
          local eSpell = EntIndexToHScript(nSpell)
          
          if eSpell.QWER then
            return OnPhaseStartQWERSpell(eSpell)
            --return true
          end]]
        elseif ev.order_type == DOTA_UNIT_ORDER_GLYPH or ev.order_type == DOTA_UNIT_ORDER_RADAR then
          return false
        end
        return true
      end
      eGameMode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, 'OrderFilter'), GameMode)


      eGameMode:ClearDamageFilter()
      function GameMode:DamageFilter(ev)
        return true
      end
      eGameMode:SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), GameMode)  
    end
  )

  EventModul.InitGameMode:AddFunc(
    function(ev)
      GameMode:ApplyGameRulesSettings1()
    end
  )

  LinkEvent('player_connect_full',
    function(ev)
      GameMode:ApplyGameRulesSettings2()
    end
  )
end





--[[
function GameMode:On_game_rules_state_change(data)
  print(GetFileName().."game_rules_state_change(data)")

  for k, v in pairs(data) do
    print(k,v)
  end
  --PrintTable(data)
end
]]
InitEvents()