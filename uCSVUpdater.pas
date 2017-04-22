unit uCSVUpdater;

interface

uses System.Classes, System.SysUtils, System.Types,
     System.Generics.Defaults, System.Generics.Collections,
     Functional.Value;

  Const
    ALWAYS_FOLLOW_LINK_FILES = true;
    DONT_FOLLOW_LINK_FILES = false;

  type

  TCSVUpdater = class
    constructor Create(AFilename: string);
    destructor  Destroy; override;
  private
    fFileName: string;
    fHeaders: TStringList;
    fBody : TStringList;
    fLastError: string;
    function LoadFileSuccessfully: boolean;
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

implementation

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
             LoadFileSuccessfully;
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

function TCSVUpdater.LoadFileSuccessfully: boolean;
begin
  result := false;

  if (Filename='') then
  begin
    self.fLastError := 'No file name has been set.';
    exit;
  end;

  if not(FileExists(Filename, ALWAYS_FOLLOW_LINK_FILES)) then
  begin
    self.fLastError := format('File %s does not exist', [FileName]);
    exit;
  end;

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

end.
