/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2015
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

// Sheep Launcher Manager disguised under obscure name
class CBTTaskReactionToGiantWeaponMonitor extends IBehTreeTask
{
	public var effectResourceName 					: name;
	public var playFxOnEffectEntity 				: name;
	public var spawnZOffset 						: float;
	
	private var effectEntity 						: CEntityTemplate;
	private var victim 								: CActor;
	private var victimsArray 						: array<CActor>;
	private var actorEventReceived 					: bool;
	private var entityPos							: Vector;
	private var entityRot							: EulerAngles;
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		var target 	: CActor;
		var entity 	: CEntity;
		
		
		if ( !effectEntity )
		{
			effectEntity = (CEntityTemplate)LoadResourceAsync( effectResourceName );
		}
		
		if ( effectEntity )
		{
			while ( true )
			{
				if ( actorEventReceived )
				{
					if ( !victimsArray.Contains( victim ) )
					{
						CheckVictimPosition();
						((CActor)victim).Kill( 'CollisionFromGiantWeapon', false, npc );
						((CActor)victim).SetKinematic( false );
						entity = theGame.CreateEntity( effectEntity, entityPos, entityRot );
						victimsArray.PushBack( victim );
						if ( entity )
						{
							if ( IsNameValid( playFxOnEffectEntity ) )
							{
								entity.PlayEffect( playFxOnEffectEntity );
							}
							entity.DestroyAfter( 5.f );
						}
					}
					
					victim = NULL;
					actorEventReceived = false;
				}
				SleepOneFrame();
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		victimsArray.Clear();
	}
	
	final function CheckVictimPosition()
	{
		if ( victim )
		{
			entityPos = victim.GetWorldPosition();
			entityRot = victim.GetWorldRotation();
			entityPos.Z += spawnZOffset;
			
			GetNPC().GetVisualDebug().AddSphere( 'entityPos', 1.0, entityPos, true, Color( 0,0,255 ), 5 );
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'ReactionToGiantWeaponActor' )
		{
			victim = (CActor)GetEventParamObject();
			actorEventReceived = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskReactionToGiantWeaponMonitorDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskReactionToGiantWeaponMonitor';
	
	editable var effectResourceName 					: name;
	editable var playFxOnEffectEntity 					: name;
	editable var spawnZOffset 							: float;
	
	default effectResourceName 							= 'blood_explode';
	default playFxOnEffectEntity 						= 'blood_explode';
	default spawnZOffset 								= 0.5;
};
