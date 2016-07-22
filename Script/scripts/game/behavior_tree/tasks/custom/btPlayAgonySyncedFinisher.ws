/**

*/ 

class CBTTaskPlayAgonySyncedFinisher extends CBTTaskPlaySyncedAnimation
{
	function IsAvailable() : bool
	{
		var owner : CNewNPC = GetNPC();
	
		/*if ( isActive )
		{
			return true;
		}*/
		return super.IsAvailable();
		return owner.IsInFinisherAnim();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return super.OnActivate();
		//return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		super.OnDeactivate();
		owner.FinisherAnimEnd();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		
		/*if ( animEventName == 'AllowBlend' )
		{
			Complete(true);
			return true;
		}*/
		
		return false;
	}
}

class CBTTaskPlayAgonySyncedFinisherDef extends CBTTaskPlaySyncedAnimationDef
{
	default instanceClass = 'CBTTaskPlayAgonySyncedFinisher';
}
