Class foo {
    bar(){
        msgbox, hello!
    }
}
theClass := "foo"
theFunc := "bar"
theArgs := []

%theClass%[theFunc](theArgs*)



;Putting this together we get:

execObjMember(theClass,theFunc,theArgs){
	%theClass%[theFunc](theArgs*)
}