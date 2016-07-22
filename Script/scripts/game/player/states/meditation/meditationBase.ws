/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Tomek Kozera
/***********************************************************************/

abstract state MeditationBase in W3PlayerWitcher extends ExtendedMovable
{
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( -1.5, 0.f, 0.f ), 0.5f, dt );

		return true;
	}
	
	//requests the entire meditation state to finish
	public function StopRequested(optional closeUI : bool);
	
	event OnReactToBeingHit( damageAction : W3DamageAction )
	{
		var ret : bool;
		var tox : W3Effect_Toxicity;
		
		ret = virtual_parent.OnReactToBeingHit(damageAction);
		
		//don't stop if damaged by toxicity
		tox = (W3Effect_Toxicity)damageAction.causer;
		if(!tox)		//for some reason this does not work without the use of local variable
			StopRequested(true);
			
		return ret;
	}
}