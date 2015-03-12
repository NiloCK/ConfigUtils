SetTitleMatchMode, RegEx

#!p:: WinActivate, .*Windows PowerShell.*|posh.*
#!v:: WinActivate, .*Microsoft Visual Studio.*
#!j:: WinActivate, .*Mozilla Firefox$
#!s:: WinActivate, .*Sublime Text 2.*
#!o:: WinActivate, .*Microsoft Outlook.*

CapsLock::
if GetKeyState("LCtrl", "p")
  send, {CapsLock}
else if GetKeyState(";", "p")
  send, {Enter}
else
  send, {End}
Return