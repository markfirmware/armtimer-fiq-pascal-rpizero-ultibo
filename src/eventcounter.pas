unit EventCounter;
{$mode objfpc}{$H+}

interface
type
 TCounterWithHertz=class
  function Count:Int64; virtual; abstract;
  function Hertz:Double; virtual;
  function Period:Double; virtual;
 end;
 TTickCounter=class(TCounterWithHertz)
  function Count:Int64; override;
  function Hertz:Double; override;
 end;
 TTimeCounter=class(TCounterWithHertz)
  function Count:Int64; override;
  function Hertz:Double; override;
 end;
 TArmTimerCounter=class(TCounterWithHertz)
  class var LastArmTimerCount32:LongWord;
  class var ArmTimerJustUpper:Int64;
  class procedure InitializeClass;
  class function Count32:LongWord;
  function Count:Int64; override;
  function Hertz:Double; override;
 end;
 TEventCounter=class(TCounterWithHertz)
  EventCount:Int64;
  ReferenceCountAtFirstEvent:Int64;
  ReferenceCountAtLastEvent:Int64;
  ReferenceCounter:TCounterWithHertz;
  class function  Create:TEventCounter;
  class function  CreateHighPrecision:TEventCounter;
  constructor Create(SomeReferenceCounter:TCounterWithHertz);
  procedure Increment;
  function Count:Int64; override;
  function Hertz:Double; override;
  procedure Reset;
 end;

implementation
uses
{$ifdef ULTIBO}
 {$include UltiboImplementationUnits.inc};
{$endif}
{$ifndef ULTIBO}
 const
  TIME_TICKS_PER_SECOND=1000;
{$endif}

function TCounterWithHertz.Period:Double;
begin
 if Hertz = 0 then
  Period:=0
 else
  Period:=1 / Hertz;
end;
function TCounterWithHertz.Hertz:Double;
begin
 if Period = 0 then
  Hertz:=0
 else
  Hertz:=1 / Period;
end;
function TTickCounter.Hertz:Double;
begin
 Hertz:=TIME_TICKS_PER_SECOND;
end;
function TTickCounter.Count:Int64;
begin
 Count:=GetTickCount64;
end;
function TTimeCounter.Hertz:Double;
begin
 Hertz:=1000;
end;
function TTimeCounter.Count:Int64;
var
 SystemTime:TSystemTime;
begin
 DateTimeToSystemTime(Now,SystemTime);
 Count:=0;
 Inc(Count,SystemTime.Hour);
 Count:=Count * 60;
 Inc(Count,SystemTime.Minute);
 Count:=Count * 60;
 Inc(Count,SystemTime.Second);
 Count:=Count * 1000;
 Inc(Count,SystemTime.Millisecond);
end;
class procedure TArmTimerCounter.InitializeClass;
var
 ControlRegister:LongWord;
begin
 LastArmTimerCount32:=0;
 ArmTimerJustUpper:=0;
 {$ifdef ULTIBO}
  {$ifdef BUILD_RPI}
   ControlRegister:=PBCM2835ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Control;
   ControlRegister:=ControlRegister and not BCM2835_ARM_TIMER_CONTROL_COUNTER_PRESCALE;
   ControlRegister:=ControlRegister or BCM2835_ARM_TIMER_CONTROL_COUNTER_ENABLED;
   PBCM2835ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Control:=ControlRegister;
  {$endif}
  {$ifdef BUILD_RPI2}
   ControlRegister:=PBCM2836ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Control;
   ControlRegister:=ControlRegister and not BCM2836_ARM_TIMER_CONTROL_COUNTER_PRESCALE;
   ControlRegister:=ControlRegister or BCM2836_ARM_TIMER_CONTROL_COUNTER_ENABLED;
   PBCM2836ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Control:=ControlRegister;
  {$endif}
 {$else}
  ControlRegister:=0;
  ControlRegister:=ControlRegister;
 {$endif}
end;
class function TArmTimerCounter.Count32:LongWord;
begin
 {$ifdef ULTIBO}
  {$ifdef BUILD_RPI}
   Count32:=PBCM2835ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Counter;
  {$endif}
  {$ifdef BUILD_RPI2}
   Count32:=PBCM2836ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Counter;
  {$endif}
 {$else}
  Count32:=0;
 {$endif}
end;
function TArmTimerCounter.Count:Int64;
var
 Previous:LongWord;
begin
 Previous:=LastArmTimerCount32;
 LastArmTimerCount32:=TArmTimerCounter.Count32;
 if LastArmTimerCount32 < Previous then
  Inc(ArmTimerJustUpper,$100000000);
 Count:=ArmTimerJustUpper or LastArmTimerCount32;
end;
function TArmTimerCounter.Hertz:Double;
begin
 {$ifdef ULTIBO}
  Hertz:=400*1000*1000;
 {$else}
  Hertz:=0;
 {$endif}
end;
constructor TEventCounter.Create(SomeReferenceCounter:TCounterWithHertz);
begin
 ReferenceCounter:=SomeReferenceCounter;
 Reset;
end;
class function TEventCounter.Create:TEventCounter;
begin
 Create:=TEventCounter.Create(TTickCounter.Create);
end;
class function TEventCounter.CreateHighPrecision:TEventCounter;
begin
 CreateHighPrecision:=TEventCounter.Create(TArmTimerCounter.Create);
end;
function TEventCounter.Count:Int64;
begin
 Count:=EventCount;
end;
procedure TEventCounter.Reset;
begin
 EventCount:=0;
end;
procedure TEventCounter.Increment;
begin
 Inc(EventCount);
 if Count = 1 then
  ReferenceCountAtFirstEvent:=ReferenceCounter.Count
 else
  ReferenceCountAtLastEvent:=ReferenceCounter.Count
end;
function TEventCounter.Hertz:Double;
var Elapsed:Double;
begin
 Elapsed:=(ReferenceCountAtLastEvent - ReferenceCountAtFirstEvent) / ReferenceCounter.Hertz;
 if (Count >= 2) and (Elapsed <> 0) then
  Hertz:=(Count - 1) / Elapsed
 else
  Hertz:=0
end;

initialization
 TArmTimerCounter.InitializeClass;
end.
