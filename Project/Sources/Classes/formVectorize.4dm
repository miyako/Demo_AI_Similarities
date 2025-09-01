Class extends formIntro

property providersEmb : Object
property modelsEmb : Object
property providersGen : Object
property modelsGen : Object
property actions : Object

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Data Gen & Embeddings 🪄"))
	
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	This.providersEmb:={values: []; index: 0}
	This.modelsEmb:={values: []; index: 0}
	This.providersGen:={values: []; index: 0}
	This.modelsGen:={values: []; index: 0}
	
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
	
Function onPageChange() : cs.formVectorize
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Data Gen & Embeddings 🪄")
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
			
			This.actions.generatingCustomers.running:=1
			This.actions.generatingCustomers.progress:={value: 0; message: "Generating customers"}
			
			OBJECT SET VISIBLE(*; "customerGen@"; True)
			OBJECT SET VISIBLE(*; "btnGenerateCustomers"; False)
			
			
			
			CALL WORKER(String(Session.id)+"-generatingCustomers"; Formula(cs.workerHelper.me.generateCustomers($1; $2)); This; Current form window)
			
			
			
			
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
	
Function terminateGenerateCustomers_()
	OBJECT SET VISIBLE(*; "customerGen@"; False)
	OBJECT SET VISIBLE(*; "btnGenerateCustomers"; True)
	
	
Function terminateGenerateCustomers()
	EXECUTE METHOD IN SUBFORM("Subform"; This.terminateGenerateCustomers_; *)
	
Function progressGenerateCustomers_($progress : Object)
	Form.actions.generatingCustomers.progress.value:=$progress.value
	Form.actions.generatingCustomers.progress.message:=$progress.message
	
Function progressGenerateCustomers($progress : Object)
	EXECUTE METHOD IN SUBFORM("Subform"; This.progressGenerateCustomers_; *; $progress)
	
	
Function terminateVectorizing_()
	OBJECT SET VISIBLE(*; "embedding@"; False)
	OBJECT SET VISIBLE(*; "btnVectorize"; True)
	
	If (ds.embeddingInfo.embeddingStatus())
		Form.actions.embedding.status:="Done"
		Form.actions.embedding.info:=ds.embeddingInfo.info()
	Else 
		Form.actions.embedding.status:="Missing"
	End if 
	
Function terminateVectorizing()
	EXECUTE METHOD IN SUBFORM("Subform"; This.terminateVectorizing_; *)
	
Function progressVectorizing_($progress : Object)
	Form.actions.embedding.progress.value:=$progress.value
	Form.actions.embedding.progress.message:=$progress.message
	
Function progressVectorizing($progress : Object)
	EXECUTE METHOD IN SUBFORM("Subform"; This.progressVectorizing_; *; $progress)
	
	