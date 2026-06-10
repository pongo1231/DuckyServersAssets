#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	RegConsoleCmd("menu_bots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	Menu menu = new Menu(Handle_Menu);
	menu.SetTitle("Bot settings");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	char text[128];
	ConVar cvar;
	char state[16];

	Format(text, sizeof(text), "RCBot settings");
	menu.AddItem("bots_enable", text);

	if ((cvar = FindConVar("sm_bottaunt_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "All bots do a custom taunt on kill [%s]", state);
		menu.AddItem("bots_taunt", text);
	}

	if ((cvar = FindConVar("sm_bothurtvoice_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "All bots do a voice command on damage [%s]", state);
		menu.AddItem("bots_hurt", text);
	}

	if ((cvar = FindConVar("sm_bbr_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "All bots are robots [%s]", state);
		menu.AddItem("bots_robots", text);
	}

	if ((cvar = FindConVar("sm_spyspyspyspy_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Bots are paranoid [%s]", state);
		menu.AddItem("bots_helphelphelphelp", text);
	}

	if ((cvar = FindConVar("sm_helphelphelphelp_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Bots stick together [%s]", state);
		menu.AddItem("bots_spyspyspyspy", text);
	}

	if ((cvar = FindConVar("sm_botrtd_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Bots use RTD [%s]", state);
		menu.AddItem("bots_rtd", text);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));

		if (StrEqual(info, "bots_enable"))
			FakeClientCommand(client, "menu_bots_rcbot");
		else if (StrEqual(info, "bots_taunt"))
			Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make bots do a custom taunt on kill?", 1, 0, "Bot kill taunts");
		else if (StrEqual(info, "bots_hurt"))
			Voting_CreateYesNoConVarVote(client, "sm_bothurtvoice_enabled", "Make bots do a voice command on damage?", 1, 0, "Bot damage voice");
		else if (StrEqual(info, "bots_robots"))
			Voting_CreateYesNoConVarVote(client, "sm_bbr_enabled", "Make all bots robots?", 1, 0, "Bots as robots");
		else if (StrEqual(info, "bots_helphelphelphelp"))
			Voting_CreateYesNoConVarVote(client, "sm_spyspyspyspy_enabled", "Make bots paranoid?", 1, 0, "Bot paranoia");
		else if (StrEqual(info, "bots_spyspyspyspy"))
			Voting_CreateYesNoConVarVote(client, "sm_helphelphelphelp_enabled", "Make bots stick together?", 1, 0, "Bot sticking together");
		else if (StrEqual(info, "bots_rtd"))
			Voting_CreateYesNoConVarVote(client, "sm_botrtd_enabled", "Should bots be able to use RTD? (RTD has to be enabled too)", 1, 0, "Bot RTD");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
