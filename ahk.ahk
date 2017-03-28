; generic warning box that pops when
; user attempts to use a 'stretch' hotkey
HotkeyWarning()
{
	MsgBox, No one-handed hotkeys!
}
ToggleLyndaPause(){
  ;ControlSend, ,{space}, Lynda.com ; can't get this to work!
  WinGet, original, ID, A
  WinActivate, .*Lynda.com.*
  Send {Space}
  WinActivate, ahk_id %original%
}

; current window activators for frequently used programs
SetTitleMatchMode, RegEx

#!a:: WinActivate, .*Anki.*
#!p:: WinActivate, .*Windows PowerShell.*|posh.*
#!v:: WinActivate, .*Microsoft Visual Studio.*
#!j:: WinActivate, .*Mozilla Firefox$
#!s:: WinActivate, .*Sublime Text 2.*
#!h:: WinActivate, .*HexChat.*
#!c:: WinActivate, .*Visual Studio Code.*
#!l:: WinActivate, .*Lynda.com.*
#!o::ToggleLyndaPause()


; launch the windows snipping tool
#!n::
Run, snippingtool
WinWaitActive, ahk_class Microsoft-Windows-Tablet-SnipperToolbar
{
    send ^{PrintScreen}
}
return


; keyboard remapping (for regular typing)
$z::Send b
$+z::Send B
$b::Send p
$+b::Send P
$p::Send z
$+p::Send Z

$t::Send j
$+t::Send J
$j::Send t
$+j::Send T

$n::Send k
$+n::Send K
$k::Send n
$+k::Send N

; semi-colon key acts as R except when CapsLock is depressed.
; This allows CapsLock-;-CapsLock as end-;-return combo.

$;::
if GetKeyState("CapsLock", "p")
  send, `;
else
  send, r
Return

$+;::Send R

$r::Send `;
$+r::Send :

$o::Send v
$+o::Send V
$v::Send d
$+v::Send D
$d::Send o
$+d::Send O

; $f::Send r
; F::R
; $r::Send f
; R::F

CapsLock::
if GetKeyState("LCtrl", "p")
  send, {CapsLock}
else if GetKeyState(";", "p")
  send, {Enter}
else
  send, {End}
Return

; alt + alt -> escape. specifically in place for
; mode switching in vim
<!RAlt::Send {Escape}
>!LAlt::Send {Escape}


/*
Hotkeys here effect physical keys as written, and do not
'respect' the swaps put in place by the keyboard remapping
*/

; ^ - Ctrl
; ! - Alt

; left handed hotkeys to avoid
<^s::HotkeyWarning()
<^c::HotkeyWarning()
<^v::HotkeyWarning()
<^x::HotkeyWarning()
<^z::HotkeyWarning()
<^f::HotkeyWarning()
<^t::HotkeyWarning()
<^F4::HotkeyWarning()
<!F4::HotkeyWarning()

; right handed hotkeys to avoid
>^o::HotkeyWarning()
>^l::HotkeyWarning()
>^k::HotkeyWarning()
>^p::HotkeyWarning()
>^m::HotkeyWarning() ; vs
>^,::HotkeyWarning() ; vs
>^.::HotkeyWarning() ; vs

; suspend / resume hotkeys
#!Pause::Suspend
