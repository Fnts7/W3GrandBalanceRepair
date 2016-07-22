/***********************************************************************/
/** Copyright © 2012
/** Author : Rafal Jarczewski
/***********************************************************************/

/**
	a condition embedded in a CQuestActorCondition
*/
import abstract class CQCActorScriptedCondition extends IActorConditionType
{
	function Evaluate( actor : CActor ) : bool;
}