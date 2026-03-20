//==============================================================================
/* core.xs

   This file includes all other files in the core folder, and will be included
   by main.xs.

   ATTENTION: Includes JeHathor's functions!

*/
//==============================================================================

//==============================================================================
// Function forward declarations.
//==============================================================================
// Used in loader file to override default values, called at start of main().
mutable void preInit() {}

// Used in loader file to override initialization decisions, called at end of main().
mutable void postInit() {}

// Military
mutable void setLastUnderworldInvasionCastTime(int time = 0) {}

// Strategy.
mutable bool checkStrategyFlag(int flag = 0) { return false; }
mutable int getStrategyTowerAmount() { return 0; }
mutable int getStrategyWallCircleAmount() { return 0; }
mutable int getStrategyMaintainPlans(ref int[] planIDs) { return 0; }

// BO.
mutable bool isBuildOrderDone() { return true; }

// Economy
mutable void alertRanOutOfFoodResources() {}
mutable void alertFoundFoodResources() {}
mutable void alertRanOutOfGoldResources() {}
mutable void alertFoundGoldResources() {}

// Exploration
mutable void helperExploreOtherIslands(int planID = -1) {}

// Migration
mutable int getMigrateToAreaGroupdID() { return -1; }

//==============================================================================
// Includes.
//==============================================================================
include "core/utilities/debug.xs";
include "core/globals.xs";
include "core/globals_override.xs";
include "core/utilities/unit_queries.xs";
include "core/utilities/utilities.xs";
include "core/buildings/dropsite_placement.xs";
include "core/buildings/utilities_buildings.xs";
include "core/startup/startup_flow.xs";
include "core/buildings/buildings.xs";
include "core/buildings/buildings_economic.xs";
include "core/economy/resource_breakdown_system.xs";
include "core/economy/trade.xs";
include "core/godpowers/godpowers_utility.xs";
include "core/godpowers/godpowers_greek.xs";
include "core/godpowers/godpowers_egyptian.xs";
include "core/godpowers/godpowers_norse.xs";
include "core/godpowers/godpowers_atlantean.xs";
include "core/godpowers/godpowers_chinese.xs";
include "core/godpowers/godpowers_japanese.xs";
include "core/godpowers/godpowers.xs";
include "core/military/military_attack.xs";
include "core/military/military_defend.xs";
include "core/military/military_units.xs";
include "core/military/naval_military.xs";
include "core/military/naval_military_units.xs";
include "core/techs.xs";
include "core/economy/economic_units.xs";
include "core/economy/economy.xs";
include "core/exploration.xs";
include "core/bo_system/bo_system_internal_steps.xs";
include "core/bo_system/bo_system_internal.xs";
include "core/bo_system/bo_system_dm.xs";
include "core/bo_system/bo_system.xs";
include "core/strategy/strategy_internal.xs";
include "core/strategy/strategy.xs";
include "core/chats.xs";

// Shared
include "core/shared/archaic/archaic_default_strategy.xs";
include "core/shared/archaic/build_order_strategy.xs";
include "core/shared/classical/classical_default_strategy.xs";
include "core/shared/classical/classical_rusher_strategy.xs";
include "core/shared/classical/classical_turtler_strategy.xs";
include "core/shared/classical/classical_sieger_strategy.xs";
include "core/shared/heroic/heroic_default_strategy.xs";
include "core/shared/heroic/heroic_turtler_strategy.xs";
include "core/shared/mythic/mythic_default_strategy.xs";
include "core/shared/mythic/mythic_turtler_strategy.xs";
include "core/shared/wonder/wonder_default_strategy.xs";
include "core/shared/wonder/wonder_turtler_strategy.xs";
include "core/shared/migrate_main_base_strategy.xs";
include "core/shared/archaic/nomad_strategy.xs";
// Culture specific includes
// Greek
include "core/greek/greek_archaic.xs";
include "core/greek/greek_classical.xs";
include "core/greek/greek_dm.xs";
// Egyptian
include "core/egyptian/egyptian_archaic.xs";
include "core/egyptian/egyptian_classical.xs";
include "core/egyptian/egyptian_dm.xs";
// Norse
include "core/norse/norse_archaic.xs";
include "core/norse/norse_classical.xs";
include "core/norse/norse_dm.xs";
// Atlantean
include "core/atlantean/atlantean_archaic.xs";
include "core/atlantean/atlantean_classical.xs";
include "core/atlantean/atlantean_dm.xs";
// Chinese
include "core/chinese/chinese_archaic.xs";
include "core/chinese/chinese_classical.xs";
include "core/chinese/chinese_dm.xs";
// Japanese
include "core/japanese/japanese_archaic.xs";
include "core/japanese/japanese_classical.xs";
include "core/japanese/japanese_dm.xs";

include "core/scenario/scenario_library.xs";
include "core/setup.xs";
include "core/scenario/scenario_attack_wave_strategy.xs";

include "core/handlers.xs";
include "core/bo_system/bo_system_internal_handler.xs";

// by JeHathor
include "core/testing/micro_military.xs";
include "core/testing/micro_economy.xs";
include "core/testing/forward_buildings.xs";
include "core/testing/target_player.xs";

/* Rule priority.
Always have the correct strategy enabled, or all other rules are working with outdated info.
- strategyMonitor 100
Set up gCloseEnemyBaseID, needed for mostHatedEnemy.
- defendManager 90
Set up what enemy we want to attack, many military systems want that info.
- mostHatedEnemy 85
- mostHatedNavalEnemy 84
Set up all our economic pop counts, which culminates in gMaxMilitaryPop too. Military systems want eco information.
- fishManager 81
  fishingShipMaintainMonitor 80
  caravanMaintainMonitor 79
  villagerMaintainMonitor 78
  mikoMaintainMonitor 77
  economyPopCountsMonitor 76
Set up our military pop counts, many systems want to know how much % army we have.
-  militaryManager 70
   navalMilitaryManager 69
Needs to fire before we update the BO or we incorrectly end it.
-  assignKuafuHeroToGold 51
*/