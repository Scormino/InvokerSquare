if(!Game.hFirstInit.Tooltip){
		Game.hFirstInit.Tooltip = true


		var sThisFileName = "[Tooltips/Tooltip.js] "
		$.Msg(sThisFileName+'init...')

		/*

		//Game.CustomTooltip.nSyncEventIndex = 0







	function ReCreateTooltipArea(sTooltipName){
		var CustomTooltipArea = Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea")
		var bNew = false
		if(Game.CustomTooltip.sLastTooltip != sTooltipName){	//New
			Game.CustomTooltip.CustomTooltipRoot.style.backgroundColor = "rgb(16,23,28)"
			if(CustomTooltipArea != null){
				CustomTooltipArea.style.height = "0px"
				CustomTooltipArea.style.width = "0px"

				CustomTooltipArea.DeleteAsync(0)	//Сносим предыдущий Tooltip
				CustomTooltipArea = null
			}
			CustomTooltipArea = $.CreatePanel('Panel', Game.CustomTooltip.CustomTooltipRoot, 'TooltipArea');
			CustomTooltipArea.AddClass("DefaultArea")
			bNew = true
		}
		return {
			CustomTooltipArea: CustomTooltipArea,
			bNew: bNew
		}
	}



	Game.CustomTooltip.Types = {}
	Game.CustomTooltip.Types.SpellRefresh = function(){
		var sAbilName = Game.CustomTooltip.TooltipLastInfo.sAbilName
		var nEntityCaster = Game.CustomTooltip.TooltipLastInfo.nEntityCaster
		var nEntityAbility = Game.CustomTooltip.TooltipLastInfo.nEntityAbility || Entities.GetAbilityByName(nEntityCaster, sAbilName)
		
		var hUnitData = {
			nEntityCaster: nEntityCaster,
			sAbilName: sAbilName,
		}	

		if(nEntityAbility != -1){
			var ST__sLevelType_hLevels = CustomNetTables.GetTableValue('tooltips', nEntityAbility.toString())
			if(ST__sLevelType_hLevels){
				hUnitData.sLevelType_hLevels = StringTable2Table(ST__sLevelType_hLevels)
			}
		}else{
			var ST__sLevelType_hOutLevels = CustomNetTables.GetTableValue('tooltips', 'unit_' + nEntityCaster.toString())
			if(ST__sLevelType_hOutLevels){
				hUnitData.sLevelType_hLevels = StringTable2Table(ST__sLevelType_hOutLevels)
			}
		}

		var NewArea = ReCreateTooltipArea(sAbilName)
		RunToolTipEngine(NewArea.CustomTooltipArea, sAbilName, hUnitData, NewArea.bNew)
	}


	Game.CustomTooltip.Types.BuffRefresh = function(hData){
		if(Game.CustomTooltip.nSyncEventIndex != hData.nSyncEventIndex || !Game.CustomTooltip.bIsTooltipAlive){
			return
		}
		
		var nCaster = hData.nCaster
		var nBuff = hData.nBuff
		var sBuff = hData.sBuff
		
		//подготовка данных
		var hUnitData = {
			nEntityCaster: nCaster,
			sAbilName: sBuff,
		}	
		if(hData.sLevelType_hLevels != undefined){
			hUnitData.sLevelType_hLevels = hData.sLevelType_hLevels
		}

		//Создание панельного пространства
		var NewArea = ReCreateTooltipArea(sBuff)
		// запуск/перезапуск Tooltip движка
		RunToolTipEngine(NewArea.CustomTooltipArea, sBuff, hUnitData, NewArea.bNew)
	}
	GameEvents.Subscribe("SERVER_send_buff_info_signal", Game.CustomTooltip.Types.BuffRefresh)












	var CloseTooltip = (
		function(panel){
			return function(){
				Game.CustomTooltip.bIsTooltipAlive = false
				$.DispatchEvent("DOTAHideAbilityTooltip" , panel);
				//$.DispatchEvent("DOTAHideBuffTooltip" , panel)
				
				$.DispatchEvent("UIHideCustomLayoutTooltip" , panel, "Tooltip")	//Можно и без агрумента panel
				//Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea").style.visibility = "collapse"
				
			}
		}
	);
	function CloseBuffTooltip(panel){
		CloseTooltip(panel)()
	}
	$.RegisterForUnhandledEvent('DOTAHideBuffTooltip', CloseBuffTooltip)



	var TooltipBuffSignal = function(panel, nEntityIndex, nBuffSerial, bOnEnemy){
		return function(){
			//$.DispatchEvent("DOTAHideBuffTooltip", panel)
			var hInfo = {
				sType: 'buff',
				ParentPanel: panel,
				nBuff: nBuffSerial,
				nCaster: nEntityIndex,
				bOnEnemy: bOnEnemy
			}
			InvokeTooltip(hInfo)
		}
	}

	function TooltipBuffUpdate(panel, nEntityIndex, nBuffSerial, bOnEnemy){
		var sBuff = Buffs.GetName(nEntityIndex, nBuffSerial)
		if(Game.sTooltipName_fTooltip[sBuff] != null){	//TooltipConstants.js
			$.Schedule(0, TooltipBuffSignal(panel, nEntityIndex, nBuffSerial, bOnEnemy))
		}
	}
	$.RegisterForUnhandledEvent('DOTAShowBuffTooltip', TooltipBuffUpdate)
	*/
	/*
	var AbilityTooltip = ( //Функция, контролирующая tooltip
		function(_args){
			return function(){
				var spell = _args
				var ParentPanel = spell.FindChildTraverse("AbilityButton")//на что вешать tooltip

				var sAbilName = spell.FindChildTraverse("AbilityImage").abilityname
				var nEntityAbility = spell.FindChildTraverse("AbilityImage").contextEntityIndex
				var nEntityCaster = Abilities.GetCaster(nEntityAbility)

				var hInfo = {
					sType: 'spell',
					ParentPanel: ParentPanel,
					sAbilName: sAbilName,
					nEntityAbility: nEntityAbility,
					nEntityCaster: nEntityCaster,
				}
				InvokeTooltip(hInfo)
			}
		}
	);
	*/
	//CustomNetTables.SubscribeNetTableListener( "tooltips", ToolTipUpdate )
	//GameEvents.Subscribe("dota_player_learned_ability", ToolTipUpdate)


	/*
	function ToolTipUpdateUnitData(hData){
		//$.Msg(sThisFileName+"ToolTipUpdate, Game.CustomTooltip.bIsTooltipAlive=", Game.CustomTooltip.bIsTooltipAlive)
		var sTooltip
		if(hData.nSpell){
			//SPELL
			sTooltip = Abilities.GetAbilityName(hData.nSpell)
		}else if(hData.nParent && hData.nBuff){
			//BUFF
			sTooltip = Buffs.GetName(hData.nParent, hData.nBuff)
		}

		if(sTooltip && sTooltip == Game.CustomTooltip.sLastTooltip){
			ToolTipUpdate()
		}
	}
	GameEvents.Subscribe("RefreshTooltipsUnitData", ToolTipUpdateUnitData)	//ситуативное обновление Tooltip'а (стоит вызывать при любом событии потенциально обновляющим Tooltip)
	*/

















	

	Game.CustomTooltip = {}
	Game.CustomTooltip.nSyncEventIndex = 0
	Game.CustomTooltip.bIsTooltipAlive = false
	Game.CustomTooltip.TooltipLastInfo = null
	Game.CustomTooltip.sLastTooltip = ""	//название последнего созданного тултипа, Чтобы не создавать новый каждый раз
	Game.CustomTooltip.nTimer = 0
	Game.CustomTooltip.FuncTimer = null
	//для TooltipConstants:
	Game.CustomTooltip.CustomTooltipArea = null
	Game.CustomTooltip.NTData = null
	Game.CustomTooltip.bNew = null
	Game.CustomTooltip.bNTRefresh = false

	function SetTooltipInGame(){	//В xml файле 'ontooltiploaded="SetTooltipInGame()"'
		Game.CustomTooltip.CustomTooltipRoot = $('#TooltipArea').GetParent()
	}

	function ToolTipUpdate(){
		if(Game.CustomTooltip.TooltipLastInfo != null && Game.CustomTooltip.bIsTooltipAlive){
			InvokeTooltip(Game.CustomTooltip.TooltipLastInfo)
		}
	}
	GameEvents.Subscribe("RefreshTooltips", ToolTipUpdate)	//принудительное обновление CustomTooltip'а






	/*var CloseTooltip = (
		function(panel){
			return function(){
				Game.CustomTooltip.bIsTooltipAlive = false
				//$.DispatchEvent("DOTAHideAbilityTooltip" , panel);
				//$.DispatchEvent("DOTAHideBuffTooltip" , panel)
				
				$.DispatchEvent("UIHideCustomLayoutTooltip" , panel, "Tooltip")	//Можно и без агрумента panel
				//Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea").style.visibility = "collapse"
				
			}
		}
	);*/
	
	function TooltipClose(ParentPanel, sType){
		Game.CustomTooltip.bIsTooltipAlive = false
		$.DispatchEvent("UIHideCustomLayoutTooltip" , ParentPanel, "Tooltip")	//Можно и без агрумента panel
	}

	//Ловим сигнал закрытия Tooltip Spell'а
	function TooltipSpellClose(ParentPanel){
		TooltipClose(ParentPanel, 'spell')
	}
	$.RegisterForUnhandledEvent('DOTAHideAbilityTooltip', TooltipSpellClose)

	//Ловим сигнал открытия Tooltip Spell'а
	function TooltipSpellUpdate(hParent, sSpell, nEntityIndex){
		HookShowDefaultTooltip({
				sType: 'spell',
				hParent: hParent,
				nUnit: nEntityIndex,
				sSpell: sSpell,
				nSpell: Entities.GetAbilityByName(nEntityIndex, sSpell)
			}
		)
	}
	$.RegisterForUnhandledEvent('DOTAShowAbilityTooltipForEntityIndex', TooltipSpellUpdate)
	//DOTAShowAbilityTooltip(string abilityName)

	//Ловим сигнал закрытия Tooltip buff'а
	function CloseBuffTooltip(ParentPanel){
		TooltipClose(ParentPanel, 'buff')
	}
	$.RegisterForUnhandledEvent('DOTAHideBuffTooltip', CloseBuffTooltip)
	
	//Ловим сигнал открытия Tooltip buff'а
	function TooltipBuffUpdate(hParent, nEntityIndex, nBuffSerial, bOnEnemy){
		HookShowDefaultTooltip({
				sType: 'buff',
				hParent: hParent,
				nUnit: nEntityIndex,
				nBuff: nBuffSerial,
				bOnEnemy: bOnEnemy
			}
		)
	}
	$.RegisterForUnhandledEvent('DOTAShowBuffTooltip', TooltipBuffUpdate)

	//обрабатываем сигнал открытого Tooltip
	function HookShowDefaultTooltip(hInfo){
		//распределяем данные и вызываем CustomTooltip
		if(hInfo.sType == 'spell'){
			var hLocalInfo = {}
			hLocalInfo.sType = hInfo.sType
			hLocalInfo.ParentPanel = hInfo.hParent
			hLocalInfo.nEntityIndex = hInfo.nSpell
			hLocalInfo.nEntityParent = hInfo.nUnit
			hLocalInfo.sTooltipName = hInfo.sSpell || Abilities.GetAbilityName(hInfo.nSpell)
			if(Game.sTooltipName_fTooltip[hLocalInfo.sTooltipName]){
				$.Schedule(0, InvokeTooltip(hLocalInfo))
			}
		}else if(hInfo.sType == 'buff'){
			var sBuff = Buffs.GetName(hInfo.nUnit, hInfo.nBuff)
			if(Game.sTooltipName_fTooltip[sBuff]){	//TooltipConstants.js
				var hLocalInfo = {
					sType: hInfo.sType,
					ParentPanel: hInfo.hParent,
					nEntityIndex: hInfo.nBuff,
					nEntityParent: hInfo.nUnit,
					sTooltipName: sBuff
				}
				$.Schedule(0, InvokeTooltip(hLocalInfo))
			}
		}
	}

	//Вызов Tooltip'а
	var InvokeTooltip = function(hInfo){
		return function(){
			function RunCustomTooltipLayout(hInfo){
				if(!Game.CustomTooltip.bIsTooltipAlive){
					Game.CustomTooltip.bIsTooltipAlive = true
				}
				Game.CustomTooltip.TooltipLastInfo = hInfo
				$.DispatchEvent("UIShowCustomLayoutTooltip", hInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
			}
			RunCustomTooltipLayout(hInfo)
	
			Game.CustomTooltip.nSyncEventIndex = (Game.CustomTooltip.nSyncEventIndex || 0) + 1
			if(Game.CustomTooltip.nSyncEventIndex > 1000){Game.CustomTooltip.nSyncEventIndex = 0}
	
			var hClientSendInfo = {}
			//hClientSendInfo.nPlayerId = Players.GetLocalPlayer()
			hClientSendInfo.nSyncEventIndex = Game.CustomTooltip.nSyncEventIndex
			hClientSendInfo.sType = hInfo.sType
			hClientSendInfo.nEntityIndex = hInfo.nEntityIndex
			hClientSendInfo.nEntityParent = hInfo.nEntityParent
			hClientSendInfo.sName = hInfo.sTooltipName
	
			if(hInfo.sType == 'buff'){
				//RunCustomTooltipLayout(hInfo)
				//var hBuffAllInfo = GetBuffAllInfo(hInfo.nCaster, hInfo.nBuff, hInfo.sBuff)
				
				//hBuffAllInfo.nSyncEventIndex = Game.CustomTooltip.nSyncEventIndex
	
				GameEvents.SendCustomGameEventToServer( "CLIENT_update_tooltip_traffic", hClientSendInfo)
				Game.CustomTooltip.Types.EntRefresh(hInfo)
				//GameEvents.SendCustomGameEventToServer( "CLIENT_send_buff_info_signal", hBuffAllInfo)
				//Game.CustomTooltip.Types.BuffRefresh()
			}else if(hInfo.sType == 'spell'){
				GameEvents.SendCustomGameEventToServer( "CLIENT_update_tooltip_traffic", hClientSendInfo)
				Game.CustomTooltip.Types.EntRefresh(hInfo)
				//Game.CustomTooltip.Types.SpellRefresh()
				//if(Game.sTooltipName_fTooltip[hInfo.sAbilName] == null){	//TooltipConstants.js
				//	Game.CustomTooltip.bIsTooltipAlive = false
				//	$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", hInfo.ParentPanel, hInfo.sAbilName, hInfo.nEntityCaster);
				//}else{
					
					//Game.CustomTooltip.Types.SpellRefresh()
				//}
			}
		}
	}

	function OnTooltipReceivedTraffic( table_name, table_key, data )
	{
		data = data && StringTable2Table(data)
		if(Number.parseInt(table_key) == Players.GetLocalPlayer()
			&& Game.CustomTooltip.nSyncEventIndex == data.nSyncEventIndex
		){
			if(Game.CustomTooltip.bNTRefresh){
				GameUI.RefreshNTFunc(data)
			}
		}
	}
	CustomNetTables.SubscribeNetTableListener("tooltips", OnTooltipReceivedTraffic)










	function ReCreateTooltipArea(sTooltipName){
		var CustomTooltipArea = Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea")
		var bNew = false
		if(Game.CustomTooltip.sLastTooltip != sTooltipName){	//New
			Game.CustomTooltip.CustomTooltipRoot.style.backgroundColor = "rgb(16,23,28)"
			if(CustomTooltipArea != null){
				CustomTooltipArea.style.height = "0px"
				CustomTooltipArea.style.width = "0px"

				CustomTooltipArea.DeleteAsync(0)	//Сносим предыдущий Tooltip
				CustomTooltipArea = null
			}
			CustomTooltipArea = $.CreatePanel('Panel', Game.CustomTooltip.CustomTooltipRoot, 'TooltipArea');
			CustomTooltipArea.AddClass("DefaultArea")
			bNew = true
		}
		return {
			CustomTooltipArea: CustomTooltipArea,
			bNew: bNew
		}
	}

	Game.CustomTooltip.Types = {}
	Game.CustomTooltip.Types.EntRefresh = function(hData){
		var sTooltipName = hData.sTooltipName
		if(sTooltipName != undefined && sTooltipName != null){
			var NewArea = ReCreateTooltipArea(sTooltipName)
			RunToolTipEngine(NewArea.CustomTooltipArea, sTooltipName, NewArea.bNew)
		}
	}

	//Запуск Tooltip
	function RunToolTipEngine(CustomTooltipArea, sTooltipName, bNew){
		if(Game.CustomTooltip.nTimer != 0){
			$.CancelScheduled(Game.CustomTooltip.nTimer, Game.CustomTooltip.FuncTimer)
			Game.CustomTooltip.nTimer = 0
			Game.CustomTooltip.FuncTimer = 0
		}

		Game.CustomTooltip.CustomTooltipArea = CustomTooltipArea
		Game.CustomTooltip.bNew = bNew
		Game.CustomTooltip.sLastTooltip = sTooltipName
		GameUI.ForceTooltip({
			CustomTooltipArea: CustomTooltipArea,
			sTooltipName: sTooltipName,
			bNew: bNew
		})
	}








	//Служебные функции
	function GetBuffAllInfo(nCaster, nBuff, sBuff){
		if(nCaster != undefined || nCaster != null){
			//Если нету nBuff, но есть sBuff
			if((nBuff == undefined || nBuff == null) && (sBuff != undefined || sBuff != null)){
				var nBuffCount = Entities.GetNumBuffs(nCaster)
				for(var nBuffSlot = 0; nBuffSlot < nBuffCount; nBuffSlot++){
					var nCurrentBuff = Entities.GetBuff(nCaster, nBuffSlot)
					if(Buffs.GetName(nCaster, nCurrentBuff) == sBuff){
						nBuff = nCurrentBuff
						break
					}
				}
				//Если есть nBuff, но нету sBuff
			}else if((nBuff != undefined || nBuff != null) && (sBuff == undefined || sBuff == null)){
				sBuff = Buffs.GetName(nCaster, nBuff)
			}
		}

		return {
			nCaster: nCaster,
			nBuff: nBuff,
			sBuff: sBuff
		}
	}

























	//Фикс стандартного UI (tooltip здесь добавляет эвенты для вызова на дефолтные кнопки способностей)
	function FixVisualSpellLevels(){
		var hudlevelSpells = Game.hudRoot.FindChildTraverse("abilities")
		for(var g=0; g <= 5; g++){   //Перебираем спеллы
			var spell = hudlevelSpells.FindChildTraverse("Ability" + g)
			if(!spell){	//Перезапуск, т.к. функа вызвана слишком рано
				$.Schedule(0.5, FixVisualSpellLevels)
				//$.Msg(sThisFileName+'FixVisualSpellLevels - skip')
				break
			}
			//spell.FindChildTraverse("AbilityButton").SetPanelEvent("onmouseover", AbilityTooltip(spell));
			//spell.FindChildTraverse("LevelUpTab").SetPanelEvent("onmouseover", AbilityTooltip(spell));
			//spell.FindChildTraverse("AbilityButton").SetPanelEvent("onmouseout",CloseTooltip(spell));
			//spell.FindChildTraverse("LevelUpTab").SetPanelEvent("onmouseout", CloseTooltip(spell));
			for(var i = 0; i < 9; i++){ //перебираем уровень спелла
				var Spelllevel = spell.FindChildTraverse("LevelUp" + i);
				if(Spelllevel != null){
					if(g == 5){   //если это позиция 6 способности
						Spelllevel.style.height = "8px";
						Spelllevel.style.width = "6px";
						Spelllevel.style.margin = "1px 6px 1px 0px";
					}else{
						Spelllevel.style.height = "8px";
						Spelllevel.style.width = "5px";
						Spelllevel.style.margin = "1px 2px 1px 0px";
					}
				}
			}
		}

	}
	GameUI.DeleteStatBranch()	//[scripts/manifest.js]
	GameUI.HideAddItemSlot()	//[scripts/manifest.js]
	FixVisualSpellLevels()







	// This is an example of how to use the GameUI.SetMouseCallback function
	GameUI.SetMouseCallback( function( eventName, arg ) {
			//var CONSUME_EVENT = true;
			var CONTINUE_PROCESSING_EVENT = false;

			if	(eventName === "pressed" && (arg == 5 || arg == 6)){
				return Game.CustomTooltip.bIsTooltipAlive
			}

			if ( eventName === "wheeled" && Game.CustomTooltip.bIsTooltipAlive && Game.CustomTooltip.CustomTooltipRoot && Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea"))
			{
				var CustomTooltipArea = Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea")
				var bShift = GameUI.IsShiftDown()
				var sEvent
				
				if(bShift || CustomTooltipArea.Stats.contentheight <= CustomTooltipArea.Stats.actuallayoutheight){
					//Left-Right
					if(arg>0){
						sEvent = 'ScrollLeft'
					}else{
						sEvent = 'ScrollRight'
					}
				}else{
					//Up-Down
					if(arg>0){
						sEvent = 'ScrollUp'
					}else{
						sEvent = 'ScrollDown'
					}	
				}

				if(sEvent){
					var nPower = Math.abs(arg)
					for(var i = 0; i < nPower; i++){
						$.DispatchEvent(sEvent, CustomTooltipArea.Stats)
					}
				}
			}
			return CONTINUE_PROCESSING_EVENT
		} 
	)



	$.Msg(sThisFileName+'complete...')
}


