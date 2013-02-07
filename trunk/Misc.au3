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

Func _Messages_Recv($sMsg)
	;MsgBox(0, "DEBUG", "Massage:" & @CRLF & $sMsg)
	$sMsg = StringSplit($sMsg, "|")
	Switch $sMsg[1]
		Case "open"
			_LoadWorkspace($sMsg[2])
			_LoadProject($sMsg[2])
	EndSwitch
EndFunc

; ##############################################################

Func _FirstLaunch()
	; AutoIt Path
	Local $sPath = CFG("scite_dir")
	; $sPath est récupéré par défaut du registre
	If Not FileExists($sPath) Then
		; On suppose que SPM.exe est dans un sous-répertoire du dossier de SciTE, comme la plupart
		; des utilitaires de SciTE
		$sPath = @ScriptDir & "\..\Scite.exe"
		If Not FileExists($sPath) Then
			; Si on ne trouve toujours pas SciTE, on ouvre FileOpenDialog
			$sPath = FileOpenDialog(LNG("first_prompt_findScite"), @WorkingDir, "Executable (*.exe)", 3, "Scite.exe")
			If Not $sPath Or @error Then _Err(LNG("first_err_sciteNotFound"), 1) ; critical -> Exit
			If _Ask(LNG("first_ask_sciteRelative")) Then _
				$sPath = _PathGetRelative(@ScriptDir, $sPath)
			_AutoCfg_SetEntry("scite_dir", $sPath)
		EndIf
	EndIf
	; ---
	If FileExists(@ScriptDir & "\first_launch") Then Return
	; ---
	; File Association
	If _Ask(LNG("first_ask_assoc")) Then __Associate(1)
	; ---
	; SciTE Adapte
	If _Ask(LNG("first_ask_sciteAdapt")) Then
		_AutoCfg_SetEntry("adapt_scite", $GUI_CHECKED)
	Else
		_AutoCfg_SetEntry("adapt_scite", $GUI_UNCHECKED)
	EndIf
	; ---
	; mark
	FileClose(FileOpen(@ScriptDir & "\first_launch", 2))
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

Func _Last_Del($sPath)
	Local $read = CFG("last_projects")
	$read = StringReplace($read, "|" & $sPath, "")
	_AutoCfg_SetEntry("last_projects", $read)
	; ---
	Local $read = CFG("last_workspaces")
	$read = StringReplace($read, "|" & $sPath, "")
	_AutoCfg_SetEntry("last_workspaces", $read)
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

Func _File_Create($sPath, $iOverwrite = 0)
	If FileExists($sPath) And Not $iOverwrite Then Return
	; ---
	If _File_GetExt($sPath) = "au3" And FileExists(@WindowsDir & "\shellnew\template.au3") Then
		FileCopy(@WindowsDir & "\shellnew\template.au3", $sPath, 8)
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

Func _Debug_SciteCmd()
	Local $in = InputBox("Debug", "Send Command to SciTE")
	If Not $in Or @error Then Return
	; ---
	SendSciTE_Command($in, 1)
EndFunc
