#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=res\icon.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=A simple Project Manager For Scite4AutoIt. Made with AutoIt, for AutoIt.
#AutoIt3Wrapper_Res_Description=Scite Project Manager
#AutoIt3Wrapper_Res_Fileversion=1.2.0.1
#AutoIt3Wrapper_Res_LegalCopyright=Matwachich - 2012
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Icon_Add=res\ico_project.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_folder.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_au3.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_txt.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_ini.ico
#AutoIt3Wrapper_Res_Icon_Add=res\ico_blank.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_newProject.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_open.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_save.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_newFile.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_newFolder.ico
#AutoIt3Wrapper_Res_Icon_Add=res\btn\btn_delete.ico
#AutoIt3Wrapper_Res_Icon_Add=res\project.ico
#AutoIt3Wrapper_Run_After=copy /Y "%out%" "%scitedir%\SciteProjectManager\SPM.exe"
#AutoIt3Wrapper_Run_After=copy /Y %scriptdir%\Lang\Francais.lng" "%scitedir%\SciteProjectManager\lang\Francais.lng"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.8.1
	Author:         Matwachich

	Script Function:
		Project Manager for SciTE4AutoIt

#ce ----------------------------------------------------------------------------

Opt("GUICloseOnEsc", 0)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)
; For SciTE Director
Opt("WinSearchChildren", 1)

#include <Constants.au3>
#include <Array.au3>
#include <Misc.au3>
#include "lib\AutoConfig.au3"
#include "lib\Messages.au3"
; ---

; si une occurence existe déja, on envoit l'instruction d'ouvrir les fichiers et on ferme
If Not StringInStr($CmdLineRaw, "/restart") And Not _Singleton("SCITE_PROJECT_MANAGER_SINGLETON_OCCURENCE_NAME", 1) Then
	For $i = 1 To $CmdLine[0]
		_MsgSend("SCITE_PROJECT_MANAGER_MESSAGES_RECEIVER", "open|" & $CmdLine[$i])
	Next
	WinActivate("SPM")
	Exit
EndIf

; ---
_AutoCfg_Init($ACFG_INI, @ScriptDir & "\spm_config.ini", "SPM_Configuration")
	_AutoCfg_AddEntry("last_projects", "")
	_AutoCfg_AddEntry("last_workspaces", "")
	_AutoCfg_AddEntry("last_saveCount", 5)
	_AutoCfg_AddEntry("last_workingDir", @ScriptDir)
	_AutoCfg_AddEntry("lang_file", "English.lng")
	_AutoCfg_AddEntry("scite_dir", RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir") & "\Scite\Scite.exe")
	; ---
	; $GUI_CHECKED = 1, $GUI_UNCHECKED = 4
	_AutoCfg_AddEntry("rename_askConfirmation", 1)
	_AutoCfg_AddEntry("rename_backupFile", 1)
	_AutoCfg_AddEntry("minToTray", 1)
	_AutoCfg_AddEntry("adapt_scite", 1)
	_AutoCfg_AddEntry("workdir_onActivate", 1)
	_AutoCfg_AddEntry("win_size", "180,400")
	_AutoCfg_AddEntry("winSearch_size", "")
_AutoCfg_Update()

Global Const $__ResDir = @ScriptDir & "\res"
Global Const $__Version = "1.2.0.1"
; ---
Global $__TV_DragMode = 0, $__TV_Drag_hItem = 0
Global $__TV_EditedItem = 0

; si 1, quand on a lancé depuis SciTE, on ne fermera pas SciTE à la fin (voir _onExit)
Global $__RunFromScite = 0
Global $__User32_Dll = DllOpen("user32.dll")

#include "Lang.au3"
#include "GUI.au3"
#include "Projects.au3"
#include "TreeView.au3"
#include "Events.au3"
#include "Misc.au3"
#include "Config.au3"
#include "Scite.au3"
#include "Search.au3"

_Lang_Load()

TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_Tray_Event_Click")
FileChangeDir(CFG("last_workingDir"))

_FirstLaunch()

_GUI_Main()
_Scite_Run()

_GUI_Main($__GUI_Show)
_Scite_Adapt()

_CmdLine_Parse()

_MsgRegister("SCITE_PROJECT_MANAGER_MESSAGES_RECEIVER", "_Messages_Recv")

OnAutoItExitRegister("_OnExit")

If Not @Compiled Then
	HotKeySet("!t", "_Debug_ShowArray_TV")
	HotKeySet("!p", "_Debug_ShowArray_Projects")
	HotKeySet("!a", "_Debug_Show_ActifProject")
	HotKeySet("!v", "_Debug_SciteCmd")
EndIf

While 1
	$nMsg = GUIGetMsg(1)
	;If $nMsg[0] > 0 Then ConsoleWrite("Msg From " & $nMsg[1] & ": " & $nMsg[0] & @CRLF)
	; ---
	Select
		Case $GUI_Main <> 0 And $nMsg[1] = $GUI_Main
		; ---
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE, $Menu_Exit
					; retourne 0 si il y a eu un clique sur Annuler
					If _Project_SaveAll() Then Exit
				Case $GUI_EVENT_MINIMIZE
					If CFG("minToTray") = $GUI_CHECKED Then
						_GUI_Main($__GUI_Hide)
						Opt("TrayIconHide", 0)
						TraySetToolTip(LNG("tray_tip"))
					EndIf
					_Scite_Maximize()
				Case $GUI_EVENT_RESTORE, $GUI_EVENT_MAXIMIZE
					_Scite_Adapt()
				; ---
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
				Case $Menu_Close, $CMenu_Close
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
				Case $Menu_Search
					_Event_Search()
				Case $Menu_AddFile, $Btn_AddFile, $CMenu_AddFile
					_Event_AddFile()
				Case $Menu_AddFolder, $Btn_AddFolder, $CMenu_AddFolder
					_Event_AddFolder()
				Case $Menu_Delete, $Btn_Delete, $CMenu_Delete
					_Event_Delete()
				; ---
				Case $Menu_RunScite
					_Scite_Run()
					_Scite_Adapt()
				Case $Menu_Cfg
					_GUI_Cfg()
					_Cfg_Load()
					_GUI_Cfg($__GUI_Show)
					GuiSetState(@SW_DISABLE, $GUI_Main)
				Case $Menu_Bug
					ShellExecute("http://code.google.com/p/scite-project-manager/issues/list")
				Case $Menu_About
					_About()
				; ---
				;Case $CMenu_Close
				;	ConsoleWrite("> CMenu_Close" & @CRLF)
				Case $CMenu_OpenAll
					_Event_OpenAll()
				;Case $CMenu_AddFile
				;	ConsoleWrite("> CMenu_AddFile" & @CRLF)
				;Case $CMenu_AddFolder
				;	ConsoleWrite("> CMenu_AddFolder" & @CRLF)
				Case $CMenu_Rename
					_Event_Edit()
				;Case $CMenu_Delete
				;	ConsoleWrite("> CMenu_Delete" & @CRLF)
				Case $CMenu_Browse
					_Event_Browse()
				; ---
				Case $GUI_EVENT_MOUSEMOVE
					__TV_HandleDrag()
			EndSwitch
			; ---
			; Last Project/Workspace
			For $i = $__Last[0][0] To 1 Step -1
				If $nMsg[0] = $__Last[$i][0] Then
					; ---
					; vérifie si le fichier existe, sinon, on l'enlève de l'historique
					If Not FileExists($__Last[$i][1]) Then
						_Err(LNG("err_history_fileNotFound"))
						_GUI_LastMenu_Delete($i)
					Else
						; ---
						_LoadWorkspace($__Last[$i][1])
						_LoadProject($__Last[$i][1])
					EndIf
				EndIf
			Next
		; ---
		Case $GUI_Cfg <> 0 And $nMsg[1] = $GUI_Cfg
		; ---
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					_GUI_Cfg($__GUI_Delete)
					GuiSetState(@SW_ENABLE, $GUI_Main)
					WinActivate($GUI_Main)
				Case $B_Ok
					_Cfg_Save()
					_GUI_Cfg($__GUI_Delete)
					GuiSetState(@SW_ENABLE, $GUI_Main)
					WinActivate($GUI_Main)
			EndSwitch
		; ---
		Case $GUI_Search <> 0 And $nMsg[1] = $GUI_Search
		; ---
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					_GUI_Search($__GUI_Delete)
					$__Search_CurrentResult = 0
			EndSwitch
	EndSelect
	; ---
WEnd

Func _Tray_Event_Click()
	Opt("TrayIconHide", 1)
	_GUI_Main($__GUI_Show)
	_Scite_Adapt()
EndFunc

Func _OnExit()
	; Save GUI Size
	_Win_SaveSize()
	; Ce _Event_Close est avec $iDontSave = 1, car on a sauvegarder dans la boucle principale
	_Event_Close(1, 1)
	_GUI_Main($__GUI_Delete)
	; ---
	_MsgRelease()
	DllClose($__User32_Dll)
	; ---
	; Save current Workdir
	_AutoCfg_SetEntry("last_workingDir", @WorkingDir)
	; ---
	If $__RunFromScite = 0 And WinExists("[Class:SciTEWindow]") And _Ask(LNG("ask_closeScite")) Then
		WinClose("[Class:SciTEWindow]")
	Else
		_Scite_Maximize() ; maximize
	EndIf
EndFunc   ;==>_OnExit

; ##############################################################

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg, $iwParam
	Local $hWndFrom, $iCode, $tNMHDR, $Info ; TreeView & ToolBar
	Local $tInfo ; ListView & ToolTips
	Local $tNMTBHOTITEM, $i_idNew ; ToolBar Only
	Local $iID ; ToolTips Only

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
					Return
				; ---
				Case $NM_RCLICK
					Local $hItem = __TV_MouseItem()
					If $hItem Then
						_GuiCtrlTreeView_SelectItem($__hTree, $hItem)
						_Event_TV_RClick($hItem)
						_GUICtrlMenu_TrackPopupMenu($hCMenu, $GUI_Main)
					EndIf
					; notmalement, le traitement par défaut ne devrait pas se faire mais...
					Return
				;Case $NM_RDBLCLK
				;	Return 0
				; ---
				; Drag & Drop des items (FILE seulement)
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
					Return
				; ---
				; je veux que quand on expand/collapse un item, le projet soit mis en status Modifié
				; pour que la fonction de sauvegarde soit appelée, pour enregistrer le status des items
				; (Expanded/Collapsed)
				Case $TVN_ITEMEXPANDEDA, $TVN_ITEMEXPANDEDW
					$__TV_Drag_hItem = __TV_MouseItem()
					If $__TV_Drag_hItem Then
						$Info = _TV_ItemGetInfo($__TV_Drag_hItem)
						__OpenProject_SetModified($Info[2])
					EndIf
				; ---
				; Edit
				;Case $TVN_BEGINLABELEDITA, $TVN_BEGINLABELEDITW
				;	$__TV_EditedItem = _GuiCtrlTreeView_GetSelection($__hTree)
				;	ConsoleWrite("Start " & $__TV_EditedItem & @CRLF)
				; ---
				Case $TVN_ENDLABELEDITA, $TVN_ENDLABELEDITW
					Local $sText = _GuiCtrlEdit_GetText(_GUICtrlTreeView_GetEditControl($__hTree))
					If $sText Then
						Return _TV_AfterRename(_GuiCtrlTreeView_GetSelection($__hTree), $sText)
					Else
						Return False
					EndIf
				; ---
				;Case $TVN_KEYDOWN
					;ConsoleWrite($tagNMTVKEYDOWN & @CRLF)
					;$tNMTVKEYDOWN = DllStructCreate($tagNMTVKEYDOWN, $ilParam)
					;ConsoleWrite(DllStructGetData($tNMTVKEYDOWN, "VKey") & @CRLF)
					;ConsoleWrite(DllStructGetData($tNMTVKEYDOWN, "Flags") & @CRLF)
				; ---
				;Case $NM_KILLFOCUS
				;	ConsoleWrite("Kill Focus" & @CRLF)
				;Case $NM_SETFOCUS
				;	ConsoleWrite("Set Focus" & @CRLF)
			EndSwitch
			Return $GUI_RUNDEFMSG
		; ##############################################################
		; ToolBar
		Case $__hToolBar
			Switch $iCode
				Case $NM_LDOWN
					;ConsoleWrite("$NM_LDOWN: Clicked Item: " & $__hToolBar_HotItem & @CRLF)
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
		; ---
		; List View (Search)
		Case $__hListView
			Switch $iCode
				Case $NM_DBLCLK
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					_Search_Event_OpenResult(DllStructGetData($tInfo, "Index"))
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
