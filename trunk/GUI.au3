#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include <GUIConstantsEx.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiTreeView.au3>
#include <GuiImageList.au3>
#include <GuiToolbar.au3>
#include <GuiToolTip.au3>

Global Enum $__GUI_Create, $__GUI_Delete, $__GUI_Show, $__GUI_Hide

Global Enum $Btn_New = 1000, $Btn_Open, $Btn_Save, $Btn_AddFile, $Btn_AddFolder, $Btn_Delete

; Taille minimum de la GUI
Global $aUtil_MinMax[4]

; ##############################################################
; GUI Main
Global $GUI_Main
Global $__hTree, $__hTreeView_ImageList
Global $__hToolBar, $__hToolBar_ImageList, $__hToolTip, $__hToolBar_HotItem
; ---
Global $Menu_File, _
			$Menu_New, $Menu_Open, $Menu_Save, $Menu_SaveAs, $Menu_SaveWorkspace, $Menu_Close, $Menu_CloseAll, $Menu_Exit
Global $Menu_Edit, _
			$Menu_SetActif, $Menu_AddFile, $Menu_AddFolder, $Menu_Delete
Global $Menu_Misc, _
			$Menu_Cfg, $Menu_About

Func _GUI_Main($flag = $__GUI_CREATE)
	Switch $flag
		Case $__GUI_CREATE
			#Region ### START Koda GUI section ### Form=GUI_Main.kxf
			$GUI_Main = GUICreate("SPM", 300, 400, 0, 0, BitOr($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_CLIPCHILDREN), $WS_EX_ACCEPTFILES)
			; ---
			$Menu_File = GUICtrlCreateMenu(LNG("Menu_File"))
				$Menu_New = GUICtrlCreateMenuItem(LNG("Menu_New"), $Menu_File)
				$Menu_Open = GUICtrlCreateMenuItem(LNG("Menu_Open"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Save = GUICtrlCreateMenuItem(LNG("Menu_Save"), $Menu_File)
				$Menu_SaveAs = GUICtrlCreateMenuItem(LNG("Menu_SaveAs"), $Menu_File)
				$Menu_SaveWorkspace = GUICtrlCreateMenuItem(LNG("Menu_SaveWorkspace"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Close = GUICtrlCreateMenuItem(LNG("Menu_Close"), $Menu_File)
				$Menu_CloseAll = GUICtrlCreateMenuItem(LNG("Menu_CloseAll"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Exit = GUICtrlCreateMenuItem(LNG("Menu_Exit"), $Menu_File)
			$Menu_Edit = GUICtrlCreateMenu(LNG("Menu_Edit"))
				$Menu_SetActif = GUICtrlCreateMenuItem(LNG("Menu_SetActif"), $Menu_Edit)
					GuiCtrlCreateMenuItem("", $Menu_Edit)
				$Menu_AddFile = GUICtrlCreateMenuItem(LNG("Menu_AddFile"), $Menu_Edit)
				$Menu_AddFolder = GUICtrlCreateMenuItem(LNG("Menu_AddFolder"), $Menu_Edit)
					GuiCtrlCreateMenuItem("", $Menu_Edit)
				$Menu_Delete = GUICtrlCreateMenuItem(LNG("Menu_Delete"), $Menu_Edit)
			$Menu_Misc = GUICtrlCreateMenu(LNG("Menu_Misc"))
				$Menu_Cfg = GUICtrlCreateMenuItem(LNG("Menu_Cfg"), $Menu_Misc)
				$Menu_About = GUICtrlCreateMenuItem(LNG("Menu_About"), $Menu_Misc)
			; ---
			$Tree = GuiCtrlCreateTreeView(2, 26, 296, 352, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
				GuiCtrlSetResizing($Tree, $GUI_DOCKBORDERS)
				$__hTree = GuiCtrlGetHandle($Tree)
			; ---
			$__hToolBar = _GuiCtrlToolBar_Create($GUI_Main)
				$__hToolTip = _GUIToolTip_Create($__hToolBar)
				_GUICtrlToolbar_SetToolTips($__hToolBar, $__hToolTip)
			; ---
			; TreeView Image List
			$__hTreeView_ImageList = _GuiImageList_Create(16, 16, 5, 3)
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_project.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_folder.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_au3.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_txt.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_ini.ico")
				_GuiImageList_AddIcon($__hTreeView_ImageList, $__ResDir & "\ico_blank.ico")
			_GuiCtrlTreeView_SetNormalImageList($__hTree, $__hTreeView_ImageList)
			; ---
			; Toolbar Image List
			$__hToolBar_ImageList = _GuiImageList_Create(18, 18, 5, 3)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_newProject.ico", 0)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_open.ico", 0)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_save.ico", 0)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_newFile.ico", 0)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_newFolder.ico", 0)
				_GuiImageList_AddIcon($__hToolBar_ImageList, $__ResDir & "\btn\btn_delete.ico", 0)
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
			GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
			GuiSetAccelerators(__GUI_Main_Accels())
			; ---
			_InitMinMax(180, 300, 300, @DesktopHeight)
			WinMove($GUI_Main, "", 0, 0, 180, 400)
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
	Local $accels[8][2] = _
		[ _
			["^n", $Menu_New], _
			["^o", $Menu_Open], _
			["^s", $Menu_Save], _
			["^+s", $Menu_SaveAs], _
			["^q", $Menu_Close], _
			["^a", $Menu_AddFile], _
			["^f", $Menu_AddFolder], _
			["{del}", $Menu_Delete] _
		]
	Return $accels
EndFunc

; ##############################################################
; Merci Tlem!!!

Func _InitMinMax($x0, $y0, $x1, $y1)
    $aUtil_MinMax[0] = $x0
    $aUtil_MinMax[1] = $y0
    $aUtil_MinMax[2] = $x1
    $aUtil_MinMax[3] = $y1
    GUIRegisterMsg(0x24, 'MY_WM_GETMINMAXINFO') ; $WM_GETMINMAXINFO
EndFunc

Func MY_WM_GETMINMAXINFO($hWnd, $Msg, $wParam, $lParam)
    Local $minmaxinfo = DllStructCreate('int;int;int;int;int;int;int;int;int;int',$lParam)
    DllStructSetData($minmaxinfo, 7, $aUtil_MinMax[0]); min X
    DllStructSetData($minmaxinfo, 8, $aUtil_MinMax[1]); min Y
    DllStructSetData($minmaxinfo, 9, $aUtil_MinMax[2]); max X
    DllStructSetData($minmaxinfo, 10, $aUtil_MinMax[3]); max Y
    Return $GUI_RUNDEFMSG
EndFunc
