;JSON CLASS
;------------------------------------
;FOUND ON STACKOVERFLOW
;https://stackoverflow.com/a/33989043/6302131
;
;DESCRIPTION
;Here is a Json class I wrote recently. It automatically handles indentation and newline chars. You can even specify which characters to use etc.
;And it also handles edge cases like double quotes within strings (they need to be escaped in json), that's something I was really missing from other json functions in ahk.
;
;LIST OF METHODS
;json.jsonFileToObj(fileFullPath)      ;convert a json file into an ahk object
;json.objToJsonFile(obj,fileFullPath)  ;convert an ahk object into a json file
;
; ==> indicates a name change from the original code
;
;json.stringify(obj)	;convert an object into a json string.    [used to be objToJson(obj)]
;json.parse(jsonStr)	;convert a json string into an ahk object [used to be jsonToObj(jsonStr)]
;
;EXAMPLE
;json := new Json("  ", "`r`n") ;use 2 space indentation and CR LF for new lines
;testObject := {"key":"","key2":"val2",keyWithoutQuotes:"val3","myArray":["a1","a2","a3",{"myEdgeCase":"edge case ""test""","numberValue":2}]}
;MsgBox % json.stringify(testObject)
;----
;OUT
;----
;{
;  "key": "", 
;  "key2": "val2", 
;  "keyWithoutQuotes": "val3", 
;  "myArray": [
;    "a1", 
;    "a2", 
;    "a3", 
;    {
;      "myEdgeCase": "edge case \"test\"", 
;      "numberValue": 2
;    }
;  ]
;}

class Json {
    __New(indent="    ",newLine="`r`n") { ;default indent: 4 spaces. default newline: crlf
        this.ind := indent
        this.nl := newLine
    }

    getIndents(num) {
        indents := ""
        Loop % num
            indents .= this.ind
        Return indents
    }

    jsonFileToObj(fileFullPath) {
        file := FileOpen(fileFullPath, "r")
        Return this.parse(file.Read()), file.Close()
    }

    objToJsonFile(obj,fileFullPath) {
        FileDelete, % fileFullPath
        SplitPath, fileFullPath,, dir
        FileCreateDir % dir
        file := FileOpen(fileFullPath, "w")
        Return file.write(this.stringify(obj)), file.Close()
    }

    stringify(obj,indNum:=0) {
        indNum++
        str := "" , array := true
        for k in obj {
            if (k == A_Index)
                continue
            array := false
            break
        }
        for a, b in obj
            str .= this.getIndents(indNum) . (array ? "" : """" a """: ") . (IsObject(b) ? this.stringify(b,indNum) : this.isNumber(b) ? b : """" StrReplace(b,"""","\""") """") . ", " this.nl
        str := RTrim(str, " ," this.nl)
        return (array ? "[" this.nl str this.nl this.getIndents(indNum-1) "]" : "{" this.nl str this.nl this.getIndents(indNum-1) "}")
    }

    parse(jsonStr) {
        SC := ComObjCreate("ScriptControl") 
        SC.Language := "JScript"
        ComObjError(false)
        jsCode =
        (
        function arrangeForAhkTraversing(obj) {
            if(obj instanceof Array) {
                for(var i=0 ; i<obj.length ; ++i)
                    obj[i] = arrangeForAhkTraversing(obj[i]) ;
                return ['array',obj] ;
            } else if(obj instanceof Object) {
                var keys = [], values = [] ;
                for(var key in obj) {
                    keys.push(key) ;
                    values.push(arrangeForAhkTraversing(obj[key])) ;
                }
                return ['object',[keys,values]] ;
            } else
                return [typeof obj,obj] ;
        }
        )
        SC.ExecuteStatement(jsCode "; obj=" jsonStr)
        return this.convertJScriptObjToAhkObj( SC.Eval("arrangeForAhkTraversing(obj)") )
    }

    convertJScriptObjToAhkObj(jsObj) {
        if(jsObj[0]="object") {
            obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
            loop % keys.length
                obj[keys[A_INDEX-1]] := this.convertJScriptObjToAhkObj( values[A_INDEX-1] )
            return obj
        } else if(jsObj[0]="array") {
            array := []
            loop % jsObj[1].length
                array.insert(this.convertJScriptObjToAhkObj( jsObj[1][A_INDEX-1] ))
            return array
        } else
            return jsObj[1]
    }

    isNumber(Num) {
        if Num is number
            return true
        else
            return false
    }
}