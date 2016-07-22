class CBTTaskAdjustVertically extends IBehTreeTask
{
	var maxSlidingSpeed : float; 
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc 				: CNewNPC = GetNPC();
		var npcPos				: Vector;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var traceStartPos, traceEndPos, traceEffect, normal, groundLevel, pos : Vector;
		
		// find ground level
		npcPos = npc.GetWorldPosition();
		traceStartPos = npcPos;
		traceEndPos = npcPos;
		traceEndPos.Z -= 10;
		
		if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
		{
			groundLevel = traceEffect;
		}
		else
		{
			return false;
		}
		
		pos = npcPos;
		pos.Z = groundLevel.Z;
	
		if ( animEventName == 'SlideToTarget' && ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle ) )
		{
			movementAdjustor = npc.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			ticket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, maxSlidingSpeed );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.SlideTo( ticket, pos );
			
			return true;
		}
		
		return false;
	}
};

class CBTTaskAdjustVerticallyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskAdjustVertically';

	editable var maxSlidingSpeed : CBehTreeValFloat;

	default maxSlidingSpeed = 1;
};