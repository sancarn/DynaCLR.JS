; Open a console window for this demonstration:
DllCall("AllocConsole")
; Open the application's stdin/stdout streams in newline-translated mode.
stdin  := FileOpen("*", "r `n")  ; Requires v1.1.17+
stdout := FileOpen("*", "w `n")
; For older versions:
;   stdin  := FileOpen(DllCall("GetStdHandle", "int", -10, "ptr"), "h `n")
;   stdout := FileOpen(DllCall("GetStdHandle", "int", -11, "ptr"), "h `n")
stdout.Write("Write to stdin.`n\> ")
stdout.Read(0) ; Flush the write buffer.

while true
{
	query := RTrim(stdin.ReadLine(), "`n")
	if(query <> ""){
		stdout.WriteLine("You wrote '" query "'.")
		stdout.Read(0) ; Flush the write buffer.
	}
	sleep,250
}