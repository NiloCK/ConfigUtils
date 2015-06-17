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
Z::P
$p::Send z
P::Z

$t::Send j
T::J
$j::Send t
J::T

$n::Send k
N::K
$k::Send n
K::N

$o::Send d
O::D
$d::Send o
D::O

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
