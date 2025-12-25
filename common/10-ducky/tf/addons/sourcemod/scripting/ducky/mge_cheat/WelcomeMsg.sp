#include <sourcemod>
#include <sdktools>
#include <server/serverchat>

public void OnClientPutInServer(int client)
{
  Server_PrintToChat(client, "Server", "NOTE: This server is protected by StAC anticheat. For HvH please visit our other MGE server: tf.gopong.dev:27018 (also listed in /menu under \"Other Servers\").");
}
