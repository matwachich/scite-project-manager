#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------

Func _Scite_Init()
	If Not FileExists($__Au3Dir & "\autoit3.exe") Then
		If Not _Ask(LNG("scite_au3notfound")) Then
			Exit
		Else
			Return 0
		EndIf
	EndIf
	; ---
	Local $timer, $run = 0
	If Not WinExists("[Class:SciTEWindow]") Then
		$run = 1
		Run($__Au3Dir & "\scite\scite.exe")
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
	EndIf
	Return $run
EndFunc

Func _Scite_Maximize()
	;WinSetState("[Class:SciTEWindow]", "", @SW_MAXIMIZE)
	;_ArrayDisplay($__SciTE_OldPos)
	WinMove("[Class:SciTEWindow]", "", 0, 0, @DesktopWidth, @DesktopHeight - _TaskBar_GetHeight())
	WinActivate("[Class:SciTEWindow]")
EndFunc

Func _Scite_Adapt($iOnlyResize = 0)
	;Local $pos = WinGetPos("[Class:SciTEWindow]")
	;If IsArray($pos) Then _
	;	$__SciTE_OldPos = $pos
	; ---
	$pos = WinGetPos($GUI_Main)
	WinMove("[Class:SciTEWindow]", "", $pos[2], 0, @DesktopWidth - $pos[2], @DesktopHeight - _TaskBar_GetHeight())
	; ---
	If $iOnlyResize Then Return
	; ---
	;WinSetState("[Class:SciTEWindow]", "", @SW_MINIMIZE)
	WinActivate($GUI_Main)
	WinActivate("[Class:SciTEWindow]")
EndFunc

; ##############################################################

Func _TaskBar_GetHeight()
	Local $pos = WinGetPos("[Class:Shell_TrayWnd]")
	Return $pos[3]
EndFunc
