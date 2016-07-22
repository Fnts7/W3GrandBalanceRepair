class W3SE_UseRiddleNode extends W3SwitchEvent
{
	editable var riddleNodeTag : name;
	
	public function Perform( parnt : CEntity )
	{	
		var riddleNode : W3RiddleNode;
		
		riddleNode = (W3RiddleNode)theGame.GetEntityByTag ( riddleNodeTag );
		
		if ( riddleNode )
		{
			riddleNode.ChangePosition ();
		}
	}
}