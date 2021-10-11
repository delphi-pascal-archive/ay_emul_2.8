{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit AY;

interface

uses Windows;

const
//Amplitude tables of sound chips
{ (c)Hacker KAY }
 Amplitudes_AY:array[0..15]of Word=
    (0, 836, 1212, 1773, 2619, 3875, 5397, 8823, 10392, 16706, 23339,
    29292, 36969, 46421, 55195, 65535);
{ (c)V_Soft
 Amplitudes_AY:array[0..15]of Word=
    (0, 513, 828, 1239, 1923, 3238, 4926, 9110, 10344, 17876, 24682,
    30442, 38844, 47270, 56402, 65535);}
{ (c)Lion17
 Amplitudes_YM:array[0..31]of Word=
    (0,  30,  190,  286, 375, 470, 560, 664, 866, 1130, 1515, 1803, 2253,
    2848, 3351, 3862, 4844, 6058, 7290, 8559, 10474, 12878, 15297, 17787,
    21500, 26172, 30866, 35676, 42664, 50986, 58842, 65535);}
{ (c)Hacker KAY }
 Amplitudes_YM:array[0..31]of Word=
    (0, 0, $F8, $1C2, $29E, $33A, $3F2, $4D7, $610, $77F, $90A, $A42,
    $C3B, $EC2, $1137, $13A7, $1750, $1BF9, $20DF, $2596, $2C9D, $3579,
    $3E55, $4768, $54FF, $6624, $773B, $883F, $A1DA, $C0FC, $E094, $FFFF);

type

 PArrayOfByte = ^TArrayOfByte;
 TArrayOfByte = packed array[0..0] of byte;

 TRegisterAY = packed record
 case Integer of
  0:(Index:array[0..15]of byte);
  1:(TonA,TonB,TonC: word;
     Noise:byte;
     Mixer:byte;
     AmplitudeA,AmplitudeB,AmplitudeC:byte;
     Envelope:word;
     EnvType:byte);
 end;

//Available soundchips
  ChTypes = (No_Chip, AY_Chip, YM_Chip);

const
 Filt_NKoefs = 32; //powers of 2
type
 TFilt_K = array of integer;
var
 Optimization_For_Quality:boolean = True;
 FilterQuality:integer = 2;
 Filt_M:integer = Filt_NKoefs;
 IsFilt:boolean = True;
 Filt_K,Filt_XL,Filt_XR:TFilt_K;
 Filt_I:integer;
 BeeperMax:integer;
 RegisterAY:TRegisterAY;
 IntFlag:boolean;
 IntBeeper,IntAY:boolean;
 RegNumNext,DatNext:integer;
 Beeper,BeeperNext:integer;
 BeeperLevel:integer;
 Delay_in_tiks:DWORD;
 FrqAyByFrqZ80:Int64;
 SampleRateByFrqZ80:int64;
 Previous_Tact:integer;
 First_Period:boolean;
 Ampl:integer;
 Tik:packed record
 case integer of
 0:(Lo:word;
    Hi:word);
 1:(Re:DWORD);
 end;
 Synthesizer:procedure(Buf:pointer);
 Current_Tik:longword;
 Number_Of_Tiks:packed record
 case boolean of
  False:(lo:longword;
         hi:longword);
  True: (re:int64);
 end;
 Envelope_EnA,Envelope_EnB,Envelope_EnC:boolean;
 Flg:smallint;
 Index_AL,Index_AR,Index_BL,Index_BR,Index_CL,Index_CR:byte;
 ChType:ChTypes = YM_Chip;
 PreAmp:integer = 230;
 PreAmpMax:integer = 255;
 BufP:pointer; //for Z80 emu
 AY_Tiks_In_Interrupt,Sample_Tiks_in_Interrupt:longword;
 ZX_Takt:smallint;
 ZX_Port:word;
 ZX_Port_Data:byte;
 AY_Takt:longint;
 AY_Reg:byte;
 AY_Data:byte;
 Previous_AY_Takt:longint;
 Number_Of_AY_Takts:longint;
 Current_RegisterAY:byte;

procedure SetEnvelopeRegister(Value:byte);
procedure SetMixerRegister(Value:byte);
procedure SetAmplA(Value:byte);
procedure SetAmplB(Value:byte);
procedure SetAmplC(Value:byte);
procedure SetAYRegister(Num:integer;Value:byte);
procedure SetAYRegisterFast(Num:integer;Value:byte);

procedure Synthesizer_Stereo16(Buf:pointer);
procedure Synthesizer_Stereo16_P(Buf:pointer);
procedure Synthesizer_Stereo8(Buf:pointer);
procedure Synthesizer_Stereo8_P(Buf:pointer);
procedure Synthesizer_Mono16(Buf:pointer);
procedure Synthesizer_Mono16_P(Buf:pointer);
procedure Synthesizer_Mono8(Buf:pointer);
procedure Synthesizer_Mono8_P(Buf:pointer);
procedure Case_EnvType_0_3__9;
procedure Case_EnvType_4_7__15;
procedure Case_EnvType_8;
procedure Case_EnvType_10;
procedure Case_EnvType_11;
procedure Case_EnvType_12;
procedure Case_EnvType_13;
procedure Case_EnvType_14;
procedure ResetAYChipEmulation;

procedure SynthesizerZX50(Buf:pointer);
procedure SynthesizerOUT(Buf:pointer);
procedure SynthesizerZXAY(Buf:pointer);
procedure SynthesizerEPSG(Buf:pointer);
procedure SynthesizerYM6(Buf:pointer);
procedure SynthesizerAY;

procedure Calculate_Level_Tables;

implementation

uses WaveOutAPI, Z80, MainWin, Players;

var
    Ton_Counter_A,
    Ton_Counter_B,
    Ton_Counter_C,
    Noise_Counter:packed record
     case integer of
      0:(Lo:word;
         Hi:word);
      1:(Re:longword);
     end;
    Envelope_Counter:packed record
     case integer of
     0:(Lo:dword;
        Hi:dword);
     1:(Re:int64);
     end;
    Ton_A,Ton_B,Ton_C:integer;
    Noise:packed record
     case boolean of
      True: (Seed:longword);
      False:(Low:word;
             Val:dword);
     end;
    Level_AR,Level_AL,
    Level_BR,Level_BL,
    Level_CR,Level_CL:array[0..31]of Integer;
    Left_Chan,Right_Chan:integer;
    Tick_Counter:byte;
    Ton_EnA,Ton_EnB,
    Ton_EnC,Noise_EnA,
    Noise_EnB,Noise_EnC:boolean;
    Case_EnvType:procedure;

type
 TS16 = packed array[0..0] of record
  Left:smallint;
  Right:smallint;
 end;
 PS16 = ^TS16;
 TS8 = packed array[0..0] of record
  Left:byte;
  Right:byte;
 end;
 PS8 = ^TS8;
 TM16 = packed array[0..0] of smallint;
 PM16 = ^TM16;
 TM8 = packed array[0..0] of byte;
 PM8 = ^TM8;

procedure Case_EnvType_0_3__9;
begin
if First_Period then
 begin
  dec(Ampl);
  if Ampl = 0 then First_Period := False
 end
end;

procedure Case_EnvType_4_7__15;
begin
if First_Period then
 begin
  Inc(Ampl);
  if Ampl = 32 then
   begin
    First_Period := False;
    Ampl := 0
   end
 end
end;

procedure Case_EnvType_8;
begin
Ampl := (Ampl - 1) and 31
end;

procedure Case_EnvType_10;
begin
if First_Period then
 begin
  dec(Ampl);
  if Ampl < 0 then
   begin
    First_Period := False;
    Ampl := 0
   end
 end
else
 begin
  inc(Ampl);
  if Ampl = 32 then
   begin
    First_Period := True;
    Ampl := 31
   end
 end
end;

procedure Case_EnvType_11;
begin
if First_Period then
 begin
  dec(Ampl);
  if Ampl < 0 then
   begin
    First_Period := False;
    Ampl := 31
   end
 end
end;

procedure Case_EnvType_12;
begin
Ampl := (Ampl + 1) and 31
end;

procedure Case_EnvType_13;
begin
if First_Period then
 begin
  inc(Ampl);
  if Ampl = 32 then
   begin
    First_Period := False;
    Ampl := 31
   end
 end
end;

procedure Case_EnvType_14;
begin
if not First_Period then
 begin
  dec(Ampl);
  if Ampl < 0 then
   begin
    First_Period := True;
    Ampl := 0
   end
 end
else
 begin
  inc(Ampl);
  if Ampl = 32 then
   begin
    First_Period := False;
    Ampl := 31
   end
 end
end;

procedure Synthesizer_Logic_Q;
begin
inc(Ton_Counter_A.Hi);
if Ton_Counter_A.Hi >= RegisterAY.TonA then
 begin
  Ton_Counter_A.Hi := 0;
  Ton_A := Ton_A xor 1
 end;
inc(Ton_Counter_B.Hi);
if Ton_Counter_B.Hi >= RegisterAY.TonB then
 begin
  Ton_Counter_B.Hi := 0;
  Ton_B := Ton_B xor 1
 end;
inc(Ton_Counter_C.Hi);
if Ton_Counter_C.Hi >= RegisterAY.TonC then
 begin
  Ton_Counter_C.Hi := 0;
  Ton_C := Ton_C xor 1
 end;
inc(Noise_Counter.Hi);
if (Noise_Counter.Hi and 1 = 0) and
   (Noise_Counter.Hi >= RegisterAY.Noise shl 1) then
 begin
  Noise_Counter.Hi := 0;
  asm
  mov eax,Noise.Seed
  shld edx,eax,16
  shld ecx,eax,19
  xor ecx,edx
  and ecx,1
  add eax,eax
  and eax,$1ffff
  inc eax
  xor eax,ecx
  mov Noise.Seed,eax
  end
 end;
if Envelope_Counter.Hi = 0 then Case_EnvType;
inc(Envelope_Counter.Hi);
if Envelope_Counter.Hi >= RegisterAY.Envelope then
 Envelope_Counter.Hi := 0
end;

procedure Synthesizer_Logic_P;
var
 k:word;
 k2:longword;
begin

inc(Ton_Counter_A.Re,Delay_In_Tiks);
k := RegisterAY.TonA; if k = 0 then inc(k);
if k <= Ton_Counter_A.Hi then
 begin
  Ton_A := Ton_A xor ((Ton_Counter_A.Hi div k) and 1);
  Ton_Counter_A.Hi := Ton_Counter_A.Hi mod k
 end;

inc(Ton_Counter_B.Re,Delay_In_Tiks);
k := RegisterAY.TonB; if k = 0 then inc(k);
if k <= Ton_Counter_B.Hi then
 begin
  Ton_B := Ton_B xor ((Ton_Counter_B.Hi div k) and 1);
  Ton_Counter_B.Hi := Ton_Counter_B.Hi mod k
 end;

inc(Ton_Counter_C.Re,Delay_In_Tiks);
k := RegisterAY.TonC; if k = 0 then inc(k);
if k <= Ton_Counter_C.Hi then
 begin
  Ton_C := Ton_C xor ((Ton_Counter_C.Hi div k) and 1);
  Ton_Counter_C.Hi := Ton_Counter_C.Hi mod k
 end;

inc(Noise_Counter.Re,Delay_In_Tiks);
k := RegisterAY.Noise; if k = 0 then inc(k);
k := k shl 1;
if Noise_Counter.Hi >= k then
 begin
  Noise_Counter.Hi := Noise_Counter.Hi mod k;
  asm
  mov eax,Noise.Seed
  shld edx,eax,16
  shld ecx,eax,19
  xor ecx,edx
  and ecx,1
  add eax,eax
  and eax,$1ffff
  inc eax
  xor eax,ecx
  mov Noise.Seed,eax
  end
 end;

k2 := RegisterAY.Envelope; if k2 = 0 then inc(k2);
if Envelope_Counter.Hi = 0 then inc(Envelope_Counter.Hi,k2);
while (Envelope_Counter.Hi >= k2) do
 begin
  dec(Envelope_Counter.Hi,k2);
  Case_EnvType
 end;
inc(Envelope_Counter.Re,int64(Delay_In_Tiks) shl 16)
end;

procedure SetMixerRegister(Value:byte);
begin
RegisterAY.Mixer := Value;
Ton_EnA := (Value and 1) = 0;
Noise_EnA := (Value and 8) = 0;
Ton_EnB := (Value and 2) = 0;
Noise_EnB := (Value and 16) = 0;
Ton_EnC := (Value and 4) = 0;
Noise_EnC := (Value and 32) = 0
end;

procedure SetEnvelopeRegister(Value:byte);
begin
Envelope_Counter.Hi := 0;
First_Period := True;
if (Value and 4) = 0 then
 ampl := 32
else
 ampl := -1;
RegisterAY.EnvType := Value;
Case Value of
0..3,9: Case_EnvType := Case_EnvType_0_3__9;
4..7,15:Case_EnvType := Case_EnvType_4_7__15;
8:      Case_EnvType := Case_EnvType_8;
10:     Case_EnvType := Case_EnvType_10;
11:     Case_EnvType := Case_EnvType_11;
12:     Case_EnvType := Case_EnvType_12;
13:     Case_EnvType := Case_EnvType_13;
14:     Case_EnvType := Case_EnvType_14;
end;
end;

procedure SetAmplA(Value:byte);
begin
RegisterAY.AmplitudeA := Value;
Envelope_EnA := (Value and 16) = 0;
end;

procedure SetAmplB(Value:byte);
begin
RegisterAY.AmplitudeB := Value;
Envelope_EnB := (Value and 16) = 0;
end;

procedure SetAmplC(Value:byte);
begin
RegisterAY.AmplitudeC := Value;
Envelope_EnC := (Value and 16) = 0;
end;

procedure SetAYRegister(Num:integer;Value:byte);
begin
case Num of
13:
 SetEnvelopeRegister(Value and 15);
1,3,5:
 RegisterAY.Index[Num] := Value and 15;
6:
 RegisterAY.Noise := Value and 31;
7: SetMixerRegister(Value and 63);
8: SetAmplA(Value and 31);
9: SetAmplB(Value and 31);
10:SetAmplC(Value and 31);
0,2,4,11,12:
 RegisterAY.Index[Num] := Value
end
end;

procedure SetAYRegisterFast(Num:integer;Value:byte);
begin
case Num of
13:
 SetEnvelopeRegister(Value);
1,3,5:
 RegisterAY.Index[Num] := Value;
6:
 RegisterAY.Noise := Value;
7: SetMixerRegister(Value);
8: SetAmplA(Value);
9: SetAmplB(Value);
10:SetAmplC(Value);
0,2,4,11,12:
 RegisterAY.Index[Num] := Value
end
end;

//sorry for assembler, I can't make effective qword procedure on pascal...
function ApplyFilter(Lev:integer;var Filt_X:TFilt_K):integer;
asm
        push    ebx
        push    esi
        push    edi
        add     esp,-8
        mov     ecx,Filt_M
        mov     edi,Filt_K
        lea     esi,edi+ecx*4
        mov     ebx,[edx]
        mov     ecx,Filt_I
        mov     [ebx+ecx*4],eax
        imul    dword ptr [edi]
        mov     [esp],eax
        mov     [esp+4],edx
@lp:    dec     ecx
        jns     @gz
        mov     ecx,Filt_M
@gz:    mov     eax,[ebx+ecx*4]
        add     edi,4
        imul    dword ptr [edi]
        add     [esp],eax
        adc     [esp+4],edx
        cmp     edi,esi
        jnz     @lp
        mov     Filt_I,ecx
        pop     eax
        pop     edx
        pop     edi
        pop     esi
        pop     ebx
        test    edx,edx
        jns     @nm
        add     eax,0FFFFFFh
        adc     edx,0
@nm:    shrd    eax,edx,24
end;

procedure Synthesizer_Mixer_Q;
var
 LevL,LevR,k:integer;
begin
LevL := Beeper;
LevR := LevL;

k := 1;
if Ton_EnA then k := Ton_A;
if Noise_EnA then k := k and Noise.Val;
if k <> 0 then
 begin
  if Envelope_EnA then
   begin
    inc(LevL,Level_AL[RegisterAY.AmplitudeA * 2 + 1]);
    inc(LevR,Level_AR[RegisterAY.AmplitudeA * 2 + 1])
   end
  else
   begin
    inc(LevL,Level_AL[Ampl]);
    inc(LevR,Level_AR[Ampl])
   end
 end;

k := 1;
if Ton_EnB then k := Ton_B;
if Noise_EnB then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnB then
  begin
   inc(LevL,Level_BL[RegisterAY.AmplitudeB * 2 + 1]);
   inc(LevR,Level_BR[RegisterAY.AmplitudeB * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_BL[Ampl]);
   inc(LevR,Level_BR[Ampl])
  end;

k := 1;
if Ton_EnC then k := Ton_C;
if Noise_EnC then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnC then
  begin
   inc(LevL,Level_CL[RegisterAY.AmplitudeC * 2 + 1]);
   inc(LevR,Level_CR[RegisterAY.AmplitudeC * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_CL[Ampl]);
   inc(LevR,Level_CR[Ampl])
  end;

if IsFilt then
 begin
  k := Filt_I;
  LevL := ApplyFilter(LevL,Filt_XL);
  Filt_I := k;
  LevR := ApplyFilter(LevR,Filt_XR)
 end;
 
inc(Left_Chan,LevL);
inc(Right_Chan,LevR)
end;

procedure FillVis;
begin
with VisPoints[MkVisPos], RegisterAY do
 begin
  TnA := TonA;
  TnB := TonB;
  TnC := TonC;
  Mix := Mixer;
  AmpA := AmplitudeA;
  AmpB := AmplitudeB;
  AmpC := AmplitudeC;
  AmpE := Ampl;
  EnvP := Envelope;
  EnvT := EnvType;
  Calc := 0
 end;
Inc(MkVisPos);
if MkVisPos >= VisPosMax then MkVisPos := 0;
Inc(VisPoint,VisStep)
end;

procedure Synthesizer_Stereo16;
var
 Tmp:integer;
begin
repeat
Synthesizer_Logic_Q;
Synthesizer_Mixer_Q;
Inc(Current_Tik);
Inc(Tick_Counter);
if Tick_Counter >= Tik.Hi then
 begin
  Inc(Tik.Re,Delay_In_Tiks);
  Dec(Tik.Hi,Tick_Counter);
  if NOfTicks = VisPoint then FillVis;
  Inc(NOfTicks);
  Tmp := Left_Chan div Tick_Counter;
  if Tmp > 32767 then
   Tmp := 32767
  else if Tmp < -32768 then
   Tmp := -32768;
  PS16(Buf)^[BuffLen].Left := Tmp;
  Tmp := Right_Chan div Tick_Counter;
  if Tmp > 32767 then
   Tmp := 32767
  else if Tmp < -32768 then
   Tmp := -32768;
  PS16(Buf)^[BuffLen].Right := Tmp;
  Inc(BuffLen);
  Tmp := 0;
  Left_Chan:= Tmp;
  Right_Chan := Tmp;
  Tick_Counter := Tmp;
  if BuffLen = BufferLength then
   begin
    if Current_Tik < Number_Of_Tiks.Hi then
     IntFlag := True;
    exit
   end
 end
until Current_Tik >= Number_Of_Tiks.Hi;
Tmp := 0;
Number_Of_Tiks.hi := Tmp;
Current_Tik := Tmp
end;

procedure Synthesizer_Stereo8;
var
 Tmp:integer;
begin
repeat
Synthesizer_Logic_Q;
Synthesizer_Mixer_Q;
Inc(Current_Tik);
Inc(Tick_Counter);
if Tick_Counter >= Tik.Hi then
 begin
  Inc(Tik.Re,Delay_In_Tiks);
  Dec(Tik.Hi,Tick_Counter);
  if NOfTicks = VisPoint then FillVis;
  Inc(NOfTicks);
  Tmp := Left_Chan div Tick_Counter;
  if Tmp > 127 then
   Tmp := 127
  else if Tmp < -128 then
   Tmp := -128;
  PS8(Buf)^[BuffLen].Left := 128 + Tmp;
  Tmp := Right_Chan div Tick_Counter;
  if Tmp > 127 then
   Tmp := 127
  else if Tmp < -128 then
   Tmp := -128;
  PS8(Buf)^[BuffLen].Right := 128 + Tmp;
  Inc(BuffLen);
  Tmp := 0;
  Left_Chan := Tmp;
  Right_Chan := Tmp;
  Tick_Counter := Tmp;
  if BuffLen = BufferLength then
   begin
    if Current_Tik < Number_Of_Tiks.Hi then
     IntFlag := True;
    exit
   end
 end
until Current_Tik >= Number_Of_Tiks.Hi;
Tmp := 0;
Number_Of_Tiks.hi := Tmp;
Current_Tik := Tmp
end;

procedure Synthesizer_Mixer_Q_Mono;
var
 Lev,k:integer;
begin
Lev := Beeper;

k := 1;
if Ton_EnA then k := Ton_A;
if Noise_EnA then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnA then
  inc(Lev,Level_AL[RegisterAY.AmplitudeA * 2 + 1])
 else
  inc(Lev,Level_AL[Ampl]);

k := 1;
if Ton_EnB then k := Ton_B;
if Noise_EnB then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnB then
  inc(Lev,Level_BL[RegisterAY.AmplitudeB * 2 + 1])
 else
  inc(Lev,Level_BL[Ampl]);

k := 1;
if Ton_EnC then k := Ton_C;
if Noise_EnC then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnC then
  inc(Lev,Level_CL[RegisterAY.AmplitudeC * 2 + 1])
 else
  inc(Lev,Level_CL[Ampl]);

if IsFilt then
 Lev := ApplyFilter(Lev,Filt_XL);
 
inc(Left_Chan,Lev)
end;

procedure Synthesizer_Mono16;
var
 Tmp:integer;
begin
repeat
Synthesizer_Logic_Q;
Synthesizer_Mixer_Q_Mono;
Inc(Current_Tik);
Inc(Tick_Counter);
if Tick_Counter >= Tik.Hi then
 begin
  Inc(Tik.Re,Delay_In_Tiks);
  Dec(Tik.Hi,Tick_Counter);
  if NOfTicks = VisPoint then FillVis;
  Inc(NOfTicks);
  Tmp := Left_Chan div Tick_Counter;
  if Tmp > 32767 then
   Tmp := 32767
  else if Tmp < -32768 then
   Tmp := -32768;
  PM16(Buf)^[BuffLen] := Tmp;
  Inc(BuffLen);
  Tmp := 0;
  Left_Chan := Tmp;
  Tick_Counter := Tmp;
  if BuffLen = BufferLength then
   begin
    if Current_Tik < Number_Of_Tiks.Hi then
     IntFlag := True;
    exit
   end
 end
until Current_Tik >= Number_Of_Tiks.Hi;
Tmp := 0;
Number_Of_Tiks.hi := Tmp;
Current_Tik := Tmp
end;

procedure Synthesizer_Mono8;
var
 Tmp:integer;
begin
repeat
Synthesizer_Logic_Q;
Synthesizer_Mixer_Q_Mono;
Inc(Current_Tik);
Inc(Tick_Counter);
if Tick_Counter >= Tik.Hi then
 begin
  Inc(Tik.Re,Delay_In_Tiks);
  Dec(Tik.Hi,Tick_Counter);
  if NOfTicks = VisPoint then FillVis;
  Inc(NOfTicks);
  Tmp := Left_Chan div Tick_Counter;
  if Tmp > 127 then
   Tmp := 127
  else if Tmp < -128 then
   Tmp := -128;
  PM8(Buf)^[BuffLen] := 128 + Tmp;
  Inc(BuffLen);
  Tmp := 0;
  Left_Chan := Tmp;
  Tick_Counter := Tmp;
  if BuffLen = BufferLength then
   begin
    if Current_Tik < Number_Of_Tiks.Hi then
     IntFlag := True;
    exit
   end
 end
until Current_Tik >= Number_Of_Tiks.Hi;
Tmp := 0;
Number_Of_Tiks.hi := Tmp;
Current_Tik := Tmp
end;

procedure Synthesizer_Stereo16_P;
var
 LevL,LevR,k:integer;
begin
repeat
Synthesizer_Logic_P;
LevL := Beeper;
LevR := LevL;

k := 1;
if Ton_EnA then k := Ton_A;
if Noise_EnA then k := k and Noise.Val;
 if k <> 0 then
  if Envelope_EnA then
   begin
    inc(LevL,Level_AL[RegisterAY.AmplitudeA * 2 + 1]);
    inc(LevR,Level_AR[RegisterAY.AmplitudeA * 2 + 1])
   end
  else
   begin
    inc(LevL,Level_AL[Ampl]);
    inc(LevR,Level_AR[Ampl])
   end;

k := 1;
if Ton_EnB then k := Ton_B;
if Noise_EnB then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnB then
  begin
   inc(LevL,Level_BL[RegisterAY.AmplitudeB * 2 + 1]);
   inc(LevR,Level_BR[RegisterAY.AmplitudeB * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_BL[Ampl]);
   inc(LevR,Level_BR[Ampl])
  end;

k := 1;
if Ton_EnC then k := Ton_C;
if Noise_EnC then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnC then
  begin
   inc(LevL,Level_CL[RegisterAY.AmplitudeC * 2 + 1]);
   inc(LevR,Level_CR[RegisterAY.AmplitudeC * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_CL[Ampl]);
   inc(LevR,Level_CR[Ampl])
  end;

if NOfTicks = VisPoint then FillVis;
Inc(NOfTicks);
PS16(Buf)^[BuffLen].Left := LevL;
PS16(Buf)^[BuffLen].Right := LevR;
Inc(BuffLen);
inc(Current_Tik);
if BuffLen = BufferLength then
 begin
  if Current_Tik < Number_Of_Tiks.Hi then
   IntFlag := True;
  exit
 end;
until Current_Tik >= Number_Of_Tiks.Hi;
k := 0;
Number_Of_Tiks.hi := k;
Current_Tik := k
end;

procedure Synthesizer_Stereo8_P;
var
 LevL,LevR,k:integer;
begin
repeat
Synthesizer_Logic_P;
LevL := 128 + Beeper;
LevR := LevL;

k := 1;
if Ton_EnA then k := Ton_A;
if Noise_EnA then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnA then
  begin
   inc(LevL,Level_AL[RegisterAY.AmplitudeA * 2 + 1]);
   inc(LevR,Level_AR[RegisterAY.AmplitudeA * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_AL[Ampl]);
   inc(LevR,Level_AR[Ampl])
  end;

k := 1;
if Ton_EnB then k := Ton_B;
if Noise_EnB then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnB then
  begin
   inc(LevL,Level_BL[RegisterAY.AmplitudeB * 2 + 1]);
   inc(LevR,Level_BR[RegisterAY.AmplitudeB * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_BL[Ampl]);
   inc(LevR,Level_BR[Ampl])
  end;

k := 1;
if Ton_EnC then k := Ton_C;
if Noise_EnC then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnC then
  begin
   inc(LevL,Level_CL[RegisterAY.AmplitudeC * 2 + 1]);
   inc(LevR,Level_CR[RegisterAY.AmplitudeC * 2 + 1])
  end
 else
  begin
   inc(LevL,Level_CL[Ampl]);
   inc(LevR,Level_CR[Ampl])
  end;

if NOfTicks = VisPoint then FillVis;
Inc(NOfTicks);
PS8(Buf)^[BuffLen].Left := LevL;
PS8(Buf)^[BuffLen].Right := LevR;
Inc(BuffLen);
Inc(Current_Tik);
if BuffLen = BufferLength then
 begin
  if Current_Tik < Number_Of_Tiks.Hi then
   IntFlag := True;
  exit
 end
until Current_Tik >= Number_Of_Tiks.Hi;
k := 0;
Number_Of_Tiks.hi := k;
Current_Tik := k
end;

procedure Synthesizer_Mono16_P;
var
 Lev,k:integer;
begin
repeat
Synthesizer_Logic_P;
Lev := Beeper;

k := 1;
if Ton_EnA then k := Ton_A;
if Noise_EnA then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnA then
  inc(Lev,Level_AL[RegisterAY.AmplitudeA * 2 + 1])
 else
  inc(Lev,Level_AL[Ampl]);

k := 1;
if Ton_EnB then k := Ton_B;
if Noise_EnB then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnB then
  inc(Lev,Level_BL[RegisterAY.AmplitudeB * 2 + 1])
 else
  inc(Lev,Level_BL[Ampl]);

k := 1;
if Ton_EnC then k := Ton_C;
if Noise_EnC then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnC then
  inc(Lev,Level_CL[RegisterAY.AmplitudeC * 2 + 1])
 else
  inc(Lev,Level_CL[Ampl]);

if NOfTicks = VisPoint then FillVis;
Inc(NOfTicks);
PM16(Buf)^[BuffLen] := Lev;
Inc(BuffLen);
Inc(Current_Tik);
if BuffLen = BufferLength then
 begin
  if Current_Tik < Number_Of_Tiks.Hi then
   IntFlag := True;
  exit
 end
until Current_Tik >= Number_Of_Tiks.Hi;
k := 0;
Number_Of_Tiks.hi := k;
Current_Tik := k
end;

procedure Synthesizer_Mono8_P;
var
 Lev,k:integer;
begin
repeat
Synthesizer_Logic_P;
Lev := 128 + Beeper;

k := 1;
if Ton_EnA then k := Ton_A;
if Noise_EnA then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnA then
  inc(Lev,Level_AL[RegisterAY.AmplitudeA * 2 + 1])
 else
  inc(Lev,Level_AL[Ampl]);

k := 1;
if Ton_EnB then k := Ton_B;
if Noise_EnB then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnB then
  inc(Lev,Level_BL[RegisterAY.AmplitudeB * 2 + 1])
 else
  inc(Lev,Level_BL[Ampl]);

k := 1;
if Ton_EnC then k := Ton_C;
if Noise_EnC then k := k and Noise.Val;
if k <> 0 then
 if Envelope_EnC then
  inc(Lev,Level_CL[RegisterAY.AmplitudeC*2+1])
 else
  inc(Lev,Level_CL[Ampl]);

if NOfTicks = VisPoint then FillVis;
Inc(NOfTicks);
PM8(Buf)^[BuffLen] := Lev;
Inc(BuffLen);
Inc(Current_Tik);
if BuffLen = BufferLength then
 begin
  if Current_Tik < Number_Of_Tiks.Hi then
   IntFlag := True;
  exit
 end
until Current_Tik >= Number_Of_Tiks.Hi;
k := 0;
Number_Of_Tiks.hi := k;
Current_Tik := k
end;

procedure ResetAYChipEmulation;
begin
Flg := 0;
IntFlag := False;
Number_Of_Tiks.Re := 0;
Current_Tik := 0;
Envelope_Counter.Re := 0;
Ton_Counter_A.Re := 0;
Ton_Counter_B.Re := 0;
Ton_Counter_C.Re := 0;
Noise_Counter.Re := 0;
Ton_A := 0;
Ton_B := 0;
Ton_C := 0;
Left_Chan := 0; Right_Chan := 0;
Tick_Counter := 0;
Tik.Re := Delay_In_Tiks;
Noise.Seed := $FFFF;
Noise.Val := 0
end;

procedure Calculate_Level_Tables;
var
 i,b,l,r:integer;
 Index_A,Index_B,Index_C:integer;
 k:real;
begin
Index_A := Index_AL; Index_B := Index_BL; Index_C := Index_CL;
l := Index_A + Index_B + Index_C;
r := Index_AR + Index_BR + Index_CR;
if NumberOfChannels = 2 then
 begin
  if l < r then
   l := r;
 end
else
 begin
  l := l + r;
  Inc(Index_A,Index_AR);
  Inc(Index_B,Index_BR);
  Inc(Index_C,Index_CR)
 end;
if l = 0 then Inc(l);
if SampleBit = 8 then
 r := 127
else
 r := 32767;
l := 255*r div l;
case ChType of
AY_Chip:
 for i := 0 to 15 do
  begin
   b := round(Index_A/255*Amplitudes_AY[i]);
   b := round(b/65535*l);
   Level_AL[i*2] := b; Level_AL[i*2 + 1] := b;
   b := round(Index_AR/255*Amplitudes_AY[i]);
   b := round(b/65535*l);
   Level_AR[i*2] := b; Level_AR[i*2 + 1] := b;
   b := round(Index_B/255*Amplitudes_AY[i]);
   b := round(b/65535*l);
   Level_BL[i*2] := b; Level_BL[i*2 + 1] := b;
   b := round(Index_BR/255*Amplitudes_AY[i]);
   b := round(b/65535*l);
   Level_BR[i*2] := b; Level_BR[i*2 + 1] := b;
   b := round(Index_C/255*Amplitudes_AY[i]);
   b := round(b/65535*l);
   Level_CL[i*2] := b; Level_CL[i*2 + 1] := b;
   b := round(Index_CR/255*Amplitudes_AY[i]);
   b := round(b/65535*l);
   Level_CR[i*2] := b; Level_CR[i*2 + 1] := b
  end;
YM_Chip:
 for i := 0 to 31 do
  begin
   b := round(Index_A/255*Amplitudes_YM[i]);
   Level_AL[i] := round(b/65535*l);
   b := round(Index_AR/255*Amplitudes_YM[i]);
   Level_AR[i] := round(b/65535*l);
   b := round(Index_B/255*Amplitudes_YM[i]);
   Level_BL[i] := round(b/65535*l);
   b := round(Index_BR/255*Amplitudes_YM[i]);
   Level_BR[i] := round(b/65535*l);
   b := round(Index_C/255*Amplitudes_YM[i]);
   Level_CL[i] := round(b/65535*l);
   b := round(Index_CR/255*Amplitudes_YM[i]);
   Level_CR[i] := round(b/65535*l)
  end
end;
//k := (exp(PreAmp*ln(2)/PreAmpMax) - 1);
k := PreAmp / PreAmpMax; //linear from version 2.7 fix 2
                         //because of volume control is system now 
for i := 0 to 31 do
 begin
  Level_AL[i] := round(Level_AL[i]*k);
  Level_AR[i] := round(Level_AR[i]*k);
  Level_BL[i] := round(Level_BL[i]*k);
  Level_BR[i] := round(Level_BR[i]*k);
  Level_CL[i] := round(Level_CL[i]*k);
  Level_CR[i] := round(Level_CR[i]*k)
 end;
if SampleBit = 8 then
 BeeperLevel := -round(BeeperMax div 2 * k)
else
 BeeperLevel := -round(BeeperMax * 128 * k)
end;

procedure SynthesizerAY;
asm
  cmp IntFlag,0
  jnz @me
  mov eax,CurrentTact
  sub eax,Previous_Tact
  mov ecx,eax
  cmp Optimization_For_Quality,0
  jnz @me1
  mul dword ptr [SampleRateByFrqZ80]
  xchg eax,ecx
  push edx
  mul dword ptr [SampleRateByFrqZ80 + 4]
  jmp @me3
@me1:
  mul dword ptr [FrqAyByFrqZ80]
  xchg eax,ecx
  push edx
  mul dword ptr [FrqAyByFrqZ80 + 4]
@me3:
  pop edx
  add eax,edx
  add ecx,Number_Of_Tiks.lo
  adc eax,Number_Of_Tiks.hi
  jz @me2
  mov Number_Of_Tiks.hi,eax
  mov Number_Of_Tiks.lo,ecx
  mov eax,CurrentTact
  mov Previous_Tact,eax
  mov eax,edx
@me:
  mov IntFlag,0
  mov eax,BufP
  call [Synthesizer]
@me2:
end;

procedure SynthesizerZX50;
begin
if not IntFlag then
 begin
 if Optimization_For_Quality then
  Number_Of_Tiks.hi := AY_Tiks_In_Interrupt
 else
  Number_Of_Tiks.hi := Sample_Tiks_In_Interrupt
 end
else
 IntFlag := False;
Synthesizer(Buf)
end;

procedure SynthesizerOUT;
var
 ZX_Takt2:smallint;
 Number_Of_Takts:smallInt;
 N_Of_Tiks:packed record
     case boolean of
      false:(lo:longword;
             hi:longword);
      true: (re:int64);
     end;
begin
if not IntFlag then
 begin
 if ZX_Takt=-1 then ZX_Takt2:=0 else ZX_Takt2:=ZX_Takt;
 Number_Of_Takts:=ZX_Takt2-Previous_AY_Takt;
 if (Number_Of_Takts<=0) then inc(Number_Of_Takts,17472)
 else if (flg>0) then inc(Number_Of_Takts,17472);
 if Optimization_For_Quality then
  N_Of_Tiks.Re:=Number_Of_Tiks.Re+
                 Number_Of_Takts*FrqAyByFrqZ80
 else N_Of_Tiks.Re:=Number_Of_Tiks.Re+
                 Number_Of_Takts*SamplerateByFrqZ80;
 if N_Of_Tiks.Hi=0 then
  begin
  if ZX_Takt2=0 then inc(Flg);
  exit;
  end;
 Flg:=0;
 Number_Of_Tiks.Re := N_Of_Tiks.Re;
 Previous_AY_Takt:=ZX_Takt2;
 end
else
 IntFlag:=False;
Synthesizer(Buf)
end;

procedure SynthesizerYM6;
begin
if not IntFlag then
 begin
  inc(Number_Of_Tiks.re,YM6Tiks);
  if Number_Of_Tiks.hi = 0 then exit
 end
else
 IntFlag := False;
Synthesizer(Buf)
end;

procedure SynthesizerEPSG;
var
 N_Of_Tiks:packed record
     case boolean of
      false:(lo:longword;
             hi:longword);
      true: (re:int64);
     end;
begin
if not IntFlag then
 begin
  Number_Of_AY_Takts := AY_Takt - Previous_AY_Takt;
  if Optimization_For_Quality then
   N_Of_Tiks.Re := Number_Of_Tiks.Re + Number_Of_AY_Takts * FrqAyByFrqZ80
  else
   N_Of_Tiks.Re := Number_Of_Tiks.Re + Number_Of_AY_Takts * SampleRateByFrqZ80;
  if N_Of_Tiks.hi = 0 then exit;
  Number_Of_Tiks.Re := N_Of_Tiks.Re;
  Previous_AY_Takt := AY_Takt
 end
else
 IntFlag := False;
Synthesizer(Buf)
end;

procedure SynthesizerZXAY;
var
 N_Of_Tiks:packed record
     case boolean of
      false:(lo:longword;
             hi:longword);
      true: (re:int64);
     end;
begin
if not IntFlag then
 begin
  Number_Of_AY_Takts := AY_Takt - Previous_AY_Takt;
  if (Number_Of_AY_Takts <= 0) then inc(Number_Of_AY_Takts,$100000)
  else if (flg > 0) then inc(Number_Of_AY_Takts,$100000);
  if Optimization_For_Quality then
   N_Of_Tiks.Re := Number_Of_Tiks.Re + Number_Of_AY_Takts*FrqAyByFrqZ80
  else
   N_Of_Tiks.Re := Number_Of_Tiks.Re + Number_Of_AY_Takts*SampleRateByFrqZ80;
  if N_Of_Tiks.hi = 0 then
   begin
    if AY_Takt = 0 then inc(Flg);
    exit
   end;
  Flg := 0;
  Number_Of_Tiks.Re := N_Of_Tiks.Re;
  Previous_AY_Takt := AY_Takt
 end
else
 IntFlag := False;
Synthesizer(Buf);
end;

end.
