/** 
 * Used to set the Listen Overrides to normal for each client, for a certain sender. 
 *
 * @param client		Client index.
 * @noreturn
 */
void ResetListenOverrides(int client)
{
	for(int ListenerIndex = 1; ListenerIndex <= MaxClients; ++ListenerIndex)
	{
		if(IsClientConnected(ListenerIndex) && ListenerIndex != client)
		{
			SetListenOverride(ListenerIndex, client, Listen_Default);
		}
	}
}

/**
 * Used to reset the g_TeamID, and g_IsVoiceAltOn arrays, and the Listen Overrides for each client. 
 *
 * @noreturn
 */
void ResetClientListening()
{	
	for(int i = 1; i <= MaxClients; ++i)
	{
		if( IsClientConnected(i) )
		{
			ResetListenOverrides(i);
		}

		g_VoiceChatState[i] = VOICESTATE_NORMAL;
		g_TeamID[i] = 0;
	}
}

/**
 * Sets the Listen Overrides to Listen_No, for each client that is not on the same team as the sender.
 * This function is meant to be used when the alltalk is on.
 *
 * @param client		Client index.
 * @noreturn
 */
void DoVoiceAltAlltalkOnTeamOnly(int client)
{
	for(int ListenerIndex = 1; ListenerIndex <= MaxClients; ++ListenerIndex)
	{
		if( g_TeamID[client] != g_TeamID[ListenerIndex] && IsClientInGame(ListenerIndex) )
		{
			SetListenOverride(ListenerIndex, client, Listen_No);
		}
	}
}

/**
 * Sets the Listen Overrides for each client, for a certain sender. 
 * If they are not on the same team, the Listen Override will be set to Listen_No, otherwise set it to Listen_Default. 
 * This function is meant to be used when alltalk is on.
 *
 * @param client		Client index.
 * @noreturn
 */
void DoVoiceAltAlltalkOn(int client)
{
	for(int ListenerIndex = 1; ListenerIndex <= MaxClients; ++ListenerIndex)
	{
		if(g_TeamID[client] != g_TeamID[ListenerIndex])
		{
			if( IsClientInGame(ListenerIndex) )
			{
				SetListenOverride(ListenerIndex, client, Listen_No);
			}
		}
		else if( IsClientInGame(ListenerIndex) )
		{
			SetListenOverride(ListenerIndex, client, Listen_Default);
		}
	}
}

/**
 * Sets the Listen Overrides for each client to on, for a certain sender.
 * It is meant to be used when alltalk is off.
 *
 * @param client		Client index.
 * @noreturn
 */
void DoVoiceAltAlltalkOff(int client)
{
	for(int ListenerIndex = 1; ListenerIndex <= MaxClients; ++ListenerIndex)
	{
		if(IsClientInGame(ListenerIndex) && ListenerIndex != client)
		{
			SetListenOverride(ListenerIndex, client, Listen_Yes);
		}
	}
}

/**
 * Function to check if a client is muted.
 * This function is basically Client_IsMuted from smlib, written in SourcePawn Transitional Syntax.
 *
 * @param client		Client index.
 * @return				True if the client is muted, false otherwise.
 */
bool IsMutedFlagSet(int client)
{
	return view_as<bool>(GetClientListeningFlags(client) & VOICE_MUTED);
}