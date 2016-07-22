/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Resource functions
/** Copyright © 2009
/***********************************************************************/

// Load a resource synchronously by alias from xml definition or using depot path
import function LoadResource( resource : string, optional isDepotPath : bool ) : CResource;

// Load resource latent version
import latent function LoadResourceAsync( resource : string, optional isDepotPath : bool ) : CResource;

/////////////////////////////////////////////
// CResource class
/////////////////////////////////////////////
import class CResource extends CObject
{
	import final function GetPath() : string;
}
