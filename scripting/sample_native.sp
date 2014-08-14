#include <rankme>

public Plugin:myinfo = {
	name = "Native Sample",
	author = "",
	description = "",
	version = "0.0",
	url = ""
};

public OnPluginStart(){
	RegAdminCmd("give_point",CMD_GivePoint,ADMFLAG_ROOT);
	RegAdminCmd("getstats",CMD_GetStats,ADMFLAG_ROOT);
	RegAdminCmd("getsession",CMD_GetSession,ADMFLAG_ROOT);
	RegAdminCmd("getrank",CMD_GetRank,ADMFLAG_ROOT);
	RegAdminCmd("getweaponkills",CMD_GetWeapon,ADMFLAG_ROOT);
}

public Action:CMD_GivePoint(client,args){
	new String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	
	new player = FindTarget(0,arg1,true,false);
	if(player != -1){
		// Will give to player 5 points for Being a good guy, and show it to everyone
		RankMe_GivePoint(player,5,"Being a good guy",0,1);
		
		// Will give to player 5 points for Being a good guy, and show it only for him
		RankMe_GivePoint(player,5,"Being a good guy",1,0);
	} else {
		ReplyToCommand(client,"Target not found");
	}
	return Plugin_Handled;

}

public Action:CMD_GetStats(client,args){
	new String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	new player = FindTarget(0,arg1,true,false);
	new stats[STATS_NAMES];
	RankMe_GetStats(player,stats);
	ReplyToCommand(client,"%N => Kills: %d Deaths: %d",player,stats[KILLS],stats[DEATHS]);
	return Plugin_Handled;
}

public Action:CMD_GetWeapon(client,args){
	new String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	new player = FindTarget(0,arg1,true,false);
	new wstats[WEAPONS_ENUM];
	RankMe_GetWeaponStats(player,wstats);
	ReplyToCommand(client,"%N => Kills with AK47: %d Kills with AWP: %d",player,wstats[AK47],wstats[AWP]);
	return Plugin_Handled;
}

public Action:CMD_GetHitBox(client,args){
	new String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	new player = FindTarget(0,arg1,true,false);
	new hstats[HITBOXES];
	RankMe_GetHitbox(player,hstats);
	ReplyToCommand(client,"%N => Hits on Stomach: %d Hits on Head: %d",player,hstats[STOMACH],hstats[HEAD]);
	return Plugin_Handled;
}

public Action:CMD_GetSession(client,args){
	new String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	new player = FindTarget(0,arg1,true,false);
	new stats[STATS_NAMES];
	RankMe_GetSession(player,stats);
	ReplyToCommand(client,"%N => Kills: %d Deaths: %d",player,stats[KILLS],stats[DEATHS]);
	return Plugin_Handled;
}
public Action:CMD_GetRank(client,args){
	new String:arg1[MAX_NAME_LENGTH];
	GetCmdArg(1,arg1,sizeof(arg1));
	new player = FindTarget(0,arg1,true,false);
	RankMe_GetRank(player,RankCallback,client);
	return Plugin_Handled;
}

public RankCallback(player, rank,any:client){
	PrintToChat(client,"%N is rank %d",player,rank);
}