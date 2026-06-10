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

	menu.AddItem("server_map_menu", "Map menu");

	menu.AddItem("server_scramble_teams", "Scramble teams");

	if ((cvar = FindConVar("mp_disable_respawn_times")) != null) {
		FormatToggle(cvar, state, sizeof(state), true);
		Format(text, sizeof(text), "Instant respawn [%s]", state);
		menu.AddItem("server_instant_respawn", text);
	}

	if ((cvar = FindConVar("tf_weapon_criticals")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Random crits [%s]", state);
		menu.AddItem("server_random_crits", text);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));

		if (StrEqual(info, "server_map_menu"))
			FakeClientCommand(client, "callvote");
		else if (StrEqual(info, "server_scramble_teams"))
			Voting_CreateYesNoCommandVote(client, "mp_scrambleteams", "Scramble teams?", "", "Scramble teams");
		else if (StrEqual(info, "server_instant_respawn"))
			Voting_CreateYesNoConVarVote(client, "mp_disable_respawn_times", "Enable instant respawn?", 0, 1, "Instant respawn");
		else if (StrEqual(info, "server_random_crits"))
			Voting_CreateYesNoConVarVote(client, "tf_weapon_criticals", "Enable random crits?", 1, 0, "Random crits");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
