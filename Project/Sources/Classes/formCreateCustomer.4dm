Class extends formVectorize

property providersGen : Object
property modelsGen : Object
property newCustomer : cs.customerEntity
property possibleDuplicateCustomers : Collection
property actions : Object

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Create Customers 🪄"))
	
	This.newCustomer:=ds.customer.new()
	This.newCustomer.address:=cs.address.new()
	This.possibleDuplicateCustomers:=[]
	
	//MARK: form events & callbacks
	
Function onAddressFormatted($chatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult)
	
	If (Form#Null)
		OBJECT SET VISIBLE(*; "addressFormattingSpinner"; False)
		var $result : Object
		$result:=Form.getAIStructuredResponse($chatCompletionsResult; Is object)
		Form.newCustomer.address:=cs.address.new($result.response)
		Form.refreshStatus()
	End if 
	
Function onRandomCustomerGenerated($chatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult)
	
	If (Form#Null)
		OBJECT SET VISIBLE(*; "customerGenMessage"; False)
		OBJECT SET VISIBLE(*; "customerGenSpinner@"; False)
		var $result : Object
		$result:=Form.getAIStructuredResponse($chatCompletionsResult; Is object)
		Form.newCustomer:=ds.customer.newCustomerFromObject($result.response)
		Form.refreshStatus()
	End if 
	
Function onCustomerVectorizedForSearch($embeddingsResult : cs.AIKit.OpenAIEmbeddingsResult)
	
	If (Form#Null)
		If ($embeddingsResult.success)
			var $similarCustomersCol : Collection:=[]
			var $targetSimilarity : Real
			$targetSimilarity:=$embeddingsResult.request.headers.similarity
			var $vector : 4D.Vector
			$vector:=$embeddingsResult.vector
			
			var $customer : cs.customerEntity
			var $similarity : Real
			For each ($customer; ds.customer.query("vector != null"))
				$similarity:=$vector.cosineSimilarity($customer.vector)
				If ($similarity>=$targetSimilarity)
					$similarCustomersCol.push({entity: $customer; customerID: $customer.ID; similarity: $similarity})
				End if 
			End for each 
			
			var $customersWithSimilarities : Collection
			$customersWithSimilarities:=$similarCustomersCol.orderBy("similarity desc")
			
			Form.possibleDuplicateCustomers:=$customersWithSimilarities
			Form.actions.searchingSimilarities.progress.message:=String($customersWithSimilarities.length)+" "+\
				(($customersWithSimilarities.length<=1) ? "customer" : "customers")+" with similarities found"
			
			OBJECT SET VISIBLE(*; "similaritiesSearchSpinner"; False)
			
		End if 
	End if 
	
Function onCustomerVectorizedForSave($embeddingsResult : cs.AIKit.OpenAIEmbeddingsResult)
	
	If (Form#Null)
		If ($embeddingsResult.success)
			var $similarCustomersCol : Collection:=[]
			var $customer : cs.customerEntity
			$customer:=ds.customer.get($embeddingsResult.request.headers.customer)
			If ($customer#Null)
				$customer.vector:=$embeddingsResult.vector
				$customer.save()
				OBJECT SET ENABLED(*; "btnSaveCustomer"; False)
			End if 
			
		End if 
	End if 
	
Function onLoad() : cs.formCreateCustomer
	
	Super.onLoad()
	
	This.actions:=This.actions=Null ? {} : This.actions
	This.actions.generatingCustomer:={running: 0; progress: {value: 0; message: ""}; timing: 0}
	This.actions.formattingAddress:={running: 0; progress: {value: 0; message: ""}; textToFormat: ""; timing: 0}
	This.actions.searchingSimilarities:={running: 0; progress: {value: 0; message: ""}; similarityLevel: 90; timing: 0}
	
	OBJECT SET VISIBLE(*; "customerGen@"; False)
	OBJECT SET VISIBLE(*; "addressFormatting@"; False)
	OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	
	return This.refreshStatus()
	
Function onPageChange() : cs.formCreateCustomer
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Create Customers 🪄")
			
			This.refreshStatus()
			
	End case 
	
	return This
	
Function onDataChange() : cs.formCreateCustomer
	
	Super.onDataChange()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="similarityLevel@")
			OBJECT SET TITLE(*; "btnSearchSimilarCustomers@"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearchMessage@"; False)
		Else 
			
			This.refreshStatus()
			
	End case 
	
	return This
	
Function onClicked() : cs.formCreateCustomer
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnNewCustomer")
			
			This.newCustomer:=ds.customer.new()
			This.newCustomer.address:=cs.address.new()
			
			This.refreshStatus()
			
		: ($event.objectName="btnSaveCustomer")
			
			This.saveCustomer(This.newCustomer)
			
		: ($event.objectName="btnGenerateCustomer")
			
			This.generateCustomer()
			
		: ($event.objectName="btnFormatAddress")
			
			This.formatAddress()
			
		: ($event.objectName="btnSearchSimilarCustomers")
			
			This.possibleDuplicateCustomers:=[]
			
			Form.actions.searchingSimilarities.running:=1
			This.actions.searchingSimilarities.progress.message:=""
			
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; True)
			
			This.searchSimilarCustomers()
			
	End case 
	
	return This
	
Function onAfterEdit() : cs.formCreateCustomer
	
	Super.onAfterEdit()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="textToFormat")
			
			This.refreshStatus()
			
	End case 
	
	return This
	
	//MARK: functions
	
Function refreshStatus() : cs.formCreateCustomer
	
	Super.refreshStatus()
	
	OBJECT SET ENABLED(*; "btnSearchSimilarCustomers@"; Bool(ds.embeddingInfo.embeddingStatus()))
	OBJECT SET TITLE(*; "btnSearchSimilarCustomers@"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
	OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	OBJECT SET ENABLED(*; "btnSaveCustomer"; This.newCustomer.valid)
	
	var $textToFormat : Text
	$textToFormat:=(OBJECT Get name(Object with focus)="textToFormat") ? Get edited text : This.actions.formattingAddress.textToFormat
	
	OBJECT SET ENABLED(*; "btnFormatAddress"; $textToFormat#"")
	
	return This
	
Function saveCustomer($customer : cs.customerEntity) : cs.formCreateCustomer
	
	var $status : Object
	$status:=$customer.save()
	If ($status.success)
		var $vectorizer : cs.AI_Vectorizer
		$vectorizer:=cs.AI_Vectorizer.new(This.providersEmb.currentValue; This.modelsEmb.currentValue)
		$vectorizer.vectorize($customer.stringify(); {onResponse: This.onCustomerVectorizedForSave; extraHeaders: {customer: $customer.getKey(dk key as string)}})
	End if 
	
	return This
	
Function searchSimilarCustomers() : cs.formCreateCustomer
	
	var $customer : cs.customerEntity
	$customer:=ds.customer.newCustomerFromObject(This.newCustomer.toObject())
	
	var $vectorizer : cs.AI_Vectorizer
	$vectorizer:=cs.AI_Vectorizer.new(This.providersEmb.currentValue; This.modelsEmb.currentValue)
	$vectorizer.vectorize($customer.stringify(); {onResponse: This.onCustomerVectorizedForSearch; extraHeaders: {similarity: This.actions.searchingSimilarities.similarityLevel/100}})
	
	return This
	
Function generateCustomer() : cs.formCreateCustomer
	
	This.actions.generatingCustomer:={running: 1; progress: {value: 0; message: "Generating customer with AI"}; timing: 0}
	This.actions.formattingAddress.running:=0
	This.actions.formattingAddress.progress:={value: 0; message: ""}
	This.actions.formattingAddress.timing:=0
	This.actions.searchingSimilarities.running:=0
	This.actions.searchingSimilarities.progress:={value: 0; message: ""}
	This.actions.searchingSimilarities.timing:=0
	
	OBJECT SET VISIBLE(*; "customerGen@"; True)
	OBJECT SET VISIBLE(*; "addressFormatting@"; False)
	OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	
	var $dataGenerator : cs.AI_DataGenerator
	$dataGenerator:=cs.AI_DataGenerator.new(This.providersGen.currentValue; This.modelsGen.currentValue)
	
	var $customerGenerator : cs.AIKit.OpenAIChatHelper
	$customerGenerator:=$dataGenerator.AIClient.chat.create($dataGenerator.customerSystemPrompt; {model: This.modelsGen.currentValue; onResponse: This.onRandomCustomerGenerated})
	
	var $prompt : Text
	$prompt:="generate 1 customer"
	$customerGenerator.prompt($prompt)
	
	return This
	
Function formatAddress() : cs.formCreateCustomer
	
	This.actions.formattingAddress.running:=1
	This.actions.formattingAddress.timing:=0
	This.actions.formattingAddress.progress.message:="Formatting address with AI"
	
	OBJECT SET VISIBLE(*; "addressFormatting@"; True)
	OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	
	var $textToFormat : Text
	$textToFormat:=(OBJECT Get name(Object with focus)="textToFormat") ? Get edited text : This.actions.formattingAddress.textToFormat
	
	var $addressFormatter : cs.AI_AddressFormatter
	$addressFormatter:=cs.AI_AddressFormatter.new(This.providersGen.currentValue; This.modelsGen.currentValue)
	
	var $formatter : cs.AIKit.OpenAIChatHelper
	$formatter:=$addressFormatter.AIClient.chat.create($addressFormatter.formatterSystemPrompt; {model: This.modelsGen.currentValue; onResponse: This.onAddressFormatted})
	
	var $prompt : Text
	$prompt:="Here is the address to format into json "+String($textToFormat)
	$formatter.prompt($prompt)