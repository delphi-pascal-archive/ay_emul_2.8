{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

//Delphi 5 TScrollBar component must die! (see VCL sources ;)
//TScrollBar in Delphi 6 has one more bug ;) Borland rules :)
//And in Delphi 7... So, now using WinAPI.

unit PlayList;

interface

uses
  Windows, Messages, Types, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MainWin, Menus, ShellApi, FileCtrl, AY,
  UniReader, Buttons, Players, ImgList;

const
  Version_String:string='ZX Spectrum Sound Chip Emulator Play List File v1.';
  T_ExtraTypes = ';*.trd;*.scl;*.sna;*.$*;*.!*;*.fdi;*.tap';
  T_AllSup = '|*.out;*.zxay;*.zx50;*.stc;*.asc;*.vtx;' +
             '*.ym;*.psg;*.zxs;*.stp;*.psc;*.ftc;*.fls;*.pt1;*.pt2;*.pt3;' +
             '*.sqt;*.gtr;*.fxm;*.psm;*.m3u;*.ayl;*.ay;*.aym;*.mp3;*.mp2;' +
             '*.mp1;*.ogg;*.wav;*.wma;*.mo3;*.it;*.xm;*.s3m;*.mtm;*.mod;' +
             '*.umx;*.cda';
  T_SupTypes =   'Все допустимые типы';
  T_WinampPL =   'Списки проигрывания Winamp (M3U)|*.m3u';
  T_AYEmulPL =   'Списки проигрывания AY_Emul (AYL)|*.ayl';
  T_OUT      =   'Файлы вывода (OUT)|*.out';
  T_ZXAY     =   'Файлы сопроцессора (ZXAY)|*.zxay';
  T_STC      =   'Файлы Sound Tracker (STC)|*.stc';
  T_ASM      =   'Файлы редактора ASM (ASC)|*.asc';
  T_VTX      =   'Файлы Vortex (VTX)|*.vtx';
  T_YM       =   'Файлы ST-Sound (YM)|*.ym';
  T_PSG      =   'Файлы эмуляторов (PSG)|*.psg';
  T_STP      =   'Файлы Sound Tracker Pro (STP)|*.stp';
  T_PSC      =   'Файлы Pro Sound Creator (PSC)|*.psc';
  T_FTC      =   'Файлы Fast Tracker (FTC)|*.ftc';
  T_FLS      =   'Файлы Flash Tracker (FLS)|*.fls';
  T_PT1      =   'Файлы Pro Tracker 1 (PT1)|*.pt1';
  T_PT2      =   'Файлы Pro Tracker 2 (PT2)|*.pt2';
  T_PT3      =   'Файлы Pro Tracker 3 (PT3)|*.pt3';
  T_SQT      =   'Файлы SQ-Tracker (SQT)|*.sqt';
  T_GTR      =   'Файлы Global Tracker (GTR)|*.gtr';
  T_FXM      =   'Файлы AY Language Fuxoft''a (FXM)|*.fxm';
  T_PSM      =   'Файлы Pro Sound Maker (PSM)|*.psm';
  T_AY       =   'Файлы AYPlay и DeliAY (AY)|*.ay';
  T_AYM      =   'Файлы RDOSPLAY (AYM)|*.aym';
  T_MP3      =   'Файлы MPEG 1 Layer 3 (MP3)|*.mp3';
  T_MP2      =   'Файлы MPEG 1 Layer 2 (MP2)|*.mp2';
  T_MP1      =   'Файлы MPEG 1 Layer 1 (MP1)|*.mp1';
  T_OGG      =   'Файлы Vorbis (OGG)|*.ogg';
  T_WAV      =   'Файлы звукозаписи (WAV)|*.wav';
  T_WMA      =   'Файлы звукозаписи Windows Media (WMA)|*.wma';
  T_MO3      =   'Файлы MOD2MO3 (MO3)|*.mo3';
  T_IT       =   'Файлы PC Impulse Tracker (IT)|*.it';
  T_XM       =   'Файлы PC Fast Tracker 2 (XM)|*.xm';
  T_S3M      =   'Файлы PC Scream Tracker 3 (S3M)|*.s3m';
  T_MTM      =   'Файлы PC MultiTracker (MTM)|*.mtm';
  T_MOD      =   'Файлы Generic module format (MOD)|*.mod';
  T_UMX      =   'Пакет музыки Unreal Tournament (UMX)|*.umx';
  T_CDA      =   'Дорожки AudioCD (CDA)|*.cda';
  T_ALL      =   'Все файлы|*.*';

  E_SupTypes =   'All supported types';
  E_WinampPL =   'Winamp Playlists (M3U)|*.m3u';
  E_AYEmulPL =   'AY_Emul Playlists (AYL)|*.ayl';
  E_OUT      =   'OUT files (OUT)|*.out';
  E_ZXAY     =   'Sound chip files (ZXAY)|*.zxay';
  E_STC      =   'Sound Tracker files (STC)|*.stc';
  E_ASM      =   'ASM music editor files (ASC)|*.asc';
  E_VTX      =   'Vortex files (VTX)|*.vtx';
  E_YM       =   'ST-Sound files (YM)|*.ym';
  E_PSG      =   'Emulators files (PSG)|*.psg';
  E_STP      =   'Sound Tracker Pro files (STP)|*.stp';
  E_PSC      =   'Pro Sound Creator files (PSC)|*.psc';
  E_FTC      =   'Fast Tracker files (FTC)|*.ftc';
  E_FLS      =   'Flash Tracker files (FLS)|*.fls';
  E_PT1      =   'Pro Tracker 1 files (PT1)|*.pt1';
  E_PT2      =   'Pro Tracker 2 files (PT2)|*.pt2';
  E_PT3      =   'Pro Tracker 3 files (PT3)|*.pt3';
  E_SQT      =   'SQ-Tracker files (SQT)|*.sqt';
  E_GTR      =   'Global Tracker files (GTR)|*.gtr';
  E_FXM      =   'Fuxoft AY Language (FXM)|*.fxm';
  E_PSM      =   'Pro Sound Maker files (PSM)|*.psm';
  E_AY       =   'AYPlay and DeliAY files (AY)|*.ay';
  E_AYM      =   'RDOSPLAY files (AYM)|*.aym';
  E_MP3      =   'MPEG 1 Layer 3 files (MP3)|*.mp3';
  E_MP2      =   'MPEG 1 Layer 2 files (MP2)|*.mp2';
  E_MP1      =   'MPEG 1 Layer 1 files (MP1)|*.mp1';
  E_OGG      =   'Vorbis files (OGG)|*.ogg';
  E_WAV      =   'Wave files (WAV)|*.wav';
  E_WMA      =   'Windows Media audio files (WMA)|*.wma';
  E_MO3      =   'MOD2MO3 files (MO3)|*.mo3';
  E_IT       =   'PC Impulse Tracker files (IT)|*.it';
  E_XM       =   'PC Fast Tracker 2 files (XM)|*.xm';
  E_S3M      =   'PC Scream Tracker 3 files (S3M)|*.s3m';
  E_MTM      =   'PC MultiTracker files (MTM)|*.mtm';
  E_MOD      =   'Generic module format files (MOD)|*.mod';
  E_UMX      =   'Unreal Tournament music package (UMX)|*.umx';
  E_CDA      =   'AudioCD Tracks (CDA)|*.cda';
  E_ALL      =   'All files|*.*';

type
  TPLScrBar = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
  end;
  TPlayList = class(TWinControl)
  public
    constructor Create(AOwner: TComponent); override;
    procedure DefaultHandler(var Message); override;
    procedure WndProc(var Message: TMessage); override;
    procedure PLAreaMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure PLAreaMouseUp(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure PLAreaMouseMove(Sender: TObject; Shift: TShiftState; X,
       Y: Integer);
    procedure PLAreaMouseWheelDown(Sender: TObject; Shift: TShiftState;
       MousePos: TPoint; var Handled: Boolean);
    procedure PLAreaMouseWheelUp(Sender: TObject; Shift: TShiftState;
       MousePos: TPoint; var Handled: Boolean);
    procedure PLAreaDblClick(Sender: TObject);
    procedure PLAreaKeyDown(Sender: TObject; var Key: Word;
       Shift:   TShiftState);
    procedure PLAreaKeyUp(Sender: TObject; var Key: Word;
       Shift:   TShiftState);
    procedure MTimerPrc(Sender: TObject);
  end;
  TForm3 = class(TForm)
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    WAV1: TMenuItem;
    VTX1: TMenuItem;
    YM1: TMenuItem;
    PSG1: TMenuItem;
    N4: TMenuItem;
    PSG2: TMenuItem;
    N2: TMenuItem;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label1: TLabel;
    DirectionButton: TSpeedButton;
    LoopListButton: TSpeedButton;
    ImageList1: TImageList;
    PopupMenu2: TPopupMenu;
    RandomSort: TMenuItem;
    ByauthorSort: TMenuItem;
    BytitleSort: TMenuItem;
    ByfilenameSort: TMenuItem;
    Byfiletype1: TMenuItem;
    N3: TMenuItem;
    Finditem1: TMenuItem;
    Label2: TLabel;
    procedure WndProc(var Message: TMessage); override;
    procedure Add_Item_Dialog(Add:boolean);
    procedure Add_CD_Dialog(Add:boolean);
    procedure Add_Directory_Dialog(Add:boolean);
    procedure PlayNextItem;
    procedure PlayPreviousItem;
    procedure FormHide(Sender: TObject);
    procedure WAV1Click(Sender: TObject);
    procedure VTX1Click(Sender: TObject);
    procedure YM1Click(Sender: TObject);
    procedure PSG1Click(Sender: TObject);
    procedure PSG2Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Add_Files(SF:TStrings);
    procedure N2Click(Sender: TObject);
    procedure UpdateTray(Index:integer);
    procedure DropFiles(var Msg: TWmDropFiles);message wm_DropFiles;
    procedure Add_File(FN:string;Detect:boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure WMGETTIMELENGTH(var Msg: TMessage);message WM_GETTIMELENGTH;
    procedure Label1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SetDirection(Dir:integer);
    procedure LoopListButtonClick(Sender: TObject);
    procedure DirectionButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RandomSortClick(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure ByauthorSortClick(Sender: TObject);
    procedure BytitleSortClick(Sender: TObject);
    procedure ByfilenameSortClick(Sender: TObject);
    procedure SearchFilesInFolder(Dir:string;nps:integer);
    procedure Byfiletype1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Finditem1Click(Sender: TObject);
    procedure RedrawItemsLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
//PlayListItem parameters
 PPlayListItem = ^TPlayListItem;
 TPlayListItem = record
   FileName,Author,Title,Programm,Tracker,Computer,Date,Comment:string;
   FileType:Available_Types;
   Time,Loop,Offset,Address,Length,UnpackedSize,AY_Freq,Int_Freq,
   Channel_Mode,Number_Of_Channels,FormatSpec,Tag:Integer;
   Chip_Type:ChTypes;
   AL,AR,BL,BR,CL,CR:byte;
   Selected:boolean;
   Error:ErrorCodes;
 end;

procedure ClearParams;
procedure ClearPlayList;
procedure ClearSelection;
function AddPlayListItem(var PLItem:PPlayListItem):integer;
procedure PlayItem(Index:integer;Play:integer);
procedure RedrawItem(DC:HDC;n:integer);
procedure RedrawPlaylist(From:integer;DC:HDC;OnlyItems:boolean);
function GetPlayListString(PLItem:PPLayListItem):string;
procedure LoadAYL(AYLName:string);
procedure SaveAYL(AYLName:string);
procedure CalculatePlaylistScrollBar;
function CalculateTotalTime(Force:boolean):boolean;
function TimeSToStr(ms:integer):string;
procedure CreatePlayOrder;
function AllErrored:boolean;
procedure MakeVisible(Index:integer;All:boolean);

var
  Form3: TForm3;
  IsClicked:boolean;
  MTimer:TTimer;
  MTimerY:integer;
  MTimerOn:boolean = False;
  Direction:integer = -1;
  ListLooped:boolean = False;
  PLArea:TPlayList;
  PLScrBar:TPLScrBar;
  PlayingOrderItem:integer = -1;
  PlayingItem:integer = -1;
  PlayListItems:array of PPlayListItem;
  PlayingOrder:array of integer;
  LastSelected:integer = -1;
  ShownFrom,ListLineHeight:integer;
  PLDef_Number_Of_Channels:integer;
  PLDef_Channel_Mode:integer;
  PLDef_SoundChip_Frq:integer;
  PLDef_Chip_Type:ChTypes;
  PLDef_Player_Frq:integer;
  PLDef_AL,PLDef_AR,PLDef_BL,PLDef_BR,PLDef_CL,PLDef_CR:byte;
  DisablePLRedraw:boolean = False;
  PLColorBkSel,PLColorBkPl,PLColorBk,PLColorPlSel,PLColorPl,
  PLColorSel,PLColor,PLColorErrSel,PLColorErr:TColor;

implementation

uses LH5, ItemEdit, Mixer, Z80, ChanDir, WaveOutAPI, Convs, lightBASS, CDviaMCI,
  FindPLItem, SelectCDs;

type
  TMyCompare = function(Index1,Index2:integer):integer;

{$R *.DFM}

procedure MovePLItem(i,n:integer);
var
 PLI:pointer;
 j:integer;
begin
if i = n then exit;
if i > n then
 for j := i - 1 downto n do
  begin
   PLI := PlaylistItems[j + 1];
   PlaylistItems[j + 1] := PlaylistItems[j];
   PlaylistItems[j] := PLI
  end
else
 for j := i + 1 to n do
  begin
   PLI := PlaylistItems[j - 1];
   PlaylistItems[j - 1] := PlaylistItems[j];
   PlaylistItems[j] := PLI
  end;
CreatePlayOrder
end;

procedure MovePLItem2(i,n:integer);
begin
    if Item_Displayed = i then
     Item_Displayed := n
    else if (i < Item_Displayed) and
            (n >= Item_Displayed) then
     Dec(Item_Displayed)
    else if (i > Item_Displayed) and
            (n <= Item_Displayed) then
     Inc(Item_Displayed);
    if Scroll_Distination = i then
     Scroll_Distination := n
    else if (i < Scroll_Distination) and
            (n >= Scroll_Distination) then
     Dec(Scroll_Distination)
    else if (i > Scroll_Distination) and
            (n <= Scroll_Distination) then
     Inc(Scroll_Distination);
    if PlayingItem = i then
     begin
      PlayingItem := n;
      Form3.RedrawItemsLabel
     end
    else if (i < PlayingItem) and
            (n >= PlayingItem) then
     begin
      Dec(PlayingItem);
      Form3.RedrawItemsLabel
     end
    else if (i > PlayingItem) and
            (n <= PlayingItem) then
     begin
      Inc(PlayingItem);
      Form3.RedrawItemsLabel
     end;
    MovePLItem(i,n)
end;

procedure MakeVisible(Index:integer;All:boolean);
var
 n:integer;
begin
if Index <= ShownFrom then
 RedrawPlayList(Index,0,True)
else
 begin
  n := PLArea.ClientHeight div ListLineHeight;
  if Index - ShownFrom >= n  then
   RedrawPlayList(Index - n + 1,0,True)
  else if not All then
   RedrawItem(0,Index)
  else
   RedrawPlayList(ShownFrom,0,True)
 end
end;

procedure DoMove(Y:integer);
var
 Index:integer;
begin
  Index := (Y + ShownFrom * ListLineHeight) div ListLineHeight;
  if Index < 0 then
   Index := 0
  else if Index >= Length(PlaylistItems) then
   Index := Length(PlaylistItems) - 1;
  if  LastSelected <> Index then
   begin
    MovePLItem2(LastSelected,Index);
    MakeVisible(Index,True);
    ReprepareScroll;
    LastSelected := Index
   end
end;

procedure TPlaylist.MTimerPrc(Sender: TObject);
begin
DoMove(MTimerY)
end;

procedure StartTimer(Y:integer);
begin
MTimerY := Y;
DoMove(MTimerY);
if Y < 0 then
 Y := -Y
else
 Y := Y - PLArea.Height + 1;
Y := 300 - Y*10;
if Y <= 0 then Y := 1;
if MTimerOn then
 begin
  MTimer.Interval := Y;
  exit
 end;
MTimer := TTimer.Create(PLArea);
MTimerOn := True;
MTimer.Interval := Y;
MTimer.OnTimer := PLArea.MTimerPrc
end;

procedure StopTimer;
begin
if MTimerOn then
 begin
  MTimer.Free;
  MTimerOn := False
 end
end;

procedure TPlaylist.PLAreaMouseUp(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
begin
IsClicked := False;
StopTimer
end;

procedure TPlaylist.PLAreaMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if IsClicked and ([ssLeft] = Shift) and (LastSelected <> -1) then
 begin
  if (Y < 0) or
     (Y >= PLArea.ClientHeight - PLArea.ClientHeight mod ListLineHeight) then
   StartTimer(Y)
  else
   begin
    StopTimer;
    DoMove(Y)
   end
 end
end;

procedure CreatePlayOrder;
var
 i,j,l:integer;
begin
l := Length(PlayListItems);
SetLength(PlayingOrder,l);
if l = 0 then exit;
if Direction = 0 then
 for i := 0 to l - 1 do
  begin
   j := l - i - 1;
   PlayingOrder[i] := j;
   PlayListItems[j].Tag := i
  end
else if Direction <> 2 then
 for i := 0 to l - 1 do
  begin
   PlayingOrder[i] := i;
   PlayListItems[i].Tag := i
  end
else
 begin
  for i := 0 to l - 1 do
   PlayListItems[i].Tag := -1;
  i := 0;
  if PlayingItem >= 0 then
   begin
    PlayListItems[PlayingItem].Tag := 0;
    PlayingOrder[0] := PlayingItem;
    i := 1
   end;
  for i := i to l - 1 do
   begin
    repeat
     j := Random(l)
    until PlayListItems[j].Tag < 0;
    PlayListItems[j].Tag := i;
    PlayingOrder[i] := j
   end
 end;
if PlayingItem = - 1 then
 PlayingOrderItem := -1
else
 PlayingOrderItem := PlayListItems[PlayingItem].Tag
end;

procedure TForm3.Add_Item_Dialog(Add:boolean);
var
 s:string;
begin
if Russian_Interface then
 Form1.OpenDIalog1.Filter := T_SupTypes  + T_AllSup + T_ExtraTypes + '|' +
  T_VTX + '|' + T_YM  + '|' + T_AY +  '|' + T_PT1 + '|' + T_PT2 + '|' +
  T_PT3 + '|' + T_STC + '|' + T_STP + '|' + T_ASM + '|' + T_PSC + '|' +
  T_PSM + '|' +
  T_SQT + '|' + T_FTC + '|' + T_FXM + '|' + T_FLS + '|' + T_GTR + '|' +
  T_AYM + '|' + T_PSG + '|' + T_OUT + '|' + T_ZXAY+ '|' + T_MP3 + '|' +
  T_MP2 + '|' + T_MP1 + '|' + T_OGG + '|' + T_WAV + '|' + T_WMA + '|' +
  T_MO3 + '|' + T_IT  + '|' + T_XM  + '|' + T_S3M + '|' + T_MTM + '|' +
  T_MOD + '|' + T_UMX + '|' + T_CDA + '|' + T_AYEmulPL + '|' + T_WinampPL +
  '|' + T_ALL
else
 Form1.OpenDIalog1.Filter := E_SupTypes  + T_AllSup  + T_ExtraTypes + '|' +
  E_VTX + '|' + E_YM  + '|' + E_AY +  '|' + E_PT1 + '|' + E_PT2 + '|' +
  E_PT3 + '|' + E_STC + '|' + E_STP + '|' + E_ASM + '|' + E_PSC + '|' +
  E_PSM + '|' +
  E_SQT + '|' + E_FTC + '|' + E_FXM + '|' + E_FLS + '|' + E_GTR + '|' +
  E_AYM + '|' + E_PSG + '|' + E_OUT + '|' + E_ZXAY+ '|' + E_MP3 + '|' +
  E_MP2 + '|' + E_MP1 + '|' + E_OGG + '|' + E_WAV + '|' + E_WMA + '|' +
  E_MO3 + '|' + E_IT  + '|' + E_XM  + '|' + E_S3M + '|' + E_MTM + '|' +
  E_MOD + '|' + E_UMX + '|' + E_CDA + '|' + E_AYEmulPL + '|' + E_WinampPL +
  '|' + E_ALL;
if Form1.OpenDialog1.Execute then
 begin
  s := ExtractFilePath(Form1.OpenDialog1.FileName);
  Form1.OpenDialog1.InitialDir := s;
  if AutoSaveDefDir then
   Form1.DefaultDirectory := s;
  try
   if not Add then
    begin
     StopAndFreeAll;
     ClearPlayList
    end;
   Add_Files(Form1.OpenDialog1.Files);
   CalculateTotalTime(False)
  finally
   CreatePlayOrder;
   RedrawPlaylist(0,0,True)
  end;
  if not Add then PlayItem(0,0)
 end
end;

procedure TForm3.Add_CD_Dialog(Add:boolean);
var
 i,j{,n,t}:integer;
 WasInit:boolean;
begin
if CDList.ShowModal = mrOk then
 begin
      try
       if not Add then
        begin
         StopAndFreeAll;
         ClearPlayList
        end;

for i := 0 to Length(CDDrives) - 1 do
 if CDList.ListBox1.Selected[i] then
  begin
   WasInit := CDIDs[i] <> 0;
   InitCDDevice(i);
   try
    for j := 1 to CDGetNumberOfTracks(i) do
     AddCDTrack(i,j,True);
   finally
    if not WasInit then CloseCDDevice(i)
   end
  end;

       CalculateTotalTime(False)
      finally
       CreatePlayOrder;
       RedrawPlaylist(0,0,True);
      end;
      if not Add then PlayItem(0,0)
 end
end;

procedure PlayItem;
var
 i:integer;
begin
if (Index < 0) or (Index >= Length(PlayListItems)) then exit;
PlayingOrderItem := Index;
Index := PlayingOrder[Index];
i := PlayingItem;
PlayingItem := Index;
Form3.RedrawItemsLabel;
if (CurFileType <> CDAFile) or (PlayListItems[Index].FileType <> CDAFile) then StopPlaying;
FreePlayingResourses;
if i >= 0 then RedrawItem(0,i);
RedrawItem(0,Index);
PrepareItem(Index);
if not (CurFileType in [BASSFileMin..BASSFileMax]) then
 begin
  FreeBASS;
  UnloadBASS
 end;
if CurFileType <> CDAFile then
 FreeAllCD;
with PlayListItems[Index]^ do
 begin
  MakeVisible(Index,False);
  Scroll_Distination := Index;
  if Error <> FileNoError then
   begin
    Time_ms := 0;
    ClearTimeInd := True;
    Form3.UpdateTray(Index);
    PostMessage(Form1.Handle,WM_PLAYNEXTITEM,0,0);
    exit
   end;

  i := -1;
  if Time = 0 then
   begin
    GetTime(FileHandle,Index,True,i);
    RedrawItem(0,Index);
    if Error <> FileNoError then
     begin
      Time_ms := 0;
      ClearTimeInd := True;
      Form3.UpdateTray(Index);
      PostMessage(Form1.Handle,WM_PLAYNEXTITEM,0,0);
      exit
     end
   end;

  if Loop < 0 then
   Loop := i;
  LoopVBL := Loop;
  if LoopVBL < 0 then LoopVBL := 0;
  if FileType in [OUTFile,ZXAYFile,EPSGFile,BASSFileMin..BASSFileMax] then
   begin
    ProgrMax := Time;
    Time_ms := Time
   end
  else if (FileType = AYFile) or (FileType = AYMFile) then
   begin
    Time_ms := round(Time / FrqZ80 *  MaxTStates * 1000);
    Global_Tick_Max := Time
   end
  else if FileType = CDAFile then
   begin
    ProgrMax := Time;
    Time_ms := round(Time * 1000 / 75)
   end
  else
   begin
    Time_ms := round(Time / Interrupt_Freq * 1000000);
    Global_Tick_Max := Time
   end;

  FileAvailable := True;

  if Form2.CheckBox8.Checked then
   if Number_Of_Channels > 0 then
    Set_Stereo(Number_Of_Channels)
   else if PLDef_Number_Of_Channels > 0 then
    Set_Stereo(PLDef_Number_Of_Channels);

  if Form2.CheckBox2.Checked then
   if Chip_Type <> No_Chip then
    ChType := Chip_Type
   else if PLDef_Chip_Type <> No_Chip then
    ChType := PLDef_Chip_Type;

  if Form2.CheckBox1.Checked then
   case Channel_Mode of
   0..6: Form1.Set_Mode(Channel_Mode);
   -2:   Form1.Set_Mode_Manual(AL,AR,BL,BR,CL,CR);
   -1:   case PLDef_Channel_Mode of
         0..6: Form1.Set_Mode(PLDef_Channel_Mode);
         -2:   Form1.Set_Mode_Manual(PLDef_AL,PLDef_AR,PLDef_BL,PLDef_BR,
                                          PLDef_CL,PLDef_CR);
         end;
   end;

  AYFileEnableAutoSwitch := False;

  if Form2.CheckBox3.Checked then
   if AY_Freq >= 0 then
    Form1.Set_Chip_Frq(AY_Freq)
   else if PLDef_SoundChip_Frq >= 0 then
    Form1.Set_Chip_Frq(PLDef_SoundChip_Frq)
   else if (CurFileType = AYFile) or (CurFileType = AYMFile) then
    begin
     AYFileEnableAutoSwitch := True;
     Form1.Set_Chip_Frq(1773400)
    end
   else if (CurFileType = YM2File) then
    Form1.Set_Chip_Frq(2000000);

  if Form2.CheckBox9.Checked then
   if Int_Freq >= 0 then
    Form1.Set_Player_Frq(Int_Freq)
   else if PLDef_Player_Frq >= 0 then
    Form1.Set_Player_Frq(PLDef_Player_Frq)
   else if (CurFileType = YM2File) then
    Form1.Set_Player_Frq(50000);

  Calculate_Level_Tables

 end;
Form3.UpdateTray(Index);
case Play of
-1,0:
  begin
   Calculate_Slider_Points;
   if Play = 0 then PlayCurrent
  end;
1:WAV_Converter;
2:VTX_Converter;
3:YM6_Converter;
4:PSG_Converter;
5:ZXAY_Converter
end
end;

procedure TForm3.UpdateTray(Index:integer);
var
 i:integer;
begin
CurItem.PLStr := GetPlayListString(PlayListItems[Index]);
with PlayListItems[Index]^ do
 begin
  CurItem.Title := Title;
  CurItem.Author := Author;
  CurItem.Programm := Programm;
  CurItem.Comment := Comment;
  CurItem.Tracker := Tracker;
  CurItem.FileName := FileName
 end;
Application.Title := CurItem.PLStr;
i := Length(CurItem.PLStr);
if i > 63 then i := 60;
move(CurItem.PLStr[1],TrIcon.SzTip[0],i);
TrIcon.SzTip[i] := #0;
if Length(CurItem.PLStr) > 63 then
 DWORDPtr(@TrIcon.SzTip[60])^ := $2E2E2E;
Form1.ChangeTrayIcon
end;

procedure TForm3.PlayNextItem;
var
 Tmp:integer;
begin
Tmp := PlayingOrderItem + 1;
if Tmp >= Length(PlayListItems) then
 if ListLooped and not AllErrored then
  Tmp := 0;
PlayItem(Tmp,0)
end;

procedure TForm3.PlayPreviousItem;
var
 Tmp:integer;
begin
Tmp := PlayingOrderItem - 1;
if Tmp < 0 then
 if ListLooped and not AllErrored then
  Tmp := Length(PlayListItems) - 1;
PlayItem(Tmp,0)
end;

procedure TForm3.FormHide(Sender: TObject);
begin
if ButtZoneRoot<>nil then
 if ButList.Is_On then
  ButList.Switch_Off
end;

procedure ClearParams;
begin
LastSelected := -1;
Item_Displayed := -1;
PlayingOrderItem := -1;
PlayingItem := -1;
Scroll_Distination := -1;
Scroll_Offset := scr_lineheight;
PLDef_Number_Of_Channels := 0;
PLDef_Channel_Mode := -1;
PLDef_SoundChip_Frq := -1;
PLDef_Chip_Type := No_Chip;
PLDef_Player_Frq := -1;
ClearTimeInd := True
end;

procedure ClearPlayListItems;
var
 i:integer;
begin
LastSelected := -1;
for i := 0 to Length(PlayListItems) - 1 do
 Dispose(PlayListItems[i]);
PlayListItems := nil
end;

procedure ForceScrollForDelete;
begin
Item_Displayed := Scroll_Distination;
Scroll_Offset := scr_lineheight;
ReprepareScroll;
Scroll_Distination := -1;
Item_Displayed := -1;
end;

procedure ClearPlayList;
var
 Client:TRect;
 hDC1:HDC;
 hbr:HBRUSH;
 si:tagSCROLLINFO;
begin
if Scroll_Distination <> Item_Displayed then
 ForceScrollForDelete;
ClearPlayListItems;
PlayingOrder := nil;
PlayingOrderItem := -1;
PlayingItem := -1;

si.cbSize := sizeof(si);
si.fMask := SIF_ALL;
si.nMin := 0;
si.nMax := 0;
si.nPage := 1;
si.nPos := 0;
SetScrollInfo(PLScrBar.Handle,SB_CTL,si,True);

Form3.Label1.Caption := '0:00';
Form3.Label2.Caption := '0/0';

Client.Left := 0;
Client.Top := 0;
Client.Right := PLArea.ClientWidth;
Client.Bottom := PLArea.ClientHeight;
hDC1 := GetDC(PLArea.Handle);
hbr := CreateSolidBrush(PLColorBk);
FillRect(hDC1,Client,hbr);
DeleteObject(hbr);
ReleaseDC(PLArea.Handle,hDC1);
ClearParams
end;

procedure TForm3.WAV1Click(Sender: TObject);
begin
PlayItem(PlayListItems[LastSelected].Tag,1)
end;

procedure TForm3.VTX1Click(Sender: TObject);
begin
PlayItem(PlayListItems[LastSelected].Tag,2)
end;

procedure TForm3.YM1Click(Sender: TObject);
begin
PlayItem(PlayListItems[LastSelected].Tag,3)
end;

procedure TForm3.PSG1Click(Sender: TObject);
begin
PlayItem(PlayListItems[LastSelected].Tag,4)
end;

procedure TForm3.PSG2Click(Sender: TObject);
begin
PlayItem(PlayListItems[LastSelected].Tag,5)
end;

procedure TForm3.N1Click(Sender: TObject);
var
 Temp:integer;
begin
if (LastSelected < 0) or (LastSelected >= Length(PlayListItems)) then exit;
with TForm5.Create(Self) do
 try
  with PlayListItems[LastSelected]^ do
   begin
    Edit1.Text := Author;
    Edit2.Text := Title;
    Edit3.Text := Programm;
    Edit4.Text := Tracker;
    Edit5.Text := Computer;
    Edit6.Text := Date;
    Edit20.Text:= FileName;
    Memo1.Text := Comment;
    SetPlayItems(Chip_Type,Number_Of_Channels,AY_Freq,
                     Int_Freq,Channel_Mode,AL,AR,BL,BR,CL,CR);
    if FileType = Unknown then
     ComboBox2.ItemIndex := -1
    else
     ComboBox2.ItemIndex := Integer(FileType) - 1;
    Edit21.Text := IntToStr(Offset);
    Edit22.Text := IntToStr(Length);
    Edit23.Text := IntToStr(Address);
    Edit24.Text := IntToStr(Time);
    Edit25.Text := IntToStr(Loop);
    if not Russian_Interface then
     begin
      Caption := 'List''s Item Adjusting';
      GroupBox1.Caption := 'Information';
      GroupBox1.Caption := 'Information';
      GroupBox2.Caption := 'Playing';
      GroupBox3.Caption := 'Chip';
      GroupBox4.Caption := 'Chip frequency';
      GroupBox5.Caption := 'Player Frequency';
      GroupBox6.Caption := 'Number of channels';
      GroupBox7.Caption := 'Channels amplification';
      GroupBox8.Caption := 'Default list settings';
      GroupBox9.Caption := 'File';
      Label1.Caption := 'Author';
      Label2.Caption := 'Title';
      Label3.Caption := 'Program';
      Label4.Caption := 'Tracker';
      Label5.Caption := 'Computer';
      Label6.Caption := 'Date';
      Label7.Caption := 'Comment:';
      Label11.Caption := 'Name';
      Label12.Caption := 'Type';
      Label13.Caption := 'Offset';
      Label14.Caption := 'Address';
      Label16.Caption := 'Time';
      Label17.Caption := 'Length';
      Label18.Caption := 'Loop';
      RadioButton10.Caption := 'Stereo';
      RadioButton11.Caption := 'Mono';
      RadioButton12.Caption := 'Another';
      RadioButton7.Caption := 'Another';
      RadioButton9.Caption := 'Another';
      RadioButton13.Caption := 'Standard';
      RadioButton14.Caption := 'Default';
      RadioButton15.Caption := 'Default';
      RadioButton16.Caption := 'Default';
      RadioButton17.Caption := 'Default';
      RadioButton18.Caption := 'Default';
      Button1.Caption := 'Load';
      Button2.Caption := 'Save';
      Button4.Caption := 'Cancel'
     end;
    if ShowModal = mrOK then
     begin
      Author := Trim(Edit1.Text);
      Title := Trim(Edit2.Text);
      Programm := Trim(Edit3.Text);
      Tracker := Trim(Edit4.Text);
      Computer := Trim(Edit5.Text);
      Date := Trim(Edit6.Text);
      Comment := Trim(Memo1.Text);
      FileName := Trim(Edit20.Text);
      GetPlayItems(Chip_Type,Number_Of_Channels,AY_Freq,
                     Int_Freq,Channel_Mode,AL,AR,BL,BR,CL,CR);
      if ComboBox2.ItemIndex <> -1 then
       FileType := Available_Types(ComboBox2.ItemIndex + 1);
      Val(Edit21.Text,Offset,Temp);
      Val(Edit22.Text,Length,Temp);
      Val(Edit23.Text,Address,Temp);
      Val(Edit24.Text,Time,Temp);
      Val(Edit25.Text,Loop,Temp);
      RedrawItem(0,LastSelected);
      Form3.UpdateTray(LastSelected);
      ReprepareScroll
     end
   end  
 finally
  Free
 end
end;

procedure LoadAYL(AYLName:string);
const
 NumOfTokens = 21;
 MyTokens:array[0..NumOfTokens - 1] of string =
  ('ChipType','Channels','ChannelsAllocation','ChipFrequency',
   'PlayerFrequency','Offset','Length','Address','Loop','Time','Original',
   'Name','Author','Program','Computer','Date','Comment','Tracker','Type',
   'ams_andsix','FormatSpec');
 MaxTokenLen = 18;
var
 m3uf:TextFile;
 String1,String2:string;
 TokenError:boolean;
 i2,Vers:integer;

 procedure ExtractToken(S1:string;var S2:string;var Ind:integer);
 var
  i:integer;
 begin
  i := 1;
  S2 := '';
  while (i <= MaxTokenLen) and (i <= Length(S1)) and (S1[i] <> '=') do
   begin
    S2 := S2 + S1[i];
    inc(i)
   end;
  if i > Length(S1) then
   begin
    TokenError := True;
    exit
   end;
  Ind := 0;
  while (Ind < NumOfTokens) and (MyTokens[Ind] <> S2) do inc(Ind);
  if Ind = NumOfTokens then
   begin
    TokenError := True;
    exit
   end;
  S2 := '';
  for i := i + 1 to Length(S1) do S2 := S2 + S1[i];
 end;

 procedure ExtractChType(S1:string;var ChT:ChTypes);
 begin
  if S1 = 'AY' then ChT := AY_Chip
  else if S1 = 'YM' then ChT := YM_Chip
  else TokenError := True;
 end;

 procedure ExtractChans(S1:string;var Chs:integer);
 begin
  if S1 = 'Mono' then Chs := 1 else
  if S1 = 'Stereo' then Chs := 2 else TokenError := True;
 end;

 procedure ExtractChanMode(S1:string;var ChM:integer;
                                    var a1,a2,a3,a4,a5,a6:byte);
 var
  i,j,Temp:integer;
  S2:string;
  ai:array[0..5]of byte;
 begin
  if S1='Mono' then ChM:=0 else
  if S1='ABC' then ChM:=1 else
  if S1='ACB' then ChM:=2 else
  if S1='BAC' then ChM:=3 else
  if S1='BCA' then ChM:=4 else
  if S1='CAB' then ChM:=5 else
  if S1='CBA' then ChM:=6 else
   begin
    ChM := -2; i := 1; S1 := S1 + ',';
    for j := 0 to 5 do
     begin
      S2 := '';
      while (i <= length(S1)) and (S1[i] <> ',') do
       begin
        S2 := S2 + S1[i];
        inc(i)
       end;
      if i > length(S1) then
       begin
        TokenError := True;
        exit
       end;
      Val(S2,ai[j],Temp);
      if Temp <> 0 then
       begin
        TokenError := True;
        exit
       end;
      inc(i)
     end;
    a1 := ai[0];
    a2 := ai[1];
    a3 := ai[2];
    a4 := ai[3];
    a5 := ai[4];
    a6 := ai[5]
   end
 end;

 procedure ExtractInteger(S1:string;var Integ:integer);
 var
  Temp:integer;
 begin
  Val(S1,Integ,Temp);
  if Temp <> 0 then TokenError := True
 end;

 procedure ExtractFType(S1:string;var FT:Available_Types);
 begin
  FT := MaxType;
  while (FT > Unknown)and(STypes[FT] <> S1) do dec(FT);
  if FT = Unknown then TokenError := True;
 end;

 function ConvertCR(s:string):string;
 var
  i,i0,j:integer;
 begin
  if Vers < 13 then
   begin
    Result := s;
    exit
   end;
  Result := '';
  i := 1;
  while i <= Length(s) do
   begin
    j := 0;
    i0 := i;
    while (i <= Length(s)) and (s[i] <> '\') do
     begin
      Inc(i);
      Inc(j)
     end;
    if j <> 0 then
     Result := Result + Copy(s,i0,j);
    if i >= Length(s) then break;
    if s[i + 1] = 'n' then
     begin
      s[i] := #13;
      s[i + 1] := #10
     end
    else
     begin
      Inc(i,2);
      Result := Result + s[i - 1]
     end
   end
 end;

var
 i:integer;
 PLItemWork:TPlayListItem;
 PLItem:PPlayListItem;
begin
 AssignFile(m3uf,AYLName);
 Reset(m3uf);
 try
 if not eof(m3uf) then
  begin
   Readln(m3uf,String1);
   if String1 = Version_String + '0' then
    Vers := 10
   else if String1 = Version_String + '1' then
    Vers := 11
   else if String1 = Version_String + '2' then
    Vers := 12
   else if String1 = Version_String + '3' then
    Vers := 13
   else
    Vers := 0;
   if Vers <> 0 then
    begin
     SetCurrentDir(ExtractFileDir(AYLName));
     TokenError := False;
     if not eof(m3uf) then
      begin
       ReadLn(m3uf,String1);
       if String1 = '<' then
        while not eof(m3uf) do
         begin
          ReadLn(m3uf,String1);
          if String1 = '>' then
           begin
            if not eof(m3uf) then ReadLn(m3uf,String1)
            else TokenError := True;
            break
           end;
          if String1 <> '' then
           begin
            ExtractToken(String1,String2,i2);
            if TokenError then break;
            case i2 of
            0:   ExtractChType(String2,PLDef_Chip_Type);
            1:   ExtractChans(String2,PLDef_Number_Of_Channels);
            2:   ExtractChanMode(String2,PLDef_Channel_Mode,PLDef_AL,PLDef_AR,
                                 PLDef_BL,PLDef_BR,PLDef_CL,PLDef_CR);
            3:   ExtractInteger(String2,PLDef_SoundChip_Frq);
            4:   begin
                  ExtractInteger(String2,PLDef_Player_Frq);
                  if (Vers = 10) and not TokenError then
                   PLDef_Player_Frq := PLDef_Player_Frq * 1000;
                 end
            else
             TokenError := True
            end;
            if TokenError then break;
           end;
         end;

       while not TokenError do
        begin
         if eof(m3uf) then
          begin
           String2 := '';
           TokenError := True
          end
         else
          ReadLn(m3uf,String2);
         if String2 <> '<' then
          begin
           if (LowerCase(ExtractFileExt(String1)) = '.cda') or FileExists(String1) then
            Add_Songs_From_File(ExpandFileName(String1),True);
           String1 := String2
          end
         else if (LowerCase(ExtractFileExt(String1)) = '.cda') or FileExists(String1) then
          begin
           with PLItemWork do
            begin
             FileName := ExpandFileName(String1);
             FileType := Unknown;
             Chip_Type := No_Chip;
             Number_Of_Channels := 0;
             Channel_Mode := -1;
             AY_Freq := -1;
             Int_Freq := -1;
             Offset := 0;
             Length := -1;
             Address := 0;
             Loop := -1;
             Time := 0;
             UnpackedSize := 0;
             Title := '';
             Author := '';
             Programm := '';
             Computer := '';
             Date := '';
             Comment := '';
             Tracker := '';
             Error := FileNoError;
             FormatSpec := -1;
             Selected := False;
             while not eof(m3uf) do
              begin
               ReadLn(m3uf,String1);
               if String1 = '>' then
                begin
                 if FileType = Unknown then
                  begin
                   String1 := AnsiUpperCase(ExtractFileExt(FileName));
                   if System.Length(String1) <> 0 then String1[1] := ' ';
                   String1 := Trim(String1);
                   ExtractFType(String1,FileType);
                  end;
                 break
                end;
               ExtractToken(String1,String2,i2);
               if TokenError then break;
               case i2 of
               0:   ExtractChType(String2,Chip_Type);
               1:   ExtractChans(String2,Number_Of_Channels);
               2:   ExtractChanMode(String2,Channel_Mode,AL,AR,
                                    BL,BR,CL,CR);
               3:   ExtractInteger(String2,Ay_Freq);
               4:   begin
                     ExtractInteger(String2,Int_Freq);
                     if (Vers = 10) and not TokenError then
                      Int_Freq := Int_Freq * 1000;
                    end;
               5:   ExtractInteger(String2,Offset);
               6:   ExtractInteger(String2,Length);
               7:   ExtractInteger(String2,Address);
               8:   ExtractInteger(String2,Loop);
               9:   ExtractInteger(String2,Time);
               10:  ExtractInteger(String2,UnpackedSize);
               11:  Title := String2;
               12:  Author := String2;
               13:  Programm := String2;
               14:  Computer := String2;
               15:  Date := String2;
               16:  Comment := ConvertCR(String2);
               17:  Tracker := String2;
               18:  ExtractFType(String2,FileType);
               19,20:  ExtractInteger(String2,FormatSpec)
               end
              end
            end;
           if not TokenError then
            begin
             if (PLItemWork.FileType in [YM2File..YM6File]) and
                (PLItemWork.UnpackedSize = 0) then
              begin
               i := Length(PlaylistItems);
               Add_Songs_From_File(PLItemWork.FileName,False);
               if i <> Length(PlaylistItems) - 1 then exit;
               with PlaylistItems[i]^ do
                begin
                 PLItemWork.Offset := Offset;
                 PLItemWork.FileType := FileType;
                 PLItemWork.Length := Length;
                 PLItemWork.UnpackedSize := UnpackedSize;
                 PLItemWork.FormatSpec := FormatSpec
                end
              end
             else
              i := AddPlaylistItem(PLItem);
             PlaylistItems[i]^ := PLItemWork;
             RedrawItem(0,i);
             if not eof(m3uf) then Readln(m3uf,String1) else TokenError := True
            end
          end
         else
          begin
           while not eof(m3uf) and (String2 <> '>') do Readln(m3uf,String2);
           if not eof(m3uf) then Readln(m3uf,String1) else TokenError := True
          end
        end
      end
    end
  end
 finally
  CloseFile(m3uf);
  ReprepareScroll
 end
end;

procedure SaveAYL(AYLName:string);
Const
 NChan:array[1..2] of array [0..6] of char=
       ('Mono','Stereo');
 ChanAl:array[0..6] of array [0..4] of char=
       ('Mono','ABC','ACB','BAC','BCA','CAB','CBA');
 ChipT:array[AY_Chip..YM_Chip] of array [0..1] of char=
       ('AY','YM');
var
 m3uf:TextFile;
 flag:boolean;

 procedure AddBr;
 begin
  if not Flag then
   begin
    Writeln(m3uf,'<');
    Flag := True
   end;
 end;

 procedure WriteParam(s:string);
 begin
  AddBr;
  Write(m3uf,s)
 end;

 procedure WritelnParam(s:string);
 begin
  AddBr;
  Writeln(m3uf,s)
 end;

 function ConvCR(s:string):string;
 var
  i,i0,j:integer;
 begin
  Result := '';
  i := 1;
  while i <= Length(s) do
   begin
    j := 0;
    i0 := i;
    while (i <= Length(s)) and not (s[i] in ['\',#13]) do
     begin
      Inc(i);
      Inc(j)
     end;
    if j <> 0 then
     Result := Result + Copy(s,i0,j);
    if i > Length(s) then break;
    if s[i] = '\' then
     begin
      Result := Result + '\\';
      Inc(i)
     end
    else
     begin
      if i = Length(s) then break;
      Result := Result + '\n';
      Inc(i,2)
     end
   end
 end;

var
 i:integer;
 FName:string;
begin
AssignFile(m3uf,AYLName);
Rewrite(m3uf);
try
 Writeln(m3uf,Version_String + '3');
 flag := False;
 if PLDef_Number_Of_Channels > 0 then
  WritelnParam('Channels=' + NChan[PLDef_Number_Of_Channels]);
 if PLDef_Channel_Mode <> -1 then
  begin
   WriteParam('ChannelsAllocation=');
   if PLDef_Channel_Mode >= 0 then
    Writeln(m3uf,ChanAl[PLDef_Channel_Mode])
   else
    Writeln(m3uf,IntToStr(PLDef_AL) + ',' + IntToStr(PLDef_AR) + ','
               + IntToStr(PLDef_BL) + ',' + IntToStr(PLDef_BR) + ','
               + IntToStr(PLDef_CL) + ',' + IntToStr(PLDef_CR))
  end;
 if PLDef_SoundChip_Frq >= 0 then
  WritelnParam('ChipFrequency=' + IntToStr(PLDef_SoundChip_Frq));
 if PLDef_Player_Frq >= 0 then
  WritelnParam('PlayerFrequency=' + IntToStr(PLDef_Player_Frq));
 if PLDef_Chip_Type <> No_Chip then
  WritelnParam('ChipType=' + ChipT[PLDef_Chip_Type]);
 if flag then
  begin
   Writeln(m3uf,'>');
   flag := False
  end;
 for i := 0 to Length(PlaylistItems) - 1 do
  with PlaylistItems[i]^ do
   if FileType <> Unknown then
    begin
     Writeln(m3uf,FileName);
     if (Number_Of_Channels <> PLDef_Number_Of_Channels) and
        (Number_Of_Channels > 0) then
      WritelnParam('Channels=' + NChan[Number_Of_Channels]);
     if (Channel_Mode <> PLDef_Channel_Mode) and
        (Channel_Mode <> -1) then
      begin
       WriteParam('ChannelsAllocation=');
       if Channel_Mode >= 0 then
        Writeln(m3uf,ChanAl[Channel_Mode])
       else
        Writeln(m3uf,IntToStr(AL) + ',' + IntToStr(AR) + ','
                   + IntToStr(BL) + ',' + IntToStr(BR) + ','
                   + IntToStr(CL) + ',' + IntToStr(CR));
      end;
     if ((AY_Freq <> PLDef_SoundChip_Frq) and (AY_Freq >= 0)) then
      WritelnParam('ChipFrequency=' + IntToStr(AY_Freq));
     if ((Int_Freq <> PLDef_Player_Frq) and (Int_Freq >= 0)) then
      WritelnParam('PlayerFrequency=' + IntToStr(Int_Freq));
     if (Chip_Type <> PLDef_Chip_Type) and (Chip_Type <> No_Chip) then
      WritelnParam('ChipType=' + ChipT[Chip_Type]);
     if Author <> '' then
      WritelnParam('Author=' + Author);
     if Title <> '' then
      WritelnParam('Name=' + Title);
     if Programm <> '' then
      WritelnParam('Program=' + Programm);
     if Tracker <> '' then
      WritelnParam('Tracker=' + Tracker);
     if Computer <> '' then
      WritelnParam('Computer=' + Computer);
     if Date <> '' then
      WritelnParam('Date=' + Date);
     if Comment <> '' then
      WritelnParam('Comment=' + ConvCR(Comment));
     FName := UpperCase(ExtractFileExt(FileName));
     if (FName <> SExts[FileType]) or
        (FileType in [EPSGFile,YM2File..YM6File,ASC0File]) then
      WritelnParam('Type=' + STypes[FileType]);
     if (Address <> 0) and (FileType <> FXMFile) then
      WritelnParam('Address=' + IntToStr(Address));
     if (FName <> SExts[FileType]) or (FileType in [VTXFile..YM6File,ASC0File]) then
      WritelnParam('Length=' + IntToStr(Length));
     if FileType in [VTXFile..YM6File] then
      WritelnParam('Original=' + IntToStr(UnpackedSize));
     if Offset <> 0 then
      WritelnParam('Offset=' + IntToStr(Offset));
     if Time <> 0 then
      WritelnParam('Time=' + IntToStr(Time));
     if Loop >= 0 then
      WritelnParam('Loop=' + IntToStr(Loop));
     if ((FileType = FXMFile) and (FormatSpec <> 31)) or
        ((FormatSpec <> -1) and
         (FileType in [YM5File,YM6File,EPSGFile,AYMFile,CDAFile])) then
      WritelnParam('FormatSpec=' + IntToStr(FormatSpec));
     if flag then
      begin
       if FileType = FXMFile then
        Writeln(m3uf,'Address=' + IntToStr(Address));
       Writeln(m3uf,'>');
       flag := False
      end
    end
finally
 CloseFile(m3uf)
end
end;

procedure TForm3.Add_Files(SF:TStrings);
var
 Index:integer;
begin
with SF do
 for Index := 0 to Count - 1 do
  Add_File(Strings[Index],True);
end;

procedure TForm3.Add_File(FN:string;Detect:boolean);
var
 m3uf:TextFile;
 String1,Ext:string;
begin
if FileExists(FN) then
 begin
  Ext := LowerCase(ExtractFileExt(FN));
  if Ext = '.ayl' then
   LoadAYL(FN)
  else if Ext = '.m3u' then
   begin
    SetCurrentDir(ExtractFileDir(FN));
    AssignFile(m3uf,FN);
    Reset(m3uf);
    while not eof(m3uf) do
     begin
      ReadLn(m3uf,String1);
      if (LowerCase(ExtractFileExt(String1)) = '.cda') or FileExists(String1) then
       Add_Songs_From_File(ExpandFileName(String1),True)
     end;
     CloseFile(m3uf);
   end
  else
   Add_Songs_From_File(FN,Detect)
 end
end;

procedure Add_FileAtPos(FN:string;Detect:boolean;var n:integer);
var
 i:integer;
begin
i := Length(PlaylistItems);
DisablePLRedraw := True;
Form3.Add_File(FN,Detect);
DisablePLRedraw := False;
for i := i to Length(PlaylistItems) - 1 do
 begin
  MovePLItem2(i,n);
  Inc(n)
 end;
ReprepareScroll;
RedrawPlaylist(ShownFrom,0,True)
end;

function RemoveStdExt(Ext:Available_Types;Force:boolean;const FileName:string):string;
var
 SExt:string;
 i:integer;
begin
SExt := Trim(FileName);
i := Length(SExt);
while (i > 1) and (SExt[i] <> '.') do Dec(i);
if i = 1 then
 begin
  Result := FileName;
  exit
 end;
SExt := UpperCase(Copy(SExt,i,Length(SExt) - i + 1));
if (SExts[Ext] = SExt) or
   (Force and ((SExt = '.TRD') or (SExt = '.SCL') or (SExt = '.SNA'))) then
 Result := Copy(FileName,1,i - 1)
else
 Result := FileName;
end;

procedure TForm3.N2Click(Sender: TObject);
var
 FileOut:file;
 Buffer:ModTypes;
 Exten,FN:string;
 i:integer;
begin
if (LastSelected < 0) or (LastSelected >= Length(PlayListItems)) then exit;
if not (PlaylistItems[LastSelected].FileType in [STCFile..GTRFile]) then exit;
Exten := LowerCase(SExts[PlaylistItems[LastSelected].FileType]);
Form1.SaveDialog1.DefaultExt := Copy(Exten,2,Length(Exten) - 1);
if Russian_Interface then
 case PlaylistItems[LastSelected].FileType of
 STCFile:
  Form1.SaveDialog1.Filter := T_STC;
 ASCFile,ASC0File:
  Form1.SaveDialog1.Filter := T_ASM;
 STPFile:
  Form1.SaveDialog1.Filter := T_STP;
 PSCFile:
  Form1.SaveDialog1.Filter := T_PSC;
 FTCFile:
  Form1.SaveDialog1.Filter := T_FTC;
 PT1File:
  Form1.SaveDialog1.Filter := T_PT1;
 PT2File:
  Form1.SaveDialog1.Filter := T_PT2;
 PT3File:
  Form1.SaveDialog1.Filter := T_PT3;
 SQTFile:
  Form1.SaveDialog1.Filter := T_SQT;
 GTRFile:
  Form1.SaveDialog1.Filter := T_GTR
 end
else
 case PlaylistItems[LastSelected].FileType of
 STCFile:
  Form1.SaveDialog1.Filter := E_STC;
 ASCFile,ASC0File:
  Form1.SaveDialog1.Filter := E_ASM;
 STPFile:
  Form1.SaveDialog1.Filter := E_STP;
 PSCFile:
  Form1.SaveDialog1.Filter := E_PSC;
 FTCFile:
  Form1.SaveDialog1.Filter := E_FTC;
 PT1File:
  Form1.SaveDialog1.Filter := E_PT1;
 PT2File:
  Form1.SaveDialog1.Filter := E_PT2;
 PT3File:
  Form1.SaveDialog1.Filter := E_PT3;
 SQTFile:
  Form1.SaveDialog1.Filter := E_SQT;
 GTRFile:
  Form1.SaveDialog1.Filter := E_GTR
 end;
Form1.SaveDialog1.InitialDir := ExtractFilePath(
                        PlaylistItems[LastSelected].FileName);
FN := '';
with PlaylistItems[LastSelected]^ do
 begin
  if System.Length(Programm) > ImageIDLen + 3 then
   if Copy(Programm,1,ImageIDLen) = ImageID then
    begin
     i := Pos('>',Programm);
     if (i > ImageIDLen + 1) and (i < System.Length(Programm)) and
        (Programm[i - 1] = '-') then
      FN := Trim(Copy(Programm,i + 1,System.Length(Programm) - i))
    end;
//  if (FN = '') then FN := Trim(Title);
  if FN = '' then
   begin
    FN := IntToHex(LastSelected,trunc(ln(System.Length(PlaylistItems))/ln(16)) + 1);
    FN := RemoveStdExt(FileType,True,ExtractFileName(FileName)) + '_' + FN
   end;
 end;

i := Length(Form1.SaveDialog1.InitialDir) + 1;
if i + Length(FN) > MAX_PATH then
 begin
  i := MAX_PATH - i; if i < 0 then i := 0;
  SetLength(FN,i)
 end;
for i := 1 to Length(FN) do
 case FN[i] of
 #0..#$1f,'\','/','?','*': FN[i] := '_';
 ':': FN[i] := ';';
 '|': FN[i] := 'l';
 '<': FN[i] := '{';
 '>': FN[i] := '}';
 '"': FN[i] := '''';
 end;
if (FN = '.') or (FN = '..') then FN := '';
Form1.SaveDialog1.FileName := FN;
if not LoadTrackerModule(Buffer,LastSelected,0,0,nil,Unknown) then exit;
while Form1.SaveDialog1.Execute do
 begin
  FN := Form1.SaveDialog1.FileName;
  if LowerCase(ExtractFileExt(FN)) <> Exten then FN := FN + Exten;
  if FileExists(FN) then
   if MessageDlg('File ''' + FN + ''' exists. Overwrite?',
           mtConfirmation,[mbYes,mbNo],0) =  mrNo then continue;
  AssignFile(FileOut,FN);
  Rewrite(FileOut,1);
  i := PlaylistItems[LastSelected].Length;
  if PlaylistItems[LastSelected].FileType = ASC0File then inc(i);
  if PlaylistItems[LastSelected].FileType in [ASCFile,ASC0File] then
   InsertTitleASC(Buffer,i,PlaylistItems[LastSelected]^.Comment)
  else if PlaylistItems[LastSelected].FileType = STPFile then
   InsertTitleSTP(Buffer,i,PlaylistItems[LastSelected]^.Comment);
  BlockWrite(FileOut,Buffer,i);
  CloseFile(FileOut);
  break
 end;
end;

procedure TForm3.DropFiles(var Msg: TWmDropFiles);
var
 nFiles,i,n,er:integer;
 Filename:string;
 Pt:TPoint;
 r1,r2:boolean;
begin
r1 := RecurseDirs; r2 := RecurseOnlyKnownTypes;
RecurseDirs := True; RecurseOnlyKnownTypes := True;
 try
  n := -1;
  if DragQueryPoint(Msg.Drop,Pt) and (Pt.y >= PLArea.BevelWidth) and
            (Pt.y < PLArea.ClientHeight + PLArea.BevelWidth) then
   begin
    n := (Pt.y - PLArea.BevelWidth) div ListLineHeight + ShownFrom;
    if (n < 0) or (n >= Length(PlaylistItems)) then n := -1
   end;
  nFiles := DragQueryFile(Msg.Drop,$FFFFFFFF,nil,0);
  SetLength(Filename,MAX_PATH);
  for i := 0 to nFiles - 1 do
   begin
    DragQueryFile(Msg.Drop,i,PChar(Filename),MAX_PATH);
    er := GetFileAttributes(PChar(Filename));
    if (er = -1) or (er and FILE_ATTRIBUTE_DIRECTORY = 0) then
     begin
      if n = -1 then
       Add_File(PChar(Filename),True)
      else
       Add_FileAtPos(PChar(Filename),True,n)
     end
    else
     Form3.SearchFilesInFolder(PChar(Filename),n)
   end
 finally
  RecurseDirs := r1; RecurseOnlyKnownTypes := r2;
  DragFinish(Msg.Drop);
  CalculateTotalTime(False);
  CreatePlayOrder
 end
end;

procedure TForm3.SearchFilesInFolder;
var
 SearchRec: TSearchRec;
 i:integer;
begin
Dir := IncludeTrailingBackslash(Dir);
i := FindFirst(Dir + '*.*',faAnyFile,SearchRec);
while i <> ERROR_NO_MORE_FILES do
 begin
  if i = 0 then
   if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    if SearchRec.Attr and faDirectory <> 0 then
     begin
      if RecurseDirs then
       SearchFilesInFolder(Dir + SearchRec.Name,nps)
     end
    else if SearchRec.Size > 0 then
     if nps = -1 then
      Add_File(Dir + SearchRec.Name,RecurseOnlyKnownTypes)
     else
      Add_FileAtPos(Dir + SearchRec.Name,RecurseOnlyKnownTypes,nps);
  i := FindNext(SearchRec)
 end;
FindClose(SearchRec)
end;

procedure TForm3.Add_Directory_Dialog(Add:boolean);
begin
 with TChngDir.Create(Self) do
  try
    CheckBox1.Visible := True;
    CheckBox1.Checked := RecurseDirs;
    CheckBox2.Visible := True;
    CheckBox2.Checked := RecurseOnlyKnownTypes;
    if Russian_Interface then
     begin
      CheckBox1.Caption := 'Просмотреть вложенные папки';
      CheckBox2.Caption := 'Поиск модулей в файлах';
      Caption := 'Открыть файлы из папки';
      Button2.Caption := 'Отмена'
     end
    else
     begin
      CheckBox1.Caption := 'Recurse all subfolders';
      CheckBox2.Caption := 'Search for tunes in files';
      Caption := 'Open files from folder';
      Button2.Caption := 'Cancel'
     end;
    if DirectoryExists(Form1.DefaultDirectory) then
     DirectoryListBox1.Directory := Form1.DefaultDirectory;
    DirName.Text := DirectoryListBox1.Directory;
    ShowModal;
    if ModalResult = mrOk then
     begin
      Screen.Cursor := crHourGlass;
      Form1.OpenDialog1.InitialDir := DirName.Text;
      if AutoSaveDefDir then
       Form1.DefaultDirectory := DirName.Text;
      RecurseDirs := CheckBox1.Checked;
      RecurseOnlyKnownTypes := CheckBox2.Checked;
      try
       if not Add then
        begin
         StopAndFreeAll;
         ClearPlayList
        end;
       SearchFilesInFolder(DirName.Text,-1);
       CalculateTotalTime(False)
      finally
       CreatePlayOrder;
       RedrawPlaylist(0,0,True);
       Screen.Cursor := crDefault
      end;
      if not Add then PlayItem(0,0)
     end
  finally
    Free
  end
end;

function TimeSToStr;
begin
SetLength(Result,4);
Result[4] := char(ms mod 10 + 48);
ms := ms div 10;
Result[3] := char(ms mod 6 + 48);
ms := ms div 6;
Result[2] := ':';
Result[1] := char(ms mod 10 + 48);
ms := ms div 10;
if ms = 0 then exit;
Result := char(ms mod 6 + 48) + Result;
ms := ms div 6;
if ms = 0 then exit;
Result := IntToStr(ms) + ':' + Result
end;

function GetPlayListTime(PLItem:PPLayListItem):integer;
var
 i:integer;
begin
with PLItem^ do
 begin
  if FileType in [OUTFile,ZXAYFile,EPSGFile,BASSFileMin..BASSFileMax] then
   Result := round(Time / 1000)
  else if FileType in [AYFile,AYMFile] then
   Result := round(Time / FrqZ80 * MaxTStates)
  else if FileType = CDAFile then
   Result := round(Time / 75)
  else
   begin
    if (not Form2.CheckBox9.Checked) or
       ((Int_Freq < 0) and (PLDef_Player_Frq < 0)) then
     i := Form2.FrqPlTemp
    else if Int_Freq >= 0 then
     i := Int_Freq
    else
     i := PLDef_Player_Frq;
    Result := round(Time / i * 1000)
   end
 end
end;

function GetPlayListTimeStr(PLItem:PPLayListItem):string;
begin
if PLItem.Time > 0 then
 Result := TimeSToStr(GetPlayListTime(PLItem))
else
 Result := ''
end;

function GetPlayListString(PLItem:PPLayListItem):string;
begin
with PLItem^ do
 if Error = FileNoError then
  begin
   if (Author <> '') and (Title <> '') then
    Result := Author + ' - ' + Title
   else if Author <> '' then
    Result := Author
   else if Title <> '' then
    Result := Title
   else
    Result := RemoveStdExt(FileType,False,ExtractFileName(FileName))
  end
 else
   Result := ExtractFileName(FileName) + ' (' + Errors[Error] + ')'
end;

procedure RedrawItemRealy(DC:HDC;i,n:integer);
var
 s,t:string;
 sz:tagSIZE;
 Client:TRect;
 BkColor,TxtColor:HBRUSH;
 tw,nch:integer;
begin
with PlayListItems[n]^ do
 begin
  if Selected then
   begin
    BkColor := PLColorBkSel;
    if Error = FileNoError then
     begin
      if PlayingItem = n then
       TxtColor := PLColorPlSel
      else
       TxtColor := PLColorSel
     end
    else
     TxtColor := PLColorErrSel
   end
  else
   begin
    if PlayingItem = n then
     BkColor := PLColorBkPl
    else
     BkColor := PLColorBk;
    if Error = FileNoError then
     begin
      if PlayingItem = n then
       TxtColor := PLColorPl
      else
       TxtColor := PLColor
     end
    else
     TxtColor := PLColorErr
   end;
  SetTextColor(DC,TxtColor);
  SetBkColor(DC,BkColor);
  s := GetPlayListString(PlayListItems[n]);
  if Error = FileNoError then
   begin
    t := GetPlayListTimeStr(PlayListItems[n]);
    if t = '' then
     begin
      PostMessage(Form3.Handle,WM_GETTIMELENGTH,0,n);
      t := STypes[FileType]
     end
    else
     t := STypes[FileType] + ' ' + t;
    GetTextExtentPoint32(DC,PChar(t),System.Length(t),Sz);
    tw := Sz.cx
   end
  else
   tw := 0;
  GetTextExtentExPoint(DC,PChar(s),System.Length(s),PLArea.ClientWidth - tw - 4,@nch,nil,Sz);
  if nch < System.Length(s) then
   begin
    s[nch] := '.';
    s[nch - 1] := '.';
    s[nch - 2] := '.'
   end;
  Client.Left := 0;
  Client.Top := i * ListLineHeight;
  Client.Right := PLArea.ClientWidth - tw;
  Client.Bottom := (i + 1)*ListLineHeight;
  ExtTextOut(DC,0,i*ListLineHeight,ETO_OPAQUE or ETO_CLIPPED,@Client,PChar(s),nch,nil);
  if Error = FileNoError then
   begin
    Client.Left := Client.Right;
    Client.Right := PLArea.ClientWidth;
    ExtTextOut(DC,Client.Left,i*ListLineHeight,ETO_OPAQUE or ETO_CLIPPED,@Client,PChar(t),System.Length(t),nil);
   end
 end
end;

procedure RedrawItem(DC:HDC;n:integer);
var
 DC1:HDC;
 p:THandle;
begin
if DisablePLRedraw then exit;
if (n < ShownFrom) or
   (n >= ShownFrom + PLArea.ClientHeight div ListLineHeight) then exit;
if not Form3.Visible then exit;
if DC = 0 then
 DC1 := GetDC(PLArea.Handle)
else
 DC1 := DC;
p := SelectObject(DC1,PLArea.Font.Handle);
RedrawItemRealy(DC1,n - ShownFrom,n);
SelectObject(DC1,p);
if DC = 0 then
 ReleaseDC(PLArea.Handle,DC1);
end;

procedure RedrawPlaylist;
var
 i,n,na,nmax:integer;
 DC1:HDC;
 Client:TRect;
 p:THandle;
begin
ShownFrom := From;
if DisablePLRedraw then exit;
if not Form3.Visible then exit;
if DC = 0 then
 DC1 := GetDC(PLArea.Handle)
else
 DC1 := DC;
na := Length(PlayListItems);
if na <> 0 then
 begin
  p := SelectObject(DC1,PLArea.Font.Handle);
  nmax := PLArea.ClientHeight div ListLineHeight;
  n := na - From;
  if n > nmax then
   n := nmax
  else if n < nmax then
   begin
    dec(From,nmax - n);
    n := nmax;
    if From < 0 then
     begin
      inc(n,From);
      From := 0
     end;
    ShownFrom := From
   end;
  for i := 0 to n - 1 do
   RedrawItemRealy(DC1,i,i + From);
  if not OnlyItems then
   begin
    Client.Left := 0;
    Client.Top := n * ListLineHeight;
    Client.Right := PLArea.ClientWidth;
    Client.Bottom := PLArea.ClientHeight;
    i := CreateSolidBrush(PLColorBk);
    FillRect(DC1,Client,i);
    DeleteObject(i)
   end;
  SelectObject(DC1,p)
 end
else if not OnlyItems then
 begin
  Client.Left := 0;
  Client.Top := 0;
  Client.Right := PLArea.ClientWidth;
  Client.Bottom := PLArea.ClientHeight;
  i := CreateSolidBrush(PLColorBk);
  FillRect(DC1,Client,i);
  DeleteObject(i)
 end;
if DC = 0 then
 ReleaseDC(PLArea.Handle,DC1);
CalculatePlaylistScrollBar
end;

function AddPlayListItem;
begin
New(PLItem);
Result := Length(PlayListItems);
SetLength(PlayListItems,Result + 1);
PlayListItems[Result] := PLItem;
Form3.RedrawItemsLabel
end;

constructor TPlayList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  ControlStyle := [csClickEvents, csDoubleClicks, csCaptureMouse];
  TabStop := True;
  ParentColor := False;
  BevelKind := bkTile;
  BevelInner := bvLowered;
  Align := alClient;
  ShownFrom := 0;
  Color := clNone;
  PopupMenu := Form3.PopupMenu1;
  OnMouseDown := PLAreaMouseDown;
  OnMouseUp := PLAreaMouseUp;
  OnMouseMove := PLAreaMouseMove;
  OnMouseWheelDown := PLAreaMouseWheelDown;
  OnMouseWheelUp := PLAreaMouseWheelUp;
  OnDblClick := PLAreaDblClick;
  OnKeyDown := PLAreaKeyDown;
  OnKeyUp := PLAreaKeyUp
end;

procedure TPlayList.DefaultHandler(var Message);
var
 ps:tagPAINTSTRUCT;
 hDC1:HDC;
begin
  case TMessage(Message).Msg of
    WM_GETDLGCODE:
     begin
      TMessage(Message).Result := -1;// xor integer(DLGC_WANTTAB);
      exit
     end;
    WM_PAINT:
      begin
       hDC1 := BeginPaint(Handle,ps);
       RedrawPlaylist(ShownFrom,hDC1,False);
       EndPaint(Handle,ps);
       TWMPaint(Message).Result := -1
      end
  end;
  inherited;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
 DC:HDC;
 p:THandle;
 sz:tagSIZE;
begin

//default playlist colors
PLColorBkSel := GetSysColor(COLOR_HIGHLIGHT);
PLColorBkPl := GetSysColor(COLOR_WINDOW) - $100D10;
if integer(PLColorBkPl) < 0 then PLColorBkPl := 0;
PLColorBk := GetSysColor(COLOR_WINDOW);

PLColorPlSel := $FF80FF;
PLColorPl := $0DA00D;

PLColorSel := GetSysColor(COLOR_HIGHLIGHTTEXT);
PLColor := GetSysColor(COLOR_WINDOWTEXT);

PLColorErrSel := $FFFF00;
PLColorErr := $FF;

ClearParams;
Form3.SetDirection(1);
PLArea := TPlayList.Create(Form3);
DC :=  GetDC(PLArea.Handle);
p := SelectObject(DC,PLArea.Font.Handle);
GetTextExtentPoint32(DC,'0',1,Sz);
SelectObject(DC,p);
ReleaseDC(PLArea.Handle,DC);
ListLineHeight := Sz.cy;
PLScrBar := TPLScrBar.Create(Form3)
end;

procedure ClearSelection;
var
 i:integer;
begin
 LastSelected := -1;
 for i := 0 to Length(PlayListItems) - 1 do
  with PlayListItems[i]^ do
   if Selected then
    begin
     Selected := False;
     RedrawItem(0,i)
    end
end;

procedure TPlayList.PLAreaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
 i,n,sfr,sto:integer;
begin
i := PLArea.ClientHeight div ListLineHeight;
n := Y div ListLineHeight;
if Button = mbLeft then
 begin
  IsClicked := True;       
  if (Y >= 0) and (n < i) then
   begin
    Inc(n,ShownFrom);
    if n < Length(PlayListItems) then
     begin
      if not (ssCtrl in Shift) then
       for i := 0 to Length(PlayListItems) - 1 do
        with PlayListItems[i]^ do
         if Selected and (i <> n) then
          begin
           Selected := False;
           RedrawItem(0,i)
          end;
      if not (ssShift in Shift) or (LastSelected = -1) then
       begin
        LastSelected := n;
        if not PlayListItems[n].Selected then
         begin
          PlayListItems[n].Selected := True;
          RedrawItem(0,n)
         end
        else if ssCtrl in Shift then
         begin
          PlayListItems[n].Selected := False;
          RedrawItem(0,n)
         end
       end
      else
       begin
        if LastSelected > n then
         begin
          sfr := n;
          sto := LastSelected
         end
        else
         begin
          sfr := LastSelected;
          sto := n
         end;
        for i := sfr to sto do
         with PlayListItems[i]^ do
          if not Selected then
           begin
            Selected := True;
            RedrawItem(0,i)
           end
       end
     end
    else
     ClearSelection
   end
  else
   ClearSelection
 end
else if Button = mbRight then
 if (Y >= 0) and (n < i) then
  begin
   Inc(n,ShownFrom);
   if n < Length(PlayListItems) then
    begin
     if not PlayListItems[n].Selected then
      begin
       ClearSelection;
       PlayListItems[n].Selected := True;
       RedrawItem(0,n)
      end;
     LastSelected := n
    end
  end
end;

procedure Do_LineDown;
begin
if ShownFrom < Length(PlayListItems) - 1 then
 RedrawPlaylist(ShownFrom + 1,0,True)
end;

procedure Do_LineUp;
begin
if ShownFrom > 0 then
 RedrawPlaylist(ShownFrom - 1,0,True)
end;

procedure TPlayList.PLAreaMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
Handled := True;
Do_LineDown
end;

procedure TPlayList.PLAreaMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
Handled := True;
Do_LineUp
end;

procedure TPlayList.PLAreaDblClick(Sender: TObject);
begin
if (GetKeyState(VK_SHIFT) and 128 <> 0) or
   (GetKeyState(VK_CONTROL) and 128 <> 0) then exit;
if LastSelected < 0 then exit;
PlayItem(PlayListItems[LastSelected].Tag,0);
if Direction = 2 then CreatePlayOrder
end;

procedure TForm3.SpeedButton1Click(Sender: TObject);
begin
if GetKeyState(VK_SHIFT) and 128 <> 0 then
 Add_Directory_Dialog(True)
else if GetKeyState(VK_CONTROL) and 128 <> 0 then
 Add_CD_Dialog(True)
else
 Add_Item_Dialog(True)
end;

procedure TForm3.SpeedButton2Click(Sender: TObject);
begin
ClearPlayList
end;

procedure TForm3.SpeedButton3Click(Sender: TObject);
var
 i:integer;
 m3uf:TextFile;
 FName:string;
begin
Form1.SaveDialog1.InitialDir := Form1.OpenDialog1.InitialDir;
Form1.SaveDialog1.FileName := '';
Form1.SaveDialog1.DefaultExt := '';
if Russian_Interface then
 Form1.SaveDialog1.Filter := T_AyEmulPL + '|' + T_WinampPL
else
 Form1.SaveDialog1.Filter := E_AyEmulPL + '|' + E_WinampPL;
Form1.SaveDialog1.FilterIndex := 1;
if Form1.SaveDialog1.Execute then
 begin
  FName := AnsiLowerCase(ExtractFileExt(Form1.SaveDialog1.FileName));
  if Form1.SaveDialog1.FilterIndex = 2 then
   begin
    if FName <> '.m3u' then
     FName := Form1.SaveDialog1.FileName + '.m3u'
    else
     FName := Form1.SaveDialog1.FileName;
    AssignFile(m3uf,FName);
    Rewrite(m3uf);
    for i := 0 to Length(PlaylistItems) - 1 do
     Writeln(m3uf,PlaylistItems[i].FileName);
    CloseFile(m3uf)
   end
  else
   begin
    if FName <> '.ayl' then
     FName := Form1.SaveDialog1.FileName + '.ayl'
    else
     FName := Form1.SaveDialog1.FileName;
    SaveAYL(FName)
   end
 end;
end;

procedure TryGetTime(n:integer);
var
 FileHandleTime:integer;
begin
with PlayListItems[n]^ do
 if (Time = 0) and (Error = FileNoError) then
  begin
   if not (FileType in [BASSFileMin..BASSFileMax,CDAFile]) then
    UniReadInit(FileHandleTime,URFile,FileName,nil);
   try
    GetTime(FileHandleTime,n,False,Loop)
   except
    on EBASSError do Error := ErBASSError;
    on EFileStructureError do Error := ErBadFileStructure
    else Error := ErReadingFile
   end;
   if not (FileType in [BASSFileMin..BASSFileMax,CDAFile]) then
    UniReadClose(FileHandleTime);
   if (Error <> FileNoError) or (Time <> 0) then
    begin
     RedrawItem(0,n);
     if (n - Item_Displayed + 1) in [0..2] then ReprepareScroll
    end
  end
end;

procedure TForm3.WMGETTIMELENGTH;
begin
if DWORD(Msg.lParam) < DWORD(Length(PlayListItems)) then
 TryGetTime(Msg.lParam)
end;

procedure DeletePlayListItem(n:integer);
var
 i,c:integer;
begin
if n < 0 then exit;
c := Length(PlayListItems) - 1;
if n > c then exit;
Dispose(PlayListItems[n]);
for i := n + 1 to c do
 PlayListItems[i - 1] := PlayListItems[i];
SetLength(PlayListItems,c);
Form3.RedrawItemsLabel
end;

procedure TPlayList.PLAreaKeyDown(Sender: TObject; var Key: Word;
  Shift:   TShiftState);
var
 LS,Index,{Mode,}n:integer;

 procedure CheckVis;
 begin
  LastSelected := Index;
  PlayListItems[Index].Selected := True;
  MakeVisible(Index,False)
 end;

 procedure Do_Home;
 var
  i:integer;
 begin
  if Length(PlayListItems) <> 0 then
   begin
    if not (ssShift in Shift) or (LastSelected = -1) then
     begin
      ClearSelection;
      PlayListItems[0].Selected := True
     end
    else
     for i := 0 to LastSelected do
      PlayListItems[i].Selected := True;
    LastSelected := 0;
    RedrawPlayList(0,0,True)
   end
 end;

 procedure Do_End;
 var
  i:integer;
 begin
  if Length(PlayListItems) <> 0 then
   begin
    if not (ssShift in Shift) or (LastSelected = -1) then
     begin
      ClearSelection;
      PlayListItems[Length(PlayListItems) - 1].Selected := True
     end
    else
     for i := LastSelected to Length(PlayListItems) - 1 do
      PlayListItems[i].Selected := True;
    LastSelected := Length(PlayListItems) - 1;
    RedrawPlayList(LastSelected,0,True)
   end
 end;

begin
case Key of
VK_DELETE:
 if Length(PlayListItems) <> 0 then
  begin
   LS := LastSelected;
   try
   for Index := Length(PlayListItems) - 1 downto 0 do
    if PlayListItems[Index].Selected then
     begin
      if (Scroll_Distination <> Item_Displayed) and
         (Index = Scroll_Distination) then
       ForceScrollForDelete;
      if Index < PlayingItem then
       begin
        Dec(PlayingItem);
        Form3.RedrawItemsLabel
       end
      else if Index = PlayingItem then
       begin
        PlayingItem := -1;
        Form3.RedrawItemsLabel
       end;
      if Index < Scroll_Distination then
       Dec(Scroll_Distination)
      else if Index = Scroll_Distination then
       Scroll_Distination := -1;
      if Index < Item_Displayed then
       Dec(Item_Displayed)
      else if Index = Item_Displayed then
       Item_Displayed := -1;
      DeletePlayListItem(Index);
      ReprepareScroll
     end;
   if LS >= Length(PlayListItems) then LS := Length(PlayListItems) - 1;
   LastSelected := LS;
   if LS >= 0 then PlayListItems[LS].Selected := True;
   finally
    RedrawPlaylist(ShownFrom,0,False);
    CreatePlayOrder;
    CalculateTotalTime(False)
   end 
  end;
VK_DOWN:
 if Length(PlayListItems) <> 0 then
  begin
   Index := LastSelected + 1;
   LastSelected := -1;
   if not (ssShift in Shift) then ClearSelection;
   if Index < Length(PlayListItems) then CheckVis
  end;
VK_UP:
 if Length(PlayListItems) <> 0 then
  begin
   Index := LastSelected - 1;
   LastSelected := -1;
   if not (ssShift in Shift) then ClearSelection;
   if Index = -2 then Index := Length(PlayListItems) - 1;
   if Index >= 0 then CheckVis
  end;
VK_HOME:
 Do_Home;
VK_END:
 Do_End;
VK_PRIOR:
 if ssCtrl in Shift then
  Do_Home
 else if Length(PlayListItems) <> 0 then
  begin
   if (LastSelected = ShownFrom) and (ShownFrom <> 0) then
    begin
     Dec(ShownFrom,PLArea.ClientHeight div ListLineHeight);
     if ShownFrom < 0 then ShownFrom := 0
    end;
   if not (ssShift in Shift) then
    begin
     ClearSelection;
     PlayListItems[ShownFrom].Selected := True
    end
   else
    for Index := 0 to LastSelected do
     PlayListItems[Index].Selected := True;
   LastSelected := ShownFrom;
   RedrawPlaylist(ShownFrom,0,True)
  end;
VK_NEXT:
 if ssCtrl in Shift then
  Do_End
 else if Length(PlayListItems) <> 0 then
  begin
   n := PLArea.ClientHeight div ListLineHeight;
   if (LastSelected = ShownFrom + n - 1) and
      (ShownFrom <> Length(PlayListItems) - 1) then
    begin
     Inc(ShownFrom,n);
     if ShownFrom >= Length(PlayListItems) then
      ShownFrom := Length(PlayListItems) - 1
    end;
   LS := ShownFrom + n - 1;
   if LS >= Length(PlayListItems) then
    LS := Length(PlayListItems) - 1;
   if not (ssShift in Shift) then
    begin
     ClearSelection;
     PlayListItems[LS].Selected := True
    end
   else
    for Index := LastSelected to LS do
     PlayListItems[Index].Selected := True;
   LastSelected := LS;
   RedrawPlaylist(ShownFrom,0,True)
  end;
VK_INSERT:
 Form3.SpeedButton1Click(Sender);
VK_RETURN:
 PLAreaDblClick(Sender);
Ord('A'):
 if (Length(PlayListItems) <> 0) and (ssCtrl in Shift) then
  begin
   for Index := 0 to Length(PlayListItems) - 1 do
    PlayListItems[Index].Selected := True;
   RedrawPlaylist(ShownFrom,0,True)
  end;
VK_ESCAPE:
 Form3.Visible := False;
VK_F7:
 Form3.Finditem1Click(Sender)
else
 Form1.OnKeyDown(Sender,Key,Shift)
end
end;

procedure TPlayList.PLAreaKeyUp(Sender: TObject; var Key: Word;
  Shift:   TShiftState);
begin
Form1.OnKeyUp(Sender,Key,Shift)
end;

function CalculateTotalTime;
var
 i,t,l:integer;
 s:string;
begin
Result := False;
if not Form3.Label1.Enabled then exit;
if Force then Form3.Label1.Enabled := False;
t := 0;
Result := True;
try
l := Length(PlaylistItems);
for i := 0 to l - 1 do
 with PlayListItems[i]^ do
  begin
   if Force then TryGetTime(i);
   if Time > 0 then
    Inc(t,GetPlayListTime(PlaylistItems[i]))
   else if Error = FileNoError then
    Result := False;
   if Force then
    begin
     Application.ProcessMessages;
     if Application.Terminated then exit;
     if l <> System.Length(PlaylistItems) then
      begin
       Result := False;
       break
      end
    end
  end;
s := TimeSToStr(t);
if not Result then s := s + '+';
Form3.Label1.Caption := s;
finally
if Force then Form3.Label1.Enabled := True;
end
end;

procedure TForm3.Label1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Screen.Cursor := crAppStart;
try
 CalculateTotalTime(True)
finally
 Screen.Cursor := crDefault
end
end;

procedure TPlaylist.WndProc;
begin
if Message.Msg = WM_ERASEBKGND then
 begin
  Message.Result := 1;
  exit
 end;
inherited
end;

procedure CalculatePlaylistScrollBar;
var
 l,p:integer;
 si:tagSCROLLINFO;
begin
l := Length(PlayListItems);
si.cbSize := sizeof(si);
si.fMask := SIF_ALL;
si.nMin := 0;
if l = 0 then
 begin
  si.nMax := 0;
  si.nPage := 1;
  si.nPos := 0;
 end
else
 begin
  p := PLArea.ClientHeight div ListLineHeight;
  if l < p then l := p;
  //if (Max = l - 1) and (Position = ShownFrom) and (PageSize = p) then exit;
  si.nMax := l - 1;
  si.nPage := p;
  si.nPos := ShownFrom;
 end;
SetScrollInfo(PLScrBar.Handle,SB_CTL,si,True);
end;

procedure TForm3.PopupMenu1Popup(Sender: TObject);
begin
  with Form3.PopupMenu1 do
   begin
    Items[0].Enabled := False;
    Items[2].Enabled := False;
    Items[3].Enabled := False;
    Items[4].Enabled := False;
    Items[5].Enabled := False;
    Items[6].Enabled := False;
    Items[7].Enabled := False
   end;
  if LastSelected <> - 1 then
    with Form3.PopupMenu1 do
     begin
      Items[0].Enabled := True;
      if not (PlayListItems[LastSelected].FileType in [BASSFileMin..BASSFileMax,CDAFile]) then
       begin
        Items[2].Enabled := True;
        Items[4].Enabled := True;
        Items[5].Enabled := True;
        Items[6].Enabled := True;
        case PlayListItems[LastSelected].FileType of
        VTXFile:
         Items[4].Enabled := False;
        YM5File,
        YM6File:
         Items[5].Enabled := False;
        PSGFile:
         Items[6].Enabled := False;
        OUTFile,EPSGFile:
         Items[3].Enabled := True;
        STCFile..GTRFile:
         Items[7].Enabled := True;
        AYFile,AYMFile:
         Items[3].Enabled := True
        end
       end
     end
end;

procedure TForm3.SetDirection;
var
 Bmp:TBitmap;
begin
if Direction = Dir then exit;
Direction := Dir;
Bmp := TBitmap.Create;
ImageList1.GetBitmap(Dir,Bmp);
DirectionButton.Glyph := Bmp;
Bmp.Free
end;

procedure TForm3.LoopListButtonClick(Sender: TObject);
begin
ListLooped := LoopListButton.Down
end;

procedure TForm3.DirectionButtonClick(Sender: TObject);
var
 Dir:integer;
begin
Dir := (Direction + 1) and 3;
SetDirection(Dir);
CreatePlayOrder
end;

procedure TForm3.FormActivate(Sender: TObject);
begin
IsClicked := False
end;

procedure TForm3.FormShow(Sender: TObject);
begin
DragAcceptFiles(Handle, True)
end;

procedure TForm3.RandomSortClick(Sender: TObject);
var
 i,i1,i2:integer;
 PLI:pointer;
begin
if Length(PlaylistItems) < 2 then exit;
try
for i := 0 to Length(PlaylistItems) - 1 do
 PlaylistItems[i].Tag := 0;
i := Length(PlaylistItems) div 2;
while i > 0 do
 begin
  repeat
   i1 := Random(Length(PlaylistItems));
  until PlaylistItems[i1].Tag = 0;
  PlaylistItems[i1].Tag := 1;
  repeat
   i2 := Random(Length(PlaylistItems));
  until PlaylistItems[i2].Tag = 0;
  PlaylistItems[i2].Tag := 1;
  if PlayingItem = i1 then
   PlayingItem := i2
  else if PlayingItem = i2 then
   PlayingItem := i1;
  if Item_Displayed = i1 then
   Item_Displayed := i2
  else if Item_Displayed = i2 then
   Item_Displayed := i1;
  if Scroll_Distination = i1 then
   Scroll_Distination := i2
  else if Scroll_Distination = i2 then
   Scroll_Distination := i1;
  PLI := PlaylistItems[i1];
  PlaylistItems[i1] := PlaylistItems[i2];
  PlaylistItems[i2] := PLI;
  Dec(i)
 end;
ReprepareScroll;
finally
 CreatePlayOrder;
 RedrawItemsLabel;
 RedrawPlaylist(0,0,True)
end
end;

procedure TForm3.SpeedButton4Click(Sender: TObject);
var
 Pt:TPoint;
begin
Pt.x := SpeedButton4.Width; Pt.y := 0;
Pt := SpeedButton4.ClientToScreen(Pt);
PopupMenu2.Popup(Pt.x,Pt.y)
end;

function AllErrored;
var
 i:integer;
begin
Result := False;
for i := 0 to Length(PlaylistItems) - 1 do
 if PlayListItems[i].Error = FileNoError then exit;
Result := True
end;

procedure MyQuickSort(Compare:TMyCompare);

 procedure QuickSort(L,R:Integer);
 var
   I, J, P: Integer;
   N:pointer;
 begin
   repeat
     I := L;
     J := R;
     P := (L + R) shr 1;
     repeat
       while Compare(I, P) < 0 do Inc(I);
       while Compare(J, P) > 0 do Dec(J);
       if I <= J then
       begin
         N := PlaylistItems[J];
         PlaylistItems[J] := PlaylistItems[I];
         PlaylistItems[I] := N;
         if P = I then
           P := J
         else if P = J then
           P := I;
         Inc(I);
         Dec(J);
       end;
     until I > J;
     if L < J then QuickSort(L, J);
     L := I;
   until I >= R;
 end;

var
 temp,i:integer;
 PI,ID,SD:pointer;
begin
temp := Length(PlaylistItems) - 1;
if temp > 0 then
 begin
  PI := PlaylistItems[PlayingItem];
  ID := PlaylistItems[Item_Displayed];
  SD := PlaylistItems[Scroll_Distination];
  try
   QuickSort(0,temp);
   for i := 0 to temp do
    if PlaylistItems[i] = PI then
     begin
      PlayingItem := i;
      break
     end;
   for i := 0 to temp do
    if PlaylistItems[i] = ID then
     begin
      Item_Displayed := i;
      break
     end;
   for i := 0 to temp do
    if PlaylistItems[i] = SD then
     begin
      Scroll_Distination := i;
      break
     end;
   ReprepareScroll
  finally
   CreatePlayOrder;
   Form3.RedrawItemsLabel;
   RedrawPlaylist(0,0,True)
  end
 end
end;

function CompareFileNames(Index1, Index2: Integer): Integer;
begin
Result := AnsiCompareText(PlaylistItems[Index1].FileName,PlaylistItems[Index2].FileName)
end;

function CompareTitles(Index1, Index2: Integer): Integer;
begin
Result := AnsiCompareText(PlaylistItems[Index1].Title,PlaylistItems[Index2].Title);
if Result = 0 then Result := CompareFileNames(Index1,Index2)
end;

function CompareAuthors(Index1, Index2: Integer): Integer;
begin
Result := AnsiCompareText(PlaylistItems[Index1].Author,PlaylistItems[Index2].Author);
if Result = 0 then Result := CompareTitles(Index1,Index2)
end;

function CompareTypes(Index1, Index2: Integer): Integer;
var
 FT1,FT2:Available_Types;
begin
FT1 := PlaylistItems[Index1].FileType; FT2 := PlaylistItems[Index2].FileType;
Result := 0;
if FT1 <> FT2 then
 begin
  if FT1 = Unknown then
   Result := -1
  else if FT2 = Unknown then
   Result := 1
  else
   Result := CompareText(STypes[FT1],STypes[FT2])
 end;
if Result = 0 then Result := CompareAuthors(Index1,Index2)
end;

procedure TForm3.ByauthorSortClick(Sender: TObject);
begin
MyQuickSort(CompareAuthors)
end;

procedure TForm3.BytitleSortClick(Sender: TObject);
begin
MyQuickSort(CompareTitles)
end;

procedure TForm3.ByfilenameSortClick(Sender: TObject);
begin
MyQuickSort(CompareFileNames)
end;

procedure TForm3.Byfiletype1Click(Sender: TObject);
begin
MyQuickSort(CompareTypes)
end;

constructor TPLScrBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  ControlStyle := [csFramed, csDoubleClicks, csOpaque];
  TabStop := False;
  Width := GetSystemMetrics(SM_CXVSCROLL);
  Align := alRight
end;

procedure TPLScrBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  CreateSubClass(Params, 'SCROLLBAR');
  Params.Style := Params.Style or SBS_VERT
end;

procedure TForm3.WndProc(var Message: TMessage);
var
 si:tagSCROLLINFO;

  procedure GetSI;
  begin
   si.cbSize := sizeof(si);
   si.fMask := SIF_ALL;
   GetScrollInfo(PLScrBar.Handle,SB_CTL,si)
  end;

  procedure SetSI;
  var
   l,p:integer;
  begin
   l := Length(PlayListItems);
   p := PLArea.ClientHeight div ListLineHeight;
   if si.nPos > l - p then
    si.nPos := l - p;
   if si.nPos < 0 then
    si.nPos := 0;
   if si.nPos <> ShownFrom then
    RedrawPlaylist(si.nPos,0,True)
  end;

begin
case Message.Msg of
WM_VSCROLL:
 begin
  case LOWORD(Message.wParam) of
  SB_LINEDOWN:
   begin
    GetSI;
    inc(si.nPos);
    SetSI
   end;
  SB_LINEUP:
   begin
    GetSI;
    dec(si.nPos);
    SetSI
   end;
  SB_PAGEDOWN:
   begin
    GetSI;
    inc(si.nPos,si.nPage);
    SetSI
   end;
  SB_PAGEUP:
   begin
    GetSI;
    dec(si.nPos,si.nPage);
    SetSI
   end;
  SB_THUMBTRACK:
   begin
    GetSI;
    si.nPos := si.nTrackPos;
    SetSI
   end;
  end;
  Message.Result := 0;
  exit
 end;
end;
inherited
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
StopTimer;
ClearPlayListItems;
PLArea.Free
end;

procedure TForm3.Finditem1Click(Sender: TObject);
begin
with TForm9.Create(Self) do
 try
  ShowModal
 finally
  Free
 end 
end;

procedure TForm3.RedrawItemsLabel;
begin
Label2.Caption := IntToStr(PlayingItem + 1) + '/' + IntToStr(Length(PlayListItems))
end;

end.
