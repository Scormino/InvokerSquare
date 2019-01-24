function CreateAbilityButton(abil, abilname, blok_name)	// to ex:'#Block_Q'
{
	var panel = $.CreatePanel('Panel', blok_name, '');
	panel.BLoadLayoutSnippet("MainDotaImage")

	var button = panel.FindChildTraverse("SpellButton")
	var image = panel.FindChildTraverse("SpellButton").FindChildTraverse("OriginSpellImage")

	image.abilityname = abilname;
    //image.abil = Entities.GetAbility(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()), 2);


    
	panel.SetPanelEvent(("oncontextmenu"), function(){
		//$.Msg("Spell " + abilname + " reconstruction..."); // вывод в консоль
		var plyID = Game.GetLocalPlayerID(); // Game - глобальная штука, смотри API JS
		var data = {		// Обьект для передачи в Луа
			playerID: plyID, 
			abil: abil,
			abilname: abilname,
			ClosingQWERSystem: $('#CheckBoxClosing').checked
		}
		GameEvents.SendCustomGameEventToServer("event_onButtonSpellClick", data); 
	});
	



	panel.SetPanelEvent("onmouseover", function (){ 
		var hInfo = {
			ParentPanel: panel,
			sAbilName: abilname,
			nEntityCaster: 	Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()),
		}
		$.DispatchEvent ("DOTAShowAbilityTooltipForEntityIndex" , panel, abilname, hInfo.nEntityCaster)
		//Game.CustomTooltipSignal(hInfo)
		//Game.ToolTipLastPanel
		//$.DispatchEvent ( "DOTAShowAbilityTooltip" , panel,  abilname); 
	  } 
	)
	panel.SetPanelEvent("onmouseout", function (){ 
		$.DispatchEvent ("DOTAHideAbilityTooltip" , panel);
		$.DispatchEvent("UIHideCustomLayoutTooltip" , "Tooltip");
		//Game.CustomTooltip.CustomTooltipRoot.FindChildTraverse("TooltipArea").style.visibility = "collapse"
		Game.CustomTooltip.bIsTooltipAlive = false
	  } 
	)
	return panel
}

function CreateSpellBlock(nBlock)
{
	var panel = $.CreatePanel('Panel', $('#Spell_Blocks'), 'Spell_Block'+nBlock);
	panel.BLoadLayoutSnippet("Spell_Block")
	return panel
}

function CreateLabel(newtext, blok_name)
{
	var panel = $.CreatePanel('Panel', blok_name, '');
	panel.BLoadLayoutSnippet("SnippetTitle");
	var label = panel.FindChildTraverse("TitleLabel").text = newtext;
	return panel
}




function ShowHideQWERSystem(Title, bState){
	var PanelQWERSystem = Title.GetParent()

	if(bState){
		if(!PanelQWERSystem.BHasClass('Showstate')){
			PanelQWERSystem.AddClass('Showstate')
		}
	}else{
		if(PanelQWERSystem.BHasClass('Showstate')){
			PanelQWERSystem.RemoveClass('Showstate')
		}
	}
}




function Init(event)
{

	$.Msg('[QWERSystem.js] Init beginning')

	if(Game.QWERSystemTitleName == $('#Title')){
		return 0
	}
	Game.QWERSystemTitleName = $('#Title')
	ShowHideQWERSystem(Game.QWERSystemTitleName, false)

	$("#CheckBoxClosing").SetPanelEvent("onmouseover", function (){ 
			$.DispatchEvent ( "DOTAShowTextTooltip" , $("#CheckBoxClosing"),  "HelpClosing"); 
		} 
	)
	$("#CheckBoxClosing").SetPanelEvent("onmouseout", function (){ 
			$.DispatchEvent ("DOTAHideTextTooltip" , $("#CheckBoxClosing")); 
		} 
	)

	var panel_blockQ = CreateSpellBlock(1)							//Создаём блок, который имеет панель подзаголовка и Spell_Array
	CreateAbilityButton(null, "invoker_quantum", panel_blockQ.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	
	var panel_blockW = CreateSpellBlock(2)					
	CreateAbilityButton(null, "invoker_warp", panel_blockW.FindChildTraverse("Spell_Block_Title_id"));

	var panel_blockE = CreateSpellBlock(3)					
	CreateAbilityButton(null, "invoker_expanse", panel_blockE.FindChildTraverse("Spell_Block_Title_id"));
	
	var panel_blockQW = CreateSpellBlock(4)		
	CreateAbilityButton(null, "invoker_quantum", panel_blockQW.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	CreateLabel("+", panel_blockQW.FindChildTraverse("Spell_Block_Title_id"))
	CreateAbilityButton(null, "invoker_warp", panel_blockQW.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	
	var panel_blockQE = CreateSpellBlock(5)	
	CreateAbilityButton(null, "invoker_quantum", panel_blockQE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	CreateLabel("+", panel_blockQE.FindChildTraverse("Spell_Block_Title_id"))
	CreateAbilityButton(null, "invoker_expanse", panel_blockQE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке


	var panel_blockWE = CreateSpellBlock(6)	
	CreateAbilityButton(null, "invoker_warp", panel_blockWE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	CreateLabel("+", panel_blockWE.FindChildTraverse("Spell_Block_Title_id"))
	CreateAbilityButton(null, "invoker_expanse", panel_blockWE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке

	var panel_blockQWE = CreateSpellBlock(7)	
	CreateAbilityButton(null, "invoker_quantum", panel_blockQWE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	CreateLabel("+", panel_blockQWE.FindChildTraverse("Spell_Block_Title_id"))
	CreateAbilityButton(null, "invoker_warp", panel_blockQWE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	CreateLabel("+", panel_blockQWE.FindChildTraverse("Spell_Block_Title_id"))
	CreateAbilityButton(null, "invoker_expanse", panel_blockQWE.FindChildTraverse("Spell_Block_Title_id"));	//Создаём кнопку в нашем блоке
	
	BlockSache = {}
	BlockSache[1] = panel_blockQ
	BlockSache[2] = panel_blockW
	BlockSache[3] = panel_blockE
	BlockSache[4] = panel_blockQW
	BlockSache[5] = panel_blockQE
	BlockSache[6] = panel_blockWE
	BlockSache[7] = panel_blockQWE

	BlockColorRefresh()

	var hGameConst = StringTable2Table(CustomNetTables.GetTableValue( "Hash", "hGameConst" ))

	//сортировка данных
	if(hGameConst != null & hGameConst.sAbilName_hFormula != null){
		var f = hGameConst.sAbilName_hFormula

		var GF = function(a, b, c){	//GenFormula
			return {1: a, 2: b, 3: c}
		}
		var BlockLib = {}
		var FormulaLib = {}
		var q = 1
		var w = 2
		var e = 3
		//формулы 1 порядка
		FormulaLib[1] 	= GF(q, 0, 0);	BlockLib[1] 	= 1
		FormulaLib[2] 	= GF(w, 0, 0);	BlockLib[2] 	= 2
		FormulaLib[3] 	= GF(e, 0, 0);	BlockLib[3] 	= 3

		//формулы 2 порядка
		FormulaLib[4] 	= GF(q, q, 0);	BlockLib[4] 	= 1
		FormulaLib[5] 	= GF(q, w, 0);	BlockLib[5] 	= 4
		FormulaLib[6] 	= GF(q, e, 0);	BlockLib[6] 	= 5
		FormulaLib[7] 	= GF(w, q, 0);	BlockLib[7] 	= 4
		FormulaLib[8] 	= GF(w, w, 0);	BlockLib[8] 	= 2
		FormulaLib[9] 	= GF(w, e, 0);	BlockLib[9] 	= 6
		FormulaLib[10] 	= GF(e, q, 0);	BlockLib[10] 	= 5
		FormulaLib[11] 	= GF(e, w, 0);	BlockLib[11] 	= 6
		FormulaLib[12] 	= GF(e, e, 0);	BlockLib[12] 	= 3

		//формулы 3 порядка
		FormulaLib[13]	= GF(q, q, q);	BlockLib[13] 	= 1
		FormulaLib[14]	= GF(q, q, w);	BlockLib[14] 	= 4
		FormulaLib[15]	= GF(q, q, e);	BlockLib[15] 	= 5
		FormulaLib[16]	= GF(q, w, q);	BlockLib[16] 	= 4
		FormulaLib[17]	= GF(q, w, w);	BlockLib[17] 	= 4
		FormulaLib[18]	= GF(q, w, e);	BlockLib[18] 	= 7
		FormulaLib[19]	= GF(q, e, q);	BlockLib[19] 	= 5
		FormulaLib[20]	= GF(q, e, w);	BlockLib[20] 	= 7
		FormulaLib[21]	= GF(q, e, e);	BlockLib[21] 	= 5

		FormulaLib[22]	= GF(w, q, q);	BlockLib[22] 	= 4
		FormulaLib[23]	= GF(w, q, w);	BlockLib[23] 	= 4
		FormulaLib[24]	= GF(w, q, e);	BlockLib[24] 	= 7
		FormulaLib[25]	= GF(w, w, q);	BlockLib[25] 	= 4
		FormulaLib[26]	= GF(w, w, w);	BlockLib[26] 	= 2
		FormulaLib[27]	= GF(w, w, e);	BlockLib[27] 	= 6
		FormulaLib[28]	= GF(w, e, q);	BlockLib[28] 	= 7
		FormulaLib[29]	= GF(w, e, w);	BlockLib[29] 	= 6
		FormulaLib[30]	= GF(w, e, e);	BlockLib[30] 	= 6

		FormulaLib[31]	= GF(e, q, q);	BlockLib[31] 	= 5
		FormulaLib[32]	= GF(e, q, w);	BlockLib[32] 	= 7
		FormulaLib[33]	= GF(e, q, e);	BlockLib[33] 	= 5
		FormulaLib[34]	= GF(e, w, q);	BlockLib[34] 	= 7
		FormulaLib[35]	= GF(e, w, w);	BlockLib[35] 	= 6
		FormulaLib[36]	= GF(e, w, e);	BlockLib[36] 	= 6
		FormulaLib[37]	= GF(e, e, q);	BlockLib[37] 	= 5
		FormulaLib[38]	= GF(e, e, w);	BlockLib[38] 	= 6
		FormulaLib[39]	= GF(e, e, e);	BlockLib[39] 	= 3

		var CheckForEqualityArray = function(a, b){
			for(var g = 1; g <= 3; g++){
				if(a[g] != b[g]){
					return false
				}
			}
			return true
		}
		for(var nSpell = 1; nSpell <= 39; nSpell++){
			var sCurrentSpell = ''
			for(var sAbilName in f){
				if(CheckForEqualityArray(f[sAbilName], FormulaLib[nSpell])){
					sCurrentSpell = sAbilName
					delete f[sAbilName]
					break
				}
			}
			if(sCurrentSpell != ''){
				CreateAbilityButton(null, sCurrentSpell, BlockSache[BlockLib[nSpell]].FindChildTraverse("Spell_Array_id"))
			}
		}
	}

	//Отлов нажатия кнопки 'shop'
	GameUI.RefreshShop = {}
	var OnShopButton = function(bNewShopState){
		ShowHideQWERSystem(Game.QWERSystemTitleName, bNewShopState)
	}

	
	GameUI.RefreshShop.bMemOpen = false	//Был ли открыт магазин в прошлый раз
	GameUI.RefreshShop.TimerFunc = function(){
		var bOpen = Game.IsShopOpen()
		if(GameUI.RefreshShop.bMemOpen != bOpen){	//Если состояние изменилось
			OnShopButton(bOpen)
			GameUI.RefreshShop.bMemOpen = bOpen 		//Запоминаем новое значение
		}
		GameUI.RefreshShop.nTimer = $.Schedule(0.1, GameUI.RefreshShop.TimerFunc)
	}
	GameUI.RefreshShop.TimerFunc()



	$.Msg('[QWERSystem.js] Init complete...')
}


function CloseSpellBook(){
	if($('#CheckBoxClosing').checked){
		$.DispatchEvent('DOTAHUDToggleShop')
	}
}

function SpellBookClickButton(){
	ShowHideQWERSystem(Game.QWERSystemTitleName);
}

Init()
GameEvents.Subscribe("CloseSpellBook", CloseSpellBook)
GameEvents.Subscribe("SpellBookClickButton", SpellBookClickButton)



function BlockColorRefresh(){
	var nHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() )
	
	var invoker_quantum = Entities.GetAbilityByName( nHeroIndex, 'invoker_quantum' )
	var invoker_warp = Entities.GetAbilityByName( nHeroIndex, 'invoker_warp' )
	var invoker_expanse = Entities.GetAbilityByName( nHeroIndex, 'invoker_expanse' )
	var invoker_reconstruction = Entities.GetAbilityByName( nHeroIndex, 'invoker_reconstruction' )

	var q = 1
	var w = 2
	var e = 3
	var r = 4
	
	var hLevels = {}
	hLevels[q] = Abilities.GetLevel( invoker_quantum )
	hLevels[w] = Abilities.GetLevel( invoker_warp )
	hLevels[e] = Abilities.GetLevel( invoker_expanse )
	hLevels[r] = Abilities.GetLevel( invoker_reconstruction )

	var UpdateBlockBackgroundColor = function(nBlock, bColor){
		var sBorder = '2px solid rgb(17, 17, 17)'
		if(bColor){
			sBorder = '2px solid rgb(23, 99, 0)'
		}
		$('#Spell_Blocks').FindChildTraverse('Spell_Block'+nBlock).style.border = sBorder
		/*
		var sBackgroundColor = 'rgba(0,0,0,0.8)'
		if(bColor){
			sBackgroundColor = 'rgba(0,60,0,0.6)'
		}
		$('#Spell_Blocks').FindChildTraverse('Spell_Block'+nBlock).style.backgroundColor = sBackgroundColor
		*/
	}

	UpdateBlockBackgroundColor(1, 
		hLevels[q] > 0
	)
	UpdateBlockBackgroundColor(2, 
		hLevels[w] > 0
	)
	UpdateBlockBackgroundColor(3, 
		hLevels[e] > 0
	)	
	UpdateBlockBackgroundColor(4, 
		hLevels[q] > 0 && hLevels[w] > 0
	)	
	UpdateBlockBackgroundColor(5, 
		hLevels[q] > 0 && hLevels[e] > 0
	)	
	UpdateBlockBackgroundColor(6, 
		hLevels[w] > 0 && hLevels[e] > 0
	)	
	UpdateBlockBackgroundColor(7, 
		hLevels[q] > 0 && hLevels[w] > 0 && hLevels[e] > 0
	)	
	//$('#Spell_Blocks').FindChildTraverse('Spell_Block'+nBlock)


}
GameEvents.Subscribe("dota_player_learned_ability", BlockColorRefresh)

/*
function printJS(keys){
	$.Msg("printJS:")
	$.Msg(keys)
}
GameEvents.Subscribe("printJS", printJS)
*/