include "lib/rm_core.xs";
include "lib/rm_beautification.xs";
include "lib/rm_forests.xs";

//by JeHathor (AUG 2024)
void generate()
{
   rmSetProgress(0.0);

   // Define mixes.
   int baseMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(baseMixID, cNoiseFractalSum, 0.3, 5, 0.5);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainNorseSnowGrass2, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainNorseSnowGrass1, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainNorseSnowRocks1, 1.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainTundraSnowDirt1, 5.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainTundraSnowDirt2, 3.0);
   
   int pondMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(pondMixID, cNoiseFractalSum, 0.3, 5, 0.5);
   rmCustomMixAddPaintEntry(pondMixID, cTerrainTundraSnowRocks2, 2.0);
   rmCustomMixAddPaintEntry(pondMixID, cTerrainTundraSnowRocks1, 3.0);
   rmCustomMixAddPaintEntry(pondMixID, cTerrainNorseSnowDirt3, 2.0);
   rmCustomMixAddPaintEntry(pondMixID, cTerrainNorseSnowDirt2, 2.0);
   rmCustomMixAddPaintEntry(pondMixID, cTerrainNorseSnowDirt1, 2.0);
   
   int pondLayerMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(pondLayerMixID, cNoiseFractalSum, 0.3, 5, 0.5);
   rmCustomMixAddPaintEntry(pondLayerMixID, cTerrainNorseSnowRocks1, 2.0);
   rmCustomMixAddPaintEntry(pondLayerMixID, cTerrainTundraSnowDirt3, 2.0);
   rmCustomMixAddPaintEntry(pondLayerMixID, cTerrainTundraSnowDirt2, 2.0);
   rmCustomMixAddPaintEntry(pondLayerMixID, cTerrainNorseSnowDirt3, 3.0);

   // Map size and terrain init.
   int axisTiles = getAxisTilesFromCount();
   rmSetMapSize(axisTiles);
   rmInitializeMix(baseMixID);

   // Player placement.
   rmSetTeamSpacingModifier(0.8);
   rmPlacePlayersOnCircle(xsRandFloat(0.375, 0.4));

   // Finalize player placement and do post-init things.
   postPlayerPlacement();

   // Mother Nature's civ.
   rmSetNatureCivFromCulture(cCultureNorse);

   // Lighting.
   rmSetLighting(cLightingSetRmKerlaugar01);

   rmSetProgress(0.1);

   // Global elevation.
   rmAddGlobalHeightNoise(cNoiseFractalSum, 5.0, 0.1, 5, 0.3);
   
   // classes
   int pondAreaClassID = rmClassCreate();
   int lakeClassID = rmClassCreate();

   // Settlements and towers.
   // Starting town centers.
   int startingTownCenterID = rmObjectDefCreate("starting town center");
   rmObjectDefAddItem(startingTownCenterID, cUnitTypeTownCenter, 1);
   rmObjectDefPlacePerPlayer(startingTownCenterID, true, 1);
   
   int avoidPond6 = rmCreateClassDistanceConstraint(pondAreaClassID, 6.0);
   int avoidLake5 = rmCreateClassDistanceConstraint(lakeClassID, 5.0);

   // Starting towers.
   int startingTowerID = rmObjectDefCreate("starting tower");
   rmObjectDefAddItem(startingTowerID, cUnitTypeSentryTower, 1);
   addObjectLocsPerPlayer(startingTowerID, true, 4, cStartingTowerMinDist, cStartingTowerMaxDist, cStartingTowerAvoidanceMeters);
   rmObjectDefAddConstraint(startingTowerID, avoidPond6);
   generateLocations("starting tower locs");
   
   rmSetProgress(0.2);

   // Center pond area.
   
   float lakeAreaHeight = -5.0;

   // Outer Pond Area to create a dirt-like buffer area between cliff and the grass.
   int outerPondAreaID = rmAreaCreate("outer pond");
   rmAreaSetSize(outerPondAreaID, 0.3);
   rmAreaSetLoc(outerPondAreaID, cCenterLoc);
   rmAreaAddTerrainLayer(outerPondAreaID, cTerrainTundraRoadSnow2, 0, 1);
   rmAreaAddTerrainLayer(outerPondAreaID, cTerrainNorseSnowGrass1, 1, 2);
   rmAreaSetMix(outerPondAreaID, pondLayerMixID);

   rmAreaSetBlobDistance(outerPondAreaID, 1.0 * rmGetMapXTiles() / 20.0, 1.0 * rmGetMapZTiles() / 10.0);
   rmAreaSetBlobs(outerPondAreaID, 1, 5);

   rmAreaSetEdgeSmoothDistance(outerPondAreaID, 5);
   rmAreaSetCoherence(outerPondAreaID, 1.0);

   rmAreaBuild(outerPondAreaID);

   int innerPondAreaID = rmAreaCreate("inner pond");
   rmAreaSetSize(innerPondAreaID, 0.25);
   rmAreaSetLoc(innerPondAreaID, cCenterLoc);
   rmAreaSetMix(innerPondAreaID, pondMixID);

   rmAreaSetCliffType(innerPondAreaID, cCliffTundraSnow);
   if (gameIs1v1() == true)
   {
      rmAreaSetCliffRamps(innerPondAreaID, 6, 0.1);
   }
   else
   {
      rmAreaSetCliffRamps(innerPondAreaID, 6, 0.1);
   }
   rmAreaSetCliffRampSteepness(innerPondAreaID, 100.0);
   rmAreaSetCliffEmbellishmentDensity(innerPondAreaID, 0.25);
   rmAreaSetCliffSideRadius(innerPondAreaID, 1, 1);

   rmAreaSetHeightRelative(innerPondAreaID, lakeAreaHeight);

   int blendIdx = rmAreaAddHeightBlend(innerPondAreaID, cBlendAll, cFilter3x3Box, 10, 5, true, true);
   rmAreaAddHeightBlendConstraint(innerPondAreaID, blendIdx, vDefaultAvoidImpassableLand);
   rmAreaAddHeightBlendExpansionConstraint(innerPondAreaID, blendIdx, vDefaultAvoidImpassableLand);

   rmAreaSetEdgeSmoothDistance(innerPondAreaID, 5);
   rmAreaSetCoherence(innerPondAreaID, 0.25);

   rmAreaSetHeightNoise(innerPondAreaID, cNoiseFractalSum, 12.0, 0.1, 2, 0.5);

   rmAreaAddConstraint(innerPondAreaID, rmCreateAreaEdgeDistanceConstraint(outerPondAreaID, 15.0));

   rmAreaAddToClass(innerPondAreaID, pondAreaClassID);

   rmAreaBuild(innerPondAreaID);
   
   int avoidPondEdge6 = rmCreateAreaEdgeDistanceConstraint(innerPondAreaID, 6.0);

   // Center lake.
   int waterAreaID = rmAreaCreate("lake");
   rmAreaSetWaterType(waterAreaID, cWaterNorseLake);
   rmAreaSetCoherence(waterAreaID, 0.25);
   rmAreaSetEdgeSmoothDistance(waterAreaID, 4);
   rmAreaSetWaterHeight(waterAreaID, lakeAreaHeight-1);
   rmAreaSetSize(waterAreaID, 0.08);
   rmAreaAddToClass(waterAreaID, lakeClassID);
   rmAreaSetLoc(waterAreaID, cCenterLoc);

   rmAreaBuild(waterAreaID);

   // KotH.
   if (gameIsKotH() == true)
   {
      int islandKotHID = rmAreaCreate("koth island");
      rmAreaSetSize(islandKotHID, rmRadiusToAreaFraction(15.0 * sqrt(cNumberPlayers)));
      rmAreaSetLoc(islandKotHID, cCenterLoc);
      //rmAreaSetMix(islandKotHID, baseMixID);

      rmAreaSetCoherence(islandKotHID, 0.25);
      rmAreaSetEdgeSmoothDistance(islandKotHID, 5);
      rmAreaSetHeight(islandKotHID, lakeAreaHeight);
      rmAreaSetHeightNoise(islandKotHID, cNoiseFractalSum, 3.0, 0.1, 3, 0.5);
      rmAreaSetHeightNoiseBias(islandKotHID, 1.0); // Only grow upwards.
      rmAreaSetHeightNoiseEdgeFalloffDist(islandKotHID, 20.0);
      rmAreaAddHeightBlend(islandKotHID, cBlendEdge, cFilter5x5Box, 10.0, 5.0);
      
      rmAreaAddToClass(islandKotHID, vKotHClassID);

      rmAreaBuild(islandKotHID);
   }
   placeKotHObjects();

   rmSetProgress(0.3);

   // Settlements.
   
   int avoidPond16 = rmCreateClassDistanceConstraint(pondAreaClassID, 16.0);
   
   int firstSettlementID = rmObjectDefCreate("first settlement");
   rmObjectDefAddItem(firstSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(firstSettlementID, avoidPond16);

   int secondSettlementID = rmObjectDefCreate("second settlement");
   rmObjectDefAddItem(secondSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(secondSettlementID, avoidPond16);

   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(firstSettlementID, false, 1, 60.0, 80.0, cSettlementDist1v1, cBiasBackward);
      add1v1ObjectSimLocs(secondSettlementID, false, 1, 80.0, 120.0, cSettlementDist1v1, cBiasAggressive);
   }
   else
   {
      addObjectLocsPerPlayer(firstSettlementID, false, 1, 60.0, 80.0, cCloseSettlementDist, cBiasBackward | cBiasAllyInside);
      addObjectLocsPerPlayer(secondSettlementID, false, 1, 70.0, 90.0, cFarSettlementDist, cBiasAggressive | cBiasAllyOutside);
   }
   
   // Large / Giant map settlements.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      int thirdSettlementID = rmObjectDefCreate("third settlement");
      rmObjectDefAddItem(thirdSettlementID, cUnitTypeSettlement, 1);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultSettlementAvoidEdge);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidCorner);
      rmObjectDefAddConstraint(thirdSettlementID, avoidPond16);
      addObjectLocsPerPlayer(thirdSettlementID, false, 1 * getMapAreaSizeFactor(), 90.0, -1.0, 100.0);
   }

   generateLocations("settlement locs");

   rmSetProgress(0.4);

   // Starting objects.
   // Starting gold.
   int startingGoldID = rmObjectDefCreate("starting gold");
   rmObjectDefAddItem(startingGoldID, cUnitTypeMineGoldMedium, 1);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingGoldID, vDefaultStartingGoldAvoidTower);
   rmObjectDefAddConstraint(startingGoldID, vDefaultForceStartingGoldNearTower);
   addObjectLocsPerPlayer(startingGoldID, false, 1, cStartingGoldMinDist, cStartingGoldMaxDist, cStartingObjectAvoidanceMeters);

   int startingGoldSmallID = rmObjectDefCreate("starting gold small");
   rmObjectDefAddItem(startingGoldSmallID, cUnitTypeMineGoldSmall, 1);
   rmObjectDefAddConstraint(startingGoldSmallID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingGoldSmallID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingGoldSmallID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingGoldSmallID, vDefaultStartingGoldAvoidTower);
   rmObjectDefAddConstraint(startingGoldSmallID, vDefaultForceStartingGoldNearTower);
   addObjectLocsPerPlayer(startingGoldSmallID, false, 1, cStartingGoldMinDist, (cStartingGoldMaxDist + 2.0), cStartingObjectAvoidanceMeters);

   generateLocations("starting gold locs");

   // Starting hunt.
   int startingHuntID = rmObjectDefCreate("starting hunt");
   rmObjectDefAddItem(startingHuntID, cUnitTypeElk, 4);
   rmObjectDefAddItem(startingHuntID, cUnitTypeBoar, xsRandInt(2, 3));
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingHuntID, vDefaultForceInTowerLOS);
   rmObjectDefAddConstraint(startingHuntID, vDefaultFoodAvoidGold);
   addObjectLocsPerPlayer(startingHuntID, false, 1, cStartingHuntMinDist, cStartingHuntMaxDist, cStartingObjectAvoidanceMeters);

   // Chicken.
   int startingChickenID = rmObjectDefCreate("starting chicken");
   rmObjectDefAddItem(startingChickenID, cUnitTypeChicken, xsRandInt(5, 7));
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingChickenID, vDefaultFoodAvoidGold);
   addObjectLocsPerPlayer(startingChickenID, false, 1, cStartingChickenMinDist, cStartingChickenMaxDist, cStartingObjectAvoidanceMeters);

   // Berries.
   int startingBerriesID = rmObjectDefCreate("starting berries");
   rmObjectDefAddItem(startingBerriesID, cUnitTypeBerryBush, xsRandInt(6, 9), 5.0);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultFoodAvoidGold);
   addObjectLocsPerPlayer(startingBerriesID, false, 1, cStartingBerriesMinDist, cStartingBerriesMaxDist, cStartingObjectAvoidanceMeters);

   // Herdables.
   int startingHerdID = rmObjectDefCreate("starting herd");
   rmObjectDefAddItem(startingHerdID, cUnitTypeCow, xsRandInt(2, 3));
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidImpassableLand5);
   addObjectLocsPerPlayer(startingHerdID, true, 1, cStartingHerdMinDist, cStartingHerdMaxDist);

   generateLocations("starting food locs");

   rmSetProgress(0.5);

   // Gold.
   float avoidGoldMeters = 50.0;

   // Close gold.
   int closeGoldID = rmObjectDefCreate("close gold");
   rmObjectDefAddItem(closeGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidImpassableLand20);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeGoldID, createTownCenterConstraint(65.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(closeGoldID, false, 1, 65.0, 75.0, avoidGoldMeters);
   }
   else
   {
      addObjectLocsPerPlayer(closeGoldID, false, 1, 65.0, 75.0, avoidGoldMeters);
   }

   // Far gold.
   int farGoldID = rmObjectDefCreate("far gold");
   rmObjectDefAddItem(farGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(farGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(farGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(farGoldID, vDefaultAvoidImpassableLand20);
   rmObjectDefAddConstraint(farGoldID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(farGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(farGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(farGoldID, createTownCenterConstraint(80.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(farGoldID, false, 1, 80.0, 100.0, avoidGoldMeters);
   }
   else
   {
      addObjectLocsPerPlayer(farGoldID, false, 1, 80.0, 100.0, avoidGoldMeters);
   }

   // Bonus gold.
   int bonusGoldID = rmObjectDefCreate("bonus gold");
   rmObjectDefAddItem(bonusGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidImpassableLand20);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidSettlementRange);
   // rmObjectDefAddConstraint(bonusGoldID, createTownCenterConstraint(100.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(bonusGoldID, false, xsRandInt(1, 2) * getMapSizeBonusFactor(), 100.0, -1.0, avoidGoldMeters);
   }
   else
   {
      addObjectLocsPerPlayer(bonusGoldID, false, 1 * getMapSizeBonusFactor(), 100.0, -1.0, avoidGoldMeters);
   }

   generateLocations("gold locs");

   rmSetProgress(0.6);

   // Hunt.
   float avoidHuntMeters = 50.0;

   // Close hunt.
   int closeHuntID = rmObjectDefCreate("close hunt");
   rmObjectDefAddItem(closeHuntID, cUnitTypeElk, xsRandInt(5, 9));
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeHuntID, avoidPond6);
   rmObjectDefAddConstraint(closeHuntID, createTownCenterConstraint(60.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(closeHuntID, false, 1, 60.0, 80.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(closeHuntID, false, 1, 60.0, 80.0, avoidHuntMeters);
   }

   // Far hunt 1.
   float farHuntFloat = xsRandFloat(0.0, 1.0);
   int farHunt1ID = rmObjectDefCreate("far hunt 1");
   if(farHuntFloat < 1.0 / 3.0)
   {
      rmObjectDefAddItem(farHunt1ID, cUnitTypeElk, xsRandInt(6, 9));
   }
   else if(farHuntFloat < 2.0 / 3.0)
   {
      rmObjectDefAddItem(farHunt1ID, cUnitTypeCaribou, xsRandInt(6, 10));
   }
   else
   {
      rmObjectDefAddItem(farHunt1ID, cUnitTypeAurochs, xsRandInt(2, 4));
   }
   rmObjectDefAddConstraint(farHunt1ID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(farHunt1ID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(farHunt1ID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(farHunt1ID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(farHunt1ID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(farHunt1ID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(farHunt1ID, avoidPond6);
   rmObjectDefAddConstraint(farHunt1ID, createTownCenterConstraint(80.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(farHunt1ID, false, xsRandInt(1, 2), 80.0, 100.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(farHunt1ID, false, xsRandInt(1, 2), 80.0, 100.0, avoidHuntMeters);
   }

   // Far hunt 2.
   int farHunt2ID = rmObjectDefCreate("far hunt 2");
   rmObjectDefAddItem(farHunt2ID, cUnitTypeBoar, xsRandInt(2, 4));
   rmObjectDefAddConstraint(farHunt2ID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(farHunt2ID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(farHunt2ID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(farHunt2ID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(farHunt2ID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(farHunt2ID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(farHunt2ID, avoidPond6);
   rmObjectDefAddConstraint(farHunt2ID, createTownCenterConstraint(80.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(farHunt2ID, false, 1, 90.0, 120.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(farHunt2ID, false, 1, 90.0, 120.0, avoidHuntMeters);
   }

   // Large / Giant map size hunt.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      float largeMapHuntFloat = xsRandFloat(0.0, 1.0);
      int largeMapHuntID = rmObjectDefCreate("large map hunt");
      if(largeMapHuntFloat < 1.0 / 3.0)
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeElk, xsRandInt(6, 12));
      }
      else if(largeMapHuntFloat < 2.0 / 3.0)
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeAurochs, xsRandInt(2, 4));
      }
      else
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeBoar, xsRandInt(2, 4));
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeCaribou, xsRandInt(3, 6));
      }

      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidAll);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidEdge);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidImpassableLand10);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultFoodAvoidGold);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidSettlementRange);
      rmObjectDefAddConstraint(largeMapHuntID, avoidPond6);
      rmObjectDefAddConstraint(largeMapHuntID, createTownCenterConstraint(80.0));
      addObjectLocsPerPlayer(largeMapHuntID, false, 1 * getMapSizeBonusFactor(), 100.0, -1.0, avoidHuntMeters);
   }

   generateLocations("hunt locs");

   rmSetProgress(0.7);

   // Player fish.
   for(int i = 1; i <= cNumberPlayers; i++)
   {
      int p = vDefaultTeamPlayerOrder[i];
      float minAngle = -0.025 * cPi + vPlayerForwardAnglesByPlayer[p];
      float maxAngle = 0.025 * cPi + vPlayerForwardAnglesByPlayer[p];
      int playerAngleConstraint = rmCreateCircularConstraint(rmGetPlayerLoc(p), cMaxFloat, minAngle, maxAngle);

      int playerFishID = rmObjectDefCreate("player fish " + p);
      rmObjectDefAddItem(playerFishID, cUnitTypePerch, 3, 5.0);
      rmObjectDefAddConstraint(playerFishID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 9.0));
      rmObjectDefAddConstraint(playerFishID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, true, 12.0));
      rmObjectDefAddConstraint(playerFishID, playerAngleConstraint);
      rmObjectDefAddConstraint(playerFishID, rmCreateAreaConstraint(rmAreaGetID(cPlayerAreaName + " " + p)));
      // TODO Syscall to place at player loc.
      rmObjectDefPlaceAtLoc(playerFishID, 0, rmGetPlayerLoc(p), 0.0, rmXFractionToMeters(0.5));
   }

   // Global fish.
   if(gameIs1v1() == true && cMapSizeCurrent == cMapSizeStandard)
   {
      float fishDistMeters = 18.0;

      int fishID = rmObjectDefCreate("1v1 fish");
      rmObjectDefAddItem(fishID, cUnitTypePerch, 2, 6.0);
      rmObjectDefAddConstraint(fishID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 10.0));
      rmObjectDefAddConstraint(fishID, rmCreateTypeDistanceConstraint(cUnitTypeFishResource, fishDistMeters));
      // Don't force in any area so we get a more random pattern.
      addMirroredObjectLocsPerPlayer(fishID, false, 3, 20.0, rmXFractionToMeters(0.5), fishDistMeters);

      generateLocations("fish locs");
   }
   else
   {
      float fishDistMeters = 20.0;

      int fishID = rmObjectDefCreate("global fish");
      rmObjectDefAddItem(fishID, cUnitTypePerch, 2, 6.0);
      rmObjectDefAddConstraint(fishID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 10.0));
      //rmObjectDefAddConstraint(fishID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, true, 50.0));
      rmObjectDefAddConstraint(fishID, rmCreateTypeDistanceConstraint(cUnitTypeFishResource, fishDistMeters));
      rmObjectDefPlaceAnywhere(fishID, 0, 4 * cNumberPlayers * getMapAreaSizeFactor());
   }

   // Herdables.
   float avoidHerdMeters = 50.0;

   int closeHerdID = rmObjectDefCreate("close herd");
   rmObjectDefAddItem(closeHerdID, cUnitTypeCow, xsRandInt(1, 2));
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeHerdID, avoidPond6);
   addObjectLocsPerPlayer(closeHerdID, false, 1, 50.0, 70.0, avoidHerdMeters);

   int bonusHerdID = rmObjectDefCreate("bonus herd");
   rmObjectDefAddItem(bonusHerdID, cUnitTypeCow, xsRandInt(1, 2));
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusHerdID, avoidPond6);
   addObjectLocsPerPlayer(bonusHerdID, false, xsRandInt(1, 2) * getMapAreaSizeFactor(), 70.0, -1.0, avoidHerdMeters);

   generateLocations("herd locs");

   // Predators.
   int predatorsID = rmObjectDefCreate("predator");
   if(xsRandBool(0.5) == true)
   {
      rmObjectDefAddItem(predatorsID, cUnitTypeWolf, xsRandInt(2, 3));
   }
   else
   {
      rmObjectDefAddItem(predatorsID, cUnitTypeBear, xsRandInt(1, 2));
   }
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(predatorsID, vDefaultFoodAvoidFood);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(predatorsID, avoidPond6);
   rmObjectDefAddConstraint(predatorsID, createTownCenterConstraint(80.0));
   addObjectLocsPerPlayer(predatorsID, false, xsRandInt(1, 2) * getMapAreaSizeFactor(), 80.0, -1.0, 50.0);

   generateLocations("predator locs");

   // Berries.
   int berriesID = rmObjectDefCreate("berries");
   rmObjectDefAddItem(berriesID, cUnitTypeBerryBush, xsRandInt(8, 12), 5.0);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(berriesID, vDefaultFoodAvoidFood);
   rmObjectDefAddConstraint(berriesID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(berriesID, avoidPond16);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(berriesID, createTownCenterConstraint(50.0));
   addObjectLocsPerPlayer(berriesID, false, xsRandInt(1, 2) * getMapAreaSizeFactor(), 80.0, -1.0, 40.0);

   generateLocations("berries locs");

   // Relics.
   int outerRelicID = rmObjectDefCreate("outer relic");
   rmObjectDefAddItem(outerRelicID, cUnitTypeRelic, 1);
   rmObjectDefAddConstraint(outerRelicID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(outerRelicID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(outerRelicID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(outerRelicID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(outerRelicID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(outerRelicID, createTownCenterConstraint(50.0));
   rmObjectDefAddConstraint(outerRelicID, avoidPond6);
   addObjectLocsPerPlayer(outerRelicID, false, 1 * getMapSizeBonusFactor(), 80.0, -1.0, 60.0);

   generateLocations("outer relic locs");

   rmSetProgress(0.8);

   // Stragglers.
   placeStartingStragglers(cUnitTypeTreeTundraSnow);
   
   int forestAvoidPond = rmCreateClassDistanceConstraint(pondAreaClassID, 22.0);

   forestGenAddType(cForestTundraSnow);
   forestGenSetAreaTiles(75, 125);
   forestGenSetSelfAvoidDist(25.0);
   forestGenAddConstraint(vDefaultAvoidAll);
   forestGenAddConstraint(vDefaultForestAvoidTownCenter);
   forestGenAddConstraint(vDefaultAvoidSettlementWithFarm);
   forestGenAddConstraint(vDefaultAvoidImpassableLand10);
   forestGenAddConstraint(forestAvoidPond);

   forestGenGeneratePlayerForests(2, cDefaultPlayerForestOriginMinDist, cDefaultPlayerForestOriginMaxDist);
   forestGenGenerateGlobalForests(12 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(0.9);

   // Embellishment.

   // Gold areas.
   buildAreaUnderObjectDef(startingGoldID, cTerrainTundraSnowRocks2, cTerrainTundraSnowRocks1, 7.0);
   buildAreaUnderObjectDef(startingGoldSmallID, cTerrainTundraSnowRocks2, cTerrainTundraSnowRocks1, 6.0);
   buildAreaUnderObjectDef(closeGoldID, cTerrainTundraSnowRocks2, cTerrainTundraSnowRocks1, 5.0);
   buildAreaUnderObjectDef(farGoldID, cTerrainTundraSnowRocks2, cTerrainTundraSnowRocks1, 5.0);
   buildAreaUnderObjectDef(bonusGoldID, cTerrainTundraSnowRocks2, cTerrainTundraSnowRocks1, 5.0);

   // Berries areas.
   buildAreaUnderObjectDef(startingBerriesID, cTerrainNorseSnowGrass3, cTerrainNorseSnowGrass2, 8.0);
   buildAreaUnderObjectDef(berriesID, cTerrainNorseSnowGrass3, cTerrainNorseSnowGrass2, 8.0);

   // Random trees.
   int randomTreeID = rmObjectDefCreate("random tree");

   rmObjectDefAddItem(randomTreeID, cUnitTypeTreeTundra, 1);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(randomTreeID, vDefaultEmbellishmentTreeAvoidTree);
   rmObjectDefAddConstraint(randomTreeID, avoidPond6);
   rmObjectDefPlaceAnywhere(randomTreeID, 0, 6 * cNumberPlayers * getMapAreaSizeFactor());

   int randomTreePondID = rmObjectDefCreate("random tree pond");
   rmObjectDefAddItem(randomTreePondID, cUnitTypeTreePineSnow, 1);
   rmObjectDefAddConstraint(randomTreePondID, rmCreateAreaConstraint(innerPondAreaID));
   rmObjectDefAddConstraint(randomTreePondID, avoidLake5);
   rmObjectDefPlaceAnywhere(randomTreePondID, 0, 50 * cNumberPlayers * getMapAreaSizeFactor());

   // Rocks.
   int rockTinyID = rmObjectDefCreate("rock tiny");
   rmObjectDefAddItem(rockTinyID, cUnitTypeRockGreekTiny, 1);
   rmObjectDefAddConstraint(rockTinyID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefPlaceAnywhere(rockTinyID, 0, 15 * cNumberPlayers * getMapAreaSizeFactor());

   int rockSmallID = rmObjectDefCreate("rock small");
   rmObjectDefAddItem(rockSmallID, cUnitTypeRockGreekSmall, 1);
   rmObjectDefPlaceAnywhere(rockSmallID, 0, 35 * cNumberPlayers);

   int rockLargeID = rmObjectDefCreate("rock large");
   rmObjectDefAddItem(rockLargeID, cUnitTypeRockGreekLarge, 1);
   rmObjectDefAddConstraint(rockLargeID, rmCreateAreaConstraint(innerPondAreaID));
   rmObjectDefAddConstraint(rockLargeID, avoidLake5);
   rmObjectDefAddConstraint(rockLargeID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefPlaceAnywhere(rockLargeID, 0, 8 * cNumberPlayers * getMapAreaSizeFactor());

   // Plants.
   int plantGrassID = rmObjectDefCreate("plant grass");
   rmObjectDefAddItem(plantGrassID, cUnitTypePlantNorseGrass, 1);
   rmObjectDefAddConstraint(plantGrassID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantGrassID, avoidPond6);
   rmObjectDefPlaceAnywhere(plantGrassID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantBushID = rmObjectDefCreate("plant bush");
   rmObjectDefAddItem(plantBushID, cUnitTypePlantNorseBush, 1);
   rmObjectDefAddConstraint(plantBushID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantBushID, avoidPond6);
   rmObjectDefPlaceAnywhere(plantBushID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantShrubID = rmObjectDefCreate("plant shrub");
   rmObjectDefAddItem(plantShrubID, cUnitTypePlantNorseShrub, 1);
   rmObjectDefAddConstraint(plantShrubID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantShrubID, avoidPond6);
   rmObjectDefPlaceAnywhere(plantShrubID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantFernID = rmObjectDefCreate("plant fern");
   rmObjectDefAddItem(plantFernID, cUnitTypePlantNorseFern, 1);
   rmObjectDefAddConstraint(plantFernID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantFernID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(plantFernID, avoidPond6);
   rmObjectDefPlaceAnywhere(plantFernID, 0, 12 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantWeedsID = rmObjectDefCreate("plant weeds");
   rmObjectDefAddItem(plantWeedsID, cUnitTypePlantNorseWeeds, 1);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(plantWeedsID, avoidPond6);
   rmObjectDefPlaceAnywhere(plantWeedsID, 0, 15 * cNumberPlayers * getMapAreaSizeFactor());

   // Logs.
   int logID = rmObjectDefCreate("log");
   rmObjectDefAddItem(logID, cUnitTypeRottingLog, 1);
   rmObjectDefAddConstraint(logID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(logID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(logID, avoidPond6);
   rmObjectDefPlaceAnywhere(logID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());

   // Birbs.
   int birdID = rmObjectDefCreate("bird");
   rmObjectDefAddItem(birdID, cUnitTypeHawk, 1);
   rmObjectDefPlaceAnywhere(birdID, 0, 2 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(1.0);
}
