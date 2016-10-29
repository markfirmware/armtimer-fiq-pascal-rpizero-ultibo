program Screen;

uses
 {$ifdef ULTIBO}
  {$include UltiboImplementationUnits.inc}
  DwcOtg,
  Keyboard,
  UltiboCrtSurrogate,
 {$else}
  Crt,
 {$endif}
 EventCounter;

var
 FrameCounter:TEventCounter;
 Quiet:Boolean;
 SdCardIsPresent,SdCardWasPresent:Boolean;
 SdCardString:String;

procedure UpdateSdCard;
begin
 SdCardWasPresent:=SdCardIsPresent;
 SdCardIsPresent:=DirectoryExists('c:');
 if SdCardIsPresent then
  SdCardString:='Y'
 else
  SdCardString:='N';
 if SdCardIsPresent and not SdCardWasPresent then
  SystemRestart(100);
end;

begin
 Sleep(3000);
 Quiet:=False;
 SdCardIsPresent:=True;
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
     UpdateSdCard;
    end;
   GotoXY(1,1);
   if Quiet then
    WriteLn('Quiet')
   else
    WriteLn(Format('      Frames %7.3f Hz %7.3f us   %s',[FrameCounter.Hertz,FrameCounter.Period * 1000*1000,SdCardString]));
  end;
end.
