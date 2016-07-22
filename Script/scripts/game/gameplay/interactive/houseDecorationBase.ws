/***********************************************************************/
/** Copyright © 2015
/** Authors : Danisz Markiewicz
/***********************************************************************/

abstract class W3HouseDecorationBase extends W3Container
{
	protected var m_popupData : W3ItemSelectionPopupData;
	protected var m_itemSelectionTagList : array<name>;
	protected var m_itemSelectionForbiddenTagList : array<name>;
	protected var m_itemSelectionMode : EItemSelectionPopupMode;
	protected var m_itemSelectionCategories : array<name>;
	protected editable var m_acceptQuestItems : bool;
	protected editable saved var m_decorationEnabled : bool;
	protected editable var m_noItemMessageStringKey : name;
	
	default m_noItemMessageStringKey = 'decoration_error_generic';
	hint m_decorationEnabled = "String key of a message that should be display if the player doesn't have any valid items in his inventory."; 
	
	default m_decorationEnabled	= true;
	hint m_decorationEnabled = "Should the decoration entity interaction be enabled."; 
	
	//Overriding default setting, we want decorations to be always highlighted
	default disableFocusHighlightControl = true;
	hint m_acceptQuestItems = "If true quest item filter we be disabled for this decoration."; 
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//Always mark this container as quest container
		SetIsQuestContainer( true );
		
		//We don't want the player to use quest items as decorations
		if( !m_acceptQuestItems )
		{
			AddItemSelectionForbiddenFilterTag( 'Quest' );
		}
		
		UpdateDecorationFocusHighlight();
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if( GetIsDecoractionEmpty() )
		{
			if( GetIfPlayerHasValidItems() )
			{
				//There are no items in container, open item selection
				OpenItemCollectionMenu();
			}
			else
			{
				//If there are no valid items to display in pop-up window display on-screen message instead
				if( IsNameValid( m_noItemMessageStringKey ) )
				{
					thePlayer.DisplayHudMessage( GetLocStringByKeyExt( m_noItemMessageStringKey ) );
				}
			}
		}
		else
		{
			//There is something in container, open loot panel
			ProcessLoot ();
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		//If the entity is disabled the interaction should not be displayed
		if ( !m_decorationEnabled )
		{
			return false;
		}
		
		return true;
	}	
	
	//Waiting for item selection popup to be closed
	timer function ItemSelectionTimer( delta : float , id : int)
	{
		if( m_popupData )
		{
			AddTimer( 'ItemSelectionTimer', 0.1f );
		}
		else
		{
			ProcessItemReceival();
		}
	}
	
	//Performs operatins upon receiving an item
	public function ProcessItemReceival( optional mute : bool )
	{
		//UpdateContainer();
		SetFocusModeVisibility( focusModeHighlight );
	}
	
	//Updates entities focus highlight mode
	private function UpdateDecorationFocusHighlight()
	{
		if( m_decorationEnabled )
		{
			this.SetFocusModeVisibility( FMV_Interactive, true );
		}
		else
		{
			this.SetFocusModeVisibility( FMV_None, true );
		}	
	}
	
	//Opens item selection popup with correct filters
	private function OpenItemCollectionMenu()
	{
		var itemSelectionPopup : CR4ItemSelectionPopup;	
		var tags : array<name>;	
		var firstTag : name;
		
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( 'None' );
		
		tags = GetTags();
		firstTag = tags[0];
		
		//UI popup requires entity tag to be unique, decoration should not work if it's not
		if( !GetIsTagUnique( firstTag ) )
		{
			LogChannel( 'houseDecorations', "Entity tag '" + firstTag + "' is not unique, decoration will not function!" );
			return;
		}
		
		m_popupData = new W3ItemSelectionPopupData in theGame.GetGuiManager();
		m_popupData.targetInventory = GetInventory();
		m_popupData.collectorTag = firstTag;
		m_popupData.overrideQuestItemRestrictions = true;
		
		//Following filter settings are modified per child class type
		m_popupData.filterTagsList = m_itemSelectionTagList;
		m_popupData.filterForbiddenTagsList = m_itemSelectionForbiddenTagList;
		m_popupData.selectionMode = m_itemSelectionMode;
		
		m_popupData.categoryFilterList = m_itemSelectionCategories;
		
		theGame.RequestPopup('ItemSelectionPopup', m_popupData);
		AddTimer( 'ItemSelectionTimer', 0.1f );
	}
	
	//Adds a new tag to filters of item selection popup
	function AddItemSelectionFilterTag( newTag : name )
	{
		m_itemSelectionTagList.PushBack( newTag );
	}
	
	//Adds a new forbidden tag to filters of item selection popup
	function AddItemSelectionForbiddenFilterTag( newTag : name )
	{
		m_itemSelectionForbiddenTagList.PushBack( newTag );
	}

	//Add item category to items that should be considered during item processing
	function AddItemSelectionCategory( newCategory : name )
	{
		m_itemSelectionCategories.PushBack( newCategory );
	}
	
	//Changes the item selection popup mode
	function ChangeItemSelectionMode( newMode : EItemSelectionPopupMode )
	{
		m_itemSelectionMode = newMode;
	}
	
	//Checks if there is exactly one entity with this tag
	private function GetIsTagUnique( entityTag : name ) : bool
	{
		var entities : array<CEntity>;
		
		theGame.GetEntitiesByTag( entityTag, entities );
		
		if( entities.Size() == 1 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	//Check if there are any vaild items in the inventory, expanded in child classes
	private function GetIsDecoractionEmpty() : bool
	{
		return GetInventory().IsEmpty();
	}
	
	//Pre-check for items that are valid for pop-up panel, expanded in child classes
	private function GetIfPlayerHasValidItems() : bool
	{
		return true;
	}
	
	//Public function used to enable and disable via external systems
	public function SetDecorationEnabled( enabled : bool ) 
	{
		m_decorationEnabled = enabled;
		
		UpdateDecorationFocusHighlight();
	}
	
	//Public function used to enable and disable via external systems
	public function GetAcceptQuestItems() : bool
	{
		return m_acceptQuestItems;
	}
	
	//Check if the item has any of the forbidden tags
	public function GetItemHasForbiddenTag( item : SItemUniqueId ) : bool
	{
		var i, size : int;
		var inv : CInventoryComponent;
		
		inv = thePlayer.GetInventory();
		size =  m_itemSelectionForbiddenTagList.Size();
		
		if( size == 0 ) return false;
		
		for( i=0; i < size; i+= 1 )
		{
			if( inv.ItemHasTag( item , m_itemSelectionForbiddenTagList[i] ) )
			{
				return true;
			}
		}
		
		return false;
	}	
	
	//Check if the entity has inside it's inventory a sleeveless armor or not
	public function GetHasSleevlessArmor() : bool
	{
		var armors : array<SItemUniqueId>;
		var armorName  : name;
		var sleevlesDefinitions : array<name>;
		
		sleevlesDefinitions = theGame.GetDefinitionsManager().GetItemsWithTag('Sleevless');
		
		armors = GetInventory().GetItemsByCategory('armor');
		armorName = GetInventory().GetItemName( armors[0] );
		
		if( sleevlesDefinitions.Contains( armorName ) )
		{
			return true;
		}
		
		return false;
	}
	
	
}
	

	