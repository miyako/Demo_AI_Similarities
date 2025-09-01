If (False)
/*
.loadDefaults() is invoked on when the table is empty.
delete all records to force update based on /RESOURCES/AIProviders.json.
*/
	TRUNCATE TABLE([providerSettings])
	SET DATABASE PARAMETER([providerSettings]; Table sequence number; 0)
End if 
/*
get the latest list of models and identify default reasonning/reasoning models.
*/
ds.providerSettings.updateProviderSettings()
00_Start