#include <sourcemod>
#include <sdktools>
#include <rcbot2>

bool g_PlayingMvM = false;

public void OnPluginStart()
{
    CreateTimer(20.0, Timer_Check, _, TIMER_REPEAT);
}

public void OnMapStart()
{
    g_PlayingMvM = GameRules_GetProp("m_bPlayingMannVsMachine") > 0;

    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));
    if (StrEqual(mapName, "itemtest"))
        ChangeMap("Placeholder map");
}

void ChangeMap(char[] reason)
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "../../custom/pongo/cfg/mapcycle.txt");

    Handle file = OpenFile(path, "r", true);
    if (file == null)
        return;

    char maps[256][PLATFORM_MAX_PATH];
    int count = 0;

    char line[PLATFORM_MAX_PATH];
    while (!IsEndOfFile(file) && count < sizeof(maps))
    {
        ReadFileLine(file, line, sizeof(line));
        TrimString(line);

        if (line[0] == '\0' || line[0] == ';' || line[0] == '/')
            continue;

        strcopy(maps[count], sizeof(maps[]), line);
        count++;
    }

    CloseHandle(file);

    if (count == 0)
        return;

    int index = GetRandomInt(0, count - 1);
    ForceChangeLevel(maps[index], reason);
}

public Action Timer_Check(Handle timer)
{
    if (!RCBot2_IsWaypointAvailable())
    {
        ChangeMap("No waypoints");
        
        return Plugin_Continue;
    }

    if (g_PlayingMvM)
    {
        int obj = FindEntityByClassname(-1, "tf_objective_resource");
        if (obj == -1)
            return Plugin_Continue;

        if (GetEntProp(obj, Prop_Send, "m_nMannVsMachineWaveCount") != 0 || GetEntProp(obj, Prop_Send, "m_nMannVsMachineMaxWaveCount") != 0)
            return Plugin_Continue;
            
        ChangeMap("Broken popfile");
    }

    return Plugin_Continue;
}
