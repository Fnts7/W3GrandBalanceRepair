/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2016 CD Projekt RED
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

/*

do formacji mogą się nadawać:
add_gesture_explain_01-13
add_gesture_question_03-07
add_gesture_slight_explain_01-07
add_reaction - wszystkie

do gossip/greeting:
add_gesture_slight_explain_05
add_gesture_slight_explain_06

*/


class CBTTaskGesturesManager extends IBehTreeTask
{
	public var disableGestures 					: bool;
	public var removePlayedAnimationFromPool	: bool;
	public var gossipGesturesOnly 				: bool;
	public var dontActivateGestureWhenNotTalking: bool;
	public var onlyOneActorGesticulatingAtATime : bool;
	public var stopGestureOnDeactivate 			: bool;
	public var dontOverrideRightHand 			: bool;
	public var dontOverrideLeftHand 			: bool;
	public var cooldownBetweenGesture 			: float;
	public var chanceToPlayGesture 				: float;
	
	//private var 
	private var m_animListLeftHand 				: array<name>;
	private var m_animListRightHand 			: array<name>;
	private var m_animListBothHands 			: array<name>;
	private var m_animList 						: array<name>;
	
	private var animListLeftHand 				: array<name>;
	private var animListRightHand 				: array<name>;
	private var animListBothHands 				: array<name>;
	private var animList 						: array<name>;
	private var timeStamp 						: float;
	private var reactionEventTimeStamp 			: float;
	private var itemInLeftHand 					: bool;
	private var itemInRightHand 				: bool;
	
	
	function Initialize()
	{
		//GOSSIP
		//animationListGossip.PushBack( 'add_gesture_slight_explain_05' ); r
		//animationListGossip.PushBack( 'add_gesture_slight_explain_06' ); l
		
		//FORMATIONS
		//both hands
		m_animList.PushBack( 'add_gesture_explain_01' );
		m_animList.PushBack( 'add_gesture_explain_02' );
		m_animList.PushBack( 'add_gesture_explain_03' );
		m_animList.PushBack( 'add_gesture_explain_04' );
		m_animList.PushBack( 'add_gesture_explain_05' );
		m_animList.PushBack( 'add_gesture_explain_06' );
		m_animList.PushBack( 'add_gesture_explain_07' ); 		//r
		m_animList.PushBack( 'add_gesture_explain_08' );
		m_animList.PushBack( 'add_gesture_explain_09' );
		m_animList.PushBack( 'add_gesture_explain_10' );
		m_animList.PushBack( 'add_gesture_explain_11' );
		m_animList.PushBack( 'add_gesture_explain_12' );
		m_animList.PushBack( 'add_gesture_explain_13' );
		m_animList.PushBack( 'add_gesture_question_03' );
		m_animList.PushBack( 'add_gesture_question_04' );
		m_animList.PushBack( 'add_gesture_question_05' );
		m_animList.PushBack( 'add_gesture_question_06' );
		m_animList.PushBack( 'add_gesture_question_07' );
		//	m_animList.PushBack( 'add_gesture_slight_explain_01' );
		//	m_animList.PushBack( 'add_gesture_slight_explain_02' );
		//	m_animList.PushBack( 'add_gesture_slight_explain_03' );
		//	m_animList.PushBack( 'add_gesture_slight_explain_04' );
		m_animList.PushBack( 'add_gesture_slight_explain_05' );
		m_animList.PushBack( 'add_gesture_slight_explain_06' ); 
		//	m_animList.PushBack( 'add_gesture_slight_explain_07' );
		m_animList.PushBack( 'add_reaction_agreeing_nod_01' );
		m_animList.PushBack( 'add_reaction_agreeing_nod_02' );
		m_animList.PushBack( 'add_reaction_laugh_01' );
		m_animList.PushBack( 'add_reaction_offended_01' );
		m_animList.PushBack( 'add_reaction_offended_02' );
		m_animList.PushBack( 'add_reaction_shake_head_01' );
		m_animList.PushBack( 'add_reaction_shake_head_02' );
		
		//left hand
		//	m_animListLeftHand.PushBack( 'add_gesture_question_05' ); 			//l
		//	m_animListLeftHand.PushBack( 'add_gesture_slight_explain_02' ); 	//l
		//	m_animListLeftHand.PushBack( 'add_gesture_slight_explain_03' ); 	//l
		m_animListLeftHand.PushBack( 'add_gesture_slight_explain_06' ); 	//l 
		m_animListLeftHand.PushBack( 'add_reaction_agreeing_nod_01' ); 		//l
		m_animListLeftHand.PushBack( 'add_gesture_explain_01' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_02' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_03' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_04' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_05' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_06' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_08' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_09' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_10' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_11' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_12' );
		m_animListLeftHand.PushBack( 'add_gesture_explain_13' );
		m_animListLeftHand.PushBack( 'add_gesture_question_03' );
		m_animListLeftHand.PushBack( 'add_gesture_question_04' );
		m_animListLeftHand.PushBack( 'add_gesture_question_05' );
		m_animListLeftHand.PushBack( 'add_gesture_question_06' );
		m_animListLeftHand.PushBack( 'add_gesture_question_07' );
		//	m_animListLeftHand.PushBack( 'add_reaction_agreeing_nod_02' ); 		//n
		//	m_animListLeftHand.PushBack( 'add_reaction_laugh_01' ); 			//n
		//	m_animListLeftHand.PushBack( 'add_reaction_offended_01' ); 			//n
		//	m_animListLeftHand.PushBack( 'add_reaction_offended_02' ); 			//n
		//	m_animListLeftHand.PushBack( 'add_reaction_shake_head_01' ); 		//n
		//	m_animListLeftHand.PushBack( 'add_reaction_shake_head_02' ); 		//n
		
		//right hand
		//	m_animListRightHand.PushBack( 'add_gesture_slight_explain_01' ); 	//r
		m_animListRightHand.PushBack( 'add_gesture_slight_explain_05' ); 	//r
		m_animListRightHand.PushBack( 'add_gesture_explain_01' );
		m_animListRightHand.PushBack( 'add_gesture_explain_02' );
		m_animListRightHand.PushBack( 'add_gesture_explain_03' );
		m_animListRightHand.PushBack( 'add_gesture_explain_04' );
		m_animListRightHand.PushBack( 'add_gesture_explain_05' );
		m_animListRightHand.PushBack( 'add_gesture_explain_06' );
		m_animListRightHand.PushBack( 'add_gesture_explain_07' ); 			//r
		m_animListRightHand.PushBack( 'add_gesture_explain_08' );
		m_animListRightHand.PushBack( 'add_gesture_explain_09' );
		m_animListRightHand.PushBack( 'add_gesture_explain_10' );
		m_animListRightHand.PushBack( 'add_gesture_explain_11' );
		m_animListRightHand.PushBack( 'add_gesture_explain_12' );
		m_animListRightHand.PushBack( 'add_gesture_explain_13' );
		//	m_animListRightHand.PushBack( 'add_reaction_agreeing_nod_02' ); 	//n
		//	m_animListRightHand.PushBack( 'add_reaction_laugh_01' ); 			//n
		//	m_animListRightHand.PushBack( 'add_reaction_offended_01' ); 		//n
		//	m_animListRightHand.PushBack( 'add_reaction_offended_02' ); 		//n
		//	m_animListRightHand.PushBack( 'add_reaction_shake_head_01' ); 		//n
		//	m_animListRightHand.PushBack( 'add_reaction_shake_head_02' ); 		//n
		
		//both hands
		m_animListBothHands.PushBack( 'add_reaction_agreeing_nod_02' ); 	//n
		m_animListBothHands.PushBack( 'add_reaction_laugh_01' ); 			//n
		m_animListBothHands.PushBack( 'add_reaction_offended_01' ); 		//n
		m_animListBothHands.PushBack( 'add_reaction_offended_02' ); 		//n
		m_animListBothHands.PushBack( 'add_reaction_shake_head_01' ); 		//n
		m_animListBothHands.PushBack( 'add_reaction_shake_head_02' ); 		//n
		
		
		//we'll remove animations from duplicate arrays to avoid repeating same anims
		//when array size reaches zero duplicate array will be restored from main array
		animListLeftHand = m_animListLeftHand;
		animListRightHand = m_animListRightHand;
		animListBothHands = m_animListBothHands;
		animList = m_animList;
	}
	
	/*
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	*/
	
	latent function Main() : EBTNodeStatus
	{
		var actor				: CActor = GetActor();
		var mac 				: CMovingPhysicalAgentComponent;
		var ass 				: SAnimatedComponentSlotAnimationSettings;
		var l_animList 			: array<name>;
		var i 					: int;
		var tempF 				: float;
		
		
		if ( disableGestures )
		{
			return BTNS_Active;
		}
		
		
		mac = (CMovingPhysicalAgentComponent) actor.GetComponentByClassName( 'CMovingPhysicalAgentComponent' );
		
		ResetAnimatedComponentSlotAnimationSettings( ass );
		ass.blendIn = 0.5f;
		ass.blendOut = 0.8f;
		
		while ( true )
		{
			if ( !FailedAdditionalConditionsCheck() && GetLocalTime() >= timeStamp + cooldownBetweenGesture && RandF() <= chanceToPlayGesture )
			{
				RestoreAnimationLists();
				HasAnyItemInHands();
				
				if ( ( itemInLeftHand && itemInRightHand ) || ( dontOverrideRightHand && dontOverrideLeftHand ) )
				{
					if ( !gossipGesturesOnly )
					{
						i = RandRange( animListBothHands.Size() - 1, 0 );
						actor.RaiseEvent( 'GestureNoHands' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_NO_HANDS_SLOT', animListBothHands[i] , 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( animListBothHands[i], 'GESTURE_NO_HANDS_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureNoHandsSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						if ( removePlayedAnimationFromPool )
						{
							animListBothHands.EraseFast(i);
						}
					}
				}
				else if ( itemInRightHand || dontOverrideRightHand )
				{
					if ( gossipGesturesOnly )
					{
						actor.RaiseEvent( 'GestureRightHand' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_RIGHT_HAND_SLOT', 'add_gesture_slight_explain_05', 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( 'add_gesture_slight_explain_06', 'GESTURE_RIGHT_HAND_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureRightHandSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
					}
					else
					{
						i = RandRange( animListLeftHand.Size() - 1, 0 );
						actor.RaiseEvent( 'GestureRightHand' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_RIGHT_HAND_SLOT', animListLeftHand[i] , 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( animListLeftHand[i], 'GESTURE_RIGHT_HAND_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureRightHandSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						if ( removePlayedAnimationFromPool )
						{
							animListLeftHand.EraseFast(i);
						}
					}
				}
				else if ( itemInLeftHand || dontOverrideLeftHand )
				{
					if ( gossipGesturesOnly )
					{
						actor.RaiseEvent( 'GestureLeftHand' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_LEFT_HAND_SLOT', 'add_gesture_slight_explain_06', 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( 'add_gesture_slight_explain_05', 'GESTURE_LEFT_HAND_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureLeftHandSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
					}
					else
					{
						i = RandRange( animListRightHand.Size() - 1, 0 );
						actor.RaiseEvent( 'GestureLeftHand' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_LEFT_HAND_SLOT', animListRightHand[i] , 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( animListRightHand[i], 'GESTURE_LEFT_HAND_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureLeftHandSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						if ( removePlayedAnimationFromPool )
						{
							animListRightHand.EraseFast(i);
						}
					}
				}
				else if ( gossipGesturesOnly )
				{
					if ( RandF() < 0.5 )
					{
						actor.RaiseEvent( 'GestureBothHands' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_BOTH_HANDS_SLOT', 'add_gesture_slight_explain_05', 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( 'add_gesture_slight_explain_05', 'GESTURE_BOTH_HANDS_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureBothHandsSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						
					}
					else
					{
						actor.RaiseEvent( 'GestureBothHands' );
						SleepOneFrame();
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_BOTH_HANDS_SLOT', 'add_gesture_slight_explain_06', 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( 'add_gesture_slight_explain_06', 'GESTURE_BOTH_HANDS_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureBothHandsSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
					}
				}
				else
				{
					i = RandRange( animList.Size() - 1, 0 );
					actor.RaiseEvent( 'GestureBothHands' );
					SleepOneFrame();
					tempF = RandF();
					if ( tempF > 0.67f )
					{
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_BOTH_HANDS_SLOT', animList[i] , 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( animList[i], 'GESTURE_BOTH_HANDS_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureBothHandsSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						if ( removePlayedAnimationFromPool )
						{
							animList.EraseFast(i);
						}
					}
					else if ( tempF > 0.33f && tempF <= 0.67f )
					{
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_BOTH_HANDS_SLOT', animList[i] , 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( animListLeftHand[i], 'GESTURE_LEFT_HAND_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureBothHandsSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						if ( removePlayedAnimationFromPool )
						{
							animListLeftHand.EraseFast(i);
						}
					}
					else
					{
						//if ( actor.ActionPlaySlotAnimationAsync( 'GESTURE_BOTH_HANDS_SLOT', animList[i] , 0.5, 0.8 ) )
						if ( mac.PlaySlotAnimationAsync( animListRightHand[i], 'GESTURE_RIGHT_HAND_SLOT' ) )
						{
							theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( actor, 'GesticulatingActor', 12.0f, 5, 1, 999, true );
							actor.WaitForBehaviorNodeDeactivation( 'GestureBothHandsSlotEnd', 12.0f );
							theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
							actor.RaiseEvent( 'GestureForceEnd' );
							timeStamp = GetLocalTime();
						}
						if ( removePlayedAnimationFromPool )
						{
							animListRightHand.EraseFast(i);
						}
					}
				}
			}
			
			Sleep( 0.5 );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var actor 	: CActor = GetActor();
		
		RestoreAnimationLists();
		if ( stopGestureOnDeactivate )
		{
			actor.RaiseEvent( 'GestureForceEnd' );
			theGame.GetBehTreeReactionManager().RemoveReactionEvent( actor, 'GesticulatingActor' );
		}
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( onlyOneActorGesticulatingAtATime )
		{
			reactionEventTimeStamp = GetLocalTime();
			return true;
		}
		
		return false;
	}
	
	final function FailedAdditionalConditionsCheck() : bool
	{
		var actor 			: CActor = GetActor();
		var actors 			: array<CActor>;
		var a, b, c, res 	: bool;
		
		if ( dontActivateGestureWhenNotTalking && !actor.IsSpeaking() )
		{
			a = true;
		}
		
		if ( onlyOneActorGesticulatingAtATime && GetLocalTime() <= reactionEventTimeStamp + 2.0f )
		{
			b = true;
		}
		
		actors = GetActorsInRange( actor, 7.0f, 1, '', true );
		if ( actors.Size() < 1 )
		{
			c = true;
		}
		
		if ( a || b || c )
		{
			res = true;
		}
		
		return res;
	}
	
	final function RestoreAnimationLists()
	{
		if ( removePlayedAnimationFromPool )
		{
			if ( animList.Size() == 0 )
			{
				animList = m_animList;
			}
			if ( animListLeftHand.Size() == 0 )
			{
				animListLeftHand = m_animListLeftHand;
			}
			if ( animListRightHand.Size() == 0 )
			{
				animListRightHand = m_animListRightHand;
			}
			if ( animListBothHands.Size() == 0 )
			{
				animListBothHands = m_animListBothHands;
			}
		}
	}
	
	final function HasAnyItemInHands() : bool
	{
		var actor		: CActor = GetActor();
		var inv 		: CInventoryComponent = actor.GetInventory();
		var item		: SItemUniqueId;
		
		if ( inv )
		{
			item = inv.GetItemFromSlot( 'r_weapon' );
			if ( inv.IsIdValid( item ) )
			{
				itemInRightHand = true;
			}
			
			item = inv.GetItemFromSlot( 'l_weapon' );
			if ( inv.IsIdValid( item ) )
			{
				itemInLeftHand = true;
			}
			
			if ( itemInRightHand || itemInLeftHand )
			{
				return true;
			}
		}
		
		itemInLeftHand = false;
		itemInRightHand = false;
		return false;
	}
}

class CBTTaskGesturesManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass 							= 'CBTTaskGesturesManager';
	
	editable var disableGestures 					: CBehTreeValBool;
	editable var removePlayedAnimationFromPool		: CBehTreeValBool;
	editable var gossipGesturesOnly 				: CBehTreeValBool;
	editable var cooldownBetweenGesture 			: CBehTreeValFloat;
	editable var chanceToPlayGesture 				: CBehTreeValFloat;
	editable var dontActivateGestureWhenNotTalking 	: CBehTreeValBool;
	editable var onlyOneActorGesticulatingAtATime 	: CBehTreeValBool;
	editable var stopGestureOnDeactivate 			: CBehTreeValBool;
	editable var dontOverrideRightHand 				: CBehTreeValBool;
	editable var dontOverrideLeftHand 				: CBehTreeValBool;
	
	public function Initialize()
	{
		SetValBool( disableGestures, true );
		SetValBool( removePlayedAnimationFromPool, true );
		SetValFloat( cooldownBetweenGesture, 2.0f );
		SetValFloat( chanceToPlayGesture, 1.0f );
		SetValBool( stopGestureOnDeactivate, true );
		SetValBool( onlyOneActorGesticulatingAtATime, true );
		
		super.Initialize();
	}
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'GesticulatingActor' );
	}
}