# DynaCLR.JS

A dynamic and portable CLRCompiler allowing you to run C#.NET and VB.NET code in NodeJS in-process.

This project aims to be 'as good as' Edge.JS but with increased portability. It should also be less frustrating to setup as it doesn't require node-gyp.

Requirements:
* Windows OS
* Microsoft Common Language Runtime (CLR):
 _CLR should be available on all computers with an operating system of Windows Vista? onwards. However it is supported for all: Windows 98, ME, NT 4.0, 2000, XP, and Server 2003_

The project is split into 2 halves.

## The AHK Side

The AHK code which is located in the base directory including all libraries in `Libs/`. The AHK code is then compiled into an executable `DynaCLR.exe`. This is the only component which is required for executing VB/C#.NET code and follows the [STDIO API](STDIO_API.MD). With this code VB/C#.NET code can be compiled and ran from any language which supports writing to STDIN and reading from STDOUT.

## The NodeJS Side

The NodeJS code which is required for the execution of the [NodeJS API](JS/NodeJS_API.MD). This is a wrapper around the AHK Side allowing users to easily execute VB/C#.NET code in-process using NodeJS.

## Special Thanks

Lexicos for the continued developement of Autohotkey and the creation of [CLR.AHK](https://autohotkey.com/boards/viewtopic.php?f=6&t=4633&hilit=CLR.AHK). This project would not have been so easy for me to create if it weren't for CLR.AHK doing most of the work for me. All that was required is a STDIO wrapper around base functionality already existent in CLR.AHK.
