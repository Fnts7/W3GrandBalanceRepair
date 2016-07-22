//for use in arrays
struct SItem
{
	editable var itemName : name;
	editable var quantity : int;
		default quantity = 1;
};

enum EQuestSword
{
	EQS_Any,
	EQS_Steel,
	EQS_Silver
}

struct SGlossaryImageOverride
{
	var uniqueTag : name;
	var imageFileName : string;
}

