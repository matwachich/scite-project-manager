#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------

; #FUNCTION# ;===============================================================================
;
; Name...........: _Assoc_Set
; Description ...: Associate a file extension with a program/command
; Syntax.........: _Assoc_Set($sFileExt, $sFileType, $sCommand, $sIconFile = "", $iIconId = Default)
; Parameters ....: $sFileExt - File extension (with or withou .)
;                  $sFileType - File type name
;                  $sCommand - The command line to associate with the extension (see remark)
;                  $sIconFile - [optional] Icon file
;                  $iIconId -  [optional] Icon index in the icon file
; Return values .: 1
; Author ........: Matwachich
; Remarks .......: For example, if you want to associate the extension .ext with your script
;                  you should set $sCommand = '"' & @ScriptFullPath & '" "%1"'
;
; ;==========================================================================================
Func _Assoc_Set($sFileExt, $sFileType, $sCommand, $sIconFile = "", $iIconId = Default)
	If StringLeft($sFileExt, 1) <> "." Then $sFileExt = "." & $sFileExt
	; ---
	RegWrite("HKEY_CLASSES_ROOT\" & $sFileExt, "", "REG_SZ", $sFileType)
	RegWrite("HKEY_CLASSES_ROOT\" & $sFileType & "\shell", "", "REG_SZ", "Open")
	RegWrite("HKEY_CLASSES_ROOT\" & $sFileType & "\shell\open", "", "REG_SZ", "Open")
	RegWrite("HKEY_CLASSES_ROOT\" & $sFileType & "\shell\open\command", "", "REG_SZ", $sCommand)
	; ---
	If $sIconFile Then
		If Not IsKeyword($iIconId) And $iIconId <> Default Then $sIconFile &= "," & $iIconId
		RegWrite("HKEY_CLASSES_ROOT\" & $sFileType & "\DefaultIcon", "", "REG_SZ", $sIconFile)
	EndIf
	; ---
	Return 1
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _Assoc_Get
; Description ...: Get informations about a file extension
; Syntax.........: _Assoc_Get($sFileExt)
; Parameters ....: $sFileExt - File extension (with or withou .)
; Return values .: Success - 3 elements array:
;                  |0 -> File type
;                  |1 -> Command associated
;                  |2 -> Icon file
;                  |3 -> Icon index ("" if no index)
;                  Failure -
; Author ........: Matwachich
; Remarks .......:
;
; ;==========================================================================================
Func _Assoc_Get($sFileExt)
	If StringLeft($sFileExt, 1) <> "." Then $sFileExt = "." & $sFileExt
	; ---
	Local $sFileType = RegRead("HKEY_CLASSES_ROOT\" & $sFileExt, "")
	If @error Or Not $sFileExt Then Return SetError(1, 0, 0)
	; ---
	Local $ret[4] = [ _
		$sFileType, _
		RegRead("HKEY_CLASSES_ROOT\" & $sFileType & "\shell\open\command", "") _
	]
	; ---
	Local $ico = RegRead("HKEY_CLASSES_ROOT\" & $sFileType & "\DefaultIcon", "")
	If StringInStr($ico, ",") Then
		$ret[2] = StringLeft($ico, StringInStr($ico, ",", 1, -1) - 1)
		$ret[3] = StringTrimLeft($ico, StringInStr($ico, ",", 1, -1))
	Else
		$ret[2] = $ico
		$ret[3] = ""
	EndIf
	; ---
	Return $ret
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _Assoc_Del
; Description ...: Delete file association
; Syntax.........: _Assoc_Del($sFileExt)
; Parameters ....: $sFileExt - File extension (with or withou .)
; Return values .: 1
; Author ........: Matwachich
; Remarks .......:
;
; ;==========================================================================================
Func _Assoc_Del($sFileExt)
	If StringLeft($sFileExt, 1) <> "." Then $sFileExt = "." & $sFileExt
	; ---
	Local $sFileType = RegRead("HKEY_CLASSES_ROOT\" & $sFileExt, "")
	RegDelete("HKEY_CLASSES_ROOT\" & $sFileExt)
	; ---
	If $sFileType Then RegDelete("HKEY_CLASSES_ROOT\" & $sFileType)
	; ---
	Return 1
EndFunc
