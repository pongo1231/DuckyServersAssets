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

	menu.AddItem("server_scramble_teams", "Scramble teams");

	if ((cvar = FindConVar("mp_disable_respawn_times")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Instant respawn [%s]", state);
		menu.AddItem("server_instant_respawn", text);
	}

	if ((cvar = FindConVar("tf_forced_holiday")) != null) {
		int holiday = GetConVarInt(cvar);
		FormatHoliday(holiday, state, sizeof(state));
		Format(text, sizeof(text), "Halloween mode [%s]", state);
		menu.AddItem("server_halloween", text);
	}

	if ((cvar = FindConVar("tf_weapon_criticals")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Random crits [%s]", state);
		menu.AddItem("server_random_crits", text);
	}

	if ((cvar = FindConVar("tf_ctf_bonus_time")) != null) {
		Format(text, sizeof(text), "Crits on capture time [%is]", GetConVarInt(cvar));
		menu.AddItem("server_crits_on_cap", text);
	}

	if ((cvar = FindConVar("tf_flag_caps_per_round")) != null) {
		Format(text, sizeof(text), "Flag captures to win [%i]", GetConVarInt(cvar));
		menu.AddItem("server_flag_caps_to_win", text);
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
		else if (StrEqual(info, "server_scramble_teams"))
			Voting_CreateYesNoCommandVote(client, "mp_scrambleteams", "Scramble teams?", "", "Scramble teams");
		else if (StrEqual(info, "server_instant_respawn"))
			Voting_CreateYesNoConVarVote(client, "mp_disable_respawn_times", "Enable instant respawn?", 1, 0, "Instant respawn");
		else if (StrEqual(info, "server_halloween"))
			Voting_CreateYesNoConVarVote(client, "tf_forced_holiday", "Enable halloween mode?", 2, 0, "Halloween mode");
		else if (StrEqual(info, "server_random_crits"))
			Voting_CreateYesNoConVarVote(client, "tf_weapon_criticals", "Enable random crits?", 1, 0, "Random crits");
		else if (StrEqual(info, "server_crits_on_cap"))
			Voting_CreateStringConVarVote(client, "tf_ctf_bonus_time", "Set crits on capture time", "CTF crit time", "0", "5", "10", "20", "30", "60");
		else if (StrEqual(info, "server_flag_caps_to_win"))
			Voting_CreateStringConVarVote(client, "tf_flag_caps_per_round", "Set flag captures to win", "CTF flag caps", "1", "2", "3", "4", "5", "10");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
