/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

enum EQuestPlayerSkillLevel
{
	EQPSL_Skill,
	EQPSL_DialogAxiiLevel
}

enum EQuestPlayerSkillCondition
{
	EQPSC_Equipped,
	EQPSC_Learned,
	EQPSC_LearnedButNotEquipped
}

struct SQuestPlayerSkill
{
	editable var skill : ESkill;
	editable var skillLevel : int;
	editable var condition : EQuestPlayerSkillCondition;
};

class W3QuestCond_PlayerSkillLevel extends CQuestScriptedCondition
{
	editable var mode : EQuestPlayerSkillLevel;
	editable var skills : array<SQuestPlayerSkill>;
	editable var dialogAxiiLevel : int;
	
	hint mode = "Choose between skill level check and Dialog Axii Level check";

	function Evaluate() : bool
	{	
		var witcher : W3PlayerWitcher;
		var isSkill, isEquipped, knowsSkill : bool;
		var i: int;
	
		witcher = GetWitcherPlayer();
		
		if(mode == EQPSL_DialogAxiiLevel)
		{
			return witcher.GetAxiiLevel() >= dialogAxiiLevel;
		}
		else
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				//first check if skill is known at all
				knowsSkill = witcher.HasLearnedSkill(skills[i].skill);
				
				if(!knowsSkill)
					return false;
				
				//then check equip
				isEquipped = witcher.IsSkillEquipped(skills[i].skill);
			
				if(skills[i].condition == EQPSC_Equipped)
				{
					if(!isEquipped)
						return false;
				}
				else if(skills[i].condition == EQPSC_LearnedButNotEquipped)
				{
					if(isEquipped)
						return false;
				}
				
				//then check level
				if(witcher.GetSkillLevel(skills[i].skill) < skills[i].skillLevel)
					return false;
			}
			
			return true;
		}
	}
}