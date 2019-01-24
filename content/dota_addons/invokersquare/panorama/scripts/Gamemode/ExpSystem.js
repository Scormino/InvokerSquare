var sThisFileName = "[Gamemode/ExpSystem.js] "
$.Msg(sThisFileName+'init...')

function ExpSystemInit(){
	GameUI.hudRoot.FindChildTraverse("inventory_backpack_list").style.visibility = 'collapse'
	var InventoryContainer = GameUI.hudRoot.FindChildTraverse('InventoryContainer')
	var PanelExp = InventoryContainer.FindChildTraverse('PanelInventoryExp')
	if(!PanelExp){
		PanelExp = $.CreatePanel('Panel', InventoryContainer, 'PanelInventoryExp')
		PanelExp.BLoadLayout( "file://{resources}/layout/custom_game/Gamemode/ExpSystem.xml", false, false )
		var DOTAslider = PanelExp.FindChildTraverse( "DOTASliderInventoryExp" )
		DOTAslider.FindChildrenWithClassTraverse("LeftRightFlow")[0].style.visibility = 'collapse'
		



		var slider = DOTAslider.FindChildTraverse( "Slider" )
		var LabelExpFactor = PanelExp.FindChildTraverse('LabelInventoryExpCurrentFactor')
		var LabelExpPerSec = PanelExp.FindChildTraverse('LabelInventoryExpPerSec')
		Game.ExpSystem = {}
		Game.ExpSystem.nTimer = 0

		var sLocalPlayer = Players.GetLocalPlayer().toString()
		var sShowPossibility = 'ShowPossibility'
		var PanelSliderTop = PanelExp.FindChildTraverse('PanelSliderInventoryExpBlack') //Эта панель как раз появляется при наведении

		function UpdateExpInfo() {	//return current local "hExpInfo"
			var hExpInfo
			var sExpFactor = '?%'
			var sExpPerSec = '? exp/sec'
			var nSelectedUnit = Players.GetLocalPlayerPortraitUnit()
			
			var nSelectedTeam = Entities.GetTeamNumber(nSelectedUnit)
			var nLocalTeam = Players.GetTeam(Players.GetLocalPlayer())
			if(nSelectedTeam == nLocalTeam){
				var nSelectedPlayer = Entities.GetPlayerOwnerID(nSelectedUnit)
				if(nSelectedPlayer == Players.GetLocalPlayer()){
					//Если юнит наш
					if(!PanelSliderTop.BHasClass(sShowPossibility)){
						PanelSliderTop.AddClass(sShowPossibility)
					}					
				}else{
					//если юнит союзный
					if(PanelSliderTop.BHasClass(sShowPossibility)){
						PanelSliderTop.RemoveClass(sShowPossibility)
					}
				}
				hExpInfo = Game.ExpSystem.sPlayer_hExpInfo[nSelectedPlayer.toString()]
				if(hExpInfo){
					sExpFactor = (Math.round(100 * hExpInfo.nGainFactor)).toString() + '%'
					sExpPerSec = ((hExpInfo.nExpPerSec).toFixed(1)).toString() + ' exp/sec'
				}
			}else{
				//если юнит чужой
				PanelSliderTop.RemoveClass(sShowPossibility)
			}
			LabelExpFactor.text = sExpFactor
			LabelExpPerSec.text = sExpPerSec

			return hExpInfo
		}
		GameEvents.Subscribe( 'dota_player_update_selected_unit', UpdateExpInfo )
		GameEvents.Subscribe( 'dota_player_update_query_unit', UpdateExpInfo )

		function OnExpInfoChanged( sTable_name, sTable_key, sPlayer_hExpInfo )
		{
			if(sTable_key == 'ExpSystem'){
				if(!sPlayer_hExpInfo){
					sPlayer_hExpInfo = CustomNetTables.GetTableValue( "Mode", "ExpSystem" )
        }
        sPlayer_hExpInfo = StringTable2Table(sPlayer_hExpInfo)
				Game.ExpSystem.sPlayer_hExpInfo = sPlayer_hExpInfo	//Записываем всю инфу
				return UpdateExpInfo()
			}
		}
		CustomNetTables.SubscribeNetTableListener( "Mode", OnExpInfoChanged )











		var fSliderUpdate = function(){
			if(slider.value != Game.ExpSystem.nMemoryExpFacor){
				//Значение изменилось
				Game.ExpSystem.nMemoryExpFacor = slider.value
				GameEvents.SendCustomGameEventToServer("ExpSystemUpdate", {
						nPlayer: Players.GetLocalPlayer(),
						nNewExpFactor: slider.value,
					}
				)
			}
		}

		var fStartUpdated = function(){
			fSliderUpdate()
			Game.ExpSystem.nTimer = $.Schedule(0.02, fStartUpdated)
		}
		var fStopUpdated = function(){
			if(Game.ExpSystem.nTimer != 0){
				$.CancelScheduled(Game.ExpSystem.nTimer, fStartUpdated)
				Game.ExpSystem.nTimer = 0
			}
			fSliderUpdate()
		}

		var PanelInventoryExpInfo = PanelExp.FindChildTraverse( "PanelInventoryExpInfo" )
		PanelInventoryExpInfo.SetPanelEvent("onmouseover", fStartUpdated)	//мышь наведена на панель
		PanelInventoryExpInfo.SetPanelEvent("onmouseout", fStopUpdated) 	//мышь вышла с панели
		
		//единожды присваиваем значение ползунка
		var hExpInfoTemp = OnExpInfoChanged("Mode", "ExpSystem")
		if(hExpInfoTemp){
			slider.value = hExpInfoTemp.nGainFactor
		}else{
			slider.value = 1.0
		}
    Game.ExpSystem.nMemoryExpFacor = slider.value
	}  
}
ExpSystemInit()

$.Msg(sThisFileName+'complete...')