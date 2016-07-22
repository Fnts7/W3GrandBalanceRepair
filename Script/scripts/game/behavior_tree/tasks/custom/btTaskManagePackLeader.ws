//>--------------------------------------------------------------------------
// BTTaskManagePackLeader
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Define a single npc as leader of the pack in a certain radius
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 15-January-2015
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskManagePackLeader extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------	
	public var packName				: name;
	public var leadingRadius		: float;
	public var forceMeAsLeader		: bool;
	
	private var  m_checkDelay		: float;
	
	default m_checkDelay = 1;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		var l_npc : CNewNPC = GetNPC();
		l_npc.isPackLeader = false;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	latent function Main() : EBTNodeStatus
	{
		var i					: int;
		var l_npc				: CNewNPC = GetNPC();
		var l_otherNPC			: CNewNPC;
		var l_delayToNextCheck	: float;
		var l_leaderIsHere		: bool;
		
		var l_actorsAround		: array<CActor>;
		
		l_npc.packName = packName;
		
		while( true )
		{
			//GetNPC().GetVisualDebug().AddText('IsLeader', "Is Leader: " + l_npc.isPackLeader , Vector(0,0,1.5f ), false,,Color( 255, 255, 255 ), true, 1.2f );
			
			l_actorsAround = GetActorsInRange( l_npc, leadingRadius,,, true );
			l_leaderIsHere = false;
			
			if( forceMeAsLeader  )
			{
				l_npc.isPackLeader = true;
			}
			
			// If a leader already exists
			for( i = 0 ; i < l_actorsAround.Size() ; i += 1 )
			{
				l_otherNPC = (CNewNPC) l_actorsAround[ i ];
				
				if( l_otherNPC == l_npc )
					continue;
				
				if( l_otherNPC.isPackLeader && l_otherNPC.packName == packName )
				{
					// If am already a leader,  I remove the position from the other one
					if( l_npc.isPackLeader )
					{
						l_otherNPC.isPackLeader = false;
					}
					else
					{
						//GetNPC().GetVisualDebug().AddArrow('toLeader', GetNPC().GetWorldPosition() + Vector( 0, 0, 1), l_otherNPC.GetWorldPosition() + Vector( 0, 0, 1), 1, 0.5f, 0.8f, true, Color( 255, 56, 89 ),, 0.5f );
					}
					
					l_leaderIsHere = true;
					
					
				}
			}
			
			// If there is no leader around, become the Leader
			if( !l_npc.isPackLeader && !l_leaderIsHere )
			{
				l_npc.isPackLeader = true;
			}
			
			if( l_npc.isPackLeader )
			{
				GetNPC().GetVisualDebug().AddText('IsLeader', "!!Is Leader!!" + l_npc.isPackLeader , Vector(0,0,1.5f ), false,,Color( 255, 255, 255 ), true, 1.2f );
			}
			
			//Sleep( m_checkDelay );
			SleepOneFrame();
		}
		return BTNS_Completed;
	}

}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskManagePackLeaderDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManagePackLeader';	
	
	editable var packName			: CBehTreeValCName;
	editable var leadingRadius		: float;
	editable var forceMeAsLeader 	: bool;
}