{
lightBASS
---------
(c)2003,2005 S.V.Bulba
http://bulba.at.kz/
vorobey@mail.khstu.ru

Description:
------------
Dinamycally loads/unloads BASS.DLL
Performs all required checks before calling BASS.DLL
Uses minimal set of constants, types and declarations from original BASS.PAS
Written for using with BASS.DLL version 2.1
}

unit lightBASS;

interface

uses
 Windows,Messages,SysUtils;

type
 HSTREAM = DWORD;
 HMUSIC = DWORD;
 HSYNC = DWORD;
 QWORD = int64;
 FLOAT = Single;

 EBASSError = class(Exception);

 SYNCPROC = procedure(handle: HSYNC; channel, data: DWORD; user: DWORD); stdcall;

{
Next procedures and functions checks some flags and handles
and if all OK calls BASS.DLL functions. During calling
some errors can be ocurred, all of them are correctly translated
into DELPHI's exceptions with error messages
}

procedure RaiseLastBASSError;

procedure LoadBASS(WMA:boolean); //If BASS.DLL is not loaded then loads BASS.DLL,
                        //checks version and gets some procs addresses
                        //if WMA then also loads BASSWMA.DLL

procedure UnloadBASS;   //Unload BASS.DLL if it was loaded

procedure InitBASS(device: Integer; freq, flags: DWORD; win: HWND);
                        //calls BASS_Init if BASS was not initialized

procedure FreeBASS;     //calls BASS_Free if BASS was initialized

procedure PlayBASS(FileName:PChar;Stream:boolean;WMA:boolean);
                        //Tries start playing file: Stream = True - as stream,
                        //                          Stream = False - as module.
                        //If successed then set sync for end of music by
                        //WM_PLAYNEXTITEM message

procedure PlayFreeBASS;     //if PlayBASS was OK, stops playing and removes sync

function BASS_StreamCreateFile2(WMA:boolean; f: Pointer; flags: DWORD): HSTREAM;

procedure SwitchPause;  //during playing pauses/resumes playback

function GetLengthBASS(var TimeSec:DWORD):DWORD;
                        //returns max position for using with
                        //BASS_ChannelGetPosition. Length in bytes is
                        //stored in TimeSec var. For streams both values
                        //are identical.

const
 BASS_NOSOUNDDEVICE = 0;
 BASS_FIRSTSOUNDDEVICE = 1;

//Some consts from BASS.PAS
 BASS_TAG_ID3   = 0;
 BASS_TAG_ID3V2 = 1;
 BASS_TAG_OGG   = 2;

 BASS_STREAM_DECODE      = $200000;

 BASS_MUSIC_STOPBACK     = $80000;
 BASS_MUSIC_CALCLEN      = $8000;
 BASS_MUSIC_NOSAMPLE     = $100000;

 BASS_DATA_FFT512   = $80000000;
 BASS_DATA_FFT1024  = $80000001;
 BASS_DATA_FFT2048  = $80000002;
 BASS_DATA_FFT4096  = $80000003;

var
//Some BASS.DLL function addresses (see description in original BASS.PAS)
 BASS_GetVersion:function: DWORD; stdcall;
 BASS_ErrorGetCode:function: DWORD; stdcall;
 BASS_Init:function (device: Integer; freq, flags: DWORD; win: HWND; clsid: PGUID): BOOL; stdcall;
 BASS_Free:function: BOOL; stdcall;
 BASS_StreamCreateFile:function (mem: BOOL; f: Pointer; offset, length, flags: DWORD): HSTREAM; stdcall;
 BASS_StreamFree:procedure (handle: HSTREAM); stdcall;
 BASS_ChannelPlay:function (handle: DWORD; restart: BOOL): BOOL; stdcall;
 BASS_ChannelSetSync:function (handle: DWORD; stype: DWORD; param: QWORD; proc: SYNCPROC; user: DWORD): HSYNC; stdcall;
 BASS_ChannelRemoveSync:function (handle: DWORD; sync: HSYNC): BOOL; stdcall;
 BASS_ChannelPause:function (handle: DWORD): BOOL; stdcall;
 BASS_StreamGetLength:function (handle: HSTREAM): QWORD; stdcall;
 BASS_ChannelGetPosition:function (handle: DWORD): QWORD; stdcall;
 BASS_ChannelSetPosition:function (handle: DWORD; pos: QWORD): BOOL; stdcall;
 BASS_ChannelGetLevel:function (handle: DWORD): DWORD; stdcall;
 BASS_ChannelGetData:function (handle: DWORD; buffer: Pointer; length: DWORD): DWORD; stdcall;
 BASS_ChannelGetAttributes:function (handle: DWORD; var freq, volume: DWORD; var pan: Integer): BOOL; stdcall;
 BASS_ChannelBytes2Seconds:function (handle: DWORD; pos: QWORD): FLOAT; stdcall;
 BASS_ChannelSeconds2Bytes:function (handle: DWORD; pos: FLOAT): QWORD; stdcall;
 BASS_StreamGetTags:function (handle: HSTREAM; tags : DWORD): PChar; stdcall;
 BASS_MusicLoad:function (mem: BOOL; f: Pointer; offset, length, flags, freq: DWORD): HMUSIC; stdcall;
 BASS_MusicFree:procedure (handle: HMUSIC); stdcall;
 BASS_MusicGetName:function (handle: HMUSIC): PChar; stdcall;
 BASS_MusicGetLength:function (handle: HMUSIC; playlen: BOOL): DWORD; stdcall;

 BASS_WMA_StreamCreateFile:function (mem:BOOL; fl:pointer; offset,length,flags:DWORD): HSTREAM; stdcall;

 hiBASS:THandle = 0;       //handle to BASS.DLL instance,
                           //0 => BASS.DLL is not loaded
 hiBASSWMA:THandle = 0;    //handle to BASSWMA.DLL instance,
                           //0 => BASSWMA.DLL is not loaded

 MusicHandle:integer = 0;  //handle to stream or module,
                           //0 => no music loaded

 MusicIsStream:boolean;    //True => Music is stream, otherwise module

 BASSPaused:boolean;       //pause flag, used by SwitchPause

 BASSInitialized:boolean = False; //True => BASS_Init was called successfully

 BASSDevice:integer;

implementation

uses MainWin;

const
//Some consts from BASS.PAS
 BASS_SYNC_MESSAGE                 = $20000000;
 BASS_SYNC_END                     = 2;
 BASS_MP3_SETPOS         = $20000;

var
 hsEND:HSYNC = 0; //sync handler, used for end of music message (WM_PLAYNEXTITEM)
                  //if <> 0 then sync is set

procedure RaiseLastBASSError;
const
 BASSErCodes:array[0..42] of string =
 ('All is OK',
  'Memory error',
  'Can''t open the file',
  'Can''t find a free sound driver',
  'The sample buffer was lost',
  'Invalid handle',
  'Unsupported sample format',
  'Invalid playback position',
  'BASS_Init has not been successfully called',
  'BASS_Start has not been successfully called',
  'Unknown error',
  'Unknown error',
  'Unknown error',
  'Unknown error',
  'Already initialized/paused/whatever',
  'Unknown error',
  'Not paused',
  'Unknown error',
  'Can''t get a free channel',
  'An illegal type was specified',
  'An illegal parameter was specified',
  'No 3D support',
  'No EAX support',
  'Illegal device number',
  'Not playing',
  'Illegal sample rate',
  'Unknown error',
  'The stream is not a file stream',
  'Unknown error',
  'No hardware voices available',
  'Unknown error',
  'The MOD music has no sequence data',
  'No internet connection could be opened',
  'Couldn''t create the file',
  'Effects are not enabled',
  'The channel is playing',
  'Unknown error',
  'Requested data is not available',
  'The channel is a "decoding channel"',
  'A sufficient DirectX version is not installed',
  'Connection timedout',
  'Unsupported file format',
  'Unavailable speaker');
var
 ErCode:DWORD;
begin
ErCode := BASS_ErrorGetCode;
if ErCode > 42 then ErCode := 26;
raise EBASSError.Create(BASSErCodes[ErCode])
end;

function TryGet(const p:pointer):pointer;
begin
Result := p;
if p = nil then RaiseLastOSError
end;

procedure CheckVersion;
begin
if BASS_GetVersion <> $00010002 then
 raise EBASSError.Create('Sorry, BASS version 2.1 required.')
end;

procedure LoadBASS;
begin
if hiBass = 0 then
 begin
  hiBASS := LoadLibrary('BASS.DLL');
  if hiBASS = 0 then
   raise EBASSError.Create(
    'BASS.DLL 2.1 by Ian Luck required for playing extra file types.'#13#10 +
        'Download it from http://bulba.at.kz/');
  try
   BASS_GetVersion := TryGet(GetProcAddress(hiBASS,'BASS_GetVersion'));
   CheckVersion;
   BASS_ErrorGetCode := TryGet(GetProcAddress(hiBASS,'BASS_ErrorGetCode'));
   BASS_Init := TryGet(GetProcAddress(hiBASS,'BASS_Init'));
   BASS_Free := TryGet(GetProcAddress(hiBASS,'BASS_Free'));
   BASS_StreamCreateFile := TryGet(GetProcAddress(hiBASS,'BASS_StreamCreateFile'));
   BASS_StreamFree := TryGet(GetProcAddress(hiBASS,'BASS_StreamFree'));
   BASS_ChannelPlay := TryGet(GetProcAddress(hiBASS,'BASS_ChannelPlay'));
   BASS_ChannelSetSync := TryGet(GetProcAddress(hiBASS,'BASS_ChannelSetSync'));
   BASS_ChannelRemoveSync := TryGet(GetProcAddress(hiBASS,'BASS_ChannelRemoveSync'));
   BASS_ChannelPause := TryGet(GetProcAddress(hiBASS,'BASS_ChannelPause'));
   BASS_StreamGetLength := TryGet(GetProcAddress(hiBASS,'BASS_StreamGetLength'));
   BASS_ChannelGetPosition := TryGet(GetProcAddress(hiBASS,'BASS_ChannelGetPosition'));
   BASS_ChannelSetPosition := TryGet(GetProcAddress(hiBASS,'BASS_ChannelSetPosition'));
   BASS_ChannelGetLevel := TryGet(GetProcAddress(hiBASS,'BASS_ChannelGetLevel'));
   BASS_ChannelGetData := TryGet(GetProcAddress(hiBASS,'BASS_ChannelGetData'));
   BASS_ChannelGetAttributes := TryGet(GetProcAddress(hiBASS,'BASS_ChannelGetAttributes'));
   BASS_ChannelBytes2Seconds := TryGet(GetProcAddress(hiBASS,'BASS_ChannelBytes2Seconds'));
   BASS_ChannelSeconds2Bytes := TryGet(GetProcAddress(hiBASS,'BASS_ChannelSeconds2Bytes'));
   BASS_StreamGetTags := TryGet(GetProcAddress(hiBASS,'BASS_StreamGetTags'));
   BASS_MusicLoad := TryGet(GetProcAddress(hiBASS,'BASS_MusicLoad'));
   BASS_MusicFree := TryGet(GetProcAddress(hiBASS,'BASS_MusicFree'));
   BASS_MusicGetName := TryGet(GetProcAddress(hiBASS,'BASS_MusicGetName'));
   BASS_MusicGetLength := TryGet(GetProcAddress(hiBASS,'BASS_MusicGetLength'));
  except
   FreeLibrary(hiBass);
   hiBass := 0;
   raise
  end
 end;
if not WMA or (hiBASSWMA <> 0) then exit;
hiBASSWMA := LoadLibrary('BASSWMA.DLL');
if hiBASSWMA = 0 then
 begin
  FreeLibrary(hiBASS);
  hiBASS := 0;
  raise EBASSError.Create(
    'BASSWMA.DLL 2.1 by Ian Luck required for playing WMA files.'#13#10 +
    'Download it from http://bulba.at.kz/');
 end;
try
 BASS_WMA_StreamCreateFile := TryGet(GetProcAddress(hiBASSWMA,'BASS_WMA_StreamCreateFile'));
except
 FreeLibrary(hiBASSWMA);
 hiBASSWMA := 0;
 FreeLibrary(hiBASS);
 hiBASS := 0;
 raise
end
end;

procedure UnloadBASS;
begin
if hiBASSWMA <> 0 then
 begin
  FreeLibrary(hiBASSWMA);
  hiBASSWMA := 0
 end; 
if hiBASS = 0 then exit;
FreeLibrary(hiBASS);
hiBASS := 0
end;

procedure InitBASS;
begin
if BASSInitialized and (BASSDevice = device) then exit;
FreeBASS;
BASSDevice := device;
BASSInitialized := BASS_Init(device,freq,flags,win,nil);
if not BASSInitialized then RaiseLastBASSError
end;

procedure FreeBASS;
begin
if BASSInitialized then
 begin
  BASSInitialized := False;
  BASS_Free
 end
end;

procedure PlayBASS;
begin
if MusicHandle <> 0 then exit;
MusicIsStream := Stream;
if Stream then
 MusicHandle := BASS_StreamCreateFile2(WMA,FileName,0)
else
 MusicHandle := BASS_MusicLoad(False,FileName,0,0,BASS_MUSIC_STOPBACK or BASS_MUSIC_CALCLEN,0);
if MusicHandle = 0 then RaiseLastBASSError;
BASSPaused := False;
hsEND := BASS_ChannelSetSync(MusicHandle,BASS_SYNC_MESSAGE or BASS_SYNC_END,0,pointer(WM_PLAYNEXTITEM),0);
if not BASS_ChannelPlay(MusicHandle,True) then RaiseLastBASSError
end;

procedure PlayFreeBASS;
begin
if MusicHandle = 0 then exit;
try
 if hsEND <> 0 then
  begin
   if not BASS_ChannelRemoveSync(MusicHandle,hsEND) then RaiseLastBASSError;
   hsEND := 0
  end;
finally
 if MusicIsStream then
  BASS_StreamFree(MusicHandle)
 else
  BASS_MusicFree(MusicHandle);
 MusicHandle := 0
end
end;

function BASS_StreamCreateFile2(WMA:boolean; f: Pointer; flags: DWORD): HSTREAM;
begin
if WMA then
 Result := BASS_WMA_StreamCreateFile(False,f,0,0,flags)
else
 Result := BASS_StreamCreateFile(False,f,0,0,flags)
end;

procedure SwitchPause;
begin
if MusicHandle = 0 then exit;
if not BASSPaused then
 begin
  BASSPaused := BASS_ChannelPause(MusicHandle);
  if not BASSPaused then RaiseLastBASSError
 end
else
 begin
  BASSPaused := not BASS_ChannelPlay(MusicHandle,False);
  if BASSPaused then RaiseLastBASSError
 end
end;

function GetLengthBASS;
begin
Result := 0;
if MusicHandle = 0 then exit;
if MusicIsStream then
 begin
  Result := BASS_StreamGetLength(MusicHandle);
  TimeSec := Result
 end
else
 begin
  Result := BASS_MusicGetLength(MusicHandle,False);
  TimeSec := BASS_MusicGetLength(MusicHandle,True)
 end;
if (integer(Result) = - 1) or (integer(TimeSec) = - 1) then RaiseLastBASSError
end;

end.
