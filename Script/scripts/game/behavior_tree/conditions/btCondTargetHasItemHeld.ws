
class CBTCondTargetHasItemHeld extends IBehTreeTask
{
	public var itemCategory 				: name;
	public var alsoCheckIfHeldsAnything 	: bool;
	
	function IsAvailable() : bool
	{
		var i			: int;
		var target 		: CActor;
		var targetInv 	: CInventoryComponent;
		var items		: array<SItemUniqueId>;
		var weapon		: SItemUniqueId;
		
		target = GetCombatTarget();
		if ( !target ) return true;
		targetInv = target.GetInventory();
		if ( !targetInv ) return true;
		
		items = targetInv.GetItemsByCategory( itemCategory );
		
		if ( items.Size() > 0 )
		{
			for ( i = 0; i < items.Size() ; i += 1 )
			{
				if ( targetInv.IsItemHeld( items[i] ) )
				{
					return true;
				}
			}
		}
		
		if ( alsoCheckIfHeldsAnything && target.IsHuman() )
		{
			weapon = targetInv.GetItemFromSlot('r_weapon');
			
			if ( !targetInv.IsIdValid( weapon ) )
			{
				weapon = targetInv.GetItemFromSlot('l_weapon');
				
				if ( !targetInv.IsIdValid( weapon ) )
					return true;
			}
		}
			
		return false;
	}
};

class CBTCondTargetHasItemHeldDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondTargetHasItemHeld';

	editable var itemCategory 				: name;
	editable var alsoCheckIfHeldsAnything 	: bool;
	
	default itemCategory = 'fist';
	default alsoCheckIfHeldsAnything = true;
};