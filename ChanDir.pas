{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit ChanDir;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
  TChngDir = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DirectoryListBox1: TDirectoryListBox;
    DirName: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure DirectoryListBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChngDir: TChngDir;

implementation

{$R *.DFM}

procedure TChngDir.DirectoryListBox1Change(Sender: TObject);
begin
DirName.Text:=DirectoryListBox1.Directory;
end;

end.
