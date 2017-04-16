unit uCSVUpdater;

interface

uses System.Classes, System.SysUtils, System.Generics;

type

  TCSVUpdater = class
    constructor Create(AFilename: string);
    destructor  Destroy; override;
  private
    fFileName: string;
    fHeaders: TStringList;
    function getHeaders: string;
    procedure SetHeaders(const Value: string);
    function LoadHeaders: boolean;
    function getRowByIndex(AIndex: integer): string;
    procedure setRowByIndex(AIndex: integer; const Value: string);
    function LocateRow(AIndex: integer): string;
  public
    property Filename: string read fFileName write fFilename;
    property Headers : string read getHeaders write SetHeaders;
    property Row[AIndex: integer] : string read getRowbyIndex write setRowByIndex;
    property Row[AHeader: string; AValue : Value<T>] read getRowByValue write setRowByValue;

  end;

implementation

{ TCSVUpdater }

constructor TCSVUpdater.Create(AFilename: string);
begin
  self.fHeaders := TStringlist.Create;
end;

destructor TCSVUpdater.Destroy;
begin
  freeandNil(self.fHeaders);
  inherited;
end;

function TCSVUpdater.getHeaders: string;
begin
 result := '';
 if (fHeaders.Count=0) then if not(LoadHeaders) then
   raise exception.Create('No headers found');

end;

function TCSVUpdater.getRowByIndex(AIndex: integer): string;
begin
  result := LocateRow(AIndex);
end;

function TCSVUpdater.LoadHeaders: boolean;
begin

end;

function TCSVUpdater.LocateRow(AIndex: integer): string;
begin
  if (AIndex<1) then raise Exception.Create('Row must be >= 1');


end;

procedure TCSVUpdater.SetHeaders(const Value: string);
begin

end;

procedure TCSVUpdater.setRowByIndex(AIndex: integer; const Value: string);
begin

end;

end.
