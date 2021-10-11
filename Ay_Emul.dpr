{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

program Ay_Emul;

uses
  Forms,
  Windows,
  Messages,
  TlHelp32,
  Sysutils,
  About in 'About.pas' {AboutBox},
  MainWin in 'MainWin.pas' {Form1},
  LH5 in 'lh5.pas',
  HeadEdit in 'HeadEdit.pas' {HeaderEditor},
  ChanDir in 'ChanDir.pas' {ChngDir},
  Mixer in 'Mixer.pas' {Form2},
  PlayList in 'PlayList.pas' {Form3},
  ProgBox in 'ProgBox.pas' {Form4},
  ItemEdit in 'ItemEdit.pas' {Form5},
  Tools in 'Tools.pas' {Form6},
  Z80 in 'Z80.pas',
  JmpTime in 'JmpTime.pas' {Form8},
  lightBASS in 'lightBASS.pas',
  BASScode in 'BASScode.pas',
  SelVolCtrl in 'SelVolCtrl.pas' {Form7},
  CDviaMCI in 'CDviaMCI.pas',
  Players in 'Players.pas',
  AY in 'AY.pas',
  WaveOutAPI in 'WaveOutAPI.pas',
  Convs in 'Convs.pas',
  UniReader in 'UniReader.pas',
  Languages in 'Languages.pas',
  FindPLItem in 'FindPLItem.pas' {Form9},
  SelectCDs in 'SelectCDs.pas' {CDList},
  digidrum in 'digidrum.pas';

{$R *.RES}
{$R WindowsXP.RES}

const
 WindowTitle = 'AY-3-8910 & AY-3-8912 Emulator v2.8';
 TitleLength = Length(WindowTitle);

var
 HPrevWindow:HWnd;

function CheckParams:boolean;
const
 alen = MAX_PATH * 2 + 4;
type
 arr = array[0..alen - 1] of byte;
var
 l:integer;
 T:DWORD;
 HBlock:longword;
 HAddr:^arr;
 s:string;
begin
Result := False;
T := GetTickCount;
repeat
HBlock := CreateFileMapping(longword(-1),nil,PAGE_READWRITE,0,
                                alen,'Ay_Emul Command Line Area');
if (HBlock <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
 begin
  CloseHandle(HBlock);
  Sleep(1);
  HBlock := 0
 end
until (HBlock <> 0) or (GetTickCount - T >= 5000);
if HBlock <> 0 then
 begin
  HAddr := MapViewOfFile(HBlock,FILE_MAP_ALL_ACCESS,0,0,alen);
  if HAddr <> nil then
   begin
    Result := True;
    s := '"' + GetCurrentDir + '" ' + GetCommandLine;
    if ParamCount = 0 then s := s + ' /vshow';
    l := Length(s);
    if l >= alen then l := alen - 1;
    move(s[1],HAddr^,l);
    HAddr^[l] := 0;
    SendMessage(HPrevWindow,WM_LINEPARAM,0,0);
    UnmapViewOfFile(HAddr)
   end;
  CloseHandle(HBlock)
 end
end;

function ProcessExists:boolean;
var
 pe32:PROCESSENTRY32;
 T,hSnapshot,CPID:DWORD;
 FN:string;

 function EnumWindowsProc(hWnd,lParam:DWORD):BOOL;stdcall;
 var
  PID:DWORD;
  s:string;
 begin
  Result := True;
  GetWindowThreadProcessId(hWnd,@PID);
  if PID = lParam then
   if GetWindowTextLength(hWnd) = TitleLength then
    begin
     SetLength(s,TitleLength + 1);
     GetWindowText(hWnd,PChar(s),TitleLength + 1);
     s := PChar(s);
     if s = WindowTitle then
      begin
       HPrevWindow := hWnd;
       Result := False
      end
    end
 end;

begin
Result := False;
hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
if hSnapshot = DWORD(-1) then RaiseLastOSError;
try
 FN := AnsiLowerCase(ExtractFileName(ParamStr(0)));
 CPID := GetCurrentProcessId;
 pe32.dwSize := sizeof(PROCESSENTRY32);
 if Process32First(hSnapshot,pe32) then
  repeat
   if pe32.th32ProcessID = CPID then exit;
   if AnsiLowerCase(ExtractFileName(pe32.szExeFile)) = FN then
    begin
     HPrevWindow := 0;
     T := GetTickCount;
     repeat
      EnumWindows(@EnumWindowsProc,pe32.th32ProcessID);
      if HPrevWindow = 0 then
       Sleep(1)
     until (HPrevWindow <> 0) or (GetTickCount - T >= 5000);
     if HPrevWindow <> 0 then Result := CheckParams;
     exit
    end;
  until not Process32Next(hSnapshot,pe32)
finally
 CloseHandle(hSnapshot)
end
end;

begin
if not ProcessExists then
 begin
  Application.Initialize;
  Application.Title := 'AY Emulator';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TCDList, CDList);
  Form1.Visible := False;
  try
   Form1.CommandLineAndRegCheck;
  except
   ShowException(ExceptObject, ExceptAddr)
  end;
  Form1.Visible := True;
  Application.Run
 end
end.
