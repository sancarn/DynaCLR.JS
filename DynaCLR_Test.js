var spawn = require('child_process').spawn
var childx = spawn('DynaCLR.exe')
childx.stdout.once('data',function(data){
	childx.stdout.read() //flush stdout
	childx.stdin.write('stringinject ; Once upon a time, in a land far far away;lived a princess who sewed a long dress.\n')
	childx.stdout.once('data',function(data){
		childx.stdout.read() //flush stdout
		childx.stdout.once('data',function(data){
			console.log('String Returned:\n' + data.toString('ascii') + '\n')	
			childx.kill()
		})
		childx.stdin.write('stringreturn ' + data.toString('ascii') + '\n')
	})
})
