; Scripting Dictionary, By Matwachich
; !!! the Key is Case-Sensitive !!!

Global $__ScriptingDictionary_ErrorHandler = ObjEvent("AutoIt.Error", "__ScriptingDictionary_ErrorHandler")
Global $__ScriptingDictionary_LastUsed

; ##############################################################
; Example
#cs
#include <Array.au3>

$sd = _SD_Create()
ConsoleWrite(IsObj($sd) & @CRLF)

_SD_FromIni(-1, @ScriptDir & "\test.ini", "TEST")

$list = _SD_List(-1)
_ArrayDisplay($list)

ConsoleWrite('_SD_Set(-1, "Nom", "DUPON")' & @TAB & _SD_Set(-1, "Nom", "DUPON") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)
ConsoleWrite('_SD_Set(-1, "Prénom", "Jean")' & @TAB & _SD_Set(-1, "Prénom", "Jean") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)
ConsoleWrite('_SD_Set(-1, "Age", 21)' & @TAB & _SD_Set(-1, "Age", 21) & " - @error = " & @error & " - @extended = " & @extended & @CRLF)

ConsoleWrite('_SD_Get(-1, "Nom")' & @TAB & _SD_Get(-1, "Nom") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)
ConsoleWrite('_SD_Get(-1, "Prénom")' & @TAB & _SD_Get(-1, "Prénom") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)
ConsoleWrite('_SD_Get(-1, "Age")' & @TAB & _SD_Get(-1, "Age") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)
ConsoleWrite('_SD_Get(-1, "Rien")' & @TAB & _SD_Get(-1, "Rien") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)

ConsoleWrite('_SD_Set(-1, "Age", 22)' & @TAB & _SD_Set(-1, "Age", 22) & " - @error = " & @error & " - @extended = " & @extended & @CRLF)
ConsoleWrite('_SD_Get(-1, "Age")' & @TAB & _SD_Get(-1, "Age") & " - @error = " & @error & " - @extended = " & @extended & @CRLF)

ConsoleWrite(_SD_Count(-1) & @CRLF)
$list = _SD_List(-1)
_ArrayDisplay($list)

_SD_Del(-1, "Prénom")

$list = _SD_List(-1)
_ArrayDisplay($list)

_SD_ToIni(-1, @ScriptDir & "\test.ini", "TEST")
#ce
; ##############################################################

; Returns a Scripting.Dictionary Object
Func _SD_Create()
	Local $ret = ObjCreate("Scripting.Dictionary")
	$__ScriptingDictionary_LastUsed = $ret
	Return SetError(@error, 0, $ret)
EndFunc

; Create a new variable in the Scripting.Dictionary $hSD (-1 for last used Scripting.Dictionary)
; or change the value of an existing variable.
Func _SD_Set($hSD, $sKey, $Data, $iOverwrite = 1, $iCreateIfNecessary = 1)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	If $iCreateIfNecessary Then
		If Not _SD_Exists($hSD, $sKey) Then
			Return SetError(@error, 0, $hSD.Add($sKey, $Data))
		Else
			If $iOverwrite Then
				$hSD.Item($sKey) = $Data
				Return SetError(@error, 0, 1)
			Else
				Return SetError(0, 0, 0)
			EndIf
		EndIf
	Else
		If Not _SD_Exists($hSD, $sKey) Then
			Return SetError(1, 0, 0)
		Else
			If $iOverwrite Then
				$hSD.Item($sKey) = $Data
				Return SetError(@error, 0, 1)
			Else
				Return SetError(0, 0, 0)
			EndIf
		EndIf
	EndIf
EndFunc

; Returns the value of a variable, or 0 and sets @error if the variable
; doesn't exists
Func _SD_Get($hSD, $sKey)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	If Not _SD_Exists($hSD, $sKey) Then Return SetError(1, 0, 0)
	Return SetError(@error, 0, $hSD.Item($sKey))
EndFunc

; Delete a variable
Func _SD_Del($hSD, $sKey)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	$hSD.Remove($sKey)
    If @error Then Return SetError(1, 0, 0)
	; ---
	Return SetError(0, 0, 1)
EndFunc

; Checks if a variable exists
Func _SD_Exists($hSD, $sKey)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	Return SetError(@error, 0, $hSD.Exists($sKey))
EndFunc

; Returns the number of variables in the $hSD Scripting.Dictionary
Func _SD_Count($hSD)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	Return SetError(@error, 0, $hSD.Count)
EndFunc

; List all variables/values in the $hSD Scripting.Dictionary
; Returns a 2D-Array:
;	$array[0][0] = Number of variables (n)
;	$array[n][0] = Variable name
;	$array[n][1] = Variable value
Func _SD_List($hSD)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	Local $keys = $hSD.Keys
	Local $items = $hSD.Items
	Local $ret[1][2] = [[0,""]]
	For $i = 0 To UBound($keys) - 1
		ReDim $ret[$ret[0][0] + 2][2]
		$ret[$ret[0][0] + 1][0] = $keys[$i]
		$ret[$ret[0][0] + 1][1] = $items[$i]
		$ret[0][0] += 1
	Next
	; ---
	Return $ret
EndFunc

; Dumps all the variables/values of the $hSD Scripting.Dictionary to an ini file
Func _SD_ToIni($hSD, $sIniPath, $sIniSection, $iDeleteSectionFirst = 1)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	If $iDeleteSectionFirst Then IniDelete($sIniPath, $sIniSection)
	; ---
	Local $list = _SD_List($hSD)
	If Not IsArray($list) Or $list[0][0] = 0 Then Return SetError(0, 0, 0)
	; ---
	For $i = 1 To $list[0][0]
		IniWrite($sIniPath, $sIniSection, $list[$i][0], $list[$i][1])
	Next
	Return SetError(0, 0, $list[0][0])
EndFunc

; Reads all the pairs (key/value) of a section in an ini file, and adds them to the $hSD Scripting.Dictionary
Func _SD_FromIni($hSD, $sIniPath, $sIniSection, $iOverwrite = 1, $iCreateIfNecessary = 1)
	If Not __SD_CheckLast($hSD) Then Return SetError(-1, 0, 0)
	; ---
	Local $ini = IniReadSection($sIniPath, $sIniSection)
	If @error Or Not IsArray($ini) Or $ini[0][0] = 0 Then Return SetError(1, 0, 0)
	; ---
	For $i = 1 To $ini[0][0]
		_SD_Set($hSD, $ini[$i][0], $ini[$i][1], $iOverwrite, $iCreateIfNecessary)
	Next
	Return SetError(0, 0, $ini[0][0])
EndFunc

; ##############################################################
; Internals

Func __SD_CheckLast(ByRef $hSD)
	; Not working
	;If Not IsObj($hSD) Then Return 0
	If $hSD = -1 Then
		$hSD = $__ScriptingDictionary_LastUsed
	Else
		$__ScriptingDictionary_LastUsed = $hSD
	EndIf
	Return 1
EndFunc

Func __ScriptingDictionary_ErrorHandler()
	ConsoleWrite("COM Error, ScriptLine(" & $__ScriptingDictionary_ErrorHandler.scriptline & ") : " & _
				 "Number 0x" & Hex($__ScriptingDictionary_ErrorHandler.number, 8) & _
				 " - " & $__ScriptingDictionary_ErrorHandler.windescription & @CRLF)
EndFunc