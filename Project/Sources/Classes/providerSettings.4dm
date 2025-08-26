Class extends DataClass


Function openProviderFile($path : Text) : Collection
	var $jsonText : Text
	
	$jsonText:=File($path).getText()
	return JSON Parse($jsonText; Is collection)
	
Function loadDefaults()
	var $providersFilePath:="/RESOURCES/AIProviders.json"
	var $jsonContent : Collection
	
	$jsonContent:=This.openProviderFile($providersFilePath)
	This.fromCollection($jsonContent)
	
Function updateProviderSettings()
	var $providers : cs.providerSettingsSelection:=This.all()
	var $provider : cs.providerSettingsEntity
	var $AIClient : cs.AIKit.OpenAI
	var $modelsList : cs.AIKit.OpenAIModelListResult
	var $f : 4D.Function
	var $models : Collection
	var $modelsToKeep : Collection
	var $modelsToRemove : Collection
	var $defaultModel : Object
	
	If (This.all().length=0)
		This.loadDefaults()
	End if 
	
	For each ($provider; $providers)
		$AIClient:=cs.AIKit.OpenAI.new($provider.key)
		$AIClient.baseURL:=($provider.url#"") ? $provider.url : $AIClient.baseURL
		$modelsList:=$AIClient.models.list()
		If ($modelsList.success)
			$f:=Formula(New object("model"; $1.value.id))
			$models:=$modelsList.models.map($f)
			$modelsToKeep:=($provider.modelsToKeep.values.length=0) ? ["@"] : $provider.modelsToKeep.values.copy()
			$modelsToRemove:=$provider.modelsToRemove.values.copy()
			$models:=$models.query("model in :1 and not (model in :2)"; $modelsToKeep; $modelsToRemove)
			$models:=$models.orderBy("model asc")
			$provider.models:={values: $models}
		Else 
			$provider.models:={values: []}
		End if 
		
		If ($provider.models.values.length>0)
			If ($provider.models.values.query("model = :1"; $provider.defaults.embedding).length=0)
				$defaultModel:=$provider.models.values.query("model = :1"; "@embed@").first()
				$provider.defaults.embedding:=($defaultModel#Null) ? $defaultModel.model : "No embedding model detected"
			End if 
			
			If ($provider.models.values.query("model = :1"; $provider.defaults.reasonning).length=0)
				$defaultModel:=$provider.models.values.query("model # :1"; "@embed@").first()
				$provider.defaults.reasonning:=($defaultModel#Null) ? $defaultModel.model : "No reasonning model detected"
			End if 
		End if 
		$provider.save()
		
	End for each 
	
	
Function add()
	var $newProvider : cs.providerSettingsEntity
	
	$newProvider:=ds.providerSettings.new()
	$newProvider.name:=""
	$newProvider.url:=""
	$newProvider.key:=""
	$newProvider.models:={values: []}
	$newProvider.modelsToKeep:={values: []}
	$newProvider.modelsToRemove:={values: []}
	$newProvider.defaults:={embedding: ""; reasonning: ""}
	$newProvider.save()
	
Function providersAvailable($kind : Text) : cs.providerSettingsSelection
	Case of 
		: ($kind="embedding")
			return This.query("hasEmbeddingModels = true")
		: ($kind="reasonning")
			return This.query("hasReasonningModels = true")
		Else 
			return This.query("hasModels = true")
	End case 
	
	
	
	
	
	