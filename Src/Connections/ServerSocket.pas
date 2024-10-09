unit ServerSocket;

interface

uses Winsock2, Windows, PlayerThread, Player, BaseMob, NPC, PlayerData,
  UpdateThreads, MiscData, PartyData, Generics.Collections, AnsiStrings,
  ConnectionsThread, GuildData, SQL, MOB, PET, Objects, classes, Math,
  CastleSiege;
{$OLDTYPELAYOUT ON}

type
  PServerSocket = ^TServerSocket;

  TServerSocket = class
    ServerAddr: TSockAddrIn;
    Name: AnsiString;
    Ip: AnsiString;
    ServerName: string;
    IsActive: Boolean;
    InstantiatedPlayers: WORD;
    ServerHasClosed: Boolean;
    // cSQL: TQuery;
    NationID: BYTE;
    NationType: BYTE;
    DuelCount: Integer;
    ChannelId: BYTE;
    ActivePlayersNowHere: Integer;
    ActiveReliquaresOnTemples: Integer;
    AltarActive: Boolean;
    Players: ARRAY [1 .. 200] OF TPlayer; // reserved 1-2000
    NPCS: ARRAY [2048 .. 3047] OF TNpc; // reserved 2048-3048
    MOBS: TMobStruct; // reserved 3048 + 6099 mob spawns
    PETS: Array [9148 .. 10147] of TPet; // reserved 9148-10147
    OBJ: Array [10148 .. 10239] of TOBJ;
    Prans: Array [10241 .. 10642] of Integer;
    Parties: ARRAY [1 .. 30] OF TParty;
    Devires: Array [0 .. 4] of TDevir;
    DevirNpc: Array [3335 .. 3339] of TNpc;
    DevirGuards: Array [3355 .. 3369] of TNpc;
    DevirStones: Array [3340 .. 3354] of TNpc;
    SecureAreas: Array [0 .. 9] of TSecureArea;
    ReliqEffect: ARRAY [0 .. 395] OF Integer;
    CastleObjects: Array [3370 .. 3390] of TNpc;
    CastleSiegeHandler: TCastleSiege;
    ConnectionThread: TConnectionsThread;
    PlayerThreadsGarbage: TPlayerThreadGarbage;
    UpdateHpMpThread: TUpdateHpMpThread;
    UpdateBuffsThread: TUpdateBuffsThread;
    UpdateMailsThread: TUpdateMailsThread;
    UpdateVisibleThread: TUpdateVisibleThread;
    UpdateWorldAroundThread: TUpdateWorldAroundThread;
    UpdateTimeThread: TUpdateTimeThread;
    UpdateEventListenerThread: TUpdateEventListenerThread;
    SkillRegenerateThread: TSkillRegenerateThread;
    SkillDamageThread: TSkillDamageThread;
    MobSpawnThread1: TMobSpawnThread1;
    MobSpawnThread2: TMobSpawnThread2;
    MobSpawnThread3: TMobSpawnThread3;
    MobHandlerThread1: TMobHandlerThread1;
    MobHandlerThread2: TMobHandlerThread2;
    MobHandlerThread3: TMobHandlerThread3;
    MobMovimentThread1: TMobMovimentThread1;
    MobMovimentThread2: TMobMovimentThread2;
    MobMovimentThread3: TMobMovimentThread3;
    PetHandler: TPetHandler;
    PetSpawner: TPetSpawner;
    SaveInGame: TSaveInGame;
    TimeItensThread: TTimeItensThread;
    ItemQuestThread: TQuestItemThread;
    PranFoodThread: TPranFoodThread;
    TemplesManagmentThread: TTemplesManagmentThread;
    AltarManagmentThread: TAltarManagmentThread;
    CastleSiegeThread: TCastleSiegeThread;

  var
    Sock: TSocket;
    ResetTime: LongInt;
  public
    { TServerSocket }
    function StartSocket(): Boolean;
    function StartServer(): Boolean;
    procedure CloseServer;
    procedure StartThreads;
    procedure StartPartys;
    procedure StartMobs;
    procedure AcceptConnection;
    { Player Functions }
    function GetPlayer(const ClientId: WORD): PPlayer; overload;
    function GetPlayer(const CharacterName: string): PPlayer; overload;
    { Disconnect Functions }
    procedure DisconnectAll;
    procedure Disconnect(var Player: TPlayer); overload;
    procedure Disconnect(ClientId: WORD); overload;
    procedure Disconnect(userName: string); overload;
    { Send Functions }
    procedure SendPacketTo(ClientId: Integer; var Packet; Size: WORD;
      Encrypt: Boolean = true);
    procedure SendSignalTo(ClientId: Integer; pIndex, opCode: WORD);
    procedure SendToVisible(var Base: TBaseMob; var Packet; Size: WORD);
    procedure SendToAll(var Packet; Size: WORD);
    procedure SendServerMsg(Mensg: AnsiString; MsgType: Integer = $10;
      Null: Integer = 0; Type2: Integer = 0; SendToSelf: Boolean = true;
      MyClientID: WORD = 0);
    procedure SendServerMsgForNation(Mensg: AnsiString; aNation: BYTE;
      MsgType: Integer = $10; Null: Integer = 0; Type2: Integer = 0;
      SendToSelf: Boolean = true; MyClientID: WORD = 0);
    { PacketControl }
    function PacketControl(var Player: TPlayer; var Size: Integer;
      var Buffer: array of BYTE; initialOffset: Integer): Boolean;
    { ServerTime }
    function GetResetTime: LongInt;
    function CheckResetTime: Boolean;
    function GetEndDayTime: LongInt;
    { Players }
    function GetPlayerByName(Name: string; out Player: PPlayer)
      : Boolean; overload;
    function GetPlayerByName(Name: string): Integer; overload;
    function GetPlayerByUsername(userName: string): Integer;
    function GetPlayerByUsernameAux(userName: string; CidAux: WORD): Integer;
    function GetPlayerByCharIndex(CharIndex: DWORD; out Player: PPlayer)
      : Boolean; overload;
    function GetPlayerByCharIndex(CharIndex: DWORD; out Player: TPlayer)
      : Boolean; overload;
    { Get Guild }
    function GetGuildByIndex(GuildIndex: Integer): String;
    function GetGuildByName(GuildName: String): Integer;
    function GetGuildSlotByID(GuildIndex: Integer): Integer;
    { Prans }
    function GetFreePranClientID(): Integer;
    { Pets }
    function GetFreePetClientID(): Integer;
    { Temples }
    function GetFreeTempleSpace(): TSpaceTemple;
    function GetFreeTempleSpaceByIndex(id: Integer): TSpaceTemple;
    procedure SaveTemplesDB(Player: PPlayer);
    procedure UpdateReliquaresForAll();
    procedure UpdateReliquareInfosForAll();
    procedure UpdateReliquareEffects();
    function CanOpenTempleNow(DevirId: BYTE): Boolean;
    function OpenDevir(DevId: Integer; TempID: Integer;
      WhoKilledLast: Integer): Boolean;
    function CloseDevir(DevId: Integer; TempID: Integer;
      WhoGetReliq: Integer): Boolean;
    function GetTheStonesFromDevir(DevId: Integer): TIdsArray;
    function GetTheGuardsFromDevir(DevId: Integer): TIdsArray;
    function GetEmptySecureArea(): BYTE;
    function RemoveSecureArea(AreaSlot: BYTE): Boolean; overload;
    function RemoveSecureArea(DevId: Integer): Boolean; overload;
    function RemoveSecureArea(TempID: WORD): Boolean; overload;
    function CreateMapObject(OtherPlayer: PPlayer; OBJID: WORD;
      ContentID: WORD = 0): Boolean;
    function GetFreeObjId(): WORD;
    procedure CollectReliquare(Player: PPlayer; Index: WORD);
    procedure CollectAltar(Player: PPlayer; Index: WORD);
  end;
{$OLDTYPELAYOUT OFF}

implementation

uses GlobalDefs, SysUtils, DateUtils, Log,
  PacketHandlers, StrUtils, Packets,
  Functions, MailFunctions,
  FilesData, Load, EntityMail, AuthHandlers;
{$REGION 'TServerSocket'}

function TServerSocket.StartSocket;
var
  wsa: TWsaData;
  Margv: Cardinal;
  Xargv: AnsiChar;
begin
  Result := false;
  ZeroMemory(@Self.Players, sizeof(Self.Players));
  if (WSAStartup(MAKEWORD(2, 2), wsa) <> 0) then
  begin
    Logger.Write('Ocorreu um erro ao inicializar o Winsock 2.',
      TLogType.ServerStatus);
    exit;
  end;
  Self.Sock := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  Self.ServerAddr.sin_family := AF_INET;
  Self.ServerAddr.sin_port := htons(8822); // port
  Self.ServerAddr.sin_addr.S_addr := inet_addr(PAnsiChar(Self.Ip));

  Xargv := '1';
  if (setsockopt(Self.Sock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0) then
  begin
    Logger.Write('Ocorreu um erro ao configurar o socket para TCP_NODELAY. ' +
      WSAGetLastError.ToString, TLogType.Warnings);
    closesocket(Self.Sock);
    Self.Sock := INVALID_SOCKET;
    exit;
  end;
  if (bind(Sock, TSockAddr(ServerAddr), sizeof(ServerAddr)) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao configurar o socket.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    exit;
  end;
  if (listen(Sock, MAX_CONNECTIONS) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao colocar o socket em modo de escuta.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    exit;
  end;
  Result := true;
end;

function TServerSocket.StartServer: Boolean;
begin
  Result := false;
  if not(Self.StartSocket) then
    exit;
  InstantiatedPlayers := 0;
  IsActive := true;
  ZeroMemory(@Self.Players, sizeof(Self.Players));
  ZeroMemory(@Self.MOBS, sizeof(Self.MOBS));
  ZeroMemory(@Self.Parties, sizeof(Self.Parties));
  Self.StartPartys;
  Self.StartMobs;
  CastleSiegeHandler := TCastleSiege.Create();

  ZeroMemory(@Self.PETS, sizeof(Self.PETS));
  ZeroMemory(@Self.OBJ, sizeof(Self.OBJ));
  Logger.Write(ServerList[Self.ChannelId].Name +
    ' iniciado com sucesso [Porta: 8822].', TLogType.ServerStatus);
  Self.ResetTime := Self.GetResetTime;
  Result := true;
end;

procedure TServerSocket.CloseServer;
var
  i: Integer;
begin
  Self.IsActive := false;
  for i := Low(Self.Players) to High(Self.Players) do
  begin
    Self.Players[i].SocketClosed := true;
    closesocket(Self.Players[i].socket)
  end;
end;

procedure TServerSocket.StartThreads;
begin
  ConnectionThread := TConnectionsThread.Create(ACCEPT_CONNECTIONS_DELAY,
    Self.ChannelId);
  UpdateHpMpThread := TUpdateHpMpThread.Create(2000, Self.ChannelId);
  UpdateBuffsThread := TUpdateBuffsThread.Create(1000, Self.ChannelId);
  UpdateTimeThread := TUpdateTimeThread.Create(500, Self.ChannelId);
  UpdateEventListenerThread := TUpdateEventListenerThread.Create(1000,
    Self.ChannelId);
  SkillRegenerateThread := TSkillRegenerateThread.Create(1000, Self.ChannelId);
  SkillDamageThread := TSkillDamageThread.Create(1000, Self.ChannelId);
  TimeItensThread := TTimeItensThread.Create(5000, Self.ChannelId);
  ItemQuestThread := TQuestItemThread.Create(1000, Self.ChannelId);
  PranFoodThread := TPranFoodThread.Create(200000, Self.ChannelId);
  TemplesManagmentThread := TTemplesManagmentThread.Create(1000,
    Self.ChannelId);
  AltarManagmentThread := TAltarManagmentThread.Create(1000, Self.ChannelId);
end;

procedure TServerSocket.StartPartys;
var
  i: Integer;
begin
  for i := 1 to Length(Self.Parties) do
  begin
    Self.Parties[i].Index := i;
    Self.Parties[i].Leader := 0;
    Self.Parties[i].ChannelId := Self.ChannelId;
    Self.Parties[i].Members := TList<WORD>.Create;
    Self.Parties[i].MemberName := TList<Integer>.Create;
  end;
end;

procedure TServerSocket.StartMobs;
  function IfGuard(IntName: Integer): Boolean;
  begin
    Result := false;
    case IntName of
      81, 82, 117, 485, 486, 739, 888, 889, 890, 897, 901, 915, 924, 1935, 1936,
        1925, 1926, 1927, 1922, 1923, 2595:
        begin
          Result := true;
          exit;
        end;
    end;
  end;

var
  MobQuery, MobPos: TQuery;
  MobCount, MobPosCount, id, idGen, i, i2, i3: Integer;

  Path: String;
  DataFile, F: TextFile;
  FileStrings: TStringList;
  Count: DWORD;
  LineFile: String;
  MobNameInit: String;
  MobN: String;
  id2: Integer;
  j: Integer;
begin
  try
    MobQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));
    id := 0;
    if not(MobQuery.Query.Connection.Connected) then
    begin
      Logger.Write('MobQuery connection MySQL has failed.', TLogType.Error);
      MobQuery.Destroy;
      exit;
    end;
    MobQuery.SetQuery
      ('select m.* from monsters m join monster_positions mpos on mpos.Mobid = m.Id where m.active = 1 group by m.Id;');
    MobQuery.Run();
    MobCount := MobQuery.Query.RecordCount;
    if not(MobCount = 0) then
    begin
      idGen := 0;
      Count := 0;
      for i := 0 to (MobCount - 1) do
      begin
        if not(MobQuery.Query.Connection.Connected) then
        begin
          Logger.Write('MobQuery connection MySQL has failed.', TLogType.Error);
          MobQuery.Destroy;
          exit;
        end;
        MOBS.TMobS[id].IntName := MobQuery.Query.FieldByName('Id').AsInteger;
        MOBS.TMobS[id].Equip[0] := WORD(MobQuery.Query.FieldByName('Equipment1')
          .AsInteger);
        MOBS.TMobS[id].Equip[1] := WORD(MobQuery.Query.FieldByName('Equipment2')
          .AsInteger);
        MOBS.TMobS[id].Equip[6] := WORD(MobQuery.Query.FieldByName('Equipment3')
          .AsInteger);
        MOBS.TMobS[id].InitHP := MobQuery.Query.FieldByName('InitialHp')
          .AsInteger;
        if (MOBS.TMobS[id].InitHP = 0) then
        begin
          MOBS.TMobS[id].InitHP := 3500;
        end;
        MOBS.TMobS[id].Rotation := MobQuery.Query.FieldByName('Rotation')
          .AsInteger;
        MOBS.TMobS[id].MobLevel := MobQuery.Query.FieldByName('Level')
          .AsInteger;
        MOBS.TMobS[id].MobElevation :=
          WORD(MobQuery.Query.FieldByName('Elevation').AsInteger);
        MOBS.TMobS[id].Cabeca := MobQuery.Query.FieldByName('Head').AsInteger;
        MOBS.TMobS[id].Perna := MobQuery.Query.FieldByName('Leg').AsInteger;
        MOBS.TMobS[id].MobType := MobQuery.Query.FieldByName('Type').AsInteger;
        MOBS.TMobS[id].SpawnType := MobQuery.Query.FieldByName('SpawnType')
          .AsInteger;
        MOBS.TMobS[id].IsService :=
          WordBool(MobQuery.Query.FieldByName('IsService').AsBoolean);
        MOBS.TMobS[id].IsAltar := MobQuery.Query.FieldByName('ServiceType')
          .AsInteger = 1;

        MOBS.TMobS[id].ReespawnTime := MobQuery.Query.FieldByName('RespawnTime')
          .AsInteger;
        MOBS.TMobS[id].Skill01 := MobQuery.Query.FieldByName('Skill1')
          .AsInteger;
        MOBS.TMobS[id].Skill02 := MobQuery.Query.FieldByName('Skill2')
          .AsInteger;
        MOBS.TMobS[id].Skill03 := MobQuery.Query.FieldByName('Skill3')
          .AsInteger;
        MOBS.TMobS[id].Skill04 := MobQuery.Query.FieldByName('Skill4')
          .AsInteger;
        MOBS.TMobS[id].Skill05 := MobQuery.Query.FieldByName('Skill5')
          .AsInteger;

        MOBS.TMobS[id].MobExp := MobQuery.Query.FieldByName('Experience')
          .AsInteger;
        MOBS.TMobS[id].DropIndex := 0;

        // Deixa os mobs de altar desativados
        if (MobQuery.Query.FieldByName('ServiceType').AsInteger = 1) then
        begin
          MOBS.TMobS[id].IsActiveToSpawn := false;
        end
        else
          MOBS.TMobS[id].IsActiveToSpawn := true;

        MobPos := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));
        if not(MobPos.Query.Connection.Connected) then
        begin
          Logger.Write('MobQuery connection MySQL has failed.', TLogType.Error);
          MobPos.Destroy;
          exit;
        end;
        MobPos.SetQuery('SELECT * FROM monster_positions where mobid =' +
          MobQuery.Query.FieldByName('Id').AsInteger.ToString);
        MobPos.Run();
        MobPosCount := MobPos.Query.RecordCount;
        idGen := 0;
        if not(MobPosCount = 0) then
        begin
          for i2 := 0 to (MobPosCount - 1) do
          begin

            MobN := AnsiString(MobQuery.Query.FieldByName('Name').AsString);
            MOBS.TMobS[id].IndexGeneric := id;
            System.AnsiStrings.StrPLCopy(MOBS.TMobS[id].Name,
              AnsiString(MobN), 64);
            MOBS.TMobS[id].MobsP[idGen].Index := Count + 3048;

            MOBS.TMobS[id].MobsP[idGen].InitPos.X :=
              MobPos.Query.FieldByName('InitPosX').AsSingle;
            MOBS.TMobS[id].MobsP[idGen].InitPos.Y :=
              MobPos.Query.FieldByName('InitPosY').AsSingle;
            MOBS.TMobS[id].MobsP[idGen].DestPos.X :=
              MobPos.Query.FieldByName('FinalPosX').AsSingle;
            MOBS.TMobS[id].MobsP[idGen].DestPos.Y :=
              MobPos.Query.FieldByName('FinalPosY').AsSingle;

            MOBS.TMobS[id].MobsP[idGen].FirstDestPos.X :=
              MobPos.Query.FieldByName('FinalPosX').AsSingle;
            MOBS.TMobS[id].MobsP[idGen].FirstDestPos.Y :=
              MobPos.Query.FieldByName('FinalPosY').AsSingle;
            MOBS.TMobS[id].MobsP[idGen].DestPos.X := MOBS.TMobS[id].MobsP[idGen]
              .DestPos.X + 5;
            MOBS.TMobS[id].MobsP[idGen].DestPos.Y := MOBS.TMobS[id].MobsP[idGen]
              .DestPos.Y + 5;

            MOBS.TMobS[id].MobsP[idGen].isAggressive :=
              MobQuery.Query.FieldByName('Aggressive').AsBoolean;
            MOBS.TMobS[id].MobsP[idGen].isStalker :=
              MobQuery.Query.FieldByName('Stalker').AsBoolean;

            MOBS.TMobS[id].MobsP[idGen].InitAttackRange := 11;
            MOBS.TMobS[id].MobsP[idGen].InitMoveWait := 8;
            MOBS.TMobS[id].MobsP[idGen].DestAttackRange := 11;
            MOBS.TMobS[id].MobsP[idGen].DestMoveWait := 8;
            MOBS.TMobS[id].MoveSpeed := 22;
            MOBS.TMobS[id].MobsP[idGen].Base.Create(nil, (Count + 3048),
              Self.ChannelId);
            MOBS.TMobS[id].MobsP[idGen].Base.Mobid := id;
            MOBS.TMobS[id].MobsP[idGen].Base.IsActive := true;
            MOBS.TMobS[id].MobsP[idGen].Base.ClientId := Count + 3048;
            MOBS.TMobS[id].MobsP[idGen].Base.SecondIndex := idGen;
            MOBS.TMobS[id].MobsP[idGen].MovedTo := TypeMobLocation.Init;
            MOBS.TMobS[id].MobsP[idGen].LastMyAttack := now;
            MOBS.TMobS[id].MobsP[idGen].LastSkillAttack := now;
            MOBS.TMobS[id].MobsP[idGen].CurrentPos := MOBS.TMobS[id].MobsP
              [idGen].InitPos;
            MOBS.TMobS[id].MobsP[idGen].XPositionsToMove := 1;
            MOBS.TMobS[id].MobsP[idGen].YPositionsToMove := 1;
            MOBS.TMobS[id].MobsP[idGen].NeighborIndex := -1;
            MOBS.TMobS[id].MobsP[idGen].Base.IsBoss := false;
            MOBS.TMobS[id].MobsP[idGen].HP := MOBS.TMobS[id].InitHP;
            MOBS.TMobS[id].MobsP[idGen].MP := MOBS.TMobS[id].InitHP;
            MOBS.TMobS[id].MobsP[idGen].LastSkillUsedByMob := now;
            MOBS.TMobS[id].MobsP[idGen].Base.MobDbId :=
              MobQuery.Query.FieldByName('Id').AsInteger;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.CurrentScore.
              DNFis := MobQuery.Query.FieldByName('PhysicalDamage').AsInteger;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.CurrentScore.
              DNMag := MobQuery.Query.FieldByName('MagicalDamage').AsInteger;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.CurrentScore.
              DefFis := MobQuery.Query.FieldByName('PhysicalDefense').AsInteger;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.CurrentScore.
              DefMag := MobQuery.Query.FieldByName('MagicalDefense').AsInteger;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.CurrentScore.
              Esquiva := MOB_ESQUIVA;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.CritRes :=
              MOB_CRIT_RES;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.DuploRes :=
              MOB_DUPLO_RES;
            MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.Nation :=
              Self.NationID;
            MOBS.TMobS[id].MobsP[idGen].LastMyAttack := now;
            MOBS.TMobS[id].MobsP[idGen].UpdatedMobSpawn := now;
            MOBS.TMobS[id].MobsP[idGen].UpdatedMobHandler := now;
            MOBS.TMobS[id].MobsP[idGen].UpdatedMobMoviment := now;

            if (IfGuard(MOBS.TMobS[id].IntName) = true) then
            begin
              MOBS.TMobS[id].MobsP[idGen].isGuard := true;
              MOBS.TMobS[id].MobsP[idGen].CurrentPos := MOBS.TMobS[i].MobsP
                [j].InitPos;
              MOBS.TMobS[id].MobsP[idGen].DestPos := MOBS.TMobS[i].MobsP
                [j].InitPos;
              MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.
                CurrentScore.DNFis := MOB_GUARD_PATK;
              MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.
                CurrentScore.DNMag := MOB_GUARD_MATK;
              MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.
                CurrentScore.DefFis := MOB_GUARD_PDEF;
              MOBS.TMobS[id].MobsP[idGen].Base.PlayerCharacter.Base.
                CurrentScore.DefMag := MOB_GUARD_MDEF;
            end;
            inc(idGen);
            inc(Count);
            MobPos.Query.Next;
          end;
        end;
        MobPos.Destroy;
        MobQuery.Query.Next;
        inc(id);
      end;
    end;
    MobQuery.Destroy;
  except
    on E: Exception do
    begin
      Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
      exit;
    end;
  end;
  if (MobSpawnThread1 = nil) then
    MobSpawnThread1 := TMobSpawnThread1.Create(1000, Self.ChannelId, 0);
  if (MobSpawnThread2 = nil) then
    MobSpawnThread2 := TMobSpawnThread2.Create(1000, Self.ChannelId, 0);
  if (MobSpawnThread3 = nil) then
    MobSpawnThread3 := TMobSpawnThread3.Create(1000, Self.ChannelId, 0);
  if (MobHandlerThread1 = nil) then
    MobHandlerThread1 := TMobHandlerThread1.Create(1000, Self.ChannelId, 0);
  if (MobHandlerThread2 = nil) then
    MobHandlerThread2 := TMobHandlerThread2.Create(1000, Self.ChannelId, 0);
  if (MobHandlerThread3 = nil) then
    MobHandlerThread3 := TMobHandlerThread3.Create(1000, Self.ChannelId, 0);
  if (MobMovimentThread1 = nil) then
    MobMovimentThread1 := TMobMovimentThread1.Create(600, Self.ChannelId, 0);
  if (MobMovimentThread2 = nil) then
    MobMovimentThread2 := TMobMovimentThread2.Create(600, Self.ChannelId, 0);
  if (MobMovimentThread3 = nil) then
    MobMovimentThread3 := TMobMovimentThread3.Create(600, Self.ChannelId, 0);

  Logger.Write('[Server Mobs Init ] Mobs iniciados com sucesso. Mobs: ' +
    id.ToString + ' Spawns: ' + Count.ToString, TLogType.ServerStatus);
end;

procedure TServerSocket.AcceptConnection;
var
  ClientInfo: PSockAddr;
  Clid: Integer;
  FSock: Cardinal;
  Margv: Cardinal;
  Xargv: AnsiChar;
begin
  ClientInfo := nil;
  FSock := accept(Self.Sock, ClientInfo, nil);
  try
    if ((FSock <> INVALID_SOCKET) and not(Self.ServerHasClosed)) then
    begin
      Clid := TFunctions.FreeClientId(Self.ChannelId);
      if not(Clid = 0) then
      begin
        Margv := 1;
        if (ioctlsocket(FSock, FIONBIO, Margv) < 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para Non-Blocking.',
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;
        Xargv := '1';
        if (setsockopt(FSock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para TCP_NODELAY. ' +
            WSAGetLastError.ToString, TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;

        ZeroMemory(@Self.Players[Clid], sizeof(TPlayer));
        Self.Players[Clid].socket := FSock;
        Self.Players[Clid].Authenticated := false;
        Self.Players[Clid].ConnectionedTime := now;
        Self.Players[Clid].Thread := TPlayerThread.Create(Clid,
          Self.Players[Clid].socket, Self.ChannelId);
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at AcceptConnection ' + E.Message + chr(13) +
        E.StackTrace, TLogType.Error);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Player Functions'}

function TServerSocket.GetPlayer(const ClientId: WORD): PPlayer;
begin
  if ((Self.Players[ClientId].Base.ClientId > 0) and
    not(Self.Players[ClientId].SocketClosed)) then
  begin
    Result := @Self.Players[ClientId];
  end
  else
  begin
    Result := nil;
  end;
end;

function TServerSocket.GetPlayer(const CharacterName: string): PPlayer;
var
  i: Integer;
begin
  Result := Nil;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Self.Players[i].Character.Base.Name = '') then
      continue;
    if (string(Players[i].Character.Base.Name) = CharacterName) then
    begin
      Result := @Self.Players[i];
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Disconnect Functions'}

procedure TServerSocket.DisconnectAll;
var
  i: WORD;
  cnt: WORD;
begin
  cnt := 0;
  for i := 1 to MAX_CONNECTIONS do
    if Self.Players[i].Base.IsActive then
    begin
      Self.Disconnect(Self.Players[i]);
      inc(cnt, 1);
    end;
  if (cnt > 0) then
    Logger.Write('[' + string(ServerList[ChannelId].Name) +
      ']: Foram desconectados ' + IntToStr(cnt) + ' jogadores.',
      TLogType.ConnectionsTraffic);
end;

procedure TServerSocket.Disconnect(ClientId: WORD);
begin
  if (ClientId = 0) then
    exit;
  if not(Players[ClientId].Base.IsActive) then
    exit;
  Self.Disconnect(Players[ClientId]);
end;

procedure TServerSocket.Disconnect(var Player: TPlayer);
var
  cid: WORD;
begin
  if (Trim(String(Player.Account.Header.userName)) = '') then
    exit;
  if (Player.Base.ClientId = 0) then
    exit;
  cid := Player.Base.ClientId;
  if not(Player.xdisconnected) then
  begin
    Player.SaveInGame(Player.SelectedCharacterIndex);
    Player.Destroy;
    Logger.Write('[' + string(ServerList[ChannelId].Name) + ']: O jogador ' +
      string(Player.Account.Header.userName) + ' [ClientId: ' + IntToStr(cid) +
      '] se desconectou.', ConnectionsTraffic);
  end;
  Player.Party := nil;
end;

procedure TServerSocket.Disconnect(userName: string);
var
  i: Integer;
begin
  for i := 1 to (MAX_CONNECTIONS) do
  begin
    if not(Players[i].Base.IsActive) then
      continue;
    if (string(Players[i].Account.Header.userName) = userName) then
    begin
      Players[i].SocketClosed := true;
      Self.Disconnect(Players[i]);
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Send Functions'}

procedure TServerSocket.SendPacketTo(ClientId: Integer; var Packet; Size: WORD;
  Encrypt: Boolean);
begin
  if Self.Players[ClientId].Base.IsActive then
    Self.Players[ClientId].SendPacket(Packet, Size, Encrypt);
end;

procedure TServerSocket.SendSignalTo(ClientId: Integer; pIndex, opCode: WORD);
var
  Signal: TPacketHeader;
begin
  if (ClientId > MAX_CONNECTIONS) or not(Players[ClientId].Base.IsActive) then
    exit;
  ZeroMemory(@Signal, sizeof(TPacketHeader));
  Signal.Size := 12;
  Signal.Index := pIndex;
  Signal.Code := opCode;
  Players[ClientId].SendPacket(Signal, Signal.Size, true);
end;

procedure TServerSocket.SendToVisible(var Base: TBaseMob; var Packet;
  Size: WORD);
var
  i: Integer;
begin
  for i in Base.VisiblePlayers do
  begin
    if Self.Players[i].Status <> Playing then
      continue;
    if (Self.Players[i].SocketClosed) then
      continue;

    Self.SendPacketTo(i, Packet, Size);
  end;
end;

procedure TServerSocket.SendToAll(var Packet; Size: WORD);
var
  i: Integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Status = Playing then
    begin
      if (Self.Players[i].SocketClosed) then
        continue;
      Self.Players[i].SendPacket(Packet, Size);
    end
    else
      continue;
  end;
end;

procedure TServerSocket.SendServerMsg(Mensg: AnsiString; MsgType: Integer = 16;
  Null: Integer = 0; Type2: Integer = 0; SendToSelf: Boolean = true;
  MyClientID: WORD = 0);
var
  i: Integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Status <> Playing then
      continue;
    if (Self.Players[i].SocketClosed) then
      continue;
    if (SendToSelf = false) then
    begin
      if (i = MyClientID) then
        continue;
    end;
    Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end;
end;

procedure TServerSocket.SendServerMsgForNation(Mensg: AnsiString; aNation: BYTE;
  MsgType: Integer = $10; Null: Integer = 0; Type2: Integer = 0;
  SendToSelf: Boolean = true; MyClientID: WORD = 0);
var
  i: Integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Status <> Playing then
      continue;
    if (Self.Players[i].SocketClosed) then
      continue;
    if (SendToSelf = false) then
    begin
      if (i = MyClientID) then
        continue;
    end;
    if (Self.Players[i].Base.Character.Nation = aNation) then
      Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end;
end;
{$ENDREGION}
{$REGION 'PacketControl'}

function TServerSocket.PacketControl(var Player: TPlayer; var Size: Integer;
  var Buffer: array of BYTE; initialOffset: Integer): Boolean;
var
  Header: TPacketHeader;
  Log: String;
  i: Integer;
begin
  ZeroMemory(@Header, sizeof(TPacketHeader));
  Move(Buffer, Header, sizeof(TPacketHeader));
  Header.Index := Player.Base.ClientId;
  Result := true;
  case Header.Code of
    // 0:
    // begin
    // end;
    $320:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UseSkill(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: UseSkill error. msg[' + E.Message + ' : '
            + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          // Player.SocketClosed := True;
        end;
      end;
    $302:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.AttackTarget(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: AttackTarget error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          // Player.SocketClosed := True;
        end;
      end;
    $301:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.MovementCommand(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: MovementCommand error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $70F:
      try
        if (Player.IsInstantiated) then
        begin
          TPacketHandlers.MoveItem(Player, Buffer);
          { if not(TPacketHandlers.MoveItem(Player, Buffer)) then
            begin
            for I := 0 to 63 do
            begin
            Player.Base.SendRefreshItemSlot(INV_TYPE, i, Player.Base.Character.Inventory[i], False);
            end;

            for I := 0 to 15 do
            begin
            Player.Base.SendRefreshItemSlot(EQUIP_TYPE, i, Player.Base.Character.Equip[i], False);
            end;
            end; }
        end;
      except
        on E: Exception do
          Logger.Write('PacketControl: MoveItem error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $31D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UseItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UseItem error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $21B:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UseBuffItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UseBuffItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $305:
      try
        TPacketHandlers.UpdateRotation(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateRotation error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $30F:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.OpenNPC(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenNPC error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31E:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeItemBar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeItemBar error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $668:
      try
        Player.BackToCharList;
      except
        on E: Exception do
          Logger.Write('PacketControl: BackToCharList error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F0B:
      try
        if (Player.LoggedByOtherChannel) then
        begin
          Player.LoggedByOtherChannel := false;
        end
        else
          Player.SendToWorldSends;
      except
        on E: Exception do
          Logger.Write('PacketControl: SendToWorldSends error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F86:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.SendClientSay(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendClientSay error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $20A:
      try
        Player.SendPlayerCash;
      except
        on E: Exception do
          Logger.Write('PacketControl: SendPlayerCash error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $327:
      try
        TPacketHandlers.CancelSkillLaunching(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CancelSkillLaunching error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $202:
      try
        TPacketHandlers.RequestServerTime(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestServerTime error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $207:
      try
        TPacketHandlers.GiveLeaderRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GiveLeaderRaid error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $209:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.BuyItemCash(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyItemCash error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $213:
      try
        TPacketHandlers.GetStatusPoint(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GetStatusPoint error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $21A:
      try
        TPacketHandlers.RenoveItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenoveItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $22A:
      try
        TPacketHandlers.RenoveItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenoveItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $224:
      try
        TPacketHandlers.UnsealItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UnsealItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $22C:
      try
        if not(TPacketHandlers.RequestCharInfo(Player, Buffer)) then
        begin
          Player.SendClientMessage('Alvo n�o est� logado.');
        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: RequestCharInfo error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
        end;
      end;
    $22D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.SendItemChat(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendItemChat error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $303:
      try
        TPacketHandlers.RevivePlayer(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RevivePlayer error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $304:
      try
        TPacketHandlers.UpdateAction(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CharacterActionSend(0x304) error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $307:
      try
        TPacketHandlers.PKMode(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: PKMode error. msg[' + E.Message + ' : ' +
            chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $313:
      try
        TPacketHandlers.BuyNPCItens(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyNPCItens error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $314:
      try
        TPacketHandlers.SellNPCItens(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SellNPCItens error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $315:
      try
        TPacketHandlers.TradeRequest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeRequest error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $316:
      try
        TPacketHandlers.TradeResponse(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeResponse error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $317:
      try
        TPacketHandlers.TradeRefresh(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeRefresh error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $318:
      try
        TPacketHandlers.TradeCancel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TradeCancel error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $319:
      try
        TPacketHandlers.CreatePersonalShop(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreatePersonalShop error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31A:
      try
        TPacketHandlers.OpenPersonalShop(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenPersonalShop error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31B:
      try
        TPacketHandlers.BuyPersonalShopItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyPersonalShopItem error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $31C:
      try
        TPacketHandlers.LearnSkill(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: LearnSkill error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $322:
      try
        TPacketHandlers.SendParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $323:
      try
        TPacketHandlers.AcceptParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AcceptParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $324:
      try
        TPacketHandlers.KickParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: KickParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $325:
      try
        TPacketHandlers.DestroyParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DestroyParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $326:
      try
        TPacketHandlers.PartyAlocateConfig(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: PartyAlocateConfig error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $329:
      try
        TPacketHandlers.RemoveBuff(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RemoveBuff error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32A:
      try
        TPacketHandlers.ResetSkills(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ResetSkills error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32B:
      try
        TPacketHandlers.MakeItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: MakeItem error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32C:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.DeleteItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DeleteItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeItemAttribute(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeItemAttribute error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $32F:
      try
        TPacketHandlers.AbandonQuest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AbandonQuest error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $332:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.AgroupItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AgroupItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $333:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UngroupItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UngroupItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    //$334:
      {try
        TPacketHandlers.RequestEnterDungeon(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end; }
    $336:
      try
        TPacketHandlers.CollectMapItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $338:
      try
        TPacketHandlers.UpdateMemberPosition(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateMemberPosition error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $33A:
      try
        TPacketHandlers.CancelCollectMapItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $340:
      try
        TPacketHandlers.RepairItens(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreateGuild error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $341:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.CreateGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreateGuild error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $342:
      try
        TPacketHandlers.SendRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendRaid error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $343:
      try
        TPacketHandlers.AcceptRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AcceptRaid error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $344:
      try
        TPacketHandlers.ExitRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ExitRaid error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $348:
      try
        TPacketHandlers.CloseNPCOption(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CloseNPCOption error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $34A:
      try
        TPacketHandlers.TeleportSetPosition(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: TeleportSetPosition error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $34B:
      try
        TPacketHandlers.GiveLeaderParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GiveLeaderParty error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    //$355:
{      try
        TPacketHandlers.DungeonLobbyConfirm(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DungeonLobbyConfirm error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;}
    $356:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.SendGift(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendGift error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $359:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ReceiveEventItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ReceiveEventItem error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $361:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.UpdateActiveTitle(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateActiveTitle error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $372:
      try
        TPacketHandlers.AddFriendRequest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddFriendRequest error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $38F:
      try
        TPacketHandlers.AddSelfParty(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddSelfParty error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $395:
      try
        TPacketHandlers.SendRequestDuel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendRequestDuel error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $396:
      try
        TPacketHandlers.DuelResponse(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DuelResponse error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $673:
      try
        TPacketHandlers.AddFriendResponse(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddFriendResponse error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $619:
      try
        TPacketHandlers.ChangeMasterGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: AddFriendResponse error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $67D:
      try
        TPacketHandlers.InviteToGuildAccept(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: InviteToGuildAccept error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $685:
      try
        TPacketHandlers.CheckLogin(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CheckLogin error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $603:
      try
        TPacketHandlers.RequestDeleteChar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestDeleteChar error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $B52:
      try
        TPacketHandlers.RequestUpdateReliquare(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestUpdateReliquare error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $E3A:
      try
        TPacketHandlers.UpdateNationTaxes(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateNationTaxes error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $E51:
      try
        TPacketHandlers.MoveItemToReliquare(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: MoveItemToReliquare error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $F02:
      try
        TPacketHandlers.NumericToken(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: NumericToken error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F05:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeChannel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeChannel error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F06:
      try
        TPacketHandlers.LoginIntoChannel(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: LoginIntoChannel error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $F1C:
      try
        TPacketHandlers.ExitGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ExitGuild error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F1D:
      try
        TPacketHandlers.ChangeGuildMemberRank(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeGuildMemberRank error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F12:
      try
        TPacketHandlers.RequestGuildToAlly(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestGuildAlliance error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F20:
      try
        TPacketHandlers.UpdateGuildNotices(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateGuildNotices error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F21:
      try
        TPacketHandlers.UpdateGuildSite(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateGuildSite error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F22:
      try
        TPacketHandlers.UpdateGuildRanksConfig(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateGuildRanksConfig error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F26:
      try
        TPacketHandlers.SendFriendSay(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendFriendSay error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F2D:
      try
        TPacketHandlers.KickMemberOfGuild(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: KickMemberOfGuild error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F2F:
      try
        TPacketHandlers.CloseGuildChest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CloseGuildChest error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F27:
      try
        TPacketHandlers.OpenFriendWindow(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenFriendWindow error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F30:
      try
        TPacketHandlers.CloseFriendWindow(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CloseFriendWindow error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F34:
      try
        TPacketHandlers.UpdateNationGold(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UpdateNationGold error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F59:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeGold(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeGold error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F74:
      try
        TPacketHandlers.DeleteFriend(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DeleteFriend error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F7B:
      try
        TPacketHandlers.InviteToGuildRequest(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: InviteToGuildRequest error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $F7E:
      try
        TPacketHandlers.InviteToGuildDeny(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: InviteToGuildDeny error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3E01:
      try
        TPacketHandlers.DeleteChar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: DeleteChar error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3E04:
      try
        TPacketHandlers.CreateCharacter(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CreateCharacter error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3E02:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RenamePran(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenamePran error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F15:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.sendCharacterMail(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendCharacterMail error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F16:
      try
        TPacketHandlers.checkSendMailRequirements(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: checkSendMailRequirements error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F17:
      try
        TEntityMail.sendMailList(Player);
      except
        on E: Exception do
          Logger.Write('PacketControl: sendMailList error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F18:
      try
        TPacketHandlers.OpenMail(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: OpenMail error. msg[' + E.Message + ' : '
            + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F1A:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.withdrawMailItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: withdrawMailItem error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F0D:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestAuctionItems(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAuctionItems error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F0B:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestRegisterItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestRegisterItem error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F11:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestOwnAuctionItems(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestOwnAuctionItems error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F10:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestAuctionOfferCancel(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAuctionOfferCancel error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3F0C:
      try
        if (Player.IsInstantiated) then
          TPacketHandlers.RequestAuctionOfferBuy(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAuctionOfferBuy error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $F93A:
      try
        TPacketHandlers.RequestServerPing(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestServerPing error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3E05:
      try
        TPacketHandlers.ReclaimCoupom(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ReclaimCoupom error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
{$REGION 'Packets from GM TOOL'}
    $3202:
      try
        TPacketHandlers.CheckGMLogin(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CheckGMLogin error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3204:
      try
        TPacketHandlers.GMPlayerMove(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMPlayerMove error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3205:
      try
        TPacketHandlers.GMSendChat(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMSendChat error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3206:
      try
        TPacketHandlers.GMGoldManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMGoldManagment error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3207:
      try
        TPacketHandlers.GMCashManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMCashManagment error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3208:
      try
        TPacketHandlers.GMLevelManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMLevelManagment error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3209:
      try
        TPacketHandlers.GMBuffsManagment(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMBuffsManagment error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3210:
      try
        TPacketHandlers.GMDisconnect(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMDisconnect error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3211:
      try
        TPacketHandlers.GMBan(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMBan error. msg[' + E.Message + ' : ' +
            chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3212:
      try
        TPacketHandlers.GMEventItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMEventItem error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3299:
      try
        TPacketHandlers.GMEventItemForAll(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMEventItemForAll error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3214:
      try
        TPacketHandlers.GMRequestServerInformation(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestServerInformation error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $3219:
      try
        TPacketHandlers.GMSendSpawnMob(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMSendSpawnMob error. msg[' + E.Message +
            ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3221:
      Logger.Write('PacketControl: Pacote de backup - removido error.',
        TLogType.Error);

    $3225:
      Logger.Write('PacketControl: Pacote de backup - removido error.',
        TLogType.Error);

    $3229:
      try
        TPacketHandlers.GMRequestCommandsAutoriz(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestCommandsAutoriz error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $322D:
      try
        TPacketHandlers.GMRequestGMUsernames(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestGMUsernames error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3234:
      try
        TPacketHandlers.GMReproveCommand(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMReproveCommand error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3236:
      try
        TPacketHandlers.GMApproveCommand(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMApproveCommand error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;

    $3238:
      try
        TPacketHandlers.GMSendAddEffect(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMSendAddEffect error. msg[' + E.Message
            + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $323A:
      try
        TPacketHandlers.GMRequestCreateCoupom(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestCreateCoupom error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3240:
      try
        TPacketHandlers.GMRequestComprovantSearchID(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestComprovantSearchID error. msg['
            + E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3242:
      try
        TPacketHandlers.GMRequestComprovantSearchName(Player, Buffer);
      except
        on E: Exception do
          Logger.Write
            ('PacketControl: GMRequestComprovantSearchName error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3246:
      try
        TPacketHandlers.GMRequestCreateComprovant(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestCreateComprovant error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $3248:
      try
        TPacketHandlers.GMRequestComprovantValidate(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestComprovantValidate error. msg['
            + E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;

    $324A:
      try
        TPacketHandlers.GMRequestDeletePrans(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GMRequestDeletePrans error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);

      end;
{$ENDREGION}
{$REGION 'Pacotes Aika Other Attributes'}
    $23FE:
      try
        TPacketHandlers.RequestAllAttributes(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAllAttributes error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
    $23FB:
      try
        TPacketHandlers.RequestAllAttributesTarget(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RequestAllAttributesTarget error. msg[' +
            E.Message + ' : ' + chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
            '.', TLogType.Error);
      end;
{$ENDREGION}
  else
    { begin
      Log := '[' + string(ServerList[Player.ChannelIndex].Name) +
      ']: Recv - Code: ' + Format('0x%x', [Header.Code]) + ' / Size: ' +
      IntToStr(Size) + ' / ClientId: ' + IntToStr(Header.index);
      Logger.Write(Log, TLogType.Packets);
      //LogPackets := true;
      end; }
  end;
end;
{$ENDREGION}
{$REGION 'ServerTime'}

function TServerSocket.GetResetTime;
var
  Tomorrow: TDateTime;
begin
  Tomorrow := IncDay(now, 1);
  Result := DateTimeToUnix(IncHour(EncodeDate(YearOf(now), MonthOf(now),
    DayOf(Tomorrow)), 6));
end;

function TServerSocket.CheckResetTime;
begin
  Result := false;
  if (now > Self.ResetTime) then
  begin
    Result := true;
  end;
end;

function TServerSocket.GetEndDayTime;
var
  Tomorrow: TDateTime;
begin
  Tomorrow := IncDay(now, 1);
  Result := DateTimeToUnix(EncodeDate(YearOf(now), MonthOf(now),
    DayOf(Tomorrow)));
end;
{$ENDREGION}
{$REGION 'Players'}

function TServerSocket.GetPlayerByName(Name: string;
  out Player: PPlayer): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := Low(Players) to High(Players) do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Character.Base.Name) = Name) then
    begin
      Player := @Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByName(Name: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Character.Base.Name) = Name) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByUsername(userName: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Account.Header.userName) = userName) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByUsernameAux(userName: string;
  CidAux: WORD): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (string(Self.Players[i].Account.Header.userName) = userName) then
    begin
      if (i = CidAux) then
        continue;
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByCharIndex(CharIndex: DWORD;
  out Player: PPlayer): Boolean;
var
  i: WORD;
begin
  Result := false;
  for i := Low(Players) to High(Players) do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (Self.Players[i].Character.Base.CharIndex = CharIndex) then
    begin
      Player := @Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByCharIndex(CharIndex: DWORD;
  out Player: TPlayer): Boolean;
var
  i: WORD;
begin
  Result := false;
  for i := Low(Players) to High(Players) do
  begin
    if not(Self.Players[i].Base.IsActive) then
      continue;
    if (Self.Players[i].Character.Base.CharIndex = CharIndex) then
    begin
      Player := Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'guild gets'}

function TServerSocket.GetGuildByIndex(GuildIndex: Integer): String;
var
  i: Integer;
begin
  Result := '';
  if (GuildIndex = 0) then
  begin
    exit;
  end;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (Guilds[i].Index = DWORD(GuildIndex)) then
    begin
      Result := String(Guilds[i].Name);
      break;
    end;
  end;
end;

function TServerSocket.GetGuildByName(GuildName: String): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (GuildName = '') then
    exit;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (String(Guilds[i].Name) = GuildName) then
    begin
      Result := Guilds[i].Index;
      break;
    end;
  end;
end;

function TServerSocket.GetGuildSlotByID(GuildIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (GuildIndex = 0) then
    exit;
  for i := Low(Guilds) to High(Guilds) do
  begin
    if (Guilds[i].Index = (GuildIndex)) then
    begin
      Result := Guilds[i].Slot;
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Prans'}

function TServerSocket.GetFreePranClientID(): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(Self.Prans) to High(Self.Prans) do
  begin
    if (Self.Prans[i] = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetFreePetClientID(): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(Self.PETS) to High(Self.PETS) do
  begin
    if (Self.PETS[i].IntName = 0) then
    begin
      Result := i;
      break;
    end;
  end;

end;
{$ENDREGION}
{$REGION 'Temples'}

function TServerSocket.GetFreeTempleSpace(): TSpaceTemple;
var
  i, j: Integer;
begin
  Result.DevirId := 255;
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if (Self.Devires[i].Slots[j].IsAble) then
      begin
        if (Self.Devires[i].Slots[j].ItemID = 0) then
        begin
          Result.DevirId := i;
          Result.SlotID := j;
          break;
        end
        else
          continue;
      end
      else
        continue;
    end;
  end;
end;

function TServerSocket.GetFreeTempleSpaceByIndex(id: Integer): TSpaceTemple;
var
  j: Integer;
begin
  Result.DevirId := 255;
  for j := 0 to 4 do
  begin
    if (Self.Devires[id].Slots[j].IsAble) then
    begin
      if (Self.Devires[id].Slots[j].ItemID = 0) then
      begin
        Result.DevirId := id;
        Result.SlotID := j;
        break;
      end
      else
        continue;
    end
    else
      continue;
  end;
end;

procedure TServerSocket.SaveTemplesDB(Player: PPlayer);
var
  i, j, cnt: Integer;
  FieldNameItemID, FieldNameName, FieldTimeCap, FieldIsAble: String;
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conex�o individual com mysql.[SaveTemplesDB]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveTemplesDB]', TLogType.Error);
    SQLComp.Destroy;
    exit;
  end;
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      FieldNameItemID := 'slot' + IntToStr(j + 1) + '_itemid';
      FieldNameName := 'slot' + IntToStr(j + 1) + '_name';
      FieldTimeCap := 'slot' + IntToStr(j + 1) + '_timecap';
      FieldIsAble := 'slot' + IntToStr(j + 1) + '_able';
      SQLComp.SetQuery(Format('UPDATE devires SET ' + FieldNameItemID + '=%d, '
        + FieldNameName + '=%s, ' + FieldTimeCap + '=%s, ' + FieldIsAble +
        '=%d WHERE devir_id=%d', [Self.Devires[i].Slots[j].ItemID,
        QuotedStr(String(Self.Devires[i].Slots[j].NameCapped)),
        QuotedStr(DateTimeToStr(Self.Devires[i].Slots[j].TimeCapped)),
        Self.Devires[i].Slots[j].IsAble.ToInteger, Self.Devires[i].DevirId]));
      SQLComp.Run(false);
    end;
  end;
  SQLComp.Destroy;
end;

procedure TServerSocket.UpdateReliquaresForAll();
var
  i: WORD;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Players[i].Status >= Playing) then
    begin
      Players[i].SendReliquesToPlayer;
      Players[i].Base.GetCurrentScore;
      Players[i].Base.SendStatus;
      Players[i].Base.SendRefreshPoint;
      Players[i].Base.SendCurrentHPMP();
    end;
  end;
end;

procedure TServerSocket.UpdateReliquareInfosForAll();
var
  i: WORD;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Players[i].Status >= Playing) then
    begin
      Players[i].SendUpdateReliquareInformation(Self.ChannelId);
    end;
  end;
end;

procedure TServerSocket.UpdateReliquareEffects();
var
  i, j: Integer;
begin
  ZeroMemory(@Self.ReliqEffect, sizeof(Self.ReliqEffect));
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if (Self.Devires[i].Slots[j].ItemID <> 0) then
      begin
        Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] :=
          Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]] +
          ItemList[Self.Devires[i].Slots[j].ItemID].EFV[0];
        if (Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF[0]]
          >= 20) then
        begin
          Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF
            [0]] := 50;
        end
        else if (Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF
          [0]] <= 0) then
        begin
          Self.ReliqEffect[ItemList[Self.Devires[i].Slots[j].ItemID].EF
            [0]] := 0;
        end;
      end;
    end;
  end;
end;

{ Servers[Player.ChannelIndex].ReliqEffect[
  ItemList[Count].EF[0]] := Servers[Player.ChannelIndex].ReliqEffect[
  ItemList[Count].EF[0]] + ItemList[Count].EFV[0]; }
function TServerSocket.CanOpenTempleNow(DevirId: BYTE): Boolean;
begin
end;

function TServerSocket.OpenDevir(DevId: Integer; TempID: Integer;
  WhoKilledLast: Integer): Boolean;
var
  PacketDevirSpawn: TSendCreateMobPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  i, rand, SecureId: Integer;
begin
  Result := false;
  Self.Players[WhoKilledLast].SendDevirChange(TempID, $1D);
  for i in Self.Players[WhoKilledLast].Base.VisiblePlayers do
  begin
    Self.Players[i].SendDevirChange(TempID, $1D);
  end;

  Self.Devires[DevId].CollectedReliquare := false;
  Self.Devires[DevId].OpenedThread := TDevirOpennedThread.Create(1000,
    Self.ChannelId, DevId, TempID, SecureId);
end;

function TServerSocket.CloseDevir(DevId: Integer; TempID: Integer;
  WhoGetReliq: Integer): Boolean;
var
  GuardsIds, StonesIds: TIdsArray;
  i: Integer;
begin
  GuardsIds := Self.GetTheGuardsFromDevir(DevId);
  StonesIds := Self.GetTheStonesFromDevir(DevId);
  for i := 0 to 2 do
  begin
    Self.DevirGuards[GuardsIds[i]].DeadTime := StrToDateTime('30/12/1899');
    Self.DevirStones[StonesIds[i]].DeadTime := StrToDateTime('30/12/1899');
    Self.DevirStones[StonesIds[i]].Base.IsDead := false;
    Self.DevirStones[StonesIds[i]].PlayerChar.Base.CurrentScore.CurHP :=
      Self.DevirStones[StonesIds[i]].PlayerChar.Base.CurrentScore.MaxHp;
  end;
  Self.Devires[DevId].OpenTime := StrToDateTime('30/12/1899');
  Self.Devires[DevId].IsOpen := false;
  Self.Devires[DevId].StonesDied := 0;
  Self.Devires[DevId].GuardsDied := 0;
  Self.Devires[DevId].CollectedReliquare := false;

  Self.Players[WhoGetReliq].SendDevirChange(TempID, $10);
  for i in Self.Players[WhoGetReliq].Base.VisiblePlayers do
  begin
    Self.Players[i].SendDevirChange(TempID, $10);
  end;
end;

function TServerSocket.GetTheStonesFromDevir(DevId: Integer): TIdsArray;
begin
  case DevId of
    0:
      begin
        Result[0] := 3340;
        Result[1] := 3345;
        Result[2] := 3350;
      end;
    1:
      begin
        Result[0] := 3341;
        Result[1] := 3346;
        Result[2] := 3351;
      end;
    2:
      begin
        Result[0] := 3342;
        Result[1] := 3347;
        Result[2] := 3352;
      end;
    3:
      begin
        Result[0] := 3343;
        Result[1] := 3348;
        Result[2] := 3353;
      end;
    4:
      begin
        Result[0] := 3344;
        Result[1] := 3349;
        Result[2] := 3354;
      end;
  end;
end;

function TServerSocket.GetTheGuardsFromDevir(DevId: Integer): TIdsArray;
begin
  case DevId of
    0:
      begin
        Result[0] := 3355;
        Result[1] := 3360;
        Result[2] := 3365;
      end;
    1:
      begin
        Result[0] := 3356;
        Result[1] := 3361;
        Result[2] := 3366;
      end;
    2:
      begin
        Result[0] := 3357;
        Result[1] := 3362;
        Result[2] := 3367;
      end;
    3:
      begin
        Result[0] := 3358;
        Result[1] := 3363;
        Result[2] := 3368;
      end;
    4:
      begin
        Result[0] := 3359;
        Result[1] := 3364;
        Result[2] := 3369;
      end;
  end;
end;

function TServerSocket.GetEmptySecureArea(): BYTE;
var
  i: Integer;
begin
  Result := 255;
  for i := 0 to 9 do
  begin
    // if (Self.SecureAreas[i].IsActive = false) then
    // begin
    // Result := i;
    // break;
    // end;
  end;
end;

function TServerSocket.RemoveSecureArea(AreaSlot: BYTE): Boolean;
begin
end;

function TServerSocket.RemoveSecureArea(DevId: Integer): Boolean;
begin
end;

function TServerSocket.RemoveSecureArea(TempID: WORD): Boolean;
begin
end;

function TServerSocket.CreateMapObject(OtherPlayer: PPlayer; OBJID: WORD;
  ContentID: WORD = 0): Boolean;
var
  NewId: WORD;
  newOBJ: POBJ;
  i: WORD;
begin
  if (OtherPlayer = nil) then
    exit;
  NewId := Self.GetFreeObjId;
  if (NewId = 0) then
  begin
    OtherPlayer.SendClientMessage
      ('Erro ao criar o objeto no mapa. ERR_01 Send ticket for support.');
    exit;
  end;
  newOBJ := @Self.OBJ[NewId];
  case OBJID of
    320:
      // item id do bau das rel�quias
      begin
        newOBJ.Index := NewId;
        newOBJ.Position := OtherPlayer.Base.Neighbors[RandomRange(1, 7)].pos;
        newOBJ.ContentType := OBJECT_RELIQUARE;
        newOBJ.ContentAmount := 1;
        newOBJ.ContentCollectTime := 10;
        newOBJ.ContentItemID := ContentID;
        newOBJ.ReSpawn := false;
        newOBJ.CreateTime := now;
        newOBJ.Face := 320;
        newOBJ.NameID := 914;
      end;
    925:
      // item id do bau das rel�quias
      begin
        newOBJ.Index := NewId;
        newOBJ.Position := TPosition.Create(3500,934);
        newOBJ.ContentType := OBJECT_RELIQUARE;
        newOBJ.ContentAmount := 1;
        newOBJ.ContentCollectTime := 10;
        newOBJ.ContentItemID := ContentID;
        newOBJ.ReSpawn := false;
        newOBJ.CreateTime := now;
        newOBJ.Face := 258;
        newOBJ.NameID := 925;
      end;
    325: // item id do bau de itens
      begin
      end;
    331: // item id do bau de gold
      begin
      end;
    332: // item id do bau de evento
      begin
      end;
  else
    begin
      //
    end;
  end;

end;

function TServerSocket.GetFreeObjId(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i := 10148 to 10239 do
  begin
    if (Self.OBJ[i].Index = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TServerSocket.CollectReliquare(Player: PPlayer; Index: WORD);
var
  Packet: TCollectItem;
begin
  ZeroMemory(@Packet, sizeof(TCollectItem));
  Packet.Header.Size := sizeof(TCollectItem);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $336;
  Packet.Index := Index;
  Packet.Time := 10;
  Player.SendPacket(Packet, Packet.Header.Size);
  Player.CollectingReliquare := true;
  Player.CollectingID := Index;
  Player.CollectInitTime := now;
end;

procedure TServerSocket.CollectAltar(Player: PPlayer; Index: WORD);
var
  Packet: TCollectItem;
begin
  ZeroMemory(@Packet, sizeof(TCollectItem));
  Packet.Header.Size := sizeof(TCollectItem);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $336;
  Packet.Index := Index;
  Packet.Time := 10;
  Player.SendPacket(Packet, Packet.Header.Size);
  Player.CollectingAltar := true;
  Player.CollectingID := Index;
  Player.CollectInitTime := now;
end;
{$ENDREGION}

end.
