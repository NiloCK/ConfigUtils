; generic warning box that pops when 
; user attempts to use a 'stretch' hotkey
HotkeyWarning()
{
	MsgBox, No one-handed hotkeys!
}

; current window activators for frequently used programs
SetTitleMatchMode, RegEx

#!a:: WinActivate, .*Atom.*
#!p:: WinActivate, .*Windows PowerShell.*|posh.*
#!v:: WinActivate, .*Microsoft Visual Studio.*
#!j:: WinActivate, .*Mozilla Firefox$
#!s:: WinActivate, .*Sublime Text 2.*
#!o:: WinActivate, .*Microsoft Outlook.*
#!h:: WinActivate, .*HexChat.*
#!c:: WinActivate, .*Visual Studio Code.*


; keyboard remapping (for regular typing)
$z::Send p
$+z::Send p
$p::Send z
$+p::Send z

$t::Send j
$+t::Send j
$j::Send t
$+j::Send t

$n::Send k
$+n::Send k
$k::Send n
$+k::Send n

$o::Send v
$+o::Send v
$v::Send d
$+v::Send d
$d::Send o
$+d::Send o

; $f::Send r
; F::R
; $r::Send f
; R::F



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

CapsLock::
if GetKeyState("LCtrl", "p")
  send, {CapsLock}
else if GetKeyState(";", "p")
  send, {Enter}
else
  send, {End}
Return

; suspend / resume hotkeys
#!Pause::Suspend
