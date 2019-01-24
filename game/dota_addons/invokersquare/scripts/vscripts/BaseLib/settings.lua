-- In this file you can set up all the properties and settings for your game mode.

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 10.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 17.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 0                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE =	-1--1300       -- How far out should we allow the camera to go?  Use -1 for the default (1134) while still allowing for panorama camera distance changes

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = false      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = false        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = false                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = false             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = true             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 25         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 30                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
local base_exp = 190
local add_exp = 10

local memory_exp = 0
XP_PER_LEVEL_TABLE[1] = 0
for i=2,MAX_LEVEL do
	memory_exp = memory_exp + base_exp + (add_exp * (i-1))
	XP_PER_LEVEL_TABLE[i] = memory_exp
end

ENABLE_FIRST_BLOOD = false               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = true               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = "npc_dota_hero_invoker"	-- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.
-------------------------RESPAWN
FIXED_RESPAWN_TIME = 5                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 6000              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 5               -- What should we use for the minimum attack speed?

GAME_END_DELAY = 6                    -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 1            -- How long should we wait after the victory message displays to show the End Screen?  Use 
STARTING_GOLD = 0                     -- How much starting gold should we give to each player?
DISABLE_DAY_NIGHT_CYCLE = true         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?


SKIP_TEAM_SETUP = false                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = false               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 15              -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = false                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 


-- NOTE: You always need at least 2 non-bounty type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = false
ENABLED_RUNES[DOTA_RUNE_HASTE] = false
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = false
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = false
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = false
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = false
ENABLED_RUNES[DOTA_RUNE_ARCANE] = false


MAX_NUMBER_OF_TEAMS = 12                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true           -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 255, 0, 0 }  -- red
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 0, 0, 255 }   -- blue
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 0, 255, 0 }  -- lime
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 255, 215, 0 }   -- gold
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 0, 255, 255 }   -- Aqua	
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 255, 0, 255 }  -- Fuchsia
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 139, 69, 19 }   -- SaddleBrown
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 255, 255, 255 }  -- white
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 128, 128, 128 }  --   Gray 
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 0, 0, 0 }  --   black

--[[
print("[Lenivex setting.lua] Teams:")

local key, value
for key, value in pairs(TEAM_COLORS) do
  print(key, "{"..value[1]..","..value[2]..","..value[3].."}") -- выведет "a 3", потом "b 4"
end
]]

--{ 61, 210, 150 }  --    Teal
--{ 243, 201, 9 }   --    Yellow
--{ 197, 77, 168 }  --    Pink
--{ 255, 108, 0 }   --    Orange
--{ 52, 85, 255 }   --    Blue
--{ 101, 212, 19 }  --    Green
--{ 129, 83, 54 }   --    Brown
--{ 27, 192, 216 }  --    Cyan
--{ 199, 228, 13 }  --    Olive
--{ 140, 42, 244 }  --    Purple

--CustomNetTables:SetTableValue("Hash", "TEAM_COLORS" , TEAM_COLORS)	--записываем, для удобной передачи в .js


USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
  
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 20
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 20

--CUSTOM_TEAM_PLAYER_COUNT[4] = 20
--CUSTOM_TEAM_PLAYER_COUNT[5] = 20