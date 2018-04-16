#define MyAppName "VRTK %{codename}"
#define MyAppVersion "%{version}"
#define MyAppPublisher "MRAKOBEZE"
#define PkgDir "%{pkg_dir}"
#define InputDir "%{input_dir}"
#define FileBasename "%{out_file}"
#define MyAppURL "http://mrakobeze.github.io/vrtk"

[Setup]
AppId={{74DC58F0-8F53-4F23-AF1B-8CE9162F8B98}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf64}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir={#PkgDir}
OutputBaseFilename={#FileBasename}
Compression=lzma
ChangesEnvironment=yes
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Files]
Source: "{#InputDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; AfterInstall: AddPath(ExpandConstant('{app}'))

[Code]

procedure AddPath(NewPath: String);
var
  PathStr: String;
begin
  RegQueryStringValue(HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', PathStr);
  if Pos(NewPath, PathStr) <= 0 then 
  begin
    PathStr := NewPath + ';' + PathStr;
    RegWriteStringValue(HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', PathStr);
  end;
end;

procedure PurgePath(OldPath: String);
var
  PathStr: String;
  StartPos, Len: Integer;
begin
  RegQueryStringValue(HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', PathStr);

  StartPos := Pos(OldPath + ';', PathStr);
  if StartPos > 0 then 
  begin
    Len := Length(OldPath + ';');   
    Delete(PathStr, StartPos, Len); 
    RegWriteStringValue(HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', PathStr);
    Exit;
  end;


  StartPos := Pos(OldPath, PathStr);
  if StartPos > 0 then
  begin
    Len := Length(OldPath); 
    Delete(PathStr, StartPos, Len); 
    RegWriteStringValue(HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', PathStr);
  end;
end;