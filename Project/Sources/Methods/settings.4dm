//%attributes = {"invisible":true,"preemptive":"capable"}
var $providers : cs.providerSettingsSelection
$providers:=ds.providerSettings.providers()

ds.providerSettings.updateProviderSettings()

var $OpenAI; $Ollama : Object
$OpenAI:=ds.providerSettings.provider("OpenAI")
$Ollama:=ds.providerSettings.provider("Ollama")