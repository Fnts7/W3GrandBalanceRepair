/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014
/***********************************************************************/


// EAsyncTestResult - asynchronous task result

//enum EAsyncTestResult
//{
//	EAsyncTastResult_Failure,
//	EAsyncTastResult_Success,
//	EAsyncTastResult_Pending,
//	EAsyncTastResult_Invalidated,
//};


// ENavigationReachabilityTestType - reachabiltiy query type

//enum ENavigationReachabilityTestType
//{
//	ENavigationReachability_All = PathLib::CMultiReachabilityData::REACH_ALL,					- Query fails is any point is not-reachable.
//	ENavigationReachability_Any = PathLib::CMultiReachabilityData::REACH_ANY,					- Query success if any point is reachable.
//	ENavigationReachability_FullTest = PathLib::CMultiReachabilityData::REACH_FULL				- Query tests all positions, and success if at least one is reachable.
//};



import class CNavigationReachabilityQueryInterface extends IScriptable
{
	// Returns last query output
	// queryValidTime - time at which we consider query to be valid
	import final function GetLastOutput( optional queryValidTime : float ) : EAsyncTestResult;
	
	import final function GetOutputClosestDistance() : float;
	import final function GetOutputClosestEntity() : CEntity;
	
	// Starts new query
	import final function TestActorsList
		( testType : ENavigationReachabilityTestType											// query type
		, originActor : CActor																	// actor whos reachability we are testing
		, list : array< CActor >																// list of possible targets
		, optional safeSpotTolerance : float													// if origin pos is not accessible we will try to find a safe spot - in given tolerance radius
		, optional pathfindDinstanceLimit : float )												// is specified and > 0 will require pathfinding test to 
		: EAsyncTestResult;
};
