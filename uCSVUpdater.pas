unit uCSVUpdater;

interface

uses System.Classes, System.SysUtils, System.Types,
     System.Generics.Defaults, System.Generics.Collections,
     Functional.Value;

  Const
    ALWAYS_FOLLOW_LINK_FILES = true;
    DONT_FOLLOW_LINK_FILES = false;

  type

  TValidatedFilename = Class
    Name: string;
    InvalidReason: string;
    class function isValid(AName: string) : boolean;
    class function ValidFilename(AName: string) : TValidatedFilename;
  End;

  TCSVUpdater = class
    constructor Create(AFilename: string);
    destructor  Destroy; override;
  private
    fFileName: string;
    fHeaders: TStringList;
    fBody : TStringList;
    fLastError: string;
    function LoadFileSuccessfully(Filename: TValidatedFilename): boolean;
    function LoadHeadersSuccessfully: boolean;
    function getRowByIndex(AIndex: integer): string;
    procedure setRowByIndex(AIndex: integer; const Value: string);
    function getRowByValue(AHeader: string; AValue: string): string;
    function getHeaders: string;
    function getFileLoaded: boolean;
  public
    property FileLoaded : boolean read getFileLoaded;
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

function TCSVUpdater.getFileLoaded: boolean;
begin
   result := (Self.fBody.Count>0) or
             LoadFileSuccessfully(Self.Filename);
end;

function TCSVUpdater.getHeaders: string;
begin
  if LoadHeadersSuccessfully then
      result := self.fHeaders.Text;

end;

function TCSVUpdater.getRowByIndex(AIndex: integer): string;
begin
  result := '';
  if (AIndex>1) then raise Exception.Create('Row must be >= 1'); // Truly an exception

  if (self.FileLoaded) and (Aindex<=self.fBody.Count) then
      result := self.fBody[AIndex-1];
end;

function TCSVUpdater.getRowByValue(AHeader, AValue: string): string;
begin

end;

function TCSVUpdater.LoadFileSuccessfully(Filename: string): boolean;
begin
  result := false;
  // Side Effect - This will not always return the same value.
  // Capture Error at the lowest level (except if it is really an exceptional)
  try
    self.fBody.LoadFromFile(Filename);
    result := true;
  except
    on e:exception do
      begin
         // What conditions do we want to handle???
         self.fLastError := e.Message;
         raise;
      end;
  end;

end;

function TCSVUpdater.LoadHeadersSuccessfully: boolean;
begin
  Result := FileLoaded and (fHeaders.Count>0);

  if (not Result) and (Self.fBody.Count>0) then
  begin
    self.fHeaders.DelimitedText := self.fBody[0];
    result := self.fHeaders.Count>0;
  end;

end;

procedure TCSVUpdater.setRowByIndex(AIndex: integer; const Value: string);
begin

end;

{ TValidatedFilename }

class function TValidatedFilename.isValid(AName: string): boolean;
begin
  Result := false;
  inValidReason := '';
  if (AName='') then
    invalidReason := 'No file name has been set.'
  else if not(FileExists(AName, ALWAYS_FOLLOW_LINK_FILES)) then
    invalidReason := format('File %s does not exist', [AName])
  else Result := true;
end;

class function TValidatedFilename.ValidFilename(AName: string): TValidatedFilename;
begin
  Result := nil;
  if (isValid(AName))then
  begin
    result := TValidatedFilename.Create;
    Result.Name := AName;
  end;

end;

end.
