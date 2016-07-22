/***********************************************************************/
/** Copyright © 2014
/** Author : Tomasz Kozera
/***********************************************************************/

class W3Effect_BleedingTracking extends W3DamageOverTimeEffect
{	
	private var bloodTemplate : CEntityTemplate;
	private var bloodSpawnTimer : float;
	private const var BLOOD_SPAWN_DELAY_MIN, BLOOD_SPAWN_DELAY_MAX : int;			//how often to spawn blood entity
	
	default BLOOD_SPAWN_DELAY_MIN = 2;
	default BLOOD_SPAWN_DELAY_MAX = 3;
	default effectType = EET_BleedingTracking;
	default resistStat = CDS_BleedingRes;
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		//if target received no damage then we shut off the particle effect
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			PlayTargetFX();
		}		
	}
	
	event OnUpdate(dt : float)
	{
		var pos, posTo, posUp, tempV, posDown : Vector;
		
		super.OnUpdate(dt);
		
		bloodSpawnTimer -= dt;
		if(bloodSpawnTimer <= 0)
		{
			//spawn entity
			pos = target.GetWorldPosition();
			posUp = pos;
			posUp.Z += 0.2;		//failsafe if entity is slightly below terrain level
			posDown = pos;
			posDown.Z -= 50;	//high value for flying monsters to leave blood trails while flying
			
			if(theGame.GetWorld().StaticTrace( posUp, posDown, posTo, tempV))
			{
				posTo.Z += 0.05;	//if spawned on terrain might clip through and be displayed under terrain
			}
			else
			{
				posTo = posUp;
			}

			theGame.CreateEntity(bloodTemplate, posTo, EulerAngles(0, RandF() * 360, 0), , , , PM_Persist);
		
			//reset clock
			bloodSpawnTimer = RandRangeF(BLOOD_SPAWN_DELAY_MAX, BLOOD_SPAWN_DELAY_MIN);
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		bloodTemplate = (CEntityTemplate)LoadResource("tracking_bolt_blood");
		bloodSpawnTimer = 0;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		bloodTemplate = (CEntityTemplate)LoadResource("tracking_bolt_blood");
		bloodSpawnTimer = 0;
	}
}