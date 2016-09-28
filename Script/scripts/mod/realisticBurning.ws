//////////////////////////////////////////////////////
///// Grand Balance Repair Realistic Burning /////////
//////////////////////////////////////////////////////

function GBRGetFireResist(npc : CNewNPC, baseResistOnly : bool, out resistPerc : float)
{
	var level : int;
	var category : name;
	var stats : CCharacterStats;
	var min, max : SAbilityAttributeValue;
	var dm : CDefinitionsManagerAccessor;
	var definitionResist, configRes : float;
	var configWrapper : CInGameConfigWrapper;
	
	level = npc.GetLevelFromLocalVar();
	if (level < 1)
		return;
	stats = npc.GetCharacterStats();

	if (stats.HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL))
		category = theGame.params.ENEMY_BONUS_PER_LEVEL;
	else if (stats.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP))
		category = theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP;
	else if (stats.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL))
		category = theGame.params.MONSTER_BONUS_PER_LEVEL;
	else if (stats.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED))
		category = theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED;
	else if (stats.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED))
		category = theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED;
	else
		return;

	dm = theGame.GetDefinitionsManager();
	dm.GetAbilityAttributeValue(category, 'burning_resistance_perc', min, max);
	definitionResist = CalculateAttributeValue(min);

	resistPerc -= definitionResist * level;
	
	if (resistPerc >= 1.0f || baseResistOnly)
		return;

	// Apply fixed burning resist
	configWrapper = theGame.GetInGameConfigWrapper();
	configRes = StringToFloat(configWrapper.GetVarValue('GBRRealisticBurning', 'FixedBurnResist')) / 100;
	resistPerc = resistPerc + (1.0f - resistPerc) * configRes;

	if (resistPerc >= 1.0f)
		return;

	// Apply category per level burning resist
	switch (category)
	{
	case theGame.params.ENEMY_BONUS_PER_LEVEL:
		configRes = StringToFloat(configWrapper.GetVarValue('GBRRealisticBurning', 'HumanBurnResist')) / 100;
		break;
	case theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP:
		configRes = StringToFloat(configWrapper.GetVarValue('GBRRealisticBurning', 'GroupMonsterBurnResist')) / 100;
		break;
	case theGame.params.MONSTER_BONUS_PER_LEVEL:
		configRes = StringToFloat(configWrapper.GetVarValue('GBRRealisticBurning', 'MonsterBurnResist')) / 100;
		break;
	case theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED:
		configRes = StringToFloat(configWrapper.GetVarValue('GBRRealisticBurning', 'GroupArmoredMonsterBurnResist')) / 100;
		break;
	case theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED:
		configRes = StringToFloat(configWrapper.GetVarValue('GBRRealisticBurning', 'ArmoredMonsterBurnResist')) / 100;
		break;
	}
	
	resistPerc = resistPerc + (1.0f - resistPerc) * GBRCalculateResist(level, configRes);
}

function GBRCalculateResist(level : int, maxResist : float) : float
{
	var step1, step2 : float;

	step2 = 0.75f * maxResist;
	step1 = 0.1f * maxResist;

	if (level < 10)
		return step1 * level / 10;
	else if (level < 50)
		return step1 + (step2 - step1) * (level - 10) / 40;
	else if (level < 100)
		return step2 + (maxResist - step2) * (level - 50) / 50;
	else
		return maxResist;
}
