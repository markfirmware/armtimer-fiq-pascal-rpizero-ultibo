unit EventCounter;
{$mode objfpc}{$H+}

interface
type
 TCounterWithHertz=class
  function Count:LongWord; virtual; abstract;
  function Hertz:Double; virtual;
  function Period:Double; virtual;
 end;
 TTickCounter=class(TCounterWithHertz)
  function Count:LongWord; override;
  function Hertz:Double; override;
 end;
 TTimeCounter=class(TCounterWithHertz)
  function Count:LongWord; override;
  function Hertz:Double; override;
 end;
 TArmTimerCounter=class(TCounterWithHertz)
  function Count:LongWord; override;
  function Hertz:Double; override;
  class procedure InitializeControlRegister;
 end;
 TEventCounter=class(TCounterWithHertz)
  EventCount:LongWord;
  ReferenceCountAtFirstEvent:LongWord;
  ReferenceCountAtLastEvent:LongWord;
  ReferenceCounter:TCounterWithHertz;
  class function  Create:TEventCounter;
  class function  CreateHighPrecision:TEventCounter;
  constructor Create(SomeReferenceCounter:TCounterWithHertz);
  procedure Increment;
  function Count:LongWord; override;
  function Hertz:Double; override;
  procedure Reset;
 end;

implementation
uses
{$ifdef ULTIBO}
 {$ifdef BUILD_RPI}
  bcm2835,
 {$endif}
 {$ifdef BUILD_RPI2}
  bcm2837,
 {$endif}
 devices, globalconst,
{$endif}
 sysutils;
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
function TTickCounter.Count:LongWord;
begin
 Count:=GetTickCount;
end;
function TTimeCounter.Hertz:Double;
begin
 Hertz:=1000;
end;
function TTimeCounter.Count:LongWord;
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
class procedure TArmTimerCounter.InitializeControlRegister;
var
 ControlRegister:LongWord;
begin
 {$ifdef ULTIBO}
  ControlRegister:=PBCM2835ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Control;
  ControlRegister:=ControlRegister and not BCM2835_ARM_TIMER_CONTROL_COUNTER_PRESCALE;
  ControlRegister:=ControlRegister or BCM2835_ARM_TIMER_CONTROL_COUNTER_ENABLED;
  PBCM2835ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Control:=ControlRegister;
 {$else}
  ControlRegister:=0;
  ControlRegister:=ControlRegister;
 {$endif}
end;
function TArmTimerCounter.Count:LongWord;
begin
 {$ifdef ULTIBO}
  Count:=PBCM2835ARMTimerRegisters(TimerDeviceGetDefault^.Address)^.Counter;
 {$else}
  Count:=0;
 {$endif}
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
function TEventCounter.Count:LongWord;
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
 TArmTimerCounter.InitializeControlRegister;
end.
