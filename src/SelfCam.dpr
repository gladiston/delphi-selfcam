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
  Application.Title := 'SelfCam-S� tenho olhos para voc�';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
