function GetFileName(nLevel)  --Возвращает путь файла (начиная с vscripts\..), из которого выполняется скрипт
	local sPath = debug.getinfo(nLevel or 2, "S").source
	local nPosEnd
  _, nPosEnd = sPath:find("vscripts")
	return "["..sPath:sub(nPosEnd+2).."] "
end
sLOAD = "loading..."
sCOMPLETE = "load complete..."

--Debug init
if db == nil then
  if _G.DEBUG_SPEW then
		_G.db = function(...)
			local function TabGenerate(nTab)
				nTab = nTab or 1
				local sResult = ''
				local i
				for i = 1, nTab do
					sResult = sResult .. '	'
				end
				return sResult
			end
			print(GetFileName(3)..tostring(...))

			local hArgs = {...}
			for nArgIndex, arg in pairs(hArgs) do
				if arg == nil then
					print('['..nArgIndex..'] == nil')
				elseif type(arg) == 'table' then
					--[[if arg == {} then
						print(TabGenerate(1)..tostring(arg)..'= {}')
					end]]
					local function Table2str(t, tab, nIterationCount)
						nIterationCount = nIterationCount or 1
						print(TabGenerate(tab)..tostring(t))
						for k, v in pairs(t) do
							print(TabGenerate(tab+1)..'('..type(k)..') '..tostring(k)..' = ('..type(v)..') '..tostring(v))
							
							if nIterationCount < 5 then
								if type(k) == 'table' then
									Table2str(k, tab+2, nIterationCount+1)
								end
								if (type(v) == 'table') and 
								(not ((type(k) == 'string') and (k:sub(1,2) == '__'))) 
								then
									Table2str(v, tab+2, nIterationCount+1)
								end
							end
						end
					end
					Table2str(arg, 1)
				end
			end
			--[[
			local s = {...}
			for k, v in pairs(s) do
				Say(nil, v, false)
			end
			]]
    end
  else
    _G.db = function() end
  end
end

db(sLOAD)

--Создаёт список функций, для дальнейшего выполнения
function CreateModul()
	local ModulEvents = class({})
	ModulEvents.hFunctions = {}	--Пространство выполняемых функций

	function ModulEvents:AddFunc(NewFunc)
		local i = 1
		while self.hFunctions[i] ~= nil do
			i = i + 1
		end
		self.hFunctions[i] = NewFunc
	end

	function ModulEvents:FullClear()
		self.hFunctions = nil
		self.hFunctions = {}
	end

	function ModulEvents:apply(...)
		local i = 1
		while self.hFunctions[i] ~= nil do
			self.hFunctions[i](...)
			i = i + 1
		end
	end

	return ModulEvents
end

db(sCOMPLETE)