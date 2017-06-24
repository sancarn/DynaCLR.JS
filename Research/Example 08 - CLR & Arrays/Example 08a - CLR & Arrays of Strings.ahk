#Include Libs\CLR.AHK
code = 
(
Imports System
Imports System.Runtime.InteropServices
Imports System.Windows.Forms
Class MainCLass
	Function TestArray(inArray as object) as string()
		For i as integer = 1 to inArray.length()
			Messagebox.Show(inArray(i))
		Next
		
		Dim outArray(0 to 9) as String
		For i as integer = 0 to 9
			Messagebox.Show(i)
			outArray(i) = "A" & i
		Next
		
		return outArray
	End Function
End Class
)

asm := CLR_CompileVB(code, "System.dll | System.Windows.Forms.dll")
obj := CLR_CreateObject(asm, "MainClass")
newArr := obj.TestArray(["A","S","D","F","G"])

if (COMObjType(newArr) && 0x2000){ ;if object is of type SafeArray then...
	msgbox, % newArr.MinIndex() "..." newArr.MaxIndex() "`n" newArr[1]
	for k in newArr
		msgbox, %k%
}

;Msgbox::
;A
;S
;D
;F
;G
;0
;1
;2
;3
;4
;5
;6
;7
;8
;9
;A1
;A2
;A3
;A4
;A5
;A6
;A7
;A8
;A9


;	SafeArrayDestroy(psa){
;		Return, DLLCall("oleaut32\SafeArrayDestroy", "UInt", psa)
;	}
;	SafeArrayGetDim(psa){
;		Return, DLLCall("oleaut32\SafeArrayGetDim", "UInt", psa)
;	}
;	SafeArrayGetLBound(psa,nDim=1){
;		VarSetCapacity(plLBound,16,0)
;		DllCall("oleaut32\SafeArrayGetLBound", "UInt", psa, "Int", nDim, "UInt", &plLBound)
;		return, NumGet(plLBound,0)
;	}
;	SafeArrayGetUBound(psa,nDim=1){
;		VarSetCapacity(plLBound,16,0)
;		DllCall("oleaut32\SafeArrayGetUBound", "UInt", psa, "Int", nDim, "UInt", &plLBound)
;		return, NumGet(plLBound,0)
;	}
;	SafeArrayGetElement(psa,indices){
;		nDim := SafeArrayGetDim(psa)
;		Loop, Parse, indices, `,
;		{
;			If(A_Index < nDim)
;				x+=A_LoopField * A_Index ;calculate elements location - 1
;			y:= A_LoopField ;calculate elements location -2
;		}
;		If(nDim>1){
;			z=1
;			Loop, % nDim -1 ;calculate elements location -3
;			{
;				lBound := (test:=SafeArrayGetLBound(psa,A_Index)) ? test : 0 ;test for lower bound
;				z *= SafeArrayGetUBound(psa,A_Index) - lbound + 1
;			}
;			index := x+y*z
;		} else {
;			index := indices
;		}
;		
;		pva = NumGet(psa+12)
;		type := NumGet(pva+(Index) * 16,0,"UShort")
;		If (Type=2)
;			return numget(pva+(Index+1)*16-8,0,"short")
;		If (Type=3)
;			return numget(pva+(Index+1)*16-8,0,"int")
;		If (Type=4)
;			return numget(pva+(Index+1)*16-8,0,"Float")
;		If (Type=5)
;			return regexreplace(numget(pva+(Index+1)*16-8,0,"Double"),"\.?0*$")
;		Else 
;			Return Numget(pva + (Index+1)*16-8)
;	}