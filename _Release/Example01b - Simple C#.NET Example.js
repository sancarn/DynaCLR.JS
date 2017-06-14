/* Example 1b - Simple C#.NET Example */
/**
 *  The Common Language Runtime (CLR) is an Execution Environment.
 * It works as an interface between Operating Systems and applications written in
 * .Net languages. CLR can therefore convert Managed code into Native code and then
 * execute the Program.
 *
 * In this example we demonstrate the compilation and execution of a basic V#.NET application.
 */
 
const CLR = require('DynaCLR').new()
code = `
using System.Windows.Forms;
class Foo {
	public void Test() {
		MessageBox.Show("Hello, world, from C#!");
	}
}
`

References = ["System.dll","System.Windows.Forms.dll"]
asm 	=	CLR.CompileAssembly(code, References, "System", "Microsoft.CSharp.CSharpCodeProvider")
obj 	=	CLR.CreateObject(asm, "Foo")
status	=	CLR.Execute(obj,"Test")
CLR.Finally(function(){
	if (status.value=='true'){
		console.log("The application ran successfully")
	} else {
		console.log("The application didn't run successfully")
	}
});

