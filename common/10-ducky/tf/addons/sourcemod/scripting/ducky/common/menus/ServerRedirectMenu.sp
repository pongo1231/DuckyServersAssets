#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	RegConsoleCmd("menu_redirect", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle("Other servers");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	menu.AddItem("1", "All of our servers are listed here:");
	menu.AddItem("2", "servers.ecmec.eu");

	menu.Display(client, MENU_TIME_FOREVER);
 
	return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
		   FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
