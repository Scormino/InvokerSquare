--require('BaseLib/utils')

--Единоразовая инициализация
if not bSetupComplete then
  db(sLOAD)
  _G.bSetupComplete = true

  local sMap = GetMapName()
  db('map = '..sMap)


  local Maps = {}

  local function fDefaultInit()
    local nTowerTypesCount = 2 --Кол-во типов башен (это связано с именами на карте и юнитами в 'npc_units_custom.txt')
    local hTowers = {}

    local function GetProcPerLoc(vLoc)
      local m = 4096  --Тупо в ручную узнал размер карты (не нашёл другого способа узнать размер)
      local minX, maxX, minY, maxY = -m, m, -m, m

      local xProc = 100 * (vLoc.x - minX) / (maxX - minX)
      local yProc = 100 * (vLoc.y - minY) / (maxY - minY)
      
      return xProc, (100 - yProc) --Инвертируем, так как в JS отсчёт идёт сверху
    end
    
    local FOR_CLIENT__nTower_hTower = {}
    local FOR_SERVER__nTower_hTower = {}
    local nTower = 1
    for nTowerType = 1, nTowerTypesCount do
      local hTowers = Entities:FindAllByName('TOWER_'..tostring(nTowerType))
      for _, eTower in pairs(hTowers) do
        local vPos = eTower:GetAbsOrigin()
        local nDefaultPlayer = -1   --Игрок по умолчанию влажеющий таверами
        local bAllow = true
        if nTowerType >= 2 then
          bAllow = false
        end

        local xProc, yProc = GetProcPerLoc(vPos)
        FOR_CLIENT__nTower_hTower[nTower] = {
          hMiniMapPos = {
            xProc = xProc,
            yProc = yProc,
          },
          nTowerType = nTowerType,
          nPlayer = nDefaultPlayer, 
          bAllow = bAllow,    --Разрешено ли сесть в этот слот
        }
        FOR_SERVER__nTower_hTower[nTower] = {
          vPos = vPos,
          nTowerType = nTowerType,
          nPlayer = nDefaultPlayer,
        }
        nTower = nTower + 1
      end
    end

    --local minX, maxX, minY, maxY = GetWorldMinX(), GetWorldMaxX(), GetWorldMinY(), GetWorldMaxY()  
    
    local FOR_CLIENT__hConstants = {
      nTower_hTower = FOR_CLIENT__nTower_hTower,
    }
    CustomNetTables:SetTableValue("addon", "hMapConstants", FOR_CLIENT__hConstants)
    return {
      nTower_hTower = FOR_SERVER__nTower_hTower,
    }
  end




  Maps.flat = fDefaultInit
  Maps['8_players'] = fDefaultInit
  Maps['4_players'] = fDefaultInit
  Maps.space = fDefaultInit
  _G.hMapConstants = Maps[sMap]()				--Сюда запишутся константы зависящие от карты
  

  db(sCOMPLETE)
end




