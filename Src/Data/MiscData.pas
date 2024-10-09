unit MiscData;

interface

uses SysUtils, Windows, Classes, PartyData;
{$OLDTYPELAYOUT ON}
{$REGION 'Quest Data'}

type
  TQuest = packed record
    ID: WORD;
    Unk: ARRAY [0 .. 9] OF BYTE;
  end;

{$ENDREGION}
{$REGION 'Item Data'}

type
  TItemEffect = packed record
    Index: Array [0 .. 2] of BYTE;
    Value: Array [0 .. 2] of BYTE;
  End;
  {
    type
    TOrigItem = packed record
    Index, APP: WORD;
    Identific: LongInt;
    Effects: TItemEffect;
    MIN, MAX: BYTE;
    Refi: WORD; // REFI[1Byte]/LVL[1Byte]/(QNT[2 bytes]) //acho que esse lvl são 2 bytes, 1 pra cada level(min e max) usado no nivelamento
    Time: WORD; // Licença/TEMPO PRA EXPIRAR
    end; }

type
  PItem = ^TItem;

  TItem = packed record
    Index, APP: WORD;
    Identific: LongInt;
    Effects: TItemEffect;
    MIN, MAX: BYTE;
    Refi: WORD;
    // REFI[1Byte]/LVL[1Byte]/(QNT[2 bytes]) //acho que esse lvl são 2 bytes, 1 pra cada level(min e max) usado no nivelamento
    Time: WORD; // Licença/TEMPO PRA EXPIRAR
    // não fará parte do item, pois para mover usando sizeof(TITEM_SIZE) const
    { Iddb: UInt64;
      IsActive: Boolean; //item ativo=1 (existente) item desativado=0 (deletado)
      GeneratedIn: Byte; //vai ter consts para isso, de onde foi gerado
      GeneratedTime: TDateTime; //data e hora de geramento
      GeneratorAccountID: UInt64; //acciddb de quem gerou
      DeletedTime: TDateTime; //isso aqui vai ser nulo na db, até ter active=0
      DeleterAccountID: UInt64; //isso aqui vai ser nulo na db, até ter active=0 }

  private
    function GetExpire: TDateTime;
    procedure SetExpire(Time: TDateTime);

    function GetIsSealed: Boolean;
    procedure SetIsSealed(Selado: Boolean);
  public
    property ExpireDate: TDateTime read GetExpire write SetExpire;
    property IsSealed: Boolean read GetIsSealed write SetIsSealed;

    function GetEquipSellPrice: DWORD;
    function GetEquipType: Integer;
  end;

type
  TItemPrice = record
    PriceType: BYTE;
    Value1, Value2: DWORD;
  end;

type
  PItemCash = ^TItemCash;

  TItemCash = packed record
    Index, APP: WORD;
    Identific: LongInt;

    function ToItem: TItem;
  end;

{$ENDREGION}
{$REGION 'Position Data'}

type
  TPosition = record
  public
    X, Y: Single;

    constructor Create(X, Y: Single);

    function Distance(const pos: TPosition): WORD;
    function InRange(const pos: TPosition; range: WORD): Boolean;

    procedure ForEach(range: BYTE; proc: TProc<TPosition>);

    function IsValid: Boolean;

    class function Lerp(const start, dest: TPosition; Time: Single)
      : TPosition; static;
    class function Qerp(const start, dest: TPosition; Time: Single;
      inverse: Boolean = false): TPosition; static;

    class operator Equal(pos1, pos2: TPosition): Boolean;
    class operator NotEqual(pos1, pos2: TPosition): Boolean;
    class operator Add(pos1, pos2: TPosition): TPosition;
    class operator Subtract(pos1, pos2: TPosition): TPosition;
    class operator Multiply(pos1: TPosition; val: WORD): TPosition;
    class operator Multiply(pos1: TPosition; val: Single): TPosition;

    class function MidAdvanceValue(const CurrentPosition: TPosition;
      range: WORD): TPosition; static;
    class function MidBackValue(const OldestPosition: TPosition; range: WORD)
      : TPosition; static;


    // essa func ajuda a processar os novos valores do campo de visão

    // procedure ForEach (range: Byte; proc: TProc<TPosition>);
  end;

{$ENDREGION}
{$REGION 'HeightMap Data'}

type
  THeightMap = record
    p: array [0 .. 4095] of array [0 .. 4095] of BYTE;
  End;

{$ENDREGION}
{$REGION 'Token Data'}

type
  TPlayerToken = packed record
    Token: ARRAY [0 .. 31] OF AnsiChar;
    CreationTime: TDateTime;

  public
    procedure Generate(Password: string);
  end;

{$ENDREGION}
{$REGION 'Nation Data'}

type
  TGuildsAlly = packed record
    LordMarechal: Array [0 .. 19] of AnsiChar;
    Estrategista: Array [0 .. 19] of AnsiChar;
    Juiz: Array [0 .. 19] of AnsiChar;
    Tesoureiro: Array [0 .. 19] of AnsiChar;
  end;

{$ENDREGION}
{$REGION 'Title Data'}

type
  TTitle = packed record
    Index, Level: BYTE;
  end;

{$ENDREGION}
{$REGION 'PersonalShop Data'}

type
  PPersonalShopItem = ^TPersonalShopItem;

  TPersonalShopItem = packed record
    Price: UInt64;
    Slot: DWORD;
    Item: TItem;
  end;

type
  TPersonalShopData = packed record
    Index: DWORD;
    Name: ARRAY [0 .. 31] OF AnsiChar;
    Products: ARRAY [0 .. 9] OF TPersonalShopItem;
  end;

{$ENDREGION}
{$REGION 'Mail Data'}

type
  TMailContent = packed record
    Nick: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: Array [0 .. 511] of AnsiChar;
    Gold: DWORD;
    ItemSlot: Array [0 .. 6] of BYTE; // 4 slots mas sobra 3
  end;

type
  TStructCarta = packed record
    Index: UInt64;
    NickEnviado: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    DataRetorno: Array [0 .. 19] of AnsiChar;
    Checked: Boolean;
    Return: Boolean;
    CheckItem: Boolean;
    Leilao: Boolean;
  end;

type
  TOpenMailContent = packed record
    Index: UInt64; { Index da carta }
    CharIndex: DWORD;
    Slot: WORD;
    OpenType: WORD;
    Index2: UInt64; { Repete o index }
    Nick: ARRAY [0 .. 15] OF AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: ARRAY [0 .. 511] OF AnsiChar;
    DataEnvio: ARRAY [0 .. 19] OF AnsiChar;
    Items: ARRAY [0 .. 4] OF TItem;
    Gold: DWORD;
    Return: Boolean;
    Unk_B01: Boolean;
    Unk_B02: Boolean;
    Unk_B03: Boolean;
  end;

{$ENDREGION}
{$REGION 'Damage Data'}

type
  TDamageType = (Normal, Critical, Double, DoubleCritical, Immune,
    ImmuneCritical, ImmuneDouble, ImmuneDoubleCritical, Miss, MissCritical,
    MissDouble, MissCritical2, Miss2, Miss2Critical, Miss2Double,
    Miss2Critical2, Block, BlockCritical, BlockDouble, BlockCritical2, Immune2,
    Immune2Critical, Immune2Double, Immune2Critical2, Miss3, Miss3Critical,
    Miss3Double, Miss3Critical2, Miss4, Miss4Critical, Miss4Double,
    Miss4Critical2, None, None2, None3, None4, None5, Debuff, None7,
    None8, None9);

{$ENDREGION}
{$REGION 'Reliquare Data'}

type
  TReliquareForPacket = packed record
    ItemID: WORD;
    APP: WORD;
    Unknown: DWORD;
    TimeToEstabilish: DWORD;
    Unknown2: WORD;
    UnkByte1: BYTE; // valor 2
    UnkByte2: BYTE; // valor 1
    Unknown3: DWORD;
  end;

type
  TReliquareInfoForPacket = packed record
    ItemID: DWORD;
    NameCapped: Array [0 .. 15] of AnsiChar;
    TimeCapped: DWORD;
    IsActive: BYTE;
    Unk: Array [0 .. 2] of BYTE;
  end;

type
  TDevirForPacket = packed record
    Slots: Array [0 .. 4] of TReliquareForPacket;
  end;

type
  TDevirInfoForPacket = packed record
    Slots: Array [0 .. 4] of TReliquareInfoForPacket;
  end;

type
  TDevirSlot = record
    ItemID: WORD;
    APP: WORD;
    IsAble: Boolean;
    TimeCapped: TDateTime;
    TimeToEstabilish: TDateTime;
    NameCapped: Array [0 .. 15] of AnsiChar;
    TimeFurthed: TDateTime;
    ItemFurthed: DWORD;
    Furthed: Boolean;
  end;

type
  TDevirOpennedThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    DevirId: Integer;
    TempId: Integer;
    SecureAreaId: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE;
      DevId, TempId, SecAid: Integer);
  end;

type
  TDevir = record
    DevirId: DWORD;
    NationID: DWORD;
    Slots: Array [0 .. 4] of TDevirSlot;
    StonesDied: Integer;
    GuardsDied: Integer;
    ReliqCount: Integer;
    IsOpen: Boolean;
    CollectedReliquare: Boolean;
    OpenTime: TDateTime;
    OpenedThread: TDevirOpennedThread;
    PlayerIndexGettingReliq: WORD;
  end;

type
  TSpaceTemple = record
    DevirId: BYTE;
    SlotID: BYTE;
  end;

type
  TSecureArea = record
    SecureClientID: WORD;
    IsActive: Boolean;
    SecureType: BYTE;
    SecureDevir: Boolean;
    DevirId: BYTE;
    TempId: WORD;
    Position: TPosition;
    TimeInit: TDateTime;
    TotemFace: WORD;
    Effect: BYTE;
    WhoInitiated: Array [0 .. 15] of AnsiChar;
  end;

type
  TIdsArray = Array [0 .. 2] of Integer;

{$ENDREGION}

type
  TNeighbor = record
    Occuped: Boolean;
    pos: TPosition;
  end;

type
  TypeMobLocation = (Init, dest);

type
  Guards = (Guarda_Verband = 81, Guarda_Amarkand = 82, Guarda_Hekla = 117,
    Guarda_Regenchain = 485, Guarda_Amark_Devir = 486, Guarda_Mirza = 739,
    Guarda_Basilan = 888, Guarda_Sigmund = 889, Guarda_bat_Amark = 890,
    Guarda_bat_Verband = 897, Pedra_Guardia = 901, Guarda_bat_Mirza = 915,
    Guarda_Altar = 924, Guarda_bat_Basilan = 1935, Mago_bat_MIG = 1936,
    Guarda_real_Amark = 1925, Guarda_real_Sig = 1926, Guarda_bat_Hekla = 1927,
    Guarda_Bat_Mirza2 = 1922, Guarda_real_Verband = 1923, Guarda_Disc = 2595);

type
  TPetType = (X14, NORMAL_PET);

var
  TDungeonDificultNames: Array [0 .. 2] of String;

type
  TMasterPrives = (NonPriv, NonPriv2, NonPriv3, ModeradorPriv, GameMasterPriv,
    AdministratorPriv);

{$OLDTYPELAYOUT OFF}

implementation

uses
  Util, Functions, GlobalDefs, DateUtils, AnsiStrings, Log;

{$REGION 'TPosition'}

constructor TPosition.Create(X, Y: Single);
begin
  self.X := X;
  self.Y := Y;
end;

function TPosition.IsValid: Boolean;
begin
  Result := true;
  if (self.X.IsInfinity) then
    Result := false
  else if (self.Y.IsInfinity) then
    Result := false
  else if (self.X.IsNan) then
    Result := false
  else if (self.Y.IsNan) then
    Result := false;
end;

function TPosition.Distance(const pos: TPosition): WORD;
var
  dif: TPosition;
  I: Integer;
  RR: Single;
begin
  I := 65354;

  try
    if ((pos.IsValid) and (self.IsValid)) then
    begin
      dif := self - pos;
      RR := Sqrt((dif.X * dif.X) + (dif.Y * dif.Y));

      if (RR < 0) then
        I := Abs(Round(RR))
      else if (RR <= 65354) then
        I := Round(RR);

      Result := I;
    end
    else
    begin
      Result := 65354;
    end;
  except
    on E: Exception do
    begin
      Result := 65354;
      Logger.Write('Erro de calculo no Distance: ' + E.Message, TLogType.Error);
    end;
  end;
end;

function TPosition.InRange(const pos: TPosition; range: WORD): Boolean;
var
  dist: WORD;
begin
  dist := self.Distance(pos);

  Result := (dist <= range);
end;

procedure TPosition.ForEach(range: BYTE; proc: TProc<TPosition>);
var
  X, Y: WORD;
begin
  for X := Round(self.X) - range to Round(self.X) + range do
  begin
    for Y := Round(self.Y) - range to Round(self.Y) + range do
    begin
      if (X > 4096) or (X = 0) or (Y > 4096) or (Y = 0) then
      begin
        Continue;
      end;
      proc(TPosition.Create(X, Y));
    end;
  end;
end;

class function TPosition.Lerp(const start, dest: TPosition; Time: Single)
  : TPosition;
begin
  Result := start + (dest - start) * Time;
end;

class function TPosition.Qerp(const start, dest: TPosition; Time: Single;
  inverse: Boolean = false): TPosition;
var
  quad: Single;
begin
  quad := IfThen(inverse, (2 - Time), Time);
  Result := start + (dest - start) * Time * quad;
end;

class operator TPosition.Equal(pos1, pos2: TPosition): Boolean;
begin
  Result := false;
  if (pos1.X = pos2.X) AND (pos1.Y = pos2.Y) then
    Result := true;
end;

class operator TPosition.NotEqual(pos1, pos2: TPosition): Boolean;
begin
  Result := not(pos1 = pos2);
end;

class operator TPosition.Add(pos1, pos2: TPosition): TPosition;
begin
  Result.X := pos1.X + pos2.X;
  Result.Y := pos1.Y + pos2.Y;
end;

class operator TPosition.Subtract(pos1, pos2: TPosition): TPosition;
begin
  Result.X := pos1.X - pos2.X;
  Result.Y := pos1.Y - pos2.Y;
end;

class operator TPosition.Multiply(pos1: TPosition; val: WORD): TPosition;
begin
  Result.X := pos1.X * val;
  Result.Y := pos1.Y * val;
end;

class operator TPosition.Multiply(pos1: TPosition; val: Single): TPosition;
begin
  Result.X := Round(pos1.X * val);
  Result.Y := Round(pos1.Y * val);
end;

class function TPosition.MidAdvanceValue(const CurrentPosition: TPosition;
  range: WORD): TPosition;
var
  NewRange: WORD;
begin
  NewRange := Round(range / 2);
  Result.X := CurrentPosition.X + NewRange;
  Result.Y := CurrentPosition.Y + NewRange;
end;

class function TPosition.MidBackValue(const OldestPosition: TPosition;
  range: WORD): TPosition;
var
  NewRange: WORD;
begin
  NewRange := Round(range / 2);

  Result.X := OldestPosition.X - NewRange;
  Result.Y := OldestPosition.Y - NewRange;
end;

{$ENDREGION}
{$REGION 'Token Data'}

procedure TPlayerToken.Generate(Password: string);
var
  strToken: string;
begin
  strToken := TFunctions.StringToMd5(TFunctions.StringToMd5(Password) +
    TFunctions.StringToMd5(DateTimeToStr(Now)));

  AnsiStrings.StrPCopy(self.Token, AnsiString(strToken));

  self.CreationTime := Now;
end;

{$ENDREGION}
{$REGION 'Item'}

function TItemCash.ToItem: TItem;

begin
  Result.Index := self.Index;
  Result.APP := self.APP;
  Result.Identific := self.Identific;

  // Move(self, Result, sizeof(self));
  // FillMemory(@Result.Effects.Index[0], sizeof(byte), $CC); //sizeof(TItem) - sizeof(self)
end;

function TItem.GetExpire: TDateTime;
var
  UnixDate: Cardinal;
begin
  Result := StrToDateTime(BASE_DATETIME);

  case ItemList[self.Index].ItemType of

    9:
      begin
        Result := IncDay(Result, self.Time);
      end;

  else
    begin
      Move(PDWORD(LPARAM(@self.Time) - 01)^, PDWORD(LPARAM(@UnixDate) + 01)^,
        3); // erro aqui por conta do x64

      Result := (UnixToDateTime(UnixDate));
    end;

  end;
end;

procedure TItem.SetExpire(Time: TDateTime);
var
  BaseTime: TDateTime;
  UnixDate: Cardinal;
begin

  BaseTime := StrToDateTime(BASE_DATETIME);

  case ItemList[self.Index].ItemType of

    9:
      begin
        self.Time := DaysBetween(Time, BaseTime);
      end;

  else
    begin
      UnixDate := DateTimeToUnix(Time);

      Move(PDWORD(LPARAM(@UnixDate) + 01)^,
        PDWORD(LPARAM(@self.Time) - 01)^, 3);
    end;

  end;
end;

function TItem.GetIsSealed: Boolean;
var
  UnixDate: Cardinal;
begin
  Move(self.Refi, UnixDate, sizeof(DWORD));

  Result := (UnixDate = 0);
end;

procedure TItem.SetIsSealed(Selado: Boolean);
var
  UnixDate: Cardinal;
begin
  if (Selado) then
  begin
    UnixDate := 0;
    Move(UnixDate, self.Refi, sizeof(DWORD));
  end
  else
  begin
    self.Refi := 00;
    self.ExpireDate := IncHour(Now, ItemList[self.Index].Duration + 2);
  end;
end;

function TItem.GetEquipSellPrice: DWORD;
var
  Durab_perc: Single;
begin
  Durab_perc := self.MIN / self.MAX;

  Result := Round(ItemList[self.Index].DefMag * Durab_perc);
end;

function TItem.GetEquipType: Integer;
begin
  if ((ItemList[self.Index].ATKFis > 0) or (ItemList[self.Index].MagATK > 0))
  then
  begin
    Result := 0;
  end
  else if ((ItemList[self.Index].DefFis > 0) or
    (ItemList[self.Index].DefMag > 0)) then
  begin
    Result := 1;
  end
  else
  begin
    Result := 2;
  end;
end;

{$ENDREGION}
{ TUpdateHpMpThread }

constructor TDevirOpennedThread.Create(SleepTime: Integer; ChannelId: BYTE;
  DevId, TempId, SecAid: Integer);
begin
  self.FDelay := SleepTime;
  self.FreeOnTerminate := true;
  self.ChannelId := ChannelId;
  self.DevirId := DevId;
  self.TempId := TempId;
  self.SecureAreaId := SecAid;

  inherited Create(false);
end;

procedure TDevirOpennedThread.Execute;
begin
  while Servers[self.ChannelId].Devires[self.DevirId].IsOpen do
  begin
    if (self.DevirId = 4) then
      break;
    { tempo para fechar o templo e resetar todos }
    if (Servers[self.ChannelId].Devires[self.DevirId].IsOpen) then
    begin
      if (Now >= IncSecond(Servers[self.ChannelId].Devires[self.DevirId]
        .OpenTime, 60)) then
      begin

        Servers[self.ChannelId].CloseDevir(self.DevirId, self.TempId, 0);

        Servers[self.ChannelId].Devires[self.DevirId]
          .PlayerIndexGettingReliq := 0;
      end;
    end;
    Sleep(FDelay);
  end;
end;

initialization

TDungeonDificultNames[0] := 'Normal';
TDungeonDificultNames[1] := 'Dificil';
TDungeonDificultNames[2] := 'Elite';

end.
