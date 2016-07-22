class W3Effect_Oil extends CBaseGameplayEffect
{
	private saved var currCount : int;			//current oil charges
	private saved var maxCount : int;			//max oil charges
	private saved var sword : SItemUniqueId;	//sword item that has the oil applied
	private saved var oilAbility : name;		//ability of the oil item
	private saved var oilItemName : name;		//item name of the oil
	private saved var queueTimer : int;
	
	default effectType = EET_Oil;
	default isPositive = true;
	default dontAddAbilityOnTarget = true;
	default queueTimer = 0;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var oilParams : W3OilBuffParams;
		
		//get stats
		oilParams = (W3OilBuffParams)customParams;
		if(oilParams)
		{
			iconPath = oilParams.iconPath;
			effectNameLocalisationKey = oilParams.localizedName;
			effectDescriptionLocalisationKey = oilParams.localizedDescription;
			currCount = oilParams.currCount;
			maxCount = oilParams.maxCount;
			sword = oilParams.sword;
			oilAbility = oilParams.oilAbilityName;
			oilItemName = oilParams.oilItemName;
		}
		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		//count alchemy usage but only after nightmare
		if( ShouldProcessTutorial( 'TutorialAlchemyRefill' ) && FactsQuerySum( "q001_nightmare_ended" ) > 0 && target == GetWitcherPlayer() )
		{
			FactsAdd( 'tut_alch_refill', 1 );
		}
		
		//remove oil ability from item
		target.GetInventory().RemoveItemCraftedAbility( sword, oilAbility );
		
		Show( false );
		
		super.OnEffectRemoved();
	}
	
	event OnEffectAddedPost()
	{
		var swordEquipped : bool;
		var swordEntity : CWitcherSword;
		
		//add oil ability to item
		target.GetInventory().AddItemCraftedAbility( sword, oilAbility );
				
		swordEquipped = GetWitcherPlayer().IsItemEquipped( sword );
		if(swordEquipped)
		{
			//When sword is equipped it adds its abilities to player. Since item is equipped it has already done that so we need to do it manually.
			target.AddAbility( oilAbility );
			
			//visuals on blade
			swordEntity = (CWitcherSword) target.GetInventory().GetItemEntityUnsafe( sword );
			swordEntity.ApplyOil( oilAbility );
		}
		
		UpdateOilsQueue();
	}
	
	protected function Show( visible : bool )
	{
		var swordEntity : CWitcherSword;
		
		if( visible )
		{
			if( !GetWitcherPlayer().IsItemHeld( sword ) )
			{
				return;
			}
		}
		
		showOnHUD = visible;
		
		//visuals on blade
		swordEntity = (CWitcherSword) target.GetInventory().GetItemEntityUnsafe( sword );		
		if( visible )
		{
			swordEntity.ApplyOil( oilAbility );
		}
		else
		{
			swordEntity.RemoveOil( oilAbility );
		}	
	}
	
	protected function OnResumed()
	{
		if( currCount > 0 )
		{
			Show( true );			
		}
	}
	
	protected function OnPaused()
	{
		Show( false );
	}
	
	public final function Reapply( newMax : int )
	{
		maxCount = newMax;
		currCount = newMax;
		
		queueTimer = 0;
		UpdateOilsQueue();
		
		//show if not visible
		if( !IsPaused( '' ) )
		{
			Show( true );
		}
	}
	
	private final function UpdateOilsQueue()
	{
		var otherOils : array< W3Effect_Oil >;
		var i : int;
		
		otherOils = target.GetInventory().GetOilsAppliedOnItem( sword );
		otherOils.Remove( this );
		
		for( i=0; i<otherOils.Size(); i+=1 )
		{
			otherOils[i].IncreaseQueueTimer();
		}
	}
	
	public final function IncreaseQueueTimer()
	{
		queueTimer += 1;
	}
	
	public final function GetQueueTimer() : int
	{
		return queueTimer;
	}
	
	protected function CumulateWith( effect : CBaseGameplayEffect )
	{
		var oldCount : int;
		
		oldCount = currCount;
		
		super.CumulateWith( effect );
		
		if( oldCount <= 0 && currCount > 0 && !IsPaused( '' ) && !showOnHUD )
		{
			Show( true );
		}
	}
	
	public final function ReduceAmmo()
	{
		if( currCount == 1 )
		{
			Show( false );
		}
		
		currCount = Max( 0, currCount - 1 );
	}
	
	public final function GetAmmoMaxCount() : int
	{
		return maxCount;
	}

	public final function GetAmmoCurrentCount() : int
	{
		return currCount;
	}

	public final function GetAmmoPercentage() : float
	{
		return currCount / maxCount;
	}
	
	public final function GetSwordItemId() : SItemUniqueId
	{
		return sword;
	}
	
	public final function GetOilItemName() : name
	{
		return oilItemName;
	}
	
	public final function GetOilAbilityName() : name
	{
		return oilAbility;
	}
	
	public final function GetMonsterCategory() : EMonsterCategory
	{
		var i : int;
		var mcType : EMonsterCategory;
		var attributes : array< name >;
	
		theGame.GetDefinitionsManager().GetAbilityAttributes( oilAbility, attributes );
		
		for( i=0; i<attributes.Size(); i+=1 )
		{
			mcType = MonsterAttackPowerBonusToCategory( attributes[ i ] );
			if( mcType != MC_NotSet )
			{
				return mcType;
			}
		}
			
		return MC_NotSet;
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var otherLevel, selfLevel : int;
		var oilTypeSelf, oilTypeOther : string;
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var otherBuff : W3Effect_Oil;
	
		otherBuff = ( W3Effect_Oil ) e;		
		oilTypeSelf = StrLeft( oilItemName, StrLen( oilItemName ) - 2 );
		oilTypeOther = StrLeft( otherBuff.oilItemName, StrLen( otherBuff.oilItemName ) - 2 );
		
		if(oilTypeSelf != oilTypeOther)
		{
			return EI_Pass;
		}
		
		//choose higher level
		dm = theGame.GetDefinitionsManager();
		dm.GetItemAttributeValueNoRandom( oilItemName, true, 'level', min, max );
		selfLevel = RoundMath( CalculateAttributeValue( min ) );
		
		dm.GetItemAttributeValueNoRandom( otherBuff.oilItemName, true, 'level', min, max );
		otherLevel = RoundMath( CalculateAttributeValue( min ) );
		
		if( otherLevel >= selfLevel)
		{
			return EI_Override;
		}

		return EI_Deny;
	}
}

class W3OilBuffParams extends W3BuffCustomParams
{
	var iconPath : string;
	var localizedName : string;
	var localizedDescription : string;
	var currCount : int;
	var maxCount : int;
	var sword : SItemUniqueId;
	var oilAbilityName : name;
	var oilItemName : name;
}