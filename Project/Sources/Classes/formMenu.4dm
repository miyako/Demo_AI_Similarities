Class extends form

Class constructor($menu : Collection)
	
	$menu:=$menu=Null ? [] : $menu
	
	Super($menu.unshift("Intro"))  //; "Data Gen & Embeddings 🪄"; "Create Customers 🪄"; "Search similarities"])
	
Function onClicked() : cs.formMenu
	
	Super.onClicked()
	
	return This
	
Function onPageChange() : cs.formMenu
	
	Super.onPageChange()
	
	Case of 
		: (This.menu.currentValue="Intro")
			
	End case 
	
	return This