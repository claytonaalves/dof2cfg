unit u_Dof2CfgMain;

interface

function Main: integer;

implementation

uses
  Windows,
  SysUtils,
  Classes,
  IniFiles,
  Registry;

procedure ShowHelp(const _Error: string);
begin
  raise Exception.CreateFmt('%s'#13#10 +
    'usage: Dof2Cfg <projectfile>', [_Error]);
end;

procedure ReplaceDelphi(const _Version: string; var _Path: string);
var
  reg: TRegistry;
  Delphi: string;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if (_Version = '5.0') or (_Version = '<unknown>') then begin
      reg.OpenKeyReadOnly('SOFTWARE\Borland\Delphi\5.0');
      Delphi := ExcludeTrailingPathDelimiter(LowerCase(reg.ReadString('RootDir')));
      _Path := StringReplace(_Path, '$(DELPHI)', Delphi, [rfReplaceAll, rfIgnoreCase]);
    end else if _Version = '6.0' then begin
      reg.OpenKeyReadOnly('SOFTWARE\Borland\Delphi\6.0');
      Delphi := ExcludeTrailingPathDelimiter(LowerCase(reg.ReadString('RootDir')));
      _Path := StringReplace(_Path, '$(DELPHI)', Delphi, [rfReplaceAll, rfIgnoreCase]);
    end else if _Version = '7.0' then begin
      reg.OpenKeyReadOnly('SOFTWARE\Borland\Delphi\7.0');
      Delphi := ExcludeTrailingPathDelimiter(LowerCase(reg.ReadString('RootDir')));
      _Path := StringReplace(_Path, '$(DELPHI)', Delphi, [rfReplaceAll, rfIgnoreCase]);
    end;
  finally
    FreeAndNil(reg);
  end;
end;

function FindFirstVariableName(_Path: string): String;
var
  VariableStartPosition: Integer;
  VariableEndPosition: Integer;
  tmpPath: string;
begin
  VariableStartPosition := Pos('$(', _Path)+2;
  tmpPath := Copy(_Path, VariableStartPosition, Length(_Path));
  VariableEndPosition := Pos(')', tmpPath)-1;
  Result := Copy(tmpPath, 1, VariableEndPosition);
end;

procedure ReplaceEnvironmentVariables(var _Path: string);
var
  VariableName: string;
  VariableValue: string;
begin
  while Pos('$(', _Path)>0 do begin
    VariableName := FindFirstVariableName(_Path);
    VariableValue := GetEnvironmentVariable(VariableName);
    _Path := StringReplace(_Path, '$(' + VariableName + ')', VariableValue, [rfReplaceAll, rfIgnoreCase]);
  end;
end;

function Main: integer;
var
  DofFn: string;
  CfgFn: string;
  Dof: TMemIniFile;
  cfg: TStringlist;
  s: string;
  FileVersion: string;
begin
  if ParamCount <> 1 then
    ShowHelp('One parameter is required.');
  s := ParamStr(1);
  if (s = '-?') or SameText(s, '--help') then
    ShowHelp('');

  DofFn := ChangeFileExt(s, '.dof');
  CfgFn := ChangeFileExt(DofFn, '.cfg');
  cfg := nil;
  dof := TMemIniFile.Create(DofFn);
  try
    FileVersion := Dof.ReadString('FileVersion', 'Version', '<unknown>');

    cfg := TStringList.Create;

    // -- $-Switches

    // Record Alignment
    s := Dof.ReadString('Compiler', 'A', '8');
    if s = '0' then
      cfg.Add('-$A-')
    else if s = '1' then begin
      if (FileVersion = '<unknown>') or (FileVersion = '5.0') then
        cfg.Add('-$A+')
      else
        cfg.Add('-$A' + s);
    end else
      cfg.Add('-$A' + s);

    // Bool Eval
    s := Dof.ReadString('Compiler', 'B', '0');
    if s = '0' then
      cfg.Add('-$B-')
    else
      cfg.Add('-$B+');

    // Assertions
    s := Dof.ReadString('Compiler', 'C', '1');
    if s = '0' then
      cfg.Add('-$C-')
    else
      cfg.Add('-$C+');

    // DebugInfo
    s := Dof.ReadString('Compiler', 'D', '1');
    if s = '0' then
      cfg.Add('-$D-')
    else
      cfg.Add('-$D+');

    // unknown, probably never used
    s := Dof.ReadString('Compiler', 'E', '0');
    if s = '0' then
      cfg.Add('-$E-')
    else
      cfg.Add('-$E+');

    // unknown, probably never used
    s := Dof.ReadString('Compiler', 'F', '0');
    if s = '0' then
      cfg.Add('-$F-')
    else
      cfg.Add('-$F+');

    // ImportedData
    s := Dof.ReadString('Compiler', 'G', '1');
    if s = '0' then
      cfg.Add('-$G-')
    else
      cfg.Add('-$G+');

    // LongStrings
    s := Dof.ReadString('Compiler', 'H', '1');
    if s = '0' then
      cfg.Add('-$H-')
    else
      cfg.Add('-$H+');

    // IOChecking
    s := Dof.ReadString('Compiler', 'I', '1');
    if s = '0' then
      cfg.Add('-$I-')
    else
      cfg.Add('-$I+');

    // WritableConsts
    s := Dof.ReadString('Compiler', 'J', '0');
    if s = '0' then
      cfg.Add('-$J-')
    else
      cfg.Add('-$J+');

    // Unknown, probably never used
    s := Dof.ReadString('Compiler', 'K', '0');
    if s = '0' then
      cfg.Add('-$K-')
    else
      cfg.Add('-$K+');

    // LocalDebugSymbols
    s := Dof.ReadString('Compiler', 'L', '1');
    if s = '0' then
      cfg.Add('-$L-')
    else
      cfg.Add('-$L+');

    // RuntimeTypeInfo
    s := Dof.ReadString('Compiler', 'M', '0');
    if s = '0' then
      cfg.Add('-$M-')
    else
      cfg.Add('-$M+');

    // Unknown, probably never used
    s := Dof.ReadString('Compiler', 'N', '0');
    if s = '0' then
      cfg.Add('-$N-')
    else
      cfg.Add('-$N+');

    // Optimization
    s := Dof.ReadString('Compiler', 'O', '1');
    if s = '0' then
      cfg.Add('-$O-')
    else
      cfg.Add('-$O+');

    // OpenStringParams
    s := Dof.ReadString('Compiler', 'P', '1');
    if s = '0' then
      cfg.Add('-$P-')
    else
      cfg.Add('-$P+');

    // IntegerOverflowChecking
    s := Dof.ReadString('Compiler', 'Q', '0');
    if s = '0' then
      cfg.Add('-$Q-')
    else
      cfg.Add('-$Q+');

    // RangeChecking
    s := Dof.ReadString('Compiler', 'R', '0');
    if s = '0' then
      cfg.Add('-$R-')
    else
      cfg.Add('-$R+');

    // Unknown, probably never used
    s := Dof.ReadString('Compiler', 'S', '0');
    if s = '0' then
      cfg.Add('-$S-')
    else
      cfg.Add('-$S+');

    // Typed @ operator
    s := Dof.ReadString('Compiler', 'T', '0');
    if s = '0' then
      cfg.Add('-$T-')
    else
      cfg.Add('-$T+');

    // PentiumSaveDivide
    s := Dof.ReadString('Compiler', 'U', '0');
    if s = '0' then
      cfg.Add('-$U-')
    else
      cfg.Add('-$U+');

    // StrictVarStrings
    s := Dof.ReadString('Compiler', 'V', '1');
    if s = '0' then
      cfg.Add('-$V-')
    else
      cfg.Add('-$V+');

    // GenerateStackFrames
    s := Dof.ReadString('Compiler', 'W', '0');
    if s = '0' then
      cfg.Add('-$W-')
    else
      cfg.Add('-$W+');

    // ExtendedSyntax
    s := Dof.ReadString('Compiler', 'X', '1');
    if s = '0' then
      cfg.Add('-$X-')
    else
      cfg.Add('-$X+');

    // SymbolReferenceInfo
    s := Dof.ReadString('Compiler', 'Y', '2');
    if s = '0' then
      cfg.Add('-$Y-')
    else if s = '1' then
      cfg.Add('-$YD')
    else
      cfg.Add('-$Y+');

    // Minimum Size of Enum
    s := Dof.ReadString('Compiler', 'Z', '1');
    cfg.Add('-$Z' + s);

    // -- no '$' options

    // MapFile
    s := Dof.ReadString('Linker', 'MapFile', '0');
    if s = '1' then
      cfg.Add('-GS') // with segements
    else if s = '2' then
      cfg.Add('-GP') // with publics
    else if s = '3' then begin
      cfg.Add('-GD'); // detailed
      cfg.Add('-GP'); // with publics
    end else
      ; // no map file

    // OutputObjs
    s := Dof.ReadString('Linker', 'OutputObjs', '0');
    if s = '9' then
      cfg.Add('-J') // C object files
    else if s = '10' then
      cfg.Add('-JP') // C++ object files
    else if s = '14' then
      cfg.Add('-JPN') // C++ object files + Namespaces
    else if s = '30' then
      cfg.Add('-JPNE') // C++ object files + Namespaces + all symbols
    else if s = '26' then
      cfg.Add('-JPE') // C++ object files + all symbols
    else
      ; // no object files

    // ConsoleApp (dcc help output seems to be wrong)
    s := Dof.ReadString('Linker', 'ConsoleApp', '1');
    if s = '1' then
      cfg.Add('-cg')
    else
      cfg.Add('-cc');

    // remote debug info
    s := Dof.ReadString('Linker', 'RemoteSymbols', '0');
    if s = '1' then
      cfg.Add('-vr');

    // UnitAliases
    s := Dof.ReadString('Compiler', 'UnitAliases', '');
    cfg.Add('-A' + s);

    // ShowHints
    s := Dof.ReadString('Compiler', 'ShowHints', '1');
    if s = '1' then
      cfg.Add('-H+');

    // ShowWarnings
    s := Dof.ReadString('Compiler', 'ShowWarnings', '1');
    if s = '1' then
      cfg.Add('-W+');

    // Make modified units - seems to be always there
    cfg.Add('-M');

    // StackSize (also -$M)
    s := Dof.ReadString('Linker', 'MinStackSize', '16384');
    s := s + ',' + Dof.ReadString('Linker', 'MaxStackSize', '1048576');
    cfg.Add('-$M' + s);

    // ImageBase
    s := Dof.ReadString('Linker', 'ImageBase', '4194304');
    cfg.Add('-K$' + Format('%.8x', [StrToInt(s)]));

    // (Exe)OutputDir
    s := Dof.ReadString('Directories', 'OutputDir', '');
    cfg.Add('-E"' + s + '"');

    // UnitOutputDir
    s := Dof.ReadString('Directories', 'UnitOutputDir', '');
    cfg.Add('-N"' + s + '"');

    // BplOutputDir
    s := Dof.ReadString('Directories', 'PackageDLLOutputDir', '');
    cfg.Add('-LE"' + s + '"');

    // DcpOutputDir
    s := Dof.ReadString('Directories', 'PackageDCPOutputDir', '');
    cfg.Add('-LN"' + s + '"');

    // Unit directories
    s := Dof.ReadString('Directories', 'SearchPath', '');
    ReplaceDelphi(FileVersion, s);
    ReplaceEnvironmentVariables(s);
    cfg.Add('-U"' + s + '"');

    // Object directories
    s := Dof.ReadString('Directories', 'SearchPath', '');
    ReplaceDelphi(FileVersion, s);
    ReplaceEnvironmentVariables(s);
    cfg.Add('-O"' + s + '"');

    // IncludeDirs
    s := Dof.ReadString('Directories', 'SearchPath', '');
    ReplaceDelphi(FileVersion, s);
    ReplaceEnvironmentVariables(s);
    cfg.Add('-I"' + s + '"');

    // look for 8.3 filenames - never used
    // cfg.Add('-P');

    // Quiet compile - never used
    // cfg.Add('-Q');

    // Resource directories
    s := Dof.ReadString('Directories', 'SearchPath', '');
    ReplaceDelphi(FileVersion, s);
    ReplaceEnvironmentVariables(s);
    cfg.Add('-R"' + s + '"');

    // Conditionals
    s := Dof.ReadString('Directories', 'Conditionals', '');
    cfg.Add('-D' + s);

    // DebugInfo in exe
    s := Dof.ReadString('Linker', 'DebugInfo', '0');
    if s = '1' then
      cfg.Add('-vn');

    // Output 'never build' DCPs - (not supported, cannot be read from .dof)
    // cfg.Add('-Z');

    // -- Runtime package support
    s := Dof.ReadString('Directories', 'UsePackages', '');
    if s = '1' then begin
      s := Dof.ReadString('Directories', 'Packages', '');
      cfg.Add('-LU' + s);
    end;

//    cfg.WriteBOM := False;
    Cfg.SaveToFile(CfgFn);

  finally
    FreeAndNil(cfg);
    FreeAndNil(dof);
  end;
  Result := 0
end;

end.

