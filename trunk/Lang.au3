#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

#include "lib\ScriptingDictionary.au3"

Global $oLangDic = _SD_Create()

Func _Lang_Load($sPath = Default)
	If $sPath = Default Then Return __Lang_LoadDefault()
	; ---
	_SD_FromIni($oLangDic, $sPath, "SPM_Language")
	__Lang_LoadDefault()
EndFunc

Func __Lang_LoadDefault()
	_SD_Set($oLangDic, "ProgName", "Scite Project Manager", 0, 1)
	; ---
	; GUI Main
	_SD_Set($oLangDic, "Menu_File",			"&File", 0, 1)
	_SD_Set($oLangDic, "Menu_New",			"New Project", 0, 1)
	_SD_Set($oLangDic, "Menu_Open",			"Open Project", 0, 1)
	_SD_Set($oLangDic, "Menu_Save",			"Save Project", 0, 1)
	_SD_Set($oLangDic, "Menu_SaveAs",		"Save Project As", 0, 1)
	_SD_Set($oLangDic, "Menu_Close",		"Close Active Project", 0, 1)
	_SD_Set($oLangDic, "Menu_Exit",			"Exit", 0, 1)
	_SD_Set($oLangDic, "Menu_Edit",			"&Edit", 0, 1)
	_SD_Set($oLangDic, "Menu_AddFile",		"Add File(s)", 0, 1)
	_SD_Set($oLangDic, "Menu_AddFolder",	"Add Folder", 0, 1)
	_SD_Set($oLangDic, "Menu_Delete",		"Delete", 0, 1)
	_SD_Set($oLangDic, "Menu_Misc",			"&Misc", 0, 1)
	_SD_Set($oLangDic, "Menu_Cfg",			"Configuration", 0, 1)
	_SD_Set($oLangDic, "Menu_About",		"About", 0, 1)
	; ---
	; Prompt
	_SD_Set($oLangDic, "prompt_new",		"Enter project's name", 0, 1)
	_SD_Set($oLangDic, "prompt_save",		'Save Project: "%s"', 0, 1)
	; ---
	; Errors
	_SD_Set($oLangDic, "err_cannotSave",	"Impossible to save to the specified file.", 0, 1)
	_SD_Set($oLangDic, "err_invalidFile",	"The file specified is invalid:" & @CRLF & "%s", 0, 1)
EndFunc
; ---

Func LNG($sID, $var1 = "", $var2 = "", $var3 = "", $var4 = "", $var5 = "")
	Switch @NumParams
		Case 2
			Return StringFormat(_SD_Get($oLangDic, $sID), $var1)
		Case 3
			Return StringFormat(_SD_Get($oLangDic, $sID), $var1, $var2)
		Case 4
			Return StringFormat(_SD_Get($oLangDic, $sID), $var1, $var2, $var3)
		Case 5
			Return StringFormat(_SD_Get($oLangDic, $sID), $var1, $var2, $var3, $var4)
		Case 6
			Return StringFormat(_SD_Get($oLangDic, $sID), $var1, $var2, $var3, $var4, $var5)
		Case Else
			Return _SD_Get($oLangDic, $sID)
	EndSwitch
EndFunc
