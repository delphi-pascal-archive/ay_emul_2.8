{
CD via MCI
----------
(c)2003 S.V.Bulba
http://bulba.at.kz/
vorobey@mail.khstu.ru

Description:
------------
Simple MCI interface
Based on Multimedia Programmer's Reference
Some ideas was got from Notify CD Player v1.60
}

unit CDviaMCI;

interface

uses Windows,Messages,MMSystem;

procedure InitCDDevice(CDNumber:DWORD);
procedure CDPlayTrack(CDNumber:DWORD;n:integer;Handle:THandle);
function CDGetNumberOfTracks(CDNumber:DWORD):DWORD;
function CDGetTrackLength(CDNumber:DWORD;n:integer):DWORD;
function IsAudioTrack(CDNumber:DWORD;n:integer):boolean;
function CDGetPosition(CDNumber:DWORD):integer;
procedure CDSetPosition(CDNumber:DWORD;n,pos:DWORD;Handle:THandle);
procedure CDSwitchPause(CDNumber:DWORD;Handle:THandle);
procedure StopCDDevice(CDNumber:DWORD);
procedure CloseCDDevice(CDNumber:DWORD);
procedure FreeAllCD;
procedure StartCD(CDNumber,n:integer);
function CheckCDNum(CDNumber:integer):boolean;
procedure CDVisualisation;

var
 CDDrives:array of char;
 CDIDs:array of MCIDEVICEID;
 CDPlayingPaused:boolean;
 CDPauseTime:DWORD;
 CDIndex:integer = 0;

implementation

uses SysUtils, WaveOutAPI, MainWin, Players;

procedure MCICheck(Er:MCIERROR);
var
 ErMes:array[0..255] of char;
 s:string;
begin
if Er <> 0 then
 begin
  s := 'MCI error #' + IntToStr(Er);
  if mciGetErrorString(Er,ErMes,256) then
   s := s + ': "' + ErMes + '"';
  raise Exception.Create(s)
 end
end;

function CheckCDNum;
begin
Result :=  (DWORD(CDNumber) < DWORD(Length(CDIDs))) and
           (CDIDs[CDNumber] <> 0)
end;

procedure CheckAndRaiseCDNum(CDNumber:integer);
begin
if (Length(CDDrives) = 0) then
 raise Exception.Create('No CD drives found');
if DWORD(CDNumber) >= DWORD(Length(CDDrives)) then
 raise Exception.Create('Specified CD drive not found')
end;

procedure InitCDDevice;
var
 MOP:MCI_OPEN_PARMS;
 MSP:MCI_SET_PARMS;
begin
CheckAndRaiseCDNum(CDNumber);
if CDIDs[CDNumber] <> 0 then exit;
DWORD(MOP.lpstrDeviceType) := MCI_DEVTYPE_CD_AUDIO;
MOP.lpstrElementName := PChar(CDDrives[CDNumber] + ':'#0);
MCICheck(mciSendCommand(0,MCI_OPEN,MCI_OPEN_TYPE or
                                   MCI_OPEN_TYPE_ID or
                                   MCI_OPEN_ELEMENT,
                                   DWORD(@MOP)));
CDIDs[CDNumber] := MOP.wDeviceID;
MSP.dwTimeFormat := MCI_FORMAT_TMSF;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_SET,MCI_SET_TIME_FORMAT
                                              ,DWORD(@MSP)))
end;

function CDGetNumberOfTracks;
var
 MSP:MCI_STATUS_PARMS;
begin
Result := 0;
if not CheckCDNum(CDNumber) then exit;
MSP.dwItem := MCI_STATUS_NUMBER_OF_TRACKS;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_STATUS,MCI_STATUS_ITEM or MCI_WAIT,
					DWORD(@MSP)));
Result := MSP.dwReturn;
if Result > 99 then Result := 99
end;

function CDGetTrackLength;
var
 MSP:MCI_STATUS_PARMS;
begin
Result := 0;
if not CheckCDNum(CDNumber) then exit;
MSP.dwItem := MCI_STATUS_LENGTH;
MSP.dwTrack := n;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_STATUS,MCI_STATUS_ITEM or MCI_TRACK or MCI_WAIT,
					DWORD(@MSP)));
Result := MSP.dwReturn
end;

function IsAudioTrack;
var
 MSP:MCI_STATUS_PARMS;
begin
Result := False;
if not CheckCDNum(CDNumber) then exit;
MSP.dwItem := MCI_CDA_STATUS_TYPE_TRACK;
MSP.dwTrack := n;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_STATUS,MCI_STATUS_ITEM or MCI_TRACK or MCI_WAIT,
					DWORD(@MSP)));
Result := MSP.dwReturn = MCI_CDA_TRACK_AUDIO
end;

function CDGetPosition;
var
 MSP:MCI_STATUS_PARMS;
begin
Result := 0;
if not CheckCDNum(CDNumber) then exit;
MSP.dwItem := MCI_STATUS_POSITION;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_STATUS,MCI_STATUS_ITEM or MCI_WAIT,DWORD(@MSP)));
Result := MSP.dwReturn
end;

procedure CDSetPosition;
var
 MPP:MCI_PLAY_PARMS;
begin
if not CheckCDNum(CDNumber) then exit;
MPP.dwCallback := Handle;
MPP.dwFrom := n + pos shl 8;
MPP.dwTo := DWORD(n) + CDGetTrackLength(CDNumber,n) shl 8;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_PLAY,MCI_NOTIFY or MCI_FROM or MCI_TO
                                                   ,DWORD(@MPP)));
CDPlayingPaused := False
end;

procedure CDPlayTrack;
var
 MPP:MCI_PLAY_PARMS;
begin
if not CheckCDNum(CDNumber) then exit;
MPP.dwCallback := Handle;
MPP.dwFrom := n;
MPP.dwTo := DWORD(n) + CDGetTrackLength(CDNumber,n) shl 8;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_PLAY,MCI_NOTIFY or MCI_FROM or MCI_TO
                                                   ,DWORD(@MPP)));
CDPlayingPaused := False
end;

procedure CDSwitchPause;
begin
if not CheckCDNum(CDNumber) then exit;
if not CDPlayingPaused then
 begin
  CDPauseTime := CDGetPosition(CDNumber);
  StopCDDevice(CDNumber);
  CDPlayingPaused := True
 end
else
 begin
  CDSetPosition(CDNumber,CDPauseTime and 255,CDPauseTime shr 8,Handle);
  CDPlayingPaused := False
 end
end;

procedure StopCDDevice;
begin
if not CheckCDNum(CDNumber) then exit;
MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_STOP,MCI_WAIT,0))
end;

procedure CloseCDDevice;
begin
if not CheckCDNum(CDNumber) then exit;
try
 try
  StopCDDevice(CDNumber)
 finally
  MCICheck(mciSendCommand(CDIDs[CDNumber],MCI_CLOSE,MCI_WAIT,0));
  CDIDs[CDNumber] := 0
 end
except
end 
end;

procedure FreeAllCD;
var
 i:integer;
begin
for i := 0 to Length(CDDrives) - 1 do
 CloseCDDevice(i)
end;

procedure CDVisualisation;
var
 MSF:packed record
  case boolean of
  True: (TMSF:DWORD);
  False:(T,M,S,F:byte);
 end;
begin
if Paused or (CurFileType <> CDAFile) or not IsPlaying then exit;
    try
     MSF.TMSF := CDGetPosition(CurCDNum);
    except
     PostMessage(Form1.Handle,WM_PLAYERROR,0,0);
     exit
    end;
    CurrTime_Rasch := round((MSF.F / 75 + MSF.S + MSF.M * 60) * 1000);
    VProgrPos := MSF.F + (MSF.S + MSF.M * 60) * 75;
    ShowProgress(VProgrPos);
end;

procedure StartCD;
begin
// if IsPlaying then exit;
// StopCDDevice(CDNumber);
 InitCDDevice(CDNumber);
 try
  CDPlayTrack(CDNumber,n,Form1.Handle)
 except
  CloseCDDevice(CDNumber);
  raise
 end;
 IsPlaying := True;
 Reseted := 0;
 Paused := False;
end;

var
 i:char;
 l:integer;

initialization

for i := 'A' to 'Z' do
 if GetDriveType(PChar(i + ':\')) = DRIVE_CDROM then
  begin
   l := Length(CDDrives);
   SetLength(CDDrives,l + 1);
   CDDrives[l] := i
  end;
SetLength(CDIDs,Length(CDDrives));
for l := 0 to Length(CDDrives) - 1 do
 CDIDs[l] := 0

finalization

CDDrives := nil;
CDIDs := nil

end.
