/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Effect that raises power stat value (attack/spell power)
*/
abstract class W3RaisePowerStatEffect extends CBaseGameplayEffect
{
	protected saved var stat : ECharacterPowerStats;		//stat to increase
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	public function Init(params : SEffectInitInfo)
	{
		attributeName = PowerStatEnumToName(stat);
		super.Init(params);
	}
}