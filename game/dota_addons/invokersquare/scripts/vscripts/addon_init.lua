
local sExecByEnt = 'ExecByEnt'
function SyncFunc(hData)
  --Клиент-сервер код
  local nEnt = hData.nEntIndex
  local sFuncExec = hData.sFuncExec

  if nEnt and nEnt ~= -1 and sFuncExec then
    local eEnt
    local nEnt2 = hData.nEntIndex2
    if nEnt2 and nEnt2 ~= -1 then
      --BUFF
      local eEnt2 = EntIndexToHScript(nEnt2)
      eEnt = eEnt2 and eEnt2.nBuff_eBuff and eEnt2.nBuff_eBuff[nEnt]
    else
      --Entity Obj
      eEnt = EntIndexToHScript(nEnt)
    end

    if eEnt and (not eEnt:IsNull()) and eEnt[sFuncExec] and type(eEnt[sFuncExec]) == 'function' then
      --Exec Func
      eEnt[sFuncExec](eEnt, nil)
    end
  end
end
ListenToGameEvent(sExecByEnt, SyncFunc, nil)


function SyncExecByEnt(eEnt, sFuncExec)
  if eEnt and sFuncExec then
    local nEnt, nEnt2
    if eEnt.GetEntityIndex then
      --Entity Obj
      nEnt = eEnt:GetEntityIndex()
      if not nEnt or nEnt == -1 then
        return
      end
    else
      --Buff Obj
      nEnt = eEnt.nIndex
      nEnt2 = eEnt:GetParent():GetEntityIndex()

      if not (nEnt and nEnt2) then 
        return
      end
    end

    local hData = {
      nEntIndex = nEnt,
      nEntIndex2 = nEnt2 or -1,
      sFuncExec = sFuncExec,
    }
    FireGameEvent(sExecByEnt, hData)
  else
    print('SyncExecByEnt error args: eEnt=', eEnt, ', sFuncExec=',sFuncExec)
  end
end

function SyncGlobalTable(hData)
  local sTableName = hData.sTableName
  local sKey = hData.sKey
  local nIsStringTable = hData.nIsStringTable or 0

  local hGlobalTab = CustomNetTables:GetTableValue(sTableName, sKey)
  if nIsStringTable == 1 then
    require('AddonScripts/ModifierSync')
    hGlobalTab = StringTable2Table(hGlobalTab)
  end
  _G[sKey] = hGlobalTab
end
ListenToGameEvent('SyncGlobalTable', SyncGlobalTable, nil)