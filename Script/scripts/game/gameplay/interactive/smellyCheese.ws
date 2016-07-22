/***********************************************************************/
/** Copyright © 2014
/** Authors : Danisz Markiewicz
/***********************************************************************/

class W3SmellyCheese extends W3AirDrainEntity
{
	editable var deactivatedByAard : bool;
	editable var smellEffectName : name;
	editable var aardedEffectName : name;
	editable var reactivateTimer : float;
	
	saved var deactivated : bool;
	
	default reactivateTimer = 0.0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if(deactivated)
		{
			PlayEffect(aardedEffectName);
			GetComponent('CheeseSmell').SetEnabled(false);
			//GetComponent('CheeseSmellSmall').SetEnabled(true);
		}
		else
		{
			PlayEffect(smellEffectName);
			GetComponent('CheeseSmell').SetEnabled(true);
			//GetComponent('CheeseSmellSmall').SetEnabled(false);	
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if(!deactivated && deactivatedByAard)
		{
			
			super.OnAardHit(sign);
			StopEffect(smellEffectName);
			PlayEffect(aardedEffectName);
			GetComponent('CheeseSmell').SetEnabled(false);
			//GetComponent('CheeseSmellSmall').SetEnabled(true);
			
			deactivated = true;
			
			if(reactivateTimer > 0.0)
			{
				this.AddTimer('ReactivateVisuals', reactivateTimer, false);
			}
			
		}
		
	}
	

	timer function ReactivateVisuals( delta : float , id : int)
	{
		StopEffect(aardedEffectName);
		PlayEffect(smellEffectName);
		
		this.AddTimer('ReactivateLogic', 0.65, false);
	}

	timer function ReactivateLogic( delta : float , id : int)
	{
		GetComponent('CheeseSmell').SetEnabled(true);
		//GetComponent('CheeseSmellSmall').SetEnabled(false);
		
		deactivated = false;
	}
	
}