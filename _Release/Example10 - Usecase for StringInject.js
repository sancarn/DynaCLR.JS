/* Example 2a - Simple VB.NET Example */
/**
 *  The Common Language Runtime (CLR) is an Execution Environment.
 * It works as an interface between Operating Systems and applications written in
 * .Net languages. CLR can therefore convert Managed code into Native code and then
 * execute the Program.
 *
 * In this example we demonstrate the compilation and execution of a basic VB.NET application.
 */
 
const CLR = require('DynaCLR').new()
code = `
Imports System.Windows.Forms
Class Foo
	Public Sub Test()
		MessageBox.Show("Hello, world, from VB!")
	End Sub
End Class
`

References = ["System.dll","System.Windows.Forms.dll"]
pCode 	=	CLR.StringInject(code)
asm 	=	CLR.CompileAssembly(pCode, References, "System", "Microsoft.VisualBasic.VBCodeProvider")
obj 	=	CLR.CreateObject(asm, "Foo")
status	=	CLR.Execute(obj,"Test")
CLR.Finally(function(){
	if (status.value=='true'){
		console.log("The application ran successfully")
	} else {
		console.log("The application didn't run successfully")
	}
});

