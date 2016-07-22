/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014
/** Author :	 Tomek Kozera
/***********************************************************************/

//Handles gamer profile. Should use proper API on platforms such as XBOX, PS, Steam and our 
//custom implementation on GOG

class W3GamerProfile
{
	private var statistics : array<SStatistic>;
	private var achievementDefinitions : array<SAchievement>;				//cached from XML achievement data
	
	public function AddAchievement(a : EAchievement)
	{
		theGame.UnlockAchievement(AchievementEnumToName(a));
		LogAchievements("Achievement <<" + a + ">> unlocked!");
	}
	
	//Initializes the object
	public function Init()
	{
		LoadXMLAchievementData();
		InitStats();
		RegisterAchievements();
	}
		
	//Sets up all statistics
	public function InitStats()
	{
		//gameplay
		InitStat(ES_CharmedNPCKills);
		InitStat(ES_AardFallKills);
		InitStat(ES_EnvironmentKills);
		InitStat(ES_CounterattackChain);
		InitStat(ES_DragonsDreamTriggers);
		InitStat(ES_KnownPotionRecipes);
		InitStat(ES_KnownBombRecipes);
		InitStat(ES_ReadBooks);
		InitStat(ES_HeadShotKills);
		InitStat(ES_BleedingBurnedPoisoned);
		InitStat(ES_DestroyedNests);
		InitStat(ES_FundamentalsFirstKills);
		InitStat(ES_FinesseKills);
		InitStat(ES_SelfArrowKills);
		InitStat(ES_ActivePotions);
		InitStat(ES_KilledCows);
		InitStat(ES_SlideTime);
	}
	
	//Registers achievements to listen to stats
	private function RegisterAchievements()
	{
		//gameplay
		RegisterAchievement(ES_CharmedNPCKills, EA_EnemyOfMyFriend);
		RegisterAchievement(ES_AardFallKills, EA_FusSthSth);
		RegisterAchievement(ES_EnvironmentKills, EA_EnvironmentUnfriendly);
		RegisterAchievement(ES_CounterattackChain, EA_TrainedInKaerMorhen);
		RegisterAchievement(ES_DragonsDreamTriggers, EA_TheEvilestThing);
		RegisterAchievement(ES_KnownPotionRecipes, EA_BreakingBad);
		RegisterAchievement(ES_KnownBombRecipes, EA_Bombardier);
		RegisterAchievement(ES_BleedingBurnedPoisoned, EA_Rage);
		RegisterAchievement(ES_HeadShotKills, EA_TechnoProgress);
		RegisterAchievement(ES_ReadBooks, EA_Bookworm);
		RegisterAchievement(ES_DestroyedNests, EA_FireInTheHole);
		RegisterAchievement(ES_FundamentalsFirstKills, EA_FundamentalsFirst);
		RegisterAchievement(ES_FinesseKills, EA_Finesse);
		RegisterAchievement(ES_SelfArrowKills, EA_FeatherStrongerThanSword);
		RegisterAchievement(ES_ActivePotions, EA_Thirst);
		RegisterAchievement(ES_KilledCows, EA_WantedDeadOrBovine);
		RegisterAchievement(ES_SlideTime, EA_Slide);
	}

	private function LoadXMLAchievementData()
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var i, tmpInt : int;
		var tmpName : name;
		var achievement : SAchievement;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('achievements');

		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			//if XML def has no name ignore
			if(!dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
				continue;
				
			achievement.type = AchievementNameToEnum(tmpName);
			
			//if unknown achievement type
			if(achievement.type == EA_Undefined)
				continue;
				
			//ok, get the required value
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredValue', tmpInt))
				achievement.requiredValue = tmpInt;
						
			achievementDefinitions.PushBack(achievement);
			
			achievement.type = EA_Undefined;
			achievement.requiredValue = -1;
		}
	}
	
	private function GetAchievementIndex(a : EAchievement) : int
	{
		var i : int;
		
		for(i=0; i<achievementDefinitions.Size(); i+=1)
			if(achievementDefinitions[i].type == a)
				return i;
				
		return -1;
	}
	
	public function CheckLearningTheRopes()
	{
		if(FactsQuerySum("ach_counter") == 1 && FactsQuerySum("ach_attack") == 1 && FactsQuerySum("ach_sign") == 1 && FactsQuerySum("ach_bomb") == 1)
		{
			AddAchievement(EA_LearningTheRopes);
		}		
	}
	
	public final function CheckTrialOfGrasses()
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if(!witcher)
			return;
		
		//check mutagen skills
		if(!witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen4))
			return;
		if(!witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen3))
			return;
		if(!witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen2))
			return;
		if(!witcher.IsAnyItemEquippedOnSlot(EES_SkillMutagen1))
			return;
				
		AddAchievement(EA_TrialOfGrasses);
	}
		
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////  INT  ///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//Resets given stat to 0
	public function ResetStat(statEnum : EStatistic)
	{
		var i, idx : int;
		var statName : name;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		statName = StatisticEnumToName(statEnum);
		FactsRemove(statName);
		FactsAdd(statName, 0);
	}
	
	public function GetStatValue(statEnum : EStatistic) : int
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return -1;
			
		return FactsQuerySum(StatisticEnumToName(statEnum));
	}
	
	//Increases given int statistic
	public function IncStat(statEnum : EStatistic)
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		FactsAdd(StatisticEnumToName(statEnum));
		CheckProgress(statEnum);
	}
	
	//Increases given int statistic
	public function SetStat(statEnum : EStatistic, val : int)
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		FactsSet(StatisticEnumToName(statEnum), val);
		CheckProgress(statEnum);
	}
	
	//Decreases given int statistic
	public function DecStat(statEnum : EStatistic)
	{
		var idx : int;
	
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
			return;
			
		FactsSubstract(StatisticEnumToName(statEnum), 1);
	}
	
	//checks given stat for perk & achievement progress
	private function CheckProgress(statEnum : EStatistic)
	{
		var i, idx : int;
		var achievementType : EAchievement;
		var statName : name;
		var currStatVal : int;
	
		idx = GetStatisticIndex(statEnum);
		statName = StatisticEnumToName(statEnum);
		currStatVal = FactsQuerySum(statName);
		
		//check achievements
		for(i=statistics[idx].registeredAchievements.Size()-1; i>=0; i-=1)
		{
			achievementType = statistics[idx].registeredAchievements[i].type;
			
			//if statistic value reached or exceeded
			if(statistics[idx].registeredAchievements[i].requiredValue <= currStatVal)
			{
				//add achievement
				AddAchievement(achievementType);
			}
		}		
	}
	
	public function CheckProgressOfAllStats()
	{
		var i : int;
	
		for( i = 0; i < statistics.Size(); i+=1 )
			CheckProgress( statistics[i].statType );
	}
	
	//Gets index of given int statistic object
	private function GetStatisticIndex(statEnum : EStatistic) : int
	{
		var i : int;
		
		for(i=0; i<statistics.Size(); i+=1)
		{
			if(statistics[i].statType == statEnum)
				return i;
		}
		
		return -1;
	}
		
	//Registers achievement to listen to given int stat
	private function RegisterAchievement(statEnum : EStatistic, ac : EAchievement)
	{
		var idx, aInd : int;
		
		idx = GetStatisticIndex(statEnum);
		if(idx < 0)
		{
			LogAchievements("Cannot register achievement <<" + ac + ">> to game statistics - statistic <<" + statEnum + ">> is no longer updated!");
			return;
		}
		
		aInd = GetAchievementIndex(ac);
		if(aInd < 0)
		{
			LogAchievements("Cannot register achievement <<" + ac + ">> to game statistics - achievement already achieved!");
			return;
		}
		statistics[idx].registeredAchievements.PushBack(achievementDefinitions[aInd]);
	}
	
	//Sets up statistic of int type, also called on game load
	private function InitStat(statEnum : EStatistic)
	{
		var stat : SStatistic;
	
		if(FactsQuerySum(StatisticEnumToName(statEnum)) == -1)	//not tracked anymore
			return;
		
		stat.statType = statEnum;
		statistics.PushBack(stat);
	}
	
	public final function ClearAllAchievementsForEP1()
	{
		var unlockedAchievments : array<name>;
		var i : int;
		
		theGame.GetUnlockedAchievements(unlockedAchievments);
		for(i=0; i<unlockedAchievments.Size(); i+=1)
		{
			theGame.LockAchievement(unlockedAchievments[i]);
		}
		
		//clear progress
		SetStat(ES_CharmedNPCKills, 0);
		SetStat(ES_AardFallKills, 0);
		SetStat(ES_EnvironmentKills, 0);
		SetStat(ES_CounterattackChain, 0);
		SetStat(ES_DragonsDreamTriggers, 0);
		SetStat(ES_BleedingBurnedPoisoned, 0);
		SetStat(ES_HeadShotKills, 0);
		SetStat(ES_FundamentalsFirstKills, 0);
		SetStat(ES_ReadBooks, 0);
		SetStat(ES_DestroyedNests, 0);
	}
	
	public final function ClearAllAchievementsForEP2()
	{
		//same as for EP1
		ClearAllAchievementsForEP1();
		
		//also clear progress of EP1 achievements
		SetStat( ES_SelfArrowKills, 0 );
		SetStat( ES_ActivePotions, 0 );
		SetStat( ES_KilledCows, 0 );
		SetStat( ES_SlideTime, 0 );
	}
	
	public final function Debug_PrintAchievements()
	{
		var achievement : EAchievement;
		var currVal, i, j, k : int;
		var goto : bool;
		var allFTs, foundFTs : array< SAvailableFastTravelMapPin >;
		var areaMapPins : array< SAreaMapPinInfo >;
		var entityMapPins : array< SEntityMapPinInfo >;
		
		LogAchievements("");
		LogAchievements("Printing current achievements' status:");
		
		//print the ones based on stats
		for(i=0; i<statistics.Size(); i+=1)
		{
			for(j=0; j<statistics[i].registeredAchievements.Size(); j+=1)
			{
				achievement = statistics[i].registeredAchievements[j].type;				
				currVal = FactsQuerySum(StatisticEnumToName(statistics[i].statType));
				LogAchievements(achievement + ", progress: " + NoTrailZeros(currVal) + "/" + NoTrailZeros(statistics[i].registeredAchievements[j].requiredValue));
			}
		}
		
		//Explorer - find 100 FT, missing points
		foundFTs = theGame.GetCommonMapManager().GetFastTravelPoints(true, false, false, true, true);
		allFTs = theGame.GetCommonMapManager().GetFastTravelPoints(false, false, false, false, true);
		LogAchievements(EA_Explorer + ", progress: " + foundFTs.Size() + "/100");
		if(foundFTs.Size() < 100)
		{
			//get list of missing FTs
			for(i=allFTs.Size()-1; i>=0; i-=1)
			{
				for(j=0; j<foundFTs.Size(); j+=1)
				{
					if(allFTs[i].tag == foundFTs[j].tag && allFTs[i].type == foundFTs[j].type && allFTs[i].area == foundFTs[j].area)
					{
						allFTs.EraseFast(i);
						break;
					}
				}
			}
			
			//get all pins
			areaMapPins = theGame.GetCommonMapManager().GetAreaMapPins();
			LogAchievements("");
			LogAchievements(EA_Explorer + ": missing " + (100 - foundFTs.Size()) + " FT points, coords:");
			
			for(k=0; k<allFTs.Size(); k+=1)
			{
				goto = false;
				
				//find pin
				for ( i = 0; i < areaMapPins.Size(); i += 1 )
				{
					entityMapPins.Clear();
					entityMapPins = theGame.GetCommonMapManager().GetEntityMapPins( areaMapPins[ i ].worldPath );
					for ( j = 0; j < entityMapPins.Size(); j += 1 )
					{
						if(entityMapPins[j].entityType == allFTs[k].type && entityMapPins[j].entityName == allFTs[k].tag && areaMapPins[i].areaType == allFTs[k].area)
						{
							LogAchievements( SpaceFill(allFTs[k].tag,35,ESFM_JustifyLeft) + " in   " + SpaceFill(allFTs[k].area,30,ESFM_JustifyLeft) + " at:   x=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.X),5,ESFM_JustifyRight) + ", y=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.Y),5,ESFM_JustifyRight) + ", z=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.Z),5,ESFM_JustifyRight) );
							goto = true;
							break;
						}
					}
					
					if(goto)
						break;
				}
			}
		}
		/* 
			debug - print found FTs
		else
		{
			areaMapPins = theGame.GetCommonMapManager().GetAreaMapPins();
			for(k=0; k<foundFTs.Size(); k+=1)
			{
				goto = false;
				
				//find pin
				for ( i = 0; i < areaMapPins.Size(); i += 1 )
				{
					entityMapPins.Clear();
					entityMapPins = theGame.GetCommonMapManager().GetEntityMapPins( areaMapPins[ i ].worldPath );
					for ( j = 0; j < entityMapPins.Size(); j += 1 )
					{
						if(entityMapPins[j].entityType == foundFTs[k].type && entityMapPins[j].entityName == foundFTs[k].tag && areaMapPins[i].areaType == foundFTs[k].area)
						{
							LogAchievements( SpaceFill(foundFTs[k].tag,35,ESFM_JustifyLeft) + " in   " + SpaceFill(foundFTs[k].area,30,ESFM_JustifyLeft) + " at:   x=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.X),5,ESFM_JustifyRight) + ", y=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.Y),5,ESFM_JustifyRight) + ", z=" + SpaceFill(RoundMath(entityMapPins[j].entityPosition.Z),5,ESFM_JustifyRight) );
							goto = true;
							break;
						}
					}
					
					if(goto)
						break;
				}
			}
		}
		*/
		
		LogAchievements("");
	}
}

exec function UnlockAllAchievements()
{
	var gamerProfile : W3GamerProfile;
	var i : int;
	
	gamerProfile = theGame.GetGamerProfile();
	for( i = 0; i <= EnumGetMax('EAchievement'); i += 1 )
	{
		gamerProfile.AddAchievement(i);
	}
}

exec function achieve(a : EAchievement)
{
	theGame.GetGamerProfile().AddAchievement(a);	
}

exec function achievei(i : int)
{
	var a : EAchievement;
	
	a = i;
	theGame.GetGamerProfile().AddAchievement(a);	
}

exec function printach()
{
	theGame.GetGamerProfile().Debug_PrintAchievements();
}
