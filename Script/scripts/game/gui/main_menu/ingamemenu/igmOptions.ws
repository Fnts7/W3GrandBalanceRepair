﻿/***********************************************************************/
/** Witcher Script file - Various Utilities for ingame menu that don't need to be in the menu itself
/***********************************************************************/
/** Copyright © 2015 CDProjektRed
/** Author : Jason Slama
/***********************************************************************/

function IngameMenu_GetOptionTypeFromString(optionType:string): InGameMenuActionType
{
	if (optionType == "TOGGLE")
	{
		return IGMActionType_Toggle;
	}
	else if (optionType == "SLIDER")
	{
		return IGMActionType_Slider;
	}
	else if (optionType == "OPTIONS")
	{
		return IGMActionType_List;
	}
	else if (optionType == "GAMMA")
	{
		return IGMActionType_Gamma;
	}
	
	return IGMActionType_Toggle; // #J Reasonable default
}

function IngameMenu_FillOptionsSubMenuData(flashStorageUtility : CScriptedFlashValueStorage, isMainMenu : bool) : CScriptedFlashArray
{
	var l_optionChildList		: CScriptedFlashArray;
	var i 						: int;
	var numOptionsGroups		: int;
	var l_ChildMenuFlashArray	: CScriptedFlashArray;
	var l_DataFlashObject 		: CScriptedFlashObject;
	var groupRootObject			: CScriptedFlashObject;
	var groupOptionArray		: CScriptedFlashArray;
	var groupParentArray		: CScriptedFlashArray;
	var groupName				: name;
	var videoDisplayName		: string;
	var dlcGroupID				: int = -1;
	var inGameConfigWrapper 	: CInGameConfigWrapper;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	l_optionChildList = flashStorageUtility.CreateTempFlashArray();
	
	// Pre-generating option groups to control their order. All dynamic ones (such as options) will be appended after
	// ======================================================================================================================================================
	IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", "audio", l_optionChildList, groupParentArray);
	IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", "option_controllerhelp", l_optionChildList, groupParentArray);
		
	// --------------------------------- Controller Help ---------------------------------
	{
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "option_control_scheme");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('controllerhelp') );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("menu_option_control_scheme") );	
		//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_controllerhelp_description") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_ControllerHelp );	
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
	}
	
	// --------------------------------- keybinds ---------------------------------
	if (theGame.GetPlatform() == Platform_PC)
	{
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "option_keybinds");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('controllerhelp') );
		l_DataFlashObject.SetMemberFlashString(  "label", inGameMenu_TryLocalize("menu_option_keybinds") );	
		//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_controllerhelp_description") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_KeyBinds );	
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
	}
	
	IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", "gameplay", l_optionChildList, groupParentArray);
	if (theGame.GetPlatform() == Platform_PC)
	{
		videoDisplayName = "video";
	}
	else
	{
		videoDisplayName = "visuals";
	}
	IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", videoDisplayName + ".hudelements", l_optionChildList, groupParentArray);
	// --------------------------------- UIRescale ---------------------------------
	// #J for consoles the folder is called visuals, on PC its called video, so we check for both
	if (GetObjectFromArrayWithLabel(l_optionChildList, "id", videoDisplayName, groupRootObject))
	{
		groupOptionArray = groupRootObject.GetMemberFlashArray("subElements");
		
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "uirescale");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('UI_Rescale') );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_rescale") );	
		//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_rescale_description") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_UIRescale );	
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		groupOptionArray.PushBackFlashObject(l_DataFlashObject);
	}
	if (theGame.GetPlatform() == Platform_PC)
	{
		IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", "video.postprocess", l_optionChildList, groupParentArray);
		IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", "video.general", l_optionChildList, groupParentArray);
	}
	
	if (isMainMenu)
	{
		IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", "localization", l_optionChildList, groupParentArray);
	}
	// ======================================================================================================================================================
	
	
	// --------------------------------- InGameConfig Stuff ---------------------------------
	numOptionsGroups = inGameConfigWrapper.GetGroupsNum();
	
	for (i = 0; i < numOptionsGroups; i += 1)
	{
		groupName = inGameConfigWrapper.GetGroupName(i);
		
		if (groupName == 'DLC') // Forcing DLC last
		{
			dlcGroupID = i;
		}
		else
		{
			IngameMenu_FillArrayFromConfigGroup(flashStorageUtility, i, l_optionChildList);
		}
	}
	// ======================================================================================================================================================
	
	if (isMainMenu)
	{
		// --------------------------------- Credits ---------------------------------
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "credits");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Wither3 );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_extras_credits") );	
		//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_credits_description") );
		l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("panel_mainmenu_extras_credits") );
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		
		if ( theGame.GetDLCManager().IsEP1Available() || theGame.GetDLCManager().IsEP2Available() )
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			IngameMenu_FillCreditsSubGroup(flashStorageUtility, l_ChildMenuFlashArray);
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
		}
		
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		// ======================================================================================================================================================
	}
	else
	{
		// -------------------------------- Difficulty Option ---------------------------
		if (GetObjectFromArrayWithLabel(l_optionChildList, "id", "gameplay", groupRootObject))
		{
			groupOptionArray = groupRootObject.GetMemberFlashArray("subElements");
			IngameMenu_AddDifficultyOption(flashStorageUtility, groupOptionArray);
			IngameMenu_AddGwentDifficultyOption(flashStorageUtility, groupOptionArray);
		}
		// ======================================================================================================================================================
	}
	
	// --------------------------------- DLC ----------------------------------------
	//if (dlcGroupID != -1)
	//{
	//	IngameMenu_FillArrayFromConfigGroup(flashStorageUtility, dlcGroupID, l_optionChildList);
	//}
	
	return l_optionChildList;
}

function IngameMenu_FillCreditsSubGroup(flashStorageUtility : CScriptedFlashValueStorage, rootFlashArray:CScriptedFlashArray):void
{
	var l_ChildMenuFlashArray	: CScriptedFlashArray;
	var l_DataFlashObject 		: CScriptedFlashObject;
	
	// --------------------------------- Credits ---------------------------------
	l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
	l_DataFlashObject.SetMemberFlashString( "id", "credits_witcher");
	l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Wither3 );
	l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("TW3") );	
	//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_credits_description") );
	l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
	
	l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
	l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
	
	rootFlashArray.PushBackFlashObject(l_DataFlashObject);
	// ======================================================================================================================================================
	
	if (theGame.GetDLCManager().IsEP1Available())
	{
		// --------------------------------- Credits ---------------------------------
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "credits_heart_of_stone");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Ep1 );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("dlc_hearts_of_stone") );	
		//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_credits_description") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		rootFlashArray.PushBackFlashObject(l_DataFlashObject);
		// ======================================================================================================================================================
	}
	
	if ( theGame.GetDLCManager().IsEP2Available() )
	{
		// --------------------------------- Credits ---------------------------------
		l_DataFlashObject = flashStorageUtility.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "credits_blood_and_wine");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", CreditsIndex_Ep2 );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("dlc_blood_and_wine") );	
		//l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_credits_description") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Credits );	
		
		l_ChildMenuFlashArray = flashStorageUtility.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		rootFlashArray.PushBackFlashObject(l_DataFlashObject);
		// ======================================================================================================================================================
	}
}

function IngameMenu_FillArrayFromConfigGroup(flashStorageUtility : CScriptedFlashValueStorage, groupID:int, rootFlashArray:CScriptedFlashArray):void
{
	var groupRootObject			: CScriptedFlashObject;
	var groupName				: name;
	var hasChildOptions			: bool;
	var groupParentArray		: CScriptedFlashArray;
	var inGameConfigWrapper	: CInGameConfigWrapper;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	groupName = inGameConfigWrapper.GetGroupName(groupID);
	
	if (groupName != 'Hidden' && inGameConfigWrapper.IsGroupVisible(groupName) && !inGameConfigWrapper.DoGroupHasTag(groupName, 'keybinds'))
	{
		groupRootObject = IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility, "panel_", inGameConfigWrapper.GetGroupDisplayName(groupName), rootFlashArray, groupParentArray);
		
		if (groupRootObject)
		{
			hasChildOptions = IngameMenu_FillSubMenuOptionsList(flashStorageUtility, groupID, groupName, groupRootObject);
			
			// If all the options in the group turn out to be hidden, remove it from the list
			if (!hasChildOptions && groupParentArray)
			{
				groupParentArray.PopBack();
			}
		}
	}
}

function IngameMenu_FetchAndGenerateGroupMenuObject(flashStorageUtility : CScriptedFlashValueStorage, displayNamePrefix:string, groupDisplayName:string, rootFlashArray:CScriptedFlashArray, out optionParentArray:CScriptedFlashArray):CScriptedFlashObject
{
	var displayNameArray 	: string;
	var newChildArray 		: CScriptedFlashArray;
	var tokenedDisplayNames	: array<string>;
	var deconstructedString : string;
	var currentSubMenuName	: string;
	var tmp					: string;
	var currentArray		: CScriptedFlashArray;
	var currentObject		: CScriptedFlashObject;
	
	var inGameConfigWrapper	: CInGameConfigWrapper;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	deconstructedString = groupDisplayName;
	currentArray = rootFlashArray;
	
	while (deconstructedString != "")
	{
		currentSubMenuName = "";
		
		StrSplitFirst(deconstructedString, ".", currentSubMenuName, tmp);
		
		if (currentSubMenuName == "" && deconstructedString != "")
		{
			currentSubMenuName = deconstructedString;
		}
		
		deconstructedString = tmp;
		tmp = "";
		
		while (StrBeginsWith(deconstructedString, "."))
		{
			StrReplace(deconstructedString, ".", "");
		}
		
		if (GetObjectFromArrayWithLabel(currentArray, "id", currentSubMenuName, currentObject))
		{
			currentArray = currentObject.GetMemberFlashArray("subElements");
		}
		else
		{
			currentObject = flashStorageUtility.CreateTempFlashObject();
			currentObject.SetMemberFlashString( "id", currentSubMenuName);
			currentObject.SetMemberFlashString(  "label", GetLocStringByKeyExt(displayNamePrefix + currentSubMenuName) );
			currentObject.SetMemberFlashUInt(  "tag", NameToFlashUInt( 'MenuSelector') );
			//currentObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("panel_" + currentSubMenuName + "_description") );
			
			if (deconstructedString == "")
			{	
				currentObject.SetMemberFlashUInt( "type", IGMActionType_MenuLastHolder );	
			}
			else
			{
				currentObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );	
			}
			
			currentObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt(displayNamePrefix + currentSubMenuName) );
			
			newChildArray = flashStorageUtility.CreateTempFlashArray();
			currentObject.SetMemberFlashArray( "subElements", newChildArray );
			
			optionParentArray = currentArray;
			currentArray.PushBackFlashObject(currentObject);
			
			currentArray = newChildArray;
		}
	}
	
	return currentObject;
}

function IngameMenu_FillSubMenuOptionsList(flashStorageUtility : CScriptedFlashValueStorage, groupID:int, groupName:name, groupRootObject : CScriptedFlashObject):bool
{
	var groupDisplayName	: string;
	var groupOptionArray	: CScriptedFlashArray;
	var optionObject		: CScriptedFlashObject;
	var optionFlashArray 	: CScriptedFlashArray;
	var optionValueObject	: CScriptedFlashObject;
	var presetNum			: int;
	var numOptions			: int;
	var i					: int;
	var option_it			: int;
	var numOptionValues		: int;
	var optionName			: name;
	var optionDisplayName	: string;
	var optionDisplayType	: string;
	var optionValue			: string;
	var optionVarValue		: string;
	var currentOptionType	: int;
	var numValidOptions		: int;
	var noLocalization 		: bool;
	var customNames			: bool;
	var customDisplayName	: bool;
	
	var inGameConfigWrapper	: CInGameConfigWrapper;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	numValidOptions = 0;
	
	groupOptionArray = groupRootObject.GetMemberFlashArray("subElements");
	
	groupDisplayName = StrReplaceAll(inGameConfigWrapper.GetGroupDisplayName(groupName), ".", "_");
	
	presetNum = inGameConfigWrapper.GetGroupPresetsNum(groupName);
	if (presetNum > 0)
	{
		numValidOptions = 1;
		optionObject = flashStorageUtility.CreateTempFlashObject();
		
		optionObject.SetMemberFlashString( "id", "Presets");
		optionObject.SetMemberFlashString( "label", inGameMenu_TryLocalize("preset_" + groupDisplayName ));
		optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt( 'OptionPresets') );
		//optionObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("preset_" + groupDisplayName + "_description") );
		optionObject.SetMemberFlashUInt( "type", IGMActionType_Preset );
		optionObject.SetMemberFlashInt( "groupID", groupID );
		optionObject.SetMemberFlashUInt( "GroupName", NameToFlashUInt( groupName ) );
		
		optionFlashArray = flashStorageUtility.CreateTempFlashArray();
		
		for (i = 0; i < presetNum; i += 1)
		{
			optionValueObject = flashStorageUtility.CreateTempFlashObject();
			optionValueObject.SetMemberFlashInt( "id", i );
			optionValueObject.SetMemberFlashString( "label", inGameMenu_TryLocalize("preset_value_" + inGameConfigWrapper.GetGroupPresetDisplayName(groupName, i)));
			optionValueObject.SetMemberFlashUInt( "type", IGMActionType_Preset );
			optionFlashArray.PushBackFlashObject(optionValueObject);
		}
		
		optionObject.SetMemberFlashArray( "subElements", optionFlashArray );
		
		groupOptionArray.PushBackFlashObject(optionObject);
	}
	
	numOptions = inGameConfigWrapper.GetVarsNumByGroupName(groupName);
	
	for (i = 0; i < numOptions; i += 1)
	{
		optionName = inGameConfigWrapper.GetVarNameByGroupName(groupName, i);
		
		numOptionValues = inGameConfigWrapper.GetVarOptionsNum(groupName, optionName);
		optionDisplayType = inGameConfigWrapper.GetVarDisplayType(groupName, optionName);
		noLocalization = inGameConfigWrapper.DoVarHasTag(groupName, optionName, 'nonLocalized');
		customNames = inGameConfigWrapper.DoVarHasTag(groupName, optionName, 'customNames');
		customDisplayName = inGameConfigWrapper.DoVarHasTag(groupName, optionName, 'customDisplayName');
		
		if (inGameConfigWrapper.IsVarVisible(groupName, optionName) && (optionDisplayType != "OPTIONS" || numOptionValues > 1))
		{
			optionDisplayName = inGameConfigWrapper.GetVarDisplayName(groupName, optionName);
			
			optionValue = inGameConfigWrapper.GetVarValue(groupName, optionName);
			
			optionObject = flashStorageUtility.CreateTempFlashObject();
			optionObject.SetMemberFlashString( "id", "" + i );
			if (customDisplayName)
			{
				optionObject.SetMemberFlashString( "label", inGameMenu_TryLocalize(optionDisplayName) );
			}
			else
			{
				optionObject.SetMemberFlashString( "label", inGameMenu_TryLocalize("option_" + optionDisplayName) );
			}
			optionObject.SetMemberFlashUInt( "type", IngameMenu_GetOptionTypeFromString(optionDisplayType) );
			//optionObject.SetMemberFlashString(  "description", GetLocStringByKeyExt("option_" + optionDisplayName + "_description") );
			optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt(optionName) );
			optionObject.SetMemberFlashString( "current", optionValue);
			optionObject.SetMemberFlashString( "startingValue", optionValue);
			optionObject.SetMemberFlashInt( "groupID", groupID );
			if (optionName == 'UIMouseSensitivity' || optionName == 'MouseSensitivity')
			{
				optionObject.SetMemberFlashBool( "checkHardwareCursor", true );
			}
			else
			{
				optionObject.SetMemberFlashBool( "checkHardwareCursor", false );
			}
			
			optionFlashArray = flashStorageUtility.CreateTempFlashArray();
			
			for (option_it = 0; option_it < numOptionValues; option_it += 1)
			{
				optionVarValue = inGameConfigWrapper.GetVarOption(groupName, optionName, option_it);
				if (IngameMenu_GetOptionTypeFromString(optionDisplayType) == IGMActionType_List)
				{
					if(!customNames)
					{
						optionVarValue = "preset_value_" + optionVarValue;
					}
					
					if(!noLocalization)
					{
						optionVarValue = inGameMenu_TryLocalize(optionVarValue);
					}
				}
				
				optionFlashArray.PushBackFlashString( optionVarValue);
			}
			
			optionObject.SetMemberFlashArray( "subElements", optionFlashArray );
			
			groupOptionArray.PushBackFlashObject(optionObject);
			
			numValidOptions += 1;
		}
	}
	
	return numValidOptions > 0;
}

function IngameMenu_AddDifficultyOption(flashStorageUtility : CScriptedFlashValueStorage, listToAddToo:CScriptedFlashArray):void
{
	var optionObject 		: CScriptedFlashObject;
	var optionFlashArray	: CScriptedFlashArray;
	var startValue 			: string;
	var difficulty			: int;
	var optionValue			: string;
	
	// #J the -1 is because we don't want the 0 value (EDM_NotSet) and the system uses the 0 value. So I offset everything by 1
	difficulty = theGame.GetDifficultyLevel();
	
	if (difficulty != 0) // In case the difficulty is not set ><
	{
		difficulty -= 1;
	}
	
	startValue = "" + difficulty;
	
	optionObject = flashStorageUtility.CreateTempFlashObject();
	optionObject.SetMemberFlashString( "id", "difficulty");
	optionObject.SetMemberFlashString( "label", GetLocStringByKeyExt("option_difficulty") );
	optionObject.SetMemberFlashUInt( "type", IGMActionType_List );
	optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt('GameDifficulty') );
	optionObject.SetMemberFlashString( "current", startValue);
	optionObject.SetMemberFlashString( "startingValue", startValue);
	optionObject.SetMemberFlashInt( "groupID", NameToFlashUInt('SpecialSettingsGroupId') );
	
	optionFlashArray = flashStorageUtility.CreateTempFlashArray();
	
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_easy_title"));
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_normal_title"));
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_hard_title"));
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_hardcore_title"));
	
	optionObject.SetMemberFlashArray( "subElements", optionFlashArray );
	
	listToAddToo.PushBackFlashObject(optionObject);
}

function IngameMenu_AddGwentDifficultyOption(flashStorageUtility : CScriptedFlashValueStorage, listToAddToo:CScriptedFlashArray):void
{
	var optionObject 		: CScriptedFlashObject;
	var optionFlashArray	: CScriptedFlashArray;
	var startValue 			: string;
	var difficulty			: int;
	var optionValue			: string;
	
	// #J the -1 is because we don't want the 0 value (EDM_NotSet) and the system uses the 0 value. So I offset everything by 1
	difficulty = FactsQueryLatestValue('gwent_difficulty');
	
	if (difficulty != 0) // In case the difficulty is not set ><
	{
		difficulty -= 1;
	}
	
	startValue = "" + difficulty;
	
	optionObject = flashStorageUtility.CreateTempFlashObject();
	optionObject.SetMemberFlashString( "id", "GwentDifficulty");
	optionObject.SetMemberFlashString( "label", GetLocStringByKeyExt("option_gwent_difficulty") );
	optionObject.SetMemberFlashUInt( "type", IGMActionType_List );
	optionObject.SetMemberFlashUInt( "tag", NameToFlashUInt('GwentDifficulty') );
	optionObject.SetMemberFlashString( "current", startValue);
	optionObject.SetMemberFlashString( "startingValue", startValue);
	optionObject.SetMemberFlashInt( "groupID", NameToFlashUInt('Gameplay') );
	
	optionFlashArray = flashStorageUtility.CreateTempFlashArray();
	
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_easy"));
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_normal"));
	optionFlashArray.PushBackFlashString(GetLocStringByKeyExt("panel_mainmenu_dificulty_hard"));
	
	optionObject.SetMemberFlashArray( "subElements", optionFlashArray );
	
	listToAddToo.PushBackFlashObject(optionObject);
}

function IngameMenu_ChangePresetValue(groupId:name, targetPresetIndex:int, parentMenu:CR4IngameMenu):void
{
	var inGameConfigWrapper	: CInGameConfigWrapper;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	inGameConfigWrapper.ApplyGroupPreset(groupId, targetPresetIndex);
	
	if (parentMenu)
	{
		parentMenu.UpdateOptions(groupId);
	}
}

function IngameMenu_GatherOptionUpdatedValues(groupId:name, parentObject:CScriptedFlashObject, flashStorageUtility : CScriptedFlashValueStorage):void
{
	var inGameConfigWrapper	: CInGameConfigWrapper;
	var optionsArray			: CScriptedFlashArray;
	var curOptionInfo			: CScriptedFlashObject;
	var numOptions				: int;
	var iter					: int;
	var curOptionName			: name;
	var curOptionValue			: string;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	parentObject.SetMemberFlashUInt( "presetGroupID", NameToFlashUInt(groupId) );
	optionsArray = flashStorageUtility.CreateTempFlashArray();
	
	numOptions = inGameConfigWrapper.GetVarsNumByGroupName(groupId);
	
	for (iter = 0; iter < numOptions; iter += 1)
	{
		curOptionInfo = flashStorageUtility.CreateTempFlashObject();
		
		curOptionName = inGameConfigWrapper.GetVarNameByGroupName(groupId, iter);
		curOptionInfo.SetMemberFlashUInt( "optionName", NameToFlashUInt(curOptionName) );
		
		curOptionValue = inGameConfigWrapper.GetVarValue(groupId, curOptionName);
		curOptionInfo.SetMemberFlashString( "optionValue", curOptionValue );
		
		optionsArray.PushBackFlashObject(curOptionInfo);
	}
	
	parentObject.SetMemberFlashArray( "optionList", optionsArray );
}

function IngameMenu_GatherKeybindData(parentArray : CScriptedFlashArray, flashStorageUtility : CScriptedFlashValueStorage):void
{
	var currentKeybindData : CScriptedFlashObject;
	var inGameConfigWrapper	: CInGameConfigWrapper;
	var currentKeybindName : name;
	var keybindLabelKey : string;
	var keybindBindingKey : string;
	var groupIndex : int;
	var numKeybinds : int;
	var i:int;
	
	groupIndex = -1;
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	// Super lame that this must be done
	for (i = 0; i < inGameConfigWrapper.GetGroupsNum(); i += 1)
	{
		if (inGameConfigWrapper.GetGroupName(i) == 'PCInput')
		{
			groupIndex = i;
			break;
		}
	}
	
	if (groupIndex != -1)
	{
		numKeybinds = inGameConfigWrapper.GetVarsNumByGroupName('PCInput');
		
		for (i = 0; i < numKeybinds; i += 1)
		{
			currentKeybindName = inGameConfigWrapper.GetVarName(groupIndex, i);
			
			currentKeybindData = flashStorageUtility.CreateTempFlashObject();
			
			currentKeybindData.SetMemberFlashString("label", IngameMenu_GetLocalizedKeybindName(currentKeybindName));
			
			keybindBindingKey = inGameConfigWrapper.GetVarValue('PCInput', currentKeybindName);
			keybindBindingKey = StrReplace(keybindBindingKey, ";IK_None", ""); // #J TODO, if we want to support two keybinds, this wont work as is
			keybindBindingKey = StrReplace(keybindBindingKey, "IK_None;", "");
			currentKeybindData.SetMemberFlashString("value", inGameMenu_LocalizeKeyString(keybindBindingKey));
			currentKeybindData.SetMemberFlashBool("locked", inGameConfigWrapper.DoVarHasTag('PCInput', currentKeybindName, 'locked'));
			currentKeybindData.SetMemberFlashBool("permaLocked", false);
			
			currentKeybindData.SetMemberFlashUInt("tag", NameToFlashUInt(currentKeybindName));
			
			parentArray.PushBackFlashObject(currentKeybindData);
		}
	}
	
	currentKeybindData = flashStorageUtility.CreateTempFlashObject();
	currentKeybindData.SetMemberFlashString("label", inGameMenu_TryLocalize("panel_mainmenu_quicksave"));
	currentKeybindData.SetMemberFlashString("value", inGameMenu_LocalizeKeyString("IK_F5"));
	currentKeybindData.SetMemberFlashBool("locked", true);
	currentKeybindData.SetMemberFlashBool("permaLocked", true);
	currentKeybindData.SetMemberFlashUInt("tag", 0);
	parentArray.PushBackFlashObject(currentKeybindData);
}

function IngameMenu_GetLocalizedKeybindName(keybindName : name) : string
{
	var inGameConfigWrapper	: CInGameConfigWrapper;
	var label : string;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	label = inGameConfigWrapper.GetVarDisplayName('PCInput', keybindName);
	
	// #J Hacky solution but acceptable as long as we don't normally rely on this
	if (label == "move_forward")
	{
		return GetLocStringByKeyExt("ControlLayout_Movement") + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Up");
	}
	else if (label == "move_back")
	{
		return GetLocStringByKeyExt("ControlLayout_Movement") + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Down");
	}
	else if (label == "move_left")
	{
		return GetLocStringByKeyExt("ControlLayout_Movement") + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Left");
	}
	else if (label == "move_right")
	{
		return GetLocStringByKeyExt("ControlLayout_Movement") + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Right");
	}
	
	return inGameMenu_TryLocalize(label);
}

function IngameMenu_GetPCInputGroupIndex() : int
{
	var inGameConfigWrapper	: CInGameConfigWrapper;
	var numGroups : int;
	var i : int;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	numGroups = inGameConfigWrapper.GetGroupsNum();
	
	// Super lame that this must be done
	for (i = 0; i < numGroups; i += 1)
	{
		if (inGameConfigWrapper.GetGroupName(i) == 'PCInput')
		{
			return i;
		}
	}
	
	return -1;
}

function IngameMenu_GetKeybindTagWithKeybindKey(newKeybindValue:EInputKey):name
{
	var inGameConfigWrapper	: CInGameConfigWrapper;
	var currentKeybindName : name;
	var keybindLabelKey : string;
	var keybindBindingKey : string;
	var groupIndex : int;
	var numKeybinds : int;
	var searchingKeybind : string;
	var subKeybind : string;
	var i:int;
	
	searchingKeybind = newKeybindValue;
	
	inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	groupIndex = IngameMenu_GetPCInputGroupIndex();
	
	if (groupIndex != -1)
	{
		numKeybinds = inGameConfigWrapper.GetVarsNumByGroupName('PCInput');
		
		for (i = 0; i < numKeybinds; i += 1)
		{
			currentKeybindName = inGameConfigWrapper.GetVarName(groupIndex, i);
			keybindBindingKey = inGameConfigWrapper.GetVarValue('PCInput', currentKeybindName);
			
			subKeybind = StrReplace(keybindBindingKey, ";IK_None", ""); // #J TODO, if we want to support two keybinds, this wont work as is
			subKeybind = StrReplace(subKeybind, "IK_None;", "");
			
			if (subKeybind == searchingKeybind) 
			{
				return currentKeybindName;
			}
		}
	}
	
	return 'None';
}

function inGameMenu_LocalizeKeyString(key:string):string
{
	var loclizedKey : string;
	var semiColonIndex : int;
	
	// Needed for strings that still have two keys bound (for some reason)
	semiColonIndex = StrFindFirst(key, ";");
	if (semiColonIndex != -1)
	{
		key = StrLeft(key, semiColonIndex);
	}
	
	loclizedKey = GetLocStringByKeyExt("input_device_key_name_" + key);
	
	if (loclizedKey != "")
	{
		return loclizedKey;
	}
	
	return StrReplace(key, "IK_", "");
}

function inGameMenu_TryLocalize(key:string):string
{
	var localizedKey : string;
	var value:EInputKey;
	var transformation:string;
	
	localizedKey = GetLocStringByKeyExt(key);
	if (localizedKey != "")
	{
		return localizedKey;
	}
	
	return "##" + key;
}
