#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Matwachich

 Script Function:


#ce ----------------------------------------------------------------------------
#Include-Once

#include <Array.au3>
#include <GuiTreeView.au3>

Global $__TV_Assoc[1][3] = [[0, "", ""]] ; hndl, info, parent

Func _TV_Add($sText, $sType, $hParent, $sPath = "", $iProjectID = "")
	Local $hCtrl, $iIco
	Switch $sType
		Case "project"
			$hCtrl = _GuiCtrlTreeView_Add($hTree, 0, $sText, 0, 0)
			;_GuiCtrlTreeView_SetItemParam($hTree, $hCtrl, _TV_AssocInfo($hCtrl, "PROJECT|" & $iProjectID & "|" & $sPath))
			; doit être fait après avoir ajouter le projet au Array des projets ouverts, pour pouvoir y associer le iProjectID
			; c'est fait dans la fontion _LoadProject
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
			_TV_ItemSetInfo($hCtrl, "FILE|" & $iProjectID & "|" & $sPath)
		Case "folder"
			$hCtrl = _GuiCtrlTreeView_AddChild($hTree, $hParent, $sText, 1, 1)
			_TV_ItemSetInfo($hCtrl, "FOLDER|" & $iProjectID)
	EndSwitch
	; ---
	Return $hCtrl
EndFunc

Func _TV_ItemSetInfo($hItem, $sData)
	_GuiCtrlTreeView_SetItemParam($hTree, $hItem, _TV_AssocInfo($hItem, $sData))
EndFunc

; Retourne un Array de forme:
; 0 = Item Text
; 1 = Item Type (PROJECT, FILE, FOLDER)
; 2 = Project ID
; 3 = File Path (for Project and File only)
Func _TV_ItemGetInfo($hItem)
	Local $info = _TV_GetAssoc(_GuiCtrlTreeView_GetItemParam($hTree, $hItem))
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

Func _TV_AssocInfo($hItem, $sInfo, $hParent = 0)
	Local $id = __FindSlot()
	$__TV_Assoc[$id][0] = $hItem
	$__TV_Assoc[$id][1] = $sInfo
	$__TV_Assoc[$id][2] = $hParent
	Return $id
EndFunc

Func _TV_GetAssoc($ID)
	Return $__TV_Assoc[$ID][1]
EndFunc

Func _TV_DelAssocInfo($hItem)
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

Func __Info_2_KeyVal($info, ByRef $key, ByRef $val)
	$info = StringSplit($info, "|")
	If $info[0] = 1 Then _ArrayAdd($info, "")
	$key = $info[1]
	$val = $info[2]
EndFunc
