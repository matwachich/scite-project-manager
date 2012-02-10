#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include <Array.au3>
#include <GuiTreeView.au3>
#include <GuiEdit.au3>

Global $__TV_Assoc[1][3] = [[0, "sInfo", "hParent"]] ; hndl, info, parent
; ---

Func _TV_Add($sText, $sType, $hParent, $sPath = "", $iProjectID = "")
	Local $hCtrl, $iIco
	Switch $sType
		Case "project"
			$hCtrl = _GuiCtrlTreeView_Add($__hTree, 0, $sText, 0, 0)
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
			$hCtrl = _GuiCtrlTreeView_AddChild($__hTree, $hParent, $sText, $iIco, $iIco)
			_TV_ItemSetInfo($hCtrl, "FILE|" & $iProjectID & "|" & $sPath, $iProjectID)
		Case "folder"
			$hCtrl = _GuiCtrlTreeView_InsertItem($__hTree, $sText, $hParent, $hParent, 1, 1)
			_TV_ItemSetInfo($hCtrl, "FOLDER|" & $iProjectID, $iProjectID)
	EndSwitch
	; ---
	Return $hCtrl
EndFunc

Func _TV_GetAllChildren($hItem)
	Local $count = _GuiCtrlTreeView_GetChildCount($__hTree, $hItem)
	If $count < 1 Then Return 0
	; ---
	Local $ret[$count + 1] = [$count]
	Local $curr
	; ---
	$curr = _GuiCtrlTreeView_GetFirstChild($__hTree, $hItem)
	$ret[1] = $curr
	; ---
	For $i = 2 To $count
		$ret[$i] = _GuiCtrlTreeView_GetNextChild($__hTree, $curr)
		$curr = $ret[$i]
	Next
	; ---
	Return $ret
EndFunc

; hParent doit toujours être le Item du projet (et pas d'un dossier) pour que la suppression
; lors de la fermeture d'un project se passe bien (sans résidus)
Func _TV_ItemSetInfo($hItem, $sData, $iProjectID = 0)
	Local $hParent = 0 ; doit être le Item du projet
	If $iProjectID > 0 Then $hParent = __OpenProject_GetItemHandle($iProjectID)
	Local $assocInfoID = _TV_AssocInfo_Add($hItem, $sData, $hParent)
	_GuiCtrlTreeView_SetItemParam($__hTree, $hItem, $assocInfoID)
EndFunc

; Retourne un Array de forme:
; 0 = Item Text
; 1 = Item Type (PROJECT, FILE, FOLDER)
; 2 = Project ID
; 3 = File Path (for Project and File only)
Func _TV_ItemGetInfo($hItem)
	Local $info = _TV_AssocInfo_Get(_GuiCtrlTreeView_GetItemParam($__hTree, $hItem))
	Local $text = _GuiCtrlTreeView_GetText($__hTree, $hItem)
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

Global $__Int_LastHoverItem = 0

Func __TV_HandleDrag()
	If Not $__TV_DragMode Then Return
	; ---
	Local $hItem, $Info
	; si le bouton n'a pas encore été relaché
	If _IsPressed("01", $__User32_Dll) Then
		; récupère l'item sous le curseur
		$hItem = __TV_MouseItem()
		If Not $hItem Then
			; pas d'item => on désactive le InsertMark
			_GuiCtrlTreeView_SetInsertMark($__hTree, 0)
		Else
			; si il y a un item, et qu'il est différent du dernier item traité
			If $__Int_LastHoverItem And $__Int_LastHoverItem <> $hItem Then
				; on enlève tout InsertMark et Selection d'item d'abords...
				_GuiCtrlTreeView_SetInsertMark($__hTree, 0)
				_GuiCtrlTreeView_SetSelected($__hTree, $__Int_LastHoverItem, False)
				; ---
				; ... puis, selon son type (de l'item), on met un InsertMark et/ou on selectionne l'item
				$Info = _TV_ItemGetInfo($hItem)
				Switch $Info[1]
					Case "FILE"
						_GuiCtrlTreeView_SetInsertMark($__hTree, $hItem)
					Case "FOLDER", "PROJECT"
						_GuiCtrlTreeView_SetSelected($__hTree, $hItem, True)
						_GuiCtrlTreeView_SetInsertMark($__hTree, _GuiCtrlTreeView_GetLastChild($__hTree, $hItem))
				EndSwitch
			EndIf
			; ---
			$__Int_LastHoverItem = $hItem
		EndIf
	Else
		; End Drag (bouton relaché)
		; ---
		;ConsoleWrite("Drag OFF" & @CRLF)
		; ---
		$Info = _TV_ItemGetInfo($__TV_Drag_hItem)
		__OpenProject_SetModified($Info[2])
		; ---
		$Info = _TV_ItemGetInfo($__Int_LastHoverItem)
		Switch $Info[1]
			Case "FILE"
				__TV_FileMove($__TV_Drag_hItem, _GuiCtrlTreeView_GetParentHandle($__hTree, $__Int_LastHoverItem), $__Int_LastHoverItem)
			Case "FOLDER", "PROJECT"
				__TV_FileMove($__TV_Drag_hItem, $__Int_LastHoverItem, _GuiCtrlTreeView_GetLastChild($__hTree, $__Int_LastHoverItem))
		EndSwitch
		; ---
		_GuiCtrlTreeView_SetInsertMark($__hTree, 0)
		_GuiCtrlTreeView_SetSelected($__hTree, $__Int_LastHoverItem, False)
		$__TV_DragMode = 0
		$__TV_Drag_hItem = 0
		$__Int_LastHoverItem = 0
	EndIf
EndFunc

Func __TV_FileMove($hItem, $hParent, $hAfter)
	Local $infoID = _GuiCtrlTreeView_GetItemParam($__hTree, $hItem)
	Local $text = _GuiCtrlTreeView_GetText($__hTree, $hItem)
	Local $icoID = _GuiCtrlTreeView_GetImageIndex($__hTree, $hItem)
	; ---
	_GuiCtrlTreeView_Delete($__hTree, $hItem)
	Local $hNewItem = _GuiCtrlTreeView_InsertItem($__hTree, $text, $hParent, $hAfter, $icoID, $icoID)
	_GuiCtrlTreeView_SetItemParam($__hTree, $hNewItem, $infoID)
	; ---
	; car l'item a changer, on doit mettre à jour son handle dans le array $__TV_Assoc
	_TV_AssocInfo_ChangeHandles($infoID, $hNewItem)
EndFunc

; Trop complexe! Ne peut transporter qu'un FOLDER n'ayant aucun FOLDER comme child!
#cs
Func __TV_FolderMove($hItem, $hParent, $hAfter)
	Local $infoID = _GuiCtrlTreeView_GetItemParam($__hTree, $hItem)
	Local $text = _GuiCtrlTreeView_GetText($__hTree, $hItem)
	Local $icoID = _GuiCtrlTreeView_GetImageIndex($__hTree, $hItem)
	; ---
	Local $Info
	Local $aItems[1][3] = [[0, "", ""]] ; text, infoID, icoID
	Local $first = _GuiCtrlTreeView_GetFirstChild($__hTree, $hItem), $curr
	If $first Then
		__TV_FolderMove_AddToArray($aItems, $first)
		$Info = _TV_ItemGetInfo($first)
		If $Info[1] = "FOLDER" Then Return _Err(LANG("err_drag_Folder"))
		; ---
		While 1
			$curr = _GUICtrlTreeView_GetNextChild($__hTree, $first)
			If Not $curr Then ExitLoop
			; ---
			$Info = _TV_ItemGetInfo($curr)
			If $Info[1] = "FOLDER" Then Return _Err(LANG("err_drag_Folder"))
			; ---
			__TV_FolderMove_AddToArray($aItems, $curr)
			; ---
			$first = $curr
		WEnd
	EndIf
	; ---
	_GUICtrlTreeView_Delete($__hTree, $hItem)
	; ---
	Local $hNewItem = _GUICtrlTreeView_InsertItem($__hTree, $text, $hParent, $hAfter, $icoID, $icoID)
	; ---
	Local $hNewChild
	For $i = 1 To $aItems[0][0]
		$hNewChild = _GuiCtrlTreeView_AddChild($__hTree, $hNewItem, $aItems[$i][0], $aItems[$i][2], $aItems[$i][2])
		_GuiCtrlTreeView_SetItemParam($__hTree, $hNewChild, $aItems[$i][1])
		_TV_AssocInfo_ChangeHandles($aItems[$i][1], $hNewChild)
	Next
EndFunc

Func __TV_FolderMove_AddToArray(ByRef $array, $hItem)
	ReDim $array[$array[0][0] + 2][3]
	$array[0][0] += 1
	; ---
	$array[$array[0][0]][0] = _GUICtrlTreeView_GetText($__hTree, $hItem)
	$array[$array[0][0]][1] = _GUICtrlTreeView_GetItemParam($__hTree, $hItem)
	$array[$array[0][0]][2] = _GUICtrlTreeView_GetImageIndex($__hTree, $hItem)
EndFunc
#ce

Func _TV_AfterRename($hItem, $sNewText)
	Local $Info = _TV_ItemGetInfo($hItem)
	Switch $Info[1]
		Case "PROJECT"
			__OpenProject_SetName($Info[2], $sNewText)
		Case "FOLDER"
			; rien a faire
		Case "FILE"
			If CFG("rename_askConfirmation") = $GUI_CHECKED And Not _Ask(LNG("prompt_confirmFileRename")) Then Return False
			; ---
			Local $sPath = _File_GetPath(__OpenProject_GetPath($Info[2])) & "\" & $Info[3]
			; si le fichier ne se trouve pas dans un dossier identique ou enfant du dossier du projet
			If StringInStr($sPath, "..") Then $sPath = _PathFull($sPath)
			; ---
			Local $sNewPath = _File_GetPath($sPath) & "\" & $sNewText
			; ---
			If CFG("rename_backupFile") = $GUI_CHECKED Then FileCopy($sPath, $sPath & ".bak")
			FileMove($sPath, $sNewPath)
			; ---
			_TV_AssocInfo_Modify($hItem, "FILE|" & $Info[2] & "|" & _PathGetRelative(_File_GetPath(__OpenProject_GetPath($Info[2])), $sNewPath))
			; ---
			Local $iIco
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
			_GuiCtrlTreeView_SetImageIndex($__hTree, $hItem, $iIco)
	EndSwitch
	; ---
	__OpenProject_SetModified($Info[2])
	Return True
EndFunc

; ##############################################################

Func _TV_ProjectToXML($hItem, $iProjectID)
	local $rootExpandStatus = _GuiCtrlTreeView_GetExpanded($__hTree, $hItem)
	Local $xml = '<Project name="' & __OpenProject_GetName($iProjectID) & '" exp="' & $rootExpandStatus & '">' & @CRLF
	; ---
	; rootExpandStatus: on passe ce paramètre pour que dans la suite (__TV_ParseSubItems), si le Item du projet (root)
	; est collapsed, alors on met tous les dossiers sur collapsed, pour que la restitution du status à l'ouverture
	; se passe bien (si un dossier est expanded, alors même le projet sera expanded)
	__TV_ParseSubItems($xml, $hItem, 1, $rootExpandStatus)
	$xml &= '</Project>'
	; ---
	Return $xml
EndFunc

Func __TV_ParseSubItems(ByRef $xml, $hItem, $iIndent, $sRootExpandStatus)
	Local $count = _GuiCtrlTreeView_GetChildCount($__hTree, $hItem)
	If $count <= 0 Then Return
	; ---
	Local $tmp
	Local $first = _GuiCtrlTreeView_GetFirstChild($__hTree, $hItem)
	If _GuiCtrlTreeView_GetChildCount($__hTree, $first) > 0 Then
		__TV_XmlAppend($xml, __TV_Xml_AddFolder($first, _GuiCtrlTreeView_GetText($__hTree, $first), $sRootExpandStatus), $iIndent)
		__TV_ParseSubItems($xml, $first, $iIndent + 1, $sRootExpandStatus)
		__TV_XmlAppend($xml, '</Folder>', $iIndent)
	Else
		; ne pas oublier de mettre le path du fichier (ok)
		$tmp = _TV_ItemGetInfo($first)
		Switch $tmp[1]
			Case "FILE"
				__TV_XmlAppend($xml, '<File path="' & $tmp[3] & '"></File>', $iIndent)
			Case "FOLDER"
				__TV_XmlAppend($xml, __TV_Xml_AddFolder($first, $tmp[0], $sRootExpandStatus, 1), $iIndent)
		EndSwitch
	EndIf
	; ---
	Local $currItem
	For $i = 2 To $count
		$currItem = _GuiCtrlTreeView_GetNextChild($__hTree, $first)
		; ---
		If _GuiCtrlTreeView_GetChildCount($__hTree, $currItem) > 0 Then
			__TV_XmlAppend($xml, __TV_Xml_AddFolder($currItem, _GuiCtrlTreeView_GetText($__hTree, $currItem), $sRootExpandStatus), $iIndent)
			__TV_ParseSubItems($xml, $currItem, $iIndent + 1, $sRootExpandStatus)
			__TV_XmlAppend($xml, '</Folder>', $iIndent)
		Else
			; ne pas oublier de mettre le path du fichier (ok)
			$tmp = _TV_ItemGetInfo($currItem)
			Switch $tmp[1]
				Case "FILE"
					__TV_XmlAppend($xml, '<File path="' & $tmp[3] & '"></File>', $iIndent)
				Case "FOLDER"
					__TV_XmlAppend($xml, __TV_Xml_AddFolder($currItem, $tmp[0], $sRootExpandStatus, 1), $iIndent)
			EndSwitch
		EndIf
		; ---
		$first = $currItem
	Next
EndFunc

Func __TV_XmlAppend(ByRef $xml, $sText, $iIndent)
	$xml &= _StringRepeat(@TAB, $iIndent) & $sText & @CRLF
EndFunc

Func __TV_Xml_AddFolder($hItem, $sName, $sExp, $iClose = 0)
	If $sExp = True Then
		$sExp = _GuiCtrlTreeView_GetExpanded($__hTree, $hItem)
	EndIf
	; ---
	$str = '<Folder name="' & $sName & '" exp="' & $sExp & '">'
	If $iClose Then $str &= '</Folder>'
	; ---
	Return $str
EndFunc

; ##############################################################

Func _TV_AssocInfo_Add($hItem, $sInfo, $hParent = 0)
	Local $id = __TV_AssocInfo_FindSlot()
	$__TV_Assoc[$id][0] = $hItem
	$__TV_Assoc[$id][1] = $sInfo
	$__TV_Assoc[$id][2] = $hParent ; ici, ce n'est pas un dossier qui sera contenu, mais le handle de l'item ROOT du projet
	Return $id
EndFunc

Func _TV_AssocInfo_Modify($hItem, $sInfo)
	Local $id = _GuiCtrlTreeView_GetItemParam($__hTree, $hItem)
	$__TV_Assoc[$id][1] = $sInfo
EndFunc

Func _TV_AssocInfo_ChangeHandles($iInfoID, $hItem)
	If $iInfoID > $__TV_Assoc[0][0] Then Return
	; ---
	$__TV_Assoc[$iInfoID][0] = $hItem
EndFunc

Func _TV_AssocInfo_Get($ID)
	Return $__TV_Assoc[$ID][1]
EndFunc

Func _TV_AssocInfo_Del($hItem)
	For $i = 1 To $__TV_Assoc[0][0]
		; Si c'est le item, ou un de ses enfants
		If $__TV_Assoc[$i][2] = $hItem Or $__TV_Assoc[$i][0] = $hItem Then
			$__TV_Assoc[$i][0] = ""
			$__TV_Assoc[$i][1] = ""
			$__TV_Assoc[$i][2] = ""
		EndIf
	Next
	; ---
	__TV_AssocInfo_CleanEmptySlots()
EndFunc

Func __TV_AssocInfo_FindSlot()
	__TV_AssocInfo_CleanEmptySlots()
	; ---
	For $i = 1 To $__TV_Assoc[0][0]
		If Not $__TV_Assoc[$i][0] Then Return $i
	Next
	; ---
	ReDim $__TV_Assoc[$__TV_Assoc[0][0] + 2][3]
	$__TV_Assoc[0][0] += 1
	Return $__TV_Assoc[0][0]
EndFunc

Func __TV_AssocInfo_CleanEmptySlots()
	;_ArrayDisplay($__TV_Assoc, "Befor Clean")
	For $i = $__TV_Assoc[0][0] To 1 Step -1
		If $__TV_Assoc[$i][0] Then ExitLoop
		; ---
		_ArrayDelete($__TV_Assoc, $i)
		$__TV_Assoc[0][0] -= 1
	Next
	;_ArrayDisplay($__TV_Assoc, "After Clean")
EndFunc

; ##############################################################

Func __TV_MouseItem()
	Local $tMPos = _WinAPI_GetMousePos(True, $__hTree)
    Return _GUICtrlTreeView_HitTestItem($__hTree, DllStructGetData($tMPos, 1), DllStructGetData($tMPos, 2))
EndFunc

; expand one item, without expanding it's child items that have childs (from _GuiCtrlTreeView_ExpandItem)
Func __TV_ExpandItems($aItems)
	If IsArray($aItems) Then
		For $i = 1 To $aItems[0]
			_SendMessage($__hTree, $TVM_EXPAND, $TVE_EXPAND, $aItems[$i], 0, "wparam", "handle")
			_SendMessage($__hTree, $TVM_ENSUREVISIBLE, 0, $aItems[$i], 0, "wparam", "handle")
		Next
	Else
		_SendMessage($__hTree, $TVM_EXPAND, $TVE_EXPAND, $aItems, 0, "wparam", "handle")
		_SendMessage($__hTree, $TVM_ENSUREVISIBLE, 0, $aItems, 0, "wparam", "handle")
	EndIf
EndFunc
