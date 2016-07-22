/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

enum EFactOperation
{
	FO_AddFact,
	FO_RemoveFact
}

class W3SE_Fact extends W3SwitchEvent
{
	editable var fact		: string;	
	editable var operation	: EFactOperation;	
	editable var value		: int;					default value = 1;
	editable var validFor	: int;					default validFor = -1;
	
	public function Perform( parnt : CEntity )
	{	
		if( StrLen( fact ) > 0 )
		{
			switch (operation)
			{
			case FO_AddFact:
				FactsAdd( fact, value, validFor );
				break;
			case FO_RemoveFact:
				FactsRemove( fact );
				break;
			}
		}
	}
}