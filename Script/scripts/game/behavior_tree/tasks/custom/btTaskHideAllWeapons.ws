class CBTTaskHideAllWeapons extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		npc.SetRequiredItems( 'None', 'None' );
		npc.ProcessRequiredItems( true );
		return BTNS_Active;
	}
}
class CBTTaskHideAllWeaponsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHideAllWeapons';
}