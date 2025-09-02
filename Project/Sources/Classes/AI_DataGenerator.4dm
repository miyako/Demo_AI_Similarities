property customerExpectedSchema : Object
property addressExpectedSchema : Object
property singleCustomerExpectedSchema : Object
property customerColExpectedSchema : Collection
property addressColExpectedSchema : Collection
property customerSystemPrompt : Text
property addressSystemPrompt : Text
property singleCustomerSystemPrompt : Text

Class extends AI_Agent

Class constructor($providerName : Text; $model : Text)
	
	Super($providerName; $model)
	
	This.customerExpectedSchema:={firstname: "firstname"; lastname: "lastname"; email: "firstname.lastname@randomdomain.com"; phone: "random phone number"}
	This.addressExpectedSchema:={streetNumber: "number"; streetName: "street name"; apartment: "number"; builing: "building"; poBox: "po box"; city: "city"; region: "region"; postalCode: "postal code"; country: "country"}
	This.customerColExpectedSchema:=[This.customerExpectedSchema]
	This.addressColExpectedSchema:=[This.addressColExpectedSchema]
	This.singleCustomerExpectedSchema:=OB Copy(This.customerExpectedSchema)
	This.singleCustomerExpectedSchema.address:=OB Copy(This.addressExpectedSchema)
	
	This.customerSystemPrompt:="You are a data generating assistant. Your answers are used to populate a database. Your answers are stricly JSON formatted, no greetings, no conclusion, just pure json."+\
		"I will ask you to generate json arrays to populate a customer table. "+\
		"I will just ask you to generate a certain amount of records, and you will provide me the answer as a json array. "+\
		"The json array must have the following schema, here provided for 1 customer: "+JSON Stringify(This.customerExpectedSchema)+". "+\
		"avoid generic names like john doe, prefer realistic ones. "+\
		"avoid generic email domains like example.com, prefer realistic ones."
	This.addressSystemPrompt:="You are a data generating assistant. Your answers are used to populate a database. Your answers are stricly JSON formatted, no greetings, no conclusion, just pure json."+\
		"I will ask you to generate json arrays of structured address objects. "+\
		"I will just ask you to generate a certain amount of records, and you will provide me the answer as a json array. "+\
		"The json array must have the following schema, here provided for 1 address: "+JSON Stringify(This.addressExpectedSchema)+". "+\
		"Note that not all address attributes are mandatory."
	This.singleCustomerSystemPrompt:="You are a data generating assistant. Your answers are used to populate a database. Your answers are stricly JSON formatted, no greetings, no conclusion, just pure json."+\
		"I will ask you to generate a json object to populate a customer table. "+\
		"The json object must have the following schema: "+JSON Stringify(This.singleCustomerExpectedSchema)+". "+\
		"avoid generic names like john doe, prefer realistic ones. "+\
		"avoid generic email domains like example.com, prefer realistic ones. "+\
		"Note that not all address attributes are mandatory."
	
Function generateRandomCustomerObject() : Object
	var $customerGenBot : cs.AIKit.OpenAIChatHelper
	var $addressGenBot : cs.AIKit.OpenAIChatHelper
	var $prompt : Text
	var $AIResponse : Object
	var $result : Object
	
	$customerGenBot:=This.AIClient.chat.create(This.singleCustomerSystemPrompt; {model: This.model})
	$prompt:="generate 1 customer"
	$AIResponse:=$customerGenBot.prompt($prompt)
	$result:=This.getAIStructuredResponse($AIResponse; Is object)
	If ($result.success)
		return $result.response
	Else 
		return {}
	End if 
	
Function generateRandomCustomer() : cs.customerEntity
	var $customerObject : Object
	
	$customerObject:=This.generateRandomCustomerObject()
	return ds.customer.newCustomerFromObject($customerObject)