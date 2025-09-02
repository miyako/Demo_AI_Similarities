Class extends formIntro

property providersEmb : Object
property modelsEmb : Object
property providersGen : Object
property modelsGen : Object
property alreadyThere : Integer
property generated : Integer
property failedAttempts : Integer
property maxFailedAttempts : Integer

property dataGenerator : cs.AI_DataGenerator
property vectorizer : cs.AI_Vectorizer
property customerGenerator : cs.AIKit.OpenAIChatHelper
property addressGenerator : cs.AIKit.OpenAIChatHelper

property customersToVectorize : cs.customerSelection
property vectorizeStartTime : Integer
property vectorizeCount : Integer

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Data Gen & Embeddings 🪄"))
	
	This.providersEmb:={values: []; index: 0}
	This.modelsEmb:={values: []; index: 0}
	This.providersGen:={values: []; index: 0}
	This.modelsGen:={values: []; index: 0}
	
	//MARK: form events & callbacks
	
Function onCustomerVectorized($embeddingsResult : cs.AIKit.OpenAIEmbeddingsResult)
	
	If (Form#Null)
		If ($embeddingsResult.success)
			var $customer : cs.customerEntity
			$customer:=ds.customer.get($embeddingsResult.request.headers.customer)
			If ($customer#Null)
				$customer.vector:=$embeddingsResult.vector
				$customer.save()
			End if 
			var $total; $progress : Integer
			$total:=Form.vectorizeCount
			$progress:=Form.vectorizeCount-Form.customersToVectorize.length
			Form.actions.embedding.progress.value:=Int($progress/$total*100)
			Form.actions.embedding.progress.message:="Generating embeddings "+String($progress)+"/"+String($total)
			Form.actions.embedding.info.duration:=(Milliseconds-Form.vectorizeStartTime)
		Else 
			Form.failedAttempts+=1
		End if 
		
		Form.vectorizeCustomers()
		
	End if 
	
Function onAddressGenerated($chatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult)
	
	If (Form#Null)
		var $result : Object
		$result:=Form.getAIStructuredResponse($chatCompletionsResult; Is collection)
		If ($result.success)
			var $addresses : Collection
			$addresses:=$result.response
			var $customer : cs.customerEntity
			For each ($customer; ds.customer.query("address == null").slice(0; $addresses.length))
				$customer.address:=cs.address.new($addresses.pop())
				$customer.save()
			End for each 
		Else 
			Form.failedAttempts+=1
		End if 
		
		Form.populateAddresses()
		
	End if 
	
Function onCustomerGenerated($chatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult)
	
	If (Form#Null)
		var $quantity : Integer
		$quantity:=Form.actions.generatingCustomers.quantity
		var $result : Object
		$result:=Form.getAIStructuredResponse($chatCompletionsResult; Is collection)
		If ($result.success)
			ds.customer.fromCollection($result.response)
			Form.generated:=ds.customer.getCount()-Form.alreadyThere
			Form.actions.generatingCustomers.progress.value:=Int(Form.generated/$quantity*100)
			Form.actions.generatingCustomers.progress.message:="Generating customers "+String(Form.generated)+"/"+String($quantity)
		Else 
			Form.failedAttempts+=1
		End if 
		
		Form.refreshStatus().populateAddresses().generateCustomers()
		
	End if 
	
Function onLoad() : cs.formVectorize
	
	Super.onLoad()
	
	This.actions:=This.actions=Null ? {} : This.actions
	This.actions.embedding:={running: 0; progress: {value: 0; message: ""}}
	This.actions.generatingCustomers:={running: 0; progress: {value: 0; message: ""}; quantity: 30; quantityBy: 10}
	
	OBJECT SET VISIBLE(*; "customerGen@"; False)
	OBJECT SET VISIBLE(*; "embedding@"; False)
	
	return This
	
Function onPageChange() : cs.formVectorize
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Data Gen & Embeddings 🪄")
			
			This.refreshStatus()
			
	End case 
	
	return This
	
Function onClicked() : cs.formVectorize
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnVectorize")
			
			This.vectorizer:=cs.AI_Vectorizer.new(This.providersEmb.currentValue; This.modelsEmb.currentValue)
			
			This.actions.embedding.running:=1
			This.actions.embedding.status:="In progress"
			This.actions.embedding.info:=ds.embeddingInfo.dummyInfo()
			This.actions.embedding.info.model:=This.modelsGen.currentValue
			This.actions.embedding.info.provider:=This.providersGen.currentValue
			This.actions.embedding.progress:={value: 0; message: "Generating embeddings"}
			
			This.customersToVectorize:=ds.customer.query("vector == null")
			This.vectorizeCount:=This.customersToVectorize.length
			This.vectorizeStartTime:=Milliseconds
			
			This.vectorizeCustomers()
			
		: ($event.objectName="btnGenerateCustomers")
			
			This.dataGenerator:=cs.AI_DataGenerator.new(This.providersGen.currentValue; This.modelsGen.currentValue)
			
			This.generated:=0
			This.failedAttempts:=0
			This.maxFailedAttempts:=10
			
			This.customerGenerator:=This.dataGenerator.AIClient.chat.create(This.dataGenerator.customerSystemPrompt; {model: This.modelsGen.currentValue; onResponse: This.onCustomerGenerated})
			This.addressGenerator:=This.dataGenerator.AIClient.chat.create(This.dataGenerator.addressSystemPrompt; {model: This.modelsGen.currentValue; onResponse: This.onAddressGenerated})
			
			This.alreadyThere:=ds.customer.getCount()
			This.actions.generatingCustomers.running:=1
			This.actions.generatingCustomers.progress:={value: 0; message: "Generating customers"}
			
			This.generateCustomers()
			
		: ($event.objectName="btnDropData")
			
			ds.customer.all().drop()
			ds.embeddingInfo.all().drop()
			
			This.actions.embedding:={running: 0; progress: {value: 0; message: ""}; status: "Missing"}
			
			Form.refreshStatus()
			
	End case 
	
	return This
	
Function onDataChange() : cs.formVectorize
	
	Super.onDataChange()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="providersGenList@")
			
			This.modelsGen:=This.setModelList(This.providersGen; "reasoning")
			
		: ($event.objectName="providersEmbList@")
			
			This.modelsEmb:=This.setModelList(This.providersEmb; "embedding")
			
	End case 
	
	return This
	
	//MARK: functions
	
Function vectorizeCustomers() : cs.formVectorize
	
	If (This.customersToVectorize.length#0)
		OBJECT SET VISIBLE(*; "embedding@"; True)
		OBJECT SET VISIBLE(*; "btnVectorize"; False)
		var $customer : cs.customerEntity
		$customer:=This.customersToVectorize.first()
		This.customersToVectorize:=This.customersToVectorize.slice(1)
		This.vectorizer.vectorize($customer.stringify(); {onResponse: This.onCustomerVectorized; extraHeaders: {customer: $customer.getKey(dk key as string)}})
	Else 
		OBJECT SET VISIBLE(*; "embedding@"; False)
		OBJECT SET VISIBLE(*; "btnVectorize"; True)
		Form.refreshStatus()
		Form.actions.embedding.info.embeddingDate:=Current date
		Form.actions.embedding.info.embeddingTime:=Current time
		If (ds.embeddingInfo.embeddingStatus())
			Form.actions.embedding.status:="Done"
			Form.actions.embedding.info:=ds.embeddingInfo.info()
		Else 
			Form.actions.embedding.status:="Missing"
		End if 
		Form.actions.embedding.info.save()
	End if 
	
	return This
	
Function addressesToGenerate() : Integer
	
	var $quantity; $quantityBy; $toGenerate : Integer
	$quantity:=ds.customer.query("address == null").length
	$quantityBy:=This.actions.generatingCustomers.quantityBy
	$toGenerate:=($quantityBy<$quantity) ? $quantityBy : $quantity
	
	return $toGenerate
	
Function populateAddresses() : cs.formVectorize
	
	var $toGenerate : Integer
	$toGenerate:=This.addressesToGenerate()
	
	If ($toGenerate>0) && (This.failedAttempts<This.maxFailedAttempts)
		OBJECT SET VISIBLE(*; "customerGen@"; True)
		OBJECT SET VISIBLE(*; "btnGenerateCustomers"; False)
		var $prompt : Text
		$prompt:="generate "+String($toGenerate)+" addresses"
		Form.addressGenerator.prompt($prompt)
	Else 
		If (0=This.customersToGenerate())
			OBJECT SET VISIBLE(*; "customerGen@"; False)
			OBJECT SET VISIBLE(*; "btnGenerateCustomers"; True)
		End if 
	End if 
	
	return This
	
Function customersToGenerate() : Integer
	
	var $quantity; $quantityBy; $toGenerate : Integer
	$quantity:=This.actions.generatingCustomers.quantity
	$quantityBy:=This.actions.generatingCustomers.quantityBy
	$toGenerate:=($quantityBy<($quantity-This.generated)) ? $quantityBy : ($quantity-This.generated)
	
	return $toGenerate
	
Function generateCustomers() : cs.formVectorize
	
	var $toGenerate : Integer
	$toGenerate:=This.customersToGenerate()
	If ($toGenerate>0) && (This.failedAttempts<This.maxFailedAttempts)
		OBJECT SET VISIBLE(*; "customerGen@"; True)
		OBJECT SET VISIBLE(*; "btnGenerateCustomers"; False)
		var $prompt : Text
		$prompt:="generate "+String($toGenerate)+" customers"
		Form.customerGenerator.prompt($prompt)
	Else 
		If (0=This.addressesToGenerate())
			OBJECT SET VISIBLE(*; "customerGen@"; False)
			OBJECT SET VISIBLE(*; "btnGenerateCustomers"; True)
		End if 
	End if 
	
	return This
	
Function refreshStatus() : cs.formVectorize
	
	If (ds.embeddingInfo.embeddingStatus())
		This.actions.embedding.status:="Done"
		This.actions.embedding.info:=ds.embeddingInfo.info()
	Else 
		This.actions.embedding.status:="Missing"
	End if 
	
	OBJECT SET ENABLED(*; "btnVectorize"; ds.embeddingInfo.missingCount()#0)
	
	return This
	
Function refreshProviderSettings() : cs.formVectorize
	
	Super.refreshProviderSettings()
	
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	$providers:=ds.providerSettings.providersAvailable("embedding")
	If ($providers.length>0)
		This.providersEmb.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.embeddingModels.models
		This.modelsEmb.values:=$models.extract("model")
		This.modelsEmb.index:=This.modelsEmb.values.findIndex(Formula($1.value=$provider.defaults.embedding))
	End if 
	
	$providers:=ds.providerSettings.providersAvailable("reasoning")
	If ($providers.length>0)
		This.providersGen.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.reasoningModels.models
		This.modelsGen.values:=$models.extract("model")
		This.modelsGen.index:=This.modelsGen.values.findIndex(Formula($1.value=$provider.defaults.reasoning))
	End if 
	
	return This