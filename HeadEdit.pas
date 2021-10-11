{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit HeadEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  THeaderEditor = class(TForm)
    FrqBox: TGroupBox;
    SpeccyF: TRadioButton;
    AtariF: TRadioButton;
    AmstradF: TRadioButton;
    UserF: TRadioButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    Edit5: TEdit;
    Label5: TLabel;
    RadioButton2: TRadioButton;
    Edit6: TEdit;
    Label6: TLabel;
    GroupBox2: TGroupBox;
    Edit7: TEdit;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Edit8: TEdit;
    Label8: TLabel;
    Edit9: TEdit;
    GroupBox4: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    GroupBox5: TGroupBox;
    Label9: TLabel;
    Edit10: TEdit;
    Button1: TButton;
    Button2: TButton;
    GroupBox6: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Edit11: TEdit;
    Edit12: TEdit;
    Label12: TLabel;
    Edit13: TEdit;
    ComboBox1: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure SetParams;
    Procedure GetParams;
  private
    { Private declarations }
  public
    { Public declarations }
  FrqAYChk:array[0..3]of boolean;
  FrqIntChk:array[0..1]of boolean;
  ChipChk:array[0..1]of boolean;
  LoopPos:dword;
  NumOfPos:dword;
  SongName,SongAuthor,SongProgram,SongTracker:string;
  FrAy:dword;
  FrInt:word;
  ChanMode:byte;
  Rus:Boolean;
  Year:word;
  end;

var
  HeaderEditor: THeaderEditor;

implementation

{$R *.DFM}
procedure THeaderEditor.SetParams;
var
 i:integer;
 s:string;
begin
if not Rus then
 begin
  FrqBox.Caption := 'Sound chip frequency';
  Label1.Caption := 'Hz';
  Label2.Caption := 'Hz';
  Label3.Caption := 'Hz';
  Label4.Caption := 'Hz';
  Label5.Caption := 'Hz';
  Label6.Caption := 'Hz';
  GroupBox1.Caption := 'Interrupt frequency';
  RadioButton2.Caption := 'Other';
  UserF.Caption := 'Other';
  GroupBox4.Caption := 'Chip type';
  GroupBox2.Caption := 'Loop VBL';
  Label9.Caption := 'Total VBLs';
  GroupBox5.Caption := 'Other information';
  GroupBox3.Caption := 'Information about song';
  Label7.Caption := 'Title';
  Label8.Caption := 'Author';
  Label10.Caption := 'Program';
  Label11.Caption := 'Tracker';
  Label12.Caption := 'Year';
  GroupBox6.Caption := 'Channels allocation';
  Button2.Caption := 'Apply';
  Button1.Caption := 'Restore';
  Caption := 'Information in the file header'
 end;
for i := 0 to 3 do FrqAyChk[i] := False;
case FrAy of
1773400:FrqAyChk[0] := True;
2000000:FrqAyChk[1] := True;
1000000:FrqAyChk[2] := True;
else FrqAyChk[3] := True
end;
for i := 0 to 1 do FrqIntChk[i] := False;
if FrInt = 50 then FrqIntChk[0] := True else FrqIntChk[1] := True;
SpeccyF.Checked := FrqAYChk[0];
AtariF.Checked := FrqAYChk[1];
AmstradF.Checked := FrqAYChk[2];
UserF.Checked := FrqAYChk[3];
if FrqAYChk[3] then Str(FrAy,s) else s := '';
Edit1.Text := s;
RadioButton1.Checked := FrqIntChk[0];
RadioButton2.Checked := FrqIntChk[1];
if FrqIntChk[1] then Str(FrInt,s) else s := '';
Edit6.Text := s;
RadioButton3.Checked := ChipChk[0];
RadioButton4.Checked := ChipChk[1];
Str(LoopPos,s);
Edit7.Text := s;
Str(NumOfPos,s);
Edit10.Text := s;
Edit8.Text := SongName;
Edit9.Text := SongAuthor;
Edit11.Text := SongProgram;
Edit12.Text := SongTracker;
if Year <> 0 then Str(Year,s) else s := '';
Edit13.Text := s;
ComboBox1.ItemIndex := ChanMode
end;

procedure THeaderEditor.Button1Click(Sender: TObject);
begin
SetParams
end;

procedure THeaderEditor.GetParams;
var
 i,j:integer;
begin
if SpeccyF.Checked then fray := 1773400 else
if AtariF.Checked then fray := 2000000 else
if AmstradF.Checked then fray := 1000000 else
if UserF.Checked then
 begin
  Val(Edit1.Text,j,i);
  if i = 0 then
   begin
    if j < 1000000 then j := 1000000 else
    if j > 3000000 then j := 3000000;
    fray := j
   end
 end;
if RadioButton1.Checked then FrInt := 50 else
 begin
  Val(Edit6.Text,j,i);
  if i = 0 then
   begin
    if j < 1 then j := 1 else
    if j > 255 then j := 255;
    frInt := j
   end
 end;
ChipChk[0] := RadioButton3.Checked;
ChipChk[1] := RadioButton4.Checked;
Val(Edit7.Text,j,i);
if i = 0 then
 begin
  if j < 0 then j := 0 else
  if longword(j) >= NumOfPos then j := NumOfPos - 1;
  LoopPos := j
 end;
Val(Edit13.Text,j,i);
if (i = 0) and (j >= 0) and (j < 65536) then
 Year := j
else
 Year := 0;
SongName := Trim(Edit8.Text);
SongAuthor := Trim(Edit9.Text);
SongProgram := Trim(Edit11.Text);
SongTracker := Trim(Edit12.Text);
ChanMode := ComboBox1.ItemIndex
end;

end.
