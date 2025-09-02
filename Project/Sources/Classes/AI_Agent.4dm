property model : Text
property provider : Text
property AIClient : cs.AIKit.OpenAI

Class constructor($providerName : Text; $model : Text)
	
	var $provider : cs.providerSettingsEntity
	var $AIClient : cs.AIKit.OpenAI
	
	$provider:=ds.providerSettings.query("name = :1"; $providerName).first()
	
	This.provider:=$providerName
	This.model:=$model
	This.AIClient:=cs.AIKit.OpenAI.new($provider.key)
	If ($provider.url#"")
		This.AIClient.baseURL:=$provider.url
	End if 