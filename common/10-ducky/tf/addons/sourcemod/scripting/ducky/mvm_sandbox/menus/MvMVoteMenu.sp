#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	RegConsoleCmd("menu_mvm", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	if (!GameRules_GetProp("m_bPlayingMannVsMachine")) {
		Server_PrintToChat(client, "Menu", "Can't open mvm menu when not playing mvm.");
		return Plugin_Stop;
	}

	Menu menu = new Menu(Handle_Menu);
	menu.SetTitle("MvM settings");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	char text[128];
	ConVar cvar;
	char state[16];

	if ((cvar = FindConVar("tf_mvm_endless_force_on")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Endless Force Mode [%s]", state);
		menu.AddItem("mvm_endlessforcemode", text);
	}

	if ((cvar = FindConVar("sm_mvm_infinitemoney")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Infinite Money [%s]", state);
		menu.AddItem("mvm_infinitemoney", text);
	}

	menu.AddItem("mvm_killrobots", "Kill all spawned robots (use if stuck)");

	menu.AddItem("mvm_killtanks", "Kill all spawned tanks");

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));

		if (StrEqual(info, "mvm_endlessforcemode"))
			Voting_CreateYesNoConVarVote(client, "tf_mvm_endless_force_on", "Enable MvM Endless Force Mode?", 1, 0, "Endless force mode");
		else if (StrEqual(info, "mvm_infinitemoney"))
			Voting_CreateYesNoConVarVote(client, "sm_mvm_infinitemoney", "Enable infinite money?", 1, 0, "Infinite money");
		else if (StrEqual(info, "mvm_killrobots"))
			Voting_CreateYesNoCommandVote(client, "sm_slay @blue", "Kill all spawned robots? (use if stuck)", "", "Kill robots");
		else if (StrEqual(info, "mvm_killtanks"))
			Voting_CreateYesNoCommandVote(client, "sv_cheats 1; sm_fakecmd @bots tf_mvm_tank_kill", "Kill all spawned tanks?", "", "Kill tanks");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
