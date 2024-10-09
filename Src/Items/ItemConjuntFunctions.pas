unit ItemConjuntFunctions;

interface

uses
  MiscData, Windows, ItemGoldFunctions, ItemBoxFunctions, GlobalDefs, ItemFunctions,
  Log, SysUtils, DateUtils, FilesData, Math, Util, SQL, NPCHandlers, Player,
  BaseMob, PlayerData, SkillFunctions;

procedure CheckAndApplyBuffIfEquipped(Player: TPlayer);

implementation

{$REGION 'CONJUNTOS'}
procedure CheckAndApplyBuffIfEquipped(Player: TPlayer);
var
  randValue: Integer;
begin
  if (Player.Character.Base.Equip[11].Index = 13244) and
     (Player.Character.Base.Equip[12].Index = 13245) and
     (Player.Character.Base.Equip[13].Index = 13246) and
     (Player.Character.Base.Equip[14].Index = 13247) then
  begin
    randValue := Random(100) + 1;

    if randValue <= 10 then
    begin // Precisa aplicar esse buff abaixo com taxa de 10% de chance ao atacar.
      //Player.AddBuff(11936);
    end;
  end;
end;
{$ENDREGION}

end.
