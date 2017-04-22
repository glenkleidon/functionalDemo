unit GlenKleidon.CSVUtils;

interface
 uses System.Classes, System.SysUtils;


Function IsEvenDefTrue(AInteger: integer): boolean;
function nextRow(AStream: TStream; ALineBreak: String;
     AQuoteChars: string; ABufferSize: integer = 500): string;
function CountChars(AText: String; AChars: string; AStart: integer = 0;
          AEnd: integer = MaxInt):Integer;

implementation

uses strUtils;

function CountChars(AText: String; AChars: string; AStart:integer;
          AEnd:Integer):Integer;
var p: integer;
begin
   result := 0;
   p:=posEx(AChars, AText,AStart);
   while (p>0) and (p<=AEnd) do
   begin
     Result := Result +1;
     p:=posEx(AChars, AText,p+1);
   end;
end;

Function IsEvenDefTrue(AInteger: integer): boolean;
begin
  Result := True;
  if AInteger=0 then exit;
  Result := ( (Ainteger mod 2) = 0);
end;

function nextRow(AStream: TStream; ALineBreak: String;
     AQuoteChars: string; ABufferSize: integer):string ;
var lBuffer : TStringStream;
    p: integer;
    StartPosition, lCharsRemaining : int64;
    lBytesToRead : integer;
    LineText : AnsiString;
    lBufferSize : integer;
    lCopybufferFromStream : boolean;

begin
  Result := '';
  if AStream=nil then exit;

  // Dont Duplicate the data if using a Memory Stream
  StartPosition := AStream.Position;
  lCharsRemaining := AStream.size-AStream.Position;
  if (AStream.InheritsFrom(TMemoryStream)) then
  begin
     lCopybufferFromStream := false;
     lBufferSize := MaxInt;
     lBuffer := AStream as TStringStream;
     p := AStream.Position+1;
     AStream.Position := AStream.Size;
  end
  else
  begin
     lBuffer := TStringStream.create;
     lCopybufferFromStream := true;
     lBufferSize := ABufferSize;
     p := 1;
     if (lBufferSize>lCharsRemaining) then  lBufferSize := lCharsRemaining
  end;

  try
    LineText := '';
    while lCharsRemaining>0 do
    Begin
      if lCopybufferFromStream then lBuffer.copyfrom(AStream,lBufferSize);
      lCharsRemaining := lBuffer.size - StartPosition - lBuffer.Position;
      SetString(LineText, pAnsiChar(lBuffer.Memory), lBuffer.size);
      p :=Pos(ALineBreak, LineText,p);
      while (p>0) do
      begin
         if IsEvenDefTrue(CountChars(LineText,AQuoteChars,1,p)) then
         begin
           result := copy(LineText,1,p-1);
           AStream.Position := StartPosition+ALineBreak.Length-1;
           exit;
         end;
         p := PosEx(ALineBreak, LineText, p+1);
      end;
   End;
   // Not found, must be the remaining text
   Result := copy(lineText,(StartPosition and MaxInt)+1,MaxInt);
  finally
    if lCopybufferFromStream then freeandNil(lBuffer);
  end;

end;




end.
