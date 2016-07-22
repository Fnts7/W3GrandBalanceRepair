/***********************************************************************/
/**/


//Very Much NOT FINAL
//FIX: this is high level task and should be in proper directory
class CBTTaskNpcRider extends IBehTreeTask
{
	private var activate : bool;
	
	private var horseComponent : W3HorseComponent;
	private var riderEntity : CActor;
	
	function IsAvailable() : bool
	{
		return activate && (CNewNPC)riderEntity;
	}
	
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		activate = false;
		GetNPC().ActionCancelAll();
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'iAmOnTheHorse')
		{
			activate = true;
			horseComponent = GetNPC().GetHorseComponent();
			riderEntity = (CActor)horseComponent.user;
			return true;
		}
		return false;
	}
	
}

class CBTTaskNpcRiderDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskNpcRider';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'iAmOnTheHorse' );
	}
}

