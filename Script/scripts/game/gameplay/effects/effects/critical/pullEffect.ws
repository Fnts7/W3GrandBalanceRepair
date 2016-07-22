/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Patryk Fiutowski, Tomek Kozera
/***********************************************************************/

class W3Effect_Pull extends W3ImmobilizeEffect
{
	default effectType = EET_Pull;
	default resistStat = CDS_None;
	default criticalStateType = ECST_Pull;
	default isDestroyedOnInterrupt = true;
	default postponeHandling = ECH_Abort;
	default airHandling = ECH_Abort;	
	default usesFullBodyAnim			= true;
	
	private var movementAdjustor	: CMovementAdjustor;	
	private var ticket 				: SMovementAdjustmentRequestTicket;
	
	public function CacheSettings()
	{
		super.CacheSettings();
				
		blockedActions.PushBack(EIAB_Dodge);
		blockedActions.PushBack(EIAB_Roll);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var player : CR4Player = thePlayer;
		var headingVector		: Vector;
		
		super.OnEffectAdded(customParams);
		
		target.PlayEffectSingle('web');
		
		if ( this.isOnPlayer )
		{
			//block player input
			//theInput.Supp
			//rotate the player
			//pull the player to owner
			
			//theInput.SuppressSendingEvents(true);
			
			if(GetCreator())
				headingVector = GetCreator().GetWorldPosition() - target.GetWorldPosition();
			else
				headingVector = target.GetHeadingVector();
			
			movementAdjustor = target.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			ticket = movementAdjustor.CreateNewRequest( 'EffectPull' );
			movementAdjustor.Continuous( ticket );
			movementAdjustor.ReplaceRotation( ticket );
			movementAdjustor.RotateTo( ticket, VecHeading(headingVector) );
			movementAdjustor.RotateTowards(ticket, GetCreator());
			movementAdjustor.MaxRotationAdjustmentSpeed( ticket, 2160 );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 5 );
			movementAdjustor.KeepActiveFor( ticket, this.duration );
			movementAdjustor.SlideTowards(ticket,GetCreator(),2,3);
			movementAdjustor.NotifyScript(ticket,this,'OnSlideFinish',MAN_LocationAdjustmentReachedDestination);
		}
	}
	
	event OnEffectRemoved()
	{
		target.StopEffect('web');
		
		//if ( isOnPlayer )
		//	theInput.SuppressSendingEvents(false);
			
		target.SetBehaviorVariable( 'bCriticalStopped', 1 );
		
		movementAdjustor.Cancel( ticket );
		
		super.OnEffectRemoved();
	}
	
	event OnSlideFinish( requestName : CName, notify : EMovementAdjustmentNotify )
	{
		var actor : CActor;
		
		actor = (CActor)GetCreator();
		if(actor)
			actor.SignalGameplayEvent('SlideFinish');
			
		timeLeft = 0;
		//timeLeft = 0.4f;
	}	
}

class W3Effect_Tangled extends W3ImmobilizeEffect
{
	default effectType = EET_Tangled;
	default resistStat = CDS_None;
	default criticalStateType = ECST_Pull;
	default isDestroyedOnInterrupt = true;
	default postponeHandling = ECH_Abort;
	default airHandling = ECH_Abort;	
	default usesFullBodyAnim			= true;
	
	private var particleEnt : W3VisualFx;

	public function CacheSettings()
	{
		super.CacheSettings();
		blockedActions.Remove(EIAB_RunAndSprint);
		blockedActions.Remove(EIAB_Parry);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		var torsoBoneIndex : int;
		var boneMatrix	: Matrix;
		var effectEntityTemplate : CEntityTemplate;
		var pos : Vector;
		var rot  : EulerAngles;
	
		super.OnEffectAdded(customParams);
		
		//target.PlayEffectSingle('web');
	
		if ( ((CR4Player)target).IsUsingHorse() )
			target.PlayEffectSingle('black_spider_web_break');
		else
			target.PlayEffectSingle('black_spider_web');
		
		theInput.ForceDeactivateAction('CastSignHold');
		
		/*effectEntityTemplate = (CEntityTemplate) LoadResource( "tangled_effect" );
		torsoBoneIndex = target.GetBoneIndex( 'torso2' );
		
		if ( torsoBoneIndex > 0 )
		{
			boneMatrix = target.GetBoneWorldMatrixByIndex( torsoBoneIndex );
			pos = MatrixGetTranslation(boneMatrix);
			rot = MatrixGetRotation(boneMatrix);
			particleEnt = (W3VisualFx)theGame.CreateEntity( effectEntityTemplate, pos, rot );
			particleEnt.CreateAttachmentAtBoneWS( target, 'torso2', pos, rot  );
		}
		else
		{
			particleEnt = (W3VisualFx)theGame.CreateEntity( effectEntityTemplate, target.GetWorldPosition() , target.GetWorldRotation() );
			particleEnt.CreateAttachment( target );		
		}*/
	}
	
	event OnEffectRemoved()
	{
		if ( target.IsEffectActive( 'black_spider_web' ) )
		{
			target.StopEffect('black_spider_web');
			target.PlayEffectSingle('black_spider_web_break');
		}					
					
		target.SetBehaviorVariable( 'bCriticalStopped', 1 );

		super.OnEffectRemoved();
	}
}
