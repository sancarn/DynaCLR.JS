/* Example 1 - Dealing with strings */
/**
 * Strings are an important part of this library. All code created will be given in string form,
 * all file paths and code providers etc. will also be passed into the engine via strings.
 * 
 * However, some strings may be arbitrarily long. And may also include symbols which the DynaCLR.exe
 * would use to determine which character is 'the next argument'. To avoid unnecessary escaping
 * a string injection system has been implemented.
 *
 * With this system, when long or potentially dangerous strings are required to be used in DynaCLR.exe
 * it is often required to inject the string first. The injected string will return a pointer to
 * the position of the string in DynaCLR.exe's memory.
 *
 * If you want to see if your string has been transmitted correctly you can return the string back to
 * NodeJS.
 *
 * To inject a string you can use the following syntax:
 *
 *		StringInject(<My string to send!> [,<My new-line placeholder (default = "__CLR-CrLf__")>])
 *
 * To return a string use the following syntax.
 *
 *		StringReturn(<My string pointer>)
 *
 * In this example we create 3 strings, return them and then print them out once all commands have been executed.
 */
 
const CLR = require('DynaCLR').new()
S_ptr_1 = CLR.StringInject("Hello world!");
S_ptr_2 = CLR.StringInject("Hello world!\nMy name is Sancarn!");
S_ptr_3 = CLR.StringInject("Mary had a little lamb;And it's name was Doug!",";");
S1 = CLR.StringReturn(S_ptr_1);
S2 = CLR.StringReturn(S_ptr_2);
S3 = CLR.StringReturn(S_ptr_3);
CLR.Finally(function(){
	console.log("S1:\n" + S1.value + "\n-------------------")
	console.log("S2:\n" + S2.value + "\n-------------------")
	console.log("S3:\n" + S3.value + "\n-------------------")
});

