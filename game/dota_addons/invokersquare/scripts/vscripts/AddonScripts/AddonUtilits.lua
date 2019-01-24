require('BaseLib/utils')

if ADDON == nil then
  _G.ADDON = class({})
end

function ADDON:InitNetTables()
  local nGM_hGMInfo = {}
	local sGamemodeIndex_sGamemodeName = {}
  local nGamemodeCount = 0
  local sGamemodeSelected = tostring(nGamemodeCount)
  local NewGamemode = function(sGamemodeName, sGamemodeLuaFolder)
    nGM_hGMInfo[nGamemodeCount] = {
      name = sGamemodeName,
      folder = sGamemodeLuaFolder or '',
    }
    sGamemodeIndex_sGamemodeName[tostring(nGamemodeCount)] = sGamemodeName

    nGamemodeCount = nGamemodeCount + 1
    return function() 
      sGamemodeSelected = tostring(nGamemodeCount-1)
    end
  end
  
  --self.GMInit = function() end

  NewGamemode('classic', 'ClassicMode')()
  NewGamemode('deathmatch')
  NewGamemode('sandbox')
  NewGamemode('dodgeball')

  CustomNetTables:SetTableValue( "addon", "hGameSetup", {
    sGM_hGMInfo = nGM_hGMInfo,
    sGamemodeIndexSelected = sGamemodeSelected,
  })
  
  local npc_abilities_custom = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	local npc_heroes_custom = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  local npc_units_custom = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  
  CustomNetTables:SetTableValue( "npc", "abilities", npc_abilities_custom)
  CustomNetTables:SetTableValue( "npc", "heroes", npc_heroes_custom)
  CustomNetTables:SetTableValue( "npc", "units", npc_units_custom)
end

function ADDON:GMInit(bApplyUtilits)
  local mode
  if self.GM then
    mode = self.GM:Init()
    db("mode = ADDON.GM:Init() "..sCOMPLETE)
  else
    db("ADDON:GMInit() -> self.GMInitFunc == nil !!!")
    mode = class({})
  end
  --[[
  if bApplyUtilits then
    
    function mode:ApplyModifier(eUnit, sModifierName, eCaster, eSourceAbility, hDeviationsFormDefault)
      local hStats = self.Const.modifiers[sModifierName] or {}
      if hDeviationsFormDefault then
        for k, v in pairs(hDeviationsFormDefault) do
          hStats[k] = v
        end
      end
      eUnit:AddNewModifier(eCaster or eUnit, eSourceAbility, sModifierName, hStats)
    end
    
  end
  ]]
  return mode
end

db(sCOMPLETE)