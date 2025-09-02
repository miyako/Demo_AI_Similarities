Class extends Entity

Function get addressStr() : Text
	If (This.address=Null)
		return ""
	Else 
		return This.address.str
	End if 
	
Function set addressStr()
	//readOnly
	
Function get fullname() : Text
	var $fullname : Text
	
	$fullname:=(This.firstname) ? (This.firstname+" ") : ""
	$fullname+=(This.lastname) ? (This.lastname) : ""
	return $fullname
	
Function set fullname()
	//readOnly
	
Function get valid() : Boolean
/* 
* Validates that the customer has enough information to be used
* The address must be valid
* At least a firstname and a lastname
* Phone or email
 */
	
	If ((This.address#Null) && This.address.valid)
		return ((This.firstname && This.lastname && (This.email || This.phone)) ? True : False)
	End if 
	return False
	
Function set valid()
	//readOnly
	
Function stringify() : Text
	var $stringified : Text
	
	$stringified+=(This.firstname) ? (This.firstname+" ") : ""
	$stringified+=(This.lastname) ? This.lastname : ""
	$stringified+="|"
	$stringified+=(This.email) ? (This.email+"|") : ""
	$stringified+=(This.phone) ? (This.phone+"|") : ""
	$stringified+=(This.address) ? This.address.stringify() : ""
	
	return $stringified
	
Function searchSimilarCustomers($targetSimilarity : Real) : Collection
	var $embeddingInfo : cs.embeddingInfoEntity
	var $similarCustomersCol : Collection:=[]
	var $customer : cs.customerEntity
	var $vectorizer : cs.AI_Vectorizer
	var $vector : 4D.Vector
	var $similarity : Real
	
	If (ds.embeddingInfo.embeddingStatus()=False)
		throw(999; "Cannot find similarities, no embedding info found. Please generate embeddings")
		return []
	End if 
	
	$embeddingInfo:=ds.embeddingInfo.info()
	$vectorizer:=cs.AI_Vectorizer.new($embeddingInfo.provider; $embeddingInfo.model)
	$vector:=$vectorizer.vectorize(This.stringify())
	
	For each ($customer; ds.customer.all().minus(This))
		$similarity:=$vector.cosineSimilarity($customer.vector)
		If ($similarity>=$targetSimilarity)
			$similarCustomersCol.push({entity: $customer; customerID: $customer.ID; similarity: $similarity})
		End if 
	End for each 
	$similarCustomersCol:=$similarCustomersCol.orderBy("similarity desc")
	return $similarCustomersCol
	