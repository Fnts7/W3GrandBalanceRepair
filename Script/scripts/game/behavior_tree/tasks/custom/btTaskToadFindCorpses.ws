class CBTTaskToadFindCorpses extends IBehTreeTask
{
	var corpsesArray 		: array< CGameplayEntity >;
	var closestCorpse		: CGameplayEntity;
	var searchRange			: float;
	var maxResults			: int;
	var tag					: name;
	var i					: int;
	var npc					: CNewNPC;
	var tempMinDist			: float;
	var minDist				: float;
	var closestCorpsePos 	: Vector;
	
	default searchRange = 15.0;
	default maxResults = 3;
	default tag = 'q601_toad_corpse';
	
	function OnActivate() : EBTNodeStatus //move to isAvailable
	{
		minDist = 1000.0;
		npc = GetNPC();
		corpsesArray.Clear();
		
		FindGameplayEntitiesInRange( corpsesArray, npc, searchRange, maxResults, tag );
		if( corpsesArray.Size() )
		{
			return BTNS_Active;
		}
		else
		{
			return BTNS_Failed;
		}
		
	}
	
	latent function Main() : EBTNodeStatus
	{
		for( i=0; i<corpsesArray.Size(); i+=1 )
		{
			tempMinDist = VecDistance2D( npc.GetWorldPosition(), corpsesArray[i].GetWorldPosition() );
			if( tempMinDist < minDist )
			{
				minDist = tempMinDist;
				closestCorpse = corpsesArray[i];
			}
		}
		/*if( minDist > 9.0)
		{
			return BTNS_Failed;
		}*/
		SetActionTarget( closestCorpse );
		
		return BTNS_Completed;
	}
	

}
class CBTTaskToadFindCorpsesDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskToadFindCorpses';
	
	editable var searchRange		: float;
	editable var maxResults			: int;
	editable var tag				: name;

}
