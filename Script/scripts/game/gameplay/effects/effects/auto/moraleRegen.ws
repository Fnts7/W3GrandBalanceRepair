/***********************************************************************/
/** Copyright © 2012-2013
/** Author : Rafal Jarczewski, Tomek Kozera
/***********************************************************************/

// Automatic morale regeneration - set this up in entity template
class W3Effect_AutoMoraleRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoMoraleRegen;
	default regenStat = CRS_Morale;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Morale ) >= 1.0f )
		{
			target.StopMoraleRegen();
		}
	}
}