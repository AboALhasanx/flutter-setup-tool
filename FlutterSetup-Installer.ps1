# ================================================================
# FlutterSetup-Installer.ps1
# Flutter Dev Setup for Windows 10/11
# Android + Web only | Run as Administrator
# ================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Flutter Dev Setup"

function Write-Banner {
    Clear-Host
    $c1=[char]27+"[96m"; $c2=[char]27+"[92m"; $c3=[char]27+"[93m"; $rs=[char]27+"[0m"
    Write-Host ""
    Write-Host "${c1}  ███████╗██╗     ██╗   ██╗████████╗████████╗███████╗██████╗ ${rs}"
    Write-Host "${c1}  ██╔════╝██║     ██║   ██║╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗${rs}"
    Write-Host "${c2}  █████╗  ██║     ██║   ██║   ██║      ██║   █████╗  ██████╔╝${rs}"
    Write-Host "${c2}  ██╔══╝  ██║     ██║   ██║   ██║      ██║   ██╔══╝  ██╔══██╗${rs}"
    Write-Host "${c3}  ██║     ███████╗╚██████╔╝   ██║      ██║   ███████╗██║  ██║${rs}"
    Write-Host "${c3}  ╚═╝     ╚══════╝ ╚═════╝    ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝${rs}"
    Write-Host ""
    Write-Host "${c2}  ════════════════════════════════════════════════════════${rs}"
    Write-Host "${c2}    Android + Web Setup  |  Windows 10/11  |  Auto Setup  ${rs}"
    Write-Host "${c2}  ════════════════════════════════════════════════════════${rs}"
    Write-Host ""
}

function Write-Step([int]$n,[string]$t,[string]$msg) {
    Write-Host ""
    Write-Host "$([char]27)[96m  +----------------------------------------------+$([char]27)[0m"
    Write-Host "$([char]27)[96m  |$([char]27)[97m  STEP $n/$t  $msg$(' ' * [Math]::Max(0,33-$msg.Length))$([char]27)[96m|$([char]27)[0m"
    Write-Host "$([char]27)[96m  +----------------------------------------------+$([char]27)[0m"
}

function Write-OK([string]$m)   { Write-Host "  $([char]27)[92m[OK] $m$([char]27)[0m" }
function Write-INFO([string]$m) { Write-Host "  $([char]27)[93m[..] $m$([char]27)[0m" }
function Write-FAIL([string]$m) { Write-Host "  $([char]27)[91m[!!] $m$([char]27)[0m" }

function Write-Done {
    Write-Host ""
    Write-Host "$([char]27)[92m  +======================================================+$([char]27)[0m"
    Write-Host "$([char]27)[92m  |   Flutter Dev Environment Ready!                    |$([char]27)[0m"
    Write-Host "$([char]27)[92m  |                                                      |$([char]27)[0m"
    Write-Host "$([char]27)[92m  |  Next steps:                                         |$([char]27)[0m"
    Write-Host "$([char]27)[92m  |  1. Connect Android phone via USB                    |$([char]27)[0m"
    Write-Host "$([char]27)[92m  |  2. Enable USB Debugging on phone                    |$([char]27)[0m"
    Write-Host "$([char]27)[93m  |  3. Open NEW terminal and run:                       |$([char]27)[0m"
    Write-Host "$([char]27)[93m  |     > flutter doctor                                 |$([char]27)[0m"
    Write-Host "$([char]27)[93m  |     > flutter run                                    |$([char]27)[0m"
    Write-Host "$([char]27)[92m  +======================================================+$([char]27)[0m"
    Write-Host ""
}

# Admin Check
Write-Banner
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-FAIL "Please run as Administrator!"
    Write-INFO "Right-click the file > Run with PowerShell as Administrator"
    pause; exit 1
}
Write-OK "Running as Administrator"

# STEP 1: Git
Write-Step 1 7 "Installing Git"
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-OK "Git already installed"
} else {
    Write-INFO "Installing Git..."
    winget install --id Git.Git -e --source winget --silent --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")+";"+[System.Environment]::GetEnvironmentVariable("Path","User")
    Write-OK "Git installed"
}

# STEP 2: JDK 17
Write-Step 2 7 "Installing JDK 17"
if (Get-Command java -ErrorAction SilentlyContinue) {
    Write-OK "Java already installed"
} else {
    Write-INFO "Installing JDK 17 (Microsoft)..."
    winget install --id Microsoft.OpenJDK.17 -e --source winget --silent --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")+";"+[System.Environment]::GetEnvironmentVariable("Path","User")
    Write-OK "JDK 17 installed"
}

# STEP 3: Flutter SDK
Write-Step 3 7 "Installing Flutter SDK"
if (Test-Path "C:\flutter\bin\flutter.bat") {
    Write-OK "Flutter already installed"
} else {
    Write-INFO "Downloading Flutter stable (this takes a few minutes)..."
    $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.3-stable.zip"
    $zip = "$env:TEMP\flutter.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Write-INFO "Extracting to C:\flutter..."
    Expand-Archive -Path $zip -DestinationPath "C:\" -Force
    Remove-Item $zip -Force
    Write-OK "Flutter installed at C:\flutter"
}
$mp = [System.Environment]::GetEnvironmentVariable("Path","Machine")
if ($mp -notlike "*C:\flutter\bin*") {
    [System.Environment]::SetEnvironmentVariable("Path","$mp;C:\flutter\bin","Machine")
    $env:Path += ";C:\flutter\bin"
    Write-OK "Flutter added to PATH"
}

# STEP 4: Android SDK
Write-Step 4 7 "Installing Android SDK"
$ah = "$env:LOCALAPPDATA\Android\Sdk"
$ct = "$ah\cmdline-tools\latest\bin"
if (Test-Path "$ct\sdkmanager.bat") {
    Write-OK "Android SDK already installed"
} else {
    Write-INFO "Downloading Android Command Line Tools..."
    $url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $zip = "$env:TEMP\cmdtools.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    New-Item -ItemType Directory -Force -Path "$ah\cmdline-tools" | Out-Null
    Expand-Archive -Path $zip -DestinationPath "$ah\cmdline-tools" -Force
    if (Test-Path "$ah\cmdline-tools\cmdline-tools") {
        Rename-Item "$ah\cmdline-tools\cmdline-tools" "latest" -ErrorAction SilentlyContinue
    }
    Remove-Item $zip -Force
    Write-OK "Android tools extracted"
}
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME",$ah,"Machine")
$env:ANDROID_HOME = $ah
$mp = [System.Environment]::GetEnvironmentVariable("Path","Machine")
if ($mp -notlike "*cmdline-tools*") {
    [System.Environment]::SetEnvironmentVariable("Path","$mp;$ct;$ah\platform-tools","Machine")
    $env:Path += ";$ct;$ah\platform-tools"
}
Write-INFO "Installing SDK components (android-35, build-tools, platform-tools)..."
"y" | & "$ct\sdkmanager.bat" --sdk_root=$ah "platform-tools" "platforms;android-35" "build-tools;35.0.0" 2>&1 | Out-Null
Write-INFO "Accepting all licenses automatically..."
("y`n"*10) | & "$ct\sdkmanager.bat" --sdk_root=$ah --licenses 2>&1 | Out-Null
& "C:\flutter\bin\flutter.bat" config --android-sdk $ah 2>&1 | Out-Null
Write-OK "Android SDK ready"

# STEP 5: Gradle Global Config
Write-Step 5 7 "Configuring Gradle (Global)"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.gradle" | Out-Null
$gc = "org.gradle.daemon=true`norg.gradle.parallel=true`norg.gradle.caching=true`norg.gradle.jvmargs=-Xmx3072m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError"
Set-Content -Path "$env:USERPROFILE\.gradle\gradle.properties" -Value $gc -Encoding UTF8
Write-OK "Global Gradle configured (applies to ALL future projects)"

# STEP 6: VS Code + Flutter Extension
Write-Step 6 7 "Installing VS Code + Flutter"
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-INFO "Installing VS Code..."
    winget install --id Microsoft.VisualStudioCode -e --source winget --silent --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")+";"+[System.Environment]::GetEnvironmentVariable("Path","User")
    Write-OK "VS Code installed"
} else { Write-OK "VS Code already installed" }
Start-Sleep 3
try {
    & code --install-extension Dart-Code.flutter --force 2>&1 | Out-Null
    & code --install-extension Dart-Code.dart-code --force 2>&1 | Out-Null
    Write-OK "Flutter + Dart VS Code extensions installed"
} catch { Write-INFO "Install Flutter extension manually from VS Code marketplace" }

# STEP 7: Flutter Template
Write-Step 7 7 "Creating Flutter Project Template"
$tp = "$env:USERPROFILE\Documents\flutter_template"
if (-not (Test-Path "$tp\pubspec.yaml")) {
    Write-INFO "Creating template project (Android + Web only)..."
    Push-Location "$env:USERPROFILE\Documents"
    & "C:\flutter\bin\flutter.bat" create --empty --platforms=android,web flutter_template 2>&1 | Out-Null

    # Gradle settings for template
    Set-Content -Path "$tp\android\gradle.properties" -Value $gc -Encoding UTF8

    # Clean main.dart
    $md = @'
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // run: flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Hello, World!')),
      ),
    );
  }
}
'@
    Set-Content -Path "$tp\lib\main.dart" -Value $md -Encoding UTF8

    # pubspec.yaml with common packages
    $ps = @'
name: flutter_template
description: Flutter Template - Android & Web
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.7.0
  firebase_auth: ^6.4.0
  cloud_firestore: ^6.3.0
  firebase_storage: ^13.3.0
  go_router: ^17.2.3
  provider: ^6.1.2
  http: ^1.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
'@
    Set-Content -Path "$tp\pubspec.yaml" -Value $ps -Encoding UTF8

    Set-Location $tp
    & "C:\flutter\bin\flutter.bat" pub get 2>&1 | Out-Null
    Pop-Location
    Write-OK "Template created: Documents\flutter_template"
} else { Write-OK "Template already exists at Documents\flutter_template" }

# Done!
Write-Done

Write-Host "$([char]27)[96m  --- Create new project from template ---$([char]27)[0m"
Write-Host ""
Write-Host '  $name = "MyNewApp"'
Write-Host '  Copy-Item -Path "$env:USERPROFILE\Documents\flutter_template" -Destination "C:\projects\$name" -Recurse'
Write-Host '  cd "C:\projects\$name"'
Write-Host '  flutter create --project-name ($name.ToLower()) .'
Write-Host '  flutter pub get'
Write-Host '  flutter run'
Write-Host ""
Write-Host "$([char]27)[96m  Press any key to exit...$([char]27)[0m"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
