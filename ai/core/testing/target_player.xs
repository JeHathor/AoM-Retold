//==============================================================================
// target_player.xs	by JeHathor
//==============================================================================
extern bool gIsPocket = false;  //pockets target the strongest enemy
extern bool gIsFlank = false;	//flanks target the closest enemy
extern int gPlayerTeamSize = 1;	//Good to know, safe it...
extern const int myUnitStateAliveOrBuilding = 3;	//Use ABQ instead.
//==============================================================================
// getPlayerEconPop
// Returns the unit count of villagers, fishing boats, trade carts.
//==============================================================================
int getPlayerEconPop(int pID=cMyID)	//Allows to check for other players too.
{
   int retVal = 0;

   retVal = retVal + kbUnitCount(pID, cUnitTypeAbstractVillager, cUnitStateAlive);
   retVal = retVal + kbUnitCount(pID, cUnitTypeAbstractFishingShip, cUnitStateAlive);  
   retVal = retVal + kbUnitCount(pID, cUnitTypeTradeUnit, cUnitStateAlive);

   return(retVal);
}

//==============================================================================
// getUnitByIndex
// Will return a unit matching the parameters
// A more flexibel version of getUnit()
//==============================================================================
int getUnitByIndex(int index = -1, int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive,
            int visibleState = cUnitQueryVisibleStateAllValid, int[] excludeTypes = default)
{
   static int unitQueryID = -1;

   // If we don't have the query yet, create one.
   if (unitQueryID < 0)
   {
      unitQueryID = kbUnitQueryCreate("getUnitByIndex");
   }

   // Define a query to get all matching units
   if (unitQueryID != -1)
   {
      if (playerRelationOrID > 1000) // Too big for player ID number
      {
         kbUnitQuerySetPlayerID(unitQueryID, -1); // Clear the player ID, so playerRelation takes precedence.
         kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
      }
      else
      {
         kbUnitQuerySetPlayerRelation(unitQueryID, cPlayerRelationAny);
         kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
      }
      if (visibleState != cUnitQueryVisibleStateAllValid)
      {
         kbUnitQuerySetVisibleState(unitQueryID, visibleState);
      }
      if (excludeTypes.size() > 0)
      {
         kbUnitQuerySetExcludeTypes(unitQueryID, excludeTypes);
      }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
   }
   else
   {
      return (-1);
   }

   kbUnitQueryResetResults(unitQueryID);
   int numberFound = kbUnitQueryExecute(unitQueryID);
   if (index >= 0 && numberFound > index)
   {
      return (kbUnitQueryGetResult(unitQueryID, index));
   }else
   if (numberFound > 0)		//go random.
   {
      return (kbUnitQueryGetResult(unitQueryID, xsRandInt(0, numberFound - 1)));
   }
   return (-1);
}

//==============================================================================
// getPlayerTeamSize
//==============================================================================
int getPlayerTeamSize()
{
   int teamSize = 0;

   for (int i=1; i<cNumberPlayers; i++)
   {
	if(i == cMyID || kbPlayerIsAlly(i))
	{
		teamSize++;
	}
   }
   aiEcho("Players in team: "+teamSize);
   return teamSize;
}

//==============================================================================
// playerIsTeamPocket	//Identifies the Pocket/SuperPocket
//==============================================================================
bool playerIsTeamPocket(int playerID=cMyID)
{
   gPlayerTeamSize = getPlayerTeamSize();
   if(gPlayerTeamSize <= 1)	//1v1 or FFA.
   {
		gIsPocket = true;
		gIsFlank = true;
		aiEcho("Player"+cMyID+": I'm Alone!");
		return(true);
   }else
   if(gPlayerTeamSize%2 == 0)	//2,4,6,...
   {
		gIsPocket = false;
		gIsFlank = true;
		aiEcho("Player"+cMyID+": I'm Flank!");
		return(false);
   }

   //The player with the shortest distance to his team members is the pocket.
   float minDistanceScore = -1;
   int minDistanceID = -1;

   for (int pID1=1; pID1 < cNumberPlayers; pID1++)
   {
	if(pID1 == cMyID || kbPlayerIsAlly(pID1))
	{
	    float currentDistanceScore = -1;

	    int mainTC = getUnitByIndex(0, cUnitTypeAbstractSettlement, pID1, cUnitStateAlive);

	    for(int pID2=1; pID2 < cNumberPlayers; pID2++)
	    {
		if(pID2 != pID1 && (pID2 == cMyID || kbPlayerIsAlly(pID2)))
		{
		    int allyTC = getUnitByIndex(0, cUnitTypeAbstractSettlement, pID2, cUnitStateAlive);

			currentDistanceScore = currentDistanceScore + kbUnitGetDistanceToUnit(mainTC,allyTC);
		}
	    }

	    if(currentDistanceScore < minDistanceScore || minDistanceScore < 0)
	    {
		minDistanceScore = currentDistanceScore;
		minDistanceID = pID1;
	    }
	}
   }

   if(playerID == minDistanceID)	//Is this player the pocket?
   {
	gIsPocket = true;
	gIsFlank = false;
	aiEcho("Player"+cMyID+": I'm Pocket!");
	return(true);
   }
    //Otherwise Flank.
	gIsPocket = false;
	gIsFlank = true;
	aiEcho("Player"+cMyID+": I'm Flank!");
	return(false);
}

//==============================================================================
// RULE: updatePlayerToAttack.  Updates the player we should be attacking.
//==============================================================================
rule updatePlayerToAttack
   minInterval 40
   active
   runImmediately
{
   //Run this until we get a result.
   if(gIsPocket == false && gIsFlank == false)
   {
	playerIsTeamPocket(cMyID);
   }

   if (checkStrategyFlag(cStrategyFlagAutomaticTargetPlayerPicking) == false)
   {
	return;
   }

	xsDisableRule("mostHatedEnemy");	//Don't let this overwrite anything we do here.

   //Gaia is index 0, but counts as player. This means
   //if there are 4 players in the game then cNumberPlayers is set to 5.

   if(cNumberPlayers <= 3)	//instant love?
   {
	aiSetMostHatedPlayerID(cMyID == 2 ? 1:2);
	return;
   }
   //We no longer need to determine a random start index,
   //since we calculate the opponents accurately.
   int comparePlayerID=-1;
   float comparePower=-1;

   for (int indexPlayer=1; indexPlayer < cNumberPlayers; indexPlayer++)
   {
      if ((kbPlayerIsEnemy(indexPlayer) == true) &&
	 (kbPlayerIsResigned(indexPlayer) == false) &&
	 (kbPlayerHasLost(indexPlayer) == false))
      {
	//randomly target closest or strongest in FFA.
	if(gIsPocket == false || (gIsFFA == true && xsRandBool(0.5)))
	{
		//Focus on the closest player as flank.
		int myTC = getUnitByIndex(0, cUnitTypeAbstractSettlement, cMyID, cUnitStateAlive);
		vector myLocation = kbUnitGetPosition(myTC);
		int indexUnitID = getClosestUnitByLocation(cUnitTypeLogicalTypeBuildingsThatShoot, indexPlayer, cUnitStateABQ, myLocation, 999);
		float indexDistance = kbUnitGetDistanceToUnit(myTC,indexUnitID);
		if(indexDistance < comparePower || comparePower < 0)
		{
			comparePlayerID=indexPlayer;
			comparePower=indexDistance;
		}
	}else{
		//Target the player with the most power as pocket.
		int indexTC = kbUnitCount(cUnitTypeAbstractSettlement, indexPlayer, cUnitStateAlive);
		int indexEco = getPlayerEconPop(indexPlayer);
		int indexMil = kbUnitCount(cUnitTypeMilitaryUnit, indexPlayer, cUnitStateAlive);
		indexMil = indexMil + kbUnitCount(cUnitTypeLogicalTypeMythUnitNotTitan, indexPlayer, cUnitStateAlive);
		indexMil = indexMil + 10*kbUnitCount(cUnitTypeAbstractTitan, indexPlayer, cUnitStateAlive);
		//Potential outweights current military size.
		int indexPower = 20*indexTC + 3*indexEco + 1*indexMil;
		if(kbUnitCount(cUnitTypeWonder, indexPlayer, cUnitStateABQ) > 0)
		{
			indexPower = indexPower + 50;		//wonder bonus.
		}
		if(indexPower < 0)
		{
			indexPower=0;		//makes sure we pick someone. [0 > -1]
		}
		if(indexPower > comparePower)
		{
			comparePlayerID=indexPlayer;
			comparePower=indexPower;
		}
	}
      }
   }
   //Validate, then pass the comparePlayerID into the AI.
   int actualPlayerID = -1;
   if(kbPlayerIsEnemy(comparePlayerID) == true && kbPlayerIsResigned(comparePlayerID) == false)
   {
	actualPlayerID = comparePlayerID;
   }
   if(actualPlayerID < 1)
   {
	actualPlayerID = getRandomEnemyID();	//Fail safe.
   }
   //Default us off.
   aiSetMostHatedPlayerID(actualPlayerID);
}
