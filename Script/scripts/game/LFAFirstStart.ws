function LFASetDefaultOnFirstStart()
{
	var DefaultSet : bool;
	DefaultSet = theGame.GetInGameConfigWrapper().GetVarValue('LFAFirstStart', 'DefaultSet');
	
	if (!DefaultSet)
	{
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsHeavy', 'HAFastAttack', "-20");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsHeavy', 'HAStrongAttack', "-15");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsHeavy', 'HAWhirl', "-25");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsHeavy', 'HADodge', "-15");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsHeavy', 'HARoll', "-12");
		
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsMedium', 'MAFastAttack', "0");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsMedium', 'MAStrongAttack', "0");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsMedium', 'MAWhirl', "0");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsMedium', 'MADodge', "0");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsMedium', 'MARoll', "0");
		
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsLight', 'LAFastAttack', "10");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsLight', 'LAStrongAttack', "10");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsLight', 'LAWhirl', "15");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsLight', 'LADodge', "20");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorsLight', 'LARoll', "25");
				
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorResistance', 'ResistHeavy', "25");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorResistance', 'ResistMedium', "0");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorResistance', 'ResistLight', "-30");
		
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorPartsMultipliers', 'ChestPart', "50");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorPartsMultipliers', 'PantsPart', "30");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorPartsMultipliers', 'BootsPart', "10");
		theGame.GetInGameConfigWrapper().SetVarValue('LFArmorPartsMultipliers', 'GlovesPart', "10");
		
		theGame.GetInGameConfigWrapper().SetVarValue('LFAOverrideArmorType', 'overrideEnabled', "false");
		
		theGame.GetInGameConfigWrapper().SetVarValue('LFAFirstStart', 'DefaultSet', "true");
		
		theGame.SaveUserSettings();
	}
}
