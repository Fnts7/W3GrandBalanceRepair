/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Play sound event
/** Copyright © 2014 - Shadi Dadenji
/***********************************************************************/

enum ENPCType
{
	ENT_AdultMale,
	ENT_AdultFemale,
	ENT_ChildMale,	
	ENT_ChildFemale
}

class CBTTaskPlayHorseBumpSound extends IBehTreeTask
{		
	var actor 		: CActor;

	
	function IsAvailable() : bool
	{
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{		
		actor 	= GetActor();
		
		if( actor )
		{
			switch ( GetNPCType() )
			{
				case ENT_AdultMale:
					actor.SoundEvent("grunt_vo_test_reaction_AdultMale", 'head');
					break;
				
				case ENT_AdultFemale:
					actor.SoundEvent("grunt_vo_test_reaction_AdultFemale", 'head');
					break;
				
				case ENT_ChildMale:
					actor.SoundEvent("grunt_vo_test_reaction_ChildMale", 'head');
					break;
			
				case ENT_ChildFemale:
					actor.SoundEvent("grunt_vo_test_reaction_ChildFemale", 'head');
					break;

				default:
					return BTNS_Failed;				
			}
	
			return BTNS_Completed;	
		}
		
		return BTNS_Failed;
	}
	
	function GetNPCType() : ENPCType
	{
		var actor			: CActor;
		var voiceTagName 	: name;
		var voiceTagStr		: string;
		var appearanceName 	: name;
		var appearanceStr	: string;
		
		actor = GetActor();
		if ( actor.IsWoman() )
			return ENT_AdultFemale;
			
		if ( actor.IsMan() )
			return ENT_AdultMale;
			
		voiceTagName =  actor.GetVoicetag();
		voiceTagStr = NameToString( voiceTagName );
		if ( StrFindFirst(voiceTagStr, "BOY") >= 0 )
			return ENT_ChildMale;
		
		if ( StrFindFirst(voiceTagStr, "GIRL") >= 0 )
			return ENT_ChildFemale;
		
		appearanceName =  actor.GetAppearance();
		appearanceStr = NameToString( appearanceName );
		if ( StrFindFirst(appearanceStr, "BOY") >= 0 )
			return ENT_ChildMale;
		
		if ( StrFindFirst(appearanceStr, "GIRL") >= 0 )
			return ENT_ChildFemale;
		
		return ENT_AdultMale;
	}
}

class CBTTaskPlayHorseBumpSoundDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayHorseBumpSound';
}

