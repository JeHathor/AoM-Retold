include "lib/rm_core.xs";
include "lib/rm_beautification.xs";
include "lib/rm_forests.xs";
include "lib/rm_connections.xs";

//Mainland by JeHathor (JAN 2025)
void generate()
{
   rmSetProgress(0.0);

   // Define mixes.
   int baseMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(baseMixID, cNoiseFractalSum, 0.15, 5, 0.5);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrass2, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrass1, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrassRocks1, 1.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrassDirt1, 5.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrassDirt2, 5.0);

   // Map size and terrain init.
   int axisTiles = getAxisTilesFromCount();
   rmSetMapSize(axisTiles);
   rmInitializeMix(baseMixID);

   // Player placement.
   rmSetTeamSpacingModifier(0.26 + 0.04 * cNumberPlayers);
   if(gameIs1v1() == true)
   {
      rmPlacePlayersOnSquare(0.3, 0.3, 0.0, rmXFractionToMeters(0.5));
   }
   else
   {
      rmPlacePlayersOnCircle(xsRandFloat(0.3, 0.35));
   }

   // Finalize player placement and do post-init things.
   postPlayerPlacement();

   // Mother Nature's civ.
   rmSetNatureCivFromCulture(cCultureGreek);

   // KotH.
   placeKotHObjects();

   // Lighting.
   float lgtFloat = xsRandFloat(0.0, 1.0);
   if(lgtFloat > 0.7)
   {
      rmSetLighting(cLightingSetRmAcropolis01);
   }
   else
   {
      rmSetLighting(cLightingSetRmMediterranean01);
   }

   rmSetProgress(0.1);

   // Global elevation.
   rmAddGlobalHeightNoise(cNoiseFractalSum, 5.0, 0.1, 5, 0.3);

   // Settlements and towers.
   // Starting town centers.
   int startingTownCenterID = rmObjectDefCreate("starting town center");
   rmObjectDefAddItem(startingTownCenterID, cUnitTypeTownCenter, 1);
   rmObjectDefPlacePerPlayer(startingTownCenterID, true, 1);

   // Starting towers.
   int startingTowerID = rmObjectDefCreate("starting tower");
   rmObjectDefAddItem(startingTowerID, cUnitTypeSentryTower, 1);
   addObjectLocsPerPlayer(startingTowerID, true, 4, cStartingTowerMinDist, cStartingTowerMaxDist, cStartingTowerAvoidanceMeters);
   generateLocations("starting tower locs");

   // Settlements.
   int firstSettlementID = rmObjectDefCreate("first settlement");
   rmObjectDefAddItem(firstSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidCorner);

   int secondSettlementID = rmObjectDefCreate("second settlement");
   rmObjectDefAddItem(secondSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidKotH);

   if(gameIs1v1() == true)
   {
      addMirroredObjectLocsPerPlayer(firstSettlementID, false, 1, 60.0, 80.0, cSettlementDist1v1, cBiasBackward);
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
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidKotH);
      addObjectLocsPerPlayer(thirdSettlementID, false, 1 * getMapAreaSizeFactor(), 90.0, -1.0, 100.0);
   }

   generateLocations("settlement locs");

   rmSetProgress(0.2);

   // Starting objects.
   // Starting gold.
   int startingGoldID = rmObjectDefCreate("starting gold");
   rmObjectDefAddItem(startingGoldID, cUnitTypeMineGoldMedium, 1);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingGoldID, vDefaultStartingGoldAvoidTower);
   rmObjectDefAddConstraint(startingGoldID, vDefaultForceStartingGoldNearTower);
   addSimRadiusObjectLocsPerPlayer(startingGoldID, false, 1, cStartingGoldMinDist, cStartingGoldMaxDist, cStartingObjectAvoidanceMeters);

   generateLocations("starting gold locs");

   // Starting hunt.
   int startingHuntID = rmObjectDefCreate("starting hunt");
   rmObjectDefAddItem(startingHuntID, cUnitTypeDeer, xsRandInt(8, 9));
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(startingHuntID, vDefaultForceInTowerLOS);
   rmObjectDefAddConstraint(startingHuntID, vDefaultFoodAvoidGold);
   addSimRadiusObjectLocsPerPlayer(startingHuntID, false, 1, cStartingHuntMinDist, cStartingHuntMaxDist, cStartingObjectAvoidanceMeters);

   // Chicken.
   int startingChickenID = rmObjectDefCreate("starting chicken");
   rmObjectDefAddItem(startingChickenID, cUnitTypeChicken, xsRandInt(5, 7));
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(startingChickenID, vDefaultFoodAvoidGold);
   addSimRadiusObjectLocsPerPlayer(startingChickenID, false, 1, cStartingChickenMinDist, cStartingChickenMaxDist, cStartingObjectAvoidanceMeters);

   // Berries.
   int startingBerriesID = rmObjectDefCreate("starting berries");
   rmObjectDefAddItem(startingBerriesID, cUnitTypeBerryBush, xsRandInt(6, 9), 5.0);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultFoodAvoidGold);
   addSimRadiusObjectLocsPerPlayer(startingBerriesID, false, 1, cStartingBerriesMinDist, cStartingBerriesMaxDist, cStartingObjectAvoidanceMeters);

   // Herdables.
   int startingHerdID = rmObjectDefCreate("starting herd");
   rmObjectDefAddItem(startingHerdID, cUnitTypeGoat, xsRandInt(3, 5));
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidImpassableLand5);
   addSimRadiusObjectLocsPerPlayer(startingHerdID, true, 1, cStartingHerdMinDist, cStartingHerdMaxDist);

   generateLocations("starting food locs");

   // Starting forests.
   float avoidStartingForestMeters = 40.0;

   int forestDefID = rmAreaDefCreate("forest");
   rmAreaDefSetSize(forestDefID, rmTilesToAreaFraction(80), rmTilesToAreaFraction(125));
   rmAreaDefSetBlobs(forestDefID, 4, 5);
   rmAreaDefSetBlobDistance(forestDefID, 10.0);
   rmAreaDefSetAvoidSelfDistance(forestDefID, 30.0);
   rmAreaDefAddConstraint(forestDefID, vDefaultAvoidAll);
   rmAreaDefAddConstraint(forestDefID, vDefaultForestAvoidTownCenter);
   rmAreaDefAddConstraint(forestDefID, vDefaultAvoidSettlementWithFarm);
   rmAreaDefAddConstraint(forestDefID, vDefaultAvoidImpassableLand10, 2);

   float forestTypeFloat = xsRandFloat(0.0, 1.0);
   if(forestTypeFloat < 1.0 / 3.0)
   {
      rmAreaDefSetForestType(forestDefID, cForestGreekPine);
   }
   else if(forestTypeFloat < 2.0 / 3.0)
   {
      rmAreaDefSetForestType(forestDefID, cForestGreekOakLateAutumn);
   }
   else
   {
      rmAreaDefSetForestType(forestDefID, cForestGreekOak);
   }

   if(gameIs1v1() == true)
   {
      add1v1AreaSimLocs(forestDefID, 3, cStartingForestMinDist, cStartingForestMaxDist, avoidStartingForestMeters);
   }
   else
   {
      addAreaLocsPerPlayer(forestDefID, 3, cStartingForestMinDist, cStartingForestMaxDist, avoidStartingForestMeters);
   }

   generateLocations("starting forest locs");

   rmSetProgress(0.3);

   // Global forests.
   rmAreaDefCreateAndBuildAreas(forestDefID, 8 * cNumberPlayers);

   // Gold.
   float avoidGoldMeters = 40.0;

   // Medium gold.
   int closeGoldID = rmObjectDefCreate("close gold");
   rmObjectDefAddItem(closeGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidCorner);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeGoldID, createTownCenterConstraint(55.0));
   if(gameIs1v1() == true)
   {
      addMirroredObjectLocsPerPlayer(closeGoldID, false, 1, 55.0, 65.0, avoidGoldMeters, cBiasForward);
   }
   else
   {
      addObjectLocsPerPlayer(closeGoldID, false, 1, 50.0, 75.0, avoidGoldMeters);
   }

   // Bonus gold.
   int bonusGoldID = rmObjectDefCreate("bonus gold");
   rmObjectDefAddItem(bonusGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(bonusGoldID, createTownCenterConstraint(70.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(bonusGoldID, false, xsRandInt(3, 4) * getMapAreaSizeFactor(), 70.0, -1.0, avoidGoldMeters);
   }
   else
   {
      addObjectLocsPerPlayer(bonusGoldID, false, xsRandInt(3, 4) * getMapAreaSizeFactor(), 70.0, -1.0, avoidGoldMeters);
   }

   generateLocations("gold locs");

   rmSetProgress(0.4);

   // Cliffs.
   int numCliffsPerPlayer = 3 * getMapAreaSizeFactor(); // Could also randomize 3-4 here.

   int cliffClassID = rmClassDefine();

   float cliffMinSize = rmTilesToAreaFraction(250);
   float cliffMaxSize = rmTilesToAreaFraction(300);
   int cliffAvoidBuildings = rmCreateTypeDistanceConstraint(cUnitTypeBuilding, 20.0);
   int cliffAvoidCliff = rmCreateClassDistanceConstraint(cliffClassID, 40.0);
   int cliffAvoidOther = rmCreateTypeDistanceConstraint(cUnitTypeAll, 8.0);

   int cliffID = rmAreaDefCreate("cliff area");

   rmAreaDefSetSize(cliffID, xsRandFloat(cliffMinSize, cliffMaxSize));

   rmAreaDefSetCliffType(cliffID, cCliffGreekGrass);
   rmAreaDefSetCliffSideSheernessThreshold(cliffID, degToRad(45.0));
   rmAreaDefSetCliffSideRadius(cliffID, 0, 2);
   rmAreaDefSetCliffPaintInsideAsSide(cliffID, true);
   rmAreaDefSetCliffEmbellishmentDensity(cliffID, 0.25);

   rmAreaDefSetHeightRelative(cliffID, 5.0);
   rmAreaDefSetHeightNoise(cliffID, cNoiseFractalSum, 10.0, 0.2, 2, 0.5);
   rmAreaDefSetHeightNoiseBias(cliffID, 1.0); // Only grow on top of the cliff height.
   rmAreaDefAddHeightBlend(cliffID, cBlendEdge, cFilter5x5Gaussian, 2);

   rmAreaDefSetBlobs(cliffID, 2, 3);
   rmAreaDefSetBlobDistance(cliffID, 10.0, 20.0);

   rmAreaDefAddConstraint(cliffID, cliffAvoidCliff, 0.0, 10.0);
   rmAreaDefAddConstraint(cliffID, cliffAvoidBuildings, 0.0, 10.0);
   rmAreaDefAddConstraint(cliffID, cliffAvoidOther, 0.0, 10.0);

   rmAreaDefAddToClass(cliffID, cliffClassID);

   // Note that the inArea param is only choosing the origin tile, so essentially an origin constraint.
   // The locDist should always be >= the class distance, or areas won't build at all as they're too close.
   addAreaLocsPerPlayer(cliffID, numCliffsPerPlayer, 55.0, -1.0, 70.0);

   generateLocations("cliff locs");

   rmSetProgress(0.5);

   // Hunt.
   float avoidHuntMeters = 50.0;

   // Close hunt.
   int closeHuntID = rmObjectDefCreate("close hunt");
   rmObjectDefAddItem(closeHuntID, cUnitTypeDeer, xsRandInt(5, 7));
   rmObjectDefAddItem(closeHuntID, cUnitTypeBoar, 2);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(closeHuntID, vDefaultFoodAvoidFood);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeHuntID, createTownCenterConstraint(55.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(closeHuntID, false, 1, 55.0, 80.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(closeHuntID, false, 1, 55.0, 85.0, avoidHuntMeters);
   }

   // Far hunt.
   float farHuntFloat = xsRandFloat(0.0, 1.0);
   int farHuntID = rmObjectDefCreate("far hunt");
   if(farHuntFloat < 0.5)
   {
      rmObjectDefAddItem(farHuntID, cUnitTypeDeer, xsRandInt(6, 9));
   }
   else
   {
      rmObjectDefAddItem(farHuntID, cUnitTypeAurochs, xsRandInt(2, 4));
   }
   rmObjectDefAddConstraint(farHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(farHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(farHuntID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(farHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(farHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(farHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(farHuntID, createTownCenterConstraint(70.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(farHuntID, false, 1, 70.0, -1.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(farHuntID, false, 1, 70.0, -1.0, avoidHuntMeters);
   }

   // Large / Giant map size hunt.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      int largeMapHuntID = rmObjectDefCreate("large map hunt");
      float largeHuntFloat = xsRandFloat(0.0, 1.0);
      if(largeHuntFloat < 0.5)
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeDeer, xsRandInt(6, 12));
      }
      else
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeAurochs, xsRandInt(3, 4));
      }
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidAll);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidEdge);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidImpassableLand5);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultFoodAvoidGold);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidSettlementRange);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidKotH);
      rmObjectDefAddConstraint(largeMapHuntID, createTownCenterConstraint(70.0));
      addObjectLocsPerPlayer(largeMapHuntID, false, 1 * getMapSizeBonusFactor(), 100.0, -1.0, avoidHuntMeters);
   }

   generateLocations("hunt locs");

   rmSetProgress(0.6);

   // Herdables.
   float avoidHerdMeters = 50.0;

   int closeHerdID = rmObjectDefCreate("close herd");
   rmObjectDefAddItem(closeHerdID, cUnitTypeGoat, xsRandInt(2, 3));
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidTowerLOS);
   addObjectLocsPerPlayer(closeHerdID, false, 1, 50.0, 70.0, avoidHerdMeters);

   int bonusHerdID = rmObjectDefCreate("bonus herd");
   rmObjectDefAddItem(bonusHerdID, cUnitTypeGoat, xsRandInt(1, 2));
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidTowerLOS);
   addObjectLocsPerPlayer(bonusHerdID, false, xsRandInt(1, 2) * getMapSizeBonusFactor(), 70.0, -1.0, avoidHerdMeters);

   generateLocations("herd locs");

   // Predators.
   float avoidPredatorMeters = 50.0;

   int predatorsID = rmObjectDefCreate("predator");
   if(xsRandBool(0.5) == true)
   {
      rmObjectDefAddItem(predatorsID, cUnitTypeBoar, xsRandInt(2, 3));
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
   rmObjectDefAddConstraint(predatorsID, createTownCenterConstraint(80.0));
   addObjectLocsPerPlayer(predatorsID, false, xsRandInt(1, 2) * getMapAreaSizeFactor(), 80.0, -1.0, avoidPredatorMeters);

   generateLocations("predator locs");

   rmSetProgress(0.7);

   // Berries.
   float avoidBerriesMeters = 50.0;

   int farBerries1ID = rmObjectDefCreate("far berries 1");
   rmObjectDefAddItem(farBerries1ID, cUnitTypeBerryBush, xsRandInt(7, 10), 5.0);
   rmObjectDefAddConstraint(farBerries1ID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(farBerries1ID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(farBerries1ID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(farBerries1ID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(farBerries1ID, rmCreateTypeDistanceConstraint(cUnitTypeFoodResource, 10.0));
   rmObjectDefAddConstraint(farBerries1ID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(farBerries1ID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(farBerries1ID, createTownCenterConstraint(55.0));
   addObjectLocsPerPlayer(farBerries1ID, false, 1, 65.0, 100.0, avoidBerriesMeters);

   int farBerries2ID = rmObjectDefCreate("far berries 2");
   rmObjectDefAddItem(farBerries2ID, cUnitTypeBerryBush, xsRandInt(6, 10), 5.0);
   rmObjectDefAddConstraint(farBerries2ID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(farBerries2ID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(farBerries2ID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(farBerries2ID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(farBerries2ID, rmCreateTypeDistanceConstraint(cUnitTypeFoodResource, 10.0));
   rmObjectDefAddConstraint(farBerries2ID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(farBerries2ID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(farBerries2ID, createTownCenterConstraint(55.0));
   addObjectLocsPerPlayer(farBerries2ID, false, 1 * getMapSizeBonusFactor(), 65.0, -1.0, avoidBerriesMeters);
   
   generateLocations("berries locs");

   // Relics.
   float avoidRelicMeters = 80.0;

   int relicID = rmObjectDefCreate("relic");
   rmObjectDefAddItem(relicID, cUnitTypeRelic, 1);
   rmObjectDefAddItem(relicID, cUnitTypeColumns, xsRandInt(2, 3), 4.0);
   rmObjectDefAddItem(relicID, cUnitTypeColumnsBroken, xsRandInt(2, 3), 4.0);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(relicID, createTownCenterConstraint(70.0));
   addObjectLocsPerPlayer(relicID, false, 2 * getMapAreaSizeFactor(), 70.0, -1.0, avoidRelicMeters);

   generateLocations("relic locs");

   // Stragglers.
   placeStartingStragglers(cUnitTypeTreeOak);

   rmSetProgress(0.8);

   // Relic decoration.
   float relicAreaMinFraction = rmTilesToAreaFraction(10);
   float relicAreaMaxFraction = rmTilesToAreaFraction(20);

   int numRelics = rmObjectDefGetNumberCreatedObjects(relicID);

   for(int i = 0; i < numRelics; i++)
   {
      int objectID = rmObjectDefGetCreatedObject(relicID, i);
      vector objectLoc = rmObjectGetLoc(objectID);

      if(objectLoc == cInvalidVector)
      {
         continue;
      }

      int relicAreaID = rmAreaCreate("relic area " + i);
      rmAreaSetLoc(relicAreaID, objectLoc);
      rmAreaSetTerrainType(relicAreaID, cTerrainGreekRoad3);
      rmAreaSetSize(relicAreaID, xsRandFloat(relicAreaMinFraction, relicAreaMaxFraction));

      rmAreaAddConstraint(relicAreaID, vDefaultAvoidImpassableLand5);

      rmAreaBuild(relicAreaID);
   }

   // Gold areas.
   buildAreaUnderObjectDef(startingGoldID, cTerrainGreekGrassRocks2, cTerrainGreekGrassRocks1, 6.0);
   buildAreaUnderObjectDef(closeGoldID, cTerrainGreekGrassRocks2, cTerrainGreekGrassRocks1, 6.0);
   buildAreaUnderObjectDef(bonusGoldID, cTerrainGreekGrassRocks2, cTerrainGreekGrassRocks1, 6.0);

   // Berries areas.
   buildAreaUnderObjectDef(startingBerriesID, cTerrainGreekGrass2, cTerrainGreekGrass1, 10.0);
   buildAreaUnderObjectDef(farBerries1ID, cTerrainGreekGrass2, cTerrainGreekGrass1, 10.0);
   buildAreaUnderObjectDef(farBerries2ID, cTerrainGreekGrass2, cTerrainGreekGrass1, 10.0);

   rmSetProgress(0.9);

   // Random trees.
   int randomTreeID = rmObjectDefCreate("random tree");
   rmObjectDefAddItem(randomTreeID, cUnitTypeTreeOak, 1);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(randomTreeID, vDefaultEmbellishmentTreeAvoidTree);
   rmObjectDefAddConstraint(randomTreeID, rmCreateTerrainTypeDistanceConstraint(cTerrainGreekRoad3, 2.0));
   rmObjectDefPlaceAnywhere(randomTreeID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());

   // Rocks.
   int rockTinyID = rmObjectDefCreate("rock tiny");
   rmObjectDefAddItem(rockTinyID, cUnitTypeRockGreekTiny, 1);
   rmObjectDefAddConstraint(rockTinyID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(rockTinyID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(rockTinyID, 0, 35 * cNumberPlayers * getMapAreaSizeFactor());

   int rockSmallID = rmObjectDefCreate("rock small");
   rmObjectDefAddItem(rockSmallID, cUnitTypeRockGreekSmall, 1);
   rmObjectDefAddConstraint(rockSmallID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(rockSmallID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(rockSmallID, 0, 35 * cNumberPlayers * getMapAreaSizeFactor());

   // Grass.
   int grassID = rmObjectDefCreate("grass");
   rmObjectDefAddItem(grassID, cUnitTypePlantGreekGrass, 1);
   rmObjectDefAddConstraint(grassID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(grassID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(grassID, 0, 15 * cNumberPlayers * getMapAreaSizeFactor());

   // Bush.
   int bushID = rmObjectDefCreate("bush");
   rmObjectDefAddItem(bushID, cUnitTypePlantGreekBush, 1);
   rmObjectDefAddConstraint(bushID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(bushID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(bushID, 0, 15 * cNumberPlayers * getMapAreaSizeFactor());

   // Shrub.
   int shrubID = rmObjectDefCreate("shrub");
   rmObjectDefAddItem(shrubID, cUnitTypePlantGreekShrub, 1);
   rmObjectDefAddConstraint(shrubID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(shrubID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(shrubID, 0, 15 * cNumberPlayers * getMapAreaSizeFactor());

   // Weeds.
   int weedsID = rmObjectDefCreate("weeds");
   rmObjectDefAddItem(weedsID, cUnitTypePlantGreekWeeds, xsRandInt(1, 4));
   rmObjectDefAddConstraint(weedsID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(weedsID, vDefaultAvoidImpassableLand5);
   rmObjectDefPlaceAnywhere(weedsID, 0, 30 * cNumberPlayers * getMapAreaSizeFactor());

   // Logs.
   int logID = rmObjectDefCreate("log");
   rmObjectDefAddItem(logID, cUnitTypeRottingLog, 1);
   rmObjectDefAddConstraint(logID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(logID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(logID, vDefaultAvoidSettlementRange);
   rmObjectDefPlaceAnywhere(logID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());

   int logGroupID = rmObjectDefCreate("log group");
   rmObjectDefAddItem(logGroupID, cUnitTypeRottingLog, 2, 2.0);
   rmObjectDefAddConstraint(logGroupID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(logGroupID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(logGroupID, vDefaultAvoidSettlementRange);
   rmObjectDefPlaceAnywhere(logGroupID, 0, 5 * cNumberPlayers * getMapAreaSizeFactor());

   // Birbs.
   int birdID = rmObjectDefCreate("bird");
   rmObjectDefAddItem(birdID, cUnitTypeHawk, 1);
   rmObjectDefPlaceAnywhere(birdID, 0, 2 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(1.0);
}
