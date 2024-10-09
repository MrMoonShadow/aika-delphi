unit BaseMob;

interface

{$O+}

uses
  Windows, PlayerData, Diagnostics, Generics.Collections, Packets, SysUtils,
  MiscData, AnsiStrings, FilesData, Math, TlHelp32;
{$OLDTYPELAYOUT ON}

type
  TPrediction = record
    ETA: Single;
    Timer: { TDateTime; } TStopwatch;
    Source: TPosition;
    Destination: TPosition;
    function CanPredict: Boolean;
    function Elapsed: Integer;
    function Delta: Single;
    function Interpolate(out d: Single): TPosition;
    procedure Create; overload;
    procedure CalcETA(speed: Byte);
  end;

type
  PBaseMob = ^TBaseMob;

  TBaseMob = record
  private
    _prediction: TPrediction;
    _cooldown: TDictionary<WORD, TTime>;
    // _currentPosition: TPosition;
    procedure AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
    procedure RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
  public
    _buffs: TDictionary<WORD, TDateTime>;
    IsDead: Boolean;
    ClientID: WORD;
    PranClientID: WORD;
    PetClientID: WORD;
    Character: PCharacter;
    PlayerCharacter: TPlayerCharacter;
    AttackSpeed: WORD;
    IsActive: Boolean;
    IsDirty: Boolean;
    IsMotherStone: Boolean;
    Mobbaby: WORD;
    PartyId: WORD;
    PartyRequestId: WORD;
    VisibleMobs: TList<WORD>;
    VisibleNPCS: TList<WORD>;
    VisiblePlayers: TList<WORD>;
    TimeForGoldTime: TDateTime;
    VisibleTargets: Array of TMobTarget;
    VisibleTargetsCnt: WORD; // aqui vai ser o controle da lista propia
    LastTimeGarbaged: TDateTime;
    target: PBaseMob;
    IsRaioSolar: Boolean;
    IsResetRaioSolar: Boolean;
    IsDungeonMob: Boolean;
    InClastleVerus: Boolean;
    LastReceivedSkillFromCastle: TDateTime;
    PositionSpawnedInCastle: TPosition;
    NationForCastle: Byte;
    NpcIdGen: WORD;
    NpcQuests: Array [0 .. 7] of TQuestMisc;
    PersonalShopIndex: DWORD;
    PersonalShop: TPersonalShopData;
    MOB_EF: ARRAY [0 .. 395] OF Integer;
    EQUIP_CONJUNT: ARRAY [0 .. 15] OF WORD;
    EFF_5: Array [0 .. 2] of WORD; // podemos ter at� 3 efeitos 5
    IsPlayerService: Boolean;
    ChannelId: Byte;
    Neighbors: Array [0 .. 8] of TNeighbor;
    EventListener: Boolean;
    EventAction: Byte;
    EventSkillID: WORD;
    EventSkillEtc1: WORD;
    HPRListener: Boolean; // HPR = HP Recovery
    HPRAction: Byte;
    HPRSkillID: WORD;
    HPRSkillEtc1: WORD;
    SKDListener: Boolean; // SKD = Skill Damage
    SKDAction: Byte;
    SKDSkillID: WORD;
    SKDTarget: WORD;
    SKDSkillEtc1: WORD;
    SKDIsMob: Boolean;
    SDKMobID, SDKSecondIndex: WORD;
    Mobid: WORD;
    MobDbId: WORD;
    SecondIndex: WORD;
    IsBoss: Boolean;
    { Skill }
    LastBasicAttack: TDateTime;
    LastAttackMsg: TDateTime;
    AttackMsgCount: Integer;
    UsingSkill: WORD;
    ResolutoPoints: Byte;
    ResolutoTime: TDateTime;
    DefesaPoints: Byte;
    DefesaPoints2: Byte;
    BolhaPoints: Byte;
    LaminaID: WORD;
    LaminaPoints: WORD;
    Polimorfed: Boolean;
    UsingLongSkill: Boolean;
    LongSkillTimes: WORD;
    UniaoDivina: String;
    SessionOnline: Boolean;
    SessionUsername: String;
    SessionMasterPriv: TMasterPrives;
    MissCount: WORD;
    NegarCuraCount: Integer;
    RevivedTime: TDateTime;
    CurrentAction: Integer;
    LastSplashTime: TDateTime;

    ActiveTitle: Integer;
    LastReceivedAttack: TDateTime;
    LastMovedTime: TDateTime;
    LastMovedMessageHack: TDateTime;
    AttacksAccumulated, AttacksReceivedAccumulated: Integer;
    DroppedCount: Integer;
    { TBaseMob }
    procedure Create(characterPointer: PCharacter; Index: WORD;
      ChannelId: Byte); overload;
    procedure Destroy(Aux: Boolean = False);
    function IsPlayer: Boolean;
    procedure UpdateVisibleList(SpawnType: Byte = 0);
    // function CurrentPosition: TPosition;
    procedure SetDestination(const Destination: TPosition);
    procedure addvisible(m: TBaseMob);
    procedure removevisible(m: TBaseMob);
    procedure AddHP(Value: Integer; ShowUpdate: Boolean);
    procedure AddMP(Value: Integer; ShowUpdate: Boolean);
    procedure RemoveHP(Value: Integer; ShowUpdate: Boolean;
      StayOneHP: Boolean = False);
    procedure RemoveMP(Value: Integer; ShowUpdate: Boolean);
    procedure WalkinTo(Pos: TPosition);
    procedure SetEquipEffect(const Equip: TItem; SetType: Integer;
      ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
    procedure SetConjuntEffect(Index: Integer; SetType: Integer);
    procedure ConfigEffect(Count, ConjuntId: Integer; SetType: Integer);
    procedure SetOnTitleActiveEffect();
    procedure SetOffTitleActiveEffect();
    function MatchClassInfo(ClassInfo: Byte): Boolean;
    function IsCompleteEffect5(out CountEffects: Byte): Boolean;
    function SearchEmptyEffect5Slot(): Byte;
    function GetSlotOfEffect5(CallID: WORD): Byte;
    procedure LureMobsInRange();
    { Send's }
    procedure SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True; Polimorf: WORD = 0);
    procedure SendRemoveMob(delType: Integer = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True);
    procedure SendToVisible(var Packet; size: WORD; sendToSelf: Boolean = True);
    procedure SendPacket(var Packet; size: WORD);
    procedure SendRefreshLevel;
    procedure SendCurrentHPMP(Update: Boolean = False);
    procedure SendCurrentHPMPMob();
    procedure SendStatus;
    procedure SendRefreshPoint;
    procedure SendRefreshKills;
    procedure SendEquipItems(SendSelf: Boolean = True);
    procedure SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
      Notice: Boolean); overload;
    procedure SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean); overload;
    procedure SendSpawnMobs;
    procedure GenerateBabyMob;
    procedure UngenerateBabyMob(ungenEffect: WORD);
    function AddTargetToList(target: PBaseMob): Boolean;
    function RemoveTargetFromList(target: PBaseMob): Boolean;
    function ContainsTargetInList(target: PBaseMob; out id: WORD)
      : Boolean; overload;
    function ContainsTargetInList(ClientID: WORD): Boolean; overload;
    function ContainsTargetInList(ClientID: WORD; out id: WORD)
      : Boolean; overload;
    function GetEmptyTargetInList(out Index: WORD): Boolean;
    function GetTargetInList(ClientID: WORD): PBaseMob;
    function ClearTargetList(): Boolean;
    function TargetGarbageService(): Boolean;
    { Get's }
    procedure GetCreateMob(out Packet: TSendCreateMobPacket;
      P1: WORD = 0); overload;
    class function GetMob(Index: WORD; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static;
    class function GetMob(Index: WORD; Channel: Byte; out mob: PBaseMob)
      : Boolean; overload; static;
    { class function GetMob(Pos: TPosition; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static; }
    function GetMobAbility(eff: Integer): Integer;
    procedure IncreasseMobAbility(eff: Integer; Value: Integer);
    procedure DecreasseMobAbility(eff: Integer; Value: Integer);
    function GetCurrentHP(): DWORD;
    function GetCurrentMP(): DWORD;
    function GetRegenerationHP(): DWORD;
    function GetRegenerationMP(): DWORD;
    function GetEquipedItensHPMPInc: DWORD;
    function GetEquipedItensDamageReduce: DWORD;
    function GetMobClass(ClassInfo: Integer = 0): Integer;
    procedure GetCurrentScore;
    procedure GetEquipDamage(const Equip: TItem);
    procedure GetEquipDefense(const Equip: TItem);
    procedure GetEquipsDefense;
    { Buffs }
    function RefreshBuffs: Integer;
    procedure SendRefreshBuffs;
    procedure SendAddBuff(BuffIndex: WORD);
    procedure AddBuffEffect(Index: WORD);
    procedure RemoveBuffEffect(Index: WORD);
    function GetBuffToRemove(): DWORD;
    function GetDeBuffToRemove(): DWORD;
    function GetDebuffCount(): WORD;
    function GetBuffCount(): WORD;
    procedure RemoveBuffByIndex(Index: WORD);
    function GetBuffSameIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByID(BuffID: DWORD): Boolean;
    function BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
    function BuffExistsSopa(): Boolean;
    function GetBuffIDByIndex(Index: DWORD): WORD;
    procedure RemoveBuffs(Quant: Byte);
    procedure RemoveDebuffs(Quant: Byte);
    procedure ZerarBuffs();
    { Attack & Skills }
    procedure CheckCooldown(var Packet: TSendSkillUse);
    function CheckCooldown2(SkillID: DWORD): Boolean;
    procedure SendCurrentAllSkillCooldown();
    function AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
      AddTime: Boolean = False; TimeAditional: Integer = 0): Boolean;
    function AddBuffWhenEntering(BuffIndex: Integer;
      BuffTime: TDateTime): Boolean;
    function GetBuffSlot(BuffIndex: WORD): Integer;
    function GetEmptyBuffSlot(): Integer;
    function RemoveBuff(BuffIndex: WORD): Boolean;
    procedure RemoveAllDebuffs();

    procedure SendDamage(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData);
    function GetDamage(Skill: DWORD; mob: PBaseMob; out DnType: TDamageType;
      AditionalCrit: Integer = 0): UInt64;
    function GetDamageType3(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob;
      AditionalCrit: Integer = 0): TDamageType;
    procedure CalcAndCure(Skill: DWORD; mob: PBaseMob; ExtraHeal: Integer = 0);
    function CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
    function CalcCure2(BaseCure: DWORD; mob: PBaseMob;
      xSkill: Integer = 0): Integer;
    procedure HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
      SelectedPos: TPosition; DataSkill: P_SkillData);
    function ValidAttack(DmgType: TDamageType; DebuffType: Byte = 0;
      mob: PBaseMob = nil; AuxDano: Integer = 0;
      xisBoss: Boolean = False): Boolean;
    procedure MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
      out DroppedItem: Boolean; InParty: Boolean = False);
    procedure DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob;
      maxDropCount: Integer = 1);
    procedure PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
    { Parses }
    procedure SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob; Pos: TPosition);
    procedure TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure TargetSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
      Packet: TRecvDamagePacket);
    procedure AreaSkill(Skill, Anim: DWORD; mob: PBaseMob; SkillPos: TPosition;
      DataSkill: P_SkillData; DamagePerc: Single = 0; ElThymos: Integer = 0);
    procedure AttackParse(Skill, Anim: DWORD; mob: PBaseMob; var Dano: Integer;
      var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte;
      DataSkill: P_SkillData);
    procedure AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob;
      var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
      out MobAnimation: Byte);
    procedure Effect5Skill(mob: PBaseMob; EffCount: Byte;
      xPassive: Boolean = False);
    function IsSecureArea(): Boolean;
    { Effect Functions }
    procedure SendEffect(EffectIndex: DWORD);
    { Move/Teleport }
    procedure Teleport(Pos: TPosition); overload;
    procedure Teleport(Posx, Posy: WORD); overload;
    procedure Teleport(Posx, Posy: string); overload;
    procedure WalkTo(Pos: TPosition; speed: WORD = 70; MoveType: Byte = 0);
    procedure WalkAvanced(Pos: TPosition; SkillID: Integer);
    procedure WalkBacked(Pos: TPosition; SkillID: Integer; mob: PBaseMob);
    { Pets }
    procedure CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD = 0);
    procedure DestroyPet(PetID: WORD);
    { Warrior }
    procedure WarriorSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure WarriorAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean; out MoveToTarget: Boolean);
    procedure WarriorTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure WarriorSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      Pos: TPosition);
    { Rifleman }
    procedure RiflemanSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure RiflemanAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure RiflemanTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure RiflemanSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      Pos: TPosition);
    { Magician }
    procedure MagicianSkill(Skill, Anim: DWORD; DataSkill: P_SkillData;
      out defender: PBaseMob; out Dano: Integer; out DmgType: TDamageType;
      out CanDebuff: Boolean; out Resisted: Boolean);
    procedure MagicianAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure MagicianSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      Pos: TPosition);
    procedure MagicianTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure BlackMagicianShieldMPCostFactor(BuffIndex: DWORD;
      out Fator: System.Double);
    { Templar }
    procedure TemplarSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure TemplarAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure TemplarSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      Pos: TPosition);
    procedure TemplarTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    { Dual Gunner }
    procedure DualGunnerSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure DualGunnerAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure DualGunnerSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      Pos: TPosition);
    procedure DualGunnerTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    { Cleric }
    procedure ClericSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure ClericAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
      out Resisted: Boolean);
    procedure ClericSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      Pos: TPosition);
    procedure ClericTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);

  end;
{$REGION 'HP / MP Increment por level'}

const
  HPIncrementPerLevel: array [0 .. 5] of Integer = (101, // 126 War
    130, // 150 Tp
    77, // 96 Att
    74, // 93 Dual
    84, // 105 Fc
    78 // 98 Santa
    );

const
  MPIncrementPerLevel: array [0 .. 5] of Integer = (76, // 95 War
    80, // 100 Tp
    48, // 60 Att
    96, // 120 Dual
    160, // 200 Fc
    120 // 150 Santa
    );
{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

uses
  Player, GlobalDefs, Util, Log, ItemFunctions, Functions, DateUtils, mob, PET,
  PartyData, Objects, PacketHandlers, Attributes, ItemConjuntFunctions,
  UpdateThreads;
{$REGION 'TBaseMob'}

procedure TBaseMob.Destroy(Aux: Boolean);
begin
  Self.IsActive := Aux;
  FreeAndNil(VisibleMobs);
  FreeAndNil(VisibleNPCS);
  FreeAndNil(VisiblePlayers);
  FreeAndNil(_cooldown);
  FreeAndNil(_buffs);
  Servers[Self.ChannelId].Prans[Self.PranClientID] := 0;
  Self.ClearTargetList();
  Self.Character := nil; // talvez essa seja a solu��o do back char list
  Self.target := nil;
  Self.IsBoss := False;
  ZeroMemory(@Self, sizeof(TBaseMob));
end;

procedure TBaseMob.Create(characterPointer: PCharacter; Index: WORD;
  ChannelId: Byte);
begin
  ZeroMemory(@Self, sizeof(TBaseMob));
  VisibleMobs := TList<WORD>.Create;
  VisibleNPCS := TList<WORD>.Create;
  VisiblePlayers := TList<WORD>.Create;
  SetLength(VisibleTargets, 1);
  LastTimeGarbaged := Now;
  LastAttackMsg := Now;
  LastBasicAttack := Now;
  AttackMsgCount := 0;
  AttacksAccumulated := 0;
  DroppedCount := 0;
  AttacksReceivedAccumulated := 0;
  IsActive := True;
  IsDirty := False;
  IsRaioSolar := False;
  IsResetRaioSolar := False;
  LastReceivedSkillFromCastle := Now;
  InClastleVerus := False;
  Character := characterPointer;
  ClientID := index;
  Self.ChannelId := ChannelId;
  RevivedTime := Now;
  LastSplashTime := Now;
  if ((index >= 2048) and (index <= 3047)) then
  begin
    Self.NpcIdGen := index - 2047;
  end;
  // _prediction.Create;
  _cooldown := TDictionary<WORD, TTime>.Create;
  _buffs := TDictionary<WORD, TDateTime>.Create(40);
end;

function TBaseMob.IsPlayer: Boolean;
begin
  Result := IfThen(ClientID <= MAX_CONNECTIONS);
end;

procedure TBaseMob.UpdateVisibleList(SpawnType: Byte = 0);
var
  i: WORD;
  npcMob: PBaseMob;
  Packet: TSendRemoveMobPacket;
  OtherPlayer: PPlayer;
  PacketDevirSpawn: TSendCreateMobPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  xObj: POBJ;
begin
  IsDirty := False;
  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
    Exit;
  for i := Low(Servers[Self.ChannelId].Players)
    to High(Servers[Self.ChannelId].Players) do
  begin
    OtherPlayer := @Servers[Self.ChannelId].Players[i];
    if (OtherPlayer^.Status < Playing) then
    begin
      Continue;
    end;
    if (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
        Continue;
      Self.AddToVisible(OtherPlayer^.Base);
      if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      begin
        OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
      end;
      if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      begin
        OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran1.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(0,
          OtherPlayer^.Base.ClientID, 0);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran2.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn(1,
          OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else
    begin
      if not(Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
        Continue;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran1.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(0,
          OtherPlayer^.Base.ClientID);
      end;
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Account.Header.Pran2.IsSpawned) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(1,
          OtherPlayer^.Base.ClientID);
      end;
      if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      begin
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      end;
      if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      begin
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);
      end;
      Self.RemoveFromVisible(OtherPlayer^.Base);
      if (OtherPlayer^.Base.IsActive = False) then
      begin
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
  if (Servers[Self.ChannelId].Players[Self.ClientID].IsInstantiated) then
    for i := Low(Servers[Self.ChannelId].NPCs)
      to High(Servers[Self.ChannelId].NPCs) do
    begin
      if (Servers[Self.ChannelId].NPCs[i].Base.ClientID = 0) then
        Continue;
      // cid := Servers[Self.ChannelId].NPCs[i].Base.ClientId;
      npcMob := @Servers[Self.ChannelId].NPCs[i].Base;
      if (Self.PlayerCharacter.LastPos.InRange(npcMob^.PlayerCharacter.LastPos,
        DISTANCE_TO_WATCH)) then
      begin
        if (Self.VisibleNPCS.Contains(npcMob^.ClientID)) then
          Continue;
        Self.VisibleNPCS.Add(npcMob^.ClientID);
        npcMob^.SendCreateMob(SPAWN_NORMAL, Self.ClientID, False);
      end
      else
      begin
        if not(Self.VisibleNPCS.Contains(npcMob^.ClientID)) then
          Continue;
        Self.VisibleNPCS.Remove(npcMob^.ClientID);
        ZeroMemory(@Packet, sizeof(Packet));
        Packet.Header.size := sizeof(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := npcMob^.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  for i := Low(Servers[Self.ChannelId].DevirNPC)
    to High(Servers[Self.ChannelId].DevirNPC) do
  begin
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirNPC[i]
      .PlayerChar.LastPos, (DISTANCE_TO_WATCH))) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Add(i);
      ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));
      PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
      PacketDevirSpawn.Header.Index := i;
      PacketDevirSpawn.Header.Code := $349;
      Move(Servers[Self.ChannelId].DevirNPC[i].PlayerChar.Base.Name,
        PacketDevirSpawn.Name[0], 16);
      PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirSpawn.Position := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.LastPos;
      PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;
      if (Servers[Self.ChannelId].Devires[i - 3335].IsOpen) then
      begin
        PacketDevirSpawn.ItemEff[0] := $35;
      end;
      PacketDevirSpawn.Altura := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirSpawn.Tronco := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirSpawn.Perna := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirSpawn.Corpo := Servers[Self.ChannelId].DevirNPC[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.EffectType := $1;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.Unk0 := $28;
      Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);

      if (PacketDevirSpawn.ItemEff[0] = $35) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendDevirChange(i, $1D);
      end;
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Remove(i);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].DevirGuards)
    to High(Servers[Self.ChannelId].DevirGuards) do
  begin
    if (Servers[Self.ChannelId].DevirGuards[i].Base.IsDead) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirGuards
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Add(i);
      Self.AddTargetToList(@Servers[Self.ChannelId].DevirGuards[i].Base);
      ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
      PacketDevirMobsSpawn.Header.size := sizeof(TSpawnMobPacket);
      PacketDevirMobsSpawn.Header.Index := i;
      PacketDevirMobsSpawn.Header.Code := $35E;
      PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirMobsSpawn.Equip[6] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Equip[6].Index;
      PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.LastPos;
      PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.CurHP;
      PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.Level :=
        (Servers[Self.ChannelId].DevirGuards[i].PlayerChar.Base.Level + 1) * 13;
      if (Self.Character <> nil) then
        if (Self.Character.Nation = Servers[Self.ChannelId].DevirGuards[i]
          .PlayerChar.Base.Nation) then
        begin // aqui o player � da na��o do guarda, n�o dispon�vel para atacar.
          PacketDevirMobsSpawn.IsService := True;
        end
        else
        begin // aqui � dispon�vel atacar
          PacketDevirMobsSpawn.IsService := False;
        end;
      PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.DuploAtk;
      PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirMobsSpawn.MobType := 0;
      PacketDevirMobsSpawn.MobName :=
        StrToInt(String(Servers[Self.ChannelId].DevirGuards[i]
        .PlayerChar.Base.Name));
      Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      // Servers[Self.ChannelId].DevirGuards[i].Base.SendCreateMob(SPAWN_NORMAL,
      // Self.ClientID, False);
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirGuards[i].Base);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].DevirStones)
    to High(Servers[Self.ChannelId].DevirStones) do
  begin
    if (Servers[Self.ChannelId].DevirStones[i].Base.IsDead) then
      Continue;
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirStones
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Add(i);
      Self.AddTargetToList(@Servers[Self.ChannelId].DevirStones[i].Base);
      ZeroMemory(@PacketDevirMobsSpawn, sizeof(TSpawnMobPacket));
      PacketDevirMobsSpawn.Header.size := sizeof(TSpawnMobPacket);
      PacketDevirMobsSpawn.Header.Index := i;
      PacketDevirMobsSpawn.Header.Code := $35E;
      PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.LastPos;
      PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.Equip[0].Index;
      PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.CurHP;
      PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
      PacketDevirMobsSpawn.Level :=
        (Servers[Self.ChannelId].DevirStones[i].PlayerChar.Base.Level + 1) * 13;
      if (Self.Character <> nil) then
        if (Self.Character.Nation = Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.Nation) then
        begin // aqui o player � da na��o do guarda, n�o dispon�vel para atacar.
          PacketDevirMobsSpawn.IsService := True;
        end
        else
        begin // aqui � dispon�vel atacar
          PacketDevirMobsSpawn.IsService := False;
        end;
      PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.DuploAtk;
      PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;
      PacketDevirMobsSpawn.MobType := 1;
      PacketDevirMobsSpawn.MobName :=
        StrToInt(String(Servers[Self.ChannelId].DevirStones[i]
        .PlayerChar.Base.Name));
      Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      // Servers[Self.ChannelId].DevirStones[i].Base.SendCreateMob(SPAWN_NORMAL,
      // Self.ClientID, False);
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;
      Self.VisibleNPCS.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirStones[i].Base);
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].OBJ)
    to High(Servers[Self.ChannelId].OBJ) do
  begin
    if not(Servers[Self.ChannelId].OBJ[i].Index = 0) then
    begin
      xObj := @Servers[Self.ChannelId].OBJ[i];
      if (xObj.Position.InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH))
      then
      begin
        if not(Self.VisibleMobs.Contains(xObj.Index)) then
        begin
          Self.VisibleMobs.Add(xObj.Index);
          ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));
          PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
          PacketDevirSpawn.Header.Index := i;
          PacketDevirSpawn.Header.Code := $349;
          System.AnsiStrings.StrPLCopy(PacketDevirSpawn.Name,
            IntToStr(xObj.NameID), sizeof(IntToStr(xObj.NameID)));
          PacketDevirSpawn.Equip[0] := xObj.Face;
          PacketDevirSpawn.Equip[6] := xObj.Weapon;
          PacketDevirSpawn.Position := xObj.Position;
          PacketDevirSpawn.MaxHP := 100000;
          PacketDevirSpawn.MaxMP := 100000;
          PacketDevirSpawn.CurHP := 100000;
          PacketDevirSpawn.CurMP := 100000;
          PacketDevirSpawn.Altura := 7;
          PacketDevirSpawn.Tronco := 119;
          PacketDevirSpawn.Perna := 119;
          PacketDevirSpawn.Corpo := 1;
          PacketDevirSpawn.IsService := 1;
          if (xObj.Face = 320) then
            System.AnsiStrings.StrPLCopy(PacketDevirSpawn.Title,
              ItemList[xObj.ContentItemID].Name,
              sizeof(PacketDevirSpawn.Title));
          Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
        end;
      end
      else
      begin
        if (Self.VisibleMobs.Contains(Servers[Self.ChannelId].OBJ[i].Index))
        then
        begin
          Self.VisibleMobs.Remove(Servers[Self.ChannelId].OBJ[i].Index);
          ZeroMemory(@Packet, sizeof(Packet));
          Packet.Header.size := sizeof(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := i;
          Self.SendPacket(Packet, Packet.Header.size);
        end;
      end;
    end;
  end;

  for i := Low(Servers[Self.ChannelId].CastleObjects)
    to High(Servers[Self.ChannelId].CastleObjects) do
  begin
    if (Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
      .CastleObjects[i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
    begin
      if (Self.VisibleNPCS.Contains(i)) then
        Continue;

      Self.VisibleNPCS.Add(i);

      ZeroMemory(@PacketDevirSpawn, sizeof(TSendCreateMobPacket));

      PacketDevirSpawn.Header.size := sizeof(TSendCreateMobPacket);
      PacketDevirSpawn.Header.Index := i;
      PacketDevirSpawn.Header.Code := $349;

      Move(Servers[Self.ChannelId].CastleObjects[i].PlayerChar.Base.Name,
        PacketDevirSpawn.Name[0], 16);

      PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.Equip[0].Index;

      PacketDevirSpawn.Position := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.LastPos;

      PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.MaxHP;
      PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
      PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;

      PacketDevirSpawn.Altura := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Altura;
      PacketDevirSpawn.Tronco := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Tronco;
      PacketDevirSpawn.Perna := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Perna;
      PacketDevirSpawn.Corpo := Servers[Self.ChannelId].CastleObjects[i]
        .PlayerChar.Base.CurrentScore.Sizes.Corpo;

      PacketDevirSpawn.EffectType := $1;
      PacketDevirSpawn.IsService := 1;
      PacketDevirSpawn.Unk0 := $28;

      Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
    end
    else
    begin
      if not(Self.VisibleNPCS.Contains(i)) then
        Continue;

      Self.VisibleNPCS.Remove(i);

      ZeroMemory(@Packet, sizeof(Packet));

      Packet.Header.size := sizeof(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;

      Packet.Index := i;

      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TBaseMob.AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
begin
  if (Self.IsPlayer) then
  begin
    if not(VisiblePlayers.Contains(mob.ClientID)) then
    begin
      // spawn de mobs é aqui haha
      VisiblePlayers.Add(mob.ClientID);
      mob.AddToVisible(Self);
      mob.SendCreateMob(SPAWN_NORMAL, Self.ClientID, False);

      if not(Self.AddTargetToList(@mob)) then
      begin
        Logger.Write('N�o foi poss�vel adicionar alvo na lista de targets.',
          TLogType.Error);
      end;
    end;
  end
  else
  begin
    if (mob.IsPlayer) then
    begin
      VisiblePlayers.Add(mob.ClientID);
      if not(mob.VisiblePlayers.Contains(Self.ClientID)) then
      begin
        mob.VisiblePlayers.Add(Self.ClientID);
      end;
    end;
  end;
end;

procedure TBaseMob.RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
begin
  try
    if ((mob.IsActive = False) or (mob.ClientID = 0)) then
      Exit;
    if (Self.IsActive = False) then
      Exit;
    VisiblePlayers.Remove(mob.ClientID);
    if (Self.IsPlayer) then
      mob.SendRemoveMob(0, Self.ClientID);
    if (mob.VisiblePlayers.Contains(Self.ClientID)) then
    begin
      mob.RemoveFromVisible(Self);
      mob.RemoveTargetFromList(@Self);
    end;
    Self.RemoveTargetFromList(@mob);
    if (target <> NIL) AND (target.ClientID = mob.ClientID) then
      target := NIL;
  except
    on E: Exception do
    begin
      Logger.Write('Error at removefromvisible: ' + E.Message, TLogType.Error);
    end;
  end;
end;

function TBaseMob.AddTargetToList(target: PBaseMob): Boolean;
var
  id, id2: WORD;
begin
  Result := False;
  try
    if not(ContainsTargetInList(target.ClientID, id2)) then
    begin
      VisibleTargetsCnt := Length(VisibleTargets) + 1;
      SetLength(VisibleTargets, VisibleTargetsCnt);
      if (GetEmptyTargetInList(id)) then
      begin
        VisibleTargets[id].ClientID := target.ClientID;

        case target.ClientID of
          1 .. 1000:
            begin
              VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
              VisibleTargets[id].Player := target;
              VisibleTargets[id].TargetType := 0;
            end;
          1001 .. 3339, 3370 .. 9147:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].MOBS.TMobS
                [target.Mobid].MobsP[target.SecondIndex]
                .Base.PlayerCharacter.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3340 .. 3354:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirStones
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3355 .. 3369:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirGuards
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
        end;
        Result := True;
      end
      else
      begin
        VisibleTargetsCnt := Length(VisibleTargets) + 1;
        SetLength(VisibleTargets, VisibleTargetsCnt);
        id := VisibleTargetsCnt - 1;
        VisibleTargets[id].ClientID := target.ClientID;

        case target.ClientID of
          1 .. 1000:
            begin
              VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
              VisibleTargets[id].Player := target;
              VisibleTargets[id].TargetType := 0;
            end;
          1001 .. 3339, 3370 .. 9147:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].MOBS.TMobS
                [target.Mobid].MobsP[target.SecondIndex]
                .Base.PlayerCharacter.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3340 .. 3354:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirStones
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3355 .. 3369:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirGuards
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
        end;
        Result := True;
      end;
    end
    else
    begin
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('AddTargetToList: ' + E.Message, TLogType.Error);
    end;
  end;
end;

function TBaseMob.RemoveTargetFromList(target: PBaseMob): Boolean;
var
  id: WORD;
begin
  Result := False;
  if (ContainsTargetInList(target, id)) then
  begin
    VisibleTargets[id].ClientID := 0;
    VisibleTargets[id].TargetType := 0;
    VisibleTargets[id].Position.x := 0;
    VisibleTargets[id].Position.y := 0;
    VisibleTargets[id].Player := nil;
    VisibleTargets[id].mob := nil;
    dec(VisibleTargetsCnt, 1);
    Result := True;
  end;
end;

function TBaseMob.ContainsTargetInList(target: PBaseMob; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if (Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    if (VisibleTargets[i].ClientID = target.ClientID) then
    begin
      id := i;
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.ContainsTargetInList(ClientID: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if (Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;

  if (Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      Result := True;
      id := i;
      break;
    end;
  end;
end;

function TBaseMob.GetEmptyTargetInList(out Index: WORD): Boolean;
var
  i: WORD;
begin
  Result := False;
  if (Length(Self.VisibleTargets) > 0) then
  begin
    for i := Low(VisibleTargets) to High(VisibleTargets) do
    begin
      if (VisibleTargets[i].ClientID > 0) then
        Continue;

      Index := i;
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.GetTargetInList(ClientID: WORD): PBaseMob;
var
  i: WORD;
begin
  Result := nil;

  if (Length(VisibleTargets) = 0) then
  begin
    Exit;
  end;

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    if (VisibleTargets[i].ClientID = ClientID) then
    begin
      case VisibleTargets[i].TargetType of
        0:
          Result := PBaseMob(VisibleTargets[i].Player);
        1:
          Result := PBaseMob(VisibleTargets[i].mob);
      end;
      break;
    end;
  end;
end;

function TBaseMob.ClearTargetList(): Boolean;
var
  i: WORD;
begin
  Result := False;

  if (Length(VisibleTargets) = 0) then
  begin
    VisibleTargetsCnt := 0;

    Result := True;
    Exit;
  end;

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    VisibleTargets[i].ClientID := 0;
    VisibleTargets[i].TargetType := 0;
    VisibleTargets[i].Position.x := 0;
    VisibleTargets[i].Position.y := 0;
    VisibleTargets[i].Player := nil;
    VisibleTargets[i].mob := nil;
  end;
  SetLength(VisibleTargets, 0);
  /// ///
  VisibleTargetsCnt := 0;

  Result := True;
end;

function TBaseMob.TargetGarbageService(): Boolean;
var
  OtherList: Array of TMobTarget;
  i, cnt, cnt2, id, id2: WORD;
begin
  cnt := 0;
  Result := False;

  if (Length(VisibleTargets) = 0) then
  begin
    Result := True;
    Exit;
  end;

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    if (VisibleTargets[i].TargetType = 0) then
    begin
      if (VisibleTargets[i].Player = nil) then
        Continue;
      if ((VisibleTargets[i].ClientID > 0) and
        not(PBaseMob(VisibleTargets[i].Player).IsDead)) then
      begin
        Inc(cnt, 1);
        SetLength(OtherList, cnt);
        id := (cnt - 1);
        OtherList[id].ClientID := VisibleTargets[i].ClientID;
        OtherList[id].TargetType := VisibleTargets[i].TargetType;
        OtherList[id].Position := VisibleTargets[i].Position;
        OtherList[id].Player := VisibleTargets[i].Player;
        OtherList[id].mob := VisibleTargets[i].mob;
      end;
      VisibleTargets[i].ClientID := 0;
      VisibleTargets[i].TargetType := 0;
      VisibleTargets[i].Position.x := 0;
      VisibleTargets[i].Position.y := 0;
      VisibleTargets[i].Player := nil;
      VisibleTargets[i].mob := nil;
    end
    else if (VisibleTargets[i].TargetType = 1) then
    begin
      if (VisibleTargets[i].mob = nil) then
        Continue;

      if ((VisibleTargets[i].ClientID > 0) and
        not(PBaseMob(VisibleTargets[i].mob).IsDead)) then
      begin
        Inc(cnt, 1);
        SetLength(OtherList, cnt);
        id := (cnt - 1);
        OtherList[id].ClientID := VisibleTargets[i].ClientID;
        OtherList[id].TargetType := VisibleTargets[i].TargetType;

        case VisibleTargets[i].ClientID of
          2001 .. 3339, 3370 .. 9147:
            begin
              OtherList[id].Position := Servers[Self.ChannelId].MOBS.TMobS
                [PBaseMob(VisibleTargets[i].mob).Mobid].MobsP
                [PBaseMob(VisibleTargets[i].mob).SecondIndex]
                .Base.PlayerCharacter.LastPos;
            end;
          3340 .. 3354:
            begin
              OtherList[id].Position := Servers[Self.ChannelId].DevirStones
                [PBaseMob(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
            end;
          3355 .. 3369:
            begin
              OtherList[id].Position := Servers[Self.ChannelId].DevirGuards
                [PBaseMob(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
            end;
        end;

        OtherList[id].Position := VisibleTargets[i].Position;
        OtherList[id].Player := VisibleTargets[i].Player;
        OtherList[id].mob := VisibleTargets[i].mob;
      end;
      VisibleTargets[i].ClientID := 0;
      VisibleTargets[i].TargetType := 0;
      VisibleTargets[i].Position.x := 0;
      VisibleTargets[i].Position.y := 0;
      VisibleTargets[i].Player := nil;
      VisibleTargets[i].mob := nil;
    end;
  end;
  SetLength(VisibleTargets, 0);
  VisibleTargetsCnt := 0;
  cnt2 := 0;
  if (cnt > 0) then
  begin
    for i := 0 to Length(OtherList) - 1 do
    begin
      Inc(cnt2, 1);
      SetLength(VisibleTargets, cnt2);
      id2 := (cnt2 - 1);
      VisibleTargets[id2].ClientID := OtherList[i].ClientID;
      VisibleTargets[id2].TargetType := OtherList[i].TargetType;
      VisibleTargets[id2].Position := OtherList[i].Position;
      VisibleTargets[id2].Player := OtherList[i].Player;
      VisibleTargets[id2].mob := OtherList[i].mob;
    end;
    Result := True;
  end;
end;

procedure TBaseMob.SetDestination(const Destination: TPosition);
begin
  _prediction.Source := PlayerCharacter.LastPos;
  if (_prediction.Source = Destination) then
    Exit;
  _prediction.Timer.Stop;
  _prediction.Timer.Reset;
  _prediction.Timer.Start;
  _prediction.Destination := Destination;
  _prediction.CalcETA(PlayerCharacter.SpeedMove);
end;

procedure TBaseMob.addvisible(m: TBaseMob);
begin
  Self.AddToVisible(m);
end;

procedure TBaseMob.removevisible(m: TBaseMob);
begin
  Self.RemoveFromVisible(m);
end;

procedure TBaseMob.AddHP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
  begin
    Inc(Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
      .HP, Value);
    Self.SendCurrentHPMP(ShowUpdate);
    Exit;
  end;
  Inc(Self.Character.CurrentScore.CurHP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseMob.AddMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  Inc(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseMob.RemoveHP(Value: Integer; ShowUpdate: Boolean;
  StayOneHP: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) then
  begin
    deccardinal(Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP, Value);
    if (StayOneHP) then
    begin
      if (Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
        .HP = 0) then
        Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
          [Self.SecondIndex].HP := 1;
    end;
    ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
    Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
    Packet.Header.Code := $103; // AIKA
    Packet.Header.Index := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].Index;
    if (ShowUpdate) then
      Packet.Null := 1;
    Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
    Packet.MaxMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
    Packet.CurHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP;
    Packet.CurMP := Packet.MaxMP;

    Self.SendToVisible(Packet, Packet.Header.size, False);
    Exit;
  end;
  deccardinal(Self.Character.CurrentScore.CurHP, Value);

  if (Self.Character.CurrentScore.CurHP <=
    Trunc((Self.Character.CurrentScore.MaxHP / 100) * 50)) then
  begin
    Self.RemoveBuffByIndex(108);
  end;

  if (StayOneHP) then
  begin
    if (Self.Character.CurrentScore.CurHP = 0) then
      Self.Character.CurrentScore.CurHP := 1;
  end;
  Self.SendCurrentHPMP(ShowUpdate);

  if (Self.BuffExistsByIndex(134)) then
    if (Self.Character.CurrentScore.CurHP <
      (Self.Character.CurrentScore.MaxHP div 2)) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('Cura preventiva entrou em a��o e feiti�o foi desfeito.', 0);
      Self.RemoveBuffByIndex(134);
    end;

  if (Self.Character.CurrentScore.CurHP = 0) then
  begin
    Self.SendCurrentHPMP();
    Self.SendEffect($0);
    Exit;
  end;
end;

procedure TBaseMob.RemoveMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  deccardinal(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseMob.WalkinTo(Pos: TPosition);
begin
  Self.WalkTo(Pos, 70);
end;

procedure TBaseMob.SetEquipEffect(const Equip: TItem; SetType: Integer;
  ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
var
  i, ResultOf, EmptySlot: Integer;
begin
  if (ItemList[Equip.Index].ItemType = 10) then
    Exit;

  if (VerifyExpired) then
  begin
    if ((ItemList[Equip.Index].Expires) and not(Equip.IsSealed)) then
    begin
      ResultOf := CompareDateTime(Now, Equip.ExpireDate);
      if (ResultOf = 1) then
      begin
        Exit;
      end
      else if ((Equip.Time = $FFFF) and (TItemFunctions.GetItemEquipSlot(Equip.
        Index) = 9)) then
        Exit;
    end;
  end;

  if (Conjuntos[Equip.Index] > 0) and (ChangeConjunt) then
    SetConjuntEffect(Equip.Index, SetType);
  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            Inc(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            Inc(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);
        end;

        if (ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := SearchEmptyEffect5Slot();
          if not(EmptySlot = 255) then
            Self.EFF_5[EmptySlot] := ItemList[Equip.Index].MeshIDEquip;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            dec(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            dec(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);
        end;

        if (ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := GetSlotOfEffect5(ItemList[Equip.Index].MeshIDEquip);
          if not(EmptySlot = 255) then
            Self.EFF_5[EmptySlot] := 0;
        end;
      end;
    SAME_ITEM_TYPE:
      begin
        // Alterar apenas os atributos de acordo com o refine;
      end;
  end;
end;

procedure TBaseMob.SetConjuntEffect(Index: Integer; SetType: Integer);
var
  CfgEffect: Integer;
begin
  if Index = 0 then
    Exit;
  Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] :=
    Conjuntos[Index];
  CfgEffect := TItemFunctions.GetConjuntCount(Self, Index);
  case CfgEffect of
    3:
      ConfigEffect(3, Conjuntos[Index], SetType);
    4:
      ConfigEffect(4, Conjuntos[Index], SetType);
    5:
      ConfigEffect(5, Conjuntos[Index], SetType);
    6:
      ConfigEffect(6, Conjuntos[Index], SetType);
  end;
  if SetType = DESEQUIPING_TYPE then
    Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] := 0;
end;

procedure TBaseMob.ConfigEffect(Count: Integer; ConjuntId: Integer;
  SetType: Integer);
var
  i: Integer;
  EmptySlot: Byte;
begin
  EmptySlot := 255;
  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 5 do
        begin
          if SetItem[ConjuntId].EffSlot[i] <> Count then
            Continue;
          Inc(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := SearchEmptyEffect5Slot();
            if (EmptySlot = 255) then
              Continue;
            Self.EFF_5[EmptySlot] := SetItem[ConjuntId].EFV[i];
          end;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 5 do
        begin
          if SetItem[ConjuntId].EffSlot[i] <> Count then
            Continue;
          dec(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := GetSlotOfEffect5(SetItem[ConjuntId].EFV[i]);
            if (EmptySlot = 255) then
              Continue;
            Self.EFF_5[EmptySlot] := 0;
          end;
        end;
      end;
  end;
end;

procedure TBaseMob.SetOnTitleActiveEffect();
var
  i: Integer;
begin
  if (Self.PlayerCharacter.ActiveTitle.Index > 0) then
  begin
    for i := 0 to 2 do
    begin
      if (Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level - 1].EF[i] = 0) then
        Continue;

      Self.IncreasseMobAbility(Titles[Self.PlayerCharacter.ActiveTitle.Index]
        .TitleLevel[Self.PlayerCharacter.ActiveTitle.Level - 1].EF[i],
        Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level - 1].EFV[i]);
    end;
  end;
end;

procedure TBaseMob.SetOffTitleActiveEffect();
var
  i: Integer;
begin
  if (Self.PlayerCharacter.ActiveTitle.Index > 0) then
  begin
    for i := 0 to 2 do
    begin
      if (Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level - 1].EF[i] = 0) then
        Continue;

      Self.DecreasseMobAbility(Titles[Self.PlayerCharacter.ActiveTitle.Index]
        .TitleLevel[Self.PlayerCharacter.ActiveTitle.Level - 1].EF[i],
        Titles[Self.PlayerCharacter.ActiveTitle.Index].TitleLevel
        [Self.PlayerCharacter.ActiveTitle.Level - 1].EFV[i]);
    end;
  end;
end;

function TBaseMob.MatchClassInfo(ClassInfo: Byte): Boolean;
begin
  Result := (Self.GetMobClass = Self.GetMobClass(ClassInfo));
end;

function TBaseMob.IsCompleteEffect5(out CountEffects: Byte): Boolean;
var
  i: Byte;
begin
  Result := False;
  for i := 0 to 2 do
  begin
    if (EFF_5[i] > 0) then
    begin
      Inc(CountEffects);
      Result := True;
    end;
  end;
end;

function TBaseMob.SearchEmptyEffect5Slot(): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (Self.EFF_5[i] = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TBaseMob.GetSlotOfEffect5(CallID: WORD): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (Self.EFF_5[i] = CallID) then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TBaseMob.LureMobsInRange;
var
  i: Integer;
begin
  for i := Low(Self.VisibleTargets) to High(Self.VisibleTargets) do
  begin
    if (Self.VisibleTargets[i].TargetType = 1) then
    begin
      if (Servers[Self.ChannelId].MOBS.TMobS
        [PBaseMob(Self.VisibleTargets[i].mob).Mobid].MobsP
        [PBaseMob(Self.VisibleTargets[i].mob).SecondIndex].CurrentPos.Distance
        (Self.PlayerCharacter.LastPos) <= 8) then
      begin
        if (not(Servers[Self.ChannelId].MOBS.TMobS
          [PBaseMob(Self.VisibleTargets[i].mob).Mobid].MobsP
          [PBaseMob(Self.VisibleTargets[i].mob).SecondIndex].isGuard) and
          (Servers[Self.ChannelId].MOBS.TMobS[PBaseMob(Self.VisibleTargets[i]
          .mob).Mobid].MobsP[PBaseMob(Self.VisibleTargets[i].mob).SecondIndex]
          .isAggressive)) then
        begin
          if not(Servers[Self.ChannelId].MOBS.TMobS
            [PBaseMob(Self.VisibleTargets[i].mob).Mobid].MobsP
            [PBaseMob(Self.VisibleTargets[i].mob).SecondIndex].IsAttacked) then
          begin
            Servers[Self.ChannelId].MOBS.TMobS
              [PBaseMob(Self.VisibleTargets[i].mob).Mobid].MobsP
              [PBaseMob(Self.VisibleTargets[i].mob).SecondIndex]
              .IsAttacked := True;
            Servers[Self.ChannelId].MOBS.TMobS
              [PBaseMob(Self.VisibleTargets[i].mob).Mobid].MobsP
              [PBaseMob(Self.VisibleTargets[i].mob).SecondIndex].AttackerID :=
              Self.ClientID;
            Servers[Self.ChannelId].MOBS.TMobS
              [PBaseMob(Self.VisibleTargets[i].mob).Mobid].MobsP
              [PBaseMob(Self.VisibleTargets[i].mob).SecondIndex]
              .FirstPlayerAttacker := Self.ClientID;
          end;
        end;
      end;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Sends'}

procedure TBaseMob.SendToVisible(var Packet; size: WORD; sendToSelf: Boolean);
var
  i: WORD;
  xPlayer: PPlayer;
begin
  sendToSelf := IfThen(sendToSelf, IsPlayer, False);
  if (sendToSelf) then
    Self.SendPacket(Packet, size);
  if (Self.ClientID <= 3048) then
  begin
    for i in VisiblePlayers do
    begin
      try
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status >= Playing) then
          xPlayer.SendPacket(Packet, size);
      except
        Continue;
      end;
    end;
  end
  else
  begin
    for i in VisibleMobs do
    begin
      try
        if (i > MAX_CONNECTIONS) then
          Continue; // new
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status >= Playing) then
          xPlayer.SendPacket(Packet, size);
      except
        Continue;
      end;
    end;
  end;
end;

procedure TBaseMob.SendPacket(var Packet; size: WORD);
begin
  Servers[ChannelId].SendPacketTo(ClientID, Packet, size);
end;

procedure TBaseMob.SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
  SendSelf: Boolean = True; Polimorf: WORD = 0);
var
  Packet: TSendCreateMobPacket;
  Packet2: TSpawnMobPacket;
  PacketAct: TSendActionPacket;
  RlkSlot: Byte;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));

  if (Polimorf > 0) then
  begin
    // Self.SendRemoveMob(0, 0, False);

    ZeroMemory(@Packet2, sizeof(Packet2));

    Packet2.Header.size := sizeof(Packet2);
    Packet2.Header.Code := $35E;
    Packet2.Header.Index := Self.ClientID;

    Packet2.Position := Self.PlayerCharacter.LastPos;
    Packet2.Rotation := Self.PlayerCharacter.Rotation;
    Packet2.CurHP := Self.Character.CurrentScore.CurHP;
    Packet2.CurMP := Self.Character.CurrentScore.CurMP;
    Packet2.MaxHP := Self.Character.CurrentScore.MaxHP;
    Packet2.MaxMP := Self.Character.CurrentScore.MaxMP;

    Packet2.Level := Self.Character.Level;
    Packet2.SpawnType := 0;

    // Packet2.Unk_0 := $0A;

    Packet2.Equip[0] := Polimorf;
    Packet2.Equip[1] := Polimorf;
    Packet2.Equip[6] := 0;
    Packet2.Equip[7] := 0;
    Packet2.Altura := 7;
    Packet2.Tronco := 119;
    Packet2.Perna := 119;
    Packet2.Corpo := 0;
    Packet2.IsService := False;
    Packet2.MobType := 1;
    Packet2.Nation := Self.Character.Nation;
    Packet2.MobName := $7535;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet2, Packet2.Header.size)
    else
    begin
      Self.SendPacket(Packet2, Packet2.Header.size);

      for i in Self.VisiblePlayers do
      begin
        if (Servers[Self.ChannelId].Players[i].Base.Character.Nation = Self.
          Character.Nation) then
        begin
          Packet2.Nation := 0;
        end
        else
        begin
          Packet2.Nation := Self.Character.Nation;
        end;

        Servers[Self.ChannelId].Players[i].SendPacket(Packet2,
          Packet2.Header.size);
      end;

      // Self.SendToVisible(Packet2, Packet2.Header.size, SendSelf);
    end;
  end
  else
  begin
    if (Self.PlayerCharacter.PlayerKill) then
      Inc(SpawnType, $80);

    Self.GetCreateMob(Packet, sendTo);
    Packet.SpawnType := SpawnType;

    if (Self.InClastleVerus) then
    begin
      Packet.GuildIndexAndNation := Self.NationForCastle * 4096;
    end;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size)
    else
      Self.SendToVisible(Packet, Packet.Header.size, SendSelf);

    if (Self.ClientID <= MAX_CONNECTIONS) then
    begin
      RlkSlot := TItemFunctions.GetItemSlotByItemType
        (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
      if (RlkSlot <> 255) then
      begin
        Self.SendEffect(32);
      end;
    end;

    if ((Self.CurrentAction <> 0) and (sendTo > 0)) then
    begin
      ZeroMemory(@PacketAct, sizeof(PacketAct));

      PacketAct.Header.size := sizeof(PacketAct);
      PacketAct.Header.Index := Self.ClientID;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Self.CurrentAction;
      PacketAct.InLoop := 1;

      Servers[Self.ChannelId].SendPacketTo(sendTo, PacketAct,
        PacketAct.Header.size);
    end
    else if (Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction <> 0)
    then
    begin
      ZeroMemory(@PacketAct, sizeof(PacketAct));

      PacketAct.Header.size := sizeof(PacketAct);
      PacketAct.Header.Index := sendTo;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Servers[Self.ChannelId].Players[sendTo]
        .Base.CurrentAction;
      if (Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction = 65) then
        PacketAct.InLoop := 1;

      Self.SendPacket(PacketAct, PacketAct.Header.size);
    end;
  end;

  { if (Polimorf > 0) then
    begin
    Self.SendCurrentHPMP(True);
    end; }

end;

procedure TBaseMob.SendRemoveMob(delType: Integer = DELETE_NORMAL;
  sendTo: WORD = 0; SendSelf: Boolean = True);
var
  Packet: TSendRemoveMobPacket;
  mob: TBaseMob;
  i: WORD;
begin
  Packet.Header.size := sizeof(TSendRemoveMobPacket);
  Packet.Header.Code := $101; // aika
  Packet.Header.Index := $7535;
  Packet.Index := Self.ClientID;
  Packet.DeleteType := delType;
  if (SendSelf) and (Self.IsPlayer) then
  begin
    Self.SendPacket(Packet, Packet.Header.size);
  end;
  if (sendTo = 0) then
  begin
    SendToVisible(Packet, Packet.Header.size, SendSelf);
  end
  else
  begin
    Servers[ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size);
    Exit;
  end;
  for i in VisiblePlayers do
  begin
    if (GetMob(i, ChannelId, mob)) then
      RemoveFromVisible(mob);
  end;
  VisiblePlayers.Clear;
end;

procedure TBaseMob.SendRefreshLevel;
var
  Packet: TSendCurrentLevel;
begin
  if (Self.ClientID >= 3048) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendCurrentLevel));
  Packet.Header.size := sizeof(TSendCurrentLevel);
  Packet.Header.Code := $108; // AIKA
  Packet.Header.Index := ClientID;
  Packet.Level := Character.Level - 1;
  Packet.Unk := $CC;
  Packet.Exp := Character.Exp;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendCurrentHPMP(Update: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
  Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;
  Character.CurrentScore.MaxHP := Self.GetCurrentHP;
  Character.CurrentScore.MaxMP := Self.GetCurrentMP;
  if Character.CurrentScore.CurHP > Character.CurrentScore.MaxHP then
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;
  if Character.CurrentScore.CurMP > Character.CurrentScore.MaxMP then
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;
  Packet.CurHP := Character.CurrentScore.CurHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.CurMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;
  if (Update) then
    Packet.Null := 1;
  SendToVisible(Packet, Packet.Header.size);
  Sleep(1);
end;

procedure TBaseMob.SendCurrentHPMPMob();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.IsDungeonMob) then
    Exit;

  if (Self.Mobid = 0) then
    Exit;

  ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));

  Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;

  Packet.CurHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
    [Self.SecondIndex].HP;
  Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
  Packet.CurMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
    [Self.SecondIndex].HP;
  Packet.MaxMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;

  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendStatus;
var
  Packet: TSendRefreshStatus;
  temp_buff: Array [0 .. 12] of Byte;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  // Self.GetCurrentScore;
  ZeroMemory(@Packet, $2C);
  Packet.Header.size := $2C;
  Packet.Header.Code := $10A; // AIKA
  Packet.Header.Index := $7535;
  Packet.DNFis := PlayerCharacter.Base.CurrentScore.DNFis;
  Packet.DEFFis := PlayerCharacter.Base.CurrentScore.DEFFis;
  Packet.DNMAG := PlayerCharacter.Base.CurrentScore.DNMAG;
  Packet.DEFMAG := PlayerCharacter.Base.CurrentScore.DEFMAG;
  Packet.SpeedMove := PlayerCharacter.SpeedMove;
  Packet.Critico := PlayerCharacter.Base.CurrentScore.Critical;
  Packet.Esquiva := PlayerCharacter.Base.CurrentScore.Esquiva;
  Packet.Acerto := PlayerCharacter.Base.CurrentScore.Acerto;
  Packet.Duplo := PlayerCharacter.DuploAtk;
  Packet.Resist := PlayerCharacter.Resistence;
  SendPacket(Packet, Packet.Header.size);
  ZeroMemory(@temp_buff, 12);
  TPacketHandlers.RequestAllAttributes(Servers[Self.ChannelId].Players
    [Self.ClientID], temp_buff);
end;

procedure TBaseMob.SendRefreshPoint;
var
  Packet: TSendRefreshPoint;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  ZeroMemory(@Packet, sizeof(TSendRefreshPoint));
  Packet.Header.size := sizeof(TSendRefreshPoint);
  Packet.Header.Code := $109; // AIKA
  Packet.Header.Index := $7535;
  Move(PlayerCharacter.Base.CurrentScore, Packet.Pontos, sizeof(Packet.Pontos));
  Packet.SkillsPoint := Self.Character.CurrentScore.SkillPoint;
  Packet.StatusPoint := Self.Character.CurrentScore.Status;
  SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendRefreshKills;
var
  Packet: TUpdateHonorAndKills;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $12A;
  Packet.Honor := Self.Character.CurrentScore.Honor;
  Packet.Kills := Self.Character.CurrentScore.KillPoint;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendEquipItems(SendSelf: Boolean = True);
// var
// packet: TRefreshEquips;
// x: Byte;
// sItem: TItem;
// effValue: Byte;
begin
end;

procedure TBaseMob.SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
  Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
  Packet3: TRefreshItemPranPacket;
begin
  case SlotType of
    INV_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Inventory[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.Time := Item.Time;
              Packet2.Item.MIN := Item.MIN;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Equip[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    STORAGE_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players
          [Self.ClientID].Account.Header.Storage.Itens[SlotItem].Index) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, sizeof(Packet2));
              Packet2.Header.size := sizeof(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, sizeof(Packet3));
              Packet3.Header.size := sizeof(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;
              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;
              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            ZeroMemory(@Packet, sizeof(Packet));
            Packet.Header.size := sizeof(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
  else
    begin
      ZeroMemory(@Packet, sizeof(Packet));
      Packet.Header.size := sizeof(TRefreshItemPacket);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $F0E;
      Packet.Notice := Notice;
      Packet.TypeSlot := SlotType;
      Packet.Slot := SlotItem;
      Packet.Item := Item;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TBaseMob.SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
begin
  if not(TItemFunctions.GetItemEquipSlot(Self.Character.Inventory[SlotItem].
    Index) = 9) then
  begin
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(TRefreshItemPacket);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $F0E;
    Packet.Notice := Notice;
    Packet.TypeSlot := $1;
    Packet.Slot := SlotItem;
    Packet.Item := Self.Character.Inventory[SlotItem];
    Self.SendPacket(Packet, Packet.Header.size);
  end
  else
  begin
    ZeroMemory(@Packet2, sizeof(Packet2));
    Packet2.Header.size := sizeof(Packet2);
    Packet2.Header.Index := $7535;
    Packet2.Header.Code := $F0E;
    Packet2.Notice := Notice;
    Packet2.TypeSlot := $1;
    Packet2.Slot := SlotItem;
    Packet2.Item.Index := Self.Character.Inventory[SlotItem].Index;
    Packet2.Item.APP := Self.Character.Inventory[SlotItem].APP;
    Packet2.Item.Slot1 := Self.Character.Inventory[SlotItem].Effects.Index[0];
    Packet2.Item.Slot2 := Self.Character.Inventory[SlotItem].Effects.Index[1];
    Packet2.Item.Slot3 := Self.Character.Inventory[SlotItem].Effects.Index[2];
    Packet2.Item.Enc1 := Self.Character.Inventory[SlotItem].Effects.Value[0];
    Packet2.Item.Enc2 := Self.Character.Inventory[SlotItem].Effects.Value[1];
    Packet2.Item.Enc3 := Self.Character.Inventory[SlotItem].Effects.Value[2];
    Packet2.Item.Time := Self.Character.Inventory[SlotItem].Time;
    Self.SendPacket(Packet2, Packet2.Header.size);
  end;
end;

procedure TBaseMob.SendSpawnMobs;
var
  i: Integer;
begin
  for i in Self.VisibleMobs do
  begin
    if (i = 0) OR (i = Self.ClientID) then
    begin
      Exit;
    end;
    if (i <= MAX_CONNECTIONS) then
    begin
      // Servers[ChannelId].Players[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end
    else
    begin
      // NPCs[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end;
  end;
end;

procedure TBaseMob.GenerateBabyMob;
// var pos: TPosition; i, j: BYTE; mIndex, id: WORD;
// party : PParty;
// var
// babyId, babyClientId: WORD;
// party : PParty;
// i, j: Byte;
// pos: TPosition;
begin
end;

procedure TBaseMob.UngenerateBabyMob(ungenEffect: WORD);
// evok pode ser usado pra skill de att
// var pos: TPosition; i,j: BYTE; party : PParty; find: boolean;
begin
end;
{$ENDREGION}
{$REGION 'Gets'}

procedure TBaseMob.GetCreateMob(out Packet: TSendCreateMobPacket; P1: WORD);
type
  A = record
    hi, lo: Byte;
  end;
var
  i, j, k: Integer;
  Index: WORD;
  Count, Count2: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := ClientID;
  Packet.Header.Code := $349;
  Packet.Rotation := PlayerCharacter.Rotation;
  Move(Character^.Name, Packet.Name[0], 16);
  Packet.Equip[0] := Character^.Equip[0].Index;
  Packet.Equip[1] := Character^.Equip[1].Index;
  for i := 2 to 7 do
  begin
    if (Character^.Equip[i].APP = 0) or not(Self.IsPlayer) then
    begin
      Packet.Equip[i] := Character^.Equip[i].Index;
      Continue;
    end;
    Packet.Equip[i] := Character^.Equip[i].APP;
  end;
  Packet.SpeedMove := Self.PlayerCharacter.SpeedMove;
  Packet.MaxHP := Character^.CurrentScore.MaxHP;
  Packet.MaxMP := Character^.CurrentScore.MaxHP;
  if Self.IsPlayer then
  begin
    Packet.MaxHP := Self.GetCurrentHP;
    Packet.MaxMP := Self.GetCurrentMP;
    Packet.TitleId := Self.ActiveTitle;
    Packet.Unk0 := $0A;
    Packet.Effects[1] := $1D;
    Packet.GuildIndexAndNation := Character^.Nation * 4096;
    if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex) > 0 then
    begin
      AnsiStrings.StrPCopy(Packet.Title,
        AnsiString(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.GuildSlot].Name));
      Packet.GuildIndexAndNation :=
        StrToInt('$' + IntToStr(Character.Nation) +
        IntToHex(Servers[Self.ChannelId].Players[Self.ClientID]
        .Character.Base.GuildIndex, 3));
    end;
  end
  else
  begin
    Packet.EffectType := $1;
    Packet.IsService := 1;
    Packet.Unk0 := $28;
    if (Self.ClientID <= 3047) then
      AnsiStrings.StrPCopy(Packet.Title,
        AnsiString(Servers[ChannelId].NPCs[Self.ClientID]
        .NPCFile.Header.Title));
  end;
  Packet.ItemEff[7] := Character^.Equip[6].Refi div 16;
  Packet.Position := PlayerCharacter.LastPos;
  Packet.CurHP := Character^.CurrentScore.CurHP;
  Packet.CurMP := Character^.CurrentScore.CurMP;
  if Packet.CurHP > Packet.MaxHP then
    Packet.CurHP := Packet.MaxHP;
  if Packet.CurMP > Packet.MaxMP then
    Packet.CurMP := Packet.MaxMP;
  Packet.Altura := Character^.CurrentScore.Sizes.Altura;
  Packet.Tronco := Character^.CurrentScore.Sizes.Tronco;
  Packet.Perna := Character^.CurrentScore.Sizes.Perna;
  Packet.Corpo := Character^.CurrentScore.Sizes.Corpo;
  Packet.TitleId := Self.PlayerCharacter.ActiveTitle.Index;
  Packet.TitleLevel := Self.PlayerCharacter.ActiveTitle.Level - 1;
  if (PersonalShop.Index > 0) and (PersonalShop.Name <> '') then
  begin
    AnsiStrings.StrCopy(Packet.Title, Self.PersonalShop.Name);
    Packet.Corpo := 3;
    Packet.EffectType := 2;
  end;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      SkillData[Index].Duration));
    Inc(i);
  end;
  if ((Self.ClientID >= 2048) and (Self.ClientID <= 3047)) then
  begin // isso aqui � s� por conta do s�mbolo quest
    Packet.EffectType := 0;

    for i := Low(Self.NpcQuests) to High(Self.NpcQuests) do
    begin
      if (Self.NpcQuests[i].QuestID = 0) then
        Continue;
      if (Self.NpcQuests[i].LevelMin > Servers[Self.ChannelId].Players[P1]
        .Base.Character.Level) then
      begin
        if (Packet.EffectType = 0) then
          Packet.EffectType := 07;
        Continue;
      end;
      { Verificar se a quest ja foi completa }
      Count := 0;
      Count2 := 0;
      for k := Low(Servers[Self.ChannelId].Players[P1].PlayerQuests)
        to High(Servers[Self.ChannelId].Players[P1].PlayerQuests) do
      begin
        if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
          .Quest.QuestID = Self.NpcQuests[i].QuestID) then
        begin
          for j := 0 to 4 do
          begin
            if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
              .Quest.RequirimentsAmount[j] = 0) then
              Continue
            else
              Inc(Count2);

            if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Complete[j]
              >= Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
              .Quest.RequirimentsAmount[j]) then
            begin
              if not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
                .Complete[j] = 0) then
                Inc(Count);
            end;
          end;
          if (not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].IsDone))
          then
          begin
            if (Count = Count2) then
            begin
              Packet.EffectType := 4;
            end
            else
            begin
              Packet.EffectType := 3;
            end;
          end
          else
          begin
            { if(Count = Count2) then
              begin
              Packet.EffectType := 4;
              end
              else
              begin
              Packet.EffectType := 3;
              end; }
            if (Packet.EffectType <> 4) or (Packet.EffectType <> 3) then
              Packet.EffectType := Self.NpcQuests[i].QuestMark
            else
            begin
              if (Count = Count2) then
              begin
                Packet.EffectType := 4;
              end
              else
              begin
                Packet.EffectType := 3;
              end;
            end;
          end;
        end;
      end;

      if ((Packet.EffectType = 4) or (Packet.EffectType = 3)) then
        break;

      Packet.EffectType := Self.NpcQuests[i].QuestMark;
    end;
  end;
end;

class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: TBaseMob): Boolean;
begin
  Result := False;
  if (index = 0) OR (index > MAX_SPAWN_ID) then
  begin
    Exit;
  end;
  if (index > MAX_CONNECTIONS) then
    // mob := Servers[Channel].Players[index].Base
    // else
    mob := Servers[Channel].NPCs[index].Base
  else
    Exit;
  if mob.Character = nil then
    Exit;
  Result := mob.IsActive;
end;

{
  class function TBaseMob.GetMob(Pos: TPosition; Channel: Byte;
  out mob: TBaseMob): Boolean;
  begin
  Result := GetMob(Servers[Channel].MobGrid[Round(Pos.Y)][Round(Pos.X)],
  Channel, mob);
  end; }
class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: PBaseMob): Boolean;
begin
  if (index = 0) then
  begin
    Result := False;
    Exit;
  end;
  if (index <= MAX_CONNECTIONS) then
    mob := @Servers[Channel].Players[index].Base
  else
    mob := @Servers[Channel].NPCs[index].Base;
  Result := mob.IsActive;
end;

function TBaseMob.GetMobAbility(eff: Integer): Integer;
begin
  Result := Self.MOB_EF[eff];
end;

procedure TBaseMob.IncreasseMobAbility(eff: Integer; Value: Integer);
begin
  if (eff = 226) then
  begin
    Inc(Self.MOB_EF[73], Value);
  end
  else
  begin
    Inc(Self.MOB_EF[eff], Value);
  end;
end;

procedure TBaseMob.DecreasseMobAbility(eff: Integer; Value: Integer);
begin
  if (Value < 0) then
  begin
    Value := Value * (-1);
    Inc(Self.MOB_EF[eff], Value);
  end
  // fear n�o est� adicionando efeito correto, alterado para stun
  else if (eff = 226) then
  begin // se o efeito a ser removido � o fear, ent�o remove um stun
    decInt(Self.MOB_EF[73], Value);
  end
  else
    decInt(Self.MOB_EF[eff], Value); // mexi aqui nesse decint
end;

function TBaseMob.GetCurrentHP(): DWORD;
var
  hp_inc, hp_lvl, hp_equip: Integer;
  hp_perc: DWORD;
  HpCalc: Integer;
begin
  hp_inc := GetMobAbility(EF_HP);
  hp_lvl := Round(HPIncrementPerLevel[GetMobClass(Character.ClassInfo)] *
    Character.Level);
  hp_equip := Self.GetEquipedItensHPMPInc;
  hp_perc := GetMobAbility(EF_PER_HP) + GetMobAbility(EF_MARSHAL_PER_HP) +
    Servers[ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];

  TAttributeFunctions.GetHP(PlayerCharacter.Base.CurrentScore, HpCalc);
  Inc(HpCalc, hp_inc);
  Inc(HpCalc, hp_lvl);
  Inc(HpCalc, hp_equip);
  Inc(HpCalc, HpCalc * (hp_perc div 100));

  if (HpCalc <= 0) then
    HpCalc := 1;
  Result := HpCalc;
end;

function TBaseMob.GetCurrentMP(): DWORD;
var
  mp_inc, mp_lvl, mp_equip: Integer;
  mp_perc: DWORD;
  MpCalc: Integer;
begin
  mp_inc := GetMobAbility(EF_MP);
  mp_lvl := Round(MPIncrementPerLevel[GetMobClass(Character.ClassInfo)] *
    Character.Level);
  mp_equip := Self.GetEquipedItensHPMPInc;
  mp_perc := GetMobAbility(EF_PER_MP) + GetMobAbility(EF_MARSHAL_PER_MP) +
    Servers[ChannelId].ReliqEffect[EF_RELIQUE_PER_MP];

  TAttributeFunctions.GetMP(PlayerCharacter.Base.CurrentScore, MpCalc);
  Inc(MpCalc, mp_inc);
  Inc(MpCalc, mp_lvl);
  Inc(MpCalc, mp_equip);
  Inc(MpCalc, MpCalc * (mp_perc div 100));

  if (MpCalc <= 0) then
    MpCalc := 1;
  Result := MpCalc;
end;

function TBaseMob.GetRegenerationHP(): DWORD;
var
  hp_inc: Integer;
  hp_perc: Single;
  CurHP: DWORD;
const
  REC_BASE: Single = 0.05; // antes de 30/04/2021 era 0.05
begin
  hp_inc := 0;
  Inc(hp_inc, Self.GetMobAbility(EF_PRAN_REGENHP));
  Inc(hp_inc, PlayerCharacter.Base.CurrentScore.CONS * 3);
  if (hp_inc < 0) then
    hp_inc := 0;
  hp_perc := REC_BASE + ((hp_inc div 100) div 10);
  CurHP := Self.GetCurrentHP;
  Inc(hp_inc, Self.GetMobAbility(EF_REGENHP));
  Result := Trunc(CurHP * hp_perc);
  if (Result > Trunc(CurHP * 0.15)) then
    Result := Trunc(CurHP * 0.15);
end;

function TBaseMob.GetRegenerationMP(): DWORD;
var
  mp_inc: Integer;
  mp_perc: Single;
  CurMP: DWORD;
const
  REC_BASE: Single = 0.03;
begin
  mp_inc := 0;
  Inc(mp_inc, Self.GetMobAbility(EF_PRAN_REGENMP));
  Inc(mp_inc, PlayerCharacter.Base.CurrentScore.luck * 3);
  if (mp_inc < 0) then
    mp_inc := 0;
  mp_perc := REC_BASE + ((mp_inc div 100) div 10);
  CurMP := Self.GetCurrentMP;
  Inc(mp_inc, Self.GetMobAbility(EF_REGENMP));
  Result := Trunc(CurMP * mp_perc);
  if (Result > Trunc(CurMP * 0.15)) then
    Result := Trunc(CurMP * 0.15);
end;

function TBaseMob.GetEquipedItensHPMPInc: DWORD;
var
  i: Byte;
  Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;
    if (Self.Character.Equip[i].Time > 0) then
      Continue;
    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine = 0) then
      Continue;
    Inc(Result, TItemFunctions.GetItemReinforceHPMPInc(Self.Character.Equip[i].
      Index, Refine - 1));
  end;
end;

function TBaseMob.GetEquipedItensDamageReduce: DWORD;
var
  i, Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;
    if (Self.Character.Equip[i].Time > 0) then
      Continue;
    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine = 0) then
      Continue;
    Inc(Result, TItemFunctions.GetItemReinforceDamageReduction
      (Self.Character.Equip[i].Index, Refine - 1));
  end;
end;

function TBaseMob.GetMobClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
  if (Self.ClientID > MAX_CONNECTIONS) then
  begin
    Exit;
  end;
  if (ClassInfo = 0) then
    ClassInfo := Self.Character.ClassInfo;
  // war
  if (ClassInfo >= 1) and (ClassInfo <= 9) then
    Result := 0;
  // templar
  if (ClassInfo >= 11) and (ClassInfo <= 19) then
    Result := 1;
  // att
  if (ClassInfo >= 21) and (ClassInfo <= 29) then
    Result := 2;
  // dual
  if (ClassInfo >= 31) and (ClassInfo <= 39) then
    Result := 3;
  // mago
  if (ClassInfo >= 41) and (ClassInfo <= 49) then
    Result := 4;
  // cleriga
  if (ClassInfo >= 51) and (ClassInfo <= 59) then
    Result := 5;
end;

procedure TBaseMob.GetEquipDamage(const Equip: TItem);
var
  FisAtk: WORD;
  MagAtk: WORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisAtk := 0;
  MagAtk := 0;

  if Equip.Index = 0 then
  begin
    Exit
  end;

  if (Equip.MIN = 0) then
  begin
    Exit;
  end;

  if not(Equip.Refi >= 16) then
  begin
    FisAtk := ItemList[Equip.Index].ATKFis;
    MagAtk := ItemList[Equip.Index].MagAtk;
  end
  else
  begin
    if not(Equip.Time > 0) then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;

      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);

      Inc(FisAtk, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagAtk, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisAtk := ItemList[Equip.Index].ATKFis;
      MagAtk := ItemList[Equip.Index].MagAtk;
    end;
  end;

  PlayerCharacter.Base.CurrentScore.DNMAG := MagAtk;
  PlayerCharacter.Base.CurrentScore.DNFis := FisAtk;
end;

procedure TBaseMob.GetEquipDefense(const Equip: TItem);
var
  FisDef: DWORD;
  MagDef: DWORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisDef := 0;
  MagDef := 0;

  if Equip.Index = 0 then
  begin
    Exit
  end;

  if not(Equip.Refi >= 16) then
  begin
    FisDef := ItemList[Equip.Index].DEFFis;
    MagDef := ItemList[Equip.Index].DEFMAG;
  end
  else
  begin
    if not(Equip.Time > 0) then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;

      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);

      Inc(FisDef, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagDef, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisDef := ItemList[Equip.Index].DEFFis;
      MagDef := ItemList[Equip.Index].DEFMAG;
    end;
  end;

  Inc(PlayerCharacter.Base.CurrentScore.DEFMAG, MagDef);
  Inc(PlayerCharacter.Base.CurrentScore.DEFFis, FisDef);
end;

procedure TBaseMob.GetEquipsDefense;
var
  i: Integer;
begin
  Self.PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  Self.PlayerCharacter.Base.CurrentScore.DEFFis := 0;

  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;

    if (Self.Character.Equip[i].MIN = 0) then
      Continue;

    Self.GetEquipDefense(Self.Character.Equip[i]);
  end;

end;

procedure TBaseMob.GetCurrentScore;
var
  Damage_perc: WORD;
  Def_perc: WORD;
begin
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  ZeroMemory(@PlayerCharacter.Base.CurrentScore, 10);
  PlayerCharacter.Base.CurrentScore.DNFis := 0;
  PlayerCharacter.Base.CurrentScore.DNMAG := 0;
  PlayerCharacter.Base.CurrentScore.DEFFis := 0;
  PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  PlayerCharacter.Base.CurrentScore.BonusDMG := 0;
  PlayerCharacter.Base.CurrentScore.Critical := 0;
  PlayerCharacter.Base.CurrentScore.Esquiva := 0;
  PlayerCharacter.Base.CurrentScore.Acerto := 0;
  PlayerCharacter.DuploAtk := 0;
  PlayerCharacter.SpeedMove := 0;
  PlayerCharacter.Resistence := 0;
  PlayerCharacter.HabAtk := 0;
  PlayerCharacter.DamageCritical := 0;
  PlayerCharacter.ResDamageCritical := 0;
  PlayerCharacter.MagPenetration := 0;
  PlayerCharacter.FisPenetration := 0;
  PlayerCharacter.CureTax := 0;
  PlayerCharacter.CritRes := 0;
  PlayerCharacter.DuploRes := 0;
  PlayerCharacter.ReduceCooldown := 0;
  PlayerCharacter.PvPDamage := 0;
  PlayerCharacter.PvPDefense := 0;
{$REGION 'Get Status Points'}
  IncCritical(PlayerCharacter.Base.CurrentScore.Str, Character.CurrentScore.Str
    + Self.GetMobAbility(EF_STR));
  IncCritical(PlayerCharacter.Base.CurrentScore.agility,
    Character.CurrentScore.agility + Self.GetMobAbility(EF_DEX));
  IncCritical(PlayerCharacter.Base.CurrentScore.Int, Character.CurrentScore.Int
    + Self.GetMobAbility(EF_INT));
  IncCritical(PlayerCharacter.Base.CurrentScore.CONS,
    Character.CurrentScore.CONS + Self.GetMobAbility(EF_CON));
  IncCritical(PlayerCharacter.Base.CurrentScore.luck,
    Character.CurrentScore.luck + Self.GetMobAbility(EF_SPI));
{$ENDREGION}
{$REGION 'Get Attribute Status'}
{$REGION 'SpeedMove'}
  IncSpeedMove(PlayerCharacter.SpeedMove,
    (40 + Self.GetMobAbility(EF_RUNSPEED)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncSpeedMove(PlayerCharacter.SpeedMove, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_RUNSPEED]);
{$ENDREGION}
{$REGION 'Duplo Atk'}
  var
  doubleFromBuff := Self.GetMobAbility(EF_DOUBLE);
  var
  DoubleAtk := 0;
  TAttributeFunctions.GetDoubleAttack(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, Self.Character.Nation, doubleFromBuff, DoubleAtk);
  IncCritical(PlayerCharacter.DuploAtk, DoubleAtk);
{$ENDREGION}
{$REGION 'Critical'}
  var
  criticalFromBuff := Self.GetMobAbility(EF_CRITICAL);
  var
  CriticalAtk := 0;
  TAttributeFunctions.GetCriticalAttack(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, Self.Character.Nation, criticalFromBuff, CriticalAtk);
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical, CriticalAtk);
{$ENDREGION}
{$REGION 'Critical Damage' }
  var
  criticalDmgFromBuff := Self.GetMobAbility(EF_CRITICAL_POWER);
  var
  CriticalDmgAtk := 0;
  TAttributeFunctions.GetCriticalDamage(PlayerCharacter.Base.CurrentScore,
    criticalDmgFromBuff, CriticalDmgAtk);
  IncCritical(PlayerCharacter.DamageCritical, CriticalDmgAtk);
{$ENDREGION}
{$REGION 'Physical Pen' }
  var
  physicalPenAtk := 0;
  TAttributeFunctions.GetPhysicalPen(PlayerCharacter.Base.CurrentScore,
    physicalPenAtk, physicalPenAtk);
  // Loucura do Mu, n�o sei o que faz com a penetra��o
  IncCooldown(PlayerCharacter.FisPenetration, physicalPenAtk);
  IncCooldown(PlayerCharacter.FisPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE1));
{$ENDREGION}
{$REGION 'Magical Pen'}
  var
  magicalPenAtk := 0;
  TAttributeFunctions.GetMagicalPen(PlayerCharacter.Base.CurrentScore,
    magicalPenAtk, magicalPenAtk);
  // Loucura do Mu, n�o sei o que faz com a penetra��o
  IncCooldown(PlayerCharacter.MagPenetration, magicalPenAtk);
  IncCooldown(PlayerCharacter.MagPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE2));
{$ENDREGION}
{$REGION 'Hab Skill Atk'}
  var
  skillAtkFromBuff := Self.GetMobAbility(EF_SKILL_DAMAGE);
  var
  SkillDmgAtk := 0;
  TAttributeFunctions.GetSkillAttack(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, Self.Character.Nation, skillAtkFromBuff, SkillDmgAtk);

  IncWORD(PlayerCharacter.HabAtk, SkillDmgAtk);
{$ENDREGION}
{$REGION 'Cure Tax'}
  var
  cureTaxFromBuff := 0;
  var
  CureTax := 0;
  TAttributeFunctions.GetCureTax(PlayerCharacter.Base.CurrentScore,
    cureTaxFromBuff, CureTax);

  Inc(PlayerCharacter.CureTax, CureTax);
{$ENDREGION}
{$REGION 'Res Crit'}
  var
  resCritFromBuff := Self.GetMobAbility(EF_RESISTANCE6);
  var
  ResCrit := 0;
  TAttributeFunctions.GetCriticalResistance(PlayerCharacter.Base.CurrentScore,
    resCritFromBuff, ResCrit);

  IncCritical(PlayerCharacter.CritRes, ResCrit);
{$ENDREGION}
{$REGION 'Res Duplo'}
  var
  resDoubleFromBuff := Self.GetMobAbility(EF_RESISTANCE7);
  var
  ResDouble := 0;
  TAttributeFunctions.GetDoubleResistance(PlayerCharacter.Base.CurrentScore,
    resDoubleFromBuff, ResDouble);
  IncCritical(PlayerCharacter.DuploRes, ResDouble);
{$ENDREGION}
{$REGION 'Acerto'}
  var
  hitRateFromBuff := Self.GetMobAbility(EF_HIT);
  var
  HitRate := 0;
  TAttributeFunctions.GetHitRate(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, Self.Character.Nation, hitRateFromBuff, HitRate);
  var
  HitRateBylvl := Trunc(Self.Character.Level * 1.11);
  Inc(HitRate, HitRateBylvl);
  IncByte(PlayerCharacter.Base.CurrentScore.Acerto, HitRate);
{$ENDREGION}
{$REGION 'Esquiva'}
  var
  dodgeFromBuff := Self.GetMobAbility(EF_PARRY) +
    Self.GetMobAbility(EF_PRAN_PARRY);
  var
  Dodge := 0;
  TAttributeFunctions.GetDodge(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, Self.Character.Nation, dodgeFromBuff, Dodge);
  IncByte(PlayerCharacter.Base.CurrentScore.Esquiva, Dodge);
{$ENDREGION}
{$REGION 'Resistence'}
  var
  resistanceFromBuff := Self.GetMobAbility(EF_STATE_RESISTANCE);
  var
  Resistance := 0;
  TAttributeFunctions.GetAbnormalStatusResistance
    (PlayerCharacter.Base.CurrentScore, Self.ChannelId, Self.Character.Nation,
    resistanceFromBuff, Resistance);

  IncCritical(PlayerCharacter.Resistence, Resistance);
{$ENDREGION}
{$REGION 'Cooldown Time'}
  var
  cooltimeFromBuff := Self.GetMobAbility(EF_COOLTIME);
  var
  CoolTime := 0;
  TAttributeFunctions.GetCoolDownTime(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, Self.Character.Nation, cooltimeFromBuff, CoolTime);

  IncCooldown(PlayerCharacter.ReduceCooldown, CoolTime);
{$ENDREGION}
{$REGION 'PvP Damage'}
  IncWORD(PlayerCharacter.PvPDamage, Self.GetMobAbility(EF_ATK_NATION2));
{$ENDREGION}
{$REGION 'PvP Defense'}
  IncWORD(PlayerCharacter.PvPDefense, Self.GetMobAbility(EF_DEF_NATION2));
{$ENDREGION}
{$ENDREGION}
{$REGION 'Get Def'}  // revisar essa region
  Self.GetEquipsDefense;

  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE1);
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE1];

  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE2);
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE2];

  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Self.GetMobAbility(EF_RESISTANCE1));
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Self.GetMobAbility(EF_RESISTANCE2));
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Self.GetMobAbility(EF_PRAN_RESISTANCE1));
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Self.GetMobAbility(EF_PRAN_RESISTANCE2));
  if (Self.GetMobAbility(EF_UNARMOR) > 0) then
  begin
    PlayerCharacter.Base.CurrentScore.DEFFis := 0;
    PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  end;
{$ENDREGION}
{$REGION 'Get Atk'}   // revisar essa region
  Self.GetEquipDamage(Self.Character.Equip[6]);
{$REGION 'Atk Fis'}
  var
    PhysDmg: Integer;
  var
    agi: Integer;
  var
    Str: Integer;
  var
    fromBuff: Integer;
  case Self.GetMobClass() of
    0: // war
      begin
        agi := 0;
        Str := PlayerCharacter.Base.CurrentScore.Str;
        fromBuff := 0;
        TAttributeFunctions.GetPhysicalDamage(PlayerCharacter.Base.CurrentScore,
          agi, Str, Self.ChannelId, fromBuff, PhysDmg);
        IncWORD(PlayerCharacter.Base.CurrentScore.DNFis, PhysDmg);
      end;
    1: // templar
      begin
        agi := 0;
        Str := PlayerCharacter.Base.CurrentScore.Str;
        fromBuff := 0;
        TAttributeFunctions.GetPhysicalDamage(PlayerCharacter.Base.CurrentScore,
          agi, Str, Self.ChannelId, fromBuff, PhysDmg);
        IncWORD(PlayerCharacter.Base.CurrentScore.DNFis, PhysDmg);
      end;
    2: // att
      begin
        agi := PlayerCharacter.Base.CurrentScore.agility;
        Str := 0;
        fromBuff := 0;
        TAttributeFunctions.GetPhysicalDamage(PlayerCharacter.Base.CurrentScore,
          agi, Str, Self.ChannelId, fromBuff, PhysDmg);
        IncWORD(PlayerCharacter.Base.CurrentScore.DNFis, PhysDmg);
      end;
    3: // dual
      begin
        agi := PlayerCharacter.Base.CurrentScore.agility;
        Str := 0;
        fromBuff := 0;
        TAttributeFunctions.GetPhysicalDamage(PlayerCharacter.Base.CurrentScore,
          agi, Str, Self.ChannelId, fromBuff, PhysDmg);
        IncWORD(PlayerCharacter.Base.CurrentScore.DNFis, PhysDmg);
      end;
    4: // mago
      begin
        agi := PlayerCharacter.Base.CurrentScore.agility;
        Str := 0;
        fromBuff := 0;
        TAttributeFunctions.GetPhysicalDamage(PlayerCharacter.Base.CurrentScore,
          agi, Str, Self.ChannelId, fromBuff, PhysDmg);
        IncWORD(PlayerCharacter.Base.CurrentScore.DNFis, PhysDmg);
      end;
    5: // cleriga
      begin
        agi := PlayerCharacter.Base.CurrentScore.agility;
        Str := 0;
        fromBuff := 0;
        TAttributeFunctions.GetPhysicalDamage(PlayerCharacter.Base.CurrentScore,
          agi, Str, Self.ChannelId, fromBuff, PhysDmg);
        IncWORD(PlayerCharacter.Base.CurrentScore.DNFis, PhysDmg);
      end;
  end;

  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_PRAN_DAMAGE1));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE1);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
  { Reliquia }
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE1];
    IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
  end;

  decword(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) *
    Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1)));

  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_DAMAGE1));
{$ENDREGION}
{$REGION 'Atk Mag'}
  var
  MagDmg := 0;
  TAttributeFunctions.GetMagicalDamage(PlayerCharacter.Base.CurrentScore,
    Self.ChannelId, fromBuff, MagDmg);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG, MagDmg);

  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_PRAN_DAMAGE2));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE2);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
  { Reliquia }
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE2];
    IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
      Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
  end;

  decword(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) *
    Self.GetMobAbility(EF_DECREASE_PER_DAMAGE2)));

  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_DAMAGE2));

{$ENDREGION}
{$ENDREGION}
end;
{$ENDREGION}
{$REGION 'Buffs'}

procedure TBaseMob.SendRefreshBuffs();
var
  Packet: TSendBuffsPacket;
  i: Integer;
  Index: WORD;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $16E;
  Packet.Header.Index := Self.ClientID;
  Self.RefreshBuffs;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      (SkillData[Index].Duration)));
    Inc(i);
  end;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Self.SendToVisible(Packet, Packet.Header.size, False)
  else
    Self.SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendAddBuff(BuffIndex: WORD);
var
  Packet: TUpdateBuffPacket;
  EndTime: TDateTime;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $16F;
  Packet.Buff := BuffIndex;
  EndTime := IncSecond(Self._buffs[BuffIndex], (SkillData[BuffIndex].Duration));
  Packet.EndTime := DateTimeToUnix(EndTime);
  if (Self.ClientID >= 3048) then
    Self.SendToVisible(Packet, Packet.Header.size, False)
  else
    Self.SendPacket(Packet, Packet.Header.size);
  Self.SendRefreshBuffs;
  Self.SendRefreshPoint;
  Self.SendStatus;
end;

function TBaseMob.RefreshBuffs: Integer;
var
  Index: WORD;
  EndTime: TDateTime;
  // TimeNow: TDateTime;
  i: Integer;
begin
  Result := 0;
  for Index in Self._buffs.Keys do
  begin
    EndTime := IncSecond(Self._buffs[Index], SkillData[Index].Duration);
    // TimeNow := Now;
    if (EndTime < Now) then
    begin
      if (Self.RemoveBuff(Index)) then
      begin
        Inc(Result);
      end;
    end;
  end;
  if (Result > 0) then
  begin
    Self.SendCurrentHPMP(True);
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;

  // mod se der merda foi aqui por conta verificar if clientid <= max_connections
  if (Self.ClientID <= MAX_CONNECTIONS) then
  begin
    for i := Low(Self.PlayerCharacter.Buffs)
      to High(Self.PlayerCharacter.Buffs) do
    begin
      EndTime := IncSecond(Self.PlayerCharacter.Buffs[i].CreationTime,
        SkillData[Self.PlayerCharacter.Buffs[i].Index].Duration);
      if (EndTime <= Now) then
      begin
        ZeroMemory(@Self.PlayerCharacter.Buffs[i],
          sizeof(Self.PlayerCharacter.Buffs[i]));
      end;
    end;
  end;
end;

function TBaseMob.AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
  AddTime: Boolean = False; TimeAditional: Integer = 0): Boolean;
var
  BuffSlot: Integer;
begin
  Result := False;
  if (Self._buffs.Count >= 60) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('N�o foi poss�vel adicionar novos buffs. Limite: 60 Buffs.');
    Exit;
  end;
  if (BuffIndex = 7257) or (BuffIndex = 9133) then
    Exit;
  if (Self.BuffExistsByIndex(SkillData[BuffIndex].Index)) then
  begin
    Self.RemoveBuffByIndex(SkillData[BuffIndex].Index);
  end;
  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Result := True;
    if (Self.Character <> nil) then
    begin // arrumar pro debuff n�o aumentar em nation mas sim no inimigo
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;
    end;
    if (TimeAditional > 0) then
      Self._buffs[BuffIndex] := IncSecond(Now, TimeAditional)
    else
      Self._buffs[BuffIndex] := Now;
    Self.SendRefreshBuffs;
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end
  else
  begin
    Result := True;
    if (Self.Character <> nil) then
    begin // arrumar pro debuff n�o aumentar em nation mas sim no inimigo
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;
    end;
    Self._buffs.Add(BuffIndex, IncSecond(Now, TimeAditional));
    Self.AddBuffEffect(BuffIndex);
    Self.GetCurrentScore;
    BuffSlot := Self.GetEmptyBuffSlot;
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := BuffIndex;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end;
  if (Refresh) then
  begin
    Self.SendAddBuff(BuffIndex);
  end;
end;

function TBaseMob.AddBuffWhenEntering(BuffIndex: Integer;
  BuffTime: TDateTime): Boolean;
begin
  Result := True;
  if (Self._buffs.ContainsKey(BuffIndex)) then
    Exit;
  Self._buffs.Add(BuffIndex, BuffTime);
  Self.AddBuffEffect(BuffIndex);
  // Self.GetCurrentScore;
  // Self.SendAddBuff(BuffIndex);
end;

function TBaseMob.GetBuffSlot(BuffIndex: WORD): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  for i := 0 to 59 do
  begin
    if (Self.PlayerCharacter.Buffs[i].Index = BuffIndex) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;

function TBaseMob.GetEmptyBuffSlot(): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to 59 do
  begin
    if (Self.PlayerCharacter.Buffs[i].Index = 0) then
    begin
      Result := i;
      break;
    end
    else
      Continue;
  end;
end;

function TBaseMob.RemoveBuff(BuffIndex: WORD): Boolean;
var
  BuffSlot: Integer;
begin
  Result := False;
  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Self.RemoveBuffEffect(BuffIndex);
    Self._buffs.Remove(BuffIndex);
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := 0;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime := 0;
    end;
  end;
  if not(Self._buffs.ContainsKey(BuffIndex)) then
    Result := True;
  Self.GetCurrentScore;
  Self.SendStatus;
  Self.SendRefreshPoint;
  Self.SendRefreshBuffs;
  case SkillData[BuffIndex].Index of
    35: // uniao divina
      begin
        Self.UniaoDivina := '';
      end;
    42:
      begin
        Self.HPRListener := False;
      end;
    49: // contagem regressiva
      begin
        Randomize;
        Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
          True, True);
      end;
    65: // x14
      begin
        Self.DestroyPet(Self.PetClientID);
        Self.PetClientID := 0;
      end;

    73: // mjolnir
      begin
        Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
          True, True);
      end;
    // 91: //pocao logo aika
    // begin
    // Self.SendCreateMob(SPAWN_NORMAL);
    // Self.SendEffect(0);
    // end;
    99: // polimorfo
      begin
        Self.SendCreateMob(SPAWN_NORMAL);
      end;
    108: // eclater
      begin
        Randomize;
        if (Self.GetMobAbility(EF_ACCELERATION1) > 0) then
        begin
          Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0] +
            SkillData[BuffIndex].Damage), True, True);
        end
        else
          Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
            True, True);

      end;
    120:
      begin
        Self.HPRListener := False;
      end;
    125:
      begin
        Self.HPRListener := False;
      end;
    134: // cura preventiva
      begin
        Self.CalcAndCure(BuffIndex, @Self);
      end;
  end;
end;

procedure TBaseMob.RemoveAllDebuffs();
var
  i, cnt: WORD;
begin
  cnt := 0;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      Self.RemoveBuff(i);
      Inc(cnt);
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;

procedure TBaseMob.AddBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if (Self.IsDungeonMob) then
    Exit;
  for i := 0 to 3 do
  begin
    if (i = EF_RUNSPEED) then
    begin
      if ((Self.MOB_EF[EF_RUNSPEED] + SkillData[Index].EFV[i]) >= 13) then
      begin
        Self.MOB_EF[EF_RUNSPEED] := 13;
      end
      else
      begin
        Self.IncreasseMobAbility(SkillData[Index].EF[i],
          SkillData[Index].EFV[i]);
      end;
    end
    else
      Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;
end;

procedure TBaseMob.RemoveBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if (Self.IsDungeonMob) then
    Exit;
  for i := 0 to 3 do
  begin
    Self.DecreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;

end;

function TBaseMob.GetBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff <> 1) then
      Continue;
    Result := i;
    break;
  end;
end;

function TBaseMob.GetDeBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff <> 3) or (SkillData[i].BuffDebuff <> 4) then
      Continue;
    Result := i;
    break;
  end;
end;

function TBaseMob.GetDebuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4) then
    begin
      Inc(Result);
    end
    else
      Continue;
  end;
end;

function TBaseMob.GetBuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff = 1) then
    begin
      Inc(Result);
    end
    else
      Continue;
  end;
end;

procedure TBaseMob.RemoveBuffByIndex(Index: WORD);
var
  i: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].Index = Index) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Self.SendRefreshBuffs;
        Self.SendCurrentHPMP;
        Self.SendStatus;
        Self.SendRefreshPoint;
      end;
      break;
    end
    else
      Continue;
  end;
end;

function TBaseMob.GetBuffSameIndex(BuffIndex: DWORD): Boolean;
var
  j: DWORD;
  Index: DWORD;
begin
  Result := False;
  if (Self._buffs.Count = 0) then
    Exit;
  for j in Self._buffs.Keys do
  begin
    if (SkillData[BuffIndex].Index = SkillData[j].Index) then
    begin
      Self.RemoveBuff(j);
      Result := True;
      // break;
    end
    else
    begin
      Continue;
    end;
  end;
end;

function TBaseMob.BuffExistsByIndex(BuffIndex: DWORD): Boolean;
var
  i: Integer;
  Index: DWORD;
begin
  Result := False;
  if { (Self.ClientID >= 3048) or } (Self.IsDungeonMob) then
    Exit;
  if (BuffIndex = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.BuffExistsByID(BuffID: DWORD): Boolean;
var
  i: Integer;
  Index: DWORD;
begin
  Result := False;
  if { (Self.ClientID >= 3048) or } (Self.IsDungeonMob) then
    Exit;
  if (BuffID = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffID = i) then
    begin
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
var
  i, j: Integer;
begin
  Result := False;

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    for j in BuffList do
    begin
      if (SkillData[i].Index = j) then
      begin
        Result := True;
        break;
      end;
    end;

    if (Result) then
      break;
  end;
end;

function TBaseMob.BuffExistsSopa(): Boolean;
var
  i: Integer;
begin
  Result := False;

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (Copy(String(SkillData[i].Name), 0, 4) = 'Sopa') then
    begin
      Result := True;
      break;
    end;
  end;
end;

function TBaseMob.GetBuffIDByIndex(Index: DWORD): WORD;
var
  i, id: WORD;
begin
  Result := 0;
  if { (Self.ClientID >= 3048) or } (Self.IsDungeonMob) then
    Exit;
  if (Index = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (Index = SkillData[i].Index) then
    begin
      Result := id;
      break;
    end;
  end;
end;

procedure TBaseMob.RemoveBuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  cnt := 0;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      break;
    if (SkillData[i].BuffDebuff = 1) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
        Continue;
      end;
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;

procedure TBaseMob.RemoveDebuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;
  cnt := 0;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      break;
    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
        Continue;
      end;
    end
    else
      Continue;
  end;
  if not(cnt = 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;

procedure TBaseMob.ZerarBuffs();
var
  i: Integer;
begin
  for i in Self._buffs.Keys do
  begin
    Self.RemoveBuff(i);
  end;
end;
{$ENDREGION}
{$REGION 'Attack & Skills'}

procedure TBaseMob.CheckCooldown(var Packet: TSendSkillUse);
var
  EndTime: TTime;
begin
  if (Self._cooldown.ContainsKey(Packet.Skill)) then
  begin
    EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
      SkillData[Packet.Skill].Cooldown);
    if not(EndTime < Now) then
    begin
      Exit;
    end;
  end;
  Self.UsingSkill := Packet.Skill;
  Self.SendToVisible(Packet, Packet.Header.size, True);
end;

procedure TBaseMob.SendCurrentAllSkillCooldown();
var
  Packet: Tp12C;
  i: Integer;
  CurrTime: TTime;
  OPlayer: PPlayer;
begin
  ZeroMemory(@Packet, sizeof(Tp12C));
  Packet.Header.size := sizeof(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;

  OPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for i := 0 to 5 do
  begin
    if (Self._cooldown.ContainsKey(OPlayer.Character.Skills.Basics[i].
      Index + OPlayer.Character.Skills.Basics[i].Level - 1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Basics[i].
        Index + OPlayer.Character.Skills.Basics[i].Level - 1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Basics[i].
        Index + OPlayer.Character.Skills.Basics[i].Level - 1].Duration -
        ((SkillData[OPlayer.Character.Skills.Basics[i].
        Index + OPlayer.Character.Skills.Basics[i].Level - 1].Duration div 100)
        * Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  for i := 0 to 39 do
  begin
    if (Self._cooldown.ContainsKey(OPlayer.Character.Skills.Others[i].
      Index + OPlayer.Character.Skills.Others[i].Level - 1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Others[i].
        Index + OPlayer.Character.Skills.Others[i].Level - 1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Others[i].
        Index + OPlayer.Character.Skills.Others[i].Level - 1].Duration -
        ((SkillData[OPlayer.Character.Skills.Others[i].
        Index + OPlayer.Character.Skills.Others[i].Level - 1].Duration div 100)
        * Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

function TBaseMob.CheckCooldown2(SkillID: DWORD): Boolean;
var
  EndTime: TTime;
  CD: DWORD;
begin
  Result := True;
  if (Self._cooldown.ContainsKey(SkillID)) then
  begin
    if (Self.GetMobClass() = 3) then
      CD := ((SkillData[SkillID].Cooldown * PlayerCharacter.ReduceCooldown +
        50) div 100)
    else
      CD := ((SkillData[SkillID].Cooldown *
        PlayerCharacter.ReduceCooldown) div 100);
    var
      aux1: TTime;
    aux1 := Self._cooldown[SkillID];
    var
    aux2 := SkillData[SkillID].Cooldown;
    var
    aux3 := IncMillisecond(Self._cooldown[SkillID],
      ((SkillData[SkillID].Cooldown) - CD));
    var
    aux4 := Now;

    EndTime := IncMillisecond(Self._cooldown[SkillID],
      ((SkillData[SkillID].Cooldown) - CD));
    if not(EndTime < Now) then
    begin
      Result := False;
    end
    else
    begin
      Self._cooldown[SkillID] := Now;
      Result := True;
    end;
  end
  else
  begin
    Self._cooldown.Add(SkillID, Now);
    Result := True;
  end;
end;

procedure TBaseMob.SendDamage(Skill, Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  Add_Buff: Boolean;
  j: Integer;
  DropExp: Boolean;
  DropItem: Boolean;
  MobsP: PMobSPoisition;
  xDano, helper: Integer;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  xDano := Self.GetDamage(Skill, mob, Packet.DnType);
  if (Self.IsSecureArea) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Voc� est� em uma �rea segura, n�o pode lan�ar skills.');
    Exit;
  end;
  if (mob^.IsSecureArea) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('O alvo est� dentro de uma �rea segura e n�o foi afetado pela sua habilidade.');
    Exit;
  end;
  if (xDano > 0) then
  begin
    Self.AttackParse(Skill, Anim, mob, xDano, Packet.DnType, Add_Buff,
      Packet.MobAnimation, DataSkill);

    if (xDano > 0) then
    begin
      Inc(xDano, (RandomRange((xDano div 20), (xDano div 10)) + 13));
    end;
  end
  else if (xDano < 0) then
  begin
    xDano := 0;
  end;

  Packet.Dano := xDano;

  if (Skill = 0) then
  begin
    case Self.GetMobClass() of
      0:
        begin
          if (mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.25);
        end;

      1:
        begin
          if (mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.4);
        end;

      2:
        begin
          if (mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.59);

          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);

            if (Self.Character.Equip[15].Index = 0) then
            begin
              Helper := TItemFunctions.GetItemSlotByItemType
                (Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

              if (Helper <> 255) and
                (ItemList[Self.Character.Inventory[Helper].Index]
                .Classe = Self.Character.ClassInfo) then
              begin
                Move(Self.Character.Inventory[Helper], Self.Character.Equip[15],
                  sizeof(TItem));
                Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
                  Self.Character.Equip[15], False);
                ZeroMemory(@Self.Character.Inventory[Helper], sizeof(TItem));
                Self.SendRefreshItemSlot(INV_TYPE, Helper,
                  Self.Character.Inventory[Helper], False);

                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                  ('Suas balas acabaram e foram equipadas novas balas a partir do invent�rio.');
              end;
            end;
          end;
        end;

      3:
        begin
          if (mob.ClientID <= MAX_CONNECTIONS) then
            Packet.Dano := Trunc(Packet.Dano / 1.70);

          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);

            if (Self.Character.Equip[15].Index = 0) then
            begin
              Helper := TItemFunctions.GetItemSlotByItemType
                (Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

              if (Helper <> 255) and
                (ItemList[Self.Character.Inventory[Helper].Index]
                .Classe = Self.Character.ClassInfo) then
              begin
                Move(Self.Character.Inventory[Helper], Self.Character.Equip[15],
                  sizeof(TItem));
                Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
                  Self.Character.Equip[15], False);
                ZeroMemory(@Self.Character.Inventory[Helper], sizeof(TItem));
                Self.SendRefreshItemSlot(INV_TYPE, Helper,
                  Self.Character.Inventory[Helper], False);

                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                  ('Suas balas acabaram e foram equipadas novas balas a partir do invent�rio.');
              end;
            end;
          end;
        end;
    end;
  end;
  MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[0].MobsP[1];
  if (mob^.SecondIndex > 0) then
    MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];

  if ((mob^.ClientID >= 3048) and (mob^.ClientID <= 9147)) then
  begin
    case mob^.ClientID of
      3340 .. 3354:
        begin // stones
          if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP) and not(mob^.IsDead)) then
          begin
            mob^.IsDead := True;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := 0;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .IsAttacked := False;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].AttackerID := 0;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID].deadTime := Now;
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .KillStone(mob^.ClientID, Self.ClientID);
            if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
            begin
              Self.VisibleNPCS.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
              // essa skill tem retorno no caso de erro
            end;
            for j in Self.VisiblePlayers do
            begin
              if (Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains
                (mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove
                  (mob^.ClientID);
                Servers[Self.ChannelId].Players[j]
                  .Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            // Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
          end
          else
          begin
            Servers[Self.ChannelId].DevirStones[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
              .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
              Packet.Dano;
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          // Sleep(1);
          Exit;
        end;
      3355 .. 3369:
        begin // guards
          if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP) and not(mob^.IsDead)) then
          begin
            mob^.IsDead := True;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := 0;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .IsAttacked := False;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].AttackerID := 0;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID].deadTime := Now;
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .KillGuard(mob^.ClientID, Self.ClientID);
            if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
            begin
              Self.VisibleNPCS.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
              // essa skill tem retorno no caso de erro
            end;
            for j in Self.VisiblePlayers do
            begin
              if (Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains
                (mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove
                  (mob^.ClientID);
                Servers[Self.ChannelId].Players[j]
                  .Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            // Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
          end
          else
          begin
            Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
              .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
              .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
              Packet.Dano;
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          // Sleep(1);
          Exit;
        end;
    else
      begin

        if not(MobsP.IsAttacked) then
        begin
          MobsP.FirstPlayerAttacker := Self.ClientID;
        end;

        if (Packet.Dano >= MobsP^.HP) then
        begin
          mob^.IsDead := True;
          MobsP^.HP := 0;
          MobsP^.IsAttacked := False;
          MobsP^.AttackerID := 0;
          MobsP^.deadTime := Now;

          MobsP.Base.SendEffect($0);

          mob.SendCurrentHPMPMob;
          if (Self.VisibleMobs.Contains(mob^.ClientID)) then
          begin
            Self.VisibleMobs.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
            // essa skill tem retorno no caso de erro
          end;
          for j := Low(Servers[Self.ChannelId].Players)
            to High(Servers[Self.ChannelId].Players) do
          begin
            if ((Servers[Self.ChannelId].Players[j].Status < Playing) or
              (Servers[Self.ChannelId].Players[j].SocketClosed)) then
              Continue;

            if (Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains
              (mob^.ClientID)) then
            begin
              Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
                (mob^.ClientID);
              Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
            end;
          end;
          try
            if not(Servers[Self.ChannelId].Players[Self.ClientID].SocketClosed)
            then
            begin
              if (mob.SecondIndex > 0) then
              begin
                if (mob.ClientID >= 3049) and (mob.ClientID <= 9147) then
                begin
                  if (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid]
                    .IsActiveToSpawn) then
                    Self.MobKilled(mob, DropExp, DropItem, False);
                end;
              end;
            end;
          except
            on E: Exception do
            begin
              Logger.Write('Erro no MobKiller: ' + E.Message + 't ' +
                DateTimeToStr(Now), TLogType.Error);
            end;
          end;

          mob^.VisibleMobs.Clear;
          Packet.MobAnimation := 30;
        end
        else
        begin
          MobsP^.HP := MobsP^.HP - Packet.Dano;
        end;
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := MobsP^.HP;
        Self.SendToVisible(Packet, Packet.Header.size);
        // Sleep(1);
        Exit;
      end;
    end;
  end
  else if (mob.ClientID >= 9148) then
  begin
    if (Servers[Self.ChannelId].PETS[mob.ClientID].PetType = X14) then
    begin
      Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP) then
      begin
        Packet.MobAnimation := 30;
        mob.IsDead := True;
        if (Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        begin
          if (Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
            Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet
              (mob.ClientID);
        end;
        // Servers[Self.ChannelId].PETS[mob.ClientID].Base.Destroy;
        // ZeroMemory(@Servers[Self.ChannelId].PETS[mob.ClientID], sizeof(TPet));
      end
      else
      begin
        deccardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP, Packet.Dano);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      // Sleep(1);
      Exit;
    end;
  end;

  if (SecondsBetween(Now, mob.RevivedTime) <= 7) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Alvo acabou de nascer.');
    Exit;
  end;

  if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
  begin
    if (Servers[Self.ChannelId].Players[mob^.ClientID].Dueling) then
    begin
      mob^.Character.CurrentScore.CurHP := 10;
    end
    else
    begin
      mob^.Character.CurrentScore.CurHP := 0;
      mob^.SendEffect($0);
      Packet.MobAnimation := 30;
      mob^.IsDead := True;

      if (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare)
      then
        Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
          (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
      begin
        if ((mob^.Character.Nation <> Self.Character.Nation) or
          (Self.InClastleVerus)) then
        begin
          Self.PlayerKilled(mob);
        end;
      end;
    end;
  end
  else
  begin
    if (Packet.Dano > 0) then
      mob^.RemoveHP(Packet.Dano, False);

    if (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare) then
      Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
        (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
    mob^.LastReceivedAttack := Now;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;

  // Sleep(1);
end;

function TBaseMob.GetDamage(Skill: DWORD; mob: PBaseMob;
  out DnType: TDamageType; AditionalCrit: Integer = 0): UInt64;
var
  ResultDamage: Integer;
  MobDef, defHelp: Integer;
  IsPhysical: Boolean;
begin
  try
    Result := 0;
    // Self.GetCurrentScore;
    if (mob^.ClientID >= 9148) then
    begin // ataque dos pets � diferenciado
      Randomize;
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) +
        (Random(99) + 15));
      DnType := TDamageType.Normal;
      Exit;
    end;
{$REGION 'Verifica se esta imune'}
    if (mob^.GetMobAbility(EF_IMMUNITY) > 0) then
    begin
      DnType := TDamageType.Immune;
      Exit;
    end;
    if (mob^.BuffExistsByIndex(19)) then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(19);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(19);
        DnType := TDamageType.Block;
        Exit;
      end;
    end;
    if (mob^.BuffExistsByIndex(91)) then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(91);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(91);
        DnType := TDamageType.Miss2;
        Exit;
      end;
    end;
{$ENDREGION}
{$REGION 'Verifica se o ataque � fisico ou magico'}
    case Self.GetMobClass of
      0 .. 3:
        begin
          IsPhysical := True;
        end;
    else
      if (Skill = 0) then
        IsPhysical := True
      else
        IsPhysical := False;
    end;
{$ENDREGION}
    if (IsPhysical) then
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNFis;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFFis;
      // Verificando o efeito do quebrar armadura
      if (mob.MOB_EF[8] < 0) then
      begin
        dec(MobDef, (mob.MOB_EF[8] * -1));
      end;
      defHelp := (Self.PlayerCharacter.FisPenetration);
      if (defHelp > 0) then
      begin
        dec(MobDef, ((mob.PlayerCharacter.Base.CurrentScore.DEFFis div 100) *
          defHelp));
      end;
    end
    else
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNMAG;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFMAG;
      defHelp := (Self.PlayerCharacter.MagPenetration);
      if (defHelp > 0) then
      begin
        dec(MobDef, ((mob.PlayerCharacter.Base.CurrentScore.DEFMAG div 100) *
          defHelp));
      end;
    end;

    DnType := Self.GetDamageType3(Skill, IsPhysical, mob, AditionalCrit);
    if (DnType = Miss) then
    begin
      Result := 0;
      Exit;
    end;
    Randomize;
    if (MobDef > 0) then
    begin
      ResultDamage := ResultDamage - (MobDef shr 3);
    end;
    if (mob^.ClientID <= MAX_CONNECTIONS) then
      dec(ResultDamage,
        ((ResultDamage div 100) * (mob.GetEquipedItensDamageReduce div 10)));

    if (ResultDamage <= 0) then
      ResultDamage := 1;
    Result := ResultDamage;
  except
    on E: Exception do
    begin
      Logger.Write('TBaseMob.GetDamage Error: ' + E.Message, TLogType.Error);
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) -
        (((mob^.PlayerCharacter.Base.CurrentScore.DEFMAG +
        mob^.PlayerCharacter.Base.CurrentScore.DEFFis) div 2) shr 3));
      DnType := TDamageType.Normal;
      Randomize;
      Inc(Result, (RandomRange(10, 120) + 15));
    end;
  end;
end;

function TBaseMob.GetDamageType3(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob; AditionalCrit: Integer = 0): TDamageType;
var
  Esquiva, Acerto: WORD;
  Critico, ResistenciaCrit: WORD;
  Duplo, ResistenciaDuplo: WORD;
  DuploCritico, ResistenciaDuploCritico: WORD;
  TaxaCritica, TaxaResCritico, TaxaAcerto, TaxaDuplo, TaxaDuploCritico,
    TaxaResDuplo, TaxaEsquiva: Integer;
  TaxaRand: Integer;
  Helper: Extended;
  HelperX: Integer;
  AlwaysCrit: Boolean;
begin
  AlwaysCrit := False;

  Result := TDamageType.Normal;
{$REGION 'Calculando Acerto x Esquiva'}
  Esquiva := mob.PlayerCharacter.Base.CurrentScore.Esquiva;
  Acerto := Self.PlayerCharacter.Base.CurrentScore.Acerto;

  var
    probability: System.Double;
  probability := ((Acerto * 100) / (Acerto + Esquiva)) / 100;
  if (Random < (probability)) then
    Result := TDamageType.Normal;

  probability := ((Esquiva * 100) / (Acerto + Esquiva)) / 100;
  if (Random < probability) then
    Result := TDamageType.Miss;

  if (Result = TDamageType.Miss) then
  begin
    IncWORD(Self.MissCount, 1);

    if (Self.MissCount >= 3) then
    begin
      Result := TDamageType.Normal;
      Self.MissCount := 0;
    end
    else
      Exit;
  end;
{$ENDREGION}
{$REGION 'Calculando Critico x Resistencia Critico'}
  Critico := Self.PlayerCharacter.Base.CurrentScore.Critical + AditionalCrit;
  ResistenciaCrit := mob.PlayerCharacter.CritRes;

  probability := ((Critico * 100) / 255) / 100;
  if (Random < (probability + 0.1)) then
    Result := TDamageType.Critical;

  probability := ((ResistenciaCrit * 100) / 255) / 100;
  if (Random < probability) then
    Result := TDamageType.Normal;

  // TODO - Verificar esse buff
  if (Self.BuffExistsByID(6347)) then
    Result := TDamageType.Critical;

  IF (mob.BuffExistsByIndex(SkillData[BRUMA].Index)) then
    Result := TDamageType.Critical;

{$ENDREGION}
  case Result of
    Normal: // calcular o double
      begin
{$REGION 'Calculando duplo x resistencia a duplo'}
        if (Skill = 0) then
        begin
          Duplo := Self.PlayerCharacter.DuploAtk;
          ResistenciaDuplo := mob.PlayerCharacter.DuploRes;

          probability := ((Duplo * 100) / 255) / 100;
          if (Random < (probability + 0.1)) then
            Result := TDamageType.Double;

          probability := ((ResistenciaDuplo * 100) / 255) / 100;
          if (Random < probability) then
            Result := TDamageType.Normal;
        end;
{$ENDREGION}
      end;
    Critical: // Ativado
{$REGION 'Calculando duplo critico'}
      begin
        if (Skill = 0) then
        begin
          Duplo := Self.PlayerCharacter.DuploAtk;
          ResistenciaDuplo := mob.PlayerCharacter.DuploRes;

          probability := ((Duplo * 100) / 255) / 100;
          if (Random < (probability + 0.1)) then
            Result := TDamageType.DoubleCritical;

          probability := ((ResistenciaDuplo * 100) / 255) / 100;
          if (Random < probability) then
            Result := TDamageType.Critical;
        end;
      end;
{$ENDREGION}
  end;
end;

procedure TBaseMob.CalcAndCure(Skill: DWORD; mob: PBaseMob;
  ExtraHeal: Integer = 0);
var
  Cure: Cardinal;
  curePerc: Integer;
begin

  var
  cureTaxFromBuff := Self.GetMobAbility(214);
  var
  CureTax := 0;

  TAttributeFunctions.GetCureTax(PlayerCharacter.Base.CurrentScore,
    cureTaxFromBuff, CureTax);

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);

  if (SkillData[Skill].CastTime <= 1) then
  begin
    CureTax := Trunc((CureTax div 100) * 0.48);
  end;

  Inc(Cure, SkillData[Skill].Damage);

  Inc(Cure, CureTax);

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Inc(Cure, ExtraHeal);

  Randomize;
  curePerc := ((RandomRange(20, 199) div 2) + 35);
  Inc(Cure, curePerc);

  deccardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;

    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;

    Exit;
  end
  else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0))
  then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);

    mob.NegarCuraCount := mob.NegarCuraCount - 1;
    mob.LastReceivedAttack := Now;
    if (mob.NegarCuraCount = 0) then
    begin
      mob.RemoveBuffByIndex(88);
    end;

    Exit;
  end;

  var
  Critico := Self.PlayerCharacter.Base.CurrentScore.Critical;
  var
  probability := ((Critico * 100) / (Critico * 2)) / 100;
  if (Random < (probability)) then
  begin
    Inc(Cure, (Cure div 100) * (40 + Self.PlayerCharacter.DamageCritical));
  end;

  mob.AddHP(Cure, True);

  if (mob.ClientID = Self.ClientID) then
  begin
    Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
      ('Seu HP foi restaurado em ' + AnsiString(Cure.ToString), 16);
  end
  else
  begin
    Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
      ('Seu HP foi restaurado em ' + AnsiString(Cure.ToString) + ' por [' +
      AnsiString(Self.Character.Name) + '].', 16);
  end;
end;

function TBaseMob.CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  var
  cureTaxFromBuff := Self.GetMobAbility(214);
  var
  CureTax := 0;

  TAttributeFunctions.GetCureTax(PlayerCharacter.Base.CurrentScore,
    cureTaxFromBuff, CureTax);

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);

  if (SkillData[Skill].CastTime <= 1) then
  begin
    CureTax := Trunc((CureTax div 100) * 0.48);
  end;

  Inc(Cure, SkillData[Skill].Damage);

  Inc(Cure, CureTax);

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 199) div 2) + 35);
  Inc(Cure, curePerc);

  deccardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;

    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;

    Exit;
  end
  else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0))
  then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;

    if (mob.NegarCuraCount = 0) then
    begin
      mob.RemoveBuffByIndex(88);
    end;

    Exit;
  end;

  Result := Cure;
end;

function TBaseMob.CalcCure2(BaseCure: DWORD; mob: PBaseMob;
  xSkill: Integer): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);
  Cure := Cure + BaseCure;

  if (xSkill > 0) then
  begin
    Inc(Cure, SkillData[xSkill].Damage);
  end;

  Inc(Cure, ((Cure div 100) * Self.PlayerCharacter.CureTax));

  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  deccardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if (SkillData[xSkill].Index <> 125) then
  begin
    if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
    begin
      mob.NegarCuraCount := 3;

      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)),
        True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount - 1;

      Exit;
    end
    else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0))
    then
    begin
      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)),
        True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount - 1;

      if (mob.NegarCuraCount = 0) then
      begin
        mob.RemoveBuffByIndex(88);
      end;

      Exit;
    end;
  end;

  Result := Cure;
end;

procedure TBaseMob.HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SelectedPos: TPosition; DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  gotDano: Integer;
  gotDMGType: TDamageType;
  Add_Buff: Boolean;
  Resisted: Boolean;
  DropExp, DropItem: Boolean;
  j: Integer;
  s: Integer;
  Helper2: Byte;
  SelfPlayer, OtherPlayer: PPlayer;
  // Mobs: PMobSa;
  MobsP: PMobSPoisition;
  Rand: Integer;
begin
  s := sizeof(Packet);
  ZeroMemory(@Packet, s);
  Packet.Header.size := s;
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  gotDano := 0;
  if (Self.IsSecureArea) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Voc� est� em uma �rea segura, n�o pode lan�ar skills.');
    Exit;
  end;
  if (mob^.IsSecureArea) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('O alvo est� dentro de uma �rea segura e n�o foi afetado pela sua habilidade.');
    Exit;
  end;
  if (mob^.ClientID = Self.ClientID) then
    Packet.TargetID := Self.ClientID
  else
    Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;

  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  if (DataSkill^.SuccessRate = 1) and (DataSkill^.range = 0) then
  begin // skills de ataque single[Target]
    Resisted := False;
    case Self.GetMobClass() of
      2:
        begin
          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);
          end;
        end;

      3:
        begin
          if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
          begin
            TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
            Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
              Self.Character.Equip[15], False);
          end;
        end;
    end;
    Self.TargetSkill(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff, Resisted);

    if (gotDano > 0) then
    begin
      Self.AttackParse(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff,
        Packet.MobAnimation, DataSkill);

      if (gotDano > 0) then
      begin
        Inc(gotDano, ((RandomRange((gotDano div 20), (gotDano div 10))) + 13));
      end;
    end
    else
    begin
      if not(gotDMGType in [Critical, Normal, Double, DoubleCritical]) then
        Add_Buff := False;
    end;

    if (Add_Buff = True) then
    begin
      if not(Resisted) then
        Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
    end;
    Packet.Dano := gotDano;
    Packet.DnType := gotDMGType;

    MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[0].MobsP[1];
    if (mob^.SecondIndex > 0) then
      MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
        [mob^.SecondIndex];

    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      if (SecondsBetween(Now, mob.RevivedTime) <= 7) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('Alvo acabou de nascer.');
        Exit;
      end;

      OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        if (OtherPlayer^.Dueling) then
        begin
          mob^.Character.CurrentScore.CurHP := 10;
        end
        else
        begin
          mob^.Character.CurrentScore.CurHP := 0;
          mob^.SendEffect($0);
          Packet.MobAnimation := 30;
          mob^.IsDead := True;
          if (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare)
          then
            Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
              (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
          begin
            if ((mob^.Character.Nation <> Self.Character.Nation) or
              (Self.InClastleVerus)) then
            begin
              Self.PlayerKilled(mob);
            end;
          end;
        end;
      end
      else
      begin
        if (Packet.Dano > 0) then
          mob^.RemoveHP(Packet.Dano, False);
        if (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare)
        then
          Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
            (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
        if (gotDMGType in [Miss, Miss2, TDamageType.Block, Immune]) then
        begin
          Packet.MobAnimation := 0;
        end;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;

      Exit;
    end
    else if (((mob^.ClientID >= 3048) and (mob^.ClientID < 9148)) or
      (MobsP.isTemp)) then
    begin
      // Mobs := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid];
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
              not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .IsAttacked := False;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .KillStone(mob^.ClientID, Self.ClientID);
              if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if (Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains
                  (mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove
                    (mob^.ClientID);
                  Servers[Self.ChannelId].Players[j]
                    .Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;
          end;
        3355 .. 3369:
          begin // guards
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
              not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .IsAttacked := False;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .KillGuard(mob^.ClientID, Self.ClientID);
              if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if (Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains
                  (mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove
                    (mob^.ClientID);
                  Servers[Self.ChannelId].Players[j]
                    .Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            // Sleep(1);
            Exit;
          end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];

          if not(MobsP.IsAttacked) then
          begin
            MobsP.FirstPlayerAttacker := Self.ClientID;
          end;

          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 0;
            MobsP^.IsAttacked := False;
            MobsP^.AttackerID := 0;
            MobsP^.deadTime := Now;

            MobsP.Base.SendEffect($0);
            if (Self.VisibleMobs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleMobs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
            end;
            for j in Self.VisiblePlayers do
            begin
              if (Servers[Self.ChannelId].Players[j].Base.VisibleMobs = nil)
              then
              begin
                if (Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains
                  (mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
                    (mob^.ClientID);
                  Servers[Self.ChannelId].Players[j]
                    .Base.RemoveTargetFromList(mob);
                end;
              end;
            end;
            // ver aquele bang de tirar na lista propia
            mob^.VisibleMobs.Clear;
            mob^.IsDead := True;
            { Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
              ('Adquiriu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
              .MobExp.ToString) + ' + ' +
              AnsiString((Servers[Self.ChannelId].Players[Self.ClientId]
              .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
              EXP_TYPE_MOB) - Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp)
              .ToString) + ' exp.', 0); }
            Self.MobKilled(mob, DropExp, DropItem, False);
            Packet.MobAnimation := 30;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end;

          // Sleep(1);
          Exit;
        end;
      end;
    end
    else if (mob^.ClientID >= 9148) then
    begin
      Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP) then
      begin
        mob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
        Packet.MobAnimation := 30;
        mob.IsDead := True;
        var
        RlkSlot := TItemFunctions.GetItemSlotByItemType
          (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
        if (RlkSlot <> 255) then
        begin
          var
            Item: PItem := @Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.Character.Inventory[RlkSlot];
          var
          index := Item.Index;
          ZeroMemory(Item, sizeof(TItem));
          Servers[Self.ChannelId].Players[Self.ClientID]
            .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          Servers[Self.ChannelId].Players[Self.ClientID].SendEffect(0);
          Servers[Self.ChannelId].CreateMapObject(@Self, 320, index);
        end;
        if (Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        begin
          if (Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
            Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet
              (mob.ClientID);
        end;
      end
      else
      begin
        deccardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP, Packet.Dano);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
    end;
  end;
  if (DataSkill^.SuccessRate = 0) and (DataSkill^.range = 0) then
  begin
    Packet.DnType := TDamageType.None;
    Packet.Dano := 0;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;

    if (Self.IsCompleteEffect5(Helper2)) then
    begin
      Randomize;
      Rand := RandomRange(1, 101);
      if (Rand <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
      begin
        Self.Effect5Skill(@Self, Helper2, True);
      end;
    end;

    if (DataSkill^.TargetType = 1) then
    begin // [Self]
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Self.SelfBuffSkill(Skill, Anim, mob, SelectedPos);
    end
    else
    begin // [Target]
      // Self.SendCurrentHPMP;
      if (DataSkill^.Classe >= 61) and (DataSkill^.Classe <= 84) then
      begin // skills de pran
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              Packet.AttackerPos := SelfPlayer^.Account.Header.Pran1.Position;
              Packet.AttackerID := SelfPlayer^.Account.Header.Pran1.id;
              Packet.TargetID := Self.ClientID;
              Randomize;
              Rand := RandomRange(1, 225);
              if (Rand > SelfPlayer^.Account.Header.Pran1.Devotion) then
              begin
                SelfPlayer^.SendClientMessage
                  ('Pran se recusou por conta da familiaridade.');
                Self.SendToVisible(Packet, Packet.Header.size);
                Exit;
              end;
            end;
          1:
            begin
              Packet.AttackerPos := SelfPlayer^.Account.Header.Pran2.Position;
              Packet.AttackerID := SelfPlayer^.Account.Header.Pran2.id;
              Packet.TargetID := Self.ClientID;
              Randomize;
              Rand := RandomRange(1, 225);
              if (Rand > SelfPlayer^.Account.Header.Pran2.Devotion) then
              begin
                SelfPlayer^.SendClientMessage
                  ('Pran se recusou por conta da familiaridade.');
                Self.SendToVisible(Packet, Packet.Header.size);
                Exit;
              end;
            end;
        end;
      end;
      Self.SendToVisible(Packet, Packet.Header.size);
      // Sleep(1);
      Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
    end;
    Exit;
  end;
  if (DataSkill^.SuccessRate = 0) and (DataSkill^.range > 0) then
  begin // skills de buff em area [ou em party]
    if (Self.IsCompleteEffect5(Helper2)) then
    begin
      Randomize;
      Rand := RandomRange(1, 101);
      if (Rand <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
      begin
        Self.Effect5Skill(@Self, Helper2, True);
      end;
    end;

    Packet.DnType := TDamageType.None;
    Packet.Dano := 0;
    Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
    Packet.DeathPos := SelectedPos;
    Packet.TargetID := Self.ClientID;
    Self.SendToVisible(Packet, Packet.Header.size);
    Self.AreaBuff(Skill, Anim, mob, Packet);
    Exit;
  end;
end;

function TBaseMob.ValidAttack(DmgType: TDamageType; DebuffType: Byte;
  mob: PBaseMob; AuxDano: Integer; xisBoss: Boolean): Boolean;
var
  Rate: Integer;
  Rand: Integer;
  VerifyToCastle: Boolean;
begin
  Result := False;
  VerifyToCastle := False;
  case DmgType of
    Normal, Critical, Double, DoubleCritical:
      begin
        Result := True;
      end;
    Miss, Miss2, TDamageType.Block, Immune:
      begin
        Result := False;
        Exit;
      end;
  end;
  if (mob = nil) then
    Exit;
  if (mob^.ClientID >= 3048) or (mob^.IsDungeonMob) then
  begin
    if ((mob.IsBoss) and not(xisBoss)) then
    begin
    end
    else
    begin
      Result := True;
    end;
  end
  else
  begin
    Result := True;
  end;

  if not(Result) then
    Exit;

  if (mob^.BuffExistsByIndex(36) = True) or (mob^.BuffExistsByIndex(365) = True)
  then
  begin
    dec(mob^.BolhaPoints, 1);

    // Remove buffs apenas se BolhaPoints chegou a zero
    if (mob^.BolhaPoints = 0) then
    begin
      if (mob^.BuffExistsByIndex(36)) then
        mob^.RemoveBuffByIndex(36);
      if (mob^.BuffExistsByIndex(365)) then
        mob^.RemoveBuffByIndex(365);

      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] Proteção desativada.', 16, 1, 1);
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] restam ' + mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
    end;

    Result := False;
    Exit;
  end;

  // Continuar com a lógica para debuffs
  if (Result = True) then
  begin
    if (DebuffType = 0) then
      Exit;

    Randomize;
    Rand := RandomRange(1, 255);
    Rate := Trunc(Self.PlayerCharacter.Resistence / 5);
    Rate := Rate + Self.GetMobAbility(EF_STATE_RESISTANCE);

    case DebuffType of
      STUN_TYPE:
        begin
          Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_STUN);
          if (Rand <= Rate) then
          begin
            Result := False;
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('[' + AnsiString(mob^.Character.Name) +
              '] resistiu à sua habilidade de stun.');
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Você resistiu à habilidade de stun de [' +
              AnsiString(Self.Character.Name) + '].');
          end
          else
          begin
            VerifyToCastle := True;
          end;
        end;
    end;
  end;

  case DebuffType of
    SILENCE_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SILENCE1);
        if (Rand <= Rate) then
        begin
          Result := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de silêncio.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de silêncio de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
        begin
          VerifyToCastle := True;
        end;
      end;
    FEAR_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_FEAR);
        if (Rand <= Rate) then
        begin
          Result := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de medo.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de medo de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
        begin
          VerifyToCastle := True;
        end;
      end;
    LENT_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_RUNSPEED);
        if (Rand <= Rate) then
        begin
          Result := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de lentidão.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de lentidão de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
        begin
          VerifyToCastle := True;
        end;
      end;
    CHOCK_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_SHOCK);
        if (Rand <= Rate) then
        begin
          Result := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de choque.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de choque de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
        begin
          VerifyToCastle := True;
        end;
      end;
    PARALISYS_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_IMMOVABLE);
        if (Rand <= Rate) then
        begin
          Result := False;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de paralisia.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de paralisia de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
        begin
          VerifyToCastle := True;
        end;
      end;
  end;

  if (VerifyToCastle) then
  begin
    if (mob^.InClastleVerus) then
    begin
      mob^.LastReceivedSkillFromCastle := Now;
    end;
  end;
end;

procedure TBaseMob.MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
  out DroppedItem: Boolean; InParty: Boolean);
var
  i, j: Integer;
  ExpAcquired, PranExpAcquired: Int64;
  MobExp, CalcAux, CalcAuxRlq: Integer;
  DropExp, DropItem: Boolean;
  A, HelperX: Integer;
  NIndex: WORD;
  RandomClientID: Integer;
  SelfPlayer: PPlayer;
  MobsP: PMobSPoisition;
begin
  Randomize;
  ExpAcquired := 0;
  PranExpAcquired := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  if (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].IntName = 1036) then
  begin
    Servers[mob^.ChannelId].CreateMapObject(SelfPlayer, 925, ALTAR_PRIZE);
    Exit;
  end;

  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin
    Exit;
  end
  else if ((mob^.ClientID >= 3048) and (mob^.ClientID <= 9147)) then
  begin
    MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];
  end
  else
    Exit;

  if (SelfPlayer^.PartyIndex <> 0) and (InParty = False) then
  begin
    A := 0;
    for i in SelfPlayer^.Party.Members do
    begin
      DropExp := False;
      DropItem := False;
      Servers[Self.ChannelId].Players[i].Base.MobKilled(mob, DropExp,
        DropItem, True);
      if (DropExp = True) then
        Inc(A);
    end;
    if (A = 0) then
    begin // cara de outra pt ou fora da pt quem atacou (Exp)
      if (MobsP^.FirstPlayerAttacker <> 0) then
      begin
        if not(MobsP^.FirstPlayerAttacker = Self.ClientID) then
        begin
          DropExp := False;
          DropItem := False;
          Servers[Self.ChannelId].Players[MobsP^.FirstPlayerAttacker]
            .Base.MobKilled(mob, DropExp, DropItem, False);
        end;
      end;
    end;
    Exit;
  end;

  if (TItemFunctions.GetEmptySlot(SelfPlayer^) = 255) then
  begin
    SelfPlayer.SendClientMessage
      ('Seu inventário está cheio. Recompensas não serão recebidas.');
    DropItem := False;
  end;

  HelperX := (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobLevel -
    Self.Character.Level);
  case HelperX of
    - 255 .. -8:
      begin // cinza
        MobExp := 1;
      end;
    -7 .. -5:
      begin // azul
        MobExp := Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid]
          .MobExp * 0.5);
      end;

    -4 .. 3: // amarelo
      begin
        MobExp := (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobExp * 1);
      end;

    4 .. 5: // laranja
      begin
        MobExp := Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid]
          .MobExp * 1.5);
      end;

    6 .. 255: // roxo
      begin
        MobExp := Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid]
          .MobExp * 0.2);
      end;

  else
    MobExp := (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobExp * 1);
  end;

  if not(MobExp = 1) then
  begin
    MobExp := MobExp * 4;
  end;

  if (Self.Character <> nil) then
    if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      MobExp := MobExp + ((MobExp div 100) * Servers[Self.ChannelId].ReliqEffect
        [EF_RELIQUE_PER_EXP]);
    end;

  try
    if (InParty) then
    begin // est� em grupo
      if not(MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 25)) then
        Exit;
      case SelfPlayer^.Party.ExpAlocate of
        1: // igualmente
          begin
            j := 0;
            for i in SelfPlayer^.Party.Members do
            begin
              if (Self.PlayerCharacter.LastPos.Distance(Servers[Self.ChannelId]
                .Players[i].Base.PlayerCharacter.LastPos) <= DISTANCE_TO_WATCH)
              then
              begin
                j := j + 1;
              end;
            end;

            if (j = 0) then
              j := 1;

            MobExp := (MobExp div j);
            if (MobExp = 0) then
              MobExp := 1;
            ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
            DroppedExp := True;
          end;
        2: // individualmente
          begin
            if (MobsP^.FirstPlayerAttacker <> 0) then
            begin
              if (Self.ClientID = MobsP^.FirstPlayerAttacker) then
              begin
                ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq,
                  EXP_TYPE_MOB);
                DroppedExp := True;
              end;
            end
            else
            begin
              ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq,
                EXP_TYPE_MOB);
              DroppedExp := True;
            end;
          end;
      end;
      if (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].InitHP > 999999) then
      begin // MobsP
        if (Servers[mob^.ChannelId].Players[Self.ClientID].Party.InRaid) then
        begin
          for i in Servers[mob^.ChannelId].Players[Self.ClientID]
            .Party.Members do
          begin
            if (RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
            end;
          end;

          for i := 1 to 3 do
          begin
            if (Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied
              [i] = 0) then
              Continue;
            for j in Servers[mob^.ChannelId].Parties
              [Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied
              [i]].Members do
            begin
              if (RandomRange(0, 2) = 1) then
              begin
                DroppedItem := True;
                Self.DropItemFor(@Servers[mob^.ChannelId].Players[j].Base, mob);
              end;
            end;
          end;
        end
        else
        begin
          for i in Servers[mob^.ChannelId].Players[Self.ClientID]
            .Party.Members do
          begin
            if (RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
            end;
          end;
        end;
      end
      else
      begin
        case SelfPlayer^.Party.ItemAlocate of
          1: // em ordem
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                var
                helpdrop := 0;
                if (Self.ClientID = SelfPlayer^.Party.Leader) then
                begin
                  var
                    drops: Integer := System.Math.RandomRange(0, 5);

                  var
                    mobt: PMobSa := @Servers[mob.ChannelId].MOBS.TMobS
                      [mob.Mobid];

                  if (mobt.MobType = 0) then
                  begin
                    Randomize;
                    drops := System.Math.RandomRange(1, 15);
                  end;

                  while helpdrop < drops do
                  begin
                    NIndex := SelfPlayer^.Party.LastSlotItemReceived;
                    Inc(SelfPlayer^.Party.LastSlotItemReceived);
                    DroppedItem := True;
                    Self.DropItemFor(@Servers[Self.ChannelId].Players
                      [SelfPlayer^.Party.Members.ToArray[NIndex]].Base, mob);
                    if (NIndex >= (SelfPlayer^.Party.Members.Count - 1)) then
                      SelfPlayer^.Party.LastSlotItemReceived := 0;
                    Inc(helpdrop, 1);
                  end;
                end;
              end;
            end;
          2: // aleatorio
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                var
                  drops: Integer := System.Math.RandomRange(0, 5);

                var
                  mobt: PMobSa := @Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid];

                if (mobt.MobType = 0) then
                begin
                  Randomize;
                  drops := System.Math.RandomRange(1, 15);
                end;
                RandomClientID := SelfPlayer^.Party.Members.ToArray
                  [RandomRange(0, SelfPlayer^.Party.Members.Count)];
                DroppedItem := True;

                Self.DropItemFor(@Servers[Self.ChannelId].Players
                  [RandomClientID].Base, mob, 1);
              end;
            end;
          3: // individual
            begin

              if not(Self.ClientID = Servers[mob^.ChannelId].MOBS.TMobS
                [mob^.Mobid].MobsP[mob.SecondIndex].FirstPlayerAttacker) then
              begin
                Exit;
              end;

              if (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
                [mob.SecondIndex].FirstPlayerAttacker > 0) then
              begin
                if (Servers[Self.ChannelId].Players
                  [Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
                  [mob.SecondIndex].FirstPlayerAttacker].Status >= Playing) then
                begin
                  if not(Servers[Self.ChannelId].Players
                    [Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
                    [mob.SecondIndex].FirstPlayerAttacker].SocketClosed) then
                  begin
                    var
                      drops: Integer := System.Math.RandomRange(0, 5);

                    var
                      mobt: PMobSa := @Servers[mob.ChannelId].MOBS.TMobS
                        [mob.Mobid];

                    if (mobt.MobType = 0) then
                    begin
                      Randomize;
                      drops := System.Math.RandomRange(1, 15);
                    end;

                    Self.DropItemFor(@Self, mob, drops);
                    DroppedItem := True;
                  end;
                end;
              end;
            end;
          4: // lider
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                var
                  drops: Integer := System.Math.RandomRange(0, 5);

                var
                  mobt: PMobSa := @Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid];

                if (mobt.MobType = 0) then
                begin
                  Randomize;
                  drops := System.Math.RandomRange(1, 15);
                end;

                Self.DropItemFor(@Self, mob, drops);
              end;
            end;
        end;
      end;
    end
    else // n�o est� em grupo
    begin
      ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
      var
        drops: Integer := System.Math.RandomRange(0, 5);

      var
        mobt: PMobSa := @Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid];

      if (mobt.MobType = 0) then
      begin
        drops := System.Math.RandomRange(1, 15);
      end;

      Self.DropItemFor(@Self, mob, drops);

    end;
  except
    Logger.Write('erro na entrega em grupo de xp / solo', TLogType.Error);
  end;
  try
    if not(ExpAcquired = 0) then
    begin
      try
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              case SelfPlayer^.Account.Header.Pran1.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 3 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                4: // pran fada ~ pran crian�a
                  begin
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      61, 71, 81:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0,
                            1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                        // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                5 .. 18: // pran crian�a
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                19: // pran crian�a ~ pran adolescente
                  begin
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      62, 72, 82:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0,
                            1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                        // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                      begin
                        SelfPlayer^.AddPranLevel(0);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                49:
                  begin // pran adolescente ~ pran adulta
                    case SelfPlayer^.Account.Header.Pran1.ClassPran of
                      63, 73, 83:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0,
                            1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                        // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                        // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
              end;
            end;
          1:
            begin
              case SelfPlayer^.Account.Header.Pran2.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 3 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                4: // pran fada ~ pran crian�a
                  begin
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      61, 71, 81:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0,
                            1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                        // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                5 .. 18: // pran crian�a
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                19: // pran crian�a ~ pran adolescente
                  begin
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      62, 72, 82:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0,
                            1);
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                        // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                      begin
                        SelfPlayer^.AddPranLevel(1);
                      end;
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
                49:
                  begin // pran adolescente ~ pran adulta
                    case SelfPlayer^.Account.Header.Pran2.ClassPran of
                      63, 73, 83:
                        begin
                          SelfPlayer^.SendClientMessage
                            ('A sua pran precisa evoluir para ganhar exp.', 0,
                            1);
                          PranExpAcquired := 0;
                        end;
                    else
                      begin
                        PranExpAcquired := (ExpAcquired div 3);
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                        // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                        // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                      end;
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    // SelfPlayer^.SendClientMessage('Sua pran adquiriu ' +
                    // AnsiString(PranExpAcquired.ToString) + ' exp.', 0, 1);
                  end;
              end;
            end;
        end;
      except
        Logger.Write('erro no bghls das prans quando mata', TLogType.Error);
      end;

      if (Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP] > 0) then
      begin
        CalcAux := (Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP] *
          (CalcAuxRlq div 100));
        if (SelfPlayer^.SpawnedPran <> 255) then
          SelfPlayer^.SendClientMessage
            ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired - CalcAux)) +
            ' exp + ' + AnsiString(IntToStr(CalcAux)) + ', Pran ' +
            AnsiString(IntToStr(PranExpAcquired)) + '.', 0)
        else
          SelfPlayer^.SendClientMessage
            ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired - CalcAux)) +
            ' exp + ' + AnsiString(IntToStr(CalcAux)) + '.', 0);
      end
      else
      begin
        if (SelfPlayer^.SpawnedPran <> 255) then
          SelfPlayer^.SendClientMessage
            ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)) + ' exp, Pran ' +
            AnsiString(IntToStr(PranExpAcquired)) + '.', 0)
        else
          SelfPlayer^.SendClientMessage
            ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)) + ' exp.', 0);
      end;
    end;
  except
    Logger.Write('erro na msg de xp', TLogType.Error);
  end;

  try
    for i := 0 to 49 do
    begin
      if (SelfPlayer^.PlayerQuests[i].id > 0) then
      begin // se existir quest no jogador
        if not(SelfPlayer^.PlayerQuests[i].IsDone) then
        begin // se a quest ainda n�o foi entregue
          for j := 0 to 4 do
          begin // checa cada requiriment de mob
            if (SelfPlayer^.PlayerQuests[i].Quest.RequirimentsType[j] = 1) then
            // se o requiriment checado for de mob kill
            begin
              if (SelfPlayer^.PlayerQuests[i].Quest.Requiriments[j] = Servers
                [mob^.ChannelId].MOBS.TMobS[mob^.Mobid].IntName) then
              // se o mob morto for o mesmo da quest
              begin
                Inc(SelfPlayer^.PlayerQuests[i].Complete[j]);
                if (SelfPlayer^.PlayerQuests[i].Complete[j] >=
                  SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j]) then
                begin
                  SelfPlayer^.PlayerQuests[i].Complete[j] :=
                    SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j];
                  SelfPlayer^.SendClientMessage('Voc� completou a quest [' +
                    AnsiString(Quests[SelfPlayer^.PlayerQuests[i].Quest.QuestID]
                    .Titulo) + ']');
                  // aqui vai o aviso de quest completa
                end;
                SelfPlayer^.UpdateQuest(SelfPlayer^.PlayerQuests[i].id);
              end;
            end;
          end;
        end;
      end;
    end;
  except
    Logger.Write('erro na contagem da quest pra atualizar', TLogType.Error);
  end;
end;

procedure TBaseMob.DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob;
  maxDropCount: Integer = 1);
var
  IncreasedDropTax: Integer;
  drops: TMobDrops2;
  ItemID, drop, aux1, aux2, aux3, j, k: Integer;
begin
  IncreasedDropTax := 0;

  if (Drops2.TryGetValue(mob.MobDbId, drops) = False) then
    Exit;

  if (Self.Character = nil) then
    Exit;

  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Inc(IncreasedDropTax, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_DROP_RATE]);
  end;

  if (Self.GetMobAbility(EF_PARTY_PER_DROP_RATE) > 0) then
    Inc(IncreasedDropTax, Self.GetMobAbility(EF_PARTY_PER_DROP_RATE));

  for var dropCount := 0 to maxDropCount do
  begin
    ItemID := Util.SelectRandomDrop(drops,IncreasedDropTax);

    if (ItemID = 0) then
      Exit;

    if (ItemList[ItemID].ItemType = 713) then
    begin
      for k := Low(Servers) to High(Servers) do
      begin
        for aux1 := 0 to 4 do
        begin
          for j := 0 to 4 do
          begin
            if (Servers[k].Devires[aux1].Slots[j].ItemID <> 0) then
            begin
              if (ItemList[Servers[k].Devires[aux1].Slots[j].ItemID]
                .UseEffect = ItemList[ItemID].UseEffect) then
                Exit;
            end;
          end;
        end;

        for aux2 := Low(Servers[k].OBJ) to High(Servers[k].OBJ) do
        begin
          if (Servers[k].OBJ[aux2].ContentItemID = 0) then
            Continue;

          if (ItemList[Servers[k].OBJ[aux2].ContentItemID].UseEffect = ItemList
            [ItemID].UseEffect) then
            Exit;
        end;

        for aux3 := Low(Servers[k].Players) to High(Servers[k].Players) do
        begin
          if not(Servers[k].Players[aux3].Status >= Playing) then
            Continue;

          for j := 0 to 59 do
          begin
            if (Servers[k].Players[aux3].Base.Character.Inventory[j].Index = 0)
            then
              Continue;

            if (Servers[k].Players[aux3].Base.Character.Inventory[j].
              Index = ItemID) then
            begin
              Exit;
            end;

            if (ItemList[Servers[k].Players[aux3].Base.Character.Inventory[j].
              Index].ItemType = 40) then
            begin
              if (ItemList[Servers[k].Players[aux3].Base.Character.Inventory[j].
                Index].UseEffect = ItemList[ItemID].UseEffect) then
                Exit;
            end;
          end;
        end;
      end;

      Servers[Self.ChannelId].SendServerMsg('Jogador <' + Self.Character.Name +
        '> encontrou o [' + ItemList[ItemID].Name + '].', 32, 0, 16);
    end;

    if (TItemFunctions.GetItemEquipSlot(ItemID) = 0) then
      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
        ItemID, 1)
    else
      TItemFunctions.PutEquipament(Servers[Self.ChannelId].Players
        [Self.ClientID], ItemID);
  end;
end;

procedure TBaseMob.PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
var
  i, j: Integer;
  Party: PParty;
  Honor: Integer;
  RlkSlot: Byte;
  Item: PItem;
  TitleGoaled: Boolean;
  RandomTax: Integer; // Variável para controle de chance
  Nation: Integer; // Contador de kills da mesma nação
begin
  var
  red := mob.GetMobAbility(EF_BLANK16);
  mob.DecreasseMobAbility(EF_BLANK16, red);
  mob.RemoveBuffByIndex(35);
  mob.UniaoDivina := '';

  // Inicializa o contador de kills da mesma nação
  Nation := Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.Nation; // Ajuste conforme sua estrutura

  if (xRlkSlot = 0) then
    RlkSlot := TItemFunctions.GetItemSlotByItemType
      (Servers[Self.ChannelId].Players[mob^.ClientID], 40, INV_TYPE, 0)
  else
    RlkSlot := xRlkSlot;

  if (RlkSlot <> 255) then
  begin
    Item := @mob^.Character.Inventory[RlkSlot];
    var
    index := Item.Index;
    ZeroMemory(Item, sizeof(TItem));
    mob.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
    RlkSlot := TItemFunctions.GetItemSlotByItemType
      (Servers[Self.ChannelId].Players[mob^.ClientID], 40, INV_TYPE, 0);
    mob.SendEffect(0);

    Servers[Self.ChannelId].CreateMapObject(@Servers[Self.ChannelId].Players
      [Self.ClientID], 320, index);

    if (RlkSlot <> 255) then
    begin
      Self.PlayerKilled(mob, RlkSlot);
      Exit;
    end;
    Servers[Self.ChannelId].Players[mob^.ClientID].SendEffect(0);
  end;

  if (mob^.BuffExistsByIndex(126)) then
  begin // efeito duradouro
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Alvo está sob Efeito Duradouro. Impossível receber PvP/Honra.');
    Exit;
  end
  else
  begin
    if not(mob.InClastleVerus) then
      mob^.AddBuff(6471);
  end;

  if (Self.BuffExistsByIndex(126)) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Você está sob Efeito Duradouro. Impossível receber PvP/Honra.');
    Exit;
  end;

  if (mob.Character.Level < 25) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Você só pode receber PvP de alvos acima do Nv 25.');
    Exit;
  end;

  if (Self.Character.Level < 25) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Você só pode receber PvP de alvos acima do Nv 25.');
    Exit;
  end;

  if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex <> 0) then
  begin
    Party := Servers[Self.ChannelId].Players[Self.ClientID].Party;
    for i in Party.Members do
    begin
      if not(i = Self.ClientID) then
      begin
        if not(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
          InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
          Continue;
      end;

      Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
        KillPoint, 1);
      Servers[Self.ChannelId].Players[i].SendClientMessage
        ('Seus pontos de PvP foram incrementados.');
      Honor := HONOR_PER_KILL;
      Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
        Honor, Honor);
      Servers[Self.ChannelId].Players[i].SendClientMessage
        ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
      Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();

      // Verifica se o jogador tem o buff que impede o recebimento de itens
      if (Self.BuffExistsByIndex(126)) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('Você está sob Efeito Duradouro. Impossível receber PvP/Honra.');
        Exit;
      end;

      RandomTax := Random(100); // Gera um número aleatório entre 0 e 99
      if (RandomTax < 30) then // 30% de chance (0 a 29)
      begin
        TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID], 11285, SKULL_MULTIPLIER);
      end;

      TitleGoaled := False;

      for j := 0 to 95 do
      begin
        if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].
          Index = 0) then
          Continue;

        if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j].
          Index = 27) then
        begin
          Inc(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j]
            .Progress, 1);

          if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j]
            .Progress >= Titles[27].TitleLevel[Servers[Self.ChannelId].Players
            [i].Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
          begin
            Servers[Self.ChannelId].Players[i].UpdateTitleLevel(27,
              Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.PlayerCharacter.Titles[j].Level + 1, True);
            Servers[Self.ChannelId].Players[i].SendClientMessage
              ('Seu título [' + Titles[27].TitleLevel
              [Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.Titles[j]
              .Level].TitleName + '] foi atualizado.');
          end
          else
            Servers[Self.ChannelId].Players[i].UpdateTitleLevel(27,
              Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.PlayerCharacter.Titles[j].Level, False);

          TitleGoaled := True;
          break;
        end;
      end;

      if not(TitleGoaled) then
      begin
        Servers[Self.ChannelId].Players[i].AddTitle(27, 0, False);
      end;

      { if (Servers[Self.ChannelId].Players[i].Character.Base.GuildIndex > 0) then
        begin
        //Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
        //.Exp, Honor);
        for j := 0 to 127 do
        begin
        if (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
        .Members[j].Logged) then
        begin
        <<<<<<< HEAD
        Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level);
        GuildLeveled := true;
        end;
        Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Exp, Honor);
        //Servers[Self.ChannelId].Players[i].SendClientMessage('Pontos de experi�ncia da legi�o foram incrementados em '+
        //Honor.ToString + ' pontos.');
        for j := 0 to 127 do
        begin
        if (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
        .Members[j].Logged) then
        =======
        for k := Low(Servers) to High(Servers) do
        >>>>>>> parent of a46c38b (30)
        begin
        if (Servers[k].GetPlayerByCharIndex
        (Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot]
        .Members[j].CharIndex, GuildPlayer)) then
        begin
        if (GuildPlayer.Status >= Playing) then
        begin
        Servers[k].Players[GuildPlayer.Base.ClientID].SendGuildInfo;
        end;
        break;
        end;
        end;
        end;
        end;
        end; }
    end;
  end
  else
  begin
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.KillPoint, 1);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Seus pontos de PvP foram incrementados.');
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.Honor, HONOR_PER_KILL);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Adquiriu ' + AnsiString(IntToStr(HONOR_PER_KILL)) +
      ' pontos de honra.');
    Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshKills();

    RandomTax := Random(100); // Gera um número aleatório entre 0 e 99
      if (RandomTax < 15) then // 30% de chance (0 a 29)
      begin
        TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID], 11285, SKULL_MULTIPLIER);
      end;

    TitleGoaled := False;

    for j := 0 to 95 do
    begin
      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.PlayerCharacter.Titles[j].Index = 0) then
        Continue;

      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.PlayerCharacter.Titles[j].Index = 27) then
      begin
        Inc(Servers[Self.ChannelId].Players[Self.ClientID]
          .Base.PlayerCharacter.Titles[j].Progress, 1);

        if (Servers[Self.ChannelId].Players[Self.ClientID]
          .Base.PlayerCharacter.Titles[j].Progress >= Titles[27].TitleLevel
          [Servers[Self.ChannelId].Players[Self.ClientID]
          .Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27,
            Servers[Self.ChannelId].Players[Self.ClientID]
            .Base.PlayerCharacter.Titles[j].Level + 1, True);
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Seu título [' + Titles[27].TitleLevel
            [Servers[Self.ChannelId].Players[Self.ClientID]
            .Base.PlayerCharacter.Titles[j].Level].TitleName +
            '] foi atualizado.');
        end
        else
          Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27,
            Servers[Self.ChannelId].Players[Self.ClientID]
            .Base.PlayerCharacter.Titles[j].Level, False);

        TitleGoaled := True;
        break;
      end;
    end;

    if not(TitleGoaled) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].AddTitle(27, 0, False);
    end;
    { if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex > 0) then
      begin
      Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Exp, HONOR_PER_KILL);
      for j := 0 to 127 do
      begin
      if (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Members[j].Logged) then
      begin
      <<<<<<< HEAD
      Inc(Guilds[Servers[Self.ChannelId].Players[i].Character.GuildSlot].Level);
      GuildLeveled := true;
      end;
      Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Exp, HONOR_PER_KILL);
      //Servers[Self.ChannelId].Players[i].SendClientMessage('Pontos de experi�ncia da legi�o foram incrementados em '+
      //Honor.ToString + ' pontos.');
      for j := 0 to 127 do
      begin
      if (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Members[j].Logged) then
      =======
      for k := Low(Servers) to High(Servers) do
      >>>>>>> parent of a46c38b (30)
      begin
      if (Servers[k].GetPlayerByCharIndex
      (Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Members[j].CharIndex, GuildPlayer)) then
      begin
      if (GuildPlayer.Status >= Playing) then
      begin
      Servers[k].Players[GuildPlayer.Base.ClientID].SendGuildInfo;
      end;
      break;
      end;
      end;
      end;
      end;
      end; }
  end;
end;

procedure TBaseMob.SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
  Pos: TPosition);
var
  h1: Integer;
begin
  if not((SkillData[Skill].Classe >= 61) and (SkillData[Skill].Classe <= 84))
  then
  begin
    if ((Self.BuffExistsByIndex(53)) or (Self.BuffExistsByIndex(77))) then
    begin
      Self.RemoveBuffByIndex(53);
      Self.RemoveBuffByIndex(77);
    end;
  end;
  case SkillData[Skill].Classe of
    1, 2:
      begin
        WarriorSelfBuffSkill(Skill, Anim, mob, Pos);
      end;
    21, 22:
      begin
        RiflemanSelfBuffSkill(Skill, Anim, mob, Pos);
      end;
    41, 42:
      begin
        MagicianSelfBuffSkill(Skill, Anim, mob, Pos);
      end;
    11, 12:
      begin
        TemplarSelfBuffSkill(Skill, Anim, mob, Pos);
      end;
    31, 32:
      begin
        DualGunnerSelfBuffSkill(Skill, Anim, mob, Pos);
      end;
    51, 52:
      begin
        ClericSelfBuffSkill(Skill, Anim, mob, Pos);
      end;
  else
    begin
      case SkillData[Skill].Index of
        124, 127, 137, 160:
          begin
            Self.AddBuff(Skill, True, True,
              (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
          end;
        208: // faz parte dos efeitos 5, essa aq pode ser recupercao de hp ou mp
          begin
            if (SkillData[Skill].Damage = 200) then
            begin // recupera mp
              Self.AddMP(((Self.Character.CurrentScore.MaxMP div 100) *
                15), True);
            end;
            if (SkillData[Skill].Damage = 300) then
            begin // recupera hp
              Self.AddHP(((Self.Character.CurrentScore.MaxHP div 100) *
                15), True);
            end
            else
            begin
              Self.AddBuff(Skill);
            end;
          end;
        337:
          begin
            Self.RemoveAllDebuffs;
          end;
        196, 220, 244: // forma fa�rica da pran
          begin
            if (Servers[Self.ChannelId].Players[Self.ClientID]
              .FaericForm = False) then
            begin
              h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;
              Servers[Self.ChannelId].Players[Self.ClientID]
                .SendPranUnspawn(h1, 0);
              Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := True;
              Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn
                (h1, 0, 0);
            end
            else
            begin
              h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;
              Self.SendEffect(0);
              Servers[Self.ChannelId].Players[Self.ClientID].FaericForm
                := False;
              Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn
                (h1, 0, 0);
            end;

            if (Self.PetClientID > 0) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID]
                .UnspawnPet(Self.PetClientID);
            end;
          end;
      else
        begin
          Self.AddBuff(Skill);
        end;
      end;
    end;
  end;
end;

procedure TBaseMob.TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData; Posx, Posy: DWORD);
var
  Helper, Helper2: Integer;
begin

  case SkillData[Skill].Classe of
    1, 2:
      begin
        WarriorTargetBuffSkill(Skill, Anim, mob, DataSkill, Posx, Posy);
      end;
    21, 22:
      begin
        RiflemanTargetBuffSkill(Skill, Anim, mob, DataSkill, Posx, Posy);
      end;
    41, 42:
      begin
        MagicianTargetBuffSkill(Skill, Anim, mob, DataSkill, Posx, Posy);
      end;
    11, 12:
      begin
        TemplarTargetBuffSkill(Skill, Anim, mob, DataSkill, Posx, Posy);
      end;
    31, 32:
      begin
        DualGunnerTargetBuffSkill(Skill, Anim, mob, DataSkill, Posx, Posy);
      end;
    51, 52:
      begin
        ClericTargetBuffSkill(Skill, Anim, mob, DataSkill, Posx, Posy);
      end
  else
    begin
      case DataSkill^.Index of
        55:
          begin
            if (mob^.Character <> nil) then
            begin
              Randomize;
              Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
              if (mob^.Character.CurrentScore.CurHP >= Helper) then
              begin // dano maior
                Helper2 := RandomRange(60, 120);
              end
              else
              begin // dano menor
                Helper2 := RandomRange(30, 59);
              end;
            end
            else
            begin
              Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
                Self.Character.CurrentScore.DNFis + 1);
              Self.SDKMobID := mob.Mobid;
              Self.SDKSecondIndex := mob.SecondIndex;
              Self.SKDIsMob := True;
            end;
            Self.SKDSkillEtc1 :=
              ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration);
            Self.SKDTarget := mob^.ClientID;
            Self.SKDListener := True;
            Self.SKDAction := 1;
            Self.SKDSkillID := Skill;
            mob^.AddBuff(Skill);
          end;
        250:
          begin
            if (mob^.Character <> nil) then
            begin
              Randomize;
              Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
              if (mob^.Character.CurrentScore.CurHP >= Helper) then
              begin // dano maior
                Helper2 := RandomRange(60, 120);
              end
              else
              begin // dano menor
                Helper2 := RandomRange(30, 59);
              end;
            end
            else
            begin
              Helper2 := RandomRange((Self.Character.CurrentScore.DNMAG div 2),
                Self.Character.CurrentScore.DNMAG + 1);
              Self.SDKMobID := mob.Mobid;
              Self.SDKSecondIndex := mob.SecondIndex;
              Self.SKDIsMob := True;
            end;
            Self.SKDSkillEtc1 := (DataSkill^.EFV[0] + Helper2);
            Self.SKDTarget := mob^.ClientID;
            Self.SKDListener := True;
            Self.SKDAction := 1;
            Self.SKDSkillID := Skill;
            mob^.AddBuff(Skill);
          end;
        248: // ceu sereno (pran skill)
          begin
            mob^.HPRListener := True;
            mob^.HPRAction := 2;
            mob^.HPRSkillID := Skill;
            mob^.HPRSkillEtc1 := DataSkill^.EFV[0];
            mob^.AddBuff(Skill);
          end;
        145:
          begin
            mob^.AddBuff(Skill);
          end
      else
        begin
          try
            mob^.AddBuff(Skill);
          except
            on E: Exception do
            begin
              Logger.Write('Error at mob.AddBuff ' + E.Message, TLogType.Error);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TBaseMob.TargetSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Classe of
    1, 2:
      begin
        WarriorSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    11, 12: // templar skill
      begin
        TemplarSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    21, 22: // rifleman skill
      begin
        RiflemanSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    31, 32: // dualgunner skill
      begin
        DualGunnerSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    41, 42: // magician skill
      begin
        MagicianSkill(Skill, Anim, @SkillData[Skill], mob, Dano, DmgType,
          CanDebuff, Resisted);
      end;
    51, 52: // cleric skill
      begin
        ClericSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
  end;
end;

procedure TBaseMob.AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
  Packet: TRecvDamagePacket);
var
  i, cnt: Integer;
  PrePosition: TPosition;
begin
  if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = 0) then
  begin // Se n�o estiver em party, buffa s� em si mesmo
    Self.SelfBuffSkill(Skill, Anim, mob, Packet.DeathPos);
    // Logger.Write(Packet.DeathPos.X.ToString, TLogType.Packets);
  end
  else
  begin
    cnt := 0;
    // Se estiver em party, vai buffar em si mesmo + Party
    if (Self.VisiblePlayers.Count = 0) then
    begin
      Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
        [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
        Trunc(Packet.DeathPos.y));
    end
    else
    begin
      for i in Self.VisiblePlayers do
      begin
        if (Servers[Self.ChannelId].Players[i].Status < Playing) or
          (Servers[Self.ChannelId].Players[i].Base.IsDead) then
          Continue;
        if (Servers[Self.ChannelId].Players[i].PartyIndex = 0) then
          Continue;
        if (cnt = 0) then
        begin
          PrePosition := Self.PlayerCharacter.LastPos;
          Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
            [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
            Trunc(Packet.DeathPos.y));
          cnt := 1;
        end;
        if (Servers[Self.ChannelId].Players[Self.ClientID].Party.
          Index <> Servers[Self.ChannelId].Players[i].Party.Index) then
          Continue;

        if not(PrePosition.InRange(Servers[Self.ChannelId].Players[i]
          .Base.PlayerCharacter.LastPos, Trunc(SkillData[Skill].range * 1)))
        then
          Continue;

        Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players[i]
          .Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
          Trunc(Packet.DeathPos.y));
        Packet.Animation := 0;
        Packet.TargetID := i;
        Packet.AttackerHP := Servers[Self.ChannelId].Players[i]
          .Base.Character.CurrentScore.CurHP;
        // Packet.DeathPos := Servers[Self.ChannelId].Players[i]
        // .Base.PlayerCharacter.LastPos;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;
    end;
  end;
  if (SkillData[Skill].Index = 167) then
    Self.UsingLongSkill := True;
end;

procedure TBaseMob.AreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SkillPos: TPosition; DataSkill: P_SkillData; DamagePerc: Single;
  ElThymos: Integer);
var
  Dano: Integer;
  DmgType: TDamageType;
  SelfPlayer: PPlayer;
  OtherPlayer: PPlayer;
  NewMob: PBaseMob;
  NewMobSP: PMobSPoisition;
  Packet: TRecvDamagePacket;
  i, j, cnt: Integer;
  Add_Buff: Boolean;
  Resisted: Boolean;
  Mobid: Integer;
  MoveTarget: Boolean;
  DropExp, DropItem: Boolean;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.DeathPos := SkillPos;

  if ((SkillData[Skill].range > 0) { and (SkillData[Skill].CastTime > 0) } )
  then
  begin // SkillData[Skill]
    Packet.AttackerPos := SkillPos;
  end
  else
  begin
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  end;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  Self.UsingLongSkill := False;

  if (ElThymos > 0) then
  begin
    Packet.SkillID := 0;
    Packet.Animation := 0;
    Packet.MobAnimation := 26;
  end;

  if (SkillData[Skill].Index = DEMOLICAO_X14) then
  begin
    Self.SelfBuffSkill(Skill, Anim, mob, SkillPos);
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.None;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;
  case Self.GetMobClass() of
    2, 3:
      begin
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
        begin
          TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], False);
        end;
      end;
  end;

  cnt := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets = nil) then
      break;
    if (VisibleTargets[i].ClientID = 0) then
      Continue;

    if (ElThymos > 0) then
    begin
      if (VisibleTargets[i].ClientID = mob.ClientID) then
        Continue;
    end;

    case VisibleTargets[i].TargetType of
      0:
        begin
          if (VisibleTargets[i].Player = nil) then
            Continue;

          NewMob := VisibleTargets[i].Player;
          OtherPlayer := @Servers[Self.ChannelId].Players
            [VisibleTargets[i].ClientID];
          if (NewMob^.IsDead) then
            Continue;
          if (OtherPlayer.SocketClosed) then
            Continue;
          if (OtherPlayer.Status < Playing) then
            Continue;
          if (SkillPos.InRange(NewMob^.PlayerCharacter.LastPos,
            Trunc(DataSkill^.range * 1))) then
          begin
            if (TPosition.Create(2947, 1664)
              .InRange(NewMob^.PlayerCharacter.LastPos, 10)) then
              Continue;
            if ((SelfPlayer^.Character.Base.GuildIndex > 0) and
              (SelfPlayer.Character.Base.GuildIndex = OtherPlayer^.Character.
              Base.GuildIndex) and not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.PartyIndex > 0) and
              (SelfPlayer.PartyIndex = OtherPlayer^.PartyIndex) then
              Continue;
            if ((Self.Character.Nation = NewMob^.Character.Nation) and
              (SelfPlayer^.Character.PlayerKill = False) and
              not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.Dueling) then
            begin
              if (NewMob^.ClientID <> SelfPlayer^.DuelingWith) then
                Continue;
              if (SecondsBetween(Now, SelfPlayer^.DuelInitTime) <= 15) then
                Continue;
            end;

            if ((SelfPlayer^.Character.GuildSlot > 0) and
              (Servers[SelfPlayer^.ChannelIndex].Players[NewMob^.ClientID]
              .Character.GuildSlot > 0)) then
            begin
              if (Guilds[SelfPlayer^.Character.GuildSlot].Ally.Leader = Guilds
                [Servers[SelfPlayer^.ChannelIndex].Players[NewMob^.ClientID]
                .Character.GuildSlot].Ally.Leader) then
                Exit;
            end;

            if (SecondsBetween(Now, NewMob.RevivedTime) <= 7) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('Alvo acabou de nascer.');
              Continue;
            end;
            Inc(cnt);
            Packet.TargetID := NewMob^.ClientID;
            Resisted := False;
            case DataSkill^.Classe of
              1, 2: // warrior skill
                begin
                  WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Resisted, MoveTarget);
                end;
              11, 12: // templar skill
                begin
                  TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Resisted);
                end;
              21, 22: // rifleman skill
                begin
                  RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              31, 32: // dualgunner skill
                begin
                  Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              41, 42: // magician skill
                begin
                  Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
              51, 52: // cleric skill
                begin
                  Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted);
                end;
            end;
            if (Dano > 0) then
            begin
              if (ElThymos > 0) then
              begin
                Self.AttackParse(0, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);
              end
              else
              begin
                Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);
              end;

              if (Dano > 0) then
              begin
                Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                if (DamagePerc > 0) then
                begin
                  Dano := Trunc((Dano div 100) * DamagePerc);
                end;
              end;
            end
            else
            begin
              if not(DmgType in [Critical, Normal, Double, Debuff,
                DoubleCritical]) then
                Add_Buff := False;
            end;
            if (Add_Buff = True) then
            begin
              if not(Resisted) then
              BEGIN
                Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
              END
              else
              begin
                Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                  ('O Alvo Resistiu ao efeito.', 15);
                Packet.MobAnimation := 0;
              end;
            end;
            if ((ElThymos > 0) and (Dano > 0)) then
            begin
              Dano := Round((Dano / 100) * DamagePerc);
            end;
            if (DmgType = Miss) then
              Dano := 0;

            Packet.Dano := Dano;
            Packet.DnType := DmgType;
            if (Packet.Dano >= NewMob^.Character.CurrentScore.CurHP) then
            begin
              if (OtherPlayer^.Dueling) then
              begin
                NewMob^.Character.CurrentScore.CurHP := 10;
              end
              else
              begin
                NewMob^.Character.CurrentScore.CurHP := 0;
                NewMob^.SendEffect($0);
                Packet.MobAnimation := 30;
                NewMob^.IsDead := True;

                var
                RlkSlot := TItemFunctions.GetItemSlotByItemType
                  (Servers[Self.ChannelId].Players[Self.ClientID], 40,
                  INV_TYPE, 0);
                if (RlkSlot <> 255) then
                begin
                  var
                    Item: PItem := @Servers[Self.ChannelId].Players
                      [Self.ClientID].Base.Character.Inventory[RlkSlot];
                  var
                  index := Item.Index;
                  ZeroMemory(Item, sizeof(TItem));
                  Servers[Self.ChannelId].Players[Self.ClientID]
                    .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
                  Servers[Self.ChannelId].Players[Self.ClientID].SendEffect(0);
                  Servers[Self.ChannelId].CreateMapObject(@Self, 320, index);
                end;

                if (Servers[Self.ChannelId].Players[NewMob^.ClientID]
                  .CollectingReliquare) then
                  Servers[Self.ChannelId].Players[NewMob^.ClientID]
                    .SendCancelCollectItem(Servers[Self.ChannelId].Players
                    [NewMob^.ClientID].CollectingID);
                NewMob^.LastReceivedAttack := Now;
                Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;
                if (cnt > 1) then
                begin
                  Packet.AttackerID := Self.ClientID;
                  Packet.Animation := 0;
                end
                else
                begin
                  Packet.AttackerID := Self.ClientID;
                end;
                if ((SkillData[Skill].range > 0)
                  { and (SkillData[Skill].CastTime > 0) } ) then
                begin // SkillData[Skill]
                  Packet.AttackerPos := SkillPos;
                  Packet.DeathPos := Servers[Self.ChannelId].Players
                    [Self.ClientID].LastPositionLongSkill;
                end
                else
                begin
                  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                  Packet.DeathPos := SkillPos;
                end;

                Self.SendToVisible(Packet, Packet.Header.size);
                if (NewMob^.Character.Nation > 0) and (Self.Character.Nation > 0)
                then
                begin
                  if ((NewMob^.Character.Nation <> Self.Character.Nation) or
                    (Self.InClastleVerus)) then
                  begin
                    Self.PlayerKilled(NewMob);
                  end;
                end;
              end;
            end
            else
            begin
              if (Packet.Dano > 0) then
                NewMob^.RemoveHP(Packet.Dano, False);
              if (Servers[Self.ChannelId].Players[NewMob^.ClientID]
                .CollectingReliquare) then
                Servers[Self.ChannelId].Players[NewMob^.ClientID]
                  .SendCancelCollectItem(Servers[Self.ChannelId].Players
                  [NewMob^.ClientID].CollectingID);
              NewMob^.LastReceivedAttack := Now;
              Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;
              if (cnt > 1) then
              begin
                Packet.AttackerID := Self.ClientID;
                Packet.Animation := 0;
              end
              else
              begin
                Packet.AttackerID := Self.ClientID;
              end;
              if ((SkillData[Skill].range > 0)
                { and (SkillData[Skill].CastTime > 0) } ) then
              begin // SkillData[Skill]
                Packet.AttackerPos := SkillPos;
                Packet.DeathPos := Servers[Self.ChannelId].Players
                  [Self.ClientID].LastPositionLongSkill;
              end
              else
              begin
                Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                Packet.DeathPos := SkillPos;
              end;

              Self.SendToVisible(Packet, Packet.Header.size);
            end;

            // Sleep(1);
          end;
        end;
      1:
        begin
          if (VisibleTargets[i].mob = nil) then
            Continue;
          NewMob := VisibleTargets[i].mob;
          if (NewMob.ClientID > 9147) then
            Continue;
          if not(Servers[Self.ChannelId].MOBS.TMobS[NewMob.Mobid]
            .IsActiveToSpawn) then
            Continue;
          if (NewMob^.IsDead) then
            Continue;
          case NewMob^.ClientID of
            3340 .. 3354:
              begin // stones
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirStones
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1))) then
                begin
                  if (Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.ChannelId]
                    .Players[Self.ClientID].Account.Header.Nation)) then
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := False;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if (Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType,
                      Add_Buff, Packet.MobAnimation, DataSkill);

                    if (Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20),
                        (Dano div 10))) + 13));

                      if (DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                    begin
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                    end
                    else
                    begin
                      Servers[Self.ChannelId].Players[Self.ClientID]
                        .SendClientMessage('O Alvo Resistiu ao efeito.', 15);
                      Packet.MobAnimation := 0;
                    end;
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if ((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
                    not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .IsAttacked := False;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .KillStone(NewMob^.ClientID, Self.ClientID);
                    if (Self.VisibleNPCS.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCS.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if (Servers[Self.ChannelId].Players[j]
                        .Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j]
                          .Base.VisibleNPCS.Remove(NewMob^.ClientID);
                        Servers[Self.ChannelId].Players[j]
                          .Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirStones
                      [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP,
                      Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  // Sleep(1);
                end;
              end;
            3355 .. 3369:
              begin // guards
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirGuards
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1))) then
                begin
                  if (Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.ChannelId]
                    .Players[Self.ClientID].Account.Header.Nation)) then
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := False;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if (Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType,
                      Add_Buff, Packet.MobAnimation, DataSkill);

                    if (Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20),
                        (Dano div 10))) + 13));

                      if (DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                    begin
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                    end
                    else
                    begin
                      Servers[Self.ChannelId].Players[Self.ClientID]
                        .SendClientMessage('O Alvo Resistiu ao efeito.', 15);
                      Packet.MobAnimation := 0;
                    end;
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if ((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
                    not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .IsAttacked := False;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .KillGuard(NewMob^.ClientID, Self.ClientID);
                    if (Self.VisibleNPCS.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCS.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if (Servers[Self.ChannelId].Players[j]
                        .Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j]
                          .Base.VisibleNPCS.Remove(NewMob^.ClientID);
                        Servers[Self.ChannelId].Players[j]
                          .Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirGuards
                      [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP,
                      Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  // Sleep(1);
                end;
              end
          else
            begin
              NewMobSP := @Servers[Self.ChannelId].MOBS.TMobS[NewMob^.Mobid]
                .MobsP[NewMob^.SecondIndex];
              if (SkillPos.InRange(NewMobSP^.CurrentPos,
                Trunc(DataSkill^.range * 1))) then
              begin
                if ((NewMobSP^.isGuard) and
                  ((NewMob^.PlayerCharacter.Base.Nation = Self.Character.Nation)
                  or (Self.Character.Nation = 0))) then
                  Continue;

                if not(NewMobSP.IsAttacked) then
                begin
                  NewMobSP.FirstPlayerAttacker := Self.ClientID;
                end;

                Inc(cnt);
                Packet.TargetID := NewMob^.ClientID;
                Resisted := False;
                case DataSkill^.Classe of
                  1, 2: // warrior skill
                    begin
                      WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, MoveTarget);
                    end;
                  11, 12: // templar skill
                    begin
                      TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  21, 22: // rifleman skill
                    begin
                      RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  31, 32: // dualgunner skill
                    begin
                      DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  41, 42: // magician skill
                    begin
                      Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  51, 52: // cleric skill
                    begin
                      Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                end;
                if (Dano > 0) then
                begin
                  Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Packet.MobAnimation, DataSkill);

                  if (Dano > 0) then
                  begin
                    if (DamagePerc > 0) then
                    begin
                      Dano := Trunc((Dano div 100) * DamagePerc);
                    end;
                  end;
                end;
                if (Add_Buff = True) then
                begin
                  if not(Resisted) then
                  begin
                    Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end
                  else
                  begin
                    Servers[Self.ChannelId].Players[Self.ClientID]
                      .SendClientMessage('O Alvo Resistiu ao efeito.', 15);
                    Packet.MobAnimation := 0;
                  end;
                end;
                if (DmgType = Miss) then
                  Dano := 0;
                if ((ElThymos > 0) and (Dano > 0)) then
                begin
                  Dano := Round((Dano / 100) * DamagePerc);
                end;
                Packet.Dano := Dano;
                Packet.DnType := DmgType;
                NewMobSP^.IsAttacked := True;
                NewMobSP^.AttackerID := Self.ClientID;
                if (Packet.Dano >= NewMobSP^.HP) then
                begin
                  NewMobSP^.HP := 0;
                  NewMobSP^.IsAttacked := False;
                  NewMobSP^.AttackerID := 0;
                  NewMobSP^.deadTime := Now;
                  NewMob.SendEffect($0);
                  NewMob^.IsDead := True;
                  NewMob.SendCurrentHPMPMob;
                  if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
                  begin
                    Self.VisibleMobs.Remove(NewMob^.ClientID);
                    Self.RemoveTargetFromList(NewMob);
                  end;
                  for j in Self.VisiblePlayers do
                  begin
                    if (Servers[Self.ChannelId].Players[j]
                      .Base.VisibleMobs.Contains(NewMob^.ClientID)) then
                    begin
                      Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
                        (NewMob^.ClientID);
                      Servers[Self.ChannelId].Players[j]
                        .Base.RemoveTargetFromList(NewMob);
                    end;
                  end;
                  NewMob^.VisibleMobs.Clear;
                  Self.MobKilled(NewMob, DropExp, DropItem, False);
                  Packet.MobAnimation := 30;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  Packet.MobCurrHP := 0;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  // Sleep(1);
                end
                else
                begin

                  deccardinal(NewMobSP^.HP, Packet.Dano);
                  Packet.MobCurrHP := NewMobSP^.HP;
                  NewMob^.LastReceivedAttack := Now;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  NewMob.SendCurrentHPMPMob;
                  // Sleep(1);
                end;
              end;
            end;
          end;
        end;
    end;
  end;
  if ((cnt = 0) and (ElThymos = 0)) then
  begin
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;
end;

procedure TBaseMob.AttackParse(Skill, Anim: DWORD; mob: PBaseMob;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte; DataSkill: P_SkillData);
var
  HpPerc, MpPerc: Integer;
  // CriticalResTax: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1: Integer;
  OtherPlayer: PPlayer;
  BoolHelp: Boolean;
begin

  if (Self.IsSecureArea) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Voc� est� em uma �rea segura, n�o pode lan�ar skills.');
    Exit;
  end;
  if (mob^.IsSecureArea) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('O alvo est� dentro de uma �rea segura e n�o foi afetado pela sua habilidade.');
    Exit;
  end;

  if (Skill > 0) then
  begin
    Inc(Dano, (DataSkill^.Damage + Self.PlayerCharacter.HabAtk) div 2);
    Inc(Dano, Self.GetMobAbility(EF_PRAN_SKILL_DAMAGE));
    if (Self.Character <> nil) then
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect
          [EF_RELIQUE_SKILL_PER_DAMAGE] * (Dano div 100));
  end
  else
  begin
    if (Self.GetMobAbility(EF_SPLASH) > 0) then
    begin // efeito de bater em �rea no ataque b�sico
      if (SecondsBetween(Now, LastSplashTime) >= 1) then
      begin
        LastSplashTime := Now;

        Self.AreaSkill(177, SkillData[177].Anim, mob,
          Self.PlayerCharacter.LastPos, @SkillData[177],
          Self.GetMobAbility(EF_SPLASH), 1);
      end;
    end;
  end;

  case DmgType of
    Critical:
      begin
        Helper := 40 + Self.PlayerCharacter.DamageCritical;
        Inc(Dano, ((Dano div 100) * Helper));
      end;
    Double:
      Dano := (Dano * 2);
    DoubleCritical:
      begin
        Dano := Dano * 2;
        Helper := 40 + Self.PlayerCharacter.DamageCritical;
        Inc(Dano, ((Dano div 100) * Helper));
      end;
  end;

{$REGION 'AUMENTA O DANO'}
  if (mob^.GetMobAbility(EF_AMP_PHYSICAL) > 0) then
  begin
    Inc(Dano, ((Dano div 100) * mob^.GetMobAbility(EF_AMP_PHYSICAL)));
  end;

  if (mob^.GetMobAbility(EF_TYPE45) > 0) then
  begin // raio solar da santa da 10% a mais de dano em cima da vitima
    Inc(Dano, ((Dano div 100) * 10));
  end;

  if (mob^.GetMobAbility(EF_ADD_DAMAGE1) > 0) then
  begin // requiem
    Inc(Dano, (mob^.GetMobAbility(EF_ADD_DAMAGE1) * 2));
  end;

  if not(mob.IsPlayer) then
  begin
    if (mob^.BuffExistsByIndex(133)) then // raio solar
    begin
      Inc(Dano, ((Dano div 100) * (Self.GetMobAbility(EF_ATK_DEMON) +
        Self.GetMobAbility(EF_ATK_UNDEAD))));
    end;
  end;

{$ENDREGION}
{$REGION 'CALCULA O DANO'}
  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin
    if ((mob^.Character.Nation <> Self.Character.Nation) and
      (mob^.Character.Nation > 0) and (Self.Character.Nation > 0)) then
    begin
      var
      mobPvpDef := mob.PlayerCharacter.PvPDefense;
      var
      pvpPerc := 0;
      var
      pvpDefPerc := 0;

      // Dano base + Dano Pvp
      Inc(Dano, Self.PlayerCharacter.PvPDamage);
      // Machado
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(pvpPerc, Servers[Self.ChannelId].ReliqEffect
          [EF_RELIQUE_ATK_NATION]);

      // Buff Grade Eu
      Inc(pvpPerc, Self.GetMobAbility(EF_MARSHAL_ATK_NATION));

      // DanoPvpFinal = Dano + porcentagem de pvp
      Inc(Dano, pvpPerc * (Dano div 100));
      // Buff Grade inimigo
      Inc(pvpDefPerc, mob.GetMobAbility(EF_MARSHAL_DEF_NATION));

      // Escudo
      if (Servers[Self.ChannelId].NationID <> Self.Character.Nation) then
      begin
        Inc(pvpDefPerc, Servers[Self.ChannelId].ReliqEffect
          [EF_RELIQUE_DEF_NATION]);
      end;
      decInt(Dano, (Dano div 100) * pvpDefPerc);
      decInt(Dano, mobPvpDef);
      Helper := Dano;
    end;
  end
  else
  begin
    if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_MONSTER] *
        (Dano div 100));
  end;
{$ENDREGION}
{$REGION 'DIMINUI O DANO'}
  if (Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1) > 0) then
  begin
    decInt(Dano, ((Dano div 100) * Self.GetMobAbility
      (EF_DECREASE_PER_DAMAGE1)));
  end;

  if (mob^.GetMobAbility(EF_HP_CONVERSION) > 0) then
  begin
    decInt(Dano, ((Dano div 100) * mob^.GetMobAbility(EF_HP_CONVERSION)));
  end;
{$ENDREGION}
{$REGION 'ABSORVE O DANO'}
  if (mob^.BuffExistsByIndex(432)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      decInt(Dano, Help1);
      mob^.RemoveBuffByIndex(432);
    end;
  end;

  if (mob^.BuffExistsByIndex(123)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      decInt(Dano, Help1);
      mob^.RemoveBuffByIndex(123);
    end;
  end;

  if (mob^.BuffExistsByIndex(131)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      decInt(Dano, Help1);
      mob^.RemoveBuffByIndex(131);
    end;
  end;

  if (mob^.BuffExistsByIndex(142)) then
  begin
    Help1 := mob^.GetMobAbility(EF_SKILL_ABSORB2);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque.');
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Dano.ToString + ' pontos de ataque.');
      mob^.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('O alvo absorveu seu ataque em partes.', 0);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu ' + Help1.ToString + ' pontos de ataque.');
      decInt(Dano, Help1);
      mob^.RemoveBuffByIndex(142);
    end;
  end;

  if (mob^.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
  begin
    Helper := Dano;
    decInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));
    decInt(Helper, Dano);
    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);
    BoolHelp := False;
    if (OtherPlayer <> nil) then
    begin
      if (not(OtherPlayer.Base.IsDead) and (OtherPlayer.Status >= Playing) and
        not(OtherPlayer.SocketClosed)) then
      begin
        var
        red := mob.GetMobAbility(EF_BLANK16);
        if (red > 0) then
          Helper := (Helper div 100) * red;
        OtherPlayer.Base.RemoveHP(Helper, True, True);
        OtherPlayer.Base.LastReceivedAttack := Now;
        OtherPlayer.SendClientMessage('Seu HP foi consumido em ' +
          Helper.ToString + ' pontos pelo buff [União Divina] no membro <' +
          AnsiString(mob.Character.Name) + '>.', 16);
      end
      else
      begin
        mob.RemoveBuffByIndex(35);
        var
        red := mob.GetMobAbility(EF_BLANK16);

        mob.DecreasseMobAbility(EF_BLANK16, red);
        mob.UniaoDivina := '';
        BoolHelp := True;
      end;
    end;
    if not(BoolHelp) then
    begin
      decInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);
      if (mob.MOB_EF[EF_TRANSFER_LIMIT] = 0) then
      begin
        var
        red := mob.GetMobAbility(EF_BLANK16);

        mob.DecreasseMobAbility(EF_BLANK16, red);
        mob.RemoveBuffByIndex(35);
        mob.UniaoDivina := '';
      end;
    end;
  end;
  if (mob.BuffExistsByIndex(ESCUDO_NEGRO)) then
  begin
    Help1 := mob.GetMobAbility(EF_HP_CONVERSION);
    var
      Fator: System.Double;
    Help1 := Dano - Trunc(Dano.ToDouble * (Help1.ToDouble / 100));
    mob.BlackMagicianShieldMPCostFactor(ESCUDO_NEGRO, Fator);
    var
    Help2 := Trunc(Help1 * Fator);
    mob.RemoveMP(Help2, True);
    if (Help2 >= mob.Character.CurrentScore.CurMP) then
    begin
      mob.RemoveMP(Help2, True);
      mob.RemoveBuffByIndex(ESCUDO_NEGRO);
    end
    else
    begin
      mob.BlackMagicianShieldMPCostFactor(ESCUDO_NEGRO, Fator);
      Help2 := Trunc(Help1 * Fator);
      mob.RemoveMP(Help2, True);
      decInt(Dano, Help1);
    end;
  end;
{$ENDREGION}
{$REGION 'tira debuff no hit'}
  if (mob^.Polimorfed) then
  begin
    DmgType := TDamageType.Critical;
    mob^.Polimorfed := False;
    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      mob^.RemoveBuffByIndex(99);
      mob^.SendCreateMob(SPAWN_NORMAL);
    end;
  end;

  if (mob.BuffExistsByIndex(BRUMA)) then
  begin
    if not(DmgType = Miss) then
      mob.RemoveBuffByIndex(BRUMA);
  end;

  if (mob.BuffExistsByIndex(86)) then
  begin // choque dual
    mob.RemoveBuffByIndex(86);
  end;

  if (mob.BuffExistsByIndex(63)) then
  begin // choque att
    mob.RemoveBuffByIndex(63);
  end;

  if mob.BuffExistsByIndex(153) then
    mob.RemoveBuffByIndex(153);

  if mob.BuffExistsByIndex(390) then
    mob.RemoveBuffByIndex(390);

  if mob.BuffExistsByIndex(391) then
    mob.RemoveBuffByIndex(391);

  if mob.BuffExistsByIndex(392) then
    mob.RemoveBuffByIndex(392);

  if (mob^.BuffExistsByIndex(GRITO_MEDO)) then
  begin
    Randomize;
    if (RandomRange(0, 100) <= mob^.GetMobAbility(EF_FEARPLUS)) then
    begin
      mob^.RemoveBuffByIndex(GRITO_MEDO);
      mob^.AddBuff(SLOW_FEAR);
    end;
  end;

  if (mob^.BuffExistsByIndex(32)) then
  begin
    dec(Dano, ((Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE)));
    dec(mob^.DefesaPoints, 1);
    if (mob^.DefesaPoints = 0) then
      mob^.RemoveBuffByIndex(32);
  end;

  var
  passiva := mob.GetMobAbility(EF_BLANK15);
  if (passiva > 0) then
  begin
    var
    asd := Random;
    //Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
    //  ('Probabilidade [' + asd.ToString + '] Sua Probabilidade. [' +
    //  (passiva / 100).ToString + ']');
    if (Random < (passiva / 100)) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('Última esperança foi ativada e [' + AnsiString(mob.Character.Name) +
        '] libertou-se de um efeito.');
      mob.RemoveDebuffs(1);
    end;
  end;
{$ENDREGION}
{$REGION 'Cura pelo dano'}
  if (Self.GetMobAbility(EF_DRAIN_HP) > 0) then
  begin
    HpPerc := Self.GetMobAbility(EF_DRAIN_HP);
    Self.AddHP(((Dano div 100) * HpPerc), True);
  end;

  if (Self.GetMobAbility(EF_DRAIN_MP) > 0) then
  begin
    MpPerc := Self.GetMobAbility(EF_DRAIN_MP);
    Self.AddMP(((Dano div 100) * MpPerc), True);
  end;

  if (Self.GetMobAbility(EF_HP_ATK_RES) > 0) then
  begin
    HpPerc := Self.GetMobAbility(EF_HP_ATK_RES);
    Self.AddHP(((Dano div 100) * HpPerc), True);
  end;

{$ENDREGION}
  HelperInByte := 0;
  if (Self.IsCompleteEffect5(HelperInByte)) then
  begin
    Randomize;
    Help1 := RandomRange(1, 101);
    if (Help1 <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
    begin
      Self.Effect5Skill(mob, HelperInByte);
    end;
  end;

  if (mob^.BuffExistsByIndex(38)) then
  begin
    Help1 := mob^.GetMobAbility(EF_REFLECTION2);
    Self.RemoveHP(((Dano div 100) * Help1), True, True);
    mob^.RemoveBuffByIndex(38);
    Dano := 0;
    DmgType := TDamageType.None;
  end;

  if (Dano > 0) then
  begin
    Helper := mob^.GetMobAbility(EF_REFLECTION1);
    if (Helper > 0) then
    begin
      Self.RemoveHP(Helper, False, True);
      Self.SendCurrentHPMP(True);
    end;
    if (mob^.BuffExistsByIndex(222)) then
    begin
      Helper := mob^.GetMobAbility(EF_SKILL_ABSORB1);
      if (Helper > 0) then
      begin
        if (Dano >= Helper) then
        begin
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob^.RemoveBuffByIndex(222);
        end
        else
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
        decInt(Dano, Helper);
      end;
    end;
  end;

  if (mob^.BuffExistsByIndex(36) = True) and not(DataSkill^.Index = 0) and
    (Skill > 0) then
  begin
    if (DataSkill^.Index = 136) then
    begin
      dec(mob^.BolhaPoints, DataSkill^.Damage);
    end
    else
      dec(mob^.BolhaPoints, 1);

    if (mob^.BolhaPoints = 0) then
    begin
      mob^.RemoveBuffByIndex(36);
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] Proteção desativada.', 16, 1, 1);
    end
    else
    begin
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] restam ' + mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
    end;
  end;

  // Verifica e processa o buff de índice 365
  if (mob^.BuffExistsByIndex(365) = True) and not(DataSkill^.Index = 0) and
    (Skill > 0) then
  begin
    if (DataSkill^.Index = 136) then
    begin
      dec(mob^.BolhaPoints, DataSkill^.Damage);
    end
    else
      dec(mob^.BolhaPoints, 1);

    if (mob^.BolhaPoints = 0) then
    begin
      mob^.RemoveBuffByIndex(365);
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] Proteção desativada.', 16, 1, 1);
    end
    else
    begin
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := False;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] restam ' + mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
    end;
  end;

  if (mob^.BuffExistsByIndex(90)) then
  begin // estripador de dual
    if ((DmgType = Critical) or (DmgType = DoubleCritical)) then
      Self.TargetBuffSkill(6279, 0, mob, @SkillData[6279]);
  end;
  if (mob^.ResolutoPoints > 0) then
  begin
    if (SecondsBetween(Now, mob^.ResolutoTime) >= 8) then
    begin
      mob^.ResolutoPoints := 0;
    end
    else if (AddBuff) then
    begin
      dec(mob^.ResolutoPoints, 1);
      MobAnimation := 26;
      Self.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
      if (mob.Mobid = 0) then
      begin
        Randomize;
        Helper := RandomRange(1, -2);
        if (Helper = 0) then
          Self.WalkBacked(TPosition.Create(mob.PlayerCharacter.LastPos.x - 1,
            mob.PlayerCharacter.LastPos.y + 1), 209, mob)
        else
          Self.WalkBacked(TPosition.Create(mob.PlayerCharacter.LastPos.x +
            Helper, mob.PlayerCharacter.LastPos.y + Helper), 209, mob);
      end;
    end;
  end;

  if ((mob.ClientID >= 3048) and (mob.ClientID <= 9147)) then
  begin
    if (Self.GetMobAbility(EF_ATK_MONSTER) > 0) then
    begin
      Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_MONSTER)));
    end;
    if (mob.GetMobAbility(197) > 0) then
    begin
      if (Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
      begin
        Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
      end;

      if (Self.GetMobAbility(EF_ATK_DEMON) > 0) then
      begin
        Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
      end;
    end;
    if (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType >= 1024) then
    begin
      if not(mob^.BuffExistsByIndex(133)) then // raio solar
      begin

        case (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType - 1024) of
          0: // humanoide
            begin
              if (Self.GetMobAbility(EF_ATK_ALIEN) > 0) then
              begin
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_ALIEN)));
              end;
            end;

          1: // animal
            begin
              if (Self.GetMobAbility(EF_ATK_BEAST) > 0) then
              begin
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_BEAST)));
              end;
            end;

          2: // plantas
            begin
              if (Self.GetMobAbility(EF_ATK_PLANT) > 0) then
              begin
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_PLANT)));
              end;
            end;

          3: // inseto
            begin
              if (Self.GetMobAbility(EF_ATK_INSECT) > 0) then
              begin
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_INSECT)));
              end;
            end;

          4: // demonio
            begin
              if (Self.GetMobAbility(EF_ATK_DEMON) > 0) then
              begin
                if (SkillData[Skill].Index = FLECHA_SAGRADA) then
                begin
                  Inc(Dano, Dano div 2)
                end;
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_DEMON)));
              end;
            end;

          5: // morto vivo
            begin
              if (Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
              begin
                if (SkillData[Skill].Index = FLECHA_SAGRADA) then
                begin
                  Inc(Dano, Dano div 2)
                end;
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_UNDEAD)));
              end;
            end;

          6: // misto
            begin
              if (Self.GetMobAbility(EF_ATK_COMPLEX) > 0) then
              begin
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_COMPLEX)));
              end;
            end;

          7: // estrutura
            begin
              if (Self.GetMobAbility(EF_ATK_STRUCTURE) > 0) then
              begin
                Inc(Dano, Round((Dano / 100) * Self.GetMobAbility
                  (EF_ATK_STRUCTURE)));
              end;
            end;
        end;
      end;
    end;
  end;
  if (Dano > 10000) then
    Dano := 10000;

  if (Dano < 0) then
    Dano := 1;
end;

procedure TBaseMob.AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte);
var
  Helper: Integer;
  HelperInByte: Byte;
  Help1: Integer;
  Help2: Integer;
  OtherPlayer: PPlayer;
  Fator: System.Double;
begin
  if (mob.GetMobAbility(EF_AMP_PHYSICAL) > 0) then
  begin
    Inc(Dano, ((Dano div 100) * mob.GetMobAbility(EF_AMP_PHYSICAL)));
  end;

  if (mob.GetMobAbility(EF_TYPE45) > 0) then
  begin // raio solar da santa da 10% a mais de dano em cima da vitima
    Inc(Dano, ((Dano div 100) * 10));
  end;

  if ((mob.BuffExistsByIndex(432)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Help1.ToString + ' pontos.');
      decInt(Dano, Help1);
      mob.RemoveBuffByIndex(432);
    end;
  end;

  if ((mob.BuffExistsByIndex(123)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Help1.ToString + ' pontos.');
      decInt(Dano, Help1);
      mob.RemoveBuffByIndex(123);
    end;
  end;

  if ((mob.BuffExistsByIndex(131)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Help1.ToString + ' pontos.');
      decInt(Dano, Help1);
      mob.RemoveBuffByIndex(131);
    end;
  end;

  if ((mob.BuffExistsByIndex(142)) and (Dano > 0)) then
  begin
    Help1 := mob.GetMobAbility(EF_SKILL_ABSORB2);
    if (Help1 > Dano) then
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Dano.ToString + ' pontos.');
      mob.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
      Dano := 0;
      DmgType := TDamageType.None;
    end
    else
    begin
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Voc� absorveu o ataque em ' + Help1.ToString + ' pontos.');
      decInt(Dano, Help1);
      mob.RemoveBuffByIndex(142);
    end;
  end;

  if (mob.Polimorfed) then
  begin
    DmgType := TDamageType.DoubleCritical;
    mob.Polimorfed := False;

    if (mob.ClientID <= MAX_CONNECTIONS) then
    begin
      mob.RemoveBuffByIndex(99);
      mob.SendCreateMob(SPAWN_NORMAL);
    end;
  end;

  if (mob.BuffExistsByIndex(111)) then
  begin // nevoa fc
    mob.RemoveBuffByIndex(111);
  end;

  if (mob.BuffExistsByIndex(86)) then
  begin // choque dual
    mob.RemoveBuffByIndex(86);
  end;

  if (mob.BuffExistsByIndex(63)) then
  begin // choque att
    mob.RemoveBuffByIndex(63);
  end;

  if mob.BuffExistsByIndex(153) then
    mob.RemoveBuffByIndex(153);

  if mob.BuffExistsByIndex(390) then
    mob.RemoveBuffByIndex(390);

  if mob.BuffExistsByIndex(391) then
    mob.RemoveBuffByIndex(391);

  if mob.BuffExistsByIndex(392) then
    mob.RemoveBuffByIndex(392);

  if (mob.GetMobAbility(EF_HP_CONVERSION) > 0) then
  begin
    if not(mob.BuffExistsByIndex(101)) then
    begin
      decInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_HP_CONVERSION)));
    end;

  end;

  if (mob.BuffExistsByIndex(38)) then
  begin
    Help1 := mob.GetMobAbility(EF_REFLECTION2);

    if (not(mob.IsPlayer) and not(Self.IsDungeonMob)) then
    begin
      Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex].HP
        := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
        [Self.SecondIndex].HP - ((Dano div 100) * Help1);
      Self.SendCurrentHPMPMob();
    end;

    Dano := 0;
    DmgType := TDamageType.None;

    mob.RemoveBuffByIndex(38);
  end;

  if (Dano > 0) then
  begin
    Helper := mob.GetMobAbility(EF_REFLECTION1);
    if (Helper > 0) then
    begin
      if (not(mob.IsPlayer) and not(Self.IsDungeonMob)) then
      begin
        Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
          .HP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
          [Self.SecondIndex].HP - ((Dano div 100) * Help1);
        Self.SendCurrentHPMPMob();
      end;
    end;

    if (mob.BuffExistsByIndex(222)) then
    begin
      Helper := mob.GetMobAbility(EF_SKILL_ABSORB1);

      if (Helper > 0) then
      begin
        if (Dano >= Helper) then
        begin
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob.RemoveBuffByIndex(222);
        end
        else
          mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);

        dec(Dano, Helper);
      end;
    end;
  end;

  if (mob.BuffExistsByIndex(32)) then
  begin
    decInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE)));

    dec(mob.DefesaPoints, 1);

    if (mob.DefesaPoints = 0) then
      mob.RemoveBuffByIndex(32);
  end;

  if (mob.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
  begin
    Helper := Dano;

    decInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));

    decInt(Helper, Dano);

    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);

    if (Assigned(OtherPlayer)) then
    begin
      if (not(OtherPlayer.Base.IsDead) and (OtherPlayer.Status >= Playing)) then
      begin
        var
        red := mob.GetMobAbility(EF_BLANK16);
        if (red > 0) then
          Helper := (Helper div 100) * red;
        OtherPlayer.Base.RemoveHP(Helper, True, True);
        OtherPlayer.SendClientMessage('Seu HP foi consumido em ' +
          Helper.ToString + ' pontos pelo buff [União Divina] no membro <' +
          AnsiString(OtherPlayer.Base.Character.Name) + '>.', 16);
      end;
    end;

    decInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);

    if (mob.MOB_EF[EF_TRANSFER_LIMIT] = 0) then
    begin
      var
      red := mob.GetMobAbility(EF_BLANK16);

      mob.DecreasseMobAbility(EF_BLANK16, red);
      mob.RemoveBuffByIndex(35);
      mob.UniaoDivina := '';
    end;
  end;

  if not(Dano = 0) and not(mob.ClientID >= 3048) then
  begin
    if (mob.BuffExistsByIndex(460)) then
    begin
      if (Dano > mob.Character.CurrentScore.CurHP) then
      begin
        mob.RemoveBuffByIndex(460);
        mob.RemoveAllDebuffs;
        mob.ResolutoPoints := 0;
        mob.Character.CurrentScore.CurHP :=
          ((mob.Character.CurrentScore.MaxHP div 100) * 30);
        mob.Character.CurrentScore.CurMP :=
          ((mob.Character.CurrentScore.MaxMP div 100) * 25);
        mob.SendCurrentHPMP(True);
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você foi revivido graças ao buff [Pedra da Alma].');
      end;
    end;
  end;

  if (mob.BuffExistsByIndex(80)) then
  begin // requiem
    Inc(Dano, mob.GetMobAbility(EF_ADD_DAMAGE1));
  end;

  if (mob.BuffExistsByIndex(90)) then
  begin // estripador de dual
    if ((DmgType = Critical) or (DmgType = DoubleCritical)) then
      mob.TargetBuffSkill(6279, 0, mob, @SkillData[6279]);
  end;

  if (mob.ResolutoPoints > 0) then
  begin
    if (SecondsBetween(Now, mob.ResolutoTime) >= 8) then
    begin
      mob.ResolutoPoints := 0;
    end
    else if (AddBuff) then
    begin
      dec(mob.ResolutoPoints, 1);
      MobAnimation := 26;
      mob.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
    end;
  end;

  case (Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobType - 1024) of
    0: // humanoide
      begin
        if (mob.GetMobAbility(EF_DEF_ALIEN) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_ALIEN)));
        end;
      end;

    1: // animal
      begin
        if (mob.GetMobAbility(EF_DEF_BEAST) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_BEAST)));
        end;
      end;

    2: // plantas
      begin
        if (mob.GetMobAbility(EF_DEF_PLANT) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_PLANT)));
        end;
      end;

    3: // inseto
      begin
        if (mob.GetMobAbility(EF_DEF_INSECT) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_INSECT)));
        end;
      end;

    4: // demonio
      begin
        if (mob.GetMobAbility(EF_DEF_DEMON) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_DEMON)));
        end;
      end;

    5: // morto vivo
      begin
        if (mob.GetMobAbility(EF_DEF_UNDEAD) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_UNDEAD)));
        end;
      end;

    6: // misto
      begin
        if (mob.GetMobAbility(EF_DEF_COMPLEX) > 0) then
        begin
          decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_COMPLEX)));
        end;
      end;

    7: // estrutura
      begin
        if (mob.GetMobAbility(EF_DEF_STRUCTURE) > 0) then
        begin
          decInt(Dano,
            Round((Dano / 100) * mob.GetMobAbility(EF_DEF_STRUCTURE)));
        end;
      end;
  end;

  if (mob.BuffExistsByIndex(ESCUDO_NEGRO)) then
  begin
    Help1 := mob.GetMobAbility(EF_HP_CONVERSION);

    Help1 := Dano - Trunc(Dano.ToDouble * (Help1.ToDouble / 100));
    mob.BlackMagicianShieldMPCostFactor(ESCUDO_NEGRO, Fator);
    Help2 := Trunc(Help1 * Fator);
    mob.RemoveMP(Help2, True);
    if (Help2 >= mob.Character.CurrentScore.CurMP) then
    begin
      mob.RemoveMP(Help2, True);
      mob.RemoveBuffByIndex(ESCUDO_NEGRO);
    end
    else
    begin
      mob.BlackMagicianShieldMPCostFactor(ESCUDO_NEGRO, Fator);
      Help2 := Trunc(Help1 * Fator);
      mob.RemoveMP(Help2, True);
      decInt(Dano, Help1);
    end;
  end;

  if (Dano > 10000) then
    Dano := 10000;

  if (Dano < 0) then
    Dano := 1;

end;

procedure TBaseMob.Effect5Skill(mob: PBaseMob; EffCount: Byte;
  xPassive: Boolean);
var
  Packet: TRecvDamagePacket;
  Skill: Integer;
  i, cnt: Integer;
  FRand: Integer;
  PList: Array [0 .. 2] of WORD;
  MobsP: PMobSPoisition;
begin
  // if (mob^.ClientID >= 3048) then
  // Exit; // mais pra frente setar aqui pra atacar eff5 em mobs tbm
  if (EffCount > 1) then
  begin // se tiver mais de 1 efeito 5 equipado, escolher entre eles
    ZeroMemory(@PList, 6);
    cnt := 0;
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        PList[cnt] := EFF_5[i];
        Inc(cnt);
      end;
    end;
    Randomize;
    FRand := RandomRange(1, (cnt + 1));
    Skill := PList[FRand - 1];
  end
  else
  begin
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        Skill := EFF_5[i];
        break;
      end;
    end;
  end;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := SkillData[Skill].Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := SkillData[Skill].TargetAnimation;
  if ((SkillData[Skill].TargetType = 21) and not(xPassive)) then
  begin
    Packet.TargetID := mob^.ClientID;
    Self.TargetBuffSkill(Skill, SkillData[Skill].Anim, mob, @SkillData[Skill]);
    Packet.Dano :=
      ((PlayerCharacter.Base.CurrentScore.DNFis +
      PlayerCharacter.Base.CurrentScore.DNMAG) div 3);

    if (SkillData[Skill].Damage > 0) then
    begin
      Packet.Dano := Packet.Dano + SkillData[Skill].Damage;
    end;
    { Self.GetDamage(Skill, mob, Packet.DnType); }
    Packet.DnType := TDamageType.Critical;
    if (SkillData[Skill].Adicional > 0) then
    begin
      Packet.Dano := (Packet.Dano * 2);
    end;
    if (Packet.Dano >= 20000) then
    begin
      Packet.Dano := 20000;
    end;
    Randomize;
    Packet.Dano := Packet.Dano + RandomRange(20, 200);

    if (SkillData[Skill].Index = 180) then
    begin
      Randomize;
      if (RandomRange(1, 101) <= 8) then
      begin
        mob.RemoveBuff(mob.GetBuffToRemove);
      end;
    end;

    {
      if (mob.ClientId >= 3048) then
      begin
      if (Packet.Dano >= Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
      [mob.SecondIndex].HP) then
      begin
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
      [mob.SecondIndex].HP := 0;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .IsAttacked := False;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .AttackerID := 0;
      Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex]
      .DeadTime := Now;
      if (Self.VisibleMobs.Contains(Servers[mob.ChannelId].MOBS.TMobS
      [mob.Mobid].MobsP[mob.SecondIndex].Index)) then
      Self.VisibleMobs.Remove(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
      .MobsP[mob.SecondIndex].Index);
      mob.VisibleMobs.Clear;
      Servers[Self.ChannelId].Players[Self.ClientId]
      .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
      EXP_TYPE_MOB);
      Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
      ('Voc� recebeu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS
      [mob.Mobid].MobExp.ToString) + ' pontos de experi�ncia.', 0);
      mob.SendEffect($0);
      Packet.MobAnimation := 30;
      mob.IsDead := True;
      end
      else
      begin
      mob.RemoveHP(Packet.Dano, False);
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
      Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
      end;
    }
    if (mob^.ClientID >= 3048) then
    begin
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if (Packet.Dano >= Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) then
            begin
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100;
            end
            else
            begin
              deccardinal(Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Packet.TargetID := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].Base.ClientID;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;
          end;
        3355 .. 3369:
          begin // guards
            if (Packet.Dano >= Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) then
            begin
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100;
            end
            else
            begin
              deccardinal(Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Packet.TargetID := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].Base.ClientID;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;
          end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];
          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 10;
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
          end;
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := MobsP^.HP;
          Packet.TargetID := MobsP.Base.ClientID;
          Self.SendToVisible(Packet, Packet.Header.size, True);
        end;
      end;
    end
    else
    begin
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        mob^.Character.CurrentScore.CurHP := 100;
      end
      else
      begin
        mob^.RemoveHP(Packet.Dano, False);
      end;
      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      Packet.TargetID := mob.ClientID;
      Self.SendToVisible(Packet, Packet.Header.size, True);
    end;
  end
  else
  begin
    if not(SkillData[Skill].TargetType = 21) then
    begin
      Packet.TargetID := Self.ClientID;
      Packet.AttackerID := 0;
      Packet.Dano := 0;
      Packet.DnType := TDamageType.None;
      Packet.MobAnimation := SkillData[Skill].TargetAnimation;
      Self.SelfBuffSkill(Skill, SkillData[Skill].Anim, mob,
        TPosition.Create(0, 0));
      Packet.MobCurrHP := Self.Character.CurrentScore.CurHP;
      Self.SendToVisible(Packet, Packet.Header.size);
    end;
  end;
end;

function TBaseMob.IsSecureArea(): Boolean;
var
  i: Integer;
begin
  Result := False;
  if (TPosition.Create(3450, 690).InRange(Self.PlayerCharacter.LastPos, 145))
  then
  begin
    Result := True;
  end;
end;
{$ENDREGION}
{$REGION 'Effect Functions'}

procedure TBaseMob.SendEffect(EffectIndex: DWORD);
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Code := $117;
  Packet.Index := Self.ClientID;
  Packet.Effect := EffectIndex;
  Self.SendToVisible(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Move/Teleport'}

procedure TBaseMob.Teleport(Pos: TPosition);
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  Self.SendCreateMob;
  // Self.UpdateVisibleList;
end;

procedure TBaseMob.Teleport(Posx, Posy: WORD);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;

procedure TBaseMob.Teleport(Posx, Posy: string);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;

procedure TBaseMob.WalkTo(Pos: TPosition; speed: WORD; MoveType: Byte);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := MoveType;
  Packet.speed := speed;
  Self.SendToVisible(Packet, Packet.Header.size, True);
  Self.UpdateVisibleList;
end;

procedure TBaseMob.WalkAvanced(Pos: TPosition; SkillID: Integer);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) then
    Exit;

  if (Self.PlayerCharacter.LastPos.Distance(Pos) > 18) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := 0;
  Packet.Unk := SkillID;
  Packet.speed := 125; // era 125
  Self.SendToVisible(Packet, Packet.Header.size, True);
  Self.UpdateVisibleList;
end;

procedure TBaseMob.WalkBacked(Pos: TPosition; SkillID: Integer; mob: PBaseMob);
var
  PacketAtk: TRecvDamagePacket;
  PacketMove: TMovementPacket;
begin
  ZeroMemory(@PacketMove, sizeof(PacketMove));
  PacketMove.Header.size := sizeof(PacketMove);
  PacketMove.Header.Index := mob.ClientID;
  PacketMove.Header.Code := $301;
  PacketMove.Destination := Pos;
  mob.PlayerCharacter.LastPos := Pos;
  PacketMove.MoveType := 0;
  PacketMove.Unk := SkillID;
  PacketMove.speed := 15;
  ZeroMemory(@PacketAtk, sizeof(PacketAtk));
  PacketAtk.Header.size := sizeof(PacketAtk);
  PacketAtk.Header.Index := Self.ClientID;
  PacketAtk.Header.Code := $102;
  PacketAtk.SkillID := SkillID;
  PacketAtk.AttackerPos := Self.PlayerCharacter.LastPos;
  PacketAtk.AttackerID := Self.ClientID;
  PacketAtk.Animation := SkillData[SkillID].Anim;
  PacketAtk.AttackerHP := Self.Character.CurrentScore.CurHP;
  PacketAtk.TargetID := mob.ClientID;
  PacketAtk.MobAnimation := SkillData[SkillID].TargetAnimation;
  PacketAtk.DnType := TDamageType.None;
  PacketAtk.Dano := 0;
  PacketAtk.MobCurrHP := mob.Character.CurrentScore.CurHP;
  PacketAtk.DeathPos := mob.PlayerCharacter.LastPos;
  Self.SendToVisible(PacketAtk, PacketAtk.Header.size, True);
  mob.SendToVisible(PacketMove, PacketMove.Header.size, True);
  mob.UpdateVisibleList;
end;
{$ENDREGION}
{$REGION 'Pets'}

procedure TBaseMob.CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD);
var
  pId: Integer;
begin
  pId := TFunctions.FreePetId(Self.ChannelId);
  ZeroMemory(@Servers[Self.ChannelId].PETS[pId], sizeof(TPet));
  Self.PetClientID := pId;
  Servers[Self.ChannelId].PETS[pId].Base.Create(nil, pId, Self.ChannelId);
  Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.ClientID :=
    Servers[Self.ChannelId].PETS[pId].Base.ClientID;
  case PetType of
    X14:
      begin
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxHP := (SkillData[SkillID].Attribute div 5);
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurHP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNFis := ((SkillData[SkillID].Attribute div 10) div 4);;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFFis := ((SkillData[SkillID].Attribute div 10) div 2);
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DEFFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[0].
          Index := 328; // x14 face
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[1].
          Index := 328;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Altura := 7;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Tronco := $77;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Perna := $77;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Corpo := 0;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Exp := 1;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Level :=
          Self.PlayerCharacter.Base.Level;
        Servers[Self.ChannelId].PETS[pId].PetType := X14;
        Servers[Self.ChannelId].PETS[pId].Duration :=
          (SkillData[SkillID].Duration);
        Servers[Self.ChannelId].PETS[pId].IntName := SkillData[SkillID].EFV[0];
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.LastPos := Pos;
        Servers[Self.ChannelId].PETS[pId].MasterClientID := Self.ClientID;
      end;
    NORMAL_PET:
      begin // soon
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxHP := ItemList[SkillID].HP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurHP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.MaxMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxHP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.CurMP := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNFis := ItemList[SkillID].ATKFis * 2;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DNMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DNFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFFis := ItemList[SkillID].MagAtk * 2;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.DEFMAG := Servers[Self.ChannelId].PETS[pId]
          .Base.PlayerCharacter.Base.CurrentScore.DEFFis;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[0].
          Index := ItemList[SkillID].Duration; // duration will be the mob face
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Equip[1].
          Index := ItemList[SkillID].Duration;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Altura := ItemList[SkillID].TextureID;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Tronco := ItemList[SkillID].TextureID *
          ItemList[SkillID].MeshIDWeapon;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Perna := ItemList[SkillID].TextureID *
          ItemList[SkillID].MeshIDWeapon;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.
          CurrentScore.Sizes.Corpo := ItemList[SkillID].TextureID *
          ItemList[SkillID].MeshIDWeapon;;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Exp := 1;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.Base.Level := 50;
        Servers[Self.ChannelId].PETS[pId].PetType := NORMAL_PET;
        Servers[Self.ChannelId].PETS[pId].Duration := 0;
        Servers[Self.ChannelId].PETS[pId].IntName := ItemList[SkillID].DelayUse;
        Servers[Self.ChannelId].PETS[pId].Base.PlayerCharacter.LastPos := Pos;
        Servers[Self.ChannelId].PETS[pId].MasterClientID := Self.ClientID;
      end;
  end;
end;

procedure TBaseMob.DestroyPet(PetID: WORD);
var
  i: Integer;
begin
  Servers[Self.ChannelId].Players[Self.ClientID].UnspawnPet(PetID);
  for i in Self.VisiblePlayers do
  begin
    Servers[Self.ChannelId].Players[i].UnspawnPet(PetID);
  end;

  ZeroMemory(@Servers[Self.ChannelId].PETS[PetID], sizeof(TPet));
end;
{$ENDREGION}
{$REGION 'TPrediction'}

procedure TPrediction.Create;
begin
  Timer := TStopwatch.Create;
end;

function TPrediction.Delta: Single;
begin
  if ETA > 0 then
    Result := Elapsed / ETA
  else
    Result := 1;
end;

function TPrediction.Elapsed: Integer;
begin
  Result := Timer.ElapsedTicks;
end;

function TPrediction.CanPredict: Boolean;
begin
  Result := ((ETA > 0) AND (Source.IsValid) AND (Destination.IsValid));
end;

function TPrediction.Interpolate(out d: Single): TPosition;
begin
  d := Delta;
  if (d >= 1) then
  begin
    ETA := 0;
    Result := Destination;
  end
  else
    Result := TPosition.Lerp(Source, Destination, d);
end;

procedure TPrediction.CalcETA(speed: Byte);
var
  Dist: WORD;
begin
  Dist := Source.Distance(Destination);
  speed := speed * 190;
  ETA := (AI_DELAY_MOVIMENTO + (Dist * (1000 - speed)));
end;
{$ENDREGION}
{$REGION 'Warrior'}

procedure TBaseMob.WarriorSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    ATAQUE_PODEROSO:
      begin
        var
        aditionalCritical := 0;
        if (SkillData[Skill].Level >= 9) then
        begin
          var
          helper := 10 - SkillData[Skill].Level;
          aditionalCritical := 10 + (2 * helper);
        end;
        Dano := Self.GetDamage(Skill, defender, DmgType, aditionalCritical);

        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    PANCADA:
       begin
      Dano := Self.GetDamage(Skill, defender, DmgType, Dano);

      if not(Self.ValidAttack(DmgType, 0, defender)) then
      begin
        Dano := 0;
        if (DmgType = Normal) then
          DmgType := Immune;
      end;
    end;
    AVANCO_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
        case defender.ClientID of
          1 .. 1000: // MAX_CONNECTIONS players
            begin
              Self.WalkAvanced(defender.PlayerCharacter.LastPos, Skill);
            end;
          3048 .. 9147: // mobs
            begin
              case defender.ClientID of
                3340 .. 3354: // stones
                  begin
                    Self.WalkAvanced(Servers[Self.ChannelId].DevirStones
                      [defender.ClientID].PlayerChar.LastPos, Skill);
                  end;
                3355 .. 3369: // guards
                  begin
                    Self.WalkAvanced(Servers[Self.ChannelId].DevirGuards
                      [defender.ClientID].PlayerChar.LastPos, Skill);
                  end;
              else // mobs normais
                begin
                  Self.WalkAvanced(Servers[Self.ChannelId].MOBS.TMobS
                    [defender.Mobid].MobsP[defender.SecondIndex]
                    .CurrentPos, Skill);
                end;
              end;
            end;
        end;
      end;
    QUEBRAR_ARMADURA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    INCITAR:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    RESOLUTO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, Dano)) then
        begin
          defender.ResolutoPoints := SkillData[Skill].Damage;
          defender.ResolutoTime := Now;
          defender.TargetBuffSkill(6879, 0, defender, @SkillData[6879]);
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    ESTOCADA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, Dano, False)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    FERIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
  end;
end;

procedure TBaseMob.WarriorAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean; out MoveToTarget: Boolean);
begin
  case SkillData[Skill].Index of
    TEMPESTADE_LAMINA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    AREA_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    CANCAO_GUERRA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    SALTO_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    GRITO_MEDO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, FEAR_TYPE, defender, Dano)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
    LAMINA_CARREGADA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    LAMINA_CARREGADA_FOGO:
      begin
        Self.AddBuff(11930); // FOGO
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    LAMINA_CARREGADA_AGUA:
      begin
        Self.AddBuff(11931); // ÁGUA
        Self.AddBuff(11933); // BOLHA 2 HITS
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    LAMINA_CARREGADA_VENTO:
      begin
        Self.AddBuff(11932); // VENTO
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    INVESTIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, defender)) then
        begin
          CanDebuff := True;
          //mob.AddBuff(Skill);
        end
        else
        begin
          if (DmgType = Normal) then
            DmgType := Immune;
          Dano := 0;
        end;
      end;
  end;
end;

procedure TBaseMob.WarriorSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  Pos: TPosition);
begin
  case SkillData[Skill].Index of
    GlobalDefs.Block, GlobalDefs.CANCAO_DEFESA, GlobalDefs.CANCAO_GLORIA,
      GlobalDefs.CANCAO_BRAVURA, GlobalDefs.FURIA:
      begin
        Self.AddBuff(Skill);
        Self.SendCurrentHPMP(True);
      end;
    GlobalDefs.MESTRE_ESPADA:
      begin
        Self.AddBuff(Skill);
      end;
    GlobalDefs.UIVO_LIBERDADE:
      begin
        Self.AddBuff(Skill);
      end;
    GlobalDefs.UIVO_SANGUE:
      begin
        Self.AddBuff(Skill);
      end;
    GlobalDefs.ESPADA_SANGRENTA:
      begin
        Self.AddBuff(Skill);
      end;
    GlobalDefs.REVITALIZAR:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 1;
        Self.HPRSkillID := Skill;
        Self.AddBuff(Skill);
      end;
    GlobalDefs.DESPERTAR:
      begin
        var
          i: Integer;
        for i in Self._buffs.Keys do
        begin
          if (5 = SkillData[i].Index) then
          begin
            if (SkillData[i].Level >= SkillData[Skill].Level) then
            begin
              Self.AddBuff(Skill);
            end
            else
            begin
              // pegar a skill do mesmo level da furia(304 = indice anterior ao despertar nv 1 para que
              // s� precise realizar a soma do lvl para achar o indice do despertar correto)
              Self.AddBuff(304 + SkillData[i].Level);
            end;
          end;
        end;
      end;
    RETORNAR:
      begin
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;

        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
  end;
end;

procedure TBaseMob.WarriorTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
begin
  case SkillData[Skill].Index of
    GlobalDefs.CANCAO_DEFESA, GlobalDefs.CANCAO_GLORIA,
      GlobalDefs.CANCAO_BRAVURA, GlobalDefs.AVANCO_PODEROSO,
      GlobalDefs.QUEBRAR_ARMADURA, GlobalDefs.INCITAR, GlobalDefs.RESOLUTO,
      GlobalDefs.AREA_IMPACTO, GlobalDefs.CANCAO_GUERRA,
      GlobalDefs.FERIDA_MORTAL, GlobalDefs.CANCAO_MEDO:
      begin
        mob.AddBuff(Skill);
      end;
    GlobalDefs.ESTOCADA:
      begin
        Self.SKDSkillEtc1 := DataSkill^.EFV[0];
        Self.SKDIsMob := mob^.Character = nil;
        Self.SDKSecondIndex := mob^.SecondIndex;
        if (mob^.Character = nil) then
          Self.SDKMobID := mob^.Mobid;

        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
  end;
end;

{$ENDREGION}
{$REGION 'Rifleman'}

procedure TBaseMob.RiflemanSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    CONTAGEM_REGRESSIVA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TIRO_FATAL:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TIRO_ANGULAR:
      begin
        var
        aditionalCritical := 23 + (2 * SkillData[Skill].Level);
        Dano := Self.GetDamage(Skill, defender, DmgType, aditionalCritical);
      end;
    TIRO_NA_PERNA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PERSEGUIDOR:
      begin
        Dano := 0;
        DmgType := Self.GetDamageType3(Skill, True, defender);
        if (Self.ValidAttack(DmgType, 0, defender, Dano, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    PRIMEIRO_ENCONTRO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, PARALISYS_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ELIMINAR_ALVO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
      end;
    PONTO_VITAL:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, CHOCK_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    MARCA_PERSEGUIDOR:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, Dano)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CONTRA_GOLPE:
      begin
        var
        aditionalCritical := 48 + (2 * SkillData[Skill].Level);
        Dano := Self.GetDamage(Skill, defender, DmgType, aditionalCritical);
      end;
    ATAQUE_ATORDOANTE:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ELIMINACAO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
  end;
end;

procedure TBaseMob.RiflemanAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    TIRO_ANGULAR:
      begin
        var
        aditionalCritical := 23 + (2 * SkillData[Skill].Level);
        Dano := Self.GetDamage(Skill, defender, DmgType, aditionalCritical);
      end;
    DETONACAO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    RAJADA_SONICA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
  end;
end;

procedure TBaseMob.RiflemanSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  Pos: TPosition);
begin
  case SkillData[Skill].Index of
    GlobalDefs.NAJMUM, GlobalDefs.PRECISAO:
      begin
        Self.AddBuff(Skill);
      end;
    GlobalDefs.OCULTAR, GlobalDefs.PREDADOR, GlobalDefs.PREDADOR_FOGO,
      GlobalDefs.PREDADOR_AGUA, GlobalDefs.PREDADOR_VENTO:
      begin
        case SkillData[Skill].Index of
          PREDADOR_FOGO:
            begin
              Self.AddBuff(11930);
              Self.AddBuff(Skill);
            end;

          PREDADOR_AGUA:
            begin
              Self.AddBuff(11931);
              Self.AddBuff(11933);
              Self.AddBuff(Skill);
            end;

          PREDADOR_VENTO:
            begin
              Self.AddBuff(11932);
              Self.AddBuff(Skill);
            end;
        end;
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId]
          .Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          var
          RlkSlot := TItemFunctions.GetItemSlotByItemType
            (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);

          if (RlkSlot <> 255) then
          begin
            var
              Item: PItem := @Servers[Self.ChannelId].Players[Self.ClientID]
                .Base.Character.Inventory[RlkSlot];
            var
            index := Item.Index;

            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
            Servers[Self.ChannelId].Players[Self.ClientID].SendEffect(0);
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, index);
          end;
        end;

        Self.AddBuff(Skill);

        if ((Self.PetClientID > 0) and
          (Servers[Self.ChannelId].PETS[Self.PetClientID].PetType = X14)) then
        begin
          Servers[Self.ChannelId].PETS[Self.PetClientID].Base.AddBuff(Skill);
        end;
      end;

    GlobalDefs.DEMOLICAO_X14:
      begin
        if (Self.PetClientID > 0) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Você não pode possuir dois PETs ao mesmo tempo.');
          Exit;
        end;

        Self.CreatePet(X14, Pos, Skill);
        Servers[Self.ChannelId].Players[Self.ClientID]
          .SpawnPet(Self.PetClientID);
        Self.AddBuff(Skill);
      end;

    GlobalDefs.RETORNAR:
      begin
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar com relíquia.');
          Exit;
        end;

        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Impossível usar em outros países.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
  end;
end;

procedure TBaseMob.RiflemanTargetBuffSkill(Skill, Anim: DWORD;
  out mob: PBaseMob; DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
begin
  case SkillData[Skill].Index of
    PERSEGUIDOR:
      begin
        Self.SKDSkillEtc1 := DataSkill^.EFV[0];
        Self.SKDIsMob := mob^.Character = nil;
        Self.SDKSecondIndex := mob^.SecondIndex;
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    ELIMINACAO:
      begin
        mob^.RemoveBuffs(1);
      end
  else
    begin
      mob^.AddBuff(Skill);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Magician'}

procedure TBaseMob.BlackMagicianShieldMPCostFactor(BuffIndex: DWORD;
  out Fator: System.Double);
var
  i: Integer;
  Index: DWORD;
begin
  if (Self.IsDungeonMob) then
    Exit;
  if (BuffIndex = 0) then
    Exit;
  if (Self._buffs.Count = 0) then
    Exit;
  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      if (SkillData[i].Level = 1) then
      begin
        Fator := 1.5;
      end
      else
      begin
        Fator := 1.5 - ((SkillData[i].Level - 1) * 0.05);
      end;
    end;
  end;
end;

procedure TBaseMob.MagicianSkill(Skill, Anim: DWORD; DataSkill: P_SkillData;
  out defender: PBaseMob; out Dano: Integer; out DmgType: TDamageType;
  out CanDebuff: Boolean; out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    CHAMA_CAOTICA:
      begin
        var
        aditionalCritical := 23 + (2 * SkillData[Skill].Level);
        Dano := Self.GetDamage(Skill, defender, DmgType, aditionalCritical);

        if (Self.ValidAttack(DmgType, 0, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    ONDA_CHOQUE:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    INFERNO_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION1) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    IMPEDIMENTO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType, SILENCE_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    CORROER:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          var
          Helper1 := Dano;
          var
            Helper2: Byte;

          Self.AttackParse(Skill, Anim, defender, Helper1, DmgType, CanDebuff,
            Helper2, DataSkill);
          var
          Helper := ((Helper1 div 100) * SkillData[Skill].Adicional);
          Inc(Self.Character.CurrentScore.CurHP, Helper);
          Self.SendCurrentHPMP(True);
        end;
      end;
    LANCA_RAIO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION3) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);
        if (Self.ValidAttack(DmgType)) then
        begin
          // Verifica e processa o buff de índice 36
          if (defender^.BuffExistsByIndex(36) = True) then
          begin
            dec(defender^.BolhaPoints, 2);

            if (defender^.BolhaPoints = 0) then
            begin
              defender^.RemoveBuffByIndex(36);
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] Proteção desativada.',
                16, 1, 1);
            end
            else
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] restam ' +
                defender.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
            end;
          end;
          if (defender^.BuffExistsByIndex(365) = True) then
          begin
            dec(defender^.BolhaPoints, 2);

            if (defender^.BolhaPoints = 0) then
            begin
              defender^.RemoveBuffByIndex(365);
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] Proteção desativada.',
                16, 1, 1);
            end
            else
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] restam ' +
                defender.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
            end;
          end;

          CanDebuff := True;
        end;
      end;
    VINCULO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, 250 + (31 * SkillData[Skill].Level));
        if (Self.ValidAttack(DmgType)) then
        begin
          var
          Helper1 := Dano;
          var
            Helper2: Byte;

          Self.AttackParse(Skill, Anim, defender, Helper1, DmgType, CanDebuff,
            Helper2, DataSkill);
          var
          Helper := ((Helper1 div 100) * SkillData[Skill].Adicional);
          Self.RemoveHP(Helper, True, True);
        end;
      end;
    SOFRIMENTO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    POLIMORFO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, 0)) then
        begin
          CanDebuff := True;
        end;
      end;
    MAO_ESCURIDAO:
      begin
        Dano := 0;
        DmgType := Self.GetDamageType3(Skill, False, defender);
        if (Self.ValidAttack(DmgType, 0, defender, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;

procedure TBaseMob.MagicianAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    ENXAME_ESCURIDAO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ECLATER:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESPLENDOR_CAOTICO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    BRUMA:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);

        if (Self.ValidAttack(DmgType, STUN_TYPE, defender, Dano, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    QUEDA_NEGRA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    PECADOS_MORTAIS:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    PECADOS_MORTAIS_FOGO:
      begin
        Self.AddBuff(11930); // Fogo
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    PECADOS_MORTAIS_AGUA:
      begin
        Self.AddBuff(11931); // Água
        Self.AddBuff(11933); // Se o buff for água, adicione bolha 2hits
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    PECADOS_MORTAIS_VENTO:
      begin
        Self.AddBuff(11932); // Vento
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetMobAbility(EF_ACCELERATION2) > 0) then
          Inc(Dano, SkillData[Skill].Adicional);

        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;

procedure TBaseMob.MagicianSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  Pos: TPosition);
begin
  case SkillData[Skill].Index of
    ESCUDO_NEGRO:
      begin
        mob^.AddBuff(Skill);
      end;
    FLUXO_MANA:
      begin
        Randomize;
        var
        h2 := 0;
        case Self.Character.CurrentScore.Int of
          1 .. 51:
            begin
              h2 := Random(10);
            end;
          52 .. 102:
            begin
              h2 := Random(20);
            end;
          103 .. 153:
            begin
              h2 := Random(30);
            end;
          154 .. 204:
            begin
              h2 := Random(40);
            end;
          205 .. 255:
            begin
              h2 := Random(50);
            end;
        end;
        Self.AddMP((Self.Character.CurrentScore.MaxMP div 100) *
          (50 + h2), True);
      end;
    MASS_TELEPORT:
      begin
        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;
        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;
        Self.WalkTo(Pos, 70, MOVE_TELEPORT);
        Self.SendCurrentHPMP();
      end;
    RETORNAR:
      begin
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;

        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
  end;
end;

procedure TBaseMob.MagicianTargetBuffSkill(Skill, Anim: DWORD;
  out mob: PBaseMob; DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
begin
  case SkillData[Skill].Index of
    CHAMA_CAOTICA, ONDA_CHOQUE, INFERNO_CAOTICO, IMPEDIMENTO, CORROER,
      LANCA_RAIO, MAO_ESCURIDAO, ENXAME_ESCURIDAO, ESPLENDOR_CAOTICO, BRUMA,
      QUEDA_NEGRA:
      begin
        mob^.AddBuff(Skill);
      end;
    ECLATER:
      begin
        if ((mob^.Character <> nil) and (mob^.Character.CurrentScore.CurHP <=
          (mob^.Character.CurrentScore.MaxHP / 2))) then
        begin
          mob^.RemoveHP(SkillData[Skill].EFV[0], True, True);
        end
        else
          mob^.AddBuff(Skill);
      END;
    SOFRIMENTO:
      begin
        Self.SKDSkillEtc1 := DataSkill^.EFV[0];
        Self.SKDIsMob := mob^.Character = nil;
        Self.SDKSecondIndex := mob^.SecondIndex;
        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;
    MASS_TELEPORT:
      begin
        if (mob^.InClastleVerus) then
        begin
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (TItemFunctions.GetItemReliquareSlot(Servers[mob^.ChannelId].Players
          [mob^.ClientID]) <> 255) then
        begin
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;
        if (mob^.Character.Nation > 0) then
        begin
          if (mob^.Character.Nation <> Servers[mob^.ChannelId].NationID) then
          begin
            Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;
        mob^.WalkTo(TPosition.Create(Posx.ToSingle, Posy.ToSingle), 70,
          MOVE_TELEPORT);
        mob^.SendCurrentHPMP();
      end;
    POLIMORFO:
      begin
        mob^.Polimorfed := True;
        if (mob^.ClientID <= MAX_CONNECTIONS) then
        begin
          Randomize;
          var
          polimorfos := [237, 283, 284, 302, 435];
          var
          EuEscolhoVoce := RandomRange(0, 4);
          mob^.SendCreateMob(SPAWN_NORMAL, 0, True, polimorfos[EuEscolhoVoce]);
          mob^.AddBuff(Skill);
        end;
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Templar'}

procedure TBaseMob.TemplarSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    STIGMA:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    PROFICIENCIA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        var
        help := ((Trunc(Self.PlayerCharacter.Base.CurrentScore.DEFFis) +
          Trunc(Self.PlayerCharacter.Base.CurrentScore.DEFMAG)) div 100) *
          SkillData[Skill].Adicional;
        Inc(Dano, help);
        // Self.Character.Equips verificar durabilidade
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end;
      end;
    NEMESIS:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    TRAVAR_ALVO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        Inc(Dano, ((Self.PlayerCharacter.Base.CurrentScore.DEFMAG) div 100) *
          SkillData[Skill].Adicional);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ATRACAO_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
          defender^.WalkTo(Self.PlayerCharacter.LastPos);
        end;
      end;
  end;
end;

procedure TBaseMob.TemplarAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    INCITAR_MULTIDAO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        CanDebuff := True;
      end;
    EMISSAO_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    LAMINA_PROMESSA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    LAMINA_PROMESSA_FOGO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    LAMINA_PROMESSA_AGUA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    LAMINA_PROMESSA_VENTO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
  end;
end;

procedure TBaseMob.TemplarSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  Pos: TPosition);
begin
  case SkillData[Skill].Index of
    GUARDIAO, ElThymos, SANGUE_SAGRADO, ESCUDO_REFLETOR, EL_AEGIS, EL_ASTER,
      INCITAR_MULTIDAO, ATRACAO_DIVINA:
      begin
        Self.AddBuff(Skill);
      end;
    REMEDIAR:
      begin
        Self.CalcAndCure(Skill, mob,
          ((Self.Character.CurrentScore.CurHP -
          Self.Character.CurrentScore.MaxHP) div 100) * SkillData[Skill]
          .Adicional);
      end;
    LAMINA_PROMESSA:
      begin
        Self.LaminaPoints := SkillData[Skill].EFV[0];
        Self.LaminaID := Skill;
        Self.EventListener := True;
        Self.EventAction := 1;
        Self.AddBuff(Skill);
      end;
    LAMINA_PROMESSA_FOGO:
      begin
        Self.AddBuff(11930); // Fogo
        Self.LaminaPoints := SkillData[Skill].EFV[0];
        Self.LaminaID := Skill;
        Self.EventListener := True;
        Self.EventAction := 1;
        Self.AddBuff(Skill);
      end;
    LAMINA_PROMESSA_AGUA:
      begin
        Self.AddBuff(11931); // Água
        Self.AddBuff(11933); // Se o buff for água, adicione bolha 2hits
        Self.LaminaPoints := SkillData[Skill].EFV[0];
        Self.LaminaID := Skill;
        Self.EventListener := True;
        Self.EventAction := 1;
        Self.AddBuff(Skill);
      end;
    LAMINA_PROMESSA_VENTO:
      begin
        Self.AddBuff(11932); // Vento
        Self.LaminaPoints := SkillData[Skill].EFV[0];
        Self.LaminaID := Skill;
        Self.EventListener := True;
        Self.EventAction := 1;
        Self.AddBuff(Skill);
      end;
    DEFESA_CONCENTRADA:
      begin
        Self.DefesaPoints := 3;
        Self.AddBuff(Skill);
      end;
    PROTECAO:
      begin
        Self.BolhaPoints := SkillData[Skill].EFV[0];
        Self.AddBuff(Skill);
      end;
    PROTECAO_AGUA:
      begin
        Self.BolhaPoints := SkillData[Skill].EFV[0];
        Self.AddBuff(Skill);
      end;
    RETORNAR:
      begin
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;

        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
  end;
end;

procedure TBaseMob.TemplarTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
begin
  case SkillData[Skill].Index of
    NEMESIS, EL_ASTER, EMISSAO_DIVINA, PROFICIENCIA, ATRACAO_DIVINA:
      begin
        mob^.AddBuff(Skill);
      end;
    INCITAR_MULTIDAO:
      begin
        if (mob^.ClientID = Self.ClientID) then
        begin
          mob^.RemoveDebuffs(1);
          mob^.AddBuff(Skill);
        end
        else
          mob^.RemoveDebuffs(1);
      end;
    REMEDIAR:
      begin
        Self.CalcAndCure(Skill, mob,
          ((mob.Character.CurrentScore.MaxHP - mob.Character.CurrentScore.CurHP)
          div 100) * SkillData[Skill].Adicional);
      end;
    EL_TYCIA:
      begin
        Self.RemoveMP(Self.Character.CurrentScore.CurMP, True);
        mob^.Character.CurrentScore.CurHP := mob^.Character.CurrentScore.MaxHP;
        mob^.SendCurrentHPMP(True);
      end;
    UNIAO_DIVINA:
      begin
        if (mob^.ClientID <> Self.ClientID) then
        begin
          mob.UniaoDivina := String(Self.Character.Name);
          Inc(mob^.MOB_EF[SkillData[Skill].EF[0]], SkillData[Skill].EFV[0]);
          Inc(mob^.MOB_EF[SkillData[Skill].EF[1]],
            (Self.Character.CurrentScore.MaxHP div 100) *
            (100 - SkillData[Skill].EFV[1]));
          Inc(mob^.MOB_EF[EF_BLANK16], SkillData[Skill].Adicional);
          mob^.AddBuff(Skill)
        end
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Dual'}

procedure TBaseMob.DualGunnerSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    MJOLNIR:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESPINHO_VENENOSO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, PARALISYS_TYPE, defender, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    TIRO_DESCONTROLADO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
      end;
    VENENO_LENTIDAO:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, LENT_TYPE, defender, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    REQUIEM:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;
    VENENO_MANA:
      begin
        Dano := 0;
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          var
          Helper := 0;
          if (defender.Character <> nil) then
          begin
            if (SkillData[Skill].Adicional > 0) then
              Helper := (defender.Character.CurrentScore.MaxMP div 100) *
                SkillData[Skill].Adicional;
          end;
          Inc(Dano, Helper);
          defender.RemoveMP(Helper, True);
          CanDebuff := True;
        end;
      end;
    CHOQUE_SUBITO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);

        if (Self.ValidAttack(DmgType, CHOCK_TYPE, defender, Dano)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
    NEGAR_CURA:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, Dano)) then
        begin
          CanDebuff := True;
        end;
      end;
    ESTRIPADOR:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;
    VENENO_HIDRA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
  end;
end;

procedure TBaseMob.DualGunnerAreaSkill(Skill, Anim: DWORD;
  out defender: PBaseMob; out Dano: Integer; out DmgType: TDamageType;
  out CanDebuff: Boolean; out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    FUMACA_SANGRENTA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
      end;
    EXPLOSAO_RADIANTE:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, STUN_TYPE, defender)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;
  end;
end;

procedure TBaseMob.DualGunnerSelfBuffSkill(Skill, Anim: DWORD;
  out mob: PBaseMob; Pos: TPosition);
begin
  case SkillData[Skill].Index of
    MAXIMIZAR, ROSA_NEGRA, ESQUIVA_DG, ROSA_SANGRENTA:
      begin
        Self.AddBuff(Skill);
      end;
    ROSA_SANGRENTA_FOGO:
      begin
        Self.AddBuff(11930);
        Self.AddBuff(Skill);
      end;
    ROSA_SANGRENTA_AGUA:
      begin
        Self.AddBuff(11931);
        Self.AddBuff(11933);
        Self.AddBuff(Skill);
      end;
    ROSA_SANGRENTA_VENTO:
      begin
        Self.AddBuff(11932);
        Self.AddBuff(Skill);
      end;
    DISPAROS_RAPIDOS:
      begin
        Servers[Self.ChannelId].Players[Self.ClientID]
          .DisparosRapidosBarReset(Skill);
        Self._cooldown.Clear;
        Self.AddBuff(Skill);
      end;
    ACAO_IMEDIATA:
      begin
        if (SkillData[Skill].Level = 10) then
        begin
          while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId]
            .Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
          begin
            var
            RlkSlot := TItemFunctions.GetItemSlotByItemType
              (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
            if (RlkSlot <> 255) then
            begin
              var
                Item: PItem := @Servers[Self.ChannelId].Players[Self.ClientID]
                  .Base.Character.Inventory[RlkSlot];
              var
              index := Item.Index;
              ZeroMemory(Item, sizeof(TItem));
              Servers[Self.ChannelId].Players[Self.ClientID]
                .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
              Servers[Self.ChannelId].Players[Self.ClientID].SendEffect(0);
              Servers[Self.ChannelId].CreateMapObject(@Self, 320, index);
            end;
          end;
        end;
        Self.AddBuff(Skill);
      end;
    OCULTAR_DG:
      begin
        while (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId]
          .Players[Self.ClientID], 40, INV_TYPE, 0) <> 255) do
        begin
          var
          RlkSlot := TItemFunctions.GetItemSlotByItemType
            (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if (RlkSlot <> 255) then
          begin
            var
              Item: PItem := @Servers[Self.ChannelId].Players[Self.ClientID]
                .Base.Character.Inventory[RlkSlot];
            var
            index := Item.Index;
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
            Servers[Self.ChannelId].Players[Self.ClientID].SendEffect(0);
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, index);
          end;
        end;
        Self.AddBuff(Skill);
      end;
    RETORNAR:
      begin
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;

        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
  end;
end;

procedure TBaseMob.DualGunnerTargetBuffSkill(Skill, Anim: DWORD;
  out mob: PBaseMob; DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
begin
  case SkillData[Skill].Index of
    MJOLNIR, REQUIEM, ESTRIPADOR, CHOQUE_SUBITO, EXPLOSAO_RADIANTE, NEGAR_CURA,
      VENENO_HIDRA, 233:
      begin
        mob^.AddBuff(Skill);
      end;
    VENENO_LENTIDAO, ESPINHO_VENENOSO: // veneno da lentid�o e espinho venenoso
      begin
        if (mob^.Character <> nil) then
        begin
          Self.SKDSkillEtc1 := (DataSkill^.EFV[0]);
          Self.SKDTarget := mob^.ClientID;
          Self.SKDListener := True;
          Self.SKDAction := 1;
          Self.SKDSkillID := Skill;
          mob^.AddBuff(Skill);
        end;
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Santa'}

procedure TBaseMob.ClericSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    FLECHA_SAGRADA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);

        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;

    RETORNO_MAGICA:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if (defender.GetBuffCount < SkillData[Skill].Damage) then
        begin
          Dano := Dano * defender.GetBuffCount;
        end
        else
          Dano := Dano * SkillData[Skill].Damage;

        if (Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Inc(Dano, SkillData[Skill].Adicional);
          defender.RemoveBuffs(SkillData[Skill].Damage);
        end
        else
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;

          if (defender.BuffExistsByIndex(36) = True) then
          begin
            if (defender^.BolhaPoints >= (SkillData[Skill].Damage - 1)) then
            begin
              dec(defender^.BolhaPoints, SkillData[Skill].Damage - 1);
            end
            else
              dec(defender^.BolhaPoints, 1);

            if (defender^.BolhaPoints = 0) then
            begin
              defender^.RemoveBuffByIndex(36);
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] Proteção desativada.',
                16, 1, 1);
            end
            else
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] restam ' +
                defender.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
            end;
          end;
          if (defender.BuffExistsByIndex(365) = True) then
          begin
            if (defender^.BolhaPoints >= (SkillData[Skill].Damage - 1)) then
            begin
              dec(defender^.BolhaPoints, SkillData[Skill].Damage - 1);
            end
            else
              dec(defender^.BolhaPoints, 1);

            if (defender^.BolhaPoints = 0) then
            begin
              defender^.RemoveBuffByIndex(365);
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] Proteção desativada.',
                16, 1, 1);
            end
            else
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('[' + AnsiString(defender.Character.Name) +
                '] resistiu à sua habilidade de ataque.', 16, 1, 1);
              Servers[Self.ChannelId].Players[defender^.ClientID]
                .SendClientMessage('Você resistiu ao ataque de [' +
                AnsiString(Self.Character.Name) + '] restam ' +
                defender.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
            end;
          end;
        end;
      end;
  end;
end;

procedure TBaseMob.ClericAreaSkill(Skill, Anim: DWORD; out defender: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; out CanDebuff: Boolean;
  out Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    SENSOR_MAGICO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);

        if (defender.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
        end;
        if (defender.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            defender.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            defender.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;
        if (defender.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            defender.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            defender.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, 0, defender, Dano)) then
        begin
          if (defender.BuffExistsByIndex(OCULTAR)) then
          begin
            defender.RemoveBuffByIndex(OCULTAR);
          end;
          if (defender.BuffExistsByIndex(OCULTAR_DG)) then
          begin
            defender.RemoveBuffByIndex(OCULTAR_DG);
          end;
        end
        else
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    RAIO_SOLAR:
      begin
        Dano := 0;
        Self.GetDamage(Skill, defender, DmgType);
        if (Self.ValidAttack(DmgType, 0, defender, 0, True)) then
        begin
          CanDebuff := True;
        end
        else
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
    UEGENES_LUX:
      begin
        Dano := Self.GetDamage(Skill, defender, DmgType);
        if not(Self.ValidAttack(DmgType, 0, defender)) then
        begin
          Dano := 0;
          if (DmgType = Normal) then
            DmgType := Immune;
        end;
      end;
  end;
end;

procedure TBaseMob.ClericSelfBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  Pos: TPosition);
begin

  case SkillData[Skill].Index of
    124, 127, 137, 160:
      begin
        Self.AddBuff(Skill, True, True,
          (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
      end;
    NIKITA:
      begin
        Self.AddBuff(Skill);
      end;
    LIBERACAO_MANA:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 3;
        Self.HPRSkillID := Skill;
        Self.HPRSkillEtc1 := ((Self.Character.CurrentScore.DNMAG shr 3) +
          SkillData[Skill].EFV[0]);
        Self.AddBuff(Skill);
      end;
    CURA_MASSA:
      begin
        Self.CalcAndCure(Skill, mob);
        Self.AddBuff(Skill);
      end;
    RETORNAR:
      begin
        if (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar com rel�quia.');
          Exit;
        end;

        if (Self.InClastleVerus) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Imposs�vel usar em guerra. Use o teleporte.');
          Exit;
        end;
        if (Self.Character.Nation > 0) then
        begin
          if (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
          begin
            Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
              ('Imposs�vel usar em outros pa�ses.');
            Exit;
          end;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;
  end;
end;

procedure TBaseMob.ClericTargetBuffSkill(Skill, Anim: DWORD; out mob: PBaseMob;
  DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
begin
  case SkillData[Skill].Index of
    RESSUREICAO:
      begin
        var
          BoolHelper: Boolean;
        var
          i: Integer;
        if (mob.IsDead) then
        begin
          if (Self.PartyId = 0) then
            Exit;

          if (mob.PartyId = 0) then
            Exit;

          if (Servers[Self.ChannelId].Players[Self.ClientID].Party.InRaid) then
          begin
            if (mob.PartyId <> Self.PartyId) then
            begin
              BoolHelper := False;

              for i := 1 to 3 do
              begin
                if (Servers[Self.ChannelId].Players[Self.ClientID]
                  .Party.PartyAllied[i] = 0) then
                  Continue;

                if (Servers[Self.ChannelId].Players[Self.ClientID]
                  .Party.PartyAllied[i] = mob.PartyId) then
                begin
                  BoolHelper := True;
                  break;
                end;
              end;

              if not(BoolHelper) then
                Exit;
            end;
          end
          else
          begin
            if (mob.PartyId <> Self.PartyId) then
              Exit;
          end;

          mob.IsDead := False;

          mob.Character.CurrentScore.CurHP :=
            ((mob.Character.CurrentScore.MaxHP div 100) * SkillData
            [Skill].Damage);
          mob.SendEffect(1);
          mob.SendCurrentHPMP(True);

          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage
            ('Voc� foi ressuscitado pelo jogador ' +
            AnsiString(Self.Character.Name) + '.');
        end;
      end;
    CURA:
      begin
        Self.CalcAndCure(Skill, mob);
      end;
    RAIO_SOLAR: // raio solar
      begin
        var
          Helper2: Integer;
        if (mob^.Character <> nil) then
        begin
          Randomize;
          var
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);

          if (mob^.Character.CurrentScore.CurHP >= Helper) then
          begin // dano maior
            Helper2 := RandomRange(30, 59);
          end
          else
          begin // dano menor
            Helper2 := RandomRange(10, 29);
          end;
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNMAG div 2),
            Self.Character.CurrentScore.DNMAG + 1);
        end;
        if not(mob^.IsRaioSolar) then
        begin
          TSkillDamageThreadBySkill.Create(2000, Self.ChannelId,
            mob^.Character = nil, Skill, mob.SecondIndex, mob.Mobid,
            mob^.ClientID, ((DataSkill^.EFV[0] div 2) + Helper2));
          mob^.IsRaioSolar := True;
        end
        else
        begin
          mob^.IsResetRaioSolar := True;
        end;
        mob^.AddBuff(Skill);
      end;
    MAO_CURA: // mao de cura cl
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := Round(Self.CalcCure2(DataSkill^.EFV[0], mob, Skill)
          / DataSkill^.Duration);
        var
          i: Integer;
        for i := Low(Servers[ChannelId].Players)
          to High(Servers[ChannelId].Players) do
        begin
          if (Servers[ChannelId].Players[i].Character.Index <>
            mob^.PlayerCharacter.Base.CharIndex) then
          begin
            Continue;
          end
          else
          begin
            Servers[ChannelId].Players[i].HPRCycles := 0;
            break;
          end;
        end;
        mob^.AddBuff(Skill);
      end;
    MAO_CURA_I: // mao de cura cl
      begin
        mob^.AddBuff(11929);
        // Efeito mão da Cura - Concede 25% de aumento de cura.
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := Round(Self.CalcCure2(DataSkill^.EFV[0], mob, Skill)
          / DataSkill^.Duration);
        var
          i: Integer;
        for i := Low(Servers[ChannelId].Players)
          to High(Servers[ChannelId].Players) do
        begin
          if (Servers[ChannelId].Players[i].Character.Index <>
            mob^.PlayerCharacter.Base.CharIndex) then
          begin
            Continue;
          end
          else
          begin
            Servers[ChannelId].Players[i].HPRCycles := 0;
            break;
          end;
        end;
        mob^.AddBuff(Skill);
      end;
    LIBERACAO_MANA:
      begin
        mob.HPRListener := True;
        mob.HPRAction := 3;
        mob.HPRSkillID := Skill;
        mob.HPRSkillEtc1 := ((Self.Character.CurrentScore.DNMAG shr 3) +
          SkillData[Skill].EFV[0]);
        mob.AddBuff(Skill);
      end;
    RECUPERACAO:
      begin
        Self.CalcAndCure(Skill, mob);
        mob^.RemoveAllDebuffs;
      end;
    CURA_MASSA:
      begin
        Self.CalcAndCure(Skill, mob);
        mob.AddBuff(Skill);
      end;
    BENCAO, VELOCIDADE, GOLPE_DIVINO, AFIAR:
      begin
        mob^.AddBuff(Skill, True, True,
          (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));
      end;
    PURIFICAR:
      begin
        mob^.RemoveDebuffs(1);
      end;
    CURA_PREVENTIVA:
      begin
        if (mob^.Character = nil) then
          Exit;
        if (mob^.Character.CurrentScore.CurHP <=
          (mob^.Character.CurrentScore.MaxHP / 2)) then
        begin
          Self.CalcAndCure(Skill, mob);
        end
        else
          mob^.AddBuff(Skill);
      end;
    ESCUDO:
      begin
        mob.AddBuff(Skill);
      end;
    ESPLENDOR:
      begin
        if not Self.BuffExistsByIndex(349) then
        begin
          mob.AddBuff(Skill);
          mob.AddBuff(9500);
          Self.CalcAndCure(Skill, mob);
        end
        else
          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage
            ('O alvo está com a punição do esplendor.');
        Servers[Self.ChannelId].Players[Self.ClientID]
          .DisparosRapidosBarReset(5218);
        Self._cooldown.Clear;
      end;
    ESPLENDOR_FOGO:
      begin
        if not Self.BuffExistsByIndex(349) then
        begin
          mob.AddBuff(Skill);
          mob^.RemoveAllDebuffs;
          Self.AddBuff(11930); // Fogo
          mob.AddBuff(11934); // Punição do Esplendor
          Self.CalcAndCure(Skill, mob);
        end
        else
        begin
          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage
            ('O alvo está com a punição do esplendor.');
          Servers[Self.ChannelId].Players[Self.ClientID]
            .DisparosRapidosBarReset(5218);
          Self._cooldown.Clear;
        end;
      end;

    ESPLENDOR_AGUA:
      begin
        if not Self.BuffExistsByIndex(349) then
        begin
          mob.AddBuff(Skill);
          mob^.RemoveAllDebuffs;
          Self.AddBuff(11931); // Água
          Self.AddBuff(11933); // Água
          mob.AddBuff(11934); // Punição do Esplendor
          Self.CalcAndCure(Skill, mob);
        end
        else
        begin
          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage
            ('O alvo está com a punição do esplendor.');
          Servers[Self.ChannelId].Players[Self.ClientID]
            .DisparosRapidosBarReset(5218);
          Self._cooldown.Clear;
        end;
      end;
    ESPLENDOR_VENTO:
      begin
        if not Self.BuffExistsByIndex(349) then
        begin
          mob.AddBuff(Skill);
          mob^.RemoveAllDebuffs;
          Self.AddBuff(11932); // Vento
          mob.AddBuff(11934); // Punição do Esplendor
          Self.CalcAndCure(Skill, mob);
        end
        else
        begin
          Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage
            ('O alvo está com a punição do esplendor.');
          Servers[Self.ChannelId].Players[Self.ClientID]
            .DisparosRapidosBarReset(5218);
          Self._cooldown.Clear;
        end;
      end;
  end;
end;
{$ENDREGION}

end.
