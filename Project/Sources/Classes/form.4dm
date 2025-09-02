Class extends AI

property menu : Object
property actions : Object

Class constructor($menu : Collection)
	
	Super()
	
	This.menu:={}
	This.menu.values:=$menu
	This.menu.index:=0
	
	//MARK: form events
	
Function onLoad() : cs.form
	
	return This
	
Function onClicked() : cs.form
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="menu")
			FORM GOTO PAGE(This.menu.index+1)
	End case 
	
	return This
	
Function onPageChange() : cs.form
	
	return This
	
Function onDataChange() : cs.form
	
	return This
	
Function onSelectionChange() : cs.form
	
	return This
	
	//MARK: functions
	
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
	
Function get embeddingDateTime() : Text
	
	If (This.actions.embedding.info.embeddingDate=Null)
		return 
	End if 
	
	If (This.actions.embedding.info.embeddingTime=Null)
		return 
	End if 
	
	return String(This.actions.embedding.info.embeddingDate; "dd/MM/yyyy")+" "+String(Time(This.actions.embedding.info.embeddingTime); "HH:mm:ss")
	
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