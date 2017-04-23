program QuickDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uQuickDemo in 'uQuickDemo.pas',
  uRaiseOnInvalidParameter in '..\componentlibrary\uRaiseOnInvalidParameter.pas',
  Functional.Value;
  type

   [TRaiseOnCastFailure('Hello ADUG - Invalid Integer %d. Value must be >1')]
   TGTOneWithException = class(TIntegerGTOneBase);

   TGTOneWithOutException = Class(TIntegerGTOneBase);


Function EscapeTextForHTML(AText: string): string;
  begin
     Result := AText;
     Result := StringReplace(Result, '&', '&amp;', [rfReplaceAll]);
     Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
     Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
     Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
     Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
  end;

  Function AmIBeingHonestWithYou(Email: string): string;
  begin
    if pos('@', Email)<1 then raise Exception.Create('Invalid Email no @');
    if pos('.', EMail)<1 then raise Exception.Create('Invalid Email - must have "."');
    if length(Email)>254 then raise
        Exception.Create('Invalid Email - must be smaller than 254 characters');
    result := Email;
  end;

var XInt: TIntegerGTOne;
    XInt2: Cardinal;
    XInt3: Cardinal;

    XSideEffect: TMyClass;

begin
  try
    ////  Class Helper
    Writeln('Escape HTML');
    Writeln(StringOfChar('-',11));
    Writeln(Format('Escaped Text is '#13#10+
         '"<html><body>%s</body></html>"',
         [EscapeTextForHTML('I''m > 5 & < 7. I AM "WHAT"?')]));
    Writeln(StringOfChar('=',80));

    ////  Custom Attributes
    Writeln('CustomAttributes ("Decorators")');
    Writeln(StringOfChar('-',31));
    try
      XInt := -5;
      Writeln(Format('Integer Record set to -5 returns %u',[XInt.IntValue]));
    except
      on e:exception do
         Writeln('Integer RECORD raised exception: '#13#10'  '+ e.Message);
    end;

    XInt2 := TGTOneWithOutException.New(-5);
    Writeln(Format('Integer Class set to -5 returns %u',[XInt2]));

    try
      XInt2 := TGTOneWithException.New(-5);
      Writeln(Format('Integer -5 returns %u',[XInt2]));
    except
      on e:exception do
         Writeln('Integer CLASS raised exception: '#13#10'  '+ e.Message);
    end;

    try
    except
      on e:exception do
         Writeln('Integer CLASS raised exception: '#13#10'  '+ e.Message);
    end;
    Writeln(StringOfChar('=',80));

    //// Side Effects
    Writeln('Side Effect');
    Writeln(StringOfChar('-',11));
    XSideEffect := TMyClass.Create();
    Writeln(format('SideEffect is "%s"', [XSideEffect.SideEffect]));
    XSideEffect.CalculateSum(12,8);
    Writeln(format('After Calling Calculate Sum(12,8) - SideEffect is "%s"', [XSideEffect.SideEffect]));
    Writeln(StringOfChar('=',80));


    Writeln('Side Effect');
    Writeln(StringOfChar('-',11));
    XInt3 := HonestSquare(51).Value;
    Writeln(format('Square of 51 is %u (just lucky - should have checked!)', [XInt3]));
    if HonestSquare(65536).HasValue then writeln('Unexpected result in honest Square')
      else writeln('Honest Square told me It couldnt be done');
    try
      XInt3 := HonestSquare(1).Value;
      writeln(format('Square of 1 returned %d',[XInt3]));
    Except
       on e:exception do Writeln('Honest Square raised exception: '#13#10'  '+ e.Message);
    end;

    Writeln(StringOfChar('=',80));

    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
