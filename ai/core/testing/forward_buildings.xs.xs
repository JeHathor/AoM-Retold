//==============================================================================
/* buildings_offensive.xs

   Forward placement of military buildings and towers into the combat zone.
   Only active on Titan difficulty and above, not on transport maps.

*/
//==============================================================================

//==============================================================================
// buildForwardBuildings
// Places melee and archer training buildings near the current combat zone.
//==============================================================================
rule buildForwardBuildings
   minInterval 35
   inactive
   group defaultHeroicRules
{
   if (cDifficultyCurrent < cDifficultyTitan || gMapInfo.mStartsWithTransport == true)
   {
      xsDisableSelf();
      return;
   }

   debugStartAnalysis("Difficulty is " + aiGetWorldDifficultyName(cDifficultyCurrent) + ".");

   if (kbPlayerGetPop(cMyID) <= kbPlayerGetPopCap(cMyID) * 0.5)
   {
      return;
   }

   // Resource gates -- Atlantean needs both, Egyptian uses gold, everyone else wood.
   bool hasResources = false;
   if (cMyCulture == cCultureAtlantean)
   {
      hasResources = kbResourceGet(cResourceGold) > 200 && kbResourceGet(cResourceWood) > 300;
   }
   else if (cMyCulture == cCultureEgyptian)
   {
      hasResources = kbResourceGet(cResourceGold) > 200;
   }
   else
   {
      hasResources = kbResourceGet(cResourceWood) > 300;
   }
   if (hasResources == false)
   {
      return;
   }

   // Read one training building per unit class from gArmyUnitBuildings[].
   int buildingID1 = gArmyUnitBuildings[gMaintainPlanHumanMeleeStartIndex];   // Melee trainer.
   int buildingID2 = gArmyUnitBuildings[gMaintainPlanHumanArcherStartIndex];  // Archer trainer.

   if (buildingID1 == -1 || buildingID2 == -1)
   {
      debugMilitaryBuildings("buildForwardBuildings: could not resolve melee or archer training building, aborting.");
      return;
   }

   if (kbCanAffordUnit(buildingID1, cMilitaryEscrowID) == false || kbCanAffordUnit(buildingID2, cMilitaryEscrowID) == false)
   {
      return;
   }

   // Find the closest enemy shooting building as the reference point for sorting and deletion.
   int enemyShootingBuildingID = getClosestUnitByLocation(cUnitTypeLogicalTypeBuildingsThatShoot, cPlayerRelationEnemyNotGaia, cUnitStateAlive, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), 9999.0);
   if (enemyShootingBuildingID == -1)
   {
      return;
   }
   vector enemyShootingBuildingLoc = kbUnitGetPosition(enemyShootingBuildingID);

   // --- Locate the combat zone. ---
   // Query for our military units actively performing a [ranged] attack.
   // Ascending sort by distance to the closest enemy shooting building; we pick the last result (furthest from the enemy) as the safest anchor for a build plan.
   int milQueryID = kbUnitQueryCreate("ForwardBuildings_MilUnit");
   kbUnitQuerySetPlayerID(milQueryID, cMyID, false);
   kbUnitQuerySetUnitType(milQueryID, cUnitTypeMilitaryUnit);
   kbUnitQuerySetState(milQueryID, cUnitStateAlive);
   kbUnitQuerySetActionType(milQueryID, cActionTypeAttack);	//cActionTypeRangedAttack
   kbUnitQuerySetPosition(milQueryID, enemyShootingBuildingLoc);
   kbUnitQuerySetAscendingSort(milQueryID, true);
   int milCount = kbUnitQueryExecute(milQueryID);
   if (milCount == 0)
   {
      return;
   }

   int unitID = kbUnitQueryGetResult(milQueryID, milCount - 1);
   if (kbUnitGetIsIDValid(unitID) == false)
   {
      return;
   }

   vector unitLoc = kbUnitGetPosition(unitID);

   // Find the closest friendly shooting building to orient the build direction.
   int shootingBuildingID = getClosestUnitByLocation(cUnitTypeLogicalTypeBuildingsThatShoot, cMyID, cUnitStateAlive, unitLoc, 50.0);
   if (shootingBuildingID == -1)
   {
      return;
   }

   // An enemy scout nearby means this is a scouted position, not a real frontline.
   int scoutID = getClosestUnitByLocation(cUnitTypeAbstractScout, cPlayerRelationEnemyNotGaia, cUnitStateAlive, unitLoc, 18.0);
   if (scoutID != -1)
   {
      debugMilitaryBuildings("buildForwardBuildings: enemy scout within 18 units of our soldier, skipping -- not a real combat zone.");
      return;
   }

   // Build point: 8 units back from our firing unit towards the closest friendly shooting building.
   vector baseLoc = kbUnitGetPosition(shootingBuildingID);
   vector dir     = xsVectorNormalize(unitLoc - baseLoc);
   vector buildPoint = unitLoc - (dir * 8.0);

   int buildArea = kbAreaGetIDByPosition(buildPoint);
   if (kbAreaGetType(buildArea) == cAreaTypeWater || kbAreaGetType(buildArea) == cAreaTypeImpassableLand)
   {
      return;
   }

   kbBaseSetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID), buildPoint);

   // If at the build limit for the fortress, delete one to make room.
   if (buildingID1 == gFortressUnit || buildingID2 == gFortressUnit)
   {
      if (kbUnitCount(gFortressUnit, cMyID, cUnitStateAlive) >= kbPlayerGetProtoStatInt(cMyID, gFortressUnit, cProtoStatBuildLimit))
      {
         int deleteQueryID = kbUnitQueryCreate("ForwardBuildings_DeleteOldBig");
         kbUnitQuerySetPlayerID(deleteQueryID, cMyID, false);
         kbUnitQuerySetUnitType(deleteQueryID, gFortressUnit);
         kbUnitQuerySetState(deleteQueryID, cUnitStateAlive);
         kbUnitQuerySetPosition(deleteQueryID, enemyShootingBuildingLoc);
         kbUnitQuerySetAscendingSort(deleteQueryID, false);
         kbUnitQueryExecute(deleteQueryID);
         int oldID = kbUnitQueryGetResult(deleteQueryID, 0);
         if (kbUnitGetIsIDValid(oldID) == true)
         {
            aiTaskDeleteUnit(oldID);
         }
      }
   }

   // Create one build plan per building type.
   int planIDs = 0;
   for (int i = 0; i < 2; i++)
   {
      int puid = (i == 0) ? buildingID1 : buildingID2;
      if (kbProtoUnitAvailable(puid) == false) { continue; }

      int planID = aiPlanCreate("ForwardBuildingPlan_" + kbProtoUnitGetName(puid), cPlanBuild, -1, gMilitaryBuildingsCategoryID);
      if (aiPlanGetIsIDValid(planID) == false) { continue; }

      int bpID = kbBuildingPlacementCreate(aiPlanGetName(planID));
      if (bpID == -1)
      {
         aiPlanDestroy(planID);
         continue;
      }

      kbBuildingPlacementSetBuildingPUID(bpID, puid);
      kbBuildingPlacementSetCenterPosition(bpID, buildPoint, 36.0);
      kbBuildingPlacementSetBufferSpace(bpID, 14.0);
      kbBuildingPlacementSetStepSize(bpID, 0.5);
      kbBuildingPlacementAddPositionInfluence(bpID, buildPoint, 15.0, 40.0, cFalloffLinear);
      kbBuildingPlacementAddUnitInfluence(bpID, cUnitTypeTree, 12.0, 10.0, cFalloffLinear);

      int builderID = getClosestUnitByLocation(cUnitTypeAbstractVillager, cMyID, cUnitStateAlive, buildPoint, 200.0);
      if (builderID != -1)
      {
         kbBuildingPlacementAddPositionInfluence(bpID, kbUnitGetPosition(builderID), 10.0, 20.0, cFalloffLinear);
      }

      aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, puid);
      aiPlanSetVariableInt(planID, cBuildPlanBuildingPlacementID, 0, bpID);
      aiPlanSetVariableInt(planID, cBuildPlanMaxRetries, 0, 5);
      aiPlanSetPriority(planID, 70);

      if (cMyCulture == cCultureAtlantean)
      {
         addBuilderTypesToPlan(planID, puid, 1);
      }
      else
      {
         addBuilderTypesToPlan(planID, puid, 2);
      }

      planIDs++;
   }

   if (planIDs == 0)
   {
      debugMilitaryBuildings("buildForwardBuildings: no valid plans created for buildPoint " + buildPoint + ".");
   }
}

//==============================================================================
// buildForwardTowers
// Places towers near the current combat zone.
//==============================================================================
rule buildForwardTowers
   minInterval 25
   inactive
   group defaultHeroicRules
{
   if (cDifficultyCurrent < cDifficultyTitan || gMapInfo.mStartsWithTransport == true)
   {
      xsDisableSelf();
      return;
   }

   debugStartAnalysis("Difficulty is " + aiGetWorldDifficultyName(cDifficultyCurrent) + ".");

   if (kbTechGetStatus(cTechWatchTower, false) != cTechStatusActive)
   {
      if (kbUnitCount(cUnitTypeSentryTower, cMyID, cUnitStateAlive) > 3)
      {
         return;
      }
      else
      {
         xsEnableRule("towerOffensiveUpgradeMonitor");
      }
   }

   if (aiGetCurrentEconomyPop() < 20)
   {
      return;
   }

   if (kbResourceGet(cResourceWood) <= 200 || kbResourceGet(cResourceGold) <= 200)
   {
      return;
   }

   // Choose building type: Tower, Fortress, or Mirror Tower (Oranos/Kronos in Mythic only).
   int buildingID = cUnitTypeSentryTower;
   int roll = xsRandInt(0, 2);
   if (roll == 0)
   {
      if ((cMyCiv == cCivOranos || cMyCiv == cCivKronos) && kbTechGetStatus(cTechMythicAgeHelios, false) == cTechStatusActive)
      {
         buildingID = cUnitTypeMirrorTower;
      }
      else
      {
         buildingID = cUnitTypeSentryTower;
      }
   }
   else if (roll == 1)
   {
      buildingID = gFortressUnit;
   }

   if (kbCanAffordUnit(buildingID, cMilitaryEscrowID) == false)
   {
      return;
   }

   // --- Locate the combat zone. ---
   // Find the closest enemy shooting building as the reference point for sorting and deletion.
   int enemyShootingBuildingID = getClosestUnitByLocation(cUnitTypeLogicalTypeBuildingsThatShoot, cPlayerRelationEnemyNotGaia, cUnitStateAlive, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), 9999.0);
   if (enemyShootingBuildingID == -1)
   {
      return;
   }
   vector enemyShootingBuildingLoc = kbUnitGetPosition(enemyShootingBuildingID);

   int milQueryID = kbUnitQueryCreate("ForwardTowers_MilUnit");
   kbUnitQuerySetPlayerID(milQueryID, cMyID, false);
   kbUnitQuerySetUnitType(milQueryID, cUnitTypeMilitaryUnit);
   kbUnitQuerySetState(milQueryID, cUnitStateAlive);
   kbUnitQuerySetActionType(milQueryID, cActionTypeAttack);	//cActionTypeRangedAttack
   kbUnitQuerySetPosition(milQueryID, enemyShootingBuildingLoc);
   kbUnitQuerySetAscendingSort(milQueryID, true);
   int milCount = kbUnitQueryExecute(milQueryID);
   if (milCount == 0)
   {
      return;
   }

   int unitID = kbUnitQueryGetResult(milQueryID, milCount - 1);
   if (kbUnitGetIsIDValid(unitID) == false)
   {
      return;
   }

   vector unitLoc = kbUnitGetPosition(unitID);

   // Find the closest friendly shooting building to orient the build direction.
   int shootingBuildingID = getClosestUnitByLocation(cUnitTypeLogicalTypeBuildingsThatShoot, cMyID, cUnitStateAlive, unitLoc, 50.0);
   if (shootingBuildingID == -1)
   {
      return;
   }

   // An enemy scout nearby means this is a scouted position, not a real frontline.
   int scoutID = getClosestUnitByLocation(cUnitTypeAbstractScout, cPlayerRelationEnemyNotGaia, cUnitStateAlive, unitLoc, 18.0);
   if (scoutID != -1)
   {
      debugMilitaryBuildings("buildForwardTowers: enemy scout within 18 units of our soldier, skipping -- not a real combat zone.");
      return;
   }

   // Build point: 15 units back from our firing unit towards the closest friendly shooting building.
   vector baseLoc = kbUnitGetPosition(shootingBuildingID);
   vector dir     = xsVectorNormalize(unitLoc - baseLoc);
   vector buildPoint = unitLoc - (dir * 15.0);

   int buildArea = kbAreaGetIDByPosition(buildPoint);
   if (kbAreaGetType(buildArea) == cAreaTypeWater || kbAreaGetType(buildArea) == cAreaTypeImpassableLand)
   {
      return;
   }

   kbBaseSetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID), buildPoint);

   // If at the build limit, delete one to make room.
   if (kbUnitCount(buildingID, cMyID, cUnitStateAlive) >= kbPlayerGetProtoStatInt(cMyID, buildingID, cProtoStatBuildLimit))
   {
      int deleteQueryID = kbUnitQueryCreate("ForwardTowers_DeleteOld");
      kbUnitQuerySetPlayerID(deleteQueryID, cMyID, false);
      kbUnitQuerySetUnitType(deleteQueryID, buildingID);
      kbUnitQuerySetState(deleteQueryID, cUnitStateAlive);
      kbUnitQuerySetPosition(deleteQueryID, enemyShootingBuildingLoc);
      kbUnitQuerySetAscendingSort(deleteQueryID, false);
      kbUnitQueryExecute(deleteQueryID);
      int oldID = kbUnitQueryGetResult(deleteQueryID, 0);
      if (kbUnitGetIsIDValid(oldID) == true)
      {
         aiTaskDeleteUnit(oldID);
      }
   }

   int planID = aiPlanCreate("ForwardTowerPlan_" + kbProtoUnitGetName(buildingID), cPlanBuild, -1, gMilitaryBuildingsCategoryID);
   if (aiPlanGetIsIDValid(planID) == false)
   {
      return;
   }

   int bpID = kbBuildingPlacementCreate(aiPlanGetName(planID));
   if (bpID == -1)
   {
      aiPlanDestroy(planID);
      return;
   }

   kbBuildingPlacementSetBuildingPUID(bpID, buildingID);
   kbBuildingPlacementSetCenterPosition(bpID, buildPoint, 14.0);
   kbBuildingPlacementSetBufferSpace(bpID, 4.0);
   kbBuildingPlacementSetStepSize(bpID, 0.5);
   kbBuildingPlacementAddPositionInfluence(bpID, buildPoint, 60.0, 30.0, cFalloffLinear);
   kbBuildingPlacementAddUnitInfluence(bpID, cUnitTypeMilitaryUnit, 50.0, 20.0, cFalloffLinear);

   int builderID = getClosestUnitByLocation(cUnitTypeAbstractVillager, cMyID, cUnitStateAlive, buildPoint, 200.0);
   if (builderID != -1)
   {
      kbBuildingPlacementAddPositionInfluence(bpID, kbUnitGetPosition(builderID), 10.0, 20.0, cFalloffLinear);
   }

   aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, buildingID);
   aiPlanSetVariableInt(planID, cBuildPlanBuildingPlacementID, 0, bpID);
   aiPlanSetVariableInt(planID, cBuildPlanMaxRetries, 0, 10);
   aiPlanSetPriority(planID, 100);

   // Towers need more builders to go up fast at the front.
   if (cMyCulture == cCultureAtlantean)
   {
      addBuilderTypesToPlan(planID, buildingID, 2);
   }
   else
   {
      addBuilderTypesToPlan(planID, buildingID, 5);
   }

}
