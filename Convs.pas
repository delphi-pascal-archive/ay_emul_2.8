{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit Convs;

interface

procedure WAV_Converter;
procedure PSG_Converter;
procedure VTX_Converter;
procedure YM6_Converter;
procedure ZXAY_Converter;

implementation

uses Windows, UniReader, MainWin, AY, Z80, PlayList, SysUtils, WaveOutAPI, Lh5,
     HeadEdit, Controls, Players;

type
 PWriteBuffer = ^TWriteBuffer;
 TWriteBuffer = packed array[0..32767] of byte;
 
const
//Full names of trackers
 PChar_ST :array[0..34]of char = 'ZX Spectrum Sound Tracker v1.1-1.3';
 PChar_ASM:array[0..26]of char = 'ZX Spectrum ASM v0.xx-2.xx';
 PChar_FLS:array[0..25]of char = 'ZX Spectrum Flash Tracker';
 PChar_FTC:array[0..24]of char = 'ZX Spectrum Fast Tracker';
 PChar_PSC:array[0..29]of char = 'ZX Spectrum Pro Sound Creator';
 PChar_STP:array[0..29]of char = 'ZX Spectrum Sound Tracker Pro';
 PChar_SQT:array[0..22]of char = 'ZX Spectrum SQ-Tracker';
 PChar_PT1:array[0..29]of char = 'ZX Spectrum Pro Tracker v1.xx';
 PChar_PT2:array[0..29]of char = 'ZX Spectrum Pro Tracker v2.xx';
 PChar_PT3:array[0..29]of char = 'ZX Spectrum Pro Tracker v3.xx';
 PChar_GTR:array[0..26]of char = 'ZX Spectrum Global Tracker';
 PChar_FXM:array[0..18]of char = 'Fuxoft AY Language';

//Comment for VTX and YM6-files creating
 YMCommentLen = 52;
type
 NTString52 = array[0..YMCommentLen] of char;
const
 YMComment:NTString52 = 'Created by Sergey Bulba''s AY-3-8910/12 Emulator v' +
                        VersionString + #0;

var
//Wave-file header
 WaveFileHeader:record
  rId:          array[0..3] of char;
  rLen:         longint;
  wId:          array[0..3] of char;
  fId:          array[0..3] of char;
  fLen:         longint;
  wFormatTag:   word;
  nChannels:    word;
  nSamplesPerSec:  longint;
  nAvgBytesPerSec: longint;
  nBlockAlign:  word;
  FormatSpecific:  word;
  dId:          array[0..3] of char;
  dLen:         longint;
 end =
 (rId:'RIFF'; rLen:0; wId:'WAVE'; fId:'fmt '; fLen:16; wFormatTag:1;
  nChannels:2; nSamplesPerSec:44100; nAvgBytesPerSec:176400;
  nBlockAlign:4;FormatSpecific:16; dId:'data'; dlen:0);

 WBuf:PWriteBuffer;
 WPos:integer;
 WFile:file;

procedure WriteBufferInit(FN:string);
begin
New(WBuf);
AssignFile(WFile,FN);
Rewrite(WFile,1);
WPos := 0
end;

procedure WriteBufferFlush;
begin
if WPos <> 0 then
 begin
  BlockWrite(WFile,WBuf^,WPos);
  WPos := 0
 end
end;

procedure WriteBufferDW(l:DWORD);
begin
if WPos > 32768 - 4 then
 WriteBufferFlush;
DWordPtr(@WBuf[WPos])^ := l;
Inc(WPos,4)
end;

procedure WriteBufferB(b:byte);
begin
if WPos >= 32768 - 1 then
 WriteBufferFlush;
WBuf[WPos] := b;
Inc(WPos)
end;

procedure WriteBufferBuf(p:pointer;sz:integer);
begin
if WPos >= 32768 - sz then
 begin
  WriteBufferFlush;
  BlockWrite(WFile,p^,sz)
 end
else
 begin
  Move(p^,WBuf[WPos],sz);
  Inc(WPos,sz)
 end
end;

procedure WriteBufferClose;
begin
WriteBufferFlush;
CloseFile(WFile);
Dispose(WBuf)
end;

procedure VTX_Header_Editor(var Hdr:TVTXFileHeader;
                            var Title,Author,Programm,Tracker:string);
begin
 with THeaderEditor.Create(Form1) do
  begin
   FrAy := Hdr.ChipFrq;
   FrInt := Hdr.InterFrq;
   ChipChk[0] := (Hdr.Id = $7961);
   ChipChk[1] := not ChipChk[0];
   LoopPos := Hdr.Loop;
   NumOfPos := Hdr.UnpackSize div 14;
   SongName := Title;
   SongAuthor := Author;
   SongProgram := Programm;
   SongTracker := Tracker;
   ChanMode := 1;
   Rus := Russian_Interface;
   Year := Hdr.Year;
   SetParams;
   try
    ShowModal;
    if ModalResult = mrOK then
     begin
      GetParams;
      Hdr.ChipFrq := FrAy;
      Hdr.InterFrq := FrInt;
      if ChipChk[0] then
       Hdr.Id := $7961
      else
       Hdr.Id := $6d79;
      Hdr.Loop := LoopPos;
      Hdr.Mode := ChanMode;
      Hdr.Year := Year;
      Title := SongName;
      Author := SongAuthor;
      Programm := SongProgram;
      Tracker := SongTracker
     end
   finally
    Free
   end
  end
end;

procedure YM6_Header_Editor(var Hdr:TYM5FileHeader; var Title,Author:string);
begin
with THeaderEditor.Create(Form1) do
 begin
  FrAy := Hdr.ChipFrq;
  FrInt := Hdr.InterFrq;
  ChipChk[0] := False;
  ChipChk[1] := True;
  LoopPos := Hdr.Loop;
  NumOfPos := Hdr.Num_of_tiks;
  SongName := Title;
  SongAuthor := Author;
  SongProgram := '';
  SongTracker := '';
  ComboBox1.Enabled := False;
  GroupBox4.Enabled := False;
  ChanMode := 0;
  Rus := Russian_Interface;
  Year := CompilY;
  Edit11.Enabled := False;
  Edit12.Enabled := False;
  Edit13.Enabled := False;
  SetParams;
  try
   ShowModal;
   if ModalResult=mrOK then
    begin
     GetParams;
     Hdr.ChipFrq := FrAy;
     Hdr.InterFrq := FrInt;
     Hdr.Loop := LoopPos;
     Title := SongName;
     Author := SongAuthor
    end
  finally
   Free
  end
 end
end;

procedure ZXAY_Converter;
var
 New_Takt:longword;

 procedure OUT2ZXAY;
 var
  Number_Of_Takts:smallint;
  ZX_Takt,ZX_Takt2:smallint;
  ZX_Port:word;
  ZX_Port_Data:byte;
 begin
  repeat
   UniRead(FileHandle,@ZX_Takt,2);
   UniRead(FileHandle,@ZX_Port,2);
   UniRead(FileHandle,@ZX_Port_Data,1);
   if ZX_Takt = -1 then
    ZX_Takt2 := 0
   else
    ZX_Takt2 := ZX_Takt;
   Number_Of_Takts := ZX_Takt2 - Previous_AY_Takt;
   Previous_AY_Takt := ZX_Takt2;
   if Number_Of_Takts <= 0 then Inc(Number_Of_Takts,17472);
   Inc(New_Takt,Number_Of_Takts);
   if (ZX_Takt<>-1) and ((ZX_Port and PortMask) = ($BFFD and PortMask)) then
    case Current_RegisterAY of
    1,3,5,13:
     ZX_Port_Data := ZX_Port_Data and 15;
    6,8..10:
     ZX_Port_Data := ZX_Port_Data and 31;
    7:
     ZX_Port_Data := ZX_Port_Data and 63
    end;
   if New_Takt >= $100000 then
    begin
     New_Takt := New_Takt and $0fffff;
     if (New_Takt <> 0) or
        ((New_Takt = 0) and (ZX_Takt >= 0) and
         ((ZX_Port and PortMask) <> ($BFFD and PortMask))) or
        ((New_Takt = 0) and (ZX_Takt >= 0) and
         ((ZX_Port and PortMask) = ($BFFD and PortMask)) and
          (Current_RegisterAY >= 14)) or
        ((New_Takt = 0) and (ZX_Takt = -1)) or
        ((New_Takt = 0) and (ZX_Takt >= 0) and
         ((ZX_Port and PortMask) = ($BFFD and PortMask)) and
         (Current_RegisterAY < 13) and
         (RegisterAY.Index[Current_RegisterAY] = ZX_Port_Data)) then
      WriteBufferDW($FFF00000);
    end;
   if (ZX_Takt >= 0) then
    if (ZX_Port and PortMask) = ($FFFD and PortMask) then
     Current_RegisterAY := ZX_Port_Data
    else if ((ZX_Port and PortMask) = ($BFFD and PortMask)) and
            (Current_RegisterAY < 14) and
            ((Current_RegisterAY = 13) or
             (RegisterAY.Index[Current_RegisterAY] <> ZX_Port_Data)) then
     begin
      RegisterAY.Index[Current_RegisterAY] := ZX_Port_Data;
      WriteBufferDW(New_Takt or (Longword(Current_RegisterAY) shl 20) or
                  (Longword(ZX_Port_Data) shl 24))
     end;
   if UniReadersData[FileHandle]^.UniFilePos and $FFF = 0 then
    begin
     ShowProgress(UniReadersData[FileHandle]^.UniFilePos);
     Form1.MessageSkipper
    end
  until May_Quit or (UniReadersData[FileHandle]^.UniFilePos =
                        UniReadersData[FileHandle]^.UniFileSize)
 end;

 procedure EPSG2ZXAY;
 var
  Temp3:integer;
  EPSGRec:packed record
   case Boolean of
   True:(Reg,Data:byte;
         TSt:integer);
   False:(All:int64);
  end;
 begin
  EPSGRec.All := 0;
  Temp3 := -1;
  repeat
   UniRead(FileHandle,@EPSGRec,5);
   with EPSGRec do
    if All = $FFFFFFFFFF then
     begin
      Inc(New_Takt,EPSG_TStateMax - Previous_AY_Takt);
      Previous_AY_Takt := 0;
      if New_Takt >= $100000 then
       begin
        New_Takt := New_Takt and $FFFFF;
        if New_Takt <> 0 then
         begin
          WriteBufferDW($FFF00000);
          Temp3 := 0
         end
       end
     end
    else
     begin
      case Reg of
      1,3,5,13:
       Data := Data and 15;
      6,8..10:
       Data := Data and 31;
      7:
       Data := Data and 63
      end;
      Inc(New_Takt,TSt - Previous_AY_Takt);
      Previous_AY_Takt := TSt;
      if New_Takt >= $100000 then
       begin
        New_Takt := New_Takt and $FFFFF;
        if (New_Takt <> 0) or
           ((New_Takt = 0) and
            ((Reg > 13) or
             ((Reg < 13) and (RegisterAY.Index[Reg] = Data))
            )
           ) then
         begin
          WriteBufferDW($FFF00000);
          Temp3 := 0
         end
       end;
      if (Reg = 13) or
         ((Reg < 13) and (RegisterAY.Index[Reg] <> Data)) then
       begin
        RegisterAY.Index[Reg] := Data;
        WriteBufferDW(New_Takt or (Longword(Reg) shl 20) or
                    (Longword(Data) shl 24));
        Temp3 := New_Takt
       end
    end;
   if UniReadersData[FileHandle]^.UniFilePos and $FFF = 0 then
    begin
     ShowProgress(UniReadersData[FileHandle]^.UniFilePos);
     Form1.MessageSkipper
    end
  until May_Quit or (UniReadersData[FileHandle]^.UniFilePos =
                        UniReadersData[FileHandle]^.UniFileSize);
  if (Temp3 <> -1) and (longword(Temp3) <> New_Takt) then
   WriteBufferDW(New_Takt or (Longword(RegisterAY.Index[0]) shl 24))
 end;

 procedure AY2ZXAY;
 var
  Temp3:integer;
 begin
  OutProc := OutInitialConverter;
  repeat
   WasOuting := -1;
   asm
    mov al,Z80_Registers.IR.LoByte
    inc al
    and al,$7F
    or al,R_Hi_Bit
    mov Z80_Registers.IR.LoByte,al
   end;
   if IFF and not EIorDDorFD and (CurrentTact < IntLength) then
    begin
     IFF := False;
     Dec(Z80_Registers.SP,2);
     WordPointer(@RAM.Index[Z80_Registers.SP])^ := Z80_Registers.PC;
     case IMode of
     2:
      begin
       Z80_Registers.PC := WordPointer(
         @RAM.Index[Z80_Registers.IR.HiByte * 256 + 255])^;
       Inc(New_Takt,18);
       Inc(CurrentTact,18)
      end
     else
      begin
       Z80_Registers.PC := $38;
       Inc(New_Takt,12);
       Inc(CurrentTact,12)
      end
     end
    end
   else
    begin
     EIorDDorFD := False;
     Temp3 := CurrentTact;
     Inc(CurrentTact,Z80_ExecuteCommand);
     Inc(New_Takt,CurrentTact - Temp3);
    end;
   if New_Takt >= $100000 then
    begin
     New_Takt := New_Takt and $0fffff;
     if (New_Takt <> 0) or (WasOuting < 0) then
      WriteBufferDW($FFF00000);
    end;
   if WasOuting >= 0 then
    WriteBufferDW(New_Takt or (longword(WasOuting) shl 20) or
                   (longword(RegisterAY.Index[WasOuting]) shl 24));
   if CurrentTact >= MaxTStates then
    begin
     Dec(CurrentTact,MaxTStates);
     Inc(Global_Tick_Counter);
     if Global_Tick_Counter and 63 = 0 then
      begin
       ShowProgress(Global_Tick_Counter);
       Form1.MessageSkipper
      end
    end
  until (Global_Tick_Counter >= Global_Tick_Max) or May_Quit;
  if (New_Takt <> 0) and (WasOuting < 0) then
   WriteBufferDW(New_Takt or (Longword(RegisterAY.Index[0]) shl 24))
 end;

begin
if Russian_Interface then
 Form1.SaveDialog1.Filter := T_ZXAY
else
 Form1.SaveDialog1.Filter := E_ZXAY;
Form1.SaveDialog1.DefaultExt := '';
Form1.SaveDialog1.FileName := ChangeFileExt(ExtractFileName(
                        PlaylistItems[PlayingItem].FileName),'.zxay');
Form1.SaveDialog1.InitialDir := ExtractFilePath(
                        PlaylistItems[PlayingItem].FileName);
if Form1.SaveDialog1.Execute then
 begin
  Form1.SetFocus;
  WriteBufferInit(Form1.SaveDialog1.FileName);
  InitForAllTypes(True);
  New_Takt := 0;
  try
   WriteBufferDW($5941585A);
   ProgrMax := UniReadersData[FileHandle]^.UniFileSize;
   ShowProgress(0);
   May_Quit := False;
   if UniReadersData[FileHandle].UniFileSize >= 5 then
    case CurFileType of
    OUTFile:
     OUT2ZXAY;
    EPSGFile:
     EPSG2ZXAY;
    AYFile,AYMFile:
     AY2ZXAY
    end;
  finally
   WriteBufferClose
  end;
  ShowProgress(ProgrMax)
 end
end;

procedure WAV_Converter;
var
 FileOut:file;
 LoopTemp:boolean;
 WBuf:packed array[0..32767] of byte;
 BufLenTemp:integer;
begin
if Russian_Interface then
 Form1.SaveDialog1.Filter := 'Аудио файлы (WAV)|*.wav'
else
 Form1.SaveDialog1.Filter := 'Audio files (WAV)|*.wav';
Form1.SaveDialog1.DefaultExt := 'wav';
Form1.SaveDialog1.FileName := ChangeFileExt(ExtractFileName(
                        PLaylistItems[PlayingItem].FileName),'.wav');
Form1.SaveDialog1.InitialDir := ExtractFilePath(
                        PLaylistItems[PlayingItem].FileName);
if Form1.SaveDialog1.Execute then
 begin
  Form1.SetFocus;
  AssignFile(FileOut,Form1.SaveDialog1.FileName);
  Rewrite(FileOut,1);
  Seek(FileOut,SizeOf(WaveFileHeader));
  InitForAllTypes(True);
  with WaveFileHeader do
   begin
    nChannels := NumberOfChannels;
    nSamplesPerSec := SampleRate;
    nBlockAlign := (SampleBit div 8) * NumberOfChannels;
    nAvgBytesPerSec := SampleRate * nBlockAlign;
    FormatSpecific := SampleBit;
    BufLenTemp := BufferLength;
    BufferLength := 32768 div nBlockAlign
   end;
  ProgrMax := round(Time_ms/1000 * SampleRate);
  ShowProgress(VProgrPos);
  LoopTemp := Do_Loop;
  Do_Loop := False;
  repeat
   MakeBuffer(@WBuf);
   Inc(VProgrPos,BuffLen);
   BlockWrite(FileOut,WBuf,BuffLen * WaveFileHeader.nBlockAlign);
   ShowProgress(VProgrPos);
   May_Quit := Real_End;
   Form1.MessageSkipper
  until May_Quit;
  Do_Loop := LoopTemp;
  BufferLength := BufLenTemp;
  Seek(FileOut,0);
  WaveFileHeader.rlen := sizeof(WaveFileHeader) +
                        VProgrPos * WaveFileHeader.nBlockAlign;
  WaveFileHeader.dlen := VProgrPos * WaveFileHeader.nBlockAlign;
  BlockWrite(FileOut,WaveFileHeader,sizeof(WaveFileHeader));
  CloseFile(FileOut);
  ShowProgress(ProgrMax)
 end
end;

procedure PSG_Converter;
var
 Prev_Regs:array[0..13]of byte;
 FF_Counter:integer;
 pos:longword;
 
const
 PSG:array[0..15] of byte =
  ($50,$53,$47,$1a,0,0,0,0,0,0,0,0,0,0,0,0);

 procedure Psg_Save_Ostatok;
 var
  j:dword;
 begin
  if FF_Counter > 0 then
   begin
    j := FF_Counter div 4;
    if j > 0 then
     begin
      while j > 255 do
       begin
        Dec(j,255);
        WriteBufferB($FE);
        WriteBufferB($FF)
       end;
      if j > 0 then
       begin
        WriteBufferB($FE);
        WriteBufferB(j)
       end
     end;
    for j := 1 to FF_Counter mod 4 do
     WriteBufferB($FF);
    FF_Counter := 0
   end
 end;

 procedure PSG_Save_Registers;
 var
  i:word;
 begin
  Inc(FF_Counter);
  for i := 0 to 13 do
   if Prev_Regs[i] <> RegisterAY.Index[i] then
    begin
     Psg_Save_Ostatok;
     Prev_Regs[i] := RegisterAY.Index[i];
     WriteBufferB(i);
     WriteBufferB(RegisterAY.Index[i])
    end;
  Prev_Regs[13] := 255;
  RegisterAY.EnvType := 255
 end;

 procedure OUT2PSG;
 begin
  OUTZXAYConv_TotalTime := IntOffset;
  ProgrMax := round((Time_ms/1000)*(FrqZ80/MaxTStates));
  pos := 0;
  repeat
   OUT_Get_Registers;
   if pos < ProgrMax then PSG_Save_Registers;
   Inc(pos);
   if (pos and 63) = 0 then
    begin
     ShowProgress(pos);
     Form1.MessageSkipper
    end
  until May_Quit or (pos >= ProgrMax);
  PSG_Save_Ostatok
 end;

 procedure ZXAY2PSG;
 begin
  OUTZXAYConv_TotalTime := IntOffset;
  ProgrMax := round((Time_ms/1000)*(FrqZ80/MaxTStates));
  pos := 0;
  repeat
   ZXAY_Get_Registers;
   if pos < ProgrMax then PSG_Save_Registers;
   Inc(pos);
   if (pos and 63) = 0 then
    begin
     ShowProgress(pos);
     Form1.MessageSkipper
    end
  until May_Quit or (pos >= ProgrMax);
  PSG_Save_Ostatok
 end;

 procedure EPSG2PSG;
 begin
  ProgrMax := round((Time_ms/1000)*(FrqZ80/EPSG_TStateMax));
  pos := 0;
  repeat
   EPSG_Get_Registers;
   if pos < ProgrMax then PSG_Save_Registers;
   Inc(pos);
   if (pos and 63) = 0 then
    begin
     ShowProgress(pos);
     Form1.MessageSkipper
    end
  until May_Quit or (pos >= ProgrMax);
  PSG_Save_Ostatok
 end;

 procedure VBL2PSG;
 begin
  ProgrMax :=  Global_Tick_Max;
  repeat
   All_GetRegisters;
   PSG_Save_Registers;
   if (Global_Tick_Counter and 63) = 0 then
    begin
     ShowProgress(Global_Tick_Counter);
     Form1.MessageSkipper
    end
  until (Global_Tick_Counter >= Global_Tick_Max) or May_Quit;
  PSG_Save_Ostatok
 end;

var
 Loop_Save,FNIdent:boolean;
begin
if Russian_Interface then
 Form1.SaveDialog1.Filter := T_PSG
else
 Form1.SaveDialog1.Filter := E_PSG;
Form1.SaveDialog1.DefaultExt := 'psg';
Form1.SaveDialog1.InitialDir := ExtractFilePath(
                        PlaylistItems[PlayingItem].FileName);
Form1.SaveDialog1.FileName := ChangeFileExt(ExtractFileName(
                        PlaylistItems[PlayingItem].FileName),'.psg');
if Form1.SaveDialog1.Execute then
 begin
  Form1.SetFocus;
  Loop_Save := Do_Loop;
  Do_Loop := False;
  InitForAllTypes(True);
  for FF_Counter := 0 to 12 do
   Prev_Regs[FF_Counter] := 0;
  Prev_Regs[13] := 255;
  RegisterAY.EnvType := 255;
  OutProc := OutInitialConverter;
  FNIdent := AnsiLowerCase(PlaylistItems[PlayingItem].FileName) =
                                AnsiLowerCase(Form1.SaveDialog1.FileName);
  if (CurFileType = EPSGFile) and FNIdent then
   WriteBufferInit('Temp8910.$$$')
  else
   WriteBufferInit(Form1.SaveDialog1.FileName);
  May_Quit := False;
  FF_Counter := 0;
  try
   WriteBufferBuf(@PSG,16);
   case CurFileType of
   OUTFile:OUT2PSG;
   ZXAYFile:ZXAY2PSG;
   EPSGFile:EPSG2PSG;
   else VBL2PSG
   end
  finally
   WriteBufferClose
  end;
  if (CurFileType = EPSGFile) and FNIdent then
   begin
    UniReadClose(FileHandle);
    DeleteFile(PlaylistItems[PlayingItem].FileName);
    RenameFile('Temp8910.$$$',PlaylistItems[PlayingItem].FileName);
    UniReadInit(FileHandle,URFile,PlaylistItems[PlayingItem].FileName,nil);
    CurFileType := PSGFile;
    MakeBuffer := MakeBufferPSG;
    All_GetRegisters := PSG_Get_Registers;
    PlaylistItems[PlayingItem]^.Time := pos;
    PlaylistItems[PlayingItem]^.FileType := PSGFile
   end;
  Do_Loop := Loop_Save;
  ShowProgress(ProgrMax)
 end
end;

procedure VTX_Converter;
var
 p:PArrayOfByte;
 bpos:dword;

 procedure VTX_Save_Registers;
 var
  i:word;
  k:dword;
 begin
  k := 0;
  for i := 0 to 13 do
   begin
    p^[bpos + k] := RegisterAY.Index[i];
    Inc(k,ProgrMax)
   end;
  Inc(bpos);
  RegisterAY.EnvType := 255
 end;

 procedure OUT2VTX;
 begin
  OUTZXAYConv_TotalTime := IntOffset;
  repeat
   OUT_Get_Registers;
   if bpos < ProgrMax then VTX_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end
  until May_Quit or (bpos >= ProgrMax)
 end;

 procedure ZXAY2VTX;
 begin
  OUTZXAYConv_TotalTime := IntOffset;
  repeat
   ZXAY_Get_Registers;
   if bpos < ProgrMax then VTX_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end
  until May_Quit or (bpos >= ProgrMax)
 end;

 procedure EPSG2VTX;
 begin
  repeat
   EPSG_Get_Registers;
   if bpos < ProgrMax then VTX_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end;
  until May_Quit or (bpos >= ProgrMax)
 end;

 procedure VBL2VTX;
 begin
  repeat
   All_GetRegisters;
   VTX_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end;
  until (Global_Tick_Counter >= Global_Tick_Max) or May_Quit
 end;

var
 Loop_Save:boolean;
 Y,M,D:word;
 Nam,Aut,Prg,Trk:string;
 VTX_Hdr:TVTXFileHeader;
begin
if Russian_Interface then
 Form1.SaveDialog1.Filter := T_VTX
else
 Form1.SaveDialog1.Filter := E_VTX;
Form1.SaveDialog1.DefaultExt := 'vtx';
Form1.SaveDialog1.InitialDir := ExtractFilePath(
                        PlaylistItems[PlayingItem].FileName);
Form1.SaveDialog1.FileName := ChangeFileExt(ExtractFileName(
                        PlaylistItems[PlayingItem].FileName),'.vtx');
if Form1.SaveDialog1.Execute then
 begin
  Form1.SetFocus;
  Loop_Save := Do_Loop;
  Do_Loop := False;
  InitForAllTypes(True);
  RegisterAY.EnvType := 255;
  OutProc := OutInitialConverter;
  AssignFile(LhaOutFile,Form1.SaveDialog1.FileName);
  Rewrite(LhaOutFile,1);
  May_Quit := False;
  case CurFileType of
  EPSGFile:
   ProgrMax := round((Time_ms/1000)*(FrqZ80/EPSG_TStateMax));
  OUTFile,
  ZXAYFile:
   ProgrMax := round((Time_ms/1000)*(FrqZ80/MaxTStates));
  else
   ProgrMax := Global_Tick_Max;
  end;
  with VTX_Hdr do
   begin
    if ChType = YM_Chip then
     Id := $6d79
    else
     Id := $7961;
    Mode := 1;
    UnpackSize := ProgrMax * 14;
    if LoopVBL > 65535 then
     loop := 65535
    else
     loop := LoopVBL;
    case CurFileType of
    STCFile:
     Trk := PChar_ST;
    ASCFile,
    ASC0File:
     Trk := PChar_ASM;
    PSCFile:
     Trk := PChar_PSC;
    FLSFile:
     Trk := PChar_FLS;
    FTCFile:
     Trk := PChar_FTC;
    STPFile:
     Trk := PChar_STP;
    SQTFile:
     Trk := PChar_SQT;
    PT1File:
     Trk := PChar_PT1;
    PT2File:
     Trk := PChar_PT2;
    PT3File:
     Trk := PChar_PT3;
    GTRFile:
     Trk := PChar_GTR;
    FXMFile:
     Trk := PChar_FXM;
    else
     Trk := '';
    end;
    DecodeDate(Now,Y,M,D);
    Year := Y;
    ChipFrq := AY_Freq;
    if Interrupt_Freq > 255000 then
     InterFrq := 255
    else
     InterFrq := round(Interrupt_Freq/1000)
   end;
  Nam := CurItem.Title;
  Aut := CurItem.Author;
  Prg := CurItem.Programm;
  VTX_Header_Editor(VTX_Hdr,Nam,Aut,Prg,Trk);
  Nam := Nam + #0;
  Aut := Aut + #0;
  Prg := Prg + #0;
  Trk := Trk + #0;
  try
   BlockWrite(LhaOutFile,VTX_Hdr,sizeof(VTX_Hdr));
   BlockWrite(LhaOutFile,Nam[1],Length(Nam));
   BlockWrite(LhaOutFile,Aut[1],Length(Aut));
   BlockWrite(LhaOutFile,Prg[1],Length(Prg));
   BlockWrite(LhaOutFile,Trk[1],Length(Trk));
   BlockWrite(LhaOutFile,YMComment,YMCommentLen + 1);
   bpos := 0;
   GetMem(p,ProgrMax*14);
   case CurFileType of
   OUTFile:OUT2VTX;
   ZXAYFile:ZXAY2VTX;
   EPSGFile:EPSG2VTX
   else VBL2VTX
   end;
   Original_Size := VTX_Hdr.UnpackSize;
   Encode_Buffer_To_File(p);
   FreeMem(p)
  finally
   CloseFile(LhaOutFile)
  end;
  Do_Loop := Loop_Save;
  ShowProgress(ProgrMax)
 end
end;

procedure YM6_Converter;
var
 p:PArrayOfByte;
 bpos:dword;
 bposadd:dword;

 procedure YM6_Save_Registers;
 var
  i:word;
  k:dword;
 begin
  k := bposadd;
  for i := 0 to 13 do
   begin
    p^[bpos + k] := RegisterAY.Index[i];
    Inc(k,ProgrMax)
   end;
  p^[bpos + k] := 0;
  p^[bpos + k + ProgrMax] := 0;
  Inc(bpos);
  RegisterAY.EnvType := 255
 end;

 procedure OUT2YM6;
 begin
  OUTZXAYConv_TotalTime := IntOffset;
  repeat
   OUT_Get_Registers;
   if bpos < ProgrMax then YM6_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end
  until May_Quit or (bpos >= ProgrMax)
 end;

 procedure ZXAY2YM6;
 begin
  OUTZXAYConv_TotalTime := IntOffset;
  repeat
   ZXAY_Get_Registers;
   if bpos < ProgrMax then YM6_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end
  until May_Quit or (bpos >= ProgrMax)
 end;

 procedure EPSG2YM6;
 begin
  repeat
   EPSG_Get_Registers;
   if bpos < ProgrMax then YM6_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end;
  until May_Quit or (bpos >= ProgrMax)
 end;

 procedure VBL2YM6;
 begin
  repeat
   All_GetRegisters;
   YM6_Save_Registers;
   if (bpos and 63) = 0 then
    begin
     ShowProgress(bpos);
     Form1.MessageSkipper
    end;
  until (Global_Tick_Counter >= Global_Tick_Max) or May_Quit
 end;

 function Get_CRC(p:PArrayOfByte;sz:dword):word;
 var
  i,i2:dword;
 begin
  Result := 0;
  for i := 0 to pred(sz) do
   begin
    Result := (Result xor p^[i]);
    for I2 := 1 to 8 do
     if ((Result and 1) <> 0) then
      Result := ((Result shr 1) xor $a001)
     else
      Result := (Result shr 1)
   end
 end;

const
 SFileNameLen = 10;
 SFileName:string = 'AY_Emul.ym';
 YMEnd:array[0..3]of char = 'End!';
var
 i:word;
 i2:byte;
 Loop_Save:boolean;
 Tit,Aut:string;
 YM5_Hdr:TYM5FileHeader;
 LZH_Hdr:TLZHFileHeader;
begin
if CurFileType in [YM5File,YM6File] then exit;
if Russian_Interface then
 Form1.SaveDialog1.Filter := T_YM
else
 Form1.SaveDialog1.Filter := E_YM;
Form1.SaveDialog1.DefaultExt := 'ym';
Form1.SaveDialog1.InitialDir := ExtractFilePath(
                        PlaylistItems[PlayingItem].FileName);
Form1.SaveDialog1.FileName := ChangeFileExt(ExtractFileName(
                        PlaylistItems[PlayingItem].FileName),'.ym');
if Form1.SaveDialog1.Execute then
 begin
  Form1.SetFocus;
  Loop_Save := Do_Loop;
  Do_Loop := False;
  InitForAllTypes(True);
  RegisterAY.EnvType := 255;
  OutProc := OutInitialConverter;
  AssignFile(LhaOutFile,Form1.SaveDialog1.FileName);
  Rewrite(LhaOutFile,1);
  May_Quit := False;
  try
   Seek(LhaOutFile,sizeof(LZH_Hdr));
   BlockWrite(LhaOutFile,SFileName[1],SFileNameLen);
   LZH_Hdr.HSize := sizeof(LZH_Hdr) + SFileNameLen;
   LZH_Hdr.FileNameLen := SFileNameLen;
   Seek(LhaOutFile,LZH_Hdr.HSize + 2);
   case CurFileType of
   EPSGFile:
    ProgrMax := round((Time_ms/1000)*(FrqZ80/EPSG_TStateMax));
   OUTFile,
   ZXAYFile:
    ProgrMax := round((Time_ms/1000)*(FrqZ80/MaxTStates))
   else
    ProgrMax := Global_Tick_Max
   end;
   with YM5_Hdr do
    begin
     Id := $21364d59;
     Leo := 'LeOnArD!';
     Num_of_tiks := ProgrMax;
     Song_Attr := $01000000;
     Num_of_Dig := 0;
     Loop := LoopVBL;
     InterFrq := round(Interrupt_Freq/1000);
     ChipFrq := AY_Freq;
     Add_Size := 0
    end;
   Tit := CurItem.Title;
   Aut := CurItem.Author;
   YM6_Header_Editor(Ym5_Hdr,Tit,Aut);
   Tit := Tit + #0;
   Aut := Aut + #0;
   with YM5_Hdr do
    begin
     Num_of_tiks := IntelDWord(Num_of_tiks);
     ChipFrq := IntelDWord(ChipFrq);
     InterFrq := IntelWord(InterFrq);
     Loop := IntelDWord(Loop)
    end;
   bposadd := sizeof(YM5_Hdr) + longword(Length(Aut) +
                        Length(Tit)) + YMCommentLen + 1;
   bpos := 0;
   Original_Size := ProgrMax*16 + 4 + bposadd;
   GetMem(p,Original_Size);
   case CurFileType of
   OUTFile:
    OUT2YM6;
   ZXAYFile:
    ZXAY2ym6;
   EPSGFile:
    EPSG2YM6
   else
    VBL2YM6
   end;
   Move(YM5_Hdr,p^,sizeof(YM5_Hdr));
   Move(Tit[1],pointer(integer(p) + sizeof(YM5_Hdr))^,Length(Tit));
   Move(Aut[1],p^[sizeof(YM5_Hdr) + Length(Tit)],Length(Aut));
   Move(YMComment,p^[sizeof(YM5_Hdr) + Length(Aut) + Length(Tit)],
                                                        YMCommentLen + 1);
   Move(YMEnd,p^[Original_Size - 4],4);
   Encode_Buffer_To_File(p);
   Seek(LhaOutFile,0);
   LZH_Hdr.UCompSize := Original_Size;
   LZH_Hdr.CompSize := Compressed_Size;
   LZH_Hdr.Method := '-lh5-';
   LZH_Hdr.Attr := $20;
   LZH_Hdr.Dos_DT := (CompilY - 1980) shl 25 or
                     CompilM shl 21 or
                     CompilD shl 16 or
                     VersionMajor shl 11 or
                     VersionMinor shl 5;
   BlockWrite(LhaOutFile,LZH_Hdr,sizeof(LZH_Hdr));
   Seek(LhaOutFile,lZH_hdr.HSize);
   i := Get_CRC(p,Original_Size);
   BlockWrite(LhaOutFile,i,2);
   LZH_Hdr.ChkSum := 0;
   Seek(LhaOutFile,2);
   for i := 0 to Pred(LZH_hdr.HSize) do
    begin
     BlockRead(LhaOutFile,i2,1);
     Inc(LZH_Hdr.ChkSum,i2)
    end;
   Seek(LhaOutFile,1);
   BlockWrite(LhaOutFile,LZH_Hdr.ChkSum,1);
   Seek(LhaOutFile,FileSize(LhaOutFile));
   BlockWrite(LhaOutFile,Zero,1);
   FreeMem(p)
  finally
   CloseFile(LhaOutFile)
  end;
  Do_Loop := Loop_Save;
  ShowProgress(ProgrMax)
 end
end;

end.
