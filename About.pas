{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, LH5;

type
  TAboutBox = class(TForm)
    procedure WndProc(var Message: TMessage); override;
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Push(Rg:HRGN;DoPush:boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    AbFormRgn,AbOkRgn,AbHlpRgn:HRGN;
    AbDBuffer:TBitmap;
    OKClicked,HlpClicked,WinClicked:boolean;
    But:array[0..1] of record
      Pushed:boolean;
      PushedBmp,UnPushedBmp:TBitmap;
      x1,y1,x2,y2:integer;
     end;
    OldX,OldY:integer;
  end;

var
  AboutBox: TAboutBox;

implementation

uses MainWin, UniReader;

{$R *.DFM}

procedure TAboutBox.FormCreate(Sender: TObject);

 procedure AddRoundRectRgn(a,b,c,d,e,f,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRoundRectRgn(a,b,c,d,e,f);
  CombineRgn(AbFormRgn,AbFormRgn,r,op);
  DeleteObject(r)
 end;

 procedure AddRectRgn(a,b,c,d,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRectRgn(a,b,c,d);
  CombineRgn(AbFormRgn,AbFormRgn,r,op);
  DeleteObject(r)
 end;

 procedure AddRoundRectRgnH(a,b,c,d,e,f,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRoundRectRgn(a,b,c,d,e,f);
  CombineRgn(AbHlpRgn,AbHlpRgn,r,op);
  DeleteObject(r)
 end;

 procedure AddRectRgnH(a,b,c,d,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRectRgn(a,b,c,d);
  CombineRgn(AbHlpRgn,AbHlpRgn,r,op);
  DeleteObject(r)
 end;

var
 Bitmap:TBitmap;
 URHandle,i:integer;
 Stream:TStream;
 pic:array[0..469055]of byte;
begin
AbFormRgn := CreateRectRgn(18,12,315,347);
AddRoundRectRgn(40-1,285+5,183+3,344+2,183+4-40,344-285-3,RGN_DIFF);
AddRectRgn(293,340,320,347,RGN_DIFF);
AddRoundRectRgn(287,314,320,347,33,33,RGN_OR);
AddRoundRectRgn(216,329-2,300,355-2,300-216,355-329,RGN_DIFF);
AddRectRgn(180,303,233,347,RGN_DIFF);
AddRectRgn(18,315,180,347,RGN_DIFF);
AddRoundRectRgn(-3,206,38,281,38+3,281-206,RGN_DIFF);
AddRoundRectRgn(-1,167,30,191,30+1,191-167,RGN_DIFF);
AddRoundRectRgn(-3,128,28,152,30+1,191-167,RGN_DIFF);
AddRoundRectRgn(-4-11,54,50-11,114,50+4,114-54,RGN_DIFF);
AddRectRgn(18,12,23,14,RGN_DIFF);
AddRoundRectRgn(1,12,64,58,64-1,58-12,RGN_OR);
AddRoundRectRgn(12,112,30,130,30-12,132-114,RGN_OR);
AddRoundRectRgn(12,151,30,169,30-12,132-114,RGN_OR);
AddRoundRectRgn(12,189,30,207,30-12,132-114,RGN_OR);
AddRectRgn(18,280,45,315,RGN_DIFF);
AddRoundRectRgn(16,274,52,310,52-16,311-275,RGN_OR);
AddRoundRectRgn(293+4,243,342+4,320,346-293,320-242,RGN_DIFF);
AddRoundRectRgn(306,205,336,229,336-306,229-205,RGN_DIFF);
AddRoundRectRgn(308,166,338,190,336-306,229-205,RGN_DIFF);
AddRoundRectRgn(306,150,324,168,30-12,168-150,RGN_OR);
AddRoundRectRgn(306,189,324,206,30-12,206-189,RGN_OR);
AddRoundRectRgn(306,228,324,245,30-12,245-228,RGN_OR);
AddRoundRectRgn(295,29,344,150,344-295,150-29,RGN_DIFF);
AddRectRgn(294,81,300,97,RGN_DIFF);

AbHlpRgn := CreateRoundRectRgn(243,0,343,70,344-244,70-0);
AddRectRgnH(243,43,343,71,RGN_DIFF);
AddRoundRectRgnH(243,3,343,66,343-243,66-3,RGN_OR);
AddRoundRectRgnH(280,27,297,45,17,17,RGN_DIFF);
AddRoundRectRgnH(277,38,292,54,15,16,RGN_DIFF);
AddRoundRectRgnH(270,50,286,66,15,16,RGN_DIFF);
AddRoundRectRgnH(280,54,308,82,28,28,RGN_OR);
AddRectRgnH(306,62,314,70,RGN_OR);
AddRoundRectRgnH(309,64,319,73,314-306,74-65,RGN_DIFF);
AddRectRgnH(262,150,291,307,RGN_OR);
AddRoundRectRgnH(269,95,316,143,317-270,143-95,RGN_OR);
AbOkRgn := CreateRoundRectRgn(176,250,259,332,260-177,334-252);
CombineRgn(AbFormRgn,AbFormRgn,AbOkRgn,RGN_OR);
CombineRgn(AbFormRgn,AbFormRgn,AbHlpRgn,RGN_OR);

Bitmap:=TBitmap.Create;
i := FindResource(HInstance,pointer($102),pointer($100));
UniReadInit(URHandle,URMemory,'',pointer(LoadResource(HInstance,i)));
Compressed_Size := 97925; Original_Size := 469056;
UniAddDepacker(URHandle,UDLZH);
try
 UniRead(URHandle,@pic,Original_Size)
finally
 UniReadClose(URHandle)
end;
Stream := TMemoryStream.Create;
Stream.Write(pic,469056);
Stream.Position := 0;
Bitmap.LoadFromStream(Stream);
Stream.Free;
AbDBuffer := TBitmap.Create;
AbDBuffer.Width := 343;
AbDBuffer.Height := 348;
AbDBuffer.Canvas.CopyRect(Rect(0,0,343,347),Bitmap.Canvas,Rect(1,2,344,349));
But[0].UnPushedBmp := TBitmap.Create;
But[0].UnPushedBmp.Width:=83;
But[0].UnPushedBmp.Height:=82;
But[0].UnPushedBmp.Canvas.
        CopyRect(Rect(0,0,83,82),Bitmap.Canvas,Rect(177,252,260,334));
But[0].PushedBmp := TBitmap.Create;
But[0].PushedBmp.Width:=83;
But[0].PushedBmp.Height:=82;
But[0].PushedBmp.Canvas.
        CopyRect(Rect(0,0,83,82),Bitmap.Canvas,Rect(323,252,406,334));
But[0].x1 := 176;
But[0].y1 := 250;
But[0].x2 := 259;
But[0].y2 := 332;
But[1].UnPushedBmp := TBitmap.Create;
But[1].UnPushedBmp.Width:=100;
But[1].UnPushedBmp.Height:=142;
But[1].UnPushedBmp.Canvas.
        CopyRect(Rect(0,0,100,142),Bitmap.Canvas,Rect(244,2,344,144));
But[1].PushedBmp := TBitmap.Create;
But[1].PushedBmp.Width:=100;
But[1].PushedBmp.Height:=142;
But[1].PushedBmp.Canvas.
        CopyRect(Rect(0,0,100,142),Bitmap.Canvas,Rect(345,2,445,144));
But[1].x1 := 243;
But[1].y1 := 0;
But[1].x2 := 343;
But[1].y2 := 142;
Bitmap.Free;
SetWindowRgn(Handle, AbFormRgn, True);
But[0].Pushed:=False;
But[1].Pushed:=False;
OKClicked := False;
HlpClicked := False;
WinClicked := False
end;

procedure TAboutBox.FormDestroy(Sender: TObject);
begin
DeleteObject(AbFormRgn);
DeleteObject(AbOkRgn);
DeleteObject(AbHlpRgn);
But[0].PushedBmp.Free;
But[0].UnPushedBmp.Free;
But[1].PushedBmp.Free;
But[1].UnPushedBmp.Free;
AbDBuffer.Free
end;

procedure TAboutBox.FormPaint(Sender: TObject);
begin
BitBlt(Canvas.Handle,0,0,AbDBuffer.Width,AbDBuffer.Height,
       AbDBuffer.Canvas.Handle,0,0,SRCCOPY)
end;

procedure TAboutBox.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 r:TRect;
begin
if Shift <> [ssLeft] then exit;
if PtInRegion(AbOkRgn,X,Y) then
 begin
  Push(AbOkRgn,True);
  OKClicked := True;
  HlpClicked := False;
  WinClicked := False
 end
else if PtInRegion(AbHlpRgn,X,Y) then
 begin
  Push(AbHlpRgn,True);
  OKClicked := False;
  HlpClicked := True;
  WinClicked := False
 end
else
 begin
  SystemParametersInfo(SPI_GETWORKAREA,0,@r,0);
  ClipCursor(@r);
  OldX := X;
  OldY := Y;
  OKClicked := False;
  HlpClicked := False;
  WinClicked := True
 end
end;

procedure TAboutBox.Push(Rg:HRGN;DoPush:boolean);
var
 Bt:integer;
begin
if Rg = AbOkrgn then Bt := 0 else Bt := 1;
with But[Bt] do
 begin
  if DoPush = Pushed then exit;
  if DoPush then
   AbDBuffer.Canvas.CopyRect(Rect(x1,y1,x2,y2),
                        PushedBmp.Canvas,Rect(0,0,x2-x1,y2-y1))
  else
   AbDBuffer.Canvas.CopyRect(Rect(x1,y1,x2,y2),
                        UnPushedBmp.Canvas,Rect(0,0,x2-x1,y2-y1));
  Pushed := DoPush;
  Canvas.CopyRect(Rect(x1,y1,x2,y2),
                        AbDBuffer.Canvas,Rect(x1,y1,x2,y2))
 end
end;

procedure TAboutBox.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if Shift <> [ssLeft] then exit;
if OKClicked then
 begin
  if PtInRegion(AbOkRgn,X,Y) then Push(AbOkRgn,True)
  else Push(AbOkRgn,False)
 end
else if HlpClicked then
 begin
  if PtInRegion(AbHlpRgn,X,Y) then Push(AbHlpRgn,True)
  else Push(AbHlpRgn,False)
 end
else if WinClicked then
 begin
  Left := Left + X - OldX;
  Top := Top + Y - OldY
 end;
end;

procedure TAboutBox.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if OKClicked and PtInRegion(AbOkRgn,X,Y) then Close
else if HlpClicked and PtInRegion(AbHlpRgn,X,Y) then
 begin
  Push(AbHlpRgn,False);
  Form1.CallHelp;
 end;
ClipCursor(nil);
OKClicked := False;
HlpClicked := False;
WinClicked := False
end;

procedure TAboutBox.WndProc;
begin
case Message.Msg of
WM_KILLFOCUS:
 begin
  ClipCursor(nil);
  Push(AbHlpRgn,False);
  Push(AbOkRgn,False);
  OKClicked := False;
  HlpClicked := False;
  WinClicked := False
 end;
end; 
inherited
end; 

procedure TAboutBox.FormKeyPress(Sender: TObject; var Key: Char);
begin
if Key = #27 then Close
end;

end.
