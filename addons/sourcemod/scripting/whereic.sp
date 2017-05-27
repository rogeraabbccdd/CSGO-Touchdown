#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Where I See",
	author = "Kento",
	description = "Get the position you aim at",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_whereic", Command_WhereIC, ADMFLAG_GENERIC, "Force Ball Drop");
}

public Action Command_WhereIC(int client,int args)
{
	float pos[3];
	float clientEye[3], clientAngle[3];
	GetClientEyePosition(client, clientEye);
	GetClientEyeAngles(client, clientAngle);
		
	TR_TraceRayFilter(clientEye, clientAngle, MASK_SOLID, RayType_Infinite, HitSelf, client);
	
	if (TR_DidHit(INVALID_HANDLE))
		TR_GetEndPosition(pos);
	
	PrintToChat(client, "%.2f;%.2f;%.2f", pos[0], pos[1], pos[2]);
}

public bool HitSelf(int entity, int contentsMask, any data)
{
	if (entity == data)
	{
		return false;
	}
	return true;
}
