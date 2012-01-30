#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

Func _Event_Open()
	Local $path = FileOpenDialog(LNG("progName"), @WorkingDir, "Projects/Projects Groups (*.pnproj;*.ppg)|All (*.*)", 7, "", $GUI_Main)
	If @error Or Not $path Then Return
	; ---
	If Not StringInStr($path, "|") Then
		_LoadWorkspace($path)
		_LoadProject($path)
	Else
		$path = StringSplit($path, "|")
		If StringRight($path[1], 1) <> "\" Then $path[1] &= "\"
		; ---
		For $i = 2 To $path[0]
			_LoadWorkspace($path[1] & $path[$i])
			_LoadProject($path[1] & $path[$i])
		Next
	EndIf
EndFunc

Func _Event_TV_DblClick($hItem)
	$info = _TV_ItemGetInfo($hItem)
	For $elem In $info
		ConsoleWrite($elem & @CRLF)
	Next
	ConsoleWrite("===" & @CRLF)
EndFunc