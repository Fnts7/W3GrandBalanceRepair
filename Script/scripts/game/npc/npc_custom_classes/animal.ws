class CAnimal extends CNewNPC
{
	editable var animalType : EAnimalType;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		
		if( animalType == EAT_Peacock )
		{
			AddAnimEventCallback( 'SetNoTailAppearance', 'OnAnimEvent_SetNoTailAppearance' );
			AddAnimEventCallback( 'SetTailAppearance', 'OnAnimEvent_SetTailAppearance' );
		}
		else if( animalType == EAT_Pheasant )
		{
			//AddAnimEventCallback( 'SetNoWingsAppearance', 'OnAnimEvent_SetNoWingsAppearance' );
			//AddAnimEventCallback( 'SetWingsAppearance', 'OnAnimEvent_SetWingsAppearance' );
			
			SetBehaviorVariable( 'canJumpInRun', 1.0 );
		}
	}
	
	event OnAnimEvent_SetNoTailAppearance( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animalType == EAT_Peacock )
		{
			SetAppearance( 'peacock_01' );
		}
		
		return true;
	}
	
	event OnAnimEvent_SetTailAppearance( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animalType == EAT_Peacock )
		{
			SetAppearance( 'peacock_01_opened_tail' );
		}
		
		return true;
	}
	
	/*event OnAnimEvent_SetNoWingsAppearance( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animalType == EAT_Pheasant )
		{
			SetAppearance( 'pheasant_01' );
		}
		
		return true;
	}
	
	event OnAnimEvent_SetWingsAppearance( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animalType == EAT_Pheasant )
		{
			SetAppearance( 'pheasant_01_wings' );
		}
		
		return true;
	}*/
	
	/*event OnIdleEnd()
	{
		if( animalType == EAT_Peacock )
		{
			SetAppearance( 'peacock_01' );
		}
	}*/
}

enum EAnimalType
{
	EAT_NotSet,
	EAT_Peacock,
	EAT_Pheasant
}