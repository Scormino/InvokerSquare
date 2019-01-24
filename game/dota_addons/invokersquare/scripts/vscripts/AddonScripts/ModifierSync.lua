--Синхронизирует переменную с сервера используя NetTable

local sPrePrefix = '__ST'
local sPostPrefixKey = 'k'
local sPostPrefixVal = 'v'


function Table2StringTable(hDangerTable, nSTableId)
  nSTableId = nSTableId or 1  --номер текущей строковой таблицы
  local sST = sPrePrefix .. tostring(nSTableId) --префик для текущей строковой таблицы
  local hSafeTable = {} --сюда будем набирать только sKey-sVal значения (без вложенных таблиц)
  local nKVIndex = 1 --текущий индекс пары Key-Val
  for k, v in pairs(hDangerTable) do  --обходим текущую таблицу
    local sSafeKey = sST .. sPostPrefixKey .. tostring(nKVIndex)  --определяем строковой ключ для ключа "опасной" таблицы
    if type(k) == 'table' then  --если ключ опасной таблицы - это таблица
      nSTableId = nSTableId + 1 --инкрементируем абсолютное кол-во строковых таблиц
      hSafeTable[sSafeKey] = sPrePrefix .. tostring(nSTableId)  --записываем, что этот ключ опасной таблицы - таблица
      local hChild  --строковая таблица ключа опасной таблицы
      hChild, nSTableId = Table2StringTable(k, nSTableId) --получаем строковую таблицу и обновляем абсолютный индекс всех строковых таблиц
      for sChildKey, sChildVal in pairs(hChild) do  --обходим дочернюю строковую таблицу
        hSafeTable[sChildKey] = sChildVal --переписываем все результаты дочерней строковой таблицы в родительскую
      end
    else
      --если ключ - не таблица, то просто записываем ключ к текущему строковому ключу
      hSafeTable[sSafeKey] = k
    end
    --тут всё абсолютно аналогично примеру выше
    local sSaveVal = sST .. sPostPrefixVal .. tostring(nKVIndex)
    if type(v) == 'table' then
      nSTableId = nSTableId + 1
      hSafeTable[sSaveVal] = sPrePrefix .. tostring(nSTableId)
      local hChild
      hChild, nSTableId = Table2StringTable(v, nSTableId)
      for sChildKey, sChildVal in pairs(hChild) do
        hSafeTable[sChildKey] = sChildVal
      end
    else
      hSafeTable[sSaveVal] = v
    end
    
    nKVIndex = nKVIndex + 1 --инкрементируем текущий индекс Key-Val пары
  end
  return hSafeTable, nSTableId  --выводим строковую таблицу и конечный номер строковой таблицы (может не совпадать с номером выходящей строковой таблицы)
end

function StringTable2Table(stTable, nSTableId)
  local hResult = {} --это будет результирующая таблица для текущей функции
  nSTableId = nSTableId or 1 
  local sST = sPrePrefix .. tostring(nSTableId) --название строковой таблицы этой функции
  local sSTk = sST .. sPostPrefixKey --просто для уменьшения сложения строк в каждой новой итерации
  local sSTv = sST .. sPostPrefixVal --просто для уменьшения сложения строк в каждой новой итерации

  local nKVIndex = 1 --текущий индекс пары Key-Val
  while true do --Будем обходить все Key-Val пары sST строковой таблицы
    local CurrentKey, CurrentVal  --сюда собираем очередную пару
    --предпологаемая пара
    local CurrentSTk = stTable[sSTk .. tostring(nKVIndex)]  --предпологаемый ключ
    local CurrentSTv = stTable[sSTv .. tostring(nKVIndex)]  --предпологаемое значение

    if CurrentSTk then  --есть ли предпологаемый ключ (это val строковой таблицы)
      if (type(CurrentSTk) == 'string') and (CurrentSTk:sub(1, sPrePrefix:len()) == sPrePrefix) then  --Если есть ожидаемый префикс
        --то расшифровываем очередную строковую таблицу в таблицу
        local nSTChildNumber = tonumber(CurrentSTk:sub(sPrePrefix:len()+1, CurrentSTk:len()))
        CurrentKey = StringTable2Table(stTable, nSTChildNumber)  --будет расшифровывать только свою и вложенные строковые таблицы
      else
        --иначе текущее значение ключа из пары Key-Val -> будет использовано в качестве ключа для результирующей таблицы
        CurrentKey = CurrentSTk
      end

      if (type(CurrentSTv) == 'string') and (CurrentSTv:sub(1, sPrePrefix:len()) == sPrePrefix) then
        local nSTChildNumber = tonumber(CurrentSTv:sub(sPrePrefix:len()+1, CurrentSTv:len())) --берёт номер текущей строковой таблицы
        CurrentVal = StringTable2Table(stTable, nSTChildNumber)  --будет расшифровывать только указанную и вложенные строковые таблицы
      else
        CurrentVal = CurrentSTv
      end
    else
      break --если ключа нет, то и значения тоже, значит текущий индекс - пустой
    end

    hResult[CurrentKey] = CurrentVal  --записываем новую пару

    nKVIndex = nKVIndex + 1
  end
  return hResult
end
require('BaseLib/utils')

function Sync(DATA, key, bIsDebug)
  if key then
    if type(key) == 'table' then
      key = (key.GetName and key:GetName()) or 'key'
    else
      key = tostring(key)
    end
  else
    key = 'key'
  end
  if IsServer() then
    local ReturnObj = DATA
    if type(ReturnObj) == 'function' then
      ReturnObj = DATA()
    end

    local SyncObj = Table2StringTable({ReturnObj})
    CustomNetTables:SetTableValue("sync", key, SyncObj)
    
    return ReturnObj
  end
  local stTable = CustomNetTables:GetTableValue("sync", key)
  if stTable then
    local ValSync = StringTable2Table(stTable)[1]
    return ValSync
  end
end


local nSyncIterator = 0
function SyncOnly(DATA, key)
  if key then
    key = tostring(key)
  else
    nSyncIterator = nSyncIterator + 1
    if nSyncIterator > 1000 then
      nSyncIterator = 1
    end
    key = tostring(nSyncIterator)
  end
  if IsServer() then
    CustomNetTables:SetTableValue("sync", key, {result = DATA})
  end
  local hOut = CustomNetTables:GetTableValue("sync", key)
  return hOut.result
end

--[[
function SyncByEnt(Ent, sParam)
  local sKey = string.format( "%d", Ent:GetEntityIndex() )
  if IsServer() then
    CustomNetTables:SetTableValue("sync", sKey, {[sParam] = Ent[sParam]})
  end  
  local hOut = CustomNetTables:GetTableValue("sync", sKey)[sParam]
  return hOut
end
function DelByEnt(Ent)
  local sKey = string.format( "%d", Ent:GetEntityIndex() )
  CustomNetTables:SetTableValue("sync", sKey, nil)
end
]]

--CustomGameEventManager:RegisterListener('RunSync', SyncFunc)


--[[
function Sync(...)  
  local hArgs = {...}

  local key = 'sync'
  local DATA

  if hArgs[2] then
    --2 аргумента
    key = tostring(hArgs[1])
    DATA = hArgs[2]
  else
    --1 аргумент
    DATA = hArgs[1]
  end
  if IsServer() then
    if type(DATA) == 'function' then
      CustomNetTables:SetTableValue("sync", key, {result = DATA()})
    else
      CustomNetTables:SetTableValue("sync", key, {result = DATA})
    end
  end
  return CustomNetTables:GetTableValue("sync", key).result
end
]]

