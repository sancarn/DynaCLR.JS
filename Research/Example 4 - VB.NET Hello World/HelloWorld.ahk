#Include Libs\CLR.ahk

vb =
(
    Imports System.Windows.Forms
    Class Foo
        Public Sub Test()
            MessageBox.Show("Hello, world, from VB!")
        End Sub
    End Class`
)

classToTest	:= "Foo"
 funcToTest	:= "Test"

asm := CLR_CompileVB(vb, "System.dll | System.Windows.Forms.dll")
obj := CLR_CreateObject(asm, classToTest)
;obj.Test("Bob")
execObjMember(obj,funcToTest,)


execObjMember(obj,theFunc,theArgs){
	return obj[theFunc](theArgs*)
}
val(a){
return % a
}