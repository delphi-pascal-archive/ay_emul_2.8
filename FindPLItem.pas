unit FindPLItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm9 = class(TForm)
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    RadioGroup1: TRadioGroup;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

uses PlayList;

{$R *.dfm}

function FindItem2(Item,FMode:integer;const FString:string):boolean;
begin
Result := True;
with PlayListItems[Item]^ do
 begin
  if (FMode in [0,1]) and (Pos(FString,AnsiLowerCase(Author)) > 0) then exit;
  if (FMode in [0,2]) and (Pos(FString,AnsiLowerCase(Title)) > 0) then exit;
  Result := (FMode in [0,3]) and (Pos(FString,AnsiLowerCase(ExtractFileName(FileName))) > 0);
  if Result or (FMode <> 0) then exit;
  Result := True;
  if Pos(FString,AnsiLowerCase(Programm)) > 0 then exit;
  if Pos(FString,AnsiLowerCase(Tracker)) > 0 then exit;
  if Pos(FString,AnsiLowerCase(Computer)) > 0 then exit;
  if Pos(FString,AnsiLowerCase(Date)) > 0 then exit;
  if Pos(FString,AnsiLowerCase(Comment)) > 0 then exit
 end;
Result := False
end;

function FindItem(FFrom,FTo,FMode:integer;const FString:string):integer;
var
 i:integer;
begin
Result := -1;
for i := FFrom to FTo do
 if FindItem2(i,FMode,FString) then
  begin
   Result := i;
   exit
  end
end;

procedure TForm9.Button1Click(Sender: TObject);
var
 Found:integer;
 FStr:string;
begin
FStr := AnsiLowerCase(Edit1.Text);
Found := FindItem(LastSelected + 1,Length(PlayListItems) - 1,RadioGroup1.ItemIndex,FStr);
if (Found < 0) and (LastSelected >= 0) then
 Found := FindItem(0,LastSelected,RadioGroup1.ItemIndex,FStr);
if Found < 0 then
 Application.MessageBox('Search string not found','Find playslit item')
else
 begin
  ClearSelection;
  LastSelected := Found;
  PlayListItems[Found].Selected := True;
  MakeVisible(Found,True)
 end;
end;

procedure TForm9.Button2Click(Sender: TObject);
var
 i,m,Cnt:integer;
 FStr:string;
begin
ClearSelection;
FStr := AnsiLowerCase(Edit1.Text);
Cnt := 0; m := RadioGroup1.ItemIndex;
for i := 0 to Length(PlayListItems) - 1 do
 if FindItem2(i,m,FStr) then
  begin
   inc(Cnt);
   PlayListItems[i].Selected := True;
  end;
RedrawPlaylist(ShownFrom,0,True);
if Cnt = 0 then
 Application.MessageBox('Search string not found','Find playslit item')
end;

end.
