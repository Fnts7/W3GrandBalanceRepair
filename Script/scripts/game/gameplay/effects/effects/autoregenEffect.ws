/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Auto-regeneration effect a.k.a. AutoBuff - special regenration type that is applied automatically when the actor is created.
*/
abstract class W3AutoRegenEffect extends W3RegenEffect
{
	default duration = -1;
	
	/*
		Custom setting because the values of regens are not stored in the buff ability but in default character stats.
		Those stats are defined in XML under character abilities.
	*/
	protected function SetEffectValue()
	{
		if(regenStat != CRS_Undefined)
			effectValue = target.GetAttributeValue( RegenStatEnumToName(regenStat) );
	}
}