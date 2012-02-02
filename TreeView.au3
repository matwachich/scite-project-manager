#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include <Array.au3>
#include <GuiTreeView.au3>

Global $__TV_Assoc[1][3] = [[0, "", ""]] ; hndl, info, parent
; ---

Func _TV_Add($sText, $sType, $hParent, $sPath = "", $iProjectID = "")
	Local $hCtrl, $iIco
	Switch $sType
		Case "project"
			$hCtrl = _GuiCtrlTreeView_Add($hTree, 0, $sText, 0, 0)
			;_TV_ItemSetInfo($hCtrl, "PROJECT|" & $iProjectID & "|" & $sPath)
			; doit être fait après avoir ajouter le projet au Array des projets ouverts, pour pouvoir y associer le iProjectID
			; c'est fait dans la fontion _LoadProject (Projects.au3)
		Case "file"
			Switch _File_GetExt($sPath)
				Case "au3"
					$iIco = 2
				Case "txt"
					$iIco = 3
				Case "ini", "cfg"
					$iIco = 4
				Case Else
					$iIco = 5
			EndSwitch
			; ---
			$hCtrl = _GuiCtrlTreeView_AddChild($hTree, $hParent, $sText, $iIco, $iIco)
			_TV_ItemSetInfo($hCtrl, "FILE|" & $iProjectID & "|" & $sPath, $iProjectID)
		Case "folder"
			$hCtrl = _GuiCtrlTreeView_AddChild($hTree, $hParent, $sText, 1, 1)
			_TV_ItemSetInfo($hCtrl, "FOLDER|" & $iProjectID, $iProjectID)
	EndSwitch
	; ---
	Return $hCtrl
EndFunc

Func _TV_ItemGetProjectID($hItem)
	For $i = 1 To $__OpenedProjects[0][0]
		If $hItem = $__OpenedProjects[$i][2] Then Return $i
	Next
	Return SetError(1, 0, 0)
EndFunc

; hParent doit toujours être le Item du projet (et pas d'un dossier) pour que la suppression
; lors de la fermeture d'un project se passe bien (sans résidus)
Func _TV_ItemSetInfo($hItem, $sData, $iProjectID = 0)
	Local $hParent = 0 ; doit être le Item du projet
	If $iProjectID > 0 Then $hParent = __OpenProject_GetItemHandle($iProjectID)
	Local $assocInfoID = _TV_AssocInfo_Add($hItem, $sData, $hParent)
	_GuiCtrlTreeView_SetItemParam($hTree, $hItem, $assocInfoID)
EndFunc

; Retourne un Array de forme:
; 0 = Item Text
; 1 = Item Type (PROJECT, FILE, FOLDER)
; 2 = Project ID
; 3 = File Path (for Project and File only)
Func _TV_ItemGetInfo($hItem)
	Local $info = _TV_AssocInfo_Get(_GuiCtrlTreeView_GetItemParam($hTree, $hItem))
	Local $text = _GuiCtrlTreeView_GetText($hTree, $hItem)
	; ---
	Local $ret[1] = [$text]
	$info = StringSplit($info, "|", 1)
	; ---
	For $i = 1 To $info[0]
		_ArrayAdd($ret, $info[$i])
	Next
	; ---
	Return $ret
EndFunc

; ##############################################################

Func _TV_ProjectToXML($hItem)
	Local $xml = '<Project name="' & _GuiCtrlTreeView_GetText($hTree, $hItem) & '">' & @CRLF
	; ---
	__TV_ParseSubItems($xml, $hItem, 1)
	$xml &= '</Project>'
	; ---
	Return $xml
EndFunc

Func __TV_ParseSubItems(ByRef $xml, $hItem, $iIndent)
	Local $count = _GuiCtrlTreeView_GetChildCount($hTree, $hItem)
	If $count <= 0 Then Return
	; ---
	Local $tmp
	Local $first = _GuiCtrlTreeView_GetFirstChild($hTree, $hItem)
	If _GuiCtrlTreeView_GetChildCount($hTree, $first) > 0 Then
		__TV_XmlAppend($xml, '<Folder name="' & _GuiCtrlTreeView_GetText($hTree, $first) & '">', $iIndent)
			__TV_ParseSubItems($xml, $first, $iIndent + 1)
			__TV_XmlAppend($xml, '</Folder>', $iIndent)
	Else
		; ne pas oublier de mettre le path du fichier (ok)
		$tmp = _TV_ItemGetInfo($first)
		__TV_XmlAppend($xml, '<File path="' & $tmp[3] & '"></File>', $iIndent)
	EndIf
	; ---
	Local $currItem
	For $i = 2 To $count
		$currItem = _GuiCtrlTreeView_GetNextChild($hTree, $first)
		; ---
		If _GuiCtrlTreeView_GetChildCount($hTree, $currItem) > 0 Then
			__TV_XmlAppend($xml, '<Folder name="' & _GuiCtrlTreeView_GetText($hTree, $currItem) & '">', $iIndent)
			__TV_ParseSubItems($xml, $currItem, $iIndent + 1)
			__TV_XmlAppend($xml, '</Folder>', $iIndent)
		Else
			; ne pas oublier de mettre le path du fichier (ok)
			$tmp = _TV_ItemGetInfo($currItem)
			__TV_XmlAppend($xml, '<File path="' & $tmp[3] & '"></File>', $iIndent)
		EndIf
		; ---
		$first = $currItem
	Next
EndFunc

Func __TV_XmlAppend(ByRef $xml, $sText, $iIndent)
	$xml &= _StringRepeat(@TAB, $iIndent) & $sText & @CRLF
EndFunc

; ##############################################################

Func _TV_AssocInfo_Add($hItem, $sInfo, $hParent = 0)
	Local $id = __FindSlot()
	$__TV_Assoc[$id][0] = $hItem
	$__TV_Assoc[$id][1] = $sInfo
	$__TV_Assoc[$id][2] = $hParent
	Return $id
EndFunc

Func _TV_AssocInfo_Modify($hItem, $sInfo)
	Local $id = _GuiCtrlTreeView_GetItemParam($hTree, $hItem)
	$__TV_Assoc[$id][1] = $sInfo
EndFunc

Func _TV_AssocInfo_Get($ID)
	Return $__TV_Assoc[$ID][1]
EndFunc

Func _TV_AssocInfo_Del($hItem)
	For $i = $__TV_Assoc[0][0] To 1 Step -1
		If $__TV_Assoc[$i][2] = $hItem Or $__TV_Assoc[$i][0] = $hItem Then
			$__TV_Assoc[$i][0] = 0
			$__TV_Assoc[$i][1] = ""
			$__TV_Assoc[$i][2] = 0
			; ---
			If $__TV_Assoc[0][0] = $i Then
				_ArrayDelete($__TV_Assoc, $i)
				$__TV_Assoc[0][0] -= 1
			EndIf
		EndIf
	Next
EndFunc

Func __FindSlot()
	For $i = 1 To $__TV_Assoc[0][0]
		If $__TV_Assoc[$i][0] = 0 Then Return $i
	Next
	ReDim $__TV_Assoc[$__TV_Assoc[0][0] + 2][3]
	$__TV_Assoc[0][0] += 1
	Return $__TV_Assoc[0][0]
EndFunc
