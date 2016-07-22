enum EInterpCurveMode
{
	//
	CIM_Constant,
	// straight line between two keypoints.
	CIM_Linear,
	// A cubic-hermite curve between two keypoints, uses arrive/leave tangents.
	CIM_CurveAuto,
	// 
	CIM_CurveBreak,
};


class InterpCurvePoint
{
	var inVal : float;
	
	var interpMode : EInterpCurveMode;
	
	function InterpCurvePoint(){}
	
	function IsCurveKey() : bool
	{	
		return( interpMode == CIM_CurveAuto
				|| interpMode == CIM_CurveBreak );
	}
}


class InterpCurvePointF extends InterpCurvePoint
{
	var outVal : float;
	
	var arriveTangent : float;
	var leaveTangent : float;	
}


class InterpCurvePointV extends InterpCurvePoint
{
	var outVal : Vector;
	
	var arriveTangent : Vector;
	var leaveTangent : Vector;
}