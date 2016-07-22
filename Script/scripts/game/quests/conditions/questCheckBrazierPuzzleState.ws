/***********************************************************************/
/** Copyright © 2014
/** Author : Shadi Dadenji
/***********************************************************************/

class W3QuestCond_CheckBrazierPuzzleState extends CQuestScriptedCondition
{
	editable var lightList 		: array<name>;
	editable var lightsToTurnOn : array<int>;

	var componentList 	: array<CComponent>;
	var expectedState  	: array<bool>;

	var componentsFound : bool;
	var statesDefined	: bool;


	function Activate()
	{	
		componentsFound = false;
		statesDefined	= false;
		
		expectedState.Resize(lightList.Size());
	}

	
	function Evaluate() : bool
	{
		var entity 			: CEntity;
		var component 		: CComponent;
		var lightState  	: bool;
		var checksPassed 	: int = 0;

		var i : int;
		var j : int;
			

		//get all required components 1st; if any of the components are null, we immediately return false and start querying again
		if ( !componentsFound )
		{
			for (i = 0; i < lightList.Size(); i+=1)
			{
				entity = theGame.GetEntityByTag(lightList[i]);
				if ( !entity )
					return false;
				
				component = entity.GetComponentByClassName('CGameplayLightComponent');
				if ( !component )
					return false;

				componentList.PushBack( component );
			}
			
			//at this point, we know we have all valid components
			componentsFound = true;
		}

		//figure out what the expected state is for each entity in the list
		if ( !statesDefined )
		{
			for (i = 0; i < lightList.Size(); i+=1)
			{
				for (j = 0; j < lightsToTurnOn.Size(); j+=1)
				{
					if (i == lightsToTurnOn[j])
					{
						expectedState[i] = true;
						break;
					}
					else
						expectedState[i] = false;
				}
			}

			//do this process only once
			statesDefined = true;
		}

		//query light states and pass on the signal if all states are as expected
		for (i = 0; i < componentList.Size(); i+=1)
		{		
			lightState = ((CGameplayLightComponent)componentList[i]).IsLightOn();

			if (lightState == expectedState[i])
				checksPassed+=1;
		}

		if (checksPassed == lightList.Size())
			return true;

		return false;
	}
}
