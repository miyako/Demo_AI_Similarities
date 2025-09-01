property menu : Object

Class constructor($menu : Collection)
	
	This.menu:={}
	This.menu.values:=$menu
	This.menu.index:=0
	
Function onClicked() : cs.form
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="menu")
			FORM GOTO PAGE(This.menu.index+1)
	End case 
	
	return This
	
Function onPageChange() : cs.form
	
	return This
	
Function onDataChange() : cs.form
	
	return This
	
Function onSelectionChange() : cs.form
	
	return This