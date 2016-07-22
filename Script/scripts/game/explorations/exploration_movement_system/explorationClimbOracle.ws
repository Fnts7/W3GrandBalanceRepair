// CExplorationStateClimb
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 13/08/2014 )	 
//------------------------------------------------------------------------------------------------------------------

enum EClimbProbeUsed
{
	ECPU_None	,
	ECPU_Top	,
	ECPU_Bottom	,
}

//>-----------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
class CExplorationClimbOracle
{	
	private						var	m_ExplorationO			: CExplorationStateManager;
	
	private						var	probeTop				: CClimbProbe;
	private						var	probeBottom				: CClimbProbe;
	
	// Distances
	private editable			var	distForwardToCheck		: float;				default	distForwardToCheck		= 0.5f;
	private editable			var characterRadius			: float;				default characterRadius			= 0.3f;
	private editable			var characterHeight			: float;				default characterHeight			= 1.8f;
	private editable			var	radiusToCheck			: float;				default	radiusToCheck			= 0.3f;
	
	// Top bottom checks
	private	editable			var bottomCheckAllowed		: bool;					default	bottomCheckAllowed		= true;
	private						var topIsPriority			: bool;
	private						var probeBeingUsed			: EClimbProbeUsed;	
	
	// Debug
	private						var	debugLogFails			: bool;
	
	//Aux
	private						var	vectorUp				: Vector;
	
	
	//---------------------------------------------------------------------------------
	public function Initialize( explorationO : CExplorationStateManager, heightMin : float, heightMax : float, platformHeihtMin : float, radius : float )
	{
		m_ExplorationO	= explorationO;
		
		// Probes
		if( !probeTop )
		{
			probeTop	= new CClimbProbe in this;
		}
		if( !probeBottom )
		{
			probeBottom	= new CClimbProbe in this;
		}
		probeTop.Initialize( heightMin, heightMax, platformHeihtMin, radius, 1, true );
		probeBottom.Initialize( heightMin, heightMax, platformHeihtMin, radius, 2, false );
		
		// Init aux
		vectorUp	= Vector( 0.0f,0.0f, 1.0f );
	}
	
	//---------------------------------------------------------------------------------
	public function ComputeAll( ptriorizeTop : bool, position : Vector, directionNormalized : Vector, distanceType : EClimbDistanceType, requireInputDir : bool, logFails : bool )
	{		
		var requireInput	: bool;
		
		
		debugLogFails	= logFails; 
		
		topIsPriority	= ptriorizeTop;
		
		probeTop.PreUpdate( position, directionNormalized, requireInputDir, distanceType, logFails );
		probeBottom.PreUpdate( position, directionNormalized, requireInputDir, distanceType, logFails );
		
		
		probeBeingUsed	= ComputeConvenientClimb();
	}
	
	//---------------------------------------------------------------------------------
	public function CanWeClimb() : bool
	{
		switch( probeBeingUsed )
		{
			case ECPU_None	:
				return false;
				
			case ECPU_Top :
				return probeTop.IsValid();
				
			case ECPU_Bottom :
				return probeBottom.IsValid();
		}
	}
	
	//---------------------------------------------------------------------------------
	public function GetClimbData( out height : float, out vault : EClimbRequirementVault, out vaultFalls : bool, out platform : EClimbRequirementPlatform, out climbPoint : Vector, out wallNormal : Vector )
	{
		switch( probeBeingUsed )
		{
			case ECPU_None	:
				LogExplorationClimb(" Trying to get climb data when there is no valid data" );
				break;
				
			case ECPU_Top :
				probeTop.GetClimbData( height, vault, vaultFalls, platform, climbPoint, wallNormal );
				break;
				
			case ECPU_Bottom :
				probeBottom.GetClimbData( height, vault, vaultFalls, platform, climbPoint, wallNormal );
				break;
		}
	}
	
	//---------------------------------------------------------------------------------
	private function ComputeConvenientClimb() : EClimbProbeUsed
	{				
		// We start from the top and we'll use some of its data to compute the bottom check as well
		probeTop.ComputeStartup();
		
		if( !probeTop.IsSetupValid() )
		{
			return ECPU_None;
		}
		
		// Start trying top
		if( topIsPriority )
		{
			probeTop.ComputeClimbDetails();
			if( probeTop.IsValid() )
			{
				return ECPU_Top;
			}
			
			// If not valid, try bottom one
			else if( bottomCheckAllowed )
			{	
				probeBottom.ComputeStartupFromThisPoint( probeTop.GetGroundPoint() );
				probeBottom.ComputeClimbDetails();
				
				if( probeBottom.IsValid() )
				{
					return ECPU_Bottom;
				}
			}
		}
		
		// Start trying bottom
		else 
		{
			if( bottomCheckAllowed )
			{		
				probeBottom.ComputeStartupFromThisPoint( probeTop.GetGroundPoint() );
				probeBottom.ComputeClimbDetails();
				
				if( probeBottom.IsValid() )
				{
					return ECPU_Bottom;
				}
			}
			
			// If not valid, finish trying the top one
			probeTop.ComputeClimbDetails();
			if( probeTop.IsValid() )
			{
				return ECPU_Top;
			}
		}
		
		return ECPU_None;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		if( !probeTop.IsValid() && probeBottom.IsValid() )
		{
			probeBottom.OnVisualDebug( frame, flag, active );
		}
		else
		{		
			probeTop.OnVisualDebug( frame, flag, active );
		}
		
		return true;
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function DebugLogSuccesfullClimb()
	{
		var auxText	: string;
		
		
		if( probeBeingUsed	== ECPU_Top )
		{
			auxText	= "Used Top climb ";
			if( !topIsPriority  )
			{
				auxText	+= "cause bottom climb is not available ";
			}
			auxText	+= probeTop.GetDebugText();
		}
		else if( probeBeingUsed	== ECPU_Bottom )
		{
			auxText	= "Used Bottom climb ";
			if( topIsPriority )
			{
				auxText	+= "cause top climb is not available ";
			}
			auxText	+= probeBottom.GetDebugText();
		}
		
		LogExplorationClimb( auxText );
	}
}
