var sFileName = '[manifest.js] '

var UIRoot = $.GetContextPanel().GetParent().GetParent()

var hudRoot;
var panel;
for( panel = $.GetContextPanel(); panel != null; panel = panel.GetParent())
{
    hudRoot = panel;
}
Game.hudRoot = hudRoot;
GameUI.hudRoot = hudRoot


GameUI.CustomUIConfig().team_colors = {}

GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "rgba(255,0,0,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "rgba(0,0,255,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "rgba(0, 255, 0,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "rgba(255, 215, 0,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "rgba(0, 255, 255,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "rgba(255, 0, 255,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "rgba(139, 69, 19,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "rgba(255, 255, 255,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "rgba(128, 128, 128,1)";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "rgba(0, 0, 0,1)";

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );     //Shop portion of the Inventory. 
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, true )
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false )

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false )

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, true )
  GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, true )


//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false )
//$.Msg(hudRoot.FindChildTraverse("shop"))

/*
//Hide UI Invrntory
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false );
if(hudRoot.FindChildTraverse("inventory") != null){
  hudRoot.FindChildTraverse("inventory").DeleteAsync(0)
}
//hudRoot.FindChildTraverse("right_flare").style.marginRight = '204px';
//hudRoot.FindChildTraverse("AbilitiesAndStatBranch").style.marginRight = '60px';
hudRoot.FindChildTraverse("right_flare").style.marginRight = '54px';
//hudRoot.FindChildTraverse("center_bg").style.marginRight = '50px';
//$.Msg(hudRoot.FindChildrenWithClassTraverse("AbilityInsetShadowRight")[0].style)
//hudRoot.FindChildrenWithClassTraverse("AbilityInsetShadowRight").style.marginRight = '50px';
//$.Msg(hudRoot.FindChildrenWithClassTraverse("AbilityInsetShadowRight")[0].style)
//$.Msg("marginRight = " + hudRoot.FindChildTraverse("right_flare").style.marginRight )




*/

//GameUI.DefaultInventoryContainer = GameUI.hudRoot.FindChildTraverse("inventory_backpack_list").GetParent()















/*
function OnPlayerShopChanged(){
  $.Msg("OnPlayerShopChanged")
  //$.Msg(data);
}*/


//$.RegisterKeyBind($.GetContextPanel(), "ShopToggle", OnPlayerShopChanged)
//$.GetContextPanel()


//$.RegisterForUnhandledEvent( "DOTA_KEYBIND_SHOP_TOGGLE", OnPlayerShopChanged )
//GameEvents.Subscribe( "dota_player_shop_changed", OnPlayerShopChanged )
//.RegisterForUnhandledEvent("game_start", OnPlayerShopChanged);

//DOTAKeybindCommand_t.DOTA_KEYBIND_SHOP_TOGGLE = 	115



//$.Msg(DOTATeam_t.DOTA_TEAM_CUSTOM_COUNT)
//$.Msg(DOTATeam_t.DOTA_TEAM_COUNT)
//$.Msg("manifest.js")

GameUI.DeleteStatBranch = function(){
  var statBranch = GameUI.hudRoot.FindChildTraverse("StatBranch");
  if (statBranch != null){
      statBranch.DeleteAsync(0)
  }
  var statLevel = GameUI.hudRoot.FindChildTraverse("level_stats_frame");
  if (statLevel != null){
      statLevel.DeleteAsync(0)
  }

  var GlyphScanContainer = GameUI.hudRoot.FindChildTraverse("GlyphScanContainer")
  if(GlyphScanContainer){
    GlyphScanContainer.DeleteAsync(0)
  }
}

GameUI.HideAddItemSlot = function(){
  var AddItemSlot = GameUI.hudRoot.FindChildTraverse("inventory_tpscroll_container");
  if(AddItemSlot){
    //AddItemSlot.DeleteAsync(0)  //вылетает, если удалять
    AddItemSlot.visible = false
  }
}






Game.Sync = function(NT, KEY, DATA){
  var data = {
    NT: NT,
    KEY: KEY,
    DATA: DATA
  }
	GameEvents.SendCustomGameEventToServer("onSync", data)
}


db(sFileName, "complete...")
