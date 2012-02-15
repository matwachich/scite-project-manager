#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#include-once

#Include <File.au3>
#Include <GuiListView.au3>

Global $__Search_CurrentResult

Func _Search($iProjectID, $sKeyword)
	Local $aFiles = _Project_GetAllFiles($iProjectID)
	If Not IsArray($aFiles) Then Return
	; ---
	Local $sPrjPath = __OpenProject_GetPath($iProjectID)
	$sPrjPath = _File_GetPath($sPrjPath)
	; ---
	Local $aResult[1][3] = [[0, "", ""]] ; file, lineNbr, line
	For $i = 1 To $aFiles[0]
		__Search_File($sPrjPath & "\" & $aFiles[$i], $sKeyword, $aResult)
	Next
	; ---
	$__Search_CurrentResult = $aResult
	__Search_Display($aResult)
EndFunc

Func _Search_Event_OpenResult($iIndex)
	$iIndex += 1
	SendSciTE_Command('open:' & StringStripWS(StringReplace($__Search_CurrentResult[$iIndex][0], "\", "\\"), 3))
	SendSciTE_Command('goto:' & $__Search_CurrentResult[$iIndex][1])
	SendSciTE_Command('find:' & $__Search_CurrentResult[$iIndex][2])
EndFunc

; ##############################################################

Func __Search_File($sFile, $sKeyword, ByRef $aResult)
	Local $aFile
	_FileReadToArray($sFile, $aFile)
	If Not IsArray($aFile) Then Return SetError(1, 0, 0)
	; ---
	ConsoleWrite("> File: " & $sFile & @CRLF)
	For $i = 1 To $aFile[0]
		If StringInStr($aFile[$i], $sKeyword) Then
			ConsoleWrite(@TAB & "Add: " & "[" & $i & "]" & @TAB & $aFile[$i] & @CRLF)
			ReDim $aResult[$aResult[0][0] + 2][3]
			$aResult[0][0] += 1
			$aResult[$aResult[0][0]][0] = $sFile ; file path
			$aResult[$aResult[0][0]][1] = $i ; line nbr
			$aResult[$aResult[0][0]][2] = $aFile[$i] ; line
		EndIf
	Next
EndFunc

Func __Search_Display(ByRef $aResult)
	_GUI_Search()
	_GUI_Search($__GUI_Show)
	; ---
	_GUICtrlListView_BeginUpdate($__hListView)
	; ---
	For $i = 1 To $aResult[0][0]
		_GuiCtrlListView_AddItem($__hListView, _File_GetName($aResult[$i][0]))
		_GuiCtrlListView_AddSubItem($__hListView, $i - 1, $aResult[$i][1], 1)
		_GuiCtrlListView_AddSubItem($__hListView, $i - 1, $aResult[$i][2], 2)
	Next
	; ---
	For $i = 0 To 2
		_GUICtrlListView_SetColumnWidth($__hListView, $i, $LVSCW_AUTOSIZE)
		If _GUICtrlListView_GetColumnWidth($__hListView, $i) < 50 Then _GUICtrlListView_SetColumnWidth($__hListView, $i, 50)
	Next
	; ---
	_GUICtrlListView_EndUpdate($__hListView)
EndFunc

; ##############################################################
#cs
Func _Search_ToSRE($sIn)
	If Not StringRegExp($sIn, "[ *%]") Then Return $sIn
	; ---
	$sIn = StringStripWS($sIn, 7)
	$sIn = StringReplace($sIn, " ", "|")
	$sIn = StringReplace($sIn, "*", ".*")
	$sIn = StringReplace($sIn, "%", ".")
	; ---
	Return $sIn
EndFunc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _RFLTA_ListToMask
; Description ...: Convert include/exclude lists to SRE format
; Syntax ........: _RFLTA_ListToMask(ByRef $sMask, $sList)
; Parameters ....: $asList - Include/Exclude list to convert
; Return values .: Success: Converted list
;                  Failure: 0
; Author ........: SRE patterns developed from those posted by various forum members and Spiff59 in particular
; Remarks .......: This function is used internally by _RecFileListToArray
; ===============================================================================================================================
Func _RFLTA_ListToMask($sList)

	; Check for invalid characters within list
	If StringRegExp($sList, "\\|/|:|\<|\>|\|") Then Return 0
	; Strip WS and insert | for ;
	$sList = StringReplace(StringStripWS(StringRegExpReplace($sList, "\s*;\s*", ";"), 3), ";", "|")
	; Convert to SRE pattern
	$sList = StringReplace(StringReplace(StringRegExpReplace($sList, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
	; Add prefix and suffix
	Return "(?i)^(" & $sList & ")\z"

EndFunc   ;==>_RFLTA_ListToMask
#ce