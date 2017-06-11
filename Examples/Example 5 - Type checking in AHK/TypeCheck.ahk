#Include ..\..\Libs\JSON.ahk

msgbox("A string")
;There is no way to distinguish between "97" and 97 in AHK
msgbox("97")
msgbox(97)
msgbox({a:1,b:"stuff"})
msgbox([1,2,3])
msgbox("I am`r`na little`nstrange`rright?")

;Written by lexicos. Reminder: there is a seperate function for COM.
;https://autohotkey.com/boards/viewtopic.php?t=2306
; Object version - depends on current float format including a decimal point.
type(v) {
    if IsObject(v)
        return "Object"
	return v="" || [v].GetCapacity(1) ? "String" : "Number"
	
	;Changed this for my usecase
	;return v="" || [v].GetCapacity(1) ? "String" : InStr(v,".") ? "Float" : "Integer"
}




;	Type(o){
;		if(Abs(o)<>""){
;			return "Number"
;		} else if(isObject(o)){
;			return "Object"
;		} else {
;			return "String"	
;		}
;	}

Msgbox(s){
	Msgbox, % JSON_Stringify(s) . " --> " . Type(s)
}

;json := new Json("", "")
;k := Type(s) == "Object" ? JSON.stringify(s) : s
;Msgbox, % k . " --> " . Type(s)

JSON_Stringify(x){
	json := new Json("", "")
	
	if(Type(x)=="Object"){
		return json.stringify(x)
	} else if(Type(x)=="String"){
		x := RegexReplace(x,"(\n|\r)+","\n")
		return """" . x . """"
	} else if(Type(x)=="Number"){
		return x
	}
}

/*
	if(o is number){
		return o
	} else if(isObject(o)){
		json := new Json("  ", "`r`n")
		return json.stringify(o)
	} else {  ;Variable must be string
		return """" . o . """"
	}
*/