unit Webcam;
interface
uses
  Windows, Messages, Classes;
type
  TWebcam = class
    constructor Create(
      const WindowName: String = '';
      ParentWnd: Hwnd = 0;
      Left: Integer = 0;
      Top: Integer = 0;
      Width: Integer = 0;
      height: Integer = 0;
      Style: Cardinal = WS_CHILD or WS_VISIBLE;
      WebcamID: Integer = 0);
    public
      const  // AVICAP.H Header File
        WM_CAP_START = WM_USER;
        WM_CAP_SET_CALLBACK_ERROR=WM_CAP_START +2;
        WM_CAP_SET_CALLBACK_STATUSA= WM_CAP_START +3;
        WM_CAP_SET_CALLBACK_FRAME= WM_CAP_START +5;
        WM_CAP_SET_CALLBACK_VIDEOSTREAM = WM_CAP_START +6;
        WM_CAP_DRIVER_CONNECT = WM_CAP_START + 10;
        WM_CAP_DRIVER_DISCONNECT = WM_CAP_START + 11;
        WM_CAP_FILE_SET_CAPTURE_FILEA = WM_CAP_START + 20;
        WM_CAP_SAVEDIB = WM_CAP_START + 25;
        WM_CAP_EDIT_COPY = WM_CAP_START + 30;
        WM_CAP_CONFIGURE = WM_CAP_START + 41;
        WM_CAP_DLG_VIDEOSOURCE = WM_CAP_START + 42;
        WM_CAP_DLG_VIDEODISPLAY = WM_CAP_START + 43;
        WM_CAP_GET_VIDEOFORMAT = WM_CAP_START + 44;
        WM_CAP_SET_VIDEOFORMAT = WM_CAP_START + 45;
        WM_CAP_DLG_VIDEOCOMPRESSION = WM_CAP_START + 46;

        WM_CAP_SET_PREVIEW =WM_CAP_START+ 50;
        WM_CAP_SET_OVERLAY =WM_CAP_START+ 51;
        WM_CAP_SET_PREVIEWRATE = WM_CAP_START + 52;
        WM_CAP_SET_SCALE=WM_CAP_START+ 53;
        WM_CAP_GRAB_FRAME = WM_CAP_START + 60;
        WM_CAP_SEQUENCE = WM_CAP_START + 62;
        WM_CAP_SEQUENCE_NOFILE =WM_CAP_START+ 63;
        WM_CAP_STOP = WM_CAP_START + 68;

        PICWIDTH      = 640;
        PICHEIGHT     = 480;

    public
      CaptureWnd: HWnd;
      procedure Connect;
      procedure Disconnect;
      procedure GrabFrame;
      procedure SaveDIB(const FileName: String = 'webcam.bmp');
      procedure SaveAVI(const FileName: String = 'webcam.avi');
      procedure Preview(&on: Boolean = True);
      procedure PreviewRate(Rate: Integer = 42);
      procedure Configure;
      procedure Stop;
      function Conected:Boolean;
      function GetDeviceList(var Lista:TStringList):Integer;
  end;

implementation

var
libhandle:cardinal;

function capCreateCaptureWindowA(
  WindowName: PChar;
  dwStyle: Cardinal;
  x,y,width,height: Integer;
  ParentWin: HWnd;
  WebcamID: Integer): Hwnd; stdcall external 'AVICAP32.dll';

function capGetDriverDescriptionA(DrvIndex: Cardinal;
                                  Name: PAnsiChar;
                                  NameLen: Integer;
                                  Description: PAnsiChar;
                                  DescLen: Integer) : Boolean;
                                  stdcall;
                                external 'avicap32.dll' name 'capGetDriverDescriptionA';



//  CapGetDriverDescriptionA: function(DrvIndex:cardinal; Name:pansichar;NameLen:cardinal;Description:pansichar;DescLen:cardinal):boolean; stdcall;
//  CapCreateCaptureWindowA: function(lpszWindowName: pchar; dwStyle: dword; x, y, nWidth, nHeight: word; ParentWin: dword; nId: word): dword; stdcall;

{ TWebcam }


constructor TWebcam.Create(const WindowName: String; ParentWnd: Hwnd; Left, Top,
  Width, height: Integer; Style: Cardinal; WebcamID: Integer);
begin
  CaptureWnd := capCreateCaptureWindowA(pWideChar(WindowName), Style, Left, Top, Width, Height, ParentWnd, WebcamID);
  //Application.MessageBox(PWidechar(IntToStr(WebCamId)),'Debug:',0);
  //Connect;
  //CaptureWnd :=  capCreateCaptureWindow('Video', WS_CHILD or _WS_VISIBLE, 0, 0, PICWIDTH, PICHEIGHT, ParentWnd, 1);
  //SendMessage(CaptureWnd, WM_CAP_DRIVER_GET_NAME, length(driver)*sizeof(char), LPARAM(PChar(driver))
  Connect;
end;

function TWebcam.GetDeviceList(var Lista:TStringList):Integer;
var
  I: Integer;
  DeviceName: array [0..MAX_PATH] of AnsiChar;
  DeviceDesc: array [0..MAX_PATH] of AnsiChar;
begin
  result := 0;
  for I := 0 to 9 do // quantidade possivel de fontes de captura que considero sendo o limite
  begin
    if capGetDriverDescriptionA(I, DeviceName, SizeOf(DeviceName), DeviceDesc, SizeOf(DeviceDesc)) then
    begin
      if ((String(DeviceDesc))<>'') then
      begin
        inc(Result);
        Lista.Add(String(DeviceDesc));     // DeviceName or  DeviceDesc
      end;
    end;
  end;
end;

procedure TWebcam.Configure;
begin
  if CaptureWnd <> 0 then
    SendMessage(CaptureWnd, WM_CAP_CONFIGURE, 0, 0);
end;

procedure TWebcam.Connect;
begin
  if CaptureWnd <> 0 then
  begin
    SendMessage(CaptureWnd, WM_CAP_DRIVER_CONNECT, 0, 0);
    SendMessage(CaptureWnd, WM_CAP_SET_SCALE, 1, 0);
    SendMessage(CaptureWnd, WM_CAP_SET_PREVIEWRATE, 33, 0);
    SendMessage(CaptureWnd, WM_CAP_SET_OVERLAY, 1, 0);
    SendMessage(CaptureWnd, WM_CAP_SET_PREVIEW, 1, 0);

    SendMessage(CaptureWnd, WM_CAP_SET_CALLBACK_VIDEOSTREAM, 0, 0);
    SendMessage(CaptureWnd, WM_CAP_SET_CALLBACK_ERROR, 0, 0);
    SendMessage(CaptureWnd, WM_CAP_SET_CALLBACK_STATUSA, 0, 0);

  end;
end;

procedure TWebcam.Stop;
begin
  if CaptureWnd <> 0 then
  begin
    SendMessage(CaptureWnd, WM_CAP_STOP, 0, 0);
  end;
end;

function TWebcam.Conected: Boolean;
begin
  Result:=(CaptureWnd <> 0);
end;

procedure TWebcam.Disconnect;
begin
  if CaptureWnd <> 0 then
  begin
    SendMessage(CaptureWnd, WM_CAP_DRIVER_DISCONNECT, 0, 0);
    SendMessage(CaptureWnd, $0010, 0, 0);
  end;
end;

procedure TWebcam.GrabFrame;
begin
  if CaptureWnd <> 0 then
    SendMessage(CaptureWnd, WM_CAP_GRAB_FRAME, 0, 0);
end;

procedure TWebcam.Preview(&on: Boolean);
begin
  if CaptureWnd <> 0 then
    if &on then
      SendMessage(CaptureWnd, WM_CAP_SET_PREVIEW, 1, 0)
    else
      SendMessage(CaptureWnd, WM_CAP_SET_PREVIEW, 0, 0);
end;

procedure TWebcam.PreviewRate(Rate: Integer);
begin
  if CaptureWnd <> 0 then
    SendMessage(CaptureWnd, WM_CAP_SET_PREVIEWRATE, Rate, 0);
end;

procedure TWebcam.SaveDIB(const FileName: String);
begin
  if CaptureWnd <> 0 then
    SendMessage(CaptureWnd, WM_CAP_SAVEDIB, 0, Longint(PChar(Filename)));

end;

procedure TWebcam.SaveAVI(const FileName: String = 'webcam.avi');
begin
  if CaptureWnd <> 0 then
  begin
    //SendMessage(CaptureWnd, WM_CAP_SAVEDIB, 0, Cardinal(PChar(FileName)));
    SendMessage(CaptureWnd, WM_CAP_FILE_SET_CAPTURE_FILEA, 0, Longint(PChar(Filename)));
    SendMessage(CaptureWnd, WM_CAP_SEQUENCE, 0, 0);
  end;
end;


{initialization
  LibHandle := LoadLibrary('avicap32.dll');
  CapGetDriverDescriptionA := GetProcAddress(LibHandle,'capGetDriverDescriptionA');
  CapCreateCaptureWindowA := GetProcAddress(LibHandle,'capCreateCaptureWindowA');
}
end.
