#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include "lib\ScriptingDictionary.au3"

Global $oLangDic = _SD_Create()

;_Lang_Load()
;_SD_ToIni($oLangDic, @ScriptDir & "\Lang\English.lng", "SPM_Language")

Func _Lang_Load()
	Local $iNotifLangChange = 0
	If Not FileExists(@ScriptDir & "\first_launch") Then
		Switch @OSLang
			Case "0409", "0809", "0c09", "1009", "1409", "1809", "1c09", "2009", "2409", "2809", "2c09", "3009", "3409"
				_AutoCfg_SetEntry("lang_file", "English.lng")
			Case "040c", "080c", "0c0c", "100c", "140c", "180c"
				_AutoCfg_SetEntry("lang_file", "Francais.lng")
		EndSwitch
		$iNotifLangChange = 1
	EndIf
	; ---
	Local $sFilePath = @ScriptDir & "\lang\" & CFG("lang_file")
	If FileExists($sFilePath) And CFG("lang_file") <> "English.lng" Then _SD_FromIni($oLangDic, $sFilePath, "SPM_Language")
	; ---
	Local $list = _SD_List(-1)
	_ArrayDisplay($list)
	__Lang_LoadDefault()
	Local $list = _SD_List(-1)
	_ArrayDisplay($list)
	; ---
	If $iNotifLangChange Then MsgBox(64, LNG("progName"), LNG("first_langSet", StringLeft(CFG("lang_file"), StringInStr(CFG("lang_file"), ".", 1, -1) - 1)))
EndFunc

Func __Lang_LoadDefault()
	__LNG_Add("ProgName", 					"Scite Project Manager")
	; ---
	; First Launch
	__LNG_Add("first_langSet", 				'The program language has been set to "%s", you can change this in the options')
	__LNG_Add("first_prompt_findScite",		"Find SciTE.exe")
	__LNG_Add("first_err_sciteNotFound",	"SciTE.exe not found.\nPlease install AutoIt3 and SciTE4AutoIt (http://www.autoitscript.com)")
	__LNG_Add("first_ask_sciteRelative",	"Do you want to keep it as relative path? (Ideal for portable version of AutoIt)")
	__LNG_Add("first_ask_assoc",			'Do you want to associate AutoIt Project (*.auproj) and AutoIt Project Group (*.auwork) file extensions with Scite Project Manager?')
	__LNG_Add("first_ask_sciteAdapt",		'Do you want the SciTE window size be adapted to the SPM window?')
	; ---
	; GUI Main
	__LNG_Add("Menu_File",			"&File")
	__LNG_Add("Menu_New",			"New Project	(Ctrl+N)")
	__LNG_Add("Menu_Open",			"Open Project/Workspace	(Ctrl+O)")
	__LNG_Add("Menu_Save",			"Save Project	(Ctrl+S)")
	__LNG_Add("Menu_SaveAs",		"Save Project As	(Ctrl+Shift+S)")
	__LNG_Add("Menu_SaveAll",		"Save All Projects")
	__LNG_Add("Menu_SaveWorkspace",	"Save Current Workspace")
	__LNG_Add("Menu_Close",			"Close Active Project	(Ctrl+Q)")
	__LNG_Add("Menu_CloseAll",		"Close All Projects")
	__LNG_Add("Menu_LastProject",	"Last Projects")
	__LNG_Add("Menu_LastWorkspace",	"Last Workspaces")
	__LNG_Add("Menu_Last_Flush",	"Empty List")
	__LNG_Add("Menu_Exit",			"Exit")
	__LNG_Add("Menu_Edit",			"&Edit")
	__LNG_Add("Menu_SetActif",		"Set Actif Project")
	__LNG_Add("Menu_Search",		"Search In Project Files")
	__LNG_Add("Menu_AddFile",		"Add File(s)	(Ctrl+A)")
	__LNG_Add("Menu_AddFolder",		"Add Folder	(Ctrl+F)")
	__LNG_Add("Menu_Delete",		"Delete	(Del)")
	__LNG_Add("Menu_Misc",			"&Misc")
	__LNG_Add("Menu_RunScite",		"Run SciTE")
	__LNG_Add("Menu_Cfg",			"Configuration")
	__LNG_Add("Menu_Bug",			"Bug Report")
	__LNG_Add("Menu_About",			"About")
	; ---
	; GUI Cfg
	__LNG_Add("cfg_title",				"SPM - Configuration")
	__LNG_Add("cfg_lng",				"Language")
	__LNG_Add("cfg_hist_1",				"Max. entries in Projects/Workspaces History")
	__LNG_Add("cfg_hist_2",				"0 means deactivated")
	__LNG_Add("cfg_renameAsk",			"Ask confirmation before renaming files")
	__LNG_Add("cfg_renameBack",			"Make backup of renamed files")
	__LNG_Add("cfg_adaptScite",			"Adapt SciTE window to SPM")
	__LNG_Add("cfg_minToTray",			"Minimize to Tray")
	__LNG_Add("cfg_workdirOnActivate",	"Update working directory on project activation")
	__LNG_Add("cfg_assoc",				"Associate *.auproj and *.auwork with SPM")
	__LNG_Add("cfg_mb_lngChange",		"The language will change after program restart")
	; ---
	; Search
	__LNG_Add("search_guiTitle",	"Search Result")
	__LNG_Add("search_LVHeader",	"File|Line N°|Line")
	; ---
	; Context Menu
	__LNG_Add("CMenu_OpenAll",		"Open All Files")
	;__LNG_Add("CMenu_AddFile",		"Add File(s)	(Ctrl+A)")
	;__LNG_Add("CMenu_AddFolder",	"Add Folder	(Ctrl+F)")
	;__LNG_Add("CMenu_Delete",		"Delete	(Del)")
	__LNG_Add("CMenu_Close",		"Close Project")
	__LNG_Add("CMenu_Rename",		"Rename")
	__LNG_Add("CMenu_Browse",		"Open Containing Folder")
	; ---
	; SciTE
	__LNG_Add("scite_nolaunch",		"Impossible to launch SciTE.\nDo you want to launch Scite Project Manager anyway?")
	; ---
	; Prompt
	__LNG_Add("prompt_new",					"Enter project's name")
	__LNG_Add("prompt_new_path",			"New Project's Path")
	__LNG_Add("prompt_Open",				"Select Project(s) To Open")
	__LNG_Add("prompt_save",				'Save Project: "%s"')
	__LNG_Add("prompt_addFile",				"Add File(s)")
	__LNG_Add("prompt_addFolder",			"Add Folder")
	__LNG_Add("prompt_confirmFileRename",	"The file will be renamed in disk. Make sure that any modifications are saved.\nDo you want to continue?\n(You can disable this notification in the Options window)")
	__LNG_Add("prompt_Search",				"Enter a keyword to search for within projet files.\nYou can enter multiple keywords separated with ;\n(Wildcard supported *)")
	; ---
	; Questions
	__LNG_Add("ask_save",				'The project "%s" has been modified.\r\nDo you want to save the modifications?')
	__LNG_Add("ask_deleteFile",			'Are you sure you want to delete the file "%s"?\r\n(The files are not deleted from disk)')
	__LNG_Add("ask_deleteFolder",		'Are you sure you want to delete the folder "%s" and ALL IT''S CONTENT?\r\n(The files are not deleted from disk)')
	__LNG_Add("ask_closeScite",			'Do you want to close SciTE?')
	; ---
	; Errors
	__LNG_Add("err_cannotSave",				"Impossible to save to the specified file.")
	__LNG_Add("err_invalidFile",			"The file specified is invalid:\r\n%s")
	__LNG_Add("err_FileNotFound",			"%s\nFile not found. Do you want to create it?")
	__LNG_Add("err_history_fileNotFound",	"File not found.\nIt will be deleted from the list")
	;__LNG_Add("err_drag_Folder",	"The folder that you want to drag contains another folder." & @CRLF & "Impossible to continue")
	; ---
	; About
	__LNG_Add("about", "Scite Project Manager - by Matwachich (2012)\r\nThe Project Manager for AutoIt3\r\n\r\n" & _
						"Thanks to:\r\nZDS - Parsing an xml file\r\nTlem - Fixing GUI Size\r\n" & _
						"Mat - Contextual Menu in a TreeView Control\r\n" & _
						"The AutoIt Creators and the entire french and english AutoIt Community!")
	__LNG_Add("about_tip_title", "Project's page (Google Code)")
	__LNG_Add("about_tip_com", "The AutoIt Website")
	__LNG_Add("about_tip_fr", "AutoIt French Community")
	; ---
	; Tray
	__LNG_Add("tray_tip", "Scite Project Manager\nClick to restore")
EndFunc
; ---

Func LNG($sID, $var1 = "", $var2 = "", $var3 = "", $var4 = "", $var5 = "")
	Local $ret
	Switch @NumParams
		Case 2
			$ret = StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1)
		Case 3
			$ret = StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2)
		Case 4
			$ret = StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2, $var3)
		Case 5
			$ret = StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2, $var3, $var4)
		Case 6
			$ret = StringFormat(_SD_Get($oLangDic, StringLower($sID)), $var1, $var2, $var3, $var4, $var5)
		Case Else
			$ret = StringFormat(_SD_Get($oLangDic, StringLower($sID)))
	EndSwitch
	; ---
	Return $ret
EndFunc

; ##############################################################

Func __LNG_Add($sName, $sText)
	_SD_Set($oLangDic, StringLower($sName), $sText, 0, 1)
EndFunc
