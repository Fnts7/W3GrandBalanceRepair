/***********************************************************************/
/** Witcher Script file - Various Utilities for ingame menu that don't need to be in the menu itself
/***********************************************************************/
/** Copyright © 2015 CDProjektRed
/** Author : Jason Slama
/***********************************************************************/

function IngameMenu_UpdateDLCScriptTags()
{
	var inGameConfigWrapper : CInGameConfigWrapper;
	
	/*inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
	
	if (theGame.IsContentAvailable('dlc0'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc0');
	}
	
	if (theGame.IsContentAvailable('dlc1'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc1');
	}
	
	if (theGame.IsContentAvailable('dlc2'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc2');
	}
	
	if (theGame.IsContentAvailable('dlc3'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc3');
	}
	
	if (theGame.IsContentAvailable('dlc4'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc4');
	}
	
	if (theGame.IsContentAvailable('dlc5'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc5');
	}
	
	if (theGame.IsContentAvailable('dlc6'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc6');
	}
	
	if (theGame.IsContentAvailable('dlc7'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc7');
	}
	
	if (theGame.IsContentAvailable('dlc8'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc8');
	}
	
	if (theGame.IsContentAvailable('dlc9'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc9');
	}
	
	if (theGame.IsContentAvailable('dlc10'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc10');
	}
	
	if (theGame.IsContentAvailable('dlc11'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc11');
	}
	
	if (theGame.IsContentAvailable('dlc12'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc12');
	}
	
	if (theGame.IsContentAvailable('dlc13'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc13');
	}
	
	if (theGame.IsContentAvailable('dlc14'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc14');
	}
	
	if (theGame.IsContentAvailable('dlc15'))
	{
		inGameConfigWrapper.ActivateScriptTag('dlc15');
	}
	
	if (theGame.IsContentAvailable('dlc16')) 
	{ 
		inGameConfigWrapper.ActivateScriptTag('dlc16'); 
	}*/
}

function IngameMenu_PopulateSaveDataForSlotType(flashStorageUtility : CScriptedFlashValueStorage, saveType:int, parentObject:CScriptedFlashArray, allowEmptySlot:bool):void
{
	var currentData		: CScriptedFlashObject;
	var numSaveSlots	: int;
	var saveDisplayName : string;
	var currentSave		: SSavegameInfo;
	var i				: int;
	var saveGames		: array< SSavegameInfo >;
	var numSavesAdded	: int;
	
	// #J non save slot system save loading
	theGame.ListSavedGames( saveGames );
	if (saveType == -1)
	{
		numSaveSlots = 0;
	}
	else
	{	
		numSaveSlots = theGame.GetNumSaveSlots(saveType);
	}
	
	numSavesAdded = 0;
	
	for (i = 0; i < saveGames.Size(); i += 1)
	{
		currentSave = saveGames[i];
		
		saveDisplayName = theGame.GetDisplayNameForSavedGame(currentSave);
		
		if (saveType == currentSave.slotType || saveType == -1)
		{
			numSavesAdded += 1;
		}
	}
	
	if (allowEmptySlot && (numSaveSlots == -1 || numSavesAdded < numSaveSlots) )
	{
		currentData = flashStorageUtility.CreateTempFlashObject();
		
		currentData.SetMemberFlashString("id", "EMPTY");
		if (theGame.GetPlatform() == Platform_Xbox1)
		{
			currentData.SetMemberFlashString("label", GetLocStringByKeyExt("Empty_Save_Slot_x1"));
		}
		else if (theGame.GetPlatform() == Platform_PS4)
		{
			currentData.SetMemberFlashString("label", GetLocStringByKeyExt("Empty_Save_Slot_ps4"));
		}
		else
		{
			currentData.SetMemberFlashString("label", GetLocStringByKeyExt("Empty_Save_Slot"));
		}
		currentData.SetMemberFlashString("filename", "");
		currentData.SetMemberFlashInt("tag", -1);
		currentData.SetMemberFlashUInt("saveType", saveType);
		
		parentObject.PushBackFlashObject(currentData);
	}
	
	for (i = 0; i < saveGames.Size(); i += 1)
	{
		currentSave = saveGames[i];
		
		saveDisplayName = theGame.GetDisplayNameForSavedGame(currentSave);
		
		if (saveType == currentSave.slotType || saveType == -1)
		{
			currentData = flashStorageUtility.CreateTempFlashObject();
			
			currentData.SetMemberFlashString("id", saveDisplayName);
			currentData.SetMemberFlashString("label", saveDisplayName);
			currentData.SetMemberFlashString("filename", currentSave.filename);
			currentData.SetMemberFlashInt("tag", i);
			
			currentData.SetMemberFlashUInt("saveType", currentSave.slotType);
			
			parentObject.PushBackFlashObject(currentData);
		}
	}
}

function IngameMenu_PopulateImportSaveData(flashStorageUtility : CScriptedFlashValueStorage, parentObject:CScriptedFlashArray):void
{
	var saveGames : array< SSavegameInfo >;
	var currentSave		: SSavegameInfo;
	var i				: int;
	var saveDisplayName : string;
	var currentData		: CScriptedFlashObject;
	
	theGame.ListW2SavedGames( saveGames );
	
	for (i = 0; i < saveGames.Size(); i += 1)
	{
		currentSave = saveGames[i];
		
		saveDisplayName = theGame.GetDisplayNameForSavedGame(currentSave);
		
		currentData = flashStorageUtility.CreateTempFlashObject();
		
		currentData.SetMemberFlashString("id", saveDisplayName);
		currentData.SetMemberFlashString("label", saveDisplayName);
		currentData.SetMemberFlashString("filename", currentSave.filename);
		currentData.SetMemberFlashInt("tag", i);
		
		currentData.SetMemberFlashUInt("saveType", currentSave.slotType);
		
		parentObject.PushBackFlashObject(currentData);
	}
}

function InGameMenu_CreateControllerData(flashStorageUtility : CScriptedFlashValueStorage) : CScriptedFlashArray
{
	var dataFlashArray 	: CScriptedFlashArray;
	var currentData		: CScriptedFlashObject;
	
	var htmlNewline 			: string = "&#10;";
	var actionPress				: string;
	var actionHold				: string;
	var actionDoubleTap			: string;
	var txtPanelSelection   	: string;
	var txtGameMenu   			: string;
	var txtCameraControl		: string;
	var txtDPad					: string;
	var txtMovement				: string;
	var txtMountDismount		: string;
	
	if (theGame.GetPlatform() == Platform_PS4)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR_ps4");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu_ps4");
	}
	else
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
	}
	
	actionPress = GetLocStringByKeyExt("ControlLayout_press") + " ";
	actionHold = GetLocStringByKeyExt("ControlLayout_hold") + " - ";
	actionDoubleTap = GetLocStringByKeyExt("ControlLayout_doubleTap") + " - ";
	txtCameraControl = GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget");
	txtDPad = GetLocStringByKeyExt("ControlLayout_LeftSteelSword") + htmlNewline + GetLocStringByKeyExt("ControlLayout_RightSilverSword") + htmlNewline + GetLocStringByKeyExt("ControlLayout_UpPotions") + htmlNewline + GetLocStringByKeyExt("ControlLayout_DownHideSword");
	txtMovement = GetLocStringByKeyExt("ControlLayout_Movement");
	txtMountDismount = GetLocStringByKeyExt("panel_button_common_dismount");//GetLocStringByKeyExt("panel_button_common_mount") + " / " +
	
	dataFlashArray = flashStorageUtility.CreateTempFlashArray();
	
	//EXPLORATION
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_ExplorationLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump"));
	currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", txtMovement + htmlNewline + actionDoubleTap + GetLocStringByKeyExt("ControlLayout_SummonHorse"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	
	//SWIMMING
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_SwinningLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget"));
	currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Dive"));
	currentData.SetMemberFlashString("txtAButton",  GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_FastSwim"));
	currentData.SetMemberFlashString("txtBButton", actionHold + GetLocStringByKeyExt("ControlLayout_Emerge"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", txtMovement);
	currentData.SetMemberFlashString("txtDPad", GetLocStringByKeyExt("ControlLayout_UpPotions") + htmlNewline + GetLocStringByKeyExt("ControlLayout_DownHideSword"));
	dataFlashArray.PushBackFlashObject(currentData);
	
	//COMBAT
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_CombatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl);
	currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Roll") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("ControlLayout_Dodge"));
	currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("panel_input_action_lockandguard"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	
	//HORSE
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_HorseLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	//if (theGame.GetPlatform() == Platform_PS4)
		currentData.SetMemberFlashString("txtAButton",  actionHold + GetLocStringByKeyExt("ControlLayout_Canter") + "<br/>" + GetLocStringByKeyExt("ControlLayout_doubleTap") + " + " + actionHold + GetLocStringByKeyExt("ControlLayout_Gallop"));
	/*else
		currentData.SetMemberFlashString("txtAButton",  actionHold + GetLocStringByKeyExt("ControlLayout_Canter") + " / " + GetLocStringByKeyExt("ControlLayout_doubleClick") + " + " + actionHold + GetLocStringByKeyExt("ControlLayout_Gallop"));*/
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump") + htmlNewline + actionHold + txtMountDismount );
	currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("panel_button_hud_interaction_axii_calm_horse"));
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	
	//BOAT
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_BoatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Stop"));
	currentData.SetMemberFlashString("txtAButton", actionHold + GetLocStringByKeyExt("ControlLayout_Accelerate"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_disembark"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", GetLocStringByKeyExt("ControlLayout_UpPotions") + htmlNewline + GetLocStringByKeyExt("ControlLayout_DownHideSword"));
	dataFlashArray.PushBackFlashObject(currentData);
	
	return dataFlashArray;
}

function InGameMenu_CreateControllerDataCiri(flashStorageUtility : CScriptedFlashValueStorage) : CScriptedFlashArray
{
	var dataFlashArray 	: CScriptedFlashArray;
	var currentData		: CScriptedFlashObject;
	
	var htmlNewline 			: string = "&#10;";
	var actionPress				: string;
	var actionHold				: string;
	var txtPanelSelection   	: string;
	var txtGameMenu   			: string;
	var txtCameraControl		: string;
	var txtDPad					: string;
	var txtMovement				: string;
	var txtMountDismount		: string;
	
	if (theGame.GetPlatform() == Platform_PS4)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR_ps4");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu_ps4");
	}
	else
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
	}
	
	actionPress = GetLocStringByKeyExt("ControlLayout_press") + " ";
	actionHold = GetLocStringByKeyExt("ControlLayout_hold") + " - ";
	txtCameraControl = GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget");
	txtDPad = GetLocStringByKeyExt("ControlLayout_DPadLeftRight") + GetLocStringByKeyExt("ControlLayout_CiriDrawSword");
	txtMovement = GetLocStringByKeyExt("ControlLayout_Movement");
	txtMountDismount = GetLocStringByKeyExt("panel_button_common_dismount");
	
	dataFlashArray = flashStorageUtility.CreateTempFlashArray();
	
	//EXPLORATION
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_ExplorationLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump"));
	if ( thePlayer.HasAbility('CiriCharge') )
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_CiriCharge"));
	else
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtRightBumper", "");
	if ( thePlayer.HasAbility('CiriBlink') )
		currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CiriBlink"));
	else
		currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", txtMovement);
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	
	//SWIMMING
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_SwinningLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget"));
	currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Dive"));
	currentData.SetMemberFlashString("txtAButton",  GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_FastSwim"));
	currentData.SetMemberFlashString("txtBButton", actionHold + GetLocStringByKeyExt("ControlLayout_Emerge"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", txtMovement);
	currentData.SetMemberFlashString("txtDPad", "");
	dataFlashArray.PushBackFlashObject(currentData);
	
	//COMBAT
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_CombatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl);
	currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtAButton", actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("ControlLayout_Dodge"));
	if ( thePlayer.HasAbility('CiriCharge') )
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_CiriCharge"));
	else
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtRightBumper", "");
	if ( thePlayer.HasAbility('CiriBlink') )
		currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CiriBlink"));
	else
		currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("panel_input_action_guard"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	
	//HORSE
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_HorseLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	//if (theGame.GetPlatform() == Platform_PS4)
		currentData.SetMemberFlashString("txtAButton",  actionHold + GetLocStringByKeyExt("ControlLayout_Canter") + "<br/>" + GetLocStringByKeyExt("ControlLayout_doubleTap") + " + " + actionHold + GetLocStringByKeyExt("ControlLayout_Gallop"));
	/*else
		currentData.SetMemberFlashString("txtAButton",  actionHold + GetLocStringByKeyExt("ControlLayout_Canter") + " / " + GetLocStringByKeyExt("ControlLayout_doubleClick") + " + " + actionHold + GetLocStringByKeyExt("ControlLayout_Gallop"));*/
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump") + htmlNewline + actionHold + txtMountDismount );
	currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	
	//BOAT
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_BoatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Stop"));
	currentData.SetMemberFlashString("txtAButton", actionHold + GetLocStringByKeyExt("ControlLayout_Accelerate"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_disembark"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", "");
	dataFlashArray.PushBackFlashObject(currentData);
	
	return dataFlashArray;
}