class CBTTaskChangeCaranthirStaff extends IBehTreeTask
{
	private var wasActivated		: bool;
	private var startEffect			: bool;
	
	default wasActivated = false;
		
	function IsAvailable() : bool
	{
		return !wasActivated;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		ChangeAppearance();
		return BTNS_Active;
	}
	
	
	function ChangeAppearance()
	{
		var Caranthir : CNewNPC;
		var staff : CEntity;
			
		Caranthir = theGame.GetNPCByTag('Caranthir');
		staff = Caranthir.GetInventory().GetItemEntityUnsafe( Caranthir.GetInventory().GetItemFromSlot( 'r_weapon' ) );
		if( startEffect )
		{
			if ( staff )
			{
				staff.PlayEffect( 'fx_staff_gameplay');
				wasActivated = true;
			}
			else
			{
				wasActivated = false;
			}
		}
		else
		{
			if ( staff )
			{	
				staff.StopEffect('fx_staff_gameplay');
				staff.ApplyAppearance( 'broken' );
				wasActivated = true;
			}
			else
			{
				wasActivated = false;
			}
		}

	}

}

class CBTTaskChangeCaranthirStaffDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangeCaranthirStaff';
	editable var startEffect				:bool;

}