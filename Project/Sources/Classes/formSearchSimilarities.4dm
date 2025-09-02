Class extends formVectorize

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
	
Function onDataChange() : cs.formSearchSimilarities
	
	Super.onDataChange()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="similarityLevel")
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearchMessage"; False)
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
	
Function onClicked() : cs.formSearchSimilarities
	
	Super.onClicked()
	
	var $event : Object
	$event:=FORM Event
	
	Case of 
		: ($event.objectName="btnSearchSimilarities")
			
			This.customersWithSimilarities:=[]
			This.similarCustomers:=[]
			
			This.actions.searchingSimilarities.progress.message:=""
			
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; True)
			
			This.searchAllSimilarCustomers()
			
	End case 
	
	return This
	
	//MARK: functions
	
Function refreshStatus() : cs.formSearchSimilarities
	
	Super.refreshStatus()
	
	OBJECT SET ENABLED(*; "btnSearchSimilarities"; Bool(ds.embeddingInfo.embeddingStatus()))
	OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	OBJECT SET TITLE(*; "btnSearchSimilarities"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
	
	return This
	
Function searchAllSimilarCustomers()
	
	var $customersWithSimilarities : Collection
	$customersWithSimilarities:=ds.customer.customersWithSimilarities(This.actions.searchingSimilarities.similarityLevel/100)
	
	//var $customer; $similarCustomer : Object
	//For each ($customer; $customersWithSimilarities)
	//$customer.entity:=ds.customer.get($customer.customerID)
	//For each ($similarCustomer; $customer.similarities)
	//$similarCustomer.entity:=ds.customer.get($similarCustomer.customerID)
	//End for each 
	//End for each 
	
	This.customersWithSimilarities:=$customersWithSimilarities
	This.actions.searchingSimilarities.progress.message:=String($customersWithSimilarities.length)+" "+\
		(($customersWithSimilarities.length<=1) ? "customer" : "customers")+" with similarities found"