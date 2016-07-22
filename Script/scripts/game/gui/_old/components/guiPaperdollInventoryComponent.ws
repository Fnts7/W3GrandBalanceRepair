class W3GuiPaperdollInventoryComponent extends W3GuiPlayerInventoryComponent
{
	public var previewSlots : array<bool>;
	
	default bPaperdoll = true;

	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var itemTags : array<name>;

		_inv.GetItemTags( item, itemTags );

		LogChannel('PAPERDOLLITEMS'," shuld show ? "+(super.ShouldShowItem( item ) && isEquipped( item ) /*&& !itemTags.Contains('Mutagen')*/ )+" item "+_inv.GetItemName(item));
		return super.ShouldShowItem( item ) && isEquipped( item ) /*&& !itemTags.Contains('Mutagen')*/; //@FIXME BIDON - check if super.ShouldShowItem( item ) is needed here
	}
	
	protected function GetTooltipText(item : SItemUniqueId):string // #B why it's commented ?
	{
		var debugTooltip : string;
		var TooltipType : ECompareType;
		/*		
		TooltipType = _inv.GetItemRelativeTooltipType(item, _inv, SecondItemID);
		
		switch(TooltipType)
		{
			case ECT_Compare:	//TODO #B
				debugTooltip = GetItemTooltipText(item, _inv);
				break;				
			default:
				debugTooltip = GetItemTooltipText(item, _inv);
				break;
		}*/
		
		//LogChannel('W3PaperdollInventoryDataProvider',"");
		//LogChannel('W3PaperdollInventoryDataProvider',"DP GetTooltipText item "+ _inv.GetItemName(item) +" vs "+_inv.GetItemName(SecondItemID));
		//LogChannel('W3PaperdollInventoryDataProvider'," TooltipType "+TooltipType +" debugTooltip "+debugTooltip);
		
		return debugTooltip;
	}
	
	protected function isEquipped( item : SItemUniqueId ) : bool
	{
		var horseMgr : W3HorseManager;
		
		if (isHorseItem(item))
		{
			horseMgr = GetWitcherPlayer().GetHorseManager();
			if (horseMgr)
			{
				return horseMgr.IsItemEquipped(item);
			}
		}
		else
		{
			return GetWitcherPlayer().IsItemEquipped(item);
		}
		
		return false;
	}
	
	public /*override*/ function SetInventoryFlashObjectForItem( itemId : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var slotType 			  : EEquipmentSlots;
		var canDrop				  : bool;
		var targetSlot   		  : int;
		var dyeItemId			  : SItemUniqueId;
		var dyeItemName			  : name;
		
		super.SetInventoryFlashObjectForItem( itemId, flashObject );
		
		slotType = GetCurrentSlotForItem( itemId );
		
		canDrop = !IsMultipleSlot(slotType) && (slotType != EES_Bolt);
		if (!canDrop)
		{
			flashObject.SetMemberFlashBool( "canDrop", false );
		}
		
		flashObject.SetMemberFlashInt( "slotType", slotType );
		
		if( _inv.ItemHasTag(itemId, 'Edibles') && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats') )
		{
			flashObject.SetMemberFlashString( "iconPath",  "icons/inventory/food/food_dumpling_64x64.png" );
			flashObject.SetMemberFlashBool( "enchanted", true);
		}
		
		targetSlot = _inv.GetSlotForItemId( itemId );
		if( dyePreviewSlots.Size() > targetSlot )
		{
			dyeItemId = dyePreviewSlots[ targetSlot ];
			
			if( _inv.IsIdValid( dyeItemId ) )
			{
				dyeItemName = _inv.GetItemName( dyePreviewSlots[targetSlot] );
				flashObject.SetMemberFlashString( "itemColor", NameToString( dyeItemName ) );
				flashObject.SetMemberFlashBool( "isDyePreview", true );
			}
		}
		
	}
}