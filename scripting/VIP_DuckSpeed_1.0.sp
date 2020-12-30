#pragma semicolon 1
#include <sourcemod>
#include <vip_core> 
#pragma newdecls required

#define DEFAULT_DUCK_SPEED 6.023437

int           m_flDuckSpeed;

float         g_flPlayerDuckSpeed[MAXPLAYERS + 1];

GlobalForward g_hForwardPlayerDuck,
              g_hForwardPlayerDuckPost;

// duck_speed.sp
public Plugin myinfo = 
{
	name = "[VIP] Duck Speed",
	author = "sNok3, Wend4r",
	version = "2.0",
	url = "https://snok3.com | Wend4r#0001"
}

public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] sError, int iErrorSize)
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		strcopy(sError, iErrorSize, "This plugin works only on CS:GO");

		return APLRes_SilentFailure;
	}

	CreateNative("GetDuckSpeed", Native_GetDuckSpeed);
	CreateNative("SetDuckSpeed", Native_SetDuckSpeed);

	g_hForwardPlayerDuck = new GlobalForward("OnPlayerDuck", ET_Event, Param_Cell, Param_CellByRef);
	g_hForwardPlayerDuckPost = new GlobalForward("OnPlayerDuckPost", ET_Ignore, Param_Cell, Param_Cell);

	RegPluginLibrary("duck_speed");

	return APLRes_Success;
}

int Native_GetDuckSpeed(Handle hPlugin, int iArgs)
{
	return view_as<int>(g_flPlayerDuckSpeed[GetNativeCell(1)]);
}

int Native_SetDuckSpeed(Handle hPlugin, int iArgs)
{
	int   iClient = GetNativeCell(1);

	float flDuckSpeed = GetNativeCell(2);

	if(iClient == -1)
	{
		for(iClient = MaxClients + 1; --iClient;)
		{
			g_flPlayerDuckSpeed[iClient] = flDuckSpeed;
		}
	}
	else
	{
		g_flPlayerDuckSpeed[iClient] = flDuckSpeed;
	}
}

public void OnPluginStart()
{
	ConVar hCvar = CreateConVar("sm_duck_speed_enable", "1", "Is this plugin actions enabled", _, true, 0.0, true, 1.0);

	hCvar.AddChangeHook(OnEnableConVarChanged);
	OnEnableConVarChanged(hCvar, NULL_STRING, NULL_STRING);

	m_flDuckSpeed = FindSendPropInfo("CBasePlayer", "m_flDuckSpeed");

	if(VIP_IsVIPLoaded())
		VIP_OnVIPLoaded();
}

#define VIP_DuckSpeed "DuckSpeed"

public void VIP_OnVIPLoaded()
{
    VIP_RegisterFeature(VIP_DuckSpeed, BOOL);
}

public void OnPluginEnd() 
{
	VIP_UnregisterFeature(VIP_DuckSpeed);
}

void OnEnableConVarChanged(ConVar hCvar, const char[] sOldValue, const char[] sNewValue)
{
	if(hCvar.BoolValue)
	{
		for(int i = MaxClients + 1; --i;)
		{
			g_flPlayerDuckSpeed[i] = DEFAULT_DUCK_SPEED;
		}
	}
	else
	{
		for(int i = MaxClients + 1; --i;)
		{
			g_flPlayerDuckSpeed[i] = -1.0;
		}
	}
}

public void OnPlayerRunCmdPost(int iClient, int iButtons)
{
	static int iOldButtons[MAXPLAYERS + 1];

	if(iButtons & IN_DUCK && !(iOldButtons[iClient] & IN_DUCK) && VIP_IsClientVIP(iClient) && VIP_IsClientFeatureUse(iClient, VIP_DuckSpeed))
	{
		// PrintToChat(iClient, "%f", GetEntDataFloat(iClient, m_flDuckSpeed));

		float flDuckSpeed = g_flPlayerDuckSpeed[iClient];

		if(g_hForwardPlayerDuck.FunctionCount)
		{
			Action iReturn;

			Call_StartForward(g_hForwardPlayerDuck);
			Call_PushCell(iClient);
			Call_PushCellRef(flDuckSpeed);
			Call_Finish(iReturn);

			if(iReturn == Plugin_Handled)
			{
				return;
			}
		}

		if(g_flPlayerDuckSpeed[iClient] != -1.0)
		{
			SetEntDataFloat(iClient, m_flDuckSpeed, flDuckSpeed);
		}

		if(g_hForwardPlayerDuckPost.FunctionCount)
		{
			Call_StartForward(g_hForwardPlayerDuck);
			Call_PushCell(iClient);
			Call_PushCell(flDuckSpeed);
			Call_Finish();
		}
	}

	iOldButtons[iClient] = iButtons;
}