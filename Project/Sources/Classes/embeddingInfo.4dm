Class extends DataClass

Function missingCount() : Integer
	
	return ds.customer.query("vector == null").length
	
Function dummyInfo() : cs.embeddingInfoEntity
	
	var $embeddingInfo : cs.embeddingInfoEntity
	
	$embeddingInfo:=This.new()
	$embeddingInfo.model:=""
	$embeddingInfo.provider:=""
	
	return $embeddingInfo