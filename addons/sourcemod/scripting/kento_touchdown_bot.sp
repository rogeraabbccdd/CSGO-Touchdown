
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#include <kento_touchdown>

public Plugin myinfo =
{
	name = "[CS:GO] Touch Down | Bot AI",
	author = "Zeisen",
	version = "1.0",
	description = "Bot supports for TouchDown by Kento",
	url = ""
};

enum _BotRouteType
{
	SAFEST_ROUTE = 0,
	FASTEST_ROUTE,
	UNKNOWN_ROUTE
}

int g_BotAggressive[MAXPLAYERS + 1];
int g_BotTeamwork[MAXPLAYERS + 1];

Handle hGameConf = INVALID_HANDLE;

Handle hBotMoveTo = INVALID_HANDLE;

public void OnPluginStart()
{
	hGameConf = LoadGameConfigFile("touchdown.games");
	if (hGameConf == INVALID_HANDLE)
		SetFailState("Failed to found touchdown.games game config.");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer); // Move Position As Vector, Pointer
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Move Type As Integer
	hBotMoveTo = EndPrepSDKCall();
	
	CreateTimer(2.0, Timer_BotMoveThink, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client)
{
	if (!IsFakeClient(client))
		return;
	
	g_BotAggressive[client] = GetRandomInt(0, 100);
	g_BotTeamwork[client] = GetRandomInt(0, 100);
}

public Action Timer_BotMoveThink(Handle timer)
{
	float ballOrigin[3];
	if (!Touchdown_GetBallOrigin(ballOrigin))
	{
		// ThrowError("Failed to found ball's Origin");
		return Plugin_Continue;
	}
	
	float flagOrigin[3];
	
	int ballHolder = Touchdown_GetBallHolder();
	int ballHolderTeam = ballHolder > 0 ? GetClientTeam(ballHolder) : CS_TEAM_NONE;
	float ballHolderOrigin[3];
	for (int i=1; i<=MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsFakeClient(i) || !IsPlayerAlive(i))
			continue;
		
		int clientTeam = GetClientTeam(i);
		
		if (ballHolder == 0)
		{
			BotMoveTo(i, ballOrigin, g_BotAggressive[i] >= 70 ? FASTEST_ROUTE : SAFEST_ROUTE);
		}
		else
		{
			if (ballHolder == i || ballHolder > 0 && clientTeam == ballHolderTeam)
			{
				Touchdown_GetFlagOrigin(ballHolderTeam == CS_TEAM_T ? CS_TEAM_CT : CS_TEAM_T, flagOrigin);
				BotMoveTo(i, flagOrigin, g_BotAggressive[i] >= 70 ? FASTEST_ROUTE : SAFEST_ROUTE);
			}
			else
			{
				GetClientAbsOrigin(ballHolder, ballHolderOrigin);
				BotMoveTo(i, flagOrigin, g_BotAggressive[i] >= 70 ? FASTEST_ROUTE : SAFEST_ROUTE);
			}
		}
	}
	
	return Plugin_Continue;
}


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!IsFakeClient(client))
		return Plugin_Continue;

	buttons &= ~IN_SPEED;
	return Plugin_Continue;
}

public void BotMoveTo(int client, float origin[3], _BotRouteType routeType)
{
	SDKCall(hBotMoveTo, client, origin, routeType);
}


