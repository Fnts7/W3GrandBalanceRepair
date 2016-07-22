/***********************************************************************/
/** Copyright © 2014
/** Author : Michal Slapa
/***********************************************************************/

import class CAIAttackRange
{
	import var rangeMax				: float;
	import var height				: float;
	import var angleOffset			: float;
	import var position				: Vector;
	import var checkLineOfSight		: bool;
	import var lineOfSightHeight	: float;
	import var useHeadOrientation	: bool;	

	import final function Test( sourceEntity : CGameplayEntity, targetEntity : CGameplayEntity ) : bool;
	import final function GatherEntities( sourceEntity : CGameplayEntity, out entities : array< CGameplayEntity > );
}
