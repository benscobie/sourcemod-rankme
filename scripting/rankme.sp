#pragma semicolon  1
#define PLUGIN_VERSION "3.0.3"
#include <sourcemod> 
#include <adminmenu>
#include <multicolors>
#include <rankme>
#define MSG "\x01\x0B\x04[RankMe] \x01"
#define SPEC 1
#define TR 2
#define CT 3

#define SENDER_WORLD					0
#define MAX_LENGTH_MENU 470

new String:g_sSqlCreate[] = "CREATE TABLE IF NOT EXISTS `%s` (id INTEGER PRIMARY KEY, steam TEXT, name TEXT, lastip TEXT, score NUMERIC, kills NUMERIC, deaths NUMERIC, suicides NUMERIC, tk NUMERIC, shots NUMERIC, hits NUMERIC, headshots NUMERIC, connected NUMERIC, rounds_tr NUMERIC, rounds_ct NUMERIC, lastconnect NUMERIC,knife NUMERIC,glock NUMERIC,hkp2000 NUMERIC,p250 NUMERIC,deagle NUMERIC,elite NUMERIC,fiveseven NUMERIC,tec9 NUMERIC,nova NUMERIC,xm1014 NUMERIC,mag7 NUMERIC,sawedoff NUMERIC,bizon NUMERIC,mac10 NUMERIC,mp9 NUMERIC,mp7 NUMERIC,ump45 NUMERIC,p90 NUMERIC,galilar NUMERIC,ak47 NUMERIC,scar20 NUMERIC,famas NUMERIC,m4a1 NUMERIC,aug NUMERIC,ssg08 NUMERIC,sg556 NUMERIC,awp NUMERIC,g3sg1 NUMERIC,m249 NUMERIC,negev NUMERIC,hegrenade NUMERIC,flashbang NUMERIC,smokegrenade NUMERIC,incgrenade NUMERIC,molotov NUMERIC,taser NUMERIC,decoy NUMERIC,head NUMERIC, chest NUMERIC, stomach NUMERIC, left_arm NUMERIC, right_arm NUMERIC, left_leg NUMERIC, right_leg NUMERIC,c4_planted NUMERIC,c4_exploded NUMERIC,c4_defused NUMERIC,ct_win NUMERIC, tr_win NUMERIC, hostages_rescued NUMERIC, vip_killed NUMERIC, vip_escaped NUMERIC, vip_played NUMERIC)";
new String:g_sSqlInsert[] = "INSERT INTO `%s` VALUES (NULL,'%s','%s','%s','%d','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');";
new String:g_sSqlSave[] = "UPDATE `%s` SET score = '%i', kills = '%i', deaths='%i',suicides='%i',tk='%i',shots='%i',hits='%i',headshots='%i', rounds_tr = '%i', rounds_ct = '%i',lastip='%s',name='%s'%s,head='%i',chest='%i', stomach='%i',left_arm='%i',right_arm='%i',left_leg='%i',right_leg='%i',c4_planted='%i',c4_exploded='%i',c4_defused='%i',ct_win='%i',tr_win='%i', hostages_rescued='%i',vip_killed = '%d',vip_escaped = '%d',vip_played = '%d', lastconnect='%i', connected='%i' WHERE steam = '%s';";
new String:g_sSqlSaveName[] = "UPDATE `%s` SET score = '%i', kills = '%i', deaths='%i',suicides='%i',tk='%i',shots='%i',hits='%i',headshots='%i', rounds_tr = '%i', rounds_ct = '%i',lastip='%s',name='%s'%s,head='%i',chest='%i', stomach='%i',left_arm='%i',right_arm='%i',left_leg='%i',right_leg='%i',c4_planted='%i',c4_exploded='%i',c4_defused='%i',ct_win='%i',tr_win='%i', hostages_rescued='%i',vip_killed = '%d',vip_escaped = '%d',vip_played = '%d', lastconnect='%i', connected='%i' WHERE name = '%s';";
new String:g_sSqlSaveIp[] = "UPDATE `%s` SET score = '%i', kills = '%i', deaths='%i',suicides='%i',tk='%i',shots='%i',hits='%i',headshots='%i', rounds_tr = '%i', rounds_ct = '%i',lastip='%s',name='%s'%s,head='%i',chest='%i', stomach='%i',left_arm='%i',right_arm='%i',left_leg='%i',right_leg='%i',c4_planted='%i',c4_exploded='%i',c4_defused='%i',ct_win='%i',tr_win='%i', hostages_rescued='%i',vip_killed = '%d',vip_escaped = '%d',vip_played = '%d', lastconnect='%i', connected='%i' WHERE lastip = '%s';";
new String:g_sSqlRetrieveClient[] = "SELECT * FROM `%s` WHERE steam='%s';";
new String:g_sSqlRetrieveClientName[] = "SELECT * FROM `%s` WHERE name='%s';";
new String:g_sSqlRetrieveClientIp[] = "SELECT * FROM `%s` WHERE lastip='%s';";
new String:g_sSqlRemoveDuplicateSQLite[] = "delete from `%s` where `%s`.id > (SELECT min(id) from `%s` as t2 WHERE t2.steam=`%s`.steam);";
new String:g_sSqlRemoveDuplicateNameSQLite[] = "delete from `%s` where `%s`.id > (SELECT min(id) from `%s` as t2 WHERE t2.name=`%s`.name);";
new String:g_sSqlRemoveDuplicateIpSQLite[] = "delete from `%s` where `%s`.id > (SELECT min(id) from `%s` as t2 WHERE t2.lastip=`%s`.lastip);";
new String:g_sSqlRemoveDuplicateMySQL[] = "delete from `%s` USING `%s`, `%s` as vtable WHERE (`%s`.id>vtable.id) AND (`%s`.steam=vtable.steam);";
new String:g_sSqlRemoveDuplicateNameMySQL[] = "delete from `%s` USING `%s`, `%s` as vtable WHERE (`%s`.id>vtable.id) AND (`%s`.name=vtable.name);";
new String:g_sSqlRemoveDuplicateIpMySQL[] = "delete from `%s` USING `%s`, `%s` as vtable WHERE (`%s`.id>vtable.id) AND (`%s`.ip=vtable.ip);";
new String:g_sWeaponsNamesGame[37][] = {"knife","glock","hkp2000","p250","deagle","elite","fiveseven","tec9","nova","xm1014","mag7","bizon","sawedoff","mac10","mp9","mp7","ump45","p90","galilar","ak47","scar20","famas","m4a1","aug","ssg08","sg556","awp","g3sg1","m249","negev","hegrenade","flashbang","smokegrenade","incgrenade","molotov","taser","decoy"};
new String:g_sWeaponsNamesFull[37][] = {"Knife","9x19 mm Sidearm (Glock)","KM .45 Tactical (P9000)","250 Compact","Knighthawk .50C (Desert Eagle)",".40 Dual Elites","ES Five-Seven","Tec 9","Leone 12 Gauge Super","Leone YG1265 Auto Shotgun","Mag 7","Sawed-off Shotgun","PP-Bizon","Ingram MAC-10","MP9","KM Submachine Gun (MP7)","KM UMP45","ES C90 (P90)","IDF Defender","CV-47 (AK-47)","SCAR-20","Clarion 5.56","Maverick M4A1 Carbine (Colt)","Bullpup (AUG)","Schmidt Scout","Kreig 558","Magnum Sniper Rifle (AWP)","D3/AU-1 (G3)","M249","Negev","HE Grenade","Flashbang","Smoke Grenade","Incendiary Grenade","Molotove Cocktail","Zeus x27","Decoy"};
new Handle:g_cvarEnabled;
new Handle:g_cvarChatChange;
new Handle:g_cvarRankbots;
new Handle:g_cvarAutopurge;
new Handle:g_cvarDumpDB;
new Handle:g_cvarPointsBombDefusedTeam;
new Handle:g_cvarPointsBombDefusedPlayer;
new Handle:g_cvarPointsBombPlantedTeam;
new Handle:g_cvarPointsBombPlantedPlayer;
new Handle:g_cvarPointsBombExplodeTeam;
new Handle:g_cvarPointsBombExplodePlayer;
new Handle:g_cvarPointsBombPickup;
new Handle:g_cvarPointsBombDropped;
new Handle:g_cvarPointsHostageRescTeam;
new Handle:g_cvarPointsHostageRescPlayer;
new Handle:g_cvarPointsVipEscapedTeam;
new Handle:g_cvarPointsVipEscapedPlayer;
new Handle:g_cvarPointsVipKilledTeam;
new Handle:g_cvarPointsVipKilledPlayer;
new Handle:g_cvarPointsHs;
new Handle:g_cvarPointsKillCt;
new Handle:g_cvarPointsKillTr;
new Handle:g_cvarPointsKillBonusCt;
new Handle:g_cvarPointsKillBonusTr;
new Handle:g_cvarPointsKillBonusDifCt;
new Handle:g_cvarPointsKillBonusDifTr;
new Handle:g_cvarPointsStart;
new Handle:g_cvarPointsKnifeMultiplier;
new Handle:g_cvarPointsTaserMultiplier;
new Handle:g_cvarPointsTrRoundWin;
new Handle:g_cvarPointsCtRoundWin;
new Handle:g_cvarPointsMvpCt;
new Handle:g_cvarPointsMvpTr;
new Handle:g_cvarMinimalKills;
new Handle:g_cvarPercentPointsLose;
new Handle:g_cvarPointsLoseRoundCeil;
new Handle:g_cvarShowRankAll;
new Handle:g_cvarResetOwnRank;
new Handle:g_cvarMinimumPlayers;
new Handle:g_cvarVipEnabled;
new Handle:g_cvarPointsLoseTk;
new Handle:g_cvarPointsLoseSuicide;
new Handle:g_cvarShowBotsOnRank;
new Handle:g_cvarRankBy;
new Handle:g_cvarFfa;
new Handle:g_cvarMysql;
new Handle:g_cvarGatherStats;
new Handle:g_cvarDaysToNotShowOnRank;
new Handle:g_cvarRankMode;
new Handle:g_cvarSQLTable;
new Handle:g_cvarChatTriggers;

new bool:g_bEnabled;
new bool:g_bResetOwnRank;
new bool:g_bChatChange;
new bool:g_bRankBots;
new bool:g_bPointsLoseRoundCeil;
new bool:g_bShowRankAll;
new bool:g_bVipEnabled;
new bool:g_bShowBotsOnRank;
new bool:g_bFfa;
new bool:g_bMysql;
new bool:g_bGatherStats;
new bool:g_bDumpDB;
new bool:g_bChatTriggers;
new g_RankBy;
new g_PointsBombDefusedTeam;
new g_PointsBombDefusedPlayer;
new g_PointsBombPlantedTeam;
new g_PointsBombPlantedPlayer;
new g_PointsBombExplodeTeam;
new g_PointsBombExplodePlayer;
new g_PointsBombPickup;
new g_PointsBombDropped;
new g_PointsHostageRescTeam;
new g_PointsHostageRescPlayer;
new g_PointsHs;
// Size = 4 -> for using client team for points
new g_PointsKill[4];
new g_PointsKillBonus[4];
new g_PointsKillBonusDif[4];
new g_PointsMvpTr;
new g_PointsMvpCt;
new g_MinimalKills;
new g_PointsStart;
new Float:g_fPointsKnifeMultiplier;
new Float:g_fPointsTaserMultiplier;
new Float:g_fPercentPointsLose;
new g_PointsRoundWin[4];
new g_MinimumPlayers;
new g_PointsLoseTk;
new g_PointsLoseSuicide;
new g_PointsVipEscapedTeam;
new g_PointsVipEscapedPlayer;
new g_PointsVipKilledTeam;
new g_PointsVipKilledPlayer;
new g_DaysToNotShowOnRank;
new g_RankMode;
new String:g_sSQLTable[100];
new Handle:g_hStatsDb;
new bool:OnDB[MAXPLAYERS+1];
new g_aSession[MAXPLAYERS+1][STATS_NAMES];
new g_aStats[MAXPLAYERS+1][STATS_NAMES];
new g_aWeapons[MAXPLAYERS+1][WEAPONS_ENUM];
new g_aHitBox[MAXPLAYERS+1][HITBOXES];
new g_TotalPlayers;

new Handle:g_fwdOnPlayerLoaded;
new Handle:g_fwdOnPlayerSaved;

new bool:DEBUGGING=false;
new g_C4PlantedBy;
new String:g_sC4PlantedByName[MAX_NAME_LENGTH];

// Preventing duplicates
new String:g_aClientSteam[MAXPLAYERS+1][64]; 
new String:g_aClientName[MAXPLAYERS+1][MAX_NAME_LENGTH];
new String:g_aClientIp[MAXPLAYERS+1][64]; 

#include rankme/cmds

public Plugin:myinfo = {
	name = "RankMe",
	author = "lok1, Scooby",
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public OnPluginStart(){
	
	//LoadTranslations("common.phrases");
	
	// CREATE CVARS
	g_cvarEnabled = CreateConVar("rankme_enabled","1","Is RankMe enabled? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarRankbots = CreateConVar("rankme_rankbots","0","Rank bots? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarAutopurge = CreateConVar("rankme_autopurge","0","Auto-Purge inactive players? X = Days  0 = Off",_,true,0.0);
	g_cvarPointsBombDefusedTeam = CreateConVar("rankme_points_bomb_defused_team","2","How many points CTs got for defusing the C4?",_,true,0.0);
	g_cvarPointsBombDefusedPlayer = CreateConVar("rankme_points_bomb_defused_player","2","How many points the CT who defused got additional?",_,true,0.0);
	g_cvarPointsBombPlantedTeam = CreateConVar("rankme_points_bomb_planted_team","2","How many points TRs got for planting the C4?",_,true,0.0);
	g_cvarPointsBombPlantedPlayer = CreateConVar("rankme_points_bomb_planted_player","2","How many points the TR who planted got additional?",_,true,0.0);
	g_cvarPointsBombExplodeTeam = CreateConVar("rankme_points_bomb_exploded_team","2","How many points TRs got for exploding the C4?",_,true,0.0);
	g_cvarPointsBombExplodePlayer = CreateConVar("rankme_points_bomb_exploded_player","2","How many points the TR who planted got additional?",_,true,0.0);
	g_cvarPointsHostageRescTeam = CreateConVar("rankme_points_hostage_rescued_team","2","How many points CTs got for rescuing the hostage?",_,true,0.0);
	g_cvarPointsHostageRescPlayer = CreateConVar("rankme_points_hostage_rescued_player","2","How many points the CT who rescued got additional?",_,true,0.0);
	g_cvarPointsHs = CreateConVar("rankme_points_hs","1","How many additional points a player got for a HeadShot?",_,true,0.0);
	g_cvarPointsKillCt = CreateConVar("rankme_points_kill_ct","2","How many points a CT got for killing?",_,true,0.0);
	g_cvarPointsKillTr = CreateConVar("rankme_points_kill_tr","2","How many points a TR got for killing?",_,true,0.0);
	g_cvarPointsKillBonusCt = CreateConVar("rankme_points_kill_bonus_ct","1","How many points a CT got for killing additional by the diffrence of points?",_,true,0.0);
	g_cvarPointsKillBonusTr = CreateConVar("rankme_points_kill_bonus_tr","1","How many points a TR got for killing additional by the diffrence of points?",_,true,0.0);
	g_cvarPointsKillBonusDifCt = CreateConVar("rankme_points_kill_bonus_dif_ct","100","How many points of diffrence is needed for a CT to got the bonus?",_,true,0.0);
	g_cvarPointsKillBonusDifTr = CreateConVar("rankme_points_kill_bonus_dif_tr","100","How many points of diffrence is needed for a TR to got the bonus?",_,true,0.0);
	g_cvarPointsCtRoundWin = CreateConVar("rankme_points_ct_round_win","0","How many points an alive CT got for winning the round?",_,true,0.0);
	g_cvarPointsTrRoundWin = CreateConVar("rankme_points_tr_round_win","0","How many points an alive TR got for winning the round?",_,true,0.0);
	g_cvarPointsKnifeMultiplier = CreateConVar("rankme_points_knife_multiplier","2.0","Multiplier of points by knife",_,true,0.0);
	g_cvarPointsTaserMultiplier = CreateConVar("rankme_points_taser_multiplier","2.0","Multiplier of points by taser",_,true,0.0);
	g_cvarPointsStart = CreateConVar("rankme_points_start","1000","Starting points",_,true,0.0);
	g_cvarMinimalKills = CreateConVar("rankme_minimal_kills","0","Minimal kills for entering the rank",_,true,0.0);
	g_cvarPercentPointsLose = CreateConVar("rankme_percent_points_lose","1.0","Multiplier of losing points. (WARNING: MAKE SURE TO INPUT IT AS FLOAT) 1.0 equals lose same amount as won by the killer, 0.0 equals no lose",_,true,0.0);
	g_cvarPointsLoseRoundCeil = CreateConVar("rankme_points_lose_round_ceil","1","If the points is f1oat, round it to next the highest or lowest? 1 = highest 0 = lowest",_,true,0.0,true,1.0);
	g_cvarChatChange = CreateConVar("rankme_changes_chat","1","Show points changes on chat? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarShowRankAll = CreateConVar("rankme_show_rank_all","0","When rank command is used, show for all the rank of the player? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarShowBotsOnRank = CreateConVar("rankme_show_bots_on_rank","0","Show bots on rank/top/etc? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarResetOwnRank = CreateConVar("rankme_resetownrank","0","Allow player to reset his own rank? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarMinimumPlayers = CreateConVar("rankme_minimumplayers","2","Minimum players to start giving points",_,true,0.0);
	g_cvarVipEnabled = CreateConVar("rankme_vip_enabled","0","Show AS_ maps statiscs (VIP mod) on statsme and session?",_,true,0.0,true,1.0);
	g_cvarPointsVipEscapedTeam = CreateConVar("rankme_points_vip_escaped_team","2","How many points CTs got helping the VIP to escaping?",_,true,0.0);
	g_cvarPointsVipEscapedPlayer = CreateConVar("rankme_points_vip_escaped_player","2","How many points the VIP got for escaping?",_,true,0.0);
	g_cvarPointsVipKilledTeam = CreateConVar("rankme_points_vip_killed_team","2","How many points TRs got for killing the VIP?",_,true,0.0);
	g_cvarPointsVipKilledPlayer = CreateConVar("rankme_points_vip_killed_player","2","How many points the TR who killed the VIP got additional?",_,true,0.0);
	g_cvarPointsLoseTk = CreateConVar("rankme_points_lose_tk","0","How many points a player lose for Team Killing?",_,true,0.0);
	g_cvarPointsLoseSuicide = CreateConVar("rankme_points_lose_suicide","0","How many points a player lose for Suiciding?",_,true,0.0);
	g_cvarRankBy = CreateConVar("rankme_rank_by","0","Rank players by? 0 = STEAM:ID 1 = Name 2 = IP",_,true,0.0,true,2.0);
	g_cvarFfa = CreateConVar("rankme_ffa","0","Free-For-All (FFA) mode? 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarMysql = CreateConVar("rankme_mysql","0","Using MySQL? 1 = true 0 = false (SQLite)",_,true,0.0,true,1.0);
	g_cvarDumpDB = CreateConVar("rankme_dump_db","0","Dump the Database to SQL file? (required to be 1 if using the web interface and SQLite, case MySQL, it won't be dumped) 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarGatherStats = CreateConVar("rankme_gather_stats","1","Gather Statistics (a.k.a count points)? (turning this off won't disallow to see the stats already gathered) 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarDaysToNotShowOnRank = CreateConVar("rankme_days_to_not_show_on_rank","0","Days inactive to not be shown on rank? X = days 0 = off",_,true,0.0);
	g_cvarRankMode = CreateConVar("rankme_rank_mode","1","Rank by what? 1 = by points 2 = by KDR ",_,true,1.0,true,2.0);
	g_cvarSQLTable = CreateConVar("rankme_sql_table","rankme","The name of the table that will be used. (Max: 100)");
	g_cvarChatTriggers = CreateConVar("rankme_chat_triggers","1","Enable (non-command) chat triggers. (e.g: rank, statsme, top) Recommended to be set to 0 when running with EventScripts for avoiding double responses. 1 = true 0 = false",_,true,0.0,true,1.0);
	g_cvarPointsMvpCt = CreateConVar("rankme_points_mvp_ct","1","How many points a CT got for being the MVP?",_,true,0.0);
	g_cvarPointsMvpTr = CreateConVar("rankme_points_mvp_tr","1","How many points a TR got for being the MVP?",_,true,0.0);
	g_cvarPointsBombPickup = CreateConVar("rankme_points_bomb_pickup","0","How many points a player gets for picking up the bomb?",_,true,0.0);
	g_cvarPointsBombDropped = CreateConVar("rankme_points_bomb_dropped","0","How many points a player loess for dropping the bomb?",_,true,0.0);
	
	// LOAD RANKME.CFG
	AutoExecConfig(true,"rankme");
	
	// CVAR HOOK
	HookConVarChange(g_cvarEnabled,OnConVarChanged);
	HookConVarChange(g_cvarChatChange,OnConVarChanged);
	HookConVarChange(g_cvarShowBotsOnRank,OnConVarChanged);
	HookConVarChange(g_cvarShowRankAll,OnConVarChanged);
	HookConVarChange(g_cvarResetOwnRank,OnConVarChanged);
	HookConVarChange(g_cvarMinimumPlayers,OnConVarChanged);
	HookConVarChange(g_cvarRankbots,OnConVarChanged);
	HookConVarChange(g_cvarAutopurge,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombDefusedTeam,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombDefusedPlayer,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombPlantedTeam,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombPlantedPlayer,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombExplodeTeam,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombExplodePlayer,OnConVarChanged);
	HookConVarChange(g_cvarPointsHostageRescTeam,OnConVarChanged);
	HookConVarChange(g_cvarPointsHostageRescPlayer,OnConVarChanged);
	HookConVarChange(g_cvarPointsHs,OnConVarChanged);
	HookConVarChange(g_cvarPointsKillCt,OnConVarChanged);
	HookConVarChange(g_cvarPointsKillTr,OnConVarChanged);
	HookConVarChange(g_cvarPointsKillBonusCt,OnConVarChanged);
	HookConVarChange(g_cvarPointsKillBonusTr,OnConVarChanged);
	HookConVarChange(g_cvarPointsKillBonusDifCt,OnConVarChanged);
	HookConVarChange(g_cvarPointsKillBonusDifTr,OnConVarChanged);
	HookConVarChange(g_cvarPointsCtRoundWin,OnConVarChanged);
	HookConVarChange(g_cvarPointsTrRoundWin,OnConVarChanged);
	HookConVarChange(g_cvarPointsKnifeMultiplier,OnConVarChanged);
	HookConVarChange(g_cvarPointsTaserMultiplier,OnConVarChanged);
	HookConVarChange(g_cvarPointsStart,OnConVarChanged);
	HookConVarChange(g_cvarMinimalKills,OnConVarChanged);
	HookConVarChange(g_cvarPercentPointsLose,OnConVarChanged);
	HookConVarChange(g_cvarPointsLoseRoundCeil,OnConVarChanged);
	HookConVarChange(g_cvarVipEnabled,OnConVarChanged);
	HookConVarChange(g_cvarPointsVipEscapedTeam,OnConVarChanged);
	HookConVarChange(g_cvarPointsVipEscapedPlayer,OnConVarChanged);
	HookConVarChange(g_cvarPointsVipKilledTeam,OnConVarChanged);
	HookConVarChange(g_cvarPointsVipKilledPlayer,OnConVarChanged);
	HookConVarChange(g_cvarPointsLoseTk,OnConVarChanged);
	HookConVarChange(g_cvarPointsLoseSuicide,OnConVarChanged);
	HookConVarChange(g_cvarRankBy,OnConVarChanged);
	HookConVarChange(g_cvarFfa,OnConVarChanged);
	HookConVarChange(g_cvarDumpDB,OnConVarChanged);
	HookConVarChange(g_cvarGatherStats,OnConVarChanged);
	HookConVarChange(g_cvarDaysToNotShowOnRank,OnConVarChanged);
	HookConVarChange(g_cvarRankMode,OnConVarChanged);
	HookConVarChange(g_cvarMysql,OnConVarChanged_MySQL);
	HookConVarChange(g_cvarSQLTable,OnConVarChanged_SQLTable);
	HookConVarChange(g_cvarChatTriggers,OnConVarChanged);
	HookConVarChange(g_cvarPointsMvpCt,OnConVarChanged);
	HookConVarChange(g_cvarPointsMvpTr,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombPickup,OnConVarChanged);
	HookConVarChange(g_cvarPointsBombDropped,OnConVarChanged);
	
	// LOAD TRANSLATIONS
	LoadTranslations("rankme.phrases");
	
	// EVENTS
	HookEventEx("player_death",	EventPlayerDeath);
	HookEventEx("player_spawn",	EventPlayerSpawn);
	HookEventEx("player_hurt",	EventPlayerHurt);
	HookEventEx("weapon_fire", EventWeaponFire);
	HookEventEx( "bomb_planted", Event_BombPlanted );
	HookEventEx( "bomb_defused", Event_BombDefused );
	HookEventEx( "bomb_exploded", Event_BombExploded );
	HookEventEx( "bomb_dropped", Event_BombDropped );
	HookEventEx( "bomb_pickup", Event_BombPickup );
	HookEventEx( "hostage_rescued", Event_HostageRescued );
	HookEventEx( "vip_killed", Event_VipKilled );
	HookEventEx( "vip_escaped", Event_VipEscaped );
	HookEventEx("round_end", Event_RoundEnd);
	HookEventEx("round_mvp", Event_RoundMVP);
	HookEventEx("player_changename", OnClientChangeName, EventHookMode_Pre);
	
	// ADMNIN COMMANDS
	RegAdminCmd("sm_resetrank",CMD_ResetRank,ADMFLAG_ROOT,"RankMe: Resets the rank of a player");
	RegAdminCmd("sm_rankme_remove_duplicate",CMD_Duplicate,ADMFLAG_ROOT, "RankMe: Removes the duplicated rows on the database");
	RegAdminCmd("sm_rankpurge",CMD_Purge,ADMFLAG_ROOT, "RankMe: Purges from the rank players that didn't connected for X days");
	RegAdminCmd("sm_resetrank_all",CMD_ResetRankAll,ADMFLAG_ROOT,"RankMe: Resets the rank of all players");
	//RegAdminCmd("sm_rankme_import_mani",CMD_ManiImport,ADMFLAG_ROOT, "RankMe: Imports the Mani's rank data to RankMe");
	RegAdminCmd("sm_statsme2",CMD_StatsMe2,ADMFLAG_GENERIC, "RankMe: Shows the stats from a player");
	
	// PLAYER COMMANDS
	RegConsoleCmd("sm_session",CMD_Session,"RankMe: Shows the stats of your current session");
	RegConsoleCmd("sm_rank",CMD_Rank, "RankMe: Shows your rank");
	RegConsoleCmd("sm_top",CMD_Top, "RankMe: Shows the TOP");
	RegConsoleCmd("sm_topknife",CMD_TopKnife,"RankMe: Shows the TOP ordered by knife kills");
	RegConsoleCmd("sm_toptaser",CMD_TopTaser,"RankMe: Shows the TOP ordered by taser kills");
	RegConsoleCmd("sm_topnade",CMD_TopNade, "RankMe: Shows the TOP ordered by grenade kills");
	RegConsoleCmd("sm_topweapon",CMD_TopWeapon, "RankMe: Shows the TOP ordered by kills with a specific weapon");
	RegConsoleCmd("sm_topacc",CMD_TopAcc, "RankMe: Shows the TOP ordered by accuracy");
	RegConsoleCmd("sm_tophs",CMD_TopHS, "RankMe: Shows the TOP ordered by HeadShots");
	RegConsoleCmd("sm_toptime",CMD_TopTime, "RankMe: Shows the TOP ordered by Connected Time");
	RegConsoleCmd("sm_topkills",CMD_TopKills, "RankMe: Shows the TOP ordered by kills");
	RegConsoleCmd("sm_topdeaths",CMD_TopDeaths, "RankMe: Shows the TOP ordered by deaths");
	RegConsoleCmd("sm_hitboxme",CMD_HitBox,"RankMe: Shows the HitBox stats");
	RegConsoleCmd("sm_weaponme",CMD_WeaponMe,"RankMe: Shows the kills with each weapon");
	RegConsoleCmd("sm_resetmyrank",CMD_ResetOwnRank, "RankMe: Resets your own rank");
	RegConsoleCmd("sm_statsme",CMD_StatsMe, "RankMe: Shows your stats");
	RegConsoleCmd("sm_next",CMD_Next, "RankMe: Shows the next 9 players above you on the TOP");
	
	RegConsoleCmd("sm_rankme",CMD_RankMe, "RankMe: Shows a menu with the basic commands");

	//	Hook the say and say_team for chat triggers
	AddCommandListener(OnSayText, "say");
	AddCommandListener(OnSayText, "say_team");
	
	new Handle:cvarVersion = CreateConVar("rankme_version",PLUGIN_VERSION,"RankMe Version",FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	// UPDATE THE CVAR IF NEEDED
	new String:sVersionOnCvar[10];
	GetConVarString(cvarVersion,sVersionOnCvar,sizeof(sVersionOnCvar));
	if(!StrEqual(PLUGIN_VERSION,sVersionOnCvar))
		SetConVarString(cvarVersion,PLUGIN_VERSION,true,true);
	
	// Create the forwards
	g_fwdOnPlayerLoaded = CreateGlobalForward("RankMe_OnPlayerLoaded",ET_Hook,Param_Cell);
	g_fwdOnPlayerSaved = CreateGlobalForward("RankMe_OnPlayerSaved",ET_Hook,Param_Cell);
	
}

public OnConVarChanged_SQLTable(Handle:convar, const String:oldValue[], const String:newValue[]){
	
	GetConVarString(g_cvarSQLTable,g_sSQLTable,sizeof(g_sSQLTable));
	DB_Connect(true); // Force reloading the stats
}

public OnConVarChanged_MySQL(Handle:convar, const String:oldValue[], const String:newValue[]){
	DB_Connect(false);
}

public DB_Connect(bool:firstload){
	
	if(g_bMysql != GetConVarBool(g_cvarMysql) || firstload){ // NEEDS TO CONNECT IF CHANGED MYSQL CVAR OR NEVER CONNECTED
		g_bMysql = GetConVarBool(g_cvarMysql);
		GetConVarString(g_cvarSQLTable,g_sSQLTable,sizeof(g_sSQLTable));
		decl String:sError[256];
		if(g_bMysql){
			g_hStatsDb = SQL_Connect("rankme", false, sError, sizeof(sError));
		} else {
			g_hStatsDb = SQLite_UseDatabase("rankme",sError,sizeof(sError));
		}
		if(g_hStatsDb == INVALID_HANDLE)
		{
			SetFailState("[RankMe] Unable to connect to the database (%s)",sError);
		}
		SQL_LockDatabase(g_hStatsDb);
		new String:sQuery[1200];
		Format(sQuery,sizeof(sQuery),g_sSqlCreate,g_sSQLTable);
		SQL_FastQuery(g_hStatsDb,sQuery);
		Format(sQuery,sizeof(sQuery),"ALTER TABLE `%s` MODIFY id INTEGER AUTO_INCREMENT",g_sSQLTable);
		SQL_FastQuery(g_hStatsDb,sQuery);
		Format(sQuery,sizeof(sQuery),"ALTER TABLE `%s` ADD COLUMN vip_killed NUMERIC",g_sSQLTable);
		SQL_FastQuery(g_hStatsDb,sQuery);
		Format(sQuery,sizeof(sQuery),"ALTER TABLE `%s` ADD COLUMN vip_escaped NUMERIC",g_sSQLTable);
		SQL_FastQuery(g_hStatsDb,sQuery);
		Format(sQuery,sizeof(sQuery),"ALTER TABLE `%s` ADD COLUMN vip_played NUMERIC",g_sSQLTable);
		SQL_FastQuery(g_hStatsDb,sQuery);
		SQL_UnlockDatabase(g_hStatsDb);

		for(new i=1;i<=MaxClients;i++){
			if(IsClientInGame(i))
				OnClientPutInServer(i);
		}
	}

}
public OnConfigsExecuted(){
	
	if(g_hStatsDb == INVALID_HANDLE)
		DB_Connect(true);
	else
		DB_Connect(false);
	new AutoPurge = GetConVarInt(g_cvarAutopurge);
	new String:sQuery[500];
	if(AutoPurge > 0){
		new DeleteBefore = GetTime() - (AutoPurge*86400);
		Format(sQuery,sizeof(sQuery),"DELETE FROM `%s` WHERE lastconnect < '%d'",g_sSQLTable,DeleteBefore);
		SQL_TQuery(g_hStatsDb,SQL_PurgeCallback,sQuery);
	}
	
	g_bShowBotsOnRank = GetConVarBool(g_cvarShowBotsOnRank);
	g_RankBy = GetConVarInt(g_cvarRankBy);
	g_bEnabled = GetConVarBool(g_cvarEnabled);
	g_bChatChange = GetConVarBool(g_cvarChatChange);
	g_bShowRankAll = GetConVarBool(g_cvarShowRankAll);
	g_bRankBots = GetConVarBool(g_cvarRankbots);
	g_bFfa = GetConVarBool(g_cvarFfa);
	g_bDumpDB = GetConVarBool(g_cvarDumpDB);
	g_PointsBombDefusedTeam = GetConVarInt(g_cvarPointsBombDefusedTeam);
	g_PointsBombDefusedPlayer = GetConVarInt(g_cvarPointsBombDefusedPlayer);
	g_PointsBombPlantedTeam = GetConVarInt(g_cvarPointsBombPlantedTeam);
	g_PointsBombPlantedPlayer = GetConVarInt(g_cvarPointsBombPlantedPlayer);
	g_PointsBombExplodeTeam = GetConVarInt(g_cvarPointsBombExplodeTeam);
	g_PointsBombExplodePlayer = GetConVarInt(g_cvarPointsBombExplodePlayer);
	g_PointsHostageRescTeam = GetConVarInt(g_cvarPointsHostageRescTeam);
	g_PointsHostageRescPlayer = GetConVarInt(g_cvarPointsHostageRescPlayer);
	g_PointsHs = GetConVarInt(g_cvarPointsHs);
	g_PointsKill[CT] = GetConVarInt(g_cvarPointsKillCt);
	g_PointsKill[TR] = GetConVarInt(g_cvarPointsKillTr);
	g_PointsKillBonus[CT] = GetConVarInt(g_cvarPointsKillBonusCt);
	g_PointsKillBonus[TR] = GetConVarInt(g_cvarPointsKillBonusTr);
	g_PointsKillBonusDif[CT] = GetConVarInt(g_cvarPointsKillBonusDifCt);
	g_PointsKillBonusDif[TR] = GetConVarInt(g_cvarPointsKillBonusDifTr);
	g_PointsStart = GetConVarInt(g_cvarPointsStart);
	g_fPointsKnifeMultiplier = GetConVarFloat(g_cvarPointsKnifeMultiplier);
	g_fPointsTaserMultiplier = GetConVarFloat(g_cvarPointsTaserMultiplier);
	g_PointsRoundWin[TR] = GetConVarInt(g_cvarPointsTrRoundWin);
	g_PointsRoundWin[CT] = GetConVarInt(g_cvarPointsCtRoundWin);
	g_MinimalKills = GetConVarInt(g_cvarMinimalKills);
	g_fPercentPointsLose = GetConVarFloat(g_cvarPercentPointsLose);
	g_bPointsLoseRoundCeil = GetConVarBool(g_cvarPointsLoseRoundCeil);
	g_MinimumPlayers = GetConVarInt(g_cvarMinimumPlayers);
	g_bResetOwnRank = GetConVarBool(g_cvarResetOwnRank);
	g_PointsVipEscapedTeam = GetConVarInt(g_cvarPointsVipEscapedTeam);
	g_PointsVipEscapedPlayer = GetConVarInt(g_cvarPointsVipEscapedPlayer);
	g_PointsVipKilledTeam = GetConVarInt(g_cvarPointsVipKilledTeam);
	g_PointsVipKilledPlayer = GetConVarInt(g_cvarPointsVipKilledPlayer);
	g_bVipEnabled = GetConVarBool(g_cvarVipEnabled);
	g_PointsLoseTk = GetConVarInt(g_cvarPointsLoseTk);
	g_PointsLoseSuicide = GetConVarInt(g_cvarPointsLoseSuicide);
	g_DaysToNotShowOnRank = GetConVarInt(g_cvarDaysToNotShowOnRank);
	g_bGatherStats = GetConVarBool(g_cvarGatherStats);
	g_RankMode = GetConVarInt(g_cvarRankMode);
	g_bChatTriggers = GetConVarBool(g_cvarChatTriggers);
	g_PointsMvpCt = GetConVarInt(g_cvarPointsMvpCt);
	g_PointsMvpTr = GetConVarInt(g_cvarPointsMvpTr);
	g_PointsBombDropped = GetConVarInt(g_cvarPointsBombDropped);
	g_PointsBombPickup = GetConVarInt(g_cvarPointsBombPickup);
	
	if(g_bRankBots)
		Format(sQuery,sizeof(sQuery),"SELECT * FROM `%s` WHERE kills >= '%d'",g_sSQLTable,g_MinimalKills);
	else
		Format(sQuery,sizeof(sQuery),"SELECT * FROM `%s` WHERE kills >= '%d' AND steam <> 'BOT'",g_sSQLTable,g_MinimalKills);
		
	SQL_TQuery(g_hStatsDb,SQL_GetPlayersCallback,sQuery);
	
}
public Action:CMD_Duplicate(client,args){
	new String:sQuery[400];
	
	if(g_bMysql){
	
		if(g_RankBy == 0)
			Format(sQuery,sizeof(sQuery),g_sSqlRemoveDuplicateMySQL,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable);
			
		else if(g_RankBy == 1)
			Format(sQuery,sizeof(sQuery),g_sSqlRemoveDuplicateNameMySQL,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable);
		
		else if(g_RankBy == 2)
			Format(sQuery,sizeof(sQuery),g_sSqlRemoveDuplicateIpMySQL,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable);
	
	} else {
	
		if(g_RankBy == 0)
			Format(sQuery,sizeof(sQuery),g_sSqlRemoveDuplicateSQLite,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable);
			
		else if(g_RankBy == 1)
			Format(sQuery,sizeof(sQuery),g_sSqlRemoveDuplicateNameSQLite,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable);
		
		else if(g_RankBy == 2)
			Format(sQuery,sizeof(sQuery),g_sSqlRemoveDuplicateIpSQLite,g_sSQLTable,g_sSQLTable,g_sSQLTable,g_sSQLTable);
			
	}
	
	SQL_TQuery(g_hStatsDb,SQL_DuplicateCallback,sQuery,client);
	
	return Plugin_Handled;
}

public SQL_DuplicateCallback(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	
	PrintToServer("[RankMe]: %d duplicated rows removed",SQL_GetAffectedRows(owner));
	if(client != 0){
		PrintToChat(client,"[RankMe]: %d duplicated rows removed",SQL_GetAffectedRows(owner));
	}
	//LogAction(-1,-1,"[RankMe]: %d players purged by inactivity",SQL_GetAffectedRows(owner));
	
}
/*
public Action:CMD_ManiImport(client,args){
	new String:sFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFile, sizeof(sFile), "../../cfg/mani_admin_plugin/data/mani_ranks.txt");
	new Handle:hFile = OpenFile(sFile,"r");
	new String:sBuffer[600];
	new String:aData[74][MAX_NAME_LENGTH];
	new String:sQuery[1500];
	while (!IsEndOfFile(hFile)){
		sBuffer = "";
		ReadFileLine(hFile,sBuffer,sizeof(sBuffer));
		
		
		if(StrContains(sBuffer,"/") == 0 || strlen(sBuffer) == 0){} else {
			ExplodeString(sBuffer,",",aData,74,MAX_NAME_LENGTH);
			Format(sQuery,sizeof(sQuery),"INSERT INTO `%s` (id,steam,name,lastip,score) SELECT NULL,'%s','%s','%s','%d' FROM `%s` WHERE NOT EXISTS (SELECT 1 FROM `%s` WHERE steam = '%s') LIMIT 1",g_sSQLTable,aData[0],aData[64],aData[01],g_PointsStart,g_sSQLTable,g_sSQLTable,aData[0]);
			//Format(sQuery,sizeof(sQuery),"INSERT INTO `%s` (id,steam,name,lastip,score) SELECT NULL,'%s','%s','%s','%d' WHERE NOT EXISTS (SELECT 1 FROM `%s` WHERE steam = '%s')",g_sSQLTable,aData[0],aData[64],aData[01],g_PointsStart,g_sSQLTable,aData[0]);
			
			ReplaceString(sQuery,sizeof(sQuery),"\n","");
			SQL_TQuery(g_hStatsDb,SQL_NothingCallback,sQuery);
		
			client =0;
			
			new String:sWeaponsQuery[500] = "";
			
			g_aWeapons[client][0]=StringToInt(aData[29]);
			g_aWeapons[client][1]=StringToInt(aData[37]);
			g_aWeapons[client][2]=StringToInt(aData[24]);
			g_aWeapons[client][3]=StringToInt(aData[45]);
			g_aWeapons[client][4]=StringToInt(aData[25]);
			g_aWeapons[client][5]=StringToInt(aData[42]);
			g_aWeapons[client][6]=StringToInt(aData[44]);
			g_aWeapons[client][7]=StringToInt(aData[33]);
			g_aWeapons[client][8]=StringToInt(aData[28]);
			g_aWeapons[client][9]=StringToInt(aData[43]);
			g_aWeapons[client][10]=StringToInt(aData[38]);
			g_aWeapons[client][11]=StringToInt(aData[22]);
			g_aWeapons[client][12]=StringToInt(aData[39]);
			g_aWeapons[client][13]=StringToInt(aData[40]);
			g_aWeapons[client][14]=StringToInt(aData[32]);
			g_aWeapons[client][15]=StringToInt(aData[20]);
			g_aWeapons[client][16]=StringToInt(aData[31]);
			g_aWeapons[client][17]=StringToInt(aData[36]);
			g_aWeapons[client][18]=StringToInt(aData[21]);
			g_aWeapons[client][19]=StringToInt(aData[26]);
			g_aWeapons[client][20]=StringToInt(aData[34]);
			g_aWeapons[client][21]=StringToInt(aData[35]);
			g_aWeapons[client][22]=StringToInt(aData[23]);
			g_aWeapons[client][23]=StringToInt(aData[30]);
			g_aWeapons[client][24]=StringToInt(aData[41]);
			g_aWeapons[client][25]=StringToInt(aData[27]);
			g_aWeapons[client][26]=StringToInt(aData[46]);
			g_aWeapons[client][27]=StringToInt(aData[47]);
			for(new i=0;i<=36;i++){
				Format(sWeaponsQuery,sizeof(sWeaponsQuery),"%s,%s='%d'",sWeaponsQuery,g_sWeaponsNamesGame[i],g_aWeapons[client][i]);
			}
			Format(sQuery,sizeof(sQuery),"UPDATE `%s` SET score = '%s', kills = '%s', deaths='%s',suicides='%s',tk='%s',shots='%s',hits='%s',headshots='%s', rounds_tr = '%d', rounds_ct = '%d',lastip='%s',name='%s'%s,head='%s',chest='%s', stomach='%s',left_arm='%s',right_arm='%s',left_leg='%s',right_leg='%s',c4_planted='%s',c4_exploded='%s',c4_defused='%s',ct_win='%s',tr_win='%s', hostages_rescued='%s',vip_killed = '%s',vip_escaped = '%s',vip_played = '%s', lastconnect='%i', connected='%i' WHERE steam = '%s';",g_sSQLTable,aData[04],aData[07],aData[5],aData[8],aData[9],aData[57],aData[58],aData[06],StringToInt(aData[71])+StringToInt(aData[72]),StringToInt(aData[69])+StringToInt(aData[70]),aData[01],aData[73],sWeaponsQuery,aData[13],aData[14],aData[15],aData[16],aData[17],aData[18],aData[19],aData[59],aData[64],aData[60],aData[69],aData[71],aData[61],aData[68],aData[67],aData[67],StringToInt(aData[2]),StringToInt(aData[10]),aData[0]);
			ReplaceString(sQuery,sizeof(sQuery),"\n","");
			SQL_TQuery(g_hStatsDb,SQL_NothingCallback,sQuery);

		}
		
	}
	for(new d=1;d<=MaxClients;d++){
		if(IsClientInGame(d))
			OnClientPutInServer(d);
	}
}*/
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("RankMe_GivePoint", Native_GivePoint);
	CreateNative("RankMe_GetRank", Native_GetRank);
	CreateNative("RankMe_GetPoints", Native_GetPoints);
	CreateNative("RankMe_GetStats", Native_GetStats);
	CreateNative("RankMe_GetSession", Native_GetSession);
	CreateNative("RankMe_GetWeaponStats", Native_GetWeaponStats);
	CreateNative("RankMe_GetHitbox", Native_GetHitbox);
	
	RegPluginLibrary("rankme");
	
	return APLRes_Success;
}
public Native_GivePoint(Handle:plugin, numParams)
{
	new iClient = GetNativeCell(1);
	new iPoints = GetNativeCell(2);

	new len;
	GetNativeStringLength(3, len);
	
	if (len <= 0)
	{
		return;
	}
	
	
	new String:Reason[len+1];
	new String:Name[MAX_NAME_LENGTH];
	GetNativeString(3, Reason, len+1);
	new iPrintToPlayer=GetNativeCell(4);
	new iPrintToAll=GetNativeCell(5);
	g_aStats[iClient][SCORE] += iPoints;
	g_aSession[iClient][SCORE] += iPoints;
	GetClientName(iClient,Name,sizeof(Name));
	if(!g_bChatChange)
		return;
	if(iPrintToAll == 1){
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				//CPrintToChatEx(i,i,"%s %t",MSG,"GotPointsBy",Name,g_aStats[iClient][SCORE],iPoints,Reason);
				CPrintToChat(i,"%s %t",MSG,"GotPointsBy",Name,g_aStats[iClient][SCORE],iPoints,Reason);
	} else if( iPrintToPlayer == 1) {
		//CPrintToChatEx(iClient,iClient,"%s %t",MSG,"GotPointsBy",Name,g_aStats[iClient][SCORE],iPoints,Reason);
		CPrintToChat(iClient,"%s %t",MSG,"GotPointsBy",Name,g_aStats[iClient][SCORE],iPoints,Reason);
	}
}

public Native_GetRank(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new Function:callback = GetNativeCell(2);
	new any:data = GetNativeCell(3);
	
	new Handle:pack = CreateDataPack();
	
	WritePackCell(pack, client);
	WritePackFunction(pack, callback);
	WritePackCell(pack, data);
	WritePackCell(pack, _:plugin);
	
	new String:query[500];
	MakeSelectQuery(query,sizeof(query));
	
	if(g_RankMode == 1)
		Format(query,sizeof(query),"%s ORDER BY score DESC",query);
	else if(g_RankMode == 2)
		Format(query,sizeof(query),"%s ORDER BY CAST(CAST(kills as float)/CAST (deaths as float) as float) DESC",query);	
		
	SQL_TQuery(g_hStatsDb, SQL_GetRankCallback, query, pack);
}

public SQL_GetRankCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pack = data;
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new Function:callback = Function:ReadPackFunction(pack);
	new any:args = ReadPackCell(pack);
	new Handle:plugin = Handle:ReadPackCell(pack);
	CloseHandle(pack);
	
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		CallRankCallback(0, 0, Function:callback, 0, plugin);
		return;
	}
	new i;
	g_TotalPlayers =SQL_GetRowCount(hndl);
	
	new String:Receive[64];
	
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		i++;
		
		if(g_RankBy==0){
			SQL_FetchString(hndl,1,Receive,sizeof(Receive));
			if(StrEqual(Receive,g_aClientSteam[client],false))
			{
				CallRankCallback(client, i, Function:callback, args, plugin);
				break;
			}
		} else if(g_RankBy==1){
			SQL_FetchString(hndl,2,Receive,sizeof(Receive));
			if(StrEqual(Receive,g_aClientName[client],false))
			{
				CallRankCallback(client, i, Function:callback, args, plugin);
				break;
			}
		} else if(g_RankBy==2){
			SQL_FetchString(hndl,3,Receive,sizeof(Receive));
			if(StrEqual(Receive,g_aClientIp[client],false))
			{
				CallRankCallback(client, i, Function:callback, args, plugin);
				break;
			}
		}
	}
}

CallRankCallback(client, rank, Function:callback, any:data, Handle:plugin)
{
	Call_StartFunction(plugin, callback);
	Call_PushCell(client);
	Call_PushCell(rank);
	Call_PushCell(data);
	Call_Finish();
	CloseHandle(plugin);
}

public Native_GetPoints(Handle:plugin, numParams)
{
	new Client = GetNativeCell(1);
	return g_aStats[Client][SCORE];
}

public Native_GetStats(Handle:plugin, numParams)
{
	new iClient = GetNativeCell(1);
	new array[20];
	for(new i=0;i<20;i++)
		array[i] = g_aStats[iClient][i];
	
	SetNativeArray(2,array,20);

}
public Native_GetSession(Handle:plugin, numParams)
{
	new iClient = GetNativeCell(1);
	new array[20];
	for(new i=0;i<20;i++)
		array[i] = g_aSession[iClient][i];
	
	SetNativeArray(2,array,20);
	
}

public Native_GetWeaponStats(Handle:plugin, numParams)
{
	new iClient = GetNativeCell(1);
	new array[37];
	for(new i=0;i<37;i++)
		array[i] = g_aWeapons[iClient][i];
	
	SetNativeArray(2,array,37);
	
}

public Native_GetHitbox(Handle:plugin, numParams)
{
	new iClient = GetNativeCell(1);
	new array[8];
	for(new i=0;i<8;i++)
		array[i] = g_aHitBox[iClient][i];
	
	SetNativeArray(2,array,8);
}


public DumpDB(){
	if(!g_bDumpDB || g_bMysql)
		return;
	new String:sQuery[500];
	Format(sQuery,sizeof(sQuery),"SELECT * from `%s`",g_sSQLTable);
	SQL_TQuery(g_hStatsDb,SQL_DumpCallback,sQuery);
}

public Action:OnClientChangeName(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!g_bEnabled) 
		return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!g_bRankBots && IsFakeClient(client)) 
		return Plugin_Continue;
	if(IsClientConnected(client))
	{
		decl String:clientnewname[MAX_NAME_LENGTH];
		GetEventString(event, "newname", clientnewname, sizeof(clientnewname));
		if(client==g_C4PlantedBy)
			strcopy(g_sC4PlantedByName,sizeof(g_sC4PlantedByName),clientnewname);
		decl String:Eclientnewname[MAX_NAME_LENGTH*2+1];
		SQL_EscapeString(g_hStatsDb,clientnewname,Eclientnewname,sizeof(Eclientnewname));
		
		//ReplaceString(clientnewname, sizeof(clientnewname), "'", "");
		new String:query[500];
		if(g_RankBy == 1){
			OnDB[client]=false;
			for(new i=0;i<=19;i++){
				g_aSession[client][i] = 0;
				g_aStats[client][i] = 0;
			}
			g_aStats[client][SCORE]=g_PointsStart;
			for(new i=0;i<=36;i++){
				g_aWeapons[client][i] = 0;
			}
			g_aSession[client][CONNECTED] = GetTime();
			
			strcopy(g_aClientName[client],MAX_NAME_LENGTH,clientnewname);
			
			Format(query,sizeof(query),g_sSqlRetrieveClientName,g_sSQLTable,Eclientnewname);
			if(DEBUGGING){
				PrintToServer(query);
				LogError("%s",query);
			}
			SQL_TQuery(g_hStatsDb,SQL_LoadPlayerCallback,query,client);
			
		} else {
			
			if(g_RankBy == 0)
				Format(query,sizeof(query),"UPDATE `%s` SET name='%s' WHERE steam = '%s';",g_sSQLTable,Eclientnewname,g_aClientSteam[client]);
			else
				Format(query,sizeof(query),"UPDATE `%s` SET name='%s' WHERE lastip = '%s';",g_sSQLTable,Eclientnewname,g_aClientIp[client]);
			
			SQL_TQuery(g_hStatsDb,SQL_NothingCallback,query);
		}
	}
	return Plugin_Continue;
}

// Code made by Antithasys
public Action:OnSayText(client, const String:command[], argc)
{
	if(!g_bEnabled || !g_bChatTriggers || client == SENDER_WORLD || IsChatTrigger()) 
	{ // Don't parse if plugin is disabled or if is from the console or a chat trigger (e.g: ! or /)
		return Plugin_Continue;
	}
	
	decl String:cpMessage[256];
	decl String:sWords[64][256];
	GetCmdArgString(cpMessage,sizeof(cpMessage)); // Get the message
	StripQuotes(cpMessage); // Text come inside quotes
	//ReplaceString(cpMessage,sizeof(cpMessage),"\"","");
	ExplodeString(cpMessage, " ", sWords, sizeof(sWords), sizeof(sWords[])); // Explode it for use at top, topknife, topnade and topweapon
	
	// Proccess the text
	if (StrEqual(cpMessage, "rank", false))
	{
		//LogToFile("rankme.debug.log","\"rank\" chat hook called by client %d.",client);
		CMD_Rank(client, 0);
	}
	else if (StrEqual(cpMessage, "statsme", false))
	{
		CMD_StatsMe(client, 0);
	}
	else if (StrEqual(cpMessage, "hitboxme", false))
	{
		CMD_HitBox(client,0);
	}
	else if (StrEqual(cpMessage, "weaponme", false))
	{
		CMD_WeaponMe(client,0);
	}
	else if (StrEqual(cpMessage, "session", false))
	{
		CMD_Session(client,0);
	}
	else if (StrEqual(cpMessage[0], "next", false))
	{
		CMD_Next(client, 0);
	}
	else if (StrContains(sWords[0], "topknife", false) == 0)
	{	
		if (strcmp(cpMessage, "topknife") == 0)
		{
			ShowTOPKnife(client, 0);
		} 
		else 
		{
			ShowTOPKnife(client, StringToInt(cpMessage[8]));
		}
	}
	else if (StrContains(sWords[0], "toptaser", false) == 0)
	{	
		if (strcmp(cpMessage, "toptaser") == 0)
		{
			ShowTOPTaser(client, 0);
		} 
		else 
		{
			ShowTOPTaser(client, StringToInt(cpMessage[8]));
		}
	}
	else if (StrContains(sWords[0], "topnade", false) == 0)
	{
		if (strcmp(cpMessage, "topnade") == 0)
		{
			ShowTOPNade(client, 0);
		}
		else
		{
			ShowTOPNade(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "tophs", false) == 0)
	{
		if (strcmp(cpMessage, "tophs") == 0)
		{
			ShowTopHS(client, 0);
		}
		else
		{
			ShowTopHS(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topkills", false) == 0)
	{
		if (strcmp(cpMessage, "topkills") == 0)
		{
			ShowTopKills(client, 0);
		}
		else
		{
			ShowTopKills(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topdeaths", false) == 0)
	{
		if (strcmp(cpMessage, "topdeaths") == 0)
		{
			ShowTopDeaths(client, 0);
		}
		else
		{
			ShowTopDeaths(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topacc", false) == 0)
	{
		if (strcmp(cpMessage, "topacc") == 0)
		{
			ShowTopAcc(client, 0);
		}
		else
		{
			ShowTopAcc(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "toptime", false) == 0)
	{
		if (strcmp(cpMessage, "toptime") == 0)
		{
			ShowTopTime(client, 0);
		}
		else
		{
			ShowTopTime(client, StringToInt(cpMessage[7]));
		}
	}
	else if (StrContains(sWords[0], "topweapon", false) == 0)
	{
		if (strcmp(cpMessage, "topweapon") == 0)
		{
			CMD_TopWeapon(client,0); // Build the menu on the next frame
		} 
		else 
		{
			if (GetWeaponNum(sWords[1]) == 30)
			{
				CMD_TopWeapon(client,0);
			}
			else
			{
				ShowTOPWeapon(client, GetWeaponNum(sWords[1]), StringToInt(sWords[2]));
			}
		}
	}
	else if (StrContains(sWords[0],"top", false) == 0)
	{
		if (strcmp(cpMessage,"top") == 0)
		{
			ShowTOP(client, 0);
		}
		else
		{
			ShowTOP(client, StringToInt(cpMessage[3]));
		}
	}
	return Plugin_Continue;
}

public GetCurrentPlayers(){
	new count;
	for(new i=1;i<=MaxClients;i++){
		if(IsClientInGame(i) && (!IsFakeClient(i) || g_bRankBots)){
			count++;
		}
	}
	return count;
}

public OnPluginEnd(){
	if(!g_bEnabled) 
		return;
	SQL_LockDatabase(g_hStatsDb);
	for(new client=1;client<=MaxClients;client++){
		if(IsClientInGame(client)){
			if(!g_bRankBots && IsFakeClient(client)) 
				return;
			new String:name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			new String:sEscapeName[MAX_NAME_LENGTH*2+1];
			SQL_EscapeString(g_hStatsDb,name,sEscapeName,sizeof(sEscapeName));
			
			// Make SQL-safe
			//ReplaceString(name, sizeof(name), "'", "");

			
			new String:weapons_query[500] = "";
			for(new i=0;i<=36;i++){
				Format(weapons_query,sizeof(weapons_query),"%s,%s='%d'",weapons_query,g_sWeaponsNamesGame[i],g_aWeapons[client][i]);
			}
		
			new String:query[1500];
			if(g_RankBy == 1){
				Format(query,sizeof(query),g_sSqlSaveName,g_sSQLTable,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][SUICIDES],g_aStats[client][TK],
					g_aStats[client][SHOTS],g_aStats[client][HITS],g_aStats[client][HEADSHOTS],g_aStats[client][ROUNDS_TR],g_aStats[client][ROUNDS_CT],g_aClientIp[client],sEscapeName,weapons_query,
					g_aHitBox[client][1],g_aHitBox[client][2],g_aHitBox[client][3],g_aHitBox[client][4],g_aHitBox[client][5],g_aHitBox[client][6],g_aHitBox[client][7],g_aStats[client][C4_PLANTED],g_aStats[client][C4_EXPLODED],g_aStats[client][C4_DEFUSED],g_aStats[client][CT_WIN],g_aStats[client][TR_WIN],g_aStats[client][HOSTAGES_RESCUED],g_aStats[client][VIP_KILLED],g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],GetTime(),g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED],sEscapeName);
			} else if (g_RankBy == 0) {
				Format(query,sizeof(query),g_sSqlSave,g_sSQLTable,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][SUICIDES],g_aStats[client][TK],
					g_aStats[client][SHOTS],g_aStats[client][HITS],g_aStats[client][HEADSHOTS],g_aStats[client][ROUNDS_TR],g_aStats[client][ROUNDS_CT],g_aClientIp[client],sEscapeName,weapons_query,
					g_aHitBox[client][1],g_aHitBox[client][2],g_aHitBox[client][3],g_aHitBox[client][4],g_aHitBox[client][5],g_aHitBox[client][6],g_aHitBox[client][7],g_aStats[client][C4_PLANTED],g_aStats[client][C4_EXPLODED],g_aStats[client][C4_DEFUSED],g_aStats[client][CT_WIN],g_aStats[client][TR_WIN],g_aStats[client][HOSTAGES_RESCUED],g_aStats[client][VIP_KILLED],g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],GetTime(),g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED],g_aClientSteam[client]);
			} else if (g_RankBy == 2) {
				Format(query,sizeof(query),g_sSqlSaveIp,g_sSQLTable,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][SUICIDES],g_aStats[client][TK],
					g_aStats[client][SHOTS],g_aStats[client][HITS],g_aStats[client][HEADSHOTS],g_aStats[client][ROUNDS_TR],g_aStats[client][ROUNDS_CT],g_aClientIp[client],sEscapeName,weapons_query,
					g_aHitBox[client][1],g_aHitBox[client][2],g_aHitBox[client][3],g_aHitBox[client][4],g_aHitBox[client][5],g_aHitBox[client][6],g_aHitBox[client][7],g_aStats[client][C4_PLANTED],g_aStats[client][C4_EXPLODED],g_aStats[client][C4_DEFUSED],g_aStats[client][CT_WIN],g_aStats[client][TR_WIN],g_aStats[client][HOSTAGES_RESCUED],g_aStats[client][VIP_KILLED],g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],GetTime(),g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED],g_aClientIp[client]);
			}
			
			SQL_FastQuery(g_hStatsDb,query);
			
			/**
			Start the forward OnPlayerSaved
			*/
			new Action:fResult;
			Call_StartForward(g_fwdOnPlayerSaved);
			Call_PushCell(client);
			new fError = Call_Finish(fResult);
			
			if (fError != SP_ERROR_NONE)
			{
				ThrowNativeError(fError, "Forward failed");
			}
		}
	}
	SQL_UnlockDatabase(g_hStatsDb);
}

public GetWeaponNum(String:weaponname[]){


	for(new i=0;i<=36;i++){
		if(StrEqual(weaponname,g_sWeaponsNamesGame[i]))
			return i;
	}
	return 36;
}

public Action: Event_VipEscaped(Handle:event, const String:name[], bool:dontBroadcast){
	if(!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	for(new i=1;i<=MaxClients;i++){

		if(IsClientInGame(i) && GetClientTeam(i)==CT){
			g_aStats[i][SCORE]+=g_PointsVipEscapedTeam;
			g_aSession[i][SCORE]+=g_PointsVipEscapedTeam;
		
		}

	}
	g_aStats[client][VIP_PLAYED]++;
	g_aSession[client][VIP_PLAYED]++;
	g_aStats[client][VIP_ESCAPED]++;
	g_aSession[client][VIP_ESCAPED]++;
	g_aStats[client][SCORE]+=g_PointsVipEscapedPlayer;
	g_aSession[client][SCORE]+=g_PointsVipEscapedPlayer;
	
	if(!g_bChatChange)
		return;
	for(new i = 1; i <= MaxClients;i++)
		if(IsClientInGame(i))
			CPrintToChat(i,"%s %t",MSG,"CT_VIPEscaped",g_PointsVipEscapedTeam);
	if(client != 0 && (g_bRankBots || !IsFakeClient(client))) 
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"VIPEscaped",g_aClientName[client],g_aStats[client][SCORE],g_PointsVipEscapedTeam+g_PointsVipEscapedPlayer);
}

public Action: Event_VipKilled(Handle:event, const String:name[], bool:dontBroadcast){
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	new killer = GetClientOfUserId(GetEventInt(event,"attacker"));

	for(new i=1;i<=MaxClients;i++){

		if(IsClientInGame(i) && GetClientTeam(i)==TR){
			g_aStats[i][SCORE]+=g_PointsVipKilledTeam;
			g_aSession[i][SCORE]+=g_PointsVipKilledTeam;
		
		}

	}
	g_aStats[client][VIP_PLAYED]++;
	g_aSession[client][VIP_PLAYED]++;
	g_aStats[killer][VIP_KILLED]++;
	g_aSession[killer][VIP_KILLED]++;
	g_aStats[killer][SCORE]+=g_PointsVipKilledPlayer;
	g_aSession[killer][SCORE]+=g_PointsVipKilledPlayer;
	
	if(!g_bChatChange)
		return;
	for(new i = 1; i <= MaxClients;i++)
		if(IsClientInGame(i))
			CPrintToChat(i,"%s %t",MSG,"TR_VIPKilled",g_PointsVipKilledTeam);
	if(client != 0 && (g_bRankBots || !IsFakeClient(client))) 
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"VIPKilled",g_aClientName[client],g_aStats[client][SCORE],g_PointsVipKilledTeam+g_PointsVipKilledPlayer);
}

public Action: Event_HostageRescued(Handle:event, const String:name[], bool:dontBroadcast){
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	
	for(new i=1;i<=MaxClients;i++){
	
		if(IsClientInGame(i) && GetClientTeam(i)==CT){
			g_aStats[i][SCORE]+=g_PointsHostageRescTeam;
			g_aSession[i][SCORE]+=g_PointsHostageRescTeam;
		
		}
	
	}
	g_aSession[client][HOSTAGES_RESCUED]++;
	g_aStats[client][HOSTAGES_RESCUED]++;
	g_aStats[client][SCORE]+=g_PointsHostageRescPlayer;
	g_aSession[client][SCORE]+=g_PointsHostageRescPlayer;
	
	if(!g_bChatChange)
		return;
	if(g_PointsHostageRescTeam > 0)
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"CT_Hostage",g_PointsHostageRescTeam);
	
	if(g_PointsHostageRescPlayer > 0 && client != 0 && (g_bRankBots || !IsFakeClient(client))) 
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"Hostage",g_aClientName[client],g_aStats[client][SCORE],g_PointsHostageRescPlayer+g_PointsHostageRescTeam);
	
}

public Action: Event_RoundMVP(Handle:event, const String:name[], bool:dontBroadcast){
	if(!g_bEnabled || !g_bGatherStats || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if(!IsClientInGame(client))
		return;
	new team = GetClientTeam(client);
	
	if(((team == 2 && g_PointsMvpTr > 0) || (team == 3 && g_PointsMvpCt > 0)) && client != 0 && (g_bRankBots || !IsFakeClient(client))){
		
		if(team == 2){
			
			g_aStats[client][SCORE] += g_PointsMvpTr;
			g_aSession[client][SCORE] += g_PointsMvpTr;
			for(new i = 1; i <= MaxClients;i++)
				if(IsClientInGame(i))
					CPrintToChat(i,"%s %t",MSG,"MVP",g_aClientName[client],g_aStats[client][SCORE],g_PointsMvpTr);
			
		} else {
			
			g_aStats[client][SCORE] += g_PointsMvpCt;
			g_aSession[client][SCORE] += g_PointsMvpCt;
			for(new i = 1; i <= MaxClients;i++)
				if(IsClientInGame(i))
					CPrintToChat(i,"%s %t",MSG,"MVP",g_aClientName[client],g_aStats[client][SCORE],g_PointsMvpCt);
			
		}
	}
	
	
}
public Action: Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast){
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	new i;
	new Winner = GetEventInt(event,"winner");
	new bool:announced=false;
	for(i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && (g_bRankBots || !IsFakeClient(i))){
			if(Winner == TR && GetClientTeam(i)==TR){
				g_aSession[i][TR_WIN]++;
				g_aStats[i][TR_WIN]++;
				if(g_PointsRoundWin[TR] >0 && IsPlayerAlive(i)){
					g_aSession[i][SCORE] += g_PointsRoundWin[TR];
					g_aStats[i][SCORE] += g_PointsRoundWin[TR];
					if(!announced && g_bChatChange){
						for(new j = 1; j <= MaxClients;j++)
							if(IsClientInGame(j))
								CPrintToChat(j,"%s %t",MSG,"TR_Round",g_PointsRoundWin[TR]);
						announced=true;
					}
				}
			} else if(Winner == CT && GetClientTeam(i)==CT){
				g_aSession[i][CT_WIN]++;
				g_aStats[i][CT_WIN]++;
				if(g_PointsRoundWin[CT] >0 && IsPlayerAlive(i)){
					g_aSession[i][SCORE] += g_PointsRoundWin[CT];
					g_aStats[i][SCORE] += g_PointsRoundWin[CT];
					if(!announced && g_bChatChange){
						for(new j = 1; j <= MaxClients;j++)
							if(IsClientInGame(j))
								CPrintToChat(j,"%s %t",MSG,"CT_Round",g_PointsRoundWin[CT]);
						announced=true;
					}
				}
			}
			SalvarPlayer(i);
		}
	}
	
	DumpDB();
}

public EventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if(!g_bRankBots && IsFakeClient(client)) 
		return;
	if(GetClientTeam(client) == TR){
		g_aStats[client][ROUNDS_TR]++;
		g_aSession[client][ROUNDS_TR]++;
	} else if(GetClientTeam(client) == CT){
		g_aStats[client][ROUNDS_CT]++;
		g_aSession[client][ROUNDS_CT]++;
	} 
}

public Action:Event_BombPlanted( Handle:event, const String:name[], bool:dontBroadcast )
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	g_C4PlantedBy = client;
	
	for(new i=1;i<=MaxClients;i++){
	
		if(IsClientInGame(i) && GetClientTeam(i)==TR){
			g_aStats[i][SCORE]+=g_PointsBombPlantedTeam;
			g_aSession[i][SCORE]+=g_PointsBombPlantedTeam;
		
		}
	
	}
	g_aStats[client][C4_PLANTED]++;
	g_aSession[client][C4_PLANTED]++;
	g_aStats[client][SCORE]+=g_PointsBombPlantedPlayer;
	g_aSession[client][SCORE]+=g_PointsBombPlantedPlayer;
	
	strcopy(g_sC4PlantedByName,sizeof(g_sC4PlantedByName),g_aClientName[client]);
	if(!g_bChatChange)
		return;
	if(g_PointsBombPlantedTeam > 0)
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"TR_Planting",g_PointsBombPlantedTeam);
	if(g_PointsBombPlantedPlayer > 0 && client != 0 && (g_bRankBots || !IsFakeClient(client))) 
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"Planting",g_aClientName[client],g_aStats[client][SCORE],g_PointsBombPlantedTeam+g_PointsBombPlantedPlayer);
		
}

public Action:Event_BombDefused( Handle:event, const String:name[], bool:dontBroadcast )
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	for(new i=1;i<=MaxClients;i++){
	
		if(IsClientInGame(i) && GetClientTeam(i)==CT){
			g_aStats[i][SCORE]+=g_PointsBombDefusedTeam;
			g_aSession[i][SCORE]+=g_PointsBombDefusedTeam;
		
		}
	
	}
	g_aStats[client][C4_DEFUSED]++;
	g_aSession[client][C4_DEFUSED]++;
	g_aStats[client][SCORE]+=g_PointsBombDefusedPlayer;
	g_aSession[client][SCORE]+=g_PointsBombDefusedPlayer;
	
	if(!g_bChatChange)
		return;
	if(g_PointsBombDefusedTeam > 0)
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"CT_Defusing",g_PointsBombDefusedTeam);
	if(g_PointsBombDefusedPlayer > 0 && client != 0 && (g_bRankBots || !IsFakeClient(client))) 
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"Defusing",g_aClientName[client],g_aStats[client][SCORE],g_PointsBombDefusedTeam+g_PointsBombDefusedPlayer);
}

public Action:Event_BombExploded( Handle:event, const String:name[], bool:dontBroadcast )
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	new client =g_C4PlantedBy;
	
	for(new i=1;i<=MaxClients;i++){
	
		if(IsClientInGame(i) && GetClientTeam(i)==TR){
			g_aStats[i][SCORE]+=g_PointsBombExplodeTeam;
			g_aSession[i][SCORE]+=g_PointsBombExplodeTeam;
		
		}
	
	}
	g_aStats[client][C4_EXPLODED]++;
	g_aSession[client][C4_EXPLODED]++;
	g_aStats[client][SCORE]+=g_PointsBombExplodePlayer;
	g_aSession[client][SCORE]+=g_PointsBombExplodePlayer;
	
	if(!g_bChatChange)
		return;
	if(g_PointsBombExplodeTeam > 0)
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"TR_Exploding",g_PointsBombExplodeTeam);
	if(g_PointsBombExplodePlayer > 0 && client != 0 && (g_bRankBots || (IsClientInGame(client) && !IsFakeClient(client)))) 
		for(new i = 1; i <= MaxClients;i++)
			if(IsClientInGame(i))
				CPrintToChat(i,"%s %t",MSG,"Exploding",g_sC4PlantedByName,g_aStats[client][SCORE],g_PointsBombExplodeTeam+g_PointsBombExplodePlayer);
}

public Action:Event_BombPickup( Handle:event, const String:name[], bool:dontBroadcast )
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	g_aStats[client][SCORE]+=g_PointsBombPickup;
	g_aSession[client][SCORE]+=g_PointsBombPickup;
	
	if(!g_bChatChange)
		return;
	if(g_PointsBombPickup > 0)
		CPrintToChat(client,"%s %t",MSG,"BombPickup",g_aClientName[client],g_aStats[client][SCORE],g_PointsBombPickup);

}

public Action:Event_BombDropped( Handle:event, const String:name[], bool:dontBroadcast )
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	g_aStats[client][SCORE]-=g_PointsBombDropped;
	g_aSession[client][SCORE]-=g_PointsBombDropped;
	
	if(!g_bChatChange)
		return;
	if(g_PointsBombDropped > 0 && client == 0)
		CPrintToChat(client,"%s %t",MSG,"BombDropped",g_aClientName[client],g_aStats[client][SCORE],g_PointsBombDropped);

}

public Action:EventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
// ----------------------------------------------------------------------------
{
	if(!g_bEnabled || !g_bGatherStats  || g_MinimumPlayers > GetCurrentPlayers()) 
		return;
	
	new victim = GetClientOfUserId(GetEventInt(event,"userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!g_bRankBots && attacker != 0 && (IsFakeClient(victim) || IsFakeClient(attacker))) 
		return;
	
	if(victim == attacker || attacker == 0){
		g_aStats[victim][SUICIDES]++;
		g_aSession[victim][SUICIDES]++;
		g_aStats[victim][SCORE] -= g_PointsLoseSuicide;
		g_aSession[victim][SCORE] -= g_PointsLoseSuicide;
		if(g_PointsLoseSuicide > 0 && g_bChatChange){
			
			CPrintToChat(victim,"%s %t",MSG,"LostSuicide",g_aClientName[victim],g_aStats[victim][SCORE],g_PointsLoseSuicide);
		}
	} else if(!g_bFfa && (GetClientTeam(victim) == GetClientTeam(attacker))){
		if(attacker < MAXPLAYERS){
			g_aStats[attacker][TK]++;
			g_aSession[attacker][TK]++;
			g_aStats[attacker][SCORE] -= g_PointsLoseTk;
			g_aSession[attacker][SCORE] -= g_PointsLoseTk;
			if(g_PointsLoseTk > 0 && g_bChatChange){
			
				CPrintToChat(victim,"%s %t",MSG,"LostTK",g_aClientName[attacker],g_aStats[attacker][SCORE],g_PointsLoseTk,g_aClientName[victim]);
				CPrintToChat(attacker,"%s %t",MSG,"LostTK",g_aClientName[attacker],g_aStats[attacker][SCORE],g_PointsLoseTk,g_aClientName[victim]);
			}
		}
	} else {
		new team =GetClientTeam(attacker);
		new bool:headshot = GetEventBool(event, "headshot");
		decl String:weapon[64];
		GetEventString(event, "weapon", weapon, sizeof(weapon));
		ReplaceString(weapon,sizeof(weapon),"weapon_","");

		if(StrEqual(weapon,"knife_default_ct") || StrEqual(weapon,"knife_default_t") || StrEqual(weapon,"knife_t") || StrEqual(weapon,"knifegg") || StrEqual(weapon,"knife_flip") || StrEqual(weapon,"knife_gut") || StrEqual(weapon,"knife_karambit") || StrEqual(weapon,"bayonet") || StrEqual(weapon,"knife_m9_bayonet") || StrEqual(weapon,"knife_butterfly") || StrEqual(weapon,"knife_tactical")){
			weapon = "knife";
		}
		
		new score_dif;
		if(attacker < MAXPLAYERS)
			score_dif = g_aStats[victim][SCORE] - g_aStats[attacker][SCORE];
		
		if(score_dif < 0 || attacker >= MAXPLAYERS) {
			score_dif = g_PointsKill[team];
		} else {
			if(g_PointsKillBonusDif[team] == 0)
				score_dif = g_PointsKill[team] + ((g_aStats[victim][SCORE] - g_aStats[attacker][SCORE])*g_PointsKillBonus[team]);
			else
				score_dif = g_PointsKill[team] + (((g_aStats[victim][SCORE] - g_aStats[attacker][SCORE])/g_PointsKillBonusDif[team])*g_PointsKillBonus[team]);
		}
		if(StrEqual(weapon,"knife")){
			score_dif  = RoundToCeil(score_dif*g_fPointsKnifeMultiplier);
		}
		else if(StrEqual(weapon,"taser")){
			score_dif  = RoundToCeil(score_dif*g_fPointsTaserMultiplier);
		}
		if(headshot && attacker < MAXPLAYERS){
			g_aStats[attacker][HEADSHOTS]++;
			g_aSession[attacker][HEADSHOTS]++;
		}
		
		g_aStats[victim][DEATHS]++;
		g_aSession[victim][DEATHS]++;
		if(attacker < MAXPLAYERS){
			g_aStats[attacker][KILLS]++;
			g_aSession[attacker][KILLS]++;
		}
		if(g_bPointsLoseRoundCeil){
			g_aStats[victim][SCORE] -= RoundToCeil(score_dif*g_fPercentPointsLose);
			g_aSession[victim][SCORE] -= RoundToCeil(score_dif*g_fPercentPointsLose);
		} else {
			g_aStats[victim][SCORE] -= RoundToFloor(score_dif*g_fPercentPointsLose);
			g_aSession[victim][SCORE] -= RoundToFloor(score_dif*g_fPercentPointsLose);
		}
		if(attacker < MAXPLAYERS){
			g_aStats[attacker][SCORE] += score_dif;
			g_aSession[attacker][SCORE] += score_dif;
			if(GetWeaponNum(weapon) < 38)
				g_aWeapons[attacker][GetWeaponNum(weapon)]++;
		}
		
		if(g_MinimalKills == 0 || (g_aStats[victim][KILLS] >= g_MinimalKills && g_aStats[attacker][KILLS] >= g_MinimalKills)){
			if(g_bChatChange){
				//PrintToServer("%s %t",MSG,"Killing",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE]);
				CPrintToChat(victim,"%s %t",MSG,"Killing",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE]);
				if(attacker < MAXPLAYERS)
					CPrintToChat(attacker,"%s %t",MSG,"Killing",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE]);
			}
		} else {
			if(g_aStats[victim][KILLS] < g_MinimalKills && g_aStats[attacker][KILLS] < g_MinimalKills){
				if(g_bChatChange){
					CPrintToChat(victim,"%s %t",MSG,"KillingBothNotRanked",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE],g_aStats[attacker][KILLS],g_MinimalKills,g_aStats[victim][KILLS],g_MinimalKills);
					if(attacker < MAXPLAYERS)
						CPrintToChat(attacker,"%s %t",MSG,"KillingBothNotRanked",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE],g_aStats[attacker][KILLS],g_MinimalKills,g_aStats[victim][KILLS],g_MinimalKills);
				}
			} else if(g_aStats[victim][KILLS] < g_MinimalKills){
				if(g_bChatChange){
					CPrintToChat(victim,"%s %t",MSG,"KillingVictimNotRanked",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE],g_aStats[victim][KILLS],g_MinimalKills);
					if(attacker < MAXPLAYERS)
						CPrintToChat(victim,"%s %t",MSG,"KillingVictimNotRanked",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE],g_aStats[victim][KILLS],g_MinimalKills);
				}
			} else {
				if(g_bChatChange){
					CPrintToChat(victim,"%s %t",MSG,"KillingKillerNotRanked",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE],g_aStats[attacker][KILLS],g_MinimalKills);
					if(attacker < MAXPLAYERS)
						CPrintToChat(attacker,"%s %t",MSG,"KillingKillerNotRanked",g_aClientName[attacker],g_aStats[attacker][SCORE],score_dif,g_aClientName[victim],g_aStats[victim][SCORE],g_aStats[attacker][KILLS],g_MinimalKills);
				}
			} 
		}
		if(headshot && attacker < MAXPLAYERS){
			
			g_aStats[attacker][SCORE]+=g_PointsHs;
			g_aSession[attacker][SCORE]+=g_PointsHs;
			if(g_bChatChange && g_PointsHs > 0)
				CPrintToChat(attacker,"%s %t",MSG,"Headshot",g_aClientName[attacker],g_aStats[attacker][SCORE],g_PointsHs);
		}
	}
	if(attacker < MAXPLAYERS)
		if(g_aStats[attacker][KILLS] == 50)
			g_TotalPlayers++;
}

public Action:EventPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
// ----------------------------------------------------------------------------
{
	if(!g_bEnabled || !g_bGatherStats) 
		return;
	new victim = GetClientOfUserId(GetEventInt(event,"userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!g_bRankBots && (attacker == 0 || IsFakeClient(victim) || IsFakeClient(attacker))) 
		return;
	if(victim != attacker && attacker >0 && attacker <MAXPLAYERS){
		new hitgroup = GetEventInt(event,"hitgroup");
		if(hitgroup == 0) // Player was hit by knife, he, flashbang, or smokegrenade.
			return;
		g_aStats[attacker][HITS]++;
		g_aSession[attacker][HITS]++;
		g_aHitBox[attacker][hitgroup]++;
		//PrintToChat(attacker, "Hitgroup %i: %i hits", hitgroup, g_aHitBox[attacker][hitgroup]);
		//PrintToServer("Stats Hits: %i\nSession Hits: %i\nHitBox %i -> %i",g_aStats[attacker][HITS],g_aSession[attacker][HITS],hitgroup,g_aHitBox[attacker][hitgroup]);
	}
}

public Action:EventWeaponFire(Handle:event,const String:name[],bool:dontBroadcast)
{

	if(!g_bEnabled || !g_bGatherStats ) 
		return;
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if(!g_bRankBots && IsFakeClient(client)) 
		return;
	new String:sWeaponUsed[50];
	GetEventString(event,"weapon",sWeaponUsed,sizeof(sWeaponUsed));
	if(StrEqual(sWeaponUsed,"knife") || StrEqual(sWeaponUsed,"hegrenade") || StrEqual(sWeaponUsed,"flashbang") || StrEqual(sWeaponUsed,"smokegrenade") || StrEqual(sWeaponUsed,"molotov") || StrEqual(sWeaponUsed,"incgrenade") || StrEqual(sWeaponUsed,"decoy"))
		return; // Don't count knife being used neither hegrenade, flashbang and smokegrenade being threw
	g_aStats[client][SHOTS]++;
	g_aSession[client][SHOTS]++;
	
}

public SalvarPlayer(client){
	if(!g_bEnabled || !g_bGatherStats) 
		return;
	if(!g_bRankBots && IsFakeClient(client)) 
		return;
	if(!OnDB[client])
		return;
	
	new String:sEscapeName[MAX_NAME_LENGTH*2+1];
	SQL_EscapeString(g_hStatsDb,g_aClientName[client],sEscapeName,sizeof(sEscapeName));
	//SQL_EscapeString(g_hStatsDb,name,name,sizeof(name));
	
	// Make SQL-safe
	//ReplaceString(name, sizeof(name), "'", "");

	
	new String:weapons_query[500] = "";
	for(new i=0;i<=36;i++){
		Format(weapons_query,sizeof(weapons_query),"%s,%s='%d'",weapons_query,g_sWeaponsNamesGame[i],g_aWeapons[client][i]);
	}
	new String:query[1500];
	if(g_RankBy == 1){
		Format(query,sizeof(query),g_sSqlSaveName,g_sSQLTable,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][SUICIDES],g_aStats[client][TK],
			g_aStats[client][SHOTS],g_aStats[client][HITS],g_aStats[client][HEADSHOTS],g_aStats[client][ROUNDS_TR],g_aStats[client][ROUNDS_CT],g_aClientIp[client],sEscapeName,weapons_query,
			g_aHitBox[client][1],g_aHitBox[client][2],g_aHitBox[client][3],g_aHitBox[client][4],g_aHitBox[client][5],g_aHitBox[client][6],g_aHitBox[client][7],g_aStats[client][C4_PLANTED],g_aStats[client][C4_EXPLODED],g_aStats[client][C4_DEFUSED],g_aStats[client][CT_WIN],g_aStats[client][TR_WIN],g_aStats[client][HOSTAGES_RESCUED],g_aStats[client][VIP_KILLED],g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],GetTime(),g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED],sEscapeName);
	} else if(g_RankBy == 0){
		Format(query,sizeof(query),g_sSqlSave,g_sSQLTable,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][SUICIDES],g_aStats[client][TK],
			g_aStats[client][SHOTS],g_aStats[client][HITS],g_aStats[client][HEADSHOTS],g_aStats[client][ROUNDS_TR],g_aStats[client][ROUNDS_CT],g_aClientIp[client],sEscapeName,weapons_query,
			g_aHitBox[client][1],g_aHitBox[client][2],g_aHitBox[client][3],g_aHitBox[client][4],g_aHitBox[client][5],g_aHitBox[client][6],g_aHitBox[client][7],g_aStats[client][C4_PLANTED],g_aStats[client][C4_EXPLODED],g_aStats[client][C4_DEFUSED],g_aStats[client][CT_WIN],g_aStats[client][TR_WIN],g_aStats[client][HOSTAGES_RESCUED],g_aStats[client][VIP_KILLED],g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],GetTime(),g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED],g_aClientSteam[client]);
	} else if(g_RankBy == 2){
		Format(query,sizeof(query),g_sSqlSaveIp,g_sSQLTable,g_aStats[client][SCORE],g_aStats[client][KILLS],g_aStats[client][DEATHS],g_aStats[client][SUICIDES],g_aStats[client][TK],
			g_aStats[client][SHOTS],g_aStats[client][HITS],g_aStats[client][HEADSHOTS],g_aStats[client][ROUNDS_TR],g_aStats[client][ROUNDS_CT],g_aClientIp[client],sEscapeName,weapons_query,
			g_aHitBox[client][1],g_aHitBox[client][2],g_aHitBox[client][3],g_aHitBox[client][4],g_aHitBox[client][5],g_aHitBox[client][6],g_aHitBox[client][7],g_aStats[client][C4_PLANTED],g_aStats[client][C4_EXPLODED],g_aStats[client][C4_DEFUSED],g_aStats[client][CT_WIN],g_aStats[client][TR_WIN],g_aStats[client][HOSTAGES_RESCUED],g_aStats[client][VIP_KILLED],g_aStats[client][VIP_ESCAPED],g_aStats[client][VIP_PLAYED],GetTime(),g_aStats[client][CONNECTED] + GetTime()-g_aSession[client][CONNECTED],g_aClientIp[client]);
	}
	SQL_TQuery(g_hStatsDb,SQL_SaveCallback,query,client,DBPrio_High);
	
	if(DEBUGGING){
		PrintToServer(query);
		
		LogError("%s",query);
	}
	
}


public SQL_SaveCallback(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Save Player Fail: %s", error);
		return;
	}
	
	/**
		Start the forward OnPlayerSaved
	*/
	new Action:fResult;
	Call_StartForward(g_fwdOnPlayerSaved);
	Call_PushCell(client);
	new fError = Call_Finish(fResult);
	
	if (fError != SP_ERROR_NONE)
	{
		ThrowNativeError(fError, "Forward failed");
	}
		
}

public OnClientPutInServer(client){

	// If the database isn't connected, you can't run SQL_EscapeString.
	if(g_hStatsDb != INVALID_HANDLE)
		LoadPlayer(client);
	
}

public LoadPlayer(client){

	OnDB[client]=false;
	for(new i=0;i<=19;i++){
		g_aSession[client][i] = 0;
		g_aStats[client][i] = 0;
	}
	g_aStats[client][SCORE]=g_PointsStart;
	for(new i=0;i<=36;i++){
		g_aWeapons[client][i] = 0;
	}
	g_aSession[client][CONNECTED] = GetTime();
	
	new String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	strcopy(g_aClientName[client],MAX_NAME_LENGTH,name);
	new String:sEscapeName[MAX_NAME_LENGTH*2+1];
	SQL_EscapeString(g_hStatsDb,name,sEscapeName,sizeof(sEscapeName));
	//ReplaceString(name, sizeof(name), "'", "");
	new String:auth[64];
	GetClientAuthId(client,AuthId_Steam2,auth,sizeof(auth));
	strcopy(g_aClientSteam[client],64,auth);
	new String:ip[64];
	GetClientIP(client,ip,sizeof(ip));
	strcopy(g_aClientIp[client],64,ip);
	new String:query[500];
	if(g_RankBy == 1)
		Format(query,sizeof(query),g_sSqlRetrieveClientName,g_sSQLTable,sEscapeName);
	else if (g_RankBy == 0)
		Format(query,sizeof(query),g_sSqlRetrieveClient,g_sSQLTable,auth);
	else if (g_RankBy == 2)
		Format(query,sizeof(query),g_sSqlRetrieveClientIp,g_sSQLTable,ip);
		
	if(DEBUGGING){
		PrintToServer(query);
		LogError("%s",query);
	}
	if(g_hStatsDb != INVALID_HANDLE)
		SQL_TQuery(g_hStatsDb,SQL_LoadPlayerCallback,query,client);

}

public SQL_LoadPlayerCallback(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Load Player Fail: %s", error);
		return;
	}
	if(!IsClientInGame(client))
		return;
		
	if(g_RankBy == 1){
		new String:name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name));
		if(!StrEqual(name,g_aClientName[client]))
			return;
	} else if(g_RankBy == 0){
		new String:auth[64];
		GetClientAuthId(client,AuthId_Steam2,auth,sizeof(auth));
		if(!StrEqual(auth,g_aClientSteam[client]))
			return;
	} else if(g_RankBy == 2){
		new String:ip[64];
		GetClientIP(client,ip,sizeof(ip));
		if(!StrEqual(ip,g_aClientIp[client]))
			return;
	}
	if(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		for(new i=0;i<=10;i++){
			g_aStats[client][i]=SQL_FetchInt(hndl,4+i);
		}
		for(new i=0;i<=36;i++){
			g_aWeapons[client][i]=SQL_FetchInt(hndl,16+i);
		}
		for(new i=1;i<=7;i++){
			g_aHitBox[client][i]=SQL_FetchInt(hndl,52+i);
		}
		g_aStats[client][C4_PLANTED]=SQL_FetchInt(hndl,60);
		g_aStats[client][C4_EXPLODED]=SQL_FetchInt(hndl,61);
		g_aStats[client][C4_DEFUSED]=SQL_FetchInt(hndl,62);
		g_aStats[client][CT_WIN] = SQL_FetchInt(hndl,63);
		g_aStats[client][TR_WIN] = SQL_FetchInt(hndl,64);
		g_aStats[client][HOSTAGES_RESCUED] = SQL_FetchInt(hndl,65);
		g_aStats[client][VIP_KILLED] = SQL_FetchInt(hndl,66);
		g_aStats[client][VIP_ESCAPED] = SQL_FetchInt(hndl,67);
		g_aStats[client][VIP_PLAYED] = SQL_FetchInt(hndl,68);
	} else {
		new String:query[500];
		
		new String:sEscapeName[MAX_NAME_LENGTH*2+1];
		SQL_EscapeString(g_hStatsDb,g_aClientName[client],sEscapeName,sizeof(sEscapeName));
		//SQL_EscapeString(g_hStatsDb,name,name,sizeof(name));
		//ReplaceString(name, sizeof(name), "'", "");
		
		Format(query,sizeof(query),g_sSqlInsert ,g_sSQLTable,g_aClientSteam[client],sEscapeName,g_aClientIp[client],g_PointsStart);
		SQL_TQuery(g_hStatsDb,SQL_NothingCallback,query,_,DBPrio_High);
		
		if(DEBUGGING){
			PrintToServer(query);
			
			LogError("%s",query);
		}
	}
	OnDB[client] = true;
	/**
	Start the forward OnPlayerLoaded
	*/
	new Action:fResult;
	Call_StartForward(g_fwdOnPlayerLoaded);
	Call_PushCell(client);
	new fError = Call_Finish(fResult);
	
	if (fError != SP_ERROR_NONE)
	{
		ThrowNativeError(fError, "Forward failed");
	}
}

public SQL_PurgeCallback(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	
	PrintToServer("[RankMe]: %d players purged by inactivity",SQL_GetAffectedRows(owner));
	if(client != 0){
		PrintToChat(client,"[RankMe]: %d players purged by inactivity",SQL_GetAffectedRows(owner));
	}
	//LogAction(-1,-1,"[RankMe]: %d players purged by inactivity",SQL_GetAffectedRows(owner));
	
}

public SQL_NothingCallback(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		return;
	}
	
	
}

public OnClientDisconnect(client){
	if(!g_bEnabled) 
		return;
	if(!g_bRankBots && IsFakeClient(client)) 
		return;
	SalvarPlayer(client);
	OnDB[client] = false;
}

public SQL_DumpCallback(Handle:owner, Handle:hndl, const String:error[], any:Datapack){

	if(hndl == INVALID_HANDLE)
	{
		LogError("[RankMe] Query Fail: %s", error);
		PrintToServer(error);
		return;
	}
	
	new Handle:File1;
	new String:fields_values[600];
	new String:field[100];
	
	File1 = OpenFile("rank.sql","w");
	if(File1==INVALID_HANDLE){
		
		LogError("[RankMe] Unable to open dump file.");
		
	}
	new fields = SQL_GetFieldCount(hndl);
	new bool:first;
	WriteFileLine(File1,g_sSqlCreate,g_sSQLTable);
	WriteFileLine(File1,"");
	
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		field = "";
		fields_values = "";
		first=true;
		for(new i = 0;i<=fields-1;i++){
			SQL_FetchString(hndl,i,field,sizeof(field));
			ReplaceString(field,sizeof(field),"\\","\\\\",false);
			ReplaceString(field,sizeof(field),"\"","\\\"",false);
			
			if(first){
				Format(fields_values,sizeof(fields_values),"\"%s\"",field);
				first=false;
			}
			else
				Format(fields_values,sizeof(fields_values),"%s,\"%s\"",fields_values,field);
		}
	
		WriteFileLine(File1,"INSERT INTO `%s` VALUES (%s);",g_sSQLTable,fields_values);
	}
	CloseHandle(File1);
}

public OnConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[]){
	new g_bQueryPlayerCount;
	
	if(convar == g_cvarShowBotsOnRank){
		g_bShowBotsOnRank = GetConVarBool(g_cvarShowBotsOnRank);
		g_bQueryPlayerCount = true;
	}
	else if (convar == g_cvarRankBy){
		g_RankBy = GetConVarBool(g_cvarRankBy);
	}
	else if (convar == g_cvarEnabled){
		g_bEnabled = GetConVarBool(g_cvarEnabled);
	}
	else if (convar == g_cvarShowRankAll){
		g_bShowRankAll = GetConVarBool(g_cvarShowRankAll);
	}
	else if (convar == g_cvarChatChange){
		g_bChatChange = GetConVarBool(g_cvarChatChange);
	}
	else if (convar == g_cvarRankbots){
		g_bRankBots = GetConVarBool(g_cvarRankbots);
		g_bQueryPlayerCount = true;
	}
	else if (convar == g_cvarFfa){
		g_bFfa = GetConVarBool(g_cvarFfa);
	}
	else if (convar == g_cvarDumpDB){
		g_bDumpDB = GetConVarBool(g_cvarDumpDB);
	}
	else if (convar == g_cvarPointsBombDefusedTeam){
		g_PointsBombDefusedTeam = GetConVarInt(g_cvarPointsBombDefusedTeam);
	}
	else if (convar == g_cvarPointsBombDefusedPlayer){
		g_PointsBombDefusedPlayer = GetConVarInt(g_cvarPointsBombDefusedPlayer);
	}
	else if (convar == g_cvarPointsBombPlantedTeam){
		g_PointsBombPlantedTeam = GetConVarInt(g_cvarPointsBombPlantedTeam);
	}
	else if (convar == g_cvarPointsBombPlantedPlayer){
		g_PointsBombPlantedPlayer = GetConVarInt(g_cvarPointsBombPlantedPlayer);
	}
	else if (convar == g_cvarPointsBombExplodeTeam){
		g_PointsBombExplodeTeam = GetConVarInt(g_cvarPointsBombExplodeTeam);
	}
	else if (convar == g_cvarPointsBombExplodePlayer){
		g_PointsBombExplodePlayer = GetConVarInt(g_cvarPointsBombExplodePlayer);
	}
	else if (convar == g_cvarPointsHostageRescTeam){
		g_PointsHostageRescTeam = GetConVarInt(g_cvarPointsHostageRescTeam);
	}
	else if (convar == g_cvarPointsHostageRescPlayer){
		g_PointsHostageRescPlayer = GetConVarInt(g_cvarPointsHostageRescPlayer);
	}
	else if (convar == g_cvarPointsHs){
		g_PointsHs = GetConVarInt(g_cvarPointsHs);
	}
	else if (convar == g_cvarPointsKillCt){
		g_PointsKill[CT] = GetConVarInt(g_cvarPointsKillCt);
	}
	else if (convar == g_cvarPointsKillTr){
		g_PointsKill[TR] = GetConVarInt(g_cvarPointsKillTr);
	}
	else if (convar == g_cvarPointsKillBonusCt){
		g_PointsKillBonus[CT] = GetConVarInt(g_cvarPointsKillBonusCt);
	}
	else if (convar == g_cvarPointsKillBonusTr){
		g_PointsKillBonus[TR] = GetConVarInt(g_cvarPointsKillBonusTr);
	}
	else if (convar == g_cvarPointsKillBonusDifCt){
		g_PointsKillBonusDif[CT] = GetConVarInt(g_cvarPointsKillBonusDifCt);
	}
	else if (convar == g_cvarPointsKillBonusDifTr){
		g_PointsKillBonusDif[TR] = GetConVarInt(g_cvarPointsKillBonusDifTr);
	}
	else if (convar == g_cvarPointsStart){
		g_PointsStart = GetConVarInt(g_cvarPointsStart);
	}
	else if (convar == g_cvarPointsKnifeMultiplier){
		g_fPointsKnifeMultiplier = GetConVarFloat(g_cvarPointsKnifeMultiplier);
	}
	else if (convar == g_cvarPointsTaserMultiplier){
		g_fPointsTaserMultiplier = GetConVarFloat(g_cvarPointsTaserMultiplier);
	}
	else if (convar == g_cvarPointsTrRoundWin){
		g_PointsRoundWin[TR] = GetConVarInt(g_cvarPointsTrRoundWin);
	}
	else if (convar == g_cvarPointsCtRoundWin){
		g_PointsRoundWin[CT] = GetConVarInt(g_cvarPointsCtRoundWin);
	}
	else if (convar == g_cvarMinimalKills){
		g_MinimalKills = GetConVarInt(g_cvarMinimalKills);
	}
	else if (convar == g_cvarPercentPointsLose){
		g_fPercentPointsLose = GetConVarFloat(g_cvarPercentPointsLose);
	}
	else if (convar == g_cvarPointsLoseRoundCeil){
		g_bPointsLoseRoundCeil = GetConVarBool(g_cvarPointsLoseRoundCeil);
	}
	else if (convar == g_cvarMinimumPlayers){
		g_MinimumPlayers = GetConVarInt(g_cvarMinimumPlayers);
	}
	else if (convar == g_cvarResetOwnRank){
		g_bResetOwnRank = GetConVarBool(g_cvarResetOwnRank);
	}
	else if (convar == g_cvarPointsVipEscapedTeam){
		g_PointsVipEscapedTeam = GetConVarInt(g_cvarPointsVipEscapedTeam);
	}
	else if (convar == g_cvarPointsVipEscapedPlayer){
		g_PointsVipEscapedPlayer = GetConVarInt(g_cvarPointsVipEscapedPlayer);
	}
	else if (convar == g_cvarPointsVipKilledTeam){
		g_PointsVipKilledTeam = GetConVarInt(g_cvarPointsVipKilledTeam);
	}
	else if (convar == g_cvarPointsVipKilledPlayer){
		g_PointsVipKilledPlayer = GetConVarInt(g_cvarPointsVipKilledPlayer);
	}
	else if (convar == g_cvarVipEnabled){
		g_bVipEnabled = GetConVarBool(g_cvarVipEnabled);
	} 
	else if (convar == g_cvarDaysToNotShowOnRank){
		g_DaysToNotShowOnRank = GetConVarInt(g_cvarDaysToNotShowOnRank);
		g_bQueryPlayerCount = true;
	}
	else if (convar == g_cvarGatherStats){
		g_bGatherStats = GetConVarBool(g_cvarGatherStats);
	} 
	else if (convar == g_cvarRankMode){
		g_RankMode = GetConVarInt(g_cvarRankMode);
	} 
	else if (convar == g_cvarChatTriggers){
		g_bChatTriggers = GetConVarBool(g_cvarChatTriggers);
	}
	else if (convar == g_cvarPointsMvpCt){
		g_PointsMvpCt = GetConVarInt(g_cvarPointsMvpCt);
	}
	else if (convar == g_cvarPointsMvpTr){
		g_PointsMvpTr = GetConVarInt(g_cvarPointsMvpTr);
	}
	else if (convar == g_cvarPointsBombPickup){
		g_PointsBombDropped = GetConVarInt(g_cvarPointsBombPickup);
	}
	else if (convar == g_cvarPointsBombDropped){
		g_PointsBombDropped = GetConVarInt(g_cvarPointsBombDropped);
	}
	
	if(g_bQueryPlayerCount && g_hStatsDb != INVALID_HANDLE){
		new String:query[500];
		MakeSelectQuery(query,sizeof(query));
		SQL_TQuery(g_hStatsDb,SQL_GetPlayersCallback,query);
	}
}

stock bool:IsValidClient(client, bool:nobots = true) 
{  
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client))) 
	{  
			return false;  
	}  
	return IsClientInGame(client);  
}

stock MakeSelectQuery(String:sQuery[],strsize){
	
	// Make basic query
	Format(sQuery,strsize,"SELECT * FROM `%s` WHERE kills >= '%d'",g_sSQLTable, g_MinimalKills);
		
	// Append check for bots
	if(!g_bShowBotsOnRank)
		Format(sQuery,strsize,"%s AND steam <> 'BOT'",sQuery);
	
	// Append check for inactivity
	if(g_DaysToNotShowOnRank > 0)
		Format(sQuery,strsize,"%s AND lastconnect >= '%d'",sQuery,GetTime()-(g_DaysToNotShowOnRank*86400));

}