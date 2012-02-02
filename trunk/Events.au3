#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

Func _Event_New()
	Local $prjName = InputBox(LNG("ProgName"), LNG("prompt_new"))
	If @error Or Not $prjName Then Return
	; ---
	Local $sPath = FileSaveDialog(LNG("prompt_new_path"), @WorkingDir, "Au3 Project (*.auproj)", 3, $prjName & ".auproj", $GUI_Main)
	If @error Or Not $sPath then Return
	; ---
	Local $hCtrl = _TV_Add($prjName, "PROJECT", $hTree, $sPath, "")
	Local $iProjectID = __OpenProject_Add($prjName, $sPath, $hCtrl, 1) ; modified = 1 (new project)
	_TV_ItemSetInfo($hCtrl, "PROJECT|" & $iProjectID & "|" & $sPath)
EndFunc

Func _Event_Open()
	Local $path = FileOpenDialog(LNG("ProgName"), @WorkingDir, "Au3 Project/Workspace (*.auproj;*.auwork)|Programmer's Notepad Project/Workspace (*.pnproj;*.ppg)|All (*.*)", 7, "", $GUI_Main)
	If @error Or Not $path Then Return
	; ---
	If Not StringInStr($path, "|") Then
		_LoadWorkspace($path)
		_LoadProject($path)
	Else
		$path = StringSplit($path, "|")
		If StringRight($path[1], 1) <> "\" Then $path[1] &= "\"
		; ---
		For $i = 2 To $path[0]
			_LoadWorkspace($path[1] & $path[$i])
			_LoadProject($path[1] & $path[$i])
		Next
	EndIf
EndFunc

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

Func _Event_Close($onExit = 0)
	If $__ActifProject = 0 Then Return
	; ---
	If $onExit Then
		For $i = 1 To $__OpenedProjects[0][0]
			_Project_Close($i)
		Next
	Else
		_Project_Close($__ActifProject)
	EndIf
EndFunc

; ##############################################################

Func _Event_AddFile()
	If $__ActifProject = 0 Then Return
	; ---
	Local $sPrjPath = _File_GetPath(__OpenProject_GetPath($__ActifProject))
	; si le projet n'a pas encore été enregistrer, alors on ajoute des fichier depuis workdir
	If Not $sPrjPath Then $sPrjPath = @WorkingDir
	; ---
	Local $sPath = FileOpenDialog(LNG("promp_add"), $sPrjPath, "AutoIt3 Script (*.au3)|All (*.*)", 15, "", $GUI_Main)
	If Not $sPath Or @error Then Return 0
	$sPath = _FileOpenDialog_ParseMultiple($sPath)
	_ArrayDisplay($sPath)
	; ---
	Local $hItemToAdd = 0, $Info
	; ---
	Local $hSelItem = _GuiCtrlTreeView_GetSelection($hTree)
	If $hSelItem Then
		$Info = _TV_ItemGetInfo($hSelItem)
		Switch $Info[1]
			Case "project", "folder"
				$hItemToAdd = $hSelItem
			Case "file"
				$hItemToAdd = _GuiCtrlTreeView_GetParentHandle($hTree, $hSelItem)
		EndSwitch
	Else
		$hItemToAdd = __OpenProject_GetItemHandle($__ActifProject)
	EndIf
	; ---
	; C'est pas $__ActifProject que l'on modifie, mais le projet du Item selectionné, qui peut correspondre
	; au $__ActifProject, mais pas forcément
	$Info = 0
	$Info = _TV_ItemGetInfo($hItemToAdd)
	; ---
	; traitement du chemin du fichier
	Local $projPath = _File_GetPath(__OpenProject_GetPath($Info[2])) & "\"
	; ---
	For $i = 1 To $sPath[0]
		If $projPath <> "\" And StringInStr($sPath[$i], $projPath) Then
			$sPath[$i] = StringReplace($sPath[$i], $projPath, "")
		EndIf
		; ---
		_TV_Add(_File_GetName($sPath[$i]), "file", $hItemToAdd, $sPath[$i], $Info[2])
		If Not FileExists($sPath[$i]) Then _File_Create($sPath[$i])
	Next
	; ---
	__OpenProject_SetModified($Info[2], 1)
EndFunc

Func _Event_AddFolder()
	If $__ActifProject = 0 Then Return
	; ---
	
EndFunc

; ##############################################################

Func _Event_TV_DblClick($hItem)
	$info = _TV_ItemGetInfo($hItem)
	For $elem In $info
		ConsoleWrite($elem & @CRLF)
	Next
	ConsoleWrite("===" & @CRLF)
	; ---
	Switch $info[1]
		Case "PROJECT"
			__SetActifProject($info[2])
	EndSwitch
EndFunc
