/***********************************************************************/
/** Witcher Script file - Base class 
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Yaroslav Getsevich
/***********************************************************************/

class W3ItemSelectMenuInitData extends CObject
{
	public var onlyEquipped:bool;
	public var onlyUnequipped:bool;
	public var containTags:array<name>;
	
	public function applyItemSelection(item : SItemUniqueId) : void
	{
		// virtual
	}
}

class CR4MenuItemSelect extends CR4OverlayMenu
{
	protected var _itemsInv      : W3GuiItemSelectComponent;
	protected var _invComponent  : CInventoryComponent;
	
	protected var _initData : W3ItemSelectMenuInitData;
	
	event /*flash*/ OnConfigUI()
	{
		super.OnConfigUI();
		
		MakeModal(true);
				
		LogChannel('CHR', "[CR4MenuItemSelect]  OnConfigUI");
		
		_initData = (W3ItemSelectMenuInitData)GetMenuInitData();
		
		_invComponent = thePlayer.GetInventory();
		_itemsInv = new W3GuiItemSelectComponent in this;
		_itemsInv.Initialize( _invComponent );
		_itemsInv.InitFilter( _initData );
		
		UpdateData();
	}
	
	//event /*flash*/ OnEquipItem( item : SItemUniqueId, slot : int )
	event /*flash*/ OnSelectItem( item : SItemUniqueId )
	{
		LogChannel('CHR', "[CR4MenuItemSelect]  OnSelectItem; "+thePlayer.GetInventory().IsIdValid(item));
		
		_initData.applyItemSelection( item );
		RequestClose();
	}
	
	public function RequestClose():void
	{
		if (_initData)
		{
			delete _initData;
		}
		super.RequestClose();
	}	
	
	protected function UpdateData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		_itemsInv.GetInventoryFlashArray(l_flashArray,l_flashObject);
		
		LogChannel('CHR', "[CR4MenuItemSelect]  UpdateData "+l_flashArray.GetLength());
		
		m_flashValueStorage.SetFlashArray("items.list.data", l_flashArray );
	}
}