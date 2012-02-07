#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:
	Merci ZDS

#ce ----------------------------------------------------------------------------
#Include-Once

Global $__OpenedProjects[1][4] = [[0, "sPath", "hCtrl", "iModified"]] ; name, path, $hCtrl, $iModified
Global $__ActifProject = 0

#include <Array.au3>
#include <String.au3>

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
		_Last_Add(2, $sFile)
		; ---
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
	; $aToExpend contiendra tous les Elements à Expand à la fin de l'ouverture
	Local $prjName, $hCtrl, $iProjectID, $aToExpend[1], $tmp
	For $elem In $projects
		_Last_Add(1, $sFile)
		; ---
		ReDim $aToExpend[1]
		$aToExpend[0] = 0
		; ---
		$prjName = _XML_getDisplayName($elem)
		If __OpenProject_IsOpen($prjName, $sFile) Then ContinueLoop
		; ---
		$hCtrl = _TV_Add($prjName, "project", $__hTree, $sFile)
		; ---
		$tmp = $elem.GetAttribute("exp")
		If $tmp == "True" Then
			_ArrayAdd($aToExpend, $hCtrl)
			$aToExpend[0] += 1
		EndIf
		; ---
		$iProjectID = __OpenProject_Add($prjName, $sFile, $hCtrl)
		_TV_ItemSetInfo($hCtrl, "PROJECT|" & $iProjectID & "|" & $sFile)
		; ---
		__BuildSubTreeView($elem, $hCtrl, $iProjectID, $aToExpend)
		; ---
		__TV_ExpandItems($aToExpend)
		; ---
		_GuiCtrlTreeView_EnsureVisible($__hTree, $hCtrl)
	Next
	; cette boucle ne sert pas à grand chose, car il n'y a qu'un seul projet par fichier
EndFunc

Func __BuildSubTreeView($hNode, $hCtrl, $iProjectID, ByRef $aToExpend)
	; folders
	Local $fld, $fldName
	Local $folders = $hNode.SelectNodes("Folder")
	For $elem In $folders
		$fld = _TV_Add(_XML_getDisplayName($elem), "folder", $hCtrl, "", $iProjectID)
		; ---
		$tmp = $elem.GetAttribute("exp")
		If $tmp == "True" Then
			_ArrayAdd($aToExpend, $fld)
			$aToExpend[0] += 1
		EndIf
		; ---
		__BuildSubTreeView($elem, $fld, $iProjectID, $aToExpend)
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
	Local $sFile = __OpenProject_GetPath($iProjectID)
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
	Local $xml = _TV_ProjectToXML(__OpenProject_GetItemHandle($iProjectID), $iProjectID)
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

; utilisé lors de la fermeture du programme
Func _Project_SaveAll()
	If $__OpenedProjects[0][0] = 0 Then Return 1
	; ---
	For $i = 1 To $__OpenedProjects[0][0]
		If __OpenProject_IsModified($i) Then
			Switch MsgBox(35, LNG("ProgName"), LNG("ask_save", __OpenProject_GetName($i)))
				Case 6 ;yes
					If Not _Project_Save($i) Then Return 0
				Case 7 ;no
					; rien, on continue la fermeture
				Case 2 ;cancel
					Return 0
			EndSwitch
		EndIf
	Next
	; ---
	Return 1
EndFunc

; ##############################################################

; iDontSave est utile pour lors de la fermeture du programme, pour ne pas demander
; 2 fois d'enregistrer un projet modifié
Func _Project_Close($iProjectID, $iDontSave = 0)
	If $iProjectID > $__OpenedProjects[0][0] Or $iProjectID <= 0 Then Return
	; ---
	If Not $iDontSave And __OpenProject_IsModified($iProjectID) Then
		Switch MsgBox(35, LNG("ProgName"), LNG("ask_save", __OpenProject_GetName($iProjectID)))
			Case 6 ;yes
				If Not _Project_Save($iProjectID) Then Return 0
			Case 7 ;no
				; rien, on continue la fermeture
			Case 2 ;cancel
				Return 0
		EndSwitch
	EndIf
	; ---
	;If __OpenProject_IsModified($iProjectID) And _Ask(LNG("ask_save", __OpenProject_GetName($iProjectID))) Then
	;	If Not _Project_Save($iProjectID) Then Return
	;EndIf
	; ---
	Local $hItem = __OpenProject_GetItemHandle($iProjectID)
	_TV_AssocInfo_Del($hItem)
	_GuiCtrlTreeView_Delete($__hTree, $hItem)
	__OpenProject_Del($iProjectID)
	; ---
	Return 1
EndFunc

; ##############################################################

; $iModified est mis a 1 dans _Event_New (nouveau projet)
Func __OpenProject_Add($sName, $sPath, $CtrlID, $iModified = 0)
	Local $index = __OpenProject_Internal_GetSlot()
	;ConsoleWrite("ADD project: " & $sName & " -> " & $index & @CRLF)
	; ---
	$__OpenedProjects[$index][0] = $sName
	$__OpenedProjects[$index][1] = $sPath
	$__OpenedProjects[$index][2] = $CtrlID
	;$__OpenedProjects[$index][3] = $iModified
	; on fait ça pour que la petite étoile se mette en place à coté du nom du projet
	; si celui ci est nouveau
	__OpenProject_SetModified($index, $iModified)
	; ---
	If $__ActifProject = 0 Then __SetActifProject($index)
	; ---
	Return $index
EndFunc

Func __OpenProject_GetName($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, "")
	; ---
	If StringRight($__OpenedProjects[$iProjectID][0], 2) == " *" Then
		Return StringTrimRight($__OpenedProjects[$iProjectID][0], 2)
	Else
		Return $__OpenedProjects[$iProjectID][0]
	EndIf
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
	Local $text = _GuiCtrlTreeView_GetText($__hTree, $__OpenedProjects[$iProjectID][2])
	If $iModified Then
		If StringRight($text, 2) <> " *" Then _
			_GuiCtrlTreeView_SetText($__hTree, $__OpenedProjects[$iProjectID][2], $text & " *")
	Else
		If StringRight($text, 2) == " *" Then _
			_GuiCtrlTreeView_SetText($__hTree, $__OpenedProjects[$iProjectID][2], StringTrimRight($text, 2))
	EndIf
	; ---
	$__OpenedProjects[$iProjectID][3] = $iModified
	Return 1
EndFunc

Func __OpenProject_Del($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, -1)
	; ---
	; Reset le Slot
	For $i = 0 To 3
		$__OpenedProjects[$iProjectID][$i] = ""
	Next
	; ---
	__OpenProject_Internal_CleanEmptySlots()
EndFunc

Func __OpenProject_IsOpen($sName, $sPath)
	For $i = 1 To $__OpenedProjects[0][0]
		If $__OpenedProjects[$i][0] = $sName And $__OpenedProjects[$i][1] = $sPath Then Return 1
	Next
	Return 0
EndFunc

Func __OpenProject_IDIsValid($iProjectID)
	If $iProjectID > $__OpenedProjects[0][0] Then Return SetError(1, 0, 0)
	; ---
	Return $__OpenedProjects[$iProjectID][0] <> ""
EndFunc

Func __OpenProject_Internal_GetSlot()
	__OpenProject_Internal_CleanEmptySlots()
	; ---
	For $i = 1 To $__OpenedProjects[0][0]
		If Not $__OpenedProjects[$i][0] Then Return $i
	Next
	; ---
	;_ArrayDisplay($__OpenedProjects, "Befor Redim")
	Redim $__OpenedProjects[$__OpenedProjects[0][0] + 2][4]
	$__OpenedProjects[0][0] += 1
	;_ArrayDisplay($__OpenedProjects, "After Redim")
	Return $__OpenedProjects[0][0]
EndFunc

Func __OpenProject_Internal_CleanEmptySlots()
	;_ArrayDisplay($__OpenedProjects, "Befor Clean")
	For $i = $__OpenedProjects[0][0] To 1 Step -1
		If $__OpenedProjects[$i][0] Then ExitLoop
		; ---
		_ArrayDelete($__OpenedProjects, $i)
		$__OpenedProjects[0][0] -= 1
	Next
	;_ArrayDisplay($__OpenedProjects, "After Clean")
EndFunc

Func __OpenProject_Internal_GetFirstUsedSlot()
	For $i = 1 To $__OpenedProjects[0][0]
		If $__OpenedProjects[$i][0] Then Return $i
	Next
	Return 0
EndFunc

; ##############################################################

Func __SetActifProject($iID = Default)
	If $iID <> Default Then
		If $iID <> 0 And ($iID > $__OpenedProjects[0][0] Or $iID <= 0) Then Return
	EndIf
	; ---
	If $iID = Default Then
		$__ActifProject = __OpenProject_Internal_GetFirstUsedSlot()
		If $__ActifProject > 0 Then __SetActifProject($__ActifProject)
	Else
		ConsoleWrite("__SetActifProject(" & $iID & ") - " & __OpenProject_GetName($iID) & @CRLF)
		If $__OpenedProjects[$__ActifProject][0] Then _
			_GuiCtrlTreeView_SetBold($__hTree, $__OpenedProjects[$__ActifProject][2], False)
		; ---
		$__ActifProject = $iID
		_GuiCtrlTreeView_SetBold($__hTree, $__OpenedProjects[$__ActifProject][2], True)
		;ConsoleWrite("Set Bold: " & $__OpenedProjects[$__ActifProject][0] & @CRLF)
	EndIf
	#cs
	; ---
	If $iID <> Default Then
		If $iID <> $__ActifProject Then
			If $__ActifProject <= $__OpenedProjects[0][0] Then
				_GuiCtrlTreeView_SetBold($hTree, $__OpenedProjects[$__ActifProject][2], False)
				$__ActifProject = $iID
				_GuiCtrlTreeView_SetBold($hTree, $__OpenedProjects[$__ActifProject][2], True)
			Else
				__SetActifProject()
			EndIf
		EndIf
	Else
		If $__OpenedProjects[0][0] > 0 Then
			__SetActifProject($__OpenedProjects[0][0])
		Else
			$__ActifProject = 0
		EndIf
	EndIf
	#ce
EndFunc
