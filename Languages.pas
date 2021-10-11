{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit Languages;

interface
const

{ Def_Warning = 'Warning';
 Mes_Warning:string = Def_Warning;
 Def_CanNotCreateMainWindow = 'Can not create main window';
 Mes_CanNotCreateMainWindow:string = Def_CanNotCreateMainWindow;
 Def_CanNotCreatePlayListWindow = 'Can not create play list window';
 Mes_CanNotCreatePlayListWindow:string = Def_CanNotCreatePlayListWindow;
 Def_OutOfMemory = 'Out of memory';
 Mes_OutOfMemory:string = Def_OutOfMemory;
 Def_InvalidPointer = 'Invalid pointer operation';
 Mes_InvalidPointer:string = Def_InvalidPointer;
 Def_DivByZero = 'Division by zero';
 Def_RangeError = 'Range check error';
 Def_IntOverflow = 'Integer overflow';
 Def_InvalidOp = 'Invalid floating point operation';
 Def_ZeroDivide = 'Floating point division by zero';
 Def_Overflow = 'Floating point overflow';
 Def_Underflow = 'Floating point underflow';
 Def_InvalidCast = 'Invalid class typecast';
 Def_AccessViolation = 'Access violation at address %p. %s of address %p';
 Mes_AccessViolation:string = Def_AccessViolation;
 Def_StackOverflow = 'Stack overflow';
 Def_ControlC = 'Control-C hit';
 Def_Privilege = 'Privileged instruction';
 Def_InvalidVarCast = 'Invalid variant type conversion';
 Def_InvalidVarOp = 'Invalid variant operation';
 Def_DispatchError = 'Variant method calls not supported';
 Def_VarArrayCreate = 'Error creating variant array';
 Def_VarNotArray = 'Variant is not an array';
 Def_VarArrayBounds = 'Variant array index out of bounds';
 Def_AssertionFailed = 'Assertion failed';
 Mes_AssertionFailed:string = Def_AssertionFailed;
 Def_ExternalException = 'External exception %x';
 Mes_ExternalException:string = Def_ExternalException;
 Def_IntfCastError = 'Interface not supported';
 Def_SafecallException = 'Exception in safecall method';
 Def_FileNotFound = 'File not found';
 Def_InvalidFilename = 'Invalid filename';
 Def_TooManyOpenFiles = 'Too many open files';
 Def_AccessDenied = 'File access denied';
 Def_EndOfFile = 'Read beyond end of file';
 Def_DiskFull = 'Disk full';
 Def_InvalidInput = 'Invalid numeric input';
 Def_InOutError = 'I/O error %d';
 Mes_InOutError:string = Def_InOutError;
 Def_ExceptTitle = 'Application Error';
 Mes_ExceptTitle:string = Def_ExceptTitle;
 Def_ReadAccess = 'Read';
 Mes_ReadAccess:string = Def_ReadAccess;
 Def_WriteAccess = 'Write';
 Mes_WriteAccess:string = Def_WriteAccess;
 Def_ModuleAccessViolation = 'Access violation at address %p in module ''%s''. %s of address %p';
 Mes_ModuleAccessViolation:string = Def_ModuleAccessViolation;
 Def_AssertError = '%s (%s, line %d)';
 Mes_AssertError:string = Def_AssertError;
 Def_AbstractError = 'Abstract Error';
 Mes_AbstractError:string = Def_AbstractError;
 Def_InvalidFormat = 'Format ''%s'' invalid or incompatible with argument';
 Mes_InvalidFormat:string = Def_InvalidFormat;
 Def_ArgumentMissing = 'No argument for format ''%s''';
 Mes_ArgumentMissing:string = Def_ArgumentMissing;
 Def_InvalidBitmap = 'Bitmap image is not valid';
 Mes_InvalidBitmap:string = Def_InvalidBitmap;}
 Def_InvalidLZH = 'LZH compressed data is not valid';
 Mes_InvalidLZH:string = Def_InvalidLZH;
 Def_ReadAfterEndOfFile = 'Read after end of file';
 Mes_ReadAfterEndOfFile:string = Def_ReadAfterEndOfFile;
 Def_SeekAfterEndOfFile = 'Seek after end of file';
 Mes_SeekAfterEndOfFile:string = Def_SeekAfterEndOfFile;
{ Def_CanNotRegisterClass = 'Can not register window class';
 Mes_CanNotRegisterClass:string = Def_CanNotRegisterClass;
 Def_CanNotCreateWindows = 'Can not create window';
 Mes_CanNotCreateWindow:string = Def_CanNotCreateWindows;
 Def_InvalidInteger = '''%s'' is not a valid integer value';
 Mes_InvalidInteger:string = Def_InvalidInteger;
 Def_FormatTooLong = 'Format string too long';
 Mes_FormatTooLong:string = Def_FormatTooLong;
 Def_InvalidFloat = '''%s'' is not a valid floating point value';
 Mes_InvalidFloat:string = Def_InvalidFloat;
 Def_Exception = 'Exception %s in module %s at %p.'#$0A'%s%s'; 
 Mes_Exception:string = Def_Exception;
 Def_OperationAborted = 'Operation aborted';
 Mes_OperationAborted:string = Def_OperationAborted;
 Def_DuplicatePackageUnit = 'Cannot load package ''%s.''  It contains unit ''%s,''' +
    ';which is also contained in package ''%s''';
 Mes_DuplicatePackageUnit:string = Def_DuplicatePackageUnit;
 Def_InvalidPackageFile = 'Invalid package file ''%s''';
 Mes_InvalidPackageFile:string = Def_InvalidPackageFile;
 Def_InvalidPackageHandle = 'Invalid package handle';
 Mes_InvalidPackageHandle:string = Def_InvalidPackageHandle;
 Def_ErrorLoadingPackage = 'Can''t load package %s.'#13#10'%s';
 Mes_ErrorLoadingPackage:string = Def_ErrorLoadingPackage;
 Def_CannotReadPackageInfo = 'Cannot access package information for package ''%s''';
 Mes_CannotReadPackageInfo:string = Def_CannotReadPackageInfo;
 Def_Win32Error = 'Win32 Error.  Code: %d.'#10'%s';
 Mes_Win32Error:string = Def_Win32Error;
 Def_UnkWin32Error = 'A Win32 API function failed';
 Mes_UnkWin32Error = Def_UnkWin32Error;
 Def_NL = 'Application is not licensed to use this feature';
 Mes_NL:string = Def_NL;
 Def_Unknown = '<unknown>';
 Mes_Unknown:string = Def_Unknown;}

implementation

end.
