var $event : Object
$event:=FORM Event

Case of 
	: ($event.code=On Load)
		
		Form.onLoad()
		
	: ($event.code=On Clicked)
		
		Form.onClicked()
		
	: ($event.code=On Page Change)
		
		Form.onPageChange()
		
	: ($event.code=On Selection Change)
		
		Form.onSelectionChange()
		
	: ($event.code=On Data Change)
		
		Form.onDataChange()
		
End case 