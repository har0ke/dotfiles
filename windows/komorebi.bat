komorebic stop
taskkill /IM whkd.exe /IM komorebi.exe /IM komorebi-bar.exe /IM masir.exe /F
powershell Start-Process C:\Users\OkeHargens\AppData\Local\FlowLauncher\Flow.Launcher.exe
powershell Start-Process masir  -WindowStyle hidden
komorebic start --whkd --bar
komorebic toggle-window-container-behaviour
