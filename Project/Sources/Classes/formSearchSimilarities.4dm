property customersWithSimilarities : Collection
property selectedCustomer : Object
property similarCustomers : Collection
property actions : Object

Class constructor()
	This.similarCustomers:=[]
	This.actions:={\
		searchingSimilarities: {running: 0; progress: {value: 0; message: ""}; similarityLevel: 90; timing: 0}\
		}
	
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	End case 
	
Function btnSearchSimilaritiesEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			Form.customersWithSimilarities:=[]
			Form.similarCustomers:=[]
			
			This.actions.searchingSimilarities.running:=1
			This.actions.searchingSimilarities.timing:=0
			This.actions.searchingSimilarities.progress.message:="Searching similar customers"
			
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; True)
			CALL WORKER(String(Session.id)+"-searchingAllSimilarities"; Formula(cs.workerHelper.me.searchAllSimilarCustomers($1; $2)); Form; Current form window)
	End case 
	
Function listBoxCustomersEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Selection Change)
			If (Form.selectedCustomer=Null)
				Form.similarCustomers:=[]
			Else 
				Form.similarCustomers:=Form.selectedCustomer.similarities
			End if 
	End case 
	
Function rulerSimilarityEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearchMessage"; False)
	End case 
	
	
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateSearchAllSimilarCustomers_($customersWithSimilarities : Collection; $timing : Integer)
	var $customer; $similarCustomer : Object
	
	For each ($customer; $customersWithSimilarities)
		$customer.entity:=ds.customer.get($customer.customerID)
		For each ($similarCustomer; $customer.similarities)
			$similarCustomer.entity:=ds.customer.get($similarCustomer.customerID)
		End for each 
	End for each 
	
	OBJECT SET VISIBLE(*; "similaritiesSearchSpinner"; False)
	Form.customersWithSimilarities:=$customersWithSimilarities
	Form.actions.searchingSimilarities.timing:=$timing
	Form.actions.searchingSimilarities.progress.message:=String($customersWithSimilarities.length)+" "+\
		(($customersWithSimilarities.length<=1) ? "customer" : "customers")+" with similarities found in "+String($timing)+" ms"
	
Function terminateSearchAllSimilarCustomers($customersWithSimilarities : Collection; $timing : Integer)
	EXECUTE METHOD IN SUBFORM("Subform"; This.terminateSearchAllSimilarCustomers_; *; $customersWithSimilarities; $timing)