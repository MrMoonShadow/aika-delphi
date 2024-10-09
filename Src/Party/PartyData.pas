unit PartyData;

interface

uses
  Windows, Generics.Collections;
{$OLDTYPELAYOUT ON}
{$REGION 'Party (Grupo) Data'}

type
  TCharName = record
    Name: String;
  end;

type
  PParty = ^TParty;

  TParty = record
    Index: WORD;
    Leader: WORD;
    Members: TList<WORD>;
    MemberName: TList<Integer>;
    RequestId: WORD;
    ChannelId: BYTE;
    ExpAlocate: BYTE;
    ItemAlocate: BYTE;
    LastSlotItemReceived: Integer;
    DungeonLobbyConfirm: Array of WORD;
    { Raid Misc }
    InRaid: Boolean;
    IsRaidLeader: Boolean;
    RaidPartyId: BYTE;
    PartyAllied: Array [1 .. 3] of WORD;
    PartyRaidCount: Integer;
  public
    function AddMember(memberClientId: WORD): Boolean;
    procedure RemoveMember(memberClientId: WORD);
    procedure DestroyParty(ClientId: WORD);
    function GetFreeRaidSpace(): BYTE;
    procedure RefreshParty;
    procedure RefreshRaid;
    class function CreateParty(ClientId: WORD; ChannelId: BYTE): Boolean;
      overload; static;
    class function CreateRaid(RequesterID, AcceptID: WORD; ChannelId: BYTE)
      : Boolean; overload; static;
    class function AddPartyToRaid(RequesterID, AcceptID: WORD; ChannelId: BYTE)
      : Boolean; overload; static;
    procedure SendToParty(var Packet; size: WORD);
    procedure SendToRaid(var Packet; size: WORD);
  end;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, Log, SysUtils, Packets;
{$REGION 'Party (Grupo) Data'}

function TParty.AddMember(memberClientId: WORD): Boolean;
begin
  Result := False;
  if not(Servers[ChannelId].Players[memberClientId].Base.IsActive) then
    Exit;
  if (Self.Members.Count = 6) then
    Exit;

  var
  con := 0;
  while con < Self.Members.Count do
  begin
    if (Self.Members.Items[con] = memberClientId) then
    begin
      Exit;
    end;
    Inc(con, 1);
  end;
  Self.Members.Add(memberClientId);
  Servers[ChannelId].Players[memberClientId].Party := @Servers[ChannelId]
    .Parties[Self.Index]; // aqui tbm
  Servers[ChannelId].Players[memberClientId].Base.PartyId := Self.Index;
  // mexi aqui
  Servers[ChannelId].Players[memberClientId].PartyIndex := Self.Index;
  Result := True;
  Self.RefreshParty;
end;

procedure TParty.RemoveMember(memberClientId: WORD);
begin
  try
    if (Self.Members.Contains(memberClientId)) then
    begin
      if (Self.Members.Count <= 2) then
      begin
        Self.DestroyParty(Self.Leader);
        Exit;
      end;
      Self.Members.Remove(memberClientId);
      Servers[ChannelId].Players[memberClientId].PartyIndex := 0;
      Servers[ChannelId].Players[memberClientId].RefreshParty;
      if (Self.Leader = memberClientId) then
      begin
        if (Assigned(Self.Members)) then
        begin
          if (Self.Members.Count < 2) then
          begin
            Self.DestroyParty(Self.Leader);
            Exit;
          end;
          Self.Leader := Self.Members.First;
        end;
      end;
    end;
    Self.RefreshParty;
  except
    Logger.Write('Erro no remove member partydata', TLogType.Error);
  end;
end;

procedure TParty.DestroyParty(ClientId: WORD);
var
  i, j: WORD;
begin
  if (ClientId = Self.Leader) then
  begin
    for i in Self.Members do
    begin
      Servers[ChannelId].Players[i].PartyIndex := 0;
      Servers[ChannelId].Players[i].Base.PartyId := 0;
      Servers[ChannelId].Players[i].RefreshParty;
    end;
    Self.Members.Clear;
    Self.MemberName.Clear;
    Self.InRaid := False;
    Self.IsRaidLeader := False;
    Self.RaidPartyId := 0;
    for i := 1 to 3 do
    begin
      if (Self.PartyAllied[i] = 0) then
        Continue;
      for j := 1 to 3 do
      begin
        if (Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].PartyAllied
          [j] = 0) then
          Continue;
        if (Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].PartyAllied[j]
          = Self.Index) then
          Servers[Self.ChannelId].Parties[Self.PartyAllied[i]]
            .PartyAllied[j] := 0;
      end;
      Dec(Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].PartyRaidCount);
      { if(Servers[Self.Channelid].Parties[Self.PartyAllied[i]].PartyRaidCount = 1) then
        begin
        Servers[Self.Channelid].Parties[Self.PartyAllied[i]].InRaid := False;
        Servers[Self.Channelid].Parties[Self.PartyAllied[i]].IsRaidLeader := True;
        Servers[Self.Channelid].Parties[Self.PartyAllied[i]].RefreshParty;
        end
        else
        begin }
      Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].RefreshRaid;
      // end;
    end;
    ZeroMemory(@Self.PartyAllied, sizeof(Self.PartyAllied));
    Self.PartyRaidCount := 0;
    // ZeroMemory(@Self, sizeof(TParty));
  end;
end;

function TParty.GetFreeRaidSpace(): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 1 to 3 do
  begin
    if (Self.PartyAllied[i] = 0) then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TParty.RefreshParty;
var
  i, j, k, m, n: WORD;
begin
  if not(Self.InRaid) then
  begin
    for i in Self.Members do
    begin
      Servers[ChannelId].Players[i].RefreshParty;
      for k in Self.Members do
      begin
        if (k = i) then
          Continue;
        Servers[ChannelId].Players[i].SendPositionParty(k);
      end;
    end;
  end
  else
  begin
    for i in Self.Members do
    begin // atualizar primeiro minha party
      Servers[ChannelId].Players[i].RefreshParty;
      for k in Self.Members do
      begin
        if (k = i) then
          Continue;
        Servers[ChannelId].Players[i].SendPositionParty(k);
      end;
    end;
    for j := 1 to 3 do
    begin // depois atualizar as outras 3 parties aliadas
      if (Self.PartyAllied[j] = 0) then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
      begin
        Servers[ChannelId].Players[i].RefreshParty;
        for k in Self.Members do
        begin
          if (k = i) then
            Continue;
          Servers[ChannelId].Players[i].SendPositionParty(k);
        end;
        for m := 1 to 3 do
        begin
          if (m = j) then
            Continue;

          if (Self.PartyAllied[m] = 0) then
            Continue;

          for n in Servers[Self.ChannelId].Parties[Self.PartyAllied[m]]
            .Members do
          begin
            Servers[ChannelId].Players[i].SendPositionParty(n);
          end;
        end;
      end;
    end;
  end;
end;

procedure TParty.RefreshRaid;
var
  i, j, k, m, n: WORD;
begin
  if (Self.InRaid) then
  begin
    for i in Self.Members do
    begin // atualizar primeiro minha party
      Servers[ChannelId].Players[i].RefreshParty;
      for k in Self.Members do
      begin
        if (k = i) then
          Continue;
        Servers[ChannelId].Players[i].SendPositionParty(k);
      end;
    end;
    for j := 1 to 3 do
    begin // depois atualizar as outras 3 parties aliadas
      if (Self.PartyAllied[j] = 0) then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
      begin
        Servers[ChannelId].Players[i].RefreshParty;
        for k in Self.Members do
        begin
          if (k = i) then
            Continue;
          Servers[ChannelId].Players[i].SendPositionParty(k);
        end;
        for m := 1 to 3 do
        begin
          if (m = j) then
            Continue;

          if (Self.PartyAllied[m] = 0) then
            Continue;

          for n in Servers[Self.ChannelId].Parties[Self.PartyAllied[m]]
            .Members do
          begin
            Servers[ChannelId].Players[i].SendPositionParty(n);
          end;
        end;
      end;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Class functions'}

class function TParty.CreateParty(ClientId: WORD; ChannelId: BYTE): Boolean;
var
  i: Integer;
  Party: PParty;
begin
  Result := False;
  for i := 1 to Length(Servers[ChannelId].Parties) do
    if (Servers[ChannelId].Parties[i].Members.Count = 0) then
    begin
      Party := @Servers[ChannelId].Parties[i];
      Party.Leader := ClientId;
      Party.Members.Add(ClientId);
      // Party.Index := i;
      Party.LastSlotItemReceived := 0;
      Party.ExpAlocate := 1;
      Party.ItemAlocate := 1;
      Party.IsRaidLeader := True;
      Party.RaidPartyId := 1;
      Party.InRaid := False;
      // Party.PartyRaidIDs[Party.RaidPartyId] := Party.Index;
      Party.PartyRaidCount := 1;
      Result := True;
      Servers[ChannelId].Players[ClientId].Party := @Servers[ChannelId].Parties
        [i]; // aqui tbm
      Servers[ChannelId].Players[ClientId].Base.PartyId := Party.Index;
      // mexi aqui
      Servers[ChannelId].Players[ClientId].PartyIndex := Party.Index;
      break;
    end;
end;

class function TParty.CreateRaid(RequesterID, AcceptID: WORD;
  ChannelId: BYTE): Boolean;
begin
  Result := False;
  // requester é a primeira pt, que se tornará lider da raid
  if (Servers[ChannelId].Players[RequesterID].PartyIndex = 0) then
    Exit;
  // accept aceitou o pedido de raid, e se tornará segunda party na raid
  if (Servers[ChannelId].Players[AcceptID].PartyIndex = 0) then
    Exit;
  if (Servers[ChannelId].Players[RequesterID].Party.InRaid) then
    Exit;
  if (Servers[ChannelId].Players[AcceptID].Party.InRaid) then
    Exit;
  Servers[ChannelId].Players[RequesterID].Party.InRaid := True;
  Servers[ChannelId].Players[AcceptID].Party.InRaid := True;
  Servers[ChannelId].Players[RequesterID].Party.IsRaidLeader := True;
  Servers[ChannelId].Players[AcceptID].Party.IsRaidLeader := False;
  Servers[ChannelId].Players[RequesterID].Party.RaidPartyId := 1;
  Servers[ChannelId].Players[AcceptID].Party.RaidPartyId := 2;
  Servers[ChannelId].Players[AcceptID].Party.ExpAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ExpAlocate;
  Servers[ChannelId].Players[AcceptID].Party.ItemAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ItemAlocate;
  Servers[ChannelId].Players[RequesterID].Party.PartyAllied[1] :=
    Servers[ChannelId].Players[AcceptID].Party.Index;
  Servers[ChannelId].Players[AcceptID].Party.PartyAllied[1] :=
    Servers[ChannelId].Players[RequesterID].Party.Index;
  Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount := 2;
  Servers[ChannelId].Players[AcceptID].Party.PartyRaidCount := 2;
  Servers[ChannelId].Players[RequesterID].Party.RefreshRaid;
  Result := True;
end;

class function TParty.AddPartyToRaid(RequesterID, AcceptID: WORD;
  ChannelId: BYTE): Boolean;
var
  FreeSlot, FreeSlot2, i, j: BYTE;
begin
  Result := False;
  if (Servers[ChannelId].Players[RequesterID].PartyIndex = 0) then
    Exit;
  if (Servers[ChannelId].Players[AcceptID].PartyIndex = 0) then
    Exit;
  if not(Servers[ChannelId].Players[RequesterID].Party.InRaid) then
    Exit;
  if (Servers[ChannelId].Players[AcceptID].Party.InRaid) then
    Exit;
  if (Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount >= 4) then
    Exit;
  FreeSlot := Servers[ChannelId].Players[RequesterID].Party.GetFreeRaidSpace;
  if (FreeSlot = 255) then
    Exit;
  Servers[ChannelId].Players[RequesterID].Party.PartyAllied[FreeSlot] :=
    Servers[ChannelId].Players[AcceptID].Party.Index;
  Servers[ChannelId].Players[AcceptID].Party.PartyAllied[1] :=
    Servers[ChannelId].Players[RequesterID].Party.Index;
  Inc(Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount);
  Servers[ChannelId].Players[AcceptID].Party.PartyRaidCount :=
    Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount;
  j := 2;
  for i := 1 to 3 do
  begin
    if (Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i] = 0) or
      (Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i] = Servers
      [ChannelId].Players[AcceptID].Party.Index) then
      Continue;
    Servers[ChannelId].Parties[Servers[ChannelId].Players[RequesterID]
      .Party.PartyAllied[i]].PartyRaidCount := Servers[ChannelId].Players
      [RequesterID].Party.PartyRaidCount;
    Servers[ChannelId].Players[AcceptID].Party.PartyAllied[j] :=
      Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i];
    Inc(j);
    FreeSlot2 := Servers[ChannelId].Parties
      [Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i]]
      .GetFreeRaidSpace;
    Servers[ChannelId].Parties[Servers[ChannelId].Players[RequesterID]
      .Party.PartyAllied[i]].PartyAllied[FreeSlot2] := Servers[ChannelId]
      .Players[AcceptID].Party.Index;
  end;
  Servers[ChannelId].Players[AcceptID].Party.InRaid := True;
  Servers[ChannelId].Players[AcceptID].Party.IsRaidLeader := False;
  Servers[ChannelId].Players[AcceptID].Party.RaidPartyId := FreeSlot;
  Servers[ChannelId].Players[AcceptID].Party.ExpAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ExpAlocate;
  Servers[ChannelId].Players[AcceptID].Party.ItemAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ItemAlocate;
  Servers[ChannelId].Players[RequesterID].Party.RefreshRaid;
  Result := True;
end;
{$ENDREGION}

procedure TParty.SendToParty(var Packet; size: WORD);
var
  i, j: WORD;
begin
  if not(Self.InRaid) then
  begin
    for i in Self.Members do
      Servers[ChannelId].Players[i].SendPacket(Packet, size);
  end
  else
  begin
    for i in Self.Members do
    begin // mandar primeiro minha party
      Servers[ChannelId].Players[i].SendPacket(Packet, size);
    end;
    for j := 1 to 3 do
    begin // depois mandar nas outras 3 parties aliadas
      if (Self.PartyAllied[j] = 0) then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
      begin
        Servers[ChannelId].Players[i].SendPacket(Packet, size);
      end;
    end;
  end;
end;

procedure TParty.SendToRaid(var Packet; size: WORD);
var
  i, j: WORD;
begin
  if (Self.InRaid) then
  begin
    for i in Self.Members do
    begin // mandar primeiro minha party
      Servers[ChannelId].Players[i].SendPacket(Packet, size);
    end;
    for j := 1 to 3 do
    begin // depois mandar nas outras 3 parties aliadas
      if (Self.PartyAllied[j] = 0) then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
      begin
        Servers[ChannelId].Players[i].SendPacket(Packet, size);
      end;
    end;
  end;
end;

end.
