Class extends AI_Agent

property expectedSchema : Object
property formatterSystemPrompt : Text

Class constructor($providerName : Text; $model : Text)
	
	Super($providerName; $model)
	
	This.expectedSchema:={streetNumber: "number"; streetName: "street name"; apartment: "number"; builing: "building"; poBox: "po box"; city: "city"; region: "region"; postalCode: "postal code"; country: "country"}
	
	This.formatterSystemPrompt:="I need you to properly format an address as a structured object. "+\
		"I provide you an address as plain text and you must provide me a well-formatted json object corresponding to this address. "+\
		"The resulting address should be nicely and properly capitalized: first letter of each attribute, and names of streets "+\
		"The json formatted address must have the following json schema: "+JSON Stringify(This.expectedSchema)+". "+\
		"While  not all address attributes are mandatory, a general rule for an address to be valid is:\n"+\
		"*- streetName AND(streetNumber OR building OR poBox)\n"+\
		"*- city\n"+\
		"*- postalCode\n"+\
		"*- country"