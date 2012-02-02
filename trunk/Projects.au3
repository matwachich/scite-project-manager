#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	Merci ZDS

#ce ----------------------------------------------------------------------------
#Include-Once

Global $__OpenedProjects[1][4] = [[0, "", "", ""]] ; name, path, $hCtrl, $iModified
Global $__ActifProject = 0

#include <Array.au3>

Func _LoadWorkspace($sFile)
	Local $oXml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($oXml) Or Not FileExists($sFile) Then Return SetError(1, 0, 0)
	; ---
	$oXml.Load($sFile)
	Local $workSpace = $oXml.SelectNodes("/Workspace")
	If Not IsObj($workSpace) Then Return SetError(2, 0, 0)
	; ---
	Local $projects
	For $elem In $workSpace
		$projects = $elem.SelectNodes("Project")
		For $prj In $projects
			_LoadProject(_File_GetPath($sFile) & "\" & $prj.getAttribute("path"))
		Next
	Next
EndFunc

Func _LoadProject($sFile)
	Local $oXml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($oXml) Or Not FileExists($sFile) Then Return SetError(1, 0, 0)
	; ---
	$oXml.Load($sFile)
	Local $projects = $oXml.SelectNodes("/Project")
	If Not IsObj($projects) Then Return SetError(2, 0, 0)
	; ---
	Local $prjName, $hCtrl, $iProjectID, $OK = 0
	For $elem In $projects
		$prjName = _XML_getDisplayName($elem)
		If __OpenProject_IsOpen($prjName, $sFile) Then ContinueLoop
		; ---
		$hCtrl = _TV_Add($prjName, "project", $hTree, $sFile)
		; ---
		$iProjectID = __OpenProject_Add($prjName, $sFile, $hCtrl)
		_TV_ItemSetInfo($hCtrl, "PROJECT|" & $iProjectID & "|" & $sFile)
		; ---
		__BuildSubTreeView($elem, $hCtrl, $iProjectID)
		; ---
		_GuiCtrlTreeView_Expand($hTree, $hCtrl, True)
	Next
EndFunc

Func __BuildSubTreeView($hNode, $hCtrl, $iProjectID)
	; folders
	Local $fld, $fldName
	Local $folders = $hNode.SelectNodes("Folder")
	For $elem In $folders
		$fld = _TV_Add(_XML_getDisplayName($elem), "folder", $hCtrl, "", $iProjectID)
		__BuildSubTreeView($elem, $fld, $iProjectID)
	Next
	; files
	Local $file, $filePath
	Local $files = $hNode.SelectNodes("File")
	For $elem In $files
		$filePath = _XML_getDisplayName($elem)
		_TV_Add(_File_GetName($filePath), "file", $hCtrl, $filePath, $iProjectID)
	Next
EndFunc

; ##############################################################

Func _Project_Save($iProjectID, $iSaveAs = 0)
	Local $sFile = $__OpenedProjects[$iProjectID][1]
	; ---
	If $iSaveAs Or Not $sFile Then
		$sFile = FileSaveDialog(LNG("prompt_save", $__OpenedProjects[$iProjectID][0]), @WorkingDir, "Au3 Project (*.auproj)", 16, "", $GUI_Main)
		If $sFile And StringRight($sFile, 7) <> ".auproj" Then $sFile &= ".auproj"
	EndIf
	If Not $sFile Then Return 0
	; ---
	; mise a jour des infos du project (Array, Info Associées au hTreeViewItem)
	$__OpenedProjects[$iProjectID][1] = $sFile
	_TV_AssocInfo_Modify($__OpenedProjects[$iProjectID][2], "PROJECT|" & $iProjectID & "|" & $sFile)
	; ---
	Local $xml = _TV_ProjectToXML($__OpenedProjects[$iProjectID][2])
	; ---
	FileDelete($sFile)
	If Not FileWrite($sFile, $xml) Then
		_Err(LNG("err_cannotSave"))
		Return 0
	EndIf
	; ---
	__OpenProject_SetModified($iProjectID, 0)
	Return 1
EndFunc

; ##############################################################

Func _Project_Close($iProjectID)
	ConsoleWrite("Project Close: " & $iProjectID & @CRLF)
	If __OpenProject_IsModified($iProjectID) And _Ask(LNG("ask_save")) Then
		If Not _Project_Save($iProjectID) Then Return
	EndIf
	; ---
	Local $hItem = __OpenProject_GetItemHandle($iProjectID)
	_TV_AssocInfo_Del($hItem)
	_GuiCtrlTreeView_Delete($hTree, $hItem)
	__OpenProject_Del($iProjectID)
EndFunc

; ##############################################################

Func __OpenProject_Add($sName, $sPath, $CtrlID, $iModified = 0)
	ReDim $__OpenedProjects[$__OpenedProjects[0][0] + 2][4]
	$__OpenedProjects[0][0] += 1
	$__OpenedProjects[$__OpenedProjects[0][0]][0] = $sName
	$__OpenedProjects[$__OpenedProjects[0][0]][1] = $sPath
	$__OpenedProjects[$__OpenedProjects[0][0]][2] = $CtrlID
	;$__OpenedProjects[$__OpenedProjects[0][0]][3] = $iModified
	; on fait ça pour que la petite étoile se mette en place à coté du nom du projet
	; si celui ci est nouveau
	__OpenProject_SetModified($__OpenedProjects[0][0], $iModified)
	; ---
	If $__ActifProject = 0 Then __SetActifProject($__OpenedProjects[0][0])
	; ---
	Return $__OpenedProjects[0][0]
EndFunc

Func __OpenProject_GetName($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, "")
	; ---
	Return $__OpenedProjects[$iProjectID][0]
EndFunc

Func __OpenProject_GetPath($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, "")
	; ---
	Return $__OpenedProjects[$iProjectID][1]
EndFunc

Func __OpenProject_GetItemHandle($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, 0)
	; ---
	Return $__OpenedProjects[$iProjectID][2]
EndFunc

Func __OpenProject_IsModified($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, -1)
	; ---
	;ConsoleWrite("Is Modified: " & $iProjectID & " = " & $__OpenedProjects[$iProjectID][3] & @CRLF)
	Return $__OpenedProjects[$iProjectID][3]
EndFunc

Func __OpenProject_SetModified($iProjectID, $iModified = 1)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, -1)
	; ---
	;ConsoleWrite("Set Modified: " & $iProjectID & " = " & $iModified & @CRLF)
	; ---
	Local $text = _GuiCtrlTreeView_GetText($hTree, $__OpenedProjects[$iProjectID][2])
	If $iModified Then
		_GuiCtrlTreeView_SetText($hTree, $__OpenedProjects[$iProjectID][2], $text & " *")
	Else
		_GuiCtrlTreeView_SetText($hTree, $__OpenedProjects[$iProjectID][2], StringTrimRight($text, 2))
	EndIf
	; ---
	$__OpenedProjects[$iProjectID][3] = $iModified
	Return 1
EndFunc

Func __OpenProject_Del($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, -1)
	; ---
	_ArrayDelete($__OpenedProjects, $iProjectID)
	$__OpenedProjects[0][0] -= 1
EndFunc

Func __OpenProject_IsOpen($sName, $sPath)
	For $i = 1 To $__OpenedProjects[0][0]
		If $__OpenedProjects[$i][0] = $sName And $__OpenedProjects[$i][1] = $sPath Then Return 1
	Next
	Return 0
EndFunc

; ##############################################################

Func __SetActifProject($iID = Default)
	If $iID <> Default Then
		If $iID <> $__ActifProject Then
			_GuiCtrlTreeView_SetBold($hTree, $__OpenedProjects[$__ActifProject][2], False)
			$__ActifProject = $iID
			_GuiCtrlTreeView_SetBold($hTree, $__OpenedProjects[$__ActifProject][2], True)
		EndIf
	Else
		If $__OpenedProjects[0][0] > 0 Then
			__SetActifProject($__OpenedProjects[0][0])
		Else
			$__ActifProject = 0
		EndIf
	EndIf
EndFunc
