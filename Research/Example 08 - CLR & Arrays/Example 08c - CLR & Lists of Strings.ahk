#Include Libs\CLR.AHK
code = 
(
Imports System
Imports System.Collections.Generic
Class MainCLass
	Function TestArray() as List(Of String)
		return New List(Of String)(New String() {"This","is","a","string","!!!"})
	End Function
End Class
)

asm := CLR_CompileVB(code, "System.dll")
obj := CLR_CreateObject(asm, "MainClass")
list := obj.TestArray()

;;	msgbox, % ComObjType(list) ;VT_DISPATCH
;Get ICollection from returned object (oRet)
comType := ComObjType(list)
ICollection := ComObject(comType, ComObjQuery(list, "{DE8DB6F8-D101-3A92-8D1C-E72E5F10E992}"), 1)

;Get IList from ICollection
IList := ComObject(comType, ComObjQuery(ICollection, "{7BCFA00F-F764-3113-9140-3BBD127A96BB}"), 1)

;Loop over the list and append them to an array
ret := []
Loop, % ICollection.Count()
	ret.push(IList.Item(A_Index - 1))
	
Loop, % ret.length()
	msgbox, % ret[A_Index]

msgbox, % ComObjType([1,"a",3])


;;; Msgbox::
;This
;is
;a
;string
;!!!
;;; As required