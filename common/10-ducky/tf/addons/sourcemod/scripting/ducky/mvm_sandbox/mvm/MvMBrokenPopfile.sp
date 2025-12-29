#include <sourcemod>
#include <sdktools>

bool g_PlayingMvM = false;

public void OnPluginStart()
{
    CreateTimer(10.0, Timer_CheckMission, _, TIMER_REPEAT);
}

public void OnMapStart()
{
    g_PlayingMvM = GameRules_GetProp("m_bPlayingMannVsMachine") != -1;
}

bool GetRandomMap(char[] map, int maxlen)
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "../../custom/mvm_sandbox/cfg/mapcycle.txt");

    Handle file = OpenFile(path, "r", true);
    if (file == null)
        return false;

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
        return false;

    int index = GetRandomInt(0, count - 1);
    strcopy(map, maxlen, maps[index]);

    return true;
}

public Action Timer_CheckMission(Handle timer)
{
    if (!g_PlayingMvM)
        return Plugin_Continue;

    int obj = FindEntityByClassname(-1, "tf_objective_resource");
    if (obj == -1)
        return Plugin_Continue;

    if (GetEntProp(obj, Prop_Send, "m_nMannVsMachineMaxWaveCount") != 0)
        return Plugin_Continue;

    char map[PLATFORM_MAX_PATH];
    if (!GetRandomMap(map, sizeof(map)))
        return Plugin_Continue;

    ForceChangeLevel(map, "Broken popfile");

    return Plugin_Continue;
}
