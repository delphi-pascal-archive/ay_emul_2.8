{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.8 for Windows 95
Author Sergey Vladimirovich Bulba
(c)1999-2005 S.V.Bulba
}

//Based on Lh5 unit from Russian SWAG

unit Lh5;

interface

uses UniReader, SysUtils;

type
  EInvalidCompressedData = class(Exception);

var
 Compressed_Size,Original_Size:integer;
 LhaOutFile:File;

procedure LZHDepacker(Handle:integer;PBuffer:pointer;Size:Longint;Reader:PReadBlock);
procedure InitLZHDepacker(Handle:integer;Reader:PReadBlock);
procedure LZHDepackerDone;
procedure Encode_Buffer_To_File(external_buf:pointer);

implementation

uses Languages;

TYPE
  PWord=^TWord;
  TWord=ARRAY[0..32759]OF Word;
  PByte=^TByte;
  TByte=ARRAY[0..65519]OF Byte;

CONST

  BITBUFSIZ=16;
  UCHARMAX=255;

  DICBIT=13;
  DICSIZ=1 SHL DICBIT;

  MATCHBIT=8;
  MAXMATCH=1 SHL MATCHBIT;
  THRESHOLD=3;
  PERCFLAG=$8000;

  NC=(UCHARMAX+MAXMATCH+2-THRESHOLD);
  CBIT=9;
  CODEBIT=16;

  NP=DICBIT+1;
  NT=CODEBIT+3;
  PBIT=4; {Log2(NP)}
  TBIT=5; {Log2(NT)}
  NPT=NT; {Greater from NP and NT}

  NUL=0;
  MAXHASHVAL=(3*DICSIZ+(DICSIZ SHR 9+1)*UCHARMAX);

  WINBIT=14;
  WINDOWSIZE=1 SHL WINBIT;

  BUFBIT=13;
  BUFSIZE=1 SHL BUFBIT;

VAR

  Position_in_External_Buf:integer;

  BitBuf:Word;
  n,HeapSize:smallint;
  SubBitBuf,BitCount:Word;

type
  DBuffer = ARRAY[0..PRED(BUFSIZE)]OF Byte;
  PDBuffer = ^DBuffer;

var
  r:Word; //Position in dictionary buffer during depacking
  Buffer:PDBuffer; //Dictionary buffer
  BufPtr:Word;

  Left,Right:ARRAY[0..2*(NC-1)]OF Word;

  PtTable:ARRAY[0..255]OF Word;
  PtLen:ARRAY[0..PRED(NPT)]OF Byte;
  CTable:ARRAY[0..4095]OF Word;
  CLen:ARRAY[0..PRED(NC)]OF Byte;

  BlockSize:Word;

  { The following variables are used by the compression engine only }

  Heap:ARRAY[0..NC]OF Word;
  LenCnt:ARRAY[0..16]OF Word;

  Freq,SortPtr:PWord;
  Len:PByte;
  Depth:Word;

  Buf:PByte;

  CFreq:ARRAY[0..2*(NC-1)]OF Word;
  PFreq:ARRAY[0..2*(NP-1)]OF Word;
  TFreq:ARRAY[0..2*(NT-1)]OF Word;

  CCode:ARRAY[0..PRED(NC)]OF Word;
  PtCode:ARRAY[0..PRED(NPT)]OF Word;

  CPos,OutputPos,OutputMask:Word;
  Text,ChildCount:PByte;

  Pos,MatchPos,Avail:Word;
  Position,Parent,Prev,Next:PWord;

  Remainder,MatchLen:smallint;
  Level:PByte;
  
procedure InvalidLZH;
begin
raise EInvalidCompressedData.Create(Mes_InvalidLZH);
end;

{********************************** File I/O **********************************}

var
 BReader:PReadBlock;
 BHandle:integer;
function GetC:Byte;
begin
with BReader^ do
 Depacker(BHandle,@Result,sizeof(byte),Next);
end;

PROCEDURE PutC(c:Byte);
BEGIN
  IF BufPtr=BUFSIZE THEN
    BEGIN
      BlockWrite(LhaOutFile,Buffer^,BUFSIZE);BufPtr:=0;
    END;
  Buffer[BufPtr]:=C;INC(BufPtr);
END;

FUNCTION GetFromBuffer(from:pointer;p:POINTER;n:integer):smallint;
BEGIN
  if Position_in_External_Buf+n>Original_Size then
                               n:=Original_Size-Position_in_External_Buf;
  move(pointer(longint(from) + Position_in_External_Buf)^,p^,n);
  Inc(Position_In_External_Buf,n);
  GetFromBuffer:=n;
END;

{**************************** Bit handling routines ***************************}

PROCEDURE FillBuf(n:smallint);
BEGIN
  BitBuf:=(BitBuf SHL n);
  WHILE n > smallint(BitCount) DO BEGIN
    DEC(n,BitCount);
    BitBuf:=BitBuf OR (SubBitBuf SHL n);
    IF (Compressed_Size<>0) THEN
      BEGIN
        DEC(Compressed_Size);SubBitBuf:=GetC;
      END ELSE
        SubBitBuf:=0;
    BitCount:=8;
  END;
  DEC(BitCount,n);
  BitBuf:=BitBuf OR (SubBitBuf SHR BitCount);
END;

FUNCTION GetBits(n:smallint):Word;
BEGIN
  GetBits:=BitBuf SHR (BITBUFSIZ-n);
  FillBuf(n);
END;

PROCEDURE PutBits(n:word;x:Word);
BEGIN
  IF n<BitCount THEN
    BEGIN
      DEC(BitCount,n);
      SubBitBuf:=SubBitBuf OR (x SHL BitCount);
    END ELSE BEGIN
      DEC(n,BitCount);
      PutC(SubBitBuf OR (x SHR n));INC(Compressed_Size);
      IF n<8 THEN
        BEGIN
          BitCount:=8-n;SubBitBuf:=x SHL BitCount;
        END ELSE BEGIN
          PutC(x SHR (n-8));INC(Compressed_Size);
          BitCount:=16-n;SubBitBuf:=x SHL BitCount;
        END;
    END;
END;

PROCEDURE InitGetBits;
BEGIN
  BitBuf:=0;SubBitBuf:=0;BitCount:=0;FillBuf(BITBUFSIZ);
END;

PROCEDURE InitPutBits;
BEGIN
  BitCount:=8;SubBitBuf:=0;
END;

{******************************** Decompression *******************************}

PROCEDURE MakeTable(nchar:smallint;BitLen:PByte;TableBits:smallint;Table:PWord);
VAR
  count,weight:ARRAY[1..16]OF Word;
  start:ARRAY[1..17]OF Word;
  p:PWord;
  i,k,nextCode:word;
  Len,ch,jutbits,Avail,mask:smallint;
BEGIN
  FOR i:=1 TO 16 DO
    count[i]:=0;
  FOR i:=0 TO PRED(nchar) DO
    INC(count[BitLen^[i]]);
  start[1]:=0;
  FOR i:=1 TO 16 DO
    start[SUCC(i)]:=start[i]+(count[i] SHL (16-i));
  IF start[17] <> 0 THEN
   begin
    {HALT(1);}
    InvalidLZH;
   end;
  jutbits:=16-TableBits;
  FOR i:=1 TO TableBits DO
    BEGIN
      start[i]:=start[i] SHR jutbits;weight[i]:=1 SHL (TableBits-i);
    END;
  i:=SUCC(TableBits);
  WHILE (i<=16) DO BEGIN
    weight[i]:=1 SHL (16-i);INC(i);
  END;
  i:=start[SUCC(TableBits)] SHR jutbits;
  IF i<>0 THEN
    BEGIN
      k:=1 SHL TableBits;
      WHILE i<>k DO BEGIN
        Table^[i]:=0;INC(i);
      END;
    END;
  Avail:=nchar;mask:=1 SHL (15-TableBits);
  FOR ch:=0 TO PRED(nchar) DO
    BEGIN
      Len:=BitLen^[ch];
      IF Len=0 THEN
        CONTINUE;
      k:=start[Len];
      nextCode:=k+weight[Len];
      IF Len<=TableBits THEN
        BEGIN
          FOR i:=k TO PRED(nextCode) DO
            Table^[i]:=ch;
        END ELSE BEGIN
          p:=Addr(Table^[k SHR jutbits]);i:=Len-TableBits;
          WHILE i<>0 DO BEGIN
            IF p^[0]=0 THEN
              BEGIN
                right[Avail]:=0;left[Avail]:=0;p^[0]:=Avail;INC(Avail);
              END;
            IF (k AND mask)<>0 THEN
              p:=addr(right[p^[0]])
            ELSE
              p:=addr(left[p^[0]]);
            k:=k SHL 1;DEC(i);
          END;
          p^[0]:=ch;
        END;
      start[Len]:=nextCode;
    END;
END;

PROCEDURE ReadPtLen(nn,nBit,ispecial:smallint);
VAR
  i,c,n:smallint;
  mask:Word;
BEGIN
  n:=GetBits(nBit);
  IF n=0 THEN
    BEGIN
      c:=GetBits(nBit);
      FOR i:=0 TO PRED(nn) DO
        PtLen[i]:=0;
      FOR i:=0 TO 255 DO
        PtTable[i]:=c;
    END ELSE BEGIN
      i:=0;
      WHILE (i<n) DO BEGIN
        c:=BitBuf SHR (BITBUFSIZ-3);
        IF c=7 THEN
          BEGIN
            mask:=1 SHL (BITBUFSIZ-4);
            WHILE (mask AND BitBuf)<>0 DO BEGIN
              mask:=mask SHR 1;INC(c);
            END;
          END;
        IF c<7 THEN
          FillBuf(3)
        ELSE
          FillBuf(c-3);
        PtLen[i]:=c;INC(i);
        IF i=ispecial THEN
          BEGIN
            c:=PRED(GetBits(2));
            WHILE c>=0 DO BEGIN
              PtLen[i]:=0;INC(i);DEC(c);
            END;
          END;
      END;
      WHILE i<nn DO BEGIN
        PtLen[i]:=0;INC(i);
      END;
      MakeTable(nn,@PtLen,8,@PtTable);
    END;
END;

PROCEDURE ReadCLen;
VAR
  i,c,n:smallint;
  mask:Word;
BEGIN
  n:=GetBits(CBIT);
  IF n=0 THEN
    BEGIN
      c:=GetBits(CBIT);
      FOR i:=0 TO PRED(NC) DO
        CLen[i]:=0;
      FOR i:=0 TO 4095 DO
        CTable[i]:=c;
    END ELSE BEGIN
      i:=0;
      WHILE i<n DO BEGIN
        c:=PtTable[BitBuf SHR (BITBUFSIZ-8)];
        IF c>=NT THEN
          BEGIN
            mask:=1 SHL (BITBUFSIZ-9);
            REPEAT
              IF (BitBuf AND mask)<>0 THEN
                c:=right[c]
              ELSE
                c:=left[c];
              mask:=mask SHR 1;
            UNTIL c<NT;
          END;
        FillBuf(PtLen[c]);
        IF c<=2 THEN
          BEGIN
            IF c=1 THEN
              c:=2+GetBits(4)
            ELSE
              IF c=2 THEN
                c:=19+GetBits(CBIT);
            WHILE c>=0 DO BEGIN
              CLen[i]:=0;INC(i);DEC(c);
            END;
          END ELSE BEGIN
            CLen[i]:=c-2;INC(i);
          END;
      END;
      WHILE i<NC DO BEGIN
        CLen[i]:=0;INC(i);
      END;
      MakeTable(NC,@CLen,12,@CTable);
    END;
END;

FUNCTION DecodeC:Word;
VAR
  j,mask:Word;
BEGIN
  IF BlockSize=0 THEN
    BEGIN
      BlockSize:=GetBits(16);
      ReadPtLen(NT,TBIT,3);
      ReadCLen;
      ReadPtLen(NP,PBIT,-1);
    END;
  DEC(BlockSize);
  j:=CTable[BitBuf SHR (BITBUFSIZ-12)];
  IF j>=NC THEN
    BEGIN
      mask:=1 SHL (BITBUFSIZ-13);
      REPEAT
        IF (BitBuf AND mask)<>0 THEN
          j:=right[j]
        ELSE
          j:=left[j];
        mask:=mask SHR 1;
      UNTIL j<NC;
    END;
  FillBuf(CLen[j]);
  DecodeC:=j;
END;

FUNCTION DecodeP:Word;
VAR
  j,mask:Word;
BEGIN
  j:=PtTable[BitBuf SHR (BITBUFSIZ-8)];
  IF j>=NP THEN
    BEGIN
      mask:=1 SHL (BITBUFSIZ-9);
      REPEAT
        IF (BitBuf AND mask)<>0 THEN
          j:=right[j]
        ELSE
          j:=left[j];
        mask:=mask SHR 1;
      UNTIL j<NP;
    END;
  FillBuf(PtLen[j]);
  IF j<>0 THEN
    BEGIN
      DEC(j);j:=(1 SHL j)+GetBits(j);
    END;
  DecodeP:=j;
END;

{declared as static vars}
VAR
  decode_i:Word;
  decode_j:smallint;

PROCEDURE DecodeBuffer(count:Word);
VAR
  c:Word;
BEGIN
  DEC(decode_j);
  WHILE (decode_j>=0) DO BEGIN
    Buffer[r]:=Buffer[decode_i];decode_i:=SUCC(decode_i) AND PRED(DICSIZ);
    INC(r);
    IF r=count THEN
      EXIT;
    DEC(decode_j);
  END;
  WHILE TRUE DO BEGIN
    c:=DecodeC;
    IF c<=UCHARMAX THEN
      BEGIN
        Buffer[r]:=c;INC(r);
        IF r=count THEN
          EXIT;
      END ELSE BEGIN
        decode_j:=c-(UCHARMAX+1-THRESHOLD);
        decode_i:=(r-DecodeP-1)AND PRED(DICSIZ);
        DEC(decode_j);
        WHILE decode_j>=0 DO BEGIN
          Buffer[r]:=Buffer[decode_i];
          decode_i:=SUCC(decode_i) AND PRED(DICSIZ);
          INC(r);
          IF r=count THEN
            EXIT;
          DEC(decode_j);
        END;
      END;
  END;
END;

{********************************* Compression ********************************}

{-------------------------------- Huffman part --------------------------------}

PROCEDURE CountLen(i:smallint);
BEGIN
  IF i<n THEN
    BEGIN
      IF Depth<16 THEN
        INC(LenCnt[Depth])
      ELSE
        INC(LenCnt[16]);
    END ELSE BEGIN
      INC(Depth);
      CountLen(Left[i]);CountLen(Right[i]);
      DEC(Depth);
    END;
END;

PROCEDURE MakeLen(root:smallint);
VAR
  i,k:smallint;
  cum:Word;
BEGIN
  FOR i:=0 TO 16 DO
    LenCnt[i]:=0;
  CountLen(root);cum:=0;
  FOR i:=16 DOWNTO 1 DO
    INC(cum,LenCnt[i] SHL (16-i));
  WHILE cum<>0 DO BEGIN
    DEC(LenCnt[16]);
    FOR i:=15 DOWNTO 1 DO
      IF LenCnt[i]<>0 THEN
        BEGIN
          DEC(LenCnt[i]);INC(LenCnt[SUCC(i)],2);
          BREAK;
        END;
    DEC(cum);
  END;
  FOR i:=16 DOWNTO 1 DO BEGIN
    k:=PRED(LenCnt[i]);
    WHILE k>=0 DO BEGIN
      DEC(k);Len^[SortPtr^[0]]:=i;
      ASM
        ADD DWORD PTR SortPtr,2; {SortPtr:=addr(SortPtr^[1]);}
      END;
    END;
  END;
END;

PROCEDURE DownHeap(i:smallint);
VAR
  j,k:smallint;
BEGIN
  k:=Heap[i];j:=i SHL 1;
  WHILE (j<=HeapSize) DO BEGIN
    IF (j<HeapSize)AND(Freq^[Heap[j]]>Freq^[Heap[SUCC(j)]]) THEN INC(j);
    IF Freq^[k]<=Freq^[Heap[j]] THEN break;
    Heap[i]:=Heap[j];i:=j;j:=i SHL 1;
  END;
  Heap[i]:=k;
END;

PROCEDURE MakeCode(n:smallint;Len:PByte;Code:PWord);
VAR
  i,k:smallint;
  start:ARRAY[0..17] OF Word;
BEGIN
  start[1]:=0;
  FOR i:=1 TO 16 DO
    start[SUCC(i)]:=(start[i]+LenCnt[i])SHL 1;
  FOR i:=0 TO PRED(n) DO BEGIN
    k:=Len^[i];
    Code^[i]:=start[k];
    INC(start[k]);
  END;
END;

FUNCTION MakeTree(NParm:smallint;Freqparm:PWord;LenParm:PByte;
				Codeparm:PWord):smallint;
VAR
  i,j,k,Avail:smallint;
BEGIN
  n:=NParm;Freq:=Freqparm;Len:=LenParm;Avail:=n;HeapSize:=0;Heap[1]:=0;
  FOR i:=0 TO PRED(n) DO BEGIN
    Len^[i]:=0;
    IF Freq^[i]<>0 THEN
      BEGIN
        INC(HeapSize);Heap[HeapSize]:=i;
      END;
  END;
  IF HeapSize<2 THEN
    BEGIN
      Codeparm^[Heap[1]]:=0;MakeTree:=Heap[1];
      EXIT;
    END;
  FOR i:=(HeapSize div 2)DOWNTO 1 DO DownHeap(i);
  SortPtr:=Codeparm;
  REPEAT
    i:=Heap[1];
    IF i<n THEN
      BEGIN
        SortPtr^[0]:=i;
        ASM
          ADD DWORD PTR SortPtr,2; {SortPtr:=addr(SortPtr^[1]);}
        END;
      END;
    Heap[1]:=Heap[HeapSize];DEC(HeapSize);DownHeap(1);
    j:=Heap[1];
    IF j<n THEN
      BEGIN
        SortPtr^[0]:=j;
        ASM
          ADD DWORD PTR SortPtr,2; {SortPtr:=addr(SortPtr^[1]);}
        END;
      END;
    k:=Avail;INC(Avail);
    Freq^[k]:=Freq^[i]+Freq^[j];Heap[1]:=k;DownHeap(1);
    Left[k]:=i;Right[k]:=j;
  UNTIL HeapSize<=1;
  SortPtr:=Codeparm;
  MakeLen(k);MakeCode(NParm,LenParm,Codeparm);
  MakeTree:=k;
END;

PROCEDURE CountTFreq;
VAR
  i,k,n,Count:smallint;
BEGIN
  FOR i:=0 TO PRED(NT) DO
    TFreq[i]:=0;n:=NC;
  WHILE (n>0)AND(CLen[PRED(n)]=0) DO
    DEC(n);
  i:=0;
  WHILE i<n DO BEGIN
    k:=CLen[i];INC(i);
    IF k=0 THEN
      BEGIN
        Count:=1;
        WHILE (i<n)AND(CLen[i]=0) DO BEGIN
          INC(i);INC(Count);
        END;
        IF Count<=2 THEN
          INC(TFreq[0],Count)
        ELSE
          IF Count<=18 THEN
            INC(TFreq[1])
          ELSE
            IF Count=19 THEN
              BEGIN
                INC(TFreq[0]);INC(TFreq[1]);
              END ELSE
                INC(TFreq[2]);
      END ELSE
        INC(TFreq[k+2]);
  END;
END;

PROCEDURE WritePtLen(n,nBit,ispecial:smallint);
VAR
  i,k:smallint;
BEGIN
  WHILE (n>0)AND(PtLen[PRED(n)]=0) DO
    DEC(n);
  PutBits(nBit,n);i:=0;
  WHILE (i<n) DO BEGIN
    k:=PtLen[i];INC(i);
    IF k<=6 THEN
      PutBits(3,k)
    ELSE
      BEGIN
        DEC(k,3);
        PutBits(k,(1 SHL k)-2);
      END;
    IF i=ispecial THEN
      BEGIN
        WHILE (i<6)AND(PtLen[i]=0) DO
          INC(i);
        PutBits(2,(i-3)AND 3);
      END;
  END;
END;

PROCEDURE WriteCLen;
VAR
  i,k,n,Count:smallint;
BEGIN
  n:=NC;
  WHILE (n>0)AND(CLen[PRED(n)]=0) DO
    DEC(n);
  PutBits(CBIT,n);i:=0;
  WHILE (i<n) DO BEGIN
    k:=CLen[i];INC(i);
    IF k=0 THEN
      BEGIN
        Count:=1;
        WHILE (i<n)AND(CLen[i]=0) DO BEGIN
          INC(i);INC(Count);
        END;
        IF Count<=2 THEN
          FOR k:=0 TO PRED(Count) DO
            PutBits(PtLen[0],PtCode[0])
        ELSE
          IF Count<=18 THEN
            BEGIN
              PutBits(PtLen[1],PtCode[1]);
              PutBits(4,Count-3);
            END ELSE
              IF Count=19 THEN
                BEGIN
                  PutBits(PtLen[0],PtCode[0]);
                  PutBits(PtLen[1],PtCode[1]);
                  PutBits(4,15);
                END ELSE BEGIN
                  PutBits(PtLen[2],PtCode[2]);
                  PutBits(CBIT,Count-20);
                END;
      END ELSE
        PutBits(PtLen[k+2],PtCode[k+2]);
  END;
END;

PROCEDURE EncodeC(c:smallint);
BEGIN
  PutBits(CLen[c],CCode[c]);
END;

PROCEDURE EncodeP(p:Word);
VAR
  c,q:Word;
BEGIN
  c:=0;q:=p;
  WHILE q<>0 DO BEGIN
    q:=q SHR 1;INC(c);
  END;
  PutBits(PtLen[c],PtCode[c]);
  IF c>1 THEN
    PutBits(PRED(c),p AND ($ffff SHR (17-c)));
END;

PROCEDURE SendBlock;
VAR
  i,k,flags,root,Pos,Size:Word;
BEGIN
  root:=MakeTree(NC,@CFreq,@CLen,@CCode);
  Size:=CFreq[root];
  PutBits(16,Size);
  IF root>=NC THEN
    BEGIN
      CountTFreq;
      root:=MakeTree(NT,@TFreq,@PtLen,@PtCode);
      IF root>=NT THEN
        WritePtLen(NT,TBIT,3)
      ELSE
        BEGIN
          PutBits(TBIT,0);
          PutBits(TBIT,root);
        END;
      WriteCLen;
    END ELSE BEGIN
      PutBits(TBIT,0);
      PutBits(TBIT,0);
      PutBits(CBIT,0);
      PutBits(CBIT,root);
    END;
  root:=MakeTree(NP,@PFreq,@PtLen,@PtCode);
  IF root>=NP THEN
    WritePtLen(NP,PBIT,-1)
  ELSE
    BEGIN
      PutBits(PBIT,0);
      PutBits(PBIT,root);
    END;
  Pos:=0;
  FOR i:=0 TO PRED(Size) DO BEGIN
    IF (i AND 7)=0 THEN
      BEGIN
        flags:=Buf^[Pos];INC(Pos);
      END ELSE
        flags:=flags SHL 1;
    IF (flags AND (1 SHL 7))<>0 THEN
      BEGIN
        k:=Buf^[Pos]+(1 SHL 8);INC(Pos);EncodeC(k);
        k:=Buf^[Pos]SHL 8;INC(Pos);INC(k,Buf^[Pos]);INC(Pos);EncodeP(k);
      END ELSE BEGIN
        k:=Buf^[Pos];INC(Pos);EncodeC(k);
      END;
  END;
  FOR i:=0 TO PRED(NC) DO
    CFreq[i]:=0;
  FOR i:=0 TO PRED(NP) DO
    PFreq[i]:=0;
END;

PROCEDURE Output(c,p:Word);
BEGIN
  OutputMask:=OutputMask SHR 1;
  IF OutputMask=0 THEN
    BEGIN
      OutputMask:=1 SHL 7;
      IF (OutputPos>=WINDOWSIZE-24) THEN
        BEGIN
          SendBlock;OutputPos:=0;
        END;
      CPos:=OutputPos;INC(OutputPos);Buf^[CPos]:=0;
    END;
  Buf^[OutputPos]:=c;INC(OutputPos);INC(CFreq[c]);
  IF c>=(1 SHL 8) THEN
    BEGIN
      Buf^[CPos]:=Buf^[CPos] OR OutputMask;
      Buf^[OutputPos]:=(p SHR 8);INC(OutputPos);
      Buf^[OutputPos]:=p;INC(OutputPos);c:=0;
      WHILE p<>0 DO BEGIN
        p:=p SHR 1;INC(c);
      END;
      INC(PFreq[c]);
    END;
END;

{------------------------------- Lempel-Ziv part ------------------------------}

PROCEDURE InitSlide;
VAR
  i:Word;
BEGIN
  FOR i:=DICSIZ TO (DICSIZ+UCHARMAX) DO BEGIN
    Level^[i]:=1;
  END;
  FOR i:=DICSIZ TO PRED(2*DICSIZ) DO
    Parent^[i]:=NUL;
  Avail:=1;
  FOR i:=1 TO DICSIZ-2 DO
    Next^[i]:=SUCC(i);
  Next^[PRED(DICSIZ)]:=NUL;
  FOR i:=(2*DICSIZ) TO MAXHASHVAL DO
    Next^[i]:=NUL;
END;

{ Hash function }
FUNCTION Hash(p:smallint;c:Byte):smallint;
BEGIN
  Hash:=p+(c SHL (DICBIT-9))+2*DICSIZ;
END;

FUNCTION Child(q:word;c:Byte):word;
VAR
  r:word;
BEGIN
  r:=Next^[Hash(q,c)];Parent^[NUL]:=q;
  WHILE Parent^[r]<>q DO
    r:=Next^[r];
  Child:=r;
END;

PROCEDURE MakeChild(q:smallint;c:Byte;r:smallint);
VAR
  h,t:smallint;
BEGIN
  h:=Hash(q,c);
  t:=Next^[h];Next^[h]:=r;Next^[r]:=t;
  Prev^[t]:=r;Prev^[r]:=h;Parent^[r]:=q;
  INC(ChildCount^[q]);
END;

PROCEDURE Split(old:smallint);
VAR
  new,t:smallint;
BEGIN
  new:=Avail;Avail:=Next^[new];
  ChildCount^[new]:=0;
  t:=Prev^[old];Prev^[new]:=t;
  Next^[t]:=new;
  t:=Next^[old];Next^[new]:=t;
  Prev^[t]:=new;
  Parent^[new]:=Parent^[old];
  Level^[new]:=MatchLen;
  Position^[new]:=Pos;
  MakeChild(new,Text^[MatchPos+MatchLen],old);
  MakeChild(new,Text^[Pos+MatchLen],Pos);
END;

PROCEDURE InsertNode;
VAR
  q,r,j,t:smallint;
  c:Byte;
  t1,t2:PChar;
BEGIN
  IF MatchLen>=4 THEN
    BEGIN
      DEC(MatchLen);
      r:=SUCC(MatchPos) OR DICSIZ;
      q:=Parent^[r];
      WHILE q=NUL DO BEGIN
        r:=Next^[r];q:=Parent^[r];
      END;
      WHILE Level^[q]>=MatchLen DO BEGIN
        r:=q;q:=Parent^[q];
      END;
      t:=q;
      WHILE t<DICSIZ DO BEGIN
        Position^[t]:=Pos;t:=Parent^[t];
      END;
    END ELSE BEGIN
      q:=Text^[Pos]+DICSIZ;c:=Text^[SUCC(Pos)];r:=Child(q,c);
      IF r=NUL THEN
        BEGIN
          MakeChild(q,c,Pos);MatchLen:=1;
          EXIT;
        END;
      MatchLen:=2;
    END;
  WHILE true DO BEGIN
    IF r>=DICSIZ THEN
      BEGIN
        j:=MAXMATCH;MatchPos:=r;
      END ELSE BEGIN
        j:=Level^[r];MatchPos:=Position^[r] AND NOT PERCFLAG;
      END;
    IF MatchPos>=Pos THEN
      DEC(MatchPos,DICSIZ);
    t1:=addr(Text^[Pos+MatchLen]);t2:=addr(Text^[MatchPos+MatchLen]);
    WHILE MatchLen<j DO BEGIN
      IF t1^<>t2^ THEN
        BEGIN
          Split(r);
          EXIT;
        END;
      INC(MatchLen);INC(t1);INC(t2);
    END;
    IF MatchLen>=MAXMATCH THEN
      BREAK;
    Position^[r]:=Pos;q:=r;
    r:=Child(q,ORD(t1^));
    IF r=NUL THEN
      BEGIN
        MakeChild(q,ORD(t1^),Pos);
        EXIT;
      END;
    INC(MatchLen);
  END;
  t:=Prev^[r];Prev^[Pos]:=t;Next^[t]:=Pos;
  t:=Next^[r];Next^[Pos]:=t;Prev^[t]:=Pos;
  Parent^[Pos]:=q;Parent^[r]:=NUL;Next^[r]:=Pos;
END;

PROCEDURE DeleteNode;
VAR
  r,s,t,u:word;
BEGIN
  IF Parent^[Pos]=NUL THEN
    EXIT;
  r:=Prev^[Pos];s:=Next^[Pos];Next^[r]:=s;Prev^[s]:=r;
  r:=Parent^[Pos];Parent^[Pos]:=NUL;DEC(ChildCount^[r]);
  IF (r>=DICSIZ)OR(ChildCount^[r]>1) THEN
    EXIT;
  t:=Position^[r];
  IF t>=Pos THEN
    DEC(t,DICSIZ);
  s:=Child(r,Text^[t+Level^[r]]);
  t:=Prev^[s];u:=Next^[s];Next^[t]:=u;Prev^[u]:=t;
  t:=Prev^[r];Next^[t]:=s;Prev^[s]:=t;
  t:=Next^[r];Prev^[t]:=s;Next^[s]:=t;
  Parent^[s]:=Parent^[r];Parent^[r]:=NUL;
  Next^[r]:=Avail;Avail:=r;
END;

PROCEDURE Encode_Buffer_To_File;
PROCEDURE GetNextMatchFromBuffer;
VAR
  n:longword;
BEGIN
  DEC(Remainder);INC(Pos);
  IF Pos=2*DICSIZ THEN
    BEGIN
      move(Text^[DICSIZ],Text^[0],DICSIZ+MAXMATCH);
      n:=GetFromBuffer(external_buf,Addr(Text^[DICSIZ+MAXMATCH]),DICSIZ);
      INC(Remainder,n);Pos:=DICSIZ;
    END;
  DeleteNode;InsertNode;
END;
VAR
  LastMatchLen,LastMatchPos:smallint;
BEGIN
       BufPtr:=0;
       New(Buffer);
       Position_in_External_Buf:=0;
     Compressed_Size:=0;
  { initialize encoder variables }
  GetMem(Text,2*DICSIZ+MAXMATCH);
  GetMem(Level,DICSIZ+UCHARMAX+1);
  GetMem(ChildCount,DICSIZ+UCHARMAX+1);
  GetMem(Position,(DICSIZ)SHL 1);
  GetMem(Parent,(DICSIZ*2)SHL 1);
  GetMem(Prev,(DICSIZ*2)SHL 1);
  GetMem(Next,(MAXHASHVAL+1)SHL 1);

  Depth:=0;
  InitSlide;
  GetMem(Buf,WINDOWSIZE);
  Buf^[0]:=0;
  FillChar(CFreq,sizeof(CFreq),0);
  FillChar(PFreq,sizeof(PFreq),0);
  OutputPos:=0;OutputMask:=0;InitPutBits;
  Remainder:={BRead(Addr(Text^[DICSIZ]),DICSIZ+MAXMATCH);}
  GetFromBuffer(external_buf,Addr(Text^[DICSIZ]),DICSIZ+MAXMATCH);
  MatchLen:=0;Pos:=DICSIZ;InsertNode;
  IF MatchLen>Remainder THEN
    MatchLen:=Remainder;
  WHILE Remainder>0 DO BEGIN
    LastMatchLen:=MatchLen;LastMatchPos:=MatchPos;GetNextMatchFromBuffer;
    IF MatchLen>Remainder THEN
      MatchLen:=Remainder;
    IF (MatchLen>LastMatchLen)OR(LastMatchLen<THRESHOLD) THEN
      Output(Text^[PRED(Pos)],0)
    ELSE
      BEGIN
        Output(LastMatchLen+(UCHARMAX+1-THRESHOLD),(Pos-LastMatchPos-2)AND
					PRED(DICSIZ));
        DEC(LastMatchLen);
        WHILE LastMatchLen>0 DO BEGIN
          GetNextMatchFromBuffer;DEC(LastMatchLen);
        END;
        IF MatchLen>Remainder THEN
          MatchLen:=Remainder;
      END;
  END;
  {flush buffers}
  SendBlock;PutBits(7,0);
  IF BufPtr<>0 THEN
    BlockWrite(LhaOutFile,Buffer^,BufPtr);

  FreeMem(Buf,WINDOWSIZE);
  FreeMem(Next,(MAXHASHVAL+1)SHL 1);
  FreeMem(Prev,(DICSIZ*2)SHL 1);
  FreeMem(Parent,(DICSIZ*2)SHL 1);
  FreeMem(Position,(DICSIZ)SHL 1);
  FreeMem(ChildCount,DICSIZ+UCHARMAX+1);
  FreeMem(Level,DICSIZ+UCHARMAX+1);
  FreeMem(Text,2*DICSIZ+MAXMATCH);
  Dispose(Buffer)
END;

var
  l:Longint;

procedure InitLZHDepacker;
begin

BReader := Reader;
BHandle := Handle;
//BufPtr := 0;

New(Buffer);
InitGetBits;
BlockSize := 0;
decode_j := 0;
l := Original_Size;
r := 0;
end;

procedure LZHDepackerDone;
begin
Dispose(Buffer)
end;

procedure LZHDepacker;
var
  a:Word;
  l1:Longint;
  pm,ps:pointer;
begin

  BReader := Reader;
  BHandle := Handle;

  if Size > l then InvalidLZH;

  pm := PBuffer;

  l1 := Size;

  while l1 > 0 do
   begin
    a := DICSIZ - r;
    if l1 < a then
     a := l1;
    ps := pointer(integer(Buffer) + r);
    DecodeBuffer(a + r);
    Move(ps^,pm^,a);
    r := r and Pred(DICSIZ);
    inc(Longint(pm),a);
    dec(l,a);
    dec(l1,a);
   end
end;

end.
