; By Matwachich, inspiré par Tlem
; Dans la fonction de Tlem, la taille minimum/maximum avait effet sur
; 	toutes les GUIs
#Include-Once
#include <Array.au3>

Global $__GUI_MinMax[1][5] = [[0, "", "", "", ""]]

; #FUNCTION# ;===============================================================================
;
; Name...........: _GUI_MinMax_Set
; Description ...: Set Maximum & Minimun size for a resizable GUI
; Syntax.........: _GUI_MinMax_Set($hGUI, $iMin_X, $iMin_Y, $iMax_X, $iMax_Y)
; Parameters ....: $hGUI - Handle of the GUI
;                  $iMin_X - Minimun Width
;                  $iMin_Y - Minimum Height
;                  $iMax_X - Maximum Width
;                  $iMax_Y - Maximum Height
; Return values .: 1
; Author ........: Matwachich, inspired by Tlem
; Remarks .......: This function registers the $WM_GETMINMAXINFO message
;
; ;==========================================================================================
Func _GUI_MinMax_Set($hGUI, $iMin_X, $iMin_Y, $iMax_X, $iMax_Y)
	ReDim $__GUI_MinMax[$__GUI_MinMax[0][0] + 2][5]
	$__GUI_MinMax[0][0] += 1
	$__GUI_MinMax[$__GUI_MinMax[0][0]][0] = $hGUI
	$__GUI_MinMax[$__GUI_MinMax[0][0]][1] = $iMin_X
	$__GUI_MinMax[$__GUI_MinMax[0][0]][2] = $iMin_Y
	$__GUI_MinMax[$__GUI_MinMax[0][0]][3] = $iMax_X
	$__GUI_MinMax[$__GUI_MinMax[0][0]][4] = $iMax_Y
	; ---
	GUIRegisterMsg(0x24, "__GUI_MinMax_WM_GETMINMAXINFO") ; $WM_GETMINMAXINFO
	; ---
	Return 1
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _GUI_MinMax_Unset
; Description ...: Unset Maximum & Minimun size of a resizable GUI
; Syntax.........: _GUI_MinMax_Unset($hGUI)
; Parameters ....: $hGUI - Handle of the GUI
; Return values .: Success - 1
;                  Failure - 0
; Author ........: Matwachich
; Remarks .......:
;
; ;==========================================================================================
Func _GUI_MinMax_Unset($hGUI)
	For $i = $__GUI_MinMax[0][0] To 1 Step -1
		If $__GUI_MinMax[$i][0] = $hGUI Then
			_ArrayDelete($__GUI_MinMax, $i)
			$__GUI_MinMax[0][0] -= 1
			Return 1
		EndIf
	Next
	; ---
	Return 0
EndFunc

; ##############################################################

Func __GUI_MinMax_WM_GETMINMAXINFO($hWnd, $Msg, $wParam, $lParam)
	Local $minmaxinfo = DllStructCreate('int;int;int;int;int;int;int;int;int;int', $lParam)
	; ---
	For $i = 1 To $__GUI_MinMax[0][0]
		If $hWnd = $__GUI_MinMax[$i][0] Then
			DllStructSetData($minmaxinfo, 7, $__GUI_MinMax[$i][1]); min X
			DllStructSetData($minmaxinfo, 8, $__GUI_MinMax[$i][2]); min Y
			DllStructSetData($minmaxinfo, 9, $__GUI_MinMax[$i][3]); max X
			DllStructSetData($minmaxinfo, 10, $__GUI_MinMax[$i][4]); max Y
			ExitLoop
		EndIf
	Next
	; ---
    Return 'GUI_RUNDEFMSG'
EndFunc
