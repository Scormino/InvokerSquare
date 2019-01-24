--[[
	Самое начало исполнения .lua скриптов server'ом
]]

print("[addon_game_mode.lua] loading...")

_G.DEBUG_SPEW = true	 --DeBug

	

--Самые необходимые библиотеки для игры:
--Инициализация разнообразных утилит для упрощения кода
require('BaseLib/utils')

--Все нужные базовые константы
require('AddonScripts/AddonUtilits')

if _G.GameMode == nil then
	_G.GameMode = class({})
	ADDON:InitNetTables()
end

--инициализация игровых событий
require('BaseLib/events')
--инициализация функций игрового режима
require('BaseLib/gamemode')




function Precache( context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_invoker.vsndevts", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
	
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_enigma.vsndevts", context )
	

	PrecacheResource('soundfile', 'sounds/weapons/creep/neutral/black_dragon_fire.vsnd',context)
	
	--spell = invoker_spellsteal_rubiks
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context)
	
	
	--PrecacheResource( "soundfile", "sounds/weapons/hero/rubick/null_field_allies.vsnd", context)
	
	--PrecacheUnitByNameSync("npc_dota_hero_arc_warden", context)
	--PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_arc_warden.vsndevts", context )
end

-- Create the game mode when we activate
function Activate()
	db("Activate(), IsServer=", IsServer())
	GameRules.GameMode = GameMode()
	_G.GameMode = GameRules.GameMode
	GameMode:InitGameMode()	-- [gamemode.lua]


	EventModul.STATE_HERO_SELECTION:AddFunc(
		function()
			--Определение выбранного мода
			--Берём записанное с hGameSetup значение (меняется в зависимости от состояния CheckBox в GameSetup режиме)
			local hGameSetup = CustomNetTables:GetTableValue( "addon", "hGameSetup")

			local sFolder = hGameSetup.sGM_hGMInfo[hGameSetup.sGamemodeIndexSelected].folder
			local sCurrentGamemode = sFolder or 'ClassicMode'

			require('Gamemodes/'..sCurrentGamemode..'/Mode')	--определяем мод
			_G.hMode = ADDON:GMInit(true)     --Classic:Init()		--Инициализируем мод в переменную текущего мода
		end
	)
	


	--Инициализвация информации, связанной с Setup
	require('Gamemodes/Setup')	--Необходимо выполнять именно после инициализации Gamemode. Т.к. не видит enitity уже сущ. на карте
end







--[[
Timers:CreateTimer(8,
	function()
		local hST = {
			[5] = '23',
			geg = 7,
			gegR = {8}
		}
		db('Begin:', hST)
		--hST = Table2StringTable(hST)
		--db('Table2StringTable ->', hST)
		hST = Sync(hST)
		db('Sync ->', hST)
		--hST = StringTable2Table(hST)
		--db('StringTable2Table ->', hST)
	end
)
]]

--[[
require('AddonScripts/ModifierSync')		
require('BarebonesLib/timers')

_G.nLuaMemory = 0
Timers:CreateTimer(
	function()
		local nCurrentMemory = collectgarbage('count')
		print('lua memory usage = ', tostring(nCurrentMemory), ' (' .. tostring(nCurrentMemory - _G.nLuaMemory) .. ')')
		_G.nLuaMemory = nCurrentMemory


		return 1
	end
)
require('AddonScripts/ModifierSync')		
require('BarebonesLib/timers')
]]








db(sCOMPLETE)