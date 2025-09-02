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
	