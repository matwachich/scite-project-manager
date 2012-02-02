#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#NoTrayIcon

#include <Array.au3>

#include "Lang.au3"
#include "Const.au3"
#include "GUI.au3"
#include "Projects.au3"
#include "TreeView.au3"
#include "Events.au3"
#include "Misc.au3"

_Lang_Load()

_GUI_Main()
_GUI_Main($__GUI_Show)

OnAutoItExitRegister("_OnExit")

If Not @Compiled Then
	HotKeySet("!t", "_Debug_ShowArray_TV")
	HotKeySet("!p", "_Debug_ShowArray_Projects")
EndIf

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $Menu_Exit
			Exit
		Case $Menu_New
			_Event_New()
		Case $Menu_Open
			_Event_Open()
		; ---
		Case $Menu_Save
			_Event_Save()
		Case $Menu_SaveAs
			_Event_SaveAs()
		; ---
		Case $Menu_Close
			_Event_Close()
		; ---
		Case $Menu_AddFile
			_Event_AddFile()
	EndSwitch
WEnd

Func _OnExit()
	_Event_Close(1)
	_GUI_Main($__GUI_Delete)
EndFunc

; ##############################################################

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndTreeview
    $hWndTreeview = $hTree
    If Not IsHWnd($hTree) Then $hWndTreeview = GUICtrlGetHandle($hTree)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
	
    Switch $hWndFrom
        Case $hWndTreeview
            Switch $iCode
                Case $NM_CLICK ; The user has clicked the left mouse button within the control
                    _DebugPrint("$NM_CLICK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
;~                  Return 1 ; nonzero to not allow the default processing
                    Return 0 ; zero to allow the default processing
                Case $NM_DBLCLK ; The user has double-clicked the left mouse button within the control
                    _DebugPrint("$NM_DBLCLK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
					_Event_TV_DblClick(_GuiCtrlTreeView_GetSelection($hTree))
;~                  Return 1 ; nonzero to not allow the default processing
                    Return 0 ; zero to allow the default processing
                Case $NM_RCLICK ; The user has clicked the right mouse button within the control
                    _DebugPrint("$NM_RCLICK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
;~                  Return 1 ; nonzero to not allow the default processing
                    Return 0 ; zero to allow the default processing
                Case $NM_RDBLCLK ; The user has clicked the right mouse button within the control
                    _DebugPrint("$NM_RDBLCLK" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
;~                  Return 1 ; nonzero to not allow the default processing
                    Return 0 ; zero to allow the default processing
                Case $NM_KILLFOCUS ; control has lost the input focus
                    _DebugPrint("$NM_KILLFOCUS" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
                    ; No return value
                Case $NM_RETURN ; control has the input focus and that the user has pressed the key
                    _DebugPrint("$NM_RETURN" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
;~                  Return 1 ; nonzero to not allow the default processing
                    Return 0 ; zero to allow the default processing
;~              Case $NM_SETCURSOR ; control is setting the cursor in response to a WM_SETCURSOR message
;~                  Local $tinfo = DllStructCreate($tagNMMOUSE, $ilParam)
;~                  $hWndFrom = HWnd(DllStructGetData($tinfo, "hWndFrom"))
;~                  $iIDFrom = DllStructGetData($tinfo, "IDFrom")
;~                  $iCode = DllStructGetData($tinfo, "Code")
;~                  _DebugPrint("$NM_SETCURSOR" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
;~                          "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
;~                          "-->Code:" & @TAB & $iCode & @LF & _
;~                          "-->ItemSpec:" & @TAB & DllStructGetData($tinfo, "ItemSpec") & @LF & _
;~                          "-->ItemData:" & @TAB & DllStructGetData($tinfo, "ItemData") & @LF & _
;~                          "-->X:" & @TAB & DllStructGetData($tinfo, "X") & @LF & _
;~                          "-->Y:" & @TAB & DllStructGetData($tinfo, "Y") & @LF & _
;~                          "-->HitInfo:" & @TAB & DllStructGetData($tinfo, "HitInfo"))
;~                  Return 0 ; to enable the control to set the cursor
;~                  Return 1 ; nonzero to prevent the control from setting the cursor
                Case $NM_SETFOCUS ; control has received the input focus
                    _DebugPrint("$NM_SETFOCUS" & @LF & "--> hWndFrom:" & @TAB & $hWndFrom & @LF & _
                            "-->IDFrom:" & @TAB & $iIDFrom & @LF & _
                            "-->Code:" & @TAB & $iCode)
                    ; No return value
                Case $TVN_BEGINDRAGA, $TVN_BEGINDRAGW
                    _DebugPrint("$TVN_BEGINDRAG")
                Case $TVN_BEGINLABELEDITA, $TVN_BEGINLABELEDITW
                    _DebugPrint("$TVN_BEGINLABELEDIT")
                Case $TVN_BEGINRDRAGA, $TVN_BEGINRDRAGW
                    _DebugPrint("$TVN_BEGINRDRAG")
                Case $TVN_DELETEITEMA, $TVN_DELETEITEMW
                    _DebugPrint("$TVN_DELETEITEM")
                Case $TVN_ENDLABELEDITA, $TVN_ENDLABELEDITW
                    _DebugPrint("$TVN_ENDLABELEDIT")
                Case $TVN_GETDISPINFOA, $TVN_GETDISPINFOW
                    _DebugPrint("$TVN_GETDISPINFO")
                Case $TVN_GETINFOTIPA, $TVN_GETINFOTIPW
                    _DebugPrint("$TVN_GETINFOTIP")
                Case $TVN_ITEMEXPANDEDA, $TVN_ITEMEXPANDEDW
                    _DebugPrint("$TVN_ITEMEXPANDED")
                Case $TVN_ITEMEXPANDINGA, $TVN_ITEMEXPANDINGW
                    _DebugPrint("$TVN_ITEMEXPANDING")
                Case $TVN_KEYDOWN
                    _DebugPrint("$TVN_KEYDOWN")
                Case $TVN_SELCHANGEDA, $TVN_SELCHANGEDW
                    _DebugPrint("$TVN_SELCHANGED")
                Case $TVN_SELCHANGINGA, $TVN_SELCHANGINGW
                    _DebugPrint("$TVN_SELCHANGING")
                Case $TVN_SETDISPINFOA, $TVN_SETDISPINFOW
                    _DebugPrint("$TVN_SETDISPINFO")
                Case $TVN_SINGLEEXPAND
                    _DebugPrint("$TVN_SINGLEEXPAND")
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func _DebugPrint($s_text, $line = @ScriptLineNumber)
    ;ConsoleWrite( _
    ;        "!===========================================================" & @LF & _
     ;       "+======================================================" & @LF & _
    ;        "-->Line(" & StringFormat("%04d", $line) & "):" & @TAB & $s_text & @LF & _
     ;       "+======================================================" & @LF)
EndFunc   ;==>_DebugPrint
