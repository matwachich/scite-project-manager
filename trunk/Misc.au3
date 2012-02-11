#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

Func _CmdLine_Parse()
	If StringInStr($CmdLineRaw, "/fromScite") Then $__RunFromScite = 1
	; ---
	If $CmdLine[0] = 0 Then Return
	; ---
	For $i = 1 To $CmdLine[0]
		_LoadWorkspace($CmdLine[$i])
		_LoadProject($CmdLine[$i])
	Next
EndFunc

; ##############################################################

Func _Win_SaveSize()
	Local $pos = WinGetPos($GUI_Main)
	_AutoCfg_SetEntry("win_size", $pos[2] & "," & $pos[3])
EndFunc

Func _Win_GetSize($iWhat)
	Local $read = CFG("win_size")
	$read = StringSplit($read, ",")
	Switch $iWhat
		Case "x"
			Return $read[1]
		Case "y"
			Return $read[2]
	EndSwitch
EndFunc

; ##############################################################
; Historique des projets
; iType: 1 = project | 2 = workspace

Func _Last_Add($iType, $sPath)
	If CFG("last_saveCount") < 1 Then Return
	; ---
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

Func _About()
	GuiSetState(@SW_DISABLE, $GUI_Main)
	; ---
	#Region ### START Koda GUI section ### Form=
	Local $GUI_About = GUICreate("About", 323, 286, -1, -1, -1, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)
	GUICtrlCreateGroup("", 8, 8, 305, 233)
	Local $L_Spm = GUICtrlCreateLabel("Scite Project Manager", 60, 24, 205, 28)
		GUICtrlSetFont(-1, 16, 800, 0, "Times New Roman")
		GuiCtrlSetColor(-1, 0x0011FF)
		GuiCtrlSetCursor(-1, 0)
		GuiCtrlSetTip(-1, LNG("about_tip_title"))
	; ---
	GUICtrlCreateLabel("v " & $__Version, 60, 54, 205, 17, $SS_CENTER)
	GUICtrlCreateLabel(LNG("about"), 16, 82, 287, 155)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $B_OK = GUICtrlCreateButton("&OK", 124, 250, 75, 25)
	; ---
	Local $L_Com = GUICtrlCreateLabel("AutoItScript.com", 12, 246, 82, 17)
		GuiCtrlSetColor(-1, 0x0011FF)
		GuiCtrlSetCursor(-1, 0)
		GuiCtrlSetTip(-1, LNG("about_tip_com"))
	Local $L_Fr = GUICtrlCreateLabel("AutoItScript.fr", 240, 246, 68, 17)
		GuiCtrlSetColor(-1, 0x0011FF)
		GuiCtrlSetCursor(-1, 0)
		GuiCtrlSetTip(-1, LNG("about_tip_fr"))
	GUISetState(@SW_SHOW, $GUI_About)
	#EndRegion ### END Koda GUI section ###
	
	Local $msg
	While 1
		$msg = GuiGetMsg(1)
		If $msg[1] = $GUI_About Then
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE, $B_OK
					ExitLoop
				Case $L_Com
					ShellExecute("http://www.autoitscript.com")
					ExitLoop
				Case $L_Fr
					ShellExecute("http://www.autoitscript.fr")
					ExitLoop
				Case $L_Spm
					ShellExecute("http://code.google.com/p/scite-project-manager/")
					ExitLoop
			EndSwitch
		EndIf
	WEnd
	GuiDelete($GUI_About)
	; ---
	GuiSetState(@SW_ENABLE, $GUI_Main)
	WinActivate($GUI_Main)
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
	If _File_GetExt($sPath) = "au3" And FileExists(@WindowsDir & "\shellnew\template.au3") Then
		FileCopy(@WindowsDir & "\shellnew\template.au3", $sPath)
	Else
		FileClose(FileOpen($sPath, 10))
	EndIf
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

; ##############################################################
; voir:
;	- http://msdn.microsoft.com/en-us/library/windows/desktop/bb773785(v=vs.85).aspx
;	- http://msdn.microsoft.com/en-us/library/windows/desktop/bb773462(v=vs.85).aspx
;	- http://msdn.microsoft.com/en-us/library/windows/desktop/bb773456(v=vs.85).aspx

; doit prendre un Item Root (projet ou dossier)
Func _Project_Sort($iProjectID)
	Local $hItem = __OpenProject_GetItemHandle($iProjectID)
	If Not $hItem Then Return
	; ---
	; d'abord ça, pour organiser selon les textes des Items (car je n'ai pas stocké le texte dans $__TV_Assoc ! :S )
	_SendMessage($__hTree, $TVM_SORTCHILDREN, 1, $hItem, 0, "wparam", "handle")
	; ---
	; Le reste, c'est juste pour remettre les dossiers en haut
	Local $tagTVSORTCB = "HWND hParent;Long PFNTVCOMPARE;Long lParam"
	Local $sTVSORTCB = DllStructCreate($tagTVSORTCB)
	; ---
	Local $callback = DllCallbackRegister("__Sort_Callback", "int", "LPARAM;LPARAM;LPARAM")
	; ---
	DllStructSetData($sTVSORTCB, "hParent", $hItem)
	DllStructSetData($sTVSORTCB, "PFNTVCOMPARE", DllCallbackGetPtr($callback))
	DllStructSetData($sTVSORTCB, "lParam", 0)
	; ---
	_SendMessage($__hTree, $TVM_SORTCHILDRENCB, 0, DllStructGetPtr($sTVSORTCB), 0, "int", "int", "BOOL")
	;ConsoleWrite("_SendMessage: " & @error & @CRLF)
	; ---
	DllCallbackFree($callback)
EndFunc

; The lParam1 and lParam2 parameters correspond to the lParam member of the TVITEM structure for the two items being compared
; ce qui correspond à _GuiCtrlTreeView_SetItemParam !
Func __Sort_Callback($lParam1, $lParam2, $lParamSort)
	;ConsoleWrite("__Sort_Callback" & @CRLF)
	;ConsoleWrite(@TAB & "lParam1: " & $lParam1 & " = " & $__TV_Assoc[$lParam1][1] & @CRLF)
	;ConsoleWrite(@TAB & "lParam2: " & $lParam2 & " = " & $__TV_Assoc[$lParam2][1] & @CRLF)
	;ConsoleWrite(@TAB & "lParamSort: " & $lParamSort & @CRLF)
	; ---
	Local $Info1 = StringSplit($__TV_Assoc[$lParam1][1], "|")
	Local $Info2 = StringSplit($__TV_Assoc[$lParam2][1], "|")
	; ---
	Select
		Case $Info1[1] = "FILE" And $Info2[1] = "FILE"
			Return 0
		Case $Info1[1] = "FOLDER" And $Info2[1] = "FILE"
			_SendMessage($__hTree, $TVM_SORTCHILDREN, 1, $__TV_Assoc[$lParam1][0], 0, "wparam", "handle")
			Return -1
		Case $Info1[1] = "FILE" And $Info2[1] = "FOLDER"
			_SendMessage($__hTree, $TVM_SORTCHILDREN, 1, $__TV_Assoc[$lParam2][0], 0, "wparam", "handle")
			Return 1
	EndSelect
EndFunc
