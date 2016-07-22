//>--------------------------------------------------------------------------
// BTTaskManageSplashEffect
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Spawn a splash effect when the NPC cross the water level
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 15-August-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskManageSplashEffect extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	private var m_SplashEntityTemplate 			: CEntityTemplate;
	private var m_PreviousDistanceFromSurface 	: float;
	
	private var m_CrossedOnce					: bool;
	
	private var couldntLoadResource : bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	
	function IsAvailable() : bool
	{
		if ( couldntLoadResource )
		{
			return false;
		}
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{	
		var l_distanceFromSurface 	: float;
		var l_waterDepth 			: float;
		var l_pos					: Vector;
		
		if ( !m_SplashEntityTemplate )
			m_SplashEntityTemplate = (CEntityTemplate) LoadResourceAsync('water_splashes');
		
		if ( !m_SplashEntityTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		l_pos = GetNPC().GetWorldPosition();
		
		l_waterDepth = theGame.GetWorld().GetWaterDepth( l_pos );
		if( l_waterDepth > 1000 ) l_waterDepth = 0;
		
		if( l_waterDepth < 1 ) m_CrossedOnce = true;
		
		while( GetNPC().IsAlive() || !m_CrossedOnce )
		{		
			l_distanceFromSurface = DistanceFromWaterSurface();
			
			// Detect if I cross the surface:
			// if sign of multi is negative, it means the two numbers have opposite signs.
			if( m_PreviousDistanceFromSurface != 0 && l_distanceFromSurface * m_PreviousDistanceFromSurface < 0 )
			{
				SpawnWaterSplash();
				m_CrossedOnce = true;
			}
			
			// Safety in case this is task is launched once the npc is already dead below water
			if( !GetNPC().IsAlive() && l_distanceFromSurface < 0 )
			{				
				m_CrossedOnce = true;
			}
			
			m_PreviousDistanceFromSurface = DistanceFromWaterSurface();
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function DistanceFromWaterSurface() : float
	{
		var l_position 		: Vector;
		var l_world 		: CWorld;
		var l_waterLevel 	: float;
		
		l_world 		= theGame.GetWorld();		
		l_position 		= GetNPC().GetWorldPosition();		
		l_waterLevel 	= l_world.GetWaterLevel( l_position );		
		
		return ( l_position.Z - l_waterLevel );
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function SpawnWaterSplash( )
	{
		var l_splashPosition 	: Vector;
		var l_splastEntity		: CEntity;
		
		l_splashPosition 	= GetNPC().GetWorldPosition();
		l_splashPosition.Z 	= theGame.GetWorld().GetWaterLevel( l_splashPosition ) - 0.1;
		
		l_splastEntity = theGame.CreateEntity( m_SplashEntityTemplate, l_splashPosition, GetNPC().GetWorldRotation());
		
		//GetNPC().GetVisualDebug().AddSphere( 'Splash', 1, l_splashPosition, true, Color(0,0,255) );
		//GetNPC().GetVisualDebug().AddArrow( 'Splasharrow', GetNPC().GetWorldPosition(), l_splashPosition, 1.f, 0.2f, 0.2f, true, Color(0,0,255), true, 5.f );
	}

}


//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskManageSplashEffectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageSplashEffect';
}
