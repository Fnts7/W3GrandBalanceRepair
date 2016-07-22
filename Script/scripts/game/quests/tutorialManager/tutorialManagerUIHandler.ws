/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

//empty state when no UI tutorial is running
state Tutorial_Idle in W3TutorialManagerUIHandler {}

//handles UI tutorials since quest system is paused when we open panels
statemachine class W3TutorialManagerUIHandler
{
	private saved var listeners : array<SUITutorial>;
	private var lastOpenedMenu : name;
	private var isMenuOpened : bool;
	private var postponedUnregisteredMenu : name;
	
	//called when loading a game
	public final function OnLoad()
	{
		var i : int;
		
		//retrofix for pinning tutorial - added required facts
		for(i=0; i<listeners.Size(); i+=1)
		{
			if(listeners[i].tutorialStateName == 'RecipePinning')
			{
				if(listeners[i].menuName == 'AlchemyMenu')
				{
					listeners[i].requiredGameplayFactName = "tutorial_alchemy_pin_done";
					listeners[i].requiredGameplayFactValueInt = 0;
					listeners[i].requiredGameplayFactComparator = CO_Equal;
				}
				else
				{
					listeners[i].requiredGameplayFactName2 = "tutorial_craft_pin_done";
					listeners[i].requiredGameplayFactValueInt2 = 0;
					listeners[i].requiredGameplayFactComparator2 = CO_Equal;
				}
			}		
		}
	}
	
	public final function AddNewBooksTutorial()
	{
		var uitut : SUITutorial;
		
		uitut.menuName = 'CommonMenu';
		uitut.tutorialStateName = 'BooksCommonMenu';
		uitut.triggerCondition = EUITTC_OnMenuOpen;
		uitut.priority = 1;
		uitut.abortOnMenuClose = true;
		RegisterUIHint(uitut);
		
		uitut.menuName = 'GlossaryBooksMenu';
		uitut.tutorialStateName = 'BooksNew';
		uitut.triggerCondition = EUITTC_OnMenuOpen;
		uitut.priority = 1;
		uitut.abortOnMenuClose = true;
		RegisterUIHint(uitut);
		
		uitut.menuName = 'GlossaryParent';
		uitut.tutorialStateName = 'BooksCommonMenuSubmenu';
		uitut.triggerCondition = EUITTC_OnMenuOpen;
		uitut.priority = 40;
		uitut.abortOnMenuClose = true;
		RegisterUIHint(uitut);
	}
	
	//returns true if a new state will be entered
	private function HandleListeners(menuName : name, isOpened : bool) : bool
	{
		var i, factVal, chosenIndex, minPriority 	: int;
		var arr 									: array<SItemUniqueId>;
		
		//fast exit - ignore popups (also a debugging salvation)
		if(menuName == 'TutorialPopupMenu')
			return false;
			
		//skip hubmenu for shops (hubmenu tutorials should not trigger when in shop... since they're hubmenu tutorials not shop tutorials...)
		if(menuName == 'CommonMenu' && theGame.GameplayFactsQuerySum("shopMode") > 0)
			return false;
		
		if(isOpened)
			lastOpenedMenu = menuName;
			
		isMenuOpened = isOpened;
		minPriority = 1000000;
		chosenIndex = -1;
		for(i=0; i<listeners.Size(); i+=1)
		{
			if(listeners[i].menuName != menuName)
				continue;				
				
			if(listeners[i].triggerCondition == EUITTC_OnMenuOpen && !isOpened)
				continue;
				
			//disable all inventory tutorials in Stash screen
			if(menuName == 'InventoryMenu' && theGame.GameplayFactsQuerySum("stashMode") > 0)
				continue;
				
			if(listeners[i].requiredGameplayFactName != "")
			{
				factVal = theGame.GameplayFactsQuerySum(listeners[i].requiredGameplayFactName);
				if(!ProcessCompare(listeners[i].requiredGameplayFactComparator, factVal, listeners[i].requiredGameplayFactValueInt))
					continue;
			}
			if(listeners[i].requiredGameplayFactName2 != "")
			{
				factVal = theGame.GameplayFactsQuerySum(listeners[i].requiredGameplayFactName2);
				if(!ProcessCompare(listeners[i].requiredGameplayFactComparator2, factVal, listeners[i].requiredGameplayFactValueInt2))
					continue;
			}
				
			//make sure we have a mutagen (didn't use or drop it since HUD message was shown)
			if( listeners[i].tutorialStateName == 'CharDevMutagens')
			{
				arr = thePlayer.inv.GetItemsByTag('MutagenIngredient');
				if( arr.Size() == 0 )
				{
					continue;
				}
			}	
			
			//if elligible for showing we will show the one with lowest priority value
			if(minPriority > listeners[i].priority)
			{
				minPriority = listeners[i].priority;
				chosenIndex = i;
			}
		}
		
		if(chosenIndex >= 0)
		{
			LogTutorial( "UIHandler: chose new state - " + listeners[chosenIndex].tutorialStateName );
			GotoState( listeners[chosenIndex].tutorialStateName );
			return true;
		}
		
		return false;
	}
		
	public function RegisterUIHint(data : SUITutorial)
	{
		listeners.PushBack(data);
	}
	
	/*
		Returns true if unregister will trigger an entering of new state.
		
		BUT
		
		In case of book & recipe tutorials we have a case where we finish the tutorial with opened pop-up menu (text of book/scroll) so
		we don't want to trigger next tutorial just yet. Instead we want to postpone it after popup menu is closed. For this reason
		postponedUnregisteredMenu caches which menu we're in and does NOT trigger next listener. Later on in OnClosingMenu() we check
		that popup is being closed and postponedUnregisteredMenu is not empty and THEN call next listener.
		
		BUT (this is the moment where you can go berserk)
		
		When we finish the book/recipe tutorial the popup menu is not shown yet on the screen, so asking if any popup is opened returns false.
		The check is done after popup is requested to open but apparently it needs some time to process it. So instead of checking if we have some popup
		menu opened we just HACK it and check the name of tutorial state. I'm sorry, I tried...
	*/
	public function UnregisterUIState(tutorialStateName : name, optional sourceName : string) : bool
	{
		var i : int;
		var listenerMenu : name;
				
		for(i=0; i<listeners.Size(); i+=1)
		{
			if(listeners[i].tutorialStateName == tutorialStateName && (sourceName == "" || listeners[i].sourceName == sourceName) )
			{
				listenerMenu = listeners[i].menuName;
				
				listeners.EraseFast(i);
				
				//don't trigger new tutorials if pop-up menu is opened - postpone till it closes
				if(tutorialStateName == 'Books' || tutorialStateName == 'RecipeReading')
				{
					postponedUnregisteredMenu = lastOpenedMenu;
					return false;
				}
				
				//note that crafting UI tutorial is done, needed for crafting pinning tutorial
				if(tutorialStateName == 'Crafting')
				{
					theGame.GameplayFactsAdd("tutorial_craft_finished");
				}
		
				//if menu is still opened go and check if we have more listeners
				if(lastOpenedMenu == listenerMenu && isMenuOpened)
				{
					return HandleListeners(lastOpenedMenu, true);
				}
				else
				{
					return false;
				}
			}
		}
		
		return false;
	}
	
	//returns true if given state is registered by some listener
	public final function IsStateRegistered( stateName : name ) : bool
	{
		var i : int;
		
		if( stateName == '' )
		{
			return false;
		}
		
		for( i=0; i<listeners.Size(); i+=1 )
		{
			if( listeners[i].tutorialStateName == stateName )
			{
				return true;
			}
		}
		
		return false;
	}
	
	event OnOpeningMenu(menuName : name)
	{
		//LogTutorial("UIHandler: OnOpeningMenu <<" + menuName + ">>");
	
		//if there is non-menu tutorial on screen then hide it when a UI panel opens
		if(menuName == 'CommonMenu' || menuName == 'CommonIngameMenu')
			theGame.GetTutorialSystem().OnOpeningMenuHandleNonMenuTutorial();
				
		//alchemy ingredients check for tutorial
		if(menuName == 'AlchemyMenu' && ShouldProcessTutorial('TutorialAlchemyCook'))
		{
			ProcessAlchemyTutorialFact();					
		}
		//crafting ingredients check for tutorial
		if(menuName == 'CraftingMenu' && ShouldProcessTutorial('TutorialCraftingSchematicsList'))
		{
			ProcessCraftingTutorialFact();					
		}
		if(menuName == 'InventoryMenu' && ShouldProcessTutorial('TutorialRunesSelectRune'))
		{	
			ProcessRunesFact();
		}
		if(menuName == 'InventoryMenu' && ShouldProcessTutorial('TutorialArmorSocketsSelectTab'))
		{	
			ArmorUpgradesTutorialCheck();
		}
		if(menuName == 'InventoryMenu' && ShouldProcessTutorial('TutorialPotionCanEquip2'))
		{	
			ProcessPotionEquipFact();
		}		
		
		HandleListeners(menuName, true);
		
		//for current handler state
		OnMenuOpening(menuName);
	}
	
	private final function ProcessPotionEquipFact()
	{
		var witcher : W3PlayerWitcher;
		var isPot1, isPot2, isPot3, isPot4 : bool;
		var pot : SItemUniqueId;
		var n : name;
		
		witcher = GetWitcherPlayer();
		if(witcher)
		{
			isPot1 = false;
			isPot2 = false;
			isPot3 = false;
			isPot4 = false;
			if(witcher.GetItemEquippedOnSlot(EES_Potion1, pot))
			{
				isPot1 = witcher.inv.IsItemPotion(pot);
				n = witcher.inv.GetItemName(pot);
			}
			if(witcher.GetItemEquippedOnSlot(EES_Potion2, pot))
			{
				isPot2 = witcher.inv.IsItemPotion(pot);
				n = witcher.inv.GetItemName(pot);
			}
			if(witcher.GetItemEquippedOnSlot(EES_Potion3, pot))
			{
				isPot3 = witcher.inv.IsItemPotion(pot);
				n = witcher.inv.GetItemName(pot);
			}
			if(witcher.GetItemEquippedOnSlot(EES_Potion4, pot))
			{
				isPot4 = witcher.inv.IsItemPotion(pot);
				n = witcher.inv.GetItemName(pot);
			}
			
			if(!isPot1 && !isPot2 && !isPot3 && !isPot4)
				GameplayFactsAdd("tutorial_equip_potion");
		}		
	}
	
	private final function ProcessAlchemyTutorialFact()
	{
		var alchemyManager : W3AlchemyManager;
		var witcher : W3PlayerWitcher;
		var i : int;
		var recipes : array<name>;
		
		witcher = GetWitcherPlayer();
		if(witcher)
		{
			GameplayFactsRemove("tutorial_alch_has_ings");
			alchemyManager = new W3AlchemyManager in this;
			alchemyManager.Init();
			
			recipes = witcher.GetAlchemyRecipes();
			
			for(i=0; i<recipes.Size(); i+=1)
			{
				if(alchemyManager.CanCookRecipe(recipes[i]) == EAE_NoException)
				{
					GameplayFactsAdd("tutorial_alch_has_ings");
					break;
				}
			}
			
			delete alchemyManager;
		}	
	}
	
	private final function ProcessCraftingTutorialFact()
	{
		var craftingManager : W3CraftingManager;
		var i : int;
		var witcher : W3PlayerWitcher;
		var craftsmanComponent : W3CraftsmanComponent;
		var recipes : array<name>;
		var craftMenu : CR4CraftingMenu;
		var craftingError : ECraftingException;
		
		witcher = GetWitcherPlayer();
		if(witcher)
		{
			GameplayFactsRemove("tutorial_craft_has_ings");
			recipes = witcher.GetCraftingSchematicsNames();
			
			craftMenu = (CR4CraftingMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
			craftsmanComponent = craftMenu.GetCraftsmanComponent();

			if(!craftsmanComponent)
				return;
				
			craftingManager = new W3CraftingManager in this;
			craftingManager.Init(craftsmanComponent);
			
			for(i=0; i<recipes.Size(); i+=1)
			{
				craftingError = craftingManager.CanCraftSchematic(recipes[i], true);
				
				//if shematic is visible on the list
				if(craftingError != ECE_WrongCraftsmanType)
				{
					GameplayFactsAdd("tutorial_craft_has_ings");
					break;
				}
			}
			
			delete craftingManager;
		}	
	}
	
	private final function ProcessRunesFact()
	{
		var i : int;
		var weapons : array<SItemUniqueId>;
		var item : SItemUniqueId;
		
		//if has any runes
		if(thePlayer.inv.GetItemQuantityByTag('WeaponUpgrade') > 0)
		{
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
				weapons.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
				weapons.PushBack(item);
				
			for(i=0; i<weapons.Size(); i+=1)
			{
				//if has any weapon with upgrade slots
				if(thePlayer.inv.GetItemEnhancementSlotsCount(weapons[i]) > 0)
				{
					//if weapon has free upgrade slots
					if(thePlayer.inv.GetItemEnhancementCount(weapons[i]) < thePlayer.inv.GetItemEnhancementSlotsCount(weapons[i]))
					{
						GameplayFactsAdd("tut_runes_start");
						return;
					}
				}
			}
		}
	}
	
	private final function ArmorUpgradesTutorialCheck()
	{
		var i : int;
		var items : array<SItemUniqueId>;
		var item : SItemUniqueId;
		
		//if has any upgrades
		if(thePlayer.inv.GetItemQuantityByTag('ArmorUpgrade') > 0)
		{
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Armor, item))
				items.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Boots, item))
				items.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Pants, item))
				items.PushBack(item);
			if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_Gloves, item))
				items.PushBack(item);
				
			for(i=0; i<items.Size(); i+=1)
			{
				//if has any armor with upgrade slots
				if(thePlayer.inv.GetItemEnhancementSlotsCount(items[i]) > 0)
				{
					//if armor has free upgrade slots
					if(thePlayer.inv.GetItemEnhancementCount(items[i]) < thePlayer.inv.GetItemEnhancementSlotsCount(items[i]))
					{
						GameplayFactsAdd("tut_arm_upg_start");
						return;
					}
				}
			}
		}
	}
	
	event OnOpenedMenu(menuName : name)
	{
		//LogTutorial("UIHandler: OnOpenedMenu <<" + menuName + ">>");
		
		//for current handler state
		OnMenuOpened(menuName);
	}
	
	event OnClosingMenu(menuName : name)
	{
		var stateName : name;
		var i : int;
		
		//LogTutorial("UIHandler: OnClosingMenu <<" + menuName + ">>");
		
		//if closing Inventory clear inventory tutorial GP fact
		if( menuName == 'InventoryMenu' )
		{
			theGame.GameplayFactsRemove( 'panel_on_since_inv_tut' );
		}
		
		//if closing popup then we might have a postponed listener waiting (listeners don't process if a popup menu is still opened)
		if(menuName == 'PopupMenu' && IsNameValid(postponedUnregisteredMenu))
		{
			HandleListeners(postponedUnregisteredMenu, true);
			postponedUnregisteredMenu = '';
		}
		else
		{
			HandleListeners(menuName, false);
		}
		
		//for current handler state
		OnMenuClosing(menuName);
		
		//if closing menu which is having a tutorial now, abort the tutorial if it was requested
		//also close if we're closing any fullscreen menu (e.g. we have meditation tutorial but we switch to inventory and THEN close)
		stateName = GetCurrentStateName();
		if(IsNameValid(stateName))
		{
			for(i=0; i<listeners.Size(); i+=1)
			{
				if(listeners[i].tutorialStateName == stateName && listeners[i].abortOnMenuClose && (listeners[i].menuName == menuName || 'CommonMenu' == menuName))
				{
					GotoState('Tutorial_Idle');
					break;
				}
			}
		}
	}
	
	event OnClosedMenu(menuName : name)
	{
		//LogTutorial("UIHandler: OnClosedMenu <<" + menuName + ">>");
		
		//for current handler state
		OnMenuClosed(menuName);
	}
	
	//override in states
	event OnMenuClosing(menuName : name) 	{}
	event OnMenuClosed(menuName : name) 	{}
	event OnMenuOpening(menuName : name) 	{}
	event OnMenuOpened(menuName : name) 	{}
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool) {}
	
	//locks possibility to close / leave current UI panel
	public final function LockLeaveMenu(locked:bool)
	{
		var guiManager : CR4GuiManager;
		var rootMenu : CR4CommonMenu;
			
		guiManager = theGame.GetGuiManager();
				
		if (guiManager && guiManager.IsAnyMenu())
		{
			rootMenu = (CR4CommonMenu)guiManager.GetRootMenu();
			
			if (rootMenu)
			{
				rootMenu.SetLockedInMenu(locked);
			}
		}
	}
	
	//locks possibility to leave UI panels and return to game
	public final function LockCloseUIPanels(lock : bool)
	{
		var guiManager : CR4GuiManager;
		var rootMenu : CR4CommonMenu;
			
		guiManager = theGame.GetGuiManager();
				
		if (guiManager && guiManager.IsAnyMenu())
		{
			rootMenu = (CR4CommonMenu)guiManager.GetRootMenu();
			
			if (rootMenu)
			{
				rootMenu.SetLockedInHub(lock);
			}
		}
	}
	
	public final function ClearAllListeners()
	{
		listeners.Clear();
	}
}