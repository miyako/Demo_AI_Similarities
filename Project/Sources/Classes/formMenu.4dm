property menu : Object


Class constructor()
	This.menu:={}
	This.menu.values:=["Intro"; "Data Gen & Embeddings 🪄"; "Create Customers 🪄"; "Search similarities"]
	This.menu.index:=0
	
	
Function tabMenuEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			Case of 
				: (This.menu.currentValue="Intro")
					OBJECT SET SUBFORM(*; "Subform"; "intro")
				: (This.menu.currentValue="Data Gen & Embeddings 🪄")
					OBJECT SET SUBFORM(*; "Subform"; "vectorize")
				: (This.menu.currentValue="Create Customers 🪄")
					OBJECT SET SUBFORM(*; "Subform"; "createCustomer")
				: (This.menu.currentValue="Search similarities")
					OBJECT SET SUBFORM(*; "Subform"; "searchSimilarities")
			End case 
	End case 