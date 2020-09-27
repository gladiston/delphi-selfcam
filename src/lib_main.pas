unit lib_main;

interface

uses shellapi,
     inifiles,
     FileCtrl,
     Controls,
     Types,
     Classes,
     StrUtils,
     SysUtils,
     DateUtils,
     Forms,
     windows,
     StdCtrls,
     Buttons,
     Math,
     Messages,
     Graphics;

function GetCurrentUserName : string;
function GetDeviceList(var Lista:TStringList):Integer;
procedure HideTitlebar(AForm:TForm);
procedure ShowTitlebar(AForm:TForm);
procedure SethWndTrasparent(hWnd: HWND;Transparent:boolean);
procedure SetFormTransparent(Aform: TForm; AValue: Boolean);

implementation

function capGetDriverDescriptionA(DrvIndex: Cardinal;
                                  Name: PAnsiChar;
                                  NameLen: Integer;
                                  Description: PAnsiChar;
                                  DescLen: Integer) : Boolean;
                                  stdcall;
                                external 'avicap32.dll' name 'capGetDriverDescriptionA';

function GetCurrentUserName : string;
const
  cnMaxUserNameLen = 254;
var
  sUserName     : string;
  dwUserNameLen : DWord;
begin
  dwUserNameLen := cnMaxUserNameLen-1;
  SetLength( sUserName, cnMaxUserNameLen );
  GetUserName(PChar( sUserName ),dwUserNameLen );
  SetLength( sUserName, dwUserNameLen );
  Result := sUserName;
end;

function GetDeviceList(var Lista:TStringList):Integer;
var
  I: Integer;
  DeviceName: array [0..MAX_PATH] of AnsiChar;
  DeviceVersion: array [0..MAX_PATH] of AnsiChar;
begin
  result := 0;
  for I := 0 to 9 do // you can have no more then 10 install apparently?
  begin
    if capGetDriverDescriptionA(I, DeviceName, SizeOf(DeviceName), DeviceVersion, SizeOf(DeviceVersion)) then
    begin
      inc(Result);
      //Lista.Add(String(DeviceName));
      Lista.Add(String(DeviceName));
    end;
  end;
  //- See more at: http://codeverge.com/embarcadero.delphi.nativeapi/active-camera-count/1072690#sthash.oDIo59Jl.dpuf
end;

procedure HideTitlebar(AForm:TForm);
var
  Style: Longint;
begin
  if AForm.BorderStyle = bsNone then Exit;
  Style := GetWindowLong(AForm.Handle, GWL_STYLE);
  if (Style and WS_CAPTION) = WS_CAPTION then
  begin
    case AForm.BorderStyle of
      bsSingle,
      bsSizeable: SetWindowLong(AForm.Handle, GWL_STYLE, Style and
          (not (WS_CAPTION)) or WS_BORDER);
      bsDialog: SetWindowLong(AForm.Handle, GWL_STYLE, Style and
          (not (WS_CAPTION)) or DS_MODALFRAME or WS_DLGFRAME);
    end;
    AForm.Height := AForm.Height - GetSystemMetrics(SM_CYCAPTION);
    AForm.Refresh;
  end;
end;

procedure ShowTitlebar(AForm:TForm);
var
  Style: Longint;
begin
  if AForm.BorderStyle = bsNone then Exit;
  Style := GetWindowLong(AForm.Handle, GWL_STYLE);
  if (Style and WS_CAPTION) <> WS_CAPTION then
  begin
    case AForm.BorderStyle of
      bsSingle,
      bsSizeable: SetWindowLong(AForm.Handle, GWL_STYLE, Style or WS_CAPTION or
          WS_BORDER);
      bsDialog: SetWindowLong(AForm.Handle, GWL_STYLE,
          Style or WS_CAPTION or DS_MODALFRAME or WS_DLGFRAME);
    end;
    AForm.Height := AForm.Height + GetSystemMetrics(SM_CYCAPTION);
    AForm.Refresh;
  end;
end;

Procedure SethWndTrasparent(hWnd: HWND;Transparent:boolean);
var
 l        : Longint;
 lpRect   : TRect;
begin
    if Transparent then
    begin
      l := GetWindowLong(hWnd, GWL_EXSTYLE);
      l := l or WS_EX_LAYERED;
      SetWindowLong(hWnd, GWL_EXSTYLE, l);
      SetLayeredWindowAttributes(hWnd, 0, 180, LWA_ALPHA);
    end
    else
    begin
      l := GetWindowLong(hWnd, GWL_EXSTYLE);
      l := l xor WS_EX_LAYERED;
      SetWindowLong(hWnd, GWL_EXSTYLE, l);
      GetWindowRect(hWnd, lpRect);
      InvalidateRect(hWnd, lpRect, true);
    end;
end;

procedure SetFormTransparent(Aform: TForm; AValue: Boolean);
begin
  Aform.TransparentColor := AValue;
  Aform.TransparentColorValue := Aform.Color;
end;

end.
