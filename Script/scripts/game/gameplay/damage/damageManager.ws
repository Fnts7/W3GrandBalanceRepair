/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014
/** Author :  Tomek Kozera
/***********************************************************************/

/*
  Class deals with damage dealing. Damage manager is given a DamageAction object
  based on which it delivers damage to the victim. DM takes under consideration all
  possible damage modifiers (bonuses, spells, skills, protection, dodging, immortality etc.).
  DM also displays hit particles and sends info regarding which hit animation to use.
  
  The damage manager object should be a singleton held in theGame object.
*/
class W3DamageManager
{
	public function ProcessAction(act : W3DamageAction)
	{
		var proc : W3DamageManagerProcessor;
		var wasAlive : bool;
		var npc : CNewNPC;
		var playerAttacker : CR4Player;
		
		if(!act || !act.victim)
			return;
			
		wasAlive = act.victim.IsAlive();
		
		//if victim dead and no buffs in action -> nothing to do here...
		if(!wasAlive && act.GetEffectsCount() == 0)
			return;
		
		playerAttacker = (CR4Player)act.attacker;
		npc = (CNewNPC)act.victim;
		
		//victim is npc, player attacks and npc is not attackable by player
		if ( playerAttacker && npc && !npc.isAttackableByPlayer )
			return;
		
		//need one processing object per action as processed action can create new action to process (returned damage)
		proc = new W3DamageManagerProcessor in this;
		proc.ProcessAction(act);
		delete proc;
	}
}
