Class extends formCreateCustomer

property customersWithSimilarities : Collection
property selectedCustomer : Object
property similarCustomers : Collection
property actions : Object

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Search similarities"))
	
	This.similarCustomers:=[]
	
	//MARK: form events & callbacks
	
Function onLoad() : cs.formSearchSimilarities
	
	Super.onLoad()
	
	This.actions:=This.actions=Null ? {} : This.actions
	This.actions.searchingSimilarities:={progress: {message: ""}; similarityLevel: 90}
	
	return This
	
Function onPageChange() : cs.formSearchSimilarities
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Search similarities")
			
			This.refreshStatus()
			
	End case 
	
	return This
	
Function onClicked() : cs.formCreateCustomer
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnSearchSimilarCustomersAll")
			
			This.customersWithSimilarities:=[]
			This.similarCustomers:=[]
			
			This.actions.searchingSimilarities.progress.message:=""
			
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; True)
			
			This.searchAllSimilarCustomers()
			
	End case 
	
	return This
	
Function onSelectionChange() : cs.formSearchSimilarities
	
	Super.onSelectionChange()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="customersWithSimilarities")
			
			If (This.selectedCustomer=Null)
				This.similarCustomers:=[]
			Else 
				This.similarCustomers:=This.selectedCustomer.similarities
			End if 
			
	End case 
	
	return This
	
	//MARK: functions
	
Function searchAllSimilarCustomers()
	
	var $customersWithSimilarities : Collection
	$customersWithSimilarities:=ds.customer.customersWithSimilarities(This.actions.searchingSimilarities.similarityLevel/100)
	
	This.customersWithSimilarities:=$customersWithSimilarities
	This.actions.searchingSimilarities.progress.message:=String($customersWithSimilarities.length)+" "+\
		(($customersWithSimilarities.length<=1) ? "customer" : "customers")+" with similarities found"
	
	