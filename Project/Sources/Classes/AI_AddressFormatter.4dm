Class extends AI_Agent

Class constructor($providerName : Text; $model : Text)
	Super($providerName; $model)
	
Function formatAddress($addressAsText : Text) : cs.address
	var $addressFormatterBot : cs.AIKit.OpenAIChatHelper
	var $expectedSchema : Object
	var $systemPrompt : Text
	var $prompt : Text
	var $AIResponse : Object
	var $result : Object
	var $address : cs.address
	
	$expectedSchema:={streetNumber: "number"; streetName: "street name"; apartment: "number"; builing: "building"; poBox: "po box"; city: "city"; region: "region"; postalCode: "postal code"; country: "country"}
	
	$systemPrompt:="I need you to properly format an address as a structured object. "+\
		"I provide you an address as plain text and you must provide me a well-formatted json object corresponding to this address. "+\
		"The resulting address should be nicely and properly capitalized: first letter of each attribute, and names of streets "+\
		"The json formatted address must have the following json schema: "+JSON Stringify($expectedSchema)+". "+\
		"While  not all address attributes are mandatory, a general rule for an address to be valid is:\n"+\
		"*- streetName AND(streetNumber OR building OR poBox)\n"+\
		"*- city\n"+\
		"*- postalCode\n"+\
		"*- country"
	
	$addressFormatterBot:=This.AIClient.chat.create($systemPrompt; {model: This.model})
	
	$prompt:="Here is the address to format into json "+String($addressAsText)
	$AIResponse:=$addressFormatterBot.prompt($prompt)
	$result:=This.getAIStructuredResponse($AIResponse; Is object)
	
	
	If ($result.success)
		$address:=cs.address.new($result.response)
		return $address
	Else 
		return Null
	End if 