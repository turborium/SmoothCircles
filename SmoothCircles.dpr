program SmoothCircles;

uses
  Vcl.Forms,
  Main in 'Main.pas' {FormMain},
  Image32 in 'Image32\Image32.pas',
  Image32_Draw in 'Image32\Image32_Draw.pas',
  Image32_Extra in 'Image32\Image32_Extra.pas',
  Image32_Layers in 'Image32\Image32_Layers.pas',
  Image32_Resamplers in 'Image32\Image32_Resamplers.pas',
  Image32_SmoothPath in 'Image32\Image32_SmoothPath.pas',
  Image32_Transform in 'Image32\Image32_Transform.pas',
  Image32_Vector in 'Image32\Image32_Vector.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
