Class extends DataClass

Function getProvidersListFromFile($path : Text) : Collection
	
	If ($path="")
		return []
	End if 
	
	var $file : 4D.File
	$file:=File($path)
	
	If (Not($file.exists))
		return []
	End if 
	
	return JSON Parse($file.getText(); Is collection)
	
Function loadDefaults()
	
	This.fromCollection(This.getProvidersListFromFile("/RESOURCES/AIProviders.json"))
	
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
	
	If (This.getCount()=0)
		This.loadDefaults()
	End if 
	
	For each ($provider; $providers)
		$keyFile:=File("/PACKAGE/"+$provider.name+".token")
		If ($provider.key="" && $keyFile.exists)
			//load api key from external file for cs.AIKit.OpenAI.new()
			$provider.key:=$keyFile.getText()
		End if 
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
			
			If ($provider.models.values.query("model = :1"; $provider.defaults.reasoning).length=0)
				$defaultModel:=$provider.models.values.query("model # :1"; "@embed@").first()
				$provider.defaults.reasoning:=($defaultModel#Null) ? $defaultModel.model : "No reasoning model detected"
			End if 
		End if 
		$provider.save()
		
	End for each 
	
Function add() : cs.providerSettingsEntity
	
	var $newProvider : cs.providerSettingsEntity
	
	$newProvider:=ds.providerSettings.new()
	$newProvider.name:=""
	$newProvider.url:=""
	$newProvider.key:=""
	$newProvider.models:={values: []}
	$newProvider.modelsToKeep:={values: []}
	$newProvider.modelsToRemove:={values: []}
	$newProvider.defaults:={embedding: ""; reasoning: ""}
	$newProvider.save()
	
	return $newProvider
	
Function providersAvailable($kind : Text) : cs.providerSettingsSelection
	Case of 
		: ($kind="embedding")
			return This.query("hasEmbeddingModels = true")
		: ($kind="reasoning")
			return This.query("hasreasoningModels = true")
		Else 
			return This.query("hasModels = true")
	End case 
	