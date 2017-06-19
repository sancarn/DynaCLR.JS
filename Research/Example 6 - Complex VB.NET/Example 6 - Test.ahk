#Include Libs\CLR.ahk
#Include Libs\JSON.ahk
vb=
(
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
End Class
)

;Turns out System.dll is ALWAYS required. If not given, the function will not be callable.
asm := CLR_CompileVB(vb, "System.dll | System.Drawing.dll")
obj := CLR_CreateObject(asm,"IconHelper")
;img := obj.GetBase64From("C:\Users\sancarn\Desktop\Programming\JS\Launch Menu\DynaCLR.JS\Research\Example 6 - Complex VB.NET\Example 6 - Test.ahk",0x3,0)
s = ["C:\\Users\\sancarn\\Desktop\\Programming\\JS\\Launch Menu\\DynaCLR.JS\\Research\\Example 6 - Complex VB.NET\\Example 6 - Test.ahk",2,0]

;arr := JSON_Parse(s)	
;
;msgbox, % arr[1]
;msgbox, % arr[2]
;msgbox, % arr[3]

img := execObjMember(obj,"GetBase64From", JSON_Parse(s))
clipboard := img
;Output:
;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AAAAAAAAAAAAAHtYR6HSpoz++OHJ/vrkzf765Mz++uTL/vrky/7648r++ePJ/vniyf754sn++eLI/vnhyP754cf++eHH/vnhxv754cX++eDE/vngxP754MP++d/C/vnfwv7538H++d7B/vnewf753cD++d2//vndv/753b7++d29/vncvf753Lz++dy8/vncu/7527r++du6/vnauf752rn++dq4/vnat/752rf++dm3/vnZtv752bX++di1/vnYtP752LP++dey/vnXsv7517H++dex/uu+ov7Qkoj+fFN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSpoz++OLK/vrlzf765c3++uTM/vrkzP765Mv++uPL/vrjyv754sr++eLJ/vniyf754sj++eLI/vnix/754cb++eHF/vngxf754MT++eDE/vnfxP7538L++d/D/vnfwv753sH++d7A/vnewP753r/++d6//vndvv753b3++d28/vncvP753Lv++dy7/vnbuv7527r++du5/vnauP752rj++dq3/vnZt/752bb++dm1/vnZtf752LT++diz/vnXs/7517L++dey/uy+ov7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSpo3++OPL/vrlzv765c7++uXN/vrkzf765Mz++uTM/vrky/7648r++uPK/vnjyf754sn++eLI/vnix/754sf++eHG/vnhxf754MX++eDF/vngxf754MP++eDE/vnfwv7538L++d/B/vnewP753sD++d7A/vnev/753b7++d29/vncvf753Lz++dy7/vncu/7527v++du6/vnbuf7527j++du4/vnauP752rf++dq2/vnZtf752bX++di0/vnYtP752LP++diz/uy+o/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSpo3++OPL/vrlz/765c7++uXO/vrkzf765M3++uTM/vrkzP7648v++uPK/vnjyv754sn++eLI/vniyP754sf++eHG/vnhxv754MX++eDF/vngxf754MT++eDE/vnfw/7538L++d/B/vnewf753sD++d7A/vnev/753b7++d29/vncvf753Lz++dy8/vncu/7527v++du6/vnbuv7527n++du4/vnauP752rf++dq2/vnZtv752bX++di1/vnYtf752LT++diz/uy+o/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSpo3++OPM/vrm0P765s/++uXP/vrlzv765M7++uTN/vrkzf765Mz++uTL/vrjy/7648r++uPJ/vniyf754sj++eLI/vnix/754cb++eHG/vnhxf754MX++eDE/vngxP7538P++d/C/vnfwv753sH++d7A/vnewP753r/++d2//vndvv753b7++dy9/vncvf753Lz++dy7/vnbu/7527r++du5/vnbuf752rj++dq4/vnZt/752bf++dm2/vnZtv752bX++dm0/uy+o/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp43++OTN/vrn0P765tD++ubP/vrlz/765c7++uXO/vrkzf765M3++uTM/vrky/765Mv++uPK/vnjyf7548n++eLJ/vnix/754sf++eLH/vnhxv754cb++eHF/vnhxP754MT++eDD/vngwv7538L++d/B/vnewf753sD++d7A/vnev/753b/++d2+/vndvv753b3++dy8/vncvP753Lv++du6/vnbuf7527n++dq5/vnauP752rj++dq3/vnZt/752bb++dm1/uy/pP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp43++OTN/vrn0f765tD++ubQ/vrlz/765c/++uXO/vrkzf765M3++uTM/vrky/765Mv++uPK/vnjyv7548n++eLJ/vniyP754sf++eLH/vnhx/754cb++eHF/vnhxf754MT++eDE/vngw/7538L++d/B/vnewf753sH++d7A/vnewP753b/++d2+/vndvv753b3++dy8/vncvP753Lv++du7/vnbuv7527r++dq5/vnauf752rj++dq3/vnZt/752bb++dm1/uy/pP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp43++OTO/vrn0v7659H++ubR/vrm0f765tD++uXP/vrlz/765c7++uXN/vrlzf765Mz++uTL/vrjy/7648v++uPK/vriyf754sn++eLJ/vniyP754cf++eHG/vnhxv754cX++eDF/vngxP754MT++d/D/vnfw/7538L++d7B/vnewf753sD++d6//vndv/753b7++d2+/vndvf753Lz++dy8/vnbvP7527v++du6/vnbuv7527n++dq5/vnauP752rf++dm3/uy/pf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp47++OXP/vrn0/7659L++ufS/vrn0v765tH++ubQ/vrm0P765c7++uXO/vrlzv765c3++uTM/vrkzP765Mz++uTL/vrjyv7648r++ePK/vniyP754sj++eLH/vnhxv754cb++eHF/vngxf754MX++eDE/vngxP7538P++d/C/vnfwf7538H++d7A/vnewP753r/++d2//vndvv753L3++dy9/vncvf753Lz++dy7/vnbuv7527r++du6/vnbuf752rf++dq4/uzApf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp47++OXP/vrn1P7659P++ufS/vrn0v765tH++ubR/vrm0P765c/++uXO/vrlzv765c3++uTN/vrkzf765Mz++uTL/vrjy/7648r++ePK/vniyf754sj++eLH/vnhx/754cb++eHG/vngxf754MX++eDF/vngxP7538P++d/C/vnfwv7538H++d7A/vnewP753r/++d2//vndv/753L7++dy9/vncvf753Lz++dy8/vnbu/7527r++du6/vnbuf752rj++dq4/uzApf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp47++OXQ/vro1f7659T++ufT/vrn0v7659L++ufS/vrm0f765tD++ubQ/vLdy/7izMD+xayv/qqPn/6dgZj+q5Cf/te+uP765Mv++uPK/vnjyv7548n++eLJ/vniyf754sj++eHH/vnhx/754cb++eHG/vngxf754MT++eDD/vngw/733cH+7tO8/te8sP67nqH+oYKU/qGDlP62l53+6Mu2/vndvv753b3++dy9/vncvP753Lv++du6/vnbuv7527n++dq4/uzApv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp4/++OXR/vro1f766NX++ujU/vro0/766NL++ufS/vrn0v7659H++ubR/uXPxP7Dq6/+kHWQ/m5Off5fP3b+d1iA/r+lq/765Mz++uTL/vrkyv7648r++uPK/vrjyv754sn++eLI/vniyP754sb++eHG/vnhxv754cX++eDE/vngw/7z2sD+3MCz/rGUnf6CZYX+Y0J2/mdHeP6Iaof+3cCx/vndv/753b7++d29/vndvf753Lz++dy7/vncu/7527r++du5/uzAp/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSp4/++OXR/vrp1f766NX++ujU/vro1P766NP++ufT/vrn0v7659H++ubR/tC5uf6dgpr+ZkZ5/lo5cv5fP3b+d1iA/r+lq/765Mz++uTL/vrky/7648v++uPK/vrjyv754sn++eLI/vniyP754sf++eHG/vnhxv754cX++eDE/vngxP7u1b/+v6Ol/optif5dPHP+WThx/mdHeP6Iaof+3cCx/vndv/753b7++d29/vndvf753Lz++dy7/vncu/7527r++du6/uzAp/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqI/++ObS/vrq1/766db++unV/vrp1f766NT++ujU/vro1P7659P++ufS/sCor/6HbI3+Xj10/lg3cf5fP3b+d1iA/r+mrP765c3++uTM/vrkzP765Mz++uPL/vrjy/7648r++ePK/vniyf754sj++eLH/vnix/754cb++eHG/vngxf7r0r3+qY2a/npagP5YN3H+WDdx/mdHeP6Iaof+3cCx/vnewP753b/++d6+/vndvv753b3++dy9/vncvP753Lz++du7/uzAqP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqI/++ObT/vrq2P766tf++unW/vrp1v766NX++ujV/vro1f766NT++ufT/rWcqP56XIP+XDtz/lg3cf5fQHb+d1mA/r+nrf765c7++uXN/vrkzP765Mz++uTM/vrjzP7648v++uPL/vnjyv7548n++eLI/vniyP754sf++eLH/vnhxf7oz7z+mX+S/m9Pff5YN3H+WDdx/mdHeP6Iaof+3cCy/vnfwP753r/++d6//vnev/753b7++d2+/vncvf753L3++dy8/uzBqP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqI/++ObT/vrq2P766tj++unX/vrp1v766NX++ujV/vro1f766NT++ufT/q+Xpf5zVYD+XDtz/lg3cf5fQHb+d1mA/r+nrf765c7++uXO/vrkzf765Mz++uTM/vrjzP7648v++uPL/vnjyv7548n++eLI/vniyP754sf++eLH/vnhxv7nz7z+kniO/mtKev5YN3H+WDdx/mdHeP6Iaoj+3cCy/vnfwf753sD++d7A/vnev/753b/++d2+/vncvf753L3++dy8/uzBqP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJD++OfU/vrq2f766tn++urY/vrp1/766df++unW/vro1v766NX++ujU/q+Xpf5zVID+XDtz/lg3cf5fQHb+d1mA/r+nrf765dD++uXP/vrlz/765c7++uTN/vrkzf765Mz++uTL/vrjy/7648r++ePJ/vniyf754sn++eLI/vniyP7nz73+kneO/mtKev5YN3H+WDdx/mdHef6Iaon+3cCz/vnfwv7538H++d7B/vnewP753sD++d6//vndv/753b7++d2+/uzBqf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJD++OfV/vrr2v766tn++urZ/vrq2P766tj++unX/vrp1/766db++unV/q+Xpv5zVID+XDtz/lg3cf5fQHb+d1mB/r+nrv765tH++ubQ/vrm0P765c/++uXO/vrlzv765c3++uXM/vrkzP765Mv++uTK/vrjyv7548r++eLJ/vniyf7nz77+kneP/mtKev5YN3H+WDdx/mdHef6Iaon+3cG0/vngwv7538L++d/C/vnewf753sH++d7A/vnewP753r/++d2//uzBqv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJD++OfV/vrr2v766tr++urZ/vrq2f766tj++unX/vrp1/766db++unV/q+Xpv5zVID+XDtz/lg3cf5fQHb+d1mB/r+nrv765tH++ubR/vrm0P765c/++uXO/vrlzv765c3++uXM/vrkzP765Mv++uTL/vrjy/7548r++eLJ/vniyf7nz77+kneP/mtKev5YN3H+WDdx/mdHef6Iaon+3cG0/vngw/7538P++d/C/vnewv753sH++d7B/vnewP753r/++d2//uzBqv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJD++OjX/vrr3P7669v++uva/vrq2v766tn++urY/vrq1/766df++unW/q+Xp/5zVID+XDtz/lg3cf5fQHb+d1mB/r+orv7659L++ubS/vrm0f765tD++ubP/vrlz/765c7++uXO/vrlzf765M3++uTM/vrkzP7648v++uPL/vnjyv7n0L/+kneQ/mtKe/5YN3H+WDdx/mdHef6Ia4n+3cK1/vngxf754MT++d/E/vnfw/7538L++d/C/vnewf753sD++d6//uzCqv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJH++OjY/vrs3f767Nz++uvb/vrr2v7669n++uvZ/vrr2P766tj++urX/q+YqP5zVID+XDtz/lg3cf5fQHb+d1mB/r+or/7659L++ufS/vrn0v765tH++ufQ/vrm0P765s/++uXP/vrlzv765M7++uTN/vrkzP765Mz++uTM/vrky/7o0MD+k3eQ/mtKe/5YN3H+WDdx/mdHef6Ia4n+3cO2/vnhxv754cX++eDF/vngxP7538P++d/C/vnfwf7538H++d7A/uzCq/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJH++OjY/vrs3f767Nz++uvb/vrr2v7669r++uvZ/vrr2f766tj++urY/q+YqP5zVID+XDtz/lg3cf5fQHb+d1mB/r+osP7659P++ufS/vrn0v765tH++ufR/vrm0P765tD++uXP/vrlz/765M7++uTN/vrkzf765Mz++uTM/vrky/7o0MD+k3eQ/mtKe/5YN3H+WDdx/mdHef6Ia4n+3cO3/vnhxv754cX++eDF/vngxP7538P++d/C/vnfwv7538H++d7A/uzCq/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJH++OnZ/vrt3f767N3++uzc/vrs3P767Nv++uva/vrr2v7669n++urZ/q+Yqf5zVYD+Wzty/lg3cf5bO3P+aEl6/pZ+l/7AqbD+y7W2/tjCvf7jzsX+7djK/vThzv765tH++ubR/vrl0P765c/++uXO/vrlzv765c3++uTM/vrkzP7o0cH+k3eQ/mtKe/5YN3H+WDdx/mdHef6Ia4r+3cS4/vnix/754cb++eHF/vngxf754MT++eDD/vngw/7538L++d/C/uzDq/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJH++Ona/vrt3v767d7++u3d/vrs3f767Nz++uzb/vrr2/7669r++uva/q+Yqf5zVYD+Wzty/lg3cf5YN3H+Wztx/m9Rf/6CaYv+k3qU/qeMn/63n6v+xq6z/tK7uf7bxr/+4MrC/uTOw/7n0sX+6tXF/u7Zx/7y3cr+9+LM/vnkzP7o0cH+k3eR/mtKe/5YN3H+WDdx/mdHef6Ia4r+3cS5/vniyP754sf++eLG/vnhxv754cX++eDE/vngw/754MP++d/D/uzDrP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqJH++Ona/vrt3/767d7++u3d/vrs3f767Nz++uzc/vrr2/7669v++uva/q+Yqf5zVYD+Wzty/lg3cf5YN3H+WDdx/lw7c/5fP3X+YkJ3/mZGef5pSXv+a0x9/m9Qfv54WoL+i3CP/puAmP6pj6D+t56n/siwsf7bw7z+79nI/vjhzP7o0cH+k3eR/mtKe/5YN3H+WDdx/mdHef6Ia4r+3cS5/vniyP754sf++eLG/vnhxv754cX++eDF/vngxP754MT++d/D/uzDrP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqZL++Orb/vru4P767t/++u3f/vrt3v767N7++uzd/vrs3P767Nz++uvb/q+Yqv5zVYH+Wzpy/lg3cf5YN3H+WDdx/lg3cf5YN3H+WDdx/lg3cf5YN3H+WDdx/lg3cf5dPHP+aEl7/nFSgP55W4P+gGSG/ohujP6TeJL+noOZ/qiNnv6li5z+e1yC/mRCdv5YN3D+WDdw/mdHef6Ia4r+3cW5/vniyf754sj++eLI/vnix/754cb++eHG/vnhxf754MX++eDE/uzDrf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqZL++Ovc/vrv4P767uD++u7g/vru3/767d/++u3e/vrt3f767N3++uzc/q+Zq/5zVYH+XDpy/lg3cf5YOHH+XDtz/mRFef5qS3z+Zkd6/mJCd/5ePnX+Wjly/lg4cf5YN3H+WDdx/lg3cf5YN3H+WDdx/lg3cf5YN3H+WDdx/mA/df5mSHn+YUF1/lw7cv5YN3D+WDdw/mdHef6Ia4r+3cW6/vnjyf7548n++eLJ/vniyP754sf++eLH/vnhxv754cb++eHF/uzErv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqZL++Ovc/vrv4f767uD++u7g/vru3/767d/++u3f/vrt3v767N3++uzd/q+Zq/5zVYH+XDpy/lg3cf5cPHT+bEx8/pF4lf6qkqX+mYGa/oZtjf51V4H+Y0R4/ls8c/5YN3H+WDdx/lg3cf5YN3H+WDdx/lg3cf5YN3H+WDdx/lk4cf5aOnL+WTlx/lg3cf5YN3D+WDdw/mdHef6Ia4r+3cW6/vnjyv7548n++eLJ/vniyf754sf++eLH/vnhx/754cb++eHG/uzErv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSqZL++Ovd/vrv4v767uH++u7h/vru4f767uD++u7g/vrt3/767d7++uze/q+Zq/5zVYH+XDtz/lg3cf5eP3X+c1WA/q2WqP7ax8X+0L2+/sWwtv66o67+r5io/qaOov6dhJz+k3qV/ohtjf5+YIb+c1aA/m1Ofv5nR3r+Wzpz/lg3cf5YN3H+WDdx/lg3cf5YN3H+WDdx/mdHev6Ia4v+3cW7/vrky/7648v++uPK/vriyv754sn++eLJ/vniyP754sf++eHH/uzErv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqZP++eze/vvv4/777+P++u/i/vru4v767uH++u7g/vrt3/767d7++u3e/q+ZrP5zVYH+XDtz/lg3cf5fQHb+d1qD/r+qtP766tr++ura/vrq2f766tf++urX/vPh0v7n1cr+1sK//sOtsv6wl6b+n4ac/pV8lf6KcI7+eFqD/nFSgP5sTX3+Xz91/lo5cv5XN3H+WDdx/mdHev6Ia4v+3cW8/vrkzP765Mz++uPL/vrjy/7648r++ePK/vnjyP754sj++eLH/uzEr/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqZP++ezf/vvv5P777+P++u/j/vru4v767uH++u7g/vrt4P767d/++u3e/q+ZrP5zVYH+XDtz/lg3cf5fQHb+d1qD/r+qtP766tr++ura/vrq2f766tj++urY/vjo1f725dT+8uHR/u7czv7r2Mz+59TJ/uXRx/7jz8X+38rC/tO+u/67o6v+fmGF/mFCdv5XN3H+WDdx/mdHev6Ia4v+3cW8/vrkzP765Mz++uPL/vrjy/7648r++ePK/vnjyf754sj++eLH/uzEr/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqZP++ezg/vvw5f778OP+++/k/vvv4v767+H++u7h/vru4f767uD++u7f/q+ZrP5zVYH+XDtz/lg3cf5fQHb+d1qD/r+qtP7669v++uva/vrr2f7669n++urZ/vrq1/766tf++unW/vrp1v766db++unV/vro1P766NT++ujT/vPgz/7bx7/+i3GO/mdHef5XN3H+WDdx/mdHev6Ia4v+3ca9/vrkzf765M3++uTM/vrky/765Mv++uPK/vnjyv754sn++eLI/uzEsP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpP++e3h/vvw5f778OX++/Dk/vvv5P777+P++u/i/vrv4f767+H++u7g/q+ZrP5zVYH+XDtz/lg3cf5fQHb+d1qD/r+rtf767Nv++uzb/vrs2/7669r++uvZ/vrr2f766tj++urY/vrp2P766df++unW/vro1v766NX++ujU/vro1P7o1cf+k3mU/mtLfP5YN3H+WDdx/mdIev6IbIv+3ca+/vrlz/765c7++uXO/vrlzf765Mz++uTL/vrjy/7648r++uPK/u3Fsf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpP++e3h/vvw5v778OX++/Dk/vvv5P777+P++u/i/vrv4v767+H++u7h/q+ZrP5zVYH+XDtz/lg3cf5fQHb+d1qD/r+rtf767Nz++uzb/vrs2/7669r++uva/vrr2v766tn++urY/vrp2P766df++unX/vrp1v766NX++ujU/vro1P7o1cf+k3mU/mtLfP5YN3H+WDdx/mdIev6IbIv+3ca+/vrlz/765c7++uXO/vrlzf765Mz++uTL/vrjy/7648r++uPK/u3Fsf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpT++e3i/vvx5/778eb++/Dl/vvw5P778OT++/Dj/vvw4/777+L++u/i/q+arf5zVYH+XDtz/lg3cf5fQHb+d1qD/r+rtf767d3++uzc/vrs2/7669v++uvb/vrr2/7669r++urZ/vrq2P766tj++urY/vrq1v766db++unV/vrp1P7o1cj+k3mU/mtLfP5YN3H+WDdx/mdIev6IbYz+3ce//vrm0P765c/++uXO/vrlzf765c3++uXM/vrky/765Mv++uTK/u3Fsf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpT++e7j/vvy5/778ef++/Hm/vvx5f778OX++/Dl/vvw5P778OT+++/j/rCbrv5zVoH+XDtz/lg3cf5fQHf+d1qE/r+rt/767d7++u3e/vrs3f767Nz++uzc/vrr2/7669v++uva/vrr2v766tj++urY/vrq2P766tf++unX/vrp1v7o1cn+k3mU/mtLfP5YN3H+WDdx/mdIev6IbYz+3cfA/vrm0P765tD++ubP/vrlz/765c7++uXO/vrlzf765Mz++uTM/u3Gsv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpT++e7j/vvy5/778ef++/Hn/vvx5v778Ob++/Dl/vvw5f778OT+++/j/rCbrv5zVoH+XDtz/lg3cf5fQHf+d1qE/r+rt/767d7++u3e/vrs3f767N3++uzc/vrr3P7669v++uva/vrr2v766tn++urY/vrq2P766tf++unX/vrp1v7o1cr+k3mU/mtLfP5YN3H+WDdx/mdIev6IbYz+3cfA/vrm0f765tD++ubP/vrlz/765c7++uXO/vrlzv765M3++uTN/u3Gsv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpT++e/j/vvy6P778uj++/Lo/vvx5/778ef++/Hm/vvw5v778OX++/Dk/rCbr/5zVoL+XDtz/lg3cf5fQHf+d1qE/r+suP767t/++u3e/vrt3v767d7++uzd/vrs3f767Nz++uzb/vrr2v7669r++uvZ/vrq2P766tj++urX/vrp1v7o1cv+k3mV/mtLfP5YN3H+WDdx/mdIev6IbYz+3cjA/vrn0v7659H++ufQ/vrm0P765s/++uXP/vrlz/765c7++uTO/u3Gs/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpX++e/k/vvz6v778ur++/Lo/vvy6P778uj++/Hn/vvx5v778eX++/Dl/rCbsP5zVoL+XDtz/lg3cf5fQHf+d1uE/r+tuP767uD++u7g/vru3/767d/++u3e/vrt3f767N3++uzc/vrs3P767Nv++uva/vrr2v7669n++urZ/vrq2P7o1s3+k3mW/mtLfP5YN3H+WDdx/mdIev6IbYz+3cjB/vrn0v7659L++ufS/vrn0f765tH++ubQ/vrmz/765c/++uXO/u3Gs/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTqpX++e/k/vvz6v778ur++/Lp/vvy6P778uj++/Hn/vvx5/778eb++/Dl/rCbsP5zVoL+XDtz/lg3cf5fQHf+d1uE/r+tuP767uH++u7h/vru4P767d/++u3f/vrt3v767N3++uzc/vrs3P767Nv++uva/vrr2v7669r++urZ/vrq2f7o1s3+k3mW/mtLfP5YN3H+WDdx/mdIev6IbY3+3cjB/vrn0/7659L++ufS/vrn0f765tH++ubR/vrm0P765c/++uXO/u3Gs/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5X++fDl/vvz6/778+r++/Pq/vvz6f778uj++/Lo/vvy6P778ef++/Hm/rCcsP5zVoL+XDtz/lg3cf5fQHf+d1uF/r+tuf767uL++u7i/vru4f767uD++u7g/vrt3/767d3++u3d/vrt3P767Nz++uzc/vrs2/7669v++uva/vrr2v7o1s7+k3qW/mtLfP5YN3H+WDdx/mdIe/6IbY7+3cjC/vro1P766NP++ufT/vrn0v7659L++ubS/vrm0f765tD++ubP/u3HtP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5X++fDn/vv07f779Oz++/Pr/vvz6v778+r++/Lp/vvy6P778ej++/Hn/rCcsP5zVoL+XDtz/lg3cf5gQXf+fGGI/sKwu/777+P++u/i/vru4f767uH++u7g/vru3/767d/++u3f/vrt3v767d7++uze/vrs3P767Nz++uvb/vrr2v7o18/+k3uW/mtLfP5YN3H+WDdx/mlKfP6NcpH+3srE/vrp1v766NX++ujU/vrn1P7659P++ufS/vrn0v7659H++ubQ/u3HtP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5X++fDn/vv07f779Oz++/Pr/vvz6/778+r++/Lp/vvy6P778uj++/Ho/rCcsP5zVoL+XDtz/lg3cf5pSn3+moKe/tPCx/777+P++u/i/vru4f767uH++u7g/vru4P767d/++u3f/vrt3/767d7++uze/vrs3f767Nz++uvc/vrr2/7o18/+k3uW/mtLfP5YN3H+WDdx/nlchP6sk6X+5tPJ/vrp1v766NX++ujV/vrn1P7659P++ufS/vrn0v7659H++ubR/u3HtP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5b++fHo/vv17f779O3++/Ts/vvz7P778+v++/Pq/vvz6f778+n++/Lp/rCcsf5zVoP+XDtz/mhKfP6GbpH+vKq4/uPV0/778OT+++/j/vvv4v767+H++u/h/vrv4f767uD++u7g/vrt4P767d7++u3e/vrs3v767N3++uzd/vrs3P7o2M/+k3uW/mtLff5bOnP+b1CA/piAmf7Ltrn+7tzP/vrp1v766Nb++ujW/vro1P766NT++ujT/vro0v7659L++ufS/u3Htf7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5b++fHp/vv17/779e7++/Xt/vv07P779Oz++/Tr/vvz6/778+r++/Pq/relt/6AZY3+a01+/ohxk/6ynrH+39HS/vHm3v778OX++/Dk/vvw5P778OP+++/j/vrv4/767+L++u7h/vru4P767uD++u3f/vrt3v767d7++u3d/vrt3P7p2tH+nYSd/nlahP5vUYD+lX6Z/sGrtP7o1s3+9eTV/vrq2P766tf++unW/vrp1v766dT++unU/vro1P766NP++ujS/u3Htv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5b++fHp/vv17/779e7++/Xt/vv07f779Oz++/Ts/vvz7P778+v++/Pq/uje3P7ZzNH+1MXM/tzP0v7n29n+8+jh/vju5P778OX++/Dk/vvw5P778OT+++/j/vrv4/767+L++u7h/vru4f767uD++u3f/vrt3/767d7++u3d/vrt3f7159r+4dDL/tfExP7UwsL+383J/ura0P715db++OjY/vrq2P766tf++unW/vrp1v766dX++unV/vro1P766NP++ujT/u3Htv7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5b++fLq/vv17/779e7++/Xu/vv17v779e3++/Tt/vv07f779Oz++/Pr/vvz6v778+r++/Lp/vvy6f778ej++/Hn/vvx5v778eb++/Hl/vvw5f778OX++/Dk/vvv4/777+L++u/i/vrv4v767uH++u7g/vru4P767t/++u3e/vrt3v767d7++uzc/vrs3P767Nv++uvb/vrr2/7669r++urZ/vrq2f766tj++urX/vrq1/766db++unW/vro1P766NT++ujU/u3It/7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5f++fLr/vv28P779vD++/bv/vv27/779e/++/Xu/vv17f779O3++/Ts/vvz7P778+v++/Pq/vvz6f778+j++/Lo/vvy6P778uj++/Hn/vvx5v778OX++/Dl/vvw5f778OT+++/j/vvv4v767+L++u/h/vru4P767t/++u7f/vrt3v767d7++u3e/vrs3f767N3++uzc/vrs2/7669v++uvb/vrr2f7669n++uvY/vrq1/766tf++unW/vrp1v766db++ujW/u3IuP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5f++fLr/vv28f779vH++/bw/vv28P779e/++/Xu/vv17f779O3++/Ts/vvz7P778+v++/Pq/vvz6f778+n++/Lo/vvy6P778uj++/Hn/vvx5/778OX++/Dm/vvw5f778OT+++/k/vvv4v767+L++u/h/vru4f767uD++u7f/vrt3/767d/++u3e/vrs3v767N3++uzc/vrs3P7669v++uvb/vrr2v7669n++uvZ/vrq2P766tj++unX/vrp1v766db++ujW/u3IuP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5f++fPs/vv38v779/L++/bx/vv28f779vD++/Xv/vv17v779e3++/Xt/vv07P778+v++/Pr/vvz6v778+r++/Pp/vvy6P778uj++/Lo/vvx6P778eb++/Hn/vvw5f778OX++/Dl/vvv4/777+P+++/i/vrv4v767+H++u7g/vru4P767uD++u3f/vrt3/767d7++uzd/vrq2v755tb++d3P/vnTyf75zML++czC/vnLwv75y8L++cvB/vnLwP75ysD+9Mm9/ui1qP7Rkoj+fVN4/jUgRZ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5f++fPt/vv38v779/L++/fy/vv28f779vD++/bw/vv18P779e/++/Xu/vv07f779O3++/Ts/vv07P779Ov++/Pq/vvz6v778+r++/Lp/vvy6P778uj++/Hn/vvx5/778eb++/Dl/vvw5f778OT++/Dk/vvw4/777+P++u/i/vrv4v767uH++u7h/vru3/767d/++u3e/vnn1/743s3++Me8/viyrf74n5/++J+e/vifnv74n57++J+e/vienv73nZ3+652Y/eGZkf3OkYj9elJ1+zQiRpwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTq5f++fPt/vv38/779/P++/fy/vv28v779vH++/bw/vv18P779e/++/Xu/vv07v779O3++/Ts/vv07P779Ov++/Pr/vvz6v778+r++/Lp/vvy6f778uj++/Hn/vvx5/778eb++/Dl/vvw5f778OT++/Dk/vvw4/777+P++u/i/vrv4v767uH++u7h/vru4P767d/++u3f/vjk0f721r3+9sWs/vWym/71o4z+9KGJ/vSfiP70n4f+85+H/vGdh/7vm4f+4piF+9GLgPq0fnz4dEp06DYiRYwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJj++fTu/vv49P77+PT++/fz/vv38/779/L++/bx/vv28P779fD++/Xv/vv17/779e7++/Xt/vv17f779Oz++/Ts/vv06/778+r++/Pq/vvz6v778un++/Lo/vvy5/778ef++/Hm/vvx5f778OX++/Dl/vvw5P778OT+++/j/vvv4v767+H++u7h/vru4f767uD++u7g/vfgyv7zzq3+88Kc/vKziv7yp3z+8aR3/vChdP7voHL+7Z9y/umccf7kmHL80Y1w9LR4dPORYnTvaERwqDYkRVUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJj++fXw/vv49f77+PX++/j1/vv48/779/P++/fy/vv38v779vH++/bw/vv27/779u/++/Xv/vv17v779e7++/Xt/vv07f778+z++/Pr/vvz6v778+r++/Pp/vvy6f778uj++/Lo/vvx5/778ef++/Hm/vvw5v778OX++/Dk/vvv5P777+P++u/i/vrv4f767+H++u7g/vbdw/7wyJ/+8L+N/u+1fP7vrGz+7ahl/uukYf7qol7+56Bc/eCcWv3Yklv6uH5i6pFjZ+VqRW/aWz5rTi4uRQsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJj++fXw/vv49v77+PX++/j1/vv48/779/P++/fy/vv38v779vH++/bx/vv28P779vD++/Xv/vv17/779e7++/Xt/vv07f778+z++/Pr/vvz6/778+r++/Pp/vvy6f778un++/Lo/vvx6P778ef++/Hm/vvw5v778OX++/Dk/vvv5P777+P++u/i/vrv4v767+H++u7h/vbdw/7wyJ3+78CM/u+3fP7tr2z+6qpl/uamYf7jol7+3Zxe/NGQWvq6gFv1jF5n6H9Xa7KCWWhkNiY2IQAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJj++fXx/vv59/77+fX++/j1/vv49P779/P++/fz/vv38v779/L++/fy/vv28f779vH++/bw/vv18P779e/++/Xu/vv07f779O3++/Ts/vv07P779Ov++/Pq/vvz6v778+r++/Lp/vvy6f778uj++/Hn/vvx5v778eb++/Dl/vvw5f778OT++/Dj/vvw4/767+L++u/i/vbexP7wyZ7+78KO/u+6f/7ssnD+56xq/uGoZP3cn2H7z5Jg9bN8YvGVZWHoiFlmuXNOWHFSOUEfHx8fCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJn++fby/vv69/77+ff++/n2/vv49v77+PX++/j0/vv49P77+PT++/fz/vv38/779/L++/bx/vv28P779fD++/Xv/vv17/779e7++/Xt/vv17f779O3++/Ts/vv06/778+v++/Pq/vvz6f778un++/Lp/vvy6P778eb++/Hm/vvx5f778eX++/Dl/vvw5f778OT+++/j/vbgx/7xy6P+8cWT/u6+hP7rtnf+5K9v/d6ka/vPl2r3uIJn6pNjauFtR2zPlmRfa2NENykAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJn++fby/vv69/77+ff++/n2/vv49v77+Pb++/j1/vv49P77+PT++/f0/vv38/779/L++/bx/vv28f779fD++/Xv/vv17/779e7++/Xu/vv17f779O3++/Tt/vv07P778+v++/Pr/vvz6v778un++/Lp/vvy6P778ef++/Hn/vvx5v778eX++/Dl/vvw5f778OT+++/k/vbhyv7yzqj+8cea/u2/jP7otoD+3612/dCccvW4hW/rjWFv6IJabrKCXGleSjExKRUVFQwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrJn++fbz/vv6+P77+fj++/n3/vv59/77+ff++/n2/vv49f77+PX++/j1/vv48/779/P++/fy/vv38v779vH++/bw/vv27/779u/++/Xv/vv17v779e7++/Xu/vv07f778+z++/Ps/vvz6/778+r++/Lp/vvy6P778uj++/Lo/vvx5/778eb++/Hm/vvw5f778OX++/Dl/vfizP7z0a3+78mg/uq/lP3htYb90qJ9+rSFd/CVaHHef1lxtG9MX25XPUYdJAAkBwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrZn++ff0/vv6+v77+vn++/r5/vv6+P77+vf++/n3/vv59/77+fX++/j1/vv49P779/P++/fz/vv38v779/H++/bx/vv28f779vD++/bv/vv17/779e/++/Xu/vv07f779O3++/Ts/vvz6/778+r++/Pq/vvz6v778+n++/Lo/vvy6P778uj++/Hn/vvx5/778eb++/Dl/vfjzf7y0rD+7Mmm/eW+lvzZrIv7vIx99ZJndOpuSXDOhl5sWVE/PxwAAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrZn++ff1/vv7+v77+vn++/r5/vv6+P77+vj++/n3/vv59/77+fb++/j1/vv49f779/T++/fz/vv38v779/L++/bx/vv28f779vH++/bw/vv17/779e/++/Xu/vv07v779O3++/Ts/vvz7P778+v++/Pq/vvz6v778+n++/Lp/vvy6P778uj++/Hn/vvx5/778eb++/Dl/vXhzP7uzKz+58Sh+9ivlPS/lYPskWl66IdgdbeLY2xuRDE3KRwcHAkAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HTrZr++vj2/vz8+/77+/r++/r5/vv6+f77+vn++/r4/vv69/77+ff++/n2/vv49v77+PX++/j0/vv38/779/P++/fy/vv38v779/L++/bx/vv28P779vD++/Xv/vv17/779e3++/Tt/vv07f779Oz++/Tr/vv06v778+r++/Pq/vvz6f778uj++/Lo/vvy5/778ef++/Hm/vPfyv7pxqn9472d+cOdjfGfdn/iiGB7tHhVZnJhSEgqFxcXCwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HSrJn++fb0/vv6+v77+vr++vn5/vr5+f76+fj++vj3/vr49v769/b++vf1/vr39P769/T++vbz/vr28/769vL++vby/vr28v769fH++vXw/vr17/769O7++vTu/vr07f768+3++vPs/vrz6/768+v++vPr/vry6v768er++vHp/vrx6f768ej++vDn/vrw5/768Ob++u/l/vDax/7jv6T93LSa+K2IiPB4VXbYm3N+X2BGTx0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHtYR6HGloD+066c/tSvnv7Ur57+06+d/tOvnf7Tr53+06+d/tOvnP7Trpz+066c/tOunP7Trpz+066b/tOum/7Trpv+066b/tOum/7Trpv+066a/tOumv7TrZr+062a/tOtmf7TrZn+062Z/tOtmf7TrZn+062Z/tOtmP7TrJj+06yY/tOsmP7TrJj+06yX/tOsl/7TrJf+06yX/tCljf7MnoP9y5h//IJiWLAlGyVKLycnIBwcHAkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFE8MGqBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqIFcSqiBXEqogVxKqEc1KmAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA


JSON_Parse(orgs){
	return json.parse(orgs)
}

execObjMember(ByRef obj,theFunc,theArgs){
	return obj[theFunc](theArgs*)
}

