const spawn = require('child_process').spawn
var childx = spawn('StdinDemonstration.exe')
//var read1 = stdout.read().toString('ascii')
childx.stdout.on('data',function(data){console.log(data.toString('ascii'))})
childx.stdin.write('awesome!\n')


...


childx.kill()