unit uRaiseOnInvalidParameter;

interface
  uses System.RTTI;
  type


   TRaiseOnCastFailureAttribute = Class(TCustomAttribute)
   public
     FValue : string;
     constructor Create(const ARaiseOnFail : string);
   end;

Function ExtractOneGTErrorMsg(AObj : TObject): string; overload;
Function ExtractOneGTErrorMsg(ATypeInfo: pointer; AObj: TObject=nil): string; overload;

implementation


{ TRaiseOnCastFailureAttribute }

constructor TRaiseOnCastFailureAttribute.Create(const ARaiseOnFail: string);
begin
  self.FValue := ARaiseOnFail;
end;

Function ExtractOneGTErrorMsg(AObj : TObject): string;
begin
  Result := ExtractOneGTErrorMsg(Nil, AObj);
end;

Function ExtractOneGTErrorMsg(ATypeInfo: pointer; AObj: TObject=nil): string;
var
  LContext: TRttiContext;
  LType: TRttiType;
  LAttr: TCustomAttribute;
begin
  Result:='';
  { Create a new Rtti context }
  LContext := TRttiContext.Create;

  { Extract type information for TSomeType type }
  if AObj<>nil then
    LType := lContext.GetType(AObj.ClassInfo)
  else
    LType := LContext.GetType(ATypeInfo);
  if lType=nil then exit;


  { Search for the custom attribute and do some custom processing }
  for LAttr in LType.GetAttributes() do
    if LAttr is TRaiseOnCastFailureAttribute then
    begin
      Result := TRaiseOnCastFailureAttribute(LAttr).FValue;
      exit;
    end;
  { Destroy the context }
  LContext.Free;
end;



end.
