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
       Name: string;
       InvalidReason: string;
       IsValid: boolean;
  public
       Procedure Clear;
       function Validate(AFilename: string): string;
  End;

  TCSVUpdater = class
    constructor Create(AFilename: string);
    destructor  Destroy; override;
  private
    fFileName: string;
    fHeaders: TStringList;
    fBody : TStringList;
    fLastError: string;
    function LoadFileSuccessfully(AValidatedFilename: TValidatedFilename): boolean;
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
var lFilename: TValidatedFilename;
begin
   result := (Self.fBody.Count>0) or
             (
               (lFilename.Validate(Self.fFileName)<>'') and
                LoadFileSuccessfully(lFilename)
              );
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

function TCSVUpdater.LoadFileSuccessfully(AValidatedFilename: TValidatedFilename): boolean;
begin
  result := false;
  try
    self.fBody.LoadFromFile(AValidatedFilename.Name);
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

procedure TValidatedFilename.Clear;
begin
  self.Name := '';
  self.isValid := false;
  self.InvalidReason := 'No file name has been set.';
end;


function TValidatedFilename.Validate(AFilename: string): string;
begin
  Result := '';
  Clear;
  Name := AFilename;
  if (Name<>'') and
     not (FileExists(Name, ALWAYS_FOLLOW_LINK_FILES)) then
     InvalidReason := format('File %s does not exist', [Name])
  else
  begin
    IsValid := true;
    InvalidReason := '';
    Result := Name;
  end;

end;

end.
