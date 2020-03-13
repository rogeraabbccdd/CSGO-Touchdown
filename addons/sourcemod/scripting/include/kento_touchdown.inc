#if defined _Touchdown_included
 #endinput
#endif
#define _Touchdown_included

/**
 * Gets the ball origin.
 *
 * @return true on success, otherwise false.
 */
native bool Touchdown_GetBallOrigin(float origin[3]);

/**
 * Gets the ball holder.
 *
 * @return client id.
 */
native int Touchdown_GetBallHolder();

/**
 * Gets which team drop the ball.
 *
 * @return	TR = 2, CT = 3.
 */
native int Touchdown_GetBallDropTeam();

/**
 * Is client ball holder?
 *
 * @param client     Client id.
 * @return	True if client holding the ball.
 */
native bool Touchdown_IsClientBallHolder(int client);

/**
 * Gets the team's flag origin.
 *
 * @param team			Flag of team.
 * @param origin 		Flag origin.
 * @return true on success, otherwise false.
 */
native bool Touchdown_GetFlagOrigin(int team, float origin[3]);

/**
 * Gets client points.
 *
 * @return	client points.
 */
native int Touchdown_GetClientPoints(int client);

/**
 * Gets client kills.
 *
 * @return	client points.
 */
native int Touchdown_GetClientKills(int client);

/**
 * Gets client deaths.
 *
 * @return	client points.
 */
native int Touchdown_GetClientDeaths(int client);

/**
 * Gets client assists.
 *
 * @return	client points.
 */
native int Touchdown_GetClientAssists(int client);

/**
 * Gets client touchdown.
 *
 * @return	client points.
 */
native int Touchdown_GetClientTouchdown(int client);

/**
 * Gets client kill ballholder.
 *
 * @return	client points.
 */
native int Touchdown_GetClientKillball(int client);

/**
 * Gets client drop ball.
 *
 * @return	client points.
 */
native int Touchdown_GetClientDropball(int client);

/**
 * Gets client pickup ball.
 *
 * @return	client points.
 */
native int Touchdown_GetClientGetball(int client);

/**
 * Called when a player drop the ball.
 *
 * @param client     Player  index.
 * @return          No return
 */
forward Action Touchdown_OnPlayerDropBall(int client);

/**
 * Called when a player kill the ball holder.
 *
 * @param ballholder	Ball Holder.
 * @param attacker	Attacker.
 * @return          No return
 */
forward Action Touchdown_OnPlayerKillBall(int ballholder, int attacker);

/**
 * Called when the ball reset.
 *
 * @return          No return
 */
forward Action Touchdown_OnBallReset();

/**
 * Called when a player get the ball.
 *
 * @param client     Player index.
 * @return          No return
 */
forward Action Touchdown_OnPlayerGetBall(int client);

/**
 * Called when a player touchdown.
 *
 * @param client     Player index.
 * @return          No return
 */
forward Action Touchdown_OnPlayerTouchDown(int client);