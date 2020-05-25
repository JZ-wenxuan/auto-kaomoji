#SingleInstance, force
#MaxThreadsPerHotkey 255
#NoTrayIcon

PageSize := 8

; Clip() - Send and Retrieve Text Using the Clipboard
; by berban - updated February 18, 2019
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
Clip(Text="", Reselect="")
{
  Static BackUpClip, Stored, LastClip
  If (A_ThisLabel = A_ThisFunc) {
    If (Clipboard == LastClip)
      Clipboard := BackUpClip
    BackUpClip := LastClip := Stored := ""
  } Else {
    If !Stored {
      Stored := True
      BackUpClip := ClipboardAll ; ClipboardAll must be on its own line
    } Else
      SetTimer, %A_ThisFunc%, Off
    LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
    If (Text = "") {
      SendInput, ^c
      ClipWait, LongCopy ? 0.6 : 0.2, True
    } Else {
      Clipboard := LastClip := Text
      ClipWait, 10
      SendInput, ^v
    }
    SetTimer, %A_ThisFunc%, -700
    Sleep 20 ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
    If (Text = "")
      Return LastClip := Clipboard
    Else If ReSelect and ((ReSelect = True) or (StrLen(Text) < 3000))
      SendInput, % "{Shift Down}{Left " StrLen(StrReplace(Text, "`r")) "}{Shift Up}"
  }
  Return
  Clip:
  Return Clip()
}

Gui +LastFound +AlwaysOnTop -Caption +ToolWindow +HwndKaomojiGuiHwnd +DelimiterTab
Gui, Margin, 0, 0
Gui, Add, ListBox, r%PageSize% vKaomojiBox gSelectKaomoji,
KaomojiCount := 0
Loop, Read, Kaomoji.txt, UTF-8
{
  GuiControl,, KaomojiBox, %A_LoopReadLine%
  KaomojiCount += 1
}

GuiActive := false
KaomojiSelected := 0

+!x::
  GoSub, ShowPanel
return

SelectKaomoji:
  Gui, Submit
  Clip(KaomojiBox)
  ; SendInput % KaomojiBox
  GoSub, HidePanel
return

ShowPanel:
  CoordMode, mouse, Screen
  MouseGetPos, MouseX, MouseY
  Gui, Show, x%MouseX% y%MouseY% NoActivate, KaomojiPanel
  GuiActive := true
  KaomojiSelected := 1
  GuiControl, Choose, KaomojiBox, 1
return

HidePanel:
  Gui, Hide
  GuiActive := false
return

ChangeSelection:
  if (KaomojiSelected <= 0) {
    KaomojiSelected := mod(KaomojiSelected, KaomojiCount) + KaomojiCount
  } else if (KaomojiSelected > KaomojiCount) {
    KaomojiSelected := mod(KaomojiSelected - 1, KaomojiCount) + 1
  }
  GuiControl, Choose, KaomojiBox, %KaomojiSelected%
return

; Quick Reload for development
; +!r::
;   Reload
; return

#If GuiActive
Up::
WheelUp::
  KaomojiSelected -= 1
  GoSub, ChangeSelection
return

Left::
  KaomojiSelected -= PageSize
  GoSub, ChangeSelection
return

Down::
WheelDown::
  KaomojiSelected += 1
  GoSub, ChangeSelection
return

Right::
  KaomojiSelected += PageSize
  GoSub, ChangeSelection
return

Tab::
Space::
Enter::
MButton::
  GoSub, SelectKaomoji
return

Escape::
~RButton::
  GoSub, HidePanel
return

~LButton::
  MouseGetPos, , , MouseWin
  ; Hide Panel if clicked outside
  if (MouseWin != KaomojiGuiHwnd) {
    GoSub, HidePanel
  }
return