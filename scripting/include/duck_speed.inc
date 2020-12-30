#if defined _duck_speed_included
	#endinput
#endif
#define _duck_speed_included

#define DEFAULT_DUCK_SPEED 6.023437

/**
 * Gets duck speed.
 *
 * @param iClient       Client index.
 *
 * @return              Duck speed. -1.0 if default duck.
 * @error               iClient > 64.
 */
native float GetDuckSpeed(int iClient);

/**
 * Sets duck speed for player's.
 *
 * @param iClient       Client index. -1 for sets on all player.
 * @param flSpeed       Speed. By default DEFAULT_DUCK_SPEED. -1.0 if default duck.
 *
 * @noreturn
 * @error               iClient > 64.
 */
native void SetDuckSpeed(int iClient = -1, float flSpeed = -1.0);

/**
 * Called when player ducked.
 *
 * @param iClient       Client index.
 * @param flSpeed       Duck speed. Can change.
 *
 * @return              Plugin_Handled for stop the change.
 */
forward Action OnPlayerDuck(int iClient, float &flSpeed);

/**
 * Called after player ducked.
 *
 * @param iClient       Client index.
 * @param flSpeed       Duck speed.
 *
 * @noreturn
 */
forward void OnPlayerDuckPost(int iClient, float flSpeed);



public SharedPlugin __pl_duck_speed =
{
	name = "duck_speed",
	file = "duck_speed.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_duck_speed_SetNTVOptional()
{
	MarkNativeAsOptional("GetDuckSpeed");
	MarkNativeAsOptional("SetDuckSpeed");
}