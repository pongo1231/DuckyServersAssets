#include <sourcemod>
#include <server/serverchat>

#define MAX_ADS 64
#define MAX_AD_LEN 512

char ads[MAX_ADS][MAX_AD_LEN];
int size = 0;
int pointer = 0;

public void OnPluginStart()
{
    UpdateAds();
    CreateTimer(180.0, Timer_DisplayAd, _, TIMER_REPEAT);
}

public void OnClientPostAdminCheck(int client)
{
    if (IsFakeClient(client))
        return;

    Server_PrintToChat(client, "Server", "Welcome to the server! You can open the server menu by typing /menu.");
    Server_PrintToChat(client, "Server", "Make sure to check out our steam group: steamcommunity.com/groups/duckyservers");
}

public Action Timer_DisplayAd(Handle timer)
{
    if (!IsServerProcessing() || size <= 0)
        return Plugin_Continue;

    Server_PrintToChatAll("Server", ads[pointer]);

    pointer++;
    if (pointer >= size)
        pointer = 0;

    return Plugin_Handled;
}

bool HasTxtExtension(const char[] filename)
{
    int len = strlen(filename);
    if (len < 4)
        return false;

    return StrEqual(filename[len - 4], ".txt", false);
}


void UpdateAds()
{
    char dirPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, dirPath, sizeof(dirPath), "configs/ads");

    DirectoryListing dir = OpenDirectory(dirPath);
    if (dir == null)
    {
        LogError("Failed to open ads directory: %s", dirPath);
        return;
    }

    char fileName[PLATFORM_MAX_PATH];
    FileType type;

    size = 0;
    pointer = 0;

    while (dir.GetNext(fileName, sizeof(fileName), type))
    {
        if (type != FileType_File)
            continue;

        if (!HasTxtExtension(fileName))
            continue;

        char filePath[PLATFORM_MAX_PATH];
        Format(filePath, sizeof(filePath), "%s/%s", dirPath, fileName);

        ReadAdsFromFile(filePath);

        if (size >= MAX_ADS)
            break;
    }

    delete dir;

    LogMessage("Loaded %d ads", size);
}

void ReadAdsFromFile(const char[] path)
{
    Handle fileHandle = OpenFile(path, "r");
    if (fileHandle == null)
    {
        LogError("Failed to open ads file: %s", path);
        return;
    }

    char line[MAX_AD_LEN];

    while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line)))
    {
        TrimString(line);

        if (line[0] == '\0')
            continue;

        if (size >= MAX_ADS)
            break;

        strcopy(ads[size], sizeof(ads[]), line);
        size++;
    }

    delete fileHandle;
}
