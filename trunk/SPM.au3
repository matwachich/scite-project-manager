#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.3.8.0
	Author:         Matwachich
	
	Script Function:
	
	
#ce ----------------------------------------------------------------------------
#NoTrayIcon

#include <Array.au3>
#include <Misc.au3>

Global $__TV_DragMode = 0, $__TV_Drag_hItem = 0
Global $__User32_Dll = DllOpen("user32.dll")

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
		Case $Menu_CloseAll
			_Event_Close(1)
			; ---
		Case $Menu_SetActif
			_Event_SetActif()
		Case $Menu_AddFile
			_Event_AddFile()
		Case $Menu_AddFolder
			_Event_AddFolder()
		Case $Menu_Delete
			_Event_Delete()
		; ---
		Case $GUI_EVENT_MOUSEMOVE And $__TV_DragMode
			__TV_HandleDrag()
	EndSwitch
WEnd

Func _OnExit()
	_Event_Close(1)
	_GUI_Main($__GUI_Delete)
	DllClose($__User32_Dll)
EndFunc   ;==>_OnExit

; ##############################################################

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg, $iwParam
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndTreeview, $Info
	$hWndTreeview = $hTree
	If Not IsHWnd($hTree) Then $hWndTreeview = GUICtrlGetHandle($hTree)

	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	
	Switch $hWndFrom
		Case $hWndTreeview
			Switch $iCode
				;Case $NM_CLICK
					
				;	Return 0
				Case $NM_DBLCLK
					_Event_TV_DblClick(_GUICtrlTreeView_GetSelection($hTree))
					Return 0
				;Case $NM_RCLICK
				;	_Event_TV_RightClick(_GUICtrlTreeView_GetSelection($hTree))
				;	Return 0
				;Case $NM_RDBLCLK
				;	
				;	Return 0
					; ---
				Case $TVN_BEGINDRAGA, $TVN_BEGINDRAGW
					$__TV_Drag_hItem = __TV_MouseItem()
					If $__TV_Drag_hItem Then
						$Info = _TV_ItemGetInfo($__TV_Drag_hItem)
						If $Info[1] = "FILE" Then
							$__TV_DragMode = 1
						Else
							$__TV_Drag_hItem = 0
						EndIf
					EndIf
					#cs
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
					#ce
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
