#include <sourcemod>
#include <kento_touchdown>

#pragma newdecls required

// Teams
#define SPEC 1
#define TR 2
#define CT 3

public Plugin myinfo =
{
	name = "[CS:GO] Touch Down Sample 3rd Party Plugin",
	author = "Kento from Akami Studio",
	version = "1.0",
	description = "Test touchdown natives and forwards",
	url = "https://github.com/rogeraabbccdd/CSGO-Touchdown"
};

public void OnPluginStart() 
{
	RegConsoleCmd("sm_tdtest", Command_Test, "Test");
}

public Action Touchdown_OnPlayerDropBall(int client)
{
	char clientname [PLATFORM_MAX_PATH];
	GetClientName(client, clientname, sizeof(clientname));
	
	PrintToChatAll("%s drop the ball!", clientname);
}

public Action Touchdown_OnBallReset()
{
	PrintToChatAll("ball reset");
}

public Action Touchdown_OnPlayerGetBall(int client)
{
	char clientname [PLATFORM_MAX_PATH];
	GetClientName(client, clientname, sizeof(clientname));
	
	PrintToChatAll("%s get the ball!", clientname);
}

public Action Touchdown_OnPlayerTouchDown(int client)
{
	char clientname [PLATFORM_MAX_PATH];
	GetClientName(client, clientname, sizeof(clientname));
	
	PrintToChatAll("%s touchdown", clientname);
}

public Action Touchdown_OnPlayerKillBall(int ballholder, int attacker)
{
	char ballholdername [PLATFORM_MAX_PATH];
	GetClientName(ballholder, ballholdername, sizeof(ballholdername));
	
	char attackername [PLATFORM_MAX_PATH];
	GetClientName(attacker, attackername, sizeof(attackername));
	
	PrintToChatAll("%s kill the ball holder %s", attackername, ballholdername);
}

public Action Command_Test(int client, int args)
{
	char ballholdername [PLATFORM_MAX_PATH];
	GetClientName(Touchdown_GetBallHolder(), ballholdername, sizeof(ballholdername));
	
	PrintToChat(client, "Ball Drop Team %i", Touchdown_GetBallDropTeam());
	PrintToChat(client, "Ball Holder %s", Touchdown_GetBallHolder());
	
	if(Touchdown_IsClientBallHolder(client))
		PrintToChat(client, "You are the ball holder");
	else if(!Touchdown_IsClientBallHolder(client))
		PrintToChat(client, "You are NOT the ball holder");
}
