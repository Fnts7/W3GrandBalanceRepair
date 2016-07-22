/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Wait for tagged target to approach
/** Copyright © 2012
/***********************************************************************/

class CBTTaskWaitFor extends IBehTreeTask
{
	var waitForTag : CName;
	var timeout : float;
	var testDistance : float;
	var timeoutCounter : float;

	latent function Main() : EBTNodeStatus
	{	
		var npc : CNewNPC = GetNPC();
		var target : CEntity;
		
		timeoutCounter = GetLocalTime() + timeout;
		target = theGame.GetEntityByTag( waitForTag );
		
		while( true )
		{
			if ( !target )
			{
				return BTNS_Failed;
			}
			// Time ran out
			if( timeout > 0.0f && timeoutCounter > GetLocalTime() )
			{
				return BTNS_Completed;
			}
			
			// Target approached
			if( VecDistance2D( target.GetWorldPosition(), npc.GetWorldPosition() ) < testDistance )
			{
				return BTNS_Completed;
			}
			Sleep( 1.0f );
		}
		
		return BTNS_Active;
	}
}

class CBTTaskWaitForDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskWaitFor';

	editable var waitForTag : CBehTreeValCName;
	editable var timeout : CBehTreeValFloat;
	editable var testDistance : CBehTreeValFloat;
}
