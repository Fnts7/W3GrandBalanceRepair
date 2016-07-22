class W3SnowballProjectile extends W3AdvancedProjectile
{
	editable var damageTypeName : name;
	editable var initFxName : name;
	editable var onCollisionFxName : name;
	editable var specialFxOnVictimName : name;
	editable var applyDebuffIfNoDmgWasDealt : bool;
	
	//protected var victim : CActor;
	
	hint specialFxOnVictimName = "will be played on collision when applyDebuffIfNoDmgWasDealt is set to true";
	
	event OnProjectileInit()
	{
		//this.PlayEffect( initFxName );
		damageTypeName = theGame.params.DAMAGE_NAME_PIERCING;
		isActive = true;
	}
	
	//FIXME looks very much like W3BoulderProjectile, W3ElementalIfrytProjectile, W3ElementalDaoProjectile, W3StoneProjectile, PoisonProjectile
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var action : W3DamageAction;
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CActor)collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if ( victim && !collidedEntities.Contains(victim) )
		{
			this.StopProjectile();
			this.DestroyAfter(1.f);
			this.SetHideInGame(true);
			this.StopEffect( initFxName );
			this.PlayEffect(onCollisionFxName);
			 
			//dealdmg
			
			action = new W3DamageAction in this;
			action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_AttackPower, false, true, false, false);
			if ( this.projDMG > 0 )
			{
				action.AddDamage(damageTypeName, projDMG );
			}
			action.AddEffectInfo(this.projEfect);
			action.SetCanPlayHitParticle(false);
			action.SetProcessBuffsIfNoDamage(applyDebuffIfNoDmgWasDealt);
			theGame.damageMgr.ProcessAction( action );
			delete action;
			
			//do rest
			if ( applyDebuffIfNoDmgWasDealt )
				victim.PlayEffect(specialFxOnVictimName);
			
			collidedEntities.PushBack(victim);
			isActive = false;
		}
		else if ( !victim )//projectile Hit the ground
		{
			this.StopProjectile();
			this.DestroyAfter(1.f);
			this.SetHideInGame(true);
			this.StopEffect( initFxName );
			this.PlayEffect(onCollisionFxName);
			isActive = false;
		}
		return false;
	}
	
	event OnRangeReached()
	{
		isActive = false;
		this.SetHideInGame(true);
		this.StopEffect( initFxName );
		this.DestroyAfter(1.f);
	}
}