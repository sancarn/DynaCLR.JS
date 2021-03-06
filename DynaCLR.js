class Pointer {
	constructor(){
		this.value = undefined
		//this.type = "ptr"
	}
}

class CLR_Events extends Array {
	constructor(CLR){
		super()
		this.CLR = CLR
		this.isRunning = false
	}
	runAll(){
		this.isRunning = true
		if(this.length>0){
			//Contribution by le_m: https://stackoverflow.com/a/44447739/6302131. See Contrib#1
			var CLREvents = this
			this.shift().run(function(){
				CLREvents.runAll.bind(CLREvents)()
				if (!(CLREvents.length>0))  CLREvents.isRunning = false
			})
		}
	}
	new(cmd,args,ret){
		//If events array is initially empty, a run is required
		var requireRun = !(this.length>0)
		
		var e = new CLR_Event(cmd,args,ret,this.CLR)
		this.push(e)
		if(!this.isRunning && this.CLR.isReady){
			this.runAll()
		}
	}
}

class CLR_Event {
	constructor(cmd,args,ret,CLR){
		this.command = cmd;
		this.args = args
		this.CLR = CLR
		this.proc = CLR.CLRProcess;
		this.ptr = ret
	}
	
	run(callback){
		//Implementing event to execute callback after some other events have been created.
		if(this.command == "Finally"){
			this.args[0]()
			return callback(null)
		}
		
		//Implementation for all CLR events.
		var thisEvent = this
		this.proc.stdout.once('data',function(data){
			this.read()
			data = JSON.parse(data.toString())
			thisEvent.ptr.value = data
			callback(data);
		})
		this.proc.stdin.write(this.command + " " + this._getArgValues(this.args).join(" ") + "\n");
	}
	_getArgValues(args){
		var newArgs = []
		this.args.forEach(
			function(arg){
				if(arg==undefined){
					newArgs.push('')
				} else {
					if(arg.constructor.name=='Pointer'){
						if(typeof arg.value == "object"){
							newArgs.push(JSON.stringify(arg.value))
						} else {
							newArgs.push(arg.value)
						}
					} else if(typeof arg == "object"){
						newArgs.push(JSON.stringify(arg))
					} else {
						newArgs.push(arg)
					}
				}
			}
		)
		return newArgs	
	}
}

var CLR = {}
CLR.isReady = false
CLR.CLRProcess = require('child_process').spawn(require('path').resolve(__dirname,'DynaCLR.exe'))
CLR.CLRProcess.stdout.once('data',function(data){
	if(data!="Ready for input."){
		CLR.CLRProcess.kill()
		CLR = undefined
		throw new Error("Cannot create CLR process")
	} else {
		//isReady determines the run state of new events.
		CLR.isReady = true
		
		//Call event.
		CLR.onceReady()

		//Process all currently setup data.
		if(CLR.Events.length>0){
			CLR.Events.runAll()
		}
	}
})
CLR.Events = new CLR_Events(CLR)

//UDFs

CLR.StringInject = function(str,CrLf="__CLR-CrLf__"){
	var pRet = new Pointer
	this.Events.new("StringInject",[CrLf,str.replace(/\n/g,CrLf)],pRet) //Note CLR.exe requires arguments to be the other way round -- easier command line passing
	return pRet
}
CLR.StringReturn = function(ptr){
	var pRet = new Pointer
	this.Events.new("StringReturn",[ptr],pRet)
	return pRet
}
CLR.StringGetPtr = function(v,argOptional,defaultValue){
	//If v is a previously injected string pointer then return v
	//If v is a string then return CLR.StringInject(v)
	//If argument is optional return pointer with value = defaultValue (if available) else with value=0
	//Else if argument is not optional (or if argOptional = undefined) throw error
	
	//CASE: StringGetPtr(k=(new Pointer))
	if (typeof v == 'object' && v.constructor.name == 'Pointer'){
		return v
	//CASE: StringGetPtr("my string")
	} else if(v != undefined && v.constructor.name == "String") {
		return this.StringInject(v)
	//CASE: StringGetPtr()
	}  else if(!argOptional) {
		throw Error("Invalid parameter input type.")
	//CASE: StringGetPtr(,true) AND StringGetPtr(,true,"myDefaultValue")
	} else {
		vPtr = new Pointer
		vPtr.value = defaultValue != undefined ? defaultValue : 0
	}
}

CLR.LoadLibrary = function(AssemblyName, AppDomain){
	var pRet = new Pointer
	var AppDomainPtr = AppDomain ? AppDomain : 0
	this.Events.new("CLR_LoadLibrary",[AssemblyName, AppDomainPtr],pRet)
	return pRet
}

CLR.CreateObject = function(Assembly, TypeName, ArgsArr){
	var pRet = new Pointer
	this.Events.new("CLR_CreateObject",[Assembly, TypeName,JSON.stringify(ArgsArr)],pRet)
	return pRet
}

CLR.CompileAssembly = function(vCode, References, ProviderAssembly, ProviderType, AppDomain, vFileName, CompilerOptions){
	var pRet = new Pointer
	var CodePtr = this.StringGetPtr(vCode)
	var AppDomainPtr = AppDomain ? AppDomain : 0
	var FileNamePtr = this.StringGetPtr(vFileName, true)
	CompilerOptions = CompilerOptions ? CompilerOptions : ""
	
	this.Events.new("CLR_CompileAssembly",[CodePtr, typeof References == "object" ? References.join("|") : References, ProviderAssembly, ProviderType, AppDomainPtr, FileNamePtr, CompilerOptions],pRet)
	return pRet
}

CLR.Execute = function( ObjPtr, FuncName, ArgsArr){
	var pRet = new Pointer
	this.Events.new("CLR_Execute",[ObjPtr, FuncName, JSON.stringify(ArgsArr)],pRet)
	return pRet
}

CLR.GetProperty = function( ObjPtr, Property){
	var pRet = new Pointer
	this.Events.new("CLR_GetProperty",[ObjPtr, Property],pRet)
	return pRet
}

CLR.SetProperty = function( ObjPtr, Property, Value){
	var pRet = new Pointer
	this.Events.new("CLR_SetProperty",[ObjPtr,Property,JSON.stringify(Value)],pRet)
	return pRet
}

CLR.AppDomain = {}
CLR.AppDomain.New = function(iAppDomain, BaseDir){
	var pRet = new Pointer
	var AppDomain = iAppDomain ? iAppDomain : 0
	var BaseDirPtr = this.StringGetPtr(BaseDir)
	this.Events.new("AppDomain_New",[AppDomain,BaseDirPtr],pRet)
	return pRet
}

CLR.AppDomain.Drop = function(AppDomainPtr){
	var pRet = new Pointer
	if (AppDomainPtr.constructor.name == "Pointer"){
		this.Events.new("AppDomain_Drop",[AppDomainPtr],pRet)
		return pRet
	} else {
		throw new Error("AppDomain must be passed by reference to the Drop function.")
	}
}

CLR.Finally = function(callback){
	this.Events.new("Finally",[callback])
}

CLR.onceReady = function(){
	console.log('CLR is ready for input...\n')
}