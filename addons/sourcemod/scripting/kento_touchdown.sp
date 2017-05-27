// Change sm_slay team to freeze everyone? (like original S4) or use ForcePlayerSuicide
// Add Mysql stats
//
// Maybe we can add
// Jump Sound? jump_up.mp3
// Critical sound
//
// S4 TD WIKI
// http://s4league.wikia.com/wiki/Touchdown
//
/* Sounds
// count down
touchdown/_eu_1minute.mp3
touchdown/_eu_30second.mp3
touchdown/_eu_3minute.mp3
touchdown/_eu_5minute.mp3
touchdown/1.mp3
touchdown/2.mp3
touchdown/3.mp3
touchdown/4.mp3
touchdown/5.mp3
touchdown/6.mp3
touchdown/7.mp3
touchdown/8.mp3
touchdown/9.mp3
touchdown/10.mp3
touchdown/inter_timeover.mp3
touchdown/new_round_in.mp3
touchdown/new_round_in1.mp3
touchdown/next_round_in.mp3
touchdown/next_round_in1.mp3

// maybe we can use this
touchdown/attack_down.mp3
touchdown/10_winlose.mp3

// Ball drop
touchdown/blue_fumbled.mp3
touchdown/blue_fumbled1.mp3
touchdown/blue_fumbled2.mp3
touchdown/blue_fumbled3.mp3
touchdown/blue_fumbled4.mp3

// Ball drop enemy
touchdown/red_fumbled.mp3
touchdown/red_fumbled1.mp3

// Touch Down Win
touchdown/blue_team_scores.mp3
touchdown/blue_team_scores1.mp3
touchdown/blue_team_scores2.mp3
touchdown/blue_team_scores3.mp3
touchdown/blue_team_scores4.mp3

// Touch Down 1 point lead
touchdown/blue_team_take_the_lead.mp3
touchdown/blue_team_take_the_lead1.mp3

// Touch Down Lose
touchdown/red_team_scores.mp3
touchdown/red_team_scores1.mp3
touchdown/red_team_scores2.mp3
touchdown/red_team_take_the_lead.mp3

// Kill
touchdown/kill1.mp3
touchdown/kill2.mp3
touchdown/kill3.mp3
touchdown/kill4.mp3
touchdown/kill5.mp3
touchdown/kill6.mp3
touchdown/kill7.mp3
touchdown/kill8.mp3

// Round Start
touchdown/ready1.mp3
touchdown/ready2.mp3

// ATK & DEF
touchdown/you_are_attacking.mp3
touchdown/you_are_attacking1.mp3
touchdown/you_are_attacking2.mp3
touchdown/you_are_attacking3.mp3
touchdown/you_are_attacking4.mp3
touchdown/you_are_attacking5.mp3
touchdown/you_are_attacking6.mp3
touchdown/you_are_attacking7.mp3
touchdown/you_are_defending.mp3
touchdown/you_are_defending1.mp3
touchdown/you_are_defending2.mp3

// Match End
touchdown/you_have_won_the_match.mp3
touchdown/you_have_won_the_match1.mp3
touchdown/you_lost_the_match.mp3
touchdown/you_lost_the_match1.mp3

// misc
touchdown/_eu_ball_reset.mp3
touchdown/player_respawn.mp3

// Critical
touchdown/critical.mp3

// jump
touchdown/jump_up.mp3
*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <cstrike>
#include <kento_csgocolors>
#include <clientprefs>
#include <kento_touchdown>

#pragma newdecls required

// Teams
#define SPEC 1
#define TR 2
#define CT 3

enum Pos 
{
	Float:XPos, 
	Float:YPos, 
	Float:ZPos, 
}

// Model postion
int BallSpawnPoint[Pos];
int TGoalSpawnPoint[Pos];
int CTGoalSpawnPoint[Pos];

// Ball
int BallModel;
int BallHolder;
int PlayerBallModel;
int DropBallModel;

int BallDroperTeam;

// Particle
int TGoalParticle;
int CTGoalParticle;

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

bool RoundEnd;
bool Switch;

Handle hResetBallTimer = INVALID_HANDLE;

Handle hBGMTimer[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};

int Nextroundtime;
Handle hNextRoundCountdown = INVALID_HANDLE;

float roundtime;

Handle hRoundCountdown = INVALID_HANDLE;

Handle mp_restartgame = INVALID_HANDLE;

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
float ftd_respawn;
float ftd_reset;
int itd_ballposition;

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
char PrimaryWeapon[18][50] = {
    "weapon_m4a1", "weapon_m4a1_silencer", "weapon_ak47", "weapon_aug", "weapon_bizon", "weapon_famas", 
    "weapon_galilar", "weapon_mac10",
    "weapon_mag7", "weapon_mp7", "weapon_mp9", "weapon_nova", "weapon_p90", "weapon_sawedoff",
    "weapon_sg556", "weapon_ssg08", "weapon_ump45", "weapon_xm1014"
};

char SecondaryWeapon[10][50] =  { 
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
	
public Plugin myinfo =
{
	name = "[CS:GO] Touch Down",
	author = "Kento from Akami Studio",
	version = "1.0",
	description = "Gamemode from S4 League",
	url = "https://github.com/rogeraabbccdd/CSGO-Touchdown"
};

public void OnPluginStart() 
{
	RegAdminCmd("sm_resetball", Command_ResetBall, ADMFLAG_GENERIC, "Reset Ball");
	
	RegConsoleCmd("sm_guns", Command_Weapon, "Weapon Menu");
	
	// volume
	RegConsoleCmd("sm_vol", Command_Vol, "Volume");
	clientVolCookie = RegClientCookie("touchdown_vol", "Touchdown Client Volume", CookieAccess_Protected);

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
	//HookEvent("player_disconnect", Event_PlayerDisconnect);
	//HookEvent("round_freeze_end", Event_RoundFreezeEnd);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
	HookEvent("announce_phase_end", Event_HalfTime);
	
	AddNormalSoundHook(Event_SoundPlayed);
	
	HookUserMessage(GetUserMessageId("TextMsg"), MsgHook_AdjustMoney, true);
	
	mp_restartgame = FindConVar("mp_restartgame");
	if ( mp_restartgame != INVALID_HANDLE )
    {
		 HookConVarChange(mp_restartgame, Restart_Handler);
	}
	
	// Cvar
	td_respawn = CreateConVar("sm_touchdown_respawn",  "8.0", "Respawn Time.", FCVAR_NOTIFY, true, 0.0);
	td_reset = CreateConVar("sm_touchdown_reset",  "15.0", "How long to reset the ball if nobody takes the ball after ball drop.", FCVAR_NOTIFY, true, 0.0);
	td_ballposition = CreateConVar("sm_touchdown_ball_position",  "1", "Where to attach the ball when player get the ball? 0 = front, 1 = head", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	HookConVarChange(td_respawn, OnConVarChanged);
	HookConVarChange(td_reset, OnConVarChanged);
	HookConVarChange(td_ballposition, OnConVarChanged);
	
	ftd_respawn = GetConVarFloat(td_respawn);
	ftd_reset = GetConVarFloat(td_reset);
	itd_ballposition = GetConVarInt(td_ballposition);
	
	AutoExecConfig(true, "kento_touchdown");	
}

// Create natives and forwards
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Touchdown_GetBallHolder", Native_GetBallHolder);
	CreateNative("Touchdown_GetBallDropTeam", Native_GetBallDropTeam);
	CreateNative("Touchdown_IsClientBallHolder", Native_IsClientBallHolder);
	
	OnPlayerDropBall = CreateGlobalForward("Touchdown_OnPlayerDropBall", ET_Ignore, Param_Cell);
	OnBallReset = CreateGlobalForward("Touchdown_OnBallReset", ET_Ignore);
	OnPlayerGetBall = CreateGlobalForward("Touchdown_OnPlayerGetBall", ET_Ignore, Param_Cell);
	OnPlayerTouchDown = CreateGlobalForward("Touchdown_OnPlayerTouchDown", ET_Ignore, Param_Cell);
	OnPlayerKillBall = CreateGlobalForward("Touchdown_OnPlayerKillBall", ET_Ignore, Param_Cell, Param_Cell);
	
	return APLRes_Success;
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
    }
}

public void OnConfigsExecuted()
{
	LoadMapConfig(); 
}

void LoadMapConfig()
{
	char Configfile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Configfile, sizeof(Configfile), "configs/kento_touchdown.cfg");
	
	if (!FileExists(Configfile))
	{
		SetFailState("Fatal error: Unable to open generic configuration file \"%s\"!", Configfile);
	}
	
	Handle kv;
	kv = CreateKeyValues("TouchDown");
	
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	
	if (FileToKeyValues(kv, Configfile))
	{
		if (KvJumpToKey(kv, sMapName))
		{
			// Ball postion
			char ball[512];
			char ballDatas[3][32];
			KvGetString(kv, "ball", ball, PLATFORM_MAX_PATH);
			ExplodeString(ball, ";", ballDatas, 3, 32);
			BallSpawnPoint[XPos] = StringToFloat(ballDatas[0]);
			BallSpawnPoint[YPos] = StringToFloat(ballDatas[1]);
			BallSpawnPoint[ZPos] = StringToFloat(ballDatas[2]);
			
			// T goal position
			char tgoal[512];
			char tgoalDatas[3][32];
			KvGetString(kv, "goal_t", tgoal, PLATFORM_MAX_PATH);
			ExplodeString(tgoal, ";", tgoalDatas, 3, 32);
			TGoalSpawnPoint[XPos] = StringToFloat(tgoalDatas[0]);
			TGoalSpawnPoint[YPos] = StringToFloat(tgoalDatas[1]);
			TGoalSpawnPoint[ZPos] = StringToFloat(tgoalDatas[2]);
			
			// CT goal position
			char ctgoal[512];
			char ctgoalDatas[3][32];
			KvGetString(kv, "goal_ct", ctgoal, PLATFORM_MAX_PATH);
			ExplodeString(ctgoal, ";", ctgoalDatas, 3, 32);
			CTGoalSpawnPoint[XPos] = StringToFloat(ctgoalDatas[0]);
			CTGoalSpawnPoint[YPos] = StringToFloat(ctgoalDatas[1]);
			CTGoalSpawnPoint[ZPos] = StringToFloat(ctgoalDatas[2]);
		}
		else
		{
			SetFailState("Fatal error: Unable to find current map settings in configuration file \"%s\"!", Configfile);
		}
	}
	CloseHandle(kv);
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
	
	ServerCommand("mp_ignore_round_win_conditions 1");
	
	// Remove freezetime
	ServerCommand("mp_freezetime 0");
	
	// Plugin will not working if we don't have this
	ServerCommand("mp_do_warmup_period 1");
	ServerCommand("mp_do_warmuptime 1");
	
	// Remove shit
	ServerCommand("mp_weapons_allow_map_placed 0");
	ServerCommand("mp_death_drop_gun 0");
	
	// Remove cash
	ServerCommand("mp_playercashawards 0");
	ServerCommand("mp_teamcashawards 0");
	
	// Give free armor
	ServerCommand("mp_free_armor 2");
	
	// Bot is not allowed in this gamemode, because they don't know how to play
	ServerCommand("bot_quota 0");
	
	// Spec enemy is not allowed?
	// ServerCommand("mp_forcecamera 1");
	
	// We slay loser on round end, so we have to disable this. DO NOT CHANGE THIS
	ServerCommand("mp_autokick 0");
	
	// Match restart delay. DO NOT CHANGE THIS
	ServerCommand("mp_match_restart_delay 20");
	
	// Win panel show up delay. DO NOT CHANGE THIS
	ServerCommand("mp_win_panel_display_time 7");
	
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
	
	// Precache BGM
	FakePrecacheSound("*/touchdown/bgm/Chain_Reaction.mp3");
	FakePrecacheSound("*/touchdown/bgm/Super_Sonic.mp3");
	FakePrecacheSound("*/touchdown/bgm/Nova.mp3");
	FakePrecacheSound("*/touchdown/bgm/Lobby.mp3");
	FakePrecacheSound("*/touchdown/bgm/Dual_Rock.mp3");
	FakePrecacheSound("*/touchdown/bgm/Move_Your_Spirit.mp3");
	FakePrecacheSound("*/touchdown/bgm/Fuzzy_Control.mp3");
	FakePrecacheSound("*/touchdown/bgm/Seize.mp3");
	
	// Ball
	FakePrecacheSound("*/touchdown/pokeball_bounce.mp3");
	
	// Sometimes flag & ball not spawn, need to restart game
	ServerCommand("mp_restartgame 10");
	
	score_t = 0;
	score_ct = 0;
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
	CreateTimer(0.1, ShowWeaponMenu, client);
	
	if (IsValidClient(client) && !IsFakeClient(client))
	{	
		EmitSoundToClient(client, "*/touchdown/player_respawn.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
	}
}

// Weapons
// Edited from boomix's capture the flag, add translations and some improvement.
public Action ShowWeaponMenu(Handle tmr, any client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	// New weapon
	if (!b_AutoGiveWeapons[client] && b_SelectedWeapon[client])
	{
		RemoveAllWeapons(client, false);
		
		GivePlayerItem(client, g_LastPrimaryWeapon[client]);
		GivePlayerItem(client, g_LastSecondaryWeapon[client]);
		b_SelectedWeapon[client] = false;
	}
	
	else if(b_AutoGiveWeapons[client] && !b_SelectedWeapon[client])
	{
		RemoveAllWeapons(client, false);
		
		// Always random
		if(i_RandomWeapons[client] == 2)
		{
			GiveRandomWeapon(client);
		}
		
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
	menu.AddItem("new", 			newweapons);
	
	char lastweapons[512];
	Format(lastweapons, sizeof(lastweapons), "%T", "Last Weapons", client);
	
	char lastweapons2[512];
	Format(lastweapons2, sizeof(lastweapons2), "%T", "Last Weapons All The Time", client);
	
	if(StrContains(g_LastPrimaryWeapon[client], "weapon_") != -1 && StrContains(g_LastSecondaryWeapon[client], "weapon_") != -1 )
	{
		menu.AddItem("last", 			lastweapons);
		menu.AddItem("lastf", 			lastweapons2);
	} else {
		menu.AddItem("", lastweapons, ITEMDRAW_DISABLED);
		menu.AddItem("", lastweapons2, ITEMDRAW_DISABLED);
	}
	
	char randomweapons[512];
	Format(randomweapons, sizeof(randomweapons), "%T", "Random Weapons", client);
	menu.AddItem("random", 			randomweapons);
	
	char randomweapons2[512];
	Format(randomweapons2, sizeof(randomweapons2), "%T", "Random Weapons All The Time", client);
	menu.AddItem("random2", 			randomweapons2);
	
	SetMenuExitButton(menu, true);
	menu.Display(client, 0);
}

public int MenuHandlers_MainMenu(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));

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
	menu.AddItem("weapon_ump45", "UMP45");
	menu.AddItem("weapon_p90", "P90");
	
	SetMenuExitButton(menu, false);
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
			
			if(!HasWeapon(client) && IsPlayerAlive(client))
				GivePlayerItem(client, info);
			
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
			menu2.AddItem("weapon_hkp2000", 	"USP");
			menu2.AddItem("weapon_p250", 		"P250");
			menu2.AddItem("weapon_tec9", 		"TEC-9");
			SetMenuExitButton(menu2, false);
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
			GetMenuItem(menu2, item, info, sizeof(info));
			if(!HasWeapon(client, true) && IsPlayerAlive(client))
				GivePlayerItem(client, info);
			
			g_LastSecondaryWeapon[client] = info;
			
			b_SelectedWeapon[client] = true;
		}
	}
}

public void RemoveAllWeapons(int client, bool RemoveKnife)
{
	//Primary weapon check
	if(!IsClientInGame(client))
		return;
		
	int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if(weapon > 0) {
		RemovePlayerItem(client, weapon);
		RemoveEdict(weapon);
	}
	
	//Secondary
	int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(weapon2 > 0) {
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}
	
	//Grenade
	int weapon3 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon3 > 0) {
		RemovePlayerItem(client, weapon3);
		RemoveEdict(weapon3);
	}
	
	//Grenade
	int weapon4 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	if(weapon4 > 0) {
		RemovePlayerItem(client, weapon4);
		RemoveEdict(weapon4);
	}
	
	if(RemoveKnife)
	{
		int weapon5 = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
		if(weapon5 > 0) {
			RemovePlayerItem(client, weapon5);
			RemoveEdict(weapon5);
		}	
	}
	
}

bool HasWeapon(int client, bool Secondary = false)
{
	if(Secondary)
	{
		int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		if(weapon2 > 0)
			return true;
		else
			return false;
	} 
	else 
	{
		int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		int weapon2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		if(weapon > 0 || weapon2 > 0)
			return true;
		else
			return false;
	}

}

void GiveRandomWeapon(int client)
{
	int primary = GetRandomInt(0, 17);
	int secondary = GetRandomInt(0, 9);
	
	if(IsPlayerAlive(client) && !HasWeapon(client))
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
	SpawnBall();
	SpawnGoal();
	
	// Reset ball holder
	BallHolder = 0;
	BallDroperTeam = 0;
	
	// Reset timer
	ResetTimer();
	
	// Play Round Start Sound
	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			CreateTimer(1.0, StartGameTimer);
				
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					//ClientCommand(i, "play *touchdown/ready1.mp3");
					EmitSoundToClient(i, "*/touchdown/ready1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				}
				case 2:
				{
					//ClientCommand(i, "play *touchdown/ready2.mp3");
					EmitSoundToClient(i, "*/touchdown/ready2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				}
			}
		}
	}
		
	// Play BGM
	CreateTimer(0.5, PlayBGMTimer);
	
	// round countdown
	roundtime = GetConVarFloat(FindConVar("mp_roundtime"));
	roundtime *= 60.0;
	hRoundCountdown = CreateTimer(1.0, RoundCountdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action PlayBGMTimer(Handle tmr, any client)
{
	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !IsFakeClient(i))
		{
			StopBGM(i);
			
			switch(GetRandomInt(1, 8))
			{
				// Chain Reaction
				case 1:
				{
					BGM = 1;
				}
				
				// Supersonic
				case 2:
				{
					BGM = 2;
				}
				
				// Nova
				case 3:
				{
					BGM = 3;
				}
				
				// Lobby
				case 4:
				{
					BGM = 4;
				}
				
				// Dual Rock
				case 5:
				{
					BGM = 5;
				}
				
				// Move_Your_Spirit
				case 6:
				{
					BGM = 6;
				}
				
				// Fuzzy Control
				case 7:
				{
					BGM = 7;
				}
				
				// Seize
				case 8:
				{
					BGM = 8;
				}
			}
			
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
			EmitSoundToClient(client, "*/touchdown/bgm/Chain_Reaction.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(195.0, BGMTimer, client);
		}
		
		if(BGM == 2)
		{
			CPrintToChat(client, "%T", "BGM 2", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Super_Sonic.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(195.0, BGMTimer, client);
		}
	
		if(BGM == 3)	
		{
			CPrintToChat(client, "%T", "BGM 3", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Nova.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(123.0, BGMTimer, client);
		}
		
		if(BGM == 4)	
		{
			CPrintToChat(client, "%T", "BGM 4", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Lobby.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(132.0, BGMTimer, client);
		}
		
		if(BGM == 5)	
		{
			CPrintToChat(client, "%T", "BGM 5", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Dual_Rock.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(163.0, BGMTimer, client);
		}
		
		if(BGM == 6)	
		{
			CPrintToChat(client, "%T", "BGM 6", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Move_Your_Spirit.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(230.0, BGMTimer, client);
		}
		
		if(BGM == 7)	
		{
			CPrintToChat(client, "%T", "BGM 7", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Fuzzy_Control.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(159.0, BGMTimer, client);
		}
		
		if(BGM == 8)	
		{
			CPrintToChat(client, "%T", "BGM 8", client);
			EmitSoundToClient(client, "*/touchdown/bgm/Seize.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
			hBGMTimer[client] = CreateTimer(122.0, BGMTimer, client);
		}
	}
}

void StopBGM(int client)
{
	if(BGM == 1)
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Chain_Reaction.mp3");
	}
		
	if(BGM == 2)
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Super_Sonic.mp3");
	}
	
	if(BGM == 3)	
	{
		StopSound(client, SNDCHAN_STATIC,  "*/touchdown/bgm/Nova.mp3");
	}
	
	if(BGM == 4)	
	{
		StopSound(client, SNDCHAN_STATIC,  "*/touchdown/bgm/Lobby.mp3");
	}
		
	if(BGM == 5)	
	{
		StopSound(client, SNDCHAN_STATIC,  "*/touchdown/bgm/Dual_Rock.mp3");
	}
	
	if(BGM == 6)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Move_Your_Spirit.mp3");
	}
		
	if(BGM == 7)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Fuzzy_Control.mp3");	
	}
	
	if(BGM == 8)	
	{
		StopSound(client, SNDCHAN_STATIC, "*/touchdown/bgm/Seize.mp3");	
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
	
	// Cookie
	char buffer[5];
	GetClientCookie(client, clientVolCookie, buffer, 5);
	if(!StrEqual(buffer, ""))
	{
		g_fvol[client] = StringToFloat(buffer);
	}
	if(StrEqual(buffer,"")){
		g_fvol[client] = 0.8;
	}
	
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}

public Action RoundCountdown(Handle tmr)
{
	--roundtime;
	
	//3 mins, 1 mins, 30 sec, 10...1 left
    
	if (roundtime == 180)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "3 Minutes Left Hint", i);
				CPrintToChat(i, "%T", "3 Minutes Left", i);
				
				EmitSoundToClient(i, "*/touchdown/_eu_3minute.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 60)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "1 Minute Left Hint", i);
				CPrintToChat(i, "%T", "1 Minute Left", i);
				
				EmitSoundToClient(i, "*/touchdown/_eu_1minute.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 30)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "30 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "30 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/_eu_30second.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 10)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "10 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "10 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/10.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 9)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "9 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "9 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/9.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}

	else if (roundtime == 8)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "8 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "8 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/8.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 7)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "7 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "7 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 6)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "6 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "6 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 5)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "5 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "5 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 4)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "4 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "4 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 3)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "3 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "3 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 2)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "2 Seconds Left Hint", i);
				CPrintToChat(i, "%T", "2 Seconds Left", i);
				
				EmitSoundToClient(i, "*/touchdown/2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 1)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "1 Second Left Hint", i);
				CPrintToChat(i, "%T", "1 Second Left", i);
				
				EmitSoundToClient(i, "*/touchdown/1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	
	else if (roundtime == 0)
	{
		KillTimer(hRoundCountdown);
		hRoundCountdown = INVALID_HANDLE;
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
	
	int i;
	for (i = 1; i <= MaxClients; i++)
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
    
    // Half time
	if (Switch)
	{
		KillTimer(hNextRoundCountdown);
		hNextRoundCountdown = INVALID_HANDLE;
	}
	
	if (Nextroundtime == 6)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "Next Round In", i);
				
				
				switch(GetRandomInt(1,4))
				{
					case 1:
					{
						EmitSoundToClient(i, "*/touchdown/new_round_in.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 2:
					{
						EmitSoundToClient(i, "*/touchdown/new_round_in1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 3:
					{
						EmitSoundToClient(i, "*/touchdown/next_round_in.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 4:
					{
						EmitSoundToClient(i, "*/touchdown/next_round_in1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
				}
			}
		}
	}
	
	else if (Nextroundtime == 5)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 5", i);
			}
		}
	}
	
	else if (Nextroundtime == 4)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 4", i);
			}
		}
	}
	
	else if (Nextroundtime == 3)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 3", i);
			}
		}
	}
	
	else if (Nextroundtime == 2)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 2", i);
			}
		}
	}
	
	else if (Nextroundtime == 1)
	{
		int i;
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				EmitSoundToClient(i, "*/touchdown/1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
				PrintHintText(i, "%T", "Next Round In 1", i);
			}
		}
	}
	
	else if (Nextroundtime <= 0)
	{
		KillTimer(hNextRoundCountdown);
		hNextRoundCountdown = INVALID_HANDLE;
	}
}

void SpawnGoal()
{
	// Create CT goal model
	// CT Flag
	int ctflag = CreateEntityByName("prop_dynamic_override");
		
	SetEntityModel(ctflag, FlagModelPath);
	SetEntPropString(ctflag, Prop_Data, "m_iName", "CTGoalFlag");
	SetEntProp(ctflag, Prop_Send, "m_nBody", 0);

	DispatchSpawn(ctflag);
	
	SetVariantString("flag_idle1");
	AcceptEntityInput(ctflag, "SetAnimation");
	AcceptEntityInput(ctflag, "TurnOn");
	
	float ctflagpos[3];
	ctflagpos[0] = CTGoalSpawnPoint[XPos];
	ctflagpos[1] = CTGoalSpawnPoint[YPos];
	ctflagpos[2] = CTGoalSpawnPoint[ZPos];

	TeleportEntity(ctflag, ctflagpos, NULL_VECTOR, NULL_VECTOR);
	
	// CT Pole
	int ctpole = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(ctpole, PoleModelPath);
	SetEntPropString(ctpole, Prop_Data, "m_iName", "CTGoalPole");
	SetEntProp(ctpole, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(ctpole, Prop_Data, "m_nSolidType", 6);
	SetEntProp(ctpole, Prop_Send, "m_CollisionGroup", 1);
	
	float ctpolepos[3];
	ctpolepos[0] = CTGoalSpawnPoint[XPos];
	ctpolepos[1] = CTGoalSpawnPoint[YPos];
	ctpolepos[2] = CTGoalSpawnPoint[ZPos] + 40;

	TeleportEntity(ctpole, ctpolepos, NULL_VECTOR, NULL_VECTOR);	

	SDKHook(ctpole, SDKHook_StartTouch, OnStartTouch);
	
	// CT Ground
	int ctground = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(ctground, GroundModelPath);
	SetEntPropString(ctground, Prop_Data, "m_iName", "CTGoalGround");
	SetEntProp(ctground, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(ctground, Prop_Data, "m_nSolidType", 6);
	SetEntProp(ctground, Prop_Send, "m_CollisionGroup", 1);
	
	float ctgroundpos[3];
	ctgroundpos[0] = CTGoalSpawnPoint[XPos];
	ctgroundpos[1] = CTGoalSpawnPoint[YPos];
	ctgroundpos[2] = CTGoalSpawnPoint[ZPos];

	TeleportEntity(ctground, ctgroundpos, NULL_VECTOR, NULL_VECTOR);	
	
	// Create T goal model
	// T Flag
	int tflag = CreateEntityByName("prop_dynamic_override");
		
	SetEntityModel(tflag, FlagModelPath);
	SetEntPropString(tflag, Prop_Data, "m_iName", "TGoalFlag");
	SetEntProp(tflag, Prop_Send, "m_nBody", 3);

	DispatchSpawn(tflag);
	
	SetVariantString("flag_idle1");
	AcceptEntityInput(tflag, "SetAnimation");
	AcceptEntityInput(tflag, "TurnOn");
	
	float tflagpos[3];
	tflagpos[0] = TGoalSpawnPoint[XPos];
	tflagpos[1] = TGoalSpawnPoint[YPos];
	tflagpos[2] = TGoalSpawnPoint[ZPos];

	TeleportEntity(tflag, tflagpos, NULL_VECTOR, NULL_VECTOR);
	
	// T Pole
	int tpole = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(tpole, PoleModelPath);
	SetEntPropString(tpole, Prop_Data, "m_iName", "TGoalPole");
	SetEntProp(tpole, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(tpole, Prop_Data, "m_nSolidType", 6);
	SetEntProp(tpole, Prop_Send, "m_CollisionGroup", 1);
	
	float tpolepos[3];
	tpolepos[0] = TGoalSpawnPoint[XPos];
	tpolepos[1] = TGoalSpawnPoint[YPos];
	tpolepos[2] = TGoalSpawnPoint[ZPos] + 40;

	TeleportEntity(tpole, tpolepos, NULL_VECTOR, NULL_VECTOR);	
	
	SDKHook(tpole, SDKHook_StartTouch, OnStartTouch);
	
	// T Ground
	int tground = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(tground, GroundModelPath);
	SetEntPropString(tground, Prop_Data, "m_iName", "TGoalGround");
	SetEntProp(tground, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(tground, Prop_Data, "m_nSolidType", 6);
	SetEntProp(tground, Prop_Send, "m_CollisionGroup", 1);

	float tgroundpos[3];
	tgroundpos[0] = TGoalSpawnPoint[XPos];
	tgroundpos[1] = TGoalSpawnPoint[YPos];
	tgroundpos[2] = TGoalSpawnPoint[ZPos];

	TeleportEntity(tground, tgroundpos, NULL_VECTOR, NULL_VECTOR);
}

public void OnStartTouch(int ent, int client)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsValidEntity(client))
		return;
	
	char Item[255];
	GetEntPropString(ent, Prop_Data, "m_iName", Item, sizeof(Item));
	
	char clientname [PLATFORM_MAX_PATH];
	GetClientName(client, clientname, sizeof(clientname));
	
	int i;
	
	// Someone get the ball
	if (StrEqual(Item, "TDBall"))
	{
		if(GetClientTeam(client) == SPEC)
			return;
		
		// Client get the ball
		if(BallHolder == 0 && IsPlayerAlive(client) && IsValidClient(client))
		{
			GetBall(client);
		}
		
		// Play Sound
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				// TR get the ball
				if(GetClientTeam(client) == TR)
				{
					CPrintToChat(i, "%T", "Get Ball T", i, clientname);
					
					// TR play attack Sound
					if(GetClientTeam(i) == TR)
					{
						hAcquiredBallText[i] = CreateTimer(0.1, AcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 8))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking1.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking2.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 4:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking3.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 5:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking4.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 6:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking5.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 7:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking6.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 8:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking7.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
						}
					}
					// CT play defence sound
					if(GetClientTeam(i) == CT)
					{
						hRAcquiredBallText[i] = CreateTimer(0.1, RAcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 3))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/you_are_defending.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_defending.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/you_are_defending1.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_defending1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/you_are_defending2.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_defending2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
						}
					}
				}
				// CT get the ball
				if(GetClientTeam(client) == CT)
				{
					CPrintToChat(i, "%T", "Get Ball CT", i, clientname);
					
					// CT play attack Sound
					if(GetClientTeam(i) == CT)
					{
						hAcquiredBallText[i] = CreateTimer(0.1, AcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 8))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking1.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking2.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 4:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking3.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 5:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking4.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 6:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking5.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 7:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking6.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 8:
							{
								//ClientCommand(i, "play *touchdown/you_are_attacking7.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_attacking7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
						}
					}
					// TR play defence sound
					if(GetClientTeam(i) == TR)
					{
						hRAcquiredBallText[i] = CreateTimer(0.1, RAcquiredBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					
						switch(GetRandomInt(1, 3))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/you_are_defending.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_defending.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/you_are_defending1.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_defending1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/you_are_defending2.mp3");
								EmitSoundToClient(i, "*/touchdown/you_are_defending2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
							}
						}
					}
				}
			}
		}
	}
		
	// Someone Go to CT Goal
	if (StrEqual(Item, "CTGoalPole"))
	{
		// And he has a ball.
		if(GetClientTeam(client) == TR && BallHolder == client && IsValidClient(client))
		{
			// SlayLoser, Force round end.
			ServerCommand("sm_slay @ct");
			
			/*
			for (i = 1; i <= MaxClients; i++)
			{
				if(GetClientTeam(i) == CT && IsValidClient(i))
					ForcePlayerSuicide(i);
			}
			*/
			
			OnTeamWin(CS_TEAM_T);

			CS_SetMVPCount(client, CS_GetMVPCount(client) + 1);
			
			// Remove ball
			GoalBall(client);	
			
			// Create CT Goal Particle
			CreateCTGoalParticle();
			
			// Announce touchdown
			for (i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i)) 
				{
					if (GetClientTeam(client) == TR) 
						CPrintToChat(i, "%T", "Touchdown CT", i, clientname);
				}
			}
			
			RoundEnd = true;
		}
	}
	
	// Someone Go to T Goal
	if (StrEqual(Item, "TGoalPole"))
	{
		// And he has a ball.
		if(GetClientTeam(client) == CT && BallHolder == client && IsValidClient(client))
		{
			// SlayLoser, Force round end.
			ServerCommand("sm_slay @t");
			
			/*
			for (i = 1; i <= MaxClients; i++)
			{
				if(GetClientTeam(i) == TR && IsValidClient(i))
					ForcePlayerSuicide(i);
			}
			*/
			
			OnTeamWin(CS_TEAM_CT);
			
			CS_SetMVPCount(client, CS_GetMVPCount(client) + 1);
			
			// Remove ball
			GoalBall(client);	
			
			// Creat T Goal Particle
			CreateTGoalParticle();
			
			// Announce touchdown
			for (i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !IsFakeClient(i)) 
					CPrintToChat(i, "%T", "Touchdown T", i, clientname);
			}
			
			RoundEnd = true;
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

void CreateCTGoalParticle()
{
	CTGoalParticle = CreateEntityByName("info_particle_system");
	
	DispatchKeyValue(CTGoalParticle, "start_active", "1");
	DispatchKeyValue(CTGoalParticle, "effect_name", GoalParticleEffect);
	DispatchSpawn(CTGoalParticle);
		
	float ctflagpos[3];
	ctflagpos[0] = CTGoalSpawnPoint[XPos];
	ctflagpos[1] = CTGoalSpawnPoint[YPos];
	ctflagpos[2] = CTGoalSpawnPoint[ZPos];

	TeleportEntity(CTGoalParticle, ctflagpos, NULL_VECTOR, NULL_VECTOR);
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
		
	float tflagpos[3];
	tflagpos[0] = TGoalSpawnPoint[XPos];
	tflagpos[1] = TGoalSpawnPoint[YPos];
	tflagpos[2] = TGoalSpawnPoint[ZPos];

	TeleportEntity(TGoalParticle, tflagpos, NULL_VECTOR, NULL_VECTOR);

	SetVariantString("!activator");	
	ActivateEntity(TGoalParticle);
	AcceptEntityInput(TGoalParticle, "Start");
}

void OnTeamWin(int team)
{
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
	
	if(GetClientTeam(client) == CT)
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
	
	int i;
	for (i = 1; i <= MaxClients; i++)
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
		
	char clientname [PLATFORM_MAX_PATH];
	GetClientName(client, clientname, sizeof(clientname));
	
	// Call forward
	Call_StartForward(OnPlayerDropBall);
	Call_PushCell(client);
	Call_Finish();

	// Remove player ball model
	RemoveBall();
	
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
	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) != SPEC)
		{
			if(GetClientTeam(client) == TR)
				CPrintToChat(i, "%T", "Drop Ball T", i, clientname);
				
			if(GetClientTeam(client) == CT)
				CPrintToChat(i, "%T", "Drop Ball CT", i, clientname);
			
			// Nice Chance!
			if(GetClientTeam(i) != GetClientTeam(client))
			{
				hRDropBallText[i] = CreateTimer(0.1, RDropBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						//ClientCommand(i, "play *touchdown/red_fumbled.mp3");
						EmitSoundToClient(i, "*/touchdown/red_fumbled.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 2:
					{
						EmitSoundToClient(i, "*/touchdown/red_fumbled1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
				}
			}
				
			// Lost the ball!
			if(GetClientTeam(i) == GetClientTeam(client))
			{
				hDropBallText[i] = CreateTimer(0.1, DropBallText, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
				switch(GetRandomInt(1,5))
				{
					case 1:
					{
						//ClientCommand(i, "play *touchdown/blue_fumbled.mp3");
						EmitSoundToClient(i, "*/touchdown/blue_fumbled.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 2:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 3:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 4:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					case 5:
					{
						EmitSoundToClient(i, "*/touchdown/blue_fumbled4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
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
	
	BallHolder = 0;
	BallDroperTeam = 0;
	
	int i;
	for (i = 1; i <= MaxClients; i++)
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

// Terminate round from boomix's capture the flag
void RoundEnd_OnRoundStart()
{
	b_JustEnded = false;
	g_roundStartedTime = GetTime();
}

public void OnGameFrame()
{
	RoundEnd_OnGameFrame();
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
	Handle h_freezeTime = FindConVar("mp_freezetime");
	int freezeTime = GetConVarInt(h_freezeTime);
	return (GetTime() - g_roundStartedTime) - freezeTime;
}

public Action JustEndedFalse(Handle tmr, any client)
{
	if(GetClientCount(true) > 0)
		OnTeamWin(CS_TEAM_NONE);
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	int i;
	int Winner = GetEventInt(event, "winner");
	
	if(hRoundCountdown != INVALID_HANDLE)
	{
		KillTimer(hRoundCountdown);
	}
	hRoundCountdown = INVALID_HANDLE;
	
	for (i = 1; i <= MaxClients; i++)
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
		}
	}
	
	// Round Draw
	// play timeover sound
	char sMessage[256] = "";
	GetEventString(event, "message",sMessage, sizeof(sMessage));
	if(StrEqual(sMessage,"#SFUI_Notice_Round_Draw", false))
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				PrintHintText(i, "%T", "Time Is Up Hint", i);
				CPrintToChat(i, "%T", "Time Is Up", i);
				EmitSoundToClient(i, "*/touchdown/inter_timeover.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			}
		}
	}
	else
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !IsFakeClient(i)) 
			{
				if(GetClientTeam(i) == SPEC)
					continue;
				
				// TR win this round, play sound & overlay to TR
				if (Winner == TR && GetClientTeam(i) == TR)
				{
					SetClientOverlay(i, "touchdown/touchdown_green");
					
					// TR lead 1 point
					if(score_t - score_ct == 1)
					{
						switch(GetRandomInt(1,2))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/blue_team_take_the_lead.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/blue_team_take_the_lead1.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
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
								//ClientCommand(i, "play *touchdown/blue_team_scores.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores1.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores2.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 4:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores3.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 5:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores4.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
						}
					}
				}
				
				// TR win this round, play sound & overlay to CT
				if (Winner == TR && GetClientTeam(i) == CT) 
				{
					SetClientOverlay(i, "touchdown/touchdown_red");
					
					// TR lead 1 point
					if(score_t - score_ct == 1)
					{
						//ClientCommand(i, "play *touchdown/red_team_take_the_lead.mp3");
						EmitSoundToClient(i, "*/touchdown/red_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					else
					{
						switch(GetRandomInt(1,3))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/red_team_scores.mp3");
								EmitSoundToClient(i, "*/touchdown/red_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 2:
							{
								EmitSoundToClient(i, "*/touchdown/red_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 3:
							{
								EmitSoundToClient(i, "*/touchdown/red_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
						}
					}
				}
				
				// CT win this round, play sound & overlay to CT
				if (Winner == CT && GetClientTeam(i) == CT) 
				{
					SetClientOverlay(i, "touchdown/touchdown_green");
					
					// CT lead 1 point
					if(score_ct - score_t == 1)
					{
						switch(GetRandomInt(1,2))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/blue_team_take_the_lead.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/blue_team_take_the_lead1.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_take_the_lead1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
						}
					}
					else
					{
						switch(GetRandomInt(1,5))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores1.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores2.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 4:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores3.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 5:
							{
								//ClientCommand(i, "play *touchdown/blue_team_scores4.mp3");
								EmitSoundToClient(i, "*/touchdown/blue_team_scores4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
						}
					}
				}
				
				// CT win this round, play sound & overlay to TR
				if (Winner == CT && GetClientTeam(i) == TR) 
				{
					SetClientOverlay(i, "touchdown/touchdown_red");
					
					// CT lead 1 point
					if(score_ct - score_t == 1)
					{
						//ClientCommand(i, "play *touchdown/red_team_take_the_lead.mp3");
						EmitSoundToClient(i, "*/touchdown/red_team_take_the_lead.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
					}
					else
					{
						switch(GetRandomInt(1,3))
						{
							case 1:
							{
								//ClientCommand(i, "play *touchdown/red_team_scores.mp3");
								EmitSoundToClient(i, "*/touchdown/red_team_scores.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 2:
							{
								//ClientCommand(i, "play *touchdown/red_team_scores1.mp3");
								EmitSoundToClient(i, "*/touchdown/red_team_scores1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
							case 3:
							{
								//ClientCommand(i, "play *touchdown/red_team_scores2.mp3");
								EmitSoundToClient(i, "*/touchdown/red_team_scores2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
							}
						}
					}
				}
				
				CreateTimer(8.0, DeleteOverlay, i);
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
		EmitSoundToClient(attacker, "* /touchdown/critical.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[client]);
	}
}
*/

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// slay player to at round end so we don't need to play kill sound & respawn
	if(RoundEnd)
		return;
		
	// PrintText
	PrintHintText(client, "%T", "Respawn", client, ftd_respawn);
	CPrintToChat(client, "%T", "Respawn 2", client, ftd_respawn);
	
	// Respawn Victim
	CreateTimer(ftd_respawn, Respawn_Player, client);
	
	if(IsValidClient(attacker) && client != BallHolder && client != attacker && IsValidClient(client))
	{
		switch(GetRandomInt(1,8))
		{
			case 1:
			{
				//ClientCommand(attacker, "play *touchdown/kill1.mp3");
				EmitSoundToClient(attacker, "*/touchdown/kill1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 2:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 3:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill3.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 4:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill4.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 5:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill5.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 6:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill6.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 7:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill7.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
			case 8:
			{
				EmitSoundToClient(attacker, "*/touchdown/kill8.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[attacker]);
			}
		}
	}
	
	// Force thirdperson to prevent sound vol low (sound from player is fucking stupid)
	// SetEntPropEnt(client, Prop_Send, "m_iObserverMode", 5);
            
	// Kill Ball Holder
	if(BallHolder == client)
	{
		DropBall(client);
		
		Call_StartForward(OnPlayerKillBall);
		Call_PushCell(client);
		Call_PushCell(attacker);
		Call_Finish();
		
		char attackername [PLATFORM_MAX_PATH];
		GetClientName(attacker, attackername, sizeof(attackername));
		
		char clientname [PLATFORM_MAX_PATH];
		GetClientName(client, clientname, sizeof(clientname));
		
		int i;
		for (i = 1; i <= MaxClients; i++)
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
				if(client != attacker && IsValidClient(client))
				{
					if(GetClientTeam(attacker) == TR)
						CPrintToChat(i, "%T", "Kill Ball T", i, attackername, clientname);
					
					else if(GetClientTeam(attacker) == CT)
						CPrintToChat(i, "%T", "Kill Ball CT", i, attackername, clientname);
				}
			}
		}
	}
}

public Action Respawn_Player(Handle tmr, any client)
{
	if(RoundEnd)
		return;
		
	if(IsClientInGame(client) && !IsPlayerAlive(client) && (GetClientTeam(client) != SPEC))
	{
		CS_RespawnPlayer(client);
	}
}

public Action ResetBallTimer(Handle tmr, any client)
{
	ResetBall();
	hResetBallTimer = INVALID_HANDLE;
}

void SpawnBall()
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
	ballpos[0] = BallSpawnPoint[XPos];
	ballpos[1] = BallSpawnPoint[YPos];
	ballpos[2] = BallSpawnPoint[ZPos];

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

void ResetBall()
{
	// Remove all ball
	RemoveBall();
	
	Call_StartForward(OnBallReset);
	Call_Finish();

		
	// Reset Ball Holder
	BallHolder = 0;
	BallDroperTeam = 0;
	
	// Spawn Ball
	SpawnBall();
	
	// Play reset sound
	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i)) 
		{
			//ClientCommand(i, "play *touchdown/_eu_ball_reset.mp3");
			EmitSoundToClient(i, "*/touchdown/_eu_ball_reset.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
			
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

public Action Command_Test(int client,int args)
{
	
	/*
	PrintToChat(client, "%i", BGM);
	
	if(hBGMTimer[client] == INVALID_HANDLE)
		PrintToChat(client, "INVALID_HANDLE");
		
	if(hBGMTimer[client] != INVALID_HANDLE)
		PrintToChat(client, "VALID_HANDLE");
		
	PrintToChat(client, "%f", ftd_respawn);
	PrintToChat(client, "%f", ftd_reset);
	
	if(hAcquiredBallText[client] != INVALID_HANDLE)
		PrintToChat(client, "hAcquiredBllText");
		
	if(hAcquiredBallText [client]== INVALID_HANDLE)
		PrintToChat(client, "hAcquiredBallText INVALID_HANDLE");
		
	if(hRAcquiredBallText[client] == INVALID_HANDLE)
		PrintToChat(client, "hRAcquiredBallText INVALID_HANDLE");
		
	if(hRAcquiredBallText[client] != INVALID_HANDLE)
		PrintToChat(client, "hRAcquiredBallText INVALID_HANDLE");
	*/
}

// Match End
public Action Event_WinPanelMatch(Handle event, const char[] name, bool dontBroadcast)
{
	CreateTimer(7.0, MatchEndSound);
	ResetTimer();
}

public Action MatchEndSound(Handle tmr)
{
	int i;
	for (i = 1; i <= MaxClients; i++)
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
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
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
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
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
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
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
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_lost_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
						}
					}
				}
			}
			// CT Win
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
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
						}
						case 2:
						{
							EmitSoundToClient(i, "*/touchdown/you_have_won_the_match1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[i]);
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
	}
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
		
		if (volume < 0.2 || volume > 1.0)
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

public Action Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
    
	if(!IsValidClient(client) || !IsClientInGame(client))
		return Plugin_Continue;

	if(!IsPlayerAlive(client) && !RoundEnd)
		CreateTimer(8.0, Respawn_Player, client);
        
	return Plugin_Continue;
}

public Action Command_Join(int client, const char[] command, int argc)
{
	char sJoining[8];
	GetCmdArg(1, sJoining, sizeof(sJoining));
	int iJoining = StringToInt(sJoining);
	
	if(BallHolder == client)
		DropBall(client);
	
	if(iJoining == CS_TEAM_SPECTATOR)
	{
		return Plugin_Continue;
	}

	int iTeam = GetClientTeam(client);
	if(iJoining == iTeam)
		return Plugin_Handled;
	else
	{
		SetEntProp(client, Prop_Send, "m_iTeamNum", iJoining);
		ForcePlayerSuicide(client);
		
		if(!RoundEnd)
		{
			CS_RespawnPlayer(client);
		}
		
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
		ftd_respawn = GetConVarFloat(td_respawn);
	}
	else if (convar == td_reset) 
	{
		ftd_reset = GetConVarFloat(td_reset);
	}
	else if (convar == td_ballposition) 
	{
		itd_ballposition = GetConVarInt(td_ballposition);
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
		int j;
		for (j = 1; j <= MaxClients; j++)
		{
			if (IsValidClient(j) && !IsFakeClient(j))
				EmitSoundToClient(j, "*/touchdown/pokeball_bounce.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, _, _, g_fvol[j]);
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

public Action OnWeaponCanUse(int client, int weapon) 
{
    if(GetClientButtons(client) & IN_USE)
        return Plugin_Handled; 
    
    return Plugin_Continue; 
}

public Action OnWeaponDrop(int client, int weapon) 
{
    if(GetClientButtons(client) & IN_USE)
        return Plugin_Handled; 
    
    return Plugin_Continue; 
}  