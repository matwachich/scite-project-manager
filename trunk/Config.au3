#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#include-once
#include "lib\FileAssoc.au3"

Func _Cfg_Load()
	; ---
	; Lang
	Local $list = _FileListToArray(@ScriptDir & "\lang", "*.lng", 1)
	If Not IsArray($list) Then
		GuiCtrlSetData($C_Lang, "English", "English")
	Else
		Local $str = "English"
		For $i = 1 To $list[0]
			$str &= "|" & StringLeft($list[$i], StringInStr($list[$i], ".", 1, -1) - 1)
		Next
		GuiCtrlSetData($C_Lang, $str, StringLeft(CFG("lang_file"), StringInStr(CFG("lang_file"), ".", 1, -1) - 1))
	EndIf
	; ---
	; Max history
	GuiCtrlSetData($I_MaxHistory, CFG("last_saveCount"))
	; ---
	; Rename Confirmation & Backup
	GuiCtrlSetState($C_RenameConfirmation, CFG("rename_askConfirmation"))
	GuiCtrlSetState($C_RenameBackup, CFG("rename_backupFile"))
	; ---
	; SciTE Adapt
	GuiCtrlSetState($C_AdaptScite, CFG("adapt_scite"))
	; ---
	; Minimize to Tray
	GuiCtrlSetState($C_MinToTray, CFG("minToTray"))
	; ---
	; Workdir update on activate
	GuiCtrlSetState($C_WorkdirOnActivate, CFG("workdir_onActivate"))
	; ---
	; Assoc
	Local $get1 = _Assoc_Get(".auproj")
	Local $get2 = _Assoc_Get(".auwork")
	If IsArray($get1) And IsArray($get2) Then
		GuiCtrlSetState($C_Assoc, $GUI_CHECKED)
	Else
		GuiCtrlSetState($C_Assoc, $GUI_UNCHECKED)
	EndIf
EndFunc

Func _Cfg_Save()
	; ---
	; Lang
	Local $read = GuiCtrlRead($C_Lang)
	If Not $read Then $read = "English"
	$read &= ".lng"
	If $read <> CFG("lang_file") Then MsgBox(64, LNG("ProgName"), LNG("cfg_mb_lngChange"))
	_AutoCfg_SetEntry("lang_file", $read)
	; ---
	; Max History
	$read = GuiCtrlRead($I_MaxHistory)
	_AutoCfg_SetEntry("last_saveCount", $read)
	If $read = 0 Then
		_Last_Empty(1)
		_Last_Empty(2)
	EndIf
	; ---
	; Rename Confirmation & Backup
	_AutoCfg_SetEntry("rename_askConfirmation", GuiCtrlRead($C_RenameConfirmation))
	_AutoCfg_SetEntry("rename_backupFile", GuiCtrlRead($C_RenameBackup))
	; ---
	; Adapt SciTE
	$read = GuiCtrlRead($C_AdaptScite)
	If $read = $GUI_CHECKED Then _Scite_Adapt()
	; ---
	_AutoCfg_SetEntry("adapt_scite", $read)
	; ---
	; Minimize to Tray
	_AutoCfg_SetEntry("minToTray", GuiCtrlRead($C_MinToTray))
	; ---
	; workdir update on activate
	_AutoCfg_SetEntry("workdir_onActivate", GuiCtrlRead($C_WorkdirOnActivate))
	; ---
	; Assoc
	If @Compiled Then
		Switch GuiCtrlRead($C_Assoc)
			Case $GUI_CHECKED
				__Associate(1)
			Case $GUI_UNCHECKED
				__Associate(0)
		EndSwitch
	EndIf
EndFunc

; ##############################################################

Func __Associate($iStatus = 1)
	Switch $iStatus
		Case 0
			__Install_Template(2)
			; ---
			_Assoc_Del(".auproj")
			_Assoc_Del(".auwork")
		Case Else
			__Install_Template(1)
			; ---
			_Assoc_Set(".auproj", "AutoIt Project", '"' & @ScriptFullPath & '" "%1"', @ScriptFullPath & ",16")
			_Assoc_Set(".auwork", "AutoIt Workspace", '"' & @ScriptFullPath & '" "%1"', @ScriptFullPath & ",16")
	EndSwitch
EndFunc

Func __Install_Template($i)
	If $i Then
		FileWrite(@WindowsDir & "\SHELLNEW\Template.auproj", '<Project name="New Project">' & @CRLF & '</Project>')
		RegWrite("HKEY_CLASSES_ROOT\.auproj\shellnew", "FileName", "REG_SZ", '"' & @WindowsDir & '\SHELLNEW\Template.auproj"')
	Else
		FileDelete(@WindowsDir & "\SHELLNEW\Template.auproj")
		RegDelete("HKEY_CLASSES_ROOT\.auproj\shellnew", "FileName")
	EndIf
EndFunc
