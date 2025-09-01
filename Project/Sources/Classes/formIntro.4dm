Class extends form

property providers : cs.providerSettingsSelection
property providersListBox : Object
property url_openAIModels : Text
property url_installOllama : Text
property url_ollamaModels : Text
property url_AIKitProviders : Text

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Intro"))  //; "Data Gen & Embeddings 🪄"; "Create Customers 🪄"])
	
	This.providers:=ds.providerSettings.all()
	This.providersListBox:={}
	This.url_openAIModels:="https://platform.openai.com/docs/models"
	This.url_installOllama:="https://www.ollama.com/download"
	This.url_ollamaModels:="https://www.ollama.com/search"
	This.url_AIKitProviders:="https://developer.4d.com/docs/aikit/compatible-openai"
	
Function allProviders() : cs.formIntro
	
	This.providers:=ds.providerSettings.all()
	If (This.providers.length#0)
		LISTBOX SELECT ROW(*; "ProvidersListBox"; 1)
	End if 
	
	return This.onSelectionChange()
	
Function onLoad() : cs.formIntro
	
	Super.onLoad()
	
	return This.allProviders()
	
Function onClicked() : cs.formIntro
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnRefresh")
			
			ds.providerSettings.updateProviderSettings()
			
			This.allProviders()
			
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
			This.allProviders()
			
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