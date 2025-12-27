#include <sourcemod>
#include <sdktools>

bool g_PlayingMvM = false;

public void OnPluginStart()
{
    CreateTimer(20.0, Timer_CheckMission, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapStart()
{
    g_PlayingMvM = GameRules_GetProp("m_bPlayingMannVsMachine") != -1;
}

public Action Timer_CheckMission(Handle timer)
{
    if (!g_PlayingMvM)
        return Plugin_Continue;

    if (GetEntProp(FindEntityByClassname(-1, "tf_objective_resource"), Prop_Send, "m_nMannVsMachineMaxWaveCount") != 0)
        return Plugin_Continue;

    char buf[PLATFORM_MAX_PATH];
    ServerCommandEx(buf, sizeof(buf), "nextmap");
    char map[PLATFORM_MAX_PATH];
    strcopy(map, sizeof(map), buf[StrContains(buf, ": ", false) + 2]);
    TrimString(map);
    ForceChangeLevel(map, "Broken popfile");

    return Plugin_Continue;
}
