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

// Strategy.
mutable bool checkStrategyFlag(int flag = 0) { return false; }
mutable int getStrategyTowerAmount() { return 0; }
mutable int getStrategyWallCircleAmount() { return 0; }

// BO.
mutable bool isBuildOrderDone() { return true; }

// Economy
mutable void alertRanOutOfFoodResources() {}
mutable void alertFoundFoodResources() {}

// Exploration
mutable void helperExploreOtherIslands(int planID = -1) {}

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
include "core/godpowers/godpowers_utility.xs";
include "core/godpowers/godpowers_greek.xs";
include "core/godpowers/godpowers_egyptian.xs";
include "core/godpowers/godpowers_norse.xs";
include "core/godpowers/godpowers_atlantean.xs";
include "core/godpowers/godpowers.xs";
include "core/military/military_attack.xs";
include "core/military/military_defend.xs";
include "core/military/military_units.xs";
include "core/military/naval_military.xs";
include "core/military/naval_military_units.xs";
include "core/economy/trade.xs";
include "core/techs.xs";
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
include "core/shared/classical/classical_default_strategy.xs";
include "core/shared/heroic/heroic_default_strategy.xs";
include "core/shared/mythic/mythic_default_strategy.xs";
include "core/shared/wonder/wonder_default_strategy.xs";
include "core/shared/migrate_main_base.xs";
include "core/shared/archaic/nomad_strategy.xs";
// Culture specific includes
// Greek
include "core/greek/archaic/greek_archaic.xs";
include "core/greek/classical/greek_classical.xs";
include "core/greek/greek_dm.xs";
// Egyptian
include "core/egyptian/egyptian_archaic.xs";
include "core/egyptian/egyptian_classical.xs";
include "core/egyptian/egyptian_dm.xs";
// Norse
include "core/norse/archaic/norse_archaic.xs";
include "core/norse/classical/norse_classical.xs";
include "core/norse/norse_dm.xs";
// Atlantean
include "core/atlantean/atlantean_archaic.xs";
include "core/atlantean/atlantean_classical.xs";
include "core/atlantean/atlantean_dm.xs";

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
