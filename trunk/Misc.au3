#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

#cs
; UEZ
Func _ExtractIcon($sFile, $iIndex)
	_GDIPlus_Startup()
	; ---
	Local $aRet = DllCall("shell32", "long", "ExtractAssociatedIcon", "int", 0, "str", $sFile, "int*", $iIndex)
	Local $hIcon = $aRet[0]
	$aRet = DllCall($ghGDIPDll, "int", "GdipCreateBitmapFromHICON", "ptr", $hIcon, "int*", 0)
	Local $hBitmap = $aRet[0]
	_WinAPI_DestroyIcon($hIcon)
	; ---
	_GDIPlus_Shutdown()
	Return $hBitmap
EndFunc
#ce

; ##############################################################
; Historique des projets
; iType: 1 = project | 2 = workspace

Func _Last_Add($iType, $sPath)
	If _Last_Existes($sPath) Then Return
	; ---
	Local $key
	Switch $iType
		Case 1
			$key = "last_projects"
		Case 2
			$key = "last_workspaces"
	EndSwitch
	; ---
	Local $read = CFG($key)
	$read = StringSplit($read, "|")
	; ---
	If $read[0] >= CFG("last_saveCount") Then
		_ArrayDelete($read, 1)
		$read[0] -= 1
	EndIf
	_ArrayAdd($read, $sPath)
	$read[0] += 1
	; ---
	Local $str = ""
	For $i = 1 To $read[0]
		$str &= $read[$i] & "|"
	Next
	_AutoCfg_SetEntry($key, StringTrimRight($str, 1))
	; ---
	_GUI_LastMenu_Update()
EndFunc

Func _Last_Enum($iType)
	Local $key
	Switch $iType
		Case 1
			$key = "last_projects"
		Case 2
			$key = "last_workspaces"
	EndSwitch
	; ---
	Local $read = CFG($key)
	$read = StringSplit($read, "|")
	Return $read
EndFunc

Func _Last_Existes($sPath)
	For $i = 1 To $__Last[0][0]
		If $sPath = $__Last[$i][1] Then Return 1
	Next
	Return 0
EndFunc

Func _Last_Empty($iType)
	Local $key
	Switch $iType
		Case 1
			$key = "last_projects"
		Case 2
			$key = "last_workspaces"
	EndSwitch
	; ---
	_AutoCfg_SetEntry($key, "")
	_GUI_LastMenu_Update()
EndFunc

; ##############################################################

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
	_ArrayDisplay($__TV_Assoc, "$__TV_Assoc")
EndFunc

Func _Debug_ShowArray_Projects()
	_ArrayDisplay($__OpenedProjects, "$__OpenedProjects")
EndFunc

Func _Debug_Show_ActifProject()
	ConsoleWrite("!!! DEBUG: $__ActifProject = " & $__ActifProject & @CRLF)
EndFunc
