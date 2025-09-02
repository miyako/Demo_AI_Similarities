//%attributes = {"invisible":true}
var $providers : Collection
$providers:=cs.providerSettingsSB.me.providers()

cs.providerSettingsSB.me.updateProviderSettings()

var $OpenAI; $Ollama : Object
$OpenAI:=cs.providerSettingsSB.me.provider("OpenAI")
$Ollama:=cs.providerSettingsSB.me.provider("Ollama")