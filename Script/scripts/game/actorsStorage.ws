/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for the actors storage
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Actors Storage functions
/////////////////////////////////////////////

/*enum EScriptQueryFlags
{
	FLAG_ExcludePlayer		= FLAG( 0 ),
	FLAG_OnlyActors			= FLAG( 1 ),
	FLAG_OnlyAliveActors	= FLAG( 2 ),
	FLAG_WindEmitters		= FLAG( 3 ),
	FLAG_Vehicles			= FLAG( 4 ),
	FLAG_ExcludeTarget		= FLAG( 5 ),
	FLAG_Attitude_Neutral	= FLAG( 6 ),		towards actor specfied as 'target' param
	FLAG_Attitude_Friendly	= FLAG( 7 ),		towards actor specfied as 'target' param
	FLAG_Attitude_Hostile	= FLAG( 8 ),		towards actor specfied as 'target' param
	FLAG_ZDiff_3			= FLAG( 9 ),
	FLAG_ZDiff_5			= FLAG( 10 ),
	FLAG_ZDiff_Range		= FLAG( 11 ),
	FLAG_PathLibTest		= FLAG( 12 ),
	FLAG_NotVehicles		= FLAG( 13 ),
	FLAG_TestLineOfSight	= FLAG( 14 ),		broken: with 5 enemies with clear line of sight it finds 0
	
};*/

//Checks if attitude between two entities is the one given by flags
function IsRequiredAttitudeBetween(one, two : CEntity, hostile : bool, optional neutral : bool, optional friendly : bool) : bool
{
	var att : EAIAttitude;
	
	att = GetAttitudeBetween(one, two);
	return (att == AIA_Hostile && hostile) || (att == AIA_Neutral && neutral) || (att == AIA_Friendly && friendly);
}

//gets attitude between two entities
function GetAttitudeBetween(one, two : CEntity) : EAIAttitude
{
	var act1, act2 : CActor;

	if(one && two)
	{
		if( (CPlayer)one && (CPlayer)two )
		{
			return AIA_Friendly;
		}
		else
		{ 
			act1 = (CActor)one;
			act2 = (CActor)two;
			
			if(act1 && act2)
				return act1.GetAttitude(act2);
		}
	}
	
	//some error
	return AIA_Neutral;
}

function GetActorsInRange(center : CNode, range : float, optional maxResults : int, optional tag : name, optional onlyAlive : bool) : array <CActor>
{
	var flags : int;
	var actors : array<CActor>;
	var entities : array<CGameplayEntity>;
	var act : CActor;

	// handle the optionality
	if ( maxResults == 0 )
	{
		maxResults = 1000000;
	}

	if ( onlyAlive )
	{
		FindGameplayEntitiesInSphere( entities, center.GetWorldPosition(), range, maxResults, tag, FLAG_OnlyAliveActors );
	}
	else
	{
		FindGameplayEntitiesInSphere( entities, center.GetWorldPosition(), range, maxResults, tag, FLAG_OnlyActors );
	}

	ArrayOfActorsAppendArrayOfGameplayEntities( actors, entities );
	return actors;
}

function GetNonFriendlyGameplayEntitiesInRange(center : CNode, range : float, attitudeReferenceActor : CActor, optional maxResults : int, optional tag : name) : array<CGameplayEntity>
{
	var ents : array<CGameplayEntity>;
	
	if ( maxResults == 0 )
	{
		maxResults = 1000000;
	}
	
	FindGameplayEntitiesInSphere( ents, center.GetWorldPosition(), range, maxResults, tag, FLAG_Attitude_Neutral | FLAG_Attitude_Hostile, attitudeReferenceActor );
	return ents;
}

// This method finds entities inside BOX with radius equal to range - if you REALLY need to find entities inside sphere (ball) - use the method below
import function FindGameplayEntitiesInRange(out			entities  		: array< CGameplayEntity >,
														center    		: CNode,
														range     		: float,
														maxResults		: int,
											optional	tag       		: name, /*=''*/
											optional	queryFlags		: int, /*=0*/ // please combine EScriptQueryFlags
											optional	target			: CGameplayEntity, /*=NULL*/ // please combine EScriptQueryFlags
											optional	className		: name /*=''*/
											);

// If you don't need exact sphere (ball) use "general" (InRange) method (cause it's faster)
//ACHTUNG!!! entities is NOT cleared on function call!!!!!!!
import function FindGameplayEntitiesInSphere(	out				entities  		: array< CGameplayEntity >,
																point    		: Vector,
																range     		: float,
																maxResults		: int,
													optional	tag       		: name, /*=''*/
													optional	queryFlags		: int, /*=0*/ // please combine EScriptQueryFlags
													optional	target			: CGameplayEntity,  /*=NULL*/ // please combine EScriptQueryFlags
													optional	className		: name /*=''*/
												);

import function FindGameplayEntitiesInCylinder(	out				entities  		: array< CGameplayEntity >,
																point    		: Vector,
																range     		: float,
																height     		: float,
																maxResults		: int,
													optional	tag       		: name, /*=''*/
													optional	queryFlags		: int, /*=0*/ // please combine EScriptQueryFlags
													optional	target			: CGameplayEntity,  /*=NULL*/ // please combine EScriptQueryFlags
													optional	className		: name /*=''*/
												);


import function FindGameplayEntitiesInCone(	out					entities  		: array< CGameplayEntity >,
																point    		: Vector,
																coneDir			: float,
																coneAngle		: float,
																range     		: float,
																maxResults		: int,
													optional	tag       		: name, /*=''*/
													optional	queryFlags		: int, /*=0*/ // please combine EScriptQueryFlags
													optional	target			: CGameplayEntity,  /*=NULL*/ // please combine EScriptQueryFlags
													optional	className		: name /*=''*/
												);
												
import function FindGameplayEntitiesInBox(	out					entities  		: array< CGameplayEntity >,
																point    		: Vector,																
																boxLS  			: Box, // box defined in local space (in respect to 'point' position)
																maxResults		: int,
													optional	tag       		: name, /*=''*/
													optional	queryFlags		: int, /*=0*/ // please combine EScriptQueryFlags
													optional	target			: CGameplayEntity,  /*=NULL*/ // please combine EScriptQueryFlags
													optional	className		: name /*=''*/
												);
// Find nerby entities (slower version, allowing to pass the point instead of CNode)
import function FindGameplayEntitiesCloseToPoint(	out			entities  		: array< CGameplayEntity >,
																point    		: Vector,
																range     		: float,
																maxResults		: int,
													optional	tag       		: name, /*=''*/
													optional	queryFlags		: int, /*=0*/ // please combine EScriptQueryFlags
													optional	target			: CGameplayEntity, /*=NULL*/ // please combine EScriptQueryFlags
													optional	className		: name /*=''*/
												);
// This method finds entities which intersects line (start-end) of specified radius
import function FindActorsAtLine(			startPos    			: Vector,
											endPos    				: Vector,
											radius     				: float,
								out 		result 					: array<SRaycastHitResult>,
								optional 	collisionGroupsNames 	: array<name>
											);