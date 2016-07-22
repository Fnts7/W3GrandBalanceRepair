
//Struct that stores competitor data for  W3LeaderboardCustom  class
struct SLeaderBoardData
{
	saved var competitor : string;
	saved var points 	 : int;
}

//Custom class for a dynamic poster of a leaderboard, used in sq701
statemachine class W3LeaderboardCustom  extends W3Poster
{

	editable saved var m_competitors		 : array<SLeaderBoardData>;
	editable var m_pointSymbolStringKey 	 : string;
	editable var m_displayPointsNumerically  : bool;
	editable var m_bottom_padding : int;
	editable var m_left_padding : int;
	
	//We want to update the poster every time it's interated with
	event OnInteraction( actionName : string, activator : CEntity )
	{
		GenerateDescription();
		
		super.OnInteraction( actionName, activator );
	}	
	
	//Generate description base on added competitors names and points
	private function GenerateDescription()
	{
		var i : int;
		var size : int;
		
		descriptionGenerated = true;
		
		description = "";
		
		size = m_competitors.Size();
		
		for( i=0; i < size; i+= 1 )
		{
			description += AddLeftPadding() + GetLocStringByKeyExt( m_competitors[i].competitor ) + " " + AddPointMarkersString( m_competitors[i].points ) +"<br>";	
		}
		
		if( m_bottom_padding > 0 )
		{
			description +=  AddBottomPadding();
		}
		
	}
	
	//Display points either as symbols or actual numerical value
	private function AddPointMarkersString( points : int ) : string
	{
		var i : int;
		var pointsString : string;
		
		if( m_displayPointsNumerically )
		{
			return points;
		}
		
		while( i < points )
		{
			pointsString += " "+ GetLocStringByKeyExt( m_pointSymbolStringKey ) +" ";
			i+=1;
		}
		
		return pointsString;
	}
	
	//Adds line breaks at the end to move text up
	private function AddBottomPadding() : string
	{
		var i : int;
		var padding : string;
		
		while( i < m_bottom_padding )
		{
			padding += "<br>";
			i+=1;
		}
		
		return padding;
	}	

	//Adds Spaces at the beginning of the line for arrangement
	private function AddLeftPadding() : string
	{
		var i : int;
		var padding : string;
		
		if( m_left_padding < 0 )
		{
			return "";
		}
		
		while( i < m_left_padding )
		{
			padding += "  ";
			i+=1;
		}
		
		return padding;
	}	
	
	//Change points of a competitor entry or create a new entry if it was not present yet
	public function AddPointToCompetitor( editedComptetitor : string, points : int )
	{
		var i : int;
		var size : int;
		var newEntry : SLeaderBoardData;
		
		size = m_competitors.Size();
		
		for( i=0; i < size; i+= 1 )
		{
			if( editedComptetitor == m_competitors[i].competitor )
			{
				m_competitors[i].points += points;
				return;
			}
		}	
		
		newEntry.competitor =  editedComptetitor;
		newEntry.points 	=  points;
		
		m_competitors.PushBack( newEntry );
		
	}
}