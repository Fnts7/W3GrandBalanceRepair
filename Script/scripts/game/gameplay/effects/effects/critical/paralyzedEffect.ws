/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_Paralyzed extends W3ImmobilizeEffect
{
	default effectType = EET_Paralyzed;
	default resistStat = CDS_ShockRes;
	default criticalStateType = ECST_Paralyzed;
	default isDestroyedOnInterrupt = true;
}