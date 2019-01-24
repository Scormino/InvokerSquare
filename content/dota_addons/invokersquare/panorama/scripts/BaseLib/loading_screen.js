var sNameFile = "[BaseLib/loading_screen.js] "

Game.hFirstInit = {}
/*
var LoadRoot
var panel
for( panel = $.GetContextPanel(); panel != null; panel = panel.GetParent())
{
  LoadRoot = panel
}
Game.LoadRoot = LoadRoot
*/
Game.LoadRoot = $.GetContextPanel().GetParent().GetParent()
//var PanelChat = $.GetContextPanel().GetParent().FindChildrenWithClassTraverse("ChatTipBox")[0]


db(sNameFile, "complete...")