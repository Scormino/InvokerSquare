function GetConst(hConst, hParams)	--Функция позволяет полчить значения в зависимости от различных параметров
  if not hConst then
    return nil, 'error: hConst == nil'
  end
  hParams = hParams or {}
  if type(hConst) == 'number' or type(hConst) == 'string' then
    return hConst
  elseif type(hConst) == 'table' then
    local nLevel
    if type(hParams) == 'number' then
      nLevel = hParams
    else
      nLevel = math.max(hParams[hConst.factor] or 1, 1)
    end
    if hConst.first then
      --Арифметический тип
      local gain = hConst.gain or 0
      return hConst.first + (gain * (nLevel - 1))
    else
      --параметрический тип
      return hConst[nLevel]
    end
  elseif type(hConst) == 'function' then
    return hConst(hParams)
  end

  return nil, 'error'
end



function SyncGameConst()
  FireGameEvent('SyncGlobalTable', {
      sTableName = "Hash",
      sKey = "hGameConst",
      nIsStringTable = 1
    }
  )
end
function GetGameConst()
  --_G.hGameConst = _G.hGameConst or StringTable2Table(CustomNetTables:GetTableValue("Hash", "hGameConst"))
  return _G.hGameConst
end
