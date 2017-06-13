/*
syntax:		StringInject <newLinePlaceHolder> <injectedString...>
syntax:		StringReturn <pointer>
syntax:		CLR_LoadLibrary <AssemblyName> <AppDomainPtr>
syntax:		CLR_CreateObject <AssemblyPtr> <TypeName> <Args*>
syntax:		CLR_CompileAssembly <CodePtr> <References> <ProviderAssembly> <ProviderType> <AppDomainPtr> <FileNamePtr> <CompilerOptions>
syntax:		AppDomain_New <AppDomain> <BaseDirPtr>
syntax:		AppDomain_Drop <AppDomainPtr>
syntax:		Execute <ObjPtr> <FuncName> <Args*>
*/


var childx = require('child_process').spawn('DynaCLR.exe')
var vb = String.raw`
    Imports System.Windows.Forms
    Class Foo
		Public Const IsAlive As String = "I am indeed alive"
        Public Sub Test()
            MessageBox.Show("Hello, world, from VB!")
        End Sub
    End Class`

var references	= ["System.dll","System.Windows.Forms.dll"]
var classToTest	= "Foo"
var  funcToTest	= "Test"

function getCommand(arr){
	return arr.join(" ") + "\n"
}

childx.stdout.once('data',function(str){
	if(str.toString()=='Ready for input.'){
		console.log('ready')
		//Step 1. Store code as string and wait for code pointer
		childx.stdout.once('data',function(vbCode){
			vbCode = vbCode.toString()
			console.log(`vbCode:"${vbCode}"`)
			//Step 2. Compile VB into Assembly
			childx.stdout.once('data', function(asm){
				asm = asm.toString()
				console.log(`asm:"${asm}"`)
				//Step 3. Create object from assembly.
				childx.stdout.once('data',function(obj){
					obj=obj.toString()
					console.log(`obj:"${obj}"`)
					//Step 4. Execute function of stored object.
					childx.stdout.once('data',function(msg){
						msg=msg.toString()
						console.log(`msg:"${msg}"`)
						if(msg=='true'){
							console.log('Execution Success!')
						}
						childx.stdin.write(getCommand(["Exit"]))
						childx.kill()
					})
					childx.stdin.write(getCommand(["CLR_Execute",obj,funcToTest]))
				})
				childx.stdin.write(getCommand(["CLR_CreateObject",asm,classToTest]))
			})
			childx.stdin.write(getCommand(["CLR_CompileAssembly",vbCode,references.join("|"),"System","Microsoft.VisualBasic.VBCodeProvider",0,""]))
		})
	}
	childx.stdin.write(getCommand(["StringInject","__vbCrLf__",vb.replace(/\n/g,"__vbCrLf__")]))
})


// What we desire:
/*
vbCode	= CLR.StringInject(vb,"__vbCrLf__")
asm		= CLR.CompileAssembly(vbCode, references, "System", "Microsoft.VisualBasic.VBCodeProvider",0,"")
obj		= CLR.CreateObject(asm,"Foo")
CLR.Execute(obj,"Test")
CLR.Exit()
*/

//AHK:
//asm := CLR_CompileVB(vb, "System.dll | System.Windows.Forms.dll")
//obj := CLR_CreateObject(asm, "Foo")
//obj.Test()

/*
//Testing
childx.stdout.on('data',function(s){console.log(s.toString())})
childx.stdin.write(getCommand(["StringInject","__vbCrLf__",vb.replace(/\n/g,"__vbCrLf__")]))
childx.stdin.write(getCommand(["CLR_CompileAssembly",1,references.join("|"),"System","Microsoft.VisualBasic.VBCodeProvider",0,""]))
childx.stdin.write(getCommand(["CLR_CreateObject",1,classToTest]))
childx.stdin.write(getCommand(["CLR_Execute",1,funcToTest]))
*/
