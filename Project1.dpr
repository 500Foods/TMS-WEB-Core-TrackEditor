program Project1;

{$R *.dres}

uses
  Vcl.Forms,
  WEBLib.Forms,
  Unit1 in 'Unit1.pas' {Form1: TWebForm} {*.html},
  WebAudioAPIHelper in 'WebAudioAPIHelper.pas' {WAAH: TWebDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TWAAH, WAAH);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
