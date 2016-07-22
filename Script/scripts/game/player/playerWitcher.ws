/***********************************************************************/
/***********************************************************************/
/** Copyright © 2009-2014
/** Author : collective mind of the CDP
/***********************************************************************/

statemachine class W3PlayerWitcher extends CR4Player
{	
	//CRAFTING
	private saved var craftingSchematics				: array<name>; 					//known crafting schematics
	
	//ALCHEMY
	private saved var alchemyRecipes 					: array<name>; 					//known alchemy recipes	
	
	//BOOKS
	private saved var booksRead 						: array<name>; 					//known books
	
	// SKILLS
	private 			var fastAttackCounter, heavyAttackCounter	: int;		//counter for light/heavy attacks. Currently not used but I leave it in case it will come back
	private				var isInFrenzy : bool;
	private				var hasRecentlyCountered : bool;
	private saved 		var cannotUseUndyingSkill : bool;						//if activation delay of Undying skill has finished or not
	
	//ARMOR SET BONUSES
	protected saved			var amountOfSetPiecesEquipped			: array<int>;
	
	// FOCUS MODE
	public				var canSwitchFocusModeTarget	: bool;
	protected			var switchFocusModeTargetAllowed : bool;
		default canSwitchFocusModeTarget = true;
		default switchFocusModeTargetAllowed = true;
	
	// SIGNS
	private editable	var signs						: array< SWitcherSign >;
	private	saved		var equippedSign				: ESignType;
	private				var currentlyCastSign			: ESignType; default currentlyCastSign = ST_None;
	private				var signOwner					: W3SignOwnerPlayer;
	private				var usedQuenInCombat			: bool;
	public				var yrdenEntities				: array<W3YrdenEntity>;
	public saved		var m_quenReappliedCount		: int;
	
	default				equippedSign	= ST_Aard;
	default				m_quenReappliedCount = 1;
	
	//COMBAT MECHANICS
	//private				var combatStance				: EPlayerCombatStance;		
	private 			var bDispalyHeavyAttackIndicator 		: bool; //#B
	private 			var bDisplayHeavyAttackFirstLevelTimer 	: bool; //#B
	public	 			var specialAttackHeavyAllowed 			: bool;	

	default bIsCombatActionAllowed = true;	
	default bDispalyHeavyAttackIndicator = false; //#B	
	default bDisplayHeavyAttackFirstLevelTimer = true; //#B
	
	//INPUT
	
		default explorationInputContext = 'Exploration';
		default combatInputContext = 'Combat';
		default combatFistsInputContext = 'Combat';
		
	// COMPANION MODULE	
	private saved var companionNPCTag		: name;
	private saved var companionNPCTag2		: name;
	
	private saved var companionNPCIconPath	: string;
	private saved var companionNPCIconPath2	: string;	
		
	//ITEMS	
	private 	  saved	var itemSlots					: array<SItemUniqueId>;
	private 			var remainingBombThrowDelaySlot1	: float;
	private 			var remainingBombThrowDelaySlot2	: float;
	private 			var previouslyUsedBolt : SItemUniqueId;				//ID of previously used special bolt (before we entered water)
	private		  saved var questMarkedSelectedQuickslotItems : array< SSelectedQuickslotItem >;
	
	default isThrowingItem = false;
	default remainingBombThrowDelaySlot1 = 0.f;
	default remainingBombThrowDelaySlot2 = 0.f;
	
	//----------------------------
	//SKILLS
	//----------------------------
	
	private saved var tempLearnedSignSkills : array<SSimpleSkill>;		//list of skills temporarily added for the duration of 'All Out' skill (sword_s19)
	public	saved var autoLevel				: bool;						//temp flag for switching autoleveling for player
	
	//---------------------------------------------------------
	//POTIONS and TOXICITY
	//---------------------------------------------------------
	protected saved var skillBonusPotionEffect			: CBaseGameplayEffect;			//cached current bonus potion effect (for skill) - we can have only one
	
	//CHARACTER LEVELING AND DEVELOPMENT
	public saved 		var levelManager 				: W3LevelManager;

	//REPUTATION
	saved var reputationManager	: W3Reputation;
	
	//MEDALLION
	private editable	var medallionEntity			: CEntityTemplate;
	private				var medallionController		: W3MedallionController;
	
	//MUTATIONS
	
	//#B Radial Menu
	public 				var bShowRadialMenu	: bool;	

	private 			var _HoldBeforeOpenRadialMenuTime : float;
	
	default _HoldBeforeOpenRadialMenuTime = 0.5f;
	
	public var MappinToHighlight : array<SHighlightMappin>;
	
	//OTHER
	protected saved	var horseManagerHandle			: EntityHandle;		//handles horse stuff //#DynSave this is always dynamic and will never be saved, can't fix
	

	private var isInitialized : bool;
	private var timeForPerk21 : float;
	
		default isInitialized = false;
		
	
	private var invUpdateTransaction : bool;
		default invUpdateTransaction = false;
	
	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
	
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// INITIALIZATION
	//
	////////////////////////////////////////////////////////////////////////////////
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var i 				: int;
		var items 			: array<SItemUniqueId>;
		var items2 			: array<SItemUniqueId>;
		var horseTemplate 	: CEntityTemplate;
		var horseManager 	: W3HorseManager;
		
		AddAnimEventCallback( 'ActionBlend', 			'OnAnimEvent_ActionBlend' );
		AddAnimEventCallback('cast_begin',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_throw',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_end',				'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_friendly_begin',		'OnAnimEvent_Sign');
		AddAnimEventCallback('cast_friendly_throw',		'OnAnimEvent_Sign');
		AddAnimEventCallback('axii_ready',				'OnAnimEvent_Sign');
		AddAnimEventCallback('axii_alternate_ready',	'OnAnimEvent_Sign');
		AddAnimEventCallback('yrden_draw_ready',		'OnAnimEvent_Sign');
		
		AddAnimEventCallback( 'ProjectileThrow',	'OnAnimEvent_Throwable'	);
		AddAnimEventCallback( 'OnWeaponReload',		'OnAnimEvent_Throwable'	);
		AddAnimEventCallback( 'ProjectileAttach',	'OnAnimEvent_Throwable' );
		AddAnimEventCallback( 'Mutation11AnimEnd',	'OnAnimEvent_Mutation11AnimEnd' );
		AddAnimEventCallback( 'Mutation11ShockWave', 'OnAnimEvent_Mutation11ShockWave' );
		
//		theTelemetry.LogWithName( TE_HERO_SPAWNED );
		
		amountOfSetPiecesEquipped.Resize( EnumGetMax( 'EItemSetType' ) + 1 );
		
		runewordInfusionType = ST_None;
				
		//  Ability manager recalculates resistances so we need to re-equip items first
		inv = GetInventory();			//inv is set in super

		// create and initialize sign owner
		signOwner = new W3SignOwnerPlayer in this;
		signOwner.Init( this );
		
		itemSlots.Resize( EnumGetMax('EEquipmentSlots')+1 );

		if(!spawnData.restored)
		{
			levelManager = new W3LevelManager in this;			
			levelManager.Initialize();
			
			//equip items mounted by default from character template
			inv.GetAllItems(items);
			for(i=0; i<items.Size(); i+=1)
			{
				if(inv.IsItemMounted(items[i]) && ( !inv.IsItemBody(items[i]) || inv.GetItemCategory(items[i]) == 'hair' ) )
					EquipItem(items[i]);
			}
			
			//Sets up default Geralt hair item
			//SetupStartingHair();
			
			// Add starting alchemy recipes
			AddAlchemyRecipe('Recipe for Swallow 1',true,true);
			AddAlchemyRecipe('Recipe for Cat 1',true,true);
			AddAlchemyRecipe('Recipe for White Honey 1',true,true);
			
			AddAlchemyRecipe('Recipe for Samum 1',true,true);
			AddAlchemyRecipe('Recipe for Grapeshot 1',true,true);
			
			AddAlchemyRecipe('Recipe for Specter Oil 1',true,true);
			AddAlchemyRecipe('Recipe for Necrophage Oil 1',true,true);
			AddAlchemyRecipe('Recipe for Alcohest 1',true,true);
		}
		else
		{
			AddTimer('DelayedOnItemMount', 0.1, true);
			
			//Check applied hair for any errors that might occur due to item manipulation via scripts
			CheckHairItem();
		}
		
		// CRAFTING ITEM SCHEMATICS
		AddStartingSchematics();

		super.OnSpawned( spawnData );
		
		// New mutagen recipes, added here to work with old saves
		AddAlchemyRecipe('Recipe for Mutagen red',true,true);
		AddAlchemyRecipe('Recipe for Mutagen green',true,true);
		AddAlchemyRecipe('Recipe for Mutagen blue',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen red',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen green',true,true);
		AddAlchemyRecipe('Recipe for Greater mutagen blue',true,true);
		
		AddCraftingSchematic('Starting Armor Upgrade schematic 1',true,true);
		
		// Revert ciri locks
		if( inputHandler )
		{
			inputHandler.BlockAllActions( 'being_ciri', false );
		}
		SetBehaviorVariable( 'test_ciri_replacer', 0.0f);
		
		if(!spawnData.restored)
		{
			//toxicity`
			abilityManager.GainStat(BCS_Toxicity, 0);		//to calculate current threshold			
		}		
		
		levelManager.PostInit(this, spawnData.restored, true);
		
		SetBIsCombatActionAllowed( true );		//PFTODO: should this get called when loading a game?
		SetBIsInputAllowed( true, 'OnSpawned' );				//PFTODO: should this get called when loading a game?
		
		//Reputation
		if ( !reputationManager )
		{
			reputationManager = new W3Reputation in this;
			reputationManager.Initialize();
		}
		
		theSound.SoundParameter( "focus_aim", 1.0f, 1.0f );
		theSound.SoundParameter( "focus_distance", 0.0f, 1.0f );
		
		//unlock skills for testing purposes
		//if(!theGame.IsFinalBuild() && !spawnData.restored )
		//	Debug_EquipTestingSkills(true);
			
		//cast sign
		currentlyCastSign = ST_None;
		
		//horse manager
		if(!spawnData.restored)
		{
			horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
			horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
			horseManager.CreateAttachment(this);
			horseManager.OnCreated();
			EntityHandleSet( horseManagerHandle, horseManager );
		}
		else
		{
			AddTimer('DelayedHorseUpdate', 0.01, true);
		}
		
		// HACK - removing Ciri abilities
		RemoveAbility('Ciri_CombatRegen');
		RemoveAbility('Ciri_Rage');
		RemoveAbility('CiriBlink');
		RemoveAbility('CiriCharge');
		RemoveAbility('Ciri_Q205');
		RemoveAbility('Ciri_Q305');
		RemoveAbility('Ciri_Q403');
		RemoveAbility('Ciri_Q111');
		RemoveAbility('Ciri_Q501');
		RemoveAbility('SkillCiri');
		
		if(spawnData.restored)
		{
			RestoreQuen(savedQuenHealth, savedQuenDuration);			
		}
		else
		{
			savedQuenHealth = 0.f;
			savedQuenDuration = 0.f;
		}
		
		if(spawnData.restored)
		{
			ApplyPatchFixes();
		}
		else
		{
			//fact added when new game was started with patch 1.20 or newer
			FactsAdd( "new_game_started_in_1_20" );
		}
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			NewGamePlusAdjustDLC1TemerianSet(inv);
			NewGamePlusAdjustDLC5NilfgardianSet(inv);
			NewGamePlusAdjustDLC10WolfSet(inv);
			NewGamePlusAdjustDLC14SkelligeSet(inv);
			if(horseManager)
			{
				NewGamePlusAdjustDLC1TemerianSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC5NilfgardianSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC10WolfSet(horseManager.GetInventoryComponent());
				NewGamePlusAdjustDLC14SkelligeSet(horseManager.GetInventoryComponent());
			}
		}
		
		//failsafe - sometimes whirl does not end properly and keeps stamina lock, cannot pinpoint why this happens
		ResumeStaminaRegen('WhirlSkill');
		
		if(HasAbility('Runeword 4 _Stats', true))
			StartVitalityRegen();
		
		//sword_s19 skill temp bonus
		if(HasAbility('sword_s19'))
		{
			RemoveTemporarySkills();
		}
		
		HACK_UnequipWolfLiver();
		
		//HACK - GRYPHON SET BONUS 2 CAN BE SAVED WHILE IT SHOULDN'T BE
		if( HasBuff( EET_GryphonSetBonusYrden ) )
		{
			RemoveBuff( EET_GryphonSetBonusYrden, false, "GryphonSetBonusYrden" );
		}
		
		if( spawnData.restored )
		{
			//recalc encumbrance - if we change some values in patch, loading a save would not reflect that until something is added / removed from inventory
			UpdateEncumbrance();
			
			//reset immortality from Mutation 11 if triggered outside of combat and saved at that time
			RemoveBuff( EET_Mutation11Immortal );
		}
		
		isInitialized = true;
	}

	////////////////////////////////////////////////////
	//
	// HACK AHEAD
	//
	private function HACK_UnequipWolfLiver()
	{
		var itemName1, itemName2, itemName3, itemName4 : name;
		var item1, item2, item3, item4 : SItemUniqueId;
		
		GetItemEquippedOnSlot( EES_Potion1, item1 );
		GetItemEquippedOnSlot( EES_Potion2, item2 );
		GetItemEquippedOnSlot( EES_Potion3, item3 );
		GetItemEquippedOnSlot( EES_Potion4, item4 );

		if ( inv.IsIdValid( item1 ) )
			itemName1 = inv.GetItemName( item1 );
		if ( inv.IsIdValid( item2 ) )
			itemName2 = inv.GetItemName( item2 );
		if ( inv.IsIdValid( item3 ) )
			itemName3 = inv.GetItemName( item3 );
		if ( inv.IsIdValid( item4 ) )
			itemName4 = inv.GetItemName( item4 );

		if ( itemName1 == 'Wolf liver' || itemName3 == 'Wolf liver' )
		{
			if ( inv.IsIdValid( item1 ) )
				UnequipItem( item1 );
			if ( inv.IsIdValid( item3 ) )
				UnequipItem( item3 );
		}
		else if ( itemName2 == 'Wolf liver' || itemName4 == 'Wolf liver' )
		{
			if ( inv.IsIdValid( item2 ) )
				UnequipItem( item2 );
			if ( inv.IsIdValid( item4 ) )
				UnequipItem( item4 );
		}
	}
	//
	// END OF HACK
	//
	////////////////////////////////////////////////////

	timer function DelayedHorseUpdate( dt : float, id : int )
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
		{
			if ( man.ApplyHorseUpdateOnSpawn() )
			{
				//hackfix for cases when we FT between two different HUBs and horse is not spawned before player spawns - encumbrace then ignores horse items
				UpdateEncumbrance();
				
				RemoveTimer( 'DelayedHorseUpdate' );
			}
		}
	}	
	
	event OnAbilityAdded( abilityName : name)
	{
		super.OnAbilityAdded(abilityName);
		
		if(HasAbility('Runeword 4 _Stats', true))
			StartVitalityRegen();
			
		if ( GetStat(BCS_Focus, true) >= GetStatMax(BCS_Focus) && abilityName == 'Runeword 8 _Stats' && !HasBuff(EET_Runeword8) )
		{
			AddEffectDefault(EET_Runeword8, this, "equipped item");
		}

	}
	
	private final function AddStartingSchematics()
	{
		AddCraftingSchematic('Starting Armor Upgrade schematic 1',	true,true);
		AddCraftingSchematic('Thread schematic',					true, true);
		AddCraftingSchematic('String schematic',					true, true);
		AddCraftingSchematic('Linen schematic',						true, true);
		AddCraftingSchematic('Silk schematic',						true, true);
		AddCraftingSchematic('Resin schematic',						true, true);
		AddCraftingSchematic('Blasting powder schematic',			true, true);
		AddCraftingSchematic('Haft schematic',						true, true);
		AddCraftingSchematic('Hardened timber schematic',			true, true);
		AddCraftingSchematic('Leather squares schematic',			true, true);
		AddCraftingSchematic('Leather schematic',					true, true);
		AddCraftingSchematic('Hardened leather schematic',			true, true);
		AddCraftingSchematic('Draconide leather schematic',			true, true);
		AddCraftingSchematic('Iron ingot schematic',				true, true);
		AddCraftingSchematic('Steel ingot schematic',				true, true);
		AddCraftingSchematic('Steel ingot schematic 1',				true, true);
		AddCraftingSchematic('Steel plate schematic',				true, true);
		AddCraftingSchematic('Dark iron ingot schematic',			true, true);
		AddCraftingSchematic('Dark steel ingot schematic',			true, true);
		AddCraftingSchematic('Dark steel ingot schematic 1',		true, true);
		AddCraftingSchematic('Dark steel plate schematic',			true, true);
		AddCraftingSchematic('Silver ore schematic',				true, true);
		AddCraftingSchematic('Silver ingot schematic',				true, true);
		AddCraftingSchematic('Silver ingot schematic 1',			true, true);
		AddCraftingSchematic('Silver plate schematic',				true, true);
		AddCraftingSchematic('Meteorite ingot schematic',			true, true);
		AddCraftingSchematic('Meteorite silver ingot schematic',	true, true);
		AddCraftingSchematic('Meteorite silver plate schematic',	true, true);
		AddCraftingSchematic('Glowing ingot schematic',				true, true);
		AddCraftingSchematic('Dwimeryte ore schematic',				true, true);
		AddCraftingSchematic('Dwimeryte ingot schematic',			true, true);
		AddCraftingSchematic('Dwimeryte ingot schematic 1',			true, true);
		AddCraftingSchematic('Dwimeryte plate schematic',			true, true);
		AddCraftingSchematic('Infused dust schematic',				true, true);
		AddCraftingSchematic('Infused shard schematic',				true, true);
		AddCraftingSchematic('Infused crystal schematic',			true, true);

		if ( theGame.GetDLCManager().IsEP2Available() )
		{
			AddCraftingSchematic('Draconide infused leather schematic',	true, true);
			AddCraftingSchematic('Nickel ore schematic',				true, true);
			AddCraftingSchematic('Cupronickel ore schematic',			true, true);
			AddCraftingSchematic('Copper ore schematic',				true, true);
			AddCraftingSchematic('Copper ingot schematic',				true, true);
			AddCraftingSchematic('Copper plate schematic',				true, true);
			AddCraftingSchematic('Green gold ore schematic',			true, true);
			AddCraftingSchematic('Green gold ore schematic 1',			true, true);
			AddCraftingSchematic('Green gold ingot schematic',			true, true);
			AddCraftingSchematic('Green gold plate schematic',			true, true);
			AddCraftingSchematic('Orichalcum ore schematic',			true, true);
			AddCraftingSchematic('Orichalcum ore schematic 1',			true, true);
			AddCraftingSchematic('Orichalcum ingot schematic',			true, true);
			AddCraftingSchematic('Orichalcum plate schematic',			true, true);
			AddCraftingSchematic('Dwimeryte enriched ore schematic',	true, true);
			AddCraftingSchematic('Dwimeryte enriched ingot schematic',	true, true);
			AddCraftingSchematic('Dwimeryte enriched plate schematic',	true, true);
		}
	}
	
	private final function ApplyPatchFixes()
	{
		var cnt, transmutationCount, mutagenCount, i : int;
		var transmutationAbility, itemName : name;
		var pam : W3PlayerAbilityManager;
		var slotId : int;
		var offset : float;
		var buffs : array<CBaseGameplayEffect>;
		var mutagen : W3Mutagen_Effect;
		var skill : SSimpleSkill;
		var spentSkillPoints, swordSkillPointsSpent, alchemySkillPointsSpent, perkSkillPointsSpent, pointsToAdd : int;
		var mutagens : array< W3Mutagen_Effect >;
		
		if(FactsQuerySum("ClearingPotionPassiveBonusFix") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;

			cnt = GetAbilityCount('sword_adrenalinegain') - pam.GetPathPointsSpent(ESP_Sword);
			if(cnt > 0)
				RemoveAbilityMultiple('sword_adrenalinegain', cnt);
				
			cnt = GetAbilityCount('magic_staminaregen') - pam.GetPathPointsSpent(ESP_Signs);
			if(cnt > 0)
				RemoveAbilityMultiple('magic_staminaregen', cnt);
				
			cnt = GetAbilityCount('alchemy_potionduration') - pam.GetPathPointsSpent(ESP_Alchemy);
			if(cnt > 0)
				RemoveAbilityMultiple('alchemy_potionduration', cnt);
		
			FactsAdd("ClearingPotionPassiveBonusFix");
		}
				
		//fix for mutagen syngergy bonus (alchemy skill 19) not removed properly when under influence of Dimeritium Bomb
		if(FactsQuerySum("DimeritiumSynergyFix") < 1)
		{
			slotId = GetSkillSlotID(S_Alchemy_s19);
			if(slotId != -1)
				UnequipSkill(S_Alchemy_s19);
				
			RemoveAbilityAll('greater_mutagen_color_green_synergy_bonus');
			RemoveAbilityAll('mutagen_color_green_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_green_synergy_bonus');
			
			RemoveAbilityAll('greater_mutagen_color_blue_synergy_bonus');
			RemoveAbilityAll('mutagen_color_blue_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_blue_synergy_bonus');
			
			RemoveAbilityAll('greater_mutagen_color_red_synergy_bonus');
			RemoveAbilityAll('mutagen_color_red_synergy_bonus');
			RemoveAbilityAll('mutagen_color_lesser_red_synergy_bonus');
			
			if(slotId != -1)
				EquipSkill(S_Alchemy_s19, slotId);
		
			FactsAdd("DimeritiumSynergyFix");
		}
		
		//tutorial for pinning recipes
		if(FactsQuerySum("DontShowRecipePinTut") < 1)
		{
			FactsAdd( "DontShowRecipePinTut" );
			TutorialScript('alchemyRecipePin', '');
			TutorialScript('craftingRecipePin', '');
		}
		
		//potion reducing level requirement
		if(FactsQuerySum("LevelReqPotGiven") < 1)
		{
			FactsAdd("LevelReqPotGiven");
			inv.AddAnItem('Wolf Hour', 1, false, false, true);
		}
		
		//missing auto stamina regen buff
		if(!HasBuff(EET_AutoStaminaRegen))
		{
			AddEffectDefault(EET_AutoStaminaRegen, this, 'autobuff', false);
		}
		
		//wrongly implemented Transmutation skill AND
		//remaining offset toxicity after abilityManager object get corrupted and deleted
		buffs = GetBuffs();
		offset = 0;
		mutagenCount = 0;
		for(i=0; i<buffs.Size(); i+=1)
		{
			mutagen = (W3Mutagen_Effect)buffs[i];
			if(mutagen)
			{
				offset += mutagen.GetToxicityOffset();
				mutagenCount += 1;
			}
		}
		
		//fix offset
		if(offset != (GetStat(BCS_Toxicity) - GetStat(BCS_Toxicity, true)))
			SetToxicityOffset(offset);
			
		//fix Transmutation
		mutagenCount *= GetSkillLevel(S_Alchemy_s13);
		transmutationAbility = GetSkillAbilityName(S_Alchemy_s13);
		transmutationCount = GetAbilityCount(transmutationAbility);
		if(mutagenCount < transmutationCount)
		{
			RemoveAbilityMultiple(transmutationAbility, transmutationCount - mutagenCount);
		}
		else if(mutagenCount > transmutationCount)
		{
			AddAbilityMultiple(transmutationAbility, mutagenCount - transmutationCount);
		}
		
		//enchanting glossary tutorial
		if(theGame.GetDLCManager().IsEP1Available())
		{
			theGame.GetJournalManager().ActivateEntryByScriptTag('TutorialJournalEnchanting', JS_Active);
		}

		//sword_s19 not removed its state 
		if(HasAbility('sword_s19') && FactsQuerySum("Patch_Sword_s19") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;

			//remove all sign skills
			skill.level = 0;
			for(i = S_Magic_s01; i <= S_Magic_s20; i+=1)
			{
				skill.skillType = i;				
				pam.RemoveTemporarySkill(skill);
			}
			
			//add skillpoints for sign skills that were developed
			spentSkillPoints = levelManager.GetPointsUsed(ESkillPoint);
			swordSkillPointsSpent = pam.GetPathPointsSpent(ESP_Sword);
			alchemySkillPointsSpent = pam.GetPathPointsSpent(ESP_Alchemy);
			perkSkillPointsSpent = pam.GetPathPointsSpent(ESP_Perks);
			
			pointsToAdd = spentSkillPoints - swordSkillPointsSpent - alchemySkillPointsSpent - perkSkillPointsSpent;
			if(pointsToAdd > 0)
				levelManager.UnspendPoints(ESkillPoint, pointsToAdd);
			
			//remove ability
			RemoveAbilityAll('sword_s19');
			
			//do only once
			FactsAdd("Patch_Sword_s19");
		}
		
		//issue resurfaced but only with passive stat bonus
		if( HasAbility( 'sword_s19' ) )
		{
			RemoveAbilityAll( 'sword_s19' );
		}
		
		//armor type change glyphwords
		if(FactsQuerySum("Patch_Armor_Type_Glyphwords") < 1)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			
			pam.SetPerkArmorBonus( S_Perk_05, this );
			pam.SetPerkArmorBonus( S_Perk_06, this );
			pam.SetPerkArmorBonus( S_Perk_07, this );
			
			FactsAdd("Patch_Armor_Type_Glyphwords");
		}
		
		if( FactsQuerySum( "Patch_Decoction_Buff_Icons" ) < 1 )
		{
			mutagens = GetMutagenBuffs();
			for( i=0; i<mutagens.Size(); i+=1 )
			{
				itemName = DecoctionEffectTypeToItemName( mutagens[i].GetEffectType() );				
				mutagens[i].OverrideIcon( itemName );
			}
			
			FactsAdd( "Patch_Decoction_Buff_Icons" );
		}
	}
	
	public final function RestoreQuen( quenHealth : float, quenDuration : float, optional alternate : bool ) : bool
	{
		var restoredQuen 	: W3QuenEntity;
		
		if(quenHealth > 0.f && quenDuration >= 3.f)
		{
			restoredQuen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			restoredQuen.Init( signOwner, signs[ST_Quen].entity, true );
			
			if( alternate )
			{
				restoredQuen.SetAlternateCast( S_Magic_s04 );
			}
			
			restoredQuen.OnStarted();
			restoredQuen.OnThrowing();
			
			if( !alternate )
			{
				restoredQuen.OnEnded();
			}
			
			restoredQuen.SetDataFromRestore(quenHealth, quenDuration);
			
			return true;
		}
		
		return false;
	}
	
	public function IsInitialized() : bool
	{
		return isInitialized;
	}
	
	private function NewGamePlusInitialize()
	{
		var questItems : array<name>;
		var horseManager : W3HorseManager;
		var horseInventory : CInventoryComponent;
		var i, missingLevels, expDiff : int;
		
		super.NewGamePlusInitialize();
		
		//get horse inventory - that's where the stash is
		horseManager = (W3HorseManager)EntityHandleGet(horseManagerHandle);
		if(horseManager)
			horseInventory = horseManager.GetInventoryComponent();
		
		//set NG+ level to player level + few
		theGame.params.SetNewGamePlusLevel(GetLevel());
		
		//increase player level if below 30		
		if (theGame.GetDLCManager().IsDLCAvailable('ep1'))
			missingLevels = theGame.params.NEW_GAME_PLUS_EP1_MIN_LEVEL - GetLevel();
		else
			missingLevels = theGame.params.NEW_GAME_PLUS_MIN_LEVEL - GetLevel();
			
		for(i=0; i<missingLevels; i+=1)
		{
			//M.J. Divide XP by 2 since AddPoints() will multiply it by 2 as we are in NG+ mode.
			expDiff = levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint);
			expDiff = CeilF( ((float)expDiff) / 2 );
			AddPoints(EExperiencePoint, expDiff, false);
		}
		
		//-- remove all quest items 1) and 2)
		
		//1) some non-quest items might dynamically have 'Quest' tag added so first we remove all items that 
		//currently have Quest tag
		inv.RemoveItemByTag('Quest', -1);
		horseInventory.RemoveItemByTag('Quest', -1);

		//2) some quest items might lose 'Quest' tag during the course of the game so we need to check their 
		//XML definitions rather than actual items in inventory
		questItems = theGame.GetDefinitionsManager().GetItemsWithTag('Quest');
		for(i=0; i<questItems.Size(); i+=1)
		{
			inv.RemoveItemByName(questItems[i], -1);
			horseInventory.RemoveItemByName(questItems[i], -1);
		}
		
		//3) some quest items don't have 'Quest' tag at all
		inv.RemoveItemByName('mq1002_artifact_3', -1);
		horseInventory.RemoveItemByName('mq1002_artifact_3', -1);
		
		//4) some quest items are regular items but become quest items at some point - Quests will mark them with proper tag
		inv.RemoveItemByTag('NotTransferableToNGP', -1);
		horseInventory.RemoveItemByTag('NotTransferableToNGP', -1);
		
		//remove notice board notices - they are not quest items
		inv.RemoveItemByTag('NoticeBoardNote', -1);
		horseInventory.RemoveItemByTag('NoticeBoardNote', -1);
		
		//remove active buffs
		RemoveAllNonAutoBuffs();
		
		//remove quest alchemy recipes
		RemoveAlchemyRecipe('Recipe for Trial Potion Kit');
		RemoveAlchemyRecipe('Recipe for Pops Antidote');
		RemoveAlchemyRecipe('Recipe for Czart Lure');
		RemoveAlchemyRecipe('q603_diarrhea_potion_recipe');
		
		//remove trophies
		inv.RemoveItemByTag('Trophy', -1);
		horseInventory.RemoveItemByTag('Trophy', -1);
		
		//remove usable items
		inv.RemoveItemByCategory('usable', -1);
		horseInventory.RemoveItemByCategory('usable', -1);
		
		//remove quest abilities
		RemoveAbility('StaminaTutorialProlog');
    	RemoveAbility('TutorialStaminaRegenHack');
    	RemoveAbility('area_novigrad');
    	RemoveAbility('NoRegenEffect');
    	RemoveAbility('HeavySwimmingStaminaDrain');
    	RemoveAbility('AirBoost');
    	RemoveAbility('area_nml');
    	RemoveAbility('area_skellige');
    	
    	//remove Gwent cards
    	inv.RemoveItemByTag('GwintCard', -1);
    	horseInventory.RemoveItemByTag('GwintCard', -1);
    	    	
    	
    	//remove readable items (maps, lore books etc - decision was to remove all)
    	inv.RemoveItemByTag('ReadableItem', -1);
    	horseInventory.RemoveItemByTag('ReadableItem', -1);
    	
    	//restore stats
    	abilityManager.RestoreStats();
    	
    	//unblock toxicity threshold
    	((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(10000);
    	
    	//replenish alchemy items
    	GetInventory().SingletonItemsRefillAmmo();
    	
    	//remove crafting recipes
    	craftingSchematics.Clear();
    	AddStartingSchematics();
    	
    	//clear set bonuses cached data
    	for( i=0; i<amountOfSetPiecesEquipped.Size(); i+=1 )
    	{
			amountOfSetPiecesEquipped[i] = 0;
		}

    	//add clearing potion
    	inv.AddAnItem('Clearing Potion', 1, true, false, false);
    	
    	//broken Ouroboros Mask
    	inv.RemoveItemByName('q203_broken_eyeofloki', -1);
    	horseInventory.RemoveItemByName('q203_broken_eyeofloki', -1);
    	
    	//replace NG+ Witcher items with "base" variants
    	NewGamePlusReplaceViperSet(inv);
    	NewGamePlusReplaceViperSet(horseInventory);
    	NewGamePlusReplaceLynxSet(inv);
    	NewGamePlusReplaceLynxSet(horseInventory);
    	NewGamePlusReplaceGryphonSet(inv);
    	NewGamePlusReplaceGryphonSet(horseInventory);
    	NewGamePlusReplaceBearSet(inv);
    	NewGamePlusReplaceBearSet(horseInventory);
    	NewGamePlusReplaceEP1(inv);
    	NewGamePlusReplaceEP1(horseInventory);
    	NewGamePlusReplaceEP2WitcherSets(inv);
    	NewGamePlusReplaceEP2WitcherSets(horseInventory);
    	NewGamePlusReplaceEP2Items(inv);
    	NewGamePlusReplaceEP2Items(horseInventory);
    	NewGamePlusMarkItemsToNotAdjust(inv);
    	NewGamePlusMarkItemsToNotAdjust(horseInventory);
    	
    	//remove action locks from previous playthrough
    	inputHandler.ClearLocksForNGP();
    	
    	//remove buff immunities & removed immunities from previous playthrough
    	buffImmunities.Clear();
    	buffRemovedImmunities.Clear();
    	
    	newGamePlusInitialized = true;
    	
    	//HACK  - resetting amount of quen reapplied with Bear Set Bonus 1
    	m_quenReappliedCount = 1;
	}
		
	private final function NewGamePlusMarkItemsToNotAdjust(out inv : CInventoryComponent)
	{
		var ids		: array<SItemUniqueId>;
		var i 		: int;
		var n		: name;
		
		inv.GetAllItems(ids);
		for( i=0; i<ids.Size(); i+=1 ) 
		{
			inv.SetItemModifierInt(ids[i], 'NGPItemAdjusted', 1);
		}
	}
	
	private final function NewGamePlusReplaceItem( item : name, new_item : name, out inv : CInventoryComponent)
	{
		var i, j 					: int;
		var ids, new_ids, enh_ids 	: array<SItemUniqueId>;
		var dye_ids					: array<SItemUniqueId>;
		var enh					 	: array<name>;
		var wasEquipped 			: bool;
		var wasEnchanted 			: bool;
		var wasDyed					: bool;
		var enchantName, colorName	: name;
		
		if ( inv.HasItem( item ) )
		{
			ids = inv.GetItemsIds(item);
			for (i = 0; i < ids.Size(); i += 1)
			{
				inv.GetItemEnhancementItems( ids[i], enh );
				wasEnchanted = inv.IsItemEnchanted( ids[i] );
				if ( wasEnchanted ) 
					enchantName = inv.GetEnchantment( ids[i] );
				wasEquipped = IsItemEquipped( ids[i] );
				wasDyed = inv.IsItemColored( ids[i] );
				if ( wasDyed )
				{
					colorName = inv.GetItemColor( ids[i] );
				}
				
				inv.RemoveItem( ids[i], 1 );
				new_ids = inv.AddAnItem( new_item, 1, true, true, false );
				if ( wasEquipped )
				{
					EquipItem( new_ids[0] );
				}
				if ( wasEnchanted )
				{
					inv.EnchantItem( new_ids[0], enchantName, getEnchamtmentStatName(enchantName) );
				}
				for (j = 0; j < enh.Size(); j += 1)
				{
					enh_ids = inv.AddAnItem( enh[j], 1, true, true, false );
					inv.EnhanceItemScript( new_ids[0], enh_ids[0] );
				}
				if ( wasDyed )
				{
					dye_ids = inv.AddAnItem( colorName, 1, true, true, false );
					inv.ColorItem( new_ids[0], dye_ids[0] );
					inv.RemoveItem( dye_ids[0], 1 );
				}
				
				inv.SetItemModifierInt( new_ids[0], 'NGPItemAdjusted', 1 );
			}
		}
	}
	
	private final function NewGamePlusAdjustDLCItem(item : name, mod : name, inv : CInventoryComponent)
	{
		var ids		: array<SItemUniqueId>;
		var i 		: int;
		
		if( inv.HasItem(item) )
		{
			ids = inv.GetItemsIds(item);
			for (i = 0; i < ids.Size(); i += 1)
			{
				if ( inv.GetItemModifierInt(ids[i], 'DoNotAdjustNGPDLC') <= 0 )
				{
					inv.AddItemBaseAbility(ids[i], mod);
					inv.SetItemModifierInt(ids[i], 'DoNotAdjustNGPDLC', 1);	
				}
			}
		}
		
	}
	
	private final function NewGamePlusAdjustDLC1TemerianSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC1 Temerian Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC5NilfgardianSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC5 Nilfgaardian Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC10WolfSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP Wolf Armor',   'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 1', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 2', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Armor 3', 'NGP DLC Compatibility Chest Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Boots 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Gloves 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 1', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 2', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 3', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf Pants 4', 'NGP DLC Compatibility Armor Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword',   'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 1', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 2', 'NGP Wolf Steel Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School steel sword 3', 'NGP Wolf Steel Sword Mod', inv);
		
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword',   'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 1', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 2', 'NGP Wolf Silver Sword Mod', inv);
		NewGamePlusAdjustDLCItem('NGP Wolf School silver sword 3', 'NGP Wolf Silver Sword Mod', inv);
	}
	
	private final function NewGamePlusAdjustDLC14SkelligeSet(inv : CInventoryComponent) 
	{
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Armor', 'NGP DLC Compatibility Chest Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Gloves', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Pants', 'NGP DLC Compatibility Armor Mod', inv);
		NewGamePlusAdjustDLCItem('NGP DLC14 Skellige Boots', 'NGP DLC Compatibility Armor Mod', inv);
	}
	
	private final function NewGamePlusReplaceViperSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Viper School steel sword', 'NGP Viper School steel sword', inv);
		
		NewGamePlusReplaceItem('Viper School silver sword', 'NGP Viper School silver sword', inv);
	}
	
	private final function NewGamePlusReplaceLynxSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Lynx Armor', 'NGP Lynx Armor', inv);
		NewGamePlusReplaceItem('Lynx Armor 1', 'NGP Lynx Armor 1', inv);
		NewGamePlusReplaceItem('Lynx Armor 2', 'NGP Lynx Armor 2', inv);
		NewGamePlusReplaceItem('Lynx Armor 3', 'NGP Lynx Armor 3', inv);
		
		NewGamePlusReplaceItem('Lynx Gloves 1', 'NGP Lynx Gloves 1', inv);
		NewGamePlusReplaceItem('Lynx Gloves 2', 'NGP Lynx Gloves 2', inv);
		NewGamePlusReplaceItem('Lynx Gloves 3', 'NGP Lynx Gloves 3', inv);
		NewGamePlusReplaceItem('Lynx Gloves 4', 'NGP Lynx Gloves 4', inv);
		
		NewGamePlusReplaceItem('Lynx Pants 1', 'NGP Lynx Pants 1', inv);
		NewGamePlusReplaceItem('Lynx Pants 2', 'NGP Lynx Pants 2', inv);
		NewGamePlusReplaceItem('Lynx Pants 3', 'NGP Lynx Pants 3', inv);
		NewGamePlusReplaceItem('Lynx Pants 4', 'NGP Lynx Pants 4', inv);
		
		NewGamePlusReplaceItem('Lynx Boots 1', 'NGP Lynx Boots 1', inv);
		NewGamePlusReplaceItem('Lynx Boots 2', 'NGP Lynx Boots 2', inv);
		NewGamePlusReplaceItem('Lynx Boots 3', 'NGP Lynx Boots 3', inv);
		NewGamePlusReplaceItem('Lynx Boots 4', 'NGP Lynx Boots 4', inv);
		
		NewGamePlusReplaceItem('Lynx School steel sword', 'NGP Lynx School steel sword', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 1', 'NGP Lynx School steel sword 1', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 2', 'NGP Lynx School steel sword 2', inv);
		NewGamePlusReplaceItem('Lynx School steel sword 3', 'NGP Lynx School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Lynx School silver sword', 'NGP Lynx School silver sword', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 1', 'NGP Lynx School silver sword 1', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 2', 'NGP Lynx School silver sword 2', inv);
		NewGamePlusReplaceItem('Lynx School silver sword 3', 'NGP Lynx School silver sword 3', inv);
	}
	
	private final function NewGamePlusReplaceGryphonSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Gryphon Armor', 'NGP Gryphon Armor', inv);
		NewGamePlusReplaceItem('Gryphon Armor 1', 'NGP Gryphon Armor 1', inv);
		NewGamePlusReplaceItem('Gryphon Armor 2', 'NGP Gryphon Armor 2', inv);
		NewGamePlusReplaceItem('Gryphon Armor 3', 'NGP Gryphon Armor 3', inv);
		
		NewGamePlusReplaceItem('Gryphon Gloves 1', 'NGP Gryphon Gloves 1', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 2', 'NGP Gryphon Gloves 2', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 3', 'NGP Gryphon Gloves 3', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 4', 'NGP Gryphon Gloves 4', inv);
		
		NewGamePlusReplaceItem('Gryphon Pants 1', 'NGP Gryphon Pants 1', inv);
		NewGamePlusReplaceItem('Gryphon Pants 2', 'NGP Gryphon Pants 2', inv);
		NewGamePlusReplaceItem('Gryphon Pants 3', 'NGP Gryphon Pants 3', inv);
		NewGamePlusReplaceItem('Gryphon Pants 4', 'NGP Gryphon Pants 4', inv);
		
		NewGamePlusReplaceItem('Gryphon Boots 1', 'NGP Gryphon Boots 1', inv);
		NewGamePlusReplaceItem('Gryphon Boots 2', 'NGP Gryphon Boots 2', inv);
		NewGamePlusReplaceItem('Gryphon Boots 3', 'NGP Gryphon Boots 3', inv);
		NewGamePlusReplaceItem('Gryphon Boots 4', 'NGP Gryphon Boots 4', inv);
		
		NewGamePlusReplaceItem('Gryphon School steel sword', 'NGP Gryphon School steel sword', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 1', 'NGP Gryphon School steel sword 1', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 2', 'NGP Gryphon School steel sword 2', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 3', 'NGP Gryphon School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Gryphon School silver sword', 'NGP Gryphon School silver sword', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 1', 'NGP Gryphon School silver sword 1', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 2', 'NGP Gryphon School silver sword 2', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 3', 'NGP Gryphon School silver sword 3', inv);
	}
	
	private final function NewGamePlusReplaceBearSet(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Bear Armor', 'NGP Bear Armor', inv);
		NewGamePlusReplaceItem('Bear Armor 1', 'NGP Bear Armor 1', inv);
		NewGamePlusReplaceItem('Bear Armor 2', 'NGP Bear Armor 2', inv);
		NewGamePlusReplaceItem('Bear Armor 3', 'NGP Bear Armor 3', inv);
		
		NewGamePlusReplaceItem('Bear Gloves 1', 'NGP Bear Gloves 1', inv);
		NewGamePlusReplaceItem('Bear Gloves 2', 'NGP Bear Gloves 2', inv);
		NewGamePlusReplaceItem('Bear Gloves 3', 'NGP Bear Gloves 3', inv);
		NewGamePlusReplaceItem('Bear Gloves 4', 'NGP Bear Gloves 4', inv);
		
		NewGamePlusReplaceItem('Bear Pants 1', 'NGP Bear Pants 1', inv);
		NewGamePlusReplaceItem('Bear Pants 2', 'NGP Bear Pants 2', inv);
		NewGamePlusReplaceItem('Bear Pants 3', 'NGP Bear Pants 3', inv);
		NewGamePlusReplaceItem('Bear Pants 4', 'NGP Bear Pants 4', inv);
		
		NewGamePlusReplaceItem('Bear Boots 1', 'NGP Bear Boots 1', inv);
		NewGamePlusReplaceItem('Bear Boots 2', 'NGP Bear Boots 2', inv);
		NewGamePlusReplaceItem('Bear Boots 3', 'NGP Bear Boots 3', inv);
		NewGamePlusReplaceItem('Bear Boots 4', 'NGP Bear Boots 4', inv);
		
		NewGamePlusReplaceItem('Bear School steel sword', 'NGP Bear School steel sword', inv);
		NewGamePlusReplaceItem('Bear School steel sword 1', 'NGP Bear School steel sword 1', inv);
		NewGamePlusReplaceItem('Bear School steel sword 2', 'NGP Bear School steel sword 2', inv);
		NewGamePlusReplaceItem('Bear School steel sword 3', 'NGP Bear School steel sword 3', inv);
		
		NewGamePlusReplaceItem('Bear School silver sword', 'NGP Bear School silver sword', inv);
		NewGamePlusReplaceItem('Bear School silver sword 1', 'NGP Bear School silver sword 1', inv);
		NewGamePlusReplaceItem('Bear School silver sword 2', 'NGP Bear School silver sword 2', inv);
		NewGamePlusReplaceItem('Bear School silver sword 3', 'NGP Bear School silver sword 3', inv);
	}
		
	private final function NewGamePlusReplaceEP1(out inv : CInventoryComponent)
	{	
		NewGamePlusReplaceItem('Ofir Armor', 'NGP Ofir Armor', inv);
		NewGamePlusReplaceItem('Ofir Sabre 2', 'NGP Ofir Sabre 2', inv);
		
		NewGamePlusReplaceItem('Crafted Burning Rose Armor', 'NGP Crafted Burning Rose Armor', inv);
		NewGamePlusReplaceItem('Crafted Burning Rose Gloves', 'NGP Crafted Burning Rose Gloves', inv);
		NewGamePlusReplaceItem('Crafted Burning Rose Sword', 'NGP Crafted Burning Rose Sword', inv);
		
		NewGamePlusReplaceItem('Crafted Ofir Armor', 'NGP Crafted Ofir Armor', inv);
		NewGamePlusReplaceItem('Crafted Ofir Boots', 'NGP Crafted Ofir Boots', inv);
		NewGamePlusReplaceItem('Crafted Ofir Gloves', 'NGP Crafted Ofir Gloves', inv);
		NewGamePlusReplaceItem('Crafted Ofir Pants', 'NGP Crafted Ofir Pants', inv);
		NewGamePlusReplaceItem('Crafted Ofir Steel Sword', 'NGP Crafted Ofir Steel Sword', inv);
		
		NewGamePlusReplaceItem('EP1 Crafted Witcher Silver Sword', 'NGP EP1 Crafted Witcher Silver Sword', inv);
		NewGamePlusReplaceItem('Olgierd Sabre', 'NGP Olgierd Sabre', inv);
		
		NewGamePlusReplaceItem('EP1 Witcher Armor', 'NGP EP1 Witcher Armor', inv);
		NewGamePlusReplaceItem('EP1 Witcher Boots', 'NGP EP1 Witcher Boots', inv);
		NewGamePlusReplaceItem('EP1 Witcher Gloves', 'NGP EP1 Witcher Gloves', inv);
		NewGamePlusReplaceItem('EP1 Witcher Pants', 'NGP EP1 Witcher Pants', inv);
		NewGamePlusReplaceItem('EP1 Viper School steel sword', 'NGP EP1 Viper School steel sword', inv);
		NewGamePlusReplaceItem('EP1 Viper School silver sword', 'NGP EP1 Viper School silver sword', inv);
	}
	
	private final function NewGamePlusReplaceEP2WitcherSets(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Lynx Armor 4', 'NGP Lynx Armor 4', inv);
		NewGamePlusReplaceItem('Gryphon Armor 4', 'NGP Gryphon Armor 4', inv);
		NewGamePlusReplaceItem('Bear Armor 4', 'NGP Bear Armor 4', inv);
		NewGamePlusReplaceItem('Wolf Armor 4', 'NGP Wolf Armor 4', inv);
		NewGamePlusReplaceItem('Red Wolf Armor 1', 'NGP Red Wolf Armor 1', inv);
		
		NewGamePlusReplaceItem('Lynx Gloves 5', 'NGP Lynx Gloves 5', inv);
		NewGamePlusReplaceItem('Gryphon Gloves 5', 'NGP Gryphon Gloves 5', inv);
		NewGamePlusReplaceItem('Bear Gloves 5', 'NGP Bear Gloves 5', inv);
		NewGamePlusReplaceItem('Wolf Gloves 5', 'NGP Wolf Gloves 5', inv);
		NewGamePlusReplaceItem('Red Wolf Gloves 1', 'NGP Red Wolf Gloves 1', inv);
		
		NewGamePlusReplaceItem('Lynx Pants 5', 'NGP Lynx Pants 5', inv);
		NewGamePlusReplaceItem('Gryphon Pants 5', 'NGP Gryphon Pants 5', inv);
		NewGamePlusReplaceItem('Bear Pants 5', 'NGP Bear Pants 5', inv);
		NewGamePlusReplaceItem('Wolf Pants 5', 'NGP Wolf Pants 5', inv);
		NewGamePlusReplaceItem('Red Wolf Pants 1', 'NGP Red Wolf Pants 1', inv);
		
		NewGamePlusReplaceItem('Lynx Boots 5', 'NGP Lynx Boots 5', inv);
		NewGamePlusReplaceItem('Gryphon Boots 5', 'NGP Gryphon Boots 5', inv);
		NewGamePlusReplaceItem('Bear Boots 5', 'NGP Bear Boots 5', inv);
		NewGamePlusReplaceItem('Wolf Boots 5', 'NGP Wolf Boots 5', inv);
		NewGamePlusReplaceItem('Red Wolf Boots 1', 'NGP Red Wolf Boots 1', inv);
		
		
		NewGamePlusReplaceItem('Lynx School steel sword 4', 'NGP Lynx School steel sword 4', inv);
		NewGamePlusReplaceItem('Gryphon School steel sword 4', 'NGP Gryphon School steel sword 4', inv);
		NewGamePlusReplaceItem('Bear School steel sword 4', 'NGP Bear School steel sword 4', inv);
		NewGamePlusReplaceItem('Wolf School steel sword 4', 'NGP Wolf School steel sword 4', inv);
		NewGamePlusReplaceItem('Red Wolf School steel sword 1', 'NGP Red Wolf School steel sword 1', inv);
		
		NewGamePlusReplaceItem('Lynx School silver sword 4', 'NGP Lynx School silver sword 4', inv);
		NewGamePlusReplaceItem('Gryphon School silver sword 4', 'NGP Gryphon School silver sword 4', inv);
		NewGamePlusReplaceItem('Bear School silver sword 4', 'NGP Bear School silver sword 4', inv);
		NewGamePlusReplaceItem('Wolf School silver sword 4', 'NGP Wolf School silver sword 4', inv);
		NewGamePlusReplaceItem('Red Wolf School silver sword 1', 'NGP Red Wolf School silver sword 1', inv);
	}
	
	private final function NewGamePlusReplaceEP2Items(out inv : CInventoryComponent)
	{
		NewGamePlusReplaceItem('Guard Lvl1 Armor 3', 'NGP Guard Lvl1 Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Armor 3', 'NGP Guard Lvl1 A Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Armor 3', 'NGP Guard Lvl2 Armor 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Armor 3', 'NGP Guard Lvl2 A Armor 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Armor 3', 'NGP Knight Geralt Armor 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Armor 3', 'NGP Knight Geralt A Armor 3', inv);
		NewGamePlusReplaceItem('q702_vampire_armor', 'NGP q702_vampire_armor', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Gloves 3', 'NGP Guard Lvl1 Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Gloves 3', 'NGP Guard Lvl1 A Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Gloves 3', 'NGP Guard Lvl2 Gloves 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Gloves 3', 'NGP Guard Lvl2 A Gloves 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Gloves 3', 'NGP Knight Geralt Gloves 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Gloves 3', 'NGP Knight Geralt A Gloves 3', inv);
		NewGamePlusReplaceItem('q702_vampire_gloves', 'NGP q702_vampire_gloves', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Pants 3', 'NGP Guard Lvl1 Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Pants 3', 'NGP Guard Lvl1 A Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Pants 3', 'NGP Guard Lvl2 Pants 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Pants 3', 'NGP Guard Lvl2 A Pants 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Pants 3', 'NGP Knight Geralt Pants 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Pants 3', 'NGP Knight Geralt A Pants 3', inv);
		NewGamePlusReplaceItem('q702_vampire_pants', 'NGP q702_vampire_pants', inv);
		
		NewGamePlusReplaceItem('Guard Lvl1 Boots 3', 'NGP Guard Lvl1 Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl1 A Boots 3', 'NGP Guard Lvl1 A Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 Boots 3', 'NGP Guard Lvl2 Boots 3', inv);
		NewGamePlusReplaceItem('Guard Lvl2 A Boots 3', 'NGP Guard Lvl2 A Boots 3', inv);
		NewGamePlusReplaceItem('Knight Geralt Boots 3', 'NGP Knight Geralt Boots 3', inv);
		NewGamePlusReplaceItem('Knight Geralt A Boots 3', 'NGP Knight Geralt A Boots 3', inv);
		NewGamePlusReplaceItem('q702_vampire_boots', 'NGP q702_vampire_boots', inv);
		
		NewGamePlusReplaceItem('Serpent Steel Sword 1', 'NGP Serpent Steel Sword 1', inv);
		NewGamePlusReplaceItem('Serpent Steel Sword 2', 'NGP Serpent Steel Sword 2', inv);
		NewGamePlusReplaceItem('Serpent Steel Sword 3', 'NGP Serpent Steel Sword 3', inv);
		NewGamePlusReplaceItem('Guard lvl1 steel sword 3', 'NGP Guard lvl1 steel sword 3', inv);
		NewGamePlusReplaceItem('Guard lvl2 steel sword 3', 'NGP Guard lvl2 steel sword 3', inv);
		NewGamePlusReplaceItem('Knights steel sword 3', 'NGP Knights steel sword 3', inv);
		NewGamePlusReplaceItem('Hanza steel sword 3', 'NGP Hanza steel sword 3', inv);
		NewGamePlusReplaceItem('Toussaint steel sword 3', 'NGP Toussaint steel sword 3', inv);
		NewGamePlusReplaceItem('q702 vampire steel sword', 'NGP q702 vampire steel sword', inv);
		
		NewGamePlusReplaceItem('Serpent Silver Sword 1', 'NGP Serpent Silver Sword 1', inv);
		NewGamePlusReplaceItem('Serpent Silver Sword 2', 'NGP Serpent Silver Sword 2', inv);
		NewGamePlusReplaceItem('Serpent Silver Sword 3', 'NGP Serpent Silver Sword 3', inv);
	}
	
	public function GetEquippedSword(steel : bool) : SItemUniqueId
	{
		var item : SItemUniqueId;
		
		if(steel)
			GetItemEquippedOnSlot(EES_SteelSword, item);
		else
			GetItemEquippedOnSlot(EES_SilverSword, item);
			
		return item;
	}
	
	timer function BroadcastRain( deltaTime : float, id : int )
	{
		var rainStrength : float = 0;
		rainStrength = GetRainStrength();
		if( rainStrength > 0.5 )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'RainAction', 2.0f , 50.0f, -1.f, -1, true); //reactionSystemOld
			LogReactionSystem( "'RainAction' was sent by Player - single broadcast - distance: 50.0" ); 
		}
	}
	
	function InitializeParryType()
	{
		var i, j : int;
		
		parryTypeTable.Resize( EnumGetMax('EAttackSwingType')+1 );
		for( i = 0; i < EnumGetMax('EAttackSwingType')+1; i += 1 )
		{
			parryTypeTable[i].Resize( EnumGetMax('EAttackSwingDirection')+1 );
		}
		parryTypeTable[AST_Horizontal][ASD_UpDown] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_DownUp] = PT_None;
		parryTypeTable[AST_Horizontal][ASD_LeftRight] = PT_Left;
		parryTypeTable[AST_Horizontal][ASD_RightLeft] = PT_Right;
		parryTypeTable[AST_Vertical][ASD_UpDown] = PT_Up;
		parryTypeTable[AST_Vertical][ASD_DownUp] = PT_Down;
		parryTypeTable[AST_Vertical][ASD_LeftRight] = PT_None;
		parryTypeTable[AST_Vertical][ASD_RightLeft] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalUp][ASD_LeftRight] = PT_UpLeft;
		parryTypeTable[AST_DiagonalUp][ASD_RightLeft] = PT_RightUp;
		parryTypeTable[AST_DiagonalDown][ASD_UpDown] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_DownUp] = PT_None;
		parryTypeTable[AST_DiagonalDown][ASD_LeftRight] = PT_LeftDown;
		parryTypeTable[AST_DiagonalDown][ASD_RightLeft] = PT_DownRight;
		parryTypeTable[AST_Jab][ASD_UpDown] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_DownUp] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_LeftRight] = PT_Jab;
		parryTypeTable[AST_Jab][ASD_RightLeft] = PT_Jab;	
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// DEATH
	//
	////////////////////////////////////////////////////////////////////////////////
	event OnDeath( damageAction : W3DamageAction )
	{
		var items 		: array< SItemUniqueId >;
		var i, size 	: int;	
		var slot		: EEquipmentSlots;
		var holdSlot	: name;
	
		super.OnDeath( damageAction );
	
		items = GetHeldItems();
				
		if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait')
		{
			OnRangedForceHolster( true, true, true );		
			rangedWeapon.ClearDeployedEntity(true);
		}
		
		size = items.Size();
		
		if ( size > 0 )
		{
			for ( i = 0; i < size; i += 1 )
			{
				if ( this.inv.IsIdValid( items[i] ) && !( this.inv.IsItemCrossbow( items[i] ) ) )
				{
					holdSlot = this.inv.GetItemHoldSlot( items[i] );				
				
					if (  holdSlot == 'l_weapon' && this.IsHoldingItemInLHand() )
					{
						this.OnUseSelectedItem( true );
					}			
			
					DropItemFromSlot( holdSlot, false );
					
					if ( holdSlot == 'r_weapon' )
					{
						slot = this.GetItemSlot( items[i] );
						if ( UnequipItemFromSlot( slot ) )
							Log( "Unequip" );
					}
				}
			}
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// Input Section
	//
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function HandleMovement( deltaTime : float )
	{
		super.HandleMovement( deltaTime );
		
		rawCameraHeading = theCamera.GetCameraHeading();
	}
		
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// SETTERS & GETTERS
	//
	//////////////////////////////////////////////////////////////////////////////////////////
	
	function ToggleSpecialAttackHeavyAllowed( toggle : bool)
	{
		specialAttackHeavyAllowed = toggle;
	}
	
	function GetReputationManager() : W3Reputation
	{
		return reputationManager;
	}
			
	function OnRadialMenuItemChoose( selectedItem : string ) //#B
	{
		var iSlotId : int;
		var item : SItemUniqueId;
		
		if ( selectedItem != "Crossbow" )
		{
			if ( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
				OnRangedForceHolster( true, false );
		}
		
		
		switch(selectedItem)
		{
			/*case "Silver":
				if(IsItemEquippedByCategoryName('silversword'))
				{
					OnEquipMeleeWeapon( PW_Silver, false, true );
				}
				break;
			case "Steel":
				if(IsItemEquippedByCategoryName('steelsword'))
				{
					OnEquipMeleeWeapon( PW_Steel, false, true );
				}
				break;	*/
			case "Meditation":
				theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu' );
				break;			
			case "Slot1":
				GetItemEquippedOnSlot( EES_Petard1, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Petard1 );
				}
				else
				{
					SelectQuickslotItem( EES_Petard2 );
				}
				break;
				
			case "Slot2":
				GetItemEquippedOnSlot( EES_Petard2, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Petard2 );
				}
				else
				{
					SelectQuickslotItem( EES_Petard1 );
				}
				break;
				
			case "Crossbow":
				SelectQuickslotItem(EES_RangedWeapon);
				break;
				
			case "Slot3":
				GetItemEquippedOnSlot( EES_Quickslot1, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Quickslot1 );
				}
				else
				{
					SelectQuickslotItem( EES_Quickslot2 );
				}
				break;
				
			case "Slot4": 
				GetItemEquippedOnSlot( EES_Quickslot2, item );
				if( thePlayer.inv.IsIdValid( item ) )
				{
					SelectQuickslotItem( EES_Quickslot2 );
				}
				else
				{
					SelectQuickslotItem( EES_Quickslot1 );
				}
				break;
				
			default:
				SetEquippedSign(SignStringToEnum( selectedItem ));
				FactsRemove("SignToggled");
				break;
		}
	}
	
	function ToggleNextItem()
	{
		var quickSlotItems : array< EEquipmentSlots >;
		var currentSelectedItem : SItemUniqueId;
		var item : SItemUniqueId;
		var i : int;
		
		for( i = EES_Quickslot2; i > EES_Petard1 - 1; i -= 1 )
		{
			GetItemEquippedOnSlot( i, item );
			if( inv.IsIdValid( item ) )
			{
				quickSlotItems.PushBack( i );
			}
		}
		if( !quickSlotItems.Size() )
		{
			return;
		}
		
		currentSelectedItem = GetSelectedItemId();
		
		if( inv.IsIdValid( currentSelectedItem ) )
		{
			for( i = 0; i < quickSlotItems.Size(); i += 1 )
			{
				GetItemEquippedOnSlot( quickSlotItems[i], item );
				if( currentSelectedItem == item )
				{
					if( i == quickSlotItems.Size() - 1 )
					{
						SelectQuickslotItem( quickSlotItems[ 0 ] );
					}
					else
					{
						SelectQuickslotItem( quickSlotItems[ i + 1 ] );
					}
					return;
				}
			}
		}
		else // just pick first valid
		{
			SelectQuickslotItem( quickSlotItems[ 0 ] );
		}
	}
		
	// SIGNS
	function SetEquippedSign( signType : ESignType )
	{
		if(!IsSignBlocked(signType))
		{
			equippedSign = signType;
			FactsSet("CurrentlySelectedSign", equippedSign);
		}
	}
	
	function GetEquippedSign() : ESignType
	{
		return equippedSign;
	}
	
	function GetCurrentlyCastSign() : ESignType
	{
		return currentlyCastSign;
	}
	
	function SetCurrentlyCastSign( type : ESignType, entity : W3SignEntity )
	{
		currentlyCastSign = type;
		
		if( type != ST_None )
		{
			signs[currentlyCastSign].entity = entity;
		}
	}
	
	function GetCurrentSignEntity() : W3SignEntity
	{
		if(currentlyCastSign == ST_None)
			return NULL;
			
		return signs[currentlyCastSign].entity;
	}
	
	public function GetSignEntity(type : ESignType) : W3SignEntity
	{
		if(type == ST_None)
			return NULL;
			
		return signs[type].entity;
	}
	
	public function GetSignTemplate(type : ESignType) : CEntityTemplate
	{
		if(type == ST_None)
			return NULL;
			
		return signs[type].template;
	}
	
	public function IsCurrentSignChanneled() : bool
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
			return signs[currentlyCastSign].entity.OnCheckChanneling();
		
		return false;
	}
	
	function IsCastingSign() : bool
	{
		return currentlyCastSign != ST_None;
	}
	
	// Called from code
	protected function IsInCombatActionCameraRotationEnabled() : bool
	{
		if( IsInCombatAction() && ( GetCombatAction() == EBAT_EMPTY || GetCombatAction() == EBAT_Parry ) )
		{
			return true;
		}
		
		return !bIsInCombatAction;
	}
	
	function SetHoldBeforeOpenRadialMenuTime ( time : float )
	{
		_HoldBeforeOpenRadialMenuTime = time;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// @Repair Kits
	//
	//////////////////////////////////////////////////////////////////////////////////////////
	
	public function RepairItem (  rapairKitId : SItemUniqueId, usedOnItem : SItemUniqueId )
	{
		var itemMaxDurablity 		: float;
		var itemCurrDurablity 		: float;
		var baseRepairValue		  	: float;
		var reapirValue				: float;
		var itemAttribute			: SAbilityAttributeValue;
		
		itemMaxDurablity = inv.GetItemMaxDurability(usedOnItem);
		itemCurrDurablity = inv.GetItemDurability(usedOnItem);
		itemAttribute = inv.GetItemAttributeValue ( rapairKitId, 'repairValue' );
		
		if( itemCurrDurablity >= itemMaxDurablity )
		{
			return;
		}
		
		if ( inv.IsItemAnyArmor ( usedOnItem )|| inv.IsItemWeapon( usedOnItem ) )
		{			
			
			baseRepairValue = itemMaxDurablity * itemAttribute.valueMultiplicative;					
			reapirValue = MinF( itemCurrDurablity + baseRepairValue, itemMaxDurablity );
			
			inv.SetItemDurabilityScript ( usedOnItem, MinF ( reapirValue, itemMaxDurablity ));
		}
		
		inv.RemoveItem ( rapairKitId, 1 );
		
	}
	public function HasRepairAbleGearEquiped ( ) : bool
	{
		var curEquipedItem : SItemUniqueId;
		
		return ( GetItemEquippedOnSlot(EES_Armor, curEquipedItem) || GetItemEquippedOnSlot(EES_Boots, curEquipedItem) || GetItemEquippedOnSlot(EES_Pants, curEquipedItem) || GetItemEquippedOnSlot(EES_Gloves, curEquipedItem)) == true;
	}
	public function HasRepairAbleWaponEquiped () : bool
	{
		var curEquipedItem : SItemUniqueId;
		
		return ( GetItemEquippedOnSlot(EES_SilverSword, curEquipedItem) || GetItemEquippedOnSlot(EES_SteelSword, curEquipedItem) ) == true;
	}
	public function IsItemRepairAble ( item : SItemUniqueId ) : bool
	{
		return inv.GetItemDurabilityRatio(item) <= 0.99999f;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// @Oils
	//
	//////////////////////////////////////////////////////////////////////////////////////////
		
	//applies oil on given player item - adds oil bonus ability to item abilities
	public function ApplyOil( oilId : SItemUniqueId, usedOnItem : SItemUniqueId ) : bool
	{
		var tutStateOil : W3TutorialManagerUIHandlerStateOils;		
		
		if( !super.ApplyOil( oilId, usedOnItem ))
			return false;
				
		//oils equip tutorial
		if(ShouldProcessTutorial('TutorialOilCanEquip3'))
		{
			tutStateOil = (W3TutorialManagerUIHandlerStateOils)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutStateOil)
			{
				tutStateOil.OnOilApplied();
			}
		}
		
		return true;
	}
	
	private final function RemoveExtraOilsFromItem( item : SItemUniqueId )
	{
		var oils : array< CBaseGameplayEffect >;
		var i, cnt : int;
		var buff : W3Effect_Oil;
	
		oils = GetBuffs( EET_Oil );
		for( i=0; i<oils.Size(); i+=1 )
		{			
			buff = (W3Effect_Oil) oils[ i ];
			if( buff && buff.GetSwordItemId() == item )
			{
				cnt += 1;
			}
		}
		while( cnt > 1 )
		{
			inv.RemoveOldestOilFromItem( item );
			cnt -= 1;
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// Damage
	//
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//FIXME this is foobar - sign tests should be moved to actor or entity. This will be usefull when npc will have signs or sign-like spells.
	function ReduceDamage(out damageData : W3DamageAction)
	{
		var actorAttacker : CActor;
		var quen : W3QuenEntity;
		var attackRange : CAIAttackRange;
		var attackerMovementAdjustor : CMovementAdjustor;
		var dist, distToAttacker, actionHeading, attackerHeading, currAdrenaline, adrenReducedDmg, focus : float;
		var attackName : name;
		var useQuenForBleeding : bool;
		var min, max : SAbilityAttributeValue;
		var skillLevel : int;
		
		super.ReduceDamage(damageData);
		
		//HACK for bleeding and quen - since bleeding does direct damage it's not considered in super
		//but we want quen to reduce it
		quen = (W3QuenEntity)signs[ST_Quen].entity;
		useQuenForBleeding = false;
		if(quen && !damageData.DealsAnyDamage() && ((W3Effect_Bleeding)damageData.causer) && damageData.GetDamageValue(theGame.params.DAMAGE_NAME_DIRECT) > 0.f)
			useQuenForBleeding = true;
		
		//damage prevented in super
		if(!useQuenForBleeding && !damageData.DealsAnyDamage())
			return;	
		
		actorAttacker = (CActor)damageData.attacker;
		
		//dodging
		if(actorAttacker && IsCurrentlyDodging() && damageData.CanBeDodged())
		{
			//check if we're dodging straight on attacker or +/- 30 degrees off. If so then the damage will not be prevented
			//if(	( AbsF(AngleDistance(GetCombatActionHeading(), actorAttacker.GetHeading())) < 150 ) && ( !actorAttacker.GetIgnoreImmortalDodge() ) )
			actionHeading = evadeHeading;
			attackerHeading = actorAttacker.GetHeading();
			dist = AngleDistance(actionHeading, attackerHeading);
			distToAttacker = VecDistance(this.GetWorldPosition(),damageData.attacker.GetWorldPosition());
			attackName = actorAttacker.GetLastAttackRangeName();
			attackRange = theGame.GetAttackRangeForEntity( actorAttacker, attackName );
			attackerMovementAdjustor = actorAttacker.GetMovingAgentComponent().GetMovementAdjustor();
			if( ( AbsF(dist) < 150 && attackName != 'stomp' && attackName != 'anchor_special_far' && attackName != 'anchor_far' ) 
				|| ( ( attackName == 'stomp' || attackName == 'anchor_special_far' || attackName == 'anchor_far' ) && distToAttacker > attackRange.rangeMax * 0.75 ) )
			{
				if ( theGame.CanLog() )
				{
					LogDMHits("W3PlayerWitcher.ReduceDamage: Attack dodged by player - no damage done", damageData);
				}
				damageData.SetAllProcessedDamageAs(0);
				damageData.SetWasDodged();
			}
			// S_sword_s9 - decrease damage while dodging
			else if( !damageData.IsActionEnvironment() && !damageData.IsDoTDamage() && CanUseSkill( S_Sword_s09 ) )
			{
				skillLevel = GetSkillLevel( S_Sword_s09 );
				if( skillLevel == GetSkillMaxLevel( S_Sword_s09 ) )
				{
					damageData.SetAllProcessedDamageAs(0);
					damageData.SetWasDodged();
				}
				else
				{
					damageData.processedDmg.vitalityDamage *= 1 - CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s09, 'damage_reduction', false, true)) * skillLevel;
				}
				
				if ( theGame.CanLog() )
				{
					LogDMHits("W3PlayerWitcher.ReduceDamage: skill S_Sword_s09 reduced damage while dodging", damageData );
				}
			}
		}
		
		//damage reduction from signs
		if(quen && damageData.GetBuffSourceName() != "FallingDamage")
		{
			if ( theGame.CanLog() )
			{		
				LogDMHits("W3PlayerWitcher.ReduceDamage: Processing Quen sign damage reduction...", damageData);
			}
			quen.OnTargetHit( damageData );
		}	
		
		// Gryphon Set Bonus 2 - reducing damage if Geralt is in Yrden sign
		if( HasBuff( EET_GryphonSetBonusYrden ) )
		{
			min = GetAttributeValue( 'gryphon_set_bns_dmg_reduction' );
			damageData.processedDmg.vitalityDamage *= 1 - min.valueAdditive;
		}
		
		//Mutation 5 - Reducing dmg for each adrenaline point
		if( IsMutationActive( EPMT_Mutation5 ) && !IsAnyQuenActive() && !damageData.IsDoTDamage() )
		{
			focus = GetStat( BCS_Focus );
			currAdrenaline = FloorF( focus );
			if( currAdrenaline >= 1 )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation5', 'mut5_dmg_red_perc', min, max );
				adrenReducedDmg = ( currAdrenaline * min.valueAdditive );
				damageData.processedDmg.vitalityDamage *= 1 - adrenReducedDmg;
				
				//visuals
				theGame.MutationHUDFeedback( MFT_PlayOnce );
				
				if( focus >= 3.f )
				{
					PlayEffect( 'mutation_5_stage_03' );
				}
				else if( focus >= 2.f )
				{
					PlayEffect( 'mutation_5_stage_02' );
				}
				else
				{
					PlayEffect( 'mutation_5_stage_01' );
				}
			}
		}
		
		//if we don't ignore immortality mode
		if(!damageData.GetIgnoreImmortalityMode())
		{
			if(!((W3PlayerWitcher)this))
				Log("");
			
			//immortality
			if( IsInvulnerable() )
			{
				if ( theGame.CanLog() )
				{
					LogDMHits("CActor.ReduceDamage: victim Invulnerable - no damage will be dealt", damageData );
				}
				damageData.SetAllProcessedDamageAs(0);
				return;
			}
			//inform attacker that the damage was dealt
			if(actorAttacker && damageData.DealsAnyDamage() )
				actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', damageData );
			
			//immortal
			if( IsImmortal() )
			{
				if ( theGame.CanLog() )
				{
					LogDMHits("CActor.ReduceDamage: victim is Immortal, clamping damage", damageData );
				}
				damageData.processedDmg.vitalityDamage = ClampF(damageData.processedDmg.vitalityDamage, 0, GetStat(BCS_Vitality)-1 );
				damageData.processedDmg.essenceDamage  = ClampF(damageData.processedDmg.essenceDamage, 0, GetStat(BCS_Essence)-1 );
				return;
			}
		}
		else
		{
			//inform attacker that the damage was dealt
			if(actorAttacker && damageData.DealsAnyDamage() )
				actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', damageData );
		}
	}
	
	timer function UndyingSkillCooldown(dt : float, id : int)
	{
		cannotUseUndyingSkill = false;
	}
	
	event OnTakeDamage( action : W3DamageAction)
	{
		var currVitality, rgnVitality, hpTriggerTreshold : float;
		var healingFactor : float;
		var abilityName : name;
		var abilityCount, maxStack, itemDurability : float;
		var addAbility : bool;
		var min, max : SAbilityAttributeValue;
		var mutagenQuen : W3SignEntity;
		var equipped : array<SItemUniqueId>;
		var i : int;
		var killSourceName : string;
		var aerondight	: W3Effect_Aerondight;
	
		currVitality = GetStat(BCS_Vitality);
		
		//death preventing effects
		if(action.processedDmg.vitalityDamage >= currVitality)
		{
			killSourceName = action.GetBuffSourceName();
			
			//some deaths cannot be prevented by anything
			if( killSourceName != "Quest" && killSourceName != "Kill Trigger" && killSourceName != "Trap" && killSourceName != "FallingDamage" )
			{			
				//skill that prevents fatal damage & removes battle trance and focus points
				if(!cannotUseUndyingSkill && FloorF(GetStat(BCS_Focus)) >= 1 && CanUseSkill(S_Sword_s18) && HasBuff(EET_BattleTrance) )
				{
					healingFactor = CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'healing_factor', false, true) );
					healingFactor *= GetStatMax(BCS_Vitality);
					healingFactor *= GetStat(BCS_Focus);
					healingFactor *= 1 + CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'healing_bonus', false, true) ) * (GetSkillLevel(S_Sword_s18) - 1);
					ForceSetStat(BCS_Vitality, GetStatMax(BCS_Vitality));
					DrainFocus(GetStat(BCS_Focus));
					RemoveBuff(EET_BattleTrance);
					cannotUseUndyingSkill = true;
					AddTimer('UndyingSkillCooldown', CalculateAttributeValue( GetSkillAttributeValue(S_Sword_s18, 'trigger_delay', false, true) ), false, , , true);
				}
				//Mutation 11 - instead of killing, final blow heals Geralt
				else if( IsMutationActive( EPMT_Mutation11 ) && !HasBuff( EET_Mutation11Debuff ) && !IsInAir() )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation11', 'health_prc', min, max );

					action.SetAllProcessedDamageAs( 0 );
					
					OnMutation11Triggered();					
				}
				else
				{
					//"Reinforced" special item ability. When fatal blows comes, item takes all damage on itself (durability) and prevents death.
					equipped = GetEquippedItems();
					
					for(i=0; i<equipped.Size(); i+=1)
					{
						if ( !inv.IsIdValid( equipped[i] ) )
						{
							continue;
						}
						itemDurability = inv.GetItemDurability(equipped[i]);
						if(inv.ItemHasAbility(equipped[i], 'MA_Reinforced') && itemDurability > 0)
						{
							//break item
							inv.SetItemDurabilityScript(equipped[i], MaxF(0, itemDurability - action.processedDmg.vitalityDamage) );
							
							//prevent damage
							action.processedDmg.vitalityDamage = 0;
							ForceSetStat(BCS_Vitality, 1);
							
							break;
						}
					}
				}
			}
		}
		
		//mutagen 10, 15
		if(action.DealsAnyDamage() && !((W3Effect_Toxicity)action.causer) )
		{
			if(HasBuff(EET_Mutagen10))
				RemoveAbilityAll( GetBuff(EET_Mutagen10).GetAbilityName() );
			
			if(HasBuff(EET_Mutagen15))
				RemoveAbilityAll( GetBuff(EET_Mutagen15).GetAbilityName() );
		}
				
		//mutagen 19
		if(HasBuff(EET_Mutagen19))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetBuff(EET_Mutagen19).GetAbilityName(), 'max_hp_perc_trigger', min, max);
			hpTriggerTreshold = GetStatMax(BCS_Vitality) * CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			
			if(action.GetDamageDealt() >= hpTriggerTreshold)
			{
				mutagenQuen = (W3SignEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
				mutagenQuen.Init( signOwner, signs[ST_Quen].entity, true );
				mutagenQuen.OnStarted();
				mutagenQuen.OnThrowing();
				mutagenQuen.OnEnded();
			}
		}
		
		//mutagen 27
		if(action.DealsAnyDamage() && !action.IsDoTDamage() && HasBuff(EET_Mutagen27))
		{
			abilityName = GetBuff(EET_Mutagen27).GetAbilityName();
			abilityCount = GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen27_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}
			
			if(addAbility)
			{
				AddAbility(abilityName, true);
			}
		}
		//Dettlaff traps
		if(HasBuff(EET_Trap) && !action.IsDoTDamage() && action.attacker.HasAbility( 'mon_dettlaff_monster_base' ))
		{
			action.AddEffectInfo(EET_Knockdown);
			RemoveBuff(EET_Trap, true);
		}		
		
		super.OnTakeDamage(action);
		
		// Aerondight effect
		if( !action.WasDodged() && action.DealtDamage() && inv.ItemHasTag( inv.GetCurrentlyHeldSword(), 'Aerondight' ) && !action.IsDoTDamage() && !( (W3Effect_Toxicity) action.causer ) )
		{
			aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
			if( aerondight && aerondight.GetCurrentCount() != 0 )
			{
				aerondight.ReduceAerondightStacks();
			}
		}
		
		//mutation 3
		if( !action.WasDodged() && action.DealtDamage() && !( (W3Effect_Toxicity) action.causer ) )
		{
			RemoveBuff( EET_Mutation3 );
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// @Combat
	//
	//////////////////////////////////////////////////////////////////////////////////////////
	
	event OnStartFistfightMinigame()
	{
		var i : int;
		var buffs : array< CBaseGameplayEffect >;
		
		//remove potions
		effectManager.RemoveAllPotionEffects();
		//remove toxicity
		abilityManager.DrainToxicity(GetStatMax( BCS_Toxicity ));
		//remove food
		buffs = GetBuffs( EET_WellFed );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			RemoveEffect( buffs[i] );
		}
		
		//remove beverages
		buffs.Clear();
		buffs = GetBuffs( EET_WellHydrated );
		for( i=buffs.Size()-1; i>=0; i-=1 )
		{
			RemoveEffect( buffs[i] );
		}
		
		super.OnStartFistfightMinigame();
	}
	
	event OnEndFistfightMinigame()
	{
		super.OnEndFistfightMinigame();
	}
	
	//crit hit chance 0-1
	public function GetCriticalHitChance( isLightAttack : bool, isHeavyAttack : bool, target : CActor, victimMonsterCategory : EMonsterCategory, isBolt : bool ) : float
	{
		var ret : float;
		var thunder : W3Potion_Thunderbolt;
		var min, max : SAbilityAttributeValue;
		
		ret = super.GetCriticalHitChance( isLightAttack, isHeavyAttack, target, victimMonsterCategory, isBolt );
		
		//Perk_05 bonus
		//if(!isHeavyAttack)
		//{
		//	ret += CalculateAttributeValue(GetAttributeValue('critical_hit_chance_fast_style'));
		//}
		
		thunder = ( W3Potion_Thunderbolt )GetBuff( EET_Thunderbolt );
		if( thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm )
		{
			ret += 1.0f;
		}
		
		//mutation 9 bonus
		if( isBolt && IsMutationActive( EPMT_Mutation9 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'critical_hit_chance', min, max);
			ret += min.valueMultiplicative;
		}
		
		// Crossbow skill bonus
		if( isBolt && CanUseSkill( S_Sword_s07 ) )
		{
			ret += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s07);
		}
			
		return ret;
	}
	
	//gets damage bonus for critical hit
	public function GetCriticalHitDamageBonus(weaponId : SItemUniqueId, victimMonsterCategory : EMonsterCategory, isStrikeAtBack : bool) : SAbilityAttributeValue
	{
		var min, max, bonus, null, oilBonus : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var monsterBonusType : name;
		
		bonus = super.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, isStrikeAtBack);
		
		//alchemy oil criticical damage skill bonus
		if( inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) && GetStat( BCS_Focus ) >= 3 && CanUseSkill( S_Alchemy_s07 ) )
		{
			monsterBonusType = MonsterCategoryToAttackPowerBonus( victimMonsterCategory );
			oilBonus = inv.GetItemAttributeValue( weaponId, monsterBonusType );
			if(oilBonus != null)	//has proper oil type
			{
				bonus += GetSkillAttributeValue(S_Alchemy_s07, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true);
			}
		}
		
		// Mutagen 11 - back strike bonus
		if (isStrikeAtBack && HasBuff(EET_Mutagen11))
		{
			mutagen = GetBuff(EET_Mutagen11);
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(mutagen.GetAbilityName(), 'damageIncrease', min, max);
			bonus += GetAttributeRandomizedValue(min, max);
		}
			
		return bonus;		
	}
	
	public function ProcessLockTarget( optional newLockTarget : CActor, optional checkLeftStickHeading : bool ) : bool
	{
		var newLockTargetFound	: bool;
	
		newLockTargetFound = super.ProcessLockTarget(newLockTarget, checkLeftStickHeading);
		
		if(GetCurrentlyCastSign() == ST_Axii)
		{
			((W3AxiiEntity)GetCurrentSignEntity()).OnDisplayTargetChange(newLockTarget);
		}
		
		return newLockTargetFound;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// @Combat Actions
	//
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*script*/ event OnProcessActionPost(action : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		var rendLoad : float;
		var value : SAbilityAttributeValue;
		var actorVictim : CActor;
		var weaponId : SItemUniqueId;
		var usesSteel, usesSilver, usesVitality, usesEssence : bool;
		var abs : array<name>;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		
		super.OnProcessActionPost(action);
		
		attackAction = (W3Action_Attack)action;
		actorVictim = (CActor)action.victim;
		
		if( !actorVictim.IsAlive() )
		{
			return false;
		}
		
		if(attackAction)
		{
			if(attackAction.IsActionMelee())
			{
				//Rend aka special attack heavy
				if(SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
				{
					rendLoad = GetSpecialAttackTimeRatio();
					
					//consumed focus is lesser of two: current focus and (rend time held * max focus)
					rendLoad = MinF(rendLoad * GetStatMax(BCS_Focus), GetStat(BCS_Focus));
					
					//used points are treated as INTs
					rendLoad = FloorF(rendLoad);					
					DrainFocus(rendLoad);
					
					OnSpecialAttackHeavyActionProcess();
				}
				else if(actorVictim && IsRequiredAttitudeBetween(this, actorVictim, true))
				{
					//focus gain on hit - rend gives none	
					// M.J Each attack gives the same number of adrenaline
					value = GetAttributeValue('focus_gain');
					
					if( FactsQuerySum("debug_fact_focus_boy") > 0 )
					{
						Debug_FocusBoyFocusGain();
					}
					
					//bonus from skill
					if ( CanUseSkill(S_Sword_s20) )
					{
						value += GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s20);
					}
					
					//mutation 3
					if( IsMutationActive( EPMT_Mutation3 ) && IsRequiredAttitudeBetween( this, action.victim, true ) && !action.victim.HasTag( 'Mutation3InvalidTarget' ) && !attackAction.IsParried() && !attackAction.WasDodged() && !attackAction.IsCountered() && !inv.IsItemFists( attackAction.GetWeaponId() ) && !attackAction.WasDamageReturnedToAttacker() && attackAction.DealtDamage() )
					{
						AddEffectDefault( EET_Mutation3, this, "", false );
					}
					
					GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(value)) );
				}
				
				//tutorial - using wrong sword type. Display only when hitting hostiles (even if you can hit neutrals / friendlies)				
				weaponId = attackAction.GetWeaponId();
				if(actorVictim && (ShouldProcessTutorial('TutorialWrongSwordSteel') || ShouldProcessTutorial('TutorialWrongSwordSilver')) && GetAttitudeBetween(actorVictim, this) == AIA_Hostile)
				{
					usesSteel = inv.IsItemSteelSwordUsableByPlayer(weaponId);
					usesSilver = inv.IsItemSilverSwordUsableByPlayer(weaponId);
					usesVitality = actorVictim.UsesVitality();
					usesEssence = actorVictim.UsesEssence();
					
					if(usesSilver && usesVitality)
					{
						FactsAdd('tut_wrong_sword_silver',1);
					}
					else if(usesSteel && usesEssence)
					{
						FactsAdd('tut_wrong_sword_steel',1);
					}
					else if(FactsQuerySum('tut_wrong_sword_steel') && usesSilver && usesEssence)
					{
						FactsAdd('tut_proper_sword_silver',1);
						FactsRemove('tut_wrong_sword_steel');
					}
					else if(FactsQuerySum('tut_wrong_sword_silver') && usesSteel && usesVitality)
					{
						FactsAdd('tut_proper_sword_steel',1);
						FactsRemove('tut_wrong_sword_silver');
					}
				}
				
				//runeword infusing sword with sign power
				if(!action.WasDodged() && HasAbility('Runeword 1 _Stats', true))
				{
					if(runewordInfusionType == ST_Axii)
					{
						actorVictim.SoundEvent('sign_axii_release');
					}
					else if(runewordInfusionType == ST_Igni)
					{
						actorVictim.SoundEvent('sign_igni_charge_begin');
					}
					else if(runewordInfusionType == ST_Quen)
					{
						value = GetAttributeValue('runeword1_quen_heal');
						Heal( action.GetDamageDealt() * value.valueMultiplicative );
						PlayEffectSingle('drain_energy_caretaker_shovel');
					}
					else if(runewordInfusionType == ST_Yrden)
					{
						actorVictim.SoundEvent('sign_yrden_shock_activate');
					}
					runewordInfusionType = ST_None;
					
					//stop fx
					items = inv.GetHeldWeapons();
					weaponEnt = inv.GetItemEntityUnsafe(items[0]);
					weaponEnt.StopEffect('runeword_aard');
					weaponEnt.StopEffect('runeword_axii');
					weaponEnt.StopEffect('runeword_igni');
					weaponEnt.StopEffect('runeword_quen');
					weaponEnt.StopEffect('runeword_yrden');
				}
				
				//light / heavy attacks tutorial
				if(ShouldProcessTutorial('TutorialLightAttacks') || ShouldProcessTutorial('TutorialHeavyAttacks'))
				{
					if(IsLightAttack(attackAction.GetAttackName()))
					{
						theGame.GetTutorialSystem().IncreaseGeraltsLightAttacksCount(action.victim.GetTags());
					}
					else if(IsHeavyAttack(attackAction.GetAttackName()))
					{
						theGame.GetTutorialSystem().IncreaseGeraltsHeavyAttacksCount(action.victim.GetTags());
					}
				}
			}
			else if(attackAction.IsActionRanged())
			{
				//bolt focus gain (if has skill)
				if(CanUseSkill(S_Sword_s15))
				{				
					value = GetSkillAttributeValue(S_Sword_s15, 'focus_gain', false, true) * GetSkillLevel(S_Sword_s15) ;
					GainStat(BCS_Focus, CalculateAttributeValue(value) );
				}
				
				//skill: critical crossbow hit disables 1 random enemy skill
				if(CanUseSkill(S_Sword_s12) && attackAction.IsCriticalHit() && actorVictim)
				{
					//get non-blocked abilities of victim
					abs = actorVictim.GetAbilities(false);
					dm = theGame.GetDefinitionsManager();
					for(i=abs.Size()-1; i>=0; i-=1)
					{
						if(!dm.AbilityHasTag(abs[i], theGame.params.TAG_MONSTER_SKILL) || actorVictim.IsAbilityBlocked(abs[i]))
						{
							abs.EraseFast(i);
						}
					}
					
					//if there is any non-blocked ability - pick random and block it
					if(abs.Size() > 0)
					{
						value = GetSkillAttributeValue(S_Sword_s12, 'duration', true, true) * GetSkillLevel(S_Sword_s12);
						actorVictim.BlockAbility(abs[ RandRange(abs.Size()) ], true, CalculateAttributeValue(value));
					}
				}
			}
		}
		
		//mutation 10
		if( IsMutationActive( EPMT_Mutation10 ) && ( action.IsActionMelee() || action.IsActionWitcherSign() ) )
		{
			PlayEffect( 'mutation_10_energy' );
		}
		
		//perk generating adrenaline on bomb non-DoT damage
		if(CanUseSkill(S_Perk_18) && ((W3Petard)action.causer) && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			value = GetSkillAttributeValue(S_Perk_18, 'focus_gain', false, true);
			GainStat(BCS_Focus, CalculateAttributeValue(value));
		}		
		
		// Lynx Set Bonus 1 - boosting next light attacks
		if( attackAction && IsHeavyAttack( attackAction.GetAttackName() ) && !IsUsingHorse() && attackAction.DealtDamage() && IsSetBonusActive( EISB_Lynx_1 ) && !attackAction.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered() && ( inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) )
		{
			AddEffectDefault( EET_LynxSetBonus, NULL, "HeavyAttack" );
			SoundEvent( "ep2_setskill_lynx_activate" );
		}		
	}
	
	//mutagen 14 - attack power bonus
	timer function Mutagen14Timer(dt : float, id : int)
	{
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		
		abilityName = GetBuff(EET_Mutagen14).GetAbilityName();
		abilityCount = GetAbilityCount(abilityName);
		
		if(abilityCount == 0)
		{
			addAbility = true;
		}
		else
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen14_max_stack', min, max);
			maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			
			if(maxStack >= 0)
			{
				addAbility = (abilityCount < maxStack);
			}
			else
			{
				addAbility = true;
			}
		}
		
		if(addAbility)
		{
			AddAbility(abilityName, true);
		}
		else
		{
			//max stack reached
			RemoveTimer('Mutagen14Timer');
		}
	}
	
	public final function FailFundamentalsFirstAchievementCondition()
	{
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
		
	public final function SetUsedQuenInCombat()
	{
		usedQuenInCombat = true;
	}
	
	public final function UsedQuenInCombat() : bool
	{
		return usedQuenInCombat;
	}
	
	event OnCombatStart()
	{
		var quenEntity, glyphQuen : W3QuenEntity;
		var focus, stamina : float;
		var glowTargets, moTargets, actors : array< CActor >;
		var delays : array< float >;
		var rand, i : int;
		var isHostile, isAlive, isUnconscious : bool;
		
		super.OnCombatStart();
		
		if ( IsInCombatActionFriendly() )
		{
			SetBIsCombatActionAllowed(true);
			SetBIsInputAllowed(true, 'OnCombatActionStart' );
		}
		
		//mutagen 14 - attack power bonus
		if(HasBuff(EET_Mutagen14))
		{
			AddTimer('Mutagen14Timer', 2, true);
		}
		
		//mutagen 15 - attack power bonus
		if(HasBuff(EET_Mutagen15))
		{
			AddAbility(GetBuff(EET_Mutagen15).GetAbilityName(), false);
		}
		
		//mutation 12
		mutation12IsOnCooldown = false;
		
		//check if quen is currently on		
		quenEntity = (W3QuenEntity)signs[ST_Quen].entity;		
		
		//if has some quen
		if(quenEntity)
		{
			usedQuenInCombat = quenEntity.IsAnyQuenActive();
		}
		else
		{
			usedQuenInCombat = false;
		}
		
		if(usedQuenInCombat || HasPotionBuff() || IsEquippedSwordUpgradedWithOil(true) || IsEquippedSwordUpgradedWithOil(false))
		{
			SetFailedFundamentalsFirstAchievementCondition(true);
		}
		else
		{
			if(IsAnyItemEquippedOnSlot(EES_PotionMutagen1) || IsAnyItemEquippedOnSlot(EES_PotionMutagen2) || IsAnyItemEquippedOnSlot(EES_PotionMutagen3) || IsAnyItemEquippedOnSlot(EES_PotionMutagen4))
				SetFailedFundamentalsFirstAchievementCondition(true);
			else
				SetFailedFundamentalsFirstAchievementCondition(false);
		}
		
		if(CanUseSkill(S_Sword_s20) && IsThreatened())
		{
			focus = GetStat(BCS_Focus);
			if(focus < 1)
			{
				GainStat(BCS_Focus, 1 - focus);
			}
		}

		if ( HasAbility('Glyphword 17 _Stats', true) && RandF() < CalculateAttributeValue(GetAttributeValue('quen_apply_chance')) )
		{
			stamina = GetStat(BCS_Stamina);
			glyphQuen = (W3QuenEntity)theGame.CreateEntity( signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
			glyphQuen.Init( signOwner, signs[ST_Quen].entity, true );
			glyphQuen.OnStarted();
			glyphQuen.OnThrowing();
			glyphQuen.OnEnded();
			ForceSetStat(BCS_Stamina, stamina);
		}
		
		//abort meditation
		MeditationForceAbort(true);
		
		//Achievement - School of the Drunken Master
		/*
		if( HasBuff( EET_Drunkenness) && FactsQuerySum( "WasDrunkEntireFight" ) == 0 )
		{
			FactsAdd( "WasDrunkEntireFight" );
		}*/

		//mutation 4
		if( IsMutationActive( EPMT_Mutation4 ) )
		{
			AddEffectDefault( EET_Mutation4, this, "combat start", false );
		}
		else if( IsMutationActive( EPMT_Mutation5 ) && GetStat( BCS_Focus ) >= 1.f )
		{
			AddEffectDefault( EET_Mutation5, this, "", false );
		}
		//Mutation 7 - stat boost at the start of combat
		else if( IsMutationActive( EPMT_Mutation7 ) )
		{
			/*
			actors = GetEnemies();
			
			if( actors.Size() > 1 )
			{		
				AddEffectDefault( EET_Mutation7Buff, this, "Mutation 7, combat start" );			
			}
			else if( actors.Size() == 0 )
			{*/
				//remove queued hack if any
				RemoveTimer( 'Mutation7CombatStartHackFixGo' );
				
				//hack for case when geralt is thrown into combat mode by quest before any npc has turned hostile
				AddTimer( 'Mutation7CombatStartHackFix', 1.f, true, , , , true );
			//}
		}
		else if( IsMutationActive( EPMT_Mutation8 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayRepeat );
		}
		//mutation 10 - show at the start of combat
		else if( IsMutationActive( EPMT_Mutation10 ) )
		{
			//character fx
			PlayEffect( 'mutation_10' );
			
			//onscreen effect
			PlayEffect( 'critical_toxicity' );
			AddTimer( 'Mutation10StopEffect', 5.f );
		}
	}
	
	timer function Mutation7CombatStartHackFix( dt : float, id : int )
	{
		var actors : array< CActor >;
		
		actors = GetEnemies();
		
		if( actors.Size() > 0 )
		{
			//wait for other quest stuff to process
			AddTimer( 'Mutation7CombatStartHackFixGo', 0.5f );
			RemoveTimer( 'Mutation7CombatStartHackFix' );
		}
	}
	
	timer function Mutation7CombatStartHackFixGo( dt : float, id : int )
	{
		var actors : array< CActor >;
		
		if( IsMutationActive( EPMT_Mutation7 ) )
		{
			actors = GetEnemies();
			
			if( actors.Size() > 1 )
			{		
				AddEffectDefault( EET_Mutation7Buff, this, "Mutation 7, combat start" );			
			}
		}
	}
	
	public final function IsInFistFight() : bool
	{
		var enemies : array< CActor >;
		var i, j : int;
		var invent : CInventoryComponent;
		var weapons : array< SItemUniqueId >;
		
		if( IsInFistFightMiniGame() )
		{
			return true;
		}
		
		enemies = GetEnemies();
		for( i=0; i<enemies.Size(); i+=1 )
		{
			weapons.Clear();
			invent = enemies[i].GetInventory();
			weapons = invent.GetHeldWeapons();
			
			for( j=0; j<weapons.Size(); j+=1 )
			{
				if( invent.IsItemFists( weapons[j] ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	timer function Mutation10StopEffect( dt : float, id : int )
	{
		StopEffect( 'critical_toxicity' );
	}
	
	//called when combat finishes
	event OnCombatFinished()
	{
		var mut17 : W3Mutagen17_Effect;
		var inGameConfigWrapper : CInGameConfigWrapper;
		var disableAutoSheathe : bool;
		
		super.OnCombatFinished();
		
		//mutagen 10 disable
		if(HasBuff(EET_Mutagen10))
		{
			RemoveAbilityAll( GetBuff(EET_Mutagen10).GetAbilityName() );
		}
		
		//mutagen 14 disable
		if(HasBuff(EET_Mutagen14))
		{
			RemoveAbilityAll( GetBuff(EET_Mutagen14).GetAbilityName() );
		}
		
		//mutagen 15 disable
		if(HasBuff(EET_Mutagen15))
		{
			RemoveAbilityAll( GetBuff(EET_Mutagen15).GetAbilityName() );
		}
		
		//mutagen 17 disable
		if(HasBuff(EET_Mutagen17))
		{
			mut17 = (W3Mutagen17_Effect)GetBuff(EET_Mutagen17);
			mut17.ClearBoost();
		}
		
		//mutagen 18 disable
		if(HasBuff(EET_Mutagen18))
		{
			RemoveAbilityAll( GetBuff(EET_Mutagen18).GetAbilityName() );
		}
		
		//mutagen 22 disable
		if(HasBuff(EET_Mutagen22))
		{
			RemoveAbilityAll( GetBuff(EET_Mutagen22).GetAbilityName() );
		}
		
		//mutagen 27 disable
		if(HasBuff(EET_Mutagen27))
		{
			RemoveAbilityAll( GetBuff(EET_Mutagen27).GetAbilityName() );
		}
		
		//mutation 3 stacks buff
		RemoveBuff( EET_Mutation3 );
		
		//mutation 4
		RemoveBuff( EET_Mutation4 );
		
		//mutation 5
		RemoveBuff( EET_Mutation5 );
		
		//Mutation 7 disable buffs
		RemoveBuff( EET_Mutation7Buff );
		RemoveBuff( EET_Mutation7Debuff );
			
		if( IsMutationActive( EPMT_Mutation7 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}
		else if( IsMutationActive( EPMT_Mutation8 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}
		
		//mutation 10
		RemoveBuff( EET_Mutation10 );
		
		//feline set bonus 1
		RemoveBuff( EET_LynxSetBonus );
		
		//adrenaline drain
		if(GetStat(BCS_Focus) > 0)
		{
			AddTimer('DelayedAdrenalineDrain', theGame.params.ADRENALINE_DRAIN_AFTER_COMBAT_DELAY, , , , true);
		}
		
		//Removing overheal bonus
		thePlayer.abilityManager.ResetOverhealBonus();
		
		usedQuenInCombat = false;		
		
		theGame.GetGamerProfile().ResetStat(ES_FinesseKills);
		
		LogChannel( 'OnCombatFinished', "OnCombatFinished: DelayedSheathSword timer added" ); 
		
		//auto sword sheathing
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Gameplay', 'DisableAutomaticSwordSheathe' );			
		if( !disableAutoSheathe )
		{
			if ( ShouldAutoSheathSwordInstantly() )
				AddTimer( 'DelayedSheathSword', 0.5f );
			else
				AddTimer( 'DelayedSheathSword', 2.f );
		}
		
		OnBlockAllCombatTickets( false ); // failsafe for killing opponents with debug keys
		
		//'discharge' Runeword 1 infusion
		runewordInfusionType = ST_None;
		
		//Achievement - Style of a Drunken Master
		/*
		if( FactsQuerySum( "statistics_druken_master" ) >=3 && FactsQuerySum( "WasDrunkEntireFight" ) == 1 )
		{
			theGame.GetGamerProfile().AddAchievement( EA_StyleOfTheDrunkenMaster );
			FactsAdd( "DrunkMasterAchievementUnlocked" );
		}
		
		FactsRemove( "statistics_druken_master" );
		FactsRemove( "WasDrunkEntireFight" );
		*/
		
		/*if ( !this.IsThreatened() )
		{
			if ( this.IsInCombatAction() )
				this.PushCombatActionOnBuffer(EBAT_Sheathe_Sword,BS_Pressed);
			else
				OnEquipMeleeWeapon( PW_None, false );
		}*/
	}
	
	public function PlayHitEffect( damageAction : W3DamageAction )
	{
		var hitReactionType		: EHitReactionType;
		var isAtBack			: bool;
		
		//mutation 4 acid blood splash when being hit
		if( damageAction.GetMutation4Triggered() )
		{
			hitReactionType = damageAction.GetHitReactionType();
			isAtBack = IsAttackerAtBack( damageAction.attacker );
			
			if( hitReactionType != EHRT_Heavy )
			{
				if( isAtBack )
				{
					damageAction.SetHitEffect( 'light_hit_back_toxic', true );					
				}
				else
				{
					damageAction.SetHitEffect( 'light_hit_toxic' );
				}
			}
			else
			{
				if( isAtBack )
				{
					damageAction.SetHitEffect( 'heavy_hit_back_toxic' ,true );
				}
				else
				{
					damageAction.SetHitEffect( 'heavy_hit_toxic' );
				}
			}
		}
		
		super.PlayHitEffect( damageAction );
	}
	
	timer function DelayedAdrenalineDrain(dt : float, id : int)
	{
		if ( !HasBuff(EET_Runeword8) )
			AddEffectDefault(EET_AdrenalineDrain, this, "after_combat_adrenaline_drain");
	}
	
	//performs an attack (mechanics wise) on given target and using given attack data
	protected function Attack( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity)
	{
		var mutagen17 : W3Mutagen17_Effect;
		
		super.Attack(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity);
		
		if( (CActor)hitTarget && HasBuff(EET_Mutagen17) )
		{
			mutagen17 = (W3Mutagen17_Effect)GetBuff(EET_Mutagen17);
			if(mutagen17.HasBoost())
			{
				mutagen17.ClearBoost();
			}
		}
	}
	
	public final timer function SpecialAttackLightSustainCost(dt : float, id : int)
	{
		var focusPerSec, cost, delay : float;
		var reduction : SAbilityAttributeValue;
		var skillLevel : int;
		
		if(abilityManager && abilityManager.IsInitialized() && IsAlive())
		{
			PauseStaminaRegen('WhirlSkill');
			
			if(GetStat(BCS_Stamina) > 0)
			{
				cost = GetStaminaActionCost(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
				delay = GetStaminaActionDelay(ESAT_Ability, GetSkillAbilityName(S_Sword_s01), dt);
				skillLevel = GetSkillLevel(S_Sword_s01);
				
				if(skillLevel > 1)
				{
					reduction = GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, true) * (skillLevel - 1);
					cost = MaxF(0, cost * (1 - reduction.valueMultiplicative) - reduction.valueAdditive);
				}
				
				DrainStamina(ESAT_FixedValue, cost, delay, GetSkillAbilityName(S_Sword_s01));
			}
			else				
			{				
				GetSkillAttributeValue(S_Sword_s01, 'focus_cost_per_sec', false, true);
				focusPerSec = GetWhirlFocusCostPerSec();
				DrainFocus(focusPerSec * dt);
			}
		}
		
		if(GetStat(BCS_Stamina) <= 0 && GetStat(BCS_Focus) <= 0)
		{
			OnPerformSpecialAttack(true, false);
		}
	}
	
	public final function GetWhirlFocusCostPerSec() : float
	{
		var ability : SAbilityAttributeValue;
		var val : float;
		var skillLevel : int;
		
		ability = GetSkillAttributeValue(S_Sword_s01, 'focus_cost_per_sec_initial', false, false);
		skillLevel = GetSkillLevel(S_Sword_s01);
		
		if(skillLevel > 1)
			ability -= GetSkillAttributeValue(S_Sword_s01, 'cost_reduction', false, false) * (skillLevel-1);
			
		val = CalculateAttributeValue(ability);
		
		return val;
	}
	
	public final timer function SpecialAttackHeavySustainCost(dt : float, id : int)
	{
		var focusHighlight, ratio : float;
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;		

		//drain stamina
		DrainStamina(ESAT_Ability, 0, 0, GetSkillAbilityName(S_Sword_s02), dt);

		//abort if out of stamina
		if(GetStat(BCS_Stamina) <= 0)
			OnPerformSpecialAttack(false, false);
			
		//update 'held' ratio
		ratio = EngineTimeToFloat(theGame.GetEngineTime() - specialHeavyStartEngineTime) / specialHeavyChargeDuration;
		
		//rounding and blend-out errors
		if(ratio > 0.95)
			ratio = 1;
			
		SetSpecialAttackTimeRatio(ratio);
		
		//calculate focus point cost and highlight 'to be used' focus points on HUD
		focusHighlight = ratio * GetStatMax(BCS_Focus);
		focusHighlight = MinF(focusHighlight, GetStat(BCS_Focus));
		focusHighlight = FloorF(focusHighlight);
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.LockFocusPoints((int)focusHighlight);
			}		
		}
	}
	
	public function OnSpecialAttackHeavyActionProcess()
	{
		var hud : CR4ScriptedHud;
		var hudWolfHeadModule : CR4HudModuleWolfHead;
		
		super.OnSpecialAttackHeavyActionProcess();

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.ResetFocusPoints();
			}		
		}
	}
	
	timer function IsSpecialLightAttackInputHeld ( time : float, id : int )
	{
		var hasResource : bool;
		
		if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
		{
			if ( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
			{
				if(GetStat(BCS_Stamina) > 0)
				{
					hasResource = true;
				}
				else
				{
					hasResource = (GetStat(BCS_Focus) >= GetWhirlFocusCostPerSec() * time);					
				}
				
				if(hasResource)
				{
					SetupCombatAction( EBAT_SpecialAttack_Light, BS_Pressed );
					RemoveTimer('IsSpecialLightAttackInputHeld');
				}
				else if(!playedSpecialAttackMissingResourceSound)
				{
					IndicateTooLowAdrenaline();
					playedSpecialAttackMissingResourceSound = true;
				}
			}			
		}
		else
		{
			RemoveTimer('IsSpecialLightAttackInputHeld');
		}
	}	
	
	timer function IsSpecialHeavyAttackInputHeld ( time : float, id : int )
	{		
		var cost : float;
		
		if ( GetCurrentStateName() == 'CombatSteel' || GetCurrentStateName() == 'CombatSilver' )
		{
			cost = CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s02, 'stamina_cost_per_sec', false, false));
			
			if( GetBIsCombatActionAllowed() && inputHandler.IsActionAllowed(EIAB_SwordAttack))
			{
				if(GetStat(BCS_Stamina) >= cost)
				{
					SetupCombatAction( EBAT_SpecialAttack_Heavy, BS_Pressed );
					RemoveTimer('IsSpecialHeavyAttackInputHeld');
				}
				else if(!playedSpecialAttackMissingResourceSound)
				{
					IndicateTooLowAdrenaline();
					playedSpecialAttackMissingResourceSound = true;
				}
			}
		}
		else
		{
			RemoveTimer('IsSpecialHeavyAttackInputHeld');
		}
	}
	
	public function EvadePressed( bufferAction : EBufferActionType )
	{
		var cat : float;
		
		if( (bufferAction == EBAT_Dodge && IsActionAllowed(EIAB_Dodge)) || (bufferAction == EBAT_Roll && IsActionAllowed(EIAB_Roll)) )
		{
			//tutorial - even if input is not allowed - we might get caught with slowmo during previous dodge - so dodge is not allowed then
			if(bufferAction != EBAT_Roll && ShouldProcessTutorial('TutorialDodge'))
			{
				FactsAdd("tut_in_dodge", 1, 2);
				
				if(FactsQuerySum("tut_fight_use_slomo") > 0)
				{
					theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
					FactsRemove("tut_fight_slomo_ON");
				}
			}				
			else if(bufferAction == EBAT_Roll && ShouldProcessTutorial('TutorialRoll'))
			{
				FactsAdd("tut_in_roll", 1, 2);
				
				if(FactsQuerySum("tut_fight_use_slomo") > 0)
				{
					theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_TutorialFight) );
					FactsRemove("tut_fight_slomo_ON");
				}
			}
				
			if ( GetBIsInputAllowed() )
			{			
				if ( GetBIsCombatActionAllowed() )
				{
					CriticalEffectAnimationInterrupted("Dodge 2");
					PushCombatActionOnBuffer( bufferAction, BS_Released );
					ProcessCombatActionBuffer();
				}					
				else if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					if ( CanPlayHitAnim() && IsThreatened() )
					{
						CriticalEffectAnimationInterrupted("Dodge 1");
						PushCombatActionOnBuffer( bufferAction, BS_Released );
						ProcessCombatActionBuffer();							
					}
					else
						PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
				
				else if ( !( IsCurrentSignChanneled() ) )
				{
					//bIsRollAllowed = true;
					PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
			}
			else
			{
				if ( IsInCombatAction() && GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack )
				{
					if ( CanPlayHitAnim() && IsThreatened() )
					{
						CriticalEffectAnimationInterrupted("Dodge 3");
						PushCombatActionOnBuffer( bufferAction, BS_Released );
						ProcessCombatActionBuffer();							
					}
					else
						PushCombatActionOnBuffer( bufferAction, BS_Released );
				}
				LogChannel( 'InputNotAllowed', "InputNotAllowed" );
			}
		}
		else
		{
			DisplayActionDisallowedHudMessage(EIAB_Dodge);
		}
	}
		
	//All input mechanics are in here
	public function ProcessCombatActionBuffer() : bool
	{
		var action	 			: EBufferActionType			= this.BufferCombatAction;
		var stage	 			: EButtonStage 				= this.BufferButtonStage;		
		var throwStage			: EThrowStage;		
		var actionResult 		: bool = true;
		
		
		if( isInFinisher )
		{
			return false;
		}
		
		if ( action != EBAT_SpecialAttack_Heavy )
			specialAttackCamera = false;			
		
		//call super
		if(super.ProcessCombatActionBuffer())
			return true;		//... and quit if processed	
			
		switch ( action )
		{			
			case EBAT_CastSign :
			{
				switch ( stage )
				{
					case BS_Pressed : 
					{
//						if ( GetInvalidUniqueId() == inv.GetItemFromSlot( 'l_weapon' ) )
//						{
//							if ( ( !rangedWeapon || !( rangedWeapon.PerformedDraw() || rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' ) )
//								&& !currentlyUsingItem )
	//						if ( !currentlyUsingItem )
	//						{
								actionResult = this.CastSign();
								LogChannel('SignDebug', "CastSign()");
	//						}
//						}
					} break;
					
					default : 
					{
						actionResult = false;
					} break;
				}
			} break;
			
			case EBAT_SpecialAttack_Light :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						//AddTemporarySkills();
						actionResult = this.OnPerformSpecialAttack( true, true );
					} break;
					
					case BS_Released :
					{						
						actionResult = this.OnPerformSpecialAttack( true, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;

			case EBAT_SpecialAttack_Heavy :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						//AddTemporarySkills();
						actionResult = this.OnPerformSpecialAttack( false, true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( false, false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			
			default:
				return false;	//not processed
		}
		
		//if here then buffer got processed
		this.CleanCombatActionBuffer();
		
		if (actionResult)
		{
			SetCombatAction( action ) ;
		}
		
		return true;
	}
		
	/*
		These declarations are needed here only to call event with the same name inside combat state (there's no other way to call it!).
	*/	
	event OnPerformSpecialAttack( isLightAttack : bool, enableAttack : bool ){}	
	
	public final function GetEnemies() : array< CActor >
	{
		var actors, actors2 : array<CActor>;
		var i : int;
		
		//something that should work in theory
		actors = GetWitcherPlayer().GetHostileEnemies();
		ArrayOfActorsAppendUnique( actors, GetWitcherPlayer().GetMoveTargets() );
		
		//and a hackfix
		thePlayer.GetVisibleEnemies( actors2 );
		ArrayOfActorsAppendUnique( actors, actors2 );
		
		for( i=actors.Size()-1; i>=0; i-=1 )
		{
			if( !IsRequiredAttitudeBetween( actors[i], this, true ) )
			{
				actors.EraseFast( i );
			}
		}
		
		return actors;
	}
	
	event OnPlayerTickTimer( deltaTime : float )
	{
		super.OnPlayerTickTimer( deltaTime );
		
		if ( !IsInCombat() )
		{
			fastAttackCounter = 0;
			heavyAttackCounter = 0;			
		}		
	}
	
	//////////////////
	// @attacks
	//////////////////
	
	protected function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var ret : bool;
		var skill : ESkill;
	
		ret = super.PrepareAttackAction(hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity, attackAction);
		
		if(!ret)
			return false;
		
		//Skill bonuses
		if(attackAction.IsActionMelee())
		{			
			skill = SkillNameToEnum( attackAction.GetAttackTypeName() );
			if( skill != S_SUndefined && CanUseSkill(skill))
			{
				if(IsLightAttack(animData.attackName))
					fastAttackCounter += 1;
				else
					fastAttackCounter = 0;
				
				if(IsHeavyAttack(animData.attackName))
					heavyAttackCounter += 1;
				else
					heavyAttackCounter = 0;				
			}		
		}
		
		AddTimer('FastAttackCounterDecay',5.0);
		AddTimer('HeavyAttackCounterDecay',5.0);
		
		return true;
	}
	
	protected function TestParryAndCounter(data : CPreAttackEventData, weaponId : SItemUniqueId, out parried : bool, out countered : bool) : array<CActor>
	{
		//rend cannot be parried
		if(SkillNameToEnum(attackActionName) == S_Sword_s02)
			data.Can_Parry_Attack = false;
			
		return super.TestParryAndCounter(data, weaponId, parried, countered);
	}
		
	private timer function FastAttackCounterDecay(delta : float, id : int)
	{
		fastAttackCounter = 0;
	}
	
	private timer function HeavyAttackCounterDecay(delta : float, id : int)
	{
		heavyAttackCounter = 0;
	}
		
	//---------------------------------------------- @CRAFTING --------------------------------------------------------	
	public function GetCraftingSchematicsNames() : array<name>		{return craftingSchematics;}
	
	public function RemoveAllCraftingSchematics()
	{
		craftingSchematics.Clear();
	}
	
	/**
		Adds new schematic to the book. Returns true if the schematic was added, false if it's already in the book.
	*/
	function AddCraftingSchematic( nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool ) : bool
	{
		var i : int;
		
		if(!skipTutorialUpdate && ShouldProcessTutorial('TutorialCraftingGotRecipe'))
		{
			FactsAdd("tut_received_schematic");
		}
		
		for(i=0; i<craftingSchematics.Size(); i+=1)
		{
			if(craftingSchematics[i] == nam)
				return false;
			
			//found a place to insert
			if(StrCmp(craftingSchematics[i],nam) > 0)
			{
				craftingSchematics.Insert(i,nam);
				AddCraftingHudNotification( nam, isSilent );
				theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_CraftingSchematics );
				return true;
			}			
		}	

		//if here then either the array is empty or 'nam' should be inserted at the end
		craftingSchematics.PushBack(nam);
		AddCraftingHudNotification( nam, isSilent );
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_CraftingSchematics );
		return true;	
	}
	
	function AddCraftingHudNotification( nam : name, isSilent : bool )
	{
		var hud : CR4ScriptedHud;
		if( !isSilent )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				hud.OnCraftingSchematicUpdate( nam );
			}
		}
	}	
	
	function AddAlchemyHudNotification( nam : name, isSilent : bool )
	{
		var hud : CR4ScriptedHud;
		if( !isSilent )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				hud.OnAlchemySchematicUpdate( nam );
			}
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////  @MUTATIONS  //////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnMutation11Triggered()
	{
		var min, max : SAbilityAttributeValue;
		var healValue : float;
		var quenEntity : W3QuenEntity;
		
		//skip animation etc.
		if( IsSwimming() || IsDiving() || IsSailing() || IsUsingHorse() || IsUsingBoat() || IsUsingVehicle() || IsUsingExploration() )
		{
			//heal
			ForceSetStat( BCS_Vitality, GetStatMax( BCS_Vitality ) );
			
			//HUD
			theGame.MutationHUDFeedback( MFT_PlayOnce );
			
			//cam shake
			GCameraShake( 1.0f, , , , true, 'camera_shake_loop_lvl1_1' );
			AddTimer( 'StopMutation11CamShake', 2.f );
			
			//vibration
			theGame.VibrateControllerVeryHard( 2.f );
			
			//fx
			Mutation11ShockWave( true );
			
			//add delay
			AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
		}
		else
		{
			AddEffectDefault( EET_Mutation11Buff, this, "Mutation 11", false );
		}
	}
	
	timer function StopMutation11CamShake( dt : float, id : int )
	{
		theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
	}
	
	private var mutation12IsOnCooldown : bool;
	
	public final function AddMutation12Decoction()
	{
		var params : SCustomEffectParams;
		var buffs : array< EEffectType >;
		var existingDecoctionBuffs : array<CBaseGameplayEffect>;
		var i : int;
		var effectType : EEffectType;
		var decoctions : array< SItemUniqueId >;
		var tmpName : name;
		var min, max : SAbilityAttributeValue;
		
		if( mutation12IsOnCooldown )
		{
			return;
		}
		
		//maxcap reached
		existingDecoctionBuffs = GetDrunkMutagens( "Mutation12" );
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation12', 'maxcap', min, max );
		if( existingDecoctionBuffs.Size() >= min.valueAdditive )
		{
			return;
		}
		
		//set cooldown
		mutation12IsOnCooldown = true;		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation12', 'cooldown', min, max );
		AddTimer( 'Mutation12Cooldown', CalculateAttributeValue( min ) );
		
		//get decoctions
		decoctions = inv.GetItemsByTag( 'Mutagen' );
		
		//filter out already active ones
		for( i=decoctions.Size()-1; i>=0; i-=1 )
		{
			inv.GetPotionItemBuffData( decoctions[i], effectType, tmpName );
			if( HasBuff( effectType ) )
			{
				decoctions.EraseFast( i );
				continue;
			}
			buffs.PushBack( effectType );
		}
		
		//if has all add random ones
		if( buffs.Size() == 0 )
		{
			for( i=EET_Mutagen01; i<=EET_Mutagen28; i+=1 )
			{
				if( !HasBuff( i ) )
				{
					buffs.PushBack( i );
				}
			}
		}
		
		//remove Werewolf and Fiend (no combat bonus)
		buffs.Remove( EET_Mutagen16 );
		buffs.Remove( EET_Mutagen24 );
		
		//has everything
		if( buffs.Size() == 0 )
		{
			return;
		}
		
		//add buff
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation12', 'duration', min, max );
		params.effectType = buffs[ RandRange( buffs.Size() ) ];
		params.creator = this;
		params.sourceName = "Mutation12";
		params.duration = min.valueAdditive;
		AddEffectCustom( params );
		( ( W3Mutagen_Effect ) GetBuff( params.effectType, params.sourceName ) ).OverrideIcon( DecoctionEffectTypeToItemName( params.effectType ) );
		
		//show fx
		if ( !IsEffectActive( 'invisible' ) )
		{
			PlayEffect( 'use_potion' );
		}
		
		theGame.MutationHUDFeedback( MFT_PlayOnce );
	}
	
	timer function Mutation12Cooldown( dt : float, id : int )
	{
		mutation12IsOnCooldown = false;
	}
	
	//returns true if player has some skillpoints or mutagens
	public final function HasResourcesToStartAnyMutationResearch() : bool
	{
		var greenPoints, redPoints, bluePoints, count : int;
		var itemIDs : array< SItemUniqueId >;
		
		if( levelManager.GetPointsFree( ESkillPoint ) > 0 )
		{
			return true;
		}
		
		//count mutagen points
		count = inv.GetItemQuantityByName( 'Greater mutagen green' );
		if( count > 0 )
		{
			itemIDs = inv.GetItemsByName( 'Greater mutagen green' );
			greenPoints = inv.GetMutationResearchPoints( SC_Green, itemIDs[0] );
			if( greenPoints > 0 )
			{
				return true;
			}
		}	
		count = inv.GetItemQuantityByName( 'Greater mutagen red' );
		if( count > 0 )
		{
			itemIDs.Clear();
			itemIDs = inv.GetItemsByName( 'Greater mutagen red' );
			redPoints = inv.GetMutationResearchPoints( SC_Red, itemIDs[0] );
			if( redPoints > 0 )
			{
				return true;
			}
		}		
		count = inv.GetItemQuantityByName( 'Greater mutagen blue' );
		if( count > 0 )
		{
			itemIDs.Clear();
			itemIDs = inv.GetItemsByName( 'Greater mutagen blue' );
			bluePoints = inv.GetMutationResearchPoints( SC_Blue, itemIDs[0] );
			if( bluePoints > 0 )
			{
				return true;
			}
		}		
		
		return false;
	}
	
	//fire quen impulse
	public final function Mutation11StartAnimation()
	{
		//play animation
		thePlayer.ActionPlaySlotAnimationAsync( 'PLAYER_SLOT', 'geralt_mutation_11', 0.2, 0.2 );
		
		//block all actions
		BlockAllActions( 'Mutation11', true );
		
		//cam shake
		loopingCameraShakeAnimName = 'camera_shake_loop_lvl1_1';
		GCameraShake( 1.0f, , , , true, loopingCameraShakeAnimName );
		
		//pad vibration - will be stopped when animation ends so the duration needs to be longer than anim duration
		theGame.VibrateControllerVeryHard( 15.f );
		
		//unpushable
		storedInteractionPriority = GetInteractionPriority();
		SetInteractionPriority( IP_Max_Unpushable );
	}
	
	event OnAnimEvent_Mutation11ShockWave( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		Mutation11ShockWave( false );
	}
	
	private final function Mutation11ShockWave( skipQuenSign : bool )
	{
		var action : W3DamageAction;
		var ents : array< CGameplayEntity >;
		var i, j : int;
		var damages : array< SRawDamage >;
	
		//find targets
		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), 5.f, 1000, '', FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral, this);
		
		if( ents.Size() > 0 )
		{
			damages = theGame.GetDefinitionsManager().GetDamagesFromAbility( 'Mutation11' );
		}
		
		//apply effects
		for(i=0; i<ents.Size(); i+=1)
		{
			action = new W3DamageAction in theGame;
			action.Initialize( this, ents[i], NULL, "Mutation11", EHRT_Heavy, CPS_SpellPower, false, false, true, false );
			
			for( j=0; j<damages.Size(); j+=1 )
			{
				action.AddDamage( damages[j].dmgType, damages[j].dmgVal );
			}
			
			action.SetCannotReturnDamage( true );
			action.SetProcessBuffsIfNoDamage( true );
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
			action.SetHitAnimationPlayType( EAHA_ForceYes );
			action.SetCanPlayHitParticle( false );
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		//fx
		//PlayEffect( 'mutation_11_second_life_force' );
		
		//quen burst fx
		mutation11QuenEntity = ( W3QuenEntity )GetSignEntity( ST_Quen );
		if( !mutation11QuenEntity )
		{
			mutation11QuenEntity = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
			mutation11QuenEntity.CreateAttachment( this, 'quen_sphere' );
			AddTimer( 'DestroyMutation11QuenEntity', 2.f );
		}
		mutation11QuenEntity.PlayHitEffect( 'quen_impulse_explode', mutation11QuenEntity.GetWorldRotation() );
		
		if( !skipQuenSign )
		{
			//green heal fx
			PlayEffect( 'mutation_11_second_life' );
			
			//quen bubble
			RestoreQuen( 1000000.f, 10.f, true );
		}
	}
	
	private var mutation11QuenEntity : W3QuenEntity;
	private var storedInteractionPriority : EInteractionPriority;
	
	timer function DestroyMutation11QuenEntity( dt : float, id : int )
	{
		if( mutation11QuenEntity )
		{
			mutation11QuenEntity.Destroy();
		}
	}
	
	event OnAnimEvent_Mutation11AnimEnd( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_DurationEnd )
		{
			//unblock actions
			BlockAllActions( 'Mutation11', false );			
			
			//stop cam shake
			theGame.GetGameCamera().StopAnimation( 'camera_shake_loop_lvl1_1' );
			
			//stop pad vibrations
			theGame.StopVibrateController();
			
			//unpushable
			SetInteractionPriority( storedInteractionPriority );
			
			//remove regen buff
			RemoveBuff( EET_Mutation11Buff, true );
		}
		else if ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle )
		{
			/*	variable is changed to get correct pose to which blending out is done,
				without this line AIControlled will be set after whole animation (including blending out)	*/
			SetBehaviorVariable( 'AIControlled', 0.f );
		}
	}
		
	public final function MutationSystemEnable( enable : bool )
	{
		( ( W3PlayerAbilityManager ) abilityManager ).MutationSystemEnable( enable );
	}
	
	public final function IsMutationSystemEnabled() : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationSystemEnabled();
	}
	
	public final function GetMutation( mutationType : EPlayerMutationType ) : SMutation
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutation( mutationType );
	}
	
	public final function IsMutationActive( mutationType : EPlayerMutationType) : bool
	{
		var swordQuality : int;
		var sword : SItemUniqueId;
		
		if( GetEquippedMutationType() != mutationType )
		{
			return false;
		}
		
		switch( mutationType )
		{
			case EPMT_Mutation4 :
			case EPMT_Mutation5 :
			case EPMT_Mutation7 :
			case EPMT_Mutation8 :
			case EPMT_Mutation10 :
			case EPMT_Mutation11 :
			case EPMT_Mutation12 :
				if( IsInFistFight() )
				{
					return false;
				}
		}
		
		if( mutationType == EPMT_Mutation1 )
		{
			sword = inv.GetCurrentlyHeldSword();			
			swordQuality = inv.GetItemQuality( sword );
			
			//only rare or higher as only such swords are magical in nature
			if( swordQuality < 3 )
			{
				return false;
			}
		}
		
		return true;
	}
		
	public final function SetEquippedMutation( mutationType : EPlayerMutationType ) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).SetEquippedMutation( mutationType );
	}
	
	public final function GetEquippedMutationType() : EPlayerMutationType
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetEquippedMutationType();
	}
	
	public final function CanEquipMutation(mutationType : EPlayerMutationType) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).CanEquipMutation( mutationType );
	}
	
	public final function CanResearchMutation( mutationType : EPlayerMutationType ) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).CanResearchMutation( mutationType );
	}
	
	public final function IsMutationResearched(mutationType : EPlayerMutationType) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).IsMutationResearched( mutationType );
	}
	
	public final function GetMutationResearchProgress(mutationType : EPlayerMutationType) : int
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMutationResearchProgress( mutationType );
	}
	
	public final function GetMasterMutationStage() : int
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).GetMasterMutationStage();
	}
	
	public final function MutationResearchWithSkillPoints(mutation : EPlayerMutationType, skillPoints : int) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).MutationResearchWithSkillPoints( mutation, skillPoints );
	}
	
	public final function MutationResearchWithItem(mutation : EPlayerMutationType, item : SItemUniqueId) : bool
	{
		return ( ( W3PlayerAbilityManager ) abilityManager ).MutationResearchWithItem( mutation, item );
	}
	
	public final function GetMutationLocalizedName( mutationType : EPlayerMutationType ) : string
	{
		var pam : W3PlayerAbilityManager;
		var locKey : name;
	
		pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
		locKey = pam.GetMutationNameLocalizationKey( mutationType );
		
		return GetLocStringByKeyExt( locKey );
	}
	
	public final function GetMutationLocalizedDescription( mutationType : EPlayerMutationType ) : string
	{
		var pam : W3PlayerAbilityManager;
		var locKey : name;
		var arrStr : array< string >;
		var dm : CDefinitionsManagerAccessor;
		var min, max, sp : SAbilityAttributeValue;
		var tmp, tmp2, tox, critBonusDamage, val : float;
		var stats, stats2 : SPlayerOffenseStats;
		var buffPerc, exampleEnemyCount, debuffPerc : int;
	
		pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
		locKey = pam.GetMutationDescriptionLocalizationKey( mutationType );
		dm = theGame.GetDefinitionsManager();
		
		switch( mutationType )
		{
			case EPMT_Mutation1 :
				dm.GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);							
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * min.valueAdditive ) ) );
				break;
				
			case EPMT_Mutation2 :
				sp = GetPowerStatValue( CPS_SpellPower );
				
				//crit chance
				dm.GetAbilityAttributeValue( 'Mutation2', 'crit_chance_factor', min, max );
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * ( min.valueAdditive + sp.valueMultiplicative * min.valueMultiplicative ) ) ) );
				
				//crit dmg - shown as percents of base damage!
				dm.GetAbilityAttributeValue( 'Mutation2', 'crit_damage_factor', min, max );
				critBonusDamage = sp.valueMultiplicative * min.valueMultiplicative;
				
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * critBonusDamage ) ) );
				break;
				
			case EPMT_Mutation3 :
				//AP bonus
				dm.GetAbilityAttributeValue( 'Mutation3', 'attack_power', min, max );
				tmp = min.valueMultiplicative;
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * tmp ) ) );
				
				//max bonus				
				dm.GetAbilityAttributeValue( 'Mutation3', 'maxcap', min, max );
				arrStr.PushBack( NoTrailZeros( RoundMath( 100 * tmp * min.valueAdditive ) ) );
				break;
				
			case EPMT_Mutation4 :
				//dmg per point
				dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
				tmp2 = 100 * min.valueAdditive;
				dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
				tmp2 *= min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( tmp2 ) );
				
				//current dmg bonus, including current toxicity
				tox = GetStat( BCS_Toxicity );
				if( tox > 0 )
				{
					tmp = RoundMath( tmp2 * tox );
				}
				else
				{
					tmp = tmp2;
				}
				arrStr.PushBack( NoTrailZeros( tmp ) );
				
				//max dmg bonus
				tox = GetStatMax( BCS_Toxicity );
				tmp = RoundMath( tmp2 * tox );
				arrStr.PushBack( NoTrailZeros( tmp ) );
				break;
				
			case EPMT_Mutation5 :
				//reduction percents
				dm.GetAbilityAttributeValue( 'Mutation5', 'mut5_dmg_red_perc', min, max );
				tmp = min.valueAdditive;
				arrStr.PushBack( NoTrailZeros( 100 * tmp ) );
				
				//max reduction percents
				arrStr.PushBack( NoTrailZeros( 100 * tmp * 3 ) );
				
				break;
			
			case EPMT_Mutation6 :	
				//freeze chance
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );	
				
				//damage
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
				sp = GetTotalSignSpellPower( S_Magic_1 );
				val = sp.valueAdditive + sp.valueMultiplicative * ( sp.valueBase + min.valueAdditive );
				arrStr.PushBack( NoTrailZeros( RoundMath( val ) ) );	
			
				break;
				
			case EPMT_Mutation7 :
				//buff bonus
				dm.GetAbilityAttributeValue( 'Mutation7Buff', 'attack_power', min, max );
				buffPerc = (int) ( 100 * min.valueMultiplicative );
				arrStr.PushBack( NoTrailZeros( buffPerc ) );
				
				//buff duration
				dm.GetAbilityAttributeValue( 'Mutation7BuffEffect', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				
				//example enemies #
				exampleEnemyCount = 11;
				arrStr.PushBack( exampleEnemyCount );
				
				//example bonus
				arrStr.PushBack( buffPerc * ( exampleEnemyCount -1 ) );
				
				//debuff 'bonus'
				dm.GetAbilityAttributeValue( 'Mutation7Debuff', 'attack_power', min, max );
				debuffPerc = (int) ( - 100 * min.valueMultiplicative );
				arrStr.PushBack( NoTrailZeros( debuffPerc ) );
				
				//max debuff
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation7Debuff', 'minCapStacks', min, max );
				arrStr.PushBack( NoTrailZeros( debuffPerc * min.valueAdditive ) );
				
				//debuff duration
				dm.GetAbilityAttributeValue( 'Mutation7DebuffEffect', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
					
				break;
			
			case EPMT_Mutation8 :
				//damage bonus
				dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				//trigger hp perc
				dm.GetAbilityAttributeValue( 'Mutation8', 'hp_perc_trigger', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				break;
				
			case EPMT_Mutation9 :
				//flat damage bonus
				/*
				dm.GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				*/
				
				//current damage
				stats = GetOffenseStatsList( 1 );
				arrStr.PushBack( NoTrailZeros( RoundMath( stats.crossbowSteelDmg ) ) );
				
				//if active damage
				stats2 = GetOffenseStatsList( 2 );
				arrStr.PushBack( NoTrailZeros( RoundMath( stats2.crossbowSteelDmg ) ) );
				
				//crit chance
				dm.GetAbilityAttributeValue( 'Mutation9', 'critical_hit_chance', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				//hp loss
				dm.GetAbilityAttributeValue( 'Mutation9', 'health_reduction', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				break;
				
			case EPMT_Mutation10 :
				//damage boost perc
				dm.GetAbilityAttributeValue( 'Mutation10Effect', 'mutation10_stat_boost', min, max );
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative ) );
				
				//max bonus potential
				arrStr.PushBack( NoTrailZeros( 100 * min.valueMultiplicative * GetStatMax( BCS_Toxicity ) ) );
				
				break;
				
			case EPMT_Mutation11 :
				//health boost
				arrStr.PushBack( 100 );
				
				//cooldown
				dm.GetAbilityAttributeValue( 'Mutation11DebuffEffect', 'duration', min, max);
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );
				break;
				
			case EPMT_Mutation12 :
				//duration
				dm.GetAbilityAttributeValue( 'Mutation12', 'duration', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );				
				
				//maxcap
				dm.GetAbilityAttributeValue( 'Mutation12', 'maxcap', min, max );
				arrStr.PushBack( NoTrailZeros( min.valueAdditive ) );	
				break;
				
			case EPMT_MutationMaster :
				//number of level-ups possible
				arrStr.PushBack( "4" );
				
				break;
		}
		
		return GetLocStringByKeyExtWithParams( locKey, , , arrStr );
	}
		
	public final function ApplyMutation10StatBoost( out statValue : SAbilityAttributeValue )
	{
		var attValue 			: SAbilityAttributeValue;
		var currToxicity		: float;
		
		if( IsMutationActive( EPMT_Mutation10 ) )
		{
			currToxicity = GetStat( BCS_Toxicity );
			if( currToxicity > 0.f )
			{
				attValue = GetAttributeValue( 'mutation10_stat_boost' );
				currToxicity *= attValue.valueMultiplicative;
				statValue.valueMultiplicative += currToxicity;
			}
		}
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// @Books:: tracking newly added books to the glossary 
	//
	////////////////////////////////////////////////////////////////////////////////	

	public final function IsBookRead( bookName : name ):bool
	{
		return booksRead.Contains( bookName );
	}	
	
	public final function AddReadBook( bookName : name ):void
	{
		if( !booksRead.Contains( bookName ) )
		{
			booksRead.PushBack( bookName );
		}
	}
	
	public final function RemoveReadBook( bookName : name ):void
	{
		var idx : int = booksRead.FindFirst( bookName );
		
		if( idx > -1 )
		{
			booksRead.Erase( idx );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// @Alchemy
	//
	////////////////////////////////////////////////////////////////////////////////
	
	public final function GetMutagenBuffs() : array< W3Mutagen_Effect >
	{
		var null : array< W3Mutagen_Effect >;
		
		if(effectManager)
		{
			return effectManager.GetMutagenBuffs();
		}
	
		return null;
	}
	
	public function GetAlchemyRecipes() : array<name>
	{
		return alchemyRecipes;
	}
		
	public function CanLearnAlchemyRecipe(recipeName : name) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var recipeNode : SCustomNode;
		var i, tmpInt : int;
		var tmpName : name;
	
		dm = theGame.GetDefinitionsManager();
		if ( dm.GetSubNodeByAttributeValueAsCName( recipeNode, 'alchemy_recipes', 'name_name', recipeName ) )
		{
			return true;
			/*
			unused perk 8
			if(dm.GetCustomNodeAttributeValueInt( recipeNode, 'level', tmpInt))
			{
				if(tmpInt >= 3)
				{
					return CanUseSkill(S_Perk_08);
				}
				else
				{
					return true;
				}
			}
			else
			{
				return true;
			}
			*/
		}
		
		return false;
	}
	
	private final function RemoveAlchemyRecipe(recipeName : name)
	{
		alchemyRecipes.Remove(recipeName);
	}
	
	private final function RemoveAllAlchemyRecipes()
	{
		alchemyRecipes.Clear();
	}

	/**
		Adds new recipe to the book. Returns true if the recipe was added, false if it's already in the book.
	*/
	function AddAlchemyRecipe(nam : name, optional isSilent : bool, optional skipTutorialUpdate : bool) : bool
	{
		var i, potions, bombs : int;
		var found : bool;
		var m_alchemyManager : W3AlchemyManager;
		var recipe : SAlchemyRecipe;
		var knownBombTypes : array<string>;
		var strRecipeName, recipeNameWithoutLevel : string;
		
		if(!IsAlchemyRecipe(nam))
			return false;
		
		found = false;
		for(i=0; i<alchemyRecipes.Size(); i+=1)
		{
			if(alchemyRecipes[i] == nam)
				return false;
			
			//found a place to insert
			if(StrCmp(alchemyRecipes[i],nam) > 0)
			{
				alchemyRecipes.Insert(i,nam);
				found = true;
				AddAlchemyHudNotification(nam,isSilent);
				break;
			}			
		}	

		if(!found)
		{
			alchemyRecipes.PushBack(nam);
			AddAlchemyHudNotification(nam,isSilent);
		}
		
		m_alchemyManager = new W3AlchemyManager in this;
		m_alchemyManager.Init(alchemyRecipes);
		m_alchemyManager.GetRecipe(nam, recipe);
			
		//skill toxicity increase
		if(CanUseSkill(S_Alchemy_s18))
		{
			if ((recipe.cookedItemType != EACIT_Bolt) && (recipe.cookedItemType != EACIT_Undefined) && (recipe.level <= GetSkillLevel(S_Alchemy_s18)))
				AddAbility(SkillEnumToName(S_Alchemy_s18), true);
			
		}
		
		//achievement for learning - need to do a full pass due to desync between RC and patch versions
		if(recipe.cookedItemType == EACIT_Bomb)
		{
			bombs = 0;
			for(i=0; i<alchemyRecipes.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
				
				//bombs are unique
				if(recipe.cookedItemType == EACIT_Bomb)
				{
					strRecipeName = NameToString(alchemyRecipes[i]);
					recipeNameWithoutLevel = StrLeft(strRecipeName, StrLen(strRecipeName)-2);
					if(!knownBombTypes.Contains(recipeNameWithoutLevel))
					{
						bombs += 1;
						knownBombTypes.PushBack(recipeNameWithoutLevel);
					}
				}
			}
			
			theGame.GetGamerProfile().SetStat(ES_KnownBombRecipes, bombs);
		}		
		//achievement for learning - need to do a full pass due to desync between RC and patch versions
		else if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
		{
			potions = 0;
			for(i=0; i<alchemyRecipes.Size(); i+=1)
			{
				m_alchemyManager.GetRecipe(alchemyRecipes[i], recipe);
				
				//potions are not unique
				if(recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Quest)
				{
					potions += 1;
				}				
			}		
			theGame.GetGamerProfile().SetStat(ES_KnownPotionRecipes, potions);
		}
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_AlchemyRecipe );
				
		return true;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// Combat Actions GUI Mediator //#B
	// 
	//////////////////////////////////////////////////////////////////////////////////////////
	
	public function GetDisplayHeavyAttackIndicator() : bool
	{
		return bDispalyHeavyAttackIndicator;
	}

	public function SetDisplayHeavyAttackIndicator( val : bool ) 
	{
		bDispalyHeavyAttackIndicator = val;
	}

	public function GetDisplayHeavyAttackFirstLevelTimer() : bool
	{
		return bDisplayHeavyAttackFirstLevelTimer;
	}

	public function SetDisplayHeavyAttackFirstLevelTimer( val : bool ) 
	{
		bDisplayHeavyAttackFirstLevelTimer = val;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// Witcher's Throw Item Mechanics
	// 
	//////////////////////////////////////////////////////////////////////////////////////////

	public function SelectQuickslotItem( slot : EEquipmentSlots )
	{
		var item : SItemUniqueId;
	
		GetItemEquippedOnSlot(slot, item);
		selectedItemId = item;			//invalid if no item
	}	
	
	/////////////////////////////////////////////////////////////////////////////////
	//
	//	MEDALLION
	//
	/////////////////////////////////////////////////////////////////////////////////
	
	public function GetMedallion() : W3MedallionController
	{
		if ( !medallionController )
		{
			medallionController = new W3MedallionController in this;
		}
		return medallionController;
	}
	
	// Medallion highlighted objects
	public final function HighlightObjects(range : float, optional highlightTime : float )
	{
		var ents : array<CGameplayEntity>;
		var i : int;

		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), range, 100, 'HighlightedByMedalionFX', FLAG_ExcludePlayer);

		if(highlightTime == 0)
			highlightTime = 30;
		
		for(i=0; i<ents.Size(); i+=1)
		{
			if(!ents[i].IsHighlighted())
			{
				ents[i].SetHighlighted( true );
				ents[i].PlayEffectSingle( 'medalion_detection_fx' );
				ents[i].AddTimer( 'MedallionEffectOff', highlightTime );
			}
		}
	}
	
	// highlighted enemies
	public final function HighlightEnemies(range : float, optional highlightTime : float )
	{
		var ents : array<CGameplayEntity>;
		var i : int;
		var catComponent : CGameplayEffectsComponent;

		FindGameplayEntitiesInSphere(ents, GetWorldPosition(), range, 100, , FLAG_ExcludePlayer + FLAG_OnlyAliveActors);

		if(highlightTime == 0)
			highlightTime = 5;
		
		for(i=0; i<ents.Size(); i+=1)
		{
			if(IsRequiredAttitudeBetween(this, ents[i], true))
			{
				catComponent = GetGameplayEffectsComponent(ents[i]);
				if(catComponent)
				{
					catComponent.SetGameplayEffectFlag(EGEF_CatViewHiglight, true);
					ents[i].AddTimer( 'EnemyHighlightOff', highlightTime, , , , , true );
				}
			}
		}
	}	
	
	function SpawnMedallionEntity()
	{
		var rot					: EulerAngles;
		var spawnedMedallion	: CEntity;
				
		spawnedMedallion = theGame.GetEntityByTag( 'new_Witcher_medallion_FX' ); 
		
		if ( !spawnedMedallion )
			theGame.CreateEntity( medallionEntity, GetWorldPosition(), rot, true, false );
	}
	
	/////////////////////////////////////////////////////////////////////////////////
	//
	//	COMBAT FOCUS
	//
	/////////////////////////////////////////////////////////////////////////////////
	
	// Yes! Empty space!
	
	public final function InterruptCombatFocusMode()
	{
		if( this.GetCurrentStateName() == 'CombatFocusMode_SelectSpot' )
		{	
			SetCanPlayHitAnim( true );
			PopState();
		}
	}
	
	public final function IsInDarkPlace() : bool
	{
		var envs : array< string >;
		
		if( FactsQuerySum( "tut_in_dark_place" ) )
		{
			return true;
		}
		
		GetActiveAreaEnvironmentDefinitions( envs );
		
		if( envs.Contains( 'env_novigrad_cave' ) || envs.Contains( 'cave_catacombs' ) )
		{
			return true;
		}
		
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////  @EQUIPMENT @SLOTS @ITEMS   ////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private saved var selectedPotionSlotUpper, selectedPotionSlotLower : EEquipmentSlots;
	private var potionDoubleTapTimerRunning, potionDoubleTapSlotIsUpper : bool;
		default selectedPotionSlotUpper = EES_Potion1;
		default selectedPotionSlotLower = EES_Potion2;
		default potionDoubleTapTimerRunning = false;
	
	public final function SetPotionDoubleTapRunning(b : bool, optional isUpperSlot : bool)
	{
		if(b)
		{
			AddTimer('PotionDoubleTap', 0.3);
		}
		else
		{
			RemoveTimer('PotionDoubleTap');
		}
		
		potionDoubleTapTimerRunning = b;
		potionDoubleTapSlotIsUpper = isUpperSlot;
	}
	
	public final function IsPotionDoubleTapRunning() : bool
	{
		return potionDoubleTapTimerRunning;
	}
	
	timer function PotionDoubleTap(dt : float, id : int)
	{
		potionDoubleTapTimerRunning = false;
		OnPotionDrinkInput(potionDoubleTapSlotIsUpper);
	}
	
	public final function OnPotionDrinkInput(fromUpperSlot : bool)
	{
		var slot : EEquipmentSlots;
		
		if(fromUpperSlot)
			slot = GetSelectedPotionSlotUpper();
		else
			slot = GetSelectedPotionSlotLower();
			
		DrinkPotionFromSlot(slot);
	}
	
	public final function OnPotionDrinkKeyboardsInput(slot : EEquipmentSlots)
	{
		DrinkPotionFromSlot(slot);
	}
	
	private function DrinkPotionFromSlot(slot : EEquipmentSlots):void
	{
		var item : SItemUniqueId;		
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleItemInfo;
		
		GetItemEquippedOnSlot(slot, item);
		if(inv.ItemHasTag(item, 'Edibles'))
		{
			ConsumeItem( item );
		}
		else
		{			
			if (ToxicityLowEnoughToDrinkPotion(slot))
			{
				DrinkPreparedPotion(slot);
			}
			else
			{
				SendToxicityTooHighMessage();
			}
		}
		
		hud = (CR4ScriptedHud)theGame.GetHud(); 
		if ( hud ) 
		{ 
			module = (CR4HudModuleItemInfo)hud.GetHudModule("ItemInfoModule");
			if( module )
			{
				module.ForceShowElement();
			}
		}
	}
	
	private function SendToxicityTooHighMessage()
	{
		var messageText : string;
		var language : string;
		var audioLanguage : string;
		
		if (GetHudMessagesSize() < 2)
		{
			messageText = GetLocStringByKeyExt("menu_cannot_perform_action_now") + " " + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity");
			
			theGame.GetGameLanguageName(audioLanguage,language);
			if (language == "AR")
			{
				messageText += (int)(abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(abilityManager.GetStatMax(BCS_Toxicity)) + " :";
			}
			else
			{
				messageText += ": " + (int)(abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(abilityManager.GetStatMax(BCS_Toxicity));
			}
			
			DisplayHudMessage(messageText);
		}
		theSound.SoundEvent("gui_global_denied");
	}
	
	public final function GetSelectedPotionSlotUpper() : EEquipmentSlots
	{
		return selectedPotionSlotUpper;
	}
	
	public final function GetSelectedPotionSlotLower() : EEquipmentSlots
	{
		return selectedPotionSlotLower;
	}
	
	//Flips selected potion between two slots (upper or lower). Returns true if flip actually occured.
	public final function FlipSelectedPotion(isUpperSlot : bool) : bool
	{
		if(isUpperSlot)
		{
			if(selectedPotionSlotUpper == EES_Potion1 && IsAnyItemEquippedOnSlot(EES_Potion3))
			{
				selectedPotionSlotUpper = EES_Potion3;
				return true;
			}
			else if(selectedPotionSlotUpper == EES_Potion3 && IsAnyItemEquippedOnSlot(EES_Potion1))
			{
				selectedPotionSlotUpper = EES_Potion1;
				return true;
			}
		}
		else
		{
			if(selectedPotionSlotLower == EES_Potion2 && IsAnyItemEquippedOnSlot(EES_Potion4))
			{
				selectedPotionSlotLower = EES_Potion4;
				return true;
			}
			else if(selectedPotionSlotLower == EES_Potion4 && IsAnyItemEquippedOnSlot(EES_Potion2))
			{
				selectedPotionSlotLower = EES_Potion2;
				return true;
			}
		}
		
		return false;
	}
	
	public final function AddBombThrowDelay( bombId : SItemUniqueId )
	{
		var slot : EEquipmentSlots;
		
		slot = GetItemSlot( bombId );
		
		if( slot == EES_Unused )
		{
			return;
		}
			
		if( slot == EES_Petard1 || slot == EES_Quickslot1 )
		{
			remainingBombThrowDelaySlot1 = theGame.params.BOMB_THROW_DELAY;
			AddTimer( 'BombDelay', 0.0f, true );
		}
		else if( slot == EES_Petard2 || slot == EES_Quickslot2 )
		{
			remainingBombThrowDelaySlot2 = theGame.params.BOMB_THROW_DELAY;
			AddTimer( 'BombDelay', 0.0f, true );
		}
		else
		{
			return;
		}
	}
	
	public final function GetBombDelay( slot : EEquipmentSlots ) : float
	{
		if( slot == EES_Petard1 || slot == EES_Quickslot1 )
		{
			return remainingBombThrowDelaySlot1;
		}
		else if( slot == EES_Petard2 || slot == EES_Quickslot2 )
		{
			return remainingBombThrowDelaySlot2;
		}
		
		return 0;
	}
	
	timer function BombDelay( dt : float, id : int )
	{
		remainingBombThrowDelaySlot1 = MaxF( 0.f , remainingBombThrowDelaySlot1 - dt );
		remainingBombThrowDelaySlot2 = MaxF( 0.f , remainingBombThrowDelaySlot2 - dt );
		
		if( remainingBombThrowDelaySlot1 <= 0.0f && remainingBombThrowDelaySlot2  <= 0.0f )
		{
			RemoveTimer('BombDelay');
		}
	}
	
	public function ResetCharacterDev()
	{
		//char dev mutagens
		UnequipItemFromSlot(EES_SkillMutagen1);
		UnequipItemFromSlot(EES_SkillMutagen2);
		UnequipItemFromSlot(EES_SkillMutagen3);
		UnequipItemFromSlot(EES_SkillMutagen4);
		
		levelManager.ResetCharacterDev();
		((W3PlayerAbilityManager)abilityManager).ResetCharacterDev();		
	}
	
	public final function ResetMutationsDev()
	{
		levelManager.ResetMutationsDev();
		((W3PlayerAbilityManager)abilityManager).ResetMutationsDev();
	}
	
	public final function GetHeldSword() : SItemUniqueId
	{
		var i : int;
		var weapons : array< SItemUniqueId >;
		
		weapons = inv.GetHeldWeapons();
		for( i=0; i<weapons.Size(); i+=1 )
		{
			if( inv.IsItemSilverSwordUsableByPlayer( weapons[i] ) || inv.IsItemSteelSwordUsableByPlayer( weapons[i] ) )
			{
				return weapons[i];
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public function ConsumeItem( itemId : SItemUniqueId ) : bool
	{
		var itemName : name;
		var removedItem, willRemoveItem : bool;
		var edibles : array<SItemUniqueId>;
		var toSlot : EEquipmentSlots;
		var i : int;
		var equippedNewEdible : bool;
		
		itemName = inv.GetItemName( itemId );
		
		if (itemName == 'q111_imlerith_acorn' ) // MEGA HACK STARTS
		{
			AddPoints(ESkillPoint, 2, true);
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_title_buy_skill") + "<br>" + GetLocStringByKeyExt("panel_character_availablepoints") + " +2");
			theSound.SoundEvent("gui_character_buy_skill"); // #J Not sure if best sound, but its better than no sound
		} 
		else if ( itemName == 'Clearing Potion' ) 
		{
			ResetCharacterDev();
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_character_cleared") );
			theSound.SoundEvent("gui_character_synergy_effect"); // #J Not sure if best sound, but its better than no sound
		}
		else if ( itemName == 'Restoring Potion' ) 
		{
			ResetMutationsDev();
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_character_cleared") );
			theSound.SoundEvent("gui_character_synergy_effect"); // #J Not sure if best sound, but its better than no sound
		}
		else if(itemName == 'Wolf Hour')
		{
			removedItem = inv.RemoveItem( itemId, 1 );
			theSound.SoundEvent("gui_character_synergy_effect"); // #J Not sure if best sound, but its better than no sound
			AddEffectDefault(EET_WolfHour, thePlayer, 'wolf hour');
		}
		else if ( itemName == 'q704_ft_golden_egg' )
		{
			AddPoints(ESkillPoint, 1, true);
			removedItem = inv.RemoveItem( itemId, 1 );
			theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_character_popup_title_buy_skill") + "<br>" + GetLocStringByKeyExt("panel_character_availablepoints") + " +1");
			theSound.SoundEvent("gui_character_buy_skill"); // #J Not sure if best sound, but its better than no sound
		} 
		else if ( itemName == 'mq7023_cake' )
		{
			this.AddAbility('mq7023_cake_vitality_bonus');
			removedItem = inv.RemoveItem( itemId, 1 );
			theSound.SoundEvent("gui_character_synergy_effect");
		}
		else
		{
			willRemoveItem = inv.GetItemQuantity(itemId) == 1 && !inv.ItemHasTag(itemId, 'InfiniteUse');
			
			if(willRemoveItem)
				toSlot = GetItemSlot(itemId);
				
			removedItem = super.ConsumeItem(itemId);
			
			if(willRemoveItem && removedItem)
			{
				edibles = inv.GetItemsByTag('Edibles');
				equippedNewEdible = false;
				
				//look for non-alcohol
				for(i=0; i<edibles.Size(); i+=1)
				{
					if(!IsItemEquipped(edibles[i]) && !inv.ItemHasTag(edibles[i], 'Alcohol') && inv.GetItemName(edibles[i]) != 'Clearing Potion' && inv.GetItemName(edibles[i]) != 'Wolf Hour')
					{
						EquipItemInGivenSlot(edibles[i], toSlot, true, false);
						equippedNewEdible = true;
						break;
					}
				}
				
				//take alco if only has alco
				if(!equippedNewEdible)
				{
					for(i=0; i<edibles.Size(); i+=1)
					{
						if(!IsItemEquipped(edibles[i]) && inv.GetItemName(edibles[i]) != 'Clearing Potion' && inv.GetItemName(edibles[i]) != 'Wolf Hour')
						{
							EquipItemInGivenSlot(edibles[i], toSlot, true, false);
							break;
						}
					}
				}
			}
		}
		
		return removedItem;
	}
	
	//returns item ID (or empty if none) of item that can be used to refill alchemical items in meditation
	public final function GetAlcoholForAlchemicalItemsRefill() : SItemUniqueId
	{
		var alcos : array<SItemUniqueId>;
		var id : SItemUniqueId;
		var i, price, minPrice : int;
		
		alcos = inv.GetItemsByTag(theGame.params.TAG_ALCHEMY_REFILL_ALCO);
		
		if(alcos.Size() > 0)
		{
			if(inv.ItemHasTag(alcos[0], theGame.params.TAG_INFINITE_USE))
				return alcos[0];
				
			minPrice = inv.GetItemPrice(alcos[0]);
			price = minPrice;
			id = alcos[0];
			
			for(i=1; i<alcos.Size(); i+=1)
			{
				if(inv.ItemHasTag(alcos[i], theGame.params.TAG_INFINITE_USE))
					return alcos[i];
				
				price = inv.GetItemPrice(alcos[i]);
				
				if(price < minPrice)
				{
					minPrice = price;
					id = alcos[i];
				}
			}
			
			return id;
		}
		
		return GetInvalidUniqueId();
	}
	
	public final function ClearPreviouslyUsedBolt()
	{
		previouslyUsedBolt = GetInvalidUniqueId();
	}
	
	public function GetCurrentInfiniteBoltName( optional forceBodkin : bool, optional forceHarpoon : bool ) : name
	{
		if(!forceBodkin && (forceHarpoon || GetCurrentStateName() == 'Swimming' || IsSwimming() || IsDiving()) )
		{
			return 'Harpoon Bolt';
		}
		return 'Bodkin Bolt';
	}
	
	//adds and equips infinite bolts of proper type
	public final function AddAndEquipInfiniteBolt(optional forceBodkin : bool, optional forceHarpoon : bool)
	{
		var bolt, bodkins, harpoons : array<SItemUniqueId>;
		var boltItemName : name;
		var i : int;
		
		//failsafe - remove any infinite bolts if they're in inventory for some reason
		bodkins = inv.GetItemsByName('Bodkin Bolt');
		harpoons = inv.GetItemsByName('Harpoon Bolt');
		
		for(i=bodkins.Size()-1; i>=0; i-=1)
			inv.RemoveItem(bodkins[i], inv.GetItemQuantity(bodkins[i]) );
			
		for(i=harpoons.Size()-1; i>=0; i-=1)
			inv.RemoveItem(harpoons[i], inv.GetItemQuantity(harpoons[i]) );
			
		//Check which bolt is needed.
		//Note: all three checks for swimming are NOT guaranteed to work, hence optional force flags
		boltItemName = GetCurrentInfiniteBoltName( forceBodkin, forceHarpoon );
		
		//select previous special ammo
		if(boltItemName == 'Bodkin Bolt' && inv.IsIdValid(previouslyUsedBolt))
		{
			bolt.PushBack(previouslyUsedBolt);
		}
		else
		{
			//add bolt
			bolt = inv.AddAnItem(boltItemName, 1, true, true);
			
			//if harpoon then we store previously used special bolt if any to restore once we leave water
			if(boltItemName == 'Harpoon Bolt')
			{
				GetItemEquippedOnSlot(EES_Bolt, previouslyUsedBolt);
			}
		}
		
		EquipItem(bolt[0], EES_Bolt);
	}
	
	//called when item is added to players inventory through ANY means
	event OnItemGiven(data : SItemChangedData)
	{
		var m_guiManager 	: CR4GuiManager;
		
		super.OnItemGiven(data);
		
		//player object may not exist at this point. As much as impossible that sounds - it does happen (as a result inv is not set)
		if(!inv)
			inv = GetInventory();
		
		//update encumbrance
		if(inv.IsItemEncumbranceItem(data.ids[0]))
			UpdateEncumbrance();
		
		m_guiManager = theGame.GetGuiManager();
		if(m_guiManager)
			m_guiManager.RegisterNewItem(data.ids[0]);
	}
		
	//checks progress towards FullyArmed achievement and gives it if applicable
	public final function CheckForFullyArmedAchievement()
	{
		if( HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_BEAR) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_GRYPHON) || 
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_LYNX) || HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_WOLF) ||
			HasAllItemsFromSet(theGame.params.ITEM_SET_TAG_VIPER)
		)
		{
			theGame.GetGamerProfile().AddAchievement(EA_FullyArmed);
		}
	}
	
	//checks if player has all items from witcher set with given tag equipped
	public final function HasAllItemsFromSet(setItemTag : name) : bool
	{
		var item : SItemUniqueId;
		
		if(!GetItemEquippedOnSlot(EES_SteelSword, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
		
		if(!GetItemEquippedOnSlot(EES_SilverSword, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Boots, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Pants, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Gloves, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		if(!GetItemEquippedOnSlot(EES_Armor, item) || !inv.ItemHasTag(item, setItemTag))
			return false;
			
		//hack for some sets having also a crossbow
		if(setItemTag == theGame.params.ITEM_SET_TAG_BEAR || setItemTag == theGame.params.ITEM_SET_TAG_LYNX)
		{
			if(!GetItemEquippedOnSlot(EES_RangedWeapon, item) || !inv.ItemHasTag(item, setItemTag))
				return false;
		}

		return true;
	}
	
	/* few nice checks are in here so I leave it for the time being
	private function CanPlaceMobileCampfire(out position : Vector) : bool
	{
		var colPos, normal, headPosition : Vector;
		var world : CWorld;
		var test : float;
	
		position = Vector(0, 0, 0);
		
		//check if is allowed to place it at all
		if(GetCurrentStateName() != 'Exploration' || isOnBoat || IsInInterior() || IsInSettlement())
			return false;
			
		//ground test
		position = GetWorldPosition() + VecNormalize(GetHeadingVector()) * 0.5;
		world = theGame.GetWorld();
		
		if(!world.StaticTrace(position + Vector(0,0,1), position - Vector(0,0,0.5), colPos, normal))
			return false;	//void cannot place
			
		position = colPos;	//snapped to ground position
		
		//underwater
		test = world.GetWaterLevel(position, true);
		
		if(position.Z <= world.GetWaterLevel(position, true))
			return false;
		
		//not navigable area - cannot reach so most likely no place
		if(!world.NavigationCircleTest(position, 0.4))
			return false;
			
		//actor occupies that spot - cannot place
		if(!theGame.TestNoCreaturesOnLocation(position, 0.4, this))
			return false;
			
		//behind wall - line of sight check
		headPosition = GetBoneWorldPosition('head');
		if(world.StaticTrace(headPosition, position, colPos, normal ) )
		{
			//small deviation is fine
			if(VecDistance(colPos, position) > 0.1)			
				return false;
		}
			
		return true;
	}
	*/
	
	//returns total armor
	public function GetTotalArmor() : SAbilityAttributeValue
	{
		var armor : SAbilityAttributeValue;
		var armorItem : SItemUniqueId;
		
		armor = super.GetTotalArmor();
		
		if(GetItemEquippedOnSlot(EES_Armor, armorItem))
		{
			//subtract base item armor
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			//add real armor
			armor += inv.GetItemArmorTotal(armorItem);			
		}
		
		if(GetItemEquippedOnSlot(EES_Pants, armorItem))
		{
			//subtract base item armor
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			//add real armor
			armor += inv.GetItemArmorTotal(armorItem);			
		}
			
		if(GetItemEquippedOnSlot(EES_Boots, armorItem))
		{
			//subtract base item armor
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			//add real armor
			armor += inv.GetItemArmorTotal(armorItem);			
		}
			
		if(GetItemEquippedOnSlot(EES_Gloves, armorItem))
		{
			//subtract base item armor
			armor -= inv.GetItemAttributeValue(armorItem, theGame.params.ARMOR_VALUE_NAME);
			
			//add real armor
			armor += inv.GetItemArmorTotal(armorItem);			
		}
			
		return armor;
	}
	
	//Picks random armor item and reduces its durability.
	//Returns slot of the item that got reduced or EES_InvalidSlot if nothing reduced 
	public function ReduceArmorDurability() : EEquipmentSlots
	{
		var r, sum : int;
		var slot : EEquipmentSlots;
		var id : SItemUniqueId;
		var prevDurMult, currDurMult, ratio : float;
	
		//pick item slot
		sum = theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_BOOTS_WEIGHT;
		sum += theGame.params.DURABILITY_ARMOR_MISS_WEIGHT;
		
		r = RandRange(sum);
		
		if(r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT)
			slot = EES_Armor;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT)
			slot = EES_Pants;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT + theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT)
			slot = EES_Gloves;
		else if (r < theGame.params.DURABILITY_ARMOR_CHEST_WEIGHT + theGame.params.DURABILITY_ARMOR_PANTS_WEIGHT + theGame.params.DURABILITY_ARMOR_GLOVES_WEIGHT + theGame.params.DURABILITY_ARMOR_BOOTS_WEIGHT)
			slot = EES_Boots;
		else
			return EES_InvalidSlot;					//theGame.params.DURABILITY_ARMOR_MISS_WEIGHT
		
		GetItemEquippedOnSlot(slot, id);				
		ratio = inv.GetItemDurabilityRatio(id);		//ratio before reduction
		if(inv.ReduceItemDurability(id))			//auto-handles invalid id and no defined durability
		{
			prevDurMult = theGame.params.GetDurabilityMultiplier(ratio, false);
			
			ratio = inv.GetItemDurabilityRatio(id);
			currDurMult = theGame.params.GetDurabilityMultiplier(ratio, false);
			
			if(currDurMult != prevDurMult)
			{
				//if durability threshold changed then recalc resists
				
				//currently affects only armor
				//((W3PlayerAbilityManager)abilityManager).RecalcItemResistDurability(slot, id);
			}
				
			return slot;
		}
		
		return EES_InvalidSlot;
	}
	
	//returns true if item was dismantled
	public function DismantleItem(dismantledItem : SItemUniqueId, toolItem : SItemUniqueId) : bool
	{
		var parts : array<SItemParts>;
		var i : int;
		
		if(!inv.IsItemDismantleKit(toolItem))
			return false;
		
		parts = inv.GetItemRecyclingParts(dismantledItem);
		
		if(parts.Size() <= 0)
			return false;
			
		for(i=0; i<parts.Size(); i+=1)
			inv.AddAnItem(parts[i].itemName, parts[i].quantity, true, false);
			
		inv.RemoveItem(toolItem);
		inv.RemoveItem(dismantledItem);
		return true;
	}
	
	//gets item from given slot to out param *item*, returns true if the ID is valid
	public function GetItemEquippedOnSlot(slot : EEquipmentSlots, out item : SItemUniqueId) : bool
	{
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots'))
			return false;
		
		item = itemSlots[slot];
		
		return inv.IsIdValid(item);
	}
	
	//returns slot on which this item is equipped or invalid if this item is not equipped or player does not have it
	public function GetItemSlotByItemName(itemName : name) : EEquipmentSlots
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		var slot : EEquipmentSlots;
		
		ids = inv.GetItemsByName(itemName);
		for(i=0; i<ids.Size(); i+=1)
		{
			slot = GetItemSlot(ids[i]);
			if(slot != EES_InvalidSlot)
				return slot;
		}
		
		return EES_InvalidSlot;
	}
	
	//returns slot on which this item is equipped or invalid if this item is not equipped or item id is invalid
	public function GetItemSlot(item : SItemUniqueId) : EEquipmentSlots
	{
		var i : int;
		
		if(!inv.IsIdValid(item))
			return EES_InvalidSlot;
			
		for(i=0; i<itemSlots.Size(); i+=1)
			if(itemSlots[i] == item)
				return i;
		
		return EES_InvalidSlot;
	}
	
	public function GetEquippedItems() : array<SItemUniqueId>
	{
		return itemSlots;
	}
	
	public function IsItemEquipped(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		return itemSlots.Contains(item);
	}

	public function IsItemHeld(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		return inv.IsItemHeld(item);
	}

	//returns true if any item is equipped on given slot
	public function IsAnyItemEquippedOnSlot(slot : EEquipmentSlots) : bool
	{
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots'))
			return false;
			
		return inv.IsIdValid(itemSlots[slot]);
	}
	
	//returns next free quickslot or EES_InvalidSlot if all are occupied
	public function GetFreeQuickslot() : EEquipmentSlots
	{
		if(!inv.IsIdValid(itemSlots[EES_Quickslot1]))		return EES_Quickslot1;
		if(!inv.IsIdValid(itemSlots[EES_Quickslot2]))		return EES_Quickslot2;
		/*if(!inv.IsIdValid(itemSlots[EES_Quickslot3]))		return EES_Quickslot3;
		if(!inv.IsIdValid(itemSlots[EES_Quickslot4]))		return EES_Quickslot4;
		if(!inv.IsIdValid(itemSlots[EES_Quickslot5]))		return EES_Quickslot5;*/
		
		return EES_InvalidSlot;
	}
	
	// Used by things like cut scenes which may mount things independently
	event OnEquipItemRequested(item : SItemUniqueId, ignoreMount : bool)
	{
		var slot : EEquipmentSlots;
		
		if(inv.IsIdValid(item))
		{
			slot = inv.GetSlotForItemId(item);
				
			if (slot != EES_InvalidSlot)
			{
				//#J [WARNING] might want to eventually add a parameter for toHand, currently ignoreMount is always false so it doesn't matter 
				//(trying to fix P0 quickly so covering hypothetical uses that may never come to be seems like waste of time)
				EquipItemInGivenSlot(item, slot, ignoreMount);
			}
		}
	} 
	
	event OnUnequipItemRequested(item : SItemUniqueId)
	{
		UnequipItem(item);
	}
	
	/*
		Equips given item. If you don't provide the slot it will find appropriate one and equip there. 
		If it's a multiple slot group (e.g. quickslots or potion slots) it will try to find next free slot. If it cannot then the default slot
		will be used.
		
		If toHand is set then given item will be made *held*, that is it's entity will be put in witcher hands.
		
		Returns true if item was successfully equipped.
	*/
	public function EquipItem(item : SItemUniqueId, optional slot : EEquipmentSlots, optional toHand : bool) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
			
		if(slot == EES_InvalidSlot)
		{
			slot = inv.GetSlotForItemId(item);
			
			if(slot == EES_InvalidSlot)
				return false;
		}
		
		ForceSoundAppearanceUpdate();
		
		return EquipItemInGivenSlot(item, slot, false, toHand);
	}
	
	protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		//AK: don't mount potion mutagens in inventory	
		//PB: don't mount usable items (will be mounted on use)
		return !IsSlotPotionMutagen(slot) && category != 'usable' && category != 'potion' && category != 'petard' && !inv.ItemHasTag(item, 'PlayerUnwearable');
	}
		
	protected function ShouldMountItemWithName( itemName: name ): bool
	{
		var slot : EEquipmentSlots;
		var items : array<SItemUniqueId>;
		var category : name;
		var i : int;
		
		items = inv.GetItemsByName( itemName );
		
		category = inv.GetItemCategory( items[0] );
		
		slot = GetItemSlot( items[0] );
		
		return ShouldMount( slot, items[0], category );
	}	
	
	public function GetMountableItems( out items : array< SItemUniqueId > )
	{
		var i : int;
		var mountable : bool;
		var mountableItems : array< SItemUniqueId >;
		var slot : EEquipmentSlots;
		var category : name;
		var item: SItemUniqueId;
		
		for ( i = 0; i < items.Size(); i += 1 )
		{
			item = items[i];
		
			category = inv.GetItemCategory( item );
		
			slot = GetItemSlot( item );
		
			mountable = ShouldMount( slot, item, category );
		
			if ( mountable )
			{
				mountableItems.PushBack( items[ i ] );
			}
		}
		items = mountableItems;
	}
	
	public final function AddAndEquipItem( item : name ) : bool
	{
		var ids : array< SItemUniqueId >;
		
		ids = inv.AddAnItem( item );
		if( inv.IsIdValid( ids[ 0 ] ) )
		{
			return EquipItem( ids[ 0 ] );
		}
		
		return false;
	}
	
	public final function AddQuestMarkedSelectedQuickslotItem( sel : SSelectedQuickslotItem )
	{
		questMarkedSelectedQuickslotItems.PushBack( sel );
	}
	
	public final function GetQuestMarkedSelectedQuickslotItem( sourceName : name ) : SItemUniqueId
	{
		var i : int;
		
		for( i=0; i<questMarkedSelectedQuickslotItems.Size(); i+=1 )
		{
			if( questMarkedSelectedQuickslotItems[i].sourceName == sourceName )
			{
				return questMarkedSelectedQuickslotItems[i].itemID;
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	public final function SwapEquippedItems(slot1 : EEquipmentSlots, slot2 : EEquipmentSlots)
	{
		var temp : SItemUniqueId;
		var pam : W3PlayerAbilityManager;
		
		temp = itemSlots[slot1];
		itemSlots[slot1] = itemSlots[slot2];
		itemSlots[slot2] = temp;
		
		if(IsSlotSkillMutagen(slot1))
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			if(pam)
				pam.OnSwappedMutagensPost(itemSlots[slot1], itemSlots[slot2]);
		}
	}
	
	public final function GetSlotForEquippedItem( itemID : SItemUniqueId ) : EEquipmentSlots
	{
		var i : int;
		
		for( i=0; i<itemSlots.Size(); i+=1 )
		{
			if( itemSlots[i] == itemID )
			{
				return i;
			}
		}
		
		return EES_InvalidSlot;
	}
	
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{			
		var i, groupID : int;
		var fistsID : array<SItemUniqueId>;
		var pam : W3PlayerAbilityManager;
		var isSkillMutagen : bool;		
		var armorEntity : CItemEntity;
		var armorMeshComponent : CComponent;
		var armorSoundIdentification : name;
		var category : name;
		var prevSkillColor : ESkillColor;
		var containedAbilities : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var armorType : EArmorType;
		var otherMask, previousItemInSlot : SItemUniqueId;
		var tutStatePot : W3TutorialManagerUIHandlerStatePotions;
		var tutStateFood : W3TutorialManagerUIHandlerStateFood;
		var tutStateSecondPotionEquip : W3TutorialManagerUIHandlerStateSecondPotionEquip;
		var boltItem : SItemUniqueId;
		var aerondight : W3Effect_Aerondight;
		
		if(!inv.IsIdValid(item))
		{
			LogAssert(false, "W3PlayerWitcher.EquipItemInGivenSlot: invalid item");
			return false;
		}
		if(slot == EES_InvalidSlot || slot == EES_HorseBlinders || slot == EES_HorseSaddle || slot == EES_HorseBag || slot == EES_HorseTrophy)
		{
			LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> - provided slot <<" + slot + ">> is invalid");
			return false;
		}
		if(itemSlots[slot] == item)
		{
			return true;
		}	
		
		if(!HasRequiredLevelToEquipItem(item))
		{
			//player does not meet level requirement
			return false;
		}
		
		if(inv.ItemHasTag(item, 'PhantomWeapon') && !GetPhantomWeaponMgr())
		{
			InitPhantomWeaponMgr();
		}
		
		//managing Aerondight buffs
		if( slot == EES_SilverSword && inv.ItemHasTag( item, 'Aerondight' ) )
		{
			AddEffectDefault( EET_Aerondight, this, "Aerondight" );
			
			//pause the effect since the sword is not held in hand at this moment
			aerondight = (W3Effect_Aerondight)GetBuff( EET_Aerondight );
			aerondight.Pause( 'ManageAerondightBuff' );
		}		
		
		//swapping items - just reassign in slots, don't do any logic
		previousItemInSlot = itemSlots[slot];
		if(/*inv.IsIdValid(previousItemInSlot) &&*/ IsItemEquipped(item)) // #Y potions and bombs can be swapped with empty item
		{
			SwapEquippedItems(slot, GetItemSlot(item));
			return true;
		}
		
		//skill mutagens
		isSkillMutagen = IsSlotSkillMutagen(slot);
		if(isSkillMutagen)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			if(!pam.IsSkillMutagenSlotUnlocked(slot))
			{
				return false;
			}
		}
		
		//unequip previous item if slot is occupied
		if(inv.IsIdValid(previousItemInSlot))
		{			
			if(!UnequipItemFromSlot(slot, true))
			{
				LogAssert(false, "W3PlayerWitcher.EquipItem: Cannot equip item <<" + inv.GetItemName(item) + ">> !!");
				return false;
			}
		}		
		
		//if it's a mask unequip other equipped mask
		if(inv.IsItemMask(item))
		{
			if(slot == EES_Quickslot1)
				GetItemEquippedOnSlot(EES_Quickslot2, otherMask);
			else
				GetItemEquippedOnSlot(EES_Quickslot1, otherMask);
				
			if(inv.IsItemMask(otherMask))
				UnequipItem(otherMask);
		}
		
		if(isSkillMutagen)
		{
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
		}
		
		itemSlots[slot] = item;
		
		category = inv.GetItemCategory( item );
	
		//potion mutagens
		if( !ignoreMounting && ShouldMount(slot, item, category) )
		{
			// force mounting mutagen skills (so that other mutagen skills won't be unmounted)
			inv.MountItem( item, toHand, IsSlotSkillMutagen( slot ) );
		}		
		
		theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_EQUIPPED, inv.GetItemName(item), slot );
				
		if(slot == EES_RangedWeapon)
		{			
			rangedWeapon = ( Crossbow )( inv.GetItemEntityUnsafe(item) );
			if(!rangedWeapon)
				AddTimer('DelayedOnItemMount', 0.1, true);
			
			if ( IsSwimming() || IsDiving() )
			{
				GetItemEquippedOnSlot(EES_Bolt, boltItem);
				
				if(inv.IsIdValid(boltItem))
				{
					if ( !inv.ItemHasTag(boltItem, 'UnderwaterAmmo' ))
					{
						AddAndEquipInfiniteBolt(false, true);
					}
				}
				else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
				{
					AddAndEquipInfiniteBolt(false, true);
				}
			}
			//default ammo
			else if(!IsAnyItemEquippedOnSlot(EES_Bolt))
				AddAndEquipInfiniteBolt();
		}
		else if(slot == EES_Bolt)
		{
			if(rangedWeapon)
			{	if ( !IsSwimming() || !IsDiving() )
				{
					rangedWeapon.OnReplaceAmmo();
					rangedWeapon.OnWeaponReload();
				}
				else
				{
					DisplayHudMessage(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
				}
			}
		}		
		//skill mutagen
		else if(isSkillMutagen)
		{			
			pam.OnSkillMutagenEquipped(item, slot, prevSkillColor);
			LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> equipped to slot <<" + slot + ">>");
			LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
			LogSkillColors("");
		}
		else if(slot == EES_Gloves && HasWeaponDrawn(false))
		{
			PlayRuneword4FX(PW_Steel);
			PlayRuneword4FX(PW_Silver);
		}
		//if currently has selected bomb and equips a bomb, auto-select newly equipped bomb
		else if( ( slot == EES_Petard1 || slot == EES_Petard2 ) && inv.IsItemBomb( GetSelectedItemId() ) )
		{
			SelectQuickslotItem( slot );
		}

		//fist fight bonus ability
		if(inv.ItemHasAbility(item, 'MA_HtH'))
		{
			inv.GetItemContainedAbilities(item, containedAbilities);
			fistsID = inv.GetItemsByName('fists');
			dm = theGame.GetDefinitionsManager();
			for(i=0; i<containedAbilities.Size(); i+=1)
			{
				if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
				{					
					inv.AddItemCraftedAbility(fistsID[0], containedAbilities[i], true);
				}
			}
		}		
		
		//perk armor bonuses
		if(inv.IsItemAnyArmor(item))
		{
			armorType = inv.GetArmorType(item);
			pam = (W3PlayerAbilityManager)abilityManager;
			
			if(armorType == EAT_Light)
			{
				if(CanUseSkill(S_Perk_05))
					pam.SetPerkArmorBonus(S_Perk_05);
			}
			else if(armorType == EAT_Medium)
			{
				if(CanUseSkill(S_Perk_06))
					pam.SetPerkArmorBonus(S_Perk_06);
			}
			else if(armorType == EAT_Heavy)
			{
				if(CanUseSkill(S_Perk_07))
					pam.SetPerkArmorBonus(S_Perk_07);
			}
		}
		
		//Updating SetBonuses Info
		UpdateItemSetBonuses( item, true );
				
		// report global event
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
	
		//potion equip tutorial	
		if(ShouldProcessTutorial('TutorialPotionCanEquip3'))
		{
			if(IsSlotPotionSlot(slot))
			{
				tutStatePot = (W3TutorialManagerUIHandlerStatePotions)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStatePot)
				{
					tutStatePot.OnPotionEquipped(inv.GetItemName(item));
				}
				
				tutStateSecondPotionEquip = (W3TutorialManagerUIHandlerStateSecondPotionEquip)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStateSecondPotionEquip)
				{
					tutStateSecondPotionEquip.OnPotionEquipped(inv.GetItemName(item));
				}
				
			}
		}
		//food equip tutorial	
		if(ShouldProcessTutorial('TutorialFoodSelectTab'))
		{
			if( IsSlotPotionSlot(slot) && inv.IsItemFood(item))
			{
				tutStateFood = (W3TutorialManagerUIHandlerStateFood)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if(tutStateFood)
				{
					tutStateFood.OnFoodEquipped();
				}
			}
		}
		
		//achievement for any fully equipped witcher set
		if(inv.IsItemSetItem(item))
		{
			CheckForFullyArmedAchievement();	
		}
		
		return true;
	}

	private function CheckHairItem()
	{
		var ids : array<SItemUniqueId>;
		var i   : int;
		var itemName : name;
		var hairApplied : bool;
		
		ids = inv.GetItemsByCategory('hair');
		
		for(i=0; i<ids.Size(); i+= 1)
		{
			itemName = inv.GetItemName( ids[i] );
			
			if( itemName != 'Preview Hair' )
			{
				if( hairApplied == false )
				{
					inv.MountItem( ids[i], false );
					hairApplied = true;
				}
				else
				{
					inv.RemoveItem( ids[i], 1 );
				}
				
			}
		}
		
		if( hairApplied == false )
		{
			ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
			inv.MountItem( ids[0], false );
		}
		
	}

	//Tries to set crossbow object untill it succeeds
	timer function DelayedOnItemMount( dt : float, id : int )
	{
		var crossbowID : SItemUniqueId;
		var invent : CInventoryComponent;
		
		invent = GetInventory();
		if(!invent)
			return;	//inventory component not streamed yet
		
		//get crossbow ID
		GetItemEquippedOnSlot(EES_RangedWeapon, crossbowID);
				
		if(invent.IsIdValid(crossbowID))
		{
			//if has crossbow, get object
			rangedWeapon = ( Crossbow )(invent.GetItemEntityUnsafe(crossbowID) );
			
			if(rangedWeapon)
			{
				//if succeeded finish, else will loop again
				RemoveTimer('DelayedOnItemMount');
			}
		}
		else
		{
			//if no crossbow then nothing to set - abort
			RemoveTimer('DelayedOnItemMount');
		}
	}

	public function GetHeldItems() : array<SItemUniqueId>
	{
		var items : array<SItemUniqueId>;
		var item : SItemUniqueId;
	
		if( inv.GetItemEquippedOnSlot(EES_SilverSword, item) && inv.IsItemHeld(item))
			items.PushBack(item);
			
		if( inv.GetItemEquippedOnSlot(EES_SteelSword, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_RangedWeapon, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Quickslot1, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Quickslot2, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Petard1, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		if( inv.GetItemEquippedOnSlot(EES_Petard2, item) && inv.IsItemHeld(item))
			items.PushBack(item);

		return items;			
	}
	
	/*
		Unequips item from given slot. Returns true if item was successfully removed.
	*/
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item, bolts, id : SItemUniqueId;
		var items : array<SItemUniqueId>;
		var retBool : bool;
		var fistsID, bolt : array<SItemUniqueId>;
		var i, groupID : int;
		var pam : W3PlayerAbilityManager;
		var prevSkillColor : ESkillColor;
		var containedAbilities : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var armorType : EArmorType;
		var isSwimming : bool;
		var hud 				: CR4ScriptedHud;
		var damagedItemModule 	: CR4HudModuleDamagedItems;
		
		if(slot == EES_InvalidSlot || slot < 0 || slot > EnumGetMax('EEquipmentSlots') || !inv.IsIdValid(itemSlots[slot]))
			return false;
			
		//remove mutagen potion effect
		if(IsSlotSkillMutagen(slot))
		{
			//get current color bonus
			pam = (W3PlayerAbilityManager)abilityManager;
			groupID = pam.GetSkillGroupIdOfMutagenSlot(slot);
			prevSkillColor = pam.GetSkillGroupColor(groupID);
		}
		
		//remove oil buff from HUD
		if(slot == EES_SilverSword  || slot == EES_SteelSword)
		{
			PauseOilBuffs( slot == EES_SteelSword );
		}
			
		item = itemSlots[slot];
		itemSlots[slot] = GetInvalidUniqueId();
		
		// unequiping swords
		if(inv.ItemHasTag( item, 'PhantomWeapon' ) && GetPhantomWeaponMgr())
		{
			DestroyPhantomWeaponMgr();
		}
		
		//manage crosssbow and bolts under water
		
		//Managing Aerondight buff
		if( slot == EES_SilverSword && inv.ItemHasTag( item, 'Aerondight' ) )
		{
			RemoveBuff( EET_Aerondight );
		}
		
		//unequipping crossbow
		if(slot == EES_RangedWeapon)
		{
			
			this.OnRangedForceHolster( true, true );
			rangedWeapon.ClearDeployedEntity(true);
			rangedWeapon = NULL;
		
			//if has equipped some infinite bolts, remove them
			if(GetItemEquippedOnSlot(EES_Bolt, bolts))
			{
				if(inv.ItemHasTag(bolts, theGame.params.TAG_INFINITE_AMMO))
				{
					inv.RemoveItem(bolts, inv.GetItemQuantity(bolts) );
				}
			}
		}
		else if(IsSlotSkillMutagen(slot))
		{			
			pam.OnSkillMutagenUnequipped(item, slot, prevSkillColor);
			LogSkillColors("Mutagen <<" + inv.GetItemName(item) + ">> unequipped from slot <<" + slot + ">>");
			LogSkillColors("Group bonus color is now <<" + pam.GetSkillGroupColor(groupID) + ">>");
			LogSkillColors("");
		}
		
		//usable items
		if(currentlyEquipedItem == item)
		{
			currentlyEquipedItem = GetInvalidUniqueId();
			RaiseEvent('ForcedUsableItemUnequip');
		}
		if(currentlyEquipedItemL == item)
		{
			if ( currentlyUsedItemL )
			{
				currentlyUsedItemL.OnHidden( this );
			}
			HideUsableItem ( true );
		}
				
		//unmount if mountable item
		if( !IsSlotPotionMutagen(slot) )
		{
			GetInventory().UnmountItem(item, true);
		}
		
		retBool = true;
				
		//unequipping bolts
		if(IsAnyItemEquippedOnSlot(EES_RangedWeapon) && slot == EES_Bolt)
		{			
			if(inv.ItemHasTag(item, theGame.params.TAG_INFINITE_AMMO))
			{
				//unequipping infinite ammo bolts
				inv.RemoveItem(item, inv.GetItemQuantityByName( inv.GetItemName(item) ) );
			}
			else if (!reequipped)
			{
				//unequipping finite ammo bolts
				AddAndEquipInfiniteBolt();
			}
		}
		
		//if weapon was held in hand then update the character pose / combat state
		if(slot == EES_SilverSword  || slot == EES_SteelSword)
		{
			OnEquipMeleeWeapon(PW_None, true);			
		}
		
		if( /*IsSlotQuickslot(slot) || */ GetSelectedItemId() == item )
		{
			ClearSelectedItemId();
		}
		
		if(inv.IsItemBody(item))
		{
			retBool = true;
		}		
		
		if(retBool && !reequipped)
		{
			theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_UNEQUIPPED, inv.GetItemName(item), slot );
			
			//remove enhanced item buffs
			if(slot == EES_SteelSword && !IsAnyItemEquippedOnSlot(EES_SilverSword))
			{
				RemoveBuff(EET_EnhancedWeapon);
			}
			else if(slot == EES_SilverSword && !IsAnyItemEquippedOnSlot(EES_SteelSword))
			{
				RemoveBuff(EET_EnhancedWeapon);
			}
			else if(inv.IsItemAnyArmor(item))
			{
				if( !IsAnyItemEquippedOnSlot(EES_Armor) && !IsAnyItemEquippedOnSlot(EES_Gloves) && !IsAnyItemEquippedOnSlot(EES_Boots) && !IsAnyItemEquippedOnSlot(EES_Pants))
					RemoveBuff(EET_EnhancedArmor);
			}
		}
		
		//fist fight bonus ability
		if(inv.ItemHasAbility(item, 'MA_HtH'))
		{
			inv.GetItemContainedAbilities(item, containedAbilities);
			fistsID = inv.GetItemsByName('fists');
			dm = theGame.GetDefinitionsManager();
			for(i=0; i<containedAbilities.Size(); i+=1)
			{
				if(dm.AbilityHasTag(containedAbilities[i], 'MA_HtH'))
				{
					inv.RemoveItemCraftedAbility(fistsID[0], containedAbilities[i]);
				}
			}
		}
		
		//perk armor bonuses
		if(inv.IsItemAnyArmor(item))
		{
			armorType = inv.GetArmorType(item);
			pam = (W3PlayerAbilityManager)abilityManager;
			
			if(CanUseSkill(S_Perk_05) && (armorType == EAT_Light || GetCharacterStats().HasAbility('Glyphword 2 _Stats', true) || inv.ItemHasAbility(item, 'Glyphword 2 _Stats')))
			{
				pam.SetPerkArmorBonus(S_Perk_05);
			}
			if(CanUseSkill(S_Perk_06) && (armorType == EAT_Medium || GetCharacterStats().HasAbility('Glyphword 3 _Stats', true) || inv.ItemHasAbility(item, 'Glyphword 3 _Stats')) )
			{
				pam.SetPerkArmorBonus(S_Perk_06);
			}
			if(CanUseSkill(S_Perk_07) && (armorType == EAT_Heavy || GetCharacterStats().HasAbility('Glyphword 4 _Stats', true) || inv.ItemHasAbility(item, 'Glyphword 4 _Stats')) )
			{
				pam.SetPerkArmorBonus(S_Perk_07);
			}
		}
		
		//Updating Set Bonus Info
		UpdateItemSetBonuses( item, false );
		
		//Updating number of alchemy items in stack
		if( inv.ItemHasTag( item, theGame.params.ITEM_SET_TAG_BONUS ) && !IsSetBonusActive( EISB_RedWolf_2 ) )
		{
			SkillReduceBombAmmoBonus();
		}

		if( slot == EES_Gloves )
		{
			thePlayer.DestroyEffect('runeword_4');
		}
		
		// Update broken item indicator
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			damagedItemModule = hud.GetDamagedItemModule();
			if ( damagedItemModule )
			{
				damagedItemModule.OnItemUnequippedFromSlot( slot );
			}
		}
		
		// report global event
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		return retBool;
	}
		
	public function UnequipItem(item : SItemUniqueId) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
		
		return UnequipItemFromSlot( itemSlots.FindFirst(item) );
	}
	
	public function DropItem( item : SItemUniqueId, quantity : int ) : bool
	{
		if(!inv.IsIdValid(item))
			return false;
		if(IsItemEquipped(item))
			return UnequipItem(item);
		
		return true;
	}	
	
	//Returns true if there is at least one item with given name or category equipped (others with same name might be unequipped)
	public function IsItemEquippedByName(itemName : name) : bool
	{
		var i : int;
	
		for(i=0; i<itemSlots.Size(); i+=1)
			if(inv.GetItemName(itemSlots[i]) == itemName)
				return true;

		return false;
	}

	//Returns true if there is at least one item of given category equipped (others with same name might be unequipped)
	public function IsItemEquippedByCategoryName(categoryName : name) : bool
	{
		var i : int;
	
		for(i=0; i<itemSlots.Size(); i+=1)
			if(inv.GetItemCategory(itemSlots[i]) == categoryName)
				return true;
				
		return false;
	}
	
	public function GetMaxRunEncumbrance(out usesHorseBonus : bool) : float
	{
		var value : float;
		
		value = CalculateAttributeValue(GetHorseManager().GetHorseAttributeValue('encumbrance', false));
		usesHorseBonus = (value > 0);
		value += CalculateAttributeValue( GetAttributeValue('encumbrance') );
		
		return value;
	}
		
	public function GetEncumbrance() : float
	{
		var i: int;
		var encumbrance : float;
		var items : array<SItemUniqueId>;
		var inve : CInventoryComponent;
	
		inve = GetInventory();			//called before geralt is spawned -> inv == NULL
		inve.GetAllItems(items);

		for(i=0; i<items.Size(); i+=1)
		{
			encumbrance += inve.GetItemEncumbrance( items[i] );
			
			//if( inve.GetItemEncumbrance( items[i] ) > 0.f )
			//	LogItems( SpaceFill(inve.GetItemQuantity( items[i] ), 3, ESFM_JustifyLeft ) + "x Item: " + inve.GetItemName( items[i] ) + " with Weight: " + inve.GetItemWeight( items[i] ) + " adds Encumberance: " + inve.GetItemEncumbrance(items[i]) + ". Total = " + encumbrance );
		}		
		return encumbrance;
	}
	
	// In case of multi add/remove item call we can postopnd heavy updates like UpdateEncumbrance()
	// and call it only once after finishing whole transaction
	public function StartInvUpdateTransaction():void
	{
		invUpdateTransaction = true;
	}
	
	public function FinishInvUpdateTransaction():void
	{
		invUpdateTransaction = false;
		
		// place all heavy operation you need here:
		// ...
		UpdateEncumbrance();
	}
	
	//optimize me!
	public function UpdateEncumbrance()
	{
		var temp : bool;
		
		if (invUpdateTransaction)
		{
			// update postponding till finishInvUpdateTransaction call
			return;
		}
		
		//we add bonus 1 point because UI shows this as int rather than float, so having 150.9 / 150 is shown as 150/150
		//so from player's perspective you should not be overburdened
		if ( GetEncumbrance() >= (GetMaxRunEncumbrance(temp) + 1) )
		{
			if( !HasBuff(EET_OverEncumbered) && FactsQuerySum( "DEBUG_EncumbranceBoy" ) == 0 )
			{
				AddEffectDefault(EET_OverEncumbered, NULL, "OverEncumbered");
			}
		}
		else if(HasBuff(EET_OverEncumbered))
		{
			RemoveAllBuffsOfType(EET_OverEncumbered);
		}
	}
	
	public final function GetSkillGroupIDFromIndex(idx : int) : int
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupIDFromIndex(idx);
			
		return -1;
	}
	
	public final function GetSkillGroupColor(groupID : int) : ESkillColor
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupColor(groupID);
			
		return SC_None;
	}
	
	public final function GetSkillGroupsCount() : int
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.GetSkillGroupsCount();
			
		return 0;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	//
	// Witcher's Signs
	// 
	////////////////////////////////////////////////////////////////////////////////////////// 
	
	//returns next (left or right) sign type in cycle
	function CycleSelectSign( bIsCyclingLeft : bool ) : ESignType
	{
		var signOrder : array<ESignType>;
		var i : int;
		
		signOrder.PushBack( ST_Yrden );
		signOrder.PushBack( ST_Quen );
		signOrder.PushBack( ST_Igni );
		signOrder.PushBack( ST_Axii );
		signOrder.PushBack( ST_Aard );
			
		for( i = 0; i < signOrder.Size(); i += 1 )
			if( signOrder[i] == equippedSign )
				break;
		
		if(bIsCyclingLeft)
			return signOrder[ (4 + i) % 5 ];	//5+i-1
		else
			return signOrder[ (6 + i) % 5 ];
	}
	
	function ToggleNextSign()
	{
		SetEquippedSign(CycleSelectSign( false ));
		FactsAdd("SignToggled", 1, 1);
	}
	
	function TogglePreviousSign()
	{
		SetEquippedSign(CycleSelectSign( true ));
		FactsAdd("SignToggled", 1, 1);
	}
	
	function ProcessSignEvent( eventName : name ) : bool
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
		{
			return signs[currentlyCastSign].entity.OnProcessSignEvent( eventName );
		}
		
		return false;
	}
	
	var findActorTargetTimeStamp : float;
	var pcModeChanneledSignTimeStamp	: float;
	event OnProcessCastingOrientation( isContinueCasting : bool )
	{
		var customOrientationTarget : EOrientationTarget;
		var checkHeading 			: float;
		var rotHeading 				: float;
		var playerToHeadingDist 	: float;
		var slideTargetActor		: CActor;
		var newLockTarget			: CActor;
		
		var enableNoTargetOrientation	: bool;
		
		var currTime : float;
		
		enableNoTargetOrientation = true;
		if ( GetDisplayTarget() && this.IsDisplayTargetTargetable() )// && theInput.LastUsedGamepad() )// && ( GetPlayerCombatStance() == PCS_AlertNear || GetPlayerCombatStance() == PCS_Guarded ) ) 
		{
			enableNoTargetOrientation = false;
			if ( theInput.GetActionValue( 'CastSignHold' ) > 0 || this.IsCurrentSignChanneled() )
			{
				if ( IsPCModeEnabled() )
				{
					if ( EngineTimeToFloat( theGame.GetEngineTime() ) >  pcModeChanneledSignTimeStamp + 1.f )
						enableNoTargetOrientation = true;
				}
				else
				{
					if ( GetCurrentlyCastSign() == ST_Igni || GetCurrentlyCastSign() == ST_Axii )
					{
						slideTargetActor = (CActor)GetDisplayTarget();
						if ( slideTargetActor 
							&& ( !slideTargetActor.GetGameplayVisibility() || !CanBeTargetedIfSwimming( slideTargetActor ) || !slideTargetActor.IsAlive() ) )
						{
							SetSlideTarget( NULL );
							if ( ProcessLockTarget() )
								slideTargetActor = (CActor)slideTarget;
						}				
						
						if ( !slideTargetActor )
						{
							LockToTarget( false );
							enableNoTargetOrientation = true;
						}
						else if ( IsThreat( slideTargetActor ) || GetCurrentlyCastSign() == ST_Axii )
							LockToTarget( true );
						else
						{
							LockToTarget( false );
							enableNoTargetOrientation = true;
						}
					}
				}
			}

			if ( !enableNoTargetOrientation )
			{			
				customOrientationTarget = OT_Actor;
			}
		}
		
		if ( enableNoTargetOrientation )
		{
			if ( GetPlayerCombatStance() == PCS_AlertNear && theInput.GetActionValue( 'CastSignHold' ) > 0 )
			{
				if ( GetDisplayTarget() && !slideTargetActor )
				{
					currTime = EngineTimeToFloat( theGame.GetEngineTime() );
					if ( currTime > findActorTargetTimeStamp + 1.5f )
					{
						findActorTargetTimeStamp = currTime;
						
						newLockTarget = GetScreenSpaceLockTarget( GetDisplayTarget(), 180.f, 1.f, 0.f, true );
						
						if ( newLockTarget && IsThreat( newLockTarget ) && IsCombatMusicEnabled() )
						{
							SetTarget( newLockTarget, true );
							SetMoveTargetChangeAllowed( true );
							SetMoveTarget( newLockTarget );
							SetMoveTargetChangeAllowed( false );
							SetSlideTarget( newLockTarget );							
						}	
					}
				}
				else
					ProcessLockTarget();
			}
			
			if ( wasBRAxisPushed )
				customOrientationTarget = OT_CameraOffset;
			else
			{
				if ( !lastAxisInputIsMovement || theInput.LastUsedPCInput() )
					customOrientationTarget = OT_CameraOffset;
				else if ( theInput.GetActionValue( 'CastSignHold' ) > 0 )
				{
					if ( GetOrientationTarget() == OT_CameraOffset )
						customOrientationTarget = OT_CameraOffset;
					else if ( GetPlayerCombatStance() == PCS_AlertNear || GetPlayerCombatStance() == PCS_Guarded ) 
						customOrientationTarget = OT_CameraOffset;
					else
						customOrientationTarget = OT_Player;	
				}
				else
					customOrientationTarget = OT_CustomHeading;
			}			
		}		
		
		if ( GetCurrentlyCastSign() == ST_Quen )
		{
			if ( theInput.LastUsedPCInput() )
			{
				customOrientationTarget = OT_Camera;
			}
			else if ( IsCurrentSignChanneled() )
			{
				if ( bLAxisReleased )
					customOrientationTarget = OT_Player;
				else
					customOrientationTarget = OT_Camera;
			}
			else 
				customOrientationTarget = OT_Player;
		}	
		
		if ( GetCurrentlyCastSign() == ST_Axii && IsCurrentSignChanneled() )
		{	
			if ( slideTarget && (CActor)slideTarget )
			{
				checkHeading = VecHeading( slideTarget.GetWorldPosition() - this.GetWorldPosition() );
				rotHeading = checkHeading;
				playerToHeadingDist = AngleDistance( GetHeading(), checkHeading );
				
				if ( playerToHeadingDist > 45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading, 0.0, 0.5, false );
				else if ( playerToHeadingDist < -45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading, 0.0, 0.5, false );					
			}
			else
			{
				checkHeading = VecHeading( theCamera.GetCameraDirection() );
				rotHeading = GetHeading();
				playerToHeadingDist = AngleDistance( GetHeading(), checkHeading );
				
				if ( playerToHeadingDist > 45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading - 22.5, 0.0, 0.5, false );
				else if ( playerToHeadingDist < -45 )
					SetCustomRotation( 'ChanneledSignAxii', rotHeading + 22.5, 0.0, 0.5, false );				
			}
		}		
			
		if ( IsActorLockedToTarget() )
			customOrientationTarget = OT_Actor;
		
		AddCustomOrientationTarget( customOrientationTarget, 'Signs' );
		
		if ( customOrientationTarget == OT_CustomHeading )
			SetOrientationTargetCustomHeading( GetCombatActionHeading(), 'Signs' );			
	}
	
	event OnRaiseSignEvent()
	{
		var newTarget : CActor;
	
		if ( ( !IsCombatMusicEnabled() && !CanAttackWhenNotInCombat( EBAT_CastSign, false, newTarget ) ) || ( IsOnBoat() && !IsCombatMusicEnabled() ) )
		{		
			if ( CastSignFriendly() )
				return true;
		}
		else
		{
			RaiseEvent('CombatActionFriendlyEnd');
			SetBehaviorVariable( 'SignNum', (int)equippedSign );
			SetBehaviorVariable( 'combatActionType', (int)CAT_CastSign );

			if ( IsPCModeEnabled() )
				pcModeChanneledSignTimeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
		
			if( RaiseForceEvent('CombatAction') )
			{
				OnCombatActionStart();
				findActorTargetTimeStamp = EngineTimeToFloat( theGame.GetEngineTime() );
				theTelemetry.LogWithValueStr(TE_FIGHT_PLAYER_USE_SIGN, SignEnumToString( equippedSign ));
				return true;
			}
		}
		
		return false;
	}
	
	function CastSignFriendly() : bool
	{
		var actor : CActor;
	
		SetBehaviorVariable( 'combatActionTypeForOverlay', (int)CAT_CastSign );			
		if ( RaiseCombatActionFriendlyEvent() )
		{
			/*if ( bLAxisReleased && slideTarget )
			{
				actor = (CActor)slideTarget;
				if ( actor )
					SetCustomRotation( 'Sign', VecHeading( actor.GetWorldPosition() - GetWorldPosition() ), 0.0f, 0.3f, false );	
			}*/			
			return true;
		}	
		
		return false;
	}
	
	function CastSign() : bool
	{
		var equippedSignStr : string;
		var newSignEnt : W3SignEntity;
		var spawnPos : Vector;
		var slotMatrix : Matrix;
		var target : CActor;
		
		if ( IsInAir() )
		{
			return false;
		}
		
		AddTemporarySkills();
		
		//OnProcessCastingOrientation( false );
		
		if(equippedSign == ST_Aard)
		{
			CalcEntitySlotMatrix('l_weapon', slotMatrix);
			spawnPos = MatrixGetTranslation(slotMatrix);
		}
		else
		{
			spawnPos = GetWorldPosition();
		}
		
		if( equippedSign == ST_Aard || equippedSign == ST_Igni )
		{
			target = GetTarget();
			if(target)
				target.SignalGameplayEvent( 'DodgeSign' );
		}
		
		newSignEnt = (W3SignEntity)theGame.CreateEntity( signs[equippedSign].template, spawnPos, GetWorldRotation() );
		return newSignEnt.Init( signOwner, signs[equippedSign].entity );
	}
	
	//if we throw hold while casting sign then the input gets ingored (cleared from combat action buffer when cast sign stop is processed)
	private function HAX_SignToThrowItemRestore()
	{
		var action : SInputAction;
		
		action.value = theInput.GetActionValue('ThrowItemHold');
		action.lastFrameValue = 0;
		
		if(IsPressed(action) && CanSetupCombatAction_Throw())
		{
			if(inv.IsItemBomb(selectedItemId))
			{
				BombThrowStart();
			}
			else
			{
				UsableItemStart();
			}
			
			SetThrowHold( true );
		}
	}
	
	event OnCFMCameraZoomFail(){}
		
	////////////////////////////////////////////////////////////////////////////////

	public final function GetDrunkMutagens( optional sourceName : string ) : array<CBaseGameplayEffect>
	{
		return effectManager.GetDrunkMutagens( sourceName );
	}
	
	public final function GetPotionBuffs() : array<CBaseGameplayEffect>
	{
		return effectManager.GetPotionBuffs();
	}
	
	public final function RecalcPotionsDurations()
	{
		var i : int;
		var buffs : array<CBaseGameplayEffect>;
		
		buffs = GetPotionBuffs();
		for(i=0; i<buffs.Size(); i+=1)
		{
			buffs[i].RecalcPotionDuration();
		}
	}

	public function StartFrenzy()
	{
		var ratio, duration : float;
		var skillLevel : int;
	
		isInFrenzy = true;
		skillLevel = GetSkillLevel(S_Alchemy_s16);
		ratio = 0.48f - skillLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s16, 'slowdown_ratio', false, true));
		duration = skillLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s16, 'slowdown_duration', false, true));
	
		theGame.SetTimeScale(ratio, theGame.GetTimescaleSource(ETS_SkillFrenzy), theGame.GetTimescalePriority(ETS_SkillFrenzy) );
		AddTimer('SkillFrenzyFinish', duration * ratio, , , , true);
	}
	
	timer function SkillFrenzyFinish(dt : float, optional id : int)
	{		
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_SkillFrenzy) );
		isInFrenzy = false;
	}
	
	public function GetToxicityDamageThreshold() : float
	{
		var ret : float;
		
		ret = theGame.params.TOXICITY_DAMAGE_THRESHOLD;
		
		if(CanUseSkill(S_Alchemy_s01))
			ret += CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s01, 'threshold', false, true)) * GetSkillLevel(S_Alchemy_s01);
		
		return ret;
	}
	
	/*
	private function DrinkMutagenPotion(id : SItemUniqueId, slot : EEquipmentSlots) : bool
	{
		var toxicityOffset, toxicitySum : float;
		var ret : EEffectInteract;
		var mutagen : SDrunkMutagen;
		var mutagenParams : SCustomEffectParams;		
		var buffs : array<SEffectInfo>;
		//var tutState : W3TutorialManagerUIHandlerStatePreparationMutagens; disabled, might be added in patch
		var result : bool;
			
		if(!IsSlotMutagen(slot)) 
			return false;
		
		toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(id,'toxicity_offset'));
	
		// check what toxicity would be if we drink mutagen, don't allow it to be too high.
		toxicitySum = abilityManager.GetStat(BCS_Toxicity) + (toxicityOffset - GetMutagenToxicityOffset(slot)) * abilityManager.GetStatMax(BCS_Toxicity);
		if( toxicitySum > abilityManager.GetStatMax(BCS_Toxicity) )
			return false;			

		//buff type
		inv.GetItemBuffs(id, buffs);
				
		//apply mutagen effect
		mutagenParams.effectType = buffs[0].effectType;
		mutagenParams.creator = this;
		mutagenParams.sourceName = "mutagen";
		mutagenParams.duration = -1;
		mutagenParams.customAbilityName = buffs[0].effectAbilityName;
		ret = AddEffectCustom(mutagenParams);
		
		//post-application - if successfull
		if(ret == EI_Pass || ret == EI_Override || ret == EI_Cumulate)
		{			
			PlayEffect('use_potion');
			
			itemSlots[slot] = id;	//'equip mutagen'
			
			mutagen.mutagenName = GetInventory().GetItemName( id );
			mutagen.effectType = buffs[0].effectType;
			mutagen.slot = slot;
			mutagen.toxicityOffset = toxicityOffset;
			
			drunkMutagens.PushBack( mutagen );
			
			AddToxicityOffset(toxicityOffset);
			
			result = true;
		}
		else
		{
			result = false;
		}
		
		/ * disabled, might be added in patch
		//tutorial
		if(ShouldProcessTutorial('TutorialMutagenPotion'))
		{
			tutState = (W3TutorialManagerUIHandlerStatePreparationMutagens)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(tutState)
			{
				tutState.OnMutagenEquipped();
			}
		}
		* /
		
		//trial of grasses achievement
		theGame.GetGamerProfile().CheckTrialOfGrasses();
		
		//fundamentals first achievement
		SetFailedFundamentalsFirstAchievementCondition(true);
		
		// report global event
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		return result;
	}
	*/
	
	public final function AddToxicityOffset( val : float)
	{
		((W3PlayerAbilityManager)abilityManager).AddToxicityOffset(val);		
	}
	
	public final function SetToxicityOffset( val : float)
	{
		((W3PlayerAbilityManager)abilityManager).SetToxicityOffset(val);
	}
	
	public final function RemoveToxicityOffset( val : float)
	{
		((W3PlayerAbilityManager)abilityManager).RemoveToxicityOffset(val);		
	}
	
	//calculates final duration of potion (with all skill bonuses)
	public final function CalculatePotionDuration(item : SItemUniqueId, isMutagenPotion : bool, optional itemName : name) : float
	{
		var duration, skillPassiveMod, mutagenSkillMod : float;
		var val, min, max : SAbilityAttributeValue;
		
		//base potion duration
		if(inv.IsIdValid(item))
		{
			duration = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'duration'));			
		}
		else
		{
			theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
			
		skillPassiveMod = CalculateAttributeValue(GetAttributeValue('potion_duration'));
		
		if(isMutagenPotion && CanUseSkill(S_Alchemy_s14))
		{
			val = GetSkillAttributeValue(S_Alchemy_s14, 'duration', false, true);
			mutagenSkillMod = val.valueMultiplicative * GetSkillLevel(S_Alchemy_s14);
		}
		
		duration = duration * (1 + skillPassiveMod + mutagenSkillMod);
		
		return duration;
	}
	
	public function ToxicityLowEnoughToDrinkPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId ) : bool
	{
		var item 				: SItemUniqueId;
		var maxTox 				: float;
		var potionToxicity 		: float;
		var toxicityOffset 		: float;
		var effectType 			: EEffectType;
		var customAbilityName 	: name;
		
		if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];
		
		inv.GetPotionItemBuffData(item, effectType, customAbilityName);
		maxTox = abilityManager.GetStatMax(BCS_Toxicity);
		potionToxicity = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity'));
		toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
		
		if(effectType != EET_WhiteHoney)
		{
			if(abilityManager.GetStat(BCS_Toxicity, false) + potionToxicity + toxicityOffset > maxTox )
			{
				return false;
			}
		}
		
		return true;
	}
	
	public final function HasFreeToxicityToDrinkPotion( item : SItemUniqueId, effectType : EEffectType, out finalPotionToxicity : float ) : bool
	{
		var i : int;
		var maxTox, toxicityOffset, adrenaline : float;
		var costReduction : SAbilityAttributeValue;
		
		//White Honey can always be drunk
		if( effectType == EET_WhiteHoney )
		{
			return true;
		}
		
		//get toxicity costs
		maxTox = abilityManager.GetStatMax(BCS_Toxicity);
		finalPotionToxicity = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity'));
		toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
		
		//check for perk which decrases toxicity cost by consuming adrenaline
		if(CanUseSkill(S_Perk_13))
		{
			costReduction = GetSkillAttributeValue(S_Perk_13, 'cost_reduction', false, true);
			adrenaline = FloorF(GetStat(BCS_Focus));
			costReduction = costReduction * adrenaline;
			finalPotionToxicity = (finalPotionToxicity - costReduction.valueBase) * (1 - costReduction.valueMultiplicative) - costReduction.valueAdditive;
			finalPotionToxicity = MaxF(0.f, finalPotionToxicity);
		}
		
		//normal toxicity check
		if(abilityManager.GetStat(BCS_Toxicity, false) + finalPotionToxicity + toxicityOffset > maxTox )
		{
			return false;
		}
		
		return true;
	}
	
	public function DrinkPreparedPotion( slotid : EEquipmentSlots, optional itemId : SItemUniqueId )
	{	
		var potParams : W3PotionParams;
		var potionParams : SCustomEffectParams;
		var factPotionParams : W3Potion_Fact_Params;
		var adrenaline, hpGainValue, duration, finalPotionToxicity : float;
		var ret : EEffectInteract;
		var effectType : EEffectType;
		var item : SItemUniqueId;
		var customAbilityName, factId : name;
		var atts : array<name>;
		var i : int;
		var mutagenParams : W3MutagenBuffCustomParams;
		
		//normally use slot BUT you can also drink any potion directly from inventory panel without equipping - in that case we override it by custom itemID		
		if(itemId != GetInvalidUniqueId())
			item = itemId; 
		else 
			item = itemSlots[slotid];
		
		//invalid item
		if(!inv.IsIdValid(item))
			return;
			
		//potion has no ammo left
		if( inv.SingletonItemGetAmmo(item) == 0 )
			return;
			
		//buff info
		inv.GetPotionItemBuffData(item, effectType, customAbilityName);
			
		//toxicity cost check
		if( !HasFreeToxicityToDrinkPotion( item, effectType, finalPotionToxicity ) )
		{
			return;
		}
				
		//custom params - fact name
		if(effectType == EET_Fact)
		{
			inv.GetItemAttributes(item, atts);
			
			for(i=0; i<atts.Size(); i+=1)
			{
				if(StrBeginsWith(NameToString(atts[i]), "fact_"))
				{
					factId = atts[i];
					break;
				}
			}
			
			factPotionParams = new W3Potion_Fact_Params in theGame;
			factPotionParams.factName = factId;
			factPotionParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = factPotionParams;
		}
		//custom params for mutagens
		else if(inv.ItemHasTag( item, 'Mutagen' ))
		{
			mutagenParams = new W3MutagenBuffCustomParams in theGame;
			mutagenParams.toxicityOffset = CalculateAttributeValue(inv.GetItemAttributeValue(item, 'toxicity_offset'));
			mutagenParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = mutagenParams;
			
			if( IsMutationActive( EPMT_Mutation10 ) && !HasBuff( EET_Mutation10 ) )
			{
				AddEffectDefault( EET_Mutation10, this, "Mutation 10" );
			}
		}
		//custom params for potions
		else
		{
			potParams = new W3PotionParams in theGame;
			potParams.potionItemName = inv.GetItemName(item);
			
			potionParams.buffSpecificParams = potParams;
		}
	
		//set duration
		duration = CalculatePotionDuration(item, inv.ItemHasTag( item, 'Mutagen' ));		

		//apply potion
		potionParams.effectType = effectType;
		potionParams.creator = this;
		potionParams.sourceName = "drank_potion";
		potionParams.duration = duration;
		potionParams.customAbilityName = customAbilityName;
		ret = AddEffectCustom(potionParams);

		//clear custom params
		if(factPotionParams)
			delete factPotionParams;
			
		if(mutagenParams)
			delete mutagenParams;
			
		//use up ammo
		inv.SingletonItemRemoveAmmo(item);
		
		//post-application - if successfull
		if(ret == EI_Pass || ret == EI_Override || ret == EI_Cumulate)
		{
			if( finalPotionToxicity > 0.f )
			{
				abilityManager.GainStat(BCS_Toxicity, finalPotionToxicity );
			}
			
			//adrenaline perk
			if(CanUseSkill(S_Perk_13))
			{
				abilityManager.DrainFocus(adrenaline);
			}
			
			if (!IsEffectActive('invisible'))
			{
				PlayEffect('use_potion');
			}
			
			if ( inv.ItemHasTag( item, 'Mutagen' ) )
			{
				//trial of grasses achievement
				theGame.GetGamerProfile().CheckTrialOfGrasses();
				
				//fundamentals first achievement
				SetFailedFundamentalsFirstAchievementCondition(true);
			}
			
			//heal
			if(CanUseSkill(S_Alchemy_s02))
			{
				hpGainValue = ClampF(GetStatMax(BCS_Vitality) * CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s02, 'vitality_gain_perc', false, true)) * GetSkillLevel(S_Alchemy_s02), 0, GetStatMax(BCS_Vitality));
				GainStat(BCS_Vitality, hpGainValue);
			}			
			
			//bonus random potion
			if(CanUseSkill(S_Alchemy_s04) && !skillBonusPotionEffect && (RandF() < CalculateAttributeValue(GetSkillAttributeValue(S_Alchemy_s04, 'apply_chance', false, true)) * GetSkillLevel(S_Alchemy_s04)))
			{
				AddRandomPotionEffectFromAlch4Skill( effectType );				
			}
			
			theGame.GetGamerProfile().SetStat(ES_ActivePotions, effectManager.GetPotionBuffsCount());
		}
		
		theTelemetry.LogWithLabel(TE_ELIXIR_USED, inv.GetItemName(item));
		
		if(ShouldProcessTutorial('TutorialPotionAmmo'))
		{
			FactsAdd("tut_used_potion");
		}
		
		SetFailedFundamentalsFirstAchievementCondition(true);
	}
	
	//Alchemy skill 04 adds (with some chance) random potion effect when we drink any potion
	private final function AddRandomPotionEffectFromAlch4Skill( currentlyDrankPotion : EEffectType )
	{
		var randomPotions : array<EEffectType>;
		var currentPotion : CBaseGameplayEffect;
		var effectsOld, effectsNew : array<CBaseGameplayEffect>;
		var i, ind : int;
		var duration : float;
		var params : SCustomEffectParams;
		var ret : EEffectInteract;
		
		//list of potions to pick from
		randomPotions.PushBack( EET_BlackBlood );
		randomPotions.PushBack( EET_Blizzard );
		randomPotions.PushBack( EET_FullMoon );
		randomPotions.PushBack( EET_GoldenOriole );
		randomPotions.PushBack( EET_KillerWhale );
		randomPotions.PushBack( EET_MariborForest );
		randomPotions.PushBack( EET_PetriPhiltre );
		randomPotions.PushBack( EET_Swallow );
		randomPotions.PushBack( EET_TawnyOwl );
		randomPotions.PushBack( EET_Thunderbolt );
		
		//exclude currently drank potion
		randomPotions.Remove( currentlyDrankPotion );
		
		//select bonus potion to add
		ind = RandRange( randomPotions.Size() );

		//if it's a potion effect we currently have instead of adding new buff, restore the duration of the initial one to full
		if( HasBuff( randomPotions[ ind ] ) )
		{
			currentPotion = GetBuff( randomPotions[ ind ] );
			currentPotion.SetTimeLeft( currentPotion.GetInitialDurationAfterResists() );
		}
		//else add new potion buff
		else
		{			
			duration = BonusPotionGetDurationFromXML( randomPotions[ ind ] );
			
			if(duration > 0)
			{
				effectsOld = GetCurrentEffects();
									
				params.effectType = randomPotions[ ind ];
				params.creator = this;
				params.sourceName = SkillEnumToName( S_Alchemy_s04 );
				params.duration = duration;
				ret = AddEffectCustom( params );
				
				//if it added properly, save this information
				if( ret != EI_Undefined && ret != EI_Deny )
				{
					effectsNew = GetCurrentEffects();
					
					ind = -1;
					for( i=effectsNew.Size()-1; i>=0; i-=1)
					{
						if( !effectsOld.Contains( effectsNew[i] ) )
						{
							ind = i;
							break;
						}
					}
					
					if(ind > -1)
					{
						skillBonusPotionEffect = effectsNew[ind];
					}
				}
			}		
		}
	}
	
	// Caches recipes' data from XML for given recipes
	private function BonusPotionGetDurationFromXML(type : EEffectType) : float
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpName, typeName, itemName : name;
		var abs : array<name>;
		var min, max : SAbilityAttributeValue;
		var tmpInt : int;
		var temp 								: array<float>;
		var i, temp2, temp3 : int;
						
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');
		typeName = EffectTypeToName(type);
		
		//get potion item name
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
			{
				//proper potion definition...
				if(tmpName == typeName)
				{
					if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
					{
						//of level 1...
						if(tmpInt == 1)
						{
							if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', itemName))
							{
								//got valid item id
								if(IsNameValid(itemName))
								{
									break;
								}
							}
						}
					}
				}
			}
		}
		
		if(!IsNameValid(itemName))
			return 0;
		
		//get duration from item's ability's definition
		dm.GetItemAbilitiesWithWeights(itemName, true, abs, temp, temp2, temp3);
		dm.GetAbilitiesAttributeValue(abs, 'duration', min, max);						
		return CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	
	public function ClearSkillBonusPotionEffect()
	{
		skillBonusPotionEffect = NULL;
	}
	
	public function GetSkillBonusPotionEffect() : CBaseGameplayEffect
	{
		return skillBonusPotionEffect;
	}
	
	////////////////////////////////////////////////////////////////////////////////
	//
	// @Buffs
	//
	////////////////////////////////////////////////////////////////////////////////
	
	public final function HasRunewordActive(abilityName : name) : bool
	{
		var item : SItemUniqueId;
		var hasRuneword : bool;
		
		if(GetItemEquippedOnSlot(EES_SteelSword, item))
		{
			hasRuneword = inv.ItemHasAbility(item, abilityName);				
		}
		
		if(!hasRuneword)
		{
			if(GetItemEquippedOnSlot(EES_SilverSword, item))
			{
				hasRuneword = inv.ItemHasAbility(item, abilityName);
			}
		}
		
		return hasRuneword;
	}
	
	public final function GetShrineBuffs() : array<CBaseGameplayEffect>
	{
		var null : array<CBaseGameplayEffect>;
		
		if(effectManager && effectManager.IsReady())
			return effectManager.GetShrineBuffs();
			
		return null;
	}
	
	public final function AddRepairObjectBuff(armor : bool, weapon : bool) : bool
	{
		var added : bool;
		
		added = false;
		
		if(weapon && (IsAnyItemEquippedOnSlot(EES_SilverSword) || IsAnyItemEquippedOnSlot(EES_SteelSword)) )
		{
			AddEffectDefault(EET_EnhancedWeapon, this, "repair_object", false);
			added = true;
		}
		
		if(armor && (IsAnyItemEquippedOnSlot(EES_Armor) || IsAnyItemEquippedOnSlot(EES_Gloves) || IsAnyItemEquippedOnSlot(EES_Boots) || IsAnyItemEquippedOnSlot(EES_Pants)) )
		{
			AddEffectDefault(EET_EnhancedArmor, this, "repair_object", false);
			added = true;
		}
		
		return added;
	}
	
	/*
		Called when new critical effect has started
		This will interrupt current critical state
		
		returns true if the effect got fired properly
	*/
	public function StartCSAnim(buff : CBaseGameplayEffect) : bool
	{
		//if has quen and gets DOT - abort DOT's anim
		if(IsAnyQuenActive() && (W3CriticalDOTEffect)buff)
			return false;
			
		return super.StartCSAnim(buff);
	}
	
	public function GetPotionBuffLevel(effectType : EEffectType) : int
	{
		if(effectManager && effectManager.IsReady())
			return effectManager.GetPotionBuffLevel(effectType);
			
		return 0;
	}	

	////////////////////////////////////////////////////////////////////////////////
	//
	// @Stats
	//
	////////////////////////////////////////////////////////////////////////////////
	
	event OnLevelGained(currentLevel : int, show : bool)
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if(abilityManager && abilityManager.IsInitialized())
		{
			((W3PlayerAbilityManager)abilityManager).OnLevelGained(currentLevel);
		}
		
		if ( theGame.GetDifficultyMode() != EDM_Hardcore ) 
		{
			Heal(GetStatMax(BCS_Vitality));
		} 
	
		//achievement
		if(currentLevel >= 35)
		{
			theGame.GetGamerProfile().AddAchievement(EA_Immortal);
		}
	
		if ( hud && currentLevel < levelManager.GetMaxLevel() && FactsQuerySum( "DebugNoLevelUpUpdates" ) == 0 )
		{
			hud.OnLevelUpUpdate(currentLevel, show);
		}
		
		theGame.RequestAutoSave( "level gained", false );
	}
	
	public function GetSignStats(skill : ESkill, out damageType : name, out damageVal : float, out spellPower : SAbilityAttributeValue)
	{
		var i, size : int;
		var dm : CDefinitionsManagerAccessor;
		var attrs : array<name>;
	
		spellPower = GetPowerStatValue(CPS_SpellPower);
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(GetSkillAbilityName(skill), attrs);
		size = attrs.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( IsDamageTypeNameValid(attrs[i]) )
			{
				damageVal = CalculateAttributeValue(GetSkillAttributeValue(skill, attrs[i], false, true));
				damageType = attrs[i];
				break;
			}
		}
	}
		
	//used by Ignore Pain skill to change max vitality based on dynamically calculated value (cannot use abilities to do that)
	public function SetIgnorePainMaxVitality(val : float)
	{
		if(abilityManager && abilityManager.IsInitialized())
			abilityManager.SetStatPointMax(BCS_Vitality, val);
	}
	
	event OnAnimEvent_ActionBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart && !disableActionBlend )
		{
			if ( this.IsCastingSign() )
				ProcessSignEvent( 'cast_end' );
			//MSTODO:
			//SetMoveTarget( FindNearestTarget() );	
			FindMoveTarget();
			SetCanPlayHitAnim( true );
			this.SetBIsCombatActionAllowed( true );
			
			if ( this.GetFinisherVictim() && this.GetFinisherVictim().HasAbility( 'ForceFinisher' ) && !isInFinisher )
			{
				this.GetFinisherVictim().SignalGameplayEvent( 'Finisher' );
			}
			else if (this.BufferCombatAction != EBAT_EMPTY )
			{
				//if ( !( this.BufferCombatAction == EBAT_CastSign ) )//&& inv.IsItemCrossbow( inv.GetItemFromSlot( 'l_weapon' ) ) ) )
				//LogChannel('combatActionAllowed',"BufferCombatAction != EBAT_EMPTY");
					
					if ( !IsCombatMusicEnabled() )
					{
						SetCombatActionHeading( ProcessCombatActionHeading( this.BufferCombatAction ) ); 
						FindTarget();
						UpdateDisplayTarget( true );
					}
			
					if ( AllowAttack( GetTarget(), this.BufferCombatAction ) )
						this.ProcessCombatActionBuffer();
			}
			else
			{
				//stamina pause should happen just for a brief moment
				ResumeStaminaRegen( 'InsideCombatAction' );
				
				//if sign button is held we should cast sign to have better responsiveness
				/*if (  theInput.GetActionValue( 'CastSignHold' ) > 0.f ) //GetCombatAction() != EBAT_CastSign &&
				{
					this.PushCombatActionOnBuffer( EBAT_CastSign, BS_Pressed);
					this.ProcessCombatActionBuffer();
				}*/
			}
		}
		else if ( disableActionBlend )
		{
			disableActionBlend = false;
		}
	}
	
	
	event OnAnimEvent_Sign( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_Tick )
		{
			ProcessSignEvent( animEventName );
		}
	}
	
	event OnAnimEvent_Throwable( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var thrownEntity		: CThrowable;	
		
		thrownEntity = (CThrowable)EntityHandleGet( thrownEntityHandle );
			
		if ( inv.IsItemCrossbow( inv.GetItemFromSlot('l_weapon') ) &&  rangedWeapon.OnProcessThrowEvent( animEventName ) )
		{		
			return true;
		}
		else if( thrownEntity && IsThrowingItem() && thrownEntity.OnProcessThrowEvent( animEventName ) )
		{
			return true;
		}
	}
	
	event OnTaskSyncAnim( npc : CNewNPC, animNameLeft : name )
	{
		var tmpBool : bool;
		var tmpName : name;
		var damage, points, resistance : float;
		var min, max : SAbilityAttributeValue;
		var mc : EMonsterCategory;
		
		super.OnTaskSyncAnim( npc, animNameLeft );
		
		if( animNameLeft == 'BruxaBite' && IsMutationActive( EPMT_Mutation4 ) )
		{
			theGame.GetMonsterParamsForActor( npc, mc, tmpName, tmpBool, tmpBool, tmpBool );
			
			if( mc == MC_Vampire )
			{
				GetResistValue( CDS_BleedingRes, points, resistance );
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'DirectDamage', min, max );
				damage = MaxF( 0.f, max.valueMultiplicative * GetMaxHealth() - points );
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'duration', min, max );
				damage *= min.valueAdditive * ( 1 - MinF( 1.f, resistance ) );
				
				if( damage > 0.f )
				{
					npc.AddAbility( 'Mutation4BloodDebuff' );
					ProcessActionMutation4ReturnedDamage( damage, npc, EAHA_ForceNo );					
					npc.AddTimer( 'RemoveMutation4BloodDebuff', 15.f, , , , , true );
				}
			}
		}
	}
	
	//Mutation 4 Returned damage
	public function ProcessActionMutation4ReturnedDamage( damageDealt : float, attacker : CActor, hitAnimationType : EActionHitAnim, optional action : W3DamageAction ) : bool
	{
		var customParams				: SCustomEffectParams;
		var currToxicity				: float;
		var min, max, customDamageValue	: SAbilityAttributeValue;
		var dm							: CDefinitionsManagerAccessor;
		var animAction					: W3DamageAction;

		if( damageDealt <= 0 )
		{
			return false;
		}
		
		if( action )
		{
			action.SetMutation4Triggered();
		}
			
		dm = theGame.GetDefinitionsManager();
		currToxicity = GetStat( BCS_Toxicity );
		
		dm.GetAbilityAttributeValue( 'AcidEffect', 'DirectDamage', min, max );
		customDamageValue.valueAdditive = damageDealt * min.valueAdditive;
		
		if( currToxicity > 0 )
		{
			customDamageValue.valueAdditive *= currToxicity;
		}
		
		dm.GetAbilityAttributeValue( 'AcidEffect', 'duration', min, max );
		customDamageValue.valueAdditive /= min.valueAdditive; 
		
		customParams.effectType = EET_Acid;
		customParams.effectValue = customDamageValue;
		customParams.duration = min.valueAdditive;
		customParams.creator = this;
		customParams.sourceName = 'Mutation4';
		
		attacker.AddEffectCustom( customParams );
		
		//hit anim
		animAction = new W3DamageAction in theGame;
		animAction.Initialize( this, attacker, NULL, 'Mutation4', EHRT_Reflect, CPS_Undefined, true, false, false, false );
		animAction.SetCannotReturnDamage( true );
		animAction.SetCanPlayHitParticle( false );
		animAction.SetHitAnimationPlayType( hitAnimationType );
		theGame.damageMgr.ProcessAction( animAction );
		delete animAction;
		
		theGame.MutationHUDFeedback( MFT_PlayOnce );
		
		return true;
	}
	
	event OnPlayerActionEnd()
	{
		var l_i				: int;
		var l_bed			: W3WitcherBed;
		
		l_i = (int)GetBehaviorVariable( 'playerExplorationAction' );
		
		if( l_i == PEA_GoToSleep )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			BlockAllActions( 'WitcherBed', false );
			l_bed.ApplyAppearance( "collision" );
			l_bed.GotoState( 'WakeUp' );
			theGame.ReleaseNoSaveLock( l_bed.m_bedSaveLock );
			
			// HACK
			substateManager.m_MovementCorrectorO.disallowRotWhenGoingToSleep = false;
		}
		
		super.OnPlayerActionEnd();
	}
	
	event OnPlayerActionStartFinished()
	{
		var l_initData			: W3SingleMenuInitData;		
		var l_i					: int;
		
		l_i = (int)GetBehaviorVariable( 'playerExplorationAction' );
		
		if( l_i == PEA_GoToSleep )
		{
			l_initData = new W3SingleMenuInitData in this;
			l_initData.SetBlockOtherPanels( true );
			l_initData.ignoreSaveSystem = true;
			l_initData.ignoreMeditationCheck = true;
			l_initData.setDefaultState( '' );
			l_initData.isBonusMeditationAvailable = true;
			l_initData.fixedMenuName = 'MeditationClockMenu';
			
			theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu', l_initData );
		}
		
		super.OnPlayerActionStartFinished();
	}
	
	public function IsInCombatAction_SpecialAttack() : bool
	{
		if ( IsInCombatAction() && ( GetCombatAction() == EBAT_SpecialAttack_Light || GetCombatAction() == EBAT_SpecialAttack_Heavy ) )
			return true;
		else
			return false;
	}
	
	public function IsInCombatAction_SpecialAttackHeavy() : bool
	{
		if ( IsInCombatAction() && GetCombatAction() == EBAT_SpecialAttack_Heavy )
			return true;
		else
			return false;
	}
	
	protected function WhenCombatActionIsFinished()
	{
		super.WhenCombatActionIsFinished();
		RemoveTimer( 'ProcessAttackTimer' );
		RemoveTimer( 'AttackTimerEnd' );
		CastSignAbort();
		specialAttackCamera = false;
		this.OnPerformSpecialAttack( true, false );
	}
	
	event OnCombatActionEnd()
	{
		this.CleanCombatActionBuffer();		
		super.OnCombatActionEnd();
		
		RemoveTemporarySkills();
	}
	
	event OnCombatActionFriendlyEnd()
	{
		if ( IsCastingSign() )
		{
			SetBehaviorVariable( 'IsCastingSign', 0 );
			SetCurrentlyCastSign( ST_None, NULL );
			LogChannel( 'ST_None', "ST_None" );					
		}

		super.OnCombatActionFriendlyEnd();
	}
	
	public function GetPowerStatValue( stat : ECharacterPowerStats, optional ablName : name, optional ignoreDeath : bool ) : SAbilityAttributeValue
	{
		var result :  SAbilityAttributeValue;
		
		// MUTATION 10 POWER STAT BOOST
		result = super.GetPowerStatValue( stat, ablName, ignoreDeath );
		ApplyMutation10StatBoost( result );
		
		return result;
	}
	
	//--------------------------------- RADIAL MENU #B --------------------------------------
	
	timer function OpenRadialMenu( time: float, id : int )
	{
		//_gfxFuncShowRadialMenu(FlashArgBool(true));
		if( GetBIsCombatActionAllowed() && !IsUITakeInput() )
		{
			bShowRadialMenu = true;
		}
		//LogChannel('RADIAL',"OpenRadialMenu timer");
		this.RemoveTimer('OpenRadialMenu');
	}
	
	public function OnAddRadialMenuOpenTimer(  )
	{
		//LogChannel('RADIAL',"OnAddRadialMenuOpenTimer");
		//if( GetBIsCombatActionAllowed() )
		//{
		    // fix to make radial menu delay independent of current time scale
		    // if it's required in other places as well, changes in timer would be more appropriate
			this.AddTimer('OpenRadialMenu', _HoldBeforeOpenRadialMenuTime * theGame.GetTimeScale() );
		//}
	}

	public function SetShowRadialMenuOpenFlag( bSet : bool  )
	{
		//LogChannel('RADIAL',"OnAddRadialMenuOpenTimer bSet "+bSet);
		bShowRadialMenu = bSet;
	}
	
	public function OnRemoveRadialMenuOpenTimer()
	{
		//LogChannel('RADIAL',"OnRemoveRadialMenuOpenTimer");
		this.RemoveTimer('OpenRadialMenu');
	}
	
	public function ResetRadialMenuOpenTimer()
	{
		//LogChannel('RADIAL',"ResetRadialMenuOpenTimer");
		this.RemoveTimer('OpenRadialMenu');
		if( GetBIsCombatActionAllowed() )
		{
		    // fix to make radial menu delay independent of current time scale
		    // if it's required in other places as well, changes in timer would be more appropriate
			AddTimer('OpenRadialMenu', _HoldBeforeOpenRadialMenuTime * theGame.GetTimeScale() );
		}
	}

	//--------------------------------- Companion Module #B --------------------------------------
	
	timer function ResendCompanionDisplayName(dt : float, id : int)
	{
		var hud : CR4ScriptedHud;
		var companionModule : CR4HudModuleCompanion;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			companionModule = (CR4HudModuleCompanion)hud.GetHudModule("CompanionModule");
			if( companionModule )
			{
				companionModule.ResendDisplayName();
			}
		}
	}

	timer function ResendCompanionDisplayNameSecond(dt : float, id : int)
	{
		var hud : CR4ScriptedHud;
		var companionModule : CR4HudModuleCompanion;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			companionModule = (CR4HudModuleCompanion)hud.GetHudModule("CompanionModule");
			if( companionModule )
			{
				companionModule.ResendDisplayNameSecond();
			}
		}
	}
	
	public function RemoveCompanionDisplayNameTimer()
	{
		this.RemoveTimer('ResendCompanionDisplayName');
	}
		
	public function RemoveCompanionDisplayNameTimerSecond()
	{
		this.RemoveTimer('ResendCompanionDisplayNameSecond');
	}
	
		
	public function GetCompanionNPCTag() : name
	{
		return companionNPCTag;
	}

	public function SetCompanionNPCTag( value : name )
	{
		companionNPCTag = value;
	}	

	public function GetCompanionNPCTag2() : name
	{
		return companionNPCTag2;
	}

	public function SetCompanionNPCTag2( value : name )
	{
		companionNPCTag2 = value;
	}

	public function GetCompanionNPCIconPath() : string
	{
		return companionNPCIconPath;
	}

	public function SetCompanionNPCIconPath( value : string )
	{
		companionNPCIconPath = value;
	}

	public function GetCompanionNPCIconPath2() : string
	{
		return companionNPCIconPath2;
	}

	public function SetCompanionNPCIconPath2( value : string )
	{
		companionNPCIconPath2 = value;
	}
	
	//-------------------------------------- OTHER ---------------------------------------------

	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
	{
		var chance : float;
		var procQuen : W3SignEntity;
		
		if(!damageAction.IsDoTDamage() && damageAction.DealsAnyDamage())
		{
			if(inv.IsItemBomb(selectedItemId))
			{
				BombThrowAbort();
			}
			else
			{
				//usable item and crossbow
				ThrowingAbort();
			}			
		}		
		
		//special item with chance to apply quen when hit with projectile
		if(damageAction.IsActionRanged())
		{
			chance = CalculateAttributeValue(GetAttributeValue('quen_chance_on_projectile'));
			if(chance > 0)
			{
				chance = ClampF(chance, 0, 1);
				
				if(RandF() < chance)
				{
					procQuen = (W3SignEntity)theGame.CreateEntity(signs[ST_Quen].template, GetWorldPosition(), GetWorldRotation() );
					procQuen.Init(signOwner, signs[ST_Quen].entity, true );
					procQuen.OnStarted();
					procQuen.OnThrowing();
					procQuen.OnEnded();
				}
			}
		}
		
		//abort meditation unless it's toxicity damage
		if( !((W3Effect_Toxicity)damageAction.causer) )
			MeditationForceAbort(true);
		
		//if in whirlwind, skip hit animations
		if(IsDoingSpecialAttack(false))
			damageAction.SetHitAnimationPlayType(EAHA_ForceNo);
		
		return super.ReactToBeingHit(damageAction, buffNotApplied);
	}
	
	protected function ShouldPauseHealthRegenOnHit() : bool
	{
		//level 3 swallow prevents regen pause
		if( ( HasBuff( EET_Swallow ) && GetPotionBuffLevel( EET_Swallow ) >= 3 ) || HasBuff( EET_Runeword8 ) || HasBuff( EET_Mutation11Buff ) )
		{
			return false;
		}
			
		return true;
	}
		
	public function SetMappinToHighlight( mappinName : name, mappinState : bool )
	{
		var mappinDef : SHighlightMappin;
		mappinDef.MappinName = mappinName;
		mappinDef.MappinState = mappinState;
		MappinToHighlight.PushBack(mappinDef);
	}	

	public function ClearMappinToHighlight()
	{
		MappinToHighlight.Clear();
	}
	
	public function CastSignAbort()
	{
		if( currentlyCastSign != ST_None && signs[currentlyCastSign].entity)
		{
			signs[currentlyCastSign].entity.OnSignAborted();
		}
		
		//HAX_SignToThrowItemRestore();
	}
	
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		var med : W3PlayerWitcherStateMeditationWaiting;
				
		//abort meditation if meditating
		med = (W3PlayerWitcherStateMeditationWaiting)GetCurrentState();
		if(med)
		{
			med.StopRequested(true);
		}
		
		//super has to be called as last since it changes player state
		super.OnBlockingSceneStarted( scene );
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////    ---===  @HORSE  ===---    ////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function GetHorseManager() : W3HorseManager
	{
		return (W3HorseManager)EntityHandleGet( horseManagerHandle );
	}
	
	//Provide item id from HORSE'S INVENTORY. Returns false if failed.
	public function HorseEquipItem(horsesItemId : SItemUniqueId) : bool
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.EquipItem(horsesItemId) != GetInvalidUniqueId();
			
		return false;
	}
	
	//Returns false if failed
	public function HorseUnequipItem(slot : EEquipmentSlots) : bool
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.UnequipItem(slot) != GetInvalidUniqueId();
			
		return false;
	}
	
	//returns removed amount
	public final function HorseRemoveItemByName(itemName : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByName(itemName, quantity);
	}
	
	//returns removed amount
	public final function HorseRemoveItemByCategory(itemCategory : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByCategory(itemCategory, quantity);
	}
	
	//returns removed amount
	public final function HorseRemoveItemByTag(itemTag : name, quantity : int)
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			man.HorseRemoveItemByTag(itemTag, quantity);
	}
	
	public function GetAssociatedInventory() : CInventoryComponent
	{
		var man : W3HorseManager;
		
		man = GetHorseManager();
		if(man)
			return man.GetInventoryComponent();
			
		return NULL;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////    ---===  @TUTORIAL  ===---    /////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function TutorialMutagensUnequipPlayerSkills() : array<STutorialSavedSkill>
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		return pam.TutorialMutagensUnequipPlayerSkills();
	}
	
	public final function TutorialMutagensEquipOneGoodSkill()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		pam.TutorialMutagensEquipOneGoodSkill();
	}
	
	public final function TutorialMutagensEquipOneGoodOneBadSkill()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
			pam.TutorialMutagensEquipOneGoodOneBadSkill();
	}
	
	public final function TutorialMutagensEquipThreeGoodSkills()
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
			pam.TutorialMutagensEquipThreeGoodSkills();
	}
	
	public final function TutorialMutagensCleanupTempSkills(savedEquippedSkills : array<STutorialSavedSkill>)
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		return pam.TutorialMutagensCleanupTempSkills(savedEquippedSkills);
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////    ---===  @STATS  ===---    ////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function CalculatedArmorStaminaRegenBonus() : float
	{
		var armorEq, glovesEq, pantsEq, bootsEq : bool;
		var tempItem : SItemUniqueId;
		var staminaRegenVal : float;
		var armorRegenVal : SAbilityAttributeValue;
		
		if( HasAbility( 'Glyphword 2 _Stats', true ) )
		{
			armorEq = inv.GetItemEquippedOnSlot( EES_Armor, tempItem );
			glovesEq = inv.GetItemEquippedOnSlot( EES_Gloves, tempItem );
			pantsEq = inv.GetItemEquippedOnSlot( EES_Pants, tempItem );
			bootsEq = inv.GetItemEquippedOnSlot( EES_Boots, tempItem );
			
			if ( armorEq )
				staminaRegenVal += 0.1;
			if ( glovesEq )
				staminaRegenVal += 0.02;
			if ( pantsEq )
				staminaRegenVal += 0.1;
			if ( bootsEq )
				staminaRegenVal += 0.03;
			
		}
		else if( HasAbility( 'Glyphword 3 _Stats', true ) )
		{
			staminaRegenVal = 0;
		}
		else if( HasAbility( 'Glyphword 4 _Stats', true ) )
		{
			armorEq = inv.GetItemEquippedOnSlot( EES_Armor, tempItem );
			glovesEq = inv.GetItemEquippedOnSlot( EES_Gloves, tempItem );
			pantsEq = inv.GetItemEquippedOnSlot( EES_Pants, tempItem );
			bootsEq = inv.GetItemEquippedOnSlot( EES_Boots, tempItem );
			
			if ( armorEq )
				staminaRegenVal -= 0.1;
			if ( glovesEq )
				staminaRegenVal -= 0.02;
			if ( pantsEq )
				staminaRegenVal -= 0.1;
			if ( bootsEq )
				staminaRegenVal -= 0.03;
		}
		else
		{
			armorRegenVal = GetAttributeValue('staminaRegen_armor_mod');
			staminaRegenVal = armorRegenVal.valueMultiplicative;
		}
		
		return staminaRegenVal;
	}
	
	public function GetOffenseStatsList( optional hackMode : int ) : SPlayerOffenseStats
	{
		var playerOffenseStats:SPlayerOffenseStats;
		var steelDmg, silverDmg, elementalSteel, elementalSilver : float;
		var steelCritChance, steelCritDmg : float;
		var silverCritChance, silverCritDmg : float;
		var attackPower	: SAbilityAttributeValue;
		var fastCritChance, fastCritDmg : float;
		var strongCritChance, strongCritDmg : float;
		var fastAP, strongAP, min, max : SAbilityAttributeValue;
		var item, crossbow : SItemUniqueId;
		var value : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var thunder : W3Potion_Thunderbolt;
		
		if(!abilityManager || !abilityManager.IsInitialized())
			return playerOffenseStats;
		
		if (CanUseSkill(S_Sword_s21))
			fastAP += GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s21); 
		if (CanUseSkill(S_Perk_05))
		{
			fastAP += GetAttributeValue('attack_power_fast_style');
			fastCritDmg += CalculateAttributeValue(GetAttributeValue('critical_hit_chance_fast_style'));
			strongCritDmg += CalculateAttributeValue(GetAttributeValue('critical_hit_chance_fast_style'));
		}
		if (CanUseSkill(S_Sword_s04))
			strongAP += GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * GetSkillLevel(S_Sword_s04);
		if (CanUseSkill(S_Perk_07))
			strongAP +=	GetAttributeValue('attack_power_heavy_style');
			
		if (CanUseSkill(S_Sword_s17)) 
		{
			fastCritChance += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s17);
			fastCritDmg += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s17);
		}
		
		if (CanUseSkill(S_Sword_s08)) 
		{
			strongCritChance += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * GetSkillLevel(S_Sword_s08);
			strongCritDmg += CalculateAttributeValue(GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * GetSkillLevel(S_Sword_s08);
		}
		
		if ( HasBuff(EET_Mutagen05) && (GetStat(BCS_Vitality) == GetStatMax(BCS_Vitality)) )
		{
			attackPower += GetAttributeValue('damageIncrease');
		}
		
		steelCritChance += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		silverCritChance += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		steelCritDmg += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		silverCritDmg += CalculateAttributeValue(GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
		attackPower += GetPowerStatValue(CPS_AttackPower);
		
		if (GetItemEquippedOnSlot(EES_SteelSword, item))
		{
			steelDmg = GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_SLASHING, GetInvalidUniqueId());
			steelDmg += GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_PIERCING, GetInvalidUniqueId());
			steelDmg += GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_BLUDGEONING, GetInvalidUniqueId());
			elementalSteel = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FIRE));
			elementalSteel += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FROST)); 
			if ( GetInventory().IsItemHeld(item) )
			{
				steelCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				silverCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				steelCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
				silverCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			}
			steelCritChance += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
			steelCritDmg += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			
			thunder = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
			if(thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm)
			{
				steelCritChance += 1.0f;
			}
		}
		else
		{
			steelDmg += 0;
			steelCritChance += 0;
			steelCritDmg +=0;
		}
		
		if (GetItemEquippedOnSlot(EES_SilverSword, item))
		{
			silverDmg = GetTotalWeaponDamage(item, theGame.params.DAMAGE_NAME_SILVER, GetInvalidUniqueId());
			elementalSilver = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FIRE));
			elementalSilver += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FROST));
			if ( GetInventory().IsItemHeld(item) )
			{
				steelCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				silverCritChance -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
				steelCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
				silverCritDmg -= CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			}
			silverCritChance += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_CHANCE));
			silverCritDmg += CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.CRITICAL_HIT_DAMAGE_BONUS));
			
			thunder = (W3Potion_Thunderbolt)GetBuff(EET_Thunderbolt);
			if(thunder && thunder.GetBuffLevel() == 3 && GetCurWeather() == EWE_Storm)
			{
				silverCritChance += 1.0f;
			}
		}
		else
		{
			silverDmg += 0;
			silverCritChance += 0;
			silverCritDmg +=0;
		}
		
		if ( HasAbility('Runeword 4 _Stats', true) )
		{
			steelDmg += steelDmg * (abilityManager.GetOverhealBonus() / GetStatMax(BCS_Vitality));
			silverDmg += silverDmg * (abilityManager.GetOverhealBonus() / GetStatMax(BCS_Vitality));
		}
		
		fastAP += attackPower;
		strongAP += attackPower;
		
		playerOffenseStats.steelFastCritChance = (steelCritChance + fastCritChance) * 100;
		playerOffenseStats.steelFastCritDmg = steelCritDmg + fastCritDmg;
		if ( steelDmg != 0 )
		{
			playerOffenseStats.steelFastDmg = (steelDmg + fastAP.valueBase) * fastAP.valueMultiplicative + fastAP.valueAdditive + elementalSteel;
			playerOffenseStats.steelFastCritDmg = (steelDmg + fastAP.valueBase) * (fastAP.valueMultiplicative + playerOffenseStats.steelFastCritDmg) + fastAP.valueAdditive + elementalSteel;
		}
		else
		{
			playerOffenseStats.steelFastDmg = 0;
			playerOffenseStats.steelFastCritDmg = 0;
		}
		playerOffenseStats.steelFastDPS = (playerOffenseStats.steelFastDmg * (100 - playerOffenseStats.steelFastCritChance) + playerOffenseStats.steelFastCritDmg * playerOffenseStats.steelFastCritChance) / 100;
		playerOffenseStats.steelFastDPS = playerOffenseStats.steelFastDPS / 0.6;
		//playerOffenseStats.steelFastCritDmg *= 100;
		
		playerOffenseStats.steelStrongCritChance = (steelCritChance + strongCritChance) * 100;
		playerOffenseStats.steelStrongCritDmg = steelCritDmg + strongCritDmg;
		if ( steelDmg != 0 )
		{
			playerOffenseStats.steelStrongDmg = (steelDmg + strongAP.valueBase) * strongAP.valueMultiplicative + strongAP.valueAdditive + elementalSteel;
			playerOffenseStats.steelStrongDmg *= 1.833f;
			playerOffenseStats.steelStrongCritDmg = (steelDmg + strongAP.valueBase) * (strongAP.valueMultiplicative + playerOffenseStats.steelStrongCritDmg) + strongAP.valueAdditive + elementalSteel;
			playerOffenseStats.steelStrongCritDmg *= 1.833f;		}
		else
		{
			playerOffenseStats.steelStrongDmg = 0;
			playerOffenseStats.steelStrongCritDmg = 0;
		}
		playerOffenseStats.steelStrongDPS = (playerOffenseStats.steelStrongDmg * (100 - playerOffenseStats.steelStrongCritChance) + playerOffenseStats.steelStrongCritDmg * playerOffenseStats.steelStrongCritChance) / 100;
		playerOffenseStats.steelStrongDPS = playerOffenseStats.steelStrongDPS / 1.1;
		//playerOffenseStats.steelStrongCritDmg *= 100;
	
		
		playerOffenseStats.silverFastCritChance = (silverCritChance + fastCritChance) * 100;
		playerOffenseStats.silverFastCritDmg = silverCritDmg + fastCritDmg;
		if ( silverDmg != 0 )
		{
			playerOffenseStats.silverFastDmg = (silverDmg + fastAP.valueBase) * fastAP.valueMultiplicative + fastAP.valueAdditive + elementalSilver;
			playerOffenseStats.silverFastCritDmg = (silverDmg + fastAP.valueBase) * (fastAP.valueMultiplicative + playerOffenseStats.silverFastCritDmg) + fastAP.valueAdditive + elementalSilver;	
		}
		else
		{
			playerOffenseStats.silverFastDmg = 0;
			playerOffenseStats.silverFastCritDmg = 0;	
		}
		playerOffenseStats.silverFastDPS = (playerOffenseStats.silverFastDmg * (100 - playerOffenseStats.silverFastCritChance) + playerOffenseStats.silverFastCritDmg * playerOffenseStats.silverFastCritChance) / 100;
		playerOffenseStats.silverFastDPS = playerOffenseStats.silverFastDPS / 0.6;
		//playerOffenseStats.silverFastCritDmg *= 100;
		
		playerOffenseStats.silverStrongCritChance = (silverCritChance + strongCritChance) * 100;
		playerOffenseStats.silverStrongCritDmg = silverCritDmg + strongCritDmg;		
		if ( silverDmg != 0 )
		{
			playerOffenseStats.silverStrongDmg = (silverDmg + strongAP.valueBase) * strongAP.valueMultiplicative + strongAP.valueAdditive + elementalSilver;
			playerOffenseStats.silverStrongDmg *= 1.833f;
			playerOffenseStats.silverStrongCritDmg = (silverDmg + strongAP.valueBase) * (strongAP.valueMultiplicative + playerOffenseStats.silverStrongCritDmg) + strongAP.valueAdditive + elementalSilver;
			playerOffenseStats.silverStrongCritDmg *= 1.833f;
		}
		else
		{
			playerOffenseStats.silverStrongDmg = 0;
			playerOffenseStats.silverStrongCritDmg = 0;
		}
		playerOffenseStats.silverStrongDPS = (playerOffenseStats.silverStrongDmg * (100 - playerOffenseStats.silverStrongCritChance) + playerOffenseStats.silverStrongCritDmg * playerOffenseStats.silverStrongCritChance) / 100;
		playerOffenseStats.silverStrongDPS = playerOffenseStats.silverStrongDPS / 1.1;
		//playerOffenseStats.silverStrongCritDmg *= 100;
		
		playerOffenseStats.crossbowCritChance = GetCriticalHitChance( false, false, NULL, MC_NotSet, true );
	
		// Bolt stats
		playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
		if (GetItemEquippedOnSlot(EES_Bolt, item))
		{
			//GetItemEquippedOnSlot(EES_RangedWeapon, crossbow);
			
			steelDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_FIRE));
			if(steelDmg > 0)
			{
				playerOffenseStats.crossbowSteelDmg = steelDmg;
				
				playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_FIRE;
				playerOffenseStats.crossbowSilverDmg = steelDmg;
			}
			else
			{
				playerOffenseStats.crossbowSilverDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_SILVER));
				
				steelDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_PIERCING));
				if(steelDmg > 0)
				{
					playerOffenseStats.crossbowSteelDmg = steelDmg;
					playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
				}
				else
				{
					playerOffenseStats.crossbowSteelDmg = CalculateAttributeValue(GetInventory().GetItemAttributeValue(item, theGame.params.DAMAGE_NAME_BLUDGEONING));
					playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_BLUDGEONING;
				}
			}
		}
		// Crossbow
		if (GetItemEquippedOnSlot(EES_RangedWeapon, item))
		{
			attackPower += GetInventory().GetItemAttributeValue(item, PowerStatEnumToName(CPS_AttackPower));
			if(CanUseSkill(S_Perk_02))
			{				
				attackPower += GetSkillAttributeValue(S_Perk_02, PowerStatEnumToName(CPS_AttackPower), false, true);
			}

			//mutation 9 increases base damage
			if( hackMode != 1 && ( IsMutationActive( EPMT_Mutation9 ) || hackMode == 2 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
				playerOffenseStats.crossbowSteelDmg += min.valueAdditive;
				playerOffenseStats.crossbowSilverDmg += min.valueAdditive;
			}		
			
			playerOffenseStats.crossbowSteelDmg = (playerOffenseStats.crossbowSteelDmg + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive;
			playerOffenseStats.crossbowSilverDmg = (playerOffenseStats.crossbowSilverDmg + attackPower.valueBase) * attackPower.valueMultiplicative + attackPower.valueAdditive;
		}
		else
		{
			playerOffenseStats.crossbowSteelDmg = 0;
			playerOffenseStats.crossbowSilverDmg = 0;
			playerOffenseStats.crossbowSteelDmgType = theGame.params.DAMAGE_NAME_PIERCING;
		}
		
		return playerOffenseStats;
	}
	
	public function GetTotalWeaponDamage(weaponId : SItemUniqueId, damageTypeName : name, crossbowId : SItemUniqueId) : float
	{
		var damage, durRatio, durMod, itemMod : float;
		var repairObjectBonus, min, max : SAbilityAttributeValue;
		
		durMod = 0;
		damage = super.GetTotalWeaponDamage(weaponId, damageTypeName, crossbowId);
		
		//mutation 9 crossbow bonus
		if( IsMutationActive( EPMT_Mutation9 ) && inv.IsItemBolt( weaponId ) && IsDamageTypeAnyPhysicalType( damageTypeName ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'damage', min, max);
			damage += min.valueAdditive;
		}
		
		//durability & repair bonus only affects physical damage
		if(IsPhysicalResistStat(GetResistForDamage(damageTypeName, false)))
		{
			repairObjectBonus = inv.GetItemAttributeValue(weaponId, theGame.params.REPAIR_OBJECT_BONUS);
			durRatio = -1;
			
			if(inv.IsIdValid(crossbowId) && inv.HasItemDurability(crossbowId))
			{
				durRatio = inv.GetItemDurabilityRatio(crossbowId);
			}
			else if(inv.IsIdValid(weaponId) && inv.HasItemDurability(weaponId))
			{
				durRatio = inv.GetItemDurabilityRatio(weaponId);
			}
			
			//if has durability at all
			if(durRatio >= 0)
				durMod = theGame.params.GetDurabilityMultiplier(durRatio, true);
			else
				durMod = 1;
		}
		
		//Aerondight weapon scaling
		if( damageTypeName == 'SilverDamage' && inv.ItemHasTag( weaponId, 'Aerondight' ) )
		{
			itemMod = inv.GetItemModifierFloat( weaponId, 'PermDamageBoost' );
			if( itemMod > 0.f )
			{
				damage += itemMod;
			}
		}
		
		return damage * (durMod + repairObjectBonus.valueMultiplicative);
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////    ---===  @SKILLS  ===---    ///////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function GetSkillPathType(skill : ESkill) : ESkillPath
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillPathType(skill);
			
		return ESP_NotSet;
	}
	
	public function GetSkillLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillLevel(s);
			
		return -1;
	}
	
	public function GetSkillMaxLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetSkillMaxLevel(s);
			
		return -1;
	}
	
	public function GetBoughtSkillLevel(s : ESkill) : int
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).GetBoughtSkillLevel(s);
			
		return -1;
	}
	
	//used mostly for dialog choice options
	public function GetAxiiLevel() : int
	{
		var level : int;
		
		level = 1;
		
		if(CanUseSkill(S_Magic_s17)) level += GetSkillLevel(S_Magic_s17);
			
		return Clamp(level, 1, 4);
	}
	
	public function IsInFrenzy() : bool
	{
		return isInFrenzy;
	}
	
	public function HasRecentlyCountered() : bool
	{
		return hasRecentlyCountered;
	}
	
	public function SetRecentlyCountered(counter : bool)
	{
		hasRecentlyCountered = counter;
	}
	
	timer function CheckBlockedSkills(dt : float, id : int)
	{
		var nextCallTime : float;
		
		nextCallTime = ((W3PlayerAbilityManager)abilityManager).CheckBlockedSkills(dt);
		if(nextCallTime != -1)
			AddTimer('CheckBlockedSkills', nextCallTime, , , , true);
	}
		
	//removes temporarily gained skills
	public function RemoveTemporarySkills()
	{
		var i : int;
		var pam : W3PlayerAbilityManager;
	
		if(tempLearnedSignSkills.Size() > 0)
		{
			pam = (W3PlayerAbilityManager)abilityManager;
			for(i=0; i<tempLearnedSignSkills.Size(); i+=1)
			{
				pam.RemoveTemporarySkill(tempLearnedSignSkills[i]);
			}
			
			tempLearnedSignSkills.Clear();						
		}
		RemoveAbilityAll(SkillEnumToName(S_Sword_s19));
	}
	
	public function RemoveTemporarySkill(skill : SSimpleSkill) : bool
	{
		var pam : W3PlayerAbilityManager;
		
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam && pam.IsInitialized())
			return pam.RemoveTemporarySkill(skill);
			
		return false;
	}
	
	//add temporarily all skills for 'All Out' skill
	private function AddTemporarySkills()
	{
		if(CanUseSkill(S_Sword_s19) && GetStat(BCS_Focus) >= 3)
		{
			tempLearnedSignSkills = ((W3PlayerAbilityManager)abilityManager).AddTempNonAlchemySkills();						
			DrainFocus(GetStat(BCS_Focus));
			AddAbilityMultiple(SkillEnumToName(S_Sword_s19), GetSkillLevel(S_Sword_s19));			
		}
	}

	/*
	public function GetSkillLinkColorVertical(skill : ESkill, out color : ESkillColor, out isJoker : bool)
	{
		if(abilityManager && abilityManager.IsInitialized())
			((W3PlayerAbilityManager)abilityManager).GetSkillLinkColorVertical(skill, color, isJoker);
	}
	
	public function GetSkillLinkColorLeft(skill : ESkill, out color : ESkillColor, out isJoker : bool)
	{
		if(abilityManager && abilityManager.IsInitialized())
			((W3PlayerAbilityManager)abilityManager).GetSkillLinkColorLeft(skill, color, isJoker);
	}
	
	public function GetSkillLinkColorRight(skill : ESkill, out color : ESkillColor, out isJoker : bool)
	{
		if(abilityManager && abilityManager.IsInitialized())
			((W3PlayerAbilityManager)abilityManager).GetSkillLinkColorRight(skill, color, isJoker);
	}*/
	
	public function HasAlternateQuen() : bool
	{
		var quenEntity : W3QuenEntity;
		
		quenEntity = (W3QuenEntity)GetCurrentSignEntity();
		if(quenEntity)
		{
			return quenEntity.IsAlternateCast();
		}
		
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////
	//////////////////  @LEVELING @EXPERIENCE  ////////////////////////////
	///////////////////////////////////////////////////////////////////////
	
	public function AddPoints(type : ESpendablePointType, amount : int, show : bool)
	{
		levelManager.AddPoints(type, amount, show);
	}
	
	public function GetLevel() : int											{return levelManager.GetLevel();}
	public function GetMaxLevel() : int											{return levelManager.GetMaxLevel();}
	public function GetTotalExpForNextLevel() : int								{return levelManager.GetTotalExpForNextLevel();}	
	public function GetPointsTotal(type : ESpendablePointType) : int 			{return levelManager.GetPointsTotal(type);}
	public function IsAutoLeveling() : bool										{return autoLevel;}
	public function SetAutoLeveling( b : bool )									{autoLevel = b;}
	
	public function GetMissingExpForNextLevel() : int
	{
		return Max(0, GetTotalExpForNextLevel() - GetPointsTotal(EExperiencePoint));
	}
	
	////////////////////////////////////////////////////////////////////////////
	////////////////////  @SIGNS  //////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	private saved var runewordInfusionType : ESignType;
	default runewordInfusionType = ST_None;
	
	public final function GetRunewordInfusionType() : ESignType
	{
		return runewordInfusionType;
	}
	
	//processes impulse skill
	public function QuenImpulse( isAlternate : bool, signEntity : W3QuenEntity, source : string, optional forceSkillLevel : int )
	{
		var level, i, j : int;
		var atts, damages : array<name>;
		var ents : array<CGameplayEntity>;
		var action : W3DamageAction;
		var dm : CDefinitionsManagerAccessor;
		var skillAbilityName : name;
		var dmg : float;
		var min, max : SAbilityAttributeValue;
		var pos : Vector;
		
		if( forceSkillLevel > 0 )
		{
			level = forceSkillLevel;
		}
		else
		{
			level = GetSkillLevel(S_Magic_s13);
		}
		
		dm = theGame.GetDefinitionsManager();
		skillAbilityName = GetSkillAbilityName(S_Magic_s13);
		
		if(level >= 2)
		{
			//load damage types
			dm.GetAbilityAttributes(skillAbilityName, atts);
			for(i=0; i<atts.Size(); i+=1)
			{
				if(IsDamageTypeNameValid(atts[i]))
				{
					damages.PushBack(atts[i]);
				}
			}
		}
		
		//find targets
		pos = signEntity.GetWorldPosition();
		FindGameplayEntitiesInSphere(ents, pos, 3, 1000, '', FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral + FLAG_TestLineOfSight, this);
		
		//apply effects
		for(i=0; i<ents.Size(); i+=1)
		{
			action = new W3DamageAction in theGame;
			action.Initialize(this, ents[i], signEntity, source, EHRT_Heavy, CPS_SpellPower, false, false, true, false);
			action.SetSignSkill(S_Magic_s13);
			action.SetCannotReturnDamage(true);
			action.SetProcessBuffsIfNoDamage(true);
			
			//hit fx for alternate level 2+, sphere has it at the end of func
			if(!isAlternate && level >= 2)
			{
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
			}
			
			if(level >= 1)
			{
				action.AddEffectInfo(EET_Stagger);
			}
			if(level >= 2)
			{
				for(j=0; j<damages.Size(); j+=1)
				{
					dm.GetAbilityAttributeValue(skillAbilityName, damages[j], min, max);
					dmg = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					if( IsSetBonusActive( EISB_Bear_2 ) )
					{
						dm.GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_2 ), 'quen_dmg_boost', min, max );
						dmg *= 1 + min.valueMultiplicative;						
					}					
					action.AddDamage(damages[j], dmg);
				}
			}
			if(level == 3)
			{
				action.AddEffectInfo(EET_KnockdownTypeApplicator);
			}
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		//fx - all levels
		if(isAlternate)
		{
			signEntity.PlayHitEffect('quen_impulse_explode', signEntity.GetWorldRotation());
			signEntity.EraseFirstTimeStamp();
						
			//fx - alternate level 2+, non-alternate has it setup in damage action
			if(level >= 2)
			{
				if( !IsSetBonusActive( EISB_Bear_2 ) )
				{
					signEntity.PlayHitEffect('quen_electric_explode', signEntity.GetWorldRotation());
				}
				else
				{
					signEntity.PlayHitEffect('quen_electric_explode_bear_abl2', signEntity.GetWorldRotation());
				}
			}
		}
		else
		{
			signEntity.PlayEffect('lasting_shield_impulse');
		}		
	}

	public function OnSignCastPerformed(signType : ESignType, isAlternate : bool)
	{
		var items : array<SItemUniqueId>;
		var weaponEnt : CEntity;
		var fxName : name;
		var pos : Vector;
		
		super.OnSignCastPerformed(signType, isAlternate);
		
		if(HasAbility('Runeword 1 _Stats', true) && GetStat(BCS_Focus) >= 1.0f)
		{
			DrainFocus(1.0f);
			runewordInfusionType = signType;
			items = inv.GetHeldWeapons();
			weaponEnt = inv.GetItemEntityUnsafe(items[0]);
			
			//clear previous infusion fx
			weaponEnt.StopEffect('runeword_aard');
			weaponEnt.StopEffect('runeword_axii');
			weaponEnt.StopEffect('runeword_igni');
			weaponEnt.StopEffect('runeword_quen');
			weaponEnt.StopEffect('runeword_yrden');
					
			//show current fx
			if(signType == ST_Aard)
				fxName = 'runeword_aard';
			else if(signType == ST_Axii)
				fxName = 'runeword_axii';
			else if(signType == ST_Igni)
				fxName = 'runeword_igni';
			else if(signType == ST_Quen)
				fxName = 'runeword_quen';
			else if(signType == ST_Yrden)
				fxName = 'runeword_yrden';
				
			weaponEnt.PlayEffect(fxName);
		}
		
		//frost shader in front of Geralt if using mutation 6 and base aard
		if( IsMutationActive( EPMT_Mutation6 ) && signType == ST_Aard && !isAlternate )
		{
			pos = GetWorldPosition() + GetWorldForward() * 2;
			
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup( pos, 0.f, 3.f, 2.f, 5.f, 0 );
		}
	}
	
	public saved var savedQuenHealth, savedQuenDuration : float;
	//this is insane! but there's no event on saving game
	timer function HACK_QuenSaveStatus(dt : float, id : int)
	{
		var quenEntity : W3QuenEntity;
		
		quenEntity = (W3QuenEntity)signs[ST_Quen].entity;
		savedQuenHealth = quenEntity.GetShieldHealth();
		savedQuenDuration = quenEntity.GetShieldRemainingDuration();
	}
	
	timer function DelayedRestoreQuen(dt : float, id : int)
	{
		RestoreQuen(savedQuenHealth, savedQuenDuration);
	}
	
	public final function OnBasicQuenFinishing()
	{
		RemoveTimer('HACK_QuenSaveStatus');
		savedQuenHealth = 0.f;
		savedQuenDuration = 0.f;
	}
	
	public final function IsAnyQuenActive() : bool
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)GetSignEntity(ST_Quen);
		if(quen)
			return quen.IsAnyQuenActive();
			
		return false;
	}
	
	public final function IsQuenActive(alternateMode : bool) : bool
	{
		if(IsAnyQuenActive() && GetSignEntity(ST_Quen).IsAlternateCast() == alternateMode)
			return true;
			
		return false;
	}
	
	public function FinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		var quen : W3QuenEntity;
		
		quen = (W3QuenEntity)GetSignEntity(ST_Quen);
		if(quen)
			quen.ForceFinishQuen( skipVisuals, forceNoBearSetBonus );
	}
	
	//returns value of spell power to be used by this sign (including power bonuses)
	public function GetTotalSignSpellPower(signSkill : ESkill) : SAbilityAttributeValue
	{
		var sp : SAbilityAttributeValue;
		var penalty : SAbilityAttributeValue;
		var penaltyReduction : float;
		var penaltyReductionLevel : int; 
		
		//character SP + spell specific skills
		sp = GetSkillAttributeValue(signSkill, PowerStatEnumToName(CPS_SpellPower), true, true);
		
		//skill custom
		if ( signSkill == S_Magic_s01 )
		{
			//wave leveling penalty reduction
			penaltyReductionLevel = GetSkillLevel(S_Magic_s01) + 1;
			if(penaltyReductionLevel > 0)
			{
				penaltyReduction = 1 - penaltyReductionLevel * CalculateAttributeValue(GetSkillAttributeValue(S_Magic_s01, 'spell_power_penalty_reduction', true, true));
				penalty = GetSkillAttributeValue(S_Magic_s01, PowerStatEnumToName(CPS_SpellPower), false, false);
				sp += penalty * penaltyReduction;	//add amount equal to penalty reduction (since full penalty is already applied)
			}
		}
		
		//magic item abilities
		if(signSkill == S_Magic_1 || signSkill == S_Magic_s01)
		{
			sp += GetAttributeValue('spell_power_aard');
		}
		else if(signSkill == S_Magic_2 || signSkill == S_Magic_s02)
		{
			sp += GetAttributeValue('spell_power_igni');
		}
		else if(signSkill == S_Magic_3 || signSkill == S_Magic_s03)
		{
			sp += GetAttributeValue('spell_power_yrden');
		}
		else if(signSkill == S_Magic_4 || signSkill == S_Magic_s04)
		{
			sp += GetAttributeValue('spell_power_quen');
		}
		else if(signSkill == S_Magic_5 || signSkill == S_Magic_s05)
		{
			sp += GetAttributeValue('spell_power_axii');
		}
		
		//MUTATION 10 SPELL POWER BOOST
		ApplyMutation10StatBoost( sp );
	
		return sp;
	}
	
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////  @GWENT  /////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	
	public final function GetGwentCardIndex( cardName : name ) : int
	{
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		if(dm.ItemHasTag( cardName , 'GwintCardLeader' )) //Checks for Gwent cards factions
		{
			return theGame.GetGwintManager().GwentLeadersNametoInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNrkd' ))
		{
			return theGame.GetGwintManager().GwentNrkdNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNlfg' ))
		{
			return theGame.GetGwintManager().GwentNlfgNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSctl' ))
		{
			return theGame.GetGwintManager().GwentSctlNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardMstr' ))
		{
			return theGame.GetGwintManager().GwentMstrNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSke' ))
		{
			return theGame.GetGwintManager().GwentSkeNameToInt( cardName );
		}	
		else if(dm.ItemHasTag( cardName , 'GwintCardNeutral' ))
		{
			return theGame.GetGwintManager().GwentNeutralNameToInt( cardName );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSpcl' ))
		{
			return theGame.GetGwintManager().GwentSpecialNameToInt( cardName );
		}
		
		return -1;
	}
	
	public final function AddGwentCard(cardName : name, amount : int) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var cardIndex, i : int;
		var tut : STutorialMessage;
		var gwintManager : CR4GwintManager;
		
		//getting new gwent card tutorial - cannot be done in quest as there is no way to send signal
		//to that phase if player activated it before patch
		if(FactsQuerySum("q001_nightmare_ended") > 0 && ShouldProcessTutorial('TutorialGwentDeckBuilder2'))
		{
			tut.type = ETMT_Hint;
			tut.tutorialScriptTag = 'TutorialGwentDeckBuilder2';
			tut.journalEntryName = 'TutorialGwentDeckBuilder2';
			tut.hintPositionType = ETHPT_DefaultGlobal;
			tut.markAsSeenOnShow = true;
			tut.hintDurationType = ETHDT_Long;

			theGame.GetTutorialSystem().DisplayTutorial(tut);
		}
		
		dm = theGame.GetDefinitionsManager();
		
		cardIndex = GetGwentCardIndex(cardName);
		
		if (cardIndex != -1)
		{
			FactsAdd("Gwint_Card_Looted");
			
			for(i = 0; i < amount; i += 1)
			{
				theGame.GetGwintManager().AddCardToCollection( cardIndex );
			}
		}
		
		if( dm.ItemHasTag( cardName, 'GwentTournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsAdd( "GwentTournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsAdd( "GwentTournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsAdd( "GwentTournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsAdd( "GwentTournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsAdd( "GwentTournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsAdd( "GwentTournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsAdd( "GwentTournament", 7 );
			}
			
			CheckGwentTournamentDeck();
		}
		
		if( dm.ItemHasTag( cardName, 'EP2Tournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsAdd( "EP2Tournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsAdd( "EP2Tournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsAdd( "EP2Tournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsAdd( "EP2Tournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsAdd( "EP2Tournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsAdd( "EP2Tournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsAdd( "EP2Tournament", 7 );
			}
			
			CheckEP2TournamentDeck();
		}
		
		gwintManager = theGame.GetGwintManager();
		if( !gwintManager.IsDeckUnlocked( GwintFaction_Skellige ) &&
			gwintManager.HasCardsOfFactionInCollection( GwintFaction_Skellige, false ) )
		{
			gwintManager.UnlockDeck( GwintFaction_Skellige );
		}
		
		return true;
	}
	
	
	public final function RemoveGwentCard(cardName : name, amount : int) : bool
	{
		var dm : CDefinitionsManagerAccessor;
		var cardIndex, i : int;
		
		dm = theGame.GetDefinitionsManager();
		
		if(dm.ItemHasTag( cardName , 'GwintCardLeader' )) //Checks for Gwent cards factions
		{
			cardIndex = theGame.GetGwintManager().GwentLeadersNametoInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNrkd' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNrkdNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNlfg' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNlfgNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSctl' ))
		{
			cardIndex = theGame.GetGwintManager().GwentSctlNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardMstr' ))
		{
			cardIndex = theGame.GetGwintManager().GwentMstrNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardNeutral' ))
		{
			cardIndex = theGame.GetGwintManager().GwentNeutralNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		else if(dm.ItemHasTag( cardName , 'GwintCardSpcl' ))
		{
			cardIndex = theGame.GetGwintManager().GwentSpecialNameToInt( cardName );
			for(i=0; i<amount; i+=1)
				theGame.GetGwintManager().RemoveCardFromCollection( cardIndex );
		}
		
		if( dm.ItemHasTag( cardName, 'GwentTournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsSubstract( "GwentTournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsSubstract( "GwentTournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsSubstract( "GwentTournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsSubstract( "GwentTournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsSubstract( "GwentTournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsSubstract( "GwentTournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsSubstract( "GwentTournament", 7 );
			}
			
			CheckGwentTournamentDeck();
		}
			
			
		if( dm.ItemHasTag( cardName, 'EP2Tournament' ) )
		{
			if ( dm.ItemHasTag( cardName, 'GT1' ) )
			{
				FactsSubstract( "EP2Tournament", 1 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT2' ) )
			{
				FactsSubstract( "EP2Tournament", 2 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT3' ) )
			{
				FactsSubstract( "EP2Tournament", 3 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT4' ) )
			{
				FactsSubstract( "EP2Tournament", 4 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT5' ) )
			{
				FactsSubstract( "EP2Tournament", 5 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT6' ) )
			{
				FactsSubstract( "EP2Tournament", 6 );
			}
			
			else if ( dm.ItemHasTag( cardName, 'GT7' ) )
			{
				FactsSubstract( "EP2Tournament", 7 );
			}
			
			CheckEP2TournamentDeck();
		}
		
		return true;
	}
	
	function CheckGwentTournamentDeck()
	{
		var gwentPower			: int;
		var neededGwentPower	: int;
		var checkBreakpoint		: int;
		
		neededGwentPower = 70;
		
		checkBreakpoint = neededGwentPower/5;
		gwentPower = FactsQuerySum( "GwentTournament" );
		
		if ( gwentPower >= neededGwentPower )
		{
			FactsAdd( "HasGwentTournamentDeck", 1 );
		}
		else
		{
			if( FactsDoesExist( "HasGwentTournamentDeck" ) )
			{
				FactsRemove( "HasGwentTournamentDeck" );
			}
			
			if ( gwentPower >= checkBreakpoint )
			{
				FactsAdd( "GwentTournamentObjective1", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective1" ) )
			{
				FactsRemove( "GwentTournamentObjective1" );
			}
			
			if ( gwentPower >= checkBreakpoint*2 )
			{
				FactsAdd( "GwentTournamentObjective2", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective2" ) )
			{
				FactsRemove( "GwentTournamentObjective2" );
			}
			
			if ( gwentPower >= checkBreakpoint*3 )
			{
				FactsAdd( "GwentTournamentObjective3", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective3" ) )
			{
				FactsRemove( "GwentTournamentObjective3" );
			}
			
			if ( gwentPower >= checkBreakpoint*4 )
			{
				FactsAdd( "GwentTournamentObjective4", 1 );
			}
			else if ( FactsDoesExist( "GwentTournamentObjective4" ) )
			{
				FactsRemove( "GwentTournamentObjective4" );
			}
		}
	}
	
	function CheckEP2TournamentDeck()
	{
		var gwentPower			: int;
		var neededGwentPower	: int;
		var checkBreakpoint		: int;
		
		neededGwentPower = 24;
		
		checkBreakpoint = neededGwentPower/5;
		gwentPower = FactsQuerySum( "EP2Tournament" );
		
		if ( gwentPower >= neededGwentPower )
		{
			if( FactsQuerySum( "HasEP2TournamentDeck") == 0 )
			{
				FactsAdd( "HasEP2TournamentDeck", 1 );
			}
			
		}
		else
		{
			if( FactsDoesExist( "HasEP2TournamentDeck" ) )
			{
				FactsRemove( "HasEP2TournamentDeck" );
			}
			
			if ( gwentPower >= checkBreakpoint )
			{
				FactsAdd( "EP2TournamentObjective1", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective1" ) )
			{
				FactsRemove( "EP2TournamentObjective1" );
			}
			
			if ( gwentPower >= checkBreakpoint*2 )
			{
				FactsAdd( "EP2TournamentObjective2", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective2" ) )
			{
				FactsRemove( "EP2TournamentObjective2" );
			}
			
			if ( gwentPower >= checkBreakpoint*3 )
			{
				FactsAdd( "EP2TournamentObjective3", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective3" ) )
			{
				FactsRemove( "EP2TournamentObjective3" );
			}
			
			if ( gwentPower >= checkBreakpoint*4 )
			{
				FactsAdd( "EP2TournamentObjective4", 1 );
			}
			else if ( FactsDoesExist( "EP2TournamentObjective4" ) )
			{
				FactsRemove( "EP2TournamentObjective4" );
			}
		}
	}
	
	
	////////////////////////////////////////////////////////////////////////////
	////////////////////  @MEDITATION  /////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	
	public function SimulateBuffTimePassing(simulatedTime : float)
	{
		super.SimulateBuffTimePassing(simulatedTime);
		
		FinishQuen(true);
	}
	
	//Can player kneel and enter meditation mode. Does NOT check for 'waiting' mechanics
	public function CanMeditate() : bool
	{
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		//cannot play kneel animation
		if(currentStateName == 'Exploration' && !CanPerformPlayerAction())
			return false;
		
		//not in exloration or meditation
		if(GetCurrentStateName() != 'Exploration' && GetCurrentStateName() != 'Meditation' && GetCurrentStateName() != 'MeditationWaiting')
			return false;
			
		//not in vehicles
		if(GetUsedVehicle())
			return false;
			
		//not if in water
		return CanMeditateHere();
	}
	
	//If the 'waiting' mechanic is available
	public final function CanMeditateWait(optional skipMeditationStateCheck : bool) : bool
	{
		var currState : name;
		
		currState = GetCurrentStateName();
		
		//if not meditating then cannot meditate wait. Also hack for exploration - if game time is paused by menus we might not have had
		//enough time to enter meditation state, and are frozen inbetween
		if(!skipMeditationStateCheck && currState != 'Meditation')
			return false;
			
		//if time stopped cannot meditate as time does not flow at all
		if(theGame.IsGameTimePaused())
			return false;
			
		if(!IsActionAllowed( EIAB_MeditationWaiting ))
			return false;
			
		return true;
	}

	//Is current position ok for kneeling to meditate
	public final function CanMeditateHere() : bool
	{
		var pos	: Vector;
		
		pos = GetWorldPosition();
		if(pos.Z <= theGame.GetWorld().GetWaterLevel(pos, true) && IsInShallowWater())
			return false;
		
		if(IsThreatened())
			return false;
		
		return true;
	}
	
	//Makes player kneel and enter meditation. Does not WAIT any time yet
	public function Meditate() : bool
	{
		var medState 			: W3PlayerWitcherStateMeditation;
		var stateName 			: name;
	
		stateName = GetCurrentStateName();
	
		//ignore animation glitches since the panel hides all now
		if (!CanMeditate() /*|| stateName == 'Meditation'*/ || stateName == 'MeditationWaiting' )
			return false;
	
		GotoState('Meditation');
		medState = (W3PlayerWitcherStateMeditation)GetState('Meditation');		
		medState.SetMeditationPointHeading(GetHeading());
		
		return true;
	}
	
	//healhs health, restores alchemy items
	public final function MeditationRestoring(simulatedTime : float)
	{			
		//health
		if ( theGame.GetDifficultyMode() != EDM_Hard && theGame.GetDifficultyMode() != EDM_Hardcore ) 
		{
			Heal(GetStatMax(BCS_Vitality));
		}
		
		// toxicity
		abilityManager.DrainToxicity( abilityManager.GetStat( BCS_Toxicity ) );
		abilityManager.DrainFocus( abilityManager.GetStat( BCS_Focus ) );
		
		//items
		inv.SingletonItemsRefillAmmo();
		
		//potions
		SimulateBuffTimePassing(simulatedTime);
		
		// Applying witcher house buffs
		ApplyWitcherHouseBuffs();
	}
	
	var clockMenu : CR4MeditationClockMenu;
	
	public function MeditationClockStart(m : CR4MeditationClockMenu)
	{
		clockMenu = m;
		AddTimer('UpdateClockTime',0.1,true);
	}
	
	public function MeditationClockStop()
	{
		clockMenu = NULL;
		RemoveTimer('UpdateClockTime');
	}
	
	public timer function UpdateClockTime(dt : float, id : int)
	{
		if(clockMenu)
			clockMenu.UpdateCurrentHours();
		else
			RemoveTimer('UpdateClockTime');
	}
	
	private var waitTimeHour : int;
	public function SetWaitTargetHour(t : int)
	{
		waitTimeHour = t;
	}
	public function GetWaitTargetHour() : int
	{
		return waitTimeHour;
	}
	
	public function MeditationForceAbort(forceCloseUI : bool)
	{
		var waitt : W3PlayerWitcherStateMeditationWaiting;
		var medd : W3PlayerWitcherStateMeditation;
		var currentStateName : name;
		
		currentStateName = GetCurrentStateName();
		
		if(currentStateName == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)GetCurrentState();
			if(waitt)
			{
				waitt.StopRequested(forceCloseUI);
			}
		}
		else if(currentStateName == 'Meditation')
		{
			medd = (W3PlayerWitcherStateMeditation)GetCurrentState();
			if(medd)
			{
				medd.StopRequested(forceCloseUI);
			}
		}
		
		//because UI handles meditation differently right now, we no longer enter Meditation when entering panel and 
		//when waiting the game is not running (no ticks)
		if(forceCloseUI && theGame.GetGuiManager().IsAnyMenu())
		{
			theGame.GetGuiManager().GetRootMenu().CloseMenu();
			DisplayActionDisallowedHudMessage(EIAB_MeditationWaiting, false, false, true, false);
		}
	}
	
	public function Runeword10Triggerred()
	{
		var min, max : SAbilityAttributeValue; 
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 10 _Stats', 'stamina', min, max );
		GainStat(BCS_Stamina, min.valueMultiplicative * GetStatMax(BCS_Stamina));
		PlayEffect('runeword_10_stamina');
	}
	
	public function Runeword12Triggerred()
	{
		var min, max : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Runeword 12 _Stats', 'focus', min, max );
		GainStat(BCS_Focus, RandRangeF(max.valueAdditive, min.valueAdditive));
		PlayEffect('runeword_20_adrenaline');	//fx has typo in name
	}
	
	var runeword10TriggerredOnFinisher, runeword12TriggerredOnFinisher : bool;
	
	event OnFinisherStart()
	{
		super.OnFinisherStart();
		
		runeword10TriggerredOnFinisher = false;
		runeword12TriggerredOnFinisher = false;
	}
	
	public function ApplyWitcherHouseBuffs()
	{
		var l_bed			: W3WitcherBed;
		
		if( FactsQuerySum( "PlayerInsideInnerWitcherHouse" ) > 0 )
		{
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			
			if( l_bed.GetWasUsed() )
			{
				if( l_bed.GetBedLevel() != 0 )
				{
					AddEffectDefault( EET_WellRested, this, "Bed Buff" );
				}

				if( FactsQuerySum( "StablesExists" ) )
				{
					AddEffectDefault( EET_HorseStableBuff, this, "Stables" );
				}
				
				if( l_bed.GetWereItemsRefilled() )
				{
					theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_alchemy_table_buff_applied" ),, true );
					l_bed.SetWereItemsRefilled( false );
				}
				
				AddEffectDefault( EET_BookshelfBuff, this, "Bookshelf" );
				
				Heal( GetStatMax( BCS_Vitality ) );
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////
	////////////////////  @DEBUG  //////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	
	public function CheatResurrect()
	{
		super.CheatResurrect();
		theGame.ReleaseNoSaveLock(theGame.deathSaveLockId);
		theInput.RestoreContext( 'Exploration', true );	
	}
	
	//testing skills equip
	public function Debug_EquipTestingSkills(equip : bool, force : bool)
	{
		var skills : array<ESkill>;
		var i, slot : int;
		
		//make pam believe it's level 36 so it unlocks skill slots
		((W3PlayerAbilityManager)abilityManager).OnLevelGained(36);
		
		skills.PushBack(S_Magic_s01);
		skills.PushBack(S_Magic_s02);
		skills.PushBack(S_Magic_s03);
		skills.PushBack(S_Magic_s04);
		skills.PushBack(S_Magic_s05);
		skills.PushBack(S_Sword_s01);
		skills.PushBack(S_Sword_s02);
		
		//equip special skills
		if(equip)
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				if(!force && IsSkillEquipped(skills[i]))
					continue;
					
				//add skill
				if(GetSkillLevel(skills[i]) == 0)
					AddSkill(skills[i]);
				
				//find free slot
				if(force)
					slot = i+1;		//slots are numbered 1+ not 0+
				else
					slot = GetFreeSkillSlot();
				
				//equip
				EquipSkill(skills[i], slot);
			}
		}
		else
		{
			for(i=0; i<skills.Size(); i+=1)
			{
				UnequipSkill(GetSkillSlotID(skills[i]));
			}
		}
	}
	
	public function Debug_ClearCharacterDevelopment(optional keepInv : bool)
	{
		var template : CEntityTemplate;
		var entity : CEntity;
		var invTesting : CInventoryComponent;
		var i : int;
		var items : array<SItemUniqueId>;
		var abs : array<name>;
	
		delete abilityManager;
		delete levelManager;
		delete effectManager;
		
		//remove old abilities
		abs = GetAbilities(false);
		for(i=0; i<abs.Size(); i+=1)
			RemoveAbility(abs[i]);
			
		//get default abilities and add them
		abs.Clear();
		GetCharacterStatsParam(abs);		
		for(i=0; i<abs.Size(); i+=1)
			AddAbility(abs[i]);
					
		//leveling
		levelManager = new W3LevelManager in this;			
		levelManager.Initialize();
		levelManager.PostInit(this, false, true);		
						
		//skills, perks etc., exp, buffs
		AddAbility('GeraltSkills_Testing');
		SetAbilityManager();		//defined in inheriting classes but must be called before setting any other managers - sets skills and stats
		abilityManager.Init(this, GetCharacterStats(), false, theGame.GetDifficultyMode());
		
		SetEffectManager();
		
		abilityManager.PostInit();						//called after other managers are ready	
		
		//Debug_EquipTestingSkills(false);
		
		//--------------------------------------  ITEMS		
		//remove items
		if(!keepInv)
		{
			inv.RemoveAllItems();
		}		
		
		//add default items
		template = (CEntityTemplate)LoadResource("geralt_inventory_release");
		entity = theGame.CreateEntity(template, Vector(0,0,0));
		invTesting = (CInventoryComponent)entity.GetComponentByClassName('CInventoryComponent');
		invTesting.GiveAllItemsTo(inv, true);
		entity.Destroy();
		
		//equip items
		inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if(!inv.ItemHasTag(items[i], 'NoDrop'))			//skip body parts
				EquipItem(items[i]);
		}
			
		//items from testing inventory entity
		Debug_GiveTestingItems(0);
	}
	
	function Debug_BearSetBonusQuenSkills()
	{
		var skills	: array<ESkill>;
		var i, slot	: int;
		
		skills.PushBack(S_Magic_s04);
		skills.PushBack(S_Magic_s14);
		
		for(i=0; i<skills.Size(); i+=1)
		{				
			//add skill
			if(GetSkillLevel(skills[i]) == 0)
			{
				AddSkill(skills[i]);
			}
			
			slot = GetFreeSkillSlot();
			
			//equip
			EquipSkill(skills[i], slot);
		}
	}
	
	final function Debug_HAX_UnlockSkillSlot(slotIndex : int) : bool
	{
		if(abilityManager && abilityManager.IsInitialized())
			return ((W3PlayerAbilityManager)abilityManager).Debug_HAX_UnlockSkillSlot(slotIndex);
			
		return false;
	}
	
	
	public function GetLevelupAbility( id : int) : name
	{
		switch(id)
		{
			case 1: return 'Lvl1';
			case 2: return 'Lvl2';
			case 3: return 'Lvl3';
			case 4: return 'Lvl4';
			case 5: return 'Lvl5';
			case 6: return 'Lvl6';
			case 7: return 'Lvl7';
			case 8: return 'Lvl8';
			case 9: return 'Lvl9';
			case 10: return 'Lvl10';
			case 11: return 'Lvl11';
			case 12: return 'Lvl12';
			case 13: return 'Lvl13';
			case 14: return 'Lvl14';
			case 15: return 'Lvl15';
			case 16: return 'Lvl16';
			case 17: return 'Lvl17';
			case 18: return 'Lvl18';
			case 19: return 'Lvl19';
			case 20: return 'Lvl20';
			case 21: return 'Lvl21';
			case 22: return 'Lvl22';
			case 23: return 'Lvl23';
			case 24: return 'Lvl24';
			case 25: return 'Lvl25';
			case 26: return 'Lvl26';
			case 27: return 'Lvl27';
			case 28: return 'Lvl28';
			case 29: return 'Lvl29';
			case 30: return 'Lvl30';
			case 31: return 'Lvl31';
			case 32: return 'Lvl32';
			case 33: return 'Lvl33';
			case 34: return 'Lvl34';
			case 35: return 'Lvl35';
			case 36: return 'Lvl36';
			case 37: return 'Lvl37';
			case 38: return 'Lvl38';
			case 39: return 'Lvl39';
			case 40: return 'Lvl40';
			case 41: return 'Lvl41';
			case 42: return 'Lvl42';
			case 43: return 'Lvl43';
			case 44: return 'Lvl44';
			case 45: return 'Lvl45';
			case 46: return 'Lvl46';
			case 47: return 'Lvl47';
			case 48: return 'Lvl48';
			case 49: return 'Lvl49';
			case 50: return 'Lvl50';
		
			default: return '';
		}
		
		return '';
	}	
	
	public function CanSprint( speed : float ) : bool
	{
		if( !super.CanSprint( speed ) )
		{
			return false;
		}		
		if( rangedWeapon && rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			if ( this.GetPlayerCombatStance() ==  PCS_AlertNear )
			{
				if ( IsSprintActionPressed() )
					OnRangedForceHolster( true, false );
			}
			else
				return false;
		}
		if( GetCurrentStateName() != 'Swimming' && GetStat(BCS_Stamina) <= 0 )
		{
			SetSprintActionPressed(false,true);
			return false;
		}
		
		return true;
	}
	
	public function ManageSleeping()
	{
		thePlayer.RemoveBuffImmunity_AllCritical( 'Bed' );
		thePlayer.RemoveBuffImmunity_AllNegative( 'Bed' );

		thePlayer.PlayerStopAction( PEA_GoToSleep );
	}
	
	// Purpose of this command is ONLY to allow to continue testing on saves with broken horse manager
	// DO NOT USE IT OTHERWISE
	public function RestoreHorseManager() : bool
	{
		var horseTemplate 	: CEntityTemplate;
		var horseManager 	: W3HorseManager;	
		
		if ( GetHorseManager() )
		{
			return false;
		}
		
		horseTemplate = (CEntityTemplate)LoadResource("horse_manager");
		horseManager = (W3HorseManager)theGame.CreateEntity(horseTemplate, GetWorldPosition(),,,,,PM_Persist);
		horseManager.CreateAttachment(this);
		horseManager.OnCreated();
		EntityHandleSet( horseManagerHandle, horseManager );	
		
		return true;
	}
	
	//private saved var blockedSigns : array<ESignType>;
	
	/*public final function BlockSignSelection(signType : ESignType, block : bool)
	{
		if(block && !blockedSigns.Contains(signType))
			blockedSigns.PushBack(signType);
		else if(!block)
			blockedSigns.Remove(signType);
	}*/
	
	/*public final function GetBlockedSigns () : array<ESignType>
	{
		return blockedSigns;
	}*/
	final function PerformParryCheck( parryInfo : SParryInfo ) : bool
	{
		if( super.PerformParryCheck( parryInfo ) )
		{
			GainAdrenalineFromPerk21( 'parry' );
			return true;
		}
		return false;
	}	
	
	protected final function PerformCounterCheck( parryInfo: SParryInfo ) : bool
	{
		var fistFightCheck, isInFistFight		: bool;
		
		if( super.PerformCounterCheck( parryInfo ) )
		{
			GainAdrenalineFromPerk21( 'counter' );
			
			isInFistFight = FistFightCheck( parryInfo.target, parryInfo.attacker, fistFightCheck );
			
			if( isInFistFight && fistFightCheck )
			{
				FactsAdd( "statistics_fist_fight_counter" );
				AddTimer( 'FistFightCounterTimer', 0.5f, , , , true );
			}
			
			return true;
		}
		return false;
	}
	
	public function GainAdrenalineFromPerk21( n : name )
	{
		var perkStats, perkTime : SAbilityAttributeValue;
		var targets	: array<CActor>;
		
		targets = GetHostileEnemies();
		
		if( !CanUseSkill( S_Perk_21 ) || targets.Size() == 0 )
		{
			return;
		}
		
		perkTime = GetSkillAttributeValue( S_Perk_21, 'perk21Time', false, false );
		
		if( theGame.GetEngineTimeAsSeconds() >= timeForPerk21 + perkTime.valueAdditive )
		{
			perkStats = GetSkillAttributeValue( S_Perk_21, n , false, false );
			GainStat( BCS_Focus, perkStats.valueAdditive );
			timeForPerk21 = theGame.GetEngineTimeAsSeconds();
			
			AddEffectDefault( EET_Perk21InternalCooldown, this, "Perk21", false );
		}	
	}
	
	timer function FistFightCounterTimer( dt : float, id : int )
	{
		FactsRemove( "statistics_fist_fight_counter" );
	}
	
	public final function IsSignBlocked(signType : ESignType) : bool
	{
		switch( signType )
		{
			case ST_Aard :
				return IsRadialSlotBlocked ( 'Aard');
				break;
			case ST_Axii :
				return IsRadialSlotBlocked ( 'Axii');
				break;
			case ST_Igni :
				return IsRadialSlotBlocked ( 'Igni');
				break;
			case ST_Quen :
				return IsRadialSlotBlocked ( 'Quen');
				break;
			case ST_Yrden :
				return IsRadialSlotBlocked ( 'Yrden');
				break;
			default:
				break;
		}
		return false;
		//return blockedSigns.Contains(signType);
	}
	
	public final function AddAnItemWithAutogenLevelAndQuality(itemName : name, desiredLevel : int, minQuality : int, optional equipItem : bool)
	{
		var itemLevel, quality : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;
		
		itemLevel = 0;
		quality = 0;
		attemptCounter = 0;
		while(itemLevel != desiredLevel || quality < minQuality)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			itemLevel = inv.GetItemLevel(ids[0]);
			quality = RoundMath(CalculateAttributeValue(inv.GetItemAttributeValue(ids[0], 'quality')));
			
			//if not doable at all
			if(attemptCounter >= 1000)
				break;
			
			if(itemLevel != desiredLevel || quality < minQuality)
				inv.RemoveItem(ids[0]);
		}
		
		if(equipItem)
			EquipItem(ids[0]);
	}
	
	public final function AddAnItemWithAutogenLevel(itemName : name, desiredLevel : int)
	{
		var itemLevel : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;

		itemLevel = 0;
		while(itemLevel != desiredLevel)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			itemLevel = inv.GetItemLevel(ids[0]);
			
			//if not doable at all
			if(attemptCounter >= 1000)
				break;
				
			if(itemLevel != desiredLevel)
				inv.RemoveItem(ids[0]);
		}
	}
	
	public final function AddAnItemWithMinQuality(itemName : name, minQuality : int, optional equip : bool)
	{
		var quality : int;
		var ids : array<SItemUniqueId>;
		var attemptCounter : int;

		quality = 0;
		while(quality < minQuality)
		{
			attemptCounter += 1;
			ids.Clear();
			ids = inv.AddAnItem(itemName, 1, true);
			quality = RoundMath(CalculateAttributeValue(inv.GetItemAttributeValue(ids[0], 'quality')));
			
			//if not doable at all
			if(attemptCounter >= 1000)
				break;
				
			if(quality < minQuality)
				inv.RemoveItem(ids[0]);
		}
		
		if(equip)
			EquipItem(ids[0]);
	}
	
	
	//////////////////////////////////////////
	//				SET BONUSES				//
	//////////////////////////////////////////
	
	public function IsSetBonusActive( bonus : EItemSetBonus ) : bool
	{
		switch(bonus)
		{
			case EISB_Lynx_1:			return amountOfSetPiecesEquipped[ EIST_Lynx ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Lynx_2:			return amountOfSetPiecesEquipped[ EIST_Lynx ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Gryphon_1:		return amountOfSetPiecesEquipped[ EIST_Gryphon ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Gryphon_2:		return amountOfSetPiecesEquipped[ EIST_Gryphon ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Bear_1:			return amountOfSetPiecesEquipped[ EIST_Bear ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Bear_2:			return amountOfSetPiecesEquipped[ EIST_Bear ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Wolf_1:			return amountOfSetPiecesEquipped[ EIST_Wolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_Wolf_2:			return amountOfSetPiecesEquipped[ EIST_Wolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_RedWolf_1:		return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			case EISB_RedWolf_2:		return amountOfSetPiecesEquipped[ EIST_RedWolf ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
			case EISB_Vampire:			return amountOfSetPiecesEquipped[ EIST_Vampire ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
			default:					return false;
		}
	}
	
	public function GetSetPartsEquipped( setType : EItemSetType ) : int
	{
		return amountOfSetPiecesEquipped[ setType ];
	}
	
	protected function UpdateItemSetBonuses( item : SItemUniqueId, increment : bool )
	{
		var setType : EItemSetType;
		var tutorialStateSets : W3TutorialManagerUIHandlerStateSetItemsUnlocked;
		var id : SItemUniqueId;
					
		if( !inv.IsIdValid( item ) || !inv.ItemHasTag(item, theGame.params.ITEM_SET_TAG_BONUS ) )  
		{
			//wolf set bonus 1 - up to 3 oils on item
			if( !IsSetBonusActive( EISB_Wolf_1 ) )
			{
				if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
				{
					RemoveExtraOilsFromItem( id );
				}
				if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
				{
					RemoveExtraOilsFromItem( id );
				}
			}
		
			return;
		}
		
		setType = CheckSetType( item );
		
		if( increment )
		{
			amountOfSetPiecesEquipped[ setType ] += 1;
			
			if( amountOfSetPiecesEquipped[ setType ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS && ShouldProcessTutorial( 'TutorialSetBonusesUnlocked' ) && theGame.GetTutorialSystem().uiHandler && theGame.GetTutorialSystem().uiHandler.GetCurrentStateName() == 'SetItemsUnlocked' )
			{
				tutorialStateSets = ( W3TutorialManagerUIHandlerStateSetItemsUnlocked )theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				tutorialStateSets.OnSetBonusCompleted();
			}
		}
		else
		{
			amountOfSetPiecesEquipped[ setType ] -= 1;
		}
		
		//Achievement - Ready To Roll
		if( setType != EIST_Vampire && amountOfSetPiecesEquipped[ setType ] == theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS )
		{
			theGame.GetGamerProfile().AddAchievement( EA_ReadyToRoll );
		}
		
		//wolf set bonus 1 - up to 3 oils on item
		if( !IsSetBonusActive( EISB_Wolf_1 ) )
		{
			if( GetItemEquippedOnSlot( EES_SteelSword, id ) )
			{
				RemoveExtraOilsFromItem( id );
			}
			if( GetItemEquippedOnSlot( EES_SilverSword, id ) )
			{
				RemoveExtraOilsFromItem( id );
			}
		}
		
		ManageActiveSetBonuses( setType );
		
		// Loading soundbanks
		ManageSetBonusesSoundbanks( setType );
	}
	
	public function ManageActiveSetBonuses( setType : EItemSetType )
	{
		var l_i				: int;
		
		//LYNX SET
		if( setType == EIST_Lynx )
		{
			//Lynx Set Bonus 1
			if( HasBuff( EET_LynxSetBonus ) && !IsSetBonusActive( EISB_Lynx_1 ) )
			{
				RemoveBuff( EET_LynxSetBonus );
			}
		}
		//GRYPHON SET
		else if( setType == EIST_Gryphon )
		{
			// Gryphon Set Bonus 1
			if( !IsSetBonusActive( EISB_Gryphon_1 ) )
			{
				RemoveBuff( EET_GryphonSetBonus );
			}
			// Gryphon Set Bonus 2
			if( IsSetBonusActive( EISB_Gryphon_2 ) && !HasBuff( EET_GryphonSetBonusYrden ) )
			{
				for( l_i = 0 ; l_i < yrdenEntities.Size() ; l_i += 1 )
				{
					if( yrdenEntities[ l_i ].GetIsPlayerInside() && !yrdenEntities[ l_i ].IsAlternateCast() )
					{
						AddEffectDefault( EET_GryphonSetBonusYrden, this, "GryphonSetBonusYrden" );
						break;
					}
				}
			}
			else
			{
				RemoveBuff( EET_GryphonSetBonusYrden );
			}
		}
	}
	
	public function CheckSetTypeByName( itemName : name ) : EItemSetType
	{
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_LYNX ) )
		{
			return EIST_Lynx;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_GRYPHON ) )
		{
			return EIST_Gryphon;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_BEAR ) )
		{
			return EIST_Bear;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_WOLF ) )
		{
			return EIST_Wolf;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_RED_WOLF ) )
		{
			return EIST_RedWolf;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VAMPIRE ) )
		{
			return EIST_Vampire;
		}
		else
		if( dm.ItemHasTag( itemName, theGame.params.ITEM_SET_TAG_VIPER ) )
		{
			return EIST_Viper;
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	public function CheckSetType( item : SItemUniqueId ) : EItemSetType
	{
		var stopLoop 	: bool;
		var tags 		: array<name>;
		var i 			: int;
		var setType 	: EItemSetType;
		
		stopLoop = false;
		
		inv.GetItemTags( item, tags );
		
		// Checking what type set has been equipped
		for( i=0; i<tags.Size(); i+=1 )
		{
			switch( tags[i] )
			{
				case theGame.params.ITEM_SET_TAG_LYNX:
				case theGame.params.ITEM_SET_TAG_GRYPHON:
				case theGame.params.ITEM_SET_TAG_BEAR:
				case theGame.params.ITEM_SET_TAG_WOLF:
				case theGame.params.ITEM_SET_TAG_RED_WOLF:
				case theGame.params.ITEM_SET_TAG_VAMPIRE:
				case theGame.params.ITEM_SET_TAG_VIPER:
					setType = SetItemNameToType( tags[i] );
					stopLoop = true;
					break;
			}		
			if ( stopLoop )
			{
				break;
			}
		}
		
		return setType;
	}
	
	public function GetSetBonusStatusByName( itemName : name, out desc1, desc2 : string, out isActive1, isActive2 : bool ) : EItemSetType
	{
		var setType : EItemSetType;
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			setType = CheckSetTypeByName( itemName );
			SetBonusStatusByType( setType, desc1, desc2, isActive1, isActive2 );
			
			return setType;		
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	public function GetSetBonusStatus( item : SItemUniqueId, out desc1, desc2 : string, out isActive1, isActive2 : bool ) : EItemSetType
	{
		var setType : EItemSetType;
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			setType = CheckSetType( item );
			SetBonusStatusByType( setType, desc1, desc2, isActive1, isActive2 );
			
			return setType;
		}
		else
		{
			return EIST_Undefined;
		}
	}
	
	private function SetBonusStatusByType(setType : EItemSetType, out desc1, desc2 : string, out isActive1, isActive2 : bool):void
	{
		var setBonus : EItemSetBonus;
		
		if( amountOfSetPiecesEquipped[ setType ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS )
		{
			isActive1 = true;			
		}
		
		if( amountOfSetPiecesEquipped[ setType ] >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS )
		{
			isActive2 = true;
		}
		
		setBonus = ItemSetTypeToItemSetBonus( setType, 1 );
		desc1 = GetSetBonusTooltipDescription( setBonus );
		
		setBonus = ItemSetTypeToItemSetBonus( setType, 2 );
		desc2 = GetSetBonusTooltipDescription( setBonus );
	}
	
	public function ItemSetTypeToItemSetBonus( setType : EItemSetType, nr : int ) : EItemSetBonus
	{
		var setBonus : EItemSetBonus;
	
		if( nr == 1 )
		{
			switch( setType )
			{
				case EIST_Lynx: 			setBonus = EISB_Lynx_1;		break;
				case EIST_Gryphon: 			setBonus = EISB_Gryphon_1;	break;
				case EIST_Bear: 			setBonus = EISB_Bear_1;		break;
				case EIST_Wolf: 			setBonus = EISB_Wolf_1;		break;
				case EIST_RedWolf: 			setBonus = EISB_RedWolf_1;	break;
				case EIST_Vampire:			setBonus = EISB_Vampire;	break;
			}
		}
		else
		{
			switch( setType )
			{
				case EIST_Lynx: 			setBonus = EISB_Lynx_2;		break;
				case EIST_Gryphon: 			setBonus = EISB_Gryphon_2;	break;
				case EIST_Bear: 			setBonus = EISB_Bear_2;		break;
				case EIST_Wolf: 			setBonus = EISB_Wolf_2;		break;
				case EIST_RedWolf: 			setBonus = EISB_RedWolf_2;	break;
				case EIST_Vampire:			setBonus = EISB_Undefined;	break;
			}
		} 
	
		return setBonus;
	}
	
	public function GetSetBonusTooltipDescription( bonus : EItemSetBonus ) : string
	{
		var finalString : string;
		var arrString	: array<string>;
		var dm			: CDefinitionsManagerAccessor;
		var min, max 	: SAbilityAttributeValue;
		var tempString	: string;
		
		switch( bonus )
		{
			case EISB_Lynx_1:			tempString = "skill_desc_lynx_set_ability1"; break;
			case EISB_Lynx_2:			tempString = "skill_desc_lynx_set_ability2"; break;
			case EISB_Gryphon_1:		tempString = "skill_desc_gryphon_set_ability1"; break;
			case EISB_Gryphon_2:		tempString = "skill_desc_gryphon_set_ability2"; break;
			case EISB_Bear_1:			tempString = "skill_desc_bear_set_ability1"; break;
			case EISB_Bear_2:			tempString = "skill_desc_bear_set_ability2"; break;
			case EISB_Wolf_1:			tempString = "skill_desc_wolf_set_ability2"; break;
			case EISB_Wolf_2:			tempString = "skill_desc_wolf_set_ability1"; break;
			case EISB_RedWolf_1:		tempString = "skill_desc_red_wolf_set_ability1"; break;
			case EISB_RedWolf_2:		tempString = "skill_desc_red_wolf_set_ability2"; break;
			case EISB_Vampire:			tempString = "skill_desc_vampire_set_ability1"; break;
			default:					tempString = ""; break;
		}
		
		dm = theGame.GetDefinitionsManager();
		
		switch( bonus )
		{
		case EISB_Lynx_1:
			dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'duration', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			dm.GetAbilityAttributeValue( 'LynxSetBonusEffect', 'lynx_dmg_boost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) ); 
			arrString.PushBack( FloatToString( min.valueAdditive * 100 * amountOfSetPiecesEquipped[ EIST_Lynx ] ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Lynx_2:
			dm.GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_dmg_boost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100 ) );
			
			dm.GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_adrenaline_cost', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Gryphon_1:
			dm.GetAbilityAttributeValue( 'GryphonSetBonusEffect', 'duration', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString ); 
			break;		
		case EISB_Gryphon_2:
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			arrString.PushBack( FloatToString( ( min.valueAdditive - 1 )* 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'staminaRegen', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'spell_power', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100) );
			dm.GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'gryphon_set_bns_dmg_reduction', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive * 100) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Bear_1:
			dm.GetAbilityAttributeValue( 'setBonusAbilityBear_1', 'quen_reapply_chance', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100 ) );
			
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100 * amountOfSetPiecesEquipped[ EIST_Bear ] ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Bear_2:
			dm.GetAbilityAttributeValue( 'setBonusAbilityBear_2', 'quen_dmg_boost', min, max );
			arrString.PushBack( FloatToString( min.valueMultiplicative * 100 ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_RedWolf_2:
			dm.GetAbilityAttributeValue( 'setBonusAbilityRedWolf_2', 'amount', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		case EISB_Vampire:
			dm.GetAbilityAttributeValue( 'setBonusAbilityVampire', 'life_percent', min, max );
			arrString.PushBack( FloatToString( min.valueAdditive ) );
			arrString.PushBack( FloatToString( min.valueAdditive * amountOfSetPiecesEquipped[ EIST_Vampire ] ) );
			finalString = GetLocStringByKeyExtWithParams( tempString,,,arrString );
			break;
		default:
			finalString = GetLocStringByKeyExtWithParams( tempString );
		}
		
		return finalString;
	}
	
	public function ManageSetBonusesSoundbanks( setType : EItemSetType )
	{
		if( amountOfSetPiecesEquipped[ setType ] >= theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS )
		{
			switch( setType )
			{
				case EIST_Lynx:
					LoadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
					break;
				case EIST_Gryphon:
					LoadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
					break;
				case EIST_Bear:
					LoadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
					break;
			}
		}
		else
		{
			switch( setType )
			{
				case EIST_Lynx:
					UnloadSetBonusSoundBank( "ep2_setbonus_lynx.bnk" );
					break;
				case EIST_Gryphon:
					UnloadSetBonusSoundBank( "ep2_setbonus_gryphon.bnk" );
					break;
				case EIST_Bear:
					UnloadSetBonusSoundBank( "ep2_setbonus_bear.bnk" );
					break;
			}
		}
	}
	
	public function VampiricSetAbilityRegeneration()
	{
		var healthMax		: float;
		var healthToReg		: float;
		
		healthMax = GetStatMax( BCS_Vitality );
		
		healthToReg = ( amountOfSetPiecesEquipped[ EIST_Vampire ] * healthMax ) / 100;
		
		PlayEffect('drain_energy_caretaker_shovel');
		GainStat( BCS_Vitality, healthToReg );
	}
	
	private function LoadSetBonusSoundBank( bankName : string )
	{
		if( !theSound.SoundIsBankLoaded( bankName ) )
		{
			theSound.SoundLoadBank( bankName, true );
		}
	}
	
	private function UnloadSetBonusSoundBank( bankName : string )
	{
		if( theSound.SoundIsBankLoaded( bankName ) )
		{
			theSound.SoundUnloadBank( bankName );
		}
	}
	
	timer function BearSetBonusQuenReapply( dt : float, id : int )
	{
		var newQuen		: W3QuenEntity;
		
		newQuen = (W3QuenEntity)theGame.CreateEntity( GetSignTemplate( ST_Quen ), GetWorldPosition(), GetWorldRotation() );
		newQuen.Init( signOwner, GetSignEntity( ST_Quen ), true );
		newQuen.freeFromBearSetBonus = true;
		newQuen.OnStarted();
		newQuen.OnThrowing();
		newQuen.OnEnded();
		
		m_quenReappliedCount += 1;
		
		RemoveTimer( 'BearSetBonusQuenReapply');
	}
	
	public final function StandaloneEp1_1()
	{
		var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
		var pam : W3PlayerAbilityManager;
		var ids : array<SItemUniqueId>;
		var STARTING_LEVEL : int;
		
		FactsAdd("StandAloneEP1", 1);
		
		//clear inventory
		inv.RemoveAllItems();
		
		//add required quest items
		inv.AddAnItem('Illusion Medallion', 1, true, true, false);
		inv.AddAnItem('q103_safe_conduct', 1, true, true, false);
		
		//remove all achievements
		theGame.GetGamerProfile().ClearAllAchievementsForEP1();
		
		//set level
		STARTING_LEVEL = 32;
		inc = STARTING_LEVEL - GetLevel();
		for(i=0; i<inc; i+=1)
		{
			levelManager.AddPoints(EExperiencePoint, levelManager.GetTotalExpForNextLevel() - levelManager.GetPointsTotal(EExperiencePoint), false);
		}
		
		//release all skillpoints
		levelManager.ResetCharacterDev();
		pam = (W3PlayerAbilityManager)abilityManager;
		if(pam)
		{
			pam.ResetCharacterDev();
		}
		levelManager.SetFreeSkillPoints(levelManager.GetLevel() - 1 + 11);	//+1 for q111 quest reward, +10 because balancing
		
		//mutagen ings
		inv.AddAnItem('Mutagen red', 4);
		inv.AddAnItem('Mutagen green', 4);
		inv.AddAnItem('Mutagen blue', 4);
		inv.AddAnItem('Lesser mutagen red', 2);
		inv.AddAnItem('Lesser mutagen green', 2);
		inv.AddAnItem('Lesser mutagen blue', 2);
		inv.AddAnItem('Greater mutagen green', 1);
		inv.AddAnItem('Greater mutagen blue', 2);
		
		//money
		startingMoney = 40000;
		if(GetMoney() > startingMoney)
		{
			RemoveMoney(GetMoney() - startingMoney);
		}
		else
		{
			AddMoney( 40000 - GetMoney() );
		}
		
		//armor
		/*
		inv.AddAnItem('Light armor 01r');
		inv.AddAnItem('Boots 04');
		inv.AddAnItem('Gloves 04');
		inv.AddAnItem('Pants 04');
		
		AddAnItemWithMinQuality('Medium armor 05r', 3, true);
		AddAnItemWithMinQuality('Boots 032', 3, true);
		AddAnItemWithMinQuality('Heavy gloves 02', 3, true);
		AddAnItemWithMinQuality('Pants 03', 3, true);
		
		inv.AddAnItem('Heavy armor 05r');
		inv.AddAnItem('Heavy boots 08');
		inv.AddAnItem('Heavy gloves 04');
		inv.AddAnItem('Heavy pants 04');
		
		//swords
		AddAnItemWithMinQuality('Gnomish sword 2', 3, true);
		AddAnItemWithMinQuality('Azurewrath', 3, true);
		*/
		
		//armor
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Armor');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Boots');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Gloves');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Pants');
		EquipItem(ids[0]);
		
		//swords
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Steel Sword');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('EP1 Standalone Starting Silver Sword');
		EquipItem(ids[0]);
		
		//torch
		inv.AddAnItem('Torch', 1, true, true, false);
		
		//crafting ingredients
		quantityLow = 1;
		randLow = 3;
		quantityMedium = 4;
		randMedium = 4;
		quantityHigh = 8;
		randHigh = 6;
		
		inv.AddAnItem('Alghoul bone marrow',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Amethyst dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas eyes',quantityLow+RandRange(randLow));
		inv.AddAnItem('Arachas venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Basilisk hide',quantityLow+RandRange(randLow));
		inv.AddAnItem('Basilisk venom',quantityLow+RandRange(randLow));
		inv.AddAnItem('Bear pelt',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Berserker pelt',quantityLow+RandRange(randLow));
		inv.AddAnItem('Coal',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Cotton',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Dark iron ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dark iron ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Deer hide',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Diamond dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Draconide leather',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowned dead tongue',quantityLow+RandRange(randLow));
		inv.AddAnItem('Drowner brain',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Dwimeryte ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Dwimeryte ore',quantityLow+RandRange(randLow));
		inv.AddAnItem('Emerald dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Endriag chitin plates',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Endriag embryo',quantityLow+RandRange(randLow));
		inv.AddAnItem('Ghoul blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Goat hide',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hag teeth',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened leather',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Hardened timber',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Harpy feathers',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Horse hide',quantityLow+RandRange(randLow));
		inv.AddAnItem('Iron ore',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Leather straps',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Leather',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Linen',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Meteorite ingot',quantityLow+RandRange(randLow));
		inv.AddAnItem('Meteorite ore',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Necrophage skin',quantityLow+RandRange(randLow));
		inv.AddAnItem('Nekker blood',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Nekker heart',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Oil',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Phosphorescent crystal',quantityLow+RandRange(randLow));
		inv.AddAnItem('Pig hide',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Pure silver',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rabbit pelt',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Rotfiend blood',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Sapphire dust',quantityLow+RandRange(randLow));
		inv.AddAnItem('Silk',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Silver ingot',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Silver ore',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Specter dust',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Steel ingot',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Steel plate',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('String',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Thread',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Timber',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Twine',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Venom extract',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Water essence',quantityMedium+RandRange(randMedium));
		inv.AddAnItem('Wolf liver',quantityHigh+RandRange(randHigh));
		inv.AddAnItem('Wolf pelt',quantityMedium+RandRange(randMedium));
		
		inv.AddAnItem('Alcohest', 5);
		inv.AddAnItem('Dwarven spirit', 5);
	
		//crossbow, bolts
		ids.Clear();
		ids = inv.AddAnItem('Crossbow 5');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Blunt Bolt', 100);
		EquipItem(ids[0]);
		inv.AddAnItem('Broadhead Bolt', 100);
		inv.AddAnItem('Split Bolt', 100);
		
		//remove recipes
		RemoveAllAlchemyRecipes();
		RemoveAllCraftingSchematics();
		
		//recipes - potions
		//AddAlchemyRecipe('Recipe for Black Blood 1');
		//AddAlchemyRecipe('Recipe for Blizzard 1');
		AddAlchemyRecipe('Recipe for Cat 1');
		//AddAlchemyRecipe('Recipe for Full Moon 1');
		//AddAlchemyRecipe('Recipe for Golden Oriole 1');
		//AddAlchemyRecipe('Recipe for Killer Whale 1');
		AddAlchemyRecipe('Recipe for Maribor Forest 1');
		AddAlchemyRecipe('Recipe for Petris Philtre 1');
		AddAlchemyRecipe('Recipe for Swallow 1');
		AddAlchemyRecipe('Recipe for Tawny Owl 1');
		//AddAlchemyRecipe('Recipe for Thunderbolt 1');
		AddAlchemyRecipe('Recipe for White Gull 1');
		AddAlchemyRecipe('Recipe for White Honey 1');
		AddAlchemyRecipe('Recipe for White Raffards Decoction 1');
		/*
		AddAlchemyRecipe('Recipe for Black Blood 2');
		AddAlchemyRecipe('Recipe for Blizzard 2');
		AddAlchemyRecipe('Recipe for Cat 2');
		AddAlchemyRecipe('Recipe for Full Moon 2');
		AddAlchemyRecipe('Recipe for Golden Oriole 2');
		AddAlchemyRecipe('Recipe for Killer Whale 2');
		AddAlchemyRecipe('Recipe for Maribor Forest 2');
		AddAlchemyRecipe('Recipe for Petris Philtre 2');
		AddAlchemyRecipe('Recipe for Swallow 2');
		AddAlchemyRecipe('Recipe for Tawny Owl 2');
		AddAlchemyRecipe('Recipe for Thunderbolt 2');
		AddAlchemyRecipe('Recipe for White Gull 2');
		AddAlchemyRecipe('Recipe for White Honey 2');
		AddAlchemyRecipe('Recipe for White Raffards Decoction 2');	
		*/
		
		//recipes - oils
		AddAlchemyRecipe('Recipe for Beast Oil 1');
		AddAlchemyRecipe('Recipe for Cursed Oil 1');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 1');
		AddAlchemyRecipe('Recipe for Hybrid Oil 1');
		AddAlchemyRecipe('Recipe for Insectoid Oil 1');
		AddAlchemyRecipe('Recipe for Magicals Oil 1');
		AddAlchemyRecipe('Recipe for Necrophage Oil 1');
		AddAlchemyRecipe('Recipe for Specter Oil 1');
		AddAlchemyRecipe('Recipe for Vampire Oil 1');
		AddAlchemyRecipe('Recipe for Draconide Oil 1');
		AddAlchemyRecipe('Recipe for Ogre Oil 1');
		AddAlchemyRecipe('Recipe for Relic Oil 1');
		AddAlchemyRecipe('Recipe for Beast Oil 2');
		AddAlchemyRecipe('Recipe for Cursed Oil 2');
		AddAlchemyRecipe('Recipe for Hanged Man Venom 2');
		AddAlchemyRecipe('Recipe for Hybrid Oil 2');
		AddAlchemyRecipe('Recipe for Insectoid Oil 2');
		AddAlchemyRecipe('Recipe for Magicals Oil 2');
		AddAlchemyRecipe('Recipe for Necrophage Oil 2');
		AddAlchemyRecipe('Recipe for Specter Oil 2');
		AddAlchemyRecipe('Recipe for Vampire Oil 2');
		AddAlchemyRecipe('Recipe for Draconide Oil 2');
		AddAlchemyRecipe('Recipe for Ogre Oil 2');
		AddAlchemyRecipe('Recipe for Relic Oil 2');
		
		//recipes - bombs
		AddAlchemyRecipe('Recipe for Dancing Star 1');
		//AddAlchemyRecipe('Recipe for Devils Puffball 1');
		AddAlchemyRecipe('Recipe for Dwimeritum Bomb 1');
		//AddAlchemyRecipe('Recipe for Dragons Dream 1');
		AddAlchemyRecipe('Recipe for Grapeshot 1');
		AddAlchemyRecipe('Recipe for Samum 1');
		//AddAlchemyRecipe('Recipe for Silver Dust Bomb 1');
		AddAlchemyRecipe('Recipe for White Frost 1');
		/*
		AddAlchemyRecipe('Recipe for Dancing Star 2');
		AddAlchemyRecipe('Recipe for Devils Puffball 2');
		AddAlchemyRecipe('Recipe for Dwimeritum Bomb 2');
		AddAlchemyRecipe('Recipe for Dragons Dream 2');
		AddAlchemyRecipe('Recipe for Grapeshot 2');
		AddAlchemyRecipe('Recipe for Samum 2');
		AddAlchemyRecipe('Recipe for Silver Dust Bomb 2');
		AddAlchemyRecipe('Recipe for White Frost 2');
		*/
		
		//recipes - alcohol
		AddAlchemyRecipe('Recipe for Dwarven spirit 1');
		AddAlchemyRecipe('Recipe for Alcohest 1');
		AddAlchemyRecipe('Recipe for White Gull 1');
		
		//crafting recipes
		AddStartingSchematics();
		
		//cooked alchemy items
		ids.Clear();
		ids = inv.AddAnItem('Swallow 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Thunderbolt 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Tawny Owl 2');
		EquipItem(ids[0]);
		ids.Clear();
		
		ids = inv.AddAnItem('Grapeshot 2');
		EquipItem(ids[0]);
		ids.Clear();
		ids = inv.AddAnItem('Samum 2');
		EquipItem(ids[0]);
		
		inv.AddAnItem('Dwimeritum Bomb 1');
		inv.AddAnItem('Dragons Dream 1');
		inv.AddAnItem('Silver Dust Bomb 1');
		inv.AddAnItem('White Frost 2');
		inv.AddAnItem('Devils Puffball 2');
		inv.AddAnItem('Dancing Star 2');
		inv.AddAnItem('Beast Oil 1');
		inv.AddAnItem('Cursed Oil 1');
		inv.AddAnItem('Hanged Man Venom 2');
		inv.AddAnItem('Hybrid Oil 1');
		inv.AddAnItem('Insectoid Oil 1');
		inv.AddAnItem('Magicals Oil 1');
		inv.AddAnItem('Necrophage Oil 2');
		inv.AddAnItem('Specter Oil 1');
		inv.AddAnItem('Vampire Oil 1');
		inv.AddAnItem('Draconide Oil 1');
		inv.AddAnItem('Relic Oil 1');
		inv.AddAnItem('Black Blood 1');
		inv.AddAnItem('Blizzard 1');
		inv.AddAnItem('Cat 2');
		inv.AddAnItem('Full Moon 1');
		inv.AddAnItem('Maribor Forest 1');
		inv.AddAnItem('Petris Philtre 1');
		inv.AddAnItem('White Gull 1', 3);
		inv.AddAnItem('White Honey 2');
		inv.AddAnItem('White Raffards Decoction 1');
		
		//mutagen decoctions
		inv.AddAnItem('Mutagen 17');	//forktail
		inv.AddAnItem('Mutagen 19');	//wraith
		inv.AddAnItem('Mutagen 27');	//griphon
		inv.AddAnItem('Mutagen 26');	//leshen
		
		//repair kits
		inv.AddAnItem('weapon_repair_kit_1', 5);
		inv.AddAnItem('weapon_repair_kit_2', 3);
		inv.AddAnItem('armor_repair_kit_1', 5);
		inv.AddAnItem('armor_repair_kit_2', 3);
		
		//runes
		quantityMedium = 2;
		quantityLow = 1;
		inv.AddAnItem('Rune stribog lesser', quantityMedium);
		inv.AddAnItem('Rune stribog', quantityLow);
		inv.AddAnItem('Rune dazhbog lesser', quantityMedium);
		inv.AddAnItem('Rune dazhbog', quantityLow);
		inv.AddAnItem('Rune devana lesser', quantityMedium);
		inv.AddAnItem('Rune devana', quantityLow);
		inv.AddAnItem('Rune zoria lesser', quantityMedium);
		inv.AddAnItem('Rune zoria', quantityLow);
		inv.AddAnItem('Rune morana lesser', quantityMedium);
		inv.AddAnItem('Rune morana', quantityLow);
		inv.AddAnItem('Rune triglav lesser', quantityMedium);
		inv.AddAnItem('Rune triglav', quantityLow);
		inv.AddAnItem('Rune svarog lesser', quantityMedium);
		inv.AddAnItem('Rune svarog', quantityLow);
		inv.AddAnItem('Rune veles lesser', quantityMedium);
		inv.AddAnItem('Rune veles', quantityLow);
		inv.AddAnItem('Rune perun lesser', quantityMedium);
		inv.AddAnItem('Rune perun', quantityLow);
		inv.AddAnItem('Rune elemental lesser', quantityMedium);
		inv.AddAnItem('Rune elemental', quantityLow);
		
		inv.AddAnItem('Glyph aard lesser', quantityMedium);
		inv.AddAnItem('Glyph aard', quantityLow);
		inv.AddAnItem('Glyph axii lesser', quantityMedium);
		inv.AddAnItem('Glyph axii', quantityLow);
		inv.AddAnItem('Glyph igni lesser', quantityMedium);
		inv.AddAnItem('Glyph igni', quantityLow);
		inv.AddAnItem('Glyph quen lesser', quantityMedium);
		inv.AddAnItem('Glyph quen', quantityLow);
		inv.AddAnItem('Glyph yrden lesser', quantityMedium);
		inv.AddAnItem('Glyph yrden', quantityLow);
		
		//memory exhaust error
		StandaloneEp1_2();
	}
	
	public final function StandaloneEp1_2()
	{
		var horseId : SItemUniqueId;
		var ids : array<SItemUniqueId>;
		var ents : array< CJournalBase >;
		var i : int;
		var manager : CWitcherJournalManager;
		
		//food
		inv.AddAnItem( 'Cows milk', 20 );
		ids.Clear();
		ids = inv.AddAnItem( 'Dumpling', 44 );
		EquipItem(ids[0]);
		
		//clearing potion
		inv.AddAnItem('Clearing Potion', 2, true, false, false);
		
		//horse gear
		GetHorseManager().RemoveAllItems();
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Bag 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Blinder 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		ids.Clear();
		ids = inv.AddAnItem('Horse Saddle 2');
		horseId = GetHorseManager().MoveItemToHorse(ids[0]);
		GetHorseManager().EquipItem(horseId);
		
		manager = theGame.GetJournalManager();

		//delete journal entries - bestiary
		manager.GetActivatedOfType( 'CJournalCreature', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		//delete journal entries - characters
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalCharacter', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		//delete journal entries - quest
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalQuest', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			//don't disable EP1 quest
			if( StrStartsWith(ents[i].baseName, "q60"))
				continue;
				
			manager.ActivateEntry(ents[i], JS_Inactive, false, true);
		}
		
		//tutorial entries activate		
		manager.ActivateEntryByScriptTag('TutorialAard', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAdrenaline', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAxii', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialAxiiDialog', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCamera', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCamera_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriBlink', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriCharge', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCiriStamina', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialCounter', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialDialogClose', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFallingRoll', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocus', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialFocusClues', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseRoad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed0', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed0_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed1', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSpeed2', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSummon', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialHorseSummon_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialIgni', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalAlternateSings', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBoatDamage', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBoatMount', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalBuffs', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCharDevLeveling', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCharDevSkills', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCrafting', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalCrossbow', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDialogGwint', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDialogShop', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDive', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDodge', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDodge_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDrawWeapon_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalDurability', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalExplorations', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalExplorations_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalFastTravel', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalFocusRedObjects', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalGasClouds', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHeavyAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHorse', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalHorseStamina', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalJump', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalLightAttacks_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMeditation', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMeditation_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMonsterThreatLevels', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMovement', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMovement_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMutagenIngredient', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalMutagenPotion', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalOils', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPetards', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPotions', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalPotions_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalQuestArea', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRadial', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRifts', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalRun', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalShopDescription', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSignCast', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSignCast_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalSpecialAttacks', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJournalStaminaExploration', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialJumpHang', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadder', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadderMove', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialLadderMove_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialObjectiveSwitching', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialOxygen', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialParry', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialPOIUncovered', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialQuen', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialRoll', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialRoll_pad', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSpeedPairing', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSprint', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialStaminaSigns', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialStealing', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialSwimmingSpeed', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialTimedChoiceDialog', JS_Active);
		manager.ActivateEntryByScriptTag('TutorialYrden', JS_Active);
		
		//disable quest blocks with tutorials
		FactsAdd('kill_base_tutorials');
		
		//disable already queued tutorials
		theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
		
		//enable start of standalone mode tutorial
		FactsAdd('standalone_ep1');
		FactsRemove("StandAloneEP1");
		
		theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
	}
	
	final function Debug_FocusBoyFocusGain()
	{
		var focusGain : float;
		
		focusGain = FactsQuerySum( "debug_fact_focus_boy" ) ;
		GainStat( BCS_Focus, focusGain );
	}
	
	public final function StandaloneEp2_1()
	{
		var i, inc, quantityLow, randLow, quantityMedium, randMedium, quantityHigh, randHigh, startingMoney : int;
		var pam : W3PlayerAbilityManager;
		var ids : array<SItemUniqueId>;
		var STARTING_LEVEL : int;
		
		FactsAdd( "StandAloneEP2", 1 );
		
		//clear inventory
		inv.RemoveAllItems();
		
		//add required quest items
		inv.AddAnItem( 'Illusion Medallion', 1, true, true, false );
		inv.AddAnItem( 'q103_safe_conduct', 1, true, true, false );
		
		//remove all achievements
		theGame.GetGamerProfile().ClearAllAchievementsForEP2();
		
		//set level
		levelManager.Hack_EP2StandaloneLevelShrink( 35 );
		
		//release all skillpoints
		levelManager.ResetCharacterDev();
		pam = ( W3PlayerAbilityManager )abilityManager;
		if( pam )
		{
			pam.ResetCharacterDev();
		}
		levelManager.SetFreeSkillPoints( levelManager.GetLevel() - 1 + 11 );	//+1 for q111 quest reward, +10 because balancing
		
		//mutagen ings
		inv.AddAnItem( 'Mutagen red', 4 );
		inv.AddAnItem( 'Mutagen green', 4 );
		inv.AddAnItem( 'Mutagen blue', 4 );
		inv.AddAnItem( 'Lesser mutagen red', 2 );
		inv.AddAnItem( 'Lesser mutagen green', 2 );
		inv.AddAnItem( 'Lesser mutagen blue', 2 );
		inv.AddAnItem( 'Greater mutagen red', 2 );
		inv.AddAnItem( 'Greater mutagen green', 2 );
		inv.AddAnItem( 'Greater mutagen blue', 2 );
		
		//money
		startingMoney = 20000;
		if( GetMoney() > startingMoney )
		{
			RemoveMoney( GetMoney() - startingMoney );
		}
		else
		{
			AddMoney( 20000 - GetMoney() );
		}
		
		//armor
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Armor' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Boots' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Gloves' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Pants' );
		EquipItem( ids[0] );
		
		//swords
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Steel Sword' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'EP2 Standalone Starting Silver Sword' );
		EquipItem( ids[0] );
		
		//torch
		inv.AddAnItem( 'Torch', 1, true, true, false );
		
		//crafting ingredients
		quantityLow = 1;
		randLow = 3;
		quantityMedium = 4;
		randMedium = 4;
		quantityHigh = 8;
		randHigh = 6;
		
		inv.AddAnItem( 'Alghoul bone marrow',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Amethyst dust',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Arachas eyes',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Arachas venom',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Basilisk hide',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Basilisk venom',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Bear pelt',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Berserker pelt',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Coal',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Cotton',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Dark iron ingot',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Dark iron ore',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Deer hide',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Diamond dust',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Draconide leather',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Drowned dead tongue',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Drowner brain',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Dwimeryte ingot',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Dwimeryte ore',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Emerald dust',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Endriag chitin plates',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Endriag embryo',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Ghoul blood',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Goat hide',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Hag teeth',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Hardened leather',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Hardened timber',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Harpy feathers',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Horse hide',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Iron ore',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Leather straps',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Leather',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Linen',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Meteorite ingot',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Meteorite ore',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Necrophage skin',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Nekker blood',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Nekker heart',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Oil',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Phosphorescent crystal',quantityLow+RandRange( randLow ) );
		inv.AddAnItem( 'Pig hide',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Pure silver',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Rabbit pelt',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Rotfiend blood',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Sapphire dust',quantityLow+RandRange( randLow ) );
//		inv.AddAnItem( 'Silk',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Silver ingot',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Silver ore',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Specter dust',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Steel ingot',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Steel plate',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'String',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Thread',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Timber',quantityHigh+RandRange( randHigh ) );
//		inv.AddAnItem( 'Twine',quantityMedium+RandRange( randMedium ) );
//		inv.AddAnItem( 'Venom extract',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Water essence',quantityMedium+RandRange( randMedium ) );
		inv.AddAnItem( 'Wolf liver',quantityHigh+RandRange( randHigh ) );
		inv.AddAnItem( 'Wolf pelt',quantityMedium+RandRange( randMedium ) );
		
		inv.AddAnItem( 'Alcohest', 5 );
		inv.AddAnItem( 'Dwarven spirit', 5 );
	
		//crossbow, bolts
		ids.Clear();
		ids = inv.AddAnItem( 'Crossbow 5' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Blunt Bolt', 100 );
		EquipItem( ids[0] );
		inv.AddAnItem( 'Broadhead Bolt', 100 );
		inv.AddAnItem( 'Split Bolt', 100 );
		
		//remove recipes
		RemoveAllAlchemyRecipes();
		RemoveAllCraftingSchematics();
		
		//recipes - potions
		//AddAlchemyRecipe( 'Recipe for Black Blood 1' );
		//AddAlchemyRecipe( 'Recipe for Blizzard 1' );
		//AddAlchemyRecipe( 'Recipe for Cat 1' );
		//AddAlchemyRecipe( 'Recipe for Full Moon 1' );
		//AddAlchemyRecipe( 'Recipe for Golden Oriole 1' );
		//AddAlchemyRecipe( 'Recipe for Killer Whale 1' );
		//AddAlchemyRecipe( 'Recipe for Maribor Forest 1' );
		AddAlchemyRecipe( 'Recipe for Petris Philtre 2' );
		AddAlchemyRecipe( 'Recipe for Swallow 1' );
		AddAlchemyRecipe( 'Recipe for Tawny Owl 1' );
		//AddAlchemyRecipe( 'Recipe for Thunderbolt 1' );
		AddAlchemyRecipe( 'Recipe for White Gull 1' );
		//AddAlchemyRecipe( 'Recipe for White Honey 1' );
		//AddAlchemyRecipe( 'Recipe for White Raffards Decoction 1' );
		/*
		AddAlchemyRecipe( 'Recipe for Black Blood 2' );
		AddAlchemyRecipe( 'Recipe for Blizzard 2' );
		AddAlchemyRecipe( 'Recipe for Cat 2' );
		AddAlchemyRecipe( 'Recipe for Full Moon 2' );
		AddAlchemyRecipe( 'Recipe for Golden Oriole 2' );
		AddAlchemyRecipe( 'Recipe for Killer Whale 2' );
		AddAlchemyRecipe( 'Recipe for Maribor Forest 2' );
		AddAlchemyRecipe( 'Recipe for Petris Philtre 2' );
		AddAlchemyRecipe( 'Recipe for Swallow 2' );
		AddAlchemyRecipe( 'Recipe for Tawny Owl 2' );
		AddAlchemyRecipe( 'Recipe for Thunderbolt 2' );
		AddAlchemyRecipe( 'Recipe for White Gull 2' );
		AddAlchemyRecipe( 'Recipe for White Honey 2' );
		AddAlchemyRecipe( 'Recipe for White Raffards Decoction 2' );	
		*/
		
		//recipes - oils
		AddAlchemyRecipe( 'Recipe for Beast Oil 1' );
		AddAlchemyRecipe( 'Recipe for Cursed Oil 1' );
		AddAlchemyRecipe( 'Recipe for Hanged Man Venom 1' );
		AddAlchemyRecipe( 'Recipe for Hybrid Oil 1' );
		AddAlchemyRecipe( 'Recipe for Insectoid Oil 2' );
		AddAlchemyRecipe( 'Recipe for Magicals Oil 1' );
		AddAlchemyRecipe( 'Recipe for Necrophage Oil 1' );
		AddAlchemyRecipe( 'Recipe for Specter Oil 1' );
		AddAlchemyRecipe( 'Recipe for Vampire Oil 2' );
		AddAlchemyRecipe( 'Recipe for Draconide Oil 2' );
		AddAlchemyRecipe( 'Recipe for Ogre Oil 1' );
		AddAlchemyRecipe( 'Recipe for Relic Oil 1' );
		AddAlchemyRecipe( 'Recipe for Beast Oil 2' );
		AddAlchemyRecipe( 'Recipe for Cursed Oil 2' );
		AddAlchemyRecipe( 'Recipe for Hanged Man Venom 2' );
		AddAlchemyRecipe( 'Recipe for Hybrid Oil 2' );
		AddAlchemyRecipe( 'Recipe for Insectoid Oil 2' );
		AddAlchemyRecipe( 'Recipe for Magicals Oil 2' );
		AddAlchemyRecipe( 'Recipe for Necrophage Oil 2' );
		AddAlchemyRecipe( 'Recipe for Specter Oil 2' );
		AddAlchemyRecipe( 'Recipe for Vampire Oil 2' );
		AddAlchemyRecipe( 'Recipe for Draconide Oil 2' );
		AddAlchemyRecipe( 'Recipe for Ogre Oil 2' );
		AddAlchemyRecipe( 'Recipe for Relic Oil 2' );
		
		//recipes - bombs
		AddAlchemyRecipe( 'Recipe for Dancing Star 1' );
		//AddAlchemyRecipe( 'Recipe for Devils Puffball 1' );
		AddAlchemyRecipe( 'Recipe for Dwimeritum Bomb 1' );
		//AddAlchemyRecipe( 'Recipe for Dragons Dream 1' );
		AddAlchemyRecipe( 'Recipe for Grapeshot 1' );
		AddAlchemyRecipe( 'Recipe for Samum 1' );
		//AddAlchemyRecipe( 'Recipe for Silver Dust Bomb 1' );
		AddAlchemyRecipe( 'Recipe for White Frost 1' );
		/*
		AddAlchemyRecipe( 'Recipe for Dancing Star 2' );
		AddAlchemyRecipe( 'Recipe for Devils Puffball 2' );
		AddAlchemyRecipe( 'Recipe for Dwimeritum Bomb 2' );
		AddAlchemyRecipe( 'Recipe for Dragons Dream 2' );
		AddAlchemyRecipe( 'Recipe for Grapeshot 2' );
		AddAlchemyRecipe( 'Recipe for Samum 2' );
		AddAlchemyRecipe( 'Recipe for Silver Dust Bomb 2' );
		AddAlchemyRecipe( 'Recipe for White Frost 2' );
		*/
		
		//recipes - alcohol
		AddAlchemyRecipe( 'Recipe for Dwarven spirit 1' );
		AddAlchemyRecipe( 'Recipe for Alcohest 1' );
		AddAlchemyRecipe( 'Recipe for White Gull 1' );
		
		//crafting recipes
		AddStartingSchematics();
		
		//cooked alchemy items
		ids.Clear();
		ids = inv.AddAnItem( 'Swallow 2' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Thunderbolt 2' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Tawny Owl 2' );
		EquipItem( ids[0] );
		ids.Clear();
		
		ids = inv.AddAnItem( 'Grapeshot 2' );
		EquipItem( ids[0] );
		ids.Clear();
		ids = inv.AddAnItem( 'Samum 2' );
		EquipItem( ids[0] );
		
		inv.AddAnItem( 'Dwimeritum Bomb 1' );
		inv.AddAnItem( 'Dragons Dream 1' );
		inv.AddAnItem( 'Silver Dust Bomb 1' );
		inv.AddAnItem( 'White Frost 2' );
		inv.AddAnItem( 'Devils Puffball 2' );
		inv.AddAnItem( 'Dancing Star 2' );
		inv.AddAnItem( 'Beast Oil 1' );
		inv.AddAnItem( 'Cursed Oil 1' );
		inv.AddAnItem( 'Hanged Man Venom 2' );
		inv.AddAnItem( 'Hybrid Oil 2' );
		inv.AddAnItem( 'Insectoid Oil 2' );
		inv.AddAnItem( 'Magicals Oil 1' );
		inv.AddAnItem( 'Necrophage Oil 2' );
		inv.AddAnItem( 'Ogre Oil 1' );
		inv.AddAnItem( 'Specter Oil 1' );
		inv.AddAnItem( 'Vampire Oil 2' );
		inv.AddAnItem( 'Draconide Oil 2' );
		inv.AddAnItem( 'Relic Oil 1' );
		inv.AddAnItem( 'Black Blood 1' );
		inv.AddAnItem( 'Blizzard 1' );
		inv.AddAnItem( 'Cat 2' );
		inv.AddAnItem( 'Full Moon 1' );
		inv.AddAnItem( 'Golden Oriole 1' );
		inv.AddAnItem( 'Killer Whale 1' );
		inv.AddAnItem( 'Maribor Forest 1' );
		inv.AddAnItem( 'Petris Philtre 2' );
		inv.AddAnItem( 'White Gull 1', 3 );
		inv.AddAnItem( 'White Honey 2' );
		inv.AddAnItem( 'White Raffards Decoction 1' );
		
		//mutagen decoctions
		inv.AddAnItem( 'Mutagen 17' );	//forktail
		inv.AddAnItem( 'Mutagen 19' );	//wraith
		inv.AddAnItem( 'Mutagen 27' );	//griphon
		inv.AddAnItem( 'Mutagen 26' );	//leshen
		
		//repair kits
		inv.AddAnItem( 'weapon_repair_kit_1', 5 );
		inv.AddAnItem( 'weapon_repair_kit_2', 3 );
		inv.AddAnItem( 'armor_repair_kit_1', 5 );
		inv.AddAnItem( 'armor_repair_kit_2', 3 );
		
		//runes
		quantityMedium = 2;
		quantityLow = 1;
		inv.AddAnItem( 'Rune stribog lesser', quantityMedium );
		inv.AddAnItem( 'Rune stribog', quantityLow );
		inv.AddAnItem( 'Rune dazhbog lesser', quantityMedium );
		inv.AddAnItem( 'Rune dazhbog', quantityLow );
		inv.AddAnItem( 'Rune devana lesser', quantityMedium );
		inv.AddAnItem( 'Rune devana', quantityLow );
		inv.AddAnItem( 'Rune zoria lesser', quantityMedium );
		inv.AddAnItem( 'Rune zoria', quantityLow );
		inv.AddAnItem( 'Rune morana lesser', quantityMedium );
		inv.AddAnItem( 'Rune morana', quantityLow );
		inv.AddAnItem( 'Rune triglav lesser', quantityMedium );
		inv.AddAnItem( 'Rune triglav', quantityLow );
		inv.AddAnItem( 'Rune svarog lesser', quantityMedium );
		inv.AddAnItem( 'Rune svarog', quantityLow );
		inv.AddAnItem( 'Rune veles lesser', quantityMedium );
		inv.AddAnItem( 'Rune veles', quantityLow );
		inv.AddAnItem( 'Rune perun lesser', quantityMedium );
		inv.AddAnItem( 'Rune perun', quantityLow );
		inv.AddAnItem( 'Rune elemental lesser', quantityMedium );
		inv.AddAnItem( 'Rune elemental', quantityLow );
		
		inv.AddAnItem( 'Glyph aard lesser', quantityMedium );
		inv.AddAnItem( 'Glyph aard', quantityLow );
		inv.AddAnItem( 'Glyph axii lesser', quantityMedium );
		inv.AddAnItem( 'Glyph axii', quantityLow );
		inv.AddAnItem( 'Glyph igni lesser', quantityMedium );
		inv.AddAnItem( 'Glyph igni', quantityLow );
		inv.AddAnItem( 'Glyph quen lesser', quantityMedium );
		inv.AddAnItem( 'Glyph quen', quantityLow );
		inv.AddAnItem( 'Glyph yrden lesser', quantityMedium );
		inv.AddAnItem( 'Glyph yrden', quantityLow );
		
		//memory exhaust error
		StandaloneEp2_2();
	}
	
	public final function StandaloneEp2_2()
	{
		var horseId : SItemUniqueId;
		var ids : array<SItemUniqueId>;
		var ents : array< CJournalBase >;
		var i : int;
		var manager : CWitcherJournalManager;
		
		//food
		inv.AddAnItem( 'Cows milk', 20 );
		ids.Clear();
		ids = inv.AddAnItem( 'Dumpling', 44 );
		EquipItem( ids[0] );
		
		//clearing potion
		inv.AddAnItem( 'Clearing Potion', 2, true, false, false );
		
		//horse gear
		GetHorseManager().RemoveAllItems();
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Bag 2' );
		horseId = GetHorseManager( ).MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Blinder 2' );
		horseId = GetHorseManager().MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		ids.Clear();
		ids = inv.AddAnItem( 'Horse Saddle 2' );
		horseId = GetHorseManager().MoveItemToHorse( ids[0] );
		GetHorseManager().EquipItem( horseId );
		
		manager = theGame.GetJournalManager();

		//delete journal entries - bestiary
		manager.GetActivatedOfType( 'CJournalCreature', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		//delete journal entries - characters
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalCharacter', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		//delete journal entries - quest
		ents.Clear();
		manager.GetActivatedOfType( 'CJournalQuest', ents );
		for(i=0; i<ents.Size(); i+=1)
		{
			//don't disable EP1 quest
			if( StrStartsWith( ents[i].baseName, "q60" ) )
				continue;
				
			manager.ActivateEntry( ents[i], JS_Inactive, false, true );
		}
		
		//tutorial entries activate		
		manager.ActivateEntryByScriptTag( 'TutorialAard', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAdrenaline', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAxii', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialAxiiDialog', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCamera', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCamera_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriBlink', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriCharge', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCiriStamina', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialCounter', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialDialogClose', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFallingRoll', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocus', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialFocusClues', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseRoad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed0_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed1', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSpeed2', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSummon', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialHorseSummon_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialIgni', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalAlternateSings', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBoatDamage', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBoatMount', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalBuffs', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevLeveling', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCharDevSkills', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCrafting', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalCrossbow', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDialogGwint', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDialogShop', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDive', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDodge', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDodge_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDrawWeapon_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalDurability', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalExplorations_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalFastTravel', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalFocusRedObjects', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalGasClouds', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHeavyAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHorse', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalHorseStamina', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalJump', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalLightAttacks_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMeditation_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMonsterThreatLevels', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMovement', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMovement_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenIngredient', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalMutagenPotion', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalOils', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPetards', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPotions', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalPotions_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalQuestArea', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRadial', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRifts', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalRun', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalShopDescription', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSignCast_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalSpecialAttacks', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJournalStaminaExploration', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialJumpHang', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadder', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadderMove', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialLadderMove_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialObjectiveSwitching', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialOxygen', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialParry', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialPOIUncovered', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialQuen', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialRoll', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialRoll_pad', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSpeedPairing', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSprint', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialStaminaSigns', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialStealing', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialSwimmingSpeed', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialTimedChoiceDialog', JS_Active );
		manager.ActivateEntryByScriptTag( 'TutorialYrden', JS_Active );
		
		inv.AddAnItem( 'Geralt Shirt', 1 );
		inv.AddAnItem( 'Thread', 13 );
		inv.AddAnItem( 'String', 9 );
		inv.AddAnItem( 'Linen', 4 );
		inv.AddAnItem( 'Silk', 6 );
		inv.AddAnItem( 'Nigredo', 3 );
		inv.AddAnItem( 'Albedo', 1 );
		inv.AddAnItem( 'Rubedo', 1 );
		inv.AddAnItem( 'Rebis', 1 );
		inv.AddAnItem( 'Dog tallow', 4 );
		inv.AddAnItem( 'Lunar shards', 3 );
		inv.AddAnItem( 'Quicksilver solution', 5 );
		inv.AddAnItem( 'Aether', 1 );
		inv.AddAnItem( 'Optima mater', 3 );
		inv.AddAnItem( 'Fifth essence', 2 );
		inv.AddAnItem( 'Hardened timber', 6 );
		inv.AddAnItem( 'Fur square', 1 );
		inv.AddAnItem( 'Leather straps', 11 ); //  23 );
		inv.AddAnItem( 'Leather squares', 6 ); // 16 );
		inv.AddAnItem( 'Leather', 3 ); // 7 ); 
		inv.AddAnItem( 'Hardened leather', 14 ); // 18 );
		inv.AddAnItem( 'Chitin scale', 8 ); // 9 );
		inv.AddAnItem( 'Draconide leather', 5 ); // 9 );
		inv.AddAnItem( 'Infused draconide leather', 0 );
		inv.AddAnItem( 'Steel ingot', 5 );
		inv.AddAnItem( 'Dark iron ore', 2 );
		inv.AddAnItem( 'Dark iron ingot', 3 );
		inv.AddAnItem( 'Dark iron plate', 1 );
		inv.AddAnItem( 'Dark steel ingot', 10 );
		inv.AddAnItem( 'Dark steel plate', 6 );
		inv.AddAnItem( 'Silver ore', 2 );
		inv.AddAnItem( 'Silver ingot', 6 );
		inv.AddAnItem( 'Meteorite ore', 3 );
		inv.AddAnItem( 'Meteorite ingot', 3 );
		inv.AddAnItem( 'Meteorite plate', 2 );
		inv.AddAnItem( 'Meteorite silver ingot', 6 );
		inv.AddAnItem( 'Meteorite silver plate', 5 );
		inv.AddAnItem( 'Orichalcum ingot', 0 );
		inv.AddAnItem( 'Orichalcum plate', 1 );
		inv.AddAnItem( 'Dwimeryte ingot', 6 );
		inv.AddAnItem( 'Dwimeryte plate', 5 );
		inv.AddAnItem( 'Dwimeryte enriched ingot', 0 );
		inv.AddAnItem( 'Dwimeryte enriched plate', 0 );
		inv.AddAnItem( 'Emerald dust', 0 );
		inv.AddAnItem( 'Ruby dust', 4 );
		inv.AddAnItem( 'Ruby', 2 );
		inv.AddAnItem( 'Ruby flawless', 1 );
		inv.AddAnItem( 'Sapphire dust', 0 );
		inv.AddAnItem( 'Sapphire', 0 );
		inv.AddAnItem( 'Monstrous brain', 8 );
		inv.AddAnItem( 'Monstrous blood', 14 );
		inv.AddAnItem( 'Monstrous bone', 9 );
		inv.AddAnItem( 'Monstrous claw', 14 );
		inv.AddAnItem( 'Monstrous dust', 9 );
		inv.AddAnItem( 'Monstrous ear', 5 );
		inv.AddAnItem( 'Monstrous egg', 1 );
		inv.AddAnItem( 'Monstrous eye', 10 );
		inv.AddAnItem( 'Monstrous essence', 7 );
		inv.AddAnItem( 'Monstrous feather', 8 );
		inv.AddAnItem( 'Monstrous hair', 12 );
		inv.AddAnItem( 'Monstrous heart', 7 );
		inv.AddAnItem( 'Monstrous hide', 4 );
		inv.AddAnItem( 'Monstrous liver', 5 );
		inv.AddAnItem( 'Monstrous plate', 1 );
		inv.AddAnItem( 'Monstrous saliva', 6 );
		inv.AddAnItem( 'Monstrous stomach', 3 );
		inv.AddAnItem( 'Monstrous tongue', 5 );
		inv.AddAnItem( 'Monstrous tooth', 9 );
		inv.AddAnItem( 'Venom extract', 0 );
		inv.AddAnItem( 'Siren vocal cords', 1 );
		
		//select crossbow
		SelectQuickslotItem( EES_RangedWeapon );
		
		//disable quest blocks with tutorials
		FactsAdd( 'kill_base_tutorials' );
		
		//disable already queued tutorials
		theGame.GetTutorialSystem().RemoveAllQueuedTutorials();
		
		//enable start of standalone mode tutorial
		FactsAdd( 'standalone_ep2' );
		FactsRemove( "StandAloneEP2" );
		
		theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
	}
}

exec function fuqfep1()
{
	theGame.GetJournalManager().ForceUntrackingQuestForEP1Savegame();
}

///////////////////////////////////////////////////////////////////////
// HACKS! DO NOT USE THIS!!! IF IT IS REAAALY NEEDED ASK BEFORE USING!!!! - MAREK
///////////////////////////////////////////////////////////////////////

function GetWitcherPlayer() : W3PlayerWitcher
{
	return (W3PlayerWitcher)thePlayer;
}
