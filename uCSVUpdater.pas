unit uCSVUpdater;

interface

uses System.Classes, System.SysUtils, System.Types,
     System.Generics.Defaults, System.Generics.Collections,
     Functional.Value;

  type

  TCSVUpdater = class
    constructor Create(AFilename: string);
    destructor  Destroy; override;
  private
    fFileName: string;
    fHeaders: TStringList;
    fBody : TStringList;
    fLastError: string;
    function getHeaders: string;
    procedure SetHeaders(const Value: string);
    procedure LoadHeaders;
    function getRowByIndex(AIndex: integer): string;
    procedure setRowByIndex(AIndex: integer; const Value: string);
    function LocateRow(AIndex: integer): string;
    function getRowByValue(AHeader: string; AValue: string): string;
    function getBody: TStrings;
    procedure SetBody(const Value: TStrings);
  public
    property Filename: string read fFileName;
    property Headers : string read getHeaders;
    property Row[AIndex : integer] : string read getRowbyIndex write setRowByIndex;
  end;

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


{ TCSVUpdater }

constructor TCSVUpdater.Create(AFilename: string);
begin
  fHeaders := TStringlist.Create;
  fBody := TStringList.Create;
  fHeaders.QuoteChar := '"';
  fHeaders.Delimiter := ',';
  fHeaders.LineBreak := #13#10;
  fBody.QuoteChar := '"';
  fBody.LineBreak := #13#10;
  fBody.Delimiter := '"';
  fFilename := expandFileName(AFilename);
end;

destructor TCSVUpdater.Destroy;
begin
  freeandNil(Self.fBody);
  freeandNil(self.fHeaders);
  inherited;
end;

function TCSVUpdater.getBody: TStrings;
begin
  result := self.fbody as TStrings;
end;

function TCSVUpdater.getHeaders: string;
begin
  fLastError := '';
  result := '';
  if (fHeaders.Count=0) then
  try
   LoadHeaders;
  Except
   on e:exception do
     fLastError := 'Could not load headers: '+ e.Message;
  end;
  result := self.fHeaders.Text;

end;

function TCSVUpdater.getRowByIndex(AIndex: integer): string;
begin
  result := LocateRow(AIndex);
end;

function TCSVUpdater.getRowByValue(AHeader, AValue: string): string;
begin

end;

Procedure TCSVUpdater.LoadHeaders;
begin
  if (fFileName<>'') and
     (FileExists(fFilename,true)) then
  begin
    self.fBody.LoadFromFile(fFilename);
    self.SetHeaders(self.fBody[0]);
    self.fBody.Delete(0);
  end;
end;

function TCSVUpdater.LocateRow(AIndex: integer): string;
begin
  if self.fbody.count<1 then loadHeaders;
  if (AIndex<1) then raise Exception.Create('Row must be >= 1');
  if (Aindex>self.fBody.Count) then raise Exception.Createfmt('Row %u not found.',[AIndex]);
  result := self.fBody[AIndex-1];
end;

procedure TCSVUpdater.SetBody(const Value: TStrings);
begin

end;

procedure TCSVUpdater.SetHeaders(const Value: string);
begin
  self.fHeaders.DelimitedText := Value;
end;

procedure TCSVUpdater.setRowByIndex(AIndex: integer; const Value: string);
begin

end;

end.
