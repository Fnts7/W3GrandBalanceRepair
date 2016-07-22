/*
enum EFocusModeSlideDistance
{
	FMSD_Short,
	FMSD_Medium,
	FMSD_Long,
}

struct SVitalSpotInfo //#B obsolete ?
{
	var owner					: CNewNPC;
	var	spotName				: int; // #B Localised string id
	var	spotDescription			: int; // #B Localised string id
	var	slotScreenCoord			: Vector;
	var	focusPointsCost			: int;
	var	gameEffects				: array< IGameplayEffectExecutor >;
	var slotWorldPos			: Vector;
	var isVisible				: bool;
	var ambientSound			: SVitalSpotAmbientSound;
	var hitReactionAnimation 	: name;
	var destroyAfterExecution	: bool;
	var vitalSpotIndex			: int; 
	//default buttonCode = ESB_NONE;
}

struct SCombatFocusModeEnemyData
{
	var enemyName : int;
	var enemyDescription : int;
	var health : int;
	var stamina : float;
	var armor : float;
	var knowledgePoints : int;
	var currentEffects : array< CBaseGameplayEffect >;
}

struct SVitalSpotAmbientSound
{
	var soundEvent		: string;
	var soundEventOff	: string;
	var slotName		: name;
}
*/