unit uQuickDemo;

interface
  uses System.Classes, System.SysUtils, uRaiseOnInvalidParameter;

  type
    TMyClass = Class
    private
      fSideEffect: string;
    public
      property SideEffect : string read fSideEffect write fSideEffect;
      function CalculateSum(AInteger1, AInteger2 : integer): integer;
    End;
    
    [TRaiseOnCastFailure('Invalid Integer %d. Value must be >1')]
    TIntegerGTOne = Record
      IntValue: Cardinal;
    public
      function isValid(AInt: integer) : boolean;
      class operator Implicit(AInt : Integer): TIntegerGTOne;
    End;

    TIntegerGTOneBase = Class
    private
      fIntValue: Cardinal;
      function isValid(AInt: integer) : boolean;
    public
      property IntValue : Cardinal read fIntValue;
      Constructor Create(AInt: Integer);
      Class function New(AInt: Integer): Cardinal;
    End;
    

implementation
{ TMyClass }

function TMyClass.CalculateSum(AInteger1, AInteger2: integer): integer;
begin
   result := AInteger1 + AInteger2;
   self.fSideEffect := Result.ToString();
end;

{ TIntegerGTOneBase }

class operator TIntegerGTOne.Implicit(AInt: Integer): TIntegerGTOne;
var lFmtString: string;
begin
   result.IntValue := 2;
   if Result.isValid(AInt) then
   begin
     result.IntValue := AInt;
     exit;
   end;
   // Do I need to Raise??
  lFmtString := ExtractOneGTErrorMsg(TypeInfo(TIntegerGTOne));
  if lFmtString<>'' then raise Exception.Createfmt(lFmtString, [Aint]);
end;

function TIntegerGTOne.isValid(AInt: Integer): boolean;
begin
  result := (AInt>1);
end;

function TIntegerGTOneBase.isValid(AInt: integer): boolean;
begin
  result := (AInt>1);
end;

class function TIntegerGTOneBase.New(AInt: Integer): Cardinal;
var lFmtString: string;
    lGTOne: TIntegerGTOneBase;
begin
   lGTOne := Self.Create(AInt);
   try
     result := lGtone.IntValue;
   finally
     freeandnil(lGTOne);
   end;
end;

{ TIntegerGTOneBase }

constructor TIntegerGTOneBase.Create(AInt: Integer);
var lFmtString: string;
begin
   fIntValue := 2;
   if isValid(AInt) then
     begin
       fIntValue := AInt;
       exit;
     end;
     // Do I need to Raise??
     
    lFmtString := ExtractOneGTErrorMsg(self);
    if lFmtString<>'' then raise Exception.Createfmt(lFmtString, [Aint])
end;


end.
