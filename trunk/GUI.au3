#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include <GUIConstantsEx.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <UpdownConstants.au3>
#include <ComboConstants.au3>
#include <GuiTreeView.au3>
#include <GuiImageList.au3>
#include <GuiToolbar.au3>
#include <GuiToolTip.au3>
#include <StaticConstants.au3>
#Include <GuiListView.au3>

#include "lib\GUIMinMax.au3"

Global Enum $__GUI_Create, $__GUI_Delete, $__GUI_Show, $__GUI_Hide

Global Enum $Btn_New = 1000, $Btn_Open, $Btn_Save, $Btn_AddFile, $Btn_AddFolder, $Btn_Delete

; Taille min/max de la GUI
Global $aUtil_MinMax[4]

; ##############################################################
; GUI Main
Global $GUI_Main, $GUI_Main_Dec ; besoin pour envoyer des commandes à SciTE
Global $__hTree, $__hTreeView_ImageList
Global $__hToolBar, $__hToolBar_ImageList, $__hToolTip, $__hToolBar_HotItem
; ---
Global $Menu_File, _
			$Menu_New, $Menu_Open, $Menu_Save, $Menu_SaveAs, $Menu_SaveAll, $Menu_SaveWorkspace, $Menu_Close, $Menu_CloseAll, $Menu_Exit, _
			$Menu_LastProject, _
				$Menu_LastProject_Flush, _
			$Menu_LastWorkspace, _
				$Menu_LastWorkspace_Flush
Global $Menu_Edit, _
			$Menu_SetActif, $Menu_Search, $Menu_AddFile, $Menu_AddFolder, $Menu_Delete
Global $Menu_Misc, _
			$Menu_RunScite, $Menu_Cfg, $Menu_Bug, $Menu_About
; ---
Global $CMenu_Dummy, $CMenu, $hCMenu, _
			$CMenu_OpenAll, $CMenu_AddFile, $CMenu_AddFolder, $CMenu_Delete, $CMenu_Close, $CMenu_Rename, $CMenu_Browse

Func _GUI_Main($flag = $__GUI_CREATE)
	Switch $flag
		Case $__GUI_CREATE
			#Region ### START Koda GUI section ### Form=GUI_Main.kxf
			$GUI_Main = GUICreate("SPM", 300, 400, 0, 0, BitOr($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_CLIPCHILDREN), $WS_EX_ACCEPTFILES)
			$GUI_Main_Dec = Dec(StringRight($GUI_Main, 8))
			; ---
			; ça, c'est pour faire avancer le compteur des CtrlID, pour qu'il n'y ait plus d'interférences
			; entre les CMenu et les Contrôles de la GUI (c'est le seul truc que j'ai trouvé!!!)
			; Car, quand je fais Bouton-Droit sur un TVItem, le menu apparaît, Je clique sur un Item du menu
			; c'est bon il est appelé, mais le message du clique droit sur le TVItem est aussi traité,
			; et ça peut correspondre à n'import quoi! (New, Open...) alors, pour que ce clique droit ne
			; corresponde plus à rien, je fais avancer le compteur pour les contrôles aient des ID élevés
			; --- PS: tous ces dummy sont détruit à la fin de la création de la GUI ---
			; Et non! je ne les supprime pas à la fin, sinon, les contrôles créer après cette fonction (les MenuItem
			; de l'historique des projets/workspace) prendront les CtrlID que je voulai éviter! Et il y aura de nouveau
			; interférence!!!
			;Local $dummy[200]
			For $i = 0 To 199
				GuiCtrlCreateDummy()
				;$dummy[$i] = GuiCtrlCreateDummy()
			Next
			; ---
			; GUI Menu
			$Menu_File = GUICtrlCreateMenu(LNG("Menu_File"))
				$Menu_New = GUICtrlCreateMenuItem(LNG("Menu_New"), $Menu_File)
				$Menu_Open = GUICtrlCreateMenuItem(LNG("Menu_Open"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Save = GUICtrlCreateMenuItem(LNG("Menu_Save"), $Menu_File)
				$Menu_SaveAs = GUICtrlCreateMenuItem(LNG("Menu_SaveAs"), $Menu_File)
				$Menu_SaveAll = GUICtrlCreateMenuItem(LNG("Menu_SaveAll"), $Menu_File)
				$Menu_SaveWorkspace = GUICtrlCreateMenuItem(LNG("Menu_SaveWorkspace"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Close = GUICtrlCreateMenuItem(LNG("Menu_Close"), $Menu_File)
				$Menu_CloseAll = GUICtrlCreateMenuItem(LNG("Menu_CloseAll"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
					$Menu_LastProject = GuiCtrlCreateMenu(LNG("Menu_LastProject"), $Menu_File)
						$Menu_LastProject_Flush = GuiCtrlCreateMenuItem(LNG("Menu_Last_Flush"), $Menu_LastProject)
							GuiCtrlCreateMenuItem("", $Menu_LastProject)
					$Menu_LastWorkspace = GuiCtrlCreateMenu(LNG("Menu_LastWorkspace"), $Menu_File)
						$Menu_LastWorkspace_Flush = GuiCtrlCreateMenuItem(LNG("Menu_Last_Flush"), $Menu_LastWorkspace)
							GuiCtrlCreateMenuItem("", $Menu_LastWorkspace)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Exit = GUICtrlCreateMenuItem(LNG("Menu_Exit"), $Menu_File)
			$Menu_Edit = GUICtrlCreateMenu(LNG("Menu_Edit"))
				$Menu_SetActif = GUICtrlCreateMenuItem(LNG("Menu_SetActif"), $Menu_Edit)
				$Menu_Search = GUICtrlCreateMenuItem(LNG("Menu_Search"), $Menu_Edit)
					GuiCtrlCreateMenuItem("", $Menu_Edit)
				$Menu_AddFile = GUICtrlCreateMenuItem(LNG("Menu_AddFile"), $Menu_Edit)
				$Menu_AddFolder = GUICtrlCreateMenuItem(LNG("Menu_AddFolder"), $Menu_Edit)
					GuiCtrlCreateMenuItem("", $Menu_Edit)
				$Menu_Delete = GUICtrlCreateMenuItem(LNG("Menu_Delete"), $Menu_Edit)
			$Menu_Misc = GUICtrlCreateMenu(LNG("Menu_Misc"))
				$Menu_RunScite = GuiCtrlCreateMenuItem(LNG("Menu_RunScite"), $Menu_Misc)
				$Menu_Cfg = GUICtrlCreateMenuItem(LNG("Menu_Cfg"), $Menu_Misc)
					GuiCtrlCreateMenuItem("", $Menu_Misc)
				$Menu_Bug = GuiCtrlCreateMenuItem(LNG("Menu_Bug"), $Menu_Misc)
				$Menu_About = GUICtrlCreateMenuItem(LNG("Menu_About"), $Menu_Misc)
			; ---
			_GUI_LastMenu_Update()
			; ---
			; TreeView Context Menu
			$CMenu_Dummy = GuiCtrlCreateDummy()
			$CMenu = GuiCtrlCreateContextMenu($CMenu_Dummy)
				$CMenu_Close = GuiCtrlCreateMenuItem(LNG("CMenu_Close"), $CMenu)
					GuiCtrlCreateMenuItem("", $CMenu)
				$CMenu_OpenAll = GuiCtrlCreateMenuItem(LNG("CMenu_OpenAll"), $CMenu)
					GuiCtrlCreateMenuItem("", $CMenu)
				$CMenu_AddFile = GuiCtrlCreateMenuItem(LNG("Menu_AddFile"), $CMenu)
				$CMenu_AddFolder = GuiCtrlCreateMenuItem(LNG("Menu_AddFolder"), $CMenu)
				$CMenu_Rename = GuiCtrlCreateMenuItem(LNG("CMenu_Rename"), $CMenu)
				$CMenu_Delete = GuiCtrlCreateMenuItem(LNG("Menu_Delete"), $CMenu)
					GuiCtrlCreateMenuItem("", $CMenu)
				$CMenu_Browse = GuiCtrlCreateMenuItem(LNG("CMenu_Browse"), $CMenu)
			; ---
			$hCMenu = GuiCtrlGetHandle($CMenu)
			; ---
			;$Tree = GuiCtrlCreateTreeView(2, 26, 296, 352, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
			;	GuiCtrlSetResizing($Tree, $GUI_DOCKBORDERS)
			;	$__hTree = GuiCtrlGetHandle($Tree)
			; On n'utilise pas de contrôle standard car ces Items auront un CtrlID, et interfereront avec les events des autres contrôles
			$__hTree = _GuiCtrlTreeView_Create($GUI_Main, 2, 26, 296, 352, BitOR($TVS_EDITLABELS, $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
			; ---
			$__hToolBar = _GuiCtrlToolBar_Create($GUI_Main)
				$__hToolTip = _GUIToolTip_Create($__hToolBar)
				_GUICtrlToolbar_SetToolTips($__hToolBar, $__hToolTip)
			; ---
			; TreeView Image List
			$__hTreeView_ImageList = _GuiImageList_Create(16, 16, 5, 3)
			If Not @Compiled Then
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_project.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_folder.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_au3.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_txt.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_ini.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_blank.ico")
			Else
				_GuiImageList_AddIcon($__hTreeView_ImageList, @ScriptFullPath, 4)
				_GuiImageList_AddIcon($__hTreeView_ImageList, @ScriptFullPath, 5)
				_GuiImageList_AddIcon($__hTreeView_ImageList, @ScriptFullPath, 6)
				_GuiImageList_AddIcon($__hTreeView_ImageList, @ScriptFullPath, 7)
				_GuiImageList_AddIcon($__hTreeView_ImageList, @ScriptFullPath, 8)
				_GuiImageList_AddIcon($__hTreeView_ImageList, @ScriptFullPath, 9)
			EndIf
			_GuiCtrlTreeView_SetNormalImageList($__hTree, $__hTreeView_ImageList)
			; ---
			; Toolbar Image List
			$__hToolBar_ImageList = _GuiImageList_Create(18, 18, 5, 3)
			If Not @Compiled Then
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_newProject.ico", 0, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_open.ico", 0, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_save.ico", 0, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_newFile.ico", 0, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_newFolder.ico", 0, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_delete.ico", 0, 1)
			Else
				_GuiImageList_AddIcon($__hToolBar_ImageList, @ScriptFullPath, 10, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, @ScriptFullPath, 11, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, @ScriptFullPath, 12, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, @ScriptFullPath, 13, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, @ScriptFullPath, 14, 1)
				_GuiImageList_AddIcon($__hToolBar_ImageList, @ScriptFullPath, 15, 1)
			EndIf
			_GuiCtrlToolBar_SetImageList($__hToolBar, $__hToolBar_ImageList)
			; ---
			; Toolbar buttons
			_GuiCtrlToolBar_AddButton($__hToolBar, $Btn_New, 0)
			_GuiCtrlToolBar_AddButton($__hToolBar, $Btn_Open, 1)
			_GuiCtrlToolBar_AddButton($__hToolBar, $Btn_Save, 2)
			_GuiCtrlToolBar_AddButtonSep($__hToolBar)
			_GuiCtrlToolBar_AddButton($__hToolBar, $Btn_AddFile, 3)
			_GuiCtrlToolBar_AddButton($__hToolBar, $Btn_AddFolder, 4)
			_GuiCtrlToolBar_AddButton($__hToolBar, $Btn_Delete, 5)
			; ---
			GUIRegisterMsg($WM_COPYDATA, "MY_WM_COPYDATA") ; SciTE Command
			GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
			GUIRegisterMsg($WM_SIZE, "WM_SIZE")
			GuiSetAccelerators(__GUI_Main_Accels())
			; ---
			_GUI_MinMax_Set($GUI_Main, 180, 300, 300, @DesktopHeight)
			WinMove($GUI_Main, "", 0, 0, _Win_GetSize("x"), _Win_GetSize("y"))
			; ---
			;For $i = 0 To 99
			;	GuiCtrlDelete($dummy[$i])
			;Next
			; ---
			#EndRegion ### END Koda GUI section ###
		Case $__GUI_SHOW
			GuiSetState(@SW_SHOW, $GUI_Main)
		Case $__GUI_HIDE
			GuiSetState(@SW_HIDE, $GUI_Main)
		Case $__GUI_DELETE
			_GuiCtrlToolBar_Destroy($__hToolBar)
			_GuiToolTip_Destroy($__hToolTip)
			_GuiImageList_Destroy($__hTreeView_ImageList)
			_GuiImageList_Destroy($__hToolBar_ImageList)
			GuiDelete($GUI_Main)
			$GUI_Main = 0
	EndSwitch
EndFunc

Func __GUI_Main_Accels()
	Local $accels[9][2] = _
		[ _
			["^n", $Menu_New], _
			["^o", $Menu_Open], _
			["^s", $Menu_Save], _
			["^+s", $Menu_SaveAs], _
			["^q", $Menu_Close], _
			["^a", $Menu_AddFile], _
			["^f", $Menu_AddFolder], _
			["{del}", $Menu_Delete], _
			["^r", $Menu_Search] _
		]
	Return $accels
EndFunc

; ##############################################################
; Gestion des last projects/workspaces

Global $__Last[1][2] = [[0, ""]]

Func _GUI_LastMenu_Update()
	For $i = $__Last[0][0] To 1 Step -1
		GuiCtrlDelete($__Last[$i][0])
		_ArrayDelete($__Last, $i)
	Next
	$__Last[0][0] = 0
	; ---
	Local $list = _Last_Enum(1)
	For $i = 1 To $list[0]
		If Not $list[$i] Then ContinueLoop
		; ---
		Redim $__Last[$__Last[0][0] + 2][2]
		$__Last[0][0] += 1
		$__Last[$__Last[0][0]][0] = GuiCtrlCreateMenuItem($list[$i], $Menu_LastProject)
		$__Last[$__Last[0][0]][1] = $list[$i]
	Next
	; ---
	$list = _Last_Enum(2)
	For $i = 1 To $list[0]
		If Not $list[$i] Then ContinueLoop
		; ---
		Redim $__Last[$__Last[0][0] + 2][2]
		$__Last[0][0] += 1
		$__Last[$__Last[0][0]][0] = GuiCtrlCreateMenuItem($list[$i], $Menu_LastWorkspace)
		$__Last[$__Last[0][0]][1] = $list[$i]
	Next
EndFunc

Func _GUI_LastMenu_Delete($iId)
	GuiCtrlDelete($__Last[$iId][0])
	_Last_Del($__Last[$iId][1])
	; ---
	_ArrayDelete($__Last, $iId)
	$__Last[0][0] -= 1
EndFunc

; ##############################################################
; Cfg GUI
Global $GUI_Cfg, $C_Lang, $I_MaxHistory, $ud_MaxHistory, $C_Assoc, $C_RenameConfirmation, $C_RenameBackup, $C_MinToTray, $C_AdaptScite, $B_Ok
Global $C_WorkdirOnActivate

Func _GUI_Cfg($flag = $__GUI_CREATE)
	Switch $flag
		Case $__GUI_CREATE
			#Region ### START Koda GUI section ### Form=GUI_Cfg.kxf
			$GUI_Cfg = GUICreate(LNG("cfg_title"), 255, 268, -1, -1, -1, -1, $GUI_Main)
			GUICtrlCreateLabel(LNG("cfg_lng"), 18, 18, 58, 17)
			GUICtrlCreateLabel(LNG("cfg_hist_1"), 18, 48, 213, 17)
			GUICtrlCreateLabel(LNG("cfg_hist_2"), 18, 69, 115, 17)
			$C_Lang = GUICtrlCreateCombo("", 78, 15, 151, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
			$I_MaxHistory = GUICtrlCreateInput("", 132, 66, 97, 21, $SS_RIGHT)
				$ud_MaxHistory = GuiCtrlCreateUpDown($I_MaxHistory)
				GuiCtrlSetLimit($ud_MaxHistory, 15, 0)
			$C_RenameConfirmation = GUICtrlCreateCheckbox(LNG("cfg_renameAsk"), 15, 102, 240, 17)
			$C_RenameBackup = GUICtrlCreateCheckbox(LNG("cfg_renameBack"), 15, 120, 240, 17)
			$C_AdaptScite = GUICtrlCreateCheckbox(LNG("cfg_adaptScite"), 15, 144, 240, 17)
			$C_MinToTray = GUICtrlCreateCheckbox(LNG("cfg_minToTray"), 15, 162, 240, 17)
			$C_WorkdirOnActivate = GUICtrlCreateCheckbox(LNG("cfg_workdirOnActivate"), 15, 180, 240, 17)
			$C_Assoc = GUICtrlCreateCheckbox(LNG("cfg_assoc"), 15, 204, 240, 17)
				If Not @compiled Then GuiCtrlSetState($C_Assoc, $GUI_DISABLE)
			$B_Ok = GUICtrlCreateButton("OK", 89, 234, 75, 25)
			#EndRegion ### END Koda GUI section ###
		Case $__GUI_SHOW
			GuiSetState(@SW_SHOW, $GUI_Cfg)
		Case $__GUI_HIDE
			GuiSetState(@SW_HIDE, $GUI_Cfg)
		Case $__GUI_DELETE
			GuiDelete($GUI_Cfg)
			$GUI_Cfg = 0
	EndSwitch
EndFunc

; ##############################################################
; GUI Search

Global $GUI_Search, $__hListView

Func _GUI_Search($iMode = $__GUI_Create)
	Switch $iMode
		Case $__GUI_Create
			$GUI_Search = GUICreate(LNG("search_guiTitle"), 312, 312, -1, -1, BitOr($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_CLIPCHILDREN), -1, $GUI_Main)
			$__hListView = _GuiCtrlListView_Create($GUI_Search, LNG("search_LVHeader"), 6, 6, 300, 300, $LVS_REPORT + $LVS_SINGLESEL + $LVS_SHOWSELALWAYS + $LVS_NOSORTHEADER)
				_GUICtrlListView_SetExtendedListViewStyle($__hListView, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES)
			; ---
			Local $pos = WinGetPos("[Class:SciTEWindow]")
			If Not IsArray($pos) Then
				$pos = WinGetPos($GUI_Main)
				WinMove($GUI_Search, "", $pos[0] + $pos[2], (@DesktopHeight / 3) * 2, @DesktopWidth / 3, @DesktopHeight / 3)
			Else
				$pos[1] = ($pos[3] / 3) * 2
				$pos[3] = $pos[3] / 3
				WinMove($GUI_Search, "", $pos[0], $pos[1], $pos[2], $pos[3])
			EndIf
		Case $__GUI_Show
			GuiSetState(@SW_SHOW, $GUI_Search)
		Case $__GUI_Hide
			GuiSetState(@SW_HIDE, $GUI_Search)
		Case $__GUI_Delete
			GUIDelete($GUI_Search)
			$GUI_Search = 0
	EndSwitch
EndFunc


; ##############################################################
; Pour redimensionner le TreeView et le ListView (Search) (car il n'a pas de CtrlID)

Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	Local $w = _WinAPI_LoWord($lParam)
    Local $h = _WinAPI_HiWord($lParam)
	; ---
	Switch $hWnd
		Case $GUI_Main
			_WinAPI_MoveWindow($__hTree, 2, 26, $w - 4, $h - (4 + 24))
			; just resize, without activating nor maximizing
			_Scite_Adapt(1)
		Case $GUI_Search
			_WinAPI_MoveWindow($__hListView, 6, 6, $w - 12, $h - 12)
	EndSwitch
	; ---
    Return 0
EndFunc