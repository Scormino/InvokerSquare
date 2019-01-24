db(sLOAD)
require('BaseLib/settings')

function GameMode:InitGameMode()
	_G.eGameMode = GameRules:GetGameModeEntity()
  db("InitGameMode()")
  
  EventModul.InitGameMode:apply(self)
end

function GameMode:ApplyGameRulesSettings1()
  -- Setup rules

  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

  GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
  GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )

  GameRules:SetCustomGameEndDelay( GAME_END_DELAY )
  GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
  GameRules:SetStartingGold( STARTING_GOLD )

  if SKIP_TEAM_SETUP then
    GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
    GameRules:LockCustomGameSetupTeamAssignment( true )
    GameRules:EnableCustomGameSetupAutoLaunch( true )
  else
    GameRules:SetCustomGameSetupAutoLaunchDelay( AUTO_LAUNCH_DELAY )
    GameRules:LockCustomGameSetupTeamAssignment( LOCK_TEAM_SETUP )
    GameRules:EnableCustomGameSetupAutoLaunch( ENABLE_AUTO_LAUNCH )
  end


  -- This is multiteam configuration stuff
  if USE_AUTOMATIC_PLAYERS_PER_TEAM then
    local num = math.floor(20 / MAX_NUMBER_OF_TEAMS)
    local count = 0
    for team,number in pairs(TEAM_COLORS) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, num)
      end
      count = count + 1
    end
  else
    local count = 0
    for team,number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, number)
      end
      count = count + 1
    end
  end

  

  if USE_CUSTOM_TEAM_COLORS then
    for team,color in pairs(TEAM_COLORS) do
      SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
    end
  end
end

function GameMode:ApplyGameRulesSettings2()
  mode = GameRules:GetGameModeEntity()  
  -- Set GameMode parameters    
  mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
  mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
  mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
  mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
  mode:SetBuybackEnabled( BUYBACK_ENABLED )
  mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
  mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
  mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
  mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
  mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

  mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
  mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

  mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
  mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
  mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

  mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
  mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
  if FORCE_PICKED_HERO ~= nil then
    mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
  end
  mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
  mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
  mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
  mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
  mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
  mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
  mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
  mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )

  for rune, spawn in pairs(ENABLED_RUNES) do
    mode:SetRuneEnabled(rune, spawn)
  end

  mode:SetUnseenFogOfWarEnabled( USE_UNSEEN_FOG_OF_WAR )

  mode:SetDaynightCycleDisabled( DISABLE_DAY_NIGHT_CYCLE )
  mode:SetKillingSpreeAnnouncerDisabled( DISABLE_KILLING_SPREE_ANNOUNCER )
  mode:SetStickyItemDisabled( DISABLE_STICKY_ITEM )

  --self:OnFirstPlayerLoaded()
end

function GameMode:onSync(data)
  --local nPlayerID = data.PlayerID
  local sNT = data.NT
  local sKEY = data.KEY
  local DATA = data.DATA

  --[[local Table = CustomNetTables:GetTableValue(sNT, sKEY)
  for k, v in pairs(DATA) do
    Table[k] = v
  end]]
  --db('DATA=', DATA)
  CustomNetTables:SetTableValue(sNT, sKEY, DATA)--Table)
end
CustomGameEventManager:RegisterListener("onSync", Dynamic_Wrap(GameMode, 'onSync'))

db(sCOMPLETE)