#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#include-once

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <WindowsConstants.au3>

Func _Template_Select()
	Local $list = _FileListToArray(@ScriptDir & "\Templates", "*.template", 1)
	If Not IsArray($list) Then Return MsgBox(64, LNG("progName"), LNG("templ_notemplates"))
	; ---

EndFunc

; ##############################################################

Global $GUI_Templates, $Ls_Templates, $B_Templ_Select, $B_Templ_Add, $B_Templ_Edit, $B_Templ_Delete, $B_Templ_Explore

Func _GUI_Templates($iMode = $__GUI_Create)
	Switch $iMode
		Case $__GUI_Create
			$GUI_Templates = GUICreate("Templates", 226, 224, -1, -1)
			; ---
			$Ls_Templates = GUICtrlCreateList("", 6, 6, 121, 210, BitOR($LBS_NOTIFY,$LBS_SORT,$LBS_NOINTEGRALHEIGHT,$WS_VSCROLL))
			; ---
			$B_Templ_Select = GUICtrlCreateButton("Select", 132, 6, 87, 19)
			$B_Templ_Add = GUICtrlCreateButton("Add", 132, 30, 87, 19)
			$B_Templ_Edit = GUICtrlCreateButton("Edit", 132, 54, 87, 19)
			$B_Templ_Delete = GUICtrlCreateButton("Delete", 132, 78, 87, 19)
			$B_Templ_Explore = GUICtrlCreateButton("Explore", 132, 198, 87, 19)
		Case $__GUI_Show
			GuiSetState(@SW_SHOW, $GUI_Templates)
		Case $__GUI_Hide
			GuiSetState(@SW_HIDE, $GUI_Templates)
		Case $__GUI_Delete
			GUIDelete($GUI_Templates)
			$GUI_Templates = 0
	EndSwitch
EndFunc

; ##############################################################
; New Project Assistant GUI

Global $GUI_PrjAssistant, $I_NewPrj_MainDir, $B_NewPrj_Browse, $I_NewPrj_Folders, $B_NewPrj_Add
Global $B_NewPrj_Remove, $B_NewPrj_Empty, $B_NewPrj_AddTemplate, $L_NewPrj_LV, $B_NewPrj_Create

Func _GUI_PrjAssistant($iMode = $__GUI_Create)
	Switch $iMode
		Case $__GUI_Create
			#Region ### START Koda GUI section ### Form=GUI_NewPrj.kxf
			$GUI_PrjAssistant = GUICreate("New Project Assistant", 373, 323, -1, -1, -1, -1, $GUI_Main)
			GUICtrlCreateLabel("New Project", 12, 6, 348, 23, $SS_CENTER)
				GUICtrlSetFont(-1, 16, 800, 0, "Times New Roman")
			; ---
			GUICtrlCreateLabel("Project directory", 12, 36, 80, 17)
			$I_NewPrj_MainDir = GUICtrlCreateInput("", 12, 54, 319, 21)
			$B_NewPrj_Browse = GUICtrlCreateButton("", 336, 54, 25, 21)
				GUICtrlSetTip(-1, "Browse")
			; ---
			GUICtrlCreateLabel("Pipe | separated list of folders to create in the project directory", 12, 90, 292, 17)
			$I_NewPrj_Folders = GUICtrlCreateInput("", 12, 108, 347, 21)
			; ---
			GUICtrlCreateGroup("Files", 12, 138, 347, 141)
				$B_NewPrj_Add = GUICtrlCreateButton("Add", 264, 156, 75, 19)
				$B_NewPrj_AddTemplate = GUICtrlCreateButton("Add Template", 264, 180, 75, 19)
				$B_NewPrj_Remove = GUICtrlCreateButton("Remove", 264, 204, 75, 19)
				$B_NewPrj_Empty = GUICtrlCreateButton("Empty", 264, 246, 75, 19)
				; ---
				$L_NewPrj_LV = GUICtrlCreateListView("", 24, 156, 226, 114)
			GUICtrlCreateGroup("", -99, -99, 1, 1)
			; ---
			$B_NewPrj_Create = GUICtrlCreateButton("Create Project", 12, 288, 345, 25)
			#EndRegion ### END Koda GUI section ###
		Case $__GUI_Show
			GuiSetState(@SW_SHOW, $GUI_PrjAssistant)
		Case $__GUI_Hide
			GuiSetState(@SW_HIDE, $GUI_PrjAssistant)
		Case $__GUI_Delete
			GUIDelete($GUI_PrjAssistant)
			$GUI_PrjAssistant = 0
	EndSwitch
EndFunc
