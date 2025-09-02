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
property chatHelper : cs.AIKit.OpenAIChatHelper

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Data Gen & Embeddings 🪄"))
	
	This.providersEmb:={values: []; index: 0}
	This.modelsEmb:={values: []; index: 0}
	This.providersGen:={values: []; index: 0}
	This.modelsGen:={values: []; index: 0}
	
	//MARK: form events & callbacks
	
Function onDataGenerated($chatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult)
	
	If (Form#Null)
		$quantity:=Form.actions.generatingCustomers.quantity
		$quantityBy:=Form.actions.generatingCustomers.quantityBy
		$result:=Form.getAIStructuredResponse($chatCompletionsResult; Is collection)
		If ($result.success)
			ds.customer.fromCollection($result.response)
			Form.generated:=ds.customer.getCount()-Form.alreadyThere
			Form.actions.generatingCustomers.progress.value:=Int(Form.generated/$quantity*100)
			Form.actions.generatingCustomers.progress.message:="Generating customers "+String(Form.generated)+"/"+String($quantity)
		Else 
			Form.failedAttempts+=1
		End if 
		
		Form.generateCustomers()
		
	End if 
	
Function onPageChange() : cs.formVectorize
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Data Gen & Embeddings 🪄")
			
			This.updateModels().updateActions()
			
			OBJECT SET VISIBLE(*; "customerGen@"; False)
			OBJECT SET VISIBLE(*; "embedding@"; False)
			
	End case 
	
	return This
	
Function gencust()
	var $customerGenerator : cs.AI_DataGenerator
	var $formulaCallback : 4D.Function
	
	$customerGenerator:=cs.AI_DataGenerator.new($formObject.providersGen.currentValue; $formObject.modelsGen.currentValue)
	$customerGenerator.generateCustomers($formObject.actions.generatingCustomers.quantity; $formObject.actions.generatingCustomers.quantityBy; {window: $window; formula: Formula($formObject.progressGenerateCustomers($1))})
	$customerGenerator.populateAddresses(10; {window: $window; formula: Formula($formObject.progressGenerateCustomers($1))})
	CALL FORM($window; Formula($formObject.terminateGenerateCustomers()))
	
Function btnVectorizeEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			
			This.actions.embedding.running:=1
			This.actions.embedding.status:="In progress"
			This.actions.embedding.embeddingInfo:=ds.embeddingInfo.dummyInfo()
			This.actions.embedding.progress:={value: 0; message: "Generating embeddings"}
			
			OBJECT SET VISIBLE(*; "embedding@"; True)
			OBJECT SET VISIBLE(*; "btnVectorize"; False)
			CALL WORKER(String(Session.id)+"-embedding"; Formula(cs.workerHelper.me.vectorizeCustomers($1; $2)); This; Current form window)
	End case 
	
Function onClicked() : cs.formVectorize
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnGenerateCustomers")
			
			This.dataGenerator:=cs.AI_DataGenerator.new(This.providersGen.currentValue; This.modelsGen.currentValue)
			
			This.generated:=0
			This.failedAttempts:=0
			This.maxFailedAttempts:=10
			This.chatHelper:=This.dataGenerator.AIClient.chat.create(This.dataGenerator.customerSystemPrompt; {model: $model; onResponse: This.onDataGenerated})
			This.alreadyThere:=ds.customer.getCount()
			This.actions.generatingCustomers.running:=1
			This.actions.generatingCustomers.progress:={value: 0; message: "Generating customers"}
			
			This.generateCustomers()
			
			//$customerGenerator.populateAddresses(10; {window: $window; formula: Formula($formObject.progressGenerateCustomers($1))})
			
			
			
			
			
			
			
			
			
			
			
			
		: ($event.objectName="btnDropData")
			
			ds.customer.all().drop()
			ds.embeddingInfo.all().drop()
			
			This.actions.embedding:={running: 0; progress: {value: 0; message: ""}; status: "Missing"}
			
	End case 
	
	return This
	
Function onDataChange() : cs.formVectorize
	
	Super.onDataChange()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="providersGenList")
			
			This.modelsGen:=This.setModelList(This.providersGen; "reasoning")
			
		: ($event.objectName="providersEmbList")
			
			This.modelsEmb:=This.setModelList(This.providersEmb; "embedding")
			
	End case 
	
	return This
	
Function terminateVectorizing_()
	
	OBJECT SET VISIBLE(*; "embedding@"; False)
	OBJECT SET VISIBLE(*; "btnVectorize"; True)
	
	If (ds.embeddingInfo.embeddingStatus())
		Form.actions.embedding.status:="Done"
		Form.actions.embedding.info:=ds.embeddingInfo.info()
	Else 
		Form.actions.embedding.status:="Missing"
	End if 
	
	//MARK: functions
	
Function generateCustomers()
	
	var $quantity; $quantityBy; $toGenerate : Integer
	$quantity:=This.actions.generatingCustomers.quantity
	$quantityBy:=This.actions.generatingCustomers.quantityBy
	
	$toGenerate:=($quantityBy<($quantity-This.generated)) ? $quantityBy : ($quantity-This.generated)
	If ($toGenerate>0) && (Form.failedAttempts<Form.maxFailedAttempts)
		OBJECT SET VISIBLE(*; "customerGen@"; True)
		OBJECT SET VISIBLE(*; "btnGenerateCustomers"; False)
		$prompt:="generate "+String($toGenerate)+" customers"
		Form.chatHelper.prompt($prompt)
	Else 
		OBJECT SET VISIBLE(*; "customerGen@"; False)
		OBJECT SET VISIBLE(*; "btnGenerateCustomers"; True)
	End if 
	
Function updateActions() : cs.formVectorize
	
	This.actions:={\
		embedding: {running: 0; progress: {value: 0; message: ""}}; \
		generatingCustomers: {running: 0; progress: {value: 0; message: ""}; quantity: 30; quantityBy: 10}\
		}
	If (ds.embeddingInfo.embeddingStatus())
		This.actions.embedding.status:="Done"
		This.actions.embedding.info:=ds.embeddingInfo.info()
	Else 
		This.actions.embedding.status:="Missing"
	End if 
	
	return This
	
Function updateModels() : cs.formVectorize
	
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