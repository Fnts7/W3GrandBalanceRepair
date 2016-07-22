/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Effect that raises max value of one of the stats (e.g. vitality).
*/
abstract class W3ChangeMaxStatEffect extends CBaseGameplayEffect
{
	protected saved var stat : EBaseCharacterStats;			//stat to be raised
	
		default isPositive = true;
	
	// We need to get a proper attribute name based on the stat type, before calling super's constructor
	public function Init(params : SEffectInitInfo)
	{
		attributeName = StatEnumToName(stat);
		super.Init(params);
	}
}