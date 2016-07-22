/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Andrzej Kwiatkowski, Tomek Kozera
/***********************************************************************/

class W3Effect_LongStagger extends W3Effect_Stagger
{
	default criticalStateType 		= ECST_LongStagger;
	default effectType 				= EET_LongStagger;
	
	private var owner : CEntity;
	
	public function OnTimeUpdated(dt : float)
	{
		if( !owner )
		{
			owner = EntityHandleGet( creatorHandle );
		}
		
		if( owner && owner.HasTag( 'fairytale_witch' ) )
		{
			timeToEnableDodge = 1.f;
		}
		
		super.OnTimeUpdated(dt);
	}
}
