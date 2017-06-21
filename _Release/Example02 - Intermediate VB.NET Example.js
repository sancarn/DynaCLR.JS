/**
 * LESSONS LEARNT:
 * 1. Arrays passed from JavaScript to CLR are COM Objects (Safe Arrays?). They are NOT native .NET Arrays.
 * 2. Arrays passed to CLR have all the same methods as AHK. You access the arrays the same also. (obj(1),obj(2) ... for i = 1 to obj.length() ...)
 * 3. Native Arrays cannot be returned from CLR to AHK.
 * 4. Huge data strings cannot easily be passed from AHK to NodeJS due to the way STDOUT is read. For this reason it is better to dump the data to a temporary file and read the data out with require('fs').fileRead()
 */

function getFileIcons__testData(){
    var imagePaths =  ["C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\data"
                      ,"C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\DirectoryList.ahk"
                      ,"C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\Icon2.png"
                      ,"C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\README.md"
                      ,"C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\LICENSE"
                      ,"C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\main.js"
                      ,"C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\package.json"]
                        
                        
    var callback = function(data){
        console.log(data)
    }
    getFileIcons(imagePaths,callback)
}

function getFileIcons(imagePaths,callback){
    var iconSizes = {
        Large       : 0x0,    //32x32
        Small       : 0x1,    //16x16
        ExtraLarge  : 0x2,    //48x48
        Jumbo       : 0x4    //256x256
    }
    initGetImages(imagePaths,callback)    
    
    function initGetImages(images,callback){
        var vb=`
            Imports System
            Imports System.Runtime.InteropServices
            Imports System.Drawing
			
            Public Enum IconSize As Integer
            	Large = &H0 '32x32
            	Small = &H1 '16x16
            	ExtraLarge = &H2 '48x48
            	Jumbo = &H4 '256x256
            End Enum
            
            Public Class IconHelper
            	Private Const SHGFI_ICON As UInteger = &H100
            	Private Const SHGFI_LARGEICON As UInteger = &H0
            	Private Const SHGFI_SMALLICON As UInteger = &H1
            	Private Const SHGFI_USEFILEATTRIBUTES As UInteger = &H10
            	Private Const SHGFI_ICONLOCATION As UInteger = &H1000 'The name of the file containing the icon is copied to the szDisplayName member of the structure specified by psfi. The icon's index is copied to that structure's iIcon member.
            	Private Const SHGFI_SYSICONINDEX As UInteger = &H4000
            	Private Const SHIL_JUMBO As UInteger = &H4
            	Private Const SHIL_EXTRALARGE As UInteger = &H2
            	Private Const ILD_TRANSPARENT As UInteger = &H1
            	Private Const ILD_IMAGE As UInteger = &H20
            	Private Const FILE_ATTRIBUTE_NORMAL As UInteger = &H80
				
            	<DllImport("shell32.dll", EntryPoint:="#727")>
            	Private Shared Function SHGetImageList(ByVal iImageList As Integer, ByRef riid As Guid, ByRef ppv As IImageList) As Integer
            	End Function
				
            	<DllImport("shell32.dll", EntryPoint:="SHGetFileInfoW", CallingConvention:=CallingConvention.StdCall)>
            	Private Shared Function SHGetFileInfoW(<MarshalAs(UnmanagedType.LPWStr)> ByVal pszPath As String, ByVal dwFileAttributes As UInteger, ByRef psfi As SHFILEINFOW, ByVal cbFileInfo As Integer, ByVal uFlags As UInteger) As Integer
            	End Function
				
            	<DllImport("shell32.dll", EntryPoint:="SHGetFileInfoW", CallingConvention:=CallingConvention.StdCall)>
            	Private Shared Function SHGetFileInfoW(ByVal pszPath As IntPtr, ByVal dwFileAttributes As UInteger, ByRef psfi As SHFILEINFOW, ByVal cbFileInfo As Integer, ByVal uFlags As UInteger) As Integer
            	End Function
				
            	<DllImport("user32.dll", EntryPoint:="DestroyIcon")>
            	Private Shared Function DestroyIcon(ByVal hIcon As IntPtr) As <MarshalAs(UnmanagedType.Bool)> Boolean
            	End Function
				
            	<StructLayout(LayoutKind.Sequential)>
            	Private Structure RECT
            		Public left, top, right, bottom As Integer
            	End Structure
				
            	<StructLayout(LayoutKind.Sequential, CharSet:=CharSet.[Unicode])>
            	Private Structure SHFILEINFOW
            		Public hIcon As System.IntPtr
            		Public iIcon As Integer
            		Public dwAttributes As UInteger
            		<MarshalAs(UnmanagedType.ByValTStr, SizeConst:=260)> Public szDisplayName As String
            		<MarshalAs(UnmanagedType.ByValTStr, SizeConst:=80)> Public szTypeName As String
            	End Structure
				
            	<StructLayout(LayoutKind.Sequential)>
            	Private Structure IMAGELISTDRAWPARAMS
            		Public cbSize As Integer
            		Public himl As IntPtr
            		Public i As Integer
            		Public hdcDst As IntPtr
            		Public x As Integer
            		Public y As Integer
            		Public cx As Integer
            		Public cy As Integer
            		Public xBitmap As Integer
            		Public yBitmap As Integer
            		Public rgbBk As Integer
            		Public rgbFg As Integer
            		Public fStyle As Integer
            		Public dwRop As Integer
            		Public fState As Integer
            		Public Frame As Integer
            		Public crEffect As Integer
            	End Structure
				
            	<StructLayout(LayoutKind.Sequential)>
            	Private Structure IMAGEINFO
            		Public hbmImage As IntPtr
            		Public hbmMask As IntPtr
            		Public Unused1 As Integer
            		Public Unused2 As Integer
            		Public rcImage As RECT
            	End Structure
				
            	<ComImport(), Guid("46EB5926-582E-4017-9FDF-E8998DAA0950"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)>
            	Private Interface IImageList
            		<PreserveSig()> Function Add(ByVal hbmImage As IntPtr, ByVal hbmMask As IntPtr, ByRef pi As Integer) As Integer
            		<PreserveSig()> Function ReplaceIcon(ByVal i As Integer, ByVal hicon As IntPtr, ByRef pi As Integer) As Integer
            		<PreserveSig()> Function SetOverlayImage(ByVal iImage As Integer, ByVal iOverlay As Integer) As Integer
            		<PreserveSig()> Function Replace(ByVal i As Integer, ByVal hbmImage As IntPtr, ByVal hbmMask As IntPtr) As Integer
            		<PreserveSig()> Function AddMasked(ByVal hbmImage As IntPtr, ByVal crMask As Integer, ByRef pi As Integer) As Integer
            		<PreserveSig()> Function Draw(ByRef pimldp As IMAGELISTDRAWPARAMS) As Integer
            		<PreserveSig()> Function Remove(ByVal i As Integer) As Integer
            		<PreserveSig()> Function GetIcon(ByVal i As Integer, ByVal flags As Integer, ByRef picon As IntPtr) As Integer
            		<PreserveSig()> Function GetImageInfo(ByVal i As Integer, ByRef pImageInfo As IMAGEINFO) As Integer
            		<PreserveSig()> Function Copy(ByVal iDst As Integer, ByVal punkSrc As IImageList, ByVal iSrc As Integer, ByVal uFlags As Integer) As Integer
            		<PreserveSig()> Function Merge(ByVal i1 As Integer, ByVal punk2 As IImageList, ByVal i2 As Integer, ByVal dx As Integer, ByVal dy As Integer, ByRef riid As Guid, ByRef ppv As IntPtr) As Integer
            		<PreserveSig()> Function Clone(ByRef riid As Guid, ByRef ppv As IntPtr) As Integer
            		<PreserveSig()> Function GetImageRect(ByVal i As Integer, ByRef prc As RECT) As Integer
            		<PreserveSig()> Function GetIconSize(ByRef cx As Integer, ByRef cy As Integer) As Integer
            		<PreserveSig()> Function SetIconSize(ByVal cx As Integer, ByVal cy As Integer) As Integer
            		<PreserveSig()> Function GetImageCount(ByRef pi As Integer) As Integer
            		<PreserveSig()> Function SetImageCount(ByVal uNewCount As Integer) As Integer
            		<PreserveSig()> Function SetBkColor(ByVal clrBk As Integer, ByRef pclr As Integer) As Integer
            		<PreserveSig()> Function GetBkColor(ByRef pclr As Integer) As Integer
            		<PreserveSig()> Function BeginDrag(ByVal iTrack As Integer, ByVal dxHotspot As Integer, ByVal dyHotspot As Integer) As Integer
            		<PreserveSig()> Function EndDrag() As Integer
            		<PreserveSig()> Function DragEnter(ByVal hwndLock As IntPtr, ByVal x As Integer, ByVal y As Integer) As Integer
            		<PreserveSig()> Function DragLeave(ByVal hwndLock As IntPtr) As Integer
            		<PreserveSig()> Function DragMove(ByVal x As Integer, ByVal y As Integer) As Integer
            		<PreserveSig()> Function SetDragCursorImage(ByRef punk As IImageList, ByVal iDrag As Integer, ByVal dxHotspot As Integer, ByVal dyHotspot As Integer) As Integer
            		<PreserveSig()> Function DragShowNolock(ByVal fShow As Integer) As Integer
            		<PreserveSig()> Function GetDragImage(ByRef ppt As Point, ByRef pptHotspot As Point, ByRef riid As Guid, ByRef ppv As IntPtr) As Integer
            		<PreserveSig()> Function GetItemFlags(ByVal i As Integer, ByRef dwFlags As Integer) As Integer
            		<PreserveSig()> Function GetOverlayImage(ByVal iOverlay As Integer, ByRef piIndex As Integer) As Integer
            	End Interface
				
            	Public Shared Function GetIconFrom(ByVal PathName As String, ByVal IcoSize As IconSize, ByVal UseFileAttributes As Boolean) As Icon
            		Dim ico As Icon = Nothing
            		Dim shinfo As New SHFILEINFOW()
            		Dim flags As UInteger = SHGFI_SYSICONINDEX
				
            		If UseFileAttributes Then flags = (flags Or SHGFI_USEFILEATTRIBUTES)
				
            		If SHGetFileInfoW(PathName, FILE_ATTRIBUTE_NORMAL, shinfo, Marshal.SizeOf(shinfo), flags) = 0 Then
            			Throw New IO.FileNotFoundException()
            		End If
				
            		Dim iidImageList As New Guid("46EB5926-582E-4017-9FDF-E8998DAA0950")
            		Dim iml As IImageList = Nothing
            		SHGetImageList(IcoSize, iidImageList, iml)
				
            		If iml IsNot Nothing Then
            			Dim hIcon As IntPtr = IntPtr.Zero
            			iml.GetIcon(shinfo.iIcon, ILD_IMAGE, hIcon)
            			ico = CType(Icon.FromHandle(hIcon).Clone, Icon)
            			DestroyIcon(hIcon)
            			If Not ico.ToBitmap.PixelFormat = Imaging.PixelFormat.Format32bppArgb Then
            				ico.Dispose()
            				iml.GetIcon(shinfo.iIcon, ILD_TRANSPARENT, hIcon)
            				ico = CType(Icon.FromHandle(hIcon).Clone, Icon)
            				DestroyIcon(hIcon)
            			End If
            		End If
				
            		Return ico
            	End Function
				
            	Public Function GetBase64From(ByVal PathName As String, ByVal IcoSize As IconSize, ByVal UseFileAttributes As Boolean) As String
            		Dim bitmap As Bitmap = GetIconFrom(PathName, IcoSize, UseFileAttributes).ToBitmap()
            		Dim stream As New System.IO.MemoryStream()
            		bitmap.Save(stream, System.Drawing.Imaging.ImageFormat.Bmp)
            		Return Convert.ToBase64String(stream.ToArray())
            	End Function
				'Perhaps up here we need PathNames as object?
				Public Function GetAllBase64From(ByVal PathNames As Object, ByVal IcoSize As IconSize, ByVal UseFileAttributes As Boolean) As String
					'With an AHK array, get all assosciated icons, write them to a temporary file and return the file path.
					Dim sRet As String = ""
					Dim len as integer = PathNames.length()
					if len >= 1 then
						sRet = Me.GetBase64From(PathNames(1), IcoSize, UseFileAttributes)
						if len >= 2 then
							For i as integer = 2 to PathNames.length()
								sRet &= """,""" & Me.GetBase64From(PathNames(i), IcoSize, UseFileAttributes)
							Next
						end if
					end if
					sRet = "[""" & sRet & """]"
					return WriteToTempFile(sRet)
				End Function
				Public Function WriteToTempFile(ByVal Data As String) As String
					' Writes text to a temporary file and returns path
					Dim strFilename As String = System.IO.Path.GetTempFileName()
					Dim objFS As New System.IO.FileStream(strFilename, _
					System.IO.FileMode.Append, _
					System.IO.FileAccess.Write)
					' Write data
					Dim Writer As New System.IO.StreamWriter(objFS)
					With Writer
						.BaseStream.Seek(0, System.IO.SeekOrigin.End)
						.WriteLine(Data)
						.Flush()
						.Close()
					End With
					Return strFilename
				End Function
			End Class
        `
        var references = [
                             "System.dll",
                             "System.Drawing.dll"
                         ]
        
        var   DynaCLR = require('DynaCLR')
        var   CLR = DynaCLR.new()
        var   asm = CLR.CompileAssembly(vb,references, "System", "Microsoft.VisualBasic.VBCodeProvider")
        var   obj = CLR.CreateObject(asm, "IconHelper")
		var  imgs = CLR.Execute(obj,"GetAllBase64From", [images,iconSizes.Large,false])
        CLR.Finally(function(){
            var fs = require('fs')
			fs.readFile(imgs.value,"ascii",function(err,data){
				ret = ""
				var e=""
				try {
					ret = JSON.parse(data)
				} catch(e) {
					ret = data
				}
				callback({ret,err,e})
			})
        })
        return true
    }
   
}

var i;
console.time("getFileIcons__testData")
getFileIcons__testData()
console.timeEnd("getFileIcons__testData")