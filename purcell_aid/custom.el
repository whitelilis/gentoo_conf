(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector (vector "#657b83" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#fdf6e3"))
 '(custom-enabled-themes (quote (sanityinc-solarized-dark)))
 '(custom-safe-themes (quote ("4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" default)))
 '(fci-rule-color "#eee8d5")
 '(cua-enable-cua-keys nil)
 '(session-use-package t nil (session)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; wizard code start here
;; zoo
(setq backup-directory-alist '(("." . "~/back")))


;; rainbow-delimiters-mode is good, add for all
(global-rainbow-delimiters-mode)

;; default use sbcl
(setq slime-default-lisp 'sbcl)
(global-set-key "\C-cs" 'slime-selector)
(eval-after-load 'slime
  '(progn
     (slime-setup '(slime-fancy slime-xref-browser slime-scratch))
     (setq slime-autodoc-use-multiline-p t)))


;;; for time display
(setq display-time-24hr-format t)
(setq display-time-format "%Y-%m-%d %R")
(display-time)

;; larger font
(increment-default-font-height 20)


;;; for perl mode
(defalias 'perl-mode 'cperl-mode)
(add-hook 'cperl-mode-hook 'n-cperl-mode-hook t)
(defun n-cperl-mode-hook ()
  (paredit-mode)
  (setq cperl-indent-level 8)
  (setq cperl-continued-statement-offset 0)
;  (setq cperl-extra-newline-before-brace t)
;  (set-face-background 'cperl-array-face "blue")
;  (set-face-background 'cperl-hash-face "red")
  )


;;; frenquency used command in slime repl
(defun change-pr ()
  (interactive)
  (slime-repl-previous-input)
  (paredit-backward)
  (paredit-wrap-sexp))
(global-set-key [(control x) (w)]  'change-pr)

;;; font
(set-default-font "文泉驿等宽正黑-12")
;(set-face-attribute 'default nil :font "文泉驿等宽微米黑-12") ; very good width
;(set-face-attribute 'default nil :font "Monaco-12")  ; good for programming
;(set-face-attribute 'default nil :height 120)
                                        ; The value is in 1/10pt, so 100 will give you 10pt, etc.
;;; org export to html, no sub-superscripts
(eval-after-load 'org
  '(progn
     (setq org-use-sub-superscripts nil)))

(setq org-agenda-files (list "/home/wizard/src/github/org/work.org"
                             "/home/wizard/src/github/org/life.org" 
                             "/home/wizard/src/github/org/issue.org"))

;;; rebind
(global-set-key [(control s)] '(lambda ()
                                 "For easy search, eg C-s C-w"
                                 (interactive)
                                 (backward-word)
                                 (isearch-forward)))
(global-set-key [(f5)] 'query-replace-regexp)
(global-set-key [(f8)] 'magit-status)
(global-set-key [(control f8)] 'magit-log)


(setq hippie-expand-try-functions-list
      '(
        try-expand-dabbrev
        try-expand-dabbrev-visible
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-expand-list
        try-expand-list-all-buffers
        try-expand-line-all-buffers
        try-expand-line
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol
        try-expand-whole-kill
        senator-try-expand-semantic
;;;         senator-complete-symbol
;;;         semantic-ia-complete-symbol
        ispell-complete-word))
(global-set-key [(control tab)] 'hippie-expand) ;hippie-expand is very good 

(setq ac-expand-on-auto-complete t)
(setq ac-auto-start t)







