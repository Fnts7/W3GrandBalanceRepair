/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Tomek Kozera
/***********************************************************************/

/*
	Action for weapon / physical attacks such as sword slashes, throwing daggers etc.
*/
class W3Action_Attack extends W3DamageAction
{
	private var weaponId : SItemUniqueId; 			//id of the weapon used
	private var crossbowId : SItemUniqueId;			//if weapon is a bolt then we also need id of crossbow
	private var attackName : name;					//attack name - set in animations and loaded from XML to provide special parameters (e.g. slash, pierce)
	private var attackTypeName : name;				//name of the attack type used with this attack (e.g. attack_light or StrongAttackOverpower)
	private var isAttackReflected : bool;			//set to true if the attack was reflected - attacker plays a reflect reaction
	private var isParried : bool;					//set to true if the attack was parried
	private var isCountered : bool;					//set to true if the attack was countered
	private var attackAnimName : name;				//name of the attack animation - used for dismemberment
	private var hitTime : float;					//time of hit - used for dismemberment
	private var weaponEntity : CItemEntity;			//item entity - used for dismemberment	
	private var weaponSlot : name;					//name of the slot from which attacker used a weapon to deal this damage action
	private var boneIndex : int;					//hit bone index
	private var soundAttackType : name;				//attack type for sound setup	
	private var usedZeroStaminaPerk : bool;			//set to true if attack triggered S_Perk_16 (will drain victim's stamina to 0)
	private var applyBuffsIfParried : bool;			//buffs will be applied even if action was parried
		
	/*
		We can have several types of attack names e.g. slash, pierce, overhead while at the same time all of those attacks being considered light attacks.
		In such case the attackName will have the precise attack name (slash) while attackTypeName will have it's general type (attack_light).
	*/
	
	//Needs to override base function with new parameter list so it has to have a different name
	public function Init( attackr : CGameplayEntity, victm : CGameplayEntity, causr : IScriptable, weapId : SItemUniqueId, attName : name, src :string, hrt : EHitReactionType, canParry : bool, canDodge : bool, skillName : name, swType : EAttackSwingType, swDir : EAttackSwingDirection, isM : bool, isR : bool, isW : bool, isE : bool, optional hitFX_ : name, optional hitBackFX_ : name, optional hitParriedFX_ : name, optional hitBackParriedFX_ : name, optional crossId : SItemUniqueId)
	{		
		var player : CR4Player;
		var powerStat : ECharacterPowerStats;
	
		if(attName == '' || !attackr)
		{
			LogAssert(false, "W3Action_Attack.Init: missing attack data - debug (attack name OR attacker)!");
			return;
		}
		
		//set power stat based on attack type
		if(theGame.GetDefinitionsManager().AbilityHasTag(attName, 'UsesSpellPower'))
			powerStat = CPS_SpellPower;
		else
			powerStat = CPS_AttackPower;
		
		//super
		super.Initialize( attackr, victm, causr, src, hrt, powerStat, isM, isR, isW, isE, hitFX_, hitBackFX_, hitParriedFX_, hitBackParriedFX_);
		
		swingType = swType;
		swingDirection = swDir;
		attackName = attName;
		weaponId = weapId;
		crossbowId = crossId;
		canBeParried = canParry && !attackr.HasAbility( 'UnblockableAttacks' );
		canBeDodged = canDodge;
		soundAttackType = 'empty';
		boneIndex = -1;	//not set
		
		player = (CR4Player)attacker;
		if(IsBasicAttack(skillName) || (player && player.CanUseSkill(SkillNameToEnum(skillName))) )
			attackTypeName = skillName;
		else
			attackTypeName = '';
		
		FillDataFromWeapon();
		FillDataFromAttackName();		
	}
	
	protected function Clear()
	{
		weaponId = GetInvalidUniqueId();
		crossbowId = GetInvalidUniqueId();
		attackName = '';
		attackTypeName = '';
		isAttackReflected = false;
		isParried = false;
		isCountered = false;
		attackAnimName = '';
		hitTime = 0;
		weaponSlot = '';
		soundAttackType = 'empty';
		boneIndex = -1;
		forceExplosionDismemberment = false;
		weaponEntity = NULL;		
	}
	
	//override parent so that noone makes an AttackAction and then initializes it using super's constructor without passing required data
	public function Initialize( att : CGameplayEntity, vict : CGameplayEntity, caus : IScriptable, src : string, hrt : EHitReactionType, pwrStatType : ECharacterPowerStats, isM : bool, isR : bool, isW : bool, isE : bool, optional hitFX_ : name, optional hitBackFX_ : name, optional hitParriedFX_ : name, optional hitBackParriedFX_ : name)
	{
		LogAssert(false, "W3Action_Attack.Initialize: my friend... you are using wrong constructor :P - use Init()");
	}
	
	// Fills action data from used weapon
	private function FillDataFromWeapon()
	{
		var inv : CInventoryComponent;
		var i, size : int;
		var dmgTypes : array< name >;
		var buffs : array<SEffectInfo>;
		var actorAttacker : CActor;
		
		inv = attacker.GetInventory();
		
		actorAttacker = ( CActor ) attacker;
		if ( actorAttacker )
		{
			size = inv.GetWeaponDTNames(weaponId, dmgTypes);	
			for( i = 0; i < size; i += 1 )
				AddDamage( dmgTypes[i], actorAttacker.GetTotalWeaponDamage(weaponId, dmgTypes[i], crossbowId) );
		
			size = inv.GetItemBuffs(weaponId, buffs);
			for( i = 0; i < size; i += 1 )
				AddEffectInfo(buffs[i].effectType, , , buffs[i].effectAbilityName, ,buffs[i].applyChance);
				
			if( theGame.CanLog() && dmgTypes.Size() == 0 && buffs.Size() == 0 )
			{
				LogDMHits( "Weapon " + inv.GetItemName( weaponId ) + " has no damage and no buff stats defined - it will do nothing!" );
			}
		}
	}
	
	// Gets attack data from xml. The attributes can be damage, effects, basic attack damage or junk :P
	private function FillDataFromAttackName()
	{
		var attributes, abilities : array<name>;
		var i, size : int;
		var dm : CDefinitionsManagerAccessor;
		var dmgVal : float;
		var dmgAttributeName, abilityName : name;
		var type : EEffectType;
		var min, max : SAbilityAttributeValue;
		var actorAttacker : CActor;	

		actorAttacker = ( CActor ) attacker;
		
		dm = theGame.GetDefinitionsManager();		
		
		//if basic attack we need to get damage from monster 'con' ability 	
		if(actorAttacker && IsBasicAttack(attackName))
		{
			for (i=0; i<dmgInfos.Size(); i+=1)
			{
				// add damge based on the attack type used
				dmgAttributeName = GetBasicAttackDamageAttributeName(attackName, dmgInfos[i].dmgType);		
				dmgVal = CalculateAttributeValue(actorAttacker.GetAttributeValue(dmgAttributeName));
				
				if(dmgVal > 0)
					AddDamage(dmgInfos[i].dmgType, dmgVal);

				//dmgAttributeName = GetBasicAttackDamageAttributeName(attackName, theGame.params.DAMAGE_NAME_SILVER);
				//dmgVal = CalculateAttributeValue(actorAttacker.GetAttributeValue(dmgAttributeName));
				//if(dmgVal > 0)
				//	AddDamage(theGame.params.DAMAGE_NAME_SILVER, dmgVal);
			}
		}
				
		//common part - additional dmg and effects
		dm.GetContainedAbilities(attackName, abilities);
		size = abilities.Size();
		for( i = 0; i < size; i += 1 )
		{
			//effect
			if( IsEffectNameValid(abilities[i]) )
			{
				EffectNameToType(abilities[i], type, abilityName);
				AddEffectInfo(type, , , abilityName);
			}
		}
		
		dm.GetContainedAbilities(attackName, attributes);
		size = attributes.Size();
		for( i = 0; i < size; i += 1 )
		{
			//damage
			if( IsDamageTypeNameValid(attributes[i]) )
			{
				dm.GetAbilityAttributeValue(attackName, attributes[i], min, max);
				dmgVal = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));				
				
				if(dmgVal > 0)
					AddDamage(attributes[i], dmgVal);
			}
		}
	}
	
	function AddDamage( dmgType : name, dmgVal : float )
	{		
		if( theGame.GetDefinitionsManager().AbilityHasTag( attackName, theGame.params.ATTACK_NO_DAMAGE ) )
		{
			return;
		}
		
		if ( IsActionMelee() )
		{
			dmgVal = RandRangeF( dmgVal*1.1, dmgVal*0.9 );
		}
		
		super.AddDamage( dmgType, dmgVal );
	}
	
	function AddEffectInfo(effectType : EEffectType, optional duration : float, optional effectCustomValue : SAbilityAttributeValue, optional effectAbilityName : name, optional customParams : W3BuffCustomParams, optional buffApplyChance : float )
	{
		//gryphon hack
		if( theGame.GetDefinitionsManager().AbilityHasTag( attackName, theGame.params.ATTACK_NO_DAMAGE ) )
		{
			if(effectType == EET_Bleeding)
				return;
		}
		
		super.AddEffectInfo(effectType, duration, effectCustomValue, effectAbilityName, customParams, buffApplyChance);
	}
	
	public function GetPowerStatBonusAbilityTag() : name		{return attackName;}
	public function GetWeaponId() : SItemUniqueId				{return weaponId;}
	public function SetIsParried(b : bool)						{isParried = b;}
	public function IsParried() : bool							{return isParried;}
	public function SetIsCountered(b : bool)					{isCountered = b;}
	public function IsCountered() : bool						{return isCountered;}
	public function SetAttackAnimName(a : name)					{attackAnimName = a;}
	public function GetAttackAnimName() : name					{return attackAnimName;}
	public function SetHitTime(t : float)						{hitTime = t;}
	public function GetHitTime() : float						{return hitTime;}	
	public function SetWeaponEntity(e : CItemEntity)			{weaponEntity = e;}
	public function GetWeaponEntity() : CItemEntity				{return weaponEntity;}	
	public function SetWeaponSlot(w : name)						{weaponSlot = w;}
	public function GetWeaponSlot() : name						{return weaponSlot;}
	public function SetSoundAttackType(s : name)				{soundAttackType = s;}
	public function GetSoundAttackType() : name					{return soundAttackType;}	
	public function UsedZeroStaminaPerk() : bool				{return usedZeroStaminaPerk;}
	public function SetUsedZeroStaminaPerk()					{usedZeroStaminaPerk = true;}
	public function ApplyBuffsIfParried() : bool				{return applyBuffsIfParried;}
	public function SetApplyBuffsIfParried(b : bool)			{applyBuffsIfParried = b;}
	
	// Returns name of the attack (set in animation)
	public function GetAttackName() : name						{return attackName;}
	
	// Returns name of the attack TYPE (e.g. skill, light, heavy etc.)
	public function GetAttackTypeName() : name					{return attackTypeName;}
	
	// Override. Returns power stat value for this action
	public function GetPowerStatValue() : SAbilityAttributeValue
	{
		var min, max, result, horseDamageBonus : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var temp : name;
		var actorVictim, actorAttacker : CActor;
		var monsterCategory : EMonsterCategory;
		var tmpBool : bool;
		var horse : CNewNPC;
		var horseSpeed, holdRatio : float;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var attributes : array<name>;
		var mutagenBuff : W3Mutagen28_Effect;
		var playerAttacker : CPlayer;
		var mutagen25 : W3Mutagen25_Effect;
		

		result = super.GetPowerStatValue();
		actorVictim = (CActor)victim;
		actorAttacker = (CActor)attacker;		
				
		if(actorVictim && actorAttacker)
		{
			//monster type item bonus		
			theGame.GetMonsterParamsForActor( actorVictim, monsterCategory, temp, tmpBool, tmpBool, tmpBool);
			
			//if proper oil active
			if( actorAttacker.GetInventory().ItemHasActiveOilApplied( weaponId, monsterCategory ) )
			{
				actorAttacker.GetInventory().GetItemAbilities(weaponId, attributes);
				result += actorAttacker.GetInventory().GetItemAttributeValue(weaponId, MonsterCategoryToAttackPowerBonus(monsterCategory) );
			}
			
			//monster type mutagen bonus
			playerAttacker = (CPlayer)actorAttacker;
			if(playerAttacker && playerAttacker.HasBuff(EET_Mutagen28))
			{
				mutagenBuff = (W3Mutagen28_Effect)playerAttacker.GetBuff(EET_Mutagen28);
				result += mutagenBuff.GetMonsterDamageBonus(monsterCategory);				
			}
		}
		
		//geralt skill bonus
		witcherAttacker = (W3PlayerWitcher)attacker;
		if(witcherAttacker)
		{		
			//light & heavy attack skill bonus
			//if( witcherAttacker.CanUseSkill(S_Sword_s21) && (witcherAttacker.IsLightAttack(attackTypeName) || witcherAttacker.IsHeavyAttack(attackTypeName)) )
			//	result += witcherAttacker.GetPowerStatValue(powerStatType, SkillEnumToName(S_Sword_s21));

			//basic heavy attack damage
			if(witcherAttacker.IsHeavyAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_2))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_2, PowerStatEnumToName(CPS_AttackPower), false, true);
			
			//heavy attack upgrade bonus
			if(witcherAttacker.IsHeavyAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_s04))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s04);
			
			//light attack upgrade bonus
			if(witcherAttacker.IsLightAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_s21))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s21);
						
			//crossbow damage perk
			if(witcherAttacker.inv.IsIdValid(crossbowId) && witcherAttacker.CanUseSkill(S_Perk_02))
			{				
				result += witcherAttacker.GetSkillAttributeValue(S_Perk_02, PowerStatEnumToName(CPS_AttackPower), false, true);
			}

			//attack after counter
			if(witcherAttacker.HasRecentlyCountered() && witcherAttacker.CanUseSkill(S_Sword_s11))
			{
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s11, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s11);
			}
			
			//perk 05 bonus
			if(witcherAttacker.IsLightAttack(attackTypeName))
			{
				result += witcherAttacker.GetAttributeValue('attack_power_fast_style');
			}
			
			//perk 07 bonus
			if(witcherAttacker.IsHeavyAttack(attackTypeName))
			{
				result += witcherAttacker.GetAttributeValue('attack_power_heavy_style');
			}
		}
			
		// horse
		if(actorAttacker)
		{
			horse = (CNewNPC)(actorAttacker.GetUsedVehicle());
			
			if( horse && horse.IsHorse())
			{
				/*speed bonus -- disabled, npcs don't get speed bonuses
				if( attackName == 'attack_speed_based' )
				{
					horseSpeed = horse.GetMovingAgentComponent().GetRelativeMoveSpeed();
					
					//FIXME - move to a better place than getter function
					if( horseSpeed >= 3.0 && horseSpeed < 4.0 )
					{
						horseDamageBonus.valueMultiplicative = 1.5;
					}
					else if( horseSpeed >= 4.0 )
					{
						horseDamageBonus.valueMultiplicative = 4.0;
						if( actorAttacker == thePlayer )
							AddEffectInfo( EET_Knockdown, 1.5 );
					}
					
					result += horseDamageBonus;
				}*/
				
				//mutagen bonus
				if(actorAttacker == thePlayer && thePlayer.HasBuff(EET_Mutagen25) && IsActionMelee())
				{
					mutagen25 = (W3Mutagen25_Effect)thePlayer.GetBuff(EET_Mutagen25);
					result += mutagen25.GetAttackPowerBonus();
				}
			}
		}
		
		//power stat bonus from attack definition
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(attackName, attributes);		
		for(i=0; i<attributes.Size(); i+=1)
		{
			if(PowerStatNameToEnum(attributes[i]) == powerStatType)
			{
				dm.GetAbilityAttributeValue(attackName, attributes[i], min, max);
				result += GetAttributeRandomizedValue(min, max);
				break;
			}
		}
		
		//FINAL HACK
		if(result.valueMultiplicative < 0)
			result.valueMultiplicative = 0.001;
		
		return result;
	}
	
	//gets bone index in which victim was hit by actor
	public final function GetHitBoneIndex() : int
	{
		var weaponEntity : CItemEntity;
		var weaponSlotMatrix : Matrix;
		var weaponSlotPosition, weaponTipSlotPosition : Vector;
		var i : int;
		var dist, min : float;
		var category : name;
		var cr4HumanoidCombatComponent : CR4HumanoidCombatComponent;
		
		//if not cached then cache first
		if(boneIndex == -1)
		{		
			category = attacker.GetInventory().GetItemCategory(weaponId);
			weaponSlotPosition = MatrixGetTranslation( attacker.GetBoneWorldMatrixByIndex(attacker.GetBoneIndex(weaponSlot)) );
			
			if(category == 'monster_weapon')
			{
				boneIndex = victim.GetRootAnimatedComponent().FindNearestBoneWS(weaponSlotPosition);
			}
			else if(category == 'fist')
			{
			}
			else	//not a monster - weapon edge check
			{
				weaponEntity = attacker.GetInventory().GetItemEntityUnsafe(weaponId);
				if(weaponEntity)
				{
					weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
					weaponTipSlotPosition = MatrixGetTranslation( weaponSlotMatrix );
					
					cr4HumanoidCombatComponent = (CR4HumanoidCombatComponent)victim.GetComponentByClassName( 'CR4HumanoidCombatComponent' );
					if( cr4HumanoidCombatComponent )
					{
						boneIndex = cr4HumanoidCombatComponent.GetBoneClosestToEdge(weaponSlotPosition, weaponTipSlotPosition);
					}
					else
					{
						boneIndex = victim.GetRootAnimatedComponent().FindNearestBoneToEdgeWS(weaponSlotPosition, weaponTipSlotPosition);
					}
				}
			}
		}
		
		return boneIndex;
	}
}
