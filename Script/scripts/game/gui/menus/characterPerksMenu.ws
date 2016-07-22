/***********************************************************************/
/** Witcher Script file - character development : Perks
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4CharacterPerksMenu extends CR4MenuBase
{	
	var moduleId : int;

	event /*flash*/ OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		super.OnConfigUI();
		//theSound.SoundEvent( 'gui_global_panel_open' );  // #B sound - open
		
		UpdatePerks();
		UpdateBookPerks();
		
		UpdatePlayerStatisticsData();
	}

	function UpdatePerks()
	{/*
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var perks 					: array<SSkill>;
		var i : int;

		perks = GetWitcherPlayer().GetPlayerPerks();
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < perks.Size(); i += 1 )
		{
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			GetSkillGFxObject(perks[i], l_flashObject);
			l_flashArray.PushBackFlashObject(l_flashObject);
			
			/ *
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.SkillDataStub");
			l_flashObject.SetMemberFlashUInt("abilityName",NameToFlashUInt(perks[i].abilityName));
			l_flashObject.SetMemberFlashString("iconPath",perks[i].iconPath);
			l_flashObject.SetMemberFlashBool("acquired", perks[i].level > 0 );
			l_flashObject.SetMemberFlashBool("avialable",true);
			l_flashObject.SetMemberFlashBool("isNew",perks[i].isNew);
			l_flashObject.SetMemberFlashBool("isSkill",false);
			l_flashObject.SetMemberFlashInt("positonID",i); //@FIXME TK - now it's always zero, changed to index for a moment perks[i].positionID);
			l_flashArray.PushBackFlashObject(l_flashObject);
			* /			
		}
		m_flashValueStorage.SetFlashArray( "character.perks", l_flashArray );
		m_flashValueStorage.SetFlashString("character.perks.name",GetLocStringByKeyExt('panel_character_perks_name'));
		*/
	}
	
	function UpdateBookPerks()
	{/*
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var perks 					: array<SSkill>;
		var i : int;

		perks = GetWitcherPlayer().GetPlayerBookPerks();
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < perks.Size(); i += 1 )
		{		
			l_flashObject = m_flashValueStorage.CreateTempFlashObject();
			GetSkillGFxObject(perks[i], l_flashObject);
			
			/ *
			l_flashObject = m_flashValueStorage.CreateTempFlashObject("red.game.witcher3.menus.common.SkillDataStub");
			l_flashObject.SetMemberFlashUInt("abilityName",NameToFlashUInt(perks[i].abilityName));
			l_flashObject.SetMemberFlashString("iconPath",perks[i].iconPath);
			l_flashObject.SetMemberFlashBool("acquired", perks[i].level > 0 );
			l_flashObject.SetMemberFlashBool("avialable",true);
			l_flashObject.SetMemberFlashBool("isNew",perks[i].isNew);
			l_flashObject.SetMemberFlashBool("isSkill",false);
			l_flashObject.SetMemberFlashInt("positonID",i); //@FIXME TK - now it's always zero, changed to index for a moment perks[i].positionID);
			* /
			
			l_flashArray.PushBackFlashObject(l_flashObject);
		}
		m_flashValueStorage.SetFlashArray( "character.books", l_flashArray );
		m_flashValueStorage.SetFlashString("character.books.name",GetLocStringByKeyExt('panel_character_bookperks_name'));
		*/
	}
	
	protected function GetSkillGFxObject(curSkill : SSkill, out dataObject : CScriptedFlashObject) : void
	{
		dataObject.SetMemberFlashInt('id', curSkill.skillType); // tooltip key field
		dataObject.SetMemberFlashInt('skillTypeId', curSkill.skillType);
		dataObject.SetMemberFlashInt('level', GetWitcherPlayer().GetSkillLevel(curSkill.skillType));
		
		dataObject.SetMemberFlashString('skillType', curSkill.skillType);
		dataObject.SetMemberFlashString('skillPath', curSkill.skillPath);
		
		dataObject.SetMemberFlashString('cost', curSkill.cost);
		dataObject.SetMemberFlashString('iconPath', curSkill.iconPath);
		dataObject.SetMemberFlashString('positionID', curSkill.positionID);
		
		//dataObject.SetMemberFlashString('skillSubPath', curSkill.skillSubPath);
		//dataObject.SetMemberFlashString('abilityName', curSkill.abilityName);		
		//dataObject.SetMemberFlashString('isCoreSkill', curSkill.isCoreSkill);
		//dataObject.SetMemberFlashInt('maxLevel', curSkill.maxLevel);
		//dataObject.SetMemberFlashString('dropDownLabel', curSkill.skillPath);
		//dataObject.SetMemberFlashString('color', skillColor);
		//dataObject.SetMemberFlashBool('updateAvailable', CheckIfAvailable(curSkill));
		//dataObject.SetMemberFlashBool('notEnoughPoints', ( GetCurrentSkillPoints() <= 0 ));
		dataObject.SetMemberFlashBool('isEquipped', thePlayer.IsSkillEquipped(curSkill.skillType));
	}

	function UpdatePlayerStatisticsData()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var attackPower, spellPower	: SAbilityAttributeValue;
		var id						: SItemUniqueId;
		
		var value 					: int;
		var valueFloat 				: float;
		
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetBaseStatLocalizedName(BCS_Vitality));
		l_flashObject.SetMemberFlashString("icon","Vitality");
		l_flashObject.SetMemberFlashString("value", RoundMath(thePlayer.GetStatMax(BCS_Vitality)));
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetBaseStatLocalizedName(BCS_Stamina));
		l_flashObject.SetMemberFlashString("icon","Stamina");
		l_flashObject.SetMemberFlashString("value", RoundMath(thePlayer.GetStatMax(BCS_Stamina)));
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetRegenStatLocalizedName(CRS_Vitality));
		l_flashObject.SetMemberFlashString("icon","Vitality Regeneration");		
		l_flashObject.SetMemberFlashString("value", NoTrailZeros(RoundTo(CalculateAttributeValue(thePlayer.GetAttributeValue(RegenStatEnumToName(CRS_Vitality))),1)) +" /s");
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetRegenStatLocalizedName(CRS_Stamina));
		l_flashObject.SetMemberFlashString("icon","Stamina regeneration");
		l_flashObject.SetMemberFlashString("value", NoTrailZeros(RoundTo(CalculateAttributeValue(thePlayer.GetAttributeValue(RegenStatEnumToName(CRS_Stamina))),1)) +" /s");
		l_flashArray.PushBackFlashObject(l_flashObject);
		/*
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt("Armor"));
		l_flashObject.SetMemberFlashString("icon","Armor");
		l_flashObject.SetMemberFlashString("value","X %");
		l_flashArray.PushBackFlashObject(l_flashObject);
		*/
		
		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetPowerStatLocalizedName(CPS_AttackPower));
		l_flashObject.SetMemberFlashString("icon","Attack power");
		attackPower = thePlayer.GetPowerStatValue(CPS_AttackPower);
		l_flashObject.SetMemberFlashString("value",RoundMath(attackPower.valueMultiplicative*100) + " %");
		l_flashArray.PushBackFlashObject(l_flashObject);
		
		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetPowerStatLocalizedName(CPS_SpellPower));
		l_flashObject.SetMemberFlashString("icon","Spell power");
		spellPower = thePlayer.GetPowerStatValue(CPS_AttackPower);
		l_flashObject.SetMemberFlashString("value",RoundMath(spellPower.valueMultiplicative*100) + " %");
		l_flashArray.PushBackFlashObject(l_flashObject);

		//-- steel sword damages (steel + silver + elemental)
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt("Steel sword damage")); // #B ??
		l_flashObject.SetMemberFlashString("icon","Steel sword damage");		
		if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, id))
		{
			l_flashObject.SetMemberFlashString("value", GetWeaponDamageStats(id, attackPower));
		}
		else
		{
			//if no sword equipped
			l_flashObject.SetMemberFlashString("value","-");
		}
		l_flashArray.PushBackFlashObject(l_flashObject);

		//-- silver sword damages (steel + silver + elemental)
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString("name",GetLocStringByKeyExt("Silver sword damage")); // #B ??
		l_flashObject.SetMemberFlashString("icon","Silver sword damage");		
		if(GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, id))
		{
			l_flashObject.SetMemberFlashString("value", GetWeaponDamageStats(id, attackPower));
		}
		else
		{
			//if no sword equipped
			l_flashObject.SetMemberFlashString("value","-");
		}
		l_flashArray.PushBackFlashObject(l_flashObject);
		
		m_flashValueStorage.SetFlashArray( "playerstats.stats", l_flashArray );
		m_flashValueStorage.SetFlashString( "playerstats.stats.name", GetLocStringByKeyExt("panel_common_statistics_name"));
	}
	
	function UpdateStatsTooltip( statName : string ) //@FIXME BIDON - there is no localisation here
	{
		m_flashValueStorage.SetFlashString("inventory.stats.title",statName);
		m_flashValueStorage.SetFlashString("inventory.stats.description",statName+"description");
	}
	
	
	event /*flash*/ OnGetSkillTooltipData(skillType : ESkill, compareItemType : int)
	{
		var resultGFxData 	: CScriptedFlashObject;
		var skillDisplayName : string;
		var skillDisplayDescription : string;
		var skillTemp : SSkill;
		
		/*switch(moduleId)
		{
			case 0:
				skillDisplayName = GetLocStringByKeyExt(GetWitcherPlayer().GetPerkLocalisationKeyName(skillType));
				skillTemp = GetWitcherPlayer().GetPlayerPerk(skillType);
				if(skillTemp.level > 0)
				{
					skillDisplayDescription = GetLocStringByKeyExt(GetWitcherPlayer().GetPerkLocalisationKeyDescription(skillType));
				}
				else
				{
					skillDisplayDescription = GetLocStringByKeyExt(GetWitcherPlayer().GetPerkLocalisationKeyDescriptionNotAcquired(skillType));
				}
				break;
			case 1:
				skillDisplayName = GetLocStringByKeyExt(GetWitcherPlayer().GetBookPerkLocalisationKeyName(skillType));
				skillTemp = GetWitcherPlayer().GetPlayerBookPerk(skillType);
				if(skillTemp.level > 0)
				{
					skillDisplayDescription = GetLocStringByKeyExt(GetWitcherPlayer().GetBookPerkLocalisationKeyDescription(skillType));
				}
				else
				{
					skillDisplayDescription = GetLocStringByKeyExt(GetWitcherPlayer().GetBookPerkLocalisationKeyDescriptionNotAcquired(skillType));
				}
				break;
		}*/
		resultGFxData = m_flashValueStorage.CreateTempFlashObject();
		resultGFxData.SetMemberFlashString('skillName', GetLocStringByKeyExt(skillTemp.localisationNameKey));
		resultGFxData.SetMemberFlashString('skillDescription', GetLocStringByKeyExt(skillTemp.localisationDescriptionKey));
		resultGFxData.SetMemberFlashString('skillLevel', GetWitcherPlayer().GetSkillLevel(skillTemp.skillType) + "/"+skillTemp.maxLevel);
		resultGFxData.SetMemberFlashString('IconPath', skillTemp.iconPath);
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultGFxData);
	}
	
	private function GetWeaponDamageStats(id : SItemUniqueId, attackPower : SAbilityAttributeValue) : string
	{
		var durabilityModifier, silverDamage, steelDamage, elementalDamage : float;
		var retString : string;
	
		//get durability modifier
		durabilityModifier = theGame.params.GetDurabilityMultiplier(thePlayer.inv.GetItemDurabilityRatio(id), true);
	
		//get raw weapon damages
		steelDamage = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_PHYSICAL));
		steelDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_SLASHING));
		steelDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_PIERCING));
		steelDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_BLUDGEONING));
		silverDamage = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_SILVER));
		
		elementalDamage = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_FIRE));
		elementalDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_FROST));
		elementalDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_POISON));
		elementalDamage += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(id, theGame.params.DAMAGE_NAME_SHOCK));
					
		//apply attack power & durability modifiers
		steelDamage = MaxF(0, (steelDamage + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive);
		steelDamage *= durabilityModifier;			
		
		silverDamage = MaxF(0, (silverDamage + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive);
		silverDamage *= durabilityModifier;
		
		elementalDamage = MaxF(0, (elementalDamage + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive);
		elementalDamage *= durabilityModifier;
		
		//get final string
		retString = RoundF(steelDamage) + " + " + RoundF(silverDamage);
		if(elementalDamage > 0)
			retString += " + " + RoundF(elementalDamage);
			
		return  retString;
	}
	
	event /*flash*/ OnCloseMenu()
	{
		if( m_parentMenu )
		{
			m_parentMenu.OnCloseMenu();
		}
		theSound.SoundEvent( 'gui_global_quit' ); // #B sound - quit
		CloseMenu();
	}

	event /*flash*/ OnUpdateCharacterButtons( skillName : string )
	{
		//UpdateStatsTooltip(statName);
	}		
	
	event /*flash*/ OnCharacterTabSelected( id : int )
	{
		m_flashValueStorage.SetFlashInt("character.tab.mode",id,-1);
	}
	
	event /*flash*/ OnModuleSelected(  moduleID : int, optional moduleBindingName : string )
	{
		super.OnModuleSelected(  moduleID, moduleBindingName );
		switch(moduleBindingName)
		{
			case "character.perks" :
				moduleId = 0;
				break;
			case "character.books" :
				moduleId = 1;
				break;
			default:
				return false;
		}
	}	
	
	event /*flash*/ OnPlaySound( soundKey : string )
	{
		theSound.SoundEvent( soundKey );
	}
}
