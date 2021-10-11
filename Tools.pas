{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit Tools;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, FileCtrl, ShlObj, ComObj, ActiveX, ExtCtrls, Buttons;

const
 NOfIcons = 14;
 IconAuthors:array[0..NOfIcons] of string =
 ('Sergey Bulba','X-agon','X-agon','X-agon','X-agon','David Willis',
  'Graham Goring','Graham Goring','Graham Goring','Graham Goring',
  'bcass','bcass','Exocet','Exocet','Roman Morozov');

type
    TIconSelector = class
    IcGrp:TGroupBox;
    IcImg:TImage;
    IconUpDown:TUpDown;
    AuthLB,AuthName:TLabel;
    constructor Create(AOwner:TWinControl);
    destructor Destroy; override;
    procedure ShowIcon;
    procedure IconUpDownClick(Sender: TObject; Button: TUDBtnType);
    public
    DoSelectIcon:procedure(n:integer) of object;
    end;

    TForm6 = class(TForm)
    PageControl1: TPageControl;
    GenTools: TTabSheet;
    GroupBox1: TGroupBox;
    CheckBox40: TCheckBox;
    GroupBox5: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    GroupBox6: TGroupBox;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    GroupBox10: TGroupBox;
    Button10: TButton;
    Button11: TButton;
    GroupBox11: TGroupBox;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    GroupBox12: TGroupBox;
    Label8: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Edit3: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Button12: TButton;
    Button13: TButton;
    GroupBox13: TGroupBox;
    Edit4: TEdit;
    CheckBox38: TCheckBox;
    Button14: TButton;
    FTypTools: TTabSheet;
    SearchTool: TTabSheet;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    DName: TEdit;
    GroupBox3: TGroupBox;
    CheckBox9: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox33: TCheckBox;
    CheckBox35: TCheckBox;
    Protokol: TMemo;
    ProgressBar1: TProgressBar;
    Button3: TButton;
    Memo1: TMemo;
    Button8: TButton;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox23: TCheckBox;
    CheckBox24: TCheckBox;
    CheckBox25: TCheckBox;
    CheckBox26: TCheckBox;
    CheckBox27: TCheckBox;
    CheckBox28: TCheckBox;
    CheckBox30: TCheckBox;
    CheckBox31: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    Button9: TButton;
    CheckBox21: TCheckBox;
    CheckBox32: TCheckBox;
    CheckBox34: TCheckBox;
    CheckBox36: TCheckBox;
    CheckBox37: TCheckBox;
    FIDOTools: TTabSheet;
    Label2: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    CheckBox29: TCheckBox;
    CheckBox41: TCheckBox;
    CheckBox42: TCheckBox;
    CheckBox43: TCheckBox;
    Button16: TButton;
    Button4: TButton;
    CheckBox44: TCheckBox;
    CheckBox45: TCheckBox;
    CheckBox46: TCheckBox;
    CheckBox47: TCheckBox;
    CheckBox48: TCheckBox;
    CheckBox49: TCheckBox;
    CheckBox50: TCheckBox;
    CheckBox51: TCheckBox;
    CheckBox52: TCheckBox;
    CheckBox53: TCheckBox;
    CheckBox54: TCheckBox;
    CheckBox55: TCheckBox;
    CheckBox56: TCheckBox;
    Button7: TButton;
    CheckBox39: TCheckBox;
    CheckBox57: TCheckBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    ColorDialog1: TColorDialog;
    CheckBox58: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AllEnable;
    function CloseQuery:boolean;override;
    procedure Button4Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    function CheckRegistration(S1:PChar;Ind:integer):boolean;
    procedure SetRegInfo;
    function RegisterFile(S1:PChar;Ind:integer):boolean;
    function UnRegisterFile(S1:PChar;Ind:integer):boolean;
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    function CheckRegPath(a:integer):boolean;
    procedure SetIfRegPath;
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure CheckBox38Click(Sender: TObject);
    procedure Edit4Exit(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox40Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure SelectMenuIcon(n:integer);
    procedure SelectMusIcon(n:integer);
    procedure SelectSkinIcon(n:integer);
    procedure SelectListIcon(n:integer);
    procedure SelectBASSIcon(n:integer);
    procedure CheckBox12Click(Sender: TObject);
    procedure CheckBox13Click(Sender: TObject);
    procedure CheckBox14Click(Sender: TObject);
    procedure CheckBox15Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure CheckBox18Click(Sender: TObject);
    procedure CheckBox22Click(Sender: TObject);
    procedure CheckBox23Click(Sender: TObject);
    procedure CheckBox24Click(Sender: TObject);
    procedure CheckBox25Click(Sender: TObject);
    procedure CheckBox26Click(Sender: TObject);
    procedure CheckBox19Click(Sender: TObject);
    procedure CheckBox27Click(Sender: TObject);
    procedure CheckBox28Click(Sender: TObject);
    procedure CheckBox30Click(Sender: TObject);
    procedure CheckBox31Click(Sender: TObject);
    procedure CheckBox32Click(Sender: TObject);
    procedure CheckBox34Click(Sender: TObject);
    procedure CheckBox17Click(Sender: TObject);
    procedure CheckBox36Click(Sender: TObject);
    procedure CheckBox37Click(Sender: TObject);
    procedure CheckBox21Click(Sender: TObject);
    procedure CheckBox44Click(Sender: TObject);
    procedure CheckBox45Click(Sender: TObject);
    procedure CheckBox46Click(Sender: TObject);
    procedure CheckBox47Click(Sender: TObject);
    procedure CheckBox48Click(Sender: TObject);
    procedure CheckBox49Click(Sender: TObject);
    procedure CheckBox50Click(Sender: TObject);
    procedure CheckBox51Click(Sender: TObject);
    procedure CheckBox52Click(Sender: TObject);
    procedure CheckBox53Click(Sender: TObject);
    procedure CheckBox54Click(Sender: TObject);
    procedure CheckBox55Click(Sender: TObject);
    procedure CheckBox56Click(Sender: TObject);
    procedure CheckBox39Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label13Click(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label16Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    function ChangePLColor(var Color:TColor):boolean;
    procedure CheckBox58Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  RegAudio:boolean;
  RegPlaylist:boolean;
  RegSkin:boolean;
  RegBASS:boolean;
  AppIcSel,TrayIcSel,StartIcSel,
  MusIcSel,SkinIcSel,ListIcSel,BASSIcSel:TIconSelector;
  end;

procedure SaveDefaultDir2(subKeyHnd1:integer);
function GetIconHandle(n:integer):HICON;

var
  Form6: TForm6;

const

MyKeys:array[0..3]of string=
('AY_Emul Audio File','AY_Emul Playlist File',
 'AY_Emul Skin File','AY_Emul BASS File');

implementation

{$R *.DFM}

uses ChanDir, MainWin, Mixer, WaveOutAPI, AY, Z80, Players, PlayList;

procedure TForm6.Button2Click(Sender: TObject);
begin
with TChngDir.Create(Self) do
  try
    if Russian_Interface then
     begin
      Caption := 'Выбор рабочей папки';
      Button2.Caption:= 'Отмена'
     end
    else
     begin
      Caption := 'Select folder';
      Button2.Caption := 'Cancel'
     end;
    if DirectoryExists(DName.Text) then
     DirectoryListBox1.Directory := DName.Text;
    DirName.Text := DirectoryListBox1.Directory;
    ShowModal;
    if ModalResult = mrOk then DName.Text := DirName.Text
  finally
    Free
  end
end;

procedure TForm6.Button1Click(Sender: TObject);
begin
if Russian_Interface then
 Form1.OpenDialog1.Filter := 'Все файлы|*.*'
else
 Form1.OpenDialog1.Filter := 'All files|*.*';
Form1.OpenDialog1.Filter := Form1.OpenDialog1.Filter +
 '|SNA|*.sna|TRD, TD0, FDI, SCL|*.trd;*.scl;*.fdi;*.td0|BIN|*.bin|TAP, TZX|' +
 '*.tap;*.tzx';
if Form1.OpenDialog1.Execute then
 begin
  Memo1.Lines := Form1.OpenDialog1.Files;
  Form1.OpenDialog1.FileName := ''
 end
end;

procedure TForm6.Button3Click(Sender: TObject);
begin
if FinderWorksNow then
 begin
  May_Quit := True;
  AllEnable;
 end
else
 begin
  if Russian_Interface then
   Button3.Caption := Lan_Tools_Stop_Ru
  else
   Button3.Caption := Lan_Tools_Stop_En;
  Memo1.ReadOnly := True;
  DName.ReadOnly := True;
  Button1.Enabled := False;
  Button2.Enabled := False;
  Button4.Enabled := False;
  GroupBox1.Enabled := False;
  GroupBox3.Enabled := False;
  GroupBox5.Enabled := False;
  GroupBox6.Enabled := False;
  GroupBox10.Enabled := False;
  Protokol.Clear;
  FindModules
 end
end;

Procedure TForm6.AllEnable;
begin
FinderWorksNow := False;
if Russian_Interface then
 Button3.Caption := Lan_Tools_Begin_Ru
else
 Button3.Caption := Lan_Tools_Begin_En;
Memo1.ReadOnly := False;
DName.ReadOnly := False;
Button1.Enabled := True;
Button2.Enabled := True;
Button4.Enabled := True;
GroupBox1.Enabled := True;
GroupBox3.Enabled := True;
GroupBox5.Enabled := True;
GroupBox6.Enabled := True;
GroupBox10.Enabled := True
end;

procedure TForm6.Button4Click(Sender: TObject);
begin
PostMessage(Handle,WM_CLOSE,0,0)
end;

function TForm6.CloseQuery:boolean;
begin
Result := not FinderWorksNow;
if Result then
 begin
  if ButTools.Is_On then ButTools.Switch_Off;
  ToolsY := Top;
  ToolsX := Left
 end
end;

procedure TForm6.RadioButton3Click(Sender: TObject);
begin
Form1.SetPriority(IDLE_PRIORITY_CLASS)
end;

procedure TForm6.RadioButton4Click(Sender: TObject);
begin
Form1.SetPriority(NORMAL_PRIORITY_CLASS)
end;

procedure TForm6.RadioButton5Click(Sender: TObject);
begin
Form1.SetPriority(HIGH_PRIORITY_CLASS)
end;

procedure TForm6.RadioButton6Click(Sender: TObject);
begin
if not Russian_Interface then Form1.SwapLan
end;

procedure TForm6.RadioButton7Click(Sender: TObject);
begin
if Russian_Interface then Form1.SwapLan
end;

procedure TForm6.Button7Click(Sender: TObject);
var
 i:integer;
 i1:longword;
 MyRegPath:string;
 subKeyHnd1:HKey;
begin
Uninstall := True;
//Form1.RemoveOldPaths;
MyRegPath := MyRegPath1 + '\' + MyRegPath2 + '\' + MyRegPath3 + #0;
i := RegDeleteKey(HKEY_CURRENT_USER,PChar(MyRegPath));
if i <> ERROR_FILE_NOT_FOUND then
 CheckRegError(i);
MyRegPath[Length(MyRegPath1) + Length(MyRegPath2) + 2] := #0;
i := RegOpenKeyEx(HKEY_CURRENT_USER,PChar(MyRegPath),0,
     KEY_ENUMERATE_SUB_KEYS,subKeyHnd1);
if i <> ERROR_FILE_NOT_FOUND then
 CheckRegError(i);
if i = ERROR_SUCCESS then
 begin
  i1 := 0;
  i := RegEnumKeyEx(subKeyHnd1,0,nil,i1,nil,nil,nil,nil);
  RegCloseKey(subKeyHnd1);
  if i = ERROR_NO_MORE_ITEMS then
   begin
    i := RegDeleteKey(HKEY_CURRENT_USER,PChar(MyRegPath));
    CheckRegError(i)
   end
  else if i <> ERROR_MORE_DATA then
   CheckRegError(i)
 end;
MyRegPath[Length(MyRegPath1) + 1] := #0;
i := RegOpenKeyEx(HKEY_CURRENT_USER,PChar(MyRegPath),0,
      KEY_ENUMERATE_SUB_KEYS,subKeyHnd1);
if i <> ERROR_FILE_NOT_FOUND then
 CheckRegError(i);
if i = ERROR_SUCCESS then
 begin
  i1 := 0;
  i := RegEnumKeyEx(subKeyHnd1,0,nil,i1,nil,nil,nil,nil);
  RegCloseKey(subKeyHnd1);
  if i = ERROR_NO_MORE_ITEMS then
   begin
    i := RegDeleteKey(HKEY_CURRENT_USER,PChar(MyRegPath));
    CheckRegError(i)
   end
  else if i <> ERROR_MORE_DATA then
   CheckRegError(i)
 end;
Button9Click(Sender);
SetRegInfo;
ShowMessage('Ay_Emul data is removed from your system. Close the program ' +
            'and delete Ay_Emul folder to complete uninstall. See you!')
end;

procedure StartMenuLink(ChangeIcon:boolean);
var
 AnObj:IUnknown;
 ShLink:IShellLink;
 PFile:IPersistFile;
 StartMenuDir,MyProgramPath:string;
 ShCutPath:WideString;
 Pidl:PItemIDList;
 F:file;
begin
SetLength(StartMenuDir, MAX_PATH + 1);
if (SHGetSpecialFolderLocation(Application.Handle, CSIDL_PROGRAMS,Pidl)
    = NOERROR) and SHGetPathFromIDList(Pidl, PChar(StartMenuDir)) then
 begin
  StartMenuDir := StrPas(PChar(StartMenuDir));
  ShCutPath := StartMenuDir + '\AY Emulator.lnk';
  if not FileExists(ShCutPath) then
   begin
    if ChangeIcon then exit
   end
  else
   begin
    AssignFile(F,ShCutPath);
    Erase(F)
   end;
  MyProgramPath := ParamStr(0);
  AnObj := CreateComObject(CLSID_ShellLink);
  ShLink := AnObj as IShellLink;
  PFile := AnObj as IPersistFile;
  ShLink.SetPath(PChar(MyProgramPath));
  ShLink.SetWorkingDirectory(PChar(ExtractFileDir(MyProgramPath)));
  ShLink.SetIconLocation(PChar(MyProgramPath),MenuIconNumber);
  PFile.Save(PWChar(ShCutPath), False)
 end
end;

procedure TForm6.SelectMenuIcon(n:integer);
begin
if MenuIconNumber = n then exit;
MenuIconNumber := n;
StartMenuLink(True)
end;

procedure TForm6.Button10Click(Sender: TObject);
begin
StartMenuLink(False)
end;

procedure TForm6.Button11Click(Sender: TObject);
var
 Pidl:PItemIDList;
 StartMenuDir:string;
 F:file;
begin
SetLength(StartMenuDir, MAX_PATH + 1);
if (SHGetSpecialFolderLocation(Application.Handle, CSIDL_PROGRAMS,Pidl)
    = NOERROR) and SHGetPathFromIDList(Pidl, PChar(StartMenuDir)) then
 begin
  StartMenuDir := StrPas(PChar(StartMenuDir)) + '\AY Emulator.lnk';
  if FileExists(StartMenuDir) then
   begin
    AssignFile(F,StartMenuDir);
    Erase(F)
   end
 end
end;

function TForm6.CheckRegPath(a:integer):boolean;
var
 DataStr:string;
 i,j,size:integer;
 subKeyHnd1:HKey;
begin
Result := False;
DataStr := MyKeys[a];
DataStr := DataStr + '\shell\open\command'#0;
i := RegOpenKeyEx(HKEY_CLASSES_ROOT,PChar(DataStr),0,KEY_ALL_ACCESS,
        subKeyHnd1);
if i <> ERROR_SUCCESS then
 begin
  if i <> ERROR_FILE_NOT_FOUND then CheckRegError(i);
  exit
 end;
try
 i := RegQueryValueEx(subKeyHnd1,'',nil,@j,nil,@size);
 CheckRegError(i);
 if j = REG_SZ then
  begin
   SetLength(DataStr,size);
   i := RegQueryValueEx(subKeyHnd1,'',nil,@j,PByte(DataStr),@size);
   CheckRegError(i);
   if a <> 2 then
    Result := AnsiLowerCase(DataStr) =
                        AnsiLowerCase('"' + ParamStr(0) + '" "%1"'#0)
   else
    Result := AnsiLowerCase(DataStr) =
                        AnsiLowerCase('"' + ParamStr(0) + '" /p"%1"'+#0)
  end
finally
 RegCloseKey(subKeyHnd1)
end
end;

procedure TForm6.SetIfRegPath;
begin
RegAudio := CheckRegPath(0);
RegPlaylist := CheckRegPath(1);
RegSkin := CheckRegPath(2);
RegBASS := CheckRegPath(3)
end;

procedure TForm6.RadioButton8Click(Sender: TObject);
begin
TrayMode := 0;
Form1.RemoveTrayIcon;
ShowWindow(Application.Handle,SW_SHOW)
end;

procedure TForm6.RadioButton9Click(Sender: TObject);
begin
TrayMode := 1;
Form1.AddTrayIcon;
ShowWindow(Application.Handle,SW_HIDE)
end;

procedure TForm6.RadioButton10Click(Sender: TObject);
begin
TrayMode := 2;
Form1.RemoveTrayIcon;
ShowWindow(Application.Handle,SW_SHOW)
end;

procedure TForm6.Button12Click(Sender: TObject);
var
 tmp:integer;
 s,s1:string;
begin
s := Form1.OpenDialog1.FileName;
s1 := Form1.OpenDialog1.InitialDir;
Form1.OpenDialog1.FileName := '';
tmp := Form1.OpenDialog1.FilterIndex;
Form1.OpenDialog1.FilterIndex := 1;
Form1.OpenDialog1.Options := [ofHideReadOnly,ofEnableSizing];
if Russian_Interface then
 Form1.OpenDialog1.Filter:='Файлы шаблонов (AYS)|*.ays'
else
 Form1.OpenDialog1.Filter:='Skin files (AYS)|*.ays';
if Form1.SkinDirectory <> '' then
 Form1.OpenDialog1.InitialDir := Form1.SkinDirectory;
if Form1.OpenDialog1.Execute then
 begin
  Form1.SkinDirectory := ExtractFileDir(Form1.OpenDialog1.FileName);
  Form1.LoadSkin(Form1.OpenDialog1.FileName,False);
  Form1.Repaint
 end;
Form1.OpenDialog1.InitialDir := s1; 
Form1.OpenDialog1.FilterIndex := tmp;
Form1.OpenDialog1.FileName := s;
Form1.OpenDialog1.Options :=
                 [ofHideReadOnly,ofAllowMultiSelect,ofEnableSizing]
end;

procedure TForm6.Button13Click(Sender: TObject);
begin
if Form1.Is_Skined then
 begin
  Form1.LoadSkin('',False);
  Form1.Repaint
 end
end;

procedure TForm6.CheckBox38Click(Sender: TObject);
begin
AutoSaveDefDir := CheckBox38.Checked
end;

procedure TForm6.Edit4Exit(Sender: TObject);
var
 s:string;
begin
s := Trim(Edit4.Text);
if DirectoryExists(s) then
 Form1.DefaultDirectory := s
end;

procedure TForm6.Button14Click(Sender: TObject);
var
 i:integer;
 MyRegPath:string;
 CreateStatus:longword;
 subKeyHnd1:HKey;
begin
MyRegPath := MyRegPath1 + '\' + MyRegPath2 + '\' + MyRegPath3 + #0;
i := 0;
CheckRegError(RegCreateKeyEx(HKEY_CURRENT_USER,PChar(MyRegPath),0,@i,
     REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,subKeyHnd1,@CreateStatus));
try
 SaveDefaultDir2(subKeyHnd1)
finally
 RegCloseKey(subKeyHnd1)
end
end;

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action := caFree;
AppIcSel.Free;
TrayIcSel.Free;
StartIcSel.Free;
MusIcSel.Free;
SkinIcSel.Free;
ListIcSel.Free;
BASSIcSel.Free
end;

procedure TForm6.FormCreate(Sender: TObject);
begin
if ToolsX <> MaxInt then
 begin
  Top := ToolsY;
  Left := ToolsX
 end
else
 Position := poScreenCenter
end;

procedure TForm6.CheckBox40Click(Sender: TObject);
begin
AutoSaveWindowsPos := CheckBox40.Checked
end;

procedure SaveDefaultDir2;
var
 i:integer;
 DefDir:string;
begin
 if (Form1.DefaultDirectory <> '') and
    (Form1.DefaultDirectory <> ExtractFileDir(ParamStr(0))) then
  begin
   DefDir := Form1.DefaultDirectory + #0;
   i := Length(DefDir);
   i := RegSetValueEx(subKeyHnd1,'DefaultDirectory',0,REG_SZ,
                PChar(DefDir),i);
   CheckRegError(i)
  end
 else
  begin
   i := RegDeleteValue(subKeyHnd1,'DefaultDirectory');
   if i <> ERROR_FILE_NOT_FOUND then
    CheckRegError(i)
  end
end;

procedure TForm6.Button16Click(Sender: TObject);
begin
with Form1 do
 begin
  FIDO_Descriptor_Enabled := CheckBox29.Checked;
  FIDO_Descriptor_KillOnNothing := CheckBox42.Checked;
  FIDO_Descriptor_KillOnExit := CheckBox41.Checked;
  FIDO_Descriptor_WinEnc := CheckBox43.Checked;
  FIDO_Descriptor_Prefix := Edit6.Text;
  FIDO_Descriptor_Suffix := Edit7.Text;
  FIDO_Descriptor_Nothing := Edit8.Text;
  FIDO_Descriptor_Filename := Edit5.Text;
  if IsPlaying and not Paused then
   FIDO_SaveStatus(FIDO_Playing)
  else
   FIDO_SaveStatus(FIDO_Nothing)
 end
end;

procedure TIconSelector.ShowIcon;
var
 Ic:TIcon;
begin
Ic := TIcon.Create;
Ic.ReleaseHandle;
Ic.Handle := GetIconHandle(IconUpDown.Position);
IcImg.Picture.Assign(Ic);
Ic.Free;
AuthName.Caption := IconAuthors[IconUpDown.Position]
end;

procedure TIconSelector.IconUpDownClick(Sender: TObject; Button: TUDBtnType);
begin
ShowIcon;
DoSelectIcon(IconUpDown.Position)
end;

constructor TIconSelector.Create;
begin
inherited Create;
IcGrp := TGroupBox.Create(AOwner);
IcGrp.Width := 97;
IcGrp.Height := 81;
IcImg := TImage.Create(IcGrp);
IcImg.Parent := IcGrp;
IcImg.Width := 32;
IcImg.Height := 32;
IcImg.Top := 16;
IcImg.Left := 24;
IconUpDown := TUpDown.Create(IcGrp);
IconUpDown.Parent := IcGrp;
IconUpDown.Height := 32;
IconUpDown.Top := 16;
IconUpDown.Left := 56;
IconUpDown.Max := NOfIcons;
IconUpDown.OnClick := IconUpDownClick;
AuthLB := TLabel.Create(IcGrp);
AuthLB.Parent := IcGrp;
AuthLB.Left := 32;
AuthLB.Top := 48;
AuthLB.Caption := 'Author:';
AuthName := TLabel.Create(IcGrp);
AuthName.Parent := IcGrp;
AuthName.Alignment := taCenter;
AuthName.AutoSize := False;
AuthName.Left := 8;
AuthName.Top := 64;
AuthName.Width := 81;
AuthName.Height := 13;
IcGrp.Parent := AOwner
end;

destructor TIconSelector.Destroy;
begin
try
 AuthName.Free;
 AuthLB.Free;
 IconUpDown.Free;
 IcImg.Free;
 IcGrp.Free
finally
 inherited
end
end;

function GetIconHandle;
var
 p:PChar;
begin
if n = 0 then
 p := 'MAINICON'
else
 p := pointer(n);
Result := LoadIcon(hInstance,p)
end;

procedure RegisterType(n:integer);
const
 RTypes:array[boolean,0..3] of string =
 (('AY/YM Audio File'#0,
   'AY/YM Emulator Playlist File'#0,
   'AY Emulator Skin File'#0,
   'AY_Emul&BASS Audio File'#0),
  ('Аудио файл AY/YM'#0,
   'Список проигрывания AY/YM эмулятора'#0,
   'Файл обшивки эмулятора AY'#0,
   'Аудио файл AY_Emul&BASS'#0));
var
 i:integer;
 DataStr:string;
 subKeyHnd1,subKeyHnd2:HKey;
 CreateStatus:longword;
begin
DataStr := MyKeys[n] + #0;
i := 0;
i := RegCreateKeyEx(HKEY_CLASSES_ROOT,PChar(DataStr),0,@i,
       REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,subKeyHnd1,@CreateStatus);
CheckRegError(i);
try
 DataStr := RTypes[Russian_Interface,n];
 i := Length(DataStr);
 i := RegSetValueEx(subKeyHnd1,'',0,REG_SZ,PChar(DataStr),i);
 CheckRegError(i);
 i := 0;
 i := RegCreateKeyEx(subKeyHnd1,'DefaultIcon',0,@i,
        REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,subKeyHnd2,@CreateStatus);
 CheckRegError(i);
 try
  DataStr := ParamStr(0) + ',';
  case n of
  0:
   DataStr := DataStr + IntToStr(MusIconNumber);
  1:
   DataStr := DataStr + IntToStr(ListIconNumber);
  2:
   DataStr := DataStr + IntToStr(SkinIconNumber);
  3:
   DataStr := DataStr + IntToStr(BASSIconNumber)
  end;
  i := Length(DataStr);
  i := RegSetValueEx(subKeyHnd2,'',0,REG_SZ,PChar(DataStr),i);
  CheckRegError(i)
 finally
  RegCloseKey(subKeyHnd2)
 end;
 i := 0;
 i := RegCreateKeyEx(subKeyHnd1,'shell\open\command',0,@i,
        REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,subKeyHnd2,@CreateStatus);
 CheckRegError(i);
 try
  DataStr := '"' + ParamStr(0) + '" ';
  if n = 2 then DataStr := DataStr + '/p';
  DataStr := DataStr + '"%1"'#0;
  i := Length(DataStr);
  i := RegSetValueEx(subKeyHnd2,'',0,REG_SZ,PChar(DataStr),i);
  CheckRegError(i);
  case n of
  0:
   Form6.RegAudio := True;
  1:
   Form6.RegPlaylist := True;
  2:
   Form6.RegSkin := True;
  3:
   Form6.RegBASS := True
  end
 finally
  RegCloseKey(subKeyHnd2)
 end
finally
 RegCloseKey(subKeyHnd1)
end
end;

procedure TForm6.Button8Click(Sender: TObject);
begin
CheckBox12Click(Sender);
CheckBox13Click(Sender);
CheckBox14Click(Sender);
CheckBox15Click(Sender);
CheckBox16Click(Sender);
CheckBox34Click(Sender);
CheckBox26Click(Sender);
CheckBox22Click(Sender);
CheckBox23Click(Sender);
CheckBox24Click(Sender);
CheckBox25Click(Sender);
CheckBox32Click(Sender);
CheckBox37Click(Sender);
CheckBox36Click(Sender);
CheckBox17Click(Sender);
CheckBox27Click(Sender);
CheckBox28Click(Sender);
CheckBox30Click(Sender);
CheckBox31Click(Sender);
CheckBox56Click(Sender);
CheckBox58Click(Sender);

CheckBox18Click(Sender);
CheckBox19Click(Sender);

CheckBox21Click(Sender);

CheckBox44Click(Sender);
CheckBox45Click(Sender);
CheckBox46Click(Sender);
CheckBox47Click(Sender);
CheckBox48Click(Sender);
CheckBox49Click(Sender);
CheckBox50Click(Sender);
CheckBox51Click(Sender);
CheckBox52Click(Sender);
CheckBox53Click(Sender);
CheckBox54Click(Sender);
CheckBox55Click(Sender);
CheckBox39Click(Sender);

RegisterType(0);
RegisterType(1);
RegisterType(2);
RegisterType(3);
SetRegInfo
end;

function TForm6.CheckRegistration(S1:PChar;Ind:integer):boolean;
var
 i:integer;
 RStr:PChar;
 subKeyHnd1:HKey;
begin
Result := False;
if Ind = 0 then if not RegAudio then exit;
if Ind = 1 then if not RegPlaylist then exit;
if Ind = 2 then if not RegSkin then exit;
if Ind = 3 then if not RegBASS then exit;
i := RegOpenKeyEx(HKEY_CLASSES_ROOT,S1,0,KEY_EXECUTE,subKeyHnd1);
if i <> ERROR_SUCCESS then
 begin
  if i <> ERROR_FILE_NOT_FOUND then CheckRegError(i);
  exit
 end;
if RegQueryValueEx(subKeyHnd1,'',nil,nil,nil,@i) = ERROR_SUCCESS then
 begin
  GetMem(RStr,i);
  if RegQueryValueEx(subKeyHnd1,'',nil,nil,PByte(RStr),@i) = ERROR_SUCCESS then
   Result := (MyKeys[Ind] = RStr);
  FreeMem(RStr)
 end;
RegCloseKey(subKeyHnd1)
end;

procedure TForm6.SetRegInfo;
begin
CheckBox12.Checked := Form1.STC_Registered;
CheckBox13.Checked := Form1.STP_Registered;
CheckBox14.Checked := Form1.ASC_Registered;
CheckBox15.Checked := Form1.PSC_Registered;
CheckBox58.Checked := Form1.PSM_Registered;
CheckBox16.Checked := Form1.SQT_Registered;
CheckBox18.Checked := Form1.AYL_Registered;
CheckBox22.Checked := Form1.PT1_Registered;
CheckBox23.Checked := Form1.PT2_Registered;
CheckBox24.Checked := Form1.PT3_Registered;
CheckBox25.Checked := Form1.FTC_Registered;
CheckBox26.Checked := Form1.FLS_Registered;
CheckBox19.Checked := Form1.M3U_Registered;
CheckBox27.Checked := Form1.OUT_Registered;
CheckBox28.Checked := Form1.ZXAY_Registered;
CheckBox30.Checked := Form1.PSG_Registered;
CheckBox31.Checked := Form1.VTX_Registered;
CheckBox32.Checked := Form1.GTR_Registered;
CheckBox34.Checked := Form1.FXM_Registered;
CheckBox17.Checked := Form1.YM_Registered;
CheckBox36.Checked := Form1.AYM_Registered;
CheckBox37.Checked := Form1.AY_Registered;
CheckBox21.Checked := Form1.AYS_Registered;
CheckBox44.Checked := Form1.MP3_Registered;
CheckBox45.Checked := Form1.MP2_Registered;
CheckBox46.Checked := Form1.MP1_Registered;
CheckBox47.Checked := Form1.OGG_Registered;
CheckBox48.Checked := Form1.WAV_Registered;
CheckBox49.Checked := Form1.MO3_Registered;
CheckBox50.Checked := Form1.IT_Registered;
CheckBox51.Checked := Form1.XM_Registered;
CheckBox52.Checked := Form1.S3M_Registered;
CheckBox53.Checked := Form1.MTM_Registered;
CheckBox54.Checked := Form1.MOD_Registered;
CheckBox55.Checked := Form1.UMX_Registered;
CheckBox39.Checked := Form1.WMA_Registered;
CheckBox56.Checked := Form1.CDA_Registered
end;

function TForm6.RegisterFile(S1:PChar;Ind:integer):boolean;
var
 i:integer;
 subKeyHnd1:HKey;
 CreateStatus:longword;
 RStr:PChar;
begin
try
 i := 0;
 CheckRegError(RegCreateKeyEx(HKEY_CLASSES_ROOT,S1,0,@i,
       REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,subKeyHnd1,@CreateStatus));
 try
  if RegQueryValueEx(subKeyHnd1,'',nil,nil,nil,@i) = ERROR_SUCCESS then
   begin
    GetMem(RStr,i);
    try
     if RegQueryValueEx(subKeyHnd1,'',nil,nil,PByte(RStr),@i) = ERROR_SUCCESS then
      if (StrComp(PChar(MyKeys[Ind] + #0),RStr) <> 0) and (RStr[0] <> #0) then
       CheckRegError(RegSetValueEx(subKeyHnd1,'Before AY_Emul',0,REG_SZ,RStr,i))
    finally
     FreeMem(RStr)
    end
   end;
  CheckRegError(RegSetValueEx(subKeyHnd1,'',0,REG_SZ,PChar(MyKeys[Ind] + #0),
                 Length(MyKeys[Ind]) + 1));
  Result := True;
 finally
  RegCloseKey(subKeyHnd1)
 end
except
 Result := False
end
end;

function TForm6.UnRegisterFile(S1:PChar;Ind:integer):boolean;
var
 i:integer;
 subKeyHnd1:HKey;
 RStr:PChar;
begin
Result := False;
i := RegOpenKeyEx(HKEY_CLASSES_ROOT,S1,0,KEY_ALL_ACCESS,subKeyHnd1);
if i <> ERROR_SUCCESS then
 begin
  if i <> ERROR_FILE_NOT_FOUND then CheckRegError(i);
  exit
 end;
try
 if RegQueryValueEx(subKeyHnd1,'Before AY_Emul',nil,nil,nil,@i) = ERROR_SUCCESS then
  begin
   GetMem(RStr,i);
   try
    if RegQueryValueEx(subKeyHnd1,'Before AY_Emul',nil,nil,PByte(RStr),@i) = ERROR_SUCCESS then
     CheckRegError(RegSetValueEx(subKeyHnd1,'',0,REG_SZ,RStr,i))
   finally
    FreeMem(RStr);
    RegDeleteValue(subKeyHnd1,'Before AY_Emul')
   end
  end
 else if RegQueryValueEx(subKeyHnd1,'',nil,nil,nil,@i) = ERROR_SUCCESS then
  begin
   GetMem(RStr,i);
   try
    if RegQueryValueEx(subKeyHnd1,'',nil,nil,PByte(RStr),@i) = ERROR_SUCCESS then
     begin
      if StrComp(RStr,PChar(MyKeys[Ind] + #0)) = 0 then
       begin
        try
         CheckRegError(RegDeleteValue(subKeyHnd1,''));
        except
        end;
        i := 0;
        i := RegEnumKeyEx(subKeyHnd1,0,nil,dword(i),nil,nil,nil,nil);
        if i = ERROR_NO_MORE_ITEMS then
         begin
          i := 0;
          i := RegEnumValue(subKeyHnd1,0,nil,dword(i),nil,nil,nil,nil);
          if i = ERROR_NO_MORE_ITEMS then
           begin
            RegCloseKey(subKeyHnd1);
            subKeyHnd1 := 0;
            CheckRegError(RegDeleteKey(HKEY_CLASSES_ROOT,S1))
           end
         end
       end
     end
   finally
    FreeMem(RStr)
   end
  end
finally
 if subKeyHnd1 <> 0 then RegCloseKey(subKeyHnd1)
end
end;

procedure TForm6.Button9Click(Sender: TObject);
begin
Form1.STC_Registered := UnRegisterFile('.stc',0);
Form1.STP_Registered := UnRegisterFile('.stp',0);
Form1.ASC_Registered := UnRegisterFile('.asc',0);
Form1.PSC_Registered := UnRegisterFile('.psc',0);
Form1.SQT_Registered := UnRegisterFile('.sqt',0);
Form1.AYL_Registered := UnRegisterFile('.ayl',1);
Form1.PT1_Registered := UnRegisterFile('.pt1',0);
Form1.PT2_Registered := UnRegisterFile('.pt2',0);
Form1.PT3_Registered := UnRegisterFile('.pt3',0);
Form1.FTC_Registered := UnRegisterFile('.ftc',0);
Form1.FLS_Registered := UnRegisterFile('.fls',0);
Form1.M3U_Registered := UnRegisterFile('.m3u',1);
Form1.OUT_Registered := UnRegisterFile('.out',0);
Form1.ZXAY_Registered := UnRegisterFile('.zxay',0);
Form1.PSG_Registered := UnRegisterFile('.psg',0);
Form1.VTX_Registered := UnRegisterFile('.vtx',0);
Form1.YM_Registered := UnRegisterFile('.ym',0);
Form1.AYM_Registered := UnRegisterFile('.aym',0);
Form1.AY_Registered := UnRegisterFile('.ay',0);
Form1.AYS_Registered := UnRegisterFile('.ays',2);
Form1.GTR_Registered := UnRegisterFile('.gtr',0);
Form1.FXM_Registered := UnRegisterFile('.fxm',0);
Form1.PSM_Registered := UnRegisterFile('.psm',0);
Form1.MP3_Registered := UnRegisterFile('.mp3',3);
Form1.MP2_Registered := UnRegisterFile('.mp2',3);
Form1.MP1_Registered := UnRegisterFile('.mp1',3);
Form1.OGG_Registered := UnRegisterFile('.ogg',3);
Form1.WAV_Registered := UnRegisterFile('.wav',3);
Form1.MO3_Registered := UnRegisterFile('.mo3',3);
Form1.IT_Registered := UnRegisterFile('.it',3);
Form1.XM_Registered := UnRegisterFile('.xm',3);
Form1.S3M_Registered := UnRegisterFile('.s3m',3);
Form1.MTM_Registered := UnRegisterFile('.mtm',3);
Form1.MOD_Registered := UnRegisterFile('.mod',3);
Form1.UMX_Registered := UnRegisterFile('.umx',3);
Form1.WMA_Registered := UnRegisterFile('.wma',3);
Form1.CDA_Registered := UnRegisterFile('.cda',0);
SetRegInfo
end;

procedure TForm6.SelectMusIcon;
begin
if MusIconNumber <> n then
 begin
  MusIconNumber := n;
  RegisterType(0)
 end 
end;

procedure TForm6.SelectSkinIcon;
begin
if SkinIconNumber <> n then
 begin
  SkinIconNumber := n;
  RegisterType(2)
 end
end;

procedure TForm6.SelectListIcon;
begin
if ListIconNumber <> n then
 begin
  ListIconNumber := n;
  RegisterType(1)
 end
end;

procedure TForm6.SelectBASSIcon;
begin
if BASSIconNumber <> n then
 begin
  BASSIconNumber := n;
  RegisterType(3)
 end
end;

procedure TForm6.CheckBox12Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox12.Checked then
 Form1.STC_Registered := RegisterFile('.stc',0)
else
 Form1.STC_Registered := UnRegisterFile('.stc',0)
end;

procedure TForm6.CheckBox13Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox13.Checked then
 Form1.STP_Registered := RegisterFile('.stp',0)
else
 Form1.STP_Registered := UnRegisterFile('.stp',0)
end;

procedure TForm6.CheckBox14Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox14.Checked then
 Form1.ASC_Registered := RegisterFile('.asc',0)
else
 Form1.ASC_Registered := UnRegisterFile('.asc',0)
end;

procedure TForm6.CheckBox15Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox15.Checked then
 Form1.PSC_Registered := RegisterFile('.psc',0)
else
 Form1.PSC_Registered := UnRegisterFile('.psc',0)
end;

procedure TForm6.CheckBox16Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox16.Checked then
 Form1.SQT_Registered := RegisterFile('.sqt',0)
else
 Form1.SQT_Registered := UnRegisterFile('.sqt',0)
end;

procedure TForm6.CheckBox18Click(Sender: TObject);
begin
if not RegPlaylist then RegisterType(1);
if CheckBox18.Checked then
 Form1.AYL_Registered := RegisterFile('.ayl',1)
else
 Form1.AYL_Registered := UnRegisterFile('.ayl',1)
end;

procedure TForm6.CheckBox22Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox22.Checked then
 Form1.PT1_Registered := RegisterFile('.pt1',0)
else
 Form1.PT1_Registered := UnRegisterFile('.pt1',0)
end;

procedure TForm6.CheckBox23Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox23.Checked then
 Form1.PT2_Registered := RegisterFile('.pt2',0)
else
 Form1.PT2_Registered := UnRegisterFile('.pt2',0)
end;

procedure TForm6.CheckBox24Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox24.Checked then
 Form1.PT3_Registered := RegisterFile('.pt3',0)
else
 Form1.PT3_Registered := UnRegisterFile('.pt3',0)
end;

procedure TForm6.CheckBox25Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox25.Checked then
 Form1.FTC_Registered := RegisterFile('.ftc',0)
else
 Form1.FTC_Registered := UnRegisterFile('.ftc',0)
end;

procedure TForm6.CheckBox26Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox26.Checked then
 Form1.FLS_Registered := RegisterFile('.fls',0)
else
 Form1.FLS_Registered := UnRegisterFile('.fls',0)
end;

procedure TForm6.CheckBox19Click(Sender: TObject);
begin
if not RegPlaylist then RegisterType(1);
if CheckBox19.Checked then
 Form1.M3U_Registered := RegisterFile('.m3u',1)
else
 Form1.M3U_Registered := UnRegisterFile('.m3u',1)
end;

procedure TForm6.CheckBox27Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox27.Checked then
 Form1.OUT_Registered := RegisterFile('.out',0)
else
 Form1.OUT_Registered := UnRegisterFile('.out',0)
end;

procedure TForm6.CheckBox28Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox28.Checked then
 Form1.ZXAY_Registered := RegisterFile('.zxay',0)
else
 Form1.ZXAY_Registered := UnRegisterFile('.zxay',0)
end;

procedure TForm6.CheckBox30Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox30.Checked then
 Form1.PSG_Registered := RegisterFile('.psg',0)
else
 Form1.PSG_Registered := UnRegisterFile('.psg',0)
end;

procedure TForm6.CheckBox31Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox31.Checked then
 Form1.VTX_Registered := RegisterFile('.vtx',0)
else
 Form1.VTX_Registered := UnRegisterFile('.vtx',0)
end;

procedure TForm6.CheckBox32Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox32.Checked then
 Form1.GTR_Registered := RegisterFile('.gtr',0)
else
 Form1.GTR_Registered := UnRegisterFile('.gtr',0)
end;

procedure TForm6.CheckBox34Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox34.Checked then
 Form1.FXM_Registered := RegisterFile('.fxm',0)
else
 Form1.FXM_Registered := UnRegisterFile('.fxm',0)
end;

procedure TForm6.CheckBox17Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox17.Checked then
 Form1.YM_Registered := RegisterFile('.ym',0)
else
 Form1.YM_Registered := UnRegisterFile('.ym',0)
end;

procedure TForm6.CheckBox36Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox36.Checked then
 Form1.AYM_Registered := RegisterFile('.aym',0)
else
 Form1.AYM_Registered := UnRegisterFile('.aym',0)
end;

procedure TForm6.CheckBox37Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox37.Checked then
 Form1.AY_Registered := RegisterFile('.ay',0)
else
 Form1.AY_Registered := UnRegisterFile('.ay',0)
end;

procedure TForm6.CheckBox21Click(Sender: TObject);
begin
if not RegSkin then RegisterType(2);
if CheckBox21.Checked then
 Form1.AYS_Registered := RegisterFile('.ays',2)
else
 Form1.AYS_Registered := UnRegisterFile('.ays',2)
end;

procedure TForm6.CheckBox44Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox44.Checked then
 Form1.MP3_Registered := RegisterFile('.mp3',3)
else
 Form1.MP3_Registered := UnRegisterFile('.mp3',3)
end;

procedure TForm6.CheckBox45Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox45.Checked then
 Form1.MP2_Registered := RegisterFile('.mp2',3)
else
 Form1.MP2_Registered := UnRegisterFile('.mp2',3)
end;

procedure TForm6.CheckBox46Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox46.Checked then
 Form1.MP1_Registered := RegisterFile('.mp1',3)
else
 Form1.MP1_Registered := UnRegisterFile('.mp1',3)
end;

procedure TForm6.CheckBox47Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox47.Checked then
 Form1.OGG_Registered := RegisterFile('.ogg',3)
else
 Form1.OGG_Registered := UnRegisterFile('.ogg',3)
end;

procedure TForm6.CheckBox48Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox48.Checked then
 Form1.WAV_Registered := RegisterFile('.wav',3)
else
 Form1.WAV_Registered := UnRegisterFile('.wav',3)
end;

procedure TForm6.CheckBox49Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox49.Checked then
 Form1.MO3_Registered := RegisterFile('.mo3',3)
else
 Form1.MO3_Registered := UnRegisterFile('.mo3',3)
end;

procedure TForm6.CheckBox50Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox50.Checked then
 Form1.IT_Registered := RegisterFile('.it',3)
else
 Form1.IT_Registered := UnRegisterFile('.it',3)
end;

procedure TForm6.CheckBox51Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox51.Checked then
 Form1.XM_Registered := RegisterFile('.xm',3)
else
 Form1.XM_Registered := UnRegisterFile('.xm',3)
end;

procedure TForm6.CheckBox52Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox52.Checked then
 Form1.S3M_Registered := RegisterFile('.s3m',3)
else
 Form1.S3M_Registered := UnRegisterFile('.s3m',3)
end;

procedure TForm6.CheckBox53Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox53.Checked then
 Form1.MTM_Registered := RegisterFile('.mtm',3)
else
 Form1.MTM_Registered := UnRegisterFile('.mtm',3)
end;

procedure TForm6.CheckBox54Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox54.Checked then
 Form1.MOD_Registered := RegisterFile('.mod',3)
else
 Form1.MOD_Registered := UnRegisterFile('.mod',3)
end;

procedure TForm6.CheckBox55Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox55.Checked then
 Form1.UMX_Registered := RegisterFile('.umx',3)
else
 Form1.UMX_Registered := UnRegisterFile('.umx',3)
end;

procedure TForm6.CheckBox39Click(Sender: TObject);
begin
if not RegBASS then RegisterType(3);
if CheckBox39.Checked then
 Form1.WMA_Registered := RegisterFile('.wma',3)
else
 Form1.WMA_Registered := UnRegisterFile('.wma',3)
end;

procedure TForm6.CheckBox56Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox56.Checked then
 Form1.CDA_Registered := RegisterFile('.cda',0)
else
 Form1.CDA_Registered := UnRegisterFile('.cda',0)
end;

procedure TForm6.CheckBox58Click(Sender: TObject);
begin
if not RegAudio then RegisterType(0);
if CheckBox58.Checked then
 Form1.PSM_Registered := RegisterFile('.psm',0)
else
 Form1.PSM_Registered := UnRegisterFile('.psm',0)
end;

function TForm6.ChangePLColor;
begin
ColorDialog1.Color := Color;
Result := ColorDialog1.Execute;
if Result then
 begin
  Color := ColorDialog1.Color;
  RedrawPlaylist(ShownFrom,0,False)
 end 
end;

procedure TForm6.Label1Click(Sender: TObject);
begin
if ChangePLColor(PLColor) then
 begin
  Label1.Font.Color := PLColor;
  Label12.Font.Color := PLColor
 end
end;

procedure TForm6.Label12Click(Sender: TObject);
begin
if ChangePLColor(PLColorBk) then
 begin
  Label1.Color := PLColorBk;
  Label12.Color := PLColorBk;
  Label18.Color := PLColorBk
 end
end;

procedure TForm6.Label13Click(Sender: TObject);
begin
if ChangePLColor(PLColorSel) then
 begin
  Label13.Font.Color := PLColorSel;
  Label14.Font.Color := PLColorSel
 end
end;

procedure TForm6.Label14Click(Sender: TObject);
begin
if ChangePLColor(PLColorBkSel) then
 begin
  Label13.Color := PLColorBkSel;
  Label14.Color := PLColorBkSel;
  Label17.Color := PLColorBkSel;
  Label19.Color := PLColorBkSel
 end
end;

procedure TForm6.Label15Click(Sender: TObject);
begin
if ChangePLColor(PLColorPl) then
 begin
  Label15.Font.Color := PLColorPl;
  Label16.Font.Color := PLColorPl
 end
end;

procedure TForm6.Label16Click(Sender: TObject);
begin
if ChangePLColor(PLColorBkPl) then
 begin
  Label15.Color := PLColorBkPl;
  Label16.Color := PLColorBkPl
 end
end;

procedure TForm6.Label17Click(Sender: TObject);
begin
if ChangePLColor(PLColorPlSel) then Label17.Font.Color := PLColorPlSel
end;

procedure TForm6.Label18Click(Sender: TObject);
begin
if ChangePLColor(PLColorErr) then Label18.Font.Color := PLColorErr
end;

procedure TForm6.Label19Click(Sender: TObject);
begin
if ChangePLColor(PLColorErrSel) then Label19.Font.Color := PLColorErrSel
end;

end.
