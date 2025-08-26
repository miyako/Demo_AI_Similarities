/* 
* A simple address class
* All attributes are optional
 */

property streetNumber : Text
property streetName : Text
property apartment : Text
property building : Text
property poBox : Text
property city : Text
property region : Text
property postalCode : Text
property country : Text

Class constructor($addressObject : Object)
	If ($addressObject#Null)
		This.streetNumber:=$addressObject.streetNumber ? ($addressObject.streetNumber) : Null
		This.streetName:=$addressObject.streetName ? ($addressObject.streetName) : Null
		This.apartment:=$addressObject.apartment ? ($addressObject.apartment) : Null
		This.building:=$addressObject.building ? ($addressObject.building) : Null
		This.poBox:=$addressObject.poBox ? ($addressObject.poBox) : Null
		This.city:=$addressObject.city ? ($addressObject.city) : Null
		This.region:=$addressObject.region ? ($addressObject.region) : Null
		This.postalCode:=$addressObject.postalCode ? ($addressObject.postalCode) : Null
		This.country:=$addressObject.country ? ($addressObject.country) : Null
	End if 
	
Function get str() : Text
/* 
* Gives a nicely formatted single-line address
 */
	var $parts : Collection:=[]
	var $streetAddress : Text
	
	If (This.valid)
		$streetAddress:=This.streetNumber ? (This.streetNumber+" ") : ""
		$streetAddress+=This.streetName
		
		$parts:=[\
			($streetAddress ? $streetAddress : ""); \
			(This.building ? This.building : ""); \
			(This.apartment ? This.apartment : ""); \
			(This.poBox ? This.poBox : ""); \
			(This.city ? This.city : ""); \
			(This.region ? This.region : ""); \
			(This.postalCode ? This.postalCode : ""); \
			(This.country ? This.country : "")]
		return $parts.join(", "; ck ignore null or empty)
	Else 
		return "Invalid address"
	End if 
	
Function stringify() : Text
	var $stringified : Text
	
	$stringified+=(This.streetNumber) ? (This.streetNumber+" ") : ""
	$stringified+=(This.streetName) ? (This.streetName+" ") : ""
	$stringified+=(This.apartment) ? (This.apartment+" ") : ""
	$stringified+=(This.building) ? (This.building+" ") : ""
	$stringified+=(This.poBox) ? (This.poBox+" ") : ""
	$stringified+=(This.city) ? (This.city+" ") : ""
	$stringified+=(This.region) ? (This.region+" ") : ""
	$stringified+=(This.postalCode) ? (This.postalCode+" ") : ""
	$stringified+=(This.country) ? (This.country) : ""
	
	return $stringified
	
Function get valid() : Boolean
/* 
* Validates that the address has enough information to be used
* While the required fields can vary by country, a general rule for global applicability is:
*   - street_name AND (street_number OR building OR po_box)
*   - city
*   - postal_code
*   - country
 */
	
	var $street : Variant
	
	$street:=This.streetName && (This.streetNumber || This.building || This.poBox)
	return ($street && This.city && This.postalCode && This.country ? True : False)
	