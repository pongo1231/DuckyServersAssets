#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_redirect", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_VoteMenu);
    menu.SetTitle("Other servers");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    menu.AddItem("tf.ecmec.eu:27017", "EU | Sandbox");
    menu.AddItem("tf.ecmec.eu:27021", "EU | Sandbox 2");
    menu.AddItem("tf.ecmec.eu:27016", "EU | MvM Sandbox");
    menu.AddItem("tf.ecmec.eu:27022", "EU | MvM Sandbox 2");
    menu.AddItem("tf.ecmec.eu:27015", "EU | MvM Vanilla");
    menu.AddItem("tf.ecmec.eu:27019", "EU | MGE");
    menu.AddItem("tf.ecmec.eu:27020", "EU | MGE 2");
    menu.AddItem("tf.ecmec.eu:27018", "EU | MGE HvH");
    menu.AddItem("tf.ecmec.eu:27025", "EU | MGE HvH 2");
    
    menu.AddItem("tf2.ecmec.eu:27019", "US | MGE");
    menu.AddItem("tf2.ecmec.eu:27018", "US | MGE HvH");
    menu.AddItem("tf2.ecmec.eu:27016", "US | MvM Sandbox");

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        char item_info[32];
        if (GetMenuItem(menu, item, item_info, sizeof(item_info)))
            DisplayAskConnectBox(client, 10.0, item_info);
    }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}
