program CSVUpdater;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uCSVUpdater in 'uCSVUpdater.pas',
  GlenKleidon.CSVUtils in 'GlenKleidon.CSVUtils.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
