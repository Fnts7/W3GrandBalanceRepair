function AddHitFacts( victimTags : array<name>, attackerTags : array<name>, hitType : string, optional validForever : bool, optional prefix : string )
{
	var i, j, sizeV, sizeA, oneSec, dur : int;
	var strV : string;
	var canLog : bool;
	
	canLog = theGame.CanLog();
	sizeV = victimTags.Size();
	sizeA = attackerTags.Size();
	
	if ( validForever )
	{
		dur = -1;
	}
	else
	{
		dur = 1;
	}
	
	for(i=0; i<sizeV; i+=1)
	{
		strV = prefix + NameToString(victimTags[i]) + hitType;
		
		if ( canLog )
		{
			LogFacts(strV);
		}
		FactsAdd(strV, 1, dur);
		
		for( j = 0; j < sizeA; j += 1)
		{
			if ( canLog )
			{
				LogFacts( strV + "_by_" + NameToString(attackerTags[j]) );
			}
			FactsAdd( strV + "_by_" + NameToString(attackerTags[j]), 1, 1 );	//not only for weapons but for all actor attacks
		}
	}
}