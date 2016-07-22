import class CSwitchableFoliageComponent extends CComponent
{
	private var currEntryName : name;

	public function SetAndSaveEntry( entryName : name )
	{
		currEntryName = entryName;
		SetEntry( currEntryName );
	}
	
	public function GetEntry() : name
	{
		return currEntryName;
	}

	// Set tree resource entry by name
	import private final function SetEntry( entryName : name );
}