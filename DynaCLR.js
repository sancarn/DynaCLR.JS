/*
	Contrib#1:{
		Question:{
			Consider the following class:
				class TimerFunk {
					constructor(someObject){
						this.a = 1
						this.someObject = someObject
					}
					funk(){
						console.log(this.a)
						if(this.a > 2){
							return
						}
						this.a++
						this.someObject.execCallback(this.funk)
					}
				}
			
			When the following commands are executed:
			
				t = new TimerFunk({execCallback:function(callback){callback()}})
				t.funk()
			
			it is intended that the following data is logged:
				0
				1
				2
				3
			instead this data is logged:
				VM2097:9 1
				VM2097:9 Uncaught TypeError: Cannot read property 'a' of undefined
					at funk (<anonymous>:9:25)
					at Object.execCallback (<anonymous>:5:13)
					at TimerFunk.funk (<anonymous>:13:25)
					at <anonymous>:1:3

			From debugging I have figured out that this is because on the first loop this represents the object t however, on the 2nd loop this represents someObject.
			Is there any way I can fix this and allow me to access class properties from within the executed callback?
		} answer {
			Your callback is called without the TimerFunk instance t as the this object:
				function(callback){callback()}}
				
			A solution is to bind the this object of the callback to the TimerFunk instance:
				funk() {
				  ...
				  this.someObject.execCallback(this.funk.bind(this));
				}
				
			Alternatively, you can explicitly pass t as the this object via callback.call(t):
				t = new TimerFunk({execCallback:function(callback){callback.call(t)}});	
		}
	}
*/

class Pointer {
	constructor(){
		this.value = undefined
		this.type = "ptr"
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
		if(!this.isRunning){
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
				if(arg.type=='ptr'){
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
		)
		return newArgs	
	}
}

var CLR = {}
CLR.CLRProcess = require('child_process').spawn('DynaCLR.exe')
CLR.CLRProcess.stdout.once('data',function(data){
	if(data!="Ready for input."){
		CLR.CLRProcess.kill()
		CLR = undefined
		throw new Error("Cannot create CLR process")
	} else {
		CLR.onceReady()
	}
})
CLR.Events = new CLR_Events(CLR)

//UDFs

CLR.StringInject = function(str,CrLf="__CLR-CrLf__"){
	var ptr = new Pointer
	this.Events.new("StringInject",[CrLf,str.replace(/\n/g,CrLf)],ptr) //Note CLR.exe requires arguments to be the other way round -- easier command line passing
	return ptr
}
CLR.StringReturn = function(ptr){
	var sRet = new Pointer
	this.Events.new("StringReturn",[ptr],sRet)
	return sRet
}

CLR.Finally = function(callback){
	this.Events.new("Finally",[callback])
}

CLR.onceReady = function(){
	console.log('CLR is ready for input...\n')
	/* Example 1 - Using String Inject */
	S_ptr_1 = CLR.StringInject("Hello world!");
	S_ptr_2 = CLR.StringInject("Hello world!\nMy name is Sancarn!");
	S_ptr_3 = CLR.StringInject("Mary had a little lamb;And it's name was Doug!",";");
	S1 = CLR.StringReturn(S_ptr_1)
	S2 = CLR.StringReturn(S_ptr_2)
	S3 = CLR.StringReturn(S_ptr_3)
	CLR.Finally(function(){
		console.log("S1:\n" + S1.value + "\n-------------------")
		console.log("S2:\n" + S2.value + "\n-------------------")
		console.log("S3:\n" + S3.value + "\n-------------------")
	});
}