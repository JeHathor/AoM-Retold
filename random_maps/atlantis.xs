include "lib/rm_core.xs";
include "lib/rm_beautification.xs";
include "lib/rm_forests.xs";
include "lib/rm_connections.xs";

//ATLANTIS by JeHathor (SEP 2024)
void generate()
{
   rmSetProgress(0.0);

   // Map size and terrain init.
   int axisTiles = getAxisTilesFromCount() * 1.5;
   rmSetMapSize(axisTiles);
   rmInitializeWater(cWaterAtlanteanSea);

   // Mother Nature's civ.
   rmSetNatureCivFromCulture(cCultureAtlantean);

   // Lighting.
   rmSetLighting("biome_greek_temperate_day_01_mod");	/*tna11*/

   // Define mixes.
   int baseMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(baseMixID, cNoiseFractalSum, 0.25, 5, 0.1);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainAtlanteanGrass2, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainAtlanteanGrass1, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainAtlanteanGrassRocks1, 2.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainAtlanteanGrassDirt1, 3.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainAtlanteanGrassDirt2, 3.0);

   // Define classes.
   int centralIslandClassID = rmClassCreate();
   int avoidCentralIslandConstraint = rmCreateClassDistanceConstraint(centralIslandClassID, 1.0);

   int mainIslandClassID = rmClassCreate();
   int avoidMainIslandConstraint = rmCreateClassDistanceConstraint(mainIslandClassID, 3.0);

   int bonusIslandClassID = rmClassCreate();
   int avoidBonusIslandConstraint = rmCreateClassDistanceConstraint(bonusIslandClassID, 25);

   int shortAvoidAll = rmCreateTypeDistanceConstraint(cUnitTypeAll, 4.0);

   // Water overrides.
   rmWaterTypeAddBeachLayer(cWaterAtlanteanSea, cTerrainAtlanteanBeach1, 3.0, 2.0);
   rmWaterTypeAddBeachLayer(cWaterAtlanteanSea, cTerrainAtlanteanGrassDirt3, 5.0, 2.0);
   rmWaterTypeAddBeachLayer(cWaterAtlanteanSea, cTerrainAtlanteanGrassDirt2, 7.0, 2.0);

   //---------------------------------------------
   // large land ring
   //---------------------------------------------
   int landRingLargeID = rmAreaCreate("Large Island");
   rmAreaSetSize(landRingLargeID, 0.5);
   rmAreaSetLoc(landRingLargeID, cCenterLoc);
   rmAreaSetMix(landRingLargeID, baseMixID);

   rmAreaSetHeightNoise(landRingLargeID, cNoiseFractalSum, 5.0, 0.1, 2, 0.5);
   rmAreaSetHeightNoiseBias(landRingLargeID, 1.0);
   rmAreaSetHeightNoiseEdgeFalloffDist(landRingLargeID, 20.0);

   rmAreaSetHeight(landRingLargeID, 0.25);
   rmAreaAddHeightBlend(landRingLargeID, cBlendEdge, cFilter5x5Gaussian, 10, 10);

   rmAreaSetCoherence(landRingLargeID, 0.9);
   rmAreaSetEdgeSmoothDistance(landRingLargeID, 15);
   rmAreaAddConstraint(landRingLargeID, createSymmetricBoxConstraint(0.075), 0.0, 10.0);

   rmAreaAddToClass(landRingLargeID, mainIslandClassID);
   rmAreaBuild(landRingLargeID);

   //---------------------------------------------
   // large water ring
   //---------------------------------------------
   int waterRingLargeID = rmAreaCreate("Large Lake");
   rmAreaSetSize(waterRingLargeID, 0.2);
   rmAreaSetLoc(waterRingLargeID, cCenterLoc);
   rmAreaSetWaterType(waterRingLargeID, cWaterAtlanteanSea);
   rmAreaSetCoherence(waterRingLargeID, 0.9);

   rmAreaAddToClass(waterRingLargeID, mainIslandClassID);
   rmAreaBuild(waterRingLargeID);

   //---------------------------------------------
   // medium land ring
   //---------------------------------------------
   int landRingMediumID = rmAreaCreate("Medium Island");
   rmAreaSetSize(landRingMediumID, 0.1);
   rmAreaSetLoc(landRingMediumID, cCenterLoc);
   rmAreaSetMix(landRingMediumID, baseMixID);

   rmAreaSetHeightNoise(landRingMediumID, cNoiseFractalSum, 5.0, 0.1, 2, 0.5);
   rmAreaSetHeightNoiseBias(landRingMediumID, 1.0);
   rmAreaSetHeightNoiseEdgeFalloffDist(landRingMediumID, 20.0);

   rmAreaSetHeight(landRingMediumID, 0.25);
   rmAreaAddHeightBlend(landRingMediumID, cBlendEdge, cFilter5x5Gaussian, 8, 8);

   rmAreaSetCoherence(landRingMediumID, 0.9);
   rmAreaSetEdgeSmoothDistance(landRingMediumID, 15);

   rmAreaAddToClass(landRingMediumID, mainIslandClassID);
   rmAreaBuild(landRingMediumID);

   //---------------------------------------------
   // medium water ring
   //---------------------------------------------
   int waterRingMediumID = rmAreaCreate("Medium Lake");
   rmAreaSetSize(waterRingMediumID, 0.05);
   rmAreaSetLoc(waterRingMediumID, cCenterLoc);
   rmAreaSetWaterType(waterRingMediumID, cWaterAtlanteanHybrid);
   rmAreaSetCoherence(waterRingMediumID, 0.9);

   rmAreaAddToClass(waterRingMediumID, mainIslandClassID);
   rmAreaBuild(waterRingMediumID);

   //---------------------------------------------
   // player placement
   //---------------------------------------------
   rmSetTeamSpacingModifier(0.9);
   rmPlacePlayersOnCircle(0.4);

   // Finalize player placement and do post-init things.
   postPlayerPlacement();

   // Player resources.
   for(int i = 1; i <= cNumberPlayers; i++)
   {
      rmAddPlayerResource(i, cResourceWood, 100.0);
   }

   //---------------------------------------------
   // player water ring
   //---------------------------------------------
   for(int i = 1; i <= cNumberPlayers; i++)
   {
	int p = vDefaultTeamPlayerOrder[i];

	int playerWaterID = rmAreaCreate("Starting Channel" + p);
	rmAreaSetSize(playerWaterID, rmRadiusToAreaFraction(48.0));
	rmAreaSetLoc(playerWaterID, rmGetPlayerLoc(p));
	rmAreaSetWaterType(playerWaterID, cWaterAtlanteanSea);
	rmAreaSetCoherence(playerWaterID, 0.9);
	rmAreaAddToClass(playerWaterID, mainIslandClassID);
   }
   rmAreaBuildAll();

   //---------------------------------------------
   // channel of atlantis
   //---------------------------------------------
   int pathDefID = rmPathDefCreate("path def");
   rmPathDefSetCostNoise(pathDefID, 0.0, 8.0);

   int pathAreaDefID = rmAreaDefCreate("path area def");
   rmAreaDefSetWaterType(pathAreaDefID, cWaterAtlanteanHybrid);

   createPlayerToAreaConnections("player connection", pathDefID, pathAreaDefID, waterRingMediumID, 30.0 + (5 * getMapSizeBonusFactor()));

   rmSetProgress(0.1);

   //---------------------------------------------
   // center island
   //---------------------------------------------
   int landRingSmallID = rmAreaCreate("Small Island");
   rmAreaSetSize(landRingSmallID, 0.02);
   rmAreaSetLoc(landRingSmallID, cCenterLoc);
   rmAreaSetMix(landRingSmallID, baseMixID);

   rmAreaSetHeight(landRingSmallID, 0.50);
   rmAreaAddHeightBlend(landRingSmallID, cBlendEdge, cFilter5x5Gaussian, 4, 4);

   rmAreaSetCoherence(landRingSmallID, 0.9);
   rmAreaSetEdgeSmoothDistance(landRingSmallID, 15);

   rmAreaAddToClass(landRingSmallID, centralIslandClassID);
   rmAreaAddToClass(landRingSmallID, mainIslandClassID);
   rmAreaBuild(landRingSmallID);

   //---------------------------------------------
   // center hill
   //---------------------------------------------
   int centralElevationID = rmAreaCreate("central hill");
   rmAreaSetSize(centralElevationID, 0.015);
   rmAreaSetLoc(centralElevationID, cCenterLoc);
   rmAreaSetMix(centralElevationID, baseMixID);

   rmAreaSetCliffType(centralElevationID, cCliffAtlanteanGrass);
   if (gameIs1v1() == true)
   {
      rmAreaSetCliffRamps(centralElevationID, 4, 0.1);
   }
   else
   {
      rmAreaSetCliffRamps(centralElevationID, cNumberPlayers, 0.1);
   }
   rmAreaSetCliffRampSteepness(centralElevationID, 100.0);
   rmAreaSetCliffEmbellishmentDensity(centralElevationID, 0.25);
   rmAreaSetCliffSideRadius(centralElevationID, 1, 1);

   rmAreaSetHeightRelative(centralElevationID, 7);

   int blendIdx = rmAreaAddHeightBlend(centralElevationID, cBlendAll, cFilter3x3Box, 10, 5, true, true);
   rmAreaAddHeightBlendConstraint(centralElevationID, blendIdx, vDefaultAvoidImpassableLand);
   rmAreaAddHeightBlendExpansionConstraint(centralElevationID, blendIdx, vDefaultAvoidImpassableLand);

   rmAreaSetEdgeSmoothDistance(centralElevationID, 5);
   rmAreaSetCoherence(centralElevationID, 0.9);

   rmAreaSetHeightNoise(centralElevationID, cNoiseFractalSum, 3.0, 0.1, 2, 0.5);
   rmAreaBuild(centralElevationID);

   //---------------------------------------------
   // center objects
   //---------------------------------------------
   if (gameIsKotH() == false)
   {
      // Add some embellishment to the center.
      int centerTempleID = rmObjectDefCreate("center temple");
      rmObjectDefAddItem(centerTempleID, cUnitTypeSettlement, 1);
      rmObjectDefPlaceAtLoc(centerTempleID, 0, cCenterLoc);
   }

   int centerTorchID = rmObjectDefCreate("center torch");
   rmObjectDefAddItem(centerTorchID, cUnitTypeTorch, 1);
   rmObjectDefSetItemVariation(centerTorchID, 0, 0);
   placeObjectDefInCircle(centerTorchID, 0, false, 6, 16.0);
   
   // KotH.
   placeKotHObjects();

   rmSetProgress(0.2);

   //---------------------------------------------
   // player Islands
   //---------------------------------------------
   for(int i = 1; i <= cNumberPlayers; i++)
   {
	int p = vDefaultTeamPlayerOrder[i];

	int playerIslandID = rmAreaCreate("Starting Island" + p);

	rmAreaSetSize(playerIslandID, rmRadiusToAreaFraction(34.0));
	rmAreaSetLoc(playerIslandID, rmGetPlayerLoc(p));
	rmAreaSetMix(playerIslandID, baseMixID);

	rmAreaSetHeight(playerIslandID, 0.25);
	rmAreaAddHeightBlend(playerIslandID, cBlendEdge, cFilter5x5Gaussian, 2, 2);

	rmAreaSetCoherence(playerIslandID, 0.9);
	rmAreaSetEdgeSmoothDistance(playerIslandID, 15);
	rmAreaAddToClass(playerIslandID, mainIslandClassID);
   }
   rmAreaBuildAll();

   //---------------------------------------------
   // starting town centers
   //---------------------------------------------
   int startingTownCenterID = rmObjectDefCreate("starting town center");
   rmObjectDefAddItem(startingTownCenterID, cUnitTypeTownCenter, 1);
   rmObjectDefPlacePerPlayer(startingTownCenterID, true, 1);

   //---------------------------------------------
   // starting towers
   //---------------------------------------------
   int startingTowerID = rmObjectDefCreate("starting tower");
   rmObjectDefAddItem(startingTowerID, cUnitTypeSentryTower, 1);
   addObjectLocsPerPlayer(startingTowerID, true, 5, cStartingTowerMinDist*0.6, cStartingTowerMaxDist*0.6, cStartingTowerAvoidanceMeters*0.6);
   generateLocations("starting tower locs");

   //---------------------------------------------
   // bonus islands
   //---------------------------------------------
   int numBonusIslands = 3 * cNumberPlayers * getMapAreaSizeFactor();
   float bonusIslandMinSize = rmTilesToAreaFraction(500 * getMapAreaSizeFactor());
   float bonusIslandMaxSize = rmTilesToAreaFraction(800 * getMapAreaSizeFactor());
   int bonusIslandOriginAvoidEdge = createSymmetricBoxConstraint(rmXTilesToFraction(20));

   for(int i = 1; i <= numBonusIslands; i++)
   {
      int bonusIslandID = rmAreaCreate("bonus island " + i);
      rmAreaSetSize(bonusIslandID, xsRandFloat(bonusIslandMinSize, bonusIslandMaxSize));
      rmAreaSetMix(bonusIslandID, baseMixID);

      rmAreaSetHeight(bonusIslandID, 0.0);
      rmAreaSetEdgeSmoothDistance(bonusIslandID, 10, false);
      rmAreaAddHeightBlend(bonusIslandID, cBlendEdge, cFilter5x5Gaussian, 10, 10);
      
      rmAreaSetHeightNoise(bonusIslandID, cNoiseFractalSum, 5.0, 0.1, 3, 0.5);
      rmAreaSetHeightNoiseBias(bonusIslandID, 1.0);
      rmAreaSetHeightNoiseEdgeFalloffDist(bonusIslandID, 15.0);

      rmAreaSetBlobs(bonusIslandID, 0, 4);
      rmAreaSetBlobDistance(bonusIslandID, 15.0);

      rmAreaAddConstraint(bonusIslandID, avoidBonusIslandConstraint);
      rmAreaAddConstraint(bonusIslandID, avoidMainIslandConstraint);
      rmAreaAddConstraint(bonusIslandID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 30.0));
      rmAreaAddOriginConstraint(bonusIslandID, bonusIslandOriginAvoidEdge);
      rmAreaAddToClass(bonusIslandID, bonusIslandClassID);

      rmAreaBuild(bonusIslandID);
   }

   rmSetProgress(0.3);

   //---------------------------------------------
   // settlements
   //---------------------------------------------
   int firstSettlementID = rmObjectDefCreate("first settlement");
   rmObjectDefAddItem(firstSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidChampionSiegeShipRange);
   rmObjectDefAddConstraint(firstSettlementID, avoidCentralIslandConstraint);
   rmObjectDefAddConstraint(firstSettlementID, avoidBonusIslandConstraint);

   int secondSettlementID = rmObjectDefCreate("second settlement");
   rmObjectDefAddItem(secondSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidChampionSiegeShipRange);
   rmObjectDefAddConstraint(secondSettlementID, avoidCentralIslandConstraint);
   rmObjectDefAddConstraint(secondSettlementID, avoidBonusIslandConstraint);

   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(firstSettlementID, false, 1, 60.0, 80.0, cSettlementDist1v1, cBiasBackward);
      add1v1ObjectSimLocs(secondSettlementID, false, 1, 70.0, 90.0, cSettlementDist1v1, cBiasAggressive);
   }
   else
   {
      addObjectLocsPerPlayer(firstSettlementID, false, 1, 60.0, 80.0, cCloseSettlementDist, cBiasBackward | cBiasAllyInside);
      addObjectLocsPerPlayer(secondSettlementID, false, 1, 80.0, 100.0, cFarSettlementDist, cBiasAggressive | getRandomAllyBias());
   }

   // Large / Giant map settlements.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      int thirdSettlementID = rmObjectDefCreate("third settlement");
      rmObjectDefAddItem(thirdSettlementID, cUnitTypeSettlement, 1);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidChampionSiegeShipRange);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultSettlementAvoidEdge);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(thirdSettlementID, avoidMainIslandConstraint);
      addObjectLocsPerPlayer(thirdSettlementID, false, 1 * getMapAreaSizeFactor(), 90.0, -1.0, 100.0);
   }

   generateLocations("settlement locs");

   rmSetProgress(0.4);

   //---------------------------------------------
   // player gold
   //---------------------------------------------
   float avoidGoldMeters = 50.0;

   int playerGoldID = rmObjectDefCreate("player gold");
   rmObjectDefAddItem(playerGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(playerGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(playerGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(playerGoldID, vDefaultAvoidWater10);
   rmObjectDefAddConstraint(playerGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(playerGoldID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(playerGoldID, avoidBonusIslandConstraint);
   rmObjectDefAddConstraint(playerGoldID, avoidCentralIslandConstraint);
   addObjectLocsPerPlayer(playerGoldID, false, 2, 40.0, 100.0, avoidGoldMeters, cInAreaPlayer);

   generateLocations("player gold locs");

   //---------------------------------------------
   // starting gold
   //---------------------------------------------
   int startingGoldID = rmObjectDefCreate("starting gold");
   rmObjectDefAddItem(startingGoldID, cUnitTypeMineGoldMedium, 1);
   rmObjectDefAddConstraint(startingGoldID, shortAvoidAll);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidWater5);
   rmObjectDefAddConstraint(startingGoldID, vDefaultStartingGoldAvoidTower);
   rmObjectDefAddConstraint(startingGoldID, vDefaultForceStartingGoldNearTower);
   addObjectLocsPerPlayer(startingGoldID, false, 1, cStartingGoldMinDist*0.75, cStartingGoldMaxDist, cStartingObjectAvoidanceMeters*0.5);

   generateLocations("starting gold locs");

   rmSetProgress(0.5);

   //---------------------------------------------
   // starting herdables
   //---------------------------------------------
   int startingHerdID = rmObjectDefCreate("starting herd");
   rmObjectDefAddItem(startingHerdID, cUnitTypeGoat, xsRandInt(4, 5));
   rmObjectDefAddConstraint(startingHerdID, shortAvoidAll);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidWater5);
   addObjectLocsPerPlayer(startingHerdID, true, 1, cStartingHerdMinDist*0.75, cStartingHerdMaxDist);

   //---------------------------------------------
   // starting berries
   //---------------------------------------------
   int startingplayerBerriesID = rmObjectDefCreate("starting berries");
   rmObjectDefAddItem(startingplayerBerriesID, cUnitTypeBerryBush, xsRandInt(6, 10), 2.0);
   rmObjectDefAddConstraint(startingplayerBerriesID, shortAvoidAll);
   rmObjectDefAddConstraint(startingplayerBerriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingplayerBerriesID, vDefaultAvoidWater5);
   rmObjectDefAddConstraint(startingplayerBerriesID, vDefaultFoodAvoidGold);
   addObjectLocsPerPlayer(startingplayerBerriesID, false, 1, cStartingBerriesMinDist*0.75, cStartingBerriesMaxDist, cStartingObjectAvoidanceMeters*0.5);

   generateLocations("starting food locs");

   //---------------------------------------------
   // starting chicken
   //---------------------------------------------
   int startingChickenID = rmObjectDefCreate("starting chicken");
   rmObjectDefAddItem(startingChickenID, cUnitTypeChicken, xsRandInt(6, 10));
   rmObjectDefAddConstraint(startingChickenID, shortAvoidAll);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidWater5);
   rmObjectDefAddConstraint(startingChickenID, vDefaultFoodAvoidGold);
   addObjectLocsPerPlayer(startingChickenID, false, 1, cStartingChickenMinDist*0.75, cStartingChickenMaxDist, cStartingObjectAvoidanceMeters*0.5);

   rmSetProgress(0.6);

   //---------------------------------------------
   // player hunt
   //---------------------------------------------
   float avoidHuntMeters = 40.0;

   int numPlayerHunt = xsRandInt(2, 3);

   for(int i = 0; i < numPlayerHunt; i++)
   {
      float huntFloat = xsRandFloat(0.0, 1.0);
      int playerHuntID = rmObjectDefCreate("player hunt " + i);
      if(huntFloat < 1.0 / 3.0)
      {
         rmObjectDefAddItem(playerHuntID, cUnitTypeDeer, xsRandInt(6, 9));
      }
      else if(huntFloat < 2.0 / 3.0)
      {
         rmObjectDefAddItem(playerHuntID, cUnitTypeBoar, xsRandInt(1, 3));
         rmObjectDefAddItem(playerHuntID, cUnitTypeDeer, xsRandInt(2, 4));
      }
      else
      {
         rmObjectDefAddItem(playerHuntID, cUnitTypeAurochs, xsRandInt(2, 4));
      }
      rmObjectDefAddConstraint(playerHuntID, vDefaultAvoidAll);
      rmObjectDefAddConstraint(playerHuntID, vDefaultAvoidEdge);
      rmObjectDefAddConstraint(playerHuntID, vDefaultAvoidWater5);
      rmObjectDefAddConstraint(playerHuntID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(playerHuntID, vDefaultFoodAvoidGold);
      rmObjectDefAddConstraint(playerHuntID, vDefaultAvoidSettlementWithFarm);
      rmObjectDefAddConstraint(playerHuntID, avoidBonusIslandConstraint);
      rmObjectDefAddConstraint(playerHuntID, avoidCentralIslandConstraint);
      addObjectLocsPerPlayer(playerHuntID, false, 1, 40.0, -1.0, avoidHuntMeters, cInAreaPlayer);
   }

   generateLocations("player hunt locs");

   //---------------------------------------------
   // bonus gold
   //---------------------------------------------
   int bonusGoldID = rmObjectDefCreate("bonus gold");
   rmObjectDefAddItem(bonusGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidWater5);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(bonusGoldID, avoidCentralIslandConstraint);
   rmObjectDefAddConstraint(bonusGoldID, avoidBonusIslandConstraint);
   addObjectLocsPerPlayer(bonusGoldID, false, xsRandInt(2, 4) * getMapSizeBonusFactor(), 70.0, -1.0, avoidGoldMeters);

   generateLocations("bonus gold locs");

   rmSetProgress(0.7);

   //---------------------------------------------
   // forest
   //---------------------------------------------
   forestGenAddType(cForestAtlanteanLush);
   forestGenSetAreaTiles(60, 80);
   forestGenSetSelfAvoidDist(30.0);
   forestGenAddConstraint(vDefaultAvoidAll);
   forestGenAddConstraint(vDefaultForestAvoidTownCenter);
   forestGenAddConstraint(vDefaultAvoidSettlementWithFarm);
   forestGenAddConstraint(vDefaultAvoidWater5);
   forestGenAddConstraint(avoidCentralIslandConstraint);

   forestGenGeneratePlayerForests(2, cDefaultPlayerForestOriginMinDist, cDefaultPlayerForestOriginMaxDist);
   forestGenGenerateGlobalForests(15 * cNumberPlayers * getMapAreaSizeFactor());

   //---------------------------------------------
   // relics
   //---------------------------------------------
   float avoidRelicMeters = 50.0;

   int relicNumPerPlayer = 2 * getMapAreaSizeFactor();
   
   int numRelicsPerPlayer = min(relicNumPerPlayer * cNumberPlayers, cMaxRelics) / cNumberPlayers;

   int relicID = rmObjectDefCreate("relic");
   rmObjectDefAddItem(relicID, cUnitTypeRelic, 1);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidWater5);
   rmObjectDefAddConstraint(relicID, avoidMainIslandConstraint);
   addObjectLocsPerPlayer(relicID, false, numRelicsPerPlayer, 80.0, -1.0, avoidRelicMeters);

   generateLocations("relic locs");

   //---------------------------------------------
   // starting trees
   //---------------------------------------------
   placeStartingStragglers(cUnitTypeTreePalm);

   rmSetProgress(0.8);

   //---------------------------------------------
   // player fish
   //---------------------------------------------
   for(int i = 1; i <= cNumberPlayers; i++)
   {
      int p = vDefaultTeamPlayerOrder[i];
      float minAngle = 0.95 * cPi + vPlayerForwardAnglesByPlayer[p];
      float maxAngle = 1.05 * cPi + vPlayerForwardAnglesByPlayer[p];
      int playerAngleConstraint = rmCreateCircularConstraint(rmGetPlayerLoc(p), cMaxFloat, minAngle, maxAngle);

      int playerFishID = rmObjectDefCreate("player fish " + p);
      rmObjectDefAddItem(playerFishID, cUnitTypeMahi, 3, 5.0);
      rmObjectDefAddConstraint(playerFishID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 9.0));
      rmObjectDefAddConstraint(playerFishID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, true, 12.0));
      rmObjectDefAddConstraint(playerFishID, avoidMainIslandConstraint);
      rmObjectDefAddConstraint(playerFishID, playerAngleConstraint);
      // TODO Checked place.
      // TODO Syscall to place at player loc.
      rmObjectDefPlaceAtLoc(playerFishID, 0, rmGetPlayerLoc(p), 0.0, rmXFractionToMeters(0.5));
   }

   //---------------------------------------------
   // random fish
   //---------------------------------------------
   float fishDistMeters = 30.0;
   int avoidFish = rmCreateTypeDistanceConstraint(cUnitTypeFishResource, fishDistMeters);
   int fishCornerBlock = createCornerAreas("fish corner block", rmXFractionToMeters(0.175));
   int fishAvoidCorner = rmCreateClassDistanceConstraint(fishCornerBlock, 0.1);

   int fishID = rmObjectDefCreate("global fish");
   rmObjectDefAddItem(fishID, cUnitTypeMahi, 3, 6.0);
   rmObjectDefAddConstraint(fishID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 10.0));
   rmObjectDefAddConstraint(fishID, createSymmetricBoxConstraint(0.02));
   rmObjectDefAddConstraint(fishID, avoidMainIslandConstraint);
   rmObjectDefAddConstraint(fishID, avoidFish);
   if(gameIs1v1() == true)
   {
      rmObjectDefAddConstraint(fishID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, true, 30.0));
      add1v1ObjectSimLocs(fishID, false, xsRandInt(5, 6) * getMapAreaSizeFactor(), 60.0, rmXFractionToMeters(0.75), fishDistMeters, cInAreaPlayer);
   }
   else
   {
      // TODO This probably needs more tuning later on.
      rmObjectDefAddConstraint(fishID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, true, 50.0));
      addObjectLocsPerPlayer(fishID, false, xsRandInt(5, 6) * getMapAreaSizeFactor(), 80.0, -1.0, fishDistMeters, cInAreaPlayer);
   }

   generateLocations("fish locs");

   // Bonus fish.
   int decoFishID = rmObjectDefCreate("bonus fish");
   rmObjectDefAddItem(decoFishID, cUnitTypeMahi, 1);
   rmObjectDefAddConstraint(decoFishID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 30.0));
   rmObjectDefAddConstraint(decoFishID, avoidFish);
   rmObjectDefAddConstraint(decoFishID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(decoFishID, avoidMainIslandConstraint);
   // Unchecked.
   rmObjectDefPlaceAnywhere(decoFishID, 0, 4 * cNumberPlayers * getMapAreaSizeFactor());

   //---------------------------------------------
   // random trees
   //---------------------------------------------
   int randomTreeID = rmObjectDefCreate("random tree");
   rmObjectDefAddItem(randomTreeID, cUnitTypeTreeOak, 1);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidWater5);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(randomTreeID, vDefaultEmbellishmentTreeAvoidTree);
   rmObjectDefAddConstraint(randomTreeID, avoidBonusIslandConstraint);
   rmObjectDefPlaceAnywhere(randomTreeID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(0.9);

   //---------------------------------------------
   // beautifications
   //---------------------------------------------

   // Rocks.
   int rockTinyID = rmObjectDefCreate("rock tiny");
   rmObjectDefAddItem(rockTinyID, cUnitTypeRockAtlanteanTiny, 1);
   rmObjectDefAddConstraint(rockTinyID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(rockTinyID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(rockTinyID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());

   int rockSmallID = rmObjectDefCreate("rock small");
   rmObjectDefAddItem(rockSmallID, cUnitTypeRockAtlanteanSmall, 1);
   rmObjectDefAddConstraint(rockSmallID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(rockSmallID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(rockSmallID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());

   // Plants.
   int plantGrassID = rmObjectDefCreate("plant grass");
   rmObjectDefAddItem(plantGrassID, cUnitTypePlantAtlanteanGrass, 1);
   rmObjectDefAddConstraint(plantGrassID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantGrassID, vDefaultAvoidWater5);
   rmObjectDefPlaceAnywhere(plantGrassID, 0, 35 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantShrubID = rmObjectDefCreate("plant shrub");
   rmObjectDefAddItem(plantShrubID, cUnitTypePlantAtlanteanShrub, 1);
   rmObjectDefAddConstraint(plantShrubID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantShrubID, vDefaultAvoidWater5);
   rmObjectDefPlaceAnywhere(plantShrubID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantFernID = rmObjectDefCreate("plant fern");
   rmObjectDefAddItemRange(plantFernID, cUnitTypePlantAtlanteanFern, 1, 2, 0.0, 4.0);
   rmObjectDefAddConstraint(plantFernID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantFernID, vDefaultAvoidWater5);
   rmObjectDefPlaceAnywhere(plantFernID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantWeedsID = rmObjectDefCreate("plant weeds");
   rmObjectDefAddItemRange(plantWeedsID, cUnitTypePlantAtlanteanWeeds, 1, 3, 0.0, 4.0);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultAvoidWater5);
   rmObjectDefPlaceAnywhere(plantWeedsID, 0, 15 * cNumberPlayers * getMapAreaSizeFactor());
   
   int flowersID = rmObjectDefCreate("flowers");
   rmObjectDefAddItemRange(flowersID, cUnitTypeFlowers, 1, 3, 0.0, 4.0);
   rmObjectDefAddConstraint(flowersID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(flowersID, vDefaultAvoidWater5);
   rmObjectDefPlaceAnywhere(flowersID, 0, 8 * cNumberPlayers * getMapAreaSizeFactor());

   // Seaweed.
   int seaweedID = rmObjectDefCreate("seaweed");
   rmObjectDefAddItem(seaweedID, cUnitTypeSeaweed, 3, 4.0);
   rmObjectDefAddConstraint(seaweedID, rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 2.5));
   rmObjectDefAddConstraint(seaweedID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, true, 5.0));
   rmObjectDefPlaceAnywhere(seaweedID, 0, 50 * cNumberPlayers * getMapAreaSizeFactor());

   // Birbs.
   int birdID = rmObjectDefCreate("bird");
   rmObjectDefAddItem(birdID, cUnitTypeHawk, 1);
   rmObjectDefPlaceAnywhere(birdID, 0, 2 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(1.0);
}
