/*
Sound files can be used in the future.
critical.mp3 - 	Critical (S4 Critical has 3d text effect)
jump_up.mp3 - Jump
attack_down.mp3 - ???
*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <cstrike>
#include <kento_csgocolors>
#include <clientprefs>
#include <kento_touchdown>
#include <SteamWorks>

#pragma newdecls required

// Teams
#define SPEC 1
#define TR 2
#define CT 3

// Model postion
float BallSpawnPoint[3];
float TGoalSpawnPoint[3];
float CTGoalSpawnPoint[3];

// Ball
int BallModel;
int BallHolder;
int PlayerBallModel;
int DropBallModel;
int Touchdowner;

int BallDroperTeam;

// Particle
int TGoalParticle;
int CTGoalParticle;
int TGoalModel;
int CTGoalModel;
int TPoleModel;
int CTPoleModel;
int TGroundModel;
int CTGroundModel;

int CTParticle;
int TParticle;
int BallParticle;
int DropBallParticle;

int PlayerBallRef = INVALID_ENT_REFERENCE;
int DropBallRef = INVALID_ENT_REFERENCE;
int BallRef = INVALID_ENT_REFERENCE;

int CTParticleRef = INVALID_ENT_REFERENCE;
int TParticleRef = INVALID_ENT_REFERENCE;
int BallParticleRef = INVALID_ENT_REFERENCE;
int DropBallParticleRef = INVALID_ENT_REFERENCE;

int TGoalRef = INVALID_ENT_REFERENCE;
int TPoleRef = INVALID_ENT_REFERENCE;
int TGroundRef = INVALID_ENT_REFERENCE;
int CTGoalRef = INVALID_ENT_REFERENCE;
int CTPoleRef = INVALID_ENT_REFERENCE;
int CTGroundRef = INVALID_ENT_REFERENCE;

bool RoundEnd;
bool Switch;

bool g_spawned_t = false;
bool g_spawned_ct = false;

bool bWarmUp;

Handle hResetBallTimer = INVALID_HANDLE;

Handle hBGMTimer[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};

int Nextroundtime;
Handle hNextRoundCountdown = INVALID_HANDLE;

float roundtime;

Handle hRoundCountdown = INVALID_HANDLE;

// Ball model from mottzi's Simple Ball Plugin
// https://forums.alliedmods.net/showthread.php?p=2423345
#define BallModelPath "models/knastjunkies/soccerball.mdl"

// Flag model from boomix's capture the flag, but I make it 3x bigger
// https://forums.alliedmods.net/showthread.php?t=289838
#define FlagModelPath "models/mapmodels/flags_3x.mdl"
#define PoleModelPath "models/props/pole_3x.mdl"
#define GroundModelPath "models/props/ctf/ground.mdl"

// Valve official particle
#define GoalParticleEffect "weapon_confetti_balloons"

// I don't know where I got these, I found this in my game folder.
// Maybe I got these from someone's server
// Looks like these particles are made by iEx
#define ParticlePath "particles/iEx2.pcf"
#define ParticlePath2 "particles/aurasandtrailbyiex.pcf"
#define BallParticleEffect "4215"
#define TParticleEffect "Trail"
#define CTParticleEffect "Trail"

// BGM
int BGM = 0;

bool b_JustEnded = false;
int g_roundStartedTime;

// Cookie
Handle clientVolCookie;
float g_fvol[MAXPLAYERS+1];

// Cvar
ConVar td_respawn;
ConVar td_reset;
ConVar td_ballposition;
ConVar td_taser;
ConVar td_healthshot;

ConVar td_stats_enabled;
ConVar td_stats_min;
ConVar td_stats_table_name;
ConVar td_points_enabled;

ConVar td_bgm_enabled;
ConVar td_quake_enabled;

float ftd_respawn;
float ftd_reset;
int itd_ballposition;
bool btd_taser;
bool btd_healthshot;

bool btd_stats_enabled;
int itd_stats_min;
bool btd_points_enabled;

bool btd_bgm_enabled;
bool btd_quake_enabled;

char std_stats_table_name[200];

ConVar td_points_td;
ConVar td_points_kill;
ConVar td_points_assist;
ConVar td_points_bonus;
ConVar td_points_death;
ConVar td_points_dropball;
ConVar td_points_killball;
ConVar td_points_pickball;
ConVar td_points_start;
ConVar td_points_min;
ConVar td_points_min_enabled;

int itd_points_td;
int itd_points_kill;
int itd_points_assist;
float ftd_points_bonus;
int itd_points_death;
int itd_points_dropball;
int itd_points_killball;
int itd_points_pickball;
int itd_points_start;
int itd_points_min;
bool btd_points_min_enabled;

ConVar mp_freezetime;
ConVar mp_weapons_allow_map_placed;
ConVar mp_death_drop_gun;
ConVar mp_playercashawards;
ConVar mp_teamcashawards;
ConVar mp_free_armor;
ConVar mp_match_restart_delay;
ConVar mp_win_panel_display_time;
ConVar mp_restartgame;

ConVar mp_ignore_round_win_conditions;
int i_mp_ignore_round_win_conditions;

// Timer
Handle hDropBallText[MAXPLAYERS + 1] = INVALID_HANDLE;
Handle hRDropBallText[MAXPLAYERS + 1] = INVALID_HANDLE;
Handle hAcquiredBallText[MAXPLAYERS + 1] = INVALID_HANDLE;
Handle hRAcquiredBallText[MAXPLAYERS + 1] = INVALID_HANDLE;

//score
int score_t;
int score_ct;
int score_ct2;
int score_t2;

// Weapons
// From boomix's capture the flag
char PrimaryWeapon[19][50] = 
{
	"weapon_m4a1", "weapon_m4a1_silencer", "weapon_ak47", "weapon_aug", "weapon_bizon", "weapon_famas", 
	"weapon_galilar", "weapon_mac10",
	"weapon_mag7", "weapon_mp7", "weapon_mp5sd", "weapon_mp9", "weapon_nova", "weapon_p90", "weapon_sawedoff",
	"weapon_sg556", "weapon_ssg08", "weapon_ump45", "weapon_xm1014"
};

char SecondaryWeapon[10][50] = 
{ 
	"weapon_deagle", "weapon_elite", "weapon_fiveseven" , "weapon_glock", "weapon_hkp2000", 
	"weapon_usp_silencer", "weapon_tec9", "weapon_p250", "weapon_cz75a", "weapon_revolver"
};

char g_LastPrimaryWeapon[MAXPLAYERS + 1][128];
char g_LastSecondaryWeapon[MAXPLAYERS + 1][128];

bool b_AutoGiveWeapons[MAXPLAYERS + 1];
int i_RandomWeapons[MAXPLAYERS + 1];
bool b_SelectedWeapon[MAXPLAYERS + 1];

// Forwards
Handle OnPlayerDropBall;
Handle OnBallReset;
Handle OnPlayerGetBall;
Handle OnPlayerTouchDown;
Handle OnPlayerKillBall;

// Stats
enum struct STATS
{
	int POINTS;
	int KILLS;
	int DEATHS;
	int ASSISTS;
	int TOUCHDOWN;
	int GETBALL;
	int DROPBALL;
	int KILLBALL;
}

STATS Stats[MAXPLAYERS + 1];

// query
Database ddb = null;
int iTotalPlayers;

public Plugin myinfo =
{
	name = "[CS:GO] Touch Down",
	author = "Kento",
	version = "2.11",
	description = "Gamemode from S4 League",
	url = "https://github.com/rogeraabbccdd/CSGO-Touchdown"
};

public void OnPluginStart() 
{
	RegAdminCmd("sm_resetball", Command_ResetBall, ADMFLAG_GENERIC, "Reset Ball");
	
	// Weapon
	RegConsoleCmd("sm_guns", Command_Weapon, "Weapon Menu");
	
	// Stats and rank
	RegConsoleCmd("sm_rank", Command_Rank, "Show your touchdown rank");
	RegConsoleCmd("sm_stats", Command_Stats, "Show your touchdown stats");
	RegConsoleCmd("sm_top", Command_Top, "Show top players");
	
	// volume
	RegConsoleCmd("sm_vol", Command_Vol, "Volume");
	clientVolCookie = RegClientCookie("touchdown_vol", "Touchdown Client Volume", CookieAccess_Protected);
	
	// edit mode
	RegAdminCmd("sm_td", Command_Edit, ADMFLAG_GENERIC, "Edit Touchdown Configs");

	// Late spawn
	AddCommandListener(Command_Join, "jointeam");
	
	LoadTranslations("kento.touchdown.phrases");
	
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	//HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("item_pickup", Event_ItemPickUp);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("cs_win_panel_match", Event_WinPanelMatch);
	HookEvent("announce_phase_end", Event_HalfTime);
	
	//https://github.com/mukunda-/rxg-plugins/blob/fc533fcc9aeab3715b89d1a5c99905deb9a17865/gamefixes/restart_fix.sp
	HookEvent("cs_match_end_restart", Event_MatchRestart, EventHookMode_PostNoCopy);
	
	AddNormalSoundHook(Event_SoundPlayed);
	
	HookUserMessage(GetUserMessageId("TextMsg"), MsgHook_AdjustMoney, true);
	
	// Cvar
	td_respawn = CreateConVar("sm_touchdown_respawn",  "8.0", "Respawn Time.", FCVAR_NOTIFY, true, 0.0);
	td_reset = CreateConVar("sm_touchdown_reset",  "15.0", "How long to reset the ball if nobody takes the ball after ball drop.", FCVAR_NOTIFY, true, 0.0);
	td_ballposition = CreateConVar("sm_touchdown_ball_position",  "1", "Where to attach the ball when player get the ball? 0 = front, 1 = head", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	td_taser = CreateConVar("sm_touchdown_taser",  "1", "Give player taser?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	td_healthshot = CreateConVar("sm_touchdown_healthshot",  "1", "Give player healthshot?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	td_stats_enabled = CreateConVar("sm_touchdown_stats_enabled",  "0", "Enable stats or not? (MYSQL only!)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	td_stats_min = CreateConVar("sm_touchdown_stats_min",  "4", "Min player to count stats.", FCVAR_NOTIFY, true, 0.0);
	td_stats_table_name = CreateConVar("sm_touchdown_stats_table",  "touchdown", "MySQL table name for touchdown.");
	
	td_bgm_enabled = CreateConVar("sm_touchdown_bgm_enabled",  "1", "Enable BGM or not?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	td_quake_enabled = CreateConVar("sm_touchdown_quake_enabled",  "1", "Enable quake sounds or not? (all kill sounds)", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	// Points cvar
	// http://s4league.wikia.com/wiki/Touchdown#Scoring
	td_points_enabled = CreateConVar("sm_touchdown_points_enabled",  "0", "Enable points or not?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	td_points_td = CreateConVar("sm_touchdown_points_td",  "10", "How many points player can get when he touchdown?", FCVAR_NOTIFY, true, 0.0);
	td_points_kill = CreateConVar("sm_touchdown_points_kill",  "2", "How many points player will get when he kill?", FCVAR_NOTIFY, true, 0.0);
	td_points_assist = CreateConVar("sm_touchdown_points_assist",  "1", "How many points player can get when he assist kill?", FCVAR_NOTIFY, true, 0.0);
	td_points_bonus = CreateConVar("sm_touchdown_points_bonus",  "2.0", "Offense / Defence bonus multiplier", FCVAR_NOTIFY, true, 0.0);
	td_points_death = CreateConVar("sm_touchdown_points_death",  "0", "How many points player will lose when he killed?", FCVAR_NOTIFY, true, 0.0);
	td_points_dropball = CreateConVar("sm_touchdown_points_dropball",  "0", "How many points player will lose when he drop ball?", FCVAR_NOTIFY, true, 0.0);
	td_points_killball = CreateConVar("sm_touchdown_points_killball",  "2", "How many points player will get when he kill ball holder?", FCVAR_NOTIFY, true, 0.0);
	td_points_pickball = CreateConVar("sm_touchdown_points_pickball",  "2", "How many points player will get when he pick up the ball?", FCVAR_NOTIFY, true, 0.0);
	td_points_start = CreateConVar("sm_touchdown_points_start",  "0", "Starting points", FCVAR_NOTIFY, true, 0.0);
	td_points_min_enabled = CreateConVar("sm_touchdown_points_min_enabled",  "1", "Enable minimum points?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	td_points_min = CreateConVar("sm_touchdown_points_min",  "0", "Minimum points", FCVAR_NOTIFY, true, 0.0);
	
	// Server Cvar
	// Remove freezetime, S4 doesn't have freeze time
	mp_freezetime = FindConVar("mp_freezetime");
	mp_weapons_allow_map_placed = FindConVar("mp_weapons_allow_map_placed");
	mp_death_drop_gun = FindConVar("mp_death_drop_gun");
	mp_playercashawards = FindConVar("mp_playercashawards");
	mp_teamcashawards = FindConVar("mp_teamcashawards");
	mp_free_armor = FindConVar("mp_free_armor");
	mp_match_restart_delay = FindConVar("mp_match_restart_delay");
	mp_win_panel_display_time = FindConVar("mp_win_panel_display_time");
	mp_restartgame = FindConVar("mp_restartgame");
	mp_ignore_round_win_conditions = FindConVar("mp_ignore_round_win_conditions");
	
	// Hook Cvar Change
	td_respawn.AddChangeHook(OnConVarChanged);
	td_reset.AddChangeHook(OnConVarChanged);
	td_ballposition.AddChangeHook(OnConVarChanged);
	td_taser.AddChangeHook(OnConVarChanged);
	td_healthshot.AddChangeHook(OnConVarChanged);
	
	td_stats_enabled.AddChangeHook(OnConVarChanged);
	td_stats_min.AddChangeHook(OnConVarChanged);
	td_stats_table_name.GetString(std_stats_table_name, sizeof(std_stats_table_name));
	
	td_bgm_enabled.AddChangeHook(OnConVarChanged);
	td_quake_enabled.AddChangeHook(OnConVarChanged);

	td_points_enabled.AddChangeHook(OnConVarChanged);
	td_points_td.AddChangeHook(OnConVarChanged);
	td_points_kill.AddChangeHook(OnConVarChanged);
	td_points_assist.AddChangeHook(OnConVarChanged);
	td_points_bonus.AddChangeHook(OnConVarChanged);
	td_points_death.AddChangeHook(OnConVarChanged);
	td_points_dropball.AddChangeHook(OnConVarChanged);
	td_points_killball.AddChangeHook(OnConVarChanged);
	td_points_pickball.AddChangeHook(OnConVarChanged);
	td_points_start.AddChangeHook(OnConVarChanged);
	td_points_min.AddChangeHook(OnConVarChanged);
	td_points_min_enabled.AddChangeHook(OnConVarChanged);
	
	mp_freezetime.AddChangeHook(OnConVarChanged);
	mp_weapons_allow_map_placed.AddChangeHook(OnConVarChanged);
	mp_death_drop_gun.AddChangeHook(OnConVarChanged);
	mp_playercashawards.AddChangeHook(OnConVarChanged);
	mp_teamcashawards.AddChangeHook(OnConVarChanged);
	mp_free_armor.AddChangeHook(OnConVarChanged);
	mp_match_restart_delay.AddChangeHook(OnConVarChanged);
	mp_win_panel_display_time.AddChangeHook(OnConVarChanged);
	mp_ignore_round_win_conditions.AddChangeHook(OnConVarChanged);
	
	mp_restartgame.AddChangeHook(Restart_Handler);
	
	AutoExecConfig(true, "kento_touchdown");
	
	/* Late load? I think you should reload the map, not only reload the plugin :/
	for(int i = 1; i <= MaxClients; i++)
	{ 
		if(IsValidClient(i) && !IsFakeClient(i))	OnClientCookiesCached(i);
	}
	*/
}

// Create natives and forwards
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Touchdown_GetBallOrigin", Native_GetBallOrigin);
	CreateNative("Touchdown_GetBallHolder", Native_GetBallHolder);
	CreateNative("Touchdown_GetBallDropTeam", Native_GetBallDropTeam);
	CreateNative("Touchdown_IsClientBallHolder", Native_IsClientBallHolder);
	
	CreateNative("Touchdown_GetFlagOrigin", Native_GetFlagOrigin);
	
	CreateNative("Touchdown_GetClientPoints", Native_GetClientPoints);
	CreateNative("Touchdown_GetClientKills", Native_GetClientKills);
	CreateNative("Touchdown_GetClientDeaths", Native_GetClientDeaths);
	CreateNative("Touchdown_GetClientAssists", Native_GetClientAssists);
	CreateNative("Touchdown_GetClientTouchdown", Native_GetClientTouchdown);
	CreateNative("Touchdown_GetClientKillball", Native_GetClientKillball);
	CreateNative("Touchdown_GetClientDropball", Native_GetClientDropball);
	CreateNative("Touchdown_GetClientGetball", Native_GetClientGetball);
	
	OnPlayerDropBall = CreateGlobalForward("Touchdown_OnPlayerDropBall", ET_Ignore, Param_Cell);
	OnBallReset = CreateGlobalForward("Touchdown_OnBallReset", ET_Ignore);
	OnPlayerGetBall = CreateGlobalForward("Touchdown_OnPlayerGetBall", ET_Ignore, Param_Cell);
	OnPlayerTouchDown = CreateGlobalForward("Touchdown_OnPlayerTouchDown", ET_Ignore, Param_Cell);
	OnPlayerKillBall = CreateGlobalForward("Touchdown_OnPlayerKillBall", ET_Ignore, Param_Cell, Param_Cell);
	
	return APLRes_Success;
}

public int Native_GetBallOrigin(Handle plugin, int numParams)
{
	// if received wrong params?
	if (numParams > 1)
	{
		ThrowNativeError(1, "Received wrong params. %d (expected : 1)", numParams);
		return 0;
	}
	
	int index;
	if (BallRef != INVALID_ENT_REFERENCE)
		index = EntRefToEntIndex(BallRef);
	else if (DropBallRef != INVALID_ENT_REFERENCE)
		index = EntRefToEntIndex(DropBallRef);
	else if (BallHolder > 0)
		index = BallHolder;
	else return 0;		
				
	if (!IsValidEntity(index))return 0;
	
	float ballOrigin[3];
	GetEntPropVector(index, Prop_Send, "m_vecOrigin", ballOrigin);
	
	SetNativeArray(1, ballOrigin, 3);
	
	return 1;
}

public int Native_GetBallHolder(Handle plugin, int numParams)
{
	return BallHolder;
}

public int Native_GetBallDropTeam(Handle plugin, int numParams)
{
	return BallDroperTeam;
}

public int Native_IsClientBallHolder(Handle plugin, int numParams)
{
	if(BallHolder == GetNativeCell(1))
		return true;
	else return false;
}

public int Native_GetFlagOrigin(Handle plugin, int numParams)
{
	// if received wrong params?
	if (numParams > 2)
	{
		ThrowNativeError(1, "Received wrong params. %d (expected : 2)", numParams);
		return 0;
	}
	
	int flagTeam = GetNativeCell(1);
	float flagOrigin[3];
	if (flagTeam == CS_TEAM_T)
	{
		flagOrigin[0] = TGoalSpawnPoint[0];
		flagOrigin[1] = TGoalSpawnPoint[1];
		flagOrigin[2] = TGoalSpawnPoint[2];
	}
	else if (flagTeam == CS_TEAM_CT)
	{
		flagOrigin[0] = CTGoalSpawnPoint[0];
		flagOrigin[1] = CTGoalSpawnPoint[1];
		flagOrigin[2] = CTGoalSpawnPoint[2];
	}
	else
		ThrowNativeError(1, "Received wrong flag of team. %d (expected : 2 or 3)",  flagTeam);
	
	SetNativeArray(2, flagOrigin, 3);
	
	return 1;
}

public int Native_GetClientPoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].POINTS;
}

public int Native_GetClientKills(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].KILLS;
}

public int Native_GetClientDeaths(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].DEATHS;
}

public int Native_GetClientAssists(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].ASSISTS;
}

public int Native_GetClientTouchdown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].TOUCHDOWN;
}

public int Native_GetClientKillball(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].KILLBALL;
}

public int Native_GetClientGetball(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].GETBALL;
}

public int Native_GetClientDropball(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	return Stats[client].DROPBALL;
}
	
public void Restart_Handler(Handle convar, const char[] oldValue, const char[] newValue)
{
	if ((convar == mp_restartgame))
	{
		ResetTimer();
		RoundEnd = false;
		BallHolder = 0;
		BallDroperTeam = 0;
		score_t = 0;
		score_ct = 0;
		score_t2 = 0;
		score_ct2 = 0;
		Switch = false;
		Touchdowner = 0;
		g_spawned_t = false;
		g_spawned_ct = false;
	}
}

public void OnConfigsExecuted()
{
	LoadMapConfig(); 
	
	ftd_respawn = td_respawn.FloatValue;
	ftd_reset = td_reset.FloatValue;
	itd_ballposition = td_ballposition.IntValue;
	btd_taser = td_taser.BoolValue;
	btd_healthshot = td_healthshot.BoolValue;
	
	btd_stats_enabled = td_stats_enabled.BoolValue;
	itd_stats_min = td_stats_min.IntValue;
	btd_points_enabled = td_stats_enabled.BoolValue;

	btd_bgm_enabled = td_bgm_enabled.BoolValue;
	btd_quake_enabled = td_quake_enabled.BoolValue;
	
	itd_points_td = td_points_td.IntValue;
	itd_points_kill = td_points_kill.IntValue;
	itd_points_assist = td_points_assist.IntValue;
	ftd_points_bonus = td_points_bonus.FloatValue;
	itd_points_death = td_points_death.IntValue;
	itd_points_dropball = td_points_dropball.IntValue;
	itd_points_killball = td_points_killball.IntValue;
	itd_points_pickball = td_points_pickball.IntValue;
	itd_points_start = td_points_start.IntValue;
	itd_points_min = td_points_min.IntValue;
	btd_points_min_enabled = td_points_min_enabled.BoolValue;
	
	if(btd_stats_enabled || btd_points_enabled)
	{		
		if (SQL_CheckConfig("touchdown"))		
		{		
			SQL_TConnect(OnSQLConnect, "touchdown");		
		}		
		else if (!SQL_CheckConfig("touchdown"))		
		{		
			SetFailState("Can't find an entry in your databases.cfg with the name \"touchdown\".");		
			return;		
		}		
	}
}

void LoadMapConfig()
{
	char Configfile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Configfile, sizeof(Configfile), "configs/kento_touchdown.cfg");
	
	if (!FileExists(Configfile))
	{
		SetFailState("Fatal error: Unable to open configuration file \"%s\"!", Configfile);
	}
	
	KeyValues kv = CreateKeyValues("TouchDown");
	kv.ImportFromFile(Configfile);
	
	char sMapName[128], sMapName2[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	
	// Does current map string contains a "workshop" prefix at a start?
	if (strncmp(sMapName, "workshop", 8) == 0)
	{
		Format(sMapName2, sizeof(sMapName2), sMapName[19]);
	}
	else
	{
		Format(sMapName2, sizeof(sMapName2), sMapName);
	}
	
	if (kv.JumpToKey(sMapName2))
	{
		// Ball postion
		char ball[512];
		char ballDatas[3][32];
		kv.GetString("ball", ball, sizeof(ball));
		ExplodeString(ball, ";", ballDatas, 3, 32);
		BallSpawnPoint[0] = StringToFloat(ballDatas[0]);
		BallSpawnPoint[1] = StringToFloat(ballDatas[1]);
		BallSpawnPoint[2] = StringToFloat(ballDatas[2]);
			
		// T goal position
		char tgoal[512];
		char tgoalDatas[3][32];
		kv.GetString("goal_t", tgoal, sizeof(tgoal));
		ExplodeString(tgoal, ";", tgoalDatas, 3, 32);
		TGoalSpawnPoint[0] = StringToFloat(tgoalDatas[0]);
		TGoalSpawnPoint[1] = StringToFloat(tgoalDatas[1]);
		TGoalSpawnPoint[2] = StringToFloat(tgoalDatas[2]);
			
		// CT goal position
		char ctgoal[512];
		char ctgoalDatas[3][32];
		kv.GetString("goal_ct", ctgoal, sizeof(ctgoal));
		ExplodeString(ctgoal, ";", ctgoalDatas, 3, 32);
		CTGoalSpawnPoint[0] = StringToFloat(ctgoalDatas[0]);
		CTGoalSpawnPoint[1] = StringToFloat(ctgoalDatas[1]);
		CTGoalSpawnPoint[2] = StringToFloat(ctgoalDatas[2]);
	}
	else 
	{
		LogError("Error: Unable to find current map settings in configuration file \"%s\"!", Configfile);
	}
	
	kv.Rewind();
	delete kv;
}

public void OnMapStart() 
{
	int iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, "func_bomb_target")) != -1) //Find bombsites
	{
		AcceptEntityInput(iEnt,"kill"); //Destroy the entity
	}
	
	while((iEnt = FindEntityByClassname(iEnt, "func_hostage_rescue")) != -1) //Find rescue points
	{
		AcceptEntityInput(iEnt,"kill"); //Destroy the entity
	}
	
	while((iEnt = FindEntityByClassname(iEnt, "func_buyzone")) != -1) //Find buyzone
	{
		AcceptEntityInput(iEnt,"kill"); //Destroy the entity
	}
	
	// Download Sound
	AddFileToDownloadsTable("sound/touchdown/_eu_1minute.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_30second.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_3minute.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_5minute.mp3");
	AddFileToDownloadsTable("sound/touchdown/1.mp3");
	AddFileToDownloadsTable("sound/touchdown/2.mp3");
	AddFileToDownloadsTable("sound/touchdown/3.mp3");
	AddFileToDownloadsTable("sound/touchdown/4.mp3");
	AddFileToDownloadsTable("sound/touchdown/5.mp3");
	AddFileToDownloadsTable("sound/touchdown/6.mp3");
	AddFileToDownloadsTable("sound/touchdown/7.mp3");
	AddFileToDownloadsTable("sound/touchdown/8.mp3");
	AddFileToDownloadsTable("sound/touchdown/9.mp3");
	AddFileToDownloadsTable("sound/touchdown/10.mp3");
	AddFileToDownloadsTable("sound/touchdown/inter_timeover.mp3");
	AddFileToDownloadsTable("sound/touchdown/new_round_in.mp3");
	AddFileToDownloadsTable("sound/touchdown/new_round_in1.mp3");
	AddFileToDownloadsTable("sound/touchdown/next_round_in.mp3");
	AddFileToDownloadsTable("sound/touchdown/next_round_in1.mp3");
	//AddFileToDownloadsTable("sound/touchdown/attack_down.mp3");
	//AddFileToDownloadsTable("sound/touchdown/critical.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_fumbled.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_fumbled1.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_fumbled2.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_fumbled3.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_fumbled4.mp3");
	AddFileToDownloadsTable("sound/touchdown/red_fumbled.mp3");
	AddFileToDownloadsTable("sound/touchdown/red_fumbled1.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_scores.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_scores1.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_scores2.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_scores3.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_scores4.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_take_the_lead.mp3");
	AddFileToDownloadsTable("sound/touchdown/blue_team_take_the_lead1.mp3");
	AddFileToDownloadsTable("sound/touchdown/red_team_scores.mp3");
	AddFileToDownloadsTable("sound/touchdown/red_team_scores1.mp3");
	AddFileToDownloadsTable("sound/touchdown/red_team_scores2.mp3");
	AddFileToDownloadsTable("sound/touchdown/red_team_take_the_lead.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill1.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill2.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill3.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill4.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill5.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill6.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill7.mp3");
	AddFileToDownloadsTable("sound/touchdown/kill8.mp3");
	AddFileToDownloadsTable("sound/touchdown/ready1.mp3");
	AddFileToDownloadsTable("sound/touchdown/ready2.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking1.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking2.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking3.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking4.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking5.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking6.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_attacking7.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_defending.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_defending1.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_are_defending2.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_have_won_the_match.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_have_won_the_match1.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_lost_the_match.mp3");
	AddFileToDownloadsTable("sound/touchdown/you_lost_the_match1.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_ball_reset.mp3");
	AddFileToDownloadsTable("sound/touchdown/player_respawn.mp3");
	//AddFileToDownloadsTable("sound/touchdown/jump_up.mp3");
	AddFileToDownloadsTable("sound/touchdown/player_dead.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_voice_man_dead_blow.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_voice_man_dead_hard.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_voice_man_dead_normal.mp3");
	AddFileToDownloadsTable("sound/touchdown/_eu_voice_man_dead_shock.mp3");
	
	// Ball
	AddFileToDownloadsTable("sound/touchdown/pokeball_bounce.mp3");
	
	// Download Model
	// Ball
	AddFileToDownloadsTable("materials/knastjunkies/Material__0.vmt");
	AddFileToDownloadsTable("materials/knastjunkies/Material__1.vmt");
	AddFileToDownloadsTable("models/knastjunkies/SoccerBall.dx90.vtx");
	AddFileToDownloadsTable("models/knastjunkies/soccerball.mdl");
	AddFileToDownloadsTable("models/knastjunkies/SoccerBall.phy");
	AddFileToDownloadsTable("models/knastjunkies/soccerball.vvd");
	
	// Flag
	AddFileToDownloadsTable("materials/editor/gray.vmt");
	AddFileToDownloadsTable("materials/editor/gray.vtf");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/axisflag.vmt");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/axisflag.vtf");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/neutralflag.vmt");
	AddFileToDownloadsTable("materials/models/mapmodels/flags/neutralflag.vtf");
	AddFileToDownloadsTable("models/mapmodels/flags_3x.dx90.vtx");
	AddFileToDownloadsTable("models/mapmodels/flags_3x.mdl");
	AddFileToDownloadsTable("models/mapmodels/flags_3x.vvd");
	
	// Pole
	AddFileToDownloadsTable("materials/models/props/pole/gray.vmt");
	AddFileToDownloadsTable("models/props/pole_3x.dx90.vtx");
	AddFileToDownloadsTable("models/props/pole_3x.mdl");
	AddFileToDownloadsTable("models/props/pole_3x.phy");
	AddFileToDownloadsTable("models/props/pole_3x.vvd");
	
	// Ground
	AddFileToDownloadsTable("materials/models/props/ctf/ground/tilefloor005a.vmt");
	AddFileToDownloadsTable("materials/models/props/ctf/ground/train_metalceiling_02.vmt");
	AddFileToDownloadsTable("models/props/ctf/ground.dx80.vtx");
	AddFileToDownloadsTable("models/props/ctf/ground.dx90.vtx");
	AddFileToDownloadsTable("models/props/ctf/ground.mdl");
	AddFileToDownloadsTable("models/props/ctf/ground.phy");
	AddFileToDownloadsTable("models/props/ctf/ground.sw.vtx");
	AddFileToDownloadsTable("models/props/ctf/ground.vvd");
	
	// Overlay
	AddFileToDownloadsTable("materials/touchdown/touchdown_green.vmt");
	AddFileToDownloadsTable("materials/touchdown/touchdown_green.vtf");
	AddFileToDownloadsTable("materials/touchdown/touchdown_red.vmt");
	AddFileToDownloadsTable("materials/touchdown/touchdown_red.vtf");
	
	PrecacheDecal("materials/touchdown/touchdown_green.vmt", true);
	PrecacheDecal("materials/touchdown/touchdown_green.vtf", true);
	PrecacheDecal("materials/touchdown/touchdown_red.vmt", true);
	PrecacheDecal("materials/touchdown/touchdown_red.vtf", true);
	
	// Download BGM
	AddFileToDownloadsTable("sound/touchdown/bgm/Chain_Reaction.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Super_Sonic.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Nova.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Lobby.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Dual_Rock.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Move_Your_Spirit.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Fuzzy_Control.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Seize.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Syriana.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Access.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Grave_Consequence.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Come_On.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Starfish.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/NB_Power.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Alice.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Chase_yourself.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Dark_ages.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Dark_lightning.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Hypersonic.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Never_give_up.mp3");
	AddFileToDownloadsTable("sound/touchdown/bgm/Real_overdrive.mp3");
	
	// Precache Model
	PrecacheModel(BallModelPath, true);
	PrecacheModel(FlagModelPath, true);
	PrecacheModel(PoleModelPath, true);
	PrecacheModel(GroundModelPath, true);
	
	// Precache Particle
	PrecacheGeneric(ParticlePath, true);
	PrecacheGeneric(ParticlePath2, true);
	
	PrecacheEffect("ParticleEffect");
	PrecacheParticleEffect(TParticleEffect);
	PrecacheParticleEffect(BallParticleEffect);
	PrecacheParticleEffect(CTParticleEffect);

	// Download Particle
	AddFileToDownloadsTable(ParticlePath);
	AddFileToDownloadsTable(ParticlePath2);
	AddFileToDownloadsTable("materials/ex/gl.vmt");
	AddFileToDownloadsTable("materials/ex/gl.vtf");
			
	// Precache Sound
	// https://wiki.alliedmods.net/Csgo_quirks
	FakePrecacheSound("*/touchdown/_eu_1minute.mp3");
	FakePrecacheSound("*/touchdown/_eu_30second.mp3");
	FakePrecacheSound("*/touchdown/_eu_3minute.mp3");
	FakePrecacheSound("*/touchdown/_eu_5minute.mp3");
	FakePrecacheSound("*/touchdown/1.mp3");
	FakePrecacheSound("*/touchdown/2.mp3");
	FakePrecacheSound("*/touchdown/3.mp3");
	FakePrecacheSound("*/touchdown/4.mp3");
	FakePrecacheSound("*/touchdown/5.mp3");
	FakePrecacheSound("*/touchdown/6.mp3");
	FakePrecacheSound("*/touchdown/7.mp3");
	FakePrecacheSound("*/touchdown/8.mp3");
	FakePrecacheSound("*/touchdown/9.mp3");
	FakePrecacheSound("*/touchdown/10.mp3");
	FakePrecacheSound("*/touchdown/inter_timeover.mp3");
	FakePrecacheSound("*/touchdown/new_round_in.mp3");
	FakePrecacheSound("*/touchdown/new_round_in1.mp3");
	FakePrecacheSound("*/touchdown/next_round_in.mp3");
	FakePrecacheSound("*/touchdown/next_round_in1.mp3");
	//FakePrecacheSound("*/touchdown/attack_down.mp3");
	//FakePrecacheSound("*/touchdown/critical.mp3");
	FakePrecacheSound("*/touchdown/blue_fumbled.mp3");
	FakePrecacheSound("*/touchdown/blue_fumbled1.mp3");
	FakePrecacheSound("*/touchdown/blue_fumbled2.mp3");
	FakePrecacheSound("*/touchdown/blue_fumbled3.mp3");
	FakePrecacheSound("*/touchdown/blue_fumbled4.mp3");
	FakePrecacheSound("*/touchdown/red_fumbled.mp3");
	FakePrecacheSound("*/touchdown/red_fumbled1.mp3");
	FakePrecacheSound("*/touchdown/blue_team_scores.mp3");
	FakePrecacheSound("*/touchdown/blue_team_scores1.mp3");
	FakePrecacheSound("*/touchdown/blue_team_scores2.mp3");
	FakePrecacheSound("*/touchdown/blue_team_scores3.mp3");
	FakePrecacheSound("*/touchdown/blue_team_scores4.mp3");
	FakePrecacheSound("*/touchdown/blue_team_take_the_lead.mp3");
	FakePrecacheSound("*/touchdown/blue_team_take_the_lead1.mp3");
	FakePrecacheSound("*/touchdown/red_team_scores.mp3");
	FakePrecacheSound("*/touchdown/red_team_scores1.mp3");
	FakePrecacheSound("*/touchdown/red_team_scores2.mp3");
	FakePrecacheSound("*/touchdown/red_team_take_the_lead.mp3");
	FakePrecacheSound("*/touchdown/kill1.mp3");
	FakePrecacheSound("*/touchdown/kill2.mp3");
	FakePrecacheSound("*/touchdown/kill3.mp3");
	FakePrecacheSound("*/touchdown/kill4.mp3");
	FakePrecacheSound("*/touchdown/kill5.mp3");
	FakePrecacheSound("*/touchdown/kill6.mp3");
	FakePrecacheSound("*/touchdown/kill7.mp3");
	FakePrecacheSound("*/touchdown/kill8.mp3");
	FakePrecacheSound("*/touchdown/ready1.mp3");
	FakePrecacheSound("*/touchdown/ready2.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking1.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking2.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking3.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking4.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking5.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking6.mp3");
	FakePrecacheSound("*/touchdown/you_are_attacking7.mp3");
	FakePrecacheSound("*/touchdown/you_are_defending.mp3");
	FakePrecacheSound("*/touchdown/you_are_defending1.mp3");
	FakePrecacheSound("*/touchdown/you_are_defending2.mp3");
	FakePrecacheSound("*/touchdown/you_have_won_the_match.mp3");
	FakePrecacheSound("*/touchdown/you_have_won_the_match1.mp3");
	FakePrecacheSound("*/touchdown/you_lost_the_match.mp3");
	FakePrecacheSound("*/touchdown/you_lost_the_match1.mp3");
	FakePrecacheSound("*/touchdown/_eu_ball_reset.mp3");
	FakePrecacheSound("*/touchdown/player_respawn.mp3");
	//FakePrecacheSound("*/touchdown/jump_up.mp3");
	FakePrecacheSound("*/touchdown/player_dead.mp3");
	FakePrecacheSound("*/touchdown/_eu_voice_man_dead_blow.mp3");
	FakePrecacheSound("*/touchdown/_eu_voice_man_dead_hard.mp3");
	FakePrecacheSound("*/touchdown/_eu_voice_man_dead_normal.mp3");
	FakePrecacheSound("*/touchdown/_eu_voice_man_dead_shock.mp3");
	
	// Precache BGM
	FakePrecacheSound("*/touchdown/bgm/Chain_Reaction.mp3");
	FakePrecacheSound("*/touchdown/bgm/Super_Sonic.mp3");
	FakePrecacheSound("*/touchdown/bgm/Nova.mp3");
	FakePrecacheSound("*/touchdown/bgm/Lobby.mp3");
	FakePrecacheSound("*/touchdown/bgm/Dual_Rock.mp3");
	FakePrecacheSound("*/touchdown/bgm/Move_Your_Spirit.mp3");
	FakePrecacheSound("*/touchdown/bgm/Fuzzy_Control.mp3");
	FakePrecacheSound("*/touchdown/bgm/Seize.mp3");
	FakePrecacheSound("*/touchdown/bgm/Syriana.mp3");
	FakePrecacheSound("*/touchdown/bgm/Access.mp3");
	FakePrecacheSound("*/touchdown/bgm/Grave_Consequence.mp3");
	FakePrecacheSound("*/touchdown/bgm/Come_On.mp3");
	FakePrecacheSound("*/touchdown/bgm/Starfish.mp3");
	FakePrecacheSound("*/touchdown/bgm/NB_Power.mp3");
	FakePrecacheSound("*/touchdown/bgm/Alice.mp3");
	FakePrecacheSound("*/touchdown/bgm/Chase_yourself.mp3");
	FakePrecacheSound("*/touchdown/bgm/Dark_ages.mp3");
	FakePrecacheSound("*/touchdown/bgm/Dark_lightning.mp3");
	FakePrecacheSound("*/touchdown/bgm/Hypersonic.mp3");
	FakePrecacheSound("*/touchdown/bgm/Never_give_up.mp3");
	FakePrecacheSound("*/touchdown/bgm/Real_overdrive.mp3");
	
	// Ball
	FakePrecacheSound("*/touchdown/pokeball_bounce.mp3");
	
	// Score
	score_t = 0;
	score_ct = 0;
	
	// Cvars
	i_mp_ignore_round_win_conditions = 0;
	mp_ignore_round_win_conditions.IntValue = 0;
	mp_freezetime.IntValue = 0;
	mp_weapons_allow_map_placed.IntValue = 0;
	mp_death_drop_gun.IntValue = 0;
	mp_playercashawards.IntValue = 0;
	mp_teamcashawards.IntValue = 0;
	mp_free_armor.IntValue = 2;
	mp_match_restart_delay.IntValue = 20;
	mp_win_panel_display_time.IntValue = 7;
}

// https://wiki.alliedmods.net/Csgo_quirks
stock void FakePrecacheSound(const char[] szPath)
{
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}

// https://forums.alliedmods.net/showpost.php?p=2471747&postcount=4
stock void PrecacheEffect(const char[] sEffectName)
{
		static int table = INVALID_STRING_TABLE;
		
		if (table == INVALID_STRING_TABLE)
		{
				table = FindStringTable("EffectDispatch");
		}
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
}

stock void PrecacheParticleEffect(const char[] sEffectName)
{
		static int table = INVALID_STRING_TABLE;
		
		if (table == INVALID_STRING_TABLE)
		{
				table = FindStringTable("ParticleEffectNames");
		}
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
}  

public void OnEntityCreated(int entity, const char[] classname)
{
		if(StrEqual(classname, "game_player_equip"))
		{
				AcceptEntityInput(entity, "Kill");
		}
}  

// Remove C4
public Action Event_ItemPickUp(Handle event, const char[] name, bool dontBroadcast)
{
	char temp[32];
	GetEventString(event, "item", temp, sizeof(temp));
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(StrEqual(temp, "weapon_c4", false)) //Find the bomb carrier
	{
		int WeaponIndex = GetPlayerWeaponSlot(client, 4);
		RemovePlayerItem(client, WeaponIndex); //Remove the bomb
	}
	return Plugin_Continue;
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IsFakeClient(client))
		CreateTimer(0.1, ShowWeaponMenu, client);
	else GiveRandomWeapon(client);
	
	CreateTimer(0.1, FreezeClient, client);
	EmitSoundToClient(client, "*/touchdown/player_respawn.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
	EmitSoundToSpec(client, "*/touchdown/player_respawn.mp3");
	
	// https://github.com/mukunda-/rxg-plugins/blob/fc533fcc9aeab3715b89d1a5c99905deb9a17865/gamefixes/restart_fix.sp
	if(GetClientTeam(client) == TR)	g_spawned_t = true;
	
	if(GetClientTeam(client) == CT) g_spawned_ct = true;
	
	// both team have players
	if (g_spawned_t && g_spawned_ct && !bWarmUp)
	{
		i_mp_ignore_round_win_conditions = 1;
		mp_ignore_round_win_conditions.IntValue = 1;
	}
}

// Weapons
// Edited from boomix's capture the flag, add translations and some improvement.
public Action ShowWeaponMenu(Handle tmr, any client)
{
	if (!IsValidClient(client) || IsFakeClient(client))	return;
	
	// New weapon
	if (!b_AutoGiveWeapons[client] && b_SelectedWeapon[client])
	{
		RemoveAllWeapons(client, false);
		
		if(btd_taser)	GivePlayerItem(client, "weapon_taser");
		
		if(btd_healthshot)	GivePlayerItem(client, "weapon_healthshot");
			
		GivePlayerItem(client, g_LastPrimaryWeapon[client]);
		GivePlayerItem(client, g_LastSecondaryWeapon[client]);
		b_SelectedWeapon[client] = false;
	}
	
	else if(b_AutoGiveWeapons[client] && !b_SelectedWeapon[client])
	{
		RemoveAllWeapons(client, false);
		
		if(btd_taser)	GivePlayerItem(client, "weapon_taser");
		
		if(btd_healthshot)	GivePlayerItem(client, "weapon_healthshot");
		
		// Always random
		if(i_RandomWeapons[client] == 2)	GiveRandomWeapon(client);

		// Random this time
		else if(i_RandomWeapons[client] == 1)
		{
			GiveRandomWeapon(client);
			
			i_RandomWeapons[client] = 0;
			b_SelectedWeapon[client] = false;
		}
		
		// Always last weapon
		else if(i_RandomWeapons[client] == 0)
		{
			GivePlayerItem(client, g_LastPrimaryWeapon[client]);
			GivePlayerItem(client, g_LastSecondaryWeapon[client]);
		}
	} 
	
	// Player doesn't select a weapon
	else if(!b_AutoGiveWeapons[client] && !b_SelectedWeapon[client])
	{
		RemoveAllWeapons(client, false);
		
		if(btd_taser)	GivePlayerItem(client, "weapon_taser");
		
		if(btd_healthshot)	GivePlayerItem(client, "weapon_healthshot");
			
		ShowMainMenu(client);
	}
}

void ShowMainMenu(int client)
{
	Menu menu = new Menu(MenuHandlers_MainMenu);
	char weaponmenu[512];
	Format(weaponmenu, sizeof(weaponmenu), "%T", "Weapon Menu", client);
	SetMenuTitle(menu, weaponmenu);
	
	char newweapons[512];
	Format(newweapons, sizeof(newweapons), "%T", "New Weapons", client);
	menu.AddItem("new", newweapons);
	
	char lastweapons[512];
	Format(lastweapons, sizeof(lastweapons), "%T", "Last Weapons", client);
	
	char lastweapons2[512];
	Format(lastweapons2, sizeof(lastweapons2), "%T", "Last Weapons All The Time", client);
	
	if(StrContains(g_LastPrimaryWeapon[client], "weapon_") != -1 && StrContains(g_LastSecondaryWeapon[client], "weapon_") != -1 )
	{
		menu.AddItem("last", lastweapons);
		menu.AddItem("lastf", lastweapons2);
	} 
	else 
	{
		menu.AddItem("", lastweapons, ITEMDRAW_DISABLED);
		menu.AddItem("", lastweapons2, ITEMDRAW_DISABLED);
	}
	
	char randomweapons[512];
	Format(randomweapons, sizeof(randomweapons), "%T", "Random Weapons", client);
	menu.AddItem("random", randomweapons);
	
	char randomweapons2[512];
	Format(randomweapons2, sizeof(randomweapons2), "%T", "Random Weapons All The Time", client);
	menu.AddItem("random2", randomweapons2);
	
	menu.ExitButton = true;
	menu.Display(client, 0);
}

public int MenuHandlers_MainMenu(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(item, info, sizeof(info));

			if(StrEqual(info, "new"))
			{
				ShowPrimaryWeaponMenu(client);
				return;
			}
			
			else if(StrEqual(info, "last"))
			{
				if(!HasWeapon(client) && IsPlayerAlive(client))
				{
					GivePlayerItem(client, g_LastPrimaryWeapon[client]);
					GivePlayerItem(client, g_LastSecondaryWeapon[client]);
				}
				return;
			}
			
			else if(StrEqual(info, "lastf"))
			{
				if(!HasWeapon(client) && IsPlayerAlive(client))
				{
					GivePlayerItem(client, g_LastPrimaryWeapon[client]);
					GivePlayerItem(client, g_LastSecondaryWeapon[client]);
				}
				b_AutoGiveWeapons[client] = true;
				return;
			}

			else if(StrEqual(info, "random"))
			{
				GiveRandomWeapon(client);
				
				i_RandomWeapons[client] = 1;
				b_SelectedWeapon[client] = true;
				
				return;
			}
			
			else if(StrEqual(info, "random2"))
			{
				GiveRandomWeapon(client);
				
				b_AutoGiveWeapons[client] = true;
				i_RandomWeapons[client] = 2;
				
				return;
			}
		}
	}
}

void ShowPrimaryWeaponMenu(int client)
{
	Menu menu = new Menu(MenuHandlers_PrimaryWeapon);
	char primaryweapon[512];
	Format(primaryweapon, sizeof(primaryweapon), "%T", "Primary Weapon", client);
	SetMenuTitle(menu, primaryweapon);
	
	menu.AddItem("weapon_ak47", "AK-47");
	menu.AddItem("weapon_m4a1", "M4A4");
	menu.AddItem("weapon_m4a1_silencer", "M4A1-S");
	menu.AddItem("weapon_galilar", "Galil AR");
	menu.AddItem("weapon_famas", "Famas");
	menu.AddItem("weapon_aug", "AUG");
	menu.AddItem("weapon_ssg08", "SSG 08");
	menu.AddItem("weapon_sg556", "SG 553");
	menu.AddItem("weapon_nova", "Nova");
	menu.AddItem("weapon_xm1014", "XM1014");
	menu.AddItem("weapon_mag7", "Mag 7");
	menu.AddItem("weapon_sawedoff", "Sawed-off");
	menu.AddItem("weapon_bizon", "PP-Bizon");
	menu.AddItem("weapon_mac10", "MAC-10");
	menu.AddItem("weapon_mp9", "MP9");
	menu.AddItem("weapon_mp7", "MP7");
	menu.AddItem("weapon_mp5sd", "MP5-SD");
	menu.AddItem("weapon_ump45", "UMP45");
	menu.AddItem("weapon_p90", "P90");

	menu.ExitButton = false;
	menu.Display(client, 0);
}

public int MenuHandlers_PrimaryWeapon(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			if(!HasWeapon(client) && IsPlayerAlive(client))	GivePlayerItem(client, info);
			
			g_LastPrimaryWeapon[client] = info;
			
			Menu menu2 = new Menu(MenuHandlers_SecondaryWeapon);
			char secondaryweapon[512];
			Format(secondaryweapon, sizeof(secondaryweapon), "%T", "Secondary Weapon", client);
			SetMenuTitle(menu2, secondaryweapon);
			menu2.AddItem("weapon_deagle", 		"Deagle");
			menu2.AddItem("weapon_revolver", 	"Revolver");
			menu2.AddItem("weapon_elite", 		"Dual burretas");
			menu2.AddItem("weapon_fiveseven",	"Five seven");
			menu2.AddItem("weapon_glock", 		"Glock");
			menu2.AddItem("weapon_hkp2000", 	"P2000");
			menu2.AddItem("weapon_usp_silencer", 	"USP-S");
			menu2.AddItem("weapon_p250", 		"P250");
			menu2.AddItem("weapon_tec9", 		"TEC-9");
			menu2.ExitButton =  false;
			menu2.Display(client, 0);
		}
	}
}

public int MenuHandlers_SecondaryWeapon(Menu menu2, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu2.GetItem(item, info, sizeof(info));
			
			if(!HasWeapon(client, 2) && IsPlayerAlive(client))	GivePlayerItem(client, info);
			
			g_LastSecondaryWeapon[client] = info;
			
			b_SelectedWeapon[client] = true;
		}
	}
}

public void RemoveAllWeapons(int client, bool RemoveKnife)
{
	//Primary weapon check
	if(!IsValidClient(client))	return;
		
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0) 
	{
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);
	}
	
	//Secondary
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0) 
	{
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}
	
	//Grenade
	int weapon3 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon3 > 0) 
	{
		RemovePlayerItem(client, weapon3);
		RemoveEdict(weapon3);
	}
	
	//Grenade
	int weapon4 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon4 > 0) 
	{
		RemovePlayerItem(client, weapon4);
		RemoveEdict(weapon4);
	}
	
	if(RemoveKnife)
	{
		int weapon5 = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
		if(weapon5 > 0) 
		{
			RemovePlayerItem(client, weapon5);
			RemoveEdict(weapon5);
		}	
	}
}

bool HasWeapon(int client, int type = 3)
{
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

	// type 1, only check primary
	if (type == 1 && weapon > 0) return true;
	// type 2, only check secondary
	else if (type == 2 && weapon2 > 0) return true;
	else if (type == 3 && (weapon > 0 || weapon2 > 0)) return true
	else return false;
}

void GiveRandomWeapon(int client)
{
	int primary = GetRandomInt(0, 18);
	int secondary = GetRandomInt(0, 9);
	
	if((IsPlayerAlive(client) && !HasWeapon(client, 1)) || IsFakeClient(client))
	{
		GivePlayerItem(client, PrimaryWeapon[primary]);
		GivePlayerItem(client, SecondaryWeapon[secondary]);	
	}
		
	g_LastPrimaryWeapon[client] = PrimaryWeapon[primary];
	g_LastSecondaryWeapon[client] = SecondaryWeapon[secondary];
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	RoundEnd = false;
	
	RoundEnd_OnRoundStart();
	
	// Switch score after half
	if(Switch)
	{
		score_ct2 = score_ct;
		score_t2 = score_t;
	
		score_t = score_ct2;
		score_ct = score_t2;

		SetTeamScore(CS_TEAM_CT, score_t2);
		SetTeamScore(CS_TEAM_T, score_ct2);
		
		Switch = false;
	}
	
	// Remove Hostage
	int iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, "hostage_entity")) != -1) //Find the hostages themselves and destroy them
	{
		AcceptEntityInput(iEnt, "kill");
	}
	
	// Create ball model
	SpawnBall(BallSpawnPoint);
	SpawnTGoal(TGoalSpawnPoint);
	SpawnCTGoal(CTGoalSpawnPoint);
	
	// Reset ball holder
	BallHolder = 0;
	BallDroperTeam = 0;
	Touchdowner = 0;
	
	// Reset timer
	ResetTimer();
	
	// Play Round Start Sound
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i)) 
		{
			if(!IsFakeClient(i))
			{
				CreateTimer(1.0, StartGameTimer);
				switch(GetRandomInt(1, 2))
				{
					case 1:
					{
						//ClientCommand(i, "play *touchdown/ready1.mp3");
						EmitSoundToClient(i, "*/touchdown/ready1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
					}
					case 2:
					{
						//ClientCommand(i, "play *touchdown/ready2.mp3");
						EmitSoundToClient(i, "*/touchdown/ready2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
					}
				}
			}

			// Unfreeze players
			if (GetClientTeam(i) == CT || GetClientTeam(i) == TR) SetEntityMoveType(i, MOVETYPE_WALK);
		}
	}
		
	// Play BGM
	if(btd_bgm_enabled) CreateTimer(0.5, PlayBGMTimer);
	
	// round countdown
	roundtime = FindConVar("mp_roundtime").FloatValue;
	roundtime *= 60.0;
	hRoundCountdown = CreateTimer(1.0, RoundCountdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action PlayBGMTimer(Handle tmr, any client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !IsFakeClient(i))
		{
			StopBGM(i);
			
			BGM = GetRandomInt(1, 21)
			
			hBGMTimer[i] = CreateTimer(0.5, BGMTimer, i);
		}
	}
}

public Action StartGameTimer(Handle tmr, any client)
{
	for (int i = 1; i <= MaxClients; i++) 
	{ 
				if(IsValidClient(i) && !IsFakeClient(i))
				{
					PrintHintText(i, "%T", "Start Game", i);
				}
		} 
}

public Action BGMTimer(Handle tmr, any client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
	{ 
		if(BGM == 1)
		{
			CPrintToChat(client, "%T", "BGM 1", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Chain_Reaction.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(195.0, BGMTimer, client);
		}
		
		else if(BGM == 2)
		{
			CPrintToChat(client, "%T", "BGM 2", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Super_Sonic.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(195.0, BGMTimer, client);
		}
	
		else if(BGM == 3)	
		{
			CPrintToChat(client, "%T", "BGM 3", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Nova.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(123.0, BGMTimer, client);
		}
		
		else if(BGM == 4)	
		{
			CPrintToChat(client, "%T", "BGM 4", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Lobby.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(132.0, BGMTimer, client);
		}
		
		else if(BGM == 5)	
		{
			CPrintToChat(client, "%T", "BGM 5", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Dual_Rock.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(163.0, BGMTimer, client);
		}
		
		else if(BGM == 6)	
		{
			CPrintToChat(client, "%T", "BGM 6", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Move_Your_Spirit.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(230.0, BGMTimer, client);
		}
		
		else if(BGM == 7)	
		{
			CPrintToChat(client, "%T", "BGM 7", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Fuzzy_Control.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(159.0, BGMTimer, client);
		}
		
		else if(BGM == 8)	
		{
			CPrintToChat(client, "%T", "BGM 8", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Seize.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(122.0, BGMTimer, client);
		}
		
		else if(BGM == 9)	
		{
			CPrintToChat(client, "%T", "BGM 9", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Syriana.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(92.0, BGMTimer, client);
		}
		
		else if(BGM == 10)	
		{
			CPrintToChat(client, "%T", "BGM 10", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Access.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(145.0, BGMTimer, client);
		}
		
		else if(BGM == 11)	
		{
			CPrintToChat(client, "%T", "BGM 11", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Grave_Consequence.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(99.0, BGMTimer, client);
		}
		
		else if(BGM == 12)	
		{
			CPrintToChat(client, "%T", "BGM 12", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Come_On.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(180.0, BGMTimer, client);
		}
		
		else if(BGM == 13)	
		{
			CPrintToChat(client, "%T", "BGM 13", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Starfish.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(135.0, BGMTimer, client);
		}
		
		else if(BGM == 14)	
		{
			CPrintToChat(client, "%T", "BGM 14", client);
			EmitSoundToClient(client, "*/touchdown/bgm/NB_Power.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(125.0, BGMTimer, client);
		}

		else if(BGM == 15)	
		{
			CPrintToChat(client, "%T", "BGM 15", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Alice.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(181.0, BGMTimer, client);
		}

		else if(BGM == 16)	
		{
			CPrintToChat(client, "%T", "BGM 16", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Chase_yourself.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(140.0, BGMTimer, client);
		}

		else if(BGM == 17)	
		{
			CPrintToChat(client, "%T", "BGM 17", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Dark_ages.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(160.0, BGMTimer, client);
		}

		else if(BGM == 18)	
		{
			CPrintToChat(client, "%T", "BGM 18", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Dark_lightning.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(119.0, BGMTimer, client);
		}

		else if(BGM == 19)	
		{
			CPrintToChat(client, "%T", "BGM 19", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Hypersonic.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(80.0, BGMTimer, client);
		}

		else if(BGM == 20)	
		{
			CPrintToChat(client, "%T", "BGM 20", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Never_give_up.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(225.0, BGMTimer, client);
		}

		else if(BGM == 21)	
		{
			CPrintToChat(client, "%T", "BGM 21", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Real_overdrive.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(121.0, BGMTimer, client);
		}
	}
}

void StopBGM(int client)
{
	if(BGM == 1)
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Chain_Reaction.mp3");
	}
		
	else if(BGM == 2)
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Super_Sonic.mp3");
	}
	
	else if(BGM == 3)	
	{
		StopSound(client, SNDCHAN_STATIC,  "*/touchdown/bgm/Nova.mp3");
	}
	
	else if(BGM == 4)	
	{
		StopSound(client, SNDCHAN_STATIC,  "*/touchdown/bgm/Lobby.mp3");
	}
		
	else if(BGM == 5)	
	{
		StopSound(client, SNDCHAN_STATIC,  "*/touchdown/bgm/Dual_Rock.mp3");
	}
	
	else if(BGM == 6)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Move_Your_Spirit.mp3");
	}
		
	else if(BGM == 7)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Fuzzy_Control.mp3");	
	}
	
	else if(BGM == 8)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Seize.mp3");	
	}
	
	else if(BGM == 9)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Syriana.mp3");	
	}
	
	else if(BGM == 10)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Access.mp3");	
	}
	
	else if(BGM == 11)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Grave_Consequence.mp3");	
	}
	
	else if(BGM == 12)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Come_On.mp3");	
	}
	
	else if(BGM == 13)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Starfish.mp3");	
	}
	
	else if(BGM == 14)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/NB_Power.mp3");	
	}

	else if(BGM == 15)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Alice.mp3");
	}

	else if(BGM == 16)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Chase_yourself.mp3");
	}

	else if(BGM == 17)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Dark_ages.mp3");
	}

	else if(BGM == 18)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Dark_lightning.mp3");
	}

	else if(BGM == 19)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Hypersonic.mp3");
	}

	else if(BGM == 20)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Never_give_up.mp3");
	}

	else if(BGM == 21)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Real_overdrive.mp3");
	}
}

public void OnClientPutInServer(int client)
{
	if(!IsValidClient(client) && IsFakeClient(client))
		return;
		
	if(BGM != 0)
	{
		hBGMTimer[client] = CreateTimer(2.0, BGMTimer, client);
	}
	
	OnClientCookiesCached(client);
	
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}

public void OnClientCookiesCached(int client)
{
	char buffer[5];
	GetClientCookie(client, clientVolCookie, buffer, 5);
	if(!StrEqual(buffer, ""))
	{
		g_fvol[client] = StringToFloat(buffer);
	}
	if(StrEqual(buffer,"")){
		g_fvol[client] = 0.8;
	}
}

public void OnClientPostAdminCheck(int client)		
{		
	if((btd_stats_enabled || btd_points_enabled) && ddb != null)	LoadClientStats(client);		
}

public Action RoundCountdown(Handle tmr)
{
	--roundtime;
	
	//3 mins, 1 mins, 30 sec, 10...1 left
		
	if (roundtime == 180)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "3 Minutes Left Hint", i);
				CPrintToChat(i, "%T", "3 Minutes Left", i);
				
				EmitSoundToClient(i, "*/touchdown/_eu_3minute.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 60)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "1 Minute Left Hint", i);
				CPrintToChat(i, "%T", "1 Minute Left", i);
				
				EmitSoundToClient(i, "*/touchdown/_eu_1minute.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 30)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "30 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "30 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/_eu_30second.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 10)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "10 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "10 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/10.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 9)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "9 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "9 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/9.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}

	else if (roundtime == 8)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "8 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "8 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/8.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 7)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "7 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "7 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 6)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "6 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "6 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 5)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "5 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "5 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "4 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "4 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 3)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "3 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "3 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 2)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "2 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "2 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "1 Second Left Hint", i);
				CPrintToChat(i, "%T", "1 Second Left", i);
				
				EmitSoundToClient(i, "*/touchdown/1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 0)
	{
		if(hRoundCountdown != INVALID_HANDLE)
		{
			KillTimer(hRoundCountdown);
			hRoundCountdown = INVALID_HANDLE;
		}
	}
}

void ResetTimer()
{
	if(hNextRoundCountdown != INVALID_HANDLE)
	{
		KillTimer(hNextRoundCountdown);
	}
	hNextRoundCountdown = INVALID_HANDLE;
	
	if(hRoundCountdown != INVALID_HANDLE)
	{
		KillTimer(hRoundCountdown);
	}
	hRoundCountdown = INVALID_HANDLE;
	
	if(hResetBallTimer != INVALID_HANDLE)
	{
		KillTimer(hResetBallTimer);
		hResetBallTimer = INVALID_HANDLE;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			if (hBGMTimer[i] != INVALID_HANDLE)
			{
				KillTimer(hBGMTimer[i]);
			}
			hBGMTimer[i] = INVALID_HANDLE;
			
			if(hAcquiredBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hAcquiredBallText[i]);
			}
			hAcquiredBallText[i] = INVALID_HANDLE;
	
			if(hRAcquiredBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRAcquiredBallText[i]);
			}
			hRAcquiredBallText[i] = INVALID_HANDLE;
		
			if(hDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hDropBallText[i]);
			}
			hDropBallText[i] = INVALID_HANDLE;
	
			if(hRDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRDropBallText[i]);
			}
			hRDropBallText[i] = INVALID_HANDLE;
		}
	}
}

public Action NextRoundCountdown(Handle tmr)
{
	--Nextroundtime;
		
		// We don't need this in Half time and warmup
	if (Switch || bWarmUp)
	{
		if(hNextRoundCountdown != INVALID_HANDLE)
		{
			KillTimer(hNextRoundCountdown);
			hNextRoundCountdown = INVALID_HANDLE;
		}
	}
	
	if (Nextroundtime == 6)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "Next Round In", i);			
				
				switch(GetRandomInt(1,4))
				{
					case 1:
					{
						EmitSoundToClient(i, "*/touchdown/new_round_in.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
					}
					case 2:
					{
						EmitSoundToClient(i, "*/touchdown/new_round_in1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
					}
					case 3:
					{
						EmitSoundToClient(i, "*/touchdown/next_round_in.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
					}
					case 4:
					{
						EmitSoundToClient(i, "*/touchdown/next_round_in1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
					}
				}
			}
		}
	}
	
	else if (Nextroundtime == 5)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 5", i);
			}
		}
	}
	
	else if (Nextroundtime == 4)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 4", i);
			}
		}
	}
	
	else if (Nextroundtime == 3)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 3", i);
			}
		}
	}
	
	else if (Nextroundtime == 2)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 2", i);
			}
		}
	}
	
	else if (Nextroundtime == 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 1", i);
			}
		}
	}
	
	else if (Nextroundtime <= 0)
	{
		if(hNextRoundCountdown != INVALID_HANDLE)
		{
			KillTimer(hNextRoundCountdown);
			hNextRoundCountdown = INVALID_HANDLE;
		}
	}
}

void SpawnCTGoal(float pos[3])
{
	int entity;
	entity  = EntRefToEntIndex(CTGoalRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		CTGoalRef = INVALID_ENT_REFERENCE;
	}
	entity  = EntRefToEntIndex(CTPoleRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		CTPoleRef = INVALID_ENT_REFERENCE;
	}
	entity  = EntRefToEntIndex(CTGroundRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		CTGroundRef = INVALID_ENT_REFERENCE;
	}
	
	// Create CT goal model
	// CT Flag
	CTGoalModel = CreateEntityByName("prop_dynamic_override");
		
	SetEntityModel(CTGoalModel, FlagModelPath);
	SetEntPropString(CTGoalModel, Prop_Data, "m_iName", "CTGoalFlag");
	SetEntProp(CTGoalModel, Prop_Send, "m_nBody", 0);

	DispatchSpawn(CTGoalModel);
	
	CTGoalRef = EntIndexToEntRef(CTGoalModel);
	
	SetVariantString("flag_idle1");
	AcceptEntityInput(CTGoalModel, "SetAnimation");
	AcceptEntityInput(CTGoalModel, "TurnOn");
	
	float ctgoalpos[3];
	ctgoalpos[0] = pos[0];
	ctgoalpos[1] = pos[1];
	ctgoalpos[2] = pos[2];

	TeleportEntity(CTGoalModel, ctgoalpos, NULL_VECTOR, NULL_VECTOR);
	
	// CT Pole
	CTPoleModel = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(CTPoleModel, PoleModelPath);
	SetEntPropString(CTPoleModel, Prop_Data, "m_iName", "CTGoalPole");
	SetEntProp(CTPoleModel, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(CTPoleModel, Prop_Data, "m_nSolidType", 6);
	SetEntProp(CTPoleModel, Prop_Send, "m_CollisionGroup", 1);
	
	float ctpolepos[3];
	ctpolepos[0] = pos[0];
	ctpolepos[1] = pos[1];
	ctpolepos[2] = pos[2] + 40;
	
	CTPoleRef = EntIndexToEntRef(CTPoleModel);

	TeleportEntity(CTPoleModel, ctpolepos, NULL_VECTOR, NULL_VECTOR);	

	SDKHook(CTPoleModel, SDKHook_StartTouch, OnStartTouch);
	
	// CT Ground
	CTGroundModel = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(CTGroundModel, GroundModelPath);
	SetEntPropString(CTGroundModel, Prop_Data, "m_iName", "CTGoalGround");
	SetEntProp(CTGroundModel, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(CTGroundModel, Prop_Data, "m_nSolidType", 6);
	SetEntProp(CTGroundModel, Prop_Send, "m_CollisionGroup", 1);
	
	float ctgroundpos[3];
	ctgroundpos[0] = pos[0];
	ctgroundpos[1] = pos[1];
	ctgroundpos[2] = pos[2];
	
	CTGroundRef = EntIndexToEntRef(CTGroundModel);

	TeleportEntity(CTGroundModel, ctgroundpos, NULL_VECTOR, NULL_VECTOR);	
}

void SpawnTGoal(float pos[3])
{
	int entity;
	entity  = EntRefToEntIndex(TGoalRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		TGoalRef = INVALID_ENT_REFERENCE;
	}
	entity  = EntRefToEntIndex(TPoleRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		TPoleRef = INVALID_ENT_REFERENCE;
	}
	entity  = EntRefToEntIndex(TGroundRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		TGroundRef = INVALID_ENT_REFERENCE;
	}
	
	// Create T goal model
	// T Flag
	TGoalModel = CreateEntityByName("prop_dynamic_override");
		
	SetEntityModel(TGoalModel, FlagModelPath);
	SetEntPropString(TGoalModel, Prop_Data, "m_iName", "TGoalFlag");
	SetEntProp(TGoalModel, Prop_Send, "m_nBody", 3);

	DispatchSpawn(TGoalModel);
	
	TGoalRef = EntIndexToEntRef(TGoalModel);
	
	SetVariantString("flag_idle1");
	AcceptEntityInput(TGoalModel, "SetAnimation");
	AcceptEntityInput(TGoalModel, "TurnOn");
	
	float TGoalModelpos[3];
	TGoalModelpos[0] = pos[0];
	TGoalModelpos[1] = pos[1];
	TGoalModelpos[2] = pos[2];

	TeleportEntity(TGoalModel, TGoalModelpos, NULL_VECTOR, NULL_VECTOR);
	
	// T Pole
	TPoleModel = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(TPoleModel, PoleModelPath);
	SetEntPropString(TPoleModel, Prop_Data, "m_iName", "TGoalPole");
	SetEntProp(TPoleModel, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(TPoleModel, Prop_Data, "m_nSolidType", 6);
	SetEntProp(TPoleModel, Prop_Send, "m_CollisionGroup", 1);
	
	float tpolepos[3];
	tpolepos[0] = pos[0];
	tpolepos[1] = pos[1];
	tpolepos[2] = pos[2] + 40;
	
	TPoleRef = EntIndexToEntRef(TPoleModel);

	TeleportEntity(TPoleModel, tpolepos, NULL_VECTOR, NULL_VECTOR);	
	
	SDKHook(TPoleModel, SDKHook_StartTouch, OnStartTouch);
	
	// T Ground
	TGroundModel = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(TGroundModel, GroundModelPath);
	SetEntPropString(TGroundModel, Prop_Data, "m_iName", "TGoalGround");
	SetEntProp(TGroundModel, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(TGroundModel, Prop_Data, "m_nSolidType", 6);
	SetEntProp(TGroundModel, Prop_Send, "m_CollisionGroup", 1);

	float tgroundpos[3];
	tgroundpos[0] = pos[0];
	tgroundpos[1] = pos[1];
	tgroundpos[2] = pos[2];
	
	TGroundRef = EntIndexToEntRef(TGroundModel);

	TeleportEntity(TGroundModel, tgroundpos, NULL_VECTOR, NULL_VECTOR);
}

public void OnStartTouch(int ent, int client)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsValidEntity(client))
		return;
	
	char Item[255];
	GetEntPropString(ent, Prop_Data, "m_iName", Item, sizeof(Item));
	
	// Someone get the ball
	if (StrEqual(Item, "TDBall"))
	{
		if(GetClientTeam(client) == SPEC)
			return;
		
		// You can't pick up the ball in warmup
		if(bWarmUp)
		{
			CPrintToChat(client, "%T", "No pick up warmup", client)
			return;
		}
		
		// Client get the ball
		if(BallHolder == 0 && IsPlayerAlive(client) && IsValidEntity(client))
		{
			GetBall(client);
		}
		else return;
		
		// Play Sound
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				// TR get the ball
				if(GetClientTeam(client) == TR)
				{
					CPrintToChat(i, "%T", "Get Ball T", i, client);
					
					// TR play attack Sound
					if(GetClientTeam(i) == TR)
					{
						hAcquiredBallText[i] = CreateTimer(0.1, AcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 8))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking2.mp3");
							}
							case 4:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking3.mp3");
							}
							case 5:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking4.mp3");
							}
							case 6:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking5.mp3");
							}
							case 7:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking6.mp3");
							}
							case 8:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking7.mp3");
							}
						}
					}
					// CT play defence sound
					else if(GetClientTeam(i) == CT)
					{
						hRAcquiredBallText[i] = CreateTimer(0.1, RAcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 3))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_defending.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_defending.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_defending1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_defending1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_defending2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_defending2.mp3");
							}
						}
					}
				}
				// CT get the ball
				else if(GetClientTeam(client) == CT)
				{
					CPrintToChat(i, "%T", "Get Ball CT", i, client);
					
					// CT play attack Sound
					if(GetClientTeam(i) == CT)
					{
						hAcquiredBallText[i] = CreateTimer(0.1, AcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 8))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking2.mp3");
							}
							case 4:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking3.mp3");
							}
							case 5:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking4.mp3");
							}
							case 6:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking5.mp3");
							}
							case 7:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking6.mp3");
							}
							case 8:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_attacking7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_attacking7.mp3");
							}
						}
					}
					// TR play defence sound
					else if(GetClientTeam(i) == TR)
					{
						hRAcquiredBallText[i] = CreateTimer(0.1, RAcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 3))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_defending.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_defending.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_defending1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_defending1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/you_are_defending2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
								EmitSoundToSpec(i, "*/touchdown/you_are_defending2.mp3");
							}
						}
					}
				}
			}
		}
	}
		
	// Someone Go to CT Goal
	else if (StrEqual(Item, "CTGoalPole"))
	{
		// And he is T and he has a ball.
		if(GetClientTeam(client) == TR && BallHolder == client && IsValidEntity(client))
		{
			// Touchdown is not allowed if time is up
			if(RoundEnd)
				return;
			
			// Remove ball
			GoalBall(client);	
			
			// T Win
			OnTeamWin(CS_TEAM_T);
			
			// Create CT Goal Particle
			CreateCTGoalParticle();
			
			// Announce touchdown
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i)) 
				{
					CPrintToChat(i, "%T", "Touchdown T", i, client);
				}
			}
		}
	}
	
	// Someone Go to T Goal
	else if (StrEqual(Item, "TGoalPole"))
	{
		// And he is CT and he has a ball.
		if(GetClientTeam(client) == CT && BallHolder == client && IsValidEntity(client))
		{
			// Touchdown is not allowed if time is up
			if(RoundEnd)
				return;
			
			// Remove ball
			GoalBall(client);
			
			// CT Win
			OnTeamWin(CS_TEAM_CT);
			
			// Creat T Goal Particle
			CreateTGoalParticle();
			
			// Announce touchdown
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i)) 
				{
					CPrintToChat(i, "%T", "Touchdown CT", i, client);
				}
			}
		}
	}
}

public Action AcquiredBallText(Handle tmr, any client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
		PrintHintText(client, "%T", "Acquired Ball", client);
}

public Action RAcquiredBallText(Handle tmr, any client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
		PrintHintText(client, "%T", "Rival Acquired Ball", client);
}

public Action SpecBallText(Handle tmr, any client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
		PrintHintText(client, "%T", "Acquired Ball", client);
}

void CreateCTGoalParticle()
{
	CTGoalParticle = CreateEntityByName("info_particle_system");
	
	DispatchKeyValue(CTGoalParticle, "start_active", "1");
	DispatchKeyValue(CTGoalParticle, "effect_name", GoalParticleEffect);
	DispatchSpawn(CTGoalParticle);
		
	float CTGoalModelpos[3];
	CTGoalModelpos[0] = CTGoalSpawnPoint[0];
	CTGoalModelpos[1] = CTGoalSpawnPoint[1];
	CTGoalModelpos[2] = CTGoalSpawnPoint[2];

	TeleportEntity(CTGoalParticle, CTGoalModelpos, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("!activator");	
	ActivateEntity(CTGoalParticle);
	AcceptEntityInput(CTGoalParticle, "Start");
}

void CreateTGoalParticle()
{
	TGoalParticle = CreateEntityByName("info_particle_system");
	
	DispatchKeyValue(TGoalParticle, "start_active", "1");
	DispatchKeyValue(TGoalParticle, "effect_name", GoalParticleEffect);
	DispatchSpawn(TGoalParticle);
		
	float TGoalModelpos[3];
	TGoalModelpos[0] = TGoalSpawnPoint[0];
	TGoalModelpos[1] = TGoalSpawnPoint[1];
	TGoalModelpos[2] = TGoalSpawnPoint[2];

	TeleportEntity(TGoalParticle, TGoalModelpos, NULL_VECTOR, NULL_VECTOR);

	SetVariantString("!activator");	
	ActivateEntity(TGoalParticle);
	AcceptEntityInput(TGoalParticle, "Start");
}

void OnTeamWin(int team)
{
	RoundEnd = true;
	
	if(team == CS_TEAM_CT)
	{
		SetTeamScore(CS_TEAM_CT, GetTeamScore(CS_TEAM_CT) + 1);
		score_ct++;
		CS_TerminateRound(15.0, CSRoundEnd_CTWin, true);
	}
	
	else if(team == CS_TEAM_T)
	{
		SetTeamScore(CS_TEAM_T, GetTeamScore(CS_TEAM_T) + 1);
		score_t++;
		CS_TerminateRound(15.0, CSRoundEnd_TerroristWin, true);
	}
	
	else if(team == CS_TEAM_NONE)
	{
		CS_TerminateRound(15.0, CSRoundEnd_Draw, true);
		//ServerCommand("sm_slay @all");
	}
}

public int GetTotalRoundTime() 
{
	return GameRules_GetProp("m_iRoundTime");
}

void GetBall(int client)
{
	if(!IsValidClient(client))
		return;
		
	// Call forward
	Call_StartForward(OnPlayerGetBall);
	Call_PushCell(client);
	Call_Finish();
	
	// Remove map model
	RemoveBall();
		
	// Stats
	if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
	{
		Stats[client].GETBALL++;
		
		if(btd_points_enabled)
		{
			Stats[client].POINTS += itd_points_pickball;
		
			if(itd_points_pickball != 0)
				CPrintToChat(client, "%T", "Point Get Ball", client, Stats[client].POINTS, itd_points_pickball);
		}
	}
	
	// Create ball model and attach it on player
	float m_fHatOrigin[3], m_fHatAngles[3], m_fForward[3], m_fRight[3], m_fUp[3], m_fOffset[3];

	GetClientAbsOrigin(client,m_fHatOrigin);
	GetClientAbsAngles(client,m_fHatAngles);

	// Front
	if(itd_ballposition == 0)
	{
		m_fOffset[0] = 6.0;
		m_fOffset[1] = 18.5;
		m_fOffset[2] = 15.0;
	}
	// Head
	else if(itd_ballposition == 1)
	{
		m_fOffset[0] = 0.0;
		m_fOffset[1] = 0.0;
		m_fOffset[2] = 91.0;
	}
		
	GetAngleVectors(m_fHatAngles, m_fForward, m_fRight, m_fUp);

	m_fHatOrigin[0] += m_fRight[0]*m_fOffset[0]+m_fForward[0]*m_fOffset[1]+m_fUp[0]*m_fOffset[2];
	m_fHatOrigin[1] += m_fRight[1]*m_fOffset[0]+m_fForward[1]*m_fOffset[1]+m_fUp[1]*m_fOffset[2];
	m_fHatOrigin[2] += m_fRight[2]*m_fOffset[0]+m_fForward[2]*m_fOffset[1]+m_fUp[2]*m_fOffset[2];
	
	// Create the hat entity
	PlayerBallModel = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(PlayerBallModel, "model", BallModelPath);
	DispatchKeyValue(PlayerBallModel, "spawnflags", "256");
	DispatchKeyValue(PlayerBallModel, "solid", "0");
	SetEntPropEnt(PlayerBallModel, Prop_Send, "m_hOwnerEntity", client);
	SetEntPropFloat(PlayerBallModel, Prop_Send, "m_flModelScale", 0.6);

	DispatchSpawn(PlayerBallModel);	
	AcceptEntityInput(PlayerBallModel, "TurnOn", PlayerBallModel, PlayerBallModel, 0);
	
	// Teleport the hat to the right position and attach it
	TeleportEntity(PlayerBallModel, m_fHatOrigin, m_fHatAngles, NULL_VECTOR); 

	SetVariantString("!activator");
	AcceptEntityInput(PlayerBallModel, "SetParent", client, PlayerBallModel, 0);
	
	PlayerBallRef = EntIndexToEntRef(PlayerBallModel);
	
	// Create player particle
	if(GetClientTeam(client) == TR)
	{
		TParticle = CreateEntityByName("info_particle_system");
	
		DispatchKeyValue(TParticle, "start_active", "1");
		DispatchKeyValue(TParticle, "effect_name", TParticleEffect);
		DispatchSpawn(TParticle);

		TeleportEntity(TParticle, m_fHatOrigin, m_fHatAngles, NULL_VECTOR);
		SetVariantString("!activator");	
		AcceptEntityInput(TParticle, "SetParent", client, TParticle, 0);	
		ActivateEntity(TParticle);
		TParticleRef = EntIndexToEntRef(TParticle);
		AcceptEntityInput(TParticle, "Start");
		
		SetEdictFlags(TParticle, GetEdictFlags(TParticle)&(~FL_EDICT_ALWAYS));
		SDKHookEx(TParticle, SDKHook_SetTransmit, Hook_SetTransmit);
	}
	
	else if(GetClientTeam(client) == CT)
	{
		CTParticle = CreateEntityByName("info_particle_system");
	
		DispatchKeyValue(CTParticle, "start_active", "1");
		DispatchKeyValue(CTParticle, "effect_name", CTParticleEffect);
		DispatchSpawn(CTParticle);

		TeleportEntity(CTParticle, m_fHatOrigin, m_fHatAngles, NULL_VECTOR);
		SetVariantString("!activator");	
		AcceptEntityInput(CTParticle, "SetParent", client, CTParticle, 0);	
		ActivateEntity(CTParticle);
		CTParticleRef = EntIndexToEntRef(CTParticle);
		AcceptEntityInput(CTParticle, "Start");
		
		SetEdictFlags(CTParticle, GetEdictFlags(CTParticle)&(~FL_EDICT_ALWAYS));
		SDKHookEx(CTParticle, SDKHook_SetTransmit, Hook_SetTransmit);
	}
	
	// Who hold the ball
	BallHolder = client;
	BallDroperTeam = 0;
	
	// Kill Reset Timer if ball picked up by player
	if(hResetBallTimer != INVALID_HANDLE)
	{
		KillTimer(hResetBallTimer);
		hResetBallTimer = INVALID_HANDLE;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			if(hDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hDropBallText[i]);
			}
			hDropBallText[i] = INVALID_HANDLE;
	
			if(hRDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRDropBallText[i]);
			}
			hRDropBallText[i] = INVALID_HANDLE;
		}
	}
}

public Action Hook_SetTransmit(int iEntity, int iClient)
{
	setFlags(iEntity);
}

void setFlags(int edict)
{
		if (GetEdictFlags(edict) & FL_EDICT_ALWAYS)
		{
				SetEdictFlags(edict, (GetEdictFlags(edict) ^ FL_EDICT_ALWAYS));
		}
}

void RemoveBall()
{
	int entity = EntRefToEntIndex(BallRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		AcceptEntityInput(entity, "Kill");
		BallRef = INVALID_ENT_REFERENCE;
	}
	
	int entity2 = EntRefToEntIndex(DropBallRef);
	if(entity2 != INVALID_ENT_REFERENCE && IsValidEdict(entity2) && entity2 != 0)
	{
		AcceptEntityInput(entity2, "Kill");
		DropBallRef = INVALID_ENT_REFERENCE;
	}
	
	int entity3 = EntRefToEntIndex(PlayerBallRef);
	if(entity3 != INVALID_ENT_REFERENCE && IsValidEdict(entity3) && entity3 != 0)
	{
		AcceptEntityInput(entity3, "Kill");
		PlayerBallRef = INVALID_ENT_REFERENCE;
	}
	
	int entity4 = EntRefToEntIndex(CTParticleRef);
	if(entity4 != INVALID_ENT_REFERENCE && IsValidEdict(entity4) && entity4 != 0)
	{
		AcceptEntityInput(entity4, "DestroyImmediately");
		AcceptEntityInput(entity4, "Kill");
		CTParticleRef = INVALID_ENT_REFERENCE;
	}
	
	int entity5 = EntRefToEntIndex(TParticleRef);
	if(entity5 != INVALID_ENT_REFERENCE && IsValidEdict(entity5) && entity5 != 0)
	{
		AcceptEntityInput(entity5, "DestroyImmediately");
		AcceptEntityInput(entity5, "Kill");
		TParticleRef = INVALID_ENT_REFERENCE;
	}
	
	int entity6 = EntRefToEntIndex(BallParticleRef);
	if(entity6 != INVALID_ENT_REFERENCE && IsValidEdict(entity6) && entity6 != 0)
	{
		AcceptEntityInput(entity6, "DestroyImmediately");
		AcceptEntityInput(entity6, "Kill");
		BallParticleRef = INVALID_ENT_REFERENCE;
	}
	
	int entity7 = EntRefToEntIndex(DropBallParticleRef);
	if(entity7 != INVALID_ENT_REFERENCE && IsValidEdict(entity7) && entity6 != 0)
	{
		AcceptEntityInput(entity7, "DestroyImmediately");
		AcceptEntityInput(entity7, "Kill");
		DropBallParticleRef = INVALID_ENT_REFERENCE;
	}
}

void DropBall(int client)
{
	if(!IsValidClient(client))
		return;
	
	// Call forward
	Call_StartForward(OnPlayerDropBall);
	Call_PushCell(client);
	Call_Finish();

	// Remove player ball model
	RemoveBall();

	// Stats
	if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
	{
		Stats[client].DROPBALL++;		
		
		if(btd_points_enabled)
		{
			Stats[client].POINTS -= itd_points_dropball;
			
			if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
				Stats[client].POINTS = itd_points_min;
				
			if(itd_points_dropball != 0)
				CPrintToChat(client, "%T", "Point Drop Ball", client, Stats[client].POINTS, itd_points_dropball);
		}
	}
	
	// Spawn a ball model
	// From simple ball plugin
	DropBallModel = CreateEntityByName("hegrenade_projectile");
	DispatchKeyValue(DropBallModel, "targetname", "TDBall");
	
	DispatchSpawn(DropBallModel);
	SetEntityModel(DropBallModel, BallModelPath);

	SetEntProp(DropBallModel, Prop_Send, "m_usSolidFlags", 0x0004 | 0x0008);
	SetEntPropFloat(DropBallModel, Prop_Data, "m_flModelScale", 0.6);
	
	DropBallRef = EntIndexToEntRef(DropBallModel);
	
	float origin[3];
	GetClientAbsOrigin(client, origin);
	
	//origin[2] -= 20.0;
	
	TeleportEntity(DropBallModel, origin, NULL_VECTOR, NULL_VECTOR);
	
	SDKHook(DropBallModel, SDKHook_StartTouch, OnStartTouch);
	
	// Create ball particle
	DropBallParticle = CreateEntityByName("info_particle_system");
	
	DispatchKeyValue(DropBallParticle, "start_active", "1");
	DispatchKeyValue(DropBallParticle, "effect_name", BallParticleEffect);
	DispatchSpawn(DropBallParticle);

	TeleportEntity(DropBallParticle, origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("!activator");	
	AcceptEntityInput(DropBallParticle, "SetParent", DropBallModel, DropBallParticle, 0);	
	ActivateEntity(DropBallParticle);
	AcceptEntityInput(DropBallParticle, "Start");
	
	DropBallParticleRef = EntIndexToEntRef(DropBallParticle);
	
	SetEdictFlags(DropBallParticle, GetEdictFlags(DropBallParticle)&(~FL_EDICT_ALWAYS));
	SDKHookEx(DropBallParticle, SDKHook_SetTransmit, Hook_SetTransmit);
	
	// Remove ball holder
	BallHolder = 0;
	
	// BallDropper Team
	// Prevent plugin error if ballholder disconnect
	BallDroperTeam = GetClientTeam(client);
	
	// Reset ball of no one get the ball in 10 sec
	hResetBallTimer = CreateTimer(ftd_reset, ResetBallTimer, client);
	
	// Play attack defence sound to other player
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i) && GetClientTeam(i) != SPEC)
		{
			if(GetClientTeam(client) == TR)	CPrintToChat(i, "%T", "Drop Ball T", i, client);
				
			else if(GetClientTeam(client) == CT)	CPrintToChat(i, "%T", "Drop Ball CT", i, client);
			
			// Nice Chance!
			if(GetClientTeam(i) != GetClientTeam(client))
			{
				hRDropBallText[i] = CreateTimer(0.1, RDropBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						EmitSoundToClient(i, "*/touchdown/red_fumbled.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/red_fumbled.mp3");
					}
					case 2:
					{
						EmitSoundToClient(i, "*/touchdown/red_fumbled1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/red_fumbled1.mp3");
					}
				}
			}
				
			// Lost the ball!
			else if(GetClientTeam(i) == GetClientTeam(client))
			{
				hDropBallText[i] = CreateTimer(0.1, DropBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
				switch(GetRandomInt(1,5))
				{
					case 1:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/blue_fumbled.mp3");
					}
					case 2:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/blue_fumbled1.mp3");
					}
					case 3:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/blue_fumbled2.mp3");
					}
					case 4:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/blue_fumbled3.mp3");
					}
					case 5:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/blue_fumbled4.mp3");
					}
				}
			}
		}
	}
}

public Action DropBallText(Handle tmr, any client)
{
	if(IsValidClient(client) && !IsFakeClient(client))	
		PrintHintText(client, "%T", "Team Drop", client);
}

public Action RDropBallText(Handle tmr, any client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
		PrintHintText(client, "%T", "Rival Team Drop", client);
}

void GoalBall(int client)
{
	// Call forward
	Call_StartForward(OnPlayerTouchDown);
	Call_PushCell(client);
	Call_Finish();
	
	// Remove player ball model
	AcceptEntityInput(PlayerBallModel, "Kill");
	
	// Remove player ball aura
	if(GetClientTeam(client) == TR)
		AcceptEntityInput(TParticle, "Kill");
	
	else if(GetClientTeam(client) == CT)
		AcceptEntityInput(CTParticle, "Kill");
		
	// Give player 1 MVP star
	CS_SetMVPCount(client, CS_GetMVPCount(client) + 1);
	
	// Stats
	if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
	{
		Stats[client].TOUCHDOWN++;	
		
		if(btd_points_enabled)
		{
			Stats[client].POINTS += itd_points_td;
		
			if(itd_points_td != 0)
				CPrintToChat(client, "%T", "Point Touchdown", client, Stats[client].POINTS, itd_points_td);
		}
	}
	
	BallHolder = 0;
	BallDroperTeam = 0;
	Touchdowner = client;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i)) 
		{
			if(!IsFakeClient(client)) 
			{
				if(hAcquiredBallText[i] != INVALID_HANDLE)
				{
					KillTimer(hAcquiredBallText[i]);
				}
				hAcquiredBallText[i] = INVALID_HANDLE;
		
				if(hRAcquiredBallText[i] != INVALID_HANDLE)
				{
					KillTimer(hRAcquiredBallText[i]);
				}
				hRAcquiredBallText[i] = INVALID_HANDLE;
			}
			
			// Freeze all player except player who touchdown like S4
			if(GetClientTeam(i) != SPEC && i != client)
				SetEntityMoveType(i, MOVETYPE_NONE);
		}
	}
}

// Terminate round from boomix's capture the flag
void RoundEnd_OnRoundStart()
{
	b_JustEnded = false;
	g_roundStartedTime = GetTime();
}

public void OnGameFrame()
{
	RoundEnd_OnGameFrame();
	
	if(GameRules_GetProp("m_bWarmupPeriod") == 1)
		bWarmUp = true;

	else bWarmUp = false;
}

void RoundEnd_OnGameFrame()
{
	if(GetTotalRoundTime() == GetCurrentRoundTime())
	{
		if(!b_JustEnded)
		{
			b_JustEnded = true;
			CreateTimer(1.0, JustEndedFalse);
		}
	}
}

public int GetCurrentRoundTime() 
{
	int freezeTime = mp_freezetime.IntValue;
	return (GetTime() - g_roundStartedTime) - freezeTime;
}

public Action JustEndedFalse(Handle tmr, any client)
{
	if(GetClientCount(true) > 0)
		OnTeamWin(CS_TEAM_NONE);
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	int Winner = GetEventInt(event, "winner");
	
	if(hRoundCountdown != INVALID_HANDLE)
	{
		KillTimer(hRoundCountdown);
	}
	hRoundCountdown = INVALID_HANDLE;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			if(hAcquiredBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hAcquiredBallText[i]);
			}
			hAcquiredBallText[i] = INVALID_HANDLE;
	
			if(hRAcquiredBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRAcquiredBallText[i]);
			}
			hRAcquiredBallText[i] = INVALID_HANDLE;
		
			if(hDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hDropBallText[i]);
			}
			hDropBallText[i] = INVALID_HANDLE;
	
			if(hRDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRDropBallText[i]);
			}
			hRDropBallText[i] = INVALID_HANDLE;
			
			if(btd_stats_enabled || btd_points_enabled)	SaveClientStats(i);
		}
	}
	
	char sMessage[256] = "";
	GetEventString(event, "message",sMessage, sizeof(sMessage));
	
	// Round Draw
	// play timeover sound
	if(StrEqual(sMessage,"#SFUI_Notice_Round_Draw", false))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i)) 
			{
				if(!IsFakeClient(i))
				{
					PrintHintText(i, "%T", "Time Is Up Hint", i);
					CPrintToChat(i, "%T", "Time Is Up", i);
					EmitSoundToClient(i, "*/touchdown/inter_timeover.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
				}

				// Freeze player if time is up
				if(GetClientTeam(i) != SPEC)	SetEntityMoveType(i, MOVETYPE_NONE);
			}
		}
	}
	// Round NOT draw
	// Emit sound to spec
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				if (Winner == TR && GetClientTeam(i) == TR)
				{
					SetClientOverlay(i, "touchdown/touchdown_green");
					CreateTimer(8.0, DeleteOverlay, i);

					// TR lead 1 point
					if(score_t - score_ct == 1)
					{
						switch(GetRandomInt(1,2))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_take_the_lead.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_take_the_lead1.mp3");
							}
						}
					}
					
					// TR lead more than 1 point or draw
					else
					{
						switch(GetRandomInt(1,5))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores2.mp3");
							}
							case 4:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores3.mp3");
							}
							case 5:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores4.mp3");
							}
						}
					}
				}
				
				// TR win this round, play sound & overlay to CT
				else if (Winner == TR && GetClientTeam(i) == CT) 
				{
					SetClientOverlay(i, "touchdown/touchdown_red");
					CreateTimer(8.0, DeleteOverlay, i);
					
					// TR lead 1 point
					if(score_t - score_ct == 1)
					{
						//ClientCommand(i, "play *touchdown/red_team_take_the_lead.mp3");
						EmitSoundToClient(i, "*/touchdown/red_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/red_team_take_the_lead.mp3");
					}
					else
					{
						switch(GetRandomInt(1,3))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/red_team_scores.mp3");
								EmitSoundToClient(i, "*/touchdown/red_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/red_team_scores.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/red_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/red_team_scores1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/red_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/red_team_scores2.mp3");
							}
						}
					}
				}
				
				// CT win this round, play sound & overlay to CT
				else if (Winner == CT && GetClientTeam(i) == CT) 
				{
					SetClientOverlay(i, "touchdown/touchdown_green");
					CreateTimer(8.0, DeleteOverlay, i);
					
					// CT lead 1 point
					if(score_ct - score_t == 1)
					{
						switch(GetRandomInt(1,2))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_take_the_lead.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_take_the_lead1.mp3");
							}
						}
					}
					else
					{
						switch(GetRandomInt(1,5))
						{
							case 1:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores2.mp3");
							}
							case 4:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores3.mp3");
							}
							case 5:
							{
								EmitSoundToClient(i, "*/touchdown/blue_team_scores4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/blue_team_scores4.mp3");
							}
						}
					}
				}
				
				// CT win this round, play sound & overlay to TR
				else if (Winner == CT && GetClientTeam(i) == TR) 
				{
					SetClientOverlay(i, "touchdown/touchdown_red");
					CreateTimer(8.0, DeleteOverlay, i);
					
					// CT lead 1 point
					if(score_ct - score_t == 1)
					{
						EmitSoundToClient(i, "*/touchdown/red_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
						EmitSoundToSpec(i, "*/touchdown/red_team_take_the_lead.mp3");
					}
					else
					{
						switch(GetRandomInt(1,3))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/red_team_scores.mp3");
								EmitSoundToClient(i, "*/touchdown/red_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/red_team_scores.mp3");
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/red_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/red_team_scores1.mp3");
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/red_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
								EmitSoundToSpec(i, "*/touchdown/red_team_scores2.mp3");
							}
						}
					}
				}
			}
		}
	}
	
	// Next round countdown
	Nextroundtime = 15;
	hNextRoundCountdown = CreateTimer(1.0, NextRoundCountdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

bool SetClientOverlay(int client, char[] strOverlay)
{
	if (IsValidClient(client))
	{
		int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);	
		ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
		return true;
	}
	return false;
}

public Action DeleteOverlay(Handle tmr, any client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		SetClientOverlay(client, "");
	}
	return Plugin_Handled;
}
	
/* Critical
public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int damage = GetEventInt(event, "dmg_health");

	if (damage > 50) 
	{
		//ClientCommand(attacker, "play *touchdown/critical.mp3");
		EmitSoundToClient(attacker, "* /touchdown/critical.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
	}
}
*/

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int assister = GetClientOfUserId(GetEventInt(event, "assister"));
	
	// We don't need to respawn player in warmup.
	if(!bWarmUp)
	{
		// PrintText
		PrintHintText(client, "%T", "Respawn", client, ftd_respawn);
		CPrintToChat(client, "%T", "Respawn 2", client, ftd_respawn);
	
		// Respawn Victim
		CreateTimer(ftd_respawn, Respawn_Player, client);
	}
	
	// Play death sound and dissolve effect
	if(IsValidClient(client))
	{	
		// Sound
		EmitSoundToClient(client, "*/touchdown/player_dead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
		EmitSoundToSpec(client, "*/touchdown/player_dead.mp3");
		
		// EU S4 doesn't really have "voice", only sound effect wtf.
		switch(GetRandomInt(1,4))
		{
			case 1:
			{
				EmitSoundToClient(client, "*/touchdown/_eu_voice_man_dead_blow.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
				EmitSoundToSpec(client, "*/touchdown/_eu_voice_man_dead_blow.mp3");
			}
			case 2:
			{
				EmitSoundToClient(client, "*/touchdown/_eu_voice_man_dead_hard.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
				EmitSoundToSpec(client, "*/touchdown/_eu_voice_man_dead_hard.mp3");
			}
			case 3:
			{
				EmitSoundToClient(client, "*/touchdown/_eu_voice_man_dead_normal.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
				EmitSoundToSpec(client, "*/touchdown/_eu_voice_man_dead_normal.mp3");
			}
			case 4:
			{
				EmitSoundToClient(client, "*/touchdown/_eu_voice_man_dead_shock.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[client]);
				EmitSoundToSpec(client, "*/touchdown/_eu_voice_man_dead_shock.mp3");
			}
		}
		
		// Dissolve
		// https://forums.alliedmods.net/showthread.php?t=71084
		CreateTimer(0.2, Dissolve, client);
		
		// Not suicide
		if(client != attacker && IsValidClient(attacker) && btd_quake_enabled)
		{
			// Play kill sound
			switch(GetRandomInt(1,8))
			{
				case 1:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill1.mp3");
				}
				case 2:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill2.mp3");
				}
				case 3:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill3.mp3");
				}
				case 4:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill4.mp3");
				}
				case 5:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill5.mp3");
				}
				case 6:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill6.mp3");
				}
				case 7:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill7.mp3");
				}
				case 8:
				{
					EmitSoundToClient(attacker, "*/touchdown/kill8.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[attacker]);
					EmitSoundToSpec(attacker, "*/touchdown/kill8.mp3");
				}
			}
		}
	}
	
	// someone have the ball
	if (BallHolder != 0)
	{
		// player suicide
		if(BallHolder != client && (client == attacker || !IsValidClient(attacker)))
		{
			// stats enable
			if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
			{
				Stats[client].DEATHS++;
				
				if(IsValidClient(assister))
					Stats[assister].ASSISTS++;	
				
				if(btd_points_enabled)
				{
					Stats[client].POINTS -= itd_points_death;	
					
					if(IsValidClient(assister))
						Stats[assister].POINTS += itd_points_assist;
					
					if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
						Stats[client].POINTS = itd_points_min;
					
					if(itd_points_assist != 0 && IsValidClient(assister))
						CPrintToChat(assister, "%T", "Point Assist", assister, Stats[assister].POINTS, itd_points_assist, attacker, client);
			
					if(itd_points_death != 0)
						CPrintToChat(client, "%T", "Point Suicide", client, Stats[client].POINTS, itd_points_death);	
				}						
			}
		}

		// ball holder suicide
		else if(BallHolder == client && (client == attacker || attacker == 0))
		{
			// stats enable
			if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
			{
				Stats[client].DEATHS++;
				
				if(IsValidClient(assister))
					Stats[assister].ASSISTS++;	
				
				if(btd_points_enabled)
				{
					Stats[client].POINTS -= itd_points_death;	
					
					if(IsValidClient(assister))
						Stats[assister].POINTS += itd_points_assist;

					if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
						Stats[client].POINTS = itd_points_min;
				
					if(itd_points_assist != 0 && IsValidClient(assister))
						CPrintToChat(assister, "%T", "Point Assist", assister, Stats[assister].POINTS, itd_points_assist, attacker, client);
			
					if(itd_points_death != 0)
						CPrintToChat(client, "%T", "Point Suicide", client, Stats[client].POINTS, itd_points_death);
				}
			}
				
			DropBall(client);
		
			Call_StartForward(OnPlayerKillBall);
			Call_PushCell(client);
			Call_PushCell(attacker);
			Call_Finish();
		
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i)) 
				{
					if(hAcquiredBallText[i] != INVALID_HANDLE)
					{
						KillTimer(hAcquiredBallText[i]);
					}
					hAcquiredBallText[i] = INVALID_HANDLE;
	
					if(hRAcquiredBallText[i] != INVALID_HANDLE)
					{
						KillTimer(hRAcquiredBallText[i]);
					}
					hRAcquiredBallText[i] = INVALID_HANDLE;
				}
			}
		}
			
		// kill ball holder, not ball holder suicide
		if(BallHolder == client && client != attacker && IsValidClient(attacker))
		{
			// stats enable
			if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
			{
				Stats[attacker].KILLS++;
				Stats[attacker].KILLBALL++;
				Stats[client].DEATHS++;	
				
				if(IsValidClient(assister))
					Stats[assister].ASSISTS++;	
					
				if(btd_points_enabled)
				{
					Stats[attacker].POINTS += itd_points_killball;
					Stats[client].POINTS -= itd_points_death;
				
					if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
						Stats[client].POINTS = itd_points_min;
				
					if(IsValidClient(assister))
						Stats[assister].POINTS += itd_points_assist;
				
					if(itd_points_assist != 0 && IsValidClient(assister))
						CPrintToChat(assister, "%T", "Point Assist", assister, Stats[assister].POINTS, itd_points_assist, attacker, client);
			
					if(itd_points_killball != 0)
						CPrintToChat(attacker, "%T", "Point Kill Ball", attacker, Stats[attacker].POINTS, itd_points_killball, client);
			
					if(itd_points_death != 0)
						CPrintToChat(client, "%T", "Point Death", client, Stats[client].POINTS, itd_points_death, attacker);
				}
			}
		
			DropBall(client);
		
			Call_StartForward(OnPlayerKillBall);
			Call_PushCell(client);
			Call_PushCell(attacker);
			Call_Finish();
				
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i)) 
				{
					if(hAcquiredBallText[i] != INVALID_HANDLE)
					{
						KillTimer(hAcquiredBallText[i]);
					}
					hAcquiredBallText[i] = INVALID_HANDLE;
	
					if(hRAcquiredBallText[i] != INVALID_HANDLE)
					{
						KillTimer(hRAcquiredBallText[i]);
					}
					hRAcquiredBallText[i] = INVALID_HANDLE;

					// Not suicide
					if(GetClientTeam(attacker) == TR)
						CPrintToChat(i, "%T", "Kill Ball T", i, attacker, client);
					
					else if(GetClientTeam(attacker) == CT)
						CPrintToChat(i, "%T", "Kill Ball CT", i, attacker, client);
				}
			}
		}

		// not kill ball holder and someone have the ball, so we have Attack / Defense bonus points
		else if(BallHolder != client && client != attacker && IsValidClient(attacker))
		{
			// stats enable
			if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
			{
				Stats[attacker].KILLS++;
				Stats[client].DEATHS++;	
				
				if(IsValidClient(assister))
					Stats[assister].ASSISTS++;	
					
				if(btd_points_enabled)
				{
					int score_dif_attacker = RoundToCeil(itd_points_kill * ftd_points_bonus);
					int score_dif_assister = RoundToCeil(itd_points_assist * ftd_points_bonus);
				
					Stats[attacker].POINTS += score_dif_attacker;
					Stats[client].POINTS -= itd_points_death;
				
					if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
						Stats[client].POINTS = itd_points_min;
				
					if(IsValidClient(assister))
						Stats[assister].POINTS += score_dif_assister;
			
					if(score_dif_assister != 0 && IsValidClient(assister))
						CPrintToChat(assister, "%T", "Point Assist", assister, Stats[assister].POINTS, score_dif_assister, attacker ,client);
				
					if(score_dif_attacker != 0)
						CPrintToChat(attacker, "%T", "Point Kill", attacker, Stats[attacker].POINTS, score_dif_attacker, client);

					if(itd_points_death != 0)
						CPrintToChat(client, "%T", "Point Death", client, Stats[client].POINTS, itd_points_death, attacker);
				}
			}
		}
	}
	
	// Nobody have the ball, no bonus
	else if (BallHolder == 0)
	{
		if(client != attacker && IsValidClient(attacker))
		{
			// stats enable
			if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
			{
				Stats[attacker].KILLS++;
				Stats[client].DEATHS++;
				
				if(IsValidClient(assister))
					Stats[assister].ASSISTS++;	
				
				if(btd_points_enabled)
				{
					Stats[attacker].POINTS += itd_points_kill;
					Stats[client].POINTS -= itd_points_death;
				
					if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
						Stats[client].POINTS = itd_points_min;
				
					if(IsValidClient(assister))
						Stats[assister].POINTS += itd_points_assist;
				
					if(itd_points_assist != 0 && IsValidClient(assister))
						CPrintToChat(assister, "%T", "Point Assist", assister, Stats[assister].POINTS, itd_points_assist, attacker, client);
				
					if(itd_points_kill != 0)
						CPrintToChat(attacker, "%T", "Point Kill", attacker, Stats[attacker].POINTS, itd_points_kill, client);
				
					if(itd_points_death != 0)
						CPrintToChat(client, "%T", "Point Death", client, Stats[client].POINTS, itd_points_death, attacker);
				}
			}
		}
		
		// player suicide
		if(client == attacker || attacker == 0)
		{
			// stats enable
			if(btd_stats_enabled && itd_stats_min <= GetCurrentPlayers())
			{
				Stats[client].DEATHS++;	
				
				if(IsValidClient(assister))
					Stats[assister].ASSISTS++;	
					
				if(btd_points_enabled)
				{
					Stats[client].POINTS -= itd_points_death;
				
					if(btd_points_min_enabled && Stats[client].POINTS < itd_points_min)
						Stats[client].POINTS = itd_points_min;
				
					if(IsValidClient(assister))
						Stats[assister].POINTS += itd_points_assist;
			
					if(itd_points_assist != 0 && IsValidClient(assister))
						CPrintToChat(assister, "%T", "Point Assist", assister, Stats[assister].POINTS, itd_points_assist, attacker, client);
			
					if(itd_points_death != 0)
						CPrintToChat(client, "%T", "Point Suicide", client, Stats[client].POINTS, itd_points_death);
				}
			}
		}
	}
}

public Action Respawn_Player(Handle tmr, any client)
{
	if(IsClientInGame(client) && !IsPlayerAlive(client) && (GetClientTeam(client) != SPEC))
	{
		CS_RespawnPlayer(client);
	}
}

public Action ResetBallTimer(Handle tmr, any client)
{
	ResetBall(true);
	hResetBallTimer = INVALID_HANDLE;
}

void SpawnBall(float pos[3])
{
	// Create ball model
	BallModel = CreateEntityByName("prop_dynamic_override");
		
	SetEntityModel(BallModel, BallModelPath);
	SetEntPropString(BallModel, Prop_Data, "m_iName", "TDBall");
	SetEntProp(BallModel, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(BallModel, Prop_Data, "m_nSolidType", 6);
	SetEntProp(BallModel, Prop_Send, "m_CollisionGroup", 1);
	SetEntPropFloat(BallModel, Prop_Send, "m_flModelScale", 0.6);
	SetEntityMoveType(BallModel, MOVETYPE_NOCLIP); 
	
	BallRef = EntIndexToEntRef(BallModel);

	DispatchSpawn(BallModel);
	
	float ballpos[3];
	ballpos[0] = pos[0];
	ballpos[1] = pos[1];
	ballpos[2] = pos[2];

	TeleportEntity(BallModel, ballpos, NULL_VECTOR, NULL_VECTOR);
	
	SDKHook(BallModel, SDKHook_StartTouch, OnStartTouch);
	
	// Create ball particle
	BallParticle = CreateEntityByName("info_particle_system");
	
	DispatchKeyValue(BallParticle, "start_active", "1");
	DispatchKeyValue(BallParticle, "effect_name", BallParticleEffect);
	DispatchSpawn(BallParticle);

	TeleportEntity(BallParticle, ballpos, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("!activator");	
	
	BallParticleRef = EntIndexToEntRef(BallParticle);
	
	ActivateEntity(BallParticle);
	AcceptEntityInput(BallParticle, "Start");
	
	SetEdictFlags(BallParticle, GetEdictFlags(BallParticle)&(~FL_EDICT_ALWAYS)); //to allow settransmit hooks
	SDKHookEx(BallParticle, SDKHook_SetTransmit, Hook_SetTransmit);
}

void ResetBall(bool spawn)
{
	// Remove all ball
	RemoveBall();
	
	Call_StartForward(OnBallReset);
	Call_Finish();
		
	// Reset Ball Holder
	BallHolder = 0;
	BallDroperTeam = 0;
	Touchdowner = 0;
	
	// Spawn Ball
	if(spawn)	SpawnBall(BallSpawnPoint);
	
	// Play reset sound
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			EmitSoundToClient(i, "*/touchdown/_eu_ball_reset.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
			
			// Remove hint text
			if(hAcquiredBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hAcquiredBallText[i]);
			}
			hAcquiredBallText[i] = INVALID_HANDLE;
	
			if(hRAcquiredBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRAcquiredBallText[i]);
			}
			hRAcquiredBallText[i] = INVALID_HANDLE;
		
			if(hDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hDropBallText[i]);
			}
			hDropBallText[i] = INVALID_HANDLE;
	
			if(hRDropBallText[i] != INVALID_HANDLE)
			{
				KillTimer(hRDropBallText[i]);
			}
			hRDropBallText[i] = INVALID_HANDLE;
			
			PrintHintText(i, "%T", "Reset Hint", i);
			CPrintToChat(i, "%T", "Reset", i);
		}
	}
}

public Action Command_ResetBall(int client,int args)
{
	if(hResetBallTimer != INVALID_HANDLE)
	{
		KillTimer(hResetBallTimer);
		hResetBallTimer = INVALID_HANDLE;
	}
	ResetBall(true);
	
	return Plugin_Handled;
}

stock bool IsValidClient(int client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}

public Action Command_Weapon(int client,int args)
{
	b_AutoGiveWeapons[client] = false;
	i_RandomWeapons[client] = 0;
	b_SelectedWeapon[client] = false;
	ShowMainMenu(client);
	return Plugin_Handled;
}

// Match End
public Action Event_WinPanelMatch(Handle event, const char[] name, bool dontBroadcast)
{
	CreateTimer(7.0, MatchEndSound);
	ResetTimer();
	i_mp_ignore_round_win_conditions = 0;
	mp_ignore_round_win_conditions.IntValue = 0;
}

public Action MatchEndSound(Handle tmr)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			// TR Win
			if (score_t > score_ct)
			{
				// Stop bgm
				StopBGM(i);
			
				// play win sound to TR
				if (GetClientTeam(i) == TR)
				{
					PrintHintText(i, "%T", "Win Hint", i);
					CPrintToChat(i, "%T", "Win", i);
					
					switch(GetRandomInt(1, 2))
					{
						case 1:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_have_won_the_match.mp3");
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_have_won_the_match1.mp3");
						}
					}
				}
				// play lose sound to CT
				else if (GetClientTeam(i) == CT)
				{
					PrintHintText(i, "%T", "Lose Hint", i);
					CPrintToChat(i, "%T", "Lose", i);
					
					switch(GetRandomInt(1, 2))
					{
						case 1:
						{
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_lost_the_match.mp3");
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_lost_the_match1.mp3");
						}
					}
				}
			}
			// CT Win
			else if (score_t < score_ct)
			{
				// Stop bgm
				StopBGM(i);
				
				// play win sound to CT
				if (GetClientTeam(i) == CT)
				{
					PrintHintText(i, "%T", "Win Hint", i);
					CPrintToChat(i, "%T", "Win", i);
					
					switch(GetRandomInt(1, 2))
					{
						case 1:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_have_won_the_match.mp3");
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_have_won_the_match1.mp3");
						}
					}
				}
				// play lose sound to TR
				else if (GetClientTeam(i) == TR)
				{
					PrintHintText(i, "%T", "Lose Hint", i);
					CPrintToChat(i, "%T", "Lose", i);
					
					switch(GetRandomInt(1, 2))
					{
						case 1:
						{
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_lost_the_match.mp3");
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_lost_the_match1.mp3");
						}
					}
				}
			}
			// Draw, S4 don't have draw sound so we play win sound
			else if (score_t == score_ct)
			{
				// Stop bgm
				StopBGM(i);
				
				PrintHintText(i, "%T", "Draw Hint", i);
				CPrintToChat(i, "%T", "Draw", i);
				
				if (GetClientTeam(i) == CT || GetClientTeam(i) == TR)
				{
					switch(GetRandomInt(1, 2))
					{
						case 1:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_have_won_the_match.mp3");
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
							EmitSoundToSpec(i, "*/touchdown/you_have_won_the_match1.mp3");
						}
					}
				}
			}
		}
	}
}

public void OnMapEnd()
{
	ResetTimer();
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason) 
{
	if(reason == CSRoundEnd_GameStart)
	{
		ResetTimer();
		RoundEnd = false;
		BallHolder = 0;
		BallDroperTeam = 0;
		Touchdowner = 0;
	}
	
	// PrintToChatAll("Round Terminated Reason: %d", reason);
}  

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client))
		return;
	
	if(!IsValidClient(client))
		return;
		
	if(BallHolder == client)
	{
		DropBall(client);
	}
	
	if (hBGMTimer[client] != INVALID_HANDLE)
	{
		KillTimer(hBGMTimer[client]);
	}
	hBGMTimer[client] = INVALID_HANDLE;
	
	if(hAcquiredBallText[client] != INVALID_HANDLE)
	{
		KillTimer(hAcquiredBallText[client]);
	}
	hAcquiredBallText[client] = INVALID_HANDLE;
	
	if(hRAcquiredBallText[client] != INVALID_HANDLE)
	{
		KillTimer(hRAcquiredBallText[client]);
	}
	hRAcquiredBallText[client] = INVALID_HANDLE;
		
	if(hDropBallText[client] != INVALID_HANDLE)
	{
		KillTimer(hDropBallText[client]);
	}
	hDropBallText[client] = INVALID_HANDLE;
	
	if(hRDropBallText[client] != INVALID_HANDLE)
	{
		KillTimer(hRDropBallText[client]);
	}
	hRDropBallText[client] = INVALID_HANDLE;
	
	// Client disconnect and the team has no player
	if(GetTeamClientCount(CT) == 0)
		g_spawned_ct = false;
		
	if(GetTeamClientCount(TR) == 0)
		g_spawned_ct = false;
	
	// both team no player
	if(GetTeamClientCount(CT) == 0 && GetTeamClientCount(TR) == 0)
	{
		i_mp_ignore_round_win_conditions = 0;
		mp_ignore_round_win_conditions.IntValue = 0;
	}
		
	// save stats
	if(btd_stats_enabled || btd_points_enabled)	SaveClientStats(client);
}

public Action Command_Vol(int client,int args)
{
	if (IsValidClient(client))
	{
		char arg[20];
		float volume;
		
		if (args < 1)
		{
			CPrintToChat(client, "%T", "Volume 1", client);
			return Plugin_Handled;
		}
			
		GetCmdArg(1, arg, sizeof(arg));
		volume = StringToFloat(arg);
		
		if (volume < 0.0 || volume > 1.0)
		{
			CPrintToChat(client, "%T", "Volume 1", client);
			return Plugin_Handled;
		}
		
		g_fvol[client] = StringToFloat(arg);
		CPrintToChat(client, "%T", "Volume 2", client, g_fvol[client]);
		
		SetClientCookie(client, clientVolCookie, arg);
		
		// Replay bgm
		// Stop playing bgm
		StopBGM(client);
		
		// Reset bgm timer
		if (hBGMTimer[client] != INVALID_HANDLE)
		{
			KillTimer(hBGMTimer[client]);
		}
		hBGMTimer[client] = INVALID_HANDLE;
		
		// Play bgm
		hBGMTimer[client] = CreateTimer(0.5, BGMTimer, client);
	}
	return Plugin_Handled;
}

public Action Command_Join(int client, const char[] command, int argc)
{
	char sJoining[8];
	GetCmdArg(1, sJoining, sizeof(sJoining));
	int iJoining = StringToInt(sJoining);

	if(BallHolder == client)
		DropBall(client);
	
	// Join spec
	if(iJoining == CS_TEAM_SPECTATOR)
	{
		// Unfreeze if player join spec after someone touchdown
		if(RoundEnd)
			SetEntityMoveType(client, MOVETYPE_WALK);
	}

	int iTeam = GetClientTeam(client);
	
	if(iJoining != iTeam && (iJoining == CS_TEAM_CT || iJoining == CS_TEAM_T))
	{
		// Restartgame when someone play alone and new player join
		// only 1 player and he join different team
		// joined CT, and TR = 0
		if(iJoining == CT && GetTeamClientCount(TR) == 0)
			g_spawned_t = false;
		
		// joined CT, and TR = 0
		if(iJoining == TR && GetTeamClientCount(CT) == 0)
			g_spawned_ct = false;
		
		// Respawn
		CS_RespawnPlayer(client);
		
		// Freeze if roundend
		CreateTimer(0.1, FreezeClient, client);
		
		// Someone is holding the ball
		if(BallHolder != 0)
		{
			if(GetClientTeam(BallHolder) == iJoining)
				hAcquiredBallText[client] = CreateTimer(0.1, AcquiredBallText, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
			else if(GetClientTeam(BallHolder) != iJoining)
				hRAcquiredBallText[client] = CreateTimer(0.1, RAcquiredBallText, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		
		// Someone dropped the ball
		if(BallDroperTeam != 0)
		{
			if(BallDroperTeam == iJoining)
				hDropBallText[client] = CreateTimer(0.1, DropBallText, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
			else if(BallDroperTeam != iJoining)
				hRDropBallText[client] = CreateTimer(0.1, RDropBallText, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	return Plugin_Continue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == td_respawn) 
	{
		ftd_respawn = td_respawn.FloatValue;
	}
	else if (convar == td_reset) 
	{
		ftd_reset = td_reset.FloatValue;
	}
	else if (convar == td_ballposition) 
	{
		itd_ballposition = td_ballposition.IntValue;
	}
	else if (convar == td_bgm_enabled) 
	{
		btd_bgm_enabled = td_bgm_enabled.BoolValue;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				// Stop playing bgm
				StopBGM(i);
				
				// Reset bgm timer
				if (hBGMTimer[i] != INVALID_HANDLE)
				{
					KillTimer(hBGMTimer[i]);
				}
				hBGMTimer[i] = INVALID_HANDLE;
				
				// Play bgm
				if(btd_bgm_enabled) hBGMTimer[i] = CreateTimer(0.5, BGMTimer, i);
			}
		}
	}
	else if (convar == td_quake_enabled) 
	{
		btd_quake_enabled = td_quake_enabled.BoolValue;
	}
	else if (convar == td_stats_enabled) 
	{
		btd_stats_enabled = td_stats_enabled.BoolValue;
	}
	else if (convar == td_stats_min) 
	{
		itd_stats_min = td_stats_min.IntValue;
	}
	else if (convar == td_points_enabled) 
	{
		btd_points_enabled = td_points_enabled.BoolValue;
	}
	else if (convar == td_points_td) 
	{
		itd_points_td = td_points_td.IntValue;
	}
	else if (convar == td_points_kill) 
	{
		itd_points_kill = td_points_kill.IntValue;
	}
	else if (convar == td_points_assist) 
	{
		itd_points_assist = td_points_assist.IntValue;
	}
	else if (convar == td_points_bonus) 
	{
		ftd_points_bonus = td_points_bonus.FloatValue;
	}
	else if (convar == td_points_death) 
	{
		itd_points_death = td_points_death.IntValue;
	}
	else if (convar == td_points_dropball) 
	{
		itd_points_dropball = td_points_dropball.IntValue;
	}
	else if (convar == td_points_killball) 
	{
		itd_points_killball = td_points_killball.IntValue;
	}
	else if (convar == td_points_pickball) 
	{
		itd_points_pickball = td_points_pickball.IntValue;
	}
	else if (convar == td_points_start) 
	{
		itd_points_start = td_points_start.IntValue;
	}
	else if (convar == td_points_min) 
	{
		itd_points_min = td_points_min.IntValue;
	}
	else if (convar == td_points_min_enabled) 
	{
		btd_points_min_enabled = td_points_min_enabled.BoolValue;
	}
	else if (convar == td_taser) 
	{
		btd_taser = td_taser.BoolValue;
	}
	else if (convar == td_healthshot) 
	{
		btd_healthshot = td_healthshot.BoolValue;
	}
	else if (convar == mp_freezetime)
	{
		mp_freezetime.IntValue = 0;
	}
	else if (convar == mp_weapons_allow_map_placed)
	{
		mp_weapons_allow_map_placed.IntValue = 0;
	}
	else if (convar == mp_death_drop_gun)
	{
		mp_death_drop_gun.IntValue = 0;
	}
	else if (convar == mp_playercashawards)
	{
		mp_playercashawards.IntValue = 0;
	}
	else if (convar == mp_teamcashawards)
	{
		mp_teamcashawards.IntValue = 0;
	}
	else if (convar == mp_free_armor)
	{
		mp_free_armor.IntValue = 2;
	}
	else if (convar == mp_match_restart_delay)
	{
		mp_match_restart_delay.IntValue = 20;
	}
	else if (convar == mp_win_panel_display_time)
	{
		mp_win_panel_display_time.IntValue = 7;
	}
	else if (convar == mp_ignore_round_win_conditions)
	{
		mp_ignore_round_win_conditions.IntValue = i_mp_ignore_round_win_conditions;
	}
}

public Action MsgHook_AdjustMoney(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init)
{
	char buffer[64];
	PbReadString(msg, "params", buffer, sizeof(buffer), 0);
	
	if (StrEqual(buffer, "#Player_Cash_Award_Killed_Enemy"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Win_Hostages_Rescue"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Win_Defuse_Bomb"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Win_Time"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Elim_Bomb"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Elim_Hostage"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_T_Win_Bomb"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Point_Award_Assist_Enemy_Plural"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Point_Award_Assist_Enemy"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Point_Award_Killed_Enemy_Plural"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Point_Award_Killed_Enemy"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Kill_Hostage"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Damage_Hostage"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Get_Killed"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Respawn"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Interact_Hostage"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Killed_Enemy"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Rescued_Hostage"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Bomb_Defused"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Bomb_Planted"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Killed_Enemy_Generic"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Killed_VIP"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_Kill_Teammate"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Win_Hostage_Rescue"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Loser_Bonus"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Loser_Zero"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Rescued_Hostage"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Hostage_Interaction"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Hostage_Alive"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Planted_Bomb_But_Defused"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_CT_VIP_Escaped"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_T_VIP_Killed"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_no_income"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Generic"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_Custom"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Team_Cash_Award_no_income_suicide"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_ExplainSuicide_YouGotCash"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_ExplainSuicide_TeammateGotCash"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_ExplainSuicide_EnemyGotCash"))
	{
		return Plugin_Handled;
	}
	if (StrEqual(buffer, "#Player_Cash_Award_ExplainSuicide_Spectators"))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
} 

// Also from simple ball plugin
public Action Event_SoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if(DropBallModel == entity && StrEqual(sample, "~)weapons/hegrenade/he_bounce-1.wav"))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
				EmitSoundToClient(i, "*/touchdown/pokeball_bounce.mp3", entity, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[i]);
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

// Match End
public Action Event_HalfTime(Handle event, const char[] name, bool dontBroadcast)
{
	// Switch score when next round start
	Switch = true;
}

// Block player use "e" to pick up weapon.
public Action OnWeaponCanUse(int client, int weapon) 
{
		if(GetClientButtons(client) & IN_USE)	return Plugin_Handled; 
		
		return Plugin_Continue; 
}

// Block player drop weapon.
public Action OnWeaponDrop(int client, int weapon) 
{
		if(GetClientButtons(client) & IN_USE)	return Plugin_Handled; 
		
		return Plugin_Continue; 
}  


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!IsValidClient(client))	return Plugin_Continue;

	// https://forums.alliedmods.net/showpost.php?p=2514392&postcount=2
	if(RoundEnd && client!= Touchdowner && buttons & IN_ATTACK)
	{
		buttons &= ~IN_ATTACK;
		return Plugin_Changed;
	}
		
	if(RoundEnd && client!= Touchdowner && buttons & IN_ATTACK2)
	{
		buttons &= ~IN_ATTACK2;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action FreezeClient(Handle tmr, any client)
{
	if (IsValidClient(client) && RoundEnd)
		SetEntityMoveType(client, MOVETYPE_NONE);
}

public void Event_MatchRestart(Handle event, const char[] name, bool dontBroadcast) 
{
	// reset flags which event will use
	g_spawned_t = false;
	g_spawned_ct = false;
}

public int GetCurrentPlayers() 
{
	int count;
	for (int i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i) && !IsFakeClient(i)) 
		{
			count++;
		}
	}
	return count;
}

public void OnSQLConnect(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		SetFailState("(OnSQLConnect) Can't connect to mysql");
		return;
	}
	
	if (ddb != null)		
	{	
		delete hndl;		
		return;		
	}

	ddb = view_as<Database>(CloneHandle(hndl));
	
	CreateTable();
}

void CreateTable()
{
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), 
	"CREATE TABLE IF NOT EXISTS `%s`  \
	( id INT NOT NULL AUTO_INCREMENT ,  \
	steamid VARCHAR(32) NOT NULL ,  \
	name VARCHAR(64) NOT NULL ,  \
	points INT NOT NULL ,  \
	kills INT NOT NULL ,  \
	deaths INT NOT NULL ,  \
	assists INT NOT NULL ,  \
	touchdown INT NOT NULL ,  \
	getball INT NOT NULL ,  \
	dropball INT NOT NULL ,  \
	killball INT NOT NULL ,  \
	PRIMARY KEY (id))  \
	ENGINE = InnoDB;", std_stats_table_name);
	
	ddb.Query(SQL_CreateTable, sQuery);
}

public void SQL_CreateTable(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_CreateTable) Fail at Query: %s", error);
		return;
	}
	delete results;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i))
		{
			LoadClientStats(i);
		}
	}
}

void LoadClientStats(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
	
	char sCommunityID[32];
	SteamWorks_GetClientSteamID(client, sCommunityID, sizeof(sCommunityID));
	if(StrEqual("STEAM_ID_STOP_IGNORING_RETVALS", sCommunityID))
	{
		LogError("Auth failed for client index %d", client);
		return;
	}
	
	char LoadQuery[512];
	Format(LoadQuery, sizeof(LoadQuery), "SELECT * FROM `%s` WHERE steamid = '%s'", std_stats_table_name, sCommunityID);
	
	ddb.Query(SQL_LoadClientStats, LoadQuery, GetClientUserId(client));
}

public void SQL_LoadClientStats(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	
	if (!IsValidClient(client) || IsFakeClient(client))
		return;
	
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_LoadClientStats) Fail at Query: %s", error);
		return;
	}
	else
	{
		// New player
		if(!results.HasResults || !results.FetchRow())
		{
			char sCommunityID[32];
			SteamWorks_GetClientSteamID(client, sCommunityID, sizeof(sCommunityID));
			if(StrEqual("STEAM_ID_STOP_IGNORING_RETVALS", sCommunityID))
			{
				LogError("Auth failed for client index %d", client);
				return;
			}
			
			char InsertQuery[512];
			Format(InsertQuery, sizeof(InsertQuery), "INSERT INTO `%s` VALUES(NULL,'%s','%N','%d','0','0','0','0','0','0','0');", std_stats_table_name, sCommunityID, client, itd_points_start);
			ddb.Query(SQL_InsertCallback, InsertQuery, GetClientUserId(client));
		}
		
		else
		{
			Stats[client].POINTS = results.FetchInt(3);
			Stats[client].KILLS = results.FetchInt(4);
			Stats[client].DEATHS = results.FetchInt(5);
			Stats[client].ASSISTS = results.FetchInt(6);
			Stats[client].TOUCHDOWN = results.FetchInt(7);
			Stats[client].GETBALL = results.FetchInt(8);
			Stats[client].DROPBALL = results.FetchInt(9);
			Stats[client].KILLBALL = results.FetchInt(10);
		}
	}
}

public void SQL_InsertCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("SQL_InsertCallback) Fail at Query: %s", error);
		return;
	}
}

void SaveClientStats(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client)) 
		return;
	
	char sCommunityID[32];
	SteamWorks_GetClientSteamID(client, sCommunityID, sizeof(sCommunityID));
	if(StrEqual("STEAM_ID_STOP_IGNORING_RETVALS", sCommunityID))
	{
		LogError("Auth failed for client index %d", client);
		return;
	}
			
	char SaveQuery[512];
	Format(SaveQuery, sizeof(SaveQuery),
	"UPDATE `%s` SET name = '%N', points = '%i', kills = '%i', deaths='%i', assists='%i', touchdown='%i', getball='%i', dropball='%i',killball='%i' WHERE steamid = '%s';",
	std_stats_table_name,
	client,
	Stats[client].POINTS,
	Stats[client].KILLS,
	Stats[client].DEATHS,
	Stats[client].ASSISTS,
	Stats[client].TOUCHDOWN,
	Stats[client].GETBALL,
	Stats[client].DROPBALL,
	Stats[client].KILLBALL,
	sCommunityID);
	
	ddb.Query(SQL_SaveCallback, SaveQuery, GetClientUserId(client))
}

public void SQL_SaveCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_SaveClientStats) Fail at Query: %s", error);
		return;
	}
}

public void OnPluginEnd() 
{
	if(btd_stats_enabled || btd_points_enabled)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				SaveClientStats(i);
			}
		}
	}
}

public Action Command_Rank(int client,int args)
{
	if(!btd_stats_enabled || !IsValidClient(client) || IsFakeClient(client))
		return Plugin_Handled;
		
	char RankQuery[512];
	Format(RankQuery, sizeof(RankQuery), "SELECT * FROM `%s` ORDER BY points DESC", std_stats_table_name);
	
	ddb.Query(SQL_RankCallback, RankQuery, GetClientUserId(client));
	
	/*
	PrintToChat(client, "Point %d, Kill %d, Deaths %d, Assists %d, TD %d, getball %d, dropball %d, killball %d"
	, Stats[client].POINTS, Stats[client].KILLS, Stats[client].DEATHS, Stats[client].ASSISTS, Stats[client].TOUCHDOWN, 
	Stats[client].GETBALL, Stats[client].DROPBALL, Stats[client].KILLBALL);
	*/
	
	return Plugin_Handled;
}

public void SQL_RankCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_RankCallback) Fail at Query: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(data);
	int i;
	char Auth_receive[32];
	
	iTotalPlayers = SQL_GetRowCount(results);
	
	char sCommunityID[32];
	SteamWorks_GetClientSteamID(client, sCommunityID, sizeof(sCommunityID));
	if(StrEqual("STEAM_ID_STOP_IGNORING_RETVALS", sCommunityID))
	{
		LogError("Auth failed for client index %d", client);
		return;
	}
	
	// get player's rank
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(1, Auth_receive, sizeof(Auth_receive));
		
		if(StrEqual(Auth_receive, sCommunityID))
		{
			CPrintToChat(client, "%T", "Command Rank", client, i, iTotalPlayers, Stats[client].POINTS, Stats[client].KILLS, Stats[client].DEATHS, Stats[client].ASSISTS, Stats[client].TOUCHDOWN);
			break;
		}
	}
}

public Action Command_Stats(int client,int args)
{
	if(!btd_stats_enabled || !IsValidClient(client) || IsFakeClient(client))
		return Plugin_Handled;
		
	char RankQuery[512];
	Format(RankQuery, sizeof(RankQuery), "SELECT * FROM `%s` ORDER BY points DESC", std_stats_table_name);
	
	ddb.Query(SQL_StatsCallback, RankQuery, GetClientUserId(client));
	
	return Plugin_Handled;
}

public void SQL_StatsCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_StatsCallback) Fail at Query: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(data);
	int i;
	char Auth_receive[32];
	
	iTotalPlayers = SQL_GetRowCount(results);
	
	char sCommunityID[32];
	SteamWorks_GetClientSteamID(client, sCommunityID, sizeof(sCommunityID));
	if(StrEqual("STEAM_ID_STOP_IGNORING_RETVALS", sCommunityID))
	{
		LogError("Auth failed for client index %d", client);
		return;
	}
	
	// get player's rank
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(1, Auth_receive, sizeof(Auth_receive));
		
		if(StrEqual(Auth_receive, sCommunityID))
		{
			break;
		}
	}
	
	// Create Menu
	char temp[255];
	char text[512];
	
	Menu statsmenu = new Menu(StatsMenu_Handler);
	SetMenuPagination(statsmenu, 3);
	
	char title[64];
	Format(title, sizeof(title), "%T \n \n", "Touchdown Stats", client, client);
	statsmenu.SetTitle(title);
	
	Format(temp, sizeof(temp), "%T \n", "Basic Stats", client);
	StrCat(text, sizeof(text), temp);
	Format(temp, sizeof(temp), "%T \n \n", "Stats 1", client, Stats[client].POINTS, i, iTotalPlayers);
	StrCat(text, sizeof(text), temp);
	statsmenu.AddItem("", text);
	text="";
	
	Format(temp, sizeof(temp), "%T \n", "Kill Stats", client);
	StrCat(text, sizeof(text), temp);
	float kills = IntToFloat(Stats[client].KILLS);
	int ideaths = Stats[client].DEATHS;
	int deaths;
	if(ideaths == 0)
		deaths = 1;
	else deaths = ideaths;
	Format(temp, sizeof(temp), "%T \n \n", "Stats 2", client, Stats[client].KILLS, Stats[client].DEATHS, Stats[client].ASSISTS, kills/deaths);
	StrCat(text, sizeof(text), temp);
	statsmenu.AddItem("", text);
	text="";
	
	Format(temp, sizeof(temp), "%T \n", "Ball Stats", client);
	StrCat(text, sizeof(text), temp);
	Format(temp, sizeof(temp), "%T \n \n", "Stats 3", client, Stats[client].TOUCHDOWN, Stats[client].DROPBALL, Stats[client].GETBALL, Stats[client].KILLBALL);
	StrCat(text, sizeof(text), temp);
	statsmenu.AddItem("", text);
	text="";
	
	statsmenu.Display(client, MENU_TIME_FOREVER);
}

public int StatsMenu_Handler(Menu menu, MenuAction action, int client,int param)
{
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

public float IntToFloat(int integer)
{
	char s[300];
	IntToString(integer,s,sizeof(s));
	return StringToFloat(s);
}

public Action Command_Top(int client,int args)
{
	if(!btd_stats_enabled || !IsValidClient(client) || IsFakeClient(client))
		return Plugin_Handled;
	
	// Create Menu
	Menu TopMenu = new Menu(TopMenu_Handler);
	
	char TopMenutitle[512];
	Format(TopMenutitle, sizeof(TopMenutitle), "%T", "Top Menu Title", client);
	TopMenu.SetTitle(TopMenutitle);
		
	// Add No MVP
	char points[512];
	Format(points, sizeof(points), "%T", "Top 10 Points", client);
	TopMenu.AddItem("points", points);
	
	char td[512];
	Format(td, sizeof(td), "%T", "Top 10 Touchdown", client);
	TopMenu.AddItem("touchdown", td);
	
	char kills[512];
	Format(kills, sizeof(kills), "%T", "Top 10 Kills", client);
	TopMenu.AddItem("kills", kills);
	
	char deaths[512];
	Format(deaths, sizeof(deaths), "%T", "Top 10 Deaths", client);
	TopMenu.AddItem("deaths", deaths);
	
	char assists[512];
	Format(assists, sizeof(assists), "%T", "Top 10 Assists", client);
	TopMenu.AddItem("assists", assists);
	
	char killball[512];
	Format(killball, sizeof(killball), "%T", "Top 10 Killball", client);
	TopMenu.AddItem("killball", killball);
	
	char getball[512];
	Format(getball, sizeof(getball), "%T", "Top 10 Getball", client);
	TopMenu.AddItem("getball", getball);
	
	char dropball[512];
	Format(dropball, sizeof(dropball), "%T", "Top 10 Dropball", client);
	TopMenu.AddItem("dropball", dropball);

	TopMenu.Display(client, MENU_TIME_FOREVER);
		
	return Plugin_Handled;
}

public int TopMenu_Handler(Menu menu, MenuAction action, int client,int param)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menuitem[10];
			menu.GetItem(param, menuitem, sizeof(menuitem));
			
			if(StrEqual(menuitem, "points"))	ShowTopPoints(client);
	
			else if(StrEqual(menuitem, "touchdown"))	ShowTopTouchdown(client);
				
			else if(StrEqual(menuitem, "kills"))	ShowTopKills(client);
	
			else if(StrEqual(menuitem, "deaths"))	ShowTopDeaths(client);
				
			else if(StrEqual(menuitem, "assists"))	ShowTopAssists(client);
				
			else if(StrEqual(menuitem, "killball"))	ShowTopKillball(client);
				
			else if(StrEqual(menuitem, "getball"))	ShowTopGetball(client);
				
			else if(StrEqual(menuitem, "dropball"))	ShowTopDropball(client);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void ShowTopPoints(int client)
{
	char TopPointsQuery[512];
	Format(TopPointsQuery, sizeof(TopPointsQuery), "SELECT * FROM `%s` ORDER BY points DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopPointsCallback, TopPointsQuery, GetClientUserId(client));
}

public void SQL_TopPointsCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopPointsCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopPointsmenu = new Menu(TopPoints_MenuHandler);
	TopPointsmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Points Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Points", client, i, name, results.FetchInt(3));
		StrCat(text, sizeof(text), temp);
	}
	
	TopPointsmenu.AddItem("", text);
	TopPointsmenu.ExitButton = true;
	TopPointsmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopPoints_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopTouchdown(int client)
{
	char TopTouchdownQuery[512];
	Format(TopTouchdownQuery, sizeof(TopTouchdownQuery), "SELECT * FROM `%s` ORDER BY touchdown DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopTouchdownCallback, TopTouchdownQuery, GetClientUserId(client));
}

public void SQL_TopTouchdownCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopTouchdownCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopTouchdownmenu = new Menu(TopTouchdown_MenuHandler);
	TopTouchdownmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Touchdown Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Touchdown", client, i, name, results.FetchInt(7));
		StrCat(text, sizeof(text), temp);
	}
	
	TopTouchdownmenu.AddItem("", text);
	TopTouchdownmenu.ExitButton = true;
	TopTouchdownmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopTouchdown_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopKills(int client)
{
	char TopKillsQuery[512];
	Format(TopKillsQuery, sizeof(TopKillsQuery), "SELECT * FROM `%s` ORDER BY kills DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopKillsCallback, TopKillsQuery, GetClientUserId(client));
}

public void SQL_TopKillsCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopKillsCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopKillsmenu = new Menu(TopKills_MenuHandler);
	TopKillsmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Kills Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Kills", client, i, name, results.FetchInt(4));
		StrCat(text, sizeof(text), temp);
	}
	
	TopKillsmenu.AddItem("", text);
	TopKillsmenu.ExitButton = true;
	TopKillsmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopKills_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopDeaths(int client)
{
	char TopDeathsQuery[512];
	Format(TopDeathsQuery, sizeof(TopDeathsQuery), "SELECT * FROM `%s` ORDER BY deaths DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopDeathsCallback, TopDeathsQuery, GetClientUserId(client));
}

public void SQL_TopDeathsCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopDeathsCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopDeathsmenu = new Menu(TopDeaths_MenuHandler);
	TopDeathsmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Deaths Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Deaths", client, i, name, results.FetchInt(5));
		StrCat(text, sizeof(text), temp);
	}
	
	TopDeathsmenu.AddItem("", text);
	TopDeathsmenu.ExitButton = true;
	TopDeathsmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopDeaths_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopAssists(int client)
{
	char TopAssistsQuery[512];
	Format(TopAssistsQuery, sizeof(TopAssistsQuery), "SELECT * FROM `%s` ORDER BY assists DESC LIMIT 10", std_stats_table_name);

	ddb.Query(SQL_TopAssistsCallback, TopAssistsQuery, GetClientUserId(client));
}

public void SQL_TopAssistsCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopAssistsCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopAssistsmenu = new Menu(TopAssists_MenuHandler);
	TopAssistsmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Assists Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Assists", client, i, name, results.FetchInt(6));
		StrCat(text, sizeof(text), temp);
	}
	
	TopAssistsmenu.AddItem("", text);
	TopAssistsmenu.ExitButton = true;
	TopAssistsmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopAssists_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopKillball(int client)
{
	char TopKillballQuery[512];
	Format(TopKillballQuery, sizeof(TopKillballQuery), "SELECT * FROM `%s` ORDER BY killball DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopKillballCallback, TopKillballQuery, GetClientUserId(client));
}

public void SQL_TopKillballCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopKillballCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopKillballmenu = new Menu(TopKillball_MenuHandler);
	TopKillballmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Killball Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Killball", client, i, name, results.FetchInt(10));
		StrCat(text, sizeof(text), temp);
	}
	
	TopKillballmenu.AddItem("", text);
	TopKillballmenu.ExitButton = true;
	TopKillballmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopKillball_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopDropball(int client)
{
	char TopDropballQuery[512];
	Format(TopDropballQuery, sizeof(TopDropballQuery), "SELECT * FROM `%s` ORDER BY dropball DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopDropballCallback, TopDropballQuery, GetClientUserId(client));
}

public void SQL_TopDropballCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopDropballCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopDropballmenu = new Menu(TopDropball_MenuHandler);
	TopDropballmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Dropball Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Dropball", client, i, name, results.FetchInt(9));
		StrCat(text, sizeof(text), temp);
	}
	
	TopDropballmenu.AddItem("", text);
	TopDropballmenu.ExitButton = true;
	TopDropballmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopDropball_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

void ShowTopGetball(int client)
{
	char TopGetballQuery[512];
	Format(TopGetballQuery, sizeof(TopGetballQuery), "SELECT * FROM `%s` ORDER BY getball DESC LIMIT 10", std_stats_table_name);
	
	ddb.Query(SQL_TopGetballCallback, TopGetballQuery, GetClientUserId(client));
}

public void SQL_TopGetballCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || strlen(error) > 0)
	{
		SetFailState("(SQL_TopGetballCallback) Fail at Query: %s", error);
		return;
	}
	
	int i;
	int client = GetClientOfUserId(data);
	char name[255], temp[255], text[512];
	
	Menu TopGetballmenu = new Menu(TopGetball_MenuHandler);
	TopGetballmenu.SetTitle("");
	
	Format(temp, sizeof(temp), "%T \n \n", "Top Getball Title", client);
	StrCat(text, sizeof(text), temp);
	
	while(results.HasResults && results.FetchRow())
	{
		i++;
		results.FetchString(2, name, sizeof(name))
		Format(temp, sizeof(temp), "%T \n", "Show Top Getball", client, i, name, results.FetchInt(8));
		StrCat(text, sizeof(text), temp);
	}
	
	TopGetballmenu.AddItem("", text);
	TopGetballmenu.ExitButton = true;
	TopGetballmenu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

public int TopGetball_MenuHandler(Menu menu, MenuAction action, int client,int param)
{	
	if (action == MenuAction_End || action == MenuAction_Select)	delete menu;
}

// Dissolve
// https://forums.alliedmods.net/showthread.php?t=71084
public Action Dissolve(Handle timer, any client)
{
	if (!IsValidEntity(client))	return;
		
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (ragdoll < 0)	return;
		
	char dname[32];
	Format(dname, sizeof(dname), "dis_%d", client);
	
	int ent = CreateEntityByName("env_entity_dissolver");
	if (ent > 0)
	{
		DispatchKeyValue(ragdoll, "targetname", dname);
		DispatchKeyValue(ent, "dissolvetype", "2");
		DispatchKeyValue(ent, "target", dname);
		AcceptEntityInput(ent, "Dissolve");
		AcceptEntityInput(ent, "kill");
	} 
}

// Edit from nikooo777's cksurf
void EmitSoundToSpec(int client, char[] buffer)
{
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x) && !IsPlayerAlive(x))
		{
			int SpecMode = GetEntProp(x, Prop_Send, "m_iObserverMode");
			int Target = GetEntPropEnt(x, Prop_Send, "m_hObserverTarget");
			
			if (SpecMode == 4 && Target == client) // Firstperson
			{
				EmitSoundToClient(x, buffer, Target, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[x]);
			}
			else if (SpecMode == 5 && Target == client) // Thirdperson
			{
				EmitSoundToClient(x, buffer, x, SNDCHAN_STATIC, SNDLEVEL_NONE, _, g_fvol[x]);
			}
		}
	}
}

public Action Command_Edit(int client, int args)
{
	ShowEditMenu(client);
	return Plugin_Handled;
}

void ShowEditMenu(int client)
{
	Menu menu = new Menu(EditMenu_Handler);
	
	char title[64], temp[255];
	Format(title, sizeof(title), "%T \n \n", "Edit Menu Title", client, client);
	menu.SetTitle(title);
	
	Format(temp, sizeof(temp), "%T", "Spawn T Flag", client);
	menu.AddItem("spawnTGoalModel", temp);
	
	Format(temp, sizeof(temp), "%T", "Spawn CT Flag", client);
	menu.AddItem("spawnCTGoalModel", temp);
	
	Format(temp, sizeof(temp), "%T", "Spawn Ball", client);
	menu.AddItem("spawnball", temp);
	
	Format(temp, sizeof(temp), "%T", "Save Edit", client);
	menu.AddItem("saveedit", temp);
	
	menu.ExitButton = true;
	menu.Display(client, 30);
}

public int EditMenu_Handler(Menu menu, MenuAction action, int client,int param)
{
	if (action == MenuAction_Select)
	{
		char info[20];
		menu.GetItem(param, info, sizeof(info));
		
		float pos[3];
		float clientEye[3], clientAngle[3];
		GetClientEyePosition(client, clientEye);
		GetClientEyeAngles(client, clientAngle);
			
		TR_TraceRayFilter(clientEye, clientAngle, MASK_SOLID, RayType_Infinite, HitSelf, client);
		
		if (TR_DidHit(INVALID_HANDLE))	TR_GetEndPosition(pos);

		if (StrEqual(info, "spawnTGoalModel"))
		{
			SpawnTGoal(pos);
			TGoalSpawnPoint = pos;
			CPrintToChat(client, "%T", "Remember to save edit", client);
		}
		
		else if (StrEqual(info, "spawnCTGoalModel"))
		{
			SpawnCTGoal(pos);	
			CTGoalSpawnPoint = pos;
			CPrintToChat(client, "%T", "Remember to save edit", client);
		}
		
		else if (StrEqual(info, "spawnball"))
		{
			ResetBall(false);
			SpawnBall(pos);	
			BallSpawnPoint = pos;
			CPrintToChat(client, "%T", "Remember to save edit", client);
		}
		
		else if (StrEqual(info, "saveedit"))	SaveConfig(client);
		
		ShowEditMenu(client);
	}
}

public bool HitSelf(int entity, int contentsMask, any data)
{
	if (entity == data)	return false;
	return true;
}

void SaveConfig(int client)
{
	char Configfile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Configfile, sizeof(Configfile), "configs/kento_touchdown.cfg");
	
	if (!FileExists(Configfile))
	{
		SetFailState("Fatal error: Unable to open configuration file \"%s\"!", Configfile);
	}
	
	KeyValues kv = CreateKeyValues("TouchDown");
	kv.ImportFromFile(Configfile);
	
	char sMapName[128], sMapName2[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	
	// Does current map string contains a "workshop" prefix at a start?
	if (strncmp(sMapName, "workshop", 8) == 0)
	{
		Format(sMapName2, sizeof(sMapName2), sMapName[19]);
	}
	else
	{
		Format(sMapName2, sizeof(sMapName2), sMapName);
	}
	
	kv.JumpToKey(sMapName2, true);
	
	float pos[3];
	char spos[512];
	
	int entity;
	entity = EntRefToEntIndex(TGoalRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		Format(spos, sizeof(spos), "%f;%f;%f", pos[0], pos[1], pos[2]);
		kv.SetString("goal_t", spos);
	}

	entity = EntRefToEntIndex(CTGoalRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		Format(spos, sizeof(spos), "%f;%f;%f", pos[0], pos[1], pos[2]);
		kv.SetString("goal_ct", spos);
	}
	
	entity = EntRefToEntIndex(BallRef);
	if(entity != INVALID_ENT_REFERENCE && IsValidEdict(entity) && entity != 0)
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		Format(spos, sizeof(spos), "%f;%f;%f", pos[0], pos[1], pos[2]);
		kv.SetString("ball", spos);
	}
	
	//Put it inside config file
	kv.Rewind();
	kv.ExportToFile(Configfile);
	
	CPrintToChat(client, "%T", "Edit Saved", client);
	
	delete kv;
}

