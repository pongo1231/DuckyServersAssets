#include <sourcemod>
#include <server/serverchat>
#include <advanced_motd>

public void OnPluginStart()
{
    RegConsoleCmd("menu_radio", CmdRadio);
    AddCommandListener(SayHook, "say");
    AddCommandListener(SayHook, "say_team");
}

public Action SayHook(int client, const char[] cmd, int argc)
{
    if (!client || !IsClientInGame(client))
        return Plugin_Continue;

    char text[192];
    GetCmdArgString(text, sizeof(text));
    StripQuotes(text);

    if (StrEqual(text, "/radio", false))
    {
        ShowMenu(client);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action CmdRadio(int client, int args)
{
    if (client && IsClientInGame(client))
        ShowMenu(client);

    return Plugin_Handled;
}

void ShowMenu(int client)
{
    AdvMOTD_ShowMOTDPanel(client, "Radio", "https://ecmec.eu/radio", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
}

void OnMOTDFailure(int client, MOTDFailureReason reason)
{
    if (reason == MOTDFailure_Disabled)
        Server_PrintToChat(client, "Menu", "You have HTML MOTDs disabled.");
    else if (reason == MOTDFailure_Matchmaking)
        Server_PrintToChat(client, "Menu", "You cannot view HTML MOTDs because you joined via Quickplay.");
    else if(reason == MOTDFailure_QueryFailed)
        Server_PrintToChat(client, "Menu", "Unable to verify that you can view HTML MOTDs.");
    else
        Server_PrintToChat(client, "Menu", "Unable to verify that you can view HTML MOTDs for an unknown reason.");
}
