{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit SelVolCtrl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  MMSystem, StdCtrls;

type
  TForm7 = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TForm7.FormShow(Sender: TObject);
begin
ListBox1.ItemIndex := 0
end;

procedure TForm7.ListBox1Click(Sender: TObject);
begin
Button1.Enabled := ListBox1.ItemIndex <> -1
end;

end.
 