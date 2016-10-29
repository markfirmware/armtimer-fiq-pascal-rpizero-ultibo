unit UltiboCrtSurrogate;

interface
procedure ClrScr;
procedure CursorOff;
procedure GotoXY(X,Y:Integer);
function KeyPressed:Boolean;
function ReadKey:String;

implementation
uses
 Console;

procedure ClrScr;
begin
 ConsoleClrScr;
end;
procedure CursorOff;
begin
// ConsoleCursorOff;
end;
procedure GotoXY(X,Y:Integer);
begin
 ConsoleGotoXY(X,Y);
end;
function KeyPressed:Boolean;
begin
 KeyPressed:=ConsoleKeyPressed;
end;
function ReadKey:String;
begin
 ReadKey:=ConsoleReadKey;
end;
end.
