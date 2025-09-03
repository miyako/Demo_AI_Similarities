Class extends EntitySelection

Function dropEmbeddings()
	
	var $customer : cs.customerEntity
	For each ($customer; This)
		$customer.vector:=Null
		$customer.save()
	End for each 