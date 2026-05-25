#include <sourcemod>

Handle hudSync;
Handle hudTimer;

public void OnPluginStart()
{
	hudSync = CreateHudSynchronizer();
	hudTimer = CreateTimer(0.25, Timer_UpdateHud, _, TIMER_REPEAT);
}

public Action Timer_UpdateHud(Handle timer)
{
	SetHudTextParams(0.01, 0.01, 9999999999.0, 0, 153, 0, 127, 0, 0.0, 0.0);

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientConnected(i) && IsClientInGame(i))
			ShowSyncHudText(i, hudSync, "Ducky EU");

	return Plugin_Continue;
}

public void OnPluginEnd()
{
	delete hudTimer;
	delete hudSync;
}
