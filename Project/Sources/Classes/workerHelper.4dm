singleton Class constructor()
	
Function formatAddress($formObject : Object; $window : Integer)
	var $addressFormatter : cs.AI_AddressFormatter
	var $address : cs.address
	var $startMillisecond; $timing : Integer
	
	$addressFormatter:=cs.AI_AddressFormatter.new($formObject.providersGen.currentValue; $formObject.modelsGen.currentValue)
	$startMillisecond:=Milliseconds
	$address:=$addressFormatter.formatAddress($formObject.actions.formattingAddress.textToFormat)
	$timing:=Milliseconds-$startMillisecond
	CALL FORM($window; Formula($formObject.terminateAddressFormatting($address; $timing)))
	
	