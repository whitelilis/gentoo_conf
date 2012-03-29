;; $Id: fvwm-mode.el 114 2006-02-10 19:49:58Z theblackdragon $
;; 
;; Release 1.5.1
;; 
;; Copyright (C) 2005  Bert Geens <bert@lair.be>
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; 
;; Thanks to Scott Andrew Borton for his excellent major mode tutorial, 
;;  to Thomas Adam for providing his vim syntax file for Fvwm which was a great help in creating this mode 
;;  and many others in the emacs and fvwm communities.
;; 
;; Thanks also to Hun for bugreporting and providing patches with added keywords.
;; 
;; ChangeLog:
;; 1.5.2:
;;  - implemented the timestamp function in a more intelligent way, it'll now work each time you save, and not only when you exit emacs with an unsaved file open.
;;  - fixed the font lock to not hilight end of line comments as those are not supported by FVWM even though the effect makes it appear it does in a lot of cases.
;; 1.5.1:
;;  - fixed a typo in fvwm-script-insert-skeleton.
;;  - added keywords
;; 1.5.0:
;;  - added menus for the most common tasks (which is all of them at the moment).
;;  - added completion of fvwm keywords (M-Tab).
;;  - fixed the colouring of start of line comments containg colour definitions.
;;  - insert-last-modified-time now only gets executed when the buffer has actually been changed.
;;  - fixed fvwm-execute-region now also works in XEmacs.
;;  - font-lock is now case insensitive by default, you can change this behaviour by changing the value of the fvwm-keywords-ignore-case variable.
;;  - fixed the limited length of fvwm-execute-region
;;  - added the possibility to insert the skeleton of an FvwmScript, you can access it either from the  menu or run it with fvwm-script-insert-skeleton.
;; 1.4.1:
;;  - fixed a bug in fvwm-script-insert-widget which caused the inserted widget to always be numbered 1.
;; 1.4.0:
;;  - added some typo fixes and keywords with different casing from Hun.
;;  - added a function that inserts the time you last modified the file when you save it.
;;  - fixed the fact that colour codes were no longer coloured, but seen as comments
;;  - added hilighting of "menu shortcuts" (the &x things inside your menus, if you use them of course)
;;  - added functionality to execute FVWM commands (C-c e c) or regions from config files (C-c e r) from within emacs, you need to have the FvwmCommand module running for this to work.
;;  - added the option to execute files containing FVWM commands through the FVWM 'Read' command (C-c e f)
;;  - added a function to insert the skeleton of an FvwmScript widget definition C-c i w), thanks to Hun for the idea.
;; 1.3.0:
;;  - added quite some keywords provided by Hun
;;  - added hilighting of module configuration lines (eg: "*FvwmButtons: Rows 2")
;;  - added a function to insert an FvwmButtons skeleton (C-c i b)
;; 1.2.2:
;;  - fixed yet another bug with the syntax hilighting: forgot the t argument to regexp-opt on a couple of occasions
;;  - added the Test function to the appropriate list (fvwm-functions)
;; 1.2.1:
;;  - fixed a bug where Emacs would colour keywords that were part of a normal string.
;; 1.2.0:
;;  - fixed a color code colouring issue when a colour code appeared at the end of a line
;;  - fixed the bug where comments wouldn't be coloured when there appeared double quotes in the text to comment.
;;  - made sure text between single quotes is also treated as text by fvwm-mode
;; 1.1.0:
;;  - fixed the syntax hilighting, it's now easier to add new keywords as you don't have to rebuild the optimized regular expression yourself.
;;  - added functions to insert skeletons for FVWM menus (C-c i m) and functions (C-c i f).
;;  - added a workaround to keep everything working in emacsen < 22, as there seems to be a limit on the size of the datat regexp-opt can cope with.
;;  - added a require font-lock as otherwise some faces might not be defined on startup, causing an ugly crash on init.
;; 1.0.0:
;;  - initial release
;;  - only does syntax hilighting
;; 
;; TODO:
;; * move some keywords around and add 'new' ones
;; * fix the colouring to be usable with color-theme
;; * hilight user defined functions
;; * speed up generation of the completion list on GNU Emacs < 22 and XEmacs (Emacs 22 uses hash-maps for this, which is _much_ faster...)
;; 
(defvar fvwm-mode-hook nil)

;; -------------------------
;; |       Variables       |
;; -------------------------
(defvar fvwm-last-updated-prefix "# Last edited on ")
(defvar fvwm-time-format-string "%Y/%m/%d - %X") ;See the help for "format-time-string" for more information
(defvar fvwm-last-updated-suffix "                                #")

(defvar fvwm-fvwmcommand-path "/usr/X11R6/bin/FvwmCommand"
  "The path to the FvwmCommand executable, this most probably shouldn't be modified on a default Fvwm installation.")

(defvar fvwm-keywords-force-case t
  "If set fvwm-mode will hilight keywords in a case sensitive way, using the casing used in the FVWM manpages (CamelCase), if not set it will hilight keywords regardless the casing, this is the way FVWM treats the keywords when parsing the configuration file.\n\nThis variable is t by default.")
(defvar fvwm-preload-completions t
  "If you are planning on using completion a lot it might be advisable to set this to t as otherwise you'll experience a delay when trying to use completion for the first time")

;; -------------------------
;; |      Keymappings      |
;; -------------------------
(defvar fvwm-mode-map
  (let ((fvwm-mode-map (make-sparse-keymap)))
    (define-key fvwm-mode-map "\C-cib" 'fvwm-insert-buttons)
    (define-key fvwm-mode-map "\C-cif" 'fvwm-insert-function)
    (define-key fvwm-mode-map "\C-cim" 'fvwm-insert-menu)
    (define-key fvwm-mode-map "\C-ciw" 'fvwm-script-insert-widget)
    (define-key fvwm-mode-map "\C-cec" 'fvwm-execute-command)
    (define-key fvwm-mode-map "\C-cef" 'fvwm-execute-file)
    (define-key fvwm-mode-map "\C-cer" 'fvwm-execute-region)
    (define-key fvwm-mode-map "\M-\t"  'fvwm-complete-keyword)
    fvwm-mode-map)
  "Keymap for FVWM major mode")

;; -------------------------
;; |         Menus         |
;; -------------------------
(easy-menu-define fvwm-menu fvwm-mode-map "FVWM"
  '("FVWM"
    ["Insert Function" fvwm-insert-function t]
    ["Insert FvwmButtons" fvwm-insert-buttons t]
    ["Insert Menu" fvwm-insert-menu t]
    ["-" nil nil]
    ("FvwmScript"
     ["Insert skeleton" fvwm-script-insert-skeleton t]
     ["Insert widget" fvwm-script-insert-widget t])
    ["-" nil nil]
    ("Execute"
     ["Execute command" fvwm-execute-command t]
     ["Execute file" fvwm-execute-file t]
     ["Execute region" fvwm-execute-region t])))

;; -------------------------
;; |     Syntax table      |
;; -------------------------
(defvar fvwm-syntax-table
  ;; We just get rid of all default entries as they interfere with colour coding the config (used this last in revision 65, version 1.3.0)
  (let ((table (copy-syntax-table)))
     (modify-syntax-entry ?\" "_"  table) ;otherwise it messes with comment colouring.
     (modify-syntax-entry ?\- "w"   table) ;otherwise it'll hilight parts of strings containing an FVWM keyword.
    table)
  "FVWM mode syntax table")

;; -------------------------
;; |     Define faces      |
;; -------------------------
(defvar fvwm-special-face 'fvwm-special-face "Special face for fvwm-mode")
(defface fvwm-special-face
  '((((class grayscale) (background light))
     (foreground "DimGray" :bold t :italic t))
    (((class grayscale) (background dark))
     (foreround "LightGray":bold t :italic t))
    (((class color) (background light)) (:foreground "SteelBlue"))
    (((class color) (background dark)) (:foreground "bisque1"))
    ;;(((class color) (background dark)) (:foreground "DarkOrange"))
    (t (:bold t :italic t)))
  "FVWM Mode face used to highlight special keywords."
  :group 'fvwm-faces)

(defvar fvwm-shortcut-key-face 'fvwm-shortcut-key-face "Special face for Fvwm menu shortcuts")
(defface fvwm-shortcut-key-face
  '((((class grayscale) (background light))
     (foreground "DimGray" :bold t :italic t))
    (((class grayscale) (background dark))
     (foreround "LightGray":bold t :italic t))
    (((class color) (background light)) (:foreground "SteelBlue"))
    (((class color) (background dark)) (:foreground "bisque1"))
    (t (:bold t :italic t)))
  "Fvwm Mode mode face used to highlight menu shortcuts."
  :group 'fvwm-faces)

(defvar fvwm-rgb-value-face 'fvwm-rgb-value-face "RGB value face for fvwm-mode")
(defface fvwm-rgb-value-face
  '((((class grayscale) (background light))
     (foreground "DimGray" :bold t :italic t))
    (((class grayscale) (background dark))
     (foreround "LightGray":bold t :italic t))
    (((class color) (background light)) (:foreground "LightSalmon")) ;use same colour as the JDE
    (((class color) (background dark)) (:foreground "LightSalmon"))
    (t (:bold t :italic t)))
  "Fvwm Mode mode face used to highlight RGB value."
  :group 'fvwm-faces)

;; -------------------------
;; |  Syntax highlighting  |
;; -------------------------
(require 'font-lock)
;;
;; Fvwm functions
;; 
(defvar fvwm-functions '(
	"AddButtonStyle" "AddTitleStyle" "AddToDecor" "AddToFunc" "AddToMenu"
	"AnimatedMove" "Any" "AppsBackingStore" "Autoraise" 

	"BackingStore" "Beep" "BorderStyle" "BoundaryWidth" "BugOpts" "BusyCursor"
	"ButtonState" "ButtonStyle" "DestroyModuleConfig"

	"ChangeDecor" "ChangeMenuStyle" "CenterOnCirculate" "CirculateDown"
	"CirculateHit" "CirculateSkip" "CirculateSkipIcons" "CirculateUp" "ClickTime"
	"ClickToFocus" "Close" "ColorLimit" "ColormapFocus" "CopyMenuStyle" "Current"
	"Cursor" "CursorMove" "CursorStyle" 

	"DecorateTransients" "DefaultColors" "DefaultColorset" "DefaultFont"
	"DefaultIcon" "DefaultLayers" "Delete" "Desk" "DesktopName" "DesktopSize"
	"Destroy" "DestroyModule" "Deschedule" "DestroyDecor" "DestroyFunc" "DestroyMenu"
	"DestroyMenuStyle" "Direction" "DontMoveOff"

	"Echo" "EdgeCommand" "EdgeResistance" "EdgeScroll" "EdgeThickness" "Emulate"
	"EndFunction" "EndMenu" "EndPopup" "EscapeFunc" "EWMHBaseStruts" "Exec"
	"ExecUseShell" "ExitFunction"  "EWMHActivateWindowFunc"

	"FakeClick" "FlipFocus" "Focus" "Function"

	"GlobalOpts" "GnomeButton" "GotoDesk" "GotoDenkAndPage" "GotoPage"

	"HiBackColor" "HideGeometryWindow" "HiForeColor" "HilightColor"

	"Icon" "IconBox" "IconFont" "Iconify" "IconPath" "IgnoreModifiers" "ImagePath"

	"Key"

	"Layer" "Lenience" "Lower"

	"Maximize" "Menu" "MenuBackColor" "MenuForeColor" "MenuStippleColor" "MenuStyle"
	"Module" "ModulePath" "Mouse" "Move" "MoveThreshold" "MoveToDesk" "MoveToPage"
	"MoveToScreen" "MWMBorders" "MWMButtons" "MWMDecorHints" "MWMFunctionHints"
	"MWMHintOverride" "MWMMenus"

	"Next" "NoBorder" "NoBoundaryWidth" "None" "Nop" "NoPPosition" "NoTitle"

	"OpaqueMove" "OpaqueMoveSize" "OpaqueResize"

	"Pager" "PagerBackColor" "PagerFont" "PagerForeColor" "PagingDefault" "Pick"
	"PipeRead" "PixmapPath" "PlaceAgain" "PointerKey" "Popup" "Prev"

	"Quit" "QuitScreen" "QuitSession"

	"Raise" "RaiseLower" "RandomPlacement" "Read" "Recapture" "RecaptureWindow"
	"Refresh" "Resize" "ResizeMove" "Restart" 

	"SaveUnders" "SaveQuitSession" "SaveSession" "Scroll" "SetAnimation" "SetEnv" 
	"SetMenuDelay" "SetMenuStyle" "SendToModule" "Silent" "SloppyFocus" "SmartPlacement" "SnapAttraction" 
	"SnapGrid" "StartsOnDesk" "StaysOnTop" "StdBackColor" "StdForeColor" "Stick" "Sticky" 
	"StickyBackColor" "StickyForeColor" "StickyIcons" "Stroke" "StrokeFunc" 
	"StubbornIconPlacement" "StubbornIcons" "StubbornPlacement" "Style" "StyleFocus" 
	"SuppressIcons" "Swallow"  "Schedule"

	"Test" "Title" "TitleStyle" "TogglePage" 
        "ThisWindow" "TestRc" 

	"UnsetEnv" "UpdateDecor" "UpdateStyles"

	"Wait" "Warp" "WarpToWindow" "WindowFont" "WindowId" "WindowList" "WindowListSkip" 
	"WindowShade" "WindowShadeAnimate" "WindowsDesk" "Xinerama" "XineramaPrimaryScreen" 
	"XineramaSls" "XineramaSlsSize" "XorPixmap" "XorValue"))
;; 
;; Fvwm keywords
;; 
(defvar fvwm-keywords-1 '(
       "Action" "Active" "ActiveColorset" "ActiveDown" "ActiveFore" "ActiveForeOff"
       "ActivePlacement" "ActivePlacementHonorsStartsOnPage" "ActivePlacementIgnoresStartsOnPage"
       "ActiveUp" "All" "AllDesks" "AllowRestack" "AllPages" "Alphabetic" "Anim" "Animated" "Animation" "AnimationOff" 
       "AutomaticHotkeys" "AutomaticHotkeysOff" "AdjustedPixmap" 
        
       "BGradient" "Back" "BackColor" "Background" "BackingStore" "BackingStoreOff" "BalloonColorset" "bg" 
       "Balloons" "BalloonFont" "BalloonYOffset" "BalloonBorderWidth"
       "BorderColorset" "BorderWidth" "Bottom" "BoundaryWidth" "Buffer" "Button"
       "Button0" "Button1" "Button2" "Button3" "Button4" "Button5" "Button6" "Button7" "Button8"
       "Button9" "ButtonGeometry"

       "CGradient" "CaptureHonorsStorsOnPage" "CoptureIgnoresStartsOnPage" "CascadePlacement"
       "Centered" "CirculateHit" "CirculateHitIcon" "CirculateHitShaded" "CirculateSkip"
       "CirculateSkipIcon" "CirculateSkipShaded" "Clear" "ClickToFocus" "ClickToFocusDoesntPassClick"
       "ClickToFocusDoestRaise" "ClickToFocusPassesClick" "ClickToFocusPassesClickOff"
       "ClickToFocusRaises" "ClickToFocusRaisesOff" "Color" "Colorset" "Context" "Columns"
       "CurrentDesk" "CurrentPage" "CurrentPageAnyDesk"

       "DrawMotion" "DGradient" "DecorateTransient" "Default" "Delay" "DepressableBorder" "Desk" "DontLowerTransient"
       "DontRaiseTransient" "DontShowName" "DontStackTransient" "DontStackTransientParent" "DoubleClick"
       "DoubleClickTime" "Down" "DrawIcons" "DumbPlacement" "DynamicMenu" "DynamicPopDownAction"
       "DynamicPopupAction" 

       "East" "Expect" "Effect"

       "FVWM" "FirmBorder" "Fixed" "FixedPosition" "Flat" "FlickeringMoveWorkaround"
       "FlickeringQtDialogsWorkaround" "FocusColorset" "FocusButton" "FocusFollowsMouse" "FollowsFocus"
       "FollowsMouse" "Fore" "Font" "ForeColor" "ForeGround" "Format" "Frame" "Function" "Fvwm"
       "FvwmBorder" "FvwmButtons" "FeedBack" "fg" "fgsh" "fgAlpha"

       "GNOMEIgnoreHints" "GNOMEUseHints" "Geometry" "GrabFocus" "GrabFocusOff" "GrabFocusTransient"
       "GrabFocusTransientOff" "Greyed" "GreyedColorset"

       "HGradient" "Handles" "HandleWidth" "Height" "HiddenHandles" "Hilight3DOff" "Hilight3DThick"
       "Hilight3DThickness" "Hilight3dThin" "HilightBack" "HilightBackOff" "HilightBorderColorset"
       "HilightColorset" "HilightFore" "HintOverride" "HoldSubmenus"
       "HilightIconTitleColorset" "hi"
       
       "Icon" "IconAlpha" "IconBox" "IconFill" "IconFont" "IconGrid" "IconOverride" "IconTitle"
       "Iconic" "IconifyWindowGroups" "IconifyWindowGroupsOff" "Icons" "IgnoreRestack" "Inactive"
       "InActive" "IndexedWindowName" "Interior" "Item" "ItemFormat" "Iterations"
       "IconTitleColorset" "IconTitleRelief" "IndexedIconName" "IconBackgroundPadding" "IconTint"
       
       "KeepWindowGroupsOnDesk"

       "Layer" "Left" "LeftJustified" "LeftJustify" "Lenience" "LowerTransient" "LeftOfText"

       "Match" "MWM" "MWMBorder" "MWMDecor" "MWMDecorMax" "MWMDecorMenu" "MWMDecorMin" "MWMFunctions"
       "ManagerGeometry" "ManualPlacement" "ManualPlacementHonorsStartsOnPage"
       "ManualPlacementIgnoresStartsOnPage" "MaxWindowSize" "Maximized" "Menu" "MenuColorset"
       "MenuFace" "MiniIcons" "MinOverlapPercentPlacement" "MinOverlapPlacement" "MiniIcon"
       "MixedVisualWorkaround" "ModalityIsEvil" "ModuleSynchronous" "Mouse" "MouseFocus"
       "MouseFocusClickDoesntRaise" "MouseFocusClickRaises" "MouseFocusClickRaisesOff" "Move" "Mwm"
       "MwmBorder" "MwmButtons" "MwmDecor" "MwmFunctions" "MultiPixmap" ))

(defvar fvwm-keywords-2 '(
       "NakedTransient" "Never" "NeverFocus" "NoActiveIconOverride" "NoBorder" "NoButton"
       "NoBoundaryWidth""NoButton" "NoDecorHint" "NoDeskSort" "NoFuncHint" "NoGeometry"
       "NoGeometryWithInfo" "NoHandles" "NoHotkeys" "NoIcon" "NoIconAction" "NoIconOverride" "NoIconPosition"
       "NoIconTitle" "NoIcons" "NoInset" "NoLenience" "NoMatch" "NoNormal" "NoOLDecor" "NoOnBottom" "NoOnTop"
       "NoOverride" "NoPPosition" "NoResizeOverride" "NoSticky" "NoShape" "NoStipledTitles" "NoTitle"
       "NoTransientPPosition" "NoTransientUSPosition" "NoUSPosition" "NoWarp" "Normal" "North"
       "Northeast" "Northwest" "NotAlphabetic"

       "OLDecor" "OnBottom" "OnTop" "Once" "OnlyIcons" "OnlyListSkip" "OnlyNormal" "OnlyOnBottom"
       "OnlyOnTop" "OnlySticky" "Opacity"

       "Padding" "Panel" "ParentalRelativity" "Pixmap" "PlainButton" "PopdownDelayed" "PopdownDelay"
       "PopupDelay" "PopupAsRootMenu" "PopupAsSubmenu" "PopdownImmediately" "PopupDelayed"
       "PopupImmediately" "PopupOffset"

       "Quiet"

       "RGradient" "RaiseOverNativeWindows" "RaiseOverUnmanaged" "RaiseTransient" "Raised" "Read"
       "RecaptureHonorsStartsOnPage" "RecaptureIgnoresStartsOnPage" "Rectangle" "ReliefThickness" "RemoveSubmenus"
       "Reset" "Resize" "ResizeHintOverride" "ResizeOpaque" "ResizeOutline" "Resolution" "ReverseOrder"
       "Right" "RightJustified" "Root" "RootTransparent" "Rows" "RightTitleRotatedCCW"

       "SGradient" "SameType" "SaveUnder" "SaveUnderDiff" "ScatterWindowGroups" "Screen" "SelectButton"
       "SelectInPlace" "SelectOnReleasE" "SelectWarp" "SeparatorsLong" "SeparatorsShort" 
       "ShowCurrentDesk" "ShowMapping"
       "SideColor" "SidePic" "Simple" "SkipMapping" "Slippery" "SlipperyIcon" "SmallFont" "SlippyFocus"
       "SmartPlacement" "SmartPlacementIsNormal" "SmartPlacementIsReallySmart" "Solid" "SolidSeparators"
       "Sort" "South" "Southeast" "Southwest" "StackTransientParent" "StartIconic" "StartNormal"
       "StartsAnyWhere" "StartsLowered" "StartsOnDesk" "StartsOnPage" "StartsOnPageIgnoresTransients"
       "StartsOnPageIncludesTransients" "StartsOnScreen" "StartsRaised" "StaysOnBottom" "StaysOnTop"
       "StaysPut" "Sticky" "StickyAcrossDesks" "StickyIcon" "StipledTitles" "StippledTitle" "StippledTitleOff"
       "SubmenusLeft" "SubmenusRight" "Sunk" "StrokeWidth" "sh"

       "This" "TileCascadePlacement" "TileManualPlacement" "TiledPixmap" "Timeout" "Tint" "Title"
       "TitleAtBottom" "TitleAtLeft" "TitleAtRight" "TitleAtTop" "TitleUnderlines0" "TitleUnderlines1"
       "TitleUnderlines2" "TitleWarp" "TitleWarpOff" "Top" "Transient" "Translucent" "TrianglesRelief"
       "TrianglesSolid" "Toggle" "Twist" 

       "Up" "UseBorderStyle" "UseDecor" "UseIconName" "UseIconPosition" "UseListSkip" "UsePPosition"
       "UseSkipList" "UseStyle" "UseTitleStyle" "UseTransientPPosition" "UseTransientUSPosition"
       "UseUSPosition" "UseWinList" "UnderText"

       "VGradient" "VariablePosition" "Vector" "VerticalItemSpacing" "VerticalTitleSpacing"

       "Width" "WIN" "Wait" "Warp" "WarpTitle" "West" "Win" "Window" "WindowBorderWidth" "Window3dBorders"
       "WindowColorsets" "WindowListHit" "WindowListSkip" "WindowShadeScrolls" "WindowShadeShrinks"
       "Window3DBorders" "WindowShadeSteps" "Windows"

       "XineramaRoot"

       "YGradient"))

;; We need to work around a size limitation for the arguments to regexp-opt in emacses before GNU Emacs 22
(if (string< (substring emacs-version 0 2) "22")
    (let ()
	(defvar fvwm-keywords-1-opt (regexp-opt fvwm-keywords-1))
      (defvar fvwm-keywords-2-opt (regexp-opt fvwm-keywords-2))
      (defvar fvwm-keywords (concat "\\<\\(" fvwm-keywords-1-opt "\\|" fvwm-keywords-2-opt "\\)\\>")))
  (defvar fvwm-keywords (concat "\\<" (regexp-opt (append fvwm-keywords-1 fvwm-keywords-2) t) "\\>")))
;; 
;; Fvwm focusstyles for the Style command (the FP Styles)
;; 
(defvar fvwm-fp-focusstyles (concat "\\<" (regexp-opt '(
       "FPFocusClickButtons" "FPFocusClickModifiers"
       "!FPSortWindowlistByFocus" "FPSortWindowlistByFocus"
       "FPClickRaisesFocused" "!FPClickRaisesFocused"
       "FPClickDecorRaisesFocused" "!FPClickDecorRaisesFocused"
       "FPClickIconRaisesFocused" "!FPClickIconRaisesFocused"
       "!FPClickRaisesUnfocused" "FPClickRaisesUnfocused"
       "FPClickDecorRaisesUnfocused" "FPClickDecorRaisesUnfocused"
       "FPClickIconRaisesUnfocused" "!FPClickIconRaisesUnfocused"
       "FPClickToFocus" "!FPClickToFocus" "FPClickDecorToFocus"
       "!FPClickDecorToFocus" "FPClickIconToFocus" "!FPClickIconToFocus"
       "!FPEnterToFocus" "FPEnterToFocus" "!FPLeaveToUnfocus"
       "FPLeaveToUnfocus" "!FPFocusByProgram" "FPFocusByProgram"
       "!FPFocusByFunction" "FPFocusByFunction"
       "FPFocusByFunctionWarpPointer" "!FPFocusByFunctionWarpPointer"
       "FPLenient" "!FPLenient" "!FPPassFocusClick" "FPPassFocusClick"
       "!FPPassRaiseClick" "FPPassRaiseClick" "FPIgnoreFocusClickMotion"
       "!FPIgnoreFocusClickMotion FPIgnoreRaiseClickMotion"
       "!FPIgnoreRaiseClickMotion" "!FPAllowFocusClickFunction"
       "FPAllowFocusClickFunction" "!FPAllowRaiseClickFunction"
       "FPAllowRaiseClickFunction" "FPGrabFocus" "FPOverrideGrabFocus"
       "!FPOverrideGrabFocus" "FPReleaseFocus"
       "!FPReleaseFocus" "!FPReleaseFocusTransient"
       "FPReleaseFocusTransient" "FPOverrideReleaseFocus"
       "!FPOverrideReleaseFocus") t) "\\>"))
;; 
;; Fvwm focusstyles for the StyleFocus command
;; 
(defvar fvwm-stylefocus-focusstyles (concat "\\<" (regexp-opt '(
       "FocusClickButtons" "FocusClickModifiers"
       "!SortWindowlistByFocus" "SortWindowlistByFocus"
       "ClickRaisesFocused" "!ClickRaisesFocused"
       "ClickDecorRaisesFocused" "!ClickDecorRaisesFocused"
       "ClickIconRaisesFocused" "!ClickIconRaisesFocused"
       "!ClickRaisesUnfocused" "ClickRaisesUnfocused"
       "ClickDecorRaisesUnfocused" "ClickDecorRaisesUnfocused"
       "ClickIconRaisesUnfocused" "!ClickIconRaisesUnfocused"
       "ClickToFocus !ClickToFocus" "ClickDecorToFocus"
       "!ClickDecorToFocus" "ClickIconToFocus" "!ClickIconToFocus"
       "!EnterToFocus" "EnterToFocus" "!LeaveToUnfocus"
       "LeaveToUnfocus" "!FocusByProgram" "FocusByProgram"
       "!FocusByFunction" "FocusByFunction"
       "FocusByFunctionWarpPointer" "!FocusByFunctionWarpPointer"
       "Lenient" "!Lenient" "!PassFocusClick" "PassFocusClick"
       "!PassRaiseClick" "PassRaiseClick" "IgnoreFocusClickMotion"
       "!IgnoreFocusClickMotion" "IgnoreRaiseClickMotion"
       "!IgnoreRaiseClickMotion" "!AllowFocusClickFunction"
       "AllowFocusClickFunction" "!AllowRaiseClickFunction"
       "AllowRaiseClickFunction" "GrabFocus" "OverrideGrabFocus"
       "!OverrideGrabFocus" "ReleaseFocus"
       "!ReleaseFocus" "!ReleaseFocusTransient") t) "\\>"))
;; 
;; EWMH keywords
;; 
(defvar ewmh-keywords (concat "\\<" (regexp-opt '(
       "EWMHDonateIcon" "EWMHDontDonateIcon"
       "EWMHDonateMiniIcon" "EWMHDontDonateMiniIcon"
       "EWMHMiniIconOverride" "EWMHNoMiniIconOverride"
       "EWMHUseStackingOrderHints"  "EWMHIgnoreStackingOrderHints"
       "EWMHIgnoreStateHints" "EWMHUseStateHints"
       "EWMHMaximizeIgnoreWorkingArea" "EWMHMaximizeUseWorkingArea"
       "EWMHMaximizeUseDynamicWorkingArea"
       "EWMHPlacementIgnoreWorkingArea" "EWMHPlacementUseWorkingArea"
       "EWMHPlacementUseDynamicWorkingArea") t) "\\>"))
;;
;; Conditionnames
;; 
(defvar fvwm-conditionnames (concat "\\<" (regexp-opt '(
       "AcceptsFocus" "CurrentDesk" "CurrentGlobalPage"
       "CurrentGlobalPageAnyDesk" "CurrentPage"
       "CurrentPageAnyDesk" "CurrentScreen" "Iconic" "Layer"
       "Maximized" "PlacedByButton3" "PlacedByFvwm" "Raised"
       "Shaded" "Sticky" "Transient" "Visible") t) "\\>"))
;; 
;; Contextnames
;; 
(defvar fvwm-contextnames (concat "\\<" (regexp-opt '(
       "BOTTOM" "BOTTOM_EDGE" "BOTTOM_LEFT" "BOTTOM_RIGHT"
       "DEFAULT" "DESTROY" "LEFT" "LEFT_EDGE" "MENU" "MOVE"
       "RESIZE" "RIGHT" "RIGHT_EDGE" "ROOT" "SELECT" "STROKE" "SYS"
       "TITLE" "TOP" "TOP_EDGE" "TOP_LEFT" "TOP_RIGHT" "WAIT"
       "POSITION") t) "\\>"))
;; 
;; Fvwm module and special function names
;; 
(defvar fvwm-special (concat "\\<" (regexp-opt '(
       "FvwmAnimate" "FvwmAudio" "FvwmAuto" "FvwmBacker" "FvwmBanner"
       "FvwmButtons" "FvwmCascade" "FvwmCommandS" "FvwmConsole"
       "FvwmConsoleC" "FvwmCpp" "FvwmDebug" "FvwmDragWell" "FvwmEvent" 
       "FvwmForm" "FvwmGtk" "FvwmIconBox" "FvwmIconMan" "FvwmIdent"
       "FvwmM4" "FvwmPager" "FvwmRearrange" "FvwmSave" "FvwmSaveDesk"
       "FvwmScript" "FvwmScroll" "FvwmTalk" "FvwmTaskBar" "FvwmTheme"
       "FvwmTile" "FvwmWharf" "FvwmWindowMenu" "FvwmWinList"

       "StartFunction" "InitFunction" "RestartFunction" "ExitFunction"
       "SessionInitFunction" "SessionRestartFunction" "SessionExitFunction"
       "MissingSubmenuFunction") t) "\\>"))
;; 
;; Some others:
;; (regexp-opt '("bottom bottomright" "button" "default" "down" "indicator" "none" "pointer" "position" "prev" "quiet" "top" "unlimited") t)
;; (regexp-opt '("True" "False" "Toggle") t)
;; 
(defconst fvwm-font-lock-keywords-1
  (list
   '("\\(#[0-9a-fA-F]\\{12\\}\\)" . fvwm-rgb-value-face) ;hilight RGB values, never seen this before, but it was in fvwm.vim...
   '("\\(#[0-9a-fA-F]\\{9\\}\\)" . fvwm-rgb-value-face)	;hilight RGB values, never seen this before, but it was in fvwm.vim...
   '("\\(#[0-9a-fA-F]\\{6\\}\\)" . fvwm-rgb-value-face)	;hilight RGB values
   '("\\(#[0-9a-fA-F]\\{3\\}\\)" . fvwm-rgb-value-face)	;hilight RGB values
   '("\\(rgb:[0-9a-fA-F]\\{1,4\\}\/[0-9a-fA-F]\\{1,4\\}\/[0-9a-fA-F]\\{1,4\\}\\)" 1 fvwm-rgb-value-face) ;hilight RGB values
   '("^[ ]*\\(#.*\\)" 1 font-lock-comment-face) ;hilight comments
   '("\\(&.\\)" 1 fvwm-shortcut-key-face)  ;fvwm shortcutkey
   '("\"[^\"]*\"" . font-lock-string-face) ;hilight doublequoted strings
   '("\'[^\']*\'" . font-lock-string-face) ;hilight singlequoted strings
   '("\`[^\`]*\`" . font-lock-string-face) ;hilight backticked strings
   '("*\\([a-zA-Z]*\\):" 1 fvwm-special-face) ;hilight module names
   '("\\($\\[[^$]*\\]\\)" 1 font-lock-variable-name-face) ;hilight Fvwm variables
   (cons (concat "\\<" (regexp-opt fvwm-functions t) "\\>") font-lock-function-name-face) ;Fvwm functions to hilight
   (cons fvwm-keywords font-lock-keyword-face) ;Hilight Fvwm functions
   (cons fvwm-fp-focusstyles font-lock-keyword-face) ;Fvwm FP Style keywords to hilight
   (cons fvwm-stylefocus-focusstyles font-lock-keyword-face);Fvwm StyleFocus keywords
   (cons ewmh-keywords font-lock-keyword-face) ;EWMH keywords
   (cons fvwm-conditionnames font-lock-keyword-face) ;Conditionnames to hilight
   (cons fvwm-contextnames font-lock-constant-face) ;Fvwm context keywords
   (cons fvwm-special fvwm-special-face)) ;Fvwm builtin modules and special functions
  "Fvwm keywords to hilight")
;; 
;; FvwmScript keywords
;; 
(defvar fvwmscript-instructions (concat "\\<" (regexp-opt '(
       "HideWidget" "ShowWidget" "ChangeValue" "ChangeMaxValue" "ChangeMinValue"
       "ChangeTitle" "ChongeLocaleTitle" "ChangeIcon" "ChangeForeColor" 
       "ChangeBackColor" "ChangeColorset" "ChongePosition" "ChangeSize" "ChangeFont"
       "WarpPointer" "WriteToFile" "Do" "Set" "Quit" "SendSignal" "SendToScript"
       "Key") t) "\\>")) ;instructions
(defvar fvwmscript-functions (concat "\\<" (regexp-opt '(
       "GetTitle" "GetValue" "GetMinValue" "GetMaxValue" "GetFore" "GetBack"
       "GetHilight" "GetShadow" "GetOutput" "NumToHex" "HexToNum" "Add" "Mult" "Div"
       "StrCopy" "LaunchScript" "GetScriptArgument" "GetScriptFather"
       "ReceivFromScript" "RemainderOfDiv" "GetTime" "GetPid" "Gettext"
       "SendMsgAndGet" "Parse" "LastString") t) "\\>")) ;functions
;;gotta check these (regexp-opt '("Begin" "Case" "Do" "End" "Init" "Main" "PeriodicTasks" "Property" "QuitFunc" "Set" "Widget" "If" "Then" "Else") words) ;functions
(defvar fvwmscript-properties (concat "\\<" (regexp-opt '(
       "Type" "Size" "Position" "Title" "Value" "MaxValue" "MinValue" "Font"
       "ForeColor" "BackColor" "HilightColor" "ShadowColor" "Colorset" "Flags") t) "\\>"));properties
(defvar fvwmscript-flagsopt (concat "\\<" (regexp-opt '(
       "Hidden" "NoReliefString" "NoFocus" "Left" "Center" "Right") t) "\\>"))	;flagsOpt
(defvar fvwmscript-keywords (concat "\\<" (regexp-opt '(
       "BackColor" "Colorset" "DefaultFont" "DefaultBack" "DefaultColorset"
       "DefaultFore" "DefaultHilight" "DefaultShadow" "Font" "ForeColor" "HilightColor"
       "ShadowColor" "SingleClic" "UseGettext" "WindowLocaleTitle" "WindowPosition"
       "WindowSize" "WindowTitle" ) t) "\\>"));keywords
(defvar fvwmscript-widgets (concat "\\<" (regexp-opt '(
       "CheckBox" "HDipstick" "HScrollBar" "ItemDraw" "List" "Menu" "MiniScroll"
       "PopupMenu" "PushButton" "Rectangle" "SwallowExec" "TextField" "VDipstick"
       "VScrollBar") t) "\\>")) ;widgets
;; 
(defconst fvwm-font-lock-keywords-2
  (append fvwm-font-lock-keywords-1
	  (list
	   '("\\(rgb:..\/..\/..\\)" 1 fvwm-rgb-value-face)
	   '("\\($[-_a-zA-Z0-9]*\\)" 1 font-lock-variable-name-face)
	   (cons fvwmscript-instructions font-lock-function-name-face) ;instructions
	   (cons fvwmscript-functions font-lock-function-name-face) ;functions
	   '("\\<\\(Begin\\|Case\\|Do\\|E\\(?:lse\\|nd\\)\\|I\\(?:f\\|nit\\)\\|Main\\|P\\(?:eriodicTasks\\|roperty\\)\\|QuitFunc\\|Set\\|Then\\|Widget\\)\\>" . font-lock-keyword-face)
	   (cons fvwmscript-properties font-lock-keyword-face) ;properties
	   (cons fvwmscript-flagsopt font-lock-function-name-face) ;flagsOpt
	   (cons fvwmscript-keywords font-lock-keyword-face)	  ;keywords
	   (cons fvwmscript-widgets font-lock-keyword-face)))	  ;widgets
	  "FvwmScript keywords to hilight")

(defvar fvwm-font-lock-keywords fvwm-font-lock-keywords-2 "Default hilighting for FVWM mode")

;; -------------------------
;; |       Functions       |
;; -------------------------
(defun fvwm-insert-function (name)
  "Inserts the skeleton for an FVWM Function into the current buffer."
  (interactive "sFunction name? ")
  (skeleton-insert
   '(nil "AddToFunc " name "\n"
	 " + " _ )))
;;   (define-skeleton fvwm-function
;;     "Defines the skeleton for an FVWM Function."
;;     "Function name: "
;;     "AddToFunc " name "\n"
;;     " +" _))

(defun fvwm-insert-menu (name)
  "Inserts the skeleton for an FVWM Menu into the current buffer."
  (interactive "sMenu name? ")
  (skeleton-insert
   '(nil "DestroyMenu name\n"
	 "AddToMenu name\n"
	 " + " _)))

(defun fvwm-insert-buttons (name rows columns geometry)
  "Inserts the skeleton for an FvwmButtons and adds it to your StartFunction (if possible)
Pressing enter at any prompt skips that option and doesn't include it in the skeleton."
  (interactive "sFvwmButtons alias? \nsAmount of rows? \nsAmount of columns? \nsGeometry? ")
  (skeleton-insert
   '(nil "DestroyModuleConfig " name ": *\n"
	 (if (not (string-equal rows "" )) (insert (concat "*" name ": Rows " rows "\n")))
	 (if (not (string-equal columns "" )) (insert (concat "*" name ": Columns " columns "\n")))
	 (if (not (string-equal geometry "" )) (insert (concat "*" name ": Geometry " geometry "\n")))
	 "\n")))

(defun fvwm-script-insert-skeleton (title width height font)
  "Inserts the skeleton for an FvwmScript into the current buffer"
  (interactive "sFvwmScript title: \nsWidth (default: empty): \nsHeight (default: empty): \nsFont definition (default: empty): ")
  (goto-char (point-min))
  (skeleton-insert
   '(nil "#-*-fvwm-*-\n"
	 "WindowTitle {" title "}\n"
	 (if (and (not (string-equal width "")) (not (string-equal height ""))) (insert (concat "WindowSize " width " " height)))
	 (if (not (string-equal font "")) (insert (concat "Font " font)))
	 "Init\n"
	 "Begin\n"
	 " " _ "\n"
	 "End\n\n"
	 "PeriodicTasks\n"
	 "Begin\n"
	 " \n"
	 "End\n")))

(defun fvwm-script-insert-widget (type title number x-pos y-pos width height)
  "Inserts the skeleton for a new FvwmScript widget,the type is the type of widget to insert (see man FvwmButtons for details), the title is the title for the widget, or nothing if left empty, the numder is the number the widget will get it defaults to number one higher than the current highest widget number"
  (interactive "sWidget type (default: ItemDraw): \nsWidget title (default: empty): \nsWidget number (default: next highest number): \nsx-position (default: 0): \nsy-position (default: 0): \nsWidth (default: 100): \nsHeight (default: 50): ")
  (if (string= number "")
      (let ((widget-number "0") temp-widget-number (working-point-position (point))) ; use save-excursion instead of saving the point position
	"Find the highest numbered widget" 
	(goto-char (point-max))
	(while (re-search-backward "^Widget \\(.*\\)" nil t)
	  (setq temp-widget-number (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
	  (if (string< widget-number temp-widget-number)
	      (progn
		(setq widget-number temp-widget-number)
		(forward-word 1))))
	(setq number (+ (string-to-int widget-number) 1))
	(goto-char working-point-position)))
  (skeleton-insert
   '(nil "Widget " (number-to-string number) "\n"
	 "Property\n"
	 " Position " x-pos | "0" " " y-pos | "0" "\n"
	 " Size " width | "100" " " height | "50" "\n"
	 " Type " type | "ItemDraw" "\n"
	 " Title {" title "}\n"
	 "Main\n"
	 " Case message of\n"
	 "  SingleClic:\n"
	 "  Begin\n"
	 "   " _ "\n"
	 "  End\n"
	 "End\n")))

(setq fvwm-keywords-map nil)

(defun fvwm-generate-hashmap ()
  "Generates the alist or hash-map needed by fvwm-complete-keyword"
  (let ((fvwm-keywords-all (append fvwm-functions fvwm-keywords-1 fvwm-keywords-2)))
    (message "Generating list of completions...")
    (if (and (not (featurep 'xemacs)) (> emacs-major-version 21))
	(progn
	  (setq fvwm-keywords-map (makehash))
	  (let ((i 0))
	    (while (< i (length fvwm-keywords-all))
	      (puthash (nth i fvwm-keywords-all) nil fvwm-keywords-map)
	      (setq i (+ i 1)))))
      (progn
	(setq fvwm-keywords-map (list))
	(let ((i 0) (cur))
	  (while (< i (length fvwm-keywords-all))
	    ;(setq fvwm-keywords-map (cons fvwm-keywords-map ((nth i fvwm-keywords-all) . nil))) ; This is not cool...
	    (mapcar (lambda (e) (add-to-list 'fvwm-keywords-map (cons e nil))) fvwm-keywords-all) ;thank you fledermaus!
	    (setq i (+ i 1))))))))

(defun fvwm-complete-keyword ()
  "Completes the FVWM keywords before point by comparing it against the known FVWM keywords"
  ;; This function is largely based on lisp-complete-symbol from GNU Emacs' lisp.el
  (interactive)

  (if (not fvwm-keywords-map)
      (fvwm-generate-hashmap))

  (let ((window (get-buffer-window "*Completions*")))
    (if (and (eq last-command this-command)
	     window (window-live-p window) (window-buffer window)
	     (buffer-name (window-buffer window)))
	;; If there's already a completion buffer open, reuse it.
	(with-current-buffer (window-buffer window)
	  (if (pos-visible-in-window-p (point-max) window)
	      (set-window-start window (point-min))
	    (save-selected-window
	      (select-window window)
	      (scroll-up))))

      ;; Do completion
      (let* ((end (point))
	     (beg (with-syntax-table fvwm-syntax-table
		    (save-excursion
		      (backward-sexp 1)
		      (while (= (char-syntax (following-char)) ?\')
			(forward-char 1))
		      (point))))
	     (pattern (buffer-substring-no-properties beg end))
	     (completion (try-completion pattern fvwm-keywords-map)))
	(cond ((eq completion t))
	      ((null completion)
	       (message "Can't find completion for \"%s\"" pattern)
	       (ding))
	      ((not (string= pattern completion))
	       (delete-region beg end)
	       (insert completion))
	      (t
	       (message "Making completion list...")
	       (let ((list (all-completions pattern fvwm-keywords-map)))
		 (setq list (sort list 'string<))
		 (let (new)
		   (while list
		     (setq new (cons (if (fboundp (intern (car list)))
					 (list (car list) " <f>")
				       (car list))
				     new))
		     (setq list (cdr list)))
		   (setq list (nreverse new)))
		 (with-output-to-temp-buffer "*Completions*"
		   (display-completion-list list)))
	       (message "Making completion list...%s" "done")))))))

(add-hook 'before-save-hook
	  '(lambda ()
	     (save-excursion
	       (goto-char (point-min))
	       (if (buffer-modified-p)
		   (if (re-search-forward (concat "^" fvwm-last-updated-prefix ".*") nil t)
		       (replace-match (concat fvwm-last-updated-prefix (format-time-string fvwm-time-format-string) fvwm-last-updated-suffix)))))))

;; -------------------------
;; |   Run Fvwm commands   |
;; -------------------------
(defun fvwm-execute-command (command)
  "Execute the specified FVWM command using FvwmCommand. Which of course needs to be running, see man FvwmCommand for details on that."
  (interactive "sCommand? ")
  (if (featurep 'xemacs)
      (shell-command (concat fvwm-fvwmcommand-path " '" command "'") "*fvwm-output*")
    (shell-command (concat fvwm-fvwmcommand-path " '" command "'") "*fvwm-output*" "*fvwm-error*")))

(defun fvwm-execute-region ()
  "Execute the specified FVWM command using FvwmCommand. Which of course needs to be running, see man FvwmCommand for details on that."
  (interactive)
  (let ((end (region-end)) (beg (region-beginning)))
    (goto-char beg)
    (while (< beg end)
      (progn
	(beginning-of-line)
	(setq beg (point))
	(end-of-line)
	(fvwm-execute-command (buffer-substring beg (point)))
	(line-move 1)))
    (line-move -1)))

(defun fvwm-execute-file ()
  "Execute the file containing FVWM commands as the 'Read' FVWM statement would do, you need to have FvwmCommand working for this to actually work, see man FvwmCommand for details on that."
  (interactive)
  (fvwm-execute-command (concat "Read " (expand-file-name (read-file-name "Path to file: " "~/.fvwm")))))

;; -------------------------
;; |    Entry function     |
;; -------------------------
(defun fvwm-mode ()
  "Launches the FVWM major mode."
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table fvwm-syntax-table)
  (setq comment-start "# ")
  (setq require-final-newline t)

  (use-local-map fvwm-mode-map)

  (set (make-local-variable 'font-lock-defaults) (list 'fvwm-font-lock-keywords nil fvwm-keywords-force-case))
  ;; (set (make-local-variable 'indent-line-function) 'fvwm-indent-line)
  (setq major-mode 'fvwm-mode
	mode-name "FVWM")

  ;; XEmacs needs this, otherwise the menu isn't displayed.
  (if (featurep 'xemacs)
      (easy-menu-add fvwm-menu fvwm-mode-map))

  ;; Create the completions database when the mode is first loaded.
  (if fvwm-preload-completions
      (fvwm-generate-hashmap))

  (run-hooks 'fvwm-mode-hook))

(provide 'fvwm-mode)
