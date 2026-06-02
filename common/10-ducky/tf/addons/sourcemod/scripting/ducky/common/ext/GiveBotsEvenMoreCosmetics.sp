// Give Bots More Cosmetics
// Original by PC Gamer - decompiled and rewritten with name-seeding + no-reroll

#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "2.0"

ConVar g_hCVEnabled;
ConVar g_hCVMVMREDEnabled;
ConVar g_hCVTimer;
Handle g_hEquipWearable;
bool g_bLateLoad;
bool g_bMVM;
bool g_bTouched[MAXPLAYERS + 1];
bool g_bCosmeticsGiven[MAXPLAYERS + 1];
int g_iSeedCounter;

// --- Seeded random ---

int HashString(const char[] str)
{
	int hash = 5381;
	for (int i = 0; str[i] != '\0'; i++)
		hash = ((hash << 5) + hash) + str[i];
	return hash;
}

int SeededRandom(int seed, int subid, int max)
{
	int val = ((seed * 1103515245 + subid * 12345 + 12345) ^ (seed >> 16)) & 0x7fffffff;
	return (val % max) + 1;
}

int BotRandom(int client, int min, int max)
{
	if (!g_bCosmeticsGiven[client])
	{
		char name[64];
		GetClientName(client, name, sizeof(name));
		int seed = HashString(name) + view_as<int>(TF2_GetPlayerClass(client));
		g_iSeedCounter++;
		return SeededRandom(seed, g_iSeedCounter, max - min + 1) + min - 1;
	}
	return GetRandomUInt(min, max);
}

// --- Helpers ---

int GetRandomUInt(int min, int max)
{
	return min + RoundToFloor(GetURandomFloat() * (max - min + 1));
}

bool IsPlayerHere(int client)
{
	if (client < 1 || IsClientSourceTV(client) || IsClientReplay(client))
		return false;
	return client && IsClientInGame(client) && IsFakeClient(client);
}

void CreateHat(int client, int itemindex, int level, int quality, int flags = 0)
{
	int entity = CreateEntityByName("tf_wearable");
	if (!IsValidEntity(entity)) return;

	char netclass[64];
	GetEntityNetClass(entity, netclass, sizeof(netclass));
	SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", itemindex);
	SetEntProp(entity, Prop_Send, "m_bInitialized", 1);
	SetEntData(entity, FindSendPropInfo(netclass, "m_iEntityQuality"), quality);
	SetEntProp(entity, Prop_Send, "m_iEntityLevel", level);

	DispatchSpawn(entity);
	SDKCall(g_hEquipWearable, client, entity);
}

void RemoveAllWearables(int client)
{
	int edict = MaxClients + 1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)))
		{
			if (StrEqual(netclass, "CTFWearable", true))
			{
				if (client == GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity"))
				{
					if (!GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
						AcceptEntityInput(edict, "Kill");
				}
			}
		}
	}
}

bool BotStillHasCosmetics(int client)
{
	if (!g_bCosmeticsGiven[client])
		return false;

	int count = 0;
	int edict = MaxClients + 1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		if (IsValidEntity(edict))
		{
			if (client == GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity"))
			{
				if (!GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
					count++;
			}
		}
	}
	return count >= 2;
}

// --- Plugin lifecycle ---

public Plugin myinfo =
{
	name = "Give Bots More Cosmetics",
	author = "PC Gamer",
	description = "Gives TF2 bots pre-made cosmetic sets",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	char game[32];
	GetGameFolderName(game, sizeof(game));
	if (!StrEqual(game, "tf") && !StrEqual(game, "tf_beta"))
	{
		Format(error, err_max, "This plugin only works for TF2 or TF2 Beta.");
		return APLRes_Failure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("sm_gbmc_version", PLUGIN_VERSION, "Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_hCVEnabled = CreateConVar("sm_gbmc_enabled", "1", "Enables/disables this plugin", _, true, 0.0, true, 1.0);
	g_hCVMVMREDEnabled = CreateConVar("sm_gbmc_MVM_red_enabled", "1", "Enable RED team cosmetics in MvM", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCVTimer = CreateConVar("sm_gbmc_delay", "0.1", "Delay for giving cosmetics to bots", _, true, 0.1, true, 30.0);
	HookEvent("post_inventory_application", player_inv, EventHookMode_Post);
	HookConVarChange(g_hCVEnabled, OnEnabledChanged);

	if (g_bLateLoad)
		OnMapStart();

	GameData hTF2 = new GameData("sm-tf2.games");
	if (!hTF2)
		SetFailState("This plugin is designed for a TF2 dedicated server only.");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(hTF2.GetOffset("RemoveWearable") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hEquipWearable = EndPrepSDKCall();

	if (!g_hEquipWearable)
		SetFailState("Failed to create call: CBasePlayer::EquipWearable");

	delete hTF2;
}

public void OnEnabledChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (GetConVarBool(g_hCVEnabled))
		HookEvent("post_inventory_application", player_inv, EventHookMode_Post);
	else
		UnhookEvent("post_inventory_application", player_inv, EventHookMode_Post);
}

public void OnMapStart()
{
	if (GameRules_GetProp("m_bPlayingMannVsMachine"))
		g_bMVM = true;
}

public void OnClientDisconnect(int client)
{
	g_bTouched[client] = false;
	g_bCosmeticsGiven[client] = false;
}

// --- Inventory event ---

public void player_inv(Event event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(g_hCVEnabled))
		return;

	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	if (!g_bMVM)
	{
		if (!g_bTouched[client])
		{
			if (IsPlayerHere(client))
			{
				RemoveAllWearables(client);
				g_bTouched[client] = true;
				CreateTimer(GetConVarFloat(g_hCVTimer), Timer_GiveHat, userid);
			}
		}
		return;
	}

	// MvM: only RED gets cosmetics
	if (GetConVarBool(g_hCVMVMREDEnabled) && IsPlayerHere(client)
	    && GetClientTeam(client) == 2)
	{
		if (!g_bTouched[client])
		{
			RemoveAllWearables(client);
			g_bTouched[client] = true;
			CreateTimer(GetConVarFloat(g_hCVTimer), Timer_GiveHat, userid);
		}
	}
}

public Action Timer_GiveHat(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	g_bTouched[client] = false;

	if (!GetConVarBool(g_hCVEnabled) || !IsPlayerHere(client))
		return Plugin_Stop;

	// Skip if they already have cosmetics from a previous spawn/resupply
	if (BotStillHasCosmetics(client))
	{
		g_bCosmeticsGiven[client] = true;
		return Plugin_Stop;
	}

	g_iSeedCounter = 0;
	g_bCosmeticsGiven[client] = false;

	GiveHat2(client);
	return Plugin_Stop;
}

void GiveHat2(int client)
{
	g_bTouched[client] = false;
	if (!GetConVarBool(g_hCVEnabled) || !IsPlayerHere(client))
		return;

	int totalPresets = 102;
	int preset = BotRandom(client, 1, totalPresets);

	switch (preset)
	{
	case 1:
	{
		CreateHat(client, 139, 10, 6, 1);
		CreateHat(client, 30104, 10, 6);
		CreateHat(client, 955, 10, 6);
	}
	case 2:
	{
		CreateHat(client, 30066, 10, 6, 1);
		CreateHat(client, 30397, 10, 6);
		CreateHat(client, 30309, 10, 6);
	}
	case 3:
	{
		CreateHat(client, 30413, 10, 6, 1);
		CreateHat(client, 30085, 10, 6);
		CreateHat(client, 30309, 10, 6);
	}
	case 4:
	{
		CreateHat(client, 1186, 10, 6, 1);
		CreateHat(client, 743, 10, 6);
		CreateHat(client, 30923, 10, 6);
	}
	case 5:
	{
		CreateHat(client, 30882, 10, 6, 1);
		CreateHat(client, 743, 10, 6);
		CreateHat(client, 30881, 10, 6);
	}
	case 6:
	{
		CreateHat(client, 30915, 10, 6, 1);
		CreateHat(client, 30878, 10, 6);
		CreateHat(client, 30880, 10, 6);
	}
	case 7:
	{
		CreateHat(client, 30329, 10, 6, 1);
		CreateHat(client, 1025, 10, 6);
		CreateHat(client, 30551, 10, 6);
	}
	case 8:
	{
		CreateHat(client, 30362, 10, 6, 1);
		CreateHat(client, 30104, 10, 6);
		CreateHat(client, 296, 10, 6);
	}
	case 9:
	{
		CreateHat(client, 30623, 10, 6, 1);
		CreateHat(client, 143, 10, 6);
		CreateHat(client, 30726, 10, 6);
	}
	case 10:
	{
		CreateHat(client, 30646, 10, 6);
		CreateHat(client, 30658, 10, 6);
		CreateHat(client, 733, 10, 6);
	}
	case 11:
	{
		CreateHat(client, 30066, 10, 6, 1);
		CreateHat(client, 30068, 10, 6);
		CreateHat(client, 30607, 10, 6);
	}
	case 12:
	{
		CreateHat(client, 30740, 10, 6, 1);
		CreateHat(client, 30722, 10, 6);
		CreateHat(client, 30738, 10, 6);
	}
	case 13:
	{
		CreateHat(client, 471, 10, 6, 1);
		CreateHat(client, 30309, 10, 6);
		CreateHat(client, 30551, 10, 6);
	}
	case 14:
	{
		CreateHat(client, 30974, 10, 6, 1);
		CreateHat(client, 30972, 10, 6);
		CreateHat(client, 30923, 10, 6);
	}
	case 15:
	{
		CreateHat(client, 1185, 10, 6, 1);
		CreateHat(client, 30878, 10, 6);
		CreateHat(client, 30880, 10, 6);
	}
	case 16:
	{
		CreateHat(client, 30838, 10, 6, 1);
		CreateHat(client, 30706, 10, 6);
		CreateHat(client, 30929, 10, 6);
	}
	case 17:
	{
		CreateHat(client, 30829, 10, 6, 1);
		CreateHat(client, 30972, 10, 6);
		CreateHat(client, 9229, 10, 6);
	}
	case 18:
	{
		CreateHat(client, 30759, 10, 6, 1);
		CreateHat(client, 30706, 10, 6);
		CreateHat(client, 30757, 10, 6);
	}
	case 19:
	{
		CreateHat(client, 30814, 10, 6, 1);
		CreateHat(client, 30706, 10, 6);
		CreateHat(client, 30929, 10, 6);
	}
	case 20:
	{
		CreateHat(client, 470, 10, 6, 1);
		CreateHat(client, 486, 10, 6);
		CreateHat(client, 30726, 10, 6);
	}
	case 21:
	{
		CreateHat(client, 702, 10, 6, 1);
		CreateHat(client, 30551, 10, 6);
		CreateHat(client, 30198, 10, 6);
	}
	case 22:
	{
		CreateHat(client, 30542, 10, 6, 1);
		CreateHat(client, 30551, 10, 6);
		CreateHat(client, 30972, 10, 6);
	}
	case 23:
	{
		CreateHat(client, 1186, 10, 6, 1);
		CreateHat(client, 143, 10, 6);
		CreateHat(client, 30929, 10, 6);
	}
	case 24:
	{
		CreateHat(client, 1185, 10, 6, 1);
		CreateHat(client, 143, 10, 6);
		CreateHat(client, 30929, 10, 6);
	}
	case 25:
	{
		CreateHat(client, 31058, 10, 6, 1);
		CreateHat(client, 31060, 10, 6);
		CreateHat(client, 31061, 10, 6);
	}
	case 26:
	{
		CreateHat(client, 31173, 10, 6, 1);
		CreateHat(client, 31093, 10, 6);
		CreateHat(client, 31167, 10, 6);
	}
	case 27:
	{
		CreateHat(client, 31245, 10, 6, 1);
		CreateHat(client, 30972, 10, 6);
	}
	case 28:
	{
		CreateHat(client, 31259, 10, 6, 1);
		CreateHat(client, 30972, 10, 6);
	}
	case 29:
	{
		CreateHat(client, 31183, 10, 6, 1);
		CreateHat(client, 30929, 10, 6);
	}
	case 30:
	{
		CreateHat(client, 116, 10, 6, 1);
		CreateHat(client, 744, 10, 6);
		CreateHat(client, 166, 10, 6);
	}
	case 31:
	{
		CreateHat(client, 279, 10, 6, 1);
		CreateHat(client, 583, 10, 6);
	}
	case 32:
	{
		CreateHat(client, 189, 10, 6, 1);
		CreateHat(client, 432, 10, 6);
	}
	case 33:
	{
		CreateHat(client, 30058, 10, 6, 1);
	}
	case 34:
	{
		CreateHat(client, 263, 10, 6, 1);
	}
	case 35:
	{
		CreateHat(client, 30885, 10, 6, 1);
	}
	case 36:
	{
		CreateHat(client, 1899, 10, 6, 1);
		CreateHat(client, 623, 10, 6);
	}
	case 37:
	{
		CreateHat(client, 471, 10, 6, 1);
		CreateHat(client, 343, 10, 6);
		CreateHat(client, 242, 10, 6);
	}
	case 38:
	{
		CreateHat(client, 537, 10, 6, 1);
		CreateHat(client, 619, 10, 6);
		CreateHat(client, 31167, 10, 6);
	}
	case 39:
	{
		CreateHat(client, 30571, 10, 6, 1);
	}
	case 40:
	{
		CreateHat(client, 756, 10, 6, 1);
	}
	case 41:
	{
		CreateHat(client, 956, 10, 6, 1);
	}
	case 42:
	{
		CreateHat(client, 523, 10, 6, 1);
		CreateHat(client, 522, 10, 6);
	}
	case 43:
	{
		CreateHat(client, 126, 10, 6, 1);
		CreateHat(client, 143, 10, 6);
	}
	case 44:
	{
		CreateHat(client, 30118, 10, 6, 1);
	}
	case 45:
	{
		CreateHat(client, 817, 10, 6, 1);
		CreateHat(client, 816, 10, 6);
	}
	case 46:
	{
		CreateHat(client, 30065, 10, 6, 1);
	}
	case 47:
	{
		CreateHat(client, 634, 10, 6, 1);
	}
	case 48:
	{
		CreateHat(client, 785, 10, 6, 1);
	}
	case 49:
	{
		CreateHat(client, 333, 10, 6, 1);
	}
	case 50:
	{
		CreateHat(client, 334, 10, 6, 1);
	}
	case 51:
	{
		CreateHat(client, 332, 10, 6, 1);
	}
	case 52:
	{
		CreateHat(client, 408, 10, 6, 1);
	}
	case 53:
	{
		CreateHat(client, 409, 10, 6, 1);
	}
	case 54:
	{
		CreateHat(client, 410, 10, 6, 1);
	}
	case 55:
	{
		CreateHat(client, 2122, 10, 6, 1);
	}
	case 56:
	{
		CreateHat(client, 2111, 10, 6, 1);
	}
	case 57:
	{
		CreateHat(client, 1011, 10, 6, 1);
		CreateHat(client, 31086, 10, 6);
	}
	case 58:
	{
		CreateHat(client, 135, 10, 6, 1);
		CreateHat(client, 1122, 10, 6);
	}
	case 59:
	{
		CreateHat(client, 31172, 10, 6, 1);
		CreateHat(client, 31260, 10, 6);
		CreateHat(client, 31252, 10, 6);
	}
	case 60:
	{
		CreateHat(client, 278, 10, 6, 1);
		CreateHat(client, 583, 10, 6);
	}
	case 61:
	{
		CreateHat(client, 31165, 10, 6, 1);
		CreateHat(client, 992, 10, 6);
		CreateHat(client, 30972, 10, 6);
	}
	case 62:
	{
		CreateHat(client, 30297, 10, 6, 1);
	}
	case 63:
	{
		CreateHat(client, 31171, 10, 6, 1);
		CreateHat(client, 995, 10, 6);
	}
	case 64:
	{
		CreateHat(client, 277, 10, 6, 1);
	}
	case 65:
	{
		CreateHat(client, 125, 10, 6, 1);
		CreateHat(client, 31135, 10, 6);
	}
	case 66:
	{
		CreateHat(client, 115, 10, 6, 1);
	}
	case 67:
	{
		CreateHat(client, 302, 10, 6, 1);
		CreateHat(client, 30306, 10, 6);
		CreateHat(client, 953, 10, 6);
	}
	case 68:
	{
		CreateHat(client, 341, 10, 6, 1);
		CreateHat(client, 992, 10, 6);
		CreateHat(client, 31093, 10, 6);
	}
	case 69:
	{
		CreateHat(client, 582, 10, 6, 1);
	}
	case 70:
	{
		CreateHat(client, 31044, 10, 6, 1);
		CreateHat(client, 583, 10, 6);
	}
	case 71:
	{
		CreateHat(client, 666, 10, 6, 1);
		CreateHat(client, 655, 10, 6);
	}
	case 72:
	{
		CreateHat(client, 31071, 10, 6, 1);
		CreateHat(client, 242, 10, 6);
	}
	case 73:
	{
		CreateHat(client, 756, 10, 6, 1);
		CreateHat(client, 242, 10, 6);
	}
	case 74:
	{
		CreateHat(client, 941, 10, 6, 1);
		CreateHat(client, 583, 10, 6);
	}
	case 75:
	{
		CreateHat(client, 984, 10, 6, 1);
		CreateHat(client, 987, 10, 6);
	}
	case 76:
	{
		CreateHat(client, 1164, 10, 6, 1);
		CreateHat(client, 1170, 10, 6, 1);
	}
	case 77:
	{
		CreateHat(client, 1169, 10, 6, 1);
		CreateHat(client, 1171, 10, 6);
	}
	case 78:
	{
		CreateHat(client, 30646, 10, 6, 1);
		CreateHat(client, 30669, 10, 6);
	}
	case 79:
	{
		CreateHat(client, 30700, 10, 6, 1);
	}
	case 80:
	{
		CreateHat(client, 30733, 10, 6, 1);
		CreateHat(client, 30726, 10, 6);
		CreateHat(client, 30722, 10, 6);
	}
	case 81:
	{
		CreateHat(client, 30915, 10, 6, 1);
		CreateHat(client, 30883, 10, 6);
	}
	case 82:
	{
		CreateHat(client, 31104, 10, 6, 1);
		CreateHat(client, 31062, 10, 6);
		CreateHat(client, 31105, 10, 6);
	}
	case 83:
	{
		CreateHat(client, 667, 10, 6, 1);
		CreateHat(client, 31251, 10, 6);
		CreateHat(client, 31167, 10, 6);
	}
	case 84:
	{
		CreateHat(client, 289, 10, 6, 1);
		CreateHat(client, 869, 10, 6);
		CreateHat(client, 927, 10, 6);
	}
	case 85:
	{
		CreateHat(client, 640, 10, 6, 1);
		CreateHat(client, 30309, 10, 6);
	}
	case 86:
	{
		CreateHat(client, 260, 10, 6, 1);
		CreateHat(client, 30309, 10, 6);
	}
	case 87:
	{
		CreateHat(client, 1158, 10, 6, 1);
		CreateHat(client, 31208, 10, 6);
	}
	case 88:
	{
		CreateHat(client, 470, 10, 6, 1);
	}
	case 89:
	{
		CreateHat(client, 1173, 10, 6, 1);
	}
	case 90:
	{
		CreateHat(client, 712, 10, 6, 1);
		CreateHat(client, 655, 10, 6);
		CreateHat(client, 31251, 10, 6);
	}
	case 91:
	{
		CreateHat(client, 711, 10, 6, 1);
		CreateHat(client, 245, 10, 6);
		CreateHat(client, 31293, 10, 6);
	}
	case 92:
	{
		CreateHat(client, 713, 10, 6, 1);
		CreateHat(client, 623, 10, 6);
		CreateHat(client, 30880, 10, 6);
	}
	case 93:
	{
		CreateHat(client, 31443, 10, 6, 1);
		CreateHat(client, 31442, 10, 6);
	}
	case 94:
	{
		CreateHat(client, 31383, 10, 6, 1);
		CreateHat(client, 31386, 10, 6);
	}
	case 95:
	{
		CreateHat(client, 30297, 10, 6, 1);
	}
	case 96:
	{
		CreateHat(client, 30928, 10, 6, 1);
		CreateHat(client, 738, 10, 6);
	}
	case 97:
	{
		CreateHat(client, 31415, 10, 6, 1);
		CreateHat(client, 31416, 10, 6);
	}
	case 98:
	{
		CreateHat(client, 31442, 10, 6);
	}
	case 99:
	{
		CreateHat(client, 30484, 10, 6, 1);
	}
	case 100:
	{
		CreateHat(client, 30497, 10, 6);
		CreateHat(client, 30571, 10, 6);
	}
	case 101:
	{
		CreateHat(client, 30796, 10, 6);
		CreateHat(client, 31471, 10, 6);
		CreateHat(client, 987, 10, 6);
	}
	case 102:
	{
		CreateHat(client, 31470, 10, 6, 1);
	}
	}

	g_bCosmeticsGiven[client] = true;
}
