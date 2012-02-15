#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------

Global $__Scite_hWnd = 0
Global $__SciTE_LastAnswer = ""


Func _Scite_Run()
	If WinExists("[Class:SciTEWindow]") Then
		While 1
			$__Scite_hWnd = WinGetHandle("DirectorExtension")
			If $__Scite_hWnd Then ExitLoop
		WEnd
		Return 1
	EndIf
	; ---
	Run(CFG("scite_dir"))
	$timer = TimerInit()
	Do
		Sleep(50)
		If TimerDiff($timer) >= 5000 Then
			If Not _Ask(LNG("scite_nolaunch")) Then
				Exit
			Else
				Return 0
			EndIf
		EndIf
	Until WinExists("[Class:SciTEWindow]")
	; ---
	While 1
		$__Scite_hWnd = WinGetHandle("DirectorExtension")
		If $__Scite_hWnd Then ExitLoop
	WEnd
	Return 1
EndFunc

Func _Scite_OpenFile($sPath)
	SendSciTE_Command('open:' & StringStripWS(StringReplace($sPath, "\", "\\"), 3))
	;ConsoleWrite("Answer: " & _Scite_WaitAnswer() & " - Err: " & @error & @CRLF)
EndFunc

; ##############################################################

; Send command to SciTE
Func SendSciTE_Command($sCmd, $iAnswer = 0)
	If Not _Scite_Run() Then Return _Err(LNG("scite_nolaunch"))
	; ---
	$sCmd = ":" & $GUI_Main_Dec & ":" & $sCmd
	ConsoleWrite('-->' & $sCmd & @LF)
	; ---
	Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
	DllStructSetData($CmdStruct, 1, $sCmd)
	; ---
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
	DllStructSetData($COPYDATA, 1, 1)
	DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
	DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
	; ---
	DllCall($__User32_Dll, 'None', 'SendMessage', _
		'HWnd', $__Scite_hWnd, _
		'Int', $WM_COPYDATA, _
		'HWnd', $GUI_Main, _
		'Ptr', DllStructGetPtr($COPYDATA))
	; ---
	If $iAnswer Then _
		Return SetError(@error, @extended, _Scite_WaitAnswer(500))
EndFunc   ;==>SendSciTE_Command
; ---

Func _Scite_WaitAnswer($iTimeOut = 1000) ; 1000 ms
	Local $timer = TimerInit()
	While Not $__SciTE_LastAnswer
		If TimerDiff($timer) >= $iTimeOut Then Return SetError(1, 0, "")
	WEnd
	Local $ret = $__SciTE_LastAnswer
	$__SciTE_LastAnswer = ""
	Return $ret
EndFunc
; ---

; Received Data from SciTE
Func MY_WM_COPYDATA($hWnd, $msg, $wParam, $lParam)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
	$SciTECmdLen = DllStructGetData($COPYDATA, 2)
	Local $CmdStruct = DllStructCreate('Char[' & $SciTECmdLen + 1 & ']', DllStructGetData($COPYDATA, 3))
	$SciTECmd = StringLeft(DllStructGetData($CmdStruct, 1), $SciTECmdLen)
	$SciTECmd = StringTrimLeft($SciTECmd, StringInStr($SciTECmd, ":", 0, 1, 2))
	;ConsoleWrite("Recv: " & $SciTECmd & @CRLF)
	$__SciTE_LastAnswer = $SciTECmd
EndFunc   ;==>MY_WM_COPYDATA

; ##############################################################

Func _Scite_Maximize()
	;WinSetState("[Class:SciTEWindow]", "", @SW_MAXIMIZE)
	;_ArrayDisplay($__SciTE_OldPos)
	; ---
	If CFG("adapt_scite") = $GUI_UNCHECKED Then Return
	; ---
	; If the SciTE win is minimized, dont maximize it
	If Not BitAND(WinGetState("[Class:SciTEWindow]"), 32) Then Return
	; ---
	WinMove("[Class:SciTEWindow]", "", 0, 0, @DesktopWidth, @DesktopHeight - _TaskBar_GetHeight())
	WinActivate("[Class:SciTEWindow]")
EndFunc

Func _Scite_Adapt($iOnlyResize = 0)
	;Local $pos = WinGetPos("[Class:SciTEWindow]")
	;If IsArray($pos) Then _
	;	$__SciTE_OldPos = $pos
	; ---
	If CFG("adapt_scite") = $GUI_UNCHECKED Then Return
	; ---
	; cette variable est mise à 1 dans WM_SIZE
	If Not $iOnlyResize Then WinActivate("[Class:SciTEWindow]")
	; ---
	$pos = WinGetPos($GUI_Main)
	WinMove("[Class:SciTEWindow]", "", $pos[2], 0, @DesktopWidth - $pos[2], @DesktopHeight - _TaskBar_GetHeight())
	; ---
	;WinSetState("[Class:SciTEWindow]", "", @SW_MINIMIZE)
	;WinActivate($GUI_Main)
	;WinActivate("[Class:SciTEWindow]")
EndFunc

; ##############################################################

Func _TaskBar_GetHeight()
	Local $pos = WinGetPos("[Class:Shell_TrayWnd]")
	Return $pos[3]
EndFunc
