/** Double-include prevention */
#if defined _voting_natives_included_
  #endinput
#endif
#define _voting_natives_included_

/**
 * Returns "Enabled" or "Disabled" based on a ConVar's boolean value.
 *
 * @param cvar     The ConVar to check
 * @param buffer   Buffer to store the result
 * @param maxlen   Maximum length of buffer
 * @param inverted If true, inverts the meaning (0 = Enabled, 1 = Disabled)
 */
stock void FormatToggle(ConVar cvar, char[] buffer, int maxlen, bool inverted=false) {
	bool isEnabled = (cvar != null && GetConVarBool(cvar));
	if (inverted)
		isEnabled = !isEnabled;
	strcopy(buffer, maxlen, isEnabled ? "Enabled" : "Disabled");
}

/**
 * Returns a human-readable holiday name for a tf_forced_holiday value.
 *
 * @param value    The cvar's integer value
 * @param buffer   Buffer to store the result
 * @param maxlen   Maximum length of buffer
 */
stock void FormatHoliday(int value, char[] buffer, int maxlen) {
	if (value == 2)
		strcopy(buffer, maxlen, "Halloween");
	else if (value == 1)
		strcopy(buffer, maxlen, "Birthday");
	else if (value == 3)
		strcopy(buffer, maxlen, "Full Moon");
	else
		strcopy(buffer, maxlen, "Off");
}

/**
 * Creates a Boolean ConVar Change Vote Menu
 *
 * @param client        The client index that started the vote
 * @param convar        The ConVar to change
 * @param question      The question to show
 * @param true_value    Value to set when vote passes
 * @param false_value   Value to set when vote fails
 * @param friendlyName  Human-readable name for the setting (used in results)
 */
native void Voting_CreateYesNoConVarVote(int client, char[] convar, char[] question, int true_value=1, int false_value=0, const char[] friendlyName="");

/**
 * Creates a Multi-Value ConVar Change Vote Menu
 *
 * @param client        The client index that started the vote
 * @param convar        The ConVar to change
 * @param question      The question to show
 * @param friendlyName  Human-readable name for the setting (used in results)
 * @param values        The values to select from
 */
native void Voting_CreateStringConVarVote(int client, char[] convar, char[] question, const char[] friendlyName, char[] ...);

/**
 * Creates a Yes/No Vote for a Command Execution
 *
 * @param client        The client index that started the vote
 * @param commandYes    The Command to execute when vote passes
 * @param question      The question to show
 * @param commandNo     The Command to execute when vote fails (if empty, vote simply fails)
 * @param friendlyName  Human-readable name for the action/setting (used in results)
 */
native void Voting_CreateYesNoCommandVote(int client, char[] commandYes, char[] question, char[] commandNo="", const char[] friendlyName="");
