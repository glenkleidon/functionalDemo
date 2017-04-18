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
  public
    property Filename: string read fFileName write SetFilename;
    property Headers : string read getHeaders write SetHeaders;
    property Row[AIndex : integer] : string read getRowbyIndex write setRowByIndex;
  end;

implementation

{ TCSVUpdater }

constructor TCSVUpdater.Create(AFilename: string);
begin
  fHeaders := TStringlist.Create;
  fBody := TStringList;
end;

destructor TCSVUpdater.Destroy;
begin
  freeandNil(Self.fBody);
  freeandNil(self.fHeaders);
  inherited;
end;

function TCSVUpdater.getHeaders: string;
begin
  fLastError := '';
  result := '';
  if (fHeaders.Count=0) then
  try
   LoadHeaders;
   result := self.fHeaders.Text;
  Except
   on e:exception do
     fLastError := 'Could not load headers: '+ e.Message;
  end;
end;

function TCSVUpdater.getRowByIndex(AIndex: integer): string;
begin
  result := LocateRow(AIndex);
end;

function TCSVUpdater.getRowByValue(AHeader, AValue: string): string;
begin

end;

Procedure TCSVUpdater.LoadHeaders;
var fStream : TFileStream;
    lList : TStringlist;
begin
  if (fFileName<>'') and
     (FileExists(fFilename,true)) then
  begin
    fStream := TFileStream.Create(fFilename, fmOpenRead or fmShareDenyNone);
    lList := TStringlist;
    try
      lList.QuoteChar := '"';
      lList.Delimiter := ',';
      lList.LineBreak := #13#10;
      lList.LoadFromStream(fStream);

    finally
      FreeAndNil(lList);
      freeAndNil(FStream);
    end;
  end;

end;

function TCSVUpdater.LocateRow(AIndex: integer): string;
begin
  if (AIndex<1) then raise Exception.Create('Row must be >= 1');


end;

procedure TCSVUpdater.SetFilename(const Value: string);
begin
    fFileName := Value;
end;

procedure TCSVUpdater.SetHeaders(const Value: string);
begin

end;

procedure TCSVUpdater.setRowByIndex(AIndex: integer; const Value: string);
begin

end;

end.
