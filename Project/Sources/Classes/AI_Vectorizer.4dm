Class extends AI_Agent

Class constructor($providerName : Text; $model : Text)
	Super($providerName; $model)
	
Function vectorize($value : Variant) : 4D.Vector
	var $result : Object:={}
	$result:=This.AIClient.embeddings.create($value; This.model)
	return $result.vector