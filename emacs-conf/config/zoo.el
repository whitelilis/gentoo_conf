;; red Hat Linux default .emacs initialization file
;; Time-stamp: <wizard 2012/03/07 15:31:44>

;;wizard code below
;; (set-coding-system 'chinese-iso-8bit)

;;hidden some code of program ?
;;(setq hs-minor-mode-prefix [(contrl o)])

(global-auto-revert-mode t)

(require 'ido)
(ido-mode t)

(require 'template)
(template-initialize)

;How does template.el cooperate with ido.el? simply adding ido-find-file to template-find-file-commands doesn’t work, you need add this to your dot emacs file:
(add-to-list 'template-find-file-commands 'ido-exit-minibuffer)
;; with pde mode's template, they cooperate well.

(setq c-default-style "linux")
(setq perl-indent-continued-arguments "BSD")


;; time stamp
(setq time-stamp-active t)
(setq time-stamp-format "%:u %04y/%02m/%02d %02H:%02M:%02S")
(add-hook 'write-file-hooks 'time-stamp)


;; auto fill mode
(setq outline-minor-mode-prefix [(control o)])
(setq adaptive-fill-regexp "[ \t]+\\|[ \t]*\\([0-9]+\\.\\|\\*+\\)[ \t]*")
(setq adaptive-fill-first-line-regexp "^\\* *$")


(setq frame-title-format "%b---in EMACS")
(fset 'yes-or-no-p 'y-or-n-p)
(display-time) ;;save place for other
(column-number-mode t)
(transient-mark-mode t)
(show-paren-mode t)

;;(setq lazy-lock-defer-on-scrolling t)
;;(setq font-lock-support-mode 'lazy-lock-mode)

(setq font-lock-maximum-decoration t)
(setq-default make-backup-files nil)
(setq inhibit-startup-message t)
(mouse-avoidance-mode 'animate)
(setq scroll-margin 3
      scroll-conservatively 10000)


(setq dired-recursive-deletes t)
(setq dired-recursive-copies t)

(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'LaTeX-hide-environment 'disabled nil)


(setq version-control t)

(setq dired-kept-versions 1)
(setq kept-old-versions 2)
(setq kept-new-versions 5)
(setq delete-old-versions t)
(setq backup-directory-alist '(("." . "~/var/tmp")))
(setq backup-by-copying t)



;;wizard code end


;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
;;(global-set-key [delete] 'delete-char)
;;(global-set-key [kp-delete] 'delete-char)
;; turn on font-lock mode
;; enable visual feedback on selections
(setq-default transient-mark-mode t)

;; always end a file with a newline
(setq require-final-newline t)

;; stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)
;; keep point add end of line when move on end of line
(setq track-eol t)
;; keep kill ring max
(setq kill-ring-max 600)
;; when C-k at beginging of line,also delete this line
(setq-default kill-whole-line t)

(when window-system
  ;; enable wheelmouse support by default
  (mwheel-install)
  ;; use extended compound-text coding for X clipboard
  (set-selection-coding-system 'compound-text-with-extensions))

;; (setup-chinese-gb-environment)
;; (set-language-environment 'Chinese-GB)

;; prefer utf-8

;; copy and paste chinese charicters with other applications
;; (set-clipboard-coding-system 'ctext)
;; (set-clipboard-coding-system 'mule-utf-8-unix)
(prefer-coding-system 'utf-8)
(set-language-environment "utf-8")
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                     my functions below              ;;;;;;

;;;;;;;;;;;;;;  auto many windows ,only for gdb ;;;;;;;;;;;;;;;

(defvar gdb-many-windows t)
(global-cwarn-mode t) ;; warning in c/c++
;;;;;;;;;;;;;;;;; jdb validate test ;;;;;;;;;;;;;;;;;;;
(setq process-connection-type nil)

;;;;;;;;;;;;;;;;;;;; simple hooks ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (add-hook 'c-mode-hook
;;        '(lambda ()
;;           (c-toggle-auto-hungry-state)
;;           (flyspell-mode)
;;           (auto-fill-mode)))
(defun usefullmodes()
  "some usefull mode when programming"
  (c-toggle-auto-hungry-state)
  (outline-minor-mode)
  (font-lock-mode)
;;;   (flyspell-mode)
;;;   (text-mode-hook-identify)
  (turn-on-auto-fill)
  )
(add-hook 'text-mode-hook 'usefullmodes)
(add-hook 'c-mode-hook 'usefullmodes)
(add-hook 'c++-mode-hook 'usefullmodes)
;(add-hook 'java-mode-hook 'usefullmodes)
;(add-hook 'java-mode-hook 'senator-minor-mode) ;conflict with hippie-expand
(add-hook 'perl-mode-hook 'usefullmodes)

(add-hook 'vc-mode-hook 'vc-dired-toggle-terse-mode)

;; (add-hook 'find-file-hook 'flymake-find-file-hook) ;for auto check; worked but not as I think
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;  browse kill ring ;;;;;;;;;;;;;;

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq default-major-mode 'text-mode)

;; with cedet, the following is not necessary, but semantor conflict with hippie-expand, and always I don't use semantor, so not use cedet now.
;; (setq semantic-load-turn-everything-on t)
;; (require 'semantic-load)
;; (setq global-semantic-summary-mode t)
;; (setq semantic-load-turn-everything-on t)
;; (require 'semantic-ia)


;;; ctypes
(require 'ctypes)
(ctypes-auto-parse-mode)


(autoload 'javascript-mode "javascript" nil t)
(mapcar
 (function (lambda (setting)
             (setq auto-mode-alist
                   (cons setting auto-mode-alist))))
 '(("\\\.sh" . sh-mode)
   ("\\\.bash" . sh-mode)
   ("\\.pl" . cperl-mode)
   ("\\.pm" . cperl-mode)
   ("\\.rdf$".  sgml-mode)
   ("\\.session$" . emacs-lisp-mode)
   ("\\.l$" . c-mode)
   ("\\.y$" . c-mode)
   ("\\.css$" . css-mode)
   ("\\.cfm$" . html-mode)
   ;;    ("rc$" . conf-mode)                        ;for rc file
   ("gnus" . emacs-lisp-mode)
   ("\\.sgmdoc$" . docbook-mode)
   ("\\.sgmldoc$" . docbook-mode)
   ("\\.xml$" . nxml-mode)
   ("\\.el$"  . emacs-lisp-mode)
   ("\\.php$" . html-mode)              ;additional mmm-mode
   ("\\.jsp$" . html-mode)              ;additional mmm-mode
   ("\\.idl$" . idl-mode)
   ("\\.js\\'" . javascript-mode)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fix junk characters (^M)in shell mode
(add-hook 'shell-mode-hook
          'ansi-color-for-comint-mode-on)

;; user info, usefull in many situation
(setq user-full-name "LiuZhe")
(setq user-mail-address "whitelilis@gmail.com")


;; cvs

;; (setq vc-default-back-end 'CVS)
;; (autoload 'cvs-add "cvs-add" "CVS add" t)
;; (autoload 'cvs-commit "cvs-commit" "CVS commit" t)
;; (autoload 'cvs-diff "cvs-diff" "CVS diff" t)

;; (plan)
;; (delete-other-windows)

;(setq default-frame-alist '(font . "文泉驿等宽正黑"))
(set-default-font "文泉驿等宽正黑-12")

;(set-face-attribute 'default nil :font "文泉驿等宽微米黑-12") ; very good width
;(set-face-attribute 'default nil :font "Monaco-12")  ; good for programming
(set-face-attribute 'default nil :height 120) ; The value is in 1/10pt, so 100 will give you 10pt, etc.

(server-start)

;; (require 'freemind)
