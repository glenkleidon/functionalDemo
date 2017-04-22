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
    procedure SetFilename(const Value: string);
    function getBody: TStrings;
    procedure SetBody(const Value: TStrings);
  public
    property Filename: string read fFileName write SetFilename;
    property Headers : string read getHeaders write SetHeaders;
    property Body : TStrings read getBody write SetBody;
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
  FileName := AFilename;
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
    Headers := self.fBody[0];
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

procedure TCSVUpdater.SetFilename(const Value: string);
begin
    fFileName := expandFileName(Value);
end;

procedure TCSVUpdater.SetHeaders(const Value: string);
begin
  self.fHeaders.DelimitedText := Value;
end;

procedure TCSVUpdater.setRowByIndex(AIndex: integer; const Value: string);
begin

end;

end.
