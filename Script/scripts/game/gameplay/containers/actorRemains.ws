/***********************************************************************/
/** Copyright © 2013 CDProjektRed
/** Author : Tomasz Kozera
/***********************************************************************/

class W3ActorRemains extends W3AnimatedContainer
{
	editable var dismemberOnLoot						: bool;
	editable var dismembermentOnlyWhenLootingTrophy 	: bool; default dismembermentOnlyWhenLootingTrophy = true;
	editable var dismembermentType						: EDismembermentWoundTypes; default dismembermentType = DWT_Head;
	editable var dismembermentName						: name;
	editable var manualTrophyTransfer					: bool;
	
	private var owner 				 	: CActor;
	private var hasTrophy 		 		: bool;
	private saved var wasDismembered 	: bool;
	private saved var trophyItemNames	: array <name>;

	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		var commonMapManager : CCommonMapManager;

		super.OnSpawned( spawnData );
		
		if ( spawnData.restored )		
		{
			if ( HasQuestItem() )
			{
				commonMapManager = theGame.GetCommonMapManager();
				commonMapManager.AddQuestLootContainer( this );
			}
		}
	}
	/*
		Called by dynamic container to start a timer that will remove this object after some time.
		The weaponsDroppedOnGround array holds weapons dropped on ground by the actor. If any of
		those weapons is looted from this container then we need to delete the entities from the level
	*/
	public function LootDropped(optional own : CActor)
	{
		owner = own;
		
		if(!HasQuestItem())
			AddTimer( 'LootTimeout', theGame.params.CONTAINER_DYNAMIC_DESTROY_TIMEOUT );
	}
	
	public final function GetOwner() : CActor
	{
		return owner;
	}
	
	/*
		When an item got transfered we check if it's in the array of dropped items, if so we need to
		destroy the entity and remove it from the array
	*/
	event OnItemGiven(data : SItemChangedData)
	{
		
		super.OnItemGiven(data);
		
		if ( inv.IsItemTrophy ( data.ids[0] ) )
		{
			hasTrophy = true;
		}
		// removing from the world previously dropped item
		if(owner)
			owner.RemoveDroppedItem( GetInventory().GetItemName( data.ids[0] ), true );
	}
	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		var itemName : name;
		
		super.OnItemTaken(itemId, quantity);
		
		if ( inv.IsItemTrophy ( itemId ) )
		{
			itemName = inv.GetItemName ( itemId );
		
			trophyItemNames.PushBack ( itemName );
		}
		if(!HasQuestItem())
			StopEffect('quest_highlight_fx');
	}
	
	public function OnContainerClosed()
	{
		
		if(!HasQuestItem())
		StopEffect('quest_highlight_fx');	
			
		if ( CanDismember() && owner )
		{
			theGame.FadeOutAsync(1);
			wasDismembered = true;
			AddTimer( 'ProcessDismembermentTimer', 2, false );
		}
		else
		{
			if ( isPlayingInteractionAnim )
			{
				thePlayer.PlayerStopAction( interactionAnim );	
			}
			
			//In case no dismemberment happening trophy should be transferred.
			manualTrophyTransfer = false;
			
			FinalizeLooting ();
		}
		
	}
		
	function HasTrophyItems ( )  : bool
	{
		var trophyIds : array <SItemUniqueId>;
		
		trophyIds = inv.GetItemsByCategory( 'trophy' );
		
		if ( trophyIds.Size() > 0 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function CanDismember () : bool
	{
		if ( wasDismembered )
		{
			return false;
		}
		if ( dismemberOnLoot )
		{
			if ( !dismembermentOnlyWhenLootingTrophy )
			{
				return true;
			}
			else if ( dismembermentOnlyWhenLootingTrophy && hasTrophy && !HasTrophyItems() )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	
	function FinalizeLooting ()
	{
		var i : int;
		var commonMapManager : CCommonMapManager;
		var trophyIds : array <SItemUniqueId>;
		var eqId	  : SItemUniqueId;
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		
		if( !manualTrophyTransfer || !owner )
		{
			if(witcher)
			{
				for ( i=0; i < trophyItemNames.Size (); i+=1 )
				{
					trophyIds = witcher.inv.GetItemsByName( trophyItemNames[i] );
					
					//Right now we want to transfer all trophies
					//if ( witcher.inv.ItemHasTag ( trophyIds[0], 'HorseTrophy' ) )
					//{
						eqId = witcher.GetHorseManager().MoveItemToHorse(trophyIds[0]);
						witcher.GetHorseManager().EquipItem(eqId);
					//}
				}
				
				trophyItemNames.Clear();
			}
		}
		
		if(IsEmpty())
		{
			commonMapManager = theGame.GetCommonMapManager();
			commonMapManager.DeleteQuestLootContainer( this );
			UnhighlightEntity();
			Enable(false);
			Destroy();
		}
	}
	
	function ProcessDismemberment ()
	{
		if ( owner )
		{
			if ( dismembermentName == '' )
			{
				dismembermentName = owner.GetWoundNameFromWoundType ( dismembermentType );
			}
			owner.SetDismembermentInfo( dismembermentName, owner.GetWorldPosition() - thePlayer.GetWorldPosition(), true );
			owner.AddTimer( 'DelayedDismemberTimer', 0.05f );
		}
		
		if ( isPlayingInteractionAnim )
		{
			thePlayer.PlayerStopAction( interactionAnim );	
		}
		
		if( manualTrophyTransfer )
		{
			AddTimer( 'EndAnimationTimer', 2.1f, false );
		}
		else
		{
			AddTimer( 'FadeInTimer', 1.0f, false );
		}
		
	}
	
	timer function ProcessDismembermentTimer ( timeDelta : float, id : int )
	{
		ProcessDismemberment ();
	}
	
	timer function FadeInTimer ( timeDelta : float, id : int )
	{
		theGame.FadeInAsync(1);
		AddTimer( 'EndAnimationTimer', 1.1f, false );
	}
	
	timer function EndAnimationTimer( timeDelta : float, id : int )
	{
		FinalizeLooting ();
	}
	
	// If player is not near then we delete this (dynamic) container. Otherwise we reset the timer.
	timer function LootTimeout( td: float , id : int)
	{
		if ( VecDistance( GetWorldPosition(), thePlayer.GetWorldPosition() ) < 25.0f )
			AddTimer( 'LootTimeout', theGame.params.CONTAINER_DYNAMIC_DESTROY_TIMEOUT );
		else
			Destroy();
	}
	
	event OnFocusModeEnabled( enabled : bool )
	{
		if ( enabled && CanShowFocusInteractionIcon() )
		{
			PlayEffect( 'remains_highlight' );
		}
		else
		{
			StopEffect( 'remains_highlight' );
		}
	}	
}