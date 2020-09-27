program SelfCam;

uses
  Vcl.Forms,
  main in 'main.pas' {frmPrincipal},
  Webcam in 'Webcam.pas',
  lib_main in 'lib_main.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SelfCam-Só tenho olhos para você';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
