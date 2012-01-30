#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	Merci ZDS

#ce ----------------------------------------------------------------------------
#Include-Once

Global $__OpenedProjects[1][3] = [[0, "", ""]] ; name, path, $hCtrl
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
			_LoadProject(_File_GetPath($sFile) & "\" & $prj.getAttribute("path"), $hTree)
		Next
	Next
EndFunc

Func _LoadProject($sFile, $hParent = $hTree)
	Local $oXml = ObjCreate("Microsoft.XMLDOM")
	If Not IsObj($oXml) Or Not FileExists($sFile) Then Return SetError(1, 0, 0)
	; ---
	$oXml.Load($sFile)
	Local $projects = $oXml.SelectNodes("/Project")
	If Not IsObj($projects) Then Return SetError(2, 0, 0)
	; ---
	Local $prjName, $hCtrl, $iProjectID
	For $elem In $projects
		$prjName = _XML_getDisplayName($elem)
		If __OpenProject_IsOpen($prjName, $sFile) Then ContinueLoop
		; ---
		$hCtrl = _TV_Add($prjName, "project", $hParent, $sFile)
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

Func __OpenProject_Add($sName, $sPath, $CtrlID)
	ReDim $__OpenedProjects[$__OpenedProjects[0][0] + 2][3]
	$__OpenedProjects[0][0] += 1
	$__OpenedProjects[$__OpenedProjects[0][0]][0] = $sName
	$__OpenedProjects[$__OpenedProjects[0][0]][1] = $sPath
	$__OpenedProjects[$__OpenedProjects[0][0]][2] = $CtrlID
	; ---
	If $__ActifProject = 0 Then __SetActifProject($__OpenedProjects[0][0])
	; ---
	Return $__OpenedProjects[0][0]
EndFunc

Func __OpenProject_Del($sName, $sPath)
	For $i = 1 To $__OpenedProjects[0][0]
		If $__OpenedProjects[$i][0] = $sName And $__OpenedProjects[$i][1] = $sPath Then
			_ArrayDelete($__OpenedProjects, $i)
			$__OpenedProjects[0][0] -= 1
			; ---
			Return
		EndIf
	Next
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
		_GuiCtrlTreeView_SetBold($hTree, $__OpenedProjects[$__ActifProject][2], False)
		$__ActifProject = $iID
		_GuiCtrlTreeView_SetBold($hTree, $__OpenedProjects[$__ActifProject][2], True)
	Else
		If $__OpenedProjects[0][0] > 0 Then
			__SetActifProject($__OpenedProjects[0][0])
		Else
			$__ActifProject = 0
		EndIf
	EndIf
EndFunc

; ##############################################################

Func _XML_getDisplayName($node)
	Switch StringUpper($node.nodeName())
		Case "PROJECT", "FOLDER"
			Return $node.getAttribute("name")
		Case "FILE"
			Return $node.getAttribute("path")
	EndSwitch
	Return ""
EndFunc   ;==>XML_getDisplayName
