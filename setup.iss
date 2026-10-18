; ==================================================
#define AppVersion "3.3.0"
#define BuildNumber "144"
; ==================================================

#define FullVersion AppVersion + "." + BuildNumber

[Setup]
AppName=Solian
AppVersion={#AppVersion}
AppPublisher=Solsynth
AppPublisherURL=https://solsynth.dev
AppSupportURL=https://kb.solsynth.dev/zh/solar-network
AppUpdatesURL=https://github.com/Solsynth/Solian/releases
AppCopyright=Copyright © 2025 Solsynth
VersionInfoVersion={#FullVersion}
UninstallDisplayName=Solian
UninstallDisplayIcon={app}\Solian.exe

DefaultDirName={commonpf}\Solian
; Reuse the directory of an existing installation so an unattended update
; (/SILENT) replaces the same files the running build came from.
UsePreviousAppDir=yes

OutputDir=.\Installer
OutputBaseFilename=windows-x86_64-setup
SetupIconFile=.\assets\icons\icon.ico  

Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=4

ArchitecturesAllowed=x64compatible
PrivilegesRequired=admin

[Files]
Source: ".\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Solian"; Filename: "{app}\Solian.exe";IconFilename: "{app}\Solian.exe"
Name: "{group}\{cm:UninstallProgram,Solian}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Solian"; Filename: "{app}\Solian.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\Solian.exe"; Description: "Launch Solian"; Flags: nowait postinstall skipifsilent
; The updater runs this installer with /SILENT, and Setup closes the running
; Solian through the Restart Manager before replacing its files. Nothing is
; left on screen afterwards and RestartApplications cannot bring it back
; (Flutter's Windows runner never calls RegisterApplicationRestart), so relaunch
; the installed build with the original, non-elevated user token.
Filename: "{app}\Solian.exe"; Flags: nowait runasoriginaluser skipifnotsilent

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\dev.solsynth\Solian"
Type: files; Name: "{group}\Solian.lnk" ;
Type: files; Name: "{autodesktop}\Solian.lnk" ;
