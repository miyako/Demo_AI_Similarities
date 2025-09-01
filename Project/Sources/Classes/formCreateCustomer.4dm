property providersGen : Object
property modelsGen : Object
property newCustomer : cs.customerEntity
property similarCustomers : Collection
property actions : Object

Class constructor()
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	This.providersGen:={values: []; index: 0}
	This.modelsGen:={values: []; index: 0}
	
	$providers:=ds.providerSettings.providersAvailable("reasoning")
	If ($providers.length>0)
		This.providersGen.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.reasoningModels.models
		This.modelsGen.values:=$models.extract("model")
		This.modelsGen.index:=This.modelsGen.values.findIndex(Formula($1.value=$provider.defaults.reasoning))
	End if 
	
	This.newCustomer:=ds.customer.new()
	This.newCustomer.address:=cs.address.new()
	This.similarCustomers:=[]
	This.actions:={\
		generatingCustomer: {running: 0; progress: {value: 0; message: ""}; timing: 0}; \
		formattingAddress: {running: 0; progress: {value: 0; message: ""}; textToFormat: ""; timing: 0}; \
		searchingSimilarities: {running: 0; progress: {value: 0; message: ""}; similarityLevel: 90; timing: 0}\
		}
	
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "🪄 Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "customerGen@"; False)
			OBJECT SET VISIBLE(*; "addressFormatting@"; False)
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	End case 
	
Function providersGenListEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			This.modelsGen:=This.setModelList(This.providersGen; "reasoning")
	End case 
	
Function btnGenerateCustomerEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
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
			CALL WORKER(String(Session.id)+"-generatingCustomer"; Formula(cs.workerHelper.me.generateCustomer($1; $2)); Form; Current form window)
	End case 
	
Function btnFormatAddressEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			If (Form.actions.formattingAddress.textToFormat#"")
				This.actions.formattingAddress.running:=1
				This.actions.formattingAddress.timing:=0
				This.actions.formattingAddress.progress.message:="Formatting address with AI"
				
				OBJECT SET VISIBLE(*; "addressFormatting@"; True)
				OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
				CALL WORKER(String(Session.id)+"-formattingAddress"; Formula(cs.workerHelper.me.formatAddress($1; $2)); Form; Current form window)
			End if 
	End case 
	
Function btnSearchSimilaritiesEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			This.actions.searchingSimilarities.running:=1
			This.actions.searchingSimilarities.timing:=0
			This.actions.searchingSimilarities.progress.message:="Searching similar customers"
			
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; True)
			CALL WORKER(String(Session.id)+"-searchingSimilarities"; Formula(cs.workerHelper.me.searchSimilarCustomers($1; $2; $3)); Form; Form.newCustomer.toObject(); Current form window)
	End case 
	
Function btnNewCustomerEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			This.newCustomer:=ds.customer.new()
			This.newCustomer.address:=cs.address.new()
	End case 
	
Function btnSaveCustomerEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			If (This.newCustomer.valid)
				This.newCustomer.saveAndVectorize()
			Else 
				throw(999; "Customer cannot be saved, check your data")
			End if 
	End case 
	
	
	
	
Function rulerSimilarityEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "🪄 Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearchMessage"; False)
	End case 
	
	
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateGenerateCustomer_($customerObject : Object; $timing : Integer)
	var $addressObj : Object
	
	OBJECT SET VISIBLE(*; "customerGenSpinner"; False)
	Form.newCustomer:=ds.customer.newCustomerFromObject($customerObject)
	Form.actions.generatingCustomer:={running: 0; progress: {value: 100; message: "Customer generated in "+String($timing)+" ms"}; timing: $timing}
	
/*// Launch similarity search afterwards
OBJECT SET VISIBLE(*; "similaritiesSearch@"; True)
Form.actions.searchingSimilarities.running:=1*/
	
	Form.btnSearchSimilaritiesEventHandler(On Clicked)
	
	CALL WORKER(String(Session.id)+"-searchingSimilarities"; Formula(cs.workerHelper.me.searchSimilarCustomers($1; $2; $3)); Form; Form.newCustomer.toObject(); Current form window)
	
Function terminateGenerateCustomer($customerObject : Object; $timing : Integer)
	EXECUTE METHOD IN SUBFORM("Subform"; This.terminateGenerateCustomer_; *; $customerObject; $timing)
	
Function terminateAddressFormatting_($addressObject : cs.address; $timing : Integer)
	OBJECT SET VISIBLE(*; "addressFormattingSpinner"; False)
	Form.newCustomer.address:=$addressObject
	Form.actions.formattingAddress.timing:=$timing
	Form.actions.formattingAddress.progress.message:="Address formatted in "+String($timing)+" ms"
	
	
Function terminateAddressFormatting($addressObject : cs.address; $timing : Integer)
	EXECUTE METHOD IN SUBFORM("Subform"; This.terminateAddressFormatting_; *; $addressObject; $timing)
	
	
Function terminateSearchSimilarCustomers_($similarCustomers : Collection; $timing : Integer)
	var $entry : Object
	
	For each ($entry; $similarCustomers)
		$entry.entity:=ds.customer.get($entry.customerID)
	End for each 
	
	OBJECT SET VISIBLE(*; "similaritiesSearchSpinner"; False)
	Form.similarCustomers:=$similarCustomers
	Form.actions.searchingSimilarities.timing:=$timing
	Form.actions.searchingSimilarities.progress.message:=String($similarCustomers.length)+" "+\
		(($similarCustomers.length<=1) ? "similarity" : "similarities")+" found in "+String($timing)+" ms"
	
Function terminateSearchSimilarCustomers($similarCustomers : Collection; $timing : Integer)
	EXECUTE METHOD IN SUBFORM("Subform"; This.terminateSearchSimilarCustomers_; *; $similarCustomers; $timing)
	
	
	
	
	
Function setModelList($providerList : Object; $kind : Text) : Object
	
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	var $list : Object:={}
	var $defaultModel : Text
	
	$provider:=ds.providerSettings.query("name = :1"; $providerList.currentValue).first()
	
	Case of 
		: ($kind="reasoning")
			$models:=$provider.reasoningModels.models
			$defaultModel:=$provider.defaults.reasoning
		: ($kind="embedding")
			$models:=$provider.embeddingModels.models
			$defaultModel:=$provider.defaults.embedding
	End case 
	
	$list.values:=$models.extract("model")
	$list.index:=$list.values.findIndex(Formula($1.value=$defaultModel))
	
	return $list