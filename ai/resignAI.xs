/*******************************************************************************
*
*	RESIGN AI - by JeHathor	(Feb 2025)
*
*
*******************************************************************************/
//==============================================================================
// useSimpleUnitQuery
//==============================================================================
int useSimpleUnitQuery(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive,
   vector position = cInvalidVector, float radius = -1.0)
{
   static int unitQueryID = -1;

   // If we don't have the query yet, create one.
   if (unitQueryID < 0)
   {
      unitQueryID = kbUnitQueryCreate("useSimpleUnitQuery");
   }

   // Define a query to get all matching units.
   if (unitQueryID != -1)
   {
      if (playerRelationOrID > 1000) // Too big for player ID number.
      {
         kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
      }
      else
      {
         kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
      }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
      kbUnitQuerySetPosition(unitQueryID, position);
      kbUnitQuerySetMaximumDistance(unitQueryID, radius);
   }
   else
   {
      return -1;
   }

   kbUnitQueryResetResults(unitQueryID);
   return unitQueryID;
}
//==============================================================================
// deleteEverything
//==============================================================================
void deleteEverything(void)
{
   int unitQueryID = useSimpleUnitQuery(cUnitTypeAll, cMyID, cUnitStateAlive);
   int numberFound = kbUnitQueryExecute(unitQueryID);
   aiTaskDeleteUnits(kbUnitQueryGetResults(unitQueryID));
}
//==============================================================================
// MAIN
//==============================================================================
void main() { deleteEverything(); aiResign(); xsDisableSelf(); }
