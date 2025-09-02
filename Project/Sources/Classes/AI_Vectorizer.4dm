Class extends AI_Agent

Class constructor($providerName : Text; $model : Text)
	
	Super($providerName; $model)
	
Function vectorize($value : Variant; $parameters : Object)
	
	This.AIClient.embeddings.create($value; This.model; $parameters)