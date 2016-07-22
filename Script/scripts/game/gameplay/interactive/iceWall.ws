/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3IceWall extends CGameplayEntity
{
	event OnFireHit(source : CGameplayEntity)
	{
		super.OnFireHit(source);
		
		//fx with force to break the ice
		PlayEffect('break_force');
	}
}