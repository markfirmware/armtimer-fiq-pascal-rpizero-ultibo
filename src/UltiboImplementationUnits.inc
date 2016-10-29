 GlobalConfig, GlobalConst, GlobalTypes, Console, Devices, Platform, SysUtils,

{$ifdef BUILD_RPI}
 RaspberryPi, PlatformRpi, BCM2708, BCM2835
{$endif}

{$ifdef BUILD_RPI2}
 RaspberryPi2, PlatformRpi2, BCM2709, BCM2836
{$endif}
