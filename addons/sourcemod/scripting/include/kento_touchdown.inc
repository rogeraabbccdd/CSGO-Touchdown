#if defined _Touchdown_included
 #endinput
#endif
#define _Touchdown_included

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
 * @param client     Player index.
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