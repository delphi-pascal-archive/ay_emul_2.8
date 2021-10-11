{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit Z80;
interface
const
 IntLength	= 32;
 PortMask       = $c002;
type
 TOutProc = procedure(Prt:word;Dat:byte);
 TInProc = procedure (Prt:word; var Dat:byte);
 WordPointer=^Word;
 Z80_Register=packed record
  case Boolean of
  True :(AllWord:word);
  False:(LoByte,HiByte:byte);
  end;
 PCommonRegisters=^TCommonRegisters;
 TCommonRegisters=record
  HL,DE,BC:Z80_Register;
  end;
 PAF=^TAF;
 TAF=Z80_Register;
var
 MaxTStates:integer;
 CurrentTact:integer; {0..MaxTStates}

 Z80_Registers:record
  Common:PCommonRegisters;
  AF:PAF;
  SP,PC:word;
  IR,IX,IY:Z80_Register;
  end;
 CommonMain,CommonAlt:TCommonRegisters;
 AFMain,AFAlt:TAF;
 PCommonAlt:PCommonRegisters;
 PAFAlt:PAF;
 IFF:boolean;
 EIorDDorFD:boolean;
 IMode:integer;
 R_Hi_Bit:byte;
 AY_CurReg:byte;
 CPCData:byte;
 CPCSwitch:byte;
 WasOuting:integer;
 AYFileEnableAutoSwitch:boolean;
 OutProc:TOutProc;
 InProc:TInProc;
 function Z80_ExecuteCommand:integer;
 procedure InitialOutProc(Prt:word;Dat:byte);
 procedure ZXOutProc(Prt:word;Dat:byte);
 procedure CPCOutProc(Prt:word;Dat:byte);
 procedure InitialInProc(Prt:word; var Dat:byte);
 procedure ZXInProc(Prt:word; var Dat:byte);
 procedure CPCInProc(Prt:word; var Dat:byte);
 procedure OutInitialConverter(Prt:word;Dat:byte);
 procedure OutZXConverter(Prt:word;Dat:byte);
 procedure OutCPCConverter(Prt:word;Dat:byte);
implementation

uses AY, MainWin, Players;

var
 Flg:boolean;

procedure SetFlagsInc;
asm
 pushf
 pop ax
 and eax,$8d0
 mov ecx,eax
 shr ecx,9
 or eax,ecx
 mov edx,Z80_Registers.AF
 mov cl,[edx]
 and cl,1
 or al,cl
 mov [edx],al
end;

procedure  SetFlagsDec;
asm
 pushf
 pop ax
 and eax,$8d0
 mov ecx,eax
 shr ecx,9
 or eax,ecx
 or eax,2
 mov edx,Z80_Registers.AF
 mov cl,[edx]
 and cl,1
 or al,cl
 mov [edx],al
end;

procedure  SetAddHLFlags;
asm
lahf
and ah,1
mov edx,Z80_Registers.AF
mov al,[edx]
and al,$fc
or al,ah
mov [edx],al
end;

procedure  SetAddAFlags;
asm
 pushf
 pop ax
 and eax,$8d1
 mov ecx,eax
 shr ecx,9
 or eax,ecx
 mov edx,Z80_Registers.AF
 mov [edx],al
end;

procedure  SetSubAFlags;
asm
 pushf
 pop ax
 and eax,$8d1
 mov ecx,eax
 shr ecx,9
 or eax,ecx
 mov edx,Z80_Registers.AF
 or al,2
 mov [edx],al
end;

procedure  SetAndFlags;
asm
 lahf
 and ah,$c4
 mov edx,Z80_Registers.AF
 mov al,[edx]
 and al,$28
 or al,ah
 or al,$10
 mov [edx],al
end;

procedure  SetOrFlags;
asm
 lahf
 and ah,$c4
 mov edx,Z80_Registers.AF
 mov al,[edx]
 and al,$28
 or al,ah
 mov [edx],al
end;

procedure  SetRlcFlags;
asm
mov edx,Z80_Registers.AF
lahf
and ah,1
mov cl,ah
and al,al
lahf
and ah,$ec
or cl,ah
mov [edx],cl
end;

procedure  SetSliFlags;
asm
mov edx,Z80_Registers.AF
and ah,1
mov cl,ah
and al,al
lahf
and ah,$ec
or cl,ah
mov [edx],cl
end;

procedure CPCInProc(Prt:word; var Dat:byte);
begin
Dat := 255
end;

procedure ZXInProc(Prt:word; var Dat:byte);
begin
Dat := 255;
if (Prt and  PortMask) = (65533 and PortMask) then
 if AY_CurReg < 14 then
  Dat := RegisterAY.Index[AY_CurReg]
end;

procedure CPCOutProc(Prt:word;Dat:byte);
var
 b:byte;
begin
case Hi(Prt) of
$F4:
 CPCData := Dat;
$F6:
 begin
  b := Dat and $C0;
  if CPCSwitch = 0 then
   CPCSwitch := b
  else if b = 0 then
   begin
    case CPCSwitch of
    $C0:
     AY_CurReg := CPCData;
    $80:
     begin
      if AY_CurReg < 14 then
       begin
        SynthesizerAY;
        if not IntFlag then
         SetAYRegister(AY_CurReg,CPCData)
        else
         begin
          IntAY := True;
          RegNumNext := AY_CurReg;
          DatNext := CPCData
         end
       end
     end
    end;
    CPCSwitch := 0
   end
 end
end
end;

procedure ZXOutProc(Prt:word;Dat:byte);
begin
Flg := False;
if Prt and 1 = 0 then
 begin
  if (Dat and 16 <> 0) then
   BeeperNext := BeeperLevel
  else
   BeeperNext := 0;
  if BeeperNext <> Beeper then
   begin
    SynthesizerAY;
    Flg := True;
    if not IntFlag then
     Beeper := BeeperNext
    else
     IntBeeper := True
   end
 end;
if (Prt and  PortMask) = (65533 and PortMask) then
 AY_CurReg := Dat
else if (Prt and  PortMask) = (49149 and PortMask) then
 if (AY_CurReg < 14) then
  begin
   if not Flg then SynthesizerAY;
   if not IntFlag then
    SetAYRegister(AY_CurReg,Dat)
   else
    begin
     IntAY := True;
     RegNumNext := AY_CurReg;
     DatNext := Dat
    end
  end
end;

procedure InitialOutProc(Prt:word;Dat:byte);
var
 b:byte;
begin
Flg := False;
if Prt and 1 = 0 then
 begin
  if (Dat and 16 <> 0) then
   BeeperNext := BeeperLevel
  else
   BeeperNext := 0;
  if BeeperNext <> Beeper then
   begin
    SynthesizerAY;
    Flg := True;
    if not IntFlag then
     Beeper := BeeperNext
    else
     IntBeeper := True
   end
 end;
case Hi(Prt) of
$F4:
 CPCData := Dat;
$F6:
 begin
  b := Dat and $C0;
  if CPCSwitch = 0 then
   CPCSwitch := b
  else if b = 0 then
   begin
    case CPCSwitch of
    $C0:
     AY_CurReg := CPCData;
    $80:
     begin
      if AY_CurReg < 14 then
       begin
        OutProc := CPCOutProc;
        InProc := CPCInProc;
        if AYFileEnableAutoSwitch then
         Form1.Set_Chip_Frq(1000000);
        IntBeeper := False;
        Beeper := 0;
        if not Flg then SynthesizerAY;
        if not IntFlag then
         SetAYRegister(AY_CurReg,CPCData)
        else
         begin
          IntAY := True;
          RegNumNext := AY_CurReg;
          DatNext := CPCData
         end
       end
     end
    end;
    CPCSwitch := 0
   end
 end;
else if (Prt and  PortMask) = (65533 and PortMask) then
 begin
  OutProc := ZXOutProc;
  InProc := ZXInProc;
  AY_CurReg := Dat
 end
else if (Prt and  PortMask) = (49149 and PortMask) then
 if (AY_CurReg < 14) then
  begin
   OutProc := ZXOutProc;
   InProc := ZXInProc;
   if not Flg then SynthesizerAY;
   if not IntFlag then
    SetAYRegister(AY_CurReg,Dat)
   else
    begin
     IntAY := True;
     RegNumNext := AY_CurReg;
     DatNext := Dat
    end
  end
end
end;

procedure OutCPCConverter(Prt:word;Dat:byte);
var
 b:byte;
begin
case Hi(Prt) of
$F4:
 CPCData := Dat;
$F6:
 begin
  b := Dat and $C0;
  if CPCSwitch = 0 then
   CPCSwitch := b
  else if b = 0 then
   begin
    case CPCSwitch of
    $C0:
      AY_CurReg := CPCData;
    $80:
     begin
      if AY_CurReg < 14 then
       begin
        Case AY_CurReg of
        1, 3, 5, 13:
              b := CPCData and 15;
        6, 8..10:
              b := CPCData and 31;
        7:    b := CPCData and 63;
        else
              b := CPCData;
        end;
        if (AY_CurReg = 13) or (RegisterAY.Index[AY_CurReg] <> b) then
         begin
          WasOuting := AY_CurReg;
          RegisterAY.Index[AY_CurReg] := b
         end;
       end;
     end
    end;
    CPCSwitch := 0
   end
 end
end
end;

procedure OutZXConverter(Prt:word;Dat:byte);
var
 b:byte;
begin
if (Prt and  PortMask) = (65533 and PortMask) then
 AY_CurReg := Dat
else if (Prt and  PortMask) = (49149 and PortMask) then
 if (AY_CurReg < 14) then
  begin
    Case AY_CurReg of
    1, 3, 5, 13:
          b := Dat and 15;
    6, 8..10:
          b := Dat and 31;
    7:    b := Dat and 63;
    else
          b := Dat;
    end;
    if (AY_CurReg = 13) or (RegisterAY.Index[AY_CurReg] <> b) then
     begin
      WasOuting := AY_CurReg;
      RegisterAY.Index[AY_CurReg] := b
     end;
  end
end;

procedure OutInitialConverter(Prt:word;Dat:byte);
var
 b:byte;
begin
case Hi(Prt) of
$F4:
 CPCData := Dat;
$F6:
 begin
  b := Dat and $C0;
  if CPCSwitch = 0 then
   CPCSwitch := b
  else if b = 0 then
   begin
    case CPCSwitch of
    $C0:
      AY_CurReg := CPCData;
    $80:
     begin
      if AY_CurReg < 14 then
       begin
        OutProc := OutCPCConverter;
        InProc := CPCInProc;
        Case AY_CurReg of
        1, 3, 5, 13:
              b := CPCData and 15;
        6, 8..10:
              b := CPCData and 31;
        7:    b := CPCData and 63;
        else
              b := CPCData;
        end;
        if (AY_CurReg = 13) or (RegisterAY.Index[AY_CurReg] <> b) then
         begin
          WasOuting := AY_CurReg;
          RegisterAY.Index[AY_CurReg] := b
         end;
       end;
     end
    end;
    CPCSwitch := 0
   end
 end;
else if (Prt and  PortMask) = (65533 and PortMask) then
 begin
  OutProc := OutZXConverter;
  InProc := ZXInProc;
  AY_CurReg := Dat
 end
else if (Prt and  PortMask) = (49149 and PortMask) then
 if (AY_CurReg < 14) then
  begin
   OutProc := OutZXConverter;
   InProc := ZXInProc;
    Case AY_CurReg of
    1, 3, 5, 13:
          b := Dat and 15;
    6, 8..10:
          b := Dat and 31;
    7:    b := Dat and 63;
    else
          b := Dat;
    end;
    if (AY_CurReg = 13) or (RegisterAY.Index[AY_CurReg] <> b) then
     begin
      WasOuting := AY_CurReg;
      RegisterAY.Index[AY_CurReg] := b
     end;
  end
end
end;

procedure InitialInProc(Prt:word; var Dat:byte);
begin
Dat := 255;
if (Prt and  PortMask) = (65533 and PortMask) then
 if AY_CurReg < 14 then
  Dat := RegisterAY.Index[AY_CurReg]
end;

{#00 NOP}
function m0:integer;
begin
Result:=4;
end;
{#01 LD BC,nn}
function m1:integer;
begin
Z80_Registers.Common.BC.AllWord:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
inc(Z80_Registers.PC,2);
Result:=10;
end;
{#02 LD (BC),A}
function m2:integer;
begin
RAM.Index[Z80_Registers.Common.BC.AllWord]:=Z80_Registers.AF.HiByte;
Result:=7;
end;
{#03 INC BC}
function m3:integer;
begin
inc(Z80_Registers.Common.BC.AllWord);
Result:=6;
end;
{#04 INC B}
function m4:integer;
begin
inc(Z80_Registers.Common.BC.HiByte);
SetFlagsInc;
Result:=4;
end;
{#05 DEC B}
function m5:integer;
begin
dec(Z80_Registers.Common.BC.HiByte);
SetFlagsDec;
Result:=4;
end;
{#06 LD B,n}
function m6:integer;
begin
Z80_Registers.Common.BC.HiByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#07 RLCA}
function m7:integer;
begin
asm
mov edx,Z80_Registers.AF
rol byte ptr [edx+1],1
lahf
and ah,1
mov al,[edx]
and al,$ec
or al,ah
mov [edx],al
end;
Result:=4;
end;
{#08 EX AF,AF'}
function m8:integer;
var Temp:pointer;
begin
Temp:=Z80_Registers.AF;
Z80_Registers.AF:=PAFAlt;
PAFAlt:=Temp;
Result:=4;
end;
{#09 ADD HL,BC}
function m9:integer;
begin
inc(Z80_Registers.Common.HL.AllWord,Z80_Registers.Common.BC.AllWord);
SetAddHLFlags;
Result:=11;
end;
{#0A LD A,(BC)}
function m10:integer;
begin
Z80_Registers.AF.HiByte:=RAM.Index[Z80_Registers.Common.BC.AllWord];
Result:=7;
end;
{#0B DEC BC}
function m11:integer;
begin
dec(Z80_Registers.Common.BC.AllWord);
Result:=6;
end;
{#0C INC C}
function m12:integer;
begin
inc(Z80_Registers.Common.BC.LoByte);
SetFlagsInc;
Result:=4;
end;
{#0D DEC C}
function m13:integer;
begin
dec(Z80_Registers.Common.BC.LoByte);
SetFlagsDec;
Result:=4;
end;
{#0E LD C,n}
function m14:integer;
begin
Z80_Registers.Common.BC.LoByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#0F RRCA}
function m15:integer;
begin
asm
mov edx,Z80_Registers.AF
ror byte ptr [edx+1],1
lahf
and ah,1
mov al,[edx]
and al,$ec
or al,ah
mov [edx],al
end;
Result:=4;
end;
{#10 DJNZ $+e}
function m16:integer;
begin
dec(Z80_Registers.Common.BC.HiByte);
if Z80_Registers.Common.BC.HiByte=0 then
 begin
 inc(Z80_Registers.PC);
 Result:=8;
 end
else
 begin
 inc(Z80_Registers.PC,shortint(RAM.Index[Z80_Registers.PC])+1);
 Result:=13;
 end
end;
{#11 LD DE,nn}
function m17:integer;
begin
Z80_Registers.Common.DE.AllWord:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
inc(Z80_Registers.PC,2);
Result:=10;
end;
{#12 LD (DE),A}
function m18:integer;
begin
RAM.Index[Z80_Registers.Common.DE.AllWord]:=Z80_Registers.AF.HiByte;
Result:=7;
end;
{#13 INC DE}
function m19:integer;
begin
inc(Z80_Registers.Common.DE.AllWord);
Result:=6;
end;
{#14 INC D}
function m20:integer;
begin
inc(Z80_Registers.Common.DE.HiByte);
SetFlagsInc;
Result:=4;
end;
{#15 DEC D}
function m21:integer;
begin
dec(Z80_Registers.Common.DE.HiByte);
SetFlagsDec;
Result:=4;
end;
{#16 LD D,n}
function m22:integer;
begin
Z80_Registers.Common.DE.HiByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#17 RLA}
function m23:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx]
mov ah,al
sahf
rcl byte ptr [edx+1],1
lahf
and ah,1
and al,$ec
or al,ah
mov [edx],al
end;
Result:=4;
end;
{#18 JR $+e}
function m24:integer;
begin
inc(Z80_Registers.PC,shortint(RAM.Index[Z80_Registers.PC])+1);
Result:=12;
end;
{#19 ADD HL,DE}
function m25:integer;
begin
inc(Z80_Registers.Common.HL.AllWord,Z80_Registers.Common.DE.AllWord);
SetAddHLFlags;
Result:=11;
end;
{#1A LD A,(DE)}
function m26:integer;
begin
Z80_Registers.AF.HiByte:=RAM.Index[Z80_Registers.Common.DE.AllWord];
Result:=7;
end;
{#1B DEC DE}
function m27:integer;
begin
dec(Z80_Registers.Common.DE.AllWord);
Result:=6;
end;
{#1C INC E}
function m28:integer;
begin
inc(Z80_Registers.Common.DE.LoByte);
SetFlagsInc;
Result:=4;
end;
{#1D DEC E}
function m29:integer;
begin
dec(Z80_Registers.Common.DE.LoByte);
SetFlagsDec;
Result:=4;
end;
{#1E LD E,n}
function m30:integer;
begin
Z80_Registers.Common.DE.LoByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#1F RRA}
function m31:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx]
mov ah,al
sahf
rcr byte ptr [edx+1],1
lahf
and ah,1
and al,$ec
or al,ah
mov [edx],al
end;
Result:=4;
end;
{#20 JR NZ,$+e}
function m32:integer;
begin
if Z80_Registers.AF.LoByte and $40 <> 0 then
 begin
 inc(Z80_Registers.PC);
 Result:=7;
 end
else
 begin
 inc(Z80_Registers.PC,shortint(RAM.Index[Z80_Registers.PC])+1);
 Result:=12;
 end
end;
{#21 LD HL,nn}
function m33:integer;
begin
Z80_Registers.Common.HL.AllWord:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
inc(Z80_Registers.PC,2);
Result:=10;
end;
{#22 LD (nn),HL}
function m34:integer;
var
 Temp:integer;
begin
Temp:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
WordPointer(@RAM.Index[Temp])^:=Z80_Registers.Common.HL.AllWord;
inc(Z80_Registers.PC,2);
Result:=16;
end;
{#23 INC HL}
function m35:integer;
begin
inc(Z80_Registers.Common.HL.AllWord);
Result:=6;
end;
{#24 INC H}
function m36:integer;
begin
inc(Z80_Registers.Common.HL.HiByte);
SetFlagsInc;
Result:=4;
end;
{#25 DEC H}
function m37:integer;
begin
dec(Z80_Registers.Common.HL.HiByte);
SetFlagsDec;
Result:=4;
end;
{#26 LD H,n}
function m38:integer;
begin
Z80_Registers.Common.HL.HiByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#27 DAA}
function m39:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ax,[edx]
xchg ah,al
mov cl,ah
and cl,2
jnz @aftersub
sahf
daa
jp @m39exit
@aftersub:
sahf
das
@m39exit:
lahf
xchg ah,al
and al,$fd
or al,cl
mov [edx],ax
end;
Result:=4;
end;
{#28 JR Z,$+e}
function m40:integer;
begin
if Z80_Registers.AF.LoByte and $40 = 0 then
 begin
 inc(Z80_Registers.PC);
 Result:=7;
 end
else
 begin
 inc(Z80_Registers.PC,shortint(RAM.Index[Z80_Registers.PC])+1);
 Result:=12;
 end
end;
{#29 ADD HL,HL}
function m41:integer;
begin
inc(Z80_Registers.Common.HL.AllWord,Z80_Registers.Common.HL.AllWord);
SetAddHLFlags;
Result:=11;
end;
{#2A LD HL,(nn)}
function m42:integer;
var
 Temp:integer;
begin
Temp:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
Z80_Registers.Common.HL.AllWord:=WordPointer(@RAM.Index[Temp])^;
inc(Z80_Registers.PC,2);
Result:=16;
end;
{#2B DEC HL}
function m43:integer;
begin
dec(Z80_Registers.Common.HL.AllWord);
Result:=6;
end;
{#2C INC L}
function m44:integer;
begin
inc(Z80_Registers.Common.HL.LoByte);
SetFlagsInc;
Result:=4;
end;
{#2D DEC L}
function m45:integer;
begin
dec(Z80_Registers.Common.HL.LoByte);
SetFlagsDec;
Result:=4;
end;
{#2E LD L,n}
function m46:integer;
begin
Z80_Registers.Common.HL.LoByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#2F CPL}
function m47:integer;
begin
asm
mov edx,Z80_Registers.AF
not byte ptr [edx+1]
or byte ptr [edx],$12
end;
Result:=4;
end;
{#30 JR NC,$+e}
function m48:integer;
begin
if Z80_Registers.AF.LoByte and 1 <> 0 then
 begin
 inc(Z80_Registers.PC);
 Result:=7;
 end
else
 begin
 inc(Z80_Registers.PC,shortint(RAM.Index[Z80_Registers.PC])+1);
 Result:=12;
 end
end;
{#31 LD SP,nn}
function m49:integer;
begin
Z80_Registers.SP:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
inc(Z80_Registers.PC,2);
Result:=10;
end;
{#32 LD (nn),A}
function m50:integer;
var
 Temp:integer;
begin
Temp:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
RAM.Index[Temp]:=Z80_Registers.AF.HiByte;
inc(Z80_Registers.PC,2);
Result:=13;
end;
{#33 INC SP}
function m51:integer;
begin
inc(Z80_Registers.SP);
Result:=6;
end;
{#34 INC (HL)}
function m52:integer;
begin
inc(RAM.Index[Z80_Registers.Common.HL.AllWord]);
SetFlagsInc;
Result:=11;
end;
{#35 DEC (HL}
function m53:integer;
begin
dec(RAM.Index[Z80_Registers.Common.HL.AllWord]);
SetFlagsDec;
Result:=11;
end;
{#36 LD (HL),n}
function m54:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=10;
end;
{#37 SCF}
function m55:integer;
begin
asm
mov edx,Z80_Registers.AF
and byte ptr [edx],$ed
or byte ptr [edx],1
end;
Result:=4;
end;
{#38 JR C,$+e}
function m56:integer;
begin
if Z80_Registers.AF.LoByte and 1 = 0 then
 begin
 inc(Z80_Registers.PC);
 Result:=7;
 end
else
 begin
 inc(Z80_Registers.PC,shortint(RAM.Index[Z80_Registers.PC])+1);
 Result:=12;
 end
end;
{#39 ADD HL,SP}
function m57:integer;
begin
inc(Z80_Registers.Common.HL.AllWord,Z80_Registers.SP);
SetAddHLFlags;
Result:=11;
end;
{#3A LD A,(nn)}
function m58:integer;
var
 Temp:integer;
begin
Temp:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
Z80_Registers.AF.HiByte:=RAM.Index[Temp];
inc(Z80_Registers.PC,2);
Result:=13;
end;
{#3B DEC SP}
function m59:integer;
begin
dec(Z80_Registers.SP);
Result:=6;
end;
{#3C INC A}
function m60:integer;
begin
inc(Z80_Registers.AF.HiByte);
SetFlagsInc;
Result:=4;
end;
{#3D DEC A}
function m61:integer;
begin
dec(Z80_Registers.AF.HiByte);
SetFlagsDec;
Result:=4;
end;
{#3E LD A,n}
function m62:integer;
begin
Z80_Registers.AF.HiByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=7;
end;
{#3F CCF}
function m63:integer;
begin
asm
mov edx,Z80_Registers.AF
and byte ptr [edx],$fd
xor byte ptr [edx],1
end;
Result:=4;
end;
{#40 LD B,B}
function m64:integer;
begin
Result:=4;
end;
{#41 LD B,C}
function m65:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.LoByte;
Result:=4;
end;
{#42 LD B,D}
function m66:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.DE.HiByte;
Result:=4;
end;
{#43 LD B,E}
function m67:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.DE.LoByte;
Result:=4;
end;
{#44 LD B,H}
function m68:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.HL.HiByte;
Result:=4;
end;
{#45 LD B,L}
function m69:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.HL.LoByte;
Result:=4;
end;
{#46 LD B,(HL)}
function m70:integer;
begin
Z80_Registers.Common.BC.HiByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#47 LD B,A}
function m71:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.AF.HiByte;
Result:=4;
end;
{#48 LD C,B}
function m72:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.HiByte;
Result:=4;
end;
{#49 LD C,C}
function m73:integer;
begin
Result:=4;
end;
{#4A LD C,D}
function m74:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.DE.HiByte;
Result:=4;
end;
{#4B LD C,E}
function m75:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.DE.LoByte;
Result:=4;
end;
{#4C LD C,H}
function m76:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.HL.HiByte;
Result:=4;
end;
{#4D LD C,L}
function m77:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.HL.LoByte;
Result:=4;
end;
{#4E LD C,(HL)}
function m78:integer;
begin
Z80_Registers.Common.BC.LoByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#4F LD C,A}
function m79:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.AF.HiByte;
Result:=4;
end;
{#50 LD D,B}
function m80:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.BC.HiByte;
Result:=4;
end;
{#51 LD D,C}
function m81:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.BC.LoByte;
Result:=4;
end;
{#52 LD D,D}
function m82:integer;
begin
Result:=4;
end;
{#53 LD D,E}
function m83:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.LoByte;
Result:=4;
end;
{#54 LD D,H}
function m84:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.HL.HiByte;
Result:=4;
end;
{#55 LD D,L}
function m85:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.HL.LoByte;
Result:=4;
end;
{#56 LD D,(HL)}
function m86:integer;
begin
Z80_Registers.Common.DE.HiByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#57 LD D,A}
function m87:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.AF.HiByte;
Result:=4;
end;
{#58 LD E,B}
function m88:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.BC.HiByte;
Result:=4;
end;
{#59 LD E,C}
function m89:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.BC.LoByte;
Result:=4;
end;
{#5A LD E,D}
function m90:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.HiByte;
Result:=4;
end;
{#5B LD E,E}
function m91:integer;
begin
Result:=4;
end;
{#5C LD E,H}
function m92:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.HL.HiByte;
Result:=4;
end;
{#5D LD E,L}
function m93:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.HL.LoByte;
Result:=4;
end;
{#5E LD E,(HL)}
function m94:integer;
begin
Z80_Registers.Common.DE.LoByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#5F LD E,A}
function m95:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.AF.HiByte;
Result:=4;
end;
{#60 LD H,B}
function m96:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.BC.HiByte;
Result:=4;
end;
{#61 LD H,C}
function m97:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.BC.LoByte;
Result:=4;
end;
{#62 LD H,D}
function m98:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.DE.HiByte;
Result:=4;
end;
{#63 LD H,E}
function m99:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.DE.LoByte;
Result:=4;
end;
{#64 LD H,H}
function m100:integer;
begin
Result:=4;
end;
{#65 LD H,L}
function m101:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.LoByte;
Result:=4;
end;
{#66 LD H,(HL)}
function m102:integer;
begin
Z80_Registers.Common.HL.HiByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#67 LD H,A}
function m103:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.AF.HiByte;
Result:=4;
end;
{#68 LD L,B}
function m104:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.BC.HiByte;
Result:=4;
end;
{#69 LD L,C}
function m105:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.BC.LoByte;
Result:=4;
end;
{#6A LD L,D}
function m106:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.DE.HiByte;
Result:=4;
end;
{#6B LD L,E}
function m107:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.DE.LoByte;
Result:=4;
end;
{#6C LD L,H}
function m108:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.HiByte;
Result:=4;
end;
{#6D LD L,L}
function m109:integer;
begin
Result:=4;
end;
{#6E LD L,(HL)}
function m110:integer;
begin
Z80_Registers.Common.HL.LoByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#6F LD L,A}
function m111:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.AF.HiByte;
Result:=4;
end;
{#70 LD (HL),B}
function m112:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.Common.BC.HiByte;
Result:=7;
end;
{#71 LD (HL),C}
function m113:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.Common.BC.LoByte;
Result:=7;
end;
{#72 LD (HL),D}
function m114:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.Common.DE.HiByte;
Result:=7;
end;
{#73 LD (HL),E}
function m115:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.Common.DE.LoByte;
Result:=7;
end;
{#74 LD (HL),H}
function m116:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.Common.HL.HiByte;
Result:=7;
end;
{#75 LD (HL),L}
function m117:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.Common.HL.LoByte;
Result:=7;
end;
{#76 HALT}
function m118:integer;
var
 temp:integer;
begin
if not IFF then
 begin
  dec(Z80_Registers.PC);
  Result := 4;
 end
else
 begin
  temp := CurrentTact + 4;
  if temp >= MaxTStates then
   dec(temp,MaxTStates);
  if (temp >= IntLength) then
   begin
    Result := MaxTStates - CurrentTact;
    temp := Result and 3;
    if temp <> 0 then
     Result := Result + 4 - temp
   end
  else
   Result := 4;
 end
end;
{#77 LD (HL),A}
function m119:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=Z80_Registers.AF.HiByte;
Result:=7;
end;
{#78 LD A,B}
function m120:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.Common.BC.HiByte;
Result:=4;
end;
{#79 LD A,C}
function m121:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.Common.BC.LoByte;
Result:=4;
end;
{#7A LD A,D}
function m122:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.Common.DE.HiByte;
Result:=4;
end;
{#7B LD A,E}
function m123:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.Common.DE.LoByte;
Result:=4;
end;
{#7C LD A,H}
function m124:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.Common.HL.HiByte;
Result:=4;
end;
{#7D LD A,L}
function m125:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.Common.HL.LoByte;
Result:=4;
end;
{#7E LD A,(HL)}
function m126:integer;
begin
Z80_Registers.AF.HiByte:=RAM.Index[Z80_Registers.Common.HL.AllWord];
Result:=7;
end;
{#7F LD A,A}
function m127:integer;
begin
Result:=4;
end;
{#80 ADD A,B}
function m128:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.Common.BC.HiByte);
SetAddAFlags;
Result:=4;
end;
{#81 ADD A,C}
function m129:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.Common.BC.LoByte);
SetAddAFlags;
Result:=4;
end;
{#82 ADD A,D}
function m130:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.Common.DE.HiByte);
SetAddAFlags;
Result:=4;
end;
{#83 ADD A,E}
function m131:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.Common.DE.LoByte);
SetAddAFlags;
Result:=4;
end;
{#84 ADD A,H}
function m132:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.Common.HL.HiByte);
SetAddAFlags;
Result:=4;
end;
{#85 ADD A,L}
function m133:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.Common.HL.LoByte);
SetAddAFlags;
Result:=4;
end;
{#86 ADD A,(HL)}
function m134:integer;
begin
inc(Z80_Registers.AF.HiByte,RAM.Index[Z80_Registers.Common.HL.AllWord]);
SetAddAFlags;
Result:=7;
end;
{#87 ADD A,A}
function m135:integer;
begin
inc(Z80_Registers.AF.HiByte,Z80_Registers.AF.HiByte);
SetAddAFlags;
Result:=4;
end;
{#88 ADC A,B}
function m136:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 5]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#89 ADC A,C}
function m137:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 4]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#8A ADC A,D}
function m138:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 3]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#8B ADC A,E}
function m139:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 2]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#8C ADC A,H}
function m140:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 1]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#8D ADC A,L}
function m141:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#8E ADC A,(HL)}
function m142:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr RAM.Index[edx]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=7;
end;
{#8F ADC A,A}
function m143:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov al,[edx+1]
adc [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#90 SUB B}
function m144:integer;
begin
dec(Z80_Registers.AF.HiByte,Z80_Registers.Common.BC.HiByte);
SetSubAFlags;
Result:=4;
end;
{#91 SUB C}
function m145:integer;
begin
dec(Z80_Registers.AF.HiByte,Z80_Registers.Common.BC.LoByte);
SetSubAFlags;
Result:=4;
end;
{#92 SUB D}
function m146:integer;
begin
dec(Z80_Registers.AF.HiByte,Z80_Registers.Common.DE.HiByte);
SetSubAFlags;
Result:=4;
end;
{#93 SUB E}
function m147:integer;
begin
dec(Z80_Registers.AF.HiByte,Z80_Registers.Common.DE.LoByte);
SetSubAFlags;
Result:=4;
end;
{#94 SUB H}
function m148:integer;
begin
dec(Z80_Registers.AF.HiByte,Z80_Registers.Common.HL.HiByte);
SetSubAFlags;
Result:=4;
end;
{#95 SUB L}
function m149:integer;
begin
dec(Z80_Registers.AF.HiByte,Z80_Registers.Common.HL.LoByte);
SetSubAFlags;
Result:=4;
end;
{#96 SUB (HL)}
function m150:integer;
begin
dec(Z80_Registers.AF.HiByte,RAM.Index[Z80_Registers.Common.HL.AllWord]);
SetSubAFlags;
Result:=7;
end;
{#97 SUB A}
function m151:integer;
begin
asm
mov edx,Z80_Registers.AF
sub eax,eax
mov [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#98 SBC A,B}
function m152:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 5]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#99 SBC A,C}
function m153:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 4]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#9A SBC A,D}
function m154:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 3]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#9B SBC A,E}
function m155:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 2]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#9C SBC A,H}
function m156:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx + 1]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#9D SBC A,L}
function m157:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,[edx]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=4;
end;
{#9E SBC A,(HL)}
function m158:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr RAM.Index[edx]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=7;
end;
{#9F SBC A,A}
function m159:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov al,[edx+1]
sbb [edx+1],al
end;
SetAddAFlags;
Result:=4;
end;
{#A0 AND B}
function m160:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         Z80_Registers.Common.BC.HiByte;
SetAndFlags;
Result:=4;
end;
{#A1 AND C}
function m161:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         Z80_Registers.Common.BC.LoByte;
SetAndFlags;
Result:=4;
end;
{#A2 AND D}
function m162:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         Z80_Registers.Common.DE.HiByte;
SetAndFlags;
Result:=4;
end;
{#A3 AND E}
function m163:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         Z80_Registers.Common.DE.LoByte;
SetAndFlags;
Result:=4;
end;
{#A4 AND H}
function m164:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         Z80_Registers.Common.HL.HiByte;
SetAndFlags;
Result:=4;
end;
{#A5 AND L}
function m165:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         Z80_Registers.Common.HL.LoByte;
SetAndFlags;
Result:=4;
end;
{#A6 AND (HL)}
function m166:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         RAM.Index[Z80_Registers.Common.HL.AllWord];
SetAndFlags;
Result:=7;
end;
{#A7 AND A}
function m167:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
and al,al
end;
SetAndFlags;
Result:=4;
end;
{#A8 XOR B}
function m168:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         Z80_Registers.Common.BC.HiByte;
SetOrFlags;
Result:=4;
end;
{#A9 XOR C}
function m169:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         Z80_Registers.Common.BC.LoByte;
SetOrFlags;
Result:=4;
end;
{#AA XOR D}
function m170:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         Z80_Registers.Common.DE.HiByte;
SetOrFlags;
Result:=4;
end;
{#AB XOR E}
function m171:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         Z80_Registers.Common.DE.LoByte;
SetOrFlags;
Result:=4;
end;
{#AC XOR H}
function m172:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         Z80_Registers.Common.HL.HiByte;
SetOrFlags;
Result:=4;
end;
{#AD XOR L}
function m173:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         Z80_Registers.Common.HL.LoByte;
SetOrFlags;
Result:=4;
end;
{#AE XOR (HL)}
function m174:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         RAM.Index[Z80_Registers.Common.HL.AllWord];
SetOrFlags;
Result:=7;
end;
{#AF XOR A}
function m175:integer;
begin
asm
xor eax,eax
mov edx,Z80_Registers.AF
mov [edx+1],al
end;
SetOrFlags;
Result:=4;
end;
{#B0 OR B}
function m176:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         Z80_Registers.Common.BC.HiByte;
SetOrFlags;
Result:=4;
end;
{#B1 OR C}
function m177:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         Z80_Registers.Common.BC.LoByte;
SetOrFlags;
Result:=4;
end;
{#B2 OR D}
function m178:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         Z80_Registers.Common.DE.HiByte;
SetOrFlags;
Result:=4;
end;
{#B3 OR E}
function m179:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         Z80_Registers.Common.DE.LoByte;
SetOrFlags;
Result:=4;
end;
{#B4 OR H}
function m180:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         Z80_Registers.Common.HL.HiByte;
SetOrFlags;
Result:=4;
end;
{#B5 OR L}
function m181:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         Z80_Registers.Common.HL.LoByte;
SetOrFlags;
Result:=4;
end;
{#B6 OR (HL)}
function m182:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         RAM.Index[Z80_Registers.Common.HL.AllWord];
SetOrFlags;
Result:=7;
end;
{#B7 OR A}
function m183:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
or al,al
end;
SetOrFlags;
Result:=4;
end;
{#B8 CP B}
function m184:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
sub al,[edx+5]
end;
SetSubAFlags;
Result:=4;
end;
{#B9 CP C}
function m185:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
sub al,[edx+4]
end;
SetSubAFlags;
Result:=4;
end;
{#BA CP D}
function m186:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
sub al,[edx+3]
end;
SetSubAFlags;
Result:=4;
end;
{#BB CP E}
function m187:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
sub al,[edx+2]
end;
SetSubAFlags;
Result:=4;
end;
{#BC CP H}
function m188:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
sub al,[edx+1]
end;
SetSubAFlags;
Result:=4;
end;
{#BD CP L}
function m189:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
sub al,[edx]
end;
SetSubAFlags;
Result:=4;
end;
{#BE CP (HL)}
function m190:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx + 1]
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
sub al,byte ptr [RAM + edx]
end;
SetSubAFlags;
Result:=7;
end;
{#BF CP A}
function m191:integer;
begin
asm
sub eax,eax
end;
SetSubAFlags;
Result:=4;
end;
{#C0 RET NZ}
function m192:integer;
begin
if Z80_Registers.AF.LoByte and $40 = 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#C1 POP BC}
function m193:integer;
begin
Z80_Registers.Common.BC.AllWord:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=10;
end;
{#C2 JP NZ,nn}
function m194:integer;
begin
if Z80_Registers.AF.LoByte and $40 = 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#C3 JP nn}
function m195:integer;
begin
Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
Result:=10;
end;
{#C4 CALL NZ,nn}
function m196:integer;
begin
if Z80_Registers.AF.LoByte and $40 = 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#C5 PUSH BC}
function m197:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.Common.BC.AllWord;
Result:=11;
end;
{#C6 ADD A,n}
function m198:integer;
begin
inc(Z80_Registers.AF.HiByte,RAM.Index[Z80_Registers.PC]);
SetAddAFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#C7 RST 0}
function m199:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=0;
Result:=11;
end;
{#C8 RET Z}
function m200:integer;
begin
if Z80_Registers.AF.LoByte and $40 <> 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#C9 RET}
function m201:integer;
begin
Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=10;
end;
{#CA JP Z,nn}
function m202:integer;
begin
if Z80_Registers.AF.LoByte and $40 <> 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#CC CALL Z,nn}
function m204:integer;
begin
if Z80_Registers.AF.LoByte and $40 <> 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#CD CALL nn}
function m205:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
Result:=17;
end;
{#CE ADC A,n}
function m206:integer;
begin
asm
movzx edx,Z80_Registers.PC
mov al,byte ptr RAM.Index[edx]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#CF RST 8}
function m207:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=8;
Result:=11;
end;
{#D0 RET NC}
function m208:integer;
begin
if Z80_Registers.AF.LoByte and 1 = 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#D1 POP DE}
function m209:integer;
begin
Z80_Registers.Common.DE.AllWord:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=10;
end;
{#D2 JP NC,nn}
function m210:integer;
begin
if Z80_Registers.AF.LoByte and 1 = 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#D3 OUT (N),A}
function m211:integer;
begin
inc(CurrentTact,12);
OutProc((word(Z80_Registers.AF.HiByte) shl 8) or RAM.Index[Z80_Registers.PC],
                Z80_Registers.AF.HiByte);
inc(Z80_Registers.PC);
Result := 0;
end;
{#D4 CALL NC,nn}
function m212:integer;
begin
if Z80_Registers.AF.LoByte and 1 = 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#D5 PUSH DE}
function m213:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.Common.DE.AllWord;
Result:=11;
end;
{#D6 SUB n}
function m214:integer;
begin
dec(Z80_Registers.AF.HiByte,RAM.Index[Z80_Registers.PC]);
SetSubAFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#D7 RST 16}
function m215:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=16;
Result:=11;
end;
{#D8 RET C}
function m216:integer;
begin
if Z80_Registers.AF.LoByte and 1 <> 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#D9 EXX}
function m217:integer;
Var
 Temp:pointer;
begin
Temp:=Z80_Registers.Common;
Z80_Registers.Common:=PCommonAlt;
PCommonAlt:=Temp;
Result:=4;
end;
{#DA JP C,nn}
function m218:integer;
begin
if Z80_Registers.AF.LoByte and 1 <> 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#DB IN A,(N)}
function m219:integer;
begin
InProc((word(Z80_Registers.AF.HiByte) shl 8) or RAM.Index[Z80_Registers.PC],
                Z80_Registers.AF.HiByte);
inc(Z80_Registers.PC);
Result:=11;
end;
{#DC CALL C,nn}
function m220:integer;
begin
if Z80_Registers.AF.LoByte and 1 <> 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^ := Z80_Registers.PC + 2;
 Z80_Registers.PC := WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result := 17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#DE SBC A,n}
function m222:integer;
begin
asm
movzx edx,Z80_Registers.PC
mov al,byte ptr RAM.Index[edx]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#DF RST 24}
function m223:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=24;
Result:=11;
end;
{#E0 RET PO}
function m224:integer;
begin
if Z80_Registers.AF.LoByte and 4 = 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#E1 POP HL}
function m225:integer;
begin
Z80_Registers.Common.HL.AllWord:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=10;
end;
{#E2 JP PO,nn}
function m226:integer;
begin
if Z80_Registers.AF.LoByte and 4 = 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#E3 EX (SP),HL}
function m227:integer;
var
 Temp:word;
 WP:WordPointer;
begin
WP := @RAM.Index[Z80_Registers.SP];
Temp := WP^;
WP^ := Z80_Registers.Common.HL.AllWord;
Z80_Registers.Common.HL.AllWord := Temp;
Result:=19;
end;
{#E4 CALL PO,nn}
function m228:integer;
begin
if Z80_Registers.AF.LoByte and 4 = 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#E5 PUSH HL}
function m229:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.Common.HL.AllWord;
Result:=11;
end;
{#E6 AND n}
function m230:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         RAM.Index[Z80_Registers.PC];
SetAndFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#E7 RST 32}
function m231:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=32;
Result:=11;
end;
{#E8 RET PE}
function m232:integer;
begin
if Z80_Registers.AF.LoByte and 4 <> 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#E9 JP (HL)}
function m233:integer;
begin
Z80_Registers.PC:=Z80_Registers.Common.HL.AllWord;
Result:=4;
end;
{#EA JP PE,nn}
function m234:integer;
begin
if Z80_Registers.AF.LoByte and 4 <> 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#EB EX DE,HL}
function m235:integer;
var
 Temp:word;
begin
Temp:=Z80_Registers.Common.HL.AllWord;
Z80_Registers.Common.HL.AllWord:=Z80_Registers.Common.DE.AllWord;
Z80_Registers.Common.DE.AllWord:=Temp;
Result:=4;
end;
{#EC CALL PE,nn}
function m236:integer;
begin
if Z80_Registers.AF.LoByte and 4 <> 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#EE XOR n}
function m238:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         RAM.Index[Z80_Registers.PC];
SetOrFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#EF RST 40}
function m239:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=40;
Result:=11;
end;
{#F0 RET P}
function m240:integer;
begin
if Z80_Registers.AF.LoByte and $80 = 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#F1 POP AF}
function m241:integer;
begin
Z80_Registers.AF.AllWord:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=10;
end;
{#F2 JP P,nn}
function m242:integer;
begin
if Z80_Registers.AF.LoByte and $80 = 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#F3 DI}
function m243:integer;
begin
IFF := False;
Result:=4;
end;
{#F4 CALL P,nn}
function m244:integer;
begin
if Z80_Registers.AF.LoByte and $80 = 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#F5 PUSH AF}
function m245:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.AF.AllWord;
Result:=11;
end;
{#F6 OR n}
function m246:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         RAM.Index[Z80_Registers.PC];
SetOrFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#F7 RST 48}
function m247:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=48;
Result:=11;
end;
{#F8 RET M}
function m248:integer;
begin
if Z80_Registers.AF.LoByte and $80 <> 0 then
 begin
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
 inc(Z80_Registers.SP,2);
 Result:=11;
 end
else
 Result:=5;
end;
{#F9 LD SP,HL}
function m249:integer;
begin
Z80_Registers.SP:=Z80_Registers.Common.HL.AllWord;
Result:=6;
end;
{#FA JP M,nn}
function m250:integer;
begin
if Z80_Registers.AF.LoByte and $80 <> 0 then
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^
else
 inc(Z80_Registers.PC,2);
Result:=10;
end;
{#FB EI}
function m251:integer;
begin
IFF := True;
EIorDDorFD := True;
Result:=4;
end;
{#FC CALL M,nn}
function m252:integer;
begin
if Z80_Registers.AF.LoByte and $80 <> 0 then
 begin
 dec(Z80_Registers.SP,2);
 WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC+2;
 Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
 Result:=17;
 end
else
 begin
 inc(Z80_Registers.PC,2);
 Result:=10;
 end;
end;
{#FE CP n}
function m254:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx + 1]
movzx edx,Z80_Registers.PC
sub al,byte ptr [RAM + edx]
end;
SetSubAFlags;
inc(Z80_Registers.PC);
Result:=7;
end;
{#FF RST 56}
function m255:integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=Z80_Registers.PC;
Z80_Registers.PC:=56;
Result:=11;
end;

{#CB #00 RLC B}
function c0:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
rol al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #01 RLC C}
function c1:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
rol al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #02 RLC D}
function c2:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
rol al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #03 RLC E}
function c3:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
rol al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #04 RLC H}
function c4:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
rol al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #05 RLC L}
function c5:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
rol al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #06 RLC (HL)}
function c6:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
rol al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #07 RLC A}
function c7:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,byte ptr [edx+1]
rol al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #08 RRC B}
function c8:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
ror al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #09 RRC C}
function c9:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
ror al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #0A RRC D}
function c10:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
ror al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #0B RRC E}
function c11:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
ror al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #0C RRC H}
function c12:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
ror al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #0D RRC L}
function c13:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
ror al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #0E RRC (HL)}
function c14:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
ror al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #0F RRC A}
function c15:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,byte ptr [edx+1]
ror al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #10 RL B}
function c16:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
rcl al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #11 RL C}
function c17:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
rcl al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #12 RL D}
function c18:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
rcl al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #13 RL E}
function c19:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
rcl al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #14 RL H}
function c20:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
rcl al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #15 RL L}
function c21:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
rcl al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #16 RL (HL)}
function c22:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
sahf
mov al,byte ptr [RAM + edx]
rcl al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #17 RL A}
function c23:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov al,byte ptr [edx+1]
rcl al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #18 RR B}
function c24:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
rcr al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #19 RR C}
function c25:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
rcr al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #1A RR D}
function c26:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
rcr al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #1B RR E}
function c27:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
rcr al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #1C RR H}
function c28:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
rcr al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #1D RR L}
function c29:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
rcr al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #1E RR (HL)}
function c30:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
rcr al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #1F RR A}
function c31:integer;
begin
asm
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
mov al,byte ptr [edx+1]
rcr al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #20 SLA B}
function c32:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
shl al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #21 SLA C}
function c33:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
shl al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #22 SLA D}
function c34:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
shl al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #23 SLA E}
function c35:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
shl al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #24 SLA H}
function c36:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
shl al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #25 SLA L}
function c37:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
shl al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #26 SLA (HL)}
function c38:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
shl al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #27 SLA A}
function c39:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,byte ptr [edx+1]
shl al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #28 SRA B}
function c40:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
sar al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #29 SRA C}
function c41:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
sar al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #2A SRA D}
function c42:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
sar al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #2B SRA E}
function c43:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
sar al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #2C SRA H}
function c44:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
sar al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #2D SRA L}
function c45:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
sar al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #2E SRA (HL)}
function c46:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
sar al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #2F SRA A}
function c47:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,byte ptr [edx+1]
sar al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #30 SLI B}
function c48:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
shl al,1
lahf
inc al
mov byte ptr [edx+5],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #31 SLI C}
function c49:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
shl al,1
lahf
inc al
mov byte ptr [edx+4],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #32 SLI D}
function c50:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
shl al,1
lahf
inc al
mov byte ptr [edx+3],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #33 SLI E}
function c51:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
shl al,1
lahf
inc al
mov byte ptr [edx+2],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #34 SLI H}
function c52:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
shl al,1
lahf
inc al
mov byte ptr [edx+1],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #35 SLI L}
function c53:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
shl al,1
lahf
inc al
mov byte ptr [edx],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #36 SLI (HL)}
function c54:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
shl al,1
lahf
inc al
mov byte ptr [RAM + edx],al
end;
SetSliFlags;
Result:=15;
end;
{#CB #37 SLI A}
function c55:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,byte ptr [edx+1]
shl al,1
lahf
inc al
mov byte ptr [edx+1],al
end;
SetSliFlags;
Result:=8;
end;
{#CB #38 SRL B}
function c56:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+5]
shr al,1
mov byte ptr [edx+5],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #39 SRL C}
function c57:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+4]
shr al,1
mov byte ptr [edx+4],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #3A SRL D}
function c58:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+3]
shr al,1
mov byte ptr [edx+3],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #3B SRL E}
function c59:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+2]
shr al,1
mov byte ptr [edx+2],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #3C SRL H}
function c60:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx+1]
shr al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #3D SRL L}
function c61:integer;
begin
asm
mov edx,Z80_Registers.Common
mov al,byte ptr [edx]
shr al,1
mov byte ptr [edx],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #3E SRL (HL)}
function c62:integer;
begin
asm
mov edx,Z80_Registers.Common
movzx edx,word ptr [edx]
mov al,byte ptr [RAM + edx]
shr al,1
mov byte ptr [RAM + edx],al
end;
SetRlcFlags;
Result:=15;
end;
{#CB #3F SRL A}
function c63:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,byte ptr [edx+1]
shr al,1
mov byte ptr [edx+1],al
end;
SetRlcFlags;
Result:=8;
end;
{#CB #40 BIT 0,B}
function c64:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #41 BIT 0,C}
function c65:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #42 BIT 0,D}
function c66:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #43 BIT 0,E}
function c67:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #44 BIT 0,H}
function c68:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #45 BIT 0,L}
function c69:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #46 BIT 0,(HL)}
function c70:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #47 BIT 0,A}
function c71:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #48 BIT 1,B}
function c72:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #49 BIT 1,C}
function c73:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #4A BIT 1,D}
function c74:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #4B BIT 1,E}
function c75:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #4C BIT 1,H}
function c76:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #4D BIT 1,L}
function c77:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #4E BIT 1,(HL)}
function c78:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #4F BIT 1,A}
function c79:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #50 BIT 2,B}
function c80:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #51 BIT 2,C}
function c81:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #52 BIT 2,D}
function c82:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #53 BIT 2,E}
function c83:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #54 BIT 2,H}
function c84:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #55 BIT 2,L}
function c85:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #56 BIT 2,(HL)}
function c86:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #57 BIT 2,A}
function c87:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #58 BIT 3,B}
function c88:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #59 BIT 3,C}
function c89:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #5A BIT 3,D}
function c90:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #5B BIT 3,E}
function c91:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #5C BIT 3,H}
function c92:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #5D BIT 3,L}
function c93:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #5E BIT 3,(HL)}
function c94:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #5F BIT 3,A}
function c95:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #60 BIT 4,B}
function c96:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #61 BIT 4,C}
function c97:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #62 BIT 4,D}
function c98:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #63 BIT 4,E}
function c99:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #64 BIT 4,H}
function c100:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #65 BIT 4,L}
function c101:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #66 BIT 4,(HL)}
function c102:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #67 BIT 4,A}
function c103:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #68 BIT 5,B}
function c104:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #69 BIT 5,C}
function c105:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #6A BIT 5,D}
function c106:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #6B BIT 5,E}
function c107:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #6C BIT 5,H}
function c108:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #6D BIT 5,L}
function c109:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #6E BIT 5,(HL)}
function c110:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #6F BIT 5,A}
function c111:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #70 BIT 6,B}
function c112:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #71 BIT 6,C}
function c113:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #72 BIT 6,D}
function c114:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #73 BIT 6,E}
function c115:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #74 BIT 6,H}
function c116:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #75 BIT 6,L}
function c117:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #76 BIT 6,(HL)}
function c118:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #77 BIT 6,A}
function c119:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #78 BIT 7,B}
function c120:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.HiByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #79 BIT 7,C}
function c121:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.BC.LoByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #7A BIT 7,D}
function c122:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.HiByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #7B BIT 7,E}
function c123:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.DE.LoByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #7C BIT 7,H}
function c124:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.HiByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #7D BIT 7,L}
function c125:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.Common.HL.LoByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #7E BIT 7,(HL)}
function c126:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[Z80_Registers.Common.HL.AllWord] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=15;
end;
{#CB #7F BIT 7,A}
function c127:integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If Z80_Registers.AF.HiByte and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=8;
end;
{#CB #80 RES 0,B}
function c128:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $fe;
Result:=8;
end;
{#CB #81 RES 0,C}
function c129:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $fe;
Result:=8;
end;
{#CB #82 RES 0,D}
function c130:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $fe;
Result:=8;
end;
{#CB #83 RES 0,E}
function c131:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $fe;
Result:=8;
end;
{#CB #84 RES 0,H}
function c132:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $fe;
Result:=8;
end;
{#CB #85 RES 0,L}
function c133:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $fe;
Result:=8;
end;
{#CB #86 RES 0,(HL)}
function c134:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $fe;
Result:=15;
end;
{#CB #87 RES 0,A}
function c135:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $fe;
Result:=8;
end;
{#CB #88 RES 1,B}
function c136:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $fd;
Result:=8;
end;
{#CB #89 RES 1,C}
function c137:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $fd;
Result:=8;
end;
{#CB #8A RES 1,D}
function c138:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $fd;
Result:=8;
end;
{#CB #8B RES 1,E}
function c139:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $fd;
Result:=8;
end;
{#CB #8C RES 1,H}
function c140:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $fd;
Result:=8;
end;
{#CB #8D RES 1,L}
function c141:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $fd;
Result:=8;
end;
{#CB #8E RES 1,(HL)}
function c142:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $fd;
Result:=15;
end;
{#CB #8F RES 1,A}
function c143:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $fd;
Result:=8;
end;
{#CB #90 RES 2,B}
function c144:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $fb;
Result:=8;
end;
{#CB #91 RES 2,C}
function c145:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $fb;
Result:=8;
end;
{#CB #92 RES 2,D}
function c146:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $fb;
Result:=8;
end;
{#CB #93 RES 2,E}
function c147:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $fb;
Result:=8;
end;
{#CB #94 RES 2,H}
function c148:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $fb;
Result:=8;
end;
{#CB #95 RES 2,L}
function c149:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $fb;
Result:=8;
end;
{#CB #96 RES 2,(HL)}
function c150:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $fb;
Result:=15;
end;
{#CB #97 RES 2,A}
function c151:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $fb;
Result:=8;
end;
{#CB #98 RES 3,B}
function c152:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $f7;
Result:=8;
end;
{#CB #99 RES 3,C}
function c153:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $f7;
Result:=8;
end;
{#CB #9A RES 3,D}
function c154:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $f7;
Result:=8;
end;
{#CB #9B RES 3,E}
function c155:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $f7;
Result:=8;
end;
{#CB #9C RES 3,H}
function c156:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $f7;
Result:=8;
end;
{#CB #9D RES 3,L}
function c157:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $f7;
Result:=8;
end;
{#CB #9E RES 3,(HL)}
function c158:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $f7;
Result:=15;
end;
{#CB #9F RES 3,A}
function c159:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $f7;
Result:=8;
end;
{#CB #A0 RES 4,B}
function c160:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $ef;
Result:=8;
end;
{#CB #A1 RES 4,C}
function c161:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $ef;
Result:=8;
end;
{#CB #A2 RES 4,D}
function c162:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $ef;
Result:=8;
end;
{#CB #A3 RES 4,E}
function c163:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $ef;
Result:=8;
end;
{#CB #A4 RES 4,H}
function c164:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $ef;
Result:=8;
end;
{#CB #A5 RES 4,L}
function c165:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $ef;
Result:=8;
end;
{#CB #A6 RES 4,(HL)}
function c166:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $ef;
Result:=15;
end;
{#CB #A7 RES 4,A}
function c167:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $ef;
Result:=8;
end;
{#CB #A8 RES 5,B}
function c168:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $df;
Result:=8;
end;
{#CB #A9 RES 5,C}
function c169:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $df;
Result:=8;
end;
{#CB #AA RES 5,D}
function c170:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $df;
Result:=8;
end;
{#CB #AB RES 5,E}
function c171:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $df;
Result:=8;
end;
{#CB #AC RES 5,H}
function c172:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $df;
Result:=8;
end;
{#CB #AD RES 5,L}
function c173:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $df;
Result:=8;
end;
{#CB #AE RES 5,(HL)}
function c174:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $df;
Result:=15;
end;
{#CB #AF RES 5,A}
function c175:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $df;
Result:=8;
end;
{#CB #B0 RES 6,B}
function c176:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $bf;
Result:=8;
end;
{#CB #B1 RES 6,C}
function c177:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $bf;
Result:=8;
end;
{#CB #B2 RES 6,D}
function c178:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $bf;
Result:=8;
end;
{#CB #B3 RES 6,E}
function c179:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $bf;
Result:=8;
end;
{#CB #B4 RES 6,H}
function c180:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $bf;
Result:=8;
end;
{#CB #B5 RES 6,L}
function c181:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $bf;
Result:=8;
end;
{#CB #B6 RES 6,(HL)}
function c182:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $bf;
Result:=15;
end;
{#CB #B7 RES 6,A}
function c183:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $bf;
Result:=8;
end;
{#CB #B8 RES 7,B}
function c184:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte and $7f;
Result:=8;
end;
{#CB #B9 RES 7,C}
function c185:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte and $7f;
Result:=8;
end;
{#CB #BA RES 7,D}
function c186:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte and $7f;
Result:=8;
end;
{#CB #BB RES 7,E}
function c187:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte and $7f;
Result:=8;
end;
{#CB #BC RES 7,H}
function c188:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte and $7f;
Result:=8;
end;
{#CB #BD RES 7,L}
function c189:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte and $7f;
Result:=8;
end;
{#CB #BE RES 7,(HL)}
function c190:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] and $7f;
Result:=15;
end;
{#CB #BF RES 7,A}
function c191:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and $7f;
Result:=8;
end;
{#CB #C0 SET 0,B}
function c192:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 1;
Result:=8;
end;
{#CB #C1 SET 0,C}
function c193:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 1;
Result:=8;
end;
{#CB #C2 SET 0,D}
function c194:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 1;
Result:=8;
end;
{#CB #C3 SET 0,E}
function c195:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 1;
Result:=8;
end;
{#CB #C4 SET 0,H}
function c196:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 1;
Result:=8;
end;
{#CB #C5 SET 0,L}
function c197:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 1;
Result:=8;
end;
{#CB #C6 SET 0,(HL)}
function c198:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 1;
Result:=15;
end;
{#CB #C7 SET 0,A}
function c199:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 1;
Result:=8;
end;
{#CB #C8 SET 1,B}
function c200:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 2;
Result:=8;
end;
{#CB #C9 SET 1,C}
function c201:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 2;
Result:=8;
end;
{#CB #CA SET 1,D}
function c202:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 2;
Result:=8;
end;
{#CB #CB SET 1,E}
function c203:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 2;
Result:=8;
end;
{#CB #CC SET 1,H}
function c204:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 2;
Result:=8;
end;
{#CB #CD SET 1,L}
function c205:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 2;
Result:=8;
end;
{#CB #CE SET 1,(HL)}
function c206:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 2;
Result:=15;
end;
{#CB #CF SET 1,A}
function c207:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 2;
Result:=8;
end;
{#CB #D0 SET 2,B}
function c208:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 4;
Result:=8;
end;
{#CB #D1 SET 2,C}
function c209:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 4;
Result:=8;
end;
{#CB #D2 SET 2,D}
function c210:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 4;
Result:=8;
end;
{#CB #D3 SET 2,E}
function c211:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 4;
Result:=8;
end;
{#CB #D4 SET 2,H}
function c212:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 4;
Result:=8;
end;
{#CB #D5 SET 2,L}
function c213:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 4;
Result:=8;
end;
{#CB #D6 SET 2,(HL)}
function c214:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 4;
Result:=15;
end;
{#CB #D7 SET 2,A}
function c215:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 4;
Result:=8;
end;
{#CB #D8 SET 3,B}
function c216:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 8;
Result:=8;
end;
{#CB #D9 SET 3,C}
function c217:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 8;
Result:=8;
end;
{#CB #DA SET 3,D}
function c218:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 8;
Result:=8;
end;
{#CB #DB SET 3,E}
function c219:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 8;
Result:=8;
end;
{#CB #DC SET 3,H}
function c220:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 8;
Result:=8;
end;
{#CB #DD SET 3,L}
function c221:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 8;
Result:=8;
end;
{#CB #DE SET 3,(HL)}
function c222:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 8;
Result:=15;
end;
{#CB #DF SET 3,A}
function c223:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 8;
Result:=8;
end;
{#CB #E0 SET 4,B}
function c224:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 16;
Result:=8;
end;
{#CB #E1 SET 4,C}
function c225:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 16;
Result:=8;
end;
{#CB #E2 SET 4,D}
function c226:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 16;
Result:=8;
end;
{#CB #E3 SET 4,E}
function c227:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 16;
Result:=8;
end;
{#CB #E4 SET 4,H}
function c228:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 16;
Result:=8;
end;
{#CB #E5 SET 4,L}
function c229:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 16;
Result:=8;
end;
{#CB #E6 SET 4,(HL)}
function c230:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 16;
Result:=15;
end;
{#CB #E7 SET 4,A}
function c231:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 16;
Result:=8;
end;
{#CB #E8 SET 5,B}
function c232:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 32;
Result:=8;
end;
{#CB #E9 SET 5,C}
function c233:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 32;
Result:=8;
end;
{#CB #EA SET 5,D}
function c234:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 32;
Result:=8;
end;
{#CB #EB SET 5,E}
function c235:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 32;
Result:=8;
end;
{#CB #EC SET 5,H}
function c236:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 32;
Result:=8;
end;
{#CB #ED SET 5,L}
function c237:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 32;
Result:=8;
end;
{#CB #EE SET 5,(HL)}
function c238:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 32;
Result:=15;
end;
{#CB #EF SET 5,A}
function c239:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 32;
Result:=8;
end;
{#CB #F0 SET 6,B}
function c240:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 64;
Result:=8;
end;
{#CB #F1 SET 6,C}
function c241:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 64;
Result:=8;
end;
{#CB #F2 SET 6,D}
function c242:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 64;
Result:=8;
end;
{#CB #F3 SET 6,E}
function c243:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 64;
Result:=8;
end;
{#CB #F4 SET 6,H}
function c244:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 64;
Result:=8;
end;
{#CB #F5 SET 6,L}
function c245:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 64;
Result:=8;
end;
{#CB #F6 SET 6,(HL)}
function c246:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 64;
Result:=15;
end;
{#CB #F7 SET 6,A}
function c247:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 64;
Result:=8;
end;
{#CB #F8 SET 7,B}
function c248:integer;
begin
Z80_Registers.Common.BC.HiByte:=Z80_Registers.Common.BC.HiByte or 128;
Result:=8;
end;
{#CB #F9 SET 7,C}
function c249:integer;
begin
Z80_Registers.Common.BC.LoByte:=Z80_Registers.Common.BC.LoByte or 128;
Result:=8;
end;
{#CB #FA SET 7,D}
function c250:integer;
begin
Z80_Registers.Common.DE.HiByte:=Z80_Registers.Common.DE.HiByte or 128;
Result:=8;
end;
{#CB #FB SET 7,E}
function c251:integer;
begin
Z80_Registers.Common.DE.LoByte:=Z80_Registers.Common.DE.LoByte or 128;
Result:=8;
end;
{#CB #FC SET 7,H}
function c252:integer;
begin
Z80_Registers.Common.HL.HiByte:=Z80_Registers.Common.HL.HiByte or 128;
Result:=8;
end;
{#CB #FD SET 7,L}
function c253:integer;
begin
Z80_Registers.Common.HL.LoByte:=Z80_Registers.Common.HL.LoByte or 128;
Result:=8;
end;
{#CB #FE SET 7,(HL)}
function c254:integer;
begin
RAM.Index[Z80_Registers.Common.HL.AllWord]:=
                   RAM.Index[Z80_Registers.Common.HL.AllWord] or 128;
Result:=15;
end;
{#CB #FF SET 7,A}
function c255:integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or 128;
Result:=8;
end;

{#ED #00 *NOP*}
function e0:integer;
begin
Result:=8;
end;
{#ED #01 *NOP*}
function e1:integer;
begin
Result:=8;
end;
{#ED #02 *NOP*}
function e2:integer;
begin
Result:=8;
end;
{#ED #03 *NOP*}
function e3:integer;
begin
Result:=8;
end;
{#ED #04 *NOP*}
function e4:integer;
begin
Result:=8;
end;
{#ED #05 *NOP*}
function e5:integer;
begin
Result:=8;
end;
{#ED #06 *NOP*}
function e6:integer;
begin
Result:=8;
end;
{#ED #07 *NOP*}
function e7:integer;
begin
Result:=8;
end;
{#ED #08 *NOP*}
function e8:integer;
begin
Result:=8;
end;
{#ED #09 *NOP*}
function e9:integer;
begin
Result:=8;
end;
{#ED #0A *NOP*}
function e10:integer;
begin
Result:=8;
end;
{#ED #0B *NOP*}
function e11:integer;
begin
Result:=8;
end;
{#ED #0C *NOP*}
function e12:integer;
begin
Result:=8;
end;
{#ED #0D *NOP*}
function e13:integer;
begin
Result:=8;
end;
{#ED #0E *NOP*}
function e14:integer;
begin
Result:=8;
end;
{#ED #0F *NOP*}
function e15:integer;
begin
Result:=8;
end;
{#ED #10 *NOP*}
function e16:integer;
begin
Result:=8;
end;
{#ED #11 *NOP*}
function e17:integer;
begin
Result:=8;
end;
{#ED #12 *NOP*}
function e18:integer;
begin
Result:=8;
end;
{#ED #13 *NOP*}
function e19:integer;
begin
Result:=8;
end;
{#ED #14 *NOP*}
function e20:integer;
begin
Result:=8;
end;
{#ED #15 *NOP*}
function e21:integer;
begin
Result:=8;
end;
{#ED #16 *NOP*}
function e22:integer;
begin
Result:=8;
end;
{#ED #17 *NOP*}
function e23:integer;
begin
Result:=8;
end;
{#ED #18 *NOP*}
function e24:integer;
begin
Result:=8;
end;
{#ED #19 *NOP*}
function e25:integer;
begin
Result:=8;
end;
{#ED #1A *NOP*}
function e26:integer;
begin
Result:=8;
end;
{#ED #1B *NOP*}
function e27:integer;
begin
Result:=8;
end;
{#ED #1C *NOP*}
function e28:integer;
begin
Result:=8;
end;
{#ED #1D *NOP*}
function e29:integer;
begin
Result:=8;
end;
{#ED #1E *NOP*}
function e30:integer;
begin
Result:=8;
end;
{#ED #1F *NOP*}
function e31:integer;
begin
Result:=8;
end;
{#ED #20 *NOP*}
function e32:integer;
begin
Result:=8;
end;
{#ED #21 *NOP*}
function e33:integer;
begin
Result:=8;
end;
{#ED #22 *NOP*}
function e34:integer;
begin
Result:=8;
end;
{#ED #23 *NOP*}
function e35:integer;
begin
Result:=8;
end;
{#ED #24 *NOP*}
function e36:integer;
begin
Result:=8;
end;
{#ED #25 *NOP*}
function e37:integer;
begin
Result:=8;
end;
{#ED #26 *NOP*}
function e38:integer;
begin
Result:=8;
end;
{#ED #27 *NOP*}
function e39:integer;
begin
Result:=8;
end;
{#ED #28 *NOP*}
function e40:integer;
begin
Result:=8;
end;
{#ED #29 *NOP*}
function e41:integer;
begin
Result:=8;
end;
{#ED #2A *NOP*}
function e42:integer;
begin
Result:=8;
end;
{#ED #2B *NOP*}
function e43:integer;
begin
Result:=8;
end;
{#ED #2C *NOP*}
function e44:integer;
begin
Result:=8;
end;
{#ED #2D *NOP*}
function e45:integer;
begin
Result:=8;
end;
{#ED #2E *NOP*}
function e46:integer;
begin
Result:=8;
end;
{#ED #2F *NOP*}
function e47:integer;
begin
Result:=8;
end;
{#ED #30 *NOP*}
function e48:integer;
begin
Result:=8;
end;
{#ED #31 *NOP*}
function e49:integer;
begin
Result:=8;
end;
{#ED #32 *NOP*}
function e50:integer;
begin
Result:=8;
end;
{#ED #33 *NOP*}
function e51:integer;
begin
Result:=8;
end;
{#ED #34 *NOP*}
function e52:integer;
begin
Result:=8;
end;
{#ED #35 *NOP*}
function e53:integer;
begin
Result:=8;
end;
{#ED #36 *NOP*}
function e54:integer;
begin
Result:=8;
end;
{#ED #37 *NOP*}
function e55:integer;
begin
Result:=8;
end;
{#ED #38 *NOP*}
function e56:integer;
begin
Result:=8;
end;
{#ED #39 *NOP*}
function e57:integer;
begin
Result:=8;
end;
{#ED #3A *NOP*}
function e58:integer;
begin
Result:=8;
end;
{#ED #3B *NOP*}
function e59:integer;
begin
Result:=8;
end;
{#ED #3C *NOP*}
function e60:integer;
begin
Result:=8;
end;
{#ED #3D *NOP*}
function e61:integer;
begin
Result:=8;
end;
{#ED #3E *NOP*}
function e62:integer;
begin
Result:=8;
end;
{#ED #3F *NOP*}
function e63:integer;
begin
Result:=8;
end;
{#ED #40 IN B,(C)}
function e64:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.BC.HiByte);
{not made}
Result:=12;
end;
{#ED #41 OUT (C),B}
function e65:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.BC.HiByte);
Result := 0;
end;
{#ED #42 SBC HL,BC}
function e66:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,[edx+4]
sbb [edx],ax
end;
SetSubAFlags;
Result:=15;
end;
{#ED #43 LD (nn),BC}
function e67:integer;
begin
WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^:=
                Z80_Registers.Common.BC.AllWord;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #44 NEG}
function e68:integer;
begin
Z80_Registers.AF.HiByte:=-Z80_Registers.AF.HiByte;
SetSubAFlags;
Result:=8;
end;
{#ED #45 RETN}
function e69:integer;
begin
Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=14;
end;
{#ED #46 IM0}
function e70:integer;
begin
IMode := 0;
Result:=8;
end;
{#ED #47 LD I,A}
function e71:integer;
begin
Z80_Registers.IR.HiByte:=Z80_Registers.AF.HiByte;
Result:=9;
end;
{#ED #48 IN C,(C)}
function e72:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.BC.LoByte);
{not made}
Result:=12;
end;
{#ED #49 OUT (C),C}
function e73:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.BC.LoByte);
Result := 0;
end;
{#ED #4A ADC HL,BC}
function e74:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,[edx+4]
adc [edx],ax
end;
SetAddAFlags;
Result:=15;
end;
{#ED #4B LD BC,(nn)}
function e75:integer;
begin
Z80_Registers.Common.BC.AllWord:=
    WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #4C *NOP*}
function e76:integer;
begin
Result:=8;
end;
{#ED #4D RETI}
function e77:integer;
begin
Z80_Registers.PC:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=14;
end;
{#ED #4E *IM0*}
function e78:integer;
begin
IMode := 0;
Result:=8;
end;
{#ED #4F LD R,A}
function e79:integer;
begin
R_Hi_Bit := Z80_Registers.AF.HiByte and 128;
Z80_Registers.IR.LoByte:=Z80_Registers.AF.HiByte;
Result:=9;
end;
{#ED #50 IN D,(C)}
function e80:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.DE.HiByte);
{not made}
Result:=12;
end;
{#ED #51 OUT (C),D}
function e81:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.DE.HiByte);
Result := 0;
end;
{#ED #52 SBC HL,DE}
function e82:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,[edx+2]
sbb [edx],ax
end;
SetSubAFlags;
Result:=15;
end;
{#ED #53 LD (nn),DE}
function e83:integer;
begin
WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^:=
                Z80_Registers.Common.DE.AllWord;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #54 *NOP*}
function e84:integer;
begin
Result:=8;
end;
{#ED #55 *NOP*}
function e85:integer;
begin
Result:=8;
end;
{#ED #56 IM1}
function e86:integer;
begin
IMode := 1;
Result:=8;
end;
{#ED #57 LD A,I}
function e87:integer;
var
 t:byte;
begin
t := Z80_Registers.IR.HiByte;
Z80_Registers.AF.HiByte := t;
if t <> 0 then
 t := t and $A8
else
 t := t or $40;
t := t or (Z80_Registers.AF.LoByte and 1);
if IFF then
 t := t or 4;
Z80_Registers.AF.LoByte := t;
Result:=9;
end;
{#ED #58 IN E,(C)}
function e88:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.DE.LoByte);
{not made}
Result:=12;
end;
{#ED #59 OUT (C),E}
function e89:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.DE.LoByte);
Result := 0;
end;
{#ED #5A ADC HL,DE}
function e90:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,[edx+2]
adc [edx],ax
end;
SetAddAFlags;
Result:=15;
end;
{#ED #5B LD DE,(nn)}
function e91:integer;
begin
Z80_Registers.Common.DE.AllWord:=
    WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #5C *NOP*}
function e92:integer;
begin
Result:=8;
end;
{#ED #5D *NOP*}
function e93:integer;
begin
Result:=8;
end;
{#ED #5E IM2}
function e94:integer;
begin
IMode := 2;
Result:=8;
end;
{#ED #5F LD A,R}
function e95:integer;
var
 t:byte;
begin
t := Z80_Registers.IR.LoByte;
Z80_Registers.AF.HiByte := t;
if t <> 0 then
 t := t and $A8
else
 t := t or $40;
t := t or (Z80_Registers.AF.LoByte and 1);
if IFF then
 t := t or 4;
Z80_Registers.AF.LoByte := t;
Result:=9;
end;
{#ED #60 IN H,(C)}
function e96:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.HL.HiByte);
{not made}
Result:=12;
end;
{#ED #61 OUT (C),H}
function e97:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.HL.HiByte);
Result := 0;
end;
{#ED #62 SBC HL,HL}
function e98:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,[edx]
sbb [edx],ax
end;
SetSubAFlags;
Result:=15;
end;
{#ED #63 LD (nn),HL}
function e99:integer;
begin
WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^:=
                Z80_Registers.Common.HL.AllWord;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #64 *NOP*}
function e100:integer;
begin
Result:=8;
end;
{#ED #65 *NOP*}
function e101:integer;
begin
Result:=8;
end;
{#ED #66 *IM0*}
function e102:integer;
begin
IMode := 0;
Result:=8;
end;
{#ED #67 RRD}
function e103:integer;
var
 temp,temp2:byte;
begin
temp:=RAM.Index[Z80_Registers.Common.HL.AllWord];
temp2:=temp and 15;
RAM.Index[Z80_Registers.Common.HL.AllWord]:=(temp shr 4) or
                 (Z80_Registers.AF.HiByte shl 4);
Z80_Registers.AF.HiByte:=temp2;
{not made}
Result:=18;
end;
{#ED #68 IN L,(C)}
function e104:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.HL.LoByte);
{not made}
Result:=12;
end;
{#ED #69 OUT (C),L}
function e105:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.Common.HL.LoByte);
Result := 0;
end;
{#ED #6A ADC HL,HL}
function e106:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,[edx]
adc [edx],ax
end;
SetAddAFlags;
Result:=15;
end;
{#ED #6B LD HL,(nn)}
function e107:integer;
begin
Z80_Registers.Common.HL.AllWord:=
        WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #6C *NOP*}
function e108:integer;
begin
Result:=8;
end;
{#ED #6D *NOP*}
function e109:integer;
begin
Result:=8;
end;
{#ED #6E *IM0*}
function e110:integer;
begin
IMode := 0;
Result:=8;
end;
{#ED #6F RLD}
function e111:integer;
var
 temp,temp2:byte;
begin
temp:=RAM.Index[Z80_Registers.Common.HL.AllWord];
temp2:=temp shr 4;
RAM.Index[Z80_Registers.Common.HL.AllWord]:=(temp shl 4) or
                 (Z80_Registers.AF.HiByte and 15);
Z80_Registers.AF.HiByte:=temp2;
{not made}
Result:=18;
end;
{#ED #70 IN (HL),(C)}
function e112:integer;
begin
{not made}
Result:=12;
end;
{#ED #71 *NOP*}
function e113:integer;
begin
Result:=8;
end;
{#ED #72 SBC HL,SP}
function e114:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,word ptr (Z80_Registers[8]) {SP :(((}
sbb [edx],ax
end;
SetSubAFlags;
Result:=15;
end;
{#ED #73 LD (nn),SP}
function e115:integer;
begin
WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^:=
        Z80_Registers.SP;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #74 *NOP*}
function e116:integer;
begin
Result:=8;
end;
{#ED #75 *NOP*}
function e117:integer;
begin
Result:=8;
end;
{#ED #76 *IM1*}
function e118:integer;
begin
IMode := 1;
Result:=8;
end;
{#ED #77 *NOP*}
function e119:integer;
begin
Result:=8;
end;
{#ED #78 IN A,(C)}
function e120:integer;
begin
InProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.AF.HiByte);
{not made}
Result:=12;
end;
{#ED #79 OUT (C),A}
function e121:integer;
begin
inc(CurrentTact,12);
OutProc(Z80_Registers.Common.BC.AllWord,Z80_Registers.AF.HiByte);
Result := 0;
end;
{#ED #7A ADC HL,SP}
function e122:integer;
begin
asm
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
mov edx,Z80_Registers.Common
mov ax,word ptr (Z80_Registers[8]) {SP :(((}
adc [edx],ax
end;
SetAddAFlags;
Result:=15;
end;
{#ED #7B LD SP,(nn)}
function e123:integer;
begin
Z80_Registers.SP:=
        WordPointer(@RAM.Index[WordPointer(@RAM.Index[Z80_Registers.PC])^])^;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#ED #7C *NOP*}
function e124:integer;
begin
Result:=8;
end;
{#ED #7D *NOP*}
function e125:integer;
begin
Result:=8;
end;
{#ED #7E *IM2*}
function e126:integer;
begin
IMode := 2;
Result:=8;
end;
{#ED #7F *NOP*}
function e127:integer;
begin
Result:=8;
end;
{#ED #80 *NOP*}
function e128:integer;
begin
Result:=8;
end;
{#ED #81 *NOP*}
function e129:integer;
begin
Result:=8;
end;
{#ED #82 *NOP*}
function e130:integer;
begin
Result:=8;
end;
{#ED #83 *NOP*}
function e131:integer;
begin
Result:=8;
end;
{#ED #84 *NOP*}
function e132:integer;
begin
Result:=8;
end;
{#ED #85 *NOP*}
function e133:integer;
begin
Result:=8;
end;
{#ED #86 *NOP*}
function e134:integer;
begin
Result:=8;
end;
{#ED #87 *NOP*}
function e135:integer;
begin
Result:=8;
end;
{#ED #88 *NOP*}
function e136:integer;
begin
Result:=8;
end;
{#ED #89 *NOP*}
function e137:integer;
begin
Result:=8;
end;
{#ED #8A *NOP*}
function e138:integer;
begin
Result:=8;
end;
{#ED #8B *NOP*}
function e139:integer;
begin
Result:=8;
end;
{#ED #8C *NOP*}
function e140:integer;
begin
Result:=8;
end;
{#ED #8D *NOP*}
function e141:integer;
begin
Result:=8;
end;
{#ED #8E *NOP*}
function e142:integer;
begin
Result:=8;
end;
{#ED #8F *NOP*}
function e143:integer;
begin
Result:=8;
end;
{#ED #90 *NOP*}
function e144:integer;
begin
Result:=8;
end;
{#ED #91 *NOP*}
function e145:integer;
begin
Result:=8;
end;
{#ED #92 *NOP*}
function e146:integer;
begin
Result:=8;
end;
{#ED #93 *NOP*}
function e147:integer;
begin
Result:=8;
end;
{#ED #94 *NOP*}
function e148:integer;
begin
Result:=8;
end;
{#ED #95 *NOP*}
function e149:integer;
begin
Result:=8;
end;
{#ED #96 *NOP*}
function e150:integer;
begin
Result:=8;
end;
{#ED #97 *NOP*}
function e151:integer;
begin
Result:=8;
end;
{#ED #98 *NOP*}
function e152:integer;
begin
Result:=8;
end;
{#ED #99 *NOP*}
function e153:integer;
begin
Result:=8;
end;
{#ED #9A *NOP*}
function e154:integer;
begin
Result:=8;
end;
{#ED #9B *NOP*}
function e155:integer;
begin
Result:=8;
end;
{#ED #9C *NOP*}
function e156:integer;
begin
Result:=8;
end;
{#ED #9D *NOP*}
function e157:integer;
begin
Result:=8;
end;
{#ED #9E *NOP*}
function e158:integer;
begin
Result:=8;
end;
{#ED #9F *NOP*}
function e159:integer;
begin
Result:=8;
end;
{#ED #A0 LDI}
function e160:integer;
begin
RAM.Index[Z80_Registers.Common.DE.AllWord]:=
                RAM.Index[Z80_Registers.Common.HL.AllWord];
inc(Z80_Registers.Common.DE.AllWord);
inc(Z80_Registers.Common.HL.AllWord);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $e9;
dec(Z80_Registers.Common.BC.AllWord);
if Z80_Registers.Common.BC.AllWord <> 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or 4;
Result:=16;
end;
{#ED #A1 CPI}
function e161:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx+1]
mov edx,Z80_Registers.Common
movzx ecx,word ptr [edx]
inc word ptr [edx]
sub al,byte ptr [RAM + ecx]
lahf
mov ecx,Z80_Registers.AF
mov al,[ecx]
and ah,$d0
or al,ah
or al,2
and al,$fb
dec word ptr [edx+4]
jz @cpiexit
or al,4
@cpiexit:
mov [ecx],al
end;
Result:=16;
end;
{#ED #A2 INI}
function e162:integer;
begin
{not made}
Result:=16;
end;
{#ED #A3 OUTI}
function e163:integer;
begin
inc(CurrentTact,16);
OutProc(Z80_Registers.Common.BC.AllWord,
        RAM.Index[Z80_Registers.Common.HL.AllWord]);
inc(Z80_Registers.Common.HL.AllWord);
dec(Z80_Registers.Common.BC.HiByte);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $42;
if Z80_Registers.Common.BC.HiByte<>0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $bf;
Result := 0;
end;
{#ED #A4 *NOP*}
function e164:integer;
begin
Result:=8;
end;
{#ED #A5 *NOP*}
function e165:integer;
begin
Result:=8;
end;
{#ED #A6 *NOP*}
function e166:integer;
begin
Result:=8;
end;
{#ED #A7 *NOP*}
function e167:integer;
begin
Result:=8;
end;
{#ED #A8 LDD}
function e168:integer;
begin
RAM.Index[Z80_Registers.Common.DE.AllWord]:=
        RAM.Index[Z80_Registers.Common.HL.AllWord];
dec(Z80_Registers.Common.DE.AllWord);
dec(Z80_Registers.Common.HL.AllWord);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $e9;
dec(Z80_Registers.Common.BC.AllWord);
if Z80_Registers.Common.BC.AllWord <> 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or 4;
Result:=16;
end;
{#ED #A9 CPD}
function e169:integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[edx + 1]
mov edx,Z80_Registers.Common
movzx ecx,word ptr [edx]
dec word ptr [edx]
sub al,byte ptr [RAM + ecx]
lahf
mov ecx,Z80_Registers.AF
mov al,[ecx]
and ah,$d0
or al,ah
or al,2
and al,$fb
dec word ptr [edx+4]
jz @cpiexit
or al,4
@cpiexit:
mov [ecx],al
end;
Result:=16;
end;
{#ED #AA IND}
function e170:integer;
begin
{not made}
Result:=16;
end;
{#ED #AB OUTD}
function e171:integer;
begin
inc(CurrentTact,16);
OutProc(Z80_Registers.Common.BC.AllWord,
        RAM.Index[Z80_Registers.Common.HL.AllWord]);
dec(Z80_Registers.Common.HL.AllWord);
dec(Z80_Registers.Common.BC.HiByte);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $42;
if Z80_Registers.Common.BC.HiByte<>0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $bf;
Result := 0;
end;
{#ED #AC *NOP*}
function e172:integer;
begin
Result:=8;
end;
{#ED #AD *NOP*}
function e173:integer;
begin
Result:=8;
end;
{#ED #AE *NOP*}
function e174:integer;
begin
Result:=8;
end;
{#ED #AF *NOP*}
function e175:integer;
begin
Result:=8;
end;
{#ED #B0 LDIR}
function e176:integer;
begin
RAM.Index[Z80_Registers.Common.DE.AllWord]:=
        RAM.Index[Z80_Registers.Common.HL.AllWord];
inc(Z80_Registers.Common.DE.AllWord);
inc(Z80_Registers.Common.HL.AllWord);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $e9;
dec(Z80_Registers.Common.BC.AllWord);
if Z80_Registers.Common.BC.AllWord <> 0 then
 begin
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or 4;
 dec(Z80_Registers.PC,2);
 Result:=21;
 end
else
 Result:=16;
end;
{#ED #B1 CPIR}
function e177:integer;
asm
mov edx,Z80_Registers.AF
mov al,[edx + 1]
mov edx,Z80_Registers.Common
movzx ecx,word ptr [edx]
inc word ptr [edx]
sub al,byte ptr [RAM + ecx]
lahf
mov ecx,Z80_Registers.AF
mov al,[ecx]
and ah,$d0
or al,ah
or al,2
and al,$fb
dec word ptr [edx+4]
jz @cpirexit
or al,4
mov [ecx],al
sahf
jz @cpirexit2
sub Z80_Registers.PC,2
mov eax,21
ret
@cpirexit:
mov [ecx],al
@cpirexit2:
mov eax,16
end;
{#ED #B2 INIR}
function e178:integer;
begin
{not made}
Result:=16;
end;
{#ED #B3 OTIR}
function e179:integer;
begin
inc(CurrentTact,15);
OutProc(Z80_Registers.Common.BC.AllWord,
        RAM.Index[Z80_Registers.Common.HL.AllWord]);
inc(Z80_Registers.Common.HL.AllWord);
dec(Z80_Registers.Common.BC.HiByte);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $42;
if Z80_Registers.Common.BC.HiByte<>0 then
 begin
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $bf;
 dec(Z80_Registers.PC,2);
 Result := 21 - 15;
 end
else
 Result:=0;
end;
{#ED #B4 *NOP*}
function e180:integer;
begin
Result:=8;
end;
{#ED #B5 *NOP*}
function e181:integer;
begin
Result:=8;
end;
{#ED #B6 *NOP*}
function e182:integer;
begin
Result:=8;
end;
{#ED #B7 *NOP*}
function e183:integer;
begin
Result:=8;
end;
{#ED #B8 LDDR}
function e184:integer;
begin
RAM.Index[Z80_Registers.Common.DE.AllWord]:=
        RAM.Index[Z80_Registers.Common.HL.AllWord];
dec(Z80_Registers.Common.DE.AllWord);
dec(Z80_Registers.Common.HL.AllWord);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $e9;
dec(Z80_Registers.Common.BC.AllWord);
if Z80_Registers.Common.BC.AllWord <> 0 then
 begin
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or 4;
 dec(Z80_Registers.PC,2);
 Result:=21;
 end
else
 Result:=16;
end;
{#ED #B9 CPDR}
function e185:integer;
asm
mov edx,Z80_Registers.AF
mov al,[edx + 1]
mov edx,Z80_Registers.Common
movzx ecx,word ptr [edx]
dec word ptr [edx]
sub al,byte ptr [RAM + ecx]
lahf
mov ecx,Z80_Registers.AF
mov al,[ecx]
and ah,$d0
or al,ah
or al,2
and al,$fb
dec word ptr [edx+4]
jz @cpirexit
or al,4
mov [ecx],al
sahf
jz @cpirexit2
sub Z80_Registers.PC,2
mov eax,21
ret
@cpirexit:
mov [ecx],al
@cpirexit2:
mov eax,16
end;
{#ED #BA INDR}
function e186:integer;
begin
{not made}
Result:=16;
end;
{#ED #BB OTDR}
function e187:integer;
begin
inc(CurrentTact,15);
OutProc(Z80_Registers.Common.BC.AllWord,
        RAM.Index[Z80_Registers.Common.HL.AllWord]);
dec(Z80_Registers.Common.HL.AllWord);
dec(Z80_Registers.Common.BC.HiByte);
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $42;
if Z80_Registers.Common.BC.HiByte<>0 then
 begin
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $bf;
 dec(Z80_Registers.PC,2);
 Result := 21 - 15;
 end
else
 Result := 0;
end;
{#ED #BC *NOP*}
function e188:integer;
begin
Result:=8;
end;
{#ED #BD *NOP*}
function e189:integer;
begin
Result:=8;
end;
{#ED #BE *NOP*}
function e190:integer;
begin
Result:=8;
end;
{#ED #BF *NOP*}
function e191:integer;
begin
Result:=8;
end;
{#ED #C0 *NOP*}
function e192:integer;
begin
Result:=8;
end;
{#ED #C1 *NOP*}
function e193:integer;
begin
Result:=8;
end;
{#ED #C2 *NOP*}
function e194:integer;
begin
Result:=8;
end;
{#ED #C3 *NOP*}
function e195:integer;
begin
Result:=8;
end;
{#ED #C4 *NOP*}
function e196:integer;
begin
Result:=8;
end;
{#ED #C5 *NOP*}
function e197:integer;
begin
Result:=8;
end;
{#ED #C6 *NOP*}
function e198:integer;
begin
Result:=8;
end;
{#ED #C7 *NOP*}
function e199:integer;
begin
Result:=8;
end;
{#ED #C8 *NOP*}
function e200:integer;
begin
Result:=8;
end;
{#ED #C9 *NOP*}
function e201:integer;
begin
Result:=8;
end;
{#ED #CA *NOP*}
function e202:integer;
begin
Result:=8;
end;
{#ED #CB *NOP*}
function e203:integer;
begin
Result:=8;
end;
{#ED #CC *NOP*}
function e204:integer;
begin
Result:=8;
end;
{#ED #CD *NOP*}
function e205:integer;
begin
Result:=8;
end;
{#ED #CE *NOP*}
function e206:integer;
begin
Result:=8;
end;
{#ED #CF *NOP*}
function e207:integer;
begin
Result:=8;
end;
{#ED #D0 *NOP*}
function e208:integer;
begin
Result:=8;
end;
{#ED #D1 *NOP*}
function e209:integer;
begin
Result:=8;
end;
{#ED #D2 *NOP*}
function e210:integer;
begin
Result:=8;
end;
{#ED #D3 *NOP*}
function e211:integer;
begin
Result:=8;
end;
{#ED #D4 *NOP*}
function e212:integer;
begin
Result:=8;
end;
{#ED #D5 *NOP*}
function e213:integer;
begin
Result:=8;
end;
{#ED #D6 *NOP*}
function e214:integer;
begin
Result:=8;
end;
{#ED #D7 *NOP*}
function e215:integer;
begin
Result:=8;
end;
{#ED #D8 *NOP*}
function e216:integer;
begin
Result:=8;
end;
{#ED #D9 *NOP*}
function e217:integer;
begin
Result:=8;
end;
{#ED #DA *NOP*}
function e218:integer;
begin
Result:=8;
end;
{#ED #DB *NOP*}
function e219:integer;
begin
Result:=8;
end;
{#ED #DC *NOP*}
function e220:integer;
begin
Result:=8;
end;
{#ED #DD *NOP*}
function e221:integer;
begin
Result:=8;
end;
{#ED #DE *NOP*}
function e222:integer;
begin
Result:=8;
end;
{#ED #DF *NOP*}
function e223:integer;
begin
Result:=8;
end;
{#ED #E0 *NOP*}
function e224:integer;
begin
Result:=8;
end;
{#ED #E1 *NOP*}
function e225:integer;
begin
Result:=8;
end;
{#ED #E2 *NOP*}
function e226:integer;
begin
Result:=8;
end;
{#ED #E3 *NOP*}
function e227:integer;
begin
Result:=8;
end;
{#ED #E4 *NOP*}
function e228:integer;
begin
Result:=8;
end;
{#ED #E5 *NOP*}
function e229:integer;
begin
Result:=8;
end;
{#ED #E6 *NOP*}
function e230:integer;
begin
Result:=8;
end;
{#ED #E7 *NOP*}
function e231:integer;
begin
Result:=8;
end;
{#ED #E8 *NOP*}
function e232:integer;
begin
Result:=8;
end;
{#ED #E9 *NOP*}
function e233:integer;
begin
Result:=8;
end;
{#ED #EA *NOP*}
function e234:integer;
begin
Result:=8;
end;
{#ED #EB *NOP*}
function e235:integer;
begin
Result:=8;
end;
{#ED #EC *NOP*}
function e236:integer;
begin
Result:=8;
end;
{#ED #ED *NOP*}
function e237:integer;
begin
Result:=8;
end;
{#ED #EE *NOP*}
function e238:integer;
begin
Result:=8;
end;
{#ED #EF *NOP*}
function e239:integer;
begin
Result:=8;
end;
{#ED #F0 *NOP*}
function e240:integer;
begin
Result:=8;
end;
{#ED #F1 *NOP*}
function e241:integer;
begin
Result:=8;
end;
{#ED #F2 *NOP*}
function e242:integer;
begin
Result:=8;
end;
{#ED #F3 *NOP*}
function e243:integer;
begin
Result:=8;
end;
{#ED #F4 *NOP*}
function e244:integer;
begin
Result:=8;
end;
{#ED #F5 *NOP*}
function e245:integer;
begin
Result:=8;
end;
{#ED #F6 *NOP*}
function e246:integer;
begin
Result:=8;
end;
{#ED #F7 *NOP*}
function e247:integer;
begin
Result:=8;
end;
{#ED #F8 *NOP*}
function e248:integer;
begin
Result:=8;
end;
{#ED #F9 *NOP*}
function e249:integer;
begin
Result:=8;
end;
{#ED #FA *NOP*}
function e250:integer;
begin
Result:=8;
end;
{#ED #FB *NOP*}
function e251:integer;
begin
Result:=8;
end;
{#ED #FC *NOP*}
function e252:integer;
begin
Result:=8;
end;
{#ED #FD *NOP*}
function e253:integer;
begin
Result:=8;
end;
{#ED #FE *NOP*}
function e254:integer;
begin
Result:=8;
end;
{#ED #FF *NOP*}
function e255:integer;
begin
Result:=8;
end;
{#DD #00 *NOP*}
function d0(var IndReg:Z80_Register):integer;
begin
Result:=m0+4;
end;
{#DD #01 *NOP*}
function d1(var IndReg:Z80_Register):integer;
begin
Result:=m1+4;
end;
{#DD #02 *NOP*}
function d2(var IndReg:Z80_Register):integer;
begin
Result:=m2+4;
end;
{#DD #03 *NOP*}
function d3(var IndReg:Z80_Register):integer;
begin
Result:=m3+4;
end;
{#DD #04 *NOP*}
function d4(var IndReg:Z80_Register):integer;
begin
Result:=m4+4;
end;
{#DD #05 *NOP*}
function d5(var IndReg:Z80_Register):integer;
begin
Result:=m5+4;
end;
{#DD #06 *NOP*}
function d6(var IndReg:Z80_Register):integer;
begin
Result:=m6+4;
end;
{#DD #07 *NOP*}
function d7(var IndReg:Z80_Register):integer;
begin
Result:=m7+4;
end;
{#DD #08 *NOP*}
function d8(var IndReg:Z80_Register):integer;
begin
Result:=m8+4;
end;
{#DD #09 ADD IX,BC}
function d9(var IndReg:Z80_Register):integer;
begin
inc(IndReg.AllWord,Z80_Registers.Common.BC.AllWord);
SetAddHLFlags;
Result:=15;
end;
{#DD #0A *NOP*}
function d10(var IndReg:Z80_Register):integer;
begin
Result:=m10+4;
end;
{#DD #0B *NOP*}
function d11(var IndReg:Z80_Register):integer;
begin
Result:=m11+4;
end;
{#DD #0C *NOP*}
function d12(var IndReg:Z80_Register):integer;
begin
Result:=m12+4;
end;
{#DD #0D *NOP*}
function d13(var IndReg:Z80_Register):integer;
begin
Result:=m13+4;
end;
{#DD #0E *NOP*}
function d14(var IndReg:Z80_Register):integer;
begin
Result:=m14+4;
end;
{#DD #0F *NOP*}
function d15(var IndReg:Z80_Register):integer;
begin
Result:=m15+4;
end;
{#DD #10 *NOP*}
function d16(var IndReg:Z80_Register):integer;
begin
Result:=m16+4;
end;
{#DD #11 *NOP*}
function d17(var IndReg:Z80_Register):integer;
begin
Result:=m17+4;
end;
{#DD #12 *NOP*}
function d18(var IndReg:Z80_Register):integer;
begin
Result:=m18+4;
end;
{#DD #13 *NOP*}
function d19(var IndReg:Z80_Register):integer;
begin
Result:=m19+4;
end;
{#DD #14 *NOP*}
function d20(var IndReg:Z80_Register):integer;
begin
Result:=m20+4;
end;
{#DD #15 *NOP*}
function d21(var IndReg:Z80_Register):integer;
begin
Result:=m21+4;
end;
{#DD #16 *NOP*}
function d22(var IndReg:Z80_Register):integer;
begin
Result:=m22+4;
end;
{#DD #17 *NOP*}
function d23(var IndReg:Z80_Register):integer;
begin
Result:=m23+4;
end;
{#DD #18 *NOP*}
function d24(var IndReg:Z80_Register):integer;
begin
Result:=m24+4;
end;
{#DD #19 ADD IX,DE}
function d25(var IndReg:Z80_Register):integer;
begin
inc(IndReg.AllWord,Z80_Registers.Common.DE.AllWord);
SetAddHLFlags;
Result:=15;
end;
{#DD #1A *NOP*}
function d26(var IndReg:Z80_Register):integer;
begin
Result:=m26+4;
end;
{#DD #1B *NOP*}
function d27(var IndReg:Z80_Register):integer;
begin
Result:=m27+4;
end;
{#DD #1C *NOP*}
function d28(var IndReg:Z80_Register):integer;
begin
Result:=m28+4;
end;
{#DD #1D *NOP*}
function d29(var IndReg:Z80_Register):integer;
begin
Result:=m29+4;
end;
{#DD #1E *NOP*}
function d30(var IndReg:Z80_Register):integer;
begin
Result:=m30+4;
end;
{#DD #1F *NOP*}
function d31(var IndReg:Z80_Register):integer;
begin
Result:=m31+4;
end;
{#DD #20 *NOP*}
function d32(var IndReg:Z80_Register):integer;
begin
Result:=m32+4;
end;
{#DD #21 LD IX,nn}
function d33(var IndReg:Z80_Register):integer;
begin
IndReg.AllWord:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
inc(Z80_Registers.PC,2);
Result:=14;
end;
{#DD #22 LD (nn),IX}
function d34(var IndReg:Z80_Register):integer;
var
 Temp:integer;
begin
Temp:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
WordPointer(@RAM.Index[Temp])^:=IndReg.AllWord;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#DD #23 INC IX}
function d35(var IndReg:Z80_Register):integer;
begin
inc(IndReg.AllWord);
Result:=10;
end;
{#DD #24 INC IXh}
function d36(var IndReg:Z80_Register):integer;
begin
inc(IndReg.HiByte);
SetFlagsInc;
Result:=8;
end;
{#DD #25 DEC IXh}
function d37(var IndReg:Z80_Register):integer;
begin
dec(IndReg.HiByte);
SetFlagsDec;
Result:=8;
end;
{#DD #26 LD IXh,n}
function d38(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=11;
end;
{#DD #27 *NOP*}
function d39(var IndReg:Z80_Register):integer;
begin
Result:=m39+4;
end;
{#DD #28 *NOP*}
function d40(var IndReg:Z80_Register):integer;
begin
Result:=m40+4;
end;
{#DD #29 ADD IX,IX}
function d41(var IndReg:Z80_Register):integer;
begin
inc(IndReg.AllWord,IndReg.AllWord);
SetAddHLFlags;
Result:=15;
end;
{#DD #2A LD IX,(nn)}
function d42(var IndReg:Z80_Register):integer;
var
 Temp:integer;
begin
Temp:=WordPointer(@RAM.Index[Z80_Registers.PC])^;
IndReg.AllWord:=WordPointer(@RAM.Index[Temp])^;
inc(Z80_Registers.PC,2);
Result:=20;
end;
{#DD #2B DEC IX}
function d43(var IndReg:Z80_Register):integer;
begin
dec(IndReg.AllWord);
Result:=10;
end;
{#DD #2C INC IXl}
function d44(var IndReg:Z80_Register):integer;
begin
inc(IndReg.LoByte);
SetFlagsInc;
Result:=8;
end;
{#DD #2D DEC IXl}
function d45(var IndReg:Z80_Register):integer;
begin
dec(IndReg.LoByte);
SetFlagsDec;
Result:=8;
end;
{#DD #2E LD IXl,n}
function d46(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=11;
end;
{#DD #2F *NOP*}
function d47(var IndReg:Z80_Register):integer;
begin
Result:=m47+4;
end;
{#DD #30 *NOP*}
function d48(var IndReg:Z80_Register):integer;
begin
Result:=m48+4;
end;
{#DD #31 *NOP*}
function d49(var IndReg:Z80_Register):integer;
begin
Result:=m49+4;
end;
{#DD #32 *NOP*}
function d50(var IndReg:Z80_Register):integer;
begin
Result:=m50+4;
end;
{#DD #33 *NOP*}
function d51(var IndReg:Z80_Register):integer;
begin
Result:=m51+4;
end;
{#DD #34 INC (IX+n)}
function d52(var IndReg:Z80_Register):integer;
begin
inc(RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]);
SetFlagsInc;
inc(Z80_Registers.PC);
Result:=23;
end;
{#DD #35 DEC (IX+d)}
function d53(var IndReg:Z80_Register):integer;
begin
dec(RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]);
SetFlagsDec;
inc(Z80_Registers.PC);
Result:=23;
end;
{#DD #36 LD (IX+d),n}
function d54(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        RAM.Index[Z80_Registers.PC+1];
inc(Z80_Registers.PC,2);
Result:=19;
end;
{#DD #37 *NOP*}
function d55(var IndReg:Z80_Register):integer;
begin
Result:=m55+4;
end;
{#DD #38 *NOP*}
function d56(var IndReg:Z80_Register):integer;
begin
Result:=m56+4;
end;
{#DD #39 ADD IX,SP}
function d57(var IndReg:Z80_Register):integer;
begin
inc(IndReg.AllWord,Z80_Registers.SP);
SetAddHLFlags;
Result:=15;
end;
{#DD #3A *NOP*}
function d58(var IndReg:Z80_Register):integer;
begin
Result:=m58+4;
end;
{#DD #3B *NOP*}
function d59(var IndReg:Z80_Register):integer;
begin
Result:=m59+4;
end;
{#DD #3C *NOP*}
function d60(var IndReg:Z80_Register):integer;
begin
Result:=m60+4;
end;
{#DD #3D *NOP*}
function d61(var IndReg:Z80_Register):integer;
begin
Result:=m61+4;
end;
{#DD #3E *NOP*}
function d62(var IndReg:Z80_Register):integer;
begin
Result:=m62+4;
end;
{#DD #3F *NOP*}
function d63(var IndReg:Z80_Register):integer;
begin
Result:=m63+4;
end;
{#DD #40 *NOP*}
function d64(var IndReg:Z80_Register):integer;
begin
Result:=m64+4;
end;
{#DD #41 *NOP*}
function d65(var IndReg:Z80_Register):integer;
begin
Result:=m65+4;
end;
{#DD #42 *NOP*}
function d66(var IndReg:Z80_Register):integer;
begin
Result:=m66+4;
end;
{#DD #43 *NOP*}
function d67(var IndReg:Z80_Register):integer;
begin
Result:=m67+4;
end;
{#DD #44 LD B,IXh}
function d68(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.BC.HiByte:=IndReg.HiByte;
Result:=8;
end;
{#DD #45 LD B,IXl}
function d69(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.BC.HiByte:=IndReg.LoByte;
Result:=8;
end;
{#DD #46 LD B,(IX+d)}
function d70(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.BC.HiByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #47 *NOP*}
function d71(var IndReg:Z80_Register):integer;
begin
Result:=m71+4;
end;
{#DD #48 *NOP*}
function d72(var IndReg:Z80_Register):integer;
begin
Result:=m72+4;
end;
{#DD #49 *NOP*}
function d73(var IndReg:Z80_Register):integer;
begin
Result:=m73+4;
end;
{#DD #4A *NOP*}
function d74(var IndReg:Z80_Register):integer;
begin
Result:=m74+4;
end;
{#DD #4B *NOP*}
function d75(var IndReg:Z80_Register):integer;
begin
Result:=m75+4;
end;
{#DD #4C LD C,IXh}
function d76(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.BC.LoByte:=IndReg.HiByte;
Result:=8;
end;
{#DD #4D LD C,IXl}
function d77(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.BC.LoByte:=IndReg.LoByte;
Result:=8;
end;
{#DD #4E LD C,(IX+d)}
function d78(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.BC.LoByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #4F *NOP*}
function d79(var IndReg:Z80_Register):integer;
begin
Result:=m79+4;
end;
{#DD #50 *NOP*}
function d80(var IndReg:Z80_Register):integer;
begin
Result:=m80+4;
end;
{#DD #51 *NOP*}
function d81(var IndReg:Z80_Register):integer;
begin
Result:=m81+4;
end;
{#DD #52 *NOP*}
function d82(var IndReg:Z80_Register):integer;
begin
Result:=m82+4;
end;
{#DD #53 *NOP*}
function d83(var IndReg:Z80_Register):integer;
begin
Result:=m83+4;
end;
{#DD #54 LD D,IXh}
function d84(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.DE.HiByte:=IndReg.HiByte;
Result:=8;
end;
{#DD #55 LD D,IXl}
function d85(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.DE.HiByte:=IndReg.LoByte;
Result:=8;
end;
{#DD #56 LD D,(IX+d)}
function d86(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.DE.HiByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #57 *NOP*}
function d87(var IndReg:Z80_Register):integer;
begin
Result:=m87+4;
end;
{#DD #58 *NOP*}
function d88(var IndReg:Z80_Register):integer;
begin
Result:=m88+4;
end;
{#DD #59 *NOP*}
function d89(var IndReg:Z80_Register):integer;
begin
Result:=m89+4;
end;
{#DD #5A *NOP*}
function d90(var IndReg:Z80_Register):integer;
begin
Result:=m90+4;
end;
{#DD #5B *NOP*}
function d91(var IndReg:Z80_Register):integer;
begin
Result:=m91+4;
end;
{#DD #5C LD E,IXh}
function d92(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.DE.LoByte:=IndReg.HiByte;
Result:=8;
end;
{#DD #5D LD E,IXl}
function d93(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.DE.LoByte:=IndReg.LoByte;
Result:=8;
end;
{#DD #5E LD E,(IX+d)}
function d94(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.DE.LoByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #5F *NOP*}
function d95(var IndReg:Z80_Register):integer;
begin
Result:=m95+4;
end;
{#DD #60 LD IXh,B}
function d96(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=Z80_Registers.Common.BC.HiByte;
Result:=8;
end;
{#DD #61 LD IXh,C}
function d97(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=Z80_Registers.Common.BC.LoByte;
Result:=8;
end;
{#DD #62 LD IXh,D}
function d98(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=Z80_Registers.Common.DE.HiByte;
Result:=8;
end;
{#DD #63 LD IXh,E}
function d99(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=Z80_Registers.Common.DE.LoByte;
Result:=8;
end;
{#DD #64 LD IXh,IXh}
function d100(var IndReg:Z80_Register):integer;
begin
Result:=8;
end;
{#DD #65 LD IXh,IXl}
function d101(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=IndReg.LoByte;
Result:=8;
end;
{#DD #66 LD H,(IX+d)}
function d102(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.HL.HiByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #67 LD IXh,A}
function d103(var IndReg:Z80_Register):integer;
begin
IndReg.HiByte:=Z80_Registers.AF.HiByte;
Result:=8;
end;
{#DD #68 LD IXl,B}
function d104(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=Z80_Registers.Common.BC.HiByte;
Result:=8;
end;
{#DD #69 LD IXl,C}
function d105(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=Z80_Registers.Common.BC.LoByte;
Result:=8;
end;
{#DD #6A LD IXl,D}
function d106(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=Z80_Registers.Common.DE.HiByte;
Result:=8;
end;
{#DD #6B LD IXl,E}
function d107(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=Z80_Registers.Common.DE.LoByte;
Result:=8;
end;
{#DD #6C LD IXl,IXh}
function d108(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=IndReg.HiByte;
Result:=8;
end;
{#DD #6D LD IXl,IXl}
function d109(var IndReg:Z80_Register):integer;
begin
Result:=8;
end;
{#DD #6E LD L,(IX+d)}
function d110(var IndReg:Z80_Register):integer;
begin
Z80_Registers.Common.HL.LoByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #6F LD IXl,A}
function d111(var IndReg:Z80_Register):integer;
begin
IndReg.LoByte:=Z80_Registers.AF.HiByte;
Result:=8;
end;
{#DD #70 LD (IX+d),B}
function d112(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.Common.BC.HiByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #71 LD (IX+d),C}
function d113(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.Common.BC.LoByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #72 LD (IX+d),D}
function d114(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.Common.DE.HiByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #73 LD (IX+d),E}
function d115(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.Common.DE.LoByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #74 LD (IX+d),H}
function d116(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.Common.HL.HiByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #75 LD (IX+d),L}
function d117(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.Common.HL.LoByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #76 *NOP*}
function d118(var IndReg:Z80_Register):integer;
begin
Result:=m118+4;
end;
{#DD #77 LD (IX+d),A}
function d119(var IndReg:Z80_Register):integer;
begin
RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])]:=
        Z80_Registers.AF.HiByte;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #78 *NOP*}
function d120(var IndReg:Z80_Register):integer;
begin
Result:=m120+4;
end;
{#DD #79 *NOP*}
function d121(var IndReg:Z80_Register):integer;
begin
Result:=m121+4;
end;
{#DD #7A *NOP*}
function d122(var IndReg:Z80_Register):integer;
begin
Result:=m122+4;
end;
{#DD #7B *NOP*}
function d123(var IndReg:Z80_Register):integer;
begin
Result:=m123+4;
end;
{#DD #7C LD A,IXh}
function d124(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=IndReg.HiByte;
Result:=8;
end;
{#DD #7D LD A,IXl}
function d125(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=IndReg.LoByte;
Result:=8;
end;
{#DD #7E LD A,(IX+d)}
function d126(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=RAM.Index[IndReg.AllWord+
                shortint(RAM.Index[Z80_Registers.PC])];
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #7F *NOP*}
function d127(var IndReg:Z80_Register):integer;
begin
Result:=m127+4;
end;
{#DD #80 *NOP*}
function d128(var IndReg:Z80_Register):integer;
begin
Result:=m128+4;
end;
{#DD #81 *NOP*}
function d129(var IndReg:Z80_Register):integer;
begin
Result:=m129+4;
end;
{#DD #82 *NOP*}
function d130(var IndReg:Z80_Register):integer;
begin
Result:=m130+4;
end;
{#DD #83 *NOP*}
function d131(var IndReg:Z80_Register):integer;
begin
Result:=m131+4;
end;
{#DD #84 ADD A,IXh}
function d132(var IndReg:Z80_Register):integer;
begin
inc(Z80_Registers.AF.HiByte,IndReg.HiByte);
SetAddAFlags;
Result:=8;
end;
{#DD #85 ADD A,IXl}
function d133(var IndReg:Z80_Register):integer;
begin
inc(Z80_Registers.AF.HiByte,IndReg.LoByte);
SetAddAFlags;
Result:=8;
end;
{#DD #86 ADD A,(IX+d)}
function d134(var IndReg:Z80_Register):integer;
begin
inc(Z80_Registers.AF.HiByte,RAM.Index[IndReg.AllWord+
        shortint(RAM.Index[Z80_Registers.PC])]);
SetAddAFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #87 *NOP*}
function d135(var IndReg:Z80_Register):integer;
begin
Result:=m135+4;
end;
{#DD #88 *NOP*}
function d136(var IndReg:Z80_Register):integer;
begin
Result:=m136+4;
end;
{#DD #89 *NOP*}
function d137(var IndReg:Z80_Register):integer;
begin
Result:=m137+4;
end;
{#DD #8A *NOP*}
function d138(var IndReg:Z80_Register):integer;
begin
Result:=m138+4;
end;
{#DD #8B *NOP*}
function d139(var IndReg:Z80_Register):integer;
begin
Result:=m139+4;
end;
{#DD #8C ADC A,IXh}
function d140(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[eax + 1]
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=8;
end;
{#DD #8D ADC A,IXl}
function d141(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[eax]
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
Result:=8;
end;
{#DD #8E ADC A,(IX+d)}
function d142(var IndReg:Z80_Register):integer;
begin
asm
movzx edx,Z80_Registers.PC
movsx ecx,byte ptr RAM.Index[edx]
movzx eax,word ptr [eax]
add ax,cx
mov al,byte ptr RAM.Index[eax]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
adc [edx+1],al
end;
SetAddAFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #8F *NOP*}
function d143(var IndReg:Z80_Register):integer;
begin
Result:=m143+4;
end;
{#DD #90 *NOP*}
function d144(var IndReg:Z80_Register):integer;
begin
Result:=m144+4;
end;
{#DD #91 *NOP*}
function d145(var IndReg:Z80_Register):integer;
begin
Result:=m145+4;
end;
{#DD #92 *NOP*}
function d146(var IndReg:Z80_Register):integer;
begin
Result:=m146+4;
end;
{#DD #93 *NOP*}
function d147(var IndReg:Z80_Register):integer;
begin
Result:=m147+4;
end;
{#DD #94 SUB IXh}
function d148(var IndReg:Z80_Register):integer;
begin
dec(Z80_Registers.AF.HiByte,IndReg.HiByte);
SetSubAFlags;
Result:=8;
end;
{#DD #95 SUB IXl}
function d149(var IndReg:Z80_Register):integer;
begin
dec(Z80_Registers.AF.HiByte,IndReg.LoByte);
SetSubAFlags;
Result:=8;
end;
{#DD #96 SUB (IX+d)}
function d150(var IndReg:Z80_Register):integer;
begin
dec(Z80_Registers.AF.HiByte,RAM.Index[IndReg.AllWord+
                        shortint(RAM.Index[Z80_Registers.PC])]);
SetSubAFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #97 *NOP*}
function d151(var IndReg:Z80_Register):integer;
begin
Result:=m151+4;
end;
{#DD #98 *NOP*}
function d152(var IndReg:Z80_Register):integer;
begin
Result:=m152+4;
end;
{#DD #99 *NOP*}
function d153(var IndReg:Z80_Register):integer;
begin
Result:=m153+4;
end;
{#DD #9A *NOP*}
function d154(var IndReg:Z80_Register):integer;
begin
Result:=m154+4;
end;
{#DD #9B *NOP*}
function d155(var IndReg:Z80_Register):integer;
begin
Result:=m155+4;
end;
{#DD #9C SBC A,IXh}
function d156(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[eax+1]
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=8;
end;
{#DD #9D SBC A,IXl}
function d157(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov al,[eax]
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
Result:=8;
end;
{#DD #9E SBC A,(IX+d)}
function d158(var IndReg:Z80_Register):integer;
begin
asm
movzx edx,Z80_Registers.PC
movsx ecx,byte ptr RAM.Index[edx]
movzx eax,word ptr [eax]
add ax,cx
mov al,byte ptr RAM.Index[eax]
mov edx,Z80_Registers.AF
shr byte ptr [edx],1
sbb [edx+1],al
end;
SetSubAFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #9F *NOP*}
function d159(var IndReg:Z80_Register):integer;
begin
Result:=m159+4;
end;
{#DD #A0 *NOP*}
function d160(var IndReg:Z80_Register):integer;
begin
Result:=m160+4;
end;
{#DD #A1 *NOP*}
function d161(var IndReg:Z80_Register):integer;
begin
Result:=m161+4;
end;
{#DD #A2 *NOP*}
function d162(var IndReg:Z80_Register):integer;
begin
Result:=m162+4;
end;
{#DD #A3 *NOP*}
function d163(var IndReg:Z80_Register):integer;
begin
Result:=m163+4;
end;
{#DD #A4 AND IXh}
function d164(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         IndReg.HiByte;
SetAndFlags;
Result:=8;
end;
{#DD #A5 AND IXl}
function d165(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                         IndReg.LoByte;
SetAndFlags;
Result:=8;
end;
{#DD #A6 AND (IX+d)}
function d166(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte and
                   RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])];
SetAndFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #A7 *NOP*}
function d167(var IndReg:Z80_Register):integer;
begin
Result:=m167+4;
end;
{#DD #A8 *NOP*}
function d168(var IndReg:Z80_Register):integer;
begin
Result:=m168+4;
end;
{#DD #A9 *NOP*}
function d169(var IndReg:Z80_Register):integer;
begin
Result:=m169+4;
end;
{#DD #AA *NOP*}
function d170(var IndReg:Z80_Register):integer;
begin
Result:=m170+4;
end;
{#DD #AB *NOP*}
function d171(var IndReg:Z80_Register):integer;
begin
Result:=m171+4;
end;
{#DD #AC XOR IXh}
function d172(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         IndReg.HiByte;
SetOrFlags;
Result:=8;
end;
{#DD #AD XOR IXl}
function d173(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
                         IndReg.LoByte;
SetOrFlags;
Result:=8;
end;
{#DD #AE XOR (IX+d)}
function d174(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte xor
        RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])];
SetOrFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #AF *NOP*}
function d175(var IndReg:Z80_Register):integer;
begin
Result:=m175+4;
end;
{#DD #B0 *NOP*}
function d176(var IndReg:Z80_Register):integer;
begin
Result:=m176+4;
end;
{#DD #B1 *NOP*}
function d177(var IndReg:Z80_Register):integer;
begin
Result:=m177+4;
end;
{#DD #B2 *NOP*}
function d178(var IndReg:Z80_Register):integer;
begin
Result:=m178+4;
end;
{#DD #B3 *NOP*}
function d179(var IndReg:Z80_Register):integer;
begin
Result:=m179+4;
end;
{#DD #B4 OR IXh}
function d180(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         IndReg.HiByte;
SetOrFlags;
Result:=8;
end;
{#DD #B5 OR IXl}
function d181(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
                         IndReg.LoByte;
SetOrFlags;
Result:=8;
end;
{#DD #B6 OR (IX+d)}
function d182(var IndReg:Z80_Register):integer;
begin
Z80_Registers.AF.HiByte:=Z80_Registers.AF.HiByte or
        RAM.Index[IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC])];
SetOrFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #B7 *NOP*}
function d183(var IndReg:Z80_Register):integer;
begin
Result:=m183+4;
end;
{#DD #B8 *NOP*}
function d184(var IndReg:Z80_Register):integer;
begin
Result:=m184+4;
end;
{#DD #B9 *NOP*}
function d185(var IndReg:Z80_Register):integer;
begin
Result:=m185+4;
end;
{#DD #BA *NOP*}
function d186(var IndReg:Z80_Register):integer;
begin
Result:=m186+4;
end;
{#DD #BB *NOP*}
function d187(var IndReg:Z80_Register):integer;
begin
Result:=m187+4;
end;
{#DD #BC CP IXh}
function d188(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,[edx+1]
sub cl,byte ptr [IndReg+1]
end;
SetSubAFlags;
Result:=8;
end;
{#DD #BD CP IXl}
function d189(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,[edx+1]
sub cl,byte ptr [IndReg]
end;
SetSubAFlags;
Result:=8;
end;
{#DD #BE CP (IX+d)}
function d190(var IndReg:Z80_Register):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,[edx+1]
movzx edx,Z80_Registers.PC
movsx dx,byte ptr [RAM + edx]
add dx,[eax]
sub cl,byte ptr [RAM + edx]
end;
SetSubAFlags;
inc(Z80_Registers.PC);
Result:=19;
end;
{#DD #BF *NOP*}
function d191(var IndReg:Z80_Register):integer;
begin
Result:=m191+4;
end;
{#DD #C0 *NOP*}
function d192(var IndReg:Z80_Register):integer;
begin
Result:=m192+4;
end;
{#DD #C1 *NOP*}
function d193(var IndReg:Z80_Register):integer;
begin
Result:=m193+4;
end;
{#DD #C2 *NOP*}
function d194(var IndReg:Z80_Register):integer;
begin
Result:=m194+4;
end;
{#DD #C3 *NOP*}
function d195(var IndReg:Z80_Register):integer;
begin
Result:=m195+4;
end;
{#DD #C4 *NOP*}
function d196(var IndReg:Z80_Register):integer;
begin
Result:=m196+4;
end;
{#DD #C5 *NOP*}
function d197(var IndReg:Z80_Register):integer;
begin
Result:=m197+4;
end;
{#DD #C6 *NOP*}
function d198(var IndReg:Z80_Register):integer;
begin
Result:=m198+4;
end;
{#DD #C7 *NOP*}
function d199(var IndReg:Z80_Register):integer;
begin
Result:=m199+4;
end;
{#DD #C8 *NOP*}
function d200(var IndReg:Z80_Register):integer;
begin
Result:=m200+4;
end;
{#DD #C9 *NOP*}
function d201(var IndReg:Z80_Register):integer;
begin
Result:=m201+4;
end;
{#DD #CA *NOP*}
function d202(var IndReg:Z80_Register):integer;
begin
Result:=m202+4;
end;
{#DD #CC *NOP*}
function d204(var IndReg:Z80_Register):integer;
begin
Result:=m204+4;
end;
{#DD #CD *NOP*}
function d205(var IndReg:Z80_Register):integer;
begin
Result:=m205+4;
end;
{#DD #CE *NOP*}
function d206(var IndReg:Z80_Register):integer;
begin
Result:=m206+4;
end;
{#DD #CF *NOP*}
function d207(var IndReg:Z80_Register):integer;
begin
Result:=m207+4;
end;
{#DD #D0 *NOP*}
function d208(var IndReg:Z80_Register):integer;
begin
Result:=m208+4;
end;
{#DD #D1 *NOP*}
function d209(var IndReg:Z80_Register):integer;
begin
Result:=m209+4;
end;
{#DD #D2 *NOP*}
function d210(var IndReg:Z80_Register):integer;
begin
Result:=m210+4;
end;
{#DD #D3 *NOP*}
function d211(var IndReg:Z80_Register):integer;
begin
Result:=m211+4;
end;
{#DD #D4 *NOP*}
function d212(var IndReg:Z80_Register):integer;
begin
Result:=m212+4;
end;
{#DD #D5 *NOP*}
function d213(var IndReg:Z80_Register):integer;
begin
Result:=m213+4;
end;
{#DD #D6 *NOP*}
function d214(var IndReg:Z80_Register):integer;
begin
Result:=m214+4;
end;
{#DD #D7 *NOP*}
function d215(var IndReg:Z80_Register):integer;
begin
Result:=m215+4;
end;
{#DD #D8 *NOP*}
function d216(var IndReg:Z80_Register):integer;
begin
Result:=m216+4;
end;
{#DD #D9 *NOP*}
function d217(var IndReg:Z80_Register):integer;
begin
Result:=m217+4;
end;
{#DD #DA *NOP*}
function d218(var IndReg:Z80_Register):integer;
begin
Result:=m218+4;
end;
{#DD #DB *NOP*}
function d219(var IndReg:Z80_Register):integer;
begin
Result:=m219+4;
end;
{#DD #DC *NOP*}
function d220(var IndReg:Z80_Register):integer;
begin
Result:=m220+4;
end;
{#DD #DD *NOP*}
function d221(var IndReg:Z80_Register):integer;
begin
EIorDDorFD := True;
dec(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 dec al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result:=4;
end;
{#DD #DE *NOP*}
function d222(var IndReg:Z80_Register):integer;
begin
Result:=m222+4;
end;
{#DD #DF *NOP*}
function d223(var IndReg:Z80_Register):integer;
begin
Result:=m223+4;
end;
{#DD #E0 *NOP*}
function d224(var IndReg:Z80_Register):integer;
begin
Result:=m224+4;
end;
{#DD #E1 POP IX}
function d225(var IndReg:Z80_Register):integer;
begin
IndReg.AllWord:=WordPointer(@RAM.Index[Z80_Registers.SP])^;
inc(Z80_Registers.SP,2);
Result:=14;
end;
{#DD #E2 *NOP*}
function d226(var IndReg:Z80_Register):integer;
begin
Result:=m226+4;
end;
{#DD #E3 EX (SP),IX}
function d227(var IndReg:Z80_Register):integer;
var
 Temp:word;
 WP:WordPointer;
begin
WP := @RAM.Index[Z80_Registers.SP];
Temp := WP^;
WP^ := IndReg.AllWord;
IndReg.AllWord := Temp;
Result:=23;
end;
{#DD #E4 *NOP*}
function d228(var IndReg:Z80_Register):integer;
begin
Result:=m228+4;
end;
{#DD #E5 PUSH IX}
function d229(var IndReg:Z80_Register):integer;
begin
dec(Z80_Registers.SP,2);
WordPointer(@RAM.Index[Z80_Registers.SP])^:=IndReg.AllWord;
Result:=15;
end;
{#DD #E6 *NOP*}
function d230(var IndReg:Z80_Register):integer;
begin
Result:=m230+4;
end;
{#DD #E7 *NOP*}
function d231(var IndReg:Z80_Register):integer;
begin
Result:=m231+4;
end;
{#DD #E8 *NOP*}
function d232(var IndReg:Z80_Register):integer;
begin
Result:=m232+4;
end;
{#DD #E9 JP (IX)}
function d233(var IndReg:Z80_Register):integer;
begin
Z80_Registers.PC:=IndReg.AllWord;
Result:=8;
end;
{#DD #EA *NOP*}
function d234(var IndReg:Z80_Register):integer;
begin
Result:=m234+4;
end;
{#DD #EB EX DE,HL}
function d235(var IndReg:Z80_Register):integer;
begin
Result:=m235+4;
end;
{#DD #EC *NOP*}
function d236(var IndReg:Z80_Register):integer;
begin
Result:=m236+4;
end;
{#DD #ED *NOP*}
function d237(var IndReg:Z80_Register):integer;
begin
EIorDDorFD := True;
dec(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 dec al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result:=4;
end;
{#DD #EE *NOP*}
function d238(var IndReg:Z80_Register):integer;
begin
Result:=m238+4;
end;
{#DD #EF *NOP*}
function d239(var IndReg:Z80_Register):integer;
begin
Result:=m239+4;
end;
{#DD #F0 *NOP*}
function d240(var IndReg:Z80_Register):integer;
begin
Result:=m240+4;
end;
{#DD #F1 *NOP*}
function d241(var IndReg:Z80_Register):integer;
begin
Result:=m241+4;
end;
{#DD #F2 *NOP*}
function d242(var IndReg:Z80_Register):integer;
begin
Result:=m242+4;
end;
{#DD #F3 *NOP*}
function d243(var IndReg:Z80_Register):integer;
begin
Result:=m243+4;
end;
{#DD #F4 *NOP*}
function d244(var IndReg:Z80_Register):integer;
begin
Result:=m244+4;
end;
{#DD #F5 *NOP*}
function d245(var IndReg:Z80_Register):integer;
begin
Result:=m245+4;
end;
{#DD #F6 *NOP*}
function d246(var IndReg:Z80_Register):integer;
begin
Result:=m246+4;
end;
{#DD #F7 *NOP*}
function d247(var IndReg:Z80_Register):integer;
begin
Result:=m247+4;
end;
{#DD #F8 *NOP*}
function d248(var IndReg:Z80_Register):integer;
begin
Result:=m248+4;
end;
{#DD #F9 LD SP,IX}
function d249(var IndReg:Z80_Register):integer;
begin
Z80_Registers.SP:=IndReg.AllWord;
Result:=10;
end;
{#DD #FA *NOP*}
function d250(var IndReg:Z80_Register):integer;
begin
Result:=m250+4;
end;
{#DD #FB *NOP*}
function d251(var IndReg:Z80_Register):integer;
begin
Result:=m251+4;
end;
{#DD #FC *NOP*}
function d252(var IndReg:Z80_Register):integer;
begin
Result:=m252+4;
end;
{#DD #FD *NOP*}
function d253(var IndReg:Z80_Register):integer;
begin
EIorDDorFD := True;
dec(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 dec al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result:=4;
end;
{#DD #FE *NOP*}
function d254(var IndReg:Z80_Register):integer;
begin
Result:=m254+4;
end;
{#DD #FF *NOP*}
function d255(var IndReg:Z80_Register):integer;
begin
Result:=m255+4;
end;

{#DD #CB d #00 *NOP*}
function b0(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 5],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #01 *NOP*}
function b1(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 4],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #02 *NOP*}
function b2(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 3],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #03 *NOP*}
function b3(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 2],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #04 *NOP*}
function b4(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #05 *NOP*}
function b5(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #06 RLC (IX+d)}
function b6(const ixd:longword):integer;
begin
asm
rol byte ptr [RAM + eax],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #07 *NOP*}
function b7(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,byte ptr [RAM + eax]
rol cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23 
end;
{#DD #CB d #08 *NOP*}
function b8(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 5],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #09 *NOP*}
function b9(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 4],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #0A *NOP*}
function b10(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 3],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #0B *NOP*}
function b11(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 2],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #0C *NOP*}
function b12(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #0D *NOP*}
function b13(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #0E RRC (IX+d)}
function b14(const ixd:longword):integer;
begin
asm
ror byte ptr [RAM + eax],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #0F *NOP*}
function b15(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,byte ptr [RAM + eax]
ror cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #10 *NOP*}
function b16(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx + 5],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #11 *NOP*}
function b17(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx + 4],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #12 *NOP*}
function b18(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx + 3],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #13 *NOP*}
function b19(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx + 2],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #14 *NOP*}
function b20(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx + 1],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #15 *NOP*}
function b21(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #16 RL (IX+d)}
function b22(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
rcl byte ptr [RAM + ecx],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #17 *NOP*}
function b23(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
sahf
rcl al,1
mov byte ptr [RAM + ecx],al
mov [edx + 1],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #18 *NOP*}
function b24(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx + 5],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #19 *NOP*}
function b25(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx + 4],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #1A *NOP*}
function b26(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx + 3],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #1B *NOP*}
function b27(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx + 2],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #1C *NOP*}
function b28(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx + 1],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #1D *NOP*}
function b29(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
mov edx,Z80_Registers.Common
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #1E RR (IX+d)}
function b30(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov ah,[edx]
sahf
rcr byte ptr [RAM + ecx],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #1F *NOP*}
function b31(const ixd:longword):integer;
begin
asm
mov ecx,eax
mov edx,Z80_Registers.AF
mov al,byte ptr [RAM + eax]
mov ah,[edx]
sahf
rcr al,1
mov byte ptr [RAM + ecx],al
mov [edx + 1],al
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #20 *NOP*}
function b32(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 5],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #21 *NOP*}
function b33(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 4],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #22 *NOP*}
function b34(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 3],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #23 *NOP*}
function b35(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 2],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #24 *NOP*}
function b36(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #25 *NOP*}
function b37(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #26 SLA (IX+d)}
function b38(const ixd:longword):integer;
begin
asm
shl byte ptr [RAM + eax],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #27 *NOP*}
function b39(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,byte ptr [RAM + eax]
shl cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #28 *NOP*}
function b40(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 5],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #29 *NOP*}
function b41(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 4],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #2A *NOP*}
function b42(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 3],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #2B *NOP*}
function b43(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 2],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #2C *NOP*}
function b44(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #2D *NOP*}
function b45(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #2E SRA (IX+d)}
function b46(const ixd:longword):integer;
begin
asm
sar byte ptr [RAM + eax],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #2F *NOP*}
function b47(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,byte ptr [RAM + eax]
sar cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #30 *NOP*}
function b48(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.Common
mov [edx+5],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #31 *NOP*}
function b49(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.Common
mov [edx+4],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #32 *NOP*}
function b50(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.Common
mov [edx+3],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #33 *NOP*}
function b51(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.Common
mov [edx+2],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #34 *NOP*}
function b52(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.Common
mov [edx+1],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #35 *NOP*}
function b53(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.Common
mov [edx],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #36 SLI (IX+d)}
function b54(const ixd:longword):integer;
begin
asm
add eax,offset RAM
shl byte ptr [eax],1
mov ecx,eax
lahf
inc byte ptr [ecx]
end;
SetSliFlags;
Result := 23
end;
{#DD #CB d #37 *NOP*}
function b55(const ixd:longword):integer;
begin
asm
add eax,offset RAM
mov cl,[eax]
shl cl,1
mov edx,eax
lahf
inc cl
mov [edx],cl
mov edx,Z80_Registers.AF
mov [edx+1],cl
end;
SetSliFlags;
Result:=23;
end;
{#DD #CB d #38 *NOP*}
function b56(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 5],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #39 *NOP*}
function b57(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 4],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #3A *NOP*}
function b58(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 3],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #3B *NOP*}
function b59(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 2],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #3C *NOP*}
function b60(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #3D *NOP*}
function b61(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.Common
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #3E SRL (IX+d)}
function b62(const ixd:longword):integer;
begin
asm
shr byte ptr [RAM + eax],1
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #3F *NOP*}
function b63(const ixd:longword):integer;
begin
asm
mov edx,Z80_Registers.AF
mov cl,byte ptr [RAM + eax]
shr cl,1
mov byte ptr [RAM + eax],cl
mov [edx + 1],cl
end;
SetRlcFlags;
Result := 23
end;
{#DD #CB d #40 *NOP*}
function b64(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #41 *NOP*}
function b65(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #42 *NOP*}
function b66(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #43 *NOP*}
function b67(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #44 *NOP*}
function b68(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #45 *NOP*}
function b69(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #46 BIT 0,(IX+d)}
function b70(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #47 *NOP*}
function b71(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 1 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #48 *NOP*}
function b72(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #49 *NOP*}
function b73(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #4A *NOP*}
function b74(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #4B *NOP*}
function b75(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #4C *NOP*}
function b76(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #4D *NOP*}
function b77(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #4E BIT 1,(IX+d)}
function b78(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #4F *NOP*}
function b79(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 2 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #50 *NOP*}
function b80(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #51 *NOP*}
function b81(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #52 *NOP*}
function b82(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #53 *NOP*}
function b83(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #54 *NOP*}
function b84(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #55 *NOP*}
function b85(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #56 BIT 2,(IX+d)}
function b86(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #57 *NOP*}
function b87(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 4 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #58 *NOP*}
function b88(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #59 *NOP*}
function b89(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #5A *NOP*}
function b90(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #5B *NOP*}
function b91(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #5C *NOP*}
function b92(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #5D *NOP*}
function b93(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #5E BIT 3,(IX+d)}
function b94(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #5F *NOP*}
function b95(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 8 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #60 *NOP*}
function b96(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #61 *NOP*}
function b97(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #62 *NOP*}
function b98(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #63 *NOP*}
function b99(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #64 *NOP*}
function b100(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #65 *NOP*}
function b101(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #66 BIT 4,(IX+d)}
function b102(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #67 *NOP*}
function b103(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 16 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #68 *NOP*}
function b104(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #69 *NOP*}
function b105(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #6A *NOP*}
function b106(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #6B *NOP*}
function b107(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #6C *NOP*}
function b108(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #6D *NOP*}
function b109(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #6E BIT 5,(IX+d)}
function b110(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #6F *NOP*}
function b111(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 32 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #70 *NOP*}
function b112(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #71 *NOP*}
function b113(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #72 *NOP*}
function b114(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #73 *NOP*}
function b115(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #74 *NOP*}
function b116(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #75 *NOP*}
function b117(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #76 BIT 6,(IX+d)}
function b118(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #77 *NOP*}
function b119(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 64 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #78 *NOP*}
function b120(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #79 *NOP*}
function b121(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #7A *NOP*}
function b122(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #7B *NOP*}
function b123(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #7C *NOP*}
function b124(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #7D *NOP*}
function b125(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #7E BIT 7,(IX+d)}
function b126(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #7F *NOP*}
function b127(const ixd:longword):integer;
begin
Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte and $BD or $10;
If RAM.Index[ixd] and 128 = 0 then
 Z80_Registers.AF.LoByte:=Z80_Registers.AF.LoByte or $40;
Result:=23;
end;
{#DD #CB d #80 *NOP*}
function b128(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #81 *NOP*}
function b129(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #82 *NOP*}
function b130(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #83 *NOP*}
function b131(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #84 *NOP*}
function b132(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #85 *NOP*}
function b133(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #86 RES 0,(IX+d)}
function b134(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $fe;
Result:=23;
end;
{#DD #CB d #87 *NOP*}
function b135(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fe;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #88 *NOP*}
function b136(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #89 *NOP*}
function b137(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #8A *NOP*}
function b138(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #8B *NOP*}
function b139(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #8C *NOP*}
function b140(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #8D *NOP*}
function b141(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #8E RES 1,(IX+d)}
function b142(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $fd;
Result:=23;
end;
{#DD #CB d #8F *NOP*}
function b143(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fd;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #90 *NOP*}
function b144(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #91 *NOP*}
function b145(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #92 *NOP*}
function b146(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #93 *NOP*}
function b147(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #94 *NOP*}
function b148(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #95 *NOP*}
function b149(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #96 RES 2,(IX+d)}
function b150(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $fb;
Result:=23;
end;
{#DD #CB d #97 *NOP*}
function b151(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $fb;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #98 *NOP*}
function b152(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #99 *NOP*}
function b153(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #9A *NOP*}
function b154(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #9B *NOP*}
function b155(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #9C *NOP*}
function b156(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #9D *NOP*}
function b157(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #9E RES 3,(IX+d)}
function b158(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $f7;
Result:=23;
end;
{#DD #CB d #9F *NOP*}
function b159(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $f7;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #A0 *NOP*}
function b160(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #A1 *NOP*}
function b161(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #A2 *NOP*}
function b162(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #A3 *NOP*}
function b163(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #A4 *NOP*}
function b164(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #A5 *NOP*}
function b165(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #A6 RES 4,(IX+d)}
function b166(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $ef;
Result:=23;
end;
{#DD #CB d #A7 *NOP*}
function b167(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $ef;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #A8 *NOP*}
function b168(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #A9 *NOP*}
function b169(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #AA *NOP*}
function b170(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #AB *NOP*}
function b171(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #AC *NOP*}
function b172(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #AD *NOP*}
function b173(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #AE RES 5,(IX+d)}
function b174(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $df;
Result:=23;
end;
{#DD #CB d #AF *NOP*}
function b175(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $df;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #B0 *NOP*}
function b176(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #B1 *NOP*}
function b177(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #B2 *NOP*}
function b178(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #B3 *NOP*}
function b179(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #B4 *NOP*}
function b180(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #B5 *NOP*}
function b181(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #B6 RES 6,(IX+d)}
function b182(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $bf;
Result:=23;
end;
{#DD #CB d #B7 *NOP*}
function b183(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $bf;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #B8 *NOP*}
function b184(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #B9 *NOP*}
function b185(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #BA *NOP*}
function b186(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #BB *NOP*}
function b187(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #BC *NOP*}
function b188(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #BD *NOP*}
function b189(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #BE RES 7,(IX+d)}
function b190(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] and $7f;
Result:=23;
end;
{#DD #CB d #BF *NOP*}
function b191(const ixd:longword):integer;
Var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] and $7f;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #C0 *NOP*}
function b192(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #C1 *NOP*}
function b193(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #C2 *NOP*}
function b194(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #C3 *NOP*}
function b195(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #C4 *NOP*}
function b196(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #C5 *NOP*}
function b197(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #C6 SET 0,(IX+d)}
function b198(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 1;
Result:=23;
end;
{#DD #CB d #C7 *NOP*}
function b199(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 1;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #C8 *NOP*}
function b200(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #C9 *NOP*}
function b201(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #CA *NOP*}
function b202(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #CB *NOP*}
function b203(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #CC *NOP*}
function b204(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #CD *NOP*}
function b205(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #CE SET 1,(IX+d)}
function b206(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 2;
Result:=23;
end;
{#DD #CB d #CF *NOP*}
function b207(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 2;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D0 *NOP*}
function b208(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D1 *NOP*}
function b209(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D2 *NOP*}
function b210(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D3 *NOP*}
function b211(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D4 *NOP*}
function b212(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D5 *NOP*}
function b213(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D6 SET 2,(IX+d)}
function b214(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 4;
Result:=23;
end;
{#Dd #DB d #D7 *NOP*}
function b215(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 4;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D8 *NOP*}
function b216(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #D9 *NOP*}
function b217(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#Dd #DB d #DA *NOP*}
function b218(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #DB *NOP*}
function b219(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#Dd #DB d #DC *NOP*}
function b220(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#Dd #DB d #DD *NOP*}
function b221(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#Dd #DB d #DE SET 3,(IX+d)}
function b222(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 8;
Result:=23;
end;
{#Dd #DB d #DF *NOP*}
function b223(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 8;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #E0 *NOP*}
function b224(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #E1 *NOP*}
function b225(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #E2 *NOP*}
function b226(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #E3 *NOP*}
function b227(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #E4 *NOP*}
function b228(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #E5 *NOP*}
function b229(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #E6 SET 4,(IX+d)}
function b230(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 16;
Result:=23;
end;
{#DD #CB d #E7 *NOP*}
function b231(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 16;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #E8 *NOP*}
function b232(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #E9 *NOP*}
function b233(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #EA *NOP*}
function b234(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #EB *NOP*}
function b235(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #EC *NOP*}
function b236(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #ED *NOP*}
function b237(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #EE SET 5,(IX+d)}
function b238(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 32;
Result:=23;
end;
{#DD #CB d #EF *NOP*}
function b239(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 32;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #F0 *NOP*}
function b240(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #F1 *NOP*}
function b241(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #F2 *NOP*}
function b242(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #F3 *NOP*}
function b243(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #F4 *NOP*}
function b244(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #F5 *NOP*}
function b245(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #F6 SET 6,(IX+d)}
function b246(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 64;
Result:=23;
end;
{#DD #CB d #F7 *NOP*}
function b247(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 64;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #F8 *NOP*}
function b248(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #F9 *NOP*}
function b249(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.HL.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #FA *NOP*}
function b250(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #FB *NOP*}
function b251(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.DE.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #FC *NOP*}
function b252(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.HiByte:=Temp;
Result:=23;
end;
{#DD #CB d #FD *NOP*}
function b253(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.Common.BC.LoByte:=Temp;
Result:=23;
end;
{#DD #CB d #FE SET 7,(IX+d)}
function b254(const ixd:longword):integer;
begin
RAM.Index[ixd]:=RAM.Index[ixd] or 128;
Result:=23;
end;
{#DD #CB d #FF *NOP*}
function b255(const ixd:longword):integer;
var
 Temp:byte;
begin
Temp:=RAM.Index[ixd] or 128;
RAM.Index[ixd]:=Temp;
Z80_Registers.AF.HiByte:=Temp;
Result:=23;
end;

const
Z80_DDFDCBTable:array [0..255] of
        function(const ixd:longword):integer=
  (b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,
   b21,b22,b23,b24,b25,b26,b27,b28,b29,b30,b31,b32,b33,b34,b35,b36,b37,b38,b39,
   b40,b41,b42,b43,b44,b45,b46,b47,b48,b49,b50,b51,b52,b53,b54,b55,b56,b57,b58,
   b59,b60,b61,b62,b63,b64,b65,b66,b67,b68,b69,b70,b71,b72,b73,b74,b75,b76,b77,
   b78,b79,b80,b81,b82,b83,b84,b85,b86,b87,b88,b89,b90,b91,b92,b93,b94,b95,b96,
   b97,b98,b99,b100,b101,b102,b103,b104,b105,b106,b107,b108,b109,b110,b111,b112,
   b113,b114,b115,b116,b117,b118,b119,b120,b121,b122,b123,b124,b125,b126,b127,
   b128,b129,b130,b131,b132,b133,b134,b135,b136,b137,b138,b139,b140,b141,b142,
   b143,b144,b145,b146,b147,b148,b149,b150,b151,b152,b153,b154,b155,b156,b157,
   b158,b159,b160,b161,b162,b163,b164,b165,b166,b167,b168,b169,b170,b171,b172,
   b173,b174,b175,b176,b177,b178,b179,b180,b181,b182,b183,b184,b185,b186,b187,
   b188,b189,b190,b191,b192,b193,b194,b195,b196,b197,b198,b199,b200,b201,b202,
   b203,b204,b205,b206,b207,b208,b209,b210,b211,b212,b213,b214,b215,b216,b217,
   b218,b219,b220,b221,b222,b223,b224,b225,b226,b227,b228,b229,b230,b231,b232,
   b233,b234,b235,b236,b237,b238,b239,b240,b241,b242,b243,b244,b245,b246,b247,
   b248,b249,b250,b251,b252,b253,b254,b255);

{#DD #CB префикс}
function d203(var IndReg:Z80_Register):integer;
var
 SubCode:integer;
 Ofst:longword;
begin
Ofst:=word(IndReg.AllWord+shortint(RAM.Index[Z80_Registers.PC]));
inc(Z80_Registers.PC);
SubCode:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=Z80_DDFDCBTable[SubCode](Ofst);
end;

Const
Z80_DDFDTable:array [0..255] of
        function (var IndReg:Z80_Register):integer;register=
  (d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
   d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,d31,d32,d33,d34,d35,d36,d37,d38,d39,
   d40,d41,d42,d43,d44,d45,d46,d47,d48,d49,d50,d51,d52,d53,d54,d55,d56,d57,d58,
   d59,d60,d61,d62,d63,d64,d65,d66,d67,d68,d69,d70,d71,d72,d73,d74,d75,d76,d77,
   d78,d79,d80,d81,d82,d83,d84,d85,d86,d87,d88,d89,d90,d91,d92,d93,d94,d95,d96,
   d97,d98,d99,d100,d101,d102,d103,d104,d105,d106,d107,d108,d109,d110,d111,d112,
   d113,d114,d115,d116,d117,d118,d119,d120,d121,d122,d123,d124,d125,d126,d127,
   d128,d129,d130,d131,d132,d133,d134,d135,d136,d137,d138,d139,d140,d141,d142,
   d143,d144,d145,d146,d147,d148,d149,d150,d151,d152,d153,d154,d155,d156,d157,
   d158,d159,d160,d161,d162,d163,d164,d165,d166,d167,d168,d169,d170,d171,d172,
   d173,d174,d175,d176,d177,d178,d179,d180,d181,d182,d183,d184,d185,d186,d187,
   d188,d189,d190,d191,d192,d193,d194,d195,d196,d197,d198,d199,d200,d201,d202,
   d203,d204,d205,d206,d207,d208,d209,d210,d211,d212,d213,d214,d215,d216,d217,
   d218,d219,d220,d221,d222,d223,d224,d225,d226,d227,d228,d229,d230,d231,d232,
   d233,d234,d235,d236,d237,d238,d239,d240,d241,d242,d243,d244,d245,d246,d247,
   d248,d249,d250,d251,d252,d253,d254,d255);
{#DD prefix}
function m221:integer;
var
 SubCode:integer;
begin
SubCode:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 inc al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result:=Z80_DDFDTable[SubCode](Z80_Registers.IX);
end;
{#FD prefix}
function m253:integer;
var
 SubCode:integer;
begin
SubCode:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 inc al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result:=Z80_DDFDTable[SubCode](Z80_Registers.IY);
end;

const
Z80_CBTable:array [0..255] of function:integer=
  (c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,
   c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38,c39,
   c40,c41,c42,c43,c44,c45,c46,c47,c48,c49,c50,c51,c52,c53,c54,c55,c56,c57,c58,
   c59,c60,c61,c62,c63,c64,c65,c66,c67,c68,c69,c70,c71,c72,c73,c74,c75,c76,c77,
   c78,c79,c80,c81,c82,c83,c84,c85,c86,c87,c88,c89,c90,c91,c92,c93,c94,c95,c96,
   c97,c98,c99,c100,c101,c102,c103,c104,c105,c106,c107,c108,c109,c110,c111,c112,
   c113,c114,c115,c116,c117,c118,c119,c120,c121,c122,c123,c124,c125,c126,c127,
   c128,c129,c130,c131,c132,c133,c134,c135,c136,c137,c138,c139,c140,c141,c142,
   c143,c144,c145,c146,c147,c148,c149,c150,c151,c152,c153,c154,c155,c156,c157,
   c158,c159,c160,c161,c162,c163,c164,c165,c166,c167,c168,c169,c170,c171,c172,
   c173,c174,c175,c176,c177,c178,c179,c180,c181,c182,c183,c184,c185,c186,c187,
   c188,c189,c190,c191,c192,c193,c194,c195,c196,c197,c198,c199,c200,c201,c202,
   c203,c204,c205,c206,c207,c208,c209,c210,c211,c212,c213,c214,c215,c216,c217,
   c218,c219,c220,c221,c222,c223,c224,c225,c226,c227,c228,c229,c230,c231,c232,
   c233,c234,c235,c236,c237,c238,c239,c240,c241,c242,c243,c244,c245,c246,c247,
   c248,c249,c250,c251,c252,c253,c254,c255);

{#CB prefix}
function m203:integer;
var
 SubCode:integer;
begin
SubCode:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 inc al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result:=Z80_CBTable[SubCode];
end;

Const
Z80_EDTable:array [0..255] of function:integer=
  (e0,e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,e11,e12,e13,e14,e15,e16,e17,e18,e19,e20,
   e21,e22,e23,e24,e25,e26,e27,e28,e29,e30,e31,e32,e33,e34,e35,e36,e37,e38,e39,
   e40,e41,e42,e43,e44,e45,e46,e47,e48,e49,e50,e51,e52,e53,e54,e55,e56,e57,e58,
   e59,e60,e61,e62,e63,e64,e65,e66,e67,e68,e69,e70,e71,e72,e73,e74,e75,e76,e77,
   e78,e79,e80,e81,e82,e83,e84,e85,e86,e87,e88,e89,e90,e91,e92,e93,e94,e95,e96,
   e97,e98,e99,e100,e101,e102,e103,e104,e105,e106,e107,e108,e109,e110,e111,e112,
   e113,e114,e115,e116,e117,e118,e119,e120,e121,e122,e123,e124,e125,e126,e127,
   e128,e129,e130,e131,e132,e133,e134,e135,e136,e137,e138,e139,e140,e141,e142,
   e143,e144,e145,e146,e147,e148,e149,e150,e151,e152,e153,e154,e155,e156,e157,
   e158,e159,e160,e161,e162,e163,e164,e165,e166,e167,e168,e169,e170,e171,e172,
   e173,e174,e175,e176,e177,e178,e179,e180,e181,e182,e183,e184,e185,e186,e187,
   e188,e189,e190,e191,e192,e193,e194,e195,e196,e197,e198,e199,e200,e201,e202,
   e203,e204,e205,e206,e207,e208,e209,e210,e211,e212,e213,e214,e215,e216,e217,
   e218,e219,e220,e221,e222,e223,e224,e225,e226,e227,e228,e229,e230,e231,e232,
   e233,e234,e235,e236,e237,e238,e239,e240,e241,e242,e243,e244,e245,e246,e247,
   e248,e249,e250,e251,e252,e253,e254,e255);

{#ED prefix}
function m237:integer;
var
 SubCode:integer;
begin
SubCode:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
asm
 mov al,Z80_Registers.IR.LoByte
 inc al
 and al,$7F
 or al,R_Hi_Bit
 mov Z80_Registers.IR.LoByte,al
end;
Result := Z80_EDTable[SubCode];
end;

Const
 Z80_MainTable:array [0..255] of function:integer=
  (m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19,m20,
   m21,m22,m23,m24,m25,m26,m27,m28,m29,m30,m31,m32,m33,m34,m35,m36,m37,m38,m39,
   m40,m41,m42,m43,m44,m45,m46,m47,m48,m49,m50,m51,m52,m53,m54,m55,m56,m57,m58,
   m59,m60,m61,m62,m63,m64,m65,m66,m67,m68,m69,m70,m71,m72,m73,m74,m75,m76,m77,
   m78,m79,m80,m81,m82,m83,m84,m85,m86,m87,m88,m89,m90,m91,m92,m93,m94,m95,m96,
   m97,m98,m99,m100,m101,m102,m103,m104,m105,m106,m107,m108,m109,m110,m111,m112,
   m113,m114,m115,m116,m117,m118,m119,m120,m121,m122,m123,m124,m125,m126,m127,
   m128,m129,m130,m131,m132,m133,m134,m135,m136,m137,m138,m139,m140,m141,m142,
   m143,m144,m145,m146,m147,m148,m149,m150,m151,m152,m153,m154,m155,m156,m157,
   m158,m159,m160,m161,m162,m163,m164,m165,m166,m167,m168,m169,m170,m171,m172,
   m173,m174,m175,m176,m177,m178,m179,m180,m181,m182,m183,m184,m185,m186,m187,
   m188,m189,m190,m191,m192,m193,m194,m195,m196,m197,m198,m199,m200,m201,m202,
   m203,m204,m205,m206,m207,m208,m209,m210,m211,m212,m213,m214,m215,m216,m217,
   m218,m219,m220,m221,m222,m223,m224,m225,m226,m227,m228,m229,m230,m231,m232,
   m233,m234,m235,m236,m237,m238,m239,m240,m241,m242,m243,m244,m245,m246,m247,
   m248,m249,m250,m251,m252,m253,m254,m255);

function Z80_ExecuteCommand:integer;
var OpCode:integer;
begin
OpCode:=RAM.Index[Z80_Registers.PC];
inc(Z80_Registers.PC);
Result:=Z80_MainTable[OpCode];
end;

end.
