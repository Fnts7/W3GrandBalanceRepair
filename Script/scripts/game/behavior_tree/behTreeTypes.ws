/*
enum EBTNodeStatus
{
	BTNS_Invalid,
	BTNS_New,
	BTNS_Active,
	BTNS_Failed,
	BTNS_Completed,
	BTNS_Aborted,
	BTNS_RepeatTree,	
};
*/

class W3BehTreeValNameArray extends IScriptable
{
	editable var nameArray : array<name>;
	
	public function GetArray() : array<name>
	{
		return nameArray;
	}
}