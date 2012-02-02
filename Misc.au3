#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

Func _Ask($sText)
	Return MsgBox(36, LNG("ProgName"), $sText) = 6
EndFunc

Func _Err($sText, $iCritical = 0)
	MsgBox(16, LNG("ProgName"), $sText)
	If $iCritical Then Exit
EndFunc

; ##############################################################

Func _FileOpenDialog_ParseMultiple($sel)
	Local $ret[1] = [0]
	; ---
	If Not StringInStr($sel, "|") Then
		_ArrayAdd($ret, $sel)
		$ret[0] += 1
	Else
	; ---
		$sel = StringSplit($sel, "|")
		For $i = 2 To $sel[0]
			_ArrayAdd($ret, $sel[1] & "\" & $sel[$i])
			$ret[0] += 1
		Next
	EndIf
	; ---
	Return $ret
EndFunc

; ##############################################################

Func _File_GetName($s)
	Return StringTrimLeft($s, StringInStr($s, "\", 1, -1))
EndFunc

Func _File_GetPath($s)
	Return StringLeft($s, StringInStr($s, "\", 1, -1) - 1)
EndFunc

Func _File_GetExt($s)
	Return StringTrimLeft($s, StringInStr($s, ".", 1, -1))
EndFunc

Func _File_Create($sPath)
	FileClose(FileOpen($sPath, 10))
EndFunc

; ##############################################################

Func _XML_getDisplayName($node)
	Switch StringUpper($node.nodeName())
		Case "PROJECT", "FOLDER"
			Return $node.getAttribute("name")
		Case "FILE"
			Return $node.getAttribute("path")
	EndSwitch
	Return ""
EndFunc   ;==>XML_getDisplayName

; ##############################################################
; Debug

Func _Debug_ShowArray_TV()
	_ArrayDisplay($__TV_Assoc)
EndFunc

Func _Debug_ShowArray_Projects()
	_ArrayDisplay($__OpenedProjects)
EndFunc
