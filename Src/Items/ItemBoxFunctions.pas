unit ItemBoxFunctions;

interface

uses MiscData, Player, Windows;

const
_MountBoxEvent = 966;

type
  TItemBoxFunctions = class(TObject)
  public
    class procedure UseBoxItem(var Player: TPlayer; item: PItem);
  end;

implementation

uses GlobalDefs, ItemFunctions, SkillFunctions, ItemSkillFunctions, Log, SysUtils, DateUtils, FilesData, Math, Util, SQL,
  NPCHandlers;

class procedure TItemBoxFunctions.UseBoxItem(var Player: TPlayer; item: PItem);
var RandomTax, i: WORD;
begin
  case ItemList[item.Index].UseEffect of
    _MountBoxEvent:
      begin
        if (Player.GetInventoryMaxSlots() < 2) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0:
            begin
              TItemFunctions.PutEquipament(Player, 362); // Montaria WAR
              TItemFunctions.PutItem(Player, 4496); // Sela de Montaria [Evento]
            end;
          1:
            begin
              if (Player.GetInventoryMaxSlots() < 2) then
              begin // tp tem o escudo a mais
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 363); // Montaria TP
              TItemFunctions.PutItem(Player, 4496); // Sela de Montaria [Evento]
            end;
          2:
            begin
              TItemFunctions.PutEquipament(Player, 364); // Montaria ATT
              TItemFunctions.PutItem(Player, 4496); // Sela de Montaria [Evento]
            end;
          3:
            begin
              TItemFunctions.PutEquipament(Player, 365); // Montaria DUAL
              TItemFunctions.PutItem(Player, 4496); // Sela de Montaria [Evento]
            end;
          4:
            begin
              TItemFunctions.PutEquipament(Player, 366); // Montaria FC
              TItemFunctions.PutItem(Player, 4496); // Sela de Montaria [Evento]
            end;
          5:
            begin
              TItemFunctions.PutEquipament(Player, 367); // Montaria CL
              TItemFunctions.PutItem(Player, 4496); // Sela de Montaria [Evento]
            end;
        end;
      end;
      971: // Baú Sortido de Sopa [Verband]
    begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4851, 4852, 4853], [33, 33, 34]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
  972: // Baú Sortido de Sopa [Ursula]
     begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4854, 4855, 4856], [33, 33, 34]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
  973: // Baú Sortido de Sopa [Amarkand]
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4857, 4858, 4859], [33, 33, 34]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
  974: // Baú Sortido de Sopa [Heckla]
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4860, 4861, 4862], [33, 33, 34]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
  975: // Baú Sortido de Sopa [Deserto]
     begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4863, 4864, 4865], [33, 33, 34]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
  976: // Baú Sortido de Sopa [Deserto]
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4866, 4867, 4868], [33, 33, 34]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
  977: // Baú Sortido de Sopa [Leopold]
    begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4869, 4870, 4871, 4875], [32, 32, 32, 4]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
978: // Baú Sortido de Sopa [Karena]
 begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4872, 4873, 4874, 4875], [32, 32, 32, 4]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    979:
    begin
        if (Player.GetInventoryMaxSlots() <= 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0:    // WR
            begin
              TItemFunctions.PutEquipament(Player, 4721, 1);
              TItemFunctions.PutEquipament(Player, 4722, 1);
              TItemFunctions.PutEquipament(Player, 4723, 1);
              TItemFunctions.PutEquipament(Player, 4724, 1);
              TItemFunctions.PutEquipament(Player, 4725, 1);
            end;
          1:      // TP
            begin
              if (Player.GetInventoryMaxSlots() <= 6) then
              begin // tp tem o escudo a mais
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 4715, 1);
              TItemFunctions.PutEquipament(Player, 4716, 1);
              TItemFunctions.PutEquipament(Player, 4717, 1);
              TItemFunctions.PutEquipament(Player, 4718, 1);
              TItemFunctions.PutEquipament(Player, 4719, 1);
              TItemFunctions.PutEquipament(Player, 4720, 1);
            end;
          2:     // ATT
            begin
              TItemFunctions.PutEquipament(Player, 4710, 1);
              TItemFunctions.PutEquipament(Player, 4711, 1);
              TItemFunctions.PutEquipament(Player, 4712, 1);
              TItemFunctions.PutEquipament(Player, 4713, 1);
              TItemFunctions.PutEquipament(Player, 4714, 1);
            end;
          3:   // DUAL
            begin
              TItemFunctions.PutEquipament(Player, 4736, 1);
              TItemFunctions.PutEquipament(Player, 4737, 1);
              TItemFunctions.PutEquipament(Player, 4738, 1);
              TItemFunctions.PutEquipament(Player, 4739, 1);
              TItemFunctions.PutEquipament(Player, 4740, 1);
            end;
          4:    // FC
            begin
              TItemFunctions.PutEquipament(Player, 4731, 1);
              TItemFunctions.PutEquipament(Player, 4732, 1);
              TItemFunctions.PutEquipament(Player, 4733, 1);
              TItemFunctions.PutEquipament(Player, 4734, 1);
              TItemFunctions.PutEquipament(Player, 4735, 1);
            end;
          5:   // CL
            begin
              TItemFunctions.PutEquipament(Player, 4726, 1);
              TItemFunctions.PutEquipament(Player, 4727, 1);
              TItemFunctions.PutEquipament(Player, 4728, 1);
              TItemFunctions.PutEquipament(Player, 4729, 1);
              TItemFunctions.PutEquipament(Player, 4730, 1);
            end;
        end;
      end;
      980:
    begin
        if (Player.GetInventoryMaxSlots() <= 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0:    // WR
            begin
              TItemFunctions.PutEquipament(Player, 4721, 1);
              TItemFunctions.PutEquipament(Player, 4722, 1);
              TItemFunctions.PutEquipament(Player, 4723, 1);
              TItemFunctions.PutEquipament(Player, 4724, 1);
              TItemFunctions.PutEquipament(Player, 4725, 1);
            end;
          1:      // TP
            begin
              if (Player.GetInventoryMaxSlots() <= 6) then
              begin // tp tem o escudo a mais
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 4715, 1);
              TItemFunctions.PutEquipament(Player, 4716, 1);
              TItemFunctions.PutEquipament(Player, 4717, 1);
              TItemFunctions.PutEquipament(Player, 4718, 1);
              TItemFunctions.PutEquipament(Player, 4719, 1);
              TItemFunctions.PutEquipament(Player, 4720, 1);
            end;
          2:     // ATT
            begin
              TItemFunctions.PutEquipament(Player, 4710, 1);
              TItemFunctions.PutEquipament(Player, 4711, 1);
              TItemFunctions.PutEquipament(Player, 4712, 1);
              TItemFunctions.PutEquipament(Player, 4713, 1);
              TItemFunctions.PutEquipament(Player, 4714, 1);
            end;
          3:   // DUAL
            begin
              TItemFunctions.PutEquipament(Player, 4736, 1);
              TItemFunctions.PutEquipament(Player, 4737, 1);
              TItemFunctions.PutEquipament(Player, 4738, 1);
              TItemFunctions.PutEquipament(Player, 4739, 1);
              TItemFunctions.PutEquipament(Player, 4740, 1);
            end;
          4:    // FC
            begin
              TItemFunctions.PutEquipament(Player, 4731, 1);
              TItemFunctions.PutEquipament(Player, 4732, 1);
              TItemFunctions.PutEquipament(Player, 4733, 1);
              TItemFunctions.PutEquipament(Player, 4734, 1);
              TItemFunctions.PutEquipament(Player, 4735, 1);
            end;
          5:   // CL
            begin
              TItemFunctions.PutEquipament(Player, 4726, 1);
              TItemFunctions.PutEquipament(Player, 4727, 1);
              TItemFunctions.PutEquipament(Player, 4728, 1);
              TItemFunctions.PutEquipament(Player, 4729, 1);
              TItemFunctions.PutEquipament(Player, 4730, 1);
            end;
        end;
      end;
    18000: // Elmo de Cristal - 18000
      begin
        if (Player.GetInventoryMaxSlots() < 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0:
            begin
              TItemFunctions.PutEquipament(Player, 3540, 1);
            end;
          1:
            begin
              if (Player.GetInventoryMaxSlots() < 1) then
              begin // tp tem o escudo a mais
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 3640, 1);
            end;
          2:
            begin
              TItemFunctions.PutEquipament(Player, 3740, 1);
            end;
          3:
            begin
              TItemFunctions.PutEquipament(Player, 3840, 1);
            end;
          4:
            begin
              TItemFunctions.PutEquipament(Player, 3940, 1);
            end;
          5:
            begin
              TItemFunctions.PutEquipament(Player, 4040, 1);
            end;
        end;
      end;
    18001: // Academia Vermelha
      begin
        if (Player.GetInventoryMaxSlots() < 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0: // war
            begin
              TItemFunctions.PutEquipament(Player, 12075);
              TItemFunctions.PutEquipament(Player, 12381);
              TItemFunctions.PutEquipament(Player, 12411);
              TItemFunctions.PutEquipament(Player, 12441);
              TItemFunctions.PutEquipament(Player, 12471);
            end;

          1: // tp
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              TItemFunctions.PutEquipament(Player, 12351);
              TItemFunctions.PutEquipament(Player, 12110);
              TItemFunctions.PutEquipament(Player, 12501);
              TItemFunctions.PutEquipament(Player, 12531);
              TItemFunctions.PutEquipament(Player, 12561);
              TItemFunctions.PutEquipament(Player, 12591);
            end;

          2: // att
            begin
              TItemFunctions.PutEquipament(Player, 12215);
              TItemFunctions.PutEquipament(Player, 12621);
              TItemFunctions.PutEquipament(Player, 12651);
              TItemFunctions.PutEquipament(Player, 12681);
              TItemFunctions.PutEquipament(Player, 12711);
            end;

          3: // dual
            begin
              TItemFunctions.PutEquipament(Player, 12250);
              TItemFunctions.PutEquipament(Player, 12741);
              TItemFunctions.PutEquipament(Player, 12771);
              TItemFunctions.PutEquipament(Player, 12801);
              TItemFunctions.PutEquipament(Player, 12831);
            end;

          4: // fc
            begin
              TItemFunctions.PutEquipament(Player, 12285);
              TItemFunctions.PutEquipament(Player, 12861);
              TItemFunctions.PutEquipament(Player, 12891);
              TItemFunctions.PutEquipament(Player, 12921);
              TItemFunctions.PutEquipament(Player, 12951);
            end;

          5: // cl
            begin
              TItemFunctions.PutEquipament(Player, 12320);
              TItemFunctions.PutEquipament(Player, 12981);
              TItemFunctions.PutEquipament(Player, 13011);
              TItemFunctions.PutEquipament(Player, 13041);
              TItemFunctions.PutEquipament(Player, 13071);
            end;
        end;
      end;
    18002: // Academia Azul
      begin
        if (Player.GetInventoryMaxSlots() < 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0: // war
            begin
              TItemFunctions.PutEquipament(Player, 12074);
              TItemFunctions.PutEquipament(Player, 12380);
              TItemFunctions.PutEquipament(Player, 12410);
              TItemFunctions.PutEquipament(Player, 12440);
              TItemFunctions.PutEquipament(Player, 12470);
            end;

          1: // tp
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              TItemFunctions.PutEquipament(Player, 12350);
              TItemFunctions.PutEquipament(Player, 12109);
              TItemFunctions.PutEquipament(Player, 12500);
              TItemFunctions.PutEquipament(Player, 12530);
              TItemFunctions.PutEquipament(Player, 12560);
              TItemFunctions.PutEquipament(Player, 12590);
            end;

          2: // att
            begin
              TItemFunctions.PutEquipament(Player, 12214);
              TItemFunctions.PutEquipament(Player, 12620);
              TItemFunctions.PutEquipament(Player, 12650);
              TItemFunctions.PutEquipament(Player, 12680);
              TItemFunctions.PutEquipament(Player, 12710);
            end;

          3: // dual
            begin
              TItemFunctions.PutEquipament(Player, 12249);
              TItemFunctions.PutEquipament(Player, 12740);
              TItemFunctions.PutEquipament(Player, 12770);
              TItemFunctions.PutEquipament(Player, 12800);
              TItemFunctions.PutEquipament(Player, 12830);
            end;

          4: // fc
            begin
              TItemFunctions.PutEquipament(Player, 12284);
              TItemFunctions.PutEquipament(Player, 12860);
              TItemFunctions.PutEquipament(Player, 12890);
              TItemFunctions.PutEquipament(Player, 12920);
              TItemFunctions.PutEquipament(Player, 12950);
            end;

          5: // cl
            begin
              TItemFunctions.PutEquipament(Player, 12319);
              TItemFunctions.PutEquipament(Player, 12980);
              TItemFunctions.PutEquipament(Player, 13010);
              TItemFunctions.PutEquipament(Player, 13040);
              TItemFunctions.PutEquipament(Player, 13070);
            end;
        end;
      end;
    18003: // Fundador
      begin
        if (Player.GetInventoryMaxSlots() < 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0: // war
            begin
              TItemFunctions.PutEquipament(Player, 1063); // Espada
              TItemFunctions.PutEquipament(Player, 1687); // Elmo
              TItemFunctions.PutEquipament(Player, 1717); // Armadura
              TItemFunctions.PutEquipament(Player, 1747); // Luva
              TItemFunctions.PutEquipament(Player, 1777); // Bota
            end;

          1: // tp
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              TItemFunctions.PutEquipament(Player, 1028); // Lâmina
              TItemFunctions.PutEquipament(Player, 1301); // Escudo
              TItemFunctions.PutEquipament(Player, 1807); // Elmo
              TItemFunctions.PutEquipament(Player, 1837); // Armadura
              TItemFunctions.PutEquipament(Player, 1867); // Luva
              TItemFunctions.PutEquipament(Player, 1897); // Bota
            end;

          2: // att
            begin
              TItemFunctions.PutEquipament(Player, 1203); // Rifle
              TItemFunctions.PutEquipament(Player, 1927); // Elmo
              TItemFunctions.PutEquipament(Player, 1957); // Armadura
              TItemFunctions.PutEquipament(Player, 1987); // Luva
              TItemFunctions.PutEquipament(Player, 2017); // Bota
            end;

          3: // dual
            begin
              TItemFunctions.PutEquipament(Player, 1168); // Pistola
              TItemFunctions.PutEquipament(Player, 2047); // Elmo
              TItemFunctions.PutEquipament(Player, 2077); // Armadura
              TItemFunctions.PutEquipament(Player, 2107); // Luva
              TItemFunctions.PutEquipament(Player, 2137); // Bota
            end;

          4: // fc
            begin
              TItemFunctions.PutEquipament(Player, 1273); // Cajado
              TItemFunctions.PutEquipament(Player, 2167); // Elmo
              TItemFunctions.PutEquipament(Player, 2197); // Armadura
              TItemFunctions.PutEquipament(Player, 2227); // Luva
              TItemFunctions.PutEquipament(Player, 2257); // Bota
            end;

          5: // cl
            begin
              TItemFunctions.PutEquipament(Player, 1238); // Cetro
              TItemFunctions.PutEquipament(Player, 2287); // Elmo
              TItemFunctions.PutEquipament(Player, 2317); // Armadura
              TItemFunctions.PutEquipament(Player, 2347); // Luva
              TItemFunctions.PutEquipament(Player, 2377); // Bota
            end;
        end;
      end;
      18004:
         begin
        if (Player.GetInventoryMaxSlots() < 4) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0: // war
            begin
              TItemFunctions.PutEquipament(Player, 1683); // Elmo
              TItemFunctions.PutEquipament(Player, 1713); // Armadura
              TItemFunctions.PutEquipament(Player, 1743); // Luva
              TItemFunctions.PutEquipament(Player, 1773); // Bota
            end;

          1: // tp
            begin
              if (Player.GetInventoryMaxSlots() < 5) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 1803); // Elmo
              TItemFunctions.PutEquipament(Player, 1833); // Armadura
              TItemFunctions.PutEquipament(Player, 1863); // Luva
              TItemFunctions.PutEquipament(Player, 1893); // Bota
            end;

          2: // att
            begin
              TItemFunctions.PutEquipament(Player, 1923); // Elmo
              TItemFunctions.PutEquipament(Player, 1953); // Armadura
              TItemFunctions.PutEquipament(Player, 1983); // Luva
              TItemFunctions.PutEquipament(Player, 2013); // Bota
            end;

          3: // dual
            begin
              TItemFunctions.PutEquipament(Player, 2043); // Elmo
              TItemFunctions.PutEquipament(Player, 2073); // Armadura
              TItemFunctions.PutEquipament(Player, 2103); // Luva
              TItemFunctions.PutEquipament(Player, 2133); // Bota
            end;

          4: // fc
            begin
              TItemFunctions.PutEquipament(Player, 2163); // Elmo
              TItemFunctions.PutEquipament(Player, 2193); // Armadura
              TItemFunctions.PutEquipament(Player, 2223); // Luva
              TItemFunctions.PutEquipament(Player, 2253); // Bota
            end;

          5: // cl
            begin
              TItemFunctions.PutEquipament(Player, 2283); // Elmo
              TItemFunctions.PutEquipament(Player, 2313); // Armadura
              TItemFunctions.PutEquipament(Player, 2343); // Luva
              TItemFunctions.PutEquipament(Player, 2373); // Bota
            end;
        end;
      end;
      18005:
           begin
        if (Player.GetInventoryMaxSlots() < 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        case Player.Base.GetMobClass of
          0: // war
            begin
              TItemFunctions.PutEquipament(Player, 1068); // Espada
            end;

          1: // tp
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 1033); // Lâmina
              TItemFunctions.PutEquipament(Player, 1308); // Escudo
            end;

          2: // att
            begin
              TItemFunctions.PutEquipament(Player, 1208); // Rifle
            end;

          3: // dual
            begin
              TItemFunctions.PutEquipament(Player, 1173); // Pistola
            end;

          4: // fc
            begin
              TItemFunctions.PutEquipament(Player, 1278); // Cajado
            end;

          5: // cl
            begin
              TItemFunctions.PutEquipament(Player, 1243); // Cetro
            end;
        end;
      end;
    18842:
      begin
        if Player.GetInventoryMaxSlots() < 7 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 18841); // Conjunto de Aparência academia
        TItemFunctions.PutItem(Player, 18840); // Conjunto de Acessório [15 dias]
        TItemFunctions.PutItem(Player, 18839); // Conjunto da Alteza  [30 dias]
        TItemFunctions.PutItem(Player, 16613); // Double Exp 3 dias
        TItemFunctions.PutItem(Player, 16608); // Gato Preto Roxo [7 dias]
        TItemFunctions.PutItem(Player, 7903); // Bolsa Extra [30 dias ]
        TItemFunctions.PutItem(Player, 16585); // Logo AIKA [7 dias]
        TItemFunctions.PutItem(Player, 4580, 6); // Athlon [6 Unidade]
        TItemFunctions.PutItem(Player, 14253); // Titulo Saudades Sumido
      end;
    18841:
      begin
        if (Player.GetInventoryMaxSlots() < 5) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;

        case Player.Base.GetMobClass of
          0: // war
            begin
              if Random(2) = 0 then
              begin
                TItemFunctions.PutEquipament(Player, 12075);
                TItemFunctions.PutEquipament(Player, 12381);
                TItemFunctions.PutEquipament(Player, 12411);
                TItemFunctions.PutEquipament(Player, 12441);
                TItemFunctions.PutEquipament(Player, 12471);
              end
              else
              begin
                TItemFunctions.PutEquipament(Player, 12074);
                TItemFunctions.PutEquipament(Player, 12380);
                TItemFunctions.PutEquipament(Player, 12410);
                TItemFunctions.PutEquipament(Player, 12440);
                TItemFunctions.PutEquipament(Player, 12470);
              end;
            end;

          1: // tp
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              if Random(2) = 0 then
              begin
                TItemFunctions.PutEquipament(Player, 12351);
                TItemFunctions.PutEquipament(Player, 12110);
                TItemFunctions.PutEquipament(Player, 12501);
                TItemFunctions.PutEquipament(Player, 12531);
                TItemFunctions.PutEquipament(Player, 12561);
                TItemFunctions.PutEquipament(Player, 12591);
              end
              else
              begin
                TItemFunctions.PutEquipament(Player, 12350);
                TItemFunctions.PutEquipament(Player, 12109);
                TItemFunctions.PutEquipament(Player, 12500);
                TItemFunctions.PutEquipament(Player, 12530);
                TItemFunctions.PutEquipament(Player, 12560);
                TItemFunctions.PutEquipament(Player, 12590);
              end;
            end;
          2: // att
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              if Random(2) = 0 then
              begin
                TItemFunctions.PutEquipament(Player, 12215);
                TItemFunctions.PutEquipament(Player, 12621);
                TItemFunctions.PutEquipament(Player, 12651);
                TItemFunctions.PutEquipament(Player, 12681);
                TItemFunctions.PutEquipament(Player, 12711);
              end
              else
              begin
                TItemFunctions.PutEquipament(Player, 12214);
                TItemFunctions.PutEquipament(Player, 12620);
                TItemFunctions.PutEquipament(Player, 12650);
                TItemFunctions.PutEquipament(Player, 12680);
                TItemFunctions.PutEquipament(Player, 12710);
              end;
            end;
          3: // dual
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              if Random(2) = 0 then
              begin
                TItemFunctions.PutEquipament(Player, 12250);
                TItemFunctions.PutEquipament(Player, 12741);
                TItemFunctions.PutEquipament(Player, 12771);
                TItemFunctions.PutEquipament(Player, 12801);
                TItemFunctions.PutEquipament(Player, 12831);
              end
              else
              begin
                TItemFunctions.PutEquipament(Player, 12249);
                TItemFunctions.PutEquipament(Player, 12740);
                TItemFunctions.PutEquipament(Player, 12770);
                TItemFunctions.PutEquipament(Player, 12800);
                TItemFunctions.PutEquipament(Player, 12830);
              end;
            end;
          4: // fc
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              if Random(2) = 0 then
              begin
                TItemFunctions.PutEquipament(Player, 12285);
                TItemFunctions.PutEquipament(Player, 12861);
                TItemFunctions.PutEquipament(Player, 12891);
                TItemFunctions.PutEquipament(Player, 12921);
                TItemFunctions.PutEquipament(Player, 12951);
              end
              else
              begin
                TItemFunctions.PutEquipament(Player, 12284);
                TItemFunctions.PutEquipament(Player, 12860);
                TItemFunctions.PutEquipament(Player, 12890);
                TItemFunctions.PutEquipament(Player, 12920);
                TItemFunctions.PutEquipament(Player, 12950);
              end;
            end;
          5: // cl
            begin
              if (Player.GetInventoryMaxSlots() < 6) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;

              if Random(2) = 0 then
              begin
                TItemFunctions.PutEquipament(Player, 12320);
                TItemFunctions.PutEquipament(Player, 12981);
                TItemFunctions.PutEquipament(Player, 13011);
                TItemFunctions.PutEquipament(Player, 13041);
                TItemFunctions.PutEquipament(Player, 13071);
              end
              else
              begin
                TItemFunctions.PutEquipament(Player, 12319);
                TItemFunctions.PutEquipament(Player, 12980);
                TItemFunctions.PutEquipament(Player, 13010);
                TItemFunctions.PutEquipament(Player, 13040);
                TItemFunctions.PutEquipament(Player, 13070);
              end;
            end;
        end;
      end;
    18839:
      begin
        case Player.Base.GetMobClass of
          0: // set war
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6727, 1);
              TItemFunctions.PutEquipament(Player, 6997, 1);
              TItemFunctions.PutEquipament(Player, 7027, 1);
              TItemFunctions.PutEquipament(Player, 7057, 1);
              TItemFunctions.PutEquipament(Player, 7087, 1);
            end;
          1: // set tp
            begin
              if Player.GetInventoryMaxSlots() < 6 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6692, 1);
              TItemFunctions.PutEquipament(Player, 1304, 1);
              TItemFunctions.PutEquipament(Player, 7117, 1);
              TItemFunctions.PutEquipament(Player, 7147, 1);
              TItemFunctions.PutEquipament(Player, 7177, 1);
              TItemFunctions.PutEquipament(Player, 7207, 1);
            end;
          2: // set att
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6867, 112);
              TItemFunctions.PutEquipament(Player, 7237, 112);
              TItemFunctions.PutEquipament(Player, 7267, 112);
              TItemFunctions.PutEquipament(Player, 7297, 112);
              TItemFunctions.PutEquipament(Player, 7327, 112);
            end;
          3: // set dual
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6832, 112);
              TItemFunctions.PutEquipament(Player, 7357, 112);
              TItemFunctions.PutEquipament(Player, 7387, 112);
              TItemFunctions.PutEquipament(Player, 7417, 112);
              TItemFunctions.PutEquipament(Player, 7447, 112);
            end;
          4: // set fc
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6937, 112);
              TItemFunctions.PutEquipament(Player, 7477, 112);
              TItemFunctions.PutEquipament(Player, 7507, 112);
              TItemFunctions.PutEquipament(Player, 7537, 112);
              TItemFunctions.PutEquipament(Player, 7567, 112);
            end;
          5: // set cl
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6902, 112);
              TItemFunctions.PutEquipament(Player, 7597, 112);
              TItemFunctions.PutEquipament(Player, 7627, 112);
              TItemFunctions.PutEquipament(Player, 7657, 112);
              TItemFunctions.PutEquipament(Player, 7687, 112);
            end;
        end;
      end;
    18840:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 1567);
        TItemFunctions.PutItem(Player, 1568);
        TItemFunctions.PutItem(Player, 1569);
        TItemFunctions.PutItem(Player, 1570);
      end;
    18838:
      begin
        case Player.Base.GetMobClass of
          0: // set war
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6727, 1);
              TItemFunctions.PutEquipament(Player, 6997, 1);
              TItemFunctions.PutEquipament(Player, 7027, 1);
              TItemFunctions.PutEquipament(Player, 7057, 1);
              TItemFunctions.PutEquipament(Player, 7087, 1);
            end;
          1: // set tp
            begin
              if Player.GetInventoryMaxSlots() < 6 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6692, 1);
              TItemFunctions.PutEquipament(Player, 1304, 1);
              TItemFunctions.PutEquipament(Player, 7117, 1);
              TItemFunctions.PutEquipament(Player, 7147, 1);
              TItemFunctions.PutEquipament(Player, 7177, 1);
              TItemFunctions.PutEquipament(Player, 7207, 1);
            end;
          2: // set att
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6867, 112);
              TItemFunctions.PutEquipament(Player, 7237, 112);
              TItemFunctions.PutEquipament(Player, 7267, 112);
              TItemFunctions.PutEquipament(Player, 7297, 112);
              TItemFunctions.PutEquipament(Player, 7327, 112);
            end;
          3: // set dual
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6832, 112);
              TItemFunctions.PutEquipament(Player, 7357, 112);
              TItemFunctions.PutEquipament(Player, 7387, 112);
              TItemFunctions.PutEquipament(Player, 7417, 112);
              TItemFunctions.PutEquipament(Player, 7447, 112);
            end;
          4: // set fc
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6937, 112);
              TItemFunctions.PutEquipament(Player, 7477, 112);
              TItemFunctions.PutEquipament(Player, 7507, 112);
              TItemFunctions.PutEquipament(Player, 7537, 112);
              TItemFunctions.PutEquipament(Player, 7567, 112);
            end;
          5: // set cl
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6902, 112);
              TItemFunctions.PutEquipament(Player, 7597, 112);
              TItemFunctions.PutEquipament(Player, 7627, 112);
              TItemFunctions.PutEquipament(Player, 7657, 112);
              TItemFunctions.PutEquipament(Player, 7687, 112);
            end;
        end;
      end;
    17040: // Caixa de Anel Lv50 - 17040
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([1335, 1575], [40, 60]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    17041: // Caixa de Brinco Lv50 - 17041
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([1363, 1576], [40, 60]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    17042: // Caixa de Bracelete Lv50 - 17042
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([1393, 1577], [40, 60]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    17043: // Caixa de Colar Lv50 - 17043
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([1418, 1578], [40, 60]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    1:
      begin
        case Player.Base.GetMobClass of
          0: // set war
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6727, 1);
              TItemFunctions.PutEquipament(Player, 6997, 1);
              TItemFunctions.PutEquipament(Player, 7027, 1);
              TItemFunctions.PutEquipament(Player, 7057, 1);
              TItemFunctions.PutEquipament(Player, 7087, 1);
            end;
          1: // set tp
            begin
              if Player.GetInventoryMaxSlots() < 6 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6692, 1);
              TItemFunctions.PutEquipament(Player, 1304, 1);
              TItemFunctions.PutEquipament(Player, 7117, 1);
              TItemFunctions.PutEquipament(Player, 7147, 1);
              TItemFunctions.PutEquipament(Player, 7177, 1);
              TItemFunctions.PutEquipament(Player, 7207, 1);
            end;
          2: // set att
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6867, 112);
              TItemFunctions.PutEquipament(Player, 7237, 112);
              TItemFunctions.PutEquipament(Player, 7267, 112);
              TItemFunctions.PutEquipament(Player, 7297, 112);
              TItemFunctions.PutEquipament(Player, 7327, 112);
            end;
          3: // set dual
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6832, 112);
              TItemFunctions.PutEquipament(Player, 7357, 112);
              TItemFunctions.PutEquipament(Player, 7387, 112);
              TItemFunctions.PutEquipament(Player, 7417, 112);
              TItemFunctions.PutEquipament(Player, 7447, 112);
            end;
          4: // set fc
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6937, 112);
              TItemFunctions.PutEquipament(Player, 7477, 112);
              TItemFunctions.PutEquipament(Player, 7507, 112);
              TItemFunctions.PutEquipament(Player, 7537, 112);
              TItemFunctions.PutEquipament(Player, 7567, 112);
            end;
          5: // set cl
            begin
              if Player.GetInventoryMaxSlots() < 5 then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutEquipament(Player, 6902, 112);
              TItemFunctions.PutEquipament(Player, 7597, 112);
              TItemFunctions.PutEquipament(Player, 7627, 112);
              TItemFunctions.PutEquipament(Player, 7657, 112);
              TItemFunctions.PutEquipament(Player, 7687, 112);
            end;
        end;
      end;
    357: // caixa do T diário 10467
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 4520, 5);
        TItemFunctions.PutItem(Player, 4521, 5);
        TItemFunctions.PutItem(Player, 8200, 5);
        TItemFunctions.PutItem(Player, 4358, 10);
        TItemFunctions.PutItem(Player, 4398, 10);
      end;
    666:
      begin
        case Player.Base.GetMobClass of
          0, 1, 4, 5:
            begin
              if (Player.GetInventoryMaxSlots() < 9) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
              TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
              TItemFunctions.PutItem(Player, 1611); // Anel de Velocidade 3Dias
              TItemFunctions.PutItem(Player, 15550, 50); // Poção de Vida Média
              TItemFunctions.PutItem(Player, 15551, 50); // Poção de Mana Média
              TItemFunctions.PutItem(Player, 966); // Caixa de Montaria [Evento]
              TItemFunctions.PutItem(Player, 8026); // Símbolo de Testamento
              TItemFunctions.PutItem(Player, 10045); // Baú do Level 10
              TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
            end;
          2:
            begin
              if (Player.GetInventoryMaxSlots() < 10) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
              TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
              TItemFunctions.PutItem(Player, 1611); // Anel de Velocidade 3Dias
              TItemFunctions.PutItem(Player, 15550, 50); // Poção de Vida Média
              TItemFunctions.PutItem(Player, 15551, 50); // Poção de Mana Média
              TItemFunctions.PutItem(Player, 966); // Caixa de Montaria [Evento]
              TItemFunctions.PutItem(Player, 8026); // Símbolo de Testamento
              TItemFunctions.PutItem(Player, 10045); // Baú do Level 10
              TItemFunctions.PutItem(Player, 7966); // Bala de Cash [Rifleman]
              TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
            end;
          3:
            begin
              if (Player.GetInventoryMaxSlots() < 10) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
              TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
              TItemFunctions.PutItem(Player, 1611); // Anel de Velocidade 3Dias
              TItemFunctions.PutItem(Player, 15550, 50); // Poção de Vida Média
              TItemFunctions.PutItem(Player, 15551, 50); // Poção de Mana Média
              TItemFunctions.PutItem(Player, 966); // Caixa de Montaria [Evento]
              TItemFunctions.PutItem(Player, 8026); // Símbolo de Testamento
              TItemFunctions.PutItem(Player, 10045); // Baú do Level 10
              TItemFunctions.PutItem(Player, 7936); // Bala de Cash [Dualgunner]
              TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
            end;
        end;
      end;
    667:
      begin
        if Player.GetInventoryMaxSlots() < 7 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
        TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
        TItemFunctions.PutItem(Player, 1613); // Brinco de Velocidade 3Dias
        TItemFunctions.PutItem(Player, 15550, 75); // Poção de Vida Média
        TItemFunctions.PutItem(Player, 15551, 75); // Poção de Mana Média
        TItemFunctions.PutItem(Player, 4438); // Símbolo de Cidadania
        TItemFunctions.PutItem(Player, 10046); // Baú do Level 20
      end;
    668:
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
        TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
        TItemFunctions.PutItem(Player, 1614); // Bracelete de Velocidade 3Dias
        TItemFunctions.PutItem(Player, 15550, 100); // Poção de Vida Média
        TItemFunctions.PutItem(Player, 15551, 100); // Poção de Mana Média
        TItemFunctions.PutItem(Player, 10047); // Baú do Level 30

      end;
    669:
      begin
        if Player.GetInventoryMaxSlots() < 7 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
        TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
        TItemFunctions.PutItem(Player, 1612); // Bracelete de Velocidade 3Dias
        TItemFunctions.PutItem(Player, 15550, 100); // Poção de Vida Média
        TItemFunctions.PutItem(Player, 15551, 100); // Poção de Mana Média
        TItemFunctions.PutItem(Player, 8045); // Símbolo da Confiança
        TItemFunctions.PutItem(Player, 10048); // Baú do Level 40
      end;
    670:
      begin
        if Player.GetInventoryMaxSlots() < 7 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 4322, 5); // Poção de Velocidade
        TItemFunctions.PutItem(Player, 8189, 20); // Perga portal Evento
        TItemFunctions.PutItem(Player, 15550, 100); // Poção de Vida Média
        TItemFunctions.PutItem(Player, 15551, 100); // Poção de Mana Média
        TItemFunctions.PutItem(Player, 8043); // Símbolo do Vendedor
        TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
        TItemFunctions.PutItem(Player, 10049); // Baú do Level 50
      end;
    671:
      begin
        case Player.Base.GetMobClass of
          0, 1, 4, 5:
            begin
              if (Player.GetInventoryMaxSlots() < 9) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 8199, 50); // Reparador de arma C
              TItemFunctions.PutItem(Player, 8253, 50); // Reparador de armadura C
              TItemFunctions.PutItem(Player, 4483); // Poção da Defesa
              TItemFunctions.PutItem(Player, 4487); // Poção da Destruição
              TItemFunctions.PutItem(Player, 8007);
              // Extrato Líquido 3 dias [Evento]
              TItemFunctions.PutItem(Player, 4442, 2);
              // Pergaminho de Experiência 1 hora
              TItemFunctions.PutItem(Player, 10050); // Baú do Level 60
              TItemFunctions.PutItem(Player, 15552, 250); // Poção de Vida Grande
              TItemFunctions.PutItem(Player, 15553, 250); // Poção de Mana Grande
            end;
          2:
            begin
              if (Player.GetInventoryMaxSlots() < 10) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 8199, 50); // Reparador de arma C
              TItemFunctions.PutItem(Player, 8253, 50); // Reparador de armadura C
              TItemFunctions.PutItem(Player, 4483); // Poção da Defesa
              TItemFunctions.PutItem(Player, 4487); // Poção da Destruição
              TItemFunctions.PutItem(Player, 8007);
              // Extrato Líquido 3 dias [Evento]
              TItemFunctions.PutItem(Player, 4442, 2);
              // Pergaminho de Experiência 1 hora
              TItemFunctions.PutItem(Player, 10050); // Baú do Level 60
              TItemFunctions.PutItem(Player, 7972); // Bala de Cash [Rifleman]
              TItemFunctions.PutItem(Player, 15552, 250); // Poção de Vida Grande
              TItemFunctions.PutItem(Player, 15553, 250); // Poção de Mana Grande
            end;
          3:
            begin
              if (Player.GetInventoryMaxSlots() < 10) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 8199, 50); // Reparador de arma C
              TItemFunctions.PutItem(Player, 8253, 50); // Reparador de armadura C
              TItemFunctions.PutItem(Player, 4483); // Poção da Defesa
              TItemFunctions.PutItem(Player, 4487); // Poção da Destruição
              TItemFunctions.PutItem(Player, 8007);
              // Extrato Líquido 3 dias [Evento]
              TItemFunctions.PutItem(Player, 4442, 2);
              // Pergaminho de Experiência 1 hora
              TItemFunctions.PutItem(Player, 10050); // Baú do Level 60
              TItemFunctions.PutItem(Player, 7942); // Bala de Cash [Dualgunner]
              TItemFunctions.PutItem(Player, 15552, 250); // Poção de Vida Grande
              TItemFunctions.PutItem(Player, 15553, 250); // Poção de Mana Grande
            end;
        end;
      end;
    672:
      begin
        case Player.Base.GetMobClass of
          0, 1, 4, 5:
            begin
              if (Player.GetInventoryMaxSlots() < 11) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 8189, 50); // Perga portal Evento
              TItemFunctions.PutItem(Player, 8007);
              // Extrato Líquido 3 dias [Evento]
              TItemFunctions.PutItem(Player, 15549);
              // Buquê de Rosas Vermelhas 3 Dias
              TItemFunctions.PutItem(Player, 10051, 1); // Bau do Level 70
              TItemFunctions.PutItem(Player, 8026); // Símbolo de Testamento
              TItemFunctions.PutItem(Player, 966); // Caixa de Montaria [Evento]
              TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
              TItemFunctions.PutItem(Player, 8045); // Símbolo da Confiança
              TItemFunctions.PutItem(Player, 8043); // Símbolo do Vendedor
              TItemFunctions.PutItem(Player, 15552, 500); // Poção de Vida Grande
              TItemFunctions.PutItem(Player, 15553, 500); // Poção de Mana Grande
            end;
          2:
            begin
              if (Player.GetInventoryMaxSlots() < 12) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 8189, 50); // Perga portal Evento
              TItemFunctions.PutItem(Player, 8007);
              // Extrato Líquido 3 dias [Evento]
              TItemFunctions.PutItem(Player, 15549);
              // Buquê de Rosas Vermelhas 3 Dias
              TItemFunctions.PutItem(Player, 10051, 1); // Bau do Level 70
              TItemFunctions.PutItem(Player, 7975); // Bala de Cash [Rifleman]
              TItemFunctions.PutItem(Player, 8026); // Símbolo de Testamento
              TItemFunctions.PutItem(Player, 966); // Caixa de Montaria [Evento]
              TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
              TItemFunctions.PutItem(Player, 8045); // Símbolo da Confiança
              TItemFunctions.PutItem(Player, 8043); // Símbolo do Vendedor
              TItemFunctions.PutItem(Player, 15552, 500); // Poção de Vida Grande
              TItemFunctions.PutItem(Player, 15553, 500); // Poção de Mana Grande
            end;
          3:
            begin
              if (Player.GetInventoryMaxSlots() < 12) then
              begin
                Player.SendClientMessage('Inventário cheio.');
                Exit;
              end;
              TItemFunctions.PutItem(Player, 8189, 50); // Perga portal Evento
              TItemFunctions.PutItem(Player, 8007);
              // Extrato Líquido 3 dias [Evento]
              TItemFunctions.PutItem(Player, 15549);
              // Buquê de Rosas Vermelhas 3 Dias
              TItemFunctions.PutItem(Player, 10051, 1); // Bau do Level 70
              TItemFunctions.PutItem(Player, 7945); // Bala de Cash [Dualgunner]
              TItemFunctions.PutItem(Player, 8026); // Símbolo de Testamento
              TItemFunctions.PutItem(Player, 966); // Caixa de Montaria [Evento]
              TItemFunctions.PutItem(Player, 8025); // Símbolo do Viajante
              TItemFunctions.PutItem(Player, 8045); // Símbolo da Confiança
              TItemFunctions.PutItem(Player, 8043); // Símbolo do Vendedor
              TItemFunctions.PutItem(Player, 15552, 500); // Poção de Vida Grande
              TItemFunctions.PutItem(Player, 15553, 500); // Poção de Mana Grande
            end;
        end;
      end;
    673:
      begin
        if Player.GetInventoryMaxSlots() < 11 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 10052, 1);
        Player.SendClientMessage
          ('Recebeu a caixa de volta, ainda não está configurada.');
      end;
    674:
      begin
        if Player.GetInventoryMaxSlots() < 11 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 10051, 1);
        Player.SendClientMessage
          ('Recebeu a caixa de volta, ainda não está configurada.');
      end;
    1600:
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 10433);
        TItemFunctions.PutItem(Player, 4271);
        TItemFunctions.PutItem(Player, 11451);
        TItemFunctions.PutItem(Player, 4480);
        TItemFunctions.PutItem(Player, 4481);
      end;
    295:
      begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 8007)
      end;
    288:
      begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 8009);
      end;
    39:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (7008) + i * 30);
        end;
      end;
    41:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (7127) + i * 30);
        end;
      end;
    42:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (7248) + i * 30);
        end;
      end;
    43:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (7368) + i * 30);
        end;
      end;
    44:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (7488) + i * 30);
        end;
      end;
    45:
      begin
        if Player.GetInventoryMaxSlots() < 4 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (7608) + i * 30);
        end;
      end;
    992: // Alma Negra Guerreiro
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 2553, 127); // Espada da Alma Negra
        TItemFunctions.PutItem(Player, 2838, 127); // Elmo da Alma Negra
        TItemFunctions.PutItem(Player, 2868, 127); // Armadura da Alma Negra
        TItemFunctions.PutItem(Player, 2898, 127); // Manoplas da Alma Negra
        TItemFunctions.PutItem(Player, 2928, 127); // Botas da Alma Negra
      end;

    993: // Alma Negra Templario
      begin
        if Player.GetInventoryMaxSlots() < 7 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 2518, 127); // Lâmina da Alma Negra
        TItemFunctions.PutItem(Player, 2808, 127); // Escudo da Alma Negra
        TItemFunctions.PutItem(Player, 2958, 127); // Elmo da Alma Negra
        TItemFunctions.PutItem(Player, 2988, 127); // Armadura da Alma Negra
        TItemFunctions.PutItem(Player, 3018, 127); // Manoplas da Alma Negra
        TItemFunctions.PutItem(Player, 3048, 127); // Botas da Alma Negra
      end;

    994: // Alma Negra Atirador
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 2693, 127); // Rifle da Alma Negra
        TItemFunctions.PutItem(Player, 3078, 127); // Elmo da Alma Negra
        TItemFunctions.PutItem(Player, 3108, 127); // Armadura da Alma Negra
        TItemFunctions.PutItem(Player, 3138, 127); // Manoplas da Alma Negra
        TItemFunctions.PutItem(Player, 3168, 127); // Botas da Alma Negra
      end;

    995: // Alma Negra Pistoleira
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 2658, 127); // Rifle da Alma Negra
        TItemFunctions.PutItem(Player, 3198, 127); // Elmo da Alma Negra
        TItemFunctions.PutItem(Player, 3228, 127); // Armadura da Alma Negra
        TItemFunctions.PutItem(Player, 3258, 127); // Manoplas da Alma Negra
        TItemFunctions.PutItem(Player, 3288, 127); // Botas da Alma Negra
      end;

    996: // Alma Negra Feiticeiro
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 2763, 127); // Rifle da Alma Negra
        TItemFunctions.PutItem(Player, 3318, 127); // Elmo da Alma Negra
        TItemFunctions.PutItem(Player, 3348, 127); // Armadura da Alma Negra
        TItemFunctions.PutItem(Player, 3378, 127); // Manoplas da Alma Negra
        TItemFunctions.PutItem(Player, 3408, 127); // Botas da Alma Negra
      end;

    997: // Alma Negra Clérigo
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 2728, 127); // Rifle da Alma Negra
        TItemFunctions.PutItem(Player, 3438, 127); // Elmo da Alma Negra
        TItemFunctions.PutItem(Player, 3468, 127); // Armadura da Alma Negra
        TItemFunctions.PutItem(Player, 3498, 127); // Manoplas da Alma Negra
        TItemFunctions.PutItem(Player, 3528, 127); // Botas da Alma Negra
      end;
    137:
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (2846) + i * 30, $50);
        end;
        TItemFunctions.PutEquipament(Player, 2561, $50);
      end;
    138:
      begin
        if Player.GetInventoryMaxSlots() < 6 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (2966) + i * 30, 5);
        end;
        TItemFunctions.PutEquipament(Player, 2526, $50);
        TItemFunctions.PutEquipament(Player, 2816, $50);
      end;
    139:
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (3086) + i * 30, $50);
        end;
        TItemFunctions.PutEquipament(Player, 2701, $50);
      end;
    140:
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (3206) + i * 30, $50);
        end;
        TItemFunctions.PutEquipament(Player, 2666, $50);
      end;
    141:
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (3326) + i * 30, $50);
        end;
        TItemFunctions.PutEquipament(Player, 2771, $50);
      end;
    142:
      begin
        if Player.GetInventoryMaxSlots() < 5 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        for i := 0 to 3 do
        begin
          TItemFunctions.PutEquipament(Player, (3446) + i * 30, $50);
        end;
        TItemFunctions.PutEquipament(Player, 2736, $50);
      end;
    9572: // Caixa de Cristal de Montaria
      begin
        if (Player.GetInventoryMaxSlots() = 0) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([4215, 4216, 4217, 4218, 4219, 4213,
          4226, 4227, 4214, 4230, 4231, 4240, 4241],
          [20, 20, 20, 20, 20, 20, 15, 15, 15, 5, 25, 25, 3]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    8270:  // Caixa de Cristal Pran
      begin
        if (Player.GetInventoryMaxSlots() = 0) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([9451, 9452, 9454, 9455, 9456, 9457,
          9458, 9459, 9460, 9461, 9462, 9463, 9464, 9465],
          [5, 5, 2, 2, 2, 25, 25, 25, 25, 25, 15, 15, 5, 5, 30]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    5311:  // Caixa de Cristal Soul
    begin
        if (Player.GetInventoryMaxSlots() = 0) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([5312, 5313, 5314, 5315, 5316, 5317,
          5318, 5319, 5323, 5324, 5325, 5326, 5327,5328,5329],
          [12,12,12,12,12,11,11,11,1,1,1,1,1,1,1]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    16581:
    begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 16615);
      end;
    16582:
    begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 16614);
      end;
    16583:
    begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 16612);
      end;
    16584:
    begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 16611);
      end;
    16585:
    begin
        if Player.GetInventoryMaxSlots() < 1 then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, 16592);
      end;
    16004: // Caixa de Cristal de Pran Lv2
      begin
        if (Player.GetInventoryMaxSlots() = 2) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([8270, 11454, 14140, 8137],
          [30, 50, 50, 5]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    16003:  // Caixa de Cristal de Montaria lv2
      begin
        if (Player.GetInventoryMaxSlots() = 0) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([9572, 4274, 14140, 8137],
          [30, 50, 50, 5]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    16000:  // Caixa de Cristal de Arma
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([14137, 11454, 14140, 8137],
          [30, 50, 50, 5]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    16001: // Caixa de Cristal de Armadura Lv2
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([14132, 11454, 14140, 8137],
          [30, 50, 50, 5]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    16002: // Caixa de Cristal de Acessório Lv2
      begin
        if (Player.GetInventoryMaxSlots() = 1) then
        begin
          Player.SendClientMessage('Inventário cheio.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([14129, 11454, 14140, 8137],
          [30, 50, 50, 5]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        TItemFunctions.PutItem(Player, RandomTax);
      end;
    970: // Caixa do Nah
      begin
        if (Player.GetInventoryMaxSlots() < 2) then
        begin
          Player.SendClientMessage('Inventário cheio. 2 Espaços necessários.');
          Exit;
        end;
        RandomTax := TItemFunctions.SelectRamdomItem([1, 2, 3, 4, 5, 6,7,8,9,10,11,12,13,14,15,16,17,18],
          [8,8,6,6,6,6,6,6,6,6,8,8,8,8,1,1,1,1]);
        if (RandomTax = 0) then
        begin
          Player.SendClientMessage('Erro randomico, contate o suporte.');
          Exit;
        end;
        case RandomTax of
          1:
            begin
              TItemFunctions.PutItem(Player, 16567, 1); // Pergaminho do Retorno: Regenshein
            end;

          2:
            begin
              TItemFunctions.PutItem(Player, 16568, 1); // Pergaminho do Retorno: Cidade
            end;
          3:
            begin
              TItemFunctions.PutItem(Player, 16569, 1); // Perg. Desconhecido: Humanoide
            end;
          4:
            begin
              TItemFunctions.PutItem(Player, 16570, 1); // Perg. Desconhecido: Morto-Vivo
            end;
          5:
            begin
              TItemFunctions.PutItem(Player, 16571, 1);  // Perg. Desconhecido: Demônio
            end;
          6:
            begin
              TItemFunctions.PutItem(Player, 16572, 1);   // Perg. Desconhecido: Estrutura
            end;
         7:
            begin
              TItemFunctions.PutItem(Player, 16573, 1);  // Perg. Desconhecido: Misto
            end;
         8:
            begin
              TItemFunctions.PutItem(Player, 16574, 1);  // Perg. Desconhecido: Inseto
            end;
         9:
            begin
              TItemFunctions.PutItem(Player, 16575, 1);  // Perg. Desconhecido: Planta
            end;
         10:
            begin
              TItemFunctions.PutItem(Player, 16576, 1); // Perg. Desconhecido: Animal
            end;
          11:
            begin
              TItemFunctions.PutItem(Player, 16577, 1); // Poção da Inteligência
            end;
         12:
            begin
              TItemFunctions.PutItem(Player, 16578, 1); // Poção da Agilidade
            end;
        13:
            begin
              TItemFunctions.PutItem(Player, 16579, 1); // Poção da Força
            end;
      14:
            begin
              TItemFunctions.PutItem(Player, 16580, 1); // Poção da Velocidade
            end;
    15:
            begin
              TItemFunctions.PutItem(Player, 16582, 1); // Proteção da Defesa [1 D]  – Selado
            end;
  16:
            begin
              TItemFunctions.PutItem(Player, 16583, 1); // Poção da Destruição  [1 D] – Selado
            end;
  17:
            begin
              TItemFunctions.PutItem(Player, 16584, 1); // Proteção do Gato Preto [1 D] – Selado
            end;
18:
            begin
              TItemFunctions.PutItem(Player, 16585, 1); // Extrato de Líquido Facion [1 D] – Selado
            end;

        end;
      end;
    17101: // Lâmina Carregada Aprimorado [Vento]
      // SKILL SERIA 420
      if Player.Base.Character.ClassInfo = 3 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(420) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 417, 4);
          TSkillFunctions.UpdateAllOnBar(Player, 417, 420, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 418, 420, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 419, 420, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17102: // Lâmina Carregada Aprimorado [Água]
      // SKILL SERIA 419
      if Player.Base.Character.ClassInfo = 3 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(419) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 417, 3);
          TSkillFunctions.UpdateAllOnBar(Player, 417, 419, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 418, 419, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 420, 419, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17103: // Lâmina Carregada Aprimorado [Fogo]
      // SKILL SERIA 418
      if Player.Base.Character.ClassInfo = 3 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(418) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 417, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 417, 418, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 419, 418, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 420, 418, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17129: // Lâmina da Promessa Transcendido [Fogo]
      if Player.Base.Character.ClassInfo = 13 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(1378) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 1377, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1378, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1378, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1378, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17128: // Lâmina da Promessa Transcendido [Água]
      if Player.Base.Character.ClassInfo = 13 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(1379) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 1377, 3);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1379, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1379, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1379, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17127: // Lâmina da Promessa Transcendido [Vento]
      if Player.Base.Character.ClassInfo = 13 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(1380) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 1377, 4);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1380, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1380, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 1377, 1380, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17155: // Posição de Atirador Transcendido [Vento]
      if Player.Base.Character.ClassInfo = 23 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(2338) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 2337, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2338, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2338, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2338, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17154: // Posição de Atirador Transcendido [Água]
      if Player.Base.Character.ClassInfo = 23 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(2339) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 2337, 3);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2339, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2339, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2339, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17153: // Posição de Atirador Transcendido [Fogo]
      if Player.Base.Character.ClassInfo = 23 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(2340) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 2337, 4);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2340, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2340, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 2337, 2340, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17181: // Rosa Sangrenta Transcendido [Fogo]
      if Player.Base.Character.ClassInfo = 33 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(3298) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 3297, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3298, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3298, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3298, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17180: // Rosa Sangrenta Transcendido [Água]
      if Player.Base.Character.ClassInfo = 33 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(3299) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 3297, 3);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3299, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3299, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3299, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17179: // Rosa Sangrenta Transcendido [Vento]
      if Player.Base.Character.ClassInfo = 33 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(3300) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 3297, 4);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3300, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3300, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 3297, 3300, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17207: // Pecados Mortais Transcendido [Fogo]
      if Player.Base.Character.ClassInfo = 43 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(4258) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 4257, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4258, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4258, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4258, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17206: // Pecados Mortais Transcendido [Água]
      if Player.Base.Character.ClassInfo = 43 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(4259) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 4257, 3);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4259, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4259, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4259, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17205: // Pecados Mortais Transcendido [Vento]
      if Player.Base.Character.ClassInfo = 43 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(4260) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 4257, 4);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4260, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4260, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4257, 4260, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17231: // Esplendor Transcendido [Fogo]
      if Player.Base.Character.ClassInfo = 53 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(5218) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 5217, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5218, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5218, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5218, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17232: // Esplendor Transcendido [Água]
      if Player.Base.Character.ClassInfo = 53 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(5219) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 5217, 3);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5219, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5219, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5219, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17233: // Esplendor Transcendido [Vento]
      if Player.Base.Character.ClassInfo = 53 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(5220) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 5217, 4);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5220, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5220, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 5217, 5220, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17234: // Mão da Cura
      if Player.Base.Character.ClassInfo >= 51 then
      begin
        var
          barIndex: Integer;
        if Player.Character.Skills.GetSkill(4962) > 0 then
        begin
          Player.SendClientMessage('Você já possui essa habilidade.');
          Exit;
        end
        else
        begin
          TSkillFunctions.LearnSkillBook(Player, 4961, 2);
          TSkillFunctions.UpdateAllOnBar(Player, 4961, 4962, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4961, 4962, barIndex);
          TSkillFunctions.UpdateAllOnBar(Player, 4961, 4962, barIndex);
        end;
      end
      else
      begin
        Player.SendClientMessage
          ('Você não tem a classe permitida pra usar esse livro.');
        Exit;
      end;
    17099: // Evolução Segunda Classe
      begin
        Inc(Player.Character.Base.ClassInfo);
        Player.SaveInGame(Player.SelectedCharacterIndex);
        Player.SendClientMessage('Parabéns por a Segunda Classe.');
      end;

    17100: // Evolução Classe Classe
      begin
        Inc(Player.Character.Base.ClassInfo);
        Player.SaveInGame(Player.SelectedCharacterIndex);
        Player.SendClientMessage('Parabéns por a Terceira Classe.');
      end;
    17098: // Evolução Segunda Classe WR
      begin
        if Player.Character.Base.ClassInfo = BYTE(1) then
        begin
          Player.Character.Base.ClassInfo := BYTE(2);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Gladiador.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17088: // Evolução Terceira Classe WR
      begin
        if Player.Character.Base.ClassInfo = BYTE(2) then
        begin
          Player.Character.Base.ClassInfo := BYTE(3);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Ares.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17097: // Evolução Segunda Classe TP
      begin
        if Player.Character.Base.ClassInfo = BYTE(11) then
        begin
          Player.Character.Base.ClassInfo := BYTE(12);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Paladino.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17087: // Evolução Terceira Classe TP
      begin
        if Player.Character.Base.ClassInfo = BYTE(12) then
        begin
          Player.Character.Base.ClassInfo := BYTE(13);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Atena.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17096: // Evolução Segunda Classe ATT
      begin
        if Player.Character.Base.ClassInfo = BYTE(21) then
        begin
          Player.Character.Base.ClassInfo := BYTE(22);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Dinamitador.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17086: // Evolução Terceira Classe ATT
      begin
        if Player.Character.Base.ClassInfo = BYTE(22) then
        begin
          Player.Character.Base.ClassInfo := BYTE(23);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Apolo.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17095: // Evolução Segunda Classe DG
      begin
        if Player.Character.Base.ClassInfo = BYTE(31) then
        begin
          Player.Character.Base.ClassInfo := BYTE(32);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Desperado.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17085: // Evolução Terceira Classe DG
      begin
        if Player.Character.Base.ClassInfo = BYTE(32) then
        begin
          Player.Character.Base.ClassInfo := BYTE(33);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Artemis.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17094: // Evolução Segunda Classe FC
      begin
        if Player.Character.Base.ClassInfo = BYTE(41) then
        begin
          Player.Character.Base.ClassInfo := BYTE(42);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage
            ('Parabéns por se tornar Feiticeiro Caótico.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17084: // Evolução Terceira Classe FC
      begin
        if Player.Character.Base.ClassInfo = BYTE(42) then
        begin
          Player.Character.Base.ClassInfo := BYTE(43);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Hades.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17093: // Evolução Segunda Classe CL
      begin
        if Player.Character.Base.ClassInfo = BYTE(51) then
        begin
          Player.Character.Base.ClassInfo := BYTE(52);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Santo.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17083: // Evolução Terceira Classe CL
      begin
        if Player.Character.Base.ClassInfo = BYTE(52) then
        begin
          Player.Character.Base.ClassInfo := BYTE(53);
          Player.SaveInGame(Player.SelectedCharacterIndex);
          Player.SendClientMessage('Parabéns por se tornar Afrodite.');
        end
        else
        begin
          Player.SendClientMessage('Sua classe atual não pode usar este item.');
          Exit;
        end;
      end;
    17081: // Evolução da pran Pra Criança
      begin
        Player.SendClientMessage('Adicionar o sistema de evolução.');
        TItemFunctions.PutItem(Player, 17081, 1); // Espada da Alma Negra
      end;
    17082: // Evolução da pran Pra Adolescente
      begin
        Player.SendClientMessage('Adicionar o sistema de evolução.');
        TItemFunctions.PutItem(Player, 17082, 1); // Espada da Alma Negra
      end;
    17089: // Evolução da pran Pra Adulta
      begin
        Player.SendClientMessage('Adicionar o sistema de evolução.');
        TItemFunctions.PutItem(Player, 17089, 1); // Espada da Alma Negra
      end;
    14250: // Administrador - 14250
      begin
        Player.AddTitle(80, 1);
      end;
    14253: // Saudades Sumido - 14253
      begin
        Player.AddTitle(83, 1);
      end;
  end;
end;

end.unit ItemBoxFunctions;
