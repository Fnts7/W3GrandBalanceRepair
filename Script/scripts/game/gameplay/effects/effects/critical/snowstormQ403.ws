/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_SnowstormQ403 extends W3Effect_Snowstorm
{
	default effectType = EET_SnowstormQ403;
		
	protected function StopEffects()
	{
		var temp : bool;
		
		//hack usesCam - we want to use different camera fx INSTEAD of base one
		temp = usesCam;
		usesCam = false;
		super.StopEffects();
		usesCam = temp;
		
		if(isOnPlayer)
			theGame.GetGameCamera().StopEffect( 'q403_battle_frost' );		
	}
	
	protected function PlayEffects()
	{
		var temp : bool;
		
		//hack usesCam - we want to use different camera fx INSTEAD of base one
		temp = usesCam;
		usesCam = false;
		super.PlayEffects();
		usesCam = temp;
		
		if(isOnPlayer)
			theGame.GetGameCamera().PlayEffect( 'q403_battle_frost' );
	}
}