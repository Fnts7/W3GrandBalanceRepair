/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Node class
/////////////////////////////////////////////

import class CNode extends CObject
{
	// Get node name
	import final function GetName() : string;
	
	// Get node local position
	import final function GetLocalPosition() : Vector;
	
	// Get node local rotation
	import final function GetLocalRotation() : EulerAngles;
	
	// Get node local scale
	import final function GetLocalScale() : Vector;
	
	// Get node local to world matrix
	import final function GetLocalToWorld() : Matrix;
	
	// Get node world position
	import final function GetWorldPosition() : Vector;
	
	// Get node world rotation
	import final function GetWorldRotation() : EulerAngles;
	
	// Get node world Forward
	import final function GetWorldForward() : Vector;
	
	// Get node world Right
	import final function GetWorldRight() : Vector;
	
	// Get node world Up
	import final function GetWorldUp() : Vector;
	
	// Get node heading ( world rotation yaw )
	import final function GetHeading() : float;
	
	// Get node heading vector ( Y axis )
	import final function GetHeadingVector() : Vector;
	
	// Return true is node has given tag
	import final function HasTag( tag : name ) : bool;
	
	// Get node tags
	import final function GetTags() : array< name >;
	
	// Set node tags
	import final function SetTags( tags : array< name > );
	
	// Get node tags as string
	import final function GetTagsString() : string;
			
	public function AddTag(tag : name)
	{
		var tags : array<name>;
	
		tags = GetTags();
		ArrayOfNamesPushBackUnique(tags, tag);
		SetTags(tags);		
	}
}

// Get node closest to position
import function FindClosestNode( position : Vector, nodes : array< CNode > ) : CNode;

// Sort nodes by distance to position (closest at index 0)
import function SortNodesByDistance( position : Vector, out nodes : array< CNode > );