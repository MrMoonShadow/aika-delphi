program AikaServer;
{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  DateUtils,
  Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  StrUtils,
  Winsock2,
  Log in 'Src\Functions\Log.pas',
  GlobalDefs in 'Src\Data\GlobalDefs.pas',
  ServerSocket in 'Src\Connections\ServerSocket.pas',
  Load in 'Src\Functions\Load.pas',
  NPC in 'Src\Mob\NPC.pas',
  BaseMob in 'Src\Mob\BaseMob.pas',
  Player in 'Src\Mob\Player.pas',
  CpuUsage in 'Src\Functions\CpuUsage.pas',
  Functions in 'Src\Functions\Functions.pas',
  ItemFunctions in 'Src\Functions\ItemFunctions.pas',
  SkillFunctions in 'Src\Functions\SkillFunctions.pas',
  Util in 'Src\Functions\Util.pas',
  ConnectionsThread in 'Src\Threads\ConnectionsThread.pas',
  PlayerThread in 'Src\Threads\PlayerThread.pas',
  UpdateThreads in 'Src\Threads\UpdateThreads.pas',
  FilesData in 'Src\Data\FilesData.pas',
  MiscData in 'Src\Data\MiscData.pas',
  Packets in 'Src\Data\Packets.pas',
  PlayerData in 'Src\Data\PlayerData.pas',
  PartyData in 'Src\Party\PartyData.pas',
  CharacterMail in 'Src\Mail\CharacterMail.pas',
  MailFunctions in 'Src\Mail\MailFunctions.pas',
  EncDec in 'Src\Connections\EncDec.pas',
  NPCHandlers in 'Src\PacketHandlers\NPCHandlers.pas',
  PacketHandlers in 'Src\PacketHandlers\PacketHandlers.pas',
  LoginSocket in 'Src\Connections\LoginSocket.pas',
  AuthHandlers in 'Src\PacketHandlers\AuthHandlers.pas',
  TokenSocket in 'Src\Connections\TokenSocket.pas',
  CommandHandlers in 'Src\PacketHandlers\CommandHandlers.pas',
  GuildData in 'Src\Guild\GuildData.pas',
  SQL in 'Src\Connections\SQL.pas',
  MOB in 'Src\Mob\MOB.pas',
  PET in 'Src\Mob\PET.pas',
  R_Paneil in 'Src\Functions\R_Paneil.pas',
  EntityMail in 'Src\Data\Entity\EntityMail.pas',
  EntityFriend in 'Src\Data\Entity\EntityFriend.pas',
  SendPacketForm in 'Src\Forms\SendPacketForm.pas' {frmSendPacket},
  Nation in 'Src\Nation\Nation.pas',
  PingBackForm in 'Src\Forms\PingBackForm.pas' {frmPingback: DWORD): BOOL; stdcall;
var
  i: BYTE;
begin
  Result := False;
  if (dwCtrlType = CTRL_CLOSE_EVENT) or (dwCtrlType = CTRL_LOGOFF_EVENT) or
    (dwCtrlType = CTRL_SHUTDOWN_EVENT) then
  begin
    if not(ServerHasClosed) then
    begin
      TFunctions.SaveGuilds;
      for i := Low(Nations) to High(Nations) do
      begin
        Nations[i].SaveNation;
      end;
      for i := Low(Servers) to High(Servers) do
      begin
        Servers[i].CloseServer;
      end;
      Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
    end;
    Result := True;
  end;
end;

var
  InputStr: string;
  Uptime: TDateTime;
  timeinit: Integer;
  CreateSendPacketForm: Boolean = True;
  i: Integer;
  cmdto: String;

begin
  Logger := TLog.Create;
  SetConsoleTitleA('Aika Server');

  try
    Uptime := Now;
    WebServerClosed := False;
    xServerClosed := False;
    TLoad.InitCharacters;
    TLoad.InitItemList;
    TLoad.InitSkillData;
    TLoad.InitSetItem;
    TLoad.InitConjunts;
    TLoad.InitReinforce;
    TLoad.InitPremiumItems;
    TLoad.InitExpList;
    TLoad.InitPranExpList;
    TLoad.InitServerConf;
    TLoad.InitServerList;
    TLoad.LoadNPCOptions;
    TLoad.InitMapsData;
    TLoad.InitScrollPositions;
    TLoad.InitQuestList;
    TLoad.InitQuests;
    TLoad.InitTitles;
    TLoad.InitDropList2;
    TLoad.InitRecipes;
    TLoad.InitMakeItems;
    Logger.Space; { Space},
  AuctionFunctions in 'Src\Auction\AuctionFunctions.pas',
  CharacterAutcion in 'Src\Auction\CharacterAutcion.pas',
  Objects in 'Src\Mob\Objects.pas',
  CastleSiege in 'Src\Nation\CastleSiege.pas',
  Attributes in 'Src\Attributes\Attributes.pas',
  ItemGoldFunctions in 'Src\Items\ItemGoldFunctions.pas',
  ItemBoxFunctions in 'Src\Items\ItemBoxFunctions.pas',
  ItemConjuntFunctions in 'Src\Items\ItemConjuntFunctions.pas',
  ItemSkillFunctions in 'Src\Items\ItemSkillFunctions.pas';

function ConsoleHandler(dwCtrlType: DWORD): BOOL; stdcall;
var
  i: BYTE;
begin
  Result := False;
  if (dwCtrlType = CTRL_CLOSE_EVENT) or (dwCtrlType = CTRL_LOGOFF_EVENT) or
    (dwCtrlType = CTRL_SHUTDOWN_EVENT) then
  begin
    if not(ServerHasClosed) then
    begin
      TFunctions.SaveGuilds;
      for i := Low(Nations) to High(Nations) do
      begin
        Nations[i].SaveNation;
      end;
      for i := Low(Servers) to High(Servers) do
      begin
        Servers[i].CloseServer;
      end;
      Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
    end;
    Result := True;
  end;
end;

var
  InputStr: string;
  Uptime: TDateTime;
  timeinit: Integer;
  CreateSendPacketForm: Boolean = True;
  i: Integer;
  cmdto: String;

begin
  Logger := TLog.Create;
  SetConsoleTitleA('Aika Server');

  try
    Uptime := Now;
    WebServerClosed := False;
    xServerClosed := False;
    TLoad.InitCharacters;
    TLoad.InitItemList;
    TLoad.InitSkillData;
    TLoad.InitSetItem;
    TLoad.InitConjunts;
    TLoad.InitReinforce;
    TLoad.InitPremiumItems;
    TLoad.InitExpList;
    TLoad.InitPranExpList;
    TLoad.InitServerConf;
    TLoad.InitServerList;
    TLoad.LoadNPCOptions;
    TLoad.InitMapsData;
    TLoad.InitScrollPositions;
    TLoad.InitQuestList;
    TLoad.InitQuests;
    TLoad.InitTitles;
    TLoad.InitDropList2;
    TLoad.InitRecipes;
    TLoad.InitMakeItems;
    Logger.Space; { Space }
    TLoad.InitServers; { Channels Load }
    Logger.Space; { Space }
    TLoad.InitAuthServer;
    Logger.Space; { Space }
    TLoad.InitNPCS;
    TLoad.InitGuilds;
    for i := Low(Servers) to High(Servers) do
    begin
      Servers[i].ServerHasClosed := False;

      Servers[i].StartThreads;

      if (i <= 2) then
      begin
        Nations[Servers[i].NationID - 1].CreateNation(Servers[i].ChannelID);
        Nations[Servers[i].NationID - 1].LoadNation();
        Servers[i].UpdateReliquareEffects();
      end;

    end;

    timeinit := MilliSecondsBetween(Now, Uptime);
    Logger.Write('Servidor levou ' + IntToStr(Round(timeinit / 1000)) +
      ' segundos para carregar completamente.', TLogType.ServerStatus);
    Logger.Space;

    while (True) do
    begin
      ReadLn(cmdto);

      case AnsiIndexStr(cmdto, ['close', 'savecsvmob', 'reloadskill',
        'reloaditem', 'reloadserverconf', 'reloadmobs', 'reloaddrops',
        'reloadpremiumshop', 'reloadquestsserver', 'reloadquestclient',
        'reloadtitles', 'reloadrecipes', 'reloadmakeitem']) of
        0:
          begin
            for i := Low(Servers) to High(Servers) do
            begin
              closesocket(Servers[i].Sock);
              Servers[i].Sock := INVALID_SOCKET;
            end;
            ServerHasClosed := True;
            Logger.Write('Fechando o servidor, aguarde...',
              TLogType.ConnectionsTraffic);

            TFunctions.SaveGuilds;

            Logger.Write('GUILDAS SALVAS..', TLogType.ConnectionsTraffic);
            try
              for i := Low(Nations) to High(Nations) do
              begin
                Nations[i].SaveNation;
              end;
            except

              Sleep(1000);
              Logger.Write('NAÇÕES SALVAS..', TLogType.ConnectionsTraffic);

              xServerClosed := True;
              Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
              Logger.Write
                ('Desconectando as pessoas.. aguarde até o final para salvar!',
                TLogType.ConnectionsTraffic);

            end;

            for i := Low(Servers) to High(Servers) do
            begin
              Servers[i].ServerHasClosed := True;
              Sleep(1000);
              Servers[i].CloseServer;
              Sleep(1000);

            end;

            xServerClosed := True;
            Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
            Logger.Write('Feche a janela deste console. Tudo foi salvo!',
              TLogType.ConnectionsTraffic);
          end;

        1:
          begin

          end;

        2:
          begin
            ZeroMemory(@SkillData, sizeof(SkillData));
            TLoad.InitSkillData;
          end;
        3:
          begin
            ZeroMemory(@ItemList, sizeof(ItemList));
            TLoad.InitItemList;
          end;
        4: // reloadserverconf
          begin
            TLoad.InitServerConf;
          end;
        5: // reloadmobs
          begin
            for i := Low(Servers) to High(Servers) do
            begin
              Servers[i].StartMobs;
            end;
          end;

        6: // reloaddrops
          begin
            TLoad.InitDropList2;
          end;
        7: // reloadpremiumshop
          begin
            TLoad.InitPremiumItems;
          end;
        8: // reloadquestsserver
          begin
            TLoad.InitQuests;
          end;
        9: // reloadquestclient
          begin
            TLoad.InitQuestList;
          end;
        10: // reloadtitles
          begin
            TLoad.InitTitles;
          end;
        11: // reloadrecipes
          begin
            TLoad.InitRecipes;
          end;
        12: // reloadmakeitems
          begin
            TLoad.InitMakeItems;
          end;
      else
        begin
          for i := Low(Servers) to High(Servers) do
          begin
            Servers[i].SendServerMsg(AnsiString('[SERVER] ' + cmdto), 32, 16);
          end;
        end;
      end;
    end;

  except
    on E: Exception do
    begin
      Logger.Write(E.ClassName + ': ' + E.Message, TLogType.error);
      ReadLn(InputStr);
    end;
  end;

end.
