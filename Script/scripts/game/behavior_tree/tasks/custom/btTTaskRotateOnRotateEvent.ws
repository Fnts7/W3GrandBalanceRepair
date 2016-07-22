class BTTaskRotateOnRotateEvent extends IBehTreeTask
{
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'RotateEventStart')
		{
			GetNPC().SetRotationAdjustmentRotateTo( GetActionTarget() );
			return true;
		}
		if ( eventName == 'RotateAwayEventStart')
		{
			GetNPC().SetRotationAdjustmentRotateTo( GetActionTarget(), 180.0 );
			return true;
		}
		
		return false;
	}
}

class BTTaskRotateOnRotateEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskRotateOnRotateEvent';
}