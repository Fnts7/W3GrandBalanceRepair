//>--------------------------------------------------------------------------
// BTTaskIrisDeath
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskIrisDeath extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		var i						: int;
		var l_npc 					: W3NightWraithIris;
		var l_availablePaintings 	: array<CNode>;
		
		l_npc = (W3NightWraithIris) GetNPC();
		l_npc.StopEffect('drained_paint');
		
		
		/*l_availablePaintings = l_npc.GetAvailablePaintings();
		
		// Loop just in case there is less than 5 available paintings
		for( i = 0; i < l_availablePaintings.Size() ; i += 1 )
		{
			if( i == 0 )
				l_npc.PlayEffect( 'suck_into_painting', l_availablePaintings[i] );
			else if( i == 1 )
				l_npc.PlayEffect( 'suck_into_painting_01', l_availablePaintings[i] );
			else if( i == 2 )
				l_npc.PlayEffect( 'suck_into_painting_02', l_availablePaintings[i] );
			else if( i == 3 )
				l_npc.PlayEffect( 'suck_into_painting_03', l_availablePaintings[i] );
			else if( i == 4 )
				l_npc.PlayEffect( 'suck_into_painting_04', l_availablePaintings[i] );
		}*/
		
		
		return BTNS_Active;
	}
}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskIrisDeathDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisDeath';
}