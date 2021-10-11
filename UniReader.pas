{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

unit UniReader;

interface

const
 BufferSize = 32768;
 MaxHandle = 2;

type

 PReadBlock = ^TReadBlock;
 TReader = procedure(Handle:integer;PBuffer:pointer;Size:Longint;Reader:PReadBlock);
 TReadBlock = record
  Depacker:TReader;
  Closer:procedure;
  Next:PReadBlock;
 end;
 UniReaders = (URFile,URMemory);
 UniDepacker = (UDLZH);
 UniDepackers = array of UniDepacker;
 PUniReadersData = ^TUniReadersData;
 TUniReadersData = record
  UniType:UniReaders;
  ReadersRoot:PReadBlock;
  UniFilePos,UniFileSize:integer;
  UniFile:file;
  FileBuffer:array[0..BufferSize - 1] of byte;
  DirectReader:TReadBlock;
  BufferPos,BufferReaden:integer;
  UniMemory:pointer;
  UniOffset:integer;
 end;

var
 UniReadersData:array[0..MaxHandle] of PUniReadersData = (nil,nil,nil);

 procedure UniRead(Handle:integer;PBuf:pointer;Size:integer);
 procedure UniReadInit(var Handle:integer;Reader:UniReaders;FileName:string;
                                                                pMem:pointer);
 procedure UniReadClose(Handle:integer);
 procedure UniAddDepacker(Handle:integer;UD:UniDepacker);
 procedure UniFileSeek(Handle:integer;Pos:integer);

implementation

uses SysUtils, LH5, Languages;

procedure ReadDataBlockFromFile(Handle:integer;PBuffer:pointer;Size:Longint;
                                Reader:PReadBlock);
var
 Readen:integer;
begin
if Size = 0 then exit;
with UniReadersData[Handle]^ do
if BufferPos = BufferReaden then
 begin
  if Size >= BufferSize then
   begin
    BlockRead(UniFile,PBuffer^,Size,Readen);
    if Readen < Size then
     raise Exception.Create(Mes_ReadAfterEndOfFile);
    inc(UniFilePos,Size)
   end
  else
   begin
    BlockRead(UniFile,FileBuffer,BufferSize,BufferReaden);
    if BufferReaden < Size then
     raise Exception.Create(Mes_ReadAfterEndOfFile);
    Move(FileBuffer,PBuffer^,Size);
    BufferPos := Size;
    inc(UniFilePos,Size)
   end
 end
else
 begin
  if Size <= BufferReaden - BufferPos then
   begin
    Move(FileBuffer[BufferPos],PBuffer^,Size);
    inc(BufferPos,Size);
    inc(UniFilePos,Size)
   end
  else
   begin
    Readen := BufferReaden - BufferPos;
    Move(FileBuffer[BufferPos],PBuffer^,Readen);
    BufferPos := BufferReaden;
    inc(UniFilePos,Readen);
    ReadDataBlockFromFile(Handle,pointer(integer(PBuffer) + Readen),Size - Readen,nil);
   end
 end;
end;

procedure UniFileSeek;
var
 NewBufferPos:integer;
begin
with UniReadersData[Handle]^ do
 begin
  if UniFilePos = Pos then exit;
  if Longword(Pos) > Longword(UniFileSize) then
   raise Exception.Create(Mes_SeekAfterEndOfFile);
  NewBufferPos := BufferPos + Pos - UniFilePos;
  UniFilePos := Pos;
  if (NewBufferPos >= 0) and (NewBufferPos < BufferReaden) then
   BufferPos := NewBufferPos
  else
   begin
    Seek(UniFile,Pos);
    BufferPos := BufferReaden
   end
 end  
end;

procedure ReadDataBlockFromMemory(Handle:integer;PBuffer:pointer;Size:Longint;
                                Reader:PReadBlock);
begin
with UniReadersData[Handle]^ do
 begin
  Move(Pointer(Longint(UniMemory) + UniOffset)^,PBuffer^,Size);
  Inc(UniOffset,Size)
 end
end;

procedure UniRead;
begin
with UniReadersData[Handle].ReadersRoot^ do
 Depacker(Handle,PBuf,Size,Next);
end;

procedure UniReadInit;
var
 i:integer;
begin
for i := 0 to MaxHandle do
 if UniReadersData[i] = nil then
  begin
   Handle := i;
   break
  end;
New(UniReadersData[Handle]);
with UniReadersData[Handle]^ do
 begin
  UniType := Reader;
  case Reader of
  URFile:
   begin
    UniFilePos := 0;
    BufferPos := 0;
    BufferReaden := 0;
    AssignFile(UniFile,FileName);
    Reset(UniFile,1);
    UniFileSize := FileSize(UniFile);
    with DirectReader do
     begin
      Depacker := ReadDataBlockFromFile;
      Next := nil
     end
   end;
  URMemory:
   begin
    UniMemory := pMem;
    UniOffset := 0;
    with DirectReader do
     begin
      Depacker := ReadDataBlockFromMemory;
      Next := nil
     end
   end
  end;
  ReadersRoot := @DirectReader
 end 
end;

procedure UniReadClose;
var
 DepackerReader,p:PReadBlock;
begin
with UniReadersData[Handle]^ do
 begin
  if UniType = URFile then CloseFile(UniFile);
  DepackerReader := ReadersRoot;
  p := DepackerReader.Next;
  while p <> nil do
   begin
    DepackerReader.Closer;
    Dispose(DepackerReader);
    DepackerReader := p;
    p := DepackerReader.Next;
   end
 end;
Dispose(UniReadersData[Handle]);
UniReadersData[Handle] := nil
end;

procedure UniAddDepacker;
var
 DepackerReader:PReadBlock;
begin
with UniReadersData[Handle]^ do
case UD of
UDLZH:
  begin
   New(DepackerReader);
   with DepackerReader^ do
    begin
     Depacker := LZHDepacker;
     Closer := LZHDepackerDone;
     Next := ReadersRoot
    end;
   InitLZHDepacker(Handle,ReadersRoot);
   ReadersRoot := DepackerReader
  end;
end;
end;

end.