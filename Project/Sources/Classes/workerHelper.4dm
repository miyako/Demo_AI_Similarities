singleton Class constructor()
	
/**
* Generating customers
**/
Function generateCustomers($formObject : Object; $window : Integer)
	var $customerGenerator : cs.AI_DataGenerator
	var $formulaCallback : 4D.Function
	
	$customerGenerator:=cs.AI_DataGenerator.new($formObject.providersGen.currentValue; $formObject.modelsGen.currentValue)
	$customerGenerator.generateCustomers($formObject.actions.generatingCustomers.quantity; $formObject.actions.generatingCustomers.quantityBy; {window: $window; formula: Formula($formObject.progressGenerateCustomers($1))})
	$customerGenerator.populateAddresses(10; {window: $window; formula: Formula($formObject.progressGenerateCustomers($1))})
	CALL FORM($window; Formula($formObject.terminateGenerateCustomers()))
	
/**
* Vectorize
**/
Function vectorizeCustomers($formObject : Object; $window : Integer)
	ds.customer.vectorizeAll($formObject.providersEmb.currentValue; $formObject.modelsEmb.currentValue; {window: $window; formula: Formula($formObject.progressVectorizing($1))})
	CALL FORM($window; Formula($formObject.terminateVectorizing()))
	
	
/**
* Generate a random customer
**/
Function generateCustomer($formObject : Object; $window : Integer)
	var $customerGenerator : cs.AI_DataGenerator
	var $customerObject : Object
	var $startMillisecond; $timing : Integer
	
	$customerGenerator:=cs.AI_DataGenerator.new($formObject.providersGen.currentValue; $formObject.modelsGen.currentValue)
	$startMillisecond:=Milliseconds
	$customerObject:=$customerGenerator.generateRandomCustomerObject()
	$timing:=Milliseconds-$startMillisecond
	CALL FORM($window; Formula($formObject.terminateGenerateCustomer($customerObject; $timing)))
	
/**
* Format an address
**/
Function formatAddress($formObject : Object; $window : Integer)
	var $addressFormatter : cs.AI_AddressFormatter
	var $address : cs.address
	var $startMillisecond; $timing : Integer
	
	$addressFormatter:=cs.AI_AddressFormatter.new($formObject.providersGen.currentValue; $formObject.modelsGen.currentValue)
	$startMillisecond:=Milliseconds
	$address:=$addressFormatter.formatAddress($formObject.actions.formattingAddress.textToFormat)
	$timing:=Milliseconds-$startMillisecond
	CALL FORM($window; Formula($formObject.terminateAddressFormatting($address; $timing)))
	
	
/**
* Search similar customers for a customer (as object)
**/
	
Function searchSimilarCustomers($formObject : Object; $customerObject : Object; $window : Integer)
	var $startMillisecond; $timing : Integer
	var $customer : cs.customerEntity
	var $similarCustomers : Collection
	
	$customer:=ds.customer.newCustomerFromObject($customerObject)
	$startMillisecond:=Milliseconds
	$similarCustomers:=$customer.searchSimilarCustomers($formObject.actions.searchingSimilarities.similarityLevel/100)
	$timing:=Milliseconds-$startMillisecond
	
	CALL FORM($window; Formula($formObject.terminateSearchSimilarCustomers($similarCustomers; $timing)))