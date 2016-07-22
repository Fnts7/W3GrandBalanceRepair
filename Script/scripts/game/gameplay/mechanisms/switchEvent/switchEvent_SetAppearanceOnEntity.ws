class W3SE_SetAppearanceOnEntity extends W3SwitchEvent
{
	editable var entityHandle : EntityHandle;
	editable var appearanceName : string;
	var entity : CEntity;
	
	hint entityHandle = "Entity on which we perform";
	hint appearanceName = "Appearance name to set";
	
	public function Perform( parnt : CEntity )
	{
		entity = EntityHandleGet( entityHandle );
						
		if ( !entity )
		{
			entity = parnt;
		}
		
		entity.ApplyAppearance( appearanceName );
	}
}