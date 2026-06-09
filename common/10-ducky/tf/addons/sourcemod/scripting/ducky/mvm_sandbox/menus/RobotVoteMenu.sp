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

	if ((cvar = FindConVar("sm_bottaunt_enabled")) != null) {
		Format(text, sizeof(text), "Robots do a custom taunt on kill (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_taunt", text);
	}

	if ((cvar = FindConVar("tf_bot_melee_only")) != null) {
		Format(text, sizeof(text), "Robots only use melee (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("mvm_bots_melee", text);
	}

	if ((cvar = FindConVar("nb_blind")) != null) {
		Format(text, sizeof(text), "Robots are blind (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("mvm_bots_can_attack", text);
	}

	if ((cvar = FindConVar("sm_robotshuman_enabled")) != null) {
		Format(text, sizeof(text), "Robots are humans (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("mvm_bots_kartbots", text);
	}

	if ((cvar = FindConVar("sm_chargebots_enabled")) != null) {
		Format(text, sizeof(text), "Robots are aggressive (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_charge", text);
	}

	if ((cvar = FindConVar("sm_kartbots_enabled")) != null) {
		Format(text, sizeof(text), "Robots use bumper cars (Silly) (Currently: %b)", GetConVarBool(cvar));
		menu.AddItem("bots_bumpercart", text);
	}

	if ((cvar = FindConVar("sm_botrtd_mvmbots")) != null) {
		Format(text, sizeof(text), "Robots use RTD (Currently: %b)", GetConVarBool(cvar));
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
			Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make robots do a custom taunt on kill? (Silly)");
		else if (StrEqual(info, "mvm_bots_melee"))
			Voting_CreateYesNoConVarVote(client, "tf_bot_melee_only", "Make robots use melee only? (Silly)");
		else if (StrEqual(info, "mvm_bots_can_attack"))
			Voting_CreateYesNoConVarVote(client, "nb_blind", "Make robots blind? (Silly)");
		else if (StrEqual(info, "mvm_bots_kartbots"))
			Voting_CreateYesNoConVarVote(client, "sm_robotshuman_enabled", "Make spawned robots human? (Silly)");
		else if (StrEqual(info, "bots_charge"))
			Voting_CreateYesNoConVarVote(client, "sm_chargebots_enabled", "Make all robots aggressive? (Silly)");
		else if (StrEqual(info, "bots_bumpercart"))
			Voting_CreateYesNoConVarVote(client, "sm_kartbots_enabled", "Should all newly spawned robots use bumper cars? (Silly)");
		else if (StrEqual(info, "bots_rtd"))
			Voting_CreateYesNoConVarVote(client, "sm_botrtd_mvmbots", "Should robots be able to use RTD? (RTD and Bot RTD has to be enabled too)");
	} else if (action == MenuAction_Cancel) {
		if (item == MenuCancel_ExitBack)
			FakeClientCommand(client, "menu_bots");
	} else if (action == MenuAction_End)
		delete menu;
}
