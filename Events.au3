#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	

#ce ----------------------------------------------------------------------------
#Include-Once

#include <File.au3>

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

; ##############################################################

Func _Event_Close($All = 0)
	If $__ActifProject = 0 Then Return
	; ---
	If $All Then
		For $i = $__OpenedProjects[0][0] To 1 Step -1
			_Project_Close($i)
		Next
	Else
		_Project_Close($__ActifProject)
	EndIf
	; ---
	__SetActifProject()
EndFunc

; ##############################################################

Func _Event_SetActif()
	Local $hItem = _GuiCtrlTreeView_GetSelection($__hTree)
	If Not $hItem Then Return
	; ---
	Local $Info = _TV_ItemGetInfo($hItem)
	__SetActifProject($Info[2])
EndFunc

Func _Event_AddFile()
	;If $__ActifProject = 0 Then Return
	If $__OpenedProjects[0][0] = 0 Then Return
	; ---
	;Local $sPrjPath = _File_GetPath(__OpenProject_GetPath($__ActifProject))
	; juste au cas ou
	;If Not $sPrjPath Then $sPrjPath = @WorkingDir
	; ---
	Local $sPath = FileOpenDialog(LNG("promp_addFile"), @WorkingDir, "AutoIt3 Script (*.au3)|All (*.*)", 15, "", $GUI_Main)
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
		If Not FileExists($sPath[$i]) Then _File_Create($sPath[$i])
	Next
	; ---
	__OpenProject_SetModified($Info[2], 1)
EndFunc

Func _Event_AddFolder()
	;If $__ActifProject = 0 Then Return
	If $__OpenedProjects[0][0] = 0 Then Return
	; ---
	Local $sName = InputBox(LNG("ProgName"), LNG("promp_addFolder"))
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
				__OpenProject_SetModified($Info[2], 1)
			EndIf
	EndSwitch
EndFunc

; ##############################################################

Func _Event_TV_DblClick($hItem)
	$info = _TV_ItemGetInfo($hItem)
	Switch $info[1]
		Case "PROJECT"
			__SetActifProject($info[2])
	EndSwitch
EndFunc

#cs
Func _Event_TV_RightClick($hItem)
	$info = _TV_ItemGetInfo($hItem)
	
EndFunc
#ce
