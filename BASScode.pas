{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit BASScode;

interface

uses Windows,lightBASS;

var
 BASSFFTType:DWORD;
 BASSAmpMin:real;

 procedure StartBASS(WMA:boolean);
 procedure BASSVisualisation;

implementation

uses MainWin, WaveOutAPI, Players;

procedure BASSVisualisation;
var
 i,l,r,k:DWORD;
 q:QWORD;
 fft:array[0..2047] of FLOAT;
 k1:real;
begin
if (MusicHandle = 0) or Paused then exit;
    if MusicIsStream then
     begin
      q := BASS_ChannelGetPosition(MusicHandle); if q = -1 then exit;
      k1 := BASS_ChannelBytes2Seconds(MusicHandle,q); if k1 < 0 then exit;
      CurrTime_Rasch := round(k1 * 1000);
      VProgrPos := CurrTime_Rasch
     end
    else
     begin
      CurrTime_Rasch := GetTickCount - TimePlayStart;
      VProgrPos := CurrTime_Rasch
     end;
    if IndicatorChecked then
     begin
      l := BASS_ChannelGetLevel(MusicHandle);
      if l <> $FFFFFFFF then
       begin
        r := l shr 16;
        if r <= BASSAmpMin * 128 then
         r := 0
        else
         r := round(15/ln(1/BASSAmpMin)*ln(r/BASSAmpMin/32768));
        l := l and $FFFF;
        if l <= BASSAmpMin * 128 then
         l := 0
        else
         l := round(15/ln(1/BASSAmpMin)*ln(l/BASSAmpMin/32768));
        RedrawVisChannels(l,0,r,15)
       end
     end;
    if SpectrumChecked then
     begin
      k1 := spa_num/ln(20000/20);
      l := BASS_ChannelGetData(MusicHandle,@fft,BASSFFTType); if l = $FFFFFFFF then exit;
      BitBlt(DC_Vis,0,0,spa_width,spa_height,DC_Sources,spa_src,0,SRCCOPY);
      case BASSFFTType of
      BASS_DATA_FFT512: k := 512;
      BASS_DATA_FFT1024: k := 1024;
      BASS_DATA_FFT2048: k := 2048
      else k := 4096
      end;
      for i := 1 to k div 2 - 1 do
       begin
        r := round(k1 * ln(i/k/20*SampleRate));
        if r < spa_num then
         begin
          if fft[i] <= BASSAmpMin then
           l := spa_height
          else
           l := round(spa_height - spa_height/ln(1/BASSAmpMin)*ln(fft[i]/BASSAmpMin));
          if l < spa_height then
           begin
            MoveToex(DC_Vis,r,spa_height,nil);
            LineTo(DC_Vis,r,l + 1)
           end
         end
       end;
      BitBlt(DC_Window,spa_x,spa_y,spa_width,spa_height,DC_Vis,0,0,SRCCOPY)
     end;
    ShowProgress(VProgrPos);
end;

procedure StartBASS;
begin
 if IsPlaying then exit;
 PlayFreeBASS;
 LoadBASS(WMA);
 InitBASS(BASS_FIRSTSOUNDDEVICE,SampleRate,0,Form1.Handle);
 PlayBASS(PChar(CurItem.FileName),CurFileType in [StreamFileMin..StreamFileMax],CurFileType = WMAFile);
 TimePlayStart := GetTickCount;
 IsPlaying := True;
 Reseted := 0;
 Paused := False;
end;

end.