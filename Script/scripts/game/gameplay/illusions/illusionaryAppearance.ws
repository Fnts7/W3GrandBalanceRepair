//----------------------------------------------------------------------
// W3IllusionaryAppearance
//----------------------------------------------------------------------
//>---------------------------------------------------------------------
// Entity that switches appearance when "Dispelled"
//----------------------------------------------------------------------
// Copyright © 2014 CDProjektRed
// Author : R.Pergent - 21-July-2014
//----------------------------------------------------------------------
class W3IllusionaryAppearance extends W3IllusionaryObstacle
{
	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	private editable var realAppearance			: string;
	
	default realAppearance = "true_form";
	default focusAreaIntensity	= 0.25f;
	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	public function Dispel()
	{
		PlayEffect('dissapear');
		AddTimer('DeactivateFocusArea', m_disappearanceEffectDuration, false, , , true);
		AddTimer('RemoveIllusion', m_disappearanceEffectDuration, false, , , true);
		FactsAdd( m_addFactOnDispel, 1 );
	}
	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	private timer function RemoveIllusion( _delta:float , id : int)
	{
		ApplyAppearance( realAppearance );
	}
}