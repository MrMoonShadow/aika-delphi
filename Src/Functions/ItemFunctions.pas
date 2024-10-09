unit ItemFunctions;

interface

uses MiscData, Player, BaseMob, Windows, PlayerData, SkillFunctions,
  ItemGoldFunctions, ItemBoxFunctions, ItemSkillFunctions;

type
  TItemFunctions = class(TObject)
  public
    { Item Amount }
    class function GetItemAmount(item: TItem): BYTE; static;
    class procedure SetItemAmount(var item: TItem; quant: WORD;
      Somar: Boolean = False); static;
    class procedure DecreaseAmount(item: PItem; Quanti: WORD = 1); overload;
    class procedure DecreaseAmount(var Player: TPlayer; Slot: BYTE;
      Quanti: WORD = 1); overload;
    class function AgroupItem(SrcItem, DestItem: PItem): Boolean;
    { Item Price }
    class function GetBuyItemPrice(item: TItem; var Price: TItemPrice;
      quant: WORD = 1): Boolean;
    { Item Propertys }
    class function CanAgroup(item: TItem): Boolean; overload;
    class function CanAgroup(item: TItem; Quanti: WORD): Integer; overload;
    { Put e Remove item }
    class function PutItem(var Player: TPlayer; item: TItem;
      StartSlot: BYTE = 0; Notice: Boolean = False): Integer; overload;
    class function PutItem(var Player: TPlayer; Index: WORD; quant: WORD = 1)
      : Integer; overload;
    class function PutEquipament(var Player: TPlayer; Index: Integer;
      Refine: Integer = 0): Integer;
    class function RemoveItem(var Player: TPlayer;
      const SlotType, Slot: Integer): Boolean;
    class function PutItemOnEvent(var Player: TPlayer; ItemIndex: WORD;
      ItemAmount: WORD = 1): Boolean;
    class function PutItemOnEventByCharIndex(var Player: TPlayer;
      CharIndex: Integer; ItemIndex: WORD): Boolean;
    { Item Duration }
    class function SetItemDuration(var item: TItem): Boolean;
    { Conjunt & Equip }
    class function GetItemEquipSlot(Index: Integer): Integer;
    class function GetItemEquipPranSlot(Index: Integer): Integer;
    class function GetConjuntCount(const BaseMB: TBaseMob;
      Index: Integer): Integer;
    class function GetItemBySlot(var Player: TPlayer; Slot: BYTE;
      out item: TItem): Boolean;
    class function GetClass(ClassInfo: Integer = 0): Integer;
    { Inventory Slots }
    class function GetInvPranMaxSlot(const Player: TPlayer): Integer;
    class function GetEmptySlot(const Player: TPlayer): BYTE; static;
    class function GetEmptyPranSlot(const Player: TPlayer): BYTE; static;
    class function VerifyItemSlot(var Player: TPlayer; Slot: Integer;
      const item: TItem): Boolean;
    class function VerifyBagSlot(const Player: TPlayer; Slot: Integer): Boolean;
    class function GetItemSlot(const Player: TPlayer; item: TItem;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE; static;
    class function GetItemSlot2(const Player: TPlayer; ItemID: WORD)
      : BYTE; static;
    class function GetItemSlotByItemType(const Player: TPlayer; ItemType: WORD;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
    class function GetItemSlotAndAmountByIndex(const Player: TPlayer;
      ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
    class function GetItemReliquareSlot(const Player: TPlayer): BYTE;
    class function GetItemThatExpires(const Player: TPlayer;
      SlotType: BYTE): BYTE;
    { Ramdom Select Functions }
    class function SelectRamdomItem(const Items: ARRAY OF WORD;
      const Chances: ARRAY OF WORD): WORD;
    { Reinforce }
    class function GetResultRefineItem(const item: WORD; Extract: WORD;
      Refine: BYTE): BYTE;
    class function GetItemReinforceChance(const item: WORD; Refine: BYTE): WORD;
    class function ReinforceItem(var Player: TPlayer; item: DWORD; Item2: DWORD;
      Item3: DWORD): BYTE;
    class function GetArmorReinforceIndex(const item: WORD): WORD;
    class function GetReinforceCust(const Index: WORD): Cardinal;
    class function GetItemReinforce2Index(ItemIndex: WORD): WORD;
    class function GetItemReinforce3Index(ItemIndex: WORD): WORD;
    { Enchant }
    class function Enchantable(item: TItem): Boolean;
    class function GetEmptyEnchant(item: TItem): BYTE;
    class function EnchantItem(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Change App }
    class function Changeable(item: TItem): Boolean;
    class function ChangeApp(var Player: TPlayer; item: DWORD; Athlon: DWORD;
      NewApp: DWORD): BYTE;
    { Mount Enchant }
    class function EnchantMount(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Premium Inventory Function }
    class function FindPremiumIndex(Index: WORD): WORD;
    { Use item }
    class function UsePremiumItem(var Player: TPlayer; Slot: Integer): Boolean;
    class function UseItem(var Player: TPlayer; Slot: Integer;
      Type1: DWORD = 0): Boolean;
    { Item Reinforce Stats }
    class function GetItemReinforceDamageReduction(Index: WORD;
      Refine: BYTE): WORD;
    class function GetItemReinforceHPMPInc(Index: WORD; Refine: BYTE): WORD;
    class function GetReinforceFromItem(const item: TItem): BYTE;
    { ItemDB Functions }
    class function UpdateMovedItems(var Player: TPlayer;
      SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
      SrcItem, DestItem: PItem): Boolean;
    { Recipe Functions }
    class function GetIDRecipeArray(RecipeItemID: WORD): WORD;
  end;

implementation

uses GlobalDefs, Log, SysUtils, DateUtils, FilesData, Math, Util, SQL,
  NPCHandlers;
{$REGION 'Item Amount'}

class function TItemFunctions.GetItemAmount(item: TItem): BYTE;
begin
  if ItemList[item.Index].CanAgroup then
  begin
    Result := item.Refi;
  end
  else
  begin
    Result := 1;
  end;
end;

class procedure TItemFunctions.SetItemAmount(var item: TItem; quant: WORD;
  Somar: Boolean = False);
begin
  if ItemList[item.Index].CanAgroup then
  begin
    if (Somar = True) then
    begin
      Inc(item.Refi, quant);
    end
    else
    begin
      item.Refi := quant;
    end;
  end
  else
  begin
    Exit;
  end;
end;

class procedure TItemFunctions.DecreaseAmount(item: PItem; Quanti: WORD = 1);
begin
  if (item.Refi - Quanti) > 0 then
  begin
    Dec(item.Refi, Quanti);
  end
  else
  begin
    ZeroMemory(item, sizeof(TItem));
  end;
end;

class procedure TItemFunctions.DecreaseAmount(var Player: TPlayer; Slot: BYTE;
  Quanti: WORD = 1);
var
  item: PItem;
begin
  item := @Player.Character.Base.Inventory[Slot];
  Self.DecreaseAmount(item, Quanti);
end;

class function TItemFunctions.AgroupItem(SrcItem: PItem;
  DestItem: PItem): Boolean;
var
  quant: WORD;
  Aux: TItem;
begin
  Result := False;
  if ItemList[SrcItem.Index].CanAgroup then
  begin
    if (SrcItem.Refi + DestItem.Refi) > MAX_SLOT_AMOUNT then
    begin
      if (SrcItem.Refi = 1000) or (DestItem.Refi = 1000) then
      begin
        Move(DestItem^, Aux, sizeof(TItem));
        Move(SrcItem^, DestItem^, sizeof(TItem));
        Move(Aux, SrcItem^, sizeof(TItem));
        Result := True;
        Exit;
      end;
      quant := (SrcItem.Refi + DestItem.Refi) - MAX_SLOT_AMOUNT;
      TItemFunctions.SetItemAmount(SrcItem^, MAX_SLOT_AMOUNT);
      TItemFunctions.SetItemAmount(DestItem^, quant);
    end
    else
    begin
      Inc(SrcItem^.Refi, DestItem^.Refi);
      ZeroMemory(DestItem, sizeof(TItem));
      Result := True;
      Exit;
    end;
  end
end;
{$ENDREGION}
{$REGION 'Item Price'}

class function TItemFunctions.GetBuyItemPrice(item: TItem;
  var Price: TItemPrice; quant: WORD = 1): Boolean;
begin
  if (ItemList[item.Index].TypePriceItem > 0) then
  begin
    Price.PriceType := PRICE_ITEM;
    Price.Value1 := ItemList[item.Index].TypePriceItem;
    Price.Value2 := ItemList[item.Index].TypePriceItemValue * quant;
    Result := True;
    Exit;
  end
  else if ((ItemList[item.Index].PriceHonor > 0) and
    (ItemList[item.Index].SellPrince = 0)) then
  begin
    Price.PriceType := PRICE_HONOR;
    Price.Value1 := ItemList[item.Index].PriceHonor * quant;
    Price.Value2 := ItemList[item.Index].PriceMedal * quant;
    Result := True;
    Exit;
  end
  else if (ItemList[item.Index].PriceMedal > 0) then
  begin
    Price.PriceType := PRICE_MEDAL;
    Price.Value1 := ItemList[item.Index].PriceMedal * quant;
    Price.Value2 := ItemList[item.Index].PriceGold * quant;
    Result := True;
    Exit;
  end
  else
  begin
    Price.PriceType := PRICE_GOLD;
    Price.Value1 := ItemList[item.Index].SellPrince * quant;
    Result := True;
    Exit;
  end;
end;
{$ENDREGION}
{$REGION 'Item Propertys'}

class function TItemFunctions.CanAgroup(item: TItem): Boolean;
begin
  if (ItemList[item.Index].CanAgroup) then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;

class function TItemFunctions.CanAgroup(item: TItem; Quanti: WORD): Integer;
begin
  if not(ItemList[item.Index].CanAgroup) then
  begin
    Result := ITEM_UNAGRUPABLE;
  end
  else if (item.Refi + Quanti > 1000) then
  begin
    Result := ITEM_QUANT_EXCEDE;
  end
  else
  begin
    Result := ITEM_AGRUPABLE;
  end;
end;
{$ENDREGION}
{$REGION 'Put & Remove Item'}

class function TItemFunctions.PutItem(var Player: TPlayer; item: TItem;
  StartSlot: BYTE = 0; Notice: Boolean = False): Integer;
var
  Slot, InInventory: BYTE;
  quant, i, j: WORD;
  ItemInv: TItem;
begin
  Slot := 0;
  Result := -1;
  InInventory := Self.GetItemSlot(Player, item, INV_TYPE, StartSlot);
  if (ItemList[item.Index].Expires) and not(ItemList[item.Index].CanSealed) then
  begin
    Self.SetItemDuration(item);
  end;
  if (ItemList[item.Index].CanSealed) then
  begin
    item.IsSealed := True;
  end;
  case InInventory of
    0 .. 128:
      begin
        case Self.CanAgroup(Player.Character.Base.Inventory[InInventory],
          item.Refi) of
          ITEM_UNAGRUPABLE:
            begin
              Slot := Self.GetEmptySlot(Player);
              if (Slot = 255) then
              begin
                Player.SendClientMessage('Inventário cheio!');
                Exit;
              end;
              if (item.Index = 5300) then
              begin
                if (Player.Character.Base.Inventory[61].Index = 0) then
                  Slot := 61
                else if (Player.Character.Base.Inventory[62].Index = 0) then
                  Slot := 62
                else
                  Exit;
              end;
              Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
                Player.Character.Base.Inventory[Slot], Notice);
            end;
          ITEM_QUANT_EXCEDE:
            begin
              Move(item, ItemInv, sizeof(TItem));
              quant := MAX_SLOT_AMOUNT - Player.Character.Base.Inventory
                [InInventory].Refi;
              if (quant > 0) then
              begin
                Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                  MAX_SLOT_AMOUNT);
                Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                  Player.Character.Base.Inventory[InInventory], Notice);
                Dec(ItemInv.Refi, quant);
                Result := Self.PutItem(Player, ItemInv, InInventory + 1);
              end
              else
              begin
                Result := Self.PutItem(Player, ItemInv, InInventory + 1);
              end;
            end;
          ITEM_AGRUPABLE:
            begin
              Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                item.Refi, True);
              Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                Player.Character.Base.Inventory[InInventory], Notice);
            end;
        end;
      end;
    255:
      begin
        Slot := Self.GetEmptySlot(Player);
        Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
          Player.Character.Base.Inventory[Slot], Notice);
        if (ItemList[Player.Character.Base.Inventory[Slot].Index].ItemType = 40)
        then
        begin
          for i := Low(Servers) to High(Servers) do
          begin
            Servers[i].SendServerMsgForNation
              ('O jogador <' + AnsiString(Player.Base.Character.Name) +
              '> adquiriu o tesouro sagrado [' +
              AnsiString(ItemList[Player.Character.Base.Inventory[Slot].Index]
              .Name) + '].'
              { '] do templo de ' +
                AnsiString(
                Servers[Player.Channelindex].DevirNpc[Player.OpennedTemple].
                PlayerChar.Base.PranName[0]) } ,
              Integer(Player.Account.Header.Nation), 16, 32, 16);
          end;
          Player.SendEffect(32);
        end;
      end;
  end;
  if (Result = -1) and (Slot <> 255) then
    Result := Slot;
end;

class function TItemFunctions.PutItem(var Player: TPlayer;
  Index, quant: WORD): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(item));
  item.Index := Index;
  item.APP := Index;
  item.Refi := quant;
  item.MIN := ItemList[item.Index].Durabilidade;
  item.MAX := item.MIN;
  Result := Self.PutItem(Player, item, 0, True)
end;

class function TItemFunctions.PutEquipament(var Player: TPlayer; Index: Integer;
  Refine: Integer = 0): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(TItem));
  item.Index := Index;
  item.APP := Index;
  item.MAX := ItemList[item.Index].Durabilidade;
  item.MIN := item.MAX;
  item.Refi := Refine;
  Result := Self.PutItem(Player, item, 0, True)
end;

class function TItemFunctions.RemoveItem(var Player: TPlayer;
  const SlotType, Slot: Integer): Boolean;
var
  item: PItem;
begin
  Result := False;
  item := Nil;
  case SlotType of
    INV_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 63) then
        begin
          item := @Player.Character.Base.Inventory[Slot];
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 83) then
        begin
          item := @Player.Account.Header.Storage.Itens[Slot];
        end
        else
          Exit;
      end;
    CASH_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 23) then
        begin
          item^ := Player.Account.Header.CashInventory.Items[Slot].ToItem;
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Slot >= 0) and (Slot <= 15) then
        begin
          item := @Player.Character.Base.Equip[Slot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if (Player.SpawnedPran = 255) then
          Exit;
        case Player.SpawnedPran of
          0:
            begin
              if (Slot >= 1) and (Slot <= 5) then
              begin
                item := @Player.Account.Header.Pran1.Equip[Slot];
              end
              else
                Exit;
            end;
          1:
            begin
              if (Slot >= 1) and (Slot <= 5) then
              begin
                item := @Player.Account.Header.Pran2.Equip[Slot];
              end
              else
                Exit;
            end;
        end;
      end;
    PRAN_INV_TYPE:
      begin
        if (Player.SpawnedPran = 255) then
          Exit;
        case Player.SpawnedPran of
          0:
            begin
              if (Slot >= 0) and (Slot <= 41) then
              begin
                item := @Player.Account.Header.Pran1.Inventory[Slot];
              end
              else
                Exit;
            end;
          1:
            begin
              if (Slot >= 0) and (Slot <= 41) then
              begin
                item := @Player.Account.Header.Pran2.Inventory[Slot];
              end
              else
                Exit;
            end;
        end;
      end;
  else
    begin
      Exit;
    end;
  end;
  if (item = Nil) then
    Exit;
  ZeroMemory(item, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(SlotType, Slot, item^, False);
  Result := True;
end;

class function TItemFunctions.PutItemOnEvent(var Player: TPlayer;
  ItemIndex: WORD; ItemAmount: WORD): Boolean;
var
  SQLComp: TQuery;
  charid: Integer;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[PutItemOnEvent]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEvent]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    if (Player.Base.Character.CharIndex = 0) then
      charid := Player.Account.Characters[0].Index
    else
      charid := Player.Base.Character.CharIndex;
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 0)', [EVENT_ITEM, charid, ItemIndex, ItemAmount]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;

class function TItemFunctions.PutItemOnEventByCharIndex(var Player: TPlayer;
  CharIndex: Integer; ItemIndex: WORD): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write
      ('Falha de conexão individual com mysql.[PutItemOnEventByCharIndex]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEventByCharIndex]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 0)', [EVENT_ITEM, CharIndex, ItemIndex, 1]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;
{$ENDREGION}
{$REGION 'Item Duration'}

class function TItemFunctions.SetItemDuration(var item: TItem): Boolean;
begin
  Result := True;
  if (ItemList[item.Index].Expires) then
  begin
    item.ExpireDate := IncHour(Now, ItemList[item.Index].Duration + 2);
  end
  else
  begin
    Result := False;
  end;
end;
{$ENDREGION}
{$REGION 'Conjunt & Equip'}

class function TItemFunctions.GetItemEquipSlot(Index: Integer): Integer;
begin
  Result := 0;
  if (ItemList[Index].ItemType = 50) or (ItemList[Index].ItemType = 52) then
  begin
    Result := 15;
  end;
  if (ItemList[Index].ItemType > 0) and (ItemList[Index].ItemType < 16) then
  begin
    Result := ItemList[Index].ItemType;
    Exit;
  end
  else if (ItemList[Index].ItemType > 1000) and (ItemList[Index].ItemType < 1011)
  then
  begin
    Result := 6;
    Exit;
  end;
end;

class function TItemFunctions.GetItemEquipPranSlot(Index: Integer): Integer;
begin
  Result := ItemList[Index].ItemType - 18;
end;

class function TItemFunctions.GetConjuntCount(const BaseMB: TBaseMob;
  Index: Integer): Integer;
var
  Count, Conjunt: Integer;
  i: Integer;
begin
  Conjunt := Conjuntos[Index];
  Count := 0;
  for i := 0 to 15 do
  begin
    if BaseMB.EQUIP_CONJUNT[i] = Conjunt then
      Inc(Count, 1);
  end;
  Result := Count;
end;

class function TItemFunctions.GetItemBySlot(var Player: TPlayer; Slot: BYTE;
  out item: TItem): Boolean;
begin
  Result := False;
  if (Slot > 63) then
    Exit;
  item := Player.Base.Character.Inventory[Slot];
  Result := True;
end;

class function TItemFunctions.GetClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
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
{$ENDREGION}
{$REGION 'Inventory Slots'}

class function TItemFunctions.VerifyItemSlot(var Player: TPlayer; Slot: Integer;
  const item: TItem): Boolean;
var
  OriginalItem: TItem;
begin
  ZeroMemory(@OriginalItem, sizeof(TItem));
  OriginalItem := Player.Character.Base.Inventory[Slot];
  Result := False;
  if not(CompareMem(@OriginalItem, @item, sizeof(TItem))) then
    Exit;
  Result := True;
end;

class function TItemFunctions.GetInvPranMaxSlot(const Player: TPlayer): Integer;
begin
  Result := 19;
  case Player.SpawnedPran of
    0:
      begin
        if (Player.Account.Header.Pran1.Inventory[41].Index > 0) then
          Result := 39;
      end;
    1:
      begin
        if (Player.Account.Header.Pran2.Inventory[41].Index > 0) then
          Result := 39;
      end;
  end;
end;

class function TItemFunctions.GetEmptySlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255;
  MAX_SLOT := Player.GetInventoryMaxSlots();
  for i := 0 to MAX_SLOT do
  begin
    if Player.Character.Base.Inventory[i].Index <> 0 then
      Continue;
    case i of
      0 .. 14:
        begin
          Result := i;
          Exit;
        end;
      15 .. 29:
        begin
          if (Player.Character.Base.Inventory[61].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      30 .. 44:
        begin
          if (Player.Character.Base.Inventory[62].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      45 .. 59:
        begin
          if (Player.Character.Base.Inventory[63].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
    end;
  end;
end;

class function TItemFunctions.GetEmptyPranSlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255;
  MAX_SLOT := GetInvPranMaxSlot(Player);
  case Player.SpawnedPran of
    0:
      begin
        for i := 0 to MAX_SLOT do
        begin
          if (Player.Account.Header.Pran1.Inventory[i].Index <> 0) then
            Continue;
          case i of
            0 .. 19:
              begin
                Result := i;
                Exit;
              end;
            20 .. 39:
              begin
                if (Player.Account.Header.Pran1.Inventory[41].Index <> 0) then
                begin
                  Result := i;
                  Exit;
                end;
              end;
          end;
        end;
      end;
    1:
      begin
        for i := 0 to MAX_SLOT do
        begin
          if (Player.Account.Header.Pran2.Inventory[i].Index <> 0) then
            Continue;
          case i of
            0 .. 19:
              begin
                Result := i;
                Exit;
              end;
            20 .. 39:
              begin
                if (Player.Account.Header.Pran2.Inventory[41].Index <> 0) then
                begin
                  Result := i;
                  Exit;
                end;
              end;
          end;
        end;
      end;
  end;
end;

class function TItemFunctions.VerifyBagSlot(const Player: TPlayer;
  Slot: Integer): Boolean;
begin
  Result := False;
  case Slot of
    0 .. 14:
      Result := True;
    15 .. 29:
      begin
        if (Player.Character.Base.Inventory[61].Index > 0) then
          Result := True;
      end;
    30 .. 44:
      if (Player.Character.Base.Inventory[62].Index > 0) then
        Result := True;
    45 .. 59:
      if (Player.Character.Base.Inventory[63].Index > 0) then
        Result := True;
  end;
end;

class function TItemFunctions.GetItemSlot(const Player: TPlayer; item: TItem;
  SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;
begin
  case SlotType of
    INV_TYPE:
      begin
        for i := StartSlot to 63 do
        begin
          if Player.Character.Base.Inventory[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    EQUIP_TYPE:
      begin
        for i := StartSlot to 15 do
        begin
          if Player.Character.Base.Equip[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    STORAGE_TYPE:
      begin
        for i := StartSlot to 85 do
        begin
          if Player.Account.Header.Storage.Itens[i].Index <> item.Index then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
  end;
  Result := 255;
end;

class function TItemFunctions.GetItemSlot2(const Player: TPlayer;
  ItemID: WORD): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 59 do // inventory
  begin
    if (Player.Character.Base.Inventory[i].Index = ItemID) then
    begin
      Result := i;
      Break;
    end
    else
    begin
      Continue;
    end;
  end;
end;

class function TItemFunctions.GetItemSlotByItemType(const Player: TPlayer;
  ItemType: WORD; SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;
begin
  case SlotType of
    INV_TYPE:
      begin
        for i := StartSlot to 63 do
        begin
          if ItemList[Player.Character.Base.Inventory[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    EQUIP_TYPE:
      begin
        for i := StartSlot to 15 do
        begin
          if ItemList[Player.Character.Base.Equip[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
    STORAGE_TYPE:
      begin
        for i := StartSlot to 85 do
        begin
          if ItemList[Player.Account.Header.Storage.Itens[i].Index].ItemType <> ItemType
          then
          begin
            Continue;
          end;
          Result := i;
          Exit;
        end;
      end;
  end;
  Result := 255;
end;

class function TItemFunctions.GetItemSlotAndAmountByIndex(const Player: TPlayer;
  ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
var
  i: WORD;
begin
  Result := False;
  for i := 0 to 59 do
  begin
    if (Player.Base.Character.Inventory[i].Index = ItemIndex) then
    begin
      Result := True;
      Slot := i;
      Refi := Player.Base.Character.Inventory[i].Refi;
      Break;
    end
    else
      Continue;
  end;
end;

class function TItemFunctions.GetItemReliquareSlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 59 do
  begin
    if (Player.Base.Character.Inventory[i].Index = 0) then
      Continue;
    if (ItemList[Player.Base.Character.Inventory[i].Index].ItemType = 40) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

class function TItemFunctions.GetItemThatExpires(const Player: TPlayer;
  SlotType: BYTE): BYTE;
var
  i: BYTE;
  item: PItem;
begin
  Result := 255;
  case SlotType of
    INV_TYPE:
      begin
        for i := 0 to 59 do
        begin
          item := @Player.Base.Character.Inventory[i];
          if (item.Index = 0) then
            Continue;
          if (ItemList[item.Index].Expires) then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        for i := 0 to 15 do
        begin
          item := @Player.Base.Character.Equip[i];
          if (item.Index = 0) then
            Continue;
          if (ItemList[item.Index].Expires) then
          begin
            Result := i;
            Break;
          end;
        end;
      end;
  end;
end;
{$ENDREGION}
{$REGION 'Ramdom Select Functions'}

class function TItemFunctions.SelectRamdomItem(const Items: ARRAY OF WORD;
  const Chances: ARRAY OF WORD): WORD;
var
  RandomTax, cnt: BYTE;
  RamdomArray: ARRAY OF WORD;
  i, j: Integer;
  RamdomSlot: Integer;
begin
  Result := 0;
  try
    Randomize;
    RandomTax := Random(100);
    cnt := 0;
    for i := 0 to Length(Items) - 1 do
    begin
      if (RandomTax <= Chances[i]) then
      begin
        SetLength(RamdomArray, cnt + 1);
        RamdomArray[cnt] := Items[i];
        Inc(cnt);
      end
      else
        Continue;
    end;
    if (Length(RamdomArray) = 0) then
    begin
      Randomize;
      RamdomSlot := RandomRange(0, Length(Items));
      Result := Items[RamdomSlot];
    end
    else
    begin
      Randomize;
      RamdomSlot := RandomRange(0, Length(RamdomArray));
      Result := RamdomArray[RamdomSlot];
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TlogType.Error);
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TlogType.Warnings);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Reinforce'}

class function TItemFunctions.GetResultRefineItem(const item: WORD;
  Extract: WORD; Refine: BYTE): BYTE;
var
  RamdomSlot: Integer;
  Chance: WORD;

begin
  // FillMemory(@RamdomArray, Length(RamdomArray), $3);
  { Pega a chance de refine }
  // Self.GetItemReinforceChance(item, Refine);
  // 0 volta -2
  // 1 volta -1
  // 2 sucesso
  case ItemList[item].Rank of
    0:
      begin
        Chance := ChancesOfRefinamentNormal[Refine]
      end;
    2, 3:
      begin
        Chance := ChancesOfRefinamentRaro[Refine]
      end;
    5:
      begin
        Chance := ChancesOfRefinamentSuperior[Refine]
      end;
  end;

  if (Random <= (Chance / 100)) then
  begin // deu bom
    Result := 2;
    Exit;
  end
  else
  begin
    case Refine of
      0 .. 3: // de +0 até +3
        begin // 100% de chance, impossivel voltar
          Result := 2;
          Exit;
        end;
      4 .. 5: // de +4 até +6
        begin
          if (Extract = 0) then
          begin
            Result := 1;
            Exit;
          end;
          case ItemList[Extract].ItemType of
            63, 65: // extrato normal
              begin
                Result := 1;
                Exit;
              end;
            64, 66: // extrato enriquecido
              begin
                Result := 3;
                Exit;
              end;
          end;
        end;
      6 .. 13: // de +7 até +11
        begin
          if (Extract = 0) then
          begin
            Result := 0;
            Exit;
          end;
          case ItemList[Extract].ItemType of
            63, 65: // extrato normal
              begin
                Result := 1;
                Exit;
              end;
            64, 66: // extrato enriquecido
              begin
                Result := 3;
                Exit;
              end;
          end;
        end;
    end;
  end;
end;

class function TItemFunctions.GetItemReinforceChance(const item: WORD;
  Refine: BYTE): WORD;
begin
  Result := 0;
  if (ItemList[item].UseEffect <= 0) then
    Exit;
  case Self.GetItemEquipSlot(item) of
    0 .. 5:
      begin
        Result := ReinforceA01[ItemList[item].UseEffect].Chance[Refine];
      end;
    6:
      begin
        Result := ReinforceW01[ItemList[item].UseEffect].Chance[Refine];
      end;
    7:
      begin
        Result := ReinforceA01[ItemList[item].UseEffect].Chance[Refine];
      end;
  else
    begin
      Result := 0;
    end;
  end;
end;

class function TItemFunctions.ReinforceItem(var Player: TPlayer; item: DWORD;
  Item2: DWORD; Item3: DWORD): BYTE;
var
  ItemIndex: Integer;
  HiraKaize: PItem;
  Extract: Integer;
  Refine: Integer;
begin
  Result := 4;
  ItemIndex := Player.Character.Base.Inventory[item].Index;
  HiraKaize := @Player.Character.Base.Inventory[Item2];
  if (Item3 = $FFFFFFFF) then
  begin
    Extract := 0;
  end
  else
  begin
    Extract := Player.Character.Base.Inventory[Item3].Index;
  end;
{$REGION 'Checagens Importantes'}
  if (ItemList[HiraKaize.Index].Rank < ItemList[ItemIndex].Rank) then
  begin
    Exit;
  end;
  if (Extract > 0) and (ItemList[Extract].Rank < ItemList[ItemIndex].Rank) then
  begin
    Exit;
  end;
  if (Self.GetReinforceCust(ItemIndex) > Player.Character.Base.Gold) then
  begin
    Result := 5;
    Exit;
  end;
  if (Player.Character.Base.Inventory[item].Refi >= 176) then
  begin
    Result := 6;
    Exit;
  end;
{$ENDREGION}
  if not(ItemList[ItemIndex].Fortification) then
  begin
    if not(HiraKaize.Refi > 0) then
    begin
      Exit;
    end;
    if (Extract > 0) then
    begin
      if (Player.Base.Character.Inventory[Item3].Refi > 0) then
      begin
        Self.DecreaseAmount(Player, Item3);
      end
      else
      begin
        Exit;
      end;
    end;
    Self.DecreaseAmount(HiraKaize);
    Dec(Player.Base.Character.Gold, Self.GetReinforceCust(ItemIndex));
    Result := Self.GetResultRefineItem(ItemIndex, Extract,
      Trunc(Player.Character.Base.Inventory[item].Refi / $10));
    case Result of
      0:
        begin
          ZeroMemory(@Player.Character.Base.Inventory[item], sizeof(TItem));
          // Dec(Player.Character.Base.Inventory[item].Refi, 32);
        end;
      1:
        begin
          Dec(Player.Character.Base.Inventory[item].Refi, $10);
        end;
      2:
        begin
          Inc(Player.Character.Base.Inventory[item].Refi, $10);
        end;
      3:
        begin
          // Player.SendClientMessage('Refinação falhou. O item não será destruido.');
          Exit;
        end;
    end;
  end
  else
  begin
    Player.SendClientMessage('Esse item não pode ser refinado.');
    Exit;
  end;
  if (Player.Character.Base.Inventory[item].Index = 0) then
  begin
    Player.Base.SendRefreshItemSlot(INV_TYPE, item,
      Player.Character.Base.Inventory[item], False);
  end
  else
  begin
    Refine := Round(Player.Character.Base.Inventory[item].Refi / 16);
    if (Result = 2) and (Refine >= 9) then
    begin
      Servers[Player.ChannelIndex].SendServerMsg
        (AnsiString(string(Player.Character.Base.Name) + ' refinou com sucesso '
        + string(ItemList[ItemIndex].Name) + ' +' + Refine.ToString), 16, 0, 0,
        False, Player.Base.ClientID);
    end;
  end;
end;

class function TItemFunctions.GetArmorReinforceIndex(const item: WORD): WORD;
  function GetRefineClass(Classe: BYTE): BYTE;
  begin
    Result := 6;
    case Classe of
      01 .. 10:
        Result := 1;
      11 .. 20:
        Result := 0;
      21 .. 30:
        Result := 2;
      31 .. 40:
        Result := 3;
      41 .. 50:
        Result := 4;
      51 .. 60:
        Result := 5;
    end;
  end;

var
  ItemType: WORD;
begin
  Result := 0;
  if not(ItemList[item].ItemType >= 2) and not(ItemList[item].ItemType <= 7)
  then
    Exit;
  ItemType := ItemList[item].ItemType;
  if (ItemType = 7) then
    ItemType := 6;
  Result := ((ItemType - 2) * 30) + ItemList[item].UseEffect;
end;

class function TItemFunctions.GetReinforceCust(const Index: WORD): Cardinal;
begin
  case Self.GetItemEquipSlot(Index) of
    2 .. 5:
      begin
        Result := ReinforceA01[ItemList[Index].UseEffect - 1].ReinforceCust;
      end;
    6:
      begin
        Result := ReinforceW01[ItemList[Index].UseEffect - 1].ReinforceCust;
      end;
    7:
      begin
        Result := ReinforceA01[ItemList[Index].UseEffect - 1].ReinforceCust;
      end;
  else
    begin
      Result := 0;
    end;
  end;
end;

class function TItemFunctions.GetItemReinforce2Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  ClassInfo: BYTE;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;
  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce2sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce2sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce2sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;
  ClassInfo := Self.GetClass(ItemList[ItemIndex].Classe);
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  if (EquipSlot = 6) then
  begin
    case ClassInfo of
      0:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Sword));
        end;
      1:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Blade));
        end;
      2:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Rifle));
        end;
      3:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Pistol));
        end;
      4:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Staff));
        end;
      5:
        begin
          Inc(ReinforceIndex, WORD(Reinforce2_Area_Wand));
        end;
    end;
    Result := (ReinforceIndex + ItemUseEffect);
    Exit;
  end;
  case EquipSlot of
    2:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Helmet) + (ClassInfo * 30)));
      end;
    3:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Armor) + (ClassInfo * 30)));
      end;
    4:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Gloves) + (ClassInfo * 30)));
      end;
    5:
      begin
        Inc(ReinforceIndex, (WORD(Reinforce2_Area_Shoes) + (ClassInfo * 30)));
      end;
    7:
      begin
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Shield));
      end;
  end;
  Result := (ReinforceIndex + ItemUseEffect);
end;

class function TItemFunctions.GetItemReinforce3Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;
  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce3sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce3sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce3sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  case (EquipSlot) of
    2:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Helmet));
    3:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Armor));
    4:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Gloves));
    5:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shoes));
    7:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shield));
  end;
  Result := (ReinforceIndex + ItemUseEffect);
end;
{$ENDREGION}
{$REGION 'Enchant'}

class function TItemFunctions.Enchantable(item: TItem): Boolean;
var
  i: BYTE;
begin
  Result := False;
  for i := 0 to 2 do
  begin
    if (item.Effects.Index[i] = 0) then
    begin
      Result := True;
      Break;
    end
    else
      Continue;
  end;
end;

class function TItemFunctions.GetEmptyEnchant(item: TItem): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 2 do
  begin
    if (item.Effects.Index[i] = 0) then
    begin
      Result := i;
      Break;
    end
    else
      Continue;
  end;
end;

class function TItemFunctions.EnchantItem(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
  ItemSlotType: Integer;
  R1, RandomEnch, OldRandomEnch: Integer;
  i: Integer;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) then
    Exit;
  if (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;
  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType = 508)
    then
    begin
      if (ItemList[Player.Base.Character.Inventory[Item2].Index].EF[0] = 0) then
      begin
        ItemSlotType := Self.GetItemEquipSlot(Player.Base.Character.Inventory
          [ItemSlot].Index);
        Randomize;
        RandomEnch := 0;
        case ItemSlotType of
          2 .. 5, 7:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Set));
                    RandomEnch := VaizanP_Set[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Set));
                    RandomEnch := VaizanM_Set[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Set));
                    RandomEnch := VaizanG_Set[R1];
                  end;
              end;
            end;
          6:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Wep));
                    RandomEnch := VaizanP_Wep[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Wep));
                    RandomEnch := VaizanM_Wep[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Wep));
                    RandomEnch := VaizanG_Wep[R1];
                  end;
              end;
            end;
          11 .. 14:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(VaizanP_Acc));
                    RandomEnch := VaizanP_Acc[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(VaizanM_Acc));
                    RandomEnch := VaizanM_Acc[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(VaizanG_Acc));
                    RandomEnch := VaizanG_Acc[R1];
                  end;
              end;
            end;
          23:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  begin
                    R1 := RandomRange(0, Length(Crystal_Damage));
                    RandomEnch := Crystal_Damage[R1];
                  end;
                5321:
                  begin
                    R1 := RandomRange(0, Length(Crystal_Defense));
                    RandomEnch := Crystal_Defense[R1];
                  end;
                5322:
                  begin
                    R1 := RandomRange(0, Length(Crystal_Soul));
                    RandomEnch := Crystal_Soul[R1];
                  end;
              end;
            end;
        end;
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;
        for i := 0 to 2 do
        begin
          if (Player.Character.Base.Inventory[ItemSlot].Effects.
            Index[i] = ItemList[RandomEnch].EF[0]) then
          begin
            OldRandomEnch := RandomEnch;
            case ItemSlotType of
              2 .. 5, 7:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Set));
                        RandomEnch := VaizanP_Set[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanP_Set[R1 - 1]
                          else
                            RandomEnch := VaizanP_Set[R1 + 1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Set));
                        RandomEnch := VaizanM_Set[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanM_Set[R1 - 1]
                          else
                            RandomEnch := VaizanM_Set[R1 + 1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Set));
                        RandomEnch := VaizanG_Set[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanG_Set[R1 - 1]
                          else
                            RandomEnch := VaizanG_Set[R1 + 1];
                        end;
                      end;
                  end;
                end;
              6:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Wep));
                        RandomEnch := VaizanP_Wep[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanP_Wep[R1 - 1]
                          else
                            RandomEnch := VaizanP_Wep[R1 + 1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Wep));
                        RandomEnch := VaizanM_Wep[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanM_Wep[R1 - 1]
                          else
                            RandomEnch := VaizanM_Wep[R1 + 1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Wep));
                        RandomEnch := VaizanG_Wep[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanG_Wep[R1 - 1]
                          else
                            RandomEnch := VaizanG_Wep[R1 + 1];
                        end;
                      end;
                  end;
                end;
              11 .. 14:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(VaizanP_Acc));
                        RandomEnch := VaizanP_Acc[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanP_Acc[R1 - 1]
                          else
                            RandomEnch := VaizanP_Acc[R1 + 1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(VaizanM_Acc));
                        RandomEnch := VaizanM_Acc[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanM_Acc[R1 - 1]
                          else
                            RandomEnch := VaizanM_Acc[R1 + 1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(VaizanG_Acc));
                        RandomEnch := VaizanG_Acc[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := VaizanG_Acc[R1 - 1]
                          else
                            RandomEnch := VaizanG_Acc[R1 + 1];
                        end;
                      end;
                  end;
                end;
              23:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      begin
                        R1 := RandomRange(0, Length(Crystal_Damage));
                        RandomEnch := Crystal_Damage[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := Crystal_Damage[R1 - 1]
                          else
                            RandomEnch := Crystal_Damage[R1 + 1];
                        end;
                      end;
                    5321:
                      begin
                        R1 := RandomRange(0, Length(Crystal_Defense));
                        RandomEnch := Crystal_Defense[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := Crystal_Defense[R1 - 1]
                          else
                            RandomEnch := Crystal_Defense[R1 + 1];
                        end;
                      end;
                    5322:
                      begin
                        R1 := RandomRange(0, Length(Crystal_Soul));
                        RandomEnch := Crystal_Soul[R1];
                        if (RandomEnch = OldRandomEnch) then
                        begin
                          if (R1 > 0) then
                            RandomEnch := Crystal_Soul[R1 - 1]
                          else
                            RandomEnch := Crystal_Soul[R1 + 1];
                        end;
                      end;
                  end;
                end;
            end;
            // Result := 4; // SendPlayerMessage
            // Exit;
          end;
        end;
        EnchantIndex := ItemList[RandomEnch].EF[0];
        EnchantValue := ItemList[RandomEnch].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          (EnchantValue);
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end
      else
      begin
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;
        for i := 0 to 2 do
        begin
          if (Player.Character.Base.Inventory[ItemSlot].Effects.
            Index[i] = ItemList[Player.Base.Character.Inventory[Item2].Index]
            .EF[0]) then
          begin
            if not(ItemList[Player.Base.Character.Inventory[Item2].Index]
              .ItemType = 33) then // pular se for estrela da pran
            begin
              Result := 3; // SendPlayerMessage
              Exit;
            end;
          end;
        end;
        EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EF[0];
        EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          EnchantValue;
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end;
      Result := 2;
      Exit;
    end;
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;
    var
    ItemType := ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType;
    case ItemType of
      509: // arma
        begin // 6 arma
          if not(Player.Character.Base.Inventory[ItemSlot].GetEquipType() = 0)
          then
          begin
            Player.SendClientMessage
              ('Vai usar hacker na puta que te pariu, se eu ver essa merda no log, vai tomar ban');
            Player.Base.WalkTo(TPosition.Create(416, 144), 70, MOVE_TELEPORT);
            Player.Base.SendCurrentHPMP();
            Exit;
          end;
        end;
      510: // armadura
        begin
          if not(Player.Character.Base.Inventory[ItemSlot].GetEquipType() = 1)
          then
          begin
            Player.SendClientMessage
              ('Vai usar hacker na puta que te pariu, se eu ver essa merda no log, vai tomar ban');
            Player.Base.WalkTo(TPosition.Create(416, 144), 70, MOVE_TELEPORT);
            Player.Base.SendCurrentHPMP();
            Exit;
          end;
        end;
      511: // manto/pet
        begin // 8 manto
          if not(ItemList[Player.Character.Base.Inventory[ItemSlot].Index]
            .ItemType = 8) then
          begin
            Player.SendClientMessage
              ('Vai usar hacker na puta que te pariu, se eu ver essa merda no log, vai tomar ban');
            Player.Base.WalkTo(TPosition.Create(416, 144), 70, MOVE_TELEPORT);
            Player.Base.SendCurrentHPMP();
            Exit;
          end;
        end;
      512: // acessorio
        begin // 11 12 13 14 - acessorio
          if not(Player.Character.Base.Inventory[ItemSlot].GetEquipType() = 2)
          then
          begin
            Player.SendClientMessage
              ('Vai usar hacker na puta que te pariu, se eu ver essa merda no log, vai tomar ban');
            Player.Base.WalkTo(TPosition.Create(416, 144), 70, MOVE_TELEPORT);
            Player.Base.SendCurrentHPMP();
            Exit;
          end;
        end;
      518: // montaria
        begin // 9 montaria
          if not(ItemList[Player.Character.Base.Inventory[ItemSlot].Index]
            .ItemType = 9) then
          begin
            Player.SendClientMessage
              ('Vai usar hacker na puta que te pariu, se eu ver essa merda no log, vai tomar ban');
            Player.Base.WalkTo(TPosition.Create(416, 144), 70, MOVE_TELEPORT);
            Player.Base.SendCurrentHPMP();
            Exit;
          end;
        end;
    end;
    for i := 0 to 2 do
    begin
      if (Player.Character.Base.Inventory[ItemSlot].Effects.
        Index[i] = ItemList[Player.Base.Character.Inventory[Item2].Index].EF[0])
      then
      begin
        if not(ItemList[Player.Base.Character.Inventory[Item2].Index]
          .ItemType = 33) then // pular se for estrela da pran
        begin
          Result := 3; // SendPlayerMessage
          Exit;
        end;
      end;
    end;
    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end;
  Result := 2;
end;
{$ENDREGION}
{$REGION 'Change APP'}

class function TItemFunctions.Changeable(item: TItem): Boolean;
begin
  Result := False;
  if (item.APP = 0) or (item.Index = item.APP) then
  begin
    Result := True;
  end;
end;

class function TItemFunctions.ChangeApp(var Player: TPlayer;
  item, Athlon, NewApp: DWORD): BYTE;
var
  MItem, MAthlon, MNewApp: TItem;
begin
  Result := 0;
  MItem := Player.Character.Base.Inventory[item];
  MAthlon := Player.Character.Base.Inventory[Athlon];
  MNewApp := Player.Character.Base.Inventory[NewApp];
  if (MItem.Index = 0) then
    Exit;
  if (MAthlon.Index = 0) then
    Exit;
  if (MNewApp.Index = 0) then
    Exit;
  if not(Player.Base.GetMobClass(ItemList[MNewApp.Index].Classe)
    = Player.Base.GetMobClass(ItemList[MItem.Index].Classe)) then
  begin
    Result := 1;
    Exit;
  end;
  if (ItemList[MItem.Index].CanAgroup) then
  begin
    Result := 1;
    Exit;
  end;
  if (ItemList[MNewApp.Index].CanAgroup) then
  begin
    Result := 1;
    Exit;
  end;
  if (Self.Changeable(MItem)) then
  begin
    Player.Character.Base.Inventory[item].APP := Player.Character.Base.Inventory
      [NewApp].Index;
    ZeroMemory(@Player.Character.Base.Inventory[NewApp], sizeof(TItem));
    Self.DecreaseAmount(@Player.Character.Base.Inventory
      [Self.GetItemSlot2(Player, MAthlon.Index)]);
    Player.Base.SendRefreshItemSlot(Self.GetItemSlot2(Player,
      MAthlon.Index), False);
    Result := 2;
  end;
end;
{$ENDREGION}
{$REGION 'Enchant Mount'}

class function TItemFunctions.EnchantMount(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
type
  TSpecialRefi = record
    hi, lo: BYTE;
  end;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) then
    Exit;
  if (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;
  if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType <> 518)
  then
  begin
    Exit;
  end;
  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;
    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    { case EmptyEnchant of
      0:
      begin
      Player.Character.Base.Inventory[ItemSlot].Effects.Index[0] :=
      EnchantIndex;
      Player.Character.Base.Inventory[ItemSlot].MIN :=
      EnchantValue;
      end;
      1:
      begin
      Player.Character.Base.Inventory[ItemSlot].Effects.Index[2] :=
      EnchantIndex;
      Player.Character.Base.Inventory[ItemSlot].MAX :=
      EnchantValue;
      end;
      2:
      begin
      Refi1.lo := EnchantValue;
      Player.Character.Base.Inventory[ItemSlot].Effects.Value[1] :=
      EnchantIndex;
      Move(Refi1, Player.Character.Base.Inventory[ItemSlot].Refi, 2);
      end;
      end; }
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end
  else
  begin
    Result := 1;
    Exit;
  end;
  Result := 2;
end;
{$ENDREGION}
{$REGION 'Premium Inventory Function'}

class function TItemFunctions.FindPremiumIndex(Index: WORD): WORD;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(PremiumItems) - 1 do
  begin
    if (PremiumItems[i].Index = Index) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Use Item'}

class function TItemFunctions.UsePremiumItem(var Player: TPlayer;
  Slot: Integer): Boolean;
var
  item: TItem;
  Premium: PItemCash;
  AddExp: UInt64;
begin
  if (Player.GetInventoryMaxSlots() = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  Premium := @Player.Account.Header.CashInventory.Items[Slot];
  ZeroMemory(@item, sizeof(TItem));
  item.Index := PremiumItems[Premium.Index].ItemIndex;
  Self.SetItemAmount(item, PremiumItems[Premium.Index].Amount);
  if (ItemList[item.Index].Expires) then
  begin
    Self.SetItemAmount(item, 0);
  end;
  Self.PutItem(Player, item, 0, True);
  ZeroMemory(@item, sizeof(TItem));
  ZeroMemory(Premium, sizeof(TItemCash));
  Player.Base.SendRefreshItemSlot(CASH_TYPE, Slot, item, False);
  Result := (Premium.Index = 0);
end;

class function TItemFunctions.UseItem(var Player: TPlayer; Slot: Integer;
  Type1: DWORD): Boolean;
var
  item, SecondItem: PItem;
  i: Integer;
  BagSlot: Integer;
  Decrease: Cardinal;
  RecipeIndex, RandomTax, EmptySlot: WORD;
  ItemSlot, ItemAmount: BYTE;
  ItemExists, HaveAmount: Boolean;
  Level, ReliqSlot: WORD;
  LevelExp: UInt64;
  AddExp: UInt64;
  Rand: Integer;
  PosX: TPosition;
begin
  item := @Player.Character.Base.Inventory[Slot];
  Result := False;
  Decrease := 1;
  if Player.Character.Base.Level < ItemList[item.Index].Level then
    Exit;
  case ItemList[item.Index].ItemType of
    ITEM_TYPE_USE_GOLD_COIN, ITEM_TYPE_USE_CASH_COIN,
      ITEM_TYPE_USE_RICH_GOLD_COIN, ITEM_TYPE_ALTARCOIN, ITEM_TYPE_GOLDCOIN,
      ITEM_TYPE_GOLDCOIN2:
      begin
        TItemGoldFunctions.UseGoldItem(Player, item);
      end;
    ITEM_TYPE_BAU:
      begin
        TItemBoxFunctions.UseBoxItem(Player, item);
        TItemSkillFunctions.UseSkillItem(Player, item);
      end;
{$REGION 'Poções em Geral'}
{$REGION 'Poção Mista'}
    ITEM_TYPE_HPMP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
        Player.SendClientMessage(format('Seu HP e MP foi recuperado em %d.',
          [ItemList[item.Index].UseEffect]));
      end;
    ITEM_TYPE_HPMP_LAGRIMAS:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
        Player.SendClientMessage(format('Seu HP e MP foi recuperado em %d.',
          [ItemList[item.Index].UseEffect]));
      end;
{$ENDREGION}
{$REGION 'Poção de HP'}
    ITEM_TYPE_HP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurHP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
        Player.SendClientMessage(format('Seu HP foi recuperado em %d.',
          [ItemList[item.Index].UseEffect]));
      end;
{$ENDREGION}
{$REGION 'Poção de MP'}
    ITEM_TYPE_MP_POTION:
      begin
        Inc(Player.Character.Base.CurrentScore.CurMP,
          ItemList[item.Index].UseEffect);
        Player.Base.SendCurrentHPMP(True);
        Player.SendClientMessage(format('Seu MP foi recuperado em %d.',
          [ItemList[item.Index].UseEffect]));
      end;
{$ENDREGION}
{$REGION 'Poções de Buff'}
    ITEM_TYPE_POTION_BUFF:
      begin
        if (Copy(String(ItemList[item.Index].Name), 0, 4) = 'Sopa') then
        begin
          if not(Player.Base.BuffExistsSopa) then
          begin
            Player.Base.AddBuff(ItemList[item.Index].UseEffect);
            Self.DecreaseAmount(item, Decrease);
            Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
            Result := True;
            Exit;
          end
          else
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[item.Index].UseEffect].Name
              + '].'));
            Exit;
          end;
        end;
        if (SkillData[ItemList[item.Index].UseEffect].Index = 251) then
        begin
          if (Player.Base.BuffExistsByIndex(251)) then
          begin
            Player.SendClientMessage('Não é combinável com [' +
              AnsiString(SkillData[ItemList[item.Index].UseEffect].Name
              + '].'));
            Exit;
          end;
        end;
        case SkillData[ItemList[item.Index].UseEffect].Index of
          298:
            begin
              if (Player.Base.BuffExistsByIndex(176)) then
                Exit;
            end;
          493: // poção valor de batalha
            begin
              if (Player.Base.BuffExistsInArray([494, 495, 496, 497])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;
          494: // poção valor de batalha
            begin
              if (Player.Base.BuffExistsInArray([493, 495, 496, 497])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;
          495: // poção valor de batalha
            begin
              if (Player.Base.BuffExistsInArray([494, 493, 496, 497])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;
          496: // poção valor de batalha
            begin
              if (Player.Base.BuffExistsInArray([494, 495, 493, 497])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;
          497: // poção valor de batalha
            begin // poção de batalha pvp
              if (Player.Base.BuffExistsInArray([494, 495, 496, 493])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;
        end;
        Player.Base.AddBuff(ItemList[item.Index].UseEffect);
      end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Comida de pran'}
    ITEM_TYPE_PRAN_FOOD:
      begin
        if (Player.SpawnedPran = 0) then
        begin
          if (Player.Account.Header.Pran1.Food >= 121) then
          begin
            Player.Account.Header.Pran1.Food := 121;
            Player.SendClientMessage('Sua pran não consegue comer mais.');
            Exit;
          end;
          case item.Index of // setar a personalidade
            8105: // sopa de batata doce (cute)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Cute, 2);
                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;
            8106: // perfait de cereja (sexy)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Sexy, 2);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;
            8107: // salada de caviar (smart)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Smart, 2);
                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;
            8108: // espetinho de camarao (energetic)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Energetic, 2);
                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;
            8109: // churrasco de york (tough)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Tough, 2);
                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
              end;
            8110: // peixe duvidoso assado (corrupt)
              begin
                Inc(Player.Account.Header.Pran1.Personality.Corrupt, 2);
                DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
              end;
          end;
          case item.Index of
            8105 .. 8110:
              begin
                if not(Player.Account.Header.Pran1.Devotion >= 226) then
                  Player.Account.Header.Pran1.Devotion :=
                    Player.Account.Header.Pran1.Devotion + 1;
              end;
          end;
          if (Player.Account.Header.Pran1.MovedToCentral = True) then
            Player.Account.Header.Pran1.MovedToCentral := False;
          if ((Player.Account.Header.Pran1.Food + 15) > 121) then
            Player.Account.Header.Pran1.Food := 121
          else
            Inc(Player.Account.Header.Pran1.Food, 15);
          Player.SendPranToWorld(0);
        end
        else if (Player.SpawnedPran = 1) then
        begin
          if (Player.Account.Header.Pran2.Food >= 121) then
          begin
            Player.Account.Header.Pran2.Food := 121;
            Player.SendClientMessage('Sua pran não consegue comer mais.');
            Exit;
          end;
          case item.Index of // setar a personalidade
            8105: // sopa de batata doce (cute)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Cute, 2);
                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;
            8106: // perfait de cereja (sexy)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Sexy, 2);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;
            8107: // salada de caviar (smart)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Smart, 2);
                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;
            8108: // espetinho de camarao (energetic)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Energetic, 2);
                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;
            8109: // churrasco de york (tough)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Tough, 2);
                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
              end;
            8110: // peixe duvidoso assado (corrupt)
              begin
                Inc(Player.Account.Header.Pran2.Personality.Corrupt, 2);
                DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
              end;
          end;
          if (Player.Account.Header.Pran2.MovedToCentral = True) then
            Player.Account.Header.Pran2.MovedToCentral := False;
          case item.Index of
            8105 .. 8110:
              begin
                if not(Player.Account.Header.Pran2.Devotion >= 226) then
                  Player.Account.Header.Pran2.Devotion :=
                    Player.Account.Header.Pran2.Devotion + 1;
              end;
          end;
          if ((Player.Account.Header.Pran2.Food + 15) > 121) then
            Player.Account.Header.Pran2.Food := 121
          else
            Inc(Player.Account.Header.Pran2.Food, 15);
          Player.SendPranToWorld(1);
        end
        else
          Exit;
      end;
    ITEM_TYPE_PRAN_DIGEST:
      begin // Digestivo da pran
        if (Player.Account.Header.Pran1.IsSpawned) then
        begin
          if (Player.Account.Header.Pran1.Food <= 13) then
          begin
            Player.SendClientMessage
              ('Sua pran está com muita fome para usar o Digestivo.');
            Exit;
          end;
          Player.Account.Header.Pran1.Food :=
            Player.Account.Header.Pran1.Food div 2;
          Player.SendPranToWorld(0);
        end
        else if (Player.Account.Header.Pran2.IsSpawned) then
        begin
          if (Player.Account.Header.Pran2.Food <= 13) then
          begin
            Player.SendClientMessage
              ('Sua pran está com muita fome para usar o Digestivo.');
            Exit;
          end;
          Player.Account.Header.Pran2.Food :=
            Player.Account.Header.Pran2.Food div 2;
          Player.SendPranToWorld(1);
        end;
      end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Utilidades'}
{$REGION 'Símbolo do Viajante'}
    ITEM_TYPE_BAG_INV:
      begin
        Self.SetItemDuration(item^);
        Move(item^, Player.Character.Base.Inventory[63], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, 63, item^, False);
        Player.SendClientMessage('Selo de [' +
          AnsiString(ItemList[item.Index].Name) + '] foi removido.');
        ZeroMemory(item, sizeof(TItem));
      end;
{$ENDREGION}
{$REGION 'Símbolo da Determinação'}
    ITEM_TYPE_BAG_STORAGE:
      begin
        BagSlot := 0;
        for i := 1 to 3 do
        begin
          if (Player.Account.Header.Storage.Itens[80 + i].Index = 0) then
          begin
            BagSlot := 80 + i;
          end;
        end;
        if (BagSlot = 0) then
        begin
          Player.SendClientMessage('Limite de expansão atingido.');
          Exit;
        end;
        Self.SetItemDuration(item^);
        Move(item^, Player.Account.Header.Storage.Itens[BagSlot],
          sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, BagSlot, item^, False);
        Player.SendClientMessage('Selo de [' +
          AnsiString(ItemList[item.Index].Name) + '] foi removido.');
        ZeroMemory(item, sizeof(TItem));
      end;
{$ENDREGION}
{$REGION 'Simbolo do Testamento (Bolsa Pran)'}
    ITEM_TYPE_BAG_PRAN:
      begin
        case Player.SpawnedPran of
          0:
            begin
              if (Player.Account.Header.Pran1.Inventory[41].Index <> 0) then
              begin
                Player.SendClientMessage
                  ('Você já possui duas bolsas nessa pran.');
                Exit;
              end;
              BagSlot := 41;
              Self.SetItemDuration(item^);
              Move(item^, Player.Account.Header.Pran1.Inventory[BagSlot],
                sizeof(TItem));
              // Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Player.Base.SendRefreshItemSlot(PRAN_INV_TYPE, BagSlot,
                Player.Account.Header.Pran1.Inventory[BagSlot], False);
              Player.SendClientMessage
                ('Selo de [' + AnsiString(ItemList[item.Index].Name) +
                '] foi removido.');
              ZeroMemory(item, sizeof(TItem));
            end;
          1:
            begin
              if (Player.Account.Header.Pran2.Inventory[41].Index <> 0) then
              begin
                Player.SendClientMessage
                  ('Você já possui duas bolsas nessa pran.');
                Exit;
              end;
              BagSlot := 41;
              Self.SetItemDuration(item^);
              Move(item^, Player.Account.Header.Pran2.Inventory[BagSlot],
                sizeof(TItem));
              // Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Player.Base.SendRefreshItemSlot(PRAN_INV_TYPE, BagSlot,
                Player.Account.Header.Pran2.Inventory[BagSlot], False);
              Player.SendClientMessage
                ('Selo de [' + AnsiString(ItemList[item.Index].Name) +
                '] foi removido.');
              ZeroMemory(item, sizeof(TItem));
            end;
        else
          Exit;
        end;
      end;
{$ENDREGION}
{$REGION 'Símbolo da Confiança'}
    ITEM_TYPE_STORAGE_OPEN:
      begin
        Player.OpennedOption := 7;
        Player.OpennedNPC := Player.Base.ClientID;
        Player.SendStorage(STORAGE_TYPE_PLAYER);
      end;
{$ENDREGION}
{$REGION 'Símbolo do vendedor'}
    ITEM_TYPE_SHOP_OPEN:
      begin
        Player.OpennedOption := 5;
        Player.OpennedNPC := 2070;
        TNPChandlers.ShowShop(Player, Servers[Player.ChannelIndex].NPCS[2070]);
      end;
{$ENDREGION}
{$REGION 'Onyx'}
    ITEM_TYPE_ADD_EXP_PERC:
      begin
        Player.AddExpPerc(ItemList[item.Index].UseEffect * 1);
        AddExp := LevelExp - UInt64(Player.Character.Base.Exp);
        Player.Base.SendRefreshLevel;
        Player.SendClientMessage('Você recebeu ' + IntToStr(AddExp) +
          ' experiência');
      end;
    ITEM_TYPE_USE_TO_UP_LVL:
      begin
        case ItemList[item.Index].UseEffect of
          1:
            begin
              Level := ItemList[item.Index].UseEffect * 1;
              try
                LevelExp := ExpList[Player.Character.Base.Level +
                  (Level - 1)] + 1;
              except
                LevelExp := High(ExpList);
              end;
              AddExp := LevelExp - UInt64(Player.Character.Base.Exp);
              Player.Base.SendRefreshLevel;
            end;
        else
          begin
            Player.AddLevel(ItemList[item.Index].UseEffect);
            Player.SendClientMessage('Você recebeu ' + IntToStr(AddExp) +
              ' experiência');
          end;
        end;
      end;
{$ENDREGION}
{$REGION 'Pergaminho do portal'}
    ITEM_TYPE_SCROLL_PORTAL:
      begin
        if (Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage
            ('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;
        try
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot <> 255) then
          begin
            Player.SendClientMessage('Impossível usar com relíquia.');
            Exit;
          end;
          if (Player.Base.Character.Nation > 0) then
          begin
            if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
              .NationID) then
            begin
              Player.SendClientMessage
                ('Impossível usar este item no canal desejado.');
              Exit;
            end;
          end;
          PosX := TPosition.Create(ScrollTeleportPosition[Type1].PosX,
            ScrollTeleportPosition[Type1].PosY);
          if (PosX.IsValid) then
            Player.Teleport(PosX)
          else
          begin
            PosX := TPosition.Create(3450, 690);
            Player.Teleport(PosX);
          end;
        except
          on E: Exception do
          begin
            Player.Teleport(Player.Base.PlayerCharacter.LastPos);
            Logger.Write('erro ao se teleportar. ' + E.Message, TlogType.Error);
            Exit;
          end;
        end;
      end;
{$ENDREGION}
{$REGION 'Pergaminho VIP'}
   ITEM_TYPE_SCROLL_VIP:
begin

  if (Player.Base.InClastleVerus) then
  begin
    Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
    Exit;
  end;

  ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
  if (ReliqSlot <> 255) then
  begin
    Player.SendClientMessage('Impossível usar com relíquia.');
    Exit;
  end;

  if (Player.Base.Character.Nation = 0) then
  begin
      Player.SendClientMessage('Você precisa ser cidadão.');
      Exit;
  end;

  if (Player.Base.Character.Nation > 0) then
  begin
    if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex].NationID) then
    begin
      Player.SendClientMessage('Impossível usar este item no canal desejado.');
      Exit;
    end;
  end;

  // Teleporta o jogador para a posição VIP
  Player.SendPlayerToVipPosition();
end;
{$ENDREGION}
{$REGION 'Pergaminho:Regenshein'}
    ITEM_TYPE_CITY_SCROLL:
      begin
        if (Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage
            ('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;
        if (Player.Base.Character.Nation > 0) then
        begin
          if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
            .NationID) then
          begin
            Player.SendClientMessage
              ('Impossível usar este item no canal desejado.');
            Exit;
          end;
        end;
        Player.SendPlayerToCityPosition();
      end;
{$ENDREGION}
{$REGION 'Pergaminho:CidadeSalva'}
    ITEM_TYPE_LOC_SCROLL:
      begin
        if (Player.Base.InClastleVerus) then
        begin
          Player.SendClientMessage
            ('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Impossível usar com relíquia.');
          Exit;
        end;
        if (Player.Base.Character.Nation > 0) then
        begin
          if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex]
            .NationID) then
          begin
            Player.SendClientMessage
              ('Impossível usar este item no canal desejado.');
            Exit;
          end;
        end;
        Player.SendPlayerToSavedPosition();
      end;
{$ENDREGION}
{$REGION 'Símbolo de cidadania'}
    ITEM_TYPE_SET_ACCOUNT_NATION:
      begin
        case ItemList[item.Index].UseEffect of
          99:
            begin
              if Player.Account.Header.Nation > TCitizenship.None then
                Exit;
              Player.Character.Base.Nation := ServerList[Player.ChannelIndex]
                .NationIndex;
              Player.Account.Header.Nation :=
                TCitizenship(ServerList[Player.ChannelIndex].NationIndex);
              Player.RefreshPlayerInfos;
              Player.AddTitle(18, 1);
              // Player.SocketClosed := True;
            end;
        end;
      end;
{$ENDREGION}
{$ENDREGION}
{$REGION 'Receitas'}
    ITEM_TYPE_RECIPE:
      begin
        RecipeIndex := Self.GetIDRecipeArray(item.Index);
        if (RecipeIndex = 3000) then
        begin
          Player.SendClientMessage('A receita não existe no banco de dados.');
          Exit;
        end;
        if (Recipes[RecipeIndex].LevelMin > Player.Base.Character.Level) then
        begin
          Player.SendClientMessage('Level mínimo da receita é ' +
            AnsiString(Recipes[RecipeIndex].LevelMin.ToString) + '.');
          Exit;
        end;
        ItemExists := True;
        HaveAmount := True;
        for i := 0 to 11 do
        begin
          if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
            Continue;
          if (Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
            Recipes[RecipeIndex].ItemIDRequired[i] := 4204;
          if not(Self.GetItemSlotAndAmountByIndex(Player,
            Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount)) then
          begin
            ItemExists := False;
            Player.SendClientMessage('Você não possui [' +
              AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
              .Name) + '].');
            Break;
          end
          else
          begin
            if (ItemAmount < Recipes[RecipeIndex].ItemRequiredAmount[i]) then
            begin
              HaveAmount := False;
              Player.SendClientMessage('Você precisa de ' +
                AnsiString(Recipes[RecipeIndex].ItemRequiredAmount[i].ToString)
                + ' do item [' +
                AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
                .Name) + ']. Separe a quantidade correta em apenas UM slot.');
              Break;
            end;
          end;
        end;
        if (not(ItemExists) or not(HaveAmount)) then
        begin
          Exit;
        end;
        EmptySlot := GetEmptySlot(Player);
        if (EmptySlot = 255) then
        begin
          Player.SendClientMessage('Seu inventário está cheio.');
          Exit;
        end;
        Randomize;
        RandomTax := RandomRange(1,
          (Recipes[RecipeIndex].SuccessTax div 10) + 1);
        if (RandomTax <= (Recipes[RecipeIndex].SuccessTax div 10)) then
        begin // success
          Player.SendClientMessage('Receita bem sucedida.');
          Self.PutItem(Player, Recipes[RecipeIndex].Reward,
            Recipes[RecipeIndex].RewardAmount);
          for i := 0 to 11 do
          begin
            if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
              Continue;
            if (Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
              Recipes[RecipeIndex].ItemIDRequired[i] := 4204;
            if (Self.GetItemSlotAndAmountByIndex(Player,
              Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount))
            then
            begin
              SecondItem := @Player.Base.Character.Inventory[ItemSlot];
              if ((TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex]
                .ItemRequiredAmount[i]) >= 2) and
                (TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex]
                .ItemRequiredAmount[i]) <= 14)) then
              begin
                TItemFunctions.RemoveItem(Player, INV_TYPE, ItemSlot);
              end
              else
              begin
                Self.DecreaseAmount(SecondItem,
                  Recipes[RecipeIndex].ItemRequiredAmount[i]);
                Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
                  SecondItem^, False);
              end;
            end;
          end;
        end
        else // quebrar receita
        begin
          Player.SendClientMessage('Receita falhou e foi perdida.');
        end;
      end;
{$ENDREGION}
  else
    Exit;
  end;
  Self.DecreaseAmount(item, Decrease);
  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
  Result := True;
end;
{$REGION 'Item Reinforce Stats'}

class function TItemFunctions.GetItemReinforceDamageReduction(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].DamageReduction[Refine];
end;

class function TItemFunctions.GetItemReinforceHPMPInc(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].HealthIncrementPoints[Refine];
end;

class function TItemFunctions.GetReinforceFromItem(const item: TItem): BYTE;
begin
  Result := 0;
  if (item.Refi = 0) then
    Exit;
  Result := Round(item.Refi / 16);
end;
{$ENDREGION}
{$REGION 'ItemDB Functions'}

class function TItemFunctions.UpdateMovedItems(var Player: TPlayer;
  SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
  SrcItem, DestItem: PItem): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[UpdateMovedItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[UpdateMovedItems]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', SrcSlotType);
    SQLComp.AddParameter2('pslot', SrcItemSlot);
    // Player.PlayerSQL.AddParameter2('pid', SrcItem.Iddb);
    SQLComp.Run(False);
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', DestSlotType);
    SQLComp.AddParameter2('pslot', DestItemSlot);
    // Player.PlayerSQL.AddParameter2('pid', DestItem.Iddb);
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('Erro ao salvar os itens movidos acc[' +
        String(Player.Account.Header.Username) + '] items[' +
        String(ItemList[SrcItem.Index].Name) + ' -> ' +
        String(ItemList[DestItem.Index].Name) + '] slot [' +
        SrcItemSlot.ToString + ' -> ' + DestItemSlot.ToString + '] error [' +
        E.Message + '] time [' + DateTimeToStr(Now) + ']', TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Recipe Functions'}

class function TItemFunctions.GetIDRecipeArray(RecipeItemID: WORD): WORD;
var
  i: WORD;
begin
  Result := 3000;
  for i := Low(Recipes) to High(Recipes) do
  begin
    if (Recipes[i].ItemRecipeID = 0) then
      Continue;
    if (Recipes[i].ItemRecipeID = RecipeItemID) then
    begin
      Result := i;
      Break;
    end
    else
      Continue;
  end;
end;
{$ENDREGION}

end.unit ItemFunctions;
