Class extends Entity

Function get embeddingDateTime() : Text
	
	If (This.embeddingDate=Null)
		return 
	End if 
	
	If (This.embeddingTime=Null)
		return 
	End if 
	
	return Change string(String(This.embeddingDate; ISO date; Time(This.embeddingTime)); " "; 11)
	