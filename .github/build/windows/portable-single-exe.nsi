Unicode true
RequestExecutionLevel user
SilentInstall silent
AutoCloseWindow true
CRCCheck on
SetCompressor /SOLID lzma

!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

!ifndef PRODUCT_NAME
  !define PRODUCT_NAME "Techmino"
!endif
!ifndef APP_EXE
  !define APP_EXE "Techmino.exe"
!endif
!ifndef OUTPUT_EXE
  !error "OUTPUT_EXE must be defined"
!endif
!ifndef PAYLOAD_X86
  !error "PAYLOAD_X86 must be defined"
!endif
!ifndef PAYLOAD_X64
  !error "PAYLOAD_X64 must be defined"
!endif
!ifndef ICON_PATH
  !error "ICON_PATH must be defined"
!endif
!ifndef VERSION_STRING
  !define VERSION_STRING "0.0.0"
!endif
!ifndef FILE_VERSION
  !define FILE_VERSION "0.0.0.0"
!endif

Name "${PRODUCT_NAME}"
OutFile "${OUTPUT_EXE}"
Icon "${ICON_PATH}"
BrandingText "${PRODUCT_NAME}"

VIProductVersion "${FILE_VERSION}"
VIAddVersionKey /LANG=1033 "CompanyName" "26F Studio"
VIAddVersionKey /LANG=1033 "FileDescription" "${PRODUCT_NAME} portable single-file launcher"
VIAddVersionKey /LANG=1033 "FileVersion" "${VERSION_STRING}"
VIAddVersionKey /LANG=1033 "InternalName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Copyright © 2019-2023 26F-Studio. Some Rights Reserved."
VIAddVersionKey /LANG=1033 "OriginalFilename" "${PRODUCT_NAME}_Windows.exe"
VIAddVersionKey /LANG=1033 "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=1033 "ProductVersion" "${VERSION_STRING}"

Var LaunchArgs
Var ExtractDir
Var ExitCode
Var RequestedArch

Section
  ${GetParameters} $LaunchArgs
  ${GetOptions} $LaunchArgs "/EXTRACT=" $ExtractDir
  ${GetOptions} $LaunchArgs "/ARCH=" $RequestedArch

  ${If} $ExtractDir == ""
    InitPluginsDir
    SetOutPath "$PLUGINSDIR"
  ${Else}
    SetOutPath "$ExtractDir"
  ${EndIf}

  ; /ARCH is intentionally honored only by extraction mode. Normal launches always
  ; select the architecture that matches Windows.
  ${If} $ExtractDir != ""
  ${AndIf} $RequestedArch == "x86"
    File /r "${PAYLOAD_X86}\*.*"
  ${ElseIf} $ExtractDir != ""
  ${AndIf} $RequestedArch == "x64"
    File /r "${PAYLOAD_X64}\*.*"
  ${ElseIf} ${RunningX64}
    File /r "${PAYLOAD_X64}\*.*"
  ${Else}
    File /r "${PAYLOAD_X86}\*.*"
  ${EndIf}

  ${If} $ExtractDir != ""
    SetOutPath "$TEMP"
    SetErrorLevel 0
    Quit
  ${EndIf}

  ClearErrors
  ExecWait '"$PLUGINSDIR\${APP_EXE}" $LaunchArgs' $ExitCode
  ${If} ${Errors}
    StrCpy $ExitCode 1
  ${EndIf}

  ; $PLUGINSDIR is deleted automatically when the launcher exits, but only
  ; after the current working directory is moved somewhere else.
  SetOutPath "$TEMP"
  SetErrorLevel $ExitCode
SectionEnd
