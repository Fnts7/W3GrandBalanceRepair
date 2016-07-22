import class CAppearanceComponent extends CComponent
{
	import final function IncludeAppearanceTemplate(template : CEntityTemplate); 
	import final function ExcludeAppearanceTemplate(template : CEntityTemplate); 
	
	// Selects a different appearance for the entity.
	import final function ApplyAppearance( appearanceName : string );
}



function GetAppearanceNames2( path : string, output : array< name> ) 
{
	var temp : CEntityTemplate;
	temp = (CEntityTemplate)LoadResource( path, true );
	return GetAppearanceNames( temp, output );	
}

import function GetAppearanceNames( template : CEntityTemplate, output : array< name> );