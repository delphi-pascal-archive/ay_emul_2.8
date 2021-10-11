{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit WaveOutAPI;

interface

uses Windows, Messages, MMSystem, SysUtils, Forms;

type
//Digital sound data buffer
 TWaveOutBuffer = packed array of byte;
 TVisPoint = record
  AmpA,AmpB,AmpC,AmpE,
  TnA,TnB,TnC,EnvP,EnvT,Mix,Calc:integer;
 end;

const
 NumberOfBuffersDef = 3;
 BufLen_msDef = 300;
 WODeviceDef = WAVE_MAPPER;

var
 NumberOfBuffers,BufferLength,BuffLen,BufLen_ms:integer;
 NOfTicks,WODevice:DWORD;
 IsPlaying:boolean = False;
 Reseted:integer = 0;
 Paused:boolean;
 NumberOfChannels,SampleRate,SampleBit:integer;
 VisPoints:array of TVisPoint;
 MkVisPos,VisPosMax,VisPoint,VisStep,VisTickMax:DWORD;
 ResetMutex:THandle;
 HWO:HWAVEOUT;
 waveOutBuffers:array of record
  Buf:TWaveOutBuffer;
  WH:WAVEHDR;
 end;

procedure StartWOThread;
procedure WOThreadFinalization;
procedure StopWOThread;
procedure WOCheck(Res:MMRESULT);
function WOThreadActive:boolean;
procedure WOResetPlaying(Res:boolean);
procedure WOUnresetPlaying;
procedure WOPauseRestart;
procedure SetBuffers(len,num:integer);
procedure WOVisualisation;

implementation

uses MainWin, Players;

var
 WOEventH:THANDLE;
 WOThreadID:DWORD;
 WOThreadH:THANDLE = 0;
 WOCS:RTL_CRITICAL_SECTION;

type
 EMultiMediaError = class(Exception);

procedure WOCheck(Res:MMRESULT);
var
 ErrMsg:array[0..255] of Char;
begin
if Res <> 0 then
 begin
  EnterCriticalSection(WOCS);
  waveOutGetErrorText(Res,ErrMsg,SizeOf(ErrMsg));
  LeaveCriticalSection(WOCS);
  raise EMultiMediaError.Create(ErrMsg)
 end
end;

procedure WOVisualisation;
var
 CurVisPos:DWORD;
 MMTIME1:MMTime;
 T,E,A:integer;
 TE:boolean;
begin
if not WOThreadActive or Paused then exit;
    MMTIME1.wType := TIME_SAMPLES;
    EnterCriticalSection(WOCS);
    waveOutGetPosition(HWO,@MMTIME1,sizeof(MMTIME1));
    LeaveCriticalSection(WOCS);
    if MMTIME1.sample <> 0 then //if woReseted then don't redraw
     begin
    VProgrPos := BaseSample + MMTIME1.sample;
    CurrTime_Rasch := round(VProgrPos / SampleRate * 1000);
    CurVisPos := MMTIME1.sample mod VisTickMax div VisStep;
    if SpectrumChecked or IndicatorChecked then
     with VisPoints[CurVisPos] do
      begin
       if Calc = 0 then
        begin
         Calc := 1;
         case EnvT of
         8,12 : E := 28;
         10,14: E := 26;
         else
          begin
           E := AmpE - 1;
           if E < 0 then E := 0
          end 
         end;
         T := TnA;
         if AmpA and 16 = 0 then
          AmpA := AmpA * 2
         else if not (EnvT in [8,10,12,14]) then
          AmpA := E
         else
          begin
           A := E;
           TE := Mix and 1 = 0;
           if (T <= 3) and TE then
            Dec(A,6)
           else if TE then
            A := 30;
           AmpA := A;
           if (T <= 3) or not TE then
            if EnvT in [8,12] then
             T := EnvP * 16
            else
             T := EnvP * 32;
          end;
         TnA := T;
         T := TnB;
         if AmpB and 16 = 0 then
          AmpB := AmpB * 2
         else if not (EnvT in [8,10,12,14]) then
          AmpB := E
         else
          begin
           A := E;
           TE := Mix and 2 = 0;
           if (T <= 3) and TE then
            Dec(A,6)
           else if TE then
            A := 30;
           AmpB := A;
           if (T <= 3) or not TE then
            if EnvT in [8,12] then
             T := EnvP * 16
            else
             T := EnvP * 32;
          end;
         TnB := T;
         T := TnC;
         if AmpC and 16 = 0 then
          AmpC := AmpC * 2
         else if not (EnvT in [8,10,12,14]) then
          AmpC := E
         else
          begin
           A := E;
           TE := Mix and 4 = 0;
           if (T <= 3) and TE then
            Dec(A,6)
           else if TE then
            A := 30;
           AmpC := A;
           if (T <= 3) or not TE then
            if EnvT in [8,12] then
             T := EnvP * 16
            else
             T := EnvP * 32;
          end;
         TnC := T;
        end;
       RedrawVisChannels(AmpA,AmpB,AmpC,30);
       RedrawVisSpectrum(VisPoints[CurVisPos]);
      end;
      ShowProgress(VProgrPos)
     end;
end;

procedure WaitForWOThreadExit;
var
 ExCode:DWORD;
begin
if WOThreadH = 0 then exit;
repeat
 if not GetExitCodeThread(WOThreadH,ExCode) then break;
 if ExCode = STILL_ACTIVE then Sleep(0)
until ExCode <> STILL_ACTIVE;
CloseHandle(WOThreadH);
WOThreadH := 0
end;

procedure StopWOThread;
var
 msg:TMsg;
begin
if WOThreadActive then
 begin
  IsPlaying := False;
  WOResetPlaying(True);
  WOUnresetPlaying;
  SetEvent(WOEventH);
  WaitForWOThreadExit;
  while not PeekMessage(msg,Form1.Handle,
                      WM_FINALIZEWO,WM_FINALIZEWO,PM_REMOVE) do Sleep(0);
  WOThreadFinalization
 end
end;

function WOThreadFunc(a:pointer):dword;stdcall;

 function AllBuffersDone:boolean;
 var
  i:integer;
 begin
  Result := False;
  for i := 0 to NumberOfBuffers - 1 do
   if waveOutBuffers[i].WH.dwFlags and WHDR_DONE = 0 then exit;
  Result := True
 end;

var
 i,j,SampleSize:integer;
 mut:boolean;
begin
SampleSize := (SampleBit div 8) * NumberOfChannels;
mut := False;
try
repeat
 if WaitForSingleObject(ResetMutex,INFINITE) <> WAIT_OBJECT_0 then break;
 mut := True;
 if not Real_End then
  begin
   for i := 0 to NumberOfBuffers - 1 do
    with waveOutBuffers[i] do
     begin
      if Reseted > 0 then break;
      if not IsPlaying then break;
      if WH.dwFlags and WHDR_DONE <> 0 then
       begin
        MakeBuffer(WH.lpdata);
        if Reseted > 0 then break;
        if not IsPlaying then break;
        if BuffLen = 0 then
         begin
          if AllBuffersDone then break
         end
        else
         begin
          WH.dwBufferLength := BuffLen * SampleSize;
          WH.dwFlags := WH.dwFlags and not WHDR_DONE;
          EnterCriticalSection(WOCS);
          try
          WOCheck(waveOutWrite(HWO,@WH,sizeof(WAVEHDR)))
          finally
          LeaveCriticalSection(WOCS)
          end
         end
       end
     end
  end;
 if Real_End and (Reseted = 0) and AllBuffersDone then break;
 mut := False;
 ReleaseMutex(ResetMutex);
 if not IsPlaying then break;
 j := WaitForSingleObject(WOEventH,BufLen_ms);
 if (j <> WAIT_OBJECT_0) and (j <> WAIT_TIMEOUT) then break
until not IsPlaying
finally
if mut then ReleaseMutex(ResetMutex);
PostMessage(Form1.Handle,WM_FINALIZEWO,0,0);
Result := STILL_ACTIVE - 1
end
end;

procedure StartWOThread;
var
 pwfx:pcmwaveformat;
 i,bl:integer;
begin
if WOThreadActive then exit;
with pwfx.wf do
 begin
  wFormatTag := 1;
  nChannels := NumberOfChannels;
  nSamplesPerSec := SampleRate;
  nBlockAlign := (SampleBit div 8) * NumberOfChannels;
  nAvgBytesPerSec := SampleRate * nBlockAlign
 end;
pwfx.wBitsPerSample := SampleBit;
WOCheck(waveOutOpen(@HWO,WODevice,@pwfx,WOEventH,0,CALLBACK_EVENT));
WaitForSingleObject(WOEventH,INFINITE);
try
bl := BufferLength * pwfx.wf.nBlockAlign;
for i := 0 to NumberOfBuffers - 1 do
 with waveOutBuffers[i] do
  begin
   SetLength(Buf,bl);
   with WH do
    begin
     lpdata := @Buf[0];
     dwBufferLength := bl;
     dwFlags := 0;
     dwUser := 0;
     dwLoops := 0;
    end;
   WOCheck(waveOutPrepareHeader(HWO,@WH,sizeof(WAVEHDR)));
   WH.dwFlags := WH.dwFlags or WHDR_DONE;
  end
except
 WOCheck(waveOutClose(HWO));
 raise
end;

IsPlaying := True;
Reseted := 0;
Paused := False;
WOThreadH := CreateThread(nil,0,@WOThreadFunc,nil,0,WOThreadID);
//SetThreadPriority(WOThreadH,THREAD_PRIORITY_ABOVE_NORMAL)
end;

procedure WOThreadFinalization;
var
 i:integer;
begin
WaitForWOThreadExit;

try
 WOCheck(waveOutReset(HWO));
 for i := 0 to NumberOfBuffers - 1 do
  with waveOutBuffers[i] do
   begin
    while WH.dwFlags and WHDR_DONE = 0 do Sleep(0);
    if WH.dwFlags and WHDR_PREPARED <> 0 then
     WOCheck(waveOutUnprepareHeader(HWO,@WH,sizeof(WAVEHDR)));
    Buf := nil
   end;
 WOCheck(waveOutClose(HWO));
except
 ShowException(ExceptObject, ExceptAddr);
end;

IsPlaying := False;
Reseted := 0

end;

function WOThreadActive;
var
 ExCode:DWORD;
begin
Result := (WOThreadH <> 0) and
          GetExitCodeThread(WOThreadH,ExCode) and
          (ExCode = STILL_ACTIVE);
if not Result then
 if WOThreadH <> 0 then
  begin
   CloseHandle(WOThreadH);
   WOThreadH := 0
  end
end;

procedure WOResetPlaying;
var
 i:integer;
begin
inc(Reseted);
if Reseted > 1 then exit;
WaitForSingleObject(ResetMutex,INFINITE);
if Res then
 begin
  WOCheck(waveOutReset(HWO));
  MkVisPos := 0;
  VisPoint := 0;
  NOfTicks := 0;
  for i := 0 to NumberOfBuffers - 1 do
   with waveOutBuffers[i] do
    while WH.dwFlags and WHDR_DONE = 0 do Sleep(0)
 end
end;

procedure WOUnresetPlaying;
begin
dec(Reseted);
if Reseted = 0 then
 begin
  SetEvent(WOEventH);
  ReleaseMutex(ResetMutex)
 end
end;

procedure SetBuffers;
begin
if WOThreadActive then exit;
if (num < 2) or (num > 10) then exit;
if (len < 5) or (len > 2000) then exit;
BufLen_ms := len;
NumberOfBuffers := num;
SetLength(waveOutBuffers,NumberOfBuffers);
BufferLength := round(BufLen_ms * SampleRate / 1000);
VisPosMax := round(BufferLength * NumberOfBuffers / VisStep) + 1;
VisTickMax := VisStep * VisPosMax;
SetLength(VisPoints,VisPosMax)
end;

procedure WOPauseRestart;
begin
EnterCriticalSection(WOCS);
try
if Paused then
 begin
  WOCheck(waveOutRestart(HWO));
  Paused := False
 end
else
 begin
  WOCheck(waveOutPause(HWO));
  Paused := True
 end 
finally
 LeaveCriticalSection(WOCS);
end
end;

initialization

WOEventH := CreateEvent(nil,False,False,nil);
InitializeCriticalSection(WOCS);

finalization

DeleteCriticalSection(WOCS);
CloseHandle(WOEventH);

end.
