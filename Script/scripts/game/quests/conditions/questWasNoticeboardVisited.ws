class W3QuestCond_WasNoticeboardVisited extends CQuestScriptedCondition
{
	editable var entityName : name;
	
	function Evaluate() : bool
	{
		var board : W3NoticeBoard;
		
		if ( !IsNameValid( entityName ) )
		{
			return false;
		}
		board = (W3NoticeBoard)theGame.GetEntityByTag( entityName );
		if ( !board )
		{
			return false;
		}
		return board.WasVisited();
	}
}