/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Encounter System
/** Copyright © 2010-2013
/***********************************************************************/

import class CSpawnTreeEntrySubDefinition extends CObject
{
	import var creatureDefinition 	: name;
	import var partyMemberId 		: name;
}
import class CPartySpawnOrganizer extends IScriptable
{
}
import class CInstantMountPartySpawnOrganizer extends CPartySpawnOrganizer
{
}
import class CCreaturePartyEntry extends CBaseCreatureEntry
{
	import var partySpawnOrganizer : CPartySpawnOrganizer;
	
	import function AddPartyMember( inEditor : bool ) : CSpawnTreeEntrySubDefinition;

	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "Add rider + horse in party" );
	}
	
	function RunSpecialOption( option : int )
	{
		var horseMember : CSpawnTreeEntrySubDefinition;
		var riderMember : CSpawnTreeEntrySubDefinition;
		
		horseMember = AddPartyMember( true );
		riderMember = AddPartyMember( true );
		
		
		horseMember.creatureDefinition 	= 'horse_def';
		riderMember.creatureDefinition 	= 'rider_def';
		horseMember.partyMemberId 		= 'horse';
		riderMember.partyMemberId 		= 'rider';
		
		partySpawnOrganizer = new CInstantMountPartySpawnOrganizer in this;
	}
}
