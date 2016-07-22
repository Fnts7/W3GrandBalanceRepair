/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

abstract class W3SE_CustomScript extends W3SwitchEvent
{
	public editable var scriptID : string;
	
	hint scriptID = "Script ID to call (string)";
	
	private function Perform( parnt : CEntity )
	{
		LogChannel('Switch', "W3SE_CustomScript.Activate: custom switch script <<"+scriptID+">> is about to be called");
		//switch(scriptID)
		//	put your menace code here		
	}
}