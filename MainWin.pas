{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit MainWin;

interface

uses
  Windows, Messages, Types, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, MMSystem, About, LH5, FileCtrl, ShellApi, UniReader, WaveOutAPI, AY,
  StdCtrls;

const

{$R bmp.res}   //Resource of compressed bitmaps

//Version related constants
 VersionString = '2.8';
 {$define beta}
 IsBeta = ' beta';
 BetaNumber = ' 12';
 VersionMajor = 2;
 VersionMinor = 8;
 CompilYs = '2005';
 CompilY = 2005;
 CompilM = 11;
 CompilD = 9;
 CompilS = '9 of November 2005';

//Default mixer parameters
 SampleRateDef  = 44100;
 SampleBitDef   = 16;
 FrqZ80Def      = 3494400;
 AY_FreqDef     = 1773400;
 IntOffsetDef   = 0;
 BeeperMaxDef   = 128;
 MaxTStatesDef  = 69888;
 Interrupt_FreqDef = 50000;
 Index_ALDef    = 255;
 Index_ARDef    = 13;
 Index_BLDef    = 170;
 Index_BRDef    = 170;
 Index_CLDef    = 13;
 Index_CRDef    = 255;
 NumOfChanDef   = 2;
 ChanModeDef    = 1;
 MFPTimerModeDef = 0;
 MFPTimerFrqDef = 2457600;

//User defined windows messages
 WM_LINEPARAM      = WM_USER;
 WM_PLAYNEXTITEM   = WM_USER + 1;
 WM_PLAYERROR      = WM_USER + 2;
 WM_TRAYICON       = WM_USER + 3;
 WM_VISUALISATION  = WM_USER + 4;
 WM_FINALIZEWO     = WM_USER + 5;
 WM_HIDEMINIMIZE   = WM_USER + 6;
 WM_GETTIMELENGTH  = WM_USER + 8;

//Metrics of some controls
//Main window
 MWWidth = 358;
 MWHeight = 123;

 //Spectrum analizer
 spa_num = 91 - 26 - 2;
 spa_width = spa_num + 2; spa_height = 20;
 spa_x = 26; spa_y = 34;

 //Amplitude analizer
 amp_width = 17; amp_height = 15;
 amp_x = 50; amp_y = 18;

 max_width2 = spa_width; max_height2 = spa_height;

 //Scrolling title
 scr_lineheight = 24;
 scr_x = 108;scr_y = 48;
 scr_width = 197; scr_height = scr_lineheight;

 //Time label
 time_x = 24; time_y = 65;
 time_width = 93-24;time_height = 20;

 max_height = scr_height;

 //Offsets of background bitmaps for controls
 spa_src = 0;
 amp_src = spa_width;
 time_src = spa_width + amp_width;
 scr_src = spa_width + amp_width + time_width;
 max_src = scr_src + scr_width;

//Skin 2.0 identificator
SkinId:string = 'Ay_Emul 2.0 Skin File'#13#10#26;
SkinIdLen = 24;

//Register paths
MyRegPath1:string = 'SOFTWARE\Sergey Vladimirovich Bulba';
MyRegPath2:string = 'ZX Spectrum Sound Chip Emulator';
MyRegPath3:string = VersionString + IsBeta;
{NumOfOldPaths = 14;
MyRegPath3Old:array[1..NumOfOldPaths] of string = ('1.5 beta'#0,'1.5'#0,
                         '2.0 beta'#0,'2.0'#0,'2.2'#0,'2.3'#0,'2.4 beta'#0,
                         '2.4'#0,'2.5 beta','2.5','2.6 beta','2.6','2.7 beta',
                         '2.7');}

//Multilanguage supporting
Lan_Mixer_BoxTitle  :string = 'Микшер';
Lan_Mixer_Optimiz   :string = 'Оптимизация';
Lan_Mixer_ForQ      :string = 'по качеству';
Lan_Mixer_ForP      :string = 'по скорости';
Lan_Mixer_FstInt    :string = 'Смещение прерывания';
Lan_Mixer_ChansAmpl :string = 'Усиление каналов';
Lan_Mixer_FrqAY     :string = 'Частота микросхемы';
Lan_Mixer_ChType    :string = 'Тип микросхемы';
Lan_Mixer_SamRate   :string = 'Частота сэмплов';
Lan_Mixer_BitRate   :string = 'Бит на сэмпл';
Lan_Mixer_FrqPlr    :string = 'Частота прерываний';
Lan_Mixer_Chans     :string = 'Каналы';
Lan_Mixer_Restore   :string = 'Восстановить';
Lan_Mixer_Get       :string = 'Брать из списка';
Lan_Mixer_Another   :string = 'Другая';
Lan_Mixer_FrqZ80    :string = 'Частота Z80';
Lan_Mixer_Close     :string = 'Закрыть';

Lan_Tools_BoxTitle_En  :string = 'Tools';
Lan_Tools_BoxTitle_Ru  :string = 'Инструменты';
Lan_Tools_ConvParam_En :string = 'Other';
Lan_Tools_ConvParam_Ru :string = 'Прочее';
Lan_Tools_Searching_En :string = 'Searching for tunes in files';
Lan_Tools_Searching_Ru :string = 'Поиск модулей в файлах';
Lan_Tools_Prior_En     :string = 'Priority';
Lan_Tools_Prior_Ru     :string = 'Приоритет';
Lan_Tools_StartMenu_En :string = '''Start'' menu';
Lan_Tools_StartMenu_Ru :string = 'Меню "Пуск"';
Lan_Tools_SourceFls_En :string = 'Source files:';
Lan_Tools_SourceFls_Ru :string = 'Исходные файлы:';
Lan_Tools_WorkFold_En  :string = 'Work folder:';
Lan_Tools_WorkFold_Ru  :string = 'Рабочая папка:';
Lan_Tools_Choose_En    :string = 'Choose...';
Lan_Tools_Choose_Ru    :string = 'Обзор...';
Lan_Tools_SearchFor_En :string = 'Search for tunes';
Lan_Tools_SearchFor_Ru :string = 'Искать модули';
Lan_Tools_WorkRep_En   :string = 'Work report:';
Lan_Tools_WorkRep_Ru   :string = 'Протокол работы:';
Lan_Tools_Begin_En     :string = 'Begin';
Lan_Tools_Begin_Ru     :string = 'Начать';
Lan_Tools_Stop_En      :string = 'Stop';
Lan_Tools_Stop_Ru      :string = 'Стоп';
Lan_Tools_Apply_En     :string = 'Apply';
Lan_Tools_Apply_Ru     :string = 'Применить';
Lan_Tools_Save_En      :string = 'Save';
Lan_Tools_Save_Ru      :string = 'Сохранить';
Lan_Tools_FilesReg_En  :string = 'Files registration';
Lan_Tools_FilesReg_Ru  :string = 'Регистрация файлов';
Lan_Tools_RemoveEmu_En :string = 'Uninstall';
Lan_Tools_RemoveEmu_Ru :string = 'Деинсталлировать';
Lan_Tools_Restore_En   :string = 'Restore';
Lan_Tools_Restore_Ru   :string = 'Восстановить';
Lan_Tools_Idle_En      :string = 'idle';
Lan_Tools_Idle_Ru      :string = 'низкий';
Lan_Tools_Normal_En    :string = 'normal';
Lan_Tools_Normal_Ru    :string = 'обычный';
Lan_Tools_High_En      :string = 'high';
Lan_Tools_High_Ru      :string = 'высокий';
Lan_Tools_Remove_En    :string = 'Remove';
Lan_Tools_Remove_Ru    :string = 'Убрать';
Lan_Tools_Add_En       :string = 'Add';
Lan_Tools_Add_Ru       :string = 'Добавить';
Lan_Tools_Tray_En      :string = 'Icon on system tray';
Lan_Tools_Tray_Ru      :string = 'Значок на панели задач';
Lan_Tools_Always_En    :string = 'always';
Lan_Tools_Always_Ru    :string = 'всегда';
Lan_Tools_Never_En     :string = 'never';
Lan_Tools_Never_Ru     :string = 'никогда';
Lan_Tools_Minim_En     :string = 'minimize';
Lan_Tools_Minim_Ru     :string = 'сворачивать';
Lan_Tools_SkAut_En     :string = 'Skin''s author';
Lan_Tools_SkAut_Ru     :string = 'Автор обшивки';
Lan_Tools_SkCom_En     :string = 'Comment';
Lan_Tools_SkCom_Ru     :string = 'Комментарий';
Lan_Tools_SkFN_En      :string = 'File name';
Lan_Tools_SkFN_Ru      :string = 'Имя файла';
Lan_Tools_SkStd_En     :string = 'Standard';
Lan_Tools_SkStd_Ru     :string = 'Стандарт';
Lan_Tools_SkTit_En     :string = 'Current Skin';
Lan_Tools_SkTit_Ru     :string = 'Текущая обшивка';
Lan_Tools_AutoSave_En  :string = 'Automatically save current';
Lan_Tools_AutoSave_Ru  :string = 'Автоматически запоминать текущую';
Lan_Tools_DefDir_En    :string = 'Folder with music';
Lan_Tools_DefDir_Ru    :string = 'Папка с музыкой';

Lan_List_BoxTitle   :string = 'Список проигрывания';
Lan_List_AddItems   :string = 'Добавить';
Lan_List_ClearList  :string = 'Очистить';
Lan_List_SaveList   :string = 'Сохранить';
Lan_List_Tools    :string = 'Действия';
Lan_List_ItemAdj    :string = 'Настройка элемента...';
Lan_List_ConvWav    :string = 'Конвертировать в WAV...';
Lan_List_ConvZxay   :string = 'Конвертировать в ZXAY...';
Lan_List_ConvVtx    :string = 'Конвертировать в VTX...';
Lan_List_ConvYm6    :string = 'Конвертировать в YM6...';
Lan_List_ConvPsg    :string = 'Конвертировать в PSG...';
Lan_List_SaveItem   :string = 'Сохранить как...';

Zero:integer = 0; //:-)

type

 BytePtr = ^byte;
 WordPtr = ^word;
 DWordPtr = ^longword;

//Own sens object
  PSensZone = ^TSensZone;
  TSensZone = class(TObject)
  constructor Create(ps:PSensZone;x,y,w,h:integer;pr:TNotifyEvent);
  function Touche(x,y:integer):boolean;
  public
  Next:PSensZone;
  zx,zy,zw,zh:integer;
  Clicked:boolean;
  Action:TNotifyEvent;
  end;

//Own button object
  PButtZone = ^TButtZone;
  TButtZone = class(TObject)
  constructor Create(ps:PButtZone;x,y,w,h,rh:integer;
                     DC_Bmp:HDC;x1,y1,x2,y2:integer;pr:TNotifyEvent);
  procedure Free;
  function Touche(x,y:integer):boolean;
  procedure Push;
  procedure UnPush;
  procedure Switch_On;
  procedure Switch_Off;
  procedure Redraw(OnCanvas:boolean);
  public
  Next:PButtZone;
  zx,zy,zw,zh,RgnHandle:integer;
  Clicked:integer;
  Is_On,Is_Pushed:boolean;
  Bmp1,Bmp2:HBITMAP;
  DC1,DC2:HDC;
  Action:TNotifyEvent;
  end;

//Own led object
  PLedZone = ^TLedZone;
  TLedZone = class(TObject)
  constructor Create(ps:PLedZone;x,y,w,h:integer;
                        DC_Bmp:HDC;x1,y1,x2,y2:integer);
  procedure Free;
  procedure Redraw(OnCanvas:boolean);
  public
  Next:PLedZone;
  zx,zy,zw,zh:integer;
  State:boolean;
  Bmp1,Bmp2:HBITMAP;
  DC1,DC2:HDC;
  end;

//Own mouse moving object
  PMoveZone = ^TMoveZone;
  TMoveZone = class(TObject)
  constructor Create(ps:PMoveZone;x,y,w,h,y1,h1,rh:integer;pr:TNotifyEvent);
  procedure Free;
  function Touche(x,y:integer):boolean;
  function ToucheBut(x,y:integer):boolean;
  procedure AddBitmaps(DC_Bmp:HDC;x1,y1,bw,bh:integer;m:boolean);
  procedure Redraw(OnCanvas:boolean);
  procedure HideBmp;
  public
  Next:PMoveZone;
  zx,zy,zw,zh,zy1,zh1,Delt,OldX,OldY,PosX,PosY,RgnHandle,
  bm1h,bm1w:integer;
  Clicked,State,Bmps,Mask:boolean;
  Bmp1,Bmp2,BmpMask:HBITMAP;
  DC1,DC2,DCMask:HDC;
  Action:TNotifyEvent;
  end;

 FIDO_Status = (FIDO_Nothing,FIDO_Playing,FIDO_Exit);

//Main window form
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure WndProc(var Message: TMessage); override;
    procedure ButOpenClick(Sender: TObject);
    procedure DoMovingWindow(Sender: TObject);
    procedure DoMovingVol(Sender: TObject);
    procedure DoMovingProgr(Sender: TObject);
    procedure DoMovingScroll(Sender: TObject);
    procedure PlayClick(Sender: TObject);
    procedure SetDefault;
    procedure ButPauseClick(Sender: TObject);
    procedure ButStopClick(Sender: TObject);
    procedure CommandLineInterpreter(CL:string;Start:boolean);
    procedure WMLINEPARAM(var Msg: TMessage);message WM_LINEPARAM;
    procedure WMPLAYNEXTITEM(var Msg: TMessage);message WM_PLAYNEXTITEM;
    procedure WMPLAYERROR(var Msg: TMessage);message WM_PLAYERROR;
    procedure WMTRAYICON(var Msg: TMessage);message WM_TRAYICON;
    procedure WMFINALIZEWO(var Msg: TMessage);message WM_FINALIZEWO;
    procedure MMMIXMCONTROLCHANGE(var Msg: TMessage);message MM_MIXM_CONTROL_CHANGE;
    procedure DoVisualisation(var Msg: TMessage);message WM_VISUALISATION;
    procedure HideMinimize(var Msg: TMessage);message WM_HIDEMINIMIZE;
    procedure MessageSkipper;
    procedure SwapLan;
    procedure SetPriority(Pr:longword);
    procedure Set_Chip_Frq(Fr:integer);
    procedure Set_Player_Frq(Fr:integer);
    procedure ButMixerClick(Sender: TObject);
    procedure ButMinClick(Sender: TObject);
    procedure ButCloseClick(Sender: TObject);
    procedure ButAboutClick(Sender: TObject);
    procedure ButAmpClick(Sender: TObject);
    procedure ButTimeClick(Sender: TObject);
    procedure ButSpaClick(Sender: TObject);
    procedure ShowAllParams;
    procedure RestoreAllParams;
    procedure ButListClick(Sender: TObject);
    procedure ButNextClick(Sender: TObject);
    procedure ButPrevClick(Sender: TObject);
    procedure Set_Mode(It:Integer);
    procedure Set_Mode_Manual(AL,AR,BL,BR,CL,CR:byte);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButToolsClick(Sender: TObject);
    procedure ButLoopClick(Sender: TObject);
    procedure Set_Z80_Frq(NewF:integer);
    procedure Set_N_Tact(NewF:integer);
    procedure CommandLineAndRegCheck;
    procedure FillTools;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AppRestore(Sender: TObject);
    procedure AppMinimize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RemoveTrayIcon;
    procedure AddTrayIcon;
    procedure ChangeTrayIcon;
    procedure SelectTrayIcon(n:integer);
    procedure SelectAppIcon(n:integer);
    procedure LoadSkin(FName:string;First:boolean);
    procedure SetMainBmp(p:pointer;size:integer);
    procedure BmpFree;
    procedure CopyBmpSources;
    procedure Set_MFP_Frq(Md,Fr:integer);
    procedure DropFiles(var Msg: TWmDropFiles);message wm_DropFiles;
    procedure ShowApp(Tray:boolean);
    procedure MyBringToFront;
    procedure FIDO_SaveStatus(Status:FIDO_Status);
    procedure JumpToTime;
    procedure CallHelp;
    procedure VolUp;
    procedure VolDown;
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure MMMCINOTIFY(var Msg: TMessage);message MM_MCINOTIFY;
    procedure SaveParams;
//    procedure RemoveOldPaths;
    procedure Set_Sample_Rate2(SR:integer);
    procedure Set_Sample_Bit2(SB:integer);
    procedure Set_Stereo2(St:integer);
    procedure SetOptimization2(Q:boolean);
    procedure Set_WODevice2(WOD:integer);
    procedure Set_BufLen_ms2(BL:integer);
    procedure Set_NumberOfBuffers2(NB:integer);
    procedure Set_Chip2(Ch:ChTypes);
    procedure Set_Z80_Frq2(NewF:integer);
    procedure Set_Chip_Frq2(Fr:integer);
    procedure Set_Player_Frq2(Fr:integer);
    procedure Set_IntOffset2(InO:integer);
    procedure Set_N_Tact2(NT:integer);
    procedure Set_N_TactS(t:string);
    procedure Set_Language2(Rus:boolean);
    procedure Set_Loop2(Lp:boolean);
    procedure Set_TrayMode2(TM:integer);
    procedure Set_MFP_Frq2(Md,Fr:integer);
    procedure SetAutoSaveDefDir2(ASD:boolean);
    procedure SetAutoSaveWindowsPos2(ASW:boolean);
    procedure SetAutoSaveVolumePos2(ASV:boolean);
    procedure SetPriority2(NP:integer);
    procedure SetChan2(u,i:integer);
    procedure SetFilter(FQ:integer);
    procedure SetFilter2(FQ:integer);
    procedure CalcFiltKoefs;
    procedure SaveAllParams;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  STC_Registered,STP_Registered,ASC_Registered,PSC_Registered,
  SQT_Registered,AYL_Registered,PT1_Registered,PT2_Registered,
  PT3_Registered,FTC_Registered,FLS_Registered,M3U_Registered,
  OUT_Registered,ZXAY_Registered,PSG_Registered,
  VTX_Registered,YM_Registered,AYS_Registered,
  GTR_Registered,FXM_Registered,PSM_Registered,AY_Registered,AYM_Registered,
  MP3_Registered,MP2_Registered,MP1_Registered,OGG_Registered,
  WAV_Registered,MO3_Registered,IT_Registered,XM_Registered,
  S3M_Registered,MTM_Registered,MOD_Registered,UMX_Registered,WMA_Registered,
  CDA_Registered:boolean;

  Is_Skined:boolean;
  SkinFileName,SkinAuthor,SkinComment:string;

  DefaultDirectory,SkinDirectory:string;

  LastTimeComLine:DWORD;
  end;

function IntelWord(Wrd:word):word;
function IntelDWord(DWrd:dword):dword;
function MyForceDirectories(Dir: string):boolean;

procedure PlayCurrent;
procedure StopAndFreeAll;
procedure StopPlaying;
procedure RestoreControls;

procedure RedrawVisChannels(ca,cb,cc,mh:integer);
procedure RedrawVisSpectrum(CP:TVisPoint);

procedure ShowProgress(a1:integer);

procedure Set_Sample_Rate(SR:integer);
procedure Set_Sample_Bit(SB:integer);
procedure Set_Stereo(St:integer);
procedure SetOptimization(Q:boolean);

procedure Rewind(newpos,maxpos:integer);

procedure ReprepareScroll;

procedure GetSysVolume;
procedure SetSysVolume;
procedure RedrawVolume;

procedure CheckRegError(Index:integer);

var
  Form1: TForm1;

  MFPTimerFrq,MFPTimerMode:integer;

  VisEventH:THANDLE;
  VisThreadID:DWORD;
  VisThreadH:THANDLE;

  Scr_Left:boolean = False;
  ScrFlg:boolean = True;
  Scr_Pause:integer = 1;
  pr1:integer = -2;
  pr2:integer = -2;
  Scroll_Distination:integer = -1;
  Item_Displayed:integer = -1;
  HorScrl_Offset:integer = 0;
  Scroll_Offset:integer = scr_lineheight;
  TimeFont,ScrollFont:HFONT;
  ClearTimeInd:boolean;
  TimeMode:integer = 0;
  CurrTime_Rasch:integer;
  BaseSample:DWORD;

  DC_Window,
  DC_Sources,DC_Time,DC_Vis:HDC;
  DC_VScroll,DC_Scroll,DC_DBuffer:HDC;
  Brush_VScroll:HBRUSH;
  Bitmap_DBuffer,
  BitmapSources,Bitmap_Time,Bitmap_Vis:HBITMAP;
  Bitmap_VScroll,Bitmap_Scroll:HBITMAP;
  Pen_Vis:HPEN;

  VProgrPos:integer;
  ProgrMax,ProgrPos:longword;
  ProgrX:word = 0;
  ProgrWidth:word;

  IntOffset:integer;
  OUTZXAYConv_TotalTime:integer;

  FrqZ80,Interrupt_Freq,AY_Freq:integer;

  Russian_Interface:boolean = False;
  PSG_Skip:word;
  Real_End,May_Quit:boolean;
  Do_Scroll:boolean = True;
  Do_Loop:boolean = False;
  Time_ms:integer = 0;
  TimeShown:integer = -MaxInt;

  ButPlay,ButNext,ButPrev,ButOpen,ButStop,ButPause,ButAbout,
  ButLoop,ButMixer,ButTools,ButList,ButMinimize,ButClose:TButtZone;
  SensSpa,SensAmp,SensTime:TSensZone;
  MoveWin,MoveVol,MoveProgr,MoveScr:TMoveZone;
  Led_AY,Led_YM,Led_Stereo:TLedZone;
  MyFormRgn,RgnClose,RgnMin,RgnMixer,RgnTools,RgnPList,
  RgnLoop,RgnBack,RgnPlay,RgnNext,RgnStop,RgnPause,RgnOpen,
  RgnVol,RgnProgr:HRGN;

  IndicatorChecked:boolean = True;
  SpectrumChecked:boolean = True;
  AutoSaveDefDir:boolean = True;
  Priority:dword = NORMAL_PRIORITY_CLASS;

  //Tray Icon Data
  TrayMode:integer = 0;
  TrayOn:LongBool = False;
  TrIcon:_NOTIFYICONDATA;
  TrayIconNumber:integer = 11;
  TrayIconClicked:boolean = False;
  RecurseDirs:boolean = True;
  RecurseOnlyKnownTypes:boolean = False;

  MenuIconNumber:integer = 0;
  AppIconNumber:integer = 0;
  MusIconNumber:integer = 10;
  SkinIconNumber:integer = 3;
  ListIconNumber:integer = 2;
  BASSIconNumber:integer = 4;

  FIDO_Descriptor_Enabled:boolean = False;
  FIDO_Descriptor_WinEnc:boolean = False;
  FIDO_Descriptor_KillOnNothing:boolean = False;
  FIDO_Descriptor_KillOnExit:boolean = True;
  FIDO_Descriptor_Prefix:string = '... Ay_Emul: ';
  FIDO_Descriptor_Suffix:string = '';
  FIDO_Descriptor_Nothing:string = 'Silent now...';
  FIDO_Descriptor_Filename:string;
  FIDO_Descriptor_String:string = '';

  ToolsX:integer = MaxInt;
  ToolsY:integer;
  AutoSaveWindowsPos:boolean = True;
  AutoSaveVolumePos:boolean = False;
  Uninstall:boolean = False;

const
  ButtZoneRoot:PButtZone = nil;
  SensZoneRoot:PSensZone = nil;
  MoveZoneRoot:PMoveZone = nil;
  LedZoneRoot:PLedZone = nil;
  CLFast = 800;
  InitialScan:boolean = False;

var
  AfterScan:array of string;
  TimePlayStart:DWORD;
  VolumeCtrl,VolumeCtrlMax:integer;
  VolLinear:boolean = False;

implementation

uses Mixer, PlayList, Tools, Z80, JmpTime, Players, lightBASS, BASScode,
     CDviaMCI;

{$R *.DFM}

type
//Spectrum analizer values
 TSpa = array[0..spa_num - 1] of byte;
 PSpa = ^TSpa;

var
  sw:integer = scr_width;
  sj,sw1,sj1,sw2,sj2:integer;
  ss,ss1,ss2:string;
  Spa_points:array[0..spa_num] of integer;
  Spa_piks,Spa_prev:TSpa;
  PSpa_Piks,PSpa_prev:PSpa;

function IntelWord(Wrd:word):word;
asm
xchg al,ah
end;

function IntelDWord(DWrd:dword):dword;
asm
xchg al,ah
ror eax,16
xchg al,ah
end;

function MyForceDirectories(Dir: string):boolean;
begin
  Result := True;
  if (Length(Dir) = 0) then exit;
  if (AnsiLastChar(Dir) <> nil) and (AnsiLastChar(Dir)^ = '\') then
    Delete(Dir, Length(Dir), 1);
  if DirectoryExists(Dir)
    or (ExtractFilePath(Dir) = Dir) then exit;
  if MyForceDirectories(ExtractFilePath(Dir)) then
   Result := CreateDir(Dir)
end;

type
 ERegistryError = class(Exception);

procedure CheckRegError;
var
 Strg:PChar;
begin
if Index <> ERROR_SUCCESS then
 begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER,
                nil,Index,0,@Strg,0,nil);
  try
   raise ERegistryError.Create(Strg);
  finally
   LocalFree(integer(Strg))
  end
 end
end;

procedure GetStringWnJ(const s:string; var w,j:integer);
var
 Sz:tagSIZE;
begin
GetTextExtentPoint32(DC_VScroll,PChar(s),System.Length(s),Sz);
j := 0;
w := Sz.cx;
if scr_width > w then
 j := (scr_width - w) div 2
end;

procedure RedrawScroll;
begin
BitBlt(DC_Scroll,0,0,scr_width,scr_height,DC_Sources,scr_src,0,SRCCOPY);
TextOut(DC_VScroll,-HorScrl_Offset + sj,scr_height,PChar(ss),Length(ss));
BitBlt(DC_Scroll,0,0,scr_width,scr_height,DC_VScroll,0,scr_height,SRCAND);
BitBlt(DC_Window,scr_x,scr_y,scr_width,scr_height,DC_Scroll,0,0,SRCCOPY)
end;

procedure RedrawTime;
var
 CurTimeJ:integer;
 CurrTimeStr:string;
 Sz:tagSIZE;
 sig:string;
begin
if TimeMode = 1 then sig := '-' else sig := '';
CurrTimeStr := sig + TimeSToStr(abs(TimeShown));
GetTextExtentPoint32(DC_Time,PChar(CurrTimeStr),Length(CurrTimeStr),Sz);
CurTimeJ := time_width - Sz.cx;
if CurTimeJ > 0 then CurTimeJ := CurTimeJ div 2;
BitBlt(DC_Time,0,0,time_width,time_height,DC_Sources,time_src,0,SRCCOPY);
TextOut(DC_Time,CurTimeJ,0,PChar(CurrTimeStr),Length(CurrTimeStr));
BitBlt(DC_Window,time_x,time_y,time_width,time_height, DC_Time,0,0,SRCCOPY)
end;

procedure CalculateSpectrumPoints;
var
 i:integer;
begin
Spa_points[0] := $FFF;
for i := 1 to spa_num do
 Spa_points[i] := round($FFF * exp(-ln(16 * 22050 * $FFF/AY_Freq)*i/spa_num))
end;

procedure TForm1.DoVisualisation;
var
 Y_Stp:integer;
 Points_To_Scroll:integer;
 Temp,Temp1:integer;
begin
 begin
 WOVisualisation;
 BASSVisualisation;
 CDVisualisation;
 if ClearTimeInd then
  begin
   BitBlt(DC_Time,0,0,time_width,time_height,DC_Sources,time_src,0,SRCCOPY);
   BitBlt(DC_Window,time_x,time_y,time_width,time_height,DC_Sources,time_src,0,SRCCOPY);
   TimeShown := -MaxInt;
   ClearTimeInd := False
  end;
 if Time_ms <> 0 then
  begin
   case TimeMode of
   0: Temp := round(CurrTime_Rasch / 1000);
   1:
    begin
     Temp := Time_ms - CurrTime_Rasch;
     if Temp < 0 then Temp := 0;
     Temp := -round(Temp / 1000);
    end
   else
    Temp := round(Time_ms / 1000);
   end;
   if Temp <> TimeShown then
    begin
     TimeShown := Temp;
     RedrawTime
    end
  end;
 Temp := Item_Displayed;
 Temp1 := Scroll_Distination;
 if Abs(Temp1 - Temp) > 16 then
  begin
   if Temp1 > Temp then
    Temp := Temp1 - 16
   else
    Temp := Temp1 + 16;
   Item_Displayed := Temp;
   ss := GetPlayListString(PlaylistItems[Temp]);
   GetStringWnJ(ss,sw,sj);
   TextOut(DC_VScroll,sj,scr_lineheight,PChar(ss),Length(ss));
   pr1 := -2; pr2 := -2
  end;
 Points_To_Scroll := scr_lineheight*(Temp1 - Temp + 1) - Scroll_Offset;
 if Points_To_Scroll <> 0 then
  begin
   ScrFlg := False;
   Y_Stp := (Abs(Points_To_Scroll) - 1) div scr_lineheight + 1;
   if Y_Stp >= scr_lineheight then Y_Stp := scr_lineheight - 1;
   if Points_To_Scroll > 0 then
    begin
     if (Scroll_Offset >= scr_lineheight) and (Temp <> pr2) then
      begin
       pr2 := Temp;
       FillRect(DC_VScroll,Rect(0,scr_lineheight*2,
                scr_width,scr_lineheight*3),Brush_VScroll);
       if Temp + 1 < Length(PlaylistItems) then
        begin
         ss2 := GetPlayListString(PlaylistItems[Temp + 1]);
         GetStringWnJ(ss2,sw2,sj2);
         TextOut(DC_VScroll,sj2,scr_lineheight*2,PChar(ss2),Length(ss2))
        end
      end;
     Inc(Scroll_Offset,Y_Stp);
     if Scroll_Offset >= 2*scr_lineheight then
      begin
       HorScrl_Offset := 0;
       ss := ss2; sw := sw2; sj := sj2;
       BitBlt(DC_VScroll,0,0,scr_width,scr_lineheight*2,
              DC_VScroll,0,scr_lineheight,SRCCOPY);
       Dec(Scroll_Offset,scr_lineheight);
       Inc(Temp);
       Item_Displayed := Temp
      end
    end
   else
    begin
     if (Scroll_Offset <= scr_lineheight) and (Temp <> pr1) then
      begin
       pr1 := Temp;
       FillRect(DC_VScroll,Rect(0,0,scr_width,scr_lineheight),Brush_VScroll);
       if Temp - 1 >= 0 then
        begin
         ss1 := GetPlayListString(PlaylistItems[Temp - 1]);
         GetStringWnJ(ss1,sw1,sj1);
         TextOut(DC_VScroll,sj1,0,PChar(ss1),Length(ss1))
        end
      end;
     Dec(Scroll_Offset,Y_Stp);
     if Scroll_Offset <= 0 then
      begin
       HorScrl_Offset := 0;
       ss := ss1; sw := sw1; sj := sj1;
       BitBlt(DC_VScroll,0,scr_lineheight,scr_width,scr_lineheight*2,
              DC_VScroll,0,0,SRCCOPY);
       Inc(Scroll_Offset,scr_lineheight);
       Dec(Temp);
       Item_Displayed := Temp
      end
    end;
   BitBlt(DC_Scroll,0,0,scr_width,scr_height,DC_Sources,scr_src,0,SRCCOPY);
   BitBlt(DC_Scroll,0,0,scr_width,scr_height,DC_VScroll,0,Scroll_Offset,SRCAND);
   BitBlt(DC_Window,scr_x,scr_y,scr_width,scr_height,DC_Scroll,0,0,SRCCOPY)
  end;
 if ScrFlg then
  begin
   pr1 := -2;
   pr2 := -2
  end;
 if Do_Scroll and ScrFlg and (sw > scr_width) and
    not MoveScr.Clicked then
  begin
   Dec(Scr_Pause);
   if Scr_Pause = 0 then
    begin
     Inc(Scr_Pause);
     if Scr_Left then
      begin
       Dec(HorScrl_Offset);
       if HorScrl_Offset < 0 then
        begin
         Scr_Left := False;
         HorScrl_Offset := 0;
         Scr_Pause := 50
        end
       else
        RedrawScroll
      end
     else
      begin
       Inc(HorScrl_Offset);
       if HorScrl_Offset > sw - scr_width then
        begin
         Scr_Left := True;
         HorScrl_Offset := sw - scr_width;
         Scr_Pause := 50
        end
       else
        RedrawScroll
      end
    end
  end
 else
  ScrFlg := True;
 end;
end;

function VisThreadFunc(a:pointer):dword;stdcall;
var
 t:DWORD;
begin
t := 0;
while WaitForSingleObject(VisEventH,t) <> WAIT_OBJECT_0 do
 begin
  t := 100;
  if not IsIconic(Application.Handle) then
   begin
    t := GetTickCount;
    SendMessage(Form1.Handle,WM_VISUALISATION,0,0);
    Inc(integer(t),30 - integer(GetTickCount));
    if integer(t) < 0 then
     t := 0
   end
 end;
Result := STILL_ACTIVE - 1
end;

procedure RedrawVisChannels;
begin
if IndicatorChecked then
 begin
  BitBlt(DC_Vis,0,0,amp_width,amp_height,DC_Sources,amp_src,0,SRCCOPY);
  if ca > 0 then
   begin
    MoveToex(DC_Vis,1,amp_height,nil);
    LineTo(DC_Vis,1,amp_height + 1 - ca * amp_height div mh)
   end;
  if cb > 0 then
   begin
    MoveToex(DC_Vis,8,amp_height,nil);
    LineTo(DC_Vis,8,amp_height + 1 - cb * amp_height div mh)
   end;
  if cc > 0 then
   begin
    MoveToex(DC_Vis,15,amp_height,nil);
    LineTo(DC_Vis,15,amp_height + 1 - cc * amp_height div mh)
   end;
  BitBlt(DC_Window,amp_x,amp_y,amp_width,amp_height,DC_Vis,0,0,SRCCOPY)
 end
end;

procedure RedrawVisSpectrum;
var
 p:pointer;
 i,j:integer;
begin
if SpectrumChecked then
 begin
  p := PSpa_prev;
  PSpa_prev := PSpa_piks;
  PSpa_Piks := p;
  for i := 0 to spa_num - 1 do
   begin
    if (CP.TnA > Spa_Points[i + 1]) and (CP.TnA <= Spa_Points[i]) then
     PSpa_piks^[i] := CP.AmpA
    else
     PSpa_piks^[i] := 0;
    if (CP.TnB > Spa_Points[i + 1]) and (CP.TnB <= Spa_Points[i]) then
     if PSpa_piks^[i] < CP.AmpB then
      PSpa_piks^[i] := CP.AmpB;
    if (CP.TnC > Spa_Points[i + 1]) and (CP.TnC <= Spa_Points[i]) then
     if PSpa_piks^[i] < CP.AmpC then
      PSpa_piks^[i] := CP.AmpC
   end;
  BitBlt(DC_Vis,0,0,spa_width,spa_height,DC_Sources,spa_src,0,SRCCOPY);
  for i := 0 to spa_num - 1 do
   begin
    if PSpa_Piks^[i] > 0 then
     begin
      MoveToex(DC_Vis,i + 1,spa_height,nil);
      LineTo(DC_Vis,i + 1,(31 - PSpa_Piks^[i])*spa_height div 30)
     end;
    if PSpa_Prev^[i] > PSpa_Piks^[i] then
     begin
      PSpa_Piks^[i] := PSpa_Prev^[i];
      if PSpa_Piks^[i] > 0 then
       begin
        j := (31 - PSpa_Piks^[i])*spa_height div 30;
        SetPixel(DC_Vis,i,j,rgb(10,10,10));
        SetPixel(DC_Vis,i + 1,j,rgb(10,10,10));
        SetPixel(DC_Vis,i + 2,j,rgb(10,10,10))
       end;
      Dec(PSpa_Piks^[i],2)
     end
   end;
  BitBlt(DC_Window,spa_x,spa_y,spa_width,spa_height,DC_Vis,0,0,SRCCOPY)
 end
end;

procedure ShowProgress;

 function divmul(q1,q2,q3:dword):dword;register;
 asm
  mul q2
  div q3
 end;

var
 x:word;
begin
ProgrPos := a1;
if (ProgrMax = 0) then exit;
if ProgrMax < ProgrPos then ProgrPos := ProgrMax;
x := divmul(ProgrWidth,ProgrPos,ProgrMax);
if ProgrX <> x then
 begin
  ProgrX := x;
  if MoveProgr.Clicked then exit;
  MoveProgr.HideBmp;
  OffsetRgn(MoveProgr.RgnHandle,x - MoveProgr.PosX,0);
  MoveProgr.PosX := x;
  MoveProgr.Redraw(False)
 end
end;

procedure TForm1.SetDefault;
var
 IsPl:boolean;
begin
IsPl := WOThreadActive;
BeeperMax := BeeperMaxDef;
Set_Z80_Frq(FrqZ80Def);
Set_Player_Frq(Interrupt_FreqDef);
if not IsPl then Set_Sample_Rate(SampleRateDef);
Set_Chip_Frq(AY_FreqDef);
Set_MFP_Frq(MFPTimerModeDef,MFPTimerFrqDef);
IntOffset := IntOffsetDef;
Set_N_Tact(MaxTStatesDef);
if not IsPl then
 begin
  Set_Sample_Bit(SampleBitDef);
  Set_Stereo(NumOfChanDef);
  SetBuffers(BufLen_msDef,NumberOfBuffersDef);
  WODevice := WODeviceDef
 end;
Set_Mode_Manual(Index_ALDef,Index_ARDef,Index_BLDef,Index_BRDef,
                Index_CLDef,Index_CRDef);
ChType := YM_Chip;
SetOptimization(True);
SetFilter(2);
BASSFFTType := BASS_DATA_FFT4096;
BASSAmpMin := 0.003;
Calculate_Level_Tables;
RedrawPlaylist(ShownFrom,0,False);
CalculateTotalTime(False)
end;

procedure TForm1.ButOpenClick(Sender: TObject);
begin
ButOpen.UnPush;
if GetKeyState(VK_SHIFT) and 128 <> 0 then
 Form3.Add_Directory_Dialog(False)
else if GetKeyState(VK_CONTROL) and 128 <> 0 then
 Form3.Add_CD_Dialog(False)
else
 Form3.Add_Item_Dialog(False)
end;

procedure TForm1.PlayClick(Sender: TObject);
begin
if IsPlaying then exit;
if not FileAvailable then
 begin
  ButPlay.UnPush;
  exit
 end;
PlayCurrent
end;

procedure TForm1.ButPauseClick(Sender: TObject);
begin
if not IsPlaying then
 begin
  ButPause.UnPush;
  exit
 end;
if not (CurFileType in [BASSFileMin..BASSFileMax,CDAFile]) then
 WOPauseRestart
else if CurFileType <> CDAFile then
 begin
  Paused := True;
  SwitchPause;
  TimePlayStart := GetTickCount - TimePlayStart;
  Paused := BASSPaused
 end
else
 begin
  CDSwitchPause(CurCDNum,Handle);
  Paused := CDPlayingPaused
 end; 
if not Paused then
 begin
  FIDO_SaveStatus(FIDO_Playing);
  ButPause.Switch_Off
 end
else
 begin
  FIDO_SaveStatus(FIDO_Nothing);
  ButPause.Switch_On
 end
end;

procedure TForm1.ButStopClick(Sender: TObject);
begin
try
 StopAndFreeAll
finally
 ButStop.UnPush
end
end;

procedure RestoreControls;
begin
 Form1.FIDO_SaveStatus(FIDO_Nothing);
 ButPlay.Switch_Off;
 Form2.GroupBox3.Enabled := True;
 Form2.GroupBox4.Enabled := True;
 Form2.Buff.Enabled := True;
 Form2.GroupBox10.Enabled := True;
 Form2.RadioButton13.Enabled := True;
 Form2.RadioButton14.Enabled := True;
 ButStop.UnPush;
 ButPause.Switch_Off;
 Form2.Edit12.Text := ''; Form2.Edit13.Text := ''; Form2.Edit14.Text := '';
 Form2.Edit15.Text := ''; Form2.Edit16.Text := ''; Form2.Edit17.Text := '';
 Form2.Edit18.Text := ''; Form2.Edit23.Text := ''; Form2.Edit26.Text := '';
 Form2.CheckBox4.Checked := False;
 Form2.CheckBox5.Checked := False;
 Form2.CheckBox6.Checked := False;
 Form2.CheckBox7.Checked := False
end;

procedure PlayCurrent;
begin
case ChType of
AY_Chip:
 begin
  Led_AY.State := False;
  Led_YM.State := True
 end;
YM_Chip:
 begin
  Led_AY.State := True;
  Led_YM.State := False
 end
end;
Led_Stereo.State := NumberOfChannels = 1;
Led_AY.Redraw(False);
Led_YM.Redraw(False);
Led_Stereo.Redraw(False);

ButPlay.Switch_On;
Form1.ShowAllParams;
ButPause.Switch_Off;
ButStop.UnPush;
Form2.GroupBox3.Enabled := False;
Form2.GroupBox4.Enabled := False;
Form2.Buff.Enabled := False;
Form2.GroupBox10.Enabled := False;
Form2.RadioButton13.Enabled := False;
Form2.RadioButton14.Enabled := False;
Form1.FIDO_SaveStatus(FIDO_Playing);

try
 InitForAllTypes(True);
if CurFileType in [BASSFileMin..BASSFileMax] then
 StartBASS(CurFileType = WMAFile)
else if CurFileType <> CDAFile then
 StartWOThread
else
 StartCD(CurCDNum,CurCDTrk)
except
 RestoreControls;
 ShowException(ExceptObject, ExceptAddr)
end
end;

procedure TForm1.MessageSkipper;
var
 masg:TMsg;
begin
while PeekMessage(masg,windowhandle,0,0,PM_REMOVE) do
 case masg.message of
 WM_LBUTTONDOWN:     may_quit:=true;
 WM_KEYDOWN:         if masg.wparam=VK_ESCAPE then may_quit:=true;
 WM_PAINT:           begin
                     TranslateMessage(Masg);
                     DispatchMessage(Masg);
                     end;
 end;
if Form3.Visible then
 while PeekMessage(masg,Form3.Handle,0,0,PM_REMOVE) do
  if masg.message=WM_PAINT then
   begin
   TranslateMessage(Masg);
   DispatchMessage(Masg);
   end;
end;

procedure TForm1.WMLINEPARAM;
var
 HBlock:DWORD;
 HAddr:PChar;
begin
HBlock := OpenFileMapping(FILE_MAP_ALL_ACCESS,False,'Ay_Emul Command Line Area');
if HBlock <> 0 then
 try
  pointer(HAddr) := MapViewOfFile(HBlock,FILE_MAP_ALL_ACCESS,0,0,MAX_PATH * 2 + 4);
  if HAddr <> nil then
   try
    if InitialScan then
     CommandLineInterpreter(HAddr,False)
    else
     begin
      SetLength(AfterScan,Length(AfterScan) + 1);
      AfterScan[Length(AfterScan) - 1] := HAddr
     end 
   finally
    UnmapViewOfFile(pointer(HAddr))
   end
 finally
  CloseHandle(HBlock)
 end
end;

procedure TForm1.CommandLineInterpreter;
var
 CLPos,CLLen,fileadp:integer;
 Param:string;
 fileex,quote,Fast,fileadd:boolean;
 ParamFiles:TStringList;

 procedure CommandLineParameter(CLP:string);
 var
  Ch:char;
  ErrPos,NewFrq,i,j:integer;
  usils:array[0..5]of byte;
  TempStr:string;
 begin
  if CLP = '' then exit;
  if CLP[1] = '/' then
   begin
    if Length(CLP) < 2 then exit;
    case char(byte(CLP[2]) or $20) of
    's':
      begin
       Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
       if ErrPos = 0 then
        Set_Sample_Rate2(NewFrq)
      end;
    'b':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then
       Set_Sample_Bit2(NewFrq)
     end;
    'z':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then Set_Z80_Frq2(NewFrq)
     end;
    'y':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      Val(CLP,NewFrq,ErrPos);
      if ErrPos = 0 then Set_Chip_Frq2(NewFrq)
      else if CLP = 'list' then Form2.CheckBox3.Checked := True
      else if CLP = 'mixer' then Form2.CheckBox3.Checked := False
     end;
    'q':
     begin
      CLP := Trim(Copy(CLP,3,Length(CLP) - 2));
      if CLP = '' then
       Set_MFP_Frq2(0,0)
      else
       begin
        Val(CLP,NewFrq,ErrPos);
        if ErrPos = 0 then
         Set_MFP_Frq2(1,NewFrq)
       end
     end;
    't':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then Set_IntOffset2(Newfrq)
     end;
    'a':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       IndicatorChecked := True
      else if CLP = 'off' then
       IndicatorChecked := False
      else if CLP = 'dd' then
       begin
        fileadd := True;
        fileadp := -1
       end
      else if CLP = 'dp' then
       fileadd := True
     end;
    'f':
     begin
      TempStr := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if TempStr = 'on' then
       SpectrumChecked := True
      else if TempStr = 'off' then
       SpectrumChecked := False
      else if (Length(TempStr) > 2) and (TempStr[1] = 'd') then
       begin
        CLP := Copy(CLP,5,Length(CLP) - 4);
        case TempStr[2] of
        'f':FIDO_Descriptor_FileName := CLP;
        'n':FIDO_Descriptor_Nothing := CLP;
        's':FIDO_Descriptor_Suffix := CLP;
        'p':FIDO_Descriptor_Prefix := CLP;
        'e':FIDO_Descriptor_Enabled := CLP <> '0';
        'k':FIDO_Descriptor_KillOnNothing := CLP <> '0';
        'x':FIDO_Descriptor_KillOnExit := CLP <> '0';
        'w':FIDO_Descriptor_WinEnc := CLP <> '0'
        end
       end
     end;
    'i':
     Set_N_TactS(Copy(CLP,3,Length(CLP) - 2));
    'o':
     if Length(CLP) = 3 then
      begin
       Ch := char(byte(CLP[3]) or $20);
       if Ch in ['q','p'] then
        SetOptimization2(Ch = 'q')
      end;
    'l':
     if Length(CLP) = 3 then
      begin
       Ch := char(byte(CLP[3]) or $20);
       if Ch in ['e','r'] then
        Set_Language2(Ch = 'r')
      end;
    'n':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      Val(CLP,NewFrq,ErrPos);
      if ErrPos = 0 then
       Set_Player_Frq2(NewFrq)
      else if CLP = 'list' then
       Form2.CheckBox9.Checked := True
      else if CLP = 'mixer' then
       Form2.CheckBox9.Checked := False
     end;
    'c':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       Set_Loop2(True)
      else if CLP = 'off' then
       Set_Loop2(False)
     end;
    'r':
     if Length(CLP) = 3 then
      begin
       Ch := char(byte(CLP[3]) or $20);
       if Ch in ['i','n','h'] then
        begin
         case Ch of
         'i':SetPriority2(IDLE_PRIORITY_CLASS);
         'n':SetPriority2(NORMAL_PRIORITY_CLASS)
         else SetPriority2(HIGH_PRIORITY_CLASS)
         end
        end
      end;
    'h':
     begin
      CLP := UpperCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'MONO' then NewFrq := 0
      else if CLP = 'AYABC' then NewFrq := 1
      else if CLP = 'AYACB' then NewFrq := 2
      else if CLP = 'AYBAC' then NewFrq := 3
      else if CLP = 'AYBCA' then NewFrq := 4
      else if CLP = 'AYCAB' then NewFrq := 5
      else if CLP = 'AYCBA' then NewFrq := 6
      else if CLP = 'YMABC' then NewFrq := 7
      else if CLP = 'YMACB' then NewFrq := 8
      else if CLP = 'YMBAC' then NewFrq := 9
      else if CLP = 'YMBCA' then NewFrq := 10
      else if CLP = 'YMCAB' then NewFrq := 11
      else if CLP = 'YMCBA' then NewFrq := 12
      else if CLP = 'LIST' then
       begin
        Form2.CheckBox1.Checked := True;
        NewFrq := -1
       end
      else if CLP = 'MIXER' then
       begin
        Form2.CheckBox1.Checked := False;
        NewFrq := -1
       end
      else
       begin
        i := 1;
        CLP := CLP + ',';
        for j := 0 to 5 do
         begin
          TempStr := '';
          while (i <= Length(CLP)) and (CLP[i] <> ',') do
           begin
            TempStr := TempStr + CLP[i];
            Inc(i)
           end;
          Inc(i);
          if i - 1 > Length(CLP) then break;
          Val(TempStr,usils[j],ErrPos);
          if ErrPos <> 0 then break
         end;
        if (i - 1 <= Length(CLP)) and (ErrPos = 0) then
         with Form2 do
          for j := 0 to 5 do
           SetChan2(usils[j],j);
        NewFrq := -1
       end;
      if NewFrq >= 0 then Form2.SetChanIndexes(NewFrq)
     end;
    'd':
     begin
      CLP := UpperCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'MONO' then Set_Stereo2(1)
      else if CLP = 'STEREO' then Set_Stereo2(2)
      else if CLP = 'LIST' then Form2.CheckBox8.Checked := True
      else if CLP = 'MIXER' then Form2.CheckBox8.Checked := False
     end;
    'e':
     begin
      CLP := UpperCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'AY' then Set_Chip2(AY_Chip)
      else if CLP = 'YM' then Set_Chip2(YM_Chip)
      else if CLP = 'LIST' then Form2.CheckBox2.Checked := True
      else if CLP = 'MIXER' then Form2.CheckBox2.Checked := False
     end;
    'g':
     begin
      CLP := Copy(CLP,3,Length(CLP) - 2);
      if CLP = '0' then
       Set_TrayMode2(0)
      else if CLP = '1' then
       Set_TrayMode2(1)
      else if CLP = '2' then
       Set_TrayMode2(2)
     end;
    'j':
     begin
      CLP := Copy(CLP,3,Length(CLP) - 2);
      if CLP = '0' then
       TimeMode := 0
      else if CLP = '1' then
       TimeMode := 1
      else if CLP = '2' then
       TimeMode := 2
     end;
    'k':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then Do_Scroll := True
      else if CLP = 'off' then Do_Scroll := False
     end;
    'p':
     LoadSkin(Copy(CLP,3,Length(CLP) - 2),False);
    'w':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       SetAutoSaveDefDir2(True)
      else if CLP = 'off' then
       SetAutoSaveDefDir2(False)
      else if (Length(CLP) > 2) and (CLP[1] = 'o') then
       begin
        Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
        if ErrPos = 0 then
         case CLP[2] of
         'n':Set_NumberOfBuffers2(NewFrq);
         'l':Set_BufLen_ms2(NewFrq);
         'd':Set_WODevice2(NewFrq)
         end
       end
     end;
    'u':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then SetChan2(NewFrq,6)
     end;
    'v':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'hide' then
       PostMessage(Handle,WM_HIDEMINIMIZE,0,0)
      else if CLP = 'show' then
       ShowApp(False)
     end;
    'x':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       SetAutoSaveWindowsPos2(True)
      else if CLP = 'off' then
       SetAutoSaveWindowsPos2(False)
     end;
    '!':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       SetAutoSaveVolumePos2(True)
      else if CLP = 'off' then
       SetAutoSaveVolumePos2(False)
     end
    end
   end
  else
   begin
    if FileExists(CLP) then
     begin
      fileex := True;
      ParamFiles.Add(ExpandFileName(CLP))
     end
   end
 end;

var
 First:integer;
 dir:string;

begin
Fast := GetTickCount - LastTimeComLine < CLFast;
dir := GetCurrentDir;
ParamFiles := TStringList.Create;
fileex := False; fileadd := False; fileadp := Length(PlayListItems);
CLPos := 1;
CLLen := Length(CL);
First := 0;
while CLPos <= CLLen do
 begin
  quote := False;
  Param := '';
  while (CLPos <= CLLen) and (quote or (CL[CLPos] > ' ')) do
   begin
    if CL[CLPos] = '"' then
     quote := not quote
    else
     Param := Param + CL[CLPos];
    Inc(CLPos)
   end;
  case First of
  0:
   begin
    First := 1;
    SetCurrentDir(Param);
   end;
  1:
   First := 2;
  else
   CommandLineParameter(Param);
  end;
  Inc(CLPos)
 end;
SetCurrentDir(dir); 
if FileEx then
 begin
  try
   if not fileadd and not Start and not Fast then
    begin
     StopPlaying;
     ClearPlayList;
    end
   else if fileadd and (fileadp >= 0) then
    StopPlaying;
   Form3.Add_Files(ParamFiles);
   CalculateTotalTime(False)
  finally
   CreatePlayOrder;
   ParamFiles.Free;
   if (fileadp >= 0) and (fileadp < Length(PlayListItems)) then
    RedrawPlaylist(fileadp,0,True)
   else
    RedrawPlaylist(0,0,True)
  end;
  if not fileadd and not Start and not Fast then
   PlayItem(0,0)
  else if fileadd and (fileadp >= 0) and (fileadp < Length(PlayListItems)) then
   PlayItem(PlayListItems[fileadp].Tag,0)
 end;
LastTimeComLine := GetTickCount
end;

procedure TForm1.SwapLan;
var
 temp:string;
begin

temp := Form2.GroupBox12.Caption;
Form2.GroupBox12.Caption := Lan_Mixer_Optimiz;
Lan_Mixer_Optimiz := temp;

temp := Form2.RadioButton26.Caption;
Form2.RadioButton26.Caption := Lan_Mixer_ForQ;
Lan_Mixer_ForQ := temp;

temp := Form2.RadioButton28.Caption;
Form2.RadioButton28.Caption := Lan_Mixer_ForP;
Lan_Mixer_ForP := temp;

temp := Form2.Label7.Caption;
Form2.Label7.Caption := Lan_Mixer_FstInt;
Lan_Mixer_FstInt := temp;

temp := Form2.Caption;
Form2.Caption := Lan_Mixer_BoxTitle;
Lan_Mixer_BoxTitle := temp;

temp := Form2.KUsil.Caption;
Form2.KUsil.Caption := Lan_Mixer_ChansAmpl;
Lan_Mixer_ChansAmpl := temp;

temp := Form2.GroupBox2.Caption;
Form2.GroupBox2.Caption := Lan_Mixer_FrqAY;
Lan_Mixer_FrqAY := temp;

temp := Form2.GroupBox1.Caption;
Form2.GroupBox1.Caption := Lan_Mixer_ChType;
Lan_Mixer_ChType := temp;

temp := Form2.GroupBox3.Caption;
Form2.GroupBox3.Caption := Lan_Mixer_SamRate;
Lan_Mixer_SamRate := temp;

temp := Form2.GroupBox4.Caption;
Form2.GroupBox4.Caption := Lan_Mixer_BitRate;
Lan_Mixer_BitRate := temp;

temp := Form2.GroupBox5.Caption;
Form2.GroupBox5.Caption := Lan_Mixer_Chans;
Lan_Mixer_Chans := temp;

temp := Form2.GroupBox7.Caption;
Form2.GroupBox7.Caption := Lan_Mixer_FrqPlr;
Lan_Mixer_FrqPlr := temp;

temp := Form2.CheckBox1.Caption;
Form2.CheckBox1.Caption := Lan_Mixer_Get;
Form2.CheckBox2.Caption := Lan_Mixer_Get;
Form2.CheckBox3.Caption := Lan_Mixer_Get;
Form2.CheckBox8.Caption := Lan_Mixer_Get;
Form2.CheckBox9.Caption := Lan_Mixer_Get;
Lan_Mixer_Get := temp;

temp := Form2.RadioButton7.Caption;
Form2.RadioButton7.Caption := Lan_Mixer_Another;
Form2.RadioButton16.Caption := Lan_Mixer_Another;
Form2.RadioButton20.Caption := Lan_Mixer_Another;
Form2.RadioButton25.Caption := Lan_Mixer_Another;
Form2.RadioButton27.Caption := Lan_Mixer_Another;
Lan_Mixer_Another := temp;

temp := Form2.GroupBox9.Caption;
Form2.GroupBox9.Caption := Lan_Mixer_FrqZ80;
Lan_Mixer_FrqZ80 := temp;

temp := Form2.Button1.Caption;
Form2.Button1.Caption := Lan_Mixer_Restore;
Lan_Mixer_Restore := temp;

temp := Form2.Button2.Caption;
Form2.Button2.Caption := Lan_Mixer_Close;
Lan_Mixer_Close := temp;

if Russian_Interface then
 begin
  Form2.StaticText15.Caption := 'Hz';
  Form2.StaticText14.Caption := 'Hz';
  Form2.StaticText10.Caption := 'Hz';
  Form2.StaticText11.Caption := 'Hz';
  Form2.StaticText12.Caption := 'Hz';
  Form2.RadioButton11.Caption := '16 bit';
  Form2.RadioButton12.Caption := '8 bit'
 end
else
 begin
  Form2.StaticText15.Caption := 'Гц';
  Form2.StaticText14.Caption := 'Гц';
  Form2.StaticText10.Caption := 'Гц';
  Form2.StaticText11.Caption := 'Гц';
  Form2.StaticText12.Caption := 'Гц';
  Form2.RadioButton11.Caption := '16 бит';
  Form2.RadioButton12.Caption := '8 бит'
 end;

temp := Form3.Caption;
Form3.Caption := Lan_List_BoxTitle;
Lan_List_BoxTitle := temp;

temp := Form3.SpeedButton1.Caption;
Form3.SpeedButton1.Caption := Lan_List_AddItems;
Lan_List_AddItems := temp;

temp := Form3.SpeedButton2.Caption;
Form3.SpeedButton2.Caption := Lan_List_ClearList;
Lan_List_ClearList := temp;

temp := Form3.SpeedButton3.Caption;
Form3.SpeedButton3.Caption := Lan_List_SaveList;
Lan_List_SaveList := temp;

temp := Form3.SpeedButton4.Caption;
Form3.SpeedButton4.Caption := Lan_List_Tools;
Lan_List_Tools := temp;

temp := Form3.PopupMenu1.Items[0].Caption;
Form3.PopupMenu1.Items[0].Caption := Lan_List_ItemAdj;
Lan_List_ItemAdj := temp;

temp := Form3.PopupMenu1.Items[2].Caption;
Form3.PopupMenu1.Items[2].Caption := Lan_List_ConvWav;
Lan_List_ConvWav := temp;

temp := Form3.PopupMenu1.Items[3].Caption;
Form3.PopupMenu1.Items[3].Caption := Lan_List_ConvZxay;
Lan_List_ConvZxay := temp;

temp := Form3.PopupMenu1.Items[4].Caption;
Form3.PopupMenu1.Items[4].Caption := Lan_List_ConvVtx;
Lan_List_ConvVtx := temp;

temp := Form3.PopupMenu1.Items[5].Caption;
Form3.PopupMenu1.Items[5].Caption := Lan_List_ConvYm6;
Lan_List_ConvYm6 := temp;

temp := Form3.PopupMenu1.Items[6].Caption;
Form3.PopupMenu1.Items[6].Caption := Lan_List_ConvPsg;
Lan_List_ConvPsg := temp;

temp := Form3.PopupMenu1.Items[7].Caption;
Form3.PopupMenu1.Items[7].Caption := Lan_List_SaveItem;
Lan_List_SaveItem := temp;

Russian_Interface := not Russian_Interface;
FillTools
end;

procedure TForm1.FillTools;
begin
if ButTools.Is_On then
 begin
 if not Russian_Interface then
  begin
  Form6.Caption := Lan_Tools_BoxTitle_En;
  Form6.GroupBox1.Caption := Lan_Tools_ConvParam_En;
  Form6.SearchTool.Caption := Lan_Tools_Searching_En;
  Form6.GroupBox3.Caption := Lan_Tools_SearchFor_En;
  Form6.GroupBox5.Caption := Lan_Tools_Prior_En;
  Form6.FTypTools.Caption := Lan_Tools_FilesReg_En;
  Form6.GroupBox10.Caption := Lan_Tools_StartMenu_En;
  Form6.GroupBox11.Caption := Lan_Tools_Tray_En;
  Form6.GroupBox12.Caption := Lan_Tools_SkTit_En;
  Form6.GroupBox13.Caption := Lan_Tools_DefDir_En;
  Form6.Label3.Caption := Lan_Tools_SourceFls_En;
  Form6.Label4.Caption := Lan_Tools_WorkFold_En;
  Form6.Label5.Caption := Lan_Tools_WorkRep_En;
  Form6.Label5.Caption := Lan_Tools_WorkRep_En;
  Form6.Label6.Caption := Lan_Tools_SkAut_En;
  Form6.Label7.Caption := Lan_Tools_SkCom_En;
  Form6.Label8.Caption := Lan_Tools_SkFN_En;
  Form6.RadioButton3.Caption := Lan_Tools_Idle_En;
  Form6.RadioButton4.Caption := Lan_Tools_Normal_En;
  Form6.RadioButton5.Caption := Lan_Tools_High_En;
  Form6.RadioButton8.Caption := Lan_Tools_Never_En;
  Form6.RadioButton9.Caption := Lan_Tools_Always_En;
  Form6.RadioButton10.Caption := Lan_Tools_Minim_En;
  Form6.Button1.Caption := Lan_Tools_Choose_En;
  Form6.Button2.Caption := Lan_Tools_Choose_En;
  Form6.Button3.Caption := Lan_Tools_Begin_En;
  Form6.Button7.Caption := Lan_Tools_RemoveEmu_En;
  Form6.Button8.Caption := Lan_Tools_Apply_En;
  Form6.Button16.Caption := Lan_Tools_Apply_En;
  Form6.Button9.Caption := Lan_Tools_Restore_En;
  Form6.Button10.Caption := Lan_Tools_Add_En;
  Form6.Button11.Caption := Lan_Tools_Remove_En;
  Form6.Button12.Caption := Lan_Tools_Choose_En;
  Form6.Button13.Caption := Lan_Tools_SkStd_En;
  Form6.Button14.Caption := Lan_Tools_Save_En;
  Form6.CheckBox38.Caption := Lan_Tools_AutoSave_En
  end
 else
  begin
  Form6.Caption := Lan_Tools_BoxTitle_Ru;
  Form6.GroupBox1.Caption := Lan_Tools_ConvParam_Ru;
  Form6.SearchTool.Caption := Lan_Tools_Searching_Ru;
  Form6.GroupBox3.Caption := Lan_Tools_SearchFor_Ru;
  Form6.GroupBox5.Caption := Lan_Tools_Prior_Ru;
  Form6.FTypTools.Caption := Lan_Tools_FilesReg_Ru;
  Form6.GroupBox10.Caption := Lan_Tools_StartMenu_Ru;
  Form6.GroupBox11.Caption := Lan_Tools_Tray_Ru;
  Form6.GroupBox12.Caption := Lan_Tools_SkTit_Ru;
  Form6.GroupBox13.Caption := Lan_Tools_DefDir_Ru;
  Form6.Label3.Caption := Lan_Tools_SourceFls_Ru;
  Form6.Label4.Caption := Lan_Tools_WorkFold_Ru;
  Form6.Label5.Caption := Lan_Tools_WorkRep_Ru;
  Form6.Label6.Caption := Lan_Tools_SkAut_Ru;
  Form6.Label7.Caption := Lan_Tools_SkCom_Ru;
  Form6.Label8.Caption := Lan_Tools_SkFN_Ru;
  Form6.RadioButton3.Caption := Lan_Tools_Idle_Ru;
  Form6.RadioButton4.Caption := Lan_Tools_Normal_Ru;
  Form6.RadioButton5.Caption := Lan_Tools_High_Ru;
  Form6.RadioButton8.Caption := Lan_Tools_Never_Ru;
  Form6.RadioButton9.Caption := Lan_Tools_Always_Ru;
  Form6.RadioButton10.Caption := Lan_Tools_Minim_Ru;
  Form6.Button1.Caption := Lan_Tools_Choose_Ru;
  Form6.Button2.Caption := Lan_Tools_Choose_Ru;
  Form6.Button3.Caption := Lan_Tools_Begin_Ru;
  Form6.Button7.Caption := Lan_Tools_RemoveEmu_Ru;
  Form6.Button8.Caption := Lan_Tools_Apply_Ru;
  Form6.Button16.Caption := Lan_Tools_Apply_Ru;
  Form6.Button9.Caption := Lan_Tools_Restore_Ru;
  Form6.Button10.Caption := Lan_Tools_Add_Ru;
  Form6.Button11.Caption := Lan_Tools_Remove_Ru;
  Form6.Button12.Caption := Lan_Tools_Choose_Ru;
  Form6.Button13.Caption := Lan_Tools_SkStd_Ru;
  Form6.Button14.Caption := Lan_Tools_Save_Ru;
  Form6.CheckBox38.Caption := Lan_Tools_AutoSave_Ru
  end;
  Form6.Button4.Caption := Form2.Button2.Caption
 end
end;

procedure TForm1.SetPriority(Pr:longword);
var
 HMyProcess:longword;
begin
HMyProcess := GetCurrentProcess;
SetPriorityClass(HMyProcess,Pr);
CloseHandle(HMyProcess);
Priority := Pr
end;

procedure TForm1.Set_Chip_Frq2;
begin
if Fr <> AY_Freq then
 begin
  Set_Chip_Frq(Fr);
  Form2.FrqAYTemp := AY_Freq;
  Form2.Set_Frqs
 end
end;

procedure TForm1.Set_Chip_Frq(Fr:integer);
begin
if (Fr >= 1000000) and (Fr <= 3500000) then
 begin
  SuspendPlaying;
  try
  AY_Freq := Fr;
  CalculateSpectrumPoints;
  if MFPTimerMode = 0 then
   MFPTimerFrq := round(AY_Freq * 16 / 13);
  Delay_In_Tiks := round(8192/SampleRate * AY_Freq);
  FrqAyByFrqZ80 := round(AY_Freq/FrqZ80/8 * 4294967296);
  Tik.Re := Delay_In_Tiks;
  AY_Tiks_In_Interrupt := round(AY_Freq/(Interrupt_Freq/1000 * 8));
  YM6TiksOnInt := AY_Freq/(Interrupt_Freq/1000 * 8);
  SetFilter(FilterQuality);
  if IsPlaying then
   begin
    Form2.Edit18.Text := IntToStr(AY_Freq);
    Form2.Edit26.Text := IntToStr(MFPTimerFrq)
   end
  finally
   WOUnresetPlaying
  end
 end
end;

procedure TForm1.Set_MFP_Frq;
begin
SuspendPlaying;
try
if Md = 0 then
 begin
  MFPTimerMode := 0;
  MFPTimerFrq := round(AY_Freq * 16 / 13)
 end
else
 if (Fr >= 1000000) and (Fr <= 3000000) then
  begin
   MFPTimerMode := 1;
   MFPTimerFrq := Fr
  end;
if IsPlaying then
 Form2.Edit26.Text := IntToStr(MFPTimerFrq)
finally
 WOUnresetPlaying
end
end;

procedure TForm1.ButMixerClick(Sender: TObject);
begin
if ButMixer.Is_On then
 ButMixer.Switch_Off
else
 ButMixer.Is_On := True;
Form2.Visible := ButMixer.Is_On
end;

procedure TForm1.Set_Z80_Frq;
begin
if (NewF >= 1000000) and (NewF <= 8000000) then
 begin
  SuspendPlaying;
  try
  if (FrqZ80 <> NewF) and FileAvailable and
     (CurFileType in [OUTFile,ZXAYFile,AYFile,AYMFile,EPSGFile]) then
   begin
    Time_ms := round(Time_ms/NewF*FrqZ80);
    ProgrMax := round(Time_ms/1000*SampleRate);
    VProgrPos := round(VProgrPos/NewF*FrqZ80)
   end;
  FrqZ80 := NewF;
  FrqAyByFrqZ80 := round(AY_Freq/FrqZ80/8*4294967296);
  SampleRateByFrqZ80 := round(SampleRate/FrqZ80*4294967296)
  finally
   WOUnresetPlaying
  end;
  RedrawPlaylist(ShownFrom,0,False);
  CalculateTotalTime(False)
 end
end;

procedure TForm1.Set_Z80_Frq2;
begin
if NewF <> FrqZ80 then
 begin
  Set_Z80_Frq(NewF);
  Form2.Set_Z80Frqs
 end 
end;

procedure TForm1.Set_N_Tact(NewF:integer);
begin
if (NewF > 9999) and (NewF <= 200000) then
 begin
  SuspendPlaying;
  try
  if (MaxTStates <> NewF) and FileAvailable and
     (CurFileType in [AYFile,AYMFile]) then
   begin
    Time_ms := round(Time_ms/MaxTStates*NewF);
    ProgrMax := round(Time_ms/1000*SampleRate);
    VProgrPos := round(VProgrPos/MaxTStates*NewF)
   end;
  MaxTStates := NewF;
  if IntOffset >= MaxTStates then
   begin
    IntOffset := MaxTStates - 1;
    Form2.FTact.Text := IntToStr(IntOffset)
   end
  finally
   WOUnresetPlaying
  end;
  RedrawPlaylist(ShownFrom,0,False);
  CalculateTotalTime(False)
 end
end;

procedure TForm1.Set_N_Tact2;
begin
if NT <> MaxTStates then
 begin
  Set_N_Tact(NT);
  Form2.Edit19.Text := IntToStr(MaxTStates)
 end
end;

procedure TForm1.Set_N_TactS;
var
 V,ErrPos:integer;
begin
Val(t,V,ErrPos);
if ErrPos = 0 then Set_N_Tact2(V)
end;

procedure TForm1.Set_Sample_Rate2;
begin
if (SR <> SampleRate) and not IsPlaying then
 begin
  Set_Sample_Rate(SR);
  Form2.SetSRs
 end
end;

procedure Set_Sample_Rate(SR:integer);
begin
if not ((SR >= 8000) and (SR < 300000)) then exit;
SampleRate := SR;
VisStep := round(SampleRate/100);
BufferLength := round(BufLen_ms * SampleRate / 1000);
VisPosMax := round(BufferLength * NumberOfBuffers / VisStep) + 1;
VisTickMax := VisStep * VisPosMax;
SetLength(VisPoints,VisPosMax);
Delay_In_Tiks := round(8192/SampleRate*AY_Freq);
YM6SamTiksOnInt := SampleRate/Interrupt_Freq*1000;
Sample_Tiks_in_Interrupt := round(SampleRate/Interrupt_Freq*1000);
SampleRateByFrqZ80 := round(SampleRate/FrqZ80*4294967296);
Form1.SetFilter(FilterQuality)
end;

procedure SetSynthesizer;
begin
if Optimization_For_Quality then
 begin
  if NumberOfChannels = 2 then
   begin
    if SampleBit = 8 then
     Synthesizer := Synthesizer_Stereo8
    else
     Synthesizer := Synthesizer_Stereo16;
   end
  else if SampleBit = 8 then
   Synthesizer := Synthesizer_Mono8
  else
   Synthesizer := Synthesizer_Mono16
 end
else
 begin
  if NumberOfChannels = 2 then
   begin
    if SampleBit = 8 then
     Synthesizer := Synthesizer_Stereo8_P
    else
     Synthesizer := Synthesizer_Stereo16_P
   end
  else if SampleBit = 8 then
   Synthesizer := Synthesizer_Mono8_P
  else
   Synthesizer := Synthesizer_Mono16_P;
 end;
Calculate_Level_Tables 
end;

procedure TForm1.Set_Sample_Bit2;
begin
if (SampleBit <> SB) and ((SB = 16) or (SB = 8)) and not IsPlaying then
 begin
  Set_Sample_Bit(SB);
  case SB of
  16:Form2.RadioButton11.Checked := True;
  8:Form2.RadioButton12.Checked := True
  end
 end 
end;

procedure Set_Sample_Bit(SB:integer);
begin
SampleBit := SB;
SetSynthesizer
end;

procedure TForm1.Set_Stereo2;
begin
if (St <> NumberOfChannels) and (St in [1,2]) and not IsPlaying then
 begin
  Set_Stereo(St);
  case St of
  1:Form2.RadioButton14.Checked := True;
  2:Form2.RadioButton13.Checked := True
  end
 end
end;

procedure Set_Stereo(St:integer);
begin
NumberOfChannels := St;
SetSynthesizer
end;

procedure TForm1.SetOptimization2;
begin
if Optimization_For_Quality = Q then exit;
SetOptimization(Q);
with Form2 do
 begin
  if Q then
   RadioButton26.Checked := True
  else
   RadioButton28.Checked := True;
  TrackBar14.Visible := Q;
  Label12.Visible := Q;
  Label13.Visible := Q
 end
end;

procedure SetOptimization;
begin
SuspendPlaying;
try
Optimization_For_Quality := Q;
if Q then
 begin
  AtariTimerPeriod1 := AtariTimerPeriod1/SampleRate*(AY_Freq / 8);
  AtariTimerPeriod2 := AtariTimerPeriod2/SampleRate*(AY_Freq / 8);
  AtariTimerCounter1 := AtariTimerCounter1/SampleRate*(AY_Freq / 8);
  AtariTimerCounter2 := AtariTimerCounter2/SampleRate*(AY_Freq / 8);
  YM6CurTik := YM6CurTik/SampleRate*(AY_Freq / 8);
  Current_Tik := round(Current_Tik/SampleRate*(AY_Freq / 8));
  Number_Of_Tiks.Re := round(Number_Of_Tiks.Re/SampleRate*(AY_Freq / 8))
 end
else
 begin
  AtariTimerPeriod1 := AtariTimerPeriod1/(AY_Freq / 8) * SampleRate;
  AtariTimerPeriod2 := AtariTimerPeriod2/(AY_Freq / 8) * SampleRate;
  AtariTimerCounter1 := AtariTimerCounter1/(AY_Freq / 8) * SampleRate;
  AtariTimerCounter2 := AtariTimerCounter2/(AY_Freq / 8) * SampleRate;
  YM6CurTik := YM6CurTik/(AY_Freq / 8) * SampleRate;
  Current_Tik := round(Current_Tik/(AY_Freq / 8) * SampleRate);
  Number_Of_Tiks.Re:=round(Number_Of_Tiks.Re/(AY_Freq / 8) * SampleRate)
 end;
SetSynthesizer
finally
 WOUnresetPlaying
end
end;

procedure TForm1.ShowAllParams;
begin
Form2.Edit12.Text := IntToStr(Index_AL);
Form2.Edit13.Text := IntToStr(Index_AR);
Form2.Edit14.Text := IntToStr(Index_BL);
Form2.Edit15.Text := IntToStr(Index_BR);
Form2.Edit16.Text := IntToStr(Index_CL);
Form2.Edit17.Text := IntToStr(Index_CR);
Form2.Edit18.Text := IntToStr(AY_Freq);
Form2.Edit23.Text := FloatToStrF(Interrupt_Freq/1000,ffFixed,7,3);
Form2.Edit26.Text := IntToStr(MFPTimerFrq);
if ChType = AY_Chip then
 Form2.CheckBox4.Checked := True
else
 Form2.CheckBox5.Checked := True;
if NumberOfChannels = 2 then
 Form2.CheckBox7.Checked := True
else
 Form2.CheckBox6.Checked := True
end;

procedure TForm1.RestoreAllParams;
begin
with Form2 do
 begin
  if RadioButton2.Checked then
   ChType := YM_Chip
  else
   ChType := AY_Chip;
  SetChan2(TrackBar1.Position,0);
  SetChan2(TrackBar2.Position,1);
  SetChan2(TrackBar3.Position,2);
  SetChan2(TrackBar4.Position,3);
  SetChan2(TrackBar5.Position,4);
  SetChan2(TrackBar6.Position,5);
  Set_Chip_Frq(FrqAYTemp);
  Set_Player_Frq(FrqPlTemp);
  if RadioButton13.Checked then
   Set_Stereo(2)
  else
   Set_Stereo(1)
 end
end;

procedure TForm1.ButListClick(Sender: TObject);
begin
if ButList.Is_On then
 ButList.Switch_Off
else
 ButList.Is_On := True;
Form3.Visible := ButList.Is_On
end;

procedure TForm1.ButNextClick(Sender: TObject);
begin
ButNext.UnPush;
Form3.PlayNextItem
end;

procedure TForm1.ButPrevClick(Sender: TObject);
begin
ButPrev.UnPush;
Form3.PlayPreviousItem
end;

procedure TForm1.WMPLAYNEXTITEM;
var
 Flg:boolean;
begin
if CurFileType <> CDAFile then
 StopPlaying
else
 begin
  IsPlaying := False;
  Reseted := 0;
  Paused := False;
  RestoreControls
 end;
Flg := (Direction = 3) and (not ListLooped);
if not Flg then
 begin
  if Direction <> 3 then
   begin
    Form3.PlayNextItem;
    Flg := PlayingItem >= Length(PlayListItems) - 1
   end
  else
   PlayCurrent;
 end;
if not IsPlaying and Flg then
 begin
  FreeBASS;
  UnloadBASS;
  CloseCDDevice(CurCDNum)
 end
end;

procedure TForm1.Set_Mode_Manual(AL,AR,BL,BR,CL,CR:byte);
begin
Index_AL := AL; Index_AR := AR;
Index_BL := BL; Index_BR := BR;
Index_CL := CL; Index_CR := CR;
Calculate_Level_Tables
end;

procedure TForm1.Set_Mode(It:Integer);
var
 Echo:integer;
begin
if It > 0 then
 begin
  if ChType = AY_Chip then Echo := 85 else Echo := 13;
  case It of
  1: begin
      Index_AL := 255; Index_AR := Echo;
      Index_BL := 170; Index_BR := 170;
      Index_CL := Echo; Index_CR := 255
     end;
  2: begin
      Index_AL :=255; Index_AR := Echo;
      Index_BL :=Echo; Index_BR := 255;
      Index_CL :=170; Index_CR := 170
     end;
  3: begin
      Index_AL :=170; Index_AR := 170;
      Index_BL :=255; Index_BR := Echo;
      Index_CL :=Echo; Index_CR := 255
     end;
  4: begin
      Index_AL :=Echo; Index_AR := 255;
      Index_BL :=255; Index_BR := Echo;
      Index_CL :=170; Index_CR := 170
     end;
  5: begin
      Index_AL := 170; Index_AR := 170;
      Index_BL := Echo; Index_BR := 255;
      Index_CL := 255; Index_CR := Echo
     end;
  6: begin
      Index_AL := Echo; Index_AR := 255;
      Index_BL := 170; Index_BR := 170;
      Index_CL := 255; Index_CR := Echo
     end
   end
 end
else
 begin
  Index_AL := 255; Index_AR := 255;
  Index_BL := 255; Index_BR := 255;
  Index_CL := 255; Index_CR := 255
 end;
Calculate_Level_Tables
end;

procedure TForm1.Set_Player_Frq2;
begin
if Fr <> Interrupt_Freq then
 begin
  Set_Player_Frq(Fr);
  Form2.FrqPlTemp := Interrupt_Freq;
  Form2.Set_Pl_Frqs;
  RedrawPlaylist(ShownFrom,0,False);
  CalculateTotalTime(False)
 end
end;

procedure TForm1.Set_Player_Frq;
begin
if (Fr >= 1000) and (Fr <= 2000000) and (Interrupt_Freq <> Fr) then
 begin
  SuspendPlaying;
  try
  if (Interrupt_Freq <> Fr) and FileAvailable and
                       (CurFileType in [MinVBLType..MaxVBLType])then
   begin
    Time_ms := round(Time_ms/Fr*Interrupt_Freq);
    ProgrMax := round(Time_ms/1000*SampleRate);
    VProgrPos := round(VProgrPos/Fr*Interrupt_Freq)
   end;
  Interrupt_Freq := Fr;
  if IsPlaying then
   Form2.Edit23.Text := FloatToStrF(Interrupt_Freq/1000,ffFixed,70,3);
  YM6SamTiksOnInt := SampleRate/Interrupt_Freq*1000;
  Sample_Tiks_in_Interrupt := round(SampleRate/Interrupt_Freq*1000);
  AY_Tiks_In_Interrupt := round(AY_Freq/(Interrupt_Freq/1000*8));
  YM6TiksOnInt := AY_Freq/(Interrupt_Freq/1000*8);
  finally
   WOUnresetPlaying
  end;
 end
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 p:PSensZone;
 p1:PMoveZone;
 p2:PButtZone;
 OfsR:integer;
 r:TRect;
begin
if ssDouble in Shift then
 if (X >= scr_x) and (X < scr_x + scr_width) and
    (Y >= scr_y) and (Y < scr_y + scr_height) then
  begin
   Do_Scroll := not Do_Scroll;
   exit
  end;

if Button = mbLeft then
 begin
  if MoveWin.Touche(X,Y) then
   begin
    SystemParametersInfo(SPI_GETWORKAREA,0,@r,0);
    ClipCursor(@r)
   end;
  p := SensZoneRoot;
  while p <> nil do
   begin
    if p.Touche(X,Y) then
     p.Clicked := True;
    p := p.Next
   end;
  p2 := ButtZoneRoot;
  while p2 <> nil do
   begin
    if (p2.Clicked = 0) and p2.Touche(X,Y) then
     begin
      p2.Clicked := 1;
      p2.Push
     end;
    p2 := p2.Next
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    if p1.Bmps then
     begin
      if p1.ToucheBut(X,Y) then
       begin
        p1.OldX := X;
        p1.Delt := X - p1.posX;
        p1.Clicked := True
       end
      else if p1.Touche(X,Y) then
       begin
        p1.Clicked := True;
        OfsR := X - p1.zx - p1.bm1w div 2;
        if OfsR > p1.zw - p1.bm1w then
         OfsR := p1.zw - p1.bm1w
        else if OfsR < 0 then
         OfsR := 0;
        if OfsR <> p1.PosX then
         begin
          p1.HideBmp;
          OffsetRgn(p1.RgnHandle,OfsR - p1.PosX,0);
          p1.PosX := OfsR;
          p1.Redraw(False);
          p1.Action(Self)
         end;
        p1.OldX := X;
        p1.Delt := X - p1.posX
       end
     end
    else if p1.Touche(X,Y) then
     begin
      p1.OldX := X;
      p1.OldY := Y;
      p1.Clicked := True
     end;
    p1 := p1.Next
   end
 end
end;

procedure TForm1.ButToolsClick(Sender: TObject);
begin
if not ButTools.Is_On then
 begin
 ButTools.Is_On := True;
 FinderWorksNow := False;
 Form6 := TForm6.Create(Self);
 with Form6 do
  begin
   AppIcSel := TIconSelector.Create(GenTools);
   AppIcSel.DoSelectIcon := SelectAppIcon;
   AppIcSel.IcGrp.Top := 227;
   AppIcSel.IcGrp.Left := 210;
   AppIcSel.IcGrp.Caption := 'Application icon';
   AppIcSel.IconUpDown.Position := AppIconNumber;
   AppIcSel.ShowIcon;

   TrayIcSel := TIconSelector.Create(GenTools);
   TrayIcSel.DoSelectIcon := SelectTrayIcon;
   TrayIcSel.IcGrp.Top := 227;
   TrayIcSel.IcGrp.Left := 108;
   TrayIcSel.IcGrp.Caption := 'Tray icon';
   TrayIcSel.IconUpDown.Position := TrayIconNumber;
   TrayIcSel.ShowIcon;

   StartIcSel := TIconSelector.Create(GenTools);
   StartIcSel.DoSelectIcon := SelectMenuIcon;
   StartIcSel.IcGrp.Top := 227;
   StartIcSel.IcGrp.Left := 6;
   StartIcSel.IcGrp.Caption := '''Start'' menu icon';
   StartIcSel.IconUpDown.Position := MenuIconNumber;
   StartIcSel.ShowIcon;

   MusIcSel := TIconSelector.Create(FTypTools);
   MusIcSel.DoSelectIcon := SelectMusIcon;
   MusIcSel.IcGrp.Top := 10;
   MusIcSel.IcGrp.Left := 10;
   MusIcSel.IcGrp.Caption := 'Music files icon';
   MusIcSel.IconUpDown.Position := MusIconNumber;
   MusIcSel.ShowIcon;

   SkinIcSel := TIconSelector.Create(FTypTools);
   SkinIcSel.DoSelectIcon := SelectSkinIcon;
   SkinIcSel.IcGrp.Top := 190;
   SkinIcSel.IcGrp.Left := 10;
   SkinIcSel.IcGrp.Caption := 'Skin files icon';
   SkinIcSel.IconUpDown.Position := SkinIconNumber;
   SkinIcSel.ShowIcon;

   ListIcSel := TIconSelector.Create(FTypTools);
   ListIcSel.DoSelectIcon := SelectListIcon;
   ListIcSel.IcGrp.Top := 100;
   ListIcSel.IcGrp.Left := 10;
   ListIcSel.IcGrp.Caption := 'Playlists icon';
   ListIcSel.IconUpDown.Position := ListIconNumber;
   ListIcSel.ShowIcon;

   BASSIcSel := TIconSelector.Create(FTypTools);
   BASSIcSel.DoSelectIcon := SelectBASSIcon;
   BASSIcSel.IcGrp.Top := 100;
   BASSIcSel.IcGrp.Left := 200;
   BASSIcSel.IcGrp.Caption := 'BASS files icon';
   BASSIcSel.IconUpDown.Position := BASSIconNumber;
   BASSIcSel.ShowIcon;

   FillTools;
   Edit1.Text := SkinAuthor;
   Edit2.Text := SkinComment;
   Edit3.Text := SkinFileName;
   Edit4.Text := DefaultDirectory;
   CheckBox38.Checked := AutoSaveDefDir;
   CheckBox40.Checked := AutoSaveWindowsPos;
   if (OpenDialog1.InitialDir<>'') and
      (OpenDialog1.InitialDir[Length(OpenDialog1.InitialDir)]<>'\') then
    DName.Text:=OpenDialog1.InitialDir+'\'
   else
    DName.Text:=OpenDialog1.InitialDir;
   DName.Text:=DName.Text+'AY Finder Temporary Folder';
   case Priority of
   IDLE_PRIORITY_CLASS:RadioButton3.Checked:=True;
   NORMAL_PRIORITY_CLASS:RadioButton4.Checked:=True;
   HIGH_PRIORITY_CLASS:RadioButton5.Checked:=True;
   end;
   case TrayMode of
   0:RadioButton8.Checked:=True;
   1:RadioButton9.Checked:=True;
   2:RadioButton10.Checked:=True;
   end;
   if Russian_Interface then RadioButton6.Checked:=True
   else RadioButton7.Checked:=True;
   CheckBox29.Checked := FIDO_Descriptor_Enabled;
   CheckBox42.Checked := FIDO_Descriptor_KillOnNothing;
   CheckBox41.Checked := FIDO_Descriptor_KillOnExit;
   CheckBox43.Checked := FIDO_Descriptor_WinEnc;
   Edit6.Text := FIDO_Descriptor_Prefix;
   Edit7.Text := FIDO_Descriptor_Suffix;
   Edit8.Text := FIDO_Descriptor_Nothing;
   Edit5.Text := FIDO_Descriptor_Filename;
   Label1.Color := PLColorBk;
   Label1.Font.Color := PLColor;
   Label12.Color := PLColorBk;
   Label12.Font.Color := PLColor;
   Label13.Color := PLColorBkSel;
   Label13.Font.Color := PLColorSel;
   Label14.Color := PLColorBkSel;
   Label14.Font.Color := PLColorSel;
   Label15.Color := PLColorBkPl;
   Label15.Font.Color := PLColorPl;
   Label16.Color := PLColorBkPl;
   Label16.Font.Color := PLColorPl;
   Label17.Color := PLColorBkSel;
   Label17.Font.Color := PLColorPlSel;
   Label18.Color := PLColorBk;
   Label18.Font.Color := PLColorErr;
   Label19.Color := PLColorBkSel;
   Label19.Font.Color := PLColorErrSel;
   SetIfRegPath;
   STC_Registered := CheckRegistration('.stc',0);
   STP_Registered := CheckRegistration('.stp',0);
   ASC_Registered := CheckRegistration('.asc',0);
   PSC_Registered := CheckRegistration('.psc',0);
   SQT_Registered := CheckRegistration('.sqt',0);
   AYL_Registered := CheckRegistration('.ayl',1);
   PT1_Registered := CheckRegistration('.pt1',0);
   PT2_Registered := CheckRegistration('.pt2',0);
   PT3_Registered := CheckRegistration('.pt3',0);
   FTC_Registered := CheckRegistration('.ftc',0);
   FLS_Registered := CheckRegistration('.fls',0);
   GTR_Registered := CheckRegistration('.gtr',0);
   FXM_Registered := CheckRegistration('.fxm',0);
   PSM_Registered := CheckRegistration('.psm',0);
   M3U_Registered := CheckRegistration('.m3u',1);
   OUT_Registered := CheckRegistration('.out',0);
   ZXAY_Registered := CheckRegistration('.zxay',0);
   PSG_Registered := CheckRegistration('.psg',0);
   VTX_Registered := CheckRegistration('.vtx',0);
   AY_Registered := CheckRegistration('.ay',0);
   AYM_Registered := CheckRegistration('.aym',0);
   YM_Registered := CheckRegistration('.ym',0);
   AYS_Registered := CheckRegistration('.ays',2);
   MP3_Registered := CheckRegistration('.mp3',3);
   MP2_Registered := CheckRegistration('.mp2',3);
   MP1_Registered := CheckRegistration('.mp1',3);
   OGG_Registered := CheckRegistration('.ogg',3);
   WAV_Registered := CheckRegistration('.wav',3);
   MO3_Registered := CheckRegistration('.mo3',3);
   IT_Registered := CheckRegistration('.it',3);
   XM_Registered := CheckRegistration('.xm',3);
   S3M_Registered := CheckRegistration('.s3m',3);
   MTM_Registered := CheckRegistration('.mtm',3);
   MOD_Registered := CheckRegistration('.mod',3);
   UMX_Registered := CheckRegistration('.umx',3);
   WMA_Registered := CheckRegistration('.wma',3);
   CDA_Registered := CheckRegistration('.cda',0);
   SetRegInfo
  end;
 end
else if not FinderWorksNow then PostMessage(Form6.Handle,WM_CLOSE,0,0)
end;

procedure MainWinRepaint(DC:HDC);
var
 p:PButtZone;
 p1:PMoveZone;
 p2:PLedZone;
begin
if LedZoneRoot <> nil then
 begin
  p2 := LedZoneRoot;
  repeat
   p2.Redraw(True);
   p2 := p2.Next
  until p2 = nil
 end;
if ButtZoneRoot <> nil then
 begin
  p := ButtZoneRoot;
  repeat
   p.Redraw(True);
   p := p.Next
  until p = nil
 end;
if MoveZoneRoot <> nil then
 begin
  p1 := MoveZoneRoot;
  repeat
   p1.Redraw(True);
   p1 := p1.Next
  until p1 = nil
 end;
BitBlt(DC_DBuffer,scr_x,scr_y,scr_width,scr_height,DC_Scroll,0,0,SRCCOPY);
BitBlt(DC_DBuffer,time_x,time_y,time_width,time_height,DC_Time,0,0,SRCCOPY);
BitBlt(DC,0,0,MWWidth,MWHeight,DC_DBuffer,0,0,SRCCOPY)
end;

procedure TForm1.ButLoopClick(Sender: TObject);
begin
if ButLoop.Is_On then
 ButLoop.Switch_Off
else
 ButLoop.Is_On := True;
Do_Loop := ButLoop.Is_On
end;

constructor TSensZone.Create(ps:PSensZone;x,y,w,h:integer;pr:TNotifyEvent);
var
 p:PSensZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
if SensZoneRoot = nil then
 SensZoneRoot := ps
else
 begin
  p := SensZoneRoot;
  while p.Next <> nil do p := p.Next;
  p.Next := ps
 end;
Next := nil;
Clicked := False;
Action := pr
end;

function TSensZone.Touche(x,y:integer):boolean;
begin
Result := (x >= zx) and (x < zx + zw) and (y >= zy) and (y < zy + zh)
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 p:PButtZone;
 p1:PMoveZone;
 OfsR:integer;
begin
if ssShift in Shift then Shift := Shift - [ssShift];
if [ssLeft] = Shift then
 begin
  p := ButtZoneRoot;
  while p <> nil do
   begin
    if (p.Clicked = 1) and not p.Is_On then
     if p.Touche(X,Y) then
      p.Push
     else
      p.UnPush;
    p := p.Next
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    if p1.Clicked then
     begin
      if p1.Bmps then
       begin
        OfsR := p1.posX + X - p1.OldX;
        p1.OldX := X;
        if OfsR < 0 then
         begin
          p1.OldX := p1.Delt;
          OfsR := 0
         end
        else if OfsR > p1.zw - p1.bm1w then
         begin
          OfsR := p1.zw - p1.bm1w;
          p1.OldX := OfsR + p1.Delt
         end;
        if OfsR <> p1.PosX then
         begin
          p1.HideBmp;
          OffsetRgn(p1.RgnHandle,OfsR - p1.PosX,0);
          p1.PosX := OfsR;
          p1.Redraw(False);
          p1.Action(Self)
         end
       end
      else
       begin
        p1.PosX := X - p1.OldX;
        p1.PosY := Y - p1.OldY;
        p1.Action(Self)
       end
     end;
    p1 := p1.Next
   end
 end
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 p:PSensZone;
 p1:PMoveZone;
 p2:PButtZone;
begin
if not (ssLeft in Shift) then
 begin
  ClipCursor(nil);
  p := SensZoneRoot;
  while p <> nil do
   begin
    if p.Clicked then
     begin
      if p.Touche(X,Y) then
       p.Action(Self);
      p.Clicked := False
     end;
    p := p.Next
   end;
  p2 := ButtZoneRoot;
  while p2 <> nil do
   begin
    if p2.Clicked = 1 then
     begin
      if p2.Touche(X,Y) then
       p2.Action(Self);
      p2.Clicked := 0
     end;
    p2 := p2.Next
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    if p1.Clicked then
     begin
      p1.Clicked := False;
      p1.Action(Self)
     end;
    p1 := p1.Next
   end
 end  
end;

constructor TButtZone.Create;
var
 p:PButtZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
RgnHandle := rh;
if ButtZoneRoot = nil then
 ButtZoneRoot := ps
else
 begin
  p := ButtZoneRoot;
  while p.Next <> nil do p := p.Next;
  p.Next := ps
 end;
Next := nil;
Is_On := False;
Is_Pushed := False;
Clicked := 0;
Action := pr;
DC1 := CreateCompatibleDC(DC_Window);
Bmp1 := SelectObject(DC1,CreateCompatibleBitmap(DC_Window,zw,zh));
BitBlt(DC1,0,0,zw,zh,DC_Bmp,x1,y1,SRCCOPY);
DC2 := CreateCompatibleDC(DC_Window);
Bmp2 := SelectObject(DC2,CreateCompatibleBitmap(DC_Window,zw,zh));
BitBlt(DC2,0,0,zw,zh,DC_Bmp,x2,y2,SRCCOPY)
end;

function TButtZone.Touche(x,y:integer):boolean;
begin
if RgnHandle <> 0 then
 Result := PtInRegion(RgnHandle,x,y)
else
 Result := (x >= zx) and (x < zx + zw) and (y >= zy) and (y < zy + zh)
end;

procedure TButtZone.Free;
begin
DeleteObject(SelectObject(DC1,Bmp1));
DeleteDC(DC1);
DeleteObject(SelectObject(DC2,Bmp2));
DeleteDC(DC2);
inherited
end;

procedure TButtZone.Redraw(OnCanvas:boolean);
begin
if OnCanvas then
 begin
 if not Is_Pushed then
  BitBlt(DC_DBuffer,zx,zy,zw,zh,DC1,0,0,SRCCOPY)
 else
  BitBlt(DC_DBuffer,zx,zy,zw,zh,DC2,0,0,SRCCOPY)
 end
else
 begin
 if not Is_Pushed then
  BitBlt(DC_Window,zx,zy,zw,zh,DC1,0,0,SRCCOPY)
 else
  BitBlt(DC_Window,zx,zy,zw,zh,DC2,0,0,SRCCOPY)
 end
end;

procedure TButtZone.Push;
begin
if not Is_Pushed then
 begin
  Is_Pushed := True;
  Redraw(False)
 end
end;

procedure TButtZone.UnPush;
begin
if Is_Pushed then
 begin
  Is_Pushed := False;
  Redraw(False)
 end
end;

procedure TButtZone.Switch_On;
begin
if not Is_On then
 Is_On := True;
Push
end;

procedure TButtZone.Switch_Off;
begin
if Is_On then
 Is_On := False;
UnPush
end;

constructor TLedZone.Create;
var
 p:PLedZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
if LedZoneRoot = nil then
 LedZoneRoot := ps
else
 begin
  p := LedZoneRoot;
  while p.Next <> nil do p := p.Next;
  p.Next := ps
 end;
Next := nil;
State := False;
DC1 := CreateCompatibleDC(DC_Window);
Bmp1 := SelectObject(DC1,CreateCompatibleBitmap(DC_Window,zw,zh));
BitBlt(DC1,0,0,zw,zh,DC_Bmp,x1,y1,SRCCOPY);
DC2 := CreateCompatibleDC(DC_Window);
Bmp2 := SelectObject(DC2,CreateCompatibleBitmap(DC_Window,zw,zh));
BitBlt(DC2,0,0,zw,zh,DC_Bmp,x2,y2,SRCCOPY)
end;

procedure TLedZone.Redraw(OnCanvas:boolean);
begin
if OnCanvas then
 begin
 if not State then
  BitBlt(DC_DBuffer,zx,zy,zw,zh,DC1,0,0,SRCCOPY)
 else
  BitBlt(DC_DBuffer,zx,zy,zw,zh,DC2,0,0,SRCCOPY)
 end
else
 begin
 if not State then
  BitBlt(DC_Window,zx,zy,zw,zh,DC1,0,0,SRCCOPY)
 else
  BitBlt(DC_Window,zx,zy,zw,zh,DC2,0,0,SRCCOPY)
 end
end;

procedure TLedZone.Free;
begin
DeleteObject(SelectObject(DC1,Bmp1));
DeleteDC(DC1);
DeleteObject(SelectObject(DC2,Bmp2));
DeleteDC(DC2);
inherited
end;

procedure TForm1.ButCloseClick(Sender: TObject);
begin
Close
end;

procedure TForm1.ButAboutClick(Sender: TObject);
begin
{$ifdef beta}
{MessageBox(Handle,'AY Emulator'#13'Version ' + VersionString + IsBeta +
                BetaNumber + #13+
                'Author Sergey Bulba'#13'Design Ivan Reshetnikov'+
                #13'Compiled at ' + CompilS + #13'(c)1999-' +
                CompilYs + ' S.V.Bulba'#13'http://bulba.at.kz/',
                'About program',mb_OK);}
{$endif}
  with TAboutBox.Create(Self) do
  try
   {$ifdef beta}
   AbDBuffer.Canvas.TextOut(100,236,IsBeta + BetaNumber);
   {$endif}
   ShowModal;
  finally
   Free;
   ButAbout.UnPush
  end
end;

procedure TForm1.ButSpaClick(Sender: TObject);
begin
SpectrumChecked := not SpectrumChecked
end;

procedure TForm1.ButAmpClick(Sender: TObject);
begin
IndicatorChecked := not IndicatorChecked
end;

procedure TForm1.ButTimeClick(Sender: TObject);
begin
Inc(TimeMode);
if TimeMode > 2 then TimeMode := 0
end;

constructor TMoveZone.Create(ps:PMoveZone;x,y,w,h,y1,h1,rh:integer;
                                                        pr:TNotifyEvent);
var
 p:PMoveZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
zy1 := y1; zh1 := h1;
RgnHandle := rh;
PosX := 0;
if MoveZoneRoot = nil then
 MoveZoneRoot := ps
else
 begin
  p := MoveZoneRoot;
  while p.Next <> nil do p := p.Next;
  p.Next := ps
 end;
Next := nil;
Mask := False;
Bmps := False;
State := False;
Clicked := False;
Action := pr
end;

function TMoveZone.ToucheBut(x,y:integer):boolean;
begin
Result := PtInRegion(RgnHandle,x,y)
end;

function TMoveZone.Touche(x,y:integer):boolean;
begin
Result := ((x >= zx) and (x < zx + zw) and
           (y >= zy + zy1) and (y < zy + zy1 + zh1))
end;

procedure TForm1.DoMovingWindow(Sender: TObject);
begin
Left := Left + MoveWin.PosX;
Top := Top + MoveWin.PosY
end;

procedure TForm1.DoMovingScroll(Sender: TObject);
begin
Inc(MoveScr.OldX,MoveScr.PosX);
if sw <= scr_width then exit;
if Scroll_Distination <> Item_Displayed then exit;
Dec(HorScrl_Offset,MoveScr.PosX);
if HorScrl_Offset < 0 then
 HorScrl_Offset := 0
else if HorScrl_Offset > sw - scr_width then
 HorScrl_Offset := sw - scr_width;
RedrawScroll
end;

procedure TMoveZone.AddBitmaps;
begin
Bmps := True;
DC1 := CreateCompatibleDC(DC_Window);
Bmp1 := SelectObject(DC1,CreateCompatibleBitmap(DC_Window,bw,bh));
Bm1w := bw;
Bm1h := bh;
BitBlt(DC1,0,0,bw,bh,DC_Bmp,x1,y1,SRCCOPY);
if m then
 begin
  DCMask := CreateCompatibleDC(DC_Window);
  BmpMask := SelectObject(DCMask,CreateBitmap(bw,bh,1,1,nil));
  SetBkColor(DC_Bmp,GetPixel(DC_Bmp,x1,y1));
  BitBlt(DCMask,0,0,bw,bh,DC_Bmp,x1,y1,SRCCOPY);
  SetBkColor(DC1, RGB(0,0,0));
  SetTextColor(DC1,RGB(255,255,255));
  BitBlt(DC1,0,0,bw,bh,DCMask,0,0,SRCAND);
  Mask := True
 end;
DC2 := CreateCompatibleDC(DC_Window);
Bmp2 := SelectObject(DC2,CreateCompatibleBitmap(DC_Window,zw,zh));
BitBlt(DC2,0,0,zw,zh,DC_Bmp,zx,zy,SRCCOPY)
end;

procedure TMoveZone.Free;
begin
if Bmps then
 begin
  DeleteObject(SelectObject(DC1,Bmp1));
  DeleteDC(DC1);
  DeleteObject(SelectObject(DC2,Bmp2));
  DeleteDC(DC2);
  if Mask then
   begin
    DeleteObject(SelectObject(DCMask,BmpMask));
    DeleteDC(DCMask)
   end
 end;
inherited
end;

procedure TMoveZone.Redraw(OnCanvas:boolean);
begin
if Bmps then
 begin
  if not Mask then
   BitBlt(DC_DBuffer,zx + PosX,zy,Bm1w,Bm1h,DC1,0,0,SRCCOPY)
  else
   begin
    BitBlt(DC_DBuffer,zx + PosX,zy,Bm1w,Bm1h,DCMask,0,0,SRCAND);
    BitBlt(DC_DBuffer,zx + PosX,zy,Bm1w,Bm1h,DC1,0,0,SRCPAINT)
   end;
  if not OnCanvas then
   BitBlt(DC_Window,zx,zy,zw,zh,DC_DBuffer,zx,zy,SRCCOPY)
 end;
end;

procedure TMoveZone.HideBmp;
begin
if Bmps then
 BitBlt(DC_DBuffer,zx + PosX,zy,Bm1w,Bm1h,DC2,PosX,0,SRCCOPY)
end;

procedure TForm1.DoMovingVol(Sender: TObject);
begin
VolumeCtrl := MoveVol.PosX;
SetSysVolume
end;

procedure Rewind(newpos,maxpos:integer);
var
 p:integer;
 f:double;
 i:DWORD;
 MSF:packed record
  case boolean of
  True: (MSF:DWORD);
  False:(M,S,F:byte);
 end;
begin
if not IsPlaying then exit;
if Paused then exit;
if MoveProgr.Clicked then exit;
if not (CurFileType in [BASSFileMin..BASSFileMax,CDAFile]) then
 WOResetPlaying(True);
if newpos < 0 then
 newpos := 0
else if newpos > maxpos then
 newpos := maxpos;
if maxpos = ProgrWidth then
 begin
  p := newpos;
  f := 0
 end
else
 begin
  f := newpos/maxpos * ProgrWidth;
  p := Trunc(f);
  f := Frac(f)
 end;

if MoveProgr.PosX <> p then
 begin
  MoveProgr.HideBmp;
  OffsetRgn(MoveProgr.RgnHandle,p - MoveProgr.PosX,0);
  MoveProgr.PosX := p;
  MoveProgr.Redraw(False)
 end;
if not (CurFileType in [BASSFileMin..BASSFileMax,CDAFile]) then
 begin
  try
   RerollMusic(NewPos,MaxPos,p,f)
  finally
   WOUnresetPlaying
  end 
 end
else if CurFileType in [StreamFileMin..StreamFileMax] then
 begin
  if not BASS_ChannelSetPosition(MusicHandle,BASS_ChannelSeconds2Bytes(MusicHandle,newpos/maxpos * ProgrMax / 1000)) then
   PostMessage(Form1.Handle,WM_PLAYNEXTITEM,0,0)
 end
else if CurFileType <> CDAFile then
 begin
  Paused := True;
  p := round(newpos/maxpos * ProgrMax / 1000);
  if not BASS_ChannelSetPosition(MusicHandle,DWORD(p) or $FFFF0000) then
   PostMessage(Form1.Handle,WM_PLAYNEXTITEM,0,0)
  else
   TimePlayStart := GetTickCount - DWORD(p) * 1000;
  Paused := False
 end
else
 begin
  i := round(newpos/maxpos * ProgrMax);
  MSF.F := i mod 75;
  i := i div 75;
  MSF.S := i mod 60;
  MSF.M := i div 60;
  CDSetPosition(CurCDNum,CurCDTrk,MSF.MSF,Form1.Handle)
 end
end;

procedure TForm1.DoMovingProgr(Sender: TObject);
begin
Rewind(MoveProgr.PosX,ProgrWidth)
end;

procedure TForm1.ButMinClick(Sender: TObject);
begin
ButMinimize.UnPush;
Application.Minimize
end;

procedure TForm1.AppMinimize(Sender: TObject);
begin
if TrayMode <> 0 then
 begin
  ShowWindow(Application.Handle,SW_HIDE);
  if TrayMode = 2 then
   AddTrayIcon;
 end;
end;

procedure TForm1.AppRestore(Sender: TObject);
begin
if TrayMode = 2 then RemoveTrayIcon;
end;

procedure TForm1.MyBringToFront;
begin
Application.Minimize;
if TrayMode <> 0 then
 ShowWindow(Application.Handle,SW_SHOW);
Application.Restore;
if TrayMode = 1 then
 ShowWindow(Application.Handle,SW_HIDE)
end;

procedure TForm1.ShowApp(Tray:boolean);
{var
 h:THandle;}
begin
if IsIconic(Application.Handle) then
 begin
  if TrayMode <> 0 then
   ShowWindow(Application.Handle,SW_SHOW);
  Application.Restore;
  if TrayMode = 1 then
   ShowWindow(Application.Handle,SW_HIDE)
 end
else if Tray then
 begin
{  if Application.Active then
   Application.Minimize
  else} //not works, unfortunately...
  Application.BringToFront
 end 
else
 MyBringToFront
end;

procedure TForm1.WMTRAYICON(var Msg: TMessage);
begin
case Msg.LParam of
WM_LBUTTONDOWN:
 TrayIconClicked := True;
WM_LBUTTONUP:
 if TrayIconClicked then
  begin
   TrayIconClicked := False;
   ShowApp(True)
  end
end
end;

procedure TForm1.FormCreate(Sender: TObject);

 function AddRoundRectRgnR(a,b,c,d,e,f:integer):HRGN;
 begin
  Result := CreateRoundRectRgn(a,b,c,d,e,f);
  CombineRgn(MyFormRgn,MyFormRgn,Result,RGN_OR)
 end;

 procedure AddRoundRectRgn(a,b,c,d,e,f:integer);
 begin
  DeleteObject(AddRoundRectRgnR(a,b,c,d,e,f))
 end;

var
 i:integer;

const
 RegionVolPoints:array[0..2] of tagPOINT =
  ((x:237+70-18;y:21+11),(x:237+70;y:21+11),(x:237+70;y:21));
 RegionProgrPoints:array[0..11] of tagPOINT =
  ((x:96;y:84),(x:100;y:84),(x:100;y:83),(x:112;y:83),(x:112;y:84),
   (x:116;y:84),(x:116;y:92),(x:112;y:92),(x:112;y:93),(x:100;y:93),
   (x:100;y:92),(x:96;y:92));
begin
Randomize;

DC_Window := GetDC(Handle);
MyFormRgn := CreateRectRgn(51,1,311,114);
AddRoundRectRgn(0,0,115,115,115,115);
AddRoundRectRgn(358-115,0,358,115,115,115);
RgnLoop := AddRoundRectRgnR(62-10,110-10,62+11,110+11,21,21);
RgnBack := AddRoundRectRgnR(80,96,80+35,123,14,14);
RgnPlay := AddRoundRectRgnR(119,96,119+35,123,14,14);
RgnPause := AddRoundRectRgnR(158,96,158+35,123,14,14);
RgnStop := AddRoundRectRgnR(197,96,197+35,123,14,14);
RgnNext := AddRoundRectRgnR(235,96,235+35,123,14,14);
RgnOpen := AddRoundRectRgnR(275,96,275+35,123,14,14);
RgnMixer := CreateRoundRectRgn(318,21,318+26,21+26,26,26);
RgnPList := CreateRoundRectRgn(310,77,310+26,77+26,26,26);
RgnTools := CreateRoundRectRgn(322,50,322+26,50+26,26,26);
RgnMin := CreateRoundRectRgn(282,6,282+16,6+16,16,16);
RgnClose := CreateRoundRectRgn(304,6,304+16,6+16,16,16);
SensSpa := TSensZone.Create(@SensSpa,spa_x,spa_y,spa_width,spa_height,ButSpaClick);
SensAmp := TSensZone.Create(@SensAmp,amp_x,amp_y,amp_width,amp_height,ButAmpClick);
SensTime := TSensZone.Create(@SensTime,time_x,time_y,time_width,time_height,ButTimeClick);
MoveWin := TMoveZone.Create(@MoveWin,84,5,279-84,22-5,0,22-5,0,DoMovingWindow);
RgnVol := CreatePolygonRgn(RegionVolPoints,3,ALTERNATE);
MoveVol := TMoveZone.Create(@MoveVol,237,21,70,12,4,8,RgnVol,DoMovingVol);
RgnProgr := CreatePolygonRgn(RegionProgrPoints,12,ALTERNATE);
MoveProgr := TMoveZone.Create(@MoveProgr,96,83,255-96,10,2,5,RgnProgr,DoMovingProgr);
MoveScr := TMoveZone.Create(@MoveScr,scr_x,scr_y,scr_width,scr_height,0,scr_height,0,DoMovingScroll);

Bitmap_DBuffer := CreateCompatibleBitmap(DC_Window,MWWidth,MWHeight);
DC_DBuffer := CreateCompatibleDC(DC_Window);
SelectObject(DC_DBuffer,Bitmap_DBuffer);

FileMode := 0;

LoadSkin('',True);

VolumeCtrl := MoveVol.zw - MoveVol.Bm1w;
VolumeCtrlMax := VolumeCtrl;
MoveVol.PosX := VolumeCtrl;
SysVolumeParams.Title := 'Not selected';
SysVolumeParams.MixerNumber := -1;
SysVolumeParams.DestNumber := -1;
SysVolumeParams.CtrlNumber := -1;
SysVolumeParams.MixerID := -1;
SysVolumeParams.Opened := False;

ProgrWidth := MoveProgr.zw - MoveProgr.Bm1w;

SetLength(Trackers_Slider_Points,ProgrWidth);

Led_AY.State := True;
SetWindowRgn(Handle,MyFormRgn,True);
PSpa_prev := @Spa_prev;
PSpa_piks := @Spa_piks;
Synthesizer := Synthesizer_Stereo16;
Application.OnRestore := AppRestore;
Application.OnMinimize := AppMinimize;

FIDO_Descriptor_Filename := ExtractFileDir(ParamStr(0));
if (FIDO_Descriptor_Filename <> '') and
   (FIDO_Descriptor_Filename[Length(FIDO_Descriptor_Filename)] <> '\') then
 FIDO_Descriptor_Filename := FIDO_Descriptor_Filename + '\';
FIDO_Descriptor_Filename := FIDO_Descriptor_Filename + 'AYSTATUS.TXT';

for i := 0 to spa_num - 1 do Spa_piks[i] := 0;

BitmapSources := CreateCompatibleBitmap(DC_Window,max_src,max_height);
DC_Sources := CreateCompatibleDC(DC_Window);
SelectObject(DC_Sources,BitmapSources);

TimeFont := CreateFont(-20,0,0,0,FW_BOLD,0,0,0,DEFAULT_CHARSET,
                       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,
                       DEFAULT_PITCH or FF_DONTCARE,'MS Sans Serif');
ScrollFont := CreateFont(-20,0,0,0,FW_THIN,0,0,0,DEFAULT_CHARSET,
                         OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,
                         DEFAULT_PITCH or FF_DONTCARE,'MS Sans Serif');

Bitmap_Time := CreateCompatibleBitmap(DC_Window,time_width,time_height);
DC_Time := CreateCompatibleDC(DC_Window);
SelectObject(DC_Time,BitMap_Time);
SelectObject(DC_Time,TimeFont);
SetTextColor(DC_Time,RGB(70,70,70));
SetBkMode(DC_Time,TRANSPARENT);

Pen_Vis := CreatePen(PS_SOLID, 3, RGB(70, 70, 70));
Bitmap_Vis := CreateCompatibleBitmap(DC_Window,max_width2,max_height2);
DC_Vis := CreateCompatibleDC(DC_Window);
SelectObject(DC_Vis,Bitmap_Vis);
SelectObject(DC_Vis,Pen_Vis);

Bitmap_VScroll := CreateCompatibleBitmap(DC_Window,scr_width,scr_lineheight*3);
DC_VScroll := CreateCompatibleDC(DC_Window);
SelectObject(DC_VScroll,Bitmap_VScroll);
SelectObject(DC_VScroll,ScrollFont);
SetTextColor(DC_VScroll,RGB(96,96,96));
SetBkColor(DC_VScroll,RGB(255,255,255));

Bitmap_Scroll := CreateCompatibleBitmap(DC_Window,scr_width,scr_lineheight);
DC_Scroll := CreateCompatibleDC(DC_Window);
SelectObject(DC_Scroll,Bitmap_Scroll);

Brush_VScroll := CreateSolidBrush(RGB(255,255,255));
FillRect(DC_VScroll,Rect(0,0,scr_width,scr_lineheight*3),Brush_VScroll);
CopyBmpSources;

ResetMutex := CreateMutex(nil, False, 'AYEmul_Reset');

VisEventH := CreateEvent(nil,False,False,nil);
VisThreadH := CreateThread(nil,0,@VisThreadFunc,nil,0,VisThreadID);
//SetThreadPriority(ScrollThreadHandle,THREAD_PRIORITY_ABOVE_NORMAL);
DragAcceptFiles(Handle,True)
end;

procedure ReprepareScroll;
begin
if Item_Displayed > 0 then
 begin
  ss1 := GetPlayListString(PlaylistItems[Item_Displayed - 1]);
  GetStringWnJ(ss1,sw1,sj1)
 end;
if Item_Displayed < Length(PlaylistItems) - 1 then
 begin
  ss2 := GetPlayListString(PlaylistItems[Item_Displayed + 1]);
  GetStringWnJ(ss2,sw2,sj2)
 end;
if (Item_Displayed >= 0) and (Item_Displayed < Length(PlaylistItems)) then
 begin
  ss := GetPlayListString(PlaylistItems[Item_Displayed]);
  GetStringWnJ(ss,sw,sj);
  if scr_lineheight*(Scroll_Distination - Item_Displayed + 1)
                         - Scroll_Offset = 0 then
   begin
    if scr_width < sw then
     begin
      if HorScrl_Offset > sw - scr_width then
       HorScrl_Offset := sw - scr_width - 1
     end
    else
     begin
      HorScrl_Offset := 0;
      FillRect(DC_VScroll,Rect(0,scr_lineheight,scr_width,scr_lineheight*2),Brush_VScroll)
     end; 
    RedrawScroll
   end
 end
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);

 procedure TryClick(Bt:TButtZone);
 begin
  if Bt.Clicked = 2 then
   begin
    Bt.Clicked := 0;
    Bt.Action(Sender)
   end
 end;

begin
case Key of
byte('T'):
 ButTimeClick(Sender);
byte('1'):
 ButAmpClick(Sender);
byte('2'):
 ButSpaClick(Sender);
byte('P'):
 TryClick(ButTools);
byte('E'):
 TryClick(ButList);
byte('G'):
 TryClick(ButMixer);
byte('R'):
 TryClick(ButLoop);
byte('X'),VK_NUMPAD5:
 TryClick(ButPlay);
byte('V'):
 TryClick(ButStop);
byte('C'):
 TryClick(ButPause);
byte('B'),VK_NUMPAD6:
 TryClick(ButNext);
byte('Z'),VK_NUMPAD4:
 TryClick(ButPrev);
byte('L'),VK_NUMPAD0:
 TryClick(ButOpen)
end
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

 procedure UnClickAllButButt(Butt:TButtZone);
 var
  p:PButtZone;
 begin
  p := ButtZoneRoot;
  while p <> nil do
   begin
    if p <> @Butt then
     if p.Clicked <> 0 then
      begin
       p.Clicked := 0;
       if not p.Is_On then p.UnPush
      end;
    p := p.Next
   end
 end;

 procedure Push(Bt:TButtZone);
 begin
  if Bt.Clicked = 0 then
   begin
    UnClickAllButButt(Bt);
    Bt.Clicked := 2;
    Bt.Push
   end
 end;

begin
case Key of
byte('P'):
 Push(ButTools);
byte('J'):
 begin
  UnClickAllButButt(nil);
  JumpToTime
 end;
byte('E'):
 Push(ButList);
byte('G'):
 Push(ButMixer);
byte('R'):
 Push(ButLoop);
byte('X'),VK_NUMPAD5:
 Push(ButPlay);
byte('V'):
 Push(ButStop);
byte('C'):
 Push(ButPause);
byte('B'),VK_NUMPAD6:
 Push(ButNext);
byte('Z'),VK_NUMPAD4:
 Push(ButPrev);
byte('L'),VK_NUMPAD0:
 Push(ButOpen);
VK_UP,VK_NUMPAD8:
 VolUp;
VK_DOWN,VK_NUMPAD2:
 VolDown;
VK_LEFT:
 begin
  UnClickAllButButt(nil);
  if Time_ms > 0 then
   Rewind(CurrTime_Rasch - 5000,Time_ms)
 end;
VK_RIGHT:
 begin
  UnClickAllButButt(nil);
  if Time_ms > 0 then
   Rewind(CurrTime_Rasch + 5000,Time_ms)
 end;
VK_F1:
 begin
  UnClickAllButButt(nil);
  CallHelp
 end
end
end;

procedure TForm1.VolUp;
begin
if MoveVol.PosX < MoveVol.zw - MoveVol.Bm1w then
 begin
  MoveVol.Clicked := False;
  MoveVol.HideBmp;
  Inc(MoveVol.PosX);
  OffsetRgn(MoveVol.RgnHandle,1,0);
  MoveVol.Redraw(False);
  MoveVol.Action(Self)
 end
end;

procedure TForm1.VolDown;
begin
if MoveVol.posX > 0 then
 begin
  MoveVol.Clicked := False;
  MoveVol.HideBmp;
  Dec(MoveVol.PosX);
  OffsetRgn(MoveVol.RgnHandle,-1,0);
  MoveVol.Redraw(False);
  MoveVol.Action(Self)
 end
end;

procedure TForm1.AddTrayIcon;
begin
if not TrayOn then
 begin
  TrIcon.Wnd := Handle;
  TrIcon.uID := 0;
  TrIcon.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
  TrIcon.uCallbackMessage := WM_TRAYICON;
  TrIcon.hIcon := GetIconHandle(TrayIconNumber);
  if not FileAvailable then TrIcon.szTip := 'AY Emulator'#0;
  TrIcon.cbSize := SizeOf(TrIcon);
  TrayOn := Shell_NotifyIcon(NIM_ADD,@TrIcon)
 end
end;

procedure TForm1.RemoveTrayIcon;
begin
if TrayOn then Shell_NotifyIcon(NIM_DELETE,@TrIcon);
TrayOn := False
end;

procedure TForm1.ChangeTrayIcon;
begin
if TrayOn then
 begin
  TrIcon.uFlags := NIF_TIP;
  Shell_NotifyIcon(NIM_MODIFY,@TrIcon);
 end
end;

procedure TForm1.SelectAppIcon;
begin
if AppIconNumber = n then exit;
AppIconNumber := n;
Application.Icon.ReleaseHandle;
Application.Icon.Handle := GetIconHandle(n)
end;

procedure TForm1.SelectTrayIcon;
begin
if TrayIconNumber = n then exit;
TrayIconNumber := n;
if TrayOn then
 begin
  TrIcon.uFlags := NIF_ICON;
  TrIcon.hIcon := GetIconHandle(n);
  Shell_NotifyIcon(NIM_MODIFY,@TrIcon);
 end
end;

procedure TForm1.LoadSkin(FName:string;First:boolean);
var
 Buffer:array of byte;
 Author,Comment:string;
 s:string;
 i:integer;
 tl,mx,pl,ls,pa,l1,l2,l3,lp:boolean;
 URHandle:integer;
begin
if FName = '' then
 begin
  i := FindResource(HInstance,pointer($101),pointer($100));
  UniReadInit(URHandle,URMemory,'',pointer(LoadResource(HInstance,i)));
  Compressed_Size:=80001; Original_Size:=161454;
  UniAddDepacker(URHandle,UDLZH);
  try
   SetLength(Buffer,Original_Size);
   UniRead(URHandle,@Buffer[0],Original_Size)
  finally
   UniReadClose(URHandle)
  end;
  SkinAuthor := '';
  SkinComment := '';
  SkinFileName := '';
  Is_Skined := False;
  i := 0
 end
else
 begin
  UniReadInit(URHandle,URFile,FName,nil);
  SetLength(s,SkinIdLen);
  UniRead(URHandle,@s[1],SkinIdLen);
  if s <> SkinId then
   begin
    UniReadClose(URHandle);
    if Russian_Interface then
     ShowMessage('Файл ' + FName +
       ' не является файлом шаблона для эмулятора версии 2.0')
    else
     ShowMessage('File ' + FName +
       ' is not AY-3-8910/12 Emulator v2.0 Skin File');
    exit
   end;
  UniRead(URHandle,@Original_Size,4);
  Compressed_Size := UniReadersData[URHandle].UniFileSize -
                        UniReadersData[URHandle].UniFilePos;
  UniAddDepacker(URHandle,UDLZH);
  try
   SetLength(Buffer,Original_Size);
   UniRead(URHandle,@Buffer[0],Original_Size)
  finally
   UniReadClose(URHandle)
  end;
  Author := '';
  i := 0;
  while (i < Original_Size) and (Buffer[i] <> 0) do
   begin
    Author := Author + char(Buffer[i]);
    Inc(i)
   end;
  SkinAuthor := Author;
  Comment := '';
  Inc(i);
  while (i < Original_Size) and (Buffer[i] <> 0) do
   begin
    Comment := Comment + char(Buffer[i]);
    Inc(i)
   end;
  SkinComment := Comment;
  SkinFileName := FName;
  Is_Skined := True;
  Inc(i)
 end;
if not First then
 begin
  tl := ButTools.Is_On;
  mx := ButMixer.Is_On;
  ls := ButList.Is_On;
  pa := ButPause.Is_Pushed;
  pl := ButPlay.Is_Pushed;
  lp := ButLoop.Is_Pushed;
  l1 := Led_AY.State;
  l2 := Led_YM.State;
  l3 := Led_Stereo.State;
  BmpFree;
  DeleteObject(SelectObject(MoveVol.DC1,MoveVol.Bmp1));
  DeleteObject(SelectObject(MoveVol.DC1,MoveVol.Bmp2));
  MoveVol.Bmps := False;
  DeleteObject(SelectObject(MoveProgr.DC1,MoveProgr.Bmp1));
  DeleteObject(SelectObject(MoveProgr.DC1,MoveProgr.Bmp2));
  MoveProgr.Bmps := False;
  SetMainBmp(@Buffer[i],Original_Size - i);
  CopyBmpSources;
  ButTools.Is_On := tl;
  ButTools.Is_Pushed := tl;
  ButMixer.Is_On := mx;
  ButMixer.Is_Pushed := mx;
  ButList.Is_On := ls;
  ButList.Is_Pushed := ls;
  ButPause.Is_Pushed := pa;
  ButPlay.Is_Pushed := pl;
  ButLoop.Is_Pushed := lp;
  ButLoop.Is_On := lp;
  Led_AY.State := l1;
  Led_YM.State := l2;
  Led_Stereo.State := l3;
  if ButTools.Is_On then
   begin
    Form6.Edit1.Text := SkinAuthor;
    Form6.Edit2.Text := SkinComment;
    Form6.Edit3.Text := SkinFileName
   end
 end
else
 SetMainBmp(@Buffer[0],Original_Size);
if FileAvailable then
 begin
  RedrawTime;
  RedrawScroll
 end;
Refresh
end;

procedure TForm1.SetMainBmp(p:pointer;size:integer);
var
 Stream:TStream;
 Bitmap:TBitmap;
begin
Stream := TMemoryStream.Create;
Stream.Write(p^,size);
Stream.Position := 0;
Bitmap := TBitmap.Create;
Bitmap.LoadFromStream(Stream);
Stream.Free;
BitBlt(DC_DBuffer,0,0,MWWidth,MWHeight,Bitmap.Canvas.Handle,0,0,SRCCOPY);
ButPlay := TButtZone.Create(@ButPlay,119,96,35,27,RgnPlay,
                            Bitmap.Canvas.Handle,119,96,119,122,PlayClick);
ButPrev := TButtZone.Create(@ButPrev,80,96,35,27,RgnBack,
                            Bitmap.Canvas.Handle,80,96,80,122,ButPrevClick);
ButNext := TButtZone.Create(@ButNext,235,96,35,27,RgnNext,
                            Bitmap.Canvas.Handle,235,96,235,122,ButNextClick);
ButOpen := TButtZone.Create(@ButOpen,275,96,35,27,RgnOpen,
                            Bitmap.Canvas.Handle,275,96,275,122,ButOpenClick);
ButStop := TButtZone.Create(@ButStop,197,96,35,27,RgnStop,
                            Bitmap.Canvas.Handle,197,96,197,122,ButStopClick);
ButPause := TButtZone.Create(@ButPause,158,96,35,27,RgnPause,
                             Bitmap.Canvas.Handle,158,96,158,122,ButPauseClick);
ButLoop := TButtZone.Create(@ButLoop,62-10,110-10,21,21,RgnLoop,
                             Bitmap.Canvas.Handle,62-10,110-10,358-21,110-7,ButLoopClick);
ButMixer := TButtZone.Create(@ButMixer,318,21,26,26,RgnMixer,
                             Bitmap.Canvas.Handle,318,21,26*2,124,ButMixerClick);
ButList := TButtZone.Create(@ButList,310,77,26,26,RgnPList,
                            Bitmap.Canvas.Handle,310,77,26,124,ButListClick);
ButTools := TButtZone.Create(@ButTools,322,50,26,26,RgnTools,
                             Bitmap.Canvas.Handle,322,50,0,124,ButToolsClick);
ButMinimize := TButtZone.Create(@ButMinimize,282,6,16,16,RgnMin,
                                Bitmap.Canvas.Handle,282,6,0,0,ButMinClick);
ButClose := TButtZone.Create(@ButClose,304,6,16,16,RgnClose,
                             Bitmap.Canvas.Handle,304,6,358-16,0,ButCloseClick);
ButAbout := TButtZone.Create(@ButAbout,258,84,307-258,92-84,0,
                             Bitmap.Canvas.Handle,258,84,0,123-(92-84),ButAboutClick);
MoveVol.AddBitmaps(Bitmap.Canvas.Handle,358-41,113,18,11,True);
MoveProgr.AddBitmaps(Bitmap.Canvas.Handle,0,103,20,10,True);
Led_AY := TLedZone.Create(@Led_AY,99,26,144-99,33-26,
                          Bitmap.Canvas.Handle,99,26,358-(144-99)-1,150-(33-26)-1);
Led_YM := TLedZone.Create(@Led_YM,144,26,190-144,33-26,
                          Bitmap.Canvas.Handle,144,26,358-(190-144)-1,150-(33-26)*2-2);
Led_Stereo := TLedZone.Create(@Led_Stereo,190,26,234-190,33-26,
                              Bitmap.Canvas.Handle,190,26,358-(234-190)-1,150-(33-26)*3-3);
Bitmap.Free
end;

procedure TForm1.BmpFree;
var
 pppp,pppp1:PButtZone;
 ppp,ppp1:PLedZone;
begin
if ButtZoneRoot <> nil then
 begin
  pppp := ButtZoneRoot;
  ButtZoneRoot := nil;
  repeat
   pppp1 := pppp.Next;
   pppp.Free;
   pppp := pppp1
  until pppp = nil
 end;
if LedZoneRoot <> nil then
 begin
  ppp := LedZoneRoot;
  LedZoneRoot := nil;
  repeat
   ppp1 := ppp.Next;
   ppp.Free;
   ppp := ppp1
  until ppp = nil
 end
end;

procedure TForm1.CopyBmpSources;
begin
BitBlt(DC_Sources,spa_src,0,spa_width,spa_height,
       DC_DBuffer,spa_x,spa_y,SRCCOPY);
BitBlt(DC_Sources,amp_src,0,amp_width,amp_height,
       DC_DBuffer,amp_x,amp_y,SRCCOPY);
BitBlt(DC_Sources,time_src,0,time_width,time_height,
       DC_DBuffer,time_x,time_y,SRCCOPY);
BitBlt(DC_Sources,scr_src,0,scr_width,scr_height,
       DC_DBuffer,scr_x,scr_y,SRCCOPY);
BitBlt(DC_Time,0,0,time_width,time_height,
       DC_Sources,time_src,0,SRCCOPY);
BitBlt(DC_Scroll,0,0,scr_width,scr_height,
       DC_Sources,scr_src,0,SRCCOPY)
end;

procedure TForm1.DropFiles(var Msg: TWmDropFiles);
var
 nFiles,i,er:integer;
 Filename:string;
 r1,r2:boolean;
begin
StopAndFreeAll;
ClearPlayList;
r1 := RecurseDirs; r2 := RecurseOnlyKnownTypes;
RecurseDirs := True; RecurseOnlyKnownTypes := True;
 try
  nFiles := DragQueryFile(Msg.Drop,$FFFFFFFF,nil,0);
  SetLength(Filename,MAX_PATH);
  for i := 0 to nFiles - 1 do
   begin
    DragQueryFile(Msg.Drop,i,PChar(Filename),MAX_PATH);
    er := GetFileAttributes(PChar(Filename));
    if (er = -1) or (er and FILE_ATTRIBUTE_DIRECTORY = 0) then
     Form3.Add_File(PChar(Filename),True)
    else
     Form3.SearchFilesInFolder(PChar(Filename),-1)
   end
 finally
  RecurseDirs := r1; RecurseOnlyKnownTypes := r2;
  DragFinish(Msg.Drop);
  CalculateTotalTime(False);
  CreatePlayOrder
 end;
PlayItem(0,0)
end;

procedure TForm1.FIDO_SaveStatus(Status:FIDO_Status);
var
 f:System.text;
 s:string;

 procedure KillFile;
 begin
 try
  if FileExists(FIDO_Descriptor_FileName) then
   begin
    AssignFile(f,FIDO_Descriptor_FileName);
    Erase(f);
    FIDO_Descriptor_String := s
   end
 except
 end
 end;

var
 i:integer;
begin
if not FIDO_Descriptor_Enabled then exit;
case Status of
FIDO_Nothing:
        begin
         if FIDO_Descriptor_KillOnNothing then
          begin
           KillFile;
           exit
          end;
         s := FIDO_Descriptor_Prefix + FIDO_Descriptor_Nothing
        end;
FIDO_Exit:
        begin
         if FIDO_Descriptor_KillOnExit then
          begin
           KillFile;
           exit
          end;
         s := FIDO_Descriptor_Prefix + FIDO_Descriptor_Nothing
        end;
else    s := FIDO_Descriptor_Prefix +
                CurItem.PLStr + FIDO_Descriptor_Suffix
end;
if s <> FIDO_Descriptor_String then
 begin
  FIDO_Descriptor_String := s;
  for i := 1 to Length(s) do
   case s[i] of
    #205: s[i] := 'H';
    #240: s[i] := 'p'
   end;
  if not FIDO_Descriptor_WinEnc then
   AnsiToOemBuff(@s[1], @s[1], Length(s));
  try
   AssignFile(f,FIDO_Descriptor_FileName);
   Rewrite(f);
   Write(f,s);
   CloseFile(f)
  except
  end
 end
end;

procedure TForm1.JumpToTime;

function TimeValid(stime:string;var time:integer):boolean;
var
 temp,t1:integer;
begin
Result := True;
Val(stime,time,temp);
if temp = 0 then exit;
if (temp > 1) and (temp < Length(stime)) and (stime[temp] = ':') then
 begin
  Val(Copy(stime,temp + 1,Length(stime) - temp),time,t1);
  if t1 = 0 then
   begin
    Val(Copy(stime,1,temp - 1),t1,temp);
    if temp = 0 then
     begin
      inc(time,t1*60);
      exit
     end;
   end;
 end;
Result := False
end;

var
 time:integer;
begin
if not IsPlaying then exit;
if Paused then exit;
with TForm8.Create(Self) do
 try
  Edit1.Text := TimeSToStr(round(CurrTime_Rasch / 1000));
  if Russian_Interface then
   begin
    Caption := 'Перейти на время';
    Label1.Caption := 'минуты:секунды';
    Label2.Caption := 'Длина трека ' + TimeSToStr(round(Time_ms / 1000));
    Button1.Caption := 'Перейти';
    Button2.Caption := 'Отмена';
   end
  else
   begin
    Caption := 'Jump to time';
    Label1.Caption := 'Minutes:Seconds';
    Label2.Caption := 'Track length ' + TimeSToStr(round(Time_ms / 1000));
    Button1.Caption := 'Jump';
    Button2.Caption := 'Cancel';
   end;
  if ShowModal = mrOK then
   if TimeValid(Edit1.Text,time) then
    Rewind(time*1000,Time_ms)
 finally
  Free;
 end
end;

procedure TForm1.CallHelp;
begin
if Russian_Interface then
 WinHelp(WindowHandle, PChar(ExtractFilePath(ParamStr(0))+'Ay_Rus.hlp'),
                  HELP_FINDER, 0)
else
 WinHelp(WindowHandle, PChar(ExtractFilePath(ParamStr(0))+'Ay_Eng.hlp'),
                  HELP_FINDER, 0)
end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
VolDown
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
VolUp
end;

procedure TForm1.WMFINALIZEWO;
begin
WOThreadFinalization;
RestoreControls;
PostMessage(Form1.Handle,WM_PLAYNEXTITEM,0,0);
end;

procedure TForm1.WndProc;
var
 ps:tagPAINTSTRUCT;
 hDC1:HDC;
 p:PSensZone;
 p1:PMoveZone;
 p2:PButtZone;
begin
case Message.Msg of
WM_ERASEBKGND:
 begin
  Message.Result := 1;
  exit
 end;
WM_KILLFOCUS:
 begin
  ClipCursor(nil);
  p := SensZoneRoot;
  while p <> nil do
   begin
    p.Clicked := False;
    p := p.Next
   end;
  p2 := ButtZoneRoot;
  while p2 <> nil do
   begin
    if (p2.Clicked = 1) and not p2.Is_On then p2.UnPush;
    p2.Clicked := 0;
    p2 := p2.Next
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    p1.Clicked := False;
    p1 := p1.Next
   end
 end;
WM_PAINT:
 begin
   hDC1 := BeginPaint(Form1.Handle,ps);
   try
    MainWinRepaint(hDC1)
   finally
    EndPaint(Form1.Handle,ps)
   end;
  Message.Result := 0;
  exit
 end;
end;
inherited
end;

procedure StopPlaying;
begin
try
if not (CurFileType in [BASSFileMin..BASSFileMax,CDAFile]) then
 StopWOThread
else
 begin
  if CurFileType <> CDAFile then
   PlayFreeBASS
  else
   StopCDDevice(CurCDNum)
 end
finally
IsPlaying := False;
Reseted := 0;
Paused := False;
RestoreControls
end
end;

procedure GetSysVolume;
var
 MCD:TMIXERCONTROLDETAILS;
 MDU:array of TMIXERCONTROLDETAILS_UNSIGNED;
 i,ps:integer;
begin
if SysVolumeParams.MixerID = -1 then exit;
SetLength(MDU,SysVolumeParams.Chans);
FillChar(MCD,sizeof(TMIXERCONTROLDETAILS),0);
MCD.cbStruct := sizeof(TMIXERCONTROLDETAILS);
MCD.dwControlID := SysVolumeParams.ControlID;
MCD.cChannels := SysVolumeParams.Chans;
MCD.cbDetails := sizeof(TMIXERCONTROLDETAILS_UNSIGNED);
MCD.paDetails := @MDU[0];
if mixerGetControlDetails(SysVolumeParams.MixerID,@MCD,
                               MIXER_GETCONTROLDETAILSF_VALUE or
                               MIXER_OBJECTF_MIXER) = MMSYSERR_NOERROR then
 begin
  ps := 0;
  for i := 0 to SysVolumeParams.Chans - 1 do
   if SysVolumeParams.Vals[i].dwValue <> MDU[i].dwValue then
    begin
     ps := 1;
     break
    end;
  if ps <> 0 then
   begin
    for i := 0 to SysVolumeParams.Chans - 1 do
     SysVolumeParams.Vals[i].dwValue := MDU[i].dwValue;
    ps := SysVolumeParams.Pos;
    SysVolumeParams.Pos := 0;
    for i := 0 to SysVolumeParams.Chans - 1 do
     if DWORD(SysVolumeParams.Pos) < MDU[i].dwValue then
      SysVolumeParams.Pos := MDU[i].dwValue;
    if (SysVolumeParams.Pos > 0) and (ps = SysVolumeParams.Pos) then
     for i := 0 to SysVolumeParams.Chans - 1 do
      SysVolumeParams.Balans[i].dwValue := MDU[i].dwValue
   end
 end
else
 SysVolumeParams.Pos := SysVolumeParams.Max;
if VolLinear then
 VolumeCtrl := round((SysVolumeParams.Pos - SysVolumeParams.Min) /
                    (SysVolumeParams.Max - SysVolumeParams.Min) * VolumeCtrlMax)
else
 VolumeCtrl := round(ln((SysVolumeParams.Pos - SysVolumeParams.Min) /
                        (SysVolumeParams.Max - SysVolumeParams.Min) + 1) /
                     ln(2) * VolumeCtrlMax);
RedrawVolume
end;

procedure SetSysVolume;
var
 MCD:TMIXERCONTROLDETAILS;
 i,ps:integer;
begin
if SysVolumeParams.MixerID = -1 then exit;
ps := SysVolumeParams.Min;
for i := 0 to SysVolumeParams.Chans - 1 do
 if DWORD(ps) < SysVolumeParams.Balans[i].dwValue then
  ps := SysVolumeParams.Balans[i].dwValue;
if VolLinear then
 SysVolumeParams.Pos := SysVolumeParams.Min +
                       round(VolumeCtrl / VolumeCtrlMax *
                             (SysVolumeParams.Max - SysVolumeParams.Min))
else
 SysVolumeParams.Pos := SysVolumeParams.Min +
                        round((exp(VolumeCtrl / VolumeCtrlMax * ln(2)) - 1) *
                              (SysVolumeParams.Max - SysVolumeParams.Min));
for i := 0 to SysVolumeParams.Chans - 1 do
 if ps > 0 then
  SysVolumeParams.Vals[i].dwValue := SysVolumeParams.Min +
   round((SysVolumeParams.Pos - SysVolumeParams.Min)/ps*
             (SysVolumeParams.Balans[i].dwValue - DWORD(SysVolumeParams.Min)))
 else
  SysVolumeParams.Vals[i].dwValue := SysVolumeParams.Pos;
FillChar(MCD,sizeof(TMIXERCONTROLDETAILS),0);
MCD.cbStruct := sizeof(TMIXERCONTROLDETAILS);
MCD.dwControlID := SysVolumeParams.ControlID;
MCD.cChannels := SysVolumeParams.Chans;
MCD.cbDetails := sizeof(TMIXERCONTROLDETAILS_UNSIGNED);
MCD.paDetails := @SysVolumeParams.Vals[0];
mixerSetControlDetails(SysVolumeParams.MixerID,@MCD,
                                        MIXER_SETCONTROLDETAILSF_VALUE or
                                        MIXER_OBJECTF_MIXER);
RedrawVolume
end;

procedure RedrawVolume;
begin
if VolumeCtrl = MoveVol.PosX then exit;
MoveVol.HideBmp;
OffsetRgn(MoveVol.RgnHandle,VolumeCtrl - MoveVol.PosX,0);
MoveVol.PosX := VolumeCtrl;
MoveVol.Redraw(False)
end;

procedure TForm1.MMMIXMCONTROLCHANGE;
begin
if (Msg.WParam = SysVolumeParams.MixerHandle) and
   (Msg.LParam = SysVolumeParams.ControlID) then
 GetSysVolume
end;

procedure TForm1.MMMCINOTIFY;
begin
if not CheckCDNum(CurCDNum) then exit;
if Msg.LParam <> integer(CDIDs[CurCDNum]) then exit;
if Msg.WParam = MCI_NOTIFY_SUCCESSFUL then
 WMPLAYNEXTITEM(Msg)
end;

procedure TForm1.WMPLAYERROR;
begin
ButStopClick(Self)
end;

procedure StopAndFreeAll;
begin
try
 StopPlaying
finally
 FreeBASS;
 UnloadBASS;
 try
  FreeAllCD
 except
 end
end
end;

{procedure TForm1.RemoveOldPaths;
var
 subKeyHnd1:HKey;
 i,j:integer;
 MyRegPath:string;
begin
MyRegPath := MyRegPath1 + '\' + MyRegPath2 + #0;
i := RegOpenKeyEx(HKEY_CURRENT_USER,PChar(MyRegPath),0,KEY_ALL_ACCESS,
        subKeyHnd1);
if i = ERROR_FILE_NOT_FOUND then exit;
CheckRegError(i);
for j := 1 to NumOfOldPaths do
 begin
  i := RegDeleteKey(subKeyHnd1,PChar(MyRegPath3Old[j]));
  if i <> ERROR_FILE_NOT_FOUND then
   try
    CheckRegError(i)
   except
   end
 end;
RegCloseKey(subKeyHnd1)
end;}

procedure TForm1.SaveParams;
var
 subKeyHnd1:HKey;
 i:integer;
 CreateStatus:longword;
 MyRegPath:string;

 procedure SaveDW(Nm:PChar; const Vl:integer);
 begin
 CheckRegError(RegSetValueEx(subKeyHnd1,Nm,0,REG_DWORD,@Vl,4))
 end;

 procedure SaveStr(Nm:PChar; const Vl:string);
 begin
 CheckRegError(RegSetValueEx(subKeyHnd1,Nm,0,REG_SZ,PChar(Vl),Length(Vl) + 1))
 end;

begin
if Uninstall then exit;
//RemoveOldPaths;
MyRegPath := MyRegPath1 + '\' + MyRegPath2 + '\' + MyRegPath3 + #0;
i := 0;
i := RegCreateKeyEx(HKEY_CURRENT_USER,PChar(MyRegPath),0,@i,
       REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,subKeyHnd1,@CreateStatus);
CheckRegError(i);
try
 SaveDW('SampleRate',SampleRate);
 SaveDW('SampleBit',SampleBit);
 SaveDW('OutChansMono',Ord(Form2.RadioButton14.Checked));
 SaveDW('OutChansList',Ord(Form2.CheckBox8.Checked));
 SaveDW('WODevice',WODevice);
 SaveDW('BufLen_ms',BufLen_ms);
 SaveDW('NumberOfBuffers',NumberOfBuffers);
 SaveDW('Chip',Ord(not Form2.RadioButton1.Checked) + 1);
 SaveDW('ChipList',Ord(Form2.CheckBox2.Checked));
 SaveDW('FrqZ80',FrqZ80);
 SaveDW('FrqAY',Form2.FrqAYTemp);
 SaveDW('FrqAYList',Ord(Form2.CheckBox3.Checked));
 SaveDW('FrqPl',Form2.FrqPlTemp);
 SaveDW('FrqPlList',Ord(Form2.CheckBox9.Checked));
 SaveDW('IntOffset',IntOffset);
 SaveDW('MaxTStates',MaxTStates);
 SaveDW('VisAmpls',Ord(IndicatorChecked));
 SaveDW('VisSpectrum',Ord(SpectrumChecked));
 SaveDW('VisScroll',Ord(Do_Scroll));
 SaveDW('OptimizationQ',Ord(Optimization_For_Quality));
 SaveDW('Russian',Ord(Russian_Interface));
 SaveDW('Loop',Ord(Do_Loop));
 SaveDW('TrayMode',TrayMode);
 SaveDW('TimeMode',TimeMode);
 if Form1.Is_Skined then
  SaveStr('Skin',SkinFileName)
 else
  SaveStr('Skin','');
 SaveDW('MFPTimerMode',MFPTimerMode);
 SaveDW('MFPTimerFrq',MFPTimerFrq);
 SaveDW('AutoSaveDefDir',Ord(AutoSaveDefDir));
 SaveDW('AutoSaveWindowsPos',Ord(AutoSaveWindowsPos));
 SaveDW('AutoSaveVolumePos',Ord(AutoSaveVolumePos));
 SaveDW('BeeperMax',BeeperMax);
 SaveDW('Priority',Priority);
 SaveDW('ChanAL',Form2.TrackBar1.Position);
 SaveDW('ChanAR',Form2.TrackBar2.Position);
 SaveDW('ChanBL',Form2.TrackBar3.Position);
 SaveDW('ChanBR',Form2.TrackBar4.Position);
 SaveDW('ChanCL',Form2.TrackBar5.Position);
 SaveDW('ChanCR',Form2.TrackBar6.Position);
 SaveDW('ChansList',Ord(Form2.CheckBox1.Checked));
 SaveDW('FIDO_Descriptor_Enabled',Ord(FIDO_Descriptor_Enabled));
 SaveDW('FIDO_Descriptor_KillOnExit',Ord(FIDO_Descriptor_KillOnExit));
 SaveDW('FIDO_Descriptor_KillOnNothing',Ord(FIDO_Descriptor_KillOnNothing));
 SaveDW('FIDO_Descriptor_WinEnc',Ord(FIDO_Descriptor_WinEnc));
 SaveStr('FIDO_Descriptor_FileName',FIDO_Descriptor_FileName);
 SaveStr('FIDO_Descriptor_Nothing',FIDO_Descriptor_Nothing);
 SaveStr('FIDO_Descriptor_Suffix',FIDO_Descriptor_Suffix);
 SaveStr('FIDO_Descriptor_Prefix',FIDO_Descriptor_Prefix);
 SaveDW('FilterQuality',FilterQuality);
 SaveDW('PreAmp',PreAmp);
 SaveDW('BASSFFTType',BASSFFTType);
 SaveDW('BASSAmpMin',round(BASSAmpMin * 10000));
 SaveDW('VolLinear',Ord(VolLinear));
 SaveDW('VolMixerNumber',SysVolumeParams.MixerNumber);
 SaveDW('VolDestNumber',SysVolumeParams.DestNumber);
 SaveDW('VolCtrlNumber',SysVolumeParams.CtrlNumber);
 SaveDW('VolCtrlChans',SysVolumeParams.Chans);
 if AutoSaveVolumePos then SaveDW('Volume',VolumeCtrl);
 if AutoSaveWindowsPos then
  begin
   SaveDW('MainX',Form1.Left);
   SaveDW('MainY',Form1.Top);
   SaveDW('ListX',Form3.Left);
   SaveDW('ListY',Form3.Top);
   SaveDW('ListW',Form3.Width);
   SaveDW('ListH',Form3.Height);
   SaveDW('ListVis',Ord(Form3.Visible));
   SaveDW('MixerX',Form2.Left);
   SaveDW('MixerY',Form2.Top);
   if ButTools.Is_On then
    begin
     ToolsY := Form6.Top;
     ToolsX := Form6.Left
    end;
   SaveDW('ToolsX',ToolsX);
   SaveDW('ToolsY',ToolsY)
  end;
 SaveDW('ListItem',PlayingItem);
 SaveDW('AppIcon',AppIconNumber);
 SaveDW('TrayIcon',TrayIconNumber);
 SaveDW('MenuIcon',MenuIconNumber);
 SaveDW('MusIcon',MusIconNumber);
 SaveDW('SkinIcon',SkinIconNumber);
 SaveDW('ListIcon',ListIconNumber);
 SaveDW('BASSIcon',BASSIconNumber);
 SaveStr('SkinDirectory',SkinDirectory);
 SaveDW('PlayListDirection',Direction);
 SaveDW('PlayListLoop',Ord(ListLooped));
 SaveDW('PLColorBkSel',PLColorBkSel);
 SaveDW('PLColorBkPl',PLColorBkPl);
 SaveDW('PLColorBk',PLColorBk);
 SaveDW('PLColorPlSel',PLColorPlSel);
 SaveDW('PLColorPl',PLColorPl);
 SaveDW('PLColorSel',PLColorSel);
 SaveDW('PLColor',PLColor);
 SaveDW('PLColorErrSel',PLColorErrSel);
 SaveDW('PLColorErr',PLColorErr);
 if AutoSaveDefDir then SaveDefaultDir2(subKeyHnd1)
finally
 RegCloseKey(subKeyHnd1)
end
end;

procedure TForm1.CommandLineAndRegCheck;
var
 i,v,v1:integer;
 subKeyHnd1:HKey;
 MyRegPath,dir:string;
 PlayIt,KeyOpened:boolean;
 Mixers:TSysMixers;

 function GetDW(Nm:PChar; var Vl:integer):boolean;
 var
  i:integer;
 begin
 i := 4;
 Result := RegQueryValueEx(subKeyHnd1,Nm,nil,nil,@Vl,@i) = ERROR_SUCCESS
 end;

 function GetStr(Nm:PChar; var Vl:string):boolean;
 var
  i:integer;
 begin
 Result := RegQueryValueEx(subKeyHnd1,Nm,nil,nil,nil,@i) = ERROR_SUCCESS;
 if Result then
  begin
   SetLength(Vl,i + 1);
   Result := RegQueryValueEx(subKeyHnd1,Nm,nil,nil,@Vl[1],@i) = ERROR_SUCCESS;
   if Result then
    Vl := PChar(Vl)
  end;
 end;

begin
ClearParams;
MyRegPath := MyRegPath1 + '\' + MyRegPath2 + '\' + MyRegPath3 + #0;
KeyOpened := RegOpenKeyEx(HKEY_CURRENT_USER,PChar(MyRegPath),0,
   KEY_EXECUTE,subKeyHnd1) = ERROR_SUCCESS;
SetDefault;
if (integer(GetVersion) < 0) then //Win9x or Win32s
 SetPriority(HIGH_PRIORITY_CLASS);
try
try
if KeyOpened then
 begin
  if GetDW('SampleRate',v) then Set_Sample_Rate2(v);
  if GetDW('SampleBit',v) then Set_Sample_Bit2(v);
  if GetDW('OutChansMono',v) then Set_Stereo2(v);
  if GetDW('OutChansList',v) then Form2.CheckBox8.Checked := v <> 0;
  if GetDW('WODevice',v) then Set_WODevice2(v);
  if GetDW('BufLen_ms',v) then Set_BufLen_ms2(v);
  if GetDW('NumberOfBuffers',v) then Set_NumberOfBuffers2(v);
  if GetDW('Chip',v) then Set_Chip2(ChTypes(v));
  if GetDW('ChipList',v) then Form2.CheckBox2.Checked := v <> 0;
  if GetDW('FrqZ80',v) then Set_Z80_Frq2(v);
  if GetDW('FrqAY',v) then Set_Chip_Frq2(v);
  if GetDW('FrqAYList',v) then Form2.CheckBox3.Checked := v <> 0;
  if GetDW('FrqPl',v) then Set_Player_Frq2(v);
  if GetDW('FrqPlList',v) then Form2.CheckBox9.Checked := v <> 0;
  if GetDW('MaxTStates',v) then Set_N_Tact2(v);
  if GetDW('IntOffset',v) then Set_IntOffset2(v);
  if GetDW('VisAmpls',v) then IndicatorChecked := v <> 0;
  if GetDW('VisSpectrum',v) then SpectrumChecked := v <> 0;
  if GetDW('VisScroll',v) then Do_Scroll := v <> 0;
  if GetDW('OptimizationQ',v) then SetOptimization2(v <> 0);
  if GetDW('FilterQuality',v) then SetFilter2(v);
  if GetDW('Russian',v) then Set_Language2(v <> 0);
  if GetDW('Loop',v) then Set_Loop2(v <> 0);
  if GetDW('TimeMode',v) then if v in [0..2] then TimeMode := v;
  SkinDirectory := '';
  if GetStr('Skin',dir) then if dir <> '' then
   begin
    LoadSkin(dir,False);
    SkinDirectory := ExtractFileDir(dir)
   end;
  if GetStr('SkinDirectory',dir) then if dir <> '' then
   SkinDirectory := dir;
  v1 := MFPTimerMode;
  if GetDW('MFPTimerMode',v) then v1 := v;
  if v1 = 0 then
   Set_MFP_Frq2(0,0)
  else
   begin
    v1 := MFPTimerFrq;
    if GetDW('MFPTimerFrq',v) then v1 := v;
    Set_MFP_Frq2(1,v1)
   end;
  if GetDW('AutoSaveDefDir',v) then SetAutoSaveDefDir2(v <> 0);
  if GetDW('AutoSaveWindowsPos',v) then SetAutoSaveWindowsPos2(v <> 0);
  if GetDW('AutoSaveVolumePos',v) then SetAutoSaveVolumePos2(v <> 0);
  if GetDW('Priority',v) then SetPriority2(v);
  if GetDW('ChanAL',v) then SetChan2(v,0);
  if GetDW('ChanAR',v) then SetChan2(v,1);
  if GetDW('ChanBL',v) then SetChan2(v,2);
  if GetDW('ChanBR',v) then SetChan2(v,3);
  if GetDW('ChanCL',v) then SetChan2(v,4);
  if GetDW('ChanCR',v) then SetChan2(v,5);
  if GetDW('BeeperMax',v) then SetChan2(v,6);
  if GetDW('PreAmp',v) then SetChan2(v,7);
  if GetDW('ChansList',v) then Form2.CheckBox1.Checked := v <> 0;
  if GetDW('FIDO_Descriptor_Enabled',v) then FIDO_Descriptor_Enabled := v <> 0;
  if GetDW('FIDO_Descriptor_KillOnExit',v) then FIDO_Descriptor_KillOnExit := v <> 0;
  if GetDW('FIDO_Descriptor_KillOnNothing',v) then FIDO_Descriptor_KillOnNothing := v <> 0;
  if GetDW('FIDO_Descriptor_WinEnc',v) then FIDO_Descriptor_WinEnc := v <> 0;
  if GetStr('FIDO_Descriptor_FileName',dir) then FIDO_Descriptor_FileName := dir;
  if GetStr('FIDO_Descriptor_Nothing',dir) then FIDO_Descriptor_Nothing := dir;
  if GetStr('FIDO_Descriptor_Suffix',dir) then FIDO_Descriptor_Suffix := dir;
  if GetStr('FIDO_Descriptor_Prefix',dir) then FIDO_Descriptor_Prefix := dir;
  if GetDW('PlayListDirection',v) then if v in [0..3] then Form3.SetDirection(v);
  if GetDW('PlayListLoop',v) then
   begin
    ListLooped := v <> 0;
    Form3.LoopListButton.Down := ListLooped
   end;
  if GetDW('PLColorBkSel',v) then PLColorBkSel := v;
  if GetDW('PLColorBkPl',v) then PLColorBkPl := v;
  if GetDW('PLColorBk',v) then PLColorBk := v;
  if GetDW('PLColorPlSel',v) then PLColorPlSel := v;
  if GetDW('PLColorPl',v) then PLColorPl := v;
  if GetDW('PLColorSel',v) then PLColorSel := v;
  if GetDW('PLColor',v) then PLColor := v;
  if GetDW('PLColorErrSel',v) then PLColorErrSel := v;
  if GetDW('PLColorErr',v) then PLColorErr := v;
  if GetDW('BASSFFTType',v) then
   if (DWORD(v) >= BASS_DATA_FFT512) and (DWORD(v) <= BASS_DATA_FFT4096) then
    BASSFFTType := v;
  if GetDW('BASSAmpMin',v) then
   if (v >= 1) and (v <= 1000) then
    BASSAmpMin := v / 10000;
  if GetDW('VolLinear',v) then VolLinear := v <> 0;
  if GetDW('VolMixerNumber',v) then SysVolumeParams.MixerNumber := v;
  if GetDW('VolDestNumber',v) then SysVolumeParams.DestNumber := v;
  if GetDW('VolCtrlNumber',v) then SysVolumeParams.CtrlNumber := v;
  if GetDW('VolCtrlChans',v) then SysVolumeParams.Chans := v;
  GetSystemMixers(Mixers);
  if not SelectMixerControl(Mixers,SysVolumeParams.MixerNumber,
                                   SysVolumeParams.DestNumber,
                                   SysVolumeParams.CtrlNumber) then
   DetectVolumeCtrl2(Mixers);
  Mixers := nil;
  if AutoSaveVolumePos then
   begin
    if GetDW('Volume',v) then
     if v < VolumeCtrlMax then
      begin
       VolumeCtrl := v;
       SetSysVolume
      end
   end;
  DefaultDirectory := '';
  if GetStr('DefaultDirectory',dir) then DefaultDirectory := dir
 end
else
 DetectVolumeCtrl
finally
 Form2.SetMixerParams
end;
LastTimeComLine := GetTickCount - CLFast;
if ParamCount <> 0 then
 CommandLineInterpreter('"' + GetCurrentDir + '" ' + GetCommandLine,True);
for i := 0 to Length(AfterScan) - 1 do
 CommandLineInterpreter(AfterScan[i],True);
AfterScan := nil;
dir := ExtractFileDir(ParamStr(0));
PlayIt := Length(PlaylistItems) <> 0;
if not PlayIt then
 begin
  SetCurrentDir(dir);
  MyRegPath := ExpandFileName('Ay_Emul.ayl');
  if FileExists(MyRegPath) then
   begin
    LoadAYL(MyRegPath);
    if KeyOpened then
     if GetDW('ListItem',v) then
      if (v >= 0) and (v < Length(PlayListItems)) then
       PlayingItem := v;
   end
 end;
CreatePlayOrder;
CalculateTotalTime(False);
if DefaultDirectory = '' then DefaultDirectory := dir;
if SetCurrentDir(DefaultDirectory) then OpenDialog1.InitialDir := DefaultDirectory;
if KeyOpened then
 begin
  if AutoSaveWindowsPos then
   begin
    Position := poDesigned;
    if GetDW('MainX',v) then Left := v;
    if GetDW('MainY',v) then Top := v;
    Form3.Position := poDesigned;
    if GetDW('ListX',v) then Form3.Left := v;
    if GetDW('ListY',v) then Form3.Top := v;
    if GetDW('ListW',v) then Form3.Width := v;
    if GetDW('ListH',v) then Form3.Height := v;
    if GetDW('ListVis',v) then if v <> 0 then
     begin
      ButList.Switch_On;
      Form3.Visible := True
     end;
    Form2.Position := poDesigned;
    if GetDW('MixerX',v) then Form2.Left := v;
    if GetDW('MixerY',v) then Form2.Top := v;
    if GetDW('ToolsX',v) then ToolsX := v;
    if GetDW('ToolsY',v) then ToolsY := v
   end;
  if GetDW('AppIcon',v) then SelectAppIcon(v);
  if GetDW('TrayIcon',v) then SelectTrayIcon(v);
  if GetDW('MenuIcon',v) then MenuIconNumber := v;
  if GetDW('MusIcon',v) then MusIconNumber := v;
  if GetDW('SkinIcon',v) then SkinIconNumber := v;
  if GetDW('ListIcon',v) then ListIconNumber := v;
  if GetDW('BASSIcon',v) then BASSIconNumber := v;
  if GetDW('TrayMode',v) then Set_TrayMode2(v);
 end;
finally
 if KeyOpened then RegCloseKey(subKeyHnd1)
end;
FIDO_SaveStatus(FIDO_Nothing);
if PlayIt then
 PlayItem(0,0)
else
 PlayItem(PlayingOrderItem,-1);
InitialScan := True
end;

procedure TForm1.Set_WODevice2;
begin
if (WODevice <> DWORD(WOD)) and not WOThreadActive and (WOD >= -1) and
                        (WOD < Form2.ComboBox2.Items.Count - 1) then
 begin
  WODevice := WOD;
  Form2.ComboBox2.ItemIndex := WOD + 1
 end
end;

procedure TForm1.Set_BufLen_ms2;
begin
 if BL <> BufLen_ms then
  begin
   SetBuffers(BL,NumberOfBuffers);
   Form2.TrackBar8.Position := BufLen_ms
  end
end;

procedure TForm1.Set_NumberOfBuffers2;
begin
if NB <> NumberOfBuffers then
 begin
  SetBuffers(BufLen_ms,NB);
  Form2.TrackBar9.Position := NumberOfBuffers
 end
end;

procedure TForm1.Set_Chip2;
begin
if (Ch <> ChType) and (Ch in [AY_Chip,YM_Chip]) then
 begin
  ChType := Ch;
  Calculate_Level_Tables;
  Form2.CheckBox5.Checked := False;
  Form2.CheckBox4.Checked := False;
  case Ch of
  AY_Chip:
   begin
    Form2.RadioButton1.Checked := True;
    Led_AY.State := False;
    Led_YM.State := True;
    Led_AY.Redraw(False);
    Led_YM.Redraw(False);
    if IsPlaying then
     Form2.CheckBox4.Checked := True
   end;
  YM_Chip:
   begin
    Form2.RadioButton2.Checked := True;
    Led_AY.State := True;
    Led_YM.State := False;
    Led_AY.Redraw(False);
    Led_YM.Redraw(False);
    if IsPlaying then
     Form2.CheckBox5.Checked := True
   end
  end
 end
end;

procedure TForm1.Set_IntOffset2;
begin
if (InO <> IntOffset) and (InO >= 0) and (InO < MaxTStates) then
 begin
  IntOffset := InO;
  Form2.FTact.Text := IntToStr(InO)
 end
end;

procedure TForm1.Set_Language2;
begin
if Rus = Russian_Interface then exit;
SwapLan;
if ButTools.Is_On then
 if Russian_Interface then
  Form6.RadioButton6.Checked := True
 else
  Form6.RadioButton7.Checked := True
end;

procedure TForm1.Set_Loop2;
begin
if Do_Loop = Lp then exit;
Do_Loop := Lp;
case Lp of
True:ButLoop.Switch_On;
else ButLoop.Switch_Off
end
end;

procedure TForm1.Set_TrayMode2;
begin
if (TrayMode = TM) or (DWORD(TM) > 2) then exit;
TrayMode := TM;
case TM of
0:
 begin
  RemoveTrayIcon;
  ShowWindow(Application.Handle,SW_SHOW)
 end;
1:
 begin
  AddTrayIcon;
  ShowWindow(Application.Handle,SW_HIDE)
 end;
2:
 begin
  RemoveTrayIcon;
  ShowWindow(Application.Handle,SW_SHOW)
 end
end;
if ButTools.Is_On then
 case TM of
 0:Form6.RadioButton8.Checked := True;
 1:Form6.RadioButton9.Checked := True;
 2:Form6.RadioButton10.Checked := True
end
end;

procedure TForm1.Set_MFP_Frq2;
begin
if (Md = MFPTimerMode) and (Fr = MFPTimerFrq) then exit;
Set_MFP_Frq(Md,Fr);
Form2.FrqMFPTemp := MFPTimerFrq;
Form2.Set_MFPFrqs
end;

procedure TForm1.SetAutoSaveDefDir2;
begin
AutoSaveDefDir := ASD;
if ButTools.Is_On then Form6.CheckBox38.Checked := ASD
end;

procedure TForm1.SetAutoSaveWindowsPos2;
begin
AutoSaveWindowsPos := ASW;
if ButTools.Is_On then Form6.CheckBox40.Checked := ASW
end;

procedure TForm1.SetAutoSaveVolumePos2;
begin
AutoSaveVolumePos := ASV;
Form2.CheckBox39.Checked := ASV
end;

procedure TForm1.SetPriority2;
begin
if not (NP in
    [IDLE_PRIORITY_CLASS,NORMAL_PRIORITY_CLASS,HIGH_PRIORITY_CLASS]) then exit;
SetPriority(NP);
if ButTools.Is_On then
 case Priority of
 IDLE_PRIORITY_CLASS:   Form6.RadioButton3.Checked := True;
 NORMAL_PRIORITY_CLASS: Form6.RadioButton4.Checked := True;
 HIGH_PRIORITY_CLASS:   Form6.RadioButton5.Checked := True
 end
end;

procedure TForm1.SetChan2;
begin
if DWORD(u) > 255 then exit;
with Form2 do
 case i of
 0:Change_Show(TrackBar1,Edit1,Edit12,u,Index_AL);
 1:Change_Show(TrackBar2,Edit2,Edit13,u,Index_AR);
 2:Change_Show(TrackBar3,Edit3,Edit14,u,Index_BL);
 3:Change_Show(TrackBar4,Edit4,Edit15,u,Index_BR);
 4:Change_Show(TrackBar5,Edit5,Edit16,u,Index_CL);
 5:Change_Show(TrackBar6,Edit6,Edit17,u,Index_CR);
 6:Change_Show2(Form2.TrackBar7,Form2.Edit20,u,BeeperMax);
 7:Change_Show2(TrackBar13,Edit30,u,PreAmp)
 end
end;

procedure TForm1.CalcFiltKoefs;
var
 i,i2,Filt_M2:integer;
 K,F,C:double;
 FKt:array of double;
begin
C := Pi * SampleRate / (AY_Freq div 8);
SetLength(FKt,Filt_M + 1);
Filt_M2 := Filt_M div 2;
K := 0;
for i := 0 to Filt_M do
 begin
  i2 := i - Filt_M2;
  if i2 = 0 then
   F := C
  else
   F := sin(C * i2) / i2 * (0.54 - 0.46 * cos(2 * Pi / Filt_M * i));
  FKt[i] := F;
  K := K + F
 end;
for i := 0 to Filt_M do
 Filt_K[i] := round(FKt[i] / K * $1000000)
end;

procedure TForm1.SetFilter;
begin
SuspendPlaying;
try
FilterQuality := FQ;
if (FQ = 0) or (SampleRate >= AY_Freq div 8) then
 begin
  IsFilt := False;
  Filt_K := nil;
  Filt_XL := nil;
  Filt_XR := nil;
  exit
 end;
IsFilt := True;
Filt_M := round(exp((FQ + 3) * ln(2)));
SetLength(Filt_K,Filt_M + 1);
CalcFiltKoefs;
SetLength(Filt_XL,Filt_M + 1);
SetLength(Filt_XR,Filt_M + 1);
FillChar(Filt_XL[0],(Filt_M + 1) * 4,0);
FillChar(Filt_XR[0],(Filt_M + 1) * 4,0);
Filt_I := 0
finally
WOUnresetPlaying
end
end;

procedure TForm1.SetFilter2;
begin
if (FilterQuality = FQ) or (FQ > 6) then exit;
SetFilter(FQ);
with Form2 do
 begin
  TrackBar14.Position := FQ;
  if FQ = 0 then
   Label13.Caption := 'off'
  else
   Label13.Caption := IntToStr(Filt_M)
 end;
end;

procedure TForm1.SaveAllParams;
var
 Tmp:boolean;
begin
try
 Tmp := FIDO_Descriptor_Enabled;
 FIDO_Descriptor_Enabled := False;
 StopAndFreeAll;
 FIDO_Descriptor_Enabled := Tmp;
 FIDO_SaveStatus(FIDO_Exit);
 FreePlayingResourses;
 SaveParams
except
 ShowException(ExceptObject, ExceptAddr)
end
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
 p,p1:PSensZone;
 pp,pp1:PMoveZone;
 ExCode:DWORD;
 msg:TMsg;
 String1:string;
begin
SaveAllParams;
SetCurrentDir(ExtractFileDir(ParamStr(0)));
try
if DiskFree(0) > 100 then
 begin
  String1 := ExpandFileName('Ay_Emul.ayl');
  SaveAYL(String1)
 end
except
end;
if SysVolumeParams.Opened then
 mixerClose(SysVolumeParams.MixerHandle);
RemoveTrayIcon;
BmpFree;
if SensZoneRoot <> nil then
 begin
  p := SensZoneRoot;
  SensZoneRoot := nil;
  repeat
   p1 := p.Next;
   p.Free;
   p := p1
  until p = nil
 end;
if MoveZoneRoot <> nil then
 begin
  pp := MoveZoneRoot;
  MoveZoneRoot := nil;
  repeat
   pp1 := pp.Next;
   pp.Free;
   pp := pp1
  until pp = nil
 end;
DeleteObject(RgnLoop);
DeleteObject(RgnBack);
DeleteObject(RgnPlay);
DeleteObject(RgnNext);
DeleteObject(RgnStop);
DeleteObject(RgnPause);
DeleteObject(RgnOpen);
DeleteObject(RgnMixer);
DeleteObject(RgnVol);
DeleteObject(RgnProgr);
SetEvent(VisEventH);
repeat
 if not GetExitCodeThread(VisThreadH,ExCode) then break;
 if ExCode = STILL_ACTIVE then
  while PeekMessage(msg,Handle,
                WM_VISUALISATION,WM_VISUALISATION,PM_REMOVE) do
until ExCode <> STILL_ACTIVE;
CloseHandle(VisThreadH);
CloseHandle(VisEventH);
CloseHandle(ResetMutex);
DeleteObject(Pen_Vis);
DeleteObject(Bitmap_VScroll);
DeleteObject(Bitmap_Scroll);
DeleteObject(Bitmap_Vis);
DeleteObject(Bitmap_Time);
DeleteObject(BitmapSources);
DeleteObject(Bitmap_DBuffer);
DeleteObject(TimeFont);
DeleteObject(ScrollFont);
DeleteObject(Brush_VScroll);
DeleteDC(DC_Scroll);
DeleteDC(DC_VScroll);
DeleteDC(DC_Vis);
DeleteDC(DC_Time);
DeleteDC(DC_Sources);
DeleteDC(DC_DBuffer);
ReleaseDC(Handle,DC_Window);
SetPriority(NORMAL_PRIORITY_CLASS)
end;

procedure TForm1.HideMinimize;
begin
Application.Minimize
end;

end.


