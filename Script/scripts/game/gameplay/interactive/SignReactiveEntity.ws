// Ł.SZ A class for entity that can change appearance when a sign aard or igni is cast

class CSignReactiveEntity extends W3MonsterClue
{
	editable var factOnSignCast 			: string;
	editable saved  var igni 				: bool;
	editable saved  var aard 				: bool;
	editable var clueActionWhenDestroyed	: EClueOperation; default clueActionWhenDestroyed = CO_None;//default clueDisablesWhenDestroyed = false;
	editable var igniteOnInteraction		: bool; default igniteOnInteraction = false;
	
	editable var destroyingTimeout			: float; default destroyingTimeout = 5;
	editable var destroyedEffectsTimeout	: float; default destroyedEffectsTimeout = 10;
	
	editable var destroyingEffectName		: name; default destroyingEffectName = 'destroy';
	editable var destroyedEffectName		: name; default destroyedEffectName = 'destroyed';
	
	private var isDestroyed					: bool;
	private var clueActionArray				: array <EClueOperation>;
	
	private var currentAppearance 			: string;   default currentAppearance = "default";
	
	private var interactionComponents		: array <CComponent>;
	private var i							: int;
	
	public function IsDestroyed() : bool
	{
		return isDestroyed;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		ApplyAppearance( currentAppearance );
		super.OnSpawned( spawnData );
		Init();
	}
	event OnIgniHit( sign : W3IgniProjectile )
	{
		if ( igni && !isDestroyed  )
		{
			HitByFire();
			super.OnIgniHit(sign);
		}	
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if ( aard && !isDestroyed )
		{
			StartDestroyed(true);
			currentAppearance = "destroyed";
			PlayEffect(destroyingEffectName, this );
			AddTimer ( 'ApplyDestroyAppearance', destroyingTimeout, , , , true );
			super.OnAardHit(sign);
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( !igni )
		{
			return false;
		}
	}
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator == thePlayer && actionName == "Ignite" )
		{
			if(!thePlayer.CanPerformPlayerAction())
				return false;
			
			if(!isDestroyed)
			{
				thePlayer.PlayerStartAction( PEA_IgniLight );
				HitByFire();
			}		
		}
		else
		{
			super.OnInteraction(actionName,activator);
		}
	}
	
	public function EnableSignReactivness ( enable : bool )
	{
		 igni = enable;
		 aard = enable;
	}
	private function Init()
	{
		
	}
	
	private function HitByFire()
	{	
		interactionComponents = this.GetComponentsByClassName('CInteractionComponent');
		if (interactionComponents.Size()>0)
		{
			for (i = 0; i < interactionComponents.Size(); i += 1)
			{
				interactionComponents[i].SetEnabled(false);
			}
		}
		if ( factOnSignCast != "" )
		{
			FactsAdd( factOnSignCast, 1, -1 );
		}
		StartDestroyed(true);
		currentAppearance = "destroyed";
		PlayEffect(destroyingEffectName);//, this );
		AddTimer ( 'ApplyDestroyAppearance', destroyingTimeout, , , , true );
	}
	
	private timer function StopDestroyedEffect ( timeDelta : float , id : int)
	{
		StopEffect ( destroyedEffectName );
	}
	
	private timer function ApplyDestroyAppearance ( timeDelta : float , id : int)
	{
		ApplyAppearance( currentAppearance );
		PlayEffect(destroyedEffectName);//, this );
		StopEffect ( destroyingEffectName );
		AddTimer ( 'StopDestroyedEffect', destroyedEffectsTimeout, , , , true );
		SetDestroyed(true);
	}
	
	event OnClueDetected()
	{
		if (igniteOnInteraction) this.GetComponent("Burn").SetEnabled(true);
		super.OnClueDetected();
	}
	
	private function StartDestroyed(destroyed : bool)
	{
		isDestroyed = destroyed;
		clueActionArray.Clear();
		clueActionArray.PushBack(CO_Disable);
		this.OnManageClue(clueActionArray);
	}
	
	private function SetDestroyed(destroyed : bool)
	{
		clueActionArray.Clear();
		clueActionArray.PushBack(clueActionWhenDestroyed);
		this.OnManageClue(clueActionArray);
	}
	
	
	
	
}

/*class CSignReactiveComponent extends CSelfUpdatingComponent
{
	editable var igni 						: bool;
	editable var aard 						: bool;
	
	editable var destroyingTimeout			: float; default destroyingTimeout = 5;
	editable var destroyedEffectsTimeout	: float; default destroyedEffectsTimeout = 10;
	
	editable var destroyingEffectName		: name; default destroyingEffectName = 'destroy';
	editable var destroyedEffectName		: name; default destroyedEffectName = 'destroyed';
	
	private saved var isDestroyed			: bool;
	
	private saved var currentAppearance 	: string;   default currentAppearance = "default";
	
	private var owner 						: CEntity;
	private var applyDestroyingEffect		: bool; default applyDestroyingEffect = false;
	private var stopDestroyingEffect		: bool; default stopDestroyingEffect = false;
	
	private var counter						: float;		
	
	private var factOnSignCast 				: string;
	
	
	
	
	event OnComponentAttachFinished()
	{
		owner = GetEntity();
		owner.ApplyAppearance( currentAppearance );
		StopTicking();
		
		factOnSignCast = owner.GetTagsString() + "_signReactiveObjectDestroyed";
	}
	event OnComponentTick ( _Dt : float )
	{
		Update ( _Dt );
	}
	event OnIgniHit( )
	{
		if ( igni && !isDestroyed  )
		{
			StartTicking();
			isDestroyed = true;
			currentAppearance = "destroyed";
			owner.PlayEffect('destroy', owner );
			applyDestroyingEffect = true;
			counter = 0;
		}
	}
	
	event OnAardHit( )
	{
		if ( aard && !isDestroyed )
		{
			StartTicking();
			isDestroyed = true;
			currentAppearance = "destroyed";
			owner.PlayEffect('destroy', owner );
			applyDestroyingEffect = true;
			counter = 0;
		}
	}
	
	private function Update ( _Dt : float )
	{
		if ( applyDestroyingEffect )
		{
			counter += _Dt;
			
			if ( counter >= destroyingTimeout )
			{
				ApplyDestroyAppearance();
			}
		}
		if ( stopDestroyingEffect )
		{
			counter += _Dt;
			
			if ( counter >= destroyedEffectsTimeout )
			{
				StopDestroyedEffect ( );
			}
		}
	}
	private function StopDestroyedEffect ( )
	{
		stopDestroyingEffect = true;
		counter = 0;
		owner.StopEffect ( 'destroyed' );
		StopTicking();
	}
	
	private  function ApplyDestroyAppearance ( )
	{
		applyDestroyingEffect = false;
		counter = 0;
		stopDestroyingEffect = true;
		
		owner.ApplyAppearance( currentAppearance );
		owner.PlayEffect('destroyed', this );
		owner.StopEffect ( 'destroy' );
		if ( factOnSignCast != "" )
		{
			FactsAdd( factOnSignCast, 1, -1 );
		}
	}
	
	
}*/