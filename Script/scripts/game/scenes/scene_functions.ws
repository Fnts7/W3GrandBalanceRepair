storyscene function SoundEventScene(player: CStoryScenePlayer, eventName : string, saveBehavior : ESoundEventSaveBehavior )
{
	theSound.SoundEvent( eventName );
	switch( saveBehavior )
	{
		case SESB_Save:
			theSound.SoundEventAddToSave( eventName );
			break;
		case SESB_ClearSaved:
			theSound.SoundEventClearSaved();
			break;
	}
}

//Remove unwanted hair that Geralt might have, this should be put at the start of a barber scene as failsafe
storyscene function BarberSetupScene( player: CStoryScenePlayer )
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;
	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			if( !inv.IsItemMounted( ids[i] ) )
				inv.RemoveItem(ids[i], 1);	
		}
		
	}
	
}

//Function for letting music play in background of USM videos
storyscene function SetFinalboardQuest( player: CStoryScenePlayer, isFinalboard: bool )
{
	player.SetFinalboardQuest( isFinalboard );
}

//Cleans up all hair items from player's inventory and applies new by given tag
latent storyscene function SetGeraltHair( player: CStoryScenePlayer, hairstyleName : name )
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;
	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			inv.RemoveItem(ids[i], 1);	
		}
		
	}
	
//	ids.Clear();
	
	ids = inv.AddAnItem( hairstyleName );

	inv.MountItem(ids[0]);
	
	Sleep(1.0f);
}


struct shopQuestItemDef
{ 	
	editable var itemName       : name;
	editable var requiredFact	: string;
	editable var forbiddenFact	: string;
	editable var quantity	    : int;

	default quantity = 1;
}

//Adds quest items to the shop if conditions are met
latent storyscene function ShopQuestItemManager ( player: CStoryScenePlayer, merchantTag : name, questItems : array < shopQuestItemDef > )
{
	var merchant : CNewNPC; 
	var inv		 : CInventoryComponent;
	var size 	 : int;
	var i 		 : int;
	
	merchant = (CNewNPC) theGame.GetEntityByTag( merchantTag ) ;
	inv = merchant.GetInventory();
	
	size = questItems.Size();
	
	for(i=0; i < size; i += 1)
	{
		
		if( (FactsQuerySum( questItems[i].requiredFact) >= 1 || questItems[i].requiredFact == "" ) && FactsQuerySum( questItems[i].forbiddenFact ) == 0 )
		{
			if(inv.GetItemQuantityByName( questItems[i].itemName ) == 0 )
			{
				inv.AddAnItem(questItems[i].itemName, questItems[i].quantity);
			}
		}
		else
		{
			if(inv.GetItemQuantityByName( questItems[i].itemName ) != 0 )
			{
				inv.RemoveItemByName(questItems[i].itemName, inv.GetItemQuantityByName( questItems[i].itemName ) );
			}
			
		}
		
	}
	
	Sleep(0.2f);
	
}

// #Y Block other panels ?
latent function OpenInventoryForScene( containerNPC : CGameplayEntity, filterTags : array<name> )
{
	var initDataObject:W3InventoryInitData = new W3InventoryInitData in theGame.GetGuiManager();
	initDataObject.containerNPC = containerNPC;
	initDataObject.filterTagsList = filterTags;
	initDataObject.setDefaultState('CharacterInventory');
	OpenGUIPanelForScene('InventoryMenu', 'CommonMenu', containerNPC, initDataObject);
}

// Funkcja wlaczajaca interaction Talk

latent function OpenGUIPanelForScene( menu : name, backgroundMenu : name , shopOwner : CGameplayEntity, optional menuInitData : W3MenuInitData )
{
	var panelName : name;
	theGame.GetGuiManager().SetLastOpenedCommonMenuName( 'None' ); 
	if (menuInitData)
	{
		theGame.RequestMenuWithBackground( menu, backgroundMenu, menuInitData );
	}
	else
	{
		theGame.RequestMenuWithBackground( menu, backgroundMenu, shopOwner );
	}
	
	panelName = theGame.GetGuiManager().GetLastOpenedCommonMenuName();
	while( panelName == 'None' ) 
    { 
		SleepOneFrame();
		panelName = theGame.GetGuiManager().GetLastOpenedCommonMenuName();
    }     
}

storyscene function EnableTalkComponent ( player: CStoryScenePlayer, shouldBeEnabled : bool, actorTag : name )
{
	var object	: CActor;
	var component : CComponent;
	
	object = theGame.GetActorByTag( actorTag );
	component = object.GetComponent ( "Talk" );
	component.SetEnabled( shouldBeEnabled );
}

// Funckja odpalajaca panel rzemieslnictwa
latent storyscene function ShowCraftingPanel( player: CStoryScenePlayer, crafterTag : CName )
{
	var initDataObject:W3InventoryInitData = new W3InventoryInitData in theGame.GetGuiManager();
	var crafterEntity : W3MerchantNPC;
	crafterEntity = (W3MerchantNPC)theGame.GetNPCByTag( crafterTag );
	crafterEntity.SetCraftingEnabled( true );
	initDataObject.containerNPC = crafterEntity;
	OpenGUIPanelForScene( 'CraftingMenu', 'CommonMenu', crafterEntity, initDataObject);
}

// Funckja odpalajaca panel rzemieslnictwa
latent storyscene function ShowEnchanterPanel( player: CStoryScenePlayer, enchanterTag : CName )
{
	var initDataObject:W3InventoryInitData = new W3InventoryInitData in theGame.GetGuiManager();
	var enchanterEntity : W3MerchantNPC;
	enchanterEntity = (W3MerchantNPC)theGame.GetNPCByTag( enchanterTag );
	enchanterEntity.SetCraftingEnabled( true );
	initDataObject.containerNPC = enchanterEntity;
	OpenGUIPanelForScene( 'EnchantingMenu', 'CommonMenu', enchanterEntity, initDataObject);
}

// funkcja do wlaczania sklepu z linii dialogowej 
latent storyscene function ShowMeGoods( player: CStoryScenePlayer, merchantTag : CName )
{
	var initDataObject : W3InventoryInitData = new W3InventoryInitData in theGame.GetGuiManager();
	var shopOwner : CNewNPC;
	var merchants : array<CActor>;
	var i : int;
	var shopInventory : CInventoryComponent;
	
	if ( merchantTag == ''  )
	{
	    return;
	}
	
	//Firstly search for a merchant close to us
	merchants = GetActorsInRange(thePlayer, 2.0f, 100000, '', true);

	for(i=0; i < merchants.Size(); i+= 1 )
	{
		if( merchants[i].HasTag( merchantTag ) )
		{
			shopOwner = (CNewNPC) merchants[i];
			break;
		}	
		
	}
	
	//If no merchant close just search for any merchant with that tag
	if ( !shopOwner )
	{
		shopOwner = theGame.GetNPCByTag( merchantTag );
		
		if( !shopOwner )
			return;
		
	}
	
	if( !shopOwner.HasTag('Merchant' ) ) // #Y TODO: Refact
	{
		shopOwner.AddTag('Merchant');
	}
	
	shopInventory = shopOwner.GetInventory();
	if( shopInventory )
	{
		shopInventory.AutoBalanaceItemsWithPlayerLevel();
	}
		
	initDataObject.containerNPC = (CGameplayEntity)shopOwner;
	OpenGUIPanelForScene( 'InventoryMenu', 'CommonMenu', shopOwner, initDataObject );
	//@FIXME TOMEK CZARNY - IT DOESN'T QUIT
}


/* THIS FUNCTION SHOULD NEVER BE USED, WE DON'T HAVE REPAIR AS SEPERATE CHOICE FOR MERCHANTS
latent storyscene function RepairForMe( player: CStoryScenePlayer, repairTag : CName, armorer : bool, blacksmith : bool, masteryLevel : int )
{
	var initDataObject : W3InventoryInitData = new W3InventoryInitData in theGame.GetGuiManager();
	var repairNpc : CNewNPC;
	
	if ( repairTag == ''  )
	{
	    return;
	}
	repairNpc = (CNewNPC)theGame.GetNPCByTag( repairTag );
	if ( !repairNpc )
	{
		return;
	}
	
	if ( armorer )
	{
		repairNpc.AddTag('Armorer');
	}	
	if ( blacksmith )
	{
		repairNpc.AddTag('Blacksmith');
	}	
	
	switch( masteryLevel )
	{
		case 1:
			repairNpc.AddTag('Apprentice');
			break;
		case 2:
			repairNpc.AddTag('Specialist');
			break;
		case 3:
		case 4:
		case 5:
			repairNpc.AddTag('Master');
			break;
	}
	
	theGame.GetGuiManager().SetLastOpenedCommonMenuName( 'None' ); 			
	
	initDataObject.containerNPC = (CGameplayEntity)repairNpc;
	OpenGUIPanelForScene( 'BlacksmithParent', 'CommonMenu', repairNpc, initDataObject ); //@FIXME TOMEK CZARNY - IT DOESN'T QUIT
}
*/

// #B function for opening containers from dialog lines
latent storyscene function OpenContainer( player: CStoryScenePlayer, npcTag : CName, optional tagsFilter : array<name> )
{
	var containerOwner    : CGameplayEntity;
	
	if ( npcTag == ''  )
	{
		return;
	}
	containerOwner = (CGameplayEntity)theGame.GetEntityByTag( npcTag );
	if ( !containerOwner )
	{
		return;
	}
	
	OpenInventoryForScene(containerOwner, tagsFilter);
	//OpenGUIPanelForScene( 'InventoryMenu', 'CommonMenu', containerOwner ); //@FIXME TOMEK CZARNY - IT DOESN'T QUIT
}

enum ENegotiationResult
{
	TooMuch,
	PrettyClose,
	WeHaveDeal,
	GetLost
};

// #B
storyscene function SetRewardModifierScene( player: CStoryScenePlayer, rewardName : name, modifer : float, onlyIfDoesntExist : bool, multiply : bool, notBaseMonsterHuntReward : bool   ) : void
{
	if( onlyIfDoesntExist == true )
	{
		if( thePlayer.GetRewardMultiplierExists(rewardName) == false )
		{	
			if( !notBaseMonsterHuntReward )
			{
				thePlayer.SetRewardMultiplier(rewardName, 0.75f);
			}
			else
			{
				thePlayer.SetRewardMultiplier(rewardName, modifer);
			}
		}
	}
	else
	{
		if( multiply )
		{
			thePlayer.SetRewardMultiplier(rewardName, thePlayer.GetRewardMultiplier( rewardName ) * modifer );
		}
		else
		{
			thePlayer.SetRewardMultiplier(rewardName, modifer);
		}
	}
}

// #B
storyscene function GiveRewardToPlayer( player: CStoryScenePlayer, rewardName : name ) : void
{
	theGame.GiveReward( rewardName, thePlayer );
}

// #B
latent storyscene function NegotiateMonsterHunt( player: CStoryScenePlayer, rewardName : name, questUniqueScriptTag : CName, alwaysSuccessful : bool, isItemReward : bool ) : ENegotiationResult
{
	var hud : CR4ScriptedHud;
	var dialogueModule : CR4HudModuleDialog;
	var currentReward : SReward;
	var minimalGold : int;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		//minimal value needs to be based on the actual max reward
		theGame.GetReward( rewardName, currentReward );
		minimalGold = currentReward.gold;
		
		dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
		dialogueModule.OpenMonsterHuntNegotiationPopup(rewardName, minimalGold, alwaysSuccessful, isItemReward );
		while( dialogueModule.IsPopupOpened() )
		{
			SleepOneFrame();
		}
		return dialogueModule.GetLastNegotiationResult();
	}
	return GetLost;
}



latent storyscene function NegotiateLowestPriceScene( player: CStoryScenePlayer, controlFact : string, bestBarginModifier : float, lowestPriceModifier : float ) : ENegotiationResult
{
	var hud : CR4ScriptedHud;
	var dialogueModule : CR4HudModuleDialog;
	var currentReward : SReward;
	var minimalGold : int;
	
	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		
		dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
		dialogueModule.OpenLowerPriceNegotiationPopup( controlFact, bestBarginModifier, lowestPriceModifier );
		while( dialogueModule.IsPopupOpened() )
		{
			SleepOneFrame();
		}
		return dialogueModule.GetLastNegotiationResult();
	}
	return GetLost;
}



// #B
latent storyscene function PlaceBet( player: CStoryScenePlayer, rewardName : name, startingBetPercentage : int )
{
	var hud : CR4ScriptedHud;
	var dialogueModule : CR4HudModuleDialog;

	hud = (CR4ScriptedHud)theGame.GetHud();
	if( hud )
	{
		dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
		dialogueModule.OpenBetPopup(rewardName,startingBetPercentage);
		while( dialogueModule.IsPopupOpened() )
		{
			SleepOneFrame();
		}
	}
}

storyscene function StorePlayerItems( player: CStoryScenePlayer, merchantTag : CName, storageTag : CName ) : bool
{
	//theHud.ShowShopNew( theGame.GetNPCByTag( merchantTag ), true, (W2PlayerStorage)theGame.GetEntityByTag( storageTag ) );
	return true;
}

storyscene function AddFact_S( player: CStoryScenePlayer, factName: string, value: int, validFor : int )
{
	if(validFor > 0 )
	{
		FactsAdd( factName, value, validFor );
	}
	else
	{
		FactsAdd( factName, value, -1);
	}
	
	player.DbFactAdded( factName );
}

//MT // Removes fact from facts DB
storyscene function RemoveFact_S( player: CStoryScenePlayer, factId : string )
{
	// Checks if the specified fact is defined in the DB.
	if( FactsDoesExist( factId ) )
	{
		// Removes a single fact from the facts db.
		FactsRemove( factId );
	}
	player.DbFactRemoved( factId );
}

// Shave Geralt
latent storyscene function ShaveGeralt( player: CStoryScenePlayer )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).Shave();
	
	Sleep(1.0f);
}

// Set Geralts beard stage
latent storyscene function SetGeraltBeard( player: CStoryScenePlayer, maxBeard : bool, optional stage : int )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).SetBeardStage( maxBeard, stage);
	
	Sleep(1.0f);
}

// set / remove tattoo
storyscene function SetTattoo( player: CStoryScenePlayer, hasTattoo : bool )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).SetTattoo( hasTattoo );
}

//(un) block beard growing
storyscene function BlockBeardGrowth( player: CStoryScenePlayer, optional block : bool )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).BlockGrowing( block );
}

// set custom head it also block the beard growth
storyscene function SetCustomHead( player: CStoryScenePlayer, head : name, barberSystem : bool )
{
	var acs : array< CComponent >;
	
	if( barberSystem )
	{
		thePlayer.RememberCustomHead( head );
	}
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).SetCustomHead( head );
}

// remove custom head it also block the beard growth
storyscene function RemoveCustomHead( player: CStoryScenePlayer, barberSystem : bool )
{
	var acs : array< CComponent >;
	var barberHead : name;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );

	if(!barberSystem)
	{
		barberHead = thePlayer.GetRememberedCustomHead();
		
		if( IsNameValid(barberHead) )
		{
			( ( CHeadManagerComponent ) acs[0] ).SetCustomHead( barberHead );
		}
		else
		{
			( ( CHeadManagerComponent ) acs[0] ).RemoveCustomHead();
		}
	}
	else
	{
		thePlayer.ClearRememberedCustomHead();
		( ( CHeadManagerComponent ) acs[0] ).RemoveCustomHead();
	}
}

// Adds an item to target NPC or player
storyscene function AddItemOnNPC_S ( player: CStoryScenePlayer, npc: CName, item_name : CName, optional quantity : int, dontInformGUI : bool)
{
	var npc_newnpc : CNewNPC;
	var hud : CR4ScriptedHud;		

	if ( !IsNameValid( item_name ) )
	{
		return;
	}
	if(quantity < 0)
	{
		LogQuest("Scene function AddItemOnNPC_S: quantity of <<" + item_name + ">> must be >=0, aborting!");
		LogAssert(false, "Scene function AddItemOnNPC_S: quantity of <<" + item_name + ">> must be >=0, aborting!");
		return;
	}
	
	quantity = Max(1, quantity);

	if( npc == 'PLAYER')
	{
		if(item_name == 'Orens')
		{
			thePlayer.AddMoney(quantity);
			if( !dontInformGUI )
			{
				hud = (CR4ScriptedHud)theGame.GetHud();
				hud.OnItemRecivedDuringScene('Crowns',quantity); // #B because our default currency are Crowns !!!
			}
			return;
		}
		else
		{
			thePlayer.inv.AddAnItem( item_name, quantity, true );
		}
		if( !dontInformGUI )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			hud.OnItemRecivedDuringScene(item_name, quantity);
		}
	}
	else
	{
		npc_newnpc = theGame.GetNPCByTag(npc);
		
		if(!npc_newnpc)
		{
			LogQuest("Scene function AddItemOnNPC_S: cannot find NPC with tag <<" + npc + ">> for item <<" + item_name + ">>, aborting!");
			LogAssert(false, "Scene function AddItemOnNPC_S: cannot find NPC with tag <<" + npc + ">> for item <<" + item_name + ">>, aborting!");
			return;
		}
		
		if(item_name == 'Orens')
			npc_newnpc.GetInventory().AddMoney(quantity);
		else
			npc_newnpc.GetInventory().AddAnItem( item_name, quantity, dontInformGUI );
	}
}

storyscene function RemoveItemOnNPC_S( player: CStoryScenePlayer, npc: name, item_name : name, item_category : name, item_tag : name, optional quantity : int)
{
	var gameplayEntity	: CGameplayEntity;
	var inv 		: CInventoryComponent;

	if( !IsNameValid( item_name ) &&
	    !IsNameValid( item_category ) &&
	    !IsNameValid( item_tag ) )
	{
		LogQuest( "Quest function <<RemoveItemOnNPC_S>>: no arguments provided, aborting!");
		return;
	}
	/*
	if( quantity < 0 )
	{
		LogQuest( "Quest function <<RemoveItemOnNPC_S>>: quantity of <<" + quantity + ">> is not a valid value, aborting!");
		return;
	}
	*/
	if( npc == 'PLAYER' )
	{
		inv = thePlayer.GetInventory();
	}
	else
	{
		gameplayEntity = (CGameplayEntity)theGame.GetEntityByTag( npc ); //theGame.GetNPCByTag( npc );
		if ( !gameplayEntity )
		{
			LogQuest("Scene function RemoveItemOnNPC_S: cannot find NPC with tag <<" + npc + ">> for item <<" + item_name + ">>, aborting!");
			LogAssert(false, "Scene function RemoveItemOnNPC_S: cannot find NPC with tag <<" + npc + ">> for item <<" + item_name + ">>, aborting!");
			return;
		}
		inv = gameplayEntity.GetInventory();
	}

	if ( inv )
	{
		if ( item_name == 'Orens' )
		{
			inv.RemoveMoney(quantity);
		}
		else
		{
			if ( IsNameValid( item_name ) )
			{
				inv.RemoveItemByName( item_name, quantity );
			}
			else if ( IsNameValid( item_category ) )
			{
				inv.RemoveItemByCategory( item_category, quantity );
			}
			else if ( IsNameValid( item_tag ) )
			{		
				inv.RemoveItemByTag( item_tag, quantity );
			}
		}
	}
	else
	{
		LogQuest("Scene function RemoveItemOnNPC_S: cannot find inventory for NPC with tag <<" + npc + ">> for item <<" + item_name + ">>, aborting!");
	}
}


// Adds an item to target NPC or player
storyscene function EquipItemOnNPC_S( player: CStoryScenePlayer, npc: CName, itemName : CName, optional unequip : bool, optional toHand : bool  )
{
	var target : CActor;
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var i, idx : int;

	if( npc == 'PLAYER')
	{
		target = thePlayer;
	}
	else
	{
		target = theGame.GetNPCByTag(npc);
		
		if(!target)
		{
			LogQuest("Scene function EquipItemOnNPC_S: cannot find NPC with tag <<" + npc + ">> for item <<" + itemName + ">>, aborting!");
			LogAssert(false, "Scene function EquipItemOnNPC_S: cannot find NPC with tag <<" + npc + ">> for item <<" + itemName + ">>, aborting!");
			return;
		}
	}

	inv = target.GetInventory();	
	
	if( inv )
	{
		//find item id
		ids = inv.GetItemsIds(itemName);			
		if(ids.Size() <= 0)			
		{
			LogQuest("EquipItemOnNPC_S: cannot (un)equip item <<" + itemName + ">> on <<" + npc + ">>, target does not have this item");
			return;
		}			
		for(i=0; i<ids.Size(); i+=1)
		{
			if(inv.GetItemName(ids[i]) == itemName)
			{
				idx = i;
				break;
			}
		}
	
		//equip/unequip item
		if(unequip)
		{
			target.UnequipItem(ids[idx]);
		}
		else
		{
			if(toHand && target != thePlayer)
			{
				target.EquipItem(ids[idx], EES_InvalidSlot, true);
			}
			else
			{
				target.EquipItem(ids[idx]);
			}
		}			
	}
	else
	{
		LogQuest("EquipItemOnNPC_S: target actor <<" + target + ">> has no inventory component, cannot equip/unequip items");
	}
}

latent storyscene function OpenWorldMap( player: CStoryScenePlayer ) : bool //#B
{
	return false;
}

storyscene function EnableFastTravelPin( player: CStoryScenePlayer ,pinTag : name, enable : bool )
{
	var manager : CCommonMapManager = theGame.GetCommonMapManager();

	manager.SetEntityMapPinDisabled( pinTag, !enable );
	
	//@FIXME BIDON - Fact database change ?
}

//This method finds all NPCs with given tag and changes their appearance
storyscene function AppearanceChange_scene(player: CStoryScenePlayer, opponentTag : name, appearanceName : name )
{
	AppearanceChange(opponentTag, appearanceName);
}

storyscene function TutorialMessage_scene(player: CStoryScenePlayer, message : STutorialMessage)
{
	TutorialMessage(message);
}

storyscene function TutorialHintHide_scene(player: CStoryScenePlayer, journalEntry : name)
{
	TutorialHintHide(journalEntry);
}

storyscene function DoorManager(player: CStoryScenePlayer, tag : name, newState : EDoorQuestState, optional keyItemName : name, optional removeKeyOnUse : bool)
{
	var nodes : array<CNode>;
	var entity : CEntity;
	var door : W3Door;
	var doorComponent : CDoorComponent;
	var lockableEntity : W3LockableEntity;
	var i : int;
	
	theGame.GetNodesByTag(tag, nodes);
	
	for(i=0; i<nodes.Size(); i+=1)
	{
		// old door system
		// TODO: Remove once transition to the new system is complete
		door = (W3Door)nodes[i];
		if(door)
		{			
			switch(newState)
			{
				case EDQS_Open:
					door.Open();
					break;
				case EDQS_Close:
					door.Close();
					break;
				case EDQS_RemoveLock:
					door.Unlock();
					break;
				case EDQS_Enable:
					door.Enable(true);
					break;
				case EDQS_Disable:
					door.Enable(false);
					break;
				case EDQS_Lock:
					door.Lock(keyItemName, removeKeyOnUse);
					break;
			}
		}
		else
		{
			// new door system
			entity = (CEntity)nodes[i];
			if( !entity )
			{
				continue;
			}
			
			doorComponent = (CDoorComponent)entity.GetComponentByClassName( 'CDoorComponent' );
			if( doorComponent )
			{
				switch(newState)
				{
					case EDQS_Open:
						doorComponent.Open( false, true );
						break;
					case EDQS_Close:
						doorComponent.Close( true );
						break;
					case EDQS_Enable:
						doorComponent.SetEnabled( true );
						break;
					case EDQS_Disable:
						doorComponent.SetEnabled( false );
						break;
					case EDQS_RemoveLock:
					case EDQS_Lock:
						
						lockableEntity = (W3LockableEntity)entity;
						if( lockableEntity )
						{
							if( newState == EDQS_RemoveLock )
							{
								lockableEntity.Unlock();							
							}
							else
							{
								lockableEntity.Lock(keyItemName, removeKeyOnUse);							
							}
						}
						break;
				}			
			}
			else
			{
				LogQuest("DoorChangeState: entity <<" + nodes[i] + ">> is not a door entity!!! Skipping");
			}
		}
	}
}


enum ECollectItemsRes
{
	ItemCollected,
	NothingChanged,
	WrongItem,
	AlreadyRecieved,
	AllItemsCollected
};
latent storyscene function CollectItems ( player: CStoryScenePlayer, collectorTag : name, items : array<name>, uniqueTransactionId : string, keepItemsInContainer : bool, optional filterTagsList : array<name> ) : ECollectItemsRes
{
	var inventory : CInventoryComponent;
	var received, alreadyCollected : bool;
	var factId : string;
	var i, collectedCount : int = 0;	
	var result : ECollectItemsRes = WrongItem;
	var ent : CGameplayEntity;
	var itemsBeforeChange : array<name>;
	var itemsAfterChange : array<name>;
	
	ent = (CGameplayEntity)theGame.GetEntityByTag( collectorTag );
	if( !ent )
	{
		return NothingChanged;
	}
	
	inventory = ent.GetInventory();		
	itemsBeforeChange = inventory.GetItemsNames();
	theGame.GetGuiManager().SetLastOpenedCommonMenuName( 'None' ); 		
	
	//////////////////////////////////////////////////////////////
	//OpenContainer( player, collectorTag ); ////////////////////
	OpenContainer( player, collectorTag, filterTagsList);
	////////////////////////////////////////////////////////////
 
	while( theGame.GetGuiManager().GetLastOpenedCommonMenuName() == 'None' ) 
    { 
		SleepOneFrame();
    }     
    
    itemsAfterChange = inventory.GetItemsNames();
    for( i = itemsAfterChange.Size() - 1; i >= 0 ; i-=1  )
    {
		if( itemsBeforeChange.Contains( itemsAfterChange[ i ] ) )
		{
			itemsAfterChange.Erase( i );
		}
    }
	
	if( itemsAfterChange.Size() == 0 )
	{
		return NothingChanged;
	}

	for( i = 0; i < items.Size(); i+=1  )
	{
		factId = uniqueTransactionId + "_" + items[i];
		received = itemsAfterChange.Contains( items[i] );
		alreadyCollected = FactsQuerySum( factId ) > 0;
		
		if( alreadyCollected )
			collectedCount += 1;
		
		if( received )
		{
			if( !alreadyCollected )
			{				
				FactsAdd( factId );
				if (!keepItemsInContainer)
				{
					inventory.RemoveItemByName( items[i] );
				}
				collectedCount += 1;
				result = ItemCollected;
			}
			else if( result != ItemCollected )		
			{			
				result = AlreadyRecieved;
			}					
		}
	}
	
	if( collectedCount == items.Size() )
	{
		result = AllItemsCollected;
	}
		
	return result;
}



//// for mq2049 Atheist and bringing him books - JR

enum ECollectItemsCustomRes
{
	Book1 = 0,
	Book2 = 1,
	Book3 = 2,
	Book4 = 3,
	Book5 = 4,
	NothingChangedCus = 5,
	WrongItemCus = 6,
	AlreadyRecievedCus = 7,
	AllItemsCollectedCus = 8
};
latent storyscene function CollectItemsCustom ( player: CStoryScenePlayer, collectorTag : name, items : array<name>, uniqueTransactionId : string, keepItemsInContainer : bool, optional filterTagsList : array<name> ) : ECollectItemsCustomRes
{
	var inventory : CInventoryComponent;
	var received, alreadyCollected : bool;
	var factId : string;
	var i, collectedCount : int = 0;	
	var result : ECollectItemsCustomRes = WrongItemCus;
	var ent : CGameplayEntity;
	var itemsBeforeChange : array<name>;
	var itemsAfterChange : array<name>;
	
	ent = (CGameplayEntity)theGame.GetEntityByTag( collectorTag );
	if( !ent )
	{
		return NothingChangedCus;
	}
	
	inventory = ent.GetInventory();		
	itemsBeforeChange = inventory.GetItemsNames();
	
	// fix for TTP 129161:
	// let's remove items that are not considered as "collected" by this quest
	// (facts for them are not added)
	// so that they can be properly "received"
    for ( i = itemsBeforeChange.Size() - 1; i >= 0 ; i-=1 )
    {
		// if this is the item we are interested in
		if( items.Contains( itemsBeforeChange[ i ] ) )
		{
			factId = uniqueTransactionId + "_" + itemsBeforeChange[ i ];
			alreadyCollected = FactsQuerySum( factId ) > 0;		
			if ( !alreadyCollected )
			{
				itemsBeforeChange.Erase( i );
			}
		}
    }	
	
	theGame.GetGuiManager().SetLastOpenedCommonMenuName( 'None' ); 		
	
	//////////////////////////////////////////////////////////////
	//OpenContainer( player, collectorTag ); ////////////////////
	OpenContainer( player, collectorTag, filterTagsList);
	////////////////////////////////////////////////////////////
 
	while( theGame.GetGuiManager().GetLastOpenedCommonMenuName() == 'None' ) 
    { 
		SleepOneFrame();
    }     
    
    itemsAfterChange = inventory.GetItemsNames();
    for( i = itemsAfterChange.Size() - 1; i >= 0 ; i-=1  )
    {
		if( itemsBeforeChange.Contains( itemsAfterChange[ i ] ) )
		{
			itemsAfterChange.Erase( i );
		}
    }
	
	if( itemsAfterChange.Size() == 0 )
	{
		return NothingChangedCus;
	}

	for( i = 0; i < items.Size(); i+=1  )
	{
		factId = uniqueTransactionId + "_" + items[i];
		received = itemsAfterChange.Contains( items[i] );
		alreadyCollected = FactsQuerySum( factId ) > 0;
		
		if( alreadyCollected )
			collectedCount += 1;
		
		if( received )
		{
			if( !alreadyCollected )
			{				
				FactsAdd( factId );
				if (!keepItemsInContainer)
				{
					inventory.RemoveItemByName( items[i] );
				}
				collectedCount += 1;
				result = Min( i, 4 );
			}
			else if( result > 4 )		
			{			
				result = AlreadyRecievedCus;
			}					
		}
	}
	
	if( collectedCount == items.Size() )
	{
		result = AllItemsCollectedCus;
	}
		
	return result;
}

storyscene function TakeMoneyScene( player: CStoryScenePlayer, money : int, dontPlaySound : bool )
{
	var currentMoney : int;
	
	if( money <= 0 )return;
	currentMoney = thePlayer.GetMoney();
	
	if( currentMoney < money )
		thePlayer.RemoveMoney( currentMoney );
	else
		thePlayer.RemoveMoney( money );

	if( !dontPlaySound )
		theSound.SoundEvent("gui_bribe");	

}


storyscene function BankCollectBillOfExchangeScene( player: CStoryScenePlayer, baseBillPrice : int )
{
	var 	   witcher : W3PlayerWitcher;
	var 	   inv     : CInventoryComponent;
	var 	  horseInv : CInventoryComponent;
	var 	billsCount : int;
	
	witcher = GetWitcherPlayer();
	
	inv = witcher.inv;
	horseInv = witcher.GetHorseManager().GetInventoryComponent();
	
	billsCount = inv.GetItemQuantityByName('vivaldis_bill_of_exchange') + horseInv.GetItemQuantityByName('vivaldis_bill_of_exchange');
	
	if( billsCount > 0)
	{
		inv.RemoveItemByName( 'vivaldis_bill_of_exchange', -1);
		witcher.HorseRemoveItemByName( 'vivaldis_bill_of_exchange', -1);
		
		
		thePlayer.DisplayItemRewardNotification('Crowns', (int)( billsCount * baseBillPrice ) );
		inv.AddAnItem( 'Crowns', billsCount * baseBillPrice, true, true );
		
	}
	
}

storyscene function BankCurrencyExchangeScene( player: CStoryScenePlayer, orensExchangeModifier : float, florensExchangeModifier : float )
{
	var 	   witcher : W3PlayerWitcher;
	var 	   inv     : CInventoryComponent;
	var 	  horseInv : CInventoryComponent;
	var 		     i : int;
	var 	  sumValue :  float;

	
	witcher = GetWitcherPlayer();
	inv = witcher.inv;
	horseInv = witcher.GetHorseManager().GetInventoryComponent();
		
	sumValue += inv.GetItemQuantityByName('Orens') * orensExchangeModifier;
	sumValue += inv.GetItemQuantityByName('Florens') * florensExchangeModifier;

	sumValue += horseInv.GetItemQuantityByName('Orens') * orensExchangeModifier;
	sumValue += horseInv.GetItemQuantityByName('Florens') * florensExchangeModifier;
	
	inv.RemoveItemByName( 'Orens', -1);
	inv.RemoveItemByName( 'Florens', -1);
	
	witcher.HorseRemoveItemByName( 'Orens', -1);
	witcher.HorseRemoveItemByName( 'Florens', -1);
	
	if(sumValue < 1.0) sumValue = 1.0;

	thePlayer.DisplayItemRewardNotification('Crowns', (int) sumValue );
	inv.AddAnItem( 'Crowns', (int) sumValue, true, true );
	

}

storyscene function ShowEP2Logo_S( player: CStoryScenePlayer, show : bool, fadeInterval : float, x : int, y : int )
{
	var overlayPopupRef : CR4OverlayPopup;
	
	overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
	if ( overlayPopupRef )
	{
		overlayPopupRef.ShowEP2Logo( show, fadeInterval, x, y );
	}
}
