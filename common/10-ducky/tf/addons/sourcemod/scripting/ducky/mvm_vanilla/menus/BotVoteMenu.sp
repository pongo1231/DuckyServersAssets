#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>
#include <rcbot2>

ConVar g_enableBots;
ConVar g_rcbotQuota;

public void OnMapStart()
{
    CreateTimer(5.0, Delay_CheckWaypoints, _);
}

public Action Delay_CheckWaypoints(Handle timer)
{
    if (RCBot2_IsWaypointAvailable())
        return Plugin_Continue;

    SetConVarInt(g_enableBots, 0);
    return Plugin_Continue;
}

public void OnClientDisconnect_Post(int client)
{
    if (!RCBot2_IsWaypointAvailable())
        return;

    for (int client = 1; client < MaxClients + 1; client++)
        if (IsClientInGame(client) && !IsFakeClient(client))
            return;

    SetConVarInt(g_enableBots, 1);
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
    switch (item) {
            case 0:
                Voting_CreateYesNoConVarVote(client, "menu_bots_rcbot_enablebots", "Enable RCBots?");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}

public Action MenuOpen(int client, int args) {
    if (!RCBot2_IsWaypointAvailable())
    {
        Server_PrintToChat(client, "Menu", "This map does not support RCBots.");
        return Plugin_Continue;
    }

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Bot settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    Format(text, sizeof(text), "Enable RCBots (Currently: %b)", GetConVarBool(FindConVar("menu_bots_rcbot_enablebots")));
    menu.AddItem("bots_robots", text);

    menu.Display(client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public Action Timer_KickBots(Handle timer) {
    if (GetConVarInt(g_enableBots) < 1) {
        SetConVarInt(g_rcbotQuota, 0);
        for (int client = 1; client < MaxClients + 1; client++)
            if (IsClientInGame(client) && IsFakeClient(client) && TF2_GetClientTeam(client) == TFTeam_Red)
                KickClient(client);
    }
    else
        SetConVarInt(g_rcbotQuota, 1);
}

public void OnPluginStart() {
    RegConsoleCmd("menu_bots", MenuOpen);
    g_enableBots = CreateConVar("menu_bots_rcbot_enablebots", "1", _, _, true, 0.0, true, 1.0);
    g_rcbotQuota = FindConVar("rcbot_bot_quota_interval");
    CreateTimer(1.0, Timer_KickBots, _, TIMER_REPEAT);
}
