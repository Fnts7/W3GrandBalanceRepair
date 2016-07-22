class W3MonsterElementalArm extends CGameplayEntity
{
	editable var physcialComponent : CComponent;
	
	var victims 	: array< CActor >;
	var victim 		: CActor;
	var isActive	: bool;
	
	var action : W3DamageAction;
	
	var owner : CActor;
	
	private autobind component : CMeshComponent = single;
	
	//bone name k_lforearm_g
	
	//x:48,051 y:-11,691 z:1,362
	
	//characters\models\monsters\elemental\model\a_01__elemental.w2mesh
	
	function SetIsActive( toggle : bool )
	{
		isActive = true;
		
		//set timer here
	}
	
	function SetOwner ( actor : CActor )
	{
		owner = actor;
		AddTimer('ExplodeTimer',5.0, false, , , true );
	}
	
	timer function ExplodeTimer( dt : float , id : int)
	{
		if ( isActive )
		{
			Explode();
		}
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( isActive && activator != (CEntity)owner )
		{
			Explode();
		}
	}
	
	function Explode()
	{
		var i : int;
		
		victims = owner.GetNPCsAndPlayersInRange(5 ,10,'',FLAG_ExcludeTarget + FLAG_OnlyAliveActors + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral);
		//play effect
		
		PlayEffect('explosion');
		
		if( component )
		{
			component.SetVisible(false);
		}
		
		StopEffect('fire_fx');
		
		action = new W3DamageAction in this;
		
		for ( i=0; i < victims.Size() ; i+= 1 )
		{
			action = new W3DamageAction in this;
			action.Initialize(owner,victims[i],NULL,'elemental_arm',EHRT_None,CPS_AttackPower,false,false,false,true);
			action.AddDamage(theGame.params.DAMAGE_NAME_ELEMENTAL,20);		//FIXME URGENT - fixed value -TK
			action.AddEffectInfo(EET_KnockdownTypeApplicator, 2.f );
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		this.DestroyAfter(7);
		
		isActive = false;
		
	}

	event OnContactEvent( position : Vector, force : Vector, otherBody : CComponent, actorIndex : int, shapeIndex : int )
	{
		if ( isActive && otherBody.GetEntity() != (CEntity)owner )
		{
			Explode();
		}
		else if ( isActive && !otherBody )
		{
			Explode();
		}
	}
}