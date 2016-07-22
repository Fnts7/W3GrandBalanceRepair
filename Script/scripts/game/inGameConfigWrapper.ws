import class CInGameConfigWrapper
{
	/* Groups - access by group CName */
	import final function GetGroupDisplayName( groupName : name ) : string;
	import final function GetGroupPresetsNum( groupName : name ) : int;
	import final function GetGroupPresetDisplayName( groupName : name, presetIdx : int ) : string;
	import final function ApplyGroupPreset( groupName : name, presetIdx : int );
	import final function ResetGroupToDefaults( groupName : name );
	
	/* Vars - access by var CName */
	import final function GetVarDisplayType( groupName : name, varName : name ) : string;
	import final function GetVarDisplayName( groupName : name, varName : name ) : string;
	import final function GetVarOptionsNum( groupName : name, varName : name ) : int;
	import final function GetVarOption( groupName : name, varName : name, optionIdx : int ) : string;
	import final function GetVarValue( groupCName : name, varCName : name ) : string;
	import final function SetVarValue( groupName : name, varName : name, varValue : string );
	import final function GetVarNameByGroupName( groupName : name, varIdx : int ) : name;
	import final function GetVarsNumByGroupName( groupName : name ) : int;
	import final function IsVarVisible( groupName : name, varName : name ) : bool;
	import final function DoVarHasTag( groupName : name, varName : name, tag : name ) : bool;
	
	/* List groups and vars - access by indices */
	import final function GetGroupsNum() : int;
	import final function GetGroupName( groupIdx : int ) : name;
	import final function GetVarsNum( groupIdx : int ) : int;
	import final function GetVarName( groupIdx : int, varIdx : int ) : name;
	import final function IsGroupVisible( groupName : name ) : bool;
	import final function DoGroupHasTag( groupName : name, tag : name ) : bool;
	
	/* General functions */
	import final function IsTagActive( tag : name ) : bool;
	import final function ActivateScriptTag( tag : name );
	import final function DeactivateScriptTag( tag : name );
}

function GetCurrentTextLocCode() : string
{
	var ingameConfigWrapper : CInGameConfigWrapper;
	var selectedIndex : int;
	
	ingameConfigWrapper = theGame.GetInGameConfigWrapper();
	selectedIndex = StringToInt(ingameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_text'), 0);
	
	return ingameConfigWrapper.GetVarOption('Localization', 'Virtual_Localization_text', selectedIndex);
}

struct SInGameConfigBufferedEntry
{
	var groupName : name;
	var varName : name;
	var varValue : string;
	var startValue : string;
}

class CInGameConfigBufferedWrapper
{
	public var inGameConfig : CInGameConfigWrapper;
	public var buffer : array<SInGameConfigBufferedEntry>;
	
	public function FillAppendWithGroup( groupName : name ) : void
	{
		var varsNum : int;
		var counter : int;
		var varValue : string;
		var bufferEntry : SInGameConfigBufferedEntry;
		var found : bool;
		var i : int;
		
		varsNum = inGameConfig.GetVarsNumByGroupName( groupName );
		
		bufferEntry.groupName = groupName;
		
		for( counter=0; counter<varsNum; counter+=1 )
		{
			bufferEntry.varName = inGameConfig.GetVarNameByGroupName( groupName, counter );
			found = false;
			
			// Look for the entry in buffer
			for( i=0; i<buffer.Size(); i+=1 )
			{
				if( buffer[i].groupName == bufferEntry.groupName && buffer[i].varName == bufferEntry.varName )
				{
					found = true;
					break;
				}
			}
			
			// Add only if not found
			if( found == false )
			{
				bufferEntry.varValue = inGameConfig.GetVarValue( groupName, bufferEntry.varName );
			
				buffer.PushBack( bufferEntry );
			}
		}
	}
	
	// Get buffered var value (or value from config system if there is no buffered entry for particular var)
	public function GetVarValue( groupName : name, varName : name ) : string
	{
		var i : int;
		
		// Look for the value in buffer
		for( i=0; i<buffer.Size(); i+=1 )
		{
			if( buffer[i].groupName == groupName && buffer[i].varName == varName )
			{
				return buffer[i].varValue;
			}
		}
		
		// Otherwise get from configs (that means that we have not set anything to that var in buffer)
		return inGameConfig.GetVarValue( groupName, varName );
	}
	
	// Set buffered var value
	public function SetVarValue( groupName : name, varName : name, varValue : string ) : void
	{
		var i : int;
		var bufferEntry : SInGameConfigBufferedEntry;
		var found : bool;
		
		found = false;
		// Look for the value in buffer
		for( i=0; i<buffer.Size(); i+=1 )
		{
			if( buffer[i].groupName == groupName && buffer[i].varName == varName )
			{
				buffer[i].varValue = varValue;
				found = true;
				break;
			}
		}
		
		// Otherwise create new buffer entry
		if( found == false )
		{
			bufferEntry.groupName = groupName;
			bufferEntry.varName = varName;
			bufferEntry.varValue = varValue;
			bufferEntry.startValue = inGameConfig.GetVarValue( groupName, varName );
			buffer.PushBack( bufferEntry );
		}
	}
	
	public function AnyBufferedVarHasTag(tag:name):bool
	{
		var i : int;
		
		// Look for the value in buffer
		for( i=0; i<buffer.Size(); i+=1 )
		{
			// We can ignore options that haven't actually changed
			if (inGameConfig.DoVarHasTag( buffer[i].groupName, buffer[i].varName, tag ) && buffer[i].startValue != buffer[i].varValue)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function ApplyNewValues() : void
	{
		var i : int;
		
		// Look for the value in buffer
		for( i=0; i<buffer.Size(); i+=1 )
		{
			inGameConfig.SetVarValue( buffer[i].groupName, buffer[i].varName, buffer[i].varValue );
		}
	}
	
	// Flush buffered configs to config system and clears the buffer
	public function FlushBuffer() : void
	{
		ApplyNewValues();
		
		buffer.Clear();
	}
	
	public function UndoAndFlushBuffer() : void
	{
		var i : int;
		
		// Look for the value in buffer
		for( i=0; i<buffer.Size(); i+=1 )
		{
			inGameConfig.SetVarValue( buffer[i].groupName, buffer[i].varName, buffer[i].startValue );
		}
		
		buffer.Clear();
	}
	
	// Check if there is anything to flush in the buffer
	public function IsEmpty() : bool
	{
		if( buffer.Size() > 0 )
		{
			return false;
		}
		
		return true;
	}
	
	// Clear buffer without flushing config values to config system
	public function ClearBuffer() : void
	{
		buffer.Clear();
	}
}
