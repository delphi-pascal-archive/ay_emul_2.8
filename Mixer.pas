{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit Mixer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, SelVolCtrl, MMSystem;

type
  TSysMixers = array of record
   ID:integer;
   Caps:TMIXERCAPS;
   Dests:array of record
    Line:TMIXERLINE;
    LCtrls:TMIXERLINECONTROLS;
    Ctrls:array of TMIXERCONTROL;
   end;
  end;
  TForm2 = class(TForm)
    MixerTabSheet: TPageControl;
    AYEmuSheet: TTabSheet;
    KUsil: TGroupBox;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel2: TBevel;
    Bevel18: TBevel;
    Bevel19: TBevel;
    Bevel20: TBevel;
    Bevel17: TBevel;
    Bevel21: TBevel;
    Bevel23: TBevel;
    Bevel24: TBevel;
    Bevel22: TBevel;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit6: TEdit;
    Edit5: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit14: TEdit;
    TrackBar7: TTrackBar;
    Edit20: TEdit;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    CheckBox3: TCheckBox;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit18: TEdit;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    Edit19: TEdit;
    GroupBox7: TGroupBox;
    RadioButton15: TRadioButton;
    Edit21: TEdit;
    RadioButton16: TRadioButton;
    Edit22: TEdit;
    CheckBox9: TCheckBox;
    Edit23: TEdit;
    RadioButton17: TRadioButton;
    Edit24: TEdit;
    GroupBox8: TGroupBox;
    RadioButton18: TRadioButton;
    RadioButton19: TRadioButton;
    RadioButton20: TRadioButton;
    Edit25: TEdit;
    Edit26: TEdit;
    Edit27: TEdit;
    GroupBox9: TGroupBox;
    RadioButton21: TRadioButton;
    RadioButton22: TRadioButton;
    RadioButton25: TRadioButton;
    Edit28: TEdit;
    Edit29: TEdit;
    Edit32: TEdit;
    WOSheet: TTabSheet;
    GroupBox3: TGroupBox;
    RadioButton23: TRadioButton;
    StaticText14: TStaticText;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    GroupBox5: TGroupBox;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    GroupBox4: TGroupBox;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    Button1: TButton;
    RadioButton24: TRadioButton;
    StaticText15: TStaticText;
    RadioButton27: TRadioButton;
    Edit31: TEdit;
    SpeedButton1: TSpeedButton;
    Button2: TButton;
    SpeedButton2: TSpeedButton;
    Buff: TGroupBox;
    LbLen: TLabel;
    LbNum: TLabel;
    Label4: TLabel;
    LBTot: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TrackBar8: TTrackBar;
    TrackBar9: TTrackBar;
    GroupBox10: TGroupBox;
    ComboBox2: TComboBox;
    BASSSheet: TTabSheet;
    GroupBox11: TGroupBox;
    FFTTyp: TLabel;
    Label10: TLabel;
    TrackBar11: TTrackBar;
    TrackBar12: TTrackBar;
    Label2: TLabel;
    aminmax: TLabel;
    TrackBar13: TTrackBar;
    Edit30: TEdit;
    VolumeSheet: TTabSheet;
    Button3: TButton;
    Button4: TButton;
    Label3: TLabel;
    Edit33: TEdit;
    CheckBox10: TCheckBox;
    GroupBox12: TGroupBox;
    Label12: TLabel;
    Label13: TLabel;
    RadioButton26: TRadioButton;
    RadioButton28: TRadioButton;
    TrackBar14: TTrackBar;
    FTact: TEdit;
    Label7: TLabel;
    CheckBox39: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    procedure TrackBar1Change(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure Edit3Exit(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure Edit4Exit(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure Edit5Exit(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure Edit6Exit(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure Set_Frqs;
    procedure Set_Z80Frqs;
    procedure Edit11Exit(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton12Click(Sender: TObject);
    procedure RadioButton13Click(Sender: TObject);
    procedure RadioButton14Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Change_Show(TB:TTrackBar;E1,E2:TEdit;NewVal:Byte;var Ind:Byte);
    procedure RadioButton15Click(Sender: TObject);
    procedure RadioButton16Click(Sender: TObject);
    procedure Set_Pl_Frqs;
    procedure Edit22Exit(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SetMixerParams;
    procedure SetChanIndexes(Temp:integer);
    procedure FormCreate(Sender: TObject);
    procedure RadioButton17Click(Sender: TObject);
    procedure RadioButton20Click(Sender: TObject);
    procedure Set_MFPFrqs;
    procedure Edit25Exit(Sender: TObject);
    procedure RadioButton18Click(Sender: TObject);
    procedure RadioButton19Click(Sender: TObject);
    procedure RadioButton25Click(Sender: TObject);
    procedure RadioButton22Click(Sender: TObject);
    procedure RadioButton21Click(Sender: TObject);
    procedure Edit32Exit(Sender: TObject);
    procedure Edit19Exit(Sender: TObject);
    procedure Edit20Exit(Sender: TObject);
    procedure Change_Show2(TB:TTrackBar;E1:TEdit;NewVal:byte;var Ind:integer);
    procedure TrackBar7Change(Sender: TObject);
    procedure RadioButton23Click(Sender: TObject);
    procedure RadioButton24Click(Sender: TObject);
    procedure SetSRs;
    procedure Edit31Exit(Sender: TObject);
    procedure RadioButton27Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure TrackBar8Change(Sender: TObject);
    procedure TrackBar9Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure TrackBar11Change(Sender: TObject);
    procedure TrackBar12Change(Sender: TObject);
    procedure TrackBar13Change(Sender: TObject);
    procedure Edit30Exit(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure TrackBar14Change(Sender: TObject);
    procedure RadioButton28Click(Sender: TObject);
    procedure RadioButton26Click(Sender: TObject);
    procedure FTactExit(Sender: TObject);
    procedure CheckBox39Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FrqAYTemp,FrqPlTemp,FrqMFPTemp:longword;
  end;

procedure GetSystemMixers(var Mixers:TSysMixers);
function DetectVolumeCtrl:boolean;
function DetectVolumeCtrl2(var Mixers:TSysMixers):boolean;
function SelectMixerControl(var Mixers:TSysMixers;i,j,k:integer):boolean;

var
  Form2: TForm2;
  SysVolumeParams:record
   Title:string;
   MixerNumber,DestNumber,CtrlNumber,MixerID,
   Max,Min,Pos,ControlID,Chans:integer;
   Balans,Vals:array of TMIXERCONTROLDETAILS_UNSIGNED;
   MixerHandle:HMIXER;
   Opened:boolean;
  end;

implementation

uses MainWin, Tools, WaveOutAPI, AY, Z80, lightBASS, BASScode;

{$R *.DFM}

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
Form1.SetChan2(TrackBar1.Position,0)
end;

procedure TForm2.Edit1Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit1.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Form1.SetChan2(A,0)
else
 Edit1.Text := IntToStr(TrackBar1.Position)
end;

procedure TForm2.TrackBar2Change(Sender: TObject);
begin
Form1.SetChan2(TrackBar2.Position,1)
end;

procedure TForm2.Edit2Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit2.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Form1.SetChan2(A,1)
else
 Edit2.Text := IntToStr(TrackBar2.Position)
end;

procedure TForm2.TrackBar3Change(Sender: TObject);
begin
Form1.SetChan2(TrackBar3.Position,2)
end;

procedure TForm2.Edit3Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit3.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Form1.SetChan2(A,2)
else
 Edit3.Text := IntToStr(TrackBar3.Position)
end;

procedure TForm2.TrackBar4Change(Sender: TObject);
begin
Form1.SetChan2(TrackBar4.Position,3)
end;

procedure TForm2.Edit4Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit4.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Form1.SetChan2(A,3)
else
 Edit4.Text := IntToStr(TrackBar4.Position)
end;

procedure TForm2.TrackBar5Change(Sender: TObject);
begin
Form1.SetChan2(TrackBar5.Position,4)
end;

procedure TForm2.Edit5Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit5.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Form1.SetChan2(A,4)
else
 Edit5.Text := IntToStr(TrackBar5.Position)
end;

procedure TForm2.TrackBar6Change(Sender: TObject);
begin
Form1.SetChan2(TrackBar6.Position,5)
end;

procedure TForm2.Edit6Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit6.Text,A,Cde);
if (Cde=0)and(A in [0..255]) then
 Form1.SetChan2(A,5)
else
 Edit6.Text := IntToStr(TrackBar6.Position)
end;

procedure TForm2.RadioButton1Click(Sender: TObject);
begin
Form1.Set_Chip2(AY_Chip)
end;

procedure TForm2.RadioButton2Click(Sender: TObject);
begin
Form1.Set_Chip2(YM_Chip)
end;

procedure TForm2.RadioButton3Click(Sender: TObject);
begin
Form1.Set_Chip_Frq(1773400);
FrqAYTemp := 1773400
end;

procedure TForm2.RadioButton4Click(Sender: TObject);
begin
Form1.Set_Chip_Frq(1750000);
FrqAYTemp := 1750000
end;

procedure TForm2.RadioButton5Click(Sender: TObject);
begin
Form1.Set_Chip_Frq(2000000);
FrqAYTemp := 2000000
end;

procedure TForm2.RadioButton6Click(Sender: TObject);
begin
Form1.Set_Chip_Frq(1000000);
FrqAYTemp := 1000000
end;

procedure TForm2.RadioButton7Click(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit11.Text,Fr,Err);
if Err = 0 then
 begin
  Form1.Set_Chip_Frq(Fr);
  FrqAYTemp := AY_Freq;
  Set_Frqs
 end;
if Visible then Edit11.SetFocus
end;

procedure TForm2.Set_MFPFrqs;
begin
if MFPTimerMode = 0 then
 RadioButton18.Checked := True
else 
 case FrqMFPTemp of
 2457600:RadioButton19.Checked := True;
 else begin
       Edit25.Text := IntToStr(FrqMFPTemp);
       RadioButton20.Checked := True
      end 
 end
end;

procedure TForm2.Set_Z80Frqs;
begin
 case FrqZ80 of
 3494400:RadioButton21.Checked := True;
 3500000:RadioButton22.Checked := True;
 else begin
       Edit32.Text := IntToStr(FrqZ80);
       RadioButton25.Checked := True
      end
 end
end;

procedure TForm2.Set_Frqs;
begin
 case FrqAYTemp of
 1773400:RadioButton3.Checked:=true;
 1750000:RadioButton4.Checked:=true;
 2000000:RadioButton5.Checked:=true;
 1000000:RadioButton6.Checked:=true;
 else begin
       Edit11.Text:=IntToStr(FrqAYTemp);
       RadioButton7.Checked:=true
      end;
 end
end;

procedure TForm2.Set_Pl_Frqs;
begin
 case FrqPlTemp of
 50000:RadioButton15.Checked := True;
 48828:RadioButton17.Checked := True;
 else begin
       Edit22.Text := FloatToStrF(FrqPlTemp/1000,ffFixed,7,3);
       RadioButton16.Checked := True
      end
 end;
end;

procedure TForm2.Edit11Exit(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit11.Text,Fr,Err);
if Err = 0 then
 begin
  Form1.Set_Chip_Frq(Fr);
  FrqAYTemp := AY_Freq
 end;
Set_Frqs
end;

procedure TForm2.FormHide(Sender: TObject);
begin
if ButtZoneRoot<>nil then
 if ButMixer.Is_On then
  ButMixer.Switch_Off
end;

procedure TForm2.RadioButton24Click(Sender: TObject);
begin
Set_Sample_Rate(96000)
end;

procedure TForm2.RadioButton23Click(Sender: TObject);
begin
Set_Sample_Rate(48000)
end;

procedure TForm2.RadioButton8Click(Sender: TObject);
begin
Set_Sample_Rate(44100)
end;

procedure TForm2.RadioButton9Click(Sender: TObject);
begin
Set_Sample_Rate(22050)
end;

procedure TForm2.RadioButton10Click(Sender: TObject);
begin
Set_Sample_Rate(11025)
end;

procedure TForm2.RadioButton11Click(Sender: TObject);
begin
Set_Sample_Bit(16)
end;

procedure TForm2.RadioButton12Click(Sender: TObject);
begin
Set_Sample_Bit(8)
end;

procedure TForm2.RadioButton13Click(Sender: TObject);
begin
Set_Stereo(2)
end;

procedure TForm2.RadioButton14Click(Sender: TObject);
begin
Set_Stereo(1)
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
begin
SetChanIndexes(ComboBox1.ItemIndex);
end;

procedure TForm2.SetChanIndexes(Temp:integer);
var
EmChip:ChTypes;
begin
EmChip:=ChType;
if Temp>6 then begin
          dec(Temp,6);
          ChType:=YM_Chip;
               end else
          ChType:=AY_Chip;
Form1.Set_Mode(Temp);
ChType := EmChip;
ComboBox1.ItemIndex := -1;
Form1.SetChan2(Index_AL,0);
Form1.SetChan2(Index_AR,1);
Form1.SetChan2(Index_BL,2);
Form1.SetChan2(Index_BR,3);
Form1.SetChan2(Index_CL,4);
Form1.SetChan2(Index_CR,5)
end;

procedure TForm2.Change_Show(TB:TTrackBar;E1,E2:TEdit;NewVal:byte;var Ind:byte);
begin
TB.Position:=NewVal;
E1.Text:=IntToStr(NewVal);
if IsPlaying then E2.Text:=E1.Text;
Ind := NewVal;
Calculate_Level_Tables
end;

procedure TForm2.RadioButton15Click(Sender: TObject);
begin
Form1.Set_Player_Frq2(50000)
end;

procedure TForm2.RadioButton16Click(Sender: TObject);
Var
 Fr:integer;
 FrReal:real;
begin
try
 FrReal:=StrToFloat(Edit22.Text);
 Fr:=round(FrReal*1000);
 Form1.Set_Player_Frq2(Fr);
 if Visible then Edit22.SetFocus;
except
 Set_Pl_Frqs;
 if Visible then Edit22.SetFocus;
end;
end;

procedure TForm2.Edit22Exit(Sender: TObject);
Var
 Fr:integer;
 FrReal:real;
begin
try
 FrReal:=StrToFloat(Edit22.Text);
 Fr:=round(FrReal*1000);
 Form1.Set_Player_Frq2(Fr);
except
 Set_Pl_Frqs;
end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
Form1.SetDefault;
CheckBox1.Checked := True;
CheckBox2.Checked := True;
CheckBox3.Checked := True;
CheckBox9.Checked := True;
CheckBox8.Checked := True;
SetMixerParams
end;

procedure TForm2.SetSRs;
begin
case SampleRate of
96000:
 RadioButton24.Checked := True;
48000:
 RadioButton23.Checked := True;
44100:
 RadioButton8.Checked := True;
22050:
 RadioButton9.Checked := True;
11025:
 RadioButton10.Checked := True
else
 begin
  RadioButton27.Checked := True;
  Edit31.Text := IntToStr(SampleRate)
 end
end
end;

procedure TForm2.SetMixerParams;
begin
FrqAYTemp := AY_Freq;
FrqPlTemp := Interrupt_Freq;
FrqMFPTemp := MFPTimerFrq;
TrackBar1.Position := Index_AL;
TrackBar2.Position := Index_AR;
TrackBar3.Position := Index_BL;
TrackBar4.Position := Index_BR;
TrackBar5.Position := Index_CL;
TrackBar6.Position := Index_CR;
TrackBar7.Position := BeeperMax;
TrackBar13.Position := PreAmp;
Edit1.Text := IntToStr(Index_AL);
Edit2.Text := IntToStr(Index_AR);
Edit3.Text := IntToStr(Index_BL);
Edit4.Text := IntToStr(Index_BR);
Edit5.Text := IntToStr(Index_CL);
Edit6.Text := IntToStr(Index_CR);
Edit20.Text := IntToStr(BeeperMax);
Edit30.Text := IntToStr(PreAmp);
Edit19.Text := IntToStr(MaxTStates);
if ChType = AY_Chip then
 RadioButton1.Checked := True
else
 RadioButton2.Checked := True;
Set_Z80Frqs;
Set_Frqs;
Set_Pl_Frqs;
Set_MFPFrqs;
SetSRs;
case SampleBit of
16:
 RadioButton11.Checked := True;
8:
 RadioButton12.Checked := True
end;
if NumberOfChannels = 2 then
 RadioButton13.Checked := True
else
 RadioButton14.Checked := True;
TrackBar8.Position := BufLen_ms;
TrackBar9.Position := NumberOfBuffers;
ComboBox2.ItemIndex := Integer(WODevice) + 1;
if Optimization_For_Quality then
 RadioButton26.Checked := True
else
 RadioButton28.Checked := True;
Label12.Visible := Optimization_For_Quality;
Label13.Visible := Optimization_For_Quality;
TrackBar14.Visible := Optimization_For_Quality;
TrackBar14.Position := FilterQuality;
FTact.Text := IntToStr(IntOffset);
TrackBar11.Position := BASSFFTType - BASS_DATA_FFT512;
TrackBar12.Position := round(BASSAmpMin * 10000);
CheckBox10.Checked := VolLinear;
CheckBox39.Checked := AutoSaveVolumePos;
if IsPlaying then
 Form1.ShowAllParams
end;

procedure TForm2.FormCreate(Sender: TObject);
var
 i:integer;
 WOC:WAVEOUTCAPS;
begin

Edit21.Text := FloatToStrF(50,ffFixed,7,3);
Edit24.Text := FloatToStrF(48.828,ffFixed,7,3);
for i := 0 to waveOutGetNumDevs - 1 do
 begin
  WOCheck(waveOutGetDevCaps(i,@WOC,SizeOf(WOC)));
  ComboBox2.Items.Add(WOC.szPname)
 end;
Edit33.Text := SysVolumeParams.Title;
CheckBox10.Checked := VolLinear
end;

procedure TForm2.RadioButton17Click(Sender: TObject);
begin
Form1.Set_Player_Frq2(48828)
end;

procedure TForm2.RadioButton20Click(Sender: TObject);
Var Err,Fr:integer;
begin
Val(Edit25.Text,Fr,Err);
if Err=0 then
 begin
  Form1.Set_MFP_Frq(1,Fr);
  FrqMFPTemp:=MFPTimerFrq;
  Set_MFPFrqs
 end;
if Visible then Edit25.SetFocus
end;

procedure TForm2.Edit25Exit(Sender: TObject);
Var Err,Fr:integer;
begin
Val(Edit25.Text,Fr,Err);
if Err=0 then
 begin
  Form1.Set_MFP_Frq(1,Fr);
  FrqMFPTemp:=MFPTimerFrq;
 end;
Set_MFPFrqs
end;

procedure TForm2.RadioButton18Click(Sender: TObject);
begin
Form1.Set_MFP_Frq(0,round(AY_Freq * 16 / 13));
FrqMFPTemp := MFPTimerFrq
end;

procedure TForm2.RadioButton19Click(Sender: TObject);
begin
Form1.Set_MFP_Frq(1,2457600);
FrqMFPTemp := 2457600
end;

procedure TForm2.RadioButton25Click(Sender: TObject);
Var Err,Fr:integer;
begin
Val(Edit32.Text,Fr,Err);
if Err = 0 then
 begin
  Form1.Set_Z80_Frq(Fr);
  Set_Z80Frqs
 end;
if Visible then Edit32.SetFocus
end;

procedure TForm2.RadioButton22Click(Sender: TObject);
begin
Form1.Set_Z80_Frq(3500000)
end;

procedure TForm2.RadioButton21Click(Sender: TObject);
begin
Form1.Set_Z80_Frq(3494400)
end;

procedure TForm2.Edit32Exit(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit32.Text,Fr,Err);
if Err = 0 then
 Form1.Set_Z80_Frq(Fr);
Set_Z80Frqs
end;

procedure TForm2.Edit19Exit(Sender: TObject);
begin
Form1.Set_N_TactS(Edit19.Text)
end;

procedure TForm2.Change_Show2(TB:TTrackBar;E1:TEdit;NewVal:byte;var Ind:integer);
begin
TB.Position := NewVal;
E1.Text := IntToStr(NewVal);
Ind := NewVal;
Calculate_Level_Tables
end;

procedure TForm2.Edit20Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit20.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Change_Show2(TrackBar7,Edit20,A,BeeperMax)
else
 Edit20.Text := IntToStr(TrackBar7.Position)
end;

procedure TForm2.TrackBar7Change(Sender: TObject);
begin
Change_Show2(TrackBar7,Edit20,TrackBar7.Position,BeeperMax)
end;

procedure TForm2.Edit31Exit(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit31.Text,Fr,Err);
if Err = 0 then
 begin
  Set_Sample_Rate(Fr);
  SetSRs
 end
end;


procedure TForm2.RadioButton27Click(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit31.Text,Fr,Err);
if Err = 0 then
 begin
  Set_Sample_Rate(Fr);
  SetSRs
 end;
if Visible then Edit31.SetFocus
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
Set_Sample_Rate(round(FrqAYTemp / 8));
SetSRs
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
Visible := False
end;

procedure TForm2.SpeedButton2Click(Sender: TObject);
begin
StopAndFreeAll
end;

procedure TForm2.TrackBar8Change(Sender: TObject);
begin
SetBuffers(TrackBar8.Position,NumberOfBuffers);
LbLen.Caption := IntToStr(BufLen_ms) + ' ms';
LBTot.Caption := IntToStr(BufLen_ms * NumberOfBuffers) + ' ms'
end;

procedure TForm2.TrackBar9Change(Sender: TObject);
begin
SetBuffers(BufLen_ms,TrackBar9.Position);
LbNum.Caption := IntToStr(NumberOfBuffers);
LBTot.Caption := IntToStr(BufLen_ms * NumberOfBuffers) + ' ms'
end;

procedure TForm2.ComboBox2Change(Sender: TObject);
begin
WODevice := ComboBox2.ItemIndex - 1
end;

procedure TForm2.TrackBar11Change(Sender: TObject);
begin
case TrackBar11.Position of
0:
 begin
  FFTTyp.Caption := 'low (fastest)';
  BASSFFTType := BASS_DATA_FFT512
 end;
1:
 begin
  FFTTyp.Caption := 'lower';
  BASSFFTType := BASS_DATA_FFT1024
 end;
2:
 begin
  FFTTyp.Caption := 'higher';
  BASSFFTType := BASS_DATA_FFT2048
 end;
3:
 begin
  FFTTyp.Caption := 'high (slowest)';
  BASSFFTType := BASS_DATA_FFT4096
 end
end
end;

procedure TForm2.TrackBar12Change(Sender: TObject);
begin
BASSAmpMin := TrackBar12.Position / 10000;
aminmax.Caption := FloatToStr(BASSAmpMin)
end;

procedure TForm2.TrackBar13Change(Sender: TObject);
begin
Change_Show2(TrackBar13,Edit30,TrackBar13.Position,PreAmp)
end;

procedure TForm2.Edit30Exit(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit30.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Change_Show2(TrackBar13,Edit30,A,PreAmp)
else
 Edit30.Text := IntToStr(TrackBar13.Position)
end;

procedure GetSystemMixers;
var
 n,i,j:integer;
begin
n := mixerGetNumDevs;
SetLength(Mixers,n);
for i := 0 to n - 1 do
 begin
 if mixerGetID(i,DWORD(Mixers[i].ID),MIXER_OBJECTF_MIXER) <> MMSYSERR_NOERROR then
  Mixers[i].ID := - 1
 else if mixerGetDevCaps(Mixers[i].ID,@Mixers[i].Caps,sizeof(TMIXERCAPS)) = MMSYSERR_NOERROR then
  begin
   SetLength(Mixers[i].Dests,Mixers[i].Caps.cDestinations);
   for j := 0 to Mixers[i].Caps.cDestinations - 1 do
    begin
     FillChar(Mixers[i].Dests[j],sizeof(TMIXERLINE),0);
     Mixers[i].Dests[j].Line.cbStruct := sizeof(TMIXERLINE);
     Mixers[i].Dests[j].Line.dwDestination := j;
     if mixerGetLineInfo(Mixers[i].ID,@Mixers[i].Dests[j].Line,MIXER_GETLINEINFOF_DESTINATION or
                                     MIXER_OBJECTF_MIXER) <> MMSYSERR_NOERROR then
      Mixers[i].Dests[j].Line.cChannels := 0
     else if Mixers[i].Dests[j].Line.cControls > 0 then
      begin
       SetLength(Mixers[i].Dests[j].Ctrls,Mixers[i].Dests[j].Line.cControls);
       FillChar(Mixers[i].Dests[j].LCtrls,sizeof(TMIXERLINECONTROLS),0);
       Mixers[i].Dests[j].LCtrls.cbStruct := sizeof(TMIXERLINECONTROLS);
       Mixers[i].Dests[j].LCtrls.dwLineID := Mixers[i].Dests[j].Line.dwLineID;
       Mixers[i].Dests[j].LCtrls.cControls := Mixers[i].Dests[j].Line.cControls;
       Mixers[i].Dests[j].LCtrls.cbmxctrl := sizeof(TMIXERCONTROL);
       Mixers[i].Dests[j].LCtrls.pamxctrl := @Mixers[i].Dests[j].Ctrls[0];
       if mixerGetLineControls(Mixers[i].ID,@Mixers[i].Dests[j].LCtrls,
                        MIXER_GETLINECONTROLSF_ALL or
                        MIXER_OBJECTF_MIXER) <> MMSYSERR_NOERROR then
        Mixers[i].Dests[j].Line.cControls := 0
      end
    end
  end
 else
  Mixers[i].ID := - 1
 end
end;

procedure ReopenMixer;
begin
if SysVolumeParams.Opened then
 mixerClose(SysVolumeParams.MixerHandle);
if SysVolumeParams.MixerID <> -1 then
 SysVolumeParams.Opened := mixerOpen(@SysVolumeParams.MixerHandle,
        SysVolumeParams.MixerID,Form1.Handle,0,CALLBACK_WINDOW) = MMSYSERR_NOERROR
end;

function SelectMixerControl;
var
 ind:integer;
begin
Result := False;
if (DWORD(i) < DWORD(Length(Mixers))) and
   (DWORD(j) < DWORD(Length(Mixers[i].Dests))) and
   (DWORD(k) < DWORD(Length(Mixers[i].Dests[j].Ctrls))) then
 begin
  Result := True;
  SysVolumeParams.MixerNumber := i;
  SysVolumeParams.DestNumber := j;
  SysVolumeParams.CtrlNumber := k;
  SysVolumeParams.Title := Mixers[i].Caps.szPname + '->' +
                            Mixers[i].Dests[j].Line.szName + '->' +
                             Mixers[i].Dests[j].Ctrls[k].szName;
  SysVolumeParams.MixerID := Mixers[i].ID;
  SysVolumeParams.ControlID := Mixers[i].Dests[j].Ctrls[k].dwControlID;
  SysVolumeParams.Chans := Mixers[i].Dests[j].Line.cChannels;
  SysVolumeParams.Max := Mixers[i].Dests[j].Ctrls[k].Bounds.dwMaximum;
  SysVolumeParams.Min := Mixers[i].Dests[j].Ctrls[k].Bounds.dwMinimum;
  SetLength(SysVolumeParams.Vals,SysVolumeParams.Chans);
  SetLength(SysVolumeParams.Balans,SysVolumeParams.Chans);
  for ind := 0 to SysVolumeParams.Chans - 1 do
   SysVolumeParams.Vals[ind].dwValue := SysVolumeParams.Max;
  SysVolumeParams.Pos := SysVolumeParams.Max;
  ReopenMixer;
  GetSysVolume;
  for ind := 0 to SysVolumeParams.Chans - 1 do
   SysVolumeParams.Balans[ind].dwValue := SysVolumeParams.Vals[ind].dwValue;
  Form2.Edit33.Text := SysVolumeParams.Title
 end
end;

procedure TForm2.Button3Click(Sender: TObject);
var
 i,j,k,n:integer;
 ar:array of integer;
 Mixers:TSysMixers;
begin
with TForm7.Create(Self) do
 try
  GetSystemMixers(Mixers);
  if Length(Mixers) = 0 then
   begin
    ShowMessage('No any system mixer found');
    exit
   end;
  Caption := 'Select mixer device:';
  SetLength(ar,Length(Mixers));
  for i := 0 to Length(Mixers) - 1 do
   if Mixers[i].ID <> - 1 then
    begin
     n := ListBox1.Items.Add(Mixers[i].Caps.szPname);
     ar[n] := i
    end;
  if ListBox1.Items.Count = 0 then
   begin
    ShowMessage('No valid system mixer');
    exit
   end;
  if ShowModal <> mrOk then exit;
  i := ar[ListBox1.ItemIndex];
  ListBox1.Clear;
  Caption := 'Select destination:';
  SetLength(ar,Mixers[i].Caps.cDestinations);
  for j := 0 to Mixers[i].Caps.cDestinations - 1 do
   if (Mixers[i].Dests[j].Line.cChannels > 0) and
      (Mixers[i].Dests[j].Line.dwComponentType in
           [MIXERLINE_COMPONENTTYPE_DST_DIGITAL,
            MIXERLINE_COMPONENTTYPE_DST_LINE,
            MIXERLINE_COMPONENTTYPE_DST_MONITOR,
            MIXERLINE_COMPONENTTYPE_DST_SPEAKERS,
            MIXERLINE_COMPONENTTYPE_DST_HEADPHONES,
            MIXERLINE_COMPONENTTYPE_DST_TELEPHONE]) then
    begin
     n := ListBox1.Items.Add(Mixers[i].Dests[j].Line.szName);
     ar[n] := i
    end;
  if ListBox1.Items.Count = 0 then
   begin
    ShowMessage('No valid destinations for selected mixer device');
    exit
   end;
  if ShowModal <> mrOk then exit;
  j := ar[ListBox1.ItemIndex];
  ListBox1.Clear;
  Caption := 'Select control:';
  SetLength(ar,Mixers[i].Dests[j].Line.cControls);
  for k := 0 to Mixers[i].Dests[j].Line.cControls - 1 do
   if Mixers[i].Dests[j].Ctrls[k].dwControlType =
      MIXERCONTROL_CONTROLTYPE_VOLUME then
    begin
     n := ListBox1.Items.Add(Mixers[i].Dests[j].Ctrls[k].szName);
     ar[n] := i
    end;
  if ListBox1.Items.Count = 0 then
   begin
    ShowMessage('No volume controls found for selected destination');
    exit
   end;
  if ShowModal <> mrOk then exit;
  SelectMixerControl(Mixers,i,j,ar[ListBox1.ItemIndex])
 finally
  Free
 end
end;

function DetectVolumeCtrl2;

 function VSearch(CompType:DWORD):boolean;
 var
  i,j,k:integer;
 begin
 Result := False;
 for i := 0 to Length(Mixers) - 1 do
 if Mixers[i].ID <> -1 then
  for j := 0 to Mixers[i].Caps.cDestinations - 1 do
   if (Mixers[i].Dests[j].Line.cChannels > 0) and
      (Mixers[i].Dests[j].Line.dwComponentType = CompType) then
    for k := 0 to Mixers[i].Dests[j].Line.cControls - 1 do
     if Mixers[i].Dests[j].Ctrls[k].dwControlType =
                            MIXERCONTROL_CONTROLTYPE_VOLUME then
      begin
       Result := True;
       SelectMixerControl(Mixers,i,j,k);
       exit
      end
 end;

begin
Result := VSearch(MIXERLINE_COMPONENTTYPE_DST_SPEAKERS);
if Result then exit;
Result := VSearch(MIXERLINE_COMPONENTTYPE_DST_HEADPHONES);
if Result then exit;
Result := VSearch(MIXERLINE_COMPONENTTYPE_DST_LINE);
if Result then exit;
Result := VSearch(MIXERLINE_COMPONENTTYPE_DST_DIGITAL);
if Result then exit;
Result := VSearch(MIXERLINE_COMPONENTTYPE_DST_MONITOR);
if Result then exit;
Result := VSearch(MIXERLINE_COMPONENTTYPE_DST_TELEPHONE)
end;

function DetectVolumeCtrl;
var
 Mixers:TSysMixers;
begin
GetSystemMixers(Mixers);
Result := DetectVolumeCtrl2(Mixers)
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
if not DetectVolumeCtrl then
 ShowMessage('System volume controls not detected')
end;

procedure TForm2.CheckBox10Click(Sender: TObject);
begin
VolLinear := CheckBox10.Checked;
GetSysVolume
end;

procedure TForm2.TrackBar14Change(Sender: TObject);
begin
Form1.SetFilter2(TrackBar14.Position)
end;

procedure TForm2.RadioButton28Click(Sender: TObject);
begin
Form1.SetOptimization2(False)
end;

procedure TForm2.RadioButton26Click(Sender: TObject);
begin
Form1.SetOptimization2(True)
end;

procedure TForm2.FTactExit(Sender: TObject);
var
 Temp1,Temp2:integer;
begin
Val(FTact.Text,Temp1,Temp2);
if (Temp2 = 0) and (Temp1 >= 0) and (Temp1 < integer(MaxTStates)) then
 IntOffset := Temp1;
FTact.Text := IntToStr(IntOffset)
end;

procedure TForm2.CheckBox39Click(Sender: TObject);
begin
AutoSaveVolumePos := CheckBox39.Checked
end;

end.
