/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for various math functions
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Types
/////////////////////////////////////////////

// 4 component vector
import struct Vector
{
	import var X,Y,Z,W : float;
}

// Euler angles, used for rotation, in degrees
import struct EulerAngles
{
	import var Pitch, Yaw, Roll : float;
}

// Matrix
import struct Matrix
{
	import var X,Y,Z,W : Vector;
}

// Bounding box
import struct Box
{
	import var Min, Max : Vector;		//points of diagonal
}

// Simple color
import struct Color
{
 	import var Red, Green, Blue, Alpha : byte;
};

// Sphere
import struct Sphere
{
	import var CenterRadius2 : Vector;
}

// Ranges
struct SRange
{
	editable var min : int;
	editable var max : int;
}
struct SRangeF
{
	editable var min : float;
	editable var max : float;
}

/////////////////////////////////////////////
// Scalar functions
/////////////////////////////////////////////

// Pi value
function Pi() : float
{
	return 3.14159265;
}

// Random value [min, Max-1]
import function RandRange( max : int, optional min : int ) : int;

// Random value [0, Max-1] different than lastValue if possible
import function RandDifferent( lastValue : int, optional range : int ) : int;

// Random value from <0, 1)
import function RandF() : float;

// Random value from given range [min, max]
import function RandRangeF( max : float, optional min : float ) : float;

// Random value from given range
import function RandNoiseF( seed : int, max : float, optional min : float ) : float;

// Absolute value
import function Abs( a : int ) : int;

// Minimum of two numbers
import function Min( a,b : int ) : int;

// Maximum of two numbers
import function Max( a,b : int ) : int;

// Clamp value to given range
import function Clamp( v, min, max : int ) : int;

// Convert between angles and radians
import function Deg2Rad( deg : float ) : float;

// Convert between radians and angle
import function Rad2Deg( rad : float ) : float;

// Absolute value
import function AbsF( a : float ) : float;

function SgnF( a : float ) : float
{
	if( a > 0 ) 
	{
		return 1.f;
	}
	return -1.f;
}

//float modulo
function ModF(a : float, b : float) : float
{
	if(b <= 0 || a <= 0)
		return 0;

	return a - FloorF(a / b) * b;
}

// Sinus (angle in radians)
import function SinF( a : float ) : float;

// Arcus Sinus
import function AsinF( a : float ) : float;

// Cosinus (angle in radians)
import function CosF( a : float ) : float;

// Arcus cosinus, result in radians
import function AcosF( a : float ) : float;

// Tangens (angle in radians)
import function TanF( a : float ) : float;

// Arcus tangens a/b
import function AtanF( a,b : float ) : float;

// Exponent (e^a)
import function ExpF( a : float ) : float;

// Power (a^x)
import function PowF( a,x : float ) : float;

// Natural logarithm of a
import function LogF( a : float ) : float;
 
// Square root from A
import function SqrtF( a : float ) : float;

// Squared A
import function SqrF( a : float ) : float;

// Make seed from object handle
import function CalcSeed( object : IScriptable ) : int;

// Minimum of two values
import function MinF( a,b : float ) : float;

// Maximum of two values
import function MaxF( a,b : float ) : float;

// Clamp value
import function ClampF( v, min, max : float ) : float;

// Interpolate
import function LerpF( alpha, a, b : float, optional clamp : bool ) : float;

// Round to nearest larger integer
import function CeilF( a : float ) : int;

// Round to nearest smaller integer
import function FloorF( a : float ) : int;

// Round to integer (simple cuts fractional part so it works as cast to int)
import function RoundF( a : float ) : int;

/**
	Round float to integer using math laws (if decimal part >=0.5 then rounds to nearest highest absolute value)
	RoundMath(2.7) = 3
	RoundMath(-2.7) = -3
*/	
function RoundMath(f : float) : int
{
	if(f==0)
	{
		return (int)f;
	}
	else if(f>0)
	{
		if(f-FloorF(f) >= 0.5)
			return CeilF(f);
		return FloorF(f);
	}
	else
	{
		if(f+FloorF(f) >= -0.5)
			return CeilF(f);
		return FloorF(f);
	}
}

//Rounds float to given number of decimals
//Not optimized at all, anyway this should be imported from C++ for better performance
function RoundTo(f : float, decimal : int) : float
{
	var i, digit : int;
	var ret : float;
	var isNeg : bool;

	if(decimal < 0)
		decimal = 0;

	ret = FloorF(AbsF(f));
	isNeg = false;
	if(f<0)
	{
		isNeg = true;		
		f *= -1;
	}
	f -= ret;
	
	for(i=0; i<decimal; i+=1)
	{
		f *= 10;
		digit = FloorF(f);
		ret += digit / PowF(10,i+1);
		f -= digit;
	}
	
	if(isNeg)
		ret *= -1;
		
	return ret;
}

// Reinterpret int data as float (needed for passing masks to Scaleform)
import function ReinterpretIntAsFloat( a : int ) : float;

/////////////////////////////////////////////
// Angle functions
/////////////////////////////////////////////

// Normalize angle to 0 - 360 range
import function AngleNormalize( a : float ) : float;

// Normalize angle to -180 - 180 range
function AngleNormalize180( a : float ) : float
{
	if( a >= -180 && a <= 180 )
	{
		return a;
	}
	else if( a < -360 || a > 360 )
	{
		a = AngleNormalize( a );
	}
	if ( a > 180.f )
	{
		a -= 360.f;
	}
	else if ( a < -180.f )
	{
		a += 360.f;
	}
	return a;
}

// Interpolate angle
function LerpAngleF( alpha, a, b : float ) : float
{
	return a + AngleDistance( b, a ) * alpha;
}

// Get distance between angles ( result in -180 to 180 range )
import function AngleDistance( target, current : float ) : float;

// Approach target angle with given step
import function AngleApproach( target, cur, step : float ) : float;

// Get angle distance between nodes ( result in -180 to 180 range )
function NodeToNodeAngleDistance( target, current : CNode ) : float
{
	return -AngleDistance( VecHeading(  target.GetWorldPosition() - current.GetWorldPosition() ), current.GetHeading() );
}

/////////////////////////////////////////////
// Vector functions
/////////////////////////////////////////////

// Calculate 2 component dot product of two vectors
import function VecDot2D( a, b : Vector ) : float;

// Calculate 3 component dot product of two vectors
import function VecDot( a, b : Vector ) : float;

// Calculate cross product of two vectors
import function VecCross( a, b : Vector ) : Vector;

// Calculate 2D length of Vector
import function VecLength2D( a : Vector ) : float;

// Calculate 3D length squared of Vector
import function VecLengthSquared( a : Vector ) : float;

// Calculate 3D length of Vector
import function VecLength( a : Vector ) : float;

// Return 2D normalized Vector 
import function VecNormalize2D( a : Vector ) : Vector;

// Return 3D normalized Vector 
import function VecNormalize( a : Vector ) : Vector;

// Return 2D random Vector
import function VecRand2D() : Vector;

// Return 3D random Vector
import function VecRand() : Vector;

// Random position in ring on XY plane
function VecRingRand( minRadius, maxRadius : float ) : Vector
{	
	var r, angle : float;	
	r = RandRangeF( maxRadius, minRadius );
	angle = RandRangeF( 6.28318530 );	//2 Pi?
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}

// Random position in cone on XY plane
function VecConeRand( coneDir, coneAngle, minRadius, maxRadius : float ) : Vector
{	
	var r, angle, angleMin, angleMax : float;
	r = RandRangeF( maxRadius, minRadius );
	angleMin = Deg2Rad( coneDir - ( coneAngle * 0.5 ) + 90 );
	angleMax = Deg2Rad( coneDir + ( coneAngle * 0.5 ) + 90 );
	angle = RandRangeF( angleMax, angleMin );
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}

// Random position in ring on XY plane
function VecRingRandStatic( seed : int, minRadius, maxRadius : float ) : Vector
{	
	var r, angle : float;	
	r = RandNoiseF( seed, maxRadius, minRadius );
	angle = RandNoiseF( seed, 6.28318530 );
	return Vector( r*CosF( angle ), r*SinF( angle ), 0.0, 1.0 );
}

// Mirror vector by given normal
import function VecMirror( dir, normal : Vector ) : Vector;

// Calculate 3D distance between two vectors
import function VecDistance( from, to : Vector ) : float;

// Calculate squared 3D distance between two vectors
import function VecDistanceSquared( from, to : Vector ) : float;

// Calculate 2D distance between two vectors
import function VecDistance2D( from, to : Vector ) : float;

// Calculate squared 2D distance between two vectors
import function VecDistanceSquared2D( from, to : Vector ) : float;

// Calculate distance to edge
import function VecDistanceToEdge( point, a, b : Vector ) : float;

// Calculate nearest point on edge
import function VecNearestPointOnEdge( point, a, b : Vector ) : Vector;

// Calculate rotation that transforms "forward" to given vector
import function VecToRotation( dir : Vector ) : EulerAngles;

// Calculate yaw rotation ( heading )that transforms "forward" to given vector
import function VecHeading( dir : Vector ) : float;

// Calculate vector from heading ( yaw rotation )
import function VecFromHeading( heading : float ) : Vector;

// Transform vector as point by given matrix
import function VecTransform( m : Matrix, point : Vector ) : Vector;

// Transform vector as direction by given matrix
import function VecTransformDir( m : Matrix, point : Vector ) : Vector;

// Transform 4 component vector and project back by diving by W component
import function VecTransformH( m : Matrix, point : Vector ) : Vector;

// Calculate angle between vectors, returns value in deg. You don't have to normalize input vectors.
import function VecGetAngleBetween( from : Vector, to : Vector ) : float;

// Calculate angle between vectors around axis, returns value in deg. You don't have to normalize input vectors.
import function VecGetAngleDegAroundAxis( dirA : Vector, dirB : Vector, axis : Vector ) : float;

// Projects point to Project on a plane given by 3 points. Return projected point.
import function VecProjectPointToPlane( p1 : Vector, p2 : Vector, p3 : Vector, toProject : Vector ) : Vector;

// Rotates the vector angle degrees around the axis
import function VecRotateAxis( vector : Vector, axis : Vector, angle : float ) : Vector;

function VecRotByAngleXY(vec : Vector, angleDeg : float) : Vector
{
	var ret : Vector;
	var angle : float;
	
	angle = Deg2Rad(angleDeg);
	ret = vec;
	ret.X 	= 	vec.X*CosF( -angle ) - vec.Y*SinF( -angle );
	ret.Y 	= 	vec.X*SinF( -angle ) + vec.Y*CosF( -angle );
	
	return ret;
}

function VecInterpolate( v1, v2 : Vector, ratio : float ) : Vector
{
	var dir : Vector;
	
	dir = v2 - v1;
	
	return v1 + dir * ratio;
}

// Convert vector to string
function VecToString( vec : Vector ) : string
{
	return vec.X + " " + vec.Y + " " + vec.Z + " " + vec.W;
}

function VecToStringPrec( vec : Vector, precision : int ) : string
{
	return FloatToStringPrec( vec.X, precision ) + " " + FloatToStringPrec( vec.Y, precision ) + " " + FloatToStringPrec( vec.Z, precision ) + " " + FloatToStringPrec( vec.W, precision );
}

/////////////////////////////////////////////
// EulerAngles functions
/////////////////////////////////////////////

// Constructor. WATCH OUT FOR DIFFERENT PARAMETERS ORDER
// EulerAngles( pitch, yaw, roll )

// Get X axis for given rotation
import function RotX( rotation : EulerAngles ) : Vector;

// Get Y axis for given rotation
import function RotY( rotation : EulerAngles ) : Vector;

// Get Z axis for given rotation
import function RotZ( rotation : EulerAngles ) : Vector;

// Get the forward direction for given rotation
import function RotForward( rotation : EulerAngles ) : Vector;

// Get the right direction for given rotation
import function RotRight( rotation : EulerAngles ) : Vector;

// Get the up direction for given rotation
import function RotUp( rotation : EulerAngles ) : Vector;

// Convert euler angles to matrix
import function RotToMatrix( rotation : EulerAngles ) : Matrix;

// Decompose rotator into axes
import function RotAxes( rotation : EulerAngles, out foward, right, up : Vector );

// Calculate dot product betwen two rotations ( i.e. dot product between forward vectors of rotations )
import function RotDot( a, b : EulerAngles );

// Calculate random rotation
import function RotRand( min, max : float ) : EulerAngles;

//gets opposite rotation (opposite direction), angle range 0-360
function GetOppositeRotation180(rot : EulerAngles) : EulerAngles
{
	var ret : EulerAngles;
	
	ret.Pitch = AngleNormalize180(rot.Pitch + 180);
	ret.Yaw = AngleNormalize180(rot.Yaw + 180);
	ret.Roll = AngleNormalize180(rot.Roll + 180);
	
	return ret;	
}
/////////////////////////////////////////////
// Matrix functions
/////////////////////////////////////////////

// Build identity matrix
import function MatrixIdentity() : Matrix;

// Build translation matrix
import function MatrixBuiltTranslation( move : Vector ) : Matrix;

// Build rotation matrix
import function MatrixBuiltRotation( rot : EulerAngles ) : Matrix;

// Build scale matrix
import function MatrixBuiltScale( scale : Vector ) : Matrix;

// Build prescale matrix
import function MatrixBuiltPreScale( scale : Vector ) : Matrix;

// Build TRS matrix
import function MatrixBuiltTRS( optional translation : Vector, optional rotation : EulerAngles, optional scale : Vector ) : Matrix;

// Build RTS matrix
import function MatrixBuiltRTS( optional rotation : EulerAngles, optional translation : Vector, optional scale : Vector ) : Matrix;

// Build matrix with EY from given direction vector
import function MatrixBuildFromDirectionVector( dirVec : Vector ) : Matrix;

// Extract translation from matrix
import function MatrixGetTranslation( m : Matrix  ) : Vector;

// Extract rotation from matrix
import function MatrixGetRotation( m : Matrix ) : EulerAngles;

// Extract scale from matrix
import function MatrixGetScale( m : Matrix ) : Vector;

// Get axis X
import function MatrixGetAxisX( m : Matrix ) : Vector;

// Get axis Y
import function MatrixGetAxisY( m : Matrix ) : Vector;

// Get axis Z
import function MatrixGetAxisZ( m : Matrix ) : Vector;

// Get direction vector (axis Y)
import function MatrixGetDirectionVector( m : Matrix ) : Vector;

// Get inverted matix
// Attention: Result will be wrong if the matrix is scaled!
import function MatrixGetInverted( m : Matrix  ) : Matrix;

/////////////////////////////////////////////
// Box functions
/////////////////////////////////////////////

function GetBoxSize( box : Box ) : Vector
{
	return box.Max - box.Min;
}

function GetBoxExtents( box : Box ) : Vector
{
	return ( box.Max - box.Min ) * 0.5f;
}

function GetBoxRange( box : Box ) : float
{
	var size : Vector;
	size = GetBoxExtents( box );
	if ( size.X > size.Y )
	{
		if ( size.X > size.Z )
		{
			return size.X;
		}
	}
	else
	{
		if ( size.Y > size.Z )
		{
			return size.Y;
		}
	}
	return size.Z;
}

/////////////////////////////////////////////
// Sphere functions
/////////////////////////////////////////////

// Check if ray intersects sphere: 0 not found, 1 only exits (enterPoint same as origin), 2 enters and exits
import function SphereIntersectRay( sphere : Sphere, orign : Vector, direction : Vector, out enterPoint : Vector, out exitPoint : Vector ) : int;

// Check edge-sphere intersection, returs number of intersection points
import function SphereIntersectEdge( sphere : Sphere, a : Vector, b : Vector, out intersectionPoint0 : Vector, out intersectionPoint1 : Vector ) : int;

/////////////////////////////////////////////
// Conversions
/////////////////////////////////////////////
import function Int8ToInt( i : Int8 ) : int;
import function IntToInt8( i : int ) : Int8;

import function IntToUint64( i : int ) : Uint64;
import function Uint64ToInt( i : Uint64 ) : int;
