//==============================================================================
// micro_military.xs	by JeHathor
//==============================================================================
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//==============================================================================
// getWeakestUnitByLocation
// Will return the weakest unit matching the parameters
//==============================================================================
int getWeakestUnitByLocation(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive,
   vector location = cInvalidVector, float radius = 20.0, int visibleState = cUnitQueryVisibleStateAllValid)
{
   static int unitQueryID = -1;

   // If we don't have the query yet, create one.
   if (unitQueryID < 0)
   {
      unitQueryID = kbUnitQueryCreate("getWeakestUnitByLocation");
   }

   if (kbGetIsLocationOnMap(location) == false)
   {
      aiEchoWarning("Calling getWeakestUnitByLocation with an invalid position, this makes no sense to do.");
      return -1;
   }
   if (radius <= 0.0)
   {
      aiEchoWarning("Calling getWeakestUnitByLocation with a radius that is too small: " + radius + ".");
      return -1;
   }

   // Define a query to get all matching units.
   if (unitQueryID != -1)
   {
      if (playerRelationOrID > 1000) // Too big for player ID number.
      {
         kbUnitQuerySetPlayerID(unitQueryID, -1);
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
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
      kbUnitQuerySetPosition(unitQueryID, location);
      kbUnitQuerySetMaximumDistance(unitQueryID, radius);
   }
   else
   {
      return -1;
   }

   int weakestID = -1;
   int minHP = 99999;

   kbUnitQueryResetResults(unitQueryID);
   int numberFound = kbUnitQueryExecute(unitQueryID);
   if (numberFound > 0)
   {
      for (int i=0; i < numberFound; i++)
      {
	   int pivotHP = kbUnitGetStatFloat(kbUnitQueryGetResult(unitQueryID, i), cUnitStatCurrHP);
	   if(pivotHP < minHP)
	   {
		weakestID = kbUnitQueryGetResult(unitQueryID, i);
	   }
      }
   }
   return weakestID;
}

//==============================================================================
// unitRangeToTerrainTiles
// [unit range = terrain tiles / 2]
//==============================================================================
float unitRangeToTerrainTiles(float rangeVal=0)
{
	return(rangeVal*2.0);
}

//==============================================================================
// microRangedUnit
// Handles individual pull back and focus fire
// [unit range = terrain tiles / 2]
//==============================================================================
void microRangedUnit(int myUnitID=-1)		//Type: KitingScript
{
   if(myUnitID < 0) {return;}
   if(kbUnitGetPlayerID(myUnitID) != cMyID) {return;}
   float myAttackRange = unitRangeToTerrainTiles(kbUnitGetActionMaximumRange(myUnitID,"RangedAttack"));
   float microRangeThreshold = myAttackRange*0.50;
   vector myUnitLoc = kbUnitGetPosition(myUnitID);
   int mhpUnitID = getClosestUnitByLocation(cUnitTypeMilitaryUnit, cPlayerRelationEnemy, cUnitStateAlive, myUnitLoc, microRangeThreshold, cUnitQueryVisibleStateVisible);
   if(mhpUnitID < 0) {return;}
   if(kbUnitGetPlayerID(myUnitID) == 0) {return;}
   float safeDistance = max(myAttackRange*0.75,unitRangeToTerrainTiles(kbUnitGetActionMaximumRange(mhpUnitID,"RangedAttack")+1));
   float mhpUnitDistance = kbUnitGetDistanceToUnit(myUnitID,mhpUnitID);
   float retreatDistance = safeDistance - mhpUnitDistance;

   //A - unit is damaged?
   bool conditionA = false;
   if (kbUnitGetStatFloat(myUnitID, cUnitStatCurrHP) <= kbUnitGetStatFloat(myUnitID, cUnitStatMaxHP)*0.8)
   {
	conditionA = true;
   }

   //B - nearest enemy unit is a titan?
   bool conditionB = false;
   if(kbUnitIsType(mhpUnitID, cUnitTypeAbstractTitan))
   {
	conditionB = true;
   }

   //C - nearest enemy unit far enough?
   bool conditionC = false;
   if (mhpUnitDistance < safeDistance)
   {
	conditionC = true;
   }

   //D - nearest enemy unit is not a tank?
   bool conditionD = true;
   if(
	(
	   kbUnitIsType(mhpUnitID, cUnitTypeAbstractSiegeWeapon)
	   &&
	   kbUnitIsType(myUnitID, cUnitTypeAbstractSiegeWeapon) == false
	)
	||
	(
	   (
	      kbUnitIsType(myUnitID, cUnitTypeHero) == false
	      &&
	      kbUnitIsType(myUnitID, cUnitTypeMythUnit) == false
	   )
	   &&
	   (
	      kbUnitIsType(mhpUnitID, cUnitTypeAbstractTitan)
	      ||
	      kbUnitIsType(mhpUnitID, cUnitTypeColossus)
	      ||
	      kbUnitIsType(mhpUnitID, cUnitTypeScarab)
	      ||
	      kbUnitIsType(mhpUnitID, cUnitTypeBehemoth)
	      ||
	      kbUnitIsType(mhpUnitID, cUnitTypeFrostGiant)
	      ||
	      kbUnitIsType(mhpUnitID, cUnitTypeRockGiant)
	   )
	)
	||
	(kbUnitGetStatFloat(mhpUnitID, cUnitStatArmorPierce) >= 0.60)
     )
   {
	conditionD = false;
   }

   //E - my unit is not a hero?
   bool conditionE = true;
   if(kbUnitIsType(myUnitID, cUnitTypeHero))
   {
	conditionE = false;
   }

   if(conditionA || conditionB)	   //Evaluate conditions...
   {
	vector dangerLoc = kbUnitGetPosition(mhpUnitID);
	vector path = dangerLoc-myUnitLoc;
	path = xsVectorNormalize(path) * retreatDistance;
	vector retreatPoint = dangerLoc-path;
	aiTaskMoveUnit(myUnitID, retreatPoint, false);		//Run!!!
   }else
   if(conditionA && conditionC && conditionD && conditionE)
   {
		aiTaskWorkUnit(myUnitID, mhpUnitID, false);	//Hit!!!
   }else
   if(conditionE)	// Heroes target myth, always. Don't interfere.
   {
	int targetUnitID = getWeakestUnitByLocation(cUnitTypeUnit, cPlayerRelationEnemy, cUnitStateAlive, myUnitLoc, myAttackRange+4, cUnitQueryVisibleStateVisible);
	if(targetUnitID > -1)
	{
		aiTaskWorkUnit(myUnitID, targetUnitID, false);	//Hit!!!
	}
    }
}
//==============================================================================
// RULE: microMilitary
//==============================================================================
rule microMilitary
   active
   highFrequency
{
   if(cMicroLevelHigh < 3)
   {
	xsDisableSelf();
	return;
   }
   //if(kbPlayerGetAge(cMyID) < cAge2) {return;}

   if(kbUnitCount(cUnitTypeRanged, cMyID, cUnitStateAlive) > 0)
   {
	int myUnitID = getUnit(cUnitTypeRanged, cMyID, cUnitStateAlive);
	if(kbUnitGetActionType(myUnitID) != cActionTypeMove)
	{
		microRangedUnit(myUnitID);
	}
   }
}
