a:=[[1,2,3],1,2]
wrappy(a)


wrappy(a){
	funky(a*)
}

funky(a,b,c){
	Loop, % a.length()
	{
		msgbox, % a[A_Index]
	}
	msgbox, b: %b%`nc: %c%
}