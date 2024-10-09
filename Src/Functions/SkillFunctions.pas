unit SkillFunctions;

interface

uses
  Player, SysUtils;

type
  TSkillFunctions = class(TObject)
  public
    class function GetSkillLevel(SkillIndex: WORD; out Level: Cardinal)
      : Integer;
    class function GetSkillPranLevel(SkillIndex, SkillLevel: WORD;
      out Level: Cardinal): Integer;
    class function GetSkillIndex(Classe, Skill, Level: Integer): Integer;
    class function GetClassSkillIndex(Classe, Skill: Integer): Integer;

    class function IncremmentSkillLevel(var Player: TPlayer;
      const Skill: Integer; out SkillID: Integer): Boolean;

    class function GetSkillIndexOnBar(SkillIndex: WORD): Cardinal;
    class function GetFromBarSkillIndex(BarIndex: Cardinal): WORD;

    class function IsSkillOnBar(const Player: TPlayer; SkillIndex: Integer;
      out BarIndex: Integer): Boolean;

    class function LearnSkillAuto(var Player: TPlayer): Boolean;
    class function LearnSkillBook(var Player: TPlayer; SkillID: Integer;
      SkillVersion: Integer): Boolean;

    class function UpdateAllOnBar(var Player: TPlayer; SkillIndex: Integer;
      NewSkillIndex: Integer; out BarIndex: Integer): Boolean;
  end;

implementation

uses
  GlobalDefs, Math, PlayerData, Log, Windows;

class function TSkillFunctions.GetSkillLevel(SkillIndex: WORD;
  out Level: Cardinal): Integer;
begin
  Result := 0;

  Level := Trunc(Power(2, SkillData[SkillIndex].Level + 1) - 2);

  case Level of

    0 .. 65535:
      Result := 2;

    65536 .. 131080:
      Result := 4;

  end;
end;

class function TSkillFunctions.GetSkillPranLevel(SkillIndex, SkillLevel: WORD;
  out Level: Cardinal): Integer;
var
  l: Cardinal;
  a, b: Cardinal;
begin
  Result := 1;

  l := Round(Power(2, SkillLevel));

  dec(l);

  if (SkillIndex = 0) then
  begin // ta setando a primeira skill do loop
    Result := 1;
    Level := l;
  end
  else
  begin
    a := Round(Power(SkillIndex, 4));

    if (a = 1) then
      a := 4;

    Level := l * a;

    case Level of
      0 .. 255:
        Result := 1;

      256 .. 65535:
        Result := 2;
    end;
  end;
end;

class function TSkillFunctions.GetSkillIndex(Classe: Integer; Skill: Integer;
  Level: Integer): Integer;
begin
  Result := 1;

  if (Classe > 1) then
  begin
    Result := (Classe - 1) * (960);
  end;

  if (Skill > 1) then
  begin
    inc(Result, (Skill - 1) * (16));
  end;

  if (Classe = 1) then
  begin
    if (Level > 1) then
    begin
      inc(Result, (Level - 1));
    end;
  end
  else
  begin
    if (Level > 1) then
    begin
      inc(Result, (Level - 1));
    end
    else
    begin
      inc(Result, Level);
    end;
  end;
end;

class function TSkillFunctions.GetClassSkillIndex(Classe,
  Skill: Integer): Integer;
begin
  Result := 1;

  if (Classe > 1) then
  begin
    Result := Skill mod (960 * (Classe - 1));
  end;

  Result := Trunc(Result / 16);
end;

class function TSkillFunctions.IncremmentSkillLevel(var Player: TPlayer;
  const Skill: Integer; out SkillID: Integer): Boolean;
var
  dwSkill: Integer;
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Player.Character.Skills.Basics) - 1 do
  begin
    dwSkill := Player.Character.Skills.Basics[i].Index;
    if (Skill >= dwSkill) and (Skill <= dwSkill + 15) then
    begin
      inc(Player.Character.Skills.Basics[i].Level);
      SkillID := Player.Character.Skills.Basics[i].Index;
      Result := True;
      Break;
    end;
  end;

  if (Result) then
    Exit;

  for i := 0 to Length(Player.Character.Skills.Others) - 1 do
  begin
    dwSkill := Player.Character.Skills.Others[i].Index;

    if (Skill >= dwSkill) and (Skill <= dwSkill + 15) then
    begin
      inc(Player.Character.Skills.Others[i].Level);
      SkillID := Player.Character.Skills.Others[i].Index;
      Result := True;
      Break;
    end;
  end;
end;

class function TSkillFunctions.GetSkillIndexOnBar(SkillIndex: WORD): Cardinal;
begin
  Result := (SkillIndex * 16) + 2;
end;

class function TSkillFunctions.GetFromBarSkillIndex(BarIndex: Cardinal): WORD;
begin
  Result := Round((BarIndex - 2) / 16);
end;

class function TSkillFunctions.IsSkillOnBar(const Player: TPlayer;
  SkillIndex: Integer; out BarIndex: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Player.Character.Base.ItemBar) - 1 do
  begin
    if (Self.GetFromBarSkillIndex(Player.Character.Base.ItemBar[i]) = SkillIndex)
    then
    begin
      Result := True;
      BarIndex := i;
      Break;
    end;
  end;
end;

class function TSkillFunctions.UpdateAllOnBar(var Player: TPlayer;
  SkillIndex: Integer; NewSkillIndex: Integer; out BarIndex: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Player.Character.Base.ItemBar) - 1 do
  begin
    if (Self.GetFromBarSkillIndex(Player.Character.Base.ItemBar[i]) = SkillIndex)
    then
    begin
      Result := True;
      BarIndex := i;
      Player.Character.Base.ItemBar[BarIndex] :=
        GetSkillIndexOnBar(NewSkillIndex);
      Player.RefreshItemBarSlot(BarIndex, 2, NewSkillIndex);
    end;
  end;
end;

class function TSkillFunctions.LearnSkillAuto(var Player: TPlayer): Boolean;
var
  SkillID, i: Integer;
Begin
  for i := 0 to Length(Player.Character.Skills.Others) - 1 do
  begin
    if (Player.Character.Skills.Others[i].Level = 0) and
      (SkillData[Player.Character.Skills.Others[i].Index].MinLevel <=
      Player.Character.Base.Level) then
    begin
      inc(Player.Character.Skills.Others[i].Level);
      Player.SendPlayerSkillsLevel;
      Player.SendClientMessage
        ('Skill: ' + AnsiString(SkillData[Player.Character.Skills.Others[i].
        Index].Name) + ' Adquirida com sucesso.');
    end;
  end;
End;

class function TSkillFunctions.LearnSkillBook(var Player: TPlayer;
  SkillID: Integer; SkillVersion: Integer): Boolean;
var
  i: Integer;
begin
  if (SkillData[SkillID].MinLevel <= Player.Character.Base.Level) then
  begin
    for i := 0 to Length(Player.Character.Skills.Others) - 1 do
    begin
      if (Player.Character.Skills.Others[i].Index = SkillID) then
      begin
        Player.Character.Skills.Others[i].Level := SkillVersion;

        Player.SendPlayerSkillsLevel;

        Player.SendClientMessage('Skill: ' +
          AnsiString(SkillData[SkillID].Name) +
          ' adquirida com sucesso.');

        Result := True;
        Exit;
      end;
    end;
  end;
  Result := False;
end;

end.
