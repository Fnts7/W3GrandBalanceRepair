//-----------------------------------------------------------------------
// Copyright © 2014
// Author : R.Pergent
//-----------------------------------------------------------------------

//Aura that applies fire effect on all targets
class W3FireAura extends W3Effect_Aura
{
	default effectType = EET_FireAura;	
	
	protected function ApplySpawnsOn( entityGE : CGameplayEntity)
	{
		//process burning effect or just OnFireHit() if it's not an actor
		if( (CActor)entityGE )
			super.ApplySpawnsOn( entityGE );
		else
			entityGE.OnFireHit( GetCreator() );
	}
}