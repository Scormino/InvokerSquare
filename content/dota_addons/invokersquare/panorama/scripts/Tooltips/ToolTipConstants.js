var sThisFileName = "[TooltipConstants.js] "
$.Msg(sThisFileName+'init...')


if(!Game.hFirstInit.TooltipConstants){
	Game.hFirstInit.TooltipConstants = true

	function CustomGameModeInit(data){
		var sGameMode = data.sGameMode
		$.Msg(sThisFileName + "sGameMode = " + sGameMode)
		if(sGameMode == 'classic'){
			//InitTooltipsClassic()
		}
	}
	GameEvents.Subscribe("CustomGameModeInit", CustomGameModeInit)

	function OnHashChanged( table_name, key, data )
	{
		if(table_name == 'hGameConst'){
			RefreshGameConst()
			//hGameConst[key] = data
		}
		//$.Msg( "Table ", table_name, " changed: ", key, ", value = ", data);
	}
	CustomNetTables.SubscribeNetTableListener( "Hash", OnHashChanged )

	function RefreshGameConst(){
		hGameConst = StringTable2Table(CustomNetTables.GetTableValue( "Hash", "hGameConst" ))
		if(Game.CustomTooltip && Game.CustomTooltip.bIsTooltipAlive){
			GameUI.ForceTooltip()
		}
	}
}


//Все custom KV
var npc = {}
npc.abilities = CustomNetTables.GetTableValue("npc", "abilities")
npc.heroes = CustomNetTables.GetTableValue("npc", "heroes")
npc.units = CustomNetTables.GetTableValue("npc", "units")

var hGameConst = {}
RefreshGameConst()
InitTooltipsClassic()

function GetNTData(){
	var hData = CustomNetTables.GetTableValue( "tooltips", String(Players.GetLocalPlayer()))
	if(hData){
		return StringTable2Table(hData)
	}
}

GameUI.ForceTooltip = function(hInfo){
	var sTooltipName
	var CustomTooltipArea
	var NTData = GetNTData()
	var bNew

	if(hInfo){
		sTooltipName = hInfo.sTooltipName
		CustomTooltipArea = hInfo.CustomTooltipArea
		bNew = hInfo.bNew
	}else if(Game.CustomTooltip){
		sTooltipName = Game.CustomTooltip.sLastTooltip
		CustomTooltipArea = Game.CustomTooltip.CustomTooltipArea
		bNew = Game.CustomTooltip.bNew
	}
	if(sTooltipName != null && sTooltipName != undefined && sTooltipName != ''){
		Game.sTooltipName_fTooltip[sTooltipName](CustomTooltipArea, sTooltipName, hGameConst, NTData, bNew)
	}
}



GameUI.RefreshNTFunc = function(NTData){
	if(Game.CustomTooltip.FuncTimer){
		if(Game.CustomTooltip.bIsTooltipAlive){
			var sTooltipName = Game.CustomTooltip.sLastTooltip
			var CustomTooltipArea = Game.CustomTooltip.CustomTooltipArea
			NTData = NTData || GetNTData()
			var bAlt = GameUI.IsAltDown()

			Game.CustomTooltip.FuncTimer(CustomTooltipArea, sTooltipName, hGameConst, NTData, bAlt)
		}else{
			//Game.CustomTooltip.FuncTimer = null
		}
	}
}




var SetVisionPanel = (
	function(Panel, bAlt){
		//$.Msg(Panel)
		if(bAlt){
			Panel.style.visibility = "visible"
		}else{
			Panel.style.visibility = "collapse"
		}
	}
);
var PanelVisionUpdate = (
	function(Area, bAltDecription){
		var Handler =(
			function(Area, sPanelType){
				if(Area["Label" + sPanelType].text == ""){
					Area["Panel" + sPanelType].style.visibility = "collapse"
				}else{
					Area["Panel" + sPanelType].style.visibility = "visible"
				}
			}
		);
		Handler(Area, "Title")
		Handler(Area, "Behavior")
		Handler(Area, "Description")
		Handler(Area, "Stats")
		Handler(Area, "Alt")
		if(!bAltDecription){
			Area["PanelAlt"].style.visibility = "collapse"
		}
		Handler(Area, "Lore")
	}
);
var Tr = (
	function(sText){
		return $.Localize(sText)
	}
);

var It = (	//Interpletetor
	function(hDataValue, NTData, bAltDecription, nFix, nfactor){
		var sScrollText = ""    //Текст, формирующиеся из hDataValue
		var f = (
			function(nNumber){
				if(nNumber == Infinity){
					return Tr('SignInfinity')
				}
				if(nFix != null){
					if(nfactor != null){
						return parseFloat(nNumber * nfactor).toFixed(nFix)
					}
					return parseFloat(nNumber).toFixed(nFix)
				}
				return nNumber
			}
		);
		var getAbsLevel = (
			function(hDataValue, NTData){
				var factor = hDataValue.factor
				if(factor && NTData && NTData.sLevelName_hLevels){
					var nBaseLevel = NTData.sLevelName_hLevels[factor].base || 0	
					var nAddLevel = NTData.sLevelName_hLevels[factor].add || 0
					return Math.max(nBaseLevel + nAddLevel, 0) //--нельзя возвратить значение ниже 1 уровня
				}
				return null
			}
		);

		if(typeof hDataValue == 'string' || typeof hDataValue == 'number' ){
			sScrollText = f(Number(hDataValue))
    }else{
			if(typeof hDataValue == 'object'){
				var nLevel = getAbsLevel(hDataValue, NTData) || 0
				if(nLevel == null){
					//return f(hDataValue.first || hDataValue[1])
				}
				var bAlt = bAltDecription
				if(nLevel == 0){bAlt = true}
				if(bAlt){
					if(hDataValue.first != undefined){
						//арифметический тип
						var first = hDataValue.first
						var gain = hDataValue.gain || 0
						var sZnak = '+'
						if(gain < 0){sZnak = ''} //Минус и так у числа будет
						sScrollText = "(" + f(first) + " -> " + f(first + (gain * (9 - 1))) + ")(" + sZnak + f(gain) + ")"
					}else{
						//перечисление
						for(var g=1; g <= 9; g++){    //Перебираем все уровни способности
							if(nLevel == g){
								sScrollText = sScrollText + "|" + f(hDataValue[g]) + "|"
							}else{
								sScrollText = sScrollText + f(hDataValue[g])
							}
							if(g != 9){
								sScrollText = sScrollText + "/"
							}
						}
					}
				}else{
					//Not Alt Type
					if(hDataValue.first != undefined){
							var first = hDataValue.first
							var gain = hDataValue.gain || 0
							sScrollText = f(first + (gain * (nLevel - 1)))
					}else{
							sScrollText = f(hDataValue[nLevel])
					}
				}
			}
		}
		return sScrollText
	}
);
var InitPanelTitleLevel = (
	function(PanelParent){
		var panel = Block("Panel", PanelParent, null, "PanelTitleLevel")
		panel.BLoadLayoutSnippet("DefaultTitleLevel")
		return panel
	}
);
var AddPanelFactor = (
	function(PanelTitleLevel, factor, sAbilImage, sBlockName){
		var panel = Block("Panel", PanelTitleLevel, null, sBlockName)
		panel.BLoadLayoutSnippet("DefaultPanelLevel")
		if(typeof factor == 'number'){
			switch(factor) {
			case 1:
				factor = "invoker_quantum"
				break
			case 2:
				factor = "invoker_warp"
				break
			case 3:
				factor = "invoker_expanse"
				break
			case 4:
				factor = "invoker_reconstruction"
				break
			}
		}
		panel.factor = factor
		panel.FindChildTraverse("ImageLevel").abilityname = sAbilImage || factor

		return panel
	}
);
var SetPanelFactor = (
	function(panel, NTData, bAlt){
		//if(!panel){return}
		var nBaseLevel = 0
		var nAddLevel = 0
		if(NTData && NTData.sLevelName_hLevels){
			nBaseLevel = NTData.sLevelName_hLevels[panel.factor].base || 0
			nAddLevel = NTData.sLevelName_hLevels[panel.factor].add || 0
		}

		var labelADD = panel.FindChildTraverse("LabelAddAbilityLevel")

		//красиво покрасим ADD:
		var sSign = "+ "	//почему то приходится сохранять отдельно, так как измениние типа nAddLevel влечёт за собой не работу SetVisionPanel() функции
		if(nAddLevel < 0){
			/*if(labelADD.BHasClass("AddPlus")){
				labelADD.RemoveClass("AddPlus")
			}
			if(!labelADD.BHasClass("AddMinus")){
				labelADD.AddClass("AddMinus")	
			}*/
			
			if(labelADD.BHasClass("AddPlus")){
				labelADD.RemoveClass("AddPlus")
				labelADD.AddClass("AddMinus")
			}
			sSign = "- "
			nAddLevel = -nAddLevel
		}else{
			/*if(labelADD.BHasClass("AddMinus")){
				labelADD.RemoveClass("AddMinus")	
			}
			if(!labelADD.BHasClass("AddPlus")){
				labelADD.AddClass("AddPlus")
			}*/
			if(labelADD.BHasClass("AddMinus")){
				labelADD.RemoveClass("AddMinus")
				labelADD.AddClass("AddPlus")
			}
		}

		//присвоим значения
		panel.FindChildTraverse("LabelAbilityLevelByHero").text = nBaseLevel
		labelADD.text = sSign + nAddLevel
		
		var bVision = bAlt
		if(nAddLevel != 0){
			bVision = true
		}
		SetVisionPanel(labelADD, bVision)
	}
);
var AddStatBlock = (
	function(PanelStats, sCapion, sMeasure, nSphereClassNumber, sClassCaption, sBlockName){
		var panel = Block("Panel", PanelStats, null, sBlockName)
		panel.BLoadLayoutSnippet("DefaultStatsBlock")

		panel.FindChildTraverse("LabelCapion").text = sCapion
		if(sClassCaption != null){
			panel.FindChildTraverse("LabelCapion").AddClass(sClassCaption)
			panel.FindChildTraverse("LabelMeasure").AddClass(sClassCaption)
		}else{
			panel.FindChildTraverse("LabelCapion").AddClass("LabelStats")
			panel.FindChildTraverse("LabelMeasure").AddClass("LabelStats")
		}
		
		if(nSphereClassNumber == null){
			nSphereClassNumber = "Const"
		}

		panel.FindChildTraverse("PanelShell").AddClass("DefaultShell_" + nSphereClassNumber)
		panel.FindChildTraverse("LabelMeasure").text = sMeasure
		return panel
	}
);
var AddFormulaBlock = (
	function(sTooltipName){
		var panel = Block("Panel", PanelStats, null, sBlockName)
	}
);
var AddImageBlock = (
	function(Parent, sPreText, sImage, sPostText, sBlockName){
		var panel = Block("Panel", Parent, null, sBlockName)
		panel.BLoadLayoutSnippet("DefaultImageBlock")

		var LabelPreText = panel.FindChildTraverse("PanelPreText").FindChildTraverse("LabelCapion")
		var LabelPostText = panel.FindChildTraverse("PanelPostText").FindChildTraverse("LabelCapion")
		
		LabelPreText.text = sPreText
		LabelPostText.text = sPostText

		panel.FindChildTraverse("AbilImage").abilityname = sImage

		return panel
	}
);

var ApplyTimer = (
	function(nTimeStep, func, bNTRefresh, bSkipNilNTData){
		if(Game.CustomTooltip.nTimer == 0){
			Game.CustomTooltip.FuncTimer = func
			Game.CustomTooltip.bNTRefresh = true	//Обновление по изменению таблицы
			var TimerFuncСondition = (
				function(){
					if(!Game.CustomTooltip.bIsTooltipAlive){
						Game.CustomTooltip.nTimer = 0
						Game.CustomTooltip.FuncTimer = null
						Game.CustomTooltip.bNTRefresh = false
						return
					}

					if(Game.CustomTooltip.FuncTimer != null){
						var NTData = GetNTData()
						if(!bSkipNilNTData || NTData){
							var sTooltipName = Game.CustomTooltip.sLastTooltip
							var CustomTooltipArea = Game.CustomTooltip.CustomTooltipArea
							
							var bAlt = GameUI.IsAltDown()
							Game.CustomTooltip.FuncTimer(CustomTooltipArea, sTooltipName, hGameConst, NTData, bAlt)
						}
					}
					Game.CustomTooltip.nTimer = $.Schedule(nTimeStep, TimerFuncСondition)
				}
			);
			TimerFuncСondition()
		}
	}
);
var s = " "	//space
var ss = s+s
var tab =  "   "
var n = "\n"
var p = "/"	//per































































/*function Constructor(){
	var CustomTooltipArea = Game.CustomTooltip.CustomTooltipArea
	var sTooltipName = Game.CustomTooltip.sLastTooltip
	hGameConst
	var NTData= GetNTData()
	var bAlt = GameUI.IsAltDown()

	
	$.Msg('Area = ', Area)
}*/
var nDefaultTick = 0.05

function InitTooltipsClassic(){
	//hGameConst = data
	$.Msg('InitTooltipsClassic')
	Game.sTooltipName_fTooltip = {
		invoker_quantum: (
			function(Area, sThis, hGameConst, NTData, bNew){	//Area = hCustomTooltip
				//Area.style.width = "280px"
				Area.style.maxWidth = "385px"

				sThis = 'quantum'
				var bAlt = GameUI.IsAltDown()
				if(bNew){
					Area.Title = SuppBlock(Area, "Title", true, bAlt)
					Area.Title.label.text = Tr("DOTA_Tooltip_ability_invoker_quantum"); Area.Title.label.style.color = Tr("Tooltip_Font_Color_Quantum")
					Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
					Area.Title.PanelTitleQuantumLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 1)

					Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
					Area.Behavior.label.text = Tr("Ability:")+s+Tr("FlashSpellType")+", "+Tr("Switchable");

					Area.Description = SuppBlock(Area, "Description", true, bAlt)
					Area.Description.label.text = Tr("DOTA_Tooltip_ability_invoker_quantum_Description");

					Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
					Area.Stats.LabelPassively = AddStatDescription(Area.Stats, Tr("Passively:"))
						Area.Stats.PanelStrength = AddStatBlock(Area.Stats, tab+Tr("AddHP"), Tr("OneMeasure"), hGameConst[sThis].nHealth.factor)
						Area.Stats.PanelAttackTime = AddStatBlock(Area.Stats, tab+Tr("DOTA_Tooltip_ability_invoker_quantum_AttackTimeReduction"), Tr("sec"), hGameConst[sThis].nAttackTime.factor)
					_n(Area.Stats)
					Area.Stats.LabelPassivelySphere = AddStatDescription(Area.Stats, Tr("Passively_for_each_sphere:"))
						Area.Stats.PanelRegen = AddStatBlock(Area.Stats, tab+Tr("AddHPRegen"), Tr("OneMeasure")+p+Tr("sec"), hGameConst[sThis].nHealthRegen.factor)
					_n(Area.Stats)
					Area.Stats.LabelActive = AddStatDescription(Area.Stats, Tr("AltUse:"))
						Area.Stats.LabelActiveDescription = AddStatDescription(Area.Stats, tab+Tr("Spheres_AltUse"))

					Area.Alt = SuppBlock(Area, "Alt", true, bAlt)
					Area.Alt.label.text = Tr("DOTA_Tooltip_ability_invoker_quantum_Note0")

					Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
					Area.Lore.label.text = Tr("DOTA_Tooltip_ability_invoker_quantum_Lore")
				}
				var RefreshFunc = function(Area, sTooltipName, hGameConst, NTData, bAlt){
					SetPanelFactor(Area.Title.PanelTitleQuantumLevel, NTData, bAlt)
					Area.Stats.PanelStrength.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nHealth, NTData, bAlt);
					Area.Stats.PanelAttackTime.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nAttackTime, NTData, bAlt, 1);
					Area.Stats.PanelRegen.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nHealthRegen, NTData, bAlt, 2);
					SetVisionPanel(Area.Alt, bAlt)
					$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false, true)
			}
		),
		
			invoker_quantum_spherebuff: (
				function(Area, sThis, hGameConst, NTData, bNew){
					var bAlt = GameUI.IsAltDown()
					sThis = 'quantum'
					if(bNew){
						Area.Title = SuppBlock(Area, "Title", true, bAlt)
						Area.Title.label.text = Tr("DOTA_Tooltip_invoker_quantum_spherebuff"); Area.Title.label.style.color = Tr("Tooltip_Font_Color_Quantum")
						Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
						Area.Title.PanelTitleQuantumLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 1)
	
						Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr("DOTA_Tooltip_invoker_quantum_spherebuff_Description");
	
						Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
						Area.Stats.LabelBuff = AddStatDescription(Area.Stats, Tr('Buff'))
							Area.Stats.LabelBuffPurgeStat = AddStatDescription(Area.Stats, [{sText: tab+Tr("PurgeFALSE"), sClassLabel: "DefaultStatsRed"}])
							Area.Stats.PanelDuration = AddStatBlock(Area.Stats, tab+Tr("Duration"), Tr("sec"), hGameConst[sThis].nSphereDuration.factor)
							_n(Area.Stats)
							Area.Stats.LabelBuffEffect = AddStatDescription(Area.Stats, tab+Tr("BuffEffect"))
								Area.Stats.PanelRegen = AddStatBlock(Area.Stats, tab+tab+Tr("AddHPRegen"), Tr("OneMeasure")+p+Tr("sec"), hGameConst[sThis].nHealthRegen.factor)

						Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr("DOTA_Tooltip_invoker_quantum_spherebuff_Lore")
					}
					
					var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
						sThis = 'quantum'
						var bAlt = GameUI.IsAltDown()
						SetPanelFactor(Area.Title.PanelTitleQuantumLevel, NTData, bAlt)
						Area.Stats.PanelDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nSphereDuration, NTData, bAlt, 1)
						Area.Stats.PanelRegen.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nHealthRegen, NTData, bAlt, 2);
						$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
					}
					ApplyTimer(nDefaultTick, RefreshFunc, false, true)
				}
			),


		invoker_warp: (
			function(Area, sThis, hGameConst, NTData, bNew){
				Area.style.maxWidth = "330px"

				sThis = 'warp'
				var bAlt = GameUI.IsAltDown()
				if(bNew){
					Area.Title = SuppBlock(Area, "Title", true, bAlt)
					Area.Title.label.text = Tr("DOTA_Tooltip_ability_invoker_warp"); Area.Title.label.style.color = Tr("Tooltip_Font_Color_Warp")
				
					Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
					Area.Title.PanelTitleWarpLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 2)

					Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
					Area.Behavior.label.text = Tr("Ability:")+s+Tr("FlashSpellType")+", "+Tr("Switchable");

					Area.Description = SuppBlock(Area, "Description", true, bAlt)
					Area.Description.label.text = Tr("DOTA_Tooltip_ability_invoker_warp_Description");

					Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
					Area.Stats.LabelPassively = AddStatDescription(Area.Stats, Tr("Passively:"))
						Area.Stats.PanelIntelegence = AddStatBlock(Area.Stats, tab+Tr("AddMP"), Tr("OneMeasure"), hGameConst[sThis].nMana.factor)
					_n(Area.Stats)
					Area.Stats.LabelPassivelySphere = AddStatDescription(Area.Stats, Tr("Passively_for_each_sphere:"))
						Area.Stats.PanelRegen = AddStatBlock(Area.Stats, tab+Tr("AddMPRegen"), Tr("OneMeasure")+p+Tr("sec"), hGameConst[sThis].nManaRegen.factor)
					_n(Area.Stats)
					Area.Stats.LabelActive = AddStatDescription(Area.Stats, Tr("AltUse:"))
						Area.Stats.LabelActiveDescription = AddStatDescription(Area.Stats, tab+Tr("Spheres_AltUse"))

					Area.Alt = SuppBlock(Area, "Alt", true, bAlt)
					Area.Alt.label.text = Tr("DOTA_Tooltip_ability_invoker_warp_Note0")

					Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
					Area.Lore.label.text = Tr("DOTA_Tooltip_ability_invoker_warp_Lore")
				}
				var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
					sThis = 'warp'
					var bAlt = GameUI.IsAltDown()
					SetPanelFactor(Area.Title.PanelTitleWarpLevel, NTData, bAlt)
					Area.Stats.PanelIntelegence.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nMana, NTData, bAlt);
					Area.Stats.PanelRegen.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nManaRegen, NTData, bAlt, 2);
					//Area.Stats.PanelForseSwap.FindChildTraverse("LabelValue").text = It(hGameConst.quantum.nForseSwap, NTData, bAlt, 2, 100);
					SetVisionPanel(Area.Alt, bAlt)
					$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false, true)
			}
		),










			invoker_warp_spherebuff: (
				function(Area, sThis, hGameConst, NTData, bNew){
					var bAlt = GameUI.IsAltDown()
					var sThis = 'warp'
					if(bNew){
						Area.Title = SuppBlock(Area, "Title", true, bAlt)
						Area.Title.label.text = Tr("DOTA_Tooltip_invoker_warp_spherebuff"); Area.Title.label.style.color = Tr("Tooltip_Font_Color_Warp")
					
						Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
						Area.Title.PanelTitleWarpLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 2)
	
						Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
						Area.Behavior.label.text = Tr("Ability:")+s+Tr("FlashSpellType")+", "+Tr("Switchable");
	
						Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr("DOTA_Tooltip_invoker_warp_spherebuff_Description");
	
						Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
						
						Area.Stats.LabelBuff = AddStatDescription(Area.Stats, Tr('Buff'))
							Area.Stats.LabelBuffPurgeStat = AddStatDescription(Area.Stats, [{sText: tab+Tr("PurgeFALSE"), sClassLabel: "DefaultStatsRed"}])
							Area.Stats.PanelDuration = AddStatBlock(Area.Stats, tab+Tr("Duration"), Tr("sec"), hGameConst[sThis].nSphereDuration.factor)
							_n(Area.Stats)
							Area.Stats.LabelBuffEffect = AddStatDescription(Area.Stats, tab+Tr("BuffEffect"))
								Area.Stats.PanelRegen = AddStatBlock(Area.Stats, tab+tab+Tr("AddMPRegen"), Tr("OneMeasure")+p+Tr("sec"), hGameConst[sThis].nManaRegen.factor)
											

						Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr("DOTA_Tooltip_invoker_warp_spherebuff_Lore")
					}
					
					var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
						sThis = 'warp'
						SetPanelFactor(Area.Title.PanelTitleWarpLevel, NTData, bAlt)
						Area.Stats.PanelDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nSphereDuration, NTData, bAlt, 1)
						Area.Stats.PanelRegen.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nManaRegen, NTData, bAlt, 2);
						$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
					}
					ApplyTimer(nDefaultTick, RefreshFunc, false, true)
				}
			),















		invoker_expanse: (
			function(Area, sThis, hGameConst, NTData, bNew){
				sThis = 'expanse'
				var bAlt = GameUI.IsAltDown()
				if(bNew){
					Area.Title = SuppBlock(Area, "Title", true, bAlt)
					Area.Title.label.text = Tr("DOTA_Tooltip_ability_invoker_expanse"); Area.Title.label.style.color = Tr("Tooltip_Font_Color_Expanse")
				
					Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
					Area.Title.PanelTitleExpanseLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 3)

					Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
					Area.Behavior.label.text = Tr("Ability:")+s+Tr("FlashSpellType")+", "+Tr("Switchable");

					Area.Description = SuppBlock(Area, "Description", true, bAlt)
					Area.Description.label.text = Tr("DOTA_Tooltip_ability_invoker_expanse_Description");

					Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
					Area.Stats.LabelPassively = AddStatDescription(Area.Stats, Tr("Passively:"))
						Area.Stats.PanelAttackPoint = AddStatBlock(Area.Stats, tab+Tr("DOTA_Tooltip_ability_invoker_expanse_AttackPointReduction"), Tr("sec"), hGameConst[sThis].nAttackAnimationTime.factor)
						Area.Stats.PanelMoveSpeed = AddStatBlock(Area.Stats, tab+Tr("AddMovespeed"), Tr("OneMeasure")+p+Tr("sec"), hGameConst[sThis].nMoveSpeed.factor)
						Area.Stats.PanelVisionRange = AddStatBlock(Area.Stats, tab+Tr("AddVisionRange"), Tr("OneMeasure"), hGameConst[sThis].nVision.factor)
					_n(Area.Stats)
					Area.Stats.LabelPassivelySphere = AddStatDescription(Area.Stats, Tr("Passively_for_each_sphere:"))
						Area.Stats.PanelDamage = AddStatBlock(Area.Stats, tab+Tr("AddDamage"), Tr("OneMeasure"), hGameConst[sThis].nDamagePerSphere.factor)
							Area.Stats.LabelBuffEffectAttack = AddStatDescription(Area.Stats, [{sText: tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePhysical"), sClassLabel: "DefaultStatsDamageTypePhysical"}])
					_n(Area.Stats)
					Area.Stats.LabelActive = AddStatDescription(Area.Stats, Tr("AltUse:"))
						Area.Stats.LabelActiveDescription = AddStatDescription(Area.Stats, tab+Tr("Spheres_AltUse"))

					Area.Alt = SuppBlock(Area, "Alt", true, bAlt)
					Area.Alt.label.text = Tr("DOTA_Tooltip_ability_invoker_expanse_Note0")

					Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
					Area.Lore.label.text = Tr("DOTA_Tooltip_ability_invoker_expanse_Lore")
				}
				var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
					sThis = 'expanse'
					SetPanelFactor(Area.Title.PanelTitleExpanseLevel, NTData, bAlt)
					Area.Stats.PanelAttackPoint.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nAttackAnimationTime, NTData, bAlt, 3)
					Area.Stats.PanelMoveSpeed.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nMoveSpeed, NTData, bAlt);
					Area.Stats.PanelVisionRange.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nVision, NTData, bAlt);
					Area.Stats.PanelDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDamagePerSphere, NTData, bAlt);
					//Area.Stats.PanelForseSwap.FindChildTraverse("LabelValue").text = It(hGameConst.quantum.nForseSwap, NTData, bAlt, 2, 100);
					SetVisionPanel(Area.Alt, bAlt)
					$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false, true)
			}
		),




		






			invoker_expanse_spherebuff: (
				function(Area, sThis, hGameConst, NTData, bNew){sThis = 'expanse'
					Area.style.width = "250px"
					var bAlt = GameUI.IsAltDown()
					if(bNew){
						Area.Title = SuppBlock(Area, "Title", true, bAlt)

						Area.Title.label.text = Tr("DOTA_Tooltip_invoker_expanse_spherebuff"); Area.Title.label.style.color = Tr("Tooltip_Font_Color_Expanse")
						Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
						Area.Title.PanelTitleExpanseLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 3)
	
						Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr("DOTA_Tooltip_invoker_expanse_spherebuff_Description");

						Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
						Area.Stats.LabelBuff = AddStatDescription(Area.Stats, Tr('Buff'))
							Area.Stats.LabelBuffPurgeStat = AddStatDescription(Area.Stats, [{sText: tab+Tr("PurgeFALSE"), sClassLabel: "DefaultStatsRed"}])
							Area.Stats.PanelDuration = AddStatBlock(Area.Stats, tab+Tr("Duration"), Tr("sec"), hGameConst[sThis].nSphereDuration.factor)
							_n(Area.Stats)
							Area.Stats.LabelBuffEffect = AddStatDescription(Area.Stats, tab+Tr("BuffEffect"))
								Area.Stats.PanelDamage = AddStatBlock(Area.Stats, tab+tab+Tr("AddDamage"), Tr("OneMeasure"), hGameConst[sThis].nDamagePerSphere.factor)
									Area.Stats.LabelBuffEffectAttack = AddStatDescription(Area.Stats, [{sText: tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePhysical"), sClassLabel: "DefaultStatsDamageTypePhysical"}])
						
						Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr("DOTA_Tooltip_invoker_expanse_spherebuff_Lore")
					}
					
					var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){sThis = 'expanse'
						SetPanelFactor(Area.Title.PanelTitleExpanseLevel, NTData, bAlt)
						Area.Stats.PanelDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nSphereDuration, NTData, bAlt, 1)
						Area.Stats.PanelDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDamagePerSphere, NTData, bAlt);
						$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
					}
					ApplyTimer(nDefaultTick, RefreshFunc, false, true)
				}
			),

		invoker_forge_spirits: (
			function(Area, sThis, hGameConst, NTData, bNew){
				$.Msg(sThis,':Tooltip')
				var bAlt = GameUI.IsAltDown()
				if(bNew){	
					Area.style.maxWidth = "420px"
					Area.Title = SuppTitleBlock(Area, sThis, Tr("DOTA_Tooltip_ability_"+sThis), [null, true, null, true], true)

					Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
						Area.Behavior.label.text = Tr("Ability:")+s+Tr("FlashSpellType");
						//Area.Behavior.Targets = AddStatDescription(Area.Behavior, [{sText: Tr("Targets")+s+Tr("OrganicСreatures"), sClassLabel: "LabelBehavior"}])
						//Area.Behavior.CastRange = AddStatBlock(Area.Behavior, Tr("CastRange"), Tr("OneMeasure"), hGameConst.invoker_alacrity_of_zecora.nCastRange.factor, "LabelBehavior")
						Area.Behavior.CastAnimation = AddStatBlock(Area.Behavior, Tr("CastAnimation"), Tr("sec"), hGameConst[sThis].nCastPoint.factor, "LabelBehavior")

					Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr("DOTA_Tooltip_ability_"+sThis+"_Description");

					Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
						Area.Stats.PanelCountCreature = AddStatBlock(Area.Stats, Tr("CountCreatures"), Tr("items"), hGameConst[sThis].nCountCreatures.factor)
						Area.Stats.PanelСreature = AddStatDescription(Area.Stats, Tr("Сreature")+s+Tr("DOTA_Tooltip_ability_"+sThis)+":")
							Area.Stats.PanelDuration = AddStatBlock(Area.Stats, tab+Tr("LifeTime"), Tr("sec"), hGameConst[sThis].nDuration.factor)
							
							Area.Stats.PanelHP = AddStatBlock(Area.Stats, tab+Tr("Hp"), Tr("OneMeasure"), hGameConst[sThis].nHPMax.factor)
							Area.Stats.PanelMP = AddStatBlock(Area.Stats, tab+Tr("Mp"), Tr("OneMeasure"), hGameConst[sThis].nMPMax.factor)
							Area.Stats.PanelArmorPhysical = AddStatBlock(Area.Stats, tab+Tr("ArmorPhys"), Tr("OneMeasure"), hGameConst[sThis].nArmorPhysical.factor)
							Area.Stats.PanelMagicalResistance = AddStatBlock(Area.Stats, tab+Tr("MagicResist"), "%", hGameConst[sThis].nMagicResist.factor)
							Area.Stats.PanelBountyXP = AddStatBlock(Area.Stats, tab+Tr("BountyXP"), Tr("OneMeasure"), null)
							Area.Stats.PanelVisionRange = AddStatBlock(Area.Stats, tab+Tr("VisionRange"), Tr("OneMeasure"), null)
							Area.Stats.PanelTurnRate = AddStatBlock(Area.Stats, tab+Tr("TurnRate"), Tr("RadPerSec"), null)

							Area.Stats.PanelTypeAttack = AddStatDescription(Area.Stats, tab+Tr("TypeAttack")+s+Tr("TypeAttackRange"))
								Area.Stats.PanelTypeDamage = AddStatDescription(Area.Stats, [{sText: tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePhysical"), sClassLabel: "DefaultStatsDamageTypePhysical"}])
								Area.Stats.PanelBaseDamage = AddStatBlock(Area.Stats, tab+tab+Tr("Damage"), Tr("OneMeasure"), hGameConst[sThis].nBaseDamage.factor)
								Area.Stats.PanelTowerDamage = AddStatBlock(Area.Stats, tab+tab+Tr("TowerDamage"), Tr("OneMeasure"), null)
								Area.Stats.PanelProjectileSpeed = AddStatBlock(Area.Stats, tab+tab+Tr("ProjectileSpeed"),Tr("OneMeasure")+p+Tr("sec"), null)
								Area.Stats.PanelBaseAttackTime = AddStatBlock(Area.Stats, tab+tab+Tr("BaseAttackTime"), Tr("sec"), hGameConst[sThis].nBaseAttackSpeedTime.factor)
								Area.Stats.PanelAnimationPoint = AddStatBlock(Area.Stats, tab+tab+Tr("AnimationPoint"), Tr("sec"), null)

							//Area.Stats.PanelSpells = AddStatDescription(Area.Stats, tab+Tr("Spells"))


					Area.Alt = SuppBlock(Area, "Alt", true, bAlt)
						Area.Alt.label.text = Tr("DOTA_Tooltip_ability_"+sThis+"_Note0")

					Area.Req = SuppRequirementBlock(Area, hGameConst[sThis], NTData)

					Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr("DOTA_Tooltip_ability_"+sThis+"_Lore")
				}

				var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
					var hThisUnit = npc.units.npc_invoker_forge_spirit
					SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[1], NTData, bAlt)
					SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[3], NTData, bAlt)
						
					//SetVisionPanel(Area.Behavior.CastAnimation, bAlt)
					Area.Behavior.CastAnimation.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nCastPoint, NTData, bAlt)
					
					Area.Stats.PanelCountCreature.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nCountCreatures, NTData, bAlt)
					Area.Stats.PanelDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDuration, NTData, bAlt)

					Area.Stats.PanelHP.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nHPMax, NTData, bAlt)
					Area.Stats.PanelMP.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nMPMax, NTData, bAlt)
					Area.Stats.PanelArmorPhysical.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nArmorPhysical, NTData, bAlt)
					Area.Stats.PanelMagicalResistance.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nMagicResist, NTData, bAlt)
					//SetVisionPanel(Area.Stats.PanelBountyXP, bAlt)
					Area.Stats.PanelBountyXP.FindChildTraverse("LabelValue").text = It(hThisUnit.BountyXP, NTData, bAlt, 0)
					//SetVisionPanel(Area.Stats.PanelVisionRange, bAlt)
					Area.Stats.PanelVisionRange.FindChildTraverse("LabelValue").text = It(hThisUnit.VisionDaytimeRange, NTData, bAlt, 0)
					//SetVisionPanel(Area.Stats.PanelTurnRate, bAlt)
					Area.Stats.PanelTurnRate.FindChildTraverse("LabelValue").text = It(hThisUnit.MovementTurnRate, NTData, bAlt, 1)

					//SetVisionPanel(Area.Stats.PanelTypeDamage, bAlt)
					Area.Stats.PanelBaseDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nBaseDamage, NTData, bAlt)
					//SetVisionPanel(Area.Stats.PanelTowerDamage, bAlt)
					Area.Stats.PanelTowerDamage.FindChildTraverse("LabelValue").text = "1"
					//SetVisionPanel(Area.Stats.PanelProjectileSpeed, bAlt)
					Area.Stats.PanelProjectileSpeed.FindChildTraverse("LabelValue").text = It(hThisUnit.AttackAcquisitionRange, NTData, bAlt, 0)
					Area.Stats.PanelBaseAttackTime.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nBaseAttackSpeedTime, NTData, bAlt, 1)		
					//SetVisionPanel(Area.Stats.PanelAnimationPoint, bAlt)
					Area.Stats.PanelAnimationPoint.FindChildTraverse("LabelValue").text = It(hThisUnit.AttackAnimationPoint, NTData, bAlt, 1)

					SetVisionPanel(Area.Alt, bAlt)
					RequirementBlockRefresh(Area.Req, hGameConst[sThis], NTData, bAlt)
					$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false)
				$.Msg(sThis, ':Tooltip loaded')
			}
		),












		invoker_alacrity_of_zecora: (
			function(Area, sThis, hGameConst, NTData, bNew){
				var bAlt = GameUI.IsAltDown()
				if(bNew){	
					Area.style.maxWidth = "420px"
					Area.Title = SuppTitleBlock(Area, "invoker_alacrity_of_zecora", Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora"), [null, null, true, true], true)

					Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
						Area.Behavior.label.text = Tr("Ability:")+s+Tr("UnitTarget");
						Area.Behavior.Targets = AddStatDescription(Area.Behavior, [{sText: Tr("Targets")+s+Tr("OrganicСreatures"), sClassLabel: "LabelBehavior"}])
						Area.Behavior.CastRange = AddStatBlock(Area.Behavior, Tr("CastRange"), Tr("OneMeasure"), hGameConst[sThis].nCastRange.factor, "LabelBehavior")
						Area.Behavior.CastAnimation = AddStatBlock(Area.Behavior, Tr("CastAnimation"), Tr("sec"), hGameConst[sThis].nCastPoint.factor, "LabelBehavior")

					Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Description");

					Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
					Area.Stats.ImageBuff = AddImageBlock(Area.Stats, Tr('DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Apply_Buff'), hGameConst[sThis].sBuffTextureName, Tr('DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Buff')+':')
						Area.Stats.LabelBuffPurgeStat = AddStatDescription(Area.Stats, [{sText: tab+Tr("PurgeTRUE"), sClassLabel: "DefaultStatsGreen"}])
						Area.Stats.PanelDuration = AddStatBlock(Area.Stats, tab+Tr("Duration"), Tr("sec"), hGameConst[sThis].nDuration.factor)
						_n(Area.Stats)
						Area.Stats.LabelBuffEffect = AddStatDescription(Area.Stats, tab+Tr("BuffEffect"))
							Area.Stats.PanelInOutDamage = AddStatBlock(Area.Stats, tab+tab+Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_InOut_damage"), "%", hGameConst[sThis].nInDamagePercent.factor)
								Area.Stats.LabelBuffEffectAttack = AddStatDescription(Area.Stats, [{sText: tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePure"), sClassLabel: "DefaultStatsDamageTypePure"}])
							Area.Stats.LabelEffectAttack = AddStatDescription(Area.Stats, tab+tab+Tr("EffectAttack"))
								Area.Stats.PanelDamage = AddStatBlock(Area.Stats, tab+tab+tab+Tr("AddDamage"), Tr("OneMeasure"), hGameConst[sThis].nDamage.factor)
									Area.Stats.LabelBuffEffectAttack = AddStatDescription(Area.Stats, [{sText: tab+tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePhysical"), sClassLabel: "DefaultStatsDamageTypePhysical"}])
								
					Area.Alt = SuppBlock(Area, "Alt", true, bAlt)
						Area.Alt.label.text = Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Note0")

					Area.Req = SuppRequirementBlock(Area, hGameConst[sThis], NTData)

					Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Lore")
				}
				var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
					SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[2], NTData, bAlt)
					SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[3], NTData, bAlt)
						
					Area.Behavior.CastRange.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nCastRange, NTData, bAlt);
					Area.Behavior.CastAnimation.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nCastPoint, NTData, bAlt, 3);
					//SetVisionPanel(Area.Stats.LabelBuffPurgeStat, bAlt)
					Area.Stats.PanelDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDuration, NTData, bAlt);
					Area.Stats.PanelInOutDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nInDamagePercent, NTData, bAlt);
					//SetVisionPanel(Area.Stats.LabelBuffEffectAttack, bAlt)
					Area.Stats.PanelDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDamage, NTData, bAlt);
					
					SetVisionPanel(Area.Alt, bAlt)
					RequirementBlockRefresh(Area.Req, hGameConst[sThis], NTData, bAlt)
					$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false)
			}
		),





			invoker_alacrity_of_zecora_buff: (
				function(Area, sThis, hGameConst, NTData, bNew){sThis = 'invoker_alacrity_of_zecora'
					var bAlt = GameUI.IsAltDown()
					if(bNew){
						//Area.Title = SuppBlock(Area, "Title", true, bAlt)
						//Area.Title.label.text = Tr("DOTA_Tooltip_invoker_alacrity_of_zecora_buff");
						//Area.Title.PanelTitleLevel = InitPanelTitleLevel(Area.Title)
						//Area.Title.PanelTitleQuantumLevel = AddPanelFactor(Area.Title.PanelTitleLevel, 1)
						Area.Title = SuppTitleBlock(Area, sThis, Tr("DOTA_Tooltip_invoker_alacrity_of_zecora_buff"), [null, null, true, true], true)

						Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr("DOTA_Tooltip_invoker_alacrity_of_zecora_buff_Description");

						Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
						Area.Stats.LabelBuffEffect = AddStatDescription(Area.Stats, Tr("Buff"))
							Area.Stats.LabelBuffPurgeStat = AddStatDescription(Area.Stats, [{sText: tab+Tr("PurgeTRUE"), sClassLabel: "DefaultStatsGreen"}])
							Area.Stats.PanelDuration = AddStatBlock(Area.Stats, tab+Tr("Duration"), Tr("sec"), hGameConst[sThis].nDuration.factor)
							_n(Area.Stats)
							Area.Stats.LabelBuffEffect = AddStatDescription(Area.Stats, tab+Tr("BuffEffect"))
								Area.Stats.PanelInOutDamage = AddStatBlock(Area.Stats, tab+tab+Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_InOut_damage"), "%", hGameConst[sThis].nInDamagePercent.factor)
									Area.Stats.LabelBuffEffectAttack = AddStatDescription(Area.Stats, [{sText: tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePure"), sClassLabel: "DefaultStatsDamageTypePure"}])
								Area.Stats.LabelEffectAttack = AddStatDescription(Area.Stats, tab+tab+Tr("EffectAttack"))
									Area.Stats.PanelDamage = AddStatBlock(Area.Stats, tab+tab+tab+Tr("AddDamage"), Tr("OneMeasure"), hGameConst[sThis].nDamage.factor)
										Area.Stats.LabelBuffEffectAttack = AddStatDescription(Area.Stats, [{sText: tab+tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamagePhysical"), sClassLabel: "DefaultStatsDamageTypePhysical"}])

						Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr("DOTA_Tooltip_invoker_alacrity_of_zecora_buff_Lore")
					}
					
					var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){sThis = 'invoker_alacrity_of_zecora'
						SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[2], NTData, bAlt)
						SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[3], NTData, bAlt)
							
						Area.Stats.PanelDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDuration, NTData, bAlt);
						Area.Stats.PanelInOutDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nInDamagePercent, NTData, bAlt);
						Area.Stats.PanelDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDamage, NTData, bAlt);

						$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
					}
					ApplyTimer(nDefaultTick, RefreshFunc, false)
				}
			),





			/*
		base_tower_shield_modifier: (
			function(Area, sThis, hGameConst, NTData, bNew){


				var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
				
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false, true)
			}
		),*/

		invoker_fireBalls_hephaestus: (
			function(Area, sThis, hGameConst, NTData, bNew){
				var bAlt = GameUI.IsAltDown()
				var sThisAbil = 'invoker_fireBalls_hephaestus'

				if(bNew){	
					Area.style.maxWidth = "600px"
					Area.Title = SuppTitleBlock(Area, sThis, Tr("DOTA_Tooltip_ability_" + sThis), [null, null, true, true], true)

					Area.Behavior = SuppBlock(Area, "Behavior", true, bAlt)
						Area.Behavior.label.text = Tr("Ability:")+s+Tr("PointTarget");
						Area.Behavior.Targets = AddStatDescription(Area.Behavior, [{sText: Tr("Targets")+s+Tr("OrganicСreatures"), sClassLabel: "LabelBehavior"}])
						Area.Behavior.CastRange = AddStatBlock(Area.Behavior, Tr("CastRange"), Tr("OneMeasure"), hGameConst[sThis].nCastRange.factor, "LabelBehavior")
						Area.Behavior.CastAnimation = AddStatBlock(Area.Behavior, Tr("CastAnimation"), Tr("sec"), hGameConst[sThis].nCastPoint.factor, "LabelBehavior")

					Area.Description = SuppBlock(Area, "Description", true, bAlt)
						Area.Description.label.text = Tr('DOTA_Tooltip_ability_'+sThis+'_Description');



					Area.Stats = SuppBlock(Area, "Stats", true, bAlt)
					Area.Stats.LabelRocket = AddStatDescription(Area.Stats, Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_Rocket_Launch'))
						Area.Stats.PanelRocketSpeed = AddStatBlock(Area.Stats, tab+Tr("RocketSpeed"), Tr('OneMeasure')+'/'+Tr('sec'), hGameConst[sThis].nMaxSpeed.factor)
						Area.Stats.LabelRocketNotReflected = AddStatDescription(Area.Stats, tab+Tr('NotReflected'))
					Area.Stats.LabelRocketReachesPoint = AddStatDescription(Area.Stats, Tr('ReachesPoint'))
						Area.Stats.LabelRocketRangePerPoint = AddStatDescription(Area.Stats, tab+Tr('RangePerPoint'))
							Area.Stats.LabelRocketTargets = AddStatDescription(Area.Stats, tab+tab+Tr('Targets')+s+Tr('Enemys')+s+Tr('OrganicСreatures')+', '+Tr('Trees'))
							Area.Stats.PanelRadius = AddStatBlock(Area.Stats, tab+tab+Tr("Radius"), Tr('OneMeasure'), hGameConst[sThis].nRadius.factor)
							_n(Area.Stats)
							Area.Stats.PanelDamage = AddStatBlock(Area.Stats, tab+tab+Tr("Deals")+Tr('Damage'), Tr("OneMeasure"), hGameConst[sThis].nDamage.factor)
								Area.Stats.LabelTypeHitDamage = AddStatDescription(Area.Stats, [{sText:tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamageMagic"), sClassLabel: "DefaultStatsDamageTypeMagic"}])
							Area.Stats.PanelDamagePerStack = AddStatBlock(Area.Stats, tab+tab+Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_DamageFactor'), "%", hGameConst[sThisAbil].nStackDamageFactor.factor)
							Area.Stats.PanelHitAddStaks = AddStatBlock(Area.Stats, tab+tab+Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_HitAddStacks'), "", hGameConst[sThisAbil].nHitStackCount.factor)
							Area.Stats.PanelCreateFire = AddStatBlock(Area.Stats, tab+tab+Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_CreateFire'), Tr('sec'), hGameConst[sThisAbil].nTimeLife.factor)
								Area.Stats.PanelFireVisionRange = AddStatBlock(Area.Stats, tab+tab+tab+Tr('VisionRange'), Tr('OneMeasure'), hGameConst[sThis].nFireVisionRange.factor)
								_n(Area.Stats)
								Area.Stats.ImageDebuffFlame = AddImageBlock(Area.Stats, tab+tab+tab+Tr('DeBuff'), hGameConst[sThis].sFlameTextureName, Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_Debuff_Flame')+':')
									Area.Stats.LabelDeBuffFlamePurgeStat = AddStatDescription(Area.Stats, [{sText: tab+tab+tab+tab+Tr("PurgeFALSE"), sClassLabel: "DefaultStatsRed"}])
									Area.Stats.LabelFlameTargets = AddStatDescription(Area.Stats, tab+tab+tab+tab+Tr('Targets')+s+Tr('Enemys')+s+Tr('OrganicСreatures'))
									Area.Stats.PanelFlameRadius = AddStatBlock(Area.Stats, tab+tab+tab+tab+Tr("Radius"), Tr('OneMeasure'), hGameConst[sThis].nFireRange.factor)
									_n(Area.Stats)
									Area.Stats.PanelFlameEvery = AddStatBlock(Area.Stats, tab+tab+tab+tab+Tr("Every"), Tr('sec')+':', hGameConst[sThis].nAuraIntervalThink.factor)
										Area.Stats.LabelApplyDebuff = AddStatDescription(Area.Stats, tab+tab+tab+tab+tab+Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_Apply_Debuff'))
					_n(Area.Stats)
					Area.Stats.ImageDebuffFire = AddImageBlock(Area.Stats, Tr('DeBuff'), hGameConst[sThis].sFireTextureName, Tr('DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_Debuff_Fire')+':')
						Area.Stats.LabelDeBuffFirePurgeStat = AddStatDescription(Area.Stats, [{sText: tab+Tr("PurgeTRUE"), sClassLabel: "DefaultStatsGreen"}])
						Area.Stats.PanelDeBuffFireDuration = AddStatBlock(Area.Stats, tab+Tr("Duration"), Tr('sec'), hGameConst[sThis].nBuffDuration.factor)
						Area.Stats.PanelDeBuffFireStackCount = AddStatBlock(Area.Stats, tab+Tr("MaxStackCount"), Tr('OneMeasure'), hGameConst[sThis].nMaxStacks.factor)
						
						_n(Area.Stats)
						Area.Stats.LabelDeBuffFireInvisible = AddStatDescription(Area.Stats, [{sText: tab+Tr("DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_Clear_Invisible"), sClassLabel: "DefaultStatsDamageTypePhysical"}])
						Area.Stats.LabelDeBuffFire = AddStatDescription(Area.Stats, tab+Tr('EveryDt'))
							Area.Stats.PanelDeBuffFireDamage = AddStatBlock(Area.Stats, tab+tab+Tr("DOTA_Tooltip_ability_invoker_fireBalls_hephaestus_DamagePerSec"), Tr('OneMeasure')+'/'+Tr('sec'), hGameConst[sThis].nDamagePerStack.factor)
								Area.Stats.LabelDeBuffFireTypeDamage = AddStatDescription(Area.Stats, [{sText:tab+tab+tab+Tr("TypeDamage")+s}, {sText: Tr("TypeDamageMagic"), sClassLabel: "DefaultStatsDamageTypeMagic"}])
					
						Area.Alt = SuppBlock(Area, "Alt", true, bAlt)
						Area.Alt.label.text = Tr('DOTA_Tooltip_ability_'+sThis+'_Note0')

					Area.Req = SuppRequirementBlock(Area, hGameConst[sThis], NTData)

					Area.Lore = SuppBlock(Area, "Lore", true, bAlt)
						Area.Lore.label.text = Tr('DOTA_Tooltip_ability_'+sThis+'_Lore')
				}

				var RefreshFunc = function(Area, sThis, hGameConst, NTData, bAlt){
					SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[2], NTData, bAlt)
					SetPanelFactor(Area.Title.PanelTitleLevel.PanelSphere[3], NTData, bAlt)
						

					Area.Behavior.CastRange.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nCastRange, NTData, bAlt);
					Area.Behavior.CastAnimation.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nCastPoint, NTData, bAlt, 2);
					
					Area.Stats.PanelRocketSpeed.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nMaxSpeed, NTData, bAlt)
					//SetVisionPanel(Area.Stats.LabelRocketNotReflected, bAlt)
					Area.Stats.PanelRadius.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nRadius, NTData, bAlt)
					//SetVisionPanel(Area.Stats.LabelTypeHitDamage, bAlt)
					Area.Stats.PanelDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDamage, NTData, bAlt)
					Area.Stats.PanelDamagePerStack.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nStackDamageFactor, NTData, bAlt, 0, 100)
					Area.Stats.PanelHitAddStaks.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nHitStackCount, NTData, bAlt)
					Area.Stats.PanelCreateFire.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nTimeLife, NTData, bAlt)
					Area.Stats.PanelFireVisionRange.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nFireVisionRange, NTData, bAlt)
					//SetVisionPanel(Area.Stats.PanelFireVisionRange, bAlt)
					//SetVisionPanel(Area.Stats.LabelDeBuffFlamePurgeStat, bAlt)
					Area.Stats.PanelFlameRadius.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nFireRange, NTData, bAlt)
					Area.Stats.PanelFlameEvery.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nAuraIntervalThink, NTData, bAlt, 3)
					//SetVisionPanel(Area.Stats.LabelDeBuffFirePurgeStat, bAlt)
					Area.Stats.PanelDeBuffFireDuration.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nBuffDuration, NTData, bAlt)
					Area.Stats.PanelDeBuffFireStackCount.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nMaxStacks, NTData, bAlt)
					//SetVisionPanel(Area.Stats.LabelDeBuffFireTypeDamage, bAlt)
					Area.Stats.PanelDeBuffFireDamage.FindChildTraverse("LabelValue").text = It(hGameConst[sThis].nDamagePerStack, NTData, bAlt)
					
					SetVisionPanel(Area.Alt, bAlt)
					RequirementBlockRefresh(Area.Req, hGameConst[sThis], NTData, bAlt)
					$.DispatchEvent("UIShowCustomLayoutTooltip", Game.CustomTooltip.TooltipLastInfo.ParentPanel, "Tooltip", "file://{resources}/layout/custom_game/Tooltips/AbilityTooltip.xml"); 
				}
				ApplyTimer(nDefaultTick, RefreshFunc, false)
			}
		),
	}
}



















function FormulaElementBlock(hParent, LabelName, sBlockName){
	var PanelFormulaElement = Block("Panel", hParent, "PanelFormulaElement", sBlockName)
		PanelFormulaElement.LabelFormulaElement = Block("Label", PanelFormulaElement, "LabelFormulaElement", sBlockName)
		if(typeof LabelName == "number"){
			switch(LabelName) {
			case 0:
				LabelName = ""
				break
			case 1:
				LabelName = "Q"
				PanelFormulaElement.LabelFormulaElement.style.color = Tr("Tooltip_Font_Color_Quantum")
				break
			case 2:
				LabelName = "W"
				PanelFormulaElement.LabelFormulaElement.style.color = Tr("Tooltip_Font_Color_Warp")
				break
			case 3:
				LabelName = "E"
				PanelFormulaElement.LabelFormulaElement.style.color = Tr("Tooltip_Font_Color_Expanse")
				break
			}
		}
		PanelFormulaElement.LabelFormulaElement.text = LabelName

	return PanelFormulaElement
}

function FormulaBlock(hParent, sTooltipName){
	var PanelFormula = Block("Panel", hParent, "PanelFormula", "FormulaBlock")
	var hFormula = hGameConst.sAbilName_hFormula[sTooltipName]
	PanelFormula.hElemntPanels = {}
	for(var i=1; i<=3; i++){
		PanelFormula.hElemntPanels[i] = FormulaElementBlock(PanelFormula, Number(hFormula[i]), "PanelFormula"+i)
	}

	return PanelFormula
}

function SuppTitleBlock(hParent, sTooltipName, sCaption, nSphere_bUse, bFormulaUse){	//nSphere_bUse - создать ли Level панель на основе factor-номера сферы
	var SuppPanel = Block("Panel", hParent, "Title", "PanelTitle")
	SuppPanel.AddClass("DefaultSupp")
	SuppPanel.AddClass("DefaultTitle")

	if(bFormulaUse != null && bFormulaUse){
		SuppPanel.PanelFormula = FormulaBlock(SuppPanel, sTooltipName)
	}
	var PanelCaption = Block("Panel", SuppPanel, "PanelTitle", "FormulaBlock")
		PanelCaption.LabelCaption = Block("Label", PanelCaption, "LabelTitle", "FormulaBlock")
		PanelCaption.LabelCaption.text = sCaption
	if(nSphere_bUse != null){
		SuppPanel.PanelTitleLevel = InitPanelTitleLevel(SuppPanel)
		SuppPanel.PanelTitleLevel.PanelSphere = {}
		for(var i=1; i<=4; i++){
			if(nSphere_bUse[i]){
				SuppPanel.PanelTitleLevel.PanelSphere[i] = AddPanelFactor(SuppPanel.PanelTitleLevel, i)
			}
		}
	}

	return SuppPanel
}

function SuppRequirementBlock(hParent, hSpellConst, NTData){
	var RequirementBlock = SuppBlock(hParent, "Requirement", false)
	RequirementBlock.BLoadLayoutSnippet("RequirementBlock")


	//AddStatBlock
	var StatRequireCreate = function(Parent, sPanelName, factor){
		var PanelState = Parent.FindChildTraverse(sPanelName)
		Parent[sPanelName + 'Value'] = AddStatBlock(PanelState, '', '', factor)
	}
	StatRequireCreate(RequirementBlock, 'PanelCooldown', hSpellConst.nCooldown.factor)
	StatRequireCreate(RequirementBlock, 'PanelManaCost', hSpellConst.nManaCost.factor)




	return RequirementBlock
}

function RequirementBlockRefresh(Block, hSpellConst, NTData, bAlt){
	//$.Msg('RequirementBlockRefresh, NTData=', NTData)
	//var nAbil = Entities.GetAbilityByName( NTData.nEntityCaster, NTData.sTooltipName )
	//var sCooldown = It(hSpellConst.nCooldown, NTData, false)//Abilities.GetCooldown(nAbil)

	var nCooldown = hSpellConst.nCooldown //|| Abilities.GetCooldown(nAbil)
	var nManaCost = hSpellConst.nManaCost //|| Abilities.GetManaCost(nAbil)

	var StatRequireRefresh = function(nValue, sPanelName){
		if(nValue == 0){
			SetVisionPanel(Block.FindChildTraverse(sPanelName), false)
		}else{
			SetVisionPanel(Block.FindChildTraverse(sPanelName), true)
			Block[sPanelName+'Value'].FindChildTraverse("LabelValue").text = It(nValue, NTData, bAlt)
		}
	}
	StatRequireRefresh(nCooldown, 'PanelCooldown')
	StatRequireRefresh(nManaCost, 'PanelManaCost')
}

function SuppBlock(hParent, sPanelType, bApplyDefaults){	//создать один, из основных блоков
	var panel = $.CreatePanel('Panel', hParent, "Panel" + sPanelType);
	if(bApplyDefaults){
		panel.AddClass("DefaultSupp")
		panel.AddClass("Default" + sPanelType)
		panel.label = $.CreatePanel('Label', panel, "Label");
		panel.label.AddClass("Label" + sPanelType)
	}
	return panel
}
/*
function ParamBlock(){
	var panel = $.CreatePanel(sType, hParent, "");

}
*/

var AddStatDescription = (
	function(hParent, hLabelPack, sBlockName){	
		var panel = Block("Panel", hParent, null, sBlockName)
		panel.AddClass("DefaultStatsBlock")
		panel.labels = {}

		if(hLabelPack != null && typeof hLabelPack == 'object'){
			var i = 0
			while(hLabelPack[i] != null){
				var sClassLabel = "LabelStats"
				if(hLabelPack[i].sClassLabel != null){sClassLabel = hLabelPack[i].sClassLabel}
				panel.labels[i] = Block("Label", panel, sClassLabel, "label" + i)
				panel.labels[i].text = hLabelPack[i].sText
				i++
			}
		}else{
			panel.labels[0] = Block("Label", panel, "LabelStats", "label1")
			panel.labels[0].text = hLabelPack
		}
		return panel
	}
);

function Block(sType, hParent, sClass, sBlockName){
	if(sBlockName == null){sBlockName = ""}
	var panel = $.CreatePanel(sType, hParent, sBlockName);
	if(sClass != null){
		panel.AddClass(sClass)
	}
	return panel
}



function _n(hParent){
	return AddStatDescription(hParent, '')
}





/*
				var hSpellLib = 
				[
					{
						sSuppType: "Title",
						hBlockArgs: {
							sCaption: Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora"),
							nSphere_bUse: [null, null, true, true]
							bFormulaUse: true,
						},
					},
					{
						sSuppType: "Behavior",
						Blocks: 
						[
							{
								sBlockName: "AbilityType", 
								sBlockType: "StatDescription",
								hBlockArgs: 
								{
									hLabelPack: [{
										sText: Tr("Ability:")+s+Tr("UnitTarget"),
										sClassLabel: "LabelBehavior",
									}],
								},
							},
							{
								sBlockName: "CastRange", 
								sBlockType: "StatBlock",
								hBlockArgs: 
								{
									sCapion: Tr("CastRange"),
									sMeasure: Tr("OneMeasure"),
									nSphereClassNumber: hGameConst.[sThis].nCastRange.factor,
									sClassCaption: "LabelBehavior",
									//sBlockName: "CastRange",
								}
							},
							{
								sBlockName: "CastAnimation", 
								sBlockType: "StatBlock",
								hBlockArgs: 
								{
									sCapion: Tr("CastAnimation"),
									sMeasure: Tr("sec"),
									nSphereClassNumber: hGameConst.[sThis].nCastPoint.factor,
									sClassCaption: "LabelBehavior",
									//sBlockName: "CastRange",
								}
							},
						],
					},	
					{
						sSuppType: "Description",
						hBlockArgs: 
						{
							bApplyDefaults: true,
						},
						Blocks:
						[
							{
								sBlockName: "Description", 
								sBlockType: "Description",
								hBlockArgs: 
								{
									nSphereClassNumber: hGameConst.[sThis].nCastRange.factor,
									sText: Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Description"),
									//sClassCaption: "LabelBehavior",
								}
							},
						],
					},
					{
						sSuppType: "Stats",
						hBlockArgs: 
						{
							bApplyDefaults: true,
						},
						Blocks:
						[
							{
								sBlockName: "Buff", 
								sBlockType: "StatDescription",
								hBlockArgs: 
								{
									nSphereClassNumber: hGameConst.[sThis].nCastRange.factor,
									sText: Tr("DOTA_Tooltip_ability_invoker_alacrity_of_zecora_Description"),
									//sClassCaption: "LabelBehavior",
								}
							},
						],
					},
				]

*/

$.Msg(sThisFileName+'complete...')