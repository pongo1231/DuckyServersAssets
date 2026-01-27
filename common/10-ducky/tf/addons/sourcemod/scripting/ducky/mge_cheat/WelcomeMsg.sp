#include <sourcemod>
#include <sdktools>
#include <server/serverchat>

ConVar g_Enabled;

public void OnPluginStart()
{
  g_Enabled = CreateConVar("sm_ducky_showwelcomemsg", "1");
}

public void OnClientPutInServer(int client)
{
  if (!GetConVarBool(g_Enabled))
    return;

  Server_PrintToChat(client, "Server", "NOTE: This server is protected by StAC anticheat. For HvH please visit our other MGE server: tf.ecmec.eu:27018 (also listed in /menu under \"Other Servers\").");
}
