{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit ItemEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, MainWin, AY, Players;

type
  TForm5 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    Label7: TLabel;
    Memo1: TMemo;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox4: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    GroupBox5: TGroupBox;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    Edit12: TEdit;
    GroupBox6: TGroupBox;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    GroupBox7: TGroupBox;
    RadioButton12: TRadioButton;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    RadioButton13: TRadioButton;
    ComboBox1: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    GroupBox8: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    RadioButton16: TRadioButton;
    RadioButton17: TRadioButton;
    RadioButton18: TRadioButton;
    GroupBox9: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Edit20: TEdit;
    ComboBox2: TComboBox;
    Edit21: TEdit;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    Edit25: TEdit;
    Label18: TLabel;
    Edit26: TEdit;
    RadioButton19: TRadioButton;
    Edit13: TEdit;
    procedure SetPlayItems(Chip_Type:ChTypes;Number_Of_Channels,SoundChip_Frq,
                     Player_Frq,Channel_Mode:integer;AL,AR,BL,BR,CL,CR:byte);
    procedure GetPlayItems(var Chip_Type:ChTypes;var Number_Of_Channels,SoundChip_Frq,
                     Player_Frq,Channel_Mode:integer;var AL,AR,BL,BR,CL,CR:byte);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure Edit11Change(Sender: TObject);
    procedure Edit13Change(Sender: TObject);
    procedure CustomChAllocSet(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses PlayList;

{$R *.DFM}
procedure TForm5.SetPlayItems(Chip_Type:ChTypes;Number_Of_Channels,SoundChip_Frq,
                     Player_Frq,Channel_Mode:integer;AL,AR,BL,BR,CL,CR:byte);
begin
 case Chip_Type of
 AY_Chip:RadioButton1.Checked:=True;
 YM_Chip:RadioButton2.Checked:=True;
 No_Chip:RadioButton14.Checked:=True;
 end;
 case Number_Of_Channels of
 2:RadioButton10.Checked:=True;
 1:RadioButton11.Checked:=True;
 0:RadioButton15.Checked:=True;
 end;
 Edit11.Text:='';
 case SoundChip_Frq of
 1773400:RadioButton3.Checked:=True;
 1750000:RadioButton4.Checked:=True;
 2000000:RadioButton5.Checked:=True;
 1000000:RadioButton6.Checked:=True;
 -2,-1  :RadioButton16.Checked:=True;
 else begin
      RadioButton7.Checked:=True;
      Edit11.Text:=IntToStr(SoundChip_Frq);
      end;
 end;
 Edit13.Text:='';
 case Player_Frq of
 50000:RadioButton8.Checked:=True;
 48828:RadioButton19.Checked:=True;
 -1,-2:RadioButton17.Checked:=True;
 else begin
      RadioButton9.Checked:=True;
      Edit13.Text:=IntToStr(Player_Frq);
      end;
 end;
 Edit14.Text:=''; Edit15.Text:='';
 Edit16.Text:=''; Edit17.Text:='';
 Edit18.Text:=''; Edit19.Text:='';
 ComboBox1.ItemIndex:=-1;
 case Channel_Mode of
 0..6: Begin
       ComboBox1.ItemIndex:=Channel_Mode;
       RadioButton13.Checked:=True;
       end;
 -2:   Begin
       RadioButton12.Checked:=True;
       Edit14.Text:=IntToStr(AL);
       Edit15.Text:=IntToStr(AR);
       Edit17.Text:=IntToStr(BL);
       Edit16.Text:=IntToStr(BR);
       Edit19.Text:=IntToStr(CL);
       Edit18.Text:=IntToStr(CR);
       end;
 -1:   Begin
       RadioButton18.Checked:=True;
       end;
 end;
end;

procedure TForm5.Button1Click(Sender: TObject);
begin
with Form3 do
SetPlayItems(PLDef_Chip_Type,PLDef_Number_Of_Channels,PLDef_SoundChip_Frq,
                     PLDef_Player_Frq,PLDef_Channel_Mode,
                     PLDef_AL,PLDef_AR,PLDef_BL,PLDef_BR,PLDef_CL,PLDef_CR);
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
with Form3 do begin
GetPlayItems(PLDef_Chip_Type,PLDef_Number_Of_Channels,PLDef_SoundChip_Frq,
                     PLDef_Player_Frq,PLDef_Channel_Mode,
                     PLDef_AL,PLDef_AR,PLDef_BL,PLDef_BR,PLDef_CL,PLDef_CR);
              end;
Button1Click(Sender);
end;
procedure TForm5.GetPlayItems(var Chip_Type:ChTypes;var Number_Of_Channels,SoundChip_Frq,
                     Player_Frq,Channel_Mode:integer;var AL,AR,BL,BR,CL,CR:byte);
var Temp:integer;
begin
if RadioButton1.Checked then Chip_Type:=AY_Chip else
if RadioButton2.Checked then Chip_Type:=YM_Chip else
if RadioButton14.Checked then Chip_Type:=No_Chip;

if RadioButton10.Checked then Number_Of_Channels:=2 else
if RadioButton11.Checked then Number_Of_Channels:=1 else
if RadioButton15.Checked then Number_Of_Channels:=0;

if RadioButton3.Checked then SoundChip_Frq:=1773400 else
if RadioButton4.Checked then SoundChip_Frq:=1750000 else
if RadioButton5.Checked then SoundChip_Frq:=2000000 else
if RadioButton6.Checked then SoundChip_Frq:=1000000 else
if RadioButton16.Checked then SoundChip_Frq:=-1 else
if RadioButton7.Checked then begin
         Val(Edit11.Text,SoundChip_Frq,Temp);
         if Temp<>0 then SoundChip_Frq:=-1;
                             end;

if RadioButton8.Checked then Player_Frq:=50000 else
if RadioButton19.Checked then Player_Frq:=48828 else
if RadioButton17.Checked then Player_Frq:=-1 else
if RadioButton9.Checked then begin
         Val(Edit13.Text,Player_Frq,Temp);
         if Temp<>0 then Player_Frq:=-1;
                             end;

if RadioButton13.Checked then Channel_Mode:=ComboBox1.ItemIndex else
if RadioButton18.Checked then Channel_Mode:=-1 else
if RadioButton12.Checked then begin
         Channel_Mode:=-1;
         Val(Edit14.Text,AL,Temp);
         if Temp=0 then begin
         Val(Edit15.Text,AR,Temp);
         if Temp=0 then begin
         Val(Edit17.Text,BL,Temp);
         if Temp=0 then begin
         Val(Edit16.Text,BR,Temp);
         if Temp=0 then begin
         Val(Edit19.Text,CL,Temp);
         if Temp=0 then begin
         Val(Edit18.Text,CR,Temp);
         if Temp=0 then Channel_Mode:=-2;
                        end;
                        end;
                        end;
                        end;
                        end;
                              end;
end;

procedure TForm5.FormCreate(Sender: TObject);
var
 i:Available_Types;
begin
for i := MinType to MaxType do
 ComboBox2.Items.Add(STypes[i])
end;

procedure TForm5.ComboBox1Select(Sender: TObject);
begin
RadioButton13.Checked := True
end;

procedure TForm5.Edit11Change(Sender: TObject);
begin
RadioButton7.Checked := True
end;

procedure TForm5.Edit13Change(Sender: TObject);
begin
RadioButton9.Checked := True
end;

procedure TForm5.CustomChAllocSet(Sender: TObject);
begin
RadioButton12.Checked := True
end;

end.
