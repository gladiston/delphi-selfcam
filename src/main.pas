unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, WebCam, FMX.Media,
  Vcl.ImgList, Vcl.StdCtrls, System.Actions, Vcl.ActnList, Vcl.Menus,
  System.Types, inifiles;

type
  TfrmPrincipal = class(TForm)
    Guardar: TSaveDialog;
    ImageList1: TImageList;
    ActionList1: TActionList;
    DoSair: TAction;
    DoIniciarGravacao: TAction;
    DoPararGravacao: TAction;
    DoSalvarFoto: TAction;
    DoConfig: TAction;
    DoStayOnTop: TAction;
    PopupMenu1: TPopupMenu;
    MenuConectar: TMenuItem;
    teste21: TMenuItem;
    MenuIniciarGravacao: TMenuItem;
    MenuPararGravacao: TMenuItem;
    N4: TMenuItem;
    Capturarumafoto2: TMenuItem;
    N5: TMenuItem;
    Configurardispositivo2: TMenuItem;
    N6: TMenuItem;
    MenuStayOnTop: TMenuItem;
    Panel1: TPanel;
    DoTransparencia: TAction;
    MenuTransparencia: TMenuItem;
    N1: TMenuItem;
    DoSobre: TAction;
    Sobreesteprograma1: TMenuItem;
    N2: TMenuItem;
    Timer1: TTimer;
    DoExibeRelogio: TAction;
    Exibirounodatahoraatuais1: TMenuItem;
    Timer_StartOptions: TTimer;
    Titulo: TPanel;
    picmenu: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DoSairExecute(Sender: TObject);
    procedure DoIniciarGravacaoExecute(Sender: TObject);
    procedure DoPararGravacaoExecute(Sender: TObject);
    procedure DoSalvarFotoExecute(Sender: TObject);
    procedure DoConfigExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DoStayOnTopExecute(Sender: TObject);
    procedure MovimentarJanela(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure picmenuDblClick(Sender: TObject);
    procedure ConectarEm(Sender: TObject);
    procedure CriarListaDeDevices;
    procedure DoTransparenciaExecute(Sender: TObject);
    procedure DoSobreExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DoExibeRelogioExecute(Sender: TObject);
    procedure Timer_StartOptionsTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FMyDevice, FMyLastDevice:Integer;
    FUserName:String;
    procedure WMNCHitTest(var Msg: TWMNCHitTest) ; message WM_NCHitTest;
    procedure ReadConfig;
    procedure WriteConfig;
    function DesConectar:Boolean;
  public
    { Public declarations }
    camera: TWebcam;
  end;

var
  frmPrincipal: TfrmPrincipal;

const
  TituloEspaco='        ';

implementation
uses lib_main;
{$R *.dfm}

procedure TfrmPrincipal.WMNCHitTest(var Msg: TWMNCHitTest) ;
begin
  inherited;
  if Msg.Result = htClient then Msg.Result := htCaption;
end;

procedure TfrmPrincipal.WriteConfig;
var MyIni:TIniFile;
begin
  MyIni:=TInifile.Create('SelfCam.ini');
  MyIni.WriteInteger('Conexao','Device',FMyDevice);
  MyIni.WriteString('Conexao','USER_NAME',FUserName);
  MyIni.WriteInteger('Conexao','Top',Top);
  MyIni.WriteInteger('Conexao','Left',Left);
  MyIni.WriteInteger('Conexao','Width',Width);
  MyIni.WriteInteger('Conexao','Height',Height);
  MyIni.WriteBool('Conexao','StayOnTop',DoStayOnTop.Checked);
  MyIni.WriteBool('Conexao','ExibeRelogio',DoExibeRelogio.Checked);
  MyIni.WriteBool('Conexao','Transparencia',DoTransparencia.Checked);
  FreeAndNil(MyIni);

end;

procedure TfrmPrincipal.ReadConfig;
var MyIni:TInifile;
begin
  MyIni:=TInifile.Create('SelfCam.ini');
  FMyLastDevice:=MyIni.ReadInteger('Conexao','Device',-1);
  Top:=MyIni.ReadInteger('Conexao','Top',Top);
  Left:=MyIni.ReadInteger('Conexao','Left',Left);
  Width:=MyIni.ReadInteger('Conexao','Width',Width);
  Height:=MyIni.ReadInteger('Conexao','Height',Height);
  DoStayOnTop.Checked:=MyIni.ReadBool('Conexao','StayOnTop',false);
  DoExibeRelogio.Checked:=MyIni.ReadBool('Conexao','ExibeRelogio',false);
  DoTransparencia.Checked:=MyIni.ReadBool('Conexao','Transparencia',false);
  FreeAndNil(MyIni);
end;


function TfrmPrincipal.DesConectar:Boolean;
begin
  Result:=false;
  if Camera<>nil then
  begin
    Camera.Stop;
    Camera.Disconnect;
    DoIniciarGravacao.Enabled:=false;
    DoSalvarFoto.Enabled:=false;
    DoPararGravacao.Enabled:=false;
  end;
  Result:=true
end;

procedure TfrmPrincipal.ConectarEm(Sender: TObject);
var sOption, sDev:String;
    nTry, n:Integer;
begin
  sOption:=LowerCase(Trim((Sender as TMenuItem).Hint));
  if Pos('desconectar',sOption)>0 then
  begin
    DesConectar;
    FreeAndNil(Camera);
    exit;
  end;

  sDev:=Copy(sOption,1,Pos('.',sOption)-1);
  FMyLastDevice:=FMyDevice;
  nTry:= StrToIntDef(sDev,0);
  if nTry<>FMyDevice then
  begin
    DesConectar;
    for n := 0 to Pred(MenuConectar.Count) do
    begin
       sOption:=MenuConectar.Items[n].Caption;
       if Pos(IntToStr(FMyLastDevice)+'.',sOption)>0 then MenuConectar.Items[n].ImageIndex:=MenuConectar.Items[n].ImageIndex+1;
       if Pos(IntToStr(nTry)+'.',sOption)>0 then MenuConectar.Items[n].ImageIndex:=MenuConectar.Items[n].ImageIndex-1;
    end;
    FMyDevice:=nTry;
    if Camera=nil then
    begin
      Camera := TWebcam.Create(Application.Title,
        Panel1.Handle,
        0,
        0,
        Panel1.Width,
        Panel1.Height,
        WS_CHILD or WS_VISIBLE,   //   WS_CHILD + WS_VISIBLE + WS_OVERLAPPED
        FMyDevice);   //  FMyDevice
    end;
    Camera.Connect;
    Camera.Preview(true);
    Camera.PreviewRate(4);
    DoIniciarGravacao.Enabled:=true;
    DoSalvarFoto.Enabled:=true;
    DoPararGravacao.Enabled:=false;
    Timer_StartOptions.Enabled:=true;
  end;
end;

procedure TFrmPrincipal.CriarListaDeDevices;
var L:TStringList;
    n:Byte;
    NewOption:TMenuItem;
    bOnlyOne:Boolean;
begin
  if (FMyDevice<0) and (Camera=nil) then
  begin
    L:=TStringList.Create;
    GetDeviceList(L);
    if L.Count=1 then bOnlyOne:=true;

    for n := 0 to Pred(L.Count) do
    begin
      if Trim(L[n])<>'' then
      begin
        NewOption:=TMenuItem.Create(Self);
        NewOption.Hint:=IntToStr(n+1)+'. '+L[n];
        NewOption.Caption:=IntToStr(n+1)+'. '+L[n];
        NewOption.ImageIndex:=3;
        NewOption.OnClick:=ConectarEm;
        MenuConectar.Add(NewOption);
        if ((n=FMyLastDevice) or (bOnlyOne)) then
        begin
          ConectarEm(NewOption);
        end;
      end;
    end;
    NewOption:=TMenuItem.Create(Self);
    NewOption.Caption:='-';
    NewOption.OnClick:=nil;
    MenuConectar.Add(NewOption);
    NewOption:=TMenuItem.Create(Self);
    NewOption.Hint:='Desconectar';
    NewOption.Caption:='Desconectar';
    NewOption.OnClick:=ConectarEm;
    NewOption.ImageIndex:=2;
    MenuConectar.Add(NewOption);

    NewOption:=TMenuItem.Create(Self);
    NewOption.Hint:='0. AutoDetectar';
    NewOption.Caption:='0. AutoDetectar';
    NewOption.OnClick:=ConectarEm;
    NewOption.ImageIndex:=3;
    MenuConectar.Insert(0,NewOption);
  end;

end;

procedure TfrmPrincipal.MovimentarJanela(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(frmPrincipal.Handle, WM_SYSCOMMAND, 61458, 0) ;
end;

procedure TfrmPrincipal.picmenuDblClick(Sender: TObject);
begin
  POpupmenu1.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;




procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
begin
  Titulo.Caption:=TituloEspaco+FormatDateTime('dd/mm/yyyy hh''h''mm',now)+'-'+FUserName;
end;

procedure TfrmPrincipal.Timer_StartOptionsTimer(Sender: TObject);
begin
  if (Self.Active) and (Camera<>nil) then
  begin
    Timer_StartOptions.Enabled:=false;
    DoStayOnTopExecute(Self);
    DoExibeRelogioExecute(Self);
    DoTransparenciaExecute(Self);
  end;
end;

procedure TfrmPrincipal.DoConfigExecute(Sender: TObject);
begin
  if Camera.Conected
  then Camera.Configure
  else Application.MessageBox('WebCam não foi conectada!','Erro:', MB_ICONERROR);
end;

procedure TfrmPrincipal.DoExibeRelogioExecute(Sender: TObject);
begin
  Timer1.Enabled:=(DoExibeRelogio.Checked);
  Timer1Timer(Self);
end;

procedure TfrmPrincipal.DoStayOnTopExecute(Sender: TObject);
begin
  if FormStyle = fsStayOnTop then
  begin
    Self.FormStyle := fsNormal;
  end
  else
  begin
    Self.FormStyle := fsStayOnTop;
  end;
end;

procedure TfrmPrincipal.DoTransparenciaExecute(Sender: TObject);
begin
  if MenuTransparencia.Checked then
  begin
    SethWndTrasparent(Self.Handle, true);
  end
  else
  begin
    SethWndTrasparent(Self.Handle, false);
    //Titulo.BevelInner := bvNone;
    //Titulo.BevelOuter := bvNone;
    //Titulo.BorderStyle := bsNone;
    //Titulo.ParentBackground := True;
    //SetFormTransparent(Self, true);
  end;
end;

procedure TfrmPrincipal.DoIniciarGravacaoExecute(Sender: TObject);
begin
   IF Camera.Conected THEN
   BEGIN
      Guardar.Filter := 'Arquivo AVI (*.avi)*.avi';
      Guardar.DefaultExt := 'avi';
      Guardar.FileName := 'Video.Avi';
      IF Guardar.Execute THEN
      BEGIN
        Camera.SaveAVI(Guardar.Filename);
        DoIniciarGravacao.Enabled:=false;
        DoPararGravacao.Enabled:=true;
      END;

      Titulo.Caption:=TituloEspaco+'Gravando - '+Guardar.Filename;
   END;
end;


procedure TfrmPrincipal.DoPararGravacaoExecute(Sender: TObject);
begin
  if Camera.Conected then
  begin
    Camera.Stop;
    DoIniciarGravacao.Enabled:=true;
    DoPararGravacao.Enabled:=false;
  end;
  Titulo.Caption:=TituloEspaco+FUserName;
end;

procedure TfrmPrincipal.DoSairExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.DoSalvarFotoExecute(Sender: TObject);
begin
  if Camera.Conected then
  begin
    Guardar.FileName := 'Captura';
    Guardar.DefaultExt := 'bmp';
    Guardar.Filter := 'Arquivo Bitmap (*.bmp)|*.bmp';
    if Guardar.Execute then Camera.SaveDIB(Guardar.FileName);
  end;

{
var
  PanelDC: HDC;
begin
if not Assigned(Image1.Picture.Bitmap) then
    Image1.Picture.Bitmap := TBitmap.Create
  else
  begin
    Image1.Picture.Bitmap.Free;
    Image1.picture.Bitmap := TBitmap.Create;
  end;
  Image1.Picture.Bitmap.Height := Panel1.Height;
  Image1.Picture.Bitmap.Width  := Panel1.Width;
  Image1.Stretch := True;
  PanelDC := GetDC(Panel1.Handle);
  try
    BitBlt(Image1.Picture.Bitmap.Canvas.Handle,
      0,0,Panel1.Width, Panel1.Height, PanelDC, 0,0, SRCCOPY);
  finally
    ReleaseDC(Handle, PanelDC);
  end;
}
end;

procedure TfrmPrincipal.DoSobreExecute(Sender: TObject);
begin
  Application.MessageBox(
    pWideChar('Desenvolvido por:'+sLineBreak+
      'Gladiston (hamacker) Santana'+sLineBreak+
      '(2015) Todos os direitos reservados.'+sLineBreak+
      'Licença de uso: LGPL'),
    pWideChar('Sobre este programa:'),MB_ICONINFORMATION);

end;

procedure TfrmPrincipal.FormActivate(Sender: TObject);
begin
  Timer_StartOptions.Enabled:=true;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Camera<>nil then
    if Camera.Conected then DesConectar;
  WriteConfig;

  Action:=CaFree;


end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FMyDevice:=-1;
  FMyLastDevice:=-1;
  Timer1.Enabled:=false;
  Timer1.Interval:=5000;
  Timer_StartOptions.Interval:=3000;
  Timer_StartOptions.Enabled:=false;
  frmPrincipal.PopupMenu:=PopupMenu1;
  picmenu.PopupMenu:=PopupMenu1;
  FUserName:=GetCurrentUserName;
  Titulo.Caption:=TituloEspaco+FUserName;
  HideTitlebar(Self);
  Caption:='Video captura de '+FUserName;
  ReadConfig;


  CriarListaDeDevices;
end;

procedure TfrmPrincipal.FormResize(Sender: TObject);
begin
  if Camera<>nil then
  begin
    MoveWindow(Camera.CaptureWnd,0,0,ClientWidth, ClientHeight, false);
  end;
end;

end.
