/***********************************************************************/
/** Copyright © 2014
/** Author : Shadi Dadenji
/***********************************************************************/

class BTCondIsNPCGroupType extends IBehTreeTask
{
	var npcType : ENPCGroupType;

	
	function IsAvailable() : bool
	{
		var owner : CNewNPC = GetNPC();

		if ( owner.GetNPCType() == npcType )
		{
			return true;
		}
		
		return false;		
	}
}	


class BTCondIsNPCGroupTypeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsNPCGroupType';

	editable var npcType : ENPCGroupType;
	default npcType = ENGT_Commoner;
}