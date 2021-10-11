{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit Players;

interface

uses Windows, AY, SysUtils;

type
 EFileStructureError = class(Exception);
 ErrorCodes = (FileNoError,ErFileNotFound,ErReadingFile,ErLZHDataIsNotValid,
               ErFLSAddrNotDetected,ErBASSError,ErBadFileStructure);

const
 ImageID = 'Disk Image: ';
 ImageIDLen = Length(ImageID);
 Errors:array[Succ(Low(ErrorCodes))..High(ErrorCodes)] of string =
 ('File not found','Error reading file','LZH data is not valid',
  'Address of compilation is not detected: not FLS-file',
  'Error calling BASS.DLL','Bad file structure');

type
//Trackers structure
PModTypes = ^ModTypes;
ModTypes = packed record
case Integer of
0: (Index:array[0..65536] of byte);
1: (ST_Delay:byte;
    ST_PositionsPointer,ST_OrnamentsPointer,ST_PatternsPointer:word;
    ST_Name:array[0..17]of char;
    ST_Size:word);
2: (ASC1_Delay,ASC1_LoopingPosition:byte;
    ASC1_PatternsPointers,ASC1_SamplesPointers,ASC1_OrnamentsPointers:word;
    ASC1_Number_Of_Positions:byte;
    ASC1_Positions:array[0..65535-9]of byte);
3: (ASC0_Delay:byte;
    ASC0_PatternsPointers,ASC0_SamplesPointers,ASC0_OrnamentsPointers:word;
    ASC0_Number_Of_Positions:byte;
    ASC0_Positions:array[0..65535-8]of byte);
4: (STP_Delay:byte;
    STP_PositionsPointer,STP_PatternsPointer,
    STP_OrnamentsPointer,STP_SamplesPointer:word;
    STP_Init_Id:byte);
5: (PT2_Delay:byte;
    PT2_NumberOfPositions:byte;
    PT2_LoopPosition:byte;
    PT2_SamplesPointers:array[0..31]of word;
    PT2_OrnamentsPointers:array[0..15]of word;
    PT2_PatternsPointer:word;
    PT2_MusicName:array[0..29]of char;
    PT2_PositionList:array[0..65535 - 131]of byte);
6: (PT3_MusicName:array[0..$62]of char;
    PT3_TonTableId:byte;
    PT3_Delay:byte;
    PT3_NumberOfPositions:byte;
    PT3_LoopPosition:byte;
    PT3_PatternsPointer:word;
    PT3_SamplesPointers:array[0..31]of word;
    PT3_OrnamentsPointers:array[0..15]of word;
    PT3_PositionList:array[0..65535-201]of byte);
7: (PSC_MusicName:array[0..68]of char;
    PSC_UnknownPointer:word;
    PSC_PatternsPointer:word;
    PSC_Delay:byte;
    PSC_OrnamentsPointer:word;
    PSC_SamplesPointers:array[0..31]of word);
8: (FTC_MusicName:array[0..68]of char;
    FTC_Delay:byte;
    FTC_Loop_Position:byte;
    FTC_Slack:integer;
    FTC_PatternsPointer:word;
    FTC_Slack2:array[0..4]of byte;
    FTC_SamplesPointers:array[0..31]of word;
    FTC_OrnamentsPointers:array[0..32]of word;
    FTC_Positions:array[0..(65536 - $d4) div 2 - 1] of packed record
                                            Pattern:byte;
                                            Transposition:shortint;
                                            end);
9: (PT1_Delay:byte;
    PT1_NumberOfPositions:byte;
    PT1_LoopPosition:byte;
    PT1_SamplesPointers:array[0..15]of word;
    PT1_OrnamentsPointers:array[0..15]of word;
    PT1_PatternsPointer:word;
    PT1_MusicName:array[0..29]of char;
    PT1_PositionList:array[0..65535-99]of byte);
10:(FLS_PositionsPointer:word;
    FLS_OrnamentsPointer:word;
    FLS_SamplesPointer:word;
    FLS_PatternsPointers:array[1..(65536-6)div 6] of packed record
     PatternA,PatternB,PatternC:word;
    end);
11:(SQT_Size,SQT_SamplesPointer,SQT_OrnamentsPointer,SQT_PatternsPointer,
    SQT_PositionsPointer,SQT_LoopPointer:word);
12:(GTR_Delay:byte;
    GTR_ID:array[0..3] of char;
    GTR_Address:word;
    GTR_Name:array[0..31] of char;
    GTR_SamplesPointers:array[0..14]of word;
    GTR_OrnamentsPointers:array[0..15]of word;
    GTR_PatternsPointers:array[0..31] of packed record
     PatternA,PatternB,PatternC:word;
    end;
    GTR_NumberOfPositions:byte;
    GTR_LoopPosition:byte;
    GTR_Positions:array[0..65536 - 295 - 1]of byte);
13:(PSM_PositionsPointer:word;
    PSM_SamplesPointer:word;
    PSM_OrnamentsPointer:word;
    PSM_PatternsPointer:word;
    PSM_Remark:array[0..65535-8]of byte);
end;

type

//AY-file header and structures
 TAYFileHeader = packed record
   FileID,TypeID:longword;
   FileVersion,PlayerVersion:byte;
   PSpecialPlayer,PAuthor,PMisc:smallint;
   NumOfSongs,FirstSong:byte;
   PSongsStructure:smallint;
 end;
 TSongStructure = packed record
   PSongName,PSongData:smallint;
 end;
 TSongData = packed record
   ChanA,ChanB,ChanC,Noise:byte;
   SongLength:word;
   FadeLength:word;
   HiReg,LoReg:byte;
   PPoints,PAddresses:smallint;
 end;
 TPoints = packed record
   Stek,Init,Inter:word;
 end;

//AYM-file header
 TAYMFileHeader = packed record
   AYM:array[0..2] of char;
   Rev:char;
   Name:array[0..27] of char;
   Author:array[0..15] of char;
   Init,Play:word;
   MusMin,MusMax,MusPos,RegPos:byte;
   AF,BC,DE,HL,IX,IY:word;
   Blocks:byte;
 end;
 TAYMBlock = packed record
   start,size:word;
 end;

//VTX-file header
 TVTXFileHeader = packed record
  Id:word;
  Mode:byte;
  Loop:word;
  ChipFrq:dword;
  InterFrq:byte;
  Year:word;
  UnpackSize:dword;
 end;

//YM5- and YM6-file header
 PYM5FileHeader = ^TYM5FileHeader;
 TYM5FileHeader = packed record
  Id:dword;
  Leo:array[0..7]of char;
  Num_of_tiks:dword;
  Song_Attr:dword;
  Num_of_Dig:word;
  ChipFrq:dword;
  InterFrq:word;
  Loop:dword;
  Add_Size:word;
 end;

//LZH-file header
 TLZHFileHeader = Packed Record
  HSize      : Byte;
  ChkSum     : Byte;
  Method     : Array[1..5] of Char;
  CompSize   : LongInt;
  UCompSize  : LongInt;
  Dos_DT     : LongInt;
  Attr       : Word;
  FileNameLen: Byte;
 end;

 FXM_Stek = packed array of word;

 PPT3_Channel_Parameters = ^PT3_Channel_Parameters;
 PT3_Channel_Parameters = record
  Address_In_Pattern,
  OrnamentPointer,
  SamplePointer,
  Ton:word;
  Loop_Ornament_Position,
  Ornament_Length,
  Position_In_Ornament,
  Loop_Sample_Position,
  Sample_Length,
  Position_In_Sample,
  Volume,
  Number_Of_Notes_To_Skip,
  Note,
  Slide_To_Note,
  Amplitude:byte;
  Envelope_Enabled,
  Enabled,
  SimpleGliss:boolean;
  Current_Amplitude_Sliding,
  Current_Noise_Sliding,
  Current_Envelope_Sliding,
  Ton_Slide_Count,
  Current_OnOff,
  OnOff_Delay,
  OffOn_Delay,
  Ton_Slide_Delay,
  Current_Ton_Sliding,
  Ton_Accumulator,
  Ton_Slide_Step,
  Ton_Delta:smallint;
  Note_Skip_Counter:shortint
 end;

 PPT3_Parameters = ^PT3_Parameters;
 PT3_Parameters = record
  PT3_Version:integer;
  Env_Base:packed record
  case Boolean of
  True: (wrd:smallint);
  False:(lo:byte;
         hi:byte);
  end;
  Cur_Env_Slide,
  Env_Slide_Add:smallint;
  Cur_Env_Delay,
  Env_Delay:shortint;
  Noise_Base,
  Delay,
  AddToNoise,
  DelayCounter,
  CurrentPosition:byte;
 end;

 PPT2_Channel_Parameters = ^PT2_Channel_Parameters;
 PT2_Channel_Parameters = record
  Address_In_Pattern,
  OrnamentPointer,
  SamplePointer,
  Ton:word;
  Loop_Ornament_Position,
  Ornament_Length,
  Position_In_Ornament,
  Loop_Sample_Position,
  Sample_Length,
  Position_In_Sample,
  Volume,
  Number_Of_Notes_To_Skip,
  Note,
  Slide_To_Note,
  Amplitude:byte;
  Current_Ton_Sliding,
  Ton_Delta:smallint;
  GlissType:integer;
  Envelope_Enabled,
  Enabled:boolean;
  Glissade,
  Addition_To_Noise,
  Note_Skip_Counter:shortint
 end;
 PPT2_Parameters = ^PT2_Parameters;
 PT2_Parameters = record
  DelayCounter,
  Delay,
  CurrentPosition:byte;
 end;

 PSTC_Channel_Parameters = ^STC_Channel_Parameters;
 STC_Channel_Parameters = record
  Address_In_Pattern,
  SamplePointer,
  OrnamentPointer,
  Ton:word;
  Amplitude,
  Note,
  Position_In_Sample,
  Number_Of_Notes_To_Skip:byte;
  Sample_Tik_Counter,
  Note_Skip_Counter:shortint;
  Envelope_Enabled:boolean;
 end;
 PSTC_Parameters = ^STC_Parameters;
 STC_Parameters = record
  DelayCounter,
  Transposition,
  CurrentPosition:byte;
 end;

 PSTP_Channel_Parameters = ^STP_Channel_Parameters;
 STP_Channel_Parameters = record
  OrnamentPointer,
  SamplePointer,
  Address_In_Pattern,
  Ton:word;
  Position_In_Ornament,
  Loop_Ornament_Position,
  Ornament_Length,
  Position_In_Sample,
  Loop_Sample_Position,
  Sample_Length,
  Volume,
  Number_Of_Notes_To_Skip,
  Note,
  Amplitude:byte;
  Current_Ton_Sliding:smallint;
  Envelope_Enabled,
  Enabled:boolean;
  Glissade,
  Note_Skip_Counter:shortint
 end;
 PSTP_Parameters = ^STP_Parameters;
 STP_Parameters = record
  DelayCounter,
  CurrentPosition,
  Transposition:byte;
 end;

 PASC_Channel_Parameters = ^ASC_Channel_Parameters;
 ASC_Channel_Parameters = record
  Initial_Point_In_Sample,
  Point_In_Sample,
  Loop_Point_In_Sample,
  Initial_Point_In_Ornament,
  Point_In_Ornament,
  Loop_Point_In_Ornament,
  Address_In_Pattern,
  Ton,
  Ton_Deviation:word;
  Note,
  Addition_To_Note,
  Number_Of_Notes_To_Skip,
  Initial_Noise,
  Current_Noise,
  Volume,
  Ton_Sliding_Counter,
  Amplitude,
  Amplitude_Delay,
  Amplitude_Delay_Counter:byte;
  Current_Ton_Sliding,
  Substruction_for_Ton_Sliding:smallint;
  Note_Skip_Counter,
  Addition_To_Amplitude:shortint;
  Envelope_Enabled,
  Sound_Enabled,
  Sample_Finished,
  Break_Sample_Loop,
  Break_Ornament_Loop:boolean;
 end;
 PASC_Parameters = ^ASC_Parameters;
 ASC_Parameters = record
  Delay,
  DelayCounter,
  CurrentPosition:byte;
 end;

 PPSC_Channel_Parameters = ^PSC_Channel_Parameters;
 PSC_Channel_Parameters = record
  Address_In_Pattern,
  OrnamentPointer,
  SamplePointer,
  Ton:word;
  Current_Ton_Sliding,
  Ton_Accumulator,
  Addition_To_Ton:smallint;
  Initial_Volume,
  Note_Skip_Counter:shortint;
  Note,
  Volume,
  Amplitude,
  Volume_Counter,
  Volume_Counter1,
  Volume_Counter_Init,
  Noise_Accumulator,
  Position_In_Sample,
  Loop_Sample_Position,
  Position_In_Ornament,
  Loop_Ornament_Position:byte;
  Enabled,
  Ornament_Enabled,
  Envelope_Enabled,
  Gliss,
  Ton_Slide_Enabled,
  Break_Sample_Loop,
  Break_Ornament_Loop,
  Volume_Inc:boolean;
 end;

 PPSC_Parameters = ^PSC_Parameters;
 PSC_Parameters = record
  Delay,
  DelayCounter,
  Lines_Counter,
  Noise_Base,
  PSC_Version:byte;
  Positions_Pointer:word;
 end;

 PSQT_Channel_Parameters = ^SQT_Channel_Parameters;
 SQT_Channel_Parameters = record
  Address_In_Pattern,
  SamplePointer,
  Point_In_Sample,
  OrnamentPointer,
  Point_In_Ornament,
  Ton,
  ix27:word;
  Volume,
  Amplitude,
  Note,
  ix21:byte;
  Ton_Slide_Step,
  Current_Ton_Sliding:smallint;
  Sample_Tik_Counter,
  Ornament_Tik_Counter,
  Transposit:shortint;
  Enabled,
  Envelope_Enabled,
  Ornament_Enabled,
  Gliss,
  MixNoise,
  MixTon,
  b4ix0,b6ix0,b7ix0:boolean;
 end;

 PSQT_Parameters = ^SQT_Parameters;
 SQT_Parameters = record
  Delay,
  DelayCounter,
  Lines_Counter:byte;
  Positions_Pointer:word;
 end;

 PFTC_Channel_Parameters = ^FTC_Channel_Parameters;
 FTC_Channel_Parameters = record
  Address_In_Pattern,
  OrnamentPointer,
  SamplePointer,
  Envelope_Accumulator,
  Envelope,
  Ton:word;
  Ornament_Length,
  Loop_Ornament_Position,
  Position_In_Ornament,
  Sample_Length,
  Loop_Sample_Position,
  Position_In_Sample,
  Sample_Noise_Accumulator,
  Noise_Accumulator,
  Note_Accumulator,
  Ton_Slide_Direction,
  Volume,
  Noise,
  Amplitude,
  Previous_Note,
  Note:byte;
  Note_Skip_Counter,
  Volume_Slide:shortint;
  Addition_To_Ton,
  Ton_Slide_Step,
  Ton_Slide_Step1,
  Current_Ton_Sliding,
  Ton_Accumulator:smallint;
  Envelope_Enabled,
  Sample_Enabled:boolean;
 end;

 PFTC_Parameters = ^FTC_Parameters;
 FTC_Parameters = record
  Delay,
  DelayCounter,
  Transposition,
  CurrentPosition:byte;
 end;

 PPT1_Channel_Parameters = ^PT1_Channel_Parameters;
 PT1_Channel_Parameters = record
  Address_In_Pattern,
  OrnamentPointer,
  SamplePointer,
  Ton:word;
  Number_Of_Notes_To_Skip,
  Volume,
  Loop_Sample_Position,
  Position_In_Sample,
  Sample_Length,
  Amplitude,
  Note:byte;
  Note_Skip_Counter:shortint;
  Envelope_Enabled,
  Enabled:boolean;
 end;

 PPT1_Parameters = ^PT1_Parameters;
 PT1_Parameters = record
  Delay,
  DelayCounter,
  CurrentPosition:byte;
 end;

 PFLS_Channel_Parameters = ^FLS_Channel_Parameters;
 FLS_Channel_Parameters = record
  Address_In_Pattern,
  OrnamentPointer,
  SamplePointer,
  Ton:word;
  Sample_Length,
  Loop_Sample_Position,
  Position_In_Sample,
  Amplitude,
  Number_Of_Notes_To_Skip,
  Note:byte;
  Note_Skip_Counter,
  Sample_Tik_Counter:shortint;
  Envelope_Enabled,
  Ornament_Enabled:boolean;
 end;

 PFLS_Parameters = ^FLS_Parameters;
 FLS_Parameters = record
  Delay,
  DelayCounter,
  CurrentPosition:byte;
 end;

 PGTR_Channel_Parameters = ^GTR_Channel_Parameters;
 GTR_Channel_Parameters = record
  SamplePointer,
  OrnamentPointer,
  Address_In_Pattern,
  Ton:word;
  Position_In_Sample,
  Loop_Sample_Position,
  Sample_Length,
  Position_In_Ornament,
  Loop_Ornament_Position,
  Ornament_Length,
  Volume,
  Note,
  Amplitude:byte;
  Note_Skip_Counter:shortint;
  Envelope_Enabled,
  Enabled:boolean;
 end;

 PGTR_Parameters = ^GTR_Parameters;
 GTR_Parameters = record
  DelayCounter,
  CurrentPosition:byte;
 end;

 PFXM_Channel_Parameters = ^FXM_Channel_Parameters;
 FXM_Channel_Parameters = record
  Address_In_Pattern,
  Point_In_Sample,
  SamplePointer,
  Point_In_Ornament,
  OrnamentPointer,
  Ton:word;
  FXM_Mixer,
  Note,
  Volume,
  Amplitude:byte;
  Transposit,
  Note_Skip_Counter,
  Sample_Tik_Counter:shortint;
  b0e,b1e,b2e,b3e:boolean;
 end;

 PFXM_Parameters = ^FXM_Parameters;
 FXM_Parameters = record
  Address:word;
  Noise_Base,
  amad_andsix:byte;
 end;

 PPSM_Channel_Parameters = ^PSM_Channel_Parameters;
 PSM_Channel_Parameters = record
  Address_In_Pattern,
  RetAddress,
  DivShift,Ton:word;
  Number_Of_Notes_To_Skip,Note_Skip_Counter,
  Amplitude,RetCnt,Vol,VolCnt,LoopCnt,Orn,EnvType,EnvDiv,Samp:byte;
  OrnTick,SmpTick,Note:shortint;
 end;

 PPSM_Parameters = ^PSM_Parameters;
 PSM_Parameters = record
  Delay,
  DelayCounter:byte;
  CurrentPosition:byte;
  Transposition:shortint;
  Finished:boolean;
 end;

 TPlParams = record
  case Integer of
  0: (PT3:PT3_Parameters;PT3_A,PT3_B,PT3_C:PT3_Channel_Parameters);
  1: (PT2:PT2_Parameters;PT2_A,PT2_B,PT2_C:PT2_Channel_Parameters);
  2: (PT1:PT1_Parameters;PT1_A,PT1_B,PT1_C:PT1_Channel_Parameters);
  3: (STC:STC_Parameters;STC_A,STC_B,STC_C:STC_Channel_Parameters);
  4: (STP:STP_Parameters;STP_A,STP_B,STP_C:STP_Channel_Parameters);
  5: (ASC:ASC_Parameters;ASC_A,ASC_B,ASC_C:ASC_Channel_Parameters);
  6: (PSC:PSC_Parameters;PSC_A,PSC_B,PSC_C:PSC_Channel_Parameters);
  7: (SQT:SQT_Parameters;SQT_A,SQT_B,SQT_C:SQT_Channel_Parameters);
  8: (FTC:FTC_Parameters;FTC_A,FTC_B,FTC_C:FTC_Channel_Parameters);
  9: (FLS:FLS_Parameters;FLS_A,FLS_B,FLS_C:FLS_Channel_Parameters);
  10:(GTR:GTR_Parameters;GTR_A,GTR_B,GTR_C:GTR_Channel_Parameters);
  11:(FXM:FXM_Parameters;FXM_A,FXM_B,FXM_C:FXM_Channel_Parameters);
  12:(PSM:PSM_Parameters;PSM_A,PSM_B,PSM_C:PSM_Channel_Parameters);
 end;

//Supported types
 Available_Types =
 (Unknown, OUTFile, ZXAYFile, EPSGFile, AYFile, AYMFile, STCFile, ASCFile,
  ASC0File, STPFile, PSCFile, FLSFile, FTCFile, PT1File, PT2File, PT3File,
  SQTFile, GTRFile, FXMFile, PSMFile, VTXFile, YM2File, YM3File, YM3BFile,
  YM5File, YM6File, PSGFile, MP3File, MP2File, MP1File, OGGFile, WAVFile,
  WMAFile, MO3File, ITFile, XMFile, S3MFile, MTMFile, MODFile, UMXFile,
  CDAFile);

const
 MinType = Succ(Low(Available_Types));
 MaxType = High(Available_Types);
 MinVBLType = STCFile;
 MaxVBLType = PSGFile;
 TrkFileMin = STCFile;
 TrkFileMax = PSMFile;
 StreamFileMin = MP3File;
 StreamFileMax = WMAFile;
 MpegFileMin = MP3File;
 MpegFileMax = MP1File;
 MODFilesMin = MO3File;
 MODFilesMax = UMXFile;
 BASSFileMin = MP3File;
 BASSFileMax = UMXFile;
 STypes:array[MinType..MaxType] of string[4] =
 ('OUT','ZXAY','EPSG','AY','AYM','STC','ASC','ASC0','STP','PSC','FLS','FTC',
  'PT1','PT2','PT3','SQT','GTR','FXM','PSM','VTX','YM2','YM3','YM3b','YM5',
  'YM6','PSG','MP3','MP2','MP1','OGG','WAV','WMA','MO3','IT','XM','S3M','MTM',
  'MOD','UMX','CDA');
 SExts:array[MinType..MaxType] of string[5] =
 ('.OUT','.ZXAY','.PSG','.AY','.AYM','.STC','.ASC','.ASC','.STP','.PSC','.FLS',
  '.FTC','.PT1','.PT2','.PT3','.SQT','.GTR','.FXM','.PSM','.VTX','.YM','.YM',
  '.YM','.YM','.YM','.PSG','.MP3','.MP2','.MP1','.OGG','.WAV','.WMA','.MO3',
  '.IT','.XM','.S3M','.MTM','.MOD','.UMX','.CDA');

type
  PID3v1 = ^TID3v1;
  TID3v1 = packed record
   Tag:array[0..2] of char;
   Title,Author,Album:array[0..29] of char;
   Year:array[0..3] of char;
   Comment:array[0..29] of char;
   Genre:byte;
  end;
  PID3V2Header = ^TID3V2Header;
  TID3V2Header = packed record
   Tag:array[0..2] of char;
   VerMajor,VerMinor,Flags:byte;
   Size:DWORD;
  end;
  PID3V2ExtHeader = ^TID3V2ExtHeader;
  TID3V2ExtHeader = packed record
   Size:DWORD;
   Flags:word;
   PaddingSize:DWORD;
  end;
  PID3V2Frame = ^TID3V2Frame;
  TID3V2Frame = packed record
   Id,Size:DWORD;
   Flags:word;
  end;

var
 RAM:ModTypes;
 Global_Tick_Counter,Global_Tick_Max:integer;
 EPSG_TStateMax:integer;
 NumberOfVBLs,LoopVBL:integer;
 VTX_Offset,Position_In_VTX:integer;
 PVTXYMUnpackedData:PArrayOfByte;
 FinderWorksNow:boolean;
 FXM_StekA,FXM_StekB,FXM_StekC:FXM_Stek;
 PlParams:TPlParams;
 Trackers_Slider_Points:array of record
  PlPars:TPlParams;
  AYRegs:TRegisterAY;
  FXM_StekA,FXM_StekB,FXM_StekC:FXM_Stek;
  DWParam1,DWParam2,DWParam3:DWORD;
 end;
 AYSongData:TSongData;
 AYPoints:TPoints;
 AYBlocks:integer;
 AYMFileHeader:TAYMFileHeader;
 MakeBuffer:procedure(Buf:pointer);
 All_GetRegisters:procedure;
 CurFileType:Available_Types;
 FileOpened:boolean = False;
 FileAvailable:boolean = False;
 FileLoaded:boolean = False;
 FileHandle:integer;
 YM6TiksOnInt,YM6SamTiksOnInt:real;
 YM6SinusTable:array [0..15,0..7] of byte;
 AtariTimerPeriod1,AtariTimerPeriod2:real;
 AtariTimerCounter1,AtariTimerCounter2:real;
 YM6CurTik:real;
 YM6Tiks:int64;
 CurItem:record
  PLStr,Title,Author,Programm,Comment,Tracker,FileName:string;
 end;
 CurCDNum,CurCDTrk:integer;

function LoadTrackerModule(var Module:ModTypes;Index,MAddr,MLen:integer;Mem:pointer;FType:Available_Types):boolean;
procedure PrepareItem(Index:integer);
procedure InitForAllTypes(InitAll:boolean);
procedure InsertTitleASC(var Module:ModTypes; var Sz:integer; const TtlStr:string);
procedure InsertTitleSTP(var Module:ModTypes; var Sz:integer; const TtlStr:string);
procedure FindModules;
procedure AddCDTrack(CDN,TN:integer;Inited:boolean);
procedure Add_Songs_From_File(File_Name:string;Detect:boolean);
procedure FreePlayingResourses;

procedure MakeBufferOUT(Buf:pointer);
procedure OUT_Get_Registers;
procedure MakeBufferVTX(Buf:pointer);
procedure VTX_YM3_YM3b_Get_Registers;
procedure MakeBufferYM2(Buf:pointer);
procedure YM2_Get_Registers;
procedure MakeBufferYM5(Buf:pointer);
procedure YM5_Get_Registers;
procedure YM5i_Get_Registers;
procedure MakeBufferYM6(Buf:pointer);
procedure YM6_Get_Registers;
procedure YM6i_Get_Registers;
procedure YM6_Extra_GetRegisters;
procedure MakeBufferEPSG(Buf:pointer);
procedure EPSG_Get_Registers;
procedure MakeBufferPSG(Buf:pointer);
procedure PSG_Get_Registers;
procedure MakeBufferZXAY(Buf:pointer);
procedure ZXAY_Get_Registers;
procedure MakeBufferPT3(Buf:pointer);
procedure PT3_Get_Registers;
procedure MakeBufferPT2(Buf:pointer);
procedure PT2_Get_Registers;
procedure MakeBufferPT1(Buf:pointer);
procedure PT1_Get_Registers;
procedure MakeBufferSTC(Buf:pointer);
procedure STC_Get_Registers;
procedure MakeBufferSTP(Buf:pointer);
procedure STP_Get_Registers;
procedure MakeBufferASC(Buf:pointer);
procedure ASC_Get_Registers;
procedure MakeBufferPSC(Buf:pointer);
procedure PSC_Get_Registers;
procedure MakeBufferSQT(Buf:pointer);
procedure SQT_Get_Registers;
procedure MakeBufferFTC(Buf:pointer);
procedure FTC_Get_Registers;
procedure MakeBufferFLS(Buf:pointer);
procedure FLS_Get_Registers;
procedure MakeBufferGTR(Buf:pointer);
procedure GTR_Get_Registers;
procedure MakeBufferFXM(Buf:pointer);
procedure FXM_Get_Registers;
procedure MakeBufferPSM(Buf:pointer);
procedure PSM_Get_Registers;
procedure MakeBufferAY(Buf:pointer);
procedure AY_Get_Registers;

procedure Calculate_Slider_Points;
procedure RerollMusic(newpos,maxpos,p:integer;f:double);

procedure GetTimeFXM(Module:PModTypes;Address:integer;var Tm,Lp:integer);
procedure GetTimeGTR(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimeSTC(Module:PModTypes;var Tm:integer);
procedure GetTimeASC(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimeSTP(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimePT2(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimePT3(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimePSC(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimeFTC(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimeSQT(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimePT1(Module:PModTypes;var Tm,Lp:integer);
procedure GetTimeFLS(Module:PModTypes;var Tm:integer);
procedure GetTimePSM(Module:PModTypes;var Tm,Lp:integer);
procedure GetTime(FileHandle,Index:integer;
                   AlreadyLoaded:boolean;var Lp:integer);

procedure SuspendPlaying;

procedure YMizeSample(Buf:PArrayOfByte;Len:integer);

implementation

uses MainWin, PlayList, UniReader, Lh5, Z80, WaveOutAPI, Classes,
     ProgBox, Messages, Mixer, Tools, lightBASS, CDviaMCI, digidrum;

const     

KsaId = 'KSA SOFTWARE COMPILATION OF ';
AscId = 'ASM COMPILATION OF ';

//Ton tables of different trackers
{ASC Sound Master}
 ASM_Table:array[0..$55]of word=
($edc,$e07,$d3e,$c80,$bcc,$b22,$a82,$9ec,$95c,$8d6,$858,$7e0,$76e,$704,$69f,
 $640,$5e6,$591,$541,$4f6,$4ae,$46b,$42c,$3f0,$3b7,$382,$34f,$320,$2f3,$2c8,
 $2a1,$27b,$257,$236,$216,$1f8,$1dc,$1c1,$1a8,$190,$179,$164,$150,$13d,$12c,
 $11b,$10b,$fc,$ee,$e0,$d4,$c8,$bd,$b2,$a8,$9f,$96,$8d,$85,$7e,$77,$70,$6a,
 $64,$5e,$59,$54,$50,$4b,$47,$43,$3f,$3c,$38,$35,$32,$2f,$2d,$2a,$28,$26,$24,
 $22,$20,$1e,$1c);

{Sound Tracker}
 ST_Table:Array[0..95]of word=
($ef8,$e10,$d60,$c80,$bd8,$b28,$a88,$9f0,$960,$8e0,$858,$7e0,$77c,$708,$6b0,
 $640,$5ec,$594,$544,$4f8,$4b0,$470,$42c,$3f0,$3be,$384,$358,$320,$2f6,$2ca,
 $2a2,$27c,$258,$238,$216,$1f8,$1df,$1c2,$1ac,$190,$17b,$165,$151,$13e,$12c,
 $11c,$10b,$fc,$ef,$e1,$d6,$c8,$bd,$b2,$a8,$9f,$96,$8e,$85,$7e,$77,$70,$6b,
 $64,$5e,$59,$54,$4f,$4b,$47,$42,$3f,$3b,$38,$35,$32,$2f,$2c,$2a,$27,$25,$23,
 $21,$1f,$1d,$1c,$1a,$19,$17,$16,$15,$13,$12,$11,$10,$f);

{SQ-Tracker}
 SQT_Table:array[0..$5f]of word=
($d5d,$c9c,$be7,$b3c,$a9b,$a02,$973,$8eb,$86b,$7f2,$780,$714,$6ae,$64e,
 $5f4,$59e,$54f,$501,$4b9,$475,$435,$3f9,$3c0,$38a,$357,$327,$2fa,$2cf,$2a7,
 $281,$25d,$23b,$21b,$1fc,$1e0,$1c5,$1ac,$194,$17d,$168,$153,$140,$12e,$11d,
 $10d,$fe,$f0,$e2,$d6,$ca,$be,$b4,$aa,$a0,$97,$8f,$87,$7f,$78,$71,$6b,$65,$5f,
 $5a,$55,$50,$4c,$47,$43,$40,$3c,$39,$35,$32,$30,$2d,$2a,$28,$26,$24,$22,$20,
 $1e,$1c,$1b,$19,$18,$16,$15,$14,$13,$12,$11,$10,$f,$e);

{Fuxoft AY Language}
 FXM_Table:Array[0..$53]of word=
($fbf,$edc,$e07,$d3d,$c7f,$bcc,$b22,$a82,$9eb,$95d,$8d6,$857,$7df,$76e,$703,
 $69f,$640,$5e6,$591,$541,$4f6,$4ae,$46b,$42c,$3f0,$3b7,$382,$34f,$320,$2f3,
 $2c8,$2a1,$27b,$257,$236,$216,$1f8,$1dc,$1c1,$1a8,$190,$179,$164,$150,$13d,
 $12c,$11b,$10b,$fc,$ee,$e0,$d4,$c8,$bd,$b2,$a8,$9f,$96,$8d,$85,$7e,$77,$70,
 $6a,$64,$5e,$59,$54,$4f,$4b,$47,$43,$3f,$3b,$38,$35,$32,$2f,$2d,$2a,$28,$25,
 $23,$21);

{Pro Sound Maker}
 PSM_Table:Array[0..95]of word=
($D3D,$C7F,$BCB,$B22,$A82,$9EB,$95D,$8D6,$857,$7DF,$76E,$703,
 $69F,$63F,$5E6,$591,$541,$4F6,$4AE,$46B,$42C,$3F0,$3B7,$382,
 $34F,$320,$2F3,$2C8,$2A1,$27B,$257,$236,$216,$1F8,$1DC,$1C1,
 $1A8,$190,$179,$164,$150,$13D,$12C,$11B,$10B,$0FC,$0EE,$0E0,
 $0D4,$0C8,$0BD,$0B2,$0A8,$09F,$096,$08D,$085,$07E,$077,$070,
 $06A,$064,$05E,$059,$054,$04F,$04B,$047,$043,$03F,$03B,$038,
 $035,$032,$02F,$02D,$02A,$028,$025,$023,$021,$01F,$01E,$01C,
 $01A,$019,$018,$016,$015,$014,$013,$012,$011,$010,$00F,$00E);

type
 PT3ToneTable = array[0..95] of word;
 PT3VolTable = array[0..15,0..15] of byte;

const
{Table #0 of Pro Tracker 3.3x - 3.4r}
 PT3NoteTable_PT_33_34r:PT3ToneTable = (
  $0C21,$0B73,$0ACE,$0A33,$09A0,$0916,$0893,$0818,$07A4,$0736,$06CE,$066D,
  $0610,$05B9,$0567,$0519,$04D0,$048B,$0449,$040C,$03D2,$039B,$0367,$0336,
  $0308,$02DC,$02B3,$028C,$0268,$0245,$0224,$0206,$01E9,$01CD,$01B3,$019B,
  $0184,$016E,$0159,$0146,$0134,$0122,$0112,$0103,$00F4,$00E6,$00D9,$00CD,
  $00C2,$00B7,$00AC,$00A3,$009A,$0091,$0089,$0081,$007A,$0073,$006C,$0066,
  $0061,$005B,$0056,$0051,$004D,$0048,$0044,$0040,$003D,$0039,$0036,$0033,
  $0030,$002D,$002B,$0028,$0026,$0024,$0022,$0020,$001E,$001C,$001B,$0019,
  $0018,$0016,$0015,$0014,$0013,$0012,$0011,$0010,$000F,$000E,$000D,$000C);

{Table #0 of Pro Tracker 3.4x - 3.5x}
 PT3NoteTable_PT_34_35:PT3ToneTable = (
  $0C22,$0B73,$0ACF,$0A33,$09A1,$0917,$0894,$0819,$07A4,$0737,$06CF,$066D,
  $0611,$05BA,$0567,$051A,$04D0,$048B,$044A,$040C,$03D2,$039B,$0367,$0337,
  $0308,$02DD,$02B4,$028D,$0268,$0246,$0225,$0206,$01E9,$01CE,$01B4,$019B,
  $0184,$016E,$015A,$0146,$0134,$0123,$0112,$0103,$00F5,$00E7,$00DA,$00CE,
  $00C2,$00B7,$00AD,$00A3,$009A,$0091,$0089,$0082,$007A,$0073,$006D,$0067,
  $0061,$005C,$0056,$0052,$004D,$0049,$0045,$0041,$003D,$003A,$0036,$0033,
  $0031,$002E,$002B,$0029,$0027,$0024,$0022,$0020,$001F,$001D,$001B,$001A,
  $0018,$0017,$0016,$0014,$0013,$0012,$0011,$0010,$000F,$000E,$000D,$000C);

{Table #1 of Pro Tracker 3.3x - 3.5x)}
 PT3NoteTable_ST:PT3ToneTable = (
  $0EF8,$0E10,$0D60,$0C80,$0BD8,$0B28,$0A88,$09F0,$0960,$08E0,$0858,$07E0,
  $077C,$0708,$06B0,$0640,$05EC,$0594,$0544,$04F8,$04B0,$0470,$042C,$03FD,
  $03BE,$0384,$0358,$0320,$02F6,$02CA,$02A2,$027C,$0258,$0238,$0216,$01F8,
  $01DF,$01C2,$01AC,$0190,$017B,$0165,$0151,$013E,$012C,$011C,$010A,$00FC,
  $00EF,$00E1,$00D6,$00C8,$00BD,$00B2,$00A8,$009F,$0096,$008E,$0085,$007E,
  $0077,$0070,$006B,$0064,$005E,$0059,$0054,$004F,$004B,$0047,$0042,$003F,
  $003B,$0038,$0035,$0032,$002F,$002C,$002A,$0027,$0025,$0023,$0021,$001F,
  $001D,$001C,$001A,$0019,$0017,$0016,$0015,$0013,$0012,$0011,$0010,$000F);

{Table #2 of Pro Tracker 3.4r}
 PT3NoteTable_ASM_34r:PT3ToneTable = (
  $0D3E,$0C80,$0BCC,$0B22,$0A82,$09EC,$095C,$08D6,$0858,$07E0,$076E,$0704,
  $069F,$0640,$05E6,$0591,$0541,$04F6,$04AE,$046B,$042C,$03F0,$03B7,$0382,
  $034F,$0320,$02F3,$02C8,$02A1,$027B,$0257,$0236,$0216,$01F8,$01DC,$01C1,
  $01A8,$0190,$0179,$0164,$0150,$013D,$012C,$011B,$010B,$00FC,$00EE,$00E0,
  $00D4,$00C8,$00BD,$00B2,$00A8,$009F,$0096,$008D,$0085,$007E,$0077,$0070,
  $006A,$0064,$005E,$0059,$0054,$0050,$004B,$0047,$0043,$003F,$003C,$0038,
  $0035,$0032,$002F,$002D,$002A,$0028,$0026,$0024,$0022,$0020,$001E,$001D,
  $001B,$001A,$0019,$0018,$0015,$0014,$0013,$0012,$0011,$0010,$000F,$000E);

{Table #2 of Pro Tracker 3.4x - 3.5x}
 PT3NoteTable_ASM_34_35:PT3ToneTable = (
  $0D10,$0C55,$0BA4,$0AFC,$0A5F,$09CA,$093D,$08B8,$083B,$07C5,$0755,$06EC,
  $0688,$062A,$05D2,$057E,$052F,$04E5,$049E,$045C,$041D,$03E2,$03AB,$0376,
  $0344,$0315,$02E9,$02BF,$0298,$0272,$024F,$022E,$020F,$01F1,$01D5,$01BB,
  $01A2,$018B,$0174,$0160,$014C,$0139,$0128,$0117,$0107,$00F9,$00EB,$00DD,
  $00D1,$00C5,$00BA,$00B0,$00A6,$009D,$0094,$008C,$0084,$007C,$0075,$006F,
  $0069,$0063,$005D,$0058,$0053,$004E,$004A,$0046,$0042,$003E,$003B,$0037,
  $0034,$0031,$002F,$002C,$0029,$0027,$0025,$0023,$0021,$001F,$001D,$001C,
  $001A,$0019,$0017,$0016,$0015,$0014,$0012,$0011,$0010,$000F,$000E,$000D);

{Table #3 of Pro Tracker 3.4r}
 PT3NoteTable_REAL_34r:PT3ToneTable = (
  $0CDA,$0C22,$0B73,$0ACF,$0A33,$09A1,$0917,$0894,$0819,$07A4,$0737,$06CF,
  $066D,$0611,$05BA,$0567,$051A,$04D0,$048B,$044A,$040C,$03D2,$039B,$0367,
  $0337,$0308,$02DD,$02B4,$028D,$0268,$0246,$0225,$0206,$01E9,$01CE,$01B4,
  $019B,$0184,$016E,$015A,$0146,$0134,$0123,$0113,$0103,$00F5,$00E7,$00DA,
  $00CE,$00C2,$00B7,$00AD,$00A3,$009A,$0091,$0089,$0082,$007A,$0073,$006D,
  $0067,$0061,$005C,$0056,$0052,$004D,$0049,$0045,$0041,$003D,$003A,$0036,
  $0033,$0031,$002E,$002B,$0029,$0027,$0024,$0022,$0020,$001F,$001D,$001B,
  $001A,$0018,$0017,$0016,$0014,$0013,$0012,$0011,$0010,$000F,$000E,$000D);

{Table #3 of Pro Tracker 3.4x - 3.5x}
 PT3NoteTable_REAL_34_35:PT3ToneTable = (
  $0CDA,$0C22,$0B73,$0ACF,$0A33,$09A1,$0917,$0894,$0819,$07A4,$0737,$06CF,
  $066D,$0611,$05BA,$0567,$051A,$04D0,$048B,$044A,$040C,$03D2,$039B,$0367,
  $0337,$0308,$02DD,$02B4,$028D,$0268,$0246,$0225,$0206,$01E9,$01CE,$01B4,
  $019B,$0184,$016E,$015A,$0146,$0134,$0123,$0112,$0103,$00F5,$00E7,$00DA,
  $00CE,$00C2,$00B7,$00AD,$00A3,$009A,$0091,$0089,$0082,$007A,$0073,$006D,
  $0067,$0061,$005C,$0056,$0052,$004D,$0049,$0045,$0041,$003D,$003A,$0036,
  $0033,$0031,$002E,$002B,$0029,$0027,$0024,$0022,$0020,$001F,$001D,$001B,
  $001A,$0018,$0017,$0016,$0014,$0013,$0012,$0011,$0010,$000F,$000E,$000D);

{Volume table of Pro Tracker 3.3x - 3.4x}
 PT3VolumeTable_33_34:PT3VolTable = (
  ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
  ($00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01),
  ($00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02),
  ($00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03),
  ($00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04),
  ($00,$00,$00,$01,$01,$01,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05),
  ($00,$00,$00,$01,$01,$02,$02,$03,$03,$03,$04,$04,$05,$05,$06,$06),
  ($00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07),
  ($00,$00,$01,$01,$02,$02,$03,$03,$04,$05,$05,$06,$06,$07,$07,$08),
  ($00,$00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$06,$07,$08,$08,$09),
  ($00,$00,$01,$02,$02,$03,$04,$04,$05,$06,$06,$07,$08,$08,$09,$0A),
  ($00,$00,$01,$02,$03,$03,$04,$05,$06,$06,$07,$08,$09,$09,$0A,$0B),
  ($00,$00,$01,$02,$03,$04,$04,$05,$06,$07,$08,$08,$09,$0A,$0B,$0C),
  ($00,$00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D),
  ($00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E),
  ($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F));

{Volume table of Pro Tracker 3.5x}
 PT3VolumeTable_35:PT3VolTable = (
  ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
  ($00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01),
  ($00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02),
  ($00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03),
  ($00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04),
  ($00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05),
  ($00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06),
  ($00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07),
  ($00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08),
  ($00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09),
  ($00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A),
  ($00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B),
  ($00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C),
  ($00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D),
  ($00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E),
  ($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F));

var
 F_Frame:PModTypes;
 Readen1,F_Length,F_Address:integer;
 PrgBox:boolean;
 DDrumSamples:array of record
  Length:integer;
  Buf:PArrayOfByte;
 end;
 AtariSE1Type,AtariSE2Type,AtariSE1Channel,AtariSE2Channel:byte;
 AtariV1,AtariV2:byte;
 AtariParam1,AtariParam2:byte;
 AtariSE1Pos,AtariSE2Pos:integer;
 AtariSE1TP,AtariSE2TP:byte;
 YM6SinusPos1,YM6SinusPos2:integer;

procedure RaiseBadFileStructure;
begin
raise EFileStructureError.Create(Errors[ErBadFileStructure])
end;

procedure NewMessageSkipper;
var
 masg:TMsg;
begin
while PeekMessage(masg,Form1.Handle,0,0,PM_REMOVE) do
 if masg.message=WM_PAINT then
  begin
  TranslateMessage(Masg);
  DispatchMessage(Masg);
  end;
if Form2.Visible then
 while PeekMessage(masg,Form2.Handle,0,0,PM_REMOVE) do
  if masg.message=WM_PAINT then
   begin
   TranslateMessage(Masg);
   DispatchMessage(Masg);
   end;
if Form3.Visible then
 while PeekMessage(masg,Form3.Handle,0,0,PM_REMOVE) do
  if masg.message=WM_PAINT then
   begin
   TranslateMessage(Masg);
   DispatchMessage(Masg);
   end;
if PrgBox then
 while PeekMessage(masg,Form4.Handle,0,0,PM_REMOVE) do
  case masg.message of
  WM_KEYDOWN:    if masg.wparam=VK_ESCAPE then may_quit:=true;
  WM_LBUTTONDOWN,
  WM_LBUTTONUP,
  WM_PAINT:      begin
                 TranslateMessage(Masg);
                 DispatchMessage(Masg);
                 end;
  end;
end;

function LoadTrackerModule;
var
 f:file;
 i,i1,i2:integer;
 j,j2:longword;
 pwrd:WordPtr;
 Err:ErrorCodes;
begin
Err := FileNoError;
 try
  try
   if Index >= 0 then
    with PlaylistItems[Index]^ do
     begin
      FType := FileType;
      MAddr := Address;
      AssignFile(f,FileName);
      Reset(f,1);
      if FType = FXMFile then
       begin
        Seek(f,Offset + 6);
        Length := FileSize(f) - 6 - Offset;
       end
      else
       begin
        Seek(f,Offset);
        if Length = -1 then Length := FileSize(f);
       end;
     end;
   i := 0; if FType = FXMFile then i := MAddr;
   if Index >= 0 then
    with PlaylistItems[Index]^ do
     begin
      if Length > 65536 - i then Length := 65536 - i;
      MLen := Length
     end;
   try
    FillChar(Module,65536,0);
    if Index >= 0 then
     BlockRead(f,Module.Index[i],MLen)
    else
     Move(Mem^,Module.Index[i],MLen)
   finally
    if Index >= 0 then CloseFile(f)
   end;
   case FType of
   PT3File:
    if ((Index >= 0) and (LowerCase(ExtractFileExt(PlaylistItems[Index]^.FileName)) <> '.pt3')) or
       (Index < 0) then
     begin
      j := MAddr;
      if j <> 0 then
       begin
        if j >= 65536 then RaiseBadFileStructure;
        i := 0; i1 := 0;
        with Module do
         begin
          while (i < 65535 - 201) and (PT3_PositionList[i] <> 255) do
           begin
            if longword(i1) < PT3_PositionList[i] then
             i1 := PT3_PositionList[i];
            Inc(i)
           end;
          if i >= 65535 - 201 then RaiseBadFileStructure;
          if i > 255 then
           PT3_NumberOfPositions := 255
          else
           PT3_NumberOfPositions := i;
          if PT3_PatternsPointer < j then RaiseBadFileStructure;
          Dec(PT3_PatternsPointer,j);
          for i := 0 to 31 do
           begin
            if PT3_SamplesPointers[i] < j then RaiseBadFileStructure;
            Dec(PT3_SamplesPointers[i],j)
           end;
          for i := 0 to 15 do
           begin
            if PT3_OrnamentsPointers[i] < j then RaiseBadFileStructure;
            Dec(PT3_OrnamentsPointers[i],j)
           end;
          j2 := longword(@Index[65535]);
          pwrd := @Index[PT3_PatternsPointer]
         end;
        for i := 0 to i1 + 2 do
         begin
          if (longword(pwrd) >= j2) or (pwrd^ < j) then RaiseBadFileStructure;
          Dec(pwrd^,j);
          Inc(integer(pwrd),2)
         end
       end
     end;
   PT2File:
    if ((Index >= 0) and (LowerCase(ExtractFileExt(PlaylistItems[Index]^.FileName)) <> '.pt2')) or
       (Index < 0) then
     begin
      j := MAddr;
      if j <> 0 then
       begin
        if j >= 65536 then RaiseBadFileStructure;
        i := 0; i1 := 0;
        with Module do
         begin
          while (i < 65535 - 131) and (PT2_PositionList[i] < 128) do
           begin
            if longword(i1) < PT2_PositionList[i] then
             i1 := PT2_PositionList[i];
            Inc(i)
           end;
          if i >= 65535 - 131 then RaiseBadFileStructure;
          if i > 255 then
           PT2_NumberOfPositions := 255
          else
           PT2_NumberOfPositions := i;
          for i := 0 to 31 do
           begin
            if PT2_SamplesPointers[i] < j then RaiseBadFileStructure;
            Dec(PT2_SamplesPointers[i],j)
           end;
          for i := 0 to 15 do
           begin
            if PT2_OrnamentsPointers[i] < j then RaiseBadFileStructure;
            Dec(PT2_OrnamentsPointers[i],j)
           end;
          j2 := longword(@Index[65535]);
          pwrd := @Index[PT2_PatternsPointer]
         end;
        for i := 0 to i1 * 3 + 2 do
         begin
          if (longword(pwrd) >= j2) or (pwrd^ < j) then RaiseBadFileStructure;
          Dec(pwrd^,j);
          Inc(integer(pwrd),2)
         end
       end
     end;
   STPFile:
    if ((Index >= 0) and (LowerCase(ExtractFileExt(PlaylistItems[Index]^.FileName)) <> '.stp')) or
       (Index < 0) then
     with Module do
      if STP_Init_Id = 0 then
       begin
        j := MAddr; if j >= 65536 then RaiseBadFileStructure;
        i1 := (MLen - STP_PatternsPointer) div 2;
        if not (i1 in [0..255]) then RaiseBadFileStructure;
        STP_Init_Id := i1;
        j2 := longword(@Index[65535]);
        pwrd := @Index[STP_PatternsPointer];
        for i := 1 to i1 do
         begin
          if longword(pwrd) >= j2 then RaiseBadFileStructure;
          if pwrd^ < j then RaiseBadFileStructure;
          Dec(pwrd^,j);
          Inc(integer(pwrd),2)
         end
       end;
   ASC0File:
    with Module do
     begin
      if MLen >= 65535 then RaiseBadFileStructure;
      Move(ASC0_PatternsPointers,ASC1_PatternsPointers,MLen - 1);
      ASC1_LoopingPosition := 0;
      Inc(ASC1_PatternsPointers);
      Inc(ASC1_SamplesPointers);
      Inc(ASC1_OrnamentsPointers)
     end;
   SQTFile:
    with Module do
     begin
      i := SQT_SamplesPointer - 10;
      if  i < 0 then RaiseBadFileStructure;
      i1 := 0;
      i2 := SQT_PositionsPointer - i;
      if i2 < 0 then RaiseBadFileStructure;
      while Index[i2] <> 0 do
       begin
        if i2 > 65536 - 8 then RaiseBadFileStructure;
        if i1 < Index[i2] and $7f then
         i1 := Index[i2] and $7f;
        Inc(i2,2);
        if i1 < Index[i2] and $7f then
         i1 := Index[i2] and $7f;
        Inc(i2,2);
        if i1 < Index[i2] and $7f then
         i1 := Index[i2] and $7f;
        Inc(i2,3)
       end;
      j2 := longword(@Index[65535]);
      pwrd := @SQT_SamplesPointer;
      i1 := (SQT_PatternsPointer - i + i1 * 2) div 2;
      if i1 < 1 then RaiseBadFileStructure;
      for i2 := 1 to i1 do
       begin
        if longword(pwrd) >= j2 then RaiseBadFileStructure;
        if pwrd^ < i then RaiseBadFileStructure;
        Dec(pwrd^,i);
        Inc(integer(pwrd),2)
       end
     end;
   FTCFile:
    begin
     if (((Index >= 0) and (LowerCase(ExtractFileExt(PlaylistItems[Index]^.FileName)) <> '.ftc')) or
        (Index < 0)) and (MAddr <> 0) then
      with Module do
       begin
        j := MAddr; if j >= 65536 then RaiseBadFileStructure;
        for i := 0 to 32 do
         begin
          if FTC_OrnamentsPointers[i] < j then RaiseBadFileStructure;
          Dec(FTC_OrnamentsPointers[i],j)
         end;
        for i := 0 to 31 do
         begin
          if FTC_SamplesPointers[i] < j then RaiseBadFileStructure;
          Dec(FTC_SamplesPointers[i],j)
         end;
        j2 := longword(@Index[65535]);
        pwrd := @Index[FTC_PatternsPointer];
        i := $d4; i1 := 0;
        while (i < 65536) and (shortint(Index[i]) >= 0) do
         begin
          if i1 < Index[i] then i1 := Index[i];
          Inc(i,2)
         end;
        if i >= 65536 then RaiseBadFileStructure;
        i1 := (i1 + 1) * 3;
        if i1 < 1 then RaiseBadFileStructure;
        for i := 1 to i1 do
         begin
          if longword(pwrd) >= j2 then RaiseBadFileStructure;
          if pwrd^ < j then RaiseBadFileStructure;
          Dec(pwrd^,j);
          Inc(integer(pwrd),2)
         end
       end
    end; 
   FLSFile:
    begin
     i := Module.FLS_OrnamentsPointer - 16;
     if i >= 0 then
      with Module do
       repeat
        i2 := FLS_SamplesPointer + 2 - i;
        if (i2 >= 8) and (i2 < MLen) then
         begin
          pwrd := @Index[i2];
          i1 := pwrd^ - i;
          if (i1 >= 8) and (i1 < MLen) then
           begin
            pwrd := @Index[i2 - 4];
            i2 := pwrd^ - i;
            if (i2 >= 6) and (i2 < MLen) then
             if i1 - i2 = $20 then
              begin
               i2 := FLS_PatternsPointers[1].PatternB - i;
               if (i2 > 21) and (i2 < MLen) then
                begin
                 i1 := FLS_PatternsPointers[1].PatternA - i;
                 if (i1 > 20) and (i1 < MLen) then
                  if Index[i1 - 1] = 0 then
                   begin
                    while (i1 < MLen) and (Index[i1] <> 255) do
                     begin
                      repeat
                       case Index[i1] of
                       0..$5f,$80,$81:
                        begin
                         Inc(i1);
                         break
                        end;
                       $82..$8e:
                        Inc(i1)
                       end;
                       Inc(i1);
                      until i1 >= MLen;
                     end;
                    if i1 + 1 = i2 then break
                   end
                end
              end
           end
         end;
        Dec(i)
       until i < 0;
     if i < 0 then
      Err := ErFLSAddrNotDetected
     else
      with Module do
       begin
        pwrd := @Module;
        i1 := FLS_SamplesPointer - i; if i1 and 1 <> 0 then RaiseBadFileStructure;
        i2 := FLS_PositionsPointer - i; if (i2 - i1) and 3 <> 0 then RaiseBadFileStructure;
        inc(i1,integer(pwrd));
        inc(i2,integer(pwrd) + 2);
        repeat
         Dec(pwrd^,i);
         Inc(integer(pwrd),2)
        until i1 <= integer(pwrd);
        Inc(integer(pwrd),2);
        repeat
         Dec(pwrd^,i);
         Inc(integer(pwrd),4)
        until i2 <= integer(pwrd)
       end
    end;
   GTRFile:
    with Module do
     begin
      pwrd := @GTR_SamplesPointers[0];
      if longword(pwrd) + (15 + 16 + 32 * 3) * 2 > longword(@Index[65536]) then
       RaiseBadFileStructure;
      j := GTR_Address;
      for i := 0 to (15 + 16 + 32 * 3) - 1 do
       begin
        if pwrd^ < j then RaiseBadFileStructure;
        Dec(pwrd^,j);
        Inc(integer(pwrd),2)
       end;
      GTR_Address := 0
     end
   end;
  except
   on EFileStructureError do
    Err := ErBadFileStructure
   else
    Err := ErReadingFile
  end
 finally
  Result := Err = FileNoError;
  if Index >= 0 then
   begin
    PlaylistItems[Index]^.Error := Err;
    RedrawItem(0,Index)
   end 
 end
end;

procedure PrepareItem;

 function TrModLoaded:boolean;
 begin
  if LoadTrackerModule(RAM,Index,0,0,nil,Unknown) then
   begin
    FileLoaded := True;
    Result := True;
    CurFileType := PlayListItems[Index].FileType
   end
  else
   begin
    Result := False;
    FileAvailable := False
   end
 end;

const
 Dump:packed array[0..11] of byte=
  ($F3,$AF,$CD,0,0,$FB,$76,$CD,0,0,$18,$F9);
var
 i,i1,i2,k,k2:integer;
 sh:shortint;
 j:longword;
 AYMBlock:TAYMBlock;
 
begin
with PlayListItems[Index]^ do
 begin
  if (FileType <> CDAFile) and not FileExists(FileName) then
   begin
    FreePlayingResourses;
    Error := ErFileNotFound;
    RedrawItem(0,Index);
    FileAvailable := False
   end
  else
   begin
    if Error <> FileNoError then
     begin
      Error := FileNoError;
      RedrawItem(0,Index);
     end;
    case FileType of
    OUTFile:
      begin
       UniReadInit(FileHandle,URFile,FileName,nil);
       FileOpened := True;
       CurFileType := OUTFile;
       MakeBuffer := MakeBufferOUT;
       All_GetRegisters := OUT_Get_Registers;
      end;
    VTXFile:
      begin
       UniReadInit(FileHandle,URFile,FileName,nil);
       UniFileSeek(FileHandle,Offset);
       GetMem(PVTXYMUnpackedData,UnpackedSize);
       Compressed_Size := Length;
       Original_Size := UnpackedSize;
       UniAddDepacker(FileHandle,UDLZH);
       try
        UniRead(FileHandle,PVTXYMUnpackedData,UnpackedSize);
       except
        FreeMem(PVTXYMUnpackedData);
        Error := ErLZHDataIsNotValid;
        RedrawItem(0,Index);
        FileAvailable := False
       end;
       UniReadClose(FileHandle);
       if Error = FileNoError then
        begin
         FileLoaded := True;
         CurFileType := VTXFile;
         VTX_Offset := 0;
         NumberOfVBLs := UnpackedSize div 14;
         MakeBuffer := MakeBufferVTX;
         All_GetRegisters := VTX_YM3_YM3b_Get_Registers
        end
      end;
    YM2File..YM6File:
      begin
       UniReadInit(FileHandle,URFile,FileName,nil);
       GetMem(PVTXYMUnpackedData,UnpackedSize);
       if Offset <> 0 then
        begin
         UniFileSeek(FileHandle,Offset);
         Compressed_Size := Length;
         Original_Size := UnpackedSize;
         UniAddDepacker(FileHandle,UDLZH);
        end;
       try
        UniRead(FileHandle,PVTXYMUnpackedData,UnpackedSize);
       except
        on EInvalidCompressedData do
         Error := ErLZHDataIsNotValid;
        else
         Error := ErReadingFile;
        FreeMem(PVTXYMUnpackedData);
        RedrawItem(0,Index);
        FileAvailable := False
       end;
       UniReadClose(FileHandle);
       if Error = FileNoError then
        begin
         CurFileType := FileType;
         FileLoaded := True;
         case FileType of
         YM2File..YM3bFile:
          begin
           if FileType = YM3bFile then
            begin
             NumberOfVBLs := (UnpackedSize - 8) div 14;
             if Loop < 0 then
              Loop := DWordPtr(@PVTXYMUnpackedData^[UnpackedSize - 4])^
            end
           else
            NumberOfVBLs := (UnpackedSize - 4) div 14;
           VTX_Offset := 4;
           if FileType <> YM2File then
            begin
             MakeBuffer := MakeBufferVTX;
             All_GetRegisters := VTX_YM3_YM3b_Get_Registers;
            end
           else
            begin
             MakeBuffer := MakeBufferYM2;
             All_GetRegisters := YM2_Get_Registers;
            end
          end;
         YM5File,YM6File:
          begin
           VTX_Offset := FormatSpec;
           NumberOfVBLs := IntelDWord(
                         PYM5FileHeader(PVTXYMUnpackedData)^.Num_of_tiks);
           i := IntelWord(PYM5FileHeader(PVTXYMUnpackedData)^.Num_of_Dig);
           if i > 0 then
            begin
             SetLength(DDrumSamples,i);
             i2 := 34 + IntelWord(
                        PYM5FileHeader(PVTXYMUnpackedData)^.Add_Size);
             i1 := 0;
             while i > 0 do
              begin
               j := IntelDWord(DWordPtr(
                        @PVTXYMUnpackedData^[i2])^);
               DDrumSamples[i1].Length := j;
               DDrumSamples[i1].Buf := @PVTXYMUnpackedData^[i2 + 4];
               inc(i2,j + 4);
               inc(i1);
               dec(i)
              end;
             if PYM5FileHeader(PVTXYMUnpackedData)^.
                         Song_Attr and $06000000 = $02000000 then
              for i := 0 to System.Length(DDrumSamples) - 1 do
               for i1 := 0 to DDrumSamples[i].Length - 1 do
                begin
                 sh := shortint(DDrumSamples[i].Buf[i1]);
                 k2 := round((sh + 128)/255*65535);
                 k := 1;
                 while (k < 32) and (Amplitudes_YM[k] < k2) do
                  inc(k,2);
                 if k > 1 then
                  if Amplitudes_YM[k] - k2 >
                                 k2 - Amplitudes_YM[k - 2] then
                   dec(k,2);
                 DDrumSamples[i].Buf[i1] := k div 2
                end
             else if PYM5FileHeader(PVTXYMUnpackedData)^.
                              Song_Attr and $06000000 = 0 then
              for i := 0 to System.Length(DDrumSamples) - 1 do
               YMizeSample(DDrumSamples[i].Buf,DDrumSamples[i].Length);
            end;
           if FileType = YM5File then
            begin
             MakeBuffer := MakeBufferYM5;
             if BytePtr(pointer(integer(
                        PVTXYMUnpackedData) + 19))^ and 1 <> 0 then
              All_GetRegisters := YM5i_Get_Registers
             else
              All_GetRegisters := YM5_Get_Registers
            end
           else
            begin
             MakeBuffer := MakeBufferYM6;
             if BytePtr(pointer(integer(
                        PVTXYMUnpackedData) + 19))^ and 1 <> 0 then
              All_GetRegisters := YM6i_Get_Registers
             else
              All_GetRegisters := YM6_Get_Registers
            end
          end
         end
        end
      end;
    EPSGFile:
      begin
       UniReadInit(FileHandle,URFile,FileName,nil);
       FileOpened := True;
       CurFileType := EPSGFile;
       MakeBuffer := MakeBufferEPSG;
       All_GetRegisters := EPSG_Get_Registers;
       EPSG_TStateMax := FormatSpec
      end;
    PSGFile:
      begin
       UniReadInit(FileHandle,URFile,FileName,nil);
       FileOpened := True;
       CurFileType := PSGFile;
       MakeBuffer := MakeBufferPSG;
       All_GetRegisters := PSG_Get_Registers;
      end;
    ZXAYFile:
      begin
       UniReadInit(FileHandle,URFile,FileName,nil);
       FileOpened := True;
       CurFileType := ZXAYFile;
       MakeBuffer := MakeBufferZXAY;
       All_GetRegisters := ZXAY_Get_Registers
      end;
    PT3File:
      if TrModLoaded then
       begin
        PlParams.PT3.PT3_Version := 6;
        if RAM.PT3_MusicName[13] in ['0'..'9'] then
         PlParams.PT3.PT3_Version := Ord(RAM.PT3_MusicName[13]) - $30;
        MakeBuffer := MakeBufferPT3;
        All_GetRegisters := PT3_Get_Registers
       end;
    PT2File:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferPT2;
        All_GetRegisters := PT2_Get_Registers
       end;
    STCFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferSTC;
        All_GetRegisters := STC_Get_Registers
       end;
    STPFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferSTP;
        All_GetRegisters := STP_Get_Registers
       end;
    ASCFile,ASC0File:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferASC;
        All_GetRegisters := ASC_Get_Registers
       end;
    PSCFile:
      if TrModLoaded then
       begin
        PlParams.PSC.PSC_Version := 7;
        if RAM.PSC_MusicName[8] in ['0'..'9'] then
         PlParams.PSC.PSC_Version := Ord(RAM.PSC_MusicName[8]) - $30;
        MakeBuffer := MakeBufferPSC;
        All_GetRegisters := PSC_Get_Registers
       end;
    SQTFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferSQT;
        All_GetRegisters := SQT_Get_Registers
       end;
    FTCFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferFTC;
        All_GetRegisters := FTC_Get_Registers
       end;
    PT1File:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferPT1;
        All_GetRegisters := PT1_Get_Registers
       end;
    FLSFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferFLS;
        All_GetRegisters := FLS_Get_Registers
       end;
    GTRFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferGTR;
        All_GetRegisters := GTR_Get_Registers
       end;
    FXMFile:
      if TrModLoaded then
       begin
        PlParams.FXM.Address := Address;
        PlParams.FXM.amad_andsix := FormatSpec;
        MakeBuffer := MakeBufferFXM;
        All_GetRegisters := FXM_Get_Registers
       end;
    PSMFile:
      if TrModLoaded then
       begin
        MakeBuffer := MakeBufferPSM;
        All_GetRegisters := PSM_Get_Registers
       end;
    AYFile:
     begin
      UniReadInit(FileHandle,URFile,FileName,nil);
      UniFileSeek(FileHandle,Offset);
      UniRead(FileHandle,@AYSongData,SizeOf(TSongData));
      i := UniReadersData[FileHandle].UniFilePos;
      UniFileSeek(FileHandle,smallint(IntelWord(AYSongData.PPoints)) + i - 4);
      UniRead(FileHandle,@AYPoints,SizeOf(TPoints));
      AYPoints.Stek := IntelWord(AYPoints.Stek);
      AYPoints.Init := IntelWord(AYPoints.Init);
      AYPoints.Inter := IntelWord(AYPoints.Inter);
      AYBlocks := smallint(IntelWord(AYSongData.PAddresses)) + i - 2;
      FileOpened := True;
      CurFileType := AYFile;
      MakeBuffer := MakeBufferAY;
      All_GetRegisters := AY_Get_Registers
     end;
    AYMFile:
     begin
      UniReadInit(FileHandle,URFile,FileName,nil);
      UniRead(FileHandle,@AYMFileHeader,SizeOf(TAYMFileHeader));
      FillChar(RAM.Index[12],255 - 12 + 1,201);
      FillChar(RAM.Index[256],16383 - 256 + 1,255);
      FillChar(RAM.Index[16384],65535 - 16384 + 1,0);
      RAM.Index[56] := $FB;
      for i := 0 to AYMFileHeader.Blocks - 1 do
       begin
        UniRead(FileHandle,@AYMBlock,SizeOf(AYMBlock));
        i1 := AYMBlock.size;
        if AYMBlock.start + i1 > 65536 then
         i1 := 65536 - AYMBlock.start;
        if i1 > UniReadersData[FileHandle].UniFileSize -
                                UniReadersData[FileHandle].UniFilePos then
         i1 := UniReadersData[FileHandle].UniFileSize -
                                UniReadersData[FileHandle].UniFilePos;
        UniRead(FileHandle,@RAM.Index[AYMBlock.start],i1)
       end;
      Move(Dump,RAM,12);
      WordPtr(@RAM.Index[3])^ := AYMFileHeader.Init;
      WordPtr(@RAM.Index[8])^ := AYMFileHeader.Play;
      AYBlocks := FormatSpec;
      UniReadClose(FileHandle);
      FileLoaded := True;
      CurFileType := AYMFile;
      MakeBuffer := MakeBufferAY;
      All_GetRegisters := AY_Get_Registers
     end;
    BASSFileMin..BASSFileMax:
     begin
      if Time = 0 then
       try
        GetTime(-1,Index,True,i)
       except
        Error := ErBASSError
       end;
      CurFileType := FileType
     end;
    CDAFile:
     begin
      CurCDTrk := Offset;
      if CurCDNum <> Address then
       if (Address >= 0) and (Address < System.Length(CDDrives)) then
        begin
         FreeAllCD;
         CurCDNum := Address
        end 
       else
        Error := ErFileNotFound;
      if (Error = FileNoError) and (Time = 0) then
       try
        GetTime(-1,Index,True,i)
       except
        Error := ErFileNotFound
       end;
      CurFileType := CDAFile
     end
    end
   end
 end
end;

procedure InitForAllTypes;
const
 DumpIM2:packed array[0..9] of byte =
  ($F3,$CD,0,0,$ED,$5E,$FB,$76,$18,$FA);
 DumpIM1:packed array[0..12] of byte =
  ($F3,$CD,0,0,$ED,$56,$FB,$76,$CD,0,0,$18,$F7);
var
 i,Offs1,Offs2:integer;
 w,w1:word;
 si:smallint;
 b:byte;
begin
Case CurFileType of
OUTFile:
 begin
  UniFileSeek(FileHandle,0);
  Previous_AY_Takt := 0
 end;
AYMFile:
 begin
  InProc := InitialInProc;
  OutProc := InitialOutProc;
  Previous_Tact := 0;
  IntBeeper := False;
  IntAY := False;
  CPCSwitch := 0;
  CPCData := 0;
  CurrentTact := 0;
  Z80_Registers.Common := @CommonMain;
  PCommonAlt := @CommonAlt;
  Z80_Registers.AF := @AFMain;
  PAFAlt := @AFAlt;
  IFF := False;
  EIorDDorFD := False;
  IMode := 0;
  RAM.Index[65536] := RAM.Index[0];
  BytePtr(integer(@AYMFileHeader.AF) + AYMFileHeader.
  RegPos)^ := AYBlocks + AYMFileHeader.MusMin;
  AFMain.AllWord := AYMFileHeader.AF;
  CommonMain.BC.AllWord := AYMFileHeader.BC;
  CommonMain.DE.AllWord := AYMFileHeader.DE;
  CommonMain.HL.AllWord := AYMFileHeader.HL;
  Z80_Registers.IX.AllWord := AYMFileHeader.IX;
  Z80_Registers.IY.AllWord := AYMFileHeader.IY;
  Z80_Registers.SP := $4000;
  Z80_Registers.PC := 2;
  R_Hi_Bit := 0;
  Z80_Registers.IR.AllWord := 0
 end;
AYFile:
 begin
  InProc := InitialInProc;
  OutProc := InitialOutProc;
  Previous_Tact := 0;
  IntBeeper := False;
  IntAY := False;
  CPCSwitch := 0;
  CPCData := 0;
  CurrentTact := 0;
  Z80_Registers.Common := @CommonMain;
  PCommonAlt := @CommonAlt;
  Z80_Registers.AF := @AFMain;
  PAFAlt := @AFAlt;
  IFF := False;
  EIorDDorFD := False;
  IMode := 0;

  UniFileSeek(FileHandle,AYBlocks);
  FillChar(RAM.Index[10],255 - 10 + 1,201);
  FillChar(RAM.Index[256],16383 - 256 + 1,255);
  FillChar(RAM.Index[16384],65535 - 16384 + 1,0);
  RAM.Index[56] := $FB;
  if AYPoints.Inter <> 0 then
   begin
    Move(DumpIM1,RAM,13);
    WordPtr(@RAM.Index[9])^ := AYPoints.Inter
   end
  else
   Move(DumpIM2,RAM,10);
  WordPtr(@RAM.Index[2])^ := AYPoints.Init;
  RAM.Index[65536] := RAM.Index[0];
  Z80_Registers.SP := AYPoints.Stek;
  b := AYSongData.HiReg;
  AFMain.HiByte := b;
  AFAlt.HiByte := b;
  CommonMain.HL.HiByte := b;
  CommonMain.DE.HiByte := b;
  CommonMain.BC.HiByte := b;
  CommonAlt.HL.HiByte := b;
  CommonAlt.DE.HiByte := b;
  CommonAlt.BC.HiByte := b;
  Z80_Registers.IX.HiByte := b;
  Z80_Registers.IY.HiByte := b;
  b := AYSongData.LoReg;
  AFMain.LoByte := b;
  AFAlt.LoByte := b;
  CommonMain.HL.LoByte := b;
  CommonMain.DE.LoByte := b;
  CommonMain.BC.LoByte := b;
  CommonAlt.HL.LoByte := b;
  CommonAlt.DE.LoByte := b;
  CommonAlt.BC.LoByte := b;
  Z80_Registers.IX.LoByte := b;
  Z80_Registers.IY.LoByte := b;
  Z80_Registers.IR.AllWord := $300;
  R_Hi_Bit := 0;
  Z80_Registers.PC := 0;
  UniRead(FileHandle,@w,2);
  while w <> 0 do
   begin
    w := IntelWord(w);
    if AYPoints.Init = 0 then
     begin
      WordPtr(@RAM.Index[2])^ := w;
      AYPoints.Init := w
     end;
    UniRead(FileHandle,@w1,2);
    w1 := IntelWord(w1);
    if w1 + w > 65536 then
     w1 := 65536 - w;
    UniRead(FileHandle,@si,2);
    Offs1 := smallint(IntelWord(si)) +
                        UniReadersData[FileHandle].UniFilePos - 2;
    if Offs1 + w1 > UniReadersData[FileHandle].UniFileSize then
     w1 := UniReadersData[FileHandle].UniFileSize - Offs1;
    Offs2 := UniReadersData[FileHandle].UniFilePos;
    UniFileSeek(FileHandle,Offs1);
    UniRead(FileHandle,@RAM.Index[w],w1);
    UniFileSeek(FileHandle,Offs2);
    UniRead(FileHandle,@w,2)
   end
 end;
YM2File, 
YM5File,
YM6File:
 begin
  if CurFileType = YM5File then
   begin
    AtariSE1Type := 0;
    AtariSE2Type := 1
   end;
  Position_In_VTX := 0;
  AtariSE1Channel := 0;
  AtariSE2Channel := 0;
  AtariTimerCounter1 := 0;
  AtariTimerCounter2 := 0;
  if Optimization_for_quality then
   YM6CurTik := YM6TiksOnInt
  else
   YM6CurTik := YM6SamTiksOnInt;
  AtariV1 := 0;
  AtariV2 := 0;
  YM6SinusPos1 := 0;
  YM6SinusPos2 := 0
 end;
FXMFile:
 begin

  with PlParams.FXM,RAM do
   begin
    Noise_Base := 0;
    PlParams.FXM_A.Address_In_Pattern :=
                                        WordPtr(@Index[Address])^;
    PlParams.FXM_B.Address_In_Pattern :=
                                        WordPtr(@Index[Address + 2])^;
    PlParams.FXM_C.Address_In_Pattern :=
                                        WordPtr(@Index[Address + 4])^;
   end;

  with PlParams.FXM_A do
   begin
    Note_Skip_Counter := 1;
    FXM_Mixer := 8;
    Transposit := 0;
    b0e := False;
    b1e := False;
    b2e := False;
    b3e := False;
   end;

  with PlParams.FXM_B do
   begin
    Note_Skip_Counter := 1;
    FXM_Mixer := 8;
    Transposit := 0;
    b0e := False;
    b1e := False;
    b2e := False;
    b3e := False;
   end;

  with PlParams.FXM_C do
   begin
    Note_Skip_Counter := 1;
    FXM_Mixer := 8;
    Transposit := 0;
    b0e := False;
    b1e := False;
    b2e := False;
    b3e := False;
   end;

  SetLength(FXM_StekA,0);
  SetLength(FXM_StekB,0);
  SetLength(FXM_StekC,0);

 end;
GTRFile:
 begin

  with PlParams.GTR,RAM do
   begin
    CurrentPosition := 0;
    DelayCounter := 1;
    PlParams.GTR_A.Address_In_Pattern := GTR_PatternsPointers[
                GTR_Positions[0] div 6].PatternA;
    PlParams.GTR_B.Address_In_Pattern := GTR_PatternsPointers[
                GTR_Positions[0] div 6].PatternB;
    PlParams.GTR_C.Address_In_Pattern := GTR_PatternsPointers[
                GTR_Positions[0] div 6].PatternC;
   end;

  with PlParams.GTR_A do
   begin
    Envelope_Enabled := False;
    SamplePointer := 65536 - 4;
    Position_In_Sample := 0;
    Loop_Sample_Position := 0;
    Sample_Length := 4;
    OrnamentPointer := 65536 - 4;
    Position_In_Ornament := 0;
    Loop_Ornament_Position := 0;
    Ornament_Length := 1;
    DWordPtr(@RAM.Index[65536-4])^ := 0;
    Note_Skip_Counter := 0;
    Enabled := True;
    Ton := 0;
    Volume := 0
   end;

  with PlParams.GTR_B do
   begin
    Envelope_Enabled := False;
    SamplePointer := 65536 - 4;
    Position_In_Sample := 0;
    Loop_Sample_Position := 0;
    Sample_Length := 4;
    OrnamentPointer := 65536 - 4;
    Position_In_Ornament := 0;
    Loop_Ornament_Position := 0;
    Ornament_Length := 1;
    DWordPtr(@RAM.Index[65536-4])^ := 0;
    Note_Skip_Counter := 0;
    Enabled := True;
    Ton := 0;
    Volume := 0
   end;

  with PlParams.GTR_C do
   begin
    Envelope_Enabled := False;
    SamplePointer := 65536 - 4;
    Position_In_Sample := 0;
    Loop_Sample_Position := 0;
    Sample_Length := 4;
    OrnamentPointer := 65536 - 4;
    Position_In_Ornament := 0;
    Loop_Ornament_Position := 0;
    Ornament_Length := 1;
    DWordPtr(@RAM.Index[65536-4])^ := 0;
    Note_Skip_Counter := 0;
    Enabled := True;
    Ton := 0;
    Volume := 0
   end;

 end;
STCFile:
 begin
  with PlParams.STC,RAM do
   begin
    CurrentPosition := 0;
    Transposition := Index[ST_PositionsPointer + 2];
    DelayCounter := 1;
   end;

  with RAM do
   begin
    i := 0;
    while Index[ST_PatternsPointer + 7*i] <>
                      Index[ST_PositionsPointer + 1] do inc(i);
    PlParams.STC_A.Address_In_Pattern :=
                           WordPtr(@Index[ST_PatternsPointer + 7 * i + 1])^;
    PlParams.STC_B.Address_In_Pattern :=
                           WordPtr(@Index[ST_PatternsPointer + 7 * i + 3])^;
    PlParams.STC_C.Address_In_Pattern :=
                           WordPtr(@Index[ST_PatternsPointer + 7 * i + 5])^;
   end;

  with PlParams.STC_A do
   begin
    Note_Skip_Counter := 0;
    Envelope_Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Sample_Tik_Counter := -1;
    Position_In_Sample := 0;
    OrnamentPointer := RAM.ST_OrnamentsPointer + 1;
    Ton := 0
   end;

  with PlParams.STC_B do
   begin
    Note_Skip_Counter := 0;
    Envelope_Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Sample_Tik_Counter := -1;
    Position_In_Sample := 0;
    OrnamentPointer := RAM.ST_OrnamentsPointer + 1;
    Ton := 0
   end;

  with PlParams.STC_C do
   begin
    Note_Skip_Counter := 0;
    Envelope_Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Sample_Tik_Counter := -1;
    Position_In_Sample := 0;
    OrnamentPointer := RAM.ST_OrnamentsPointer + 1;
    Ton := 0
   end

 end;
FLSFile:
 begin
  with PlParams.FLS,RAM do
   begin
    Delay := Index[FLS_PositionsPointer];
    CurrentPosition := 0;
    DelayCounter := 1;
   end;

  with PlParams.FLS_A,RAM do
   begin
    Note_Skip_Counter := 0;
    Number_Of_Notes_To_Skip := 0;
    Address_In_Pattern :=
        FLS_PatternsPointers[Index[FLS_PositionsPointer + 1]].PatternA;
    Ornament_Enabled := False;
    Envelope_Enabled := False;
    Ton := 0;
    Sample_Tik_Counter := -1;
   end;

  with PlParams.FLS_B,RAM do
   begin
    Note_Skip_Counter := 0;
    Number_Of_Notes_To_Skip := 0;
    Address_In_Pattern :=
        FLS_PatternsPointers[Index[FLS_PositionsPointer + 1]].PatternB;
    Ornament_Enabled := False;
    Envelope_Enabled := False;
    Ton := 0;
    Sample_Tik_Counter := -1;
   end;

  with PlParams.FLS_C,RAM do
   begin
    Note_Skip_Counter := 0;
    Number_Of_Notes_To_Skip := 0;
    Address_In_Pattern :=
        FLS_PatternsPointers[Index[FLS_PositionsPointer + 1]].PatternC;
    Ornament_Enabled := False;
    Envelope_Enabled := False;
    Ton := 0;
    Sample_Tik_Counter := -1;
   end;

  end;
ASCFile,ASC0File:
  begin

   with PlParams.ASC_A do
    begin
     Note := 0;
     Initial_Noise := 0;
     Current_Noise := 0;
     Sample_Finished := False;
     Sound_Enabled := False;
     Break_Sample_Loop := False;
     Envelope_Enabled := False;
     Number_Of_Notes_To_Skip := 0;
     Addition_To_Amplitude := 0;
     Note_Skip_Counter := 0;
     Initial_Point_In_Sample := 0;
     Initial_Point_In_Ornament := 0;
     Point_In_Ornament := 0;
     Loop_Point_In_Ornament := 0;
     Substruction_for_Ton_Sliding := 0;
     Volume := 0;
     Point_In_Sample := 0;
     Ton_Deviation := 0;
     Loop_Point_In_Sample := 0;
     Ton_Sliding_Counter := 0;
     Amplitude_Delay_Counter := 0;
     Amplitude_Delay := 0;
     Addition_To_Note := 0;
     Current_Ton_Sliding := 0;
     Ton:=0
    end;

   with PlParams.ASC_B do
    begin
     Note := 0;
     Initial_Noise := 0;
     Current_Noise := 0;
     Sample_Finished := False;
     Sound_Enabled := False;
     Break_Sample_Loop := False;
     Envelope_Enabled := False;
     Number_Of_Notes_To_Skip := 0;
     Addition_To_Amplitude := 0;
     Note_Skip_Counter := 0;
     Initial_Point_In_Sample := 0;
     Initial_Point_In_Ornament := 0;
     Point_In_Ornament := 0;
     Loop_Point_In_Ornament := 0;
     Substruction_for_Ton_Sliding := 0;
     Volume := 0;
     Point_In_Sample := 0;
     Ton_Deviation := 0;
     Loop_Point_In_Sample := 0;
     Ton_Sliding_Counter := 0;
     Amplitude_Delay_Counter := 0;
     Amplitude_Delay := 0;
     Addition_To_Note := 0;
     Current_Ton_Sliding := 0;
     Ton:=0
    end;

   with PlParams.ASC_C do
    begin
     Note := 0;
     Initial_Noise := 0;
     Current_Noise := 0;
     Sample_Finished := False;
     Sound_Enabled := False;
     Break_Sample_Loop := False;
     Envelope_Enabled := False;
     Number_Of_Notes_To_Skip := 0;
     Addition_To_Amplitude := 0;
     Note_Skip_Counter := 0;
     Initial_Point_In_Sample := 0;
     Initial_Point_In_Ornament := 0;
     Point_In_Ornament := 0;
     Loop_Point_In_Ornament := 0;
     Substruction_for_Ton_Sliding := 0;
     Volume := 0;
     Point_In_Sample := 0;
     Ton_Deviation := 0;
     Loop_Point_In_Sample := 0;
     Ton_Sliding_Counter := 0;
     Amplitude_Delay_Counter := 0;
     Amplitude_Delay := 0;
     Addition_To_Note := 0;
     Current_Ton_Sliding := 0;
     Ton:=0
    end;

  with PlParams.ASC,RAM do
   begin
    CurrentPosition := 0;
    DelayCounter := 1;
    Delay := ASC1_Delay;
    PlParams.ASC_A.Address_In_Pattern :=
     WordPtr(@Index[ASC1_PatternsPointers + 6 * Index[9]])^ +
                                                ASC1_PatternsPointers;
    PlParams.ASC_B.Address_In_Pattern :=
     WordPtr(@Index[ASC1_PatternsPointers + 6 * Index[9] + 2])^ +
                                                ASC1_PatternsPointers;
    PlParams.ASC_C.Address_In_Pattern :=
     WordPtr(@Index[ASC1_PatternsPointers + 6 * Index[9] + 4])^ +
                                                ASC1_PatternsPointers
   end

 end;
FTCFile:
 begin
  with PlParams.FTC,RAM do
   begin
    Delay := FTC_Delay;
    DelayCounter := 1;
    CurrentPosition := 0;
    Transposition := FTC_Positions[0].Transposition;
    PlParams.FTC_A.Address_In_Pattern :=
         WordPtr(@Index[FTC_PatternsPointer + FTC_Positions[0].Pattern*6])^;
    PlParams.FTC_B.Address_In_Pattern :=
         WordPtr(@Index[FTC_PatternsPointer + FTC_Positions[0].Pattern*6 + 2])^;
    PlParams.FTC_C.Address_In_Pattern :=
         WordPtr(@Index[FTC_PatternsPointer + FTC_Positions[0].Pattern*6 + 4])^;
   end;

   with PlParams.FTC_A do
    begin
     OrnamentPointer := RAM.FTC_OrnamentsPointers[0];
     SamplePointer := $52;
     Note_Skip_Counter := 0;
     Loop_Ornament_Position := 0;
     Position_In_Ornament := 0;
     Ornament_Length := 1;
     Noise := 0;
     Noise_Accumulator := 0;
     Note_Accumulator := 0;
     Ton_Slide_Step1 := 0;
     Sample_Enabled := False;
     Envelope_Enabled := False;
     Volume := 15;
     Ton := 0
    end;

   with PlParams.FTC_B do
    begin
     OrnamentPointer := PlParams.FTC_A.OrnamentPointer;
     SamplePointer := $52;
     Note_Skip_Counter := 0;
     Loop_Ornament_Position := 0;
     Position_In_Ornament := 0;
     Ornament_Length := 1;
     Noise := 0;
     Noise_Accumulator := 0;
     Note_Accumulator := 0;
     Ton_Slide_Step1 := 0;
     Sample_Enabled := False;
     Envelope_Enabled := False;
     Volume := 15;
     Ton := 0
    end;

   with PlParams.FTC_C do
    begin
     OrnamentPointer := PlParams.FTC_A.OrnamentPointer;
     SamplePointer := $52;
     Note_Skip_Counter := 0;
     Loop_Ornament_Position := 0;
     Position_In_Ornament := 0;
     Ornament_Length := 1;
     Noise := 0;
     Noise_Accumulator := 0;
     Note_Accumulator := 0;
     Ton_Slide_Step1 := 0;
     Sample_Enabled := False;
     Envelope_Enabled := False;
     Volume := 15;
     Ton := 0
    end

 end;
STPFile:
 begin

  with PlParams.STP,RAM do
   begin
    DelayCounter := 1;
    Transposition := Index[STP_PositionsPointer + 3];
    CurrentPosition := 0;
    PlParams.STP_A.Address_In_Pattern :=
     WordPtr(@Index[STP_PatternsPointer + Index[STP_PositionsPointer + 2]])^;
    PlParams.STP_B.Address_In_Pattern :=
     WordPtr(@Index[STP_PatternsPointer + Index[STP_PositionsPointer + 2] + 2])^;
    PlParams.STP_C.Address_In_Pattern :=
     WordPtr(@Index[STP_PatternsPointer + Index[STP_PositionsPointer + 2] + 4])^;
   end;

  with PlParams.STP_A,RAM do
   begin
    SamplePointer := WordPtr(@Index[STP_SamplesPointer])^;
    Loop_Sample_Position := Index[SamplePointer];
    Inc(SamplePointer);
    Sample_Length := Index[SamplePointer];
    Inc(SamplePointer);
    PlParams.STP_B.SamplePointer := SamplePointer;
    PlParams.STP_B.Loop_Sample_Position := Loop_Sample_Position;
    PlParams.STP_B.Sample_Length := Sample_Length;
    PlParams.STP_C.SamplePointer := SamplePointer;
    PlParams.STP_C.Loop_Sample_Position := Loop_Sample_Position;
    PlParams.STP_C.Sample_Length := Sample_Length;

    OrnamentPointer := WordPtr(@Index[STP_OrnamentsPointer])^;
    Loop_Ornament_Position := Index[OrnamentPointer];
    Inc(OrnamentPointer);
    Ornament_Length := Index[OrnamentPointer];
    Inc(OrnamentPointer);
    PlParams.STP_B.OrnamentPointer := OrnamentPointer;
    PlParams.STP_B.Loop_Ornament_Position := Loop_Ornament_Position;
    PlParams.STP_B.Ornament_Length := Ornament_Length;
    PlParams.STP_C.OrnamentPointer := OrnamentPointer;
    PlParams.STP_C.Loop_Ornament_Position := Loop_Ornament_Position;
    PlParams.STP_C.Ornament_Length := Ornament_Length;

    Envelope_Enabled := False;
    Glissade := 0;
    Current_Ton_Sliding := 0;
    Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Note_Skip_Counter := 0;
    Volume := 0;
    Ton := 0
   end;

  with PlParams.STP_B do
   begin
    Envelope_Enabled := False;
    Glissade := 0;
    Current_Ton_Sliding := 0;
    Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Note_Skip_Counter := 0;
    Volume := 0;
    Ton := 0
   end;

  with PlParams.STP_C do
   begin
    Envelope_Enabled := False;
    Glissade := 0;
    Current_Ton_Sliding := 0;
    Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Note_Skip_Counter := 0;
    Volume := 0;
    Ton := 0
   end
   
 end;
PSCFile:
 begin

  with PlParams.PSC,RAM do
   begin
    DelayCounter := 1;
    Delay := PSC_Delay;
    Positions_Pointer := PSC_PatternsPointer;
    Lines_Counter := 1;
    Noise_Base := 0
   end;

  with PlParams.PSC_A,RAM do
   begin
    SamplePointer := PSC_SamplesPointers[0] + $4c;
    PlParams.PSC_B.SamplePointer := SamplePointer;
    PlParams.PSC_C.SamplePointer := SamplePointer;
    OrnamentPointer := WordPtr(@Index[PSC_OrnamentsPointer])^ +
                                                       PSC_OrnamentsPointer;
    PlParams.PSC_B.OrnamentPointer := OrnamentPointer;
    PlParams.PSC_C.OrnamentPointer := OrnamentPointer;

    Break_Ornament_Loop := False;
    Ornament_Enabled := False;
    Enabled := False;
    Break_Sample_Loop := False;
    Ton_Slide_Enabled := False;
    Note_Skip_Counter := 1;
    Ton := 0
   end;

  with PlParams.PSC_B do
   begin
    Break_Ornament_Loop := False;
    Ornament_Enabled := False;
    Enabled := False;
    Break_Sample_Loop := False;
    Ton_Slide_Enabled := False;
    Note_Skip_Counter := 1;
    Ton := 0
   end;

  with PlParams.PSC_C do
   begin
    Break_Ornament_Loop := False;
    Ornament_Enabled := False;
    Enabled := False;
    Break_Sample_Loop := False;
    Ton_Slide_Enabled := False;
    Note_Skip_Counter := 1;
    Ton := 0
   end

 end;
PT1File:
 begin
  with PlParams.PT1,RAM do
   begin
    DelayCounter := 1;
    Delay := PT1_Delay;
    CurrentPosition := 0;
    Move(Index[PT1_PatternsPointer +
                PT1_PositionList[0] * 6],
               PlParams.PT1_A.Address_In_Pattern,2);
    Move(Index[PT1_PatternsPointer +
                PT1_PositionList[0]*6 + 2],
               PlParams.PT1_B.Address_In_Pattern,2);
    Move(Index[PT1_PatternsPointer +
                PT1_PositionList[0]*6 + 4],
               PlParams.PT1_C.Address_In_Pattern,2)
   end;

   with PlParams.PT1_A do
    begin
     OrnamentPointer := RAM.PT1_OrnamentsPointers[0];
     Envelope_Enabled := False;
     Position_In_Sample := 0;
     Enabled := False;
     Number_Of_Notes_To_Skip := 0;
     Note_Skip_Counter := 0;
     Volume := 15;
     Ton := 0
    end;

   with PlParams.PT1_B do
    begin
     OrnamentPointer := PlParams.PT1_A.OrnamentPointer;
     Envelope_Enabled := False;
     Position_In_Sample := 0;
     Enabled := False;
     Number_Of_Notes_To_Skip := 0;
     Note_Skip_Counter := 0;
     Volume := 15;
     Ton := 0
    end;

   with PlParams.PT1_C do
    begin
     OrnamentPointer := PlParams.PT1_A.OrnamentPointer;
     Envelope_Enabled := False;
     Position_In_Sample := 0;
     Enabled := False;
     Number_Of_Notes_To_Skip := 0;
     Note_Skip_Counter := 0;
     Volume := 15;
     Ton := 0
    end;

 end;
PT2File:
 begin
  with PlParams.PT2,RAM do
   begin
    DelayCounter := 1;
    Delay := PT2_Delay;
    CurrentPosition := 0;
   end;

  with RAM do
   begin
    PlParams.PT2_A.Address_In_Pattern :=
      WordPtr(@Index[PT2_PatternsPointer +
                     PT2_PositionList[0] * 6])^;
    PlParams.PT2_B.Address_In_Pattern :=
      WordPtr(@Index[PT2_PatternsPointer +
                     PT2_PositionList[0] * 6 + 2])^;
    PlParams.PT2_C.Address_In_Pattern :=
      WordPtr(@Index[PT2_PatternsPointer +
                     PT2_PositionList[0] * 6 + 4])^;
   end;

  with PlParams.PT2_A,RAM do
   begin
    OrnamentPointer := PT2_OrnamentsPointers[0];
    Ornament_Length := Index[OrnamentPointer];
    Inc(OrnamentPointer);
    Loop_Ornament_Position := Index[OrnamentPointer];
    Inc(OrnamentPointer);
    Envelope_Enabled := False;
    Position_In_Sample := 0;
    Position_In_Ornament := 0;
    Addition_To_Noise := 0;
    Glissade := 0;
    Current_Ton_Sliding:=0;
    GlissType := 0;
    Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Note_Skip_Counter := 0;
    Volume := 15;
    Ton := 0
   end;

  with PlParams.PT2_B do
   begin
    OrnamentPointer := PlParams.PT2_A.OrnamentPointer;
    Loop_Ornament_Position := PlParams.PT2_A.Loop_Ornament_Position;
    Ornament_Length := PlParams.PT2_A.Ornament_Length;
    Envelope_Enabled := False;
    Position_In_Sample := 0;
    Position_In_Ornament := 0;
    Addition_To_Noise := 0;
    Glissade := 0;
    Current_Ton_Sliding := 0;
    GlissType := 0;
    Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Note_Skip_Counter := 0;
    Volume := 15;
    Ton := 0
   end;

  with PlParams.PT2_C do
   begin
    OrnamentPointer := PlParams.PT2_A.OrnamentPointer;
    Loop_Ornament_Position := PlParams.PT2_A.Loop_Ornament_Position;
    Ornament_Length := PlParams.PT2_A.Ornament_Length;
    Envelope_Enabled := False;
    Position_In_Sample := 0;
    Position_In_Ornament := 0;
    Addition_To_Noise := 0;
    Glissade := 0;
    Current_Ton_Sliding := 0;
    GlissType := 0;
    Enabled := False;
    Number_Of_Notes_To_Skip := 0;
    Note_Skip_Counter := 0;
    Volume := 15;
    Ton := 0
   end
 end;
PT3File:
 begin
  with PlParams.PT3,RAM do
   begin
    DelayCounter := 1;
    Delay := PT3_Delay;
    CurrentPosition := 0;
    Noise_Base := 0;
    AddToNoise := 0;
    Cur_Env_Slide := 0;
    Cur_Env_Delay := 0;
    Env_Base.wrd := 0
   end;

   with RAM do
    begin
     PlParams.PT3_A.Address_In_Pattern :=
        WordPtr(@Index[PT3_PatternsPointer + PT3_PositionList[0] * 2])^;
     PlParams.PT3_B.Address_In_Pattern :=
        WordPtr(@Index[PT3_PatternsPointer + PT3_PositionList[0] * 2 + 2])^;
     PlParams.PT3_C.Address_In_Pattern :=
        WordPtr(@Index[PT3_PatternsPointer + PT3_PositionList[0] * 2 + 4])^
    end;

   with PlParams.PT3_A,RAM do
    begin
     OrnamentPointer := PT3_OrnamentsPointers[0];
     Loop_Ornament_Position := Index[OrnamentPointer];
     inc(OrnamentPointer);
     Ornament_Length := Index[OrnamentPointer];
     inc(OrnamentPointer);
     SamplePointer := PT3_SamplesPointers[1];
     Loop_Sample_Position := Index[SamplePointer];
     inc(SamplePointer);
     Sample_Length := Index[SamplePointer];
     inc(SamplePointer);
     Volume := 15;
     Current_Ton_Sliding := 0;
     Note_Skip_Counter := 1;
     Enabled := False;
     Envelope_Enabled := False;
     Note := 0;
     Ton := 0
    end;

   with PlParams.PT3_B do
    begin
     OrnamentPointer := PlParams.PT3_A.OrnamentPointer;
     Loop_Ornament_Position := PlParams.PT3_A.Loop_Ornament_Position;
     Ornament_Length := PlParams.PT3_A.Ornament_Length;
     SamplePointer := PlParams.PT3_A.SamplePointer;
     Loop_Sample_Position := PlParams.PT3_A.Loop_Sample_Position;
     Sample_Length := PlParams.PT3_A.Sample_Length;
     Volume := 15;
     Current_Ton_Sliding := 0;
     Note_Skip_Counter := 1;
     Enabled := False;
     Envelope_Enabled := False;
     Note := 0;
     Ton := 0
    end;

   with PlParams.PT3_C do
    begin
     OrnamentPointer := PlParams.PT3_A.OrnamentPointer;
     Loop_Ornament_Position := PlParams.PT3_A.Loop_Ornament_Position;
     Ornament_Length := PlParams.PT3_A.Ornament_Length;
     SamplePointer := PlParams.PT3_A.SamplePointer;
     Loop_Sample_Position := PlParams.PT3_A.Loop_Sample_Position;
     Sample_Length := PlParams.PT3_A.Sample_Length;
     Volume := 15;
     Current_Ton_Sliding := 0;
     Note_Skip_Counter := 1;
     Enabled := False;
     Envelope_Enabled := False;
     Note := 0;
     Ton := 0
    end;

 end;
SQTFile:
 begin
  with PlParams.SQT_A do
   begin
    Ton:=0;
    Envelope_Enabled := False;
    Ornament_Enabled := False;
    Gliss := False;
    Enabled := False
   end;
  with PlParams.SQT_B do
   begin
    Ton:=0;
    Envelope_Enabled := False;
    Ornament_Enabled := False;
    Gliss := False;
    Enabled := False
   end;
  with PlParams.SQT_C do
   begin
    Ton:=0;
    Envelope_Enabled := False;
    Ornament_Enabled := False;
    Gliss := False;
    Enabled := False
   end;

  with PlParams.SQT do
   begin
    DelayCounter := 1;
    Delay := 1;
    Lines_Counter := 1;
    Positions_Pointer := RAM.SQT_PositionsPointer
   end

 end;
PSMFile:
 begin
  with PlParams.PSM do
   begin
    CurrentPosition := 0;
    Finished := False;
    b := RAM.Index[RAM.PSM_PositionsPointer];
    Transposition := RAM.Index[RAM.PSM_PositionsPointer + 1] + 48;
    Delay := RAM.Index[RAM.PSM_PatternsPointer + b * 7];
    PlParams.PSM_A.Address_In_Pattern :=
           WordPtr(@RAM.Index[RAM.PSM_PatternsPointer + b * 7 + 1])^;
    PlParams.PSM_B.Address_In_Pattern :=
           WordPtr(@RAM.Index[RAM.PSM_PatternsPointer + b * 7 + 3])^;
    PlParams.PSM_C.Address_In_Pattern :=
           WordPtr(@RAM.Index[RAM.PSM_PatternsPointer + b * 7 + 5])^;
    PlParams.PSM_A.RetCnt := 0;
    PlParams.PSM_B.RetCnt := 0;
    PlParams.PSM_C.RetCnt := 0;
    PlParams.PSM_A.Note_Skip_Counter := 1;
    PlParams.PSM_B.Note_Skip_Counter := 1;
    PlParams.PSM_C.Note_Skip_Counter := 1;
    PlParams.PSM_A.Note := -128;
    PlParams.PSM_B.Note := -128;
    PlParams.PSM_C.Note := -128;
    DelayCounter := 1
   end;
 end;
VTXFile,YM3File..YM3bFile:
 Position_In_VTX := 0;
EPSGFile:
 begin
  UniFileSeek(FileHandle,16);
  Previous_AY_Takt := 0
 end;
PSGFile:
 begin
  UniFileSeek(FileHandle,16);
  PSG_Skip := 0
 end;
ZXAYFile:
 begin
  UniFileSeek(FileHandle,4);
  Previous_AY_Takt := 0
 end
end;
for i := 0 to 12 do RegisterAY.Index[i] := 0;
SetEnvelopeRegister(0);
SetMixerRegister(0);
SetAmplA(0);
SetAmplB(0);
SetAmplC(0);
First_Period := False;
Ampl := 0;
Current_RegisterAY := 0;
if Optimization_For_Quality and IsFilt then
 begin
  FillChar(Filt_XL[0],(Filt_M + 1) * 4,0);
  FillChar(Filt_XR[0],(Filt_M + 1) * 4,0);
  Filt_I := 0
 end;
Beeper := 0;
if InitAll then
 begin
  BaseSample := 0;
  MkVisPos := 0;
  VisPoint := 0;
  NOfTicks := 0;
  ResetAYChipEmulation;
  Reseted := 0;
  Global_Tick_Counter := 0;
  if not (CurFileType in [BASSFileMin..BASSFileMax,CDAFile]) then
   ProgrMax := round(Time_ms/1000*SampleRate);
  Real_End := False;
  VProgrPos := 0;
  ShowProgress(VProgrPos)
 end
end;

procedure InsertTitleASC;
var
 n:integer;
begin
if Sz > 65536 - 63 then exit;
if Length(TtlStr) <> 63 then exit;
if Module.ASC1_PatternsPointers - Module.ASC1_Number_Of_Positions <> 9 then exit;
if Copy(TtlStr,1,Length(AscId)) <> AscId then exit;
inc(Module.ASC1_PatternsPointers,63);
inc(Module.ASC1_SamplesPointers,63);
inc(Module.ASC1_OrnamentsPointers,63);
n := Module.ASC1_Number_Of_Positions;
Move(Module.ASC1_Positions[n],Module.ASC1_Positions[n + 63],Sz - 9 - n);
Move(TtlStr[1],Module.ASC1_Positions[n],63);
inc(Sz,63)
end;

procedure InsertTitleSTP;
var
 KsaId2:string;
 i:integer;
 p:PWord;
begin
if Sz > 65536 - 53 then exit;
if Length(TtlStr) <> 53 then exit;
if Copy(TtlStr,1,Length(KsaId)) <> KsaId then exit;
SetLength(KsaId2,Length(KsaId));
Move(Module.Index[10],KsaId2[1],Length(KsaId));
if KsaId2 = KsaId then exit;
inc(Module.STP_PositionsPointer,53);
inc(Module.STP_PatternsPointer,53);
inc(Module.STP_OrnamentsPointer,53);
inc(Module.STP_SamplesPointer,53);
Move(Module.Index[10],Module.Index[10 + 53],Sz - 10);
Move(TtlStr[1],Module.Index[10],53);
inc(Sz,53);
p := @Module.Index[Module.STP_PatternsPointer];
for i := 1 to (Sz - Module.STP_PatternsPointer) div 2 do
 begin
  inc(p^,53);
  inc(integer(p),2)
 end
end;

function FoundFXM(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 Limit:integer;

 function ValidSample(var Add2:integer):boolean;
 var
  b:byte;
  Addr:integer;
 begin
  Result := False;
  if Add2 >= Limit then exit;
  Addr := Add2;
  b := F_Frame.Index[Addr];
  if b = $80 then exit;
  repeat
   case b of
   0..$F:
    begin
     inc(Addr);
     if Addr >= Limit then exit
    end;
   $80:
    begin
     inc(Addr,3);
     if Addr <= Limit + 1 then
      begin
       Result := True;
       Add2 := Addr
      end;
     exit
    end;
   $32..$41:
   else exit;
   end;
   inc(Addr);
   if Addr >= Limit then exit;
   b := F_Frame.Index[Addr]
  until False
 end;

 function ValidOrnament(var Add2:integer):boolean;
 var
  b:shortint;
  flg,flg82,flg83,flg84:boolean;
  Mode:boolean;
  Addr:integer;
 begin
  Result := False;
  if Add2 >= Limit then exit;
  Mode := True;
  Addr := Add2;
  b := F_Frame.Index[Addr];
  if b = -128 then exit;
  flg := False;
  flg82 := False;
  flg83 := False;
  flg84 := False;
  repeat
   case b of
   -126:
    begin
     if flg82 or flg83 then exit;
     Mode := True;
     flg82 := True
    end;
   -125:
    begin
     if flg83 or flg82 then exit;
     Mode := False;
     flg83 := True
    end;
   -124:
    begin
     if flg84 then exit;
     flg84 := True
    end;
   -128:
    begin
     if not flg then exit;
     inc(Addr,3);
     if Addr <= Limit + 1 then
      begin
       Result := True;
       Add2 := Addr
      end;
     exit
    end;
   else
    begin
     if Mode then
      if (b < -$53) or (b > $53) then exit;
     flg := True;
     flg82 := False;
     flg83 := False;
     flg84 := False
    end;
   end;
   inc(Addr);
   if Addr >= Limit then exit;
   b := F_Frame.Index[Addr]
  until False
 end;

 function ValidPattern(var Addr,Add2:integer;var Podpr:boolean):boolean;
 var
  flg:boolean;
  flg86,flg87,flg82,flg84,flg88,flg8a,flg8b,flg8d,flg8e:boolean;
  count82:integer;
  b:byte;
 begin
  Result := False;
  Add2 := Addr;
  if Addr >= Limit then exit;
  b := F_Frame.Index[Addr];
  if b = $80 then exit;
  flg := False;
  flg86 := False;
  flg87 := False;
  flg82 := False;
  count82 := 0;
  flg84 := False;
  flg88 := False;
  flg8a := False;
  flg8b := False;
  flg8d := False;
  flg8e := False;
  repeat
   case b of
   0..$54:
    begin
     inc(Addr);
     if Addr >= Limit then exit;
     flg := True;
     flg82 := False;
     flg86 := False;
     flg87 := False;
     flg84 := False;
     flg88 := False;
     flg8a := False;
     flg8b := False;
     flg8d := False;
     flg8e := False
    end;
   $80:
    begin
     if not flg then exit;
     inc(Addr,3);
     Podpr := False;
     Result := Addr <= Limit + 1;
     exit
    end;
   $89:
    begin
     if not flg or (count82 <> 0) then exit;
     inc(Addr);
     Podpr := True;
     Result := Addr <= Limit + 1;
     exit
    end;
   $81:
    begin
     inc(Addr,2);
     if Addr >= Limit then exit;
     flg := True;
     flg82 := False;
     flg86 := False;
     flg87 := False;
     flg84 := False;
     flg88 := False;
     flg8a := False;
     flg8b := False;
     flg8d := False;
     flg8e := False
    end;
   $82: 
    begin
     inc(Addr);
     if Addr >= Limit then exit;
     inc(count82);
     flg82 := True
    end;
   $83:
    begin
     if flg82 then exit;
     if count82 <= 0 then exit;
     flg := True;
     flg82 := False;
     flg86 := False;
     flg87 := False;
     flg84 := False;
     flg88 := False;
     flg8a := False;
     flg8b := False;
     flg8d := False;
     flg8e := False;
     dec(count82)
    end;
   $84:
    begin
     if flg84 then exit;
     inc(Addr);
     if Addr >= Limit then exit;
     flg84 := True
    end;
   $85:
    begin
     inc(Addr);
     if Addr >= Limit then exit;
    end;
   $86:
    begin
     if flg86 then exit;
     inc(Addr,2);
     if Addr >= Limit then exit;
     flg86 := True
    end;
   $87:
    begin
     if flg87 then exit;
     inc(Addr,2);
     if Addr >= Limit then exit;
     flg87 := True
    end;
   $88: 
    begin
     if flg88 then exit;
     inc(Addr);
     if Addr >= Limit then exit;
     flg88 := True
    end;
   $8A:
    begin
     if flg8a or flg8b then exit;
     flg8a := True
    end;
   $8B:
    begin
     if flg8a or flg8b then exit;
     flg8b := True
    end;
   $8C:
    begin
     inc(Addr,2);
     if Addr >= Limit then exit
    end;
   $8D:
    begin
     if flg8d then exit;
     inc(Addr);
     if Addr >= Limit then exit;
     flg8d := True
    end;
   $8E:
    begin
     if flg8e then exit;
     inc(Addr);
     if Addr >= Limit then exit;
     flg8e := True
    end;
   else exit;
   end;
   inc(Addr);
   if Addr >= Limit then exit;
   b := F_Frame.Index[Addr]
  until False;
 end;

type
 FXMTypes = (TPat,TSub,TSam,TOrn);
 PFXMObject = ^FXMObject;
 FXMObject = record
   Addr,Last:word;
   Typ:FXMTypes;
 end;
var
 RecDeep:integer;
 function BuildPatternStructure(var Pat:TList;Addr:integer):boolean;
  function ValidSample(var Addr,Add2:integer):boolean;
  var
   b:byte;
  begin
   Result := False;
   Add2 := Addr;
   if Addr > Limit then exit;
   b := F_Frame.Index[Addr];
   if b = $80 then exit;
   repeat
    case b of
    0..$F:
     begin
      inc(Addr);
      if Addr >= Limit then exit
     end;
    $80:
     begin
      inc(Addr,3);
      if Addr <= Limit + 1 then
       begin
        if WordPointer(@F_Frame.Index[Addr - 2])^ < F_Address + 6 then exit;
        Result := True;
        exit
       end
     end;
    $32..$41:
    else
     exit;
    end; 
    inc(Addr);
    if Addr >= Limit then exit;
    b := F_Frame.Index[Addr]
   until False
  end;

  function ValidOrnament(var Addr,Add2:integer):boolean;
  var
   b:shortint;
   flg,flg82,flg83,flg84:boolean;
  begin
   Result := False;
   Add2 := Addr;
   if Addr > Limit then exit;
   b := F_Frame.Index[Addr];
   if b = -128 then exit;
   flg := False;
   flg82 := False;
   flg83 := False;
   flg84 := False;
   repeat
    case b of
    -126:
     begin
      if flg82 or flg83 then exit;
      flg82 := True
     end;
    -125:
     begin
      if flg83 or flg82 then exit;
      flg83 := True
     end;
    -124:
     begin
      if flg84 then exit;
      flg84 := True
     end;
    -128:
     begin
      if not flg then exit;
      inc(Addr,3);
      if Addr <= Limit + 1 then
       begin
        if WordPointer(@F_Frame.Index[Addr - 2])^ < F_Address + 6 then exit;
        Result := True;
        exit
       end
     end;
    else
     begin
      flg := True;
      flg82 := False;
      flg83 := False;
      flg84 := False
     end;
    end;
    inc(Addr);
    if Addr >= Limit then exit;
    b := F_Frame.Index[Addr]
   until False
  end;

 var
  b:byte;
  Add2,AddT1,AddT2:integer;
  FXMO:PFXMObject;
  i:integer;
 begin
  Result := False;
  if RecDeep > 15 then exit;
  if Addr < F_Address + 6 then exit;
  dec(Addr,F_Address);
  if Addr >= Limit then exit;
  Add2 := Addr;
  b := F_Frame.Index[Addr];
  if b = $80 then exit;
  repeat
   case b of
   $8D,$8E,$88,
   $84,$85,$82,
   0..$54:
    begin
     inc(Addr);
     if Addr >= Limit then exit;
    end;
   $80:
    begin
     inc(Addr,3);
     if Addr <= Limit + 1 then
      begin
       if WordPointer(@F_Frame.Index[Addr - 2])^ < F_Address + 6 then exit;
       Result := True;
       New(FXMO);
       FXMO.Addr := Add2;
       FXMO.Last := Addr;
       FXMO.Typ := TPat;
       Pat.Add(FXMO)
      end;
     exit
    end;
   $89:
    begin
     inc(Addr);
     if Addr <= Limit + 1 then
      begin
       Result := True;
       New(FXMO);
       FXMO.Addr := Add2;
       FXMO.Last := Addr;
       FXMO.Typ := TSub;
       Pat.Add(FXMO)
      end;
     exit
    end;
   $81: 
    begin
     inc(Addr,2);
     if Addr >= Limit then exit;
     if WordPointer(@F_Frame.Index[Addr - 1])^ < F_Address + 6 then exit;
     inc(RecDeep);
     if not BuildPatternStructure(Pat,
                WordPointer(@F_Frame.Index[Addr - 1])^) then exit;
     dec(RecDeep)
    end;
   $86:
    begin
     inc(Addr,2);
     if Addr >= Limit then exit;
     i := WordPointer(@F_Frame.Index[Addr - 1])^ - F_Address;
     if i < 6 then exit;
     AddT1 := i;
     if not ValidOrnament(AddT1,AddT2) then exit;
     New(FXMO);
     FXMO.Addr := AddT2;
     FXMO.Last := AddT1;
     FXMO.Typ := TOrn;
     Pat.Add(FXMO)
    end;
   $87:
    begin
     inc(Addr,2);
     if Addr >= Limit then exit;
     i := WordPointer(@F_Frame.Index[Addr - 1])^ - F_Address;
     if i < 6 then exit;
     AddT1 := i;
     if not ValidSample(AddT1,AddT2) then exit;
     New(FXMO);
     FXMO.Addr := AddT2;
     FXMO.Last := AddT1;
     FXMO.Typ := TSam;
     Pat.Add(FXMO)
    end;
   $8C:
    begin
     inc(Addr,2);
     if Addr >= Limit then exit
    end;
   $8A,$8B,$83:
   else
    exit;
   end;
   inc(Addr);
   if Addr >= Limit then exit;
   b := F_Frame.Index[Addr]
  until False;
 end;

 function FXM_Structure(var Size:word):boolean;
 var
  PatA,PatB,PatC:TList;
  i:integer;
  min,max:word;
 begin
  Result := False;
  PatA := TList.Create;
  PatB := TList.Create;
  PatC := TList.Create;
  RecDeep := 0;
  if BuildPatternStructure(PatA,WordPointer(@F_Frame.Index[0])^) then
   if BuildPatternStructure(PatB,WordPointer(@F_Frame.Index[2])^) then
    if BuildPatternStructure(PatC,WordPointer(@F_Frame.Index[4])^) then
   begin
    max := 0;
    min := 65535;
    for i := 0 to PatA.Count - 1 do
     begin
      if min > PFXMObject(PatA.Items[i]).Addr then
       min := PFXMObject(PatA.Items[i]).Addr;
      if max < PFXMObject(PatA.Items[i]).Last then
       max := PFXMObject(PatA.Items[i]).Last;
     end;
    for i := 0 to PatB.Count - 1 do
     begin
      if min > PFXMObject(PatB.Items[i]).Addr then
       min := PFXMObject(PatB.Items[i]).Addr;
      if max < PFXMObject(PatB.Items[i]).Last then
       max := PFXMObject(PatB.Items[i]).Last;
     end;
    for i := 0 to PatC.Count - 1 do
     begin
      if min > PFXMObject(PatC.Items[i]).Addr then
       min := PFXMObject(PatC.Items[i]).Addr;
      if max < PFXMObject(PatC.Items[i]).Last then
       max := PFXMObject(PatC.Items[i]).Last;
     end;
    Size := max;
    Result := (min in [6..56]) and (Size >= 63)
   end;
  for i := 0 to PatA.Count - 1 do
   Dispose(PFXMObject(PatA.Items[i]));
  PatA.Clear;
  for i := 0 to PatB.Count - 1 do
   Dispose(PFXMObject(PatB.Items[i]));
  PatB.Clear;
  for i := 0 to PatC.Count - 1 do
   Dispose(PFXMObject(PatC.Items[i]));
  PatC.Clear;
 end;

type
 TPatterns = record
   Address:word;
   FirstFreeAddress:word;
 end;

var
 Add1,Add2:integer;
 Podpr:boolean;
 Patterns:array[0..16383] of TPatterns;
 NPat,i,j:integer;
 Size:word;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundFXM := False;
if Readen1 < 63 then exit;
NPat := 0;

if Readen1 < 49152 then
 Limit := Readen1
else
 Limit := 49151;

Podpr := False;
for i := 6 to 50 do
 if F_Frame.Index[i] in [$80,$86,$87] then
  begin
   Podpr := True;
   break
  end;
if not Podpr then exit;

Add1 := 6;
repeat
if not ValidSample(Add1) then
 if ValidPattern(Add1,Add2,Podpr) then
  begin
   if not Podpr then
    begin
     if NPat = 16384 then exit;
     Patterns[NPat].Address := Add2;
     Patterns[NPat].FirstFreeAddress := Add1;
     inc(NPat)
    end
  end
 else if not ValidOrnament(Add2) then
  begin
   if NPat = 0 then exit;
   for i := 0 to NPat - 1 do
    for j := 0 to 2 do
     begin
      F_Address := WordPointer(@F_Frame.Index[j*2])^ - Patterns[i].Address;
      if F_Address >= 0 then
       if FXM_Structure(Size) then
        begin
         if IntegrityCheck then
          try
           New(M);
           try
            if not LoadTrackerModule(M^,-1,F_Address,Size,F_Frame,FXMFile) then exit;
            GetTimeFXM(M,F_Address,TimeLength,LoopPoint);
            if TimeLength = 0 then exit
           finally
            Dispose(M)
           end 
          except
           exit
          end;
         FoundFXM := True;
         F_Length := Size;
         Exit
        end;
     end;
   Exit
  end
 else
  Add1 := Add2
until False
end;

function FoundGTR(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1:integer;
 w,w2,adr:word;
 b:byte;
 wp:WordPtr;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundGTR := False;
if Readen1 < 296 then exit;
adr := F_Frame.GTR_Address;
w := F_Frame.GTR_PatternsPointers[0].PatternA - adr;
if w > Readen1 then exit;
b := F_Frame.GTR_NumberOfPositions;
if w <> b + 295 then exit;
if F_Frame.GTR_LoopPosition >= b then exit;
for j := 0 to 13 do
 begin
  j1 := F_Frame.GTR_SamplesPointers[j + 1] -
          F_Frame.GTR_SamplesPointers[j];
  if j1 < 6 then exit;
  if (j1 - 2) mod 4 <> 0 then exit;
 end;

wp := @F_Frame.GTR_OrnamentsPointers[0];
w := wp^;
for j := 0 to 14 do
 begin
  inc(integer(wp),2);
  w2 := wp^;
  if w2 - w < 3 then exit;
  w := w2
 end;

inc(integer(wp),2);
w := wp^;
for j := 0 to 32*3 - 2 do
 begin
  inc(integer(wp),2);
  w2 := wp^;
  if w2 - w < 3 then exit;
  w := w2
 end;

wp := @F_Frame.GTR_SamplesPointers[0];

for j := 0 to 30 do
 begin
  w := wp^ - adr;
  if w >= Readen1 then exit;
  if F_Frame.Index[w] >= F_Frame.Index[w + 1] then exit;
  inc(integer(wp),2)
 end;

F_Length := F_Frame.GTR_OrnamentsPointers[15] + 3 - adr;
if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,adr,F_Length,F_Frame,GTRFile) then exit;
   GetTimeGTR(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;
wp := @F_Frame.GTR_SamplesPointers[0];
for j := 0 to (15 + 16 + 32*3) - 1 do
 begin
  dec(wp^,adr);
  inc(integer(wp),2)
 end;
F_Frame.GTR_Address := 0;
F_Address := adr;
FoundGTR := True
end;

function FoundST(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2:integer;
 M:PModTypes;
begin
TimeLength := 0;
FoundST := False;
if Readen1 < 6 then exit;
if F_Frame.ST_PositionsPointer > Readen1 then exit;
if Integer(F_Frame.ST_PatternsPointer -
                F_Frame.ST_OrnamentsPointer) <= 0 then exit;
if (F_Frame.ST_PatternsPointer -
         F_Frame.ST_OrnamentsPointer) mod $21 <> 0 then exit;
if Integer(F_Frame.ST_PositionsPointer -
                F_Frame.ST_OrnamentsPointer) >= 0 then exit;
if F_Frame.Index[F_Frame.ST_PositionsPointer] * 2 + 3 +
        F_Frame.ST_PositionsPointer - F_Frame.ST_OrnamentsPointer <> 0 then exit;

j := F_Frame.ST_OrnamentsPointer + $21;
if j > 65535 then exit;
if j > Readen1 then exit;
repeat
 dec(j);
 if F_Frame.Index[j] <> 0 then exit;
until j = F_Frame.ST_OrnamentsPointer;

j:=F_Frame.ST_PatternsPointer;
if j > Readen1 then exit;
j1 := 0; j2 := 0;
while (j + 6 <= Readen1) and (j + 6 < 65536) and (F_Frame.Index[j] <> 255) do
 begin
  inc(j);
  move(F_Frame.Index[j],j2,2);
  if j1 < j2 then j1 := j2;
  inc(j,2);
  move(F_Frame.Index[j],j2,2);
  if j1 < j2 then j1 := j2;
  inc(j,2);
  move(F_Frame.Index[j],j2,2);
  if j1 < j2 then j1 := j2;
  inc(j,2);
 end;
if F_Frame.Index[j] <> 255 then exit;
if j1 > Readen1 then exit;
if F_Frame.Index[j1 - 1] <> 255 then exit;

repeat
 if F_Frame.Index[j1] in [$83..$8e] then inc(j1);
 inc(j1);
until (j1 > 65535) or (j1 > Readen1) or (F_Frame.Index[j1] = 255);
if j1 > 65535 then exit;
if j1 > Readen1 then exit;

F_Length := j1 + 1;
//Frame.ST_Size := F_Length; //Agent-X used it for names
if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,0,F_Length,F_Frame,STCFile) then exit;
   GetTimeSTC(M,TimeLength);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;
FoundST := True
end;

function FoundASC1(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1:integer;
 j3:byte;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundASC1 := False;
if Readen1 < 9 then exit;
if not ((F_Frame.ASC1_PatternsPointers -
            F_Frame.ASC1_Number_Of_Positions) in [9,72]) then exit;
if F_Frame.ASC1_PatternsPointers > Readen1 then exit;
if F_Frame.ASC1_SamplesPointers > Readen1 then exit;
if F_Frame.ASC1_OrnamentsPointers > Readen1 then exit;

j := 0;
move(F_Frame.Index[F_Frame.ASC1_SamplesPointers],j,2);
if j <> $40 then exit;

move(F_Frame.Index[F_Frame.ASC1_OrnamentsPointers],j,2);
if j <> $40 then exit;

j3 := 0;
for j1 := 0 to Pred(F_Frame.ASC1_Number_Of_Positions) do
 if j3 < F_Frame.ASC1_Positions[j1] then
  j3 := F_Frame.ASC1_Positions[j1];

move(F_Frame.Index[F_Frame.ASC1_PatternsPointers],j,2);
if j <> (j3 + 1) * 6 then exit;

move(F_Frame.Index[F_Frame.ASC1_OrnamentsPointers + $40 - 2],j,2);
inc(j,F_Frame.ASC1_OrnamentsPointers);
while (j < Readen1) and (j < 65535) and (F_Frame.Index[j] and $40 = 0) do
 inc(j,2);
if j > 65534 then exit;
if j >= Readen1 then exit;

F_Length := j + 2;
if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,0,F_Length,F_Frame,ASCFile) then exit;
   GetTimeASC(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;
FoundASC1 := True
end;

function FoundASC0(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1:integer;
 j3:byte;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundASC0 := False;
if Readen1 < 9 then exit;
if F_Frame.ASC0_PatternsPointers - 8 -
       F_Frame.ASC0_Number_Of_Positions <> 0 then exit;
if F_Frame.ASC0_PatternsPointers > Readen1 then exit;
if F_Frame.ASC0_SamplesPointers > Readen1 then exit;
if F_Frame.ASC0_OrnamentsPointers > Readen1 then exit;

j := 0;
move(F_Frame.Index[F_Frame.ASC0_SamplesPointers],j,2);
if j <> $40 then exit;

move(F_Frame.Index[F_Frame.ASC0_OrnamentsPointers],j,2);
if j <> $40 then exit;

j3 := 0;
for j1 := 0 to Pred(F_Frame.ASC0_Number_Of_Positions) do
 if j3 < F_Frame.ASC0_Positions[j1] then j3 := F_Frame.ASC0_Positions[j1];

move(F_Frame.Index[F_Frame.ASC0_PatternsPointers],j,2);
if j <> (j3 + 1) * 6 then exit;

move(F_Frame.Index[F_Frame.ASC0_OrnamentsPointers + $40 - 2],j,2);
inc(j,F_Frame.ASC0_OrnamentsPointers);
while (j < Readen1) and (j < 65535) and (F_Frame.Index[j] and $40 = 0) do
 inc(j,2);
if j > 65534 then exit;
if j >= Readen1 then exit;

F_Length := j + 2;
if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,0,F_Length,F_Frame,ASC0File) then exit;
   GetTimeASC(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;
FoundASC0 := True
end;

function FoundSTP(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2,j3:integer;
 KsaId2:string;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
Result := False;
if Readen1 < 10 then exit;
if F_Frame.STP_PositionsPointer > Readen1 then exit;
if F_Frame.STP_PatternsPointer > Readen1 then exit;
if F_Frame.STP_OrnamentsPointer > Readen1 then exit;
if F_Frame.STP_SamplesPointer > Readen1 then exit;
if F_Frame.STP_SamplesPointer - F_Frame.STP_OrnamentsPointer <> $20 then exit;
if Integer(F_Frame.STP_OrnamentsPointer -
                F_Frame.STP_PatternsPointer) <= 0 then exit;
if (F_Frame.STP_OrnamentsPointer -
         F_Frame.STP_PatternsPointer) mod 6 <> 0 then exit;
if F_Frame.Index[F_Frame.STP_PositionsPointer] * 2 + 2 +
     F_Frame.STP_PositionsPointer - F_Frame.STP_PatternsPointer <> 0 then exit;
F_Length := F_Frame.STP_SamplesPointer + 30;
if F_Length > 65535 then exit;
if F_Length > Readen1 + 1 then exit;

j2 := 0;
j3 := F_Frame.STP_Init_Id;
if j3 = 0 then
 begin
  j2 := WordPtr(@F_Frame.Index[F_Frame.STP_PatternsPointer])^;
  SetLength(KsaId2,28); move(F_Frame.Index[10],KsaId2[1],28);
  if KsaId2 = KsaId then dec(j2,$a + 53) else dec(j2,$a);
  if j2 < 0 then exit;
  F_Address := j2;
  j3 := (F_Length - F_Frame.STP_PatternsPointer) div 2;
 end;

j := WordPtr(@F_Frame.Index[F_Frame.STP_OrnamentsPointer])^ - 1 - j2;
if Longword(j) <= Longword(Readen1 - 1) then
 begin
  if WordPtr(@F_Frame.Index[j])^ = 0 then
   begin
    if IntegrityCheck then
     try
      New(M);
      try
       if not LoadTrackerModule(M^,-1,j2,F_Length,F_Frame,STPFile) then exit;
       GetTimeSTP(M,TimeLength,LoopPoint);
       if TimeLength = 0 then exit
      finally
       Dispose(M)
      end
     except
      exit
     end;
    if F_Frame.STP_Init_Id = 0 then
     begin
      F_Frame.STP_Init_Id := j3;
      for j1 := 0 to j3-1 do
       Dec(WordPtr(@F_Frame.Index[F_Frame.STP_PatternsPointer + j1 * 2])^,j2)
     end;
    Result := True;
   end
 end;

end;

function FoundPT2(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2,j3,j4:integer;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundPT2 := False;
if Readen1 < 132 then exit;
if F_Frame.PT2_PatternsPointer = 0 then exit;
if F_Frame.PT2_PatternsPointer > Readen1 then exit;
if F_Frame.Index[F_Frame.PT2_PatternsPointer - 1] <> 255 then exit;
j3 := F_Frame.PT2_SamplesPointers[0];
if F_Frame.PT2_OrnamentsPointers[0] - j3 - 2 > Readen1 then exit;
if F_Frame.PT2_OrnamentsPointers[0] - j3 < 0 then exit;

j := 0;
move(F_Frame.Index[F_Frame.PT2_OrnamentsPointers[0] - j3],j,3);
if j <> 1 then exit;

j := WordPtr(@F_Frame.Index[F_Frame.PT2_PatternsPointer])^ - j3;
if (j < 0) or (j > Readen1) then exit;
dec(j,F_Frame.PT2_PatternsPointer);
if (j <= 0) or (j mod 6 <> 2) then exit;

j1 := 0; j2 := 0;
while (j2 < 256) and (j2 <= Readen1 - 131) and
(F_Frame.PT2_PositionList[j2] < 128) do
 begin
  if longword(j1) < F_Frame.PT2_PositionList[j2] then
   j1 := F_Frame.PT2_PositionList[j2];
  inc(j2)
 end;
if j div 6 <> j1 + 1 then exit;

j := 15;
while (j > 0) and (F_Frame.PT2_OrnamentsPointers[j] = j3) do dec(j);
j4 := F_Frame.PT2_OrnamentsPointers[j] - j3;
if (j4 < 0) or ((j4 - 2) > Readen1) then exit;
F_Length := j4 + F_Frame.Index[j4] + 2;
if F_Length > Readen1 + 1 then exit;

for j := 0 to 31 do
 begin
  j4 := F_Frame.PT2_SamplesPointers[j] - j3;
  if (j4 < 0) or ((j4 - 2) > Readen1) then exit
 end;
for j := 0 to 15 do
 begin
  j4 := F_Frame.PT2_OrnamentsPointers[j] - j3;
  if (j4 < 0) or ((j4 - 2) > Readen1) then exit
 end;
for j := 0 to j1 * 3 + 2 do
 begin
  j4 := F_Frame.PT2_PatternsPointer + j*2; if j4 > Readen1 then exit;
  j4 := WordPtr(@F_Frame.Index[j4])^ - j3; if (j4 < 0) or (j4 > Readen1) then exit
 end;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,j3,F_Length,F_Frame,PT2File) then exit;
   GetTimePT2(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;
F_Frame.PT2_NumberOfPositions := j2;
if j3 <> 0 then
 begin
  F_Address := j3;
  for j := 0 to 31 do dec(F_Frame.PT2_SamplesPointers[j],j3);
  for j := 0 to 15 do dec(F_Frame.PT2_OrnamentsPointers[j],j3);
  for j := 0 to j1 * 3 + 2 do dec(WordPtr(@F_Frame.Index[F_Frame.PT2_PatternsPointer + j*2])^,j3)
 end;
FoundPT2 := True
end;

function FoundPT3(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2,j3,j4,j5,j6,adr:integer;
 pw:WordPtr;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundPT3 := False;
if Readen1 < 202 then exit;
adr := F_Frame.PT3_SamplesPointers[0];
j4 := F_Frame.PT3_PatternsPointer - adr; if (j4 < 202) or (j4 > Readen1) then exit;
if F_Frame.Index[j4 - 1] <> 255 then exit;
j := F_Frame.PT3_OrnamentsPointers[0] - adr; if (j < 202) or (j + 2 > Readen1) then exit;

move(F_Frame.Index[j],j,3); if j <> 256 then exit;

j5 := 0;
j1 := 0;
while j5 < 256 do
 begin
  if j5 + 201 > Readen1 then exit;
  j2 := F_Frame.PT3_PositionList[j5]; if j2 = 255 then break;
  if j2 mod 3 <> 0 then exit;
  if j1 < j2 then j1 := j2;
  inc(j5)
 end;

pw := @F_Frame.Index[j4];
j3 := integer(F_Frame) + Readen1;
j := 65535;
for j2 := 0 to j1 + 2 do
 begin
  if integer(pw) >= j3 then exit;
  j6 := pw^ - adr; if (j6 < 202) or (j6 > Readen1) then exit;
  if j > j6 then j := j6;
  inc(integer(pw),2);
 end;

dec(j,j4); if j <= 0 then exit;
if j  mod 6 <> 0 then exit;
if j div 6 <> j1 div 3 + 1 then exit;

j := 15;
while (j > 0) and (F_Frame.PT3_OrnamentsPointers[j] = adr) do dec(j);
j := F_Frame.PT3_OrnamentsPointers[j] - adr; if (j < 202) or (j + 2 > Readen1) then exit;

F_Length := j + F_Frame.Index[j + 1] + 2;
if F_Length > Readen1 + 1 then exit;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,adr,F_Length,F_Frame,PT3File) then exit;
   GetTimePT3(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;

F_Frame.PT3_NumberOfPositions := j5;
F_Address := adr;
F_Frame.PT3_PatternsPointer := j4;
for j := 0 to 31 do Dec(F_Frame.PT3_SamplesPointers[j],adr);
for j := 0 to 15 do Dec(F_Frame.PT3_OrnamentsPointers[j],adr);
pw := @F_Frame.Index[j4];
for j := 0 to j1 + 2 do
 begin
  Dec(pw^,adr);
  Inc(integer(pw),2)
 end;
FoundPT3 := True
end;

function FoundPSC(PSC1_00:boolean;IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2:integer;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundPSC := False;
if Readen1 < $4c + 2 then exit;
if F_Frame.PSC_OrnamentsPointer >= Readen1 then exit;
if F_Frame.PSC_OrnamentsPointer < $4c + 2 then exit;
if F_Frame.PSC_OrnamentsPointer > 64 + $4c then exit;
if F_Frame.PSC_OrnamentsPointer mod 2 <> 0 then exit;
j2 := 0; if not PSC1_00 then j2 := $4c;
j := j2 + F_Frame.PSC_SamplesPointers[0];
if j > 65534 - 5 then exit;
if j + 5 > Readen1 then exit;

j := WordPtr(@F_Frame.Index[F_Frame.PSC_OrnamentsPointer])^;
if not PSC1_00 then inc(j,F_Frame.PSC_OrnamentsPointer);
if j > 65535 then exit;
if j >= Readen1 then exit;

j1 := WordPtr(@F_Frame.Index[F_Frame.PSC_OrnamentsPointer-2])^;
if not PSC1_00 then inc(j1,$4c);
if j1 > 65535 then exit;
if j1 >= Readen1 then exit;
if j-j1 < 8 then exit;
if (j-j1) mod 6 <> 2 then exit;

j1 := F_Frame.PSC_SamplesPointers[0] + 4;
if not PSC1_00 then inc(j1,$4c);
while (j1 < 65536) and (j1 <= readen1) and (F_Frame.Index[j1] and 32 <> 0) do
 inc(j1,6);
if j1 > 65534 then exit;
if j1 > readen1 then exit;

if F_Frame.PSC_OrnamentsPointer - $4c - 2 > 0 then
 begin
  if j1 + 3 <> F_Frame.PSC_SamplesPointers[1] + j2 then exit;
 end
else if j1 + 4 <> j then exit;

j := F_Frame.PSC_PatternsPointer + 11;
if (j > 65535) or (j >= Readen1) then exit;

dec(j,10); if F_Frame.Index[j] = 255 then exit;

repeat
 inc(j,8);
until (j > 65532) and (j+2 > Readen1) or (F_Frame.Index[j] = 255);
if j > 65532 then exit;
if j+2 > Readen1 then exit;
F_Length := j + 3;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,0,F_Length,F_Frame,PSCFile) then exit;
   GetTimePSC(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;

if PSC1_00 then
 begin
  if not (F_Frame.PSC_MusicName[8] in ['0'..'3']) then
   F_Frame.PSC_MusicName[8] := '0'
 end
else if F_Frame.PSC_MusicName[8] in ['0'..'3'] then
 F_Frame.PSC_MusicName[8] := '7';

FoundPSC := True
end;

function FoundFTC(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2,j3,maxpat,address:integer;
 jj:^word;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundFTC := false;
if Readen1 < $d4 + 3 then exit;
if F_Frame.FTC_PatternsPointer >= Readen1 then exit;
if F_Frame.FTC_OrnamentsPointers[0] <= F_Frame.FTC_SamplesPointers[0] then exit;

j1 := $d4;
maxpat := 0;
while (j1 <= readen1) and (j1 < $1d4) and (F_Frame.Index[j1] < 128) do
 begin
  if maxpat < F_Frame.Index[j1] then
   maxpat := F_Frame.Index[j1];
  inc(j1,2);
 end;
if j1 >= $1d4 then exit;
if j1 > readen1 then exit;
if F_Frame.FTC_PatternsPointer <= j1 then exit;
if F_Frame.FTC_Loop_Position >= (j1-$d4) div 2 then exit;

address := 0;
move(F_Frame.Index[F_Frame.FTC_PatternsPointer],address,2);
dec(address,(maxpat + 1) * 6 + F_Frame.FTC_PatternsPointer + 2);
if address < 0 then exit;
if F_Frame.FTC_SamplesPointers[0] - address >= Readen1 then exit;
if F_Frame.FTC_PatternsPointer >=
      F_Frame.FTC_SamplesPointers[0] - address then exit;
if F_Frame.FTC_OrnamentsPointers[0] - address >= Readen1 then exit;

j1 := 0;
j := 65535;
for j2 := 0 to 32 do
 begin
  if j > F_Frame.FTC_OrnamentsPointers[j2] then
   j := F_Frame.FTC_OrnamentsPointers[j2];
  if j1 < F_Frame.FTC_OrnamentsPointers[j2] then
   j1 := F_Frame.FTC_OrnamentsPointers[j2]
 end;
if j - address > 65535 then exit;
if j - address >= Readen1 then exit;
if j1 - address > 65533 then exit;
if j1 - address >= Readen1 then exit;

j3 := 0;
for j2 := 0 to 31 do
 begin
  if j3 < F_Frame.FTC_SamplesPointers[j2] then
   j3 := F_Frame.FTC_SamplesPointers[j2]
 end;
if j3 - address <= F_Frame.FTC_PatternsPointer then exit;
if j3 - address > 65533 then exit;
if j3 - address >= Readen1 then exit;
if j3 + 3 + (F_Frame.Index[j3 - address + 2] + 1) * 5 <> j then exit;
F_Length := j1 + 3 + (F_Frame.Index[j1 - address + 2] + 1) * 2 - address;
if F_Length > 65536 then exit;
if F_Length > Readen1 + 1 then exit;
if F_Length < F_Frame.FTC_PatternsPointer then exit;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,address,F_Length,F_Frame,FTCFile) then exit;
   GetTimeFTC(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;

F_Address := address;
for j2 := 0 to 32 do dec(F_Frame.FTC_OrnamentsPointers[j2],address);
for j2 := 0 to 31 do dec(F_Frame.FTC_SamplesPointers[j2],address);

jj := @F_Frame.Index[F_Frame.FTC_PatternsPointer];
for j2 := 1 to (maxpat + 1) * 3 do
 begin
  dec(jj^,address);
  inc(integer(jj),2);
 end;

FoundFTC := True
end;

function FoundSQT(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2,j3:integer;
 pwrd:^word;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundSQT := False;
if Readen1 < 17 then exit;
if F_Frame.SQT_SamplesPointer < 10 then exit;
if F_Frame.SQT_OrnamentsPointer <= F_Frame.SQT_SamplesPointer + 1 then exit;
if F_Frame.SQT_PatternsPointer < F_Frame.SQT_OrnamentsPointer then exit;
if F_Frame.SQT_PositionsPointer <= F_Frame.SQT_PatternsPointer then exit;
if F_Frame.SQT_LoopPointer < F_Frame.SQT_PositionsPointer then exit;

j := F_Frame.SQT_SamplesPointer - 10;
if F_Frame.SQT_LoopPointer - j >= Readen1 then exit;

j1 := F_Frame.SQT_PositionsPointer - j;
if F_Frame.Index[j1] = 0 then exit;
j2 := 0;
while F_Frame.Index[j1] <> 0 do
 begin
  if j1 + 7 >= Readen1 then exit;
  if j2 < F_Frame.Index[j1] and $7f then
   j2 := F_Frame.Index[j1] and $7f;
  inc(j1,2);
  if j2 < F_Frame.Index[j1] and $7f then
   j2 := F_Frame.Index[j1] and $7f;
  inc(j1,2);
  if j2 < F_Frame.Index[j1] and $7f then
   j2 := F_Frame.Index[j1] and $7f;
  inc(j1,3)
 end;

pwrd := @F_Frame.Index[F_Frame.SQT_SamplesPointer - j + 2];
if pwrd^ - F_Frame.SQT_PatternsPointer - 2 <> j2 * 2 then exit;

F_Length := j1 + 7;
pwrd := @F_Frame.Index[12];
j2 := pwrd^;
for j1 := 1 to (F_Frame.SQT_OrnamentsPointer -
                     F_Frame.SQT_SamplesPointer) div 2 do
 begin
  inc(integer(pwrd),2);
  j3 := pwrd^;
  if j3 - j2 <> $62 then exit;
  j2 := j3
 end;

for j1 := 1 to (F_Frame.SQT_PatternsPointer -
                         F_Frame.SQT_OrnamentsPointer) div 2 do
 begin
  inc(integer(pwrd),2);
  j3 := pwrd^;
  if j3 - j2 <> $22 then exit;
  j2 := j3
 end;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,0,F_Length,F_Frame,SQTFile) then exit;
   GetTimeSQT(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;

F_Frame.SQT_Size := F_Length;
FoundSQT := True
end;

function FoundPT1(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2:integer;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundPT1 := False;
if Readen1 < $66 then exit;
if F_Frame.PT1_PatternsPointer >= Readen1 then exit;

j := 0;
j1 := 65535;
for j2 := 0 to 15 do
 begin
  if j < F_Frame.PT1_SamplesPointers[j2] then
   j := F_Frame.PT1_SamplesPointers[j2];
  if (F_Frame.PT1_OrnamentsPointers[j2] <> 0)and
           (j1 > F_Frame.PT1_OrnamentsPointers[j2]) then
   j1 := F_Frame.PT1_OrnamentsPointers[j2]
 end;
if j1 < $67 then exit;
if j < $67 then exit;
if j > 65534 then exit;
if j > Readen1 then exit;
if j + F_Frame.Index[j] * 3 + 2 <> j1 then exit;

j:=0;
for j2 := 0 to 15 do
 if j < F_Frame.PT1_OrnamentsPointers[j2] then
  j := F_Frame.PT1_OrnamentsPointers[j2];
if j < $67 then exit;
F_Length:=j + 64;
if F_Length > 65536 then exit;
if F_Length > Readen1 + 1 then exit;

j := $63;
while (j <= F_Frame.PT1_PatternsPointer) and (F_Frame.Index[j] <> 255) do
 inc(j);
if j + 1 <> F_Frame.PT1_PatternsPointer then exit;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,0,F_Length,F_Frame,PT1File) then exit;
   GetTimePT1(M,TimeLength,LoopPoint);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;

F_Frame.PT1_NumberOfPositions := j-$63;
FoundPT1 := True
end;

function FoundFLS(IntegrityCheck:boolean;var TimeLength,LoopPoint:integer):boolean;
var
 j,j1,j2:integer;
 j3:WordPtr;
 M:PModTypes;
begin
TimeLength := 0;
LoopPoint := 0;
FoundFLS := False;
j := F_Frame.FLS_PositionsPointer - F_Frame.FLS_SamplesPointer;
if (j < 0) or (j and 3 <> 0) then exit;
j := F_Frame.FLS_OrnamentsPointer - 16; if j < 0 then exit;

repeat
 j2 := F_Frame.FLS_SamplesPointer + 2 - j;
 if (j2 >= 8) and (j2 < Readen1) then
  begin
   j3 := @F_Frame.Index[j2];
   j1 := j3^ - j;
   if (j1 >= 8) and (j1 < Readen1) then
    begin
     j3 := @F_Frame.Index[j2 - 4];
     j2 := j3^ - j;
     if (j2 >= 6) and (j2 < Readen1) then
      if j1 - j2 = $20 then
       begin
        j2 := F_Frame.FLS_PatternsPointers[1].PatternB - j;
        if (j2 > 21) and (j2 < Readen1) then
         begin
          j1 := F_Frame.FLS_PatternsPointers[1].PatternA - j;
          if (j1 > 20) and (j1 < Readen1) then
           if F_Frame.Index[j1 - 1] = 0 then
            begin
             while (j1 <= Readen1) and (F_Frame.Index[j1] <> 255) do
              begin
               repeat
                case F_Frame.Index[j1] of
                0..$5f,$80,$81:
                   begin
                    inc(j1);
                    break
                   end;
                $82..$8e:
                   begin
                    inc(j1)
                   end;
                end;
                inc(j1);
               until j1 > Readen1;
              end;
             if j1 + 1 = j2 then break;
            end;
         end;
       end;
    end;
  end;
 dec(j);
until j = -1;
if j < 0 then exit;

F_Length := 0;
if F_Frame.FLS_PositionsPointer - j > Readen1 then exit;
if F_Frame.FLS_PositionsPointer - j < 16 then exit;
F_Length := WordPtr(@F_Frame.Index[F_Frame.FLS_PositionsPointer - j - 2])^ + $60 - j;
if F_Length <= F_Frame.FLS_PositionsPointer - j then exit;
if F_Length > Readen1 + 1 then exit;
if (F_Frame.FLS_SamplesPointer - j) and 1 <> 0 then exit;

if IntegrityCheck then
 try
  New(M);
  try
   if not LoadTrackerModule(M^,-1,j,F_Length,F_Frame,FLSFile) then exit;
   GetTimeFLS(M,TimeLength);
   if TimeLength = 0 then exit
  finally
   Dispose(M)
  end
 except
  exit
 end;
F_Address := j;
FoundFLS := True
end;

procedure AddCDTrack(CDN,TN:integer;Inited:boolean);
var
 s:string;
 PLItem:PPlayListItem;
begin
if not Inited then InitCDDevice(CDN);
try
     if IsAudioTrack(CDN,TN) then
      begin
{       PLItem := TPLItem.Create;
       PLItem.Drive := i;
       PLItem.Track := j;}
       s := CDDrives[CDN] + ':\Track';
       if TN < 10 then s := s + '0';
       s := s + IntToStr(TN) + '.cda';

//       t := CDGetTrackLength(i,j);

{       n := PlayList.Items.Add(s);
       PlayList.Items.Objects[n] := PLItem}

  {n := }AddPlayListItem(PLItem);
{  Song_Author := Trim(Song_Author);
  Song_Name := Trim(Song_Name);
  PrgName := Trim(PrgName);
  TrackName := Trim(TrackName);
  ComStr := Trim(ComStr);}
  with PLItem^ do
   begin
    Author := '';
    Title := '';
    Programm := '';
    Tracker := '';
    Comment := '';
    Date := '';
    FileName := s;
    Offset := TN;
    Address := CDN;
    Length := 0;
    FileType := CDAFile;
    UnpackedSize := 0;
    Loop := -1;
    Ay_Freq := -1;
    Int_Freq := -1;
    Channel_Mode := -1;
    Chip_Type := No_Chip;
    Number_Of_Channels := 0;
    Time := {t}0;
    Error := FileNoError;
    FormatSpec := 0{FormSpec};
    Selected := False
   end;

      end
finally
 if not Inited then CloseCDDevice(CDN);
end; 

end;

procedure Add_Songs_From_File(File_Name:string;Detect:boolean);
type
 PTRDFile = ^TTRDFile;
 TTRDFile = packed record
  Name:array[0..10]of char;
  Len:word;
  A:packed record case boolean of
  False:(SecLen,Sec,Trc:byte);
  True:(SecLenH,ChSumH:word);
  end;
 end;
var
 ImageCatalog:array of record
  Name:string;
  Offset,Size:integer;
 end;
 Zag:array[0..3]of char;
 LHZag:array[0..4] of char;
 F_Offset:integer;
 FType:Available_Types;
 FTime,FLoop:integer;
 F_Buffer:array[0..65536*2-1]of byte;
 F_Index,FilSiz,F_Point:integer;
 Start_Time:dword;
 SFileExt,SFileName,SFilePath:string;
 PLItem:PPlayListItem;
 Loaded:boolean;
 URHandle:integer;

 function AddTRDName(i,sz,offs:integer):boolean;
 begin
 Result := False;
 with PTRDFile(@F_Buffer[65536 + i * sz + offs])^ do
  begin
   if Name[0] = #0 then
    begin
     SetLength(ImageCatalog,i);
     exit
    end
   else if Name[0] = #1 then
    ImageCatalog[i].Name := 'Erased_' + Trim(Copy(Name,1,7))
   else
    ImageCatalog[i].Name := Trim(Copy(Name,0,8));
   ImageCatalog[i].Name := ImageCatalog[i].Name + '.' + Name[8];
   if (Name[9] in [#33..#127]) and (Name[10] in [#32..#127]) then
    begin
     ImageCatalog[i].Name := ImageCatalog[i].Name + Name[9];
     if Name[10] <> ' ' then
      ImageCatalog[i].Name := ImageCatalog[i].Name + Name[10];
    end;
   if sz = 0 then
    ImageCatalog[i].Size := A.SecLenH
   else
    ImageCatalog[i].Size := A.SecLen * 256;
   if sz = 16 then ImageCatalog[i].Offset := (A.Sec + A.Trc * 16) * 256
  end;
 Result := True;
 end;

 procedure Init_Detector;
 var
  i,n:integer;
 begin
  Loaded := True;
  Seek(UniReadersData[URHandle].UniFile,0);
  F_Offset := -1;
  F_Index := 65535;
  FilSiz := UniReadersData[URHandle].UniFileSize - 1;
  PrgBox:=false;
  BlockRead(UniReadersData[URHandle].UniFile,F_Buffer[65536],65536,Readen1);
  May_Quit := False;
  F_Point := 1024;
  if (SFileExt = '.trd') and (UniReadersData[URHandle].UniFileSize > 4096) and
     (UniReadersData[URHandle].UniFileSize mod 256 = 0) and
     {(F_Buffer[65536 + 8*256] = 0) and} (F_Buffer[65536 + 8*256 + $e7] = 16) then
   begin
    SetLength(ImageCatalog,128);
    for i := 0 to 127 do
     if not AddTRDName(i,16,0) then break;
   end
  else if (SFileExt = '.scl') and (UniReadersData[URHandle].UniFileSize > 13) and
   (PInt64(@F_Buffer[65536])^ = $5249414c434e4953) and (F_Buffer[65536 + 8] <> 0) and
   (UniReadersData[URHandle].UniFileSize > F_Buffer[65536 + 8] * 14 + 13) then
   begin
    SetLength(ImageCatalog,F_Buffer[65536 + 8]);
    n := 9 + F_Buffer[65536 + 8] * 14;
    for i := 0 to F_Buffer[65536 + 8] - 1 do
     begin
      if not AddTRDName(i,14,9) then break;
      ImageCatalog[i].Offset := n;
      inc(n,PTRDFile(@F_Buffer[65536 + i * 14 + 9])^.A.SecLen * 256)
     end
   end
  else if (Length(SFileExt) > 2) and (SFileExt[2] in ['!','$']) and
   (UniReadersData[URHandle].UniFileSize > 17) then
   begin
    n := 0; for i := 0 to 14 do Inc(n,F_Buffer[65536 + i]);
    if PTRDFile(@F_Buffer[65536])^.A.ChSumH = word(n * 257 + 105) then
     begin
      SetLength(ImageCatalog,1);
      if AddTRDName(0,0,0) then ImageCatalog[0].Offset := 17
     end;
   end;
  Start_Time := GetTickCount
 end;

 function Module_Detector:boolean;
 var
  Readen2:integer;
 begin
  Module_Detector := False;
  repeat
   inc(F_Offset);
   inc(F_Index);
   dec(Readen1);
   if F_Offset >= FilSiz then
    begin
    if PrgBox then Form4.Free;
    exit
    end;
   if F_Index >= 65536 then
    begin
     move(F_Buffer[65536],F_Buffer,65536);
     dec(F_Index,65536);
     BlockRead(UniReadersData[URHandle].UniFile,F_Buffer[65536],65536,Readen2);
     inc(Readen1,Readen2);
    end;
   Integer(F_Frame) := integer(@F_Buffer) + F_Index;
   FTime := 0; FLoop := 0; F_Address := 0;
   if FoundST(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := STCFile;
     exit
    end
   else if FoundASC1(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := ASCFile;
     exit
    end
   else if FoundASC0(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := ASC0File;
     exit
    end
   else if FoundSTP(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := STPFile;
     exit
    end
   else if FoundPT2(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := PT2File;
     exit
    end
   else if FoundPT3(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := PT3File;
     exit
    end
   else if FoundPSC(False,True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := PSCFile;
     exit
    end
   else if FoundPSC(True,True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := PSCFile;
     exit
    end
   else if FoundFTC(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := FTCFile;
     exit
    end
   else if FoundPT1(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := PT1File;
     exit
    end
   else if FoundGTR(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := GTRFile;
     exit
    end
   else if FoundSQT(True,FTime,FLoop) then
    begin
     Module_Detector := True;
     FType := SQTFile;
     exit
    end;
   if F_Offset > F_Point then
    begin
     if not PrgBox then
     if GetTickCount - Start_Time > 2000 then
     begin
     Form4:=TForm4.Create(Form1);
     PrgBox:=true;
     if not Russian_Interface then
     begin
      Form4.Caption:='Searching for tunes';
      Form4.Button1.Caption:='Cancel';
    end;
    Form4.ProgressBar1.Max:=FilSiz+1;
      end;
     if PrgBox then Form4.ProgressBar1.Position:=F_Offset+1;
      NewMessageSkipper;
     F_Point := F_Offset + 1024
    end;
  until May_Quit or (F_Offset >= FilSiz);
  if PrgBox then Form4.Free;
 end;

procedure OpenAYMFile;
var
 i,j:integer;
 AYMFileHeader:TAYMFileHeader;
begin
UniRead(URHandle,@AYMFileHeader,SizeOf(AYMFileHeader));
if AYMFileHeader.AYM <> 'AYM' then exit;
if AYMFileHeader.Rev <> '0' then exit;
for j := 0 to AYMFileHeader.MusMax - AYMFileHeader.MusMin do
 begin
  i := AddPlayListItem(PLItem);
  with PLItem^ do
   begin
     Author := Trim(AYMFileHeader.Author);
     Title := Trim(AYMFileHeader.Name);
     Programm := '';
     Tracker := '';
     Comment := '';
     Date := '';
     FileName := File_Name;
     FormatSpec := j;
     Address := 0;
     Offset := 0;
     Length := 0;
     FileType := AYMFile;
     UnpackedSize := 0;
     Loop := 0;
     Ay_Freq := -1;
     Int_Freq := -1;
     Channel_Mode := -1;
     Chip_Type := No_Chip;
     Number_Of_Channels := 0;
     Time := 15000;
     Error := FileNoError;
     Selected := False
   end;
  RedrawItem(0,i);
  CalculatePlaylistScrollBar
 end
end;

procedure OpenAYFile;
var
 i,j,CurPos:integer;
 Ch:char;
 Byt:byte;
 Wrd:word;
 AuthorString,MiscString,SongName:string;
 AYFileHeader:TAYFileHeader;
 SongStructure:TSongStructure;
begin
UniRead(URHandle,@AYFileHeader,SizeOf(AYFileHeader));
if AYFileHeader.FileID <> $5941585A then exit;
if (AYFileHeader.TypeID <> $4C554D45) and
   (AYFileHeader.TypeID <> $44414D41) then exit;

UniFileSeek(URHandle,SmallInt(IntelWord(AYFileHeader.PAuthor)) + 12);
AuthorString := '';
repeat
 UniRead(URHandle,@Ch,1);
 if Ch <> #0 then AuthorString := AuthorString + Ch;
until Ch = #0;
AuthorString := Trim(AuthorString);

UniFileSeek(URHandle,SmallInt(IntelWord(AYFileHeader.PMisc)) + 14);
MiscString := '';
repeat
 UniRead(URHandle,@Ch,1);
 if Ch <> #0 then MiscString := MiscString + Ch;
until Ch = #0;
MiscString := Trim(MiscString);

UniFileSeek(URHandle,SmallInt(IntelWord(AYFileHeader.PSongsStructure)) + 18);
for j := 0 to AYFileHeader.NumOfSongs do
 begin
  UniRead(URHandle,@SongStructure,4);
  CurPos := UniReadersData[URHandle].UniFilePos;

  UniFileSeek(URHandle,SmallInt(IntelWord(SongStructure.PSongName)) + CurPos - 4);
  SongName := '';
  repeat
   UniRead(URHandle,@Ch,1);
   if Ch <> #0 then SongName := SongName + Ch;
  until Ch = #0;
  SongName := Trim(SongName);
  i := AddPlayListItem(PLItem);
  with PLItem^ do
   begin
     Author := AuthorString;
     Title := SongName;
     Programm := '';
     Tracker := '';
     Comment := MiscString;
     Date := '';
     FileName := File_Name;
     if AYFileHeader.TypeID = $4C554D45 then
      begin
       Offset := SmallInt(IntelWord(SongStructure.PSongData)) + CurPos - 2;
       Address := 0;
       FileType := AYFile;
       UniFileSeek(URHandle,SmallInt(IntelWord(SongStructure.PSongData)) + CurPos + 2);
       UniRead(URHandle,@Wrd,2);
       if Wrd <> 0 then
        Time := IntelWord(Wrd)
       else
        Time := 15000
      end
     else
      begin
       Offset := SmallInt(IntelWord(SongStructure.PSongData)) + CurPos - 2;
       UniFileSeek(URHandle,Offset);
       UniRead(URHandle,@Wrd,2);
       Address := IntelWord(Wrd);
       UniRead(URHandle,@Byt,1);
       FormatSpec := Byt;
       UniRead(URHandle,@Byt,1);
       UniRead(URHandle,@Wrd,2);
       Time := Byt * IntelWord(Wrd);
       inc(Offset,14 - 6);
       FileType := FXMFile
      end;
     Length := 0;
     UnpackedSize := 0;
     Loop := 0;
     Ay_Freq := -1;
     Int_Freq := -1;
     Channel_Mode := -1;
     Chip_Type := No_Chip;
     Number_Of_Channels := 0;
     Error := FileNoError;
     Selected := False
   end;
  RedrawItem(0,i);
  CalculatePlaylistScrollBar;
  UniFileSeek(URHandle,CurPos)
 end
end;

 function Add(FType:Available_Types;TimLen,Looping_VBL:integer):integer;
 var
  i,j,k,l:integer;
  KsaId2:string;
  Song_Name,Song_Author,PrgName,TrackName,CompName,DateStr,ComStr:string;
  ChipFrq,PlrFrq,ChanMode:integer;
  ChType:ChTypes;
  Ster:integer;
  Ch:char;
  Wrd:word;
  DWrd:dword;
  FormSpec:integer;
  orisize:integer;
  VTXFileHeader:TVTXFileHeader;
  LZHFileHeader:TLZHFileHeader;
  YM5FileHeader:TYM5FileHeader;
 begin
  Result := -1;
  orisize := 0;
  Song_Name := '';Song_Author := '';
  PrgName := '';TrackName := '';CompName := '';
  DateStr := '';ComStr := '';
  ChipFrq := -1;
  PlrFrq := -1;
  ChanMode := -1;
  ChType := No_Chip;
  Ster := 0;
  FormSpec := -1;

  case FType of
  STCFile:  begin
             SetLength(KsaId2,20);
             if not Loaded then
              begin
               UniFileSeek(URHandle,7);
               UniRead(URHandle,@KsaId2[1],20)
              end
             else
              Move(F_Frame.ST_Name,KsaId2[1],20);
             Song_Name := Copy(KsaId2,1,18);
             if (Song_Name='SONG BY ST COMPILE') or
                (Song_Name='SONG BY MB COMPILE') or
                (Song_Name='SONG BY ST-COMPILE') or
                (Song_Name='SOUND TRACKER v1.1') or
                (Song_Name='S.T.FULL EDITION  ') or
                (Song_Name='SOUND TRACKER v1.3') then
              Song_Name := ''
             else
              begin
               Wrd := WordPtr(@KsaId2[19])^;
               if Wrd <> F_Length then
                if KsaId2[19] in [' '..#127] then
                 begin
                  Song_Name := Song_Name + KsaId2[19];
                  if KsaId2[20] in [' '..#127] then
                   Song_Name := Song_Name + KsaId2[20]
                 end
              end
            end;
  GTRFIle:  begin
             SetLength(Song_Name,32);
             if not Loaded then
              begin
               UniFileSeek(URHandle,7);
               UniRead(URHandle,@Song_Name[1],32)
              end
             else
              Move(F_Frame.GTR_Name,Song_Name[1],32)
            end;
  PSCFile:  begin
             SetLength(Song_Name,20);
             SetLength(Song_Author,20);
             if not Loaded then
              begin
               UniFileSeek(URHandle,$19);
               UniRead(URHandle,@Song_Name[1],20);
               UniFileSeek(URHandle,$31);
               UniRead(URHandle,@Song_Author[1],20);
              end
             else
              begin
               Move(F_Frame.PSC_MusicName[$19],Song_Name[1],20);
               Move(F_Frame.PSC_MusicName[$31],Song_Author[1],20);
              end
            end;
  FTCFile:  begin
             SetLength(Song_Name,42);
             if not Loaded then
              begin
               UniFileSeek(URHandle,8);
               UniRead(URHandle,@Song_Name[1],42)
              end
             else
              Move(F_Frame.FTC_MusicName[8],Song_Name[1],42)
            end;
  PT1File:  begin
             SetLength(Song_Name,30);
             if not Loaded then
              begin
               UniFileSeek(URHandle,69);
               UniRead(URHandle,@Song_Name[1],30)
              end
             else
              Move(F_Frame.PT1_MusicName,Song_Name[1],30)
            end;
  PT2File:  begin
             SetLength(Song_Name,30);
             if not Loaded then
              begin
               UniFileSeek(URHandle,101);
               UniRead(URHandle,@Song_Name[1],30)
              end
             else
              Move(F_Frame.PT2_MusicName,Song_Name[1],30)
            end;
  PT3File:  begin
             SetLength(Song_Name,32);
             SetLength(Song_Author,32);
             if not Loaded then
              begin
               UniFileSeek(URHandle,$1E);
               UniRead(URHandle,@Song_Name[1],32);
               UniFileSeek(URHandle,$42);
               UniRead(URHandle,@Song_Author[1],32);
              end
             else
              begin
               Move(F_Frame.PT3_MusicName[$1E],Song_Name[1],32);
               Move(F_Frame.PT3_MusicName[$42],Song_Author[1],32);
              end
            end;
  ASCFile:  begin
             if not Loaded then
              begin
               UniFileSeek(URHandle,2);
               UniRead(URHandle,@F_Frame.ASC1_PatternsPointers,2);
               UniFileSeek(URHandle,8);
               UniRead(URHandle,@F_Frame.ASC1_Number_Of_Positions,1);
              end;
             if F_Frame.ASC1_PatternsPointers -
                          F_Frame.ASC1_Number_Of_Positions = 72 then
              begin
               SetLength(Song_Name,20);
               SetLength(Song_Author,20);
               if not Loaded then
                begin
                 UniFileSeek(URHandle,F_Frame.ASC1_PatternsPointers - 44);
                 UniRead(URHandle,@Song_Name[1],20);
                 UniFileSeek(URHandle,F_Frame.ASC1_PatternsPointers - 20);
                 UniRead(URHandle,@Song_Author[1],20);
                end
               else
                begin
                 Move(F_Frame.Index[F_Frame.ASC1_PatternsPointers - 44],
                        Song_Name[1],20);
                 Move(F_Frame.Index[F_Frame.ASC1_PatternsPointers - 20],
                        Song_Author[1],20);
                end
              end
            end;
  STPFile:  begin
             SetLength(KsaId2,28);
             if not Loaded then
              begin
               UniFileSeek(URHandle,10);
               UniRead(URHandle,@KsaId2[1],28)
              end
             else
              Move(F_Frame.Index[10],KsaId2[1],28);
             if KsaId2 = KsaId then
              begin
               SetLength(Song_Name,25);
               if not Loaded then
                UniRead(URHandle,@Song_Name[1],25)
               else
                Move(F_Frame.Index[38],Song_Name[1],25)
              end
            end;
  PSMFile:  begin
             if not Loaded then
              UniRead(URHandle,@Wrd,2)
             else
              Wrd := F_Frame.PSM_PositionsPointer;
             if Wrd > 8 then
              begin
               Dec(Wrd,8);
               SetLength(KsaId2,Wrd);
               if not Loaded then
                begin
                 UniFileSeek(URHandle,8);
                 UniRead(URHandle,@KsaId2[1],Wrd)
                end
               else
                Move(F_Frame.PSM_Remark,KsaId2[1],Wrd);
               if KsaId2 <> 'psm1'#0 then
                if (Wrd <= 5) or (Copy(KsaId2,1,5) <> 'psm1'#0) then
                 Song_Name := KsaId2
                else
                 Song_Name := Copy(KsaId2,6,Wrd - 5)
              end;
            end;
  VTXFile:  begin
             UniFileSeek(URHandle,0);
             UniRead(URHandle,@VTXFileHeader,2);
             if (VTXFileHeader.Id <> $5941)and
                (VTXFileHeader.Id <> $4d59)and
                (VTXFileHeader.Id <> $7961)and
                (VTXFileHeader.Id <> $6d79) then exit;
             if (VTXFileHeader.Id = $5941) or (VTXFileHeader.Id = $4d59) then
              begin
               UniRead(URHandle,@VTXFileHeader.Mode,8);
               UniRead(URHandle,@VTXFileHeader.UnpackSize,4);
              end
             else
              UniRead(URHandle,@VTXFileHeader.Mode,sizeof(VTXFileHeader) - 2);
             Looping_VBL := VTXFileHeader.Loop;
             PlrFrq := VTXFileHeader.InterFrq * 1000;
             ChipFrq := VTXFileHeader.ChipFrq;
             ChanMode := VTXFileHeader.Mode and 7;
             orisize := VTXFileHeader.UnpackSize;
             TimLen := VTXFileHeader.UnpackSize div 14;
             if VTXFileHeader.Mode = 0 then Ster := 1 else Ster := 2;
             if (VTXFileHeader.Id = $7961) or (VTXFileHeader.Id = $5941) then
              ChType := AY_Chip
             else
              ChType := YM_Chip;
             repeat
              UniRead(URHandle,@Ch,1);
              if Ch <> #0 then Song_Name := Song_Name + Ch
             until Ch = #0;
             repeat
              UniRead(URHandle,@Ch,1);
              if Ch <> #0 then Song_Author := Song_Author + Ch
             until Ch = #0;
             if (VTXFileHeader.Id = $7961) or (VTXFileHeader.Id = $6d79) then
              begin
               if VTXFileHeader.Year <> 0 then
                DateStr := IntToStr(VTXFileHeader.Year);
               repeat
                UniRead(URHandle,@Ch,1);
                if Ch <> #0 then PrgName := PrgName + Ch
               until Ch = #0;
               repeat
                UniRead(URHandle,@Ch,1);
                if Ch <> #0 then TrackName := TrackName + Ch
               until Ch = #0;
               repeat
                UniRead(URHandle,@Ch,1);
                if Ch <> #0 then ComStr := ComStr + Ch
               until Ch = #0
              end;
             F_Offset := UniReadersData[URHandle].UniFilePos;
             F_Length := UniReadersData[URHandle].UniFileSize - F_Offset
            end;
  YM3File:  begin
             UniFileSeek(URHandle,0);
             UniRead(URHandle,@LZHFileHeader,15);
             if LZHFileHeader.Method = '-lh5-' then
              begin
               orisize := LZHFileHeader.UCompSize;
               Original_Size := orisize;
               F_Length := LZHFileHeader.CompSize;
               Compressed_Size := F_Length;
               F_Offset := LZHFileHeader.HSize + 2;
               UniFileSeek(URHandle,F_Offset);
               UniAddDepacker(URHandle,UDLZH)
              end
             else
              begin
               orisize := UniReadersData[URHandle].UniFileSize;
               F_Offset := 0;
               UniFileSeek(URHandle,0)
              end;
             UniRead(URHandle,@YM5FileHeader,4);
             case YM5FileHeader.Id of
             $62334d59:
               begin
                FType := YM3bFile;
                TimLen := (orisize - 8) div 14;
               end;
             $21334d59,
             $21324d59:
               begin
                if YM5FileHeader.Id = $21324d59 then
                 FType := YM2File;
                TimLen := (orisize - 4) div 14;
                Looping_VBL := 0;
               end;
             $21354d59,
             $21364d59:
               begin
                if YM5FileHeader.Id = $21354d59 then
                 FType := YM5File
                else
                 FType := YM6File;
                if orisize < sizeof(TYM5FileHeader) then exit;
                UniRead(URHandle,@YM5FileHeader.Leo,sizeof(TYM5FileHeader) - 4);
                TimLen := IntelDWord(YM5FileHeader.Num_of_tiks);
                l := orisize - TimLen * 16;
                if l < sizeof(TYM5FileHeader) then exit;
                ChipFrq := IntelDWord(YM5FileHeader.ChipFrq);
                PlrFrq := IntelWord(YM5FileHeader.InterFrq) * 1000;
                Looping_VBL := IntelDWord(YM5FileHeader.Loop);
                k := IntelWord(YM5FileHeader.Add_Size) + sizeof(TYM5FileHeader);
                if k + 3 > l then exit;
                for i := 34 + 1 to k do
                 UniRead(URHandle,@DWrd,1);
                for i := 1 to IntelWord(YM5FileHeader.Num_of_Dig) do
                 begin
                  if k + 4 > l then exit;
                  UniRead(URHandle,@DWrd,4);
                  DWrd := IntelDWord(DWrd);
                  inc(k,4 + DWrd); if k > l then exit;
                  for j := 0 to DWrd - 1 do
                   UniRead(URHandle,@DWrd,1)
                 end;
                repeat
                 inc(k); if k > l then exit;
                 UniRead(URHandle,@Ch,1);
                 if Ch <> #0 then Song_Name := Song_Name + Ch
                until Ch = #0;
                repeat
                 inc(k); if k > l then exit;
                 UniRead(URHandle,@Ch,1);
                 if Ch <> #0 then Song_Author := Song_Author + Ch
                until Ch = #0;
                repeat
                 inc(k); if k > l then exit;
                 UniRead(URHandle,@Ch,1);
                 if Ch <> #0 then ComStr := ComStr + Ch
                until Ch = #0;
                FormSpec := k
               end
             else exit
             end
            end;
  PSGFile:  begin
             UniFileSeek(URHandle,0);
             UniRead(URHandle,@zag,4);
             if zag = 'PSG'#26 then
              begin
               UniRead(URHandle,@zag,2);
               if byte(zag[0]) > 10 then exit;
               if byte(zag[0]) = 10 then
                PlrFrq := byte(zag[1]) * 1000
              end
             else if zag = 'EPSG' then
              begin
               UniRead(URHandle,@zag,2);
               if (zag[0] <> #26) then exit;
               case zag[1] of
               #0:  FormSpec := 70908;
               #1:  FormSpec := 71680;
               #255:UniRead(URHandle,@FormSpec,4)
               else exit
               end;
               FType := EPSGFile
              end
            end;
  FXMFile:  begin
             UniFileSeek(URHandle,4);
             UniRead(URHandle,@Wrd,2);
             F_Address := Wrd;
             FormSpec := 31
            end
  end;
  Result := AddPlayListItem(PLItem);
  Song_Author := Trim(Song_Author);
  Song_Name := Trim(Song_Name);
  PrgName := Trim(PrgName);
  TrackName := Trim(TrackName);
  ComStr := Trim(ComStr);
  with PLItem^ do
   begin
    Author := Song_Author;
    Title := Song_Name;
    Programm := PrgName;
    Tracker := TrackName;
    Comment := ComStr;
    Date := DateStr;
    FileName := File_Name;
    Offset := F_Offset;
    Address := F_Address;
    Length := F_Length;
    FileType := FType;
    UnpackedSize := orisize;
    Loop := Looping_VBL;
    Ay_Freq := ChipFrq;
    Int_Freq := PlrFrq;
    Channel_Mode := ChanMode;
    Chip_Type := ChType;
    Number_Of_Channels := Ster;
    Time := TimLen;
    Error := FileNoError;
    FormatSpec := FormSpec;
    Selected := False
   end;
  RedrawItem(0,Result);
  CalculatePlaylistScrollBar
 end;

 procedure AddBASS(FType:Available_Types);
 var
  i:integer;
 begin
  i := AddPlayListItem(PLItem);
{  Song_Author := Trim(Song_Author);
  Song_Name := Trim(Song_Name);
  PrgName := Trim(PrgName);
  TrackName := Trim(TrackName);
  ComStr := Trim(ComStr);}
  with PLItem^ do
   begin
    Author := '';//Song_Author;
    Title := '';//Song_Name;
    Programm := '';//PrgName;
    Tracker := '';//TrackName;
    Comment := '';//ComStr;
    Date := '';//DateStr;
    FileName := File_Name;
    Offset := 0;//F_Offset;
    Address := 0;//F_Address;
    Length := 0;//F_Length;
    FileType := FType;
    UnpackedSize := 0;//orisize;
    Loop := -1;//Looping_VBL;
    Ay_Freq := -1;//ChipFrq;
    Int_Freq := -1;//PlrFrq;
    Channel_Mode := -1;//ChanMode;
    Chip_Type := No_Chip;
    Number_Of_Channels := 0;//Ster;
    Time := 0;//TimLen;
    Error := FileNoError;
    FormatSpec := -1;//FormSpec;
    Selected := False
   end;
  RedrawItem(0,i);
  CalculatePlaylistScrollBar
 end;

 procedure AddCD;
 type
  TCDA = packed record
   rID:array[0..3] of char;
   rLen:DWORD;
   CDAID:array[0..3] of char;
   fID:array[0..3] of char;
   fLen:DWORD;
   Version,TrackNum:word;
   SerNum,BegTime,LenTime:integer;
   end;
 var
  i,j,DriveNum,TrackNum:integer;
  D:string;
  f:file of TCDA;
  CDA:TCDA;
  FormSpec,TimLen:integer;
  Flg:boolean;
 begin
  if Length(CDDrives) = 0 then exit;
  try
   D := UpperCase(ExtractFileDrive(File_Name));
   if Length(D) = 0 then D := CDDrives[0];
   DriveNum := 0;
   for j := 0 to Length(CDDrives) - 1 do
    if CDDrives[j] = D[1] then
     begin
      DriveNum := j;
      break
     end;
    FormSpec := -1;
    TimLen := 0;
    Flg := False;
    if FileExists(File_Name) then
    begin
    AssignFile(f,File_Name);
    Reset(f);
    Read(f,CDA);
    CloseFile(f);
    if (CDA.rID = 'RIFF') and
       (CDA.CDAID = 'CDDA') and
       (CDA.fID = 'fmt ') and
       (CDA.Version = 1) then
     begin
      FormSpec := CDA.SerNum;
      TrackNum := CDA.TrackNum;
      TimLen := CDA.LenTime;
      Flg := True
     end
    end;
    if not Flg then
     begin
      D := UpperCase(File_Name);
      j := Pos('.CDA',D);
      if j >= 3 then
       TrackNum := StrToInt(Copy(D,j - 2,2))
      else
       raise Exception.Create('Open CDA error')
     end;
//    if not Flg then AddCDTrack(DriveNum,TrackNum,False)
  except
   exit
  end;

  i := AddPlayListItem(PLItem);
{  Song_Author := Trim(Song_Author);
  Song_Name := Trim(Song_Name);
  PrgName := Trim(PrgName);
  TrackName := Trim(TrackName);
  ComStr := Trim(ComStr);}
  with PLItem^ do
   begin
    Author := '';//Song_Author;
    Title := '';//Song_Name;
    Programm := '';//PrgName;
    Tracker := '';//TrackName;
    Comment := '';//ComStr;
    Date := '';//DateStr;
    FileName := File_Name;
    Offset := TrackNum;//F_Offset;
    Address := DriveNum;//F_Address;
    Length := 0;//F_Length;
    FileType := CDAFile;
    UnpackedSize := 0;//orisize;
    Loop := -1;//Looping_VBL;
    Ay_Freq := -1;//ChipFrq;
    Int_Freq := -1;//PlrFrq;
    Channel_Mode := -1;//ChanMode;
    Chip_Type := No_Chip;
    Number_Of_Channels := 0;//Ster;
    Time := TimLen;
    Error := FileNoError;
    FormatSpec := FormSpec;
    Selected := False
   end;
  RedrawItem(0,i);
  CalculatePlaylistScrollBar
 end;

const
 STPMask:array[0..15] of integer = (0,$21,-1,-1,$C3,-1,-1,$C3,-1,-1,$ED,-1,-1,-1,$C3,-2);
 ASCMask1:array[0..4] of integer = ($53,$CD,$52,0,-2);
 ASCMask2:array[0..3] of integer = ($53,$AF,$21,-2);

var
 sn:string;
 n:integer;

 function MatchMask(p:PInteger):boolean;
 var
  o:integer;
 begin
 Result := False;
 o := p^;
 repeat
  inc(integer(p),4);
  if p^ = -2 then break;
  if (p^ > 0) and (p^ <> byte(sn[o + 1])) then exit;
  inc(o)
 until False;
 Result := True;
 end;

 procedure ExtrName(ofs,idlen,nmlen,id2len,autlen:integer);
 var
  flg:boolean;
 begin
  flg := False;
  PlayListItems[n].Comment := Copy(sn,ofs,idlen + nmlen + id2len + autlen);
  if PlayListItems[n].Title = '' then
   begin
    flg := True;
    PlayListItems[n].Title := Trim(Copy(sn,ofs + idlen,nmlen));
   end;
  if (autlen <> 0) and (PlayListItems[n].Author = '') then
   begin
    flg := True;
    PlayListItems[n].Author := Trim(Copy(sn,ofs + idlen + nmlen + id2len,autlen));
   end;
  if flg then RedrawItem(0,n)
 end;

var
 i,oftmp,sz:integer;

begin
UniReadInit(URHandle,URFile,File_Name,nil);
try
SFilePath := ExtractFilePath(File_Name);
SFileName := ExtractFileName(File_Name);
SFileExt := AnsiLowerCase(ExtractFileExt(File_Name));
F_Offset := 0; F_Address := 0;
F_Length := UniReadersData[URHandle].UniFileSize;
if F_Length > 65536 then F_Length := 65536;
F_Frame := @F_Buffer;
Loaded := False;
if SFileExt = '.out' then Add(OUTFile,0,-1) else
if SFileExt = '.zxay' then Add(ZXAYFile,0,-1) else
if SFileExt = '.stc' then Add(STCFile,0,-1) else
if SFileExt = '.asc' then Add(ASCFile,0,-1) else
if SFileExt = '.stp' then Add(STPFile,0,-1) else
if SFileExt = '.psc' then Add(PSCFile,0,-1) else
if SFileExt = '.fls' then Add(FLSFile,0,-1) else
if SFileExt = '.ftc' then Add(FTCFile,0,-1) else
if SFileExt = '.pt1' then Add(PT1File,0,-1) else
if SFileExt = '.pt2' then Add(PT2File,0,-1) else
if SFileExt = '.pt3' then Add(PT3File,0,-1) else
if SFileExt = '.sqt' then Add(SQTFile,0,-1) else
if SFileExt = '.gtr' then Add(GTRFile,0,-1) else
if SFileExt = '.fxm' then Add(FXMFile,0,-1) else
if SFileExt = '.psm' then Add(PSMFile,0,-1) else
if SFileExt = '.vtx' then Add(VTXFile,0,-1) else
if SFileExt = '.ym' then Add(YM3File,0,-1) else
if SFileExt = '.psg' then Add(PSGFile,0,-1) else
if SFileExt = '.mp3' then AddBASS(MP3File) else
if SFileExt = '.mp2' then AddBASS(MP2File) else
if SFileExt = '.mp1' then AddBASS(MP1File) else
if SFileExt = '.ogg' then AddBASS(OGGFile) else
if SFileExt = '.wav' then AddBASS(WAVFile) else
if SFileExt = '.wma' then AddBASS(WMAFile) else
if SFileExt = '.mo3' then AddBASS(MO3File) else
if SFileExt = '.it' then AddBASS(ITFile) else
if SFileExt = '.xm' then AddBASS(XMFile) else
if SFileExt = '.s3m' then AddBASS(S3MFile) else
if SFileExt = '.mtm' then AddBASS(MTMFile) else
if SFileExt = '.mod' then AddBASS(MODFile) else
if SFileExt = '.umx' then AddBASS(UMXFile) else
if SFileExt = '.cda' then AddCD else
if SFileExt = '.ay' then OpenAYFile else
if SFileExt = '.aym' then OpenAYMFile else
if Detect then
 begin
  try
   UniRead(URHandle,@Zag,4);
   if zag = 'ZXAY' then
    begin
     UniRead(URHandle,@Zag,4);
     UniFileSeek(URHandle,0); // need for OpenAYFile
     if (Zag <> 'EMUL') and (Zag <> 'AMAD') then
      Add(ZXAYFile,0,-1)
     else
      OpenAYFile
    end
   else
    begin
//     UniFileSeek(URHandle,0);
     if (zag = 'PSG'#$1a) or (zag = 'EPSG') then
      Add(PSGFile,0,-1)
     else if (zag = 'YM2!') or (zag = 'YM3!') or (zag = 'YM3b') or
             (zag = 'YM5!') or (zag = 'YM6!') then
      Add(YM3File,0,-1)
     else if (((zag[0] = 'a') and (zag[1] = 'y')) or
              ((zag[0] = 'y') and (zag[1] = 'm')) or
              ((zag[0] = 'A') and (zag[1] = 'Y')) or
              ((zag[0] = 'Y') and (zag[1] = 'M'))
             ) and (zag[2] in [#0..#6]) then
      Add(VTXFile,0,-1)
     else
      begin
       UniFileSeek(URHandle,2);
       UniRead(URHandle,@LHZag,5);
       if LHZag = '-lh5-' then
        Add(YM3File,0,-1)
       else
        begin
         Init_Detector;
         while Module_Detector do
          begin
           n := Add(FType,FTime,FLoop);
           if n >= 0 then
            for i := 0 to Length(ImageCatalog) - 1 do
             with ImageCatalog[i] do
              if (F_Offset >= Offset) and
                 (F_Offset + F_Length <= Offset + Size) then
               begin
                sz := 0; if (FType = STPFile) then sz := $46
                else if FType in [ASCFile,ASC0File] then sz := $56;
                if (sz <> 0) and (Size > sz) then
                 begin
                  oftmp := FilePos(UniReadersData[URHandle].UniFile);
                  Seek(UniReadersData[URHandle].UniFile,Offset);
                  SetLength(sn,sz);
                  BlockRead(UniReadersData[URHandle].UniFile,sn[1],sz);
                  if (FType = STPFile) and MatchMask(@STPMask) and
                     (Copy(sn,18,Length(KsaId)) = KsaId) then
                   ExtrName(18,Length(KsaId),25,0,0)
                  else if (FType in [ASCFile,ASC0File]) and
                          (MatchMask(@ASCMask1) or MatchMask(@ASCMask2)) then
                   ExtrName($15,19,20,4,20);
                  Seek(UniReadersData[URHandle].UniFile,oftmp);
                 end;
                PlayListItems[n].Programm := ImageID + SFileName + '->'
                  + Name;
                if (PlayListItems[n].Author = '') and
                   (PlayListItems[n].Title = '') then
                 begin
                  PlayListItems[n].Title := Name;
                  RedrawItem(0,n)
                 end;
                break
               end;
           inc(F_Offset,F_Length - 1);
           inc(F_Index,F_Length - 1);
           dec(Readen1,F_Length - 1);
           F_Address := 0;
          end
        end
      end
    end
  except
  end;
 end;
finally
 UniReadClose(URHandle)
end
end;

procedure FindModules;
var F_STC,F_ASM0,F_ASM1,F_STP,F_PSC,F_FXM,
F_FLS,F_SQT,F_PT1,F_PT2,F_PT3,F_FTC,F_GTR,F_,IntegrityCheck:boolean;
SourceF,DistDir,String1:string;
F_Report:textfile;
F_In,F_Out:file;
FTime,FLoop,F_Offset:integer;
F_Index:integer;
FilSiz,Readen2,F_Point:integer;
F_Buffer:array[0..65536*2-1]of byte;
Index:integer;
masg:TMsg;
FXMSID:record
  Ch:array[0..3] of char;
  Addr:word;
end;
begin
FinderWorksNow:=True;
with Form6 do
 begin
 IntegrityCheck := not CheckBox57.Checked;
 F_STC:=CheckBox1.Checked;
 F_STP:=CheckBox8.Checked;
 F_ASM0:=CheckBox2.Checked;
 F_ASM1:=CheckBox10.Checked;
 F_PSC:=CheckBox6.Checked;
 F_PT1:=CheckBox3.Checked;
 F_PT2:=CheckBox4.Checked;
 F_PT3:=CheckBox5.Checked;
 F_FTC:=CheckBox7.Checked;
 F_FLS:=CheckBox9.Checked;
 F_SQT:=CheckBox11.Checked;
 F_GTR:=CheckBox33.Checked;
 F_FXM:=CheckBox35.Checked;
 F_:=F_STC or F_STP or F_ASM0 or F_ASM1 or F_PSC or F_PT1 or F_PT2 or F_PT3
     or F_FTC or F_FLS or F_SQT or F_GTR or F_FXM;
 if not F_ then
  begin
   AllEnable;
   exit
  end;
 DistDir:=DName.Text;
 if not MyForceDirectories(DistDir) then
  begin
  AllEnable;
  If Russian_Interface then
   Protokol.Lines.Add('Не удаётся создать рабочую папку')
  else
   Protokol.Lines.Add('Can not create destination folder');
  exit
  end;
 if (Length(DistDir)>0) and (DistDir[Length(DistDir)]<>'\') then
  DistDir:=DistDir+'\';
 end;
May_Quit:=False;
For Index:=0 to Form6.Memo1.Lines.Count-1 do
 begin
  AssignFile(F_In,Form6.Memo1.Lines.Strings[Index]);
{$i-}
  Reset(F_In,1);
{$i+}
 If IOResult<>0 then
  begin
  if Russian_Interface then
   Form6.Protokol.Lines.Add(IntToStr(Index)+'. Файл "'+
   Form6.Memo1.Lines.Strings[Index]+'" не найден или недоступен.')
  else
   Form6.Protokol.Lines.Add(IntToStr(Index)+'. File "'+
   Form6.Memo1.Lines.Strings[Index]+'" not found or access denied.')
  end
 else
  begin
  if Russian_Interface then
   Form6.Protokol.Lines.Add(IntToStr(Index)+'. Анализ файла "'+
   Form6.Memo1.Lines.Strings[Index]+'".')
  else
   Form6.Protokol.Lines.Add(IntToStr(Index)+'. Analisis of file  "'+
   Form6.Memo1.Lines.Strings[Index]+'".');
  F_Offset:=-1;
  F_Index:=65535;
  FilSiz:=FileSize(F_In)-1;
  Form6.ProgressBar1.Max:=FilSiz+1;
  Form6.ProgressBar1.Position:=0;
  blockread(F_In,F_Buffer[65536],65536,Readen1);
  may_quit:=false;
  F_Point:=1024;
  repeat
   inc(F_Offset);
   inc(F_Index);
   dec(Readen1);
   if F_Index>=65536 then
    begin
    move(F_Buffer[65536],F_Buffer,65536);
    dec(F_Index,65536);blockread(F_In,F_Buffer[65536],65536,Readen2);
    inc(Readen1,Readen2);
    end;
    integer(F_Frame):=integer(@F_Buffer)+F_Index;
    FTime := 0; FLoop := 0; F_Address := 0;
    if F_STC and FoundST(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Sound Tracker Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.stc');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_ASM1 and FoundASC1(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('ASM 1.xx Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.asc');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_ASM0 and FoundASC0(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('ASM 0.xx Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.asc');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,1);
    blockwrite(F_Out,zero,1);
    inc(F_Frame.ASC0_PatternsPointers);
    inc(F_Frame.ASC0_SamplesPointers);
    inc(F_Frame.ASC0_OrnamentsPointers);
    blockwrite(F_Out,F_Frame.ASC0_PatternsPointers,F_Length-1);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_STP and FoundSTP(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Sound Tracker Pro Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.stp');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_PT2 and FoundPT2(IntegrityCheck,FTime,FLoop) then begin
    if F_Address <> 0 then
     String1 := 'Phantom Family Pro Tracker 2.4'
    else
     String1 := 'Pro Tracker 2.xx';
    Form6.Protokol.Lines.Add(String1 + ' Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.pt2');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_PT3 and FoundPT3(IntegrityCheck,FTime,FLoop) then begin
    if F_Address <> 0 then
     String1 := 'Pro Tracker 3.x Utility'
    else
     String1 := 'Pro Tracker 3.xx';
    Form6.Protokol.Lines.Add(String1 + ' Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.pt3');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_PSC and FoundPSC(False,IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Pro Sound Creator v1.04-1.07 Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.psc');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_PSC and FoundPSC(True,IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Pro Sound Creator v1.00-1.03 Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.psc');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_FTC and FoundFTC(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Fast Tracker Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.ftc');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_PT1 and FoundPT1(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Pro Tracker v1.xx Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.pt1');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_SQT and FoundSQT(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('SQ-Tracker Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.sqt');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_GTR and FoundGTR(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Global Tracker Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.gtr');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
    if F_FXM and FoundFXM(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Fuxoft AY Language Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.fxm');
    rewrite(F_Out,1);
    FXMSID.Ch := 'FXSM';
    FXMSID.Addr := F_Address;
    blockwrite(F_Out,FXMSID,6);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end else
   if F_FLS and FoundFLS(IntegrityCheck,FTime,FLoop) then begin
    Form6.Protokol.Lines.Add('Flash Tracker Offset '+ IntToHex(F_Offset,8)+
                                    ' Length '+IntToHex(F_Length,4));
    AssignFile(F_Out,DistDir+IntToHex(Index,3)+'_'+IntToHex(F_Offset,8)+'.fls');
    rewrite(F_Out,1);
    blockwrite(F_Out,F_Frame^,F_Length);
    inc(F_Offset,F_Length-1);
    inc(F_Index,F_Length-1);
    dec(Readen1,F_Length-1);
    closefile(F_Out);end;
   if F_Offset>F_Point then begin
    Form6.ProgressBar1.Position:=F_Offset;
    F_Point:=F_Offset+1024;
    while PeekMessage(masg,Form1.Handle,0,0,PM_REMOVE) do
     begin
      case masg.message of
       WM_LBUTTONDOWN,WM_LBUTTONUP,
       WM_PAINT:
         begin
          TranslateMessage(Masg);
          DispatchMessage(Masg);
         end;
      end;
     end;
    if Form2.Visible then
    while PeekMessage(masg,Form2.Handle,0,0,PM_REMOVE) do
     begin
      case masg.message of
      WM_PAINT:
      begin
       TranslateMessage(Masg);
       DispatchMessage(Masg);
      end;
      end;
     end;
    if Form3.Visible then
    while PeekMessage(masg,Form3.Handle,0,0,PM_REMOVE) do
     begin
      case masg.message of
      WM_PAINT:
      begin
       TranslateMessage(Masg);
       DispatchMessage(Masg);
      end;
      end;
     end;
    while PeekMessage(masg,Form6.Handle,0,0,PM_REMOVE) do
     begin
          TranslateMessage(Masg);
          DispatchMessage(Masg);
     end;
    end;
    until may_quit or (F_Offset>=FilSiz);
    Form6.ProgressBar1.Position:=F_Offset+1;
    closefile(F_In);
    if may_quit then
    begin
    if Russian_Interface then
     Form6.Protokol.Lines.Add('Прервано по желанию пользователя.')
    else
     Form6.Protokol.Lines.Add('Interrupted because of user wish.');
    break
    end;
  end;
 end;
Form6.AllEnable;
end;

procedure MakeBufferOUT(Buf:pointer);
begin
BuffLen := 0;
if IntFlag then
 begin
  SynthesizerOUT(Buf);
  if IntFlag then exit;
  if (ZX_Takt <> -1) and ((ZX_Port and PortMask) = ($BFFD and PortMask)) then
   SetAYRegister(Current_RegisterAY,ZX_Port_Data)
 end;
with UniReadersData[FileHandle]^ do
 if UniFilePos = UniFileSize then
  if not Do_Loop then
   begin
    Real_End := True;
    exit
   end
  else
   InitForAllTypes(False);
while not Real_End and (BuffLen < BufferLength) do
begin
UniRead(FileHandle,@ZX_Takt,2);
UniRead(FileHandle,@ZX_Port,2);
UniRead(FileHandle,@ZX_Port_Data,1);
if (ZX_Takt = -1) or (ZX_Takt = 0) then SynthesizerOUT(Buf);
if ZX_Takt <> -1 then
 if (ZX_Port and PortMask) = ($FFFD and PortMask) then
  Current_RegisterAY := ZX_Port_Data
 else if (ZX_Port and PortMask) = ($BFFD and PortMask) then
  begin
   if ZX_Takt <> 0 then SynthesizerOUT(Buf);
   if not IntFlag then
    SetAYRegister(Current_RegisterAY,ZX_Port_Data)
  end;
with UniReadersData[FileHandle]^ do
 if (UniFilePos = UniFileSize) and (not IntFlag) then
  if not Do_Loop then Real_End := True else InitForAllTypes(False)
end
end;

procedure OUT_Get_Registers;
var
 ZX_Takt2:smallint;
 Number_Of_Takts:smallint;
begin
with UniReadersData[FileHandle]^ do
 if UniFilePos = UniFileSize then
  exit;
repeat
 if not IntFlag then
  begin
   UniRead(FileHandle,@ZX_Takt,2);
   UniRead(FileHandle,@ZX_Port,2);
   UniRead(FileHandle,@ZX_Port_Data,1);
   if ZX_Takt = -1 then
    ZX_Takt2 := 0
   else
    ZX_Takt2 := ZX_Takt;
   Number_Of_Takts := ZX_Takt2 - Previous_AY_Takt;
   Previous_AY_Takt := ZX_Takt2;
   if Number_Of_Takts <= 0 then
    Inc(Number_Of_Takts,17472);
   Inc(OUTZXAYConv_TotalTime,Number_Of_Takts)
  end;

 IntFlag := False;
 if OUTZXAYConv_TotalTime >= MaxTStates then
  begin
   Dec(OUTZXAYConv_TotalTime,MaxTStates);
   IntFlag := True;
   exit
  end;
 if ZX_Takt <> -1 then
  if (ZX_Port and PortMask) = ($FFFD and PortMask) then
   Current_RegisterAY := ZX_Port_Data
  else if (ZX_Port and PortMask) = ($BFFD and PortMask) then
   SetAYRegister(Current_RegisterAY,ZX_Port_Data)
until UniReadersData[FileHandle]^.UniFilePos =
                UniReadersData[FileHandle]^.UniFileSize
end;

procedure MakeBufferEPSG;
var
 EPSGRec:packed record
  case Boolean of
  True:(Reg,Data:byte;
        TSt:longword);
  False:(All:int64);
 end;
begin
BuffLen := 0;
if IntFlag then
 begin
  SynthesizerEPSG(Buf);
  if IntFlag then exit;
  if Flg <> 0 then
   SetAYRegister(AY_Reg,AY_Data)
 end;
if UniReadersData[FileHandle].UniFilePos =
     UniReadersData[FileHandle].UniFileSize then
 if not Do_Loop then
  begin
   Real_End := True;
   exit
  end
 else
  InitForAllTypes(False);
EPSGRec.All := 0;
while not Real_End and (BuffLen < BufferLength) do
begin
UniRead(FileHandle,@EPSGRec,5);
if EPSGRec.All = $FFFFFFFFFF then
 begin
  Flg := 0;
  AY_Takt := 0;
  Dec(Previous_AY_Takt,EPSG_TStateMax);
  SynthesizerEPSG(Buf)
 end
else
 begin
  Flg := 1;
  with EPSGRec do
   begin
    AY_Reg := Reg;
    AY_Data := Data;
    AY_Takt := TSt
   end;
  SynthesizerEPSG(Buf);
  if not IntFlag then
   SetAYRegister(AY_Reg,AY_Data)
 end;
if (UniReadersData[FileHandle].UniFilePos =
     UniReadersData[FileHandle].UniFileSize) and not IntFlag then
 if not Do_Loop then
  Real_End := True
 else
  InitForAllTypes(False)
end
end;

procedure EPSG_Get_Registers;
var
 EPSGRec:packed record
  case Boolean of
  True:(Reg,Data:byte;
        TSt:longword);
  False:(All:int64);
 end;
begin
if (UniReadersData[FileHandle].UniFilePos =
     UniReadersData[FileHandle].UniFileSize) then
 exit;
EPSGRec.All := 0;
repeat
UniRead(FileHandle,@EPSGRec,5);
if EPSGRec.All <> $FFFFFFFFFF then
 with EPSGRec do
  SetAYRegister(Reg,Data)
until (UniReadersData[FileHandle].UniFilePos =
     UniReadersData[FileHandle].UniFileSize) or
      (EPSGRec.All = $FFFFFFFFFF)
end;

procedure MakeBufferPSG;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 PSG_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf);
end
end;

procedure PSG_Get_Registers;
var
 b,b2:byte;
begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit;
  end;
inc(Global_Tick_Counter);
if PSG_Skip > 0 then
 begin
  dec(PSG_Skip);
  exit;
 end;
if UniReadersData[FileHandle].UniFileSize <= 16 then exit;
if UniReadersData[FileHandle].UniFilePos >=
     UniReadersData[FileHandle].UniFileSize then
 InitForAllTypes(False);
repeat
 UniRead(FileHandle,@b,1);
 if b = 255 then exit;
 if b = 254 then
  begin
   UniRead(FileHandle,@b,1);
   PSG_Skip := b * 4 - 1;
   exit
  end;
 if UniReadersData[FileHandle].UniFilePos <
       UniReadersData[FileHandle].UniFileSize then
  begin
   UniRead(FileHandle,@b2,1);
   if b < 14 then
    begin
     case b of
     13:SetEnvelopeRegister(b2 and 15);
     1,3,5:
        RegisterAY.Index[b] := b2 and 15;
     6: RegisterAY.Noise := b2 and 31;
     7: SetMixerRegister(b2 and 63);
     8: SetAmplA(b2 and 31);
     9: SetAmplB(b2 and 31);
     10:SetAmplC(b2 and 31);
     else
        RegisterAY.Index[b] := b2;
     end;
    end;
  end;
until UniReadersData[FileHandle].UniFilePos >=
       UniReadersData[FileHandle].UniFileSize
end;

procedure MakeBufferZXAY;
var
 tmp:integer;
begin
BuffLen := 0;
if IntFlag then
 begin
  SynthesizerZXAY(Buf);
  if IntFlag then exit;
  SetAYRegisterFast(AY_Reg,AY_Data)
 end;
if UniReadersData[FileHandle].UniFilePos >=
     UniReadersData[FileHandle].UniFileSize then
 if not Do_Loop then
  begin
   Real_End := True;
   exit
  end
 else
  InitForAllTypes(False);
while not Real_End and (BuffLen < BufferLength) do
begin
UniRead(FileHandle,@tmp,4);
AY_Takt := tmp and $FFFFF;
AY_Reg := (tmp shr 20) and 15;
AY_Data := tmp shr 24;
SynthesizerZXAY(Buf);
if not IntFlag then
 SetAYRegisterFast(AY_Reg,AY_Data);
if (UniReadersData[FileHandle].UniFilePos >=
     UniReadersData[FileHandle].UniFileSize) and not IntFlag then
 if not Do_Loop then
  Real_End := True
 else
  InitForAllTypes(False)
end
end;

procedure ZXAY_Get_Registers;
var
 AY_Takt:longint;
 Number_Of_Takts,tmp:longint;
begin
with UniReadersData[FileHandle]^ do
 if UniFilePos = UniFileSize then
  exit;
repeat
if not IntFlag then
 begin
  UniRead(FileHandle,@tmp,4);
  AY_Takt := tmp and $FFFFF;
  AY_Reg := (tmp shr 20) and 15;
  AY_Data := tmp shr 24;
  Number_Of_Takts := AY_Takt - Previous_AY_Takt;
  Previous_AY_Takt := AY_Takt;
  if (Number_Of_Takts <= 0) then Inc(Number_Of_Takts,$100000);
  Inc(OUTZXAYConv_TotalTime,Number_Of_Takts);
 end;
IntFlag := False;
if OUTZXAYConv_TotalTime >= MaxTStates then
 begin
  Dec(OUTZXAYConv_TotalTime,MaxTStates);
  IntFlag := True;
  exit
 end;
SetAYRegisterFast(AY_Reg,AY_Data)
until UniReadersData[FileHandle]^.UniFilePos =
                UniReadersData[FileHandle]^.UniFileSize
end;

procedure MakeBufferPT2;
begin
BuffLen := 0;
If IntFlag then SynthesizerZX50(Buf);
If IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 PT2_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure PT2_Get_Registers;
var
 TempMixer:byte;
 
 procedure PatternInterpreter(var Chan:PT2_Channel_Parameters);
 var
  quit,gliss:boolean;
 begin
 quit := False;
 gliss := False;
 with Chan,RAM do
  begin
   repeat
    case Index[Chan.Address_In_Pattern] of
    $e1..$ff:
     begin
      SamplePointer := PT2_SamplesPointers[Index[Address_In_Pattern] - $e0];
      Sample_Length := Index[SamplePointer];
      Inc(SamplePointer);
      Loop_Sample_Position := Index[SamplePointer];
      Inc(SamplePointer)
     end;
    $e0:
     begin
      Position_In_Sample := 0;
      Position_In_Ornament := 0;
      Current_Ton_Sliding := 0;
      GlissType := 0;
      Enabled := False;
      quit := True
     end;
    $80..$df:
     begin
      Position_In_Sample := 0;
      Position_In_Ornament := 0;
      Current_Ton_Sliding := 0;
      if gliss then
       begin
        Slide_To_Note := Index[Address_In_Pattern] - $80;
        if GlissType = 1 then Note := Slide_To_Note
       end
      else
       begin
        Note := Index[Address_In_Pattern] - $80;
        GlissType := 0
       end;
      Enabled := True;
      quit := True
     end;
    $7f:
     Envelope_Enabled := False;
    $71..$7e:
     begin
      Envelope_Enabled := True;
      SetEnvelopeRegister(Index[Address_In_Pattern] - $70);
      Inc(Address_In_Pattern);
      RegisterAY.Index[11] := Index[Address_In_Pattern];
      Inc(Address_In_Pattern);
      RegisterAY.Index[12] := Index[Address_In_Pattern]
     end;
    $70:
      quit := True;
    $60..$6f:
     begin
      OrnamentPointer := PT2_OrnamentsPointers[Index[Address_In_Pattern] - $60];
      Ornament_Length := Index[OrnamentPointer];
      Inc(OrnamentPointer);
      Loop_Ornament_Position := Index[OrnamentPointer];
      Inc(OrnamentPointer);
      Position_In_Ornament := 0
     end;
    $20..$5f:
     Number_Of_Notes_To_Skip := Index[Address_In_Pattern] - $20;
    $10..$1f:
     Volume := Index[Address_In_Pattern] - $10;
    $f:
     begin
      Inc(Address_In_Pattern);
      PlParams.PT2.Delay := Index[Address_In_Pattern]
     end;
    $e:
     begin
      Inc(Address_In_Pattern);
      Glissade := Index[Address_In_Pattern];
      GlissType := 1;
      gliss := True
     end;
    $d:
     begin
      Inc(Address_In_Pattern);
      Glissade := Abs(shortint(Index[Address_In_Pattern]));
{      Inc(Address_In_Pattern);
      Ton_Delta := Index[Address_In_Pattern];
      Inc(Address_In_Pattern);
      Inc(Ton_Delta,word(Index[Address_In_Pattern])shl 8);}
      Inc(Address_In_Pattern,2); //Not use precalculated Ton_Delta
                                //to avoide error with first note of pattern
      GlissType := 2;
      gliss := True;
     end;
    $c:
     GlissType := 0
    else
     begin
      Inc(Address_In_Pattern);
      Addition_To_Noise := Index[Address_In_Pattern]
     end
    end;
    inc(Address_In_Pattern)
   until quit;
   {Alternative Ton_Delta calc begin}
   if gliss and (GlissType = 2) then
    begin
     Ton_Delta := Abs(PT3NoteTable_ST[Slide_To_Note] - PT3NoteTable_ST[Note]);
     if Slide_To_Note > Note then Glissade := -Glissade
    end;
   {Alternative Ton_Delta calc end}
   Note_Skip_Counter := Number_Of_Notes_To_Skip
  end
 end;

 procedure GetRegisters(var Chan:PT2_Channel_Parameters);
 var
  j,b0,b1:byte;
 begin
  with Chan,RAM do
   begin
    if Enabled then
     begin
      b0 := Index[SamplePointer + Position_In_Sample * 3];
      b1 := Index[SamplePointer + Position_In_Sample * 3 + 1];
      Ton := Index[SamplePointer + Position_In_Sample * 3 + 2] +
        word(b1 and 15) shl 8;
      if b0 and 4 = 0 then Ton := -Ton;
      j := Note + Index[OrnamentPointer + Position_In_Ornament];
      if shortint(j) < 0 then j := 0 else if j > 95 then j := 95;
      Ton := (Ton + Current_Ton_Sliding + PT3NoteTable_ST[j]) and $fff;
      if GlissType = 2 then
       begin
        Ton_Delta := Ton_Delta - Abs(Glissade);
        if Ton_Delta < 0 then
         begin
          Note := Slide_To_Note;
          GlissType := 0;
          Current_Ton_Sliding := 0
         end
       end;
      if GlissType <> 0 then inc(Current_Ton_Sliding,Glissade);
      Amplitude := round((Volume * 17 + byte(Volume > 7)) * (b1 shr 4) / 256);
      if Envelope_Enabled then Amplitude := Amplitude or 16;
      if b0 and 1 <> 0 then
       TempMixer := TempMixer or 64
      else
       RegisterAY.Noise := (b0 shr 3 + Addition_To_Noise) and 31;
      if b0 and 2 <> 0 then
       TempMixer := TempMixer or 8;
      inc(Position_In_Sample);
      if Position_In_Sample = Sample_Length then
       Position_In_Sample := Loop_Sample_Position;
      inc(Position_In_Ornament);
      if Position_In_Ornament = Ornament_Length then
       Position_In_Ornament := Loop_Ornament_Position
     end
    else
     Amplitude := 0
   end;
  TempMixer := TempMixer shr 1
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.PT2 do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.PT2_A,RAM do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       begin
        if (Index[Address_In_Pattern] = 0)then
         begin
          Inc(CurrentPosition);
          if CurrentPosition = PT2_NumberOfPositions then
           CurrentPosition := PT2_LoopPosition;
          Address_In_Pattern := WordPtr(@Index[PT2_PatternsPointer +
                                   PT2_PositionList[CurrentPosition] * 6])^;
          PlParams.PT2_B.Address_In_Pattern :=
           WordPtr(@Index[PT2_PatternsPointer +
                                   PT2_PositionList[CurrentPosition] * 6 + 2])^;
          PlParams.PT2_C.Address_In_Pattern :=
           WordPtr(@Index[PT2_PatternsPointer +
                                   PT2_PositionList[CurrentPosition] * 6 + 4])^;
         end;
        PatternInterpreter(PlParams.PT2_A);
       end
     end;
    with PlParams.PT2_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.PT2_B)
     end;
    with PlParams.PT2_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.PT2_C)
     end;
    DelayCounter := Delay
   end;
  TempMixer := 0;
  GetRegisters(PlParams.PT2_A);
  GetRegisters(PlParams.PT2_B);
  GetRegisters(PlParams.PT2_C);

  SetMixerRegister(TempMixer);

  RegisterAY.TonA := PlParams.PT2_A.Ton;
  RegisterAY.TonB := PlParams.PT2_B.Ton;
  RegisterAY.TonC := PlParams.PT2_C.Ton;

  SetAmplA(PlParams.PT2_A.Amplitude);
  SetAmplB(PlParams.PT2_B.Amplitude);
  SetAmplC(PlParams.PT2_C.Amplitude);

  inc(Global_Tick_Counter)
 end
end;

procedure MakeBufferSTC;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 STC_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf);
end
end;

procedure STC_Get_Registers;
var
 TempMixer:byte;
 
 procedure PatternInterpreter(var Chan:STC_Channel_Parameters);
 var
  k:word;
 begin
  with Chan,RAM do
   begin
    repeat
     case Index[Address_In_Pattern] of
     0..$5f:
      begin
       Note := Index[Address_In_Pattern];
       Sample_Tik_Counter := 32;
       Position_In_Sample := 0;
       Inc(Address_In_Pattern);
       break
      end;
     $60..$6f:
      begin
       k := 0;
       while Index[$1b + $63 * k] <> (Index[Address_In_Pattern] - $60) do
        inc(k);
       SamplePointer := $1c + $63 * k;
      end;
     $70..$7f:
      begin
       k := 0;
       while Index[ST_OrnamentsPointer + $21 * k] <>
                              (Index[Address_In_Pattern] - $70) do
        inc(k);
       OrnamentPointer := ST_OrnamentsPointer + $21 * k + 1;
       Envelope_Enabled := False
      end;
     $80:
      begin
       Sample_Tik_Counter := -1;
       Inc(Address_In_Pattern);
       break
      end;
     $81:
      begin
       Inc(Address_In_Pattern);
       break
      end;
     $82:
      begin
       k := 0;
       while Index[ST_OrnamentsPointer + $21 * k] <> 0 do inc(k);
       OrnamentPointer := ST_OrnamentsPointer + $21 * k + 1;
       Envelope_Enabled := False
      end;
     $83..$8e:
      begin
       SetEnvelopeRegister(Index[Address_In_Pattern] - $80);
       Inc(Address_In_Pattern);
       RegisterAY.Index[11] := Index[Address_In_Pattern];
       Envelope_Enabled := True;
       k := 0;
       while Index[ST_OrnamentsPointer + $21 * k] <> 0 do inc(k);
       OrnamentPointer := ST_OrnamentsPointer + $21 * k + 1;
      end
     else
      Number_Of_Notes_To_Skip := Index[Address_In_Pattern] - $a1;
     end;
     inc(Address_In_Pattern)
    until False;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end
 end;

 procedure GetRegisters(var Chan:STC_Channel_Parameters);
 var
  i:word;
  j:byte;
 begin
  with Chan,RAM do
   begin
    if Sample_Tik_Counter >= 0 then
     begin
      Dec(Sample_Tik_Counter);
      Position_In_Sample := (Position_In_Sample + 1) and $1f;
      if Sample_Tik_Counter = 0 then
       if Index[SamplePointer + $60] <> 0 then
        begin
         Position_In_Sample := Index[SamplePointer + $60] and $1f;
         Sample_Tik_Counter := Index[SamplePointer + $61] + 1
        end
       else
        Sample_Tik_Counter := -1
     end;
    if Sample_Tik_Counter >= 0 then
     begin
      i := ((Position_In_Sample - 1) and $1f) * 3 + SamplePointer;
      if Index[i + 1] and $80 <> 0 then
       TempMixer := TempMixer or 64
      else
       RegisterAY.Noise := Index[i + 1] and $1f;
      if Index[i + 1] and $40 <> 0 then
       TempMixer := TempMixer or 8;
      Amplitude := Index[i] and 15;
      j := Note + Index[OrnamentPointer + (Position_In_Sample - 1) and $1f] +
                                   PlParams.STC.Transposition;
      if j > 95 then j := 95;
      if Index[i + 1] and $20 <> 0 then
       Ton := (ST_Table[j] + Index[i + 2] + word(Index[i] and $f0) shl 4)
                                                                      and $FFF
      else
       Ton := (ST_Table[j] - Index[i + 2] - word(Index[i] and $f0) shl 4)
                                                                      and $FFF;
      if Envelope_Enabled then Amplitude := Amplitude or 16
     end
    else
     Amplitude := 0
   end;
  TempMixer := TempMixer shr 1
 end;

var
 i:word;
begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;

with PlParams.STC do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   with RAM do
    begin
     DelayCounter := ST_delay;
     with PlParams.STC_A do
      begin
       Dec(Note_Skip_Counter);
       if Note_Skip_Counter < 0 then
        begin
         if Index[Address_In_Pattern] = 255 then
          begin
           if CurrentPosition = Index[ST_PositionsPointer] then
            CurrentPosition := 0
           else
            Inc(CurrentPosition);
           Transposition := Index[ST_PositionsPointer + 2 +
                                                 CurrentPosition * 2];
           i := 0;
           while Index[ST_PatternsPointer + 7 * i] <>
                            Index[ST_PositionsPointer + 1 +
                                                 CurrentPosition * 2] do
            inc(i);
           Address_In_Pattern :=
             WordPtr(@Index[ST_PatternsPointer + 7 * i + 1])^;
           PlParams.STC_B.Address_In_Pattern :=
             WordPtr(@Index[ST_PatternsPointer + 7 * i + 3])^;
           PlParams.STC_C.Address_In_Pattern :=
             WordPtr(@Index[ST_PatternsPointer + 7 * i + 5])^
          end;
         PatternInterpreter(PlParams.STC_A)
        end
      end;
     with PlParams.STC_B do
      begin
       dec(Note_Skip_Counter);
       if Note_Skip_Counter<0 then
        PatternInterpreter(PlParams.STC_B)
      end;
     with PlParams.STC_C do
      begin
       dec(Note_Skip_Counter);
       if Note_Skip_Counter<0 then
        PatternInterpreter(PlParams.STC_C)
      end;
    end
 end;



TempMixer := 0;
GetRegisters(PlParams.STC_A);
GetRegisters(PlParams.STC_B);
GetRegisters(PlParams.STC_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.STC_A.Ton;
RegisterAY.TonB := PlParams.STC_B.Ton;
RegisterAY.TonC := PlParams.STC_C.Ton;

SetAmplA(PlParams.STC_A.Amplitude);
SetAmplB(PlParams.STC_B.Amplitude);
SetAmplC(PlParams.STC_C.Amplitude);

Inc(Global_Tick_Counter)
end;

procedure MakeBufferSTP;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 STP_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure STP_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:STP_Channel_Parameters);
 var
  quit:boolean;
 begin
  quit := False;
  with Chan,RAM do
   begin
    repeat
     case Index[Address_In_Pattern] of
     1..$60:
      begin
       Note := Index[Address_In_Pattern] - 1;
       Position_In_Sample := 0;
       Position_In_Ornament := 0;
       Current_Ton_Sliding := 0;
       Enabled := True;
       quit := True
      end;
     $61..$6f:
      begin
       SamplePointer := WordPtr(@Index[STP_SamplesPointer+
                                   (Index[Address_In_Pattern] - $61) * 2])^;
       Loop_Sample_Position := Index[SamplePointer];
       Inc(SamplePointer);
       Sample_Length := Index[SamplePointer];
       Inc(SamplePointer)
      end;
     $70..$7f:
      begin
       OrnamentPointer := WordPtr(@Index[STP_OrnamentsPointer +
                                   (Index[Address_In_Pattern] - $70) * 2])^;
       Loop_Ornament_Position := Index[OrnamentPointer];
       Inc(OrnamentPointer);
       Ornament_Length := Index[OrnamentPointer];
       Inc(OrnamentPointer);
       Envelope_Enabled := False;
       Glissade := 0;
      end;
     $80..$bf:
      Number_Of_Notes_To_Skip := Index[Address_In_Pattern]- $80;
     $c0..$cf:
      begin
       if Index[Address_In_Pattern] <> $c0 then
        begin
         SetEnvelopeRegister(Index[Address_In_Pattern] - $c0);
         Inc(Address_In_Pattern);
         RegisterAY.Index[11] := Index[Address_In_Pattern]
        end;
        Envelope_Enabled := True;
        Loop_Ornament_Position := 0;
        Glissade := 0;
        Ornament_Length := 1;
      end;
     $D0..$DF:
      begin
       Enabled := False;
       quit := True;
      end;
     $e0..$ef:
      quit := True;
     $f0:
      begin
       Inc(Address_In_Pattern);
       Glissade := Index[Address_In_Pattern]
      end;
     $f1..$ff:
      Volume := Index[Address_In_Pattern] - $f1;
     end;
     Inc(Address_In_Pattern)
    until quit;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end
 end;

 procedure GetRegisters(var Chan:STP_Channel_Parameters);
 var
  j,b0,b1:byte;
 begin
  with Chan,RAM do
   begin
    if Enabled then
     begin
      Inc(Current_Ton_Sliding,Glissade);
      if Envelope_Enabled then
       j := Note + PlParams.STP.Transposition
      else
       j := Note + PlParams.STP.Transposition +
              Index[OrnamentPointer + Position_In_Ornament];
      if j > 95 then j := 95;
      b0 := Index[SamplePointer + Position_In_Sample * 4];
      b1 := Index[SamplePointer + Position_In_Sample * 4 + 1];
      Ton := (ST_Table[j] + Current_Ton_Sliding +
        WordPtr(@Index[SamplePointer + Position_In_Sample * 4 + 2])^) and $fff;
      Amplitude := (b0 and 15) - Volume;
      if shortint(Amplitude) < 0 then Amplitude := 0;
      if ((b1 and 1) <> 0) and Envelope_Enabled then
       Amplitude := Amplitude or 16;
      TempMixer := b0 shr 1 and $48 or TempMixer;
      if shortint(b0) >= 0 then
       RegisterAY.Noise := (b1 shr 1) and 31;
      Inc(Position_In_Ornament);
      if Position_In_Ornament >= Ornament_Length then
       Position_In_Ornament := Loop_Ornament_Position;
      Inc(Position_In_Sample);
      if Position_In_Sample >= Sample_Length then
       begin
        Position_In_Sample := Loop_Sample_Position;
        if shortint(Loop_Sample_Position) < 0 then Enabled := False
       end
     end
    else
     begin
      TempMixer := TempMixer or $48;
      Amplitude := 0
     end
   end;
  TempMixer := TempMixer shr 1
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.STP do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   with RAM do
    begin
     DelayCounter := STP_Delay;
     with PlParams.STP_A do
      begin
       Dec(Note_Skip_Counter);
       if Note_Skip_Counter < 0 then
        begin
         if (Index[Address_In_Pattern] = 0)then
          begin
           inc(CurrentPosition);
           if CurrentPosition = Index[STP_PositionsPointer] then
            CurrentPosition := Index[STP_PositionsPointer + 1];
           Address_In_Pattern :=
              WordPtr(@Index[STP_PatternsPointer +
                   Index[STP_PositionsPointer + 2 + CurrentPosition * 2]])^;
           PlParams.STP_B.Address_In_Pattern :=
              WordPtr(@Index[STP_PatternsPointer +
                   Index[STP_PositionsPointer + 2 + CurrentPosition * 2] + 2])^;
           PlParams.STP_C.Address_In_Pattern :=
              WordPtr(@Index[STP_PatternsPointer +
                   Index[STP_PositionsPointer + 2 + CurrentPosition * 2] + 4])^;
           Transposition := Index[STP_PositionsPointer + 3 +
                                                    CurrentPosition * 2];
          end;
         PatternInterpreter(PlParams.STP_A)
        end
      end;
     with PlParams.STP_B do
      begin
       Dec(Note_Skip_Counter);
       if Note_Skip_Counter < 0 then
        PatternInterpreter(PlParams.STP_B)
      end;
     with PlParams.STP_C do
      begin
       Dec(Note_Skip_Counter);
       if Note_Skip_Counter < 0 then
        PatternInterpreter(PlParams.STP_C)
      end
    end
 end;

TempMixer := 0;
GetRegisters(PlParams.STP_A);
GetRegisters(PlParams.STP_B);
GetRegisters(PlParams.STP_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.STP_A.Ton;
RegisterAY.TonB := PlParams.STP_B.Ton;
RegisterAY.TonC := PlParams.STP_C.Ton;

SetAmplA(PlParams.STP_A.Amplitude);
SetAmplB(PlParams.STP_B.Amplitude);
SetAmplC(PlParams.STP_C.Amplitude);

inc(Global_Tick_Counter)

end;

procedure MakeBufferASC;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 ASC_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure ASC_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:ASC_Channel_Parameters);
 var
  delta_ton:smallint;
  Initialization_Of_Ornament_Disabled,
  Initialization_Of_Sample_Disabled:boolean;
 begin
  Initialization_Of_Sample_Disabled:=false;
  Initialization_Of_Ornament_Disabled:=false;
  with Chan do
   begin
    Ton_Sliding_Counter := 0;
    Amplitude_Delay_Counter := 0;
    repeat
     with RAM do
      case Index[Address_In_Pattern] of
      0..$55:
       begin
        Note := Index[Address_In_Pattern];
        Inc(Address_In_Pattern);
        Current_Noise := Initial_Noise;
        if shortint(Ton_Sliding_Counter) <= 0 then
         Current_Ton_Sliding := 0;
        if not Initialization_Of_Sample_Disabled then
         begin
          Addition_To_Amplitude := 0;
          Ton_Deviation := 0;
          Point_In_Sample := Initial_Point_In_Sample;
          Sound_Enabled := True;
          Sample_Finished := False;
          Break_Sample_Loop := False
         end;
        if not Initialization_Of_Ornament_Disabled then
         begin
          Point_In_Ornament := Initial_Point_In_Ornament;
          Addition_To_Note := 0
         end;
        if Envelope_Enabled then
         begin
          RegisterAY.Index[11] := Index[Chan.Address_In_Pattern];
          Inc(Address_In_Pattern)
         end;
        break
       end;
      $56..$5d:
       begin
        Inc(Address_In_Pattern);
        break
       end;
      $5e:
       begin
        Break_Sample_Loop := True;
        Inc(Address_In_Pattern);
        break
       end;
      $5f:
       begin
        Sound_Enabled := False;
        Inc(Address_In_Pattern);
        break
       end;
      $60..$9f:
       Number_Of_Notes_To_Skip := Index[Address_In_Pattern] - $60;
      $a0..$bf:
       Initial_Point_In_Sample :=
        WordPtr(@Index[(Index[Address_In_Pattern] - $a0) * 2 +
                       ASC1_SamplesPointers])^ + ASC1_SamplesPointers;
      $c0..$df:
       Initial_Point_In_Ornament :=
        WordPtr(@Index[(Index[Address_In_Pattern] - $c0) * 2 +
                       ASC1_OrnamentsPointers])^ + ASC1_OrnamentsPointers;
      $e0:
       begin
        Volume := 15;
        Envelope_Enabled := True
       end;
      $e1..$ef:
       begin
        Volume := Index[Address_In_Pattern] - $e0;
        Envelope_Enabled := False
       end;
      $f0:
       begin
        Inc(Address_In_Pattern);
        Initial_Noise := Index[Address_In_Pattern]
       end;
      $f1:
       Initialization_Of_Sample_Disabled := True;
      $f2:
       Initialization_Of_Ornament_Disabled := True;
      $f3:
       begin
        Initialization_Of_Sample_Disabled := True;
        Initialization_Of_Ornament_Disabled := True
       end;
      $f4:
       begin
        Inc(Address_In_Pattern);
        PlParams.ASC.Delay := Index[Address_In_Pattern]
       end;
      $f5:
       begin
        Inc(Address_In_Pattern);
        Substruction_for_Ton_Sliding :=
                - shortint(Index[Address_In_Pattern]) * 16;
        Ton_Sliding_Counter := 255
       end;
      $f6:
       begin
        Inc(Address_In_Pattern);
        Substruction_for_Ton_Sliding :=
                 shortint(Index[Chan.Address_In_Pattern]) * 16;
        Chan.Ton_Sliding_Counter := 255;
       end;
      $f7:
       begin
        Inc(Address_In_Pattern);
        Initialization_Of_Sample_Disabled := True;
        if Index[Address_In_Pattern + 1] < $56 then
         delta_ton := ASM_Table[Note] + Current_Ton_Sliding div 16 -
           ASM_Table[Index[Address_In_Pattern + 1]]
        else
         delta_ton := Current_Ton_Sliding div 16;
        delta_ton := delta_ton shl 4;
        Substruction_for_Ton_Sliding := -delta_ton div
                shortint(Index[Address_In_Pattern]);
        Current_Ton_Sliding := delta_ton - delta_ton mod
                shortint(Index[Address_In_Pattern]);
        Ton_Sliding_Counter :=
                shortint(Index[Address_In_Pattern])
       end;
      $f8:
       SetEnvelopeRegister(8);
      $f9:
       begin
        Inc(Address_In_Pattern);
        if Index[Address_In_Pattern+1] < $56 then
         delta_ton := ASM_Table[Note] -
             ASM_Table[Index[Address_In_Pattern + 1]]
        else
         delta_ton := Current_Ton_Sliding div 16;
        delta_ton := delta_ton shl 4;
        Substruction_for_Ton_Sliding := -delta_ton div
                  shortint(Index[Address_In_Pattern]);
        Current_Ton_Sliding := delta_ton - delta_ton mod
                  shortint(Index[Address_In_Pattern]);
        Ton_Sliding_Counter :=
                  shortint(Index[Address_In_Pattern]);
       end;
      $fa:
       SetEnvelopeRegister(10);
      $fb:
       begin
        inc(Chan.Address_In_Pattern);
        if Index[Chan.Address_In_Pattern] and 32 = 0 then
         begin
          Amplitude_Delay := Index[Address_In_Pattern] shl 3;
          Amplitude_Delay_Counter := Amplitude_Delay
         end
        else
         begin
          Amplitude_Delay := ((Index[Address_In_Pattern] shl 3)
              xor $f8) + 9;{bit 0 - чэръютvщ, р сшЄv 7-3 - ьюфєы№}
          Amplitude_Delay_Counter := Chan.Amplitude_Delay
         end;
       end;
      $fc:
       SetEnvelopeRegister(12);
      $fe:
       SetEnvelopeRegister(14);
      end;
     inc(Address_In_Pattern)
    until False;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end
 end;

 procedure GetRegisters(var Chan:ASC_Channel_Parameters);
 var
  j:shortint;
  Sample_Says_OK_for_Envelope:boolean;
 begin
  with Chan,RAM do
   begin
    if Sample_Finished or not Sound_Enabled then
     Amplitude := 0
    else
     begin
      if Amplitude_Delay_Counter <> 0 then
       if Amplitude_Delay_Counter >= 16 then
        begin
         Dec(Amplitude_Delay_Counter,8);
         if Addition_To_Amplitude < -15 then
          Inc(Addition_To_Amplitude)
         else if Addition_To_Amplitude > 15 then
          Dec(Addition_To_Amplitude)
        end
       else
        begin
         if (Amplitude_Delay_Counter and 1 <> 0) then
          begin
           if Addition_To_Amplitude > -15 then
            Dec(Addition_To_Amplitude)
          end
         else if Addition_To_Amplitude < 15 then
          Inc(Addition_To_Amplitude);
         Amplitude_Delay_Counter := Amplitude_Delay
        end;
      if Index[Point_In_Sample] and 128 <> 0 then
       Loop_Point_In_Sample := Point_In_Sample;
      if Index[Point_In_Sample] and 96 = 32 then
       Sample_Finished := True;
      Inc(Ton_Deviation,shortint(Index[Point_In_Sample + 1]));
      TempMixer := Index[Point_In_Sample + 2] and 9 shl 3 or TempMixer;
      if Index[Point_In_Sample + 2] and 6 = 2 then
       Sample_Says_OK_for_Envelope := True
      else
       Sample_Says_OK_for_Envelope := False;
      if Index[Point_In_Sample + 2] and 6 = 4 then
       if Addition_To_Amplitude >- 15 then
        Dec(Addition_To_Amplitude);
      if Index[Point_In_Sample + 2] and 6 = 6 then
       if Addition_To_Amplitude < 15 then
        Inc(Addition_To_Amplitude);
      Amplitude := Addition_To_Amplitude + Index[Point_In_Sample + 2] shr 4;
      if shortint(Amplitude) < 0 then
       Amplitude := 0
      else if Amplitude > 15 then
       Amplitude := 15;
      Amplitude := (Amplitude * (Volume + 1)) shr 4;
      if Sample_Says_OK_for_Envelope and (TempMixer and 64 <> 0) then
       Inc(RegisterAY.Index[11],shortint(Index[Point_In_Sample] shl 3) div 8)
      else
       Inc(Current_Noise,shortint(Index[Point_In_Sample] shl 3) div 8);
      Inc (Point_In_Sample,3);
      if Index[Point_In_Sample - 3] and 64 <> 0 then
       if not Break_Sample_Loop then
        Point_In_Sample := Loop_Point_In_Sample
       else if Index[Point_In_Sample - 3] and 32 <> 0 then
        Sample_Finished := True;
       if Index[Point_In_Ornament] and 128 <> 0 then
        Loop_Point_In_Ornament := Point_In_Ornament;
       inc(Addition_To_Note,Index[1 + Point_In_Ornament]);
       inc(Current_Noise,
         (-shortint(Index[Point_In_Ornament] and $10)) or
                                 Index[Point_In_Ornament]);
       inc(Point_In_Ornament,2);
       if Index[Point_In_Ornament - 2] and 64 <> 0 then
        Point_In_Ornament := Loop_Point_In_Ornament;
       if TempMixer and 64 = 0 then
        RegisterAY.Noise := (byte(Current_Ton_Sliding shr 8) +
                                                   Current_Noise) and $1f;
       j := Note + Addition_To_Note;
       if j < 0 then
        j := 0
       else if j > $55 then
        j := $55;
       Ton := (ASM_Table[j] + Ton_Deviation +
                                  Current_Ton_Sliding div 16) and $fff;
       if Ton_Sliding_Counter <> 0 then
        begin
         if shortint(Ton_Sliding_Counter) > 0 then dec(Ton_Sliding_Counter);
         inc(Current_Ton_Sliding,Substruction_for_Ton_Sliding);
        end;
       if Envelope_Enabled and Sample_Says_OK_for_Envelope then
        Amplitude := Amplitude or $10
      end
   end;
  TempMixer := TempMixer shr 1
 end;

begin

if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
   begin
    Real_End := True;
    exit
   end;

with PlParams.ASC do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.ASC_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       with RAM do
        begin
         if Index[Address_In_Pattern] = 255 then
          begin
           Inc(CurrentPosition);
           if CurrentPosition >= ASC1_Number_Of_Positions then
            CurrentPosition := ASC1_LoopingPosition;
           Address_In_Pattern :=
            WordPtr(@Index[ASC1_PatternsPointers +
                  6 * Index[CurrentPosition + 9]])^ + ASC1_PatternsPointers;
           PlParams.ASC_B.Address_In_Pattern :=
            WordPtr(@Index[ASC1_PatternsPointers +
                  6 * Index[CurrentPosition + 9] + 2])^ + ASC1_PatternsPointers;
           PlParams.ASC_C.Address_In_Pattern :=
            WordPtr(@Index[ASC1_PatternsPointers +
                  6 * Index[CurrentPosition + 9] + 4])^ + ASC1_PatternsPointers;
           Initial_Noise := 0;
           PlParams.ASC_B.Initial_Noise := 0;
           PlParams.ASC_C.Initial_Noise := 0
          end;
         PatternInterpreter(PlParams.ASC_A);
        end
     end;
    with PlParams.ASC_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.ASC_B)
     end;
    with PlParams.ASC_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.ASC_C)
     end;
    DelayCounter := Delay
   end
 end;

TempMixer := 0;
GetRegisters(PlParams.ASC_A);
GetRegisters(PlParams.ASC_B);
GetRegisters(PlParams.ASC_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.ASC_A.Ton;
RegisterAY.TonB := PlParams.ASC_B.Ton;
RegisterAY.TonC := PlParams.ASC_C.Ton;

SetAmplA(PlParams.ASC_A.Amplitude);
SetAmplB(PlParams.ASC_B.Amplitude);
SetAmplC(PlParams.ASC_C.Amplitude);

inc(Global_Tick_Counter)

end;

procedure MakeBufferPSC;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 PSC_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure PSC_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:PSC_Channel_Parameters);
 var
  quit:boolean;
  b1b,b2b,b3b,b4b,b5b,b6b,b7b:boolean;

  begin
   quit := False;
   b1b := False;
   b2b := False;
   b3b := False;
   b4b := False;
   b5b := False;
   b6b := False;
   b7b := False;
   with RAM,Chan do
    begin
     repeat
      case Index[Address_In_Pattern] of
      $c0..$ff:
       begin
        Note_Skip_Counter := Index[Address_In_Pattern] - $bf;
        quit := True
       end;
      $a0..$bf:
       begin
        OrnamentPointer := WordPtr(@Index[PSC_OrnamentsPointer +
               (Index[Address_In_Pattern] - $a0) * 2])^;
        if PlParams.PSC.PSC_Version > 3 then
                inc(OrnamentPointer,PSC_OrnamentsPointer);
       end;
      $7e..$9f:
       if Index[Address_In_Pattern] >= $80 then
        begin
         SamplePointer := PSC_SamplesPointers[Index[Address_In_Pattern] - $80];
         if PlParams.PSC.PSC_Version > 3 then inc(SamplePointer,$4c);
        end;
      $6b:
       begin
        Inc(Address_In_Pattern);
        Addition_To_Ton := Index[Address_In_Pattern];
        b5b := True
       end;
      $6c:
       begin
        Inc(Address_In_Pattern);
        Addition_To_Ton := -shortint(Index[Address_In_Pattern]);
        b5b := True
       end;
      $6d:
       begin
        b4b := True;
        Inc(Address_In_Pattern);
        Addition_To_Ton := Index[Address_In_Pattern]
       end;
      $6e:
       begin
        inc(Address_In_Pattern);
        PlParams.PSC.Delay := Index[Address_In_Pattern]
       end;
      $6f:
       begin
        b1b := True;
        Inc(Address_In_Pattern)
       end;
      $70:
       begin
        b3b := True;
        Inc(Address_In_Pattern);
        Volume_Counter1 := Index[Address_In_Pattern]
       end;
      $71:
       begin
        Break_Ornament_Loop := True;
        Inc(Address_In_Pattern)
       end;
      $7a:
       begin
        Inc(Address_In_Pattern);
        if @Chan = @PlParams.PSC_B then
         begin
          SetEnvelopeRegister(Index[Address_In_Pattern] and 15);
          RegisterAY.Envelope := WordPtr(@Index[Address_In_Pattern + 1])^;
          Inc(Address_In_Pattern,2)
         end
       end;
      $7b:
       begin
        Inc(Address_In_Pattern);
        if @Chan = @PlParams.PSC_B then
         PlParams.PSC.Noise_Base := Index[Address_In_Pattern];
       end;
      $7c:
       begin
        b1b := False;
        b2b := True;
        b3b := False;
        b4b := False;
        b5b := False;
        b6b := False;
        b7b := False
       end;
      $7d:
       Break_Sample_Loop := True;
      $58..$66:
       begin
        Initial_Volume := Index[Address_In_Pattern] - $57;
        Envelope_Enabled := False;
        b6b := True
       end;
      $57:
       begin
        Initial_Volume := $f;
        Envelope_Enabled := True;
        b6b := True
       end;
      0..$56:
       begin
        Note := Index[Address_In_Pattern];
        b6b := True;
        b7b := True
       end
      else
       inc(Address_In_Pattern);
      end;
      inc(Address_In_Pattern);
     until quit;
     if b7b then
      begin
       Break_Ornament_Loop := False;
       Ornament_Enabled := True;
       Enabled := True;
       Break_Sample_Loop := False;
       Ton_Slide_Enabled := False;
       Ton_Accumulator := 0;
       Current_Ton_Sliding := 0;
       Noise_Accumulator := 0;
       Volume_Counter := 0;
       Position_In_Sample := 0;
       Position_In_Ornament := 0
      end;
     if b6b then
      Volume := Initial_Volume;
     if b5b then
      begin
       Gliss := False;
       Ton_Slide_Enabled := True
      end;
     if b4b then
      begin
       Current_Ton_Sliding := Ton - ASM_Table[Note];
       Gliss := True;
       if Chan.Current_Ton_Sliding >= 0 then
        Addition_To_Ton := - Addition_To_Ton;
       Ton_Slide_Enabled := True
      end;
     if b3b then
      begin
       Volume_Counter := Volume_Counter1;
       Volume_Inc := True;
       if Volume_Counter and $40 <> 0 then
        begin
         Volume_Counter := -shortint(Volume_Counter or 128);
         Volume_Inc := False
        end;
       Volume_Counter_Init := Volume_Counter
      end;
     if b2b then
      begin
       Break_Ornament_Loop := False;
       Ornament_Enabled := False;
       Enabled := False;
       Break_Sample_Loop := False;
       Ton_Slide_Enabled := False;
      end;
     if b1b then
      Ornament_Enabled := False
    end
 end;

 procedure GetRegisters(var Chan:PSC_Channel_Parameters);
 var
  j,b:byte;
 begin
  with Chan,RAM do
   begin
    if Enabled then
     begin
      j := Note;
      if Ornament_Enabled then
       begin
        b := Index[OrnamentPointer + Position_In_Ornament * 2];
        Inc(Noise_Accumulator,b);
        Inc(j,Index[OrnamentPointer + Position_In_Ornament * 2 + 1]);
        if shortint(j) < 0 then
         inc(j,$56);
        if j > $55 then
         dec(j,$56);
        if j > $55 then
         j := $55;
        if b and 128 = 0 then
         Loop_Ornament_Position := Position_In_Ornament;
        if b and 64 = 0 then
         begin
          if not Break_Ornament_Loop then
           Position_In_Ornament := Loop_Ornament_Position
          else
           begin
            Break_Ornament_Loop := False;
            if b and 32 = 0 then
             Ornament_Enabled := False;
            Inc(Position_In_Ornament)
           end
         end
        else
         begin
          if b and 32 = 0 then
           Ornament_Enabled := False;
           inc(Position_In_Ornament)
         end
       end;
      Note := j;
      Ton := WordPtr(@Index[SamplePointer+Position_In_Sample*6])^;
      Inc(Ton_Accumulator,Ton);
      Ton := ASM_Table[j] + Ton_Accumulator;
      if Ton_Slide_Enabled then
       begin
        Inc(Current_Ton_Sliding,Addition_To_Ton);
        if Gliss and (
          ((Current_Ton_Sliding < 0) and (Addition_To_Ton <= 0)) or
          ((Current_Ton_Sliding >= 0) and (Addition_To_Ton >= 0))) then
         Ton_Slide_Enabled := False;
        Inc(Ton,Current_Ton_Sliding)
       end;
      Ton := Ton and $fff;
      b := Index[SamplePointer + Position_In_Sample * 6 + 4];
      TempMixer := TempMixer or ((b and 9) shl 3);
      j := 0;
      if b and 2 <> 0 then
       inc(j);
      if b and 4 <> 0 then
       dec(j);
      if Volume_Counter > 0 then
       begin
        Dec(Volume_Counter);
        if Volume_Counter = 0 then
         begin
          if Volume_Inc then inc(j) else dec(j);
          Volume_Counter := Volume_Counter_Init
         end
       end;
      Inc(Volume,j);
      if shortint(Volume) < 0 then
       Volume := 0
      else if Volume > 15 then
       Volume := 15;
      Amplitude := ((Volume + 1)*(Index[SamplePointer
                         + Position_In_Sample * 6 + 3] and 15)) shr 4;
      if Envelope_Enabled and (b and 16 = 0) then
       Amplitude := Amplitude or 16;
      if (Amplitude and 16 <> 0) and (b and 8 <> 0) then
       RegisterAY.Envelope := RegisterAY.Envelope + shortint
                   (Index[SamplePointer + Position_In_Sample * 6 + 2])
      else
       begin
        inc(Noise_Accumulator,
          Index[SamplePointer + Position_In_Sample * 6 + 2]);
        if b and 8 = 0 then
         RegisterAY.Noise := Noise_Accumulator and 31
       end;
      if b and 128 = 0 then
       Loop_Sample_Position := Position_In_Sample;
      if b and 64 = 0 then
       begin
        if not Break_Sample_Loop then
         Position_In_Sample := Loop_Sample_Position
        else
         begin
          Break_Sample_Loop := False;
          if b and 32 = 0 then
           Enabled := False;
          inc(Position_In_Sample)
         end
       end
      else
       begin
        if b and 32 = 0 then
         Enabled := False;
        inc(Position_In_Sample)
       end
     end
    else
     Amplitude := 0
   end;
  TempMixer := TempMixer shr 1
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.PSC do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    Dec(Lines_Counter);
    if Lines_Counter = 0 then
     with RAM do
      begin
       if Index[Positions_Pointer + 1] = 255 then
        Positions_Pointer := WordPtr(@Index[Positions_Pointer + 2])^;
       Lines_Counter := Index[Positions_Pointer + 1];
       PlParams.PSC_A.Address_In_Pattern :=
         WordPtr(@Index[Positions_Pointer + 2])^;
       PlParams.PSC_B.Address_In_Pattern :=
         WordPtr(@Index[Positions_Pointer + 4])^;
       PlParams.PSC_C.Address_In_Pattern :=
         WordPtr(@Index[Positions_Pointer + 6])^;
       inc(Positions_Pointer,8);
       PlParams.PSC_A.Note_Skip_Counter := 1;
       PlParams.PSC_B.Note_Skip_Counter := 1;
       PlParams.PSC_C.Note_Skip_Counter := 1
      end;
    with PlParams.PSC_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       PatternInterpreter(PlParams.PSC_A);
     end;
    with PlParams.PSC_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       PatternInterpreter(PlParams.PSC_B);
     end;
    with PlParams.PSC_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       PatternInterpreter(PlParams.PSC_C);
     end;
    Inc(PlParams.PSC_A.Noise_Accumulator,Noise_Base);
    Inc(PlParams.PSC_B.Noise_Accumulator,Noise_Base);
    Inc(PlParams.PSC_C.Noise_Accumulator,Noise_Base);
    DelayCounter := Delay
   end
 end;

TempMixer := 0;
GetRegisters(PlParams.PSC_A);
GetRegisters(PlParams.PSC_B);
GetRegisters(PlParams.PSC_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.PSC_A.Ton;
RegisterAY.TonB := PlParams.PSC_B.Ton;
RegisterAY.TonC := PlParams.PSC_C.Ton;

SetAmplA(PlParams.PSC_A.Amplitude);
SetAmplB(PlParams.PSC_B.Amplitude);
SetAmplC(PlParams.PSC_C.Amplitude);

inc(Global_Tick_Counter)

end;

procedure MakeBufferSQT;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 SQT_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf);
end
end;

procedure SQT_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:SQT_Channel_Parameters);
 var
  Ptr:word;
  Temp:integer;

  procedure Call_LC1D1(a:byte);
  begin
   inc(Ptr);
   with Chan do
    begin
     if b6ix0 then
      begin
       Address_In_Pattern := Ptr + 1;
       b6ix0 := False
      end;
     with RAM do
      case a - 1 of
      0: if b4ix0 then Volume := RAM.Index[Ptr] and 15;
      1: if b4ix0 then Volume := (Volume + Index[Ptr]) and 15;
      2: if b4ix0 then
          begin
           PlParams.SQT_A.Volume := Index[Ptr];
           PlParams.SQT_B.Volume := Index[Ptr];
           PlParams.SQT_C.Volume := Index[Ptr]
          end;
      3: if b4ix0 then
          begin
           with PlParams.SQT_A do
            Volume := (Volume + Index[Ptr]) and 15;
           with PlParams.SQT_B do
            Volume := (Volume + Index[Ptr]) and 15;
           with PlParams.SQT_C do
            Volume := (Volume + Index[Ptr]) and 15
          end;
      4: if b4ix0 then
          with PlParams.SQT do
           begin
            DelayCounter := Index[Ptr] and 31;
            if DelayCounter = 0 then DelayCounter := 32;
            Delay := DelayCounter
           end;
      5: if b4ix0 then
          with PlParams.SQT do
           begin
            DelayCounter := (DelayCounter + Index[Ptr]) and 31;
            if DelayCounter = 0 then DelayCounter := 32;
            Delay := DelayCounter
           end;
      6: begin
          Current_Ton_Sliding := 0;
          Gliss := True;
          Ton_Slide_Step := -Index[Ptr];
         end;
      7: begin
          Current_Ton_Sliding := 0;
          Gliss := True;
          Ton_Slide_Step := Index[Ptr]
         end
      else
         begin
          Envelope_Enabled := True;
          SetEnvelopeRegister((a - 1) and 15);
          RegisterAY.Index[11] := Index[Ptr]
         end
      end
    end
  end;

  procedure Call_LC2A8(a:byte);
  begin
   with Chan do
    begin
     Envelope_Enabled := False;
     Ornament_Enabled := False;
     Gliss := False;
     Enabled := True;
     with RAM do
      SamplePointer := WordPtr(@Index[a * 2 + SQT_SamplesPointer])^;
     Point_In_Sample := SamplePointer + 2;
     Sample_Tik_Counter := 32;
     MixNoise := True;
     MixTon := True
    end
  end;

  procedure Call_LC2D9(a:byte);
  begin
   with Chan do
    begin
     with RAM do
      OrnamentPointer := WordPtr(@Index[a * 2 + SQT_OrnamentsPointer])^;
     Point_In_Ornament := OrnamentPointer + 2;
     Ornament_Tik_Counter := 32;
     Ornament_Enabled := True
    end
  end;

  procedure Call_LC283;
  begin
   with RAM do
    case Index[Ptr] of
    0..$7f:
     Call_LC1D1(Index[Ptr]);
    $80..$ff:
     begin
      if Index[Ptr] shr 1 and 31 <> 0 then
       Call_LC2A8(Index[Ptr] shr 1 and 31);
      if Index[Ptr] and 64 <> 0 then
       begin
        Temp := Index[Ptr+1] shr 4;
        if Index[Ptr] and 1 <> 0 then Temp := Temp or 16;
        if Temp <> 0 then Call_LC2D9(Temp);
        inc(Ptr);
        if Index[Ptr] and 15 <> 0 then
         Call_LC1D1(Index[Ptr] and 15)
       end
     end
    end;
    inc(Ptr)
  end;

  procedure Call_LC191;
  begin
   with Chan do
    begin
     Ptr := ix27;
     b6ix0 := False;
    end;
   with RAM do
    case Index[Ptr] of
    0..$7f:
     begin
      Inc(Ptr);
      Call_LC283
     end;
    $80..$ff:
     Call_LC2A8(Index[Ptr] and 31);
    end
  end;

 begin
  with Chan do
   begin
    if ix21 <> 0 then
     begin
      Dec(ix21);
      if b7ix0 then Call_LC191;
      exit
     end;
    Ptr := Address_In_Pattern;
    b6ix0 := True;
    b7ix0 := False;
    repeat
     with RAM do
      case Index[Ptr] of
      0..$5f:
       begin
        Note := Index[Ptr];
        ix27 := Ptr;
        Inc(Ptr);
        Call_LC283;
        if b6ix0 then Address_In_Pattern := Ptr;
        break
       end;
      $60..$6e:
       begin
        Call_LC1D1(Index[Ptr] - $60);
        break
       end;
      $6f..$7f:
       begin
        MixNoise := False;
        MixTon := False;
        Enabled := False;
        if Index[Ptr] <> $6f then
         Call_LC1D1(RAM.Index[Ptr] - $6f)
        else
         Address_In_Pattern := Ptr + 1;
        break
       end;
      $80..$bf:
       begin
        Address_In_Pattern := Ptr + 1;
        if Index[Ptr] in [$80..$9f] then
         begin
          if Index[Ptr] and 16 = 0 then
           Inc(Note,Index[Ptr] and 15)
          else
           Dec(Note,Index[Ptr] and 15)
         end
        else
         begin
          ix21 := Index[Ptr] and 15;
          if Index[Ptr] and 16 = 0 then break;
          if ix21 <> 0 then b7ix0 := True
         end;
        Call_LC191;
        break
       end;
      $c0..$ff:
       begin
        Address_In_Pattern := Ptr + 1;
        ix27 := Ptr;
        Call_LC2A8(Index[Ptr] and 31);
        break
       end
      end
    until False
   end
 end;

 procedure GetRegisters(var Chan:SQT_Channel_Parameters);
 var
  j,b0,b1:byte;
 begin
  TempMixer := TempMixer shl 1;
  with Chan do
   begin
    if Enabled then
     with RAM do
      begin
       b0 := Index[Point_In_Sample];
       Amplitude := b0 and 15;
       if Amplitude <> 0 then
        begin
         Dec(Amplitude,Volume);
         if shortint(Amplitude) < 0 then Amplitude := 0
        end
       else if Envelope_Enabled then
        Amplitude := 16;
       b1 := Index[Point_In_Sample + 1];
       if b1 and 32 <> 0 then
        begin
         TempMixer := TempMixer or 8;
         RegisterAY.Noise := b0 and $f0 shr 3;
         if shortint(b1) < 0 then
          Inc(RegisterAY.Noise)
        end;
       if b1 and 64 <> 0 then
        TempMixer := TempMixer or 1;
       j := Note;
       if Ornament_Enabled then
        begin
         inc(j,Index[Point_In_Ornament]);
         Dec(Ornament_Tik_Counter);
         if Ornament_Tik_Counter = 0 then
          begin
           if Index[OrnamentPointer] <> 32 then
            begin
             Ornament_Tik_Counter := Index[OrnamentPointer + 1];
             Point_In_Ornament := OrnamentPointer + 2 + Index[OrnamentPointer];
            end
           else
            begin
             Ornament_Tik_Counter := Index[SamplePointer + 1];
             Point_In_Ornament := OrnamentPointer + 2 + Index[SamplePointer];
            end
          end
         else
          inc(Point_In_Ornament)
        end;
       Inc(j,Transposit);
       if j > $5F then j := $5f;
       if b1 and 16 = 0 then
        Ton := SQT_Table[j] - (word(b1 and 15) shl 8 +
                                             Index[Point_In_Sample + 2])
       else
        Ton := SQT_Table[j] + (word(b1 and 15) shl 8 +
                                             Index[Point_In_Sample + 2]);
       Dec(Sample_Tik_Counter);
       if Sample_Tik_Counter = 0 then
        begin
         Sample_Tik_Counter := Index[SamplePointer + 1];
         if Index[SamplePointer] = 32 then
          begin
           Enabled := False;
           Ornament_Enabled := False
          end;
         Point_In_Sample := SamplePointer + 2 + Index[SamplePointer] * 3
        end
       else
        inc(Point_In_Sample,3);
       if Gliss then
        begin
         Inc(Ton,Current_Ton_Sliding);
         Inc(Current_Ton_Sliding,Ton_Slide_Step)
        end;
       Ton := Ton and $fff
      end
    else
     Amplitude := 0
   end
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.SQT do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    DelayCounter := Delay;
    Dec(Lines_Counter);
    if Lines_Counter = 0 then
     with RAM do
      begin
       if Index[Positions_Pointer] = 0 then
        Positions_Pointer := SQT_LoopPointer;
       with PlParams.SQT_C do
        begin
         if shortint(Index[Positions_Pointer]) < 0 then
          b4ix0 := True
         else
          b4ix0 := False;
         Address_In_Pattern := WordPtr(@Index[
                  byte(Index[Positions_Pointer] * 2) + SQT_PatternsPointer])^;
         Lines_Counter := Index[Address_In_Pattern];
         Inc(Address_In_Pattern);
         Inc(Positions_Pointer);
         Volume := Index[Positions_Pointer] and 15;
         if Index[Positions_Pointer] shr 4 < 9 then
          Transposit := Index[Positions_Pointer] shr 4
         else
          Transposit := -(Index[Positions_Pointer] shr 4 - 9) - 1;
         Inc(Positions_Pointer);
         ix21:=0
        end;

       if Index[Positions_Pointer] = 0 then
        Positions_Pointer := SQT_LoopPointer;
       with PlParams.SQT_B do
        begin
         if shortint(Index[Positions_Pointer]) < 0 then
          b4ix0 := True
         else
          b4ix0 := False;
         Address_In_Pattern := WordPtr(@Index[
               byte(Index[Positions_Pointer] * 2) + SQT_PatternsPointer])^ + 1;
         Inc(Positions_Pointer);
         Volume := Index[Positions_Pointer] and 15;
         if Index[Positions_Pointer] shr 4 < 9 then
          Transposit := Index[Positions_Pointer] shr 4
         else
          Transposit := -(Index[Positions_Pointer] shr 4 - 9) - 1;
         Inc(Positions_Pointer);
         ix21:=0
        end;

       if Index[Positions_Pointer] = 0 then
        Positions_Pointer := SQT_LoopPointer;
       with PlParams.SQT_A do
        begin
         if shortint(Index[Positions_Pointer]) < 0 then
          b4ix0 := True
         else
          b4ix0 := False;
         Address_In_Pattern := WordPtr(@Index[
               byte(Index[Positions_Pointer] * 2) + SQT_PatternsPointer])^ + 1;
         Inc(Positions_Pointer);
         Volume := Index[Positions_Pointer] and 15;
         if Index[Positions_Pointer] shr 4 < 9 then
          Transposit := Index[Positions_Pointer] shr 4
         else
          Transposit := -(Index[Positions_Pointer] shr 4 - 9) - 1;
         Inc(Positions_Pointer);
         ix21:=0
        end;

      Delay := Index[Positions_Pointer];
      DelayCounter := Delay;
      Inc(Positions_Pointer);

     end;
    PatternInterpreter(PlParams.SQT_C);
    PatternInterpreter(PlParams.SQT_B);
    PatternInterpreter(PlParams.SQT_A)
   end
 end;
TempMixer := 0;
GetRegisters(PlParams.SQT_C);
GetRegisters(PlParams.SQT_B);
GetRegisters(PlParams.SQT_A);
TempMixer := (-(TempMixer + 1)) and $3f;

with PlParams.SQT_A do
 begin
  if not MixNoise then TempMixer := TempMixer or 8;
  if not MixTon then TempMixer := TempMixer or 1
 end;
with PlParams.SQT_B do
 begin
  if not MixNoise then TempMixer := TempMixer or 16;
  if not MixTon then TempMixer := TempMixer or 2
 end;
with PlParams.SQT_C do
 begin
  if not MixNoise then TempMixer := TempMixer or 32;
  if not MixTon then TempMixer := TempMixer or 4
 end;
SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.SQT_A.Ton;
RegisterAY.TonB := PlParams.SQT_B.Ton;
RegisterAY.TonC := PlParams.SQT_C.Ton;

SetAmplA(PlParams.SQT_A.Amplitude);
SetAmplB(PlParams.SQT_B.Amplitude);
SetAmplC(PlParams.SQT_C.Amplitude);

Inc(Global_Tick_Counter)

end;

procedure MakeBufferFTC;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 FTC_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure FTC_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:FTC_Channel_Parameters);
 var
  quit:boolean;
  ExxAF:shortint;
 begin
  quit := False;
  EXXAF := 2;
  with Chan do
   begin
    repeat
     with RAM do
      case Index[Address_In_Pattern] of
      0..$1f:
       begin
        SamplePointer := FTC_SamplesPointers[Index[Address_In_Pattern]];
        Inc(SamplePointer);
        Loop_Sample_Position := Index[SamplePointer];
        Inc(SamplePointer);
        Sample_Length := Index[SamplePointer] + 1;
        Inc(SamplePointer)
       end;
      $20..$2f:
       Volume := Index[Address_In_Pattern] - $20;
      $30:
       begin
        Sample_Enabled := False;
        Position_In_Sample := 0;
        Sample_Noise_Accumulator:=0;
        Volume_Slide := 0;
        Noise_Accumulator := 0;
        Note_Accumulator := 0;
        Position_In_Ornament := 0;
        Ton_Accumulator := 0;
        Envelope_Accumulator := 0;
        if EXXAF > 0 then
         begin
          Current_Ton_Sliding := 0;
          Ton_Slide_Direction := 0
         end;
        if EXXAF > 1 then Ton_Slide_Step := 0;
        Note_Skip_Counter := 0;
        quit := True
       end;
      $31..$3e:
       begin
        SetEnvelopeRegister(Index[Address_In_Pattern] - $30);
        Envelope_Enabled := True;
        Inc(Address_In_Pattern);
        Envelope := WordPtr(@Index[Chan.Address_In_Pattern])^;
        Inc(Chan.Address_In_Pattern);
       end;
      $3f:
       Envelope_Enabled := False;
      $40..$5f:
       begin
        Note_Skip_Counter := Index[Address_In_Pattern] - $40;
        EXXAF := 1;
        quit := True
       end;
      $60..$cb:
       begin
        Previous_Note := Note;
        Note := PlParams.FTC.Transposition +
                                  Index[Chan.Address_In_Pattern] - $60;
        Sample_Enabled := True;
        Position_In_Sample := 0;
        Sample_Noise_Accumulator := 0;
        Volume_Slide := 0;
        Noise_Accumulator := 0;
        Note_Accumulator := 0;
        Position_In_Ornament := 0;
        Ton_Accumulator := 0;
        Envelope_Accumulator := 0;
        if EXXAF > 0 then
         begin
          Current_Ton_Sliding := 0;
          Ton_Slide_Direction := 0
         end;
        if EXXAF > 1 then Ton_Slide_Step := 0;
        Note_Skip_Counter := 0;
        quit := True
       end;
      $cc..$ec:
       begin
        OrnamentPointer := FTC_OrnamentsPointers[
                                        Index[Address_In_Pattern] - $cc];
        Inc(OrnamentPointer);
        Loop_Ornament_Position := Index[OrnamentPointer];
        Inc(OrnamentPointer);
        Ornament_Length := Index[OrnamentPointer] + 1;
        Inc(OrnamentPointer);
        Position_In_Ornament := 0;
        Noise_Accumulator := 0;
        Note_Accumulator := 0
       end;
      $ed:
       begin
        EXXAF := 1;
        Inc(Address_In_Pattern);
        Ton_Slide_Step := WordPtr(@Index[Chan.Address_In_Pattern])^;
        Inc(Address_In_Pattern);
       end;
      $ee:
       begin
        EXXAF := 0;
        Inc(Address_In_Pattern);
        Ton_Slide_Step1 := Index[Address_In_Pattern]
       end;
      $ef:
       begin
        Inc(Address_In_Pattern);
        Noise := Index[Address_In_Pattern]
       end
      else
       begin
        Inc(Address_In_Pattern);
        PlParams.FTC.Delay := Index[Address_In_Pattern]
       end
      end;
     Inc(Address_In_Pattern)
    until quit;
    if exxaf = 0 then
     begin
      Current_Ton_Sliding := PT3NoteTable_ST[Previous_Note] - PT3NoteTable_ST[Note];
      if Current_Ton_Sliding < 0 then
       begin
        Ton_Slide_Step := Ton_Slide_Step1;
        Ton_Slide_Direction := 1
       end
      else
       begin
        Ton_Slide_Step := -Ton_Slide_Step1;
        Ton_Slide_Direction := 2
       end
     end
   end
 end;

 procedure GetRegisters(var Chan:FTC_Channel_Parameters);
 var
  j,b:byte;
  k:word;
  Add_To_Note,Add_To_Noise:byte;
 begin
  with Chan,RAM do
   begin
    Add_To_Note := Note_Accumulator +
                Index[OrnamentPointer + Position_In_Ornament * 2 + 1];
    b := Index[OrnamentPointer + Position_In_Ornament * 2];
    if b and 64 <> 0 then
     Note_Accumulator := Add_To_Note;
    Add_To_Noise := Noise_Accumulator + b;
    if shortint(b) < 0 then
     Noise_Accumulator := Add_To_Noise;
    Inc(Position_In_Ornament);
    if Position_In_Ornament = Ornament_Length then
     Position_In_Ornament := Loop_Ornament_Position;
    if Sample_Enabled then
     begin
      b := Index[SamplePointer + Position_In_Sample * 5];
      j := Sample_Noise_Accumulator + b;
      if shortint(b) < 0 then
       Sample_Noise_Accumulator := j;
      if b and 64 = 0 then
       RegisterAY.Noise := (j + Noise + Add_To_Noise) and 31
      else
       TempMixer := TempMixer or 64;
      k := Ton_Accumulator +
                        WordPtr(@Index[SamplePointer+Position_In_Sample*5+1])^;
      b := Index[SamplePointer + Position_In_Sample * 5 + 2];
      if shortint(b) < 0 then
       Ton_Accumulator := k;
      Addition_To_Ton := k;
      if b and 64 <> 0 then
       TempMixer := TempMixer or 8;
      b := Index[SamplePointer + Position_In_Sample * 5 + 3];
      if b and 32 <> 0 then
       if b and 16 <> 0 then
        begin
         Dec(Volume_Slide);
         if Volume_Slide < -15 then Volume_Slide := -15
        end
       else
        begin
         Inc(Volume_Slide);
         if Volume_Slide > 15 then Volume_Slide := 15
        end;
      j := Volume_Slide + b and 15;
      if shortint(j) < 0 then j := 0 else if j > 15 then j := 15;
      Amplitude := round((Volume * 17 + byte(Volume > 7)) * j / 256);
      k := Envelope_Accumulator +
               shortint(Index[SamplePointer + Position_In_Sample * 5 + 4]);
      if shortint(b) < 0 then
       Envelope_Accumulator := k;
      if (b and 64 <> 0)and Envelope_Enabled then
       begin
        RegisterAY.Envelope := Envelope - k;
        Amplitude := Amplitude or 16;
       end;
      Inc(Position_In_Sample);
      if Position_In_Sample = Sample_Length then
       Position_In_Sample := Loop_Sample_Position
     end
    else
     begin
      Amplitude := 0;
      TempMixer:= TempMixer or 72
     end;
    j := Note + Add_To_Note;
    if j > $5F then j := $5F;
    Ton := PT3NoteTable_ST[j] + Addition_To_Ton;
    Inc(Current_Ton_Sliding,Ton_Slide_Step);
    if ((Ton_Slide_Direction = 1) and (Current_Ton_Sliding >= 0)) or
       ((Ton_Slide_Direction = 2) and (Current_Ton_Sliding < 0)) then
     begin
      Current_Ton_Sliding := 0;
      Ton_Slide_Step := 0
     end
    else
     Inc(Ton,Current_Ton_Sliding);
    Ton := Ton and $fff
   end;
  TempMixer := TempMixer shr 1
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.FTC do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.FTC_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       begin
        with RAM do
         if Index[Address_In_Pattern] = 255 then
          begin
           Inc(CurrentPosition);
           if FTC_Positions[CurrentPosition].Pattern = 255 then
            CurrentPosition := FTC_Loop_Position;
           Transposition := FTC_Positions[CurrentPosition].Transposition;
           Address_In_Pattern :=
            WordPtr(@Index[FTC_PatternsPointer +
                           FTC_Positions[CurrentPosition].Pattern * 6])^;
           PlParams.FTC_B.Address_In_Pattern :=
            WordPtr(@Index[FTC_PatternsPointer +
                           FTC_Positions[CurrentPosition].Pattern * 6 + 2])^;
           PlParams.FTC_C.Address_In_Pattern :=
            WordPtr(@Index[FTC_PatternsPointer +
                           FTC_Positions[CurrentPosition].Pattern * 6 + 4])^;
          end;
        PatternInterpreter(PlParams.FTC_A)
       end
     end;
    with PlParams.FTC_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.FTC_B)
     end;
    with PlParams.FTC_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.FTC_C)
     end;
    DelayCounter := Delay
   end
 end;

TempMixer := 0;
GetRegisters(PlParams.FTC_A);
GetRegisters(PlParams.FTC_B);
GetRegisters(PlParams.FTC_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.FTC_A.Ton;
RegisterAY.TonB := PlParams.FTC_B.Ton;
RegisterAY.TonC := PlParams.FTC_C.Ton;

SetAmplA(PlParams.FTC_A.Amplitude);
SetAmplB(PlParams.FTC_B.Amplitude);
SetAmplC(PlParams.FTC_C.Amplitude);

Inc(Global_Tick_Counter)

end;

procedure MakeBufferPT1;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 PT1_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf);
end
end;

procedure PT1_Get_Registers;
var
 TempMixer:integer;

 procedure PatternInterpreter(var Chan:PT1_Channel_Parameters);
 var
  quit:boolean;
 begin
  quit := False;
  with Chan do
   begin
    repeat
     with RAM do
      case Index[Address_In_Pattern] of
      0..$5f:
       begin
        Note := Index[Address_In_Pattern];
        Enabled := True;
        Position_In_Sample := 0;
        quit := True
       end;
      $60..$6f:
       begin
        SamplePointer := PT1_SamplesPointers[Index[Address_In_Pattern] - $60];
        Sample_Length := Index[SamplePointer];
        Inc(SamplePointer);
        Loop_Sample_Position := Index[SamplePointer];
        Inc(SamplePointer)
       end;
      $70..$7f:
       OrnamentPointer := PT1_OrnamentsPointers[
                                Index[Address_In_Pattern] - $70];
      $80:
       begin
        Enabled := False;
        quit := True
       end;
      $81:
       Envelope_Enabled := False;
      $82..$8f:
       begin
        Envelope_Enabled := True;
        SetEnvelopeRegister(Index[Address_In_Pattern] - $81);
        Inc(Address_In_Pattern);
        RegisterAY.Envelope := WordPtr(@Index[Address_In_Pattern])^;
        Inc(Address_In_Pattern)
       end;
      $90:
       quit := True;
      $91..$a0:
       PlParams.PT1.Delay := Index[Address_In_Pattern] - $91;
      $a1..$b0:
       Volume := Index[Address_In_Pattern] - $a1;
      else
       Number_Of_Notes_To_Skip := Index[Address_In_Pattern] - $b1;
      end;
      Inc(Address_In_Pattern)
    until quit;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end
 end;

 procedure GetRegisters(var Chan:PT1_Channel_Parameters);
 var
  j,b:byte;
 begin
  with Chan do
   if Enabled then
    with RAM do
     begin
      j := Note + Index[OrnamentPointer + Position_In_Sample];
      if j > 95 then j := 95;
      b := Index[SamplePointer + Position_In_Sample * 3];
      Ton := word(b) shl 4 and $f00 +
                        Index[SamplePointer + Position_In_Sample * 3 + 2];
      Amplitude := round((Volume * 17 + byte(Volume > 7)) * (b and 15) / 256);
      b := Index[SamplePointer + Position_In_Sample * 3 + 1];
      if b and 32 = 0 then Ton := -Ton;
      Ton := (Ton + PT3NoteTable_ST[j] + word(j = 46)) and $fff;
      if Envelope_Enabled then Amplitude := Amplitude or 16;
      if shortint(b) < 0 then
       TempMixer := TempMixer or 64
      else
       RegisterAY.Noise := b and 31;
      if b and 64 <> 0 then
       TempMixer := TempMixer or 8;
      Inc(Position_In_Sample);
      if Position_In_Sample = Sample_Length then
       Position_In_Sample := Loop_Sample_Position
     end
    else
     Amplitude := 0;
   TempMixer := TempMixer shr 1;
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.PT1 do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.PT1_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       begin
        with RAM do
         if (Index[Address_In_Pattern] = 255) then
          begin
           Inc(CurrentPosition);
           if CurrentPosition = PT1_NumberOfPositions then
            CurrentPosition := PT1_LoopPosition;
           Address_In_Pattern :=
            WordPtr(@Index[PT1_PatternsPointer +
                                PT1_PositionList[CurrentPosition] * 6])^;
           PlParams.PT1_B.Address_In_Pattern :=
            WordPtr(@Index[PT1_PatternsPointer +
                                PT1_PositionList[CurrentPosition] * 6 + 2])^;
           PlParams.PT1_C.Address_In_Pattern :=
            WordPtr(@Index[PT1_PatternsPointer +
                                PT1_PositionList[CurrentPosition] * 6 + 4])^
          end;
        PatternInterpreter(PlParams.PT1_A)
       end
     end;
    with PlParams.PT1_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.PT1_B)
     end;
    with PlParams.PT1_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.PT1_C)
     end;
    DelayCounter := Delay
   end
 end;

TempMixer := 0;
GetRegisters(PlParams.PT1_A);
GetRegisters(PlParams.PT1_B);
GetRegisters(PlParams.PT1_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.PT1_A.Ton;
RegisterAY.TonB := PlParams.PT1_B.Ton;
RegisterAY.TonC := PlParams.PT1_C.Ton;

SetAmplA(PlParams.PT1_A.Amplitude);
SetAmplB(PlParams.PT1_B.Amplitude);
SetAmplC(PlParams.PT1_C.Amplitude);

inc(Global_Tick_Counter)

end;

procedure MakeBufferFLS;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 FLS_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure FLS_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:FLS_Channel_Parameters);
 var
  quit:boolean;
 begin
  quit := False;
  with Chan do
   begin
    repeat
     with RAM do
      case Index[Address_In_Pattern] of
      0..$5f:
       begin
        Note := Index[Address_In_Pattern];
        Position_In_Sample := 0;
        Sample_Tik_Counter := $20;
        quit := True
       end;
      $60..$6f:
       begin
        Loop_Sample_Position := Index[FLS_SamplesPointer +
                                  (Index[Address_In_Pattern] - $60) * 4];
        Sample_Length := Index[FLS_SamplesPointer +
                                  (Index[Address_In_Pattern] - $60) * 4 + 1];
        SamplePointer := WordPtr(@Index[FLS_SamplesPointer +
                                  (Index[Address_In_Pattern] - $60) * 4 + 2])^
       end;
      $70:
       begin
        Ornament_Enabled := False;
        Envelope_Enabled := False
       end;
      $71..$7f:
       begin
        OrnamentPointer := WordPtr(@Index[FLS_OrnamentsPointer+
                                  (Index[Address_In_Pattern] - $71) * 2])^;
        Ornament_Enabled := True;
        Envelope_Enabled := False
       end;
      $80:
       begin
        Sample_Tik_Counter := -1;
        quit := True
       end;
      $81:
       quit := True;
      $82..$8e:
       begin
        SetEnvelopeRegister(Index[Address_In_Pattern] - $80);
        Envelope_Enabled := True;
        Ornament_Enabled := False;
        Inc(Address_In_Pattern);
        RegisterAY.Index[11] := Index[Address_In_Pattern]
       end
      else
       Number_Of_Notes_To_Skip := Index[Address_In_Pattern] - $a1
      end;
     Inc(Address_In_Pattern)
    until quit;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end
 end;

 procedure GetRegisters(var Chan:FLS_Channel_Parameters);
 var
  j,b0,b1:byte;
 begin
  with Chan,RAM do
   begin
    if Sample_Tik_Counter >= 0 then
     begin
      Dec(Sample_Tik_Counter);
      if Sample_Tik_Counter = 0 then
       if Loop_Sample_Position = 0 then
        begin
         Dec(Sample_Tik_Counter);
         Amplitude := 0;
         TempMixer := TempMixer shr 1;
         exit
        end
       else
        begin
         Sample_Tik_Counter := Sample_Length;
         Position_In_Sample := Loop_Sample_Position - 1;
        end;
      b0 := Index[SamplePointer + Position_In_Sample * 3];
      b1 := Index[SamplePointer + Position_In_Sample * 3 + 1];
      Amplitude := b0 and 15;
      if Envelope_Enabled then Amplitude := Amplitude or 16;
      if shortint(b1) < 0 then
       TempMixer := TempMixer or 64
      else
       RegisterAY.Noise := b1 and 31;
      if b1 and 64 <> 0 then
       TempMixer := TempMixer or 8;
      if Ornament_Enabled then
       j := Index[OrnamentPointer + Position_In_Sample]
      else
       j := 0;
      Inc(j,Note);
      if j > $5F then j := $5F;
      Ton := word(b0) shl 4 and $f00 +
                  Index[SamplePointer + Position_In_Sample * 3 + 2];
      if b1 and 32 = 0 then
       Ton := -Ton;
      Ton := (Ton + ST_Table[j]) and $fff;
      Position_In_Sample := (Position_In_Sample + 1) and 31
     end
    else
     Amplitude := 0;
    TempMixer := TempMixer shr 1
   end
 end;

begin
if Global_Tick_Counter>=Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter:=Global_Tick_Max
 else
  begin
  Real_End:=true;
  exit;
  end;
with PlParams.FLS do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.FLS_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       with RAM do
        begin
         if Index[Address_In_Pattern] = 255 then
          begin
           Inc(CurrentPosition);
           if Index[CurrentPosition + FLS_PositionsPointer + 1] = 0 then
            CurrentPosition := 0;
           Address_In_Pattern :=
            FLS_PatternsPointers[
                 Index[CurrentPosition + FLS_PositionsPointer + 1]].PatternA;
           PlParams.FLS_B.Address_In_Pattern :=
            FLS_PatternsPointers[
                 Index[CurrentPosition + FLS_PositionsPointer + 1]].PatternB;
           PlParams.FLS_C.Address_In_Pattern :=
            FLS_PatternsPointers[
                 Index[CurrentPosition + FLS_PositionsPointer + 1]].PatternC;
          end;
         PatternInterpreter(PlParams.FLS_A)
        end;
     end;
    with PlParams.FLS_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.FLS_B)
     end;
    with PlParams.FLS_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.FLS_C)
     end;
    DelayCounter := Delay
   end
 end;
  
TempMixer := 0;
GetRegisters(PlParams.FLS_A);
GetRegisters(PlParams.FLS_B);
GetRegisters(PlParams.FLS_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.FLS_A.Ton;
RegisterAY.TonB := PlParams.FLS_B.Ton;
RegisterAY.TonC := PlParams.FLS_C.Ton;

SetAmplA(PlParams.FLS_A.Amplitude);
SetAmplB(PlParams.FLS_B.Amplitude);
SetAmplC(PlParams.FLS_C.Amplitude);

inc(Global_Tick_Counter)

end;

procedure MakeBufferGTR;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 GTR_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure GTR_Get_Registers;
var
 TempMixer:byte;

 procedure PatternInterpreter(var Chan:GTR_Channel_Parameters);
 begin
  with Chan do
   begin
    Note_Skip_Counter := 0;
    repeat
     with RAM do
      case Index[Address_In_Pattern] of
      0..$5f:
       begin
        Note := Index[Address_In_Pattern];
        Position_In_Sample := 0;
        Position_In_Ornament := 0;
        Enabled := True;
        Inc(Address_In_Pattern);
        exit
       end;
      $60..$6f:
       begin
        SamplePointer := GTR_SamplesPointers[Index[Address_In_Pattern] - $60];
        Loop_Sample_Position := Index[Chan.SamplePointer];
        Inc(SamplePointer);
        Sample_Length := Index[SamplePointer];
        Inc(SamplePointer)
       end;
      $70..$7F:
       begin
        OrnamentPointer :=
                GTR_OrnamentsPointers[Index[Address_In_Pattern] - $70];
        Loop_Ornament_Position := Index[Chan.OrnamentPointer];
        Inc(Chan.OrnamentPointer);
        Ornament_Length := Index[Chan.OrnamentPointer];
        Inc(OrnamentPointer);
        Position_In_Ornament := 0;
        if GTR_ID[3] <> #$10 then
         Envelope_Enabled := False
       end;
      $80..$BF:
       Note_Skip_Counter := Index[Address_In_Pattern] - $80;
      $C0..$CF:
       begin
        SetEnvelopeRegister(Index[Address_In_Pattern] - $C0);
        Inc(Address_In_Pattern);
        RegisterAY.Index[11] := Index[Address_In_Pattern];
        Envelope_Enabled := True
       end;
      $D0..$DF:
       begin
        Inc(Address_In_Pattern);
        exit
       end;
      $E0:
       begin
        Enabled := False;
        if GTR_ID[3] <> #$10 then
         begin
          Inc(Address_In_Pattern);
          exit
         end
       end;
      $E1..$EF:
       Volume := 15 - (Index[Address_In_Pattern] - $E0)
      end;
     Inc(Address_In_Pattern)
    until False
   end 
 end;

 procedure GetRegisters(var Chan:GTR_Channel_Parameters);
 var
  j,b:byte;
 begin
  with Chan do
   begin
    if Enabled then
     with RAM do
      begin
       j := Note + Index[OrnamentPointer + Position_In_Ornament];
       if j > $5f then j := $5f;
       Inc(Position_In_Ornament);
       if Position_In_Ornament = Ornament_Length then
        Position_In_Ornament := Loop_Ornament_Position;
       Ton := (PT3NoteTable_ST[j] +
        WordPtr(@Index[SamplePointer + Position_In_Sample + 2])^) and $FFF;
       b := Index[SamplePointer + Position_In_Sample + 1];
       RegisterAY.Noise := (RegisterAY.Noise or b) and $1F;
       Amplitude := Index[SamplePointer + Position_In_Sample] - Volume;
       if ShortInt(Amplitude) < 0 then Amplitude := 0;
       Amplitude := Amplitude and $F;
       if shortint(b) < 0 then
        if Envelope_Enabled then Amplitude := Amplitude or 16;
       if b and 64 <> 0 then
        TempMixer := TempMixer or 64;
       if b and 32 <> 0 then
        TempMixer := TempMixer or 8;
       Inc(Position_In_Sample,4);
       if Position_In_Sample = Sample_Length then
        Position_In_Sample := Loop_Sample_Position
      end
    else
     begin
      Amplitude := 0;
      TempMixer := TempMixer or 8 or 64
     end
   end;
  TempMixer := TempMixer shr 1
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
with PlParams.GTR do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    DelayCounter := RAM.GTR_Delay;
    with PlParams.GTR_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       begin
        with RAM do
         while Index[Address_In_Pattern] = 255 do
          begin
           Inc(CurrentPosition);
           if CurrentPosition = GTR_NumberOfPositions then
            CurrentPosition := GTR_LoopPosition;
           Address_In_Pattern := GTR_PatternsPointers[
                GTR_Positions[CurrentPosition] div 6].PatternA;
           PlParams.GTR_B.Address_In_Pattern :=
            GTR_PatternsPointers[GTR_Positions[CurrentPosition] div 6].PatternB;
           PlParams.GTR_C.Address_In_Pattern :=
            GTR_PatternsPointers[GTR_Positions[CurrentPosition] div 6].PatternC
          end;
        PatternInterpreter(PlParams.GTR_A)
       end
     end;
    with PlParams.GTR_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.GTR_B)
     end;
    with PlParams.GTR_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter < 0 then
       PatternInterpreter(PlParams.GTR_C)
     end
   end
 end;

TempMixer := 0;
RegisterAY.Noise := 0;
GetRegisters(PlParams.GTR_A);
GetRegisters(PlParams.GTR_B);
GetRegisters(PlParams.GTR_C);

SetMixerRegister(TempMixer);

RegisterAY.TonA := PlParams.GTR_A.Ton;
RegisterAY.TonB := PlParams.GTR_B.Ton;
RegisterAY.TonC := PlParams.GTR_C.Ton;

SetAmplA(PlParams.GTR_A.Amplitude);
SetAmplB(PlParams.GTR_B.Amplitude);
SetAmplC(PlParams.GTR_C.Amplitude);

Inc(Global_Tick_Counter)

end;

procedure MakeBufferFXM;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 FXM_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf);
end
end;

procedure FXM_Get_Registers;

 procedure RealGetRegisters(var Chan:FXM_Channel_Parameters);
 begin
  RegisterAY.Noise := PlParams.FXM.Noise_Base and 31;
  with Chan do
   begin
    b2e := False;
    if Ton <> 0 then
     Amplitude := Volume and 15
    else
     Amplitude := 0
   end
 end;

 procedure GetRegisters(var Chan:FXM_Channel_Parameters);
 var
  b:byte;
 begin
  with Chan do
   begin
    Dec(Sample_Tik_Counter);
    if Sample_Tik_Counter = 0 then
     begin
      repeat
       with RAM do
        case Index[Chan.Point_In_Sample] of
        0..$1D:
         begin
          Volume := Index[Point_In_Sample];
          Inc(Point_In_Sample);
          Sample_Tik_Counter := Index[Point_In_Sample];
          Inc(Point_In_Sample);
          break
         end;
        $80:
         Point_In_Sample := WordPtr(@Index[Point_In_Sample + 1])^
        else
         begin
          Volume := Index[Point_In_Sample] - $32;
          Inc(Point_In_Sample);
          Sample_Tik_Counter := 1;
          break
         end;
        end
      until False;
     end;
    if (Ton <> 0) and not b2e then
     begin
      repeat
       with RAM do
        case Index[Point_In_Ornament] of
        $80:
         Point_In_Ornament := WordPtr(@Index[Point_In_Ornament + 1])^;
        $82:
         begin
          Inc(Point_In_Ornament);
          b3e := True
         end;
        $83:
         begin
          Inc(Chan.Point_In_Ornament);
          b3e := False
         end;
        $84:
         begin
          Inc(Point_In_Ornament);
          FXM_Mixer := FXM_Mixer xor 9;
         end
        else
         begin
          if b3e then
           begin
            Inc(Note,Index[Point_In_Ornament]);
            if Note > $53 then b := $53 else b := Note;
            Ton := FXM_Table[b]
           end
          else
           Inc(Ton,shortint(Index[Point_In_Ornament]));
          Inc(Point_In_Ornament);
          break
         end
        end;
      until False
     end
   end;
  RealGetRegisters(Chan)
 end;

 procedure PatternInterpreter(var Chan:FXM_Channel_Parameters; var Stek:FXM_Stek);
 var
  b:byte;
  i:integer;
 begin
  with Chan do
   begin
    Dec(Note_Skip_Counter);
    if Note_Skip_Counter <> 0 then
     GetRegisters(Chan)
    else
     repeat
      with RAM do
       case Index[Address_In_Pattern] of
       0..$7F:
        begin
         if Index[Address_In_Pattern] <> 0 then
          begin
           Note := Index[Address_In_Pattern] - 1 + Transposit;
           if Note > $53 then b := $53 else b := Note;
           Ton := FXM_Table[b];
           b3e := False
          end
         else
          Ton := 0;
         Inc(Address_In_Pattern);
         Note_Skip_Counter := Index[Address_In_Pattern];
         Inc(Address_In_Pattern);
         Point_In_Ornament := OrnamentPointer;
         if not b1e then
          begin
           b1e := b0e;
           Point_In_Sample := SamplePointer;
           Volume := Index[Point_In_Sample];
           Inc(Point_In_Sample);
           Sample_Tik_Counter := Index[Point_In_Sample];
           Inc(Point_In_Sample);
           RealGetRegisters(Chan)
          end
         else
          GetRegisters(Chan);
         exit
        end;
       $80:
        Address_In_Pattern := WordPtr(@Index[Address_In_Pattern + 1])^;
       $81:
        begin
         i := Length(Stek);
         SetLength(Stek,i + 1);
         Stek[i] := Address_In_Pattern + 3;
         Address_In_Pattern := WordPtr(@Index[Address_In_Pattern + 1])^
        end;
       $82:
        begin
         i := Length(Stek);
         SetLength(Stek,i + 2);
         Inc(Address_In_Pattern);
         Stek[i] := Index[Address_In_Pattern];
         Inc(Address_In_Pattern);
         Stek[i + 1] := Address_In_Pattern
        end;
       $83:
        begin
         i := Length(Stek);
         Dec(Stek[i - 2]);
         if Stek[i - 2] and 255 <> 0 then
          Address_In_Pattern := Stek[i - 1]
         else
          begin
           SetLength(Stek,i - 2);
           Inc(Address_In_Pattern)
          end
        end;
       $84:
        begin
         Inc(Address_In_Pattern);
         PlParams.FXM.Noise_Base := Index[Address_In_Pattern];
         Inc(Address_In_Pattern)
        end;
       $85:
        begin
         Inc(Address_In_Pattern);
         FXM_Mixer := Index[Address_In_Pattern];
         Inc(Address_In_Pattern)
        end;
       $86:
        begin
         Inc(Address_In_Pattern);
         OrnamentPointer := WordPtr(@Index[Address_In_Pattern])^;
         Inc(Address_In_Pattern,2)
        end;
       $87:
        begin
         Inc(Address_In_Pattern);
         SamplePointer := WordPtr(@Index[Address_In_Pattern])^;
         Inc(Address_In_Pattern,2)
        end;
       $88:
        begin
         Inc(Address_In_Pattern);
         Transposit := Index[Address_In_Pattern];
         Inc(Address_In_Pattern)
        end;
       $89:
        begin
         i := Length(Stek);
         Address_In_Pattern := Stek[i - 1];
         SetLength(Stek,i - 1)
        end;
       $8A:
        begin
         Inc(Address_In_Pattern);
         b0e := True;
         b1e := False
        end;
       $8B:
        begin
         Inc(Address_In_Pattern);
         b0e := False;
         b1e := False
        end;
       $8C:
        Inc(Chan.Address_In_Pattern,3);
       $8D:
        begin
         Inc(Address_In_Pattern);
         PlParams.FXM.Noise_Base :=
         (PlParams.FXM.Noise_Base + Index[Address_In_Pattern])
                                  and PlParams.FXM.amad_andsix;
         Inc(Address_In_Pattern)
        end;
       $8E:
        begin
         Inc(Address_In_Pattern);
         Transposit := Transposit + Index[Address_In_Pattern];
         Inc(Address_In_Pattern)
        end;
       $8F:
        begin
         i := Length(Stek);
         SetLength(Stek,i + 1);
         Stek[i] := Transposit;
         Inc(Address_In_Pattern)
        end;
       $90:
        begin
         i := Length(Stek);
         Transposit := Stek[i - 1];
         SetLength(Stek,i - 1);
         Inc(Address_In_Pattern)
        end
       else
        Inc(Address_In_Pattern)
       end
     until False
   end
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
   begin
    Real_End := True;
    exit
   end;

PatternInterpreter(PlParams.FXM_A,FXM_StekA);
PatternInterpreter(PlParams.FXM_B,FXM_StekB);
PatternInterpreter(PlParams.FXM_C,FXM_StekC);

RegisterAY.TonA := PlParams.FXM_A.Ton and $fff;
RegisterAY.TonB := PlParams.FXM_B.Ton and $fff;
RegisterAY.TonC := PlParams.FXM_C.Ton and $fff;

SetAmplA(PlParams.FXM_A.Amplitude);
SetAmplB(PlParams.FXM_B.Amplitude);
SetAmplC(PlParams.FXM_C.Amplitude);

SetMixerRegister((PlParams.FXM_A.FXM_Mixer or
                  PlParams.FXM_B.FXM_Mixer shl 1 or
                  PlParams.FXM_C.FXM_Mixer shl 2) and $3F);

Inc(Global_Tick_Counter)

end;

procedure MakeBufferPSM;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 PSM_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf);
end
end;

procedure PSM_Get_Registers;

 procedure PatternInterpreter(var Chan:PSM_Channel_Parameters);
 var
  PatAddr:word;
  b:byte;
 begin
  with Chan do
   begin
    PatAddr := Address_In_Pattern;
    if RetCnt <> 0 then
     begin
      Dec(RetCnt); if RetCnt = 0 then PatAddr := RetAddress
     end;
    repeat
     case RAM.Index[PatAddr] of
     0..$5F:
      begin
       if Note < 0 then
        Note := PlParams.PSM.Transposition - RAM.Index[PatAddr]
       else
        Dec(Note,RAM.Index[PatAddr]);
       if Note < 0 then inc(Note,96);
       VolCnt := Vol;
       SmpTick := 0;
       DivShift := 0;
       LoopCnt := 1;
       if OrnTick < 0 then
        OrnTick := OrnTick and $E0
       else
        OrnTick := OrnTick and $C0;
       if (OrnTick and $40 <> 0) and (Orn >= 33) then
        begin
         if EnvType >= $b1 then
          begin
           SetEnvelopeRegister(EnvType - $b1 + 8);
           if EnvDiv >= $f1 then
            RegisterAY.Envelope := word(EnvDiv and 15) shl 8
           else
            RegisterAY.Envelope := EnvDiv;
           OrnTick := OrnTick or $40;
          end
         else
          begin
           b := EnvType - $a1;
           SetEnvelopeRegister(((b and 3) shl 1) or 8);
           b := (b and 12) * 3 + Note;
           if b >= 48 then
            begin
             dec(b,48);
             if b >= 48 then dec(b,48)
            end;
           RegisterAY.Envelope := PSM_Table[b + 48];
          end;
        end;
       inc(PatAddr);
       break
      end;
     $60:
      begin
       SmpTick := byte(SmpTick) or 128;
       inc(PatAddr);
       break
      end;
     $61..$6f:
      Samp := RAM.Index[PatAddr] - $61;
     $70..$8f:
      begin
       Orn := RAM.Index[PatAddr] - $70;
       OrnTick := 0;
      end;
     $90:
      begin
       inc(PatAddr);
       break
      end;
     $91..$9f:
      Vol := RAM.Index[PatAddr] - $90;
     $a0:
      OrnTick := RAM.Index[PatAddr]; //$a0
     $a1..$b0:
      begin
       Orn := 33;
       EnvType := RAM.Index[PatAddr];
       OrnTick := OrnTick or $40;
      end;
     $b1..$b7:
      begin
       EnvType := RAM.Index[PatAddr];
       inc(PatAddr);
       EnvDiv := RAM.Index[PatAddr];
       SetEnvelopeRegister(EnvType - $b1 + 8);
       if EnvDiv >= $f1 then
        RegisterAY.Envelope := word(EnvDiv and 15) shl 8
       else
        RegisterAY.Envelope := EnvDiv;
       OrnTick := OrnTick or $40;
      end;
     $b8..$f8:
      Number_Of_Notes_To_Skip := RAM.Index[PatAddr] - $b7;
     $f9:
      begin
       RetAddress := PatAddr + 3;
       RetCnt := RAM.Index[word(PatAddr + 2)];
       PatAddr := WordPtr(@RAM.Index[PatAddr])^ - 1;
      end;
     $fa..$fb:
      Orn := RAM.Index[PatAddr] - $fa + 32;
     else
      begin
       inc(PatAddr);
       break
      end
     end;
     inc(PatAddr)
    until False;
    Address_In_Pattern := PatAddr;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end;
 end;

var
 TempMixer:byte;

 procedure ChangeRegisters(var Chan:PSM_Channel_Parameters);
 var
  b,b1,b2:byte;
  w,wo,ws:word;
 begin

//CBA
//  TempMixer := TempMixer shl 1;

  with Chan do
   begin
    b := Note and 127;
    b2 := OrnTick;
    wo := WordPtr(@RAM.Index[RAM.PSM_OrnamentsPointer + Orn * 2])^;
    if OrnTick and $60 = 0 then
     inc(b,RAM.Index[wo + 2 + b2]);
    if shortint(b) < 0 then b := 0 else if b > 95 then b := 95;
    Ton := PSM_Table[b];

    b2 := SmpTick * 3;
    ws := WordPtr(@RAM.Index[RAM.PSM_SamplesPointer + Samp * 2])^;
    b := RAM.Index[ws + 2 + b2];
    b1 := RAM.Index[ws + 2 + b2 + 1];
    b2 := RAM.Index[ws + 2 + b2 + 2];

    w := word(b1 and 7) shl 8 + b2;
    if b1 and 4 <> 0 then w := w or $f800;

    inc(DivShift,w); inc(Ton,DivShift);
    if smallint(Ton) < 0 then Ton := 0 else if Ton >= 4096 then Ton := 4095;

    Amplitude := b and 15;
    if OrnTick and $40 <> 0 then
     Amplitude := Amplitude or 16;
    inc(Amplitude,VolCnt - 15);
    if (shortint(Amplitude) < 0) or (shortint(SmpTick) < 0) then Amplitude := 0;

//CBA
//    TempMixer := b shr 4 and 9 or TempMixer;
//    if shortint(SmpTick) < 0 then TempMixer := TempMixer or 8;

//ABC
    TempMixer := b shr 1 and $48 or TempMixer;
    if shortint(SmpTick) < 0 then TempMixer := TempMixer or $40;

    if (shortint(b) >= 0) and (Amplitude <> 0) then
     RegisterAY.Noise := b1 shr 3;

    b := SmpTick and 31 + 1;
    b1 := RAM.Index[ws];
    b2 := RAM.Index[ws + 1];
    if b > (b1 and 31) then
     if b2 and $e0 = 0 then
      SmpTick := byte(SmpTick) or 128
     else
      begin
       b := b2 and 31;
       dec(LoopCnt);
       if LoopCnt = 0 then
        begin
         LoopCnt := b2 shr 5;
         if b1 and $20 = 0 then
          inc(VolCnt,b1 shr 6)
         else
          dec(VolCnt,b1 shr 6 + 1);
         if shortint(VolCnt) < 0 then VolCnt := 0 else if VolCnt > 15 then VolCnt := 15
        end;
      end;
    SmpTick := ((b xor byte(SmpTick)) and 31) xor byte(SmpTick);

    b := OrnTick and 31 + 1;
    b1 := RAM.Index[wo];
    b2 := RAM.Index[wo + 1];
    if b > b1 then
     begin
      if shortint(b2) < 0 then
       b := b2
      else
       OrnTick := OrnTick or $20
     end;
    OrnTick := ((b xor byte(OrnTick)) and 31) xor byte(OrnTick)

   end;

//ABC
  TempMixer := TempMixer shr 1;

 end;

var
 b:byte;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
   begin
    Real_End := True;
    exit
   end;

Inc(Global_Tick_Counter);

SetAmplA(0);
SetAmplB(0);
SetAmplC(0);

with PlParams.PSM do
 begin
  if Finished then exit;
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.PSM_C do
     begin
      dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       begin
        if RAM.Index[Address_In_Pattern] = 255 then
         begin
          inc(CurrentPosition);
          b := RAM.Index[RAM.PSM_PositionsPointer + CurrentPosition * 2];
          if b = 255 then
           begin
            b := RAM.Index[RAM.PSM_PositionsPointer + CurrentPosition * 2 + 1];
            if b = 255 then
             begin
              Finished := True;
              exit
             end;
            CurrentPosition := b;
            b := RAM.Index[RAM.PSM_PositionsPointer + b * 2];
           end;
          Transposition := RAM.Index[RAM.PSM_PositionsPointer +
                              CurrentPosition * 2 + 1] + 48;
          Delay := RAM.Index[RAM.PSM_PatternsPointer + b * 7];
          PlParams.PSM_A.Address_In_Pattern :=
           WordPtr(@RAM.Index[RAM.PSM_PatternsPointer + b * 7 + 1])^;
          PlParams.PSM_B.Address_In_Pattern :=
           WordPtr(@RAM.Index[RAM.PSM_PatternsPointer + b * 7 + 3])^;
          Address_In_Pattern :=
           WordPtr(@RAM.Index[RAM.PSM_PatternsPointer + b * 7 + 5])^;
          PlParams.PSM_A.RetCnt := 0;
          PlParams.PSM_B.RetCnt := 0;
          RetCnt := 0;
          PlParams.PSM_A.Note_Skip_Counter := 1;
          PlParams.PSM_B.Note_Skip_Counter := 1;
          PlParams.PSM_A.Note := byte(PlParams.PSM_A.Note) or 128;
          PlParams.PSM_B.Note := byte(PlParams.PSM_B.Note) or 128;
          Note := byte(Note) or 128;
         end;
        PatternInterpreter(PlParams.PSM_C);
       end;
     end;
    with PlParams.PSM_B do
     begin
      dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then PatternInterpreter(PlParams.PSM_B);
     end;
    with PlParams.PSM_A do
     begin
      dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then PatternInterpreter(PlParams.PSM_A);
     end;
    DelayCounter := Delay
   end;
  TempMixer := 0;
  ChangeRegisters(PlParams.PSM_A);
  ChangeRegisters(PlParams.PSM_B);
  ChangeRegisters(PlParams.PSM_C);

  SetMixerRegister(TempMixer);

  RegisterAY.TonA := PlParams.PSM_A.Ton;
  RegisterAY.TonB := PlParams.PSM_B.Ton;
  RegisterAY.TonC := PlParams.PSM_C.Ton;

  SetAmplA(PlParams.PSM_A.Amplitude);
  SetAmplB(PlParams.PSM_B.Amplitude);
  SetAmplC(PlParams.PSM_C.Amplitude);

 end;

end;

procedure MakeBufferPT3;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
while not Real_End and (BuffLen < BufferLength) do
begin
 PT3_Get_Registers;
 if not Real_End then SynthesizerZX50(Buf)
end
end;

procedure PT3_Get_Registers;

 function GetNoteFreq(j:integer):integer;
 begin
  case RAM.PT3_TonTableId of
  0:if PlParams.PT3.PT3_Version <= 3 then
     Result := PT3NoteTable_PT_33_34r[j]
    else
     Result := PT3NoteTable_PT_34_35[j];
  1:Result := PT3NoteTable_ST[j];
  2:if PlParams.PT3.PT3_Version <= 3 then
     Result := PT3NoteTable_ASM_34r[j]
    else
     Result := PT3NoteTable_ASM_34_35[j];
  else if PlParams.PT3.PT3_Version <= 3 then
        Result := PT3NoteTable_REAL_34r[j]
       else
        Result := PT3NoteTable_REAL_34_35[j]
  end
 end;

 procedure PatternInterpreter(var Chan:PT3_Channel_Parameters);
 var
  quit:boolean;
  Flag9,Flag8,Flag5,Flag4,
  Flag3,Flag2,Flag1:byte;
  counter:byte;
  PrNote,PrSliding:integer;
 begin
  PrNote := Chan.Note;
  PrSliding := Chan.Current_Ton_Sliding;
  quit := False;
  counter := 0;
  Flag9 := 0; Flag8 := 0; Flag5 := 0; Flag4 := 0;
  Flag3 := 0; Flag2 := 0; Flag1 := 0;
  with Chan,RAM do
   begin
    repeat
     case Index[Address_In_Pattern] of
     $f0..$ff:
       begin
        OrnamentPointer :=
          PT3_OrnamentsPointers[Index[Address_In_Pattern] - $f0];
        Loop_Ornament_Position := Index[OrnamentPointer];
        Inc(OrnamentPointer);
        Ornament_Length := Index[OrnamentPointer];
        Inc(OrnamentPointer);
        Inc(Address_In_Pattern);
        SamplePointer := PT3_SamplesPointers[Index[Address_In_Pattern] div 2];
        Loop_Sample_Position := Index[SamplePointer];
        Inc(SamplePointer);
        Sample_Length := Index[SamplePointer];
        Inc(SamplePointer);
        Envelope_Enabled := False;
        Position_In_Ornament := 0
       end;
     $d1..$ef:
       begin
        SamplePointer := PT3_SamplesPointers[Index[Address_In_Pattern] - $d0];
        Loop_Sample_Position := Index[SamplePointer];
        Inc(SamplePointer);
        Sample_Length := Index[SamplePointer];
        Inc(SamplePointer)
       end;
     $d0:
       quit := true;
     $c1..$cf:
       Volume := Index[Address_In_Pattern] - $c0;
     $c0:
       begin
        Position_In_Sample := 0;
        Current_Amplitude_Sliding := 0;
        Current_Noise_Sliding := 0;
        Current_Envelope_Sliding := 0;
        Position_In_Ornament := 0;
        Ton_Slide_Count := 0;
        Current_Ton_Sliding := 0;
        Ton_Accumulator := 0;
        Current_OnOff := 0;
        Enabled := False;
        quit := True;
       end;
     $b2..$bf:
       begin
        Envelope_Enabled := True;
        SetEnvelopeRegister(Index[Address_In_Pattern] - $b1);
        Inc(Address_In_Pattern);
        with PlParams.PT3 do
         begin
          Env_Base.hi := Index[Address_In_Pattern];
          Inc(Address_In_Pattern);
          Env_Base.lo := Index[Address_In_Pattern];
          Position_In_Ornament := 0;
          Cur_Env_Slide := 0;
          Cur_Env_Delay := 0
         end
       end;
     $b1:
       begin
        inc(Address_In_Pattern);
        Number_Of_Notes_To_Skip := Index[Address_In_Pattern]
       end;
     $b0:
       begin
        Envelope_Enabled := False;
        Position_In_Ornament := 0
       end;
     $50..$af:
       begin
        Note := Index[Address_In_Pattern] - $50;
        Position_In_Sample := 0;
        Current_Amplitude_Sliding := 0;
        Current_Noise_Sliding := 0;
        Current_Envelope_Sliding := 0;
        Position_In_Ornament := 0;
        Ton_Slide_Count := 0;
        Current_Ton_Sliding := 0;
        Ton_Accumulator := 0;
        Current_OnOff := 0;
        Enabled := True;
        quit := True
       end;
     $40..$4f:
       begin
        OrnamentPointer :=
          PT3_OrnamentsPointers[Index[Address_In_Pattern] - $40];
        Loop_Ornament_Position := Index[Chan.OrnamentPointer];
        Inc(OrnamentPointer);
        Ornament_Length := Index[OrnamentPointer];
        Inc(OrnamentPointer);
        Position_In_Ornament := 0
       end;
     $20..$3f:
       PlParams.PT3.Noise_Base := Index[Address_In_Pattern] - $20;
     $10..$1f:
       begin
        if Index[Address_In_Pattern] = $10 then
         Envelope_Enabled := False
        else
         begin
          SetEnvelopeRegister(Index[Address_In_Pattern] - $10);
          Inc(Address_In_Pattern);
          with PlParams.PT3 do
           begin
            Env_Base.hi := Index[Address_In_Pattern];
            Inc(Address_In_Pattern);
            Env_Base.lo := Index[Address_In_Pattern];
            Envelope_Enabled := True;
            Cur_Env_Slide := 0;
            Cur_Env_Delay := 0
           end
         end;
        Inc(Address_In_Pattern);
        SamplePointer := PT3_SamplesPointers[Index[Address_In_Pattern] div 2];
        Loop_Sample_Position := Index[SamplePointer];
        Inc(SamplePointer);
        Sample_Length := Index[SamplePointer];
        Inc(SamplePointer);
        Position_In_Ornament := 0
       end;
     $9:
       begin
        Inc(counter);
        Flag9 := counter
       end;
     $8:
       begin
        Inc(counter);
        Flag8 := counter
       end;
     $5:
       begin
        Inc(counter);
        Flag5 := counter
       end;
     $4:
       begin
        Inc(counter);
        Flag4 := counter
       end;
     $3:
       begin
        Inc(counter);
        Flag3 := counter
       end;
     $2:
       begin
        Inc(counter);
        Flag2 := counter
       end;
     $1:
       begin
        Inc(counter);
        Flag1 := counter
       end
     end;
     inc(Address_In_Pattern)
    until quit;
    while counter > 0 do
     begin
      if (counter = Flag1) then
       begin
        Ton_Slide_Delay := Index[Address_In_Pattern];
        Ton_Slide_Count := Ton_Slide_Delay;
        Inc(Address_In_Pattern);
        Ton_Slide_Step := WordPtr(@Index[Address_In_Pattern])^;
        Inc(Address_In_Pattern,2);
        SimpleGliss := True;
        Current_OnOff := 0
       end
      else if (counter = Flag2) then
       begin
        SimpleGliss := False;
        Current_OnOff := 0;
        Ton_Slide_Delay := Index[Address_In_Pattern];
        Ton_Slide_Count := Ton_Slide_Delay;
        Inc(Address_In_Pattern,3);
        Ton_Slide_Step := Abs(SmallInt(WordPtr(@Index[Address_In_Pattern])^));
        Inc(Address_In_Pattern,2);
        Ton_Delta := GetNoteFreq(Note) - GetNoteFreq(PrNote);
        Slide_To_Note := Note;
        Note := PrNote;
        if PlParams.PT3.PT3_Version >= 6 then
         Current_Ton_Sliding := PrSliding;
        if Ton_Delta - Current_Ton_Sliding < 0 then
         Ton_Slide_Step := -Ton_Slide_Step
       end
      else if counter = Flag3 then
       begin
        Position_in_Sample := Index[Address_In_Pattern];
        Inc(Address_In_Pattern)
       end
      else if counter = Flag4 then
       begin
        Position_in_Ornament := Index[Address_In_Pattern];
        inc(Address_In_Pattern)
       end
      else if counter = Flag5 then
       begin
        OnOff_Delay := Index[Address_In_Pattern];
        Inc(Address_In_Pattern);
        OffOn_Delay := Index[Address_In_Pattern];
        Current_OnOff := OnOff_Delay;
        Inc(Address_In_Pattern);
        Ton_Slide_Count := 0;
        Current_Ton_Sliding := 0
       end
      else if counter = Flag8 then
       begin
        with PlParams.PT3 do
         begin
          Env_Delay := Index[Address_In_Pattern];
          Cur_Env_Delay := Env_Delay;
          Inc(Address_In_Pattern);
          Env_Slide_Add := WordPtr(@Index[Address_In_Pattern])^;
         end;
        Inc(Address_In_Pattern,2)
       end
      else if counter = Flag9 then
       begin
        PlParams.PT3.Delay := Index[Address_In_Pattern];
        Inc(Address_In_Pattern)
       end;
      Dec(counter)
     end;
    Note_Skip_Counter := Number_Of_Notes_To_Skip
   end
 end;

var
 TempMixer:byte;
 AddToEnv:shortint;

 procedure ChangeRegisters(var Chan:PT3_Channel_Parameters);
 var
  j,b1,b0:byte;
  w:word;
 begin
  with Chan,RAM do
   begin
    if Enabled then
     begin
      Ton := WordPtr(@Index[SamplePointer + Position_In_Sample * 4 + 2])^;
      Inc(Ton,Ton_Accumulator);
      b0 := Index[SamplePointer + Position_In_Sample * 4];
      b1 := Index[SamplePointer + Position_In_Sample * 4 + 1];
      if b1 and $40 <> 0 then
       Ton_Accumulator := Ton;
      j := Note + Index[OrnamentPointer + Position_In_Ornament];
      if shortint(j) < 0 then j := 0 else if j > 95 then j := 95;
      w := GetNoteFreq(j);
      Ton := (Ton + Current_Ton_Sliding + w) and $fff;
      if Ton_Slide_Count > 0 then
       begin
        Dec(Ton_Slide_Count);
        if Ton_Slide_Count = 0 then
         begin
          Inc(Current_Ton_Sliding,Ton_Slide_Step);
          Ton_Slide_Count := Ton_Slide_Delay;
          if not SimpleGliss then
           if ((Ton_Slide_Step < 0) and (Current_Ton_Sliding <= Ton_Delta)) or
              ((Ton_Slide_Step >= 0) and (Current_Ton_Sliding >= Ton_Delta)) then
            begin
             Note := Slide_To_Note;
             Ton_Slide_Count := 0;
             Current_Ton_Sliding := 0
            end
         end
       end;
      Amplitude := b1 and $f;
      if b0 and $80 <> 0 then
      if b0 and $40 <> 0 then
       begin
        if Current_Amplitude_Sliding < 15 then
         inc(Current_Amplitude_Sliding)
       end
      else if Current_Amplitude_Sliding > -15 then
       dec(Current_Amplitude_Sliding);
      inc(Amplitude,Current_Amplitude_Sliding);
      if shortint(Amplitude) < 0 then Amplitude := 0
      else if Amplitude > 15 then Amplitude := 15;
      if PlParams.PT3.PT3_Version <= 4 then
       Amplitude := PT3VolumeTable_33_34[Volume,Amplitude]
      else
       Amplitude := PT3VolumeTable_35[Volume,Amplitude];
      if (b0 and 1 = 0) and Envelope_Enabled then
       Amplitude := Amplitude or 16;
      if b1 and $80 <> 0 then
       begin
        if b0 and $20 <> 0 then
         j := (b0 shr 1) or $F0 + Current_Envelope_Sliding
        else
         j := (b0 shr 1) and $F + Current_Envelope_Sliding;
        if b1 and $20 <> 0 then Current_Envelope_Sliding := j;
        Inc(AddToEnv,j)
       end
      else
       begin
        PlParams.PT3.AddToNoise := b0 shr 1 + Current_Noise_Sliding;
        if b1 and $20 <> 0 then
         Current_Noise_Sliding := PlParams.PT3.AddToNoise
       end;
      TempMixer := b1 shr 1 and $48 or TempMixer;
      Inc(Position_In_Sample);
      if Position_In_Sample >= Sample_Length then
       Position_In_Sample := Loop_Sample_Position;
      Inc(Position_In_Ornament);
      if Position_In_Ornament >= Ornament_Length then
       Position_In_Ornament := Loop_Ornament_Position
     end
    else
     Amplitude := 0;
    TempMixer := TempMixer shr 1;
    if Current_OnOff > 0 then
     begin
      dec(Current_OnOff);
      if Current_OnOff = 0 then
       begin
        Enabled := not Enabled;
        if Enabled then Current_OnOff := OnOff_Delay
        else Current_OnOff := OffOn_Delay
       end;
     end
   end
 end;

begin
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := true;
   exit
  end;
with PlParams.PT3 do
 begin
  Dec(DelayCounter);
  if DelayCounter = 0 then
   begin
    with PlParams.PT3_A do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       with RAM do
        begin
         if (Index[Address_In_Pattern] = 0) then
          begin
           inc(CurrentPosition);
           if CurrentPosition = PT3_NumberOfPositions then
            CurrentPosition := PT3_LoopPosition;
           Address_In_Pattern :=
             WordPtr(@Index[PT3_PatternsPointer +
                         PT3_PositionList[CurrentPosition] * 2])^;
           PlParams.PT3_B.Address_In_Pattern :=
             WordPtr(@Index[PT3_PatternsPointer +
                         PT3_PositionList[CurrentPosition] * 2 + 2])^;
           PlParams.PT3_C.Address_In_Pattern :=
             WordPtr(@Index[PT3_PatternsPointer +
                         PT3_PositionList[CurrentPosition] * 2 + 4])^;
           Noise_Base := 0
          end;
         PatternInterpreter(PlParams.PT3_A);
        end;
     end;
    with PlParams.PT3_B do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       PatternInterpreter(PlParams.PT3_B);
     end;
    with PlParams.PT3_C do
     begin
      Dec(Note_Skip_Counter);
      if Note_Skip_Counter = 0 then
       PatternInterpreter(PlParams.PT3_C);
     end;
    DelayCounter := Delay
   end;

  AddToEnv := 0;
  TempMixer := 0;
  ChangeRegisters(PlParams.PT3_A);
  ChangeRegisters(PlParams.PT3_B);
  ChangeRegisters(PlParams.PT3_C);

  SetMixerRegister(TempMixer);

  RegisterAY.TonA := PlParams.PT3_A.Ton;
  RegisterAY.TonB := PlParams.PT3_B.Ton;
  RegisterAY.TonC := PlParams.PT3_C.Ton;

  SetAmplA(PlParams.PT3_A.Amplitude);
  SetAmplB(PlParams.PT3_B.Amplitude);
  SetAmplC(PlParams.PT3_C.Amplitude);

  RegisterAY.Noise := (Noise_Base + AddToNoise) and 31;

  RegisterAY.Envelope := Env_Base.wrd + AddToEnv + Cur_Env_Slide;

  if Cur_Env_Delay > 0 then
   begin
    Dec(Cur_Env_Delay);
    if Cur_Env_Delay = 0 then
     begin
      Cur_Env_Delay := Env_Delay;
      Inc(Cur_Env_Slide,Env_Slide_Add)
     end
   end
end;

Inc(Global_Tick_Counter)

end;

procedure MakeBufferVTX;
begin
BuffLen := 0;
if IntFlag then SynthesizerZX50(Buf);
if IntFlag then exit;
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
while not Real_End and (BuffLen < BufferLength) do
begin
 VTX_YM3_YM3b_Get_Registers;
 SynthesizerZX50(Buf);
 if (Global_Tick_Counter >= Global_Tick_Max) and (not IntFlag) then
  if Do_Loop then
   Global_Tick_Counter := Global_Tick_Max
  else
   begin
    Real_End := True;
    exit
   end;
 if Position_In_VTX = NumberOfVBLs then Position_In_VTX := LoopVBL
end
end;

procedure VTX_YM3_YM3b_Get_Registers;
var
 i:word;
 k:integer;
begin
k := VTX_Offset;
for i := 0 to 12 do
 begin
  case i of
  1,3,5:
     RegisterAY.Index[i] := PVTXYMUnpackedData^[Position_In_VTX + k] and 15;
  6: RegisterAY.Noise := PVTXYMUnpackedData^[Position_In_VTX + k] and 31;
  7: SetMixerRegister(PVTXYMUnpackedData^[Position_In_VTX + k] and 63);
  8: SetAmplA(PVTXYMUnpackedData^[Position_In_VTX + k] and 31);
  9: SetAmplB(PVTXYMUnpackedData^[Position_In_VTX + k] and 31);
  10:SetAmplC(PVTXYMUnpackedData^[Position_In_VTX + k] and 31);
  else
     RegisterAY.Index[i] := PVTXYMUnpackedData^[Position_In_VTX + k];
  end;
  inc(k,NumberOfVBLs);
 end;
if PVTXYMUnpackedData^[Position_In_VTX + k] <> 255 then
 SetEnvelopeRegister(PVTXYMUnpackedData^[Position_In_Vtx + k] and 15);
inc(Global_Tick_Counter);
inc(Position_In_VTX)
end;

procedure MakeBufferYM2;
var
 MaxT:real;
begin
Bufflen := 0;
if IntFlag then SynthesizerYM6(Buf); if IntFlag then exit;
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
if Optimization_For_Quality then
 MaxT := YM6TiksOnInt
else
 MaxT := YM6SamTiksOnInt;
while not Real_End and (BuffLen < BufferLength) do
 begin
  if YM6CurTik >= MaxT then
   begin
    YM6CurTik := YM6CurTik - MaxT;
    YM2_Get_Registers
   end;
  YM6_Extra_GetRegisters;
  SynthesizerYM6(Buf);
  if (Global_Tick_Counter >= Global_Tick_Max) and (not IntFlag) then
   if Do_Loop then Global_Tick_Counter := Global_Tick_Max else
    begin
     Real_End := True;
     exit
    end
 end
end;

procedure YM2_Get_Registers;
var
 i:word;
 k:integer;
 frq:real;
 SE1TC:byte;
begin
k := VTX_Offset;
for i := 0 to 10 do
 begin
  case i of
  1,3,5:
     RegisterAY.Index[i] := PVTXYMUnpackedData^[Position_In_VTX + k] and 15;
  6: RegisterAY.Noise := PVTXYMUnpackedData^[Position_In_VTX + k] and 31;
  7: SetMixerRegister(PVTXYMUnpackedData^[Position_In_VTX + k] and 63);
  8: SetAmplA(PVTXYMUnpackedData^[Position_In_VTX + k] and 31);
  9: SetAmplB(PVTXYMUnpackedData^[Position_In_VTX + k] and 31);
  10:SetAmplC(PVTXYMUnpackedData^[Position_In_VTX + k] and 31);
  else
     RegisterAY.Index[i] := PVTXYMUnpackedData^[Position_In_VTX + k];
  end;
  inc(k,NumberOfVBLs);
 end;
if PVTXYMUnpackedData^[Position_In_VTX + k + NumberOfVBLs * 2] <> 255 then
 begin
  SetEnvelopeRegister(10);
  RegisterAY.Index[11] := PVTXYMUnpackedData^[Position_In_VTX + k];
  RegisterAY.Index[12] := 0
 end;
k := PVTXYMUnpackedData^[Position_In_VTX + VTX_Offset + NumberOfVBLs * 10];
if k and 128 <> 0 then
 begin
  AtariSE1Channel := 3;
  AtariSE1Type := 1;
  AtariSE1Pos := 0;
  AtariParam1 := k and $7F;
  if AtariParam1 > 39 then AtariParam1 := 39;
  SE1TC := PVTXYMUnpackedData^[Position_In_VTX + VTX_Offset + NumberOfVBLs * 12];
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE1TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE1TC/SampleRate);
  AtariTimerPeriod1 := frq*4;
  if AtariTimerCounter1 >= AtariTimerPeriod1 then
   AtariTimerCounter1 := 0
 end;
if (AtariSE1Channel <> 0) then
 SetMixerRegister(RegisterAY.Mixer or $24);
inc(Global_Tick_Counter);
inc(Position_In_VTX)
end;

procedure YM6_Extra_GetRegisters;
var
 t1,t2,t3:real;
begin
if Optimization_for_quality then
 t3 := YM6TiksOnInt - YM6CurTik
else
 t3 := YM6SamTiksOnInt - YM6CurTik;
t1 := t3;
t2 := t3;
if AtariSE1Channel <> 0 then
 begin
  if AtariTimerCounter1 = 0 then
   Case AtariSE1Type of
   0: begin
       if AtariV1 = 0 then
        AtariV1 := AtariParam1
       else
        AtariV1 := 0;
       RegisterAY.Index[7 + AtariSE1Channel] := AtariV1
      end;
   1: if CurFileType <> YM2File then
       begin
        RegisterAY.Index[7 + AtariSE1Channel] :=
         DDrumSamples[AtariParam1].Buf[AtariSE1Pos];
        inc(AtariSE1Pos);
        if AtariSE1Pos >= DDrumSamples[AtariParam1].Length then
         AtariSE1Channel := 0
       end
      else
       begin
        RegisterAY.Index[10] :=
         PArrayOfByte(sampleAdress[AtariParam1])[AtariSE1Pos];
        inc(AtariSE1Pos);
        if longword(AtariSE1Pos) >= sampleLen[AtariParam1] then
         AtariSE1Channel := 0
       end;
   2: begin
       RegisterAY.Index[7 + AtariSE1Channel] :=
        YM6SinusTable[AtariParam1,YM6SinusPos1];
       YM6SinusPos1 := (YM6SinusPos1 + 1) and 7
      end;
   3: SetEnvelopeRegister(AtariParam1);
   end;
  t1 := AtariTimerPeriod1 - AtariTimerCounter1
 end;
if AtariSE2Channel <> 0 then
 begin
  if AtariTimerCounter2 = 0 then
   Case AtariSE2Type of
   0: begin
       if AtariV2 = 0 then
        AtariV2 := AtariParam2
       else
        AtariV2 := 0;
       RegisterAY.Index[7 + AtariSE2Channel] := AtariV2
      end;
   1: begin
       RegisterAY.Index[7 + AtariSE2Channel] :=
        DDrumSamples[AtariParam2].Buf[AtariSE2Pos] and 15;
       inc(AtariSE2Pos);
       if AtariSE2Pos >= DDrumSamples[AtariParam2].Length then
        AtariSE2Channel := 0
      end;
   2: begin
       RegisterAY.Index[7 + AtariSE2Channel] :=
        YM6SinusTable[AtariParam2,YM6SinusPos2];
       YM6SinusPos2 := (YM6SinusPos2 + 1) and 7
      end;
   3: SetEnvelopeRegister(AtariParam2);
   end;
  t2 := AtariTimerPeriod2 - AtariTimerCounter2
 end;

if t2 < t1 then t1 := t2;
if t3 < t1 then t1 := t3;

YM6Tiks := round(t1*4294967296);

if AtariSE1Channel <> 0 then
 begin
  AtariTimerCounter1 := AtariTimerCounter1 + t1;
  if AtariTimerCounter1 >= AtariTimerPeriod1 then
   AtariTimerCounter1 := 0
 end;
if AtariSE2Channel <> 0 then
 begin
  AtariTimerCounter2 := AtariTimerCounter2 + t1;
  if AtariTimerCounter2 >= AtariTimerPeriod2 then
   AtariTimerCounter2 := 0
 end;
YM6CurTik := YM6CurTik + t1
end;

procedure MakeBufferYM5;
var
 MaxT:real;
begin
BuffLen := 0;
if IntFlag then SynthesizerYM6(Buf);
if IntFlag then exit;
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
if Optimization_For_Quality then
 MaxT := YM6TiksOnInt
else
 MaxT := YM6SamTiksOnInt;
if BytePtr(pointer(integer(PVTXYMUnpackedData) + 19))^ and 1 <> 0 then
 while not Real_End and (BuffLen < BufferLength) do
 begin
  if YM6CurTik >= MaxT then
   begin
    YM6CurTik := YM6CurTik - MaxT;
    YM5i_Get_Registers
   end;
  YM6_Extra_GetRegisters;
  SynthesizerYM6(Buf);
  if (Global_Tick_Counter >= Global_Tick_Max) and (not IntFlag) then
   if Do_Loop then
    Global_Tick_Counter := Global_Tick_Max
   else
    begin
     Real_End := True;
     exit
    end
 end
else
 while not Real_End and (BuffLen < BufferLength) do
 begin
  if YM6CurTik >= MaxT then
   begin
    YM6CurTik := YM6CurTik - MaxT;
    YM5_Get_Registers
   end;
  YM6_Extra_GetRegisters;
  SynthesizerYM6(Buf);
  if (Global_Tick_Counter >= Global_Tick_Max) and (not IntFlag) then
   if Do_Loop then
    Global_Tick_Counter := Global_Tick_Max
   else
    begin
     Real_End := True;
     exit
    end
 end
end;

procedure MakeBufferYM6;
var
 MaxT:real;
begin
Bufflen := 0;
If IntFlag then SynthesizerYM6(Buf);
If IntFlag then exit;
if Global_Tick_Counter >= Global_Tick_Max then
 if Do_Loop then
  Global_Tick_Counter := Global_Tick_Max
 else
  begin
   Real_End := True;
   exit
  end;
if Optimization_For_Quality then
 MaxT := YM6TiksOnInt
else
 MaxT := YM6SamTiksOnInt;
if BytePtr(pointer(integer(PVTXYMUnpackedData) + 19))^ and 1 <> 0 then
 while not Real_End and (BuffLen < BufferLength) do
 begin
  if YM6CurTik >= MaxT then
   begin
    YM6CurTik := YM6CurTik - MaxT;
    YM6i_Get_Registers
   end;
  YM6_Extra_GetRegisters;
  SynthesizerYM6(Buf);
  if (Global_Tick_Counter >= Global_Tick_Max) and (not IntFlag) then
   if Do_Loop then Global_Tick_Counter := Global_Tick_Max else
    begin
     Real_End := True;
     exit
    end
 end
else
 while not Real_End and (BuffLen < BufferLength) do
 begin
  if YM6CurTik >= MaxT then
   begin
    YM6CurTik := YM6CurTik - MaxT;
    YM6_Get_Registers
   end;
  YM6_Extra_GetRegisters;
  SynthesizerYM6(Buf);
  if (Global_Tick_Counter >= Global_Tick_Max) and (not IntFlag) then
   if Do_Loop then
    Global_Tick_Counter := Global_Tick_Max
   else
    begin
     Real_End := True;
     exit
    end
 end
end;

procedure YM6i_Get_Registers;
var
 k:integer;
 b,mx,la,lb,lc:byte;
 SE1Ch,SE2Ch,SE1Typ,SE2Typ,SE1TC,SE2TC:byte;
 frq:real;
begin

k := Position_In_Vtx + VTX_Offset;
RegisterAY.Index[0] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
RegisterAY.Index[1] := b and 15;
SE1Ch := b and $30 shr 4;
SE1Typ := b shr 6;

Inc(k,NumberOfVBLs);
RegisterAY.Index[2] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
RegisterAY.Index[3] := b and 15;
SE2Ch := b and $30 shr 4;
SE2Typ := b shr 6;

Inc(k,NumberOfVBLs);
RegisterAY.Index[4] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
RegisterAY.Index[5] := PVTXYMUnpackedData^[k] and 15;

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
RegisterAY.Noise := b and 31;
AtariSE1TP := b shr 5;

Inc(k,NumberOfVBLs);
mx := PVTXYMUnpackedData^[k] and 63;

Inc(k,NumberOfVBLs);
la := PVTXYMUnpackedData^[k];
AtariSE2TP := la shr 5;

Inc(k,NumberOfVBLs);
lb := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
lc := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
RegisterAY.Index[11] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
RegisterAY.Index[12] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
if b <> 255 then
 SetEnvelopeRegister(b and 15);

Inc(k,NumberOfVBLs);
SE1TC := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
SE2TC := PVTXYMUnpackedData^[k];

if (SE1TC <> 0) and (AtariSE1TP <> 0) and (SE1Ch <> 0) then
 begin
  case SE1Ch of
  1:  case SE1Typ of
      0,2: begin
            AtariParam1 := la and 15;
            Envelope_EnA := True
           end;
      3:   begin
            AtariParam1 := la and 15;
            SetAmplA(la and 16)
           end
      else begin
            AtariParam1 := la and 31;
            Envelope_EnA := True
           end
      end;
  2:  case SE1Typ of
      0,2: begin
            AtariParam1 := lb and 15;
            Envelope_EnB := True
           end;
      3:   begin
            AtariParam1 := lb and 15;
            SetAmplB(lb and 16)
           end
      else begin
            AtariParam1 := lb and 31;
            Envelope_EnB := True
           end
      end;
  3:  case SE1Typ of
      0,2: begin
            AtariParam1 := lc and 15;
            Envelope_EnC := True
           end;
      3:   begin
            AtariParam1 := lc and 15;
            SetAmplC(lc and 16)
           end
      else begin
            AtariParam1 := lc and 31;
            Envelope_EnC := True
           end
      end;
  end;
  if (SE1Typ = 1) and (AtariParam1 >= Length(DDrumSamples)) then SE1Ch := 0;
  AtariSE1Type := SE1Typ;
  AtariSE1Channel := SE1Ch;
  AtariSE1Pos := 0;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE1TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE1TC/SampleRate);
  case AtariSE1TP of
  1: AtariTimerPeriod1 := frq*4;
  2: AtariTimerPeriod1 := frq*10;
  3: AtariTimerPeriod1 := frq*16;
  4: AtariTimerPeriod1 := frq*50;
  5: AtariTimerPeriod1 := frq*64;
  6: AtariTimerPeriod1 := frq*100;
  7: AtariTimerPeriod1 := frq*200
  end;
  if AtariTimerCounter1 >= AtariTimerPeriod1 then
   AtariTimerCounter1 := 0
 end
else
 begin
  if (AtariSE1Channel <> 0) and (AtariSE1Type = 1) then
   begin
    case AtariSE1Channel of
    1:if mx and 9 <> 9 then AtariSE1Channel := 0;
    2:if mx and 18 <> 18 then AtariSE1Channel := 0;
    3:if mx and 36 <> 36 then AtariSE1Channel := 0
    end
   end
  else
   begin
    AtariSE1Channel := 0;
    AtariTimerCounter1 := 0;
    AtariV1 := 0
   end
 end;

if (SE2TC <> 0) and (AtariSE2TP <> 0) and (SE2Ch <> 0) then
 begin
  case SE2Ch of
  1:  case SE2Typ of
      0,2: begin
            AtariParam2 := la and 15;
            Envelope_EnA := True
           end;
      3:   begin
            AtariParam2 := la and 15;
            SetAmplA(la and 16)
           end
      else begin
            AtariParam2 := la and 31;
            Envelope_EnA := True
           end
      end;
  2:  case SE2Typ of
      0,2: begin
            AtariParam2 := lb and 15;
            Envelope_EnB := True
           end;
      3:   begin
            AtariParam2 := lb and 15;
            SetAmplB(lb and 16)
           end
      else begin
            AtariParam2 := lb and 31;
            Envelope_EnB := True
           end
      end;
  3:  case SE2Typ of
      0,2: begin
            AtariParam2 := lc and 15;
            Envelope_EnC := True
           end;
      3:   begin
            AtariParam2 := lc and 15;
            SetAmplC(lc and 16)
           end
      else begin
            AtariParam2 := lc and 31;
            Envelope_EnC := True
           end
      end;
  end;
  if (SE2Typ = 1) and (AtariParam2 >= Length(DDrumSamples)) then SE2Ch := 0;
  AtariSE2Type := SE2Typ;
  AtariSE2Channel := SE2Ch;
  AtariSE2Pos := 0;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE2TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE2TC/SampleRate);
  case AtariSE2TP of
  1: AtariTimerPeriod2 := frq*4;
  2: AtariTimerPeriod2 := frq*10;
  3: AtariTimerPeriod2 := frq*16;
  4: AtariTimerPeriod2 := frq*50;
  5: AtariTimerPeriod2 := frq*64;
  6: AtariTimerPeriod2 := frq*100;
  7: AtariTimerPeriod2 := frq*200
  end;
  if AtariTimerCounter2 >= AtariTimerPeriod2 then
   AtariTimerCounter2 := 0
 end
else
 begin
  if (AtariSE2Channel <> 0) and (AtariSE2Type = 1) then
   begin
    case AtariSE2Channel of
    1:if mx and 9 <> 9 then AtariSE2Channel := 0;
    2:if mx and 18 <> 18 then AtariSE2Channel := 0;
    3:if mx and 36 <> 36 then AtariSE2Channel := 0
    end
   end
  else
   begin
    AtariSE2Channel := 0;
    AtariTimerCounter2 := 0;
    AtariV2 := 0
   end
 end;

if AtariSE1Type = 1 then
 case AtariSE1Channel of
 1: mx := mx or 9;
 2: mx := mx or 18;
 3: mx := mx or 36;
 end;

if AtariSE2Type = 1 then
 case AtariSE2Channel of
 1: mx := mx or 9;
 2: mx := mx or 18;
 3: mx := mx or 36;
 end;

SetMixerRegister(mx);

if (AtariSE1Channel <> 1) and (AtariSE2Channel <> 1) then
 SetAmplA(la and 31);

if (AtariSE1Channel <> 2) and (AtariSE2Channel <> 2) then
 SetAmplB(lb and 31);

if (AtariSE1Channel <> 3) and (AtariSE2Channel <> 3) then
 SetAmplC(lc and 31);

Inc(Global_Tick_Counter);
Inc(Position_In_VTX);
if Position_In_VTX = NumberOfVBLs then
 Position_In_VTX := LoopVBL

end;

procedure YM6_Get_Registers;
var
 k:integer;
 b,mx,la,lb,lc:byte;
 SE1Ch,SE2Ch,SE1Typ,SE2Typ,SE1TC,SE2TC:byte;
 frq:real;
begin

k := Position_In_Vtx + VTX_Offset;
RegisterAY.Index[0] := PVTXYMUnpackedData^[k];

Inc(k);
b := PVTXYMUnpackedData^[k];
RegisterAY.Index[1] := b and 15;
SE1Ch := b and $30 shr 4;
SE1Typ := b shr 6;

Inc(k);
RegisterAY.Index[2] := PVTXYMUnpackedData^[k];

Inc(k);
b := PVTXYMUnpackedData^[k];
RegisterAY.Index[3] := b and 15;
SE2Ch := b and $30 shr 4;
SE2Typ := b shr 6;

Inc(k);
RegisterAY.Index[4] := PVTXYMUnpackedData^[k];

Inc(k);
RegisterAY.Index[5] := PVTXYMUnpackedData^[k] and 15;

Inc(k);
b := PVTXYMUnpackedData^[k];
RegisterAY.Noise := b and 31;
AtariSE1TP := b shr 5;

Inc(k);
mx := PVTXYMUnpackedData^[k] and 63;

Inc(k);
la := PVTXYMUnpackedData^[k];
AtariSE2TP := la shr 5;

Inc(k);
lb := PVTXYMUnpackedData^[k];

Inc(k);
lc := PVTXYMUnpackedData^[k];

Inc(k);
RegisterAY.Index[11] := PVTXYMUnpackedData^[k];

Inc(k);
RegisterAY.Index[12] := PVTXYMUnpackedData^[k];

Inc(k);
b := PVTXYMUnpackedData^[k];
if b <> 255 then
 SetEnvelopeRegister(b and 15);

Inc(k);
SE1TC := PVTXYMUnpackedData^[k];

Inc(k);
SE2TC := PVTXYMUnpackedData^[k];

if (SE1TC <> 0) and (AtariSE1TP <> 0) and (SE1Ch <> 0) then
 begin
  case SE1Ch of
  1:  case SE1Typ of
      0,2: begin
            AtariParam1 := la and 15;
            Envelope_EnA := True
           end;
      3:   begin
            AtariParam1 := la and 15;
            SetAmplA(la and 16)
           end
      else begin
            AtariParam1 := la and 31;
            Envelope_EnA := True
           end
      end;
  2:  case SE1Typ of
      0,2: begin
            AtariParam1 := lb and 15;
            Envelope_EnB := True
           end;
      3:   begin
            AtariParam1 := lb and 15;
            SetAmplB(lb and 16)
           end
      else begin
            AtariParam1 := lb and 31;
            Envelope_EnB := True
           end
      end;
  3:  case SE1Typ of
      0,2: begin
            AtariParam1 := lc and 15;
            Envelope_EnC := True
           end;
      3:   begin
            AtariParam1 := lc and 15;
            SetAmplC(lc and 16)
           end
      else begin
            AtariParam1 := lc and 31;
            Envelope_EnC := True
           end
      end;
  end;
  if (SE1Typ = 1) and (AtariParam1 >= Length(DDrumSamples)) then SE1Ch := 0;
  AtariSE1Type := SE1Typ;
  AtariSE1Channel := SE1Ch;
  AtariSE1Pos := 0;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE1TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE1TC/SampleRate);
  case AtariSE1TP of
  1: AtariTimerPeriod1 := frq*4;
  2: AtariTimerPeriod1 := frq*10;
  3: AtariTimerPeriod1 := frq*16;
  4: AtariTimerPeriod1 := frq*50;
  5: AtariTimerPeriod1 := frq*64;
  6: AtariTimerPeriod1 := frq*100;
  7: AtariTimerPeriod1 := frq*200
  end;
  if AtariTimerCounter1 >= AtariTimerPeriod1 then
   AtariTimerCounter1 := 0
 end
else
 begin
  if (AtariSE1Channel <> 0) and (AtariSE1Type = 1) then
   begin
    case AtariSE1Channel of
    1:if mx and 9 <> 9 then AtariSE1Channel := 0;
    2:if mx and 18 <> 18 then AtariSE1Channel := 0;
    3:if mx and 36 <> 36 then AtariSE1Channel := 0
    end
   end
  else
   begin
    AtariSE1Channel := 0;
    AtariTimerCounter1 := 0;
    AtariV1 := 0
   end
 end;

if (SE2TC <> 0) and (AtariSE2TP <> 0) and (SE2Ch <> 0) then
 begin
  case SE2Ch of
  1:  case SE2Typ of
      0,2: begin
            AtariParam2 := la and 15;
            Envelope_EnA := True
           end;
      3:   begin
            AtariParam2 := la and 15;
            SetAmplA(la and 16)
           end
      else begin
            AtariParam2 := la and 31;
            Envelope_EnA := True
           end
      end;
  2:  case SE2Typ of
      0,2: begin
            AtariParam2 := lb and 15;
            Envelope_EnB := True
           end;
      3:   begin
            AtariParam2 := lb and 15;
            SetAmplB(lb and 16)
           end
      else begin
            AtariParam2 := lb and 31;
            Envelope_EnB := True
           end
      end;
  3:  case SE2Typ of
      0,2: begin
            AtariParam2 := lc and 15;
            Envelope_EnC := True
           end;
      3:   begin
            AtariParam2 := lc and 15;
            SetAmplC(lc and 16)
           end
      else begin
            AtariParam2 := lc and 31;
            Envelope_EnC := True
           end
      end;
  end;
  if (SE2Typ = 1) and (AtariParam2 >= Length(DDrumSamples)) then SE2Ch := 0;
  AtariSE2Type := SE2Typ;
  AtariSE2Channel := SE2Ch;
  AtariSE2Pos := 0;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE2TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE2TC/SampleRate);
  case AtariSE2TP of
  1: AtariTimerPeriod2 := frq*4;
  2: AtariTimerPeriod2 := frq*10;
  3: AtariTimerPeriod2 := frq*16;
  4: AtariTimerPeriod2 := frq*50;
  5: AtariTimerPeriod2 := frq*64;
  6: AtariTimerPeriod2 := frq*100;
  7: AtariTimerPeriod2 := frq*200
  end;
  if AtariTimerCounter2 >= AtariTimerPeriod2 then
   AtariTimerCounter2 := 0
 end
else
 begin
  if (AtariSE2Channel <> 0) and (AtariSE2Type = 1) then
   begin
    case AtariSE2Channel of
    1:if mx and 9 <> 9 then AtariSE2Channel := 0;
    2:if mx and 18 <> 18 then AtariSE2Channel := 0;
    3:if mx and 36 <> 36 then AtariSE2Channel := 0
    end
   end
  else
   begin
    AtariSE2Channel := 0;
    AtariTimerCounter2 := 0;
    AtariV2 := 0
   end
 end;

if AtariSE1Type = 1 then
 case AtariSE1Channel of
 1: mx := mx or 9;
 2: mx := mx or 18;
 3: mx := mx or 36;
 end;

if AtariSE2Type = 1 then
 case AtariSE2Channel of
 1: mx := mx or 9;
 2: mx := mx or 18;
 3: mx := mx or 36;
 end;

SetMixerRegister(mx);

if (AtariSE1Channel <> 1) and (AtariSE2Channel <> 1) then
 SetAmplA(la and 31);

if (AtariSE1Channel <> 2) and (AtariSE2Channel <> 2) then
 SetAmplB(lb and 31);

if (AtariSE1Channel <> 3) and (AtariSE2Channel <> 3) then
 SetAmplC(lc and 31);

Inc(Global_Tick_Counter);
Inc(Position_In_VTX,16);
if Position_In_VTX div 16 = NumberOfVBLs then
 Position_In_VTX := LoopVBL * 16

end;

procedure YM5i_Get_Registers;
var
 k:integer;
 b,la,lb,lc,mx:byte;
 DD,SE1TC,SE2TC:byte;
 frq:real;
begin

k := Position_In_Vtx + VTX_Offset;
RegisterAY.Index[0] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
RegisterAY.Index[1] := b and 15;
AtariSE1Channel := b and $30 shr 4;
if b and $40 <> 0 then
 AtariTimerCounter1 := 0;

Inc(k,NumberOfVBLs);
RegisterAY.Index[2] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
DD := PVTXYMUnpackedData^[k];
RegisterAY.Index[3] := DD and 15;
DD := DD and $30 shr 4;

Inc(k,NumberOfVBLs);
RegisterAY.Index[4] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
RegisterAY.Index[5] := PVTXYMUnpackedData^[k] and 15;

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
RegisterAY.Noise := b and 31;
AtariSE1TP := b shr 5;

Inc(k,NumberOfVBLs);
mx := PVTXYMUnpackedData^[k] and 63;

Inc(k,NumberOfVBLs);
la := PVTXYMUnpackedData^[k];
AtariSE2TP := la shr 5;

Inc(k,NumberOfVBLs);
lb := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
lc := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
RegisterAY.Index[11] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
RegisterAY.Index[12] := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
b := PVTXYMUnpackedData^[k];
if b <> 255 then
 SetEnvelopeRegister(b and 15);

Inc(k,NumberOfVBLs);
SE1TC := PVTXYMUnpackedData^[k];

Inc(k,NumberOfVBLs);
SE2TC := PVTXYMUnpackedData^[k];

if (SE1TC <> 0) and (AtariSE1TP <> 0) and (AtariSE1Channel <> 0) then
 begin
  case AtariSE1Channel of
  1: begin
      AtariParam1 := la and 15;
      Envelope_EnA := True
     end;
  2: begin
      AtariParam1 := lb and 15;
      Envelope_EnB := True
     end;
  3: begin
      AtariParam1 := lc and 15;
      Envelope_EnC := True
     end
  end;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE1TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE1TC/SampleRate);
  case AtariSE1TP of
  1: AtariTimerPeriod1 := frq*4;
  2: AtariTimerPeriod1 := frq*10;
  3: AtariTimerPeriod1 := frq*16;
  4: AtariTimerPeriod1 := frq*50;
  5: AtariTimerPeriod1 := frq*64;
  6: AtariTimerPeriod1 := frq*100;
  7: AtariTimerPeriod1 := frq*200
  end;
  if AtariTimerCounter1 >= AtariTimerPeriod1 then
   AtariTimerCounter1 := 0
 end
else
 begin
  AtariSE1Channel := 0;
  AtariTimerCounter1 := 0;
  AtariV1 := 0
 end;

if (SE2TC <> 0) and (AtariSE2TP <> 0) and (DD <> 0) then
 begin
  case DD of
  1: begin
      AtariParam2 := la and 15;
      Envelope_EnA := True
     end;
  2: begin
      AtariParam2 := lb and 15;
      Envelope_EnB := True
     end;
  3: begin
      AtariParam2 := lc and 15;
      Envelope_EnC := True
     end
  end;
  if AtariParam2 >= Length(DDrumSamples) then DD := 0;
  AtariSE2Channel := DD;
  AtariSE2Pos := 0;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE2TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE2TC/SampleRate);
  case AtariSE2TP of
  1: AtariTimerPeriod2 := frq*4;
  2: AtariTimerPeriod2 := frq*10;
  3: AtariTimerPeriod2 := frq*16;
  4: AtariTimerPeriod2 := frq*50;
  5: AtariTimerPeriod2 := frq*64;
  6: AtariTimerPeriod2 := frq*100;
  7: AtariTimerPeriod2 := frq*200
  end;
  if AtariTimerCounter2 >= AtariTimerPeriod2 then
   AtariTimerCounter2 := 0
 end
else
 begin
  case AtariSE2Channel of
  0:AtariTimerCounter2 := 0;
  1:if mx and 9 <> 9 then AtariSE2Channel := 0;
  2:if mx and 18 <> 18 then AtariSE2Channel := 0;
  3:if mx and 36 <> 36 then AtariSE2Channel := 0
  end
 end;

case AtariSE2Channel of
1: mx := mx or 9;
2: mx := mx or 18;
3: mx := mx or 36;
end;

SetMixerRegister(mx);

if (AtariSE1Channel <> 1) and (AtariSE2Channel <> 1) then
 SetAmplA(la and 31);

if (AtariSE1Channel <> 2) and (AtariSE2Channel <> 2) then
 SetAmplB(lb and 31);

if (AtariSE1Channel <> 3) and (AtariSE2Channel <> 3) then
 SetAmplC(lc and 31);

Inc(Global_Tick_Counter);
Inc(Position_In_VTX);
if Position_In_VTX = NumberOfVBLs then
 Position_In_VTX := LoopVBL

end;

procedure YM5_Get_Registers;
var
 k:integer;
 b,la,lb,lc,mx:byte;
 DD,SE1TC,SE2TC:byte;
 frq:real;
begin

k := Position_In_Vtx + VTX_Offset;
RegisterAY.Index[0] := PVTXYMUnpackedData^[k];

Inc(k);
b := PVTXYMUnpackedData^[k];
RegisterAY.Index[1] := b and 15;
AtariSE1Channel := b and $30 shr 4;
if b and $40 <> 0 then
 AtariTimerCounter1 := 0;

Inc(k);
RegisterAY.Index[2] := PVTXYMUnpackedData^[k];

Inc(k);
DD := PVTXYMUnpackedData^[k];
RegisterAY.Index[3] := DD and 15;
DD := DD and $30 shr 4;

Inc(k);
RegisterAY.Index[4] := PVTXYMUnpackedData^[k];

Inc(k);
RegisterAY.Index[5] := PVTXYMUnpackedData^[k] and 15;

Inc(k);
b := PVTXYMUnpackedData^[k];
RegisterAY.Noise := b and 31;
AtariSE1TP := b shr 5;

Inc(k);
mx := PVTXYMUnpackedData^[k] and 63;

Inc(k);
la := PVTXYMUnpackedData^[k];
AtariSE2TP := la shr 5;

Inc(k);
lb := PVTXYMUnpackedData^[k];

Inc(k);
lc := PVTXYMUnpackedData^[k];

Inc(k);
RegisterAY.Index[11] := PVTXYMUnpackedData^[k];

Inc(k);
RegisterAY.Index[12] := PVTXYMUnpackedData^[k];

Inc(k);
b := PVTXYMUnpackedData^[k];
if b <> 255 then
 SetEnvelopeRegister(b and 15);

Inc(k);
SE1TC := PVTXYMUnpackedData^[k];

Inc(k);
SE2TC := PVTXYMUnpackedData^[k];

if (SE1TC <> 0) and (AtariSE1TP <> 0) and (AtariSE1Channel <> 0) then
 begin
  case AtariSE1Channel of
  1: begin
      AtariParam1 := la and 15;
      Envelope_EnA := True
     end;
  2: begin
      AtariParam1 := lb and 15;
      Envelope_EnB := True
     end;
  3: begin
      AtariParam1 := lc and 15;
      Envelope_EnC := True
     end
  end;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE1TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE1TC/SampleRate);
  case AtariSE1TP of
  1: AtariTimerPeriod1 := frq*4;
  2: AtariTimerPeriod1 := frq*10;
  3: AtariTimerPeriod1 := frq*16;
  4: AtariTimerPeriod1 := frq*50;
  5: AtariTimerPeriod1 := frq*64;
  6: AtariTimerPeriod1 := frq*100;
  7: AtariTimerPeriod1 := frq*200
  end;
  if AtariTimerCounter1 >= AtariTimerPeriod1 then
   AtariTimerCounter1 := 0
 end
else
 begin
  AtariSE1Channel := 0;
  AtariTimerCounter1 := 0;
  AtariV1 := 0
 end;

if (SE2TC <> 0) and (AtariSE2TP <> 0) and (DD <> 0) then
 begin
  case DD of
  1: begin
      AtariParam2 := la and 15;
      Envelope_EnA := True
     end;
  2: begin
      AtariParam2 := lb and 15;
      Envelope_EnB := True
     end;
  3: begin
      AtariParam2 := lc and 15;
      Envelope_EnC := True
     end
  end;
  if AtariParam2 >= Length(DDrumSamples) then DD := 0;
  AtariSE2Channel := DD;
  AtariSE2Pos := 0;
  if Optimization_For_Quality then
   frq := 1/(MFPTimerFrq/SE2TC/(AY_Freq/8))
  else
   frq := 1/(MFPTimerFrq/SE2TC/SampleRate);
  case AtariSE2TP of
  1: AtariTimerPeriod2 := frq*4;
  2: AtariTimerPeriod2 := frq*10;
  3: AtariTimerPeriod2 := frq*16;
  4: AtariTimerPeriod2 := frq*50;
  5: AtariTimerPeriod2 := frq*64;
  6: AtariTimerPeriod2 := frq*100;
  7: AtariTimerPeriod2 := frq*200
  end;
  if AtariTimerCounter2 >= AtariTimerPeriod2 then
   AtariTimerCounter2 := 0
 end
else
 begin
  case AtariSE2Channel of
  0:AtariTimerCounter2 := 0;
  1:if mx and 9 <> 9 then AtariSE2Channel := 0;
  2:if mx and 18 <> 18 then AtariSE2Channel := 0;
  3:if mx and 36 <> 36 then AtariSE2Channel := 0
  end
 end;

case AtariSE2Channel of
1: mx := mx or 9;
2: mx := mx or 18;
3: mx := mx or 36;
end;

SetMixerRegister(mx);

if (AtariSE1Channel <> 1) and (AtariSE2Channel <> 1) then
 SetAmplA(la and 31);

if (AtariSE1Channel <> 2) and (AtariSE2Channel <> 2) then
 SetAmplB(lb and 31);

if (AtariSE1Channel <> 3) and (AtariSE2Channel <> 3) then
 SetAmplC(lc and 31);

Inc(Global_Tick_Counter);
Inc(Position_In_VTX,16);
if (Position_In_VTX div 16 = NumberOfVBLs) then
 Position_In_VTX := LoopVBL * 16

end;

procedure MakeBufferAY;
begin
BufP := Buf;
Bufflen := 0;
if IntFlag then
 begin
  IntFlag := False;
  Synthesizer(Buf);
  if IntFlag then exit;
  if IntBeeper then
   begin
    IntBeeper := False;
    Beeper := BeeperNext
   end;
  if IntAY then
   begin
    IntAY := False;
    SetAYRegister(RegNumNext,DatNext)
   end
 end;
while BuffLen < BufferLength do
begin
 asm
  mov al,Z80_Registers.IR.LoByte
  inc al
  and al,$7F
  or al,R_Hi_Bit
  mov Z80_Registers.IR.LoByte,al
 end;
 if IFF and not EIorDDorFD and (CurrentTact < IntLength) then
  begin
   IFF := False;
   Dec(Z80_Registers.SP,2);
   WordPointer(@RAM.Index[Z80_Registers.SP])^ := Z80_Registers.PC;
   case IMode of
   2:
    begin
     Z80_Registers.PC := WordPointer(
        @RAM.Index[Z80_Registers.IR.HiByte * 256 + 255])^;
     Inc(CurrentTact,18)
    end;
   else
    begin
     Z80_Registers.PC := $38;
     Inc(CurrentTact,12)
    end;
   end
  end
 else
  begin
   EIorDDorFD := False;
   Inc(CurrentTact,Z80_ExecuteCommand);
  end;
if CurrentTact >= MaxTStates then
 begin
  Dec(CurrentTact,MaxTStates);
  Dec(Previous_Tact,MaxTStates);
  if Bufflen < BufferLength then
   SynthesizerAY;
  Inc(Global_Tick_Counter);
  if Global_Tick_Counter >= Global_Tick_Max then
   if Do_Loop then
    Global_Tick_Counter := Global_Tick_Max
   else
    begin
     Real_End := True;
     exit
    end
 end
end
end;

procedure AY_Get_Registers;
begin
repeat
 asm
  mov al,Z80_Registers.IR.LoByte
  inc al
  and al,$7F
  or al,R_Hi_Bit
  mov Z80_Registers.IR.LoByte,al
 end;
 if IFF and not EIorDDorFD and (CurrentTact < IntLength) then
  begin
   IFF := False;
   dec(Z80_Registers.SP,2);
   WordPointer(@RAM.Index[Z80_Registers.SP])^ := Z80_Registers.PC;
   case IMode of
   2:
    begin
     Z80_Registers.PC := WordPointer(
        @RAM.Index[Z80_Registers.IR.HiByte * 256 + 255])^;
     inc(CurrentTact,18);
    end;
   else
    begin
     Z80_Registers.PC := $38;
     inc(CurrentTact,12);
    end;
   end
  end
 else
  begin
   EIorDDorFD := False;
   inc(CurrentTact,Z80_ExecuteCommand);
  end;
if CurrentTact >= MaxTStates then
 begin
  dec(CurrentTact,MaxTStates);
  inc(Global_Tick_Counter);
  if Global_Tick_Counter >= Global_Tick_Max then
   if Do_Loop then
    Global_Tick_Counter := Global_Tick_Max
   else
    Real_End := True;
  exit
 end
until False
end;

procedure Calculate_Slider_Points;
var
 i,p,CPI,prev:integer;
 Step,CurPoint:real;
 temp1:integer;
 EPSGRec:packed record
  case Boolean of
  True:(Reg,Data:byte;
        TSt:longint);
  False:(All:int64);
 end;
begin
case CurFileType of
STCFile..PSMFile:
 begin
  InitForAllTypes(True);
  Step := Global_Tick_Max / ProgrWidth;
  CurPoint := Step;
  CPI := round(CurPoint);
  p := 0;
  i := 0;
  while p < ProgrWidth do
   begin
    while i < CPI do
     begin
      All_GetRegisters;
      Inc(i)
     end;
    Trackers_Slider_Points[p].PlPars := PlParams;
    Trackers_Slider_Points[p].AYRegs := RegisterAY;
    if CurFileType = FXMFile then
     begin
      temp1 := Length(FXM_StekA);
      SetLength(Trackers_Slider_Points[p].FXM_StekA,temp1);
      if temp1 <> 0 then
       Move(FXM_StekA[0],Trackers_Slider_Points[p].FXM_StekA[0],temp1 * 2);
      temp1 := Length(FXM_StekB);
      SetLength(Trackers_Slider_Points[p].FXM_StekB,temp1);
      if temp1 <> 0 then
       Move(FXM_StekB[0],Trackers_Slider_Points[p].FXM_StekB[0],temp1 * 2);
      temp1 := Length(FXM_StekC);
      SetLength(Trackers_Slider_Points[p].FXM_StekC,temp1);
      if temp1 <> 0 then
       Move(FXM_StekC[0],Trackers_Slider_Points[p].FXM_StekC[0],temp1 * 2)
     end;
    CurPoint := CurPoint + Step;
    CPI := round(CurPoint);
    Inc(p)
   end
 end;
PSGFile:
 begin
  InitForAllTypes(True);
  Step := Global_Tick_Max / ProgrWidth;
  CurPoint := Step;
  CPI := round(CurPoint);
  p := 0;
  i := 0;
  while p < ProgrWidth do
   begin
    while i < CPI do
     begin
      PSG_Get_Registers;
      inc(i)
     end;
    Trackers_Slider_Points[p].AYRegs := RegisterAY;
    Trackers_Slider_Points[p].DWParam1 := UniReadersData[FileHandle].UniFilePos;
    Trackers_Slider_Points[p].DWParam2 := PSG_Skip;
    CurPoint := CurPoint + Step;
    CPI := round(CurPoint);
    inc(p)
   end
 end;
EPSGFile:
 begin
  InitForAllTypes(True);
  Step := Time_ms / ProgrWidth / 1000 * FrqZ80;
  CurPoint := Step;
  CPI := round(Step);
  prev := 0;
  p := 0;
  i := 0;
  EPSGRec.All := 0;
  repeat
   UniRead(FileHandle,@EPSGRec,5);
   if EPSGRec.All = $FFFFFFFFFF then
    begin
     Inc(i,EPSG_TStateMax - prev);
     prev := 0
    end
   else
    begin
     Inc(i,EPSGRec.TSt - prev);
     prev := EPSGRec.TSt;
     with EPSGRec do
      if Reg < 14 then
       begin
        case Reg of
        1,3,5,13:
         Data := Data and 15;
        6,8..10:
         Data := Data and 31;
        7:
         Data := Data and 63
        end;
        RegisterAY.Index[Reg] := Data
       end
    end;
   if i >= CPI then
    begin
     if p = ProgrWidth then break;
     Trackers_Slider_Points[p].AYRegs := RegisterAY;
     Trackers_Slider_Points[p].DWParam1 := UniReadersData[FileHandle].UniFilePos;
     Trackers_Slider_Points[p].DWParam2 := prev;
     Dec(i,CPI);
     CurPoint := CurPoint + Step - CPI;
     CPI := round(CurPoint);
     Inc(p)
    end
  until UniReadersData[FileHandle].UniFilePos =
            UniReadersData[FileHandle].UniFileSize;
  if p > 0 then
   while p < ProgrWidth do
    begin
     Trackers_Slider_Points[p] := Trackers_Slider_Points[p - 1];
     Inc(p)
    end
 end;
OUTFile:
 begin
  InitForAllTypes(True);
  Step := Time_ms / ProgrWidth / 1000 * FrqZ80;
  CurPoint := Step;
  CPI := round(Step);
  prev := 0;
  p := 0;
  i := 0;
  repeat
   UniRead(FileHandle,@ZX_Takt,2);
   UniRead(FileHandle,@ZX_Port,2);
   UniRead(FileHandle,@ZX_Port_Data,1);
   case ZX_Takt of
   -1,0:
    begin
     Inc(i,17472 - prev);
     prev := 0
    end
   else
    begin
     Inc(i,ZX_Takt - prev);
     prev := ZX_Takt
    end
   end;
   if ZX_Takt > 0 then
    if (ZX_Port and PortMask) = ($FFFD and PortMask) then
     Current_RegisterAY := ZX_Port_Data
    else if (ZX_Port and PortMask) = ($BFFD and PortMask) then
     if Current_RegisterAY < 14 then
      begin
       case Current_RegisterAY of
       1,3,5,13:
        ZX_Port_Data := ZX_Port_Data and 15;
       6,8..10:
        ZX_Port_Data := ZX_Port_Data and 31;
       7:
        ZX_Port_Data := ZX_Port_Data and 63
       end;
       RegisterAY.Index[Current_RegisterAY] := ZX_Port_Data
      end;
   if i >= CPI then
    begin
     if p = ProgrWidth then break;
     Trackers_Slider_Points[p].AYRegs := RegisterAY;
     Trackers_Slider_Points[p].DWParam1 := UniReadersData[FileHandle].UniFilePos;
     Trackers_Slider_Points[p].DWParam2 := prev;
     Trackers_Slider_Points[p].DWParam3 := Current_RegisterAY;
     Dec(i,CPI);
     CurPoint := CurPoint + Step - CPI;
     CPI := round(CurPoint);
     Inc(p)
    end
  until UniReadersData[FileHandle].UniFilePos =
            UniReadersData[FileHandle].UniFileSize;
  if p > 0 then
   while p < ProgrWidth do
    begin
     Trackers_Slider_Points[p] := Trackers_Slider_Points[p - 1];
     Inc(p)
    end
 end;
ZXAYFile:
 begin
  InitForAllTypes(True);
  if UniReadersData[FileHandle].UniFileSize < 5 then exit;
  Step := Time_ms / ProgrWidth / 1000 * FrqZ80;
  CurPoint := Step;
  CPI := round(Step);
  prev := 0;
  p := 0;
  i := 0;
  repeat
   UniRead(FileHandle,@temp1,4);
   AY_Takt := temp1 and $FFFFF;
   AY_Reg := (temp1 shr 20) and 15;
   AY_Data := temp1 shr 24;
   if AY_Takt = 0 then
    Inc(i,$100000 - prev)
   else
    Inc(i,AY_Takt - prev);
   prev := AY_Takt;
   if AY_Reg < 14 then
    RegisterAY.Index[AY_Reg] := AY_Data;
   if i >= CPI then
    begin
     if p = ProgrWidth then break;
     Trackers_Slider_Points[p].AYRegs := RegisterAY;
     Trackers_Slider_Points[p].DWParam1 := UniReadersData[FileHandle].UniFilePos;
     Trackers_Slider_Points[p].DWParam2 := prev;
     Dec(i,CPI);
     CurPoint := CurPoint + Step - CPI;
     CPI := round(CurPoint);
     Inc(p)
    end;
  until UniReadersData[FileHandle].UniFilePos >=
     UniReadersData[FileHandle].UniFileSize;
  if p > 0 then
   while p < ProgrWidth do
    begin
     Trackers_Slider_Points[p] := Trackers_Slider_Points[p - 1];
     Inc(p)
    end
 end
end
end;

procedure RerollMusic;
var
 pos,stp,bas:integer;
 l:integer;
 op:pointer;
begin
case CurFileType of
VTXFile..YM6File:
 begin
  SetEnvelopeRegister(0);
  First_Period := False;
  Ampl := 0;
  ResetAYChipEmulation;
  Global_Tick_Counter := round(newpos/maxpos*Global_Tick_Max);
  BaseSample := round(Global_Tick_Counter * 1000/Interrupt_Freq * SampleRate);
  Position_In_VTX := Global_Tick_Counter mod NumberOfVBLs;
  if CurFileType in [YM5File..YM6File] then
   begin
    if BytePtr(pointer(integer(PVTXYMUnpackedData) + 19))^ and 1 <> 0 then
     begin
      pos := Position_In_VTX;
      bas := VTX_Offset + NumberOfVBLs * 13;
      stp := 1
     end
    else
     begin
      Position_In_VTX := Position_In_VTX * 16;
      pos := Position_In_VTX;
      bas := VTX_Offset + 13;
      stp := 16
     end
   end
  else
   begin
    pos := Position_In_VTX;
    bas := VTX_Offset + NumberOfVBLs * 13;
    stp := 1
   end;
  if PVTXYMUnpackedData^[pos + bas] = 255 then
   begin
    repeat
     Dec(pos,stp)
    until (pos < 0) or (PVTXYMUnpackedData^[pos + bas] <> 255);
    if pos >= 0 then
     SetEnvelopeRegister(PVTXYMUnpackedData^[pos + bas] and 15)
   end;
  ProgrPos := round(newpos/maxpos*ProgrMax);
  VProgrPos := ProgrPos
 end;
STCFile..PSMFile:
 begin
  if p = 0 then
   begin
    InitForAllTypes(False);
    ResetAYChipEmulation
   end
  else
   begin
    Dec(p);
    ResetAYChipEmulation;
    PlParams := Trackers_Slider_Points[p].PlPars;
    RegisterAY := Trackers_Slider_Points[p].AYRegs;
    SetMixerRegister(Trackers_Slider_Points[p].AYRegs.Mixer);
    SetAmplA(Trackers_Slider_Points[p].AYRegs.AmplitudeA);
    SetAmplB(Trackers_Slider_Points[p].AYRegs.AmplitudeB);
    SetAmplC(Trackers_Slider_Points[p].AYRegs.AmplitudeC);
    SetEnvelopeRegister(Trackers_Slider_Points[p].AYRegs.EnvType);
    if CurFileType = FXMFile then
     begin
      l := Length(Trackers_Slider_Points[p].FXM_StekA);
      SetLength(FXM_StekA,l);
      if l <> 0 then
       Move(Trackers_Slider_Points[p].FXM_StekA[0],FXM_StekA[0],l * 2);
      l := Length(Trackers_Slider_Points[p].FXM_StekB);
      SetLength(FXM_StekB,l);
      if l <> 0 then
       Move(Trackers_Slider_Points[p].FXM_StekB[0],FXM_StekB[0],l * 2);
      l := Length(Trackers_Slider_Points[p].FXM_StekC);
      SetLength(FXM_StekC,l);
      if l <> 0 then
       Move(Trackers_Slider_Points[p].FXM_StekC[0],FXM_StekC[0],l * 2)
     end
   end;
  p := round(f * Global_Tick_Max / ProgrWidth);
  Global_Tick_Counter := round(newpos / maxpos * Global_Tick_Max) - p;
  while p > 0 do
   begin
    All_GetRegisters;
    Dec(p)
   end;
  BaseSample := round(Global_Tick_Counter*1000/Interrupt_Freq * SampleRate);
  ProgrPos := round(newpos / maxpos * ProgrMax);
  VProgrPos := ProgrPos
 end;
PSGFile:
 begin
  if p = 0 then
   begin
    InitForAllTypes(False);
    ResetAYChipEmulation
   end
  else
   begin
    dec(p);
    ResetAYChipEmulation;
    RegisterAY := Trackers_Slider_Points[p].AYRegs;
    SetMixerRegister(Trackers_Slider_Points[p].AYRegs.Mixer);
    SetAmplA(Trackers_Slider_Points[p].AYRegs.AmplitudeA);
    SetAmplB(Trackers_Slider_Points[p].AYRegs.AmplitudeB);
    SetAmplC(Trackers_Slider_Points[p].AYRegs.AmplitudeC);
    SetEnvelopeRegister(Trackers_Slider_Points[p].AYRegs.EnvType);
    UniFileSeek(FileHandle,Trackers_Slider_Points[p].DWParam1);
    PSG_Skip := Trackers_Slider_Points[p].DWParam2
   end;
  p := round(f * Global_Tick_Max / ProgrWidth);
  Global_Tick_Counter := round(newpos / maxpos * Global_Tick_Max) - p;
  while p > 0 do
   begin
    PSG_Get_Registers;
    Dec(p)
   end;
  BaseSample := round(Global_Tick_Counter*1000/Interrupt_Freq * SampleRate);
  ProgrPos := round(newpos / maxpos * ProgrMax);
  VProgrPos := ProgrPos
 end;
EPSGFIle:
 begin
  if p = 0 then
   begin
    InitForAllTypes(False);
    ResetAYChipEmulation
   end
  else
   begin
    Dec(p);
    ResetAYChipEmulation;
    RegisterAY := Trackers_Slider_Points[p].AYRegs;
    SetMixerRegister(Trackers_Slider_Points[p].AYRegs.Mixer);
    SetAmplA(Trackers_Slider_Points[p].AYRegs.AmplitudeA);
    SetAmplB(Trackers_Slider_Points[p].AYRegs.AmplitudeB);
    SetAmplC(Trackers_Slider_Points[p].AYRegs.AmplitudeC);
    SetEnvelopeRegister(Trackers_Slider_Points[p].AYRegs.EnvType);
    UniFileSeek(FileHandle,Trackers_Slider_Points[p].DWParam1);
    Previous_AY_Takt := Trackers_Slider_Points[p].DWParam2
   end;
  p := round(f * Time_ms / 1000 * FrqZ80 / EPSG_TStateMax / ProgrWidth);
  if p > 0 then
   begin
    Previous_AY_Takt := 0;
    while p > 0 do
     begin
      EPSG_Get_Registers;
      Dec(p)
     end;
    IntFlag := False;
   end;
  BaseSample := round(newpos / maxpos * Time_ms / 1000 * SampleRate);
  ProgrPos := round(newpos / maxpos * ProgrMax);
  VProgrPos := ProgrPos
 end;
OUTFile,ZXAYFile:
 begin
  if p = 0 then
   begin
    InitForAllTypes(False);
    ResetAYChipEmulation
   end
  else
   begin
    Dec(p);
    ResetAYChipEmulation;
    RegisterAY := Trackers_Slider_Points[p].AYRegs;
    SetMixerRegister(Trackers_Slider_Points[p].AYRegs.Mixer);
    SetAmplA(Trackers_Slider_Points[p].AYRegs.AmplitudeA);
    SetAmplB(Trackers_Slider_Points[p].AYRegs.AmplitudeB);
    SetAmplC(Trackers_Slider_Points[p].AYRegs.AmplitudeC);
    SetEnvelopeRegister(Trackers_Slider_Points[p].AYRegs.EnvType);
    UniFileSeek(FileHandle,Trackers_Slider_Points[p].DWParam1);
    Previous_AY_Takt := Trackers_Slider_Points[p].DWParam2;
    Current_RegisterAY := Trackers_Slider_Points[p].DWParam3;
    Inc(p)
   end;
  OUTZXAYConv_TotalTime :=
    round(p / ProgrWidth * Time_ms / 1000 * FrqZ80) mod MaxTStates;
  p := round(f * Time_ms / 1000 * FrqZ80 / MaxTStates / ProgrWidth);
  while p > 0 do
   begin
    All_GetRegisters;
    Dec(p)
   end;
  IntFlag := False;
  BaseSample := round(newpos / maxpos * Time_ms / 1000 * SampleRate);
  ProgrPos := round(newpos / maxpos * ProgrMax);
  VProgrPos := ProgrPos
 end;
AYFile..AYMFile:
 begin
  l := round(newpos / maxpos * Global_Tick_Max);
  if l > Global_Tick_Counter then
   begin
    TOutProc(op) := OutProc;
    if op = @ZXOutProc then
     OutProc := OutZXConverter
    else if op = @CPCOutProc then
     OutProc := OutCPCConverter
    else
     OutProc := OutInitialConverter;
    repeat
     AY_Get_Registers
    until Global_Tick_Counter >= l;
    OutProc := op;
    Previous_Tact := CurrentTact;
    IntBeeper := False;
    IntAY := False;
    ResetAYChipEmulation;
    SetEnvelopeRegister(RegisterAY.EnvType);
    First_Period := False;
    Ampl := 0;
    SetMixerRegister(RegisterAY.Mixer);
    SetAmplA(RegisterAY.AmplitudeA);
    SetAmplB(RegisterAY.AmplitudeB);
    SetAmplC(RegisterAY.AmplitudeC)
   end
  else if l < Global_Tick_Counter then
   begin
    TOutProc(op) := OutProc;
    InitForAllTypes(False);
    ResetAYChipEmulation;
    if op = @ZXOutProc then
     OutProc := OutZXConverter
    else if op = @CPCOutProc then
     OutProc := OutCPCConverter
    else
     OutProc := OutInitialConverter;
    Global_Tick_Counter := 0;
    if p > 0 then
     repeat
      AY_Get_Registers
     until Global_Tick_Counter >= l;
    OutProc := op;
    SetEnvelopeRegister(RegisterAY.EnvType);
    First_Period := False;
    Ampl := 0;
    SetMixerRegister(RegisterAY.Mixer);
    SetAmplA(RegisterAY.AmplitudeA);
    SetAmplB(RegisterAY.AmplitudeB);
    SetAmplC(RegisterAY.AmplitudeC)
   end
  else
   ResetAYChipEmulation;
  BaseSample := round(l/FrqZ80 * MaxTStates * SampleRate);
  ProgrPos := round(newpos / maxpos * ProgrMax);
  VProgrPos := ProgrPos
 end
end;
CurrTime_Rasch := round(VProgrPos / SampleRate * 1000)
end;

procedure FreePlayingResourses;
var
 i:integer;
begin
if FileOpened then
 begin
  UniReadClose(FileHandle);
  FileOpened := False
 end;
if FileLoaded then
 begin
  FileLoaded := False;
  case CurFileType of
  VTXFile..YM6File:
   begin
    FreeMem(PVTXYMUnpackedData);
    if (CurFileType in [YM5File,YM6File]) and (Length(DDrumSamples) > 0) then
     DDrumSamples := nil
   end;
  FXMFile:
   begin
    FXM_StekC := nil;
    FXM_StekB := nil;
    FXM_StekA := nil;
    for i := 0 to ProgrWidth - 1 do
     begin
      Trackers_Slider_Points[i].FXM_StekA := nil;
      Trackers_Slider_Points[i].FXM_StekB := nil;
      Trackers_Slider_Points[i].FXM_StekC := nil
     end
   end
  end
 end;
Form1.RestoreAllParams
end;

procedure BASSGetTags(var Author,Title:string;h:integer;FileType:Available_Types);

 procedure GetSongInfo_ID3V1;
 var
  p:PID3v1;
 begin
  p := pointer(BASS_StreamGetTags(h,BASS_TAG_ID3));
  if p = nil then exit;
  Author := p.Author;
  Author := Trim(PChar(Author));
  Title := p.Title;
  Title := Trim(PChar(Title))
 end;

 function GetSongInfo_ID3V2:boolean;

  function GetID3V2DWord(a:dword):dword;
   asm
    shl ah,1
    xchg al,ah
    shr ax,1
    ror eax,16
    shl ah,1
    xchg al,ah
    shl ax,1
    shr eax,2
   end;

  const
   TIT2 = $32544954;
   TPE1 = $31455054;

  var
   p,TagSize,AddByte,StrSize:integer;

  procedure CaseIds(Id:integer);
   begin
    case Id of
    TIT2:
     begin
      SetLength(Title,StrSize);
      Move(pointer(p + 10 + AddByte + 1)^,Title[1],StrSize);
      Title := Trim(PChar(Title))
     end;
    TPE1:
     begin
      SetLength(Author,StrSize);
      Move(pointer(p + 10 + AddByte + 1)^,Author[1],StrSize);
      Author := Trim(PChar(Author))
     end
    end
   end;

  procedure GetFromIDV24x; //not tested
   begin
    TagSize := DWORD(p) + GetID3V2DWord(PID3V2Header(p).Size);
    if PID3V2Header(p).Flags and 32 = 0 then
     Inc(TagSize,10);
    Inc(p,10);
    if PID3V2Header(p - 10).Flags and 64 <> 0 then
     Inc(p,GetID3V2DWord(PID3V2ExtHeader(p).Size));
    while p <= TagSize - SizeOf(TID3V2Frame) do
     with PID3V2Frame(p)^ do
      begin
       AddByte := Ord(Flags and 64 <> 0);
       StrSize := integer(GetID3V2DWord(Size)) - AddByte - 1;
       if (Flags and 15 = 0) and
          (StrSize > 0) and (StrSize <= TagSize - p - 10 - AddByte - 1) and
          (PByte(p + 10 + AddByte)^ = 0) then
        CaseIds(Id);
       Inc(p,GetID3V2DWord(Size) + 10)
      end
   end;

  procedure GetFromIDV23x;
   begin
    if PID3V2Header(p).Flags and 128 <> 0 then exit;
    TagSize := DWORD(p) + GetID3V2DWord(PID3V2Header(p).Size) + 10;
    Inc(p,10);
    if PID3V2Header(p - 10).Flags and 64 <> 0 then
     Inc(p,IntelDWord(PID3V2ExtHeader(p).Size));
    while p <= TagSize - SizeOf(TID3V2Frame) do
     with PID3V2Frame(p)^ do
      begin
       AddByte := Ord(Flags and 32 <> 0);
       StrSize := integer(IntelDWord(Size)) - AddByte - 1;
       if (Flags and (128 + 64) = 0) and (StrSize > 0) and
          (StrSize <= TagSize - p - 10 - AddByte - 1) and
          (PByte(p + 10 + AddByte)^ = 0) then
        CaseIds(Id);
       Inc(p,IntelDWord(Size) + 10)
      end
   end;

 begin
  Result := False;
  p := integer(BASS_StreamGetTags(h,BASS_TAG_ID3V2));
  if p = 0 then exit;
  case PID3V2Header(p).VerMajor of
  4:GetFromIDV24x;
  3:GetFromIDV23x
  else
   exit
  end;
  if (Author <> '') or (Title <> '') then
   Result := True
 end;

 procedure GetSongInfo_OGG;
 var
  p:PChar;
  l,tl,cl:longword;
  Tag:string;
 begin
  p := BASS_StreamGetTags(h,BASS_TAG_OGG);
  if p = nil then exit;
  repeat
   l := StrLen(p);
   tl := 0;
   while (tl < l) and (PByte(DWORD(p) + tl)^ <> Ord('=')) do Inc(tl);
   if (tl = l) or (tl = 0) then break;
   if tl < l - 1 then
    begin
     SetLength(Tag,tl);
     Move(p^,Tag[1],tl);
     cl := l - tl - 1;
     if UpperCase(Tag) = 'ARTIST' then
      begin
       SetLength(Author,cl);
       Move(pointer(DWORD(p) + tl + 1)^,Author[1],cl)
      end
     else if UpperCase(Tag) = 'TITLE' then
      begin
       SetLength(Title,cl);
       Move(pointer(DWORD(p) + tl + 1)^,Title[1],cl)
      end;
     SetLength(Tag,0)
    end;
   Inc(integer(p),l + 1)
  until PByte(p)^ = 0;
  Author := Trim(Author);
  Title := Trim(Title)
 end;

begin
Author := '';
Title := '';
if h = 0 then exit;
case FileType of
MpegFileMin..MpegFileMax:
 begin
  if not GetSongInfo_ID3V2 then
   GetSongInfo_ID3V1
 end;
OGGFile:
 GetSongInfo_OGG;
MODFilesMin..MODFilesMax:
 Title := Trim(BASS_MusicGetName(h));
end
end;

procedure incr(var i:longword);
begin
inc(i);
if i >= 65536 then RaiseBadFileStructure
end;

procedure GetTimeFXM(Module:PModTypes;Address:integer;var Tm,Lp:integer);

 function FXM_Loop_Found(j11,j22,j33:word):boolean;
 var
  j1,j2,j3:longword;
  a1,a2,a3:byte;
  f71,f72,f73:boolean;
  f61,f62,f63:boolean;
  fxms1,fxms2,fxms3:array of word;
  k:integer;
  tr:integer;
 begin
       j1 := WordPtr(@Module.Index[Address])^;
       j2 := WordPtr(@Module.Index[Address + 2])^;
       j3 := WordPtr(@Module.Index[Address + 4])^;
       a1 := 1; a2 := 1; a3:= 1;
       f71 := False; f72 := False; f73 := False;
       f61 := False; f62 := False; f63 := False;
       tr := 0;
       repeat
        if (j1 = j11) and (j2 = j22) and (j3 = j33) then
         begin
          Result := True;
          Lp := tr;
          exit
         end;
        Dec(a1);
        if a1 = 0 then
         begin
          f71 := False;
          f61 := False;
          repeat
           case Module.Index[j1] of
           0..$7F,$8F..$FF:
            begin
             incr(j1);
             a1 := Module.Index[j1];
             incr(j1);
             break
            end;
           $80:
            begin
             if j1 >= 65536 - 2 then RaiseBadFileStructure;
             j1 := WordPtr(@Module.Index[j1 + 1])^;
             f71 := True
            end;
           $81:
            begin
             if j1 >= 65536 - 3 then RaiseBadFileStructure;
             k := Length(fxms1);
             SetLength(fxms1,k + 1);
             fxms1[k] := j1 + 3;
             j1 := WordPtr(@Module.Index[j1 + 1])^
            end;
           $82:
            begin
             if (j1 = j11) and (j2 = j22) and (j3 = j33) then
              begin
               Result := True;
               Lp := tr;
               exit
              end;
             k := Length(fxms1);
             SetLength(fxms1,k + 2);
             incr(j1);
             fxms1[k] := Module.Index[j1];
             incr(j1);
             fxms1[k + 1] := j1
            end;
           $83:
            begin
             k := Length(fxms1);
             if k < 2 then RaiseBadFileStructure;
             dec(fxms1[k - 2]);
             if fxms1[k - 2] and 255 <> 0 then
              begin
               j1 := fxms1[k - 1];
               f61 := True
              end
             else
              begin
               SetLength(fxms1,k - 2);
               inc(j1)
              end
            end;
           $84,$85,$88,$8D,$8E:
            inc(j1,2);
           $86,$87,$8C:
            inc(j1,3);
           $89:
            begin
             k := Length(fxms1);
             if k < 1 then RaiseBadFileStructure;
             j1 := fxms1[k - 1];
             SetLength(fxms1,k - 1)
            end;
           $8A,$8B:
            inc(j1);
           end;
           if j1 >= 65536 then RaiseBadFileStructure
          until False;
         end;
        Dec(a2);
        if a2 = 0 then
         begin
          f72 := False;
          f62 := False;
          repeat
           case Module.Index[j2] of
           0..$7F,$8F..$FF:
            begin
             incr(j2);
             a2 := Module.Index[j2];
             incr(j2);
             break
            end;
           $80:
            begin
             if j2 >= 65536 - 2 then RaiseBadFileStructure;
             j2 := WordPtr(@Module.Index[j2 + 1])^;
             f72 := True
            end;
           $81:
            begin
             if j2 >= 65536 - 3 then RaiseBadFileStructure;
             k := Length(fxms2);
             SetLength(fxms2,k + 1);
             fxms2[k] := j2 + 3;
             j2 := WordPtr(@Module.Index[j2 + 1])^
            end;
           $82:
            begin
             if (j1 = j11) and (j2 = j22) and (j3 = j33) then
              begin
               Result := True;
               Lp := tr;
               exit
              end;
             k := Length(fxms2);
             SetLength(fxms2,k + 2);
             incr(j2);
             fxms2[k] := Module.Index[j2];
             incr(j2);
             fxms2[k + 1] := j2
            end;
           $83:
            begin
             k := Length(fxms2);
             if k < 2 then RaiseBadFileStructure;
             dec(fxms2[k - 2]);
             if fxms2[k - 2] and 255 <> 0 then
              begin
               j2 := fxms2[k - 1];
               f62 := True
              end
             else
              begin
               SetLength(fxms2,k - 2);
               inc(j2)
              end
            end;
           $84,$85,$88,$8D,$8E:
            inc(j2,2);
           $86,$87,$8C:
            inc(j2,3);
           $89:
            begin
             k := Length(fxms2);
             if k < 1 then RaiseBadFileStructure;
             j2 := fxms2[k - 1];
             SetLength(fxms2,k - 1)
            end;
           $8A,$8B:
            inc(j2)
           end;
           if j2 >= 65536 then RaiseBadFileStructure
          until False;
         end;
        Dec(a3);
        if a3 = 0 then
         begin
          f73 := False;
          f63 := False;
          repeat
           case Module.Index[j3] of
           0..$7F,$8F..$FF:
            begin
             incr(j3);
             a3 := Module.Index[j3];
             incr(j3);
             break
            end;
           $80:
            begin
             if j3 >= 65536 - 2 then RaiseBadFileStructure;
             j3 := WordPtr(@Module.Index[j3 + 1])^;
             f73 := True
            end;
           $81:
            begin
             if j3 >= 65536 - 3 then RaiseBadFileStructure;
             k := Length(fxms3);
             SetLength(fxms3,k + 1);
             fxms3[k] := j3 + 3;
             j3 := WordPtr(@Module.Index[j3 + 1])^
            end;
           $82:
            begin
             if (j1 = j11) and (j2 = j22) and (j3 = j33) then
              begin
               Result := True;
               Lp := tr;
               exit
              end;
             k := Length(fxms3);
             SetLength(fxms3,k + 2);
             incr(j3);
             fxms3[k] := Module.Index[j3];
             incr(j3);
             fxms3[k + 1] := j3
            end;
           $83:
            begin
             k := Length(fxms3);
             if k < 2 then RaiseBadFileStructure;
             dec(fxms3[k - 2]);
             if fxms3[k - 2] and 255 <> 0 then
              begin
               j3 := fxms3[k - 1];
               f63 := True
              end
             else
              begin
               SetLength(fxms3,k - 2);
               inc(j3)
              end
            end;
           $84,$85,$88,$8D,$8E:
            inc(j3,2);
           $86,$87,$8C:
            inc(j3,3);
           $89:
            begin
             k := Length(fxms3);
             if k < 1 then RaiseBadFileStructure;
             j3 := fxms3[k - 1];
             SetLength(fxms3,k - 1)
            end;
           $8A,$8B:
            inc(j3);
           end;
           if j3 >= 65536 then RaiseBadFileStructure
          until False;
         end;
        inc(tr);
       until ((f71 and (f72 or f62) and (f73 or f63)) or
             ((f71 or f61) and f72 and (f73 or f63)) or
             ((f71 or f61) and (f72 or f62) and f73));
  Result := False
 end;

var
 j1,j2,j3:longword;
 a1,a2,a3:shortint;
 f71,f72,f73,
 f61,f62,f63:boolean;
 k:integer;
 j11,j22,j33:word;
 fxms1,fxms2,fxms3:array of word;
begin
   with Module^ do
    begin
     if Address > 65536 - 6 then RaiseBadFileStructure;
     j1 := WordPtr(@Index[Address])^;
     j2 := WordPtr(@Index[Address + 2])^;
     j3 := WordPtr(@Index[Address + 4])^;
     a1 := 1; a2 := 1; a3:= 1;
     f71 := False; f72 := False; f73 := False;
     f61 := False; f62 := False; f63 := False;
     repeat
      Dec(a1);
      if a1 = 0 then
       begin
        f71 := False;
        f61 := False;
        repeat
         case Index[j1] of
         0..$7F,$8F..$FF:
          begin
           Incr(j1);
           a1 := Index[j1];
           Incr(j1);
           break
          end;
         $80:
          begin
           if j1 >= 65536 - 2 then RaiseBadFileStructure;
           j1 := WordPtr(@Index[j1 + 1])^;
           j11 := j1;
           f71 := True
          end;
         $81:
          begin
           if j1 >= 65536 - 3 then RaiseBadFileStructure;
           k := System.Length(fxms1);
           SetLength(fxms1,k + 1);
           fxms1[k] := j1 + 3;
           j1 := WordPtr(@Index[j1 + 1])^
          end;
         $82:
          begin
           k := System.Length(fxms1);
           SetLength(fxms1,k + 2);
           Incr(j1);
           fxms1[k] := Index[j1];
           Incr(j1);
           fxms1[k + 1] := j1
          end;
         $83:
          begin
           k := System.Length(fxms1);
           if k < 2 then RaiseBadFileStructure;
           Dec(fxms1[k - 2]);
           if fxms1[k - 2] and 255 <> 0 then
            begin
             j1 := fxms1[k - 1];
             if j1 < 2 then RaiseBadFileStructure;
             j11 := j1 - 2;
             f61 := True
            end
           else
            begin
             SetLength(fxms1,k - 2);
             Inc(j1)
            end
          end;
         $84,$85,$88,$8D,$8E:
          Inc(j1,2);
         $86,$87,$8C:
          Inc(j1,3);
         $89:
          begin
           k := System.Length(fxms1);
           if k < 1 then RaiseBadFileStructure;
           j1 := fxms1[k - 1];
           SetLength(fxms1,k - 1)
          end;
         $8A,$8B:
          Inc(j1)
         end;
         if j1 >= 65536 then RaiseBadFileStructure
        until False;
       end;
      Dec(a2);
      if a2 = 0 then
       begin
        f72 := False;
        f62 := False;
        repeat
         case Index[j2] of
         0..$7F,$8F..$FF:
          begin
           Incr(j2);
           a2 := Index[j2];
           Incr(j2);
           break
          end;
         $80:
          begin
           if j2 >= 65536 - 2 then RaiseBadFileStructure;
           j2 := WordPtr(@Index[j2 + 1])^;
           j22 := j2;
           f72 := True
          end;
         $81:
          begin
           if j2 >= 65536 - 3 then RaiseBadFileStructure;
           k := System.Length(fxms2);
           SetLength(fxms2,k + 1);
           fxms2[k] := j2 + 3;
           j2 := WordPtr(@Module.Index[j2 + 1])^
          end;
         $82:
          begin
           k := System.Length(fxms2);
           SetLength(fxms2,k + 2);
           Incr(j2);
           fxms2[k] := Index[j2];
           Incr(j2);
           fxms2[k + 1] := j2
          end;
         $83:
          begin
           k := System.Length(fxms2);
           if k < 2 then RaiseBadFileStructure;
           Dec(fxms2[k - 2]);
           if fxms2[k - 2] and 255 <> 0 then
            begin
             j2 := fxms2[k - 1];
             if j2 < 2 then RaiseBadFileStructure;
             j22 := j2 - 2;
             f62 := True
            end
           else
            begin
             SetLength(fxms2,k - 2);
             Inc(j2)
            end
          end;
         $84,$85,$88,$8D,$8E:
          Inc(j2,2);
         $86,$87,$8C:
          Inc(j2,3);
         $89:
          begin
           k := System.Length(fxms2);
           if k < 1 then RaiseBadFileStructure;
           j2 := fxms2[k - 1];
           SetLength(fxms2,k - 1)
          end;
         $8A,$8B:
          Inc(j2)
         end;
         if j2 >= 65536 then RaiseBadFileStructure
        until False;
       end;
      Dec(a3);
      if a3 = 0 then
       begin
        f73 := False;
        f63 := False;
        repeat
         case Index[j3] of
         0..$7F,$8F..$FF:
          begin
           Incr(j3);
           a3 := Index[j3];
           Incr(j3);
           break
          end;
         $80:
          begin
           if j3 >= 65536 - 2 then RaiseBadFileStructure;
           j3 := WordPtr(@Index[j3 + 1])^;
           j33 := j3;
           f73 := True
          end;
         $81:
          begin
           if j3 >= 65536 - 3 then RaiseBadFileStructure;
           k := System.Length(fxms3);
           SetLength(fxms3,k + 1);
           fxms3[k] := j3 + 3;
           j3 := WordPtr(@Index[j3 + 1])^
          end;
         $82:
          begin
           k := System.Length(fxms3);
           SetLength(fxms3,k + 2);
           Incr(j3);
           fxms3[k] := Index[j3];
           Incr(j3);
           fxms3[k + 1] := j3
          end;
         $83:
          begin
           k := System.Length(fxms3);
           if k < 2 then RaiseBadFileStructure;
           Dec(fxms3[k - 2]);
           if fxms3[k - 2] and 255 <> 0 then
            begin
             j3 := fxms3[k - 1];
             if j3 < 2 then RaiseBadFileStructure;
             j33 := j3 - 2;
             f63 := True
            end
           else
            begin
             SetLength(fxms3,k - 2);
             Inc(j3)
            end
          end;
         $84,$85,$88,$8D,$8E:
          Inc(j3,2);
         $86,$87,$8C:
          Inc(j3,3);
         $89:
          begin
           k := System.Length(fxms3);
           if k < 1 then RaiseBadFileStructure;
           j3 := fxms3[k - 1];
           SetLength(fxms3,k - 1)
          end;
         $8A,$8B:
          Inc(j3)
         end;
         if j3 >= 65536 then RaiseBadFileStructure
        until False
       end;
      Inc(tm);
      if tm > 180000 then
       begin
        tm := 15001;
        break
       end
     until ((f71 and (f72 or f62) and (f73 or f63)) or
            ((f71 or f61) and f72 and (f73 or f63)) or
            ((f71 or f61) and (f72 or f62) and f73)
           ) and FXM_Loop_Found(j11,j22,j33);
     Dec(tm)
    end
end;

procedure GetTimeGTR(Module:PModTypes;var Tm,Lp:integer);
var
 a:byte;
 a1:shortint;
 flg:boolean;
 j1:longword;

  begin
   with Module^ do
    begin
     a := 0; a1 := 0; flg := False;
     j1 := GTR_PatternsPointers[GTR_Positions[0] div 6].PatternA;
     repeat
      Dec(a1);
      if a1 < 0 then
       begin
        a1 := 0;
        while Index[j1] = 255 do
         begin
          Inc(a);
          flg := a >= GTR_NumberOfPositions;
          if flg then break;
          if a = GTR_LoopPosition then Lp := tm;
          j1 := GTR_PatternsPointers[Module.GTR_Positions[a] div 6].PatternA
         end;
        if flg then break;
        repeat
         case Index[j1] of
         0..$5f,$D0..$DF:
          begin
           Incr(j1);
           break
          end;
         $80..$BF:
          a1 := Index[j1] - $80;
         $C0..$CF:
          Inc(j1);
         $E0:
          if GTR_ID[3] <> #$10 then
           begin
            Incr(j1);
            break
           end
         end;
         Incr(j1)
        until False
       end;
      Inc(tm,GTR_Delay)
     until False
    end
end;

procedure GetTimeSTC(Module:PModTypes;var Tm:integer);
var
 i,j:integer;
 j1,j2:longword;
 a:byte;
begin
   with Module^ do
    begin
     j := -1;
     repeat
      inc(j);
      j2 := ST_PositionsPointer + j * 2;
      incr(j2);
      j2 := Index[j2];
      i := -1;
      repeat
       inc(i);
       j1 := ST_PatternsPointer + 7 * i;
       if j1 >= 65535 then RaiseBadFileStructure
      until Index[j1] = j2;
      j1 := WordPtr(@Index[j1 + 1])^;
      a := 1;
      while Index[j1] <> 255 do
       begin
        case Index[j1] of
        0..$5f,$80,$81:
         Inc(tm,a);
        $a1..$e0:
         a := Index[j1] - $a0;
        $83..$8e:
         inc(j1)
        end;
        incr(j1)
       end
     until j = Index[ST_PositionsPointer];
     tm := tm * ST_Delay
    end
end;

procedure GetTimeASC(Module:PModTypes;var Tm,Lp:integer);
var
 i:integer;
 j1,j2,j3:longword;
 b:byte;
 a1,a2,a3,a11,a22,a33:shortint;
 Env1,Env2,Env3:boolean;
 DLCatcher:integer;
begin
    a1 := 0; a2 := 0; a3 := 0;
    a11 := 0; a22 := 0; a33 := 0;
    Env1 := False; Env2 := False; Env3 := False;
    with Module^ do
     begin
      b := ASC1_Delay;
      DLCatcher := 16384;
      for i := 0 to ASC1_Number_Of_Positions - 1 do
       begin
        if ASC1_LoopingPosition = i then Lp := tm;
        j1 := WordPtr(@Index[ASC1_PatternsPointers + 6 * Index[i + 9]])^ +
                              ASC1_PatternsPointers;
        j2 := WordPtr(@Index[ASC1_PatternsPointers + 6 * Index[i + 9] + 2])^ +
                              ASC1_PatternsPointers;
        j3 := WordPtr(@Index[ASC1_PatternsPointers + 6 * Index[i + 9] + 4])^ +
                              ASC1_PatternsPointers;
        repeat
         dec(a1);
         if a1 < 0 then
          begin
           if Index[j1] = 255 then break;
           repeat
            case Index[j1] of
            0..$55:
             begin
              a1 := a11;
              incr(j1);
              if Env1 then incr(j1);
              break
             end;
            $56..$5f:
             begin
              a1 := a11;
              incr(j1);
              break
             end;
            $60..$9f:
             a11 := Index[j1] - $60;
            $e0:
             Env1 := True;
            $e1..$ef:
             Env1 := False;
            $f0,$f5..$f7,$f9,$fb:
             inc(j1);
            $f4:
             begin
              incr(j1);
              b := Index[j1]
             end
            end;
            incr(j1)
           until False;
          end;
         dec(a2);
         if a2 < 0 then
          repeat
           case Index[j2] of
           0..$55:
            begin
             a2 := a22;
             incr(j2);
             if Env2 then incr(j2);
             break
            end;
           $56..$5f:
            begin
             a2 := a22;
             incr(j2);
             break
            end;
           $60..$9f:
            a22 := Index[j2] - $60;
           $e0:
            Env2 := True;
           $e1..$ef:
            Env2 := False;
           $f0,$f5..$f7,$f9,$fb:
            inc(j2);
           $f4:
            begin
             incr(j2);
             b := Index[j2]
            end
           end;
           incr(j2)
          until False;
         dec(a3);
         if a3 < 0 then
          repeat
           case Module.Index[j3] of
           0..$55:
            begin
             a3 := a33;
             incr(j3);
             if Env3 then incr(j3);
             break
            end;
           $56..$5f:
            begin
             a3 := a33;
             incr(j3);
             break
            end;
           $60..$9f:
            a33 := Index[j3] - $60;
           $e0:
            env3 := True;
           $e1..$ef:
            env3 := False;
           $f0,$f5..$f7,$f9,$fb:
            inc(j3);
           $f4:
            begin
             incr(j3);
             b := Index[j3]
            end
           end;
           incr(j3)
          until False;
         Inc(tm,b);
         Dec(DLCatcher);
         if DLCatcher < 0 then RaiseBadFileStructure
        until False
       end
     end
end;

procedure GetTimeSTP(Module:PModTypes;var Tm,Lp:integer);
var
 a:byte;
 i:integer;
 j1:longword;
begin
   a := 1;
   with Module^ do
    begin
     for i := 0 to Index[STP_PositionsPointer] - 1 do
      begin
       if i = Index[STP_PositionsPointer + 1] then
        Lp := tm * STP_Delay;
       j1 := WordPtr(@Index[STP_PatternsPointer +
                      Index[STP_PositionsPointer + 2 + i * 2]])^;
       while Index[j1] <> 0 do
        begin
         case Index[j1] of
         1..$60,$d0..$ef:
          Inc(tm,a);
         $80..$BF:
          a := Index[j1] - $7f;
         $c0..$cf,$f0:
          inc(j1)
         end;
         incr(j1)
        end
      end;
     tm := tm * STP_Delay
    end
end;

procedure GetTimePT2(Module:PModTypes;var Tm,Lp:integer);
var
 i:integer;
 b:byte;
 a1,a2,a3,a11,a22,a33:shortint;
 DLCatcher:integer;
 j1,j2,j3:longword;
begin
   with Module^ do
    begin
     b := PT2_Delay;
     a1 := 0; a2 := 0; a3 := 0;
     a11 := 0; a22 := 0; a33 := 0;
     DLCatcher := 16384;
     i := 0;
     repeat
       if i >= 65536-131 then RaiseBadFileStructure;
       if shortint(PT2_PositionList[i]) < 0 then break;
       if i = PT2_LoopPosition then Lp := tm;
       j1 := WordPtr(@Index[PT2_PatternsPointer +
                                PT2_PositionList[i] * 6])^;
       j2 := WordPtr(@Index[PT2_PatternsPointer +
                                PT2_PositionList[i] * 6 + 2])^;
       j3 := WordPtr(@Index[PT2_PatternsPointer +
                                PT2_PositionList[i] * 6 + 4])^;
       repeat
        dec(a1);
        if a1 < 0 then
         begin
          if Index[j1] = 0 then break;
          repeat
           case Index[j1] of
           $70,$80..$e0:
            begin
             a1 := a11;
             incr(j1);
             break
            end;
           $71..$7e:
            inc(j1,2);
           $20..$5f:
            a11 := Index[j1] - $20;
           $f:
            begin
             incr(j1);
             b := Index[j1]
            end;
           1..$b,$e:
            inc(j1);
           $d:
            inc(j1,3)
           end;
           incr(j1)
          until False
         end;
        dec(a2);
        if a2 < 0 then
         repeat
          case Index[j2] of
          $70,$80..$e0:
           begin
            a2 := a22;
            incr(j2);
            break
           end;
          $71..$7e:
           inc(j2,2);
          $20..$5f:
           a22 := Index[j2] - $20;
          $f:
           begin
            incr(j2);
            b := Index[j2]
           end;
          1..$b,$e:
           inc(j2);
          $d:
           inc(j2,3)
          end;
          incr(j2)
         until False;
        dec(a3);
        if a3 < 0 then
         repeat
          case Index[j3] of
          $70,$80..$e0:
           begin
            a3 := a33;
            incr(j3);
            break
           end;
          $71..$7e:
           inc(j3,2);
          $20..$5f:
           a33 := Index[j3] - $20;
          $f:
           begin
            incr(j3);
            b := Index[j3]
           end;
          1..$b,$e:
           inc(j3);
          $d:
           inc(j3,3)
          end;
          incr(j3)
         until False;
        Inc(tm,b);
        Dec(DLCatcher);
        if DLCatcher < 0 then RaiseBadFileStructure
       until False;
       inc(i)
     until False
    end
end;

procedure GetTimePT3(Module:PModTypes;var Tm,Lp:integer);
var
 b:byte;
 a1,a2,a3,a11,a22,a33:shortint;
 j1,j2,j3:longword;
 i,j,DLCatcher:integer;
 c1,c2,c3,c4,c5,c8:integer;
begin
   with Module^ do
    begin
     b := PT3_Delay;
     a11 := 1; a22 := 1; a33 := 1;
     DLCatcher := 16384;
     for i := 0 to PT3_NumberOfPositions - 1 do
      begin
       if i = PT3_LoopPosition then Lp := tm;
       j1 := WordPtr(@Index[PT3_PatternsPointer +
                                PT3_PositionList[i] * 2])^;
       j2 := WordPtr(@Index[PT3_PatternsPointer +
                                PT3_PositionList[i] * 2 + 2])^;
       j3 := WordPtr(@Index[PT3_PatternsPointer +
                                PT3_PositionList[i] * 2 + 4])^;
       a1 := 1; a2 := 1; a3 := 1;
       repeat
        dec(a1);
        if a1 = 0 then
         begin
          if Index[j1] = 0 then break;
          j := 0; c1 := 0; c2 := 0; c3 := 0; c4 := 0; c5 := 0; c8 := 0;
          repeat
           case Index[j1] of
           $d0,$c0,$50..$af:
            begin
             a1 := a11;
             incr(j1);
             break
            end;
           $10,$f0..$ff:
            inc(j1);
           $b2..$bf:
            inc(j1,2);
           $b1:
            begin
             incr(j1);
             a11 := Index[j1]
            end;
           $11..$1f:
            inc(j1,3);
           1:
            begin
             inc(j);
             c1 := j
            end;
           2:
            begin
             inc(j);
             c2 := j
            end;
           3:
            begin
             inc(j);
             c3 := j
            end;
           4:
            begin
             inc(j);
             c4 := j
            end;
           5:
            begin
             inc(j);
             c5 := j
            end;
           8:
            begin
             inc(j);
             c8 := j
            end;
           9:
            inc(j)
           end;
           incr(j1)
          until False;
          while j > 0 do
           begin
            if (j = c1) or (j = c8) then
             inc(j1,3)
            else if (j = c2) then
             inc(j1,5)
            else if (j = c3) or (j = c4) then
             inc(j1)
            else if (j = c5) then
             inc(j1,2)
            else
             begin
              b := Index[j1];
              inc(j1)
             end;
            if j1 >= 65536 then RaiseBadFileStructure;
            dec(j)
           end
         end;
        dec(a2);
        if a2 = 0 then
         begin
          j := 0; c1 := 0; c2 := 0; c3 := 0; c4 := 0; c5 := 0; c8 := 0;
          repeat
           case Index[j2] of
           $d0,$c0,$50..$af:
            begin
             a2 := a22;
             incr(j2);
             break
            end;
           $10,$f0..$ff:
            inc(j2);
           $b2..$bf:
            inc(j2,2);
           $b1:
            begin
             incr(j2);
             a22 := Index[j2]
            end;
           $11..$1f:
            inc(j2,3);
           1:
            begin
             inc(j);
             c1 := j
            end;
           2:
            begin
             inc(j);
             c2 := j
            end;
           3:
            begin
             inc(j);
             c3 := j
            end;
           4:
            begin
             inc(j);
             c4 := j
            end;
           5:
            begin
             inc(j);
             c5 := j
            end;
           8:
            begin
             inc(j);
             c8 := j
            end;
           9:
            inc(j)
           end;
           incr(j2)
          until False;
          while j > 0 do
           begin
            if (j = c1) or (j = c8) then
             inc(j2,3)
            else if (j = c2) then
             inc(j2,5)
            else if (j = c3) or (j = c4) then
             inc(j2)
            else if (j = c5) then
             inc(j2,2)
            else
             begin
              b := Index[j2];
              inc(j2)
             end;
            if j2 >= 65536 then RaiseBadFileStructure;
            dec(j)
           end
         end;
        dec(a3);
        if a3 = 0 then
         begin
          j := 0; c1 := 0; c2 := 0; c3 := 0; c4 := 0; c5 := 0; c8 := 0;
          repeat
           case Module.Index[j3] of
           $d0,$c0,$50..$af:
            begin
             a3 := a33;
             incr(j3);
             break
            end;
           $10,$f0..$ff:
            inc(j3);
           $b2..$bf:
            inc(j3,2);
           $b1:
            begin
             incr(j3);
             a33 := Index[j3]
            end;
           $11..$1f:
            inc(j3,3);
           1:
            begin
             inc(j);
             c1 := j
            end;
           2:
            begin
             inc(j);
             c2 := j
            end;
           3:
            begin
             inc(j);
             c3 := j
            end;
           4:
            begin
             inc(j);
             c4 := j
            end;
           5:
            begin
             inc(j);
             c5 := j
            end;
           8:
            begin
             inc(j);
             c8 := j
            end;
           9:
            inc(j)
           end;
           incr(j3)
          until False;
          while j > 0 do
           begin
            if (j = c1) or (j = c8) then
             inc(j3,3)
            else if (j = c2) then
             inc(j3,5)
            else if (j = c3) or (j = c4) then
             inc(j3)
            else if (j = c5) then
             inc(j3,2)
            else
             begin
              b := Index[j3];
              inc(j3)
             end;
            if j3 >= 65536 then RaiseBadFileStructure;
            dec(j)
           end
         end;
        Inc(tm,b);
        Dec(DLCatcher);
        if DLCatcher < 0 then RaiseBadFileStructure
       until False
      end
    end
end;

procedure GetTimePSC(Module:PModTypes;var Tm,Lp:integer);
var
 b:byte;
 pptr,cptr:longword;
 j1,j2,j3:longword;
 a1,a2,a3:shortint;
 i:integer;
begin
   with Module^ do
    begin
     b := PSC_Delay;
     pptr := PSC_PatternsPointer;
     incr(pptr);
     while Index[pptr] <> 255 do
      begin
       inc(pptr,8);
       if pptr >= 65536 then RaiseBadFileStructure
      end;
     if pptr >= 65536 - 2 then RaiseBadFileStructure;
     cptr := WordPtr(@Index[pptr + 1])^;
     incr(cptr);
     pptr := PSC_PatternsPointer;
     incr(pptr);
     while Index[pptr] <> 255 do
      begin
       if pptr = cptr then Lp := tm;
       if pptr >= 65536 - 6 then RaiseBadFileStructure;
       j1 := WordPtr(@Index[pptr + 1])^;
       j2 := WordPtr(@Index[pptr + 3])^;
       j3 := WordPtr(@Index[pptr + 5])^;
       Inc(pptr,8);
       if pptr >= 65536 then RaiseBadFileStructure;
       a1 := 1; a2 := 1; a3 := 1;
       for i := 1 to Index[pptr - 8] do
        begin
         dec(a1);
         if a1 = 0 then
          repeat
           case Index[j1] of
           $c0..$ff:
            begin
             a1 := Index[j1] - $bf;
             inc(j1);
             break
            end;
           $67..$6d,$6f..$7b:
            inc(j1);
           $6e:
            begin
             incr(j1);
             b := Index[j1]
            end
           end;
           incr(j1)
          until False;
         dec(a2);
         if a2 = 0 then
          repeat
           case Index[j2] of
           $c0..$ff:
            begin
             a2 := Index[j2] - $bf;
             inc(j2);
             break
            end;
           $67..$6d,$6f..$79,$7b:
            inc(j2);
           $6e:
            begin
             incr(j2);
             b := Index[j2]
            end;
           $7a:
            inc(j2,3)
           end;
           incr(j2)
          until False;
         dec(a3);
         if a3 = 0 then
          repeat
           case Index[j3] of
           $c0..$ff:
            begin
             a3 := Index[j3] - $bf;
             inc(j3);
             break
            end;
           $67..$6d,$6f..$7b:
            inc(j3);
           $6e:
            begin
             incr(j3);
             b := Index[j3]
            end
           end;
           incr(j3)
          until False;
         Inc(tm,b)
        end
      end
    end
end;

procedure GetTimeFTC(Module:PModTypes;var Tm,Lp:integer);
var
 b:byte;
 i:integer;
 j1,j2,j3:longword;
 a1,a2,a3:shortint;
 DLCatcher:integer;
begin
   with Module^ do
    begin
     b := FTC_Delay;
     i := 0;
     repeat
      if FTC_Positions[i].Pattern = 255 then break;
      if i = FTC_Loop_Position then Lp := tm;
      j1 := WordPtr(@Index[FTC_PatternsPointer +
                           FTC_Positions[i].Pattern * 6])^;
      j2 := WordPtr(@Index[FTC_PatternsPointer +
                           FTC_Positions[i].Pattern * 6 + 2])^;
      j3 := WordPtr(@Index[FTC_PatternsPointer +
                           FTC_Positions[i].Pattern * 6 + 4])^;
      Inc(i);
      if i >= (65536 - $d4) div 2 then RaiseBadFileStructure;
      a1 := 0; a2 := 0; a3 := 0;
      DLCatcher := 256;
      repeat
       Dec(a1);
       if a1 < 0 then
        begin
         if Index[j1] = 255 then break;
         repeat
          case Index[j1] of
          $30,$60..$cb:
           begin
            a1 := 0;
            Incr(j1);
            break
           end;
          $40..$5f:
           begin
            a1 := Index[j1] - $40;
            Incr(j1);
            break
           end;
          $ee,$ef:
           Inc(j1);
          $31..$3e,$ed:
           Inc(j1,2);
          $f0..$ff:
           begin
            Incr(j1);
            b := Index[j1]
           end
          end;
          Incr(j1)
         until False
        end;
        Dec(a2);
        if a2 < 0 then
         repeat
          case Index[j2]of
          $30,$60..$cb:
           begin
            a2 := 0;
            Incr(j2);
            break
           end;
          $40..$5f:
           begin
            a2 := Index[j2] - $40;
            Incr(j2);
            break
           end;
          $ee,$ef:
           inc(j2);
          $31..$3e,$ed:
           inc(j2,2);
          $f0..$ff:
           begin
            incr(j2);
            b := Index[j2]
           end
          end;
          Incr(j2)
         until False;
        Dec(a3);
        if a3 < 0 then
         repeat
          case Index[j3] of
          $30,$60..$cb:
           begin
            a3 := 0;
            Incr(j3);
            break
           end;
          $40..$5f:
           begin
            a3 := Index[j3] - $40;
            Incr(j3);
            break
           end;
          $ee,$ef:
           inc(j3);
          $31..$3e,$ed:
           inc(j3,2);
          $f0..$ff:
           begin
            Incr(j3);
            b := Index[j3]
           end
          end;
          Incr(j3)
         until False;
        Inc(tm,b);
        Dec(DLCatcher);
        if DLCatcher < 0 then RaiseBadFileStructure
      until False
     until False
    end
end;

procedure GetTimeSQT(Module:PModTypes;var Tm,Lp:integer);
var
 pptr,cptr:longword;
 f71,f72,f73,
 f61,f62,f63,
 f41,f42,f43,flg:boolean;
 j1,j2,j3:longword;
 j11,j22,j33:word;
 b:byte;
 a1,a2,a3:shortint;
 i:integer;
begin
   with Module^ do
    begin
     pptr := SQT_PositionsPointer;
     while Index[pptr] <> 0 do
      begin
       if pptr = SQT_LoopPointer then Lp := tm;
       f41 := Index[pptr] and 128 <> 0;
       j1 := WordPtr(@Index[byte(Index[pptr] * 2) + SQT_PatternsPointer])^;
       Incr(j1);
       Inc(pptr,2);
       if pptr >= 65536 then RaiseBadFileStructure;
       f42 := Index[pptr] and 128 <> 0;
       j2 := WordPtr(@Index[byte(Index[pptr] * 2) + SQT_PatternsPointer])^;
       Incr(j2);
       Inc(pptr,2);
       if pptr >= 65536 then RaiseBadFileStructure;
       f43 := Index[pptr] and 128 <> 0;
       j3 := WordPtr(@Index[byte(Index[pptr] * 2) + SQT_PatternsPointer])^;
       Incr(j3);
       Inc(pptr,2);
       if pptr >= 65536 then RaiseBadFileStructure;
       b := Index[pptr];
       Incr(pptr);
       a1 := 0; a2 := 0; a3 := 0;
       for i := 1 to Index[j1 - 1] do
        begin
         if a1 <> 0 then
          begin
           dec(a1);
           if f71 then
            begin
             cptr := j11;
             f61 := False;
             if Index[cptr] in [0..$7f] then
              begin
               Incr(cptr);
               case Index[cptr] of
               0..$7f:
                begin
                 Incr(cptr);
                 if f61 then j1 := cptr + 1;
                 case Index[cptr - 1] - 1 of
                 4:
                  if f41 then
                   begin
                    b := Index[cptr] and 31;
                    if b = 0 then b := 32
                   end;
                 5:
                  if f41 then
                   begin
                    b := (b + Index[cptr]) and 31;
                    if b = 0 then b := 32
                   end
                 end
                end;
               $80..$ff:
                begin
                 if Index[cptr] and 64 <> 0 then
                  begin
                   Incr(cptr);
                   if Index[cptr] and 15 <> 0 then
                    begin
                     Incr(cptr);
                     if f61 then j1 := cptr + 1;
                     case (Index[cptr - 1]) and 15 - 1 of
                     4:
                      if f41 then
                       begin
                        b := Index[cptr] and 31;
                        if b = 0 then b := 32
                       end;
                     5:
                      if f41 then
                       begin
                        b := (b + Index[cptr]) and 31;
                        if b = 0 then b := 32
                       end
                     end
                    end
                  end
                end
               end
              end
            end
          end
         else
          begin
           if j1 >= 65536 then RaiseBadFileStructure;
           cptr := j1;
           f61 := True;
           f71 := False;
           repeat
            case Index[cptr] of
            0..$5f:
             begin
              j11 := cptr;
              Incr(cptr);
              case Index[cptr] of
              0..$7f:
               begin
                Incr(cptr);
                if f61 then
                 begin
                  j1 := cptr + 1;
                  f61 := False
                 end;
                case Index[cptr - 1] - 1 of
                4:
                 if f41 then
                  begin
                   b := Index[cptr] and 31;
                   if b = 0 then b := 32
                  end;
                5:
                 if f41 then
                  begin
                   b := (b + Index[cptr]) and 31;
                   if b = 0 then b := 32
                  end
                end
               end;
              $80..$ff:
               begin
                if Index[cptr] and 64 <> 0 then
                 begin
                  Incr(cptr);
                  if Index[cptr] and 15 <> 0 then
                   begin
                    Incr(cptr);
                    if f61 then
                     begin
                      j1 := cptr + 1;
                      f61 := False
                     end;
                    case Index[cptr - 1] and 15 - 1 of
                    4:
                     if f41 then
                      begin
                       b := Index[cptr] and 31;
                       if b = 0 then b := 32
                      end;
                    5:
                     if f41 then
                      begin
                       b := (b + Index[cptr]) and 31;
                       if b = 0 then b := 32
                      end
                    end
                   end
                 end
               end
              end;
              Incr(cptr);
              if f61 then j1 := cptr;
              break
             end;
            $60..$6e:
             begin
              Incr(cptr);
              if f61 then j1 := cptr + 1;
              case Index[cptr - 1] - $60 - 1 of
              4:
               if f41 then
                begin
                 b := Index[cptr] and 31;
                 if b = 0 then b := 32
                end;
              5:if f41 then
               begin
                b := (b + Index[cptr]) and 31;
                if b = 0 then b := 32
               end
              end;
              break
             end;
            $6f..$7f:
             begin
              if Index[cptr] <> $6f then
               begin
                Incr(cptr);
                if f61 then j1 := cptr + 1;
                case Index[cptr - 1] - $6f - 1 of
                4:
                 if f41 then
                  begin
                   b := Index[cptr] and 31;
                   if b = 0 then b := 32
                  end;
                5:
                 if f41 then
                  begin
                   b := (b + Index[cptr]) and 31;
                   if b = 0 then b := 32
                  end
                end
               end
              else
               j1 := cptr + 1;
              break
             end;
            $80..$bf:
             begin
              j1 := cptr + 1;
              if Index[cptr] in [$a0..$bf] then
               begin
                a1 := Index[cptr] and 15;
                if Index[cptr] and 16 = 0 then break;
                if a1 <> 0 then f71 := True
               end;
              cptr := j11;
              f61 := False;
              if Index[cptr] in [0..$7f] then
               begin
                Incr(cptr);
                case Index[cptr] of
                0..$7f:
                 begin
                  Incr(cptr);
                  if f61 then j1 := cptr + 1;
                  case Index[cptr - 1] - 1 of
                  4:
                   if f41 then
                    begin
                     b := Index[cptr] and 31;
                     if b = 0 then b := 32
                    end;
                   5:
                    if f41 then
                     begin
                      b := (b + Index[cptr]) and 31;
                      if b = 0 then b := 32
                     end
                   end
                 end;
                $80..$ff:
                 begin
                  if Index[cptr] and 64 <> 0 then
                   begin
                    Incr(cptr);
                    if Index[cptr] and 15 <> 0 then
                     begin
                      Incr(cptr);
                      if f61 then j1 := cptr + 1;
                      case (Index[cptr - 1]) and 15 - 1 of
                      4:
                       if f41 then
                        begin
                         b := Index[cptr] and 31;
                         if b = 0 then b := 32
                        end;
                      5:
                       if f41 then
                        begin
                         b := (b + Index[cptr]) and 31;
                         if b = 0 then b := 32
                        end
                      end
                     end
                   end
                 end
                end
               end;
              break
             end;
            $c0..$ff:
             begin
              j1 := cptr + 1;
              j11 := cptr;
              break
             end
            end
           until False
          end;
         if a2 <> 0 then
          begin
           dec(a2);
           if f72 then
            begin
             cptr := j22;
             f62 := False;
             if Index[cptr] in [0..$7f] then
              begin
               incr(cptr);
               case Index[cptr] of
               0..$7f:
                begin
                 incr(cptr);
                 if f62 then j2 := cptr + 1;
                 case Index[cptr - 1] - 1 of
                 4:
                  if f42 then
                   begin
                    b := Index[cptr] and 31;
                    if b = 0 then b := 32
                   end;
                 5:
                  if f42 then
                   begin
                    b := (b + Index[cptr]) and 31;
                    if b = 0 then b := 32
                   end
                 end
                end;
               $80..$ff:
                begin
                 if Index[cptr] and 64 <> 0 then
                  begin
                   incr(cptr);
                   if Index[cptr] and 15 <> 0 then
                    begin
                     incr(cptr);
                     if f62 then j2 := cptr + 1;
                     case Index[cptr - 1] and 15 - 1 of
                     4:
                      if f42 then
                       begin
                        b := Index[cptr] and 31;
                        if b = 0 then b := 32
                       end;
                     5:
                      if f42 then
                       begin
                        b := (b + Index[cptr]) and 31;
                        if b = 0 then b := 32
                       end
                     end
                    end
                  end
                end
               end
              end
            end
          end
         else
          begin
           if j2 >= 65536 then RaiseBadFileStructure;
           cptr := j2;
           f62 := True;
           f72 := False;
           repeat
            case Index[cptr] of
            0..$5f:
             begin
              j22 := cptr;
              Incr(cptr);
              case Index[cptr] of
              0..$7f:
               begin
                Incr(cptr);
                if f62 then
                 begin
                  j2 := cptr + 1;
                  f62 := False
                 end;
                case Index[cptr - 1] - 1 of
                4:
                 if f42 then
                  begin
                   b := Index[cptr] and 31;
                   if b = 0 then b := 32
                  end;
                5:
                 if f42 then
                  begin
                   b := (b + Index[cptr]) and 31;
                   if b = 0 then b := 32
                  end
                end
               end;
              $80..$ff:
               begin
                if Index[cptr] and 64 <> 0 then
                 begin
                  Incr(cptr);
                  if Index[cptr] and 15 <> 0 then
                   begin
                    Incr(cptr);
                    if f62 then
                     begin
                      j2 := cptr + 1;
                      f62 := False
                     end;
                    case Index[cptr - 1] and 15 - 1 of
                    4:
                     if f42 then
                      begin
                       b := Index[cptr] and 31;
                       if b = 0 then b := 32
                      end;
                    5:
                     if f42 then
                      begin
                       b := (b + Index[cptr]) and 31;
                       if b = 0 then b := 32
                      end
                    end
                   end
                 end
               end
              end;
              incr(cptr);
              if f62 then j2 := cptr;
              break
             end;
            $60..$6e:
             begin
              incr(cptr);
              if f62 then j2 := cptr + 1;
              case Index[cptr - 1] - $60 - 1 of
              4:
               if f42 then
                begin
                 b := Index[cptr] and 31;
                 if b = 0 then b := 32
                end;
              5:
               if f42 then
                begin
                 b := (b + Index[cptr]) and 31;
                 if b = 0 then b := 32
                end
              end;
              break
             end;
            $6f..$7f:
             begin
              if Index[cptr] <> $6f then
               begin
                incr(cptr);
                if f62 then j2 := cptr + 1;
                case Index[cptr - 1] - $6f - 1 of
                4:
                 if f42 then
                  begin
                   b := Index[cptr] and 31;
                   if b = 0 then b := 32
                  end;
                5:
                 if f42 then
                  begin
                   b := (b + Index[cptr]) and 31;
                   if b = 0 then b := 32
                  end
                end
               end
              else
               j2 := cptr + 1;
              break
             end;
            $80..$bf:
             begin
              j2 := cptr + 1;
              if not (Index[cptr] in [$80..$9f]) then
               begin
                a2 := Index[cptr] and 15;
                if Index[cptr] and 16 = 0 then break;
                if a2 <> 0 then f72 := True
               end;
              cptr := j22;
              f62 := False;
              if Index[cptr] in [0..$7f] then
               begin
                incr(cptr);
                case Index[cptr] of
                0..$7f:
                 begin
                  incr(cptr);
                  if f62 then j2 := cptr + 1;
                  case Index[cptr - 1] - 1 of
                  4:
                   if f42 then
                    begin
                     b := Index[cptr] and 31;
                     if b = 0 then b := 32
                    end;
                  5:
                   if f42 then
                    begin
                     b := (b + Index[cptr]) and 31;
                     if b = 0 then b := 32
                    end
                  end
                 end;
                $80..$ff:
                 begin
                  if Index[cptr] and 64 <> 0 then
                   begin
                    incr(cptr);
                    if Index[cptr] and 15 <> 0 then
                     begin
                      incr(cptr);
                      if f62 then j2 := cptr + 1;
                      case Index[cptr - 1] and 15 - 1 of
                      4:
                       if f42 then
                        begin
                         b := Index[cptr] and 31;
                         if b = 0 then b := 32
                        end;
                      5:
                       if f42 then
                        begin
                         b := (b + Index[cptr]) and 31;
                         if b = 0 then b := 32
                        end
                      end
                     end
                   end
                 end
                end
               end;
              break
             end;
            $c0..$ff:
             begin
              j2 := cptr + 1;
              j22 := cptr;
              break
             end
            end
           until False
          end;
         if a3 <> 0 then
          begin
           Dec(a3);
           if f73 then
            begin
             cptr := j33;
             f63 := False;
             if Index[cptr] in [0..$7f] then
              begin
               incr(cptr);
               case Index[cptr] of
               0..$7f:
                begin
                 incr(cptr);
                 if f63 then j3 := cptr + 1;
                 case Index[cptr - 1] - 1 of
                 4:
                  if f43 then
                   begin
                    b := Index[cptr] and 31;
                    if b = 0 then b := 32
                   end;
                 5:
                  if f43 then
                   begin
                    b := (b + Index[cptr]) and 31;
                    if b = 0 then b := 32
                   end
                 end
                end;
               $80..$ff:
                begin
                 if Index[cptr] and 64 <> 0 then
                  begin
                   Incr(cptr);
                   if Index[cptr] and 15 <> 0 then
                    begin
                     Incr(cptr);
                     if f63 then j3 := cptr + 1;
                     case Index[cptr - 1] and 15 - 1 of
                     4:
                      if f43 then
                       begin
                        b := Index[cptr] and 31;
                        if b = 0 then b := 32
                       end;
                     5:
                      if f43 then
                       begin
                        b := (b + Index[cptr]) and 31;
                        if b = 0 then b := 32
                       end
                     end
                    end
                  end
                end
               end
             end
            end
          end
         else
          begin
           if j3 >= 65536 then RaiseBadFileStructure;
           cptr := j3;
           f63 := True;
           f73 := False;
           repeat
            case Index[cptr] of
            0..$5f:
             begin
              j33 := cptr;
              Incr(cptr);
              case Index[cptr] of
              0..$7f:
               begin
                Incr(cptr);
                if f63 then
                 begin
                  j3 := cptr + 1;
                  f63 := False
                 end;
                case Index[cptr - 1] - 1 of
                4:
                 if f43 then
                  begin
                   b := Index[cptr] and 31;
                   if b = 0 then b := 32
                  end;
                5:
                 if f43 then
                  begin
                   b := (b + Index[cptr]) and 31;
                   if b = 0 then b := 32
                  end
                end
               end;
              $80..$ff:
               begin
                if Index[cptr] and 64 <> 0 then
                 begin
                  Incr(cptr);
                  if Index[cptr] and 15 <> 0 then
                   begin
                    Incr(cptr);
                    if f63 then
                     begin
                      j3 := cptr + 1;
                      f63 := False
                     end;
                    case Index[cptr - 1] and 15 - 1 of
                    4:
                     if f43 then
                      begin
                       b := Index[cptr] and 31;
                       if b = 0 then b := 32
                      end;
                    5:
                     if f43 then
                      begin
                       b := (b + Index[cptr]) and 31;
                       if b = 0 then b := 32
                      end
                    end
                   end
                 end
               end
              end;
              incr(cptr);
              if f63 then j3 := cptr;
              break
             end;
            $60..$6e:
             begin
              incr(cptr);
              if f63 then j3 := cptr + 1;
              case Index[cptr - 1] - $60 - 1 of
              4:
               if f43 then
                begin
                 b := Index[cptr] and 31;
                 if b = 0 then b := 32
                end;
              5:
               if f43 then
                begin
                 b := (b + Index[cptr]) and 31;
                 if b = 0 then b := 32
                end
              end;
              break
             end;
            $6f..$7f:
             begin
              if Index[cptr] <> $6f then
               begin
                Incr(cptr);
                if f63 then j3 := cptr + 1;
                case Index[cptr - 1] - $6f - 1 of
                4:
                 if f43 then
                  begin
                   b := Index[cptr] and 31;
                   if b = 0 then b := 32
                  end;
                5:
                 if f43 then
                  begin
                   b := (b + Index[cptr]) and 31;
                   if b = 0 then b := 32
                  end
                end
               end
              else
               j3 := cptr + 1;
              break
             end;
            $80..$bf:
             begin
              j3 := cptr + 1;
              if not (Index[cptr] in [$80..$9f]) then
               begin
                a3 := Index[cptr] and 15;
                if Index[cptr] and 16 = 0 then break;
                if a3 <> 0 then f73 := True
               end;
              cptr := j33;
              f63 := False;
              if Index[cptr] in [0..$7f] then
               begin
                Incr(cptr);
                case Index[cptr] of
                0..$7f:
                 begin
                  Incr(cptr);
                  if f63 then j3 := cptr + 1;
                  case Index[cptr - 1] - 1 of
                   4:
                    if f43 then
                     begin
                      b := Index[cptr] and 31;
                      if b = 0 then b := 32
                     end;
                   5:
                    if f43 then
                     begin
                      b := (b + Index[cptr]) and 31;
                      if b = 0 then b := 32
                     end
                   end
                 end;
                $80..$ff:
                 begin
                  if Index[cptr] and 64 <> 0 then
                   begin
                    Incr(cptr);
                    if Index[cptr] and 15 <> 0 then
                     begin
                      Incr(cptr);
                      if f63 then j3 := cptr + 1;
                      case Index[cptr - 1] and 15 - 1 of
                      4:
                       if f43 then
                        begin
                         b := Index[cptr] and 31;
                         if b = 0 then b := 32
                        end;
                      5:
                       if f43 then
                        begin
                         b := (b + Index[cptr]) and 31;
                         if b = 0 then b := 32
                        end
                      end
                     end
                   end
                 end
                end
               end;
              break
             end;
            $c0..$ff:
             begin
              j3 := cptr + 1;
              j33 := cptr;
              break
             end;
            end
           until False
          end;
         Inc(tm,b)
        end
      end
    end
end;

procedure GetTimePT1(Module:PModTypes;var Tm,Lp:integer);
var
 b:byte;
 j1,j2,j3:longword;
 a1,a2,a3,a11,a22,a33:shortint;
 DLCatcher:integer;
 i:integer;
begin
   with Module^ do
    begin
     b := PT1_Delay;
     a1 := 0; a2 := 0; a3 := 0;
     a11 := 0; a22 := 0; a33 := 0;
     DLCatcher := 16384;
     for i := 0 to PT1_NumberOfPositions - 1 do
      begin
       if i = PT1_LoopPosition then Lp := tm;
       j1 := WordPtr(@Index[PT1_PatternsPointer +
                                        PT1_PositionList[i] * 6])^;
       j2 := WordPtr(@Index[PT1_PatternsPointer +
                                        PT1_PositionList[i] * 6 + 2])^;
       j3 := WordPtr(@Index[PT1_PatternsPointer +
                                        PT1_PositionList[i] * 6 + 4])^;
       repeat
        Dec(a1);
        if a1 < 0 then
         begin
          if Index[j1] = 255 then break;
           repeat
            case Index[j1] of
            $80,$90,0..$5f:
             begin
              a1 := a11;
              Incr(j1);
              break
             end;
            $82..$8f:
             Inc(j1,2);
            $b1..$fe:
             a11 := Index[j1] - $b1;
            $91..$a0:
             b := Index[j1] - $91;
            end;
            Incr(j1)
           until False
         end;
        Dec(a2);
        if a2 < 0 then
         repeat
          case Index[j2] of
          $80,$90,0..$5f:
           begin
            a2 := a22;
            Incr(j2);
            break
           end;
          $82..$8f:
           Inc(j2,2);
          $b1..$fe:
           a22 := Index[j2] - $b1;
          $91..$a0:
           b := Index[j2] - $91
          end;
          Incr(j2)
         until False;
        Dec(a3);
        if a3 < 0 then
         repeat
          case Index[j3] of
          $80,$90,0..$5f:
           begin
            a3 := a33;
            Incr(j3);
            break
           end;
          $82..$8f:
           Inc(j3,2);
          $b1..$fe:
           a33 := Index[j3] - $b1;
          $91..$a0:
           b := Index[j3] - $91
          end;
          Incr(j3)
         until False;
        Inc(tm,b);
        Dec(DLCatcher);
        if DLCatcher < 0 then RaiseBadFileStructure
       until False
      end
    end
end;

procedure GetTimeFLS(Module:PModTypes;var Tm:integer);
var
 b:byte;
 a1,a11:shortint;
 i:integer;
 pptr:longword;
 j1:longword;
begin
   with Module^ do
    begin
     b := Index[FLS_PositionsPointer];
     a1 := 0; a11 := 0; i := 0;
     repeat
      pptr := i + FLS_PositionsPointer + 1;
      if pptr >= 65536 then RaiseBadFileStructure;
      if Index[pptr] = 0 then break;
      j1 := FLS_PatternsPointers[Index[pptr]].PatternA;
      repeat
       Dec(a1);
       if a1 < 0 then
        begin
         if Index[j1] = 255 then break;
         repeat
          case Index[j1] of
          0..$5f,$80,$81:
           begin
            Incr(j1);
            a1 := a11;
            break
           end;
          $82..$8e:
           Inc(j1);
          $8f..$ff:
           a11 := Index[j1] - $a1
          end;
          Incr(j1)
         until False
        end;
       Inc(tm,b)
      until False;
      Inc(i)
     until False
    end
end;

procedure GetTimePSM(Module:PModTypes;var Tm,Lp:integer);
var
 d,b,a,rc:byte;
 p,l,j,ra:longword;
begin
with Module^ do
 begin
  p := PSM_PositionsPointer;
  if Index[p] = 255 then RaiseBadFileStructure;
  l := p;
  repeat
   inc(p);
   incr(p)
  until Index[p] = 255;
  incr(p);
  d := Index[p];
  if d <> 255 then
   begin
    l := PSM_PositionsPointer + d;
    if l > p - 3 then RaiseBadFileStructure
   end;

  p := PSM_PositionsPointer;
  repeat
   if p = l then Lp := Tm;
   d := Index[p]; if d = 255 then break;
   j := PSM_PatternsPointer + d * 7 + 5;
   if j >= 65535 then RaiseBadFileStructure;
   j := WordPtr(@Index[j])^;
   d := Index[PSM_PatternsPointer + d * 7];
   a := 1;
   rc := 0;
   repeat
    if rc <> 0 then
     begin
      dec(rc);
      if rc = 0 then j := ra
     end;
    b := Index[j];
    case b of
    0..$60,$90,$fc..$fe:
     inc(Tm,d*a);
    $b1..$b7:
     inc(j);
    $b8..$f8:
     a := b - $b7;
    $f9:
     begin
      ra := j + 3; if ra >= 65536 then RaiseBadFileStructure;
      rc := Index[j + 2];
      j := WordPtr(@Index[j])^ - 1;
     end;
    $ff:break
    end;
    incr(j)
   until False;
   inc(p); incr(p)
  until False;
 end;
end;

procedure GetTime;
var
 Module:PModTypes;
 t:smallint;
 b,b1:byte;
 i,j,tm:integer;
 EPSGRec:packed record
  case Boolean of
  True:(Reg,Data:byte;
        TSt:longword);
  False:(All:int64);
 end;
 bassh:integer;
 MSF:packed record
  case boolean of
  True: (MSF:DWORD);
  False:(M,S,F:byte);
 end;

begin
Lp := 0;
tm := 0;

with PlayListItems[Index]^ do
begin

try

if FileType in [TrkFileMin..TrkFileMax] then
 if not AlreadyLoaded then
  begin
   New(Module);
   if not LoadTrackerModule(Module^,Index,0,0,nil,Unknown) then
    begin
     Dispose(Module);
     exit
    end
  end
 else
  Module := @RAM;

try

case FileType of
OUTFile:
 with UniReadersData[FileHandle]^ do
  begin
   UniFileSeek(FileHandle,0);
   repeat
    UniRead(FileHandle,@t,2);
    if (t = -1) or (t = 0) then Inc(tm);
    UniFileSeek(FileHandle,UniFilePos + 3);
   until UniFilePos >= UniFileSize;
   tm := round(tm * 1000 / (FrqZ80 / 17472));
   if t > 0 then
    Inc(tm,round((t / 17472) * 1000 / (FrqZ80 / 17472)))
  end;
EPSGFile:
 with UniReadersData[FileHandle]^ do
  begin
   UniFileSeek(FileHandle,5);
   UniRead(FileHandle,@b,1);
   case b of
   0:   i := 70908;
   255: UniRead(FileHandle,@i,4)
   else i := 71680;
   end;
   UniFileSeek(FileHandle,16);
   EPSGRec.All := 0;
   while UniFilePos < UniFileSize do
    begin
     UniRead(FileHandle,@EPSGRec,5);
     if EPSGRec.All = $FFFFFFFFFF then Inc(tm)
    end;
   if EPSGRec.All  = $FFFFFFFFFF then
    j := 0
   else
    j := EPSGRec.TSt;
   tm := round((tm / (FrqZ80 / i) + j / FrqZ80) * 1000)
  end;
PSGFile:
 with UniReadersData[FileHandle]^ do
  begin
   UniFileSeek(FileHandle,16);
   while UniFilePos < UniFileSize do
    begin
     UniRead(FileHandle,@b,1);
     if b = 255 then Inc(tm)
     else if b = 254 then
      begin
       UniRead(FileHandle,@b1,1);
       Inc(tm,b1 * 4)
      end 
     else UniFileSeek(FileHandle,UniFilePos + 1);
    end;
   if not (b in [254,255]) then Inc(tm)
  end;
ZXAYFile:
 with UniReadersData[FileHandle]^ do
  begin
   UniFileSeek(FileHandle,4);
   while UniFilePos < UniFileSize do
    begin
     UniRead(FileHandle,@i,4);
     if i and $FFFFF = 0 then Inc(tm);
    end;
   tm := round(tm * 1000 / (FrqZ80 / $100000) +
                (t and $FFFFF) / FrqZ80 * 1000);
  end;
PT3File:
 GetTimePT3(Module,Tm,Lp);
PT2File:
 GetTimePT2(Module,Tm,Lp);
STCFile:
 GetTimeSTC(Module,Tm);
STPFile:
 GetTimeSTP(Module,Tm,Lp);
ASCFile,
ASC0File:
 GetTimeASC(Module,Tm,Lp);
PSCFile:
 GetTimePSC(Module,Tm,Lp);
SQTFile:
 GetTimeSQT(Module,Tm,Lp);
FTCFile:
 GetTimeFTC(Module,Tm,Lp);
PT1File:
 GetTimePT1(Module,Tm,Lp);
FLSFile:
 GetTimeFLS(Module,Tm);
GTRFile:
 GetTimeGTR(Module,Tm,Lp);
FXMFile:
 GetTimeFXM(Module,Address,Tm,Lp);
PSMFile:
 GetTimePSM(Module,Tm,Lp);
BASSFileMin..BASSFileMax:
 begin
  Lp := -1;
  LoadBASS(FileType = WMAFile);
  if not BASSInitialized then InitBASS(BASS_NOSOUNDDEVICE,SampleRate,0,0);
  if FileType in [StreamFileMin..StreamFileMax] then
   begin
    bassh := BASS_StreamCreateFile2(FileType = WMAFile,pchar(FileName),BASS_STREAM_DECODE);
    if bassh = 0 then RaiseLastBASSError;
    Tm := BASS_StreamGetLength(bassh);
    if Tm = -1 then RaiseLastBASSError;
    Tm := round(BASS_ChannelBytes2Seconds(bassh,Tm) * 1000);
    BASSGetTags(Author,Title,bassh,FileType);
    BASS_StreamFree(bassh)
   end
  else
   begin
    bassh := BASS_MusicLoad(False,pchar(FileName),0,0,BASS_MUSIC_STOPBACK or
                                BASS_MUSIC_CALCLEN or BASS_MUSIC_NOSAMPLE,0);
    if bassh = 0 then RaiseLastBASSError;
    Tm := BASS_MusicGetLength(bassh,True);
    if Tm = -1 then RaiseLastBASSError;
    Tm := round(BASS_ChannelBytes2Seconds(bassh,Tm) * 1000);
    BASSGetTags(Author,Title,bassh,FileType);
    BASS_MusicFree(bassh)
   end
 end;
CDAFile:
 begin
  Lp := -1;
  InitCDDevice(Address);
  if not CheckCDNum(Address) then exit;
  MSF.MSF := CDGetTrackLength(Address,Offset);
  Tm := MSF.F + (MSF.S + MSF.M * 60) * 75
 end
end

finally

if (FileType in [TrkFileMin..TrkFileMax]) and not AlreadyLoaded then
 Dispose(Module);
if Tm = 0 then Error := ErBadFileStructure

end;

if Tm <> 0 then
 begin
  Time := Tm;
  if CalculateTotalTime(False) then
   begin
    if BASSInitialized and (BASSDevice = BASS_NOSOUNDDEVICE) then
     begin
      FreeBASS;
      UnloadBASS
     end;
    if not IsPlaying or (CurFileType <> CDAFile) then
     FreeAllCD
   end
 end

except
on EBASSError do Error := ErBASSError;
on EFileStructureError do Error := ErBadFileStructure;
else if Error = FileNoError then Error := ErReadingFile
end

end
end;

procedure SuspendPlaying;
begin
if not IsPlaying then exit;
WOResetPlaying(False);
{if (CurFileType in [AYFile,AYMFile]) and IntFlag then
 begin
  if IntBeeper then
   begin
    IntBeeper := False;
    Beeper := BeeperNext
   end;
  if IntAY then
   begin
    IntAY := False;
    SetAYRegister(RegNumNext,DatNext)
   end
 end;
ResetAYChipEmulation}
end;

procedure YMizeSample(Buf:PArrayOfByte;Len:integer);
var
 i1,k,k2:integer;
 b:byte;
begin
               for i1 := 0 to Len - 1 do
                begin
                 b := Buf[i1];
                 k2 := round(b/255*65535);
                 k := 1;
                 while (k < 32) and (Amplitudes_YM[k] < k2) do
                  inc(k,2);
                 if k > 1 then
                  if Amplitudes_YM[k] - k2 >
                                 k2 - Amplitudes_YM[k - 2] then
                   dec(k,2);
                 Buf[i1] := k div 2
                end
end;

var
 i,j:integer;
 
initialization

for i := 0 to 15 do
 for j := 0 to 7 do
  YM6SinusTable[i,j] := round(sin(j*2*pi/8)*i/2 + i/2);

for i := 0 to 39 do
 YMizeSample(sampleAdress[i],sampleLen[i]);

finalization 

end.

