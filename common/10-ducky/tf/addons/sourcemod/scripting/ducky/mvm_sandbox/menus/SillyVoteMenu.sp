#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	RegConsoleCmd("menu_server_silly", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	Menu menu = new Menu(Handle_Menu);
	menu.SetTitle("Silly settings");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	char text[128];
	ConVar cvar;
	char state[16];

	if ((cvar = FindConVar("sv_gravity")) != null) {
		Format(text, sizeof(text), "Gravity [%i]", GetConVarInt(cvar));
		menu.AddItem("silly_gravity", text);
	}

	if ((cvar = FindConVar("tf2x10_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "x10 mode (Respawn to apply) [%s]", state);
		menu.AddItem("silly_x10", text);
	}

	if ((cvar = FindConVar("sm_alwayscrits_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Always crits [%s]", state);
		menu.AddItem("silly_always_crits", text);
	}

	if ((cvar = FindConVar("goomba_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Goomba Stomping [%s]", state);
		menu.AddItem("silly_goomba_enabled", text);
	}

	if ((cvar = FindConVar("sm_rtd2_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "RTD [%s]", state);
		menu.AddItem("silly_rtd_enabled", text);
	}

	if ((cvar = FindConVar("tf_grapplinghook_enable")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Grappling Hook [%s]", state);
		menu.AddItem("silly_grappling_hook_enabled", text);
	}

	if ((cvar = FindConVar("sm_spells_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Spells [%s]", state);
		menu.AddItem("silly_spells_enabled", text);
	}

	if ((cvar = FindConVar("sm_aia_all")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Unlimited Ammo [%s]", state);
		menu.AddItem("silly_unlimitedammo", text);
	}

	if ((cvar = FindConVar("sm_hugeexplosions_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Huge Explosion Effects [%s]", state);
		menu.AddItem("silly_hugeexplosions", text);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));

		if (StrEqual(info, "silly_gravity"))
			Voting_CreateStringConVarVote(client, "sv_gravity", "Set Gravity (default: 800)", "Gravity", "10", "400", "800", "1600");
		else if (StrEqual(info, "silly_x10"))
			Voting_CreateYesNoConVarVote(client, "tf2x10_enabled", "Enable x10? (Respawn to apply)", 1, 0, "x10 mode");
		else if (StrEqual(info, "silly_always_crits"))
			Voting_CreateYesNoConVarVote(client, "sm_alwayscrits_enabled", "Enable always crits?", 1, 0, "Always crits");
		else if (StrEqual(info, "silly_goomba_enabled"))
			Voting_CreateYesNoConVarVote(client, "goomba_enabled", "Enable goomba stomping?", 1, 0, "Goomba stomping");
		else if (StrEqual(info, "silly_rtd_enabled"))
			Voting_CreateYesNoConVarVote(client, "sm_rtd2_enabled", "Enable RTD?", 1, 0, "RTD");
		else if (StrEqual(info, "silly_grappling_hook_enabled"))
			Voting_CreateYesNoConVarVote(client, "tf_grapplinghook_enable", "Enable Grappling Hook?", 1, 0, "Grappling hook");
		else if (StrEqual(info, "silly_spells_enabled"))
			Voting_CreateYesNoCommandVote(client, "tf_spells_enabled 1;sm_spells_enabled 1", "Enable spells?", "tf_spells_enabled 0;sm_spells_enabled 0", "Spells");
		else if (StrEqual(info, "silly_unlimitedammo"))
			Voting_CreateYesNoConVarVote(client, "sm_aia_all", "Enable unlimited ammo?", 1, 0, "Unlimited ammo");
		else if (StrEqual(info, "silly_hugeexplosions"))
			Voting_CreateYesNoConVarVote(client, "sm_hugeexplosions_enabled", "Enable huge explosion effects?", 1, 0, "Huge explosions");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu_server");
	} else if (action == MenuAction_End)
		delete menu;
}
