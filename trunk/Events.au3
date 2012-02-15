#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include <File.au3>
#include <GuiMenu.au3>

Func _Event_New()
	Local $prjName = InputBox(LNG("ProgName"), LNG("prompt_new"))
	If @error Or Not $prjName Then Return
	; ---
	Local $sPath = FileSaveDialog(LNG("prompt_new_path"), @WorkingDir, "Au3 Project (*.auproj)", 18, $prjName & ".auproj", $GUI_Main)
	If @error Or Not $sPath then Return
	FileDelete($sPath)
	; ---
	Local $hCtrl = _TV_Add($prjName, "PROJECT", $__hTree, $sPath, "")
	Local $iProjectID = __OpenProject_Add($prjName, $sPath, $hCtrl, 1) ; modified = 1 (new project)
	_TV_ItemSetInfo($hCtrl, "PROJECT|" & $iProjectID & "|" & $sPath)
EndFunc

Func _Event_Open()
	Local $path = FileOpenDialog(LNG("prompt_Open"), @WorkingDir, "Au3 Project/Workspace (*.auproj;*.auwork)|Programmer's Notepad Project/Workspace (*.pnproj;*.ppg)|All (*.*)", 7, "", $GUI_Main)
	If @error Or Not $path Then Return
	; ---
	$path = _FileOpenDialog_ParseMultiple($path)
	For $i = 1 To $path[0]
		_LoadWorkspace($path[$i])
		_LoadProject($path[$i])
	Next
EndFunc

; ##############################################################

Func _Event_Save()
	If $__ActifProject = 0 Then Return
	; ---
	_Project_Save($__ActifProject)
EndFunc

Func _Event_SaveAs()
	If $__ActifProject = 0 Then Return
	; ---
	_Project_Save($__ActifProject, 1)
EndFunc

Func _Event_SaveWorkspace()
	If $__OpenedProjects[0][0] = 0 Then Return
	; ---
	Local $file = FileSaveDialog(LNG("prompt_saveWorkspace"), @Workingdir, "Au3 Workspace (*.auwork)", 18, "", $GUI_Main)
	If @error Or Not $file Then Return
	If StringRight($file, 7) <> ".auwork" Then $file &= ".auwork"
	; ---
	Local $dir = _File_GetPath($file), $xml = '<Workspace name="Au3 Workspace">'
	For $i = 1 To $__OpenedProjects[0][0]
		$xml &= '<Project path="' & _PathGetRelative($dir, __OpenProject_GetPath($i)) & '"></Project>'
	Next
	$xml &= '</Workspace>'
	; ---
	FileDelete($file)
	FileWrite($file, $xml)
EndFunc

Func _Event_SaveAll()
	For $i = 1 To $__OpenedProjects[0][0]
		If __OpenProject_IDIsValid($i) Then _Project_Save($i)
	Next
EndFunc

; ##############################################################

; iDontSave est utile pour lors de la fermeture du programme, pour ne pas demander
; 2 fois d'enregistrer un projet modifié
Func _Event_Close($All = 0, $iDontSave = 0)
	If $__ActifProject = 0 Then Return 1
	; ---
	If $All Then
		For $i = $__OpenedProjects[0][0] To 1 Step -1
			If Not _Project_Close($i, $iDontSave) Then Return 0
		Next
	Else
		If Not _Project_Close($__ActifProject, $iDontSave) Then Return 0
	EndIf
	; ---
	__SetActifProject()
	; ---
	Return 1
EndFunc

; ##############################################################

Func _Event_SetActif()
	Local $hItem = _GuiCtrlTreeView_GetSelection($__hTree)
	If Not $hItem Then Return
	; ---
	Local $Info = _TV_ItemGetInfo($hItem)
	__SetActifProject($Info[2])
EndFunc

Func _Event_Search()
	If $__OpenedProjects[0][0] <= 0 Then Return
	; ---
	Local $sKey = InputBox(LNG("Menu_Search"), LNG("prompt_Search"))
	If Not $sKey Or @error Then Return
	; ---
	_Search($__ActifProject, $sKey)
EndFunc

Func _Event_AddFile()
	;If $__ActifProject = 0 Then Return
	If $__OpenedProjects[0][0] = 0 Then Return
	; ---
	;Local $sPrjPath = _File_GetPath(__OpenProject_GetPath($__ActifProject))
	; juste au cas ou
	;If Not $sPrjPath Then $sPrjPath = @WorkingDir
	; ---
	Local $sPath = FileOpenDialog(LNG("prompt_addFile"), @WorkingDir, "AutoIt3 Script (*.au3)|All (*.*)", 15, "", $GUI_Main)
	If Not $sPath Or @error Then Return 0
	$sPath = _FileOpenDialog_ParseMultiple($sPath)
	; ---
	Local $hItemToAdd = 0, $Info
	; ---
	Local $hSelItem = _GuiCtrlTreeView_GetSelection($__hTree)
	If $hSelItem Then
		$Info = _TV_ItemGetInfo($hSelItem)
		Switch $Info[1]
			Case "project", "folder"
				$hItemToAdd = $hSelItem
			Case "file"
				$hItemToAdd = _GuiCtrlTreeView_GetParentHandle($__hTree, $hSelItem)
		EndSwitch
	Else
		$hItemToAdd = __OpenProject_GetItemHandle($__ActifProject)
	EndIf
	; ---
	If Not $hItemToAdd Then Return
	; ---
	; C'est pas $__ActifProject que l'on modifie, mais le projet du Item selectionné, qui peut correspondre
	; au $__ActifProject, mais pas forcément
	; Ne sert à rien: Toujours: hSelItem et $ItemToAdd auront le même ProjectID
	;$Info = 0
	$Info = _TV_ItemGetInfo($hItemToAdd)
	; ---
	; traitement du chemin du fichier
	Local $projPath = _File_GetPath(__OpenProject_GetPath($Info[2]))
	; ---
	For $i = 1 To $sPath[0]
		$sPath[$i] = _PathGetRelative($projPath, $sPath[$i])
		; ---
		_TV_Add(_File_GetName($sPath[$i]), "file", $hItemToAdd, $sPath[$i], $Info[2])
		__TV_ExpandItems($hItemToAdd)
		If Not FileExists($sPath[$i]) Then _File_Create($sPath[$i])
	Next
	; ---
	_Project_Sort($Info[2])
	__OpenProject_SetModified($Info[2], 1)
EndFunc

Func _Event_AddFolder()
	;If $__ActifProject = 0 Then Return
	If $__OpenedProjects[0][0] = 0 Then Return
	; ---
	Local $sName = InputBox(LNG("ProgName"), LNG("prompt_addFolder"))
	If Not $sName Or @error Then Return
	; ---
	Local $hSelItem, $hItemToAdd, $Info
	$hSelItem = _GuiCtrlTreeView_GetSelection($__hTree)
	If $hSelItem <> 0 Then
		$Info = _TV_ItemGetInfo($hSelItem)
		Switch $Info[1]
			Case "folder", "project"
				$hItemToAdd = $hSelItem
			Case "file"
				$hItemToAdd = _GuiCtrlTreeView_GetParentHandle($__hTree, $hSelItem)
		EndSwitch
	Else
		$hItemToAdd = __OpenProject_GetItemHandle($__ActifProject)
	EndIf
	; ---
	If Not $hItemToAdd Then Return
	; ---
	_TV_Add($sName, "folder", $hItemToAdd, "", $Info[2])
	; ---
	_Project_Sort($Info[2])
	__OpenProject_SetModified($Info[2], 1)
EndFunc

Func _Event_Delete()
	Local $hItem = _GuiCtrlTreeView_GetSelection($__hTree)
	If Not $hItem Then Return
	; ---
	Local $Info = _TV_ItemGetInfo($hItem)
	Switch $Info[1]
		Case "project"
			Return
		Case "file", "folder"
			; quand on supprime un dossier, tous les Items fils (fichiers, dossiers) sont supprimés
			; mais, seul le AssocInfo du dossier est supprimé
			; je laisse comme cela, car j'ai la flem! et puis de toute façon, quand le projet sera fermé,
			; ils seront tous supprimés
			If _Ask(LNG("ask_delete" & $Info[1], $Info[0])) Then
				_TV_AssocInfo_Del($hItem)
				_GuiCtrlTreeView_Delete($__hTree, $hItem)
				; ---
				_Project_Sort($Info[2])
				__OpenProject_SetModified($Info[2], 1)
			EndIf
	EndSwitch
EndFunc

; ##############################################################

Func _Event_OpenAll()
	Local $item = _GuiCtrlTreeView_GetSelection($__hTree)
	If Not $item Then Return
	; ---
	Local $child = _TV_GetAllChildren($item)
	If Not IsArray($child) Then Return
	; ---
	Local $info
	For $i = 1 To $child[0]
		_Event_TV_DblClick($child[$i])
	Next
EndFunc

;$__TV_EditedItem
Func _Event_Edit()
	Local $item = _GuiCtrlTreeView_GetSelection($__hTree)
	If Not $item Then Return
	; ---
	ConsoleWrite("Rename ON" & @CRLF)
	_GuiCtrlTreeView_EditText($__hTree, $item)
	$__TV_EditedItem = $item
EndFunc

Func _Event_Browse()
	Local $item = _GuiCtrlTreeView_GetSelection($__hTree)
	If Not $item Then Return
	; ---
	Local $info = _TV_ItemGetInfo($item), $path
	Switch $info[1]
		Case "FILE"
			$path = _File_GetPath(_File_GetPath(__OpenProject_GetPath($info[2])) & "\" & $info[3])
			ShellExecute($path)
		Case "PROJECT"
			$path = _File_GetPath($info[3])
			ShellExecute($path)
	EndSwitch
EndFunc

; ##############################################################

; open file in SciTE
Func _Event_TV_DblClick($hItem)
	Local $sFile = _TV_ItemGetFilePath($hItem)
	If Not $sFile Or @error Then Return
	; ---
	If Not FileExists($sFile) Then
		If _Ask(LNG("err_FileNotFound", $sFile)) Then
			_File_Create($sFile)
		Else
			Return
		EndIf
	EndIf
	; ---
	_Scite_OpenFile($sFile)
EndFunc

Func _Event_TV_RClick($hItem)
	GuiCtrlSetState($CMenu_OpenAll, $GUI_DISABLE)
	GuiCtrlSetState($CMenu_AddFile, $GUI_DISABLE)
	GuiCtrlSetState($CMenu_AddFolder, $GUI_DISABLE)
	GuiCtrlSetState($CMenu_Delete, $GUI_DISABLE)
	GuiCtrlSetState($CMenu_Close, $GUI_DISABLE)
	GuiCtrlSetState($CMenu_Rename, $GUI_DISABLE)
	GuiCtrlSetState($CMenu_Browse, $GUI_DISABLE)
	; ---
	Local $info = _TV_ItemGetInfo($hItem)
	Switch $info[1]
		Case "PROJECT"
			GuiCtrlSetState($CMenu_OpenAll, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_AddFile, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_AddFolder, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Close, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Rename, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Browse, $GUI_ENABLE)
		Case "FOLDER"
			GuiCtrlSetState($CMenu_OpenAll, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_AddFile, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_AddFolder, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Delete, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Rename, $GUI_ENABLE)
		Case "FILE"
			GuiCtrlSetState($CMenu_Delete, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Rename, $GUI_ENABLE)
			GuiCtrlSetState($CMenu_Browse, $GUI_ENABLE)
	EndSwitch
	; ---
	; on rend le projet actif
	__SetActifProject($info[2])
EndFunc

#cs
Func _Event_TV_RightClick($hItem)
	$info = _TV_ItemGetInfo($hItem)

EndFunc
#ce
