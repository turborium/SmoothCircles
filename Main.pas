unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Image32, Image32_Draw, Image32_Vector, Image32_Extra,
  Generics.Collections;

type
  TCircle = record
    X, Y: Double;
    BaseX, BaseY: Double;
    Color: TColor32;
    BaseColor: TColor32;
    Time: Double;
    TimeDelta: Double;
    Radius: Integer;
  end;

  TFormMain = class(TForm)
    PaintBox: TPaintBox;
    Timer: TTimer;
    procedure PaintBoxPaint(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private const
    MaxSize = 25;
    BlurSize = 10;
    CircleAlpha = 160;
    SpriteSize = MaxSize * 2 + BlurSize * 2;
  private var
    Circles: array [0..250] of TCircle;
    Sprites: TDictionary<Integer, TImage32>;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
var
  I: Integer;
  Path: TPathD;
  Sprite: TImage32;
begin
  // создаем точки
  for I := 0 to High(Circles) do
  begin
    // случайное время начала движения
    Circles[I].Time := Random * 20 * Pi;
    // случайная скорость движения
    Circles[I].TimeDelta := Random * 0.015 + 0.005;
    // случайный радиус
    Circles[I].Radius := Random(MaxSize - 5 - 1) + 5;
    // случайные базовые координаты
    Circles[I].BaseX := Random;
    Circles[I].BaseY := Random;
    // случаный базовый цвет
    if Random(2) = 1 then
      Circles[I].BaseColor := RainbowColor(Random * 0.25 + 0.6)
    else
      Circles[I].BaseColor := RainbowColor(Random * 0.3 + 0.45);
  end;

  // создаем размытые спрайты
  Sprites := TDictionary<Integer, TImage32>.Create;
  for I := 1 to MaxSize do
  begin
    // создаем спрайт
    Sprite := TImage32.Create;
    Sprite.SetSize(SpriteSize, SpriteSize);
    // рисуем круг
    Path := Circle(Sprite.MidPoint, I);
    DrawPolygon(Sprite, Path, frNonZero, Color32(CircleAlpha, 0, 0, 0));
    // размываем изображение
    GaussianBlur(Sprite, Sprite.Bounds, BlurSize + I div 3);
    // добавляем спрайт в словарь радиус->спрайт
    Sprites.Add(I, Sprite);
  end;

  // тип заставка
  (*
  if ExtractFileExt(ParamStr(0)).ToUpper = '.SCR' then
  begin
    BorderStyle := bsNone;
    WindowState := wsMaximized;
    FormStyle := fsStayOnTop;
  end;
  *)
end;

procedure TFormMain.FormDestroy(Sender: TObject);
var
  Sprite: TImage32;
begin
  for Sprite in Sprites.Values do
  begin
    Sprite.Free;
  end;
  Sprites.Free;
end;

procedure TFormMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  (*
  if IsScreensaver then
  begin
    Close;
  end;
  *)
end;

procedure TFormMain.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  (*
  if IsScreensaver then
  begin
    Close;
  end;
  *)
end;

procedure TFormMain.PaintBoxPaint(Sender: TObject);
var
  Image, Sprite: TImage32;
  I: Integer;
  CircleRect: TRect;
begin
  Image := TImage32.Create;
  try
    Image.SetSize(TPaintBox(Sender).Width, TPaintBox(Sender).Height);
    Image.Clear(Color32(255, 0, 0, 0));

    for I := 0 to High(Circles) do
    begin
      // извлекаем спрайт
      Sprite := Sprites[Circles[I].Radius];
      // перекрашиваем спрайт
      Sprite.SetRGB(Circles[I].Color);
      // рисуем
      CircleRect.Left := Trunc(Circles[I].X * Image.Width) - Sprite.Width div 2;
      CircleRect.Top := Trunc(Circles[I].Y * Image.Height) - Sprite.Height div 2;
      CircleRect.Width := Sprite.Width;
      CircleRect.Height := Sprite.Height;

      Image.CopyBlend(
        Sprite,
        Sprite.Bounds,
        CircleRect,
        BlendToAlpha
      );
    end;

    // копируем на экран
    Image.CopyToDc(TPaintBox(Sender).Canvas.Handle, 0, 0, False);
  finally
    Image.Free;
  end;
end;

procedure TFormMain.TimerTimer(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(Circles) do
  begin
    // X
    Circles[I].X := Circles[I].BaseX + (
      Sin(Circles[I].Time * 0.423 + Sin(Circles[I].Time * 0.1945)) +
      Sin(Circles[I].Time + Sin(Circles[I].Time * 0.32) + Sin(Circles[I].Time * 0.13))
    ) * 0.25;
    // Y
    Circles[I].Y := Circles[I].BaseY + (
      Sin(Circles[I].Time * 0.2637 + Sin(Circles[I].Time * 0.2456)) +
      Sin(Circles[I].Time * 0.39 + Sin(Circles[I].Time * 0.12) + Sin(Circles[I].Time * 0.43))
    ) * 0.25;
    // Color
    Circles[I].Color := MakeDarker(
      Circles[I].BaseColor,
      Trunc((Sin(Circles[I].Time * 2) + Sin(Circles[I].Time * 1.234)) * 20 + 40)
    );
    // Time
    Circles[I].Time := Circles[I].Time + Circles[I].TimeDelta;
  end;

  PaintBox.Invalidate;
end;

end.
