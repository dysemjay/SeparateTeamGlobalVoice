/**
 * The general intended behavior of these commands is that if one is turned "on", 
 * while another has already been turned "on", then the final result would be equivalent to, 
 * turning the former command off, and then turning the latter command on.
 *
 * An example is: entering "+voicealt", then entering "+voiceteam".
 * The result would be equivalent to: entering "+voicealt", then "-voicealt", and finally, "+voiceteam".
 *
 * Each of the "off" commands (-voicealt, -voiceglobal, -voiceteam), should only  work with its respective,
 * "on" command. (+voicealt, +voiceglobal, +voiceteam). For example: entering "+voicealt", then "-voiceteam",
 * should not change the current behavior, of "+voicealt".
 */ 

/* Action for VoiceAlt being turned on. */
public Action Command_VoiceAltOn(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}	

	if( IsMutedFlagSet(client) )
	{
		g_VoiceChatState[client] = VOICESTATE_ALT;
		return Plugin_Handled;
	}

	if(!g_boolAlltalk)
	{
		PrintToChat(client, "[SM] Your voice will be heard globally.");
		DoVoiceAltAlltalkOff(client);		
	}
	else
	{
		PrintToChat(client, "[SM] Your voice will only be heard by your team.");
		DoVoiceAltAlltalkOnTeamOnly(client);
	}

	g_VoiceChatState[client] = VOICESTATE_ALT;

	return Plugin_Handled;
}

/* Action for VoiceAlt being turned off. */
public Action Command_VoiceAltOff(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}

	if(g_VoiceChatState[client] != VOICESTATE_ALT)
	{
		return Plugin_Handled;
	}
	
	if( IsMutedFlagSet(client) )
	{
		g_VoiceChatState[client] = VOICESTATE_NORMAL;
		return Plugin_Handled;
	}
	
	ResetListenOverrides(client);
	
	g_VoiceChatState[client] = VOICESTATE_NORMAL;

	return Plugin_Handled;
}

/* Action for VoiceGlobal being turned on. */
public Action Command_VoiceGlobalOn(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}	

	if( IsMutedFlagSet(client) )
	{
		g_VoiceChatState[client] = VOICESTATE_GLOBAL;
		return Plugin_Handled;
	}

	PrintToChat(client, "[SM] Your voice will be heard globally.");
	if(!g_boolAlltalk)
	{
		DoVoiceAltAlltalkOff(client);		
	}
	else if( (g_VoiceChatState[client] & VOICESTATE_TEAM_OR_ALT) != 0 )
	{
		ResetListenOverrides(client);
	}

	g_VoiceChatState[client] = VOICESTATE_GLOBAL;

	return Plugin_Handled;
}

/* Action for VoiceGlobal being turned off. */
public Action Command_VoiceGlobalOff(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}

	if(g_VoiceChatState[client] != VOICESTATE_GLOBAL)
	{
		return Plugin_Handled;
	}
	
	if( IsMutedFlagSet(client) )
	{
		g_VoiceChatState[client] = VOICESTATE_NORMAL;	
		return Plugin_Handled;
	}
	
	if(!g_boolAlltalk)
	{
		ResetListenOverrides(client);
	}
	
	g_VoiceChatState[client] = VOICESTATE_NORMAL;

	return Plugin_Handled;
}

/* Action for VoiceTeam being turned on. */
public Action Command_VoiceTeamOn(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}	

	if( IsMutedFlagSet(client) )
	{
		g_VoiceChatState[client] = VOICESTATE_TEAM;
		return Plugin_Handled;
	}

	PrintToChat(client, "[SM] Your voice will only be heard by your team.");
	if(!g_boolAlltalk)
	{
		if( (g_VoiceChatState[client] & VOICESTATE_GLOBAL_OR_ALT) != 0 )
		{
			ResetListenOverrides(client);
		}
	}
	else
	{
		DoVoiceAltAlltalkOnTeamOnly(client);
	}
	
	g_VoiceChatState[client] = VOICESTATE_TEAM;

	return Plugin_Handled;
}

/* Action for VoiceTeam being turned off. */
public Action Command_VoiceTeamOff(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "[SM] %t", "Command is in-game only");
		return Plugin_Handled;
	}

	if(g_VoiceChatState[client] != VOICESTATE_TEAM)
	{
		return Plugin_Handled;
	}
	
	if( IsMutedFlagSet(client) )
	{
		g_VoiceChatState[client] = VOICESTATE_NORMAL;	
		return Plugin_Handled;
	}
	
	if(g_boolAlltalk)
	{
		ResetListenOverrides(client);
	}
	
	g_VoiceChatState[client] = VOICESTATE_NORMAL;

	return Plugin_Handled;
}
