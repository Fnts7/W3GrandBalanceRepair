/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Tomek Kozera
/***********************************************************************/

//An entity that can be locked by key e.g. door or container
import abstract class W3LockableEntity extends CGameplayEntity
{	
	protected editable saved var keyItemName 		: name;			//name of the key that unlocks the container (if none then not locked at all)
	protected editable saved var removeKeyOnUse 	: bool;			//if true then if entity is locked with key the key will be auto-taken from player on unlock
	private editable var enabledByFact 			: string;		//if set then entity is not enabled as long as fact does not exist
	private editable var factOnLockedAttempt 	: string;		//fact added when we try to open entity locked by key or fact and we don't have the key
	private editable var factOnUnlockedByKey 	: string;

	import protected editable var isEnabledOnSpawn 	: bool;
	import editable saved var lockedByKey : bool;							//internal var to hold info if the container is locked or not	
	
	protected optional autobind mainInteractionComponent : CDoorComponent = single;
	
	protected saved var isEnabled : bool;	
	protected var isPlayerInActivationRange : bool;
	protected var isInteractionBlocked : bool;								//when set to true all interactions are skipped but visible
	
	hint enabledByFact="If set then container will not be usable if fact does not exist";
	hint factOnLockedAttempt="Fact added when we try to use interaction on entity locked by key or fact when we don't have the key or fact does not exist";
	
	default lockedByKey 			= false;
	default removeKeyOnUse 			= true;
	default isEnabledOnSpawn 		= true;
	default isInteractionBlocked 	= false;
	default factOnUnlockedByKey 	= "";
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		super.OnSpawned(spawnData);
		
		//on actual init
		if(!spawnData.restored)
		{
			//if uses fact enabling
			if(StrLen(enabledByFact) > 0)
				isEnabled = FactsDoesExist(enabledByFact);
			else
				isEnabled = isEnabledOnSpawn;
		}
						
		Enable(isEnabled);
		CheckLock();
	}
	
	//Updates locked/unlock/loot interaction components
	public function UpdateComponents(newActiveComponentName : string)
	{
		var component : CComponent;
		var statee : bool;
		
		//locked state
		component = GetComponent("Locked");
		if(component)
		{
			statee = (newActiveComponentName == "Locked");
			component.SetEnabled(statee);
		}
		else if( lockedByKey )//&& IsNameValid(keyItemName))
		{
			LogAssert(false, "W3LockableEntity.UpdateInteractionComponents: Entity <<" + this + ">> is locked but has no Locked interaction component!");
			LogLockable("W3LockableEntity.UpdateInteractionComponents: Entity <<" + this + ">> is locked but has no Locked interaction component!");
		}
		
		//able to unlock state
		component = GetComponent("Unlock");
		if(component)
		{
			statee = (newActiveComponentName == "Unlock");
			component.SetEnabled(statee);
		}
		/*else if(IsNameValid(keyItemName))
		{
			LogAssert(false, "W3LockableEntity.UpdateInteractionComponents: Entity <<" + this + ">> is able to be unlocked but has no Unlock interaction component!");
			LogLockable("W3LockableEntity.UpdateInteractionComponents: Entity <<" + this + ">> is able to be unlocked but has no Unlock interaction component!");
		}*/
		
		//unlocked state
		statee = ( newActiveComponentName == "Main" );

		OnStateChange( statee );
	}
	
	event OnStateChange( newState : bool )
	{
		if( mainInteractionComponent )
		{
			mainInteractionComponent.SetEnabled( newState );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator != thePlayer || isInteractionBlocked)
			return false;
					
		// Check for key
		if(lockedByKey)
		{
			if( !IsNameValid(keyItemName) )
			{
				GetWitcherPlayer().DisplayHudMessage("panel_hud_message_just_locked"); //#B
				
				if ( factOnLockedAttempt != "" )
				{
					FactsAdd(factOnLockedAttempt, 1, 1);
				}
				return true;
			}
			
			if(!thePlayer.inv.HasItem(keyItemName))
			{
				GetWitcherPlayer().DisplayHudMessage("panel_hud_message_locked"); //#B
				
				if ( factOnLockedAttempt != "" )
				{
					FactsAdd(factOnLockedAttempt, 1, 1);
				}
				return true;
			} 
			else
			{	
				if( factOnUnlockedByKey != "" )
				{
					FactsAdd(factOnUnlockedByKey, 1 );
				}
				GetWitcherPlayer().DisplayHudMessage("panel_hud_message_unlock"); //#B
				Unlock();
				return true;
			}
		}
		
		return false;
	}
	
	public function IsLocked() : bool
	{
		return lockedByKey;
	}
	
	public function ToggleLock()
	{
		if ( IsLocked() )
		{
			Unlock();
		}
		else
		{
			Lock( 'anykey' );
		}
	}
		
	public function Unlock()
	{		
		if( IsNameValid(keyItemName) && removeKeyOnUse )
		{
			thePlayer.inv.RemoveItemByName( keyItemName, 1 );
		}
		UpdateComponents("Main");
		lockedByKey = false;
		
		PlayUnlockAudio();
	}
	
	private function PlayUnlockAudio()
	{
		if( (W3Door)this || (W3NewDoor)this )
		{
			SoundEvent( "global_doors_wooden_unlock" );
		}
	}
	
	public function Lock(keyName : name, optional removeKey : bool, optional smoooth : bool)
	{		
		var mainAsDoors : CDoorComponent;
		mainAsDoors = ( CDoorComponent ) GetComponentByClassName( 'CDoorComponent' );
		
		if( mainAsDoors )
		{
			if( smoooth )
			{
				mainAsDoors.Close( true );
			}
			else
			{
				mainAsDoors.InstantClose();
			}
		}
		OnLock();
		
		removeKeyOnUse = removeKey;
		lockedByKey = true;
		keyItemName = keyName;
		UpdateComponents("Locked");
	}
	
	protected function OnLock()
	{
	}
	
	protected function CheckLock()
	{
		if( lockedByKey )
		{
			Lock( keyItemName, removeKeyOnUse );
		}
	}
	
	public function Enable(e : bool, optional skipInteractionUpdate : bool, optional questForcedEnable : bool)
	{
		isEnabled = e;
		if(e)
		{
			if( lockedByKey )
			{
				if( mainInteractionComponent )
				{
					mainInteractionComponent.InstantClose();
				}
				UpdateComponents("Locked");
			}
			else
			{
				UpdateComponents("Main");	//enable the components to force a proper OnInteractionActivated call
			}
		}
		else
			UpdateComponents("");
			
		if(isPlayerInActivationRange && !skipInteractionUpdate)
			ShowInteractionComponent();	//then set the proper interaction type
	}
	
	//choose and show proper interaction
	public function ShowInteractionComponent()
	{				
		if(isEnabled)
		{
			if(lockedByKey)
			{
				if( IsNameValid(keyItemName) && thePlayer.inv.HasItem(keyItemName))
				{
					UpdateComponents("Unlock");
				}
				else
				{
					UpdateComponents("Locked");
					thePlayer.nearbyLockedContainersNoKey.PushBack(this);
				}
			}
			else
			{
				UpdateComponents("Main");
			}
		}
		else
		{
			UpdateComponents("");
		}		
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if(activator == thePlayer)
			isPlayerInActivationRange = true;
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{		
		if(activator == thePlayer)
		{
			isPlayerInActivationRange = false;
			thePlayer.nearbyLockedContainersNoKey.Remove(this);	
		}		
	}
	
	event OnAreaEnter(area : CTriggerAreaComponent, activator : CComponent)
	{
		//add a timer that will make continuous checks for fact change for as long as the player is in trigger area
		if(StrLen(enabledByFact) > 0 && activator.GetEntity() == thePlayer) // #B check here if this work with replacers
			AddTimer('RefreshFactStatus', 0.001, true, , , true);
	}
	
	event OnAreaExit(area : CTriggerAreaComponent, activator : CComponent)
	{
		if(StrLen(enabledByFact) > 0 && activator.GetEntity() == thePlayer) // #B check here if this work with replacers
			RemoveTimer('RefreshFactStatus');
	}
		
	timer function RefreshFactStatus(dt : float, id : int)
	{
		//if fact status has changed...
		if(isEnabled != FactsDoesExist(enabledByFact))
		{
			LogLockable("W3LockableEntity.RefreshFactStatus: enabling fact status is different than the enabled state of <<" + this + ">>, changing enabled state to " + (!isEnabled));
			Enable(!isEnabled);
		}
	}
	
	event OnStreamIn()
	{
		Enable(isEnabled);		
	}
	
	event OnLockForced()
	{
		Unlock();
	}
	
	public function GetKeyName() : name					{return keyItemName;}
	public function IsEnabled() : bool					{return isEnabled;}
	public function SetInteractionBlocked(b : bool)		{isInteractionBlocked = b;}
}