statemachine class WeaponHolster
{
	private	saved	var currentMeleeWeapon	: EPlayerWeapon;
	
	protected 		var queuedMeleeWeapon	: EPlayerWeapon;
	protected 		var isQueuedMeleeWeapon	: bool;
	
	protected saved var ownerHandle			: EntityHandle;
	
	public			var automaticUnholster	: bool;			default	automaticUnholster	= true;
	
	protected 		var isMeleeWeaponReady	: bool;
	
	
	//---------------------------------------------------------------------------------------------
	// Declare the events that are in the state
	//---------------------------------------------------------------------------------------------
	event OnEquipMeleeWeapon( weapontype : EPlayerWeapon, ignoreActionLock : bool, optional sheatheIfAlreadyEquipped : bool, optional forceHolster : bool ){}
	
	// Invoked from C++ side when weapon gets instant equipped
	event OnEquippedMeleeWeapon( weapontype : EPlayerWeapon ) {}
	
	event OnWeaponDrawReady(){}
	
	event OnWeaponHolsterReady(){}
	
	event OnHolsterLeftHandItem(){}
	
	//---------------------------------------------------------------------------------------------
	// Interface with other systems
	//---------------------------------------------------------------------------------------------
	public function Initialize( _owner : CActor, restored : bool )
	{
		var item : SItemUniqueId;
		
		EntityHandleSet(ownerHandle,_owner);
		if( !restored )
		{
			SetCurrentMeleWeapon( PW_None );
			queuedMeleeWeapon	= PW_None;
			isQueuedMeleeWeapon	= false;
			isMeleeWeaponReady	= true;
			
			// temp workaround of not saved states - to be fixed after states are stored in saves properly
			// ( i mean: Initialize() shouldn't be even called when restored == true )
			PushState( 'SelectingWeapon' );
		}
		else
		{
			isQueuedMeleeWeapon	= false;
			isMeleeWeaponReady	= true;
			queuedMeleeWeapon	= PW_None;
			//UpdateRealWeapon();
			//UpdateBehGraph(true);
			//UpdateScabbardsBehGraph();
			
			// temp workaround of not saved states - to be fixed after states are stored in saves properly
			// ( i mean: Initialize() shouldn't be even called when restored == true )
			PushState( 'SelectingWeapon' );
			//RecoverItemAfterLoad();
		}
	}
	
	protected function SetCurrentMeleWeapon( weapon : EPlayerWeapon )
	{
		if( currentMeleeWeapon != weapon )
		{
			currentMeleeWeapon	= weapon;
		}
	}
	
	public function UpdateRealWeapon()
	{
		var weaponHeld		: EPlayerWeapon;
		
		
		if( thePlayer.IsWeaponHeld( 'fist' ) )
		{
			weaponHeld = PW_Fists;
		}
		else if( thePlayer.IsWeaponHeld( 'silversword' ) )
		{
			weaponHeld = PW_Silver;
		}
		else if( thePlayer.IsWeaponHeld( 'steelsword' ) || thePlayer.IsWeaponHeld( 'playerSecondary' )  )
		{
			weaponHeld = PW_Steel;
		}
		else
		{
			weaponHeld = PW_None;
		}
		
		if( weaponHeld != PW_None && (W3ReplacerCiri)thePlayer  )
		{
			weaponHeld = PW_Steel;
		}
		
		SetCurrentMeleWeapon( weaponHeld );
	}
	
	protected function GetOwner() : CActor
	{
		return (CActor)EntityHandleGet(ownerHandle);
	}
	
	public function HolsterWeapon(ignoreActionLock : bool, optional forceHolster : bool )
	{
		var curWeapon : EPlayerWeapon;
		
		curWeapon	= GetCurrentMeleeWeapon();
		
		if( curWeapon == PW_None )
		{
			return;
		}
		
		DischargePhantomWeapon();
		OnEquipMeleeWeapon( curWeapon, ignoreActionLock, true, forceHolster );
	}
	
	// holsters weapon without animation
	event OnForcedHolsterWeapon()
	{
		DischargePhantomWeapon();
		SetCurrentMeleWeapon( PW_None );
		UpdateBehGraph();
	}
	
	public function GetCurrentMeleeWeapon() : EPlayerWeapon
	{
		return currentMeleeWeapon;
	}
	
	public function GetCurrentMeleeWeaponName() : name
	{
		return GetWeaponCategoryName ( currentMeleeWeapon );
	}
	
	public function TryToPrepareMeleeWeaponToAttack() : bool
	{
		if( isMeleeWeaponReady )
		{
			// End the holster animation if it is playing so it can blend
			thePlayer.RaiseEvent( 'SwitchWeaponEnd' );
		}
		
		return isMeleeWeaponReady;
	}
	
	public function IsOnTheMiddleOfHolstering() : bool
	{
		return !isMeleeWeaponReady;
	}
	
	public function IsMeleeWeaponReady() : bool
	{
		return isMeleeWeaponReady;
	}
	
	public function EndedCombat()
	{
		// We may need to disarm the player of the fists
		if( GetCurrentMeleeWeapon() == PW_Fists )
		{
			OnEquipMeleeWeapon( PW_None, true );
		}
	}
	
	public function GetMostConvenientMeleeWeapon( targetToDrawAgainst : CActor, optional ignoreActionLock : bool ) : EPlayerWeapon
	{
		var ret : EPlayerWeapon;
		var inv : CInventoryComponent;
		var heldItems	: array<name>;
		var mountedItems	: array<name>;
		var hasPhysicalWeapon, disableAutoSheathe : bool;
		var i : int;
		var npc : CNewNPC;
		var inGameConfigWrapper : CInGameConfigWrapper;
		
		if ( (W3ReplacerCiri)thePlayer  )
		{
			if ( targetToDrawAgainst )
				return PW_Steel;
			else
				return PW_None;
		}
		
		
		// If we don't have automatic unholster we can use only equipped weapon or fists
		if( !automaticUnholster )
		{
			return PW_Fists;
		}
		
		// If there is no target, use fists
		if ( !targetToDrawAgainst )
		{
			return PW_Fists;
		}
		
		// With human we use fists if he has fists
		targetToDrawAgainst.GetInventory().GetAllHeldAndMountedItemsCategories( heldItems, mountedItems );
		
		if ( heldItems.Size() > 0 )
		{
			for ( i = 0; i < heldItems.Size(); i += 1 )
			{
				if ( heldItems[i] != 'fist' )
				{
					hasPhysicalWeapon = true;
					break;
				}
			}
		}
		
		if ( !hasPhysicalWeapon && targetToDrawAgainst.GetInventory().HasHeldOrMountedItemByTag( 'ForceMeleeWeapon' ) )
		{
			hasPhysicalWeapon = true;
		}
		
		npc = (CNewNPC)targetToDrawAgainst;
		
		if ( targetToDrawAgainst.IsHuman() && ( !hasPhysicalWeapon || ( targetToDrawAgainst.GetAttitude( thePlayer ) != AIA_Hostile ) ) ) //&& heldItems.Size() <= 0 
		{
			ret = PW_Fists;
		}
		else if ( npc.IsHorse() && !npc.GetHorseComponent().IsDismounted() ) // failSafe. We shouldn't target mounted horses
		{
			ret = PW_Fists;
		}
		else
		{
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
			disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Gameplay', 'DisableAutomaticSwordSheathe' );
			
			if( disableAutoSheathe )
			{
				ret = PW_Fists;
			}
			else
			{
				// Use the most efective weapon based on used health type
				if(targetToDrawAgainst.UsesVitality())
				{
					ret = PW_Steel;
				}
				else if(targetToDrawAgainst.UsesEssence())
				{
					ret = PW_Silver;
				}
				else
				{
					LogAssert(false, "CR4Player.weaponHolsterSelectWeaponToDraw: target has neither vitality nor essesnce - don't know which weapon to use!");
					ret = PW_Fists;
				}
			}
		}
		
		inv = GetOwner().GetInventory();
		if(ret == PW_Steel && !GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
		{
			ret = PW_Fists;
		}
		else if(ret == PW_Silver && !GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
		{
			ret = PW_Fists;
		}
		
		if ( thePlayer.IsWeaponActionAllowed( ret ) || ignoreActionLock )
		{
			return ret;
		}
		else
		{
			return PW_None;
		}
	}	
	
	
	//---------------------------------------------------------------------------------------------
	// Utils
	//---------------------------------------------------------------------------------------------
	
	protected function IsThisWeaponAlreadyEquipped( weaponType : EPlayerWeapon ) : bool
	{
		//make sure we don't want to change to what we already have
		if ( weaponType == GetCurrentMeleeWeapon() )
		{
			return true;
		}
		
		return false;
	}
	
	//doesn't return proper category of held item ( e.g. you cna have axe equipped )
	protected function GetWeaponCategoryName( weaponType : EPlayerWeapon ) : name
	{
		switch( weaponType )
		{
			case PW_Steel:
				return 'steelsword';
			case PW_Silver:
				return 'silversword';
			case PW_Fists :
				return 'fist';
			case PW_None :
			default : 
				return 'None';
		}
	}
	
	protected function DischargePhantomWeapon()
	{
		if( thePlayer.GetPhantomWeaponMgr() )
			thePlayer.GetPhantomWeaponMgr().DischargeWeapon();
	}
	
	//---------------------------------------------------------------------------------------------
	// Queuing
	//---------------------------------------------------------------------------------------------
	
	protected function QueueMeleeWeapon( weapontype : EPlayerWeapon, optional sheatheIfAlreadyEquipped : bool )
	{
		// Sheathe it
		if( sheatheIfAlreadyEquipped && ( weapontype == PW_Silver || weapontype == PW_Steel ) )
		{
			// Do we have it equipped?
			if( IsThisWeaponAlreadyEquipped( weapontype ) )
			{
				weapontype	= PW_None;
			}
		}
		
		queuedMeleeWeapon	= weapontype;
		isQueuedMeleeWeapon	= true;
	}
	
	protected function IsWeaponQueued() : bool
	{
		return isQueuedMeleeWeapon;
	}
	
	protected function UnqueueMeleeWeapon()
	{
		isQueuedMeleeWeapon	= false;
	}
	
	protected function EquipQueuedMeleeWeaponIfAny() : bool
	{
		if( !isQueuedMeleeWeapon )
		{
			return false;
		}
		
		if( queuedMeleeWeapon == GetCurrentMeleeWeapon() )
		{
			isQueuedMeleeWeapon	= false;
			return false;
		}
		
		//you should only que weapon that ignore action lock
		/*if( !thePlayer.IsWeaponActionAllowed( queuedMeleeWeapon ) )
		{
			return false;
		}*/
		
		OnEquipMeleeWeapon( queuedMeleeWeapon, true );
		
		return true;
	}
	
	function UpdateBehGraph( optional init : bool )
	{
		var weapontype : EPlayerWeapon;
		var item : SItemUniqueId;
		var res : bool;
		var inv : CInventoryComponent;
		var tags : array<name>;
		
		weapontype = GetCurrentMeleeWeapon();
		
		if ( weapontype == PW_None )
		{
			weapontype = PW_Fists;
		}
		
		thePlayer.SetBehaviorVariable( 'WeaponType', 0);
		
		// hack for Ciri
		if ( !GetWitcherPlayer() && weapontype == PW_Fists && thePlayer.IsInCombat()  )
		{
			thePlayer.SetBehaviorVariable( 'playerWeapon', (int) PW_Steel );
			thePlayer.SetBehaviorVariable( 'playerWeaponForOverlay', (int) PW_Steel );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'playerWeapon', (int) weapontype );
			thePlayer.SetBehaviorVariable( 'playerWeaponForOverlay', (int) weapontype );
		}
		
		if ( thePlayer.IsUsingHorse() )
		{
			thePlayer.SetBehaviorVariable( 'isOnHorse', 1.0 );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'isOnHorse', 0.0 );
		}
		
		if ( GetWitcherPlayer() )
		{
			inv = thePlayer.GetInventory();
			if ( GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item) )
			{
				inv.GetItemTags(item,tags);
				if ( tags.Contains('SecondaryWeapon') )
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',1.f );
				else
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',0.f );
			}
			else
			{
				item = inv.GetItemFromSlot('r_weapon');
				inv.GetItemTags(item,tags);
				if ( inv.IsIdValid(item) && tags.Contains('SecondaryWeapon') )
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',1.f );
				else
					thePlayer.SetBehaviorVariable( 'secondaryWeaponForOverlay',0.f );
			}
		}
		
		switch ( weapontype )
		{
			case PW_Steel:
				thePlayer.SetBehaviorVariable( 'SelectedWeapon', 0, true);
				thePlayer.SetBehaviorVariable( 'isHoldingWeaponR', 1.0, true );
				if ( init )
					res = thePlayer.RaiseEvent('DrawWeaponInstant');
				break;
			case PW_Silver:
				thePlayer.SetBehaviorVariable( 'SelectedWeapon', 1, true);
				thePlayer.SetBehaviorVariable( 'isHoldingWeaponR', 1.0, true );
				if ( init )
					res = thePlayer.RaiseEvent('DrawWeaponInstant');
				break;
			default:
				thePlayer.SetBehaviorVariable( 'isHoldingWeaponR', 0.0, true );
				break;
		}
	}
	
	function UpdateScabbardsBehGraph()
	{
		var weapontype : EPlayerWeapon;
		var scabbardsComp : CAnimatedComponent;
		
		weapontype = GetCurrentMeleeWeapon();
		scabbardsComp = (CAnimatedComponent)( thePlayer.GetComponent( "scabbards_skeleton" ) );
		
		switch ( weapontype )
		{
			case PW_Steel:
				scabbardsComp.SetBehaviorVariable( 'isHoldingWeaponR', 1.f );
				break;
			case PW_Silver:
				scabbardsComp.SetBehaviorVariable( 'isHoldingWeaponR', 1.f );
				break;
			default:
				scabbardsComp.SetBehaviorVariable( 'isHoldingWeaponR', 0.f );
				break;
		}
	}
}


state SelectingWeapon in WeaponHolster
{
	event OnEquipMeleeWeapon( weapontype : EPlayerWeapon, ignoreActionLock : bool, optional sheatheIfAlreadyEquipped : bool, optional forceHolster : bool )
	{
		var canWeEquipNow : bool;
		
		// Find real weapon
		//parent.UpdateRealWeapon();
		
		// Can we equip now ?
		canWeEquipNow	= parent.isMeleeWeaponReady;		
		if( canWeEquipNow && !ignoreActionLock && !thePlayer.IsWeaponActionAllowed( weapontype ) )
		{
			canWeEquipNow	= false;
		}
		
		// Equip
		if( canWeEquipNow )
		{
			EquipMeleeWeapon( weapontype, sheatheIfAlreadyEquipped );
		}
		// Queue for later
		else if ( ignoreActionLock )
		{
			parent.QueueMeleeWeapon( weapontype, sheatheIfAlreadyEquipped );
		}
	}
	
	event OnEquippedMeleeWeapon( weaponType : EPlayerWeapon )
	{	
		//show current oil buff on HUD
		if( weaponType == PW_Steel || weaponType == PW_Silver )
		{
			thePlayer.ResumeOilBuffs( weaponType == PW_Steel );
			thePlayer.PlayRuneword4FX(weaponType);
			
			thePlayer.GetBuff( EET_LynxSetBonus ).Resume( 'drawing weapon' );
		}
		
		if( weaponType == PW_Silver )
		{
			thePlayer.ManageAerondightBuff( true );
		}

		if ( parent.GetCurrentMeleeWeapon() != weaponType || weaponType == PW_Fists || weaponType == PW_None )
		{
			parent.UnqueueMeleeWeapon();
			parent.SetCurrentMeleWeapon( weaponType );
			parent.UpdateBehGraph();
			thePlayer.SetBehaviorVariable( 'playerWeaponLatent', thePlayer.GetBehaviorVariable( 'playerWeapon' ) );
		}
		
		if( weaponType == PW_None )
		{
			thePlayer.AddTimer( 'DelayedTryToReequipWeapon', 0.0f, false );
		}
	}
	
	event OnHolsterLeftHandItem()
	{
		HolsterLeftHandItem();
	}
	
	entry function EquipMeleeWeapon( weapontype : EPlayerWeapon, optional sheatheIfAlreadyEquipped : bool )
	{
		var isAWeapon	: bool;
		var fists : W3PlayerWitcherStateCombatFists;
		var item : SItemUniqueId;
		var items : array<SItemUniqueId>;
		var owner : CActor; 
		
		
		if( thePlayer.GetCurrentStateName() == 'PlayerDialogScene' )
		{
			return;
		}	
		
		//parent.UpdateBehGraph(true);
		
		thePlayer.SetBehaviorVariable( 'holsterReadyToSkip', 0.0f, true );
		
		// Unqueue if there was any
		parent.UnqueueMeleeWeapon( );
		
		// Are we asking for a physical weapon?
		isAWeapon	= weapontype == PW_Silver || weapontype == PW_Steel;	
		
		// Do we have it equipped?
		if( parent.IsThisWeaponAlreadyEquipped( weapontype ) )
		{
			// E# hack. Let's remove the complete  sheatheIfAlreadyEquipped thing
			// Sheathe it
			if( sheatheIfAlreadyEquipped && isAWeapon )
			{
				if( thePlayer.IsInCombat() )
				{
					weapontype	= PW_Fists;
				}
				else
				{
					weapontype	= PW_None;
				}
				isAWeapon	= false;
			}
			// Dont equip the same weapon again
			else
			{
				return;
			}
		}	
		
		owner = parent.GetOwner();
		
		// Stop any attack
		fists = ((W3PlayerWitcherStateCombatFists)owner.GetState('Combat'));
		if( fists )
		{
			fists.comboPlayer.StopAttack();
		}
		
		// Remember what we have		
		parent.SetCurrentMeleWeapon( weapontype );	
		
		// Start changing
		Lock();
		
		parent.UpdateBehGraph();
		
		switch( weapontype )
		{
			case PW_None :
				thePlayer.SetRequiredItems('Any', 'None');
				thePlayer.ProcessRequiredItems();
				break;
			case PW_Fists : 
/*				if ( thePlayer.IsHoldingItemInLHand () )
				{
					HideUsableItemL();
				}*/
				if ( !thePlayer.inv.HasItem('Geralt fists') && !thePlayer.IsFistFightMinigameEnabled() )
				{
					thePlayer.inv.AddAnItem( 'Geralt fists', 1, true, true, false );
				}
				thePlayer.SetRequiredItems('Any', 'fist' );
				thePlayer.ProcessRequiredItems();
				break;
			case PW_Steel:
				if( GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item) )
				{
					thePlayer.DrawItemsLatent(item);
				}
				else if ( (W3ReplacerCiri)thePlayer )
				{
					items = thePlayer.GetInventory().GetItemsByName(theGame.params.CIRI_SWORD_NAME);
					if ( items.Size() > 0 )
					{
						thePlayer.DrawItemsLatent(items[0]);
					}
				}
				break;
			case PW_Silver:
				if( GetWitcherPlayer().GetItemEquippedOnSlot( EES_SilverSword, item) )
				{
					thePlayer.DrawItemsLatent(item);
				}
				break;
		}
		
		parent.UpdateRealWeapon();
		// End changing
		Unlock();		
		parent.SetCurrentMeleWeapon( weapontype );		
	}	
	
	entry function HolsterLeftHandItem()
	{
		Lock();
		
		//thePlayer.SetRequiredItems('fists', 'None');
		thePlayer.SetRequiredItems( 'None', 'Any' );
		//thePlayer.HideUsableItem();
		thePlayer.ProcessRequiredItems();
		
		Unlock();
	}
	
	event OnWeaponDrawReady()
	{
		// Restore control
		Unlock();
		
		SignalDrawSwordAction();
		
		thePlayer.SetBehaviorVariable( 'holsterReadyToSkip', 1.0f, true );
		thePlayer.SetBehaviorVariable( 'playerWeaponLatent', thePlayer.GetBehaviorVariable( 'playerWeapon' ) );
	}
	event OnWeaponHolsterReady()
	{
		// Restore control
		Unlock();
		
		SignalHolsterSwordAction();
		
		parent.DischargePhantomWeapon();
		
		thePlayer.SetBehaviorVariable( 'holsterReadyToSkip', 1.0f, true );
		thePlayer.SetBehaviorVariable( 'playerWeaponLatent', thePlayer.GetBehaviorVariable( 'playerWeapon' ) );
	}
	 
	 private latent function HideUsableItemL ()
	{
		while ( true )
		{
			if ( !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.OnUseSelectedItem( true );
				return;
			}
			Sleep( 0.01f );
		}
	}
	private function SignalDrawSwordAction()
	{
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'DrawSwordAction', -1, 8.0f, -1, 9999, true); //reactionSystemSearch
	}
	
	private function SignalHolsterSwordAction()
	{
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'HolsterSwordAction', -1, 8.0f, -1, 9999, true); //reactionSystemSearch
	}
	 
	private function Lock()
	{
		var actionBlockingExceptions : array<EInputActionBlock>;
		var horseComp : W3HorseComponent;
		
		// Lock entry function
		//parent.LockEntryFunction( true );
		
		// Lock Save
		//theGame.CreateNoSaveLock( 'weapon_holster', noSaveLock );
		
		
		// Block actions
		actionBlockingExceptions.PushBack(EIAB_Movement);
		actionBlockingExceptions.PushBack(EIAB_RunAndSprint);
		actionBlockingExceptions.PushBack(EIAB_Signs);
		actionBlockingExceptions.PushBack(EIAB_CallHorse);
		actionBlockingExceptions.PushBack(EIAB_Jump);
		//actionBlockingExceptions.PushBack(EIAB_DrawWeapon);
		actionBlockingExceptions.PushBack(EIAB_Roll);		// ED: Don't comment this line
		actionBlockingExceptions.PushBack(EIAB_Dodge);
		actionBlockingExceptions.PushBack(EIAB_Climb);
		actionBlockingExceptions.PushBack(EIAB_Slide);
		actionBlockingExceptions.PushBack(EIAB_ThrowBomb);
		actionBlockingExceptions.PushBack(EIAB_Crossbow);
		actionBlockingExceptions.PushBack(EIAB_UsableItem);
		actionBlockingExceptions.PushBack(EIAB_RadialMenu);
		actionBlockingExceptions.PushBack(EIAB_OpenInventory);
		actionBlockingExceptions.PushBack(EIAB_OpenCharacterPanel);
		actionBlockingExceptions.PushBack(EIAB_MeditationWaiting);
		actionBlockingExceptions.PushBack(EIAB_OpenMap);
		actionBlockingExceptions.PushBack(EIAB_OpenJournal);
		actionBlockingExceptions.PushBack(EIAB_OpenAlchemy);
		actionBlockingExceptions.PushBack(EIAB_OpenGlossary);
		actionBlockingExceptions.PushBack(EIAB_OpenGwint);
		actionBlockingExceptions.PushBack(EIAB_ExplorationFocus);
		actionBlockingExceptions.PushBack(EIAB_Sprint);
		actionBlockingExceptions.PushBack(EIAB_OpenMeditation);
		actionBlockingExceptions.PushBack(EIAB_QuickSlots);
		thePlayer.BlockAllActions( 'WeaponHolster', true, actionBlockingExceptions, false);
		
		// Weapon is not ready
		parent.isMeleeWeaponReady	= false;
		
		horseComp = thePlayer.GetUsedHorseComponent();
		
		if ( horseComp )
		{
			horseComp.GetUserCombatManager().OnMeleeWeaponNotReady();
		}
	}
	
	private function Unlock()
	{
		var horseComp : W3HorseComponent;
		
		parent.UpdateScabbardsBehGraph();
		
		//theGame.ReleaseNoSaveLock( noSaveLock );
		
		// Unlock all actions
		thePlayer.BlockAllActions( 'WeaponHolster', false);
		
		// Weapon is ready
		parent.isMeleeWeaponReady	= true;
		
		horseComp = thePlayer.GetUsedHorseComponent();
		
		if ( horseComp )
		{
			horseComp.GetUserCombatManager().OnMeleeWeaponReady();
		}
		
		// We cna use entry function again
		//parent.LockEntryFunction( false );
		
		// Do we have something queued that is not the current weapon?		
		parent.EquipQueuedMeleeWeaponIfAny();
	}
	
	timer function HideUsableItemLTimer ( dt : float, id : int )
	{
		if ( thePlayer.IsHoldingItemInLHand () )
		{
			if ( !thePlayer.IsUsableItemLBlocked() )
			{
				thePlayer.OnUseSelectedItem( true );
				
			}
		}
	}
	/*timer function CheckForQueuedWeapon( timeDelta : float , id : int)
	{			
		if( parent.EquipQueuedMeleeWeaponIfAny() )
		{
			parent.RemoveTimer( 'CheckForQueuedWeapon' );
		}
	}*/
}
