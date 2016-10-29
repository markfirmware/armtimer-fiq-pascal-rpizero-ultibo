unit UltiboCrtSurrogate;

interface
procedure ClrScr;
procedure CursorOff;
procedure GotoXY(X,Y:Integer);
procedure Halt(StatusCode:Integer);
function KeyPressed:Boolean;
function ReadKey:String;

implementation
uses
 Console, GlobalConst, GlobalTypes;

var
 Window:TWindowHandle;

procedure ClrScr;
begin
 ConsoleWindowClear(Window);
end;
procedure CursorOff;
begin
 ConsoleWindowCursorOff(Window);
end;
procedure GotoXY(X,Y:Integer);
begin
 ConsoleWindowSetXY(Window,X,Y);
end;
procedure Halt(StatusCode:Integer);
begin
end;
function KeyPressed:Boolean;
begin
 KeyPressed:=ConsoleKeyPressed;
end;
function ReadKey:String;
begin
 ReadKey:=ConsoleReadKey;
end;
procedure WriteLn(Line:String);
begin
 ConsoleWindowWriteLn(Window,Line);
end;

initialization
 Window:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULL,True);
end.
