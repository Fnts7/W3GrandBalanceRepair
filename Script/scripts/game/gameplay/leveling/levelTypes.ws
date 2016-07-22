/***********************************************************************/
/** Copyright © 2012
/** Author : Rafal Jarczeswki, Tomasz Kozera
/***********************************************************************/

enum ESpendablePointType
{
	ESkillPoint,
	EExperiencePoint
}

struct SSpendablePoints
{
	saved var free	: int;
	saved var used	: int;
};

struct SLevelDefinition
{
	var number : int;
	var requiredTotalExp : int;
	var addedSkillPoints : int;
	var requiredExp : int;
};