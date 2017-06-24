#NoTrayIcon
#include Libs\CLR.ahk
#include Libs\JSON.ahk

;How to execute AHK as console application:
;http://autohotkey.com/board/topic/52576-ahk-l-output-to-command-line/?p=372590
;#############################################################
;
; COMMAND LIST
;
;	StringInject <newLinePlaceHolder> <injectedString...>
;	StringReturn <pointer>
;	CLR_LoadLibrary <AssemblyName> <AppDomainPtr>
;	CLR_CreateObject <Assembly> <TypeName> <Args<JSONParsed array>>
;	CLR_CompileAssembly <CodePtr> <References> <ProviderAssembly> <ProviderType> <AppDomainPtr> <FileNamePtr> <CompilerOptions>
;	AppDomain_New <AppDomain> <BaseDirPtr>
;	AppDomain_Drop <AppDomainPtr>
;	CLR_Execute <ObjPtr> <FuncName> <Args<JSONParsed array>>
;	CLR_GetProperty <ObjPtr> <Property>
;	CLR_SetProperty <ObjPtr> <Property> <Value<JSONParsed>>


Global LoadedAssemblies		:= []		;These can be made with CLR_Compile and CLR_LoadLibrary
Global ExecutableObjects    := []		;These can be made with CLR_CreateObject
Global StoredStrings    	:= []		;These can be made with InjectString
Global AppDomains			:= []		;These can be made with AppDomain_New and dereferenced with AppDomain_Drop

;Type info:
;	s as string
Wrapper_InjectString(s){
	StoredStrings.push(s)
	return StoredStrings.length()
}

;Type info:
;	AssemblyName as string, AppDomain as integer
Wrapper_CLR_LoadLibrary(AssemblyName, AppDomain=0){
	LoadedAssemblies.push(CLR_LoadLibrary(AssemblyName, AppDomain))
	return LoadedAssemblies.length()
}

;Type info:
;	Assembly as LoadedAssembliesID, TypeName as string, args as array
Wrapper_CLR_CreateObject(Assembly, TypeName, Args){
	ExecutableObjects.push(CLR_CreateObject(Assembly, TypeName, Args*))
	return ExecutableObjects.length()
}

;Type info:
;	Code as StoredStringID, References as String, ProviderAssembly as string, ProviderType as string,
;	AppDomain as integer, FileName as string, CompilerOptions as string
Wrapper_CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, AppDomain=0, FileName="", CompilerOptions=""){
	LoadedAssemblies.push(CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, AppDomain, FileName, CompilerOptions))
	return LoadedAssemblies.length()
}

;Type info:
;	domain as integer?, sBaseDir as string
Wrapper_AppDomain_New(domain,sBaseDir=""){
	AppDomains.push(domain,sBaseDir)
	domainID := AppDomains.length
	CLR_StartDomain(AppDomains[domainID],sBaseDir)
	return domainID
}

;Type info:
;	domainPtr as integer
Wrapper_AppDomain_Drop(domainPtr){
	if(domainPtr=0){
		stderr:=FileOpen("**","w `n")
		stderr.Write("Error: Domain pointer must not be 0 or undefined.")
		stderr.Read(0)
		return
	}
	
	CLR_StopDomain(AppDomains[domainPtr])
	AppDomains[domainPtr] := 0
}

;CLR_StartDomain(ByRef AppDomain, BaseDirectory="")
;CLR_StopDomain(ByRef AppDomain)
;CLR_Start(Version="")	;Only required if you need to load a specific version.

;Stdin, stdout and stderr are file objects!
stdin  := FileOpen("*", "r `n")  ; Requires v1.1.17+
stdout := FileOpen("*", "w `n")
stderr := FileOpen("**","w `n")
stdout.Write("Ready for input.")	;Note Write is used instead of WriteLine, since WriteLine appends a \r\n onto the end of the string.
stdout.Read(0) ; Flush the write buffer.

while true
{
	cmdin := RTrim(stdin.ReadLine(), "`n")
	if(cmdin <> ""){
		if(cmdin="i)Exit"){
			stdout.Write("Exitting...")
			stdout.Read(0) ; Flush the write buffer.
			ExitApp
		} else {
			;parse cmdin 
			;stdout.Write("You wrote '" cmdin "'.")
			;stdout.Read(0) ; Flush the write buffer.
			
			;Syntax:    <command> <rest...>
			;1. Get command word
			Query := "^([^ ]+)"
			RegexMatch(cmdin,Query,Match)
			if(Match1~="i)StringInject"){
				;syntax:    StringInject <newLinePlaceHolder> <injectedString...>
				;note: newLinePlaceHolder must not contain any white space!!
				args := getArgs(cmdin,2) ;First 2 arguments are bound as single words
				str  := getRest(cmdin,2) ;2 arguments expected, rest optional
				CrLf := args[2]
				out := Wrapper_InjectString(StrReplace(str, CrLf, "`r`n"))
				stdout.Write(out)
				stdout.Read(0) ; Flush the write buffer.
				
			}else if (Match1~="i)StringReturn"){
				;Used for debugging as most of this is invisible.
				;syntax:		StringReturn <pointer>
				;description:	Returns a string from a location in memory, indicated by <pointer>
				args := getArgs(cmdin,2)
				stdout.Write(JSON_Stringify(StoredStrings[args[2]]))
				stdout.Read(0) ; Flush the write buffer.
				
			} else if(Match1~="i)CLR_LoadLibrary"){
				;syntax:		CLR_LoadLibrary <AssemblyName> <AppDomainPtr>
				;description:	Returns a pointer to a loaded assembly.
				args := getArgs(cmdin,3)
				domain := args[3] ? AppDomains[args[3]] : 0
				stdout.Write(Wrapper_CLR_LoadLibrary(args[2],domain))
				stdout.Read(0)
				
			} else if(Match1~="i)CLR_CreateObject"){
				;syntax:		CLR_CreateObject <Assembly> <TypeName> <Args*>
				;description:	returns a pointer to an executable object
				;Args* is an array strinfified using JSON.stringify(array). E.G. [1,"2",{"3":"4"},[5,6]]
				;These arguments are passed to the objects constructor.
				args			:= getArgs(cmdin,3)
				Assembly		:= LoadedAssemblies[args[2]]
				TypeName		:= args[3]
				Args			:= JSON_Parse(getRest(cmdin,3))
				
				stdout.Write(Wrapper_CLR_CreateObject(Assembly, TypeName, Args))
				stdout.Read(0)
				
			} else if(Match1~="i)CLR_CompileAssembly"){
				;syntax:		CLR_CompileAssembly <CodePtr> <References> <ProviderAssembly> <ProviderType> <AppDomainPtr> <FileNamePtr> <CompilerOptions>
				;description:	returns a pointer to a loaded assembly which is created from compiled CLR code.
				args := getArgs(cmdin,8)
				CodePtr			  := args[2]
				References		  := args[3]
				ProviderAssembly  := args[4]
				ProviderType	  := args[5]
				AppDomainPtr	  := args[6]
				FileNamePtr		  := args[7]
				CompilerOptions	  := args[8]
				
				;Process arguments
				sCode := StoredStrings[CodePtr]
				domain := AppDomainPtr ? AppDomains[AppDomainPtr] : 0
				FileName := StoredStrings[FileNamePtr]
				ret := Wrapper_CLR_CompileAssembly(sCode, References, ProviderAssembly, ProviderType, domain, FileName, CompilerOptions)
				stdout.Write(ret)
				stdout.Read(0)
				
			} else if(Match1~="i)AppDomain_New"){
				;syntax:		AppDomain_New <AppDomain> <BaseDirPtr>
				;description:	returns a pointer to a (running/loaded?) appdomain.
				args := getArgs(cmdin,3)
				domain		:= args[2]
				BaseDirPtr	:= args[3]
				
				;Precess arguments
				sBaseDir	:= StoredStrings[BaseDirPtr]
				ret := Wrapper_AppDomain_New(domain,sBaseDir)
				stdout.Write(ret)
				stdout.Read(0)
				
			} else if(Match1~="i)AppDomain_Drop"){
				;syntax:		AppDomain_Drop <AppDomainPtr>
				;description:	drops a running 
				args:= getArgs(cmdin,2)
				domainPtr	:= args[2]
				Wrapper_AppDomain_Drop(domainPtr)
			} else if(Match1~="i)CLR_Execute"){
				;syntax:			Execute <ObjPtr> <FuncName> <Args*>
				;Args* is an array strinfified using JSON.stringify(array). E.G. [1,"2",{"3":"4"},[5,6]]
				;These arguments are the arguments passed to the C#/VB object on execution.
				args := getArgs(cmdin,3)
				ObjPtr		:= args[2]
				FuncName	:= args[3]
				theArgs		:= JSON_Parse(getRest(cmdin,3))
				
				;Process arguments
				theObj := ExecutableObjects[ObjPtr]
				ret := execObjMember(theObj,FuncName,theArgs ? theArgs : [])
				if(ComObjType(ret)&& 0x2000){ ;SAFEARRAY
					_ret := ret, ret := []
					for key in _ret
						ret.push(key)
				} else if (ComObjType(ret)=9 && DeclaredType){	;COM Object
					if parseAs =
						parseAs = Object
					ret := getCOMObject(ret,DeclaredType,parseAs)
				}
				stdout.Write(JSON_Stringify(ret ? ret : "true"))
				stdout.Read(0)
			} else if(Match1~="i)CLR_GetProperty"){
				;syntax:			CLR_GetProperty <ObjPtr> <Property>
				;description:		Get a property from a CLR object.
				args := getArgs(cmdin,3)
				ObjPtr		:= args[2]
				property	:= args[3]
				
				;Process args
				theObj := ExecutableObjects[ObjPtr]
				stdout.Write(JSON_Stringify(getProperty(theObj,property)))
				stdout.Read(0)
			} else if(Match1~="i)CLR_SetProperty"){
				;syntax:		CLR_SetProperty <ObjPtr> <Property> <Value>
				;description:	Set a property of a CLR object to a particular Value.
				args := getArgs(cmdin,4)
				ObjPtr		:= args[2]
				property	:= args[3]
				value		:= JSON_Parse(args[4])
				
				;Process args
				theObj := ExecutableObjects[ObjPtr]
				e=
				setProperty(theObj,property,value,e)
				if(e=""){
					stdout.Write("true")
					stdout.Read(0)
				} else {
					stdout.Write("false")
					stdout.Read(0)
					
					stderr.WriteLine(e)
					stderr.Read(0)
				}
			} else if(Match1 ~= "i)CLR_DeclareReturnType"){
				;Syntax:		CLR_DeclareReturnType <type> <parseAs> <args*>
				args := getArgs(cmdin,3)
				DeclaredType	:= args[2]
				parseAs			:= args[3]
			}
		}
	}
	;sleep,50
}

;#########################
;# GET ARGS AND GET REST #
;#########################
;Special functions for parsing arguments supplied to DynaCLR.exe
;getArgs - Gets all expected arguments from the passed in command.
;getRest - Gets the entire string after the expected arguments. These can be optional arguments (which can be re-parsed with getArgs)
;  or, in the case of InjectString, an entire string.
getArgs(cmdin,expectedArgs){
	;Parses a string, delimeter = " ", creates an array of input arguments from STDInput passed to DynaCLR
	retArgs := []
	Loop, parse, cmdin, %A_Space%
	{
		retArgs.push(A_LoopField)
		if(A_Index=expectedArgs){
			break
		}
	}
	return retArgs
}
getRest(cmdin,expectedArgs){
	curPos:=0
	Loop, parse, cmdin, %A_Space%
	{
		if(A_Index = expectedArgs +1){
			break
		}
		curPos += StrLen(A_LoopField)+1
	}
	return SubStr(cmdin,curPos+1)
}

execObjMember(ByRef obj,theFunc,theArgs){
	return obj[theFunc](theArgs*)
}

getProperty(ByRef obj,property){
	return obj[property]
}

setProperty(ByRef obj,property, value, ByRef errors){
	try {
		obj[property] := value
	} catch e {
		errors := e
	}
}

JSON_Parse(orgs){
	return JSON.parse(orgs)
}

JSON_Stringify(x){
	;msgbox, % x
	;msgbox % JSON.stringify(x)
	return JSON.stringify(x)
}

type(v) {
    if IsObject(v)
        return "Object"
	return v="" || [v].GetCapacity(1) ? "String" : "Number"
}

findIID(name){
	Loop, Reg, HKEY_CLASSES_ROOT\Interface\, KV
	{
		RegRead, interface, HKEY_CLASSES_ROOT\Interface\%A_LoopRegName%
		if (interface = name)
			return A_LoopRegName		
	}
}

getCOMObject(obj,DeclaredType,parser="Object"){
	loop, % DeclaredType
	{
		obj := ComObject(ComObjType(obj), ComObjQuery(obj, DeclarationPathType="Direct" ? DeclaredType[A_Index] : findIID(DeclaredType[A_Index])), 1)
	}
	if(parser="Array"){	;Array of keys: [1,2,3,4]
		ret := []
		for k in obj
			ret.push(k)
	} else if(parser="Object"){	;A collection of Key-Value pairs
		ret := {}
		for k,v in obj
			ret[k] := v
	} else if(parser="Pointer"){
		ExecutableObjects.push(obj)
		ret := ExecutableObjects.length()
	} else if(parser="RegisteredObject"){
		;ToDo:
		;	Register obj as com object and return CLSID (CLSID is randomly generated)
	} else if(parser="FullObject") {
		;ToDo
		;	return key-value object with an array of methods with pointers to callable functins __methods = [...]
	}
	
	return ret
}

;JAVASCRIPT ARGUMENT CREATION:
;var passMeArguments = function(){
;    return JSON.stringify(arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments))
;}


