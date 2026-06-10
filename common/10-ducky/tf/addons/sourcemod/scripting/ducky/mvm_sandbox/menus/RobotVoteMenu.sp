#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
	RegConsoleCmd("menu_bots_robots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle("Robot settings");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	char text[128];
	ConVar cvar;
	char state[16];

	if ((cvar = FindConVar("sm_bottaunt_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots do a custom taunt on kill [%s]", state);
		menu.AddItem("bots_taunt", text);
	}

	if ((cvar = FindConVar("tf_bot_melee_only")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots only use melee [%s]", state);
		menu.AddItem("mvm_bots_melee", text);
	}

	if ((cvar = FindConVar("nb_blind")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots are blind [%s]", state);
		menu.AddItem("mvm_bots_can_attack", text);
	}

	if ((cvar = FindConVar("sm_robotshuman_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots are humans [%s]", state);
		menu.AddItem("mvm_bots_kartbots", text);
	}

	if ((cvar = FindConVar("sm_chargebots_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots are aggressive [%s]", state);
		menu.AddItem("bots_charge", text);
	}

	if ((cvar = FindConVar("sm_kartbots_enabled")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots use bumper cars [%s]", state);
		menu.AddItem("bots_bumpercart", text);
	}

	if ((cvar = FindConVar("sm_botrtd_mvmbots")) != null) {
		FormatToggle(cvar, state, sizeof(state));
		Format(text, sizeof(text), "Robots use RTD [%s]", state);
		menu.AddItem("bots_rtd", text);
	}

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select) {
		char info[32];
		GetMenuItem(menu, item, info, sizeof(info));

		if (StrEqual(info, "bots_taunt"))
			Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make robots do a custom taunt on kill?", 1, 0, "Robot kill taunts");
		else if (StrEqual(info, "mvm_bots_melee"))
			Voting_CreateYesNoConVarVote(client, "tf_bot_melee_only", "Make robots use melee only?", 1, 0, "Robot melee only");
		else if (StrEqual(info, "mvm_bots_can_attack"))
			Voting_CreateYesNoConVarVote(client, "nb_blind", "Make robots blind?", 1, 0, "Robot blindness");
		else if (StrEqual(info, "mvm_bots_kartbots"))
			Voting_CreateYesNoConVarVote(client, "sm_robotshuman_enabled", "Make spawned robots human?", 1, 0, "Human robots");
		else if (StrEqual(info, "bots_charge"))
			Voting_CreateYesNoConVarVote(client, "sm_chargebots_enabled", "Make all robots aggressive?", 1, 0, "Aggressive robots");
		else if (StrEqual(info, "bots_bumpercart"))
			Voting_CreateYesNoConVarVote(client, "sm_kartbots_enabled", "Should all newly spawned robots use bumper cars?", 1, 0, "Robot bumper cars");
		else if (StrEqual(info, "bots_rtd"))
			Voting_CreateYesNoConVarVote(client, "sm_botrtd_mvmbots", "Should robots be able to use RTD? (RTD and Bot RTD has to be enabled too)", 1, 0, "Robot RTD");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu_bots");
	} else if (action == MenuAction_End)
		delete menu;
}
