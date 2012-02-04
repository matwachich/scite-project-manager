#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

#include "lib\ScriptingDictionary.au3"

Global $oLangDic = _SD_Create()

Func _Lang_Load($sPath = "")
	If Not FileExists($sPath) Then Return __Lang_LoadDefault()
	; ---
	_SD_FromIni($oLangDic, $sPath, "SPM_Language")
	__Lang_LoadDefault()
EndFunc

Func __Lang_LoadDefault()
	__LNG_Add("ProgName", 			"Scite Project Manager")
	; ---
	; GUI Main
	__LNG_Add("Menu_File",			"&File")
	__LNG_Add("Menu_New",			"New Project	(Ctrl+N)")
	__LNG_Add("Menu_Open",			"Open Project	(Ctrl+O)")
	__LNG_Add("Menu_Save",			"Save Project	(Ctrl+S)")
	__LNG_Add("Menu_SaveAs",		"Save Project As	(Ctrl+Shift+S)")
	__LNG_Add("Menu_SaveWorkspace",	"Save Current Workspace")
	__LNG_Add("Menu_Close",			"Close Active Project	(Ctrl+Q)")
	__LNG_Add("Menu_CloseAll",		"Close All Projects")
	__LNG_Add("Menu_Exit",			"Exit")
	__LNG_Add("Menu_Edit",			"&Edit")
	__LNG_Add("Menu_SetActif",		"Set Actif Project")
	__LNG_Add("Menu_AddFile",		"Add File(s)	(Ctrl+A)")
	__LNG_Add("Menu_AddFolder",		"Add Folder	(Ctrl+F)")
	__LNG_Add("Menu_Delete",		"Delete	(Del)")
	__LNG_Add("Menu_Misc",			"&Misc")
	__LNG_Add("Menu_Cfg",			"Configuration")
	__LNG_Add("Menu_About",			"About")
	; ---
	; Prompt
	__LNG_Add("prompt_new",			"Enter project's name")
	__LNG_Add("prompt_new_path",	"New Project's Path")
	__LNG_Add("prompt_Open",		"Select Project(s) To Open")
	__LNG_Add("prompt_save",		'Save Project: "%s"')
	__LNG_Add("prompt_addFile",		"Add File(s)")
	__LNG_Add("prompt_addFolder",	"Add Folder")
	; ---
	; Questions
	__LNG_Add("ask_save",			'The project "%s" has been modified.' & @CRLF & 'Do you want to save the modifications?')
	__LNG_Add("ask_deleteFile",		'Are you sure you want to delete the file "%s"?' & @CRLF & "(The files are not deleted from disk)")
	__LNG_Add("ask_deleteFolder",	'Are you sure you want to delete the folder "%s" and ALL IT''S CONTENT?' & @CRLF & "(The files are not deleted from disk)")
	; ---
	; Errors
	__LNG_Add("err_cannotSave",		"Impossible to save to the specified file.")
	__LNG_Add("err_invalidFile",	"The file specified is invalid:" & @CRLF & "%s")
EndFunc
; ---

Func LNG($sID, $var1 = "", $var2 = "", $var3 = "", $var4 = "", $var5 = "")
	Switch @NumParams
		Case 2
			Return StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1)
		Case 3
			Return StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2)
		Case 4
			Return StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2, $var3)
		Case 5
			Return StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2, $var3, $var4)
		Case 6
			Return StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2, $var3, $var4, $var5)
		Case Else
			Return _SD_Get($oLangDic, StringLower($sID))
	EndSwitch
EndFunc

; ##############################################################

Func __LNG_Add($sName, $sText)
	_SD_Set($oLangDic, StringLower($sName), $sText, 0, 1)
EndFunc
