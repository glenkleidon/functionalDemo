unit uCSVUpdater;

interface

uses System.Classes, System.SysUtils, System.Types,
     System.Generics.Defaults, System.Generics.Collections,
     Functional.Value, windows;

  Const
    ALWAYS_FOLLOW_LINK_FILES = true;
    DONT_FOLLOW_LINK_FILES = false;

  type

  TValidatedFilename = record
  private
       FName: string;
       InvalidReason: string;
       IsValid: boolean;
       function getName: string;
  public
       Procedure Clear;
       function Validate(AFilename: string): string;
       property Name : string read getName;
       class operator Implicit(AFileName: string): TValidatedFilename;
  End;

  TCSVUpdater = class
    constructor Create(AFilename: string);
    destructor  Destroy; override;
  private
    FFileName: string;
    FHeaders: TStringList;
    FBody : TStringList;
    FLastError: string;
    function FileLoadedOrLoadsSuccessfully(AFilename: TValidatedFilename): boolean;
    function HeaderLoadedOrLoadsSuccessfully: boolean;
    function getRowByIndex(AIndex: integer): string;
    procedure setRowByIndex(AIndex: integer; const Value: string);
    function getRowByValue(AHeader: string; AValue: string): string;
    function getHeaders: string;
    function getFileLoaded: boolean;
  public
    property FileLoaded : boolean read getFileLoaded;
    property Filename: string read FFilename;
    property Headers : string read getHeaders;
    property Row[AIndex : integer] : string read getRowbyIndex write setRowByIndex;
  end;

implementation

{ TCSVUpdater }

constructor TCSVUpdater.Create(AFilename: string);
begin
  FHeaders := TStringlist.Create;
  FBody := TStringList.Create;
  FHeaders.QuoteChar := '"';
  FHeaders.Delimiter := ',';
  FHeaders.LineBreak := #13#10;
  FBody.QuoteChar := '"';
  FBody.LineBreak := #13#10;
  FBody.Delimiter := '"';
  FFilename := expandFileName(AFilename);
end;

destructor TCSVUpdater.Destroy;
begin
  freeandNil(Self.fBody);
  freeandNil(self.fHeaders);
  inherited;
end;

function TCSVUpdater.getFileLoaded: boolean;
begin
  Result := FileLoadedOrLoadsSuccessfully(Filename);
end;

function TCSVUpdater.FileLoadedOrLoadsSuccessfully(AFilename: TValidatedFilename): boolean;
begin
  if ( Self.fBody.Count=0 ) and ( AFilename.IsValid ) then
    try
      self.fBody.LoadFromFile(AFilename.Name);
    except
      on e:exception do
        begin
           // What conditions do we want to handle???
           self.fLastError := e.Message;
           raise;
        end;
    end;
  Result := (Self.fBody.Count>0);
end;

function TCSVUpdater.getHeaders: string;
begin
  Result := '';
  if HeaderLoadedOrLoadsSuccessfully then result := self.fHeaders.Text;
end;

function TCSVUpdater.getRowByIndex(AIndex: integer): string;
begin
  result := '';
  if (AIndex<1) then raise Exception.Create('Row must be >= 1'); // Truly an exception

  if (self.FileLoaded) and (Aindex<=self.fBody.Count) then
      result := self.fBody[AIndex-1];
end;

function TCSVUpdater.getRowByValue(AHeader, AValue: string): string;
begin

end;

function TCSVUpdater.HeaderLoadedOrLoadsSuccessfully: boolean;
begin
  if ( (fHeaders.Count=0) ) and ( FileLoaded ) then
  begin
    self.FHeaders.DelimitedText := self.fBody[0];
    self.FBody.Delete(0);
  end;
  result := self.fHeaders.Count>0;
end;


procedure TCSVUpdater.setRowByIndex(AIndex: integer; const Value: string);
begin

end;


{ TValidatedFilename }

procedure TValidatedFilename.Clear;
begin
  self.FName := '';
  self.isValid := false;
  self.InvalidReason := 'No file name has been set.';
end;

class operator TValidatedFilename.Implicit(AFileName: string): TValidatedFilename;
begin
  Result.Clear;
  Result.Validate(AFilename);
end;

function TValidatedFilename.getName: string;
begin
  if isValid then Result:= FName
  else Result := Validate(Fname);
end;

function TValidatedFilename.Validate(AFilename: string): string;
begin
  Result := '';
  Clear;
  FName := AFilename;
  if (FName<>'') and
     not (FileExists(FName, ALWAYS_FOLLOW_LINK_FILES)) then
     InvalidReason := format('File %s does not exist', [FName])
  else
  begin
    IsValid := true;
    InvalidReason := '';
    Result := Name;
  end;

end;

end.
