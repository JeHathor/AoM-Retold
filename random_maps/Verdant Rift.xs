include "lib/rm_core.xs";
include "lib/rm_objects.xs";
include "lib/rm_beautification.xs";
include "lib/rm_forests.xs";

//ATLANTIS by JeHathor (JAN 2025)
void generate()
{
   rmSetProgress(0.0);

   // Define mixes.
   int baseMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(baseMixID, cNoiseFractalSum, 0.1, 1);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainEgyptDirtRocks1, 2.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainEgyptDirt1, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainEgyptSand1, 4.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainEgyptSand2, 4.0);

   int cliffMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(cliffMixID, cNoiseFractalSum, 0.15, 1);
   rmCustomMixAddPaintEntry(cliffMixID, cTerrainEgyptDirtRocks1, 2.0);
   rmCustomMixAddPaintEntry(cliffMixID, cTerrainEgyptDirtRocks2, 3.0);

   // Map size and terrain init.
   int axisTiles = getAxisTilesFromCount();
   rmSetMapSize(axisTiles);
   rmInitializeMix(baseMixID);

   // Player placement.
   if(gameIs1v1() == true)
   {
      placePlayersOnLine(0.125, 0.5, 0.875, 0.5);
   }
   else if(cNumberTeams < 3)
   {
      int teamInt = xsRandInt(1, 2);
      int otherTeamInt = 3 - teamInt;
      if(rmGetNumberPlayersOnTeam(teamInt) >= 9)
      {
         placeTeamOnLine(teamInt, 0.175, 0.85, 0.175, 0.15);
      }
      else
      {
         placeTeamOnLine(teamInt, 0.175, 0.75, 0.175, 0.25);
      }

      if(rmGetNumberPlayersOnTeam(otherTeamInt) >= 9)
      {
         placeTeamOnLine(otherTeamInt, 0.825, 0.15, 0.825, 0.85);
      }
      else
      {
         placeTeamOnLine(otherTeamInt, 0.825, 0.25, 0.825, 0.75);
      }

   }
   else
   {
      rmPlacePlayersOnSquare(0.275);
   }

   // Finalize player placement and do post-init things.
   postPlayerPlacement();

   // Mother Nature's civ.
   rmSetNatureCivFromCulture(cCultureEgyptian);

   // KotH.
   placeKotHObjects();

   // Lighting.
   rmSetLighting(cLightingSetRmAir01);

   rmSetProgress(0.1);

   // Global elevation.
   rmAddGlobalHeightNoise(cNoiseFractalSum, 5.0, 0.075, 2, 0.5);

   rmAreaBuildAll();
   
   // Create mountains.
   for(int i = 0; i < 2; i++)
   {
      int slopesID = rmAreaCreate("mountain " + i);
      rmAreaSetCliffType(slopesID, cCliffEgyptGrass);
      rmAreaSetHeightRelative(slopesID, 3.0);
      rmAreaSetHeightNoise(slopesID, cNoiseFractalSum, 10.0, 0.02, 5, 1.0);
      rmAreaSetHeightNoiseBias(slopesID, 1.0); // Only grow upwards.
      rmAreaSetCliffPaintInsideAsSide(slopesID, true);
      if(gameIs1v1() == true)
      {
         rmAreaSetSize(slopesID, 0.125);
      }
      else
      {
         rmAreaSetSize(slopesID, 0.1);
      }

      rmAreaSetCoherence(slopesID, 0.25);
      rmAreaSetEdgeSmoothDistance(slopesID, 2, false);

      if(i == 0)
      {
         rmAreaSetLoc(slopesID, vectorXZ(0.5, 0.01));
         rmAreaAddInfluenceSegment(slopesID, vectorXZ(0.0, 0.0), vectorXZ(1.0, 0.0));
      }
      else if(i == 1)
      {
         rmAreaSetLoc(slopesID, vectorXZ(0.5, 0.99));
         rmAreaAddInfluenceSegment(slopesID, vectorXZ(0.0, 1.0), vectorXZ(1.0, 1.0));
      }
   }
   rmAreaBuildAll();

   rmSetProgress(0.2);

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
   rmObjectDefAddConstraint(firstSettlementID, vDefaultAvoidImpassableLand15);

   int secondSettlementID = rmObjectDefCreate("second settlement");
   rmObjectDefAddItem(secondSettlementID, cUnitTypeSettlement, 1);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultSettlementAvoidEdge);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidImpassableLand15);
   rmObjectDefAddConstraint(secondSettlementID, vDefaultAvoidKotH);

   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(firstSettlementID, false, 1, 60.0, 80.0, cSettlementDist1v1, cBiasBackward);
      add1v1ObjectSimLocs(secondSettlementID, false, 1, 80.0, 100.0, cSettlementDist1v1, cBiasForward);
   }
   else
   {
      addObjectLocsPerPlayer(firstSettlementID, false, 1, 60.0, 80.0, cCloseSettlementDist, cBiasBackward | cBiasAllyInside);
      addObjectLocsPerPlayer(secondSettlementID, false, 1, 90.0, 110.0, cFarSettlementDist, cBiasForward); // No ally bias.
   }
   
   // Large / Giant map settlements.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      int thirdSettlementID = rmObjectDefCreate("third settlement");
      rmObjectDefAddItem(thirdSettlementID, cUnitTypeSettlement, 1);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultSettlementAvoidEdge);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidImpassableLand15);
      rmObjectDefAddConstraint(thirdSettlementID, vDefaultAvoidKotH);
      addObjectLocsPerPlayer(thirdSettlementID, false, 1 * getMapAreaSizeFactor(), 90.0, -1.0, 100.0);
   }

   generateLocations("settlement locs");

   rmSetProgress(0.3);

   // Cliffs.
   int cliffClassID = rmClassDefine();
   int numCliffs = 2 * cNumberPlayers;

   float cliffMinSize = rmTilesToAreaFraction(200 * getMapAreaSizeFactor());
   float cliffMaxSize = rmTilesToAreaFraction(400 * getMapAreaSizeFactor());
   int cliffAvoidCliff = rmCreateClassDistanceConstraint(cliffClassID, 25.0);
   int cliffAvoidBuildings = rmCreateTypeDistanceConstraint(cUnitTypeBuilding, 22.5);
   int cliffAvoidPlayerCores = rmCreateClassDistanceConstraint(vPlayerCoreClass, 50.0);
   int cliffForceInBox = createSymmetricBoxConstraint(0.125);

   /*
   * TODO These need to be fixed up:
   * - Add constraints as origin constraints, slightly increse size (?).
   * - Perhaps a custom cliff type with proper inside/outside blending.
   */
   for(int i = 0; i < numCliffs; i++)
   {
      int cliffID = rmAreaCreate("cliff " + i);

      rmAreaSetSize(cliffID, xsRandFloat(cliffMinSize, cliffMaxSize));
      rmAreaSetMix(cliffID, cliffMixID);
      rmAreaSetCliffType(cliffID, cCliffEgyptSand);
      rmAreaSetCliffRamps(cliffID, 2, 0.35, 0.05, 1.0);
      rmAreaSetCliffRampSteepness(cliffID, 2.0);
      rmAreaSetCliffSideRadius(cliffID, 0, 1);
      rmAreaSetCliffEmbellishmentDensity(cliffID, 0.2);
      // Do not paint the outside layer blending to sand.
      rmAreaSetCliffLayerPaint(cliffID, cCliffLayerOuterSideFar, false);

      if (xsRandBool(0.5) == true)
      {
         rmAreaSetHeightRelative(cliffID, -6.0);
      }
      else
      {
         rmAreaSetHeightRelative(cliffID, 5.0);
      }

      rmAreaAddHeightBlend(cliffID, cBlendAll, cFilter5x5Gaussian);
      rmAreaSetEdgeSmoothDistance(cliffID, 4);
      rmAreaSetCoherence(cliffID, 0.4);

      rmAreaAddConstraint(cliffID, vDefaultAvoidEdge);
      rmAreaAddConstraint(cliffID, vDefaultAvoidImpassableLand20);
      rmAreaAddConstraint(cliffID, cliffAvoidCliff);
      rmAreaAddConstraint(cliffID, cliffAvoidBuildings);
      rmAreaAddConstraint(cliffID, cliffAvoidPlayerCores);
      rmAreaAddConstraint(cliffID, cliffForceInBox);

      rmAreaSetOriginConstraintBuffer(cliffID, 8.0);

      rmAreaAddToClass(cliffID, cliffClassID);
      
      rmAreaBuild(cliffID);
   }

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
   addObjectLocsPerPlayer(startingGoldID, false, 2, cStartingGoldMinDist, cStartingGoldMaxDist, cStartingGoldAvoidanceMeters);

   generateLocations("starting gold locs");

   // Starting food.
   float avoidStartingFoodMeters = 0.5 * cStartingObjectAvoidanceMeters;

   // Custom avoid gold constraint for particularly inbalanced team maps, e.g., 1 v 11, when players are super close to eachother.
   int startingFoodAvoidGold = rmCreateTypeDistanceConstraint(cUnitTypeGoldResource, 10.0);

   // Starting hunt.
   int startingHuntID = rmObjectDefCreate("starting hunt");
   rmObjectDefAddItem(startingHuntID, cUnitTypeGazelle, xsRandInt(8, 9));
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingHuntID, vDefaultForceInTowerLOS);
   rmObjectDefAddConstraint(startingHuntID, startingFoodAvoidGold);
   addObjectLocsPerPlayer(startingHuntID, false, 1, cStartingHuntMinDist, cStartingHuntMaxDist, avoidStartingFoodMeters);

   // Chicken.
   int startingChickenID = rmObjectDefCreate("starting chicken");
   rmObjectDefAddItem(startingChickenID, cUnitTypeChicken, xsRandInt(5, 7));
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingChickenID, startingFoodAvoidGold);
   addObjectLocsPerPlayer(startingChickenID, false, 1, cStartingChickenMinDist, cStartingChickenMaxDist, avoidStartingFoodMeters);

   // Berries.
   int startingBerriesID = rmObjectDefCreate("starting berries");
   rmObjectDefAddItem(startingBerriesID, cUnitTypeBerryBush, xsRandInt(6, 9), 5.0);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingBerriesID, startingFoodAvoidGold);
   addObjectLocsPerPlayer(startingBerriesID, false, 1, cStartingBerriesMinDist, cStartingBerriesMaxDist, avoidStartingFoodMeters);

   // Herdables.
   int startingHerdID = rmObjectDefCreate("starting herd");
   rmObjectDefAddItem(startingHerdID, cUnitTypeGoat, xsRandInt(2, 4));
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHerdID, vDefaultAvoidImpassableLand5);
   addObjectLocsPerPlayer(startingHerdID, true, 1, cStartingHerdMinDist, cStartingHerdMaxDist);

   generateLocations("starting food locs");

   rmSetProgress(0.5);

   // Gold.
   int numCenterGoldPerPlayer = 3 * getMapAreaSizeFactor();
   if(cNumberPlayers > 4)
   {
      numCenterGoldPerPlayer = 2 * getMapAreaSizeFactor();
   }

   float avoidGoldMeters = 30.0;

   // Bonus gold.
   int bonusGoldID = rmObjectDefCreate("bonus gold");
   rmObjectDefAddItem(bonusGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidImpassableLand15);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(bonusGoldID, createSymmetricBoxConstraint(0.275, 0.0));
   rmObjectDefAddConstraint(bonusGoldID, createTownCenterConstraint(70.0));

   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(bonusGoldID, false, numCenterGoldPerPlayer, 70.0, -1.0, avoidGoldMeters);
   }
   else if(gameIsFair() == true)
   {
      addObjectLocsPerPlayer(bonusGoldID, false, numCenterGoldPerPlayer, 70.0, -1.0, avoidGoldMeters, cBiasForward);
   }
   else
   {
      // Just place some gold.
      int numCenterGold = numCenterGoldPerPlayer * cNumberPlayers;
      
      addObjectLocsAtOrigin(bonusGoldID, numCenterGold, cCenterLoc, 0.0, -1.0, avoidGoldMeters);
   }

   generateLocations("gold locs");

   // Hunt.
   float avoidHuntMeters = 40.0;

   // Close hunt.
   int closeHuntID = rmObjectDefCreate("close hunt");
   rmObjectDefAddItem(closeHuntID, cUnitTypeZebra, xsRandInt(8, 10));
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeHuntID, createTownCenterConstraint(70.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(closeHuntID, false, 1, 70.0, 100.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(closeHuntID, false, 1, 70.0, 100.0, avoidHuntMeters);
   }

   // Bonus hunt.
   int bonusHuntID = rmObjectDefCreate("bonus hunt");
   rmObjectDefAddItem(bonusHuntID, cUnitTypeZebra, xsRandInt(3, 5));
   rmObjectDefAddItem(bonusHuntID, cUnitTypeGazelle, xsRandInt(4, 7));
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(bonusHuntID, createTownCenterConstraint(70.0));
   if(gameIsFair() == true)
   {
      rmObjectDefAddConstraint(bonusHuntID, createSymmetricBoxConstraint(0.25, 0.0));
   }
   if(xsRandFloat(0.0, 1.0) <= 0.75)
   {
      if(gameIs1v1() == true)
      {
         add1v1ObjectSimLocs(bonusHuntID, false, 1, 50.0, -1.0, avoidHuntMeters);
      }
      else
      {
         addObjectLocsPerPlayer(bonusHuntID, false, 1, 80.0, -1.0, avoidHuntMeters, cBiasNone, (gameIsFair() == true) ? cInAreaTeam : cInAreaNone);
      }
   }

   // Large / Giant map size hunt.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      int largeMapHuntID = rmObjectDefCreate("large map hunt");
      if(xsRandBool(0.5) == true)
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeElephant, xsRandInt(2, 3));
      }
      else
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeGazelle, xsRandInt(8, 12));
      }
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidAll);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidEdge);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidImpassableLand10);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultFoodAvoidGold);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidSettlementRange);
      rmObjectDefAddConstraint(largeMapHuntID, createTownCenterConstraint(70.0));
      addObjectLocsPerPlayer(largeMapHuntID, false, 1 * getMapSizeBonusFactor(), 100.0, -1.0, avoidHuntMeters);
   }

   generateLocations("hunt locs");

   rmSetProgress(0.6);

   // Herdables.
   float avoidHerdMeters = 50.0;

   int closeHerdID = rmObjectDefCreate("close herd");
   rmObjectDefAddItem(closeHerdID, cUnitTypeGoat, 2, 4.0);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidTowerLOS);
   addObjectLocsPerPlayer(closeHerdID, false, xsRandInt(1, 2), 50.0, 70.0, avoidHerdMeters);

   int bonusHerdID = rmObjectDefCreate("bonus herd");
   rmObjectDefAddItem(bonusHerdID, cUnitTypeGoat, 2, 4.0);
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
      rmObjectDefAddItem(predatorsID, cUnitTypeLion, xsRandInt(2, 3), 4.0);
   }
   else
   {
      if(xsRandBool(0.5) == true)
      {
         rmObjectDefAddItem(predatorsID, cUnitTypeRhinoceros, 2, 4.0);
      }else{
         rmObjectDefAddItem(predatorsID, cUnitTypeElephant, 1, 4.0);
      }
   }
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(predatorsID, vDefaultFoodAvoidFood);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(predatorsID, createTownCenterConstraint(80.0));
   if(gameIsFair() == true)
   {
      rmObjectDefAddConstraint(predatorsID, createSymmetricBoxConstraint(0.35, 0.1));
   }
   addObjectLocsPerPlayer(predatorsID, false, xsRandInt(1, 2) * getMapAreaSizeFactor(), 80.0, -1.0, avoidPredatorMeters);

   generateLocations("predator locs");

   // Berries.
   float avoidBerriesMeters = 50.0;

   int berriesID = rmObjectDefCreate("berries");
   rmObjectDefAddItem(berriesID, cUnitTypeBerryBush, xsRandInt(8, 10), 5.0);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidImpassableLand15);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(berriesID, vDefaultFoodAvoidFood);
   rmObjectDefAddConstraint(berriesID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(berriesID, vDefaultAvoidSettlementRange);
   addObjectLocsPerPlayer(berriesID, false, 1 * getMapSizeBonusFactor(), 65.0, -1.0, avoidBerriesMeters);

   generateLocations("berries locs");

   // Relics.
   float avoidRelicMeters = 80.0;

   int relicID = rmObjectDefCreate("relic");
   rmObjectDefAddItem(relicID, cUnitTypeRelic, 1);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(relicID, createTownCenterConstraint(80.0));
   addObjectLocsPerPlayer(relicID, false, 2 * getMapAreaSizeFactor(), 80.0, -1.0, avoidRelicMeters);

   generateLocations("relic locs");

   // Stragglers.
   placeStartingStragglers(cUnitTypeTreePalm);

   rmSetProgress(0.7);

   // Fish.
   if(gameIs1v1() == true)
   {
      // 1v1: 3x3 per river.
      int fishID = rmObjectDefCreate("fish");
      rmObjectDefAddItem(fishID, cUnitTypeHerring, 3, 5.0);
      placeObjectDefInLine(fishID, 0, false, 6 * getMapAreaSizeFactor(), vectorXZ(0.1, 0.05), vectorXZ(0.9, 0.05), 0.0, 5.0); // Lower river.
      placeObjectDefInLine(fishID, 0, false, 6 * getMapAreaSizeFactor(), vectorXZ(0.1, 0.95), vectorXZ(0.9, 0.95), 0.0, 5.0); // Upper river.
   }
   else
   {
      // TODO Be smarter here - could consider to mirror this because it really isn't all too interesting.

      // Everything else: Just put 1.5 * cNumberPlayers fish into each half-river (without verifying for now).
      int fishAvoidEdge = createSymmetricBoxConstraint(rmXMetersToFraction(4.0), rmZMetersToFraction(4.0));
      int fishAvoidLand = rmCreatePassabilityDistanceConstraint(cPassabilityLand, true, 6.0);
      int fishAvoidFish = rmCreateTypeDistanceConstraint(cUnitTypeFishResource, 20.0);
      int numFishPerHalfRiver = 1.5 * cNumberPlayers * getMapAreaSizeFactor();

      for(int i = 0; i < 4; i++)
      {
         int fishID = rmObjectDefCreate("fish " + i);
         rmObjectDefAddItem(fishID, cUnitTypeHerring, 3, 5.0);

         rmObjectDefAddConstraint(fishID, fishAvoidEdge);
         rmObjectDefAddConstraint(fishID, fishAvoidLand);
         rmObjectDefAddConstraint(fishID, fishAvoidFish);

         if(i == 0)
         {
            rmObjectDefAddConstraint(fishID, rmCreateBoxConstraint(vectorXZ(0.01, 0.9), vectorXZ(0.5, 1.0)));
            rmObjectDefPlaceInArea(fishID, 0, rmAreaGetID("river 1"), numFishPerHalfRiver);
         }
         else if(i == 1)
         {
            rmObjectDefAddConstraint(fishID, rmCreateBoxConstraint(vectorXZ(0.5, 0.9), vectorXZ(0.99, 1.0)));
            rmObjectDefPlaceInArea(fishID, 0, rmAreaGetID("river 1"), numFishPerHalfRiver);
         }
         else if(i == 2)
         {
            rmObjectDefAddConstraint(fishID, rmCreateBoxConstraint(vectorXZ(0.01, 0.0), vectorXZ(0.5, 0.1)));
            rmObjectDefPlaceInArea(fishID, 0, rmAreaGetID("river 0"), numFishPerHalfRiver);
         }
         else if(i == 3)
         {
            rmObjectDefAddConstraint(fishID, rmCreateBoxConstraint(vectorXZ(0.5, 0.0), vectorXZ(0.99, 0.1)));
            rmObjectDefPlaceInArea(fishID, 0, rmAreaGetID("river 0"), numFishPerHalfRiver);
         }
      }
   }

   rmSetProgress(0.8);

   forestGenAddType(cForestEgyptPalmGrassMix);
   forestGenSetAreaTiles(60, 90);
   forestGenSetSelfAvoidDist(25.0);
   forestGenAddConstraint(vDefaultAvoidAll);
   forestGenAddConstraint(vDefaultForestAvoidTownCenter);
   forestGenAddConstraint(vDefaultAvoidSettlementWithFarm);
   forestGenAddConstraint(vDefaultAvoidImpassableLand10);
   forestGenAddConstraint(rmCreateClassDistanceConstraint(cliffClassID, 0.1));

   forestGenGeneratePlayerForests(3, cDefaultPlayerForestOriginMinDist, cDefaultPlayerForestOriginMaxDist);
   forestGenGenerateGlobalForests(5 * cNumberPlayers * getMapSizeBonusFactor());

   rmSetProgress(0.9);

   // Embellishment.
   // Gold areas.
   buildAreaUnderObjectDef(startingGoldID, cTerrainEgyptGrassRocks2, cTerrainEgyptGrassDirt3, 8.0);
   buildAreaUnderObjectDef(bonusGoldID, cTerrainEgyptGrassRocks2, cTerrainEgyptGrassDirt3, 8.0);

   // Berries areas.
   buildAreaUnderObjectDef(startingBerriesID, cTerrainEgyptGrassDirt2, cTerrainEgyptGrassDirt3, 10.0);
   buildAreaUnderObjectDef(berriesID, cTerrainEgyptGrassDirt2, cTerrainEgyptGrassDirt3, 10.0);

   // Random trees.
   int randomTreeID = rmObjectDefCreate("random tree");
   rmObjectDefAddItem(randomTreeID, cUnitTypeTreePalm, 1);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(randomTreeID, vDefaultEmbellishmentTreeAvoidTree);
   rmObjectDefPlaceAnywhere(randomTreeID, 0, 5 * cNumberPlayers * getMapAreaSizeFactor());

   // Rocks.
   int rockTinyID = rmObjectDefCreate("rock tiny");
   rmObjectDefAddItem(rockTinyID, cUnitTypeRockGreekTiny, 1);
   rmObjectDefAddConstraint(rockTinyID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(rockTinyID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(rockTinyID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());

   int rockSmallID = rmObjectDefCreate("rock small");
   rmObjectDefAddItem(rockSmallID, cUnitTypeRockGreekSmall, 1);
   rmObjectDefAddConstraint(rockSmallID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(rockSmallID, vDefaultAvoidImpassableLand10);
   rmObjectDefPlaceAnywhere(rockSmallID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());

   // Plants.
   int plantBushID = rmObjectDefCreate("plant bush");
   rmObjectDefAddItem(plantBushID, cUnitTypePlantEgyptianBush, 1);
   rmObjectDefAddConstraint(plantBushID, vDefaultEmbellishmentAvoidAll);
   //rmObjectDefAddConstraint(plantBushID, vDefaultAvoidImpassableLand5);
   rmObjectDefPlaceAnywhere(plantBushID, 0, 20 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantShrubID = rmObjectDefCreate("plant shrub");
   rmObjectDefAddItem(plantShrubID, cUnitTypePlantEgyptianShrub, 1);
   rmObjectDefAddConstraint(plantShrubID, vDefaultEmbellishmentAvoidAll);
   //rmObjectDefAddConstraint(plantShrubID, vDefaultAvoidImpassableLand5);
   rmObjectDefPlaceAnywhere(plantShrubID, 0, 20 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantGrassID = rmObjectDefCreate("plant grass");
   rmObjectDefAddItem(plantGrassID, cUnitTypePlantEgyptianGrass, 1);
   rmObjectDefAddConstraint(plantGrassID, vDefaultEmbellishmentAvoidAll);
   //rmObjectDefAddConstraint(plantGrassID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(plantGrassID, vDefaultAvoidEdge);
   rmObjectDefPlaceAnywhere(plantGrassID, 0, 20 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantFernID = rmObjectDefCreate("plant fern");
   rmObjectDefAddItem(plantFernID, cUnitTypePlantEgyptianFern, 1);
   rmObjectDefAddConstraint(plantFernID, vDefaultEmbellishmentAvoidAll);
   //rmObjectDefAddConstraint(plantFernID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(plantFernID, vDefaultAvoidEdge);
   rmObjectDefPlaceAnywhere(plantFernID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantWeedsID = rmObjectDefCreate("plant weeds");
   rmObjectDefAddItem(plantWeedsID, cUnitTypePlantEgyptianWeeds, 1);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultEmbellishmentAvoidAll);
   //rmObjectDefAddConstraint(plantWeedsID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultAvoidEdge);
   rmObjectDefPlaceAnywhere(plantWeedsID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());

   // Logs.
   int logID = rmObjectDefCreate("log");
   rmObjectDefAddItem(logID, cUnitTypeRottingLog, 1);
   rmObjectDefAddConstraint(logID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(logID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(logID, vDefaultAvoidSettlementRange);
   rmObjectDefPlaceAnywhere(logID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());

   // Birbs.
   int birdID = rmObjectDefCreate("bird");
   rmObjectDefAddItem(birdID, cUnitTypeHawk, 1);
   rmObjectDefPlaceAnywhere(birdID, 0, 2 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(1.0);
}
