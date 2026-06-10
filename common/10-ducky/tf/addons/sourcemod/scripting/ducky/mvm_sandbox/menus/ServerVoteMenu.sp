#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	RegConsoleCmd("menu_server", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	Menu menu = new Menu(Handle_Menu);
	menu.SetTitle("Server settings");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	char text[128];
	ConVar cvar;
	char state[16];

	menu.AddItem("server_silly", "Silly settings");

	menu.AddItem("server_rtv", "Map settings");

	if ((cvar = FindConVar("tf_forced_holiday")) != null) {
		int holiday = GetConVarInt(cvar);
		FormatHoliday(holiday, state, sizeof(state));
		Format(text, sizeof(text), "Halloween mode [%s]", state);
		menu.AddItem("server_halloween", text);
	}

	if ((cvar = FindConVar("mp_disable_respawn_times")) != null) {
		FormatToggle(cvar, state, sizeof(state), true);
		Format(text, sizeof(text), "Instant Respawn [%s]", state);
		menu.AddItem("server_instant_respawn", text);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));

		if (StrEqual(info, "server_silly"))
			FakeClientCommand(client, "menu_server_silly");
		else if (StrEqual(info, "server_rtv"))
			FakeClientCommand(client, "menu_server_map");
		else if (StrEqual(info, "server_halloween"))
			Voting_CreateYesNoConVarVote(client, "tf_forced_holiday", "Enable halloween mode?", 2, 0, "Halloween mode");
		else if (StrEqual(info, "server_instant_respawn"))
			Voting_CreateYesNoConVarVote(client, "mp_disable_respawn_times", "Enable instant respawning?", 0, 1, "Instant respawn");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
