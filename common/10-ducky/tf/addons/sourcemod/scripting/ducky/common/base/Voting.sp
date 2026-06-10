#include <sourcemod>
#include <sdktools>
#include <server/serverchat>

const int countdown = 15;

ConVar g_convar;
char command_name[64];
char command2_name[64];
char friendly_name[64];
int true_value;
int false_value;
bool g_isBooleanVote;
bool vote_success = false;
StringMap g_hVoteValueDisplay;

bool IsVoteRunning() {
	return g_convar || command_name[0] || command2_name[0];
}

void ClearVote() {
	g_convar = null;
	command_name = "";
	command2_name = "";
	friendly_name = "";
	g_isBooleanVote = false;

	if (!vote_success)
		Server_PrintToChatAll("Vote", "No votes received; Vote failed.", true);
	vote_success = false;
}

void WarnClientVoteRunning(int client) {
	Server_PrintToChat(client, "Vote", "A vote is already in progress.", true);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("Voting_CreateYesNoConVarVote", Voting_CreateYesNoConVarVote);
	CreateNative("Voting_CreateStringConVarVote", Voting_CreateStringConVarVote);
	CreateNative("Voting_CreateYesNoCommandVote", Voting_CreateYesNoCommandVote);
	return APLRes_Success;
}

public void OnMapStart() {
	PrecacheSound("ui/vote_started.wav");
	PrecacheSound("ui/vote_success.wav");
	PrecacheSound("ui/vote_failure.wav");
	g_hVoteValueDisplay = new StringMap();
}

public int Voting_CreateYesNoConVarVote(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (IsVoteRunning()) {
		WarnClientVoteRunning(client);
		return;
	}

	char client_name[64];
	GetClientName(client, client_name, sizeof(client_name));

	char convar_name[128];
	GetNativeString(2, convar_name, sizeof(convar_name));
	g_convar = FindConVar(convar_name);
	if (g_convar == null) {
		char err[256];
		Format(err, sizeof(err), "ConVar '%s' not found.", convar_name);
		Server_PrintToChat(client, "Vote", err);
		return;
	}

	char question[128];
	GetNativeString(3, question, sizeof(question));
	true_value = GetNativeCell(4);
	false_value = GetNativeCell(5);

	if (numParams >= 6)
		GetNativeString(6, friendly_name, sizeof(friendly_name));
	else
		friendly_name[0] = '\0';

	g_isBooleanVote = (true_value == 0 && false_value != 0) || (true_value != 0 && false_value == 0);

	char text[128];
	Format(text, sizeof(text), "A vote has been started by %s.", client_name);

	Menu menu = new Menu(Handle_YesNoVoting);
	menu.SetTitle(question);
	menu.AddItem("yes", "Yes");
	menu.AddItem("no", "No");
	menu.ExitButton = false;
	menu.DisplayVoteToAll(countdown);
	Server_PrintToChatAll("Vote", text, true);

	EmitSoundToAll("ui/vote_started.wav");
}

public int Handle_YesNoVoting(Menu menu, MenuAction action, int choice, int param2) {
	if (action == MenuAction_VoteEnd) {
		int value;
		bool choice_yes = false;
		if (choice == 1) {
			value = false_value;
		} else if (choice == 0) {
			value = true_value;
			choice_yes = true;
		}

		char value_string[8];
		IntToString(value, value_string, sizeof(value_string));

		char oldValue[8];
		GetConVarString(g_convar, oldValue, sizeof(oldValue));
		char text[128];

		if (StrEqual(oldValue, value_string)) {
			if (friendly_name[0])
				Format(text, sizeof(text), "%s has been left unchanged.", friendly_name);
			else {
				char convar_name[64];
				GetConVarName(g_convar, convar_name, sizeof(convar_name));
				Format(text, sizeof(text), "%s has been left unchanged. (%s)", convar_name, value_string);
			}
		} else {
			SetConVarString(g_convar, value_string);
			if (friendly_name[0]) {
				if (g_isBooleanVote)
					Format(text, sizeof(text), "%s has been %s.", friendly_name, choice_yes ? "enabled" : "disabled");
				else
					Format(text, sizeof(text), "%s has been set to %s.", friendly_name, value_string);
			} else {
				char convar_name[64];
				GetConVarName(g_convar, convar_name, sizeof(convar_name));
				Format(text, sizeof(text), "%s has been set to %s.", convar_name, value_string);
			}
		}

		if (choice_yes)
			EmitSoundToAll("ui/vote_success.wav");
		else
			EmitSoundToAll("ui/vote_failure.wav");

		Server_PrintToChatAll("Vote", text, true);
		vote_success = true;
	} else if (action == MenuAction_End) {
		ClearVote();
		delete menu;
	}
}

public int Voting_CreateStringConVarVote(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (IsVoteRunning()) {
		WarnClientVoteRunning(client);
		return;
	}

	char client_name[64];
	GetClientName(client, client_name, sizeof(client_name));

	char convar_name[128];
	GetNativeString(2, convar_name, sizeof(convar_name));
	g_convar = FindConVar(convar_name);
	if (g_convar == null) {
		char err[256];
		Format(err, sizeof(err), "ConVar '%s' not found.", convar_name);
		Server_PrintToChat(client, "Vote", err);
		return;
	}

	char question[128];
	GetNativeString(3, question, sizeof(question));

	if (numParams >= 4)
		GetNativeString(4, friendly_name, sizeof(friendly_name));
	else
		friendly_name[0] = '\0';

	char text[128];
	Format(text, sizeof(text), "A vote has been started by %s.", client_name);

	Menu menu = new Menu(Handle_StringVoting);
	menu.SetTitle(question);

	g_hVoteValueDisplay.Clear();

	for (int i = 5; i <= numParams; i++) {
		char raw[64];
		GetNativeString(i, raw, sizeof(raw));
		int pos = StrContains(raw, "|");
		if (pos != -1) {
			raw[pos] = '\0';
			menu.AddItem(raw[pos + 1], raw);
			g_hVoteValueDisplay.SetString(raw[pos + 1], raw);
		} else {
			menu.AddItem(raw, raw);
		}
	}
	menu.ExitButton = false;
	menu.DisplayVoteToAll(countdown);
	Server_PrintToChatAll("Vote", text, true);

	EmitSoundToAll("ui/vote_started.wav");
}

public int Handle_StringVoting(Menu menu, MenuAction action, int choice, int param2) {
	if (action == MenuAction_VoteEnd) {
		char value[32];
		menu.GetItem(choice, value, sizeof(value));

		char oldValue[8];
		GetConVarString(g_convar, oldValue, sizeof(oldValue));
		char text[128];

		if (StrEqual(oldValue, value)) {
			if (friendly_name[0])
				Format(text, sizeof(text), "%s has been left unchanged.", friendly_name);
			else {
				char convar_name[64];
				GetConVarName(g_convar, convar_name, sizeof(convar_name));
				Format(text, sizeof(text), "%s has been left unchanged. (%s)", convar_name, value);
			}
		} else {
			SetConVarString(g_convar, value);
			if (friendly_name[0]) {
				char displayValue[32];
				if (g_hVoteValueDisplay.GetString(value, displayValue, sizeof(displayValue)))
					Format(text, sizeof(text), "%s has been set to %s.", friendly_name, displayValue);
				else
					Format(text, sizeof(text), "%s has been set to %s.", friendly_name, value);
			} else {
				char convar_name[64];
				GetConVarName(g_convar, convar_name, sizeof(convar_name));
				Format(text, sizeof(text), "%s has been set to %s.", convar_name, value);
			}
		}

		Server_PrintToChatAll("Vote", text, true);
		vote_success = true;
		EmitSoundToAll("ui/vote_success.wav");
	} else if (action == MenuAction_End) {
		ClearVote();
		delete menu;
	}
}

public int Voting_CreateYesNoCommandVote(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	if (IsVoteRunning()) {
		WarnClientVoteRunning(client);
		return;
	}

	char client_name[64];
	GetClientName(client, client_name, sizeof(client_name));

	GetNativeString(2, command_name, sizeof(command_name));

	char question[128];
	GetNativeString(3, question, sizeof(question));

	GetNativeString(4, command2_name, sizeof(command2_name));

	if (numParams >= 5)
		GetNativeString(5, friendly_name, sizeof(friendly_name));
	else
		friendly_name[0] = '\0';

	char text[128];
	Format(text, sizeof(text), "A vote has been started by %s.", client_name);

	Menu menu = new Menu(Handle_YesNoCommandVoting);
	menu.SetTitle(question);
	menu.AddItem("yes", "Yes");
	menu.AddItem("no", "No");
	menu.ExitButton = false;
	menu.DisplayVoteToAll(countdown);
	Server_PrintToChatAll("Vote", text, true);

	EmitSoundToAll("ui/vote_started.wav");
}

public Action Delay_DisableCheats(Handle timer) {
	ServerCommand("sv_cheats 0");

	return Plugin_Handled;
}

public int Handle_YesNoCommandVoting(Menu menu, MenuAction action, int choice, int param2) {
	if (action == MenuAction_VoteEnd) {
		char text[128];
		if (choice == 0) {
			ServerCommand(command_name);
			CreateTimer(0.01, Delay_DisableCheats);
			if (friendly_name[0]) {
				if (command2_name[0])
					Format(text, sizeof(text), "%s has been enabled.", friendly_name);
				else
					Format(text, sizeof(text), "%s has been executed.", friendly_name);
			} else {
				Format(text, sizeof(text), "%s has been executed.", command_name);
			}
			EmitSoundToAll("ui/vote_success.wav");
		} else if (choice == 1)
			if (command2_name[0]) {
				ServerCommand(command2_name);
				CreateTimer(0.01, Delay_DisableCheats);
				if (friendly_name[0])
					Format(text, sizeof(text), "%s has been disabled.", friendly_name);
				else
					Format(text, sizeof(text), "%s has been executed.", command2_name);
				EmitSoundToAll("ui/vote_success.wav");
			} else {
				if (friendly_name[0])
					Format(text, sizeof(text), "Vote for %s has failed.", friendly_name);
				else
					Format(text, sizeof(text), "Vote for %s has failed.", command_name);
				EmitSoundToAll("ui/vote_failure.wav");
			}
		Server_PrintToChatAll("Vote", text, true);
		vote_success = true;
	} else if (action == MenuAction_End) {
		ClearVote();
		delete menu;
	}
}
