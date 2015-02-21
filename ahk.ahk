SetTitleMatchMode, RegEx

#!p:: WinActivate, Windows PowerShell|posh.*
#!v:: WinActivate, .*Microsoft Visual Studio$

CapsLock::
if GetKeyState("LCtrl", "p")
  send, {CapsLock}
else if GetKeyState(";", "p")
  send, {Enter}
else
  send, {End}