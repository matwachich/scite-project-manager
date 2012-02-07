#NoTrayIcon

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
; ---
#AutoIt3Wrapper_Res_Icon_Add=res\ico_project.ico ; 4
#AutoIt3Wrapper_Res_Icon_Add=res\ico_folder.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_au3.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_txt.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_ini.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_blank.ico
; ---
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_newProject.ico ; 10
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_open.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_save.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_newFile.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_newFolder.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_delete.ico ; 15
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.3.8.0
	Author:         Matwachich
	
	Script Function:
		Project Manager for SciTE4AutoIt
	
#ce ----------------------------------------------------------------------------

Opt("GUICloseOnEsc", 0)

#include <Array.au3>
#include <Misc.au3>
#include "lib\AutoConfig.au3"

_AutoCfg_Init($ACFG_INI, @ScriptDir & "\spm_config.ini", "SPM_Configuration")
	_AutoCfg_AddEntry("last_projects", "")
	_AutoCfg_AddEntry("last_workspaces", "")
	_AutoCfg_AddEntry("last_saveCount", 5)
_AutoCfg_Update()


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
	HotKeySet("!a", "_Debug_Show_ActifProject")
EndIf

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $Menu_Exit
			If _Project_SaveAll() Then Exit
		Case $Menu_New, $Btn_New
			_Event_New()
		Case $Menu_Open, $Btn_Open
			_Event_Open()
			; ---
		Case $Menu_Save, $Btn_Save
			_Event_Save()
		Case $Menu_SaveAs
			_Event_SaveAs()
		Case $Menu_SaveAll
			_Event_SaveAll()
		Case $Menu_SaveWorkspace
			_Event_SaveWorkspace()
			; ---
		Case $Menu_Close
			_Event_Close()
		Case $Menu_CloseAll
			_Event_Close(1)
			; ---
		Case $Menu_LastProject_Flush
			_Last_Empty(1)
		Case $Menu_LastWorkspace_Flush
			_Last_Empty(2)
			; ---
		Case $Menu_SetActif
			_Event_SetActif()
		Case $Menu_AddFile, $Btn_AddFile
			_Event_AddFile()
		Case $Menu_AddFolder, $Btn_AddFolder
			_Event_AddFolder()
		Case $Menu_Delete, $Btn_Delete
			_Event_Delete()
		; ---
		Case $GUI_EVENT_MOUSEMOVE
			__TV_HandleDrag()
	EndSwitch
	; ---
	; Last Project/Workspace
	For $i = 1 To $__Last[0][0]
		If $nMsg = $__Last[$i][0] Then
			_LoadWorkspace($__Last[$i][1])
			_LoadProject($__Last[$i][1])
		EndIf
	Next
WEnd

Func _OnExit()
	; Ce _Event_Close est avec $iDontSave = 1, car on a sauvegarder dans la boucle principale
	_Event_Close(1, 1)
	_GUI_Main($__GUI_Delete)
	DllClose($__User32_Dll)
EndFunc   ;==>_OnExit

; ##############################################################

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg, $iwParam
	Local $hWndFrom, $iCode, $tNMHDR, $Info ; TreeView & ToolBar
	Local $tNMTBHOTITEM, $i_idNew ; ToolBar Only
	Local $tInfo, $iID ; ToolTips Only

	$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iCode = DllStructGetData($tNMHDR, "Code")
	
	Switch $hWndFrom
		; TreeView
		Case $__hTree
			Switch $iCode
				;Case $NM_CLICK	
				;	Return 0
				Case $NM_DBLCLK
					_Event_TV_DblClick(_GUICtrlTreeView_GetSelection($__hTree))
					Return 0
				;Case $NM_RCLICK
				;	Return 0
				;Case $NM_RDBLCLK
				;	Return 0
				; ---
				Case $TVN_BEGINDRAGA, $TVN_BEGINDRAGW
					$__TV_Drag_hItem = __TV_MouseItem()
					If $__TV_Drag_hItem Then
						$Info = _TV_ItemGetInfo($__TV_Drag_hItem)
						If $Info[1] = "FILE" Then
							$__TV_DragMode = 1
							;ConsoleWrite("Drag ON" & @CRLF)
						Else
							$__TV_Drag_hItem = 0
						EndIf
					EndIf
			EndSwitch
			Return $GUI_RUNDEFMSG
		; ##############################################################
		; ToolBar
		Case $__hToolBar
			Switch $iCode
				Case $NM_LDOWN
					ConsoleWrite("$NM_LDOWN: Clicked Item: " & $__hToolBar_HotItem & @CRLF)
					Switch $__hToolBar_HotItem
						Case $Btn_New
							_Event_New()
						Case $Btn_Open
							_Event_Open()
						Case $Btn_Save
							_Event_Save()
						Case $Btn_AddFile
							_Event_AddFile()
						Case $Btn_AddFolder
							_Event_AddFolder()
						Case $Btn_Delete
							_Event_Delete()
					EndSwitch
				Case $TBN_HOTITEMCHANGE
					$tNMTBHOTITEM = DllStructCreate($tagNMTBHOTITEM, $ilParam)
					$i_idNew = DllStructGetData($tNMTBHOTITEM, "idNew")
					$__hToolBar_HotItem = $i_idNew
			EndSwitch
			Return $GUI_RUNDEFMSG
	EndSwitch
	
	; ##############################################################
	; ToolTips
	$tInfo = DllStructCreate($tagNMTTDISPINFO, $ilParam)
	$iCode = DllStructGetData($tInfo, "Code")
	If $iCode = $TTN_GETDISPINFOW Then
		$iID = DllStructGetData($tInfo, "IDFrom")
		Switch $iID
			Case $Btn_New
				DllStructSetData($tInfo, "aText", StringReplace(LNG("Menu_New"), @TAB, " "))
			Case $Btn_Open
				DllStructSetData($tInfo, "aText", StringReplace(LNG("Menu_Open"), @TAB, " "))
			Case $Btn_Save
				DllStructSetData($tInfo, "aText", StringReplace(LNG("Menu_Save"), @TAB, " "))
			Case $Btn_AddFile
				DllStructSetData($tInfo, "aText", StringReplace(LNG("Menu_AddFile"), @TAB, " "))
			Case $Btn_AddFolder
				DllStructSetData($tInfo, "aText", StringReplace(LNG("Menu_AddFolder"), @TAB, " "))
			Case $Btn_Delete
				DllStructSetData($tInfo, "aText", StringReplace(LNG("Menu_Delete"), @TAB, " "))
		EndSwitch
	EndIf
	
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
