//>--------------------------------------------------------------------------
// BTTaskIrisSpawn
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Manage spawn effects for Iris
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskIrisTask extends IBehTreeTask
{}
class BTTaskIrisSpawn extends BTTaskIrisTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	private var m_Painting : CEntity;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		var l_iris 		: 	W3NightWraithIris;
		
		l_iris = (W3NightWraithIris) GetNPC();
		
		m_Painting = (CEntity) l_iris.GetClosestPainting();
		
		// Removed this effect temporarly because it is the same that is used during the portal mechanic
		// and it is confusing
		//m_Painting.PlayEffect('ghost_appear');
		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		m_Painting.StopEffect('ghost_appear');
	}

}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskIrisSpawnDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisSpawn';
}