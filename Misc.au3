#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

Func _Err($sText, $iCritical = 0)
	MsgBox(16, LNG("progName"), $sText)
	If $iCritical Then Exit
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
