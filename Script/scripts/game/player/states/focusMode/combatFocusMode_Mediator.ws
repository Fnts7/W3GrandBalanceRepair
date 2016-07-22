/*
class W3FocusModeMediator
{
	var vState : W3PlayerWitcherStateCombatFocusMode_SelectSpot;
	
	public function Init()
	{
		vState = ((W3PlayerWitcherStateCombatFocusMode_SelectSpot)thePlayer.GetState('CombatFocusMode_SelectSpot'));
	}
	
	public function Deinit()
	{
		vState = NULL;
	}
	
	public function GetAvailableVitalSpots( out spots : array<SVitalSpotInfo> )
	{
		if ( vState )
		{
			spots = vState.aSpots;
		}
	}
	
	public function GetEnemyData() : SCombatFocusModeEnemyData
	{
		var null : SCombatFocusModeEnemyData;
	
		if ( vState )
		{
			return vState.enemyData;
		}
		
		return null;
	}
	
	// Use this please - true means you will go to new state
	public final function EyeView() : bool
	{
		if ( vState )
		{
			LogChannel('CFM_DEBUG'," EyeView ");
			return vState.EyeView();
		}
		return false;
	}
	
	// Use this please
	public final function NormalView() : bool
	{
		if ( vState )
		{
			LogChannel('CFM_DEBUG'," NormalView");
			return vState.NormalView();
		}
		return false;
	}
	
	// Use this please
	public final function NormalViewFar() : bool
	{
		if ( vState )
		{
			LogChannel('CFM_DEBUG'," NormalFarView");
			return vState.NormalViewFar();
		}
		return false;
	}
	
	// Use this please
	public function LookAtView( spotId : int ) : bool
	{
		if ( vState )
		{
			LogChannel('CFM_DEBUG'," LookAtView "+spotId);
			return vState.LookAtView( spotId );
		}
		return false;
	}
	
	// Use this please
	public final function IsInEyeView() : bool
	{
		if ( vState )
		{
			return vState.IsInEyeView();
		}
		return false;
	}
	
	// Use this please
	public final function IsInNormalView() : bool
	{
		if ( vState )
		{
			return vState.IsInNormalView();
		}
		return false;
	}
	
	// Use this please
	public final function IsInNormalFarView() : bool
	{
		if ( vState )
		{
			return vState.IsInNormalFarView();
		}
		return false;
	}
	
	// Use this please
	public function IsInLookAtView( spotId : int ) : bool
	{
		if ( vState )
		{
			return vState.IsInLookAtView( spotId );
		}
		return false;
	}
	
	public function IsInAnyLookAtView() : bool
	{
		if ( vState )
		{
			return vState.IsInAnyLookAtView();
		}
		return false;
	}
	
	public function GetLookAtViewSpot() : int
	{
		if ( vState )
		{
			return vState.GetLookAtViewSpot();
		}
		return -1;
	}
	
	// Yes this function's name is cool
	public function HereAreTheSpotsToUse( spotIds : array<int> ) // #B we can change it to HereIsSpotToUse( spotId : int )
	{
		if ( vState )
		{
			vState.HereAreTheSpotsToUse( spotIds );
		}
	}
	
	// Yes this function's name is cool
	public function HereIsTheSpotToUse( spotId : int )
	{
		var spotArray : array<int>; // @FIXME TOMSIN remove when We use single int, not an array
		if ( vState )
		{
			spotArray.PushBack(spotId); // @FIXME TOMSIN remove when We use single int, not an array
			vState.HereAreTheSpotsToUse( spotArray ); // @FIXME TOMSIN remove when We use single int, not an array
		}
	}
}
*/