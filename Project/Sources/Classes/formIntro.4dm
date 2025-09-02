Class extends form

property providers : cs.providerSettingsSelection
property providersListBox : Object
property url_openAIModels : Text
property url_installOllama : Text
property url_ollamaModels : Text
property url_AIKitProviders : Text

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Intro"))  // "Create Customers 🪄"])
	
	This.providers:=ds.providerSettings.all()
	This.providersListBox:={}
	This.url_openAIModels:="https://platform.openai.com/docs/models"
	This.url_installOllama:="https://www.ollama.com/download"
	This.url_ollamaModels:="https://www.ollama.com/search"
	This.url_AIKitProviders:="https://developer.4d.com/docs/aikit/compatible-openai"
	
	//MARK: form events & callbacks
	
Function onOpenAIModelListResult($modelsList : cs.AIKit.OpenAIModelListResult)
	
	If (Form#Null)
		var $provider : cs.providerSettingsEntity
		$provider:=ds.providerSettings.get($modelsList.request.headers.provider)
		If ($provider#Null)
			If ($modelsList.success)
				var $f : 4D.Function
				$f:=Formula(New object("model"; $1.value.id))
				var $models : Collection
				$models:=$modelsList.models.map($f)
				var $modelsToKeep : Collection
				$modelsToKeep:=($provider.modelsToKeep.values.length=0) ? ["@"] : $provider.modelsToKeep.values.copy()
				var $modelsToRemove : Collection
				$modelsToRemove:=$provider.modelsToRemove.values.copy()
				$models:=$models.query("model in :1 and not (model in :2)"; $modelsToKeep; $modelsToRemove)
				$models:=$models.orderBy("model asc")
				$provider.models:={values: $models}
			Else 
				$provider.models:={values: []}
			End if 
			var $defaultModel : Object
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
			Form.refreshProviderSettings()
		End if 
	End if 
	
Function onLoad() : cs.formIntro
	
	Super.onLoad()
	
	return This.updateProviderSettings()
	
Function onClicked() : cs.formIntro
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnRefresh")
			
			This.updateProviderSettings()
			
		: ($event.objectName="openAILink")
			
			OPEN URL(This.url_openAIModels)
			
		: ($event.objectName="ollamaLink")
			
			OPEN URL(This.url_installOllama)
			
		: ($event.objectName="openAIKitLink")
			
			OPEN URL(This.url_AIKitProviders)
			
		: ($event.objectName="ollamaModels")
			
			OPEN URL(This.url_ollamaModels)
			
		: ($event.objectName="btnDelete")
			
			This.providersListBox.currentItem.drop()
			This.refreshProviderSettings()
			
		: ($event.objectName="btnAdd")
			
			var $newProvider : cs.providerSettingsEntity
			$newProvider:=ds.providerSettings.add()
			This.providers:=This.providers.or($newProvider)
			
			var $idx : Integer
			$idx:=$newProvider.indexOf(This.providers)
			LISTBOX SELECT ROW(*; "ProvidersListBox"; $idx+1)
			
	End case 
	
	return This
	
Function onSelectionChange() : cs.formIntro
	
	Super.onSelectionChange()
	
	If (This.providersListBox.currentItem=Null)
		OBJECT SET ENABLED(*; "btnDelete"; False)
	Else 
		OBJECT SET ENABLED(*; "btnDelete"; True)
	End if 
	
	return This
	
Function onDataChange() : cs.formIntro
	
	Super.onDataChange()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="provider.@")
			
			If (This.providersListBox.currentItem#Null)
				If (This.providersListBox.currentItem.touched())
					This.providersListBox.currentItem.save()
				End if 
			End if 
			
	End case 
	
	return This
	
Function onPageChange() : cs.formIntro
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Intro")
			
	End case 
	
	return This
	
	//MARK: functions
	
Function refreshProviderSettings() : cs.formIntro
	
	This.providers:=ds.providerSettings.all()
	If (This.providers.length#0)
		LISTBOX SELECT ROW(*; "ProvidersListBox"; 1)
	End if 
	
	return This.onSelectionChange()
	
Function updateProviderSettings() : cs.formIntro
	
	var $provider : cs.providerSettingsEntity
	var $AIClient : cs.AIKit.OpenAI
	For each ($provider; ds.providerSettings.all())
		$AIClient:=cs.AIKit.OpenAI.new($provider.key)
		$AIClient.baseURL:=($provider.url#"") ? $provider.url : $AIClient.baseURL
		$AIClient.models.list({onResponse: This.onOpenAIModelListResult; extraHeaders: {provider: $provider.getKey(dk key as string)}})
	End for each 
	
	return This
	