//%attributes = {"invisible":true}
cs.providerSettingsSB.new().updateProviders()

var $OpenAI; $Ollama : Object
$OpenAI:=cs.providerSettingsSB.me.provider("OpenAI")
$Ollama:=cs.providerSettingsSB.me.provider("Ollama")