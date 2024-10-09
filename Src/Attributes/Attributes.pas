unit Attributes;

interface

uses
  Windows, Player, PlayerData, MiscData;

type
  TAttributeFunctions = class(TObject)
  public
    class procedure GetDoubleAttack(var Status: TStatus; var ChannelId: Byte;
      var NationId: Byte; var FromBuff: Integer; out doubleAttack: Integer);
    class procedure GetCriticalAttack(var Status: TStatus; var ChannelId: Byte;
      var NationId: Byte; var FromBuff: Integer; out criticalAttack: Integer);
    class procedure GetCriticalDamage(var Status: TStatus;
      var FromBuff: Integer; out criticalDamage: Integer);
    class procedure GetPhysicalPen(var Status: TStatus; var FromBuff: Integer;
      out physicalPen: Integer);
    class procedure GetMagicalPen(var Status: TStatus; var FromBuff: Integer;
      out magicalPen: Integer);
    class procedure GetSkillAttack(var Status: TStatus; var ChannelId: Byte;
      var NationId: Byte; var FromBuff: Integer; out skillAttack: Integer);
    class procedure GetCureTax(var Status: TStatus; var FromBuff: Integer;
      out cureTax: Integer);
    class procedure GetCriticalResistance(var Status: TStatus;
      var FromBuff: Integer; out criticalResistance: Integer);
    class procedure GetDoubleResistance(var Status: TStatus;
      var FromBuff: Integer; out doubleResistance: Integer);
    class procedure GetHitRate(var Status: TStatus; var ChannelId: Byte;
      var NationId: Byte; var FromBuff: Integer; out hitRate: Integer);
    class procedure GetDodge(var Status: TStatus; var ChannelId: Byte;
      var NationId: Byte; var FromBuff: Integer; out dodge: Integer);
    class procedure GetAbnormalStatusResistance(var Status: TStatus;
      var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
      out abnormalStatusResistance: Integer);
    class procedure GetCoolDownTime(var Status: TStatus; var ChannelId: Byte;
      var NationId: Byte; var FromBuff: Integer; out cdr: Integer);
    class procedure GetPhysicalDamage(var Status: TStatus;
      var BaseStatusAgi: Integer; var BaseStatusStr: Integer;
      var ChannelId: Byte; var FromBuff: Integer; out physicalDamage: Integer);
    class procedure GetMagicalDamage(var Status: TStatus; var ChannelId: Byte;
      var FromBuff: Integer; out magicalDamage: Integer);
    class procedure GetMP(var Status: TStatus; out mp: Integer);
    class procedure GetMPRegen(var Status: TStatus; var FromBuff: Integer;
      out mpRegen: Integer);
    class procedure GetHP(var Status: TStatus; out hp: Integer);
    class procedure GetHPRegen(var Status: TStatus; var FromBuff: Integer;
      out hpRegen: Integer);
  end;

implementation

uses
  SysUtils, System.Math, GlobalDefs, AnsiStrings, ItemFunctions, DateUtils, Log,
  SQL;

class procedure TAttributeFunctions.GetDoubleAttack(var Status: TStatus;
  var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
  out doubleAttack: Integer);
var
  DoubleAtk: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.05;
  HighValue := 0.025;
  if (Status.Str <= 500) then
  begin
    DoubleAtk := Ceil(Status.Str * BaseValue);
  end
  else
  begin
    DoubleAtk := Ceil(500 * BaseValue + (Status.Str - 500) * HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    doubleAttack := DoubleAtk + Servers[ChannelId].ReliqEffect
      [EF_RELIQUE_DOUBLE] + FromBuff;
  end
  else
    doubleAttack := DoubleAtk + FromBuff;
end;

class procedure TAttributeFunctions.GetCriticalAttack(var Status: TStatus;
  var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
  out criticalAttack: Integer);
var
  CriticalAtk: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.083;
  HighValue := 0.0415;
  if (Status.agility <= 500) then
  begin
    CriticalAtk := Floor(Status.agility * BaseValue);
  end
  else
  begin
    CriticalAtk := Floor(500 * BaseValue + (Status.agility - 500) * HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    criticalAttack := CriticalAtk + Servers[ChannelId].ReliqEffect
      [EF_RELIQUE_CRITICAL] + FromBuff;
  end
  else
    criticalAttack := CriticalAtk + FromBuff;

end;

class procedure TAttributeFunctions.GetCriticalDamage(var Status: TStatus;
  var FromBuff: Integer; out criticalDamage: Integer);
var
  CriticalDmgAtk: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.2;
  HighValue := 0.1;
  if (Status.Str <= 500) then
  begin
    CriticalDmgAtk := Ceil(Status.Str * BaseValue);
  end
  else
  begin
    CriticalDmgAtk := Ceil(500 * BaseValue + (Status.Str - 500) * HighValue);
  end;

  criticalDamage := CriticalDmgAtk + FromBuff;
end;

class procedure TAttributeFunctions.GetPhysicalPen(var Status: TStatus;
  var FromBuff: Integer; out physicalPen: Integer);
var
  PhysicalPenetration: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.03;
  HighValue := 0.015;
  if (Status.Str <= 500) then
  begin
    PhysicalPenetration := Ceil(Status.Str * BaseValue);
  end
  else
  begin
    PhysicalPenetration := Ceil(500 * BaseValue + (Status.Str - 500) *
      HighValue);
  end;

  physicalPen := PhysicalPenetration + FromBuff;
end;

class procedure TAttributeFunctions.GetMagicalPen(var Status: TStatus;
  var FromBuff: Integer; out magicalPen: Integer);
var
  MagicalPenetration: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.03;
  HighValue := 0.015;
  if (Status.Int <= 500) then
  begin
    MagicalPenetration := Ceil(Status.Int * BaseValue);
  end
  else
  begin
    MagicalPenetration := Ceil(500 * BaseValue + (Status.Int - 500) *
      HighValue);
  end;

  magicalPen := MagicalPenetration + FromBuff;
end;

class procedure TAttributeFunctions.GetSkillAttack(var Status: TStatus;
  var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
  out skillAttack: Integer);
var
  SkillAtk: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 5.24;
  HighValue := 2.62;
  if (Status.Luck <= 500) then
  begin
    SkillAtk := Ceil(Status.Luck * BaseValue);
  end
  else
  begin
    SkillAtk := Ceil(500 * BaseValue + (Status.Luck - 500) * HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    skillAttack := SkillAtk + FromBuff + Servers[ChannelId].ReliqEffect
      [EF_RELIQUE_SKILL_PER_DAMAGE];
  end
  else
    skillAttack := SkillAtk + FromBuff;
end;

class procedure TAttributeFunctions.GetCureTax(var Status: TStatus;
  var FromBuff: Integer; out cureTax: Integer);
var
  aCureTax: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 6.9;
  HighValue := 3.46;
  if (Status.Int <= 500) then
  begin
    aCureTax := Ceil(Status.Int * BaseValue);
  end
  else
  begin
    aCureTax := Ceil(500 * BaseValue + (Status.Int - 500) * HighValue);
  end;

  cureTax := aCureTax + FromBuff;
end;

class procedure TAttributeFunctions.GetCriticalResistance(var Status: TStatus;
  var FromBuff: Integer; out criticalResistance: Integer);
var
  CriticalResAtk: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.072;
  HighValue := 0.036;
  if (Status.Cons <= 500) then
  begin
    CriticalResAtk := Ceil(Status.Cons * BaseValue);
  end
  else
  begin
    CriticalResAtk := Ceil(500 * BaseValue + (Status.Cons - 500) * HighValue);
  end;

  criticalResistance := CriticalResAtk + FromBuff;
end;

class procedure TAttributeFunctions.GetDoubleResistance(var Status: TStatus;
  var FromBuff: Integer; out doubleResistance: Integer);
var
  DoubleResAtk: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.03;
  HighValue := 0.015;
  if (Status.Cons <= 500) then
  begin
    DoubleResAtk := Ceil(Status.Cons * BaseValue);
  end
  else
  begin
    DoubleResAtk := Ceil(500 * BaseValue + (Status.Cons - 500) * HighValue);
  end;

  doubleResistance := DoubleResAtk + FromBuff;
end;

class procedure TAttributeFunctions.GetHitRate(var Status: TStatus;
  var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
  out hitRate: Integer);
var
  aHitRate: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.1;
  HighValue := 0.05;
  if (Status.agility <= 500) then
  begin
    aHitRate := Ceil(Status.agility * BaseValue);
  end
  else
  begin
    aHitRate := Ceil(500 * BaseValue + (Status.agility - 500) * HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    hitRate := aHitRate + Servers[ChannelId].ReliqEffect[EF_RELIQUE_HIT]
      + FromBuff;
  end
  else
    hitRate := aHitRate + FromBuff;

end;

class procedure TAttributeFunctions.GetDodge(var Status: TStatus;
  var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
  out dodge: Integer);
var
  DodgeRate: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.05;
  HighValue := 0.025;
  if (Status.agility <= 500) then
  begin
    DodgeRate := Ceil(Status.agility * BaseValue);
  end
  else
  begin
    DodgeRate := Ceil(500 * BaseValue + (Status.agility - 500) * HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    dodge := DodgeRate + Servers[ChannelId].ReliqEffect[EF_RELIQUE_PARRY]
      + FromBuff;
  end
  else
    dodge := DodgeRate + FromBuff;

end;

class procedure TAttributeFunctions.GetAbnormalStatusResistance
  (var Status: TStatus; var ChannelId: Byte; var NationId: Byte;
  var FromBuff: Integer; out abnormalStatusResistance: Integer);
var
  aAbnormalStatusResistance: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.1;
  HighValue := 0.05;
  if (Status.Luck <= 500) then
  begin
    aAbnormalStatusResistance := Ceil(Status.Luck * BaseValue);
  end
  else
  begin
    aAbnormalStatusResistance := Ceil(500 * BaseValue + (Status.Luck - 500) *
      HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    abnormalStatusResistance := aAbnormalStatusResistance + Servers[ChannelId]
      .ReliqEffect[EF_RELIQUE_STATE_RESISTANCE] + FromBuff;
  end
  else
    abnormalStatusResistance := aAbnormalStatusResistance + FromBuff;
end;

class procedure TAttributeFunctions.GetCoolDownTime(var Status: TStatus;
  var ChannelId: Byte; var NationId: Byte; var FromBuff: Integer;
  out cdr: Integer);
var
  CdrTax: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  BaseValue := 0.04;
  HighValue := 0.02;
  if (Status.Int <= 500) then
  begin
    CdrTax := Ceil(Status.Int * BaseValue);
  end
  else
  begin
    CdrTax := Ceil(500 * BaseValue + (Status.Int - 500) * HighValue);
  end;

  if (Servers[ChannelId].NationId = NationId) then
  begin
    cdr := CdrTax + Servers[ChannelId].ReliqEffect[EF_RELIQUE_COOLTIME]
      + FromBuff;
  end
  else
    cdr := CdrTax + FromBuff;
end;

class procedure TAttributeFunctions.GetPhysicalDamage(var Status: TStatus;
  var BaseStatusAgi: Integer; var BaseStatusStr: Integer; var ChannelId: Byte;
  var FromBuff: Integer; out physicalDamage: Integer);
var
  aPhysicalDamage: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  aPhysicalDamage := 0;
  BaseValue := 2.62;
  HighValue := 1.31;
  var
  statusPhys := 0;
  if (BaseStatusStr > 0) then
  begin
    statusPhys := BaseStatusStr;
  end
  else
    statusPhys := BaseStatusAgi;

  if (statusPhys <= 500) then
  begin
    aPhysicalDamage := Ceil(statusPhys * BaseValue);
  end
  else
  begin
    aPhysicalDamage := aPhysicalDamage +
      Ceil(500 * BaseValue + (statusPhys - 500) * HighValue);
  end;

  physicalDamage := aPhysicalDamage // rlk de atk fisico;
end;

class procedure TAttributeFunctions.GetMagicalDamage(var Status: TStatus;
  var ChannelId: Byte; var FromBuff: Integer; out magicalDamage: Integer);
var
  aMagicalDamage: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  aMagicalDamage := 0;
  BaseValue := 2.62;
  HighValue := 1.31;
  if (Status.Int <= 500) then
  begin
    aMagicalDamage := Ceil(Status.Int * BaseValue);
  end
  else
    aMagicalDamage := aMagicalDamage + Ceil(500 * BaseValue + (Status.Int - 500)
      * HighValue);

  magicalDamage := aMagicalDamage // rlk de atk magico;
end;

class procedure TAttributeFunctions.GetHP(var Status: TStatus; out hp: Integer);
var
  aHP: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  aHP := 0;
  BaseValue := 27.5;
  HighValue := 13.75;
  if (Status.Cons <= 500) then
  begin
    aHP := Ceil(Status.Cons * BaseValue);
  end
  else
    aHP := aHP + Ceil(500 * BaseValue + (Status.Cons - 500) * HighValue);

    hp := aHP;
end;

class procedure TAttributeFunctions.GetHPRegen(var Status: TStatus;
  var FromBuff: Integer; out hpRegen: Integer);
var
  aHPRegen: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  aHPRegen := 0;
  BaseValue := 3;
  HighValue := 1.5;
  if (Status.Cons <= 500) then
  begin
    aHPRegen := Ceil(Status.Cons * BaseValue);
  end
  else
    aHPRegen := aHPRegen + Ceil(500 * BaseValue + (Status.Cons - 500) *
      HighValue);

  hpRegen := aHPRegen + FromBuff;
end;

class procedure TAttributeFunctions.GetMP(var Status: TStatus; out mp: Integer);
var
  aMP: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  aMP := 0;
  BaseValue := 27.5;
  HighValue := 13.75;
  if (Status.Luck <= 500) then
  begin
    aMP := Ceil(Status.Luck * BaseValue);
  end
  else
    aMP := aMP + Ceil(500 * BaseValue + (Status.Luck - 500) * HighValue);

  mp := aMP;
end;

class procedure TAttributeFunctions.GetMPRegen(var Status: TStatus;
  var FromBuff: Integer; out mpRegen: Integer);
var
  aMPRegen: WORD;
  BaseValue: System.Double;
  HighValue: System.Double;
begin
  aMPRegen := 0;
  BaseValue := 3;
  HighValue := 1.5;
  if (Status.Luck <= 500) then
  begin
    aMPRegen := Ceil(Status.Luck * BaseValue);
  end
  else
    aMPRegen := aMPRegen + Ceil(500 * BaseValue + (Status.Luck - 500) *
      HighValue);

  mpRegen := aMPRegen + FromBuff;
end;

end.
