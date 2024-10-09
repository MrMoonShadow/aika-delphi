unit ItemGoldFunctions;

interface

uses MiscData, Player, Windows;

type
  TItemGoldFunctions = class(TObject)
  public
    class procedure UseGoldItem(var Player: TPlayer; item: PItem);
  end;

implementation

uses GlobalDefs, Log, SysUtils, DateUtils, FilesData, Math, Util, SQL,
  NPCHandlers;

class procedure TItemGoldFunctions.UseGoldItem(var Player: TPlayer;
  item: PItem);
begin
  case ItemList[item.Index].ItemType of
    ITEM_TYPE_USE_GOLD_COIN:
      begin
        Player.AddGold((ItemList[item.Index].SellPrince));
        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].SellPrince.ToString() + '] em gold.');
      end;
    ITEM_TYPE_USE_CASH_COIN:
      begin
        Player.AddCash((ItemList[item.Index].UseEffect));
        Player.SendClientMessage('Você recebeu o valor de [' +
          ItemList[item.Index].UseEffect.ToString() + '] em cash.');
      end;
    ITEM_TYPE_USE_RICH_GOLD_COIN:
      begin
        Player.AddGold(1000000);
        Player.SendClientMessage
          ('Você recebeu o valor de [1.000.000] em gold.');
      end;
    ITEM_TYPE_ALTARCOIN: // Bolsa de Gold [Altar]
      begin
        var
        Chance := Random(100);
        var
          GoldAmount: Integer;

        if Chance < 39 then
          GoldAmount := 200000
        else if Chance < 69 then
          GoldAmount := 400000
        else if Chance < 90 then
          GoldAmount := 600000
        else if Chance < 99 then
          GoldAmount := 1000000
        else
          GoldAmount := 3000000;

        Player.AddGold(GoldAmount);
        Player.SendClientMessage('Você recebeu ' + IntToStr(GoldAmount) +
          ' de gold.');
      end;
    ITEM_TYPE_GOLDCOIN: // Bolsa de Gold
      begin
        var
        Chance := Random(100);
        var
          GoldAmount: Integer;

        if Chance < 70 then
          GoldAmount := RandomRange(1000, 7001)
        else if Chance < 90 then
          GoldAmount := RandomRange(7000, 15001)
        else
          GoldAmount := RandomRange(15000, 20001);

        Player.AddGold(GoldAmount);
        Player.SendClientMessage('Você recebeu ' + IntToStr(GoldAmount) +
          ' de gold.');
      end;
    ITEM_TYPE_GOLDCOIN2: // Bolsa de Gold (COMUM)
      begin
        var
        Chance := Random(100);
        var
          GoldAmount: Integer;

        if Chance < 90 then
          GoldAmount := RandomRange(1000, 5001)
        else if Chance < 98 then
          GoldAmount := RandomRange(5000, 8501)
        else
          GoldAmount := RandomRange(8500, 10001);

        Player.AddGold(GoldAmount);
        Player.SendClientMessage('Você recebeu ' + IntToStr(GoldAmount) +
          ' de gold.');
      end;
  end;
end;

end.unit ItemGoldFunctions;
