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
			$str &= "|" & $list[$i]
		Next
		GuiCtrlSetData($C_Lang, $str, CFG("lang_file"))
	EndIf
	; ---
	; Max history
	GuiCtrlSetData($I_MaxHistory, CFG("last_saveCount"))
	; ---
	; Rename Confirmation & Backup
	GuiCtrlSetState($C_RenameConfirmation, CFG("rename_askConfirmation"))
	GuiCtrlSetState($C_RenameBackup, CFG("rename_backupFile"))
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
	; Assoc
	If @Compiled Then
		Switch GuiCtrlRead($C_Assoc)
			Case $GUI_CHECKED
				__Install_Template(1)
				; ---
				_Assoc_Set(".auproj", "AutoIt Project", '"' & @ScriptFullPath & '" "%1"', @ScriptFullPath & ",16")
				_Assoc_Set(".auwork", "AutoIt Workspace", '"' & @ScriptFullPath & '" "%1"', @ScriptFullPath & ",16")
			Case $GUI_UNCHECKED
				__Install_Template(2)
				; ---
				_Assoc_Del(".auproj")
				_Assoc_Del(".auwork")
		EndSwitch
	EndIf
EndFunc

; ##############################################################

Func __Install_Template($i)
	If $i Then
		FileWrite(@WindowsDir & "\SHELLNEW\Template.auproj", '<Project name="New Project">' & @CRLF & '</Project>')
		RegWrite("HKEY_CLASSES_ROOT\.auproj\shellnew", "FileName", "REG_SZ", "Template.auproj")
	Else
		FileDelete(@WindowsDir & "\SHELLNEW\Template.auproj")
		RegDelete("HKEY_CLASSES_ROOT\.auproj\shellnew", "FileName")
	EndIf
EndFunc
