/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3QuestCond_DialogChoiceCondition extends CQuestScriptedCondition
{
	private editable var dialogChoice : EDialogActionIcon;
	private editable var onOptionSelected : bool;		//triggered when the option is selected instead of shown
	
	function Evaluate() : bool
	{	
		var flags, set : int;
		
		//if no (dialog or cutscene) or cutscene => no dialog, so abort
		if(!theGame.IsDialogOrCutscenePlaying() || theGame.isCutscenePlaying)
			return false;
			
		//check if flag is set
		if(onOptionSelected)
		{
			//chosen option
			set = GameplayFactsQuerySum('dialog_used_choice_is_set');
		}
		else
		{
			//displayed option
			set = GameplayFactsQuerySum('dialog_choice_is_set');
		}
		
		if(set <= 0)
			return false;		//no data set
		
		if(dialogChoice == 0)
		{
			//wait for anything
			return true;
		}
		else
		{
			if(onOptionSelected)
			{
				//chosen option
				flags = GameplayFactsQuerySum('dialog_used_choice_flags');
			}
			else
			{
				//displayed option
				flags = GameplayFactsQuerySum('dialog_choice_flags');
			}
			
			return flags & dialogChoice;
		}
	}
}