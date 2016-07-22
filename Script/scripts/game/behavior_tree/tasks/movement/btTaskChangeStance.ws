/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBTTaskChangeStance extends IBehTreeTask
{
	var newStance 						: ENpcStance;
	var setPrevStanceOnDeactivation		: bool;
	var oldStance						: ENpcStance;
	var onDeactivate					: bool;
	var changeToFlyOnlyIfAboveGround	: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if( onDeactivate ) return BTNS_Active;
		
		if ( setPrevStanceOnDeactivation )
		{
			oldStance = npc.GetCurrentStance();
		}
		
		if ( !InternalChangeStance( newStance ) )
		{
			return BTNS_Failed;
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate )
		{
			InternalChangeStance( newStance );
		} 
		else if ( setPrevStanceOnDeactivation )
		{
			InternalChangeStance( oldStance );
		}
	}
	
	private function InternalChangeStance( _Stance : ENpcStance ) : bool
	{
		var l_distanceFromGround	 : float;
		if( changeToFlyOnlyIfAboveGround && _Stance == NS_Fly )
		{
			l_distanceFromGround = GetNPC().GetDistanceFromGround( 2 );
			
			if( l_distanceFromGround > 1 )
			{
				return GetNPC().ChangeStance( _Stance );
			}
			else
			{
				return false;
			}
		}
		else
		{
			return GetNPC().ChangeStance( _Stance );
		}
	}
	
	
}

class CBTTaskChangeStanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangeStance';

	editable var newStance 						: ENpcStance;
	editable var setPrevStanceOnDeactivation	: bool;
	editable var onDeactivate					: bool;
	editable var changeToFlyOnlyIfAboveGround	: bool;
}

