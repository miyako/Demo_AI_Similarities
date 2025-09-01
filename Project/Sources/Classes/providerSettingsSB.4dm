property keysFilePath : Text

singleton Class constructor()
	This.keysFilePath:="/RESOURCES/AIProviders.json"
	
Function openProviderFile() : Collection
	var $jsonText : Text
	
	$jsonText:=File(This.keysFilePath).getText()
	return JSON Parse($jsonText; Is collection)
	
Function writeProviderFile($jsonContent : Collection)
	var $file : 4D.File
	
	$file:=File(This.keysFilePath)
	$file.setText(JSON Stringify($jsonContent; *))
	
Function providers() : Collection
	var $f : 4D.Function
	var $providers : Collection
	
	$providers:=This.openProviderFile()
	
	$f:=Formula(New object("name"; $1.value.name; "url"; $1.value.url; "defaults"; $1.value.defaults; "models"; $1.value.models))
	return $providers.map($f)
	
Function provider($provider : Text) : Object
	var $key : Object
	var $providers : Collection
	
	$providers:=This.openProviderFile()
	
	$key:=$providers.query("name = :1"; $provider).first()
	If ($key=Null)
		throw(999; "Provider "+$provider+" not defined in "+This.keysFilePath)
		return {}
	End if 
	return $key
	
Function updateProviders()
	var $jsonText : Text
	var $jsonContent : Collection
	var $provider : Object
	var $AIClient : cs.AIKit.OpenAI
	var $modelsList : cs.AIKit.OpenAIModelListResult
	var $f : 4D.Function
	var $models : Collection
	var $modelsToKeep : Collection
	var $modelsToRemove : Collection
	var $defaultModel : Object
	
	$jsonText:=File(This.keysFilePath).getText()
	$jsonContent:=JSON Parse($jsonText; Is collection)
	
	var $keyFile : 4D.File
	For each ($provider; $jsonContent)
		$keyFile:=File("/PACKAGE/"+$provider.name+".token")
		If ($provider.key="" && $keyFile.exists)
			//load api key from external file for cs.AIKit.OpenAI.new()
			$provider.key:=$keyFile.getText()
		End if 
		
		$AIClient:=cs.AIKit.OpenAI.new($provider.key)
		//do not store api key in AIProviders.json
		$provider.key:=""
		$AIClient.baseURL:=($provider.url#"") ? $provider.url : $AIClient.baseURL
		$modelsList:=$AIClient.models.list()
		If ($modelsList.success)
			$f:=Formula(New object("model"; $1.value.id))
			$models:=$modelsList.models.map($f)
			
			$modelsToKeep:=($provider.modelsToKeep.values.length=0) ? ["@"] : $provider.modelsToKeep.values.copy()
			$modelsToRemove:=$provider.modelsToRemove.values.copy()
			$models:=$models.query("model in :1 and not (model in :2)"; $modelsToKeep; $modelsToRemove)
			
			$models:=$models.orderBy("model asc")
			$provider.models:=$models
		Else 
			$provider.models:=[]
		End if 
		
		If ($provider.models.length>0)
			If ($provider.models.query("model = :1"; $provider.defaults.embedding).length=0)
				$defaultModel:=$provider.models.query("model = :1"; "@embed@").first()
				$provider.defaults.embedding:=($defaultModel#Null) ? $defaultModel.model : "No embedding model detected"
			End if 
			
			If ($provider.models.query("model = :1"; $provider.defaults.reasoning).length=0)
				$defaultModel:=$provider.models.query("model # :1"; "@embed@").first()
				$provider.defaults.reasoning:=($defaultModel#Null) ? $defaultModel.model : "No reasoning model detected"
			End if 
		End if 
		
	End for each 
	
	This.writeProviderFile($jsonContent)