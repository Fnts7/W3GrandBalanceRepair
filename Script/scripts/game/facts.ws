/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for the facts DB
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Facts DB functions
/////////////////////////////////////////////


struct SFactParameters
{
	editable var ID			: string;
	editable var value		: int;
	editable var validFor	: int;
}

/*
	Adds a new fact.
	
	validFor - in real seconds for which the fact is valid, -1 means valid forever
	
	After the time ends the fact's value is set to 0 HOWEVER the fact is not removed - make sure to check it using QuerySum rather than DoesExist
*/
import function FactsAdd( ID : string, optional value : int, optional validFor : int /* = -1 */ );

// Returns a sum of values of all the facts with the specified id.
import function FactsQuerySum( ID : string ) : int;

// Returns a sum of values of all the facts with the specified id
// that were added after the 'sinceTime'
import function FactsQuerySumSince( ID : string, sinceTime : EngineTime ) : int;

// Returns the value of the most recently added fact with the specified id.
import function FactsQueryLatestValue( ID : string ) : int;

// Checks if the specified fact is defined in the DB.
import function FactsDoesExist( ID : string ) : bool;

// Removes a single fact from the facts db.
import function FactsRemove( ID : string ) : bool;

function FactsSet(ID : string, val : int, optional validFor : int )
{
	FactsRemove(ID);
	
	//magic numbers for engine's custom default values
	if(validFor == 0)
		validFor = -1;	

	FactsAdd(ID, val, validFor);
}

function FactsSubstract(ID : string, optional val : int)
{
	if(val == 0)
		val = 1;
		
	if(val > 0)
		FactsSet(ID, Max(0, FactsQuerySum(ID) - val) );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////   GAMEPLAY FACTS   //////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
	Duplicated facts db functionality. The reason is that if game is paused or if gametime is frozen (e.g. constant 15:30)
	then facts CANNOT be removed from DB until game is unpaused / time is unfrozen.
*/

struct SGameplayFact
{
	saved var factName : string;
	saved var value : int;
};

struct SGameplayFactRemoval
{
	saved var factName : string;
	saved var value : int;
	saved var timerID : int;
};

function GameplayFactsAdd(factName : string, optional value : int, optional realtimeSecsValidFor : int)
{
	theGame.GameplayFactsAdd(factName, value, realtimeSecsValidFor);
	theGame.GetGlobalEventsManager().OnScriptedEventString( SEC_GameplayFact, SET_Unknown, factName );
}

function GameplayFactsSet(factName : string, value : int)
{
	theGame.GameplayFactsSet(factName, value);
	theGame.GetGlobalEventsManager().OnScriptedEventString( SEC_GameplayFact, SET_Unknown, factName );
}

function GameplayFactsQuerySum(factName : string) : int
{
	return theGame.GameplayFactsQuerySum(factName);
}

function GameplayFactsRemove(factName : string)
{
	return theGame.GameplayFactsRemove(factName);
	theGame.GetGlobalEventsManager().OnScriptedEventString( SEC_GameplayFact, SET_Unknown, factName );
}