unit ItemSkillFunctions;

interface

uses
  MiscData, Player, Windows, SysUtils, SQL;

type
  TItemSkillFunctions = class(TObject)
  public
    class procedure UseSkillItem(var Player: TPlayer; item: PItem);
  end;

implementation

uses
  GlobalDefs, Log, DateUtils, FilesData, Math, Util, SkillFunctions, PacketHandlers;

{$REGION 'Habilidades Ativas'}
class procedure TItemSkillFunctions.UseSkillItem(var Player: TPlayer; item: PItem);
var
  i: Integer;
  SkillList: array of Integer; // Array dinâmico para habilidades
  SkillLevel: Integer;
  barIndex: Integer;
  Query: string;
begin
  // Verifica o efeito de uso do item
  if ItemList[item.Index].UseEffect = 17280 then
  begin
    // Inicializa o SkillList baseado na classe do jogador
    case Player.Base.GetMobClass of
      0: // Guerreiro
        begin
          SetLength(SkillList, 2);
          SkillList[0] := 113;
          SkillList[1] := 129;
        end;
      1: // Templária
        begin
          SetLength(SkillList, 2);
          SkillList[0] := 3003; // Habilidade 1 de Templária
          SkillList[1] := 3004; // Habilidade 2 de Templária
        end;
      2: // Atirador
        begin
          SetLength(SkillList, 2);
          SkillList[0] := 3013; // Habilidade 1 de Atirador
          SkillList[1] := 3014; // Habilidade 2 de Atirador
        end;
      3: // Pistoleira
        begin
          SetLength(SkillList, 2);
          SkillList[0] := 2993; // Espinho Venenoso
          SkillList[1] := 3057; // Tiro Descontrolado
        end;
      4: // Feiticeiro
        begin
          SetLength(SkillList, 2);
          SkillList[0] := 3033; // Habilidade 1 de Feiticeiro
          SkillList[1] := 3034; // Habilidade 2 de Feiticeiro
        end;
      5: // Clérigo
        begin
          SetLength(SkillList, 2);
          SkillList[0] := 3043; // Habilidade 1 de Clérigo
          SkillList[1] := 3044; // Habilidade 2 de Clérigo
        end;
    end;

    // Verifica cada habilidade na lista
    for i := 0 to Length(SkillList) - 1 do
    begin
      // Inicializa SkillLevel
      SkillLevel := 0;

      // Consulta o nível da habilidade no banco de dados
      Query := Format('SELECT level FROM aika_db.skills WHERE owner_charid = %d AND skill_id = %d',
                      [Player.Character.Base.ClientId, SkillList[i]]);

      // Verifica se a habilidade está no nível 1
      if SkillLevel = 1 then
      begin
        // Aprende a habilidade e define o nível para 12
        TSkillFunctions.LearnSkillBook(Player, SkillList[i], 12);
        TSkillFunctions.UpdateAllOnBar(Player, SkillList[i], SkillList[i], barIndex); // Ajuste o ícone conforme necessário
        Player.SendClientMessage(Format('Você aprendeu a habilidade [%d] até o nível 12.', [SkillList[i]]));
        Exit; // Interrompe o loop após aprender a primeira habilidade
      end
      else
      begin
        // Se a habilidade não está no nível 1, avança para a próxima
        Player.SendClientMessage(Format('A habilidade [%d] não pode ser aprimorada, pois está no nível %d.', [SkillList[i], SkillLevel]));
      end;
    end;

    // Se nenhuma habilidade foi aprendida, significa que todas estão no nível superior a 1
    Player.SendClientMessage('Nenhuma habilidade pode ser aprimorada no momento.');
  end;
end;
{$ENDREGION}

end.
