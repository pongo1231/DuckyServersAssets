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

	Format(text, sizeof(text), "RCBot settings");
	menu.AddItem("bots_enable", text);

	if ((cvar = FindConVar("sm_bottaunt_enabled")) != null) {
		Format(text, sizeof(text), "All bots do a custom taunt on kill (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_taunt", text);
	}

	if ((cvar = FindConVar("sm_bothurtvoice_enabled")) != null) {
		Format(text, sizeof(text), "All bots do a voice command on damage (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_hurt", text);
	}

	if ((cvar = FindConVar("sm_bbr_enabled")) != null) {
		Format(text, sizeof(text), "All bots are robots (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_robots", text);
	}

	if ((cvar = FindConVar("sm_spyspyspyspy_enabled")) != null) {
		Format(text, sizeof(text), "Bots are paranoid (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_helphelphelphelp", text);
	}

	if ((cvar = FindConVar("sm_helphelphelphelp_enabled")) != null) {
		Format(text, sizeof(text), "Bots stick together (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_spyspyspyspy", text);
	}

	if ((cvar = FindConVar("sm_botrtd_enabled")) != null) {
		Format(text, sizeof(text), "Bots use RTD (Currently: %b)", GetConVarBool(cvar));
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
			Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make bots do a custom taunt on kill?");
		else if (StrEqual(info, "bots_hurt"))
			Voting_CreateYesNoConVarVote(client, "sm_bothurtvoice_enabled", "Make bots do a voice command on damage?");
		else if (StrEqual(info, "bots_robots"))
			Voting_CreateYesNoConVarVote(client, "sm_bbr_enabled", "Make all bots robots?");
		else if (StrEqual(info, "bots_helphelphelphelp"))
			Voting_CreateYesNoConVarVote(client, "sm_spyspyspyspy_enabled", "Make bots paranoid? (Silly)");
		else if (StrEqual(info, "bots_spyspyspyspy"))
			Voting_CreateYesNoConVarVote(client, "sm_helphelphelphelp_enabled", "Make bots stick together? (Silly)");
		else if (StrEqual(info, "bots_rtd"))
			Voting_CreateYesNoConVarVote(client, "sm_botrtd_enabled", "Should bots be able to use RTD? (RTD has to be enabled too)");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu");
	} else if (action == MenuAction_End)
		delete menu;
}
