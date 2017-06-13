shell := ComObjCreate("wscript.shell")
args:=["notepad.exe"]


;Does work:
;execObjMember(shell,"Run",args)

;Does work:
;execObjMember(foo,"bar",["Amazing!"])

;Does work:
;execObjMember(shell,"Run",["notepad.exe"])

execObjMember(obj,theFunc,theArgs){
	return obj[theFunc](theArgs*)
}

Class foo
{
	bar(bas){
		msgbox, %bas%
	}

}