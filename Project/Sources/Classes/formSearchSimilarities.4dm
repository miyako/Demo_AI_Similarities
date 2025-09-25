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
	
Function onSelectionChange($objectName : Text) : cs.formSearchSimilarities
	
	Super.onSelectionChange($objectName)
	
	var $event : Object
	$event:=FORM Event
	
	If ($event.objectName#Null)
		$objectName:=$event.objectName
	End if 
	
	Case of 
		: ($objectName="ProvidersListBox")
			
			If (This.providersListBox.currentItem#Null)
				This.reasoningModels:=This.providersListBox.currentItem.reasoningModels.models
			Else 
				This.embeddingModels:=Null
			End if 
			If (This.providersListBox.currentItem#Null)
				This.embeddingModels:=This.providersListBox.currentItem.embeddingModels.models
			Else 
				This.embeddingModels:=Null
			End if 
			
		: ($objectName="customersWithSimilarities")
			
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
	
	