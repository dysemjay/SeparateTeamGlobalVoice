#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

/* Define flags for voice chat state. */
#define VOICESTATE_NORMAL 0 /* Normal behavior. */
#define VOICESTATE_TEAM 1 /* Only team members may hear. */
#define VOICESTATE_GLOBAL 2 /* All players may hear. */
#define VOICESTATE_ALT 4 /* Voice chat will behave opposite to the normal behavior specified by alltalk. */

/* Define flag combinations to be used in comparisons. */
#define VOICESTATE_TEAM_OR_ALT 5
#define VOICESTATE_GLOBAL_OR_ALT 6

/* Variables to store the sv_alltalk ConVar, and the boolean value of it. */
ConVar g_cvAlltalk;
bool g_boolAlltalk;

/* Array to designate the behavior of voice chat for a player. */
int g_VoiceChatState[MAXPLAYERS + 1];

/* Array to contain all teamids. */
int g_TeamID[MAXPLAYERS + 1];

#include "SeparateTeamGlobalVoice/interface.sp"
#include "SeparateTeamGlobalVoice/actions.sp"

public Plugin myinfo = 
{
	name = "Separate Team and Global Voice Channels",
	author = "emjay",
	description = "Creates separate channels for team and global voice chat.",
	version = "1.0.0r3",
	url = "https://forums.alliedmods.net/showthread.php?p=2384832"
};

public void OnPluginStart()
{
	/* Load translations for ReplyToCommand. */
	LoadTranslations("common.phrases");

	/* Register commands to use alternate voice chat behavior. */
	RegConsoleCmd("+voicealt", Command_VoiceAltOn);
	RegConsoleCmd("-voicealt", Command_VoiceAltOff);
	
	/* Register commands to use global voice chat. */
	RegConsoleCmd("+voiceglobal", Command_VoiceGlobalOn);
	RegConsoleCmd("-voiceglobal", Command_VoiceGlobalOff);	
	
	/* Register commands to use team voice chat. */
	RegConsoleCmd("+voiceteam", Command_VoiceTeamOn);
	RegConsoleCmd("-voiceteam", Command_VoiceTeamOff);

	/* Get state of sv_alltalk. */
	g_cvAlltalk = FindConVar("sv_alltalk");
	g_boolAlltalk = g_cvAlltalk.BoolValue;

	/* Hook change of sv_alltalk. */
	g_cvAlltalk.AddChangeHook(OnAlltalkChange);	

	/* Hook the player_team event. */
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
}

/**
 * Prevent possible exploit of players holding the mic open while the alltalk variable is changed. 
 * Recalculate listen overrides for each player when sv_alltalk is changed. 
 */
public void OnAlltalkChange(ConVar cvar, const char[] OldValue, const char[] NewValue)
{
	g_boolAlltalk = g_cvAlltalk.BoolValue;

	if(!g_boolAlltalk)
	{
		for(int SenderIndex = 1; SenderIndex <= MaxClients; ++SenderIndex)
		{
			if( g_VoiceChatState[SenderIndex] == VOICESTATE_NORMAL || IsMutedFlagSet(SenderIndex) )
			{
				continue;
			}
			else if(g_VoiceChatState[SenderIndex] == VOICESTATE_TEAM)
			{
				ResetListenOverrides(SenderIndex);
			}
			else if(g_VoiceChatState[SenderIndex] == VOICESTATE_GLOBAL)
			{
				DoVoiceAltAlltalkOff(SenderIndex);
			}
			else
			{
				PrintToChat(SenderIndex, "[SM] sv_alltalk has been changed: Your voice will be heard globally.");
				DoVoiceAltAlltalkOff(SenderIndex);
			}
		}
	}
	else
	{
		for(int SenderIndex = 1; SenderIndex <= MaxClients; ++SenderIndex)
		{
			if( g_VoiceChatState[SenderIndex] == VOICESTATE_NORMAL || IsMutedFlagSet(SenderIndex) )
			{
				continue;
			}
			else if(g_VoiceChatState[SenderIndex] == VOICESTATE_TEAM)
			{
				DoVoiceAltAlltalkOn(SenderIndex);
			}
			else if(g_VoiceChatState[SenderIndex] == VOICESTATE_GLOBAL)
			{
				ResetListenOverrides(SenderIndex);
			}
			else
			{
				PrintToChat(SenderIndex, "[SM] sv_alltalk has been changed: Your voice will only be heard by your team.");
				DoVoiceAltAlltalkOn(SenderIndex);
			}
		}				
	}
}

/**
 * Recalculate listen overrides when alltalk is on, and update g_TeamID array on player team change.
 * Recalculating listen overrides, when alltalk is off, is done when a client joins the game.
 */
public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int EventClient = GetClientOfUserId( event.GetInt("userid") );
	g_TeamID[EventClient] = event.GetInt("team");

	if(g_boolAlltalk)
	{
		for(int SenderIndex = 1; SenderIndex <= MaxClients; ++SenderIndex)
		{
			if( (g_VoiceChatState[SenderIndex] & VOICESTATE_TEAM_OR_ALT) != 0 &&
    			!IsMutedFlagSet(SenderIndex) && 
				SenderIndex != EventClient )
			{	
				if(g_TeamID[SenderIndex] != g_TeamID[EventClient])
				{
					SetListenOverride(EventClient, SenderIndex, Listen_No);
				}
				else
				{
					SetListenOverride(EventClient, SenderIndex, Listen_Default);
				}	
			}
		}
		
		if( (g_VoiceChatState[EventClient] & VOICESTATE_TEAM_OR_ALT) != 0 && !IsMutedFlagSet(EventClient) )
		{
			DoVoiceAltAlltalkOn(EventClient);
		}
	}
}

/**
 * Reset listen overrides for a muted client, 
 * and recalculate listen overrides for an unmuted client, if their voice state is not VOICESTATE_NORMAL.
 */
public void BaseComm_OnClientMute(int client, bool muteState)
{
	if(g_VoiceChatState[client] == VOICESTATE_NORMAL)
	{
		return;
	}

	if(muteState)
	{
		ResetListenOverrides(client);
		return;
	}
	
	if(!g_boolAlltalk)
	{
		if( (g_VoiceChatState[client] & VOICESTATE_GLOBAL_OR_ALT) != 0 )
		{
			PrintToChat(client, "[SM] You have been unmuted: Your voice will be heard globally.");
			DoVoiceAltAlltalkOff(client);
		}
	}
	else if( (g_VoiceChatState[client] & VOICESTATE_TEAM_OR_ALT) != 0 )
	{
		PrintToChat(client, "[SM] You have been unmuted: Your voice will only be heard by your team.");
		DoVoiceAltAlltalkOnTeamOnly(client);
	}
}

/**
 * Reset listen overrides, Team IDs, and voice states on map start and end, 
 * and when clients are put in server, or disconnected. 
 */
public void OnMapStart()
{
	ResetClientListening();
}

public void OnMapEnd()
{
	ResetClientListening();
}

public void OnClientDisconnect(int client)
{
	ResetListenOverrides(client);
	g_VoiceChatState[client] = VOICESTATE_NORMAL;

	g_TeamID[client] = 0;
}

public void OnClientPutInServer(int client)
{
	ResetListenOverrides(client);

	/**
	 * If alltalk is off, then allow the newly connected player to 
	 * hear players with VOICESTATE_GLOBAL or VOICESTATE_ALT.
	 */
	if(!g_boolAlltalk)
	{
		for(int SenderIndex = 1; SenderIndex <= MaxClients; ++SenderIndex)
		{
			if( (g_VoiceChatState[SenderIndex] & VOICESTATE_GLOBAL_OR_ALT) != 0  && !IsMutedFlagSet(SenderIndex) )
			{
				SetListenOverride(client, SenderIndex, Listen_Yes);
			}
		}
	}

	g_VoiceChatState[client] = VOICESTATE_NORMAL;

	g_TeamID[client] = 0;
}
