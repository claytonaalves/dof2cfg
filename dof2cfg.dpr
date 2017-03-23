program dof2cfg;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  IniFiles,
  u_Dof2CfgMain in 'u_Dof2CfgMain.pas';

begin
  try
    Halt(Main);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

