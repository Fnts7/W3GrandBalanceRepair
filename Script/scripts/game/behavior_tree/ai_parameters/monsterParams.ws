//////////////////////////////////////////////
///////////// MONSTER AI TREES ///////////////
//////////////////////////////////////////////

// BASE CLASSES AND DEFAULTS FOR MONSTERS:
// ---------------------------------------------------------------------------------

// CAIMonsterBase
class CAIMonsterBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\monster_base";

	editable inlined var params : CAIBaseMonsterDefaults;
	
	function Init()
	{
		params = new CAIMonsterDefaults in this;
		params.OnCreated();
	}
};

// CAIBaseMonsterDefaults
abstract class CAIBaseMonsterDefaults extends CAIDefaults
{
	editable inlined var spawnTree 			: CAIMonsterSpawn;
	editable inlined var keepDistance		: CAIKeepDistanceTree;
	editable inlined var tauntTree 			: CAIMonsterTaunt;
	editable inlined var axiiTree			: CAIMonsterAxii;
	editable inlined var idleDecoratorTree	: CAIMonsterIdleDecorator;
	editable inlined var idleTree 			: CAIIdleTree;
	
	editable var ignoreReachability		: bool;
	editable var allowPursueDistance 	: float;
	editable var canSwim				: bool;
	editable var canBury				: bool;
	editable var canKeepDistance 		: bool; 

	
	
	default ignoreReachability 	= false;
	default allowPursueDistance = 4;
	default canKeepDistance = true;
	
	
	function Init()
	{
		idleDecoratorTree = new CAIMonsterIdleDecorator in this;
		idleDecoratorTree.OnCreated();
		tauntTree = new CAIMonsterTaunt in this;
		tauntTree.OnCreated();
		axiiTree = new CAIMonsterAxii in this;
		axiiTree.OnCreated();
	}
}

// CAIMonsterDefaults
class CAIMonsterDefaults extends CAIBaseMonsterDefaults
{
	editable inlined var combatTree : CAIMonsterCombat;
	editable inlined var deathTree 	: CAIMonsterDeath;	
	
	editable var spawnEntityAtDeath	: bool;
	editable var morphInCombat 		: bool;
	editable var entityToSpawn		: name;
	
	function Init()
	{
		super.Init();
		spawnTree = new CAIMonsterSpawnDefault in this;
		spawnTree.OnCreated();
		combatTree = new CAIMonsterCombat in this;
		combatTree.OnCreated();
		deathTree = new CAIMonsterDeath in this;
		deathTree.OnCreated();
	}
};

// CAIFlyingMonsterDefaults
class CAIFlyingMonsterDefaults extends CAIBaseMonsterDefaults
{
	editable inlined var combatTree 	: CAIFlyingMonsterCombat;
	editable inlined var deathTree 		: CAIFlyingMonsterDeath;
	editable inlined var flyingWander	: CAISubTree;
	editable inlined var freeFlight		: IAIFlightIdleTree;
	
	editable var canFly				: bool;
	
	default canFly 				= true;
	default ignoreReachability 	= true;
	
	function Init()
	{
		super.Init();
		spawnTree = new CAIMonsterSpawnFlying in this;
		spawnTree.OnCreated();
		combatTree = new CAIFlyingMonsterCombat in this;
		combatTree.OnCreated();
		deathTree = new CAIFlyingMonsterDeath in this;
		deathTree.OnCreated();
		freeFlight = new CAIFlightIdleFreeRoam in this;
		freeFlight.OnCreated();
		
		axiiTree.params.canFly = true;
	}
}

// CAITrollDefaults
class CAITrollDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree.params.IncreaseHitCounterOnlyOnMelee = false;
		combatTree.params.combatLogicTree = new CAITrollCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorTroll in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAISharleyDefaults
class CAISharleyDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree.params.IncreaseHitCounterOnlyOnMelee = false;
		combatTree.params.combatLogicTree = new CAISharleyCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorTroll in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIVampiressDefaults
class CAIVampiressDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree.params.combatLogicTree = new CAIVampiressCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAINekkerDefaults
class CAINekkerDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();		
		combatTree.params.combatLogicTree = new CAINekkerCombatLogic in this;		
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'NekkerKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorNekker in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim 		= true;
		deathTree.params.disableCollision 				= true;
		deathTree.params.disableCollisionDelay 			= 0;
	}
};

// CAIBiesDefaults
class CAIBiesDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		var moveToLure : CAIActionMoveToLure =  new CAIActionMoveToLure in this;
		
		super.Init();
		combatTree.params.combatLogicTree = new CAIBiesCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorBies in this;
		idleDecoratorTree.OnCreated();
		
		moveToLure.OnCreated();
		idleDecoratorTree.params.reactionTree.params.reactions.PushBack( moveToLure );
		
		deathTree.params.disableCollision 				= true;
		deathTree.params.disableCollisionDelay 			= 0;
	}
};

// CAIBiesDEBUG
class CAIBiesDEBUG extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBiesDEBUGLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAISirenDefaults
class CAISirenDefaults extends CAIFlyingMonsterDefaults
{
	default canSwim = true;
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAISirenCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'SirenCrawlFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorSiren in this;
		idleDecoratorTree.OnCreated();
		
		/*idleTree = new CAISirenDynamicWander in this;
		idleTree.OnCreated();*/
		
		flyingWander = new CAISirenDynamicWander in this;
		flyingWander.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;		
		
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
		
		axiiTree = NULL;
		tauntTree = NULL;
	}
};

// CAIIceGiantDefaults
class CAIIceGiantDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIIceGiantCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGiant in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIIceGiantEp2Defaults
class CAIIceGiantEp2Defaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIIceGiantEp2CombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGiant in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIGhoulDefaults
class CAIDjinnDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree.params.combatLogicTree = new CAIDjinnCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIDrownerDefaults
class CAIDrownerDefaults extends CAIMonsterDefaults
{
	default canSwim = true;
	default canBury = true;
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIDrownerCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'DrownerKnockDownFinisher';
		
		spawnTree = new CAIMonsterSpawnFlying in this;
		spawnTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorDrowner in this;
		idleDecoratorTree.OnCreated();
		
		idleTree = new CAIAmphibiousDynamicWander in this;
		idleTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
		
		
	}
};

// CAIDrownerDefaults
class CAIDrownerUnderwaterDefaults extends CAIDrownerDefaults
{
	default ignoreReachability = true;
}

// CAIRotfiendDefaults
class CAIRotfiendDefaults extends CAIDrownerDefaults
{
	default canSwim = false;
	function Init()
	{
		super.Init();
		spawnEntityAtDeath  = true;
		entityToSpawn 		= 'rotfiend_explode';
	}
};

// CAIGhoulDefaults
class CAIGhoulDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree.params.combatLogicTree = new CAIGhoulCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'GhoulKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGhoul in this;
		idleDecoratorTree.OnCreated();
		
		/*tauntTree = new CAICowardMonsterTaunt in this;
		tauntTree.OnCreated();*/
		
		deathTree.params.disableCollisionOnAnim 	= true;
		deathTree.params.disableCollision 			= true;
		deathTree.params.disableCollisionDelay 		= 2;
		
		deathTree.params.stopFXOnActivate = 'morph_fx';
	}
};

// CAIGryphonDefaults
class CAIGryphonDefaults extends CAIFlyingMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIGryphonCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGryphon in this;
		idleDecoratorTree.OnCreated();		
		
		/*idleTree = new CAIDynamicFlyingWanderGryphon in this;
		idleTree.OnCreated();*/
		
		flyingWander = new CAIDynamicFlyingWanderGryphon in this;
		flyingWander.OnCreated();
		
		axiiTree.params.landingGroundOffset = 7;
	}
};

// CAIHarpyDefaults
class CAIHarpyDefaults extends CAIFlyingMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIHarpyCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim		= 'HarpyKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorHarpy in this;
		idleDecoratorTree.OnCreated();		
		
		/*idleTree = new CAIDynamicFlyingWanderHarpy in this;
		idleTree.OnCreated();*/
		
		flyingWander = new CAIDynamicFlyingWanderHarpy in this;
		flyingWander.OnCreated();
		
		axiiTree.params.onSpotLanding 		= true;
		axiiTree.params.landingGroundOffset = 1;
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
		
	}
};

// CAIWraithDefaults
class CAIWraithDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIWraithCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWraith in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 0.05;
		deathTree.params.destroyAfterAnimDelay 	= 5;
	}
};



// CAINoonwraithDefaults
class CAINoonwraithDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAINoonwraithCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorNoonWraith in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.destroyAfterAnimDelay = 5.0f;
		deathTree.params.stopFXOnActivate = 'shadows_form';
	}
};

class CAINoonwraithDoppelgangerDefaults extends CAINoonwraithDefaults
{
	default ignoreReachability = true;
	function Init()
	{
		super.Init();
		
		tauntTree = NULL;
		idleDecoratorTree = NULL;
		axiiTree = NULL;
		combatTree.params.reactionTree = NULL;
	}
}

// CAIPestaDefaults
class CAIPestaDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIPestaCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree.params.destroyAfterAnimDelay = 5.0f;
		deathTree.params.stopFXOnActivate = 'shadows_form';
	}
};


// CAIIrisDefaults
class CAIIrisDefaults extends CAIMonsterDefaults
{
	default canKeepDistance 	= false;
	default ignoreReachability 	= true;
	
	function Init()
	{
		super.Init();
		spawnTree = new CAIMonsterSpawnIris in this;
		spawnTree.OnCreated();
		combatTree.params.combatLogicTree = new CAIIrisCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree = new CAIIrisDeath in this;
		deathTree.OnCreated();
		deathTree.params.destroyAfterAnimDelay = 20.0f;
		deathTree.params.stopFXOnActivate = 'drained_paint';
	}
};

// CAIShadeDefaults
class CAIShadeDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIShadeCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		//deathTree.params.playFXOnActivate = 'disappear';
		deathTree.params.fxName = 'disappear';
		deathTree.params.destroyAfterAnimDelay = 2.0f;
	}
};

// CAIWolfDefaults
class CAIWolfDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		/////////////////////////////////////////////////////////////
		super.Init();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWolf in this;
		idleDecoratorTree.OnCreated();
		
		combatTree.params.combatLogicTree = new CAIWolfCombatLogic in combatTree.params;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'WolfKnockDownFinisher';
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
	}
};

// CAIWolfAlphaDefaults
class CAIWolfAlphaDefaults extends CAIWolfDefaults
{
	function Init()
	{
		var leadPack 			: CAILeadPackWander;
		var newParams : CAIWolfCombatLogicParams;
		super.Init();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWolfAlpha in this;
		idleDecoratorTree.OnCreated();
		
		newParams = (CAIWolfCombatLogicParams)combatTree.params.combatLogicTree.params;
		newParams.attackMovementType = MT_Walk;
		
		idleTree = new CAILeadPackWander in this;
		idleTree.OnCreated();
		leadPack = (CAILeadPackWander) idleTree;
		leadPack.leaderRegroupEvent = 'WolfMoves';
		leadPack.followers = 6;
	}
};

// CAIGuardDogDefaults
class CAIGuardDogDefaults extends CAIWolfDefaults
{
	function Init()
	{
		var moveOut : CAIActionMoveOut;
		
		super.Init();
		
		moveOut = new CAIActionMoveOut in this;
		moveOut.OnCreated();
		idleDecoratorTree.params.reactionTree.params.reactions.PushBack( moveOut );
	}
}

// CAILessogDefaults
class CAILessogDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		spawnTree = new CAIMonsterSpawnLessog in this;
		spawnTree.OnCreated();
		combatTree.params.combatLogicTree = new CAILessogCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		deathTree = new CAIMonsterDeath in this;
		deathTree.OnCreated();
		deathTree.params.playFXOnDeactivate = 'respawn_dissapear';
		deathTree.params.disableCollision = true;
		deathTree.params.destroyAfterAnimDelay = 10;
	}
};

// CAISpriganDefaults
class CAISpriganDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAISpriganCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		deathTree = new CAIMonsterDeath in this;
		deathTree.OnCreated();
		deathTree.params.playFXOnDeactivate = 'respawn_dissapear';
		deathTree.params.disableCollision = true;
		deathTree.params.destroyAfterAnimDelay = 10;
	}
};

// CAIHimDefaults
class CAIHimDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIHimCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		deathTree = new CAIMonsterDeath in this;
		deathTree.OnCreated();
	}
};

// CAIEndriagaDefaults
class CAIEndriagaDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		var combatLogicParams : CAIArachasCombatLogicParams;
		
		super.Init();
		combatTree.params.combatLogicTree = new CAIArachasCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatLogicParams = ((CAIArachasCombatLogicParams)combatTree.params.combatLogicTree.params);
		combatLogicParams.minChargeDist = 3.0;
		combatLogicParams.maxChargeDist = 4.0;
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorArachas in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim	= true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay	= 0;
	}
};

// CAIBlackSpiderDefaults
class CAIBlackSpiderDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		var combatLogicParams : CAIBlackSpiderCombatLogicParams;
		
		super.Init();
		combatTree.params.combatLogicTree = new CAIBlackSpiderCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatLogicParams = ((CAIBlackSpiderCombatLogicParams)combatTree.params.combatLogicTree.params);
		combatLogicParams.minChargeDist = 3.0;
		combatLogicParams.maxChargeDist = 4.0;
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorArachas in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim	= true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay	= 0;
	}
};

// CAIBlackSpiderEP2Defaults
class CAIBlackSpiderEP2Defaults extends CAIMonsterDefaults
{
	function Init()
	{
		var combatLogicParams : CAIBlackSpiderEP2CombatLogicParams;
		
		super.Init();
		combatTree.params.combatLogicTree = new CAIBlackSpiderEP2CombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatLogicParams = ((CAIBlackSpiderEP2CombatLogicParams)combatTree.params.combatLogicTree.params);
		combatLogicParams.minChargeDist = 3.0;
		combatLogicParams.maxChargeDist = 4.0;
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorArachas in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim	= true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay	= 0;
	}
};

// CAIArachasDefaults
class CAIArachasDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIArachasCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorArachas in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIArachasDEBUG
class CAIArachasDEBUG extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIArachasDEBUGLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIGolemDefaults
class CAIGolemDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIGolemCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGolem in this;
		idleDecoratorTree.OnCreated();
		
		spawnTree.params.monitorGroundContact = true;
	}
};

// CAIIfritDefaults
class CAIIfritDefaults extends CAIGolemDefaults
{
	function Init()
	{
		super.Init();		
		deathTree.params.destroyAfterAnimDelay = 5;
	}
}

// CAIIceGolemDefaults
class CAIIceGolemDefaults extends CAIGolemDefaults
{
	function Init()
	{
		super.Init();		
		deathTree.params.destroyAfterAnimDelay = 5;
	}
};


// CAIGolemDEBUG
class CAIGolemDEBUG extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIGolemDEBUGLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIWerewolfDefaults
class CAIWerewolfDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIWerewolfCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'WerewolfKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWerewolf in this;
		idleDecoratorTree.OnCreated();
		
		deathTree = new CAIMonsterDefeated in this;
		deathTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 0.5;
	}
};

// CAIBigbadwolfDefaults
class CAIBigbadwolfDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBigbadwolfCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'WerewolfKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWerewolf in this;
		idleDecoratorTree.OnCreated();
		
		deathTree = new CAIMonsterDefeated in this;
		deathTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 0.5;
	}
};

// CAIKatakanDefaults
class CAIKatakanDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIKatakanCombatLogic in this;
		combatTree.params.Init();
		// Commenting out the finishers related to the Werewolf and saving the lines for future Katakan changes
		// combatTree.params.criticalState[(int)ECST_Knockdown].params.FinisherAnim = 'WerewolfKnockDownFinisher';
		// combatTree.params.criticalState[(int)ECST_HeavyKnockdown].params.FinisherAnim = 'WerewolfKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorKatakan in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIFlederDefaults
class CAIFlederDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIFlederCombatLogic in this;
		combatTree.params.Init();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorKatakan in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIBearDefaults
class CAIBearDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBearCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorBear in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIBearDefaults
class CAIBearProtectiveDefaults extends CAIBearDefaults
{
	editable var canTaunt	: bool;
	editable var berserk	: bool;
	
	default canTaunt 	= false;
	default berserk 	= true;
	
	default allowPursueDistance = 0;
	function Init()
	{
		super.Init();
		keepDistance	= new CAIKeepDistanceTree in this;
		keepDistance.OnCreated();
		keepDistance.moveType = MT_Walk;
	}
};

// CAIWyvernDefaults
class CAIWyvernDefaults extends CAIFlyingMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIWyvernCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWyvern in this;
		idleDecoratorTree.OnCreated();		
		
		axiiTree.params.landingGroundOffset = 2;
		
		/*idleTree = new CAIDynamicFlyingWanderWyvern in this;
		idleTree.OnCreated();*/
		
		flyingWander = new CAIDynamicFlyingWanderWyvern in this;
		flyingWander.OnCreated();
	}
};

// CAIDracolizardDefaults
class CAIDracolizardDefaults extends CAIFlyingMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIDracolizardCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorWyvern in this;
		idleDecoratorTree.OnCreated();		
		
		axiiTree.params.landingGroundOffset = 2;
		
		/*idleTree = new CAIDynamicFlyingWanderWyvern in this;
		idleTree.OnCreated();*/
		
		flyingWander = new CAIDynamicFlyingWanderWyvern in this;
		flyingWander.OnCreated();
	}
};

// CAIGravierDefaults
class CAIGravierDefaults extends CAIMonsterDefaults
{
	default canSwim = false;
	default canBury = true;
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIGravierCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'DrownerKnockDownFinisher';
		
		spawnTree = new CAIMonsterSpawnFlying in this;
		spawnTree.OnCreated();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorDrowner in this;
		idleDecoratorTree.OnCreated();
		
		idleTree = new CAIAmphibiousDynamicWander in this;
		idleTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
		spawnEntityAtDeath  = true;
		entityToSpawn 		= 'rotfiend_explode';
		deathTree.params.playFXOnActivate = 'spikes_explode';
	}
};

// CAIGravehagDefaults
class CAIGravehagDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIGravehagCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'GravehagKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGravehag in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
	}
};

// CAIFoglingDopplegangerDefaults
class CAIFoglingDopplegangerDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIFoglingDopplegangerCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree.params.playFXOnActivate = 'disappear_fog';
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 0.05;
		deathTree.params.destroyAfterAnimDelay 	= 5;
	}
};

// CAIWitchDefaults
class CAIWitchDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIWitchCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIWitch2Defaults
class CAIWitch2Defaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIWitch2CombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIWightDefaults
class CAIWightDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIWightCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'GravehagKnockDownFinisher';
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorGravehag in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
	}
};

// CAIFugasDefaults
class CAIFugasDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIFugasCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree.params.disableCollisionOnAnim = true;
		deathTree.params.disableCollision 		= true;
		deathTree.params.disableCollisionDelay 	= 2;
	}
};

// CAIRatDefaults
class CAIRatDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		var fleeFire : CAIActionLeadEscape =  new CAIActionLeadEscape in this;
		var fleeAard : CAIActionLeadEscape =  new CAIActionLeadEscape in this;
	
		super.Init();
		combatTree.params.combatLogicTree = new CAIRatCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		fleeFire.OnCreated();
		fleeFire.actionEventName = 'FireDanger';
		
		fleeAard.OnCreated();
		fleeAard.actionEventName = 'CastSignAction';
		
		idleDecoratorTree.params.reactionTree.params.reactions.PushBack( fleeFire );
		combatTree.params.reactionTree.params.reactions.PushBack( fleeFire );
		combatTree.params.reactionTree.params.reactions.PushBack( fleeAard );
		
		combatTree.params.criticalState = NULL;
		
		spawnTree = NULL;
		tauntTree = NULL;
	}
};

// CAIBoarDefaults
class CAIBoarDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBoarCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'BoarKnockDownFinisher';
	}
};

// CAIBoarEP2Defaults
class CAIBoarEP2Defaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBoarEP2CombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'BoarKnockDownFinisher';
	}
};

// CAIPantherDefaults
class CAIPantherDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIPantherCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'BoarKnockDownFinisher';
	}
};


// CAIKikimoreDefaults
class CAIKikimoreDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIKikimoreCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'BoarKnockDownFinisher';
	}
};



// CAIToadDefaults
class CAIToadDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIToadCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree.params.disableCollision 				= true;
		deathTree.params.disableCollisionDelay 			= 0;
	}
};


// CAIScolopendromorphDefaults
class CAIScolopendromorphDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIScolopendromorphCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		idleDecoratorTree = new CAIScolopendromorphIdleDecorator in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIBroomDefaults
class CAIBroomDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBroomCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIArchesporDefaults
class CAIArchesporDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIArchesporCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		idleDecoratorTree = new CAIEchinopsIdleDecorator in this;
		idleDecoratorTree.OnCreated();
	}
};

// CAIDettlaffDefaults
class CAIDettlaffDefaults extends CAIMonsterDefaults
{
	default morphInCombat = true;
	
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIDettlaffCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}	
};

// CAIDettlaffVampireDefaults
class CAIDettlaffVampireDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIDettlaffVampireCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIFairytaleWitchDefaults
class CAIFairytaleWitchDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIFairytaleWitchCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
	}
};

// CAIBarghestDefaults
class CAIBarghestDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBarghestCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		combatTree.params.criticalState.params.FinisherAnim = 'WolfKnockDownFinisher';
		
		deathTree.params.disableCollision 				= true;
		deathTree.params.disableCollisionDelay 			= 0;
	}
};

// CAIDettlaffFlederDefaults
class CAIDettlaffFlederDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIFlederCombatLogic in this;
		combatTree.params.Init();
		
		idleDecoratorTree = new CAIMonsterIdleDecoratorKatakan in this;
		idleDecoratorTree.OnCreated();
		
		deathTree.params.destroyAfterAnimDelay = 1.f;
	}
};

// CAIDettlaffVampiressDefaults
class CAIDettlaffVampiressDefaults extends CAIMonsterDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree.params.combatLogicTree = new CAIVampiressCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree.params.destroyAfterAnimDelay = 1.f;
	}
};

// CAIBansheeDefaults
class CAIBansheeDefaults extends CAIMonsterDefaults
{
	default canKeepDistance 	= true;
	default ignoreReachability 	= false;
	
	function Init()
	{
		super.Init();
		combatTree.params.combatLogicTree = new CAIBansheeCombatLogic in this;
		combatTree.params.combatLogicTree.OnCreated();
		
		deathTree.params.destroyAfterAnimDelay = 10.0f;
	}
};

// AXII TREES AND PARAMETERS:
// ---------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------
// CAIMonsterAxii
class CAIMonsterAxii extends CAIAxiiTree
{
	default aiTreeName = "resdef:ai\monster_baseaxii";

	editable inlined var params : CAIMonsterAxiiParams;
	
	function Init()
	{
		params = new CAIMonsterAxiiParams in this;
		params.OnCreated();
	}
};
// CAIMonsterAxiiParams
class CAIMonsterAxiiParams extends CAIAxiiParameters
{		
	editable var canFly 				: bool;
	editable var onSpotLanding 			: bool;
	editable var landingGroundOffset 	: float;
	
	function Init()
	{			
		super.Init();
	}
};

// TAUNT TREES AND PARAMETERS:
// ---------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------

// CAIMonsterTaunt
class CAIMonsterTaunt extends CAITauntTree
{
	
	editable var canBury : bool;
	
	default aiTreeName = "resdef:ai\monster_basetaunt";

	editable inlined var params : CAIMonsterTauntParams;
	
	function Init()
	{
		params = new CAIMonsterTauntParams in this;
		params.OnCreated();
	}
};

// CAIMonsterTauntParams
class CAIMonsterTauntParams extends CAITauntParameters
{	
	editable var stopTauntingDistance 	: float;
	editable var tauntDelay 			: float;
	editable var forceAttackDelay		: float;
	editable var useSurround			: bool;
	editable var chanceToMove			: float;
	
	default stopTauntingDistance = 15;
	default tauntDelay 			 = 3;
	default forceAttackDelay 	 = 20;
	default useSurround			 = true;
	default chanceToMove		 = 40;
	
	hint stopTauntingDistance 	= "monster starts fighting when target is closer than this distance";
	hint tauntDelay 			= "delay between each play taunt animation";
	hint forceAttackDelay 		= "after taunting for this long, monster starts fighting";
	hint useSurround 			= "surround the target while taunting";
	hint chanceToMove 			= "chance to start/stop moving every 2 seconds";
	
	function Init()
	{			
		super.Init();
	}
};

// CAICowardMonsterTaunt
class CAICowardMonsterTaunt extends CAIMonsterTaunt
{
	default aiTreeName = "resdef:ai\monster_cowardtaunt";
	
	function Init()
	{
		super.Init();
		params = new CAICowardMonsterTauntParams in this;
		params.OnCreated();
	}
};

// CAICowardMonsterTauntParams
class CAICowardMonsterTauntParams extends CAIMonsterTauntParams
{	
	editable var moveBackDistance 	: float;
	
	default stopTauntingDistance = 10;
	default forceAttackDelay 	 = 35;
	
	default moveBackDistance 	 = 13;
};

// COMBAT TREES AND PARAMETERS:
// ---------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------

// CAIBaseMonsterCombatParams
abstract class CAIBaseMonsterCombatParams extends CAICombatParameters
{
	editable inlined var combatLogicTree 	: CAIMonsterCombatLogic; 
	editable inlined var damageReactionTree : CAIMonsterSimpleDamageReactionTree;
	
	// combat target selection params
	editable var reachabilityTolerance : float;
	editable var targetOnlyPlayer : bool;
	editable var hostileActorWeight : float;
	editable var currentTargetWeight : float;
	editable var rememberedHits : int;
	editable var hitterWeight : float;
	editable var maxWeightedDistance : float;
	editable var distanceWeight : float;
	editable var playerWeightProbability : int;
	editable var playerWeight : float;
	editable var skipVehicle : ECombatTargetSelectionSkipTarget;
	editable var skipVehicleProbability : int;
	editable var skipUnreachable : ECombatTargetSelectionSkipTarget;
	editable var skipUnreachableProbability : int;
	editable var skipNotThreatening : ECombatTargetSelectionSkipTarget;
	editable var skipNotThreateningProbability : int;

	//this is a base value. It is added to every potential target
	default	hostileActorWeight 	= 10.0f;
	
	default reachabilityTolerance = 2.0f;
	
	default	hitterWeight 		= 20.0f; //	>= playerWeight + currentTargetWeight
	default	currentTargetWeight = 9.0f;  // 
	default	playerWeight		= 1000.0f; // i will target notPlayer when potentialTarget is playerWeight[meters] closer
	
	
	//both values the same will give us 1 point per meter
	//if potentialTarget is above maxWeightedDistance he will target player for sure.
	default	distanceWeight 		= 30.0f;
	default maxWeightedDistance = 30.0f;
		
	//other flags
	default	targetOnlyPlayer = false;
	default	playerWeightProbability = 100;
	default rememberedHits = 2;		

	//targetting vehicles ( horses )
	default skipVehicle 			= CTSST_SKIP_IF_THERE_ARE_OTHER_TARGETS;
	default	skipVehicleProbability 	= 100;

	// unreachable (by navitagtion) targets
	default skipUnreachable 			= CTSST_SKIP_IF_THERE_ARE_OTHER_TARGETS;
	default	skipUnreachableProbability 	= 100;
	
	// with threat level 0
	default skipNotThreatening 				= CTSST_SKIP_IF_THERE_ARE_OTHER_TARGETS;
	default	skipNotThreateningProbability 	= 100;

	function Init()
	{
		var i : int;
		var stdCS : CAINpcCriticalState;
		//skipVehicle = 1;
		damageReactionTree = new CAIMonsterDamageReactionTree in this;
		damageReactionTree.OnCreated();
	}
}

// CAIMonsterCombat
class CAIMonsterCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\monster_basecombat";

	editable inlined var params : CAIMonsterCombatParams;
	
	function Init()
	{
		params = new CAIMonsterCombatParams in this;
		params.OnCreated();
		
		params.reactionTree = new CAIMonsterCombatReactionsTree in this;
		params.reactionTree.OnCreated();
	}
};

// CAIMonsterCombatParams
class CAIMonsterCombatParams extends CAIBaseMonsterCombatParams
{
	editable var createHitReactionEvent 		: name;
	editable var IncreaseHitCounterOnlyOnMelee 	: bool;
	editable inlined var criticalState 			: CAINpcCriticalState;
	editable inlined var reactionTree 			: CAIMonsterCombatReactionsTree;
	
	hint createReactionEvent = "HitReaction reaction event";
	
	default IncreaseHitCounterOnlyOnMelee = true;
	
	function Init()
	{			
		super.Init();		
		createHitReactionEvent = 'MonsterHitReaction';	

		criticalState =  new CAINpcCriticalState in this;
		criticalState.OnCreated();
	}
};

// CAIFlyingMonsterCombat
class CAIFlyingMonsterCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\monster_basecombat";

	editable inlined var params : CAIFlyingMonsterCombatParams;
	
	function Init()
	{
		params = new CAIFlyingMonsterCombatParams in this;
		params.OnCreated();
		
		params.reactionTree = new CAIMonsterCombatReactionsTree in this;
		params.reactionTree.OnCreated();
		params.reactionTree.params.canFly = true;
	}
};

// CAIFlyingMonsterCombatParams
class CAIFlyingMonsterCombatParams extends CAIBaseMonsterCombatParams
{
	editable var IncreaseHitCounterOnlyOnMelee 	: bool;
	editable inlined var criticalState 			: CAINpcCriticalStateFlying;
	editable inlined var reactionTree 			: CAIMonsterCombatReactionsTree;
	
	default IncreaseHitCounterOnlyOnMelee = true;
	
	function Init()
	{			
		super.Init();
		
		criticalState =  new CAINpcCriticalStateFlying in this;
		criticalState.OnCreated();
	}
};

// LOGIC TREES AND PARAMS:
// ---------------------------------------------------------------------------------

// CAIMonsterCombatLogic
class CAIMonsterCombatLogic extends CAISubTree
{
	editable inlined var params : CAIMonsterCombatLogicParams;
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIMonsterCombatLogicParams
class CAIMonsterCombatLogicParams extends CAISubTreeParameters
{
};

// CAIGravehagCombatLogicParams
class CAIGravehagCombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable inlined var mistForm : bool;
	editable inlined var mudThrow : bool;
	editable inlined var witchSpecialAttack : bool;
	
};

// CAIGravehagCombatLogicParams
class CAISharleyCombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable inlined var prioritizePlayerAsTarget : bool;
};

// CAIFlyingMonsterCombatLogic
class CAIFlyingMonsterCombatLogic extends CAIMonsterCombatLogic
{
};

// CAITrollCombatLogic
class CAITrollCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_cave_troll_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAISharleyCombatLogic
class CAISharleyCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_sharley_logic.w2behtree";

	function Init()
	{
		params = new CAISharleyCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIVampiressCombatLogic
class CAIVampiressCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_bruxa_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIIceGiantCombatLogic
class CAIIceGiantCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_ice_giant_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIIceGiantEp2CombatLogic
class CAIIceGiantEp2CombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_giant_ep2_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAINekkerCombatLogic
class CAINekkerCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_nekker_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBiesCombatLogic
class CAIBiesCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_bies_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBiesDEBUGLogic
class CAIBiesDEBUGLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_bies_debug";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAISirenCombatLogic
class CAISirenCombatLogic extends CAIFlyingMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_siren_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();		
	}
};

// CAIDrownerCombatLogic
class CAIDjinnCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_djinn_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIDrownerCombatLogic
class CAIDrownerCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_drowner_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIGhoulCombatLogic
class CAIGhoulCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_ghoul_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAINoonwraithCombatLogic
class CAINoonwraithCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_noonwraith_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIPestaCombatLogic
class CAIPestaCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_pesta_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIIrisCombatLogic
class CAIIrisCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_iris_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAINoonwraithCombatLogic
class CAIShadeCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters\monster_shade_logic";
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};


// CAIGryphonCombatLogic
class CAIGryphonCombatLogic extends CAIFlyingMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_gryphon_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAILessogCombatLogic
class CAILessogCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_lessog_logic";
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAISpriganCombatLogic
class CAISpriganCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_sprigan_logic.w2behtree";
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIHimCombatLogic
class CAIHimCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_him_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWolfCombatLogic
class CAIWolfCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_wolf_logic";

	function Init()
	{
		params = new CAIWolfCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWolfCombatLogicParams
class CAIWolfCombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable var attackMovementType : EMoveType;
	
	//default attackMovementType = MT_Run;
	function Init()
	{
		attackMovementType = MT_Run;
	}
};

// CAIGolemCombatLogic
class CAIGolemCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_golem_logic";

	function Init()
	{
		params = new CAIGolemCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIGolemCombatLogicParams
class CAIGolemCombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable var projectileTemplate : CEntityTemplate;
	editable var attackRange : float;
	
	function Init()
	{
		attackRange = 10.f;
		//TODO: GetEntityTemplate
	}
}

// CAIGolemDEBUGLogic
class CAIGolemDEBUGLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_golem_debug";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWerewolfCombatLogic
class CAIWerewolfCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_werewolf_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBigbadwolfCombatLogic
class CAIBigbadwolfCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_bigbadwolf_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIKatakanCombatLogic
class CAIKatakanCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_katakan_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.Init();
	}
};

// CAIFlederCombatLogic
class CAIFlederCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_fleder_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.Init();
	}
};

// CAIBansheeCombatLogic
class CAIBansheeCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_banshee_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWraithCombatLogic
class CAIWraithCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_wraith_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIHarpyCombatLogic
class CAIHarpyCombatLogic extends CAIFlyingMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_harpy_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIGhulCombatLogic
class CAIGhulCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_ghul_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIArachasCombatLogic
class CAIArachasCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_arachas_logic";

	function Init()
	{
		params = new CAIArachasCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBlackSpiderCombatLogic
class CAIBlackSpiderCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_black_spider_logic";

	function Init()
	{
		params = new CAIBlackSpiderCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBlackSpiderEP2CombatLogic
class CAIBlackSpiderEP2CombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_black_spider_ep2_logic";

	function Init()
	{
		params = new CAIBlackSpiderEP2CombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIArachasCombatLogicParams
class CAIArachasCombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable var minChargeDist : float;
	editable var maxChargeDist : float;
	
	function Init()
	{
		minChargeDist = 7.0;
		maxChargeDist = 8.0;
	}
};

// CAIBlackSpiderCombatLogicParams
class CAIBlackSpiderCombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable var minChargeDist : float;
	editable var maxChargeDist : float;
	
	function Init()
	{
		minChargeDist = 7.0;
		maxChargeDist = 8.0;
	}
};

// CAIBlackSpiderEP2CombatLogicParams
class CAIBlackSpiderEP2CombatLogicParams extends CAIMonsterCombatLogicParams
{
	editable var minChargeDist : float;
	editable var maxChargeDist : float;
	
	function Init()
	{
		minChargeDist = 7.0;
		maxChargeDist = 8.0;
	}
};

// CAIArachasDEBUGLogic
class CAIArachasDEBUGLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_arachas_debug";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBearCombatLogic
class CAIBearCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_bear_berserker_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWyvernCombatLogic
class CAIWyvernCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_wyvern_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIDracolizardCombatLogic
class CAIDracolizardCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_dracolizard_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIGravierCombatLogic
class CAIGravierCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_gravier_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIFoglingDopplegangerCombatLogic
class CAIFoglingDopplegangerCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_fogling_doppelganger_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIGravehagCombatLogic
class CAIGravehagCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_gravehag_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWightCombatLogic
class CAIWightCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_wight_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIWitchCombatLogic
class CAIWitchCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_witch_logic";
	
	editable var Phase1 			: bool;
	editable var Phase2 			: bool;
	editable var PhaseReset 		: bool;
	editable var AbilityHypnosis 	: bool;
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};


// CAIWitch2CombatLogic
class CAIWitch2CombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_witch2_logic";
	
	editable var Phase1 			: bool;
	editable var Phase2 			: bool;
	editable var PhaseReset 		: bool;
	editable var bileAttack 		: bool;
	editable var prePursueTaunt 	: bool;
	
	default bileAttack = true;
	default prePursueTaunt = true;
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
		
		bileAttack = true;
		prePursueTaunt = true;
	}
};



// CAIWitchSoloCombatLogic
class CAIWitchSoloCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_witch_solo_logic";
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};


// CAIFugasCombatLogic
class CAIFugasCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_fugas_logic";
	
	editable var useFasterMovementToApproach : bool;
	editable var fireAttack : bool;
	
	default useFasterMovementToApproach = true;
	default fireAttack = true;
	
	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
		
		useFasterMovementToApproach = true;
		fireAttack = true;
	}
};

// CAIRatCombatLogic
class CAIRatCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_rat_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();		
	}
};

// CAIBoarCombatLogic
class CAIBoarCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_boar_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBoarEP2CombatLogic
class CAIBoarEP2CombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_boar_ep2_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};


// CAIPantherCombatLogic
class CAIPantherCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_panther_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};


class CAIKikimoreCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_kikimore_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};



class CAIToadCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_toad_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIArchesporCombatLogic
class CAIArchesporCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_echinops_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIFairytaleWitchCombatLogic
class CAIFairytaleWitchCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_fairytale_witch_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIScolopendromorphCombatLogic
class CAIScolopendromorphCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_scolopendromorph_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBroomCombatLogic
class CAIBroomCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_broom_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIDettlaffVampireCombatLogic
class CAIDettlaffVampireCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// CAIBarghestCombatLogic
class CAIBarghestCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "resdef:ai\monsters/monster_barghest_logic";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.Init();
	}
};

// CAIDettlaffCombatLogic
class CAIDettlaffCombatLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_dettlaff_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

class CAIDettlaffTornadoLogic extends CAIMonsterCombatLogic
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\dettlaff_tornado_logic.w2behtree";

	function Init()
	{
		params = new CAIMonsterCombatLogicParams in this;
		params.OnCreated();
	}
};

// RETREAT, DAMAGE REACTION AND FINISHER TREES:
// ---------------------------------------------------------------------------------

// CAIMonsterRetreat - doesnt seem to be used anywhere

// CAIMonsterSimpleDamageReactionTree
class CAIMonsterSimpleDamageReactionTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\monster_simple_damage_reaction";
};

// CAIMonsterDamageReactionTree
class CAIMonsterDamageReactionTree extends CAIMonsterSimpleDamageReactionTree
{
	default aiTreeName = "resdef:ai\monster_damage_reaction";

	editable inlined var params : CAIDamageReactionTreeParams;
	
	function Init()
	{
		params = new CAIDamageReactionTreeParams in this;
		params.OnCreated();
	}
};

// CAIDamageReactionTreeParams
class CAIDamageReactionTreeParams extends CAISubTreeParameters
{
	editable var completeTaskAfterDisablingHitReaction : bool;
	editable var enableTeleportOnHit : bool;
	
	function Init()
	{
		completeTaskAfterDisablingHitReaction		= true;
		enableTeleportOnHit 						= false;
	}
};

// CAIFinisherTreeParams
class CAIFinisherTreeParams extends CAICombatActionParameters
{
	editable var syncAnimName : name;
	
	default syncAnimName = '';
};

// SPAWN TREES AND PARAMETERS:
// ---------------------------------------------------------------------------------

// CAIMonsterSpawn
class CAIMonsterSpawn extends CAISubTree
{
	editable inlined var params : CAIMonsterSpawnParams;
	
	function Init()
	{
	}
};

// CAIMonsterSpawnParams
class CAIMonsterSpawnParams extends CAISubTreeParameters
{
	editable var fxName						: name;
	editable var animEventNameActivator		: name;
	editable var playFXOnAnimEvent			: bool;
	editable var monitorGroundContact 		: bool;
	editable var dealDamageOnAnimEvent		: name;
	editable var becomeVisibleOnAnimEvent 	: name;
};

// CAIMonsterSpawnDefault
class CAIMonsterSpawnDefault extends CAIMonsterSpawn
{
	default aiTreeName = "resdef:ai\monster_spawn_default";

	function Init()
	{
		params = new CAIMonsterSpawnParams in this;
		params.OnCreated();
	}
};

// CAIMonsterSpawnDefault
class CAIMonsterSpawnFleder extends CAIMonsterSpawn
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_fleder_spawn.w2behtree";

	function Init()
	{
		params = new CAIMonsterSpawnParams in this;
		params.OnCreated();
	}
};

//CAIMonsterSpawnFlying
class CAIMonsterSpawnFlying extends CAIMonsterSpawn
{
	default aiTreeName = "resdef:ai\monster_spawn_flying";

	function Init()
	{
		params = new CAIMonsterSpawnParams in this;
		params.OnCreated();
	}
};

// CAIMonsterSpawnIris
class CAIMonsterSpawnIris extends CAIMonsterSpawn
{
	//default aiTreeName = "resdef:ai\monster_spawn_iris";
	default aiTreeName = "dlc\ep1\data\gameplay\trees\monsters\monster_iris_spawn.w2behtree";

	function Init()
	{
		params = new CAIMonsterSpawnParams in this;
		params.OnCreated();
	}
};

// CAIMonsterSpawnLessog
class CAIMonsterSpawnLessog extends CAIMonsterSpawn
{
	default aiTreeName = "resdef:ai\monster_spawn_lessog";

	function Init()
	{
		params = new CAIMonsterSpawnParams in this;
		params.OnCreated();
	}
};

// DEATH TREES AND PARAMETERS:
// ---------------------------------------------------------------------------------

// CAIMonsterDeath
class CAIMonsterDeath extends CAINpcDeath
{	
	function Init()
	{
		// Tree is set in parent
		super.Init();
		params = new CAIMonsterDeathParams in this;
		params.OnCreated();
	}
};

//////////////////////////////////////////////////
// CAINpcDeath 
class CAIIrisDeath extends CAIMonsterDeath
{
	default aiTreeName = "resdef:ai\monster_death_iris";
};

// CAIMonsterDeathParams
class CAIMonsterDeathParams extends CAINpcDeathParams
{		
	default	createReactionEvent			= 'MonsterDeath';
	default	fxName 						= 'death';
	default	setAppearanceTo 			= '';
	default	changeAppearanceAfter 		= 0;
	default	disableAgony 				= true;
	default	disableCollision			= true;
	default	disableCollisionDelay		= 0;
	default	disableCollisionOnAnim		= false;
	default	disableCollisionOnAnimDelay = 0.5;
	default	destroyAfterAnimDelay		= -1;
};

//////////////////////////////////////////////////
// CAIMonsterDefeated 
class CAIMonsterDefeated extends CAIMonsterDeath
{
	default aiTreeName = "resdef:ai\death/defeated";

	editable inlined var localDeathTree 	: CAIMonsterDeath;
	editable inlined var unconsciousTree 	: CAINpcUnconsciousTree;
	function Init()
	{
		super.Init();
		
		localDeathTree = new CAIMonsterDeath in this;
		localDeathTree.OnCreated();
		unconsciousTree = new CAINpcUnconsciousTree in this;
		unconsciousTree.OnCreated();
	}
};

// CAIFlyingMonsterDeath
class CAIFlyingMonsterDeath extends CAIMonsterDeath
{	
	default aiTreeName = "resdef:ai\death/flying_death";

	function Init()
	{
		// Tree is set in parent
		super.Init();
		
		params = new CAIFlyingMonsterDeathParams in this;
		params.OnCreated();
	}
};

// CAIFlyingMonsterDeathParams
class CAIFlyingMonsterDeathParams extends CAIMonsterDeathParams
{	
	default	createReactionEvent			= 'MonsterDeath';
	default	fxName 						= 'death';
	default	setAppearanceTo 			= '';
	default	changeAppearanceAfter 		= 0;
	default	disableAgony 				= true;
	default	disableCollision			= true;
	default	disableCollisionDelay		= 1.0;
	default	disableCollisionOnAnim		= false;
	default	disableCollisionOnAnimDelay = 0.5;
	default	destroyAfterAnimDelay		= -1;
};
