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
#include <String.au3>

Global Enum $__GUI_Create, $__GUI_Delete, $__GUI_Show, $__GUI_Hide

Global Const $__ResDir = @ScriptDir & "\res"
Global $__hImgList

; ##############################################################
; GUI Main
Global $GUI_Main, $hTree
Global $Menu_File, _
			$Menu_New, $Menu_Open, $Menu_Save, $Menu_SaveAs, $Menu_Close, $Menu_Exit
Global $Menu_Edit, _
			$Menu_AddFile, $Menu_AddFolder, $Menu_Delete
Global $Menu_Misc, _
			$Menu_Cfg, $Menu_About

Func _GUI_Main($flag = $__GUI_CREATE)
	Switch $flag
		Case $__GUI_CREATE
			#Region ### START Koda GUI section ### Form=GUI_Main.kxf
			$GUI_Main = GUICreate("SPM", 170, 442, 0, 0, -1, -1)
			; ---
			$Menu_File = GUICtrlCreateMenu(LNG("Menu_File"))
				$Menu_New = GUICtrlCreateMenuItem(LNG("Menu_New"), $Menu_File)
				$Menu_Open = GUICtrlCreateMenuItem(LNG("Menu_Open"), $Menu_File)
				$Menu_Save = GUICtrlCreateMenuItem(LNG("Menu_Save"), $Menu_File)
				$Menu_SaveAs = GUICtrlCreateMenuItem(LNG("Menu_SaveAs"), $Menu_File)
				$Menu_Close = GUICtrlCreateMenuItem(LNG("Menu_Close"), $Menu_File)
					GuiCtrlCreateMenuItem("", $Menu_File)
				$Menu_Exit = GUICtrlCreateMenuItem(LNG("Menu_Exit"), $Menu_File)
			$Menu_Edit = GUICtrlCreateMenu(LNG("Menu_Edit"))
				$Menu_AddFile = GUICtrlCreateMenuItem(LNG("Menu_AddFile"), $Menu_Edit)
				;$Menu_AddNewFile = GUICtrlCreateMenuItem(LNG("Menu_AddNewFile"), $Menu_Edit)
				$Menu_AddFolder = GUICtrlCreateMenuItem(LNG("Menu_AddFolder"), $Menu_Edit)
				$Menu_Delete = GUICtrlCreateMenuItem(LNG("Menu_Delete"), $Menu_Edit)
			$Menu_Misc = GUICtrlCreateMenu(LNG("Menu_Misc"))
				$Menu_Cfg = GUICtrlCreateMenuItem(LNG("Menu_Cfg"), $Menu_Misc)
				$Menu_About = GUICtrlCreateMenuItem(LNG("Menu_About"), $Menu_Misc)
			; ---
			$hTree = _GUICtrlTreeView_Create($GUI_Main, 6, 6, 157, 409, BitOR($TVS_EDITLABELS, $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
			; ---
			$__hImgList = _GuiImageList_Create(16, 16, 5, 3)
			_GuiImageList_AddIcon($__hImgList, $__ResDir & "\ico_project.ico")
			_GuiImageList_AddIcon($__hImgList, $__ResDir & "\ico_folder.ico")
			_GuiImageList_AddIcon($__hImgList, $__ResDir & "\ico_au3.ico")
			_GuiImageList_AddIcon($__hImgList, $__ResDir & "\ico_txt.ico")
			_GuiImageList_AddIcon($__hImgList, $__ResDir & "\ico_ini.ico")
			_GuiImageList_AddIcon($__hImgList, $__ResDir & "\ico_blank.ico")
			_GuiCtrlTreeView_SetNormalImageList($hTree, $__hImgList)
			; ---
			GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
			#EndRegion ### END Koda GUI section ###
		Case $__GUI_SHOW
			GuiSetState(@SW_SHOW, $GUI_Main)
		Case $__GUI_HIDE
			GuiSetState(@SW_HIDE, $GUI_Main)
		Case $__GUI_DELETE
			_GuiImageList_Destroy($__hImgList)
			GuiDelete($GUI_Main)
			$GUI_Main = 0
	EndSwitch
EndFunc
