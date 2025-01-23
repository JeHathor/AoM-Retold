include "lib/rm_core.xs";
include "lib/rm_beautification.xs";
include "lib/rm_objects.xs";
include "lib/rm_forests.xs";
include "lib/rm_connections.xs";

//by JeHathor (AUG 2024)
void createTriggers()
{
   // Generate the trigger code from the script.
   // Create the rule.
   rmTriggerAddScriptLine("rule _init");
   rmTriggerAddScriptLine("highFrequency");
   rmTriggerAddScriptLine("active");
   rmTriggerAddScriptLine("runImmediately");
   rmTriggerAddScriptLine("{");

   // Game setup, generate trigger code based on the player's civ.
   for(int i = 1; i <= cNumberPlayers; i++)
   {
      // Resource trickle.
      rmTriggerAddScriptLine("trPlayerModifyResourceData(" + i + ", cXSPlayerResourceEffectResTrickle, cResourceFavor, 0.75, cXSRelativityAssign);");

      rmTriggerAddScriptLine("trPlayerModifyResourceData(" + i + ", cXSPlayerResourceEffectResTrickle, cResourceFood, 2.00, cXSRelativityAssign);");
      rmTriggerAddScriptLine("trPlayerModifyResourceData(" + i + ", cXSPlayerResourceEffectResTrickle, cResourceWood, 2.00, cXSRelativityAssign);");
      rmTriggerAddScriptLine("trPlayerModifyResourceData(" + i + ", cXSPlayerResourceEffectResTrickle, cResourceGold, 2.00, cXSRelativityAssign);");

      // Culture-based proto/tech/power adjustments.
      int classicalAgeDelta = -40;
      int heroicAgeDelta = -30;
      int mythicAgeDelta = -20;

      int cultureID = rmGetPlayerCulture(i);
      if(cultureID == cCultureGreek)
      {
         // Age ups research faster.
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeAres, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeAthena, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeHermes, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeAphrodite, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeApollo, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeDionysus, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeArtemis, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeHephaestus, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeHera, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
      }
      else if(cultureID == cCultureEgyptian)
      {
         // Age ups research faster.
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeAnubis, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeBast, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgePtah, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeNephthys, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeSekhmet, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeSobek, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeHorus, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeOsiris, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeThoth, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
      }
      else if(cultureID == cCultureNorse)
      {
         // Age ups research faster.
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeForseti, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeFreyja, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeHeimdall, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeBragi, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeNjord, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeSkadi, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeBaldr, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeHel, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeTyr, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");

         // DLC 1
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeUllr, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeAegir, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeVidar, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
      }
      else if(cultureID == cCultureAtlantean)
      {
         // Age ups research faster.
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeLeto, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgeOceanus, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechClassicalAgePrometheus, " + i + ", " + classicalAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeHyperion, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeRheia, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechHeroicAgeTheia, " + i + ", " + heroicAgeDelta + ", cXSRelativityAbsolute);");

         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeAtlas, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeHelios, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
         rmTriggerAddScriptLine("trTechModifyResearchPoints(cTechMythicAgeHekate, " + i + ", " + mythicAgeDelta + ", cXSRelativityAbsolute);");
      }
   }

   // We're done.
   rmTriggerAddScriptLine("xsDisableSelf();");

   // Close the rule.
   rmTriggerAddScriptLine("}");
}

void generate()
{
   rmSetProgress(0.0);

   // Define mixes.
   int baseMixID = rmCustomMixCreate();
   rmCustomMixSetPaintParams(baseMixID, cNoiseRandom);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrassRocks1, 2.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrass1, 3.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrassDirt1, 2.0);
   rmCustomMixAddPaintEntry(baseMixID, cTerrainGreekGrassDirt2, 2.0);
   
   // Map size and terrain init.
   int axisTiles = getAxisTilesFromCount(9000);

   float axisMultiplier = 0.9;
   int longerAxis = getRandomXZAxis(0.5);

   if(longerAxis == cAxisX)
   {
      rmSetMapSize(axisMultiplier * axisTiles, (1.0 / axisMultiplier) * axisTiles);
   }
   else if(longerAxis == cAxisZ)
   {
      rmSetMapSize((1.0 / axisMultiplier) * axisTiles, axisMultiplier * axisTiles);
   }
   
   /*
   * TODO Initialize normal instead and build a cliff (valley).
   * Then, build areas against each other and fill up all segments with cliffs.
   */
   rmInitializeLand(cTerrainGreekCliff1, 10);

   // Player placement.
   rmSetTeamSpacingModifier(0.65);
   float radius = xsRandFloat(0.3, 0.35);

   rmPlacePlayersOnSquare(radius, radius);

   // Finalize player placement and do post-init things.
   postPlayerPlacement();

   // Mother Nature's civ.
   rmSetNatureCivFromCulture(cCultureGreek);

   // Lighting.
   rmSetLighting(cLightingSetRmMediterranean01);

   rmSetProgress(0.1);

   // Create player areas to restrict team areas (in case of weird setups like 1v11).
   float separatorWidth = 1.0;

   // Player areas.
   int playerIslandClassID = rmClassCreate();
   int avoidPlayerIsland = rmCreateClassDistanceConstraint(playerIslandClassID, 0.1);
   int playerIslandAvoidPlayerIsland = rmCreateClassDistanceConstraint(playerIslandClassID, separatorWidth);

   for(int i = 1; i <= cNumberPlayers; i++)
   {
      int playerIslandID = rmAreaCreate("player island " + i);
      rmAreaSetSize(playerIslandID, 1.0);
      rmAreaSetLocPlayer(playerIslandID, i);

      rmAreaSetCoherence(playerIslandID, 0.0);

      rmAreaAddConstraint(playerIslandID, playerIslandAvoidPlayerIsland);
      rmAreaAddToClass(playerIslandID, playerIslandClassID);
   }

   rmAreaBuildAll();

   // Team areas.
   int[] teamAreaIDs = new int(0, 0); // Empty array, team area IDs for connections go here.
   int teamIslandClassID = rmClassCreate();
   int teamIslandAvoidTeamIsland = rmCreateClassDistanceConstraint(teamIslandClassID, separatorWidth);
   int teamIslandAvoidEdge = createSymmetricBoxConstraint(rmXMetersToFraction(8.0), rmZMetersToFraction(8.0));

   for(int i = 1; i <= cNumberTeams; i++)
   {
      int teamIslandID = rmAreaCreate("team island " + i);
      rmAreaSetSize(teamIslandID, 1.0);
      rmAreaSetMix(teamIslandID, baseMixID);
      rmAreaSetLocTeam(teamIslandID, i);

      rmAreaSetCliffType(teamIslandID, cTerrainGreekCliff1);
      rmAreaSetCliffSideRadius(teamIslandID, 0, 0);
      rmAreaSetCliffEmbellishmentDensity(teamIslandID, 0.15);

      rmAreaSetCliffLayerPaint(teamIslandID, cCliffLayerOuterSideClose, false);
      rmAreaSetCliffLayerPaint(teamIslandID, cCliffLayerOuterSideFar, false);

      rmAreaSetHeightRelative(teamIslandID, -12.0);
      rmAreaAddHeightBlend(teamIslandID, cBlendEdge, cFilter5x5Gaussian, 5);
      for(int j = 1; j <= cNumberPlayers; j++)
      {
         if(rmGetPlayerTeam(j) != i)
         {
            // Avoid player areas that don't belong to our team.
            rmAreaAddConstraint(teamIslandID, rmCreateAreaDistanceConstraint(rmAreaGetID("player island " + j), 0.1));
         }
      }
      rmAreaAddConstraint(teamIslandID, teamIslandAvoidTeamIsland);
      rmAreaAddConstraint(teamIslandID, teamIslandAvoidEdge);

      rmAreaSetConstraintBuffer(teamIslandID, 0.0, 15.0);

      rmAreaAddToClass(teamIslandID, teamIslandClassID);

      teamAreaIDs.add(teamIslandID);
   }

   rmAreaBuildAll();

   // KotH.
   if (gameIsKotH() == true)
   {
      int islandKotHID = rmAreaCreate("koth island");
      rmAreaSetSize(islandKotHID, rmRadiusToAreaFraction(25.0));
      rmAreaSetLoc(islandKotHID, cCenterLoc);
      rmAreaSetHeight(islandKotHID, 0.0);

      int blendIdx = rmAreaAddHeightBlend(islandKotHID, cBlendAll, cFilter3x3Gaussian, 5, 2);
      rmAreaAddHeightBlendConstraint(islandKotHID, blendIdx, vDefaultAvoidImpassableLand);

      rmAreaSetCliffType(islandKotHID, cTerrainGreekCliff1);
      rmAreaSetCliffSideRadius(islandKotHID, 0, 2);
      rmAreaSetCliffLayerPaint(islandKotHID, cCliffLayerOuterSideClose, false);
      rmAreaSetCliffLayerPaint(islandKotHID, cCliffLayerOuterSideFar, false);

      rmAreaAddCliffEdgeConstraint(islandKotHID, cCliffEdgeIgnored, vDefaultAvoidImpassableLand);

      rmAreaAddToClass(islandKotHID, vKotHClassID);

      rmAreaBuild(islandKotHID);

      teamAreaIDs.add(islandKotHID);
   }

   // To wrap around, add the first area again.
   // By popular demand go for the variant with only one connection to each adjacent team.
   // Path.

   float pathWidth = (25.0 + 2.5 * cNumberPlayers) * getMapAreaSizeFactor();

   int pathDefID = rmPathDefCreate("team connection path");
   // No params to set here, we want direct paths.

   // Areas.
   int pathAreaDefID = rmAreaDefCreate("team connection area");
   rmAreaDefSetMix(pathAreaDefID, baseMixID);

   rmAreaDefSetHeight(pathAreaDefID, 0.0);
   rmAreaDefAddHeightConstraint(pathAreaDefID, rmCreatePassabilityMaxDistanceConstraint(cPassabilityLand, false, 0.0));
   rmAreaDefAddHeightBlend(pathAreaDefID, cBlendAll, cFilter5x5Gaussian);
   
   rmAreaDefSetCliffType(pathAreaDefID, cTerrainGreekCliff1);
   rmAreaDefSetCliffSideRadius(pathAreaDefID, 0, 2);
   rmAreaDefSetCliffLayerEmbellishmentDensity(pathAreaDefID, cCliffLayerInnerSideClose, 0.5);
   rmAreaDefSetCliffLayerEmbellishmentDensity(pathAreaDefID, cCliffLayerInnerSideFar, 0.5);
   rmAreaDefSetCliffLayerPaint(pathAreaDefID, cCliffLayerOuterSideClose, false);
   rmAreaDefSetCliffLayerPaint(pathAreaDefID, cCliffLayerOuterSideFar, false);

   rmAreaDefAddCliffEdgeConstraint(pathAreaDefID, cCliffEdgeIgnored, vDefaultAvoidImpassableLand);

   // Create the connections at the area origins and wrap around (also connecting the last to the first team).
   createAreaConnections("team connection", pathDefID, pathAreaDefID, teamAreaIDs, pathWidth, 10.0, 0.0, cAreaConnectionTypeWrap);

   // KotH.
   placeKotHObjects();

   rmSetProgress(0.2);

   // Settlements and towers.
   // Starting town centers.
   int startingTownCenterID = rmObjectDefCreate("starting town center");
   rmObjectDefAddItem(startingTownCenterID, cUnitTypeCitadelCenter, 1);
   rmObjectDefPlacePerPlayer(startingTownCenterID, true, 1);

   // Starting towers.
   int startingTowerID = rmObjectDefCreate("starting tower");
   rmObjectDefAddItem(startingTowerID, cUnitTypeSentryTower, 1);
   rmObjectDefAddItem(startingTowerID, cUnitTypeTent, 5);
   rmObjectDefAddConstraint(startingTowerID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingTowerID, vDefaultAvoidImpassableLand10);
   addObjectLocsPerPlayer(startingTowerID, true, 4, cStartingTowerMinDist+2, cStartingTowerMaxDist+2, cStartingTowerAvoidanceMeters);
   generateLocations("starting tower locs");

   // Embellishment.
   // Base beautification.
   int baseBeautificationClassID = rmClassCreate();
   float baseBeautificationSize = rmRadiusToAreaFraction(13.0);

   for(int i = 1; i <= cNumberPlayers; i++)
   {
      int p = vDefaultTeamPlayerOrder[i];

      int baseBeautificationAreaID = rmAreaCreate("base area beautification " + p);
      rmAreaSetLocPlayer(baseBeautificationAreaID, p);
      rmAreaSetSize(baseBeautificationAreaID, baseBeautificationSize);
      rmAreaSetTerrainType(baseBeautificationAreaID, cTerrainGreekRoad1);

      rmAreaAddToClass(baseBeautificationAreaID, baseBeautificationClassID);
   }

   rmAreaBuildAll();

   rmSetProgress(0.3);

   // Settlements.
   float avoidSettlementMeters = 60.0;

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
      add1v1ObjectSimLocs(firstSettlementID, false, 1, 60.0, 80.0, avoidSettlementMeters, cBiasBackward);
      add1v1ObjectSimLocs(secondSettlementID, false, 1, 80.0, 100.0, avoidSettlementMeters, cBiasForward);
   }
   else
   {
      addObjectLocsPerPlayer(firstSettlementID, false, 1, 60.0, 80.0, avoidSettlementMeters, cBiasBackward | cBiasAllyInside);
      addObjectLocsPerPlayer(secondSettlementID, false, 1, 80.0, 120.0, avoidSettlementMeters, cBiasAggressive | cBiasAllyInside);
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

   rmSetProgress(0.4);

   // Starting objects.

   int startingGoldMinDist = 15;
   int startingGoldMaxDist = 18;

   // Starting gold.
   int startingGoldID = rmObjectDefCreate("starting gold");
   rmObjectDefAddItem(startingGoldID, cUnitTypeMineGoldMedium, 1);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingGoldID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(startingGoldID, vDefaultStartingGoldAvoidTower);
   addObjectLocsPerPlayer(startingGoldID, false, 1, startingGoldMinDist, startingGoldMaxDist, cStartingObjectAvoidanceMeters, cBiasNotAggressive);

   generateLocations("starting gold locs");

   // Starting hunt.
   float startingHuntFloat = xsRandFloat(0.0, 1.0);
   int startingHuntID = rmObjectDefCreate("starting hunt");
   if(startingHuntFloat < 1.0 / 3.0)
   {
      rmObjectDefAddItem(startingHuntID, cUnitTypeDeer, xsRandInt(3, 6));
      rmObjectDefAddItem(startingHuntID, cUnitTypeBoar, xsRandInt(2, 3));
   }
   else if(startingHuntFloat < 2.0 / 3.0)
   {
      rmObjectDefAddItem(startingHuntID, cUnitTypeDeer, xsRandInt(4, 8));
   }
   else
   {
      rmObjectDefAddItem(startingHuntID, cUnitTypeAurochs, xsRandInt(4, 5));
   }
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingHuntID, vDefaultForceInTowerLOS);
   rmObjectDefAddConstraint(startingHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(startingHuntID, vDefaultAvoidImpassableLand10);
   addObjectLocsPerPlayer(startingHuntID, false, 1, cStartingHuntMinDist, cStartingHuntMaxDist, cStartingObjectAvoidanceMeters);

   // Chicken.
   int startingChickenID = rmObjectDefCreate("starting chicken");
   rmObjectDefAddItem(startingChickenID, cUnitTypeChicken, xsRandInt(6, 9));
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingChickenID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(startingChickenID, vDefaultAvoidImpassableLand10);
   addObjectLocsPerPlayer(startingChickenID, false, 1, cStartingChickenMinDist, cStartingChickenMaxDist, cStartingObjectAvoidanceMeters);

   // Berries.
   int startingBerriesID = rmObjectDefCreate("starting berries");
   rmObjectDefAddItem(startingBerriesID, cUnitTypeBerryBush, xsRandInt(5, 9), 5.0);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(startingBerriesID, vDefaultAvoidImpassableLand10);
   addObjectLocsPerPlayer(startingBerriesID, false, 1, cStartingBerriesMinDist, cStartingBerriesMaxDist, cStartingObjectAvoidanceMeters);

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
   float avoidGoldMeters = 50.0;

   // Close gold.
   int closeGoldID = rmObjectDefCreate("close gold");
   rmObjectDefAddItem(closeGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeGoldID, createTownCenterConstraint(50.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(closeGoldID, false, 1, 50.0, 70.0, avoidGoldMeters);
   }
   else
   {
      addObjectLocsPerPlayer(closeGoldID, false, 1, 50.0, -1.0, avoidGoldMeters);
   }

   // Bonus gold.
   int bonusGoldID = rmObjectDefCreate("bonus gold");
   rmObjectDefAddItem(bonusGoldID, cUnitTypeMineGoldLarge, 1);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusGoldID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(bonusGoldID, createTownCenterConstraint(80.0));

   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(bonusGoldID, false, 2 * getMapSizeBonusFactor(), 60.0, -1.0, avoidGoldMeters);
   }
   else
   {
      addObjectLocsPerPlayer(bonusGoldID, false, 2 * getMapSizeBonusFactor(), 60.0, -1.0, avoidGoldMeters);
   }

   generateLocations("gold locs");

   rmSetProgress(0.6);

   // Hunt.
   float avoidHuntMeters = 50.0;

   // Close hunt.
   int closeHuntID = rmObjectDefCreate("close hunt");
   if(xsRandBool(0.5) == true)
   {
      rmObjectDefAddItem(closeHuntID, cUnitTypeDeer, xsRandInt(4, 8));
   }
   else
   {
      rmObjectDefAddItem(closeHuntID, cUnitTypeBoar, xsRandInt(3, 4));
   }
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(closeHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(closeHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(closeHuntID, createTownCenterConstraint(60.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(closeHuntID, false, 1, 60.0, 80.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(closeHuntID, false, 1, 60.0, 80.0, avoidHuntMeters);
   }

   // Bonus hunt.
   float bonusHuntFloat = xsRandFloat(0.0, 1.0);
   int bonusHuntID = rmObjectDefCreate("bonus hunt");
   if(bonusHuntFloat < 1.0 / 3.0)
   {
      rmObjectDefAddItem(bonusHuntID, cUnitTypeAurochs, xsRandInt(3, 5));
   }
   else if(bonusHuntFloat < 2.0 / 3.0)
   {
      rmObjectDefAddItem(bonusHuntID, cUnitTypeBoar, xsRandInt(3, 5));
   }
   else
   {
      rmObjectDefAddItem(bonusHuntID, cUnitTypeDeer, xsRandInt(6, 8));
   }
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultFoodAvoidGold);
   rmObjectDefAddConstraint(bonusHuntID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(bonusHuntID, createTownCenterConstraint(60.0));
   if(gameIs1v1() == true)
   {
      add1v1ObjectSimLocs(bonusHuntID, false, 1, 60.0, -1.0, avoidHuntMeters);
   }
   else
   {
      addObjectLocsPerPlayer(bonusHuntID, false, 1, 60.0, -1.0, avoidHuntMeters);
   }

   // Large / Giant map size hunt.
   if (cMapSizeCurrent > cMapSizeStandard)
   {
      float largeMapHuntFloat = xsRandFloat(0.0, 1.0);
      int largeMapHuntID = rmObjectDefCreate("large map hunt");
      if(largeMapHuntFloat < 1.0 / 3.0)
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeDeer, xsRandInt(6, 12));
      }
      else if(largeMapHuntFloat < 2.0 / 3.0)
      {
         rmObjectDefAddItem(largeMapHuntID, cUnitTypeAurochs, xsRandInt(2, 4));
      }
      else
      {
         rmObjectDefAddItem(bonusHuntID, cUnitTypeBoar, xsRandInt(4, 7));
      }

      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidAll);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidEdge);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidImpassableLand10);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidWater5);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidTowerLOS);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultFoodAvoidGold);
      rmObjectDefAddConstraint(largeMapHuntID, vDefaultAvoidSettlementRange);
      rmObjectDefAddConstraint(largeMapHuntID, rmCreateLocDistanceConstraint(cCenterLoc, 25.0));
      rmObjectDefAddConstraint(largeMapHuntID, createTownCenterConstraint(80.0));
      addObjectLocsPerPlayer(largeMapHuntID, false, 2 * getMapSizeBonusFactor(), 100.0, -1.0, avoidHuntMeters);
   }

   generateLocations("hunt locs");

   rmSetProgress(0.7);

   // Herdables.
   float avoidHerdMeters = 50.0;

   int closeHerdID = rmObjectDefCreate("close herd");
   rmObjectDefAddItem(closeHerdID, cUnitTypeGoat, xsRandInt(1, 2));
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(closeHerdID, vDefaultAvoidTowerLOS);
   addObjectLocsPerPlayer(closeHerdID, false, xsRandInt(1, 2), 50.0, 70.0, avoidHerdMeters);

   int bonusHerdID = rmObjectDefCreate("bonus herd");
   rmObjectDefAddItem(bonusHerdID, cUnitTypeGoat, xsRandInt(2, 3));
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(bonusHerdID, vDefaultAvoidTowerLOS);
   addObjectLocsPerPlayer(bonusHerdID, false, 1 * getMapSizeBonusFactor(), 70.0, -1.0, avoidHerdMeters);

   generateLocations("herd locs");

   // Predators.
   float avoidPredatorMeters = 50.0;

   int predatorsID = rmObjectDefCreate("predator");
   if(xsRandBool(0.5) == true)
   {
      rmObjectDefAddItem(predatorsID, cUnitTypeWolf, xsRandInt(1, 2));
   }
   else
   {
      rmObjectDefAddItem(predatorsID, cUnitTypeBear, xsRandInt(1, 3));
   }
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(predatorsID, vDefaultFoodAvoidFood);
   rmObjectDefAddConstraint(predatorsID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(predatorsID, createTownCenterConstraint(70.0));
   addObjectLocsPerPlayer(predatorsID, false, xsRandInt(1, 2) * getMapAreaSizeFactor(), 70.0, -1.0, avoidPredatorMeters);

   generateLocations("predator locs");

   // Relics.
   float avoidRelicMeters = 80.0;

   int relicID = rmObjectDefCreate("relic");
   rmObjectDefAddItem(relicID, cUnitTypeRelic, 1);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidEdge);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidTowerLOS);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidSettlementRange);
   rmObjectDefAddConstraint(relicID, vDefaultAvoidImpassableLand5);
   rmObjectDefAddConstraint(relicID, createTownCenterConstraint(60.0));
   addObjectLocsPerPlayer(relicID, false, 2 * getMapAreaSizeFactor(), 60.0, -1.0, avoidRelicMeters);

   generateLocations("relic locs");

   // Stragglers.
   placeStartingStragglers(cUnitTypeTreeOak);

   rmSetProgress(0.8);

   forestGenAddType(cForestGreekMediterranean, 2.0);
   forestGenAddType(cForestGreekMediterraneanDirt, 1.0);

   forestGenSetAreaTiles(80, 120);
   forestGenSetSelfAvoidDist(30.0);
   forestGenAddConstraint(vDefaultAvoidAll);
   forestGenAddConstraint(vDefaultForestAvoidTownCenter);
   forestGenAddConstraint(vDefaultAvoidSettlementWithFarm);
   forestGenAddConstraint(vDefaultAvoidImpassableLand10);

   // Avoid the passes.
   forestGenAddConstraint(rmCreateClassMaxDistanceConstraint(teamIslandClassID, 0.1));

   forestGenGeneratePlayerForests(3, cDefaultPlayerForestOriginMinDist, cDefaultPlayerForestOriginMaxDist);
   forestGenGenerateGlobalForests(4 * cNumberPlayers * getMapSizeBonusFactor());

   rmSetProgress(0.9);

   // Embellishment.
   // Random trees.
   int randomTreeID = rmObjectDefCreate("random tree");
   rmObjectDefAddItem(randomTreeID, cUnitTypeTreeOak, 1);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidAll);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidImpassableLand10);
   rmObjectDefAddConstraint(randomTreeID, vDefaultAvoidSettlementWithFarm);
   rmObjectDefAddConstraint(randomTreeID, vDefaultEmbellishmentTreeAvoidTree);
   rmObjectDefPlaceAnywhere(randomTreeID, 0, 10 * cNumberPlayers * getMapAreaSizeFactor());

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
   int plantShrubID = rmObjectDefCreate("plant shrub");
   rmObjectDefAddItem(plantShrubID, cUnitTypePlantGreekShrub, 1);
   rmObjectDefAddConstraint(plantShrubID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantShrubID, vDefaultAvoidWater5);
   rmObjectDefPlaceAnywhere(plantShrubID, 0, 25 * cNumberPlayers * getMapAreaSizeFactor());

   int plantGrassID = rmObjectDefCreate("plant grass");
   rmObjectDefAddItem(plantGrassID, cUnitTypePlantGreekGrass, 1);
   rmObjectDefAddConstraint(plantGrassID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantGrassID, vDefaultAvoidImpassableLand5);
   rmObjectDefPlaceAnywhere(plantGrassID, 0, 40 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantFernID = rmObjectDefCreate("plant fern");
   rmObjectDefAddItemRange(plantFernID, cUnitTypePlantGreekFern, 1, 2, 0.0, 4.0);
   rmObjectDefAddConstraint(plantFernID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantFernID, vDefaultAvoidImpassableLand5);
   rmObjectDefPlaceAnywhere(plantFernID, 0, 30 * cNumberPlayers * getMapAreaSizeFactor());
   
   int plantWeedsID = rmObjectDefCreate("plant weeds");
   rmObjectDefAddItemRange(plantWeedsID, cUnitTypePlantGreekWeeds, 1, 3, 0.0, 4.0);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultEmbellishmentAvoidAll);
   rmObjectDefAddConstraint(plantWeedsID, vDefaultAvoidImpassableLand5);
   rmObjectDefPlaceAnywhere(plantWeedsID, 0, 20 * cNumberPlayers * getMapAreaSizeFactor());

   // Birbs.
   int birdID = rmObjectDefCreate("bird");
   rmObjectDefAddItem(birdID, cUnitTypeHawk, 1);
   rmObjectDefPlaceAnywhere(birdID, 0, 2 * cNumberPlayers * getMapAreaSizeFactor());

   rmSetProgress(1.0);

   // Create the triggers (to forbid units etc.).
   createTriggers();
}
