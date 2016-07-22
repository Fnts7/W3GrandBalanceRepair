/****************************************/
/** Copyright © 2016
/** Author : Andrzej Zawadzki
/****************************************/

class W3Effect_Acid extends W3DamageOverTimeEffect
{
	default effectType = EET_Acid;
	default isPositive = false;
	default powerStatType = CPS_Undefined;
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		target.SoundEvent( 'ep2_mutations_04_poison_blood_spray_enemy' );
	}
}