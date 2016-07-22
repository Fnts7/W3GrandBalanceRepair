//>--------------------------------------------------------------------------
// BTTaskIrisRequestPortal
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskIrisRequestPortal extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLE
	//-----------------------------------------------------------------------
	public 	var onDeactivate 	: bool;	
	public 	var onAnimEvent 	: CName;
	
	private var m_Npc 			: W3NightWraithIris;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( !onDeactivate && !IsNameValid( onAnimEvent ) )
			Request();
		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		if( onDeactivate )
			Request();
			
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function Request()
	{
		m_Npc = (W3NightWraithIris) GetNPC();		
		m_Npc.RequestPortal();	
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{		
		if ( animEventName == onAnimEvent )
		{
			Request();
			return true;
		}
		return true;
	}
}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskIrisRequestPortalDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisRequestPortal';
	
	private editable var onDeactivate : bool;
	private editable var onAnimEvent  : CName;
}