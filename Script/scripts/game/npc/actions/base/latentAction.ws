/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Actor latent scripted actions
/** Copyright © 2012
/***********************************************************************/

import abstract class IActorLatentAction extends IAIParameters
{
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		return NULL;
	}
}

import abstract class IPresetActorLatentAction extends IActorLatentAction
{
	import var resName : string;
}
