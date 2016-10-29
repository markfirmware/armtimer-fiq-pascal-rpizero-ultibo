program Screen;

uses {$ifdef ULTIBO} UltiboCrtSurrogate {$else} Crt {$endif}, EventCounter, SysUtils;

var
 FrameCounter:TEventCounter;
 Quiet:Boolean;

begin
 Quiet:=False;
 FrameCounter:=TEventCounter.Create;
 CursorOff;
 ClrScr;
 while True do
  begin
   FrameCounter.Increment;
   if FrameCounter.Count mod 100 = 0 then
    begin
     if KeyPressed then
      begin
       case ReadKey of
        ' ': Quiet:=not Quiet;
        'q': halt(0);
        'z': FrameCounter.Reset;
       end;
      end;
    end;
   if Quiet then
    begin
     GotoXY(1,2);
     WriteLn('Quiet');
    end
   else
    begin
     GotoXY(1,1);
     WriteLn(Format('Frames %7.3f Hz %7.3f ms   ',[FrameCounter.Hertz,FrameCounter.Period * 1000]));
    end;
  end;
end.
