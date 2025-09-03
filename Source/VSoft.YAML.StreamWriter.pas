unit VSoft.YAML.StreamWriter;

interface

// This exists because the RTL TStreamWrite always writes the BOM when you provide it with an encoding
// we need control over that as we use mutliple writers on the same stream when writing multiple dodcuments

uses
  System.SysUtils,
  System.Classes;

type
  TYAMLStreamWriter = class(TTextWriter)
  private
    FStream: TStream;
    FEncoding: TEncoding;
    FNewLine: string;
    FAutoFlush: Boolean;
    FOwnsStream: Boolean;
  protected
    FBufferIndex: Integer;
    FBuffer: TBytes;
    procedure WriteBytes(Bytes: TBytes);
  public
    constructor Create(Stream: TStream); overload;
    constructor Create(Stream: TStream; WriteBOM : boolean; Encoding: TEncoding; BufferSize: Integer = 4096); overload;
    constructor Create(const Filename: string); overload;
    constructor Create(const Filename: string; WriteBOM : boolean; Encoding: TEncoding; BufferSize: Integer = 4096); overload;
    destructor Destroy; override;
    procedure Close; override;
    procedure Flush; override;
    procedure OwnStream; inline;
    procedure Write(Value: Boolean); override;
    procedure Write(Value: Char); override;
    procedure Write(const Value: TCharArray); override;
    procedure Write(Value: Double); override;
    procedure Write(Value: Integer); override;
    procedure Write(Value: Int64); override;
    procedure Write(Value: TObject); override;
    procedure Write(Value: Single); override;
    procedure Write(const Value: string); override;
    procedure Write(Value: Cardinal); override;
    procedure Write(Value: UInt64); override;
    procedure Write(const Format: string; Args: array of const); override;
    procedure Write(const Value: TCharArray; Index, Count: Integer); override;
    procedure WriteLine; override;
    procedure WriteLine(Value: Boolean); override;
    procedure WriteLine(Value: Char); override;
    procedure WriteLine(const Value: TCharArray); override;
    procedure WriteLine(Value: Double); override;
    procedure WriteLine(Value: Integer); override;
    procedure WriteLine(Value: Int64); override;
    procedure WriteLine(Value: TObject); override;
    procedure WriteLine(Value: Single); override;
    procedure WriteLine(const Value: string); override;
    procedure WriteLine(Value: Cardinal); override;
    procedure WriteLine(Value: UInt64); override;
    procedure WriteLine(const Format: string; Args: array of const); override;
    procedure WriteLine(const Value: TCharArray; Index, Count: Integer); override;
    property AutoFlush: Boolean read FAutoFlush write FAutoFlush;
    property NewLine: string read FNewLine write FNewLine;
    property Encoding: TEncoding read FEncoding;
    property BaseStream: TStream read FStream;
  end;


implementation

procedure TYAMLStreamWriter.Close;
begin
  Flush;
  if FOwnsStream  then
    FreeAndNil(FStream);
end;

constructor TYAMLStreamWriter.Create(Stream: TStream);
begin
  inherited Create;
  FOwnsStream := False;
  FStream := Stream;
  FEncoding := TEncoding.UTF8;
  SetLength(FBuffer, 1024);
  FBufferIndex := 0;
  FNewLine := sLineBreak;
  FAutoFlush := True;
end;

constructor TYAMLStreamWriter.Create(Stream: TStream; WriteBOM : boolean; Encoding: TEncoding; BufferSize: Integer);
begin
  inherited Create;
  FOwnsStream := False;
  FStream := Stream;
  FEncoding := Encoding;
  if BufferSize >= 128 then
    SetLength(FBuffer, BufferSize)
  else
    SetLength(FBuffer, 128);
  FBufferIndex := 0;
  FNewLine := sLineBreak;
  FAutoFlush := True;
  if WriteBOM and (Stream.Position = 0) then
    WriteBytes(FEncoding.GetPreamble);
end;

constructor TYAMLStreamWriter.Create(const Filename: string);
begin
  FStream := TFileStream.Create(Filename, fmCreate);
  Create(FStream);
  FOwnsStream := True;
end;

constructor TYAMLStreamWriter.Create(const Filename: string; WriteBOM : boolean;  Encoding: TEncoding; BufferSize: Integer);
begin
  FStream := TFileStream.Create(Filename, fmCreate);
  Create(FStream, WriteBOM, Encoding, BufferSize);
  FOwnsStream := True;
end;

destructor TYAMLStreamWriter.Destroy;
begin
  Close;
  SetLength(FBuffer, 0);
  inherited;
end;

procedure TYAMLStreamWriter.Flush;
begin
  if FBufferIndex = 0 then
    Exit;
  if FStream = nil then
    Exit;

  try
    FStream.WriteBuffer(FBuffer, FBufferIndex);
  finally
    FBufferIndex := 0;
  end;
end;

procedure TYAMLStreamWriter.OwnStream;
begin
  FOwnsStream := True;
end;

procedure TYAMLStreamWriter.Write(Value: Cardinal);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value)));
end;

procedure TYAMLStreamWriter.Write(const Value: string);
begin
  WriteBytes(FEncoding.GetBytes(Value));
end;

procedure TYAMLStreamWriter.Write(Value: UInt64);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value)));
end;

procedure TYAMLStreamWriter.Write(const Value: TCharArray; Index, Count: Integer);
var
  Bytes: TBytes;
begin
  SetLength(Bytes, Count * 4);
  SetLength(Bytes, FEncoding.GetBytes(Value, Index, Count, Bytes, 0));
  WriteBytes(Bytes);
end;

procedure TYAMLStreamWriter.WriteBytes(Bytes: TBytes);
var
  ByteIndex: Integer;
  WriteLen: Integer;
begin
  ByteIndex := 0;

  while ByteIndex < Length(Bytes) do
  begin
    WriteLen := Length(Bytes) - ByteIndex;
    if WriteLen > Length(FBuffer) - FBufferIndex then
      WriteLen := Length(FBuffer) - FBufferIndex;

    Move(Bytes[ByteIndex], FBuffer[FBufferIndex], WriteLen);

    Inc(FBufferIndex, WriteLen);
    Inc(ByteIndex, WriteLen);

    if FBufferIndex >= Length(FBuffer) then
      Flush;
  end;

  if FAutoFlush then
    Flush;
end;

procedure TYAMLStreamWriter.Write(const Format: string; Args: array of const);
begin
  WriteBytes(FEncoding.GetBytes(System.SysUtils.Format(Format, Args)));
end;

procedure TYAMLStreamWriter.Write(Value: Single);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value)));
end;

procedure TYAMLStreamWriter.Write(const Value: TCharArray);
begin
  WriteBytes(FEncoding.GetBytes(Value));
end;

procedure TYAMLStreamWriter.Write(Value: Double);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value)));
end;

procedure TYAMLStreamWriter.Write(Value: Integer);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value)));
end;

procedure TYAMLStreamWriter.Write(Value: Char);
begin
  WriteBytes(FEncoding.GetBytes(Value));
end;

procedure TYAMLStreamWriter.Write(Value: TObject);
begin
  WriteBytes(FEncoding.GetBytes(Value.ToString));
end;

procedure TYAMLStreamWriter.Write(Value: Int64);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value)));
end;

procedure TYAMLStreamWriter.Write(Value: Boolean);
begin
  WriteBytes(FEncoding.GetBytes(BoolToStr(Value, True)));
end;

procedure TYAMLStreamWriter.WriteLine(const Value: TCharArray);
begin
  WriteBytes(FEncoding.GetBytes(Value));
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Double);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Integer);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine;
begin
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Boolean);
begin
  WriteBytes(FEncoding.GetBytes(BoolToStr(Value, True) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Char);
begin
  WriteBytes(FEncoding.GetBytes(Value));
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Int64);
begin
  WriteBytes(FEncoding.GetBytes(IntToStr(Value) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: UInt64);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(const Format: string; Args: array of const);
begin
  WriteBytes(FEncoding.GetBytes(System.SysUtils.Format(Format, Args) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(const Value: TCharArray; Index, Count: Integer);
var
  Bytes: TBytes;
begin
  SetLength(Bytes, Count * 4);
  SetLength(Bytes, FEncoding.GetBytes(Value, Index, Count, Bytes, 0));
  WriteBytes(Bytes);
  WriteBytes(FEncoding.GetBytes(FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Cardinal);
begin
  WriteBytes(FEncoding.GetBytes(UIntToStr(Value) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: TObject);
begin
  WriteBytes(FEncoding.GetBytes(Value.ToString + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(Value: Single);
begin
  WriteBytes(FEncoding.GetBytes(FloatToStr(Value) + FNewLine));
end;

procedure TYAMLStreamWriter.WriteLine(const Value: string);
begin
  WriteBytes(FEncoding.GetBytes(Value + FNewLine));
end;


end.
