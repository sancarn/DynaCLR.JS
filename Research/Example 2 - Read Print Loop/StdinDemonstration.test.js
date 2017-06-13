const spawn = require('child_process').spawn
var childx = spawn('StdinDemonstration.exe')
//var read1 = stdout.read().toString('ascii')
childx.stdout.on('data',function(data){console.log(data.toString('ascii'))})
childx.stdin.write('Oh my god...\n')
childx.stdin.write('Look at her butt!\n')
childx.stdin.write('It\'s so big...\n')
childx.stdin.write('I\n')
childx.stdin.write('LIKE\n')
childx.stdin.write('BIG\n')
childx.stdin.write('BUTTS\n')
childx.stdin.write('AND\n')
childx.stdin.write('I\n')
childx.stdin.write('CANNOT\n')
childx.stdin.write('LIE!\n')

...


childx.kill()