unit Raylib.Graphics;

{$i raylib.inc}

interface

uses
  RayLib,
  RayLib.System,
  RayLib.Collections;

var
  MatrixPushPop: Integer;
  MatrixCreated: Integer;
  MatrixDestroyed: Integer;
  FontsCreated: Integer;
  FontsDestroyed: Integer;
  BitmapsCreated: Integer;
  BitmapsDestroyed: Integer;

{ Forward declarations }

type
  IMatrix = interface;
  IBitmap = interface;
  IFont = interface;
  IPen = interface;
  IBrush = interface;
  ISolidBrush = interface;
  IGradientBrush = interface;
  ILinearGradientBrush = interface;
  IRadialGradientBrush = interface;
  IBitmapBrush = interface;
  ISprite = interface;
  ICanvas = interface;

{ Enumerations used by the interfaces above }

  TLineJoin = (joinMiter, joinBevel, joinRound);
  TLineCap = (capButt, capSquare, capRound);
  TFontAlign = (fontLeft, fontCenter, fontRight);
  TFontLayout = (fontTop, fontMiddle, fontBaseline, fontBottom);
  TWinding = (windCCW, windCW);

{ Remaking blend modes }

  TBlendMode = (blendAlpha, blendAdditive, blendSubtractive,
    blendLighten, blendDarken, blendInvert, blendNegative);

{ TColorB }

  TColorB = LongWord;

{ TColorF }

  TColorF = record
  public
    class operator Implicit(const Value: TColorB): TColorF;
    class operator Explicit(const Value: TColorF): TColorB;
    class operator Equal(const A, B: TColorF): Boolean; inline;
    class operator NotEqual(const A, B: TColorF): Boolean; inline;
  public
    R, G, B, A: Single;
    function Mix(const Color: TColorF; Percent: Single): TColorF;
    class function FromBytes(R, G, B: Byte; A: Byte = $FF): TColorF; static;
  end;
  PColorF = ^TColorF;

{ IDisposable }

  IDisposable = interface
  ['{860761FE-A458-4A49-BF54-8CFED22CDA46}']
    procedure Dispose;
  end;

{ IMatrix }

  IMatrix = interface
  ['{2F82AE30-10EB-40B5-87DD-C9124319B5CB}']
    procedure Copy(A, B, C, D, E, F: Single); overload;
    procedure Copy(M: IMatrix); overload;
    procedure Identity;
    function Inverse: IMatrix;
    procedure Translate(X, Y: Single);
    procedure Rotate(Angle: Single);
    procedure RotateAt(Angle, X, Y: Single);
    procedure Scale(SX, SY: Single);
    procedure ScaleAt(SX, SY, X, Y: Single);
    procedure SkewX(X: Single);
    procedure SkewY(Y: Single);
    procedure Transform(M: IMatrix);
    { Creates new matrix C using the formula:
      C = A * B
      A is this matrix, B is the matrix passed below, and C is the result }
    function Multiply(M: IMatrix): IMatrix; overload;
    { Creates a new point C using the formula:
      C = A * B
      A is this matrix, B is the point passed below, and C is the result }
    function Multiply(const P: TVec2): TVec2; overload;
    { Preserve the matrix state by pushing it onto a stack }
    procedure Push;
    { Restore the matrix state by popping it from a stack }
    procedure Pop;
  end;

{ IBitmap are fixed size bitmap instances can be created using any of the
  Canvas.LoadBitmap methods. They differ from IRenderBitmap in that they cannot
  be the target of canvas rendering and cannot be resized.

  Note: Bitmaps and share the same namespace as render bitmaps. }

  IBitmap = interface
  ['{2E0D937A-B9F9-4573-8E22-407BDBA2C587}']
    {$region property access methods}
    function GetName: string;
    function GetClientRect: TRect;
    function GetWidth: LongWord;
    function GetHeight: LongWord;
    {$endregion}
    { Name is defined when you load a bitmap from a canvas }
    property Name: string read GetName;
    { A convenient rectangle exactly fiting the bitmap }
    property ClientRect: TRect read GetClientRect;
    { The fixed width and height of the bitmap }
    property Width: LongWord read GetWidth;
    property Height: LongWord read GetHeight;
  end;

{ IRenderBitmap is a special bitmap which can be drawn to using canvas
  commands. When bound to a canvas commands such as LineTo, Circle, and Fill
  create graphics on the bitmap. When unbound the render bitmap can be used
  as with commands such as DrawImage or as a property of a bitmap brush.

  Note: A render bitmap can be created using the Canvas.NewBitmap method and
  share the same namespace as fixed bitmaps. }

  IRenderBitmap = interface(IBitmap)
  ['{C8850303-01D8-4BFD-AA68-20DBF90C430B}']
    { Bind makes the render bitmap the current target for canvas drawing }
    procedure Bind;
    { Unbind restores the back buffer as the target for canvas drawing }
    procedure Unbind;
    { If unbound resize the drawable area of this render bitmap }
    procedure Resize(W, H: LongWord);
  end;

{ IFont instances can be created by using Canvas.LoadFont methods. }

  IFont = interface
  ['{2DF60E11-7BEB-486E-B7DC-3714ED310B90}']
    {$region property access methods}
    function GetName: string;
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
    function GetSize: Single;
    procedure SetSize(Value: Single);
    function GetHeight: Single;
    procedure SetHeight(Value: Single);
    function GetAlign: TFontAlign;
    procedure SetAlign(const Value: TFontAlign);
    function GetLayout: TFontLayout;
    procedure SetLayout(const Value: TFontLayout);
    function GetBlur: Single;
    procedure SetBlur(Value: Single);
    function GetLetterSpacing: Single;
    procedure SetLetterSpacing(Value: Single);
    function GetLineSpacing: Single;
    procedure SetLineSpacing(Value: Single);
    {$endregion}
    { Name of the font }
    property Name: string read GetName;
    { Only solid color fonts are supported }
    property Color: TColorF read GetColor write SetColor;
    { Font size in pixels }
    property Size: Single read GetSize write SetSize;
    { Font height in points }
    property Height: Single read GetHeight write SetHeight;
    { Horizontal alignment of text rendered with this font }
    property Align: TFontAlign read GetAlign write SetAlign;
    { Vertical layout of text rendered with this font }
    property Layout: TFontLayout read GetLayout write SetLayout;
    { Font can be blurred which might be useful for soft font shadows }
    property Blur: Single read GetBlur write SetBlur;
    { Additive value used to modify letter spacing }
    property LetterSpacing: Single read GetLetterSpacing write SetLetterSpacing;
    { Multiplicative factor used to modify line spacing }
    property LineSpacing: Single read GetLineSpacing write SetLineSpacing;
  end;

{ IPen instances are used to stroke canvas paths.
  Note: Pens can reference a brush for more complex coloring options. }

  IPen = interface
  ['{3D67CC14-17DC-4653-B97A-02E00A16D431}']
    {$region property access methods}
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
    function GetBrush: IBrush;
    procedure SetBrush(Value: IBrush);
    function GetWidth: Single;
    procedure SetWidth(Value: Single);
    function GetMiterLimit: Single;
    procedure SetMiterLimit(Value: Single);
    function GetLineCap: TLineCap;
    procedure SetLineCap(const Value: TLineCap);
    function GetLineJoin: TLineJoin;
    procedure SetLineJoin(const Value: TLineJoin);
    {$endregion}
    property Color: TColorF read GetColor write SetColor;
    property Brush: IBrush read GetBrush write SetBrush;
    property Width: Single read GetWidth write SetWidth;
    property MiterLimit: Single read GetMiterLimit write SetMiterLimit;
    property LineCap: TLineCap read GetLineCap write SetLineCap;
    property LineJoin: TLineJoin read GetLineJoin write SetLineJoin;
  end;

{ IBrush is the base interface for the various brush types to follow }

  IBrush = interface
  ['{B7F6A0C7-EE64-4B97-96AF-74A5A5362486}']
  end;

{ ISolidBrush is a simple solid color brush }

  ISolidBrush = interface(IBrush)
  ['{35443F16-1FCD-490B-B2D0-5C17D6621953}']
    {$region property access methods}
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
    {$endregion}
    property Color: TColorF read GetColor write SetColor;
  end;

{ IGradientStop is used by gradient brushes }

  IGradientStop = interface
  ['{A44D2101-F2B4-4AC2-B346-CB2B7857CB13}']
    {$region property access methods}
    function GetOffset: Single;
    procedure SetOffset(Value: Single);
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
    {$endregion}
    property Offset: Single read GetOffset write SetOffset;
    property Color: TColorF read GetColor write SetColor;
  end;

{ IGradientBrush is the base interface for gradient brushes }

  IGradientBrush = interface(IBrush)
  ['{2EAF4D99-EFAC-47C9-AB45-C6C49ACAAF98}']
    {$region property access methods}
    function GetNearStop: IGradientStop;
    function GetFarStop: IGradientStop;
    {$endregion}
    property NearStop: IGradientStop read GetNearStop;
    property FarStop: IGradientStop read GetFarStop;
  end;

{ ILinearGradientBrush }

  ILinearGradientBrush = interface(IGradientBrush)
  ['{88232BE7-7B51-4E50-B71C-7EC2AD28AAA2}']
    {$region property access methods}
    function GetA: TVec2;
    procedure SetA(const Value: TVec2);
    function GetB: TVec2;
    procedure SetB(const Value: TVec2);
    {$endregion}
    property A: TVec2 read GetA write SetA;
    property B: TVec2 read GetB write SetB;
  end;

{ IRadialGradientBrush }

  IRadialGradientBrush = interface(IGradientBrush)
  ['{79C44874-B697-4C02-8E29-5D257828A590}']
    {$region property access methods}
    function GetRect: TRect;
    procedure SetRect(const Value: TRect);
    {$endregion}
    property Rect: TRect read GetRect write SetRect;
  end;

{ IBitmapBrush references a bitmap as a repeatable fill pattern. The pattern
  can be scaled along two axes, translated, rotated, and alpha blended.

  Note: GLES2 backend requires patterns to be a power of two or they will not
  wrap. }

  IBitmapBrush = interface(IBrush)
  ['{2EAF4D99-EFAC-47C9-AB45-C6C49ACAAF98}']
    {$region property access methods}
    function GetBitmap: IBitmap;
    procedure SetBitmap(Value: IBitmap);
    function GetAngle: Single;
    procedure SetAngle(Value: Single);
    function GetOffset: TVec2;
    procedure SetOffset(const Value: TVec2);
    function GetScale: TVec2;
    procedure SetScale(const Value: TVec2);
    function GetOpacity: Single;
    procedure SetOpacity(Value: Single);
    {$endregion}
    property Bitmap: IBitmap read GetBitmap write SetBitmap;
    property Angle: Single read GetAngle write SetAngle;
    property Offset: TVec2 read GetOffset write SetOffset;
    property Scale: TVec2 read GetScale write SetScale;
    property Opacity: Single read GetOpacity write SetOpacity;
  end;

{ ISprite }

  ISprite = interface
  ['{4B6882E6-F483-4D43-87EC-5F85C39FB228}']
    {$region property access methods}
    function GetBitmap: IBitmap;
    procedure SetBitmap(Value: IBitmap);
    function GetCols: Integer;
    procedure SetCols(Value: Integer);
    function GetRows: Integer;
    procedure SetRows(Value: Integer);
    function GetCell: Integer;
    procedure SetCell(Value: Integer);
    function GetPivot: TVec2;
    procedure SetPivot(Value: TVec2);
    function GetPosition: TVec2;
    procedure SetPosition(Value: TVec2);
    function GetRotation: Single;
    procedure SetRotation(Value: Single);
    function GetScale: TVec2;
    procedure SetScale(Value: TVec2);
    function GetOpacity: Single;
    procedure SetOpacity(Value: Single);
    {$endregion}
    { The sprite sheet }
    property Bitmap: IBitmap read GetBitmap write SetBitmap;
    { The number of columns left and right in the sprite sheet }
    property Cols: Integer read GetCols write SetCols;
    { The number of rows up and down in the sprite sheet }
    property Rows: Integer read GetRows write SetRows;
    { A zero based idnex of the current cell. Numbering starts at the top left,
      continuing right, then moving down to the next row. The total number of
      cells equals cols * rows. }
    property Cell: Integer read GetCell write SetCell;
    { A two compoent vector in the range of 0..1 that specifcies
      the position, rotation, and scale pivot. }
    property Pivot: TVec2 read GetPivot write SetPivot;
    { Position of the sprite in pixels }
    property Position: TVec2 read GetPosition write SetPosition;
    { Rotation Angle of the sprite in radians  }
    property Rotation: Single read GetRotation write SetRotation;
    { Scale of the sprite in both the x and y }
    property Scale: TVec2 read GetScale write SetScale;
    { Opacity of the sprite  in the range of 0..1 }
    property Opacity: Single read GetOpacity write SetOpacity;
  end;

{ IResourceStore is associated with a canvas, and allows for the creation and
  management of bitmap and font resources. Resoruces are tracked by name, and
  subsequent requests using the same name return an existing resource rather
  than loading the same resource mutliple times. }

  IResourceStore = interface
  ['{DEFA1507-0E3F-49C9-8E39-73F12A52560C}']
    {$region property access methods}
    function GetFontColor: TColorF;
    procedure SetFontColor(const Value: TColorF);
    {$endregion}
    { Create a new render bitmap, checking the store first if a render bitmap
      with a matching name already exists. }
    function NewBitmap(const Name: string; Width, Height: LongWord): IRenderBitmap;
    { Check the store if a image exists using name as a the key.
      If name is not found then nil is returned. }
    function LoadBitmap(const Name: string): IBitmap; overload;
    { Check the store if an image already exists. If not found load a new jpg, png,
      psd, tga, pic or gif image from a file or memory and associated it with the
      store using name as a key. }
    function LoadBitmap(const Name: string; const FileName: string): IBitmap; overload;
    function LoadBitmap(const Name: string; Memory: Pointer; Size: LongWord): IBitmap; overload;
    { Release space used by a bitmap and dispose of the underlying resources. }
    procedure DisposeBitmap(Bitmap: IBitmap);
    { Check the store if a font exists using name as a the key.
      If name is not found then nil is returned. }
    function LoadFont(const Name: string): IFont; overload;
    { Check the store if a font already exists. If not found load a new font from a file
      or memory and associated it with the store using name as a key }
    function LoadFont(const Name: string; const FileName: string): IFont; overload;
    function LoadFont(const Name: string; Memory: Pointer; Size: LongWord): IFont; overload;
    { The default color of a font when loaded }
    property FontColor: TColorF read GetFontColor write SetFontColor;
    { Note: It is an intentional design that fonts cannot be disposed }
  end;

{ ICanvas provides the main interface for generating vector graphics in this
  graphics unit. Canvas can be used to draw paths, images, and text. It has
  global properties for matrix transforms, blending, and alpha blending (aka
  Opacity), and methods for clipping and clearing content. }

  ICanvas = interface(IResourceStore)
  ['{352DAE63-6D1C-40E0-955E-87C27020CCE0}']
    {$region property access methods}
    function GetBlendMode: TBlendMode;
    procedure SetBlendMode(Value: TBlendMode);
    function GetOpacity: Single;
    procedure SetOpacity(Value: Single);
    function GetMatrix: IMatrix;
    procedure SetMatrix(Value: IMatrix);
    function GetWinding: TWinding;
    procedure SetWinding(const Value: TWinding);
    {$endregion}
    { Push all canvas state to the stack }
    procedure Push;
    { Pop canvas state from the stack }
    procedure Pop;
    { Clip drawing to a rectangle. You can use an empty rect to remove the
      clipping or combine mutliple calls to intersect the previous clipping
      regions }
    procedure Clip(const Rect: TRect); overload;
    { Shortcut to remove the clipping }
    procedure Clip; overload;
    { Clear all pixels in the current render or back buffer target. A render
      bitmap can be used with the canvas using its Bind and Unbind methods. }
    procedure Clear;
    { Measure a Single line of text }
    function MeasureText(Font: IFont; const Text: string): TVec2;
    { Measure a the height of multiple lines of text given a width }
    function MeasureMemo(Font: IFont; const Text: string; Width: Single): Single;
    { Render a Single line of text given a coordinate }
    procedure DrawText(Font: IFont; const Text: string; X, Y: Single);
    { Render a multiple lines of text given a width }
    procedure DrawTextMemo(Font: IFont; const Text: string; X, Y, Width: Single);
    { Raster image drawing }
    procedure DrawImage(Image: IBitmap; X, Y: Single; Opacity: Single = 1; Angle: Single = 0); overload;
    procedure DrawImage(Image: IBitmap; Source, Dest: TRect; Opacity: Single = 1; Angle: Single = 0); overload;
    procedure DrawSprite(Sprite: ISprite);
    { Discards the existing path and begins a new one }
    procedure BeginPath;
    { Closing the path creates a line from the last point to the first point in
      the path. It does not begin a new path. }
    procedure ClosePath;
    { These methods add geometry to the current path }
    procedure MoveTo(X, Y: Single);
    procedure LineTo(X, Y: Single);
    procedure ArcTo(X1, Y1, X2, Y2, Radius: Single);
    procedure BezierTo(CX1, CY1, CX2, CY2, X, Y: Single);
    procedure QuadTo(CX, CY, X, Y: Single);
    procedure Arc(CX, CY, Radius, A0, A1: Single; Clockwise: Boolean);
    procedure Circle(X, Y, Radius: Single); overload;
    procedure Ellipse(const R: TRect); overload;
    procedure Ellipse(X, Y, Width, Height: Single); overload;
    procedure Rect(const R: TRect); overload;
    procedure Rect(X, Y, Width, Height: Single); overload;
    procedure RoundRect(const R: TRect; Radius: Single); overload;
    procedure RoundRect(X, Y, Width, Height: Single; Radius: Single); overload;
    procedure Polygon(P: PVec2; Count: Integer; Closed: Boolean = True);
    { Radii are TL top left, TR top right, BR bottom right, and BL bottom left }
    procedure RoundRectVarying(const R: TRect; TL, TR, BR, BL: Single);
    { When preserve is false the current path is discarded and a new path begins }
    procedure Fill(Brush: IBrush; Preserve: Boolean = False); overload;
    procedure Fill(Color: TColorF; Preserve: Boolean = False); overload;
    procedure Stroke(Pen: IPen; Preserve: Boolean = False); overload;
    procedure Stroke(Color: TColorF; Width: Single = 1; Preserve: Boolean = False); overload;
    { Convenience methods that begin, paint, then discard a path }
    procedure FillCircle(Brush: IBrush; X, Y, Radius: Single);
    procedure StrokeCircle(Pen: IPen; X, Y, Radius: Single);
    procedure FillRect(Brush: IBrush; const R: TRect);
    procedure StrokeRect(Pen: IPen; const R: TRect);
    procedure FillRoundRect(Brush: IBrush; const R: TRect; Radius: Single);
    procedure StrokeRoundRect(Pen: IPen; const R: TRect; Radius: Single);
    { Global blending mode can be controlled using this property }
    property BlendMode: TBlendMode read GetBlendMode write SetBlendMode;
    { Global rendering opacity can be controlled using this property }
    property Opacity: Single read GetOpacity write SetOpacity;
    { Global rendering can be transformed using this property }
    property Matrix: IMatrix read GetMatrix write SetMatrix;
    { Counter clockwise creates solid shapes and clockwise creates shapes with holes. }
    property Winding: TWinding read GetWinding write SetWinding;
  end;

{ Do not use ICanvasFrame unless you are implementing a new windowing system
  to manage a GL context. }

  ICanvasFrame = interface
  ['{65B38056-5457-44B0-B10D-06F2AE95E73A}']
    procedure BeginFrame(W, H: Integer);
    procedure EndFrame;
  end;


function Clamp(A: Single): Single;

{ Routines to create objects used by canvas methods }

function NewColorB(R, G, B: Byte; A: Byte = $FF): TColorF; inline;
function NewColorF(R, G, B: Single; A: Single = 1): TColorF; inline;
function NewHSL(H, S, L: Single; A: Single = 1): TColorF; inline;
function NewPointF(X, Y: Single): TVec2; inline;
function NewRectF(Width, Height: Single): TRect; overload; inline;
function NewRectF(X, Y, Width, Height: Single): TRect; overload; inline;

function NewMatrix: IMatrix;
function NewPen: IPen; overload;
function NewPen(const Color: TColorF; Width: Single = 1; Cap: TLineCap = capButt): IPen; overload;
function NewBrush(const Color: TColorF): ISolidBrush; overload;
function NewBrush(const P0, P1: TVec2): ILinearGradientBrush; overload;
function NewBrush(const P0, P1: TVec2; C0, C1: TColorF): ILinearGradientBrush; overload;
function NewBrush(const Rect: TRect): IRadialGradientBrush; overload;
function NewBrush(const Rect: TRect; C0, C1: TColorF): IRadialGradientBrush; overload;
function NewBrush(Bitmap: IBitmap): IBitmapBrush; overload;
function NewSprite: ISprite;
function NewCanvas: ICanvas;

{ Useful constants }

const
  PointZero: TVec2 = (X: 0; Y: 0);
  RectEmpty: TRect = (X: 0; Y: 0; Width: 0; Height: 0);

{ Common colors }

  colorBlack                   = TColorB($FF000000);
  colorWhite                   = TColorB($FFFFFFFF);
  colorAliceBlue               = TColorB($FFF0F8FF);
  colorAntiqueWhite            = TColorB($FFFAEBD7);
  colorAqua                    = TColorB($FF00FFFF);
  colorAquamarine              = TColorB($FF7FFFD4);
  colorAzure                   = TColorB($FFF0FFFF);
  colorBeige                   = TColorB($FFF5F5DC);
  colorBisque                  = TColorB($FFFFE4C4);
  colorBlanchedAlmond          = TColorB($FFFFEBCD);
  colorBlue                    = TColorB($FF0000FF);
  colorBlueViolet              = TColorB($FF8A2BE2);
  colorBrown                   = TColorB($FF964B00);
  colorBurlyWood               = TColorB($FFDEB887);
  colorCadetBlue               = TColorB($FF5F9EA0);
  colorChartreuse              = TColorB($FF7FFF00);
  colorChocolate               = TColorB($FFD2691E);
  colorCoral                   = TColorB($FFFF7F50);
  colorCornflowerBlue          = TColorB($FF6495ED);
  colorCornsilk                = TColorB($FFFFF8DC);
  colorCrimson                 = TColorB($FFDC143C);
  colorCyan                    = TColorB($FF00FFFF);
  colorDarkBlue                = TColorB($FF00008B);
  colorDarkCyan                = TColorB($FF008B8B);
  colorDarkGoldenRod           = TColorB($FFB8860B);
  colorDarkGray                = TColorB($FFA9A9A9);
  colorDarkGrey                = TColorB($FFA9A9A9);
  colorDarkGreen               = TColorB($FF006400);
  colorDarkKhaki               = TColorB($FFBDB76B);
  colorDarkMagenta             = TColorB($FF8B008B);
  colorDarkOliveGreen          = TColorB($FF556B2F);
  colorDarkOrange              = TColorB($FFFF8C00);
  colorDarkOrchid              = TColorB($FF9932CC);
  colorDarkRed                 = TColorB($FF8B0000);
  colorDarkSalmon              = TColorB($FFE9967A);
  colorDarkSeaGreen            = TColorB($FF8FBC8F);
  colorDarkSlateBlue           = TColorB($FF483D8B);
  colorDarkSlateGray           = TColorB($FF2F4F4F);
  colorDarkSlateGrey           = TColorB($FF2F4F4F);
  colorDarkTurquoise           = TColorB($FF00CED1);
  colorDarkViolet              = TColorB($FF9400D3);
  colorDeepPink                = TColorB($FFFF1493);
  colorDeepSkyBlue             = TColorB($FF00BFFF);
  colorDimGray                 = TColorB($FF696969);
  colorDimGrey                 = TColorB($FF696969);
  colorDodgerBlue              = TColorB($FF1E90FF);
  colorFireBrick               = TColorB($FFB22222);
  colorFloralWhite             = TColorB($FFFFFAF0);
  colorForestGreen             = TColorB($FF228B22);
  colorFuchsia                 = TColorB($FFFF00FF);
  colorGainsboro               = TColorB($FFDCDCDC);
  colorGhostWhite              = TColorB($FFF8F8FF);
  colorGold                    = TColorB($FFFFD700);
  colorGoldenRod               = TColorB($FFDAA520);
  colorGray                    = TColorB($FF808080);
  colorGrey                    = TColorB($FF808080);
  colorGreen                   = TColorB($FF008000);
  colorGreenYellow             = TColorB($FFADFF2F);
  colorHoneyDew                = TColorB($FFF0FFF0);
  colorHotPink                 = TColorB($FFFF69B4);
  colorIndianRed               = TColorB($FFCD5C5C);
  colorIndigo                  = TColorB($FF4B0082);
  colorIvory                   = TColorB($FFFFFFF0);
  colorKhaki                   = TColorB($FFF0E68C);
  colorLavender                = TColorB($FFE6E6FA);
  colorLavenderBlush           = TColorB($FFFFF0F5);
  colorLawnGreen               = TColorB($FF7CFC00);
  colorLemonChiffon            = TColorB($FFFFFACD);
  colorLightBlue               = TColorB($FFADD8E6);
  colorLightCoral              = TColorB($FFF08080);
  colorLightCyan               = TColorB($FFE0FFFF);
  colorLightGoldenRodYellow    = TColorB($FFFAFAD2);
  colorLightGray               = TColorB($FFD3D3D3);
  colorLightGrey               = TColorB($FFD3D3D3);
  colorLightGreen              = TColorB($FF90EE90);
  colorLightPink               = TColorB($FFFFB6C1);
  colorLightSalmon             = TColorB($FFFFA07A);
  colorLightSeaGreen           = TColorB($FF20B2AA);
  colorLightSkyBlue            = TColorB($FF87CEFA);
  colorLightSlateGray          = TColorB($FF778899);
  colorLightSlateGrey          = TColorB($FF778899);
  colorLightSteelBlue          = TColorB($FFB0C4DE);
  colorLightYellow             = TColorB($FFFFFFE0);
  colorLime                    = TColorB($FF00FF00);
  colorLimeGreen               = TColorB($FF32CD32);
  colorLinen                   = TColorB($FFFAF0E6);
  colorMagenta                 = TColorB($FFFF00FF);
  colorMaroon                  = TColorB($FF800000);
  colorMediumAquaMarine        = TColorB($FF66CDAA);
  colorMediumBlue              = TColorB($FF0000CD);
  colorMediumOrchid            = TColorB($FFBA55D3);
  colorMediumPurple            = TColorB($FF9370DB);
  colorMediumSeaGreen          = TColorB($FF3CB371);
  colorMediumSlateBlue         = TColorB($FF7B68EE);
  colorMediumSpringGreen       = TColorB($FF00FA9A);
  colorMediumTurquoise         = TColorB($FF48D1CC);
  colorMediumVioletRed         = TColorB($FFC71585);
  colorMidnightBlue            = TColorB($FF191970);
  colorMintCream               = TColorB($FFF5FFFA);
  colorMistyRose               = TColorB($FFFFE4E1);
  colorMoccasin                = TColorB($FFFFE4B5);
  colorNavajoWhite             = TColorB($FFFFDEAD);
  colorNavy                    = TColorB($FF000080);
  colorOldLace                 = TColorB($FFFDF5E6);
  colorOlive                   = TColorB($FF808000);
  colorOliveDrab               = TColorB($FF6B8E23);
  colorOrange                  = TColorB($FFFFA500);
  colorOrangeRed               = TColorB($FFFF4500);
  colorOrchid                  = TColorB($FFDA70D6);
  colorPaleGoldenRod           = TColorB($FFEEE8AA);
  colorPaleGreen               = TColorB($FF98FB98);
  colorPaleTurquoise           = TColorB($FFAFEEEE);
  colorPaleVioletRed           = TColorB($FFDB7093);
  colorPapayaWhip              = TColorB($FFFFEFD5);
  colorPeachPuff               = TColorB($FFFFDAB9);
  colorPeru                    = TColorB($FFCD853F);
  colorPink                    = TColorB($FFFFC0CB);
  colorPlum                    = TColorB($FFDDA0DD);
  colorPowderBlue              = TColorB($FFB0E0E6);
  colorPurple                  = TColorB($FF800080);
  colorRebeccaPurple           = TColorB($FF663399);
  colorRed                     = TColorB($FFFF0000);
  colorRosyBrown               = TColorB($FFBC8F8F);
  colorRoyalBlue               = TColorB($FF4169E1);
  colorSaddleBrown             = TColorB($FF8B4513);
  colorSalmon                  = TColorB($FFFA8072);
  colorSandyBrown              = TColorB($FFF4A460);
  colorSeaGreen                = TColorB($FF2E8B57);
  colorSeaShell                = TColorB($FFFFF5EE);
  colorSienna                  = TColorB($FFA0522D);
  colorSilver                  = TColorB($FFC0C0C0);
  colorSkyBlue                 = TColorB($FF87CEEB);
  colorSlateBlue               = TColorB($FF6A5ACD);
  colorSlateGray               = TColorB($FF708090);
  colorSlateGrey               = TColorB($FF708090);
  colorSnow                    = TColorB($FFFFFAFA);
  colorSpringGreen             = TColorB($FF00FF7F);
  colorSteelBlue               = TColorB($FF4682B4);
  colorTan                     = TColorB($FFD2B48C);
  colorTeal                    = TColorB($FF008080);
  colorThistle                 = TColorB($FFD8BFD8);
  colorTomato                  = TColorB($FFFF6347);
  colorTurquoise               = TColorB($FF40E0D0);
  colorViolet                  = TColorB($FFEE82EE);
  colorWheat                   = TColorB($FFF5DEB3);
  colorWhiteSmoke              = TColorB($FFF5F5F5);
  colorYellow                  = TColorB($FFFFFF00);
  colorYellowGreen             = TColorB($FF9ACD32);

implementation

uses
  RayLib.NanoVG,
  RayLib.Gl;

const
  StackSize = 100;
{ Note: Repeat X and Y do not work with the GLESv2 path }

const
  NVG_IMAGE_DEFAULT = NVG_IMAGE_REPEATX or NVG_IMAGE_REPEATY;

{ TColorF }

class operator TColorF.Implicit(const Value: TColorB): TColorF;
begin
  Result.A := ((Value shr 24) and $FF) / $FF;
  Result.R := ((Value shr 16) and $FF) / $FF;
  Result.G := ((Value shr 8) and $FF) / $FF;
  Result.B := (Value and $FF) / $FF;
end;

class operator TColorF.Explicit(const Value: TColorF): TColorB;
var
  A, R, G, B: Byte;
begin
  A := Round(Value.A * $FF);
  R := Round(Value.R * $FF);
  G := Round(Value.G * $FF);
  B := Round(Value.B * $FF);
  Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

class operator TColorF.Equal(const A, B: TColorF): Boolean;
begin
  Result := (A.A = B.A) and (A.R = B.R) and (A.G = B.G) and (A.B = B.B);
end;

class operator TColorF.NotEqual(const A, B: TColorF): Boolean;
begin
  Result := (A.A <> B.A) or (A.R <> B.R) or (A.G <> B.G) or (A.B <> B.B);
end;

function TColorF.Mix(const Color: TColorF; Percent: Single): TColorF;
var
  C: Single;
begin
  C := 1 - Percent;
  Result.R := R * C + Color.R * Percent;
  Result.G := G * C + Color.G * Percent;
  Result.B := B * C + Color.B * Percent;
  Result.A := A * C + Color.A * Percent;
end;

class function TColorF.FromBytes(R, G, B: Byte; A: Byte = $FF): TColorF;
begin
  Result.R := R / $FF;
  Result.G := G / $FF;
  Result.B := B / $FF;
  Result.A := A / $FF;
end;

type
  TCanvas = class;

  TGraphicsObject = class(TInterfacedObject)
  public
    Changed: Boolean;
    function IsChanged: Boolean; virtual;
  end;

  TMatrix = class(TGraphicsObject, IMatrix)
  public
    Data: NVxform;
    Stack: IMatrix;
    constructor Create;
    destructor Destroy; override;
    procedure Copy(A, B, C, D, E, F: Single); overload;
    procedure Copy(M: IMatrix); overload;
    procedure Identity;
    function Inverse: IMatrix;
    procedure Translate(X, Y: Single);
    procedure Rotate(Angle: Single);
    procedure RotateAt(Angle, X, Y: Single);
    procedure Scale(SX, SY: Single);
    procedure ScaleAt(SX, SY, X, Y: Single);
    procedure SkewX(X: Single);
    procedure SkewY(Y: Single);
    procedure Transform(M: IMatrix);
    function Multiply(M: IMatrix): IMatrix; overload;
    function Multiply(const P: TVec2): TVec2; overload;
    procedure Push;
    procedure Pop;
  end;

  TBitmap = class(TGraphicsObject, IBitmap, INamed)
  public
    Id: Integer;
    Name: string;
    Width: LongWord;
    Height: LongWord;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetClientRect: TRect;
    function GetWidth: LongWord;
    function GetHeight: LongWord;
  end;

  TRenderBitmap = class(TGraphicsObject, IBitmap, IRenderBitmap, INamed)
  public
    Id: NVGLUframebuffer;
    Name: string;
    Width: LongWord;
    Height: LongWord;
    Canvas: TCanvas;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetClientRect: TRect;
    function GetWidth: LongWord;
    function GetHeight: LongWord;
    procedure Bind;
    procedure Unbind;
    procedure Resize(W, H: LongWord);
  end;

  TFont = class(TGraphicsObject, IFont, INamed)
  public
    Id: Integer;
    Name: string;
    Color: TColorF;
    Size: Single;
    Align: TFontAlign;
    Layout: TFontLayout;
    Blur: Single;
    LetterSpacing: Single;
    LineSpacing: Single;
    constructor Create;
    destructor Destroy; override;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
    function GetSize: Single;
    procedure SetSize(Value: Single);
    function GetHeight: Single;
    procedure SetHeight(Value: Single);
    function GetAlign: TFontAlign;
    procedure SetAlign(const Value: TFontAlign);
    function GetLayout: TFontLayout;
    procedure SetLayout(const Value: TFontLayout);
    function GetBlur: Single;
    procedure SetBlur(Value: Single);
    function GetLetterSpacing: Single;
    procedure SetLetterSpacing(Value: Single);
    function GetLineSpacing: Single;
    procedure SetLineSpacing(Value: Single);
  end;

  TPen = class(TGraphicsObject, IPen)
  public
    Color: TColorF;
    Brush: IBrush;
    Width: Single;
    MiterLimit: Single;
    LineCap: TLineCap;
    LineJoin: TLineJoin;
    constructor Create;
    function IsChanged: Boolean; override;
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
    function GetBrush: IBrush;
    procedure SetBrush(Value: IBrush);
    function GetWidth: Single;
    procedure SetWidth(Value: Single);
    function GetMiterLimit: Single;
    procedure SetMiterLimit(Value: Single);
    function GetLineCap: TLineCap;
    procedure SetLineCap(const Value: TLineCap);
    function GetLineJoin: TLineJoin;
    procedure SetLineJoin(const Value: TLineJoin);
  end;

  TBrush = class(TGraphicsObject, IBrush)
  end;

  TSolidBrush = class(TBrush, ISolidBrush)
  public
    Color: TColorF;
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
  end;

  TPaintBrush = class(TBrush)
  public
    Paint: NVGpaint;
    procedure Build(Ctx: NVGcontext); virtual; abstract;
  end;

  TGradientStop = class(TGraphicsObject, IGradientStop)
  public
    Offset: Single;
    Color: TColorF;
    constructor Create;
    function GetOffset: Single;
    procedure SetOffset(Value: Single);
    function GetColor: TColorF;
    procedure SetColor(const Value: TColorF);
  end;

  TGradientBrush = class(TPaintBrush, IGradientBrush)
  public
    NearStop: IGradientStop;
    FarStop: IGradientStop;
    constructor Create;
    function IsChanged: Boolean; override;
    function GetNearStop: IGradientStop;
    function GetFarStop: IGradientStop;
  end;

  TLinearGradientBrush = class(TGradientBrush, ILinearGradientBrush)
  public
    A: TVec2;
    B: TVec2;
    procedure Build(Ctx: NVGcontext); override;
    function GetA: TVec2;
    procedure SetA(const Value: TVec2);
    function GetB: TVec2;
    procedure SetB(const Value: TVec2);
  end;

  TRadialGradientBrush = class(TGradientBrush, IRadialGradientBrush)
  public
    Rect: TRect;
    procedure Build(Ctx: NVGcontext); override;
    function GetRect: TRect;
    procedure SetRect(const Value: TRect);
  end;

  TBitmapBrush = class(TPaintBrush, IBitmapBrush)
  public
    Bitmap: IBitmap;
    Angle: Single;
    Offset: TVec2;
    Scale: TVec2;
    Opacity: Single;
    constructor Create;
    procedure Build(Ctx: NVGcontext); override;
    function GetBitmap: IBitmap;
    procedure SetBitmap(Value: IBitmap);
    function GetAngle: Single;
    procedure SetAngle(Value: Single);
    function GetOffset: TVec2;
    procedure SetOffset(const Value: TVec2);
    function GetScale: TVec2;
    procedure SetScale(const Value: TVec2);
    function GetOpacity: Single;
    procedure SetOpacity(Value: Single);
  end;

  TSprite = class(TGraphicsObject, ISprite)
  public
    Bitmap: IBitmap;
    Cols: Integer;
    Rows: Integer;
    Cell: Integer;
    Pivot: TVec2;
    Position: TVec2;
    Rotation: Single;
    Scale: TVec2;
    Opacity: Single;
    constructor Create;
    function GetBitmap: IBitmap;
    procedure SetBitmap(Value: IBitmap);
    function GetCols: Integer;
    procedure SetCols(Value: Integer);
    function GetRows: Integer;
    procedure SetRows(Value: Integer);
    function GetCell: Integer;
    procedure SetCell(Value: Integer);
    function GetPivot: TVec2;
    procedure SetPivot(Value: TVec2);
    function GetPosition: TVec2;
    procedure SetPosition(Value: TVec2);
    function GetRotation: Single;
    procedure SetRotation(Value: Single);
    function GetScale: TVec2;
    procedure SetScale(Value: TVec2);
    function GetOpacity: Single;
    procedure SetOpacity(Value: Single);
  end;

  TCanvasStack = class
    BlendMode: TBlendMode;
    ClipRect: TRect;
    Opacity: Single;
    Winding: TWinding;
    Stack: TCanvasStack;
  end;

  TBitmaps = class(TNamedList<IBitmap>) end;
  TRenderBitmaps = class(TNamedList<IRenderBitmap>) end;
  TFonts = class(TNamedList<IFont>) end;

  TCanvas = class(TInterfacedObject, IResourceStore, ICanvas, ICanvasFrame, IDisposable)
  public
    Disposed: Boolean;
    Drawing: Boolean;
    Ctx: NVGcontext;
    Stack: TCanvasStack;
    Width, Height: Integer;
    DefaultFontColor: TColorF;
    Bitmaps: TBitmaps;
    RenderBitmaps: TRenderBitmaps;
    Fonts: TFonts;
    RenderBitmap: IRenderBitmap;
    SolidBrush: ISolidBrush;
    SolidPen: IPen;
    LastPen: IPen;
    LastBrush: IBrush;
    LastFont: IFont;
    ClipRect: TRect;
    BlendMode: TBlendMode;
    Opacity: Single;
    Winding: TWinding;
    Matrix: IMatrix;
    M: TMatrix;
    constructor Create;
    destructor Destroy; override;
    procedure CheckMatrix;
    procedure SelectObject(Pen: IPen); overload;
    procedure SelectObject(Brush: IBrush); overload;
    procedure SelectObject(Font: IFont); overload;
    { IDispose }
    procedure Dispose;
    { ICanvasFrame }
    procedure BeginFrame(W, H: Integer);
    procedure EndFrame;
    { IResourceStore }
    function GetFontColor: TColorF;
    procedure SetFontColor(const Value: TColorF);
    function NewBitmap(const Name: string; Width, Height: LongWord): IRenderBitmap; overload;
    function NewBitmap(Id: Integer; const Name: string): IBitmap; overload;
    procedure DisposeBitmap(Bitmap: IBitmap);
    function LoadBitmap(const Name: string): IBitmap; overload;
    function LoadBitmap(const Name: string; const FileName: string): IBitmap; overload;
    function LoadBitmap(const Name: string; Memory: Pointer; Size: LongWord): IBitmap; overload;
    function CloneFont(Font: IFont): IFont;
    function NewFont(Id: Integer; const Name: string): IFont;
    function LoadFont(const Name: string): IFont; overload;
    function LoadFont(const Name: string; const FileName: string): IFont; overload;
    function LoadFont(const Name: string; Memory: Pointer; Size: LongWord): IFont; overload;
    { ICanvas }
    procedure Push;
    procedure Pop;
    procedure Clip(const Rect: TRect); overload;
    procedure Clip; overload;
    procedure Clear;
    function MeasureText(Font: IFont; const Text: string): TVec2;
    function MeasureMemo(Font: IFont; const Text: string; Width: Single): Single;
    procedure DrawText(Font: IFont; const Text: string; X, Y: Single);
    procedure DrawTextMemo(Font: IFont; const Text: string; X, Y, Width: Single);
    procedure DrawImage(Image: IBitmap; X, Y: Single; Opacity: Single = 1; Angle: Single = 0); overload;
    procedure DrawImage(Image: IBitmap; Source, Dest: TRect; Opacity: Single = 1; Angle: Single = 0); overload;
    procedure DrawSprite(Sprite: ISprite);
    procedure BeginPath;
    procedure MoveTo(X, Y: Single);
    procedure LineTo(X, Y: Single);
    procedure ArcTo(X1, Y1, X2, Y2, Radius: Single);
    procedure BezierTo(CX1, CY1, CX2, CY2, X, Y: Single);
    procedure QuadTo(CX, CY, X, Y: Single);
    procedure Arc(CX, CY, Radius, A0, A1: Single; Clockwise: Boolean);
    procedure Circle(X, Y, Radius: Single);
    procedure Ellipse(const R: TRect); overload;
    procedure Ellipse(X, Y, Width, Height: Single); overload;
    procedure Rect(const R: TRect); overload;
    procedure Rect(X, Y, Width, Height: Single); overload;
    procedure RoundRect(const R: TRect; Radius: Single); overload;
    procedure RoundRect(X, Y, Width, Height: Single; Radius: Single); overload;
    procedure RoundRectVarying(const R: TRect; TL, TR, BR, BL: Single);
    procedure Polygon(P: PVec2; Count: Integer; Closed: Boolean = True);
    procedure ClosePath;
    procedure Fill(Brush: IBrush; Preserve: Boolean = False); overload;
    procedure Fill(Color: TColorF; Preserve: Boolean = False); overload;
    procedure Stroke(Pen: IPen; Preserve: Boolean = False); overload;
    procedure Stroke(Color: TColorF; Width: Single = 1; Preserve: Boolean = False); overload;
    procedure FillCircle(Brush: IBrush; X, Y, Radius: Single);
    procedure StrokeCircle(Pen: IPen; X, Y, Radius: Single);
    procedure FillRect(Brush: IBrush; const R: TRect);
    procedure StrokeRect(Pen: IPen; const R: TRect);
    procedure FillRoundRect(Brush: IBrush; const R: TRect; Radius: Single);
    procedure StrokeRoundRect(Pen: IPen; const R: TRect; Radius: Single);
    function GetGontext: Pointer;
    function GetBlendMode: TBlendMode;
    procedure SetBlendMode(Value: TBlendMode);
    function GetOpacity: Single;
    procedure SetOpacity(Value: Single);
    function GetMatrix: IMatrix;
    procedure SetMatrix(Value: IMatrix);
    function GetWinding: TWinding;
    procedure SetWinding(const Value: TWinding);
  end;

function IsBound(Bitmap: IBitmap): Boolean;
begin
  if Bitmap is IRenderBitmap then
    Result := (Bitmap as TRenderBitmap).Canvas.RenderBitmap = Bitmap as IRenderBitmap
  else
    Result := False;
end;

{ TGraphicsObject }

function TGraphicsObject.IsChanged: Boolean;
begin
  Result := Changed;
  Changed := False;
end;

{ TMatrix }

constructor TMatrix.Create;
begin
  inherited Create;
  Identity;
  Inc(MatrixCreated);
end;

destructor TMatrix.Destroy;
begin
  Inc(MatrixDestroyed);
  inherited Destroy;
end;

procedure TMatrix.Copy(A, B, C, D, E, F: Single);
begin
  Data[0] := A; Data[1] := B; Data[2] := C;
  Data[3] := D; Data[4] := E; Data[5] := F;
  Changed := True;
end;

procedure TMatrix.Copy(M: IMatrix);
var
  A: TMatrix;
begin
  A := M as TMatrix;
  if A = Self then
    Exit;
  Data := A.Data;
  Changed := True;
end;

procedure TMatrix.Identity;
begin
  nvgTransformIdentity(@Data);
  Changed := True;
end;

function TMatrix.Inverse: IMatrix;
var
  M: TMatrix;
begin
  Result := NewMatrix;
  M := Result as TMatrix;
  nvgTransformInverse(@M.Data, @Data);
end;

procedure TMatrix.Translate(X, Y: Single);
var
  M: NVxform;
begin
  nvgTransformTranslate(@M, X, Y);
  nvgTransformMultiply(@Data, M);
  Changed := True;
end;

procedure TMatrix.Rotate(Angle: Single);
var
  M: NVxform;
begin
  nvgTransformRotate(@M, Angle);
  nvgTransformMultiply(@Data, M);
  Changed := True;
end;

procedure TMatrix.RotateAt(Angle, X, Y: Single);
begin
  Translate(-X, -Y);
  Rotate(Angle);
  Translate(X, Y);
end;

procedure TMatrix.Scale(SX, SY: Single);
var
  M: NVxform;
begin
  nvgTransformScale(@M, SX, SY);
  nvgTransformMultiply(@Data, M);
  Changed := True;
end;

procedure TMatrix.ScaleAt(SX, SY, X, Y: Single);
begin
  Translate(-X, -Y);
  Scale(SX, SY);
  Translate(X, Y);
end;

procedure TMatrix.SkewX(X: Single);
var
  M: NVxform;
begin
  nvgTransformSkewX(@M, X);
  nvgTransformMultiply(@Data, M);
  Changed := True;
end;

procedure TMatrix.SkewY(Y: Single);
var
  M: NVxform;
begin
  nvgTransformSkewY(@M, Y);
  nvgTransformMultiply(@Data, M);
  Changed := True;
end;

procedure TMatrix.Transform(M: IMatrix);
var
  Mat: TMatrix;
begin
  Mat := M as TMatrix;
  nvgTransformMultiply(@Data, @Mat.Data);
  Changed := True;
end;

function TMatrix.Multiply(M: IMatrix): IMatrix;
var
  B: TMatrix;
  C: TMatrix;
begin
  B := M as TMatrix;
  Result := NewMatrix;
  C := Result as TMatrix;
  C.Data := Data;
  nvgTransformMultiply(@C.Data, @B.Data);
end;

function TMatrix.Multiply(const P: TVec2): TVec2;
begin
  nvgTransformPoint(Result.X, Result.Y, @Data, P.X, P.Y);
end;

procedure TMatrix.Push;
var
  S: IMatrix;
  M: TMatrix;
begin
  Inc(MatrixPushPop);
  S := NewMatrix;
  M := S as TMatrix;
  M.Data := Data;
  M.Stack := Stack;
  Stack := S;
end;

procedure TMatrix.Pop;
var
  S: IMatrix;
  M: TMatrix;
begin
  Dec(MatrixPushPop);
  S := Stack;
  if S = nil then
    Exit;
  M := S as TMatrix;
  Data := M.Data;
  Stack := M.Stack;
  Changed := True;
end;

{ TBitmap }

function TBitmap.GetName: string;
begin
  Result := Name;
end;

procedure TBitmap.SetName(const Value: string);
begin
  if Name = '' then
    Name := Value;
end;

function TBitmap.GetClientRect: TRect;
begin
  Result := {%H-}NewRectF(Width, Height);
end;

function TBitmap.GetWidth: LongWord;
begin
  Result := Width;
end;

function TBitmap.GetHeight: LongWord;
begin
  Result := Height;
end;

{ TRenderBitmap }

function TRenderBitmap.GetName: string;
begin
  Result := Name;
end;

procedure TRenderBitmap.SetName(const Value: string);
begin
  if Name = '' then
    Name := Value;
end;

function TRenderBitmap.GetClientRect: TRect;
begin
  Result := {%H-}NewRectF(Width, Height);
end;

function TRenderBitmap.GetWidth: LongWord;
begin
  Result := Width;
end;

function TRenderBitmap.GetHeight: LongWord;
begin
  Result := Height;
end;

procedure TRenderBitmap.Bind;
var
  C: TCanvas;
begin
  if IsBound(Self) then
    Exit;
  C := Canvas;
  if IsChanged then
  begin
    nvgluDeleteFramebuffer(Id);
    Id := nvgluCreateFramebuffer(C.Ctx, Width, Height, NVG_IMAGE_DEFAULT);
  end;
  nvgEndFrame(C.Ctx);
  nvgluBindFramebuffer(Id);
  glViewport(0, 0, Width, Height);
  nvgBeginFrame(C.Ctx, Width, Height, Width / Height);
  Canvas.Push;
  C.LastPen := nil;
  C.LastBrush := nil;
  C.LastFont := nil;
  C.RenderBitmap := Self;
end;

procedure TRenderBitmap.Unbind;
var
  Ctx: NVGcontext;
  C: TCanvas;
begin
  if not IsBound(Self) then
    Exit;
  Ctx := Canvas.Ctx;
  nvgEndFrame(Ctx);
  nvgluBindFramebuffer(nil);
  glViewport(0, 0, Canvas.Width, Canvas.Height);
  nvgBeginFrame(Ctx, Canvas.Width, Canvas.Height, Canvas.Width / Canvas.Height);
  nvgBeginPath(Ctx);
  Canvas.Pop;
  C := Canvas as TCanvas;
  C.LastPen := nil;
  C.LastBrush := nil;
  C.LastFont := nil;
  C.RenderBitmap := nil;
end;

procedure TRenderBitmap.Resize(W, H: LongWord);
begin
  if IsBound(Self) then
    Exit;
  if (W = Width) and (H = Height) then
    Exit;
  Width := W;
  Height := H;
  Changed := True;
end;

{ TFont }

constructor TFont.Create;
begin
  inherited Create;
  Inc(FontsCreated);
  Color := colorWhite;
  Size := 20;
  LetterSpacing := 0;
  LineSpacing := 1;
end;

destructor TFont.Destroy;
begin
  Inc(FontsDestroyed);
  inherited Destroy;
end;

function TFont.GetName: string;
begin
  Result := Name;
end;

procedure TFont.SetName(const Value: string);
begin
  if Name = '' then
    Name := Value;
end;

function TFont.GetColor: TColorF;
begin
  Result := Color;
end;

procedure TFont.SetColor(const Value: TColorF);
begin
  if Value = Color then Exit;
  Color := Value;
  Changed := True;
end;

function TFont.GetSize: Single;
begin
  Result := Size;
end;

procedure TFont.SetSize(Value: Single);
begin
  if Value < 0 then Value := 0;
  if Value = Size then Exit;
  Size := Value;
  Changed := True;
end;

function TFont.GetHeight: Single;
begin
  Result := Size / 96 * 72;
end;

procedure TFont.SetHeight(Value: Single);
begin
  Value := Value / 72 * 96;
  if Value = Size then Exit;
  Size := Value;
  Changed := True;
end;

function TFont.GetAlign: TFontAlign;
begin
  Result := Align;
end;

procedure TFont.SetAlign(const Value: TFontAlign);
begin
  if Value = Align then Exit;
  Align := Value;
  Changed := True;
end;

function TFont.GetLayout: TFontLayout;
begin
  Result := Layout;
end;

procedure TFont.SetLayout(const Value: TFontLayout);
begin
  if Value = Layout then Exit;
  Layout := Value;
  Changed := True;
end;

function TFont.GetBlur: Single;
begin
  Result := Blur;
end;

procedure TFont.SetBlur(Value: Single);
begin
  if Value < 0 then Value := 0;
  if Value = Blur then Exit;
  Blur := Value;
  Changed := True;
end;

function TFont.GetLetterSpacing: Single;
begin
  Result := LetterSpacing;
end;

procedure TFont.SetLetterSpacing(Value: Single);
begin
  if Value = LetterSpacing then Exit;
  LetterSpacing := Value;
  Changed := True;
end;

function TFont.GetLineSpacing: Single;
begin
  Result := LineSpacing;
end;

procedure TFont.SetLineSpacing(Value: Single);
begin
  if Value = LineSpacing then Exit;
  LineSpacing := Value;
  Changed := True;
end;

{ TPen }

constructor TPen.Create;
begin
  inherited Create;
  Color := colorBlack;
  Width := 1;
  MiterLimit := 10;
end;

function TPen.IsChanged: Boolean;
begin
  Result := inherited IsChanged;
  if (Brush <> nil) and (Brush as TBrush).IsChanged then
    Result := True;
end;

function TPen.GetColor: TColorF;
begin
  Result := Color;
end;

procedure TPen.SetColor(const Value: TColorF);
begin
  if Value = Color then Exit;
  Color := Value;
  Changed := True;
end;

function TPen.GetBrush: IBrush;
begin
  Result := Brush;
end;

procedure TPen.SetBrush(Value: IBrush);
begin
  if Value = Brush then Exit;
  Brush := Value;
  Changed := True;
end;

function TPen.GetWidth: Single;
begin
  Result := Width;
end;

procedure TPen.SetWidth(Value: Single);
begin
  if Value = Width then Exit;
  Width := Value;
  Changed := True;
end;

function TPen.GetMiterLimit: Single;
begin
  Result := MiterLimit;
end;

procedure TPen.SetMiterLimit(Value: Single);
begin
  if Value = MiterLimit then Exit;
  MiterLimit := Value;
  Changed := True;
end;

function TPen.GetLineCap: TLineCap;
begin
  Result := LineCap;
end;

procedure TPen.SetLineCap(const Value: TLineCap);
begin
  if Value = LineCap then Exit;
  LineCap := Value;
  Changed := True;
end;

function TPen.GetLineJoin: TLineJoin;
begin
  Result := LineJoin;
end;

procedure TPen.SetLineJoin(const Value: TLineJoin);
begin
  if Value = LineJoin then Exit;
  LineJoin := Value;
  Changed := True;
end;

{ TBrush }

function TSolidBrush.GetColor: TColorF;
begin
  Result := Color;
end;

procedure TSolidBrush.SetColor(const Value: TColorF);
begin
  if Value = Color then Exit;
  Color := Value;
  Changed := True;
end;

{ TGradientStop }

constructor TGradientStop.Create;
begin
  inherited Create;
  Color := colorBlack;
  Changed := True;
end;

function TGradientStop.GetOffset: Single;
begin
  Result := Offset;
end;

procedure TGradientStop.SetOffset(Value: Single);
begin
  if Value = Offset then Exit;
  Offset := Value;
  Changed := True;
end;

function TGradientStop.GetColor: TColorF;
begin
  Result := Color;
end;

procedure TGradientStop.SetColor(const Value: TColorF);
begin
  if Value = Color then Exit;
  Color := Value;
  Changed := True;
end;

{ TGradientBrush }

constructor TGradientBrush.Create;
begin
  inherited Create;
  NearStop := TGradientStop.Create;
  FarStop := TGradientStop.Create;
  FarStop.Offset := 1;
  FarStop.Color := colorWhite;
end;

function TGradientBrush.IsChanged: Boolean;
begin
  Result := inherited IsChanged;
  if (NearStop as TGradientStop).IsChanged then
    Result := True;
  if (FarStop as TGradientStop).IsChanged then
    Result := True;
end;

function TGradientBrush.GetNearStop: IGradientStop;
begin
  Result := NearStop;
end;

function TGradientBrush.GetFarStop: IGradientStop;
begin
  Result := FarStop;
end;

{ TLinearGradientBrush }

procedure TLinearGradientBrush.Build(Ctx: NVGcontext);
var
  C, D: TVec2;
begin
  C := A.Mix(B, NearStop.Offset);
  D := A.Mix(B, FarStop.Offset);
  Paint := nvgLinearGradient(Ctx, C.X, C.Y, D.X, D.Y, NVGcolor(NearStop.Color), NVGcolor(FarStop.Color));
end;

function TLinearGradientBrush.GetA: TVec2;
begin
  Result := A;
end;

procedure TLinearGradientBrush.SetA(const Value: TVec2);
begin
  A := Value;
  Changed := True;
end;

function TLinearGradientBrush.GetB: TVec2;
begin
  Result := B;
end;

procedure TLinearGradientBrush.SetB(const Value: TVec2);
begin
  B := Value;
  Changed := True;
end;

{ TRadialGradientBrush }

procedure TRadialGradientBrush.Build(Ctx: NVGcontext);
var
  R: Single;
begin
  R := Rect.Width;
  if Rect.Height < R then
    R := Rect.Height;
  Paint := nvgRadialGradient(Ctx, Rect.X + Rect.Width / 2, Rect.Y + Rect.Height / 2,
    R * NearStop.Offset, R * FarStop.Offset, NVGcolor(NearStop.Color), NVGcolor(FarStop.Color));
end;

function TRadialGradientBrush.GetRect: TRect;
begin
  Result := Rect;
end;

procedure TRadialGradientBrush.SetRect(const Value: TRect);
begin
  Rect := Value;
  Changed := True;
end;

{ TBitmapBrush }

constructor TBitmapBrush.Create;
begin
  inherited Create;
  Scale := {%H-}NewPointF(1, 1);
  Opacity := 1;
end;

function GetBitmapId(Bitmap: IBitmap): Integer;
var
  A: TBitmap;
  B: TRenderBitmap;
begin
  if Bitmap is TBitmap then
  begin
    A := Bitmap as TBitmap;
    Result := A.Id;
  end
  else
  begin
    B := Bitmap as TRenderBitmap;
    Result := B.Id.image;
  end;
end;

procedure TBitmapBrush.Build(Ctx: NVGcontext);
var
  Id: Integer;
begin
  Id := GetBitmapId(Bitmap);
  if (Id < 0) or IsBound(Bitmap) then
  begin
    Paint := nvgLinearGradient(Ctx, 0, 0, 10, 10, nvgRGB(0, 0, 0), nvgRGB(0, 0, 0));
    Changed := True;
  end
  else
    Paint := nvgImagePattern(Ctx, Offset.X, Offset.Y, Bitmap.Width * Scale.X,
      Bitmap.Height * Scale.Y, Angle, Id, Opacity);
end;

function TBitmapBrush.GetBitmap: IBitmap;
begin
  Result := Bitmap;
end;

procedure TBitmapBrush.SetBitmap(Value: IBitmap);
begin
  if Value = Bitmap then Exit;
  Bitmap := Value;
  Changed := True;
end;

function TBitmapBrush.GetAngle: Single;
begin
  Result := Angle;
end;

procedure TBitmapBrush.SetAngle(Value: Single);
begin
  if Value = Angle then Exit;
  Angle := Value;
  Changed := True;
end;

function TBitmapBrush.GetOffset: TVec2;
begin
  Result := Offset;
end;

procedure TBitmapBrush.SetOffset(const Value: TVec2);
begin
  Offset := Value;
  Changed := True;
end;

function TBitmapBrush.GetScale: TVec2;
begin
  Result := Scale;
end;

procedure TBitmapBrush.SetScale(const Value: TVec2);
begin
  Scale := Value;
  Changed := True;
end;

function TBitmapBrush.GetOpacity: Single;
begin
  Result := Opacity;
end;

procedure TBitmapBrush.SetOpacity(Value: Single);
begin
  if Value = Opacity then Exit;
  Opacity := Value;
  Changed := True;
end;

{ TSprite }

constructor TSprite.Create;
begin
  inherited Create;
  Cols := 1;
  Rows := 1;
  Pivot := Vec(0.5, 0.5);
  Scale := Vec(1, 1);
  Opacity := 1;
end;

function TSprite.GetBitmap: IBitmap;
begin
  Result := Bitmap;
end;

procedure TSprite.SetBitmap(Value: IBitmap);
begin
  if Value = Bitmap then Exit;
  Bitmap := Value;
end;

function TSprite.GetCols: Integer;
begin
  Result := Cols;
end;

procedure TSprite.SetCols(Value: Integer);
begin
  if Value < 0 then Value := 1;
  Cols := Value;
end;

function TSprite.GetRows: Integer;
begin
  Result := Rows;
end;

procedure TSprite.SetRows(Value: Integer);
begin
  if Value < 0 then Value := 1;
  Rows := Value;
end;

function TSprite.GetCell: Integer;
begin
  Result := Cell;
end;

procedure TSprite.SetCell(Value: Integer);
begin
  if Value < 0 then Value := 0;
  Cell := Value;
end;

function TSprite.GetPivot: TVec2;
begin
  Result := Pivot;
end;

procedure TSprite.SetPivot(Value: TVec2);
begin
  Value.x := Clamp(Value.x);
  Value.y := Clamp(Value.y);
  Pivot := Value;
end;

function TSprite.GetPosition: TVec2;
begin
  Result := Position;
end;

procedure TSprite.SetPosition(Value: TVec2);
begin
  Position := Value;
end;

function TSprite.GetRotation: Single;
begin
  Result := Rotation;
end;

procedure TSprite.SetRotation(Value: Single);
begin
  Rotation := Value;
end;

function TSprite.GetScale: TVec2;
begin
  Result := Scale;
end;

procedure TSprite.SetScale(Value: TVec2);
begin
  Scale := Value;
end;

function TSprite.GetOpacity: Single;
begin
  Result := Opacity;
end;

procedure TSprite.SetOpacity(Value: Single);
begin
  Value := Clamp(Value);
  Opacity := Value;
end;

{ TCanvas }

constructor TCanvas.Create;
begin
  inherited Create;
  {$ifdef gl2}
  Ctx := nvgCreateGL2(NVG_ANTIALIAS or NVG_STENCIL_STROKES);
  {$else}
  Ctx := nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES);
  {$endif}
  Opacity := 1;
  Matrix := NewMatrix;
  M := Matrix as TMatrix;
  nvgPathWinding(Ctx, NVG_CCW);
  DefaultFontColor := colorBlack;
  SolidBrush := NewBrush(colorBlack);
  SolidPen := NewPen(colorBlack, 1);
  Bitmaps := TBitmaps.Create;
  RenderBitmaps := TRenderBitmaps.Create;
  Fonts := TFonts.Create;
end;

procedure TCanvas.Dispose;
var
  A: IBitmap;
  B: IRenderBitmap;
begin
  if Disposed then
    Exit;
  Disposed := True;
  LastBrush := nil;
  LastPen := nil;
  LastFont := nil;
  SolidBrush := nil;
  SolidPen := nil;
  if RenderBitmap <> nil then
    RenderBitmap.Unbind;
  RenderBitmap := nil;
  for A in Bitmaps do
    nvgDeleteImage(Ctx, (A as TBitmap).Id);
  for B in RenderBitmaps do
    nvgluDeleteFramebuffer((B as TRenderBitmap).Id);
  Bitmaps.Free;
  RenderBitmaps.Free;
  Fonts.Free;
  {$ifdef gl2}
  nvgDeleteGL2(Ctx);
  {$else}
  nvgDeleteGL3(Ctx);
  {$endif}
end;

destructor TCanvas.Destroy;
begin
  Dispose;
  inherited Destroy;
end;

procedure TCanvas.CheckMatrix;
begin
  if M.Changed then
  begin
    nvgResetTransform(Ctx);
    nvgTransform(Ctx, M.Data[0], M.Data[1], M.Data[2], M.Data[3], M.Data[4], M.Data[5]);
    M.Changed := False;
  end;
end;

procedure TCanvas.SelectObject(Brush: IBrush);
var
  HasChanged: Boolean;
  Paint: TPaintBrush;
  B: TBrush;
  C: TColorF;
begin
  HasChanged := Brush <> LastBrush;
  LastBrush := Brush;
  B := Brush as TBrush;
  if B.IsChanged then
    HasChanged := True;
  if not HasChanged then
    Exit;
  if B is TSolidBrush then
  begin
    C := (B as TSolidBrush).Color;
    nvgFillColor(Ctx, NVGcolor(C));
  end
  else
  begin
    Paint := B as TPaintBrush;
    Paint.Build(Ctx);
    nvgFillPaint(Ctx, NVGpaint(Paint.Paint));
  end;
end;

procedure TCanvas.SelectObject(Pen: IPen);
const
  Caps: array[TLineCap] of NVGlineCapJoin = (NVG_BUTT, NVG_SQUARE, NVG_ROUND);
  Joins: array[TLineJoin] of NVGlineCapJoin = (NVG_MITER, NVG_BEVEL, NVG_ROUND);
var
  HasChanged: Boolean;
  Paint: TPaintBrush;
  P: TPen;
begin
  HasChanged := Pen <> LastPen;
  LastPen := Pen;
  P := Pen as TPen;
  if P.IsChanged then
    HasChanged := True;
  if not HasChanged then
    Exit;
  nvgStrokeWidth(Ctx, P.Width);
  nvgLineCap(Ctx, Caps[P.LineCap]);
  nvgLineJoin(Ctx, Joins[P.LineJoin]);
  nvgMiterLimit(Ctx, P.MiterLimit);
  if P.Brush = nil then
    nvgStrokeColor(Ctx, NVGcolor(P.Color))
  else if P.Brush is TSolidBrush then
    nvgStrokeColor(Ctx, NVGcolor((P.Brush as TSolidBrush).Color))
  else
  begin
    Paint := P.Brush as TPaintBrush;
    Paint.Build(Ctx);
    nvgStrokePaint(Ctx, NVGpaint(Paint.Paint));
  end;
end;

procedure TCanvas.SelectObject(Font: IFont);
const
  Aligns: array[TFontAlign] of NVGalign = (NVG_ALIGN_LEFT, NVG_ALIGN_CENTER,
    NVG_ALIGN_RIGHT);
  Layouts: array[TFontLayout] of NVGalign = (NVG_ALIGN_TOP, NVG_ALIGN_MIDDLE,
    NVG_ALIGN_BOTTOM, NVG_ALIGN_BASELINE);
var
  HasChanged: Boolean;
  F: TFont;
begin
  HasChanged := LastFont <> Font;
  LastFont := Font;
  F := Font as TFont;
  if F.IsChanged then
    HasChanged := True;
  if not HasChanged then
    Exit;
  nvgFontFaceId(Ctx, F.Id);
  nvgFontSize(Ctx, F.Size);
  nvgFontBlur(Ctx, F.Blur);
  nvgTextLetterSpacing(Ctx, F.LetterSpacing);
  nvgTextLineHeight(Ctx, F.LineSpacing);
  nvgTextAlign(Ctx, Aligns[F.Align] or Layouts[F.Layout]);
end;

procedure TCanvas.BeginFrame(W, H: Integer);
begin
  if Drawing then
    Exit;
  Drawing := True;
  nvgBeginFrame(Ctx, W, H, 1);
  nvgBeginPath(Ctx);
  Width := W;
  Height := H;
end;

procedure TCanvas.EndFrame;
begin
  if not Drawing then
    Exit;
  Drawing := False;
  if RenderBitmap <> nil then
    RenderBitmap.Unbind;
  nvgEndFrame(Ctx);
  LastPen := nil;
  LastBrush := nil;
  LastFont := nil;
  Opacity := 1;
  BlendMode := blendAlpha;
  M.Identity;
  M.Changed := False;
end;

{ IResourceStore }

function AdjustPathDelimiter(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  {$ifdef linux}
  for I := 1 to Length(Result) do
    if Result[I] = '\' then Result[I] := '/';
  {$else}
  for I := 1 to Length(S) do
    if Result[I] = '/' then Result[I] := '\';
  {$endif}
end;

function TCanvas.GetFontColor: TColorF;
begin
  Result := DefaultFontColor;
end;

procedure TCanvas.SetFontColor(const Value: TColorF);
begin
  DefaultFontColor := Value;
end;

function TCanvas.NewBitmap(const Name: string; Width, Height: LongWord): IRenderBitmap;
var
  Bitmap: IBitmap;
  R: TRenderBitmap;
begin
  Result := nil;
  if Name = '' then
    Exit;
  Bitmap := LoadBitmap(Name);
  if Bitmap <> nil then
  begin
    if Bitmap is IRenderBitmap then
    begin
      Result := Bitmap as IRenderBitmap;
      Result.Resize(Width, Height);
    end;
    Exit;
  end;
  Result := TRenderBitmap.Create;
  R := Result as TRenderBitmap;
  R.Id := nvgluCreateFramebuffer(Ctx, Width, Height, NVG_IMAGE_DEFAULT);
  R.Width := Width;
  R.Height := Height;
  R.Canvas := Self;
  R.Changed := False;
  RenderBitmaps.AddName(Name, Result);
end;

function TCanvas.NewBitmap(Id: Integer; const Name: string): IBitmap;
var
  R: TBitmap;
begin
  Result := nil;
  if Name = '' then
    Exit;
  Result := TBitmap.Create;
  R := Result as TBitmap;
  R.Id := Id;
  nvgImageSize(Ctx, R.Id, R.Width, R.Height);
  Bitmaps.AddName(Name, Result);
end;

function TCanvas.LoadBitmap(const Name: string): IBitmap;
var
  A: IBitmap;
  B: IRenderBitmap;
  S: string;
begin
  Result := nil;
  if Name = '' then
    Exit;
  A := Bitmaps.FindName(Name);
  if A <> nil then
    Exit(A);
  B := RenderBitmaps.FindName(Name);
  if B <> nil then
    Result := B as IBitmap;
  if (Result = nil) then
  begin
    S := AdjustPathDelimiter(Name);
    if FileExists(S) then
      Result := NewBitmap(nvgCreateImage(Ctx, PChar(S), NVG_IMAGE_DEFAULT), Name);
  end;
end;

function TCanvas.LoadBitmap(const Name: string; const FileName: string): IBitmap; overload;
var
  A: IBitmap;
  B: IRenderBitmap;
  S: string;
begin
  Result := nil;
  if Name = '' then
    Exit;
  A := Bitmaps.FindName(Name);
  if A <> nil then
    Exit(A);
  B := RenderBitmaps.FindName(Name);
  if B <> nil then
    Result := B as IBitmap;
  if Result = nil then
  begin
    S := AdjustPathDelimiter(FileName);
    Result := NewBitmap(nvgCreateImage(Ctx, PChar(S), NVG_IMAGE_DEFAULT), Name);
  end;
end;

function TCanvas.LoadBitmap(const Name: string; Memory: Pointer; Size: LongWord): IBitmap; overload;
var
  A: IBitmap;
  B: IRenderBitmap;
begin
  Result := nil;
  if Name = '' then
    Exit;
  A := Bitmaps.FindName(Name);
  if A <> nil then
    Exit(A);
  B := RenderBitmaps.FindName(Name);
  if B <> nil then
    Result := B as IBitmap;
  if Result = nil then
    Result := NewBitmap(nvgCreateImageMem(Ctx, NVG_IMAGE_DEFAULT, Memory, Size), Name);
end;

procedure TCanvas.DisposeBitmap(Bitmap: IBitmap);
begin
  if Bitmap is IRenderBitmap then
  begin
    nvgluDeleteFramebuffer((Bitmap as TRenderBitmap).Id);
    RenderBitmaps.RemoveName(Bitmap.Name)
  end
  else
  begin
    nvgDeleteImage(Ctx, (Bitmap as TBitmap).Id);
    Bitmaps.RemoveName(Bitmap.Name);
  end;
end;

function TCanvas.CloneFont(Font: IFont): IFont;
var
  A, B: TFont;
begin
  Result := TFont.Create;
  A := Result as TFont;
  B := Font as TFont;
  A.Id := B.Id;
  A.Name := B.Name;
  A.Size := B.Size;
  A.Align := B.Align;
  A.Layout := B.Layout;
  A.Blur := B.Blur;
  A.LetterSpacing := B.LetterSpacing;
  A.LineSpacing := B.LineSpacing;
  A.Color := DefaultFontColor;
end;

function TCanvas.NewFont(Id: Integer; const Name: string): IFont;
var
  F: TFont;
begin
  Result := TFont.Create;
  F := Result as TFont;
  F.Id := Id;
  Fonts.AddName(Name, Result);
  Result := CloneFont(Result);
end;

function TCanvas.LoadFont(const Name: string): IFont; overload;
var
  F: IFont;
  S: string;
begin
  Result := nil;
  if Name = '' then
    Exit;
  F := Fonts.FindName(Name);
  if F = nil then
  begin
    S := AdjustPathDelimiter(Name);
    F := NewFont(nvgCreateFont(Ctx, PChar(Name), PChar(S)), Name);
  end;
  Result := CloneFont(F);
end;

function TCanvas.LoadFont(const Name: string; const FileName: string): IFont; overload;
var
  F: IFont;
  S: string;
begin
  Result := nil;
  if Name = '' then
    Exit;
  F := Fonts.FindName(Name);
  if F = nil then
  begin
    S := AdjustPathDelimiter(FileName);
    F := NewFont(nvgCreateFont(Ctx, PChar(Name), PChar(S)), Name);
  end;
  Result := CloneFont(F);
end;

function TCanvas.LoadFont(const Name: string; Memory: Pointer; Size: LongWord): IFont; overload;
var
  F: IFont;
begin
  Result := nil;
  if Name = '' then
    Exit;
  F := Fonts.FindName(Name);
  if F = nil then
    F := NewFont(nvgCreateFontMem(Ctx, PChar(Name), Memory, Size, 0), Name);
  Result := CloneFont(F);
end;

{ ICanvas }

procedure TCanvas.Push;
var
  S: TCanvasStack;
begin
  Matrix.Push;
  S := TCanvasStack.Create;
  S.BlendMode := BlendMode;
  S.ClipRect := ClipRect;
  S.Opacity := Opacity;
  S.Winding := Winding;
  S.Stack := Stack;
  Stack := S;
  BeginPath;
end;

procedure TCanvas.Pop;
var
  C: ICanvas;
  S: TCanvasStack;
begin
  if Stack = nil then
    Exit;
  Matrix.Pop;
  C := Self;
  S := Stack;
  C.BlendMode := S.BlendMode;
  C.Clip;
  C.Clip(S.ClipRect);
  C.Opacity := S.Opacity;
  C.Winding := S.Winding;
  Stack := S.Stack;
  S.Free;
  BeginPath;
end;

procedure TCanvas.Clip(const Rect: TRect); overload;
begin
  if Rect.IsEmpty then
    nvgResetScissor(Ctx)
  else if ClipRect.IsEmpty then
    nvgScissor(Ctx, Rect.X, Rect.Y, Rect.Width, Rect.Height)
  else
    nvgIntersectScissor(Ctx, Rect.X, Rect.Y, Rect.Width, Rect.Height);
  ClipRect := Rect;
end;

procedure TCanvas.Clip; overload;
begin
  if ClipRect.IsEmpty then
    nvgResetScissor(Ctx);
  ClipRect := RectEmpty;
end;

procedure TCanvas.Clear;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
end;

function TCanvas.MeasureText(Font: IFont; const Text: string): TVec2;
var
  Bounds: array[0..4] of Single;
  S: string;
  I: Integer;
begin
  Result := PointZero;
  if Text = '' then
    Exit;
  CheckMatrix;
  { Needed for some reason font changed isn't being handled correctly. I will
    track down the issue later }
  LastFont := nil;
  SelectObject(Font);
  S := Text;
  for I := 1 to Length(S) do
    if S[I] = ' ' then
      S[I] := '[';
  nvgTextBounds(Ctx, 0, 0, PChar(S), nil, @Bounds);
  Result.X := Bounds[2] - Bounds[0];
  Result.Y := Bounds[3] - Bounds[1];
end;

function TCanvas.MeasureMemo(Font: IFont; const Text: string; Width: Single): Single;
var
  Bounds: array[0..4] of Single;
begin
  Result := 0;
  if Text = '' then
    Exit;
  CheckMatrix;
  { Needed for some reason font changed isn't being handled correctly. I will
    track down the issue later }
  LastFont := nil;
  SelectObject(Font);
  nvgTextBoxBounds(Ctx, 0, 0, Width, PChar(Text), nil, @Bounds);
  Result := Bounds[3] - Bounds[1];
end;

procedure TCanvas.DrawText(Font: IFont; const Text: string; X, Y: Single);
begin
  if Text = '' then
    Exit;
  CheckMatrix;
  SelectObject(Font);
  nvgFillColor(Ctx,  NVGcolor(Font.Color));
  nvgText(Ctx, X, Y, PChar(Text), nil);
  nvgBeginPath(Ctx);
  LastBrush := nil;
  LastPen := nil;
end;

procedure TCanvas.DrawTextMemo(Font: IFont; const Text: string; X, Y, Width: Single);
begin
  if Text = '' then
    Exit;
  CheckMatrix;
  SelectObject(Font);
  nvgFillColor(Ctx, NVGcolor(Font.Color));
  nvgTextBox(Ctx, X, Y, Width, PChar(Text), nil);
  nvgBeginPath(Ctx);
  LastBrush := nil;
  LastPen := nil;
end;

procedure TCanvas.DrawImage(Image: IBitmap; X, Y: Single; Opacity: Single = 1; Angle: Single = 0);
var
  Paint: NVGpaint;
  Id: Integer;
begin
  Id := GetBitmapId(Image);
  if (Id < 0) or IsBound(Image) then Exit;
  CheckMatrix;
  nvgBeginPath(Ctx);
  nvgRect(Ctx, X, Y, Image.Width, Image.Height);
  Paint := nvgImagePattern(Ctx, X, Y, Image.Width, Image.Height, Angle, Id, Opacity);
  nvgFillPaint(Ctx, Paint);
  nvgFill(Ctx);
  nvgBeginPath(Ctx);
  LastBrush := nil;
end;

procedure TCanvas.DrawImage(Image: IBitmap; Source, Dest: TRect; Opacity: Single = 1; Angle: Single = 0);
var
  Paint: NVGpaint;
  SX, SY: Single;
  FlipX, FlipY: Integer;
  Id: Integer;
begin
  if Source.IsEmpty or Dest.IsEmpty then
    Exit;
  Id := GetBitmapId(Image);
  if (Id < 0) or IsBound(Image) then Exit;
  CheckMatrix;
  nvgBeginPath(Ctx);
  if Dest.Width < 0 then FlipX := -1 else FlipX := 1;
  if Dest.Height < 0 then FlipY := -1 else FlipY := 1;
  Dest.Width := Dest.Width * FlipX;
  Dest.Height := Dest.Height * FlipY;
  nvgRect(Ctx, Dest.X, Dest.Y, Dest.Width, Dest.Height);
  SX := Dest.Width / Source.Width;
  SY := Dest.Height / Source.Height;
  Paint := nvgImagePattern(Ctx, Dest.X - Source.X * SX, Dest.Y - Source.Y * SY,
    Image.Width * SX * FlipX, Image.Height * SY * FlipY, Angle, Id, Opacity);
  nvgFillPaint(Ctx, Paint);
  nvgFill(Ctx);
  nvgBeginPath(Ctx);
  LastBrush := nil;
end;

procedure TCanvas.DrawSprite(Sprite: ISprite);
var
  W, H: Integer;
  P, F: TVec2;
  S, D: TRect;
begin
  if Sprite.Bitmap = nil then
    Exit;
  if Sprite.Opacity = 0 then
    Exit;
  W := Sprite.Bitmap.Width;
  H := Sprite.Bitmap.Height;
  S := Sprite.Bitmap.ClientRect;
  S.width := S.width / Sprite.Cols;
  S.height := S.height / Sprite.Rows;
  F := Sprite.Scale;
  P.x := S.width * Sprite.Pivot.x * Abs(F.x);
  P.y := S.height * Sprite.Pivot.y * Abs(F.y);
  D := S;
  if Sprite.Cell mod (Sprite.Cols + 1) > 0 then
  S.x := Sprite.Cell mod Sprite.Cols;
  S.x := S.x * W / Sprite.Cols;
  if Sprite.Cell >= Sprite.Cols then
  begin
    S.y := Sprite.Cell div Sprite.Cols;
    S.y := S.y * H / Sprite.Rows;
  end;
  D.x := Sprite.Position.x - P.x;
  D.y := Sprite.Position.y - P.y;
  D.width := Abs(F.x) * D.width;
  D.height := Abs(F.y) * D.height;
  if Sprite.Rotation <> 0 then
  begin
    Matrix.Push;
    if F.x < 0 then
      if F.y < 0 then
        Matrix.ScaleAt(-1, -1, D.x + P.x, D.y + P.y)
      else
        Matrix.ScaleAt(-1, 1, D.x + P.x, D.y + P.y)
    else if F.y < 0 then
      Matrix.ScaleAt(1, -1, D.x + P.x, D.y + P.y);
    Matrix.RotateAt(Sprite.Rotation, D.x + P.x, D.y + P.y);
    DrawImage(Sprite.Bitmap, S, D, Sprite.Opacity);
    Matrix.Pop;
  end
  else if (F.x < 0) or (F.y < 0) then
  begin
    Matrix.Push;
    if F.x < 0 then
      if F.y < 0 then
        Matrix.ScaleAt(-1, -1, D.x + P.x, D.y + P.y)
      else
        Matrix.ScaleAt(-1, 1, D.x + P.x, D.y + P.y)
    else
      Matrix.ScaleAt(1, -1, D.x + P.x, D.y + P.y);
    DrawImage(Sprite.Bitmap, S, D, Sprite.Opacity);
    Matrix.Pop;
  end
  else
    DrawImage(Sprite.Bitmap, S, D, Sprite.Opacity);
end;

procedure TCanvas.BeginPath;
begin
  nvgBeginPath(Ctx);
end;

procedure TCanvas.MoveTo(X, Y: Single);
begin
  CheckMatrix;
  nvgMoveTo(Ctx, X, Y);
end;

procedure TCanvas.LineTo(X, Y: Single);
begin
  CheckMatrix;
  nvgLineTo(Ctx, X, Y);
end;

procedure TCanvas.ArcTo(X1, Y1, X2, Y2, Radius: Single);
begin
  CheckMatrix;
  nvgArcTo(Ctx, X1, Y1, X2, Y2, Radius);
end;

procedure TCanvas.BezierTo(CX1, CY1, CX2, CY2, X, Y: Single);
begin
  CheckMatrix;
  nvgBezierTo(Ctx, CX1, CY1, CX2, CY2, X, Y);
end;

procedure TCanvas.QuadTo(CX, CY, X, Y: Single);
begin
  CheckMatrix;
  nvgQuadTo(Ctx, CX, CY, X, Y);
end;

procedure TCanvas.Arc(CX, CY, Radius, A0, A1: Single; Clockwise: Boolean);
const
  Dir: array[Boolean] of NVGwinding = (NVG_CCW, NVG_CW);
begin
  CheckMatrix;
  nvgArc(Ctx, CX, CY, Radius, A0, A1, Dir[Clockwise]);
end;

procedure TCanvas.Circle(X, Y, Radius: Single);
begin
  CheckMatrix;
  nvgCircle(Ctx, X, Y, Radius);
end;

procedure TCanvas.Ellipse(const R: TRect);
begin
  CheckMatrix;
  nvgEllipse(Ctx, R.X + R.Width / 2, R.Y + R.Height / 2,
    R.Width / 2, R.Height / 2);
end;

procedure TCanvas.Ellipse(X, Y, Width, Height: Single);
begin
  CheckMatrix;
  nvgEllipse(Ctx, X + Width / 2, Y + Height / 2, Width / 2, Height / 2);
end;

procedure TCanvas.Rect(const R: TRect);
begin
  CheckMatrix;
  nvgRect(Ctx, R.X, R.Y, R.Width, R.Height);
end;

procedure TCanvas.Rect(X, Y, Width, Height: Single);
begin
  CheckMatrix;
  nvgRect(Ctx, X, Y, Width, Height);
end;

procedure TCanvas.RoundRect(const R: TRect; Radius: Single);
begin
  CheckMatrix;
  nvgRoundedRect(Ctx, R.X, R.Y, R.Width, R.Height, Radius);
end;

procedure TCanvas.RoundRect(X, Y, Width, Height: Single; Radius: Single);
begin
  CheckMatrix;
  nvgRoundedRect(Ctx, X, Y, Width, Height, Radius);
end;

procedure TCanvas.RoundRectVarying(const R: TRect; TL, TR, BR, BL: Single);
begin
  CheckMatrix;
  if TL < 0 then TL := 0;
  if TR < 0 then TR := 0;
  if BL < 0 then BL := 0;
  if BR < 0 then BR := 0;
  nvgRoundedRectVarying(Ctx, R.X, R.Y, R.Width, R.Height, TL, TR, BR, BL);
end;

procedure TCanvas.Polygon(P: PVec2; Count: Integer; Closed: Boolean = True);
var
  I: Integer;
begin
  if Count < 2 then
    Exit;
  CheckMatrix;
  nvgMoveTo(Ctx, P.X, P.Y);
  Inc(P);
  for I := 2 to Count do
  begin
    nvgLineTo(Ctx, P.X, P.Y);
    Inc(P);
  end;
  if Closed then
    nvgClosePath(Ctx);
end;

procedure TCanvas.ClosePath;
begin
  nvgClosePath(Ctx);
end;

procedure TCanvas.Fill(Brush: IBrush; Preserve: Boolean = False);
begin
  SelectObject(Brush);
  nvgFill(Ctx);
  if not Preserve then
    nvgBeginPath(Ctx);
end;

procedure TCanvas.Fill(Color: TColorF; Preserve: Boolean = False); overload;
begin
  (SolidBrush as TBrush).Changed := True;
  SolidBrush.Color := Color;
  Fill(SolidBrush, Preserve);
end;

procedure TCanvas.Stroke(Pen: IPen; Preserve: Boolean = False); overload;
begin
  SelectObject(Pen);
  nvgStroke(Ctx);
  if not Preserve then
    nvgBeginPath(Ctx);
end;

procedure TCanvas.Stroke(Color: TColorF; Width: Single = 1; Preserve: Boolean = False); overload;
begin
  SolidPen.Color := Color;
  SolidPen.Width := Width;;
  Stroke(SolidPen, Preserve);
end;

procedure TCanvas.FillCircle(Brush: IBrush; X, Y, Radius: Single);
begin
  BeginPath;
  Circle(X, Y, Radius);
  Fill(Brush);
end;

procedure TCanvas.StrokeCircle(Pen: IPen; X, Y, Radius: Single);
begin
  BeginPath;
  Circle(X, Y, Radius);
  Stroke(Pen);
end;

procedure TCanvas.FillRect(Brush: IBrush; const R: TRect);
begin
  BeginPath;
  Rect(R);
  Fill(Brush);
end;

procedure TCanvas.StrokeRect(Pen: IPen; const R: TRect);
begin
  BeginPath;
  Rect(R);
  Stroke(Pen);
end;

procedure TCanvas.FillRoundRect(Brush: IBrush; const R: TRect; Radius: Single);
begin
  BeginPath;
  RoundRect(R, Radius);
  Fill(Brush);
end;

procedure TCanvas.StrokeRoundRect(Pen: IPen; const R: TRect; Radius: Single);
begin
  BeginPath;
  RoundRect(R, Radius);
  Stroke(Pen);
end;

function TCanvas.GetGontext: Pointer;
begin
  Result := Ctx;
end;

function TCanvas.GetBlendMode: TBlendMode;
begin
  Result := BlendMode;
end;

procedure TCanvas.SetBlendMode(Value: TBlendMode);
begin
  BlendMode := Value;
  case BlendMode of
    blendAlpha: nvgGlobalCompositeBlendFunc(Ctx, NVG_ONE, NVG_ONE_MINUS_SRC_ALPHA);
    blendAdditive: nvgGlobalCompositeBlendFunc(Ctx, NVG_ONE, NVG_ONE);
    blendSubtractive: nvgGlobalCompositeBlendFunc(Ctx, NVG_ONE_MINUS_SRC_COLOR, NVG_ONE_MINUS_SRC_COLOR);
    blendLighten: nvgGlobalCompositeBlendFunc(Ctx, NVG_SRC_COLOR, NVG_ONE);
    blendDarken: nvgGlobalCompositeBlendFunc(Ctx, NVG_ONE_MINUS_SRC_COLOR, NVG_SRC_COLOR);
    blendInvert: nvgGlobalCompositeBlendFunc(Ctx, NVG_ZERO, NVG_ONE_MINUS_SRC_COLOR);
    blendNegative: nvgGlobalCompositeBlendFunc(Ctx, NVG_ONE_MINUS_DST_COLOR, NVG_ZERO);
  end;
end;

function TCanvas.GetOpacity: Single;
begin
  Result := Opacity;
end;

procedure TCanvas.SetOpacity(Value: Single);
begin
  Opacity := {%H-}Clamp(Value);
  nvgGlobalAlpha(Ctx, Opacity);
end;

function TCanvas.GetMatrix: IMatrix;
begin
  Result := Matrix;
end;

procedure TCanvas.SetMatrix(Value: IMatrix);
var
  A: TMatrix;
begin
  if Value = Matrix then Exit;
  A := Value as TMatrix;
  M.Data := A.Data;
  M.Changed := True;
end;

function TCanvas.GetWinding: TWinding;
begin
  Result := Winding;
end;

procedure TCanvas.SetWinding(const Value: TWinding);
const
  W: array[TWinding] of NVGwinding = (NVG_CCW, NVG_CW);
begin
  if Value = Winding then Exit;
  Winding := Value;
  nvgPathWinding(Ctx, W[Winding]);
end;

{ Creation functions }

function Clamp(A: Single): Single;
begin
  if A < 0 then Result := 0 else if A > 1 then Result := 1 else Result := A;
end;

function NewColorB(R, G, B: Byte; A: Byte = $FF): TColorF;
begin
  Result := TColorB((A shl 24) or (R shl 16) or (G shl 8) or B);
end;

function NewColorF(R, G, B: Single; A: Single = 1): TColorF;
begin
  Result.A := Clamp(A);
  Result.R := Clamp(R);
  Result.G := Clamp(G);
  Result.B := Clamp(B);
end;

function NewHSL(H, S, L: Single; A: Single = 1): TColorF;
var
  C: NVGcolor absolute Result;
begin
  C := nvgHSL(H, S, L);
  Result.A := Clamp(A);
end;

function NewPointF(X, Y: Single): TVec2;
begin
  Result.X := X; Result.Y := Y;
end;

function NewRectF(Width, Height: Single): TRect;
begin
  Result.X := 0; Result.Y := 0; Result.Width := Width; Result.Height := Height;
end;

function NewRectF(X, Y, Width, Height: Single): TRect;
begin
  Result.X := X; Result.Y := Y; Result.Width := Width; Result.Height := Height;
end;

type
  TMatrixStack = TList<IMatrix>;
  TPenStack = TList<IPen>;
  TSolidBrushStack = TList<ISolidBrush>;

var
  MatrixStack: TMatrixStack;
  PenStack: TPenStack;
  SolidBrushStack: TSolidBrushStack;

function NewMatrix: IMatrix;
var
  M: TMatrix;
  I: Integer;
begin
  if MatrixStack = nil then
  begin
    MatrixStack := TMatrixStack.Create;
    MatrixStack.Capacity := StackSize;
    for I := 0 to StackSize - 1 do
      MatrixStack.Add(TMatrix.Create);
  end;
  for I := 0 to StackSize - 1 do
  begin
    M := MatrixStack.Item[I] as TMatrix;
    if M.RefCount = 2 then
    begin
      M.Identity;
      Exit(M);
    end;
  end;
  Result := TMatrix.Create;
end;

function NewPen: IPen;
var
  P: TPen;
  I: Integer;
begin
  if PenStack = nil then
  begin
    PenStack := TPenStack.Create;
    PenStack.Capacity := StackSize;
    for I := 0 to StackSize - 1 do
      PenStack.Add(TPen.Create);
  end;
  for I := 0 to StackSize - 1 do
  begin
    P := PenStack.Item[I] as TPen;
    if P.RefCount = 2 then
    begin
      P.Color := colorBlack;
      P.Width := 1;
      P.LineCap := capButt;
      P.LineJoin := joinMiter;
      P.MiterLimit := 10;
      P.Brush := nil;
      Exit(P);
    end;
  end;
  Result := TPen.Create;
end;

function NewPen(const Color: TColorF; Width: Single = 1; Cap: TLineCap = capButt): IPen; overload;
begin
  Result := NewPen;
  Result.Color := Color;
  Result.Width := Width;
  Result.LineCap := Cap;
end;

function NewBrush(const Color: TColorF): ISolidBrush;
var
  B: TSolidBrush;
  I: Integer;
begin
  if SolidBrushStack = nil then
  begin
    SolidBrushStack := TSolidBrushStack.Create;
    SolidBrushStack.Capacity := StackSize;
    for I := 0 to StackSize - 1 do
      SolidBrushStack.Add(TSolidBrush.Create);
  end;
  for I := 0 to StackSize - 1 do
  begin
    B := SolidBrushStack.Item[I] as TSolidBrush;
    if B.RefCount = 2 then
    begin
      B.Color := Color;
      Exit(B);
    end;
  end;
  Result := TSolidBrush.Create;
  Result.Color := Color;
end;

function NewBrush(const P0, P1: TVec2): ILinearGradientBrush;
var
  G: TLinearGradientBrush;
begin
  Result := TLinearGradientBrush.Create;
  G := Result as TLinearGradientBrush;
  G.A := P0;
  G.B := P1;
end;

function NewBrush(const P0, P1: TVec2; C0, C1: TColorF): ILinearGradientBrush;
begin
  Result := NewBrush(P0, P1);
  Result.NearStop.Offset := 0;
  Result.NearStop.Color := C0;
  Result.FarStop.Offset := 1;
  Result.FarStop.Color := C1;
end;

function NewBrush(const Rect: TRect): IRadialGradientBrush;
var
  B: TRadialGradientBrush;
begin
  Result := TRadialGradientBrush.Create;
  B := Result as TRadialGradientBrush;
  B.Rect := Rect;
end;

function NewBrush(const Rect: TRect; C0, C1: TColorF): IRadialGradientBrush;
begin
  Result := NewBrush(Rect);
  Result.NearStop.Offset := 0;
  Result.NearStop.Color := C0;
  Result.FarStop.Offset := 1;
  Result.FarStop.Color := C1;
end;

function NewBrush(Bitmap: IBitmap): IBitmapBrush;
var
  B: TBitmapBrush;
begin
  Result := TBitmapBrush.Create;
  B := Result as TBitmapBrush;
  B.Bitmap := Bitmap;
end;

function NewSprite: ISprite;
begin
  Result := TSprite.Create;
end;

function NewCanvas: ICanvas;
begin
  Result := TCanvas.Create;
end;

finalization
  MatrixStack.Free;
  PenStack.Free;
  SolidBrushStack.Free;
end.
