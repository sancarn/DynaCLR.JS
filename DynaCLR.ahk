#include Libs\CLR.ahk

;How to execute AHK as console application:
;http://autohotkey.com/board/topic/52576-ahk-l-output-to-command-line/?p=372590
;#############################################################

Global LoadedAssemblies		:= []		;These can be made with CLR_Compile and CLR_LoadLibrary
Global ExecutableObjects    := []		;These can be made with CLR_CreateObject
Global StoredStrings    	:= []		;These can be made with InjectString
Global AppDomains			:= []		;These can be made with 

;Type info:
;	s as string
InjectString(s){
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
Wrapper_CLR_CreateObject(Assembly, TypeName, Args*){
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
		stderr.WriteLine("Error: Domain pointer must not be 0 or undefined.")
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
stdout.Write("Ready for input.")
stdout.Read(0) ; Flush the write buffer.

while true
{
	cmdin := RTrim(stdin.ReadLine(), "`n")
	if(cmdin <> ""){
		if(cmdin="i)Exit"){
			ExitApp
		} else {
			;parse cmdin 
			;stdout.WriteLine("You wrote '" cmdin "'.")
			;stdout.Read(0) ; Flush the write buffer.
			
			;Syntax:    <command> <rest...>
			;1. Get command word
			Query := "^([^ ]+)"
			RegexMatch(cmdin,Query,Match)
			if(Match1~="i)StringInject"){
				;syntax:    "StringInject <newLinePlaceHolder> <injectedString...>" 
				args := getArgs(cmdin,3)
				str  := getRest(cmdin,3)
				out := InjectString(StrReplace(str, args[2], "`r`n"))
				stdout.WriteLine(out)
				stdout.Read(0) ; Flush the write buffer.
				
			}else if (Match1~="i)StringReturn"){
				;Used for debugging as most of this is invisible.
				;syntax:		"StringReturn <pointer>"
				;description:	Returns a string from a location in memory, indicated by <pointer>
				args := getArgs(cmdin,2)
				stdout.WriteLine(StoredStrings[args[2]])
				stdout.Read(0) ; Flush the write buffer.
				
			} else if(Match1~="i)CLR_LoadLibrary"){
				;syntax:		"CLR_LoadLibrary <AssemblyName> <AppDomainPtr>"
				;description:	Returns a pointer to a loaded assembly.
				args := getArgs(cmdin,3)
				domain := args[3] ? AppDomains[args[3]] : 0
				stdout.WriteLine(Wrapper_CLR_LoadLibrary(args[2],domain))
				stdout.Read(0)
				
			} else if(Match1~="i)CLR_CreateObject"){
				;syntax:		"CLR_CreateObject Assembly TypeName Args*"
				;description:	returns a pointer to an executable object
				args := getArgs(cmdin,3)	;get stdin-arguments
				orgs := getRest(cmdin,3)	;get object-arguments (orgs)
				collection := []
				collection := parseCLRObjectArguments(orgs)
				stdout.WriteLine(Wrapper_CLR_CreateObject(args[2], args[3], collection*))
				stdout.Read(0)
				
			} else if(Match1~="i)CLR_CompileAssembly"){
				;syntax:		"CLR_CompileAssembly CodePtr References ProviderAssembly ProviderType AppDomainPtr FileNamePtr CompilerOptions"
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
				stdout.WriteLine(ret)
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
				stdout.WriteLine(ret)
				stdout.Read(0)
				
			} else if(Match1~="i)AppDomain_Drop"){
				;syntax:		AppDomain_Drop <AppDomainPtr>
				;description:	drops a running 
				args:= getArgs(cmdin,2)
				domainPtr	:= args[2]
				Wrapper_AppDomain_Drop(domainPtr)
			} else if(Match1~="i)Execute"){
			;syntax:			Execute <ObjPtr> <FuncName> <Args*>
				args := getArgs(cmdin,3)
				orgs := getRest(cmdin,3)
				ObjPtr		:= args[2]
				FuncName	:= args[3]
				theArgs		:= []
				theArgs		:= parseCLRObjectArguments(orgs)
				
				;Process arguments
				theObj := ExecutableObjects[ObjPtr]
				ret := execObjMember(theObj,theFunc,theArgs)
				stdout.WriteLine(ret ? ret : "true")
				stdout.Read(0)
			}
		}
	}
	sleep,250
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
		if(A_Index=expectedArgs){
			break
		}
		curPos += StrLen(A_LoopField)+1
	}
	return SubStr(cmdin,curPos+1)
}

execObjMember(theClass,theFunc,theArgs){
	return %theClass%[theFunc](theArgs*)
}